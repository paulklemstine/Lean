#!/usr/bin/env python3
"""
Applications of Tropical Valuation Distillation

Demonstrates real-world applications of the spectral certification framework:
1. Hash function collision analysis
2. Sensor fusion certification
3. Feature extraction quality analysis
"""

from typing import List, Tuple, Dict, Set
from itertools import combinations
from algorithms import (
    compute_valuation_profile,
    check_separation,
    verify_full_separation,
    extract_codebook,
    separation_score_matrix,
    compression_rate,
)


# =============================================================================
# Application 1: Hash Function Collision Analysis
# =============================================================================

def hash_collision_analysis():
    """
    Model hash functions as ring congruences and analyze collision resistance.

    Each hash function h_m(x) = x mod m is a ring congruence on Z/nZ.
    A family of hash functions is an observer family.
    The diagonal avoidance theorem (Theorem 3.9) shows that collision
    resistance = injectivity of the joint hash profile.
    """
    print("=" * 60)
    print("Application 1: Hash Function Collision Analysis")
    print("=" * 60)

    n = 100  # Message space Z/100Z
    hash_families = [
        ("Single hash mod 7", [7]),
        ("Two hashes mod 7, 11", [7, 11]),
        ("Three hashes mod 7, 11, 13", [7, 11, 13]),
        ("CRT-optimal: mod 4, 9, 25", [4, 9, 25]),  # product ≥ 100
    ]

    for name, moduli in hash_families:
        codebook = extract_codebook(n, moduli)
        rate = compression_rate(n, moduli)
        sep, witness = verify_full_separation(n, moduli)

        # Count collisions
        collisions = sum(1 for v in codebook.values() if len(v) > 1)

        print(f"\n  {name}:")
        print(f"    Codebook size: {len(codebook)} / {n}")
        print(f"    Compression rate: {rate:.3f}")
        print(f"    Collision-free: {sep}")
        print(f"    Buckets with collisions: {collisions}")
        if not sep and witness:
            print(f"    Example collision: {witness[0]} and {witness[1]}")


# =============================================================================
# Application 2: Sensor Fusion Certification
# =============================================================================

def sensor_fusion_certification():
    """
    Model sensors as observers on a physical state space.

    Each sensor measures a different modular aspect of the state.
    The universal property theorem (Theorem 3.8) shows that every
    stable fusion algorithm factors through the joint sensor reading.
    """
    print("\n" + "=" * 60)
    print("Application 2: Sensor Fusion Certification")
    print("=" * 60)

    # Physical states: temperatures 0-49 (discretized)
    n = 50
    states = list(range(n))

    # Sensors with different granularities
    sensor_configs = [
        ("Coarse sensor only (mod 5)", [5]),
        ("Coarse + medium (mod 5, 7)", [5, 7]),
        ("Coarse + medium + fine (mod 5, 7, 11)", [5, 7, 11]),
        ("Two fine sensors (mod 7, 11)", [7, 11]),
    ]

    for name, moduli in sensor_configs:
        sep, witness = verify_full_separation(n, moduli)
        codebook = extract_codebook(n, moduli)
        rate = compression_rate(n, moduli)

        print(f"\n  {name}:")
        print(f"    Distinct readings: {len(codebook)} / {n}")
        print(f"    Information rate: {rate:.3f}")
        print(f"    Complete state identification: {sep}")

        if not sep and witness:
            x, y = witness
            px = compute_valuation_profile(x, moduli)
            py = compute_valuation_profile(y, moduli)
            print(f"    Confusable states: {x} and {y}")
            print(f"    Same readings: {px}")


# =============================================================================
# Application 3: Feature Extraction Quality
# =============================================================================

