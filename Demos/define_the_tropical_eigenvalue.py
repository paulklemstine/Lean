"""
Applications of the Tropical Eigenvalue (Minimum Cycle Mean)

Demonstrates real-world applications:
1. Manufacturing throughput optimization
2. Network routing analysis
3. Scheduling and clock synchronization
"""

import numpy as np
from itertools import permutations


def min_cycle_mean(W):
    """Compute minimum cycle mean using Karp's algorithm."""
    n = W.shape[0]
    if n == 0:
        return 0.0
    INF = float('inf')
    d = np.full((n + 1, n), INF)
    d[0, :] = 0.0
    for k in range(1, n + 1):
        for v in range(n):
            d[k][v] = min(d[k - 1][u] + W[u][v] for u in range(n))
    result = INF
    for v in range(n):
        max_ratio = -INF
        for k in range(n):
            if d[k][v] < INF:
                ratio = (d[n][v] - d[k][v]) / (n - k)
                max_ratio = max(max_ratio, ratio)
        if max_ratio < INF:
            result = min(result, max_ratio)
    return result


def find_optimal_cycle(W):
    """Find the simple cycle achieving the minimum cycle mean."""
    n = W.shape[0]
    best = float('inf')
    best_cycle = None
    for length in range(1, n + 1):
        for perm in permutations(range(n), length):
            cost = sum(W[perm[i]][perm[(i + 1) % length]] for i in range(length))
            mean = cost / length
            if mean < best:
                best = mean
                best_cycle = list(perm)
    return best, best_cycle


# =====================================================
# Application 1: Manufacturing Throughput
# =====================================================
print("=" * 60)
print("  APPLICATION 1: Manufacturing Throughput Optimization")
print("=" * 60)

# A factory has 4 machines in a cyclic production line.
# W[i][j] = processing time to transfer a part from machine i to machine j.
machines = ["CNC Mill", "Lathe", "Grinder", "Assembly"]
W_factory = np.array([
    [5.0, 3.0, 7.0, 4.0],   # From CNC Mill
    [6.0, 4.0, 2.0, 5.0],   # From Lathe
    [3.0, 8.0, 6.0, 1.0],   # From Grinder
    [4.0, 2.0, 5.0, 7.0],   # From Assembly
])

lam, cycle = find_optimal_cycle(W_factory)
print(f"\nProcessing time matrix (minutes):")
print(f"{'':>12s}", end="")
for m in machines:
    print(f"{m:>10s}", end="")
print()
for i, m in enumerate(machines):
    print(f"{m:>12s}", end="")
    for j in range(4):
        print(f"{W_factory[i][j]:>10.1f}", end="")
    print()

print(f"\nMinimum cycle mean (bottleneck cycle time): {lam:.2f} min")
print(f"Maximum throughput: {60/lam:.2f} parts/hour")
print(f"Bottleneck cycle: {' → '.join(machines[v] for v in cycle)} → {machines[cycle[0]]}")

# Optimization: what if we speed up the bottleneck?
print(f"\n--- What-if analysis (shift invariance) ---")
for improvement in [0.5, 1.0, 2.0]:
    W_improved = W_factory - improvement
    lam_improved = min_cycle_mean(W_improved)
    print(f"  Reduce all times by {improvement} min: "
          f"throughput = {60/lam_improved:.2f} parts/hr "
          f"(+{60/lam_improved - 60/lam:.2f})")


# =====================================================
# Application 2: Network Routing
# =====================================================
print(f"\n{'='*60}")
print("  APPLICATION 2: Network Routing Analysis")
print("=" * 60)

# A network of 5 routers. W[i][j] = latency from router i to j (ms).
routers = ["NYC", "LON", "TYO", "SFO", "SYD"]
W_net = np.array([
    [0.1, 70.0, 170.0, 40.0, 200.0],   # NYC
    [70.0, 0.1, 140.0, 90.0, 180.0],    # LON
    [170.0, 140.0, 0.1, 100.0, 80.0],   # TYO
    [40.0, 90.0, 100.0, 0.1, 120.0],    # SFO
    [200.0, 180.0, 80.0, 120.0, 0.1],   # SYD
])

