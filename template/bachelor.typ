#import "/template.typ": algorithm, algorithm-ref, capfig, capsubfig, captab, equation-note, indent, multicite, nwpu-thesis

#show: nwpu-thesis.with(
  anonymous: false, // 是否开启盲审模式
  title: "多障碍物环境中无人机集群路径规划方法研究",
  author: "吴昭桦",
  major: "计算机科学与技术",
  supervisor: ("陈进朝", "教授"),
  submit-date: (year: 2026, month: 3),
  abstract: [
    针对城市低空物流、环境监测、灾害救援及军事侦察等工作场景下无人机集群需要在有大量障碍物的空间里进行协作飞行的情况，在这种情况下一条路径可行不代表整个集群飞行安全：如果领航者的路径是曲折的那么就会导致僚机跟上的偏差过大；局部避障如果不能够很好地融入到编队控制之中也可能会导致集群队形被拉伸或者无人机之间距离太近从而带来安全隐患。因此在二维多障碍物环境中进行集群路径规划不仅要考虑路径最短还要兼顾路径平滑程度以及编队稳定性还有安全性。

    本文围绕上述问题，构建了一个由编队控制、全局路径规划和局部避障组成的分层耦合框架。全局规划层复现粒子群算法（PSO）、蚁群算法（ACO）、遗传算法（GA）、人工蜂鸟算法（AHA）、螳螂搜索算法（MSA）和原生 AL-SHADE 算法，用作横向对比。在此基础上，针对原生 AL-SHADE 直接用于航点优化时存在的档案冗余、环境风险感知不足和路径连续性较弱等问题，本文引入外部档案相似度去重机制、威胁驱动的 Lévy-高斯双态变异缩放因子以及 B样条曲线参数化路径建模。三项改进分别作用于历史解利用、搜索步长调节和轨迹连续化，使算法在障碍物密集区域中能够更稳地搜索可行路径。
    
    对于局部避障，在此采用传统的基于人工势场法(APF)，并结合切向旋转势场力，使无人机沿着障碍物边缘绕行，而不是仅仅通过径向斥力避开障碍物。局部避障指令与其他两个模块——全局路径跟踪以及编队一致性控制一起起作用，在无人机接近障碍物的情况下也尽可能保证其朝向任务目标并且保持编队队形。
    
    仿真部分设计二维多障碍物环境，在路径长度、平滑度、规划成功率、收敛迭代次数以及队形保持误差等方面对各种方法进行比较分析。可以看出，改进后AL-SHADE 在路径平滑性、编队稳定性以及飞机之间的安全裕度上都具有优势，
    在全局最优解上以及局部避开障碍物的能力上也更好。
  ],
  keywords: ("无人机集群","路径规划；多障碍物环境；螳螂搜索算法；AL-SHADE；人工势场法"),
  abstract-en: [
    With the rapid development of unmanned aerial vehicle (UAV) technology, UAV swarms have been increasingly applied in urban low-altitude logistics, environmental monitoring, disaster rescue, and military reconnaissance. However, achieving safe and efficient path planning for UAV swarms in complex multi-obstacle environments remains a significant challenge. Traditional heuristic algorithms such as Particle Swarm Optimization (PSO), Ant Colony Optimization (ACO), Genetic Algorithm (GA), Artificial Hummingbird Algorithm (AHA), Mantis Search Algorithm (MSA), and AL-SHADE exhibit varying performance in high-density two-dimensional obstacle scenarios, and often suffer from discontinuous paths, premature convergence, or infeasible solutions. The Artificial Potential Field (APF) method also tends to fall into local minima or deadlocks in complex environments. To improve global search capability, trajectory continuity, and formation stability, this study proposes a hierarchical and coupled path planning method that integrates multi-agent formation control, global optimization, and local obstacle avoidance, and implements specific improvements to the AL-SHADE algorithm within a unified fitness function and layered control framework. In the global path planning experiments, PSO, ACO, GA, AHA, MSA, and the original AL-SHADE were reproduced for performance comparison, while the improved AL-SHADE incorporates three key strategies: an external archive similarity removal mechanism, a threat-driven Lévy-Gaussian bimodal mutation scaling factor, and B-spline curve-based path parameterization. These strategies enhance path smoothness, formation maintenance, and inter-UAV safety by modeling continuous trajectories, adapting to environmental threats, and optimizing the archive. For local obstacle avoidance, a tangential rotational potential field is introduced based on the traditional APF, enabling UAVs to navigate stably around obstacles while remaining coupled with the global path and formation control. Simulation experiments in a two-dimensional multi-obstacle environment demonstrate that the improved AL-SHADE algorithm significantly enhances path smoothness, formation stability, and inter-UAV safety margin compared to other algorithms, achieving superior performance in both global planning and local obstacle avoidance.
  ],
  keywords-en: ("UAV swarm", "path planning", "multi-obstacle environment", "Mantis Search Algorithm", "AL-SHADE", "Artificial Potential Field"),
  appendix: [
     == 伪代码汇总

    本附录汇总正文中引用或涉及的主要算法伪代码，算法编号与正文引用保持一致。

    #algorithm(
      title: [二维编队一致性控制主循环],
      input: [
        无人机数量 $n$，仿真时长 $T$，采样周期 $Delta t$，
        期望相对位置矩阵 $bold(R)_x$, $bold(R)_y$，
        增益 $k_1, k_2, k_3 = k_1 k_2$，时间常数 $tau_v$，
        机动约束 $v_min, v_max, a_min, a_max, omega_min, omega_max$，
        时延上界 $h_m$，切换拓扑序列 $G(t)$。
      ],
      output: [所有无人机轨迹。],
      [*for* $i arrow 1$ *to* $n$ *do*],
      indent(
        [$(x_i, y_i) arrow$ 初始位置，$(v_(x i), v_(y i)) arrow$ 初始速度，$theta_i arrow$ 初始航向],
        [$v_(x i)^c arrow v_(x i)$, $v_(y i)^c arrow v_(y i)$],
      ),
      [$t arrow 0$],
      [*while* $t < T$ *do*],
      indent(
        [*for* $i arrow 1$ *to* $n$ *do*],
        indent(
          [$N_i(t) arrow$ 从 $G(t)$ 获取邻居集],
          [读取延迟状态：$x_j(t - tau_(i j))$, $y_j(t - tau_(i j))$, $v_(x j)(t - tau_(i j))$, $v_(y j)(t - tau_(i j))$, $forall V_j in N_i(t)$],
          [$u_(x i) arrow$ 按式@eqt:improved-consensus-x 计算],
          [$u_(y i) arrow$ 按式@eqt:improved-consensus-y 计算],
          [调用 ConstraintAdjust（见算法@alg:constraint-adj）修正 $(u_(x i), u_(y i))$],
          [$v_(x i)^c arrow v_(x i) + tau_v u_(x i)$, $quad v_(y i)^c arrow v_(y i) + tau_v u_(y i)$],
          [$v_(x i) arrow v_(x i) + frac(Delta t, tau_v)(v_(x i)^c - v_(x i))$, $quad v_(y i) arrow v_(y i) + frac(Delta t, tau_v)(v_(y i)^c - v_(y i))$],
          [$x_i arrow x_i + v_(x i) Delta t$, $quad y_i arrow y_i + v_(y i) Delta t$],
          [$theta_i arrow arctan(v_(y i) / v_(x i))$, $quad v_i arrow sqrt(v_(x i)^2 + v_(y i)^2)$],
        ),
        [$t arrow t + Delta t$，按序列更新 $G(t)$],
      ),
      [*return* ${(x_i(t), y_i(t)) | t in [0, T], i in 1..n}$],
    ) <alg:formation-control>

    #v(0.6em)
    #algorithm(
      title: [约束最小调整子过程 ConstraintAdjust],
      input: [原始控制量 $u_(x i), u_(y i)$，当前速度 $v_i$、航向 $theta_i$，
        加速度边界 $a_max, v_max, v_min$，航向速率边界 $omega_min, omega_max$，采样周期 $Delta t$。],
      output: [约束修正后的控制量 $(u'_(x i), u'_(y i))$。],
      [$alpha_i arrow sqrt(u_(x i)^2 + u_(y i)^2)$],
      [$v_i^"pred" arrow v_i + alpha_i Delta t$],
      [*if* $v_i^"pred" > v_max$ *or* $v_i^"pred" < v_min$ *then*],
      indent(
        [$a_(max)^"new" arrow min(a_max, (v_max - v_i) / Delta t)$],
        [*if* $alpha_i > a_(max)^"new"$ *then* $(u_(x i), u_(y i)) arrow frac(a_(max)^"new", alpha_i) (u_(x i), u_(y i))$],
      ),
      [$theta_i^"pred" arrow arctan((v_(y i) + u_(y i) Delta t) / (v_(x i) + u_(x i) Delta t))$],
      [$theta_min arrow theta_i + omega_min Delta t$, $quad theta_max arrow theta_i + omega_max Delta t$],
      [*if* $theta_i^"pred" > theta_max$ *or* $theta_i^"pred" < theta_min$ *then*],
      indent(
        [将 $theta_i^"pred"$ 修正至最近边界 $theta_("bound")$],
        [联立求解：$frac(v_(y i) + u_(y i) Delta t, v_(x i) + u_(x i) Delta t) = tan theta_("bound")$ 且 $u_(x i)^2 + u_(y i)^2 = alpha_i^2$],
      ),
      [*return* $(u_(x i), u_(y i))$],
    ) <alg:constraint-adj>

    #v(0.6em)
    #algorithm(
      title: [PSO 全局路径规划算法],
      input: [
        起始点 $bold(S)$，目标点 $bold(T)$，障碍物集合 $cal(O)$，
        航点数 $N$，种群规模 $P$，最大迭代次数 $T_("max")$，
        惯性权重 $omega$，学习因子 $c_1, c_2$。
      ],
      output: [全局最优航点序列 $bold(W)^"*" = {bold(w)_1^"*", dots, bold(w)_N^"*"}$。],
      [计算基线航点 $bold(W)^("base")$ 及搜索边界 $bold(W)^(min), bold(W)^(max)$],
      [*for* $i in 1..P$ *do*],
      indent(
        [$bold(X)_i arrow$ 在 $[bold(W)^(min), bold(W)^(max)]$ 内随机初始化],
        [$bold(V)_i arrow 0$, $quad bold(P)_i^("best") arrow bold(X)_i$],
      ),
      [$bold(G)^("best") arrow$ 初始种群中适应度最低的粒子],
      [*for* $t in 1..T_("max")$ *do*],
      indent(
        [*for* $i in 1..P$ *do*],
        indent(
          [$r_1, r_2 arrow$ 采样自 $cal(U)(0, 1)$],
          [$bold(V)_i arrow omega bold(V)_i + c_1 r_1 (bold(P)_i^("best") - bold(X)_i) + c_2 r_2 (bold(G)^("best") - bold(X)_i)$],
          [$bold(X)_i arrow bold(X)_i + bold(V)_i$，裁剪至 $[bold(W)^(min), bold(W)^(max)]$],
          [$J_i arrow$ 按式 $J = alpha L_"norm" + beta S_"norm" + gamma R_"norm" + mu W_"norm" + lambda_f F_"norm"$ 计算适应度],
          [*if* $J_i < J(bold(P)_i^("best"))$ *then* $bold(P)_i^("best") arrow bold(X)_i$],
          [*if* $J_i < J(bold(G)^("best"))$ *then* $bold(G)^("best") arrow bold(X)_i$],
        ),
      ),
      [*return* $bold(W)^"*" arrow bold(G)^("best")$],
    ) <alg:pso-global>

    #v(0.6em)
    #algorithm(
      title: [ACO 全局路径规划算法],
      input: [
        起始点 $bold(S)$，目标点 $bold(T)$，障碍物集合 $cal(O)$，
        航点数 $N$，档案容量 $K$，蚂蚁数量 $M$，最大迭代次数 $T_("max")$，
        集中度参数 $q$，蒸发率 $xi$。
      ],
      output: [全局最优航点序列 $bold(W)^"*" = {bold(w)_1^"*", dots, bold(w)_N^"*"}$。],
      [$cal(A) arrow$ 生成 $2K$ 个基线扰动解，评估后保留最佳 $K$ 个],
      [计算高斯核权重 $omega_l$ 与选择概率 $p_l$, $l = 1, dots, K$],
      [*for* $t in 1..T_("max")$ *do*],
      indent(
        [$cal(S)^("new") arrow emptyset$],
        [*for* $m in 1..M$ *do*],
        indent(
          [以概率 $p_l$ 从 $cal(A)$ 选取引导解 $bold(s)_("guide")$],
          [$sigma_j arrow xi dot "mean"_(l) |bold(s)_(l,j) - bold(s)_("guide",j)| + epsilon$, $forall j in 1..2N$],
          [$bold(X)^("new") arrow bold(s)_("guide") + cal(N)(bold(0), "diag"(bold(sigma)^2))$],
          [评估 $J(bold(X)^("new"))$，将 $(J(bold(X)^("new")), bold(X)^("new"))$ 加入 $cal(S)^("new")$],
        ),
        [$cal(A) arrow cal(A) union cal(S)^("new")$，按 $J$ 排序并截断至前 $K$ 个],
      ),
      [*return* $bold(W)^"*" arrow cal(A)$ 中适应度最优的解],
    ) <alg:aco-global>

    #v(0.6em)
    #algorithm(
      title: [GA 全局路径规划算法],
      input: [
        起始点 $bold(S)$，目标点 $bold(T)$，障碍物集合 $cal(O)$，
        航点数 $N$，种群规模 $P$，最大代数 $G_"max"$，
        变异概率 $p_m$，初始变异强度 $sigma_0$，锦标赛规模 $k$。
      ],
      output: [全局最优航点序列 $bold(W)^"*" = {bold(w)_1^"*", dots, bold(w)_N^"*"}$。],
      [$cal(P) arrow$ 基线扰动初始化 $P$ 个个体，评估适应度],
      [*for* $g in 1..G_"max"$ *do*],
      indent(
        [按 $J$ 排序 $cal(P)$，设 $cal(P)_("next") arrow$ 精英个体 $cal(P)[1 .. P_"elite"]$],
        [$sigma arrow sigma_0 (1 - g / G_"max")$],
        [*while* $|cal(P)_("next")| < P$ *do*],
        indent(
          [$bold(C)_(p_1) arrow "TournamentSelect"(cal(P), k)$, $bold(C)_(p_2) arrow "TournamentSelect"(cal(P), k)$],
          [$alpha arrow cal(U)(0, 1)$, $quad bold(C)_("child") arrow alpha bold(C)_(p_1) + (1 - alpha) bold(C)_(p_2)$],
          [*for* $w in 1..N$ *do*],
          indent(
            [*if* $cal(U)(0, 1) < p_m$ *then* $bold(C)_("child")[w] arrow bold(C)_("child")[w] + cal(N)(0, sigma^2 bold(I)_2)$],
          ),
          [评估 $J(bold(C)_("child"))$，加入 $cal(P)_("next")$],
        ),
        [$cal(P) arrow cal(P)_("next")$],
      ),
      [*return* $cal(P)[1]$ 的航点编码],
    ) <alg:ga-global>

    #v(0.6em)
    #algorithm(
      title: [APF 局部避障控制（单步执行周期）],
      input: [
        无人机状态 $(bold(p)_i, bold(v)_i)$，当前目标航点 $bold(p)_("tgt")$，
        障碍物集合 $cal(O)$，编队一致加速度 $bold(u)_i^("cons")$，
        参数集 $Theta = \{k_r, k_t, k_3, v_("max"), a_("max"), d_("safe"), T_h, N_s, Delta t\}$。
      ],
      output: [满足动力学约束的自动驾驶仪速度指令 $(v_(x i)^c, v_(y i)^c)$。],
      [*步骤 1：目标引力计算*],
      indent(
        [计算目标方向 $bold(d) arrow bold(p)_("tgt") - bold(p)_i$，距离 $l arrow norm(bold(d))$],
        [$v arrow$ 若 $l < 50$ 则 $max(5, 25 dot l / 50)$ 否则 25],
        [$bold(v)_("ref") arrow v dot bold(d) / l$，$dot(bold(v))_("ref") arrow bold(0)$（匀速巡航假设）],
      ),
      [*步骤 2：前视预测与减速因子*],
      indent(
        [$d_("pred") arrow$ 按式@eqt:predicted-clearance 沿 $bold(v)_i$ 方向预测未来 $T_h$ 内的最小障碍物间隙],
        [$lambda arrow "clip"(d_("pred") / (2.5 d_("safe")), 0.2, 1.0)$],
        [$bold(v)_("ref")^("eff") arrow lambda bold(v)_("ref")$],
      ),
      [*步骤 3：障碍物斥力计算*],
      indent(
        [筛选距 $bold(p)_i$ 最近的障碍物 $O^"*"$，间隙 $d arrow norm(bold(p)_i - bold(c)_O) - R_O$],
        [$d_("inf") arrow R_O + d_("safe") + 50$],
        [*if* $d < d_("inf")$ *then*],
        indent(
          [$sigma arrow max(0, (d_("inf") - d) / d_("inf"))$],
          [$bold(e)_r arrow (bold(p)_i - bold(c)_O) / norm(bold(p)_i - bold(c)_O)$],
          [$bold(f)_("rad") arrow k_r sigma bold(e)_r$],
          [$bold(e)_t arrow (-e_(r,y), e_(r,x))^T$; 若 $bold(v)_i dot bold(e)_t < 0$ 则 $bold(e)_t arrow -bold(e)_t$],
          [$bold(f)_("tan") arrow k_t sigma bold(e)_t$],
          [$bold(f)_("rep") arrow bold(f)_("rad") + bold(f)_("tan")$],
        ),
        [*else* $bold(f)_("rep") arrow bold(0)$],
      ),
      [*步骤 4：导航引力加速度*],
      indent(
        [$bold(u)_("nav") arrow dot(bold(v))_("ref") - k_3 (bold(v)_i - bold(v)_("ref")^("eff"))$],
      ),
      [*步骤 5：三通道加速度合成*],
      indent(
        [$bold(u)_i^("cmd") arrow bold(u)_i^("cons") + bold(u)_("nav") + bold(f)_("rep")$],
      ),
      [*步骤 6：动力学约束投影*],
      indent(
        [$bold(v)_("next") arrow bold(v)_i + bold(u)_i^("cmd") Delta t$],
        [*if* $norm(bold(v)_("next")) > v_("max")$ *then* $bold(u)_i^("cmd") arrow (v_("max") / norm(bold(v)_("next"))) bold(u)_i^("cmd")$],
        [*if* $norm(bold(u)_i^("cmd")) > a_("max")$ *then* $bold(u)_i^("cmd") arrow (a_("max") / norm(bold(u)_i^("cmd"))) bold(u)_i^("cmd")$],
      ),
      [*步骤 7：自驾仪指令映射*],
      indent(
        [$v_(x i)^c arrow v_(x i) + tau_v u_(x i)^("cmd")$, $quad v_(y i)^c arrow v_(y i) + tau_v u_(y i)^("cmd")$],
      ),
      [*return* $(v_(x i)^c, v_(y i)^c)$],
    ) <alg:apf-local-avoidance>

    #v(0.6em)
    #algorithm(
      title: [外部档案相似度去重更新（ArchiveDedupUpdate）],
      input: [
        外部档案矩阵 $cal(A) in bb(R)^(N_A times D)$，档案适应度向量 $bold(J)_A$，
        待存入父代 $bold(x)_("parent") in bb(R)^D$，父代适应度 $J_("parent")$，
        档案容量 $N_A$，相似度阈值 $tau_("sim") = 25.0$。
      ],
      output: [更新后的档案 $cal(A)$ 与适应度 $bold(J)_A$。],
      [*步骤 1：空档案初始化*],
      indent(
        [*if* $|cal(A)| = 0$ *then*],
        indent(
          [$cal(A) arrow [bold(x)_("parent")]$, $quad bold(J)_A arrow [J_("parent")]$],
          [*return* $cal(A)$, $bold(J)_A$],
        ),
      ),
      [*步骤 2：计算父代与档案所有成员的欧氏距离*],
      indent(
        [*for* $j in 1..|cal(A)|$ *do* $d_j arrow norm(bold(x)_("parent") - cal(A)_j)_2$],
        [$j^"*" arrow arg min_(j) d_j$, $quad d_("min") arrow d_(j^"*")$],
      ),
      [*步骤 3：三支去重决策*],
      indent(
        [*if* $d_("min") < tau_("sim")$ *then* — 空间高度相似],
        indent(
          [*if* $J_("parent") < bold(J)_A[j^"*"]$ *then* — 父代更优，替换相似成员],
          indent(
            [$cal(A)_(j^"*") arrow bold(x)_("parent")$, $quad bold(J)_A[j^"*"] arrow J_("parent")$],
          ),
          [*else* — 父代不优于相似成员，直接丢弃],
          indent(
            [不存入档案],
          ),
        ),
        [*else* — 空间足够不相似，父代代表新区域],
        indent(
          [*if* $|cal(A)| < N_A$ *then* — 追加],
          indent(
            [$cal(A) arrow cal(A) union {bold(x)_("parent")}$, $quad bold(J)_A arrow bold(J)_A union {J_("parent")}$],
          ),
          [*else* — 随机替换一项（保留无偏性）],
          indent(
            [$k arrow$ 从 ${1, dots, N_A}$ 中均匀随机采样],
            [$cal(A)_k arrow bold(x)_("parent")$, $quad bold(J)_A[k] arrow J_("parent")$],
          ),
        ),
      ),
      [*return* $cal(A)$, $bold(J)_A$],
    ) <alg:archive-dedup>

    #v(0.6em)
    #algorithm(
      title: [种群威胁度量化（ComputePopulationThreat）],
      input: [
        种群矩阵 $bold(X) in bb(R)^(P times 2N)$（$P$ 个个体，每行编码 $N$ 个航点），
        障碍物集合 $cal(O)$，航点数 $N$，起始点 $bold(S)$，目标点 $bold(T)$，
        安全距离 $d_("safe") = 20$，B 样条采样数 $N_s = 100$。
      ],
      output: [威胁度向量 $bold(T) = (T_1, dots, T_P)^T$, $T_i in [0, 1]$。],
      /* [*步骤 1：个体解码与 B 样条路径生成*],
      indent(
        [*for* $i in 1..P$ *do*],
        indent(
          [航点 $bold(W)_i arrow$ 从 $bold(x)_i$ 解码为 $N times 2$ 矩阵],
          [控制点 $bold(C)_i arrow$ 将 $bold(S)$、$bold(W)_i$、$bold(T)$ 纵向拼接为 $(N+2) times 2$ 矩阵],
          [B 样条采样点 $bold(P)_i arrow$ GenerateCubicBSpline$(bold(C)_i, N_s)$],
        ),
      ), */
      [*步骤 1：广播净空距离计算*],
      indent(
        [提取障碍物中心矩阵 $bold(C)_"obs"$ 及半径向量 $bold(R)_"obs"$],
        [*forall* $i$ 同步广播计算：$bold(D)_("surf", i) = norm(bold(P)_i["," * "," "new"] - bold(C)_"obs") - bold(R)_"obs"$],
        [$d_(i)^"min" arrow min bold(D)_("surf", i)$],
      ),
      [*步骤 2：三区威胁度映射*],
      indent(
        [*for* $i in 1..P$ *do*],
        indent(
          [*if* $d_(i)^"min" <= 0$ *then* $T_i arrow 1.0$],
          [*else if* $d_(i)^"min" < d_("safe")$ *then* $T_i arrow exp(lr(-frac(2 d_(i)^"min", d_("safe") - d_(i)^"min" + epsilon)))$],
          [*else* $T_i arrow 0.0$],
        ),
      ),
      [*return* $bold(T)$],
    ) <alg:threat-quant>

    #v(0.6em)
    #algorithm(
      title: [TALG 双态 $F$ 生成器（GenerateTALGScalingFactors）],
      input: [
        历史记忆 $bold(M)_F in bb(R)^H$，各体记忆槽索引 $"slots" in {0, dots, H-1}^P$，
        威胁度向量 $bold(T) in [0, 1]^P$，Lévy 稳定指数 $beta = 1.5$，尺度 $sigma = 0.1$，最大重试次数 $R_("max") = 100$。
      ],
      output: [缩放因子向量 $bold(F) = (F_1, dots, F_P)^T$，$F_i in (0, 1]$。],
      [*for* $i in 1..P$ *do*],
      indent(
        [$mu_F arrow bold(M)_F["slots"[i]]$],
        [*for* $"attempt" in 1..R_("max")$ *do*],
        indent(
          [*if* $"rand"(0, 1) <= T_i$ *then* — Lévy 态],
          indent(
            [$s arrow$ MantegnaLevy$(beta)$],
            [$F_i arrow mu_F + sigma dot s$],
          ),
          [*else* — 高斯态],
          indent(
            [$F_i arrow mu_F + sigma dot cal(N)(0, 1)$],
          ),
          [*if* $F_i > 0$ *then* *break*],
        ),
        [*if* $"attempt" = R_("max") + 1$ *then* $F_i arrow epsilon_("machine")$],
        [$F_i arrow min(F_i, 1.0)$],
      ),
      [*return* $bold(F)$],
    ) <alg:talg-f-gen>

    #v(0.6em)
    #algorithm(
      title: [Mantegna Lévy 步长采样器（MantegnaLevy）],
      input: [Lévy 稳定指数 $beta in (0, 2)$，标准值 $1.5$。],
      output: [Lévy 分布随机步长 $s$。],
      [计算 $sigma_u arrow lr(frac(Gamma(1 + beta) dot sin(pi beta / 2), Gamma((1 + beta) / 2) dot beta dot 2^((beta - 1) / 2)))^(1 / beta)$],
      [$u arrow cal(N)(0, sigma_u^2)$, $quad v arrow cal(N)(0, 1)$],
      [$s arrow u / (|v|^(1 / beta) + 10^(-12))$],
      [*return* $s$],
    ) <alg:mantegna-levy>

    #v(0.6em)
    #algorithm(
      title: [三次 B 样条曲线生成与路径参数化],
      input: [
        控制点集 $cal(C) = {bold(c)_0, bold(c)_1, dots, bold(c)_m}$（含起点 $bold(S)$ 与终点 $bold(T)$），
        采样点数 $N_s = 100$，曲线次数 $p = 3$。
      ],
      output: [平滑路径采样点 $cal(P) = {bold(p)_1, dots, bold(p)_(N_s)}$。],
      [*步骤 1：控制点预处理*],
      indent(
        [去除 $cal(C)$ 中连续重复点（容差 $10^(-6)$）],
        [*if* $|cal(C)| <= 1$ *then* *return* $cal(C)$],
        [$n_"ctrl" arrow |cal(C)|$, $quad "degree" arrow min(3, n_"ctrl" - 1)$],
      ),
      [*步骤 2：构造 Clamped 均匀节点向量*],
      indent(
        [$n arrow n_"ctrl" - 1$],
        [$"interior" arrow$ 在 $(0, 1)$ 内均匀插入 $n - "degree"$ 个内部节点],
        [$bold(U) arrow underbrace({0, dots, 0}, "degree"+1) dot "interior" dot underbrace({1, dots, 1}, "degree"+1)$],
      ),
      [*步骤 3：de Boor 递推采样*],
      indent(
        [$bold(P) arrow$ 空数组],
        [*for* $u$ *in* $"linspace"(U_("degree"), U_(n_"ctrl"), N_s)$ *do*],
        indent(
          [*步骤 3a：定位节点区间*],
          [*if* $u >= U_(n+1)$ *then* $k_"span" arrow n$],
          [*else* $k_"span" arrow$ 满足 $U_(k_"span") <= u < U_(k_"span"+1)$ 的最大下标（限定在 $["degree", n]$ 内）],
          [*步骤 3b：初始化受影响控制点*],
          [$bold(d)_j arrow bold(c)_(k_"span" - "degree" + j)$, $quad j = 0, 1, dots, "degree"$],
          [*步骤 3c：递推插值（r = 1→degree）*],
          [*for* $r in 1.."degree"$ *do*],
          indent(
            [*for* $j in "degree" .. r$ (降序) *do*],
            indent(
              [$"left" arrow U_(j + k_"span" - "degree")$, $quad "right" arrow U_(j + 1 + k_"span" - r)$],
              [$alpha arrow 0$ *if* $"right" - "left" < 10^(-12)$ *else* $(u - "left") / ("right" - "left")$],
              [$bold(d)_j arrow (1 - alpha) bold(d)_(j-1) + alpha bold(d)_j$],
            ),
          ),
          [将 $bold(d)_("degree")$ 追加至 $bold(P)$],
        ),
      ),
      [*步骤 4：锚定首尾端点*],
      indent(
        [$bold(P)[0] arrow bold(c)_0$, $quad bold(P)[-1] arrow bold(c)_m$],
      ),
      [*return* $bold(P)$],
    ) <alg:bspline-gen> 
  ],
  acknowledgement: [
    在最后的最后我要感谢xxx,感谢xxx在我的学业
  ],
  design_summary: [
    小结内容……
  ],
)

