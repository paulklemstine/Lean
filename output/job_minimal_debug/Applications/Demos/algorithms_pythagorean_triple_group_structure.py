#!/usr/bin/env python3
"""
Algorithms for the Berggren Tree Arithmetic Dynamical System

Implements certified enumeration, ancestry computation, and analysis algorithms
based on the formally verified properties of the Berggren tree.

Key algorithms:
1. Certified enumeration of primitive Pythagorean triples (BFS/DFS by depth)
2. Unique parent computation via inverse maps
3. Word coding: canonical path from root to any primitive triple
4. Hypotenuse statistics and growth analysis
5. Fixed-hypotenuse multiplicity classification
"""

from typing import Tuple, List, Optional, Dict, Set, Generator as Gen
from math import gcd, log, sqrt
from collections import defaultdict
import heapq

Triple = Tuple[int, int, int]

# ─── Core Berggren Maps ─────────────────────────────────────────────────────

def berg_A(a: int, b: int, c: int) -> Triple:
    """Berggren generator A: det = +1, in SO(2,1;ℤ)."""
    return (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)

def berg_B(a: int, b: int, c: int) -> Triple:
    """Berggren generator B: det = -1, in O(2,1;ℤ) \\ SO(2,1;ℤ)."""
    return (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)

def berg_C(a: int, b: int, c: int) -> Triple:
    """Berggren generator C: det = +1, in SO(2,1;ℤ)."""
    return (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)

def inv_A(a: int, b: int, c: int) -> Triple:
    """Inverse of generator A."""
    return (a + 2*b - 2*c, -2*a - b + 2*c, -2*a - 2*b + 3*c)

def inv_B(a: int, b: int, c: int) -> Triple:
    """Inverse of generator B."""
    return (a + 2*b - 2*c, 2*a + b - 2*c, -2*a - 2*b + 3*c)

def inv_C(a: int, b: int, c: int) -> Triple:
    """Inverse of generator C."""
    return (-a - 2*b + 2*c, 2*a + b - 2*c, -2*a - 2*b + 3*c)

ROOT: Triple = (3, 4, 5)
GENERATORS = {'A': berg_A, 'B': berg_B, 'C': berg_C}
INVERSES = {'A': inv_A, 'B': inv_B, 'C': inv_C}


# ─── Algorithm 1: Certified Enumeration ─────────────────────────────────────

def enumerate_by_depth(max_depth: int) -> Dict[int, List[Triple]]:
    """
    Enumerate all primitive Pythagorean triples by Berggren tree depth.

    Certified properties (formally verified):
    - Every triple produced is Pythagorean: a² + b² = c²
    - Every triple is primitive: gcd(a,b) = 1
    - All components are positive
    - No duplicates (by tree structure)

    Time complexity: O(3^d) where d = max_depth
    Space complexity: O(3^d)

    Args:
        max_depth: Maximum depth in the Berggren tree

    Returns:
        Dictionary mapping depth to list of triples at that depth
    """
    levels: Dict[int, List[Triple]] = {0: [ROOT]}
    for d in range(max_depth):
        next_level = []
        for triple in levels[d]:
            for gen in GENERATORS.values():
                child = gen(*triple)
                next_level.append(child)
        levels[d + 1] = next_level
    return levels


def enumerate_by_hypotenuse(max_c: int) -> List[Triple]:
    """
    Enumerate all primitive Pythagorean triples with hypotenuse ≤ max_c.

    Uses priority queue ordered by hypotenuse for efficient enumeration.
    Certified by hypotenuse monotonicity: children always have c' > c.

    Time complexity: O(N log N) where N = number of triples with c ≤ max_c
    Space complexity: O(N)

    Args:
        max_c: Maximum hypotenuse value

    Returns:
        List of all primitive Pythagorean triples with hypotenuse ≤ max_c,
        sorted by hypotenuse
    """
    result: List[Triple] = []
    # Priority queue: (hypotenuse, triple)
    pq: List[Tuple[int, Triple]] = [(5, ROOT)]

    while pq:
        c, triple = heapq.heappop(pq)
        if c > max_c:
            break
        result.append(triple)
        for gen in GENERATORS.values():
            child = gen(*triple)
            if child[2] <= max_c:
                heapq.heappush(pq, (child[2], child))

    return result


