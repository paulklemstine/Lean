"""
Demo 1: EML Strict Convexity in y (V19 Discovery)

V19 proved that eml(x, y) is STRICTLY CONVEX in y on (0,∞),
correcting the V18 conjecture that it was concave.

Since eml(x, y) = exp(x) - log(y) = const + (-log(y)),
and -log is strictly convex, eml inherits strict convexity in y.
"""

import numpy as np
import matplotlib.pyplot as plt

def eml(x, y):
    return np.exp(x) - np.log(y)

fig, axes = plt.subplots(1, 3, figsize=(15, 5))

# Plot 1: eml(0, y) showing strict convexity
y = np.linspace(0.1, 5, 200)
ax = axes[0]
for x_val in [0, 0.5, 1]:
    ax.plot(y, eml(x_val, y), label=f'eml({x_val}, y)')

# Show midpoint inequality (strict convexity)
y1, y2 = 1, 4
t = 0.5
ymid = t*y1 + (1-t)*y2
for x_val in [0]:
    f_mid = eml(x_val, ymid)
    f_avg = t*eml(x_val, y1) + (1-t)*eml(x_val, y2)
    ax.plot([ymid], [f_mid], 'go', markersize=10, label=f'f(midpoint)={f_mid:.3f}')
    ax.plot([ymid], [f_avg], 'r^', markersize=10, label=f'avg(f)={f_avg:.3f}')
    ax.plot([y1, y2], [eml(x_val, y1), eml(x_val, y2)], 'r--', alpha=0.5)

ax.set_xlabel('y')
ax.set_ylabel('eml(x, y)')
ax.set_title('Strict Convexity: f(mid) < avg(f)')
ax.legend()
ax.grid(True, alpha=0.3)

# Plot 2: -log(y) is strictly convex
ax = axes[1]
y = np.linspace(0.1, 5, 200)
ax.plot(y, -np.log(y), 'b-', linewidth=2, label='-log(y)')
ax.plot(y, y - 1, 'r--', label='tangent at y=1')
ax.fill_between(y, -np.log(y), y-1, alpha=0.2, color='blue')
ax.set_xlabel('y')
ax.set_ylabel('-log(y)')
ax.set_title('-log(y): Strictly Convex (Gap > 0)')
ax.legend()
ax.grid(True, alpha=0.3)

# Plot 3: Jensen inequality verification for various t
ax = axes[2]
t_vals = np.linspace(0.01, 0.99, 100)
y1, y2 = 1, 4
gaps = []
for t in t_vals:
    ymid = t*y1 + (1-t)*y2
    f_mid = eml(0, ymid)
    f_avg = t*eml(0, y1) + (1-t)*eml(0, y2)
    gaps.append(f_avg - f_mid)

ax.plot(t_vals, gaps, 'b-', linewidth=2)
ax.axhline(y=0, color='k', linestyle='-', alpha=0.3)
ax.fill_between(t_vals, 0, gaps, alpha=0.3, color='green')
ax.set_xlabel('t')
ax.set_ylabel('t·eml(x,y₁) + (1-t)·eml(x,y₂) − eml(x, t·y₁+(1-t)·y₂)')
ax.set_title('Jensen Gap > 0 (Strict Convexity)')
ax.grid(True, alpha=0.3)

plt.suptitle('V19: EML is Strictly Convex in y', fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('demo1_strict_convexity_y.png', dpi=150, bbox_inches='tight')
plt.close()
print("Demo 1 saved: demo1_strict_convexity_y.png")