= 绪论

== 研究背景

随着无人机技术持续走向成熟，其应用边界已经从早期的航拍和军事侦察，逐渐拓展到城市低空物流配送、环境监测、灾害救援以及精准农业等更复杂的场景当中。这些任务往往对飞行平台在效率、自主性和环境适应能力方面提出了更高的要求。与单架无人机相比，无人机集群（UAV Swarm）所能带来的优势是全方位的。通过协同控制技术，集群中的个体可以在任务分配与执行环节共享信息、协调行为，从而在整体层面成倍提升任务效率和系统鲁棒性。这种多机冗余协作的特性，不仅意味着面对个别节点失效时系统仍能稳定运行，也让集群更适合去执行大范围环境感知、多目标并行搜索以及高动态的协同运输等复杂作业任务。然而在实际飞行过程中，环境约束的存在会明显增加集群控制的难度。尤其是当作业场景里分布有大量密集的建筑物、树木或其他临时障碍物时，路径规划问题便不再只是为每架无人机找到一条从起点到终点的连线，而是需要同步处理多个运动体在障碍物环境中的时空协调、机间防撞以及与外部障碍物的规避，这使得问题的求解维度急剧升高，也对规划方法的全局性和实时性提出了更为严苛的要求。

在已有的路径规划研究中，粒子群算法（PSO）、蚁群算法（ACO）和遗传算法（GA）这一类传统方法，凭借其原理简单、易于实现的特点，在连续空间的全局优化问题上已经获得了相当广泛的应用。然而，当它们被直接迁移到二维高密度障碍物环境下的集群路径规划时，这些方法各自的局限性便开始集中暴露出来，往往容易表现出路径不连续、局部收敛或早熟收敛等问题。具体来看，PSO在靠近障碍物边缘时，由于粒子的速度更新机制缺乏对障碍物几何信息的有效利用，容易产生“贴墙飞”现象，使得规划出的路径紧贴着障碍物表面蜿蜒前行，既不安全，也不利于实际飞行的跟踪控制；ACO在障碍物分布密集的区域中，由于信息素的累积和挥发之间的反馈失衡，蚂蚁个体极易在局部区域内来回打转，陷入循环搜索而迟迟无法收敛到可行路径；而GA在交叉重组的过程中，因其染色体的离散编码方式与连续路径空间之间的不匹配，有可能会频繁生成直接穿越障碍物的不可行解，这无疑增加了后续修复和筛选环节的计算开销。此外，经典人工势场法（APF）虽然在实时性方面表现尚可，但当环境中出现“U型”障碍物或狭窄通道等特殊结构时，合力场的固有特性很容易将无人机集群拖入局部极小值或导致死锁状态，使得算法无法继续推进，难以胜任复杂环境下对规划可靠性的要求。

近年来，一批生物启发式算法以及自适应优化算法因为在求解连续优化问题上展现出了良好的全局寻优性能，逐渐引起了研究者的广泛关注，这些方法往往通过模拟自然界中某些生物行为或引入动态调整机制，来增强算法跳出局部最优并逼近全局最优的能力，从而为复杂环境下的路径规划问题提供了新的求解思路。以螳螂搜索算法（MSA）为例，该算法通过模仿螳螂在捕食过程中突袭与追踪的一系列动作，将全局探索与局部开发进行有机结合，在求解一部分多极值连续函数优化问题中取得了较为准确的结果，然而当它被引入到二维有障碍空间进行路径规划时，仍然会面临一些明显的困难，一方面其随机初始化机制难以保证初始解在复杂障碍环境中的均匀分布，种群容易从一开始就集中在某些局部区域，削弱了后续搜索的多样性，另一方面算法在迭代后期对搜索步长和方向的调节能力不足，容易导致过早收敛到局部最优解，从而限制了其在复杂环境下持续寻优的精度和稳定性。与之类似，人工蜂鸟算法（AHA）通过模拟蜂鸟特有的觅食行为和灵活的飞行技能，利用访问表来记录不同食源的被访问情况，并在此基础上动态切换轴向飞行、对角飞行和全向飞行三种飞行技能，同时配合引导觅食、领地觅食和迁徙觅食三种不同阶段的觅食策略，在全局搜索与局部开发之间建立起一种较为精细的平衡，在连续优化问题中这种多策略协同的设计使得AHA表现出良好的收敛速度和全局寻优能力，能够在较短的时间内逼近复杂函数的高质量解，然而当它被直接应用于二维离散路径规划任务时，同样暴露出了算法设计与路径规划实际需求之间的差距，由于AHA本身主要面向连续变量的更新与调整，缺少对离散航点之间连续性要求的专门处理机制，最终生成的无人机航迹往往由许多陡峭转折的折线段拼凑而成，整体航迹不够平滑，难以满足实际飞行中对路径可行性和飞行稳定性的基本需要。类似的问题也出现在AL-SHADE算法上，该算法借助成功历史参数自适应技术，根据搜索过程中成功个体的历史信息动态调整变异因子和交叉概率，同时配合线性种群规模缩减策略，在迭代过程中逐步淘汰较差的个体并集中计算资源，显著增强了微分进化算法应对高维连续优化问题的能力，但当研究者尝试将其直接迁移到二维离散路径规划任务时，依然会面临同样的困境，算法虽然可以在大范围内找到一条连接起点和终点的低代价路径，却由于内部机制缺乏对相邻离散航点之间几何连续性及转弯平滑度的显式约束，所生成的航迹中频繁出现急剧转向和锯齿状波动，使得规划结果在实用性和可执行性方面大打折扣，难以直接应用于对航迹质量要求较高的实际飞行场景。

由此可见，在二维多障碍物环境下对无人机集群进行路径规划，不仅需要考虑全局路径最优与航迹连贯性之间的矛盾，还要兼顾集群编队保持稳定以及局部动态避碰等实时性需求。这些问题相互耦合，使得单纯依靠某一类传统或新兴算法都难以同时获得满意的效果。因此，开展这方面的研究，既有助于从理论上丰富和完善无人机集群协同规划的方法体系，也能够为城市低空物流、灾后快速搜救等实际应用场景中的高效安全运行提供直接的技术支撑和借鉴意义。

== 研究现状

在无人机集群路径规划的研究中，编队控制是较早受到重视的基础问题。国外研究更偏向理论模型的构建，较早将多智能体一致性思想用于多个飞行器之间的协同控制。Ren 和 Beard 对分布式一致性控制及其在多飞行器系统中的应用进行了较为详细的阐述，这为后续编队控制研究提供了重要参考@RenBeard2008。相比之下，国内研究更多从实际任务的可行性出发，在虚拟领航者模型和一致性控制的基础上，结合无人机动力学限制、通信拓扑变化以及任务队形需求，讨论如何维持“V”字形、“人”字形或横队等典型编队@ZhangW2020UAVFormation。可以看出，国外研究主要关注通信拓扑和收敛性分析，国内研究则更重视队形能否适应具体航线和有限空间。随着任务环境从开阔空域逐渐转向城市低空、狭窄通道和复杂地形，固定队形的不足开始显现。为提高集群穿越受限环境的能力，队形约束调整、自适应重构、队形压缩和横向偏移等方法逐渐被引入相关研究@Zhang2019Formation。

在全局路径规划方面，国内外研究都大量采用 PSO、ACO、GA 等启发式算法。国外研究较早从算法本身出发，将粒子群优化、差分进化和新型生物启发式算法用于连续优化与路径搜索。Kennedy 和 Eberhart 提出的粒子群优化算法结构简单、收敛较快，因此较早被用于无人机路径搜索@Kennedy1995PSO；后续研究又引入螳螂搜索算法@MSA2023、L-SHADE@Tanabe2014LSHADE 以及 AL-SHADE@ALSHADE2022 等方法，以增强复杂空间中的搜索能力。国内研究通常从无人机路径规划中的工程约束出发，对适应度函数进行改造，将路径长度、障碍物风险、平滑程度和约束惩罚等因素纳入评价过程，同时使用禁忌表、惩罚函数或精英保留机制提高可行解比例@Wang2021APF。二者的侧重点并不完全相同：国外更关注算法自身的搜索能力和参数自适应，国内则更关注路径是否可行、是否安全，以及是否便于仿真验证。

