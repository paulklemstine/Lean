"""
The Modal Logic of Forcing: numerical demonstrations.

A self-contained implementation of Kripke semantics for the set-theoretic
multiverse, where necessity (Box) means "true in every forcing extension" and
possibility (Dia) means "true in some forcing extension." We verify, over finite
multiverses, the soundness of S4.2 for forcing frames (K, T, 4, .2), the
necessity/possibility duality, the failure of the S5 axiom B in a sink frame,
and the modal reading of the independence of the Continuum Hypothesis.

Everything is inlined; run `python demo.py`.
"""

from __future__ import annotations

from dataclasses import dataclass
from itertools import product
from typing import Callable, Dict, FrozenSet, Iterable, List, Tuple

# A World is a truth assignment on a finite set of atoms, encoded as a frozenset
# of the atoms that are true.
World = FrozenSet[str]


# --------------------------------------------------------------------------- #
# Modal sentence syntax                                                        #
# --------------------------------------------------------------------------- #
@dataclass(frozen=True)
class Sentence:
    """A modal propositional sentence.

    kind is one of: atom, tru, fls, neg, conj, disj, imp, box.
    """

    kind: str
    atom: str | None = None
    left: "Sentence | None" = None
    right: "Sentence | None" = None


def atom(a: str) -> Sentence:
    return Sentence("atom", atom=a)


TRU = Sentence("tru")
FLS = Sentence("fls")


def neg(p: Sentence) -> Sentence:
    return Sentence("neg", left=p)


def conj(p: Sentence, q: Sentence) -> Sentence:
    return Sentence("conj", left=p, right=q)


def disj(p: Sentence, q: Sentence) -> Sentence:
    return Sentence("disj", left=p, right=q)


def imp(p: Sentence, q: Sentence) -> Sentence:
    return Sentence("imp", left=p, right=q)


def box(p: Sentence) -> Sentence:
    return Sentence("box", left=p)


def dia(p: Sentence) -> Sentence:
    """Possibility as the dual of necessity: Dia p := not Box not p."""
    return neg(box(neg(p)))


# --------------------------------------------------------------------------- #
# Kripke semantics                                                             #
# --------------------------------------------------------------------------- #
Relation = Callable[[World, World], bool]


def meval(R: Relation, M: Iterable[World], w: World, p: Sentence) -> bool:
    """Truth of sentence p at world w, under accessibility R and multiverse M."""
    M = list(M)
    if p.kind == "atom":
        return p.atom in w
    if p.kind == "tru":
        return True
    if p.kind == "fls":
        return False
    if p.kind == "neg":
        return not meval(R, M, w, p.left)
    if p.kind == "conj":
        return meval(R, M, w, p.left) and meval(R, M, w, p.right)
    if p.kind == "disj":
        return meval(R, M, w, p.left) or meval(R, M, w, p.right)
    if p.kind == "imp":
        return (not meval(R, M, w, p.left)) or meval(R, M, w, p.right)
    if p.kind == "box":
        return all(meval(R, M, v, p.left) for v in M if R(w, v))
    raise ValueError(f"unknown sentence kind {p.kind!r}")


def mvalid(R: Relation, M: Iterable[World], p: Sentence) -> bool:
    """A sentence is valid in the frame (R, M) if true at every admissible world."""
    M = list(M)
    return all(meval(R, M, w, p) for w in M)


# --------------------------------------------------------------------------- #
# Frame conditions                                                            #
# --------------------------------------------------------------------------- #
def is_reflexive(R: Relation, M: List[World]) -> bool:
    return all(R(w, w) for w in M)


def is_transitive(R: Relation, M: List[World]) -> bool:
    return all(
        (not (R(w, v) and R(v, u))) or R(w, u)
        for w in M
        for v in M
        for u in M
    )


def is_directed(R: Relation, M: List[World]) -> bool:
    for w in M:
        for v1 in M:
            for v2 in M:
                if R(w, v1) and R(w, v2):
                    if not any(R(v1, u) and R(v2, u) for u in M):
                        return False
    return True


def is_symmetric(R: Relation, M: List[World]) -> bool:
    return all((not R(w, v)) or R(v, w) for w in M for v in M)


# --------------------------------------------------------------------------- #
# Concrete frames                                                             #
# --------------------------------------------------------------------------- #
def all_worlds(atoms: List[str]) -> List[World]:
    """Every truth assignment on the given atoms."""
    out: List[World] = []
    for bits in product([False, True], repeat=len(atoms)):
        out.append(frozenset(a for a, b in zip(atoms, bits) if b))
    return out


def flip_reach(w: World, v: World) -> bool:
    """FlipReach: v differs from w on a finite set of atoms.

    Over finite atom sets any two worlds differ finitely, so this is total (an
    equivalence relation) --- reflexive, symmetric, transitive.
    """
    return True  # over a fixed finite atom set every pair is finitely reachable


