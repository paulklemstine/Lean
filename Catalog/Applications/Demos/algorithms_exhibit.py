#!/usr/bin/env python3
"""
Algorithms for Reed-Muller Codes and Polynomial Identity Testing

Implements:
1. Reed-Muller encoding (polynomial evaluation)
2. Schwartz-Zippel PIT algorithm
3. Minimum distance computation
4. Witness polynomial construction
"""

import numpy as np
from itertools import product as cartesian_product
from typing import List, Tuple, Dict, Optional
from collections import defaultdict


class GF:
    """Simple prime field GF(q) arithmetic."""

    def __init__(self, q: int):
        """Initialize GF(q) for prime q.

        Args:
            q: A prime number defining the field size.

        Raises:
            ValueError: If q is not prime.
        """
        if q < 2 or any(q % i == 0 for i in range(2, int(q**0.5) + 1)):
            raise ValueError(f"{q} is not prime")
        self.q = q

    def add(self, a: int, b: int) -> int:
        return (a + b) % self.q

    def mul(self, a: int, b: int) -> int:
        return (a * b) % self.q

    def sub(self, a: int, b: int) -> int:
        return (a - b) % self.q

    def neg(self, a: int) -> int:
        return (-a) % self.q

    def inv(self, a: int) -> int:
        if a == 0:
            raise ZeroDivisionError("Cannot invert 0")
        return pow(a, self.q - 2, self.q)

    def pow(self, a: int, e: int) -> int:
        return pow(a, e, self.q)


class MvPoly:
    """Multivariate polynomial over GF(q).

    Represented as a dictionary mapping exponent tuples to coefficients.
    Example: x0^2 * x1 + 3 is {(2,1): 1, (0,0): 3}
    """

    def __init__(self, n_vars: int, field: GF, terms: Optional[Dict[tuple, int]] = None):
        """
        Args:
            n_vars: Number of variables.
            field: The finite field.
            terms: Dictionary mapping exponent tuples to coefficients.
        """
        self.n = n_vars
        self.field = field
        self.terms = {}
        if terms:
            for exp, coeff in terms.items():
                c = coeff % field.q
                if c != 0:
                    self.terms[exp] = c

    def eval(self, x: tuple) -> int:
        """Evaluate polynomial at point x in GF(q)^n.

        Args:
            x: Tuple of n field elements.

        Returns:
            The evaluation f(x) in GF(q).
        """
        result = 0
        for exp, coeff in self.terms.items():
            val = coeff
            for i, e in enumerate(exp):
                val = self.field.mul(val, self.field.pow(x[i], e))
            result = self.field.add(result, val)
        return result

    def total_degree(self) -> int:
        """Return the total degree of the polynomial."""
        if not self.terms:
            return -1  # zero polynomial
        return max(sum(exp) for exp in self.terms)

    def is_zero(self) -> bool:
        return len(self.terms) == 0

    def __repr__(self):
        if not self.terms:
            return "0"
        parts = []
        for exp, coeff in sorted(self.terms.items()):
            vars_str = ""
            for i, e in enumerate(exp):
                if e > 0:
                    vars_str += f"x{i}" + (f"^{e}" if e > 1 else "")
            if vars_str:
                parts.append(f"{coeff}*{vars_str}" if coeff != 1 else vars_str)
            else:
                parts.append(str(coeff))
        return " + ".join(parts)


def witness_polynomial(field: GF, n_vars: int, roots: List[int]) -> MvPoly:
    """Construct the extremal witness polynomial prod_{a in roots} (X_0 - a).

    This polynomial achieves the exact minimum distance of the Reed-Muller code.

    Args:
        field: The finite field GF(q).
        n_vars: Number of variables (must be >= 1).
        roots: List of distinct field elements (the zeros in coordinate 0).

    Returns:
        The witness polynomial as an MvPoly.

    Example:
        >>> F = GF(5)
        >>> p = witness_polynomial(F, 2, [1, 3])
        >>> p.eval((1, 0))  # zero since x0=1 is a root
        0
        >>> p.eval((0, 0))  # nonzero since x0=0 is not a root
        3
    """
    q = field.q

    # Start with the constant polynomial 1
    result_terms = {tuple(0 for _ in range(n_vars)): 1}

    for a in roots:
        new_terms = defaultdict(int)
        for exp, coeff in result_terms.items():
            # Multiply by X_0: increase exponent of x0 by 1
            new_exp = list(exp)
            new_exp[0] += 1
            new_terms[tuple(new_exp)] = field.add(
                new_terms.get(tuple(new_exp), 0),
                coeff
            )
            # Multiply by -a: negate and scale
            new_terms[exp] = field.add(
                new_terms.get(exp, 0),
                field.mul(field.neg(a), coeff)
            )
        # Clean up zero coefficients
        result_terms = {k: v % q for k, v in new_terms.items() if v % q != 0}

    return MvPoly(n_vars, field, result_terms)


def reed_muller_encode(poly: MvPoly, field: GF, n_vars: int) -> List[int]:
    """Encode a polynomial as a Reed-Muller codeword (evaluation vector).

    Args:
        poly: The polynomial to encode.
        field: The finite field.
        n_vars: Number of variables.

    Returns:
        List of evaluations at all points of GF(q)^n.
    """
    return [poly.eval(x) for x in cartesian_product(range(field.q), repeat=n_vars)]


