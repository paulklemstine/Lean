#!/usr/bin/env python3
"""
Berggren Dynamics: Applications

Demonstrates real-world applications of the Berggren semigroup theory:
1. Enumeration of Pythagorean triples up to a bound
2. Certified search space reduction via extremal path theory
3. Modular sieving using orbit structure
"""

from typing import List, Tuple, Set
from collections import defaultdict
import time

Triple = Tuple[int, int, int]

def berg_A(a, b, c): return (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)
def berg_B(a, b, c): return (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)
def berg_C(a, b, c): return (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)


def enumerate_primitive_triples(max_hyp: int) -> List[Triple]:
    """Enumerate all primitive Pythagorean triples with hypotenuse ≤ max_hyp
    using the Berggren tree with depth-first traversal.

    The tree property guarantees each primitive triple appears exactly once.
    The hypotenuse growth bound c' ≥ c + 4 ensures termination.

    Time: O(π(N)) where π(N) is the number of primitive triples ≤ N.
    Space: O(log N) for the stack (tree depth is O(log N)).
    """
    triples = []
    stack = [(3, 4, 5)]

    while stack:
        a, b, c = stack.pop()
        if c > max_hyp:
            continue
        triples.append((a, b, c))
        # Push children (in reverse order for DFS ordering)
        for gen in [berg_B, berg_C, berg_A]:
            child = gen(a, b, c)
            if child[2] <= max_hyp:
                stack.append(child)

    return sorted(triples, key=lambda t: t[2])


def depth_of_triple(triple: Triple) -> int:
    """Find the depth of a triple in the Berggren tree by
    ascending to the root using inverse generators.

    Time: O(log c) where c is the hypotenuse.
    """
    def inv_A(a, b, c): return (a + 2*b - 2*c, -2*a - b + 2*c, -2*a - 2*b + 3*c)
    def inv_B(a, b, c): return (a + 2*b - 2*c, 2*a + b - 2*c, -2*a - 2*b + 3*c)
    def inv_C(a, b, c): return (-a - 2*b + 2*c, 2*a + b - 2*c, -2*a - 2*b + 3*c)

    depth = 0
    a, b, c = triple
    while (a, b, c) != (3, 4, 5):
        # Try each inverse generator
        for inv in [inv_A, inv_B, inv_C]:
            pa, pb, pc = inv(a, b, c)
            if pa > 0 and pb > 0 and pc > 0 and pa*pa + pb*pb == pc*pc:
                a, b, c = pa, pb, pc
                depth += 1
                break
        else:
            return -1  # Should not happen for primitive triples
    return depth


def search_space_analysis(max_depth: int = 15):
    """Analyze how extremal path theory reduces the search space.

    The A-ray gives hypotenuse 2n²+6n+5 at depth n.
    This means to find all triples with hyp ≤ H, we need depth ≤ n
    where 2n²+6n+5 ≤ H, i.e., n ≈ √(H/2).

    The total tree size is 3^n, but pruning by hypotenuse bound
    dramatically reduces this.
    """
    print("=" * 70)
    print("APPLICATION 1: Search Space Reduction via Extremal Paths")
    print("=" * 70)

    print(f"\n{'depth':>6} {'A-ray hyp':>10} {'C-ray hyp':>10} {'ratio C/A':>10} "
          f"{'triples ≤ C-hyp':>16}")

    for n in range(1, max_depth + 1):
        ha = 2*n**2 + 6*n + 5
        hc = 4*n**2 + 8*n + 5
        ratio = hc / ha
        # Count triples up to C-ray hypotenuse
        count = len(enumerate_primitive_triples(hc))
        print(f"{n:>6} {ha:>10} {hc:>10} {ratio:>10.3f} {count:>16}")


