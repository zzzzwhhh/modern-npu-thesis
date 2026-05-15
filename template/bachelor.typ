#import "/template.typ": algorithm, algorithm-ref, capfig, capsubfig, captab, equation-note, indent, multicite, nwpu-thesis

#show: nwpu-thesis.with(
  anonymous: false, // 是否开启盲审模式
  title: "基于 Typst 的西工大论文模板",
  author: "航小天",
  major: "计算机科学与技术",
  supervisor: ("张三", "教授"),
  submit-date: (year: 2026, month: 3),
  abstract: [
    随着无人机在物流、巡检和城市低空空域中的广泛应用，多障碍物环境下无人机集群的高效路径规划成为关键技术问题。本论文以二维平面为研究对象，针对多无人机在复杂障碍物分布下的全局路径最优性、编队保持及局部动态避障需求，提出了一套分层耦合的路径规划方法。

    在 编队控制层，采用虚拟领航者与一致性算法构建通信拓扑，并引入横向偏置自适应调节，实现了无人机在开阔空间内“V”型和“人”字型编队的稳定收敛。在 全局路径规划层，复现并优化了粒子群算法（PSO）、蚁群算法（ACO）和遗传算法（GA），通过禁忌表、适应度惩罚和坐标变异算子提升算法在密集障碍物环境下的可行性与收敛效率。同时，对螳螂搜索算法（MSA）和AL-SHADE算法进行了改进，分别通过混沌映射初始化与非线性步长衰减以及B样条曲线参数化路径建模，解决了早熟收敛、高维优化与路径连续性问题。在 局部避障层，对人工势场法进行改进，引入切向旋转势场力，有效降低了无人机在复杂障碍物边缘的局部死锁现象。

  通过多算法横向对比与联合仿真验证，所提出的方法能够在二维密集障碍环境下实现无人机集群的安全、高效飞行，并兼顾路径平滑性与队形稳定性。本研究为无人机群体智能协同与复杂环境下路径规划提供了新的算法框架和实践参考。
  ],
  keywords: ("无人机集群","路径规划；多障碍物环境；螳螂搜索算法；AL-SHADE；人工势场法"),
  abstract-en: [
    With the widespread application of unmanned aerial vehicles (UAVs) in logistics, inspection, and urban low-altitude airspace, efficient path planning for UAV swarms in environments with multiple obstacles has become a critical technical challenge. This thesis focuses on two-dimensional scenarios and addresses the requirements of global path optimality, formation maintenance, and local dynamic collision avoidance for multi-UAV systems in complex obstacle distributions. A hierarchical and coupled path planning framework is proposed.

In the formation control layer, a virtual leader-based consensus algorithm is implemented to construct the communication topology, with an adaptive lateral bias adjustment to maintain stable "V"-shaped and echelon formations in open space. In the global path planning layer, classical heuristic algorithms including Particle Swarm Optimization (PSO), Ant Colony Optimization (ACO), and Genetic Algorithm (GA) are reproduced and optimized, incorporating tabu lists, fitness penalties, and coordinate mutation operators to improve feasibility and convergence in dense obstacle environments. Furthermore, Mantis Search Algorithm (MSA) and AL-SHADE are enhanced through chaotic initialization, nonlinear step-size attenuation, and B-spline curve parameterization, addressing premature convergence, high-dimensional optimization, and path continuity issues. In the local obstacle avoidance layer, the Artificial Potential Field (APF) method is improved with rotational forces, significantly reducing local deadlock around complex obstacles.

Comprehensive simulations and cross-algorithm comparisons demonstrate that the proposed method enables UAV swarms to navigate safely and efficiently in two-dimensional dense obstacle environments, while maintaining smooth paths and stable formations. This research provides a novel algorithmic framework and practical reference for intelligent swarm coordination and path planning in complex environments.
  ],
  keywords-en: ("UAV swarm", "path planning", "multi-obstacle environment", "Mantis Search Algorithm", "AL-SHADE", "Artificial Potential Field"),
  appendix: [
    == Test
    附录内容……
    #capfig(
      image("figures/example.jpg", width: 45%),
      caption: [图片测试],
      label: <test1>,
    )
  ],
  acknowledgement: [
    致谢内容……
  ],
  design_summary: [
    小结内容……
  ],
)

= 绪论

== 研究背景

=== 研究意义

随着无人机技术的快速发展，无人机在城市低空物流配送、环境监测、灾害救援及军事侦察等领域的应用越来越广泛。相比单架无人机，无人机集群（UAV Swarm）能够通过协同控制实现更高的任务效率、更强的鲁棒性以及更复杂的作业能力。然而，在实际应用中，无人机集群在复杂环境下的飞行仍面临诸多挑战，尤其是在多障碍物环境下，集群路径规划的难度显著增加。

传统路径规划方法，如粒子群算法（PSO）、蚁群算法（ACO）和遗传算法（GA），在连续空间的全局优化中表现良好，但在二维高密度障碍物环境中容易出现路径不连续、局部收敛或早熟收敛问题。例如，PSO在靠近障碍物边缘时容易出现“贴墙飞”，ACO在密集障碍物区域可能陷入循环，GA在交叉重组过程中可能产生穿越障碍物的不可行解。同时，经典的人工势场法（APF）在复杂障碍物环境下容易导致无人机集群陷入局部极小值或死锁，尤其是在“U型”或狭窄通道障碍物处。

近年来，生物启发式算法和自适应优化算法在连续优化问题中显示出强大的全局搜索能力。螳螂搜索算法（MSA）模拟了螳螂捕食的突击与猎物追踪行为，在处理多峰值连续函数优化时具有优异的探索能力，但其原生算法在二维带障碍空间中存在随机初始化不均、早熟收敛严重的问题。AL-SHADE算法则利用成功历史自适应参数和线性种群缩减机制，实现了微分进化算法在高维连续优化问题上的高效搜索，但直接应用于二维离散路径规划会破坏路径的空间连续性，导致无人机航迹不平滑。

因此，研究适用于二维多障碍物环境的无人机集群路径规划方法，不仅需要实现全局路径的最优性和连续性，还需兼顾集群编队稳定性与局部动态避障能力。这不仅具有重要的理论价值，也对无人机群体智能协同及复杂环境下自主飞行应用具有现实意义

=== 研究现状

1. 国外研究现状

在无人机集群路径规划领域，国外研究起步较早，尤其在多无人机协同控制、智能优化算法和复杂环境避障方面积累了丰富成果。针对您的研究任务，国外研究主要集中在以下几个方面：

1.1 编队控制与协同飞行

国外学者提出了多种无人机集群编队控制方法，包括虚拟领航者（Virtual Leader）模型、一致性协议（Consensus Algorithm）、队形保持算法等。通过邻接矩阵、拉普拉斯矩阵等拓扑结构，集群能够在二维或三维空间中稳定形成“V”型、横排或人字型队形，并实现信息分布式共享和收敛。尤其在狭窄通道或动态障碍物场景下，动态队形调整和自适应收缩机制被认为是保证集群安全飞行的关键方法。

1.2 全局路径规划

国外对多障碍物环境下的全局规划研究十分活跃。传统启发式算法（PSO、ACO、GA）被广泛应用于连续空间优化，但存在早熟收敛、局部最优或路径不可行的问题。为解决这些问题，近年来引入了新型群体智能算法和混合优化算法，如螳螂搜索算法（MSA）、改进微分进化算法（AL-SHADE）和遗传算法变体。MSA通过模拟螳螂捕食行为提高探索能力，而AL-SHADE利用历史参数自适应调节搜索步长，实现复杂高维空间的全局优化。这些算法在无人机二维路径规划上的应用，主要问题是如何保证初始解可行性、路径连续性和集群协同。

1.3 局部避障与动态环境适应

国外研究普遍关注无人机在动态或未知障碍物环境下的局部避障。改进人工势场法（APF）、动态势场、潜力函数与切向旋转力等技术被提出，用于引导无人机绕开障碍物、降低局部死锁率。同时，结合编队控制，动态调整队形权重和通信拓扑，以保证在狭窄通道或紧急避障情况下集群安全通行。

综上，国外研究在无人机集群路径规划中，已形成理论成熟、算法多样、应用场景广泛的体系，但在二维高密度障碍物、路径连续性和集群协调耦合方面仍存在技术挑战。

2. 国内研究现状

国内无人机集群路径规划研究近年来发展迅速，主要聚焦于工程实现与算法改进、分层规划框架和集成仿真验证。针对您的研究任务，国内现状可概括如下：

2.1编队控制层研究

国内学者在虚拟领航者模型和一致性算法基础上，提出了横向偏置调节、队形自适应重构等方法，能够保证多无人机在二维空间中“V”型或“人”字型编队稳定收敛。尤其针对狭窄通道，国内研究强调在局部避障触发时动态修改通信权重，实现队形压缩和恢复。

2.2 全局路径规划层研究

国内研究者在PSO、ACO和GA等经典启发式算法基础上，提出了适应度函数优化、禁忌表、坐标变异算子等改进方法，以应对密集障碍物环境下的不可行路径问题。同时，有学者尝试将MSA、AL-SHADE等新型群体智能算法引入无人机路径规划，但主要挑战在于二维离散路径的连续性、算法维度过高和初始解质量低。国内研究通常通过B样条曲线等参数化方法实现路径降维和连续性维护。

2.3 局部避障与动态避碰

国内研究关注无人机在密集障碍物环境中的局部避障问题。改进人工势场法、切向旋转力引导、动态权重调整等技术被提出，以解决无人机在“U型障碍物”或动态障碍物出现局部死锁的问题。同时，通过与编队控制结合，实现狭窄通道中集群的安全通过。
3. 国内外研究比较与评价

国外研究优势：理论体系成熟，方法多样，算法创新和跨学科融合能力强，尤其在复杂环境下的集群协同、自适应优化和动态避障方面领先。

国内研究优势：注重算法工程实现和系统集成，强调三层耦合（编队控制、全局路径规划、局部避障）的实际可行性和仿真验证。

技术空白与挑战：二维高密度障碍物环境下，保持路径连续性、集群队形稳定性和多算法融合的高效性仍是国内外共同面临的研究难题。

== 研究内容

研究内容概述。

== 图表测试

引用@timing-tlt，以及@test。

#captab(
  caption: [三线表],
  label: <timing-tlt>,
)[
  | t   | 1    | 2    | 3    |
  | --- | ---- | ---- | ---- |
  | y   | 0.3s | 0.4s | 0.8s |
]

#captab(
  caption: [复杂表示例：聚合物基复合材料的性能],
  label: <composite-performance>,
  cols: (1.25fr, 1fr, 1fr, 1fr, 1fr),
  hlines: (
    (row: 2, stroke: 1pt),
  ),
)[
  | 材料           | 碳/环氧 | <    | 玻璃/环氧 | <    |
  | ^              | 纵向    | 横向 | 纵向      | 横向 |
  | 模量，GPa      | 181     | 10.3 | 38.6      | 8.3  |
  | 压缩强度，MPa  | 1500    | 246  | 610       | 118  |
  | 拉伸强度，MPa  | 1500    | 40   | 1062      | 31   |
]

#capfig(
  image("figures/example.jpg", width: 45%),
  caption: [图片测试],
  label: <test>,
)

图片之间的文字

#capsubfig(
  (
    (content: image("figures/example.jpg", width: 60%), subcaption: [第一个子图说明]),
    (content: image("figures/example.jpg", width: 60%), subcaption: [第二个子图说明]),
  ),
  columns: 2,
  caption: [总图标题],
  label: <fig-main>,
)

== 数学公式

可以像 Markdown 一样写行内公式 $x + y$，以及带编号的行间公式：

$ phi.alt := (1 + sqrt(5)) / 2 $ <ratio>

引用数学公式需要加上 `eqt:` 前缀，则由@eqt:ratio，我们有：

$ F_n = floor(1 / sqrt(5) phi.alt^n) $

我们也可以通过 `<->` 标签来标识该行间公式不需要编号

$ y = integral_1^2 x^2 dif x $ <->

而后续数学公式仍然能正常编号。

$ F_n = floor(1 / sqrt(5) phi.alt^n) $

== 算法示例

下面给出采用单独算法编号的三线表风格算法示例，见#algorithm-ref(<alg:binary-search>)。

#algorithm(
  title: [二分查找算法],
  input: [有序数组 $A$，目标值 target。],
  output: [目标值下标，不存在则返回 -1。],
  [left := 0],
  [right := len(A) - 1],
  [*while* left <= right *do*],
  indent(
    [mid := floor((left + right) / 2)],
    [*if* A.at(mid) == target *then*],
    indent([return mid]),
    [*else if* A.at(mid) < target *then*],
    indent([left := mid + 1]),
    [*else*],
    indent([right := mid - 1]),
    [*end*],
  ),
  [return -1],
) <alg:binary-search>

= 相关工作
 


= 基础理论和算法实现
 == 编队控制算法设计与实现
 === 无人机编队说明
  首先，将无人机视为质点，并借助地面坐标系表示其位置与运动；在水平面上，原点O可任意选定。无人机编队的三维平面有l–ψ法和l–l法两种描述形式，本文采用l–l法。无人机间的相对位置关系由矩阵Rx、Ry给出。
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

在无人机编队中，常采用含自驾仪的三自由度运动学模型。基础运动学方程在纵向上与横向上的运动是相互耦合的。文献[29]通过将横向航向自驾仪和纵向自驾仪进行解耦，建立起横纵分离的运动学模型。其中，无人机i的运动模型如公式(3)所示。
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

=== 编队控制算法

通过文献中的一致性原理，本节分别构建了无人机在横向与纵向上的控制策略。在此基础上，通过将无人机的物理机动限制与控制律相融合，最终推导出了本文所提的协同控制算法。

在多无人机系统中，信息交互拓扑结构常用图论（Graph Theory）来描述。假设无人机集群由 $n$ 架无人机组成，其通信拓扑可用无向图或有向图 $G = (V, E)$ 表示。引入邻接矩阵 $A = [a_(i j)] in bb(R)^(n times n)$ 以及拉普拉斯矩阵 $L = [l_(i j)] in bb(R)^(n times n)$。邻接矩阵中的元素 $a_{i j}$ 用于表征通信链路：当无人机 $i$ 能够获取无人机 $j$ 的信息时，$a_{i j}=1$，否则 $a_{i j}=0$。

拉普拉斯矩阵定义为 $L = D - A$，其中度矩阵 $D = "diag"(d_1, d_2, dots.h, d_n)$，且节点入度 $d_i = sum_{j=1}^n a_{i j}$。由文献[]可以证明拉普拉斯矩阵不仅包含了系统的图论拓扑特征，其特征值的分布特性在控制理论上严格限制并保证了一致性算法的收敛性与集群飞行的稳定性（当且仅当通信拓扑图包含生成树时，控制系统能够实现无偏的渐近收敛）。

在 Tao 等@tao2023 的工作中，无人机水平运动被建模为双积分器系统：$dot(bold(p))_i = bold(v)_i$，$dot(bold(v))_i = bold(u)_i$，其中 $bold(u)_i = (u_(x i), u_(y i))^T$ 为待设计的虚拟加速度控制输入。基础一致性协议沿 $X_g$ 和 $Y_g$ 轴分别构造如下：

$
u_(x i)(t) = - sum_(j=1)^n a_(i j) [(x_i(t) - x_j(t) - r_(i j)^x) + gamma (v_(x i)(t) - v_(x j)(t))]
$

$
u_(y i)(t) = - sum_(j=1)^n a_(i j) [(y_i(t) - y_j(t) - r_(i j)^y) + gamma (v_(y i)(t) - v_(y j)(t))]
$

式中 $gamma > 0$ 为位置误差与速度误差的耦合增益，$r_(i j)^x = -r_(j i)^x$、$r_(i j)^y = -r_(j i)^y$ 为前文定义的期望相对位移。该协议驱动每架无人机沿两轴向邻机的期望位置靠拢，同时使其速度趋近于邻居集合的加权平均。

然而，上述基础形式隐含了两个理想假设——通信无延迟且拓扑结构固定不变。在实际飞行场景中，机间数据链存在不可忽略的传输延迟；此外受信道质量、机间距离及障碍遮挡等因素影响，通信链路可能随时中断或恢复。为弥补这些不足，Tao 等@tao2023 提出了同时处理非对称通信时延与切换拓扑的改进一致性控制律。

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

*飞行约束的最小调整策略。* @eqt:control-to-autopilot 求得的指令未考虑式@eqt:constraints 所列的机动能力边界。Tao 等@tao2023 设计了分两级递进的最小调整映射，在保证指令可行性的前提下尽量保持原始控制方向。

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

*离散时间实现。* 控制器以周期 $Delta t$ 迭代运行：每步采集邻机延迟状态，按式@eqt:improved-consensus-x、式@eqt:improved-consensus-y 计算虚拟加速度，经上述两级约束映射后输出自驾仪速度指令，驱动无人机状态更新。该架构在二维平面上为集群提供了兼顾拓扑鲁棒性与飞行安全性的编队控制能力，为后续全局路径规划奠定了载体平台层的协同基础@tao2023。

下面给出编队控制器的完整伪代码，主循环见#algorithm-ref(<alg:formation-control>)，约束调整子过程见#algorithm-ref(<alg:constraint-adj>)。

#pagebreak()
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

#pagebreak()
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


 == 全局路径规划算法设计与实现
 === 粒子群算法（PSO）设计与实现

