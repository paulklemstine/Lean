"""
Reflective Type Theory — Numerical Demonstrations
=================================================

A *reflective* proposition is one that can talk about its own provability.
We model this with Kripke frames: a proposition is the set of *proof stages*
(worlds) at which it holds, and the provability modality

    box(P) = { w : for every stage v reachable from w in one step, v is in P }

is the necessity operator of an accessibility relation R (the "provability
step").  Its dual is

    dia(P) = { w : some stage v reachable from w in one step lies in P }.

This script demonstrates, over explicit finite frames, every headline result:

  1. "Provable but not provably provable" (box P and not box box P) is
     inhabited on a non-transitive three-stage chain.
  2. Transitive frames validate axiom 4 (box P subset of box box P), so the
     phenomenon is genuinely non-classical.
  3. The modality is a *normal* modality: monotone, distributes over
     intersection, validates K, and admits necessitation.
  4. The modality is provably not the identity (proper extension of the base).
  5. Modal duality: dia P = complement(box(complement P)).
  6. Every monotone operator has least and greatest fixpoints
     (Knaster-Tarski), giving the mu / nu constructors of the modal
     mu-calculus.
  7. Loeb's law box(box P -> P) -> box P holds on converse-well-founded frames.
"""

from __future__ import annotations

from itertools import product
from typing import Callable, FrozenSet, Iterable, List, Set, Tuple

# A world is an int; a proposition is a frozenset of worlds; a frame is a
# relation R given as a set of ordered pairs (w, v) meaning "R w v".
World = int
Prop = FrozenSet[World]
Relation = Set[Tuple[World, World]]


class Frame:
    """A reflective frame: a finite set of worlds with a provability step R."""

    def __init__(self, worlds: Iterable[World], relation: Relation) -> None:
        self.worlds: FrozenSet[World] = frozenset(worlds)
        self.R: Relation = set(relation)

    def successors(self, w: World) -> Set[World]:
        """All stages one provability step ahead of w."""
        return {v for (a, v) in self.R if a == w}

    def box(self, p: Prop) -> Prop:
        """Necessity: 'is provable'. w in box p iff every successor lies in p."""
        return frozenset(
            w for w in self.worlds if self.successors(w) <= set(p)
        )

    def dia(self, p: Prop) -> Prop:
        """Possibility: 'is consistent with provability'."""
        return frozenset(
            w for w in self.worlds if self.successors(w) & set(p)
        )

    def complement(self, p: Prop) -> Prop:
        return frozenset(self.worlds - set(p))

    def is_transitive(self) -> bool:
        return all(
            (a, c) in self.R
            for (a, b) in self.R
            for (b2, c) in self.R
            if b == b2
        )

    def all_props(self) -> List[Prop]:
        """Enumerate every proposition (subset of worlds)."""
        ws = sorted(self.worlds)
        out: List[Prop] = []
        for bits in product([False, True], repeat=len(ws)):
            out.append(frozenset(w for w, b in zip(ws, bits) if b))
        return out


def pretty(p: Prop) -> str:
    return "{" + ", ".join(map(str, sorted(p))) + "}"


# ---------------------------------------------------------------------------
# 1. The flagship model: provable but not provably provable
# ---------------------------------------------------------------------------
def demo_provable_not_provably_provable() -> None:
    """The non-transitive chain 2 -> 1 -> 0 with P = {1} realises box P and
    not box box P at world 2."""
    print("=" * 70)
    print("1. Provable but not provably provable  (box P and not box box P)")
    print("=" * 70)
    frame = Frame(worlds={0, 1, 2}, relation={(2, 1), (1, 0)})
    P: Prop = frozenset({1})
    boxP = frame.box(P)
    boxboxP = frame.box(boxP)
    print(f"Chain 2 -> 1 -> 0,   P = {pretty(P)}")
    print(f"  box P      = {pretty(boxP)}")
    print(f"  box box P  = {pretty(boxboxP)}")
    print(f"  2 in box P       : {2 in boxP}")
    print(f"  2 in box box P   : {2 in boxboxP}")
    assert 2 in boxP and 2 not in boxboxP
    print("  => At stage 2, P is provable but NOT provably provable.  OK\n")


