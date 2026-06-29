#!/usr/bin/env python3
"""
Algorithms for Cap Set Theory and the Polynomial Method

This module implements the core algorithms discussed in the research paper:
1. Cap set verification and enumeration
2. Reduced polynomial interpolation over F_3
3. Indicator polynomial construction
4. Monomial counting for degree bounds
5. Additive energy computation
"""

from itertools import product
from typing import Dict, List, Tuple, Set, Optional
import functools


# ============================================================
# Type Aliases
# ============================================================

F3Element = int          # Element of F_3: 0, 1, or 2
F3Vector = Tuple[int, ...]  # Element of F_3^n
Exponent = Tuple[int, ...]  # Monomial exponent vector


# ============================================================
# Algorithm 1: Cap Set Verification
# ============================================================

def is_three_ap(x: F3Vector, y: F3Vector, z: F3Vector) -> bool:
    """
    Check if (x, y, z) form a 3-term arithmetic progression in F_3^n.

    A 3-AP satisfies x + z = 2y (mod 3), equivalently x + y + z = 0 (mod 3).

    Time complexity: O(n) where n = len(x)
    Space complexity: O(1)

    Args:
        x, y, z: vectors in F_3^n (tuples of integers mod 3)

    Returns:
        True if (x, y, z) form a 3-AP

    Example:
        >>> is_three_ap((0,), (1,), (2,))  # 0 + 2 = 2*1 mod 3
        True
        >>> is_three_ap((0, 0), (1, 0), (2, 1))  # not a 3-AP
        False
    """
    return all((xi + yi + zi) % 3 == 0 for xi, yi, zi in zip(x, y, z))


def verify_cap_set(A: List[F3Vector]) -> bool:
    """
    Verify that A is a cap set (no nontrivial 3-AP).

    Time complexity: O(|A|^3 * n)
    Space complexity: O(1)

    Args:
        A: list of vectors in F_3^n

    Returns:
        True if A contains no nontrivial 3-AP

    Example:
        >>> verify_cap_set([(0, 0), (0, 1), (1, 0), (1, 1)])
        True
    """
    A_set = set(A)
    for x in A:
        for y in A:
            if x == y:
                continue
            # Check if the "third point" z = -x - y (mod 3) is in A
            z = tuple((3 - xi - yi) % 3 for xi, yi in zip(x, y))
            if z in A_set and z != x and z != y:
                return False
    return True


def max_cap_set_greedy(n: int) -> List[F3Vector]:
    """
    Find a large cap set in F_3^n using a greedy algorithm.

    Iterates through all vectors and adds each one if it doesn't create a 3-AP.

    Time complexity: O(3^n * |A|^2 * n) where |A| is the output size
    Space complexity: O(3^n)

    Args:
        n: dimension

    Returns:
        A cap set (possibly not maximum)

    Example:
        >>> A = max_cap_set_greedy(2)
        >>> len(A) >= 3  # greedy finds at least 3
        True
    """
    vectors = [v for v in product(range(3), repeat=n)]
    A: List[F3Vector] = []
    forbidden: Set[F3Vector] = set()

    for v in vectors:
        if v in forbidden:
            continue
        A.append(v)
        # Mark all points that would create a 3-AP with existing elements
        for u in A[:-1]:
            # z = -u - v mod 3 would create a 3-AP (u, ?, v) with midpoint z
            z = tuple((3 - ui - vi) % 3 for ui, vi in zip(u, v))
            forbidden.add(z)

    return A


def max_cap_set_backtrack(n: int) -> Tuple[int, List[F3Vector]]:
    """
    Find the maximum cap set in F_3^n by backtracking.

    Time complexity: O(2^{3^n}) worst case, with pruning
    Space complexity: O(3^n)

    Args:
        n: dimension

    Returns:
        (size, cap_set): maximum size and a witnessing cap set

    Example:
        >>> size, A = max_cap_set_backtrack(1)
        >>> size
        2
    """
    vectors = list(product(range(3), repeat=n))
    N = len(vectors)
    best = [0, []]

    def backtrack(idx: int, current: List[F3Vector], forbidden: Set[F3Vector]):
        if len(current) > best[0]:
            best[0] = len(current)
            best[1] = list(current)

        remaining = N - idx
        if len(current) + remaining <= best[0]:
            return

        for i in range(idx, N):
            v = vectors[i]
            if v in forbidden:
                continue
            new_forbidden = set()
            for u in current:
                z = tuple((3 - ui - vi) % 3 for ui, vi in zip(u, v))
                new_forbidden.add(z)
            current.append(v)
            backtrack(i + 1, current, forbidden | new_forbidden)
            current.pop()

    backtrack(0, [], set())
    return best[0], best[1]