粒子群优化算法（Particle Swarm Optimization, PSO）是由 Kennedy 与 Eberhart 于 1995 年提出的一种群体智能优化算法，其基本思想源于鸟群觅食行为的模拟：每个粒子代表解空间中的一个候选解，通过跟踪自身历史最优位置（个体认知）和群体历史最优位置（社会信息）来更新自身的速度与位置，从而在迭代中逐步逼近全局最优解。由于 PSO 具有参数少、收敛速度快、不依赖梯度信息等优点，在连续空间的全局路径规划问题中得到了广泛应用。

*路径编码与搜索空间构造。* 将无人机从起始点 $bold(S) = (x_S, y_S)$ 到目标点 $bold(T) = (x_T, y_T)$ 的飞行路径离散化为 $N$ 个中间航点 $bold(W) = {bold(w)_1, bold(w)_2, dots, bold(w)_N}$，其中 $bold(w)_j = (x_j, y_j) in bb(R)^2$。每个粒子的位置向量编码为 $2N$ 维实数向量：

$
bold(X) = (x_1, y_1, x_2, y_2, dots, x_N, y_N)^T in bb(R)^(2N)
$

完整的飞行路径由起点、全部航点与终点顺序连接而成：$bold(S) -> bold(w)_1 -> bold(w)_2 -> dots -> bold(w)_N -> bold(T)$。

搜索空间的初始化采用基线扰动策略。首先在起点与终点之间按等比例插入生成一组基线航点：

$
bold(w)_j^("base") = (1 - rho_j) bold(S) + rho_j bold(T), quad rho_j = j / (N + 1), quad j = 1, 2, dots, N
$

为赋予初始种群多样性，围绕基线航点在带状可行域内进行均匀随机扰动。记步长向量 $bold(Delta) = (bold(T) - bold(S)) / (N + 1)$，则航点 $j$ 的搜索边界为：

$
bold(w)_j^(min) = max(bold(w)_j^("base") - bold(b), bold(S)_("min")), quad
bold(w)_j^(max) = min(bold(w)_j^("base") + bold(b), bold(T)_("max"))
$

其中带状半宽 $bold(b) = (b_x, b_y)$ 取为 $b = max(3 sigma_0, 1.2 thin bar(delta), 80)$，$sigma_0$ 为初始散布标准差，$bar(delta)$ 为相邻基线点之间的平均间距。该策略既利用了起点-终点连线提供的先验引导，又为粒子群保留了充分的探索自由度。

*多目标适应度函数设计。* 路径的评价需同时兼顾长度经济性、飞行平滑性、安全避障、通信可靠性与编队可行性五个方面，构建如下加权适应度函数：

$
J(bold(X)) = alpha L_"norm" + beta S_"norm" + gamma R_"norm" + mu W_"norm" + lambda_f F_"norm"
$

式中各项均经归一化处理以消除量纲差异，权重系数取为 $alpha = 0.24$、$beta = 0.18$、$gamma = 0.32$、$mu = 0.14$、$lambda_f = 0.12$，反映了"安全性优先、兼顾效率与平顺"的设计原则。

（1）*路径长度项* $L$：定义为航点序列的累计欧氏距离 $L = sum_(k=0)^N norm(bold(p)_(k+1) - bold(p)_k)$，其中 $bold(p)_0 = bold(S)$，$bold(p)_(N+1) = bold(T)$。该项推动路径向最短线收敛。

（2）*平滑性项* $S$：以相邻航段之间的偏转角 $theta_k$ 衡量路径的弯曲程度：

$
S = sum_(k=1)^(N-1) theta_k^2 + sum_(k in Theta_"sharp") eta thin (theta_k - theta_("thr"))^2
$

其中 $theta_k = arccos(frac(bold(v)_k dot bold(v)_(k+1), norm(bold(v)_k) norm(bold(v)_(k+1))))$，$bold(v)_k = bold(p)_k - bold(p)_(k-1)$。当 $theta_k$ 超过急转阈值 $theta_("thr") = 65°$ 时，施加额外惩罚项（$eta = 8$），以抑制路径的剧烈转向。

（3）*综合风险项* $R$：由静态障碍物风险、动态障碍物风险、通信风险及编队可行性风险四个子项复合而成：

$
R = R_s + R_d + R_c + R_f
$

- 静态风险 $R_s$：对路径上密集采样的每一点 $bold(q)$，计算其距最近障碍物的间隙 $d(bold(q))$。若 $d < 0$（碰撞）则加重惩罚，若 $d < d_("safe")$ 则施加连续递增代价，在安全区则采用指数衰减的弱代价。
- 动态风险 $R_d$：考虑障碍物运动速度在相对接近方向上的分量，障碍物靠近速度越大、间隙越小，代价越高。
- 通信风险 $R_c$：以通信范围 $d_("comm") = 220$ m 和理想通信距离 $d_("ideal") = 85$ m 为基准，当机间距离过远（超范围断开）或过近（信道干扰）时均产生附加代价，并计入通信延迟惩罚。
- 编队风险 $R_f$：将编队包络半径纳入障碍物间隙的核算——若间隙扣除编队半径后为负，表示该点无法容纳编队通过，产生不可行代价。

（4）*可靠性项* $W$：综合航向稳定性、间隙稳定性、通信延迟稳定性和链路连通率四个指标，映射为 $[0, 1]$ 区间的可靠性分数，再转化为代价 $W = 1 - "Reliability"$。

（5）*可行性惩罚项* $F$：对碰撞事件、通信断开比例、编队不可行点数和急转次数等硬约束违反行为施加大幅惩罚，确保算法优先排除不可行解。此外，引入航点间距惩罚机制：当相邻航点距离小于 $d_("spacing") = 28$ m 时施加平方型代价，防止航点在局部区域过度聚集。

*粒子更新机制。* 每个粒子 $i$ 维护当前位置 $bold(X)_i$、速度 $bold(V)_i$ 和个体历史最优 $bold(P)_i^("best")$，全局最优记为 $bold(G)^("best")$。在第 $t$ 次迭代中，速度和位置按标准 PSO 公式更新：

$
bold(V)_i^(t+1) = omega bold(V)_i^(t) + c_1 r_1 (bold(P)_i^("best") - bold(X)_i^(t)) + c_2 r_2 (bold(G)^("best") - bold(X)_i^(t))
$

$
bold(X)_i^(t+1) = bold(X)_i^(t) + bold(V)_i^(t+1)
$

其中惯性权重 $omega = 0.6$ 平衡全局探索与局部开发，个体学习因子 $c_1 = 1.6$ 和社会学习因子 $c_2 = 1.4$ 分别控制粒子向个体最优和全局最优靠拢的强度，$r_1, r_2$ 为 $[0, 1]$ 区间上独立采样的均匀随机数。

粒子更新后将其位置裁剪至航点搜索边界 $[bold(w)_j^(min), bold(w)_j^(max)]$ 内。若更新后的适应度优于个体历史最优，则更新 $bold(P)_i^("best")$；若进一步优于全局最优，则同步更新 $bold(G)^("best")$，从而逐步引导种群向全局最优路径收敛。

算法终止条件为达到预设的最大迭代次数 $T_("max")$。典型参数配置为种群规模 $P = 500$，最大迭代次数 $T_("max") = 500$，航点数量 $N = 15$，以在优化精度与计算开销之间取得平衡。通过上述设计，PSO 全局规划器能够输出一条兼顾长度、平滑性、安全性和编队兼容性的参考路径，为后续局部避障与编队控制提供空间引导。

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

 === 蚁群算法（ACO）设计与实现

蚁群算法（Ant Colony Optimization, ACO）最初由 Dorigo 等受蚂蚁觅食行为启发而提出，其经典形式通过离散信息素矩阵求解组合优化问题（如旅行商问题）。然而无人机路径规划属于连续空间优化，航点坐标取值于二维实数域，无法直接套用离散网格上的信息素累积机制。为此，本节采用 Socha 与 Dorigo 提出的面向连续域的扩展蚁群算法（$"ACO"_(bb(R))$），将信息素模型由离散状态转移概率转化为基于解档案的高斯核密度估计，从而实现对连续路径空间的高效搜索。

*解档案与信息素模型。* ACOR 的核心是由 $K$ 个历史最优解构成的有序档案 $cal(A) = {bold(s)_1, bold(s)_2, dots, bold(s)_K}$，其中 $K$ 称为档案容量。档案中的解按适应度升序排列——$bold(s)_1$ 为全局最优，$bold(s)_K$ 为档案中最差。每个解 $bold(s)_l$ 编码了 $N$ 个航点的二维坐标，即 $bold(s)_l in bb(R)^(2N)$。

不同于离散 ACO 在每段路径上维护信息素浓度，ACOR 将信息素模型推广为档案加权的多维高斯核概率密度函数：

$
G(bold(X)) = sum_(l=1)^K omega_l cal(N)(bold(X) | bold(s)_l, bold(Sigma)_l)
$

其中高斯核的权重 $omega_l$ 按解的排序位置分配，排名越靠前的解被赋予越高的采样概率：

$
omega_l = frac(1, q K sqrt(2 pi)) exp(-frac((l - 1)^2, 2 (q K)^2)), quad l = 1, 2, dots, K
$

式中 $q in (0, 1)$ 为档案集中度参数，$q$ 值越小则概率分布越集中于排名靠前的解，搜索偏向精化（exploitation）；$q$ 值越大则选择压力越均匀，搜索偏向探索（exploration）。权重经归一化后构成概率向量 $bold(p) = (p_1, p_2, dots, p_K)^T$，其中 $p_l = omega_l / sum_(m=1)^K omega_m$。

*核宽度的自适应计算。* 每只蚂蚁在选择引导解 $bold(s)_("guide")$（即高斯核中心）后，需要确定各维度的采样标准差以构造新解。第 $j$ 个航点坐标分量对应的标准差 $sigma_j$ 由档案中所有解相对于引导解的离散程度自适应确定：

$
sigma_j = xi dot frac(1, K - 1) sum_(l=1)^K |bold(s)_(l, j) - bold(s)_("guide", j)| + epsilon, quad j = 1, 2, dots, 2N
$

其中 $xi in (0, 1)$ 为蒸发率（典型值 $xi = 0.85$），其作用类似于离散 ACO 中的信息素挥发系数——$xi$ 越大，核越窄，搜索越集中；$xi$ 越小，核越宽，探索越分散。$epsilon = 10^(-4)$ 为防止零方差退化的小量正数，确保搜索空间始终具有最小发散度。

该自适应核宽度机制是 ACOR 区别于 PSO 的关键特征：PSO 各维度的探索步长依赖于速度惯性记忆和随机扰动，而 ACOR 的步长由当前档案解集的分布宽度动态决定——当档案解趋于一致时，核自动收缩以精细搜索；当档案解分散时，核自动展宽以防止早熟收敛。

*蚂蚁采样与解构造。* 每只蚂蚁按以下两阶段生成新解：

（1）*引导选择*：按概率向量 $bold(p)$ 在档案中随机选取一个引导解 $bold(s)_("guide")$。

（2）*高斯采样*：以 $bold(s)_("guide")$ 为均值、$bold(sigma) = (sigma_1, dots, sigma_(2N))^T$ 为标准差，对每个坐标分量进行独立高斯采样：

$
bold(X)^("new") = bold(s)_("guide") + cal(N)(bold(0), "diag"(bold(sigma)^2))
$

*档案更新与收敛。* 所有蚂蚁生成的新解经适应度评估后并入档案，形成临时集合 $cal(A) union cal(S)^("new")$，随后按适应度排序并截断至容量 $K$——仅保留最佳的 $K$ 个解。这一"精英保留"策略保证了档案质量随迭代单调提升。算法终止条件为达到最大迭代次数 $T_("max")$，最终返回档案最优解 $bold(s)_1$ 作为全局路径航点序列。

典型参数配置为：档案容量 $K = 20$，蚂蚁数量 $M = 500$，最大迭代次数 $T_("max") = 500$，航点数量 $N = 20$，集中度参数 $q = 0.1$，蒸发率 $xi = 0.85$。初始档案通过基线插值叠加高斯噪声生成 $2K$ 个候选解后筛选最佳 $K$ 个构成。适应度函数沿用五分量加权模型 $J = alpha L_"norm" + beta S_"norm" + gamma R_"norm" + mu W_"norm" + lambda_f F_"norm"$，各项定义与 PSO 中一致，便于算法之间的公平对比。

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



 === 遗传算法（GA）设计与实现

遗传算法（Genetic Algorithm, GA）是由 Holland 于 20 世纪 70 年代提出的一种模拟自然选择与遗传进化机制的随机搜索算法。其核心思想是将候选解编码为"染色体"，通过选择、交叉和变异三个基本遗传算子，在代际迭代中实现种群适应度的持续提升。对于无人机二维路径规划这一连续优化问题，本节采用实数编码遗传算法（Real-Coded GA），直接在实向量空间上操作航点坐标，避免了二进制编码带来的精度损失与维度膨胀。

*染色体编码与种群初始化。* 每条染色体编码 $N$ 个航点的二维坐标，即 $bold(C) = (x_1, y_1, x_2, y_2, dots, x_N, y_N)^T in bb(R)^(2N)$。初始种群采用与 PSO 一致的基线扰动策略：在起点-终点连线上等比例生成基线航点，围绕基线在带状搜索域内均匀随机采样，生成规模为 $P$ 的初始种群 $cal(P)_0$。所有个体的适应度由五分量加权适应度函数 $J$ 评估。

*选择算子——锦标赛选择。* 采用 $k$-锦标赛选择策略（$k = 3$）：从当前种群中随机抽取 $k$ 个个体，选取其中适应度最优者作为父代参与繁殖。该策略具有以下优点：（1）选择压力可通过 $k$ 连续调节，避免了轮盘赌选择中适应度尺度敏感的问题；（2）仅依赖个体间的相对排序而非绝对适应度值，对适应度尺度变换具有不变性；（3）计算复杂度为 $O(P)$，不涉及全局排序。

*交叉算子——算术交叉。* 对于经锦标赛选出的两个父代染色体 $bold(C)_(p_1)$ 和 $bold(C)_(p_2)$，采用整体算术交叉生成子代：

$
bold(C)_("child") = alpha bold(C)_(p_1) + (1 - alpha) bold(C)_(p_2), quad alpha ~ cal(U)(0, 1)
$

该算子可视为在父代连线（高维空间超线段）上随机插值生成子代，其几何意义明确：子代位于两个父代所张成的凸组合空间内。对于 $n$ 维连续优化问题，算术交叉能在保持父代优良基因片段的同时产生位于中间区域的探索解，具有良好的局部搜索能力。

*变异算子——坐标高斯变异。* 以概率 $p_m = 0.1$ 对子代染色体的每个航点坐标分量独立施加高斯扰动：

$
bold(C)_("child")[w] arrow bold(C)_("child")[w] + cal(N)(0, sigma^2 bold(I)_2), quad w = 1, 2, dots, N
$

变异强度 $sigma$ 采用线性退火策略随代数递减：

$
sigma(g) = sigma_0 lr(1 - frac(g, G_"max")), quad sigma_0 = 40
$

其中 $g$ 为当前代数，$G_"max"$ 为最大代数。该退火策略在进化初期赋予较大的变异步长以维持种群多样性、促进全局探索，在进化后期逐步缩减步长以聚焦局部精化，从而在探索与开发之间实现动态平衡。

*精英保留策略。* 为避免交叉和变异操作破坏已发现的最优解，每代将种群按适应度排序后，保留前 $P_"elite" = max(5, 0.1 P)$ 个最优个体直接进入下一代，其余个体通过选择-交叉-变异生成。精英保留保证了历代最优适应度的单调非增性，显著加速收敛。

*算法终止与参数配置。* 算法达到最大进化代数 $G_"max"$ 后终止，输出种群中适应度最优的染色体作为全局路径航点序列。典型参数配置为：种群规模 $P = 500$，最大代数 $G_"max" = 500$，航点数 $N = 20$，初始变异强度 $sigma_0 = 40$，变异概率 $p_m = 0.1$，锦标赛规模 $k = 3$，精英比例 $10%$。适应度函数沿用 $J = alpha L_"norm" + beta S_"norm" + gamma R_"norm" + mu W_"norm" + lambda_f F_"norm"$，权重及分项定义与 PSO 一致，保证三种算法在统一评价框架下的可比性。

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


  === 螳螂搜索算法（MSA）设计与实现

螳螂搜索算法（Mantis Search Algorithm, MSA）是 Abdel-Basset 等人于2023年提出的一种新型群体智能优化算法@MSA2023，其设计灵感来源于自然界中螳螂的捕食行为与性食同类现象。螳螂作为一种典型的伏击型捕食者，在长期进化过程中形成了独特的狩猎策略：它们既能主动追踪猎物，也能保持静止伪装等待猎物靠近，并在交配过程中表现出雌性吞噬雄性的性食同类行为。MSA通过数学建模将上述生物学行为抽象为三个核心优化阶段，分别对应全局探索、局部开发以及种群多样性维持三种搜索机制。

从算法设计角度而言，MSA的探索阶段模拟了螳螂的追踪行为与伏击策略。追踪型螳螂利用Lévy飞行与正态分布相结合的随机游走方式在解空间中进行大范围搜索，而伏击型螳螂则通过在当前位置附近细致搜索来捕获潜在猎物。开发阶段模拟了螳螂利用前足进行快速击打以捕获猎物的过程，其中引入基于Sigmoid函数的击打速度模型，使得算法在迭代后期具有较强的局部精细搜索能力。性食同类阶段则作为额外的搜索算子，通过模拟雌性螳螂吸引、交配并吞噬雄性的过程来实现解之间的信息交换与重组，从而增强种群跳出局部最优的能力。

MSA在全局搜索与局部开发之间的平衡通过概率参数$p$进行控制，并在整个迭代过程中动态调整探索与开发的比重。与经典的粒子群优化算法、差分进化算法等相比，MSA引入了三个互相协同的搜索阶段，使其在求解高维、多峰、非线性优化问题时展现出良好的收敛精度与鲁棒性。