# ---------------------------------------------------------------------------
# 2. Transitive frames validate axiom 4
# ---------------------------------------------------------------------------
def demo_axiom_four() -> None:
    """On transitive frames box P is a subset of box box P for every P."""
    print("=" * 70)
    print("2. Boundary: transitive frames validate axiom 4 (box P -> box box P)")
    print("=" * 70)
    # Transitive closure of the chain: add (2,0).
    frame = Frame(worlds={0, 1, 2}, relation={(2, 1), (1, 0), (2, 0)})
    print(f"  transitive? {frame.is_transitive()}")
    holds = all(set(frame.box(P)) <= set(frame.box(frame.box(P)))
                for P in frame.all_props())
    print(f"  box P subset box box P for ALL P : {holds}")
    assert holds
    # And the witness now fails, as predicted.
    P = frozenset({1})
    print(f"  with P = {pretty(P)}: 2 in box box P now : "
          f"{2 in frame.box(frame.box(P))}")
    print("  => Transitivity kills the phenomenon.  OK\n")


# ---------------------------------------------------------------------------
# 3. Normality of the modality
# ---------------------------------------------------------------------------
def demo_normal_modality() -> None:
    """box is monotone, distributes over intersection, validates K, and admits
    necessitation."""
    print("=" * 70)
    print("3. The modality is normal")
    print("=" * 70)
    frame = Frame(worlds={0, 1, 2},
                  relation={(2, 1), (1, 0), (2, 0), (0, 1)})
    props = frame.all_props()

    mono = all(
        set(frame.box(P)) <= set(frame.box(Q))
        for P in props for Q in props if set(P) <= set(Q)
    )
    inter = all(
        frame.box(frozenset(set(P) & set(Q)))
        == frozenset(set(frame.box(P)) & set(frame.box(Q)))
        for P in props for Q in props
    )
    # K: box(P -> Q) intersect box P  subset  box Q, using P -> Q = ~P u Q.
    def implies(P: Prop, Q: Prop) -> Prop:
        return frozenset((frame.worlds - set(P)) | set(Q))
    k_axiom = all(
        set(frame.box(implies(P, Q))) & set(frame.box(P)) <= set(frame.box(Q))
        for P in props for Q in props
    )
    nec = frame.box(frozenset(frame.worlds)) == frozenset(frame.worlds)

    print(f"  monotone                    : {mono}")
    print(f"  distributes over intersection: {inter}")
    print(f"  validates K                 : {k_axiom}")
    print(f"  necessitation (box True=True): {nec}")
    assert mono and inter and k_axiom and nec
    print("  => Normal modality confirmed.  OK\n")


# ---------------------------------------------------------------------------
# 4. Proper extension: box is not the identity
# ---------------------------------------------------------------------------
def demo_box_ne_id() -> None:
    print("=" * 70)
    print("4. Proper extension: box is not the identity operator")
    print("=" * 70)
    # A dead-end world: no successors, so box(empty) = everything != empty.
    frame = Frame(worlds={0, 1}, relation=set())
    P: Prop = frozenset()
    print(f"  frame with no steps,  P = {pretty(P)}")
    print(f"  box P = {pretty(frame.box(P))}  (all dead-ends prove anything)")
    print(f"  box P == P ? {frame.box(P) == P}")
    assert frame.box(P) != P
    print("  => box differs from identity; reflective theory strictly enriches"
          " the base.  OK\n")


