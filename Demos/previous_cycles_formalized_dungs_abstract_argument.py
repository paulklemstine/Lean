"""
demo.py — Numerical demonstration of the semantics of abstract argumentation
frameworks, and of the uniqueness theorem for well-founded frameworks.

An argumentation framework is a pair (A, R) where A is a finite set of arguments
and R is an attack relation: (a, b) in R means "a attacks b".

We compute, purely from the definitions:
  * the defense operator  F(S) = { a : S defends a }
  * the grounded extension  G = least fixed point of F  (Kleene iteration)
  * conflict-free / admissible / complete / stable / preferred extensions
    (by brute-force enumeration, used as ground truth)

and we numerically verify, on several frameworks, the theorems:
  * Stability  =>  Completeness            (all frameworks)
  * Grounded  =  intersection of all complete extensions   (all frameworks)
  * Well-founded (acyclic)  =>  unique complete extension, equal to the
    grounded = stable = preferred extension.

The module is self-contained: standard library only.
"""

from __future__ import annotations

from itertools import chain, combinations
from typing import FrozenSet, Iterable, List, Set, Tuple

Argument = str
Attack = Tuple[Argument, Argument]
Framework = Tuple[FrozenSet[Argument], FrozenSet[Attack]]


# ----------------------------------------------------------------------------
# Core semantic primitives
# ----------------------------------------------------------------------------

def attackers(af: Framework, a: Argument) -> Set[Argument]:
    """All arguments x with R(x, a)."""
    _, atk = af
    return {x for (x, y) in atk if y == a}


def conflict_free(af: Framework, s: Iterable[Argument]) -> bool:
    """No member of s attacks another member of s."""
    _, atk = af
    s = set(s)
    return all((a, b) not in atk for a in s for b in s)


def defends(af: Framework, s: Set[Argument], a: Argument) -> bool:
    """s defends a: every attacker b of a is counter-attacked by some c in s."""
    _, atk = af
    return all(any((c, b) in atk for c in s) for b in attackers(af, a))


def defense_operator(af: Framework, s: Set[Argument]) -> Set[Argument]:
    """F(S) = { a in A : S defends a }."""
    args, _ = af
    return {a for a in args if defends(af, s, a)}


def grounded_extension(af: Framework) -> FrozenSet[Argument]:
    """Least fixed point of F via Kleene iteration from the empty set.

    Since F is monotone and the empty set is below F(empty), the chain
    S_0 = {} ⊆ S_1 = F(S_0) ⊆ ... increases and stabilizes on a finite
    framework at the least fixed point = grounded extension.
    """
    s: Set[Argument] = set()
    while True:
        nxt = defense_operator(af, s)
        if nxt == s:
            return frozenset(s)
        s = nxt


def admissible(af: Framework, s: Set[Argument]) -> bool:
    """Conflict-free and defends each of its members."""
    return conflict_free(af, s) and all(defends(af, s, a) for a in s)


def complete(af: Framework, s: Set[Argument]) -> bool:
    """Admissible and closed under defense: F(S) ⊆ S."""
    return admissible(af, s) and defense_operator(af, s) <= set(s)


def stable(af: Framework, s: Set[Argument]) -> bool:
    """Conflict-free and attacks every argument outside s."""
    args, _ = af
    if not conflict_free(af, s):
        return False
    return all(any((b, a) in af[1] for b in s) for a in args - set(s))


# ----------------------------------------------------------------------------
# Enumeration (ground truth) and structural queries
# ----------------------------------------------------------------------------

def _subsets(args: Iterable[Argument]) -> Iterable[FrozenSet[Argument]]:
    args = list(args)
    return (frozenset(c) for c in chain.from_iterable(
        combinations(args, r) for r in range(len(args) + 1)))


def all_complete(af: Framework) -> List[FrozenSet[Argument]]:
    return [s for s in _subsets(af[0]) if complete(af, set(s))]


def all_stable(af: Framework) -> List[FrozenSet[Argument]]:
    return [s for s in _subsets(af[0]) if stable(af, set(s))]