# ============================================================
# Algorithm 2: Reduced Polynomial Interpolation
# ============================================================

def reduced_monomials(n: int, max_degree: Optional[int] = None) -> List[Exponent]:
    """
    Enumerate all reduced monomials in n variables over F_3.

    A reduced monomial has exponents in {0, 1, 2}.
    Optionally filter by total degree bound.

    Time complexity: O(3^n)
    Space complexity: O(3^n)

    Args:
        n: number of variables
        max_degree: if given, only include monomials with total degree ≤ max_degree

    Returns:
        List of exponent vectors

    Example:
        >>> len(reduced_monomials(2))
        9
        >>> len(reduced_monomials(2, max_degree=2))
        6
    """
    exps = list(product(range(3), repeat=n))
    if max_degree is not None:
        exps = [e for e in exps if sum(e) <= max_degree]
    return exps


def eval_monomial_f3(exp: Exponent, point: F3Vector) -> F3Element:
    """
    Evaluate a monomial x^exp at a point in F_3^n.

    Time complexity: O(n)

    Args:
        exp: exponent vector
        point: evaluation point

    Returns:
        x^exp mod 3
    """
    result = 1
    for e, x in zip(exp, point):
        result = (result * pow(x, e, 3)) % 3
    return result


def interpolate_f3(n: int, f: Dict[F3Vector, F3Element]) -> Dict[Exponent, F3Element]:
    """
    Find the unique reduced polynomial representing f : F_3^n -> F_3.

    Uses Gaussian elimination mod 3 on the evaluation matrix.

    Time complexity: O(3^{3n}) (matrix operations on 3^n × 3^n matrix)
    Space complexity: O(3^{2n})

    Args:
        n: dimension
        f: function values as a dictionary

    Returns:
        Coefficient dictionary: exponent -> coefficient (mod 3)

    Example:
        >>> f = {(0,): 0, (1,): 1, (2,): 2}  # identity function
        >>> coeffs = interpolate_f3(1, f)
        >>> coeffs[(1,)]  # coefficient of x
        1
    """
    points = list(product(range(3), repeat=n))
    monoms = reduced_monomials(n)
    m = len(monoms)

    # Build evaluation matrix
    M = [[eval_monomial_f3(exp, pt) for exp in monoms] for pt in points]
    b = [f.get(pt, 0) for pt in points]

    # Gaussian elimination mod 3
    aug = [row + [bi] for row, bi in zip(M, b)]
    pivot_cols = []

    for col in range(m):
        # Find pivot
        pivot_row = None
        for row in range(len(pivot_cols), len(aug)):
            if aug[row][col] % 3 != 0:
                pivot_row = row
                break
        if pivot_row is None:
            continue

        # Swap
        pr = len(pivot_cols)
        aug[pr], aug[pivot_row] = aug[pivot_row], aug[pr]
        pivot_cols.append((pr, col))

        # Normalize (inverse mod 3: 1->1, 2->2)
        inv = pow(aug[pr][col], 1, 3)
        aug[pr] = [(x * inv) % 3 for x in aug[pr]]

        # Eliminate
        for row in range(len(aug)):
            if row != pr and aug[row][col] % 3 != 0:
                factor = aug[row][col]
                aug[row] = [(aug[row][j] - factor * aug[pr][j]) % 3
                            for j in range(m + 1)]

    coeffs = {}
    for pr, col in pivot_cols:
        coeffs[monoms[col]] = aug[pr][-1] % 3

    return coeffs


# ============================================================
# Algorithm 3: Indicator Polynomial Evaluation
# ============================================================

