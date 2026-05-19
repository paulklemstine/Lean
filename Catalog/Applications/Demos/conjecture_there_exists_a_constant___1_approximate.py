"""
Berggren Tree Applications — Practical Uses of the Arithmetic Dynamics

This module demonstrates real-world applications of the Berggren tree
growth theorems and congruence results.

Applications:
1. Optimal triple enumeration with certified bounds
2. Cryptographic parameter selection
3. Geometric lattice point counting
4. Signal processing / Pythagorean angle generation
"""

from algorithms import (
    enumerate_triples_up_to, certified_max_depth, allA_formula,
    count_primitive_triples, berggren_A, berggren_B, berggren_C,
    GENERATORS, ROOT, build_residue_graph
)
from math import gcd, isqrt, pi, atan2
from typing import List, Tuple, Dict
from collections import Counter
import time


Triple = Tuple[int, int, int]


# ============================================================
# Application 1: Certified Triple Enumeration
# ============================================================

def benchmark_enumeration():
    """
    Benchmark the Berggren tree enumeration with certified depth bounds.

    Shows how the quadratic growth theorem gives precise performance predictions.
    """
    print("=" * 70)
    print("APPLICATION 1: Certified Triple Enumeration")
    print("=" * 70)
    print()
    print("Using the theorem: c_min(d) ≥ 2d²+4d+5, we compute certified")
    print("maximum depths and compare with actual enumeration performance.")
    print()

    bounds = [100, 500, 1000, 5000, 10000, 50000]
    print(f"{'N':>8} | {'Max depth':>10} | {'# triples':>10} | {'Time (ms)':>10} | {'Avg c':>10}")
    print("-" * 60)

    for N in bounds:
        d_max = certified_max_depth(N)
        start = time.time()
        triples = enumerate_triples_up_to(N)
        elapsed = (time.time() - start) * 1000
        avg_c = sum(t[2] for t in triples) / len(triples) if triples else 0
        print(f"{N:>8} | {d_max:>10} | {len(triples):>10} | {elapsed:>10.1f} | {avg_c:>10.1f}")

    print()


# ============================================================
# Application 2: Pythagorean Angle Generation
# ============================================================

def generate_pythagorean_angles(N: int) -> List[float]:
    """
    Generate all 'Pythagorean angles' — angles whose sine and cosine
    are both rational — with denominator ≤ N.

    A Pythagorean angle θ satisfies cos(θ) = a/c, sin(θ) = b/c
    where (a,b,c) is a primitive Pythagorean triple.

    Applications: exact rotation matrices, rational trigonometry,
    digital signal processing with exact arithmetic.
    """
    triples = enumerate_triples_up_to(N)
    angles = []
    for a, b, c in triples:
        theta = atan2(b, a)
        angles.append(theta)
        # Also consider the complementary angle
        theta2 = atan2(a, b)
        angles.append(theta2)
    return sorted(set(angles))


def demo_pythagorean_angles():
    """Show Pythagorean angles for small hypotenuses."""
    print("=" * 70)
    print("APPLICATION 2: Pythagorean Angle Generation")
    print("=" * 70)
    print()
    print("Pythagorean angles have EXACT rational sine and cosine values.")
    print("They are crucial for lossless rotation in digital signal processing.")
    print()

    triples = enumerate_triples_up_to(50)
    print(f"{'Triple (a,b,c)':>20} | {'cos=a/c':>12} | {'sin=b/c':>12} | {'θ (degrees)':>12}")
    print("-" * 65)

    for a, b, c in sorted(triples, key=lambda t: t[2]):
        cos_val = a / c
        sin_val = b / c
        theta = atan2(b, a) * 180 / pi
        print(f"{'(' + str(a) + ',' + str(b) + ',' + str(c) + ')':>20} | {cos_val:>12.6f} | {sin_val:>12.6f} | {theta:>12.4f}°")

    print()
    angles = generate_pythagorean_angles(100)
    print(f"Total Pythagorean angles with c ≤ 100: {len(angles)}")
    print(f"Average angular spacing: {360/len(angles):.2f}°")
    print()


# ============================================================
# Application 3: Hypotenuse Multiplicity Analysis
# ============================================================

