#!/usr/bin/env python3
"""
Reed–Muller Code Algorithms

Implements key algorithms related to Reed–Muller codes, Schwartz–Zippel testing,
and polynomial identity testing over finite fields.
"""

from itertools import product
from typing import List, Tuple, Dict, Optional
import random


# ────────────────────────────────────────────────────────
# Finite Field Arithmetic
# ────────────────────────────────────────────────────────

class FiniteField:
    """
    Finite field GF(p) for prime p.

    Supports all basic arithmetic operations.

    Args:
        p: A prime number defining the field size.
    """

    def __init__(self, p: int):
        self.p = p
        self.elements = list(range(p))

    def __repr__(self) -> str:
        return f"GF({self.p})"

    @property
    def order(self) -> int:
        return self.p

    def add(self, a: int, b: int) -> int:
        return (a + b) % self.p

    def sub(self, a: int, b: int) -> int:
        return (a - b) % self.p

    def mul(self, a: int, b: int) -> int:
        return (a * b) % self.p

    def neg(self, a: int) -> int:
        return (-a) % self.p

    def inv(self, a: int) -> int:
        """Multiplicative inverse using Fermat's little theorem."""
        if a == 0:
            raise ZeroDivisionError("Cannot invert zero")
        return pow(a, self.p - 2, self.p)

    def pow(self, a: int, n: int) -> int:
        return pow(a, n, self.p)

    def random_element(self) -> int:
        return random.randint(0, self.p - 1)


# ────────────────────────────────────────────────────────
# Multivariate Polynomial Representation
# ────────────────────────────────────────────────────────

class MvPolynomial:
    """
    Sparse multivariate polynomial over a finite field.

    Represented as a dictionary mapping exponent tuples to coefficients.

    Args:
        field: The finite field for coefficients.
        n_vars: Number of variables.
        terms: Dictionary mapping exponent tuples to coefficients.
    """

    def __init__(self, field: FiniteField, n_vars: int,
                 terms: Optional[Dict[Tuple[int, ...], int]] = None):
        self.field = field
        self.n_vars = n_vars
        self.terms = {}
        if terms:
            for exp, coeff in terms.items():
                c = coeff % field.p
                if c != 0:
                    self.terms[exp] = c

    def __repr__(self) -> str:
        if not self.terms:
            return "0"
        parts = []
        for exp, coeff in sorted(self.terms.items()):
            var_parts = []
            for i, e in enumerate(exp):
                if e > 0:
                    var_parts.append(f"x{i}" + (f"^{e}" if e > 1 else ""))
            term = " * ".join(var_parts) if var_parts else ""
            if coeff == 1 and term:
                parts.append(term)
            elif term:
                parts.append(f"{coeff}*{term}")
            else:
                parts.append(str(coeff))
        return " + ".join(parts)

    @property
    def is_zero(self) -> bool:
        return len(self.terms) == 0

    @property
    def total_degree(self) -> int:
        """Total degree of the polynomial."""
        if not self.terms:
            return -1  # Convention for zero polynomial
        return max(sum(exp) for exp in self.terms)

    def eval(self, point: Tuple[int, ...]) -> int:
        """Evaluate the polynomial at a point."""
        result = 0
        for exp, coeff in self.terms.items():
            term = coeff
            for i, e in enumerate(exp):
                term = self.field.mul(term, self.field.pow(point[i], e))
            result = self.field.add(result, term)
        return result

    def add(self, other: 'MvPolynomial') -> 'MvPolynomial':
        """Add two polynomials."""
        new_terms = dict(self.terms)
        for exp, coeff in other.terms.items():
            if exp in new_terms:
                new_terms[exp] = self.field.add(new_terms[exp], coeff)
                if new_terms[exp] == 0:
                    del new_terms[exp]
            else:
                new_terms[exp] = coeff
        return MvPolynomial(self.field, self.n_vars, new_terms)

    def mul(self, other: 'MvPolynomial') -> 'MvPolynomial':
        """Multiply two polynomials."""
        new_terms: Dict[Tuple[int, ...], int] = {}
        for exp1, c1 in self.terms.items():
            for exp2, c2 in other.terms.items():
                new_exp = tuple(a + b for a, b in zip(exp1, exp2))
                coeff = self.field.mul(c1, c2)
                if new_exp in new_terms:
                    new_terms[new_exp] = self.field.add(new_terms[new_exp], coeff)
                    if new_terms[new_exp] == 0:
                        del new_terms[new_exp]
                else:
                    new_terms[new_exp] = coeff
        return MvPolynomial(self.field, self.n_vars, new_terms)


