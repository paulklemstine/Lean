"""
Numerical demonstrations for the Brouwer Laplacian equality problem.

For a finite simple graph G on n vertices with m edges, let
    lambda_1 >= lambda_2 >= ... >= lambda_n >= 0
be the eigenvalues of the Laplacian L = D - A, and let
    s_k(G) = lambda_1 + ... + lambda_k
be the sum of the k largest Laplacian eigenvalues. This script demonstrates,
purely numerically:

  * the trace identity      s_n(G) = 2m,
  * monotonicity            s_1 <= s_2 <= ... <= s_n = 2m,
  * the global ceiling      s_k(G) <= 2m,
  * threshold graphs        from creation sequences, with the two boundary
                            identifications (all-dominating = complete,
                            all-isolated = empty),
  * the conjugate degree    sequence and the Grone-Merris-Bai bound
                            s_k <= sum of top-k conjugate degrees,
  * the Brouwer bound       beta_k = m + C(k+1, 2) and its equality set.

The implementation is self-contained and depends only on NumPy.
"""

from __future__ import annotations

import math
from typing import List, Sequence, Tuple

import numpy as np


# ---------------------------------------------------------------------------
# Core linear-algebra routines
# ---------------------------------------------------------------------------

def laplacian(adj: np.ndarray) -> np.ndarray:
    """Return the Laplacian L = D - A of a symmetric 0/1 adjacency matrix."""
    degrees = adj.sum(axis=1)
    return np.diag(degrees) - adj


def laplacian_eigenvalues_desc(adj: np.ndarray) -> np.ndarray:
    """Return the Laplacian eigenvalues in decreasing order (real, nonnegative)."""
    lap = laplacian(adj)
    eig = np.linalg.eigvalsh(lap)          # ascending, real (symmetric matrix)
    return np.sort(eig)[::-1]              # descending


def spectral_sum(adj: np.ndarray, k: int) -> float:
    """s_k(G): the sum of the k largest Laplacian eigenvalues."""
    eig = laplacian_eigenvalues_desc(adj)
    k = min(k, len(eig))
    return float(eig[:k].sum())