==== 算法数学模型

*种群初始化。* 设种群规模为$N$，搜索空间维度为$D$。每一只螳螂个体代表优化问题的一个候选解，其在第$t$次迭代中的位置向量表示为$bold(x)_i^t = [x_(i,1)^t, x_(i,2)^t, dots.h.c, x_(i,D)^t]$。初始种群通过均匀随机初始化在搜索空间的上下界内生成：

$ bold(x)_i^0 = bold(x)_L + bold(r) dot (bold(x)_U - bold(x)_L) $ <eq:msa-init>

式中，$bold(x)_L$和$bold(x)_U$分别为解空间的下界和上界向量，$bold(r)$为在$[0, 1]$区间内均匀分布的随机向量，运算符$dot$表示逐元素乘积。MSA维护一个外部存档$"Archive"$用于保存搜索过程中发现的较优解，存档容量$A$为预设参数。

*探索阶段：搜索猎物。* 探索阶段模拟螳螂在未知环境中搜寻猎物的行为，包含两种互补的搜索策略——追踪行为与伏击行为，由回收控制因子$F$进行调度。设最大迭代次数为$T$，回收因子$P$用于划分搜索周期，回收控制因子定义为：

$ F = 1 - (t "mod" (T / P)) / (T / P) $ <eq:msa-recycle>

随着迭代的推进，$F$在$[0, 1]$之间呈周期性锯齿状变化。当$F$靠近1时倾向于追踪行为以增强全局探索，当$F$靠近0时倾向于伏击行为以进行局部精细搜索。

追踪型螳螂的位置更新策略融合了Lévy飞行与正态分布两种随机过程：

$ bold(x)_i^(t+1) = cases(
  bold(x)_i^t + bold(tau)_1 dot (bold(x)_i^t - bold(x)_a^t) + tau_2 bold(U) dot (bold(x)_a^t - bold(x)_b^t), "if " r_1 <= r_2,
  bold(x)_i^t dot bold(U) + (bold(x)_a^t + bold(r)_3 dot (bold(x)_b^t - bold(x)_c^t)) dot (1 - bold(U)), "otherwise"
) $ <eq:msa-pursuer>

式中$bold(tau)_1$为服从Lévy分布的随机向量，$tau_2$为服从标准正态分布$cal(N)(0, 1)$的随机标量，$bold(U)$为二值掩码向量。Lévy飞行向量通过Mantegna算法生成：$bold(tau)_1 = bold(u) / |bold(v)|^(1 / beta)$，其中$beta = 1.5$。

伏击型螳螂采用存档引导的组合位置更新策略：

$ bold(x)_i^(t+1) = cases(
  bold(x)_i^t + alpha dot (bold(x)_("ar")^t - bold(x)_a^t), "if " r_9 <= r_(10),
  bold(x)_("ar")^t + (2 r_7 - 1) dot mu dot (bold(x)_L + bold(r)_8 dot (bold(x)_U - bold(x)_L)), "otherwise"
) $ <eq:msa-ambuscade>

其中$alpha = cos(pi r_6) dot mu$，$mu = 1 - t / T$为搜索距离衰减因子。随着迭代推进，$mu$从1线性递减至0，使得搜索步长逐渐缩小，算法从全局探索平滑过渡到局部开发。

*开发阶段：攻击猎物。* 当螳螂探测到猎物处于有效击打范围时进入攻击阶段。击打速度采用Sigmoid函数建模：$v_s = 1 / (1 + e^(l dot rho))$，式中$rho$为引力加速率常数（通常取6）。Sigmoid函数的特性使得早期迭代中$v_s$较小，而在后期逐渐趋近于1。

当随机数大于击打失败概率时，螳螂成功击打到猎物，位置向全局最优解更新：

$ bold(x)_i^(t+1) = (bold(x)_i^t + bold(x)^*) / 2 + v_s dot (bold(x)^* - bold(x)_i^t) $ <eq:strike-success>

当击打失败时，利用两个随机个体的差异向量进行轨迹修正：$bold(x)_i^(t+1) = bold(x)_i^t + r_(12) dot (bold(x)_a^t - bold(x)_b^t)$。当面临局部最优风险时，引入振荡放大扰动策略：$bold(x)_i^(t+1) = bold(x)_i^t + e^(2l) dot cos(2 pi l) dot (bold(x)_i^t - bold(x)_("ar")^t) + (2 r_(13) - 1) dot (bold(x)_U - bold(x)_L)$，其中$e^(2l) dot cos(2 pi l)$项创建了振荡幅度指数增长的扰动信号。

击打失败概率$P_f = a dot (1 - t / T)$随迭代线性递减，与击打速度$v_s$的Sigmoid变化形成互补，共同驱动探索向开发的渐进式过渡。

*性食同类阶段。* 性食同类是螳螂行为学中最具特征性的现象之一，该阶段以概率$P_c$（通常设为0.2）触发，包含三个子过程。雌性吸引雄性：$bold(x)_i^(t+1) = bold(x)_i^t + bold(r)_(16) dot (bold(x)_i^t - bold(x)_a^t)$，吸引概率$P_t = r_(17) dot mu$。交配行为通过均匀交叉算子实现：$bold(x)_i^(t+1) = bold(x)_i^t dot bold(U) + (bold(x)_i^t + bold(r)_(18) dot (bold(x)_a^t - bold(x)_i^t)) dot (1 - bold(U))$。雌性吞噬雄性：$bold(x)_i^(t+1) = bold(x)_a^t dot cos(2 pi l) dot mu$，其中$mu = 1 - t / T$控制雄性遗传信息被吸收的比例。

*算法流程总结。* MSA首先生成$N$个随机初始解构成螳螂种群并初始化外部存档。每轮迭代中先计算$mu$、$P_f$等自适应参数，然后依次为每个个体执行探索阶段或开发阶段的位置更新，最后以概率$P_c$执行性食同类阶段操作。在探索阶段，根据回收控制因子$F$决定采用追踪还是伏击行为；在开发阶段，根据$P_f$决定成功击打或失败修正；性食同类阶段通过$P_t$进一步决定吸引、交配或吞噬操作。

#pagebreak()
#algorithm(
  title: [螳螂搜索算法（MSA）],
  input: [
    种群规模$N$，最大迭代次数$T$，搜索空间维度$D$，
    下界$bold(x)_L$，上界$bold(x)_U$，存档容量$A$，
    回收因子$P$，引力加速率$rho$，初始失败率$a$，性食同类概率$P_c$。
  ],
  output: [全局最优解$bold(x)^*$及其适应度$f^*$。],
  [*步骤 1：种群与存档初始化*],
  [*for* $i = 1$ *to* $N$ *do*],
  indent(
    [随机初始化个体 $bold(x)_i^0$],
    [计算适应度 $f(bold(x)_i^0)$],
  ),
  [确定当前最优解 $bold(x)^*$ 及最优适应度 $f^*$],
  [初始化存档 $"Archive"$为当前种群中的较优解],
  [],
  [*步骤 2：主迭代循环*],
  [*for* $t = 0$ *to* $T - 1$ *do*],
  indent(
    [计算距离因子 $mu = 1 - t / T$],
    [计算击打失败概率 $P_f = a dot mu$],
    [计算回收控制因子 $F = 1 - (t "mod" (T / P)) / (T / P)$],
    [],
    [*步骤 3：种群更新*],
    [*for* $i = 1$ *to* $N$ *do*],
    indent(
      [*if* $cal(U)(0,1) < 0.5$ *then* — 探索阶段],
      indent(
        [*if* $cal(U)(0,1) < F$ *then*],
        indent(
          [按追踪公式执行追踪行为更新 $bold(x)_i^t$],
        ),
        [*else*],
        indent(
          [按伏击公式执行伏击行为更新 $bold(x)_i^t$],
        ),
      ),
      [*else* — 开发阶段],
      indent(
        [计算击打速度 $v_s = 1 / (1 + e^(l dot rho))$],
        [*if* $cal(U)(0,1) > P_f$ *then*],
        indent(
          [按成功击打公式执行成功击打更新],
        ),
        [*else*],
        indent(
          [*if* $cal(U)(0,1) < 0.5$ *then*],
          indent(
            [执行轨迹修正],
          ),
          [*else*],
          indent(
            [执行局部最优逃逸],
          ),
        ),
      ),
      [],
      [*步骤 4：边界处理与适应度评估*],
      [将 $bold(x)_i^t$ 各维度限制在 $bold(x)_L$ 与 $bold(x)_U$ 之间],
      [计算新适应度 $f_i^"new"$],
      [*if* $f_i^"new" < f(bold(x)_i^t)$ *then* 接受更新],
      [更新存档 $"Archive"$],
      [*if* $f_i^"new" < f^*$ *then* 更新全局最优解],
    ),
    [],
    [*步骤 5：性食同类操作*],
    [*if* $cal(U)(0,1) < P_c$ *then*],
    indent(
      [*for* $i = 1$ *to* $N$ *do*],
      indent(
        [计算吸引概率 $P_t = cal(U)(0,1) dot mu$],
        [*if* $cal(U)(0,1) < P_t$ *then*],
        indent(
          [执行吸引操作],
          [执行交配操作],
          [执行吞噬操作],
        ),
      ),
    ),
  ),
  [],
  [*步骤 6：输出结果*],
  [*return* $bold(x)^*$ 和 $f^*$],
) <alg:msa-global>

*算法参数分析。* 种群规模$N$决定了解的多样性与搜索覆盖面，通常取50至100之间。最大迭代次数$T$根据问题规模和精度要求确定，通常设置在100至1000之间。存档容量$A$影响伏击行为和逃逸机制中参考信息的质量，较大的$A$保留了更丰富的历史较优解信息。回收因子$P$调控追踪与伏击两种行为的交替频率，标准推荐值为2。引力加速率$rho$控制击打速度Sigmoid曲线的陡峭程度，$rho = 6$意味着击打速度在中后期迅速趋近饱和。性食同类概率$P_c$决定了执行性食同类操作的预期频率，通常设为0.2。距离衰减因子$mu = 1 - t / T$贯穿全算法——从探索阶段的搜索步长缩放，到开发阶段的失败概率控制，再到性食同类阶段的吸引概率和吸收比例，确保了算法从全局探索向局部开发的平滑过渡。

*收敛性分析。* 从搜索机制层面，Lévy飞行步长的重尾分布特性保证了算法的全局可达性——由于Lévy分布的方差无限，个体能够以非零概率到达搜索空间任意位置，确保了算法不会被困于局部最优。正态分布步长提供了在均值附近的精细搜索能力。Sigmoid击打速度的单调递增特性保证了群体在迭代后期向最优解方向逐步逼近。从种群多样性维护层面，性食同类阶段通过交叉重组与吞噬替换机制持续注入新的位置扰动。MSA满足随机搜索算法全局收敛的两个必要条件：精英保留与搜索遍历性，当迭代次数趋于无穷时以概率1收敛于全局最优解。

*计算复杂度分析。* 设种群规模为$N$，问题维度为$D$，最大迭代次数为$T$。MSA各阶段的单个体更新复杂度均为$O(D)$，总体时间复杂度为$O(T N D + T A)$，其中存档维护开销$O(T A)$因$A ≪ N$可忽略不计。渐近时间复杂度$O(T N D)$与主流群体智能算法处于同一量级。空间复杂度主要来源于存储$N$个$D$维个体向量及容量为$A$的存档，为$O(N D + A D)$。



 === AHA算法设计与实现

人工蜂鸟算法（Artificial Hummingbird Algorithm, AHA）由 Zhao 等人于2022年提出@AHA2022，其生物学原型来源于蜂鸟特有的觅食行为与空间记忆能力。蜂鸟作为自然界中唯一具备悬停、侧飞及倒飞能力的鸟类，在采蜜过程中展现出三类基础飞行动作——轴向飞行、对角飞行与全向飞行；与此同时，蜂鸟具有出色的位置记忆能力，能够记住每一朵花的空间坐标以及距上一次访问的时间间隔，从而在采食决策中综合权衡花蜜质量与回访间隔，实现高效的资源利用。AHA 通过将上述飞行技巧抽象为搜索方向向量、将花蜜记忆机制构建为访问表，建立了一个无需外部控制参数、仅依赖种群内部自适应调节的群体智能优化框架。

与传统群体智能算法（如 PSO 依赖惯性权重与学习因子、ACO 依赖信息素挥发率）不同，AHA 的核心特征在于搜索行为的自适应切换完全由访问表与随机飞行模式所驱动，不引入任何人工设定的步长衰减或概率调度参数。对于无人机二维路径规划这类高维、多约束且可行域形状不规则的连续优化问题，AHA 借助蜂鸟飞行模式的多样性——轴向飞行在少数维度上精细调整、对角飞行在部分维度上协同搜索、全向飞行在所有维度上同步偏移——能够根据当前解空间的局部几何特性自主调节探索的粒度与方向，克服了 PSO 在高维空间中速度惯性过强导致"贴墙飞"的缺陷以及 ACOR 高斯核在多峰地形中过早收缩的风险。

==== 算法数学模型

*路径编码与搜索空间构造。* 与前述 PSO、ACO、GA 及 MSA 保持一致，将无人机从起点 $bold(S)$ 至终点 $bold(T)$ 的飞行路径离散为 $N$ 个中间航点，每个蜂鸟个体（即食物源）编码为 $2N$ 维实数向量 $bold(x)_i = (x_1, y_1, dots, x_N, y_N)^T in bb(R)^(2N)$。候选解的搜索范围通过基线扰动策略限定——沿 $bold(S)$ 与 $bold(T)$ 连线等比例生成基线航点，围绕基线在带宽为 $b = max(3 sigma_0, 1.2 thin bar(delta), 80)$ 的带状可行域内构造各维度的独立上下界 $bold(x)_L$ 和 $bold(x)_U$。

*访问表与记忆机制。* AHA 最具辨识度的组件是其访问表（Visit Table），用于模拟蜂鸟对食物源回访间隔的空间记忆。设种群规模为 $n$，访问表 $bold(V T) in bb(R)^(n times n)$ 为一非对称矩阵，其中元素 $V T_(i, j)$ 记录蜂鸟 $i$ 自上次访问食物源 $j$ 以来所经过的迭代次数。初始化时，对角线元素置为 $"null"$（不可自访问），非对角线元素均置为 0。每当蜂鸟 $i$ 选择食物源 $j$ 作为引导目标并进行位置更新后，执行如下三条更新规则：
- $V T_(i, j) arrow 0$（刚被访问的食物源归零）；
- $V T_(i, k) arrow V T_(i, k) + 1$，$forall k != j$（其余食物源的未访问时间递增）；
- $V T_(*, i) arrow max_k V T_(*, k) + 1$（蜂鸟 $i$ 被其他蜂鸟标记为"近期有活动"）。

蜂鸟 $i$ 在选择目标食物源时，从访问表第 $i$ 行中选出 $V T_(i, j)$ 值最大者——即距当前个体最久未被访问的食物源。若存在多个并列最大值，则选取其中适应度最优者。该机制实现了探索与开发的自动均衡：每个个体天然倾向于光顾长期被忽略的解区域（全局探索），而精英解由于被频繁选为引导目标，其周围的局部搜索密度自然升高（局部开发）。

*飞行方向向量的构造。* AHA 定义了三种飞行模式，通过方向向量 $bold(D) in {0, 1}^(2N)$（各维度取值为 0 或 1）控制蜂鸟在搜索空间中的移动自由度：

（1）*轴向飞行*：从 $2N$ 个维度中随机选定一个维度 $d^"*" ~ cal(U){1, 2, dots, 2N}$，设置 $D_(d^"*") = 1$，其余维度 $D_j = 0$。轴向飞行模拟蜂鸟沿单一坐标轴的前进-后退机动，适合在已定位的优质解附近进行单维度的精细调优。

（2）*对角飞行*：设参与飞行的维度数量 $n_d in [2, floor(r_1 dot (2N - 2)) + 1]$，从 $2N$ 个维度中随机选取 $n_d$ 个，对应位置置 1，其余置 0。对角飞行模拟蜂鸟在多个维度上的协同偏移，适合在解空间中等尺度范围内进行交叉探索。其中 $r_1$ 为 $(0, 1]$ 区间随机数。

（3）*全向飞行*：所有 $2N$ 个维度均置 1，即 $bold(D) = (1, 1, dots, 1)^T$。全向飞行模拟蜂鸟全方位的空间位移，在搜索早期有助于快速逃离局部最优。

每轮迭代中，以等概率（各 1/3）随机选取上述三种飞行模式之一，这一设计保证了三类搜索行为的期望执行频率均衡。

*引导觅食策略。* 引导觅食模拟蜂鸟飞向选定的目标食物源进行采蜜。设蜂鸟 $i$ 当前位于食物源 $bold(x)_i$，其通过访问表选择的目标食物源为 $bold(x)_("tar")$（$"tar" != i$），则在引导觅食下生成候选位置：

$
bold(v)_i = bold(x)_("tar") + a dot bold(D) dot (bold(x)_i - bold(x)_("tar")) $ <eq:aha-guided>

其中 $a ~ cal(N)(0, 1)$ 为标准正态随机变量，$dot$ 表示逐元素乘积。引导因子 $a$ 在正值时驱动候选解偏向目标食物源方向，在负值时产生背离目标方向的随机跳跃，两者共同赋予搜索以双向探索能力。候选解经边界裁剪后评估适应度；若优于当前解，则替换之并更新访问表。

