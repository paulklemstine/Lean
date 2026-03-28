#!/usr/bin/env python3
"""
Demo 3: Families of Tropical Semirings
Visualizes different tropical semiring families, their operations,
and how the log-semiring interpolates between standard and tropical.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

fig = plt.figure(figsize=(22, 16))

# ──── Panel 1: The Zoo of Semirings ────
ax1 = fig.add_subplot(2, 3, 1)
ax1.set_title('The Zoo of Tropical Semirings', fontsize=13, fontweight='bold')
ax1.set_xlim(0, 10)
ax1.set_ylim(0, 10)

semirings = [
    (1.5, 9, 'Max-Plus (ℝ,max,+)', '#e74c3c', 'Scheduling'),
    (1.5, 7.5, 'Min-Plus (ℝ,min,+)', '#3498db', 'Shortest paths'),
    (1.5, 6, 'Max-Min (ℝ,max,min)', '#2ecc71', 'Fuzzy logic'),
    (1.5, 4.5, 'Boolean ({0,1},∨,∧)', '#f39c12', 'Circuits'),
    (1.5, 3, 'Log-semiring (ℝ,⊕ₕ,+)', '#9b59b6', 'Interpolation'),
    (1.5, 1.5, 'Supertropical', '#e056a0', 'Cancellation detection'),
]

for x, y, name, color, app in semirings:
    ax1.add_patch(plt.Circle((x-0.5, y), 0.35, color=color, alpha=0.7))
    ax1.text(x+0.2, y, name, fontsize=9, va='center', color='white', fontweight='bold')
    ax1.text(x+0.2, y-0.4, f'→ {app}', fontsize=8, va='center', color=color, alpha=0.7)

ax1.set_facecolor('#0a0a1a')
ax1.axis('off')

# ──── Panel 2: Max-Plus Addition vs Standard ────
ax2 = fig.add_subplot(2, 3, 2)
ax2.set_title('"Addition" in Different Semirings\nf(a,b) for a=3, varying b', 
              fontsize=12, fontweight='bold')

b_vals = np.linspace(-5, 10, 200)
a = 3.0

# Standard addition
standard = a + b_vals
# Max-plus (tropical addition)
maxplus = np.maximum(a, b_vals)
# Min-plus
minplus = np.minimum(a, b_vals)
# LogSumExp with h
h = 1.0
logsumexp = h * np.log(np.exp(a/h) + np.exp(b_vals/h))

ax2.plot(b_vals, standard, '-', color='#ffffff', linewidth=2, alpha=0.5, label='Standard: a+b')
ax2.plot(b_vals, maxplus, '-', color='#e74c3c', linewidth=2, label='Max-plus: max(a,b)')
ax2.plot(b_vals, minplus, '-', color='#3498db', linewidth=2, label='Min-plus: min(a,b)')
ax2.plot(b_vals, logsumexp, '--', color='#9b59b6', linewidth=2, label='LogSumExp (h=1)')

ax2.axvline(x=a, color='yellow', linestyle=':', alpha=0.3, label=f'a={a}')
ax2.set_xlabel('b', color='white')
ax2.set_ylabel('f(a,b)', color='white')
ax2.legend(facecolor='#1a1a2e', labelcolor='white', fontsize=8)
ax2.set_facecolor('#0a0a1a')
ax2.tick_params(colors='white')
for spine in ax2.spines.values():
    spine.set_color('white')

# ──── Panel 3: Maslov Dequantization (h → 0) ────
ax3 = fig.add_subplot(2, 3, 3)
ax3.set_title('Maslov Dequantization: h → 0\nLogSumExp → max as h→0', 
              fontsize=12, fontweight='bold')

b_vals = np.linspace(-3, 7, 200)
a = 3.0

h_values = [2.0, 1.0, 0.5, 0.2, 0.05]
colors = plt.cm.plasma(np.linspace(0.2, 0.9, len(h_values)))

for h, color in zip(h_values, colors):
    logsumexp = h * np.log(np.exp(a/h) + np.exp(b_vals/h))
    ax3.plot(b_vals, logsumexp, '-', color=color, linewidth=2, label=f'h={h}', alpha=0.8)

# Limit (max)
ax3.plot(b_vals, np.maximum(a, b_vals), 'w--', linewidth=3, label='h→0 (max)', alpha=0.8)

ax3.set_xlabel('b', color='white')
ax3.set_ylabel('a ⊕ₕ b', color='white')
ax3.legend(facecolor='#1a1a2e', labelcolor='white', fontsize=9)
ax3.set_facecolor('#0a0a1a')
ax3.tick_params(colors='white')
for spine in ax3.spines.values():
    spine.set_color('white')

# ──── Panel 4: Tropical Polynomials are Piecewise Linear ────
ax4 = fig.add_subplot(2, 3, 4)
ax4.set_title('Tropical Polynomial = Piecewise Linear\np(x) = max(3+2x, 1+x, 5)', 
              fontsize=12, fontweight='bold')

x = np.linspace(-5, 5, 500)

# Tropical polynomial: "3 + 2x" ⊕ "1 + x" ⊕ "5"
# In tropical: max(3+2x, 1+x, 5)
term1 = 3 + 2*x
term2 = 1 + x
term3 = 5 * np.ones_like(x)
tropical_poly = np.maximum(np.maximum(term1, term2), term3)

ax4.plot(x, term1, '--', color='#e74c3c', alpha=0.4, linewidth=1, label='3⊙x²  (=3+2x)')
ax4.plot(x, term2, '--', color='#3498db', alpha=0.4, linewidth=1, label='1⊙x   (=1+x)')
ax4.plot(x, term3, '--', color='#2ecc71', alpha=0.4, linewidth=1, label='5      (=5)')
ax4.plot(x, tropical_poly, '-', color='#f39c12', linewidth=3, label='Tropical max')

# Mark the tropical roots (kinks)
# 3+2x = 1+x → x = -2; 1+x = 5 → x = 4; 3+2x = 5 → x = 1
roots_x = [-2, 1, 4]
for rx in roots_x:
    ry = max(3+2*rx, 1+rx, 5)
    ax4.plot(rx, ry, 'o', color='white', markersize=10, zorder=5)
    ax4.text(rx, ry+0.8, f'x={rx}', ha='center', color='white', fontsize=9)

ax4.set_xlabel('x', color='white')
ax4.set_ylabel('p(x)', color='white')
ax4.legend(facecolor='#1a1a2e', labelcolor='white', fontsize=9)
ax4.set_facecolor('#0a0a1a')
ax4.tick_params(colors='white')
for spine in ax4.spines.values():
    spine.set_color('white')

# ──── Panel 5: Custom Universe — Operation Tables ────
ax5 = fig.add_subplot(2, 3, 5)
ax5.set_title('Custom Universe: Compare Operation Tables\nAddition in ℤ₅ vs Max-Plus on {0,1,2,3,4}', 
              fontsize=12, fontweight='bold')

n = 5
# Z/5Z addition table
z5_add = np.array([[(i+j) % n for j in range(n)] for i in range(n)])
# Max-plus table
maxplus_table = np.array([[max(i,j) for j in range(n)] for i in range(n)])

# Combined visualization
combined = np.zeros((n, 2*n+1))
combined[:, :n] = z5_add
combined[:, n] = -1  # separator
combined[:, n+1:] = maxplus_table

im = ax5.imshow(combined, cmap='plasma', aspect='equal')
for i in range(n):
    for j in range(n):
        ax5.text(j, i, str(z5_add[i,j]), ha='center', va='center', fontsize=12, color='white')
        ax5.text(j+n+1, i, str(maxplus_table[i,j]), ha='center', va='center', fontsize=12, color='white')

ax5.axvline(x=n-0.5, color='white', linewidth=3)
ax5.axvline(x=n+0.5, color='white', linewidth=3)

ax5.set_xticks(list(range(n)) + list(range(n+1, 2*n+1)))
ax5.set_xticklabels(list(range(n)) + list(range(n)), color='white', fontsize=9)
ax5.set_yticks(range(n))
ax5.set_yticklabels(range(n), color='white', fontsize=9)
ax5.text(2, -0.8, 'ℤ₅ addition (mod 5)', ha='center', fontsize=11, color='#3498db', fontweight='bold')
ax5.text(n+3, -0.8, 'Max-plus "addition"', ha='center', fontsize=11, color='#e74c3c', fontweight='bold')
ax5.set_facecolor('#0a0a1a')

# ──── Panel 6: Semiring Morphism Diagram ────
ax6 = fig.add_subplot(2, 3, 6)
ax6.set_title('Semiring Morphism Network\nMaps between algebraic universes', 
              fontsize=12, fontweight='bold')
ax6.set_xlim(-2, 12)
ax6.set_ylim(-1, 9)

nodes = {
    '(ℝ,+,×)': (2, 7),
    '(ℝ₊,+,×)': (8, 7),
    '(ℝ,max,+)': (2, 4),
    '(ℝ,min,+)': (8, 4),
    '({0,1},∨,∧)': (5, 1),
    '(ℝ,⊕ₕ,+)': (5, 5.5),
}

node_colors = {
    '(ℝ,+,×)': '#ffffff', '(ℝ₊,+,×)': '#2ecc71',
    '(ℝ,max,+)': '#e74c3c', '(ℝ,min,+)': '#3498db',
    '({0,1},∨,∧)': '#f39c12', '(ℝ,⊕ₕ,+)': '#9b59b6',
}

for name, (nx, ny) in nodes.items():
    color = node_colors[name]
    ax6.add_patch(plt.Circle((nx, ny), 0.8, facecolor='#1a1a2e', edgecolor=color, linewidth=2))
    ax6.text(nx, ny, name, ha='center', va='center', fontsize=8, color=color, fontweight='bold')

# Morphisms (edges)
edges = [
    ('(ℝ,+,×)', '(ℝ₊,+,×)', 'exp', '#2ecc71'),
    ('(ℝ₊,+,×)', '(ℝ,max,+)', 'log (h→0)', '#e74c3c'),
    ('(ℝ,max,+)', '(ℝ,min,+)', 'x↦−x', '#3498db'),
    ('(ℝ,max,+)', '({0,1},∨,∧)', 'threshold', '#f39c12'),
    ('(ℝ,min,+)', '({0,1},∨,∧)', 'threshold', '#f39c12'),
    ('(ℝ,+,×)', '(ℝ,⊕ₕ,+)', 'deform', '#9b59b6'),
    ('(ℝ,⊕ₕ,+)', '(ℝ,max,+)', 'h→0', '#e056a0'),
]

for src, dst, label, color in edges:
    sx, sy = nodes[src]
    dx, dy = nodes[dst]
    # Shorten arrows to not overlap circles
    angle = np.arctan2(dy-sy, dx-sx)
    sx2 = sx + 0.85*np.cos(angle)
    sy2 = sy + 0.85*np.sin(angle)
    dx2 = dx - 0.85*np.cos(angle)
    dy2 = dy - 0.85*np.sin(angle)
    ax6.annotate('', xy=(dx2, dy2), xytext=(sx2, sy2),
                arrowprops=dict(arrowstyle='->', color=color, lw=1.5))
    mx, my = (sx+dx)/2, (sy+dy)/2
    ax6.text(mx+0.3, my+0.3, label, fontsize=7, color=color, fontstyle='italic')

ax6.set_facecolor('#0a0a1a')
ax6.axis('off')

fig.patch.set_facecolor('#0a0a1a')
plt.tight_layout()
plt.savefig('/workspace/request-project/demos/tropical_families.png', 
            dpi=150, bbox_inches='tight', facecolor='#0a0a1a')
plt.close()
print("✅ Saved: demos/tropical_families.png")
