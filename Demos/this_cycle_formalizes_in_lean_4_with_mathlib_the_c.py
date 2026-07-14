"""
Numerical demonstrations for
"The Modal Logic and Alexandrov Topology of the Forcing Multiverse".

Self-contained. Run with:  python3 demo.py

Contents
--------
1. Independence census over n atoms: branches (2^n), sentences (2^(2^n)),
   settled sentences (always 2), independent sentences (2^(2^n) - 2), and the
   ratio 1 - 2^(1 - 2^n) tending to 1.
2. Frame-condition checker: reflexive / transitive / symmetric / euclidean /
   directed, and the induced modal axioms T, 4, B, 5, .2, with detection of the
   S4.2-but-not-S5 signature.  Includes the (Nat, <=) miniature multiverse.
3. Alexandrov topology tools: upper-set test, interior = box, closure = dia,
   button = open, settled = clopen.
"""

from __future__ import annotations

from itertools import product
from typing import Callable, FrozenSet, List, Set, Tuple

# ---------------------------------------------------------------------------
# 1. Independence census
# ---------------------------------------------------------------------------

def num_branches(n: int) -> int:
    """Number of branches (worlds) over n atoms: 2^n."""
    return 2 ** n


def num_sentences(n: int) -> int:
    """Number of sentences (Boolean functions of branches): 2^(2^n)."""
    return 2 ** (2 ** n)


def num_settled(n: int) -> int:
    """Number of settled (constant) sentences: always exactly 2."""
    return 2


def num_independent(n: int) -> int:
    """Number of independent (non-constant) sentences: 2^(2^n) - 2."""
    return num_sentences(n) - num_settled(n)


def independent_ratio(n: int) -> float:
    """Proportion of independent sentences = 1 - 2 / 2^(2^n)."""
    return num_independent(n) / num_sentences(n)


def independence_census(max_n: int = 5) -> None:
    print("=" * 68)
    print("INDEPENDENCE CENSUS  (independence is generic)")
    print("=" * 68)
    print(f"{'n':>2} | {'branches':>10} | {'sentences':>22} | {'independent':>22} | ratio")
    print("-" * 90)
    for n in range(max_n + 1):
        b = num_branches(n)
        s = num_sentences(n)
        ind = num_independent(n)
        r = independent_ratio(n)
        print(f"{n:>2} | {b:>10} | {s:>22} | {ind:>22} | {r:.12f}")
    print("\nThe ratio -> 1: undecidability is the typical case.\n")


def classify_sentence(table: Tuple[bool, ...]) -> str:
    """Classify a sentence given as its truth table over all branches."""
    if all(table) or not any(table):
        return "settled"
    return "independent"


def brute_force_check(n: int) -> None:
    """Brute-force verify the counts by enumeration (small n only)."""
    branches = list(product([False, True], repeat=n))
    m = len(branches)  # 2^n
    settled = 0
    independent = 0
    for bits in product([False, True], repeat=m):
        if classify_sentence(bits) == "settled":
            settled += 1
        else:
            independent += 1
    print(f"[brute force n={n}] branches={m}, "
          f"settled={settled} (formula 2), "
          f"independent={independent} (formula {num_independent(n)})")
    assert settled == num_settled(n)
    assert independent == num_independent(n)


# ---------------------------------------------------------------------------
# 2. Frame-condition checker
# ---------------------------------------------------------------------------

Relation = Callable[[int, int], bool]


def is_reflexive(worlds: List[int], R: Relation) -> bool:
    return all(R(w, w) for w in worlds)


def is_transitive(worlds: List[int], R: Relation) -> bool:
    return all(
        (not (R(a, b) and R(b, c))) or R(a, c)
        for a in worlds for b in worlds for c in worlds
    )


def is_symmetric(worlds: List[int], R: Relation) -> bool:
    return all((not R(a, b)) or R(b, a) for a in worlds for b in worlds)


def is_euclidean(worlds: List[int], R: Relation) -> bool:
    return all(
        (not (R(a, b) and R(a, c))) or R(b, c)
        for a in worlds for b in worlds for c in worlds
    )


def is_directed(worlds: List[int], R: Relation) -> bool:
    for a in worlds:
        for b in worlds:
            for c in worlds:
                if R(a, b) and R(a, c):
                    if not any(R(b, t) and R(c, t) for t in worlds):
                        return False
    return True


