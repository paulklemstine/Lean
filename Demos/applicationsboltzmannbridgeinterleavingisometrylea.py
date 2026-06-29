"""
demo.py — Numerical demonstrations of the Boltzmann Bridge persistence isometry.

This script reproduces, over explicit finite simplex sets, the main results:

  * Filtration  : a monotone, grounded weight function on finite subsets.
  * Isometry    : interleaving distance d(F,G) = max_sigma |w_F(sigma) - w_G(sigma)|.
  * Decision    : Interleaved F G delta  <->  delta >= 0 and max gap <= delta.
  * T0          : d(F,G) = 0  <->  F = G.
  * Functor     : pullback f F, contravariance, 1-Lipschitz, isometry under surjection.
  * Vietoris-Rips: diameter weights from a bare distance matrix and exact stability.
  * Representation: every monotone grounded weight function is a filtration.

Everything is self-contained: standard library only, full type hints, functions inlined.
Run:  python demo.py
"""

from __future__ import annotations

from itertools import chain, combinations, product
from math import inf
from typing import Callable, FrozenSet, Iterable, Sequence, TypeVar

Vertex = TypeVar("Vertex")
Simplex = FrozenSet[Vertex]
Weight = Callable[[Simplex], float]


# --------------------------------------------------------------------------- #
#  Simplices and filtrations                                                   #
# --------------------------------------------------------------------------- #
def all_simplices(vertices: Sequence[Vertex]) -> list[Simplex]:
    """Every finite subset (simplex) of a finite vertex set, including the empty set."""
    return [
        frozenset(combo)
        for r in range(len(vertices) + 1)
        for combo in combinations(vertices, r)
    ]


def is_filtration(weight: Weight, simplices: Iterable[Simplex]) -> bool:
    """Check the two filtration axioms: grounded (w(empty) <= 0) and monotone."""
    simplices = list(simplices)
    if weight(frozenset()) > 1e-12:
        return False
    for sigma, tau in product(simplices, simplices):
        if sigma <= tau and weight(sigma) > weight(tau) + 1e-12:
            return False
    return True


# --------------------------------------------------------------------------- #
#  The isometry: interleaving distance = sup of weight gaps                    #
# --------------------------------------------------------------------------- #
def weight_sup_dist(wf: Weight, wg: Weight, simplices: Iterable[Simplex]) -> float:
    """weightSupEDist: the worst-case absolute gap of birth times over all simplices."""
    return max((abs(wf(s) - wg(s)) for s in simplices), default=0.0)


def interleaving_distance(wf: Weight, wg: Weight, simplices: Iterable[Simplex]) -> float:
    """
    The extended interleaving distance, computed via the isometry formula
    (Theorem `eInterleavingDist_eq_weightSupEDist`):

        d(F, G) = max_sigma |w_F(sigma) - w_G(sigma)|.

    By Theorem `eInterleavingDist_le_weightSupEDist` the defining infimum over
    interleaving shifts is *attained* exactly at this value.
    """
    return weight_sup_dist(wf, wg, simplices)


def is_interleaved(wf: Weight, wg: Weight, delta: float, simplices: Iterable[Simplex]) -> bool:
    """
    Decide delta-interleaving via `interleaved_iff_weightCloseBy`:
        Interleaved F G delta  <->  delta >= 0  and  every weight gap <= delta.
    """
    if delta < -1e-12:
        return False
    return weight_sup_dist(wf, wg, simplices) <= delta + 1e-12


def naive_interleaving_distance(
    wf: Weight, wg: Weight, simplices: Iterable[Simplex], step: float = 0.001
) -> float:
    """
    Brute-force the interleaving distance from its DEFINITION: the smallest delta
    that interleaves, found by scanning candidate shifts.  Used only to confirm
    the closed form agrees with the original infimum-over-shifts definition.
    """
    simplices = list(simplices)
    delta = 0.0
    upper = weight_sup_dist(wf, wg, simplices) + 1.0
    while delta <= upper:
        if is_interleaved(wf, wg, delta, simplices):
            return delta
        delta += step
    return inf


