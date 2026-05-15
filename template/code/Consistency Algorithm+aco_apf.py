import numpy as np
import matplotlib.pyplot as plt
from matplotlib.animation import FuncAnimation
from collections import deque
import csv

# ===========================
# 1. 参数与基础类定义
# ===========================

class UAVParams:
    def __init__(self):
        # 物理限制 (参考论文)
        self.v_max = 80       # 最大速度 m/s
        self.a_max = 4 * 9.8  # 最大加速度 (4g)
        
        # 控制参数 (论文 Table 2)
        self.k1 = 0.8         # 位置误差增益
        self.k2 = 1.2         # 速度误差增益
        self.k3 = 0.8         # 导航项增益
        self.tau_v = 1.5      # 自动驾驶仪延迟时间常数
        self.dt = 0.1         # 仿真步长
        self.safe_margin = 20 # 障碍物安全距离，提高留空
        self.horizon = 5.0    # 预测视距 (秒)
        self.steps = 25       # 预测步数

        # 五项综合适应度权重 J = alpha*L + beta*S + gamma*R + mu*W + lambda_f*F
        self.alpha = 0.24
        self.beta = 0.18
        self.gamma = 0.32
        self.mu = 0.14
        self.lambda_f = 0.12

        # 风险子项权重 R = Rs + Rd + Rc + Rf（各子项可缩放）
        self.w_rs = 1.00
        self.w_rd = 1.00
        self.w_rc = 1.00
        self.w_rf = 1.00

        # 各分量归一化参考值，防止量纲差异导致某项主导优化
        self.len_ref = 1200.0
        self.smooth_ref = 6.0
        self.risk_ref = 80.0
        self.reliability_ref = 1.0
        self.feasibility_ref = 20.0

        # 通信风险相关参数
        self.comm_range = 220.0
        self.comm_ideal_dist = 85.0
        self.comm_delay_base = 0.05
        self.comm_delay_dist_gain = 0.0015
        self.comm_density_threshold = 3
        self.comm_interference_gain = 2.2

        # 轨迹采样与急转惩罚参数
        self.path_sample_step = 14.0
        self.tight_turn_threshold_deg = 65.0
        self.tight_turn_penalty = 8.0

        # 调试输出开关
        self.debug_fitness = False

class Obstacle:
    def __init__(self, center, radius, velocity=None):
        self.center = np.array(center, dtype=float)
        self.radius = float(radius)
        self.velocity = np.array(velocity, dtype=float) if velocity is not None else np.zeros(2)

    def update(self, dt):
        """更新动态障碍物的位置"""
        self.center += self.velocity * dt

class UAV:
    def __init__(self, uav_id, initial_state, params):
        self.id = uav_id
        self.params = params
        # State: [x, y, vx, vy]
        self.state = np.array(initial_state, dtype=float)
        
        # 历史状态队列 (用于处理通信延迟)
        self.history = deque()
        self.history.append((0.0, self.state.copy()))

    def get_delayed_state(self, current_time, delay):
        target_time = current_time - delay
        if target_time <= 0:
            return self.history[0][1]
        
        # 倒序查找最近的历史状态
        for i in range(len(self.history) - 1, -1, -1):
            t_hist, s_hist = self.history[i]
            if t_hist <= target_time:
                return s_hist
        return self.history[0][1]

    def update_dynamics(self, acc_cmd):
        """
        基于一阶自动驾驶仪模型更新状态
        这里直接输入加速度指令 u
        """
        x, y, vx, vy = self.state
        ax_cmd, ay_cmd = acc_cmd
        
        # 物理更新
        new_vx = vx + ax_cmd * self.params.dt
        new_vy = vy + ay_cmd * self.params.dt
        new_x = x + vx * self.params.dt + 0.5 * ax_cmd * self.params.dt**2
        new_y = y + vy * self.params.dt + 0.5 * ay_cmd * self.params.dt**2
        
        self.state = np.array([new_x, new_y, new_vx, new_vy])

    def store_state(self, time):
        self.history.append((time, self.state.copy()))
        if len(self.history) > 100:
            self.history.popleft()

# ===========================
# 2. 核心算法：路径与控制
# ===========================

def get_point_to_point_command(pos, target_pos, params):
    """
    生成从当前位置指向目标点的参考速度
    """
    direction = np.array(target_pos) - np.array(pos)
    distance = np.linalg.norm(direction)

    speed = 25.0
    # 接近目标时减速
    if distance < 50.0:
        speed = max(5.0, 25.0 * (distance / 50.0))

    if distance < 1.0:
        return np.zeros(2), 0.0, 0.0

    unit_direction = direction / distance
    heading = np.arctan2(unit_direction[1], unit_direction[0])
    v_target = unit_direction * speed

    return v_target, heading, 0.0

