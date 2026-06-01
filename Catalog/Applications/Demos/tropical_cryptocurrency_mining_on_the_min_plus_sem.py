#!/usr/bin/env python3
"""
Tropical Cryptocurrency Mining Demo
====================================
Demonstrates TSHA and TSHA2 hash functions, collision analysis,
mining simulation, and the concentration conjecture test.
"""

import random
import statistics
from typing import List, Tuple

random.seed(42)


def tsha(m: List[int], h: List[int]) -> int:
    """Tropical Secure Hash Algorithm: TSHA(m, h) = min_i(m_i + h_i)."""
    assert len(m) == len(h), "Message and key must have same length"
    return min(m[i] + h[i] for i in range(len(m)))


def tsha2(m: List[int], h: List[int], h2: List[int]) -> Tuple[int, int]:
    """Double Tropical Hash: TSHA2(m, h, h') = (TSHA(m,h), TSHA(m,h'))."""
    return (tsha(m, h), tsha(m, h2))


def canonical_preimage(y: int, h: List[int]) -> List[int]:
    """Construct canonical preimage: m_i = y - h_i."""
    return [y - hi for hi in h]


def tropical_merkle(a: int, b: int) -> int:
    """Tropical Merkle node: min(a, b)."""
    return min(a, b)


def demo_basic_tsha():
    """Demonstrate basic TSHA properties."""
    print("=" * 60)
    print("DEMO 1: Basic TSHA Properties")
    print("=" * 60)
    
    k = 8
    h = [3, 1, 4, 1, 5, 9, 2, 6]
    m = [7, 8, 2, 5, 3, 1, 4, 0]
    
    hash_val = tsha(m, h)
    print(f"Key h = {h}")
    print(f"Message m = {m}")
    print(f"Component sums m_i + h_i = {[m[i]+h[i] for i in range(k)]}")
    print(f"TSHA(m, h) = min(sums) = {hash_val}")
    
    # Symmetry
    hash_sym = tsha(h, m)
    print(f"\nSymmetry: TSHA(h, m) = {hash_sym} (should equal {hash_val})")
    
    # Shift equivariance
    c = 5
    m_shifted = [mi + c for mi in m]
    hash_shifted = tsha(m_shifted, h)
    print(f"\nShift by c={c}: TSHA(m+{c}, h) = {hash_shifted} = {hash_val} + {c} = {hash_val + c}")
    
    # Canonical preimage
    target = 10
    preimage = canonical_preimage(target, h)
    print(f"\nCanonical preimage for target={target}: m = {preimage}")
    print(f"Verify: TSHA(preimage, h) = {tsha(preimage, h)}")


def demo_collisions():
    """Demonstrate collision abundance in TSHA."""
    print("\n" + "=" * 60)
    print("DEMO 2: TSHA Collision Analysis")
    print("=" * 60)
    
    k = 8
    h = [3, 1, 4, 1, 5, 9, 2, 6]
    m = [7, 8, 2, 5, 3, 1, 4, 0]
    
    original_hash = tsha(m, h)
    sums = [m[i] + h[i] for i in range(k)]
    min_idx = sums.index(min(sums))
    
    print(f"Original: TSHA(m, h) = {original_hash}, min at index {min_idx}")
    
    # Generate collisions by perturbing non-minimum indices
    collision_count = 0
    for delta in range(1, 4):
        for i in range(k):
            if i == min_idx:
                continue
            m_perturbed = list(m)
            m_perturbed[i] += delta
            if tsha(m_perturbed, h) == original_hash:
                collision_count += 1
                if collision_count <= 5:
                    print(f"  Collision: perturb index {i} by +{delta} → TSHA = {tsha(m_perturbed, h)}")
    
    print(f"Total single-coordinate collisions found: {collision_count}")
    print("Collision freedom degree = k - 1 =", k - 1)