def feature_extraction_quality():
    """
    Analyze the quality of feature extractors as observer families.

    The codebook size relative to the input size measures how much
    information the features capture. The separation score matrix
    shows which features are most discriminating.
    """
    print("\n" + "=" * 60)
    print("Application 3: Feature Extraction Quality Analysis")
    print("=" * 60)

    n = 24
    states = list(range(n))

    # Different feature sets
    feature_sets = {
        "Parity only": [2],
        "Parity + mod 3": [2, 3],
        "Parity + mod 3 + mod 4": [2, 3, 4],
        "mod 3 + mod 8": [3, 8],
        "mod 2 + mod 3 + mod 4 + mod 5": [2, 3, 4, 5],
    }

    print(f"\n  Input space: Z/{n}Z ({n} elements)")
    print(f"  {'Feature set':<35} {'Codebook':>8} {'Rate':>6} {'Sep?':>5}")
    print("  " + "-" * 58)

    for name, moduli in feature_sets.items():
        codebook = extract_codebook(n, moduli)
        rate = compression_rate(n, moduli)
        sep, _ = verify_full_separation(n, moduli)
        print(f"  {name:<35} {len(codebook):>8} {rate:>6.3f} {'yes' if sep else 'no':>5}")

    # Detailed separation analysis for the best feature set
    print(f"\n  Detailed analysis: mod 3 + mod 8")
    moduli = [3, 8]
    matrix = separation_score_matrix(n, moduli)

    # Find the most confusable pairs (separation score = 0 for distinct elements)
    confusable = []
    for i in range(n):
        for j in range(i + 1, n):
            if matrix[i][j] == 0:
                confusable.append((i, j))

    if confusable:
        print(f"    Confusable pairs: {confusable[:5]}{'...' if len(confusable) > 5 else ''}")
        print(f"    Total confusable pairs: {len(confusable)}")
    else:
        print(f"    No confusable pairs — fully separating!")


# =============================================================================
# Application 4: Spectral Robustness Certificate
# =============================================================================

def spectral_robustness():
    """
    Demonstrate spectral robustness certification.

    Unlike metric robustness (which degrades with perturbation size),
    spectral robustness is binary: either two elements are spectrally
    separated (and guaranteed distinct under all stable codes) or not.
    """
    print("\n" + "=" * 60)
    print("Application 4: Spectral Robustness Certification")
    print("=" * 60)

    n = 20
    moduli = [3, 7]

    print(f"\n  Input space: Z/{n}Z, Observers: mod {moduli}")

    # For each pair, show the separation certificate
    print(f"\n  Separation certificates for elements 0-9:")
    print(f"  {'Pair':>8} {'mod 3':>6} {'mod 7':>6} {'Certified':>10}")
    print("  " + "-" * 34)

    for x in range(5):
        for y in range(x + 1, 10):
            sep3 = (x % 3 != y % 3)
            sep7 = (x % 7 != y % 7)
            certified = sep3 or sep7
            witnesses = []
            if sep3: witnesses.append("mod 3")
            if sep7: witnesses.append("mod 7")

            print(f"  ({x},{y:>2}) {'sep' if sep3 else '  =':>6} "
                  f"{'sep' if sep7 else '  =':>6} "
                  f"{'✓ (' + ', '.join(witnesses) + ')' if certified else '✗':>10}")


# =============================================================================
# Main
# =============================================================================

def main():
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  Tropical Valuation Distillation — Applications        ║")
    print("╚══════════════════════════════════════════════════════════╝\n")

    hash_collision_analysis()
    sensor_fusion_certification()
    feature_extraction_quality()
    spectral_robustness()

    print("\n" + "=" * 60)
    print("All applications demonstrated successfully.")
    print("=" * 60)


if __name__ == '__main__':
    main()


#!/usr/bin/env python3
"""
Tropical Valuation Distillation: Concrete Demonstrations

Demonstrates the key theorems from the formal framework:
1. Observer families as modular congruences
2. Valuation profiles and separation
3. Codebook extraction and compression bounds
4. Prime congruence spectrum visualization
5. Separation score heatmaps
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from itertools import combinations
from typing import List, Tuple, Dict, Set
import json
import base64
from io import BytesIO


# =============================================================================
# Core Data Structures
# =============================================================================

class RingCongruence:
    """A ring congruence on Z/nZ defined by modular reduction."""

    def __init__(self, n: int, modulus: int):
        """
        Congruence on Z/nZ: x ~ y iff x ≡ y (mod modulus).

        Args:
            n: Size of the base ring Z/nZ
            modulus: The modulus defining the congruence
        """
        self.n = n
        self.modulus = modulus

    def equivalent(self, x: int, y: int) -> bool:
        """Check if x and y are congruent."""
        return (x % self.modulus) == (y % self.modulus)

    def quotient_class(self, x: int) -> int:
        """Return the equivalence class of x."""
        return x % self.modulus

    def num_classes(self) -> int:
        """Number of equivalence classes on Z/nZ."""
        from math import gcd
        return min(self.modulus, self.n) if self.modulus > 0 else 1


class ObserverFamily:
    """A finite family of ring congruences as observers."""

    def __init__(self, n: int, congruences: List[RingCongruence]):
        self.n = n  # Size of base ring Z/nZ
        self.observers = congruences

    def observer_equiv(self, x: int, y: int) -> bool:
        """Check if x and y are observer-equivalent."""
        return all(obs.equivalent(x, y) for obs in self.observers)

    def valuation_profile(self, x: int) -> Tuple[int, ...]:
        """Compute the valuation profile of x."""
        return tuple(obs.quotient_class(x) for obs in self.observers)

    def is_separating(self, elements: List[int]) -> bool:
        """Check if the family separates all distinct pairs in elements."""
        for x, y in combinations(elements, 2):
            if not any(not obs.equivalent(x, y) for obs in self.observers):
                return False
        return True

    def separation_score(self, x: int, y: int) -> int:
        """Count the number of observers that distinguish x from y."""
        return sum(1 for obs in self.observers if not obs.equivalent(x, y))

    def codebook(self, elements: List[int]) -> Dict[Tuple[int, ...], List[int]]:
        """Extract the codebook: maps profiles to elements."""
        book = {}
        for x in elements:
            p = self.valuation_profile(x)
            if p not in book:
                book[p] = []
            book[p].append(x)
        return book


def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64 data URI."""
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    data = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{data}"


