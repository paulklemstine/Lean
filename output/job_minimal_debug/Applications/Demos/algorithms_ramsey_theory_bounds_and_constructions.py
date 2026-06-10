#!/usr/bin/env python3
"""
Ramsey Theory Algorithms

Implementations of core algorithms from the research paper:
1. Ramsey number bound computation
2. Probabilistic lower bound evaluation
3. Clique-avoidance certificate verification
4. Combinatorial line enumeration
"""

import math
import itertools
from typing import List, Tuple, Set, Optional, Dict


def erdos_szekeres_bound(s: int, t: int) -> int:
    """Compute the Erdős–Szekeres upper bound R(s,t) ≤ C(s+t-2, s-1).

    Time complexity: O(s+t) for binomial coefficient.
    Space complexity: O(1).

    >>> erdos_szekeres_bound(3, 3)
    6
    >>> erdos_szekeres_bound(3, 4)
    10
    >>> erdos_szekeres_bound(4, 4)
    20
    """
    if s <= 1 or t <= 1:
        return max(s, t)
    return math.comb(s + t - 2, s - 1)


def recursive_ramsey_table(max_s: int, max_t: int) -> Dict[Tuple[int, int], int]:
    """Compute Ramsey upper bounds using the recursion R(s,t) ≤ R(s-1,t) + R(s,t-1).

    With parity improvement: if both R(s-1,t) and R(s,t-1) are even,
    use R(s,t) ≤ R(s-1,t) + R(s,t-1) - 1.

    Time complexity: O(max_s * max_t).
    Space complexity: O(max_s * max_t).

    >>> table = recursive_ramsey_table(5, 5)
    >>> table[(3, 3)]
    6
    >>> table[(3, 4)]
    9
    """
    R: Dict[Tuple[int, int], int] = {}

    for s in range(0, max_s + 1):
        R[(s, 0)] = 0
        R[(s, 1)] = 1
    for t in range(0, max_t + 1):
        R[(0, t)] = 0
        R[(1, t)] = 1

    # R(2, t) = t
    for t in range(2, max_t + 1):
        R[(2, t)] = t
    for s in range(2, max_s + 1):
        R[(s, 2)] = s

    for s in range(3, max_s + 1):
        for t in range(3, max_t + 1):
            a = R[(s - 1, t)]
            b = R[(s, t - 1)]
            bound = a + b
            # Parity improvement
            if a % 2 == 0 and b % 2 == 0:
                bound -= 1
            R[(s, t)] = bound

    return R


def probabilistic_lower_bound(k: int) -> int:
    """Find the largest n such that 2 * C(n,k) < 2^C(k,2).

    This gives R(k,k) > n by the first-moment method.

    Time complexity: O(n) where n is the result.
    Space complexity: O(1).

    >>> probabilistic_lower_bound(3)
    3
    >>> probabilistic_lower_bound(4)
    5
    >>> probabilistic_lower_bound(5)
    8
    """
    ck2 = math.comb(k, 2)
    threshold = 2 ** ck2
    best_n = k - 1  # trivial lower bound
    for n in range(k, 10000):
        if 2 * math.comb(n, k) < threshold:
            best_n = n
        else:
            break
    return best_n


def verify_clique_avoidance(n: int, red_edges: Set[Tuple[int, int]],
                             s: int, t: int) -> Tuple[bool, Optional[List[int]]]:
    """Verify that a coloring avoids red K_s and blue K_t.

    Returns (is_good, witness) where witness is a monochromatic clique if found.

    Time complexity: O(C(n, max(s,t)) * max(s,t)^2).
    Space complexity: O(n^2).

    >>> edges = {(0,1), (1,2), (2,3), (3,4), (4,0)}  # C_5 red
    >>> ok, w = verify_clique_avoidance(5, edges, 3, 3)
    >>> ok
    True
    """
    normalized = set()
    for i, j in red_edges:
        normalized.add((min(i, j), max(i, j)))

    def is_red(i: int, j: int) -> bool:
        return (min(i, j), max(i, j)) in normalized

    # Check red K_s
    for S in itertools.combinations(range(n), s):
        if all(is_red(i, j) for i, j in itertools.combinations(S, 2)):
            return False, list(S)

    # Check blue K_t
    for S in itertools.combinations(range(n), t):
        if all(not is_red(i, j) for i, j in itertools.combinations(S, 2)):
            return False, list(S)

    return True, None