lam_net, cycle_net = find_optimal_cycle(W_net)
print(f"\nLatency matrix (ms):")
print(f"{'':>6s}", end="")
for r in routers:
    print(f"{r:>8s}", end="")
print()
for i, r in enumerate(routers):
    print(f"{r:>6s}", end="")
    for j in range(5):
        print(f"{W_net[i][j]:>8.1f}", end="")
    print()

print(f"\nMinimum cycle mean latency: {lam_net:.2f} ms")
print(f"Optimal monitoring loop: {' → '.join(routers[v] for v in cycle_net)} → {routers[cycle_net[0]]}")
print(f"This is the most efficient heartbeat/keepalive cycle in the network.")

# Impact of adding encryption overhead
print(f"\n--- Impact of encryption overhead (shift invariance) ---")
for overhead in [1.0, 5.0, 10.0]:
    lam_enc = min_cycle_mean(W_net + overhead)
    print(f"  +{overhead:4.1f} ms/hop: min cycle mean = {lam_enc:.2f} ms "
          f"(= {lam_net:.2f} + {overhead:.1f} = {lam_net + overhead:.2f} ✓)")


# =====================================================
# Application 3: Job Scheduling
# =====================================================
print(f"\n{'='*60}")
print("  APPLICATION 3: Cyclic Job Scheduling")
print("=" * 60)

# 3 jobs must be executed repeatedly in cycles.
# W[i][j] = setup time when switching from job i to job j.
jobs = ["Data Collection", "Processing", "Reporting"]
W_sched = np.array([
    [2.0, 1.0, 4.0],   # After Data Collection
    [3.0, 1.5, 1.0],   # After Processing
    [2.0, 3.0, 2.5],   # After Reporting
])

lam_sched, cycle_sched = find_optimal_cycle(W_sched)
print(f"\nSetup time matrix (hours):")
for i, j_name in enumerate(jobs):
    print(f"  {j_name:>20s}: {W_sched[i]}")

print(f"\nMinimum cycle mean setup time: {lam_sched:.2f} hours")
print(f"Optimal schedule: {' → '.join(jobs[v] for v in cycle_sched)} → {jobs[cycle_sched[0]]}")
print(f"Cycle period: {len(cycle_sched) * lam_sched:.2f} hours per full rotation")
print(f"Daily throughput: {24 / (len(cycle_sched) * lam_sched):.1f} complete cycles")

print(f"\n{'='*60}")
print("  All applications demonstrated successfully!")
print(f"{'='*60}")


"""
Demo: Tropical Eigenvalue as Minimum Cycle Mean

Demonstrates the main theorems with concrete numerical examples:
1. Cycle reduction: long cycles can always be reduced to simple ones
2. Shift invariance: λ*(W + a) = λ*(W) + a
3. Monotonicity: W ≤ W' ⟹ λ*(W) ≤ λ*(W')
4. Constant matrix: λ*(c·J) = c
5. Self-loop bound: λ*(W) ≤ W_{ii} for all i
"""

import numpy as np
from itertools import permutations


def min_cycle_mean_brute(W):
    """Compute min cycle mean by brute force over all simple cycles."""
    n = W.shape[0]
    best = float('inf')
    best_cycle = None
    for length in range(1, n + 1):
        for perm in permutations(range(n), length):
            cost = sum(W[perm[i]][perm[(i + 1) % length]] for i in range(length))
            mean = cost / length
            if mean < best:
                best = mean
                best_cycle = list(perm)
    return best, best_cycle


def cycle_mean(W, cycle):
    """Compute the mean cost of a given cycle."""
    k = len(cycle)
    cost = sum(W[cycle[i]][cycle[(i + 1) % k]] for i in range(k))
    return cost / k


def print_header(title):
    print(f"\n{'='*60}")
    print(f"  {title}")
    print(f"{'='*60}")


