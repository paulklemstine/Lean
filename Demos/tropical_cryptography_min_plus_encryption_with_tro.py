"""
Tropical Cryptography: Min-Plus Matrix Powers, Shortest Walks, and the
Eigenvalue Attack on the Tropical Discrete Logarithm Problem.

This self-contained script demonstrates the two central results:

  1. Walk-sum identity (tropical case): the (i, j) entry of the k-th tropical
     matrix power equals the minimum total weight of a k-step walk from i to j.
     We verify this by comparing the algebraic matrix power against a brute-force
     enumeration of all length-k walks.

  2. Additivity of tropical eigenvalues under powering: lambda(A^{otimes k})
     = k * lambda(A). We verify it numerically via the minimum cycle mean and
     then run the eigenvalue attack that recovers the secret exponent k from
     (A, A^{otimes k}), thereby breaking the tropical Diffie-Hellman scheme.

Tropical arithmetic:  x (+) y = min(x, y),   x (*) y = x + y,
with tropical zero = +infinity and tropical one = 0.

Run:  python demo.py
"""

from __future__ import annotations

import itertools
import math
from fractions import Fraction
from typing import List, Sequence, Tuple

INF: float = math.inf
Matrix = List[List[float]]
Vector = List[float]


# --------------------------------------------------------------------------- #
# Core tropical linear algebra                                                 #
# --------------------------------------------------------------------------- #
def trop_matmul(a: Matrix, b: Matrix) -> Matrix:
    """Tropical (min-plus) matrix product: (A (*) B)_{ij} = min_l (A_il + B_lj)."""
    n, m, p = len(a), len(b), len(b[0])
    out: Matrix = [[INF] * p for _ in range(n)]
    for i in range(n):
        for j in range(p):
            best = INF
            for l in range(m):
                cand = a[i][l] + b[l][j]
                if cand < best:
                    best = cand
            out[i][j] = best
    return out


def trop_identity(n: int) -> Matrix:
    """Tropical identity: 0 on the diagonal, +infinity off-diagonal."""
    return [[0.0 if i == j else INF for j in range(n)] for i in range(n)]


def trop_matpow(a: Matrix, k: int) -> Matrix:
    """Tropical k-th power A^{otimes k} by repeated squaring: O(n^3 log k)."""
    n = len(a)
    result = trop_identity(n)
    base = [row[:] for row in a]
    e = k
    while e > 0:
        if e & 1:
            result = trop_matmul(result, base)
        base = trop_matmul(base, base)
        e >>= 1
    return result


def trop_matvec(a: Matrix, v: Vector) -> Vector:
    """Tropical matrix-vector product: (A (*) v)_i = min_j (A_ij + v_j)."""
    n, m = len(a), len(v)
    return [min(a[i][j] + v[j] for j in range(m)) for i in range(n)]


# --------------------------------------------------------------------------- #
# 1. Walk-sum identity (brute-force verification)                             #
# --------------------------------------------------------------------------- #
def shortest_kstep_walk(a: Matrix, k: int, i: int, j: int) -> float:
    """Minimum total weight over all length-k walks i -> j, by brute force."""
    n = len(a)
    best = INF
    for interior in itertools.product(range(n), repeat=max(k - 1, 0)):
        path: Tuple[int, ...] = (i,) + interior + (j,) if k >= 1 else (i,)
        if k == 0:
            weight = 0.0 if i == j else INF
        else:
            weight = sum(a[path[t]][path[t + 1]] for t in range(k))
        best = min(best, weight)
    return best


def verify_walk_sum_identity(a: Matrix, k: int) -> bool:
    """Check (A^{otimes k})_{ij} == shortest k-step walk weight for all i, j."""
    n = len(a)
    powered = trop_matpow(a, k)
    ok = True
    for i in range(n):
        for j in range(n):
            algebraic = powered[i][j]
            combinatorial = shortest_kstep_walk(a, k, i, j)
            if not (algebraic == combinatorial or
                    (math.isinf(algebraic) and math.isinf(combinatorial))):
                ok = False
    return ok


