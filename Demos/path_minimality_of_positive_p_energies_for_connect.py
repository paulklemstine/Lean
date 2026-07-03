"""
Numerical demonstrations for:

    Path-Minimality of Positive p-Energies for Connected Bipartite Graphs

Key results demonstrated:
  1. Squared-energy identity:   sum_i lambda_i^2 = 2 * |E(G)|   (any simple graph)
  2. Path-minimality at p=2:    sum_i lambda_i^2 >= 2(n-1), equality for the path P_n
  3. Bipartite balance / half-Schatten:  for bipartite G and p != 0,
        sum_k |lambda_k|^p = 2 * E_p^+(G),   hence  E_2^+(G) = |E(G)|
  4. Closed-form path spectrum: lambda_k(P_n) = 2 cos((k+1) pi / (n+1))
        and  sum_k lambda_k(P_n)^2 = 2(n-1)

This file is self-contained (only the standard library + math). All functions
are inlined and type-hinted. Run with:  python demo.py
"""

from __future__ import annotations

import math
from typing import List, Tuple


# --------------------------------------------------------------------------
# Minimal symmetric-eigenvalue solver (Jacobi rotation) so the demo needs no
# third-party dependencies. Returns eigenvalues of a real symmetric matrix.
# --------------------------------------------------------------------------
def symmetric_eigenvalues(matrix: List[List[float]], iterations: int = 200,
                          tol: float = 1e-12) -> List[float]:
    """Eigenvalues of a real symmetric matrix via the cyclic Jacobi method."""
    n: int = len(matrix)
    a: List[List[float]] = [row[:] for row in matrix]
    for _ in range(iterations):
        off: float = 0.0
        p, q = 0, 1
        for i in range(n):
            for j in range(i + 1, n):
                if abs(a[i][j]) > off:
                    off = abs(a[i][j])
                    p, q = i, j
        if off < tol:
            break
        if a[p][p] == a[q][q]:
            theta = math.pi / 4 if a[p][q] > 0 else -math.pi / 4
        else:
            theta = 0.5 * math.atan2(2 * a[p][q], a[p][p] - a[q][q])
        c, s = math.cos(theta), math.sin(theta)
        for k in range(n):
            akp, akq = a[k][p], a[k][q]
            a[k][p] = c * akp + s * akq
            a[k][q] = -s * akp + c * akq
        for k in range(n):
            apk, aqk = a[p][k], a[q][k]
            a[p][k] = c * apk + s * aqk
            a[q][k] = -s * apk + c * aqk
    return sorted((a[i][i] for i in range(n)), reverse=True)


# --------------------------------------------------------------------------
# Graph utilities (graphs given as adjacency matrices of 0/1 entries).
# --------------------------------------------------------------------------
def edge_count(adj: List[List[int]]) -> int:
    """Number of edges of a simple graph given by its 0/1 adjacency matrix."""
    n: int = len(adj)
    return sum(adj[i][j] for i in range(n) for j in range(i + 1, n))


def path_graph(n: int) -> List[List[int]]:
    """Adjacency matrix of the path P_n on vertices 0..n-1."""
    adj: List[List[int]] = [[0] * n for _ in range(n)]
    for i in range(n - 1):
        adj[i][i + 1] = adj[i + 1][i] = 1
    return adj


def cycle_graph(n: int) -> List[List[int]]:
    """Adjacency matrix of the cycle C_n."""
    adj: List[List[int]] = [[0] * n for _ in range(n)]
    for i in range(n):
        adj[i][(i + 1) % n] = adj[(i + 1) % n][i] = 1
    return adj


def complete_bipartite(a: int, b: int) -> List[List[int]]:
    """Adjacency matrix of the complete bipartite graph K_{a,b}."""
    n: int = a + b
    adj: List[List[int]] = [[0] * n for _ in range(n)]
    for i in range(a):
        for j in range(a, n):
            adj[i][j] = adj[j][i] = 1
    return adj


def star_graph(n: int) -> List[List[int]]:
    """Adjacency matrix of the star K_{1,n-1} (center = vertex 0)."""
    adj: List[List[int]] = [[0] * n for _ in range(n)]
    for i in range(1, n):
        adj[0][i] = adj[i][0] = 1
    return adj


# --------------------------------------------------------------------------
# Energies.
# --------------------------------------------------------------------------
def positive_p_energy(eigs: List[float], p: float) -> float:
    """E_p^+ = sum over positive eigenvalues of lambda^p."""
    return sum(lam ** p for lam in eigs if lam > 1e-9)


def absolute_p_energy(eigs: List[float], p: float) -> float:
    """Schatten p-energy = sum_k |lambda_k|^p (ignoring true zeros for p>0)."""
    return sum(abs(lam) ** p for lam in eigs if abs(lam) > 1e-9)