def rotate_offsets(base_offsets, heading):
    """
    将基础队形偏移量根据当前航向进行旋转
    """
    rotated_offsets = {}
    c = np.cos(heading)
    s = np.sin(heading)
    R = np.array([[c, -s], 
                  [s,  c]])
    
    for uid, offset in base_offsets.items():
        rotated_offsets[uid] = R.dot(offset)
        
    return rotated_offsets

def predict_clearance(pos, vel, obstacles, params, horizon=2.5, steps=10):
    dt_seg = horizon / steps
    pos_curr = np.array(pos, dtype=float)
    min_clear = float('inf')
    
    travel_dist = horizon * np.linalg.norm(vel)
    close_obstacles = [obs for obs in obstacles if np.linalg.norm(pos_curr - obs.center) < travel_dist + obs.radius + params.safe_margin]
    
    for _ in range(steps):
        pos_curr = pos_curr + vel * dt_seg
        for obs in close_obstacles:
            d = np.linalg.norm(pos_curr - obs.center) - obs.radius
            min_clear = min(min_clear, d)
    return min_clear

def obstacle_repulsion(pos, vel, obstacles, params):
    """计算障碍物对无人机的斥力 (APF斥力项)"""
    if not obstacles:
        return np.zeros(2)
    pos = np.array(pos, dtype=float)
    vel = np.array(vel, dtype=float)
    nearest = None
    nearest_clear = float('inf')
    for obs in obstacles:
        d = np.linalg.norm(pos - obs.center) - obs.radius
        if d < nearest_clear:
            nearest_clear = d
            nearest = obs
            
    influence = nearest.radius + params.safe_margin + 50.0 
    if nearest_clear > influence:
        return np.zeros(2)
        
    dir_vec = pos - nearest.center 
    norm = np.linalg.norm(dir_vec)
    if norm < 1e-3:
        dir_unit = np.array([1.0, 0.0])
    else:
        dir_unit = dir_vec / norm
        
    strength = max(0.0, (influence - nearest_clear) / influence)
    f_radial = dir_unit * 25.0 * strength 
    
    tangent_unit = np.array([-dir_unit[1], dir_unit[0]])
    if np.dot(vel, tangent_unit) < 0:
        tangent_unit = -tangent_unit
        
    f_tangent = tangent_unit * 15.0 * strength
    
    return f_radial + f_tangent

def default_base_offsets():
    return {
        0: np.array([0.0, 0.0]),
        1: np.array([-20.0, 20.0]),
        2: np.array([-20.0, -20.0]),
        3: np.array([-40.0, 40.0]),
        4: np.array([-40.0, -40.0]),
    }


def segment_sample_points(a, b, step):
    a = np.asarray(a, dtype=float)
    b = np.asarray(b, dtype=float)
    seg = b - a
    dist = np.linalg.norm(seg)
    n = max(2, int(np.ceil(dist / max(step, 1e-6))) + 1)
    ts = np.linspace(0.0, 1.0, n)
    return np.array([a + t * seg for t in ts])


def path_length_cost(points):
    if len(points) < 2:
        return 0.0
    return float(np.sum(np.linalg.norm(points[1:] - points[:-1], axis=1)))


def path_smoothness_cost(points, params):
    if len(points) < 3:
        return 0.0, [], 0

    threshold = np.deg2rad(params.tight_turn_threshold_deg)
    smooth_cost = 0.0
    turn_angles = []
    sharp_turn_count = 0

    for k in range(1, len(points) - 1):
        v1 = points[k] - points[k - 1]
        v2 = points[k + 1] - points[k]
        n1 = np.linalg.norm(v1)
        n2 = np.linalg.norm(v2)
        if n1 < 1e-8 or n2 < 1e-8:
            continue

        cos_val = np.clip(np.dot(v1, v2) / (n1 * n2), -1.0, 1.0)
        theta = float(np.arccos(cos_val))
        turn_angles.append(theta)
        smooth_cost += theta ** 2

        if theta > threshold:
            sharp_turn_count += 1
            smooth_cost += params.tight_turn_penalty * (theta - threshold) ** 2

    return smooth_cost, turn_angles, sharp_turn_count