def all_preferred(af: Framework) -> List[FrozenSet[Argument]]:
    """Maximal admissible sets under inclusion."""
    adm = [set(s) for s in _subsets(af[0]) if admissible(af, set(s))]
    return [frozenset(s) for s in adm
            if not any(s < t for t in adm)]


def is_well_founded(af: Framework) -> bool:
    """Finite: R well-founded iff the attack digraph is acyclic.

    Repeatedly delete arguments that currently have no incoming attack among
    the survivors; well-founded iff everything is eventually deleted.
    """
    args, atk = set(af[0]), set(af[1])
    changed = True
    while changed:
        changed = False
        no_incoming = {a for a in args
                       if not any((x, a) in atk for x in args)}
        if no_incoming:
            args -= no_incoming
            changed = True
    return len(args) == 0


def intersection(sets: Iterable[FrozenSet[Argument]],
                 universe: FrozenSet[Argument]) -> FrozenSet[Argument]:
    sets = list(sets)
    if not sets:
        return universe
    out = set(universe)
    for s in sets:
        out &= set(s)
    return frozenset(out)


# ----------------------------------------------------------------------------
# Demonstration driver
# ----------------------------------------------------------------------------

def analyze(name: str, af: Framework) -> None:
    args, atk = af
    print("=" * 70)
    print(f"Framework: {name}")
    print(f"  arguments : {sorted(args)}")
    print(f"  attacks   : {sorted(atk)}")
    wf = is_well_founded(af)
    print(f"  well-founded (acyclic)? {wf}")

    g = grounded_extension(af)
    comps = all_complete(af)
    stabs = all_stable(af)
    prefs = all_preferred(af)

    print(f"  grounded extension          : {set(sorted(g))}")
    print(f"  complete extensions ({len(comps)})       : "
          f"{[set(sorted(c)) for c in comps]}")
    print(f"  stable extensions ({len(stabs)})         : "
          f"{[set(sorted(s)) for s in stabs]}")
    print(f"  preferred extensions ({len(prefs)})      : "
          f"{[set(sorted(p)) for p in prefs]}")

    # Theorem: stability => completeness
    assert all(complete(af, set(s)) for s in stabs), \
        "stable extension failed to be complete"
    print("  [check] every stable extension is complete ......... OK")

    # Theorem: grounded = intersection of all complete extensions
    inter = intersection(comps, frozenset(args))
    assert inter == g, f"intersection {set(inter)} != grounded {set(g)}"
    print("  [check] grounded = intersection of complete exts ... OK")

    # Theorem: well-founded => unique complete extension = grounded = stable
    if wf:
        assert len(comps) == 1 and comps[0] == g, \
            "well-founded framework lacked a unique complete extension"
        assert stabs == [g], "grounded not the unique stable extension"
        assert prefs == [g], "grounded not the unique preferred extension"
        print("  [check] well-founded => unique complete = grounded = "
              "stable = preferred ... OK")


def main() -> None:
    frameworks = {
        "Well-founded chain  a->b->c": (
            frozenset({"a", "b", "c"}),
            frozenset({("a", "b"), ("b", "c")}),
        ),
        "Two-cycle  a<->b": (
            frozenset({"a", "b"}),
            frozenset({("a", "b"), ("b", "a")}),
        ),
        "Three-cycle  a->b->c->a": (
            frozenset({"a", "b", "c"}),
            frozenset({("a", "b"), ("b", "c"), ("c", "a")}),
        ),
        "Well-founded with defense + isolated node": (
            frozenset({"a", "b", "c", "d"}),
            frozenset({("a", "b"), ("b", "c")}),  # d isolated
        ),
        "Self-attacker (not well-founded)  a->a, a->b": (
            frozenset({"a", "b"}),
            frozenset({("a", "a"), ("a", "b")}),
        ),
    }
    for name, af in frameworks.items():
        analyze(name, af)
    print("=" * 70)
    print("All theorem checks passed on every framework above.")


if __name__ == "__main__":
    main()