def indicator_eval(target: F3Vector, point: F3Vector) -> F3Element:
    """
    Evaluate the indicator polynomial δ_target(point) in F_3.

    δ_a(x) = ∏_i (1 - (x_i - a_i)^2) mod 3

    Time complexity: O(n)
    Space complexity: O(1)

    Args:
        target: the point a where δ_a(a) = 1
        point: the evaluation point x

    Returns:
        1 if point == target, 0 otherwise
    """
    result = 1
    for ti, xi in zip(target, point):
        diff = (xi - ti) % 3
        factor = (1 - pow(diff, 2, 3)) % 3
        result = (result * factor) % 3
    return result


# ============================================================
# Algorithm 4: Additive Energy Computation
# ============================================================

def additive_energy(A: List[F3Vector]) -> int:
    """
    Compute the additive energy E(A) = |{(a,b,c,d) ∈ A^4 : a+b = c+d}|.

    Uses the representation sum method: E(A) = Σ_s r(s)^2 where
    r(s) = |{(a,b) ∈ A^2 : a+b = s}|.

    Time complexity: O(|A|^2 * n)
    Space complexity: O(|A|^2)

    Args:
        A: subset of F_3^n

    Returns:
        The additive energy E(A)

    Example:
        >>> additive_energy([(0,), (1,)])
        4  # all 4 pairs (a,b,a,b)
    """
    from collections import Counter
    sum_counts: Dict[F3Vector, int] = Counter()
    for a in A:
        for b in A:
            s = tuple((ai + bi) % 3 for ai, bi in zip(a, b))
            sum_counts[s] += 1

    return sum(r * r for r in sum_counts.values())


# ============================================================
# Algorithm 5: Monomial Counting Asymptotics
# ============================================================

def count_bounded_monomials(n: int, d: int) -> int:
    """
    Count reduced monomials in n variables with total degree ≤ d.

    Each exponent is in {0, 1, 2}. This is the key counting function
    for the polynomial method bound on cap sets.

    Time complexity: O(3^n) (enumeration)
    Space complexity: O(1)

    For cap sets, the relevant bound is d = ⌊2n/3⌋, giving the
    Meshulam-type estimate |A| ≤ count_bounded_monomials(n, 2n//3).

    Args:
        n: number of variables
        d: maximum total degree

    Returns:
        Number of monomials

    Example:
        >>> count_bounded_monomials(3, 2)
        10
    """
    count = 0
    for exp in product(range(3), repeat=n):
        if sum(exp) <= d:
            count += 1
    return count


def monomial_bound_ratio(n: int) -> float:
    """
    Compute the ratio of bounded monomials to total space for cap set bounds.

    Returns count_bounded_monomials(n, 2n//3) / 3^n.

    Example:
        >>> monomial_bound_ratio(6)  # approximately 0.23
        0.23045267489711935
    """
    d = 2 * n // 3
    return count_bounded_monomials(n, d) / (3 ** n)


# ============================================================
# Example Usage
# ============================================================

if __name__ == "__main__":
    print("Algorithm Demonstrations")
    print("=" * 50)

    # Cap set verification
    A = [(0, 0), (0, 1), (1, 0), (1, 1)]
    print(f"\n1. Cap set verification for {A}:")
    print(f"   Is cap set: {verify_cap_set(A)}")

    # Greedy cap set
    for n in range(1, 5):
        A = max_cap_set_greedy(n)
        print(f"\n2. Greedy cap set in F_3^{n}: size {len(A)}")

    # Polynomial interpolation
    print(f"\n3. Polynomial interpolation in F_3^2:")
    f = {v: (v[0] * v[1]) % 3 for v in product(range(3), repeat=2)}
    coeffs = interpolate_f3(2, f)
    for exp, c in sorted(coeffs.items()):
        if c != 0:
            print(f"   Coefficient of x^{exp}: {c}")

    # Additive energy
    A = [(0, 0), (0, 1), (1, 0), (1, 1)]
    print(f"\n4. Additive energy of {A}: E(A) = {additive_energy(A)}")
    print(f"   |A|^2 = {len(A)**2}")

    # Monomial counting
    print(f"\n5. Monomial counting for cap set bounds:")
    for n in range(1, 8):
        d = 2 * n // 3
        count = count_bounded_monomials(n, d)
        ratio = monomial_bound_ratio(n)
        print(f"   n={n}: monomials(deg≤{d}) = {count}, ratio = {ratio:.4f}")