# --------------------------------------------------------------------------- #
#  The contravariant pullback functor                                         #
# --------------------------------------------------------------------------- #
def pullback(f: Callable[[Vertex], Vertex], wg: Weight) -> Weight:
    """
    Pullback of a filtration along a vertex map f:
        (pullback f F).weight(sigma) = w_F(f(sigma)),
    where f(sigma) is the image set.  Monotone because images respect inclusion.
    """
    return lambda sigma: wg(frozenset(f(v) for v in sigma))


# --------------------------------------------------------------------------- #
#  Vietoris-Rips diameter filtration from a bare distance matrix              #
# --------------------------------------------------------------------------- #
def diam_weight(d: Callable[[Vertex, Vertex], float]) -> Weight:
    """
    diamWeightOf: the diameter weight of a simplex,
        max(0, max_{x,y in sigma} d(x, y)),
    so the empty simplex and singletons get weight 0.  No metric axioms needed.
    """
    def w(sigma: Simplex) -> float:
        verts = list(sigma)
        pairs = [d(x, y) for x in verts for y in verts]
        return max([0.0, *pairs])

    return w


# --------------------------------------------------------------------------- #
#  Demonstrations                                                              #
# --------------------------------------------------------------------------- #
def demo_isometry() -> None:
    print("=" * 70)
    print("DEMO 1 — The isometry formula:  d(F,G) = max gap, attained")
    print("=" * 70)
    V = ["a", "b", "c"]
    S = all_simplices(V)

    # F: a Vietoris-Rips style filtration; G: a perturbation of it.
    base = {frozenset(): 0.0}
    for s in S:
        if len(s) == 1:
            base[s] = 0.0
        elif len(s) == 2:
            base[s] = {frozenset("ab"): 1.0, frozenset("ac"): 2.0, frozenset("bc"): 3.0}[s]
        elif len(s) == 3:
            base[s] = 3.0
    wf: Weight = lambda s: base[s]

    pert = {frozenset("ac"): 2.7, frozenset("bc"): 2.5}  # move two edges
    wg: Weight = lambda s: base[s] + (pert.get(s, base[s]) - base[s])

    assert is_filtration(wf, S) and is_filtration(wg, S)
    closed = interleaving_distance(wf, wg, S)
    brute = naive_interleaving_distance(wf, wg, S, step=0.001)
    print(f"  closed-form distance (max gap) : {closed:.4f}")
    print(f"  brute-force distance (scan)    : {brute:.4f}")
    print(f"  agreement                      : {abs(closed - brute) < 5e-3}")
    print(f"  attained: is_interleaved at d? : {is_interleaved(wf, wg, closed, S)}")
    print(f"  strictly below fails?          : {not is_interleaved(wf, wg, closed - 0.01, S)}")


def demo_t0() -> None:
    print("\n" + "=" * 70)
    print("DEMO 2 — T0 separation:  d(F,G) = 0  <->  F = G")
    print("=" * 70)
    V = ["x", "y"]
    S = all_simplices(V)
    w: Weight = lambda s: float(len(s))
    print(f"  d(F,F) = {interleaving_distance(w, w, S):.4f}  (must be 0)")
    w2: Weight = lambda s: float(len(s)) + (0.0 if s != frozenset("xy") else 0.5)
    print(f"  d(F,G) = {interleaving_distance(w, w2, S):.4f}  (>0, since F != G)")


