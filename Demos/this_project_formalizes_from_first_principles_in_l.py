"""
The Topology of Symmetric Argumentation — numerical demonstrations.

This self-contained script demonstrates the main results of the accompanying
paper on Dung argumentation frameworks and their conflict-free complexes:

  * self-defense in symmetric frameworks (conflict-free = admissible),
  * preferred extensions = maximal conflict-free sets (facets),
  * grounded extension = unattacked arguments,
  * the Euler bridge chi(K(AF)) = #preferred = n for the complete conflict
    graph on n >= 1 arguments, and its failure at n = 0.

An argumentation framework is a pair (A, R) where A = {0, ..., n-1} is the set
of arguments and R is the attack relation, given here as a set of ordered pairs
(a, b) meaning "a attacks b".

Run:  python demo.py
"""

from __future__ import annotations

from itertools import combinations, chain
from typing import FrozenSet, Iterable, List, Set, Tuple

Argument = int
Attack = Tuple[Argument, Argument]
Relation = Set[Attack]


# --------------------------------------------------------------------------- #
# Core semantics
# --------------------------------------------------------------------------- #
def attacks(R: Relation, a: Argument, b: Argument) -> bool:
    """Return True iff argument `a` attacks argument `b`."""
    return (a, b) in R


def is_symmetric(R: Relation) -> bool:
    """Return True iff the attack relation is symmetric (mutual disagreement)."""
    return all((b, a) in R for (a, b) in R)


def is_conflict_free(R: Relation, S: FrozenSet[Argument]) -> bool:
    """A set is conflict-free if no member attacks another member."""
    return not any(attacks(R, a, b) for a in S for b in S)


def defends(R: Relation, S: FrozenSet[Argument], a: Argument) -> bool:
    """S defends a: every attacker b of a is counter-attacked by some c in S."""
    for b in {x for (x, y) in R if y == a}:
        if not any(attacks(R, c, b) for c in S):
            return False
    return True


def is_admissible(R: Relation, S: FrozenSet[Argument]) -> bool:
    """S is admissible: conflict-free and defends each of its members."""
    return is_conflict_free(R, S) and all(defends(R, S, a) for a in S)


def defense_operator(
    R: Relation, A: FrozenSet[Argument], S: FrozenSet[Argument]
) -> FrozenSet[Argument]:
    """The characteristic operator F(S) = { a in A : S defends a }."""
    return frozenset(a for a in A if defends(R, S, a))


def grounded_extension(R: Relation, A: FrozenSet[Argument]) -> FrozenSet[Argument]:
    """Least fixed point of the defense operator, reached by iteration from {}."""
    S: FrozenSet[Argument] = frozenset()
    while True:
        nxt = defense_operator(R, A, S)
        if nxt == S:
            return S
        S = nxt


def unattacked(R: Relation, A: FrozenSet[Argument]) -> FrozenSet[Argument]:
    """Arguments with no attacker: the isolated vertices of the conflict graph."""
    attacked = {b for (_a, b) in R}
    return frozenset(a for a in A if a not in attacked)


# --------------------------------------------------------------------------- #
# Complex, facets, Euler characteristic
# --------------------------------------------------------------------------- #
def powerset(A: Iterable[Argument]) -> Iterable[FrozenSet[Argument]]:
    """All subsets of A as frozensets."""
    xs = list(A)
    return (frozenset(c) for r in range(len(xs) + 1) for c in combinations(xs, r))


def conflict_free_complex(
    R: Relation, A: FrozenSet[Argument]
) -> List[FrozenSet[Argument]]:
    """All faces of K(AF): the conflict-free subsets of A."""
    return [S for S in powerset(A) if is_conflict_free(R, S)]


def maximal_conflict_free(
    R: Relation, A: FrozenSet[Argument]
) -> List[FrozenSet[Argument]]:
    """Facets of K(AF): the inclusion-maximal conflict-free sets."""
    faces = conflict_free_complex(R, A)
    return [S for S in faces if not any(S < T for T in faces)]


def preferred_extensions(
    R: Relation, A: FrozenSet[Argument]
) -> List[FrozenSet[Argument]]:
    """Maximal admissible sets, computed directly from the definition."""
    adm = [S for S in powerset(A) if is_admissible(R, S)]
    return [S for S in adm if not any(S < T for T in adm)]


def euler_characteristic(faces: List[FrozenSet[Argument]]) -> int:
    """chi = sum over nonempty faces of (-1)^(|s|-1) = f_0 - f_1 + f_2 - ..."""
    return sum((-1) ** (len(s) - 1) for s in faces if len(s) > 0)


