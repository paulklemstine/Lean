"""
Visualization: Contraction Homotopy on Dyadic Intervals

Visualizes the contractibility theorem: closed intervals [a,b] containing 0
are contractible via the scalar homotopy H(x,t) = (1-t)·x. Shows multiple
starting points being simultaneously contracted to 0, demonstrating that
the entire interval is homotopy-equivalent to a point.

This is the core visual insight of surreal topology: despite potentially
containing infinitesimals and infinite elements (in non-Archimedean settings),
convex intervals in ordered fields are always topologically trivial.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches

fig, axes = plt.subplots(2, 2, figsize=(14, 10))
fig.suptitle('Contraction Homotopy on Ordered Intervals',
             fontsize=16, fontweight='bold', y=0.98)

# --- Panel 1: Contraction paths H(x,t) = (1-t)·x ---
ax1 = axes[0, 0]
t_vals = np.linspace(0, 1, 100)
start_points = np.linspace(-1, 1, 15)
colors = plt.cm.coolwarm(np.linspace(0, 1, len(start_points)))

for x0, color in zip(start_points, colors):
    path = (1 - t_vals) * x0
    ax1.plot(t_vals, path, color=color, alpha=0.7, linewidth=1.5)

ax1.axhline(y=0, color='black', linewidth=0.5, linestyle='--')
ax1.set_xlabel('Time t', fontsize=11)
ax1.set_ylabel('Position H(x,t) = (1-t)·x', fontsize=11)
ax1.set_title('Contraction Homotopy Paths', fontsize=13)
ax1.set_xlim(0, 1)
ax1.set_ylim(-1.1, 1.1)

# --- Panel 2: Dyadic approximant density growth ---
ax2 = axes[0, 1]
days = range(0, 8)
sizes = [2 * 2**n + 1 for n in days]
densities = [s / (2 * 1.0) for s in sizes]  # points per unit length

ax2.bar(list(days), sizes, color='steelblue', alpha=0.8, edgecolor='navy')
for i, (d, s) in enumerate(zip(days, sizes)):
    ax2.text(d, s + 2, str(s), ha='center', va='bottom', fontsize=9)

ax2.set_xlabel('Day n', fontsize=11)
ax2.set_ylabel('Number of dyadic points', fontsize=11)
ax2.set_title('Growth of Bounded-Day Dyadics', fontsize=13)
ax2.set_yscale('log')
ax2.set_ylim(1, 1000)

# --- Panel 3: Interval preconnectedness illustration ---
ax3 = axes[1, 0]
# Show that any two points in [a,b] can be connected via the interval
a, b = -0.8, 0.8
x_interval = np.linspace(a, b, 200)
ax3.fill_between(x_interval, -0.3, 0.3, alpha=0.15, color='green',
                  label='Interval [a,b]')
ax3.plot([a, b], [0, 0], 'g-', linewidth=3, alpha=0.5)

# Show specific connection paths
pairs = [(-0.6, 0.5), (-0.3, 0.7), (0.1, -0.7)]
pair_colors = ['#e41a1c', '#377eb8', '#ff7f00']
for (x1, x2), pc in zip(pairs, pair_colors):
    ax3.plot([x1, x2], [0, 0], '-', color=pc, linewidth=2.5, alpha=0.8)
    ax3.plot(x1, 0, 'o', color=pc, markersize=8, zorder=5)
    ax3.plot(x2, 0, 'o', color=pc, markersize=8, zorder=5)

ax3.plot(a, 0, 's', color='darkgreen', markersize=10, zorder=5)
ax3.plot(b, 0, 's', color='darkgreen', markersize=10, zorder=5)
ax3.set_xlim(-1.1, 1.1)
ax3.set_ylim(-0.5, 0.5)
ax3.set_xlabel('Position', fontsize=11)
ax3.set_title('Interval Preconnectedness', fontsize=13)
ax3.text(0, 0.35, 'Any two points are connected\nthrough the interval',
         ha='center', fontsize=10, style='italic')

# --- Panel 4: Connectivity vs epsilon ---
ax4 = axes[1, 1]

def bounded_day_dyadics_float(n):
    denom = 2 ** n
    return sorted(set(k / denom for k in range(-denom, denom + 1)))

def count_components(points, eps):
    n = len(points)
    parent = list(range(n))
    def find(x):
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x
    def union(x, y):
        px, py = find(x), find(y)
        if px != py:
            parent[px] = py
    for i in range(n):
        for j in range(i+1, n):
            if abs(points[j] - points[i]) <= eps:
                union(i, j)
    return len(set(find(i) for i in range(n)))

for day in [2, 3, 4]:
    pts = bounded_day_dyadics_float(day)
    epsilons = np.linspace(0.001, 0.6, 50)
    betti0 = [count_components(pts, e) for e in epsilons]
    ax4.plot(epsilons, betti0, '-', linewidth=2, label=f'Day {day}')

ax4.set_xlabel('ε (adjacency threshold)', fontsize=11)
ax4.set_ylabel('β₀ (connected components)', fontsize=11)
ax4.set_title('Persistent Betti-0 of Dyadics', fontsize=13)
ax4.legend(fontsize=10)
ax4.set_yscale('log')

plt.tight_layout(rect=[0, 0, 1, 0.96])
plt.savefig('viz_contraction.png', dpi=150, bbox_inches='tight')
print("Saved viz_contraction.png")
