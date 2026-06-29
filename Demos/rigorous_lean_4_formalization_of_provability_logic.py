"""
Numerical demonstrations for:

    Polymodal Provability, Ordinal Ranks, and the Category of Gödel-Löb Frames

This is a self-contained, dependency-free Python illustration of the semantic
results formalized in the accompanying Lean development. We represent finite
GL frames explicitly (worlds + accessibility relation) and compute, with the
plain definitions, the box/diamond operators, the ordinal rank, semantic Löb,
the polymodal (GLP) levels, and the synchronized product.

A GL frame is a *finite, irreflexive, transitive* directed graph: an arrow
w -> v means "v is accessible from w" (read: v is a hypothetical/stronger
extension that w can see).

Run:  python demo.py
"""

from __future__ import annotations

from itertools import product as iproduct
from typing import Callable, Dict, FrozenSet, Iterable, List, Set, Tuple

# A frame is (worlds, R) where R is a set of ordered pairs (w, v) meaning w -> v.
World = object
Relation = Set[Tuple[object, object]]
Frame = Tuple[List[object], Relation]


# --------------------------------------------------------------------------- #
# Frame construction and validity checks
# --------------------------------------------------------------------------- #
def is_irreflexive(worlds: List[object], R: Relation) -> bool:
    """No world sees itself: the semantic content of Gödel's second theorem."""
    return all((w, w) not in R for w in worlds)


def is_transitive(worlds: List[object], R: Relation) -> bool:
    """If w -> v and v -> u then w -> u."""
    for (a, b) in R:
        for (c, d) in R:
            if b == c and (a, d) not in R:
                return False
    return True


def is_gl_frame(frame: Frame) -> bool:
    """A GL frame is finite, irreflexive and transitive."""
    worlds, R = frame
    return is_irreflexive(worlds, R) and is_transitive(worlds, R)


def successors(w: object, R: Relation) -> Set[object]:
    """All v with w -> v."""
    return {v for (a, v) in R if a == w}


def strict_order_frame(n: int) -> Frame:
    """The canonical GL frame (ℕ_{<n}, >): k sees every smaller number."""
    worlds = list(range(n))
    R = {(a, b) for a in worlds for b in worlds if a > b}
    return worlds, R


# --------------------------------------------------------------------------- #
# Box and diamond operators
# --------------------------------------------------------------------------- #
def box(frame: Frame, S: Set[object]) -> Set[object]:
    """□S = { w | every successor of w is in S } (true at dead ends, vacuously)."""
    worlds, R = frame
    return {w for w in worlds if successors(w, R) <= S}


def diamond(frame: Frame, S: Set[object]) -> Set[object]:
    """◇S = { w | some successor of w is in S }."""
    worlds, R = frame
    return {w for w in worlds if successors(w, R) & S}


def complement(frame: Frame, S: Set[object]) -> Set[object]:
    worlds, _ = frame
    return set(worlds) - S


# --------------------------------------------------------------------------- #
# Ordinal rank (Theorem: rank strictly decreases along accessibility)
# --------------------------------------------------------------------------- #
def rank(frame: Frame) -> Dict[object, int]:
    """
    rank(w) = 0 if w is a dead end, else 1 + max{ rank(v) : w -> v }.

    Well-defined because accessibility is well-founded (finite + irreflexive +
    transitive). For finite frames the ordinal rank is a natural number: the
    length of the longest accessibility chain starting at w.
    """
    worlds, R = frame
    memo: Dict[object, int] = {}

    def r(w: object) -> int:
        if w in memo:
            return memo[w]
        succ = successors(w, R)
        memo[w] = 0 if not succ else 1 + max(r(v) for v in succ)
        return memo[w]

    return {w: r(w) for w in worlds}


def rank_decreases_along_R(frame: Frame) -> bool:
    """Verify gl_rank_lt_of_R: R w v  ⟹  rank(v) < rank(w)."""
    _, R = frame
    rk = rank(frame)
    return all(rk[v] < rk[w] for (w, v) in R)


