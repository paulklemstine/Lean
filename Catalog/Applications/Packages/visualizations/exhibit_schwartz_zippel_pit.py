#!/usr/bin/env python3
"""
Algorithms for Reed–Muller Codes and Polynomial Identity Testing

Implements:
1. Reed–Muller encoding (evaluation code construction)
2. Schwartz–Zippel PIT algorithm
3. Minimum distance computation
4. Extremal witness construction
"""

import itertools
import random
from typing import List, Tuple, Optional, Callable
from dataclasses import dataclass


# ============================================================
# Finite Field Arithmetic (GF(p) for prime p)
# ============================================================

class GF:
    """Simple finite field GF(p) for prime p."""
    def __init__(self, p: int):
        self.p = p
        self.elements = list(range(p))

    def add(self, a: int, b: int) -> int:
        return (a + b) % self.p

    def mul(self, a: int, b: int) -> int:
        return (a * b) % self.p

    def sub(self, a: int, b: int) -> int:
        return (a - b) % self.p

    def neg(self, a: int) -> int:
        return (-a) % self.p

    def inv(self, a: int) -> int:
        if a == 0:
            raise ValueError("Cannot invert zero")
        return pow(a, self.p - 2, self.p)

    def div(self, a: int, b: int) -> int:
        return self.mul(a, self.inv(b))

    def pow(self, a: int, n: int) -> int:
        return pow(a, n, self.p)


# ============================================================
# Multivariate Polynomial Representation
# ============================================================

@dataclass
class Monomial:
    """A monomial x₁^e₁ · x₂^e₂ · ... · xₙ^eₙ."""
    exponents: Tuple[int, ...]

    @property
    def total_degree(self) -> int:
        return sum(self.exponents)

    @property
    def n_vars(self) -> int:
        return len(self.exponents)


class MvPoly:
    """
    Multivariate polynomial over GF(p).

    Represented as a dictionary from exponent tuples to coefficients.
    """
    def __init__(self, field: GF, n_vars: int):
        self.field = field
        self.n_vars = n_vars
        self.coeffs: dict = {}  # exponent tuple -> coefficient

    def set_coeff(self, exponents: Tuple[int, ...], coeff: int):
        if coeff % self.field.p != 0:
            self.coeffs[exponents] = coeff % self.field.p
        elif exponents in self.coeffs:
            del self.coeffs[exponents]

    def eval(self, point: Tuple[int, ...]) -> int:
        result = 0
        for exps, coeff in self.coeffs.items():
            term = coeff
            for i, e in enumerate(exps):
                term = self.field.mul(term, self.field.pow(point[i], e))
            result = self.field.add(result, term)
        return result

    @property
    def total_degree(self) -> int:
        if not self.coeffs:
            return -1  # convention: zero polynomial has degree -1
        return max(sum(exps) for exps in self.coeffs)

    @property
    def is_zero(self) -> bool:
        return len(self.coeffs) == 0

    @classmethod
    def witness(cls, field: GF, n_vars: int, roots: List[int]) -> 'MvPoly':
        """
        Construct the witness polynomial ∏_{a ∈ roots} (X₀ - a).

        This polynomial depends only on the first variable and has
        total degree len(roots).
        """
        # Start with the constant 1
        poly = cls(field, n_vars)
        poly.set_coeff(tuple(0 for _ in range(n_vars)), 1)

        for a in roots:
            # Multiply by (X₀ - a)
            new_coeffs = {}
            for exps, coeff in poly.coeffs.items():
                # coeff * X₀
                new_exps = list(exps)
                new_exps[0] += 1
                new_exps_tuple = tuple(new_exps)
                val = new_coeffs.get(new_exps_tuple, 0)
                new_coeffs[new_exps_tuple] = field.add(val, coeff)

                # coeff * (-a)
                neg_a_coeff = field.mul(coeff, field.neg(a))
                val2 = new_coeffs.get(exps, 0)
                new_coeffs[exps] = field.add(val2, neg_a_coeff)

            poly.coeffs = {k: v for k, v in new_coeffs.items() if v % field.p != 0}

        return poly


# ============================================================
# Algorithm 1: Reed–Muller Encoding
# ============================================================

