"""
Visualization: Condition Number and Robustness Landscape
==========================================================
Visualizes how the Lorentzian condition number κ governs
the robustness landscape of polynomial recognition.
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


np.random.seed(42)

fig, axes = plt.subplots(1, 3, figsize=(18, 5.5))

# ---- Panel 1: Condition number vs safe radius ----
ax = axes[0]
gaps = np.linspace(0.1, 5.0, 50)
max_norm = 5.0
kappas = max_norm / gaps
safe_radii = gaps  # Safe radius = gap

ax.plot(kappas, safe_radii, 'b-', linewidth=2.5, label='Safe radius = 1/κ · ‖A‖')
ax.fill_between(kappas, 0, safe_radii, alpha=0.15, color='green', label='Safe zone')
ax.set_xlabel('Condition number κ', fontsize=12)
ax.set_ylabel('Safe perturbation radius', fontsize=12)
ax.set_title('Condition Number vs Safe Radius', fontsize=13)
ax.legend(fontsize=11)
ax.grid(True, alpha=0.3)
ax.set_xlim(1, 50)
ax.set_ylim(0, 5.5)

# ---- Panel 2: Robustness landscape for different n ----
ax = axes[1]
sigma = 1.0
n_values = [3, 5, 8, 12]
gap_range = np.linspace(0.3, 4.0, 20)
num_trials = 500

for n in n_values:
    rates = []
    for gap in gap_range:
        A = make_lorentzian_matrix(n, gap)
        failures = 0
        for _ in range(num_trials):
            E = np.random.randn(n, n) * sigma
            E = (E + E.T) / 2
            if not has_lorentzian_signature(A + E):
                failures += 1
        rates.append(failures / num_trials)
    ax.plot(gap_range, rates, 'o-', label=f'n = {n}', markersize=4)

ax.set_xlabel('Spectral gap ε', fontsize=12)
ax.set_ylabel('P(failure)', fontsize=12)
ax.set_title(f'Robustness vs Gap (σ = {sigma})', fontsize=13)
ax.legend(fontsize=11)
ax.grid(True, alpha=0.3)

# ---- Panel 3: Theoretical vs empirical failure bound ----
ax = axes[2]
n = 5
gap = 1.5
sigma_values = np.linspace(0.2, 3.0, 20)
num_trials = 800

empirical_rates = []
A = make_lorentzian_matrix(n, gap)
for sigma in sigma_values:
    failures = 0
    for _ in range(num_trials):
        E = np.random.randn(n, n) * sigma
        E = (E + E.T) / 2
        if not has_lorentzian_signature(A + E):
            failures += 1
    empirical_rates.append(max(failures / num_trials, 1e-4))

empirical_rates = np.array(empirical_rates)
mask = empirical_rates > 1e-3

# Theoretical bound: C * exp(-c * ε² / (n * σ²))
# Fit c from the data
if np.any(mask):
    x_data = gap**2 / (n * sigma_values[mask]**2)
    y_data = np.log(empirical_rates[mask])
    
    # Simple linear fit: log(P) ≈ -c * ε²/(nσ²) + log(C)
    if len(x_data) > 2:
        coeffs = np.polyfit(x_data, y_data, 1)
        c_fit = -coeffs[0]
        C_fit = np.exp(coeffs[1])
        
        sigma_theory = np.linspace(0.2, 3.0, 100)
        theory_bound = C_fit * np.exp(-c_fit * gap**2 / (n * sigma_theory**2))
        theory_bound = np.clip(theory_bound, 0, 1)

ax.semilogy(sigma_values, empirical_rates, 'bo-', label='Empirical', markersize=5)
if np.any(mask) and len(x_data) > 2:
    ax.semilogy(sigma_theory, theory_bound, 'r--', linewidth=2,
                label=f'Fit: C·exp(-{c_fit:.2f}·ε²/(nσ²))')
ax.set_xlabel('σ (noise scale)', fontsize=12)
ax.set_ylabel('P(failure)', fontsize=12)
ax.set_title(f'Empirical vs Theoretical Bound (n={n}, ε={gap})', fontsize=13)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)
ax.set_ylim(1e-4, 1.5)

plt.tight_layout()
plt.savefig('viz_condition_number.png', dpi=150, bbox_inches='tight')
print("Saved viz_condition_number.png")
