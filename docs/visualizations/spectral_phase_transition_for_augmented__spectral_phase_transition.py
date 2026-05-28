#!/usr/bin/env python3
"""
Visualization: Spectral Phase Transition for Augmented Cayley Walks

Produces a comprehensive figure showing the spectral gap ratio as a function
of augmentation size, revealing the phase transition near k ~ n^{2/3}.
All functions are self-contained (no local imports).
"""
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

def laplace_eigenvalue(n, S, k1, k2):
    """Laplacian eigenvalue at character (k1,k2) for generating set S on (Z/nZ)^2."""
    total = 0.0
    for s1, s2 in S:
        inner = (k1 * s1 + k2 * s2) % n
        total += 1 - np.cos(2 * np.pi * inner / n)
    return total

def spectral_gap(n, S):
    """Minimum nontrivial eigenvalue."""
    min_eig = float('inf')
    for k1 in range(n):
        for k2 in range(n):
            if k1 == 0 and k2 == 0:
                continue
            min_eig = min(min_eig, laplace_eigenvalue(n, S, k1, k2))
    return min_eig

def local_generators(n):
    return [(1, 0), (n-1, 0), (0, 1), (0, n-1)]

def random_symmetric_aug(n, k, rng):
    S = set()
    attempts = 0
    while len(S) < 2 * k and attempts < 20 * k:
        a1 = rng.integers(0, n)
        a2 = rng.integers(0, n)
        if (a1, a2) != (0, 0):
            S.add((a1, a2))
            S.add(((-a1) % n, (-a2) % n))
        attempts += 1
    return list(S)

# Generate data
rng = np.random.default_rng(42)
n_values = [8, 10, 12, 14, 16, 18, 20, 24]

fig, axes = plt.subplots(2, 2, figsize=(14, 11))

# Panel 1: Gap ratio vs augmentation size for fixed n
ax1 = axes[0, 0]
for n in [10, 16, 24]:
    S_local = local_generators(n)
    gap_local = spectral_gap(n, S_local)
    
    k_range = np.unique(np.round(np.logspace(0, np.log10(n), 12)).astype(int))
    k_range = k_range[k_range <= n]
    
    ratios = []
    k_vals = []
    for k in k_range:
        trial_ratios = []
        for _ in range(3):
            A = random_symmetric_aug(n, k, rng)
            S_aug = list(set(S_local + A))
            gap_aug = spectral_gap(n, S_aug)
            trial_ratios.append(gap_aug / gap_local)
        ratios.append(np.mean(trial_ratios))
        k_vals.append(k)
    
    ax1.plot(k_vals, ratios, 'o-', label=f'n={n}', markersize=4)
    # Mark n^{2/3}
    threshold = n**(2/3)
    ax1.axvline(x=threshold, color='gray', linestyle=':', alpha=0.3)

ax1.set_xlabel('Augmentation size k', fontsize=11)
ax1.set_ylabel('Spectral Gap Ratio', fontsize=11)
ax1.set_title('Gap Ratio vs Augmentation Size', fontsize=12)
ax1.legend(fontsize=9)
ax1.grid(True, alpha=0.3)
ax1.set_xscale('log')

# Panel 2: Eigenvalue landscape
ax2 = axes[0, 1]
n = 16
S_local = local_generators(n)
eigs = np.zeros((n, n))
for k1 in range(n):
    for k2 in range(n):
        eigs[k1, k2] = laplace_eigenvalue(n, S_local, k1, k2)
im = ax2.imshow(eigs, cmap='viridis', origin='lower', aspect='equal')
plt.colorbar(im, ax=ax2, shrink=0.8)
ax2.set_xlabel('$k_2$', fontsize=11)
ax2.set_ylabel('$k_1$', fontsize=11)
ax2.set_title(f'Eigenvalue Landscape (n={n}, local)', fontsize=12)