def nearest_obstacle_clearance(point, obstacles):
    if not obstacles:
        return float('inf'), None

    best_d = float('inf')
    best_obs = None
    point = np.asarray(point, dtype=float)
    for obs in obstacles:
        d = np.linalg.norm(point - obs.center) - obs.radius
        if d < best_d:
            best_d = d
            best_obs = obs
    return float(best_d), best_obs


def compute_risk_components(points, obstacles, params, base_offsets):
    rs = 0.0
    rd = 0.0
    rc = 0.0
    rf = 0.0

    clearances = []
    delay_samples = []
    connected_pairs = 0
    total_pairs = 0
    disconnected_count = 0
    formation_infeasible_count = 0
    collision_count = 0

    offset_ids = sorted(base_offsets.keys())
    leader_offset = base_offsets.get(0, np.zeros(2))
    formation_radius = max(np.linalg.norm(base_offsets[uid] - leader_offset) for uid in offset_ids)

    for k in range(len(points) - 1):
        a = points[k]
        b = points[k + 1]
        seg_vec = b - a
        seg_len = np.linalg.norm(seg_vec)
        if seg_len < 1e-8:
            continue

        tangent = seg_vec / seg_len
        heading = np.arctan2(tangent[1], tangent[0])
        samples = segment_sample_points(a, b, params.path_sample_step)

        for q in samples:
            clear, obs_nearest = nearest_obstacle_clearance(q, obstacles)
            clearances.append(clear)

            if clear < 0.0:
                collision_count += 1
                rs += 30.0 + 8.0 * abs(clear)
            elif clear < params.safe_margin:
                gap = (params.safe_margin - clear) / max(params.safe_margin, 1e-6)
                rs += 8.0 * gap + 4.0 * (gap ** 2)
            else:
                rs += np.exp(-clear / max(params.safe_margin * 1.8, 1e-6))

            if obs_nearest is not None:
                v_obs = np.linalg.norm(obs_nearest.velocity)
                if v_obs > 1e-6:
                    rel = q - obs_nearest.center
                    rel_norm = np.linalg.norm(rel)
                    if rel_norm > 1e-8:
                        rel_dir = rel / rel_norm
                        closing_speed = max(0.0, -np.dot(obs_nearest.velocity, rel_dir))
                        clearance_dyn = rel_norm - obs_nearest.radius
                        rd += (closing_speed + 0.1) * np.exp(-max(clearance_dyn, 0.0) / max(params.safe_margin * 2.0, 1e-6))

            inflated_clear = clear - formation_radius
            if inflated_clear < 0.0:
                formation_infeasible_count += 1
                rf += 6.0 + 2.5 * abs(inflated_clear)

            rotated = rotate_offsets(base_offsets, heading)
            uav_positions = []
            leader_rot = rotated.get(0, np.zeros(2))
            for uid in offset_ids:
                rel_offset = rotated[uid] - leader_rot
                uav_positions.append(q + rel_offset)

            n_uav = len(uav_positions)
            neighbor_counts = np.zeros(n_uav, dtype=int)
            for i in range(n_uav):
                for j in range(i + 1, n_uav):
                    d_ij = np.linalg.norm(uav_positions[i] - uav_positions[j])
                    total_pairs += 1
                    if d_ij <= params.comm_range:
                        connected_pairs += 1
                        neighbor_counts[i] += 1
                        neighbor_counts[j] += 1

                        delay_ij = params.comm_delay_base + params.comm_delay_dist_gain * d_ij
                        delay_samples.append(delay_ij)
                        delay_risk = (delay_ij - params.comm_delay_base) / max(params.comm_delay_base, 1e-6)
                        rc += 0.35 * delay_risk

                        link_quality = np.exp(- (d_ij / max(params.comm_range, 1e-6)) ** 2)
                        rc += (1.0 - link_quality)

                        near_threshold = params.comm_ideal_dist * 0.60
                        if d_ij < near_threshold:
                            rc += params.comm_interference_gain * (near_threshold - d_ij) / max(params.comm_ideal_dist, 1e-6)
                    else:
                        disconnected_count += 1
                        rc += 3.0 + 2.0 * (d_ij - params.comm_range) / max(params.comm_range, 1e-6)
                        delay_samples.append(params.comm_delay_base + params.comm_delay_dist_gain * params.comm_range * 1.5)

            for degree in neighbor_counts:
                if degree > params.comm_density_threshold:
                    rc += 0.4 * (degree - params.comm_density_threshold) ** 2

    return {
        'rs': rs,
        'rd': rd,
        'rc': rc,
        'rf': rf,
        'clearances': clearances,
        'delay_samples': delay_samples,
        'connected_pairs': connected_pairs,
        'total_pairs': total_pairs,
        'disconnected_count': disconnected_count,
        'formation_infeasible_count': formation_infeasible_count,
        'collision_count': collision_count
    }


