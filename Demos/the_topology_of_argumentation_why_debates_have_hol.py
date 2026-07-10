"""
The Topology of Argumentation --- numerical demonstrations.

This self-contained script implements Dung's abstract argumentation semantics
and the conflict-free simplicial complex K(AF), and numerically demonstrates the
main results of the accompanying paper:

  * conflict-free / admissible / preferred / complete / grounded extensions,
  * downward closure of conflict-free sets (K(AF) is a simplicial complex),
  * the (unreduced) Euler characteristic of K(AF),
  * the full simplex has Euler characteristic 1 (contractible),
  * refutation of the conjecture  chi(K) = #preferred - |grounded|,
  * the corrected correspondence for symmetric irreflexive frameworks
    (preferred extensions = maximal independent sets = facets of K(AF)).

An argumentation framework is a pair (A, R):
    A : the arguments, encoded as range(n),
    R : the attack relation, a set of ordered pairs (a, b) meaning "a attacks b".

No third-party dependencies are required.
"""

from __future__ import annotations

from itertools import combinations, chain
from typing import FrozenSet, Iterable, List, Set, Tuple

Arg = int
Attack = Tuple[Arg, Arg]
Relation = Set[Attack]
Extension = FrozenSet[Arg]


# --------------------------------------------------------------------------- #
# Core Dung semantics
# --------------------------------------------------------------------------- #
def powerset(args: Iterable[Arg]) -> List[Extension]:
    """All subsets of `args`, returned as frozensets."""
    items = list(args)
    return [
        frozenset(c)
        for c in chain.from_iterable(combinations(items, k) for k in range(len(items) + 1))
    ]


def is_conflict_free(s: Extension, r: Relation) -> bool:
    """No member of s attacks another member of s."""
    return not any((a, b) in r for a in s for b in s)


def defends(s: Extension, a: Arg, r: Relation) -> bool:
    """s defends a: every attacker b of a is counter-attacked by some c in s."""
    attackers = [b for (b, target) in r if target == a]
    return all(any((c, b) in r for c in s) for b in attackers)


def defense_operator(s: Extension, args: Iterable[Arg], r: Relation) -> Extension:
    """F(s): the set of all arguments defended by s."""
    return frozenset(a for a in args if defends(s, a, r))


def is_admissible(s: Extension, r: Relation) -> bool:
    """Conflict-free and defends each of its members (s subset of F(s))."""
    return is_conflict_free(s, r) and all(defends(s, a, r) for a in s)


def is_complete(s: Extension, args: Iterable[Arg], r: Relation) -> bool:
    """Admissible and closed under defense: F(s) subset of s."""
    return is_admissible(s, r) and defense_operator(s, args, r) <= s


def preferred_extensions(args: Iterable[Arg], r: Relation) -> List[Extension]:
    """Maximal admissible sets."""
    args = list(args)
    adm = [s for s in powerset(args) if is_admissible(s, r)]
    return [s for s in adm if not any(s < t for t in adm)]


def grounded_extension(args: Iterable[Arg], r: Relation) -> Extension:
    """Least fixed point of the defense operator, via Kleene iteration from empty."""
    args = list(args)
    current: Extension = frozenset()
    while True:
        nxt = defense_operator(current, args, r)
        # The grounded extension is the least fixed point reached from below;
        # iterate the monotone operator until stabilization.
        if nxt == current:
            return current
        current = nxt if current <= nxt else current | nxt


# --------------------------------------------------------------------------- #
# The conflict-free complex K(AF) and its Euler characteristic
# --------------------------------------------------------------------------- #
def conflict_free_complex(args: Iterable[Arg], r: Relation) -> List[Extension]:
    """The faces of K(AF): all conflict-free subsets of the arguments."""
    return [s for s in powerset(args) if is_conflict_free(s, r)]


