"""
Tangled Hierarchies: numerical demonstrations of self-referential soundness
in Goedel-Loeb provability logic, worked out over finite and structured
Kripke frames.

A Goedel-Loeb (GL) frame is a set of worlds W with an accessibility relation R
that is (i) transitive and (ii) converse well-founded (no infinite ascending
R-chain). We represent a finite frame by, for each world w, the set succ(w) of
worlds v with R w v. The modalities are:

    box A     = { w : succ(w) subset of A }          "A is provable at w"
    diamond A = { w : succ(w) intersect A nonempty } "A is consistent with w"
    Con       = diamond(W) = { w : succ(w) nonempty } "w is consistent"

The results demonstrated here:
  * Semantic Loeb:            box(box A -> A) subset box A
  * Reflection at bottom:     (box {} -> {})  ==  Con
  * Godel II (semantic):      box Con subset box {}
  * Tangled hierarchy:        w in Con  =>  w not in box Con
  * Soundness -> consistency: (box {} -> {}) at w  =>  w in Con
  * Lawvere / Cantor:         negation has no fixed point => no surjective
                              self-encoding onto Bool-valued predicates

All functions are self-contained with type hints.
"""

from __future__ import annotations

from itertools import combinations
from typing import Callable, Dict, FrozenSet, List, Set, Tuple


# ---------------------------------------------------------------------------
# Finite Goedel-Loeb frames
# ---------------------------------------------------------------------------

Frame = Dict[int, Set[int]]  # world -> set of successors (worlds v with R w v)


def worlds(frame: Frame) -> Set[int]:
    """The set of all worlds of a finite frame."""
    return set(frame.keys())


def is_transitive(frame: Frame) -> bool:
    """Check R w v and R v u imply R w u for all worlds."""
    for w, succ_w in frame.items():
        for v in succ_w:
            if not frame.get(v, set()).issubset(succ_w):
                return False
    return True


def is_converse_well_founded(frame: Frame) -> bool:
    """
    Converse well-foundedness: no infinite ascending chain w0 R w1 R w2 ...
    On a finite frame this is equivalent to the relation being acyclic
    (irreflexive and containing no directed cycle).
    """
    # Detect any cycle reachable via R using DFS colouring.
    WHITE, GREY, BLACK = 0, 1, 2
    colour = {w: WHITE for w in frame}

    def dfs(w: int) -> bool:
        colour[w] = GREY
        for v in frame.get(w, set()):
            if colour.get(v, WHITE) == GREY:
                return False  # back-edge = cycle
            if colour.get(v, WHITE) == WHITE and not dfs(v):
                return False
        colour[w] = BLACK
        return True

    return all(colour[w] != WHITE or dfs(w) for w in frame)


def is_gl_frame(frame: Frame) -> bool:
    """A finite frame is a GL frame iff transitive and converse well-founded."""
    return is_transitive(frame) and is_converse_well_founded(frame)


# ---------------------------------------------------------------------------
# Modalities as operators on subsets of worlds
# ---------------------------------------------------------------------------

def box(frame: Frame, a: Set[int]) -> Set[int]:
    """box A = { w : every successor of w is in A }."""
    return {w for w in frame if frame[w].issubset(a)}


def diamond(frame: Frame, a: Set[int]) -> Set[int]:
    """diamond A = { w : some successor of w is in A }."""
    return {w for w in frame if frame[w] & a}


def consistency(frame: Frame) -> Set[int]:
    """Con = { w : w has a successor }."""
    return {w for w in frame if frame[w]}


def implication(frame: Frame, a: Set[int], b: Set[int]) -> Set[int]:
    """The property (A -> B) = (complement of A) union B."""
    return (worlds(frame) - a) | b


# ---------------------------------------------------------------------------
# Verifying the theorems on a given finite frame
# ---------------------------------------------------------------------------

def check_semantic_loeb(frame: Frame, a: Set[int]) -> bool:
    """box(box A -> A) subset box A."""
    lhs = box(frame, implication(frame, box(frame, a), a))
    return lhs.issubset(box(frame, a))


def check_reflection_is_consistency(frame: Frame) -> bool:
    """(box {} -> {}) equals Con."""
    refl = implication(frame, box(frame, set()), set())
    return refl == consistency(frame)


def check_godel_second(frame: Frame) -> bool:
    """box Con subset box {}."""
    return box(frame, consistency(frame)).issubset(box(frame, set()))


def check_tangled_hierarchy(frame: Frame) -> bool:
    """Every consistent world fails to prove its own consistency."""
    con = consistency(frame)
    box_con = box(frame, con)
    return all(w not in box_con for w in con)


def check_soundness_forces_consistency(frame: Frame) -> bool:
    """If (box {} -> {}) holds at w, then w in Con."""
    refl = implication(frame, box(frame, set()), set())
    con = consistency(frame)
    return all(w in con for w in refl)


# ---------------------------------------------------------------------------
# Enumerate all GL frames on a small world set and verify everything
# ---------------------------------------------------------------------------

def all_relations_on(n: int) -> List[Frame]:
    """Enumerate every binary relation on {0,...,n-1} as a frame."""
    pairs = [(a, b) for a in range(n) for b in range(n)]
    frames: List[Frame] = []
    for k in range(len(pairs) + 1):
        for chosen in combinations(pairs, k):
            frame: Frame = {w: set() for w in range(n)}
            for (a, b) in chosen:
                frame[a].add(b)
            frames.append(frame)
    return frames


