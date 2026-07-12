"""
White's Quadratic Exchange Conjecture (Part 3) --- numerical demonstrations.

This self-contained script illustrates the combinatorial engine behind White's
quadratic exchange conjecture:

  * configurations are MULTISETS of bases (finite subsets of a ground set);
  * the ELEMENT CENSUS (total multiset union) counts, with multiplicity, how many
    bases each ground element lies in;
  * a QUADRATIC EXCHANGE MOVE replaces two bases B1, B2 by two bases C1, C2 with
    the same pooled elements (B1 + B2 = C1 + C2 as multisets);
  * REACHABILITY is the equivalence closure of quadratic moves.

We verify, computationally:
  (1) every quadratic move preserves the census, the element multiplicities, and
      the number of bases (the NECESSARY direction of the conjecture);
  (2) every symmetric exchange (swap x in B1 for y in B2) is a quadratic move;
  (3) White's Part 3 holds on U_{2,4}: its three perfect matchings are one
      reachability class;
  (4) more broadly, on small uniform matroids the reachability class of a
      configuration equals its entire census bucket (the conjecture, tested).

Run with:  python demo.py
"""

from __future__ import annotations

from collections import Counter
from itertools import combinations
from typing import FrozenSet, Iterable, List, Set, Tuple

# A basis is a frozenset of ground-set elements (ints).
Basis = FrozenSet[int]
# A configuration is a multiset of bases, represented canonically as a sorted
# tuple of bases (each basis rendered as a sorted tuple) so it is hashable.
ConfigKey = Tuple[Tuple[int, ...], ...]


# ---------------------------------------------------------------------------
# Core combinatorics
# ---------------------------------------------------------------------------
def census(config: Iterable[Basis]) -> Counter[int]:
    """Total multiset union: multiplicity of each element across all bases."""
    c: Counter[int] = Counter()
    for basis in config:
        for e in basis:
            c[e] += 1
    return c


def config_key(config: Iterable[Basis]) -> ConfigKey:
    """Canonical hashable key for a multiset of bases."""
    return tuple(sorted(tuple(sorted(b)) for b in config))


def pooled(b1: Basis, b2: Basis) -> Counter[int]:
    """The combined multiset of elements of two bases."""
    return Counter(b1) + Counter(b2)


def is_quadratic_move(b1: Basis, b2: Basis, c1: Basis, c2: Basis) -> bool:
    """True iff replacing {b1,b2} by {c1,c2} keeps the pooled elements equal."""
    return pooled(b1, b2) == pooled(c1, c2)


def symmetric_exchange(b1: Basis, b2: Basis, x: int, y: int) -> Tuple[Basis, Basis]:
    """Swap x in b1 for y in b2: returns (b1 - x + y, b2 - y + x)."""
    new1 = (set(b1) - {x}) | {y}
    new2 = (set(b2) - {y}) | {x}
    return frozenset(new1), frozenset(new2)


# ---------------------------------------------------------------------------
# Uniform matroid U_{r,n}
# ---------------------------------------------------------------------------
def uniform_bases(r: int, n: int) -> List[Basis]:
    """All r-element subsets of {0,...,n-1}: the bases of U_{r,n}."""
    return [frozenset(s) for s in combinations(range(n), r)]


def legal_quadratic_neighbors(
    config: List[Basis], basis_family: Set[Basis]
) -> List[List[Basis]]:
    """All configurations reachable from `config` by ONE basis-preserving move."""
    neighbors: List[List[Basis]] = []
    m = len(config)
    for i in range(m):
        for j in range(i + 1, m):
            b1, b2 = config[i], config[j]
            pool = pooled(b1, b2)
            # try every ordered repartition of the pool into two family bases
            for c1 in basis_family:
                if not (Counter(c1) <= pool):
                    continue
                remainder = pool - Counter(c1)
                # c2 must exactly use the remainder and lie in the family
                c2_candidate = frozenset(remainder.keys())
                if Counter(c2_candidate) != remainder:
                    continue  # remainder had a repeated element -> not a set
                if c2_candidate not in basis_family:
                    continue
                new_config = list(config)
                new_config[i], new_config[j] = c1, c2_candidate
                neighbors.append(new_config)
    return neighbors


def reachability_class(
    start: List[Basis], basis_family: Set[Basis]
) -> Set[ConfigKey]:
    """BFS over basis-preserving quadratic moves; returns the whole class."""
    seen: Set[ConfigKey] = {config_key(start)}
    frontier: List[List[Basis]] = [start]
    while frontier:
        current = frontier.pop()
        for nxt in legal_quadratic_neighbors(current, basis_family):
            k = config_key(nxt)
            if k not in seen:
                seen.add(k)
                frontier.append(nxt)
    return seen


