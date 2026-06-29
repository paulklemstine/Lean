"""
demo.py — Numerical demonstrations of the algebraic kernel of the
Eastin–Knill no-go theorem.

This script is fully self-contained (only requires NumPy). It illustrates,
with concrete complex matrices, every headline result of the formalized
development:

  * A *code* is a Hermitian projector  P  (P = P^*,  P^2 = P).
  * An operator A is *detectable with scalar c* when  P A P = c P.
  * Detectable operators are closed under scalar multiplication, addition,
    and finite sums; the detection scalars transform linearly.
  * A *transversal generator*  G = sum_i A_i  of detectable single-site
    terms compresses to a single scalar:  P G P = (sum_i c_i) P.
  * Centrality: if A is detectable, then its logical compression
    L(A) = P A P commutes with L(B) = P B P for *every* operator B.
  * Boundary: with the trivial code  P = I, the compression is the
    identity map, and the Pauli operators X and Z fail to commute, so
    the logical algebra is the full non-commutative matrix algebra.

Run with:  python demo.py
"""

from __future__ import annotations

import numpy as np

Matrix = np.ndarray
TOL: float = 1e-10


# --------------------------------------------------------------------------
# Core algebraic primitives
# --------------------------------------------------------------------------
def is_hermitian(P: Matrix) -> bool:
    """Return True iff P equals its conjugate transpose."""
    return bool(np.allclose(P, P.conj().T, atol=TOL))


def is_idempotent(P: Matrix) -> bool:
    """Return True iff P @ P == P (P is a projector when also Hermitian)."""
    return bool(np.allclose(P @ P, P, atol=TOL))


def is_code(P: Matrix) -> bool:
    """A code projector is Hermitian and idempotent."""
    return is_hermitian(P) and is_idempotent(P)


def logical(P: Matrix, A: Matrix) -> Matrix:
    """Logical compression  L(A) = P A P : the operator as seen by the code."""
    return P @ A @ P


def detection_scalar(P: Matrix, A: Matrix) -> complex | None:
    """
    If A is detectable on the code P, return the unique scalar c with
    P A P = c P; otherwise return None.
    """
    PAP = logical(P, A)
    # Find a nonzero entry of P to read off the candidate scalar.
    idx = np.argwhere(np.abs(P) > TOL)
    if idx.size == 0:
        return 0.0 + 0.0j  # P = 0: everything compresses to 0.
    i, j = idx[0]
    c = PAP[i, j] / P[i, j]
    if np.allclose(PAP, c * P, atol=TOL):
        return complex(c)
    return None


def is_detectable(P: Matrix, A: Matrix, c: complex) -> bool:
    """Check the Knill–Laflamme compression condition  P A P = c P."""
    return bool(np.allclose(logical(P, A), c * P, atol=TOL))


def commutator(X: Matrix, Y: Matrix) -> Matrix:
    """The matrix commutator  [X, Y] = X Y - Y X."""
    return X @ Y - Y @ X


# --------------------------------------------------------------------------
# Standard gates / projectors
# --------------------------------------------------------------------------
I2: Matrix = np.eye(2, dtype=complex)
X: Matrix = np.array([[0, 1], [1, 0]], dtype=complex)
Y: Matrix = np.array([[0, -1j], [1j, 0]], dtype=complex)
Z: Matrix = np.array([[1, 0], [0, -1]], dtype=complex)


def basis_code(dim: int, k: int) -> Matrix:
    """
    The rank-1 'basisCode': the projector onto the k-th standard basis
    vector |k><k|.  Every diagonal operator is detectable on this code,
    with detection scalar equal to its k-th diagonal entry.
    """
    P = np.zeros((dim, dim), dtype=complex)
    P[k, k] = 1.0
    return P


def random_code(dim: int, rank: int, seed: int = 0) -> Matrix:
    """A random Hermitian projector of the requested rank (an orthonormal
    column basis Q gives  P = Q Q^*)."""
    rng = np.random.default_rng(seed)
    M = rng.standard_normal((dim, rank)) + 1j * rng.standard_normal((dim, rank))
    Q, _ = np.linalg.qr(M)
    return Q @ Q.conj().T


