"""
demo.py — Numerical demonstrations of the Aharoni–Korman property for
well-founded posets satisfying the Finite Antichain Condition (FAC).

The mathematics
---------------
A partial order (poset) on a finite/countable set assigns to each element an
ordinal *height* (well-founded rank):

    height(x) = sup { height(y) + 1 : y < x }.

Grouping elements by height gives the *level sets* L_a = { x : height(x) = a }.
The core theorems demonstrated here:

  * strict monotonicity:  x < y  =>  height(x) < height(y)
  * each level set is an antichain (no two comparable elements share a height)
  * under FAC each level set is finite; levels partition the poset
  * downward realizability: if a <= height(w) there is u <= w with height(u)=a
  * finite chain hitting: a single chain meets every non-empty level

All posets in this demo are finite, so ordinals are ordinary natural numbers and
every construction is explicit and computable. The functions are self-contained.
"""

from __future__ import annotations

from typing import Dict, FrozenSet, Iterable, List, Optional, Set, Tuple

# A poset is represented by its ground set and its strict-less-than relation,
# given as the set of covered pairs' transitive closure. We store the full
# strict relation as a set of ordered pairs (x, y) meaning x < y.
Element = str
Relation = Set[Tuple[Element, Element]]


# --------------------------------------------------------------------------- #
# Poset construction and basic queries
# --------------------------------------------------------------------------- #
def transitive_closure(ground: Iterable[Element],
                       covers: Iterable[Tuple[Element, Element]]) -> Relation:
    """Return the strict order (x < y) as the transitive closure of `covers`."""
    less: Relation = set(covers)
    changed = True
    while changed:
        changed = False
        new_pairs = {(a, d) for (a, b) in less for (c, d) in less if b == c}
        if not new_pairs <= less:
            less |= new_pairs
            changed = True
    return less


def is_less(less: Relation, x: Element, y: Element) -> bool:
    """True iff x < y in the strict order."""
    return (x, y) in less


def comparable(less: Relation, x: Element, y: Element) -> bool:
    """True iff x and y are comparable (x < y, y < x, or x == y)."""
    return x == y or (x, y) in less or (y, x) in less


# --------------------------------------------------------------------------- #
# Height (well-founded rank) and level sets
# --------------------------------------------------------------------------- #
def height(ground: List[Element], less: Relation) -> Dict[Element, int]:
    """
    Compute height(x) = sup{ height(y) + 1 : y < x } for every element.

    For a finite well-founded order this is a memoized recursion; the order is
    well-founded automatically since a finite strict order has no infinite
    descending chain.
    """
    memo: Dict[Element, int] = {}

    def h(x: Element) -> int:
        if x in memo:
            return memo[x]
        below = [y for y in ground if is_less(less, y, x)]
        memo[x] = 0 if not below else max(h(y) + 1 for y in below)
        return memo[x]

    return {x: h(x) for x in ground}


def level_sets(ground: List[Element],
              less: Relation) -> Dict[int, FrozenSet[Element]]:
    """Return the map a -> L_a = { x : height(x) = a }."""
    hts = height(ground, less)
    levels: Dict[int, Set[Element]] = {}
    for x in ground:
        levels.setdefault(hts[x], set()).add(x)
    return {a: frozenset(s) for a, s in sorted(levels.items())}


# --------------------------------------------------------------------------- #
# Verification of the structural theorems
# --------------------------------------------------------------------------- #
def check_strict_monotone(ground: List[Element], less: Relation) -> bool:
    """Verify x < y => height(x) < height(y)."""
    hts = height(ground, less)
    return all(hts[x] < hts[y] for (x, y) in less)


def is_antichain(less: Relation, s: Iterable[Element]) -> bool:
    """True iff no two distinct elements of s are comparable."""
    s = list(s)
    return all(not (is_less(less, s[i], s[j]) or is_less(less, s[j], s[i]))
               for i in range(len(s)) for j in range(i + 1, len(s)))


def check_levels_are_antichains(ground: List[Element], less: Relation) -> bool:
    """Verify every level set is an antichain."""
    return all(is_antichain(less, lvl)
               for lvl in level_sets(ground, less).values())


def check_partition(ground: List[Element], less: Relation) -> bool:
    """Verify the level sets are disjoint and cover the ground set."""
    levels = level_sets(ground, less)
    union: Set[Element] = set()
    for lvl in levels.values():
        if union & lvl:
            return False
        union |= lvl
    return union == set(ground)