def demo_tsha2_improvement():
    """Demonstrate how TSHA2 reduces collisions."""
    print("\n" + "=" * 60)
    print("DEMO 3: TSHA2 Collision Resistance Improvement")
    print("=" * 60)
    
    for k in [4, 8, 16, 32]:
        h = [random.randint(0, 100) for _ in range(k)]
        h2 = [random.randint(0, 100) for _ in range(k)]
        
        n_trials = 10000
        n_tsha_collisions = 0
        n_tsha2_collisions = 0
        
        for _ in range(n_trials):
            m1 = [random.randint(0, 100) for _ in range(k)]
            m2 = [random.randint(0, 100) for _ in range(k)]
            
            if tsha(m1, h) == tsha(m2, h):
                n_tsha_collisions += 1
                if tsha2(m1, h, h2) == tsha2(m2, h, h2):
                    n_tsha2_collisions += 1
        
        survival_rate = n_tsha2_collisions / max(n_tsha_collisions, 1)
        print(f"k={k:3d}: TSHA collisions={n_tsha_collisions:5d}, "
              f"TSHA2 collisions={n_tsha2_collisions:4d}, "
              f"survival rate={survival_rate:.3f}")


def demo_mining():
    """Simulate tropical mining."""
    print("\n" + "=" * 60)
    print("DEMO 4: Tropical Mining Simulation")
    print("=" * 60)
    
    k = 16
    h = [random.randint(0, 50) for _ in range(k)]
    
    for target in [30, 20, 10, 5, 0, -5]:
        nonces_tried = 0
        found = False
        
        for _ in range(100000):
            nonce = [random.randint(-50, 50) for _ in range(k)]
            nonces_tried += 1
            if tsha(nonce, h) <= target:
                found = True
                break
        
        status = f"found in {nonces_tried} tries" if found else "NOT found in 100000 tries"
        print(f"Target ≤ {target:4d}: {status}")


def demo_concentration_conjecture():
    """Test the tropical hash concentration conjecture."""
    import math
    print("\n" + "=" * 60)
    print("DEMO 5: Concentration Conjecture Test")
    print("=" * 60)
    print("Conjecture: E[TSHA(m,h)] ≈ N·√(π/(2k)) for uniform m,h ∈ {0,...,N}^k")
    print("(Arises from triangular distribution of m_i + h_i, not uniform)")
    
    N = 1000
    n_samples = 50000
    
    print(f"\nN = {N}, samples = {n_samples}")
    print(f"{'k':>6} {'E[TSHA]':>10} {'N*sqrt(pi/2k)':>14} {'ratio':>8} {'Var[TSHA]':>12}")
    print("-" * 56)
    
    for k in [5, 10, 20, 50, 100, 200]:
        hashes = []
        for _ in range(n_samples):
            m = [random.randint(0, N) for _ in range(k)]
            h = [random.randint(0, N) for _ in range(k)]
            hashes.append(tsha(m, h))
        
        mean_hash = statistics.mean(hashes)
        var_hash = statistics.variance(hashes)
        predicted = N * math.sqrt(math.pi / (2 * k))
        ratio = mean_hash / predicted if predicted > 0 else float('inf')
        
        print(f"{k:6d} {mean_hash:10.2f} {predicted:14.2f} {ratio:8.4f} {var_hash:12.2f}")
    
    print("\nIf ratio ≈ 1.0 for large k, conjecture is supported.")
    print("(Small k shows finite-size corrections.)")
    print("\nNote: The naive conjecture E[TSHA] ≈ 2N/(k+1) is FALSIFIED")
    print("because m_i + h_i is triangular, not uniform.")