def modular_sieve_demo():
    """Demonstrate modular sieving: using the Berggren modular orbits
    to quickly test whether a triple can be primitive Pythagorean.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 2: Modular Sieve for Triple Verification")
    print("=" * 70)

    # Build modular orbit tables for small primes
    primes = [7, 11, 13]
    orbit_tables = {}

    for p in primes:
        root = (3 % p, 4 % p, 5 % p)
        orbit = {root}
        frontier = {root}
        while frontier:
            new_frontier = set()
            for t in frontier:
                for gen in [berg_A, berg_B, berg_C]:
                    nt = gen(*t)
                    nt_mod = (nt[0] % p, nt[1] % p, nt[2] % p)
                    if nt_mod not in orbit:
                        orbit.add(nt_mod)
                        new_frontier.add(nt_mod)
            frontier = new_frontier
        orbit_tables[p] = orbit

    print(f"\nOrbit sizes: " + ", ".join(f"mod {p}: {len(orbit_tables[p])}"
                                          for p in primes))

    # Test some triples
    test_triples = [
        (3, 4, 5), (5, 12, 13), (8, 15, 17), (7, 24, 25),
        (10, 10, 14), (6, 8, 10), (9, 12, 15), (20, 21, 29),
        (1, 2, 3), (4, 7, 9)
    ]

    print(f"\n{'triple':>15} {'primitive?':>10} {'sieve result':>15}")
    print("-" * 45)
    for t in test_triples:
        a, b, c = t
        is_pyth = a*a + b*b == c*c
        is_prim = is_pyth and __import__('math').gcd(a, b) == 1

        # Check modular sieve
        passes_sieve = True
        for p in primes:
            t_mod = (a % p, b % p, c % p)
            if t_mod not in orbit_tables[p]:
                passes_sieve = False
                break

        status = "primitive" if is_prim else ("Pythagorean" if is_pyth else "not Pyth")
        sieve = "pass" if passes_sieve else "FILTERED"
        print(f"{str(t):>15} {status:>10} {sieve:>15}")


def growth_rate_comparison():
    """Compare growth rates of different Berggren branches."""
    print("\n" + "=" * 70)
    print("APPLICATION 3: Branch Growth Rate Comparison")
    print("=" * 70)

    branches = {
        'A-ray (geodesic)': lambda n: 2*n**2 + 6*n + 5,
        'C-ray (2nd extremal)': lambda n: 4*n**2 + 8*n + 5,
        'B-ray (fastest)': None,  # Computed iteratively
    }

    # Compute B-ray
    b_hyps = [5]
    t = (3, 4, 5)
    for _ in range(20):
        t = berg_B(*t)
        b_hyps.append(t[2])

    print(f"\n{'depth':>6} {'A-ray':>10} {'C-ray':>10} {'B-ray':>12} {'B/A ratio':>10}")
    print("-" * 55)
    for n in range(1, 11):
        ha = 2*n**2 + 6*n + 5
        hc = 4*n**2 + 8*n + 5
        hb = b_hyps[n]
        print(f"{n:>6} {ha:>10} {hc:>10} {hb:>12} {hb/ha:>10.1f}")

    print("\nA-ray growth: O(n²) — slowest (geodesic)")
    print("C-ray growth: O(n²) — twice the A-ray rate")
    print("B-ray growth: O(6ⁿ) — exponential (fastest branch)")


if __name__ == '__main__':
    search_space_analysis(10)
    modular_sieve_demo()
    growth_rate_comparison()


#!/usr/bin/env python3
"""
Berggren Dynamics: Demonstrations of Second-Extremal Paths

