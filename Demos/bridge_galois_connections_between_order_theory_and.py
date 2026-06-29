"""Numerical demonstrations of the Galois-connection / closure-system bridge.

This self-contained script illustrates, with concrete finite examples, the
mathematics formalized in the accompanying Lean development:

  * A Galois connection  l : alpha -> beta,  u : beta -> alpha  on complete
    lattices satisfying   l(a) <= b   iff   a <= u(b).
  * The closure operator  cl = u . l  and kernel operator  ker = l . u.
  * The fundamental fixed-point correspondence: an order isomorphism between
    closed elements {a : u(l(a)) = a} and coclosed elements {b : l(u(b)) = b}.
  * Completeness of the lattice of closed elements (infima inherited,
    suprema = closure of the ambient supremum).
  * The Knaster-Tarski extreme fixed points  lfp(cl) = u(l(bot)),
    gfp(ker) = l(u(top)).
  * The canonical topological instance: the Galois connection between subsets
    of points and ideals (modeled finitely) yielding Zariski-style closed sets.

Every example is fully inlined; no external libraries are required.
"""

from __future__ import annotations

from itertools import combinations, chain
from typing import Callable, FrozenSet, Iterable, List, Set, Tuple, TypeVar

A = TypeVar("A")
B = TypeVar("B")


# ---------------------------------------------------------------------------
# Generic powerset-lattice Galois machinery
# ---------------------------------------------------------------------------

def powerset(universe: Iterable[A]) -> List[FrozenSet[A]]:
    """Return all subsets of a finite universe, as frozensets."""
    items = list(universe)
    return [
        frozenset(combo)
        for r in range(len(items) + 1)
        for combo in combinations(items, r)
    ]


def closure(l: Callable[[FrozenSet[A]], FrozenSet[B]],
            u: Callable[[FrozenSet[B]], FrozenSet[A]]
            ) -> Callable[[FrozenSet[A]], FrozenSet[A]]:
    """The closure operator cl(a) = u(l(a))."""
    return lambda a: u(l(a))


def kernel(l: Callable[[FrozenSet[A]], FrozenSet[B]],
           u: Callable[[FrozenSet[B]], FrozenSet[A]]
           ) -> Callable[[FrozenSet[B]], FrozenSet[B]]:
    """The kernel/interior operator ker(b) = l(u(b))."""
    return lambda b: l(u(b))


def is_galois_connection(
    alpha: List[FrozenSet[A]],
    beta: List[FrozenSet[B]],
    l: Callable[[FrozenSet[A]], FrozenSet[B]],
    u: Callable[[FrozenSet[B]], FrozenSet[A]],
    le_a: Callable[[FrozenSet[A], FrozenSet[A]], bool],
    le_b: Callable[[FrozenSet[B], FrozenSet[B]], bool],
) -> bool:
    """Check the defining bi-implication l(a) <= b  iff  a <= u(b) exhaustively."""
    for a in alpha:
        for b in beta:
            if le_b(l(a), b) != le_a(a, u(b)):
                return False
    return True


def closed_elements(
    alpha: List[FrozenSet[A]],
    cl: Callable[[FrozenSet[A]], FrozenSet[A]],
) -> List[FrozenSet[A]]:
    """Elements fixed by the closure operator: u(l(a)) = a."""
    return [a for a in alpha if cl(a) == a]


# ---------------------------------------------------------------------------
# Example 1: a contravariant relation-induced Galois connection (FCA-style)
# ---------------------------------------------------------------------------

def relation_galois(
    objects: List[int],
    attributes: List[str],
    incidence: Set[Tuple[int, str]],
):
    """Build the classical derivation Galois connection of a formal context.

    For a set X of objects, l(X) = attributes shared by ALL objects in X.
    For a set Y of attributes, u(Y) = objects having ALL attributes in Y.
    Ordered by inclusion on objects and REVERSE inclusion on attributes, this
    is a monotone Galois connection; here we exhibit it in antitone form, the
    classical Galois correspondence, and report its closed sets (concepts).
    """
    def l(X: FrozenSet[int]) -> FrozenSet[str]:
        return frozenset(
            m for m in attributes if all((g, m) in incidence for g in X)
        )

    def u(Y: FrozenSet[str]) -> FrozenSet[int]:
        return frozenset(
            g for g in objects if all((g, m) in incidence for m in Y)
        )

    return l, u


# ---------------------------------------------------------------------------
# Example 2: a monotone Galois connection on subsets via a closure rule
# ---------------------------------------------------------------------------

def divisibility_closure(universe: List[int]):
    """A monotone closure operator: close a set under divisors within universe.

    We realize it as a genuine Galois connection l -| u where beta is the
    same lattice and u = identity, l = 'add all divisors'. Then cl = u . l is
    the divisor-closure, an honest closure operator on the subset lattice.
    """
    def divisors_within(n: int) -> Set[int]:
        return {d for d in universe if n % d == 0}

    def l(X: FrozenSet[int]) -> FrozenSet[int]:
        out: Set[int] = set()
        for n in X:
            out |= divisors_within(n)
        return frozenset(out)

    def u(Y: FrozenSet[int]) -> FrozenSet[int]:
        # Largest set whose divisor-closure is contained in Y: the elements of
        # Y all of whose divisors lie in Y (the 'interior' under the rule).
        return frozenset(
            n for n in Y if all(d in Y for d in divisors_within(n))
        )

    return l, u


# ---------------------------------------------------------------------------
# Example 3: Zariski-style closed sets from an ideal / zero-set connection
# ---------------------------------------------------------------------------

