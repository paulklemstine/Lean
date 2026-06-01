"""
Algorithms for intersection form analysis in 4-manifold topology.

Provides:
- Intersection form evaluation and classification
- E8 lattice computations
- Donaldson constraint checking
- Furuta bound verification
- SOS certificate generation via Cholesky
"""

from typing import List, Tuple, Optional
import numpy as np
from numpy.typing import NDArray


def e8_matrix() -> NDArray[np.int64]:
    """Return the E8 Cartan matrix."""
    return np.array([
        [ 2, -1,  0,  0,  0,  0,  0,  0],
        [-1,  2, -1,  0,  0,  0,  0,  0],
        [ 0, -1,  2, -1,  0,  0,  0, -1],
        [ 0,  0, -1,  2, -1,  0,  0,  0],
        [ 0,  0,  0, -1,  2, -1,  0,  0],
        [ 0,  0,  0,  0, -1,  2, -1,  0],
        [ 0,  0,  0,  0,  0, -1,  2,  0],
        [ 0,  0, -1,  0,  0,  0,  0,  2]
    ], dtype=np.int64)


def hyperbolic_matrix() -> NDArray[np.int64]:
    """Return the 2x2 hyperbolic form H."""
    return np.array([[0, 1], [1, 0]], dtype=np.int64)


def evaluate_form(Q: NDArray[np.int64], v: NDArray[np.int64]) -> int:
    """Evaluate Q(v, v) = v^T Q v."""
    return int(v @ Q @ v)


def is_unimodular(Q: NDArray[np.int64]) -> bool:
    """Check if Q has determinant ±1."""
    det = int(round(np.linalg.det(Q.astype(float))))
    return abs(det) == 1


def is_symmetric(Q: NDArray[np.int64]) -> bool:
    """Check if Q is symmetric."""
    return np.array_equal(Q, Q.T)


def is_even(Q: NDArray[np.int64], num_samples: int = 10000) -> bool:
    """Check if Q(v,v) is even for all integer vectors v (probabilistic)."""
    n = Q.shape[0]
    # Check all diagonal entries are even (necessary condition)
    for i in range(n):
        if Q[i, i] % 2 != 0:
            return False
    # The form is even iff all diagonal entries are even (for symmetric matrices)
    return True


def is_diagonal(Q: NDArray[np.int64]) -> bool:
    """Check if Q is a diagonal matrix."""
    n = Q.shape[0]
    for i in range(n):
        for j in range(n):
            if i != j and Q[i, j] != 0:
                return False
    return True


def is_positive_definite(Q: NDArray[np.int64]) -> bool:
    """Check positive definiteness via eigenvalues."""
    eigenvalues = np.linalg.eigvalsh(Q.astype(float))
    return bool(np.all(eigenvalues > 0))


def donaldson_check(Q: NDArray[np.int64]) -> Tuple[bool, str]:
    """
    Check Donaldson's diagonalizability constraint.
    Returns (passes, reason).
    A smooth 4-manifold with definite intersection form must have diagonal form.
    """
    if not is_unimodular(Q):
        return False, "Not unimodular"

    is_def = is_positive_definite(Q) or is_positive_definite(-Q)
    if not is_def:
        return True, "Indefinite — no Donaldson constraint"

    if is_diagonal(Q):
        return True, "Definite and diagonal — Donaldson constraint satisfied"

    return False, "Definite but not diagonal — CANNOT be smooth (Donaldson obstruction)"


def furuta_check(n: int, b_plus: int, b_minus: int) -> Tuple[bool, str]:
    """
    Check Furuta's 10/8 + 2 bound for spin manifolds.
    Requires: 8n >= 10|b+ - b-| + 16 when b+ != b-.
    """
    if b_plus + b_minus != n:
        return False, f"b+ + b- = {b_plus + b_minus} != {n}"
    if b_plus == b_minus:
        return True, "Signature zero — no Furuta constraint"

    d = abs(b_plus - b_minus)
    lhs = 8 * n
    rhs = 10 * d + 16
    if lhs >= rhs:
        return True, f"Furuta bound satisfied: 8*{n} = {lhs} >= {rhs} = 10*{d} + 16"
    else:
        return False, f"Furuta bound VIOLATED: 8*{n} = {lhs} < {rhs} = 10*{d} + 16"


