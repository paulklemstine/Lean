"""
Demo 12: EML as Optimal Transport Cost
c(x,y) = exp(x) - ln(y) as a transport cost function.
Shows asymmetry, cost matrix, and optimal assignment for discrete case.
"""
import numpy as np
import matplotlib.pyplot as plt

def eml_cost(x, y):
    return np.exp(x) - np.log(y)

fig, axes = plt.subplots(1, 3, figsize=(18, 5))

# Left: Asymmetry visualization
ax = axes[0]
pairs = [(0, 1), (1, 2), (-1, 3), (0.5, 0.5), (2, 1)]
for x_val, y_val in pairs:
    c_xy = eml_cost(x_val, y_val)
    c_yx = eml_cost(y_val, x_val)
    ax.barh(f'({x_val},{y_val})', c_xy, color='steelblue', alpha=0.7, label='c(x,y)' if x_val == 0 and y_val == 1 else '')
    ax.barh(f'({x_val},{y_val})', -c_yx, color='coral', alpha=0.7, label='c(y,x)' if x_val == 0 and y_val == 1 else '')
ax.axvline(x=0, color='k', linewidth=0.5)
ax.set_xlabel('Cost')
ax.set_title('EML Cost Asymmetry: c(x,y) vs c(y,x)')
ax.legend()
ax.grid(True, alpha=0.3)

# Middle: Cost matrix
ax = axes[1]
x_pts = np.linspace(-1, 2, 20)
y_pts = np.linspace(0.5, 5, 20)
C = np.zeros((len(y_pts), len(x_pts)))
for i, y in enumerate(y_pts):
    for j, x in enumerate(x_pts):
        C[i, j] = eml_cost(x, y)
im = ax.imshow(C, extent=[x_pts[0], x_pts[-1], y_pts[0], y_pts[-1]],
               aspect='auto', origin='lower', cmap='viridis')
ax.set_xlabel('Source x')
ax.set_ylabel('Target y')
ax.set_title('EML Transport Cost Matrix')
fig.colorbar(im, ax=ax, label='c(x,y)')

# Right: Optimal transport map T(x) = exp(exp(x) - φ(x))
ax = axes[2]
x = np.linspace(-2, 2, 200)
# For φ(x) = exp(x)/2 (example dual potential)
phi = np.exp(x) / 2
T = np.exp(np.exp(x) - phi)
ax.plot(x, T, 'b-', linewidth=2, label='T(x) = exp(exp(x) - φ(x))')
ax.plot(x, np.exp(np.exp(x)), 'r--', linewidth=1.5, label='exp(exp(x)) (neutral curve)')
ax.plot(x, x, 'k:', linewidth=1, label='y = x')
ax.set_xlabel('Source x')
ax.set_ylabel('Target y = T(x)')
ax.set_title('Example EML Transport Map')
ax.legend(fontsize=9)
ax.set_ylim(0, 30)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('eml_optimal_transport.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved eml_optimal_transport.png")
