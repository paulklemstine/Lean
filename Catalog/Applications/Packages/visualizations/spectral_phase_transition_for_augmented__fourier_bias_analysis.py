#!/usr/bin/env python3
"""
Visualization: Fourier Bias and Spectral Gap Relationship

Shows how the Fourier bias of an augmentation set controls the spectral
gap improvement, illustrating the cross-domain bridge between additive
combinatorics and Markov chain mixing.
All functions are self-contained (no local imports).
"""
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

def laplace_eigenvalue(n, S, k1, k2):
    total = 0.0
    for s1, s2 in S:
        inner = (k1 * s1 + k2 * s2) % n
        total += 1 - np.cos(2 * np.pi * inner / n)
    return total

def spectral_gap(n, S):
    min_eig = float('inf')
    for k1 in range(n):
        for k2 in range(n):
            if k1 == 0 and k2 == 0:
                continue
            min_eig = min(min_eig, laplace_eigenvalue(n, S, k1, k2))
    return min_eig

def fourier_bias(n, A):
    max_bias = 0.0
    for k1 in range(n):
        for k2 in range(n):
            if k1 == 0 and k2 == 0:
                continue
            cos_sum = sum(np.cos(2 * np.pi * ((k1*a1 + k2*a2) % n) / n)
                         for a1, a2 in A)
            max_bias = max(max_bias, abs(cos_sum))
    return max_bias

def local_generators(n):
    return [(1, 0), (n-1, 0), (0, 1), (0, n-1)]

def random_symmetric_aug(n, k, rng):
    S = set()
    while len(S) < 2 * k:
        a1 = rng.integers(0, n)
        a2 = rng.integers(0, n)
        if (a1, a2) != (0, 0):
            S.add((a1, a2))
            S.add(((-a1) % n, (-a2) % n))
    return list(S)

rng = np.random.default_rng(42)
n = 16

fig, axes = plt.subplots(1, 2, figsize=(13, 5.5))

# Panel 1: Fourier bias vs gap improvement for many random augmentations
biases = []
gap_improvements = []
sizes = []
S_local = local_generators(n)
gap_local = spectral_gap(n, S_local)

for k in range(1, n+1):
    for _ in range(8):
        A = random_symmetric_aug(n, k, rng)
        A_sdiff = [a for a in A if a not in S_local]
        if not A_sdiff:
            continue
        S_aug = list(set(S_local + A))
        gap_aug = spectral_gap(n, S_aug)
        bias = fourier_bias(n, A_sdiff)
        
        biases.append(bias / len(A_sdiff) if A_sdiff else 0)
        gap_improvements.append(gap_aug - gap_local)
        sizes.append(len(A_sdiff))

sc = axes[0].scatter(biases, gap_improvements, c=sizes, cmap='viridis',
                      alpha=0.6, s=20, edgecolors='none')
plt.colorbar(sc, ax=axes[0], label='|A \\ S|')
axes[0].set_xlabel('Normalized Fourier Bias β/|A|', fontsize=11)
axes[0].set_ylabel('Gap Improvement Δgap', fontsize=11)
axes[0].set_title('Fourier Bias vs Spectral Gap Improvement', fontsize=12)
axes[0].grid(True, alpha=0.3)

# Add theoretical lower bound line
x_range = np.linspace(0, 1, 100)
for card in [5, 10, 20]:
    y_bound = card * (1 - x_range)
    axes[0].plot(x_range, y_bound, '--', alpha=0.5, label=f'|A|={card}: |A|(1-β/|A|)')
axes[0].legend(fontsize=8)

# Panel 2: Gap ratio vs augmentation size, colored by bias
ax2 = axes[1]
for k in [2, 5, 8, 12, n]:
    biases_k = []
    ratios_k = []
    for _ in range(20):
        A = random_symmetric_aug(n, k, rng)
        A_sdiff = [a for a in A if a not in S_local]
        S_aug = list(set(S_local + A))
        gap_aug = spectral_gap(n, S_aug)
        ratio = gap_aug / gap_local
        bias = fourier_bias(n, A_sdiff) / max(len(A_sdiff), 1)
        biases_k.append(bias)
        ratios_k.append(ratio)
    
    ax2.errorbar(k, np.mean(ratios_k), yerr=np.std(ratios_k),
                 fmt='o', markersize=6, capsize=3, label=f'k={k}')

ax2.set_xlabel('Augmentation size k', fontsize=11)
ax2.set_ylabel('Spectral Gap Ratio', fontsize=11)
ax2.set_title(f'Gap Ratio Statistics (n={n})', fontsize=12)
ax2.legend(fontsize=9)
ax2.grid(True, alpha=0.3)

plt.suptitle(f'Fourier Bias Controls Spectral Acceleration on $(\\mathbb{{Z}}/{n}\\mathbb{{Z}})^2$',
             fontsize=13, y=1.02)
plt.tight_layout()
plt.savefig('viz_fourier_bias.png', dpi=150, bbox_inches='tight')
print("Saved viz_fourier_bias.png")