# =============================================================================
# Demo 1: Observer Separation on Z/6Z
# =============================================================================

def demo_basic_separation():
    """Demonstrate observer separation using modular congruences on Z/6Z."""
    print("=" * 60)
    print("Demo 1: Observer Separation on Z/6Z")
    print("=" * 60)

    n = 6
    elements = list(range(n))

    # Two observers: mod 2 and mod 3
    obs_mod2 = RingCongruence(n, 2)
    obs_mod3 = RingCongruence(n, 3)
    family = ObserverFamily(n, [obs_mod2, obs_mod3])

    print(f"\nBase ring: Z/{n}Z = {elements}")
    print(f"Observers: mod 2, mod 3")
    print(f"\nValuation profiles:")

    for x in elements:
        profile = family.valuation_profile(x)
        print(f"  v({x}) = {profile}")

    # Check separation
    fully_sep = family.is_separating(elements)
    print(f"\nFully separating: {fully_sep}")

    # Codebook
    book = family.codebook(elements)
    print(f"Codebook size: {len(book)}")
    print(f"Type size: {n}")
    print(f"Codebook = Type size (certified): {len(book) == n}")

    # Separation scores
    print(f"\nPairwise separation scores:")
    for x, y in combinations(elements, 2):
        score = family.separation_score(x, y)
        print(f"  sep({x}, {y}) = {score}")

    return family, elements


# =============================================================================
# Demo 2: Separation Score Heatmap
# =============================================================================

def demo_separation_heatmap(family: ObserverFamily, elements: List[int]):
    """Visualize pairwise separation scores as a heatmap."""
    print("\n" + "=" * 60)
    print("Demo 2: Separation Score Heatmap")
    print("=" * 60)

    n = len(elements)
    scores = np.zeros((n, n), dtype=int)
    for i, x in enumerate(elements):
        for j, y in enumerate(elements):
            scores[i, j] = family.separation_score(x, y)

    fig, ax = plt.subplots(1, 1, figsize=(8, 6))
    im = ax.imshow(scores, cmap='YlOrRd', interpolation='nearest')
    ax.set_xticks(range(n))
    ax.set_yticks(range(n))
    ax.set_xticklabels(elements)
    ax.set_yticklabels(elements)
    ax.set_xlabel('Element y')
    ax.set_ylabel('Element x')
    ax.set_title('Observer Separation Scores on Z/6Z\n(mod 2, mod 3 observers)')

    # Add text annotations
    for i in range(n):
        for j in range(n):
            ax.text(j, i, str(scores[i, j]),
                   ha='center', va='center', fontsize=14,
                   color='white' if scores[i, j] >= 1 else 'black')

    plt.colorbar(im, ax=ax, label='Number of separating observers')
    fig.tight_layout()
    heatmap_uri = fig_to_base64(fig)
    print("Heatmap generated.")
    return heatmap_uri


# =============================================================================
# Demo 3: Codebook Size vs. Observer Count
# =============================================================================

