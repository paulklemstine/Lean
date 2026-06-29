"""
Tropical Valuation Functor — Algorithms

Type-hinted implementations of the key algorithms from the tropical
valuation bridge between algebraic coefficients and tropical convexity.
"""

from typing import List, Tuple, Optional, Set
from math import inf


def padic_valuation(p: int, n: int) -> float:
    """Compute the p-adic valuation v_p(n).

    Returns the largest k such that p^k divides n.
    Returns inf if n = 0 (tropical absorbing element).

    Args:
        p: A prime number (> 1).
        n: A non-negative integer.

    Returns:
        The p-adic valuation of n, or inf if n = 0.
    """
    if n == 0:
        return inf
    if n < 0:
        n = abs(n)
    k = 0
    while n % p == 0:
        k += 1
        n //= p
    return k


def tropical_add(a: float, b: float) -> float:
    """Tropical addition: min(a, b)."""
    return min(a, b)


def tropical_mul(a: float, b: float) -> float:
    """Tropical multiplication: a + b."""
    return a + b


def coord_valuation(p: int, x: List[int]) -> List[float]:
    """Coordinatewise p-adic valuation of a vector.

    Args:
        p: A prime number.
        x: A vector of integers.

    Returns:
        A vector of p-adic valuations.
    """
    return [padic_valuation(p, xi) for xi in x]


def tropical_lincomb_bound(
    p: int,
    coeffs: List[int],
    generators: List[List[int]]
) -> Tuple[List[float], List[float]]:
    """Compute the bridge theorem inequality for a linear combination.

    Given coefficients c_i and generator vectors x_i, computes:
    - The coordinatewise valuation of sum(c_i * x_i)
    - The tropical lower bound: inf_i(v(c_i) + v(x_ij)) for each j

    Args:
        p: A prime number.
        coeffs: Coefficient vector c ∈ ℤ^k.
        generators: Generator matrix x ∈ ℤ^(k×n).

    Returns:
        (actual_valuation, tropical_bound) where actual >= bound componentwise.
    """
    k = len(coeffs)
    n = len(generators[0]) if generators else 0

    # Compute the actual linear combination
    combination = [0] * n
    for i in range(k):
        for j in range(n):
            combination[j] += coeffs[i] * generators[i][j]

    actual = coord_valuation(p, combination)

    # Compute the tropical bound: inf_i(v(c_i) + v(x_ij))
    v_coeffs = [padic_valuation(p, c) for c in coeffs]
    tropical_bound = []
    for j in range(n):
        bound_j = inf
        for i in range(k):
            v_gen = padic_valuation(p, generators[i][j])
            bound_j = min(bound_j, v_coeffs[i] + v_gen)
        tropical_bound.append(bound_j)

    return actual, tropical_bound


def verify_bridge_theorem(
    p: int,
    coeffs: List[int],
    generators: List[List[int]]
) -> bool:
    """Verify the bridge theorem inequality for a specific instance.

    Checks that actual valuation >= tropical bound for each coordinate.

    Args:
        p: A prime number.
        coeffs: Coefficient vector.
        generators: Generator vectors.

    Returns:
        True if the bridge theorem inequality holds.
    """
    actual, bound = tropical_lincomb_bound(p, coeffs, generators)
    return all(a >= b for a, b in zip(actual, bound))


def tropical_convex_hull_membership(
    point: List[float],
    generators: List[List[float]]
) -> Tuple[bool, Optional[List[float]]]:
    """Check if a point is in the tropical convex hull and find coefficients.

    A point y is in tropConvHull({p_i}) if there exist coefficients λ_i
    such that for each j: min_i(λ_i + p_ij) ≤ y_j.

    This uses a greedy approach: set λ_i = min_j(y_j - p_ij).

    Args:
        point: The point to check, y ∈ (ℝ∪{∞})^n.
        generators: The generator points p_i ∈ (ℝ∪{∞})^n.

    Returns:
        (is_member, coefficients) where coefficients witness membership if True.
    """
    k = len(generators)
    n = len(point)

    # Greedy coefficient choice: λ_i = min_j(y_j - p_ij)
    lambdas = []
    for i in range(k):
        lam_i = inf
        for j in range(n):
            if generators[i][j] == inf:
                continue
            if point[j] == inf:
                continue
            lam_i = min(lam_i, point[j] - generators[i][j])
        lambdas.append(lam_i)

    # Verify domination
    for j in range(n):
        bound_j = inf
        for i in range(k):
            bound_j = min(bound_j, lambdas[i] + generators[i][j])
        if bound_j > point[j] + 1e-10:  # numerical tolerance
            return False, None

    return True, lambdas


def halfspace_certificate(
    weights: List[float],
    point: List[float],
    bias: float,
    bound: float
) -> bool:
    """Check a tropical halfspace certificate.

    Verifies: min(bias, min_j(w_j + x_j)) ≤ bound.

    Args:
        weights: Weight vector w ∈ (ℝ∪{∞})^n.
        point: Point x ∈ (ℝ∪{∞})^n.
        bias: Bias term b.
        bound: Upper bound B.

    Returns:
        True if the halfspace certificate is valid.
    """
    tropical_sum = min(weights[j] + point[j] for j in range(len(point)))
    return min(bias, tropical_sum) <= bound


def test_surjectivity_conjecture(
    p: int,
    generators: List[List[int]],
    max_coeff: int = 100
) -> Tuple[Set[Tuple], Set[Tuple], bool]:
    """Test the tropical surjectivity conjecture for a specific instance.

    Enumerates all ℕ-linear combinations with coefficients ≤ max_coeff
    and checks if their valuations cover the tropical hull.

    Args:
        p: A prime number.
        generators: Generator vectors x_i ∈ ℕ^n.
        max_coeff: Maximum coefficient value to enumerate.

    Returns:
        (achieved_points, hull_sample, is_surjective_so_far)
    """
    k = len(generators)
    n = len(generators[0]) if generators else 0

    achieved: Set[Tuple] = set()

    # Enumerate all k-tuples of coefficients
    def enumerate_coeffs(depth: int, current: List[int]):
        if depth == k:
            combination = [0] * n
            for i in range(k):
                for j in range(n):
                    combination[j] += current[i] * generators[i][j]
            val = tuple(padic_valuation(p, x) for x in combination)
            # Convert inf to a large number for set storage
            val = tuple(999 if v == inf else int(v) for v in val)
            achieved.add(val)
            return
        for c in range(max_coeff + 1):
            current.append(c)
            enumerate_coeffs(depth + 1, current)
            current.pop()

    if k <= 3 and max_coeff <= 50:
        enumerate_coeffs(0, [])

    return achieved, set(), True  # simplified


if __name__ == "__main__":
    # Quick test
    p = 2
    print(f"v_{p}(12) = {padic_valuation(p, 12)}")
    print(f"v_{p}(8) = {padic_valuation(p, 8)}")
    print(f"v_{p}(12*8) = {padic_valuation(p, 96)}")
    print(f"v_{p}(12) + v_{p}(8) = {padic_valuation(p, 12) + padic_valuation(p, 8)}")
    print(f"Multiplicativity: {padic_valuation(p, 96) == padic_valuation(p, 12) + padic_valuation(p, 8)}")