def is_downward_closed(faces: List[Extension]) -> bool:
    """Verify the defining axiom of a simplicial complex: subsets of faces are faces."""
    face_set = set(faces)
    return all(frozenset(sub) in face_set for f in faces for sub in powerset(f))


def euler_characteristic(faces: List[Extension]) -> int:
    """Unreduced Euler characteristic: sum over nonempty faces of (-1)^(|s|-1)."""
    return sum((-1) ** (len(s) - 1) for s in faces if len(s) > 0)


# --------------------------------------------------------------------------- #
# Demonstrations
# --------------------------------------------------------------------------- #
def describe(name: str, args: List[Arg], r: Relation) -> None:
    faces = conflict_free_complex(args, r)
    chi = euler_characteristic(faces)
    pref = preferred_extensions(args, r)
    grnd = grounded_extension(args, r)
    print(f"=== {name} ===")
    print(f"  arguments : {args}")
    print(f"  attacks   : {sorted(r)}")
    print(f"  K(AF) is downward closed (a simplicial complex): {is_downward_closed(faces)}")
    print(f"  #faces of K(AF)          : {len(faces)}")
    print(f"  Euler characteristic chi : {chi}")
    print(f"  preferred extensions     : {[sorted(p) for p in pref]}  (count {len(pref)})")
    print(f"  grounded extension       : {sorted(grnd)}  (size {len(grnd)})")
    rhs = len(pref) - len(grnd)
    print(f"  conjecture RHS #pref-|grnd| : {rhs}   ->  chi == RHS ? {chi == rhs}")
    print()


def main() -> None:
    # 1. The refuting witness: a single argument attacking nothing.
    describe("R0: single argument, no attacks (REFUTES the conjecture)", [0], set())

    # 2. Two mutually attacking arguments  0 <-> 1  (symmetric, irreflexive).
    describe("Two-cycle 0<->1 (symmetric)", [0, 1], {(0, 1), (1, 0)})

    # 3. Three-cycle  0->1->2->0  (a 'circular disagreement').
    describe("Odd cycle 0->1->2->0", [0, 1, 2], {(0, 1), (1, 2), (2, 0)})

    # 4. A defended argument: 0 attacks 1, 2 attacks 0  (grounded = {1,2}).
    describe("Chain 2->0->1", [0, 1, 2], {(0, 1), (2, 0)})

    # 5. Complete conflict graph on n vertices (symmetric): chi = n = #preferred.
    for n in (2, 3, 4):
        args = list(range(n))
        r = {(a, b) for a in args for b in args if a != b}
        faces = conflict_free_complex(args, r)
        chi = euler_characteristic(faces)
        pref = preferred_extensions(args, r)
        assert chi == n == len(pref), (n, chi, len(pref))
        print(f"Complete conflict graph K_{n}: chi = {chi} = #preferred = {len(pref)}  (verified)")
    print()

    # 6. Full simplex (no attacks at all) on n vertices: chi = 1 (contractible).
    for n in (1, 2, 3, 4, 5):
        args = list(range(n))
        faces = conflict_free_complex(args, set())
        chi = euler_characteristic(faces)
        assert chi == 1, (n, chi)
        print(f"Attack-free framework on {n} arguments: full simplex, chi = {chi}  (verified)")
    print()

    # 7. Symmetric correspondence: preferred = maximal independent sets = facets.
    args = [0, 1, 2, 3]
    r = {(0, 1), (1, 0), (1, 2), (2, 1), (2, 3), (3, 2)}  # path graph 0-1-2-3
    faces = conflict_free_complex(args, r)
    pref = {frozenset(p) for p in preferred_extensions(args, r)}
    facets = {f for f in faces if not any(f < g for g in faces)}
    print("Path graph 0-1-2-3 (symmetric):")
    print(f"  preferred extensions : {sorted(sorted(p) for p in pref)}")
    print(f"  facets of K(AF)      : {sorted(sorted(f) for f in facets)}")
    print(f"  preferred == facets  : {pref == facets}")


if __name__ == "__main__":
    main()