def compute_reliability_cost(turn_angles, clearances, delay_samples, connected_pairs, total_pairs, params):
    if turn_angles:
        heading_stability = 1.0 / (1.0 + np.std(turn_angles))
    else:
        heading_stability = 1.0

    if clearances:
        clear_arr = np.asarray(clearances, dtype=float)
        clear_nonneg = np.clip(clear_arr, 0.0, None)
        clearance_stability = 1.0 / (1.0 + np.std(clear_nonneg) / max(params.safe_margin, 1e-6))
    else:
        clearance_stability = 1.0

    if delay_samples:
        delay_arr = np.asarray(delay_samples, dtype=float)
        delay_stability = 1.0 / (1.0 + np.std(delay_arr) / max(params.comm_delay_base, 1e-6))
    else:
        delay_stability = 1.0

    link_ratio = connected_pairs / max(total_pairs, 1)

    reliability_score = np.clip(
        0.30 * heading_stability
        + 0.30 * clearance_stability
        + 0.20 * delay_stability
        + 0.20 * link_ratio,
        0.0,
        1.0
    )

    return float(1.0 - reliability_score), float(reliability_score)


def compute_feasibility_cost(min_clearance, collision_count, disconnected_count, total_pairs, formation_infeasible_count, sharp_turn_count, params):
    f_cost = 0.0

    if collision_count > 0:
        f_cost += 80.0 + 10.0 * collision_count

    if min_clearance < 0.0:
        f_cost += 50.0 + 5.0 * abs(min_clearance)
    elif min_clearance < 0.5 * params.safe_margin:
        f_cost += 8.0 * (0.5 * params.safe_margin - min_clearance) / max(params.safe_margin, 1e-6)

    if formation_infeasible_count > 0:
        f_cost += 10.0 + 1.5 * formation_infeasible_count

    dis_ratio = disconnected_count / max(total_pairs, 1)
    f_cost += 25.0 * dis_ratio
    f_cost += 0.8 * sharp_turn_count

    return float(f_cost)


def calculate_path_fitness(path_waypoints, start_pos, target_pos, obstacles, params, base_offsets=None):
    if base_offsets is None:
        base_offsets = default_base_offsets()

    pts = np.vstack([np.asarray(start_pos, dtype=float), np.asarray(path_waypoints, dtype=float), np.asarray(target_pos, dtype=float)])

    L = path_length_cost(pts)
    S, turn_angles, sharp_turn_count = path_smoothness_cost(pts, params)

    risk_info = compute_risk_components(pts, obstacles, params, base_offsets)
    Rs = params.w_rs * risk_info['rs']
    Rd = params.w_rd * risk_info['rd']
    Rc = params.w_rc * risk_info['rc']
    Rf = params.w_rf * (risk_info['rf'] + 0.6 * sharp_turn_count)
    R = Rs + Rd + Rc + Rf

    W, reliability_score = compute_reliability_cost(
        turn_angles,
        risk_info['clearances'],
        risk_info['delay_samples'],
        risk_info['connected_pairs'],
        risk_info['total_pairs'],
        params
    )

    min_clearance = float(np.min(risk_info['clearances'])) if risk_info['clearances'] else float('inf')
    F = compute_feasibility_cost(
        min_clearance,
        risk_info['collision_count'],
        risk_info['disconnected_count'],
        risk_info['total_pairs'],
        risk_info['formation_infeasible_count'],
        sharp_turn_count,
        params
    )

    len_ref = max(params.len_ref, np.linalg.norm(np.asarray(target_pos, dtype=float) - np.asarray(start_pos, dtype=float)), 1.0)
    smooth_ref = max(params.smooth_ref, len(pts) - 2, 1.0)
    risk_ref = max(params.risk_ref, len(pts), 1.0)
    reliability_ref = max(params.reliability_ref, 1.0)
    feasibility_ref = max(params.feasibility_ref, 1.0)

    L_n = L / len_ref
    S_n = S / smooth_ref
    R_n = R / risk_ref
    W_n = W / reliability_ref
    F_n = F / feasibility_ref

    J = (
        params.alpha * L_n
        + params.beta * S_n
        + params.gamma * R_n
        + params.mu * W_n
        + params.lambda_f * F_n
    )

    details = {
        'J': float(J),
        'L': float(L),
        'S': float(S),
        'R': float(R),
        'W': float(W),
        'F': float(F),
        'Rs': float(Rs),
        'Rd': float(Rd),
        'Rc': float(Rc),
        'Rf': float(Rf),
        'L_n': float(L_n),
        'S_n': float(S_n),
        'R_n': float(R_n),
        'W_n': float(W_n),
        'F_n': float(F_n),
        'reliability_score': float(reliability_score),
        'min_clearance': min_clearance,
        'collision_count': int(risk_info['collision_count'])
    }
    return float(J), details


