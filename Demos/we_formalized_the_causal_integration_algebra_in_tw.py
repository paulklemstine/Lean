"""
Causal Integration Algebra — Numerical Demonstrations
=====================================================

This self-contained script demonstrates the key results of the Causal
Integration Algebra, where the integrated-information measure Phi of a
weighted directed graph is defined as the MINIMUM directed cut over all
nontrivial bipartitions (nonempty proper subsets of the node set).

A "causal system" is an n x n matrix of NONNEGATIVE edge weights:
    weight[i][j] = strength of the directed causal influence of node i on node j.

Cross-information of a cut S (a subset of nodes):
    crossInfo(S) = sum over i in S, j not in S of weight[i][j].

Integrated information:
    Phi = min over nonempty proper subsets S of crossInfo(S).

The demos below verify, on concrete examples, the theorems proved formally:
  * crossInfo_nonneg / phi_nonneg     : crossInfo >= 0, Phi >= 0
  * phi_le_crossInfo                  : Phi <= crossInfo(S) for every cut
  * phi_zero_of_disconnected          : a zero-cost cut forces Phi = 0
  * crossInfo_scale / phi_scale       : Phi(c*C) = c*Phi(C) for c >= 0
  * crossInfo_mono / phi_mono         : larger weights => larger (or equal) Phi
  * crossInfo_le_totalWeight / phi_le_totalWeight : Phi <= total edge weight

Everything is implemented inline with type hints. No external dependencies.
"""

from __future__ import annotations

from itertools import product
from typing import Iterable, List, Sequence, Tuple

Matrix = List[List[float]]


# ---------------------------------------------------------------------------
# Core definitions (mirroring the Lean development)
# ---------------------------------------------------------------------------

def is_causal_system(weight: Sequence[Sequence[float]]) -> bool:
    """A causal system requires a square matrix with nonnegative entries."""
    n = len(weight)
    if any(len(row) != n for row in weight):
        return False
    return all(weight[i][j] >= 0.0 for i in range(n) for j in range(n))


def cross_info(weight: Sequence[Sequence[float]], S: frozenset[int]) -> float:
    """Total weight of edges directed from S into its complement."""
    n = len(weight)
    complement = [j for j in range(n) if j not in S]
    return sum(weight[i][j] for i in S for j in complement)


def nontrivial_bipartitions(n: int) -> Iterable[frozenset[int]]:
    """All nonempty proper subsets of {0, ..., n-1}."""
    for bits in product([0, 1], repeat=n):
        subset = frozenset(i for i, b in enumerate(bits) if b)
        if 0 < len(subset) < n:
            yield subset


def phi(weight: Sequence[Sequence[float]]) -> float:
    """Integrated information: the minimum directed cut over nontrivial bipartitions."""
    n = len(weight)
    assert n >= 2, "Phi requires at least 2 nodes"
    return min(cross_info(weight, S) for S in nontrivial_bipartitions(n))


def phi_argmin(weight: Sequence[Sequence[float]]) -> Tuple[float, frozenset[int]]:
    """Return (Phi, a minimizing cut)."""
    n = len(weight)
    best_S = min(nontrivial_bipartitions(n), key=lambda S: cross_info(weight, S))
    return cross_info(weight, best_S), best_S


def total_weight(weight: Sequence[Sequence[float]]) -> float:
    """Sum of all edge weights."""
    n = len(weight)
    return sum(weight[i][j] for i in range(n) for j in range(n))


def scale(weight: Sequence[Sequence[float]], c: float) -> Matrix:
    """Scale all weights by a nonnegative constant c."""
    assert c >= 0.0, "scaling constant must be nonnegative"
    return [[c * w for w in row] for row in weight]


# ---------------------------------------------------------------------------
# Example systems
# ---------------------------------------------------------------------------

def ring_system(n: int, w: float = 1.0) -> Matrix:
    """A directed ring 0 -> 1 -> ... -> n-1 -> 0; well integrated (no cheap cut)."""
    M = [[0.0] * n for _ in range(n)]
    for i in range(n):
        M[i][(i + 1) % n] = w
    return M


def disconnected_system() -> Matrix:
    """Two independent 2-node blocks; cutting between blocks costs 0 (Phi = 0)."""
    return [
        [0.0, 5.0, 0.0, 0.0],
        [5.0, 0.0, 0.0, 0.0],
        [0.0, 0.0, 0.0, 7.0],
        [0.0, 0.0, 7.0, 0.0],
    ]


