"""
Numerical demonstrations for:

    Characterizing Finite Posets Whose Probabilistic Powerdomain Is an RB-Domain

A finite poset P is called *RB-shaped* when it satisfies two conditions at once:

    1. it has a least element (a bottom below everything), and
    2. its undirected Hasse graph is a tree (connected and acyclic).

This script implements finite posets from their order relation, computes the
covering relation and Hasse graph, and checks:

    * whether the poset has a least element,
    * whether the Hasse graph is connected,
    * whether the Hasse graph is acyclic (a forest),
    * whether the Hasse graph is a tree,
    * whether the poset is RB-shaped,
    * whether the poset contains a "covering diamond" obstruction.

It then reproduces the four key witnesses:

    * the two-element chain      (RB-shaped),
    * the diamond 2 x 2          (least element, but a 4-cycle -> not a tree),
    * the two-element antichain  (acyclic forest, but no least element),
    * the "V" poset V3           (a genuine tree, but no least element).

The script is self-contained: no third-party dependencies.
"""

from __future__ import annotations

from itertools import combinations, permutations
from typing import Callable, Dict, Hashable, List, Set, Tuple

Element = Hashable


class Poset:
    """A finite partially ordered set given by its ground set and <= relation."""

    def __init__(self, elements: List[Element], leq: Callable[[Element, Element], bool]) -> None:
        self.elements: List[Element] = list(elements)
        self._leq = leq
        self._validate()

    # ---- order primitives -------------------------------------------------

    def leq(self, x: Element, y: Element) -> bool:
        """Return True iff x <= y."""
        return self._leq(x, y)

    def lt(self, x: Element, y: Element) -> bool:
        """Return True iff x < y (strictly below)."""
        return self._leq(x, y) and x != y

    def _validate(self) -> None:
        """Check reflexivity, antisymmetry and transitivity."""
        E = self.elements
        for x in E:
            assert self.leq(x, x), f"reflexivity fails at {x!r}"
        for x in E:
            for y in E:
                if self.leq(x, y) and self.leq(y, x):
                    assert x == y, f"antisymmetry fails at {x!r},{y!r}"
        for x in E:
            for y in E:
                for z in E:
                    if self.leq(x, y) and self.leq(y, z):
                        assert self.leq(x, z), f"transitivity fails at {x!r},{y!r},{z!r}"

    # ---- covering relation and Hasse graph --------------------------------

    def covers(self, x: Element, y: Element) -> bool:
        """Return True iff y covers x: x < y with nothing strictly between."""
        if not self.lt(x, y):
            return False
        for z in self.elements:
            if self.lt(x, z) and self.lt(z, y):
                return False
        return True

    def hasse_edges(self) -> Set[Tuple[Element, Element]]:
        """Undirected edges {a,b} of the Hasse graph, as sorted-by-index tuples."""
        idx = {e: i for i, e in enumerate(self.elements)}
        edges: Set[Tuple[Element, Element]] = set()
        for a in self.elements:
            for b in self.elements:
                if self.covers(a, b):
                    e = (a, b) if idx[a] < idx[b] else (b, a)
                    edges.add(e)
        return edges

    def adjacency(self) -> Dict[Element, Set[Element]]:
        """Adjacency map of the (undirected) Hasse graph."""
        adj: Dict[Element, Set[Element]] = {e: set() for e in self.elements}
        for a, b in self.hasse_edges():
            adj[a].add(b)
            adj[b].add(a)
        return adj

    # ---- least element ----------------------------------------------------

    def least_element(self):
        """Return the least element if it exists, else None."""
        for b in self.elements:
            if all(self.leq(b, x) for x in self.elements):
                return b
        return None

    def has_least(self) -> bool:
        return self.least_element() is not None

    # ---- graph properties -------------------------------------------------

    def is_connected(self) -> bool:
        """Is the Hasse graph connected? (An empty graph counts as connected.)"""
        if not self.elements:
            return True
        adj = self.adjacency()
        start = self.elements[0]
        seen: Set[Element] = {start}
        stack = [start]
        while stack:
            u = stack.pop()
            for v in adj[u]:
                if v not in seen:
                    seen.add(v)
                    stack.append(v)
        return len(seen) == len(self.elements)

    def is_acyclic(self) -> bool:
        """Is the Hasse graph acyclic? A tree/forest has |V| - components edges."""
        n = len(self.elements)
        e = len(self.hasse_edges())
        comps = self._num_components()
        # A graph is a forest iff  edges == vertices - components.
        return e == n - comps

    def _num_components(self) -> int:
        adj = self.adjacency()
        seen: Set[Element] = set()
        comps = 0
        for s in self.elements:
            if s in seen:
                continue
            comps += 1
            seen.add(s)
            stack = [s]
            while stack:
                u = stack.pop()
                for v in adj[u]:
                    if v not in seen:
                        seen.add(v)
                        stack.append(v)
        return comps

    def is_tree(self) -> bool:
        """A tree = connected and acyclic."""
        return self.is_connected() and self.is_acyclic()

    def is_rb_shaped(self) -> bool:
        """RB-shape = has a least element AND Hasse graph is a tree."""
        return self.has_least() and self.is_tree()

    # ---- diamond obstruction ---------------------------------------------

    def find_covering_diamond(self):
        """
        Search for a covering diamond a<b, a<c, b<d, c<d with b != c.
        Return (a, b, c, d) if found, else None.
        """
        for a in self.elements:
            uppers = [x for x in self.elements if self.covers(a, x)]
            for b, c in combinations(uppers, 2):
                for d in self.elements:
                    if self.covers(b, d) and self.covers(c, d):
                        return (a, b, c, d)
        return None


