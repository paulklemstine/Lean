"""
Visualization: Entropy Surrogate Convergence

Visualizes the convergence of polynomial entropy surrogates to the true
Shannon entanglement entropy as the polynomial degree increases. Shows
how the approximation error decreases geometrically, confirming that
entropy can be recovered from elementary symmetric data alone.

This is the central visual result: the Newton–Girard algebraic pipeline
converts polynomial approximation theory into computable entropy estimates.
"""

import warnings
import numpy as np
import matplotlib.pyplot as plt
import matplotlib

warnings.filterwarnings('ignore')
matplotlib.rcParams['font.size'] = 12


# Self-contained algorithms
def elementary_symmetric_all(mu):
    m = len(mu)
    e = np.zeros(m + 1)
    e[0] = 1.0
    for i in range(m):
        for k in range(min(i + 1, m), 0, -1):
            e[k] += mu[i] * e[k - 1]
    return e


def power_sum_from_esymm(esymm_data, m, N):
    p = np.zeros(N + 1)
    p[0] = float(m)
    for k in range(1, N + 1):
        ek = esymm_data[k] if k < len(esymm_data) else 0.0
        val = (-1) ** (k + 1) * k * ek
        for j in range(1, k):
            ej = esymm_data[j] if j < len(esymm_data) else 0.0
            val -= (-1) ** j * ej * p[k - j]
        p[k] = val
    return p


def shannon_entropy(x):
    if x <= 0 or x >= 1:
        return 0.0
    return -x * np.log(x) - (1 - x) * np.log(1 - x)


def chebyshev_approx(f, a, b, degree):
    n = degree + 1
    nodes = 0.5 * (a + b) + 0.5 * (b - a) * np.cos(
        np.pi * (2 * np.arange(n) + 1) / (2 * n)
    )
    values = np.array([f(x) for x in nodes])
    coeffs = np.polyfit(nodes, values, degree)
    return coeffs[::-1]


def entropy_surrogate(esymm_data, m, degree, delta):
    coeffs = chebyshev_approx(shannon_entropy, delta, 1 - delta, degree)
    p = power_sum_from_esymm(esymm_data, m, degree)
    return sum(coeffs[j] * p[j] for j in range(degree + 1))


# Generate data
np.random.seed(42)
m = 6
delta = 0.1
mu = np.random.uniform(delta, 1 - delta, m)
true_entropy = sum(shannon_entropy(x) for x in mu)
esymm = elementary_symmetric_all(mu)

degrees = list(range(1, 26))
errors = []
surrogates = []
for deg in degrees:
    s = entropy_surrogate(esymm, m, deg, delta)
    surrogates.append(s)
    errors.append(abs(s - true_entropy))

# Create figure
fig, axes = plt.subplots(1, 2, figsize=(14, 5.5))

# Left panel: surrogate vs true entropy
ax1 = axes[0]
ax1.axhline(y=true_entropy, color='red', linewidth=2, label=f'True entropy S(μ) = {true_entropy:.4f}', linestyle='--')
ax1.plot(degrees, surrogates, 'bo-', markersize=5, label='Entropy surrogate $S_N(μ)$')
ax1.fill_between(degrees,
                  [true_entropy - e for e in errors],
                  [true_entropy + e for e in errors],
                  alpha=0.15, color='blue')
ax1.set_xlabel('Polynomial degree N')
ax1.set_ylabel('Entropy estimate')
ax1.set_title('Entropy Surrogate Convergence')
ax1.legend(loc='lower right')
ax1.grid(True, alpha=0.3)

# Right panel: error on log scale
ax2 = axes[1]
for d_val, label, marker in [(0.05, 'δ = 0.05', 's'), (0.1, 'δ = 0.1', 'o'), (0.2, 'δ = 0.2', '^')]:
    mu_d = np.random.uniform(d_val, 1 - d_val, m)
    true_d = sum(shannon_entropy(x) for x in mu_d)
    esymm_d = elementary_symmetric_all(mu_d)
    errs_d = []
    for deg in degrees:
        s = entropy_surrogate(esymm_d, m, deg, d_val)
        errs_d.append(max(abs(s - true_d), 1e-16))
    ax2.semilogy(degrees, errs_d, marker=marker, markersize=5, label=label, linewidth=1.5)

ax2.set_xlabel('Polynomial degree N')
ax2.set_ylabel('Absolute error |S(μ) − S_N(μ)|')
ax2.set_title('Geometric Error Decay')
ax2.legend()
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('viz_convergence.png', dpi=150, bbox_inches='tight')
print("Saved viz_convergence.png")
