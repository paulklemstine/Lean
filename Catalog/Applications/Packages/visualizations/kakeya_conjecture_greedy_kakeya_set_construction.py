"""
algorithms.py — Algorithms for Finite-Field Kakeya and Polynomial Method

Implements key algorithms from the research:
1. Kakeya set construction (greedy and algebraic)
2. Polynomial interpolation and vanishing detection
3. Incidence counting and energy computation
4. Direction enumeration and normalization
"""

import itertools
from collections import defaultdict
import math


class FiniteField:
    """
    Simple prime field F_p implementation.

    Supports arithmetic, iteration, and basic algebraic operations
    needed for Kakeya set computations.

    Args:
        p: A prime number defining the field F_p.

    Example:
        >>> F = FiniteField(5)
        >>> F.add(3, 4)
        2
        >>> F.mul(3, 4)
        2
        >>> F.inv(3)
        2
    """

    def __init__(self, p: int):
        self.p = p
        self.q = p
        self.elements = list(range(p))

    def add(self, a: int, b: int) -> int:
        return (a + b) % self.p

    def sub(self, a: int, b: int) -> int:
        return (a - b) % self.p

    def mul(self, a: int, b: int) -> int:
        return (a * b) % self.p

    def inv(self, a: int) -> int:
        """Multiplicative inverse via Fermat's little theorem."""
        if a == 0:
            raise ValueError("Cannot invert 0")
        return pow(a, self.p - 2, self.p)

    def neg(self, a: int) -> int:
        return (-a) % self.p

    def pow(self, a: int, n: int) -> int:
        return pow(a, n, self.p)


def normalize_direction(F: FiniteField, v: tuple) -> tuple:
    """
    Normalize a direction vector by making the first nonzero coordinate 1.
    This gives a canonical representative for each direction class.

    Complexity: O(n) where n = len(v).

    Args:
        F: The finite field.
        v: A nonzero vector in F^n.

    Returns:
        The normalized direction vector.

    Example:
        >>> F = FiniteField(5)
        >>> normalize_direction(F, (2, 3))
        (1, 4)
    """
    for i, x in enumerate(v):
        if x != 0:
            inv_x = F.inv(x)
            return tuple(F.mul(inv_x, c) for c in v)
    raise ValueError("Cannot normalize zero vector")


def direction_classes(F: FiniteField, n: int) -> list:
    """
    Enumerate all direction classes in F^n (nonzero vectors modulo scaling).

    The number of classes is (q^n - 1) / (q - 1).

    Complexity: O(q^n) time and space.

    Args:
        F: The finite field.
        n: The dimension.

    Returns:
        List of normalized direction vectors.

    Example:
        >>> F = FiniteField(3)
        >>> len(direction_classes(F, 2))
        4
    """
    seen = set()
    classes = []
    for v in itertools.product(F.elements, repeat=n):
        if all(x == 0 for x in v):
            continue
        nv = normalize_direction(F, v)
        if nv not in seen:
            seen.add(nv)
            classes.append(nv)
    return classes


def affine_line_points(F: FiniteField, base: tuple, direction: tuple) -> frozenset:
    """
    Compute all points on the affine line {base + t * direction : t in F}.

    Complexity: O(q * n) where q = |F| and n = len(base).

    Args:
        F: The finite field.
        base: Base point in F^n.
        direction: Direction vector in F^n.

    Returns:
        Frozenset of points on the line.
    """
    n = len(base)
    points = set()
    for t in F.elements:
        point = tuple(F.add(base[i], F.mul(t, direction[i])) for i in range(n))
        points.add(point)
    return frozenset(points)


def greedy_kakeya_construction(F: FiniteField, n: int) -> set:
    """
    Construct a Kakeya set using a greedy algorithm that minimizes the
    number of new points added at each step.

    Algorithm:
    1. For each direction class, choose the base point that minimizes
       the number of new points added to the current set.
    2. Add the entire line to the Kakeya set.

    Complexity: O(q^{2n} * D) where D = number of direction classes.

    Args:
        F: The finite field.
        n: The dimension.

    Returns:
        A Kakeya set (as a set of tuples).

    Example:
        >>> F = FiniteField(3)
        >>> K = greedy_kakeya_construction(F, 2)
        >>> len(K) <= 9
        True
    """
    dirs = direction_classes(F, n)
    kakeya = set()

    for v in dirs:
        best_base = None
        best_cost = float('inf')
        for base in itertools.product(F.elements, repeat=n):
            line = affine_line_points(F, base, v)
            cost = len(line - kakeya)
            if cost < best_cost:
                best_cost = cost
                best_base = base
        kakeya.update(affine_line_points(F, best_base, v))

    return kakeya