def squared_energy(eigs: List[float]) -> float:
    """sum_i lambda_i^2."""
    return sum(lam * lam for lam in eigs)


# --------------------------------------------------------------------------
# Closed-form path spectrum.
# --------------------------------------------------------------------------
def path_eig(n: int, k: int) -> float:
    """Closed form eigenvalue lambda_k(P_n) = 2 cos((k+1) pi / (n+1))."""
    return 2.0 * math.cos((k + 1) * math.pi / (n + 1))


def path_spectrum_closed_form(n: int) -> List[float]:
    return [path_eig(n, k) for k in range(n)]


# --------------------------------------------------------------------------
# Demonstrations.
# --------------------------------------------------------------------------
def demo_squared_energy_identity() -> None:
    print("=" * 70)
    print("1. Squared-energy identity:  sum_i lambda_i^2 = 2 * |E(G)|")
    print("=" * 70)
    graphs: List[Tuple[str, List[List[int]]]] = [
        ("Path P_5", path_graph(5)),
        ("Cycle C_6", cycle_graph(6)),
        ("Star K_{1,4}", star_graph(5)),
        ("K_{3,3}", complete_bipartite(3, 3)),
    ]
    for name, adj in graphs:
        eigs = symmetric_eigenvalues([[float(x) for x in row] for row in adj])
        lhs = squared_energy(eigs)
        rhs = 2 * edge_count(adj)
        print(f"  {name:14s}: sum lambda^2 = {lhs:8.4f},  2|E| = {rhs:3d}"
              f"   match={abs(lhs - rhs) < 1e-6}")
    print()


def demo_path_minimality() -> None:
    print("=" * 70)
    print("2. Path-minimality at p=2:  sum lambda^2 >= 2(n-1), tight at P_n")
    print("=" * 70)
    n = 6
    graphs: List[Tuple[str, List[List[int]]]] = [
        ("Path P_6", path_graph(n)),
        ("Cycle C_6", cycle_graph(n)),
        ("Star K_{1,5}", star_graph(n)),
        ("K_{3,3}", complete_bipartite(3, 3)),
    ]
    bound = 2 * (n - 1)
    print(f"  n = {n},  lower bound 2(n-1) = {bound}")
    for name, adj in graphs:
        eigs = symmetric_eigenvalues([[float(x) for x in row] for row in adj])
        val = squared_energy(eigs)
        print(f"  {name:14s}: sum lambda^2 = {val:8.4f}"
              f"   >= {bound}? {val >= bound - 1e-6}")
    print()


def demo_bipartite_half_schatten() -> None:
    print("=" * 70)
    print("3. Bipartite: E_p^+ = 1/2 * sum |lambda|^p, and E_2^+ = |E|")
    print("=" * 70)
    graphs: List[Tuple[str, List[List[int]]]] = [
        ("Path P_5", path_graph(5)),
        ("Cycle C_6 (bip.)", cycle_graph(6)),
        ("K_{2,3}", complete_bipartite(2, 3)),
    ]
    for name, adj in graphs:
        eigs = symmetric_eigenvalues([[float(x) for x in row] for row in adj])
        for p in (1.0, 2.0, 3.0):
            epos = positive_p_energy(eigs, p)
            eabs = absolute_p_energy(eigs, p)
            print(f"  {name:16s} p={p:.0f}: E_p^+={epos:8.4f}, "
                  f"1/2*Schatten={0.5 * eabs:8.4f}, "
                  f"match={abs(epos - 0.5 * eabs) < 1e-6}")
        e2 = positive_p_energy(eigs, 2.0)
        print(f"     -> E_2^+ = {e2:.4f}  vs  |E| = {edge_count(adj)}\n")


def demo_closed_form_consistency() -> None:
    print("=" * 70)
    print("4. Closed-form path spectrum  and  sum lambda_k(P_n)^2 = 2(n-1)")
    print("=" * 70)
    for n in (3, 5, 8):
        cf = path_spectrum_closed_form(n)
        num = symmetric_eigenvalues([[float(x) for x in row] for row in path_graph(n)])
        max_diff = max(abs(a - b) for a, b in zip(sorted(cf, reverse=True), num))
        s = sum(x * x for x in cf)
        print(f"  n={n}: max|closed-form - numeric| = {max_diff:.2e}, "
              f"sum lambda^2 = {s:8.4f}, 2(n-1) = {2 * (n - 1)}")
    print()


def main() -> None:
    demo_squared_energy_identity()
    demo_path_minimality()
    demo_bipartite_half_schatten()
    demo_closed_form_consistency()
    print("All demonstrations complete.")


if __name__ == "__main__":
    main()