# --------------------------------------------------------------------------- #
# The complete conflict graph
# --------------------------------------------------------------------------- #
def complete_conflict_graph(n: int) -> Tuple[FrozenSet[Argument], Relation]:
    """(A, R) on n arguments where every two distinct arguments attack."""
    A = frozenset(range(n))
    R = {(a, b) for a in range(n) for b in range(n) if a != b}
    return A, R


def fmt(S: FrozenSet[Argument]) -> str:
    return "{}" if not S else "{" + ",".join(str(x) for x in sorted(S)) + "}"


# --------------------------------------------------------------------------- #
# Demonstrations
# --------------------------------------------------------------------------- #
def demo_self_defense() -> None:
    print("=" * 70)
    print("1. Self-defense: in a symmetric framework, conflict-free = admissible")
    print("=" * 70)
    # Symmetric 4-cycle: 0-1-2-3-0 (mutual attacks along the cycle).
    A = frozenset(range(4))
    edges = [(0, 1), (1, 2), (2, 3), (3, 0)]
    R = {(a, b) for (a, b) in edges} | {(b, a) for (a, b) in edges}
    print(f"symmetric framework? {is_symmetric(R)}")
    ok = True
    for S in powerset(A):
        if is_conflict_free(R, S) and not is_admissible(R, S):
            ok = False
            print(f"  COUNTEREXAMPLE: {fmt(S)} is conflict-free but not admissible")
    print(f"every conflict-free set is admissible: {ok}")
    print()


def demo_facets() -> None:
    print("=" * 70)
    print("2. Preferred extensions = maximal conflict-free sets (facets)")
    print("=" * 70)
    A = frozenset(range(4))
    edges = [(0, 1), (1, 2), (2, 3), (3, 0)]
    R = {(a, b) for (a, b) in edges} | {(b, a) for (a, b) in edges}
    pref = sorted(preferred_extensions(R, A), key=lambda s: (len(s), sorted(s)))
    facets = sorted(maximal_conflict_free(R, A), key=lambda s: (len(s), sorted(s)))
    print("preferred extensions :", [fmt(s) for s in pref])
    print("facets of K(AF)      :", [fmt(s) for s in facets])
    print(f"they coincide        : {pref == facets}")
    print()


def demo_grounded() -> None:
    print("=" * 70)
    print("3. Grounded extension = unattacked arguments")
    print("=" * 70)
    # 0 unattacked; 1<->2 mutual; 3 attacked by nobody but attacks 1.
    A = frozenset(range(4))
    R = {(1, 2), (2, 1), (3, 1)}  # not symmetric on purpose for contrast...
    Rsym = R | {(1, 3)}  # ...make it symmetric
    print("symmetric framework? ", is_symmetric(Rsym))
    g = grounded_extension(Rsym, A)
    u = unattacked(Rsym, A)
    print(f"grounded extension   : {fmt(g)}")
    print(f"unattacked arguments : {fmt(u)}")
    print(f"they coincide        : {g == u}")
    print()


def demo_euler_bridge() -> None:
    print("=" * 70)
    print("4. Euler bridge: chi(K(AF)) = #preferred = n  for the complete graph")
    print("=" * 70)
    print(f"{'n':>3} | {'chi':>4} | {'#preferred':>10} | {'match':>5}")
    print("-" * 34)
    for n in range(0, 8):
        A, R = complete_conflict_graph(n)
        faces = conflict_free_complex(R, A)
        chi = euler_characteristic(faces)
        npref = len(preferred_extensions(R, A))
        match = "yes" if (n >= 1 and chi == npref == n) else (
            "N/A" if n == 0 else "no")
        note = "  <- sharp: chi=0 but #preferred=1" if n == 0 else ""
        print(f"{n:>3} | {chi:>4} | {npref:>10} | {match:>5}{note}")
    print()


def demo_naive_identity_fails() -> None:
    print("=" * 70)
    print("5. The naive identity chi = #preferred - #grounded is false")
    print("=" * 70)
    # One argument, no attacks: chi = 1, #preferred = 1, #grounded = 1.
    A = frozenset({0})
    R: Relation = set()
    faces = conflict_free_complex(R, A)
    chi = euler_characteristic(faces)
    npref = len(preferred_extensions(R, A))
    g = grounded_extension(R, A)
    print("single unattacked argument:")
    print(f"  chi = {chi}, #preferred = {npref}, #grounded (as a count) = 1")
    print(f"  naive RHS = #preferred - #grounded = {npref - 1}")
    print(f"  chi ({chi}) != naive RHS ({npref - 1}) : {chi != npref - 1}")
    print()


if __name__ == "__main__":
    demo_self_defense()
    demo_facets()
    demo_grounded()
    demo_euler_bridge()
    demo_naive_identity_fails()
    print("All demonstrations complete.")
