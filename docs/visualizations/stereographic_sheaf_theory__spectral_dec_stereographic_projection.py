"""
Visualization 1: Stereographic Projection and Conformal Factor

Shows how the stereographic projection maps the real line to the unit circle,
and how the conformal factor varies. This illustrates the geometric foundation
of stereographic sheaf theory.
"""
import numpy as np
import matplotlib.pyplot as plt

fig, axes = plt.subplots(1, 3, figsize=(18, 6))

# Panel 1: Stereographic projection R -> S^1
t = np.linspace(-5, 5, 500)
x = 2*t / (1 + t**2)
y = (1 - t**2) / (1 + t**2)

ax1 = axes[0]
theta = np.linspace(0, 2*np.pi, 200)
ax1.plot(np.cos(theta), np.sin(theta), 'k-', linewidth=0.5, alpha=0.3)

# Color by parameter t
colors = plt.cm.viridis(np.linspace(0, 1, len(t)))
for i in range(len(t)-1):
    ax1.plot([x[i], x[i+1]], [y[i], y[i+1]], color=colors[i], linewidth=2)

# Mark special points
special_t = [0, 1, -1]
special_labels = ['t=0\n(0,1)', 't=1\n(1,0)', 't=-1\n(-1,0)']
for st, label in zip(special_t, special_labels):
    sx = 2*st/(1+st**2)
    sy = (1-st**2)/(1+st**2)
    ax1.plot(sx, sy, 'ro', markersize=8, zorder=5)
    ax1.annotate(label, (sx, sy), textcoords="offset points",
                xytext=(10, 10), fontsize=9)

ax1.set_xlim(-1.4, 1.4)
ax1.set_ylim(-1.4, 1.4)
ax1.set_aspect('equal')
ax1.set_title('Stereographic Projection\n$\\mathbb{R} \\to S^1$', fontsize=14)
ax1.set_xlabel('x')
ax1.set_ylabel('y')
ax1.grid(True, alpha=0.2)

# Mark north pole (excluded)
ax1.plot(0, -1, 'kx', markersize=10, markeredgewidth=2, zorder=5)
ax1.annotate('North pole\n(excluded)', (0, -1), textcoords="offset points",
            xytext=(15, -15), fontsize=9, color='red')

# Panel 2: Conformal factor
ax2 = axes[1]
lam = 2 / (1 + t**2)
ax2.fill_between(t, 0, lam, alpha=0.3, color='steelblue')
ax2.plot(t, lam, 'b-', linewidth=2)
ax2.axhline(y=2, color='r', linestyle='--', alpha=0.5, label='max = 2')
ax2.plot(0, 2, 'ro', markersize=8, zorder=5)
ax2.annotate('Maximum at t=0', (0, 2), textcoords="offset points",
            xytext=(15, 5), fontsize=10)
ax2.set_xlabel('t', fontsize=12)
ax2.set_ylabel('$\\lambda(t)$', fontsize=12)
ax2.set_title('Conformal Factor\n$\\lambda(t) = 2/(1+t^2)$', fontsize=14)
ax2.set_ylim(0, 2.5)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.2)

# Panel 3: Transition map (inversion)
ax3 = axes[2]
t_pos = np.linspace(0.2, 5, 200)
t_neg = np.linspace(-5, -0.2, 200)

ax3.plot(t_pos, 1/t_pos, 'b-', linewidth=2, label='$\\phi(t) = 1/t$')
ax3.plot(t_neg, 1/t_neg, 'b-', linewidth=2)
ax3.plot(t_pos, t_pos, 'k--', linewidth=0.5, alpha=0.3, label='identity')

# Show involutivity: phi(phi(t)) = t
for t_val in [0.5, 1.5, 3.0]:
    phi_t = 1/t_val
    phi_phi_t = 1/phi_t
    ax3.annotate('', xy=(phi_phi_t, phi_t), xytext=(t_val, phi_t),
                arrowprops=dict(arrowstyle='->', color='red', lw=1.5))
    ax3.plot([t_val, t_val], [0, phi_t], 'r:', alpha=0.3)
    ax3.plot([0, t_val], [phi_t, phi_t], 'r:', alpha=0.3)

ax3.set_xlim(-5, 5)
ax3.set_ylim(-5, 5)
ax3.set_xlabel('t', fontsize=12)
ax3.set_ylabel('$\\phi(t)$', fontsize=12)
ax3.set_title('Transition Map (Involution)\n$\\phi(t) = 1/t$, $\\phi \\circ \\phi = \\mathrm{id}$', fontsize=14)
ax3.legend(fontsize=10)
ax3.grid(True, alpha=0.2)

plt.tight_layout()
plt.savefig('stereographic_projection.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: stereographic_projection.png")
