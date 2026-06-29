"""
Tropical Matrix Powers and Tropical Diffie-Hellman: Numerical Demonstrations
============================================================================

This self-contained script demonstrates the verified results on tropical
(min-plus) matrix powers:

    (A (X) B)(i,j) = min_k ( A(i,k) + B(k,j) )        tropical product
    tropMatPow(A, k) = A^{(X)(k+1)}                    field-friendly indexing
        tropMatPow(A, 0)   = A
        tropMatPow(A, k+1) = A (X) tropMatPow(A, k)

We verify, on random and structured examples:

  * tropMatVecMul_tropMatMul : (A (X) B) (X) v = A (X) (B (X) v)
  * tropMatVecMul_tropMatPow : A^{(X)(k+1)} (X) v = (A (X) .)^[k+1] v
  * tropMatMul_tropMatPow_add: A^{(X)(a+1)} (X) A^{(X)(b+1)} = A^{(X)(a+b+2)}
  * tropMatPow_tropMatPow    : (A^{(X)(a+1)})^{(X)(b+1)} = A^{(X)(ab+a+b+1)}
  * tropMatPow_comm          : (A^a)^b = (A^b)^a    (Diffie-Hellman correctness)

It also runs a toy tropical Diffie-Hellman key exchange and illustrates the
structural transparency (cycle-mean growth) that undermines the tropical
discrete logarithm problem.

Pure Python; no third-party dependencies.
"""

from __future__ import annotations

import math
import random
from typing import List, Sequence

Matrix = List[List[float]]
Vector = List[float]

INF = float("inf")


# --------------------------------------------------------------------------
# Core tropical (min-plus) operations
# --------------------------------------------------------------------------

def trop_mat_mul(A: Matrix, B: Matrix) -> Matrix:
    """Tropical (min-plus) matrix product: (A (X) B)(i,j) = min_k A(i,k)+B(k,j)."""
    n = len(A)
    return [
        [min(A[i][k] + B[k][j] for k in range(n)) for j in range(n)]
        for i in range(n)
    ]


def trop_mat_vec_mul(A: Matrix, v: Vector) -> Vector:
    """Tropical matrix-vector product: (A (X) v)(i) = min_k A(i,k)+v(k)."""
    n = len(A)
    return [min(A[i][k] + v[k] for k in range(n)) for i in range(n)]


def trop_mat_pow(A: Matrix, k: int) -> Matrix:
    """Field-friendly tropical power: tropMatPow(A,k) = A^{(X)(k+1)}.

    tropMatPow(A,0)=A and tropMatPow(A,k+1)=A (X) tropMatPow(A,k).
    """
    if k < 0:
        raise ValueError("k must be a natural number (>= 0)")
    result = [row[:] for row in A]
    for _ in range(k):
        result = trop_mat_mul(A, result)
    return result


def trop_mat_pow_fast(A: Matrix, k: int) -> Matrix:
    """Same value as trop_mat_pow via repeated tropical squaring: O(n^3 log k).

    Computes A^{(X)(k+1)} = A^{(X)e} with e = k+1 using binary exponentiation
    of the exponent e under the (associative) tropical product.
    """
    e = k + 1
    n = len(A)
    # 'result' accumulates the product; start as the tropical "neutral" by
    # folding in the first factor explicitly.
    base = [row[:] for row in A]
    result = None
    while e > 0:
        if e & 1:
            result = base if result is None else trop_mat_mul(result, base)
        e >>= 1
        if e > 0:
            base = trop_mat_mul(base, base)
    assert result is not None
    return result


# --------------------------------------------------------------------------
# Helpers
# --------------------------------------------------------------------------

def iterate(A: Matrix, v: Vector, times: int) -> Vector:
    """Apply (w -> A (X) w) `times` times to v."""
    w = v[:]
    for _ in range(times):
        w = trop_mat_vec_mul(A, w)
    return w


def random_matrix(n: int, lo: float = -5.0, hi: float = 5.0) -> Matrix:
    return [[round(random.uniform(lo, hi), 2) for _ in range(n)] for _ in range(n)]


def random_vector(n: int, lo: float = -5.0, hi: float = 5.0) -> Vector:
    return [round(random.uniform(lo, hi), 2) for _ in range(n)]


def mat_close(A: Matrix, B: Matrix, tol: float = 1e-9) -> bool:
    return all(
        abs(A[i][j] - B[i][j]) <= tol
        for i in range(len(A))
        for j in range(len(A))
    )


def vec_close(a: Vector, b: Vector, tol: float = 1e-9) -> bool:
    return all(abs(x - y) <= tol for x, y in zip(a, b))


def show_matrix(A: Matrix, label: str = "") -> None:
    if label:
        print(f"  {label}:")
    for row in A:
        print("    [" + "  ".join(f"{x:7.2f}" for x in row) + "]")


# --------------------------------------------------------------------------
# Demonstrations of the verified theorems
# --------------------------------------------------------------------------

def demo_matvec_associativity(trials: int = 5, n: int = 4) -> None:
    print("=" * 70)
    print("Theorem tropMatVecMul_tropMatMul:  (A (X) B) (X) v = A (X) (B (X) v)")
    print("=" * 70)
    for t in range(trials):
        A, B = random_matrix(n), random_matrix(n)
        v = random_vector(n)
        lhs = trop_mat_vec_mul(trop_mat_mul(A, B), v)
        rhs = trop_mat_vec_mul(A, trop_mat_vec_mul(B, v))
        ok = vec_close(lhs, rhs)
        print(f"  trial {t + 1}: equal = {ok}")
        assert ok
    print("  -> matrix-vector associativity holds.\n")