def aco_global_route_adjustment(start_pos, target_pos, obstacles, params, n_ants=100, iters=50, n_waypoints=20, archive_size=20, base_offsets=None):
    """
    基于连续域蚁群算法 (ACOR) 的全局路径规划：输出起始点到目标点之间的 N 个空间航点
    """
    if not obstacles:
        xs = np.linspace(start_pos[0], target_pos[0], n_waypoints + 2)[1:-1]
        ys = np.linspace(start_pos[1], target_pos[1], n_waypoints + 2)[1:-1]
        return np.column_stack((xs, ys))

    if base_offsets is None:
        base_offsets = default_base_offsets()

    def evaluate(waypoints):
        fitness, _ = calculate_path_fitness(waypoints, start_pos, target_pos, obstacles, params, base_offsets)
        return fitness

    # ==========================
    # ACOR: 初始化并构建信息素解库
    # ==========================
    archive = []
    
    # 用带噪声的直线插值初始化解库
    for _ in range(archive_size * 2): # 初始多采几个选最好的
        waypoints = np.zeros((n_waypoints, 2))
        for j in range(n_waypoints):
            t = (j + 1) / (n_waypoints + 1)
            base_pt = start_pos * (1 - t) + target_pos * t
            waypoints[j] = base_pt + np.random.normal(0, 50, size=2)
        cost = evaluate(waypoints)
        archive.append((cost, waypoints))
        
    # 保留最佳的 archive_size 个解
    archive.sort(key=lambda x: x[0])
    archive = archive[:archive_size]

    # ACOR 权重概率分配参数
    q = 0.1
    weights = np.array([1.0 / (q * archive_size * np.sqrt(2 * np.pi)) * 
                        np.exp(-((i - 1)**2) / (2 * (q * archive_size)**2)) for i in range(1, archive_size + 1)])
    probs = weights / np.sum(weights)

    # 蚂蚁搜寻蒸发率/探测步长
    xi = 0.85

    for t in range(iters):
        new_solutions = []
        for _ in range(n_ants):
            # 1. 依照权重概率选择一只向导蚂蚁（选择高斯核中心）
            idx = np.random.choice(archive_size, p=probs)
            guide_waypoints = archive[idx][1]
            
            # 2. 计算此高斯核的标准差（反映其余解到它的平均距离，体现信息素浓度与发散度）
            sigma = np.zeros((n_waypoints, 2))
            for j in range(archive_size):
                sigma += np.abs(archive[j][1] - guide_waypoints)
            sigma = xi * (sigma / (archive_size - 1)) + 1e-4 # 防止完全收敛带来的除零/零方差
            
            # 3. 采样生成新蚂蚁路径
            new_waypoints = guide_waypoints + np.random.normal(0, sigma)
            cost = evaluate(new_waypoints)
            new_solutions.append((cost, new_waypoints))
            
        # 并入档案库并只保留最好的解
        archive.extend(new_solutions)
        archive.sort(key=lambda x: x[0])
        archive = archive[:archive_size]
        print("当前轮次：", t)
        print(f"当前最佳成本: {archive[0][0]:.4f}")

    # 返回成本最低的最优全局航点路径
    return archive[0][1]

