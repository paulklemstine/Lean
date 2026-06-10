"""
Algorithms for Newton Persistence over Finite Fields.

Implements the core algorithms for computing Newton graphs, fixed points,
basin depths, and persistence statistics over Z/pZ.

These algorithms are mathematically tied to the proven theorems:
- newton_fixed_iff_eval_eq_zero: Fixed points ↔ roots
- card_newtonFixed_eq_card_roots_of_squarefree: |fixed pts| = |roots| for squarefree
- card_depth_zero_eq_card_roots: depth-0 count = root count
"""

from typing import Optional
from collections import Counter


def mod_inverse(a: int, p: int) -> Optional[int]:
    """Compute modular inverse of a mod p using extended Euclidean algorithm.

    Args:
        a: Integer to invert.
        p: Prime modulus.

    Returns:
        Inverse of a mod p, or None if a ≡ 0 (mod p).
    """
    if a % p == 0:
        return None
    return pow(a, p - 2, p)


def poly_eval(coeffs: list[int], x: int, p: int) -> int:
    """Evaluate polynomial at x modulo p.

    Args:
        coeffs: Coefficients [a0, a1, ..., an] for a0 + a1*x + ... + an*x^n.
        x: Evaluation point.
        p: Prime modulus.

    Returns:
        f(x) mod p.

    Example:
        >>> poly_eval([1, 0, 1], 3, 7)  # 1 + 0*3 + 1*9 = 10 ≡ 3 (mod 7)
        3
    """
    result = 0
    power = 1
    for c in coeffs:
        result = (result + c * power) % p
        power = (power * x) % p
    return result


def poly_derivative(coeffs: list[int]) -> list[int]:
    """Compute formal derivative of polynomial.

    Args:
        coeffs: Coefficients [a0, a1, ..., an].

    Returns:
        Coefficients of f'(x) = [a1, 2*a2, ..., n*an].

    Example:
        >>> poly_derivative([1, 3, 5, 2])  # f = 1 + 3x + 5x^2 + 2x^3
        [3, 10, 6]
    """
    if len(coeffs) <= 1:
        return [0]
    return [i * coeffs[i] for i in range(1, len(coeffs))]


def newton_step(coeffs: list[int], x: int, p: int) -> Optional[int]:
    """Compute one Newton step: x - f(x)/f'(x) mod p.

    This implements the `newtonStep?` definition from the formalization.

    Args:
        coeffs: Polynomial coefficients.
        x: Current point in Z/pZ.
        p: Prime modulus.

    Returns:
        N_f(x) mod p if f'(x) ≠ 0, else None (singular point).

    Example:
        >>> newton_step([-2, 0, 1], 3, 7)  # f = x^2 - 2, x=3, p=7
        5
    """
    deriv_coeffs = poly_derivative(coeffs)
    fx = poly_eval(coeffs, x, p)
    fpx = poly_eval(deriv_coeffs, x, p)

    if fpx % p == 0:
        return None  # Singular point

    fpx_inv = mod_inverse(fpx, p)
    if fpx_inv is None:
        return None

    return (x - fx * fpx_inv) % p


def newton_graph(coeffs: list[int], p: int) -> dict[int, Optional[int]]:
    """Construct the Newton functional graph over Z/pZ.

    Args:
        coeffs: Polynomial coefficients.
        p: Prime modulus.

    Returns:
        Dictionary mapping x -> N_f(x) or None if singular.

    Example:
        >>> g = newton_graph([-1, 0, 1], 5)  # f = x^2 - 1 mod 5
        >>> g[1]  # 1 is a root, so N_f(1) = 1
        1
    """
    return {x: newton_step(coeffs, x, p) for x in range(p)}


def newton_fixed_points(coeffs: list[int], p: int) -> list[int]:
    """Find all nonsingular Newton fixed points over Z/pZ.

    By Theorem 1 (newton_fixed_iff_eval_eq_zero), these are exactly the
    points where f(x) = 0 and f'(x) ≠ 0.

    By Theorem 3 (card_newtonFixed_eq_card_roots_of_squarefree), for
    squarefree f, this equals the set of all roots.

    Args:
        coeffs: Polynomial coefficients.
        p: Prime modulus.

    Returns:
        List of fixed points.

    Example:
        >>> newton_fixed_points([-1, 0, 1], 5)  # x^2 - 1 mod 5: roots at 1, 4
        [1, 4]
    """
    graph = newton_graph(coeffs, p)
    return [x for x in range(p) if graph[x] is not None and graph[x] == x]


def roots_mod_p(coeffs: list[int], p: int) -> list[int]:
    """Find all roots of f modulo p by exhaustive search.

    Args:
        coeffs: Polynomial coefficients.
        p: Prime modulus.

    Returns:
        List of roots.

    Example:
        >>> roots_mod_p([-1, 0, 1], 5)  # x^2 - 1 mod 5
        [1, 4]
    """
    return [x for x in range(p) if poly_eval(coeffs, x, p) == 0]