# --------------------------------------------------------------------------- #
# 2. Minimum cycle mean (the tropical eigenvalue) via Karp's algorithm        #
# --------------------------------------------------------------------------- #
def min_cycle_mean(a: Matrix) -> Fraction | None:
    """
    Karp's minimum cycle mean = the tropical eigenvalue lambda(A).
    Returns None if the graph has no cycle reachable from the source.
    """
    n = len(a)
    if n == 0:
        return None
    # d[t][v] = min weight of a length-t walk from source 0 to v.
    NEG = None
    d: List[List[Fraction | None]] = [[NEG] * n for _ in range(n + 1)]
    d[0][0] = Fraction(0)
    for t in range(1, n + 1):
        for v in range(n):
            best: Fraction | None = None
            for u in range(n):
                if d[t - 1][u] is not None and not math.isinf(a[u][v]):
                    cand = d[t - 1][u] + Fraction(int(a[u][v]))
                    if best is None or cand < best:
                        best = cand
            d[t][v] = best
    lam: Fraction | None = None
    for v in range(n):
        if d[n][v] is None:
            continue
        worst: Fraction | None = None
        for t in range(n):
            if d[t][v] is not None:
                val = Fraction(d[n][v] - d[t][v], n - t)
                if worst is None or val > worst:
                    worst = val
        if worst is not None and (lam is None or worst < lam):
            lam = worst
    return lam


# --------------------------------------------------------------------------- #
# 3. The eigenvalue attack on the tropical discrete logarithm problem         #
# --------------------------------------------------------------------------- #
def eigenvalue_attack(a: Matrix, b: Matrix) -> int | None:
    """
    Recover k from (A, B = A^{otimes k}) using lambda(B) = k * lambda(A).
    Returns None if lambda(A) is zero/undefined (attack does not apply).
    """
    lam_a = min_cycle_mean(a)
    lam_b = min_cycle_mean(b)
    if lam_a is None or lam_a == 0 or lam_b is None:
        return None
    ratio = lam_b / lam_a
    if ratio.denominator == 1:
        return int(ratio)
    return None


# --------------------------------------------------------------------------- #
# Demonstration                                                                #
# --------------------------------------------------------------------------- #
def main() -> None:
    print("=" * 70)
    print("Tropical Cryptography Demonstration")
    print("=" * 70)

    A: Matrix = [
        [4.0, 1.0, INF],
        [INF, 3.0, 2.0],
        [1.0, INF, 5.0],
    ]

    print("\nPublic tropical matrix A (INF = no edge):")
    for row in A:
        print("  ", ["inf" if math.isinf(x) else int(x) for x in row])

    # --- Result 1: walk-sum / shortest-walk identity -----------------------
    print("\n[1] Walk-sum identity  (A^{otimes k})_{ij} = shortest k-step walk")
    for k in range(0, 5):
        ok = verify_walk_sum_identity(A, k)
        print(f"    k = {k}: matrix power matches brute-force shortest walk -> {ok}")

    # --- Result 2: eigenvalue additivity -----------------------------------
    print("\n[2] Tropical eigenvalue additivity  lambda(A^{otimes k}) = k*lambda(A)")
    lam_A = min_cycle_mean(A)
    print(f"    lambda(A) = {lam_A}")
    for k in range(1, 6):
        lam_Ak = min_cycle_mean(trop_matpow(A, k))
        expected = None if lam_A is None else k * lam_A
        print(f"    k = {k}: lambda(A^k) = {lam_Ak}, k*lambda(A) = {expected}, "
              f"match -> {lam_Ak == expected}")

    # --- Result 3: breaking tropical Diffie-Hellman ------------------------
    print("\n[3] Eigenvalue attack on the tropical discrete logarithm problem")
    for secret_k in (7, 13, 100, 1000):
        B = trop_matpow(A, secret_k)
        recovered = eigenvalue_attack(A, B)
        status = "BROKEN" if recovered == secret_k else "failed"
        print(f"    secret k = {secret_k:5d}  ->  recovered k = {recovered}  [{status}]")

    print("\nConclusion: the tropical eigenvalue leaks the secret exponent,")
    print("so raw min-plus matrix powering is not a one-way function.")


if __name__ == "__main__":
    main()