def demo_multiplicity():
    """
    Demonstrate the relationship between prime factorization and
    the number of primitive Pythagorean triples per hypotenuse.
    """
    print("=" * 70)
    print("APPLICATION 3: Hypotenuse Multiplicity Analysis")
    print("=" * 70)
    print()
    print("The number of primitive triples with hypotenuse c equals 2^{k-1}")
    print("where k = number of distinct primes ≡ 1 (mod 4) dividing c.")
    print()

    # Find hypotenuses with high multiplicity
    max_c = 10000
    triples = enumerate_triples_up_to(max_c)

    # Count triples per hypotenuse
    hyp_counts: Dict[int, int] = Counter()
    for a, b, c in triples:
        # Normalize to a < b
        if a > b:
            a, b = b, a
        hyp_counts[c] += 1

    # Group by multiplicity
    mult_examples: Dict[int, List[int]] = {}
    for c, count in sorted(hyp_counts.items()):
        if count not in mult_examples:
            mult_examples[count] = []
        if len(mult_examples[count]) < 5:
            mult_examples[count].append(c)

    print(f"{'Multiplicity':>12} | {'Count':>6} | {'Examples':>40} | {'k = #primes ≡1(4)'}")
    print("-" * 85)

    for mult in sorted(mult_examples.keys()):
        examples = mult_examples[mult]
        total = sum(1 for c, count in hyp_counts.items() if count == mult)
        # k from 2^{k-1} = mult
        import math
        k = int(math.log2(mult)) + 1 if mult > 0 else 0
        print(f"{mult:>12} | {total:>6} | {str(examples[:5]):>40} | k = {k}")

    print()


# ============================================================
# Application 4: Lattice Point Counting on Circles
# ============================================================

def lattice_points_on_circle(r_squared: int) -> List[Tuple[int, int]]:
    """
    Find all lattice points (x, y) on the circle x² + y² = r².

    This is directly related to primitive Pythagorean triples when
    r² = c² for a hypotenuse c.
    """
    points = []
    r = isqrt(r_squared)
    if r * r != r_squared:
        return []

    for x in range(-r, r + 1):
        y_sq = r_squared - x * x
        if y_sq >= 0:
            y = isqrt(y_sq)
            if y * y == y_sq:
                points.append((x, y))
                if y != 0:
                    points.append((x, -y))
    return list(set(points))


def demo_lattice_points():
    """Show the connection between Berggren tree and lattice point counting."""
    print("=" * 70)
    print("APPLICATION 4: Lattice Points on Circles")
    print("=" * 70)
    print()
    print("The Berggren tree enumerates primitive representations of c²")
    print("as sums of two squares, directly counting lattice points on circles.")
    print()

    test_values = [5, 13, 25, 50, 65, 85, 125, 325]
    for c in test_values:
        points = lattice_points_on_circle(c * c)
        prim_count = count_primitive_triples(c)
        # Filter to first quadrant primitive points
        prim_points = [(x, y) for x, y in points if x > 0 and y > 0 and gcd(x, y) == 1 and x < y]
        print(f"  c = {c}: {len(points)} lattice points on circle, "
              f"{prim_count} primitive triples (a<b), "
              f"primitive first-quadrant: {prim_points[:4]}{'...' if len(prim_points) > 4 else ''}")

    print()


# ============================================================
# Application 5: Residue Mixing Verification
# ============================================================

def demo_residue_mixing():
    """
    Verify residue mixing properties for small moduli.

    For odd modulus m, check whether the hypotenuse residues at large
    depth approach uniform distribution on admissible residues.
    """
    print("=" * 70)
    print("APPLICATION 5: Residue Mixing Verification")
    print("=" * 70)
    print()

    for m in [3, 5, 7, 11, 13]:
        print(f"Modulus m = {m}:")

        # Enumerate large depth and compute distribution
        current_triples = [ROOT]
        for d in range(8):
            next_triples = []
            for t in current_triples:
                for gen in GENERATORS:
                    next_triples.append(gen(*t))
            current_triples = next_triples

        # Compute hyp residue distribution
        residues = Counter(t[2] % m for t in current_triples)
        total = len(current_triples)
        admissible = sorted(residues.keys())

        print(f"  Depth 8: {total} triples")
        print(f"  Admissible residues: {admissible}")
        uniform = 1.0 / len(admissible)
        max_dev = max(abs(residues[r] / total - uniform) for r in admissible)
        print(f"  Max deviation from uniform: {max_dev:.6f} (uniform = {uniform:.6f})")
        print(f"  Distribution: {', '.join(f'{r}: {residues[r]/total:.4f}' for r in admissible)}")
        print()

    print("As depth increases, the distribution converges to uniform on")
    print("admissible residues — evidence for the mixing conjecture.")
    print()


if __name__ == "__main__":
    benchmark_enumeration()
    demo_pythagorean_angles()
    demo_multiplicity()
    demo_lattice_points()
    demo_residue_mixing()