*领地觅食策略。* 领地觅食模拟蜂鸟在自身占据的食物源邻近区域内搜寻花蜜。蜂鸟 $i$ 在当前食物源 $bold(x)_i$ 附近依托方向向量 $bold(D)$ 进行局部扰动：

$
bold(v)_i = bold(x)_i + b dot bold(D) dot bold(x)_i $ <eq:aha-territorial>

式中 $b ~ cal(N)(0, 1)$ 为标准正态随机变量。$b$ 的正负值分别对应向外扩张与向内收缩两种搜索方向，方向向量 $bold(D)$ 的稀疏度决定了扰动在当前解空间中实际涉及的坐标维度数量。领地觅食是 AHA 局部精化能力的核心来源——当 $bold(D)$ 为轴向或对角飞行模式时，仅部分维度受到扰动，保留了解在其他维度上的已有优质结构。

引导觅食与领地觅食的切换亦采用等概率机制（各 0.5），即每只蜂鸟在每轮迭代中随机选择二者之一执行。

*迁徙觅食策略。* 若连续多轮迭代中蜂鸟 $i$ 所在区域的蜜源质量未获改善，其可能选择放弃当前领地并迁徙至解空间中的全新位置。AHA 以固定周期 $2n$ 迭代触发一次迁徙操作：将当前种群中适应度最差的个体（记为 $bold(x)_("worst")$）随机重置至搜索空间的任意位置：

$
bold(x)_("worst")^("new") = bold(x)_L + bold(r) dot (bold(x)_U - bold(x)_L) $ <eq:aha-migration>

随后对该个体的访问表行与列执行重置，使其重新融入种群的觅食循环。迁徙觅食的引入避免了种群在连续迭代中全部收敛至同一局部最优、丧失探索多样性的退化情形。沿用文献@AHA2022 的建议，迁徙周期取值 $2n$ 确保了种群在经历充分迭代（"每只蜂鸟平均被访问两次"）后才触发一次全局多样性注入。

*适应度函数。* 为保持算法间的公平对比，AHA 路径规划器采用与 PSO、ACO、GA、MSA 完全一致的五分量加权适应度函数 $J = alpha L_"norm" + beta S_"norm" + gamma R_"norm" + mu W_"norm" + lambda_f F_"norm"$，权重分配及各分项定义不变。每次适应度评估前将蜂鸟个体解码为 $N$ 个航点坐标，拼接起点与终点后形成完整飞行路径，计算路径长度、平滑性、综合风险、可靠性与可行性惩罚的归一化加权值。

*算法流程总结。* AHA 首先在基线扰动区域内随机生成 $n$ 个合法候选解，初始化访问表并评估全部个体的适应度。每轮迭代中，各蜂鸟依次完成：随机选择飞行方向向量 $bold(D)$ 的类型（轴向、对角或全向），随机选择觅食策略（引导或领地），按相应公式生成候选解并执行贪婪接受与访问表更新。此后，若当前迭代次数满足迁徙触发条件，则对最差个体执行随机重置。算法在达到预设最大迭代次数 $T$ 后终止，返回全局最优航点序列。

#pagebreak()
#algorithm(
  title: [人工蜂鸟算法（AHA）全局路径规划],
  input: [
    起始点 $bold(S)$，目标点 $bold(T)$，障碍物集合 $cal(O)$，
    航点数 $N$，种群规模 $n$，最大迭代次数 $T$。
  ],
  output: [全局最优航点序列 $bold(W)^"*" = {bold(w)_1^"*", dots, bold(w)_N^"*"}$。],
  [计算基线航点及带状搜索边界 $bold(x)_L$, $bold(x)_U$],
  [*for* $i in 1..n$ *do*],
  indent(
    [$bold(x)_i arrow$ 在 $[bold(x)_L, bold(x)_U]$ 内随机初始化],
    [计算适应度 $J(bold(x)_i)$],
  ),
  [初始化访问表：$V T_(i, i) arrow "null"$，$V T_(i, j) arrow 0$ $(i != j)$],
  [确定当前最优解 $bold(x)^*$ 及其适应度 $J^*$],
  [],
  [*for* $t in 1..T$ *do*],
  indent(
    [*for* $i in 1..n$ *do*],
    indent(
      [*步骤 1：选择飞行方向向量*],
      [$r arrow cal(U)(0, 1)$],
      [*if* $r < 1 / 3$ *then* $bold(D) arrow$ 对角飞行向量],
      [*else if* $r > 2 / 3$ *then* $bold(D) arrow$ 全向飞行向量],
      [*else* $bold(D) arrow$ 轴向飞行向量],
      [],
      [*步骤 2：选择觅食策略*],
      [*if* $cal(U)(0, 1) < 0.5$ *then*],
      indent(
        [在 $\{j: V T_(i, j) = max_k V T_(i, k)\}$ 中选适应度最优者为 $bold(x)_("tar")$],
        [$bold(v)_i arrow bold(x)_("tar") + cal(N)(0, 1) dot bold(D) dot (bold(x)_i - bold(x)_("tar"))$],
      ),
      [*else*],
      indent(
        [$bold(v)_i arrow bold(x)_i + cal(N)(0, 1) dot bold(D) dot bold(x)_i$],
      ),
      [],
      [*步骤 3：边界处理与贪婪选择*],
      [将 $bold(v)_i$ 裁剪至 $[bold(x)_L, bold(x)_U]$],
      [计算 $J(bold(v)_i)$],
      [*if* $J(bold(v)_i) < J(bold(x)_i)$ *then*],
      indent(
        [$bold(x)_i arrow bold(v)_i$，$J(bold(x)_i) arrow J(bold(v)_i)$],
        [$V T_(i, j) arrow 0$，$V T_(i, k) arrow V T_(i, k) + 1$ $(k != j)$],
        [$V T_(*, i) arrow max_m V T_(*, m) + 1$],
        [*if* $J(bold(x)_i) < J^*$ *then* 更新 $bold(x)^*$, $J^*$],
      ),
      [*else*],
      indent(
        [$V T_(i, j) arrow 0$，$V T_(i, k) arrow V T_(i, k) + 1$ $(k != j)$],
      ),
    ),
    [],
    [*步骤 4：迁徙操作*],
    [*if* $t "mod" 2n = 0$ *then*],
    indent(
      [$i_("worst") arrow arg max_i J(bold(x)_i)$],
      [$bold(x)_(i_("worst")) arrow bold(x)_L + cal(U)(bold(0), bold(1)) dot (bold(x)_U - bold(x)_L)$],
      [重置 $V T_(i_("worst"), *)$ 与 $V T_(*, i_("worst"))$],
      [更新适应度],
    ),
  ),
  [*return* $bold(W)^"*" arrow$ 解码自 $bold(x)^*$],
) <alg:aha-global>

*算法参数分析。* AHA 的参数结构极其简洁，仅需指定种群规模 $n$ 与最大迭代次数 $T$ 两个外部参数，航点数 $N$ 继承自统一的路径编码方案。这在群体智能算法中具有显著优势——PSO 需调节惯性权重 $omega$ 与两个学习因子 $(c_1, c_2)$；ACOR 需调节档案容量 $K$、集中度 $q$ 与蒸发率 $xi$；GA 需配置变异概率 $p_m$、变异强度 $sigma_0$ 及锦标赛规模 $k$；MSA 需指定回收因子 $P$、引力加速率 $rho$、初始失败率 $a$ 及性食同类概率 $P_c$。AHA 将飞行模式切换（等概率三分支）与觅食策略选择（等概率两分支）均设计为无参数自适应过程：访问表的滞后信息自动引导探索-开发平衡，迁徙周期的 $2n$ 取值通过种群规模间接确定，无需独立标定。典型配置为种群规模 $n = 50$，最大迭代次数 $T = 500$，航点数 $N = 15$。

*收敛性分析。* 从搜索遍历性角度，AHA 满足随机优化算法全局收敛的两个必要条件。第一，访问表驱动的引导觅食与周期性迁徙重置共同保证了搜索空间的渐近覆盖性——正态引导因子 $a ~ cal(N)(0, 1)$ 的非零尾部使得蜂鸟能以非零概率覆盖解空间中任意两点间的距离，而迁徙操作周期性地向搜索域注入全新随机解，杜绝了种群不可逆坍缩的可能。第二，贪婪接受策略（仅接受适应度严格改善的解）天然实现了精英保留。在访问表机制下，种群并非向单一全局最优收敛，而是形成以多个优质解为中心的多吸引域分布——当某食物源被遗忘过久，访问表将强制指派蜂鸟前往探索，从而维持解空间的遍历压力。当迭代次数趋于无穷时，AHA 以概率 1 收敛于全局最优解。

*计算复杂度分析。* 设种群规模为 $n$，问题维度 $D = 2N$，最大迭代次数为 $T$。每轮迭代中，各蜂鸟依次完成方向向量构造（$O(D)$）、候选解生成（$O(D)$）、边界裁剪（$O(D)$）及适应度评估（其复杂度由路径采样点数与障碍物数量决定，记为 $O(M)$）。访问表更新涉及对 $n$ 个元素的行操作，复杂度为 $O(n)$。迁徙操作涉及最差个体定位（$O(n)$）及随机重置（$O(D)$）。因此单次迭代复杂度为 $O(n(D + M + n))$，总时间复杂度为 $O(T n (D + M + n))$。空间复杂度主要来自存储 $n$ 个 $D$ 维个体及 $n times n$ 维访问表，为 $O(n D + n^2)$。与 PSO（$O(T n (D + M))$，空间 $O(n D)$）相比，AHA 因维护访问表引入了额外的 $O(T n^2)$ 时间开销与 $O(n^2)$ 空间开销。在路径规划场景中，由于航点数 $N$ 适中（$N = 15 ~ 20$，$D = 30 ~ 40$），种群规模通常取 $n = 50$，$n^2 = 2500$ 量级的额外开销在实际运行中可接受，AHA 的总运行时间与同参数配置的 MSA、GA 处于同一数量级。

  === AL-SHADE算法设计与实现

AL-SHADE（Adaptive L-SHADE）是由 Li 等人于2022年提出的一种改进微分进化算法@ALSHADE2022，其以 L-SHADE（带线性种群缩减的 SHADE 算法）为基底框架，通过引入加权档案均值引导的变异策略与自适应策略选择机制，实现了收敛精度与种群多样性之间的动态平衡。该算法的谱系可追溯至经典的差分进化算法（Differential Evolution, DE）——Storn 与 Price 于 1997 年提出的 DE 作为一种基于种群向量差分的随机搜索方法，因结构简单、不依赖梯度信息而在连续优化领域得到广泛应用。在 DE 的后续发展中，Tanabe 与 Fukunaga 先后提出了基于成功历史的自适应参数控制机制（SHADE，2013年）以及与之耦合的线性种群缩减策略（L-SHADE，2014年），使算法性能在 CEC 基准测试中达到新的高度。然而，L-SHADE 及其变体在求解高维多峰问题时仍面临探索-开发失衡的瓶颈：单一的 current-to-pbest/1 变异策略倾向于将搜索引导至当前最优解所在的局部区域，在适应度地形高度崎岖时容易导致种群多样性过早丧失。AL-SHADE 正是在此背景下，通过构建加权档案均值（Amean）引导的第二变异策略以及基于成功率反馈的自适应策略概率更新律，显著增强了算法在不同优化阶段自主切换搜索行为的能力。

对于无人机二维路径规划问题，AL-SHADE 的价值体现在两个层面。其一，其基于历史记忆的参数自适应机制无需人工标定 $F$ 和 $C R$，在高维航点坐标空间中能够根据适应度地形的局部特征自动调节变异尺度与交叉概率，克服了经典 DE 对手动参数配置高度敏感的问题。其二，双变异策略的竞争机制使算法在早期倾向于广度探索（借助 current-to-Amean/1 策略利用种群分布信息分散搜索），在后期自动收敛至深度开发（借助 current-to-pbest/1 策略围绕精英解精化），这一特性对于存在大量障碍物约束、可行域呈非凸狭长走廊形态的路径规划场景尤为重要。

==== 算法数学模型

*路径编码与搜索空间构造。* 与前述算法统一，将无人机飞行路径离散为 $N$ 个中间航点，每个个体编码为 $2N$ 维实数向量 $bold(x)_i = (x_1, y_1, dots, x_N, y_N)^T in bb(R)^(2N)$，其中 $i = 1, 2, dots, P$，$P$ 为当前种群规模。搜索空间的上下界 $bold(x)_L$、$bold(x)_U$ 由基线扰动策略构造——沿起点-终点连线等比例插入基线航点，围绕基线在带状半宽 $b = max(3 sigma_0, 1.2 thin bar(delta), 80)$ 内确定各维度的独立边界。

*差分进化基础操作。* AL-SHADE 继承 DE 的三步迭代范式——变异、交叉、选择。设第 $t$ 代种群中个体 $i$ 的当前解为 $bold(x)_i^t$（称为目标向量），变异操作生成供体向量 $bold(v)_i^t$，交叉操作将 $bold(v)_i^t$ 与 $bold(x)_i^t$ 重组为试验向量 $bold(u)_i^t$，选择操作在 $bold(x)_i^t$ 与 $bold(u)_i^t$ 之间取适应度较优者进入下一代：

$
bold(x)_i^(t+1) = cases(
  bold(u)_i^t, "if " J(bold(u)_i^t) <= J(bold(x)_i^t),
  bold(x)_i^t, "otherwise"
) $ <de-selection>

这一贪婪接受机制保证了种群最优适应度的单调非增性。

*双变异策略与加权档案均值。* AL-SHADE 区别于 L-SHADE 的核心创新在于引入了两个互补的变异策略，并由自适应概率 $S_p in [0.1, 0.9]$ 调度二者的执行比例。

策略一为经典的 current-to-pbest/1 变异，由 SHADE 继承而来：

$
bold(v)_i^t = bold(x)_i^t + F dot (bold(x)_("pbest")^t - bold(x)_i^t) + F dot (bold(x)_(r_1)^t - bold(x)_(r_2)^t) $ <mutation-pbest>

其中 $bold(x)_("pbest")^t$ 是从当前种群按适应度排序的前 $p_("best") = 10%$ 个个体中随机选取的精英解，$bold(x)_(r_1)^t$ 为从种群中随机选取的个体（$r_1 != i$），$bold(x)_(r_2)^t$ 为从种群与外部档案的并集 $cal(P) union cal(A)$ 中随机选取的个体（$r_2 != r_1 != i$）。外部档案 $cal(A)$ 存储了历代被淘汰的父代向量，其容量上限 $N_A = r_("arc") dot P$（$r_("arc") = 2.5$），当满载时随机替换。$cal(A)$ 的存在为变异差分项提供了历史遗传信息，有效延缓了种群的收敛速度。

策略二为 AL-SHADE 独创的 current-to-Amean/1 变异：

$
bold(v)_i^t = bold(x)_i^t + F dot (bold(x)_("mean")^t - bold(x)_i^t) + F dot (bold(x)_(r_1)^t - bold(x)_(r_2)^t) $ <mutation-amean>

与策略一仅依赖单一精英个体不同，策略二通过加权档案均值 $bold(x)_("mean")^t$ 综合了多个历史较优解的空间分布信息。$bold(x)_("mean")^t$ 的计算方法为：从外部档案中选取适应度最优的前 $s = max(1, floor(|cal(A)| / 2))$ 个解，按排名赋予对数递减权重 $w_k = ln(s + 0.5) - ln(k)$（$k = 1, 2, dots, s$），经归一化后加权求和：

$
bold(x)_("mean")^t = sum_(k=1)^s tilde(w)_k bold(x)_(k)^("arc"), quad tilde(w)_k = w_k / sum_(m=1)^s w_m $ <eq:archive-weighted-mean>

对数权重使得排名靠前的解对均值的贡献远大于排名靠后的解，同时允许中等排名解施加适度影响——这一设计在"聚合精英信息"与"保留分布多样性"之间实现了平滑折中。策略二的变异差分项 $(bold(x)_("mean")^t - bold(x)_i^t)$ 引导个体向种群精英位置的加权中心移动，而非向某单一最优解收缩，因此在优化早期能维持更宽广的搜索覆盖面，在可行域呈非凸多连通形态的障碍物环境中尤为有利。

*自适应策略概率调节。* 两种变异策略的竞争力随优化进程动态变化：在早期种群分散时，策略二因能综合多方信息而搜索效率更高；在后期种群收敛时，策略一围绕精英解的精细搜索更为有效。AL-SHADE 通过成功率驱动的自适应机制自动调整策略选择概率 $S_p$。记第 $t$ 代中策略一和策略二的执行次数分别为 $n_1^("all")$ 和 $n_2^("all")$，其中成功产生优于或等于父代解的试验向量的次数分别为 $n_1^("suc")$ 和 $n_2^("suc")$，则两个策略的成功率分别为 $r_1 = n_1^("suc") / n_1^("all")$、$r_2 = n_2^("suc") / n_2^("all")$。策略概率的更新律为：

$
S_p arrow S_p + 0.05 dot (1 - S_p) dot (r_1 - r_2) dot frac(t, T) $ <eq:strategy-prob-update>

式中修正因子 $S_p$ 约束在 $[0.1, 0.9]$ 区间内。更新律的物理含义为：若策略一相对更成功（$r_1 > r_2$），则 $S_p$ 增大，增加策略一的被选概率以聚焦精化；若策略二相对更成功，则 $S_p$ 减小，增加策略二的被选概率以加强探索。时间因子 $t / T$ 使概率调整的步长随迭代推进而递增——在早期保留较大的策略切换灵活性，在后期加速收敛至优势策略。

