"""
Visualization: The Algebraic-Analytic-Information Bridge

Visualizes the three-domain bridge connecting algebraic combinatorics,
approximation theory, and information theory through Newton–Girard identities.

Shows how polynomial approximation of entropy on a gapped interval, combined
with Newton–Girard reduction, yields entropy estimates from symmetric invariants.
"""

import warnings
import numpy as np
import matplotlib.pyplot as plt
import matplotlib

warnings.filterwarnings('ignore')
matplotlib.rcParams['font.size'] = 11


def shannon_entropy(x):
    if isinstance(x, np.ndarray):
        result = np.zeros_like(x)
        mask = (x > 0) & (x < 1)
        result[mask] = -x[mask] * np.log(x[mask]) - (1 - x[mask]) * np.log(1 - x[mask])
        return result
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


fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Panel 1: Entropy function and polynomial approximations
ax = axes[0, 0]
x = np.linspace(0.001, 0.999, 500)
h = shannon_entropy(x)
ax.plot(x, h, 'k-', linewidth=2.5, label='Shannon entropy h(x)')

delta = 0.1
for deg, color in [(3, '#ff7f0e'), (6, '#2ca02c'), (12, '#d62728')]:
    coeffs = chebyshev_approx(shannon_entropy, delta, 1 - delta, deg)
    poly_vals = np.polyval(coeffs[::-1], x)
    mask = (x >= delta) & (x <= 1 - delta)
    ax.plot(x[mask], poly_vals[mask], '--', color=color, linewidth=1.5, label=f'degree {deg}')

ax.axvspan(0, delta, alpha=0.1, color='red', label='Gap region')
ax.axvspan(1 - delta, 1, alpha=0.1, color='red')
ax.set_xlabel('x')
ax.set_ylabel('h(x)')
ax.set_title('Step 1: Polynomial Approximation of Entropy')
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# Panel 2: Approximation error by degree and gap
ax = axes[0, 1]
degrees = list(range(1, 21))
for d_val, color, marker in [(0.05, '#1f77b4', 'o'), (0.1, '#ff7f0e', 's'), (0.2, '#2ca02c', '^')]:
    errs = []
    for deg in degrees:
        coeffs = chebyshev_approx(shannon_entropy, d_val, 1 - d_val, deg)
        x_test = np.linspace(d_val, 1 - d_val, 1000)
        h_test = shannon_entropy(x_test)
        p_test = np.polyval(coeffs[::-1], x_test)
        errs.append(np.max(np.abs(h_test - p_test)))
    ax.semilogy(degrees, errs, f'{marker}-', color=color, label=f'δ = {d_val}', markersize=5)

ax.set_xlabel('Polynomial degree N')
ax.set_ylabel('Max approximation error')
ax.set_title('Step 2: Error Decay with Degree')
ax.legend()
ax.grid(True, alpha=0.3)

# Panel 3: Heatmap of error across (delta, degree)
ax = axes[1, 0]
deltas = np.linspace(0.02, 0.3, 30)
degs = np.arange(2, 21)
error_map = np.zeros((len(deltas), len(degs)))

for i, d in enumerate(deltas):
    for j, deg in enumerate(degs):
        coeffs = chebyshev_approx(shannon_entropy, d, 1 - d, deg)
        x_test = np.linspace(d, 1 - d, 200)
        h_test = shannon_entropy(x_test)
        p_test = np.polyval(coeffs[::-1], x_test)
        error_map[i, j] = np.log10(max(np.max(np.abs(h_test - p_test)), 1e-16))

im = ax.imshow(error_map, aspect='auto', origin='lower',
               extent=[degs[0], degs[-1], deltas[0], deltas[-1]],
               cmap='RdYlGn_r')
plt.colorbar(im, ax=ax, label='log₁₀(max error)')
ax.set_xlabel('Polynomial degree N')
ax.set_ylabel('Spectral gap δ')
ax.set_title('Step 3: Error Landscape (δ, N)')
ax.contour(degs, deltas, error_map, levels=[-12, -8, -4, -2], colors='black', linewidths=0.8)

# Panel 4: Full pipeline — entropy from esymm data
ax = axes[1, 1]
np.random.seed(7)
m_vals = [3, 5, 8]
for m_val in m_vals:
    mu = np.random.uniform(0.1, 0.9, m_val)
    true_ent = sum(shannon_entropy(x) for x in mu)
    esymm = elementary_symmetric_all(mu)

    surr_errors = []
    for deg in degrees:
        coeffs = chebyshev_approx(shannon_entropy, 0.1, 0.9, deg)
        p = power_sum_from_esymm(esymm, m_val, deg)
        surr = sum(coeffs[j] * p[j] for j in range(deg + 1))
        surr_errors.append(max(abs(surr - true_ent), 1e-16))

    ax.semilogy(degrees, surr_errors, 'o-', markersize=4, label=f'm = {m_val}', linewidth=1.5)

ax.set_xlabel('Polynomial degree N')
ax.set_ylabel('|S(μ) − surrogate|')
ax.set_title('Full Pipeline: Entropy from Symmetric Data')
ax.legend()
ax.grid(True, alpha=0.3)

plt.suptitle('The Algebraic–Analytic–Information Bridge',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_spectral_bridge.png', dpi=150, bbox_inches='tight')
print("Saved viz_spectral_bridge.png")
