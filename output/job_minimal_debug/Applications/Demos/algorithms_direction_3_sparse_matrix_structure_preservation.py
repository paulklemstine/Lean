#!/usr/bin/env python3
"""
Algorithms for Sparse Matrix Structure Preservation

Implements the core algorithms from the research:
1. Row support computation
2. Row sparsity checking
3. Syntactic sparsity budget computation (matLeafCount)
4. Verified bound checking
5. CSR-format sparse matrix operations with support tracking
"""

import numpy as np
from typing import List, Set, Dict, Tuple, Optional
from dataclasses import dataclass, field
from enum import Enum, auto


# ============================================================================
# Algorithm 1: Row Support Computation
# ============================================================================

def compute_row_support(A: np.ndarray, i: int, tol: float = 0.0) -> Set[int]:
    """
    Compute the row support of matrix A at row i.

    The row support is the set of column indices j where A[i,j] ≠ 0.
    An optional tolerance can be used for floating-point comparisons.

    Time complexity: O(n) where n is the number of columns.
    Space complexity: O(s) where s is the number of nonzeros in row i.

    Args:
        A: Input matrix (n × n)
        i: Row index
        tol: Tolerance for zero comparison (default: exact)

    Returns:
        Set of column indices with nonzero entries
    """
    n = A.shape[1]
    return {j for j in range(n) if abs(A[i, j]) > tol}


def compute_all_row_supports(A: np.ndarray, tol: float = 0.0) -> List[Set[int]]:
    """
    Compute row supports for all rows.

    Time complexity: O(n²)
    Space complexity: O(nnz) where nnz is the total number of nonzeros.
    """
    return [compute_row_support(A, i, tol) for i in range(A.shape[0])]


# ============================================================================
# Algorithm 2: Row Sparsity Checking
# ============================================================================

def check_row_sparse(A: np.ndarray, s: int, tol: float = 0.0) -> Tuple[bool, int]:
    """
    Check if matrix A is row-s-sparse.

    Returns (is_sparse, max_row_support_size).

    Time complexity: O(n²)
    Space complexity: O(n)

    Args:
        A: Input matrix
        s: Sparsity bound
        tol: Tolerance for zero comparison

    Returns:
        (True if row-s-sparse, maximum row support size)
    """
    max_support = 0
    for i in range(A.shape[0]):
        support_size = sum(1 for j in range(A.shape[1]) if abs(A[i, j]) > tol)
        max_support = max(max_support, support_size)
    return max_support <= s, max_support


# ============================================================================
# Algorithm 3: Tensor Term AST and Leaf Count
# ============================================================================

class TermKind(Enum):
    MAT_VAR = auto()
    MAT_ADD = auto()
    SMUL_MAT = auto()


@dataclass
class MatTerm:
    """AST node for mat-sorted tensor terms."""
    kind: TermKind
    var_id: int = 0
    scalar: float = 1.0
    children: List['MatTerm'] = field(default_factory=list)

    @staticmethod
    def var(k: int) -> 'MatTerm':
        return MatTerm(TermKind.MAT_VAR, var_id=k)

    @staticmethod
    def add(a: 'MatTerm', b: 'MatTerm') -> 'MatTerm':
        return MatTerm(TermKind.MAT_ADD, children=[a, b])

    @staticmethod
    def smul(c: float, a: 'MatTerm') -> 'MatTerm':
        return MatTerm(TermKind.SMUL_MAT, scalar=c, children=[a])


def mat_leaf_count(t: MatTerm) -> int:
    """
    Compute the matrix leaf count (sparsity budget multiplier).

    This is the key syntactic invariant:
    - Variable: 1
    - Addition: sum of children's counts
    - Scalar multiplication: same as child's count

    Time complexity: O(|t|) where |t| is the term size.

    Args:
        t: A mat-sorted tensor term

    Returns:
        The matrix leaf count
    """
    if t.kind == TermKind.MAT_VAR:
        return 1
    elif t.kind == TermKind.MAT_ADD:
        return mat_leaf_count(t.children[0]) + mat_leaf_count(t.children[1])
    elif t.kind == TermKind.SMUL_MAT:
        return mat_leaf_count(t.children[0])
    return 0


def row_sparsity_budget(t: MatTerm, s: int) -> int:
    """
    Compute the predicted row sparsity bound for term t in an s-sparse environment.

    This is matLeafCount(t) * s.

    Args:
        t: A mat-sorted tensor term
        s: Base sparsity of the environment

    Returns:
        The predicted maximum row support size
    """
    return mat_leaf_count(t) * s


# ============================================================================
# Algorithm 4: Term Evaluation with Support Tracking
# ============================================================================

@dataclass
class EvalResult:
    """Result of evaluating a term, with support tracking."""
    matrix: np.ndarray
    max_row_support: int
    predicted_bound: int
    is_within_bound: bool


def eval_mat_tracked(
    t: MatTerm,
    env: Dict[int, np.ndarray],
    s: int,
    tol: float = 0.0
) -> EvalResult:
    """
    Evaluate a mat-sorted term with row support tracking.

    Computes both the matrix value and verifies the support bound.

    Args:
        t: Term to evaluate
        env: Environment mapping variable IDs to matrices
        s: Base sparsity of environment
        tol: Tolerance for zero comparison

    Returns:
        EvalResult with matrix, observed support, predicted bound, and validity
    """
    if t.kind == TermKind.MAT_VAR:
        M = env[t.var_id].copy()
    elif t.kind == TermKind.MAT_ADD:
        left = eval_mat_tracked(t.children[0], env, s, tol)
        right = eval_mat_tracked(t.children[1], env, s, tol)
        M = left.matrix + right.matrix
    elif t.kind == TermKind.SMUL_MAT:
        child = eval_mat_tracked(t.children[0], env, s, tol)
        M = t.scalar * child.matrix
    else:
        raise ValueError(f"Unknown term kind: {t.kind}")

    _, max_support = check_row_sparse(M, 0, tol)
    bound = row_sparsity_budget(t, s)

    return EvalResult(
        matrix=M,
        max_row_support=max_support,
        predicted_bound=bound,
        is_within_bound=max_support <= bound
    )