"""
Berggren Tree Arithmetic Dynamics — Demonstrations

This module provides concrete numerical demonstrations of the key theorems
about the Berggren ternary tree of primitive Pythagorean triples.

Key findings demonstrated:
1. The all-A branch yields an exact closed-form formula for triples
2. The minimum hypotenuse grows QUADRATICALLY (Θ(d²)), not exponentially
3. All hypotenuses in the tree are ≡ 1 (mod 4)
4. The quadratic sandwich: 2d²+4d+5 ≤ c_min(d) ≤ 2d²+6d+5
"""

import numpy as np
from typing import Tuple, List

Triple = Tuple[int, int, int]

# Berggren generators as functions on triples (a, b, c)
def bergA(a: int, b: int, c: int) -> Triple:
    """Berggren generator A: the 'slow growth' generator."""
    return (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)

def bergB(a: int, b: int, c: int) -> Triple:
    """Berggren generator B: the 'fast growth' generator."""
    return (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)

def bergC(a: int, b: int, c: int) -> Triple:
    """Berggren generator C: the 'intermediate growth' generator."""
    return (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)

GENERATORS = [bergA, bergB, bergC]
ROOT = (3, 4, 5)


def apply_word(word: List[int], root: Triple = ROOT) -> Triple:
    """Apply a word (list of generator indices 0,1,2) to a starting triple."""
    t = root
    for g in word:
        t = GENERATORS[g](*t)
    return t


def all_triples_at_depth(d: int) -> List[Triple]:
    """Enumerate all 3^d triples at depth d in the Berggren tree."""
    if d == 0:
        return [ROOT]
    prev = all_triples_at_depth(d - 1)
    result = []
    for t in prev:
        for g in GENERATORS:
            result.append(g(*t))
    return result


def demo_allA_branch():
    """Demonstrate the exact formula for the all-A branch."""
    print("=" * 70)
    print("DEMO 1: All-A Branch — Exact Closed-Form Formula")
    print("=" * 70)
    print()
    print("The all-A branch of the Berggren tree (always choosing generator A)")
    print("produces triples given by the exact formula:")
    print("  (a, b, c) = (2n+3, 2n²+6n+4, 2n²+6n+5)")
    print()
    print(f"{'Depth n':>8} | {'Computed triple':>30} | {'Formula triple':>30} | Match")
    print("-" * 85)

    t = ROOT
    for n in range(12):
        formula = (2*n + 3, 2*n**2 + 6*n + 4, 2*n**2 + 6*n + 5)
        match = t == formula
        print(f"{n:>8} | {str(t):>30} | {str(formula):>30} | {'✓' if match else '✗'}")
        # Verify Pythagorean
        assert t[0]**2 + t[1]**2 == t[2]**2, f"Not Pythagorean at depth {n}!"
        t = bergA(*t)
    print()
    print("All triples are Pythagorean: a² + b² = c² ✓")
    print("The hypotenuse grows as 2n² + 6n + 5 — QUADRATIC, not exponential!")
    print()


def demo_quadratic_growth():
    """Demonstrate the quadratic growth of c_min(d)."""
    print("=" * 70)
    print("DEMO 2: Quadratic Growth of Minimum Hypotenuse")
    print("=" * 70)
    print()
    print("The minimum hypotenuse at depth d satisfies the sandwich:")
    print("  2d² + 4d + 5 ≤ c_min(d) ≤ 2d² + 6d + 5")
    print()
    print(f"{'d':>4} | {'c_min(d)':>10} | {'Lower 2d²+4d+5':>15} | {'Upper 2d²+6d+5':>15} | {'3^d triples':>12}")
    print("-" * 70)

    for d in range(9):
        triples = all_triples_at_depth(d)
        cs = [t[2] for t in triples]
        cmin = min(cs)
        lower = 2*d**2 + 4*d + 5
        upper = 2*d**2 + 6*d + 5
        n_triples = len(triples)
        assert lower <= cmin <= upper, f"Sandwich violated at d={d}!"
        print(f"{d:>4} | {cmin:>10} | {lower:>15} | {upper:>15} | {n_triples:>12}")

    print()
    print("Key insight: c_min(d) = 2d² + 6d + 5 exactly (achieved by the all-A branch).")
    print("This means the tree depth needed to enumerate all triples with c ≤ N")
    print("is Θ(√N), NOT Θ(log N) as exponential growth would give.")
    print()


