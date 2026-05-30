"""
The Chebyshev Semiconjugacy: From Angles to Chaos

Visualizes the fundamental mathematical identity:
  f^n(sin²θ) = sin²(2ⁿθ)

This semiconjugacy transforms the nonlinear logistic map into simple
angle doubling, revealing the hidden linear structure within chaos.
The top panel shows the orbit on the circle (angle doubling),
the bottom panel shows the corresponding chaotic orbit on [0,1].
"""
import numpy as np
import matplotlib.pyplot as plt

fig = plt.figure(figsize=(14, 8))

# Create grid: left side for circle + orbit, right for bifurcation-like density
gs = fig.add_gridspec(2, 2, hspace=0.35, wspace=0.3)

def logistic(x):
    return 4 * x * (1 - x)

# Panel 1: Angle doubling on the circle
ax1 = fig.add_subplot(gs[0, 0], polar=True)
theta0 = 0.7  # starting angle
n_points = 20
thetas = [theta0]
for _ in range(n_points - 1):
    thetas.append(2 * thetas[-1])

# Plot the circle
circle_theta = np.linspace(0, 2*np.pi, 200)
ax1.plot(circle_theta, np.ones_like(circle_theta), 'k-', linewidth=0.5)

# Plot angle doubling steps
for i in range(len(thetas) - 1):
    ax1.annotate('', xy=(thetas[i+1] % (2*np.pi), 1),
                 xytext=(thetas[i] % (2*np.pi), 1),
                 arrowprops=dict(arrowstyle='->', color=plt.cm.viridis(i/n_points),
                                linewidth=1.5))

# Mark points
for i, t in enumerate(thetas):
    ax1.plot(t % (2*np.pi), 1, 'o', color=plt.cm.viridis(i/n_points),
             markersize=6)

ax1.set_title(r'Angle Doubling: $\theta \mapsto 2\theta$', fontsize=12, pad=15)
ax1.set_rticks([])

# Panel 2: The semiconjugacy map sin²
ax2 = fig.add_subplot(gs[0, 1])
t = np.linspace(0, 2*np.pi, 500)
ax2.plot(t, np.sin(t)**2, 'b-', linewidth=2)
ax2.fill_between(t, 0, np.sin(t)**2, alpha=0.1, color='blue')
ax2.set_xlabel(r'$\theta$', fontsize=12)
ax2.set_ylabel(r'$\sin^2(\theta)$', fontsize=12)
ax2.set_title(r'Semiconjugacy: $\sin^2$ maps angles to $[0,1]$', fontsize=12)
ax2.axhline(y=0.75, color='green', linestyle='--', alpha=0.5, label='Fixed point 3/4')
ax2.axhline(y=0.5, color='red', linestyle='--', alpha=0.5, label='Critical point 1/2')
ax2.legend(fontsize=9)
ax2.grid(True, alpha=0.3)

# Panel 3: Verification of semiconjugacy
ax3 = fig.add_subplot(gs[1, 0])
theta0 = 0.7
n_verify = 50

orbit_logistic = [np.sin(theta0)**2]
orbit_conjugate = [np.sin(theta0)**2]

x_log = np.sin(theta0)**2
theta = theta0
for i in range(n_verify):
    x_log = logistic(x_log)
    theta = 2 * theta
    orbit_logistic.append(x_log)
    orbit_conjugate.append(np.sin(theta)**2)

errors = [abs(a - b) for a, b in zip(orbit_logistic, orbit_conjugate)]

ax3.semilogy(range(len(errors)), errors, 'r-', linewidth=1.5)
ax3.set_xlabel('Iteration $n$', fontsize=11)
ax3.set_ylabel(r'$|f^n(\sin^2\theta) - \sin^2(2^n\theta)|$', fontsize=11)
ax3.set_title('Numerical Verification of Semiconjugacy', fontsize=12)
ax3.annotate('Floating-point error accumulation\n(mathematically exact by theorem)',
             xy=(30, errors[30] if len(errors) > 30 else 1e-15),
             xytext=(20, 1e-5),
             arrowprops=dict(arrowstyle='->', color='gray'),
             fontsize=9, color='gray')
ax3.grid(True, alpha=0.3)

# Panel 4: Invariant density (arcsine distribution)
ax4 = fig.add_subplot(gs[1, 1])

# Generate long orbit for histogram
x = 0.1234
orbit = []
for _ in range(100):  # warmup
    x = logistic(x)
for _ in range(100000):
    x = logistic(x)
    orbit.append(x)

x_dens = np.linspace(0.001, 0.999, 500)
arcsine_density = 1 / (np.pi * np.sqrt(x_dens * (1 - x_dens)))

ax4.hist(orbit, bins=100, density=True, alpha=0.5, color='blue',
         label='Orbit histogram')
ax4.plot(x_dens, arcsine_density, 'r-', linewidth=2,
         label=r'Arcsine: $\frac{1}{\pi\sqrt{x(1-x)}}$')
ax4.set_xlabel('$x$', fontsize=11)
ax4.set_ylabel('Density', fontsize=11)
ax4.set_title('Invariant Measure (Arcsine Distribution)', fontsize=12)
ax4.legend(fontsize=10)
ax4.set_ylim(0, 6)
ax4.grid(True, alpha=0.3)

plt.suptitle('The Chebyshev Semiconjugacy: Hidden Structure of Chaos',
             fontsize=14, fontweight='bold')
plt.savefig('viz_semiconjugacy.png', dpi=150, bbox_inches='tight')
plt.close()
