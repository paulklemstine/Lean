"""
Visualization: Smoothed Analysis of Lorentzian Recognition
============================================================
Visualizes the core result: how the spectral gap controls
failure probability under random perturbation.

Shows the conjectured scaling P(fail) ~ exp(-c ε²/(nσ²))
versus alternative scaling hypotheses.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def make_lorentzian_matrix(n, gap):
    eigenvalues = np.array([1.0] + [-gap] * (n - 1))
    Q, _ = np.linalg.qr(np.random.randn(n, n))
    A = Q @ np.diag(eigenvalues) @ Q.T
    return (A + A.T) / 2


def has_lorentzian_signature(A):
    eigenvalues = np.linalg.eigvalsh(A)
    return np.sum(eigenvalues > 1e-10) <= 1


def run_experiment(n, gap, sigma_values, num_trials=800):
    A = make_lorentzian_matrix(n, gap)
    failure_rates = np.zeros(len(sigma_values))
    for i, sigma in enumerate(sigma_values):
        failures = 0
        for _ in range(num_trials):
            E = np.random.randn(n, n) * sigma
            E = (E + E.T) / 2
            if not has_lorentzian_signature(A + E):
                failures += 1
        failure_rates[i] = failures / num_trials
    return failure_rates


np.random.seed(42)

n = 5
gaps = [0.5, 1.0, 2.0]
sigma_values = np.linspace(0.1, 3.0, 25)

fig, axes = plt.subplots(2, 2, figsize=(14, 11))

# Panel 1: Raw failure rates
ax = axes[0, 0]
for gap in gaps:
    rates = run_experiment(n, gap, sigma_values)
    ax.plot(sigma_values, rates, 'o-', label=f'ε = {gap}', markersize=4)
ax.set_xlabel('σ (noise scale)', fontsize=12)
ax.set_ylabel('P(failure)', fontsize=12)
ax.set_title('Lorentzian Misclassification Rate vs Noise', fontsize=13)
ax.legend(fontsize=11)
ax.grid(True, alpha=0.3)

# Panel 2: log(P) vs ε²/σ²
ax = axes[0, 1]
for gap in gaps:
    rates = run_experiment(n, gap, sigma_values)
    mask = rates > 0
    if np.any(mask):
        x = gap**2 / sigma_values[mask]**2
        y = np.log(rates[mask])
        ax.plot(x, y, 'o-', label=f'ε = {gap}', markersize=4)
ax.set_xlabel('ε² / σ²', fontsize=12)
ax.set_ylabel('log P(failure)', fontsize=12)
ax.set_title('Conjectured Scaling: log P vs ε²/σ²', fontsize=13)
ax.legend(fontsize=11)
ax.grid(True, alpha=0.3)

# Panel 3: log(P) vs ε/σ (alternative)
ax = axes[1, 0]
for gap in gaps:
    rates = run_experiment(n, gap, sigma_values)
    mask = rates > 0
    if np.any(mask):
        x = gap / sigma_values[mask]
        y = np.log(rates[mask])
        ax.plot(x, y, 'o-', label=f'ε = {gap}', markersize=4)
ax.set_xlabel('ε / σ', fontsize=12)
ax.set_ylabel('log P(failure)', fontsize=12)
ax.set_title('Alternative Scaling: log P vs ε/σ', fontsize=13)
ax.legend(fontsize=11)
ax.grid(True, alpha=0.3)

# Panel 4: Phase diagram
ax = axes[1, 1]
eps_grid = np.linspace(0.2, 3.0, 20)
sig_grid = np.linspace(0.2, 3.0, 20)
E_mesh, S_mesh = np.meshgrid(eps_grid, sig_grid)
rate_grid = np.zeros_like(E_mesh)
num_trials = 300

for i, eps in enumerate(eps_grid):
    for j, sig in enumerate(sig_grid):
        A = make_lorentzian_matrix(n, eps)
        failures = 0
        for _ in range(num_trials):
            E = np.random.randn(n, n) * sig
            E = (E + E.T) / 2
            if not has_lorentzian_signature(A + E):
                failures += 1
        rate_grid[j, i] = failures / num_trials

im = ax.pcolormesh(E_mesh, S_mesh, rate_grid, cmap='RdYlGn_r', shading='auto')
ax.set_xlabel('ε (spectral gap)', fontsize=12)
ax.set_ylabel('σ (noise scale)', fontsize=12)
ax.set_title('Phase Diagram: Misclassification Rate', fontsize=13)
plt.colorbar(im, ax=ax, label='P(failure)')
# Add contour at 50% failure
ax.contour(E_mesh, S_mesh, rate_grid, levels=[0.5], colors='white',
           linewidths=2, linestyles='dashed')

plt.tight_layout()
plt.savefig('viz_smoothed_analysis.png', dpi=150, bbox_inches='tight')
print("Saved viz_smoothed_analysis.png")