def eleven_eighths_check(n: int, b_plus: int, b_minus: int) -> Tuple[bool, str]:
    """Check the 11/8 conjecture bound: 8n >= 11|b+ - b-|."""
    if b_plus + b_minus != n:
        return False, f"b+ + b- = {b_plus + b_minus} != {n}"
    d = abs(b_plus - b_minus)
    lhs = 8 * n
    rhs = 11 * d
    if lhs >= rhs:
        return True, f"11/8 bound satisfied: 8*{n} = {lhs} >= {rhs} = 11*{d}"
    else:
        return False, f"11/8 bound VIOLATED: 8*{n} = {lhs} < {rhs} = 11*{d}"


def cholesky_rational(Q: NDArray[np.int64]) -> Tuple[NDArray, NDArray]:
    """
    Compute the LDL^T factorization of Q using exact rational arithmetic
    (approximated with high-precision floats).
    Returns (L, D) where Q = L D L^T, L is lower triangular with 1s on diagonal,
    D is diagonal with the pivot values.
    """
    n = Q.shape[0]
    Q_float = Q.astype(np.float64)
    L = np.eye(n)
    D = np.zeros(n)

    for j in range(n):
        # Compute D[j]
        s = Q_float[j, j]
        for k in range(j):
            s -= L[j, k] ** 2 * D[k]
        D[j] = s

        # Compute L[i, j] for i > j
        for i in range(j + 1, n):
            s = Q_float[i, j]
            for k in range(j):
                s -= L[i, k] * L[j, k] * D[k]
            L[i, j] = s / D[j]

    return L, D


def direct_sum(Q1: NDArray[np.int64], Q2: NDArray[np.int64]) -> NDArray[np.int64]:
    """Compute the direct sum of two integer forms."""
    n1, n2 = Q1.shape[0], Q2.shape[0]
    result = np.zeros((n1 + n2, n1 + n2), dtype=np.int64)
    result[:n1, :n1] = Q1
    result[n1:, n1:] = Q2
    return result


def classify_form(Q: NDArray[np.int64]) -> dict:
    """
    Classify an intersection form completely.
    Returns a dictionary with all properties.
    """
    n = Q.shape[0]
    det_val = int(round(np.linalg.det(Q.astype(float))))
    eigenvalues = sorted(np.linalg.eigvalsh(Q.astype(float)))

    b_plus = sum(1 for e in eigenvalues if e > 0)
    b_minus = sum(1 for e in eigenvalues if e < 0)
    signature = b_plus - b_minus

    return {
        "rank": n,
        "determinant": det_val,
        "unimodular": abs(det_val) == 1,
        "symmetric": is_symmetric(Q),
        "even": is_even(Q),
        "diagonal": is_diagonal(Q),
        "positive_definite": all(e > 0 for e in eigenvalues),
        "negative_definite": all(e < 0 for e in eigenvalues),
        "definite": all(e > 0 for e in eigenvalues) or all(e < 0 for e in eigenvalues),
        "b_plus": b_plus,
        "b_minus": b_minus,
        "signature": signature,
        "eigenvalues": eigenvalues,
        "min_eigenvalue": eigenvalues[0],
        "max_eigenvalue": eigenvalues[-1],
        "donaldson": donaldson_check(Q),
        "furuta": furuta_check(n, b_plus, b_minus) if is_even(Q) else ("N/A", "Not spin"),
    }


def find_minimum_norm(Q: NDArray[np.int64], bound: int = 3) -> Tuple[int, Optional[NDArray]]:
    """
    Find the minimum nonzero value of Q(v,v) for integer vectors v with |v_i| <= bound.
    Returns (min_value, minimizing_vector).
    """
    n = Q.shape[0]
    min_val = None
    min_vec = None

    # Generate all vectors with components in [-bound, bound]
    def gen_vectors(dim, current):
        if dim == 0:
            yield np.array(current, dtype=np.int64)
            return
        for val in range(-bound, bound + 1):
            yield from gen_vectors(dim - 1, current + [val])

    for v in gen_vectors(n, []):
        if np.all(v == 0):
            continue
        val = evaluate_form(Q, v)
        if min_val is None or val < min_val:
            min_val = val
            min_vec = v.copy()

    return min_val, min_vec


if __name__ == "__main__":
    # Quick test
    E8 = e8_matrix()
    props = classify_form(E8)
    print(f"E8 properties: {props}")
