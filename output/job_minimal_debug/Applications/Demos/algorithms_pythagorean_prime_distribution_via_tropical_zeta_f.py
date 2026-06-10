#!/usr/bin/env python3
"""
Algorithms for Tropical Berggren Zeta Functions

Implements the core algorithms from the research paper:
1. Primitive triple generation via Euclid parametrization
2. Berggren tree traversal
3. Tropical weight computation
4. Hypotenuse support detection
5. Admissible prime support verification
"""

from math import gcd, isqrt
from typing import List, Tuple, Set, Dict, Optional
from collections import defaultdict


# ═══════════════════════════════════════════════════════════
# Algorithm 1: Primitive Pythagorean Triple Generation
# ═══════════════════════════════════════════════════════════

def generate_primitive_triples(N: int) -> List[Tuple[int, int, int]]:
    """
    Generate all primitive Pythagorean triples (a, b, c) with c ≤ N
    using the Euclid parametrization: a = m² - n², b = 2mn, c = m² + n²
    where gcd(m, n) = 1 and m - n is odd.

    Time complexity: O(N) (each triple generated in O(log N) for gcd)
    Space complexity: O(N / log N) expected (by prime number theorem applied
                      to hypotenuse density)

    Args:
        N: Upper bound on hypotenuse c

    Returns:
        Sorted list of primitive Pythagorean triples (a, b, c) with a < b
    """
    triples = []
    for m in range(2, isqrt(N) + 1):
        for n in range(1, m):
            if (m - n) % 2 == 0:  # must have opposite parity
                continue
            if gcd(m, n) != 1:
                continue
            a = m * m - n * n
            b = 2 * m * n
            c = m * m + n * n
            if c > N:
                break
            triples.append((min(a, b), max(a, b), c))
    return sorted(triples, key=lambda t: (t[2], t[0]))


# ═══════════════════════════════════════════════════════════
# Algorithm 2: Berggren Tree Traversal
# ═══════════════════════════════════════════════════════════

# The three Berggren matrices acting on (a, b, c):
# A: (a - 2b + 2c,  2a - b + 2c,  2a - 2b + 3c)
# B: (a + 2b + 2c,  2a + b + 2c,  2a + 2b + 3c)
# C: (-a + 2b + 2c, -2a + b + 2c, -2a + 2b + 3c)

def berggren_children(a: int, b: int, c: int) -> List[Tuple[int, int, int]]:
    """
    Compute the three Berggren children of a Pythagorean triple.

    The Berggren tree is a ternary tree rooted at (3, 4, 5) that generates
    all primitive Pythagorean triples. Each node has exactly three children
    obtained by multiplying the column vector (a, b, c)^T by the three
    Berggren matrices.

    Time complexity: O(1)

    Args:
        a, b, c: A primitive Pythagorean triple

    Returns:
        List of three child triples
    """
    return [
        (abs(a - 2*b + 2*c), abs(2*a - b + 2*c), 2*a - 2*b + 3*c),   # Child A
        (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c),               # Child B
        (abs(-a + 2*b + 2*c), abs(-2*a + b + 2*c), -2*a + 2*b + 3*c),  # Child C
    ]


def berggren_tree_bfs(max_hypotenuse: int) -> List[Tuple[int, int, int]]:
    """
    Generate all primitive Pythagorean triples by BFS on the Berggren tree.

    Time complexity: O(T) where T = number of primitive triples with c ≤ N
    Space complexity: O(T)

    Args:
        max_hypotenuse: Upper bound on hypotenuse c

    Returns:
        List of all primitive triples with c ≤ max_hypotenuse
    """
    root = (3, 4, 5)
    queue = [root]
    result = []
    while queue:
        a, b, c = queue.pop(0)
        if c > max_hypotenuse:
            continue
        result.append((min(a, b), max(a, b), c))
        for child in berggren_children(a, b, c):
            if child[2] <= max_hypotenuse:
                queue.append(child)
    return sorted(result, key=lambda t: (t[2], t[0]))


# ═══════════════════════════════════════════════════════════
# Algorithm 3: Tropical Weight Computation
# ═══════════════════════════════════════════════════════════

def tropical_weight(a: int, b: int, c: int) -> int:
    """
    Compute the tropical weight of a Pythagorean triple: c - max(a, b).

    This measures the "distance from the tropical light cone" in the
    max-plus algebra. By Theorem C, this is always nonneg for Pythagorean
    triples, and strictly positive when both legs are positive.

    Time complexity: O(1)
    """
    return c - max(a, b)


def tropical_defect(a: int, b: int, c: int) -> int:
    """
    Compute the tropical defect: min(a, b).

    Dual to the tropical weight via the identity:
    tropical_weight + tropical_defect = c - max(a,b) + min(a,b) = c - (a+b) + 2*min(a,b)

    Time complexity: O(1)
    """
    return min(a, b)


def tropical_zeta_truncation(N: int) -> Dict[str, object]:
    """
    Compute the truncated tropical Berggren zeta statistics up to N.

    Returns:
        Dictionary with:
        - 'T_N': min tropical weight (T(N) = min_{c≤N} (c - max(a,b)))
        - 'Theta_N': max min-leg (Θ(N) = max_{c≤N} min(a,b))
        - 'support': set of supported hypotenuse values
        - 'counts': hypotenuse counting coefficients A(n)
    """
    triples = generate_primitive_triples(N)
    if not triples:
        return {'T_N': None, 'Theta_N': None, 'support': set(), 'counts': {}}

    counts: Dict[int, int] = defaultdict(int)
    for a, b, c in triples:
        counts[c] += 1

    return {
        'T_N': min(tropical_weight(*t) for t in triples),
        'Theta_N': max(tropical_defect(*t) for t in triples),
        'support': set(counts.keys()),
        'counts': dict(counts),
        'num_triples': len(triples),
        'weights': [tropical_weight(*t) for t in triples],
    }


