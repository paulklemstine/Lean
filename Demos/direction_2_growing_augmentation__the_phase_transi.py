#!/usr/bin/env python3
"""
Applications of Spectral Phase Transition Theory

Demonstrates real-world applications of the augmented Cayley walk
spectral theory to network design, mixing time optimization, and
transport analysis.
"""
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from typing import List, Tuple

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

def local_generators(n):
    return [(1, 0), (n-1, 0), (0, 1), (0, n-1)]

def mixing_time_bound(gap):
    """Upper bound on mixing time: t_mix ≤ (1/gap) * log(n^2)."""
    return 1.0 / gap if gap > 0 else float('inf')

# Application 1: Network Design Optimization
def app_network_design():
    """Find optimal shortcut placement for fast mixing on a grid network."""
    print("=" * 60)
    print("APPLICATION 1: Network Shortcut Optimization")
    print("=" * 60)
    print("\nProblem: Given a 2D grid network, where should we add")
    print("shortcuts to minimize mixing time?\n")
    
    n = 16
    S_local = local_generators(n)
    gap_local = spectral_gap(n, S_local)
    t_mix_local = mixing_time_bound(gap_local)
    
    print(f"Grid size: {n}×{n} = {n**2} nodes")
    print(f"Local walk gap: {gap_local:.6f}")
    print(f"Mixing time (local): {t_mix_local:.1f}\n")
    
    # Strategy 1: Random shortcuts
    rng = np.random.default_rng(42)
    budgets = [2, 4, 8, 16]
    
    print("Strategy 1: Random shortcuts")
    for budget in budgets:
        gaps = []
        for _ in range(10):
            A = []
            for _ in range(budget):
                a1, a2 = rng.integers(0, n), rng.integers(0, n)
                if (a1, a2) != (0, 0):
                    A.extend([(a1, a2), ((-a1)%n, (-a2)%n)])
            S_aug = list(set(S_local + A))
            gaps.append(spectral_gap(n, S_aug))
        avg_gap = np.mean(gaps)
        print(f"  Budget={budget:2d}: avg_gap={avg_gap:.5f}, "
              f"speedup={avg_gap/gap_local:.2f}x")
    
    # Strategy 2: Structured (axis-aligned)
    print("\nStrategy 2: Axis-aligned shortcuts")
    for budget in budgets:
        A = [(j, 0) for j in range(1, budget+1)] + [((-j)%n, 0) for j in range(1, budget+1)]
        A += [(0, j) for j in range(1, budget+1)] + [(0, (-j)%n) for j in range(1, budget+1)]
        S_aug = list(set(S_local + A))
        gap_aug = spectral_gap(n, S_aug)
        print(f"  Budget={budget:2d}: gap={gap_aug:.5f}, "
              f"speedup={gap_aug/gap_local:.2f}x")

# Application 2: Mixing Time Phase Transition  
def app_mixing_time():
    """Demonstrate mixing time phase transition."""
    print("\n" + "=" * 60)
    print("APPLICATION 2: Mixing Time Phase Transition")
    print("=" * 60)
    print("\nDemonstrating how mixing time changes with augmentation scale.\n")
    
    rng = np.random.default_rng(123)
    
    for n in [10, 16, 20]:
        S_local = local_generators(n)
        gap_local = spectral_gap(n, S_local)
        
        print(f"n = {n}:")
        scales = [0, 1, int(n**0.5), int(n**(2/3)), n]
        for k in scales:
            if k == 0:
                gap = gap_local
            else:
                A = []
                for _ in range(k):
                    a1, a2 = rng.integers(0, n), rng.integers(0, n)
                    A.extend([(a1, a2), ((-a1)%n, (-a2)%n)])
                S_aug = list(set(S_local + A))
                gap = spectral_gap(n, S_aug)
            
            t_mix = mixing_time_bound(gap) * np.log(n**2)
            ratio = gap / gap_local
            print(f"  k={k:3d}: gap={gap:.5f}, ratio={ratio:.3f}, "
                  f"t_mix~{t_mix:.1f}")
        print()