def demo_concatenation():
    """Demonstrate the concatenation decomposition theorem."""
    print("\n" + "=" * 60)
    print("DEMO 6: Concatenation Decomposition")
    print("=" * 60)
    
    k1, k2 = 4, 5
    m1 = [3, 1, 4, 1]
    m2 = [5, 9, 2, 6, 5]
    h1 = [2, 7, 1, 8]
    h2 = [2, 8, 1, 8, 2]
    
    # Concatenate
    m_full = m1 + m2
    h_full = h1 + h2
    
    hash_full = tsha(m_full, h_full)
    hash_1 = tsha(m1, h1)
    hash_2 = tsha(m2, h2)
    
    print(f"TSHA(m1‖m2, h1‖h2) = {hash_full}")
    print(f"min(TSHA(m1,h1), TSHA(m2,h2)) = min({hash_1}, {hash_2}) = {min(hash_1, hash_2)}")
    print(f"Equal: {hash_full == min(hash_1, hash_2)} ✓")


if __name__ == "__main__":
    demo_basic_tsha()
    demo_collisions()
    demo_tsha2_improvement()
    demo_mining()
    demo_concentration_conjecture()
    demo_concatenation()


#!/usr/bin/env python3
"""
Visualization: Tropical Mining Difficulty Landscape
====================================================
Shows how TSHA hash values distribute and how mining difficulty
scales with the target parameter.
"""

import random
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

random.seed(42)
np.random.seed(42)


def tsha(m, h):
    return min(m[i] + h[i] for i in range(len(m)))


