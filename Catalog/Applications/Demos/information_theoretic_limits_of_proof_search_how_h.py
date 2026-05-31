#!/usr/bin/env python3
"""
Demonstration of Information-Theoretic Proof Search Complexity

Shows key results through concrete numerical examples:
1. Search space growth vs polynomial verification
2. Information content of proofs
3. Proof density estimation
4. The n*log(n) proof length conjecture
5. Verification-search gap computation
"""

import math
from algorithms import (
    ProofSearchInstance,
    brute_force_search,
    proof_length_lower_bound,
    search_tree_size,
    proof_search_gap,
    estimate_proof_density,
    proof_length_ratio_analysis,
)


def demo_search_space_growth():
    """Demonstrate exponential growth of proof search spaces."""
    print("=" * 70)
    print("DEMO 1: Exponential Growth of Search Spaces")
    print("=" * 70)
    print()
    print(f"{'Length n':>10} {'2^n':>20} {'n^2':>10} {'Ratio 2^n/n^2':>15}")
    print("-" * 60)
    for n in [5, 10, 15, 20, 25, 30]:
        exp = 2 ** n
        quad = n ** 2
        ratio = exp / quad
        print(f"{n:>10} {exp:>20,} {quad:>10} {ratio:>15.1f}")
    print()
    print("Key insight: The search space grows exponentially while")
    print("verification cost grows only polynomially.")
    print()


def demo_proof_search_instance():
    """Demonstrate the ProofSearchInstance abstraction."""
    print("=" * 70)
    print("DEMO 2: Proof Search Instance Analysis")
    print("=" * 70)
    print()

    instances = [
        ("Small (binary, len 10, 5 proofs)", 2, 10, 5, 10),
        ("Medium (binary, len 20, 100 proofs)", 2, 20, 100, 50),
        ("Large (ternary, len 15, 10 proofs)", 3, 15, 10, 100),
        ("Lean-like (256 symbols, len 8, 3 proofs)", 256, 8, 3, 1000),
    ]

    for name, b, n, p, v in instances:
        inst = ProofSearchInstance(b, n, p, v)
        print(f"Instance: {name}")
        print(f"  Search space:     {inst.search_space_size:>20,}")
        print(f"  Brute-force cost: {inst.brute_force_cost:>20,}")
        print(f"  Proof density:    {inst.proof_density:.2e}")
        print(f"  Info content:     {inst.information_content_bits:.1f} bits")
        print(f"  Search/verify:    {inst.search_verification_ratio:.2e}")
        print()


def demo_brute_force_search():
    """Demonstrate brute-force search finding a simple proof."""
    print("=" * 70)
    print("DEMO 3: Brute-Force Proof Search")
    print("=" * 70)
    print()

    # A toy proof system: valid proofs are palindromes of length 3
    target = [1, 0, 1]

    def verify(candidate):
        return candidate == target

    result = brute_force_search(2, 3, verify)
    print(f"Target proof: {target}")
    print(f"Found proof:  {result}")
    print(f"Search space: {2**3} candidates")
    print()


def demo_counting_bounds():
    """Demonstrate counting-based proof length lower bounds."""
    print("=" * 70)
    print("DEMO 4: Counting-Based Proof Length Bounds")
    print("=" * 70)
    print()

    print(f"{'Theorems T':>12} {'Alphabet b':>12} {'Min length':>12} {'Space b^n':>15}")
    print("-" * 55)
    for T in [10, 100, 1000, 10000, 1000000]:
        for b in [2, 10, 256]:
            n = proof_length_lower_bound(T, b)
            space = b ** n
            print(f"{T:>12,} {b:>12} {n:>12} {space:>15,}")
    print()
    print("Minimum proof length grows as log_b(T).")
    print()


def demo_search_tree():
    """Demonstrate search tree size computation."""
    print("=" * 70)
    print("DEMO 5: Search Tree Leaf Counts")
    print("=" * 70)
    print()

    print(f"{'Branching b':>12} {'Depth d':>10} {'Leaves b^d':>20}")
    print("-" * 45)
    for b in [2, 3, 5, 10]:
        for d in [5, 10, 15, 20]:
            leaves = search_tree_size(b, d)
            print(f"{b:>12} {d:>10} {leaves:>20,}")
    print()