def full_relation(w: World, v: World) -> bool:
    """Full accessibility: every world reaches every world."""
    return True


# --------------------------------------------------------------------------- #
# Demonstrations                                                              #
# --------------------------------------------------------------------------- #
def demo_s42_soundness() -> None:
    print("=" * 70)
    print("1. Soundness of S4.2 for the flip-reachability forcing frame")
    print("=" * 70)
    atoms = ["CH", "VeqL", "Meas"]
    M = all_worlds(atoms)
    R = flip_reach
    print(f"Multiverse has {len(M)} worlds; atoms = {atoms}")
    print(f"  reflexive?  {is_reflexive(R, M)}")
    print(f"  transitive? {is_transitive(R, M)}")
    print(f"  directed?   {is_directed(R, M)}")

    # Test each axiom on all sentence pairs built from the atoms.
    atomic = [atom(a) for a in atoms] + [box(atom(a)) for a in atoms]
    ok_K = ok_T = ok_4 = ok_2 = True
    for p in atomic:
        for q in atomic:
            ok_K &= mvalid(R, M, imp(box(imp(p, q)), imp(box(p), box(q))))
        ok_T &= mvalid(R, M, imp(box(p), p))
        ok_4 &= mvalid(R, M, imp(box(p), box(box(p))))
        ok_2 &= mvalid(R, M, imp(dia(box(p)), box(dia(p))))
    print(f"  Axiom K  (distribution):  valid = {ok_K}")
    print(f"  Axiom T  (Box p -> p):    valid = {ok_T}")
    print(f"  Axiom 4  (Box p ->BoxBox): valid = {ok_4}")
    print(f"  Axiom .2 (DiaBox->BoxDia): valid = {ok_2}")


def demo_duality() -> None:
    print("\n" + "=" * 70)
    print("2. Necessity/possibility duality  Dia p <-> not Box not p")
    print("=" * 70)
    atoms = ["p", "q"]
    M = all_worlds(atoms)
    R = flip_reach
    p = atom("p")
    same = all(
        meval(R, M, w, dia(p)) == meval(R, M, w, neg(box(neg(p)))) for w in M
    )
    print(f"  Dia p and not Box not p agree at every world: {same}")


def demo_B_fails() -> None:
    print("\n" + "=" * 70)
    print("3. The S5 axiom B (p -> Box Dia p) FAILS: forcing is irreversible")
    print("=" * 70)
    # Sink frame over one atom 'a'. wT = {a} (atom true), wF = {} (atom false).
    wT: World = frozenset({"a"})
    wF: World = frozenset()
    M = [wT, wF]

    def sinkR(x: World, y: World) -> bool:
        return y == wF or x == y

    print(f"  sink frame reflexive?  {is_reflexive(sinkR, M)}")
    print(f"  sink frame transitive? {is_transitive(sinkR, M)}")
    print(f"  sink frame directed?   {is_directed(sinkR, M)}  (so it IS S4.2)")
    print(f"  sink frame symmetric?  {is_symmetric(sinkR, M)}  (fails -> not S5)")
    B = imp(atom("a"), box(dia(atom("a"))))
    print(f"  Axiom B valid in sink frame? {mvalid(sinkR, M, B)}  (expected False)")
    print(f"    at wT: B holds? {meval(sinkR, M, wT, B)}  (the counterexample world)")


def demo_CH_contingent() -> None:
    print("\n" + "=" * 70)
    print("4. The Continuum Hypothesis is contingent (independent), not necessary")
    print("=" * 70)
    atoms = ["CH", "VeqL", "Meas"]
    M = all_worlds(atoms)
    R = full_relation  # full-accessibility frame: contingency == independence
    godel: World = frozenset({"CH", "VeqL"})   # CH true, VeqL true, Meas false
    CH = atom("CH")
    contingent = meval(R, M, godel, conj(dia(CH), dia(neg(CH))))
    necessary = meval(R, M, godel, box(CH))
    print(f"  Dia CH and Dia not-CH at Goedel's universe: {contingent}")
    print(f"  Box CH at Goedel's universe (CH necessary): {necessary}")
    print(f"  => CH is contingent and NOT necessary: {contingent and not necessary}")

    # Bridge: contingency in full frame == independence across the multiverse.
    def independent(p: Sentence) -> bool:
        return any(meval(R, M, w, p) for w in M) and any(
            not meval(R, M, w, p) for w in M
        )

    match = all(
        meval(R, M, w, conj(dia(a), dia(neg(a)))) == independent(a)
        for a in [atom(x) for x in atoms]
        for w in M
    )
    print(f"  Bridge: contingency == independence at every world/atom: {match}")


def main() -> None:
    demo_s42_soundness()
    demo_duality()
    demo_B_fails()
    demo_CH_contingent()
    print("\nAll demonstrations complete.")


if __name__ == "__main__":
    main()