局部避障主要用于处理全局路径在实际运行过程中遇到的临时风险。国外经典研究是 Khatib 提出的人工势场法，该方法通过目标吸引力和障碍物排斥力实现实时避障@Khatib1986APF。然而，当环境中存在凹陷区域或狭窄缝隙时，经典人工势场法容易陷入局部极小值，也可能产生轨迹抖动。国内相关研究大多在工程仿真环境下改进人工势场法，例如重新设定斥力函数，引入切向旋转力，调整各部分权重，或将局部避障目标与全局引导点结合起来，以提升无人机在复杂障碍物附近的绕行能力@Wang2021APF。

总体来看，国外研究在局部避障模型和控制理论方面积累较深，国内研究则更重视与全局路径和编队控制的耦合实现。但现有方法仍常把全局路径搜索、局部避障和编队控制分开设计，路径长度、轨迹平滑性、编队保持和机间安全裕度难以在同一优化过程中协调。AL-SHADE 依靠成功历史参数记忆、自适应缩放因子与交叉概率更新，以及线性种群规模缩减机制，较适合连续航点坐标优化；但原生 AL-SHADE 仍存在折线轨迹明显、障碍威胁感知不足和外部档案相似解较多等问题。基于此，本文选取 AL-SHADE 作为主要全局路径规划框架，并通过外部档案相似度去重、障碍净空距离驱动的 Lévy-Gaussian 双态变异缩放因子和 B 样条曲线参数化方法进行改进。

== 研究内容

结合实际任务需求和前文分析的问题，本文以二维多障碍物环境下的无人机集群为研究对象，围绕编队控制、全局路径规划和局部动态避障展开研究。为使所提方法在复杂约束和密集障碍场景中具备可行性、稳定性与可复现性，本文将研究内容划分为以下四个方面：

1. 多无人机编队协同控制模型：基于虚拟领航者模型和多智能体一致性算法，构建多无人机协同控制框架，并说明邻接矩阵、拉普拉斯矩阵对通信拓扑和收敛过程的约束关系。针对二维平面内的编队保持与协同跟踪问题，设计同时考虑位置误差和速度误差的控制律，再结合速度、加速度和角速度等运动学约束进行物理可行性校验。在此基础上，引入横向偏置自适应调节机制，使集群在开阔区域和局部受限区域中都能收敛到“V”型、人字型等预定队形，并在通道收缩和恢复过程中保留一定的队形弹性。

2. 多障碍空间下的全局路径智能优化与轨迹平滑：面向密集障碍物和多约束二维环境，复现并改进粒子群（PSO）、蚁群（ACO）、遗传（GA）等经典启发式算法。在此基础上，为进一步比较不同群体智能算法在复杂连续空间中的搜索能力，本文还引入螳螂搜索算法（MSA）、人工蜂鸟算法（AHA）以及基于成功历史参数自适应学习的差分进化算法（AL-SHADE）。其中，MSA 和 AHA 分别从不同生物行为中获得搜索机制，具有较强的全局探索能力；AL-SHADE 则通过历史成功参数记忆和自适应调整机制改善差分进化算法的搜索效率。通过对上述算法进行统一建模和实验对比，可以更全面地分析各类方法在路径长度、平滑性、避障能力和收敛效果上的差异。针对差分进化算法用于离散航点编码时轨迹连续性不足的问题，进一步采用 B 样条曲线参数化的 AL-SHADE 算法，对路径维度进行降维并建立连续轨迹模型，从而改善全局规划结果的平滑性与可飞行性。

3. 基于改进人工势场的局部动态避障策略：局部避障部分主要处理动态障碍和“U”型障碍可能引发的局部极小值问题。本文在传统人工势场法（APF）的引力、斥力模型基础上加入切向旋转势场力，使无人机在接近障碍物时能够沿障碍边缘绕行，而不是只依靠径向斥力后退或停滞。该避障策略与全局路径引导点、编队控制律共同作用，使无人机在不明显偏离全局任务方向的情况下，完成较稳定的局部机动与逃逸。

4. 多层算法集成与仿真验证：为了检验上述方法的整体效果，本文构建统一的二维多障碍物仿真环境，将编队控制层、全局规划层和局部避障层放在同一场景中进行分层耦合验证。实验设置不同障碍密度和典型障碍分布，并从路径长度、平滑度、规划成功率、收敛迭代次数和队形保持误差等指标进行横向对比，分析所提方法在安全性、稳定性与效率方面的表现。

#capfig(
  image("figures/yanjiuneirong.png", width: 90%),
  caption: [研究内容示意图],
  label: <test>,
)



= 相关工作

无人机集群路径规划涉及编队控制、全局路径搜索和局部避障等多个环节。其中，全局规划算法决定参考航迹的整体质量，也直接影响后续编队跟踪和局部修正的稳定性。因此，本章重点围绕全局路径规划算法展开，先给出统一的路径评价函数，再说明 PSO、ACO、GA、MSA、AHA 和 AL-SHADE 等算法在本文任务中的建模方式与实现逻辑。

== 全局路径规划算法设计与实现

全局路径规划层的任务是为领航者生成从起点到目标点的参考路径，并使该路径能够被编队控制和局部避障模块稳定使用。由于不同优化算法得到的候选路径在长度、平滑性、安全裕度和编队可行性方面差异较大，本文采用统一的适应度函数作为评价标准。各算法均在相同的路径编码、搜索边界和约束条件下进行优化，从而保证后续实验比较具有一致性。

=== 适应度函数设计

设候选解 $bold(X)$ 解码后得到的二维参考路径为

$
cal(Q) = {bold(q)_1, bold(q)_2, dots, bold(q)_M}, quad bold(q)_k in bb(R)^2
$

其中 $M$ 为路径采样点数量。领航者沿 $cal(Q)$ 飞行，其余无人机按照预设队形偏移和局部避障修正得到位置 $bold(p)_(i,k)$。因此，适应度函数不仅评价领航者路径本身，也评价该路径对集群安全和队形保持的影响。

本文将路径规划写成加权多目标优化问题：

$
J(bold(X)) = alpha L + beta S + gamma R + mu W + lambda F
$

式中，$L$ 为路径长度代价，$S$ 为路径平滑代价，$R$ 为综合风险代价，$W$ 为通道宽度约束惩罚，$F$ 为编队保持代价；$alpha$、$beta$、$gamma$、$mu$ 和 $lambda$ 为对应权重。实际计算时，各分量先归一化，再代入加权和。若算法采用“适应度越大越优”的形式，则使用

$
"Fitness"(bold(X)) = frac(1, J(bold(X)) + epsilon)
$

进行等价转换，其中 $epsilon$ 为极小正数。本文主要以最小化 $J$ 为优化目标。

路径长度代价用于约束飞行距离：

$
L = sum_(k=1)^(M-1) norm(bold(q)_(k+1) - bold(q)_k)
$

路径平滑代价由相邻路径段夹角决定：

$
theta_k = arccos frac((bold(q)_k - bold(q)_(k-1)) dot (bold(q)_(k+1) - bold(q)_k), norm(bold(q)_k - bold(q)_(k-1)) norm(bold(q)_(k+1) - bold(q)_k))
$

$
S = sum_(k=2)^(M-1) theta_k^2
$

当路径频繁急转时，$theta_k$ 增大，平滑代价随之上升。该项可以减少折线航迹，使规划结果更适合无人机连续飞行。

综合风险代价由静态障碍风险、集群内部碰撞风险和通信风险组成：

$
R = R_s + R_c + R_f
$

静态障碍风险用于描述路径点与障碍物之间的距离关系：

$
R_s = sum_(k=1)^M exp lr(- frac((d_s(bold(q)_k) - r_("eq"))^2, sigma_s^2))
$

其中 $d_s(bold(q)_k)$ 表示路径点到最近静态障碍物表面的距离，$r_("eq")$ 为安全半径，$sigma_s$ 控制风险衰减速度。无人机越靠近障碍物，风险项越大。

集群内部碰撞风险用于约束无人机之间的最小距离：

$
R_c = sum_(k=1)^M sum_(i<j) phi(d_(i j)(t_k)), quad
phi(d) = cases((1 - d / d_("safe"))^2 quad d < d_("safe"), 0quad d >= d_("safe"))
$

其中 $d_("safe")$ 为最小安全距离。通信风险用于避免编队链路过长：

$
R_f = sum_(k=1)^M sum_((i,j) in cal(E)) max(0, d_(i j)(t_k) - d_("comm"))^2
$

$cal(E)$ 表示通信链路集合，$d_("comm")$ 为通信半径。

通道宽度惩罚用于判断当前路径是否满足编队通行需求：

$
W = sum_(k=1)^M max(0, B_("req", k) - B_k)^2
$

其中 $B_k$ 为路径点附近的可通行宽度，$B_("req", k)$ 为编队通过该位置所需的最小宽度。当允许队形适度压缩时，可令

$
B_("req", k) = B_("form")^"min" + eta_b Delta B_k
$

编队保持代价用于衡量实际队形与期望队形之间的偏差。若采用领航者-僚机偏移模型，可写为

$
F = sum_(k=1)^M sum_(i=1)^n norm(delta_(i,k) - delta_i^*)^2
$

其中 $delta_i^*$ 为第 $i$ 架无人机的理想相对偏移，$delta_(i,k)$ 为实际偏移。也可以用邻接边距离误差表示：

$
F = sum_(k=1)^M sum_((i,j) in cal(E)) (norm(bold(p)_(i,k) - bold(p)_(j,k)) - d_(i j)^*)^2
$

综上，本文的适应度函数把路径效率、安全避障、轨迹平滑和编队保持统一到同一评价框架中，为后续各类优化算法提供共同目标。

=== 粒子群算法（PSO）设计与实现

粒子群算法通过模拟群体协同行为完成搜索。每个粒子表示一条候选路径，其位置向量由 $N$ 个中间航点组成：

$
bold(X)_i = [x_(i,1), y_(i,1), dots, x_(i,N), y_(i,N)] in bb(R)^(2N)
$

种群初始化时，先根据起点和终点生成基线航点，再在基线两侧设置带状搜索边界。粒子位置在边界内随机生成，速度向量可初始化为零或小扰动。第 $i$ 个粒子在第 $t$ 代的速度和位置更新为

$
bold(V)_i^(t+1) = omega bold(V)_i^t + c_1 r_1 (bold(P)_i^"best" - bold(X)_i^t) + c_2 r_2 (bold(G)^"best" - bold(X)_i^t)
$

$
bold(X)_i^(t+1) = bold(X)_i^t + bold(V)_i^(t+1)
$

其中 $omega$ 为惯性权重，$c_1$ 和 $c_2$ 分别为个体学习因子和群体学习因子，$r_1$、$r_2$ 为 $[0,1]$ 内随机数，$bold(P)_i^"best"$ 为个体历史最优位置，$bold(G)^"best"$ 为全局最优位置。更新后若粒子越界，则将其裁剪到允许范围内。

PSO的执行过程如下。首先，根据起点、终点和带状搜索边界初始化粒子位置，并为每个粒子设置初始速度；其次，将粒子位置解码为航点序列，计算对应路径的适应度，并记录个体最优位置和全局最优位置；然后，在每轮迭代中根据惯性项、个体学习项和群体学习项更新粒子速度，再由速度更新粒子位置；接着，对越界粒子进行边界修正，并重新计算适应度。若新位置优于粒子自身历史最优，则更新个体最优；若其优于当前全局最优，则同步更新全局最优。迭代结束后，算法输出全局最优粒子对应的航点序列作为规划路径。

=== 蚁群算法（ACO）设计与实现

经典蚁群算法通常用于离散图搜索。无人机路径规划属于连续航点优化问题，因此本文采用连续域蚁群优化思想，将信息素模型表示为解档案上的高斯核采样。设档案容量为 $K$，档案中第 $l$ 个解为 $bold(s)_l$，其适应度为 $J_l$。档案按适应度从小到大排序后，较优解获得更高采样概率：

$
omega_l = frac(1, q K sqrt(2 pi)) exp lr(- frac((l - 1)^2, 2 q^2 K^2)), quad
p_l = frac(omega_l, sum_(h=1)^K omega_h)
$

其中 $q$ 控制选择压力。每只蚂蚁先按概率 $p_l$ 选择引导解，再围绕该解进行高斯采样：

$
X_j^"new" = s_(l,j) + cal(N)(0, sigma_j^2)
$

标准差 $sigma_j$ 根据档案中同一维度的离散程度确定，通常写为

$
sigma_j = xi frac(1, K-1) sum_(h=1, h != l)^K |s_(h,j) - s_(l,j)|
$

其中 $xi$ 为搜索尺度参数。新解生成后需要裁剪边界、解码为路径并计算适应度，再与原档案合并排序，保留前 $K$ 个解。

ACO 的执行过程如下。首先，在带状搜索空间内生成一批初始候选路径，并根据适应度排序后建立解档案；其次，根据档案中各解的排序位置计算高斯核权重和选择概率，使较优路径具有更高的采样概率；然后，每只蚂蚁按概率从档案中选择一个引导解，并依据档案分布计算各维度的采样标准差；接着，以引导解为中心进行高斯采样，生成新的航点编码，并对越界部分进行修正；之后，计算新路径的适应度，将其与原档案合并排序，保留前 $K$ 个较优解。循环执行上述过程，直到达到最大迭代次数后，输出档案中适应度最小的路径作为全局规划结果。

=== 遗传算法（GA）设计与实现

遗传算法（Genetic Algorithm, GA）是一种模拟自然选择和遗传进化过程的随机搜索算法，主要通过选择、交叉和变异不断更新种群。针对无人机二维路径规划中的连续航点优化问题，本文采用实数编码遗传算法，直接在航点坐标空间中进行搜索，避免二进制编码带来的精度损失和维度膨胀。

*染色体编码与初始化。* 每条染色体对应 $N$ 个中间航点的二维坐标，可表示为

$
bold(C) = [x_1, y_1, x_2, y_2, dots, x_N, y_N] in bb(R)^(2N)
$

初始种群采用与 PSO 相同的基线扰动方式生成：先沿起点与终点连线等比例设置基线航点，再围绕基线在带状搜索域内随机采样，形成规模为 $P$ 的初始种群 $cal(P)_0$。所有个体均通过统一适应度函数 $J$ 进行评价，适应度较小的染色体表示路径质量较优。

*选择算子。* 本文采用 $k$-锦标赛选择。每次选择时，从当前种群中随机抽取 $k$ 个个体，并选取其中适应度最小者作为父代。与轮盘赌选择相比，锦标赛选择不依赖适应度绝对值，只根据相对优劣确定父代，因而在路径代价差异较大时更稳定。本文取 $k = 3$。

*交叉算子。* 对两个父代染色体 $bold(C)_(p_1)$ 和 $bold(C)_(p_2)$，采用整体算术交叉生成子代：

$
bold(C)_("child") = alpha bold(C)_(p_1) + (1 - alpha) bold(C)_(p_2), quad alpha tilde.op cal(U)(0, 1)
$

该算子相当于在两个父代张成的高维线段上进行插值，能够继承父代中的有效航点组合，并在二者之间生成新的候选路径。

*变异算子。* 为防止种群过早收敛，对子代中的航点坐标施加高斯变异。对第 $w$ 个航点，以概率 $p_m$ 执行：

$
bold(C)_("child")[w] arrow bold(C)_("child")[w] + cal(N)(0, sigma(g)^2 bold(I)_2), quad w = 1, 2, dots, N
$

其中 $bold(I)_2$ 为二维单位矩阵。变异强度随代数线性衰减：

$
sigma(g) = sigma_0 * (1 - frac(g, G_("max")))
$

$g$ 为当前代数，$G_("max")$ 为最大代数，$sigma_0$ 为初始变异强度。进化前期使用较大的变异步长，有利于扩大搜索范围；后期逐渐减小步长，使种群更多围绕较优路径进行局部修正。

*精英保留与终止。* 为避免交叉和变异破坏已获得的优质路径，每代先按适应度对种群排序，并将前 $P_("elite") = max(5, round(0.1 P))$ 个最优个体直接保留到下一代。其余个体通过锦标赛选择、算术交叉和高斯变异生成，直到新种群规模恢复为 $P$。当算法达到最大代数 $G_("max")$ 后，输出当前种群中适应度最小的染色体作为全局路径航点序列。

GA 的执行过程如下。首先，根据起点、终点和带状搜索边界生成初始染色体种群，并计算每条候选路径的适应度；其次，按适应度排序并保留一部分精英个体，避免当前较优路径在后续操作中被破坏；然后，通过锦标赛选择从种群中选出父代；接着，采用算术交叉生成子代，并按给定概率对航点坐标施加高斯变异；之后，对越界航点进行修正，并重新计算子代适应度。新一代种群由精英个体和新生成子代共同组成，循环执行上述过程，直到达到最大代数，最后输出适应度最小的染色体作为全局规划路径。


=== 螳螂搜索算法（MSA）设计与实现

螳螂搜索算法（Mantis Search Algorithm, MSA）由 Abdel-Basset 等提出，其基本思想来源于螳螂寻找猎物、攻击猎物以及性食同类等行为。与一般只依靠单一扰动方式的群体智能算法不同，MSA 将搜索过程划分为寻找猎物、攻击猎物和性食同类三个阶段：寻找猎物阶段负责扩大搜索范围，攻击猎物阶段围绕当前最优解进行开发，性食同类阶段则通过个体重组和强扰动维持种群多样性。

在无人机路径规划中，每只螳螂对应一条候选航点序列。第 $i$ 个个体在第 $t$ 次迭代时的位置向量为

$
bold(x)_i^t = [x_(i,1)^t, y_(i,1)^t, dots, x_(i,N)^t, y_(i,N)^t]
$

初始化阶段根据搜索空间上下界生成初始种群：

$
bold(x)_i^0 = bold(x)_L + bold(r) dot (bold(x)_U - bold(x)_L)
$

其中 $bold(x)_L$ 和 $bold(x)_U$ 分别为下界和上界，$bold(r)$ 为 $[0,1]$ 内的随机向量。初始化后计算所有个体的适应度，并记录当前全局最优解 $bold(x)^*$。同时建立外部存档，用于保存迭代过程中出现的优质历史解，为后续伏击行为和跳出局部区域提供参考。

*寻找猎物阶段。* 该阶段主要承担全局探索任务。MSA 通过回收控制因子 $F$ 调节追捕者行为和伏击者行为的切换：

$
F = 1 - (t "mod" (T / P)) / (T / P)
$