# Panel 3: Ratio at fixed scale vs n
ax3 = axes[1, 0]
scales = {
    '$k=1$': lambda n: 1,
    '$k=n^{1/3}$': lambda n: max(1, int(n**(1/3))),
    '$k=n^{2/3}$': lambda n: max(1, int(n**(2/3))),
    '$k=n$': lambda n: n,
}
colors = ['blue', 'green', 'orange', 'red']

for (label, scale_fn), color in zip(scales.items(), colors):
    ratios = []
    ns = []
    for n in n_values:
        S_local = local_generators(n)
        gap_local = spectral_gap(n, S_local)
        k = scale_fn(n)
        k = min(k, n*n // 4)
        
        trial_ratios = []
        for _ in range(5):
            A = random_symmetric_aug(n, k, rng)
            S_aug = list(set(S_local + A))
            gap_aug = spectral_gap(n, S_aug)
            trial_ratios.append(gap_aug / gap_local)
        ratios.append(np.mean(trial_ratios))
        ns.append(n)
    
    ax3.plot(ns, ratios, 'o-', label=label, color=color, markersize=5)

ax3.set_xlabel('Group size n', fontsize=11)
ax3.set_ylabel('Spectral Gap Ratio', fontsize=11)
ax3.set_title('Ratio Growth at Different Scales', fontsize=12)
ax3.legend(fontsize=9)
ax3.grid(True, alpha=0.3)

# Panel 4: Subcritical vs supercritical
ax4 = axes[1, 1]
n = 20
S_local = local_generators(n)
gap_local = spectral_gap(n, S_local)

k_range = range(1, n+1)
ratios_rand = []
ratios_struct = []

for k in k_range:
    # Random augmentation
    trial_r = []
    for _ in range(5):
        A = random_symmetric_aug(n, k, rng)
        S_aug = list(set(S_local + A))
        gap_aug = spectral_gap(n, S_aug)
        trial_r.append(gap_aug / gap_local)
    ratios_rand.append(np.mean(trial_r))
    
    # Structured (axis) augmentation
    A = [(j, 0) for j in range(1, k+1)] + [((-j)%n, 0) for j in range(1, k+1)]
    A += [(0, j) for j in range(1, k+1)] + [(0, (-j)%n) for j in range(1, k+1)]
    S_aug = list(set(S_local + A))
    ratios_struct.append(spectral_gap(n, S_aug) / gap_local)

ax4.plot(list(k_range), ratios_rand, 'o-', label='Random aug', 
         markersize=3, alpha=0.7, color='blue')
ax4.plot(list(k_range), ratios_struct, 's-', label='Axis-aligned aug', 
         markersize=3, alpha=0.7, color='red')

# Mark threshold
threshold = n**(2/3)
ax4.axvline(x=threshold, color='green', linestyle='--', linewidth=2, 
            alpha=0.7, label=f'$n^{{2/3}}={threshold:.1f}$')
ax4.fill_betweenx([0, max(ratios_struct)*1.1], 0, threshold, 
                   color='green', alpha=0.05)
ax4.fill_betweenx([0, max(ratios_struct)*1.1], threshold, n, 
                   color='red', alpha=0.05)
ax4.text(threshold/2, max(ratios_struct)*0.9, 'Subcritical', 
         ha='center', fontsize=9, color='green')
ax4.text((threshold+n)/2, max(ratios_struct)*0.9, 'Supercritical', 
         ha='center', fontsize=9, color='red')

ax4.set_xlabel('Augmentation size k', fontsize=11)
ax4.set_ylabel('Spectral Gap Ratio', fontsize=11)
ax4.set_title(f'Phase Transition (n={n})', fontsize=12)
ax4.legend(fontsize=9)
ax4.grid(True, alpha=0.3)

plt.suptitle('Spectral Phase Transition for Augmented Cayley Walks on $(\\mathbb{Z}/n\\mathbb{Z})^2$', 
             fontsize=14, y=1.02)
plt.tight_layout()
plt.savefig('viz_phase_transition.png', dpi=150, bbox_inches='tight')
print("Saved viz_phase_transition.png")