def demo_proof_length_conjecture():
    """Test the n * log(n) proof length conjecture with synthetic data."""
    print("=" * 70)
    print("DEMO 6: Proof Length Growth Conjecture")
    print("=" * 70)
    print()

    # Simulate proof lengths following the conjectured n*log(n) growth
    # with some noise
    import random
    random.seed(42)

    statement_lengths = list(range(4, 104))
    # Simulated proof lengths: C * n * log2(n) + noise
    C = 3.0
    proof_lengths = [
        max(1, int(C * n * math.log2(n) + random.gauss(0, n * 0.5)))
        for n in statement_lengths
    ]

    analysis = proof_length_ratio_analysis(statement_lengths, proof_lengths)
    print("Synthetic data analysis (C=3.0, n=4..103):")
    print(f"  Samples:           {analysis['num_samples']}")
    print(f"  Mean ratio p/(s·log₂s): {analysis['mean_ratio']:.3f}")
    print(f"  Std ratio:         {analysis['std_ratio']:.3f}")
    print(f"  Min ratio:         {analysis['min_ratio']:.3f}")
    print(f"  Max ratio:         {analysis['max_ratio']:.3f}")
    print(f"  Conjecture supported: {analysis['conjecture_supported']}")
    print()

    # Show the verification-search gap for increasing statement lengths
    print(f"{'Stmt len n':>12} {'Est proof len':>15} {'Log factor':>12} {'Info bits':>12}")
    print("-" * 55)
    for n in [4, 8, 16, 32, 64, 128]:
        gap = proof_search_gap(n)
        print(f"{n:>12} {gap['estimated_proof_length']:>15} "
              f"{gap['log_factor']:>12.2f} {gap['information_content_bits']:>12.1f}")
    print()


def demo_proof_density():
    """Demonstrate proof density estimation."""
    print("=" * 70)
    print("DEMO 7: Proof Density and Information Content")
    print("=" * 70)
    print()

    scenarios = [
        ("Easy theorem (many proofs)", 2, 10, 100),
        ("Medium theorem", 2, 20, 50),
        ("Hard theorem (few proofs)", 2, 30, 3),
        ("Very hard (1 proof in huge space)", 2, 50, 1),
    ]

    for name, b, n, num_valid in scenarios:
        result = estimate_proof_density(b, n, num_valid)
        print(f"{name}:")
        print(f"  Search space:  2^{n} = {result['search_space']:,}")
        print(f"  Valid proofs:  {result['num_valid_proofs']}")
        print(f"  Density:       {result['proof_density']:.2e}")
        print(f"  Info content:  {result['information_content_bits']:.1f} bits")
        print(f"  Expected cost: {result['expected_search_cost']:.2e}")
        print()


def main():
    """Run all demonstrations."""
    print()
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║  INFORMATION-THEORETIC LIMITS OF PROOF SEARCH — DEMONSTRATIONS     ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()

    demo_search_space_growth()
    demo_proof_search_instance()
    demo_brute_force_search()
    demo_counting_bounds()
    demo_search_tree()
    demo_proof_length_conjecture()
    demo_proof_density()

    print("=" * 70)
    print("All demonstrations completed successfully.")
    print("=" * 70)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Proof Density and Information Content