def complete_system(n: int, w: float = 1.0) -> Matrix:
    """Every node influences every other; maximally integrated for its weight."""
    return [[0.0 if i == j else w for j in range(n)] for i in range(n)]


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

def demo_basic_phi() -> None:
    print("=" * 70)
    print("DEMO 1: Phi as minimum cut on a directed ring vs. a complete graph")
    print("=" * 70)
    ring = ring_system(4, w=1.0)
    comp = complete_system(4, w=1.0)
    p_ring, cut_ring = phi_argmin(ring)
    p_comp, cut_comp = phi_argmin(comp)
    print(f"4-node directed ring   : Phi = {p_ring:.3f}, weakest cut = {set(cut_ring)}")
    print(f"4-node complete graph  : Phi = {p_comp:.3f}, weakest cut = {set(cut_comp)}")
    print("The complete graph resists partition more strongly (higher Phi).")
    print()


def demo_nonnegativity_and_minimum() -> None:
    print("=" * 70)
    print("DEMO 2: phi_nonneg and phi_le_crossInfo")
    print("=" * 70)
    comp = complete_system(5, w=2.0)
    p = phi(comp)
    print(f"Phi(complete_5, w=2) = {p:.3f}  ->  Phi >= 0 ? {p >= 0.0}")
    all_ge = True
    for S in nontrivial_bipartitions(5):
        ci = cross_info(comp, S)
        if not (p <= ci + 1e-12):
            all_ge = False
    print(f"Phi <= crossInfo(S) for EVERY nontrivial cut S ? {all_ge}")
    print()


def demo_disconnected() -> None:
    print("=" * 70)
    print("DEMO 3: phi_zero_of_disconnected")
    print("=" * 70)
    D = disconnected_system()
    p, cut = phi_argmin(D)
    print("Two independent 2-node blocks (strong internal links, no cross links).")
    print(f"Phi = {p:.3f}  via the free cut S = {set(cut)} with crossInfo = {p:.3f}")
    print("A disconnected system decomposes for free: Phi = 0.")
    print()


def demo_scaling() -> None:
    print("=" * 70)
    print("DEMO 4: phi_scale  ->  Phi(c*C) = c*Phi(C)")
    print("=" * 70)
    C = complete_system(4, w=1.5)
    base = phi(C)
    for c in [0.0, 0.5, 2.0, 3.7]:
        scaled = phi(scale(C, c))
        print(f"c = {c:>4}:  Phi(c*C) = {scaled:7.4f},  c*Phi(C) = {c * base:7.4f}, "
              f"match = {abs(scaled - c * base) < 1e-9}")
    print()


def demo_monotonicity() -> None:
    print("=" * 70)
    print("DEMO 5: phi_mono_of_weight_le  ->  larger weights => larger Phi")
    print("=" * 70)
    C1 = complete_system(4, w=1.0)
    # C2 dominates C1 pointwise: add nonnegative amounts everywhere.
    C2 = [[C1[i][j] + (0.0 if i == j else 0.5) for j in range(4)] for i in range(4)]
    p1, p2 = phi(C1), phi(C2)
    dominates = all(C1[i][j] <= C2[i][j] for i in range(4) for j in range(4))
    print(f"C2 dominates C1 pointwise ? {dominates}")
    print(f"Phi(C1) = {p1:.4f}  <=  Phi(C2) = {p2:.4f} ? {p1 <= p2 + 1e-12}")
    print()


def demo_total_weight_bound() -> None:
    print("=" * 70)
    print("DEMO 6: phi_le_totalWeight  ->  0 <= Phi <= total edge weight")
    print("=" * 70)
    for n in range(2, 7):
        C = complete_system(n, w=1.0)
        p, tw = phi(C), total_weight(C)
        print(f"n = {n}: Phi = {p:6.3f}, totalWeight = {tw:6.3f}, "
              f"0 <= Phi <= total ? {0.0 <= p <= tw + 1e-12}")
    print()


def main() -> None:
    print("\nCausal Integration Algebra — Numerical Demonstrations\n")
    demo_basic_phi()
    demo_nonnegativity_and_minimum()
    demo_disconnected()
    demo_scaling()
    demo_monotonicity()
    demo_total_weight_bound()
    print("All demonstrations completed. Each confirms a formally proved theorem.")


if __name__ == "__main__":
    main()
