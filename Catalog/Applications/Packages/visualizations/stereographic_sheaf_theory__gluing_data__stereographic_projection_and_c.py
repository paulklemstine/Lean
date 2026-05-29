"""
Visualization 1: Stereographic Projection and Conformal Factor

Visualizes the stereographic projection from R to S^1, showing how the
real line wraps onto the circle. Also plots the conformal factor 2/(1+t^2),
which measures the local stretching of the projection.

The key insight: the conformal factor achieves its maximum at t=0 (south pole)
and decays to zero as t -> ±∞ (approaching the north pole). This is why the
stereographic atlas needs two charts — no single chart can cover the pole.
"""
import numpy as np
import matplotlib.pyplot as plt

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Panel 1: Stereographic Projection
ax = axes[0]
t = np.linspace(-5, 5, 500)
d = 1 + t**2
x = 2*t / d
y = (1 - t**2) / d

# Draw the unit circle
theta = np.linspace(0, 2*np.pi, 200)
ax.plot(np.cos(theta), np.sin(theta), 'k-', linewidth=1.5, alpha=0.3)

# Color the projection by parameter value
colors = plt.cm.viridis((t - t.min()) / (t.max() - t.min()))
for i in range(len(t)-1):
    ax.plot([x[i], x[i+1]], [y[i], y[i+1]], '-', color=colors[i], linewidth=2)

# Mark special points
special_t = [0, 1, -1, 2, -2]
for st in special_t:
    sx = 2*st / (1 + st**2)
    sy = (1 - st**2) / (1 + st**2)
    ax.plot(sx, sy, 'ro', markersize=6)
    ax.annotate(f't={st}', (sx, sy), textcoords="offset points",
                xytext=(10, 5), fontsize=8)

# North pole (missing point)
ax.plot(0, -1, 'k^', markersize=10, label='North pole (t→±∞)')
ax.set_xlim(-1.5, 1.5)
ax.set_ylim(-1.5, 1.5)
ax.set_aspect('equal')
ax.set_title('Stereographic Projection: ℝ → S¹', fontsize=12)
ax.set_xlabel('x')
ax.set_ylabel('y')
ax.legend(fontsize=8)
ax.grid(True, alpha=0.3)

# Panel 2: Conformal Factor
ax = axes[1]
t = np.linspace(-5, 5, 500)
cf = 2 / (1 + t**2)

ax.fill_between(t, 0, cf, alpha=0.3, color='steelblue')
ax.plot(t, cf, 'b-', linewidth=2, label='2/(1+t²)')
ax.axhline(y=2, color='r', linestyle='--', alpha=0.5, label='Maximum = 2')
ax.plot(0, 2, 'ro', markersize=8)
ax.annotate('Maximum at t=0', (0, 2), textcoords="offset points",
            xytext=(15, -15), fontsize=10, arrowprops=dict(arrowstyle='->', color='red'))

ax.set_xlabel('t', fontsize=12)
ax.set_ylabel('Conformal Factor', fontsize=12)
ax.set_title('Conformal Factor: 2/(1+t²) ≤ 2', fontsize=12)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Panel 3: Transition map on the overlap
ax = axes[2]
t_pos = np.linspace(0.1, 5, 200)
t_neg = np.linspace(-5, -0.1, 200)

ax.plot(t_pos, 1/t_pos, 'b-', linewidth=2, label='t ↦ 1/t (t > 0)')
ax.plot(t_neg, 1/t_neg, 'r-', linewidth=2, label='t ↦ 1/t (t < 0)')
ax.plot(t_pos, t_pos, 'k--', alpha=0.3, label='y = t (identity)')

# Mark the involution property
for t_val in [0.5, 2.0]:
    ax.annotate('', xy=(t_val, 1/t_val), xytext=(1/t_val, t_val),
                arrowprops=dict(arrowstyle='<->', color='green', lw=1.5))

ax.set_xlim(-5, 5)
ax.set_ylim(-5, 5)
ax.set_xlabel('t', fontsize=12)
ax.set_ylabel('1/t', fontsize=12)
ax.set_title('Transition Map: Involution t ↦ 1/t', fontsize=12)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('viz_stereo_projection.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved viz_stereo_projection.png")