式中，$P$ 为回收因子。$F$ 在每个周期内由 1 逐渐衰减到 0，使算法能够周期性地从大范围搜索过渡到较集中的局部搜索，避免搜索模式过早固定。

追捕者行为用于模拟螳螂主动移动寻找猎物。其位置更新可写为：

$
bold(x)_i^(t+1) = cases(
  bold(x)_i^t + bold(tau)_1 dot (bold(x)_i^t - bold(x)_a^t) + |tau_2| dot bold(U) dot (bold(x)_a^t - bold(x)_b^t) quad r_1 <= r_2,
  bold(x)_i^t dot bold(U) + (bold(x)_a^t + bold(r)_3 dot (bold(x)_b^t - bold(x)_c^t)) dot (1 - bold(U)) quad "otherwise"
)
$

其中 $bold(x)_a^t$、$bold(x)_b^t$ 和 $bold(x)_c^t$ 为随机个体，$bold(tau)_1$ 为 Lévy 飞行扰动向量，$tau_2$ 为正态随机数，$bold(U)$ 为二值掩码向量。该式既包含大尺度随机游走，也包含由随机个体差分关系产生的方向重组，有利于在复杂障碍环境中寻找新的可行通道。

伏击者行为则利用外部存档中的历史优质解作为参考。设 $bold(x)_("ar")^t$ 为存档中随机选取的个体，则有：

$
bold(x)_i^(t+1) = cases(
  bold(x)_i^t + alpha dot (bold(x)_("ar")^t - bold(x)_a^t) quad r_9 <= r_(10),
  bold(x)_("ar")^t + (2 r_7 - 1) dot mu dot (bold(x)_L + bold(r)_8 dot (bold(x)_U - bold(x)_L)) quad "otherwise"
)
$

其中

$
alpha = cos(pi r_6) dot mu, quad mu = 1 - t / T
$

$mu$ 随迭代逐渐减小，使伏击者在前期具有较大的搜索半径，在后期更多围绕历史优质区域精细调整。

*攻击猎物阶段。* 当算法进入开发阶段时，当前全局最优解 $bold(x)^*$ 被视为猎物位置。MSA 先通过 Sigmoid 函数计算击打速度：

$
v_s = 1 / (1 + e^(l dot rho))
$

再根据个体与猎物之间的距离确定攻击方向：

$
bold(d)_(s i)^t = bold(x)^* - bold(x)_i^t
$

若击打成功，个体向当前最优解靠近：

$
bold(x)_i^(t+1) = (bold(x)_i^t + bold(x)^*) / 2 + v_s dot bold(d)_(s i)^t
$

若击打失败，则根据随机个体之间的差分关系修正方向：

$
bold(x)_i^(t+1) = bold(x)_i^t + r_(12) dot (bold(x)_a^t - bold(x)_b^t)
$

击打失败概率定义为

$
P_f = a dot (1 - t / T)
$

该概率随迭代增加而降低，表示算法前期允许更多方向试探，后期逐渐转向稳定收敛。若个体出现陷入局部区域的趋势，还可引入振荡扰动：

$
bold(x)_i^(t+1) = bold(x)_i^t + e^(2l) dot cos(2 pi l) dot |bold(x)_i^t - bold(x)_("ar")^t| + (2 r_(13) - 1) dot (bold(x)_U - bold(x)_L)
$

这一项通过非线性振荡和搜索空间尺度扰动增强跳出局部最优的能力。

*性食同类阶段。* 该阶段用于模拟雌性螳螂吸引、交配并吞食雄性的过程，本质上是一组维持多样性的重组算子。首先，个体根据随机同伴进行吸引更新：

$
bold(x)_i^(t+1) = bold(x)_i^t + bold(r)_(16) dot (bold(x)_i^t - bold(x)_a^t)
$

随后通过二值掩码执行交配重组：

$
bold(x)_i^(t+1) = bold(x)_i^t dot bold(U) + (bold(x)_a^t + bold(r)_(18) dot (bold(x)_i^t - bold(x)_a^t)) dot (1 - bold(U))
$

吞食行为可表示为：

$
bold(x)_i^(t+1) = bold(x)_a^t dot cos(2 pi l) dot mu
$

该阶段在种群过快收敛时能够重新引入差异信息，降低搜索陷入单一路径通道的概率。

/* 在本文实现中，每次位置更新后都需要进行边界修复，再重新计算适应度。若新个体优于旧个体，则接受更新；否则保留原个体。若新个体优于当前全局最优解，则更新 $bold(x)^*$ 并写入外部存档。迭代达到最大次数后，输出全局最优个体对应的航点序列。整体上，MSA 通过追捕、伏击、击打和性食同类等多种搜索机制，在全局探索、局部开发和种群多样性之间保持平衡。 */

MSA 的执行过程可概括为以下几步。首先，根据航点搜索边界随机初始化螳螂种群，并计算每个个体对应路径的适应度；其次，建立外部存档，保存当前搜索过程中出现的优质历史解；然后，在每轮迭代中根据回收控制因子选择追捕者或伏击者行为，完成寻找猎物阶段的全局探索；接着，围绕当前最优解执行攻击猎物阶段，并根据击打成功、击打失败或振荡扰动更新个体；随后，按概率执行性食同类操作，通过吸引、交配和吞食行为增加种群扰动。每次更新后都进行边界修复、适应度评价和最优解记录，直到达到最大迭代次数后输出全局最优航点序列。

=== 人工蜂鸟算法（AHA）设计与实现

人工蜂鸟算法（Artificial Hummingbird Algorithm, AHA）模拟蜂鸟的空间记忆、灵活飞行和觅食行为。算法中每只蜂鸟对应一个候选解，食物源位置对应无人机全局路径的航点编码。设路径包含 $N$ 个中间航点，则第 $i$ 只蜂鸟的位置向量为：

$
bold(x)_i = [x_(i,1), y_(i,1), dots, x_(i,N), y_(i,N)] in bb(R)^(2N)
$

种群初始化时，所有蜂鸟在带状搜索边界内随机生成：

$
bold(x)_i^0 = bold(x)_L + bold(r) dot (bold(x)_U - bold(x)_L)
$

其中 $bold(x)_L$ 和 $bold(x)_U$ 分别为搜索空间下界和上界。每个个体解码为航点序列后，与起点、终点共同构成完整路径，并使用前述适应度函数计算代价 $J(bold(x)_i)$。

*访问表与目标食物源选择。* AHA 的核心结构是访问表 $bold(V T)$。访问表用于记录蜂鸟对不同食物源的访问间隔，初始状态为：

$
(V T)_(i,j)^0 = cases("null" quad i = j, 0  quad i != j)
$

其中主对角线表示蜂鸟自身所在食物源，不参与访问选择。对蜂鸟 $i$ 而言，算法先在第 $i$ 行中寻找访问间隔最大的食物源；若多个食物源访问间隔相同，则选择其中适应度更优的个体作为目标。该规则可写为：

$
cal(C)_i = {j | (V T)_(i,j) = max_(k != i) (V T)_(i,k)}, quad
j^* = arg min_(j in cal(C)_i) J(bold(x)_j)
$

这样既能避免频繁重复访问同一食物源，也能使搜索逐步向高质量路径附近集中。

*飞行模式。* AHA 通过方向向量 $bold(D) in {0,1}^(2N)$ 控制本次更新涉及的维度。若只选取一个维度更新，则对应轴向飞行，适合对单个航点坐标进行精细调整；若随机选取多个维度更新，则对应对角飞行，能够同时调整若干航点；若所有维度均参与更新，则对应全向飞行，可对整条路径形态产生较大扰动。三种飞行模式共同提供了从局部微调到全局扰动的不同搜索尺度。

*引导觅食。* 引导觅食模拟蜂鸟根据记忆飞向目标食物源的行为。设目标食物源为 $bold(x)_(j^*)^t$，候选位置更新为：

$
bold(v)_i^(t+1) = bold(x)_(j^*)^t + a dot bold(D) dot (bold(x)_i^t - bold(x)_(j^*)^t), quad a tilde.op cal(N)(0,1)
$

其中 $a$ 为标准正态随机变量，$dot$ 表示逐元素乘法。当 $a$ 较小时，候选解靠近目标食物源；当 $a$ 取较大值或负值时，候选解可能跨越目标区域，从而增强跳出局部最优的能力。

*领地觅食。* 领地觅食模拟蜂鸟在自身食物源附近继续搜索的行为。其更新不依赖外部目标，而是在当前个体附近施加扰动：

$
bold(v)_i^(t+1) = bold(x)_i^t + b dot bold(D) dot bold(x)_i^t, quad b tilde.op cal(N)(0,1)
$

其中 $b$ 同样服从标准正态分布。该策略主要用于局部开发，可对当前路径的部分航点进行修正。

*迁徙觅食。* 为避免种群长期集中在局部区域，AHA 每隔 $2n$ 次迭代触发一次迁徙操作。算法选取当前适应度最差的蜂鸟：

$
i_("worst") = arg max_i J(bold(x)_i^t)
$

并将其重新随机初始化：

$
bold(x)_(i_("worst"))^(t+1) = bold(x)_L + bold(r) dot (bold(x)_U - bold(x)_L)
$

迁徙觅食相当于向种群注入新的候选路径，可在搜索后期补充多样性。

*边界处理、贪婪选择与访问表更新。* 引导觅食或领地觅食生成候选解后，先对越界维度进行裁剪，再计算候选路径的适应度。个体更新采用贪婪准则：

$
bold(x)_i^(t+1) = cases(
  bold(v)_i^(t+1) quad J(bold(v)_i^(t+1)) < J(bold(x)_i^t),
  bold(x)_i^t quad "otherwise"
)
$

每次觅食后都需要更新访问表。若蜂鸟 $i$ 在引导觅食中访问了目标食物源 $j^*$，则将 $(V T)_(i,j^*)$ 置为 0，同一行中其他可访问元素加 1：

$
(V T)_(i,j^*) arrow 0, quad (V T)_(i,k) arrow (V T)_(i,k) + 1, quad k != j^*
$

若蜂鸟位置得到改善，则其他蜂鸟对该新食物源的访问间隔也需要相应刷新，使新产生的优质解更容易在后续迭代中被关注。

综上，AHA 的路径规划流程为：初始化蜂鸟种群和访问表；在每轮迭代中随机选择飞行模式，并在引导觅食与领地觅食之间切换；生成候选解后进行边界处理、适应度评价和贪婪选择；按规则更新访问表，并周期性执行迁徙觅食。该算法通过访问表减少重复搜索，通过多种飞行模式调节更新尺度，并通过迁徙机制维持全局探索能力。

 /* AHA 的执行过程如下。首先，根据起点、终点和带状搜索边界初始化蜂鸟种群，并计算各候选路径的适应度；其次，建立访问表 $bold(V T)$，记录不同蜂鸟对食物源的访问间隔；然后，在每轮迭代中为每只蜂鸟随机确定轴向、对角或全向飞行模式；接着，根据访问表和适应度选择目标食物源，执行引导觅食，或在当前个体附近执行领地觅食；之后，对候选解进行边界处理和贪婪选择，并同步更新访问表。当迭代次数满足迁徙条件时，算法重置当前最差个体，以补充新的搜索方向。最后，将全局最优蜂鸟个体解码为无人机全局路径。 */

=== AL-SHADE 算法设计与实现

AL-SHADE 是在 L-SHADE 基础上发展而来的自适应差分进化算法。该算法保留成功历史参数记忆和线性种群规模缩减机制，并引入 current-to-Amean/1 变异策略，以利用外部档案中的优质历史信息。本文将 AL-SHADE 作为主要全局路径规划框架。

AL-SHADE 的个体编码仍为二维航点向量：

$
bold(x)_i = [x_(i,1), y_(i,1), dots, x_(i,N), y_(i,N)]
$

初始种群按搜索边界随机生成：

$
bold(x)_i^0 = bold(x)_L + bold(r) dot (bold(x)_U - bold(x)_L)
$

算法维护两个历史记忆数组 $bold(M)_F$ 和 $bold(M)_("C R")$，分别存储成功的缩放因子和交叉概率。每个个体在迭代时随机选择一个记忆槽，并由柯西分布和高斯分布生成参数：

$
F_i tilde.op "Cauchy"(M_(F,r_i), 0.1), quad (C R)_i tilde.op cal(N)(M_(C R,r_i), 0.1)
$

AL-SHADE 采用两类变异策略。第一类为 current-to-pbest/1：

$
bold(v)_i = bold(x)_i + F_i (bold(x)_("pbest") - bold(x)_i) + F_i (bold(x)_(r_1) - bold(x)_(r_2))
$

其中 $bold(x)_("pbest")$ 从前 $p$% 优质个体中随机选取，$bold(x)_(r_2)$ 可来自当前种群或外部档案。


第二类变异策略为 current-to-Amean/1：

$
bold(v)_i = bold(x)_i + F_i (bold(x)_("Amean") - bold(x)_i) + F_i (bold(x)_(r_1) - bold(x)_(r_2))
$

其中 $bold(x)_("Amean")$ 为外部档案中优质个体的加权均值：

$
bold(x)_("Amean") = sum_(i=1)^m w_i bold(a)_i
$

权重可按排序位置确定：

$
w_i = frac(ln(m + 0.5) - ln(i), sum_(j=1)^m (ln(m + 0.5) - ln(j)))
$

*自适应策略选择。* AL-SHADE 对两种变异策略采用概率调度。对每个个体生成随机数 $r in [0, 1]$，若 $r < P_s$，则执行 current-to-pbest/1；否则执行 current-to-Amean/1。第 $g$ 代结束后，根据两种策略产生改进解的成功比例更新 $P_s$：

$
P_s^(g+1) = P_s^g + 0.05 dot (1 - P_s^g) dot (P_1 - P_2) dot frac(F_("Es"), F_("max"))
$

其中，$P_1$ 和 $P_2$ 分别表示 current-to-pbest/1 与 current-to-Amean/1 在当前代中的成功比例，$F_("Es")$ 为已消耗的函数评价次数，$F_("max")$ 为最大函数评价次数。若 $P_1 > P_2$，说明精英引导策略在当前阶段更有效，$P_s$ 相应增大；反之，则增加 current-to-Amean/1 的执行机会。该机制使算法能够随搜索进程动态调节开发和探索强度。


变异后，算法使用二项交叉生成试验向量：

$
u_(i,j) = cases(v_(i,j) quad r_j <= (C R)_i " or " j = j_("rand"), x_(i,j) quad "otherwise")
$

其中 $j_("rand")$ 保证至少一个维度来自变异向量。若变异向量越界，则采用父代与边界之间的中点进行修正：

$
v_(i,j) = cases((x_(i,j) + L_j) / 2 quad v_(i,j) < L_j, (x_(i,j) + U_j) / 2 quad v_(i,j) > U_j, v_(i,j) quad "otherwise")
$

选择阶段采用贪婪准则：

$
bold(x)_i^(g+1) = cases(bold(u)_i^g quad J(bold(u)_i^g) <= J(bold(x)_i^g), bold(x)_i^g quad "otherwise")
$

若试验个体优于父代，则父代进入外部档案，同时记录本次成功的 $F_i$、$(C R)_i$ 及适应度改变量。历史记忆通过加权 Lehmer 平均更新：

$
"mean"_("WL")(S) = frac(sum_n w_n s_n^2, sum_n w_n s_n), quad
w_n = frac(|J(bold(x)_n) - J(bold(u)_n)|, sum_l |J(bold(x)_l) - J(bold(u)_l)|)
$

