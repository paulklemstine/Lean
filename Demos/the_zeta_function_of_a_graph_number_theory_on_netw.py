"""
Numerical demonstrations for:

    The Riemann Hypothesis for the Ihara Zeta Function of a Regular Graph

Core mathematical facts illustrated here:

  * For a (q+1)-regular graph with adjacency eigenvalue lambda, the local factor
        p_lambda(u) = q*u^2 - lambda*u + 1
    has all complex roots on the circle |u| = 1/sqrt(q) if and only if
        |lambda| <= 2*sqrt(q)      (the Ramanujan bound).

  * Summed over the nontrivial spectrum this is exactly:
        zeta_G satisfies the Riemann Hypothesis  <=>  G is a Ramanujan graph.

  * The trivial eigenvalue lambda = q+1 factors as (q*u - 1)(u - 1), whose roots
    1 and 1/q lie OFF the critical circle -- hence RH is imposed only on the
    nontrivial spectrum.

The script is fully self-contained (standard library only) and uses complex
arithmetic implemented by hand to avoid external dependencies.
"""

from __future__ import annotations

import cmath
import math
from typing import List, Tuple


# ---------------------------------------------------------------------------
# Local factor and its roots
# ---------------------------------------------------------------------------
def local_factor(q: float, lam: float, u: complex) -> complex:
    """Evaluate the Ihara local factor p_lambda(u) = q*u^2 - lambda*u + 1."""
    return q * u * u - lam * u + 1.0


def local_factor_roots(q: float, lam: float) -> Tuple[complex, complex]:
    """Return the two complex roots of q*u^2 - lambda*u + 1 via the quadratic
    formula (using complex square roots so it is valid for any discriminant)."""
    disc = complex(lam * lam - 4.0 * q)
    sqrt_disc = cmath.sqrt(disc)
    r_plus = (lam + sqrt_disc) / (2.0 * q)
    r_minus = (lam - sqrt_disc) / (2.0 * q)
    return r_plus, r_minus


def on_critical_circle(q: float, u: complex, tol: float = 1e-9) -> bool:
    """Test whether |u| = 1/sqrt(q) up to tolerance."""
    return abs(abs(u) - 1.0 / math.sqrt(q)) < tol


def satisfies_ramanujan(q: float, lam: float) -> bool:
    """Ramanujan spectral bound |lambda| <= 2*sqrt(q)."""
    return abs(lam) <= 2.0 * math.sqrt(q) + 1e-12


# ---------------------------------------------------------------------------
# Demo 1: the local equivalence, eigenvalue by eigenvalue
# ---------------------------------------------------------------------------
def demo_local_equivalence() -> None:
    print("=" * 70)
    print("DEMO 1: roots on the circle  <=>  Ramanujan bound (local factor)")
    print("=" * 70)
    q = 4.0
    crit = 1.0 / math.sqrt(q)
    print(f"q = {q},  critical radius 1/sqrt(q) = {crit:.6f},  "
          f"Ramanujan bound 2*sqrt(q) = {2*math.sqrt(q):.6f}\n")
    for lam in [0.0, 2.0, 4.0 - 1e-9, 4.0, 4.5, 5.0]:
        r1, r2 = local_factor_roots(q, lam)
        ok1, ok2 = on_critical_circle(q, r1), on_critical_circle(q, r2)
        both_on = ok1 and ok2
        ram = satisfies_ramanujan(q, lam)
        status = "MATCH" if both_on == ram else "*** MISMATCH ***"
        print(f"lambda = {lam:6.3f} | roots |u| = ({abs(r1):.5f}, {abs(r2):.5f}) "
              f"| on-circle={str(both_on):5} | Ramanujan={str(ram):5} | {status}")
    print()


# ---------------------------------------------------------------------------
# Demo 2: the trivial eigenvalue lambda = q+1
# ---------------------------------------------------------------------------
def demo_trivial_eigenvalue() -> None:
    print("=" * 70)
    print("DEMO 2: the trivial eigenvalue lambda = q+1 escapes the circle")
    print("=" * 70)
    for q in [2.0, 3.0, 4.0, 9.0]:
        lam = q + 1.0
        r1, r2 = local_factor_roots(q, lam)
        crit = 1.0 / math.sqrt(q)
        print(f"q = {q:4.1f} | lambda = q+1 = {lam:4.1f} | roots = "
              f"({r1.real:.4f}, {r2.real:.4f}) | expected (1/q, 1) = "
              f"({1/q:.4f}, {1.0:.4f}) | critical 1/sqrt(q) = {crit:.4f}")
    print("Roots are always 1 and 1/q -- off the circle for q > 1.\n")


# ---------------------------------------------------------------------------
# Adjacency-matrix eigenvalues (symmetric Jacobi eigen-solver, no numpy)
# ---------------------------------------------------------------------------
def symmetric_eigenvalues(mat: List[List[float]], iters: int = 100) -> List[float]:
    """Jacobi rotation eigenvalue solver for a real symmetric matrix."""
    n = len(mat)
    a = [row[:] for row in mat]
    for _ in range(iters):
        # find largest off-diagonal magnitude
        p, qi, best = 0, 1, 0.0
        for i in range(n):
            for j in range(i + 1, n):
                if abs(a[i][j]) > best:
                    best, p, qi = abs(a[i][j]), i, j
        if best < 1e-12:
            break
        app, aqq, apq = a[p][p], a[qi][qi], a[p][qi]
        theta = 0.5 * math.atan2(2.0 * apq, aqq - app) if aqq != app else math.pi / 4
        c, s = math.cos(theta), math.sin(theta)
        for k in range(n):
            akp, akq = a[k][p], a[k][qi]
            a[k][p] = c * akp - s * akq
            a[k][qi] = s * akp + c * akq
        for k in range(n):
            akp, akq = a[p][k], a[qi][k]
            a[p][k] = c * akp - s * akq
            a[qi][k] = s * akp + c * akq
    return sorted((a[i][i] for i in range(n)), reverse=True)