# --------------------------------------------------------------------------- #
# Downward realizability and finite chain hitting
# --------------------------------------------------------------------------- #
def realize_below(ground: List[Element], less: Relation,
                 w: Element, alpha: int) -> Optional[Element]:
    """
    Downward realizability: given alpha <= height(w), return some u <= w with
    height(u) == alpha (or None if alpha > height(w)).
    """
    hts = height(ground, less)
    if alpha > hts[w]:
        return None
    cur = w
    while hts[cur] != alpha:
        # descend to some b < cur with height(b) >= alpha
        cur = next(b for b in ground
                   if is_less(less, b, cur) and hts[b] >= alpha)
    return cur


def chain_hitting_levels(ground: List[Element], less: Relation,
                        targets: List[int]) -> List[Element]:
    """
    Finite chain hitting: build a single chain meeting every non-empty level
    whose height is in `targets`. Implements the top-down construction:
    take the largest target M, realize it by w on level M, then recurse below.
    """
    hts = height(ground, less)
    levels = level_sets(ground, less)
    wanted = sorted({a for a in targets if a in levels}, reverse=True)
    if not wanted:
        return []
    M = wanted[0]
    w = next(iter(levels[M]))           # any witness on the top level
    chain = [w]
    for alpha in wanted[1:]:
        u = realize_below(ground, less, chain[-1], alpha)
        assert u is not None
        chain.append(u)
    return chain


def is_chain(less: Relation, c: Iterable[Element]) -> bool:
    """True iff every pair of elements in c is comparable."""
    c = list(c)
    return all(comparable(less, c[i], c[j])
               for i in range(len(c)) for j in range(i + 1, len(c)))


# --------------------------------------------------------------------------- #
# Example posets
# --------------------------------------------------------------------------- #
def divisibility_poset(n: int) -> Tuple[List[Element], Relation]:
    """The divisibility order on {1, ..., n}: a < b iff a | b and a != b."""
    ground = [str(k) for k in range(1, n + 1)]
    covers = [(str(a), str(b)) for a in range(1, n + 1)
              for b in range(1, n + 1)
              if a != b and b % a == 0]
    return ground, transitive_closure(ground, covers)


def boolean_lattice(k: int) -> Tuple[List[Element], Relation]:
    """The subset lattice of a k-element set, ordered by inclusion."""
    from itertools import combinations
    subsets = []
    for r in range(k + 1):
        for combo in combinations(range(k), r):
            subsets.append(frozenset(combo))
    label = {s: "{" + ",".join(map(str, sorted(s))) + "}" for s in subsets}
    ground = [label[s] for s in subsets]
    covers = [(label[a], label[b]) for a in subsets for b in subsets
              if a < b]
    return ground, transitive_closure(ground, covers)


# --------------------------------------------------------------------------- #
# Driver
# --------------------------------------------------------------------------- #
def report(name: str, ground: List[Element], less: Relation) -> None:
    print(f"\n=== {name} ({len(ground)} elements) ===")
    levels = level_sets(ground, less)
    for a, lvl in levels.items():
        print(f"  level {a}: {{{', '.join(sorted(lvl))}}}  (size {len(lvl)})")
    print(f"  strict monotonicity holds : {check_strict_monotone(ground, less)}")
    print(f"  every level an antichain  : {check_levels_are_antichains(ground, less)}")
    print(f"  levels partition the poset: {check_partition(ground, less)}")

    targets = list(levels.keys())
    chain = chain_hitting_levels(ground, less, targets)
    hts = height(ground, less)
    print(f"  chain meeting every level : {chain}")
    print(f"    is a genuine chain      : {is_chain(less, chain)}")
    hit = {hts[x] for x in chain}
    print(f"    meets every non-empty level: {hit == set(levels.keys())}")


def main() -> None:
    print("Aharoni–Korman property for well-founded FAC posets — numerical demo")

    g1, l1 = divisibility_poset(12)
    report("Divisibility order on {1,...,12}", g1, l1)

    g2, l2 = boolean_lattice(3)
    report("Boolean lattice B_3", g2, l2)

    # A chain: height climbs 0,1,2,3,4 and every level is a singleton antichain.
    g3 = ["a", "b", "c", "d", "e"]
    l3 = transitive_closure(g3, [("a", "b"), ("b", "c"), ("c", "d"), ("d", "e")])
    report("Linear chain a<b<c<d<e", g3, l3)

    # An antichain plus a top: {x,y,z} pairwise incomparable, all below t.
    g4 = ["x", "y", "z", "t"]
    l4 = transitive_closure(g4, [("x", "t"), ("y", "t"), ("z", "t")])
    report("Three-element antichain below a top (FAC, width 3)", g4, l4)


if __name__ == "__main__":
    main()
