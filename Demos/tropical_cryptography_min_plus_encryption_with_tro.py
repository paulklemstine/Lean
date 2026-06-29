"""
Tropical (min-plus) cryptanalysis: numerical demonstrations.

This self-contained script demonstrates the results of the accompanying paper
"Tropical Spectral Cryptanalysis and Strong Divisibility":

  1. Tropical (min-plus) matrix algebra and matrix powering by repeated squaring.
  2. The eigenvalue side channel: res(A^{otimes t}, v)_i = t * lambda  (Theorem 4.1).
  3. The deterministic TDLP break: recover the secret exponent t (Corollary 4.2).
  4. The silent regime lambda = 0: no leak (Theorem 4.3).
  5. The strong-divisibility leak: (m+1)|(k+1) <=> c(m+1)|c(k+1)  (Theorem 5.3).
  6. The Diffie-Hellman shared-key eigenvalue factorization (Theorem 6.1).

All arithmetic is done over the integers/rationals so the demonstrations are exact.
Run:  python demo.py
"""

from __future__ import annotations

from math import gcd, inf
from typing import List, Sequence

Matrix = List[List[float]]
Vector = List[float]


# --------------------------------------------------------------------------- #
# 1. Tropical (min-plus) algebra
# --------------------------------------------------------------------------- #
def trop_mat_mul(A: Matrix, B: Matrix) -> Matrix:
    """Min-plus matrix product: (A (x) B)_{ij} = min_k (A_{ik} + B_{kj})."""
    n = len(A)
    return [[min(A[i][k] + B[k][j] for k in range(n)) for j in range(n)] for i in range(n)]


def trop_mat_vec(A: Matrix, v: Vector) -> Vector:
    """Min-plus matrix-vector product: (A (x) v)_i = min_k (A_{ik} + v_k)."""
    n = len(A)
    return [min(A[i][k] + v[k] for k in range(n)) for i in range(n)]


def trop_mat_pow(A: Matrix, k: int) -> Matrix:
    """Field-friendly tropical power: returns A^{(x)(k+1)} (the genuine (k+1)-fold product).

    Computed by repeated tropical squaring in O(n^3 log k) tropical operations.
    """
    if k < 0:
        raise ValueError("k must be >= 0")
    # genuine exponent t = k + 1
    t = k + 1
    result: Matrix | None = None
    base = [row[:] for row in A]
    while t > 0:
        if t & 1:
            result = base if result is None else trop_mat_mul(result, base)
        t >>= 1
        if t > 0:
            base = trop_mat_mul(base, base)
    assert result is not None
    return result


def trop_residual(A: Matrix, v: Vector) -> Vector:
    """Per-coordinate residual res(A, v)_i = (A (x) v)_i - v_i."""
    Av = trop_mat_vec(A, v)
    return [Av[i] - v[i] for i in range(len(v))]


# --------------------------------------------------------------------------- #
# 2. A matrix with a known integer tropical eigenpair (lambda, v)
# --------------------------------------------------------------------------- #
def eigen_matrix(v: Vector, lam: float) -> Matrix:
    """Construct A with eigenpair (lam, v): set A_{ij} = v_i - v_j + lam.

    Then (A (x) v)_i = min_j (A_{ij} + v_j) = min_j (v_i + lam) = v_i + lam,
    so (lam, v) is a tropical eigenpair exactly.
    """
    n = len(v)
    return [[v[i] - v[j] + lam for j in range(n)] for i in range(n)]


# --------------------------------------------------------------------------- #
# 3. The strong divisibility sequence tropEigSeq(c): a(t) = c * t
# --------------------------------------------------------------------------- #
def trop_eig_seq(c: int, t: int) -> int:
    """tropEigSeq(c) evaluated at genuine exponent t: a(t) = c * t."""
    return c * t


def is_strong_divisibility(c: int, bound: int = 12) -> bool:
    """Check gcd(a(m), a(n)) = a(gcd(m, n)) for a(t) = c*t over a finite range."""
    for m in range(bound):
        for n in range(bound):
            if gcd(trop_eig_seq(c, m), trop_eig_seq(c, n)) != trop_eig_seq(c, gcd(m, n)):
                return False
    return True


