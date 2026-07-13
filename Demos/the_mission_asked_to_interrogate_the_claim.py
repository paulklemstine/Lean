"""
Numerical demonstrations for:

    "Connected Components Govern the L^p Threshold for Pattern Counts
     in Locally Dense Graphs"

All computations are exact finite averages in the step-graphon model.
Each function is self-contained and type-hinted. Run `python demo.py`.

Summary of the mathematics being demonstrated
---------------------------------------------
* rho-locally dense graphon W: every block-average of W is >= rho.
* Single edge K2:  ||W_{K2}||_{Lp} = ( mean W^p )^{1/p}.
    - Theorem 3.1: p >= 1  =>  ||W_{K2}||_{Lp} >= rho   (power mean).
    - Theorem 3.2: 0 < p < 1, k-block 0/1 kernel is a counterexample.
* 2-edge matching M2:
    - Theorem 4.1: ||W_{M2}||_{Lp} = ||W_{K2}||_{Lp}^2  (factorization).
    - Theorem 4.2: p >= 1 => ||W_{M2}||_{Lp} >= rho^2 (NO counterexample),
      disproving the conjectured threshold C(4,2)/2 = 3.
* Block-kernel closed form (Theorem 5.4):
      sum_phi hom(W_t, phi) = t^D * k^c,  D = directed edges, c = components.
* Corrected reachable threshold (Theorem 6.1): p < (n - c)/m.
"""

from __future__ import annotations

from itertools import product
from math import comb
from typing import Callable, Dict, List, Tuple

Kernel = Callable[[int, int], float]


# ---------------------------------------------------------------------------
# Core functionals in the finite step-graphon model
# ---------------------------------------------------------------------------
def single_edge_lp(W: Kernel, N: int, p: float) -> float:
    """||W_{K2}||_{Lp} = ( (1/N^2) sum_{x,y} W(x,y)^p )^(1/p)."""
    total = sum(W(x, y) ** p for x in range(N) for y in range(N))
    return (total / (N * N)) ** (1.0 / p)


def matching_lp(W: Kernel, N: int, p: float) -> float:
    """||W_{M2}||_{Lp} for the 2-edge matching (vertices 1,2,3,4; edges 12,34)."""
    total = sum(
        (W(a, b) ** p) * (W(c, d) ** p)
        for a in range(N)
        for b in range(N)
        for c in range(N)
        for d in range(N)
    )
    return (total / (N ** 4)) ** (1.0 / p)


def is_locally_dense(W: Kernel, N: int, rho: float, tol: float = 1e-12) -> bool:
    """Check (LD): every nonempty S has block-average >= rho. O(2^N)."""
    for mask in range(1, 1 << N):
        S = [i for i in range(N) if (mask >> i) & 1]
        avg = sum(W(x, y) for x in S for y in S) / (len(S) ** 2)
        if avg < rho - tol:
            return False
    return True


def block_kernel_01(k: int) -> Tuple[Kernel, int, float]:
    """k equal blocks (one point each), W=1 within a block, 0 across.

    Returns (W, N, rho) with N = k and rho = 1/k."""
    def W(x: int, y: int) -> float:
        return 1.0 if x == y else 0.0
    return W, k, 1.0 / k


# ---------------------------------------------------------------------------
# Demo 1: single-edge threshold is exactly p = 1
# ---------------------------------------------------------------------------
def demo_single_edge_threshold() -> None:
    print("=" * 70)
    print("DEMO 1  Single edge K2: threshold is exactly p = 1")
    print("=" * 70)
    k = 4
    W, N, rho = block_kernel_01(k)
    print(f"k={k}-block 0/1 kernel, rho = 1/k = {rho}")
    print(f"locally dense at level rho? {is_locally_dense(W, N, rho)}")
    print(f"{'p':>6} | {'||W_K2||_Lp':>14} | {'rho':>6} | verdict")
    print("-" * 55)
    for p in [0.25, 0.5, 0.75, 1.0, 1.5, 2.0, 4.0]:
        val = single_edge_lp(W, N, p)
        ce = "COUNTEREXAMPLE (< rho)" if val < rho - 1e-12 else "bound holds (>= rho)"
        print(f"{p:>6} | {val:>14.6f} | {rho:>6.3f} | {ce}")
    print("=> counterexamples appear exactly for p < 1 (Theorems 3.1-3.3).\n")


# ---------------------------------------------------------------------------
# Demo 2: matching factorization and the failure of C(n,2)/m
# ---------------------------------------------------------------------------
def demo_matching_disproof() -> None:
    print("=" * 70)
    print("DEMO 2  2-edge matching M2: the conjecture C(n,2)/m = 3 is FALSE")
    print("=" * 70)
    n, m = 4, 2
    conjectured = comb(n, 2) / m
    print(f"M2: n={n}, m={m}, conjectured threshold C(4,2)/2 = {conjectured}")
    k = 3
    W, N, rho = block_kernel_01(k)
    print(f"host: {k}-block 0/1 kernel, rho = {rho:.4f}\n")
    print(f"{'p':>5} | {'||W_M2||_Lp':>12} | {'(||W_K2||_Lp)^2':>16} | "
          f"{'rho^2':>8} | verdict")
    print("-" * 78)
    for p in [0.5, 1.0, 2.0, 2.9]:
        direct = matching_lp(W, N, p)
        factor = single_edge_lp(W, N, p) ** 2
        ce = "counterexample" if direct < rho ** 2 - 1e-12 else "bound holds"
        print(f"{p:>5} | {direct:>12.6f} | {factor:>16.6f} | "
              f"{rho ** 2:>8.4f} | {ce}")
    print("\nNote: factorization ||W_M2|| = ||W_K2||^2 holds to machine precision.")
    print("For every p in [1,3) the bound HOLDS -> the conjecture predicting")
    print("counterexamples there is refuted. True threshold is 1 (Cor. 4.3).\n")


