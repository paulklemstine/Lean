"""
Sensitivity to Initial Conditions: The Butterfly Effect in Cryptography

Visualizes how two orbits starting from nearly identical initial conditions
diverge exponentially under the logistic map. The Lyapunov exponent log(2)
governs this divergence rate — each iteration doubles the uncertainty,
producing exactly 1 bit of entropy.

This exponential sensitivity is the foundation of cryptographic security:
recovering the seed from the keystream requires solving a degree-2^n polynomial.
"""
import numpy as np
import matplotlib.pyplot as plt

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

def logistic(x):
    return 4 * x * (1 - x)

# Panel 1: Two diverging orbits
ax = axes[0, 0]
n = 50
x1 = np.zeros(n)
x2 = np.zeros(n)
x1[0] = 0.3
x2[0] = 0.3 + 1e-10  # differ by 10^{-10}
for i in range(1, n):
    x1[i] = logistic(x1[i-1])
    x2[i] = logistic(x2[i-1])

ax.plot(range(n), x1, 'b-', linewidth=1.5, label=r'$x_0 = 0.3$')
ax.plot(range(n), x2, 'r--', linewidth=1.5, label=r'$x_0 = 0.3 + 10^{-10}$')
ax.set_xlabel('Iteration $n$', fontsize=11)
ax.set_ylabel('$f^n(x_0)$', fontsize=11)
ax.set_title('Diverging Orbits', fontsize=12)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# Panel 2: Logarithmic divergence rate
ax = axes[0, 1]
diffs = np.abs(x1 - x2)
diffs_nonzero = np.maximum(diffs, 1e-20)
log_diffs = np.log10(diffs_nonzero)

ax.plot(range(n), log_diffs, 'k-', linewidth=1.5)
# Overlay theoretical rate log(2)/log(10) * n
theory = np.log10(1e-10) + np.arange(n) * np.log10(2)
ax.plot(range(min(n, 35)), theory[:min(n, 35)], 'r--', linewidth=1,
        label=r'Slope = $\log_{10}(2) \approx 0.301$')
ax.set_xlabel('Iteration $n$', fontsize=11)
ax.set_ylabel(r'$\log_{10}|x_1^{(n)} - x_2^{(n)}|$', fontsize=11)
ax.set_title('Exponential Divergence Rate', fontsize=12)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# Panel 3: Orbit derivative product |∏ f'(f^k(x))| vs 2^n
ax = axes[1, 0]
n_max = 30
x0_vals = [0.1, 0.3, 0.7, 0.9, 0.75]
colors = ['blue', 'green', 'red', 'purple', 'orange']

for x0, color in zip(x0_vals, colors):
    products = np.zeros(n_max)
    x = x0
    log_prod = 0
    for k in range(n_max):
        deriv = abs(4 - 8 * x)
        if deriv > 0:
            log_prod += np.log2(deriv)
        products[k] = log_prod
        x = logistic(x)
    ax.plot(range(n_max), products, color=color, linewidth=1,
            label=f'$x_0={x0}$', alpha=0.8)

ax.plot(range(n_max), np.arange(n_max), 'k--', linewidth=2,
        label=r'$n$ (slope 1 = $\log_2 2$)')
ax.set_xlabel('Iteration $n$', fontsize=11)
ax.set_ylabel(r'$\log_2 |\prod f^{\prime}(f^k(x_0))|$', fontsize=11)
ax.set_title('Orbit Derivative Growth vs $2^n$', fontsize=12)
ax.legend(fontsize=8, loc='upper left')
ax.grid(True, alpha=0.3)

# Panel 4: Polynomial degree growth (cryptographic hardness)
ax = axes[1, 1]
ns = np.arange(1, 21)
degrees = 2**ns
n_cubed = ns**3

ax.semilogy(ns, degrees, 'b-o', linewidth=2, markersize=5,
            label=r'$\deg(f^n) = 2^n$')
ax.semilogy(ns, n_cubed, 'r--s', linewidth=1.5, markersize=4,
            label=r'$n^3$')
ax.fill_between(ns, n_cubed, degrees, alpha=0.15, color='blue',
                where=degrees > n_cubed)
ax.axvline(x=10, color='gray', linestyle=':', alpha=0.5)
ax.annotate('$n=10$: Superpolynomial\nhardness begins',
            xy=(10, 10**3), xytext=(12, 2000),
            arrowprops=dict(arrowstyle='->', color='gray'),
            fontsize=9, color='gray')

ax.set_xlabel('Number of iterations $n$', fontsize=11)
ax.set_ylabel('Complexity', fontsize=11)
ax.set_title('Cryptographic Hardness: $2^n$ vs $n^3$', fontsize=12)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

plt.suptitle('Sensitivity & Cryptographic Hardness of the Logistic Map',
             fontsize=14, fontweight='bold', y=1.01)
plt.tight_layout()
plt.savefig('viz_sensitivity.png', dpi=150, bbox_inches='tight')
plt.close()
