# 高中适配版伊辛模型考试排程代码
# 用途：求解高中5门科目期末考试排程（规避冲突），适配高中信息技术课教学实践
# 适配场景：高中课堂编程实践、跨学科算法教学案例
# 依赖库：numpy (1.24.0+)、matplotlib (3.6.0+)
# 作者：zhengweiyu
# 日期：2025年12月
# 关联论文：基于伊辛模型的组合优化教学实践——高中期末考试排程案例


import numpy as np
import matplotlib.pyplot as plt

# ---------------------- 1. 初始化参数 ----------------------
# 5门科目：0-语文，1-数学，2-英语，3-物理，4-化学
subjects = ["语文", "数学", "英语", "物理", "化学"]
# 冲突矩阵（1表示冲突，0表示无冲突）
conflict_matrix = np.array([
    [0, 0, 0, 0, 0],  # 语文与其他科目无冲突
    [0, 0, 0, 1, 1],  # 数学与物理、化学冲突
    [0, 0, 0, 1, 0],  # 英语与物理冲突
    [0, 1, 1, 0, 0],  # 物理与数学、英语冲突
    [0, 1, 0, 0, 0]   # 化学与数学冲突
])
# 相互作用强度矩阵（冲突科目设为-1，无冲突设为0）
J = -conflict_matrix
# 初始自旋配置（随机生成，1=上午场，-1=下午场）
spins = np.random.choice([-1, 1], size=5)
# 模拟退火参数（简化设置，适配高中教学）
T0 = 8.0  # 初始温度
T_min = 0.1  # 最低温度
cool_rate = 0.9  # 降温系数
max_iter = 500  # 最大迭代次数

# ---------------------- 2. 核心函数 ----------------------
def calculate_energy(spins, J):
    """计算系统能量（能量越低，冲突越少）"""
    # 简化能量计算，避免复杂矩阵运算
    energy = 0
    for i in range(len(spins)):
        for j in range(i+1, len(spins)):
            energy += -J[i][j] * spins[i] * spins[j]
    return energy

def simulate_annealing(spins, J, T0, T_min, cool_rate, max_iter):
    """简化模拟退火算法，返回最优排程与能量变化"""
    T = T0
    best_spins = spins.copy()
    best_energy = calculate_energy(spins, J)
    energy_history = [best_energy]  # 记录能量变化，用于可视化

    for _ in range(max_iter):
        # 随机调整一门科目的时段（翻转一个自旋）
        idx = np.random.randint(0, len(spins))
        spins[idx] *= -1
        new_energy = calculate_energy(spins, J)
        delta_E = new_energy - best_energy

        # 判断是否保留调整（简化Metropolis准则）
        if delta_E < 0:
            best_energy = new_energy
            best_spins = spins.copy()
        else:
            # 高温时允许保留较差调整，低温时不允许
            if np.random.rand() < np.exp(-delta_E / T):
                best_energy = new_energy
                best_spins = spins.copy()
            else:
                spins[idx] *= -1  # 恢复原状态

        # 降温与记录能量
        T *= cool_rate
        energy_history.append(best_energy)
        if T < T_min:
            break

    return best_spins, best_energy, energy_history

# ---------------------- 3. 结果转换与可视化 ----------------------
def get_schedule(best_spins, subjects):
    """将自旋状态转化为直观的考试排程"""
    schedule = []
    for i in range(len(subjects)):
        time = "上午场" if best_spins[i] == 1 else "下午场"
        schedule.append(f"{subjects[i]}: {time}")
    return schedule

def count_conflicts(best_spins, J):
    """统计冲突数（简化计算，适配高中理解）"""
    conflicts = 0
    for i in range(len(best_spins)):
        for j in range(i+1, len(best_spins)):
            if J[i][j] == -1 and best_spins[i] == best_spins[j]:
                conflicts += 1
    return conflicts

# ---------------------- 4. 运行与输出结果 ----------------------
if __name__ == "__main__":
    best_spins, best_energy, energy_history = simulate_annealing(
        spins, J, T0, T_min, cool_rate, max_iter
    )
    schedule = get_schedule(best_spins, subjects)
    conflict_count = count_conflicts(best_spins, J)

    # 打印结果
    print("最优考试排程方案：")
    for item in schedule:
        print(item)
    print(f"\n最优排程冲突数：{conflict_count}")
    print(f"系统最低能量：{best_energy:.2f}")

    # 绘制能量变化曲线
    plt.figure(figsize=(8, 5))
    plt.plot(energy_history, label="System Energy", color="orange", linewidth=2)
    plt.xlabel("Iterations", fontsize=11)
    plt.ylabel("System Energy", fontsize=11)
    plt.title("Energy Change Curve during Simulated Annealing (High School Exam Scheduling)", fontsize=12)
    plt.legend()
    plt.grid(alpha=0.3)
    plt.show()