def num_edges(adj: np.ndarray) -> int:
    """Number of edges m of a simple graph given by adjacency matrix adj."""
    return int(adj.sum() // 2)


def brouwer_bound(adj: np.ndarray, k: int) -> float:
    """Brouwer bound beta_k = m + C(k+1, 2)."""
    m = num_edges(adj)
    return m + math.comb(k + 1, 2)


# ---------------------------------------------------------------------------
# Threshold graphs via creation sequences
# ---------------------------------------------------------------------------

def threshold_graph(creation: Sequence[bool]) -> np.ndarray:
    """
    Build the adjacency matrix of the threshold graph with a given creation
    sequence. creation[v] == True means vertex v is 'dominating' (joins all
    earlier vertices); False means 'isolated'. Distinct vertices i, j are
    adjacent iff creation[max(i, j)] is True.
    """
    n = len(creation)
    adj = np.zeros((n, n), dtype=int)
    for i in range(n):
        for j in range(i + 1, n):
            if creation[j]:            # j = max(i, j) since j > i
                adj[i, j] = adj[j, i] = 1
    return adj


def complete_graph(n: int) -> np.ndarray:
    """Adjacency matrix of the complete graph K_n."""
    return np.ones((n, n), dtype=int) - np.eye(n, dtype=int)


def empty_graph(n: int) -> np.ndarray:
    """Adjacency matrix of the edgeless graph on n vertices."""
    return np.zeros((n, n), dtype=int)


def clique_number_threshold(creation: Sequence[bool]) -> int:
    """
    Clique number of a threshold graph. For a threshold graph the dominating
    vertices, together with the earliest vertex, form a maximum clique; the
    clique number equals 1 + (number of dominating vertices), capped by n and
    at least 1 for a nonempty vertex set.
    """
    n = len(creation)
    if n == 0:
        return 0
    dominating = sum(1 for b in creation if b)
    return min(n, dominating + 1)


# ---------------------------------------------------------------------------
# Conjugate (transpose) degree sequence and the Grone-Merris-Bai bound
# ---------------------------------------------------------------------------

def degree_sequence(adj: np.ndarray) -> List[int]:
    """Degrees in decreasing order."""
    return sorted((int(d) for d in adj.sum(axis=1)), reverse=True)


def conjugate_degree_sequence(adj: np.ndarray) -> List[int]:
    """
    Conjugate (transpose) of the degree partition: d*_j = #{ i : d_i >= j }.
    """
    degs = degree_sequence(adj)
    if not degs:
        return []
    top = max(degs)
    return [sum(1 for d in degs if d >= j) for j in range(1, top + 1)]


def grone_merris_bai_bound(adj: np.ndarray, k: int) -> int:
    """Sum of the top-k conjugate degrees; upper bound for s_k(G)."""
    conj = conjugate_degree_sequence(adj)
    return int(sum(conj[:k]))


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

def demo_trace_identity() -> None:
    print("=" * 70)
    print("DEMO 1: Trace identity  s_n(G) = 2m")
    print("=" * 70)
    rng = np.random.default_rng(2026)
    for n in (5, 8, 12):
        # random simple graph
        upper = np.triu((rng.random((n, n)) < 0.4).astype(int), 1)
        adj = upper + upper.T
        m = num_edges(adj)
        sn = spectral_sum(adj, n)
        print(f"  n={n:2d}  m={m:3d}   s_n = {sn:8.4f}   2m = {2*m:3d}   "
              f"|s_n - 2m| = {abs(sn - 2*m):.2e}")
    print()


def demo_monotone_and_ceiling() -> None:
    print("=" * 70)
    print("DEMO 2: Monotonicity  s_1 <= ... <= s_n  and ceiling s_k <= 2m")
    print("=" * 70)
    rng = np.random.default_rng(7)
    n = 7
    upper = np.triu((rng.random((n, n)) < 0.5).astype(int), 1)
    adj = upper + upper.T
    m = num_edges(adj)
    sums = [spectral_sum(adj, k) for k in range(1, n + 1)]
    print(f"  n={n}, m={m}, 2m={2*m}")
    print("  k :  s_k     (nondecreasing, all <= 2m)")
    for k, s in enumerate(sums, start=1):
        flag = "  <= 2m OK" if s <= 2 * m + 1e-9 else "  VIOLATION"
        print(f"  {k} : {s:8.4f}{flag}")
    assert all(sums[i] <= sums[i + 1] + 1e-9 for i in range(len(sums) - 1))
    print("  monotone: OK")
    print()


def demo_threshold_boundaries() -> None:
    print("=" * 70)
    print("DEMO 3: Threshold-graph boundaries (complete / empty)")
    print("=" * 70)
    n = 6
    all_dom = threshold_graph([True] * n)
    all_iso = threshold_graph([False] * n)
    print(f"  all-dominating creation sequence == complete K_{n}? "
          f"{np.array_equal(all_dom, complete_graph(n))}")
    print(f"  all-isolated  creation sequence == empty graph?     "
          f"{np.array_equal(all_iso, empty_graph(n))}")
    print()


def demo_brouwer_equality_thresholds() -> None:
    print("=" * 70)
    print("DEMO 4: Brouwer equality on threshold graphs")
    print("        s_k = m + C(k+1,2)  at  k = omega - 1")
    print("=" * 70)
    rng = np.random.default_rng(11)
    for _ in range(4):
        n = 7
        creation = [False] + [bool(x) for x in (rng.random(n - 1) < 0.5)]
        adj = threshold_graph(creation)
        m = num_edges(adj)
        omega = clique_number_threshold(creation)
        k = omega - 1
        sk = spectral_sum(adj, k) if k >= 1 else 0.0
        beta = m + math.comb(k + 1, 2)
        gap = beta - sk
        print(f"  creation={''.join('D' if b else 'i' for b in creation)}  "
              f"m={m:2d}  omega={omega}  k={k}  "
              f"s_k={sk:7.3f}  beta_k={beta:6.1f}  gap={gap:.2e}")
    print()


def demo_empty_graph_boundary() -> None:
    print("=" * 70)
    print("DEMO 5: Empty graph  ->  s_k = 0, equality only at k = 0")
    print("=" * 70)
    n = 5
    adj = empty_graph(n)
    for k in range(0, 4):
        sk = spectral_sum(adj, k)
        beta = brouwer_bound(adj, k)
        eq = abs(sk - beta) < 1e-9
        print(f"  k={k}  s_k={sk:.3f}  beta_k=C({k+1},2)={beta:.0f}  "
              f"equality? {eq}")
    print()


def demo_grone_merris_bai() -> None:
    print("=" * 70)
    print("DEMO 6: Grone-Merris-Bai bound  s_k <= sum of top-k conjugate degrees")
    print("        (equality for all k characterizes threshold graphs)")
    print("=" * 70)
    # A threshold graph: expect equality for every k.
    creation = [False, True, False, True, True]
    thr = threshold_graph(creation)
    n = len(creation)
    print("  Threshold graph:")
    for k in range(1, n + 1):
        sk = spectral_sum(thr, k)
        gmb = grone_merris_bai_bound(thr, k)
        print(f"    k={k}  s_k={sk:7.3f}  top-k conj degrees={gmb:3d}  "
              f"tight? {abs(sk - gmb) < 1e-6}")
    # A non-threshold graph (a 4-cycle C4 has induced C4): expect slack.
    c4 = np.array([[0, 1, 0, 1],
                   [1, 0, 1, 0],
                   [0, 1, 0, 1],
                   [1, 0, 1, 0]])
    print("  Non-threshold graph (C4):")
    for k in range(1, 5):
        sk = spectral_sum(c4, k)
        gmb = grone_merris_bai_bound(c4, k)
        print(f"    k={k}  s_k={sk:7.3f}  top-k conj degrees={gmb:3d}  "
              f"tight? {abs(sk - gmb) < 1e-6}")
    print()


def main() -> None:
    demo_trace_identity()
    demo_monotone_and_ceiling()
    demo_threshold_boundaries()
    demo_brouwer_equality_thresholds()
    demo_empty_graph_boundary()
    demo_grone_merris_bai()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