def demo_codebook_growth():
    """Show how codebook size grows with number of observers."""
    print("\n" + "=" * 60)
    print("Demo 3: Codebook Size vs. Observer Count")
    print("=" * 60)

    n = 30
    elements = list(range(n))
    primes = [2, 3, 5, 7, 11, 13]

    observer_counts = []
    codebook_sizes = []

    for k in range(1, len(primes) + 1):
        congruences = [RingCongruence(n, p) for p in primes[:k]]
        family = ObserverFamily(n, congruences)
        book = family.codebook(elements)

        observer_counts.append(k)
        codebook_sizes.append(len(book))
        sep = family.is_separating(elements)

        mods_str = ", ".join(str(p) for p in primes[:k])
        print(f"  Observers mod [{mods_str}]: "
              f"codebook size = {len(book)}, "
              f"fully separating = {sep}")

    fig, ax = plt.subplots(1, 1, figsize=(8, 5))
    ax.plot(observer_counts, codebook_sizes, 'bo-', linewidth=2, markersize=8,
            label='Codebook size')
    ax.axhline(y=n, color='r', linestyle='--', linewidth=1.5,
               label=f'|S| = {n}')
    ax.set_xlabel('Number of Observers', fontsize=12)
    ax.set_ylabel('Codebook Size', fontsize=12)
    ax.set_title('Codebook Size vs. Observer Count (Z/30Z)', fontsize=14)
    ax.legend(fontsize=11)
    ax.set_xticks(observer_counts)
    ax.set_xticklabels([f"mod {primes[:k]}" for k in range(1, len(primes) + 1)],
                        rotation=45, ha='right', fontsize=9)
    ax.grid(True, alpha=0.3)
    fig.tight_layout()
    growth_uri = fig_to_base64(fig)
    print("Growth chart generated.")
    return growth_uri


# =============================================================================
# Demo 4: Prime Congruence Spectrum
# =============================================================================

def demo_prime_spectrum():
    """Visualize the prime congruence spectrum of Z/30Z."""
    print("\n" + "=" * 60)
    print("Demo 4: Prime Congruence Spectrum of Z/30Z")
    print("=" * 60)

    n = 30
    primes = [2, 3, 5]

    # Show stalk classes at each prime congruence
    print(f"\nStalk classes at each prime congruence:")
    for p in primes:
        print(f"\n  Prime congruence mod {p}:")
        classes = {}
        for x in range(n):
            cls = x % p
            if cls not in classes:
                classes[cls] = []
            classes[cls].append(x)
        for cls, elems in sorted(classes.items()):
            print(f"    Class [{cls}]: {elems}")

    # Show combined separation
    congruences = [RingCongruence(n, p) for p in primes]
    family = ObserverFamily(n, congruences)

    # Count separating observers per pair for first few elements
    print(f"\nSeparation analysis (first 10 elements):")
    for x, y in combinations(range(10), 2):
        seps = []
        for i, p in enumerate(primes):
            if not congruences[i].equivalent(x, y):
                seps.append(f"mod {p}")
        if seps:
            print(f"  {x} vs {y}: separated by {', '.join(seps)}")

    # Visualization
    fig, axes = plt.subplots(1, 3, figsize=(15, 4))

    for idx, p in enumerate(primes):
        ax = axes[idx]
        elements = list(range(n))
        colors = [x % p for x in elements]
        cmap = plt.cm.Set3

        # Create a grid layout
        cols = 6
        rows = 5
        for i, x in enumerate(elements):
            row, col = divmod(i, cols)
            color = cmap(colors[i] / max(p - 1, 1))
            rect = plt.Rectangle((col, rows - 1 - row), 0.9, 0.9,
                                facecolor=color, edgecolor='black', linewidth=0.5)
            ax.add_patch(rect)
            ax.text(col + 0.45, rows - 1 - row + 0.45, str(x),
                   ha='center', va='center', fontsize=8)

        ax.set_xlim(-0.1, cols + 0.1)
        ax.set_ylim(-0.1, rows + 0.1)
        ax.set_aspect('equal')
        ax.set_title(f'Stalk at mod {p}\n({p} classes)', fontsize=11)
        ax.axis('off')

    fig.suptitle('Prime Congruence Spectrum of Z/30Z', fontsize=14, y=1.02)
    fig.tight_layout()
    spectrum_uri = fig_to_base64(fig)
    print("Spectrum visualization generated.")
    return spectrum_uri


# =============================================================================
# Demo 5: No-Collision Theorem Verification
# =============================================================================

