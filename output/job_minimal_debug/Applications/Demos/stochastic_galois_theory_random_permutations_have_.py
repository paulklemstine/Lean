"""
Stochastic Galois Theory: Numerical Demonstrations

Demonstrates the key results:
1. Discriminant uniformity theorem (all fibers have size p)
2. Quadratic splitting classification
3. Galois genericity for quadratics: P(S_2) → 1/2
4. Cubic irreducible counts via necklace formula
"""

from algorithms import (
    disc_fiber_distribution,
    quadratic_splitting_classification,
    galois_genericity_sequence,
    irreducible_count_degree_n,
    galois_group_distribution,
    verify_disc_uniformity,
)


def demo_discriminant_uniformity():
    """Demonstrate that all discriminant fibers have cardinality p."""
    print("=" * 60)
    print("DEMO 1: Discriminant Uniformity Theorem")
    print("=" * 60)
    print()
    print("For monic quadratics x² + bx + c over F_p,")
    print("the discriminant map (b,c) ↦ b² - 4c has uniform fibers.")
    print()

    for p in [3, 5, 7, 11, 13, 17, 19, 23]:
        dist = disc_fiber_distribution(p)
        all_equal = all(v == p for v in dist.values())
        status = "✓ UNIFORM" if all_equal else "✗ NOT UNIFORM"
        print(f"  p = {p:2d}: fibers = {list(dist.values())[:5]}... "
              f"all = {p}? {status}")

    print()
    print("  THEOREM: For all odd primes p, every fiber has cardinality p.")
    print("  This is proved formally in Lean 4.")
    print()


def demo_quadratic_classification():
    """Demonstrate the three-way classification of quadratics."""
    print("=" * 60)
    print("DEMO 2: Quadratic Splitting Classification")
    print("=" * 60)
    print()
    print("Every monic quadratic over F_p falls into exactly one class:")
    print("  (A) disc = 0      → double root, non-separable")
    print("  (B) disc = square  → two distinct roots, Gal = {e}")
    print("  (C) disc = non-sq  → irreducible, Gal = Z/2Z = S_2")
    print()

    print(f"  {'p':>3s} | {'Total':>6s} | {'(A) disc=0':>10s} | "
          f"{'(B) square':>10s} | {'(C) non-sq':>10s} | "
          f"{'P(S_2)':>8s} | {'(p-1)/2p':>8s}")
    print("  " + "-" * 75)

    for p in [3, 5, 7, 11, 13, 17, 19, 23, 29, 31]:
        cls = quadratic_splitting_classification(p)
        total = p * p
        prob_s2 = cls['nonsquare_disc'] / total
        theoretical = (p - 1) / (2 * p)
        print(f"  {p:3d} | {total:6d} | {cls['zero_disc']:10d} | "
              f"{cls['square_disc']:10d} | {cls['nonsquare_disc']:10d} | "
              f"{prob_s2:8.4f} | {theoretical:8.4f}")

    print()
    print("  KEY INSIGHT: P(Gal = S_2) = (p-1)/(2p) → 1/2, NOT → 1!")
    print("  Over finite fields, the 'generic' quadratic is split with prob 1/2.")
    print()


def demo_galois_genericity():
    """Show P(S_2) approaching 1/2 as p grows."""
    print("=" * 60)
    print("DEMO 3: Galois Genericity — Approach to 1/2")
    print("=" * 60)
    print()

    results = galois_genericity_sequence(100)
    for p, prob in results:
        bar_len = int(prob * 60)
        bar = "█" * bar_len + "░" * (30 - bar_len)
        error = abs(prob - 0.5)
        print(f"  p={p:3d}: P(S_2)={prob:.4f} {bar} err={error:.4f}")

    print()
    print(f"  Theoretical limit: P(S_2) → 1/2 as p → ∞")
    print(f"  Error ~ 1/(2p), consistent with |P - 1/2| = 1/(2p)")
    print()


def demo_cubic_counts():
    """Verify the necklace formula for irreducible cubics."""
    print("=" * 60)
    print("DEMO 4: Irreducible Cubic Counts (Necklace Formula)")
    print("=" * 60)
    print()
    print("  The number of monic irreducible cubics over F_p is (p³-p)/3.")
    print("  This is the Frobenius-Möbius inversion formula.")
    print()

    print(f"  {'p':>3s} | {'Total p³':>8s} | {'Irred':>6s} | "
          f"{'(p³-p)/3':>8s} | {'Frac':>6s} | {'~1/3':>6s}")
    print("  " + "-" * 55)

    for p in [2, 3, 5, 7, 11, 13, 17, 19, 23]:
        total = p ** 3
        count = irreducible_count_degree_n(3, p)
        formula = (p**3 - p) // 3
        frac = count / total
        print(f"  {p:3d} | {total:8d} | {count:6d} | "
              f"{formula:8d} | {frac:6.4f} | {1/3:6.4f}")

    print()
    print("  CONJECTURE: Fraction of irreducible degree-n polys → 1/n as p → ∞")
    print()


