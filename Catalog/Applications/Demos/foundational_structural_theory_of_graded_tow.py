#!/usr/bin/env python3
"""
Demo: Algebraic Graded Tower Theory

Demonstrates the key theorems from the algebraic graded tower theory:
1. Defect quantization: which defect values are achievable for a given group order
2. Kernel-range factorization examples
3. Prime tower rigidity illustration
4. Defect-index identity verification
"""

from typing import List, Tuple, Set
from math import gcd


def divisors(n: int) -> List[int]:
    """Return all divisors of n in sorted order."""
    if n <= 0:
        return []
    divs = []
    for i in range(1, n + 1):
        if n % i == 0:
            divs.append(i)
    return divs


def achievable_defects(group_order: int) -> Set[int]:
    """
    Compute the set of achievable defects for a group of given order.
    By the Defect Quantization Theorem, the achievable defects are
    {group_order - d : d | group_order}.
    """
    return {group_order - d for d in divisors(group_order)}


def kernel_range_factorization(domain_card: int, kernel_card: int) -> Tuple[int, int]:
    """
    Given domain cardinality and kernel cardinality, compute range cardinality.
    By the Kernel-Range Factorization: card(domain) = card(kernel) * card(range)
    Returns (range_card, defect) where defect depends on codomain size.
    """
    if domain_card % kernel_card != 0:
        raise ValueError(f"Kernel card {kernel_card} does not divide domain card {domain_card}")
    range_card = domain_card // kernel_card
    return range_card


def defect_index_identity(codomain_card: int, image_card: int) -> Tuple[int, int, int]:
    """
    Verify the Defect-Index Identity: defect = (index - 1) * card(image)
    Returns (defect, index, verification)
    """
    if codomain_card % image_card != 0:
        raise ValueError(f"Image card {image_card} does not divide codomain card {codomain_card}")
    index = codomain_card // image_card
    defect = codomain_card - image_card
    identity_rhs = (index - 1) * image_card
    return defect, index, defect == identity_rhs


def is_prime(n: int) -> bool:
    """Check if n is prime."""
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


def demonstrate_prime_rigidity(level_cards: List[int]) -> None:
    """
    Demonstrate the Prime Tower Rigidity Theorem:
    If all level cardinalities are prime and transitions are injective,
    all cardinalities must be equal (tower is trivial).
    """
    print("\n=== Prime Tower Rigidity Demo ===")
    print(f"Level cardinalities: {level_cards}")
    all_prime = all(is_prime(c) for c in level_cards)
    print(f"All prime: {all_prime}")

    if all_prime:
        # Check divisibility chain requirement
        for i in range(len(level_cards) - 1):
            divides = level_cards[i + 1] % level_cards[i] == 0
            print(f"  Level {i} ({level_cards[i]}) | Level {i+1} ({level_cards[i+1]}): {divides}")
            if divides:
                # For primes, p | q implies p = q
                print(f"    Since {level_cards[i]} and {level_cards[i+1]} are prime, "
                      f"divisibility implies equality: {level_cards[i] == level_cards[i+1]}")

        if len(set(level_cards)) == 1:
            print("  → Tower is trivial (all levels equal) ✓")
        else:
            print("  → Injective transitions impossible (contradicts divisibility) ✗")


