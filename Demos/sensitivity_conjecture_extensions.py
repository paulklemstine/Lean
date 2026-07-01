"""
Numerical demonstrations for:

    The Spectral Core of the Sensitivity Conjecture
    Signed Adjacency Matrices of the Hypercube

We build the recursively defined signed adjacency matrix A_n of the
n-dimensional hypercube Q_n,

    A_0 = (0),    A_{n+1} = [[ A_n,  I ],
                            [  I , -A_n]],

and numerically verify the structural package proved in the paper:

    * A_n^2 = n I              (the spectral identity)
    * A_n^T = A_n              (symmetry)
    * trace(A_n) = 0           (zero trace)
    * entries in {-1, 0, 1}    (genuine signed adjacency matrix)
    * each row has n nonzeros  (n-regularity)
    * every eigenvalue mu has  mu^2 = n, i.e. |mu| = sqrt(n)
    * (det A_n)^2 = n^(2^n)     (squared determinant)
    * A_n^{-1} = (1/n) A_n      (inverse, for n >= 1)

It also verifies n-regularity in the independent symmetric-difference
model of Q_n, confirming both encodings agree.

Requires only the Python standard library plus NumPy.
"""

from __future__ import annotations

import itertools
from typing import List, Tuple

import numpy as np


# --------------------------------------------------------------------------
# Construction of the signed adjacency matrix A_n
# --------------------------------------------------------------------------
def signed_adjacency(n: int) -> np.ndarray:
    """Return the 2^n x 2^n signed adjacency matrix A_n of Q_n.

    Built by the block recursion
        A_0 = (0),  A_{n+1} = [[A_n, I], [I, -A_n]].
    """
    if n == 0:
        return np.zeros((1, 1), dtype=np.int64)
    a = signed_adjacency(n - 1)
    size = a.shape[0]
    identity = np.eye(size, dtype=np.int64)
    top = np.hstack([a, identity])
    bot = np.hstack([identity, -a])
    return np.vstack([top, bot])


# --------------------------------------------------------------------------
# Structural checks (each corresponds to a theorem in the paper)
# --------------------------------------------------------------------------
def check_spectral_identity(a: np.ndarray, n: int) -> bool:
    """A_n^2 = n I."""
    size = a.shape[0]
    return np.array_equal(a @ a, n * np.eye(size, dtype=np.int64))


def check_symmetric(a: np.ndarray) -> bool:
    """A_n^T = A_n."""
    return np.array_equal(a.T, a)


def check_zero_trace(a: np.ndarray) -> bool:
    """trace(A_n) = 0."""
    return int(np.trace(a)) == 0


def check_entries(a: np.ndarray) -> bool:
    """Every entry lies in {-1, 0, 1}."""
    return bool(np.all(np.isin(a, (-1, 0, 1))))


def check_regularity(a: np.ndarray, n: int) -> bool:
    """Each row has exactly n nonzero entries."""
    nonzeros_per_row = np.count_nonzero(a, axis=1)
    return bool(np.all(nonzeros_per_row == n))


def check_spectral_gap(a: np.ndarray, n: int, tol: float = 1e-9) -> Tuple[bool, np.ndarray]:
    """Every eigenvalue mu satisfies mu^2 = n (so |mu| = sqrt(n))."""
    eig = np.linalg.eigvalsh(a.astype(float))
    ok = bool(np.all(np.abs(eig ** 2 - n) < tol * max(1, n)))
    return ok, eig


def check_squared_determinant(a: np.ndarray, n: int, tol: float = 1e-6) -> bool:
    """(det A_n)^2 = n^(2^n)."""
    size = a.shape[0]  # 2^n
    if n == 0:
        return abs(np.linalg.det(a.astype(float))) < tol  # det = 0, n^1 = 0
    det = np.linalg.det(a.astype(float))
    expected = float(n) ** size
    return abs(det * det - expected) <= tol * expected


def check_inverse(a: np.ndarray, n: int, tol: float = 1e-9) -> bool:
    """For n >= 1, A_n^{-1} = (1/n) A_n, i.e. A_n * (1/n) A_n = I."""
    if n < 1:
        return True
    size = a.shape[0]
    prod = a.astype(float) @ (a.astype(float) / n)
    return bool(np.allclose(prod, np.eye(size), atol=tol))


# --------------------------------------------------------------------------
# Independent combinatorial model: symmetric-difference hypercube
# --------------------------------------------------------------------------
def hypercube_degrees(n: int) -> List[int]:
    """Degree of every vertex of Q_n in the symmetric-difference model.

    A vertex is a subset S of {0,...,n-1} (encoded as a frozenset).
    Two vertices are adjacent iff their symmetric difference has size 1.
    Returns the list of vertex degrees.
    """
    vertices = [frozenset(s)
                for r in range(n + 1)
                for s in itertools.combinations(range(n), r)]
    degrees: List[int] = []
    for v in vertices:
        deg = sum(1 for w in vertices if len(v ^ w) == 1)
        degrees.append(deg)
    return degrees


# --------------------------------------------------------------------------
# Driver
# --------------------------------------------------------------------------
def demonstrate(max_n: int = 6) -> None:
    print("=" * 72)
    print(" Signed adjacency matrices A_n of the hypercube Q_n")
    print("=" * 72)
    for n in range(0, max_n + 1):
        a = signed_adjacency(n)
        gap_ok, eig = check_spectral_gap(a, n)
        results = {
            "A_n^2 = n I": check_spectral_identity(a, n),
            "symmetric": check_symmetric(a),
            "zero trace": check_zero_trace(a),
            "entries in {-1,0,1}": check_entries(a),
            "n-regular (matrix)": check_regularity(a, n),
            "|eig| = sqrt(n)": gap_ok,
            "(det)^2 = n^(2^n)": check_squared_determinant(a, n),
            "inverse = (1/n)A_n": check_inverse(a, n),
        }
        status = "  ".join(f"{k}: {'OK' if v else 'FAIL'}" for k, v in results.items())
        print(f"\nn = {n}   (size {a.shape[0]}x{a.shape[0]})")
        print("  " + status)
        distinct = sorted({round(float(x), 6) for x in eig})
        print(f"  distinct eigenvalues: {distinct}   (sqrt(n) = {np.sqrt(n):.6f})")

    print("\n" + "=" * 72)
    print(" Combinatorial check: n-regularity in the symmetric-difference model")
    print("=" * 72)
    for n in range(0, max_n + 1):
        degs = hypercube_degrees(n)
        all_n = all(d == n for d in degs)
        print(f"  n = {n}: all {len(degs)} vertices have degree {n}? "
              f"{'YES' if all_n else 'NO'}")

    # Show A_2 explicitly, the smallest interesting case.
    print("\n" + "=" * 72)
    print(" Explicit A_2 and its square")
    print("=" * 72)
    a2 = signed_adjacency(2)
    print("A_2 =")
    print(a2)
    print("A_2^2 =")
    print(a2 @ a2, "  (= 2 * I)")


if __name__ == "__main__":
    demonstrate(max_n=6)