# ─── Algorithm 2: Unique Parent / Ancestry ──────────────────────────────────

def find_parent(a: int, b: int, c: int) -> Optional[Tuple[str, Triple]]:
    """
    Find the unique Berggren parent of a primitive Pythagorean triple.

    For any primitive triple (a,b,c) ≠ (3,4,5), exactly one of the three
    inverse maps produces a triple with all positive components.

    Certified by: hypotenuse strict growth + invertibility theorems.

    Time complexity: O(1)

    Args:
        a, b, c: A primitive Pythagorean triple with a,b,c > 0

    Returns:
        (generator_name, parent_triple) or None if (a,b,c) = (3,4,5)
    """
    if (a, b, c) == ROOT:
        return None

    for name, inv in INVERSES.items():
        parent = inv(a, b, c)
        pa, pb, pc = parent
        if pa > 0 and pb > 0 and pc > 0:
            return (name, parent)

    return None  # Should never happen for valid primitive triples


def word_code(a: int, b: int, c: int) -> str:
    """
    Compute the unique Berggren word that generates (a,b,c) from (3,4,5).

    This is the canonical path in the Berggren tree from root to the triple.
    Computed by iterated parent-finding (ascending the tree).

    Certified by: unique parent theorem + word injectivity.

    Time complexity: O(log c) — depth is O(log c) by hypotenuse growth

    Args:
        a, b, c: A primitive Pythagorean triple with a,b,c > 0

    Returns:
        String of generators (e.g., "ACB") reading root-to-leaf
    """
    word = []
    current = (a, b, c)

    while current != ROOT:
        result = find_parent(*current)
        if result is None:
            raise ValueError(f"Not a valid positive primitive triple: {current}")
        gen_name, parent = result
        word.append(gen_name)
        current = parent

    return ''.join(reversed(word))


def ancestry_chain(a: int, b: int, c: int) -> List[Triple]:
    """
    Compute the full ancestry chain from (a,b,c) back to (3,4,5).

    Time complexity: O(log c)

    Returns:
        List of triples from (a,b,c) to (3,4,5)
    """
    chain = [(a, b, c)]
    current = (a, b, c)

    while current != ROOT:
        result = find_parent(*current)
        if result is None:
            break
        _, parent = result
        chain.append(parent)
        current = parent

    return chain


# ─── Algorithm 3: Growth Analysis ───────────────────────────────────────────

def min_hypotenuse_at_depth(max_depth: int) -> Dict[int, int]:
    """
    Compute the minimum hypotenuse at each depth of the Berggren tree.

    Used to estimate the exponential growth rate λ.

    Time complexity: O(3^d)

    Returns:
        Dictionary mapping depth to minimum hypotenuse at that depth
    """
    levels = enumerate_by_depth(max_depth)
    return {d: min(t[2] for t in triples) for d, triples in levels.items()}


def estimate_growth_rate(max_depth: int = 12) -> float:
    """
    Estimate the base λ of exponential growth: c_min(d) ≈ C·λ^d.

    Uses linear regression on log(c_min) vs depth.

    Returns:
        Estimated growth rate λ
    """
    min_hyps = min_hypotenuse_at_depth(max_depth)
    depths = list(range(2, max_depth + 1))
    log_hyps = [log(min_hyps[d]) for d in depths]

    # Linear regression: log(c) = log(C) + d·log(λ)
    n = len(depths)
    sx = sum(depths)
    sy = sum(log_hyps)
    sxy = sum(d * lh for d, lh in zip(depths, log_hyps))
    sx2 = sum(d * d for d in depths)

    slope = (n * sxy - sx * sy) / (n * sx2 - sx * sx)
    return round(exp_val := __import__('math').exp(slope), 6)


# ─── Algorithm 4: Fixed-Hypotenuse Classification ───────────────────────────