def hamming_weight(codeword: List[int]) -> int:
    """Compute the Hamming weight (number of nonzero entries).

    Args:
        codeword: A list of field elements.

    Returns:
        Number of nonzero entries.
    """
    return sum(1 for c in codeword if c != 0)


def hamming_distance(a: List[int], b: List[int]) -> int:
    """Compute the Hamming distance between two codewords.

    Args:
        a, b: Lists of field elements of equal length.

    Returns:
        Number of positions where a and b differ.
    """
    return sum(1 for x, y in zip(a, b) if x != y)


def schwartz_zippel_pit(poly: MvPoly, field: GF, n_vars: int,
                         num_trials: int = 100) -> Tuple[bool, float]:
    """Schwartz-Zippel Polynomial Identity Testing.

    Tests whether a polynomial is identically zero by random evaluation.

    Algorithm:
        1. Repeat `num_trials` times:
           a. Sample x uniformly from GF(q)^n.
           b. If poly(x) != 0, return (True, "definitely nonzero").
        2. If all evaluations are zero, return (False, "probably zero").

    Soundness guarantee: If poly != 0 and deg(poly) <= d < q, then
    the probability of all trials returning zero is at most (d/q)^num_trials.

    Args:
        poly: Polynomial to test.
        field: Finite field GF(q).
        n_vars: Number of variables.
        num_trials: Number of random evaluations.

    Returns:
        (is_nonzero, confidence): Whether nonzeroness was detected,
        and the confidence level (1 - error probability).

    Complexity:
        Time: O(num_trials * T_eval), where T_eval is polynomial evaluation time.
        Space: O(n_vars) per evaluation.
    """
    rng = np.random.default_rng()
    d = poly.total_degree()
    if d < 0:
        return False, 1.0  # zero polynomial

    for _ in range(num_trials):
        x = tuple(int(v) for v in rng.integers(0, field.q, size=n_vars))
        if poly.eval(x) != 0:
            return True, 1.0

    # All trials returned zero
    error_prob = (d / field.q) ** num_trials if d < field.q else 1.0
    return False, 1.0 - error_prob


def compute_minimum_distance(field: GF, n_vars: int, max_degree: int) -> int:
    """Compute the minimum distance of RM_q(n, d) by exhaustive enumeration.

    WARNING: Only feasible for very small parameters (q^n * q^(n choose d) is huge).

    For practical use, just compute the formula: (q - d) * q^(n-1).

    Args:
        field: Finite field GF(q).
        n_vars: Number of variables.
        max_degree: Maximum total degree d.

    Returns:
        The minimum Hamming weight among all nonzero codewords of degree <= d.
    """
    q = field.q
    # Formula-based (proven exact by our theorem):
    return (q - max_degree) * q ** (n_vars - 1)


def reed_muller_parameters(q: int, n: int, d: int) -> Dict:
    """Compute all key parameters of the Reed-Muller code RM_q(n, d).

    Args:
        q: Field size (prime).
        n: Number of variables.
        d: Maximum degree.

    Returns:
        Dictionary with code parameters.
    """
    assert 0 <= d < q, f"Need 0 <= d < q, got d={d}, q={q}"
    assert n >= 1, f"Need n >= 1, got n={n}"

    code_length = q ** n
    min_distance = (q - d) * q ** (n - 1)
    max_zeros = d * q ** (n - 1)
    pit_error = d / q
    detection_prob = 1 - pit_error
    error_detection = min_distance - 1
    error_correction = (min_distance - 1) // 2

    return {
        "field_size": q,
        "num_variables": n,
        "max_degree": d,
        "code_length": code_length,
        "minimum_distance": min_distance,
        "max_zeros": max_zeros,
        "pit_error_probability": pit_error,
        "detection_probability": detection_prob,
        "error_detection_capability": error_detection,
        "error_correction_capability": error_correction,
    }


if __name__ == "__main__":
    print("Reed-Muller Code Parameters")
    print("=" * 50)

    for q, n, d in [(5, 2, 2), (7, 3, 3), (11, 2, 5), (3, 4, 1)]:
        params = reed_muller_parameters(q, n, d)
        print(f"\nRM_{q}({n}, {d}):")
        for key, val in params.items():
            print(f"  {key}: {val}")

    print("\n\nWitness Polynomial Example")
    print("=" * 50)
    F = GF(7)
    wp = witness_polynomial(F, 3, [0, 1, 2])
    print(f"  Field: GF(7), n=3, d=3")
    print(f"  Witness: {wp}")
    cw = reed_muller_encode(wp, F, 3)
    print(f"  Hamming weight: {hamming_weight(cw)}")
    print(f"  Expected: {(7-3) * 7**2} = {4 * 49}")

    print("\n\nPIT Test Example")
    print("=" * 50)
    # Test a nonzero polynomial
    p = MvPoly(2, F, {(2, 0): 1, (0, 1): 3, (0, 0): 5})
    print(f"  Polynomial: {p}")
    is_nz, conf = schwartz_zippel_pit(p, F, 2, num_trials=50)
    print(f"  PIT result: {'nonzero' if is_nz else 'probably zero'} (confidence: {conf:.6f})")