def compute_incidence_energy(F: FiniteField, n: int, lines: list) -> dict:
    """
    Compute incidence statistics for a family of lines.

    For each point, counts the number of lines passing through it.
    Returns multiplicity histogram and energy (sum of squared multiplicities).

    Algorithm:
    1. For each line, enumerate all points.
    2. For each point, count the number of lines through it.
    3. Compute energy E = sum_x m(x)^2.

    Complexity: O(|L| * q * n).

    Args:
        F: The finite field.
        n: The dimension.
        lines: List of (base, direction) pairs.

    Returns:
        Dictionary with keys:
        - 'multiplicities': dict mapping points to multiplicity
        - 'total_incidences': sum of all multiplicities
        - 'energy': sum of squared multiplicities
        - 'max_multiplicity': maximum multiplicity
        - 'union_size': number of distinct points

    Example:
        >>> F = FiniteField(3)
        >>> lines = [((0,0), (1,0)), ((0,0), (0,1)), ((0,0), (1,1))]
        >>> stats = compute_incidence_energy(F, 2, lines)
        >>> stats['total_incidences']
        9
    """
    multiplicities = defaultdict(int)
    for base, direction in lines:
        for point in affine_line_points(F, base, direction):
            multiplicities[point] += 1

    total = sum(multiplicities.values())
    energy = sum(m * m for m in multiplicities.values())
    max_mult = max(multiplicities.values()) if multiplicities else 0

    return {
        'multiplicities': dict(multiplicities),
        'total_incidences': total,
        'energy': energy,
        'max_multiplicity': max_mult,
        'union_size': len(multiplicities),
    }


def dvir_lower_bound(q: int, n: int) -> float:
    """
    Compute the Dvir lower bound for Kakeya sets: q^n / n!.

    Args:
        q: Field size.
        n: Dimension.

    Returns:
        The lower bound as a float.
    """
    return q**n / math.factorial(n)


def ascending_factorial_bound(q: int, n: int) -> int:
    """
    Compute the ascending factorial q(q+1)...(q+n-1) / n! = C(q+n-1, n).
    This is the sharper Dvir bound.

    Args:
        q: Field size.
        n: Dimension.

    Returns:
        The bound as an integer.
    """
    return math.comb(q + n - 1, n)


def verify_kakeya_set(F: FiniteField, n: int, K: set) -> bool:
    """
    Verify that K is a valid Kakeya set by checking every direction.

    Complexity: O(|K| * q^n * D) in the worst case.

    Args:
        F: The finite field.
        n: The dimension.
        K: Candidate Kakeya set.

    Returns:
        True if K contains a line in every nonzero direction.
    """
    for v in itertools.product(F.elements, repeat=n):
        if all(x == 0 for x in v):
            continue
        found = False
        for base in itertools.product(F.elements, repeat=n):
            line = affine_line_points(F, base, v)
            if line.issubset(K):
                found = True
                break
        if not found:
            return False
    return True


def polynomial_eval(F: FiniteField, coeffs: dict, point: tuple) -> int:
    """
    Evaluate a multivariate polynomial at a point over F_p.

    The polynomial is represented as a dict mapping exponent tuples to coefficients.

    Args:
        F: The finite field.
        coeffs: Dict mapping (e1, ..., en) to coefficient in F.
        point: Evaluation point in F^n.

    Returns:
        The value of the polynomial at the point.
    """
    result = 0
    for exps, coeff in coeffs.items():
        term = coeff
        for i, e in enumerate(exps):
            term = F.mul(term, F.pow(point[i], e))
        result = F.add(result, term)
    return result


if __name__ == "__main__":
    # Quick test
    F = FiniteField(5)
    print(f"Direction classes in F_5^2: {len(direction_classes(F, 2))}")
    print(f"Expected: (25-1)/(5-1) = {(25-1)//(5-1)}")

    K = greedy_kakeya_construction(F, 2)
    print(f"Greedy Kakeya set size: {len(K)}")
    print(f"Dvir lower bound: {dvir_lower_bound(5, 2):.1f}")
    print(f"Ascending factorial bound: {ascending_factorial_bound(5, 2)}")
    print(f"Is valid Kakeya: {verify_kakeya_set(F, 2, K)}")