Shows how proof density decreases and information content increases
as the search space grows, illustrating why longer proofs are harder to find.
"""

import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def main():
    # Simulate different proof scenarios
    n_values = np.arange(2, 41)

    # Scenario 1: Fixed number of valid proofs (P=10)
    P_fixed = 10
    density_fixed = np.array([P_fixed / (2.0**n) for n in n_values])
    info_fixed = np.array([-math.log2(d) if d > 0 else float('inf')
                           for d in density_fixed])

    # Scenario 2: Proofs grow linearly (P=n)
    density_linear = np.array([n / (2.0**n) for n in n_values])
    info_linear = np.array([-math.log2(d) if d > 0 else float('inf')
                            for d in density_linear])

    # Scenario 3: Proofs grow polynomially (P=n^2)
    density_poly = np.array([n**2 / (2.0**n) for n in n_values])
    info_poly = np.array([-math.log2(d) if d > 0 else float('inf')
                          for d in density_poly])

    fig, axes = plt.subplots(1, 3, figsize=(18, 5))

    # Plot 1: Proof density
    ax1 = axes[0]
    ax1.semilogy(n_values, density_fixed, 'r-o', label='$P=10$ (fixed)',
                 markersize=3, linewidth=1.5)
    ax1.semilogy(n_values, density_linear, 'b-s', label='$P=n$ (linear)',
                 markersize=3, linewidth=1.5)
    ax1.semilogy(n_values, density_poly, 'g-^', label='$P=n^2$ (quadratic)',
                 markersize=3, linewidth=1.5)
    ax1.set_xlabel('Proof Length $n$', fontsize=12)
    ax1.set_ylabel('Proof Density $P/2^n$', fontsize=12)
    ax1.set_title('Proof Density Decay', fontsize=14)
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)

    # Plot 2: Information content
    ax2 = axes[1]
    ax2.plot(n_values, info_fixed, 'r-o', label='$P=10$',
             markersize=3, linewidth=1.5)
    ax2.plot(n_values, info_linear, 'b-s', label='$P=n$',
             markersize=3, linewidth=1.5)
    ax2.plot(n_values, info_poly, 'g-^', label='$P=n^2$',
             markersize=3, linewidth=1.5)
    ax2.plot(n_values, n_values, 'k--', label='$n$ (linear ref)',
             linewidth=1, alpha=0.5)
    ax2.set_xlabel('Proof Length $n$', fontsize=12)
    ax2.set_ylabel('Information Content (bits)', fontsize=12)
    ax2.set_title('Information Content Growth', fontsize=14)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)

    # Plot 3: Expected search cost (1/density)
    ax3 = axes[2]
    expected_cost_fixed = 1.0 / density_fixed
    expected_cost_linear = 1.0 / density_linear
    expected_cost_poly = 1.0 / density_poly

    ax3.semilogy(n_values, expected_cost_fixed, 'r-o', label='$P=10$',
                 markersize=3, linewidth=1.5)
    ax3.semilogy(n_values, expected_cost_linear, 'b-s', label='$P=n$',
                 markersize=3, linewidth=1.5)
    ax3.semilogy(n_values, expected_cost_poly, 'g-^', label='$P=n^2$',
                 markersize=3, linewidth=1.5)
    ax3.set_xlabel('Proof Length $n$', fontsize=12)
    ax3.set_ylabel('Expected Search Cost $1/\\delta$', fontsize=12)
    ax3.set_title('Expected Brute-Force Cost', fontsize=14)
    ax3.legend(fontsize=10)
    ax3.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('proof_density_analysis.png', dpi=150, bbox_inches='tight')
    print("Saved: proof_density_analysis.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Proof Length Growth Conjecture

Tests the conjecture that proof length grows as Theta(n * log(n))
relative to statement length n, using synthetic data and showing
the logarithmic factor.
"""

