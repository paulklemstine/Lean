"""
Demo 13: EML Gradient Flow
∇eml = (exp(x), -1/y), gradient flow ODE: ẋ = -exp(x), ẏ = 1/y.
Explicit solution: x(t) = -ln(exp(-x₀) + t), y(t) = √(y₀² + 2t).
"""
import numpy as np
import matplotlib.pyplot as plt

def eml(x, y):
    return np.exp(x) - np.log(y)

def gradient_flow(x0, y0, T=5, dt=0.01):
    """Simulate gradient descent on EML."""
    ts = np.arange(0, T, dt)
    xs = -np.log(np.exp(-x0) + ts)
    ys = np.sqrt(y0**2 + 2*ts)
    return ts, xs, ys

fig, axes = plt.subplots(1, 3, figsize=(18, 5))

# Left: Flow trajectories in (x, y) plane
ax = axes[0]
x_bg = np.linspace(-3, 3, 30)
y_bg = np.linspace(0.3, 8, 30)
X, Y = np.meshgrid(x_bg, y_bg)
U = -np.exp(X)  # -∂eml/∂x
V = 1/Y         # -∂eml/∂y (note: ∂eml/∂y = -1/y, so -∂eml/∂y = 1/y)
speed = np.sqrt(U**2 + V**2)
ax.streamplot(X, Y, U, V, color=speed, cmap='coolwarm', density=1.5, linewidth=0.8)

starts = [(2, 0.5), (1, 1), (0, 2), (-1, 0.5), (2, 3)]
colors = ['red', 'blue', 'green', 'purple', 'orange']
for (x0, y0), col in zip(starts, colors):
    ts, xs, ys = gradient_flow(x0, y0, T=3)
    valid = np.isfinite(xs) & np.isfinite(ys)
    ax.plot(xs[valid], ys[valid], color=col, linewidth=2)
    ax.plot(x0, y0, 'o', color=col, markersize=8)

ax.set_xlabel('x')
ax.set_ylabel('y')
ax.set_title('EML Gradient Flow Trajectories')
ax.set_xlim(-3, 3)
ax.set_ylim(0.3, 8)
ax.grid(True, alpha=0.3)

# Middle: x(t) and y(t) over time
ax = axes[1]
for (x0, y0), col in zip(starts[:3], colors[:3]):
    ts, xs, ys = gradient_flow(x0, y0, T=5)
    valid = np.isfinite(xs)
    ax.plot(ts[valid], xs[valid], '-', color=col, linewidth=2, label=f'x(t), x₀={x0}')
    ax.plot(ts, ys, '--', color=col, linewidth=2, label=f'y(t), y₀={y0}')
ax.set_xlabel('t')
ax.set_ylabel('Value')
ax.set_title('Gradient Flow Components')
ax.legend(fontsize=7)
ax.grid(True, alpha=0.3)

# Right: EML value along flow
ax = axes[2]
for (x0, y0), col in zip(starts[:3], colors[:3]):
    ts, xs, ys = gradient_flow(x0, y0, T=5)
    valid = np.isfinite(xs) & np.isfinite(ys) & (ys > 0)
    eml_vals = eml(xs[valid], ys[valid])
    ax.plot(ts[valid], eml_vals, color=col, linewidth=2, label=f'({x0},{y0})')
ax.set_xlabel('t')
ax.set_ylabel('eml(x(t), y(t))')
ax.set_title('EML Value Along Gradient Flow (Decreasing)')
ax.legend()
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('eml_gradient_flow.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved eml_gradient_flow.png")