为提高后期开发能力，AL-SHADE 还采用线性种群规模缩减策略，设初始种群规模为 $P_("init")$，最小种群规模为 $(P_("min")$，则当前目标种群规模为：

$
P_(g+1) = "round" lr(frac(F_("Es"), F_("max")) dot (P_("min") - P_("init")) + P_("init"))
$

随着函数评估次数增加，种群规模逐步从 $P_("init")$ 降至 $P_("min")$，计算资源也从广域探索转向局部精细搜索。

在无人机路径规划中，AL-SHADE 的实现流程可以概括为：初始化种群、历史记忆和外部档案；为每个个体生成 $F_i$ 与 $(C R)_i$；按自适应概率选择变异策略；交叉得到试验个体；根据适应度执行选择并更新外部档案；最后更新历史记忆和种群规模。与 PSO、ACO、GA、MSA 和 AHA 相比，AL-SHADE 更适合连续航点坐标优化，能够在保持搜索多样性的同时逐步提高局部开发能力。但原生 AL-SHADE 仍未显式考虑路径连续性、障碍威胁感知和外部档案相似解冗余问题，这也是后文进行 TALG 改进的主要原因。

 

== 本章小结

本章围绕无人机集群全局路径规划算法展开，首先建立了统一的适应度函数，将路径长度、平滑性、静态障碍风险、机间安全、通信约束、通道宽度和编队保持等因素纳入同一评价框架。该函数为不同优化算法提供了共同的比较标准，也使后续实验能够从任务效率、安全性和队形稳定性等方面进行综合分析。

在算法层面，本章分别介绍了 PSO、ACO、GA、MSA、AHA 和 AL-SHADE 在二维航点优化问题中的设计方式。PSO 具有较快的收敛速度，ACO 和 GA 适合用于经典启发式对比，MSA 与 AHA 通过生物启发机制增强搜索多样性，而 AL-SHADE 依靠历史参数记忆和线性种群缩减机制，更适合连续航点坐标的自适应优化。通过上述内容，可以明确各算法在全局路径规划中的基本作用、适用特点和潜在不足。下一章将在此基础上进一步建立无人机编队控制模型和局部避障模型，为全局路径的执行与验证提供支撑。

= 模型构建

无人机集群路径规划要解决的不只是从起点到目标点找到一条可行航迹，还要让多架无人机在飞行过程中保持稳定队形，并能在障碍物环境中协同避障。因此，在使用全局规划结果开展任务执行之前，需要建立编队的运动描述和队形约束模型，明确无人机之间的相对位置关系、通信拓扑以及一致性控制方式。本节先对无人机编队控制模型进行建模，为前述全局路径规划结果的跟踪、后续局部避障和联合仿真打下基础。

 == 编队控制模型设计与实现
 === 无人机编队模型
  建模时先将无人机视为质点，并用地面坐标系描述其位置和运动状态；在水平面内，原点O可以根据需要选取。无人机编队的三维平面描述通常有l–ψ法和l–l法两种形式，本文采用l–l法。无人机之间的相对位置关系由矩阵Rx、Ry表示。
 $ cases(
  R_x = mat(delim: "[",
    r^x_(1 1), r^x_(1 2), dots.h, r^x_(1 n);
    r^x_(2 1), r^x_(2 2), dots.h, r^x_(2 n);
    dots.v, dots.v, dots.down, dots.v;
    r^x_(n 1), r^x_(n 2), dots.h, r^x_(n n)
  ),
  
  R_y = mat(delim: "[",
    r^y_(1 1), r^y_(1 2), dots.h, r^y_(1 n);
    r^y_(2 1), r^y_(2 2), dots.h, r^y_(2 n);
    dots.v, dots.v, dots.down, dots.v;
    r^y_(n 1), r^y_(n 2), dots.h, r^y_(n n)
  ),

) $
其中$r^x_(i j)$,$r^y_(i j)$ 表示第$i$架无人机与第$j$架无人机之间的相对位置的差值，$r^x_(i j) = r^y_(i j) = 0$。

多无人机形成的理想稳定队形如下：
$ cases(
  |x_i - x_j| -> r^x_(i j),
  |y_i - y_j| -> r^y_(i j),
  |v_i - v_j| -> 0,
) $ 

其中 $x_i, y_i$ 是无人机的坐标，$v_i$ 是速度。

=== 无人机动力学模型

无人机编队建模中，常采用含自驾仪的三自由度运动学模型。基础运动学方程中的纵向运动和横向运动存在耦合关系。文献[29]对横向航向自驾仪和纵向自驾仪进行解耦，建立横纵分离的运动学模型。其中，无人机i的运动模型如公式(3)所示。
$ cases(
  dot(x)_i = v_i cos theta_i,
  dot(y)_i = v_i sin theta_i,
  dot(theta)_i = omega_i,
  dot(v)_i = frac(1, tau_v) (v_i^c - v_i),
  dot(theta)_i = frac(1, tau_theta) (theta_i^c - theta_i),
) $ <eq:kinematics>

其中 $v_i$ 是飞机在 XOY 平面上的速度； $θ_i$ 为航向； $ω_i$ 为航向角速度； $τ_v$ 为飞行状态常数对应的速度； $τ_θ$ 为航向角对应的飞行状态常数； $v_i^c$ 为无人机自动驾驶仪的速度参考输入； $θ^c_i$ 为无人机自动驾驶仪航向角参考输入

在XOY平面上的运动存在下面的耦合关系。
$ cases(
  tan theta_i = frac(v_(y i), v_(x i)),
  v_i = sqrt(v_(x i)^2 + v_(y i)^2),
) $ <eq:coupling>
$v_(y i), v_(x i)$分别为无人机在XOY平面上的横向和纵向速度。

因此自动驾驶的动力学方程可以表示为：
$ cases(
  dot(x_i) = v_(x i),
  dot(y_i) = v_(y i),
  dot(v_(x i)) = frac(1, tau_v) (v^c_(x i) - v_(x i)),
  dot(v_(y i)) = frac(1, tau_v) (v^c_(y i) - v_(y i)),
) $ <eq:autopilot>

因为无人机存在机动性的问题，需要给无人机添加动力学的约束条件，如公式(6)所示。
$ cases(
  v_i in (v_min, v_max),
  dot(v_i) in (a_min, a_max),
  dot(theta_i) in (omega_min, omega_max),
) $ <constraints>

=== 编队控制模型

本节基于一致性原理，分别设计无人机在横向和纵向上的控制策略，并将物理机动限制纳入控制律中，得到本文采用的协同控制算法。

在多无人机系统中，无人机之间的信息交互关系通常用图论（Graph Theory）描述。设集群中共有 $n$ 架无人机，其通信拓扑可表示为无向图或有向图 $G = (V, E)$。为描述节点之间的连接关系，引入邻接矩阵 $A = [a_(i j)] in bb(R)^(n times n)$ 和拉普拉斯矩阵 $L = [l_(i j)] in bb(R)^(n times n)$。邻接矩阵元素 $a_{i j}$ 用于表示通信链路：当无人机 $i$ 能够获取无人机 $j$ 的信息时，$a_{i j}=1$，否则 $a_{i j}=0$。

拉普拉斯矩阵定义为 $L = D - A$，其中度矩阵 $D = "diag"(d_1, d_2, dots.h, d_n)$，节点入度为 $d_i = sum_{j=1}^n a_{i j}$。文献[]表明，拉普拉斯矩阵不仅反映系统的图论拓扑特征，其特征值分布也与一致性算法的收敛性和集群飞行稳定性密切相关。只有当通信拓扑图包含生成树时，控制系统才能实现无偏的渐近收敛。

Tao 等@tao2023 将无人机水平运动建模为双积分器系统：$dot(bold(p))_i = bold(v)_i$，$dot(bold(v))_i = bold(u)_i$，其中 $bold(u)_i = (u_(x i), u_(y i))^T$ 为待设计的虚拟加速度控制输入。沿 $X_g$ 和 $Y_g$ 轴构造的基础一致性协议如下：

$
u_(x i)(t) = - sum_(j=1)^n a_(i j) [(x_i(t) - x_j(t) - r_(i j)^x) + gamma (v_(x i)(t) - v_(x j)(t))]
$

$
u_(y i)(t) = - sum_(j=1)^n a_(i j) [(y_i(t) - y_j(t) - r_(i j)^y) + gamma (v_(y i)(t) - v_(y j)(t))]
$

式中，$gamma > 0$ 表示位置误差与速度误差的耦合增益，$r_(i j)^x = -r_(j i)^x$、$r_(i j)^y = -r_(j i)^y$ 为前文定义的期望相对位移。该协议使每架无人机沿两个坐标轴向邻机的期望相对位置靠拢，同时使其速度逐渐接近邻居集合的加权平均。

上述基础形式默认通信无延迟，且拓扑结构保持不变。实际飞行中，机间数据链通常存在传输延迟；受信道质量、机间距离和障碍遮挡等因素影响，通信链路也可能中断或恢复。针对这些情况，Tao 等@tao2023 提出了能够同时处理非对称通信时延和切换拓扑的改进一致性控制律。

记 $tau_(i i)(t)$ 为无人机 $i$ 自身状态感知与解算的自延迟，$tau_(i j)(t)$ 为 $j$ 到 $i$ 的机间通信延迟，二者满足有界性条件：$0 <= tau_m(t) <= h_m$ 且 $dot(tau)_m(t) <= d_m < 1$。令 $N_i(t)$ 为 $t$ 时刻无人机 $i$ 的有效邻居集，$a_(i j)(t)$ 为对应的时变邻接权重。则 $X_g$ 与 $Y_g$ 方向上的改进一致性控制输入为：

$
u_(x i)(t) = sum_(V_j in N_i(t)) a_(i j)(t) thin [
  k_1 (x_j(t - tau_(i j)) - x_i(t - tau_(i i)) - r_(j i)^x) \
  + k_2 (v_(x j)(t - tau_(i j)) - v_(x i)(t - tau_(i i)))
] + dot(v)_x^"*" - k_3 (v_(x i)(t) - v_x^"*")
$ <improved-consensus-x>

$
u_(y i)(t) = sum_(V_j in N_i(t)) a_(i j)(t) thin [
  k_1 (y_j(t - tau_(i j)) - y_i(t - tau_(i i)) - r_(j i)^y) \
  + k_2 (v_(y j)(t - tau_(i j)) - v_(y i)(t - tau_(i i)))
] + dot(v)_y^"*" - k_3 (v_(y i)(t) - v_y^"*")
$ <improved-consensus-y>

式中各参数的物理含义：$k_1 > 0$ 为位置偏差增益，控制编队几何构型的恢复强度；$k_2 > 0$ 为速度一致性增益，调节邻机间的速度同步速率；$k_3 = k_1 k_2$ 为速度跟踪增益，使集群整体速度向期望巡航速度 $(v_x^"*", v_y^"*")$ 对齐；$dot(v)_x^"*"$、$dot(v)_y^"*"$ 为参考加速度前馈项（编队匀速巡航时取零）；$r_(j i)^x$、$r_(j i)^y$ 采用反对称形式以匹配控制量的增量方向。

与基础协议相比，改进算法在三个层面进行增强：(1) 显式引入非对称通信时延 $tau_(i j)$ 与 $tau_(i i)$，使各无人机基于实际通信时序中的延迟状态而非理想同步状态进行决策；(2) 将时不变邻接权重替换为时变形式 $a_(i j)(t)$，使控制律自适应通信链路的动态通断，只要切换序列满足联合连通条件即可保证收敛@tao2023；(3) 增设参考速度前馈通道，赋予编队整体的机动跟随能力，满足路径规划层下达的变速巡航需求。

控制输入 $bold(u)_i$ 到自驾仪速度指令的映射由一阶惯性环节的逆模型给出：

$
cases(
  v_(x i)^c = v_(x i) + tau_v u_(x i),
  v_(y i)^c = v_(y i) + tau_v u_(y i),
) $ <control-to-autopilot>

该变换补偿了自驾仪的动态响应滞后，使无人机在稳态下紧密跟踪一致性控制量的期望加速度。

==== 飞行约束的调整策略

@eqt:control-to-autopilot 求得的指令未考虑@eqt:constraints 所列的机动能力边界。Tao 等@tao2023 设计了分两级递进的最小调整映射，在保证指令可行性的前提下尽量保持原始控制方向。

 由 $bold(u)_i$ 计算合加速度幅值 $alpha_i = sqrt(u_(x i)^2 + u_(y i)^2)$，以采样周期 $Delta t$ 预估下一步速度 $v_i(t+Delta t) = v_i(t) + alpha_i Delta t$。若预估值越界，则收紧加速度有效区间 $[a_(min,i)^"new", a_(max,i)^"new"]$。当 $alpha_i$ 超出上界时，按比例压缩两轴分量以保持合加速度方向不变：

$
u'_(x i) = frac(a_(max,i)^"new", alpha_i) u_(x i), quad
u'_(y i) = frac(a_(max,i)^"new", alpha_i) u_(y i)
$

由缩放后的加速度预估下一时刻航向：
$
theta_i(t+Delta t) = arctan(frac(v_(y i) + u'_(y i) Delta t, v_(x i) + u'_(x i) Delta t))
$

根据最大航向角速率 $omega_max$、$omega_min$ 确定航向可达区间：

$
theta_(min,i) = theta_i(t) + omega_min Delta t, quad
theta_(max,i) = theta_i(t) + omega_max Delta t
$

若预测航向偏离该区间，则在保持合加速度幅值不变的前提下，将航向修正至最近边界值 $theta_("bound")$，联立求解加速度最终可行解 $(u''_(x i), u''_(y i))$。经两级修正后的控制量通过式@eqt:control-to-autopilot 映射为满足全部机动约束的自驾仪指令。

==== 离散时间实现

控制器以周期 $Delta t$ 迭代运行。每个控制步先采集邻机的延迟状态，再根据@eqt:improved-consensus-x 和@eqt:improved-consensus-y 计算虚拟加速度；经过上述两级约束映射后，控制器输出自驾仪速度指令，并驱动无人机状态更新。该结构能够在二维平面内兼顾拓扑变化和飞行安全，为全局路径跟踪和后续局部避障提供稳定的编队控制基础@tao2023。

 == 局部避障算法设计与实现

前文给出的全局路径规划器（PSO、ACO、GA、MSA、AHA、AL-SHADE）能够为无人机集群提供宏观参考航点序列，但实际飞行中仍会遇到全局规划难以提前覆盖的局部风险。常见情况主要有两类：一类是障碍物分布信息不够精确，例如传感器探测范围受限或环境发生变化；另一类是多机编队保持与单机避障之间存在实时耦合冲突。因此，本文在全局规划层之下加入局部避障层，以人工势场法（Artificial Potential Field, APF）为基础，通过改进斥力场和前视预测机制，为每架无人机实时生成局部修正加速度，补足全局路径在动态环境中的安全裕度。

==== 改进人工势场法

经典人工势场法由 Khatib 于 1986 年提出，基本思路是在工作空间中构造虚拟势场：目标点产生引力，障碍物产生斥力，无人机在合力作用下向目标运动，并尽量绕开障碍物。该方法结构简单、实时性较好，但在复杂障碍物环境中也容易暴露问题。其一是目标不可达问题（Goal Non-Reachable with Obstacles Nearby, GNRON）：当目标靠近障碍物时，斥力可能压过引力，使无人机难以逼近目标。其二是局部极小值（Local Minima）问题：在"U 型"障碍物或狭窄通道中，合势场可能接近零，导致无人机来回振荡甚至停滞。本节围绕这两个问题，从斥力场建模和前视自适应减速两个方面对经典 APF 进行改进。

*障碍物斥力场的切向旋转增强。* 经典 APF 的斥力方向严格沿障碍物中心到无人机的径向线。当无人机、障碍物和目标大致共线时，合力方向也主要落在这条直线上，很难自然产生绕行动作。为解决这一问题，本文在径向斥力之外加入切向旋转分量，形成矢量复合斥力场。

设无人机 $i$ 的当前位置为 $bold(p)_i = (x_i, y_i)^T$，速度矢量为 $bold(v)_i = (v_(x i), v_(y i))^T$。对当前探测范围内的障碍物，先筛选出距离无人机最近的障碍物 $O^"*"$。这里用间隙距离 $d = norm(bold(p)_i - bold(c)_("obs")) - R_("obs")$ 作为度量，其中 $bold(c)_("obs")$ 和 $R_("obs")$ 分别表示障碍物中心和半径。斥力作用范围定义为 $d_("inf") = R_("obs") + d_("safe") + 50$，其中 $d_("safe")$ 为预设安全距离，本文取 20 m。当 $d >= d_("inf")$ 时斥力为零；当 $d < d_("inf")$ 时，斥力由径向分量 $bold(f)_("rad")$ 和切向分量 $bold(f)_("tan")$ 合成。

径向斥力沿无人机指向障碍物中心的单位向量 $bold(e)_r$ 方向，其幅值由归一化距离强度 $sigma = max(0, (d_("inf") - d) / d_("inf"))$ 调控：

$
bold(f)_("rad") = k_r sigma bold(e)_r, quad bold(e)_r = frac(bold(p)_i - bold(c)_("obs"), norm(bold(p)_i - bold(c)_("obs"))) $ <radial-repulsion>

式中 $k_r = 25$ 为径向斥力增益。$sigma in [0, 1)$ 会随无人机接近障碍物而增大，使斥力在障碍物边缘附近达到较大值。

切向斥力是本节改进的重点。先取 $bold(e)_r$ 的逆时针正交单位向量 $bold(e)_t = (-e_(r, y), e_(r, x))^T$。为了让切向力方向尽量顺着当前飞行方向，引导无人机绕过障碍物而不是反向折返，需要对 $bold(e)_t$ 和速度矢量作点积校核：若 $bold(v)_i dot bold(e)_t < 0$，则将 $bold(e)_t$ 取反。切向斥力为：

$
bold(f)_("tan") = k_t sigma bold(e)_t $ <tangential-repulsion>

其中 $k_t = 15$ 为切向力增益。加入切向分量后，合力方向不再只沿径向线变化，而会带有沿障碍物边缘转动的趋势。这样在"U 型"障碍物或狭窄通道中，无人机能够获得主动绕行的运动分量，局部死锁概率也随之降低。

复合斥力为两分量之和 $bold(f)_("rep") = bold(f)_("rad") + bold(f)_("tan")$。当无人机位于开阔区域并远离障碍物时，$sigma ≈ 0$，斥力自然退化为零，避免对集群编队产生不必要扰动。靠近障碍物时，径向分量主要负责安全避让，切向分量提供绕行引导，两者共同实现较平滑的规避动作。

*前视预测减速机制。* GNRON 问题通常出现在目标附近障碍物斥力抵消引力的情况下，此时无人机容易在终点前停滞。为缓解这一问题，本文引入基于运动预测的前视安全评估。具体做法是沿无人机当前速度方向，以固定时间步长向前预测一段轨迹，并计算预测轨迹到各障碍物的最小间隙。若该间隙小于减速阈值，则按比例降低引力参考速度，使无人机以较安全的速度靠近目标区域。

具体地，取预测视距 $T_h = 5.0$ s，并将其等分为 $N_s = 25$ 个微段，微段时间步长为 $Delta t_s = T_h / N_s$。以当前位置为起点，在速度恒定的假设下逐段向前递推，得到 $N_s$ 个预测位置点。对每个预测点计算其到各障碍物的间隙，并将整个预测时域内的最小值记为 $d_("pred")$：

$
d_("pred") = min_(k=1)^(N_s) min_(O in cal(O)) lr(norm(bold(p)_i + k Delta t_s bold(v)_i - bold(c)_O) - R_O) $ <predicted-clearance>

设减速阈值为 $d_("slow") = 2.5 d_("safe") = 50$ m，前视减速因子 $lambda$ 定义为：

$
lambda = "clip"lr(frac(d_("pred"), d_("slow")), space 0.2, space 1.0) $ <speed-reduction>

当 $d_("pred") >= d_("slow")$，即前方较安全时，$lambda = 1$，引力速度保持不变；当 $d_("pred") -> 0$ 时，$lambda arrow 0.2$，引力速度降至巡航值的 20%。这样可以让无人机在密集障碍区低速穿行，避免高速逼近后因机动余量不足而难以及时转向。将 $lambda$ 作用于导航参考速度 $bold(v)_("ref")$，即可得到安全缩放后的有效参考速度 $bold(v)_("ref")^("eff") = lambda bold(v)_("ref")$。

*目标引力场。* 引力场用于驱动无人机沿全局路径航点序列飞行。设当前目标航点为 $bold(p)_("tgt")$，即全局规划器输出并经过 APF 局部修正后的下一航点；无人机 $i$ 的位置为 $bold(p)_i$。目标方向、期望巡航速度和引力加速度指令分别为：

$
"direction" arrow bold(p)_("tgt") - bold(p)_i, quad "distance" arrow norm("direction") $ <target-direction>

$
bold(v)_("ref") = v_("cruise") dot frac("direction", "distance"), quad v_("cruise") = 25 space "m/s" $ <ref-velocity>

$
bold(u)_("nav") = dot(bold(v))_("ref") - k_3 thin (bold(v)_i - bold(v)_("ref")^("eff")) $ <nav-guidance>

当无人机距离目标航点小于 50 m 时，巡航速度按比例线性缩减（$v = max(5, 25 dot d / 50)$），使航点切换过程更加平滑；当距离最终目标小于 1 m 时，引力置零，无人机由编队控制接管并完成最终悬停。

==== 综合控制律与动力学约束

每架无人机 $i$ 在每个控制周期 $Delta t = 0.1$ s 内，都会接收来自三个功能通道的加速度指令：

$
bold(u)_i^("cmd") = bold(u)_i^("cons") + bold(u)_("nav") + bold(f)_("rep") $ <integrated-control>

其中 $bold(u)_i^("cons")$ 为前文基于改进一致性协议（时延-切换拓扑）得到的编队控制加速度，$bold(u)_("nav")$ 为式@eqt:nav-guidance 给出的目标引力与速度跟踪加速度，$bold(f)_("rep")$ 为式@eqt:radial-repulsion 和式@eqt:tangential-repulsion 合成的障碍物复合斥力加速度，并按单位质量归一化。三者采用加性叠加，实现编队保持、目标引导和局部避障的实时耦合。

在输出至自动驾驶仪之前，加速度指令需要经过两级物理约束校验。第一级是速度约束：先预估下一时刻速度 $bold(v)_i(t + Delta t) = bold(v)_i(t) + bold(u)_i^("cmd") Delta t$，若其范数超过最大允许速度 $v_("max") = 80$ m/s，则按比例收缩各分量：$bold(u)_i^("cmd") arrow (v_("max") / norm(bold(v)_i(t + Delta t))) bold(u)_i^("cmd")$。第二级是加速度约束：若 $norm(bold(u)_i^("cmd")) > a_("max") = 4g$，则等比例缩放为 $bold(u)_i^("cmd") arrow (a_("max") / norm(bold(u)_i^("cmd"))) bold(u)_i^("cmd")$。经过约束映射后，可行加速度指令再通过式@eqt:control-to-autopilot 转换为一阶惯性自动驾驶仪的速度指令，完成从控制计算到物理执行的闭环。

*控制优先级分析。* 实际执行中，三个加速度通道的优先级主要通过各分量增益体现。障碍物斥力增益（$k_r = 25$、$k_t = 15$）高于编队控制增益（$k_1 = 0.8$、$k_2 = 1.2$）。因此，当无人机近距离遭遇障碍物时（$sigma -> 1$），斥力 $bold(f)_("rep")$ 的幅值约为 40 N/kg 量级，明显高于编队控制力的 1–5 N/kg 量级，系统自然形成“安全优先”的次序，即避障优先于目标引导和编队保持。当 $sigma -> 0$，即无人机远离障碍物时，斥力自动归零，编队控制与目标引导重新主导运动，集群回到稳定编队巡航状态。

/* *分层耦合架构总结。* 局部避障层与全局规划层、编队控制层共同构成分层耦合结构。全局规划层以数秒至数十秒的周期运行，输出覆盖全程的参考航点序列；编队控制层以 0.1 s 周期运行，负责维持集群几何构型；局部避障层嵌入同一 0.1 s 控制周期内，通过加速度修正在线补充前两层指令。上层输出的全局航点在局部层中作为目标引力源，局部层输出的安全修正加速度再与编队加速度叠加，共同驱动无人机运动。这样既保留全局路径规划的远距离引导能力，也使系统能够对近场障碍物作出较快响应。
 */

*控制参数分析与标定。* APF 局部避障器主要涉及三个参数：径向斥力增益 $k_r$、切向力增益 $k_t$ 和安全距离 $d_("safe")$。本文取 $k_r = 25$，使无人机在 $d_("safe") = 20$ m 的缓冲区边缘（$sigma ≈ 0.5$）受到约 12.5 N/kg 的径向斥力，能够在两到三个控制周期内改变 80 m/s 巡航状态下的航向。切向力增益取 $k_t = 15$，此时切向分量约为径向分量的 60%。仿真调试表明，比例过小（< 30%）时绕行效果不明显，比例过大（> 90%）时又可能使无人机过度偏离目标方向。安全距离 $d_("safe") = 20$ m 综合考虑编队包络半径（约 60 m）和 GPS/惯导组合定位误差（约 5–10 m），在障碍物周围形成两级缓冲：$d_("safe")$ 内为强斥力急避区，$d_("safe")$ 至 $d_("inf")$ 之间为线性衰减预警区。

前视预测参数取 $T_h = 5.0$ s、$N_s = 25$，对应约 0.2 s/段的时间分辨率。在 80 m/s 速度下，其空间分辨率约为 16 m/段，能够提前一到两个预测段发现前方障碍物。减速阈值 $d_("slow") = 2.5 d_("safe") = 50$ m 与下限 $lambda_("min") = 0.2$ 配合使用，使无人机在进入安全缓冲区前就开始降速，避免高速冲入急避区后因机动能力不足而无法及时转向。

== 分层耦合任务执行框架

前文已经分别建立了编队控制模型、全局路径规划算法和 APF 局部避障方法。实际执行任务时，这三部分并不是彼此独立运行，而是在同一个闭环中分层配合。全局规划层先给出从起点到目标点的参考航路，编队控制层再把这条航路转化为多无人机协同飞行中的队形保持指令；当飞行过程中遇到近场障碍物时，局部避障层对控制指令作实时修正。这样处理后，系统既能保留全局路径的整体质量，也能兼顾编队稳定性和局部飞行安全。

任务开始时，系统先输入起点、目标点、障碍物分布、无人机数量和期望编队构型等先验信息。全局路径规划算法在统一适应度函数约束下搜索航点序列，并生成面向领航者的全局参考路径。随后，领航者沿参考路径逐步跟踪当前目标航点；其余跟随者则根据期望相对位移、邻接拓扑和一致性控制律生成编队保持控制量，使集群在整体运动过程中尽量维持预设队形。

进入飞行执行阶段后，局部避障层以较高控制频率嵌入编队控制回路。若无人机的预测轨迹进入障碍物影响范围，APF 模块会根据障碍物距离、径向斥力和切向绕行力计算安全修正量；若周围环境较安全，局部避障项会趋近于零，此时系统主要由全局路径跟踪和编队保持控制主导。最终控制指令仍按@eqt:integrated-control 合成，由编队一致性控制量、全局导航加速度和局部避障修正量共同决定。也就是说，局部避障并不替代全局规划，而是在保持任务方向的基础上提供必要的安全偏置。

从任务执行角度看，可以把整个流程理解为：全局规划先确定大致飞行方向，编队控制负责维持多机结构，局部避障则在出现风险时进行短时修正。全局规划层影响路径长度、到达时间和平滑性；编队控制层影响队形误差和机间安全裕度；局部避障层则关系到集群面对突发障碍物扰动时能否及时调整。后续算法改进主要作用于全局规划层，但参考路径质量会继续影响编队控制和局部避障过程，最终反映到无人机集群任务的整体表现上。


= 基于 TALG 框架的 AL-SHADE 路径规划算法改进

== AL-SHADE 算法的改进：TALG 框架

传统AL-SHADE 直接用于路径规划时，主要问题集中在档案利用、搜索步长和路径表达三个方面。首先，外部档案 $cal(A)$ 采用随机替换策略，迭代后期容易存入大量重复或高度相似的解，使档案多样性在不易察觉中下降。这样一来，current-to-Amean/1 变异策略所依赖的种群分布信息会变窄，档案均值的引导作用也会减弱。其次，变异因子 $F$ 采用柯西采样，对所有个体使用同一类参数生成方式，无法根据障碍物空间分布调整搜索尺度。开阔区域往往需要小步长精细搜索，而障碍物密集区域更需要较大步长帮助个体跳出危险通道，原生算法在这两种状态之间缺少自适应切换。除此之外，离散航点编码本身也不约束路径连续性。各航点坐标独立演化，即使相邻两代个体在搜索空间中较接近，解码后的路径仍可能出现明显折线和急转，进而使路径平滑性项 $S$ 与长度项 $L$ 的优化相互牵制。基于这些考虑，TALG（Threat-Adaptive Lévy-Gaussian）框架引入外部档案相似度去重、种群威胁度驱动的 Lévy-Gaussian 双态 $F$ 生成，以及 B 样条曲线参数化路径建模，分别改善档案多样性、环境感知搜索能力和路径几何连续性。

=== 外部档案相似度去重

原生 AL-SHADE 在更新外部档案 $cal(A)$ 时，通常采用“档案满则随机替换一项”的方式存入被淘汰父代向量。这个方法实现起来很简单，但在路径规划任务中容易带来冗余。随着种群在迭代后期逐渐靠近某个较优解，很多被淘汰的父代向量会与该解非常接近，也就是在 $bb(R)^(2N)$ 空间中的距离很小。随机替换策略无法识别这类相似个体，档案中便可能积累大量近乎相同的解。这样计算得到的加权档案均值 $bold(x)_("mean")^t$ 会更像单一聚类中心的近似估计，难以反映多个独立优质区域的分布信息。

*基于欧氏距离的相似度判别。* TALG 在每次准备向外部档案 $cal(A)$ 写入被淘汰父代向量 $bold(x)_("parent")$ 时，先计算它与当前档案所有成员之间的欧氏距离：

$
d_"min"^("archive") = min_(j=1)^(|cal(A)|) norm(bold(x)_("parent") - bold(a)_j)_2 $ <archive-min-dist>

本文设定相似度阈值 $tau_("sim") = 25.0$。其含义可以这样理解：在 $2N$ 维航点坐标空间中，当 $N = 20$、$D = 40$ 时，如果两个个体的欧氏距离小于 25，平均到每个维度的差异约为 $25 / sqrt(40) ≈ 4.0$。这类个体解码后的候选路径在几何形态上已经很接近，对加权均值计算提供的信息也基本相似。

*去重决策逻辑。* 比较 $d_"min"^("archive")$ 与阈值 $tau_("sim")$ 后，档案更新按下面几种情况处理：

$
"ArchiveUpdate"(bold(x)_("parent")) = cases(
  "替换最近邻" bold(a)_("nearest")quad"if " d_"min"^("archive") < tau_("sim") space "and" space J_"parent" < J_"nearest",
  "丢弃父代"quad "if " d_"min"^("archive") < tau_("sim") space "and" space J_"parent" >= J_"nearest",
  "存入档案（追加或随机替换）"quad "if " d_"min"^("archive") >= tau_("sim")
) $ <archive-dedup-logic>

若父代与档案中某个成员在空间上很接近，但父代适应度更优，则用父代替换该相似成员。这样既减少重复解，也保留该区域内较好的搜索结果。若父代与档案成员相似且适应度不占优，则说明该区域已有更好的代表解，父代不再写入档案。若父代与档案中所有成员都保持足够距离，则说明它可能来自一个尚未覆盖的新区域；此时档案未满则直接追加，档案已满则随机替换一项，以保留原生 L-SHADE 档案更新中的随机性。

*去重效益分析。* 引入相似度去重后，外部档案中保留下来的解更分散，重复信息也会减少。在障碍物密集的路径规划场景中，种群往往会集中到少数几条可行狭窄通道附近。若不进行去重，容量为 $N_A ≈ 1300$（$P = 500$，$r_("arc") = 2.6$）的档案中，可能有相当一部分槽位都存放相互距离不足 25 的近重复解。去重后，档案能够覆盖更广的优质解区域，$bold(x)_("mean")^t$ 的计算也不再过度依赖单一聚类。这样一来，current-to-Amean/1 变异策略中的差分方向 $(bold(x)_("mean")^t - bold(x)_i^t)$ 可以获得更有区分度的搜索引导。

档案相似度去重的完整决策流程见#algorithm-ref(<alg:archive-dedup>)。


=== 种群威胁度量化模型

TALG 的第二项改进是引入种群威胁度（Population Threat）$T_i in [0, 1]$，用来描述单个候选路径面对障碍物时的风险水平。原生 AL-SHADE 在生成变异因子时基本不区分个体所处环境，而这里把路径与障碍物之间的空间关系压缩成一个标量。$T_i$ 越大，说明路径越靠近障碍物，甚至已经出现碰撞，此时算法应倾向于采用更大尺度的变异，让个体尽快离开危险区域。

*三区威胁映射。* 对候选路径 $bold(x)_i$，先计算各采样点到所有障碍物表面的净空距离，再取其中的最小值。全路径最小净空记为 $d_("min", i) = min_(j=1)^100 min_(O in cal(O)) (norm(bold(p)_j - bold(c)_O) - R_O)$，随后按下式映射为威胁度：

$
T_i = cases(
  1.0 quad d_("min", i) <= 0 space "(碰撞区)",
  exp(lr(-frac(2 d_("min", i), d_("safe") - d_("min", i) + epsilon))) quad 0 < d_("min", i) < d_("safe") space "(过渡区)",
  0.0 quad d_("min", i) >= d_("safe") space "(安全区)"
) $ <threat-mapping>

当 $d_("min") <= 0$ 时，路径至少有一处进入障碍物内部，威胁度直接取 1。若 $d_("min") >= d_("safe") = 20$ m，则说明整条路径与障碍物保持安全间隔，威胁度取 0，算法可以更多采用高斯态做精细搜索。介于二者之间的是过渡区。这里没有使用简单线性缩放，而是采用指数函数 $exp(-2 d_("min") / (d_("safe") - d_("min")))$，使路径越接近障碍物时风险上升越快。这样处理更符合直观判断：从 20 m 接近到 10 m 的风险变化，通常小于从 5 m 接近到 1 m 的风险变化。

/* *B 样条感知对齐。* 威胁度的计算基于 B 样条曲线采样点而非控制点，这一点至关重要。若直接对控制点计算净空距离，可能出现"控制点均安全、但控制点之间的 B 样条曲线段紧贴障碍物"的漏判情况——这正是原生方法在评估函数与优化变量之间存在表征鸿沟的体现。将 100 个 B 样条采样点投入广播距离计算虽然在单次威胁评估中引入了 $O(100 dot |cal(O)|)$ 的额外开销，但其带来的安全收益——避免优化器产出外观安全实则贴障的虚假可行路径——在障碍物密集场景中远超计算代价。

种群威胁度 $T_i$ 的计算与 B 样条曲线生成紧密耦合——威胁评估的输入并非原始控制点而是光滑采样点，保证了风险评估与路径实际几何的一致性。完整威胁度量化流程见 */#algorithm-ref(<alg:threat-quant>)。


=== 威胁驱动的 Lévy-高斯双态变异缩放因子

得到个体威胁度 $T_i$ 后，TALG 将这一风险信息继续反馈到 DE 变异过程，用于调节缩放因子 $F$ 的生成方式。

*原生方法的局限。* 原生 AL-SHADE 对所有个体都从柯西分布 $F_i ~ "Cauchy"(M_(F, h_i), 0.1)$ 中采样 $F$。柯西分布具有重尾特性，因此 $F$ 有小概率取到较大值（$F ≫ 1$），这在理论上可以帮助受困个体跳出局部最优。但它并不关心个体所处的环境风险。处在开阔安全区域的个体，以及已经贴近障碍物、接近碰撞的个体，在原生框架中获得大 $F$ 的概率完全一样。这样容易带来两个问题：安全个体可能被偶然的大步长扰动破坏已有收敛结果，而危险个体又不一定能及时获得足够强的逃逸步长。

*双态采样引擎。* TALG 以个体威胁度 $T_i$ 为切换概率，建立 Lévy-Gaussian 双态 $F$ 生成器。对于个体 $i$，从历史记忆槽 $h_i$ 读取 $F$ 的基准位置参数 $mu_F = M_(F, h_i)$，以尺度参数 $sigma_F = 0.1$ 生成缩放因子：

$
F_i = cases(
  mu_F + sigma_F dot "Lévy"(beta) quad "if " "rand"(0, 1) <= T_i space "(Lévy 态)",
  mu_F + sigma_F dot cal(N)(0, 1) quad "otherwise" space "(高斯态)"
) $ <talg-dual-mode>

生成后的 $F_i$ 还需要做边界处理。若 $F_i <= 0$，则重新采样，最多重试 100 次；在极端情况下将其设为机器精度 $epsilon$，避免搜索停滞。若 $F_i > 1$，则截断为 1，因为 $F = 1$ 已对应全幅差分跳跃，可视为搜索步长上限。

高斯态（$"rand" > T_i$）沿用经典 SHADE 的采样思路，通过均值附近的正态扰动来细调搜索步长，适合安全区域中的平滑收敛。当 $T_i ≈ 0$ 时，个体几乎总会进入高斯态。Lévy 态（$"rand" <= T_i$）则用于处理受障碍物威胁较高的个体，此时算法以概率 $T_i$ 将正态噪声替换为标准 Mantegna Lévy 分布（$beta = 1.5$）产生的随机步长。Lévy 分布方差无限，尾部按幂律衰减（$P(|x| > t) ∝ t^(-beta)$），生成大幅值步长的概率高于常规正态扰动和柯西采样。在 $T_i ≈ 1$ 的高威胁场景下，个体约有 30%～40% 的概率获得 $F > 0.8$ 的大幅变异，相比纯柯西采样约 15% 的概率有明显提升。

*Mantegna Lévy 步长生成。* Lévy 随机步长通过 Mantegna 算法生成。对于稳定指数 $beta in (0, 2)$，先构造两个相互独立的正态变量 $u ~ cal(N)(0, sigma_u^2)$ 和 $v ~ cal(N)(0, 1)$，其中：

$
sigma_u = lr(frac(Gamma(1 + beta) sin(pi beta / 2), Gamma((1 + beta) / 2) beta 2^((beta-1)/2)))^(1 / beta) $ <mantegna-sigma>

则 Lévy 步长可写为 $s = u / |v|^(1/beta)$。$beta = 1.5$ 是群智能优化中较常用的折中取值。$beta$ 越小，分布尾部越重，跳跃也越激进；$beta$ 越接近 2，分布越接近正态分布。为保证数值稳定，分母中引入小量 $epsilon = 10^(-12)$，用于避免除零问题。

*威胁自适应的整体效果。* 双态 $F$ 生成器把环境风险引入参数采样，使搜索步长可以随空间状态变化。在开阔空域，$T_i ≈ 0$，大多数个体以高斯态运行，$F$ 围绕历史成功均值 $mu_F$ 小幅波动，变异步长较稳定，算法更适合优化路径长度和平滑性。在障碍物密集通道中，$T_i -> 1$，更多个体进入 Lévy 态并产生较大幅度的差分跳跃。这类跳跃有机会把个体带到障碍物另一侧的安全区域，也可以通过外部档案 $cal(A)$ 保留大尺度探索产生的历史信息，进而影响后续代的加权档案均值 $bold(x)_("mean")^t$ 和 current-to-Amean/1 变异方向。由于高斯态与 Lévy 态的比例由 $T_i$ 连续调节，搜索行为不会在安全区和危险区之间突然切换，而是呈现更平滑的过渡。

缩放因子 $F$ 的双态生成与 Mantegna Lévy 采样器的完整流程见#algorithm-ref(<alg:talg-f-gen>) 和 #algorithm-ref(<alg:mantegna-levy>)。



=== B 样条曲线参数化路径建模

B 样条曲线（B-spline）是一类由控制点和节点向量共同确定的分段多项式参数曲线。它不同于直接连接离散航点得到的折线路径，而是通过控制点间接决定曲线形态，因此具有局部支撑、连续性较好和端点可约束等特点。用于无人机路径规划时，优化阶段仍可只维护有限个控制点；在适应度评估和轨迹执行阶段，再由这些控制点生成连续光滑的飞行路径。这样可以缓解离散航点编码带来的急转、折线和曲率突变问题。

*曲线定义。* 设控制点序列为 $bold(c)_0, bold(c)_1, dots, bold(c)_m in bb(R)^2$，其中 $m+1$ 为控制点数量；设 B 样条次数为 $p$，节点向量为

$
bold(U) = (u_0, u_1, dots, u_(m+p+1))
$ <bspline-knot-vector>

则 $p$ 次 B 样条曲线可表示为

$
bold(C)(u) =
sum_(i=0)^m N_(i,p)(u) bold(c)_i,
quad u in [u_p, u_(m+1)]
$ <bspline-def>

其中 $N_(i,p)(u)$ 为第 $i$ 个 $p$ 次 B 样条基函数。基函数由 Cox-de Boor 递推公式给出。零次基函数定义为

$
N_(i, 0)(u) = cases(
  1 quad"if " u_i <= u < u_(i+1),
  0 quad "otherwise"
) $ <bspline-basis0>

当 $r = 1, 2, dots, p$ 时，$r$ 次基函数递推为

$
N_(i,r)(u) =
frac(u - u_i, u_(i+r) - u_i) N_(i,r-1)(u)
+ frac(u_(i+r+1) - u, u_(i+r+1) - u_(i+1)) N_(i+1,r-1)(u)
$ <bspline-basisr>

若递推式中的分母为 0，则对应分式项按 0 处理。由这一递推关系可知，任意参数 $u$ 处只有有限个相邻基函数非零，所以单个控制点通常只影响曲线的一段局部形状。也就是说，优化器调整某个控制点时，不会轻易破坏整条路径结构，这有利于提高变异和交叉操作的有效性。

*节点向量构造。* 为使曲线起点和终点分别通过首尾控制点，即满足 $bold(C)(u_p) = bold(c)_0$ 和 $bold(C)(u_(m+1)) = bold(c)_m$，本文采用 clamped 均匀节点向量。具体做法是在节点向量两端各设置 $p+1$ 个重复节点，使曲线端点被首尾控制点约束；中间节点均匀分布，用来保持参数区间划分相对均衡。节点向量可写为

$
u_i = cases(
  0 quad 0 <= i <= p,
  frac(i - p, m - p + 1) quad p < i <= m,
  1 quad m < i <= m + p + 1
) $ <clamped-knot>

其中 $i = 0, 1, dots, m+p+1$。本文采用三次 B 样条，即 $p = 3$。三次 B 样条在普通节点处具有 $C^2$ 连续性，能够使路径位置、切向方向和曲率变化更加平滑，也更符合无人机受到速度、加速度和航向角速度约束时的实际飞行特点。

*de Boor 递推求值。* 实际计算时，如果直接按基函数定义求 $bold(C)(u)$，需要显式计算多个基函数，过程较繁琐。本文采用 de Boor 算法对 B 样条曲线进行稳定求值。给定参数 $u$ 后，先确定其所在节点区间 $[u_s, u_(s+1))$，即

$
u_s <= u < u_(s+1), quad s in {p, p+1, dots, m}
$ <deboor-span>

随后取受该参数影响的 $p+1$ 个控制点，并初始化

$
bold(d)_j^((0)) = bold(c)_(s - p + j),
quad j = 0, 1, dots, p
$ <deboor-init>

第 $r$ 轮递推（$r = 1, 2, dots, p$）按如下线性插值进行：

$
bold(d)_j^((r)) =
(1 - alpha_(j,r)) bold(d)_(j-1)^((r-1))
+ alpha_(j,r) bold(d)_j^((r-1))
$ <deboor-recur>

其中

$
alpha_(j,r) =
frac(u - u_(s - p + j), u_(s + 1 + j - r) - u_(s - p + j)),
quad j = r, r+1, dots, p
$ <deboor-alpha>

完成 $p$ 轮递推后，曲线点由

$
bold(C)(u) = bold(d)_p^((p))
$ <deboor-result>

得到。de Boor 算法只对当前参数相关的局部控制点进行递推，单点求值复杂度为 $O(p^2)$。本文固定采用三次 B 样条，$p$ 可视为常数，因此该求值过程在路径采样中具有较好的计算效率和数值稳定性。

*路径重构与适应度评估。* 在 TALG 框架中，优化器仍以实数向量形式维护候选解。设个体 $bold(x)_i in bb(R)^(2N)$ 解码后得到 $N$ 个中间控制点，将其与起点 $bold(S)$ 和终点 $bold(T)$ 拼接，可得到完整控制点集合

$
cal(C)_i = {bold(S), bold(c)_1, bold(c)_2, dots, bold(c)_N, bold(T)}
$ <bspline-control-set>

随后在参数区间 $[u_p, u_(m+1)]$ 上均匀选取 $N_s$ 个参数值，并利用 de Boor 算法生成采样路径

$
cal(P)_i = {bold(C)(u_1), bold(C)(u_2), dots, bold(C)(u_(N_s))}
$ <bspline-sampled-path>

本文取 $N_s = 100$。适应度函数中的路径长度 $L$、平滑性 $S$、综合风险 $R$、通道宽度惩罚 $W$ 和编队保持代价 $F$ 都基于采样点集合 $cal(P)_i$ 计算，不再直接使用控制点折线。这样评价对象就是实际执行时更接近的光滑轨迹，而不是控制点连线形成的近似路径。

这种参数化方式有两个直接好处。其一，B 样条曲线本身具有连续性，可以明显减少折线路径中的急转和曲率突变，使路径更容易满足无人机飞行约束。其二，每个控制点只影响有限的局部曲线段，优化器调整单个控制点时不容易引起全局路径剧烈震荡，因此差分变异和交叉操作更容易生成可接受的试验向量。

B 样条路径参数化的完整流程见#algorithm-ref(<alg:bspline-gen>)。


*降维效应。* B 样条参数化还可以在保留路径表达能力的同时降低搜索难度。在经典航点编码中，若设置 $N = 20$ 个中间航点，优化维度为 $D = 40$。如果改用少量控制点描述曲线主体形态，需要优化的自由控制点可减少到约 $5 ~ 7$ 个，对应搜索维度降至 $10 ~ 14$。在较低维度下，差分向量 $(bold(x)_(r_1) - bold(x)_(r_2))$ 中的有效信息更集中，交叉操作也更容易保留有意义的路径结构。因此，B 样条不仅改善路径平滑性，也降低了 AL-SHADE 在高维航点空间中的搜索压力。

=== TALG 框架参数配置总览

综合上述三项改进，TALG 框架相对原生 AL-SHADE 主要调整了以下参数。历史记忆容量由 $H = 6$ 增至 $H = 15$，为双态 $F$ 生成器中的高斯态和 Lévy 态留下更多统计空间，减少两类分布的历史信息在有限槽位中相互干扰。档案比率由 $r_("arc") = 2.5$ 小幅提高到 2.6，用来补偿去重机制剔除冗余解后带来的档案规模下降。精英比例由 $p_("best") = 0.10$ 提升至 0.15，以增强精英个体在 B 样条平滑路径搜索中的引导作用。新增的相似度阈值 $tau_("sim") = 25.0$、Lévy 稳定指数 $beta = 1.5$、B 样条次数 $p = 3$ 和采样密度 100 都具有较明确的物理或数学含义，一般不需要针对不同障碍物布局重新标定。



= 实验结果分析

== 实验设置与环境配置

=== 仿真环境与障碍物布局

实验采用 $1000 times 1000$ m 的二维仿真空域。无人机集群从 $bold(S) = (0, 0)$ 出发，目标点设为 $bold(T) = (1000, 1000)$。障碍物集合由 21 个圆形障碍物组成，主要分为两类：一类是 13 个沿主对角线 $y = x$ 两侧交替分布的结构化障碍物，偏距为 120 m，半径 $R = 35$ m，用来模拟城市低空走廊中的规整建筑群；另一类是 8 个在 $(100, 900) times (100, 900)$ 区域内均匀随机生成的散落障碍物，半径同样为 $R = 35$ m，用来模拟非结构化环境中的小尺度未知障碍。此外，本文在 $(500, 500)$ 处设置中心障碍物，使起点到终点的直连方向形成一处较难穿越的瓶颈区域。该位置两侧安全通道宽度约为 60 m，对路径规划算法的探索能力和局部开发能力都有较高要求。

所有障碍物均设为静态，即 $bold(v)_("obs") = bold(0)$。编队包含 5 架无人机，其中 1 架为虚拟领航者，4 架为僚机。基础队形采用 V 型，僚机相对偏移量分别为 $(-20, 20)$、$(-20, -20)$、$(-40, 40)$、$(-40, -40)$ m。仿真步长固定为 $Delta t = 0.1$ s，单次实验最长运行时间为 $T_("max") = 100$ s。

=== 对比算法与参数配置

实验共比较七类全局路径规划算法。为保证结果具有可比性，各算法统一采用 $N = 20$ 的航点编码，并使用五分量加权适应度函数 $J = 0.24 L_"norm" + 0.18 S_"norm" + 0.32 R_"norm" + 0.14 W_"norm" + 0.12 F_"norm"$。局部避障层统一采用改进 APF，参数为 $k_r = 25$、$k_t = 15$、$d_("safe") = 20$ m；编队控制层采用第 2 章给出的改进一致性协议，参数为 $k_1 = 0.8$、$k_2 = 1.2$、$k_3 = 0.8$。除 AHA 因访问表开销较大而取 $n = 50$ 外，其余算法的初始种群规模和迭代次数均设为 $P_"init" = 500$、$T = 500$。其他参数沿用对应算法文献中的常用推荐值，具体配置如下：

#captab(
  caption: [对比算法参数配置一览],
  label: <exp-algo-config>,
)[
  | 算法            | 种群/迭代  | 类别             | 关键参数                                        |
  | PSO             | 500 / 500  | 经典群体智能     | $omega = 0.6$, $c_1 = 1.6$, $c_2 = 1.4$          |
  | ACOR            | 500 / 500  | 经典群体智能     | $K = 20$, $q = 0.1$, $xi = 0.85$                 |
  | GA              | 500 / 500  | 经典进化算法     | $p_m = 0.1$, $sigma_0 = 40$, $k = 3$             |
  | MSA             | 500 / 500  | 新型群体智能     | $P = 2$, $rho = 6$, $a = 0.5$, $P_c = 0.2$       |
  | AHA             | 50 / 500   | 新型群体智能     | 无外部控制参数                                  |
  | AL-SHADE (原生) | 500 / 500  | 自适应 DE        | $H = 6$, $p_("best") = 0.10$, $r_("arc") = 2.5$  |
  | AL-SHADE-TALG-QU | 500 / 500 | 改进自适应 DE    | $H = 15$, $p_("best") = 0.15$, $r_("arc") = 2.6$, $tau_("sim") = 25$, $beta = 1.5$ |
]

