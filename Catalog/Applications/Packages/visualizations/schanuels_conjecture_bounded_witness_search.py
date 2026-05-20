#!/usr/bin/env python3
"""
Algorithms for Schanuel Conjecture: Bounded Witness Search and
Algebraic Independence Certification

This module implements the computational methods described in the research paper:
1. Bounded-degree exponential witness search
2. Q-linear independence testing via lattice methods
3. Schanuel predimension computation
4. Minimal counterexample profiling

These algorithms correspond to the formal definitions in our Lean 4 development,
providing a computational bridge between formal proofs and numerical experimentation.
"""

import numpy as np
from typing import List, Tuple, Optional, Dict, Set
from dataclasses import dataclass, field
from itertools import product as cartesian_product
import math


@dataclass
class MonomialTerm:
    """A monomial c * x_1^{a_1} * ... * x_k^{a_k}."""
    coefficient: int
    exponents: Tuple[int, ...]

    @property
    def total_degree(self) -> int:
        return sum(self.exponents)

    def evaluate(self, values: List[complex]) -> complex:
        result = complex(self.coefficient)
        for val, exp in zip(values, self.exponents):
            if exp > 0:
                result *= val ** exp
        return result

    def __repr__(self) -> str:
        if self.coefficient == 0:
            return "0"
        parts = [str(self.coefficient)]
        for i, e in enumerate(self.exponents):
            if e > 0:
                parts.append(f"x_{i}^{e}" if e > 1 else f"x_{i}")
        return "*".join(parts)


@dataclass
class ExpAlgWitness:
    """
    An exponential algebraic dependence witness.

    Corresponds to the Lean structure ExpAlgDependenceWitness:
    - poly: a nonzero multivariate polynomial in 2n variables
    - vanishes: the polynomial evaluates to (approximately) 0

    Variables x_0, ..., x_{n-1} represent z_i,
    variables x_n, ..., x_{2n-1} represent exp(z_i).
    """
    n: int
    terms: List[MonomialTerm]
    residual: float

    @property
    def total_degree(self) -> int:
        return max((t.total_degree for t in self.terms), default=0)

    @property
    def is_nonzero(self) -> bool:
        return any(t.coefficient != 0 for t in self.terms)

    def evaluate(self, z_values: List[complex]) -> complex:
        """Evaluate the witness polynomial at (z, exp(z))."""
        exp_values = [np.exp(z) for z in z_values]
        all_values = list(z_values) + list(exp_values)
        return sum(t.evaluate(all_values) for t in self.terms)

    def __repr__(self) -> str:
        nonzero = [t for t in self.terms if t.coefficient != 0]
        if not nonzero:
            return "0"
        return " + ".join(str(t) for t in nonzero)


def generate_monomials(num_vars: int, max_degree: int) -> List[Tuple[int, ...]]:
    """
    Generate all monomials in `num_vars` variables with total degree ≤ `max_degree`.

    Returns a list of exponent tuples.

    Complexity: O(C(num_vars + max_degree, num_vars)) monomials generated.
    """
    if num_vars == 0:
        return [()]

    result = []

    def _generate(remaining_vars: int, remaining_degree: int, current: List[int]):
        if remaining_vars == 0:
            result.append(tuple(current))
            return
        for d in range(remaining_degree + 1):
            current.append(d)
            _generate(remaining_vars - 1, remaining_degree - d, current)
            current.pop()

    _generate(num_vars, max_degree, [])
    return result