# --------------------------------------------------------------------------
# Demonstrations
# --------------------------------------------------------------------------
def demo_closure() -> None:
    print("=" * 68)
    print("1.  CLOSURE OF DETECTABILITY (smul / add / sum)")
    print("=" * 68)
    P = basis_code(3, 0)  # |0><0|
    # Diagonal operators are detectable on |0><0|; scalar = top-left entry.
    A = np.diag([2.0 + 0j, 5.0, -1.0])
    B = np.diag([7.0 + 0j, 0.0, 3.0])
    a, b = detection_scalar(P, A), detection_scalar(P, B)
    print(f"  detect(A) = {a:.1f}   detect(B) = {b:.1f}")

    d = 3.0 + 1.0j
    print(f"  scalar-mul:  detect(d*A) = {detection_scalar(P, d * A):.1f}"
          f"  ==  d*detect(A) = {d * a:.1f}  -> "
          f"{np.isclose(detection_scalar(P, d * A), d * a)}")
    print(f"  additivity:  detect(A+B) = {detection_scalar(P, A + B):.1f}"
          f"  ==  a+b = {a + b:.1f}  -> "
          f"{np.isclose(detection_scalar(P, A + B), a + b)}")

    terms = [np.diag([float(i) + 1, 0.0, 0.0]) for i in range(5)]
    total = sum(terms, np.zeros((3, 3), dtype=complex))
    scal_sum = sum(detection_scalar(P, t) for t in terms)
    print(f"  finite sum:  detect(sum) = {detection_scalar(P, total):.1f}"
          f"  ==  sum c_i = {scal_sum:.1f}  -> "
          f"{np.isclose(detection_scalar(P, total), scal_sum)}")
    print()


def demo_transversal_scalar() -> None:
    print("=" * 68)
    print("2.  TRANSVERSAL SCALAR COMPRESSION   P G P = (sum c_i) P")
    print("=" * 68)
    P = basis_code(4, 1)  # |1><1|
    # A transversal generator of 4 diagonal single-site terms.
    scalars = [1.5, -2.0, 0.5, 4.0]
    terms = []
    rng = np.random.default_rng(7)
    for c in scalars:
        diag = rng.standard_normal(4) + 1j * rng.standard_normal(4)
        diag[1] = c  # the (1,1) entry is what the rank-1 code "sees"
        terms.append(np.diag(diag))
    G = sum(terms, np.zeros((4, 4), dtype=complex))
    expected = sum(scalars)
    PGP = logical(P, G)
    print(f"  individual detection scalars : {scalars}")
    print(f"  predicted total scalar       : {expected:.2f}")
    print(f"  measured  P G P = c P with c : {detection_scalar(P, G):.2f}")
    print(f"  identity P G P = (sum c) P holds -> "
          f"{np.allclose(PGP, expected * P, atol=TOL)}")
    print()


def demo_centrality() -> None:
    print("=" * 68)
    print("3.  CENTRALITY   L(A) L(B) = L(B) L(A)   for detectable A")
    print("=" * 68)
    P = random_code(5, 3, seed=42)
    assert is_code(P)
    # A detectable operator: take A = 3.7 * I, which compresses to 3.7 P.
    c = 3.7 + 0.0j
    A = c * np.eye(5, dtype=complex)
    print(f"  A = {c.real} * I is detectable with scalar c = {c.real}")
    print(f"  is_detectable(P, A, c) -> {is_detectable(P, A, c)}")

    rng = np.random.default_rng(11)
    max_norm = 0.0
    for _ in range(1000):
        B = rng.standard_normal((5, 5)) + 1j * rng.standard_normal((5, 5))
        comm = commutator(logical(P, A), logical(P, B))
        max_norm = max(max_norm, float(np.linalg.norm(comm)))
    print(f"  over 1000 random B:  max || [L(A), L(B)] ||  =  {max_norm:.2e}")
    print(f"  L(A) is central  -> {max_norm < 1e-8}")
    print()


def demo_boundary() -> None:
    print("=" * 68)
    print("4.  BOUNDARY:  WITHOUT DETECTION THE LOGICAL ALGEBRA IS FULL")
    print("=" * 68)
    P = I2  # trivial distance-1 code: P = I, compression is the identity map.
    print("  Trivial code P = I  (every operator compresses to itself).")
    print(f"  L(X) == X -> {np.allclose(logical(P, X), X)}")
    print(f"  L(Z) == Z -> {np.allclose(logical(P, Z), Z)}")
    comm = commutator(logical(P, X), logical(P, Z))
    print("  Pauli X and Z do NOT commute on the trivial code:")
    print(f"    || [L(X), L(Z)] || = {np.linalg.norm(comm):.3f}  (nonzero)")
    print("  => detectability is genuinely necessary for centrality.")
    print()


def demo_basiscode() -> None:
    print("=" * 68)
    print("5.  basisCode / diagonal_detectable  (non-vacuity witness)")
    print("=" * 68)
    dim, k = 4, 2
    P = basis_code(dim, k)
    print(f"  Code = |{k}><{k}| on C^{dim}.")
    ok = True
    rng = np.random.default_rng(3)
    for _ in range(50):
        diag = rng.standard_normal(dim) + 1j * rng.standard_normal(dim)
        D = np.diag(diag)
        ok &= is_detectable(P, D, diag[k])
    print(f"  Every diagonal operator D is detectable with scalar D[{k},{k}].")
    print(f"  verified on 50 random diagonal operators -> {ok}")
    print()


def main() -> None:
    print()
    print("ALGEBRAIC KERNEL OF THE EASTIN–KNILL NO-GO THEOREM")
    print("Numerical demonstrations\n")
    demo_closure()
    demo_transversal_scalar()
    demo_centrality()
    demo_boundary()
    demo_basiscode()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