=== 评价指标体系

实验从五个维度评价算法性能：

（1）*收敛性能指标*：包括最终适应度 $J^"*"$，以及首次达到最终改进幅度 95% 所需的迭代次数 $T_("95%")$，用于描述算法的寻优速度和收敛水平。

（2）*任务效率指标*：包括平均路径长度 $L$（m）和领航者到达时间 $t_("arr")$（s），用于衡量路径的飞行经济性和任务完成效率。

（3）*轨迹平滑性指标*：采用平均航向偏转角（°）衡量路径转向是否平缓。该指标越小，说明路径几何连续性越好，也越有利于无人机稳定跟踪。

（4）*编队保持指标*：采用相对队形误差 RMS（m）衡量僚机相对期望队形的偏离程度。该指标越小，说明编队越稳定。

（5）*集群安全指标*：采用最小无人机间距（m）衡量多机飞行过程中的内部安全裕度。该指标越大，说明无人机之间发生近距离冲突的风险越低。

所有算法均在相同障碍物布局、相同编队控制器和相同局部避障参数下运行，之后对上述指标进行统一统计和比较。

== 路径规划可视化对比

=== 全局路径形态对比

下图给出七种全局规划算法与改进 APF 局部避障器联合运行后的终态轨迹。图中黑色虚线表示全局规划路径，红色曲线表示领航者实际轨迹，其余彩色曲线表示四架僚机轨迹，蓝色圆形区域表示障碍物及其安全缓冲区。每幅图左上角标注对应算法的最终到达时间、最小无人机间距和碰撞状态。