def zariski_demo(points: List[int], polys: List[Callable[[int], int]]):
    """A finite caricature of Spec: points and 'polynomials'.

    A 'point' p is a value; a 'polynomial' f vanishes at p when f(p) == 0.
    For a set S of points, u(S) = {f : f vanishes on all of S} (the ideal),
    and for a set F of polynomials, l(F) = {p : every f in F vanishes at p}
    (the zero set V(F)). The closure cl(S) = V(I(S)) is the Zariski closure;
    its fixed points are exactly the Zariski-closed sets.
    """
    def u(S: FrozenSet[int]) -> FrozenSet[int]:
        # index polynomials by position
        return frozenset(
            i for i, f in enumerate(polys) if all(f(p) == 0 for p in S)
        )

    def l(F: FrozenSet[int]) -> FrozenSet[int]:
        return frozenset(
            p for p in points if all(polys[i](p) == 0 for i in F)
        )

    return l, u


# ---------------------------------------------------------------------------
# Driver
# ---------------------------------------------------------------------------

def banner(title: str) -> None:
    print("\n" + "=" * 70)
    print(title)
    print("=" * 70)


def main() -> None:
    subset_le = lambda x, y: x <= y  # inclusion order on frozensets

    # ----- Example 2: monotone Galois connection & closure operator ---------
    banner("Example: monotone Galois connection (divisor closure)")
    universe = [1, 2, 3, 4, 6, 12]
    l2, u2 = divisibility_closure(universe)
    lattice = powerset(universe)
    ok = is_galois_connection(lattice, lattice, l2, u2, subset_le, subset_le)
    print(f"Defining bi-implication holds on all 2^{len(universe)} pairs: {ok}")

    cl2 = closure(l2, u2)
    ker2 = kernel(l2, u2)

    # closure operator axioms
    extensive = all(subset_le(a, cl2(a)) for a in lattice)
    idem = all(cl2(cl2(a)) == cl2(a) for a in lattice)
    print(f"cl extensive (a <= cl a): {extensive}")
    print(f"cl idempotent (cl(cl a) = cl a): {idem}")

    closed = closed_elements(lattice, cl2)
    print(f"number of closed elements (fixed points of cl): {len(closed)}")
    print("a few closed sets:",
          [sorted(c) for c in sorted(closed, key=lambda s: (len(s), sorted(s)))][:6])

    # Knaster-Tarski extreme fixed points
    bot: FrozenSet[int] = frozenset()
    top: FrozenSet[int] = frozenset(universe)
    lfp = u2(l2(bot))
    gfp = l2(u2(top))
    print(f"lfp(cl) = u(l(bot)) = {sorted(lfp)}")
    print(f"gfp(ker) = l(u(top)) = {sorted(gfp)}")

    # completeness: supremum of two closed sets = closure of their union
    c1, c2 = closed[1], closed[2]
    sup_closed = cl2(c1 | c2)
    print(f"closed sup of {sorted(c1)} and {sorted(c2)} "
          f"= cl(union) = {sorted(sup_closed)} (closed: {sup_closed in closed})")
    inf_closed = c1 & c2
    print(f"closed inf (inherited intersection): {sorted(inf_closed)} "
          f"(closed: {inf_closed in closed})")

    # ----- Example 1: formal concept analysis -------------------------------
    banner("Example: formal concept analysis (closed concepts)")
    objects = [1, 2, 3, 4]
    attributes = ["even", "prime", "square", "gt2"]
    incidence: Set[Tuple[int, str]] = set()
    for g in objects:
        if g % 2 == 0:
            incidence.add((g, "even"))
        if g in (2, 3):
            incidence.add((g, "prime"))
        if g in (1, 4):
            incidence.add((g, "square"))
        if g > 2:
            incidence.add((g, "gt2"))
    l1, u1 = relation_galois(objects, attributes, incidence)
    obj_lattice = powerset(objects)
    cl1 = lambda X: u1(l1(X))  # extent closure
    extents = closed_elements(obj_lattice, cl1)
    print("Formal concepts (extent | intent):")
    for X in sorted(extents, key=lambda s: (len(s), sorted(s))):
        print(f"  objects {sorted(X)!s:18} attributes {sorted(l1(X))}")

    # fixed-point correspondence: extent -> intent -> extent round trip
    rt_ok = all(u1(l1(X)) == X for X in extents)
    print(f"round trip u(l(extent)) = extent for all concepts: {rt_ok}")

    # ----- Example 3: Zariski closed sets -----------------------------------
    banner("Example: Zariski-style closed sets on a finite 'Spec'")
    points = [0, 1, 2, 3, 4]
    polys: List[Callable[[int], int]] = [
        lambda x: x,                 # vanishes at 0
        lambda x: x - 1,             # vanishes at 1
        lambda x: x * (x - 1),       # vanishes at 0,1
        lambda x: (x - 2) * (x - 3), # vanishes at 2,3
        lambda x: 0,                 # the zero polynomial: vanishes everywhere
    ]
    l3, u3 = zariski_demo(points, polys)
    pt_lattice = powerset(points)
    cl3 = lambda S: l3(u3(S))  # Zariski closure V(I(S))
    closed_sets = closed_elements(pt_lattice, cl3)
    print(f"Zariski-closed subsets of the {len(points)} points "
          f"({len(closed_sets)} of {2**len(points)} subsets):")
    for C in sorted(closed_sets, key=lambda s: (len(s), sorted(s))):
        print(f"  {sorted(C)}")

    # closed-set axioms: intersection of closed is closed; whole space closed
    inter_ok = all(
        (C & D) in closed_sets for C in closed_sets for D in closed_sets
    )
    whole_closed = frozenset(points) in closed_sets
    print(f"intersections of closed sets are closed: {inter_ok}")
    print(f"the whole space is closed: {whole_closed}")


if __name__ == "__main__":
    main()