# ═══════════════════════════════════════════════════════════
# Algorithm 4: Admissible Prime Support Verification
# ═══════════════════════════════════════════════════════════

def is_prime(n: int) -> bool:
    """Primality test. Time: O(√n)."""
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


def prime_factors(n: int) -> List[int]:
    """Return the sorted list of distinct prime factors of n. Time: O(√n)."""
    factors = []
    d = 2
    while d * d <= n:
        if n % d == 0:
            factors.append(d)
            while n % d == 0:
                n //= d
        d += 1
    if n > 1:
        factors.append(n)
    return factors


def has_admissible_prime_support(n: int) -> bool:
    """
    Check if every prime divisor of n is 2 or ≡ 1 (mod 4).

    By Theorem B (forward), this is necessary for n to be
    expressible as a sum of two coprime squares.

    Time complexity: O(√n)
    """
    for p in prime_factors(n):
        if p != 2 and p % 4 != 1:
            return False
    return True


def is_sum_of_two_squares(n: int) -> Optional[Tuple[int, int]]:
    """
    Check if n is a sum of two squares; if so, return (x, y) with x² + y² = n.

    Uses Nat.eq_sq_add_sq_iff: n is a sum of two squares iff every prime
    factor q ≡ 3 (mod 4) appears to an even power.

    Time complexity: O(√n)
    """
    # First check necessary condition
    temp = n
    d = 2
    while d * d <= temp:
        if temp % d == 0:
            count = 0
            while temp % d == 0:
                count += 1
                temp //= d
            if d % 4 == 3 and count % 2 == 1:
                return None
        d += 1
    if temp > 1 and temp % 4 == 3:
        return None

    # Find representation
    for x in range(0, isqrt(n) + 1):
        y_sq = n - x * x
        if y_sq < 0:
            break
        y = isqrt(y_sq)
        if y * y == y_sq:
            return (x, y)
    return None


# ═══════════════════════════════════════════════════════════
# Algorithm 5: Berggren Level Statistics
# ═══════════════════════════════════════════════════════════

def berggren_level_statistics(max_depth: int) -> List[Dict]:
    """
    Compute tropical statistics for each level of the Berggren tree.

    Returns per-level statistics including:
    - Number of nodes
    - Min/max/avg tropical weight
    - Min/max hypotenuse

    Time complexity: O(3^max_depth)
    """
    stats = []
    current_level = [(3, 4, 5)]

    for depth in range(max_depth + 1):
        weights = [tropical_weight(*t) for t in current_level]
        hyps = [t[2] for t in current_level]

        stats.append({
            'depth': depth,
            'num_nodes': len(current_level),
            'min_weight': min(weights),
            'max_weight': max(weights),
            'avg_weight': sum(weights) / len(weights),
            'min_hyp': min(hyps),
            'max_hyp': max(hyps),
        })

        # Generate next level
        next_level = []
        for t in current_level:
            for child in berggren_children(*t):
                next_level.append(child)
        current_level = next_level

    return stats


# ═══════════════════════════════════════════════════════════
# Main: Run all algorithms with examples
# ═══════════════════════════════════════════════════════════

if __name__ == "__main__":
    print("=" * 70)
    print("ALGORITHM DEMONSTRATIONS")
    print("=" * 70)

    # Algorithm 1: Euclid parametrization
    print("\n--- Algorithm 1: Primitive Triple Generation (Euclid) ---")
    triples = generate_primitive_triples(100)
    print(f"  Primitive triples with c ≤ 100: {len(triples)}")
    for t in triples[:5]:
        print(f"    {t}")

    # Algorithm 2: Berggren tree
    print("\n--- Algorithm 2: Berggren Tree BFS ---")
    tree_triples = berggren_tree_bfs(100)
    print(f"  Triples from Berggren tree (c ≤ 100): {len(tree_triples)}")
    assert set(triples) == set(tree_triples), "Berggren and Euclid must agree!"
    print(f"  ✓ Berggren tree produces same set as Euclid parametrization")

    # Algorithm 3: Tropical zeta
    print("\n--- Algorithm 3: Tropical Zeta Truncation ---")
    stats = tropical_zeta_truncation(500)
    print(f"  N=500: {stats['num_triples']} triples, T(N)={stats['T_N']}, Θ(N)={stats['Theta_N']}")
    print(f"  Support size: {len(stats['support'])}")

    # Algorithm 4: Prime support
    print("\n--- Algorithm 4: Admissible Prime Support ---")
    for n in [5, 10, 13, 15, 25, 50, 65, 85]:
        adm = has_admissible_prime_support(n)
        s2s = is_sum_of_two_squares(n)
        print(f"  n={n:>3}: admissible={adm}, sum_of_squares={s2s}")

    # Algorithm 5: Berggren level statistics
    print("\n--- Algorithm 5: Berggren Level Statistics ---")
    level_stats = berggren_level_statistics(5)
    print(f"  {'Depth':<6} {'Nodes':<8} {'MinW':<6} {'MaxW':<6} {'AvgW':<8} {'MinC':<8} {'MaxC'}")
    for s in level_stats:
        print(f"  {s['depth']:<6} {s['num_nodes']:<8} {s['min_weight']:<6} "
              f"{s['max_weight']:<6} {s['avg_weight']:<8.1f} {s['min_hyp']:<8} {s['max_hyp']}")

    print("\n✓ All algorithms executed successfully")