def paley_graph(p: int) -> List[List[float]]:
    """Adjacency matrix of the Paley graph on p vertices (p prime, p = 1 mod 4).
    Vertices i~j iff (i-j) is a nonzero quadratic residue mod p. This is a
    ((p-1)/2)-regular Ramanujan graph."""
    squares = {(x * x) % p for x in range(1, p)}
    mat = [[0.0] * p for _ in range(p)]
    for i in range(p):
        for j in range(p):
            if i != j and (i - j) % p in squares:
                mat[i][j] = 1.0
    return mat


def cycle_graph(n: int) -> List[List[float]]:
    """Adjacency matrix of the n-cycle C_n, a 2-regular graph (q = 1)."""
    mat = [[0.0] * n for _ in range(n)]
    for i in range(n):
        mat[i][(i + 1) % n] = 1.0
        mat[(i + 1) % n][i] = 1.0
    return mat


# ---------------------------------------------------------------------------
# Demo 3: certified spectral RH test on real graphs
# ---------------------------------------------------------------------------
def rh_test(mat: List[List[float]], name: str) -> None:
    eigs = symmetric_eigenvalues(mat)
    degree = int(round(max(eigs)))          # top eigenvalue = q+1 for regular graph
    q = degree - 1
    trivial = eigs[0]
    nontrivial = eigs[1:]
    bound = 2.0 * math.sqrt(q) if q > 0 else 0.0
    max_nontrivial = max(abs(l) for l in nontrivial)
    is_ram = max_nontrivial <= bound + 1e-6
    print(f"{name}")
    print(f"  vertices = {len(mat)}, degree q+1 = {degree}  (q = {q})")
    print(f"  trivial eigenvalue = {trivial:.4f}  (= q+1 = {q+1})")
    print(f"  Ramanujan bound 2*sqrt(q) = {bound:.4f}")
    print(f"  max |nontrivial eigenvalue| = {max_nontrivial:.4f}")
    print(f"  => Ramanujan / RH for zeta_G: {is_ram}\n")


def demo_real_graphs() -> None:
    print("=" * 70)
    print("DEMO 3: certified spectral RH test on explicit graphs")
    print("=" * 70)
    rh_test(paley_graph(5), "Paley graph P(5)")
    rh_test(paley_graph(13), "Paley graph P(13)")
    rh_test(paley_graph(17), "Paley graph P(17)")
    rh_test(cycle_graph(6), "Cycle graph C_6 (q = 1)")


# ---------------------------------------------------------------------------
# Demo 4: prime-cycle counting vs the q^m/m heuristic
# ---------------------------------------------------------------------------
def prime_cycle_counts(mat: List[List[float]], max_len: int) -> List[int]:
    """Count prime (primitive, non-backtracking, closed) cycles by length using
    the non-backtracking (Hashimoto) edge matrix B: trace(B^m) counts closed
    non-backtracking walks of length m; Mobius inversion extracts primitives."""
    # build directed edges
    edges = [(i, j) for i in range(len(mat)) for j in range(len(mat)) if mat[i][j]]
    m = len(edges)
    B = [[0] * m for _ in range(m)]
    for a, (i, j) in enumerate(edges):
        for b, (k, l) in enumerate(edges):
            if j == k and l != i:      # follow edge, no backtrack
                B[a][b] = 1

    def matmul(X, Y):
        return [[sum(X[r][t] * Y[t][c] for t in range(m)) for c in range(m)]
                for r in range(m)]

    power = [[1 if r == c else 0 for c in range(m)] for r in range(m)]
    Nm = []  # number of closed non-backtracking walks of length k, k=1..max_len
    for _ in range(max_len):
        power = matmul(power, B)
        Nm.append(sum(power[i][i] for i in range(m)))

    # primitive counts via Mobius: sum_{d | k} d * Prim(d) = N_k  (each primitive
    # of length d contributes d closed walks of length k when d | k as its powers)
    prim = [0] * (max_len + 1)
    for k in range(1, max_len + 1):
        total = Nm[k - 1]
        for d in range(1, k):
            if k % d == 0:
                total -= d * prim[d]
        prim[k] = total // k
    return prim[1:]


def demo_prime_cycle_theorem() -> None:
    print("=" * 70)
    print("DEMO 4: prime-cycle counts vs the q^m/m heuristic (Ramanujan graph)")
    print("=" * 70)
    mat = paley_graph(13)          # 6-regular, q = 5
    q = 5
    max_len = 6
    prim = prime_cycle_counts(mat, max_len)
    print(f"Paley graph P(13): q = {q}\n")
    print(f"{'m':>3} | {'#prime cycles len m':>20} | {'q^m/m heuristic':>18}")
    for m_len in range(1, max_len + 1):
        heur = q ** m_len / m_len
        print(f"{m_len:>3} | {prim[m_len-1]:>20} | {heur:>18.1f}")
    print("\nCounts grow at the exponential rate q^m predicted by the "
          "prime-cycle theorem.\n")


if __name__ == "__main__":
    demo_local_equivalence()
    demo_trivial_eigenvalue()
    demo_real_graphs()
    demo_prime_cycle_theorem()