def demo_galois_groups_small():
    """Show full Galois group distribution for small cases."""
    print("=" * 60)
    print("DEMO 5: Full Galois Group Distribution (Small Cases)")
    print("=" * 60)
    print()

    for n in [2, 3]:
        for p in [3, 5, 7]:
            print(f"  Degree {n} over F_{p}:")
            dist = galois_group_distribution(n, p)
            for group, prob in sorted(dist.items(), key=lambda x: -x[1]):
                bar = "█" * int(prob * 40)
                print(f"    {group:30s}: {prob:.4f} {bar}")
            print()


if __name__ == "__main__":
    demo_discriminant_uniformity()
    demo_quadratic_classification()
    demo_galois_genericity()
    demo_cubic_counts()
    demo_galois_groups_small()


"""
Visualization: Discriminant Fiber Uniformity

Shows that all fibers of the discriminant map (b,c) -> b^2 - 4c over F_p
have the same cardinality p.
"""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def is_prime(n):
    if n < 2:
        return False
    if n < 4:
        return True
    if n % 2 == 0 or n % 3 == 0:
        return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i + 2) == 0:
            return False
        i += 6
    return True


def disc_fiber_sizes(p):
    """Compute all fiber sizes of the discriminant map over F_p."""
    counts = [0] * p
    for b in range(p):
        for c in range(p):
            d = (b * b - 4 * c) % p
            counts[d] += 1
    return counts


def plot_disc_uniformity():
    primes = [p for p in range(3, 30) if is_prime(p)]

    fig, axes = plt.subplots(2, 4, figsize=(16, 8))
    fig.suptitle('Discriminant Fiber Uniformity: |{(b,c) : b² - 4c ≡ d}| = p for all d',
                 fontsize=14, fontweight='bold')

    for idx, p in enumerate(primes[:8]):
        ax = axes[idx // 4, idx % 4]
        sizes = disc_fiber_sizes(p)
        colors = ['#2ecc71' if s == p else '#e74c3c' for s in sizes]
        ax.bar(range(p), sizes, color=colors, alpha=0.8, edgecolor='black', linewidth=0.5)
        ax.axhline(y=p, color='red', linestyle='--', alpha=0.5, label=f'Expected = {p}')
        ax.set_title(f'F_{p}', fontsize=12)
        ax.set_xlabel('d')
        ax.set_ylabel('|fiber|')
        ax.set_ylim(0, p * 1.3)

    plt.tight_layout()
    plt.savefig('disc_uniformity.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved disc_uniformity.png")


def plot_galois_convergence():
    """Plot P(S_2) = (p-1)/(2p) converging to 1/2."""
    primes = [p for p in range(3, 200) if is_prime(p)]
    probs = [(p - 1) / (2 * p) for p in primes]

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    # Left: P(S_2) vs p
    ax1.scatter(primes, probs, s=20, color='#3498db', alpha=0.7, label='P(Gal = S₂)')
    ax1.axhline(y=0.5, color='red', linestyle='--', alpha=0.7, label='Limit = 1/2')
    ax1.set_xlabel('Prime p', fontsize=12)
    ax1.set_ylabel('P(Gal = S₂)', fontsize=12)
    ax1.set_title('Galois Genericity for Quadratics over F_p', fontsize=13)
    ax1.legend(fontsize=10)
    ax1.set_ylim(0.3, 0.55)

    # Right: Error |P - 1/2| vs 1/p
    errors = [abs(prob - 0.5) for prob in probs]
    inv_p = [1 / p for p in primes]
    ax2.scatter(inv_p, errors, s=20, color='#e74c3c', alpha=0.7, label='|P(S₂) - 1/2|')
    # Theoretical line: error = 1/(2p)
    x_line = np.linspace(0.005, 0.35, 100)
    ax2.plot(x_line, x_line / 2, 'k--', alpha=0.5, label='y = 1/(2p)')
    ax2.set_xlabel('1/p', fontsize=12)
    ax2.set_ylabel('|P(S₂) - 1/2|', fontsize=12)
    ax2.set_title('Error Decay: Exact Match with 1/(2p)', fontsize=13)
    ax2.legend(fontsize=10)

    plt.tight_layout()
    plt.savefig('galois_convergence.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved galois_convergence.png")


def plot_splitting_types():
    """Plot splitting type distribution for cubics."""
    primes = [p for p in range(3, 50) if is_prime(p)]

    irred_fracs = []
    for p in primes:
        irred = (p**3 - p) / 3
        total = p**3
        irred_fracs.append(irred / total)

    fig, ax = plt.subplots(figsize=(10, 5))
    ax.scatter(primes, irred_fracs, s=40, color='#9b59b6', alpha=0.8,
               label='Fraction irreducible cubics')
    ax.axhline(y=1/3, color='red', linestyle='--', alpha=0.7, label='Limit = 1/3')
    ax.set_xlabel('Prime p', fontsize=12)
    ax.set_ylabel('Fraction irreducible', fontsize=12)
    ax.set_title('Irreducible Cubic Fraction → 1/3 (Frobenius Correspondence)', fontsize=13)
    ax.legend(fontsize=11)
    ax.set_ylim(0.2, 0.38)

    plt.tight_layout()
    plt.savefig('splitting_types.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved splitting_types.png")


if __name__ == "__main__":
    plot_disc_uniformity()
    plot_galois_convergence()
    plot_splitting_types()
