"""
Numerical demonstrations for:

    The Existence Gap for Stable Extensions in Abstract Argumentation

An argumentation framework is a pair (A, R) where A is a finite set of arguments
and R is an attack relation.  We represent A as range(n) and R as a callable
attack(a, b) that returns True iff argument a attacks argument b.

This script enumerates all subsets of A and classifies them under the classical
Dung semantics (conflict-free, admissible, preferred, maximal conflict-free,
stable), then reproduces every result of the paper:

  * C1 (disproved): the directed 3-cycle has NO stable extension.
  * C2 (disproved): the empty set is preferred but not stable in the 3-cycle.
  * C3 (proved):    every finite symmetric irreflexive framework has a stable
                    extension (verified over random symmetric irreflexive AFs).
  * C4 (disproved): a symmetric framework with a self-attack has NO stable
                    extension.

Run:  python demo.py
"""

from __future__ import annotations

from itertools import combinations
from typing import Callable, FrozenSet, List, Tuple
import random

Attack = Callable[[int, int], bool]


# --------------------------------------------------------------------------- #
# Enumeration helpers
# --------------------------------------------------------------------------- #
def all_subsets(n: int) -> List[FrozenSet[int]]:
    """Return every subset of {0, ..., n-1} as a frozenset."""
    subsets: List[FrozenSet[int]] = []
    for k in range(n + 1):
        for combo in combinations(range(n), k):
            subsets.append(frozenset(combo))
    return subsets


# --------------------------------------------------------------------------- #
# Dung semantics
# --------------------------------------------------------------------------- #
def is_conflict_free(n: int, attack: Attack, S: FrozenSet[int]) -> bool:
    """No member of S attacks another member of S."""
    return all(not attack(a, b) for a in S for b in S)


def defends(n: int, attack: Attack, S: FrozenSet[int], a: int) -> bool:
    """Every attacker b of a is counter-attacked by some c in S."""
    for b in range(n):
        if attack(b, a) and not any(attack(c, b) for c in S):
            return False
    return True


def is_admissible(n: int, attack: Attack, S: FrozenSet[int]) -> bool:
    """Conflict-free and defends all its members."""
    return is_conflict_free(n, attack, S) and all(
        defends(n, attack, S, a) for a in S
    )


def is_stable(n: int, attack: Attack, S: FrozenSet[int]) -> bool:
    """Conflict-free and attacks every argument outside S."""
    if not is_conflict_free(n, attack, S):
        return False
    return all(any(attack(b, a) for b in S) for a in range(n) if a not in S)


def is_maximal_conflict_free(n: int, attack: Attack, S: FrozenSet[int]) -> bool:
    """Conflict-free and inclusion-maximal among conflict-free sets."""
    if not is_conflict_free(n, attack, S):
        return False
    for a in range(n):
        if a not in S and is_conflict_free(n, attack, S | {a}):
            return False
    return True


def preferred_extensions(n: int, attack: Attack) -> List[FrozenSet[int]]:
    """All maximal admissible sets."""
    adm = [S for S in all_subsets(n) if is_admissible(n, attack, S)]
    result: List[FrozenSet[int]] = []
    for S in adm:
        if not any(S < T for T in adm):  # S is not properly contained in any admissible T
            result.append(S)
    return result


def stable_extensions(n: int, attack: Attack) -> List[FrozenSet[int]]:
    """All stable extensions."""
    return [S for S in all_subsets(n) if is_stable(n, attack, S)]


# --------------------------------------------------------------------------- #
# Concrete frameworks
# --------------------------------------------------------------------------- #
def cycle3(a: int, b: int) -> bool:
    """Directed 3-cycle 0 -> 1 -> 2 -> 0 on {0,1,2}:  a attacks b iff b == a+1 mod 3."""
    return b == (a + 1) % 3


def complete_conflict(a: int, b: int) -> bool:
    """Complete conflict graph: everyone attacks everyone else, no self-attack."""
    return a != b


def refl_self_attack(a: int, b: int) -> bool:
    """Single argument (n=1) that attacks itself: symmetric but reflexive."""
    return True


def is_symmetric(n: int, attack: Attack) -> bool:
    return all(attack(a, b) == attack(b, a) for a in range(n) for b in range(n))


def is_irreflexive(n: int, attack: Attack) -> bool:
    return all(not attack(a, a) for a in range(n))


def random_symmetric_irreflexive(n: int, p: float, rng: random.Random) -> Attack:
    """A random undirected loopless conflict graph as an attack relation."""
    edges = {
        frozenset((a, b))
        for a in range(n)
        for b in range(n)
        if a < b and rng.random() < p
    }

    def attack(a: int, b: int) -> bool:
        return a != b and frozenset((a, b)) in edges

    return attack


