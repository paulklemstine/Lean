"""
Visualization 1: Noise Threshold Phase Diagram
================================================
Visualizes the certified noise threshold as a function of circuit depth
and noise rate. Shows the boundary between certified and uncertified
regions in the (depth, noise) parameter space.
"""

import numpy as np
import matplotlib.pyplot as plt


def molecular_orbital_kernel(n_orbitals, n_electrons, hopping_strength=1.0):
    H = np.zeros((n_orbitals, n_orbitals))
    for i in range(n_orbitals - 1):
        H[i, i + 1] = -hopping_strength
        H[i + 1, i] = -hopping_strength
    eigvals, eigvecs = np.linalg.eigh(H)
    occupied = eigvecs[:, :n_electrons]
    return occupied @ occupied.T


def pairwise_neg_dep_defect(K, i, j):
    return (K[i, i] * K[j, j] - K[i, j] * K[j, i]) - K[i, i] * K[j, j]


def compute_neg_dep_margin(K):
    n = K.shape[0]
    margin = float('inf')
    for i in range(n):
        for j in range(i + 1, n):
            margin = min(margin, -pairwise_neg_dep_defect(K, i, j))
    return margin


def simulate_noisy_circuit(K, depth, eps):
    n = K.shape[0]
    K_noisy = K.copy()
    for _ in range(depth):
        K_noisy = (1 - eps) * K_noisy + eps * np.eye(n) / 2
    return K_noisy


# Parameters
n = 8
k = 4
K = molecular_orbital_kernel(n, k)
margin = compute_neg_dep_margin(K)

eps_range = np.linspace(0.001, 0.1, 80)
depth_range = np.arange(1, 101)

# Compute phase diagrams
certified_sym = np.zeros((len(eps_range), len(depth_range)))
certified_gen = np.zeros((len(eps_range), len(depth_range)))
actual = np.zeros((len(eps_range), len(depth_range)))

for ie, eps in enumerate(eps_range):
    for id_, d in enumerate(depth_range):
        certified_sym[ie, id_] = 1.0 if 2 * d * eps < margin else 0.0
        certified_gen[ie, id_] = 1.0 if 4 * d * eps < margin else 0.0

        K_noisy = simulate_noisy_circuit(K, d, eps)
        all_neg = all(
            pairwise_neg_dep_defect(K_noisy, i, j) < 0
            for i in range(n) for j in range(i + 1, n)
        )
        actual[ie, id_] = 1.0 if all_neg else 0.0

fig, axes = plt.subplots(1, 3, figsize=(18, 5))

for ax, data, title, cmap in [
    (axes[0], actual, "Actual Neg. Dep. Preserved", "Greens"),
    (axes[1], certified_gen, "Certified (General: 4dε < δ)", "Blues"),
    (axes[2], certified_sym, "Certified (Symmetric: 2dε < δ)", "Oranges"),
]:
    im = ax.imshow(data, aspect='auto', origin='lower',
                   extent=[depth_range[0], depth_range[-1],
                           eps_range[0], eps_range[-1]],
                   cmap=cmap, alpha=0.8)
    ax.set_xlabel("Circuit Depth d", fontsize=12)
    ax.set_ylabel("Noise Rate ε", fontsize=12)
    ax.set_title(title, fontsize=13, fontweight='bold')
    plt.colorbar(im, ax=ax, label="Preserved / Certified")

    # Add threshold curve
    if "Symmetric" in title:
        threshold_depths = margin / (2 * eps_range)
    elif "General" in title:
        threshold_depths = margin / (4 * eps_range)
    else:
        threshold_depths = None

    if threshold_depths is not None:
        ax.plot(threshold_depths, eps_range, 'r-', linewidth=2, label='Threshold')
        ax.legend(fontsize=10)

plt.suptitle(f"Noise Threshold Phase Diagram (n={n}, δ={margin:.4f})",
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig("noise_threshold_phase_diagram.png", dpi=150, bbox_inches='tight')
plt.close()
print("Saved noise_threshold_phase_diagram.png")
