"""
Cobweb Diagram: Visualizing Chaotic Orbits of the Logistic Map

This visualization shows the cobweb (staircase) diagram for the logistic map
f(x) = 4x(1-x), which traces how an orbit bounces between the parabola
y = f(x) and the diagonal y = x. The chaotic nature is visible as the
trajectory fills the entire interval, never settling into a periodic pattern.

Also overlays the tropical tent map T(x) = 2min(x, 1-x) showing the
piecewise-linear approximation with error bound 1/4 (proved in Lean).
"""
import numpy as np
import matplotlib.pyplot as plt

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left panel: Cobweb diagram
ax1 = axes[0]
x = np.linspace(0, 1, 500)
y_logistic = 4 * x * (1 - x)

ax1.plot(x, y_logistic, 'b-', linewidth=2, label=r'$f(x) = 4x(1-x)$')
ax1.plot(x, x, 'k--', linewidth=1, label=r'$y = x$')

# Cobweb from x0 = 0.1
x0 = 0.1
n_steps = 80
cx, cy = [x0], [0]
xk = x0
for _ in range(n_steps):
    fxk = 4 * xk * (1 - xk)
    cx.extend([xk, fxk])
    cy.extend([fxk, fxk])
    xk = fxk

ax1.plot(cx, cy, 'r-', linewidth=0.5, alpha=0.7, label=f'Orbit from $x_0={x0}$')
ax1.scatter([x0], [0], color='red', s=50, zorder=5)

# Mark fixed points
ax1.scatter([0, 0.75], [0, 0.75], color='green', s=80, zorder=5,
            marker='*', label='Fixed points')

ax1.set_xlabel('$x$', fontsize=12)
ax1.set_ylabel('$f(x)$', fontsize=12)
ax1.set_title('Cobweb Diagram: Chaos in the Logistic Map', fontsize=13)
ax1.legend(loc='upper left', fontsize=9)
ax1.set_xlim(-0.02, 1.02)
ax1.set_ylim(-0.02, 1.12)
ax1.grid(True, alpha=0.3)

# Right panel: Logistic vs Tropical approximation
ax2 = axes[1]
y_tropical = 2 * np.minimum(x, 1 - x)
y_error = np.abs(y_logistic - y_tropical)

ax2.plot(x, y_logistic, 'b-', linewidth=2, label=r'$f(x) = 4x(1-x)$')
ax2.plot(x, y_tropical, 'r--', linewidth=2, label=r'$T(x) = 2\min(x, 1-x)$')
ax2.fill_between(x, y_logistic, y_tropical, alpha=0.2, color='purple',
                  label=r'Error $\leq 1/4$')
ax2.axhline(y=0.25, color='gray', linestyle=':', alpha=0.5)

# Mark the max error point
x_max_err = 0.25
ax2.annotate(f'Max error = 1/4\nat x = 1/4',
             xy=(x_max_err, 4*0.25*0.75), xytext=(0.5, 0.4),
             arrowprops=dict(arrowstyle='->', color='purple'),
             fontsize=10, color='purple')

ax2.set_xlabel('$x$', fontsize=12)
ax2.set_ylabel('$y$', fontsize=12)
ax2.set_title('Tropical Approximation (Error ≤ 1/4)', fontsize=13)
ax2.legend(loc='upper right', fontsize=9)
ax2.set_xlim(-0.02, 1.02)
ax2.set_ylim(-0.05, 1.15)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('viz_cobweb.png', dpi=150, bbox_inches='tight')
plt.close()
