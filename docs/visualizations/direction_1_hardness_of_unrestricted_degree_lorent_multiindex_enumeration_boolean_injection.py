#!/usr/bin/env python3
"""
Algorithms for Lorentzian Recognition Complexity Analysis

Implements:
1. Multiindex enumeration and counting
2. Boolean-to-multiindex injection
3. Derivative branch tree exploration
4. Quadratic leaf Hessian computation
5. Lorentzian signature testing
6. CNF-to-polynomial encoding (candidate)
7. Certificate size computation

All algorithms include docstrings, type hints, and complexity analysis.
"""

import numpy as np
from math import comb
from itertools import product
from typing import List, Tuple, Dict, Optional, Generator
from functools import lru_cache


# =============================================================================
# Algorithm 1: Multiindex Enumeration
# =============================================================================

def enumerate_multiindices(n: int, d: int) -> Generator[Tuple[int, ...], None, None]:
    """
    Enumerate all multiindices α ∈ ℕ^n with |α| = d.

    Uses recursive generation (stars-and-bars).

    Pseudocode:
        MULTIINDICES(n, d):
            if n = 1: yield (d,)
            else:
                for k = 0 to d:
                    for α' in MULTIINDICES(n-1, d-k):
                        yield (k,) + α'

    Time:  O(C(n+d-1, d)) per enumeration
    Space: O(n) stack depth

    Args:
        n: Number of variables
        d: Weight (sum of components)

    Yields:
        Tuples of length n summing to d
    """
    if n == 1:
        yield (d,)
    elif n > 1:
        for k in range(d + 1):
            for rest in enumerate_multiindices(n - 1, d - k):
                yield (k,) + rest


def multiindex_count_exact(n: int, d: int) -> int:
    """
    Exact count of multiindices: C(n+d-1, d).

    Time:  O(min(n, d))
    Space: O(1)
    """
    return comb(n + d - 1, d)


# =============================================================================
# Algorithm 2: Boolean-to-Multiindex Injection
# =============================================================================

def bool_to_multiindex(m: int, b: Tuple[bool, ...]) -> Tuple[int, ...]:
    """
    Inject b ∈ {0,1}^m into a multiindex α ∈ ℕ^{m+1} with |α| = m.

    Construction:
        α[0] = m - count_true(b)
        α[i+1] = int(b[i])  for i = 0, ..., m-1

    Pseudocode:
        BOOL_TO_MULTIINDEX(m, b):
            ct ← COUNT(b, true)
            α[0] ← m - ct
            for i = 0 to m-1:
                α[i+1] ← int(b[i])
            return α

    Properties:
        - Weight preservation: |α| = m
        - Injectivity: b recoverable from α[1:m+1]

    Time:  O(m)
    Space: O(m)

    Args:
        m: Dimension of Boolean space
        b: Boolean tuple of length m

    Returns:
        Multiindex tuple of length m+1 with weight m
    """
    ct = sum(1 for x in b if x)
    return (m - ct,) + tuple(int(x) for x in b)


def multiindex_to_bool(m: int, alpha: Tuple[int, ...]) -> Optional[Tuple[bool, ...]]:
    """
    Inverse of bool_to_multiindex (when valid).

    Time:  O(m)
    Space: O(m)

    Returns:
        Boolean tuple if alpha is in the image, None otherwise
    """
    if len(alpha) != m + 1:
        return None
    b = tuple(x == 1 for x in alpha[1:])
    if all(x in (0, 1) for x in alpha[1:]):
        expected_slack = m - sum(1 for x in b if x)
        if alpha[0] == expected_slack:
            return b
    return None


def verify_injection(m: int) -> bool:
    """
    Verify that bool_to_multiindex is injective for given m.

    Time:  O(2^m · m)
    Space: O(2^m · m)
    """
    images = set()
    for b in product([False, True], repeat=m):
        alpha = bool_to_multiindex(m, b)
        if alpha in images:
            return False
        images.add(alpha)
        if sum(alpha) != m:
            return False
    return len(images) == 2 ** m


# =============================================================================
# Algorithm 3: Derivative Branch Tree
# =============================================================================

class DerivativeBranch:
    """
    Represents a branch in the derivative tree of a polynomial.

    A branch is specified by a multiindex α = (α₁, ..., αₙ) indicating
    how many times to differentiate with respect to each variable.

    Attributes:
        multiindex: The differentiation orders
        depth: Total differentiation depth = |α|
        is_leaf: Whether this is a quadratic leaf (depth = d-2)
    """

    def __init__(self, multiindex: Tuple[int, ...], target_depth: int):
        self.multiindex = multiindex
        self.depth = sum(multiindex)
        self.is_leaf = (self.depth == target_depth)

    def __repr__(self):
        return f"Branch(α={self.multiindex}, depth={self.depth}, leaf={self.is_leaf})"