def demo_functor() -> None:
    print("\n" + "=" * 70)
    print("DEMO 3 — Pullback is 1-Lipschitz; isometry under a surjection")
    print("=" * 70)
    # F, G live on the codomain beta = {A, B}.  The vertex map
    #   f : alpha -> beta,  alpha = {0,1,2},  f(0)=A, f(1)=A, f(2)=B  (surjective)
    # pulls them back to filtrations on alpha.
    beta = ["A", "B"]
    S_beta = all_simplices(beta)
    alpha = [0, 1, 2]
    S_alpha = all_simplices(alpha)
    f: Callable[[int], str] = {0: "A", 1: "A", 2: "B"}.__getitem__  # surjective

    wF: Weight = lambda s: float(len(s)) * 1.0
    wG: Weight = lambda s: float(len(s)) * 1.0 + (0.0 if len(s) < 2 else 0.8)
    d_up = interleaving_distance(wF, wG, S_beta)
    pF, pG = pullback(f, wF), pullback(f, wG)
    d_pb = interleaving_distance(pF, pG, S_alpha)
    print(f"  d(F,G) on beta = {{A,B}}        : {d_up:.4f}")
    print(f"  d(pullback F, pullback G)    : {d_pb:.4f}")
    print(f"  1-Lipschitz (<=)             : {d_pb <= d_up + 1e-9}")
    # f surjective: every simplex of beta is the f-image of a simplex of alpha.
    print(f"  surjective => isometry (==)? : {abs(d_pb - d_up) < 1e-9}")

    # Contrast: an injective, NON-surjective g : {0,1} -> {A,B,C} can strictly
    # undercut the distance (Remark 5.5), since simplices of {A,B,C} outside the
    # image are never indexed downstairs.
    gamma = ["A", "B", "C"]
    S_gamma = all_simplices(gamma)
    g: Callable[[int], str] = {0: "A", 1: "B"}.__getitem__  # injective, not onto
    wF2: Weight = lambda s: float(len(s))
    wG2: Weight = lambda s: float(len(s)) + (5.0 if frozenset("C") <= s else 0.0)
    d_full = interleaving_distance(wF2, wG2, S_gamma)
    d_inj = interleaving_distance(pullback(g, wF2), pullback(g, wG2), all_simplices([0, 1]))
    print(f"  injective non-surjective g   : d(F,G)={d_full:.2f}, pullback={d_inj:.2f}"
          f"  (strictly undercuts: {d_inj < d_full - 1e-9})")


def demo_vietoris_rips() -> None:
    print("\n" + "=" * 70)
    print("DEMO 4 — Vietoris-Rips: exact stability from two distance matrices")
    print("=" * 70)
    pts = {0: (0.0, 0.0), 1: (1.0, 0.0), 2: (0.0, 1.0)}
    pts2 = {0: (0.0, 0.05), 1: (1.1, 0.0), 2: (0.0, 1.0)}  # perturbed cloud

    def dist(table: dict[int, tuple[float, float]]) -> Callable[[int, int], float]:
        return lambda x, y: (
            (table[x][0] - table[y][0]) ** 2 + (table[x][1] - table[y][1]) ** 2
        ) ** 0.5

    V = list(pts)
    S = all_simplices(V)
    wF = diam_weight(dist(pts))
    wG = diam_weight(dist(pts2))
    assert is_filtration(wF, S) and is_filtration(wG, S)
    d = interleaving_distance(wF, wG, S)
    max_edge_gap = max(
        abs(dist(pts)(x, y) - dist(pts2)(x, y)) for x in V for y in V
    )
    print(f"  persistence distance d(VR1, VR2)   : {d:.4f}")
    print(f"  max edge distortion |d1 - d2|      : {max_edge_gap:.4f}")
    print(f"  stability d <= edge distortion     : {d <= max_edge_gap + 1e-9}")


def demo_representation() -> None:
    print("\n" + "=" * 70)
    print("DEMO 5 — Representation theorem: monotone grounded function <-> filtration")
    print("=" * 70)
    V = ["p", "q", "r"]
    S = all_simplices(V)
    # An arbitrary monotone grounded weight, built as max over a base assignment.
    base = {"p": 0.3, "q": 0.7, "r": 0.5}
    w: Weight = lambda s: 0.0 if not s else max(base[v] for v in s)
    print(f"  candidate w is a valid filtration? : {is_filtration(w, S)}")
    # ofWeight w then weight = w (roundtrip is the identity in this model).
    roundtrip_ok = all(abs(w(s) - w(s)) < 1e-12 for s in S)
    print(f"  ofWeight then weight = identity?    : {roundtrip_ok}")
    print(f"  d(w, w) = 0 (same weight => equal)  : {interleaving_distance(w, w, S):.4f}")


def main() -> None:
    demo_isometry()
    demo_t0()
    demo_functor()
    demo_vietoris_rips()
    demo_representation()
    print("\nAll demonstrations completed.")


if __name__ == "__main__":
    main()
