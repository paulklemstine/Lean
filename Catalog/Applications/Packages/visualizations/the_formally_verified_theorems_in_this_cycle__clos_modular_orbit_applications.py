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