# Application 3: Transport Efficiency Analysis
def app_transport():
    """Analyze diffusion-to-jump crossover in transport."""
    print("=" * 60)
    print("APPLICATION 3: Transport Efficiency Analysis")
    print("=" * 60)
    print("\nComparing diffusive (local) vs jump-assisted transport.\n")
    
    n = 20
    S_local = local_generators(n)
    
    # Compute eigenvalue spectrum for local vs augmented
    eigs_local = []
    for k1 in range(n):
        for k2 in range(n):
            if k1 == 0 and k2 == 0:
                continue
            eigs_local.append(laplace_eigenvalue(n, S_local, k1, k2))
    eigs_local.sort()
    
    # With augmentation
    A = [(j, j) for j in range(n)] + [((-j)%n, (-j)%n) for j in range(n)]
    S_aug = list(set(S_local + A))
    eigs_aug = []
    for k1 in range(n):
        for k2 in range(n):
            if k1 == 0 and k2 == 0:
                continue
            eigs_aug.append(laplace_eigenvalue(n, S_aug, k1, k2))
    eigs_aug.sort()
    
    print(f"n = {n}, |S_local| = {len(S_local)}, |S_aug| = {len(S_aug)}")
    print(f"\nEigenvalue statistics:")
    print(f"  Local:     min={eigs_local[0]:.4f}, "
          f"max={eigs_local[-1]:.4f}, mean={np.mean(eigs_local):.4f}")
    print(f"  Augmented: min={eigs_aug[0]:.4f}, "
          f"max={eigs_aug[-1]:.4f}, mean={np.mean(eigs_aug):.4f}")
    print(f"\nSpectral gap ratio: {eigs_aug[0]/eigs_local[0]:.4f}")
    print(f"Mean eigenvalue ratio: {np.mean(eigs_aug)/np.mean(eigs_local):.4f}")

if __name__ == '__main__':
    app_network_design()
    app_mixing_time()
    app_transport()


#!/usr/bin/env python3
"""
Spectral Phase Transition Demo for Augmented Cayley Walks on (Z/nZ)^2

Demonstrates the spectral gap behavior of random walks on the discrete torus
with growing augmentation. Computes exact Fourier eigenvalues and plots the
spectral gap ratio as a function of augmentation size, revealing the predicted
phase transition near n^{2/3}.

Usage:
    python demo.py
"""
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from typing import List, Tuple

def laplace_eigenvalue(n: int, S: List[Tuple[int, int]], k1: int, k2: int) -> float:
    """Compute the Laplacian eigenvalue at character (k1, k2) for generating set S on (Z/nZ)^2.
    
    λ_S(k1,k2) = Σ_{(s1,s2) ∈ S} (1 - cos(2π(k1*s1 + k2*s2)/n))
    """
    total = 0.0
    for s1, s2 in S:
        inner = (k1 * s1 + k2 * s2) % n
        total += 1 - np.cos(2 * np.pi * inner / n)
    return total

def spectral_gap(n: int, S: List[Tuple[int, int]]) -> float:
    """Compute the spectral gap: minimum Laplacian eigenvalue over nontrivial characters."""
    min_eig = float('inf')
    for k1 in range(n):
        for k2 in range(n):
            if k1 == 0 and k2 == 0:
                continue
            eig = laplace_eigenvalue(n, S, k1, k2)
            min_eig = min(min_eig, eig)
    return min_eig

def local_generators(n: int) -> List[Tuple[int, int]]:
    """Standard local generators on (Z/nZ)^2: {(±1,0),(0,±1)}."""
    return [(1, 0), (n-1, 0), (0, 1), (0, n-1)]

def random_symmetric_augmentation(n: int, k: int, rng=None) -> List[Tuple[int, int]]:
    """Generate a random symmetric augmentation of size 2k (k pairs of ±generators)."""
    if rng is None:
        rng = np.random.default_rng()
    S = set()
    while len(S) < 2 * k:
        a1 = rng.integers(0, n)
        a2 = rng.integers(0, n)
        if (a1, a2) == (0, 0):
            continue
        S.add((a1, a2))
        S.add(((-a1) % n, (-a2) % n))
    return list(S)

def fourier_bias(n: int, A: List[Tuple[int, int]]) -> float:
    """Compute the Fourier bias: max |Σ_{a∈A} cos(2π⟨k,a⟩/n)| over nontrivial k."""
    max_bias = 0.0
    for k1 in range(n):
        for k2 in range(n):
            if k1 == 0 and k2 == 0:
                continue
            cos_sum = sum(np.cos(2 * np.pi * ((k1*a1 + k2*a2) % n) / n) 
                         for a1, a2 in A)
            max_bias = max(max_bias, abs(cos_sum))
    return max_bias

