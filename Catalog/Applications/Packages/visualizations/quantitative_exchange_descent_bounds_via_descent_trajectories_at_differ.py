"""
Visualization 2: Descent Trajectories at Different Depths

Shows simulated exchange descent trajectories for objectives at different
certificate depths. High-depth objectives show rapid, near-linear convergence
while low-depth objectives take many more steps.

This visualization makes tangible the central theorem: deeper structural
certificates force faster descent.
"""

import numpy as np
import matplotlib.pyplot as plt
import math

# ── Self-contained simulation code ──

def gen_constrained_pts(d, range_per, target, current, result, max_pts=2000):
    if len(result) >= max_pts:
        return
    if len(current) == d:
        if target == 0:
            result.append(list(current))
        return
    remaining = d - len(current) - 1
    for v in range(min(range_per, target + 1)):
        if target - v <= remaining * (range_per - 1):
            gen_constrained_pts(d, range_per, target - v,
                                current + [v], result, max_pts)


def make_points(d, range_per=4):
    target = d * (range_per - 1) // 2
    pts = []
    gen_constrained_pts(d, range_per, target, [], pts)
    return np.array(pts, dtype=int) if pts else np.zeros((1, d), dtype=int)


def make_obj(d, range_per, depth):
    weights = []
    for i in range(d):
        center = range_per / 2.0
        sigma = max(range_per / (2 + depth), 0.5)
        w = [math.exp(-(v - center)**2 / (2 * sigma**2)) for v in range(range_per)]
        total = sum(w)
        w = [x / total for x in w]
        weights.append(w)
    def obj(x):
        return sum(weights[i][int(x[i]) % len(weights[i])] for i in range(d))
    return obj


def run_descent(points, obj_fn, start_idx):
    n = len(points)
    current = start_idx
    f_vals = [obj_fn(points[current])]
    for _ in range(5000):
        best_j = -1
        best_f = f_vals[-1]
        for j in range(n):
            if j == current:
                continue
            diff = points[j] - points[current]
            nz = np.nonzero(diff)[0]
            if len(nz) != 2:
                continue
            if not ((diff[nz[0]] == 1 and diff[nz[1]] == -1) or
                    (diff[nz[0]] == -1 and diff[nz[1]] == 1)):
                continue
            fj = obj_fn(points[j])
            if fj < best_f:
                best_f = fj
                best_j = j
        if best_j == -1:
            break
        current = best_j
        f_vals.append(best_f)
    return f_vals


# ── Run simulations ──

d = 6
range_per = 4
points = make_points(d, range_per)
n_pts = len(points)

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

depths = [1, d // 2, d]
depth_labels = ['Low depth (k=1)', f'Medium depth (k={d//2})', f'Maximal depth (k={d})']
colors_by_depth = ['#e74c3c', '#f39c12', '#27ae60']

for ax, depth, label, color in zip(axes, depths, depth_labels, colors_by_depth):
    obj = make_obj(d, range_per, depth)

    # Run multiple trajectories
    np.random.seed(42)
    for trial in range(min(8, n_pts)):
        start = trial * (n_pts // 8) if n_pts >= 8 else trial
        start = min(start, n_pts - 1)
        f_vals = run_descent(points, obj, start)
        # Normalize: shift so minimum is 0
        f_min = min(f_vals)
        f_norm = [f - f_min for f in f_vals]
        ax.plot(range(len(f_norm)), f_norm, '-', color=color, alpha=0.5, linewidth=1.5)

    ax.set_xlabel('Descent Step', fontsize=12)
    ax.set_ylabel('Objective Gap (f - f*)', fontsize=12)
    ax.set_title(label, fontsize=13, fontweight='bold', color=color)
    ax.grid(True, alpha=0.3)
    ax.set_ylim(bottom=-0.01)

    # Add step count annotation
    step_counts = []
    for trial in range(min(8, n_pts)):
        start = trial * (n_pts // 8) if n_pts >= 8 else trial
        start = min(start, n_pts - 1)
        f_vals = run_descent(points, obj, start)
        step_counts.append(len(f_vals) - 1)
    avg = np.mean(step_counts)
    ax.annotate(f'Avg: {avg:.0f} steps',
                xy=(0.95, 0.95), xycoords='axes fraction',
                ha='right', va='top', fontsize=11,
                bbox=dict(boxstyle='round', facecolor='white', alpha=0.8))

fig.suptitle(f'Exchange Descent Trajectories (d={d}, |S|={n_pts})',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_descent_trajectories.png', dpi=150, bbox_inches='tight')
print("Saved viz_descent_trajectories.png")