# --------------------------------------------------------------------------- #
# Semantic Löb:  □(□S → S) ⊆ □S   with  (□S → S) encoded as (□S)ᶜ ∪ S
# --------------------------------------------------------------------------- #
def loeb_holds(frame: Frame, S: Set[object]) -> bool:
    boxS = box(frame, S)
    implication = complement(frame, boxS) | S          # (□S)ᶜ ∪ S  ==  □S → S
    return box(frame, implication) <= boxS             # □(□S → S) ⊆ □S


# --------------------------------------------------------------------------- #
# Polymodal GLP frame: one world set, nested relations R_0 ⊇ R_1 ⊇ ...
# --------------------------------------------------------------------------- #
def glp_levels(worlds: List[object], R0: Relation, depth: int) -> List[Relation]:
    """
    Build a nested family R_0 ⊇ R_1 ⊇ ... ⊇ R_depth from a base GL relation R0
    by keeping, at level n, only arrows whose ordinal-rank gap is at least n+1.
    This is one concrete way to manufacture a strictly decreasing nested family
    of transitive irreflexive relations (each level is again a GL frame).
    """
    rk = rank((worlds, R0))
    levels = []
    for n in range(depth + 1):
        Rn = {(w, v) for (w, v) in R0 if rk[w] - rk[v] >= n + 1}
        levels.append(Rn)
    return levels


# --------------------------------------------------------------------------- #
# Synchronized product of two GL frames
# --------------------------------------------------------------------------- #
def synchronized_product(F: Frame, G: Frame) -> Frame:
    """(w1,w2) -> (v1,v2)  iff  w1 -> v1 in F  AND  w2 -> v2 in G."""
    WF, RF = F
    WG, RG = G
    worlds = [(a, b) for a in WF for b in WG]
    R = {((a, b), (c, d)) for (a, c) in RF for (b, d) in RG}
    return worlds, R


def rectangle(A: Set[object], B: Set[object]) -> Set[Tuple[object, object]]:
    return {(a, b) for a in A for b in B}


# --------------------------------------------------------------------------- #
# Demonstrations
# --------------------------------------------------------------------------- #
def demo_basic_frame() -> None:
    print("=" * 70)
    print("DEMO 1:  The canonical GL frame (ℕ_{<5}, >)")
    print("=" * 70)
    F = strict_order_frame(5)
    print(f"worlds      : {F[0]}")
    print(f"is GL frame : {is_gl_frame(F)}  (irreflexive & transitive)")
    print(f"successors  : {{ {', '.join(f'{w}->{sorted(successors(w, F[1]))}' for w in F[0])} }}")
    print(f"rank        : {rank(F)}        (rank(n) == n)")
    print(f"rank drops along every arrow : {rank_decreases_along_R(F)}")
    print()


def demo_box_diamond_and_loeb() -> None:
    print("=" * 70)
    print("DEMO 2:  Box, diamond, duality, and semantic Löb")
    print("=" * 70)
    F = strict_order_frame(5)
    S = {0, 2}
    bS, dS = box(F, S), diamond(F, S)
    print(f"S          = {sorted(S)}")
    print(f"□S         = {sorted(bS)}   (worlds all of whose successors lie in S)")
    print(f"◇S         = {sorted(dS)}   (worlds with some successor in S)")
    # Duality:  ◇S == (□Sᶜ)ᶜ
    dual = complement(F, box(F, complement(F, S)))
    print(f"◇S == (□Sᶜ)ᶜ : {dS == dual}")
    # Löb for several S
    print("Semantic Löb  □(□S→S) ⊆ □S  for assorted S:")
    for T in [set(), {0}, {0, 1, 2}, {1, 3}, set(F[0])]:
        print(f"    S = {sorted(T)!s:<14} Löb holds: {loeb_holds(F, T)}")
    # Gödel II flavour: with S = ∅,  □∅ = {0} ≠ univ  (the system is consistent
    # but cannot prove it); the dead end 0 makes □ vacuously true there.
    print(f"□∅ (the 'inconsistency' set) = {sorted(box(F, set()))}  -> only dead end 0")
    print()