def build_derivative_tree(n: int, d: int) -> List[DerivativeBranch]:
    """
    Build the complete derivative tree for degree-d, n-variable recognition.

    Pseudocode:
        DERIVATIVE_TREE(n, d):
            leaves ← []
            for α in MULTIINDICES(n, d-2):
                leaves.append(Branch(α, d-2))
            return leaves

    Time:  O(C(n+d-3, d-2))
    Space: O(C(n+d-3, d-2))

    Args:
        n: Number of variables
        d: Degree of polynomial

    Returns:
        List of all leaf branches
    """
    if d < 2:
        return [DerivativeBranch((0,) * n, 0)]

    target = d - 2
    leaves = []
    for alpha in enumerate_multiindices(n, target):
        leaves.append(DerivativeBranch(alpha, target))
    return leaves


# =============================================================================
# Algorithm 4: Hessian Computation for Quadratic Polynomials
# =============================================================================

def compute_hessian(coeffs: Dict[Tuple[int, ...], float], n: int) -> np.ndarray:
    """
    Compute the Hessian matrix of a polynomial from its coefficients.

    For a quadratic polynomial f = Σ c_α x^α, the Hessian H_{ij} is
    the coefficient of the monomial obtained by differentiating twice.

    H[i][j] = coefficient of ∂²f/∂xᵢ∂xⱼ evaluated at 0
            = 2·c_{eᵢ+eⱼ} if i≠j, = 2·c_{2eᵢ} if i=j

    Time:  O(n²)
    Space: O(n²)
    """
    H = np.zeros((n, n))
    for alpha, coeff in coeffs.items():
        if sum(alpha) != 2:
            continue
        for i in range(n):
            for j in range(n):
                ei_ej = list(alpha)
                if ei_ej[i] > 0:
                    factor_i = ei_ej[i]
                    ei_ej[i] -= 1
                    if ei_ej[j] > 0:
                        factor_j = ei_ej[j]
                        H[i][j] += coeff * factor_i * factor_j
                    ei_ej[i] += 1
    return H


def check_lorentzian_signature(H: np.ndarray, tol: float = 1e-10) -> Tuple[bool, int]:
    """
    Check if a symmetric matrix has Lorentzian signature (≤1 positive eigenvalue).

    Pseudocode:
        LORENTZIAN_CHECK(H):
            eigenvalues ← EIGVALSH(H)
            pos_count ← COUNT(eigenvalues > 0)
            return pos_count ≤ 1

    Time:  O(n³) for eigenvalue decomposition
    Space: O(n²)
    """
    eigenvalues = np.linalg.eigvalsh(H)
    pos_count = int(np.sum(eigenvalues > tol))
    return pos_count <= 1, pos_count


# =============================================================================
# Algorithm 5: CNF Formula Operations
# =============================================================================

class CNFFormula:
    """
    A CNF (Conjunctive Normal Form) Boolean formula.

    Each clause is a list of (variable_index, polarity) pairs.
    """

    def __init__(self, num_vars: int, clauses: List[List[Tuple[int, bool]]]):
        self.num_vars = num_vars
        self.clauses = clauses

    def evaluate(self, assignment: Tuple[bool, ...]) -> bool:
        """
        Evaluate the formula under a given assignment.

        Time:  O(total literals)
        Space: O(1)
        """
        for clause in self.clauses:
            if not any(assignment[v] == p for v, p in clause):
                return False
        return True

    def is_satisfiable(self) -> Tuple[bool, Optional[Tuple[bool, ...]]]:
        """
        Brute-force satisfiability check.

        Time:  O(2^n · m · k) where m=clauses, k=max clause size
        Space: O(n)
        """
        for assignment in product([False, True], repeat=self.num_vars):
            if self.evaluate(assignment):
                return True, assignment
        return False, None

    def find_obstruction(self, assignment: Tuple[bool, ...]) -> Optional[int]:
        """
        Find the first unsatisfied clause for a given assignment.

        Time:  O(m · k)
        Space: O(1)
        """
        for idx, clause in enumerate(self.clauses):
            if not any(assignment[v] == p for v, p in clause):
                return idx
        return None

    def verify_obstruction_duality(self) -> bool:
        """
        Verify the sat-obstruction duality theorem:
        ¬Satisfiable ↔ ∀τ, isObstructed(τ)

        Time:  O(2^n · m · k)
        """
        is_sat, _ = self.is_satisfiable()
        all_obstructed = all(
            self.find_obstruction(tau) is not None
            for tau in product([False, True], repeat=self.num_vars)
        )
        return is_sat != all_obstructed  # Duality: sat ↔ ¬all_obstructed


# =============================================================================
# Algorithm 6: Certificate Size Computation
# =============================================================================