def classify_hypotenuse_multiplicity(max_c: int) -> Dict[int, int]:
    """
    For each hypotenuse value c ≤ max_c, count the number of
    primitive Pythagorean triples (with a < b) having that hypotenuse.

    Uses Euclid parametrization for completeness:
    (a,b,c) = (m²-n², 2mn, m²+n²) with m > n > 0, gcd(m,n) = 1, m-n odd.

    Time complexity: O(max_c)
    Space complexity: O(max_c)

    Returns:
        Dictionary mapping hypotenuse c to number of primitive triples
    """
    counts: Dict[int, int] = defaultdict(int)

    for m in range(2, int(sqrt(max_c)) + 2):
        for n in range(1, m):
            if gcd(m, n) != 1 or (m - n) % 2 == 0:
                continue
            c = m*m + n*n
            if c > max_c:
                break
            counts[c] += 1

    return dict(counts)


def primes_1_mod_4_count(n: int) -> int:
    """Count prime factors of n that are ≡ 1 (mod 4)."""
    count = 0
    d = 2
    temp = n
    while d * d <= temp:
        if temp % d == 0:
            if d % 4 == 1:
                count += 1
            while temp % d == 0:
                temp //= d
        d += 1
    if temp > 1 and temp % 4 == 1:
        count += 1
    return count


def multiplicity_vs_factorization(max_c: int = 10000) -> None:
    """
    Compare actual triple counts with predictions from prime factorization.

    The number of primitive triples with hypotenuse c (considering a < b)
    is 2^(k-1) where k is the number of distinct prime factors p ≡ 1 (mod 4)
    of c, provided c is such a product.

    This validates the fixed-hypotenuse multiplicity hypothesis.
    """
    counts = classify_hypotenuse_multiplicity(max_c)

    print(f"\nHypotenuse multiplicity analysis (c ≤ {max_c}):")
    print(f"{'c':>8} {'actual':>8} {'predicted':>10} {'k(primes≡1mod4)':>16} {'match':>6}")
    print("-" * 52)

    matches = 0
    total = 0
    for c in sorted(counts.keys())[:30]:
        actual = counts[c]
        k = primes_1_mod_4_count(c)
        predicted = 2**(k - 1) if k > 0 else 0
        ok = actual == predicted
        matches += ok
        total += 1
        print(f"{c:>8} {actual:>8} {predicted:>10} {k:>16} {'✓' if ok else '✗':>6}")

    print(f"\nMatches: {matches}/{total}")


# ─── Algorithm 5: Depth Statistics ──────────────────────────────────────────

def depth_statistics(max_depth: int = 10) -> None:
    """
    Compute and display statistics about the Berggren tree at each depth.
    """
    levels = enumerate_by_depth(max_depth)

    print(f"\n{'Depth':>5} {'Count':>8} {'Min c':>8} {'Max c':>10} {'Avg c':>10} {'Min/λ^d':>10}")
    print("-" * 55)

    lam = 2.0  # approximate growth rate
    for d, triples in sorted(levels.items()):
        hyps = [t[2] for t in triples]
        min_c = min(hyps)
        max_c = max(hyps)
        avg_c = sum(hyps) / len(hyps)
        ratio = min_c / (lam ** d) if d > 0 else min_c
        print(f"{d:>5} {len(triples):>8} {min_c:>8} {max_c:>10} {avg_c:>10.1f} {ratio:>10.4f}")


# ─── Main ────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("=" * 60)
    print("  Berggren Tree Algorithms")
    print("=" * 60)

    # Demo: enumerate by hypotenuse
    print("\n--- Enumeration by hypotenuse (c ≤ 100) ---")
    triples = enumerate_by_hypotenuse(100)
    for t in triples:
        code = word_code(*t)
        print(f"  {t}  word={code}  depth={len(code)}")

    # Demo: ancestry
    print("\n--- Ancestry chain for (119, 120, 169) ---")
    chain = ancestry_chain(119, 120, 169)
    for i, t in enumerate(chain):
        print(f"  {'→ ' if i > 0 else '  '}{t}")
    print(f"  Word code: {word_code(119, 120, 169)}")

    # Demo: depth statistics
    print("\n--- Depth Statistics ---")
    depth_statistics(8)

    # Demo: multiplicity analysis
    print("\n--- Hypotenuse Multiplicity vs. Factorization ---")
    multiplicity_vs_factorization(5000)

    print("\n" + "=" * 60)
    print("  All algorithms completed.")
    print("=" * 60)