# ────────────────────────────────────────────────────────
# Algorithm 1: Reed–Muller Code Construction
# ────────────────────────────────────────────────────────

def reed_muller_codewords(field: FiniteField, n: int, d: int) -> List[List[int]]:
    """
    Construct all codewords of the Reed–Muller code RM(n, d) over GF(q).

    A codeword is the evaluation vector of a polynomial of total degree ≤ d
    over all points of GF(q)^n.

    Args:
        field: The finite field.
        n: Number of variables.
        d: Maximum total degree.

    Returns:
        List of codewords (evaluation vectors).

    Complexity: O(q^(n+C(n+d,d))) — exponential in both code length and dimension.
    """
    q = field.order
    all_points = list(product(range(q), repeat=n))

    # Generate all monomials of total degree ≤ d
    monomials = [exp for exp in product(range(d + 1), repeat=n) if sum(exp) <= d]

    # Generate all polynomials by choosing coefficients
    codewords = set()
    for coeffs in product(range(q), repeat=len(monomials)):
        terms = {}
        for exp, c in zip(monomials, coeffs):
            if c != 0:
                terms[exp] = c
        poly = MvPolynomial(field, n, terms)
        codeword = tuple(poly.eval(pt) for pt in all_points)
        codewords.add(codeword)

    return [list(cw) for cw in codewords]


# ────────────────────────────────────────────────────────
# Algorithm 2: Witness Polynomial Construction
# ────────────────────────────────────────────────────────

def witness_polynomial(field: FiniteField, n: int, d: int) -> MvPolynomial:
    """
    Construct the extremal witness polynomial achieving the minimum distance.

    The witness is f(x_0, ..., x_{n-1}) = ∏_{a ∈ S} (x_0 - a)
    where S is a set of d distinct field elements.

    Args:
        field: The finite field.
        n: Number of variables.
        d: Number of roots (= degree).

    Returns:
        The witness polynomial.

    Complexity: O(d²) for polynomial multiplication.
    """
    assert d <= field.order, f"d={d} exceeds field size {field.order}"
    roots = list(range(d))

    # Start with constant 1
    zero_exp = tuple([0] * n)
    result = MvPolynomial(field, n, {zero_exp: 1})

    for a in roots:
        # Multiply by (x_0 - a)
        x0_exp = tuple([1] + [0] * (n - 1))
        linear = MvPolynomial(field, n, {
            x0_exp: 1,
            zero_exp: field.neg(a)
        })
        result = result.mul(linear)

    return result


# ────────────────────────────────────────────────────────
# Algorithm 3: Schwartz–Zippel PIT
# ────────────────────────────────────────────────────────

def schwartz_zippel_pit(poly: MvPolynomial, num_tests: int = 100) -> dict:
    """
    Polynomial Identity Testing via Schwartz–Zippel random evaluation.

    Tests whether a polynomial is identically zero by evaluating at random points.
    If the polynomial is nonzero of degree d, the probability of a false negative
    (evaluating to zero) is at most d/q per test.

    Args:
        poly: The polynomial to test.
        num_tests: Number of random evaluation tests.

    Returns:
        Dictionary with test results:
        - 'verdict': 'nonzero' or 'possibly_zero'
        - 'nonzero_count': Number of nonzero evaluations
        - 'zero_count': Number of zero evaluations
        - 'error_bound': Upper bound on false negative probability

    Complexity: O(num_tests * d * n) for evaluation.
    """
    field = poly.field
    n = poly.n_vars
    d = poly.total_degree

    nonzero_count = 0
    zero_count = 0

    for _ in range(num_tests):
        point = tuple(field.random_element() for _ in range(n))
        val = poly.eval(point)
        if val != 0:
            nonzero_count += 1
        else:
            zero_count += 1

    # If any evaluation is nonzero, the polynomial is definitely nonzero
    verdict = 'nonzero' if nonzero_count > 0 else 'possibly_zero'

    # Error bound: probability all tests return 0 for nonzero poly ≤ (d/q)^num_tests
    error_bound = (d / field.order) ** num_tests if d >= 0 else 0

    return {
        'verdict': verdict,
        'nonzero_count': nonzero_count,
        'zero_count': zero_count,
        'error_bound': error_bound,
        'num_tests': num_tests,
    }