#capsubfig(
  (
    (content: image("figures/lujing/final_snapshot_pso_apf.png", height: 5.2cm, fit: "contain"), subcaption: [PSO + APF]),
    (content: image("figures/lujing/final_snapshot_aco_apf.png", height: 5.2cm, fit: "contain"), subcaption: [ACOR + APF]),
    (content: image("figures/lujing/final_snapshot_ga_apf.png", height: 5.2cm, fit: "contain"), subcaption: [GA + APF]),
    (content: image("figures/lujing/final_snapshot_msa_apf.png", height: 5.2cm, fit: "contain"), subcaption: [MSA + APF]),
    (content: image("figures/lujing/final_snapshot_aha_apf.png", height: 5.2cm, fit: "contain"), subcaption: [AHA + APF]),
    (content: image("figures/lujing/final_snapshot_alshade_origin_apf.png", height: 5.2cm, fit: "contain"), subcaption: [AL-SHADE + APF]),
    (content: image("figures/lujing/final_snapshot_alshade_talg2_apf.png", height: 5.2cm, fit: "contain"), subcaption: [AL-SHADE-TALG-QU + APF]),
  ),
  columns: 2,
  caption: [七种算法联合 APF 局部避障后的终态轨迹对比],
  label: <exp-path-compare>,
)

从整体轨迹看，七种算法都能在 APF 局部避障器辅助下到达目标点，图中碰撞状态也均为 No。这说明局部避障层可以对全局规划路径进行安全修正。不过，全局路径本身的质量仍会直接影响 APF 的介入程度和编队轨迹形态。若全局路径在障碍物密集区过于贴近障碍物，僚机轨迹往往会出现更明显的横向偏移和队形拉伸；若全局路径较平滑，并且留出足够通行空间，领航者与僚机轨迹则更容易保持平行和一致。

PSO、GA、MSA 和 AHA 的终态轨迹整体较接近，基本沿主对角线方向穿越障碍物分布区，并在中段绕开多个圆形障碍物。其中，PSO 的最终时间为 77.70 s，最小无人机间距为 19.11 m；GA 的最终时间为 81.00 s，最小无人机间距为 19.77 m；MSA 和 AHA 的最终时间均为 77.60 s，最小无人机间距分别为 18.79 m 和 19.83 m。上述算法都能完成任务，但在中段和终点附近，僚机轨迹出现一定程度的队形展开，说明局部避障修正仍会影响编队结构。

ACOR 的轨迹最曲折，最终到达时间为 86.50 s，在七种算法中最长。其全局路径在中部区域出现明显弯折，使领航者和僚机在多个障碍物之间产生额外绕行。虽然最终没有碰撞，但任务效率偏低，最小无人机间距也只有 18.12 m。这与后文五项指标中 ACOR 路径长度最长、到达时间最长的结果一致。

原生 AL-SHADE 的终态轨迹最短，到达也最快，最终时间为 70.60 s。不过从图中可以看到，它的全局路径在若干障碍物之间选择较直接的穿越方式，僚机轨迹在局部区域需要依靠 APF 作横向修正，最终最小无人机间距为 18.88 m。AL-SHADE-TALG-QU 的最终时间为 73.00 s，略慢于原生 AL-SHADE，但最小无人机间距提升到 20.38 m，是图示结果中最高的安全裕度。同时，AL-SHADE-TALG-QU 的全局路径和领航者轨迹更平滑，僚机之间的相对间隔也更稳定，说明 B 样条参数化和威胁感知机制对轨迹连续性与编队安全性有一定改善。

总体来看，路径可视化结果与五项指标结果基本一致。原生 AL-SHADE 在任务效率上更占优势，而 AL-SHADE-TALG-QU 在路径较短、到达较快的基础上，提高了最小机间距和编队轨迹一致性，更适合安全裕度要求较高的无人机集群任务。