def modal_profile(worlds: List[int], R: Relation) -> dict:
    """Which frame conditions and modal axioms hold."""
    refl = is_reflexive(worlds, R)
    trans = is_transitive(worlds, R)
    sym = is_symmetric(worlds, R)
    eucl = is_euclidean(worlds, R)
    direct = is_directed(worlds, R)
    axioms = {
        "T  (box p -> p)":        refl,
        "4  (box p -> box box p)": trans,
        "B  (p -> box dia p)":     sym,
        "5  (dia p -> box dia p)": eucl,
        ".2 (dia box p -> box dia p)": direct,
    }
    is_s42 = refl and trans and direct
    is_s5 = refl and trans and sym  # S5 = S4 + B
    return {
        "reflexive": refl, "transitive": trans, "symmetric": sym,
        "euclidean": eucl, "directed": direct, "axioms": axioms,
        "is_S4.2": is_s42, "is_S5": is_s5,
        "S4.2_not_S5": is_s42 and not is_s5,
    }


def frame_demo() -> None:
    print("=" * 68)
    print("FRAME-CONDITION CHECKER  (the S4.2 vs S5 separation)")
    print("=" * 68)
    worlds = list(range(4))  # miniature multiverse {0,1,2,3}
    R = lambda a, b: a <= b  # the (Nat, <=) forcing order
    prof = modal_profile(worlds, R)
    print("Frame: ({0,1,2,3}, <=)   -- the directed extension order")
    for name, holds in prof["axioms"].items():
        print(f"   axiom {name:<28} : {'HOLDS' if holds else 'FAILS'}")
    print(f"   -> is S4.2:        {prof['is_S4.2']}")
    print(f"   -> is S5:          {prof['is_S5']}")
    print(f"   -> S4.2 but NOT S5: {prof['S4.2_not_S5']}")
    print("The failure of symmetry (B) drops S5 to the forcing logic S4.2.\n")


# ---------------------------------------------------------------------------
# 3. Alexandrov topology tools
# ---------------------------------------------------------------------------

def is_upper_set(worlds: List[int], R: Relation, S: Set[int]) -> bool:
    """S is open (a button) iff it is upward closed under R."""
    return all((w not in S) or (v in S)
               for w in worlds for v in worlds if R(w, v))


def box(worlds: List[int], R: Relation, S: Set[int]) -> Set[int]:
    """Necessity / interior: {w | forall v, R w v -> v in S}."""
    return {w for w in worlds if all((not R(w, v)) or (v in S) for v in worlds)}


def dia(worlds: List[int], R: Relation, S: Set[int]) -> Set[int]:
    """Possibility / closure: {w | exists v, R w v and v in S}."""
    return {w for w in worlds if any(R(w, v) and (v in S) for v in worlds)}


def is_settled(worlds: List[int], R: Relation, S: Set[int]) -> bool:
    """Settled / clopen: truth value invariant along R in both directions."""
    return all(((w in S) == (v in S))
               for w in worlds for v in worlds if R(w, v))


def topology_demo() -> None:
    print("=" * 68)
    print("ALEXANDROV TOPOLOGY  (box = interior, dia = closure)")
    print("=" * 68)
    worlds = list(range(4))
    R = lambda a, b: a <= b
    S = {1, 2}
    print(f"Frame ({worlds}, <=),  S = {S}")
    print(f"   box S (interior) = {sorted(box(worlds, R, S))}")
    print(f"   dia S (closure)  = {sorted(dia(worlds, R, S))}")
    # box S is the largest upper set inside S; check it is a button:
    bS = box(worlds, R, S)
    print(f"   box S is an upper set (button): {is_upper_set(worlds, R, bS)}")
    # A genuinely settled assertion in this frame is only {} or all worlds:
    for T in [set(), {0, 1, 2, 3}, {2, 3}, {0}]:
        print(f"   S={T!s:<14} settled(clopen)? {is_settled(worlds, R, T)}")
    print("Only the two constants are clopen: the settled assertions are exactly")
    print("emptyset and the whole space (the topological face of card_settled = 2).\n")


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main() -> None:
    independence_census(max_n=5)
    for n in range(0, 4):
        brute_force_check(n)
    print()
    frame_demo()
    topology_demo()


if __name__ == "__main__":
    main()