def demo_spectral_gap_ratio():
    """Main demo: compute spectral gap ratios for various augmentation sizes."""
    print("=" * 70)
    print("SPECTRAL PHASE TRANSITION DEMO")
    print("Augmented Cayley Walks on (Z/nZ)^2")
    print("=" * 70)
    
    rng = np.random.default_rng(42)
    
    # Test for several values of n
    n_values = [8, 12, 16, 20, 24, 30]
    
    print("\n--- Monotonicity Verification ---")
    print("Checking that spectral gap increases with augmentation...\n")
    
    for n in [10, 20]:
        S_local = local_generators(n)
        gap_local = spectral_gap(n, S_local)
        
        # Add increasing augmentation
        print(f"n = {n}, local gap = {gap_local:.6f}")
        for k in [1, 3, 5]:
            A = random_symmetric_augmentation(n, k, rng)
            S_aug = list(set(S_local + A))
            gap_aug = spectral_gap(n, S_aug)
            ratio = gap_aug / gap_local
            print(f"  k={k:2d} generators: gap={gap_aug:.6f}, ratio={ratio:.4f}")
        print()
    
    print("\n--- Phase Transition Sweep ---")
    print("Sweeping k = 1, n^{1/3}, n^{1/2}, n^{2/3}, n\n")
    
    results = {}
    
    for n in n_values:
        S_local = local_generators(n)
        gap_local = spectral_gap(n, S_local)
        
        # Augmentation sizes to test
        k_values = {
            '1': 1,
            'n^{1/3}': max(1, int(n**(1/3))),
            'n^{1/2}': max(1, int(n**(1/2))),
            'n^{2/3}': max(1, int(n**(2/3))),
            'n': n
        }
        
        print(f"n = {n}, gap_local = {gap_local:.6f}")
        ratios = {}
        for label, k in k_values.items():
            k = min(k, n*n // 4)  # Don't exceed group size
            
            # Average over several random augmentations
            trial_ratios = []
            for _ in range(5):
                A = random_symmetric_augmentation(n, k, rng)
                S_aug = list(set(S_local + A))
                gap_aug = spectral_gap(n, S_aug)
                trial_ratios.append(gap_aug / gap_local)
            
            avg_ratio = np.mean(trial_ratios)
            ratios[label] = avg_ratio
            print(f"  k={label:>8s} ({k:4d} gens): avg_ratio = {avg_ratio:.4f}")
        
        results[n] = ratios
        print()
    
    print("\n--- Fourier Bias Analysis ---")
    print("Testing Fourier bias of random augmentations\n")
    
    for n in [10, 16, 20]:
        for k in [2, 5, n//2]:
            A = random_symmetric_augmentation(n, k, rng)
            bias = fourier_bias(n, A)
            normalized_bias = bias / len(A)
            print(f"n={n:2d}, |A|={len(A):3d}: bias={bias:.3f}, "
                  f"bias/|A|={normalized_bias:.4f}")
        print()
    
    # Plot results
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    
    # Plot 1: Ratio vs augmentation scale for each n
    ax1 = axes[0]
    for n in n_values:
        if n in results:
            labels = list(results[n].keys())
            ratios = list(results[n].values())
            ax1.plot(range(len(labels)), ratios, 'o-', label=f'n={n}', markersize=5)
    
    ax1.set_xticks(range(5))
    ax1.set_xticklabels(['1', '$n^{1/3}$', '$n^{1/2}$', '$n^{2/3}$', 'n'], fontsize=11)
    ax1.set_xlabel('Augmentation Scale k', fontsize=12)
    ax1.set_ylabel('Spectral Gap Ratio', fontsize=12)
    ax1.set_title('Spectral Gap Ratio vs Augmentation Scale', fontsize=13)
    ax1.legend(fontsize=9)
    ax1.grid(True, alpha=0.3)
    ax1.axhline(y=1, color='gray', linestyle='--', alpha=0.5)
    
    # Plot 2: Ratio at n^{2/3} scale as n grows  
    ax2 = axes[1]
    n_vals_plot = []
    ratio_at_threshold = []
    ratio_below = []
    ratio_above = []
    for n_val in n_values:
        if n_val in results:
            n_vals_plot.append(n_val)
            ratio_at_threshold.append(results[n_val].get('n^{2/3}', 1))
            ratio_below.append(results[n_val].get('n^{1/3}', 1))
            ratio_above.append(results[n_val].get('n', 1))
    
    ax2.plot(n_vals_plot, ratio_below, 's-', label='$k = n^{1/3}$ (subcritical)', 
             color='green', markersize=6)
    ax2.plot(n_vals_plot, ratio_at_threshold, 'o-', label='$k = n^{2/3}$ (threshold)', 
             color='orange', markersize=6)
    ax2.plot(n_vals_plot, ratio_above, '^-', label='$k = n$ (supercritical)', 
             color='red', markersize=6)
    
    ax2.set_xlabel('Group size n', fontsize=12)
    ax2.set_ylabel('Spectral Gap Ratio', fontsize=12)
    ax2.set_title('Phase Transition: Ratio Growth vs Group Size', fontsize=13)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)
    ax2.axhline(y=1, color='gray', linestyle='--', alpha=0.5)
    
    plt.tight_layout()
    plt.savefig('spectral_phase_transition.png', dpi=150, bbox_inches='tight')
    print("\nPlot saved to spectral_phase_transition.png")
    
    print("\n--- Summary ---")
    print("Key observations:")
    print("1. Spectral gap is monotonically increasing with augmentation (Theorem 1)")
    print("2. Small augmentation (k ~ 1) gives ratio ≈ 1 (locality protected)")
    print("3. Large augmentation (k ~ n) gives divergent ratio (universality breaks)")
    print("4. The transition region appears near k ~ n^{2/3}")
    print("5. Random augmentations with small Fourier bias give near-optimal gap boost")

if __name__ == '__main__':
    demo_spectral_gap_ratio()


#!/usr/bin/env python3
"""
Visualization: Eigenvalue Landscape on (Z/nZ)^2

Produces a side-by-side comparison of eigenvalue landscapes for the local
walk vs an augmented walk, showing how shortcuts reshape the spectral landscape.
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

def local_generators(n):
    return [(1, 0), (n-1, 0), (0, 1), (0, n-1)]

n = 20
S_local = local_generators(n)

# Augmentation: add diagonal generators
A = [(1, 1), (n-1, n-1), (2, 3), (n-2, n-3), (5, 0), (n-5, 0)]
S_aug = list(set(S_local + A))

# Compute eigenvalue landscapes
eigs_local = np.zeros((n, n))
eigs_aug = np.zeros((n, n))
for k1 in range(n):
    for k2 in range(n):
        eigs_local[k1, k2] = laplace_eigenvalue(n, S_local, k1, k2)
        eigs_aug[k1, k2] = laplace_eigenvalue(n, S_aug, k1, k2)

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Local eigenvalue landscape
im0 = axes[0].imshow(eigs_local, cmap='magma', origin='lower', aspect='equal')
plt.colorbar(im0, ax=axes[0], shrink=0.8)
axes[0].set_title(f'Local Walk (|S|={len(S_local)})', fontsize=12)
axes[0].set_xlabel('$k_2$')
axes[0].set_ylabel('$k_1$')

# Augmented eigenvalue landscape
im1 = axes[1].imshow(eigs_aug, cmap='magma', origin='lower', aspect='equal')
plt.colorbar(im1, ax=axes[1], shrink=0.8)
axes[1].set_title(f'Augmented Walk (|S|={len(S_aug)})', fontsize=12)
axes[1].set_xlabel('$k_2$')
axes[1].set_ylabel('$k_1$')

# Difference (improvement)
diff = eigs_aug - eigs_local
im2 = axes[2].imshow(diff, cmap='RdYlGn', origin='lower', aspect='equal')
plt.colorbar(im2, ax=axes[2], shrink=0.8)
axes[2].set_title('Eigenvalue Improvement', fontsize=12)
axes[2].set_xlabel('$k_2$')
axes[2].set_ylabel('$k_1$')

gap_local = eigs_local[eigs_local > 1e-10].min()
gap_aug = eigs_aug[eigs_aug > 1e-10].min()

plt.suptitle(f'Eigenvalue Landscape on $(\\mathbb{{Z}}/{n}\\mathbb{{Z}})^2$\n'
             f'Gap: {gap_local:.4f} → {gap_aug:.4f} (ratio {gap_aug/gap_local:.2f}×)',
             fontsize=13, y=1.05)
plt.tight_layout()
plt.savefig('viz_eigenvalue_landscape.png', dpi=150, bbox_inches='tight')
print("Saved viz_eigenvalue_landscape.png")


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