# ============================================================================
# Algorithm 5: Normalization with Invariant Verification
# ============================================================================

def normalize_step(t: MatTerm) -> MatTerm:
    """
    One-step normalization: distribute scalar multiplication over addition.

    c • (A + B) → (c • A) + (c • B)

    This preserves:
    1. Semantic equality (normStepMat_sound)
    2. Leaf count (normStepMat_preserves_matLeafCount)
    3. Row sparsity bound (normalize_rowSparse_bound)

    Args:
        t: Input term

    Returns:
        Normalized term (one step)
    """
    if (t.kind == TermKind.SMUL_MAT and
        len(t.children) > 0 and
        t.children[0].kind == TermKind.MAT_ADD):
        inner = t.children[0]
        return MatTerm.add(
            MatTerm.smul(t.scalar, inner.children[0]),
            MatTerm.smul(t.scalar, inner.children[1])
        )
    return t


def verify_normalization_invariants(
    t: MatTerm,
    env: Dict[int, np.ndarray],
    s: int,
    tol: float = 1e-10
) -> Dict[str, bool]:
    """
    Verify all normalization invariants for a given term.

    Checks:
    1. Semantic equality: eval(t) == eval(normalize(t))
    2. Leaf count preservation: leafCount(t) == leafCount(normalize(t))
    3. Support bound: both t and normalize(t) satisfy the bound

    Args:
        t: Input term
        env: Environment
        s: Base sparsity
        tol: Tolerance for floating-point comparison

    Returns:
        Dictionary of invariant names to verification results
    """
    t_norm = normalize_step(t)

    result_orig = eval_mat_tracked(t, env, s, tol)
    result_norm = eval_mat_tracked(t_norm, env, s, tol)

    return {
        "semantic_equality": np.allclose(result_orig.matrix, result_norm.matrix, atol=tol),
        "leaf_count_preserved": mat_leaf_count(t) == mat_leaf_count(t_norm),
        "original_within_bound": result_orig.is_within_bound,
        "normalized_within_bound": result_norm.is_within_bound,
    }


# ============================================================================
# Algorithm 6: Disjointness Check and Exact Support Computation
# ============================================================================

def check_row_disjoint(A: np.ndarray, B: np.ndarray, tol: float = 0.0) -> bool:
    """
    Check if matrices A and B are row-disjoint.

    Row-disjoint means: for all i,j, if A[i,j] ≠ 0 then B[i,j] = 0.

    Time complexity: O(n²)

    Args:
        A, B: Input matrices
        tol: Tolerance for zero comparison

    Returns:
        True if row-disjoint
    """
    n = A.shape[0]
    for i in range(n):
        for j in range(A.shape[1]):
            if abs(A[i, j]) > tol and abs(B[i, j]) > tol:
                return False
    return True


def verify_support_exactness(
    A: np.ndarray,
    B: np.ndarray,
    tol: float = 0.0
) -> Tuple[bool, Optional[int]]:
    """
    Verify Theorem 6: under disjointness, support of A+B equals union.

    Args:
        A, B: Input matrices (must be row-disjoint)
        tol: Tolerance

    Returns:
        (all_exact, first_violation_row or None)
    """
    if not check_row_disjoint(A, B, tol):
        return False, None

    n = A.shape[0]
    for i in range(n):
        support_sum = compute_row_support(A + B, i, tol)
        support_union = compute_row_support(A, i, tol) | compute_row_support(B, i, tol)
        if support_sum != support_union:
            return False, i

    return True, None


# ============================================================================
# Example Usage
# ============================================================================

if __name__ == "__main__":
    import random
    random.seed(42)
    np.random.seed(42)

    n, s = 20, 3

    # Create sparse environment
    def make_sparse(n, s):
        A = np.zeros((n, n))
        for i in range(n):
            cols = random.sample(range(n), min(s, n))
            for j in cols:
                A[i, j] = random.uniform(-10, 10)
        return A

    env = {k: make_sparse(n, s) for k in range(4)}

    # Build a term: (2.0 * M0) + (M1 + M2)
    t = MatTerm.add(
        MatTerm.smul(2.0, MatTerm.var(0)),
        MatTerm.add(MatTerm.var(1), MatTerm.var(2))
    )

    print(f"Term: {t.kind}")
    print(f"Leaf count: {mat_leaf_count(t)}")
    print(f"Predicted bound: {row_sparsity_budget(t, s)}")

    result = eval_mat_tracked(t, env, s)
    print(f"Observed max row support: {result.max_row_support}")
    print(f"Within bound: {result.is_within_bound}")

    # Verify normalization invariants
    t2 = MatTerm.smul(3.0, MatTerm.add(MatTerm.var(0), MatTerm.var(1)))
    invariants = verify_normalization_invariants(t2, env, s)
    print(f"\nNormalization invariants for c•(A+B):")
    for name, ok in invariants.items():
        print(f"  {name}: {'✓' if ok else '✗'}")
