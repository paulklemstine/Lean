"""
Demo 4: Joint Convexity of EML
Visualizes that sublevel sets of eml(x,y) are convex and demonstrates
the joint convexity inequality with random test points.
"""
import numpy as np
import matplotlib.pyplot as plt

def eml(x, y):
    return np.exp(x) - np.log(y)

# Sublevel sets
x = np.linspace(-3, 2, 400)
y = np.linspace(0.1, 20, 400)
X, Y = np.meshgrid(x, y)
Z = eml(X, Y)

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left: Convex sublevel sets
ax = axes[0]
levels = [0, 1, 2, 3, 5, 8]
colors = ['#1f77b4', '#ff7f0e', '#2ca02c', '#d62728', '#9467bd', '#8c564b']
for lvl, col in zip(levels, colors):
    ax.contour(X, Y, Z, levels=[lvl], colors=[col], linewidths=2)
    ax.contourf(X, Y, Z, levels=[-100, lvl], colors=[col], alpha=0.1)

ax.set_xlabel('x')
ax.set_ylabel('y')
ax.set_title('Convex Sublevel Sets {eml(x,y) ≤ c}')
ax.set_xlim(-3, 2)
ax.set_ylim(0.1, 20)

# Add legend entries
for lvl, col in zip(levels, colors):
    ax.plot([], [], color=col, linewidth=2, label=f'c = {lvl}')
ax.legend(loc='upper right')
ax.grid(True, alpha=0.3)

# Right: Verify joint convexity numerically
ax = axes[1]
np.random.seed(42)
n_tests = 1000
violations = 0
t_vals = np.random.uniform(0, 1, n_tests)
x1_vals = np.random.uniform(-2, 2, n_tests)
x2_vals = np.random.uniform(-2, 2, n_tests)
y1_vals = np.random.uniform(0.1, 5, n_tests)
y2_vals = np.random.uniform(0.1, 5, n_tests)

lhs = eml(t_vals * x1_vals + (1 - t_vals) * x2_vals,
          t_vals * y1_vals + (1 - t_vals) * y2_vals)
rhs = t_vals * eml(x1_vals, y1_vals) + (1 - t_vals) * eml(x2_vals, y2_vals)

gaps = rhs - lhs  # should be ≥ 0

ax.hist(gaps, bins=50, color='steelblue', edgecolor='black', alpha=0.7)
ax.axvline(x=0, color='red', linewidth=2, linestyle='--', label='Convexity boundary')
ax.set_xlabel('t·eml(x₁,y₁) + (1-t)·eml(x₂,y₂) - eml(mix, mix)')
ax.set_ylabel('Count')
ax.set_title(f'Joint Convexity Verification ({n_tests} random tests)\nMin gap = {gaps.min():.6f}')
ax.legend()
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('joint_convexity.png', dpi=150, bbox_inches='tight')
plt.close()
print(f"Saved joint_convexity.png (violations: {(gaps < -1e-10).sum()}/{n_tests})")