# ---------------------------------------------------------------------------
# 5. Modal duality
# ---------------------------------------------------------------------------
def demo_duality() -> None:
    print("=" * 70)
    print("5. Modal duality: dia P = complement(box(complement P))")
    print("=" * 70)
    frame = Frame(worlds={0, 1, 2}, relation={(2, 1), (1, 0), (0, 2)})
    ok = all(
        frame.dia(P) == frame.complement(frame.box(frame.complement(P)))
        for P in frame.all_props()
    )
    print(f"  identity holds for all P : {ok}")
    assert ok
    print("  => The two dual modalities of the mu-calculus.  OK\n")


# ---------------------------------------------------------------------------
# 6. Fixpoints (Knaster-Tarski): the mu / nu of the mu-calculus
# ---------------------------------------------------------------------------
def lfp(frame: Frame, f: Callable[[Prop], Prop]) -> Prop:
    """Least fixpoint by iterating f from the empty set (finite lattice)."""
    cur: Prop = frozenset()
    while True:
        nxt = f(cur)
        if nxt == cur:
            return cur
        cur = nxt


def gfp(frame: Frame, f: Callable[[Prop], Prop]) -> Prop:
    """Greatest fixpoint by iterating f from the top set."""
    cur: Prop = frozenset(frame.worlds)
    while True:
        nxt = f(cur)
        if nxt == cur:
            return cur
        cur = nxt


def demo_fixpoints() -> None:
    print("=" * 70)
    print("6. Fixpoints of monotone operators (mu-calculus mu / nu)")
    print("=" * 70)
    frame = Frame(worlds={0, 1, 2, 3}, relation={(0, 1), (1, 2), (2, 3)})
    A: Prop = frozenset({3})

    # "Eventually A" = mu X. A u dia X   (reaches A along the step relation).
    eventuallyA = lfp(frame, lambda X: frozenset(set(A) | set(frame.dia(X))))
    # "Always along steps some successor stays" flavour: nu X. dia X.
    perpetual = gfp(frame, lambda X: frame.dia(X))

    print(f"  frame 0->1->2->3,  A = {pretty(A)}")
    print(f"  mu X. A u dia X   (eventually reaches A) = {pretty(eventuallyA)}")
    print(f"  nu X. dia X       (infinite forward path) = {pretty(perpetual)}")
    assert eventuallyA == frozenset({0, 1, 2, 3})
    assert perpetual == frozenset()  # finite acyclic: no infinite path
    print("  => Least/greatest fixpoints exist for every monotone operator.  OK\n")


# ---------------------------------------------------------------------------
# 7. Loeb's law on converse-well-founded frames
# ---------------------------------------------------------------------------
def demo_loeb() -> None:
    print("=" * 70)
    print("7. Loeb's law box(box P -> P) -> box P on well-founded frames")
    print("=" * 70)
    # Transitive, converse-well-founded (no infinite ascending chain): 3>2>1>0
    worlds = {0, 1, 2, 3}
    rel = {(a, b) for a in worlds for b in worlds if a > b}  # strict order
    frame = Frame(worlds=worlds, relation=rel)
    print(f"  strict-order GL frame on {sorted(worlds)}, transitive="
          f"{frame.is_transitive()}")

    def implies(P: Prop, Q: Prop) -> Prop:
        return frozenset((frame.worlds - set(P)) | set(Q))

    ok = True
    for P in frame.all_props():
        premise = frame.box(implies(frame.box(P), P))
        conclusion = frame.box(P)
        if not (set(premise) <= set(conclusion)):
            ok = False
            break
    print(f"  Loeb holds for all P : {ok}")
    assert ok
    print("  => Well-founded provability satisfies the fixpoint law.  OK\n")


def main() -> None:
    demo_provable_not_provably_provable()
    demo_axiom_four()
    demo_normal_modality()
    demo_box_ne_id()
    demo_duality()
    demo_fixpoints()
    demo_loeb()
    print("All reflective-type-theory demonstrations passed.")


if __name__ == "__main__":
    main()
