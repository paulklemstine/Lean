"""
Visualization 2: Exchange Descent Trajectories at Different Depths

Shows how certificate depth affects actual descent trajectories on
concrete exchange families. Plots objective value vs step number for
objectives of varying log-concavity depth, demonstrating the
depth-sensitive convergence speedup predicted by the theory.
"""

import numpy as np
import matplotlib.pyplot as plt
import itertools


def binomial(n, k):
    if k < 0 or k > n: return 0
    if k == 0 or k == n: return 1
    k = min(k, n - k)
    r = 1
    for i in range(k):
        r = r * (n - i) // (i + 1)
    return r


def gen_simplex(d, n):
    if d == 1: return [[n]]
    pts = []
    def _g(rd, rs, c):
        if rd == 1:
            pts.append(c + [rs]); return
        for v in range(rs + 1): _g(rd - 1, rs - v, c + [v])
    _g(d, n, [])
    return pts


def make_weights(max_val, depth):
    N = max(2 * max_val, depth + max_val)
    return np.array([float(binomial(N, i)) for i in range(max_val + 1)])


def obj_val(x, weights_list):
    return sum(-np.log(weights_list[i][int(x[i])] + 1e-30)
               for i in range(len(weights_list)))


def descent_trajectory(points, d, weights_list, x0):
    pts_set = set(map(tuple, [list(p) for p in points]))
    x = list(x0)
    fx = obj_val(x, weights_list)
    traj = [fx]
    for _ in range(5000):
        best_y, best_fy = None, fx
        for i in range(d):
            for j in range(d):
                if i == j: continue
                y = list(x); y[i] += 1; y[j] -= 1
                if tuple(y) in pts_set and all(v >= 0 for v in y):
                    fy = obj_val(y, weights_list)
                    if fy < best_fy:
                        best_y, best_fy = list(y), fy
        if best_y is None: break
        x, fx = best_y, best_fy
        traj.append(fx)
    return traj


# ─── Generate data ───
np.random.seed(42)
d = 5
n_simp = 6
points = gen_simplex(d, n_simp)
points_arr = np.array(points, dtype=int)
max_coord = int(np.max(points_arr)) + 1

fig, axes = plt.subplots(1, 3, figsize=(14, 4.5))

# Panel 1: Trajectories at different depths
ax = axes[0]
colors = ['#e74c3c', '#f39c12', '#2ecc71', '#3498db', '#9b59b6']
depths = [1, 2, 3, 4, 5]

for depth, color in zip(depths, colors):
    weights = [make_weights(max_coord, depth) for _ in range(d)]
    # Use a challenging starting point
    x0 = points_arr[0].copy()
    traj = descent_trajectory(points_arr, d, weights, x0)
    ax.plot(range(len(traj)), traj, color=color, linewidth=1.8,
            label=f'k={depth}', alpha=0.85)

ax.set_xlabel('Step', fontsize=11)
ax.set_ylabel('Objective Value', fontsize=11)
ax.set_title('Descent Trajectories\nby Certificate Depth', fontsize=11, fontweight='bold')
ax.legend(fontsize=9, title='Depth k')
ax.grid(True, alpha=0.3)

# Panel 2: Step count distribution
ax = axes[1]
step_data = {}
for depth in depths:
    weights = [make_weights(max_coord, depth) for _ in range(d)]
    counts = []
    for trial in range(min(30, len(points_arr))):
        idx = np.random.randint(len(points_arr))
        traj = descent_trajectory(points_arr, d, weights, points_arr[idx])
        counts.append(len(traj) - 1)
    step_data[depth] = counts

bp = ax.boxplot([step_data[k] for k in depths], labels=[str(k) for k in depths],
                patch_artist=True, widths=0.6)
for patch, color in zip(bp['boxes'], colors):
    patch.set_facecolor(color)
    patch.set_alpha(0.6)

ax.set_xlabel('Certificate Depth k', fontsize=11)
ax.set_ylabel('Descent Steps', fontsize=11)
ax.set_title('Step Count Distribution\nby Depth', fontsize=11, fontweight='bold')
ax.grid(True, alpha=0.3, axis='y')

# Panel 3: Potential decrease per step
ax = axes[2]
for depth, color in zip([1, 3, 5], ['#e74c3c', '#2ecc71', '#9b59b6']):
    weights = [make_weights(max_coord, depth) for _ in range(d)]
    x0 = points_arr[0].copy()
    traj = descent_trajectory(points_arr, d, weights, x0)
    if len(traj) > 1:
        decreases = [traj[i] - traj[i+1] for i in range(len(traj)-1)]
        ax.plot(range(len(decreases)), decreases, color=color,
                linewidth=1.5, alpha=0.8, label=f'k={depth}')

ax.set_xlabel('Step', fontsize=11)
ax.set_ylabel('Potential Decrease Δ', fontsize=11)
ax.set_title('Per-Step Decrease\n(Larger = Faster)', fontsize=11, fontweight='bold')
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)
ax.axhline(y=0, color='gray', linestyle='-', alpha=0.3)

plt.tight_layout()
plt.savefig('viz_descent_trajectories.png', dpi=150, bbox_inches='tight')
print("Saved viz_descent_trajectories.png")