def demo_loeb_needs_irreflexivity() -> None:
    print("=" * 70)
    print("DEMO 3:  Irreflexivity is load-bearing (add a self-loop, break Löb)")
    print("=" * 70)
    worlds = [0, 1]
    R = {(1, 0)}                       # genuine GL frame: 1 -> 0
    F = (worlds, R)
    print(f"GL frame   : is_gl={is_gl_frame(F)}, Löb(∅)={loeb_holds(F, set())}")
    Rbad = {(1, 0), (0, 0)}            # add forbidden self-loop 0 -> 0
    Fbad = (worlds, Rbad)
    print(f"+self-loop : is_gl={is_gl_frame(Fbad)} (irreflexive fails), "
          f"Löb(∅)={loeb_holds(Fbad, set())}")
    print("    -> dropping irreflexivity invalidates Löb / Gödel II.")
    print()


def demo_glp() -> None:
    print("=" * 70)
    print("DEMO 4:  Polymodal GLP frame — nested levels R_0 ⊇ R_1 ⊇ ...")
    print("=" * 70)
    worlds, R0 = strict_order_frame(6)
    levels = glp_levels(worlds, R0, depth=3)
    for n, Rn in enumerate(levels):
        gl = is_gl_frame((worlds, Rn))
        print(f"  level {n}: |R_{n}| = {len(Rn):2d}   is GL frame: {gl}")
    # Nesting R_{n+1} ⊆ R_n
    nested = all(levels[n + 1] <= levels[n] for n in range(len(levels) - 1))
    print(f"  nesting  R_(n+1) ⊆ R_n : {nested}")
    # Box monotone in the index:  □_n S ⊆ □_(n+1) S
    S = {0, 1, 2}
    mono = all(box((worlds, levels[n]), S) <= box((worlds, levels[n + 1]), S)
               for n in range(len(levels) - 1))
    print(f"  box monotone in level  □_n S ⊆ □_(n+1) S  (S={sorted(S)}): {mono}")
    print("    -> frame root of the GLP axiom  [n]φ → [n+1]φ.")
    print()


def demo_product() -> None:
    print("=" * 70)
    print("DEMO 5:  Synchronized product — ◇ factors, □ does not")
    print("=" * 70)
    F = strict_order_frame(3)        # worlds 0,1,2
    G = strict_order_frame(3)
    P = synchronized_product(F, G)
    print(f"  F × G is a GL frame: {is_gl_frame(P)}   (|worlds| = {len(P[0])})")
    A, B = {0, 1}, {0}
    lhs = diamond(P, rectangle(A, B))
    rhs = rectangle(diamond(F, A), diamond(G, B))
    print(f"  ◇(A×B)            = {sorted(lhs)}")
    print(f"  (◇A)×(◇B)         = {sorted(rhs)}")
    print(f"  diamond factors   : {lhs == rhs}   (prod_diamond_rectangle)")
    # Box does NOT factor: dead end in one coordinate makes □ vacuous.
    boxLHS = box(P, rectangle(A, B))
    boxRHS = rectangle(box(F, A), box(G, B))
    print(f"  □(A×B)            = {sorted(boxLHS)}")
    print(f"  (□A)×(□B)         = {sorted(boxRHS)}")
    print(f"  box factors       : {boxLHS == boxRHS}   "
          f"(expected False: vacuous truth at dead ends)")
    witnesses = boxLHS - boxRHS
    print(f"  witnesses in □(A×B)\\(□A×□B): {sorted(witnesses)}")
    print()


def main() -> None:
    demo_basic_frame()
    demo_box_diamond_and_loeb()
    demo_loeb_needs_irreflexivity()
    demo_glp()
    demo_product()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