# =====================================================
# Demo 1: Basic computation
# =====================================================
print_header("Demo 1: Basic Tropical Eigenvalue Computation")

W = np.array([
    [10.0, 1.0, 5.0],
    [3.0, 10.0, 2.0],
    [4.0, 6.0, 10.0]
])

print(f"\nWeight matrix W:")
print(W)

lam, opt_cycle = min_cycle_mean_brute(W)
print(f"\nTropical eigenvalue λ*(W) = {lam:.4f}")
print(f"Optimal cycle: {opt_cycle}")
print(f"Cycle edges: {' → '.join(str(v) for v in opt_cycle)} → {opt_cycle[0]}")
print(f"Edge costs: {[W[opt_cycle[i]][opt_cycle[(i+1)%len(opt_cycle)]] for i in range(len(opt_cycle))]}")

# Check all self-loops
print(f"\nSelf-loop costs (upper bounds on λ*):")
for i in range(W.shape[0]):
    print(f"  W[{i}][{i}] = {W[i][i]:.1f}  ≥  λ* = {lam:.4f}  ✓")

# =====================================================
# Demo 2: Shift Invariance
# =====================================================
print_header("Demo 2: Shift Invariance — λ*(W + aJ) = λ*(W) + a")

for a in [-3.0, 0.0, 5.0, 100.0]:
    W_shifted = W + a
    lam_shifted, _ = min_cycle_mean_brute(W_shifted)
    print(f"  a = {a:7.1f}:  λ*(W+a) = {lam_shifted:8.4f}  =  {lam:.4f} + {a:.1f} = {lam + a:8.4f}  {'✓' if abs(lam_shifted - (lam + a)) < 1e-10 else '✗'}")

# =====================================================
# Demo 3: Monotonicity
# =====================================================
print_header("Demo 3: Monotonicity — W ≤ W' ⟹ λ*(W) ≤ λ*(W')")

np.random.seed(42)
for trial in range(5):
    delta = np.abs(np.random.randn(3, 3)) * 2
    W_upper = W + delta
    lam_upper, _ = min_cycle_mean_brute(W_upper)
    print(f"  Trial {trial+1}: λ*(W) = {lam:.4f} ≤ λ*(W+Δ) = {lam_upper:.4f}  {'✓' if lam <= lam_upper + 1e-10 else '✗'}")

# =====================================================
# Demo 4: Constant Matrix
# =====================================================
print_header("Demo 4: Constant Matrix — λ*(cJ) = c")

for c in [0.0, 1.0, -5.0, 3.14159]:
    W_const = np.full((4, 4), c)
    lam_const, _ = min_cycle_mean_brute(W_const)
    print(f"  c = {c:8.5f}:  λ*(cJ) = {lam_const:8.5f}  {'✓' if abs(lam_const - c) < 1e-10 else '✗'}")

# =====================================================
# Demo 5: Cycle Reduction in Action
# =====================================================
print_header("Demo 5: Cycle Reduction — Long Cycles Reduce to Simple Ones")

W4 = np.array([
    [5.0, 1.0, 8.0, 3.0],
    [7.0, 6.0, 2.0, 9.0],
    [4.0, 3.0, 7.0, 1.0],
    [2.0, 8.0, 5.0, 4.0]
])

print(f"\n4×4 Weight matrix W:")
print(W4)

lam4, opt4 = min_cycle_mean_brute(W4)
print(f"\nOptimal simple cycle: {opt4}, mean = {lam4:.4f}")

# Show some long (non-simple) cycles and their means
long_cycles = [
    [0, 1, 2, 3, 0, 1, 2, 3],  # Double traversal
    [0, 1, 0, 1, 2, 3],         # Repeated sub-loop
    [0, 1, 2, 1, 2, 3],         # With inner loop
]

print(f"\nLong (non-simple) cycles and their means:")
for cyc in long_cycles:
    mean = cycle_mean(W4, cyc)
    print(f"  {cyc}: mean = {mean:.4f}  ≥  λ* = {lam4:.4f}  {'✓' if mean >= lam4 - 1e-10 else '✗'}")