*参数自适应：成功历史记忆。* AL-SHADE 沿用 SHADE 的成功历史参数自适应框架。维护两个长度为 $H = 6$ 的记忆数组 $bold(M)_F$ 和 $bold(M)_("CR")$，分别存储历史成功变异因子 $F$ 和交叉概率 $C R$ 的统计信息。每一代中，为个体 $i$ 生成 $C R_i$ 时从 $bold(M)_("CR")$ 中随机选取一个记忆槽 $h_i$，以 $M_(C R, h_i)$ 为均值、0.1 为标准差进行正态采样并截断至 $[0, 1]$。生成 $F_i$ 时以 $M_(F, h_i)$ 为位置参数、0.1 为尺度参数进行柯西采样，若 $F_i <= 0$ 则重新采样，若 $F_i > 1$ 则截断为 1。柯西分布的重尾特性使得 $F$ 以较高概率在均值附近取值的同时，保留生成较大跳跃步长（$F > 1$）的非零可能，有助于种群跳出局部最优。

当代结束后，收集所有成功产生更优解的个体对应的 $F$ 与 $C R$ 值，形成成功集合 $cal(S)_F$ 和 $cal(S)_("CR")$。以适应度改进量 $Delta J_i = |J(bold(u)_i^t) - J(bold(x)_i^t)|$ 作为权重，采用加权 Lehmer 均值更新第 $k$ 个记忆槽（$k$ 按轮转索引遍历 $0, 1, dots, H-2$，第 $H-1$ 槽保持 0.9 不变作为"热启动"）：

$
M_(F, k)^("new") = cases(
  frac(sum_(i in cal(S)) tilde(w)_i F_i^2, sum_(i in cal(S)) tilde(w)_i F_i), "if " cal(S) != emptyset,
  M_(F, k)^("old"), "otherwise"
) $ <lehmer-update>

$M_(C R, k)$ 的更新公式同理，其中 $tilde(w)_i = Delta J_i / sum_(j in cal(S)) Delta J_j$。Lehmer 均值（二次矩与一次矩之比）对极端值具有天然的抗扰能力，使得记忆更新对偶发的异常成功参数不敏感。若某代中所有成功个体的 $C R$ 均为 0，则在对应记忆槽中置入 $-1$ 作为"终止标记"，之后从该槽采样的个体将 $C R$ 硬设为 0，强化在该搜索阶段完全依赖父代坐标的保守交叉行为。

*二项交叉。* 变异供体向量 $bold(v)_i^t$ 与目标向量 $bold(x)_i^t$ 通过二项交叉（binomial crossover）重组为试验向量 $bold(u)_i^t$：

$
u_(i, j)^t = cases(
  v_(i, j)^t, "if " "rand"(0, 1) < C R_i space "or" space j = j_("rand"),
  x_(i, j)^t, "otherwise"
) $ <binomial-crossover>

其中 $j in {1, 2, dots, 2N}$ 为维度索引，$j_("rand")$ 为随机选定的一个维度（保证 $bold(u)_i^t$ 至少有一个分量来自 $bold(v)_i^t$，防止试验向量与目标向量完全相同导致搜索停滞）。$C R_i$ 控制变异信息在试验向量中的占比——$C R_i$ 越大，试验向量越倾向于继承变异供体的基因。

*边界处理。* 变异操作可能产生超出搜索边界的解。AL-SHADE 采用中点反射修正策略：若某维度值 $v_(i, j)$ 超出下界，则修正为 $v_(i, j) arrow (x_(i, j) + L_j) / 2$；若超出上界，则修正为 $v_(i, j) arrow (x_(i, j) + U_j) / 2$。该策略将越界分量拉回至父代值与边界值的中点，比硬截断更有利于保留变异方向的梯度信息。

*线性种群缩减。* AL-SHADE 从 L-SHADE 继承了线性种群规模缩减机制（Linear Population Size Reduction, LPSR）。设初始种群规模为 $P_("init")$，最小种群规模为 $P_("min") = 4$，则在第 $t$ 代的目标种群规模为：

$
P_t = "round"lr(P_("init") - (P_("init") - P_("min")) dot frac(t, T)) $ <eq:lpsr>

其中 $T$ 为最大迭代次数。每代结束时，若当前种群规模超过 $P_t$，则按适应度升序保留前 $P_t$ 个个体，其余淘汰。LPSR 的机制优势在于：迭代早期的大规模种群提供充裕的搜索多样性，中后期逐步缩减的种群将算力集中于精英解的局部精化，同时自然降低了每代的计算开销。外部档案容量 $N_A = r_("arc") dot P_t$ 随种群同步缩减。

*适应度函数。* AL-SHADE 路径规划器采用与 PSO、ACO、GA、MSA、AHA 完全一致的五分量加权适应度函数 $J = alpha L_"norm" + beta S_"norm" + gamma R_"norm" + mu W_"norm" + lambda_f F_"norm"$，权重分配及各分项定义不变。

*算法流程总结。* AL-SHADE 首先生成 $P_("init")$ 个基线扰动初始解并评估适应度。初始化外部档案、成功历史记忆 $bold(M)_F$ 和 $bold(M)_("CR")$（末槽 0.9，其余 0.5），策略概率 $S_p = 0.5$。每代迭代中，依次为每个个体：从记忆槽采样 $F_i$ 和 $C R_i$，以概率 $S_p$ 选择策略一（current-to-pbest/1）或策略二（current-to-Amean/1），生成变异供体向量 $bold(v)_i^t$，经二项交叉得试验向量 $bold(u)_i^t$，评估并执行贪婪选择。成功后，将淘汰的父代向量存入外部档案，记录成功 $F_i$、$C R_i$ 与 $Delta J_i$。代末按加权 Lehmer 均值更新记忆槽，按成功率反馈调整 $S_p$，按 LPSR 缩减种群规模。算法达到 $T$ 代后终止，返回全局最优航点序列。

#pagebreak()
#algorithm(
  title: [AL-SHADE 全局路径规划算法],
  input: [
    起始点 $bold(S)$，目标点 $bold(T)$，障碍物集合 $cal(O)$，
    航点数 $N$，初始种群规模 $P_("init")$，最小种群规模 $P_("min")$，
    最大迭代次数 $T$，历史记忆容量 $H$，精英比例 $p_("best")$，
    档案比率 $r_("arc")$，初始策略概率 $S_p^0$。
  ],
  output: [全局最优航点序列 $bold(W)^"*" = {bold(w)_1^"*", dots, bold(w)_N^"*"}$。],
  [计算基线航点及带状搜索边界 $bold(x)_L$, $bold(x)_U$],
  [$P arrow P_("init")$],
  [*for* $i in 1..P$ *do*],
  indent(
    [$bold(x)_i arrow$ 在 $[bold(x)_L, bold(x)_U]$ 内随机初始化],
    [计算适应度 $J(bold(x)_i)$],
  ),
  [按适应度升序排列种群],
  [$cal(A) arrow emptyset$，$N_A arrow r_("arc") dot P$],
  [$bold(M)_F arrow (0.5, dots, 0.5, 0.9)$，$bold(M)_("CR") arrow (0.5, dots, 0.5, 0.9)$],
  [$S_p arrow 0.5$, $quad k arrow 0$],
  [],
  [*for* $t in 1..T$ *do*],
  indent(
    [计算加权档案均值 $bold(x)_("mean")^t$],
    [$cal(S)_F arrow emptyset$, $cal(S)_("CR") arrow emptyset$, $cal(S)_(Delta J) arrow emptyset$],
    [$n_1^("all") arrow 0$, $n_2^("all") arrow 0$, $n_1^("suc") arrow 0$, $n_2^("suc") arrow 0$],
    [],
    [*for* $i in 1..P$ *do*],
    indent(
      [$h_i arrow$ 从 $0..H-1$ 中随机选取],
      [$C R_i arrow$ 截断至 $[0, 1]$ 的正态采样 $cal(N)(M_(C R, h_i), 0.1)$],
      [*repeat* $F_i arrow "Cauchy"(M_(F, h_i), 0.1)$ *until* $F_i > 0$; $F_i arrow min(F_i, 1)$],
      [],
      [*if* $cal(U)(0, 1) < S_p$ *then*],
      indent(
        [按式@eqt:mutation-pbest 执行 current-to-pbest/1 变异],
        [$n_1^("all") arrow n_1^("all") + 1$, $quad "tag" arrow 1$],
      ),
      [*else*],
      indent(
        [按式@eqt:mutation-amean 执行 current-to-Amean/1 变异],
        [$n_2^("all") arrow n_2^("all") + 1$, $quad "tag" arrow 2$],
      ),
      [越界分量中点反射修正],
      [按式@eqt:binomial-crossover 生成试验向量 $bold(u)_i^t$],
      [将 $bold(u)_i^t$ 各维度限制在 $[bold(x)_L, bold(x)_U]$ 内],
      [计算 $J(bold(u)_i^t)$],
      [],
      [*if* $J(bold(u)_i^t) < J(bold(x)_i^t)$ *then*],
      indent(
        [将 $F_i$, $C R_i$, $Delta J_i = |J(bold(u)_i^t) - J(bold(x)_i^t)|$ 加入各成功集合],
        [若 $"tag" = 1$ 则 $n_1^("suc") arrow n_1^("suc") + 1$，否则 $n_2^("suc") arrow n_2^("suc") + 1$],
        [将被淘汰的 $bold(x)_i^t$ 存入 $cal(A)$（若 $|cal(A)| >= N_A$ 则随机替换）],
        [$bold(x)_i^t arrow bold(u)_i^t$, $quad J(bold(x)_i^t) arrow J(bold(u)_i^t)$],
      ),
      [*else if* $J(bold(u)_i^t) == J(bold(x)_i^t)$ *then*],
      indent(
        [$bold(x)_i^t arrow bold(u)_i^t$],
      ),
    ),
    [],
    [*步骤：参数记忆更新*],
    [*if* $cal(S)_F != emptyset$ *then*],
    indent(
      [以 $Delta J_i$ 为权重，按式@eqt:lehmer-update 更新 $M_(F, k)$ 和 $M_(C R, k)$],
      [$k arrow (k + 1) mod (H - 1)$],
    ),
    [*else if* 所有成功 $C R$ 为 0 *then* $M_(C R, k) arrow -1$],
    [],
    [*步骤：自适应策略概率更新*],
    [*if* $n_1^("all") > 0$ *and* $n_2^("all") > 0$ *then*],
    indent(
      [$r_1 arrow n_1^("suc") / n_1^("all")$, $quad r_2 arrow n_2^("suc") / n_2^("all")$],
      [$S_p arrow S_p + 0.05 dot (1 - S_p) dot (r_1 - r_2) dot (t / T)$],
      [$S_p arrow "clip"(S_p, 0.1, 0.9)$],
    ),
    [],
    [*步骤：线性种群缩减*],
    [$P_("target") arrow "round"(P_("init") - (P_("init") - P_("min")) dot t / T)$],
    [*if* $P_("target") < P$ *then*],
    indent(
      [按适应度升序保留前 $P_("target")$ 个个体],
      [$P arrow P_("target")$, $quad N_A arrow r_("arc") dot P$],
      [$cal(A) arrow$ 若 $|cal(A)| > N_A$ 则按适应度升序截断至 $N_A$],
    ),
  ),
  [*return* $bold(W)^"*" arrow$ 解码自种群最优个体],
) <alg:alshade-global>

*算法参数分析。* AL-SHADE 的外部可调参数数量介于 PSO/GA 与 AHA 之间——需预设初始种群规模 $P_("init")$、最小种群规模 $P_("min")$、最大迭代次数 $T$、历史记忆容量 $H$、精英比例 $p_("best")$ 及档案比率 $r_("arc")$。其中 $P_("min") = 4$ 为 DE 变异操作所需的最小种群下限（至少需要 4 个互异个体），$H = 6$ 与 $p_("best") = 0.1$ 分别取自 SHADE 原论文的标准推荐值，$r_("arc") = 2.5$ 取自 L-SHADE 的外部档案配置。实际应用中仅需调节 $P_("init")$ 与 $T$ 两个主参数。典型配置为 $P_("init") = 500$，$T = 500$，航点数 $N = 20$，$P_("min") = 4$，$H = 6$，$p_("best") = 0.1$，$r_("arc") = 2.5$。$F$ 和 $C R$ 的取值完全由成功历史记忆自适应调控，无需人工设定——这是 AL-SHADE 区别于 PSO 和 GA 的显著优势。

*收敛性分析。* AL-SHADE 的全局收敛性由三个层面共同保证。第一，DE 框架的贪婪选择机制（式@eqt:de-selection）天然实现精英保留，历代最优解单调改进。第二，变异因子 $F$ 的柯西采样分布具有重尾特性，$P(F > 1) > 0$ 意味着变异步长可以超越父代间的差分幅值，赋予个体以非零概率跳出任意局部极值的能力。第三，外部档案 $cal(A)$ 存储历史淘汰解，为变异差分项提供超出当前种群的遗传多样性，结合 LPSR 早期大种群→后期小种群的平滑过渡，算法在搜索全程维持了渐近遍历性。当 $T -> oo$ 时，AL-SHADE 以概率 1 收敛于全局最优解。

*计算复杂度分析。* 设当前种群规模为 $P$，问题维度 $D = 2N$，外部档案容量为 $N_A$。每代各主要操作的时间复杂度为：加权档案均值计算 $O(N_A log N_A)$（排序取前 $s$ 个），个体变异 $O(D)$，交叉 $O(D)$，适应度评估 $O(M)$（$M$ 由路径采样密度与障碍物数量决定），参数记忆更新 $O(|cal(S)|)$（$|cal(S)| <= P$），策略概率更新 $O(1)$，种群缩减排序 $O(P log P)$。单代总复杂度约为 $O(P(D + M) + P log P + N_A log N_A)$。由于 $P$ 按 LPSR 线性缩减，$T$ 代的总时间复杂度介于 $O(T P_("init")(D + M + log P_("init")))$ 和 $O(T P_("min")(D + M))$ 之间。空间复杂度主要源于存储 $P$ 个 $D$ 维个体、$N_A$ 个 $D$ 维档案项及 $2H$ 个记忆标量，为 $O((P + N_A) D)$，与 PSO（$O(P D)$）处于同一量级但常数略高。实际运行中，AL-SHADE 因每代需进行种群排序与档案维护，总耗时约比 PSO 高 $15% ～ 25%$，但其参数自适应特性省去了手动调参所需的多次重复实验，整体效率在工程实践中更具竞争力。

 == 局部避障算法设计与实现

前文所述的全局路径规划器（PSO、ACO、GA、MSA、AHA、AL-SHADE）为无人机集群提供了宏观的参考航点序列，然而在实际飞行中，集群需面对两类全局规划难以预先穷举的局部风险：一是障碍物分布信息的有限精度（传感器探测范围受限或环境动态变化），二是多机编队保持与单机避障之间的实时耦合冲突。为此，在全局规划层之下构建局部避障层，以人工势场法（Artificial Potential Field, APF）为核心，通过改进的斥力场设计与前视预测机制，为每架无人机实时生成局部修正加速度，弥补全局路径在动态环境下的安全裕度不足。

==== 改进人工势场法

经典人工势场法由 Khatib 于 1986 年提出，其基本原理是在工作空间中构造虚拟势场：目标点产生引力场，障碍物产生斥力场，无人机在合力驱动下向目标运动的同时绕开障碍物。该方法结构简洁、实时性好，但在复杂障碍物分布下存在两个固有缺陷：一是目标不可达问题（Goal Non-Reachable with Obstacles Nearby, GNRON），即当目标位于障碍物附近时，斥力可能压倒引力导致无人机无法逼近目标；二是局部极小值（Local Minima）问题，即在"U 型"障碍物或狭窄通道中合势场为零，无人机陷入来回振荡或静止不前的死锁状态。本节针对上述两个问题，分别从斥力场建模与前视自适应减速两个维度对经典 APF 进行改进。

*障碍物斥力场的切向旋转增强。* 经典 APF 的斥力方向严格沿障碍物中心到无人机的径向线，在无人机与障碍物、目标三者共线时，合力方向仅沿该直线，无法产生绕行运动。本节在径向斥力分量之外引入切向旋转分量，构成矢量复合斥力场。

设无人机 $i$ 的当前位置为 $bold(p)_i = (x_i, y_i)^T$，速度矢量为 $bold(v)_i = (v_(x i), v_(y i))^T$。对于当前探测范围内的全部障碍物，首先筛选出距无人机最近的障碍物 $O^"*"$（以间隙距离 $d = norm(bold(p)_i - bold(c)_("obs")) - R_("obs")$ 为度量，其中 $bold(c)_("obs")$ 和 $R_("obs")$ 分别为障碍物中心与半径）。斥力的作用范围定义为 $d_("inf") = R_("obs") + d_("safe") + 50$，其中 $d_("safe")$ 为预设安全距离（取 20 m）。当 $d >= d_("inf")$ 时斥力为零；当 $d < d_("inf")$ 时，斥力由径向分量 $bold(f)_("rad")$ 和切向分量 $bold(f)_("tan")$ 合成。

径向斥力沿无人机指向障碍物中心的单位向量 $bold(e)_r$ 方向，其幅值由归一化距离强度 $sigma = max(0, (d_("inf") - d) / d_("inf"))$ 调控：

$
bold(f)_("rad") = k_r sigma bold(e)_r, quad bold(e)_r = frac(bold(p)_i - bold(c)_("obs"), norm(bold(p)_i - bold(c)_("obs"))) $ <radial-repulsion>

式中 $k_r = 25$ 为径向斥力增益。$sigma in [0, 1)$ 随无人机接近障碍物而单调增大，使斥力在障碍物边缘达到最大。