# ---------------------------------------------------------------------------
# The four canonical witnesses.
# ---------------------------------------------------------------------------


def chain2() -> Poset:
    """Two-element chain 0 < 1."""
    return Poset([0, 1], lambda x, y: x <= y)


def diamond() -> Poset:
    """Boolean lattice 2 x 2 = {0,1}^2 ordered coordinatewise."""
    pts = [(0, 0), (1, 0), (0, 1), (1, 1)]
    return Poset(pts, lambda p, q: p[0] <= q[0] and p[1] <= q[1])


def antichain2() -> Poset:
    """Two-element antichain: order is equality."""
    return Poset(["a", "b"], lambda x, y: x == y)


def v_poset() -> Poset:
    """'V' poset: a, b incomparable minimal, both below top c."""
    return Poset(["a", "b", "c"], lambda x, y: x == y or y == "c")


# ---------------------------------------------------------------------------
# Reporting.
# ---------------------------------------------------------------------------


def report(name: str, P: Poset) -> None:
    least = P.least_element()
    diamond_hit = P.find_covering_diamond()
    print(f"=== {name} ===")
    print(f"  elements       : {P.elements}")
    print(f"  Hasse edges    : {sorted(map(str, P.hasse_edges()))}")
    print(f"  least element  : {least!r}" + ("" if least is not None else "  (none)"))
    print(f"  connected      : {P.is_connected()}")
    print(f"  acyclic        : {P.is_acyclic()}")
    print(f"  tree           : {P.is_tree()}")
    print(f"  covering diamond: {diamond_hit if diamond_hit else 'none'}")
    print(f"  RB-shaped      : {P.is_rb_shaped()}")
    print()


def main() -> None:
    print("Finite posets and the RB-shape condition")
    print("=" * 48)
    print()

    report("Two-element chain  (expect: RB-shaped)", chain2())
    report("Diamond 2 x 2      (least elt, but 4-cycle => NOT RB-shaped)", diamond())
    report("Antichain          (acyclic forest, but NO least element)", antichain2())
    report("'V' poset V3       (genuine tree, but NO least element)", v_poset())

    # Assertions encoding the paper's theorems.
    assert chain2().is_rb_shaped(), "chain should be RB-shaped"

    D = diamond()
    assert D.has_least(), "diamond has a least element"
    assert not D.is_tree(), "diamond Hasse graph is a 4-cycle, not a tree"
    assert not D.is_rb_shaped(), "diamond is NOT RB-shaped (Conjecture A refuted)"
    assert D.find_covering_diamond() is not None, "diamond contains a covering diamond"

    A = antichain2()
    assert A.is_acyclic(), "antichain Hasse graph is acyclic"
    assert not A.has_least(), "antichain has no least element (Conjecture B refuted)"

    V = v_poset()
    assert V.is_tree(), "V poset Hasse graph is a genuine tree"
    assert not V.has_least(), "V poset has no least element (Conjecture B, sharpened)"

    print("All theorem checks passed.")
    print()

    # Independence table (two conjuncts of RB-shape).
    print("Independence table")
    print("-" * 48)
    print(f"{'poset':<14}{'least?':<9}{'tree?':<8}{'RB-shaped?':<12}")
    for label, P in [
        ("chain", chain2()),
        ("diamond", diamond()),
        ("V poset", v_poset()),
        ("antichain", antichain2()),
    ]:
        print(f"{label:<14}{str(P.has_least()):<9}{str(P.is_tree()):<8}"
              f"{str(P.is_rb_shaped()):<12}")


if __name__ == "__main__":
    main()