def demo_power_is_iteration(n: int = 4, kmax: int = 6) -> None:
    print("=" * 70)
    print("Theorem tropMatVecMul_tropMatPow:  A^{(X)(k+1)} (X) v = (A (X) .)^[k+1] v")
    print("=" * 70)
    A, v = random_matrix(n), random_vector(n)
    for k in range(kmax + 1):
        lhs = trop_mat_vec_mul(trop_mat_pow(A, k), v)
        rhs = iterate(A, v, k + 1)
        ok = vec_close(lhs, rhs)
        print(f"  k={k}: power-on-vector == {k + 1} iterations: {ok}")
        assert ok
    print("  -> a tropical power is iterated min-plus dynamics.\n")


def demo_power_additivity(n: int = 4, amax: int = 4, bmax: int = 4) -> None:
    print("=" * 70)
    print("Theorem tropMatMul_tropMatPow_add:  A^{(X)(a+1)} (X) A^{(X)(b+1)} = A^{(X)(a+b+2)}")
    print("=" * 70)
    A = random_matrix(n)
    for a in range(amax + 1):
        for b in range(bmax + 1):
            lhs = trop_mat_mul(trop_mat_pow(A, a), trop_mat_pow(A, b))
            rhs = trop_mat_pow(A, a + b + 1)
            assert mat_close(lhs, rhs)
    print(f"  verified for all 0<=a<={amax}, 0<=b<={bmax}: exponents add.\n")


def demo_power_of_power(n: int = 4, amax: int = 4, bmax: int = 4) -> None:
    print("=" * 70)
    print("Theorem tropMatPow_tropMatPow:  (A^{(X)(a+1)})^{(X)(b+1)} = A^{(X)(ab+a+b+1)}")
    print("=" * 70)
    A = random_matrix(n)
    for a in range(amax + 1):
        for b in range(bmax + 1):
            lhs = trop_mat_pow(trop_mat_pow(A, a), b)
            rhs = trop_mat_pow(A, a * b + a + b)
            assert mat_close(lhs, rhs)
    print(f"  verified for all 0<=a<={amax}, 0<=b<={bmax}: exponents multiply.\n")


def demo_dh_correctness(n: int = 5, amax: int = 6, bmax: int = 6) -> None:
    print("=" * 70)
    print("Theorem tropMatPow_comm (Diffie-Hellman correctness): (A^a)^b = (A^b)^a")
    print("=" * 70)
    A = random_matrix(n)
    for a in range(amax + 1):
        for b in range(bmax + 1):
            ab = trop_mat_pow(trop_mat_pow(A, a), b)
            ba = trop_mat_pow(trop_mat_pow(A, b), a)
            assert mat_close(ab, ba)
    print(f"  verified for all 0<=a<={amax}, 0<=b<={bmax}: both parties agree.\n")


def demo_full_key_exchange(n: int = 5) -> None:
    print("=" * 70)
    print("Toy tropical Diffie-Hellman key exchange")
    print("=" * 70)
    A = random_matrix(n)
    a_secret = random.randint(3, 12)   # Alice's private exponent
    b_secret = random.randint(3, 12)   # Bob's private exponent

    P_A = trop_mat_pow(A, a_secret)    # Alice publishes A^{(X)(a+1)}
    P_B = trop_mat_pow(A, b_secret)    # Bob publishes   A^{(X)(b+1)}

    key_alice = trop_mat_pow(P_B, a_secret)   # Alice: (A^b)^a
    key_bob = trop_mat_pow(P_A, b_secret)     # Bob:   (A^a)^b

    print(f"  Alice secret a = {a_secret},  Bob secret b = {b_secret}")
    print(f"  shared exponent (a+1)(b+1) = {(a_secret + 1) * (b_secret + 1)}")
    print(f"  keys agree: {mat_close(key_alice, key_bob)}")
    show_matrix(key_alice, "shared key K = A^{(X)((a+1)(b+1))}")
    # fast exponentiation gives the identical key
    key_fast = trop_mat_pow_fast(A, (a_secret + 1) * (b_secret + 1) - 1)
    print(f"  fast-squaring key matches: {mat_close(key_alice, key_fast)}\n")


def demo_cycle_mean_transparency(n: int = 5) -> None:
    """Illustrate why the tropical discrete log leaks: A^{(X)m} grows linearly
    at the minimum cycle mean rate, making the exponent readable."""
    print("=" * 70)
    print("Structural transparency: A^{(X)m} grows at the minimum cycle mean")
    print("=" * 70)
    A = random_matrix(n, lo=0.5, hi=4.0)  # positive weights -> finite cycle means
    # minimum cycle mean over cycles up to length n (Karp-style bound)
    best = INF
    for length in range(1, n + 1):
        P = trop_mat_pow(A, length - 1)  # paths of exactly `length` edges
        best = min(best, min(P[i][i] / length for i in range(n)))
    print(f"  estimated minimum cycle mean ~ {best:.4f}")
    prev_min = None
    print("  per-step decrease of min entry of A^{(X)m} (should approach cycle mean):")
    for m in range(1, 9):
        P = trop_mat_pow(A, m - 1)
        cur = min(min(row) for row in P)
        if prev_min is not None:
            print(f"    m={m}: delta(min entry) = {cur - prev_min:.4f}")
        prev_min = cur
    print("  -> the predictable linear growth rate exposes the secret exponent.\n")


def main() -> None:
    random.seed(2026)
    demo_matvec_associativity()
    demo_power_is_iteration()
    demo_power_additivity()
    demo_power_of_power()
    demo_dh_correctness()
    demo_full_key_exchange()
    demo_cycle_mean_transparency()
    print("All verified tropical-power identities confirmed numerically.")


if __name__ == "__main__":
    main()
