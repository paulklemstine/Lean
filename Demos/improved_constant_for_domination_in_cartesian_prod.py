"""
Numerical demonstrations for:

    An Improved Vizing-Type Constant for Domination in Cartesian Products of Graphs

We work with the domination number gamma(G) of a finite simple graph G, the
Cartesian (box) product G [] H, and the improved multiplicative constant

    c = (19 - sqrt(73)) / 18  ~= 0.5809,

which is the smaller root of 9x^2 - 19x + 8, and satisfies 1/2 < c < 1.

This file is self-contained (standard library only) and verifies, on concrete
graphs:

  1. the algebraic facts about c;
  2. the two-sided bracket  max(gamma G, gamma H) <= gamma(G [] H) <= gamma(G)|V(H)|;
  3. the conditional improved Vizing bound when min(gamma G, gamma H) <= 1;
  4. that Vizing's product inequality itself holds on the sampled graphs.

Graphs are represented as (n, edges): n vertices labelled 0..n-1 and an edge set
of frozenset pairs.
"""

from __future__ import annotations

from itertools import combinations
from math import sqrt
from typing import Dict, FrozenSet, List, Set, Tuple

Graph = Tuple[int, Set[FrozenSet[int]]]

C: float = (19.0 - sqrt(73.0)) / 18.0


# --------------------------------------------------------------------------- #
# Graph construction helpers
# --------------------------------------------------------------------------- #
def make_graph(n: int, edge_list: List[Tuple[int, int]]) -> Graph:
    """Build a simple graph on vertices 0..n-1 from a list of undirected edges."""
    edges: Set[FrozenSet[int]] = {frozenset((u, v)) for u, v in edge_list if u != v}
    return (n, edges)


def path(n: int) -> Graph:
    """Path P_n on n vertices."""
    return make_graph(n, [(i, i + 1) for i in range(n - 1)])


def cycle(n: int) -> Graph:
    """Cycle C_n on n vertices (n >= 3)."""
    return make_graph(n, [(i, (i + 1) % n) for i in range(n)])


def complete(n: int) -> Graph:
    """Complete graph K_n on n vertices."""
    return make_graph(n, [(i, j) for i in range(n) for j in range(i + 1, n)])


def neighbours(g: Graph, v: int) -> Set[int]:
    """Open neighbourhood of v."""
    n, edges = g
    return {w for w in range(n) if frozenset((v, w)) in edges}


def box_product(g: Graph, h: Graph) -> Graph:
    """Cartesian (box) product G [] H with vertices flattened as a*nh + b."""
    ng, _ = g
    nh, _ = h

    def idx(a: int, b: int) -> int:
        return a * nh + b

    edges: List[Tuple[int, int]] = []
    # same first coordinate, adjacent second coordinate
    for a in range(ng):
        for b in range(nh):
            for b2 in neighbours(h, b):
                if b < b2:
                    edges.append((idx(a, b), idx(a, b2)))
    # same second coordinate, adjacent first coordinate
    for b in range(nh):
        for a in range(ng):
            for a2 in neighbours(g, a):
                if a < a2:
                    edges.append((idx(a, b), idx(a2, b)))
    return make_graph(ng * nh, edges)


# --------------------------------------------------------------------------- #
# Domination number via closed-neighbourhood bitmask cover search
# --------------------------------------------------------------------------- #
def domination_number(g: Graph) -> int:
    """Exact gamma(G) by increasing-size subset search using bitmask covers."""
    n, _ = g
    if n == 0:
        return 0
    full: int = (1 << n) - 1
    closed: List[int] = []
    for v in range(n):
        mask = 1 << v
        for w in neighbours(g, v):
            mask |= 1 << w
        closed.append(mask)
    for k in range(0, n + 1):
        for subset in combinations(range(n), k):
            cover = 0
            for v in subset:
                cover |= closed[v]
            if cover == full:
                return k
    return n  # unreachable for a valid graph


# --------------------------------------------------------------------------- #
# Certifications
# --------------------------------------------------------------------------- #
def constant_facts() -> Dict[str, float]:
    """Verify the algebraic properties of c numerically."""
    return {
        "c": C,
        "quadratic_9c2_19c_8": 9 * C * C - 19 * C + 8,  # ~ 0
        "c_minus_half": C - 0.5,                        # > 0
        "one_minus_c": 1.0 - C,                         # > 0
    }


def check_pair(name_g: str, g: Graph, name_h: str, h: Graph) -> None:
    """Print the bracket, Vizing, and conditional-constant checks for G, H."""
    gg = domination_number(g)
    gh = domination_number(h)
    prod = box_product(g, h)
    gprod = domination_number(prod)
    nh = h[0]

    lower = max(gg, gh)
    upper = gg * nh
    vizing_rhs = gg * gh
    const_rhs = C * gg * gh

    print(f"--- {name_g}  []  {name_h} ---")
    print(f"  gamma(G) = {gg},  gamma(H) = {gh},  gamma(G[]H) = {gprod}")
    print(f"  bracket:   max(gG,gH)={lower} <= {gprod} <= gG*|V(H)|={upper}   "
          f"[{'OK' if lower <= gprod <= upper else 'FAIL'}]")
    print(f"  Vizing:    gamma(G[]H)={gprod} >= gG*gH={vizing_rhs}            "
          f"[{'OK' if gprod >= vizing_rhs else 'FAIL'}]")
    cond = min(gg, gh) <= 1
    tag = "applies" if cond else "not required (min>1)"
    print(f"  improved constant ({tag}): {gprod} >= c*gG*gH={const_rhs:.4f}   "
          f"[{'OK' if gprod >= const_rhs - 1e-9 else 'FAIL'}]")
    print()


def main() -> None:
    print("=" * 66)
    print("Improved Vizing-type constant  c = (19 - sqrt(73))/18")
    print("=" * 66)
    facts = constant_facts()
    print(f"  c                       = {facts['c']:.10f}")
    print(f"  9c^2 - 19c + 8          = {facts['quadratic_9c2_19c_8']:.2e}  (should be 0)")
    print(f"  c - 1/2                 = {facts['c_minus_half']:.10f}  (should be > 0)")
    print(f"  1 - c                   = {facts['one_minus_c']:.10f}  (should be > 0)")
    print()

    pairs = [
        ("K2", complete(2), "K2", complete(2)),      # C4
        ("P3", path(3), "K2", complete(2)),          # 2x3 grid
        ("P3", path(3), "P3", path(3)),              # 3x3 grid
        ("C4", cycle(4), "K2", complete(2)),
        ("C5", cycle(5), "C5", cycle(5)),            # both gamma=2
        ("P4", path(4), "P4", path(4)),              # both gamma=2
        ("K3", complete(3), "K3", complete(3)),
    ]
    for ng, g, nh, h in pairs:
        check_pair(ng, g, nh, h)


if __name__ == "__main__":
    main()