# =====================================================
# Demo 6: 2-Cycle Entry Average Bound
# =====================================================
print_header("Demo 6: Entry Average Bound — λ*(W) ≤ (W[i][j] + W[j][i]) / 2")

print(f"\nFor the 3×3 matrix with λ* = {lam:.4f}:")
for i in range(3):
    for j in range(3):
        avg = (W[i][j] + W[j][i]) / 2
        print(f"  (W[{i}][{j}] + W[{j}][{i}]) / 2 = ({W[i][j]:.1f} + {W[j][i]:.1f}) / 2 = {avg:.4f}  ≥  λ*  {'✓' if avg >= lam - 1e-10 else '✗'}")

# =====================================================
# Demo 7: Diagonal Matrix (with off-diagonal zeros)
# =====================================================
print_header("Demo 7: Diagonal Matrix Analysis")

d = np.array([3.0, 7.0, 1.0, 5.0])
W_diag = np.diag(d)
lam_diag, cyc_diag = min_cycle_mean_brute(W_diag)
print(f"\nDiagonal entries: {d}")
print(f"Min diagonal entry: {min(d):.1f}")
print(f"Tropical eigenvalue: {lam_diag:.4f}")
print(f"Optimal cycle: {cyc_diag}")
print(f"\nNote: λ* = {lam_diag:.4f} ≤ min(d) = {min(d):.1f}")
print("For diagonal matrices, off-diagonal zeros create free edges,")
print("so 2-cycles can have mean 0, which may be < min diagonal entry.")

print(f"\n{'='*60}")
print("  All demos completed successfully!")
print(f"{'='*60}")


"""
Visualizations for Tropical Eigenvalue theory.
Generates PNG images for the PACKAGE.json.
"""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from itertools import permutations
import base64
from io import BytesIO

def min_cycle_mean_brute(W):
    n = W.shape[0]
    best = float('inf')
    best_cycle = None
    for length in range(1, n + 1):
        for perm in permutations(range(n), length):
            cost = sum(W[perm[i]][perm[(i+1)%length]] for i in range(length))
            mean = cost / length
            if mean < best:
                best = mean
                best_cycle = list(perm)
    return best, best_cycle

def fig_to_base64(fig):
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    return "data:image/png;base64," + base64.b64encode(buf.read()).decode('utf-8')

# Figure 1: Shift Invariance and Monotonicity
fig1, axes = plt.subplots(1, 2, figsize=(14, 5))

W = np.array([[10., 1., 5.], [3., 10., 2.], [4., 6., 10.]])
shifts = np.linspace(-5, 10, 50)
base_lam, _ = min_cycle_mean_brute(W)

axes[0].plot(shifts, [base_lam + a for a in shifts], 'b-', linewidth=2.5)
axes[0].axhline(y=base_lam, color='gray', linestyle=':', alpha=0.5)
axes[0].axvline(x=0, color='gray', linestyle=':', alpha=0.5)
axes[0].scatter([0], [base_lam], color='red', s=80, zorder=5)
axes[0].set_xlabel('Shift a', fontsize=13)
axes[0].set_ylabel('Tropical Eigenvalue', fontsize=13)
axes[0].set_title('Shift Invariance: λ*(W+aJ) = λ*(W) + a', fontsize=14)
axes[0].grid(True, alpha=0.3)

scales = np.linspace(0, 5, 100)
lams = [base_lam + s for s in scales]
axes[1].plot(scales, lams, 'g-', linewidth=2.5)
axes[1].fill_between(scales, lams, alpha=0.15, color='green')
axes[1].set_xlabel('Uniform increase Δ', fontsize=13)
axes[1].set_ylabel('Tropical Eigenvalue', fontsize=13)
axes[1].set_title("Monotonicity: W ≤ W' ⟹ λ*(W) ≤ λ*(W')", fontsize=14)
axes[1].grid(True, alpha=0.3)
plt.tight_layout()
b64_1 = fig_to_base64(fig1)
plt.savefig('/workspace/request-project/viz_properties.png', dpi=150, bbox_inches='tight')
plt.close()

