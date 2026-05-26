"""
Algorithms for Lorentzian Polynomial Recognition and Complexity Analysis

Implements the key algorithms from the research paper:
1. Multiindex enumeration and counting
2. Derivative tree construction
3. Lorentzian signature testing
4. CNF-to-branch obstruction checking
5. Binary-to-multiindex encoding (from the lower bound proof)
"""

from typing import List, Tuple, Dict, Optional, Callable
from itertools import product
import numpy as np
from math import comb, factorial


def enumerate_multiindices(n: int, d: int) -> List[Tuple[int, ...]]:
    """
    Enumerate all multiindices α : {0,...,n-1} → ℕ with ∑α = d.

    Uses recursive generation: for each value of α[0] from 0 to d,
    recursively enumerate (n-1)-variable multiindices of weight d - α[0].

    Args:
        n: Number of variables
        d: Total weight (degree)

    Returns:
        List of tuples, each of length n, summing to d

    Example:
        >>> enumerate_multiindices(2, 3)
        [(0, 3), (1, 2), (2, 1), (3, 0)]
    """
    if n == 0:
        return [()] if d == 0 else []
    if n == 1:
        return [(d,)]
    result = []
    for k in range(d + 1):
        for rest in enumerate_multiindices(n - 1, d - k):
            result.append((k,) + rest)
    return result


def multiindex_count(n: int, d: int) -> int:
    """
    Count the number of multiindices of weight d in n variables.

    This equals C(n + d - 1, d) by the stars-and-bars theorem.

    Args:
        n: Number of variables
        d: Total weight

    Returns:
        The count C(n+d-1, d)

    Example:
        >>> multiindex_count(3, 4)
        15
    """
    if n == 0:
        return 1 if d == 0 else 0
    return comb(n + d - 1, d)


def quadratic_leaf_count(n: int, d: int) -> int:
    """
    Compute the number of quadratic leaves in recursive Lorentzian recognition.

    For a degree-d polynomial in n variables, this is C(n + d - 3, d - 2)
    when d >= 2, and 1 otherwise.

    Args:
        n: Number of variables
        d: Degree of the polynomial

    Returns:
        Number of quadratic leaves
    """
    if d < 2:
        return 1
    return multiindex_count(n, d - 2)


def binary_to_multiindex(b: Tuple[bool, ...], n: int) -> Tuple[int, ...]:
    """
    Encode a binary string as a multiindex (from the lower bound proof).

    Maps b : {0,1}^k to a multiindex α : {0,...,n-1} → ℕ with ∑α = k.
    α[i] = b[i] for i < k, α[k] = k - ∑b[i], α[i] = 0 for i > k.

    Args:
        b: Binary string of length k
        n: Number of variables (must be > k)

    Returns:
        Multiindex tuple of length n summing to len(b)

    Example:
        >>> binary_to_multiindex((True, False, True), 5)
        (1, 0, 1, 1, 0)
    """
    k = len(b)
    assert n > k, f"Need n > k, got n={n}, k={k}"
    alpha = [0] * n
    s = 0
    for i in range(k):
        alpha[i] = 1 if b[i] else 0
        s += alpha[i]
    alpha[k] = k - s
    return tuple(alpha)


def verify_lower_bound(max_k: int = 10) -> List[Dict]:
    """
    Verify the exponential lower bound 2^k ≤ |M(n, k)| for n > k.

    For each k, compute the actual multiindex count and compare with 2^k.

    Args:
        max_k: Maximum weight to test

    Returns:
        List of dicts with k, n, actual_count, lower_bound, ratio
    """
    results = []
    for k in range(max_k + 1):
        n = k + 1  # smallest n > k
        actual = multiindex_count(n, k)
        lb = 2 ** k
        results.append({
            'k': k,
            'n': n,
            'actual_count': actual,
            'lower_bound': lb,
            'upper_bound': n ** k if k > 0 else 1,
            'ratio_to_lower': actual / lb if lb > 0 else float('inf')
        })
    return results


class HessianMatrix:
    """Represents a symmetric matrix for Lorentzian signature testing."""

    def __init__(self, matrix: np.ndarray):
        assert matrix.shape[0] == matrix.shape[1], "Matrix must be square"
        self.n = matrix.shape[0]
        self.matrix = (matrix + matrix.T) / 2  # Symmetrize

    def quadratic_form(self, x: np.ndarray) -> float:
        """Compute Q_A(x) = x^T A x."""
        return float(x @ self.matrix @ x)

    def has_lorentzian_signature(self) -> bool:
        """
        Check if the matrix has at most one positive eigenvalue.

        Returns:
            True if at most one eigenvalue is positive
        """
        eigenvalues = np.linalg.eigvalsh(self.matrix)
        pos_count = np.sum(eigenvalues > 1e-10)
        return pos_count <= 1

    def eigenvalue_signature(self) -> Tuple[int, int, int]:
        """
        Compute the inertia (p, z, n) of the matrix:
        p = number of positive eigenvalues
        z = number of zero eigenvalues
        n = number of negative eigenvalues

        Returns:
            Tuple (positive, zero, negative)
        """
        eigenvalues = np.linalg.eigvalsh(self.matrix)
        pos = int(np.sum(eigenvalues > 1e-10))
        neg = int(np.sum(eigenvalues < -1e-10))
        zero = self.n - pos - neg
        return (pos, zero, neg)


