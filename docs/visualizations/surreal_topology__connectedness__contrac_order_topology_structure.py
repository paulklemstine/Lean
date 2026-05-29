"""
Visualization: Surreal Topology — Order Topology Structure

Visualizes the key structural insights of the surreal topology theory:
1. The order topology on dyadic approximants (discrete/totally disconnected)
2. The contrast between countable (disconnected) and complete (connected) orders
3. The interval basis generating the topology
4. How order-convexity implies connectedness in the completed setting

This visualization illustrates the fundamental dichotomy: countable ordered
sets like the dyadics are totally disconnected in the order topology,
but their completions (like ℝ) become connected. The theorems proved in
this project characterize exactly when this transition occurs.
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import FancyBboxPatch, FancyArrowPatch
import matplotlib.gridspec as gridspec

fig = plt.figure(figsize=(16, 10))
fig.suptitle('Topology of Ordered Continua: From Discrete to Connected',
             fontsize=16, fontweight='bold', y=0.98)

gs = gridspec.GridSpec(2, 3, hspace=0.35, wspace=0.3)

# --- Panel 1: Dyadic approximants at different days ---
ax1 = fig.add_subplot(gs[0, 0])

for day in range(5):
    denom = 2 ** day
    pts = sorted(set(k / denom for k in range(-denom, denom + 1)))
    y = day
    ax1.scatter(pts, [y] * len(pts), s=max(2, 20 - 3*day),
                color=plt.cm.viridis(day / 5), zorder=5, alpha=0.8)

ax1.set_xlabel('Value', fontsize=10)
ax1.set_ylabel('Day', fontsize=10)
ax1.set_title('Dyadic Approximants\n(Day 0–4)', fontsize=12)
ax1.set_yticks(range(5))
ax1.set_xlim(-1.3, 1.3)

# --- Panel 2: Total disconnectedness of ℚ ---
ax2 = fig.add_subplot(gs[0, 1])

# Show rationals as isolated points
np.random.seed(42)
rationals = sorted(set(
    p / q for q in range(1, 8) for p in range(-q, q + 1)
    if -1.5 <= p/q <= 1.5
))

ax2.scatter(rationals, [0] * len(rationals), s=15, color='red',
            zorder=5, alpha=0.6)

# Show gaps (irrational points) as background
x_bg = np.linspace(-1.5, 1.5, 1000)
ax2.fill_between(x_bg, -0.3, 0.3, alpha=0.05, color='blue')
ax2.axhline(y=0, color='gray', linewidth=0.5, linestyle=':')

# Highlight sqrt(2) gap
sqrt2 = np.sqrt(2)
ax2.axvline(x=sqrt2, color='blue', linewidth=1, linestyle='--', alpha=0.5)
ax2.axvline(x=-sqrt2, color='blue', linewidth=1, linestyle='--', alpha=0.5)
ax2.text(sqrt2, 0.25, '√2', ha='center', fontsize=9, color='blue')
ax2.text(-sqrt2, 0.25, '-√2', ha='center', fontsize=9, color='blue')

ax2.set_xlabel('Value', fontsize=10)
ax2.set_title('ℚ: Totally Disconnected\n(gaps everywhere)', fontsize=12)
ax2.set_ylim(-0.5, 0.5)
ax2.set_xlim(-1.5, 1.5)

# --- Panel 3: ℝ as connected ---
ax3 = fig.add_subplot(gs[0, 2])

x_real = np.linspace(-1.5, 1.5, 1000)
ax3.fill_between(x_real, -0.15, 0.15, alpha=0.4, color='green')
ax3.plot(x_real, [0] * len(x_real), color='darkgreen', linewidth=3)

# Show an interval [a,b]
a, b = -0.5, 0.8
ax3.fill_between(np.linspace(a, b, 100), -0.25, 0.25, alpha=0.3, color='orange')
ax3.plot([a, b], [0, 0], color='darkorange', linewidth=4)
ax3.plot(a, 0, 'o', color='darkorange', markersize=10, zorder=5)
ax3.plot(b, 0, 'o', color='darkorange', markersize=10, zorder=5)
ax3.text((a+b)/2, 0.3, '[a, b] is connected\n& contractible',
         ha='center', fontsize=9, style='italic')

ax3.set_xlabel('Value', fontsize=10)
ax3.set_title('ℝ: Connected Continuum\n(no gaps)', fontsize=12)
ax3.set_ylim(-0.5, 0.5)
ax3.set_xlim(-1.5, 1.5)

# --- Panel 4: The completion funnel ---
ax4 = fig.add_subplot(gs[1, 0:2])

# Show the "completion funnel": ℚ → ℝ
# Left: discrete points. Right: continuous line.
n_pts = 30
np.random.seed(0)
q_pts = sorted(np.random.choice(np.arange(-20, 21) / 10, n_pts, replace=False))

for i, q in enumerate(q_pts):
    t_start = 0.0
    t_end = 1.0
    # Interpolate from discrete to continuous
    ts = np.linspace(t_start, t_end, 50)
    # Point spreads from isolated to filling the line
    for t in [0.0, 0.25, 0.5, 0.75, 1.0]:
        y_pos = t
        spread = t * 0.02
        if spread > 0:
            ax4.plot([q - spread, q + spread], [y_pos, y_pos],
                     color=plt.cm.plasma(t), linewidth=1, alpha=0.5)
        else:
            ax4.plot(q, y_pos, '.', color=plt.cm.plasma(t), markersize=3)

# Final continuous line at t=1
ax4.plot([-2, 2], [1, 1], color=plt.cm.plasma(1.0), linewidth=3, alpha=0.8)

# Labels
ax4.set_xlabel('Value', fontsize=10)
ax4.set_ylabel('Completion parameter', fontsize=10)
ax4.set_title('The Completion Funnel: Discrete → Connected', fontsize=12)
ax4.text(-1.8, 0.05, 'Isolated points (ℚ)', fontsize=9, color='purple')
ax4.text(-1.8, 0.95, 'Continuous line (ℝ)', fontsize=9, color='orange')
ax4.set_ylim(-0.1, 1.1)
ax4.set_xlim(-2.2, 2.2)

# --- Panel 5: Theorem dependency diagram ---
ax5 = fig.add_subplot(gs[1, 2])
ax5.set_xlim(0, 10)
ax5.set_ylim(0, 10)
ax5.axis('off')

theorems = [
    (5, 9, 'IsOrderConvex', '#2196F3'),
    (5, 7.2, 'OrdConnected ↔\nIsOrderConvex', '#4CAF50'),
    (2.5, 5.2, 'Icc preconnected\n→ univ preconnected', '#FF9800'),
    (7.5, 5.2, 'OrdConnected\n→ IsConnected', '#9C27B0'),
    (2.5, 3, 'ConnectedSpace\nfrom intervals', '#F44336'),
    (7.5, 3, 'Icc contractible\n(in ℝ)', '#009688'),
    (5, 1, 'Interval topology\nunique', '#795548'),
]

for x, y, label, color in theorems:
    bbox = FancyBboxPatch((x-1.8, y-0.7), 3.6, 1.4,
                          boxstyle="round,pad=0.2",
                          facecolor=color, alpha=0.2,
                          edgecolor=color, linewidth=1.5)
    ax5.add_patch(bbox)
    ax5.text(x, y, label, ha='center', va='center', fontsize=7.5,
             fontweight='bold', color=color)

# Arrows
arrows = [
    (5, 8.5, 5, 7.9),
    (3.5, 6.5, 2.5, 5.9),
    (6.5, 6.5, 7.5, 5.9),
    (2.5, 4.5, 2.5, 3.7),
]
for x1, y1, x2, y2 in arrows:
    ax5.annotate('', xy=(x2, y2), xytext=(x1, y1),
                 arrowprops=dict(arrowstyle='->', color='gray', lw=1.5))

ax5.set_title('Theorem Architecture', fontsize=12)

plt.savefig('viz_topology.png', dpi=150, bbox_inches='tight')
print("Saved viz_topology.png")
