"""
Global Label Min-Cut (GLMC) — numerical demonstrations.

This self-contained script mirrors the formal model and theorems:

    cutLabels(edges, A)   : set of labels on edges crossing the cut (A, complement)
    cutValue(edges, A)    : number of DISTINCT crossing labels
    proper_cuts(V)        : nonempty vertex subsets that are not all of V
    glmc_opt(edges, V)    : minimum cutValue over proper cuts (0 if none)  -- brute force

An edge is a triple (u, v, ell): an undirected edge {u, v} carrying label ell.
The brute-force solver `glmc_opt` IS the definition of the optimum; the demos
below empirically reconfirm the proved theorems:

    cutValue_le_numLabels        : cutValue <= p
    glmcOpt_le_numLabels         : glmc_opt <= p
    glmcOpt_le_of_proper         : glmc_opt <= cutValue(A) for every proper A
    glmcOpt_attained             : some proper A achieves cutValue(A) == glmc_opt
    glmcOpt_eq_zero_of_separated : an edge-free proper cut forces glmc_opt == 0
"""

from __future__ import annotations

from itertools import combinations
from typing import Hashable, Iterable, List, Optional, Set, Tuple

Vertex = Hashable
Label = Hashable
Edge = Tuple[Vertex, Vertex, Label]


def crosses(edge: Edge, A: Set[Vertex]) -> bool:
    """True iff exactly one endpoint of `edge` lies in A: (u in A) != (v in A)."""
    u, v, _label = edge
    return (u in A) != (v in A)


def cut_labels(edges: Iterable[Edge], A: Set[Vertex]) -> Set[Label]:
    """Set of labels appearing on edges that cross the cut (A, complement)."""
    return {label for (u, v, label) in edges if (u in A) != (v in A)}


def cut_value(edges: Iterable[Edge], A: Set[Vertex]) -> int:
    """Number of DISTINCT labels crossing the cut (A, complement)."""
    return len(cut_labels(edges, A))


def proper_cuts(vertices: Iterable[Vertex]) -> List[Set[Vertex]]:
    """All proper cuts: nonempty subsets A of `vertices` with A != full set."""
    V = list(vertices)
    cuts: List[Set[Vertex]] = []
    for r in range(1, len(V)):  # 1 <= |A| <= |V| - 1 => nonempty and not all
        for combo in combinations(V, r):
            cuts.append(set(combo))
    return cuts


def glmc_opt(edges: Iterable[Edge], vertices: Iterable[Vertex]) -> int:
    """Brute-force GLMC optimum: min cut_value over proper cuts (0 if none)."""
    edges = list(edges)
    cuts = proper_cuts(vertices)
    if not cuts:
        return 0
    return min(cut_value(edges, A) for A in cuts)


def glmc_argmin(
    edges: Iterable[Edge], vertices: Iterable[Vertex]
) -> Tuple[int, Optional[Set[Vertex]]]:
    """Return (optimum, witnessing proper cut) — the attainment theorem in action."""
    edges = list(edges)
    cuts = proper_cuts(vertices)
    if not cuts:
        return 0, None
    best = min(cuts, key=lambda A: cut_value(edges, A))
    return cut_value(edges, best), best


# --------------------------------------------------------------------------- #
# Example networks
# --------------------------------------------------------------------------- #

def barbell() -> Tuple[List[Vertex], List[Edge]]:
    """Two triangles (label 'r') joined by a single bridge (label 'b')."""
    V = ["a1", "a2", "a3", "b1", "b2", "b3"]
    E: List[Edge] = [
        ("a1", "a2", "r"), ("a2", "a3", "r"), ("a1", "a3", "r"),
        ("b1", "b2", "r"), ("b2", "b3", "r"), ("b1", "b3", "r"),
        ("a1", "b1", "b"),  # the lone bridge
    ]
    return V, E


def doubled_bridge() -> Tuple[List[Vertex], List[Edge]]:
    """Barbell with a second parallel bridge of a different label ('g')."""
    V, E = barbell()
    E = E + [("a2", "b2", "g")]
    return V, E


def disconnected() -> Tuple[List[Vertex], List[Edge]]:
    """Two triangles, no bridge: already disconnected."""
    V, E = barbell()
    E = [e for e in E if e[2] != "b"]  # drop the bridge
    return V, E


def palette_saturating(p: int) -> Tuple[List[Vertex], List[Edge]]:
    """Two vertices joined by p parallel edges, one per label 0..p-1.

    Every proper cut (there is exactly one up to symmetry) crosses all p labels,
    so glmc_opt == p, showing the bound glmc_opt <= p is tight.
    """
    V: List[Vertex] = ["x", "y"]
    E: List[Edge] = [("x", "y", k) for k in range(p)]
    return V, E


# --------------------------------------------------------------------------- #
# Driver
# --------------------------------------------------------------------------- #

def report(name: str, V: List[Vertex], E: List[Edge]) -> None:
    p = len({label for (_u, _v, label) in E})
    opt, witness = glmc_argmin(E, V)
    print(f"== {name} ==")
    print(f"  |V| = {len(V)}, |E| = {len(E)}, p = #labels = {p}")
    print(f"  glmc_opt = {opt}")
    print(f"  witnessing proper cut A = {sorted(map(str, witness)) if witness else None}")
    if witness is not None:
        print(f"  crossing labels at witness = {sorted(map(str, cut_labels(E, witness)))}")
    # Theorem checks
    assert opt <= p, "VIOLATION: glmc_opt > p"
    for A in proper_cuts(V):
        assert opt <= cut_value(E, A), "VIOLATION: optimum exceeds a proper cut value"
        assert cut_value(E, A) <= p, "VIOLATION: cut_value > p"
    if witness is not None:
        assert cut_value(E, witness) == opt, "VIOLATION: witness does not attain optimum"
    print("  [all theorem checks passed]\n")


def main() -> None:
    report("Barbell (single bridge)", *barbell())
    report("Doubled bridge", *doubled_bridge())
    report("Already disconnected", *disconnected())
    for p in (1, 3, 5):
        report(f"Palette-saturating (p={p})", *palette_saturating(p))

    # Disconnection theorem: an edge-free proper cut forces glmc_opt == 0.
    V, E = disconnected()
    sep = {"a1", "a2", "a3"}  # one whole triangle
    assert cut_value(E, sep) == 0
    assert glmc_opt(E, V) == 0
    print("Disconnection theorem confirmed: edge-free proper cut => glmc_opt = 0.")


if __name__ == "__main__":
    main()