def plot_hash_distribution():
    """Plot TSHA hash value distributions for different k."""
    fig, axes = plt.subplots(2, 2, figsize=(12, 10))
    fig.suptitle('TSHA Hash Value Distributions', fontsize=16, fontweight='bold')
    
    N = 100
    n_samples = 50000
    
    for idx, k in enumerate([4, 16, 64, 256]):
        ax = axes[idx // 2][idx % 2]
        
        hashes = []
        for _ in range(n_samples):
            m = [random.randint(0, N) for _ in range(k)]
            h = [random.randint(0, N) for _ in range(k)]
            hashes.append(tsha(m, h))
        
        ax.hist(hashes, bins=50, density=True, alpha=0.7, color='#2196F3', edgecolor='black', linewidth=0.5)
        
        predicted_mean = 2 * N / (k + 1)
        actual_mean = np.mean(hashes)
        ax.axvline(predicted_mean, color='red', linestyle='--', linewidth=2, label=f'Predicted: {predicted_mean:.1f}')
        ax.axvline(actual_mean, color='green', linestyle='-', linewidth=2, label=f'Actual: {actual_mean:.1f}')
        
        ax.set_title(f'k = {k}', fontsize=13)
        ax.set_xlabel('TSHA value')
        ax.set_ylabel('Density')
        ax.legend(fontsize=9)
    
    plt.tight_layout()
    plt.savefig('tropical_hash_distribution.png', dpi=150, bbox_inches='tight')
    print("Saved tropical_hash_distribution.png")


def plot_concentration_conjecture():
    """Plot the concentration conjecture test results."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))
    fig.suptitle('Tropical Hash Concentration Conjecture', fontsize=16, fontweight='bold')
    
    N = 1000
    n_samples = 20000
    ks = [3, 5, 8, 10, 15, 20, 30, 50, 75, 100, 150, 200]
    
    means = []
    variances = []
    predicted_means = []
    
    for k in ks:
        hashes = []
        for _ in range(n_samples):
            m = [random.randint(0, N) for _ in range(k)]
            h = [random.randint(0, N) for _ in range(k)]
            hashes.append(tsha(m, h))
        
        means.append(np.mean(hashes))
        variances.append(np.var(hashes))
        predicted_means.append(2 * N / (k + 1))
    
    # Plot 1: Mean vs predicted
    ax1.plot(ks, means, 'bo-', markersize=6, label='Empirical E[TSHA]')
    ax1.plot(ks, predicted_means, 'r--', linewidth=2, label='2N/(k+1)')
    ax1.set_xlabel('k (dimension)', fontsize=12)
    ax1.set_ylabel('Expected hash value', fontsize=12)
    ax1.set_title('Mean Convergence', fontsize=13)
    ax1.legend(fontsize=11)
    ax1.set_xscale('log')
    ax1.set_yscale('log')
    ax1.grid(True, alpha=0.3)
    
    # Plot 2: Variance scaling
    ax2.plot(ks, variances, 'go-', markersize=6, label='Empirical Var[TSHA]')
    # Fit power law
    log_k = np.log(ks)
    log_var = np.log(variances)
    slope, intercept = np.polyfit(log_k, log_var, 1)
    fitted = np.exp(intercept) * np.array(ks) ** slope
    ax2.plot(ks, fitted, 'r--', linewidth=2, label=f'Power law: k^{slope:.2f}')
    
    ax2.set_xlabel('k (dimension)', fontsize=12)
    ax2.set_ylabel('Variance', fontsize=12)
    ax2.set_title(f'Variance Scaling (exponent ≈ {slope:.2f})', fontsize=13)
    ax2.legend(fontsize=11)
    ax2.set_xscale('log')
    ax2.set_yscale('log')
    ax2.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('concentration_conjecture.png', dpi=150, bbox_inches='tight')
    print("Saved concentration_conjecture.png")


def plot_collision_analysis():
    """Plot TSHA vs TSHA2 collision rates."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))
    fig.suptitle('Collision Resistance: TSHA vs TSHA2', fontsize=16, fontweight='bold')
    
    ks = [2, 4, 8, 16, 32, 64]
    n_trials = 20000
    N = 50
    
    tsha_rates = []
    tsha2_rates = []
    survival_rates = []
    
    for k in ks:
        h = [random.randint(0, N) for _ in range(k)]
        h2 = [random.randint(0, N) for _ in range(k)]
        
        tsha_col = 0
        tsha2_col = 0
        
        for _ in range(n_trials):
            m1 = [random.randint(0, N) for _ in range(k)]
            m2 = [random.randint(0, N) for _ in range(k)]
            
            t1 = tsha(m1, h)
            t2 = tsha(m2, h)
            
            if t1 == t2:
                tsha_col += 1
                if tsha(m1, h2) == tsha(m2, h2):
                    tsha2_col += 1
        
        tsha_rates.append(tsha_col / n_trials)
        tsha2_rates.append(tsha2_col / n_trials)
        survival_rates.append(tsha2_col / max(tsha_col, 1))
    
    # Plot 1: Collision rates
    ax1.semilogy(ks, tsha_rates, 'rs-', markersize=8, linewidth=2, label='TSHA collision rate')
    ax1.semilogy(ks, tsha2_rates, 'b^-', markersize=8, linewidth=2, label='TSHA2 collision rate')
    ax1.set_xlabel('k (dimension)', fontsize=12)
    ax1.set_ylabel('Collision probability', fontsize=12)
    ax1.set_title('Collision Rates', fontsize=13)
    ax1.legend(fontsize=11)
    ax1.grid(True, alpha=0.3)
    
    # Plot 2: Survival rate
    ax2.bar(range(len(ks)), survival_rates, color='#FF9800', edgecolor='black')
    ax2.set_xticks(range(len(ks)))
    ax2.set_xticklabels([str(k) for k in ks])
    ax2.set_xlabel('k (dimension)', fontsize=12)
    ax2.set_ylabel('Survival rate (TSHA2 col / TSHA col)', fontsize=12)
    ax2.set_title('Fraction of TSHA Collisions Surviving in TSHA2', fontsize=13)
    ax2.axhline(y=0, color='black', linewidth=0.5)
    ax2.grid(True, alpha=0.3, axis='y')
    
    plt.tight_layout()
    plt.savefig('collision_analysis.png', dpi=150, bbox_inches='tight')
    print("Saved collision_analysis.png")


if __name__ == "__main__":
    plot_hash_distribution()
    plot_concentration_conjecture()
    plot_collision_analysis()