import math
import random
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def main():
    random.seed(42)

    # Generate synthetic data following the conjectured scaling
    n_values = np.arange(4, 201)
    C = 3.5  # Proportionality constant

    # Simulated proof lengths with realistic noise
    proof_lengths = np.array([
        max(1, int(C * n * math.log2(n) + random.gauss(0, n * 0.3)))
        for n in n_values
    ])

    # Compute ratios
    log_factors = np.array([math.log2(n) for n in n_values])
    ratios = proof_lengths / (n_values * log_factors)

    fig, axes = plt.subplots(2, 2, figsize=(14, 10))

    # Plot 1: Proof length vs statement length
    ax1 = axes[0, 0]
    ax1.scatter(n_values, proof_lengths, s=8, alpha=0.6, color='#3498db',
                label='Simulated proofs')
    n_smooth = np.linspace(4, 200, 100)
    ax1.plot(n_smooth, C * n_smooth * np.log2(n_smooth), 'r-', linewidth=2,
             label=f'$C \\cdot n \\cdot \\log_2(n)$, $C={C}$')
    ax1.plot(n_smooth, n_smooth, 'k--', linewidth=1, alpha=0.5,
             label='$p = n$ (linear)')
    ax1.set_xlabel('Statement Length $n$', fontsize=12)
    ax1.set_ylabel('Proof Length $p$', fontsize=12)
    ax1.set_title('Proof Length vs Statement Length', fontsize=14)
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)

    # Plot 2: The ratio p / (n * log2(n))
    ax2 = axes[0, 1]
    ax2.scatter(n_values, ratios, s=8, alpha=0.6, color='#e74c3c')
    ax2.axhline(y=C, color='black', linestyle='--', linewidth=1.5,
                label=f'Predicted constant $C={C}$')
    ax2.axhline(y=np.mean(ratios), color='blue', linestyle=':',
                linewidth=1.5,
                label=f'Observed mean $\\bar{{C}}={np.mean(ratios):.2f}$')
    ax2.set_xlabel('Statement Length $n$', fontsize=12)
    ax2.set_ylabel('Ratio $p / (n \\cdot \\log_2 n)$', fontsize=12)
    ax2.set_title('Proof Length Ratio (Conjecture Test)', fontsize=14)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)
    ax2.set_ylim(0, 2 * C)

    # Plot 3: Log-log plot to test power law
    ax3 = axes[1, 0]
    ax3.loglog(n_values, proof_lengths, 'o', markersize=3, alpha=0.5,
               color='#2ecc71')
    ax3.loglog(n_smooth, C * n_smooth * np.log2(n_smooth), 'r-',
               linewidth=2, label='$\\Theta(n \\log n)$')
    ax3.loglog(n_smooth, n_smooth, 'b--', linewidth=1.5,
               label='$\\Theta(n)$')
    ax3.loglog(n_smooth, n_smooth ** 2, 'g--', linewidth=1.5,
               label='$\\Theta(n^2)$')
    ax3.set_xlabel('Statement Length $n$ (log scale)', fontsize=12)
    ax3.set_ylabel('Proof Length $p$ (log scale)', fontsize=12)
    ax3.set_title('Log-Log Scaling Analysis', fontsize=14)
    ax3.legend(fontsize=10)
    ax3.grid(True, alpha=0.3)

    # Plot 4: Search complexity implied by proof length
    ax4 = axes[1, 1]
    search_cost_linear = np.array([2.0**n for n in n_values])
    search_cost_nlogn = np.array([2.0**(C * n * math.log2(n))
                                  for n in n_values[:30]])

    ax4.semilogy(n_values, search_cost_linear, 'b-', linewidth=2,
                 label='$2^n$ (linear proofs)')
    ax4.semilogy(n_values[:30], search_cost_nlogn, 'r-', linewidth=2,
                 label='$2^{n \\log n}$ (conjectured)')
    ax4.set_xlabel('Statement Length $n$', fontsize=12)
    ax4.set_ylabel('Search Complexity', fontsize=12)
    ax4.set_title('Search Complexity Growth', fontsize=14)
    ax4.legend(fontsize=10)
    ax4.grid(True, alpha=0.3)

    plt.suptitle('Proof Length Growth Conjecture: $p(n) = \\Theta(n \\cdot \\log n)$',
                 fontsize=16, y=1.02)
    plt.tight_layout()
    plt.savefig('proof_length_conjecture.png', dpi=150, bbox_inches='tight')
    print("Saved: proof_length_conjecture.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: The Verification-Search Gap

Plots the exponential gap between proof verification cost (polynomial)
and proof search cost (exponential) as a function of proof length.
"""

import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def main():
    n_values = np.arange(1, 31)

    # Search space: 2^n
    search_space = np.array([2**n for n in n_values], dtype=float)

    # Verification cost: n^2 (polynomial)
    verif_cost = n_values.astype(float) ** 2

    # Brute-force search cost: 2^n * n^2
    search_cost = search_space * verif_cost

    # Gap: search / verification
    gap = search_space

    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Plot 1: Log-scale comparison
    ax1 = axes[0]
    ax1.semilogy(n_values, search_space, 'r-o', label='Search space $2^n$',
                 markersize=4, linewidth=2)
    ax1.semilogy(n_values, verif_cost, 'b-s', label='Verification $n^2$',
                 markersize=4, linewidth=2)
    ax1.semilogy(n_values, search_cost, 'k--^', label='Brute-force $2^n \\cdot n^2$',
                 markersize=4, linewidth=1.5)
    ax1.set_xlabel('Proof Length $n$', fontsize=12)
    ax1.set_ylabel('Cost (log scale)', fontsize=12)
    ax1.set_title('Verification vs Search Cost', fontsize=14)
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)

    # Plot 2: The gap ratio
    ax2 = axes[1]
    ax2.semilogy(n_values, gap, 'g-D', markersize=4, linewidth=2,
                 color='#e74c3c')
    ax2.fill_between(n_values, 1, gap, alpha=0.15, color='#e74c3c')
    ax2.set_xlabel('Proof Length $n$', fontsize=12)
    ax2.set_ylabel('Search/Verification Ratio (log scale)', fontsize=12)
    ax2.set_title('The Exponential Gap', fontsize=14)
    ax2.grid(True, alpha=0.3)

    # Add annotation
    n_anno = 20
    ax2.annotate(f'Gap at n={n_anno}: {2**n_anno:,}×',
                xy=(n_anno, 2**n_anno),
                xytext=(n_anno - 8, 2**(n_anno + 3)),
                fontsize=10,
                arrowprops=dict(arrowstyle='->', color='black'),
                bbox=dict(boxstyle='round,pad=0.3', facecolor='yellow', alpha=0.7))

    plt.tight_layout()
    plt.savefig('verification_search_gap.png', dpi=150, bbox_inches='tight')
    print("Saved: verification_search_gap.png")


if __name__ == "__main__":
    main()
