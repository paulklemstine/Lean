#!/usr/bin/env python3
"""
Algorithms for Multivariate Polynomial Line Restriction and Kakeya Set Analysis

Implements the core algorithms arising from the coefficient extraction theorem:
1. Line restriction of multivariate polynomials
2. Homogeneous component extraction
3. Dvir vanishing test
4. Kakeya set construction and verification
"""

from typing import Dict, Tuple, List, Set, Optional
from collections import defaultdict
from itertools import product
from math import comb, factorial


# Type aliases
Monomial = Tuple[int, ...]  # exponent vector
PolyCoeffs = Dict[Monomial, float]


class MultivariatePolynomial:
    """A multivariate polynomial represented as a dictionary of monomial coefficients.

    Each monomial is a tuple of non-negative integer exponents, one per variable.
    """

    def __init__(self, coeffs: PolyCoeffs, n_vars: int):
        """Initialize with coefficient dictionary and number of variables.

        Args:
            coeffs: mapping from exponent tuples to coefficients
            n_vars: number of variables
        """
        self.coeffs = {k: v for k, v in coeffs.items() if v != 0}
        self.n_vars = n_vars

    def total_degree(self) -> int:
        """Return the total degree of the polynomial.

        Returns:
            Maximum sum of exponents over all monomials with nonzero coefficient.
        """
        if not self.coeffs:
            return -1  # Convention: zero polynomial has degree -1
        return max(sum(exp) for exp in self.coeffs.keys())

    def evaluate(self, point: List[float]) -> float:
        """Evaluate the polynomial at a given point.

        Args:
            point: values for each variable

        Returns:
            P(point)
        """
        assert len(point) == self.n_vars
        result = 0.0
        for exponent, coeff in self.coeffs.items():
            term = coeff
            for i in range(self.n_vars):
                term *= point[i] ** exponent[i]
            result += term
        return result

    def evaluate_mod(self, point: List[int], q: int) -> int:
        """Evaluate the polynomial at a point modulo q.

        Args:
            point: values for each variable (integers)
            q: modulus

        Returns:
            P(point) mod q
        """
        assert len(point) == self.n_vars
        result = 0
        for exponent, coeff in self.coeffs.items():
            term = int(coeff) % q
            for i in range(self.n_vars):
                term = (term * pow(point[i], exponent[i], q)) % q
            result = (result + term) % q
        return result

    def homogeneous_component(self, d: int) -> 'MultivariatePolynomial':
        """Extract the degree-d homogeneous component.

        Args:
            d: degree to extract

        Returns:
            The polynomial consisting only of degree-d monomials.

        Complexity: O(|support|)
        """
        hc = {exp: c for exp, c in self.coeffs.items() if sum(exp) == d}
        return MultivariatePolynomial(hc, self.n_vars)


def restrict_to_line(
    poly: MultivariatePolynomial,
    x: List[float],
    v: List[float]
) -> Dict[int, float]:
    """Restrict a multivariate polynomial to the affine line x + t*v.

    Computes the univariate polynomial P(x + tv) as a dictionary
    mapping degree to coefficient.

    Algorithm:
        For each monomial a * X^m, expand prod_i (x_i + t*v_i)^{m_i}
        using the binomial theorem, then accumulate coefficients.

    Args:
        poly: the multivariate polynomial
        x: base point of the line
        v: direction vector

    Returns:
        Dictionary mapping degree k to coefficient of t^k in P(x+tv).

    Complexity: O(|support| * d^n) where d is total degree, n is #variables
    """
    n = poly.n_vars
    result = defaultdict(float)

    for exponent, coeff in poly.coeffs.items():
        # Compute product of (x_i + t * v_i)^{m_i} via iterated convolution
        # Start with [1] (constant polynomial 1)
        current = [1.0]

        for i in range(n):
            mi = exponent[i]
            xi, vi = x[i], v[i]

            # Binomial expansion of (xi + t*vi)^mi
            factor = []
            for k in range(mi + 1):
                factor.append(comb(mi, k) * (xi ** (mi - k)) * (vi ** k))

            # Polynomial multiplication (convolution)
            new_len = len(current) + len(factor) - 1
            new_poly = [0.0] * new_len
            for j1, c1 in enumerate(current):
                for j2, c2 in enumerate(factor):
                    new_poly[j1 + j2] += c1 * c2
            current = new_poly

        # Accumulate into result
        for deg, c in enumerate(current):
            result[deg] += coeff * c

    return dict(result)


def restrict_to_line_mod(
    poly: MultivariatePolynomial,
    x: List[int],
    v: List[int],
    q: int
) -> Dict[int, int]:
    """Restrict a multivariate polynomial to an affine line over F_q.

    All arithmetic is performed modulo q.

    Args:
        poly: the multivariate polynomial (integer coefficients)
        x: base point
        v: direction vector
        q: field size (should be prime)

    Returns:
        Dictionary mapping degree k to coefficient of t^k mod q.

    Complexity: O(|support| * d^n)
    """
    n = poly.n_vars
    result = defaultdict(int)

    for exponent, coeff in poly.coeffs.items():
        current = [1]

        for i in range(n):
            mi = exponent[i]
            xi, vi = x[i] % q, v[i] % q

            factor = []
            for k in range(mi + 1):
                factor.append(
                    (comb(mi, k) * pow(xi, mi - k, q) * pow(vi, k, q)) % q
                )

            new_len = len(current) + len(factor) - 1
            new_poly = [0] * new_len
            for j1, c1 in enumerate(current):
                for j2, c2 in enumerate(factor):
                    new_poly[j1 + j2] = (new_poly[j1 + j2] + c1 * c2) % q
            current = new_poly

        for deg, c in enumerate(current):
            result[deg] = (result[deg] + int(coeff) * c) % q

    return dict(result)