# --------------------------------------------------------------------------- #
# Demonstrations
# --------------------------------------------------------------------------- #
def demo_c1_and_c2() -> None:
    print("=" * 70)
    print("C1 / C2 : the directed 3-cycle  0 -> 1 -> 2 -> 0")
    print("=" * 70)
    n = 3
    print(f"symmetric?   {is_symmetric(n, cycle3)}   (expected False)")
    print(f"irreflexive? {is_irreflexive(n, cycle3)}   (expected True)")

    stab = stable_extensions(n, cycle3)
    pref = preferred_extensions(n, cycle3)
    print(f"\nstable extensions   : {[set(s) for s in stab]}  -> count = {len(stab)}")
    print(f"preferred extensions: {[set(s) for s in pref]}")
    assert len(stab) == 0, "C1: 3-cycle should have NO stable extension"
    assert frozenset() in pref, "C2: empty set should be preferred"
    assert not is_stable(n, cycle3, frozenset()), "C2: empty set is not stable"
    print("\nC1 DISPROVED: 3-cycle has 0 stable extensions.")
    print("C2 DISPROVED: empty set is preferred but not stable "
          "=> stable is a STRICT subset of preferred.")


def demo_complete_conflict(n: int = 4) -> None:
    print("\n" + "=" * 70)
    print(f"Contrast: complete conflict graph on n = {n} arguments")
    print("=" * 70)
    stab = stable_extensions(n, complete_conflict)
    mcf = [S for S in all_subsets(n) if is_maximal_conflict_free(n, complete_conflict, S)]
    # Euler characteristic of the conflict-free complex:
    #   chi = sum over nonempty faces of (-1)^(|face|-1)
    faces = [S for S in all_subsets(n) if is_conflict_free(n, complete_conflict, S) and S]
    chi = sum((-1) ** (len(S) - 1) for S in faces)
    print(f"stable extensions : {[set(s) for s in stab]}  -> count = {len(stab)}")
    print(f"facets (maximal CF): {[set(s) for s in mcf]}")
    print(f"Euler characteristic chi(K(AF)) = {chi}")
    assert len(stab) == n, "stable count should equal n"
    assert chi == n, "Euler characteristic should equal n"
    print(f"Confirmed: #stable = chi(K(AF)) = n = {n}.")


def demo_c3(trials: int = 500, max_n: int = 7) -> None:
    print("\n" + "=" * 70)
    print("C3 : every finite symmetric irreflexive framework has a stable extension")
    print("=" * 70)
    rng = random.Random(2026)
    ok = True
    for _ in range(trials):
        n = rng.randint(1, max_n)
        attack = random_symmetric_irreflexive(n, rng.random(), rng)
        stab = stable_extensions(n, attack)
        mcf = [S for S in all_subsets(n) if is_maximal_conflict_free(n, attack, S)]
        # every maximal conflict-free set is stable, and at least one exists
        if len(stab) == 0 or set(map(tuple, map(sorted, stab))) != set(
            map(tuple, map(sorted, mcf))
        ):
            ok = False
            break
    print(f"tested {trials} random symmetric irreflexive frameworks (n up to {max_n})")
    print(f"all had >= 1 stable extension, and stable == maximal-conflict-free: {ok}")
    assert ok, "C3: existence / equivalence failed"
    print("C3 PROVED (empirically confirmed): existence guaranteed; "
          "stable = maximal conflict-free (independent sets).")


def demo_c4() -> None:
    print("\n" + "=" * 70)
    print("C4 : symmetry alone does NOT suffice (self-attack destroys existence)")
    print("=" * 70)
    n = 1
    print(f"symmetric?   {is_symmetric(n, refl_self_attack)}   (expected True)")
    print(f"irreflexive? {is_irreflexive(n, refl_self_attack)}   (expected False)")
    stab = stable_extensions(n, refl_self_attack)
    print(f"stable extensions: {[set(s) for s in stab]}  -> count = {len(stab)}")
    assert len(stab) == 0, "C4: self-attack framework should have NO stable extension"
    print("C4 DISPROVED: symmetric but reflexive => 0 stable extensions. "
          "Irreflexivity is necessary.")


def main() -> None:
    demo_c1_and_c2()
    demo_complete_conflict()
    demo_c3()
    demo_c4()
    print("\n" + "=" * 70)
    print("All four conjectures reproduced numerically.")
    print("=" * 70)


if __name__ == "__main__":
    main()