def main():
    print("=" * 60)
    print("ALGEBRAIC GRADED TOWER THEORY - DEMONSTRATION")
    print("=" * 60)

    # 1. Defect Quantization
    print("\n=== Defect Quantization Demo ===")
    for n in [6, 12, 24, 30, 60]:
        defects = sorted(achievable_defects(n))
        divs = divisors(n)
        print(f"\nGroup order {n}:")
        print(f"  Divisors: {divs}")
        print(f"  Achievable defects: {defects}")
        print(f"  Number of achievable values: {len(defects)} / {n + 1} possible")
        print(f"  Fraction eliminated: {1 - len(defects)/(n+1):.1%}")

    # 2. Kernel-Range Factorization
    print("\n\n=== Kernel-Range Factorization Demo ===")
    examples = [
        (12, 3, 24),  # Z/12 -> Z/24 with kernel of size 3
        (24, 4, 24),  # Z/24 -> Z/24 with kernel of size 4
        (60, 1, 60),  # A_5 -> A_5 injective
        (60, 60, 60), # A_5 -> A_5 trivial
    ]
    for domain, kernel, codomain in examples:
        range_card = kernel_range_factorization(domain, kernel)
        defect = codomain - range_card
        print(f"\n  Domain: {domain}, Kernel: {kernel}, Codomain: {codomain}")
        print(f"  Factorization: {domain} = {kernel} × {range_card} ✓")
        print(f"  Image size: {range_card}")
        print(f"  Defect: {codomain} - {range_card} = {defect}")
        print(f"  Image divides codomain: {codomain % range_card == 0} (Lagrange) ✓")

    # 3. Defect-Index Identity
    print("\n\n=== Defect-Index Identity Demo ===")
    for codomain, image in [(12, 4), (24, 6), (60, 12), (60, 1), (60, 60)]:
        defect, index, verified = defect_index_identity(codomain, image)
        print(f"\n  Codomain: {codomain}, Image: {image}")
        print(f"  Index [G:H] = {codomain}/{image} = {index}")
        print(f"  Defect = {defect}")
        print(f"  (index - 1) × image = ({index} - 1) × {image} = {(index-1)*image}")
        print(f"  Identity verified: {verified} ✓")

    # 4. Prime Tower Rigidity
    demonstrate_prime_rigidity([5, 5, 5, 5])
    demonstrate_prime_rigidity([3, 5, 7, 11])
    demonstrate_prime_rigidity([7, 7, 7])

    # 5. Divisibility chain for injective towers
    print("\n\n=== Injective Tower Divisibility Chain ===")
    tower_cards = [2, 6, 24, 120, 720]
    print(f"Level cardinalities: {tower_cards}")
    for i in range(len(tower_cards) - 1):
        divides = tower_cards[i + 1] % tower_cards[i] == 0
        quotient = tower_cards[i + 1] // tower_cards[i] if divides else None
        print(f"  {tower_cards[i]} | {tower_cards[i+1]}: {divides}"
              f" (quotient = {quotient})")
    print("  This is the factorial tower: 2!, 3!, 4!, 5!, 6!")
    print("  Consistent with an injective algebraic tower ✓")

    # 6. Non-example: cardinalities that cannot form an injective algebraic tower
    print("\n\n=== Non-example: Impossible Injective Tower ===")
    bad_tower = [6, 10, 15]
    print(f"Level cardinalities: {bad_tower}")
    for i in range(len(bad_tower) - 1):
        divides = bad_tower[i + 1] % bad_tower[i] == 0
        print(f"  {bad_tower[i]} | {bad_tower[i+1]}: {divides}")
    print("  6 does not divide 10, so no injective group hom Z/6 -> Z/10 exists")
    print("  This cardinality sequence is IMPOSSIBLE for an injective algebraic tower ✗")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Defect Quantization Spectrum

Shows how group structure constrains achievable defect values
compared to the unrestricted set-theoretic case.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def divisors(n: int) -> list:
    """Return all divisors of n."""
    divs = []
    for i in range(1, n + 1):
        if n % i == 0:
            divs.append(i)
    return divs


def achievable_defects(n: int) -> set:
    """Compute achievable defect values for group order n."""
    return {n - d for d in divisors(n)}