# --------------------------------------------------------------------------- #
# 4. The TDLP attack: recover secret exponent from the eigenvalue residual
# --------------------------------------------------------------------------- #
def recover_exponent(A: Matrix, B: Matrix, v: Vector, lam: float) -> int:
    """Recover the secret genuine exponent t from B = A^{(x)t}, given eigenpair (lam, v).

    Uses res(B, v)_0 = t * lam  =>  t = res / lam.  Requires lam != 0.
    """
    if lam == 0:
        raise ValueError("eigenvalue is 0: no leak (silent regime)")
    r = trop_residual(B, v)[0]
    return round(r / lam)


# --------------------------------------------------------------------------- #
# Demonstrations
# --------------------------------------------------------------------------- #
def demo() -> None:
    print("=" * 70)
    print("Tropical Spectral Cryptanalysis -- numerical demonstrations")
    print("=" * 70)

    v: Vector = [0.0, 2.0, 5.0, 1.0]
    lam = 3.0
    A = eigen_matrix(v, lam)

    print("\n[Setup] eigenvector v =", v, " eigenvalue lambda =", lam)
    print("Residual of A at v (should be lambda at every coordinate):")
    print("   ", trop_residual(A, v))

    print("\n[Theorem 4.1] res(A^{(x)t}, v)_i = t * lambda for genuine exponent t:")
    for k in range(6):
        B = trop_mat_pow(A, k)
        r = trop_residual(B, v)
        t = k + 1
        print(f"   t = {t}: residual = {r}  (expected {t * lam} everywhere)")

    print("\n[Corollary 4.2] The TDLP break -- recover a secret exponent:")
    secret_k = 41  # secret index; genuine exponent t = 42
    B = trop_mat_pow(A, secret_k)
    recovered = recover_exponent(A, B, v, lam)
    print(f"   secret genuine exponent t = {secret_k + 1}")
    print(f"   recovered from public (A, A^(x)t) and (lambda, v): t = {recovered}")
    assert recovered == secret_k + 1

    print("\n[Theorem 4.3] The silent regime lambda = 0 leaks nothing:")
    v0: Vector = [0.0, 1.0, 4.0]
    A0 = eigen_matrix(v0, 0.0)
    for k in range(4):
        B0 = trop_mat_pow(A0, k)
        print(f"   t = {k + 1}: residual = {trop_residual(B0, v0)} (identically 0)")

    print("\n[Theorem 5.1] tropEigSeq(c): a(t) = c*t is a strong divisibility sequence:")
    for c in (1, 3, 7):
        print(f"   c = {c}: gcd(a(m),a(n)) = a(gcd(m,n)) holds -> {is_strong_divisibility(c)}")

    print("\n[Theorem 5.3] Divisibility leak: (m+1)|(k+1) <=> c(m+1) | c(k+1):")
    c = 3
    for (m, k) in [(2, 8), (3, 8), (1, 11), (4, 9)]:
        secret_dvd = (m + 1) % (k + 1) == 0 or (k + 1) % (m + 1) == 0
        exp_dvd = (k + 1) % (m + 1) == 0
        eig_dvd = trop_eig_seq(c, k + 1) % trop_eig_seq(c, m + 1) == 0
        print(
            f"   (m+1)={m+1}, (k+1)={k+1}: (m+1)|(k+1)={exp_dvd}, "
            f"a(m+1)|a(k+1)={eig_dvd}  -> equivalent: {exp_dvd == eig_dvd}"
        )

    print("\n[Theorem 6.1] DH shared-key eigenvalue factorizes through public data:")
    print("   c * eig(shared) = eig(pub_a) * eig(pub_b)")
    for (a, b) in [(2, 3), (5, 4), (7, 6)]:
        lhs = c * trop_eig_seq(c, (a + 1) * (b + 1))
        rhs = trop_eig_seq(c, a + 1) * trop_eig_seq(c, b + 1)
        print(f"   a={a}, b={b}: lhs={lhs}, rhs={rhs}  -> equal: {lhs == rhs}")

    print("\nAll demonstrations completed successfully.")


if __name__ == "__main__":
    demo()