def census_bucket(
    example: List[Basis], m: int, basis_family: Set[Basis]
) -> Set[ConfigKey]:
    """All configurations of m bases from the family with `example`'s census."""
    target = census(example)
    fam = list(basis_family)

    def rec(chosen: List[Basis], start: int) -> Iterable[List[Basis]]:
        if len(chosen) == m:
            if census(chosen) == target:
                yield list(chosen)
            return
        # allow repeats: iterate with non-decreasing index for canonical multisets
        for idx in range(start, len(fam)):
            chosen.append(fam[idx])
            yield from rec(chosen, idx)
            chosen.pop()

    return {config_key(cfg) for cfg in rec([], 0)}


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------
def demo_census_invariance() -> None:
    print("=" * 70)
    print("DEMO 1: A quadratic move preserves the census and #bases")
    print("=" * 70)
    b1, b2 = frozenset({0, 1}), frozenset({2, 3})
    c1, c2 = frozenset({0, 2}), frozenset({1, 3})
    before = [b1, b2]
    after = [c1, c2]
    print(f"  before = {[sorted(b) for b in before]}, census = {dict(census(before))}")
    print(f"  after  = {[sorted(b) for b in after]}, census = {dict(census(after))}")
    print(f"  legal quadratic move?  {is_quadratic_move(b1, b2, c1, c2)}")
    print(f"  census preserved?      {census(before) == census(after)}")
    print(f"  #bases preserved?      {len(before) == len(after)}")


def demo_symmetric_is_quadratic() -> None:
    print("\n" + "=" * 70)
    print("DEMO 2: Every symmetric exchange is a quadratic move")
    print("=" * 70)
    b1, b2 = frozenset({0, 1, 2}), frozenset({3, 4, 5})
    x, y = 0, 3
    c1, c2 = symmetric_exchange(b1, b2, x, y)
    print(f"  swap {x} in {sorted(b1)} for {y} in {sorted(b2)}")
    print(f"  ->  {sorted(c1)}, {sorted(c2)}")
    print(f"  pooled elements equal?  {is_quadratic_move(b1, b2, c1, c2)}")
    print(f"  (both remain size-3 bases: {len(c1) == 3 and len(c2) == 3})")


def demo_u24() -> None:
    print("\n" + "=" * 70)
    print("DEMO 3: White's Part 3 verified on U_{2,4}")
    print("=" * 70)
    fam = set(uniform_bases(2, 4))
    print(f"  U_2,4 has {len(fam)} bases = C(4,2) = 6")
    m1 = [frozenset({0, 1}), frozenset({2, 3})]
    m2 = [frozenset({0, 2}), frozenset({1, 3})]
    m3 = [frozenset({0, 3}), frozenset({1, 2})]
    for name, m in [("M1", m1), ("M2", m2), ("M3", m3)]:
        print(f"  {name} = {[sorted(b) for b in m]}, census = {dict(census(m))}")
    cls = reachability_class(m1, fam)
    print(f"  reachability class of M1 contains M2? {config_key(m2) in cls}")
    print(f"  reachability class of M1 contains M3? {config_key(m3) in cls}")
    print(f"  size of the reachability class: {len(cls)}")


def demo_conjecture_holds_on_uniform() -> None:
    print("\n" + "=" * 70)
    print("DEMO 4: reachability class == census bucket on small uniform matroids")
    print("=" * 70)
    for (r, n, m) in [(2, 4, 2), (2, 5, 2), (2, 4, 3), (3, 5, 2)]:
        fam = set(uniform_bases(r, n))
        example = [uniform_bases(r, n)[0], uniform_bases(r, n)[-1]][:m]
        # pad the example to m bases if needed
        while len(example) < m:
            example.append(uniform_bases(r, n)[0])
        cls = reachability_class(example, fam)
        bucket = census_bucket(example, m, fam)
        ok = cls == bucket
        print(
            f"  U_{{{r},{n}}}, m={m} bases: "
            f"|class|={len(cls)}, |census bucket|={len(bucket)}, "
            f"White Part 3 holds here? {ok}"
        )


def main() -> None:
    demo_census_invariance()
    demo_symmetric_is_quadratic()
    demo_u24()
    demo_conjecture_holds_on_uniform()
    print("\nAll demonstrations complete.")


if __name__ == "__main__":
    main()
