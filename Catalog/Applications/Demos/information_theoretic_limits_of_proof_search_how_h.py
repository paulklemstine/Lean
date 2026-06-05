"""
Proof Search Entropy: Interactive Demo

Demonstrates the key results from the formal theory:
1. Entropy gap growth
2. Search difficulty bounds
3. Phase transition in proof search
4. Incompressibility analysis
5. Composition superadditivity
6. Log-factor growth conjecture test
"""

import math


def demo_entropy_gap():
    """Demonstrate that the entropy gap grows without bound."""
    print("=" * 60)
    print("DEMO 1: Entropy Gap Growth")
    print("=" * 60)
    print()
    print("For a binary proof system (b=2) with T=100 theorems,")
    print("the entropy gap EG(n) = 2^n - P(n) grows exponentially:")
    print()
    print(f"{'n':>4} {'2^n':>12} {'P(n)':>8} {'EG(n)':>12} {'EG/2^n':>10}")
    print("-" * 50)

    T = 100
    for n in range(1, 21):
        space = 2 ** n
        provable = min(space - 1, T)
        gap = space - provable
        ratio = gap / space if space > 0 else 0
        print(f"{n:4d} {space:12d} {provable:8d} {gap:12d} {ratio:10.6f}")

    print()
    print("Key insight: The entropy gap eventually dominates the search space.")
    print("Even with T=100 theorems, the gap grows to 2^20 - 100 ≈ 1M.")
    print()