def main():
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    fig.suptitle("Defect Quantization in Algebraic Graded Towers",
                 fontsize=16, fontweight='bold')

    orders = [12, 24, 30, 60]
    for ax, n in zip(axes.flat, orders):
        achievable = achievable_defects(n)
        all_vals = set(range(n + 1))
        forbidden = all_vals - achievable

        # Plot
        for v in range(n + 1):
            if v in achievable:
                ax.bar(v, 1, color='#2196F3', alpha=0.8, width=0.8)
            else:
                ax.bar(v, 1, color='#FFCDD2', alpha=0.4, width=0.8)

        ax.set_title(f"Group Order = {n}", fontsize=13, fontweight='bold')
        ax.set_xlabel("Defect Value")
        ax.set_ylabel("")
        ax.set_yticks([])
        ax.set_xlim(-0.5, n + 0.5)

        # Annotation
        pct = len(forbidden) / (n + 1) * 100
        ax.text(0.98, 0.95,
                f"{len(achievable)} achievable / {n+1} total\n"
                f"{pct:.0f}% eliminated by\nLagrange's theorem",
                transform=ax.transAxes, ha='right', va='top',
                fontsize=10, bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.7))

        # Mark divisors
        divs = divisors(n)
        div_text = ", ".join(str(d) for d in divs)
        ax.text(0.02, 0.05, f"Divisors of {n}: {div_text}",
                transform=ax.transAxes, ha='left', va='bottom',
                fontsize=8, style='italic', color='gray')

    # Legend
    blue_patch = mpatches.Patch(color='#2196F3', alpha=0.8, label='Achievable (algebraic tower)')
    red_patch = mpatches.Patch(color='#FFCDD2', alpha=0.4, label='Forbidden by Lagrange')
    fig.legend(handles=[blue_patch, red_patch], loc='lower center',
              ncol=2, fontsize=12, frameon=True)

    plt.tight_layout(rect=[0, 0.05, 1, 0.95])
    plt.savefig("defect_spectrum.png", dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved defect_spectrum.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Divisibility Chains in Algebraic Towers

Shows how injective group homomorphisms force divisibility constraints
on level cardinalities, compared to arbitrary injective functions.
"""

import matplotlib.pyplot as plt
import numpy as np


def is_prime(n: int) -> bool:
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


def main():
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))
    fig.suptitle("Cardinality Constraints: Set-Theoretic vs Algebraic Towers",
                 fontsize=14, fontweight='bold')

    # Left: Set-theoretic (any sequence with a_i <= a_{i+1})
    ax1.set_title("Set-Theoretic Tower\n(Injective maps: any a₀ ≤ a₁ ≤ ... ≤ aₙ)", fontsize=11)
    np.random.seed(42)
    for _ in range(8):
        start = np.random.randint(2, 10)
        cards = [start]
        for j in range(4):
            cards.append(cards[-1] + np.random.randint(0, 8))
        ax1.plot(range(5), cards, 'o-', alpha=0.6, markersize=8)

    ax1.set_xlabel("Tower Level", fontsize=12)
    ax1.set_ylabel("Level Cardinality", fontsize=12)
    ax1.set_xticks(range(5))
    ax1.grid(True, alpha=0.3)

    # Right: Algebraic (divisibility chain: a_i | a_{i+1})
    ax2.set_title("Algebraic Tower\n(Injective homs: a₀ | a₁ | ... | aₙ)", fontsize=11)

    algebraic_towers = [
        ([2, 4, 8, 16, 32], "Powers of 2"),
        ([3, 6, 12, 24, 48], "×2 chain from 3"),
        ([5, 10, 30, 60, 120], "Mixed chain from 5"),
        ([1, 2, 6, 24, 120], "Factorial tower"),
        ([7, 7, 7, 7, 7], "Constant prime tower"),
        ([6, 6, 12, 12, 24], "Step growth"),
    ]

    colors = plt.cm.Set2(np.linspace(0, 1, len(algebraic_towers)))
    for (cards, label), color in zip(algebraic_towers, colors):
        ax2.plot(range(5), cards, 'o-', alpha=0.8, markersize=8,
                label=label, color=color, linewidth=2)

    ax2.set_xlabel("Tower Level", fontsize=12)
    ax2.set_ylabel("Level Cardinality", fontsize=12)
    ax2.set_xticks(range(5))
    ax2.legend(fontsize=9, loc='upper left')
    ax2.grid(True, alpha=0.3)

    # Highlight impossible sequences
    impossible = [
        [6, 10, 15, 35, 77],
        [4, 9, 25, 49, 121],
    ]
    for cards in impossible:
        ax2.plot(range(5), cards, 'x--', alpha=0.4, markersize=10,
                color='red', linewidth=1.5)
    ax2.text(0.98, 0.05, "× = impossible\n(divisibility fails)",
            transform=ax2.transAxes, ha='right', va='bottom',
            fontsize=9, color='red', style='italic')

    plt.tight_layout()
    plt.savefig("divisibility_chain.png", dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved divisibility_chain.png")


if __name__ == "__main__":
    main()