# ---------------------------------------------------------------------------
# Demo 3: block-kernel closed form  sum_phi hom(W_t) = t^D * k^c
# ---------------------------------------------------------------------------
def num_components(n_vertices: int, edges: List[Tuple[int, int]]) -> int:
    """Number of connected components via union-find."""
    parent = list(range(n_vertices))

    def find(a: int) -> int:
        while parent[a] != a:
            parent[a] = parent[parent[a]]
            a = parent[a]
        return a

    for a, b in edges:
        ra, rb = find(a), find(b)
        if ra != rb:
            parent[ra] = rb
    return len({find(i) for i in range(n_vertices)})


def block_hom_sum_bruteforce(
    n_vertices: int, edges: List[Tuple[int, int]], k: int, t: float
) -> float:
    """Direct enumeration of sum_phi prod_{directed edges} W_t(phi(a),phi(b)),
    W_t(i,j) = t if i==j else 0.  Directed: each undirected edge is counted in
    both orientations, so D = 2*|E|.  O(k^n)."""
    directed = [(u, v) for (u, v) in edges] + [(v, u) for (u, v) in edges]
    total = 0.0
    for phi in product(range(k), repeat=n_vertices):
        prod = 1.0
        for a, b in directed:
            prod *= t if phi[a] == phi[b] else 0.0
        total += prod
    return total


def demo_closed_form() -> None:
    print("=" * 70)
    print("DEMO 3  Block-kernel closed form:  sum_phi hom(W_t) = t^D * k^c")
    print("=" * 70)
    patterns: Dict[str, Tuple[int, List[Tuple[int, int]]]] = {
        "single edge K2": (2, [(0, 1)]),
        "2-edge matching M2": (4, [(0, 1), (2, 3)]),
        "path P3": (3, [(0, 1), (1, 2)]),
        "triangle K3": (3, [(0, 1), (1, 2), (0, 2)]),
    }
    k, t = 3, 2.0
    print(f"k = {k} blocks, t = {t}   (D = 2*|E| directed edges)\n")
    print(f"{'pattern':>20} | {'c':>2} | {'D':>2} | {'brute':>10} | "
          f"{'t^D*k^c':>10} | match")
    print("-" * 70)
    for name, (nv, edges) in patterns.items():
        c = num_components(nv, edges)
        D = 2 * len(edges)
        brute = block_hom_sum_bruteforce(nv, edges, k, t)
        closed = (t ** D) * (k ** c)
        ok = abs(brute - closed) < 1e-9
        print(f"{name:>20} | {c:>2} | {D:>2} | {brute:>10.1f} | "
              f"{closed:>10.1f} | {ok}")
    print("\nThe exponent of k is exactly the number of components c.\n")


# ---------------------------------------------------------------------------
# Demo 4: corrected threshold (n-c)/m vs the conjectured C(n,2)/m
# ---------------------------------------------------------------------------
def demo_threshold_comparison() -> None:
    print("=" * 70)
    print("DEMO 4  Corrected threshold (n-c)/m  vs  conjectured C(n,2)/m")
    print("=" * 70)
    print(f"{'pattern':>22} | {'n':>2} | {'m':>2} | {'c':>2} | "
          f"{'(n-c)/m':>8} | {'C(n,2)/m':>9} | gap")
    print("-" * 74)
    families: List[Tuple[str, int, List[Tuple[int, int]]]] = [
        ("single edge K2", 2, [(0, 1)]),
        ("2-matching M2", 4, [(0, 1), (2, 3)]),
        ("3-matching M3", 6, [(0, 1), (2, 3), (4, 5)]),
        ("5-matching M5", 10, [(0, 1), (2, 3), (4, 5), (6, 7), (8, 9)]),
        ("triangle K3", 3, [(0, 1), (1, 2), (0, 2)]),
        ("path P3", 3, [(0, 1), (1, 2)]),
    ]
    for name, nv, edges in families:
        m = len(edges)
        c = num_components(nv, edges)
        corrected = (nv - c) / m
        conjectured = comb(nv, 2) / m
        gap = conjectured - corrected
        print(f"{name:>22} | {nv:>2} | {m:>2} | {c:>2} | "
              f"{corrected:>8.3f} | {conjectured:>9.3f} | {gap:>5.2f}")
    print("\nFor matchings the true threshold stays 1 while the conjecture")
    print("grows like 2m-1: the error is unbounded (Remark 4.4).\n")


def main() -> None:
    demo_single_edge_threshold()
    demo_matching_disproof()
    demo_closed_form()
    demo_threshold_comparison()


if __name__ == "__main__":
    main()
