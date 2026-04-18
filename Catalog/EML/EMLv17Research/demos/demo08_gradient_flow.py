"""Demo 8: EML Gradient Flow Trajectories

Simulates the gradient flow dx/dt = -exp(x), dy/dt = 1/y
with explicit solutions x(t) = -ln(exp(-x₀) + t), y(t) = sqrt(y₀² + 2t).
"""
import numpy as np
import matplotlib.pyplot as plt

def eml(x, y):
    return np.exp(x) - np.log(y)

# Explicit gradient flow solutions
def flow_x(x0, t):
    return -np.log(np.exp(-x0) + t)

def flow_y(y0, t):
    return np.sqrt(y0**2 + 2*t)

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Plot 1: Trajectories in (x,y) plane
t = np.linspace(0, 5, 500)
starts = [(1, 0.5), (2, 1), (0, 2), (1.5, 0.3), (-0.5, 3)]
colors = plt.cm.viridis(np.linspace(0, 1, len(starts)))

for (x0, y0), c in zip(starts, colors):
    xt = flow_x(x0, t)
    yt = flow_y(y0, t)
    valid = np.isfinite(xt) & np.isfinite(yt) & (yt > 0)
    axes[0,0].plot(xt[valid], yt[valid], '-', color=c, linewidth=1.5)
    axes[0,0].plot(x0, y0, 'o', color=c, markersize=8)

# Background: EML contours
x_grid = np.linspace(-3, 3, 200)
y_grid = np.linspace(0.1, 8, 200)
X, Y = np.meshgrid(x_grid, y_grid)
Z = np.exp(X) - np.log(Y)
axes[0,0].contour(X, Y, Z, levels=np.arange(-5, 15, 1), alpha=0.3, colors='gray')
axes[0,0].set_xlabel('x'); axes[0,0].set_ylabel('y')
axes[0,0].set_title('Gradient Flow Trajectories')
axes[0,0].set_xlim(-3, 3); axes[0,0].set_ylim(0, 8)

# Plot 2: EML along flow (should be decreasing)
for (x0, y0), c in zip(starts[:3], colors[:3]):
    xt = flow_x(x0, t)
    yt = flow_y(y0, t)
    valid = np.isfinite(xt) & np.isfinite(yt) & (yt > 0)
    eml_t = eml(xt[valid], yt[valid])
    axes[0,1].plot(t[valid], eml_t, '-', color=c, linewidth=2,
                   label=f'({x0}, {y0})')

axes[0,1].set_xlabel('t'); axes[0,1].set_ylabel('eml(x(t), y(t))')
axes[0,1].set_title('EML Decreasing Along Flow')
axes[0,1].legend(); axes[0,1].grid(True, alpha=0.3)

# Plot 3: Component evolution
x0, y0 = 1, 0.5
xt = flow_x(x0, t)
yt = flow_y(y0, t)
valid = np.isfinite(xt) & (yt > 0)
axes[1,0].plot(t[valid], xt[valid], 'b-', linewidth=2, label='x(t)')
axes[1,0].plot(t[valid], yt[valid], 'r-', linewidth=2, label='y(t)')
axes[1,0].set_xlabel('t')
axes[1,0].set_title('Component Evolution: x(t) → -∞, y(t) → +∞')
axes[1,0].legend(); axes[1,0].grid(True, alpha=0.3)

# Plot 4: Gradient magnitude
grad_mag = np.sqrt(np.exp(2*xt[valid]) + 1/yt[valid]**2)
axes[1,1].semilogy(t[valid], grad_mag, 'purple', linewidth=2)
axes[1,1].set_xlabel('t'); axes[1,1].set_ylabel('|∇eml|')
axes[1,1].set_title('Gradient Magnitude Along Flow')
axes[1,1].grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('/workspace/request-project/EML/EMLv17Research/demos/gradient_flow_v17.png', dpi=150)
plt.close()
print("Demo 8 complete: gradient_flow_v17.png")