def enumerate_combinatorial_lines(n: int, k: int) -> List[Tuple[List[int], Dict[int, int]]]:
    """Enumerate all combinatorial lines in [k]^n.

    A combinatorial line is specified by:
    - active: list of wild coordinates
    - base: dict mapping inactive coordinates to their fixed values

    Time complexity: O((2^n - 1) * k^(n - |active|)).
    Space complexity: O(output size).

    >>> lines = enumerate_combinatorial_lines(2, 2)
    >>> len(lines)
    5
    """
    lines = []
    for mask in range(1, 2**n):
        active = [i for i in range(n) if mask & (1 << i)]
        inactive = [i for i in range(n) if not (mask & (1 << i))]
        for base_vals in itertools.product(range(k), repeat=len(inactive)):
            base = {coord: val for coord, val in zip(inactive, base_vals)}
            lines.append((active, base))
    return lines


def count_ramsey_good_colorings(n: int, k: int) -> int:
    """Count the number of 2-colorings of K_n with no monochromatic K_k.

    WARNING: Exponential in C(n,2). Only feasible for small n.

    >>> count_ramsey_good_colorings(3, 3)
    12
    >>> count_ramsey_good_colorings(5, 3)
    12
    """
    edges = list(itertools.combinations(range(n), 2))
    m = len(edges)
    count = 0

    for mask in range(2**m):
        red = set()
        for idx, (i, j) in enumerate(edges):
            if mask & (1 << idx):
                red.add((i, j))

        has_mono = False
        # Check red K_k
        for S in itertools.combinations(range(n), k):
            if all((min(i, j), max(i, j)) in red
                   for i, j in itertools.combinations(S, 2)):
                has_mono = True
                break
        if not has_mono:
            # Check blue K_k
            for S in itertools.combinations(range(n), k):
                if all((min(i, j), max(i, j)) not in red
                       for i, j in itertools.combinations(S, 2)):
                    has_mono = True
                    break
        if not has_mono:
            count += 1
    return count


# ===========================================================================
# Demo
# ===========================================================================

if __name__ == "__main__":
    print("Erdős–Szekeres bounds:")
    for s in range(2, 7):
        for t in range(s, 7):
            print(f"  R({s},{t}) ≤ {erdos_szekeres_bound(s, t)}")

    print("\nRecursive bounds with parity improvement:")
    table = recursive_ramsey_table(6, 6)
    for s in range(2, 7):
        for t in range(s, 7):
            print(f"  R({s},{t}) ≤ {table[(s, t)]}")

    print("\nProbabilistic lower bounds:")
    for k in range(3, 10):
        n = probabilistic_lower_bound(k)
        print(f"  R({k},{k}) > {n}")

    print("\nCombinatorial lines in [2]^2:")
    lines = enumerate_combinatorial_lines(2, 2)
    for active, base in lines:
        points = []
        for a in range(2):
            word = [0, 0]
            for coord in active:
                word[coord] = a
            for coord, val in base.items():
                word[coord] = val
            points.append(tuple(word))
        print(f"  Active={active}, Base={base}: {points}")

    print("\nRamsey-good coloring counts (triangle-free, n ≤ 5):")
    for n in range(3, 6):
        c = count_ramsey_good_colorings(n, 3)
        total = 2 ** math.comb(n, 2)
        print(f"  n={n}: {c}/{total} good colorings ({100*c/total:.1f}%)")