def exhaustive_check(n: int) -> Tuple[int, int]:
    """
    Over all GL frames on n worlds, verify Loeb, Godel II, reflection,
    tangled hierarchy, and the soundness converse. Returns
    (number_of_gl_frames_checked, number_that_passed_all_checks).
    """
    checked = 0
    passed = 0
    for frame in all_relations_on(n):
        if not is_gl_frame(frame):
            continue
        checked += 1
        ok = (
            all(
                check_semantic_loeb(frame, set(a))
                for r in range(n + 1)
                for a in combinations(range(n), r)
            )
            and check_reflection_is_consistency(frame)
            and check_godel_second(frame)
            and check_tangled_hierarchy(frame)
            and check_soundness_forces_consistency(frame)
        )
        passed += int(ok)
    return checked, passed


# ---------------------------------------------------------------------------
# The canonical infinite frame: naturals with R a b <=> b < a (truncated)
# ---------------------------------------------------------------------------

def nat_frame(bound: int) -> Frame:
    """Naturals 0..bound-1 with R a b <=> b < a (a GL frame)."""
    return {a: set(range(a)) for a in range(bound)}


def iterated_box_bottom(frame: Frame, k: int) -> Set[int]:
    """box^k applied to the empty set."""
    current: Set[int] = set()
    for _ in range(k):
        current = box(frame, current)
    return current


def check_rank_identity(bound: int) -> bool:
    """
    On the natural-number frame, box^k {} = {0,1,...,k-1} (worlds of rank < k).
    """
    frame = nat_frame(bound)
    return all(
        iterated_box_bottom(frame, k) == set(range(min(k, bound)))
        for k in range(bound + 1)
    )


# ---------------------------------------------------------------------------
# Lawvere fixed-point / Cantor: no surjective self-encoding onto Bool
# ---------------------------------------------------------------------------

def anti_diagonal(f: List[List[bool]]) -> List[bool]:
    """
    Given an encoding f: A -> (A -> Bool) as an n x n boolean matrix
    (row a is the predicate f(a)), return the predicate
        d(a) = not f(a)(a)
    which by construction differs from every row f(a) at position a, hence
    is not in the range of f (Cantor's diagonal / Tarski undefinability).
    """
    return [not f[a][a] for a in range(len(f))]


def is_in_range(f: List[List[bool]], pred: List[bool]) -> bool:
    """Check whether the predicate `pred` equals some row f(a)."""
    return any(row == pred for row in f)


def negation_has_no_fixed_point() -> bool:
    """Boolean negation has no fixed point; the engine of Cantor/Tarski."""
    return all((not b) != b for b in (True, False))


# ---------------------------------------------------------------------------
# Demonstration driver
# ---------------------------------------------------------------------------

def main() -> None:
    print("=" * 70)
    print("TANGLED HIERARCHIES: self-referential soundness, numerically")
    print("=" * 70)

    print("\n[1] Exhaustive verification over all GL frames on 3 worlds")
    checked, passed = exhaustive_check(3)
    print(f"    GL frames found: {checked}")
    print(f"    frames passing Loeb, Godel II, reflection, tangling,")
    print(f"    and soundness-forces-consistency: {passed}")
    assert checked == passed and checked > 0
    print("    -> ALL GL frames satisfy every theorem.")

    print("\n[2] The canonical infinite frame (naturals under >), bound=8")
    frame = nat_frame(8)
    print(f"    is a GL frame: {is_gl_frame(frame)}")
    print(f"    Con (consistent worlds)   = {sorted(consistency(frame))}")
    print(f"    box(Con)                  = {sorted(box(frame, consistency(frame)))}")
    print(f"    box(empty) = box(bottom)  = {sorted(box(frame, set()))}")
    print("    Godel II  (box Con subset box bottom): "
          f"{check_godel_second(frame)}")
    print("    Tangled hierarchy (no live world in box Con): "
          f"{check_tangled_hierarchy(frame)}")

    print("\n[3] Rank identity  box^k(bottom) = {0,...,k-1}")
    for k in range(5):
        print(f"    box^{k}(bottom) = {sorted(iterated_box_bottom(frame, k))}")
    print(f"    identity holds up to bound: {check_rank_identity(8)}")

    print("\n[4] Lawvere / Cantor: no surjective self-encoding onto Bool")
    print(f"    negation has no fixed point: {negation_has_no_fixed_point()}")
    # A sample 3x3 encoding; the anti-diagonal escapes its range.
    f = [
        [True,  False, True],
        [False, False, True],
        [True,  True,  False],
    ]
    d = anti_diagonal(f)
    print(f"    sample encoding rows      = {f}")
    print(f"    anti-diagonal predicate   = {d}")
    print(f"    anti-diagonal in range(f) = {is_in_range(f, d)}  (must be False)")
    assert not is_in_range(f, d)
    print("    -> the diagonal predicate escapes any finite encoding.")

    print("\n" + "=" * 70)
    print("All demonstrations completed successfully.")
    print("=" * 70)


if __name__ == "__main__":
    main()