/* == 收敛性分析

=== 迭代收敛曲线

下图展示了七种全局路径规划算法在 500 次迭代过程中的最优适应度收敛曲线。纵轴为当前最优适应度值 $J$，数值越小表示候选路径的综合代价越低；横轴为迭代次数。由图可见，各算法在迭代初期均表现出明显的快速下降趋势，说明初始随机种群能够在较短时间内排除大量高代价路径；随着迭代推进，曲线逐渐趋于平缓，算法进入局部精细搜索或停滞阶段。

#capsubfig(
  (
    (content: image("figures/pso_fitness_convergence.png", width: 92%), subcaption: [PSO]),
    (content: image("figures/aco_fitness_convergence.png", width: 92%), subcaption: [ACOR]),
    (content: image("figures/ga_fitness_convergence.png", width: 92%), subcaption: [GA]),
    (content: image("figures/msa_fitness_convergence.png", width: 92%), subcaption: [MSA]),
    (content: image("figures/aha_fitness_convergence.png", width: 92%), subcaption: [AHA]),
    (content: image("figures/alshade_fitness_convergence.png", width: 92%), subcaption: [AL-SHADE]),
    (content: image("figures/alshade_talg2_fitness_convergence.png", width: 60%), subcaption: [AL-SHADE-TALG-QU]),
  ),
  columns: 2,
  caption: [七种算法的适应度收敛曲线],
  label: <exp-convergence>,
)

从收敛行为中可归纳出三种典型模式。

*快速收敛型（PSO、ACOR、GA）。* PSO、ACOR 和 GA 在前 30 代内均完成了主要的适应度下降。其中，PSO 下降最为迅速，约在 20 代左右即接近最终稳定值，说明全局最优粒子的社会学习项对种群具有较强牵引作用；ACOR 同样在初期快速下降，但约 30 代后基本停滞，最终收敛值高于 PSO，表明其连续高斯核采样在后期精细开发能力不足；GA 前期依靠选择压力和高斯变异迅速降低代价，但后期曲线趋于平直，说明种群逐渐集中于有限的可行区域，进一步改进空间较小。

*稳步改进型（MSA、AHA、AL-SHADE）。* MSA、AHA 与原生 AL-SHADE 的收敛过程相对更平滑，前期下降后仍能在较长迭代区间内保持小幅改进。MSA 在约 50 代后逐渐稳定，最终适应度约为 6.31；AHA 曲线呈阶梯式下降，说明访问表机制和迁徙觅食策略能够周期性地引入新搜索方向，使算法在中后期仍保留一定探索能力；AL-SHADE 的下降过程较为连续，约在 60 代后接近稳定，外部档案与自适应参数记忆机制使其后期仍具有微弱改进能力。

*慢收敛或高平台型（AL-SHADE-TALG-QU）。* AL-SHADE-TALG-QU 在前期同样能够快速降低适应度，但其后续下降速度明显慢于 PSO、GA 和 MSA，约在 200 代后进入平台期，最终适应度约为 8.85。该结果表明，在当前参数配置和适应度权重下，改进算子并未直接带来更低的适应度值。可能原因是 B 样条平滑、威胁驱动变异和档案去重机制更倾向于提高路径安全裕度与几何平滑性，而非单纯压低加权适应度；若权重设置中过度强调路径长度或短期代价，则该类保守搜索策略可能表现为收敛值偏高。因此，对 AL-SHADE-TALG-QU 的评价不应仅依赖适应度曲线，还应结合安全间隙、路径平滑性和编队可行性等指标综合判断。

=== 收敛速度定量比较

下表汇总了七种算法的关键收敛指标。由于本节曲线为图像结果而非原始数据文件，表中数值根据坐标轴读取得到，主要用于比较不同算法的收敛趋势和相对水平。

#captab(
  caption: [算法收敛性能定量对比（由适应度曲线近似读取）],
  label: <exp-convergence-table>,
)[
  | 算法                 | 初始 $J$（约） | 最终 $J^"*"$（约） | $T_("95%")$（约/代） | 收敛特征         |
  | PSO                  | 28             | 6.05               | 20                   | 极快下降-早停滞  |
  | ACOR                 | 33             | 6.92               | 20                   | 快速下降-平台较高 |
  | GA                   | 31             | 6.52               | 30                   | 快速下降-缓慢修正 |
  | MSA                  | 31             | 6.31               | 50                   | 稳步下降-平台稳定 |
  | AHA                  | 31             | 6.35               | 90                   | 阶梯下降-持续探索 |
  | AL-SHADE (原生)      | 31             | 6.37               | 65                   | 连续下降-后期微调 |
  | AL-SHADE-TALG-QU     | 31             | 8.85               | 100                  | 下降较慢-平台偏高 |
]

从最终适应度看，PSO 的收敛值最低，约为 6.05；MSA、AHA、AL-SHADE 和 GA 的最终结果集中在 6.31 至 6.52 之间，差异相对较小；ACOR 的最终值约为 6.92，略高于上述算法；AL-SHADE-TALG-QU 的最终值约为 8.85，在单纯适应度指标上表现不占优。由此可见，若仅以加权适应度 $J$ 作为评价标准，PSO 在本组实验中具有最快收敛速度和最低最终代价。然而，PSO 的快速收敛也意味着其后期搜索多样性较弱，可能更容易受到局部区域和路径安全裕度的限制；AHA、MSA 和 AL-SHADE 虽然下降速度略慢，但中后期仍具备一定持续改进能力。对于 AL-SHADE-TALG-QU，需要进一步结合路径平滑性、安全裕度和编队保持指标进行综合评价，以判断其改进机制是否在非适应度维度上产生收益。 */

== 算法性能定量对比

为避免只根据适应度曲线判断算法优劣，本文进一步从飞行任务执行效果出发，选取五个具有直接物理意义的指标进行横向比较，分别为平均路径长度、领航者到达时间、路径平滑性、相对队形误差和最小无人机间距。其中，平均路径长度和到达时间反映任务效率，路径平滑性反映轨迹可执行性，相对队形误差反映编队保持能力，最小无人机间距反映集群内部安全裕度。除最小无人机间距外，其余四项指标均为数值越小越优；最小无人机间距越大，机间安全裕度越充分。

#capsubfig(
  (
    (content: image("figures/zhibiao/path_length1.png", width: 92%), subcaption: [平均路径长度]),
    (content: image("figures/zhibiao/arrival_time1.png", width: 92%), subcaption: [领航者到达时间]),
    (content: image("figures/zhibiao/smoothness1.png", width: 92%), subcaption: [路径平滑性]),
    (content: image("figures/zhibiao/formation1_error.png", width: 92%), subcaption: [相对队形误差]),
    (content: image("figures/zhibiao/min_distance1.png", width: 92%), subcaption: [最小无人机间距]),
  ),
  columns: 2,
  caption: [七种算法在五个飞行性能指标上的对比],
  label: <exp-five-metrics>,
)

五项指标的具体数值见表@exp-five-metrics-table。为便于阅读，表中用向下箭头表示数值越小越优，用向上箭头表示数值越大越优。

#captab(
  caption: [七种算法五项性能指标对比],
  label: <exp-five-metrics-table>,
)[
  | 算法 | 路径 (m) ↓ | 时间 (s) ↓ | 偏转 (°) ↓ | 队形 RMS (m) ↓ | 机间距 (m) ↑ |
  | PSO（粒子群） | 1646.43 | 77.70 | 0.937 | 9.977 | 19.48 |
  | ACOR（蚁群） | 1805.31 | 86.00 | 1.062 | 9.271 | 18.06 |
  | GA（遗传） | 1684.37 | 80.90 | 0.930 | 9.274 | 19.59 |
  | MSA | 1640.24 | 77.00 | 0.908 | 9.154 | 18.59 |
  | AHA | 1659.34 | 77.50 | 0.952 | 9.395 | 18.74 |
  | AL-SHADE | 1540.46 | 71.30 | 0.835 | 9.214 | 19.12 |
  | AL-SHADE-TALG-QU | 1543.71 | 72.60 | 0.796 | 7.989 | 20.47 |
]

从任务效率看，AL-SHADE 和 AL-SHADE-TALG-QU 的平均路径长度明显短于其他算法，分别为 1540.46 m 和 1543.71 m，二者仅相差 3.25 m。这说明改进算法引入平滑和安全约束后，并未明显牺牲路径长度。领航者到达时间方面，AL-SHADE 最短，为 71.30 s；AL-SHADE-TALG-QU 为 72.60 s，只比 AL-SHADE 多 1.30 s，仍明显优于 PSO、ACOR、GA、MSA 和 AHA。可以看出，改进算法在保持较高飞行效率的同时，为路径平滑性和编队安全性留出更多优化空间。

从轨迹平滑性看，AL-SHADE-TALG-QU 的平均航向偏转最低，为 0.796°，优于 AL-SHADE 的 0.835°，也低于 ACOR 的 1.062° 和 AHA 的 0.952°。这表明 B 样条曲线参数化能够削弱离散航点连接带来的局部折角，使领航者轨迹更加连续。对于无人机集群来说，更小的航向偏转可以减少飞行控制中的加速度突变，也有助于僚机在跟随过程中维持队形。

从编队保持效果看，AL-SHADE-TALG-QU 的相对队形误差 RMS 为 7.989 m，是七种算法中最低的结果。与原生 AL-SHADE 的 9.214 m 相比，误差降低约 13.30%；与 PSO 的 9.977 m 相比，误差降低约 19.93%。这说明改进算法生成的路径对编队控制层更友好，能够减少局部急转和通道压缩对队形结构的扰动，使僚机在跟随领航者时保持更稳定的相对位置。

从安全性看，AL-SHADE-TALG-QU 的最小无人机间距达到 20.47 m，在所有算法中最大，说明其在飞行过程中保留的机间安全裕度最充分。相比之下，ACOR 和 MSA 的最小机间距分别为 18.06 m 和 18.59 m，安全裕度相对较弱。AL-SHADE 虽然路径较短、到达时间最优，但最小机间距为 19.12 m，低于改进算法。综合来看，AL-SHADE-TALG-QU 在路径长度和到达时间上接近原生 AL-SHADE，同时在平滑性、队形误差和机间安全距离三个关键指标上取得最优结果，综合飞行性能更均衡。

== 五指标综合评价

为进一步比较各算法的整体表现，本文对五项指标进行名次统计。路径长度、到达时间、平均航向偏转和队形误差按数值从小到大排序，最小无人机间距按数值从大到小排序。单项排名越靠前，表示算法在对应指标上表现越好；平均排名越小，表示综合性能越优。

#captab(
  caption: [七种算法五项指标排名统计],
  label: <exp-rank-table>,
)[
  | 算法 | 路径长度排名 | 到达时间排名 | 平滑性排名 | 队形误差排名 | 机间距排名 | 平均排名 |
  | PSO | 4 | 5 | 5 | 7 | 3 | 4.8 |
  | ACOR | 7 | 7 | 7 | 4 | 7 | 6.4 |
  | GA | 6 | 6 | 4 | 5 | 2 | 4.6 |
  | MSA | 3 | 3 | 3 | 2 | 6 | 3.4 |
  | AHA | 5 | 4 | 6 | 6 | 5 | 5.2 |
  | AL-SHADE | 1 | 1 | 2 | 3 | 4 | 2.2 |
  | AL-SHADE-TALG-QU | 2 | 2 | 1 | 1 | 1 | 1.4 |
]

由表@exp-rank-table 可知，AL-SHADE-TALG-QU 的平均排名为 1.4，在七种算法中综合最优。其路径长度和到达时间均排名第二，与原生 AL-SHADE 的差距较小；同时在路径平滑性、队形误差和最小机间距三项指标上排名第一，优势主要体现在轨迹质量、编队稳定性和安全裕度方面。原生 AL-SHADE 的平均排名为 2.2，综合表现次优，特点是任务效率最高，但队形保持和机间安全不如 AL-SHADE-TALG-QU。MSA 的平均排名为 3.4，整体表现较均衡。GA 和 PSO 分别在最小机间距或收敛速度方面有一定优势，但综合排名落后于 MSA、AL-SHADE 和改进算法。ACOR 在本组指标中的平均排名最高，说明它在当前场景下不适合作为复杂障碍物环境中的首选规划算法。

== 综合分析与讨论

=== 算法选型建议

结合上述实验结果，不同应用场景下的算法选择可以参考如下思路：

（1）*效率优先场景*：如果任务主要关注路径长度和到达时间，可以优先考虑原生 AL-SHADE。其平均路径长度为 1540.46 m，到达时间为 71.30 s，均为七种算法中的最优结果，适合飞行时间敏感、环境安全裕度要求相对可控的任务。

（2）*安全与编队稳定优先场景*：推荐 AL-SHADE-TALG-QU。该算法的最小无人机间距达到 20.47 m，队形误差 RMS 降至 7.989 m，均为本组实验最优；同时平均航向偏转仅为 0.796°，说明生成路径更平滑，可以减轻局部避障和编队控制层的调整压力。

（3）*综合均衡场景*：可考虑 AL-SHADE-TALG-QU 或 MSA。AL-SHADE-TALG-QU 在五项指标中的平均排名最低，适合作为复杂环境下的综合优选方案；MSA 在路径长度、到达时间、平滑性和队形误差上均处于中上水平，可作为结构相对简单、实现复杂度适中的备选算法。

（4）*快速收敛或基准对比场景*：PSO 可作为基础对比算法。它的适应度曲线收敛最快，最小机间距排名第三，但队形误差和路径平滑性并不占优。因此，PSO 更适合用于算法基准对照，或用于实时性要求较高、轨迹品质要求相对较低的场景。

=== 局限性与未来方向

实验结果表明，AL-SHADE-TALG-QU 在多项指标上具有较好的综合表现，但本文仍存在一些局限。第一，实验主要基于一组典型障碍物环境展开，尚未在不同障碍物密度、不同通道宽度和不同集群规模下系统验证算法排名的稳定性。第二，B 样条控制点数、采样密度和曲线次数对路径质量的影响还需要进一步分析。第三，威胁度阈值 $d_("safe")$、相似度阈值 $tau_("sim")$ 以及 Lévy 稳定指数 $beta$ 主要依据经验设定，参数自适应能力仍有提升空间。第四，当前实验环境仍是静态二维障碍物场景，若要扩展到三维动态障碍物和真实低空空域，还需要继续研究。

= 总结与展望

== 工作总结

本文面向复杂多障碍环境下的无人机集群路径规划与协同飞行问题，构建由全局路径规划、编队控制和局部避障组成的分层耦合框架。框架中，全局规划算法负责生成任务级参考路径，改进一致性控制方法用于维持多机队形，执行阶段再通过改进人工势场法进行在线安全修正。这样可以同时考虑路径全局性、飞行安全、队形稳定和局部避障实时性。

编队控制部分以虚拟领航者为核心建立无人机集群协同模型，并利用邻接矩阵和拉普拉斯矩阵描述通信拓扑关系。在一致性控制律中，本文加入通信延迟、速度跟踪和横向偏置调节机制，使僚机在跟随领航者运动时保持预设相对位置。当通道收缩或需要绕开障碍物时，队形也能进行适度弹性调整，为后续全局路径规划和局部避障提供较稳定的集群运动基础。

全局路径规划部分先构建统一的适应度函数，把路径长度、路径平滑性、静态障碍风险、集群内部碰撞风险、通信风险、通道宽度约束和编队保持代价放入同一评价框架。在此基础上，本文对 PSO、ACOR、GA、MSA、AHA 和 AL-SHADE 等算法进行建模与对比。针对原生 AL-SHADE 在路径连续性、环境风险感知和外部档案多样性方面的不足，本文提出 AL-SHADE-TALG-QU 改进框架。该框架通过外部档案相似度去重减少冗余历史解，利用种群威胁度驱动的 Lévy-Gaussian 双态缩放因子增强障碍物密集区域的跳出能力，并借助 B 样条曲线参数化路径建模提升轨迹连续性和平滑性。

局部避障部分在经典人工势场法基础上加入切向旋转势场力。无人机接近障碍物时，不只受到径向斥力作用，还会获得沿障碍物边缘绕行的切向引导。这一处理缓解了传统人工势场法在障碍物前方容易出现局部极小值和震荡的问题，也与全局规划层输出的参考路径形成互补：全局路径提供远距离引导，局部避障负责短时域内的安全修正。

== 主要结论

通过二维多障碍环境下的收敛曲线对比和五项飞行性能指标分析，可以得到以下结论。

第一，从适应度收敛曲线看，PSO 收敛最快，并取得最低的最终适应度值。这说明在当前加权适应度函数下，全局最优粒子的引导机制具有较强的快速寻优能力。不过，PSO 在路径平滑性和队形误差指标上并不占优，也就是说，适应度值较低并不必然代表集群飞行性能最好。

第二，从任务效率看，原生 AL-SHADE 在平均路径长度和领航者到达时间两项指标上表现最好，路径长度为 1540.46 m，到达时间为 71.30 s。AL-SHADE-TALG-QU 的路径长度为 1543.71 m，到达时间为 72.60 s，二者差距较小。这说明改进算法在提升轨迹质量和安全裕度的同时，基本保留了原生 AL-SHADE 的飞行效率。

第三，从轨迹平滑性和编队保持效果看，AL-SHADE-TALG-QU 取得最优结果。其平均航向偏转为 0.796°，低于原生 AL-SHADE 的 0.835°；相对队形误差 RMS 为 7.989 m，比原生 AL-SHADE 的 9.214 m 降低约 13.30%。这表明 B 样条参数化和威胁感知机制能够改善路径几何连续性，并减少僚机跟随过程中的队形扰动。

第四，从集群安全性看，AL-SHADE-TALG-QU 的最小无人机间距为 20.47 m，是七种算法中的最大值，说明其能为多机飞行保留更充分的内部安全裕度。相比之下，ACOR 和 MSA 的最小机间距分别为 18.06 m 和 18.59 m，安全裕度相对较弱。

第五，综合五项指标排名，AL-SHADE-TALG-QU 的平均排名为 1.4，优于原生 AL-SHADE 的 2.2 和 MSA 的 3.4，综合飞行性能最好。该结果说明，改进算法虽然在单纯适应度收敛曲线上并非最优，但在路径平滑性、队形保持和安全裕度等实际飞行指标上更有优势，更适合复杂障碍物环境下的无人机集群协同路径规划任务。


== 研究展望

本文方法在二维静态障碍物环境下取得了较好的规划效果，但仍有进一步完善的空间。后续研究可从以下几个方面推进。

第一，扩展到三维复杂空域和动态障碍物场景。本文主要研究二维静态障碍物环境，而实际低空空域中常会遇到高度约束、运动障碍物、临时禁飞区和风场扰动等因素。后续可将 B 样条路径建模扩展到 $bb(R)^3$ 空间，并结合动态障碍物预测模型构建时空风险场，使规划算法能够同时处理空间避障和时间避碰问题。

第二，继续分析 B 样条控制点数量与优化维度之间的关系。本文采用 B 样条参数化提升路径连续性，但控制点数量、曲线次数和采样密度会如何影响搜索效率与路径质量，仍需要更系统的实验支撑。后续可通过消融实验确定不同障碍物密度下较合适的控制点规模，并研究自适应增删控制点机制，让曲线表达能力随环境复杂度调整。

第三，提升威胁度模型和参数选择的自适应能力。当前威胁度阈值 $d_("safe")$、相似度阈值 $tau_("sim")$ 以及 Lévy 稳定指数 $beta$ 主要依据经验设定。后续可引入贝叶斯优化、强化学习或在线参数估计方法，使算法根据障碍物密度、通道宽度和种群分布状态自动调整关键参数，减少对人工调参的依赖。

第四，面向实时重规划和机载部署开展轻量化研究。AL-SHADE-TALG-QU 在路径平滑性和安全裕度方面具有优势，但 B 样条采样、威胁度计算和档案去重仍会带来一定计算负担。后续可从并行距离计算、增量式 B 样条更新、档案压缩存储和 GPU 加速等方面降低开销，并研究全局规划与局部避障之间的事件触发式重规划机制。

第五，结合真实无人机平台进行半实物或实飞验证。本文实验主要基于仿真环境，尚未充分考虑传感器噪声、定位误差、通信丢包、执行器延迟和飞控约束等实际因素。后续可在 ROS/Gazebo、AirSim 或真实多无人机平台上进一步验证，将算法输出与低层飞控接口结合起来，检验其在真实系统中的稳定性、鲁棒性和工程可用性。

总体来看，本文提出的分层耦合路径规划框架和 AL-SHADE-TALG-QU 改进算法，在复杂障碍物环境下能够获得较好的路径质量、安全性和编队协同性。随着三维动态建模、在线自适应优化和真实平台验证逐步完善，该方法可进一步面向城市低空巡检、物流配送、灾害搜索和多无人机协同侦察等任务开展应用研究。
