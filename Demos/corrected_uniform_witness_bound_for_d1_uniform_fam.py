"""
Numerical demonstrations of the Uniform Witness Bound for (d+1)-uniform
families classified by missing-trace size.

Self-contained: no external dependencies beyond the Python standard library.

Vocabulary (matching the formal development):
  * Ground set [n] = {0, 1, ..., n-1}.
  * A family F is a set of (d+1)-element subsets of [n].
  * The facet-degree of a d-set D is the number of members of F containing D.
  * The private facets (missing traces) of a member A are the d-subsets of A
    whose facet-degree is exactly 1.
  * F has missing-trace size s when every member has exactly s private facets.
  * Witness bound:  W(d,s,n) = C(n,d+1)         if s == 0
                              = floor(C(n,d)/s)  if s >= 1
"""

from __future__ import annotations

from itertools import combinations
from math import comb
from typing import Dict, FrozenSet, Iterable, List, Tuple

Member = FrozenSet[int]
Facet = FrozenSet[int]
Family = List[Member]


# --------------------------------------------------------------------------
# Core quantities
# --------------------------------------------------------------------------
def is_uniform(family: Family, d: int) -> bool:
    """True iff every member has exactly d+1 elements."""
    return all(len(a) == d + 1 for a in family)


def facet_degrees(family: Family, d: int) -> Dict[Facet, int]:
    """Map each d-subset appearing under some member to its facet-degree."""
    deg: Dict[Facet, int] = {}
    for a in family:
        for combo in combinations(sorted(a), d):
            facet = frozenset(combo)
            deg[facet] = deg.get(facet, 0) + 1
    return deg


def private_facets(family: Family, a: Member, d: int,
                   deg: Dict[Facet, int]) -> List[Facet]:
    """The d-subsets of member `a` whose facet-degree equals 1."""
    return [frozenset(c) for c in combinations(sorted(a), d)
            if deg[frozenset(c)] == 1]


def missing_trace_size(family: Family, d: int) -> Tuple[bool, int]:
    """
    Return (uniform_size?, common_value).  uniform_size? is True iff every
    member has the same number of private facets; common_value is that shared
    count (or -1 if it is not uniform / the family is empty).
    """
    deg = facet_degrees(family, d)
    sizes = {len(private_facets(family, a, d, deg)) for a in family}
    if len(sizes) == 1:
        return True, next(iter(sizes))
    return False, -1


def witness_bound(d: int, s: int, n: int) -> int:
    """W(d, s, n) as in the main theorem."""
    if s == 0:
        return comb(n, d + 1)
    return comb(n, d) // s


# --------------------------------------------------------------------------
# Canonical families
# --------------------------------------------------------------------------
def complete_family(n: int, d: int) -> Family:
    """All (d+1)-subsets of [n]."""
    return [frozenset(c) for c in combinations(range(n), d + 1)]


def trivial_star(n: int, d: int) -> Family:
    """All (d+1)-subsets of [n] containing the fixed vertex 0."""
    return [frozenset((0,) + c) for c in combinations(range(1, n), d)]


# --------------------------------------------------------------------------
# Demonstrations
# --------------------------------------------------------------------------
def demo_canonical_cardinalities() -> None:
    print("=" * 68)
    print("Canonical family cardinalities  (Propositions 5.1, 5.2)")
    print("=" * 68)
    print(f"{'n':>3} {'d':>3} | {'|complete|':>11} {'C(n,d+1)':>10} | "
          f"{'|star|':>8} {'C(n-1,d)':>10}")
    for d in (2, 3):
        for n in range(2 * (d + 1), 2 * (d + 1) + 4):
            K = complete_family(n, d)
            S = trivial_star(n, d)
            print(f"{n:>3} {d:>3} | {len(K):>11} {comb(n, d + 1):>10} | "
                  f"{len(S):>8} {comb(n - 1, d):>10}")
            assert len(K) == comb(n, d + 1)
            assert len(S) == comb(n - 1, d)
            assert is_uniform(K, d) and is_uniform(S, d)
    print("OK: cardinalities match the closed forms.\n")


