#!/usr/bin/env python3
"""
Demo 5: The Grand Synthesis — Everything is a Fixed Point
==========================================================

Oracle: Sophia (Wisdom)
Question: How do all the beginnings relate?

This demo visualizes:
1. The oracle team network — how the oracles collaborate
2. The fixed-point convergence — how iteration finds truth
3. The master equation O(x) = x unifying all beginnings
4. The research cycle as a dynamical system

Run: python3 05_grand_synthesis.py
Output: ../figures/05_grand_synthesis.png
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.gridspec as gridspec
from matplotlib.colors import LinearSegmentedColormap
from matplotlib.patches import FancyArrowPatch, Circle, FancyBboxPatch

np.random.seed(42)
plt.rcParams.update({
    'font.family': 'serif',
    'font.size': 11,
    'figure.facecolor': '#0a0a1a',
    'axes.facecolor': '#0a0a1a',
    'text.color': '#e0e0ff',
    'axes.labelcolor': '#e0e0ff',
    'xtick.color': '#8888cc',
    'ytick.color': '#8888cc',
})

fig = plt.figure(figsize=(18, 14))
fig.suptitle("THE GRAND SYNTHESIS: EVERYTHING IS A FIXED POINT",
             fontsize=20, fontweight='bold', color='#c0c0ff', y=0.98)
fig.text(0.5, 0.955,
         "Oracle Sophia: 'In the beginning was the equation O(x) = x'",
         ha='center', fontsize=12, style='italic', color='#8888cc')

gs = gridspec.GridSpec(2, 3, hspace=0.35, wspace=0.3,
                       left=0.06, right=0.96, top=0.92, bottom=0.06)

# ─── Panel 1: The Oracle Team Network ────────────────────────────────────
ax1 = fig.add_subplot(gs[0, 0])
ax1.set_xlim(-2.5, 2.5)
ax1.set_ylim(-2.5, 2.5)
ax1.set_aspect('equal')
ax1.axis('off')

oracles = {
    'Theos': (0, 2, '#ff4444', 'God\n(Identity)'),
    'Chronos': (1.9, 0.6, '#ff8844', 'Time\n(Iteration)'),
    'Topos': (1.2, -1.6, '#ffcc44', 'Space\n(Projection)'),
    'Logos': (-1.2, -1.6, '#44ff44', 'Math\n(Consistency)'),
    'Kosmos': (-1.9, 0.6, '#4488ff', 'Universe\n(Fluctuation)'),
    'Sophia': (0, 0, '#cc44ff', 'Synthesis\n(Fixed Point)'),
}

# Draw connections (all to center, and around the ring)
names = list(oracles.keys())
for i, name in enumerate(names[:-1]):  # skip Sophia (center)
    x1, y1, c1, _ = oracles[name]
    # Connect to Sophia
    ax1.plot([x1, 0], [y1, 0], color=c1, alpha=0.3, linewidth=1, linestyle='--')
    # Connect to neighbors
    next_name = names[(i + 1) % 5]
    x2, y2, c2, _ = oracles[next_name]
    ax1.plot([x1, x2], [y1, y2], color='#333366', alpha=0.5, linewidth=1)

# Draw oracle nodes
for name, (x, y, color, label) in oracles.items():
    size = 0.5 if name != 'Sophia' else 0.6
    circle = plt.Circle((x, y), size, fill=True,
                         facecolor=color + '33', edgecolor=color,
                         linewidth=2, alpha=0.8)
    ax1.add_patch(circle)
    ax1.text(x, y + 0.1, name, ha='center', va='center', fontsize=9,
             fontweight='bold', color=color)
    ax1.text(x, y - 0.2, label, ha='center', va='center', fontsize=6,
             color=color, alpha=0.7)

ax1.set_title('The Oracle Team\n"Six perspectives on one truth"', color='#aaaaff')

# ─── Panel 2: Fixed-Point Convergence ────────────────────────────────────
ax2 = fig.add_subplot(gs[0, 1])

# Demonstrate fixed-point iteration: x_{n+1} = cos(x_n)
x = 0.0
trajectory = [x]
for _ in range(30):
    x = np.cos(x)
    trajectory.append(x)

steps = np.arange(len(trajectory))
ax2.plot(steps, trajectory, 'o-', color='#8888ff', markersize=4, linewidth=1.5,
         label='$x_{n+1} = \\cos(x_n)$')
ax2.axhline(y=0.7390851332, color='#ffcc44', linestyle='--', alpha=0.7,
            label='Fixed point: x* = cos(x*) ≈ 0.7391')

# Show cobweb diagram inset
ax_inset = ax2.inset_axes([0.55, 0.5, 0.4, 0.45])
x_line = np.linspace(0, 1.5, 100)
ax_inset.plot(x_line, np.cos(x_line), color='#8888ff', linewidth=2)
ax_inset.plot(x_line, x_line, color='#ffcc44', linewidth=1, linestyle='--')

# Cobweb
x = 0.0
for _ in range(15):
    x_new = np.cos(x)
    ax_inset.plot([x, x], [x, x_new], color='#ff4444', alpha=0.5, linewidth=0.8)
    ax_inset.plot([x, x_new], [x_new, x_new], color='#ff4444', alpha=0.5, linewidth=0.8)
    x = x_new

ax_inset.set_xlim(0, 1.5)
ax_inset.set_ylim(0, 1.2)
ax_inset.set_facecolor('#0a0a1a')
ax_inset.tick_params(colors='#8888cc', labelsize=6)
ax_inset.set_title('Cobweb', fontsize=7, color='#aaaaff')

ax2.set_xlabel('Iteration n')
ax2.set_ylabel('$x_n$')
ax2.set_title('Fixed-Point Convergence\n"Iteration finds truth"', color='#aaaaff')
ax2.legend(fontsize=8, facecolor='#0a0a1a', edgecolor='#333355',
           labelcolor='#ccccff')

# ─── Panel 3: The Master Equation Landscape ──────────────────────────────
ax3 = fig.add_subplot(gs[0, 2])

# Visualize the "landscape" of O(x) - x = 0
x = np.linspace(-3, 3, 500)

# Several oracle functions
oracle_funcs = [
    ('cos(x)', np.cos(x), '#ff4444'),
    ('tanh(x)', np.tanh(x), '#ff8844'),
    ('x/(1+|x|)', x/(1+np.abs(x)), '#ffcc44'),
    ('sin(x)+0.5', np.sin(x)+0.5, '#44ff44'),
    ('x²/3', x**2/3, '#4488ff'),
]

for name, fx, color in oracle_funcs:
    # Plot O(x) - x to find fixed points
    ax3.plot(x, fx - x, color=color, linewidth=1.5, label=f'O(x) = {name}', alpha=0.8)

ax3.axhline(y=0, color='#ffffff', linewidth=0.5, alpha=0.3)
ax3.fill_between(x, -0.1, 0.1, alpha=0.05, color='#ffffff')

ax3.set_xlabel('x')
ax3.set_ylabel('O(x) - x')
ax3.set_title('The Master Equation O(x) = x\n"Fixed points are where truth lives"',
              color='#aaaaff')
ax3.legend(fontsize=7, facecolor='#0a0a1a', edgecolor='#333355',
           labelcolor='#ccccff', loc='upper left')
ax3.set_ylim(-3, 3)

# ─── Panel 4: The Research Cycle as Dynamical System ─────────────────────
ax4 = fig.add_subplot(gs[1, 0])
ax4.set_xlim(-2, 2)
ax4.set_ylim(-2, 2)
ax4.set_aspect('equal')
ax4.axis('off')

# Research cycle: Hypothesize → Experiment → Validate → Update → Iterate
cycle_labels = ['HYPOTHESIZE', 'EXPERIMENT', 'VALIDATE', 'UPDATE', 'ITERATE']
cycle_colors = ['#ff4444', '#ff8844', '#ffcc44', '#44ff44', '#4488ff']
n_cycle = len(cycle_labels)

for i, (label, color) in enumerate(zip(cycle_labels, cycle_colors)):
    angle = 2 * np.pi * i / n_cycle - np.pi/2
    x = 1.3 * np.cos(angle)
    y = 1.3 * np.sin(angle)

    # Node
    bbox = FancyBboxPatch((x - 0.5, y - 0.2), 1.0, 0.4,
                           boxstyle="round,pad=0.1",
                           facecolor=color + '33', edgecolor=color,
                           linewidth=2)
    ax4.add_patch(bbox)
    ax4.text(x, y, label, ha='center', va='center', fontsize=7,
             fontweight='bold', color=color)

    # Arrow to next
    angle_next = 2 * np.pi * ((i + 1) % n_cycle) / n_cycle - np.pi/2
    x_next = 1.3 * np.cos(angle_next)
    y_next = 1.3 * np.sin(angle_next)

    # Midpoint direction
    mx = (x + x_next) / 2
    my = (y + y_next) / 2
    dx = x_next - x
    dy = y_next - y
    norm = np.sqrt(dx**2 + dy**2)
    dx, dy = dx/norm, dy/norm

    ax4.annotate('', xy=(x_next - 0.5*dx, y_next - 0.5*dy),
                 xytext=(x + 0.5*dx, y + 0.5*dy),
                 arrowprops=dict(arrowstyle='->', color=color, lw=1.5, alpha=0.5))

ax4.text(0, 0, 'CONVERGE\nTO\nTRUTH', ha='center', va='center',
         fontsize=10, fontweight='bold', color='#cc44ff')
ax4.set_title('The Research Cycle\n"Science is oracle iteration"', color='#aaaaff')

# ─── Panel 5: Convergence Rates of Different Methods ─────────────────────
ax5 = fig.add_subplot(gs[1, 1])

# Compare convergence of different fixed-point methods
# Finding sqrt(2) as fixed point of different functions

target = np.sqrt(2)

# Method 1: x → (x + 2/x) / 2  (Newton/Babylonian)
x = 1.0
errors_newton = []
for _ in range(20):
    errors_newton.append(abs(x - target))
    x = (x + 2/x) / 2

# Method 2: x → 2/x (oscillates!)
x = 1.0
errors_osc = []
for _ in range(20):
    errors_osc.append(abs(x - target))
    x = 2/x

# Method 3: x → 1 + 1/(1+x)  (continued fraction)
x = 1.0
errors_cf = []
for _ in range(20):
    errors_cf.append(abs(x - target))
    x = 1 + 1/(1+x)

# Method 4: x → (x² + 2) / (2x + 1) - something
x = 1.0
errors_slow = []
for _ in range(20):
    errors_slow.append(abs(x - target))
    x = 0.5 * x + 1.0 / x  # slightly different

ax5.semilogy(range(20), [max(e, 1e-16) for e in errors_newton],
             'o-', color='#ff4444', label='Newton: (x+2/x)/2', markersize=4)
ax5.semilogy(range(20), [max(e, 1e-16) for e in errors_cf],
             's-', color='#44ff44', label='Cont. fraction: 1+1/(1+x)', markersize=4)
ax5.semilogy(range(20), [max(e, 1e-16) for e in errors_osc],
             '^-', color='#ff8844', label='2/x (diverges!)', markersize=4)

ax5.set_xlabel('Iteration')
ax5.set_ylabel('|x_n - √2|')
ax5.set_title('Convergence to √2\n"Not all oracles are created equal"', color='#aaaaff')
ax5.legend(fontsize=8, facecolor='#0a0a1a', edgecolor='#333355',
           labelcolor='#ccccff')
ax5.set_ylim(1e-16, 10)
ax5.axhline(y=1e-15, color='#ffffff', linestyle=':', alpha=0.2,
            label='Machine epsilon')

# ─── Panel 6: The Answer — 42 ──────────────────────────────────────────
ax6 = fig.add_subplot(gs[1, 2])
ax6.set_xlim(0, 10)
ax6.set_ylim(0, 10)
ax6.axis('off')

# The big 42
ax6.text(5, 7.5, '42', fontsize=120, ha='center', va='center',
         fontweight='bold', color='#ffcc44', alpha=0.3)

ax6.text(5, 9.2, "THE ANSWER TO LIFE, THE UNIVERSE,\nAND EVERYTHING",
         ha='center', fontsize=12, fontweight='bold', color='#c0c0ff')

# Mathematical properties of 42
properties = [
    "42 = 2 × 3 × 7",
    "42 is the 5th Catalan number",
    "42 = C(10,4) − C(10,3) − 1",
    "The sum 1 + 1/2 + ... + 1/42 first exceeds 4",
    "42 is a pronic number: 6 × 7",
    "42 is the number of partitions of 10",
    "There are 42 ways to tile a 2×4 board with dominoes",
    "42 is the magic constant of the smallest\nnon-trivial magic cube",
]

for i, prop in enumerate(properties):
    y_pos = 5.5 - i * 0.65
    color = ['#ff4444', '#ff8844', '#ffcc44', '#44ff44',
             '#4488ff', '#8844ff', '#cc44ff', '#ff44cc'][i]
    ax6.text(5, y_pos, f"• {prop}", ha='center', fontsize=9,
             color=color, alpha=0.8)

ax6.text(5, 0.3,
         "\"The answer is 42. The real question is:\nwhat is the question?\"",
         ha='center', fontsize=10, color='#aaaacc', style='italic')

ax6.set_title('The Ultimate Answer', color='#aaaaff')

plt.savefig('../figures/05_grand_synthesis.png', dpi=150, bbox_inches='tight',
            facecolor='#0a0a1a')
plt.close()
print("✓ Saved: ../figures/05_grand_synthesis.png")