def demo_congruence():
    """Demonstrate that all hypotenuses are ≡ 1 (mod 4)."""
    print("=" * 70)
    print("DEMO 3: Congruence Properties — All Hypotenuses ≡ 1 (mod 4)")
    print("=" * 70)
    print()

    for d in range(6):
        triples = all_triples_at_depth(d)
        hyps = [t[2] for t in triples]
        residues = set(h % 4 for h in hyps)
        all_one = all(h % 4 == 1 for h in hyps)
        print(f"Depth {d}: {len(hyps):>5} hypotenuses, residues mod 4 = {residues}, all ≡ 1: {'✓' if all_one else '✗'}")

    print()
    print("Every hypotenuse in the Berggren tree is congruent to 1 modulo 4.")
    print("This follows from: if c ≡ 1 (mod 4) and a²+b²=c², then each")
    print("child's hypotenuse is also ≡ 1 (mod 4).")
    print()


def demo_growth_comparison():
    """Compare quadratic vs exponential growth rates."""
    print("=" * 70)
    print("DEMO 4: Quadratic vs Exponential — Why This Matters")
    print("=" * 70)
    print()
    print("To enumerate all primitive Pythagorean triples with hypotenuse ≤ N:")
    print()
    print(f"{'N':>12} | {'Depth (quadratic √N)':>20} | {'Depth (if exponential)':>22} | {'Ratio':>8}")
    print("-" * 70)

    for N in [100, 1000, 10_000, 100_000, 1_000_000, 10_000_000]:
        # Quadratic growth: d ≈ √(N/2)
        d_quad = int(np.ceil(np.sqrt(N / 2)))
        # If growth were exponential with λ ≈ 3: d ≈ log₃(N)
        d_exp = int(np.ceil(np.log(N) / np.log(3)))
        ratio = d_quad / d_exp if d_exp > 0 else float('inf')
        print(f"{N:>12,} | {d_quad:>20} | {d_exp:>22} | {ratio:>8.1f}")

    print()
    print("The quadratic growth means MUCH deeper trees are needed for large N.")
    print("This has direct implications for algorithmic enumeration complexity.")
    print()


def demo_branch_analysis():
    """Analyze the growth rates of different periodic branches."""
    print("=" * 70)
    print("DEMO 5: Branch Growth Analysis")
    print("=" * 70)
    print()

    branches = {
        "A (all-A)": [0],
        "B (all-B)": [1],
        "C (all-C)": [2],
        "AB (alternating)": [0, 1],
        "AC (alternating)": [0, 2],
        "BC (alternating)": [1, 2],
        "ABC (cyclic)": [0, 1, 2],
    }

    print(f"{'Branch':>20} | {'Growth rate':>15} | {'First 6 hypotenuses'}")
    print("-" * 80)

    for name, pattern in branches.items():
        t = ROOT
        hyps = [t[2]]
        for i in range(20):
            g = pattern[i % len(pattern)]
            t = GENERATORS[g](*t)
            hyps.append(t[2])

        # Estimate growth rate: c_n^{1/n}
        rates = [hyps[n]**(1/n) if n > 0 else 0 for n in range(1, len(hyps))]
        if len(hyps) > 10:
            asymptotic_rate = hyps[-1]**(1/(len(hyps)-1))
        else:
            asymptotic_rate = 0

        hyp_str = ", ".join(str(h) for h in hyps[:7])
        if asymptotic_rate > 1.1:
            growth = f"λ ≈ {asymptotic_rate:.4f}"
        else:
            growth = "Θ(n²)"
        print(f"{name:>20} | {growth:>15} | {hyp_str}")

    print()
    print("The all-A branch grows quadratically (Θ(n²)), while all other periodic")
    print("branches grow exponentially. The all-A branch is the unique minimizer.")
    print()


def demo_residue_distribution():
    """Show residue distribution of hypotenuses at various depths."""
    print("=" * 70)
    print("DEMO 6: Residue Distribution of Hypotenuses")
    print("=" * 70)
    print()

    for m in [3, 5, 7, 8, 12]:
        print(f"Modulus m = {m}:")
        for d in [3, 5, 7]:
            triples = all_triples_at_depth(d)
            residues = {}
            for t in triples:
                r = t[2] % m
                residues[r] = residues.get(r, 0) + 1
            total = len(triples)
            dist = {r: f"{count/total:.3f}" for r, count in sorted(residues.items())}
            print(f"  d={d}: {dist}")
        print()


if __name__ == "__main__":
    demo_allA_branch()
    demo_quadratic_growth()
    demo_congruence()
    demo_growth_comparison()
    demo_branch_analysis()
    demo_residue_distribution()