def reed_muller_encode(field: GF, n_vars: int, max_degree: int,
                       coefficients: dict) -> List[int]:
    """
    Reed–Muller Encoding Algorithm

    Input:
        - field: GF(q)
        - n_vars: number of variables n
        - max_degree: maximum total degree d
        - coefficients: dict mapping exponent tuples to field elements

    Output:
        - Evaluation vector: [f(x) for x in GF(q)^n] (length q^n)

    Complexity: O(M · q^n) where M = number of monomials of degree ≤ d
    """
    poly = MvPoly(field, n_vars)
    for exps, coeff in coefficients.items():
        if sum(exps) <= max_degree:
            poly.set_coeff(exps, coeff)

    points = list(itertools.product(range(field.p), repeat=n_vars))
    return [poly.eval(pt) for pt in points]


# ============================================================
# Algorithm 2: Schwartz–Zippel PIT
# ============================================================

def schwartz_zippel_pit(eval_fn: Callable, field: GF, n_vars: int,
                        degree_bound: int, num_trials: int = 100) -> dict:
    """
    Schwartz–Zippel Polynomial Identity Testing Algorithm

    Input:
        - eval_fn: black-box evaluation oracle for the polynomial
        - field: GF(q)
        - n_vars: number of variables
        - degree_bound: upper bound d on total degree
        - num_trials: number of random evaluations

    Output:
        - Dictionary with:
          - 'is_zero': bool (our conclusion)
          - 'confidence': probability of correctness
          - 'trials': number of evaluations performed
          - 'nonzero_found': whether we found a nonzero evaluation

    Complexity: O(num_trials · T_eval) where T_eval is evaluation cost

    Soundness guarantee:
        If f ≠ 0, Pr[all trials give 0] ≤ (d/q)^num_trials

    Pseudocode:
        1. For i = 1, ..., num_trials:
           a. Sample x uniformly from GF(q)^n
           b. Evaluate f(x)
           c. If f(x) ≠ 0, return "f is nonzero" (certain)
        2. Return "f is likely zero" with confidence 1 - (d/q)^num_trials
    """
    q = field.p
    error_prob_per_trial = degree_bound / q

    for trial in range(num_trials):
        # Sample random point
        x = tuple(random.randint(0, q - 1) for _ in range(n_vars))
        val = eval_fn(x)

        if val != 0:
            return {
                'is_zero': False,
                'confidence': 1.0,
                'trials': trial + 1,
                'nonzero_found': True,
                'witness_point': x,
                'witness_value': val
            }

    # All evaluations were zero
    false_negative_prob = error_prob_per_trial ** num_trials
    return {
        'is_zero': True,
        'confidence': 1.0 - false_negative_prob,
        'trials': num_trials,
        'nonzero_found': False,
        'error_bound': false_negative_prob
    }


# ============================================================
# Algorithm 3: Minimum Distance Computation
# ============================================================

def compute_minimum_distance(field: GF, n_vars: int,
                             max_degree: int) -> dict:
    """
    Compute the minimum distance of RM_q(n, d) by the exact formula.

    Input:
        - field: GF(q)
        - n_vars: n (number of variables)
        - max_degree: d (maximum total degree)

    Output:
        - Dictionary with minimum distance and witness info

    The formula: min_dist = (q - d) · q^(n-1)
    """
    q = field.p
    if max_degree >= q:
        return {'error': f'd={max_degree} must be < q={q}'}

    min_dist = (q - max_degree) * (q ** (n_vars - 1))

    # Construct witness
    roots = list(range(max_degree))
    witness = MvPoly.witness(field, n_vars, roots)

    # Verify
    points = list(itertools.product(range(q), repeat=n_vars))
    actual_weight = sum(1 for pt in points if witness.eval(pt) != 0)

    return {
        'q': q,
        'n': n_vars,
        'd': max_degree,
        'minimum_distance': min_dist,
        'formula': f'({q} - {max_degree}) × {q}^{n_vars - 1} = {min_dist}',
        'witness_roots': roots,
        'witness_degree': witness.total_degree,
        'witness_weight': actual_weight,
        'verified': actual_weight == min_dist
    }


# ============================================================
# Algorithm 4: Extremal Witness Construction
# ============================================================