def demo_saturation_equality() -> None:
    print("=" * 68)
    print("Saturated regime s = 0  (Theorem 4.2)")
    print("=" * 68)
    # The complete family has NO private facets: every d-subset lies in many
    # (d+1)-members, so its facet-degree exceeds 1.  Hence missing-trace size 0.
    for d in (2, 3):
        n = 2 * (d + 1)
        K = complete_family(n, d)
        ok, s = missing_trace_size(K, d)
        print(f"d={d}, n={n}: complete family is uniform={is_uniform(K, d)}, "
              f"missing-trace size={s}, |F|={len(K)}, C(n,d+1)={comb(n, d+1)}")
        assert ok and s == 0
        assert len(K) == witness_bound(d, 0, n)
    print("OK: complete family is the saturated extremiser (|F| = C(n,d+1)).\n")


def demo_witness_bound_triangles() -> None:
    print("=" * 68)
    print("Witnessed regime: triangles on n=6 vertices  (d=2)")
    print("=" * 68)
    d, n = 2, 6
    print(f"Total d-subsets available: C({n},{d}) = {comb(n, d)}")
    for s in range(1, 4):
        print(f"  s={s}:  W(d,s,n) = floor(C({n},{d})/{s}) = "
              f"{witness_bound(d, s, n)}")
    # Explicit witnessed family: build triangles whose private pairs are
    # disjoint, illustrating |F| * s <= C(n,d).
    print()
    # An edge-disjoint set of triangles on 6 vertices (each pair used once)
    # would be a Steiner triple system; here we just verify the bound holds
    # for the trivial star and the complete family.
    S = trivial_star(n, d)
    ok, s = missing_trace_size(S, d)
    print(f"Trivial star d={d}, n={n}: |F|={len(S)}, "
          f"uniform-missing-trace={ok}, s={s}")
    if ok:
        print(f"  Check |F|*s = {len(S) * s} <= C(n,d) = {comb(n, d)} : "
              f"{len(S) * s <= comb(n, d)}")
    print()


def demo_disjointness_principle() -> None:
    print("=" * 68)
    print("Disjointness of private facets  (Lemma 3.3)")
    print("=" * 68)
    # Take a small family where some members own private facets and verify that
    # no d-set is private to two distinct members.
    d = 2
    family: Family = [
        frozenset({0, 1, 2}),
        frozenset({0, 1, 3}),
        frozenset({2, 4, 5}),
    ]
    n = 6
    assert is_uniform(family, d)
    deg = facet_degrees(family, d)
    owners: Dict[Facet, List[Member]] = {}
    for a in family:
        for p in private_facets(family, a, d, deg):
            owners.setdefault(p, []).append(a)
    print("Private facet -> owning member(s):")
    for facet, members in sorted(owners.items(), key=lambda kv: sorted(kv[0])):
        print(f"  {set(sorted(facet))} : {[set(sorted(m)) for m in members]}")
    assert all(len(ms) == 1 for ms in owners.values())
    total_private = sum(len(ms) for ms in owners.values())
    print(f"All private facets have a unique owner: True")
    print(f"Total private facets {total_private} <= C({n},{d}) = {comb(n, d)}: "
          f"{total_private <= comb(n, d)}\n")


def demo_bound_monotonicity() -> None:
    print("=" * 68)
    print("Witness bound as a function of the privacy budget s")
    print("=" * 68)
    d, n = 3, 8
    print(f"d={d}, n={n}, C(n,d+1)={comb(n, d+1)}, C(n,d)={comb(n, d)}")
    print(f"{'s':>3} | {'W(d,s,n)':>10}")
    for s in range(0, d + 1):
        print(f"{s:>3} | {witness_bound(d, s, n):>10}")
    print("Observe: the ceiling falls as s rises (privacy is expensive).\n")


def main() -> None:
    demo_canonical_cardinalities()
    demo_saturation_equality()
    demo_witness_bound_triangles()
    demo_disjointness_principle()
    demo_bound_monotonicity()
    print("All demonstrations completed successfully.")


if __name__ == "__main__":
    main()
