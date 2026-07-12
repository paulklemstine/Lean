"""
Numerical demonstrations for
"Stable Extensions in Abstract Argumentation:
 The Semantic Hierarchy, the Symmetric Collapse, and an Euler Correspondence".

An abstract argumentation framework is a finite set of arguments together with an
attack relation.  This module implements, from scratch and with type hints, the
core semantic notions -- conflict-free, admissible, complete, preferred, maximal
conflict-free (facet), stable, grounded -- and verifies the paper's main results
on concrete frameworks, culminating in the stable/Euler bridge for the complete
conflict graph.

Run:  python demo.py
"""

from __future__ import annotations

from itertools import combinations, chain
from typing import Callable, FrozenSet, List, Set, Tuple

# An argument is an int; a framework is (arguments, attack-predicate).
Argument = int
Attack = Callable[[Argument, Argument], bool]
Extension = FrozenSet[Argument]


# --------------------------------------------------------------------------- #
# Core Dung semantics
# --------------------------------------------------------------------------- #
def powerset(args: List[Argument]) -> List[Extension]:
    """All subsets of the argument set, as frozensets."""
    return [
        frozenset(c)
        for r in range(len(args) + 1)
        for c in combinations(args, r)
    ]


def conflict_free(args: List[Argument], R: Attack, S: Extension) -> bool:
    """No member of S attacks another member of S."""
    return not any(R(a, b) for a in S for b in S)


def defends_in(args: List[Argument], R: Attack, S: Extension, a: Argument) -> bool:
    """S defends a, ranging attackers over the explicit argument universe."""
    attackers = [b for b in args if R(b, a)]
    return all(any(R(c, b) for c in S) for b in attackers)


def admissible(args: List[Argument], R: Attack, S: Extension) -> bool:
    """Conflict-free and defends each of its members."""
    return conflict_free(args, R, S) and all(defends_in(args, R, S, a) for a in S)


def char_F(args: List[Argument], R: Attack, S: Extension) -> Extension:
    """Characteristic (defense) operator: all arguments S defends."""
    return frozenset(a for a in args if defends_in(args, R, S, a))


def complete(args: List[Argument], R: Attack, S: Extension) -> bool:
    """Admissible and closed under defense."""
    return admissible(args, R, S) and char_F(args, R, S) <= S


def preferred(args: List[Argument], R: Attack, S: Extension) -> bool:
    """Maximal admissible set."""
    if not admissible(args, R, S):
        return False
    return all(
        (not (S < T)) or (not admissible(args, R, T))
        for T in powerset(args)
    )


def maximal_conflict_free(args: List[Argument], R: Attack, S: Extension) -> bool:
    """Facet of the coexistence complex: maximal conflict-free set."""
    if not conflict_free(args, R, S):
        return False
    return all(
        (not (S < T)) or (not conflict_free(args, R, T))
        for T in powerset(args)
    )


def stable(args: List[Argument], R: Attack, S: Extension) -> bool:
    """Conflict-free and attacks every argument it does not contain."""
    if not conflict_free(args, R, S):
        return False
    return all(any(R(b, a) for b in S) for a in args if a not in S)


def grounded(args: List[Argument], R: Attack) -> Extension:
    """Least fixed point of the defense operator, by ascending iteration."""
    S: Extension = frozenset()
    while True:
        nxt = char_F(args, R, S)
        if nxt == S:
            return S
        S = nxt


def euler_characteristic(args: List[Argument], R: Attack) -> int:
    """Alternating sum (-1)^(|s|-1) over nonempty conflict-free faces."""
    total = 0
    for s in powerset(args):
        if s and conflict_free(args, R, s):
            total += (-1) ** (len(s) - 1)
    return total


# --------------------------------------------------------------------------- #
# Framework constructors
# --------------------------------------------------------------------------- #
def complete_conflict_graph(n: int) -> Tuple[List[Argument], Attack]:
    """Every two distinct arguments attack each other (symmetric, irreflexive)."""
    args = list(range(n))
    return args, (lambda a, b: a != b)


