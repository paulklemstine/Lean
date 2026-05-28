"""
Visualization 2: Geometric Rigidity and Newton Defects
========================================================

This script visualizes the geometric rigidity theorem:
when all Newton defects vanish, the esymm sequence must be geometric.
We show how increasing Newton defects correspond to deviations from
geometric structure.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def esymm_from_spectrum(spectrum):
    n = len(spectrum)
    e = np.zeros(n + 1)
    e[0] = 1.0
    for i in range(n):
        for k in range(min(i + 1, n), 0, -1):
            e[k] += spectrum[i] * e[k - 1]
    return e


def newton_defects(spectrum):
    e = esymm_from_spectrum(spectrum)
    n = len(spectrum)
    return [e[k]**2 - e[k-1]*e[k+1] for k in range(1, n)]


def geometric_fit(e_vals):
    """Find best geometric fit a*b^k to a positive sequence."""
    n = len(e_vals) - 1
    valid = [(k, e_vals[k]) for k in range(n+1) if e_vals[k] > 0]
    if len(valid) < 2:
        return None, None
    log_e = [np.log(v) for _, v in valid]
    ks = [k for k, _ in valid]
    # Linear regression on log scale
    coeffs = np.polyfit(ks, log_e, 1)
    b = np.exp(coeffs[0])
    a = np.exp(coeffs[1])
    return a, b


fig, axes = plt.subplots(2, 3, figsize=(16, 10))

# Panel 1: Constant spectrum -> geometric esymm
n = 8
spectrum = np.ones(n) * 2.0
e = esymm_from_spectrum(spectrum)
a, b = geometric_fit(e)
axes[0, 0].semilogy(range(n+1), e, 'bo-', markersize=6, label='e_k (constant spectrum)')
if a and b:
    fit = [a * b**k for k in range(n+1)]
    axes[0, 0].semilogy(range(n+1), fit, 'r--', alpha=0.7, label=f'Geometric fit: {a:.2f}·{b:.2f}^k')
axes[0, 0].set_xlabel('k')
axes[0, 0].set_ylabel('e_k (log scale)')
axes[0, 0].set_title('Constant Spectrum [2,2,...,2]')
axes[0, 0].legend(fontsize=7)
axes[0, 0].grid(True, alpha=0.2)

# Panel 2: Nearly constant spectrum
spectrum2 = np.ones(n) * 2.0 + np.random.RandomState(42).randn(n) * 0.1
e2 = esymm_from_spectrum(spectrum2)
a2, b2 = geometric_fit(e2)
axes[0, 1].semilogy(range(n+1), e2, 'bo-', markersize=6, label='e_k (perturbed)')
if a2 and b2:
    fit2 = [a2 * b2**k for k in range(n+1)]
    axes[0, 1].semilogy(range(n+1), fit2, 'r--', alpha=0.7, label=f'Geometric fit')
axes[0, 1].set_xlabel('k')
axes[0, 1].set_ylabel('e_k (log scale)')
axes[0, 1].set_title('Near-Constant Spectrum (σ=0.1)')
axes[0, 1].legend(fontsize=7)
axes[0, 1].grid(True, alpha=0.2)

# Panel 3: Widely varying spectrum
spectrum3 = np.array([0.1, 0.5, 1.0, 2.0, 3.0, 5.0, 8.0, 10.0])
e3 = esymm_from_spectrum(spectrum3)
a3, b3 = geometric_fit(e3)
axes[0, 2].semilogy(range(n+1), e3, 'bo-', markersize=6, label='e_k (varying)')
if a3 and b3:
    fit3 = [a3 * b3**k for k in range(n+1)]
    axes[0, 2].semilogy(range(n+1), fit3, 'r--', alpha=0.7, label='Geometric fit')
axes[0, 2].set_xlabel('k')
axes[0, 2].set_ylabel('e_k (log scale)')
axes[0, 2].set_title('Widely Varying Spectrum')
axes[0, 2].legend(fontsize=7)
axes[0, 2].grid(True, alpha=0.2)

# Panel 4: Newton defects comparison
defects1 = newton_defects(np.ones(n) * 2.0)
defects2 = newton_defects(spectrum2)
defects3 = newton_defects(spectrum3)

x = np.arange(1, n)
width = 0.25
axes[1, 0].bar(x - width, [max(d, 1e-20) for d in defects1], width, label='Constant', color='#3498db', alpha=0.8)
axes[1, 0].bar(x, [max(d, 1e-20) for d in defects2], width, label='Perturbed', color='#e74c3c', alpha=0.8)
axes[1, 0].bar(x + width, [max(d, 1e-20) for d in defects3], width, label='Varying', color='#2ecc71', alpha=0.8)
axes[1, 0].set_yscale('log')
axes[1, 0].set_xlabel('Index k')
axes[1, 0].set_ylabel('Newton defect Δ_k')
axes[1, 0].set_title('Newton Defects (always ≥ 0)')
axes[1, 0].legend(fontsize=7)
axes[1, 0].grid(True, alpha=0.2)

# Panel 5: Deviation from geometric as function of spectral spread
spreads = np.linspace(0, 3, 30)
deviations = []
max_defects = []
for spread in spreads:
    np.random.seed(42)
    spec = np.exp(np.random.randn(n) * spread)
    e = esymm_from_spectrum(spec)
    a, b = geometric_fit(e)
    if a and b and a > 0 and b > 0:
        fit = np.array([a * b**k for k in range(n+1)])
        dev = np.max(np.abs(np.log(e / fit + 1e-30)))
        deviations.append(dev)
    else:
        deviations.append(0)
    defs = newton_defects(spec)
    max_defects.append(max(defs))

axes[1, 1].plot(spreads, deviations, 'b-', linewidth=2, label='Max log deviation from geometric')
axes[1, 1].set_xlabel('Spectral spread (std of log-spectrum)')
axes[1, 1].set_ylabel('Deviation from geometric')
axes[1, 1].set_title('Rigidity: Spread → Deviation')
axes[1, 1].legend(fontsize=7)
axes[1, 1].grid(True, alpha=0.2)

# Panel 6: Newton energy vs spectral spread
axes[1, 2].plot(spreads, [np.log(max(d, 1e-30)) for d in max_defects], 'r-', linewidth=2)
axes[1, 2].set_xlabel('Spectral spread')
axes[1, 2].set_ylabel('log(max Newton defect)')
axes[1, 2].set_title('Newton Defect Growth')
axes[1, 2].grid(True, alpha=0.2)

fig.suptitle('Geometric Rigidity: Newton Defects Measure Deviation from Geometric Structure',
             fontsize=13, fontweight='bold', y=0.98)
plt.tight_layout(rect=[0, 0, 1, 0.96])
plt.savefig('viz_rigidity.png', dpi=150, bbox_inches='tight')
print("Saved: viz_rigidity.png")