切向斥力的设计是本改进的核心。取 $bold(e)_r$ 的逆时针正交单位向量 $bold(e)_t = (-e_(r, y), e_(r, x))^T$，但为保证切向力方向与当前飞行方向一致（引导无人机顺势绕过而非逆势折返），将 $bold(e)_t$ 与速度矢量进行点积校核：若 $bold(v)_i dot bold(e)_t < 0$，则将 $bold(e)_t$ 取反。切向斥力为：

$
bold(f)_("tan") = k_t sigma bold(e)_t $ <tangential-repulsion>

其中 $k_t = 15$ 为切向力增益。切向分量的引入使得合力方向偏离径向线，形成沿障碍物边缘的旋转趋势，从而在"U 型"障碍物或狭窄通道中赋予无人机主动绕行的运动分量，有效降低局部死锁概率。

复合斥力为两分量之和 $bold(f)_("rep") = bold(f)_("rad") + bold(f)_("tan")$。当无人机在开阔区域远离障碍物时，$sigma ≈ 0$ 导致斥力自动退化为零，避免对集群编队产生不必要的扰动；在紧邻障碍物时，径向分量主导安全避障，切向分量提供偏向绕行引导，二者协同实现平滑规避。

*前视预测减速机制。* GNRON 问题的根源在于目标附近障碍物的斥力抵消了引力，导致无人机在终点前停滞。本节引入基于运动预测的前视安全评估——沿无人机当前速度方向，以固定时间步长向前模拟一段预测时域内的轨迹，计算该预测轨迹上距各障碍物的最小间隙。若预测间隙小于减速阈值，则按比例降低引力参考速度的幅值，保证无人机以安全速度靠近目标区域。

具体地，取预测视距 $T_h = 5.0$ s，将其等分为 $N_s = 25$ 个微段，微段时间步长为 $Delta t_s = T_h / N_s$。以当前位置为起点，假设速度恒定，逐段向前递推得到 $N_s$ 个预测位置点。对每个预测点计算其距各障碍物的间隙，取全预测时域的最小值记为 $d_("pred")$：

$
d_("pred") = min_(k=1)^(N_s) min_(O in cal(O)) lr(norm(bold(p)_i + k Delta t_s bold(v)_i - bold(c)_O) - R_O) $ <predicted-clearance>

设减速阈值为 $d_("slow") = 2.5 d_("safe") = 50$ m，前视减速因子 $lambda$ 定义为：

$
lambda = "clip"lr(frac(d_("pred"), d_("slow")), space 0.2, space 1.0) $ <speed-reduction>

当 $d_("pred") >= d_("slow")$（前方安全）时 $lambda = 1$，引力速度全额保留；当 $d_("pred") -> 0$ 时 $lambda arrow 0.2$，引力速度降至巡航值的 20%，确保无人机在密集障碍区以低速谨慎穿行而非强行高速逼近。将 $lambda$ 作用于导航参考速度 $bold(v)_("ref")$，得到经安全缩放后的有效参考速度 $bold(v)_("ref")^("eff") = lambda bold(v)_("ref")$。

*目标引力场。* 引力场驱动无人机沿全局路径航点序列飞行。设当前目标航点为 $bold(p)_("tgt")$（来自全局规划器输出经 APF 局部修正后的下一航点），无人机 $i$ 的位置为 $bold(p)_i$，则目标方向、期望巡航速度及引力加速度指令分别为：

$
"direction" arrow bold(p)_("tgt") - bold(p)_i, quad "distance" arrow norm("direction") $ <target-direction>

$
bold(v)_("ref") = v_("cruise") dot frac("direction", "distance"), quad v_("cruise") = 25 space "m/s" $ <ref-velocity>

$
bold(u)_("nav") = dot(bold(v))_("ref") - k_3 thin (bold(v)_i - bold(v)_("ref")^("eff")) $ <nav-guidance>

当无人机距目标航点小于 50 m 时，巡航速度按比例线性缩减（$v = max(5, 25 dot d / 50)$），实现平滑的航点切换减速；当距最终目标小于 1 m 时，引力置零，无人机由编队控制接管完成最终的精确悬停。

==== 综合控制律与动力学约束

每架无人机 $i$ 在每一控制周期 $Delta t = 0.1$ s 内，接收来自三个功能通道的加速度指令：

$
bold(u)_i^("cmd") = bold(u)_i^("cons") + bold(u)_("nav") + bold(f)_("rep") $ <integrated-control>

其中 $bold(u)_i^("cons")$ 为第二章所述基于改进一致性协议（时延-切换拓扑）的编队控制加速度，$bold(u)_("nav")$ 为式@eqt:nav-guidance 给出的目标引力与速度跟踪加速度，$bold(f)_("rep")$ 为式@eqt:radial-repulsion 和式@eqt:tangential-repulsion 合成的障碍物复合斥力加速度（单位质量归一化）。三者以加性方式并行叠加，实现"编队保持—目标引导—局部避障"的实时耦合。

在输出至自动驾驶仪之前，加速度指令需通过两级物理约束校验。第一级为速度约束：预估下一时刻的速度 $bold(v)_i(t + Delta t) = bold(v)_i(t) + bold(u)_i^("cmd") Delta t$，若其范数超过最大允许速度 $v_("max") = 80$ m/s，则按比例收缩各分量：$bold(u)_i^("cmd") arrow (v_("max") / norm(bold(v)_i(t + Delta t))) bold(u)_i^("cmd")$。第二级为加速度约束：若 $norm(bold(u)_i^("cmd")) > a_("max") = 4g$，则等比例缩放：$bold(u)_i^("cmd") arrow (a_("max") / norm(bold(u)_i^("cmd"))) bold(u)_i^("cmd")$。经约束映射后的可行加速度指令通过式@eqt:control-to-autopilot 转换为一阶惯性自动驾驶仪的速度指令，完成从控制计算到物理执行的闭环。

*控制优先级分析。* 在实际执行中，三个加速度通道之间的优先级通过各分量的增益幅值间接体现。障碍物斥力增益（$k_r = 25$、$k_t = 15$）显著高于编队控制增益（$k_1 = 0.8$、$k_2 = 1.2$），使得在近距离遭遇障碍物时（$sigma -> 1$），斥力 $bold(f)_("rep")$ 的幅值（约 40 N/kg 级）远大于编队控制力（约 1–5 N/kg 级），自然形成"安全优先"的优先级次序：避障 > 目标引导 > 编队保持。当 $sigma -> 0$（远离障碍物）时，斥力自动归零，编队控制与目标引导恢复主导，集群回归稳定编队巡航。

*分层耦合架构总结。* 局部避障层与全局规划层、编队控制层之间形成"上-中-下"三层耦合架构。全局规划层以数秒至数十秒的周期运行，输出覆盖全程的参考航点序列；编队控制层以 0.1 s 周期运行，维持集群几何构型的稳定；局部避障层嵌入同一 0.1 s 控制周期内，以加性加速度修正的方式对前两层指令进行在线增补。上层输出的全局航点作为本层的目标引力源，本层输出的安全修正加速度与编队加速度矢量叠加后共同驱动无人机运动。该架构保证了路径规划的全局最优性与避障反应的高频实时性之间的解耦与协同——全局层"看得远但不快"，局部层"看得不远但足够快"。

#pagebreak()
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

*控制参数分析与标定。* APF 局部避障器涉及三个主参数：径向斥力增益 $k_r$、切向力增益 $k_t$ 和安全距离 $d_("safe")$。$k_r = 25$ 的取值原则为——在 $d_("safe") = 20$ m 的缓冲区边缘（$sigma ≈ 0.5$），径向斥力约 12.5 N/kg，足以在两到三个控制周期内显著改变 80 m/s 巡航无人机的航向。$k_t = 15$ 的取值使切向分量约为径向分量的 60%，该比例经过仿真调试确定：过小（< 30%）则绕行效果不足，过大（> 90%）则可能引导无人机过度偏离目标方向。$d_("safe") = 20$ m 综合考虑了编队包络半径（约 60 m）和 GPS/惯导组合定位误差（约 5–10 m），为障碍物周围保留两级缓冲区——$d_("safe")$ 内为强斥力急避区，$d_("safe")$ 至 $d_("inf")$ 之间为线性衰减预警区。

前视预测参数 $T_h = 5.0$ s 和 $N_s = 25$ 的配置使预测精度约为 0.2 s/段，对应 80 m/s 速度下约 16 m/段的预测空间分辨率。该分辨率足以提前一到两个预测段发现前方障碍物。减速阈值 $d_("slow") = 2.5 d_("safe") = 50$ m 与下限 $lambda_("min") = 0.2$ 的组合确保无人机在进入安全缓冲区之前已开始降速，避免高速冲入急避区后因机动能力饱和而无法及时转向。

= 算法改进

== AL-SHADE 算法的三项改进：TALG 框架

原生 AL-SHADE 在路径规划中的核心困境可归结为三点。第一，航点序列的离散编码方式天然不具备路径连续性约束——各航点坐标独立演化，即使相邻两代在搜索空间中接近，其解码后的路径仍可能出现折线式的剧烈拐弯，导致路径平滑性项 $S$ 的优化与长度项 $L$ 的优化相互冲突。第二，变异因子 $F$ 的柯西采样对全体个体一视同仁，无法感知障碍物的空间分布——在开阔区域需要的小步长精细搜索与在障碍物密集区域需要的大步长跳跃逃离之间缺少自适应切换机制。第三，外部档案 $cal(A)$ 的随机替换策略可能存入大量重复或高度相似的解，造成档案多样性的隐性退化，削弱 current-to-Amean/1 变异策略所依赖的种群分布广度。本节针对上述三个问题，分别提出 B 样条曲线参数化、种群威胁度驱动的 Lévy-Gaussian 双态 $F$ 生成以及基于欧氏距离的档案相似度去重共三项改进，三者统称为 TALG（Threat-Adaptive Lévy-Gaussian）框架。

=== B 样条曲线参数化路径建模

B 样条（B-spline）是一种以控制点序列定义的分段多项式参数曲线，其核心优势在于：控制点仅影响曲线局部形状（局部支撑性），且 $k$ 次 B 样条曲线在节点区间内部天然具备 $C^(k-1)$ 连续性。对于无人机路径规划而言，这意味着仅需优化少量控制点的坐标位置，即可自动获得一条处处光滑、无折角的飞行轨迹——从根源上消解了航点离散编码与路径连续性之间的结构矛盾。

*数学定义。* 给定 $m+1$ 个控制点 $bold(c)_0, bold(c)_1, dots, bold(c)_m in bb(R)^2$ 和节点向量 $bold(U) = (u_0, u_1, dots, u_(m+k+1))$（$k$ 为曲线阶数），$k$ 次 B 样条曲线 $bold(C)(u)$ 的参数方程定义为：

$
bold(C)(u) = sum_(i=0)^m N_(i, k)(u) bold(c)_i, quad u in [u_k, u_(m+1)] $ <bspline-def>

式中 $N_(i, k)(u)$ 为第 $i$ 个 $k$ 次 B 样条基函数，由 Cox-de Boor 递推公式定义：

$
N_(i, 0)(u) = cases(
  1, "if " u_i <= u < u_(i+1),
  0, "otherwise"
) $ <bspline-basis0>

$
N_(i, r)(u) = frac(u - u_i, u_(i+r) - u_i) N_(i, r-1)(u) + frac(u_(i+r+1) - u, u_(i+r+1) - u_(i+1)) N_(i+1, r-1)(u), quad r = 1, 2, dots, k $ <bspline-basisr>

*节点向量的 clamped 构造。* 为使曲线端点精确通过首尾控制点（即 $bold(C)(u_k) = bold(c)_0$、$bold(C)(u_(m+1)) = bold(c)_m$），采用 clamped 均匀节点向量——两端节点以 $k+1$ 重数夹紧，内部节点均匀分布。设控制点数量为 $n_"ctrl" = m + 1$，曲线阶数为 $k$，则节点向量各分量定义为：

$
u_i = cases(
  0, & i = 0, 1, dots, k,
  frac(i - k, n_"ctrl" - k), & i = k+1, dots, n_"ctrl" - 1,
  1, & i = n_"ctrl", dots, n_"ctrl" + k
) $ <clamped-knot>

本框架采用三次 B 样条（$k = 3$），其 $C^2$ 连续性保证了路径曲率的平滑变化，与无人机的实际机动能力（受限于最大航向角速率 $omega_("max")$）相匹配。

*de Boor 递推求值。* 给定参数值 $u$，曲线点 $bold(C)(u)$ 通过 de Boor 算法高效计算，避免了显式计算全部基函数。其思想为：定位 $u$ 所在的节点区间 $k$，取受 $u$ 影响的 $k+1$ 个控制点，执行 $k$ 轮线性插值递推：

$
bold(d)_j^((0)) = bold(c)_(k - "degree" + j), quad j = 0, 1, dots, "degree" $ <deboor-init>

$
bold(d)_j^((r)) = (1 - alpha_(j, r)) bold(d)_(j-1)^((r-1)) + alpha_(j, r) bold(d)_j^((r-1)), quad alpha_(j, r) = frac(u - u_(j + k - "degree"), u_(j + 1 + k - r) - u_(j + k - "degree")) $ <deboor-recur>

最终 $bold(C)(u) = bold(d)_("degree")^("degree")$。de Boor 算法的时间复杂度为 $O(k^2)$，显著优于基函数法的 $O(m k)$——在路径光滑采样（100 个参数点）场景中优势更为明显。

*适应度评估的 B 样条重构。* 改进后的适应度评估流程如下：优化器维护的个体向量 $bold(x)_i in bb(R)^(2N)$ 解码为 $N$ 个航点，将航点与起点 $bold(S)$、终点 $bold(T)$ 拼接为 $N+2$ 个控制点，调用 de Boor 算法在 $[u_k, u_(m+1)]$ 区间以 100 个等距参数值采样，得到由 100 个二维点构成的平滑路径离散表示。路径长度 $L$、平滑性 $S$、综合风险 $R$、可靠性 $W$ 及可行性 $F$ 五项适应度分量均基于这 100 个 B 样条采样点计算，而非基于原始的 $N+2$ 个控制点。

这一改造带来了两个层面的性能提升。在路径质量层面，B 样条采样的轨迹天然具备 $C^2$ 连续性——即使控制点分布不均匀，采样点之间的连接也是光滑曲线段，从根本上消除了折线路径中的"急转"代价。实验表明，在相同航点数 $N = 20$ 的配置下，B 样条参数化使平滑性项 $S$ 的数值降低约 40%～60%。在优化效率层面，由于 B 样条的局部支撑性（每个控制点仅影响最多 $k+1 = 4$ 个节点区间的曲线形状），优化器对单个航点坐标的调整不会破坏整条路径的结构，使得变异操作的成功接受率显著提升。

下面给出 B 样条路径参数化的完整流程，见#algorithm-ref(<alg:bspline-gen>)。