def certificate_complexity(n: int, d: int) -> Dict[str, int]:
    """
    Compute certificate complexity bounds for Lorentzian recognition.

    Pseudocode:
        CERTIFICATE_BOUNDS(n, d):
            exact ← MULTIINDEX_COUNT(n, d-2)
            upper ← n^(d-2)
            lower ← 2^(d-2) if n ≥ d-1 else 1
            return {exact, upper, lower}

    Time:  O(1) for bounds, O(min(n, d)) for exact
    Space: O(1)
    """
    if d < 2:
        return {"exact": 1, "upper": 1, "lower": 1}

    exact = multiindex_count_exact(n, d - 2)
    upper = n ** (d - 2)
    # Lower bound from injection: if n ≥ (d-2)+1, then ≥ 2^(d-2)
    if n >= d - 1:
        lower = 2 ** (d - 2)
    else:
        lower = 1

    return {"exact": exact, "upper": upper, "lower": lower}


def growth_rate_analysis(max_m: int = 12) -> List[Dict]:
    """
    Analyze growth rates along the phase transition diagonal.

    Returns data for each m: the exact count, bounds, and ratios.
    """
    results = []
    for m in range(1, max_m + 1):
        n, d = m + 1, m + 2
        exact = multiindex_count_exact(n, d - 2)
        lower = 2 ** m
        upper = (m + 1) ** m
        central_binom = comb(2 * m, m)

        results.append({
            "m": m,
            "n": n,
            "d": d,
            "exact": exact,
            "lower_2m": lower,
            "upper_nm": upper,
            "central_binomial": central_binom,
            "ratio_exact_lower": exact / lower,
            "log2_exact": np.log2(exact),
        })
    return results


# =============================================================================
# Algorithm 7: Spectral Obstruction Finder
# =============================================================================

def find_spectral_obstruction(A: np.ndarray, tol: float = 1e-10) -> Optional[Dict]:
    """
    Find a spectral obstruction proving A is non-Lorentzian.

    If A has ≥2 positive eigenvalues, returns two orthogonal directions
    with positive quadratic form, certifying the spectral obstruction.

    Pseudocode:
        FIND_OBSTRUCTION(A):
            eigenvalues, eigenvectors ← EIGH(A)
            pos_indices ← {i : eigenvalues[i] > 0}
            if |pos_indices| < 2: return None
            i, j ← first two elements of pos_indices
            return (eigenvectors[:,i], eigenvectors[:,j])

    Time:  O(n³)
    Space: O(n²)
    """
    eigenvalues, eigenvectors = np.linalg.eigh(A)
    pos_indices = np.where(eigenvalues > tol)[0]

    if len(pos_indices) < 2:
        return None

    i, j = pos_indices[0], pos_indices[1]
    v1 = eigenvectors[:, i]
    v2 = eigenvectors[:, j]

    return {
        "eigenvalue_1": float(eigenvalues[i]),
        "eigenvalue_2": float(eigenvalues[j]),
        "direction_1": v1,
        "direction_2": v2,
        "quad_form_1": float(v1 @ A @ v1),
        "quad_form_2": float(v2 @ A @ v2),
        "orthogonality": float(np.abs(v1 @ v2)),
    }


# =============================================================================
# Main: Run all algorithms with examples
# =============================================================================

if __name__ == "__main__":
    print("Algorithms for Lorentzian Recognition Complexity")
    print("=" * 50)

    # Algorithm 1: Multiindex enumeration
    print("\n1. Multiindex enumeration (n=3, d=2):")
    for alpha in enumerate_multiindices(3, 2):
        print(f"   {alpha}")
    print(f"   Count: {multiindex_count_exact(3, 2)}")

    # Algorithm 2: Boolean injection
    print("\n2. Boolean injection verification:")
    for m in range(1, 8):
        valid = verify_injection(m)
        count = multiindex_count_exact(m + 1, m)
        print(f"   m={m}: injection valid={valid}, "
              f"|multiindices|={count}, 2^m={2**m}")

    # Algorithm 5: CNF operations
    print("\n5. CNF satisfiability:")
    phi = CNFFormula(3, [
        [(0, True), (1, True)],
        [(1, False), (2, True)],
        [(0, False), (2, False)],
    ])
    is_sat, witness = phi.is_satisfiable()
    print(f"   Formula satisfiable: {is_sat}")
    if witness:
        print(f"   Witness: {witness}")
    print(f"   Duality verified: {phi.verify_obstruction_duality()}")

    # Algorithm 6: Certificate complexity
    print("\n6. Certificate complexity analysis:")
    for result in growth_rate_analysis(10):
        print(f"   m={result['m']}: exact={result['exact']}, "
              f"lower={result['lower_2m']}, upper={result['upper_nm']}, "
              f"ratio={result['ratio_exact_lower']:.2f}")

    # Algorithm 7: Spectral obstruction
    print("\n7. Spectral obstruction:")
    A = np.array([[3, 1, 0], [1, 2, 0], [0, 0, -1]], dtype=float)
    obs = find_spectral_obstruction(A)
    if obs:
        print(f"   Obstruction found!")
        print(f"   Eigenvalues: {obs['eigenvalue_1']:.3f}, {obs['eigenvalue_2']:.3f}")
        print(f"   Q(v1)={obs['quad_form_1']:.3f}, Q(v2)={obs['quad_form_2']:.3f}")
        print(f"   Orthogonality: {obs['orthogonality']:.2e}")
