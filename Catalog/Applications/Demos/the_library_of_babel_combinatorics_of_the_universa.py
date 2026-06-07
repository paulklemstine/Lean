#!/usr/bin/env python3
"""
Library of Babel: Numerical Demonstrations

Demonstrates key results from the formalized theory of universal libraries,
including redundancy profiles, collision bounds, and information capacity.
"""

import math
from itertools import product


def library_size(A: int, L: int) -> int:
    """Total number of volumes in the Library of Babel."""
    return A ** L


def redundancy_number(A: int, L: int, r: int) -> int:
    """
    Number of volumes within Hamming distance r of any fixed center.
    Equal to sum_{i=0}^{r} C(L,i) * (A-1)^i.
    """
    total = 0
    for i in range(min(r, L) + 1):
        total += math.comb(L, i) * (A - 1) ** i
    return total


def collision_lower_bound(A: int, L: int, D: int) -> int:
    """Minimum collision number for any D-coloring of the library."""
    lib = library_size(A, L)
    return (lib + D - 1) // D


def hamming_distance(v: tuple, w: tuple) -> int:
    """Hamming distance between two volumes."""
    return sum(1 for a, b in zip(v, w) if a != b)


def information_capacity_brute(A: int, L: int, d: int) -> int:
    """Brute-force computation of information capacity for small libraries."""
    volumes = list(product(range(A), repeat=L))

    def is_code(subset):
        for i, v in enumerate(subset):
            for j, w in enumerate(subset):
                if i < j and hamming_distance(v, w) < d:
                    return False
        return True

    # Greedy algorithm for maximum code
    best = 0
    # For small cases, try greedy
    code = []
    for v in volumes:
        if all(hamming_distance(v, c) >= d for c in code):
            code.append(v)
    return len(code)