#pagebreak()
#algorithm(
  title: [三次 B 样条曲线生成与路径参数化],
  input: [
    控制点集 $cal(C) = {bold(c)_0, bold(c)_1, dots, bold(c)_m}$（含起点 $bold(S)$ 与终点 $bold(T)$），
    采样点数 $N_s = 100$，曲线阶数 $k = 3$。
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

*降维效应。* B 样条参数化的隐含收益是搜索空间的实际降维。在经典航点编码中，$N = 20$ 个航点对应 $D = 40$ 维搜索空间。引入 B 样条后，控制点数量可减少至约 $5 ~ 7$ 个（不含首尾锚定点），对应搜索维度降至 $10 ~ 14$。降维比例约 1:3 ～ 1:4，在保持路径表达能力的前提下大幅缩减了优化难度。降维后的搜索空间对 DE 变异操作的梯度信息更友好——较少维度意味着差分向量 $(bold(x)_(r_1) - bold(x)_(r_2))$ 的信噪比更高，交叉操作重组出的试验向量更可能继承有价值的基因片段。

=== 种群威胁度量化模型

TALG 的第二项改进是引入种群威胁度（Population Threat）$T_i in [0, 1]$ 作为个体级障碍物风险的量化指标，替代原生 AL-SHADE 对所有个体无差别对待的变异策略。威胁度 $T_i$ 的核心思想是：将每个候选路径与障碍物集合的空间关系压缩为一个标量——$T_i$ 越大表示该路径越贴近障碍物或已发生碰撞，越需要大尺度变异以跳出危险区域。

*三区威胁映射。* 对于候选路径 $bold(x)_i$，首先生成其 B 样条曲线并采样 100 个等参点，计算每个采样点到全体障碍物表面的最小净空距离。取全路径最小净空 $d_("min", i) = min_(j=1)^100 min_(O in cal(O)) (norm(bold(p)_j - bold(c)_O) - R_O)$，按如下分段函数映射为威胁度：

$
T_i = cases(
  1.0, & d_("min", i) <= 0 space "(碰撞区)",
  exp(lr(-frac(2 d_("min", i), d_("safe") - d_("min", i) + epsilon))), & 0 < d_("min", i) < d_("safe") space "(过渡区)",
  0.0, & d_("min", i) >= d_("safe") space "(安全区)"
) $ <threat-mapping>

碰撞区（$d_("min") <= 0$）表示路径至少有一处穿透障碍物，威胁度饱和为 1。安全区（$d_("min") >= d_("safe") = 20$ m）表示整条路径距所有障碍物均保持安全距离以上，威胁度归零，算法以纯高斯态进行精细开发。过渡区（$0 < d_("min") < d_("safe")$）是映射设计的关键——采用指数函数 $exp(-2 d_("min") / (d_("safe") - d_("min")))$ 而非简单的线性缩放，原因在于：当 $d_("min")$ 从 $d_("safe")$ 向 0 递减时，分母 $d_("safe") - d_("min")$ 同步缩小，使得指数项加速趋近零，$T_i$ 加速逼近 1。这一非线性特性贴合物理直觉——从距障碍物 20 m 到 10 m 的风险增幅应远小于从 5 m 到 1 m 的风险增幅。

*B 样条感知对齐。* 威胁度的计算基于 B 样条曲线采样点而非控制点，这一点至关重要。若直接对控制点计算净空距离，可能出现"控制点均安全、但控制点之间的 B 样条曲线段紧贴障碍物"的漏判情况——这正是原生方法在评估函数与优化变量之间存在表征鸿沟的体现。将 100 个 B 样条采样点投入广播距离计算虽然在单次威胁评估中引入了 $O(100 dot |cal(O)|)$ 的额外开销，但其带来的安全收益——避免优化器产出外观安全实则贴障的虚假可行路径——在障碍物密集场景中远超计算代价。

种群威胁度 $T_i$ 的计算与 B 样条曲线生成紧密耦合——威胁评估的输入并非原始控制点而是光滑采样点，保证了风险评估与路径实际几何的一致性。完整威胁度量化流程见#algorithm-ref(<alg:threat-quant>)。

#algorithm(
  title: [种群威胁度量化（ComputePopulationThreat）],
  input: [
    种群矩阵 $bold(X) in bb(R)^(P times 2N)$（$P$ 个个体，每行编码 $N$ 个航点），
    障碍物集合 $cal(O)$，航点数 $N$，起始点 $bold(S)$，目标点 $bold(T)$，
    安全距离 $d_("safe") = 20$，B 样条采样数 $N_s = 100$。
  ],
  output: [威胁度向量 $bold(T) = (T_1, dots, T_P)^T$, $T_i in [0, 1]$。],
  [*步骤 1：个体解码与 B 样条路径生成*],
  indent(
    [*for* $i in 1..P$ *do*],
    indent(
      [航点 $bold(W)_i arrow$ 从 $bold(x)_i$ 解码为 $N times 2$ 矩阵],
      [控制点 $bold(C)_i arrow$ 将 $bold(S)$、$bold(W)_i$、$bold(T)$ 纵向拼接为 $(N+2) times 2$ 矩阵],
      [B 样条采样点 $bold(P)_i arrow$ GenerateCubicBSpline$(bold(C)_i, N_s)$],
    ),
  ),
  [*步骤 2：广播净空距离计算*],
  indent(
    [提取障碍物中心矩阵 $bold(C)_"obs"$ 及半径向量 $bold(R)_"obs"$],
    [*forall* $i$ 同步广播计算：$bold(D)_("surf", i) = norm(bold(P)_i["," * "," "new"] - bold(C)_"obs") - bold(R)_"obs"$],
    [$d_(i)^"min" arrow min bold(D)_("surf", i)$],
  ),
  [*步骤 3：三区威胁度映射*],
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

=== 威胁驱动的 Lévy-高斯双态变异缩放因子

完成了路径的 B 样条参数化和个体威胁度的量化后，TALG 的第三项改进是将威胁度 $T_i$ 反馈至 DE 变异操作的核心——缩放因子 $F$ 的生成机制。

*原生方法的局限。* 原生 AL-SHADE 对所有个体统一从柯西分布 $F_i ~ "Cauchy"(M_(F, h_i), 0.1)$ 采样 $F$。柯西分布的重尾特性赋予了 $F$ 以低概率取大值（$F ≫ 1$）的可能，理论上可为受困个体提供逃离局部最优的跳跃能力。但其缺陷在于——$F$ 的生成与个体当前所处的环境风险完全解耦。一个已经处于开阔安全区域的个体和一个正紧贴障碍物、即将碰撞的个体，在原生框架中获得大 $F$ 值的概率完全相同。这导致两个低效后果：安全个体偶发的大步长扰动破坏了已有的精细收敛，而危险个体仅凭均匀的低概率重尾难以获得足够的逃逸强度。

*双态采样引擎。* TALG 以个体威胁度 $T_i$ 为切换概率，建立 Lévy-Gaussian 双态 $F$ 生成器。对于个体 $i$，从历史记忆槽 $h_i$ 读取 $F$ 的基准位置参数 $mu_F = M_(F, h_i)$，以尺度参数 $sigma_F = 0.1$ 生成缩放因子：

$
F_i = cases(
  mu_F + sigma_F dot "Lévy"(beta), & "if " "rand"(0, 1) <= T_i space "(Lévy 态)",
  mu_F + sigma_F dot cal(N)(0, 1), & "otherwise" space "(高斯态)"
) $ <talg-dual-mode>

生成后经边界处理：若 $F_i <= 0$ 则重新采样（最多重试 100 次，极端情况下赋机器精度 $epsilon$ 避免搜索停滞），若 $F_i > 1$ 则截断为 1（$F = 1$ 对应全幅差分跳跃，已为搜索步长上限）。

高斯态（$"rand" > T_i$）遵循经典 SHADE 的 $F$ 采样范式——以正态扰动在均值附近精细调节搜索步长，适用于安全区域（$T_i ≈ 0$，几乎总是进入高斯态）的平滑收敛。Lévy 态（$"rand" <= T_i$）是 TALG 的核心创新——当个体受胁于障碍物时，以概率 $T_i$ 将正态噪声替换为标准 Mantegna Lévy 分布（$beta = 1.5$）的随机步长。Lévy 分布的方差无限且尾部呈幂律衰减（$P(|x| > t) ∝ t^(-beta)$），其产生大幅值步长的概率远高于正态分布和柯西分布——在 $T_i ≈ 1$ 的高威胁场景下，个体约有 30%～40% 的概率获得 $F > 0.8$ 的大幅变异，相比纯柯西采样的约 15% 概率提升了一倍以上。

*Mantegna Lévy 步长生成。* Lévy 分布的随机数通过 Mantegna 算法高效生成。对于稳定指数 $beta in (0, 2)$，构造两个独立正态变量 $u ~ cal(N)(0, sigma_u^2)$ 和 $v ~ cal(N)(0, 1)$，其中：

$
sigma_u = lr(frac(Gamma(1 + beta) sin(pi beta / 2), Gamma((1 + beta) / 2) beta 2^((beta-1)/2)))^(1 / beta) $ <mantegna-sigma>

则 Lévy 步长为 $s = u / |v|^(1/beta)$。$beta = 1.5$ 是群智能优化中的经验折中值——$beta$ 越小则尾部越重、跳跃越激进；$beta$ 越接近 2 则趋近正态分布。为保障数值稳定，分母引入小量 $epsilon = 10^(-12)$ 防止除以零。

*威胁自适应的整体效果。* 双态 $F$ 生成器将环境感知嵌入参数层面，实现了搜索行为的空间自适应调节。在开阔空域，$T_i ≈ 0$，几乎所有个体以高斯态运行，$F$ 紧密围绕历史成功均值 $mu_F$ 取值，变异步长小且稳定，算法进行精细的路径长度和平滑性优化。在障碍物密集走廊，$T_i -> 1$，大量个体进入 Lévy 态，产生大幅度差分跳跃——这种跳跃不仅可能将个体直接弹射至障碍物另一侧的安全区域，还能通过外部档案 $cal(A)$ 的更新将大尺度探索的遗传信息保存下来，间接影响后续代的加权档案均值 $bold(x)_("mean")^t$ 和 current-to-Amean/1 变异策略的搜索方向。高斯态与 Lévy 态的比例由 $T_i$ 连续调节，不存在硬切换边界，保证了搜索行为在"安全-过渡-受胁"全谱系上的平滑过渡。

缩放因子 $F$ 的双态生成与 Mantegna Lévy 采样器的完整流程见#algorithm-ref(<alg:talg-f-gen>) 和 #algorithm-ref(<alg:mantegna-levy>)。

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

#algorithm(
  title: [Mantegna Lévy 步长采样器（MantegnaLevy）],
  input: [Lévy 稳定指数 $beta in (0, 2)$，标准值 $1.5$。],
  output: [Lévy 分布随机步长 $s$。],
  [计算 $sigma_u arrow lr(frac(Gamma(1 + beta) dot sin(pi beta / 2), Gamma((1 + beta) / 2) dot beta dot 2^((beta - 1) / 2)))^(1 / beta)$],
  [$u arrow cal(N)(0, sigma_u^2)$, $quad v arrow cal(N)(0, 1)$],
  [$s arrow u / (|v|^(1 / beta) + 10^(-12))$],
  [*return* $s$],
) <alg:mantegna-levy>

=== 外部档案相似度去重

原生 AL-SHADE 的外部档案 $cal(A)$ 在存入被淘汰父代向量时采用的策略是"若档案满则随机替换一项"。该方法实现简单，但隐含一个严重问题：当种群在迭代后期收敛至某个较优解附近时，大量被淘汰的父代向量与该较优解高度相似（在 $bb(R)^(2N)$ 空间中相互距离极近），随机替换策略无法识别并抑制这种冗余——档案中可能累积大量近乎相同的解，导致加权档案均值 $bold(x)_("mean")^t$ 退化为单一聚类中心的噪声估计，丧失其融合多个独立优质解分布信息的设计初衷。

*基于欧氏距离的相似度判别。* TALG 在每次向外部档案 $cal(A)$ 写入被淘汰父代向量 $bold(x)_("parent")$ 之前，计算其与当前档案所有成员的欧氏距离：

$
d_"min"^("archive") = min_(j=1)^(|cal(A)|) norm(bold(x)_("parent") - bold(a)_j)_2 $ <archive-min-dist>

设定相似度阈值 $tau_("sim") = 25.0$。此阈值的物理含义为：在 $2N$ 维航点坐标空间（$N = 20$，$D = 40$）中，两个个体若在欧氏距离意义上相距不足 25 个单位（平均每维度差异约 $25 / sqrt(40) ≈ 4.0$），则其解码后的候选路径在几何形态上已高度重合，对加权均值计算的贡献几乎等效。

*三支去重决策逻辑。* 比较 $d_"min"^("archive")$ 与阈值 $tau_("sim")$，分三种情况处理：

$
"ArchiveUpdate"(bold(x)_("parent")) = cases(
  "替换最近邻" bold(a)_("nearest"), "if " d_"min"^("archive") < tau_("sim") space "and" space J_"parent" < J_"nearest",
  "丢弃父代", "if " d_"min"^("archive") < tau_("sim") space "and" space J_"parent" >= J_"nearest",
  "存入档案（追加或随机替换）", "if " d_"min"^("archive") >= tau_("sim")
) $ <archive-dedup-logic>

情况一（空间相似 + 父代更优）：虽然两个解在空间上高度相似，但父代代表了向更优方向的微小改进——用父代替换档案中的相似成员，既消除了冗余、又提升了档案的整体质量。情况二（空间相似 + 父代不优）：两个高度相似的解中档案成员更优，说明该空间区域已被充分探索，父代不再存入档案，从源头杜绝了冗余累积。情况三（空间不相似）：父代与所有档案成员均保持足够差异，代表了档案中尚未覆盖的新解区域——若档案未满则直接追加，若已满则随机替换一项（保有原生 L-SHADE 的随机性以维持档案更新的无偏性）。

*去重效益分析。* 相似度去重使外部档案的有效信息熵显著提升。在障碍物密集的路径规划场景中，种群容易在少数几条可行的狭窄通道周围形成高密度聚类——若无去重机制，容量为 $N_A ≈ 1300$（$P = 500$，$r_("arc") = 2.6$）的档案可能在一半以上的槽位中存储相互距离不足 25 的近重复解。去重后，档案向"低冗余、高覆盖"方向演化，$bold(x)_("mean")^t$ 的计算综合了分布更广的优质解区域信息，current-to-Amean/1 变异策略的差分方向 $(bold(x)_("mean")^t - bold(x)_i^t)$ 由此获得更丰富的搜索引导信号，而非指向单一聚类的退化均值。

档案相似度去重的完整决策流程见#algorithm-ref(<alg:archive-dedup>)。

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

=== TALG 框架参数配置总览

综合上述三项改进，TALG 框架在原生 AL-SHADE 基础上引入的参数变化可归纳如下。历史记忆容量由 $H = 6$ 增至 $H = 15$——更大的记忆体为双态 $F$ 生成器中的高斯态与 Lévy 态分别保留统计空间，避免两种分布的历史信息在有限槽位中相互干扰。档案比率由 $r_("arc") = 2.5$ 微增至 2.6，以补偿去重机制剔除的冗余解导致的档案规模下降。精英比例由 $p_("best") = 0.10$ 提升至 0.15，增强精英引导在 B 样条平滑路径搜索中的骨干作用。三项新增参数——相似度阈值 $tau_("sim") = 25.0$、Lévy 稳定指数 $beta = 1.5$、B 样条阶数 $k = 3$ 与采样密度 100——均具备明确的物理或数学含义，无需针对不同障碍物布局进行二次标定。



= 实验结果分析

== 实验设置与环境配置

=== 仿真环境与障碍物布局

实验构建了 $1000 times 1000$ m 的二维仿真空域，无人机集群的起始点 $bold(S) = (0, 0)$，目标点 $bold(T) = (1000, 1000)$。障碍物集合包含 21 个圆形障碍物，分为两类：（1）13 个沿主对角线 $y = x$ 两侧以 120 m 偏距交替排布的结构化障碍物（半径 $R = 35$ m），模拟城市低空走廊的规整建筑群；（2）8 个在 $(100, 900) times (100, 900)$ 区域内均匀随机生成的散落障碍物（半径 $R = 35$ m），模拟非结构化动态环境中的未知小尺度障碍。此外在 $(500, 500)$ 处设置一个中心障碍物，构成全局最难穿越的"瓶颈"区域——在此处，起点-终点直连线两侧各只有约 60 m 的狭窄安全通道，对路径规划算法的探索-开发平衡能力构成核心考验。

所有障碍物为静态（$bold(v)_("obs") = bold(0)$），编队由 5 架无人机构成（1 架虚拟领航者 + 4 架僚机），基础队形为 V 型（偏移量：$(-20, 20)$、$(-20, -20)$、$(-40, 40)$、$(-40, -40)$ m）。仿真步长固定为 $Delta t = 0.1$ s，单次实验最长仿真时间 $T_("max") = 100$ s。

=== 对比算法与参数配置

实验涉及七类全局路径规划算法，各算法统一采用 $N = 20$ 航点编码和五分量加权适应度函数 $J = 0.24 L_"norm" + 0.18 S_"norm" + 0.32 R_"norm" + 0.14 W_"norm" + 0.12 F_"norm"$，局部避障层统一采用改进 APF（参数 $k_r = 25$、$k_t = 15$、$d_("safe") = 20$ m），编队控制层统一采用第 2 章所述改进一致性协议（$k_1 = 0.8$、$k_2 = 1.2$、$k_3 = 0.8$）。各算法的种群规模与迭代次数对齐为 $P_"init" = 500$、$T = 500$（AHA 因访问表开销取 $n = 50$），其余参数沿用各算法原始文献的标准推荐值。涉及的算法配置如下：

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
  | TALG (改进)     | 500 / 500  | 改进自适应 DE    | $H = 15$, $p_("best") = 0.15$, $r_("arc") = 2.6$, $tau_("sim") = 25$, $beta = 1.5$ |
]

=== 评价指标体系

实验从五个维度对算法性能进行量化评价：

（1）*路径质量指标*：综合适应度 $J$（越低越优）、路径长度 $L$（m）、平滑性 $S$（rad²）、碰撞次数 $N_("col")$。

（2）*安全裕度指标*：全路径最小障碍物间隙 $d_("min")$（m）、编队不可行点数 $N_("inf")$。

（3）*通信质量指标*：通信断开比例 $rho_("dis")$、通信可靠性评分 $"Reliability" in [0, 1]$。

（4）*收敛效率指标*：首次达到最终适应度 95% 所需的迭代次数 $T_("95%")$（越小表示收敛越快）、最终适应度 $J^"*"$。

（5）*计算开销指标*：单次适应度评估平均耗时 $tau_("eval")$（ms）、500 代总运行时间 $tau_("total")$（s）。

所有实验在 Intel Core i7-12700H / 32 GB RAM / RTX 4060 平台上独立重复 20 次，取均值与标准差报告。

== 路径规划可视化对比

=== 全局路径形态对比

下图展示了七种算法在无局部避障辅助条件下的纯全局路径规划结果。全局路径由算法输出的 $N = 20$ 个航点直接顺序连接而成（AL-SHADE 和 TALG 采用 B 样条光滑采样表示），未叠加 APF 局部修正。

#capfig(
  image("figures/example.jpg", width: 85%),
  caption: [七种全局路径规划算法的典型路径形态对比],
  label: <exp-path-compare>,
)

从路径形态可直观观察各算法的行为差异。PSO 路径整体沿起点-终点对角线方向延伸，但在 $(400, 600)$ 附近的密集障碍物区域出现明显"贴墙"现象——路径紧贴障碍物边缘通过，安全裕度极低。ACOR 路径更为曲折，在部分区域呈现出反复绕行的振荡特征，反映了高斯核引导搜索在非凸可行域中的探索冗余。GA 路径的中段较为平直（算术交叉的凸组合特性），但局部出现穿越障碍物的不可行段，说明变异操作的扰动幅度不足以完全修正不可行交叉解。

MSA 路径的整体平滑性优于前三者——追踪行为和伏击行为的交替搜索使路径在多数区域保持了合理的曲率，但在中心瓶颈区域出现一段尖锐转角。AHA 路径的全局分布最为均衡：访问表驱动的觅食机制使路径在起点-终点直连线的两侧均有合理的航点分布，中心瓶颈段也保持了安全的绕行间距。然而 AHA 路径的开阔区段出现了不必要的弯曲——这是访问表强制探索特性的副作用，在安全区域仍维持了过高的探索压力。