def dvir_vanishing_test(
    poly: MultivariatePolynomial,
    x: List[int],
    v: List[int],
    q: int
) -> bool:
    """Test whether a polynomial vanishes on the full line x + tv over F_q.

    If P has total degree ≤ d < q and vanishes on the full line,
    then eval(homogeneousComponent(d, P), v) = 0 by our main theorem.

    Args:
        poly: multivariate polynomial over F_q
        x: base point
        v: direction vector
        q: field size

    Returns:
        True if P vanishes on all q points of the line.

    Complexity: O(q * |support| * n) for evaluation
    """
    n = poly.n_vars
    for t in range(q):
        point = [(x[i] + t * v[i]) % q for i in range(n)]
        if poly.evaluate_mod(point, q) != 0:
            return False
    return True


def construct_kakeya_set(q: int, n: int, method: str = "naive") -> Set[Tuple[int, ...]]:
    """Construct a Kakeya set in F_q^n.

    A Kakeya set contains a full affine line in every nonzero direction.

    Args:
        q: field size (prime)
        n: dimension
        method: construction method ("naive" or "random")

    Returns:
        Set of points forming a Kakeya set.

    Complexity: O(q^n * q) for the naive method
    """
    kakeya = set()

    # All nonzero directions in F_q^n
    all_dirs = [d for d in product(range(q), repeat=n)
                if any(x != 0 for x in d)]

    if method == "naive":
        # Simplest: for each direction, use the line through the origin
        for v in all_dirs:
            for t in range(q):
                point = tuple((t * v[i]) % q for i in range(n))
                kakeya.add(point)
    elif method == "random":
        # Choose different base points for different directions
        import random
        random.seed(42)
        for v in all_dirs:
            x = tuple(random.randint(0, q - 1) for _ in range(n))
            for t in range(q):
                point = tuple((x[i] + t * v[i]) % q for i in range(n))
                kakeya.add(point)

    return kakeya


def verify_kakeya(points: Set[Tuple[int, ...]], q: int, n: int) -> bool:
    """Verify that a set of points forms a Kakeya set in F_q^n.

    Args:
        points: set of points to verify
        q: field size
        n: dimension

    Returns:
        True if the set contains a full line in every nonzero direction.

    Complexity: O(q^n * q^n * q)
    """
    all_dirs = [d for d in product(range(q), repeat=n)
                if any(x != 0 for x in d)]

    for v in all_dirs:
        found = False
        for x in product(range(q), repeat=n):
            line_points = set()
            for t in range(q):
                point = tuple((x[i] + t * v[i]) % q for i in range(n))
                line_points.add(point)
            if line_points.issubset(points):
                found = True
                break
        if not found:
            return False
    return True


def kakeya_lower_bound(q: int, n: int) -> float:
    """Compute Dvir's lower bound q^n / n! for Kakeya sets.

    Args:
        q: field size
        n: dimension

    Returns:
        The lower bound q^n / n!
    """
    return q ** n / factorial(n)


def incidence_energy(
    lines: List[Tuple[Tuple[int, ...], Tuple[int, ...]]],
    q: int,
    n: int
) -> Tuple[int, int]:
    """Compute the incidence energy of a line family.

    For a family of lines, the multiplicity m(x) at point x is the number
    of lines passing through x. The energy is E = sum_x m(x)^2.

    Args:
        lines: list of (base_point, direction) tuples
        q: field size
        n: dimension

    Returns:
        Tuple (energy, union_size)

    Complexity: O(|lines| * q + q^n)
    """
    multiplicity = defaultdict(int)

    for x, v in lines:
        for t in range(q):
            point = tuple((x[i] + t * v[i]) % q for i in range(n))
            multiplicity[point] += 1

    energy = sum(m ** 2 for m in multiplicity.values())
    union_size = len(multiplicity)

    return energy, union_size


# ─── Example Usage ──────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("Multivariate Polynomial Line Restriction Algorithms")
    print("=" * 55)
    print()

    # Example: P(X,Y) = X² + 2XY + Y² + X + 1
    P = MultivariatePolynomial({
        (2, 0): 1, (1, 1): 2, (0, 2): 1, (1, 0): 1, (0, 0): 1
    }, n_vars=2)

    x = [1.0, 0.0]
    v = [1.0, 1.0]

    print(f"P(X,Y) = X² + 2XY + Y² + X + 1")
    print(f"Line: ({x[0]} + t·{v[0]}, {x[1]} + t·{v[1]})")
    print()

    coeffs = restrict_to_line(P, x, v)
    print("Restricted polynomial P(x + tv):")
    for d in sorted(coeffs.keys()):
        print(f"  t^{d}: {coeffs[d]:.4f}")

    print()
    d = P.total_degree()
    hc = P.homogeneous_component(d)
    eval_hc = hc.evaluate(v)
    print(f"Total degree: {d}")
    print(f"Coeff of t^{d}: {coeffs.get(d, 0):.4f}")
    print(f"Eval of HC_{d} at v: {eval_hc:.4f}")
    print(f"Match: {abs(coeffs.get(d, 0) - eval_hc) < 1e-10}")

    print()
    print("─" * 55)
    print("Kakeya set construction over F_5^2")

    q, n = 5, 2
    K = construct_kakeya_set(q, n, method="random")
    bound = kakeya_lower_bound(q, n)
    print(f"  |K| = {len(K)}")
    print(f"  Dvir bound: |K| ≥ {bound:.1f}")
    print(f"  q^n = {q**n}")