def basin_depth_histogram(coeffs: list[int], p: int, max_depth: int = 10) -> dict[int, int]:
    """Compute the basin-depth histogram of the Newton map over Z/pZ.

    Depth 0 = roots (Newton fixed points for squarefree polynomials).
    Depth k = points reaching a root in exactly k Newton steps.
    Depth -1 = points that never reach a root within max_depth steps
               or encounter a singular point.

    By Theorem 4 (card_depth_zero_eq_card_roots), the depth-0 count
    equals the root count for squarefree polynomials.

    Args:
        coeffs: Polynomial coefficients.
        p: Prime modulus.
        max_depth: Maximum depth to search.

    Returns:
        Dictionary mapping depth -> count. Key -1 for unreached points.

    Example:
        >>> h = basin_depth_histogram([-1, 0, 1], 5)
        >>> h[0]  # Number of roots
        2
    """
    graph = newton_graph(coeffs, p)
    depth: dict[int, int] = {}

    # Phase 1: Find depth-0 points (fixed points = roots for squarefree)
    for x in range(p):
        if graph[x] is not None and graph[x] == x:
            depth[x] = 0

    # Phase 2: BFS to find deeper points
    for d in range(1, max_depth + 1):
        for x in range(p):
            if x in depth:
                continue
            y = graph[x]
            if y is not None and y in depth and depth[y] == d - 1:
                depth[x] = d

    # Phase 3: Build histogram
    histogram: dict[int, int] = Counter()
    for x in range(p):
        if x in depth:
            histogram[depth[x]] += 1
        else:
            histogram[-1] += 1

    return dict(sorted(histogram.items()))


def newton_fixed_count(coeffs: list[int], p: int) -> int:
    """The persistence-zero statistic S_p(f).

    By Theorems 3 and 5, this equals the root count for squarefree f,
    and separates polynomials with different root-count distributions.

    Args:
        coeffs: Polynomial coefficients.
        p: Prime modulus.

    Returns:
        Number of nonsingular Newton fixed points.
    """
    return len(newton_fixed_points(coeffs, p))


def root_count_distribution(coeffs: list[int], primes: list[int]) -> dict[int, int]:
    """Compute the root-count distribution over a set of primes.

    This is the Frobenius fixed-point statistic distribution, which by
    Chebotarev density reflects the Galois group.

    Args:
        coeffs: Polynomial coefficients (integer).
        primes: List of primes to sample.

    Returns:
        Dictionary mapping root_count -> number_of_primes_with_that_count.

    Example:
        >>> from sympy import primerange
        >>> dist = root_count_distribution([-1, 0, 1], list(primerange(3, 50)))
    """
    counts = [newton_fixed_count(coeffs, p) for p in primes]
    return dict(Counter(counts))


def verify_theorem_1(coeffs: list[int], p: int) -> bool:
    """Computationally verify Theorem 1: fixed points = roots (when f'(x) ≠ 0).

    Args:
        coeffs: Polynomial coefficients.
        p: Prime modulus.

    Returns:
        True if the theorem holds for all x in Z/pZ.
    """
    deriv = poly_derivative(coeffs)
    for x in range(p):
        fpx = poly_eval(deriv, x, p)
        if fpx % p != 0:  # f'(x) ≠ 0
            fx = poly_eval(coeffs, x, p)
            step = newton_step(coeffs, x, p)
            is_fixed = (step == x)
            is_root = (fx == 0)
            if is_fixed != is_root:
                return False
    return True


def verify_theorem_3(coeffs: list[int], p: int) -> bool:
    """Computationally verify Theorem 3: |fixed points| = |roots| for squarefree f.

    Note: Does not check squarefreeness; caller should ensure this.

    Args:
        coeffs: Polynomial coefficients.
        p: Prime modulus.

    Returns:
        True if the cardinalities match.
    """
    fp = newton_fixed_points(coeffs, p)
    r = roots_mod_p(coeffs, p)
    return len(fp) == len(r)


if __name__ == "__main__":
    # Example: f(x) = x^3 - x mod various primes
    coeffs = [0, -1, 0, 1]  # x^3 - x = x(x-1)(x+1)
    print("Polynomial: x^3 - x")
    print()

    for p in [5, 7, 11, 13, 17]:
        fp = newton_fixed_points(coeffs, p)
        r = roots_mod_p(coeffs, p)
        hist = basin_depth_histogram(coeffs, p)
        print(f"p = {p}:")
        print(f"  Roots: {r}")
        print(f"  Newton fixed points: {fp}")
        print(f"  Theorem 1 verified: {verify_theorem_1(coeffs, p)}")
        print(f"  Theorem 3 verified: {verify_theorem_3(coeffs, p)}")
        print(f"  Depth histogram: {hist}")
        print()