def main():
    print("=" * 70)
    print("THE LIBRARY OF BABEL: NUMERICAL DEMONSTRATIONS")
    print("=" * 70)

    # --- Demo 1: Library Sizes ---
    print("\n📚 Demo 1: Library Sizes")
    print("-" * 40)
    for A, L in [(2, 4), (3, 3), (4, 4), (25, 10), (25, 100)]:
        size = library_size(A, L)
        print(f"  Alphabet={A}, Length={L}: {size:,} volumes"
              + (f" ≈ 10^{math.log10(size):.1f}" if size > 10**6 else ""))

    # Borges' actual library
    print(f"\n  Borges' Library (A=25, L=1312000):")
    log_size = 1312000 * math.log10(25)
    print(f"    ≈ 10^{log_size:,.0f} volumes")
    print(f"    (Compare: atoms in observable universe ≈ 10^80)")

    # --- Demo 2: Redundancy Profile ---
    print("\n📊 Demo 2: Redundancy Profile (A=4, L=8)")
    print("-" * 40)
    A, L = 4, 8
    lib = library_size(A, L)
    print(f"  Library size: {lib:,}")
    for r in range(L + 1):
        rn = redundancy_number(A, L, r)
        pct = 100 * rn / lib
        bar = "█" * int(pct / 2)
        print(f"  r={r}: {rn:>8,} ({pct:6.2f}%) {bar}")
    print(f"\n  Key insight: redundancy_number is the SAME for every center volume")
    print(f"  (proved as redundancy_profile_uniform)")

    # --- Demo 3: Pigeonhole Collision ---
    print("\n🎯 Demo 3: Pigeonhole Collision Bounds")
    print("-" * 40)
    A, L = 3, 5
    lib = library_size(A, L)
    print(f"  Library: A={A}, L={L}, size={lib}")
    for D in [1, 3, 10, 50, 100, 243]:
        if D < lib:
            bound = collision_lower_bound(A, L, D)
            print(f"  {D:>4} colors → some class has ≥ {bound} volumes")

    # --- Demo 4: Information Capacity (Hamming Bound) ---
    print("\n📡 Demo 4: Information Capacity (Hamming Bound)")
    print("-" * 40)
    for A, L, d in [(2, 7, 3), (2, 8, 3), (3, 4, 3), (4, 4, 3)]:
        lib = library_size(A, L)
        ball = redundancy_number(A, L, (d - 1) // 2)
        hamming_bound = lib // ball
        actual = information_capacity_brute(A, L, d)
        print(f"  A={A}, L={L}, d={d}: Hamming bound={hamming_bound}, "
              f"actual capacity≥{actual}, ball_size={ball}")

    # --- Demo 5: Sublibrary Collision ---
    print("\n💥 Demo 5: Sublibrary Collision Threshold")
    print("-" * 40)
    A, L = 3, 4
    threshold = A ** (L - 1)
    print(f"  A={A}, L={L}: Any sublibrary of size > {threshold} has")
    print(f"  two volumes at Hamming distance ≤ 1")

    # Verify with brute force
    volumes = list(product(range(A), repeat=L))
    import random
    random.seed(42)
    for trial in range(5):
        size = threshold + 1 + trial * 5
        sample = random.sample(volumes, min(size, len(volumes)))
        found = False
        for i, v in enumerate(sample):
            for j, w in enumerate(sample):
                if i < j and hamming_distance(v, w) <= 1:
                    found = True
                    break
            if found:
                break
        print(f"  Trial {trial+1} (size={len(sample)}): "
              f"Close pair found = {found}")

    # --- Demo 6: Alphabet Reduction ---
    print("\n🔤 Demo 6: Alphabet Reduction Effect")
    print("-" * 40)
    for L in [5, 10, 20, 50]:
        A = 25
        full = A ** L
        reduced = (A - 1) ** L
        ratio = reduced / full
        print(f"  L={L}: Removing 1 symbol reduces library to "
              f"{ratio:.6f} of original ({100*ratio:.2f}%)")

    # --- Demo 7: Fixed Point Theorem ---
    print("\n🔄 Demo 7: Babel Fixed Point Theorem")
    print("-" * 40)
    print("  For any encoding E: Volume → (Volume → Volume),")
    print("  if E is surjective, some volume v must satisfy E(v)(v) = v.")
    print("  (Self-reference is inescapable in a universal library)")
    A, L = 2, 3
    lib = library_size(A, L)
    endos = lib ** lib
    print(f"\n  A={A}, L={L}: {lib} volumes, {endos} endomorphisms")
    print(f"  Surjection impossible if all E(v)(v) ≠ v")

    print("\n" + "=" * 70)
    print("All demonstrations correspond to formally verified Lean 4 theorems.")
    print("=" * 70)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Redundancy Profile of the Library of Babel

Shows how the redundancy number grows with Hamming radius for different
library parameters, demonstrating the transition from isolation to universality.
"""

import math

def redundancy_number(A, L, r):
    return sum(math.comb(L, i) * (A - 1) ** i for i in range(min(r, L) + 1))

def main():
    try:
        import matplotlib.pyplot as plt
        import matplotlib
        matplotlib.use('Agg')
    except ImportError:
        print("matplotlib not available, printing text output instead")
        for A, L in [(2, 16), (4, 16), (25, 16)]:
            lib = A ** L
            print(f"\nA={A}, L={L}, Library size={lib}")
            for r in range(L + 1):
                rn = redundancy_number(A, L, r)
                print(f"  r={r}: {rn} ({100*rn/lib:.4f}%)")
        return

    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    configs = [(2, 16, 'Binary'), (4, 16, 'Quaternary'), (25, 16, 'Babel (25)')]

    for ax, (A, L, title) in zip(axes, configs):
        radii = list(range(L + 1))
        lib = A ** L
        profile = [redundancy_number(A, L, r) / lib for r in radii]

        ax.plot(radii, profile, 'b-o', markersize=4, linewidth=2)
        ax.fill_between(radii, profile, alpha=0.2)
        ax.set_xlabel('Hamming Radius r')
        ax.set_ylabel('Fraction of Library')
        ax.set_title(f'{title} Library (A={A}, L={L})')
        ax.set_ylim(0, 1.05)
        ax.axhline(y=0.5, color='red', linestyle='--', alpha=0.5, label='50%')
        ax.legend()
        ax.grid(True, alpha=0.3)

    plt.suptitle('Redundancy Profile: From Isolation to Universality',
                 fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('redundancy_profile.png', dpi=150, bbox_inches='tight')
    print("Saved redundancy_profile.png")

if __name__ == "__main__":
    main()