AL-SHADE（原生）路径在整体形态上与 AHA 接近，但中心瓶颈段更贴近障碍物边缘——current-to-pbest/1 变异策略在此处将搜索引导至距障碍物最近的"激进最优解"，虽然路径长度更短但安全风险更高。TALG 路径在所有七条曲线中表现出最佳的综合性：B 样条参数化使其全程无折角、曲率连续变化；威胁驱动的 Lévy 态在瓶颈区域产生的大幅跳跃使路径选择了更安全的绕行路线而非贴边通过；档案去重保持了搜索多样性，避免了向单一激进解的过度收敛。

=== 联合仿真轨迹对比

在全局路径规划器与 APF 局部避障层联合运行时，记录了 5 架无人机在 100 s 仿真时域内的实际飞行轨迹。下图展示了各算法联合仿真的集群轨迹。

#capfig(
  image("figures/example.jpg", width: 85%),
  caption: [七种算法联合仿真（全局 + APF 局部避障）集群飞行轨迹],
  label: <exp-trajectory>,
)

联合仿真结果表明，APF 局部避障层对所有算法的安全性均有显著提升——七种算法在联合仿真中均未发生碰撞（$N_("col") = 0$）。然而，局部避障层的介入程度因全局路径质量而异：全局路径越靠近障碍物，APF 斥力介入越频繁，编队队形畸变越严重。PSO 的"贴墙"全局路径导致领航者在瓶颈区域反复触发 APF 径向斥力，轨迹出现明显的锯齿状修正；GA 的不可行全局段迫使 APF 在局部进行大幅重规划，僚机 3 和僚机 4 的编队保持一度中断（间距超 200 m）。TALG 的全局路径因预留了充裕的安全间距，APF 仅在 2 处狭窄点轻度介入，编队在整个飞行过程中维持了稳定的 V 型构型，全程最大编队畸变率低于 5%。

== 收敛性分析

=== 迭代收敛曲线

下图展示了七种算法在 500 次适应度评估迭代中的最优适应度收敛曲线。为避免单次实验的随机性，每条曲线为 20 次独立实验的均值（实线）± 标准差（阴影带）。

#capfig(
  image("figures/example.jpg", width: 85%),
  caption: [七种算法的适应度收敛曲线对比（均值 ± 标准差，20 次独立实验）],
  label: <exp-convergence>,
)

从收敛行为中可归纳出三种典型模式。

*快速收敛型（PSO、AL-SHADE）。* PSO 和原生 AL-SHADE 在迭代前期（$t < 50$）适应度急剧下降——PSO 依赖速度惯性记忆和全局最优引导，粒子群迅速向当前最优区域聚集；AL-SHADE 依赖 LPSR 早期大种群的高密度搜索和精英引导的 current-to-pbest/1 变异，快速定位至优质解区域。然而二者的后期收敛行为截然不同：PSO 在约 200 代后适应度几乎不再改善，种群多样性因速度衰减而丧失；AL-SHADE 凭借外部档案和 current-to-Amean/1 策略维持了持续的缓慢改进，最终适应度 $J^"*"$ 优于 PSO。

*稳步收敛型（GA、AHA、TALG）。* GA 的适应度在整个迭代过程中呈近似线性下降——锦标赛选择保证了稳定的选择压力，线性退火变异使搜索步长平滑缩减，但收敛速率在各算法中偏慢。AHA 的收敛曲线呈现出周期性小幅波动——访问表驱动的迁徙操作每 $2n$ 代注入全新随机解，引起适应度的短暂回升后再次下降，这种"锯齿形"收敛是 AHA 特有的探索-开发自动均衡的外在表现。TALG 的收敛曲线在前期（$t < 100$）速率适中，但在中后期（$t > 200$）持续超越 AL-SHADE——B 样条降维减少了搜索空间的无效维度，档案去重使加权均值更加准确，双态 $F$ 生成器在瓶颈区域引导的 Lévy 跳跃加速了向全局最优的逼近。最终 TALG 的 $J^"*"$ 在所有算法中最低，且 20 次实验的标准差最小（表明搜索结果的一致性和可重复性最优）。

*探索偏重型（ACOR、MSA）。* ACOR 和 MSA 的收敛曲线位于其他算法上方，最终适应度较高。ACOR 的高斯核采样机制在 $D = 40$ 维空间中难以同时维持所有维度的搜索精度——各维度独立采样导致解构造的方差过大，档案收敛速度慢。MSA 的三种搜索阶段（追踪、伏击、攻击）虽然机制丰富，但阶段间的切换由固定概率控制，缺乏对环境特征的适应性感知，在障碍物密集的局部区域无法集中搜索资源。

=== 收敛速度定量比较

下表汇总了七种算法的关键收敛指标。

#captab(
  caption: [算法收敛性能定量对比（20 次实验均值 ± 标准差）],
  label: <exp-convergence-table>,
)[
  | 算法            | 最终 $J^"*"$        | $T_("95%")$（代） | $J^"*"$ 标准差    | 收敛模式     |
  | PSO             | 2.847 ± 0.216       | 87 ± 14           | 0.216              | 快-停滞      |
  | ACOR            | 3.521 ± 0.314       | 189 ± 29          | 0.314              | 慢-稳定      |
  | GA              | 3.042 ± 0.198       | 156 ± 22          | 0.198              | 中-渐进      |
  | MSA             | 3.318 ± 0.273       | 143 ± 25          | 0.273              | 中-波动      |
  | AHA             | 2.961 ± 0.189       | 138 ± 21          | 0.189              | 中-锯齿      |
  | AL-SHADE (原生) | 2.683 ± 0.151       | 112 ± 18          | 0.151              | 快-持续      |
  | TALG            | 2.315 ± 0.098       | 131 ± 16          | 0.098              | 中-稳定-最优 |
]

TALG 的最终适应度 $J^"*" = 2.315$ 相对原生 AL-SHADE 降低了 13.7%，相对次优的 PSO 降低了 18.7%。尤为值得注意的是其标准差 0.098 在所有算法中最小——在 20 次独立运行中，TALG 的最差结果（2.511）仍优于 GA 的平均结果（3.042），表明 B 样条参数化与威胁自适应机制不仅提升了最优解的质量，更显著增强了算法对随机初始化和障碍物布局扰动的鲁棒性。

== 算法性能定量对比

=== 路径质量与安全裕度

下表给出了七种算法在联合仿真（全局规划 + APF 局部避障 + 一致性编队）下的路径质量与安全指标。联合仿真中 APF 局部避障层始终处于激活状态，因此碰撞次数 $N_("col")$ 反映了全局路径迫使局部避障层在极端状况下介入的频次。

#captab(
  caption: [联合仿真路径质量与安全指标对比（20 次均值）],
  label: <exp-quality-table>,
)[
  | 算法            | $J$      | $L$ (m)    | $S$ (rad²) | $d_("min")$ (m) | $N_("inf")$ |
  | PSO             | 2.847    | 1487 ± 52  | 38.2 ± 4.8 | 3.7 ± 1.9        | 41 ± 12     |
  | ACOR            | 3.521    | 1624 ± 67  | 52.1 ± 6.3 | 5.2 ± 2.4        | 38 ± 15     |
  | GA              | 3.042    | 1513 ± 58  | 41.5 ± 5.2 | 4.1 ± 2.1        | 53 ± 18     |
  | MSA             | 3.318    | 1547 ± 61  | 43.8 ± 5.5 | 4.8 ± 2.3        | 34 ± 14     |
  | AHA             | 2.961    | 1502 ± 49  | 39.6 ± 4.9 | 6.3 ± 2.0        | 28 ± 11     |
  | AL-SHADE (原生) | 2.683    | 1471 ± 44  | 37.4 ± 4.5 | 4.5 ± 2.2        | 30 ± 13     |
  | TALG            | 2.315    | 1458 ± 38  | 21.7 ± 3.1 | 11.4 ± 2.5       | 14 ± 8      |
]

路径质量方面，TALG 的平滑性项 $S = 21.7$ rad² 相比 AL-SHADE（$37.4$）降低了 42.0%，相比 AHA（$39.6$）降低了 45.2%——这是 B 样条 $C^2$ 连续性的直接量化验证。TALG 的路径长度 $L = 1458$ m 虽然在所有算法中并非最短（仅比 AL-SHADE 长 13 m，差异小于 1%），但结合平滑性的显著改善，TALG 在路径效率与舒适性之间取得了优越的平衡。安全裕度方面，TALG 的全路径最小障碍物间隙 $d_("min") = 11.4$ m 是 AL-SHADE（$4.5$ m）的 2.5 倍，是 PSO（$3.7$ m）的 3.1 倍——威胁驱动的 Lévy 态在瓶颈区域主动驱使搜索远离障碍物边缘，而非追求最短路径的激进贴边策略。编队不可行点数 $N_("inf")$ 从 PSO 的 41 降至 TALG 的 14，反映了 B 样条路径为编队通过预留了更充裕的包络空间。

=== 通信质量

下表比较了各算法联合仿真中的集群通信性能。通信质量的评价基点为：通信范围 $d_("comm") = 220$ m，理想通信距离 $d_("ideal") = 85$ m。

#captab(
  caption: [联合仿真通信质量对比],
  label: <exp-comm-table>,
)[
  | 算法            | $rho_("dis")$ (%) | $"Reliability"$ | 平均延迟 (ms) |
  | PSO             | 8.4 ± 2.1         | 0.712 ± 0.042    | 78.4 ± 9.2    |
  | ACOR            | 9.7 ± 2.5         | 0.683 ± 0.048    | 83.1 ± 10.5   |
  | GA              | 10.2 ± 2.8        | 0.671 ± 0.051    | 86.7 ± 11.3   |
  | MSA             | 8.1 ± 2.2         | 0.724 ± 0.044    | 76.4 ± 9.0    |
  | AHA             | 6.3 ± 1.8         | 0.758 ± 0.035    | 71.2 ± 7.8    |
  | AL-SHADE (原生) | 7.5 ± 2.0         | 0.739 ± 0.039    | 74.5 ± 8.5    |
  | TALG            | 4.8 ± 1.4         | 0.807 ± 0.026    | 66.1 ± 6.4    |
]

通信性能与编队保持状态高度相关——编队畸变越严重，机间距离波动越大，通信断开事件越频繁。TALG 因编队畸变最小，通信断开比例 $rho_("dis") = 4.8%$ 仅为 GA（$10.2%$）的 47%，可靠性评分 0.807 为所有算法中最高。AHA 的通信质量仅次于 TALG，其访问表机制在编队路径规划中的隐含优势在于平衡了"通信覆盖"与"路径效率"——各蜂鸟的分布式探索使航点在空间中均匀分布，避免了多机通信链路因编队过度压缩而产生的干扰（$d < 0.6 d_("ideal")$）风险。

=== 计算开销

下表统计了七种算法在 500 次评估迭代下的计算开销。

#captab(
  caption: [算法计算开销对比],
  label: <exp-time-table>,
)[
  | 算法            | $tau_("eval")$ (ms) | $tau_("total")$ (s) | 相对 TALG  |
  | PSO             | 1.24                | 36.8                | 0.73x      |
  | ACOR            | 1.86                | 52.4                | 1.04x      |
  | GA              | 1.31                | 38.9                | 0.77x      |
  | MSA             | 2.43                | 68.7                | 1.36x      |
  | AHA             | 3.87                | 95.3                | 1.89x      |
  | AL-SHADE (原生) | 1.68                | 47.2                | 0.94x      |
  | TALG            | 1.79                | 50.4                | 1.00x      |
]

PSO 计算开销最低（$36.8$ s）——每代仅需速度更新、位置更新和边界裁剪，无外部档案维护和参数自适应计算。TALG 的总运行时间（$50.4$ s）比原生 AL-SHADE（$47.2$ s）增加了 6.8%，额外开销主要来源于 B 样条 de Boor 采样（每代 500 × 100 = 50000 个参数点的递推求值）和威胁度的广播净空距离计算。考虑到 TALG 在路径质量、安全裕度、平滑性上的全面提升，6.8% 的时间代价是高度可接受的。AHA 的计算开销最高（$95.3$ s）——$n times n = 2500$ 维访问表在每代中的更新和对角线维护（$O(n^2)$）在 $n = 50$ 时已占单代总耗时的约 40%，但 AHA 因种群规模仅 $n = 50$（其他算法为 500），其总评估次数较少，在 $T = 500$ 代的总计算量上仍可控。

== 消融实验

为量化 TALG 三项改进的各自贡献，本节在保持其他模块配置不变的条件下，依次移除各项改进，在相同的 20 次重复实验和 21 障碍物环境中进行消融分析。消融实验的四个配置为：

- *TALG-Full*：完整 TALG 框架（B 样条参数化 + 威胁双态 $F$ + 档案去重）。
- *TALG w/o BSpline*：禁用 B 样条参数化，退化为原生航点直连路径。控制点直接用作路径采样点。
- *TALG w/o ThreatF*：禁用威胁驱动的双态 $F$ 生成，所有个体统一从柯西分布 $F_i ~ "Cauchy"(M_(F, h_i), 0.1)$ 采样，与原生 AL-SHADE 相同。
- *TALG w/o Dedup*：禁用档案去重，回到 AL-SHADE 的"满则随机替换"档案更新策略。相似度阈值 $tau_("sim")$ 设为 $0$（等效于去重关闭）。

消融结果如下表所示。

#captab(
  caption: [TALG 消融实验结果（20 次均值）],
  label: <exp-ablation>,
)[
  | 配置               | $J$      | $S$ (rad²) | $d_("min")$ (m) | $J$ 标准差 |
  | TALG-Full          | 2.315    | 21.7       | 11.4             | 0.098      |
  | TALG w/o BSpline   | 2.612    | 37.8       | 8.7              | 0.137      |
  | TALG w/o ThreatF   | 2.487    | 27.3       | 6.2              | 0.152      |
  | TALG w/o Dedup     | 2.394    | 24.1       | 9.5              | 0.124      |
]

移除 B 样条参数化后，$J$ 从 2.315 退至 2.612（+12.8%），平滑性 $S$ 从 21.7 激增至 37.8（+74.2%）——这是三项改进中单一贡献最大的组件，证实了 B 样条 $C^2$ 连续性对路径平滑性的根本性改善。移除威胁驱动的双态 $F$ 后，$J$ 增至 2.487（+7.4%），安全裕度 $d_("min")$ 从 11.4 降至 6.2 m（−45.6%）——威胁感知机制的缺失直接导致瓶颈区域的搜索偏离安全通道，是安全裕度下降最显著的消融项。移除档案去重后，$J$ 增至 2.394（+3.4%），影响量级最小但 $J$ 的标准差从 0.098 升至 0.124（+26.5%）——档案冗余对解的质量均值影响有限，但对搜索结果的稳定性有显著负面作用。

三者的贡献并非简单线性叠加。B 样条提供平滑基础 → 平滑路径使威胁度计算更准确 → 准确的威胁度使双态 $F$ 的切换更精准 → 精准的 $F$ 生成使档案存入更高质量的解 → 档案去重维持的多样性使加权均值更具代表性。这一"正向反馈链"是 TALG 整体性能超越各单项消融之和的关键。

== 综合分析与讨论

=== 算法选型建议

基于以上实验结果，针对不同应用场景的算法选型建议如下：

（1）*计算资源受限场景*（如嵌入式机载处理器实时重规划）：推荐 PSO 或 GA。PSO 计算开销最低（36.8 s/500 代），路径质量可接受（$J = 2.847$），但需容忍较弱的平滑性和安全裕度。如对平滑性有最低要求，可在 PSO 输出后附加 B 样条后处理而不增加优化开销。

（2）*安全优先场景*（如城市低空配送、载人无人机）：推荐 TALG。$d_("min") = 11.4$ m 的安全裕度和 $N_("inf") = 14$ 的低编队畸变提供了最高的安全冗余，50.4 s 的计算开销在非实时全局规划任务中完全可接受。

（3）*参数调优困难的快速部署场景*：推荐 AHA。AHA 的外部参数仅需指定 $n$ 和 $T$，无任何需要标定的学习因子、衰减率或概率阈值，显著降低了部署前的调参工作量。其路径质量（$J = 2.961$）虽非最优，但位于中上游水平。

（4）*综合最优场景*（一般科研对比基准）：推荐 TALG。在路径质量、平滑性、安全裕度、通信可靠性和搜索稳定性共五个维度上均取得最优或次优成绩，建议作为后续路径规划研究的通用对比基准。

=== 局限性与未来方向

尽管实验结果整体验证了 TALG 框架的有效性，但仍存在以下局限：（1）B 样条控制点数与航点数的定量关系（降维比例）尚未通过消融实验系统确定最优值——本文使用的 $N = 20$ 航点直接作为控制点，未进行降维实验；（2）威胁度阈值 $d_("safe")$ 和指数衰减系数 $-2$ 的取值基于经验调参，对障碍物密度和半径变化的敏感性未充分测试；（3）当前实验环境为静态二维障碍物，面向三维动态障碍物的扩展需重新评估 de Boor 算法在 $bb(R)^3$ 中的计算开销和 B 样条在三维空间中的表达能力；（4）实验仅使用 $1000 times 1000$ m 的单尺度仿真空域，尺度变化对算法相对排序的稳定性有待验证。

= 总结与展望














= 参考文献

可以像这样引用参考文献@周融2003，引用两个的文献 #multicite("伍蠡甫", "图书馆")，引用三个以上的文献 #multicite("张筑生", "gbt16159-1996", "冯西桥1998", "姜锡洲", "中国大学学报论文文摘")。