def framework_from_edges(
    n: int, edges: Set[Tuple[Argument, Argument]]
) -> Tuple[List[Argument], Attack]:
    """Build a framework whose attack relation is the given set of ordered pairs."""
    args = list(range(n))
    eset = set(edges)
    return args, (lambda a, b: (a, b) in eset)


def symmetric_closure(edges: Set[Tuple[int, int]]) -> Set[Tuple[int, int]]:
    return set(edges) | {(b, a) for (a, b) in edges}


# --------------------------------------------------------------------------- #
# Demonstrations
# --------------------------------------------------------------------------- #
def fmt(S: Extension) -> str:
    return "{" + ",".join(map(str, sorted(S))) + "}" if S else "{}"


def demo_hierarchy() -> None:
    print("=" * 70)
    print("DEMO 1: The stable hierarchy on a general (non-symmetric) framework")
    print("=" * 70)
    # 0 -> 1 -> 2 -> 3, plus 2 -> 1 (a reinstatement chain).
    args, R = framework_from_edges(4, {(0, 1), (1, 2), (2, 3), (2, 1)})
    print("Arguments 0,1,2,3 with attacks 0->1, 1->2, 2->3, 2->1")
    for S in powerset(args):
        if stable(args, R, S):
            print(f"  Stable set {fmt(S)}:")
            print(f"    admissible? {admissible(args, R, S)}"
                  f"  complete? {complete(args, R, S)}"
                  f"  preferred? {preferred(args, R, S)}"
                  f"  facet? {maximal_conflict_free(args, R, S)}")
            assert admissible(args, R, S)
            assert complete(args, R, S)
            assert preferred(args, R, S)
            assert maximal_conflict_free(args, R, S)
    print("  Verified: every stable set is preferred/complete/admissible/facet.")


def demo_grounded_below_stable() -> None:
    print("=" * 70)
    print("DEMO 2: The grounded extension lies below every stable extension")
    print("=" * 70)
    args, R = framework_from_edges(4, {(0, 1), (1, 0), (1, 2), (2, 3), (3, 2)})
    G = grounded(args, R)
    print(f"Grounded (skeptical) extension: {fmt(G)}")
    stables = [S for S in powerset(args) if stable(args, R, S)]
    for S in stables:
        print(f"  Stable {fmt(S)} contains grounded? {G <= S}")
        assert G <= S
    print("  Verified: grounded ⊆ every stable extension.")


def demo_symmetric_collapse() -> None:
    print("=" * 70)
    print("DEMO 3: The symmetric collapse  stable = preferred = facet")
    print("=" * 70)
    edges = symmetric_closure({(0, 1), (1, 2), (0, 3), (2, 3)})  # a 4-cycle
    args, R = framework_from_edges(4, edges)
    print("Symmetric irreflexive 4-cycle 0-1-2-3-0")
    for S in powerset(args):
        st, pr, fa = (stable(args, R, S),
                      preferred(args, R, S),
                      maximal_conflict_free(args, R, S))
        assert st == pr == fa
        if st:
            print(f"  {fmt(S)} is stable = preferred = facet")
    print("  Verified: the three notions coincide on every subset.")


def demo_euler_bridge() -> None:
    print("=" * 70)
    print("DEMO 4: The stable Euler bridge on the complete conflict graph")
    print("=" * 70)
    print(f"{'n':>3} | {'#stable':>8} | {'chi(K)':>7} | equal?")
    print("-" * 34)
    for n in range(1, 8):
        args, R = complete_conflict_graph(n)
        n_stable = sum(1 for S in powerset(args) if stable(args, R, S))
        chi = euler_characteristic(args, R)
        print(f"{n:>3} | {n_stable:>8} | {chi:>7} | {n_stable == chi == n}")
        assert n_stable == chi == n
    print("  Verified: #{stable extensions} = chi(K(AF)) = n.")


def main() -> None:
    demo_hierarchy()
    print()
    demo_grounded_below_stable()
    print()
    demo_symmetric_collapse()
    print()
    demo_euler_bridge()
    print()
    print("All demonstrations passed.")


if __name__ == "__main__":
    main()
