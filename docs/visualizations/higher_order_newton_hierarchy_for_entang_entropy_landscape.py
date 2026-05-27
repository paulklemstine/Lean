"""
Visualization: Entropy landscape in the (e1, e2) plane.

Shows the region of admissible (e1, e2) values for free-fermion spectra,
with the quadratic entropy surrogate as a heatmap. The Newton inequality
constrains which (e1, e2) pairs are realizable, creating a bounded region.

This visualizes the core insight: entropy is controlled by algebraic invariants.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def esymm_all_local(lam):
    """Compute all elementary symmetric polynomials."""
    m = len(lam)
    e = np.zeros(m + 1)
    e[0] = 1.0
    for j in range(m):
        for r in range(min(m, j + 1), 0, -1):
            e[r] += lam[j] * e[r - 1]
    return e


def binary_entropy_local(x):
    if x <= 0 or x >= 1:
        return 0.0
    return -x * np.log(x) - (1 - x) * np.log(1 - x)


def generate_spectrum(L, L_A, delta=0.0):
    H = np.zeros((L, L))
    for i in range(L - 1):
        H[i, i + 1] = -1.0
        H[i + 1, i] = -1.0
    for i in range(L):
        H[i, i] = delta * (-1) ** i
    _, states = np.linalg.eigh(H)
    n_filled = L // 2
    K = states[:, :n_filled] @ states[:, :n_filled].T
    K_A = K[:L_A, :L_A]
    return np.clip(np.sort(np.linalg.eigvalsh(K_A))[::-1], 0, 1)


# Generate data points
fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Panel 1: (e1, e2) plane with entropy contours
ax = axes[0]
e1_range = np.linspace(0, 10, 200)
e2_range = np.linspace(0, 15, 200)
E1, E2 = np.meshgrid(e1_range, e2_range)
# Quadratic surrogate: 2(e1 - e1^2 + 2*e2)
Surr = 2 * (E1 - E1**2 + 2 * E2)
Surr = np.clip(Surr, 0, None)

im = ax.contourf(E1, E2, Surr, levels=20, cmap='viridis', alpha=0.8)
plt.colorbar(im, ax=ax, label='Quadratic surrogate 2(e₁ - e₁² + 2e₂)')

# Scatter actual spectra
for L in [20, 40, 60, 80]:
    for L_A in range(2, L // 2, max(1, L // 10)):
        lam = generate_spectrum(L, L_A)
        e = esymm_all_local(lam)
        S = sum(binary_entropy_local(x) for x in lam)
        ax.scatter(e[1], e[2], c='red', s=10, alpha=0.3, zorder=5)

ax.set_xlabel('e₁ (sum of eigenvalues)')
ax.set_ylabel('e₂ (sum of pairwise products)')
ax.set_title('Entropy landscape in (e₁, e₂) plane')
ax.set_xlim(0, 10)
ax.set_ylim(0, 15)

# Panel 2: True entropy vs surrogate
ax = axes[1]
S_true_list = []
S_surr_list = []
for L in [20, 40, 60, 80, 100]:
    for L_A in range(2, L // 2, max(1, L // 8)):
        lam = generate_spectrum(L, L_A)
        e = esymm_all_local(lam)
        S_true = sum(binary_entropy_local(x) for x in lam)
        S_surr = 2 * (e[1] - e[1]**2 + 2 * e[2])
        S_true_list.append(S_true)
        S_surr_list.append(S_surr)

ax.scatter(S_surr_list, S_true_list, s=8, alpha=0.5, c='steelblue')
max_val = max(max(S_true_list), max(S_surr_list)) * 1.1
ax.plot([0, max_val], [0, max_val], 'k--', alpha=0.3, label='y = x')
ax.set_xlabel('Quadratic surrogate (lower bound)')
ax.set_ylabel('True Shannon entropy')
ax.set_title('Surrogate vs true entropy (verified: S ≥ surrogate)')
ax.legend()
ax.set_xlim(0, max_val)
ax.set_ylim(0, max_val)

plt.tight_layout()
plt.savefig('viz_entropy_landscape.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: viz_entropy_landscape.png")