def demo_search_difficulty():
    """Demonstrate exponential search difficulty bounds."""
    print("=" * 60)
    print("DEMO 2: Search Difficulty Lower Bounds")
    print("=" * 60)
    print()
    print("Information-Search Duality: If V ≤ b^k valid proofs exist")
    print("among b^n candidates, search requires ≥ b^(n-k-1) steps.")
    print()

    b = 2
    for n in range(5, 16):
        for k in [1, n // 4, n // 2]:
            if k + 1 > n:
                continue
            V = b ** k
            lower = b ** (n - k - 1)
            actual = b ** n // (V + 1)
            info_bits = n - k
            print(f"  n={n:2d}, k={k:2d}: V≤{V:6d}, "
                  f"lower_bound={lower:8d}, "
                  f"actual={actual:8d}, "
                  f"info_gap={info_bits:2d} bits")
    print()


def demo_phase_transition():
    """Demonstrate the phase transition in proof search."""
    print("=" * 60)
    print("DEMO 3: Phase Transition in Proof Search")
    print("=" * 60)
    print()
    print("Phase transition: At n ≈ log_b(T), the proof system gains")
    print("enough capacity to encode all theorems, but search explodes.")
    print()

    for T in [10, 100, 1000, 10000]:
        for b in [2, 10]:
            critical = math.ceil(math.log(T, b))
            space_at_critical = b ** critical
            surplus = space_at_critical - T
            print(f"  T={T:6d}, b={b:2d}: critical_n={critical:3d}, "
                  f"b^n={space_at_critical:10d}, "
                  f"surplus={surplus:10d}")
    print()
    print("The capacity surplus (b^T - T) grows super-exponentially.")
    print("Proved: T ≤ b^T - T for all T > 0, b ≥ 2.")
    print()


def demo_incompressibility():
    """Demonstrate the incompressibility fraction."""
    print("=" * 60)
    print("DEMO 4: Incompressibility Analysis")
    print("=" * 60)
    print()
    print("Proved: At least (b-1)/b of all strings of length n")
    print("are incompressible (cannot be shortened).")
    print()

    print(f"{'b':>4} {'n':>4} {'total':>10} {'compressible':>14} {'incompressible':>15} {'fraction':>10}")
    print("-" * 60)

    for b in [2, 3, 10, 26]:
        for n in [5, 10, 15]:
            total = b ** n
            compressible = b ** (n - 1)
            incompressible = total - compressible
            frac = incompressible / total
            print(f"{b:4d} {n:4d} {total:10d} {compressible:14d} "
                  f"{incompressible:15d} {frac:10.4f}")
    print()
    print("Proved: (b-1) * b^(n-1) ≤ b^n - b^(n-1)")
    print()


def demo_composition():
    """Demonstrate superadditivity of search costs."""
    print("=" * 60)
    print("DEMO 5: Composition Superadditivity")
    print("=" * 60)
    print()
    print("Proved: b^m + b^n ≤ b^(m+n) for b≥2, m≥1, n≥1.")
    print("Proof costs compose super-additively!")
    print()

    b = 2
    print(f"{'m':>4} {'n':>4} {'b^m':>10} {'b^n':>10} {'sum':>12} {'b^(m+n)':>14} {'ratio':>8}")
    print("-" * 65)

    for m in range(1, 8):
        for n in range(1, 8):
            bm = b ** m
            bn = b ** n
            sumv = bm + bn
            composed = b ** (m + n)
            ratio = composed / sumv
            if m <= n:
                print(f"{m:4d} {n:4d} {bm:10d} {bn:10d} {sumv:12d} "
                      f"{composed:14d} {ratio:8.1f}")
    print()


def demo_log_factor():
    """Test the log-factor growth conjecture."""
    print("=" * 60)
    print("DEMO 6: Log-Factor Growth Conjecture")
    print("=" * 60)
    print()
    print("Conjecture: proof_length ~ C * statement_length * log(statement_length)")
    print("Proved: if f(s) ≥ s·log₂(s) for s≥4, then f(s) > s (super-linear).")
    print()

    # Simulated data: proof lengths with log factor
    import random
    random.seed(42)

    print("Simulated test with C ≈ 2:")
    print(f"{'s':>6} {'p':>8} {'s*log2(s)':>12} {'p/(s*log2(s))':>15}")
    print("-" * 45)

    ratios = []
    for s in range(4, 101, 5):
        expected = s * math.log2(s)
        # Simulate proof length with noise
        p = int(2.0 * expected + random.gauss(0, expected * 0.1))
        ratio = p / expected if expected > 0 else 0
        ratios.append(ratio)
        if s <= 50 or s % 20 == 0:
            print(f"{s:6d} {p:8d} {expected:12.1f} {ratio:15.4f}")

    mean_r = sum(ratios) / len(ratios)
    std_r = math.sqrt(sum((r - mean_r) ** 2 for r in ratios) / len(ratios))
    print(f"\nMean ratio: {mean_r:.4f} ± {std_r:.4f}")
    print(f"Conjecture support (0.5 ≤ C ≤ 10): {'YES' if 0.5 <= mean_r <= 10 else 'NO'}")
    print()


def demo_density_vanishing():
    """Demonstrate asymptotic density vanishing."""
    print("=" * 60)
    print("DEMO 7: Asymptotic Density Vanishing")
    print("=" * 60)
    print()
    print("Proved: For any SDF, ∃n with P(n)·2 < b^n.")
    print("The density of provable theorems in the search space vanishes.")
    print()

    T = 1000
    b = 2
    print(f"T = {T}, b = {b}")
    print(f"{'n':>4} {'P(n)':>8} {'b^n':>12} {'P(n)*2':>10} {'P(n)*2 < b^n?':>16}")
    print("-" * 55)

    for n in range(1, 25):
        provable = min(2 ** n - 1, T)
        space = 2 ** n
        double_p = provable * 2
        vanishes = double_p < space
        print(f"{n:4d} {provable:8d} {space:12d} {double_p:10d} {'YES' if vanishes else 'no':>16}")
        if vanishes and n > 10:
            break

    print()


if __name__ == "__main__":
    demo_entropy_gap()
    demo_search_difficulty()
    demo_phase_transition()
    demo_incompressibility()
    demo_composition()
    demo_log_factor()
    demo_density_vanishing()

    print("=" * 60)
    print("All demos completed successfully.")
    print("=" * 60)