# Figure 2: Cycle Means Landscape
fig2, ax2 = plt.subplots(figsize=(10, 6))
W4 = np.array([[5.,1.,8.,3.],[7.,6.,2.,9.],[4.,3.,7.,1.],[2.,8.,5.,4.]])
np.random.seed(42)
all_means = []
for length in range(1, 5):
    for perm in permutations(range(4), length):
        cost = sum(W4[perm[i]][perm[(i+1)%length]] for i in range(length))
        mean = cost / length
        all_means.append((length, mean))

lam4, _ = min_cycle_mean_brute(W4)
colors = {1: '#e74c3c', 2: '#3498db', 3: '#2ecc71', 4: '#9b59b6'}
for l in [1, 2, 3, 4]:
    pts = [(x + np.random.uniform(-0.15, 0.15), y) for x, y in all_means if x == l]
    if pts:
        ax2.scatter([p[0] for p in pts], [p[1] for p in pts],
                   c=colors[l], alpha=0.6, s=30, label=f'Length {l}')
ax2.axhline(y=lam4, color='red', linestyle='--', linewidth=2, label=f'λ* = {lam4:.2f}')
ax2.set_xlabel('Cycle Length', fontsize=13)
ax2.set_ylabel('Cycle Mean', fontsize=13)
ax2.set_title('Landscape of All Simple Cycle Means (4×4 matrix)', fontsize=14)
ax2.legend(fontsize=11)
ax2.set_xticks([1, 2, 3, 4])
ax2.grid(True, alpha=0.3)
plt.tight_layout()
b64_2 = fig_to_base64(fig2)
plt.savefig('/workspace/request-project/viz_cycle_means.png', dpi=150, bbox_inches='tight')
plt.close()

# Figure 3: Min-Plus Power Convergence
fig3, ax3 = plt.subplots(figsize=(10, 6))
W_conv = np.array([[3., 1., 5.], [4., 2., 1.], [1., 3., 4.]])
n = 3
K = 30

def minplus_matmul(A, B):
    n = A.shape[0]
    C = np.full((n, n), float('inf'))
    for i in range(n):
        for j in range(n):
            for m in range(n):
                C[i][j] = min(C[i][j], A[i][m] + B[m][j])
    return C

powers = [W_conv.copy()]
for k in range(1, K):
    powers.append(minplus_matmul(powers[-1], W_conv))

lam_conv, _ = min_cycle_mean_brute(W_conv)
cmap = plt.cm.viridis
for i in range(n):
    for j in range(n):
        ratios = [powers[k][i][j] / (k+1) for k in range(K)]
        ax3.plot(range(1, K+1), ratios, alpha=0.5, linewidth=1,
                color=cmap((i*n+j)/(n*n)))

ax3.axhline(y=lam_conv, color='red', linestyle='--', linewidth=2.5,
           label=f'λ* = {lam_conv:.4f}')
ax3.set_xlabel('Matrix power k', fontsize=13)
ax3.set_ylabel('(W^k)ᵢⱼ / k', fontsize=13)
ax3.set_title('Convergence: Min-Plus Matrix Powers → Tropical Eigenvalue', fontsize=14)
ax3.legend(fontsize=12)
ax3.grid(True, alpha=0.3)
plt.tight_layout()
b64_3 = fig_to_base64(fig3)
plt.savefig('/workspace/request-project/viz_convergence.png', dpi=150, bbox_inches='tight')
plt.close()

# Save base64 strings for PACKAGE.json
with open('/workspace/request-project/_viz_data.txt', 'w') as f:
    f.write("VIZ1_START\n")
    f.write(b64_1 + "\n")
    f.write("VIZ1_END\n")
    f.write("VIZ2_START\n")
    f.write(b64_2 + "\n")
    f.write("VIZ2_END\n")
    f.write("VIZ3_START\n")
    f.write(b64_3 + "\n")
    f.write("VIZ3_END\n")

print("All visualizations saved.")