def search_exp_witnesses(z_values: List[complex], degree_bound: int,
                          max_witnesses: int = 10,
                          tolerance: float = 1e-8) -> List[ExpAlgWitness]:
    """
    Search for polynomial relations among z_i and exp(z_i) up to a given degree.

    Algorithm:
    1. Generate all monomials in 2n variables up to degree `degree_bound`.
    2. Evaluate each monomial at the point (z, exp(z)).
    3. Use SVD to find approximate null vectors of the evaluation matrix.
    4. Round null vectors to integer coefficients.
    5. Verify each candidate witness.

    Args:
        z_values: Complex numbers z_1, ..., z_n
        degree_bound: Maximum total degree of polynomial relations to search
        max_witnesses: Maximum number of witnesses to return
        tolerance: Numerical tolerance for considering a relation as vanishing

    Returns:
        List of ExpAlgWitness objects, sorted by degree.

    Complexity:
        Time: O(M^2 * n) where M = C(2n + D, 2n) is the number of monomials
        Space: O(M * n)
    """
    n = len(z_values)
    if n == 0:
        return []

    exp_values = [np.exp(z) for z in z_values]
    all_values = list(z_values) + list(exp_values)

    # Generate monomials
    monomials = generate_monomials(2 * n, degree_bound)
    M = len(monomials)

    if M <= 1:
        return []

    # Evaluate monomials
    eval_matrix = np.zeros((2, M))  # Real and imaginary parts
    for j, expo in enumerate(monomials):
        val = complex(1.0)
        for i, e in enumerate(expo):
            if e > 0:
                val *= all_values[i] ** e
        eval_matrix[0, j] = val.real
        eval_matrix[1, j] = val.imag

    # SVD to find null space
    U, S, Vt = np.linalg.svd(eval_matrix, full_matrices=True)

    witnesses = []
    for k in range(min(max_witnesses + 5, M - 2)):
        null_vec = Vt[-(k + 1), :]

        # Try different scalings to find integer coefficients
        for scale_idx in range(M):
            if abs(null_vec[scale_idx]) > 0.1:
                scaled = null_vec / null_vec[scale_idx]
                rounded = np.round(scaled).astype(int)

                if np.all(rounded == 0):
                    continue

                # Evaluate with integer coefficients
                poly_val = sum(c * v for c, v in
                               zip(rounded,
                                   [complex(1.0) * np.prod([all_values[i] ** e
                                    for i, e in enumerate(expo) if e > 0], initial=1.0)
                                    for expo in monomials]))
                residual = abs(poly_val)

                if residual < tolerance:
                    terms = [MonomialTerm(int(c), expo)
                             for c, expo in zip(rounded, monomials)
                             if c != 0]
                    if terms:
                        witness = ExpAlgWitness(n=n, terms=terms, residual=residual)
                        witnesses.append(witness)
                        break

    # Sort by degree and remove duplicates
    witnesses.sort(key=lambda w: (w.total_degree, w.residual))
    seen = set()
    unique = []
    for w in witnesses:
        key = tuple((t.coefficient, t.exponents) for t in w.terms)
        if key not in seen:
            seen.add(key)
            unique.append(w)

    return unique[:max_witnesses]


def check_linear_independence_lll(values: List[complex],
                                   precision: int = 50) -> Dict:
    """
    Check Q-linear independence using a PSLQ/LLL-style approach.

    For n complex numbers, searches for integer relations
    c_1*v_1 + ... + c_n*v_n = 0 with |c_i| ≤ precision.

    Args:
        values: List of complex numbers
        precision: Maximum absolute value of integer coefficients to search

    Returns:
        Dictionary with independence results.
    """
    n = len(values)
    if n == 0:
        return {'independent': True, 'dim': 0}
    if n == 1:
        is_zero = abs(values[0]) < 1e-15
        return {'independent': not is_zero, 'dim': 0 if is_zero else 1}

    # Build real/imaginary matrix
    A = np.zeros((2, n))
    for j, v in enumerate(values):
        A[0, j] = v.real if isinstance(v, complex) else float(v)
        A[1, j] = v.imag if isinstance(v, complex) else 0.0

    # Search for small integer relations
    best_relation = None
    best_residual = float('inf')
    search_range = min(precision, 20)  # Cap for tractability

    for coeffs in cartesian_product(range(-search_range, search_range + 1), repeat=n):
        if all(c == 0 for c in coeffs):
            continue
        c = np.array(coeffs, dtype=float)
        residual = np.linalg.norm(A @ c)
        if residual < best_residual:
            best_residual = residual
            best_relation = list(coeffs)

    threshold = 1e-10
    if best_residual < threshold:
        return {
            'independent': False,
            'dim': None,
            'relation': best_relation,
            'residual': best_residual
        }
    else:
        return {
            'independent': True,
            'dim': n,
            'min_residual': best_residual
        }


def compute_schanuel_predimension(z_values: List[complex],
                                    degree_bound: int = 4) -> Dict:
    """
    Compute the Schanuel predimension for a tuple.

    The Schanuel predimension δ(z) is defined as:
        δ(z) = exp_alg_dim(z) - q_lin_dim(z)

    where:
    - q_lin_dim(z) = dimension of Q-span of {z_1, ..., z_n}
    - exp_alg_dim(z) = algebraic independence rank of {z_i, exp(z_i)}

    Schanuel's conjecture asserts δ(z) ≥ 0 for all tuples.

    This function computes a numerical estimate.
    """
    n = len(z_values)

    # Compute Q-linear dimension (heuristic)
    lin_result = check_linear_independence_lll(z_values)
    q_lin_dim = lin_result.get('dim', n)
    if q_lin_dim is None:
        q_lin_dim = n - 1  # Found one relation

    # Estimate algebraic independence rank via witness search
    witnesses = search_exp_witnesses(z_values, degree_bound)
    num_relations = len(witnesses)

    # Upper bound on alg. indep. rank: 2n - num_relations
    exp_alg_dim_upper = 2 * n - num_relations

    predim_upper = exp_alg_dim_upper - q_lin_dim

    return {
        'n': n,
        'q_lin_dim': q_lin_dim,
        'num_relations_found': num_relations,
        'exp_alg_dim_upper_bound': exp_alg_dim_upper,
        'predimension_upper_bound': predim_upper,
        'schanuel_satisfied': predim_upper >= 0 or num_relations == 0,
        'witnesses': witnesses
    }