def calculate_control(uavs, current_time, params, base_offsets, obstacles, current_target, is_final_target=False):
    num_uavs = len(uavs)

    leader_pos = uavs[0].state[0:2]

    if not is_final_target and np.linalg.norm(leader_pos - current_target) < 30.0:
        return np.ones(1)
        
    # 引导整体向目标点前进的参考引力场速度
    v_ref, heading, dv = get_point_to_point_command(leader_pos, current_target, params)

    heading_adj = heading
    base_speed = np.linalg.norm(v_ref)
    
    if base_speed < 0.1: # 到达目标点，停止
        return [np.zeros(2) for _ in range(num_uavs)]

    adjusted_speed = np.clip(base_speed, 0.0, params.v_max * 0.95)
    v_ref = np.array([adjusted_speed * np.cos(heading_adj), adjusted_speed * np.sin(heading_adj)])
    
    current_desired_offsets = rotate_offsets(base_offsets, heading_adj)
    
    adj_matrix = np.zeros((num_uavs, num_uavs))
    for i in range(num_uavs):
        adj_matrix[i, (i+1)%num_uavs] = 1
        adj_matrix[(i+1)%num_uavs, i] = 1
        
    delay = 0.05 
    controls = []
    
    for i, uav_i in enumerate(uavs): 
        xi, yi, vxi, vyi = uav_i.state
        
        # 1. 基础一致性控制力 (Consensus)
        u_consensus = np.array([0.0, 0.0])
        neighbors = np.where(adj_matrix[i] == 1)[0]
        
        state_i_d = uav_i.get_delayed_state(current_time, delay)
        pos_i_d = state_i_d[0:2] 
        vel_i_d = state_i_d[2:4] 
        
        for j in neighbors:
            uav_j = uavs[j]
            state_j_d = uav_j.get_delayed_state(current_time, delay)
            pos_j_d = state_j_d[0:2] 
            vel_j_d = state_j_d[2:4] 
            
            r_ji = current_desired_offsets[j] - current_desired_offsets[i]
            pos_err = (pos_j_d - pos_i_d) - r_ji 
            vel_err = vel_j_d - vel_i_d       
            u_consensus += params.k1 * pos_err + 2/params.k2 * vel_err
            
        # 1.5 针对当前速度方向的前视安全距离计算减速因子
        clearance_ahead = predict_clearance(pos_i_d, np.array([vxi, vyi]), obstacles, params, horizon=params.horizon, steps=params.steps)
        slow_threshold = params.safe_margin * 2.5
        slow_factor = np.clip(clearance_ahead / slow_threshold, 0.2, 1.0)
        v_ref_scaled = v_ref * slow_factor

        # 2. 导航与引力项 (APF 的目标导向力)
        # 直接让无人机朝向基于APF势场拉动的期望速度 (去除了耗时的局部PSO/ACO计算)
        u_nav = dv - params.k3 * (np.array([vxi, vyi]) - v_ref_scaled)

        # 3. 障碍物排斥项 (APF 的避障斥力)
        u_avoid = obstacle_repulsion(pos_i_d, np.array([vxi, vyi]), obstacles, params)
        
        # 综合期望加速度
        acc_cmd = u_consensus + u_nav + u_avoid
        
        # 4. 动力学限制
        v_next = np.array([vxi, vyi]) + acc_cmd * params.dt
        v_norm = np.linalg.norm(v_next)
        if v_norm > params.v_max:
            scale = params.v_max / v_norm
            acc_cmd *= scale 
            
        a_norm = np.linalg.norm(acc_cmd)
        if a_norm > params.a_max:
            acc_cmd = acc_cmd / a_norm * params.a_max
            
        controls.append(acc_cmd)
        
    return controls

# ===========================
# 3. 主程序
# ===========================