def construct_extremal_witness(field: GF, n_vars: int,
                               degree: int) -> dict:
    """
    Construct the extremal witness polynomial for RM_q(n, d).

    The witness is f(x) = ∏_{i=0}^{d-1} (x₁ - i), which achieves
    the minimum Hamming weight of (q-d)·q^(n-1).

    Input:
        - field: GF(q)
        - n_vars: n
        - degree: d

    Output:
        - Polynomial representation and evaluation data

    Complexity: O(d · q^n) for evaluation over all points
    """
    q = field.p
    roots = list(range(degree))
    witness = MvPoly.witness(field, n_vars, roots)

    points = list(itertools.product(range(q), repeat=n_vars))
    evaluations = [(pt, witness.eval(pt)) for pt in points]

    zero_set = [pt for pt, val in evaluations if val == 0]
    support = [pt for pt, val in evaluations if val != 0]

    return {
        'polynomial': f'∏_{{a ∈ {roots}}} (x₁ - a)',
        'degree': witness.total_degree,
        'roots': roots,
        'total_points': len(points),
        'zero_count': len(zero_set),
        'hamming_weight': len(support),
        'expected_zero_count': degree * (q ** (n_vars - 1)),
        'expected_weight': (q - degree) * (q ** (n_vars - 1)),
        'zero_set_sample': zero_set[:10],
        'support_sample': support[:10]
    }


# ============================================================
# Example Usage
# ============================================================

if __name__ == "__main__":
    print("=" * 70)
    print("Reed–Muller Code Algorithms — Examples")
    print("=" * 70)
    print()

    # Example 1: Reed–Muller Encoding
    print("--- Algorithm 1: Reed–Muller Encoding ---")
    F = GF(5)
    coeffs = {(1, 0): 1, (0, 1): 2, (0, 0): 3}  # f(x,y) = x + 2y + 3
    codeword = reed_muller_encode(F, 2, 1, coeffs)
    print(f"  f(x,y) = x + 2y + 3 over GF(5)")
    print(f"  Codeword length: {len(codeword)}")
    print(f"  Hamming weight: {sum(1 for v in codeword if v != 0)}")
    print(f"  Predicted min weight for d=1: {(5-1)*5**(2-1)} = {4*5}")
    print()

    # Example 2: Schwartz–Zippel PIT
    print("--- Algorithm 2: Schwartz–Zippel PIT ---")
    random.seed(42)

    # Test with a nonzero polynomial
    witness = MvPoly.witness(GF(7), 3, [0, 1, 2])
    result = schwartz_zippel_pit(witness.eval, GF(7), 3, 3, num_trials=20)
    print(f"  Testing nonzero poly (degree 3 over GF(7)^3):")
    print(f"  Result: {'NONZERO' if not result['is_zero'] else 'ZERO'}")
    print(f"  Trials needed: {result['trials']}")
    print()

    # Test with the zero polynomial
    zero_poly = MvPoly(GF(7), 3)
    result_zero = schwartz_zippel_pit(zero_poly.eval, GF(7), 3, 3, num_trials=20)
    print(f"  Testing zero polynomial:")
    print(f"  Result: {'NONZERO' if not result_zero['is_zero'] else 'ZERO'}")
    print(f"  Confidence: {result_zero['confidence']:.10f}")
    print()

    # Example 3: Minimum Distance
    print("--- Algorithm 3: Minimum Distance Computation ---")
    for q, n, d in [(5, 2, 2), (7, 3, 3), (11, 2, 5)]:
        info = compute_minimum_distance(GF(q), n, d)
        print(f"  RM_{q}({n},{d}): min_dist = {info['minimum_distance']}, "
              f"verified = {info['verified']}")
    print()

    # Example 4: Extremal Witness
    print("--- Algorithm 4: Extremal Witness Construction ---")
    wit_info = construct_extremal_witness(GF(7), 2, 3)
    print(f"  Witness: {wit_info['polynomial']}")
    print(f"  Degree: {wit_info['degree']}")
    print(f"  Zero count: {wit_info['zero_count']} (expected {wit_info['expected_zero_count']})")
    print(f"  Hamming weight: {wit_info['hamming_weight']} (expected {wit_info['expected_weight']})")
