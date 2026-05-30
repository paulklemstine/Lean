"""
Visualization 2: Entropy Gap Heatmap

Shows the spectral-entropy gap H(G) - log(lambda_1/Delta) as a heatmap
across different graph sizes and edge densities. Brighter colors indicate
larger gaps (more "entropy freedom").
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def degree_entropy(adj):
    degrees = adj.sum(axis=1)
    total = degrees.sum()
    if total == 0:
        return 0.0
    probs = degrees / total
    nonzero = probs[probs > 0]
    return float(-np.sum(nonzero * np.log(nonzero)))


def spectral_ratio(adj):
    eigs = np.linalg.eigvalsh(adj)
    lambda1 = eigs.max()
    max_deg = adj.sum(axis=1).max()
    return lambda1 / max_deg if max_deg > 0 else 1.0


def random_graph(n, p):
    upper = np.random.random((n, n)) < p
    adj = np.triu(upper, k=1).astype(float)
    return adj + adj.T


np.random.seed(42)

sizes = [10, 15, 20, 25, 30, 35, 40]
probs = np.linspace(0.05, 0.95, 15)
num_samples = 50

gap_matrix = np.zeros((len(sizes), len(probs)))
ratio_matrix = np.zeros((len(sizes), len(probs)))

for i, n in enumerate(sizes):
    for j, p in enumerate(probs):
        gaps = []
        rats = []
        for _ in range(num_samples):
            adj = random_graph(n, p)
            if adj.sum() == 0:
                continue
            H = degree_entropy(adj)
            ratio = spectral_ratio(adj)
            log_ratio = np.log(ratio) if ratio > 0 else -10
            gaps.append(H - log_ratio)
            rats.append(ratio)
        gap_matrix[i, j] = np.mean(gaps) if gaps else 0
        ratio_matrix[i, j] = np.mean(rats) if rats else 0

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

# Entropy gap heatmap
im1 = ax1.imshow(gap_matrix, aspect='auto', cmap='YlOrRd',
                  origin='lower', interpolation='bilinear')
ax1.set_xticks(range(0, len(probs), 3))
ax1.set_xticklabels([f'{p:.2f}' for p in probs[::3]])
ax1.set_yticks(range(len(sizes)))
ax1.set_yticklabels(sizes)
ax1.set_xlabel('Edge Probability p', fontsize=12)
ax1.set_ylabel('Number of Vertices n', fontsize=12)
ax1.set_title('Entropy Gap: H(G) - log(λ₁/Δ)', fontsize=13)
plt.colorbar(im1, ax=ax1, label='Gap (always ≥ 0)')

# Spectral ratio heatmap
im2 = ax2.imshow(ratio_matrix, aspect='auto', cmap='viridis',
                  origin='lower', interpolation='bilinear')
ax2.set_xticks(range(0, len(probs), 3))
ax2.set_xticklabels([f'{p:.2f}' for p in probs[::3]])
ax2.set_yticks(range(len(sizes)))
ax2.set_yticklabels(sizes)
ax2.set_xlabel('Edge Probability p', fontsize=12)
ax2.set_ylabel('Number of Vertices n', fontsize=12)
ax2.set_title('Spectral Regularity Ratio λ₁/Δ', fontsize=13)
plt.colorbar(im2, ax=ax2, label='Ratio (1 = regular)')

plt.tight_layout()
plt.savefig('viz_bridge_heatmap.png', dpi=150)
print("Saved viz_bridge_heatmap.png")