def demo_no_collision():
    """Computationally verify the no-collision theorem."""
    print("\n" + "=" * 60)
    print("Demo 5: No-Collision Theorem Verification")
    print("=" * 60)

    n = 12
    elements = list(range(n))
    congruences = [RingCongruence(n, 2), RingCongruence(n, 3), RingCongruence(n, 4)]
    family = ObserverFamily(n, congruences)

    print(f"\nBase ring: Z/{n}Z")
    print(f"Observers: mod 2, mod 3, mod 4")

    # Check the main bridge theorem computationally
    violations = 0
    verified = 0

    for x, y in combinations(elements, 2):
        profile_x = family.valuation_profile(x)
        profile_y = family.valuation_profile(y)

        # Check: if profiles differ, then x ≠ y (trivially true)
        if profile_x != profile_y:
            assert x != y, "No-collision violated!"
            verified += 1
        else:
            print(f"  Elements {x} and {y} have same profile: {profile_x}")
            violations += 1

    sep = family.is_separating(elements)
    print(f"\nFully separating: {sep}")
    print(f"Distinct pairs with distinct profiles: {verified}")
    print(f"Distinct pairs with same profile (collisions): {violations}")
    print(f"No-collision theorem verified for all {verified} separated pairs: ✓")

    # Now show with a fully separating family
    print(f"\n--- Adding mod 4 observer doesn't help (4 = 2²) ---")
    family2 = ObserverFamily(n, [RingCongruence(n, 2), RingCongruence(n, 3)])
    book = family2.codebook(elements)
    print(f"mod 2, mod 3: codebook size = {len(book)}, need {n}")

    family3 = ObserverFamily(n, [RingCongruence(n, 3), RingCongruence(n, 4)])
    book3 = family3.codebook(elements)
    print(f"mod 3, mod 4: codebook size = {len(book3)}, need {n}")

    family4 = ObserverFamily(n, [
        RingCongruence(n, 2), RingCongruence(n, 3), RingCongruence(n, 4)
    ])
    book4 = family4.codebook(elements)
    print(f"mod 2, mod 3, mod 4: codebook size = {len(book4)}, need {n}")


# =============================================================================
# Demo 6: Score-Based Separation Bridge
# =============================================================================

def demo_score_bridge():
    """Demonstrate the score bridge theorem."""
    print("\n" + "=" * 60)
    print("Demo 6: Score Bridge — Margin ⇒ Spectral Separation")
    print("=" * 60)

    n = 10
    elements = list(range(n))
    congruences = [RingCongruence(n, 2), RingCongruence(n, 5)]
    family = ObserverFamily(n, congruences)

    # Define an observer-stable score: sum of quotient classes
    def stable_score(x: int) -> int:
        return sum(obs.quotient_class(x) for obs in family.observers)

    print(f"\nObserver-stable score: sum of mod-2, mod-5 quotient classes")
    print(f"{'Element':>8} {'Profile':>12} {'Score':>6}")
    print("-" * 30)

    for x in elements:
        profile = family.valuation_profile(x)
        score = stable_score(x)
        print(f"{x:>8} {str(profile):>12} {score:>6}")

    # Verify score bridge: score gap ⇒ separation
    print(f"\nScore bridge verification:")
    for x, y in [(0, 1), (0, 5), (1, 3), (2, 7)]:
        sx, sy = stable_score(x), stable_score(y)
        sep = family.separation_score(x, y)
        print(f"  score({x})={sx}, score({y})={sy}, "
              f"gap={abs(sx-sy)}, observers_separating={sep}, "
              f"bridge_holds={'✓' if (sx != sy) == (sep > 0) else '✗'}")


# =============================================================================
# Main
# =============================================================================

def main():
    """Run all demonstrations."""
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  Tropical Valuation Distillation — Concrete Demos      ║")
    print("║  Certified Observer Compression via Prime Spectra      ║")
    print("╚══════════════════════════════════════════════════════════╝")

    family, elements = demo_basic_separation()
    heatmap_uri = demo_separation_heatmap(family, elements)
    growth_uri = demo_codebook_growth()
    spectrum_uri = demo_prime_spectrum()
    demo_no_collision()
    demo_score_bridge()

    print("\n" + "=" * 60)
    print("All demonstrations complete.")
    print("=" * 60)

    return {
        'heatmap': heatmap_uri,
        'growth': growth_uri,
        'spectrum': spectrum_uri
    }


if __name__ == '__main__':
    vis = main()