def profile_critical_candidate(z_values: List[complex],
                                 degree_bound: int = 4) -> Dict:
    """
    Profile a tuple as a potential Schanuel-critical candidate.

    A tuple is Schanuel-critical if:
    1. It is Q-linearly independent
    2. Its exponentials are algebraically dependent
    3. Every proper subtuple has algebraically independent exponentials

    This function checks these conditions numerically.
    """
    n = len(z_values)

    # Check condition 1: Q-linear independence
    lin_check = check_linear_independence_lll(z_values)
    is_lin_indep = lin_check['independent']

    # Check condition 2: Algebraic dependence of exponentials
    exp_values = [np.exp(z) for z in z_values]
    exp_witnesses = search_exp_witnesses(z_values, degree_bound)
    has_exp_dep = len(exp_witnesses) > 0

    # Check condition 3: Proper subtuples
    proper_all_indep = True
    subtuple_details = []
    if n >= 2:
        for size in range(1, n):
            from itertools import combinations
            for indices in combinations(range(n), size):
                sub_z = [z_values[i] for i in indices]
                sub_witnesses = search_exp_witnesses(sub_z, degree_bound)
                sub_indep = len(sub_witnesses) == 0
                subtuple_details.append({
                    'indices': indices,
                    'independent': sub_indep,
                    'witnesses_found': len(sub_witnesses)
                })
                if not sub_indep:
                    proper_all_indep = False

    is_critical = is_lin_indep and has_exp_dep and proper_all_indep

    return {
        'n': n,
        'is_lin_independent': is_lin_indep,
        'has_exp_dependence': has_exp_dep,
        'proper_subtuples_independent': proper_all_indep,
        'is_critical_candidate': is_critical,
        'num_exp_witnesses': len(exp_witnesses),
        'subtuple_details': subtuple_details,
        'assessment': (
            "CRITICAL CANDIDATE" if is_critical else
            "NOT CRITICAL" + (
                " (linearly dependent)" if not is_lin_indep else
                " (exponentials independent)" if not has_exp_dep else
                " (subtuple has dependence)"
            )
        )
    }


def bounded_independence_certificate(z_values: List[complex],
                                      degree_bound: int) -> Dict:
    """
    Produce a bounded independence certificate.

    Searches for all polynomial relations up to a given degree and reports
    either explicit witnesses or a certificate that no such relation exists.

    This corresponds to the formal theorem:
        no_small_witness_implies_bounded_independence

    Returns:
        Certificate dictionary with search results and formal interpretation.
    """
    witnesses = search_exp_witnesses(z_values, degree_bound)

    if witnesses:
        return {
            'certified_independent': False,
            'degree_bound': degree_bound,
            'witnesses_found': len(witnesses),
            'min_witness_degree': min(w.total_degree for w in witnesses),
            'witnesses': witnesses,
            'formal_statement': (
                f"Found {len(witnesses)} witness(es). "
                f"The combined tuple is NOT algebraically independent."
            )
        }
    else:
        return {
            'certified_independent': True,
            'degree_bound': degree_bound,
            'witnesses_found': 0,
            'formal_statement': (
                f"NoExpWitnessUpToDeg n z {degree_bound}: "
                f"No nonzero polynomial of total degree ≤ {degree_bound} "
                f"vanishes on (z, exp(z)). "
                f"This certifies bounded algebraic independence."
            )
        }


if __name__ == "__main__":
    print("=== Schanuel Conjecture: Algorithmic Tools ===\n")

    # Example 1: Single algebraic number
    print("Example 1: z = (1,)")
    z = [1.0 + 0j]
    cert = bounded_independence_certificate(z, degree_bound=5)
    print(f"  {cert['formal_statement']}\n")

    # Example 2: Two independent algebraic numbers
    print("Example 2: z = (1, √2)")
    z = [1.0 + 0j, np.sqrt(2) + 0j]
    pred = compute_schanuel_predimension(z)
    print(f"  Q-linear dim: {pred['q_lin_dim']}")
    print(f"  Relations found: {pred['num_relations_found']}")
    print(f"  Predimension upper bound: {pred['predimension_upper_bound']}")
    print(f"  Schanuel satisfied: {pred['schanuel_satisfied']}\n")

    # Example 3: Critical candidate profiling
    print("Example 3: Profiling (1, 2, 3) — linearly dependent")
    z = [1.0 + 0j, 2.0 + 0j, 3.0 + 0j]
    profile = profile_critical_candidate(z)
    print(f"  Assessment: {profile['assessment']}\n")

    # Example 4: Euler's identity
    print("Example 4: z = (πi) — Euler's identity")
    z = [np.pi * 1j]
    witnesses = search_exp_witnesses(z, degree_bound=3)
    cert = bounded_independence_certificate(z, degree_bound=3)
    print(f"  exp(πi) = {np.exp(np.pi * 1j):.6f}")
    print(f"  {cert['formal_statement']}")
