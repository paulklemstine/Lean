"""
Visualization 2: Generation Probability Heatmap

Shows the theoretical generation probability 1 - C/q for certified pairs
across different dimensions n and field sizes q. Darker blue = higher
probability of generation.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def generation_probability(n, q, C=1.0):
    """
    Theoretical generation probability for certified pairs in SL_n(F_q).
    P[generation] ≈ 1 - C/q for a constant C depending on n.
    """
    return max(0, 1 - C / q)


def certificate_density(n, q):
    """Approximate certificate density."""
    return 1.0 / n  # Leading-order approximation


# Create heatmap data
ns = np.arange(2, 11)
qs = np.array([3, 4, 5, 7, 8, 9, 11, 13, 16, 17, 19, 23, 25, 27, 29, 31])

# Heatmap 1: Generation probability
gen_prob = np.array([[generation_probability(n, q) for q in qs] for n in ns])

# Heatmap 2: Certificate density
cert_dens = np.array([[certificate_density(n, q) for q in qs] for n in ns])

# Heatmap 3: Expected number of samples to find certified pair
expected_samples = np.array([[n * n for q in qs] for n in ns])  # O(n) each, need 2

fig, axes = plt.subplots(1, 3, figsize=(18, 6))

# Generation probability heatmap
im1 = axes[0].imshow(gen_prob, cmap='Blues', aspect='auto', vmin=0, vmax=1)
axes[0].set_xticks(range(len(qs)))
axes[0].set_xticklabels([str(q) for q in qs], rotation=45, fontsize=8)
axes[0].set_yticks(range(len(ns)))
axes[0].set_yticklabels([str(n) for n in ns])
axes[0].set_xlabel('Field size q', fontsize=11)
axes[0].set_ylabel('Dimension n', fontsize=11)
axes[0].set_title('Generation Probability\n1 - O(1/q)', fontsize=12,
                   fontweight='bold')
plt.colorbar(im1, ax=axes[0], fraction=0.046, pad=0.04)

# Certificate density heatmap
im2 = axes[1].imshow(cert_dens, cmap='Greens', aspect='auto', vmin=0, vmax=0.6)
axes[1].set_xticks(range(len(qs)))
axes[1].set_xticklabels([str(q) for q in qs], rotation=45, fontsize=8)
axes[1].set_yticks(range(len(ns)))
axes[1].set_yticklabels([str(n) for n in ns])
axes[1].set_xlabel('Field size q', fontsize=11)
axes[1].set_ylabel('Dimension n', fontsize=11)
axes[1].set_title('Certificate Density\nΘ(1/n)', fontsize=12,
                   fontweight='bold')
plt.colorbar(im2, ax=axes[1], fraction=0.046, pad=0.04)

# Combined: P[find certified pair AND they generate]
combined = np.array([
    [certificate_density(n, q) ** 2 * generation_probability(n, q)
     for q in qs]
    for n in ns
])
im3 = axes[2].imshow(combined, cmap='Oranges', aspect='auto')
axes[2].set_xticks(range(len(qs)))
axes[2].set_xticklabels([str(q) for q in qs], rotation=45, fontsize=8)
axes[2].set_yticks(range(len(ns)))
axes[2].set_yticklabels([str(n) for n in ns])
axes[2].set_xlabel('Field size q', fontsize=11)
axes[2].set_ylabel('Dimension n', fontsize=11)
axes[2].set_title('P[certified pair generates]\n= density² × gen_prob', fontsize=12,
                   fontweight='bold')
plt.colorbar(im3, ax=axes[2], fraction=0.046, pad=0.04)

plt.suptitle('Certificate Generation: Probability Landscape',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_generation_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved viz_generation_heatmap.png")