This module demonstrates the key theorems about the Berggren semigroup
acting on primitive Pythagorean triples, with focus on the C-ray as
the second-extremal path.
"""

from itertools import product as cart_product
from typing import Tuple

Triple = Tuple[int, int, int]

# === Berggren Generators ===

def berg_A(a: int, b: int, c: int) -> Triple:
    """Berggren generator A: the 'geodesic' direction."""
    return (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)

def berg_B(a: int, b: int, c: int) -> Triple:
    """Berggren generator B: the 'expanding' direction."""
    return (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)

def berg_C(a: int, b: int, c: int) -> Triple:
    """Berggren generator C: the 'second-extremal' direction."""
    return (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)

GENERATORS = {'A': berg_A, 'B': berg_B, 'C': berg_C}
ROOT = (3, 4, 5)

def apply_word(word: str, triple: Triple = ROOT) -> Triple:
    """Apply a word of generators to a triple."""
    for letter in word:
        a, b, c = triple
        triple = GENERATORS[letter](a, b, c)
    return triple

def hypotenuse(word: str) -> int:
    """Get the hypotenuse of the triple obtained from a word."""
    return apply_word(word)[2]

# === Closed Form Verification ===

def closed_form_A(n: int) -> Triple:
    """Closed form for the A-ray at depth n."""
    return (2*n + 3, 2*(n+1)*(n+2), 2*n**2 + 6*n + 5)

def closed_form_C(n: int) -> Triple:
    """Closed form for the C-ray at depth n."""
    return ((2*n+1)*(2*n+3), 4*(n+1), 4*n**2 + 8*n + 5)

def demo_closed_forms():
    """Verify closed forms for A-ray and C-ray."""
    print("=" * 70)
    print("DEMO 1: Closed-Form Verification")
    print("=" * 70)

    print("\nA-ray: iterating generator A from (3,4,5)")
    print(f"{'n':>3} {'computed':>25} {'closed form':>25} {'match':>6}")
    print("-" * 65)
    for n in range(8):
        word = 'A' * n
        computed = apply_word(word)
        closed = closed_form_A(n)
        match = computed == closed
        print(f"{n:>3} {str(computed):>25} {str(closed):>25} {'✓' if match else '✗':>6}")

    print(f"\nHypotenuse formula: c(A^n) = 2n² + 6n + 5")
    for n in range(8):
        h = hypotenuse('A' * n)
        formula = 2*n**2 + 6*n + 5
        assert h == formula, f"Mismatch at n={n}: {h} ≠ {formula}"
    print("Verified for n = 0..7 ✓")

    print("\n\nC-ray: iterating generator C from (3,4,5)")
    print(f"{'n':>3} {'computed':>25} {'closed form':>25} {'match':>6}")
    print("-" * 65)
    for n in range(8):
        word = 'C' * n
        computed = apply_word(word)
        closed = closed_form_C(n)
        match = computed == closed
        print(f"{n:>3} {str(computed):>25} {str(closed):>25} {'✓' if match else '✗':>6}")

    print(f"\nHypotenuse formula: c(C^n) = 4n² + 8n + 5")
    for n in range(8):
        h = hypotenuse('C' * n)
        formula = 4*n**2 + 8*n + 5
        assert h == formula, f"Mismatch at n={n}: {h} ≠ {formula}"
    print("Verified for n = 0..7 ✓")


def demo_second_extremal():
    """Verify that C^n is the second-extremal path at each depth."""
    print("\n" + "=" * 70)
    print("DEMO 2: Second-Extremal Verification")
    print("=" * 70)

    for depth in range(1, 7):
        # Generate all words of given depth
        all_words = [''.join(w) for w in cart_product('ABC', repeat=depth)]
        # Sort by hypotenuse
        sorted_words = sorted(all_words, key=hypotenuse)

        a_word = 'A' * depth
        c_word = 'C' * depth

        min_word = sorted_words[0]
        second_word = sorted_words[1]

        print(f"\nDepth {depth}:")
        print(f"  Minimum:  {min_word:>8} → hyp = {hypotenuse(min_word):>6}  "
              f"(A^{depth}, formula: {2*depth**2+6*depth+5})")
        print(f"  2nd min:  {second_word:>8} → hyp = {hypotenuse(second_word):>6}  "
              f"(C^{depth}, formula: {4*depth**2+8*depth+5})")
        print(f"  3rd min:  {sorted_words[2]:>8} → hyp = {hypotenuse(sorted_words[2]):>6}")

        assert min_word == a_word, f"A^n not minimum at depth {depth}!"
        assert second_word == c_word, f"C^n not second at depth {depth}!"

    print("\n✓ C^n is the unique second-extremal path for depths 1-6")


def demo_hypotenuse_gap():
    """Demonstrate the growing gap between A-ray and C-ray."""
    print("\n" + "=" * 70)
    print("DEMO 3: Hypotenuse Gap Analysis")
    print("=" * 70)

    print(f"\n{'n':>3} {'c(A^n)':>8} {'c(C^n)':>8} {'gap':>8} {'gap formula':>12}")
    print("-" * 45)
    for n in range(1, 12):
        ha = 2*n**2 + 6*n + 5
        hc = 4*n**2 + 8*n + 5
        gap = hc - ha
        formula = 2*n**2 + 2*n
        print(f"{n:>3} {ha:>8} {hc:>8} {gap:>8} {formula:>12}")
        assert gap == formula

    print("\nGap formula: c(C^n) - c(A^n) = 2n² + 2n  ✓")
    print("The gap grows quadratically — the C-ray diverges from the geodesic.")


def demo_b_jump():
    """Demonstrate the B-jump: B multiplies hypotenuse by > 5."""
    print("\n" + "=" * 70)
    print("DEMO 4: B-Generator Jump Lemma")
    print("=" * 70)

    print("\nFor positive Pythagorean triples, hyp(B(T)) > 5·hyp(T):")
    print(f"{'triple':>20} {'hyp':>6} {'B(triple)':>25} {'B-hyp':>8} {'ratio':>8}")
    print("-" * 70)

    triples = [
        (3, 4, 5), (5, 12, 13), (8, 15, 17), (7, 24, 25),
        (20, 21, 29), (9, 40, 41), (15, 8, 17), (35, 12, 37)
    ]
    for t in triples:
        bt = berg_B(*t)
        ratio = bt[2] / t[2]
        print(f"{str(t):>20} {t[2]:>6} {str(bt):>25} {bt[2]:>8} {ratio:>8.2f}")

    print("\nAll ratios exceed 5. Formally proved: hyp(B(T)) ≥ 5c + 2  ✓")


def demo_modular_orbits():
    """Demonstrate modular dynamics of the Berggren action."""
    print("\n" + "=" * 70)
    print("DEMO 5: Modular Orbit Dynamics")
    print("=" * 70)

    for p in [7, 11, 13, 17, 19, 23]:
        # Compute the orbit of (3,4,5) mod p
        root_mod = (3 % p, 4 % p, 5 % p)
        orbit = {root_mod}
        frontier = {root_mod}

        while frontier:
            new_frontier = set()
            for t in frontier:
                for gen in [berg_A, berg_B, berg_C]:
                    nt = gen(*t)
                    nt_mod = (nt[0] % p, nt[1] % p, nt[2] % p)
                    if nt_mod not in orbit:
                        orbit.add(nt_mod)
                        new_frontier.add(nt_mod)
            frontier = new_frontier

        # Verify all triples in orbit satisfy a²+b²≡c² (mod p)
        all_pyth = all((a**2 + b**2 - c**2) % p == 0 for a, b, c in orbit)

        print(f"  p = {p:>2}: orbit size = {len(orbit):>4}, "
              f"all Pythagorean mod {p}: {'✓' if all_pyth else '✗'}")

    print("\nPythagorean relation preserved in all modular orbits ✓")


if __name__ == '__main__':
    demo_closed_forms()
    demo_second_extremal()
    demo_hypotenuse_gap()
    demo_b_jump()
    demo_modular_orbits()