def run_point_to_point_formation():
    params = UAVParams()

    base_offsets = {
        0: np.array([0, 0]),
        1: np.array([-20, 20]),   
        2: np.array([-20, -20]),  
        3: np.array([-40, 40]),   
        4: np.array([-40, -40])   
    }

    start_pos = np.array([0.0, 0.0])
    target_pos = np.array([1000.0, 1000.0])

    obstacles = []
    for i in range(1, 13):
        progress = i / 13.0
        base_x = 1000.0 * progress
        base_y = 1000.0 * progress

        offset = 120.0 * (1 if i % 2 == 0 else -1)
        center_x = base_x - offset
        center_y = base_y + offset

        obstacles.append(Obstacle(center=(center_x, center_y), radius=35, velocity=None))

    np.random.seed(42)
    attempts = 0
    num_extra = 8
    while num_extra > 0 and attempts < 1000:
        attempts += 1
        cx = np.random.uniform(100, 900)
        cy = np.random.uniform(100, 900)
        
        if np.linalg.norm(np.array([cx, cy]) - start_pos) < 150: continue
        if np.linalg.norm(np.array([cx, cy]) - target_pos) < 150: continue
            
        too_close = False
        for obs in obstacles:
            if np.linalg.norm(obs.center - np.array([cx, cy])) < 130.0:
                too_close = True
                break
        
        if not too_close:
            obstacles.append(Obstacle(center=(cx, cy), radius=35, velocity=None))
            num_extra -= 1
    obstacles.append(Obstacle(center=(500, 500), radius=35, velocity=None))
    
    print("正在执行全局 连续蚁群算法 (ACOR) 路径规划...")
    global_waypoints = aco_global_route_adjustment(
        start_pos,
        target_pos,
        obstacles,
        params,
        n_ants=500,
        iters=500,
        n_waypoints=20,
        base_offsets=base_offsets
    )
    
    global_waypoints = np.vstack([global_waypoints, target_pos])

    current_waypoint_idx = 0
    current_target = global_waypoints[current_waypoint_idx]
    prev_target = start_pos

    uavs = []
    direction = current_target - start_pos
    adj_heading = np.arctan2(direction[1], direction[0])
    adj_speed = 25.0
    start_vel = np.array([adj_speed * np.cos(adj_heading), adj_speed * np.sin(adj_heading)])

    initial_offsets = rotate_offsets(base_offsets, adj_heading)
    
    for i in range(5):
        pos_init = start_pos + initial_offsets[i]
        state = [pos_init[0], pos_init[1], start_vel[0], start_vel[1]]
        uavs.append(UAV(i, state, params))

    total_time = 100.0
    times = np.arange(0, total_time, params.dt)

    trajectories = [ {'x': [], 'y': []} for _ in range(5) ]
    obs_pos_history = [ [] for _ in range(len(obstacles)) ]

    collision_threshold = 2.0
    min_dist_overall = float('inf')
    collision_occurred = False
    reached_target = False
    flight_time = 0.0

    csv_filename = 'uav_states_aco_apf.csv'
    print(f"开始仿真并记录数据到 {csv_filename} (混合架构：Global ACOR + Local APF)...")

    with open(csv_filename, mode='w', newline='') as f:
        writer = csv.writer(f)
        header = ['Time(s)']
        for i in range(5):
            header.extend([f'UAV{i}_X', f'UAV{i}_Y', f'UAV{i}_VX', f'UAV{i}_VY'])
        for i in range(5):
            for j in range(i + 1, 5):
                header.append(f'Dist_{i}_{j}')
        writer.writerow(header)

        for t in times:
            leader_dist = np.linalg.norm(uavs[0].state[0:2] - target_pos)
            if leader_dist < 2.0:
                print(f"目标点已到达！时间: {t:.2f}s")
                reached_target = True
                flight_time = t
                break

            for i, obs in enumerate(obstacles):
                obs.update(params.dt)
                obs_pos_history[i].append(obs.center.copy())

            leader_pos = uavs[0].state[0:2]
            is_final = (current_waypoint_idx == len(global_waypoints) - 1)
            
            if not is_final:
                vec_path = current_target - prev_target
                vec_uav = leader_pos - current_target
                if np.linalg.norm(vec_uav) < 40.0 or np.dot(vec_path, vec_uav) > 0:
                    prev_target = current_target
                    current_waypoint_idx += 1
                    current_target = global_waypoints[current_waypoint_idx]
                    is_final = (current_waypoint_idx == len(global_waypoints) - 1)

            acc_cmds = calculate_control(uavs, t, params, base_offsets, obstacles, current_target, is_final)
            if isinstance(acc_cmds, np.ndarray) and acc_cmds.shape == (1,) and acc_cmds[0] == 1.0:
                if current_waypoint_idx < len(global_waypoints) - 1:
                    prev_target = current_target
                    current_waypoint_idx += 1
                    current_target = global_waypoints[current_waypoint_idx]
                    is_final = (current_waypoint_idx == len(global_waypoints) - 1)
                acc_cmds = calculate_control(uavs, t, params, base_offsets, obstacles, current_target, is_final)
            
            row = [round(t, 2)]
            current_states = []

            for i, uav in enumerate(uavs):
                uav.update_dynamics(acc_cmds[i])
                uav.store_state(t)

                trajectories[i]['x'].append(uav.state[0])
                trajectories[i]['y'].append(uav.state[1])

                s = uav.state
                current_states.append(s)
                row.extend([round(s[0], 4), round(s[1], 4), round(s[2], 4), round(s[3], 4)])

            for i in range(5):
                for j in range(i + 1, 5):
                    pos_i = current_states[i][0:2]
                    pos_j = current_states[j][0:2]
                    dist = np.linalg.norm(pos_i - pos_j)
                    row.append(round(dist, 4))
                    
                    if dist < min_dist_overall:
                        min_dist_overall = dist
                    
                    if dist < collision_threshold:
                        if not collision_occurred:
                            print(f"!!! 警告: 在 {t:.2f}s 检测到碰撞风险! UAV {i} 与 UAV {j} 间距: {dist:.4f}m")
                        collision_occurred = True

            writer.writerow(row)
            flight_time = t

    print(f"仿真结束。")
    if reached_target:
        print(f"飞行时间(到达目标): {flight_time:.2f} s")
    else:
        print(f"飞行时间(未到达目标，已仿真): {flight_time:.2f} s")
    print(f"--- 碰撞检测总结 ---")
    print(f"全过程最小无人机间距: {min_dist_overall:.4f} m")
    if collision_occurred:
        print(f"结论: 仿真过程中发生了碰撞。")
    else:
        print(f"结论: 仿真过程中未发生碰撞。")
    print(f"正在准备动画...")

    fig, ax = plt.subplots(figsize=(10, 10))
    colors = ['r', 'g', 'b', 'orange', 'purple']
    labels = ['Leader', 'UAV 1', 'UAV 2', 'UAV 3', 'UAV 4']
    
    uav_lines = [ax.plot([], [], color=colors[i], linewidth=1, alpha=0.6, label=labels[i])[0] for i in range(5)]
    uav_points = [ax.plot([], [], marker='^' if i == 0 else 'o', color=colors[i], markersize=8 if i==0 else 5)[0] for i in range(5)]

    obs_patches = []
    obs_safe_patches = []
    for obs in obstacles:
        safe_c = plt.Circle(obs.center, obs.radius + params.safe_margin, color='gray', alpha=0.1, linestyle='--')
        body_c = plt.Circle(obs.center, obs.radius, color='blue', alpha=0.3)
        ax.add_patch(safe_c)
        ax.add_patch(body_c)
        obs_safe_patches.append(safe_c)
        obs_patches.append(body_c)
    
    formation_line, = ax.plot([], [], 'k--', linewidth=1, alpha=0.8)
    time_text = ax.text(0.02, 0.95, '', transform=ax.transAxes, fontsize=12, verticalalignment='top', bbox=dict(boxstyle='round', facecolor='white', alpha=0.5))

    ax.plot(start_pos[0], start_pos[1], 'kx', markersize=10, label='Start')
    ax.plot(target_pos[0], target_pos[1], 'r*', markersize=15, label='Target')
    
    ax.plot(global_waypoints[:, 0], global_waypoints[:, 1], 'ko--', linewidth=1.5, alpha=0.5, label='Global Route (ACOR)')

    all_x = [x for traj in trajectories for x in traj['x']]
    all_y = [y for traj in trajectories for y in traj['y']]
    ax.set_xlim(min(all_x) - 100, max(all_x) + 100)
    ax.set_ylim(min(all_y) - 100, max(all_y) + 100)
    ax.set_aspect('equal')
    ax.grid(True)
    ax.legend(loc='upper right')
    ax.set_title('Multi-UAV Formation (Global ACOR + Local APF)')
    ax.set_xlabel('X (m)')
    ax.set_ylabel('Y (m)')

    step = 4
    num_frames = len(trajectories[0]['x'])
    frames_idx = range(0, num_frames, step)

    def update(frame_idx):
        for i in range(5):
            uav_lines[i].set_data(trajectories[i]['x'][:frame_idx+1], trajectories[i]['y'][:frame_idx+1])
            uav_points[i].set_data([trajectories[i]['x'][frame_idx]], [trajectories[i]['y'][frame_idx]])

        for i in range(len(obstacles)):
            pos = obs_pos_history[i][frame_idx]
            obs_patches[i].center = pos
            obs_safe_patches[i].center = pos
        
        order = [3, 1, 0, 2, 4, 3]
        fx = [trajectories[i]['x'][frame_idx] for i in order]
        fy = [trajectories[i]['y'][frame_idx] for i in order]
        formation_line.set_data(fx, fy)

        current_time = times[frame_idx]
        time_text.set_text(f'Time: {current_time:.1f} s')

        return uav_lines + uav_points + [formation_line, time_text] + obs_patches + obs_safe_patches

    print("\n正在生成动画，请稍候...")
    ani = FuncAnimation(fig, update, frames=frames_idx, interval=50, blit=True)

    gif_name = 'uav_formation_p2p_aco_apf_static.gif'
    print(f"正在保存为 GIF 动画: {gif_name}...")
    try:
        ani.save(gif_name, writer='pillow', fps=20)
        print(f"✓ 动画已保存为 {gif_name}")
    except Exception as e:
        print(f"保存失败: {e}")

    plt.show()
    print("\n动画播放完毕。")

if __name__ == "__main__":
    run_point_to_point_formation()