# ────────────────────────────────────────────────────────
# Algorithm 4: Minimum Distance Computation
# ────────────────────────────────────────────────────────

def compute_minimum_distance(field: FiniteField, n: int, d: int) -> dict:
    """
    Compute the exact minimum distance of RM(n, d) over GF(q).

    Uses the formula: min_distance = (q - d) * q^(n-1).
    Also constructs the witness polynomial and verifies the formula.

    Args:
        field: The finite field.
        n: Number of variables (n ≥ 1).
        d: Maximum total degree (0 ≤ d < q).

    Returns:
        Dictionary with:
        - 'formula_value': (q - d) * q^(n-1)
        - 'witness_weight': Actual Hamming weight of witness
        - 'verified': Whether they match

    Complexity: O(q^n * d) for witness evaluation.
    """
    q = field.order
    assert 0 <= d < q, f"Need 0 ≤ d < q, got d={d}, q={q}"
    assert n >= 1, f"Need n ≥ 1, got n={n}"

    formula_value = (q - d) * q ** (n - 1)

    # Build and evaluate witness
    witness = witness_polynomial(field, n, d)
    all_points = list(product(range(q), repeat=n))
    weight = sum(1 for pt in all_points if witness.eval(pt) != 0)

    return {
        'q': q,
        'n': n,
        'd': d,
        'formula_value': formula_value,
        'witness_weight': weight,
        'verified': formula_value == weight,
        'code_length': q ** n,
        'zero_count': q ** n - weight,
    }


# ────────────────────────────────────────────────────────
# Algorithm 5: Hamming Weight Distribution
# ────────────────────────────────────────────────────────

def hamming_weight_distribution(field: FiniteField, n: int, d: int,
                                 sample_size: int = 1000) -> Dict[int, int]:
    """
    Sample the Hamming weight distribution of RM(n, d) over GF(q).

    Args:
        field: The finite field.
        n: Number of variables.
        d: Maximum total degree.
        sample_size: Number of random codewords to sample.

    Returns:
        Dictionary mapping Hamming weights to their frequency.
    """
    q = field.order
    all_points = list(product(range(q), repeat=n))
    monomials = [exp for exp in product(range(d + 1), repeat=n) if sum(exp) <= d]

    weight_dist: Dict[int, int] = {}

    for _ in range(sample_size):
        # Random polynomial of degree ≤ d
        terms = {}
        for exp in monomials:
            c = random.randint(0, q - 1)
            if c != 0:
                terms[exp] = c

        if not terms:
            weight_dist[0] = weight_dist.get(0, 0) + 1
            continue

        poly = MvPolynomial(field, n, terms)
        weight = sum(1 for pt in all_points if poly.eval(pt) != 0)
        weight_dist[weight] = weight_dist.get(weight, 0) + 1

    return weight_dist


if __name__ == "__main__":
    # Example usage
    print("Reed–Muller Code Algorithms — Example Usage")
    print("=" * 50)

    F = FiniteField(5)

    # Minimum distance
    result = compute_minimum_distance(F, 2, 2)
    print(f"\nRM(2, 2) over GF(5):")
    print(f"  Formula: (5-2) * 5^1 = {result['formula_value']}")
    print(f"  Witness weight: {result['witness_weight']}")
    print(f"  Verified: {result['verified']}")

    # PIT test
    poly = witness_polynomial(F, 2, 2)
    pit_result = schwartz_zippel_pit(poly, num_tests=50)
    print(f"\nPIT test on witness polynomial:")
    print(f"  Verdict: {pit_result['verdict']}")
    print(f"  Nonzero evaluations: {pit_result['nonzero_count']}/{pit_result['num_tests']}")