class CNFFormula:
    """A CNF formula over Boolean variables."""

    def __init__(self, n_vars: int, clauses: List[List[Tuple[int, bool]]]):
        """
        Args:
            n_vars: Number of Boolean variables
            clauses: List of clauses, each clause is a list of (var_index, polarity) pairs
        """
        self.n_vars = n_vars
        self.clauses = clauses

    def is_satisfied(self, assignment: Tuple[bool, ...]) -> bool:
        """Check if the formula is satisfied by the given assignment."""
        for clause in self.clauses:
            clause_sat = False
            for var_idx, pol in clause:
                if assignment[var_idx] == pol:
                    clause_sat = True
                    break
            if not clause_sat:
                return False
        return True

    def is_satisfiable(self) -> Tuple[bool, Optional[Tuple[bool, ...]]]:
        """
        Check satisfiability by brute force.

        Returns:
            (is_sat, witness) where witness is a satisfying assignment or None
        """
        for assignment in product([False, True], repeat=self.n_vars):
            if self.is_satisfied(assignment):
                return True, assignment
        return False, None

    def find_conflicted_clauses(self, assignment: Tuple[bool, ...]) -> List[int]:
        """
        Find all clause indices that are conflicted (all literals falsified)
        under the given assignment.

        Returns:
            List of conflicted clause indices
        """
        conflicted = []
        for i, clause in enumerate(self.clauses):
            all_falsified = True
            for var_idx, pol in clause:
                if assignment[var_idx] == pol:
                    all_falsified = False
                    break
            if all_falsified:
                conflicted.append(i)
        return conflicted

    def verify_branch_duality(self) -> Dict:
        """
        Verify the Branch-SAT Duality: check that the formula is unsatisfiable
        iff every assignment has at least one conflicted clause.

        Returns:
            Dict with verification results
        """
        is_sat, witness = self.is_satisfiable()

        all_have_conflict = True
        for assignment in product([False, True], repeat=self.n_vars):
            conflicts = self.find_conflicted_clauses(assignment)
            if len(conflicts) == 0:
                all_have_conflict = False
                break

        return {
            'is_satisfiable': is_sat,
            'witness': witness,
            'all_assignments_have_conflict': all_have_conflict,
            'duality_holds': is_sat != all_have_conflict,
            # duality: UNSAT iff all assignments have conflict
        }


def phase_transition_data(max_n: int = 12) -> List[Dict]:
    """
    Compute certificate complexity data showing the phase transition.

    For each n, computes:
    - Fixed degree 3: O(n) certificates
    - Degree = n: exponential certificates

    Args:
        max_n: Maximum number of variables

    Returns:
        List of dicts with phase transition data
    """
    results = []
    for n in range(3, max_n + 1):
        fixed_deg = quadratic_leaf_count(n, 3)
        growing_deg = quadratic_leaf_count(n + 1, n)
        lower_bound = 2 ** (n - 2)
        results.append({
            'n': n,
            'fixed_degree_3': fixed_deg,
            'growing_degree_n': growing_deg,
            'lower_bound_2pow': lower_bound,
            'ratio': growing_deg / lower_bound if lower_bound > 0 else float('inf'),
            'log2_growing': np.log2(growing_deg) if growing_deg > 0 else 0,
        })
    return results


if __name__ == "__main__":
    print("=" * 60)
    print("Lorentzian Recognition Complexity Algorithms")
    print("=" * 60)

    # 1. Verify lower bound
    print("\n--- Exponential Lower Bound Verification ---")
    for r in verify_lower_bound(8):
        print(f"k={r['k']:2d}, n={r['n']:2d}: "
              f"|M(n,k)|={r['actual_count']:8d}, "
              f"2^k={r['lower_bound']:8d}, "
              f"n^k={r['upper_bound']:8d}, "
              f"ratio={r['ratio_to_lower']:.2f}")

    # 2. Phase transition
    print("\n--- Phase Transition Data ---")
    for r in phase_transition_data(10):
        print(f"n={r['n']:2d}: "
              f"L(n,3)={r['fixed_degree_3']:6d}, "
              f"L(n+1,n)={r['growing_degree_n']:10d}, "
              f"2^(n-2)={r['lower_bound_2pow']:8d}, "
              f"log₂={r['log2_growing']:.1f}")

    # 3. CNF duality verification
    print("\n--- Branch-SAT Duality Verification ---")

    # Example 1: Satisfiable formula
    phi_sat = CNFFormula(3, [
        [(0, True), (1, False)],   # x₀ ∨ ¬x₁
        [(1, True), (2, True)],    # x₁ ∨ x₂
    ])
    result = phi_sat.verify_branch_duality()
    print(f"Satisfiable formula: {result}")

    # Example 2: Unsatisfiable formula (x ∧ ¬x)
    phi_unsat = CNFFormula(1, [
        [(0, True)],   # x₀
        [(0, False)],  # ¬x₀
    ])
    result = phi_unsat.verify_branch_duality()
    print(f"Unsatisfiable formula: {result}")

    # 4. Signature testing
    print("\n--- Lorentzian Signature Testing ---")
    # Lorentzian matrix: diag(1, -1, -1)
    A_lor = HessianMatrix(np.diag([1.0, -1.0, -1.0]))
    print(f"diag(1,-1,-1): Lorentzian={A_lor.has_lorentzian_signature()}, "
          f"signature={A_lor.eigenvalue_signature()}")

    # Positive definite: I
    A_pd = HessianMatrix(np.eye(3))
    print(f"Identity 3x3: Lorentzian={A_pd.has_lorentzian_signature()}, "
          f"signature={A_pd.eigenvalue_signature()}")

    # 5. Binary encoding
    print("\n--- Binary-to-Multiindex Encoding ---")
    for b in [(False, False), (False, True), (True, False), (True, True)]:
        alpha = binary_to_multiindex(b, 4)
        print(f"b={b} → α={alpha}, ∑α={sum(alpha)}")
