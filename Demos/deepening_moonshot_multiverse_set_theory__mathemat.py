"""
demo.py — Numerical demonstrations for
"The Modal Logic of Forcing in a Combinatorial Multiverse".

A world is a truth assignment on a finite set of atomic set-theoretic
assertions (e.g. CH, V=L, "there is a measurable cardinal").  Sentences are
propositional combinations of atoms.  Forcing is modelled by flipping a single
atom.  Two worlds are "reachable" (forcing-equivalent) when they disagree on
only finitely many atoms — over a finite atom set, always.  Necessity (Box) and
possibility (Diamond) quantify over reachable worlds.

This script is fully self-contained (standard library only) and prints:
  * the three-way classification (valid / refutable / independent) of sentences
    in the Goedel--Cohen multiverse;
  * verification that forcing settles no atom in the full multiverse;
  * the count 2^n of worlds over n atoms;
  * an exhaustive check of the S5 modal axioms (T, 4, B, 5) and the
    Maximality Principle over the full multiverse;
  * the switch property and non-necessity of every atom, and of CH at Goedel.
"""

from __future__ import annotations

from dataclasses import dataclass
from itertools import product
from typing import Callable, Dict, FrozenSet, List, Tuple

# ----------------------------------------------------------------------------
# Sentences (a small algebraic data type)
# ----------------------------------------------------------------------------

@dataclass(frozen=True)
class Sentence:
    """A propositional sentence over string-named atoms.

    kind is one of: 'atom', 'tru', 'fls', 'neg', 'conj', 'disj', 'imp'.
    """
    kind: str
    name: str = ""
    left: "Sentence | None" = None
    right: "Sentence | None" = None


def atom(a: str) -> Sentence:
    return Sentence("atom", name=a)

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


World = Dict[str, bool]  # a truth assignment on atoms


def evaluate(w: World, p: Sentence) -> bool:
    """Boolean value of sentence p in world w."""
    if p.kind == "atom":
        return w[p.name]
    if p.kind == "tru":
        return True
    if p.kind == "fls":
        return False
    if p.kind == "neg":
        return not evaluate(w, p.left)
    if p.kind == "conj":
        return evaluate(w, p.left) and evaluate(w, p.right)
    if p.kind == "disj":
        return evaluate(w, p.left) or evaluate(w, p.right)
    if p.kind == "imp":
        return (not evaluate(w, p.left)) or evaluate(w, p.right)
    raise ValueError(f"unknown sentence kind {p.kind!r}")


# ----------------------------------------------------------------------------
# Multiverse notions
# ----------------------------------------------------------------------------

def all_worlds(atoms: List[str]) -> List[World]:
    """The full multiverse over `atoms`: all 2^n truth assignments."""
    worlds: List[World] = []
    for bits in product([False, True], repeat=len(atoms)):
        worlds.append({a: b for a, b in zip(atoms, bits)})
    return worlds


def classify(multiverse: List[World], p: Sentence) -> str:
    """Return 'valid', 'refutable', or 'independent'."""
    vals = {evaluate(w, p) for w in multiverse}
    if vals == {True}:
        return "valid"
    if vals == {False}:
        return "refutable"
    return "independent"


def flip(w: World, a: str) -> World:
    """Generic extension: toggle the truth value of atom a."""
    v = dict(w)
    v[a] = not v[a]
    return v


def disagreement(w: World, v: World) -> FrozenSet[str]:
    return frozenset(a for a in w if w[a] != v[a])


def reachable(w: World, v: World) -> bool:
    """Forcing accessibility: finite disagreement (always true here)."""
    return True  # over a finite atom set every disagreement set is finite


def box(multiverse: List[World], w: World, p: Sentence) -> bool:
    """Necessity: p holds in every reachable world of the multiverse."""
    return all(evaluate(v, p) for v in multiverse if reachable(w, v))


def diamond(multiverse: List[World], w: World, p: Sentence) -> bool:
    """Possibility: p holds in some reachable world of the multiverse."""
    return any(evaluate(v, p) for v in multiverse if reachable(w, v))


# ----------------------------------------------------------------------------
# Demonstrations
# ----------------------------------------------------------------------------

def demo_godel_cohen() -> None:
    print("=" * 68)
    print("The Goedel--Cohen two-world multiverse")
    print("=" * 68)
    godel: World = {"CH": True, "VeqL": True, "Meas": False}
    cohen: World = {"CH": False, "VeqL": False, "Meas": False}
    gc = [godel, cohen]

    tests = {
        "CH": atom("CH"),
        "V=L": atom("VeqL"),
        "V=L -> CH": imp(atom("VeqL"), atom("CH")),
        "CH or not CH": disj(atom("CH"), neg(atom("CH"))),
        "not(CH and not CH)": neg(conj(atom("CH"), neg(atom("CH")))),
    }
    for label, s in tests.items():
        print(f"  {label:22s} : {classify(gc, s)}")
    print()


def demo_forcing_settles_nothing() -> None:
    print("=" * 68)
    print("Forcing settles no atom in the full multiverse")
    print("=" * 68)
    atoms = ["CH", "VeqL", "Meas"]
    universe = all_worlds(atoms)
    print(f"  number of worlds over {len(atoms)} atoms = 2^{len(atoms)} = "
          f"{len(universe)}")
    for a in atoms:
        indep = classify(universe, atom(a)) == "independent"
        # forcing witness: from any world, one flip reverses the atom
        w = universe[0]
        flipped = flip(w, a)
        toggled = evaluate(w, atom(a)) != evaluate(flipped, atom(a))
        print(f"  atom {a:6s}: independent={indep}, single flip toggles it="
              f"{toggled}")
    print()


def demo_s5_axioms() -> None:
    print("=" * 68)
    print("The S5 modal axioms over the full multiverse (exhaustive check)")
    print("=" * 68)
    atoms = ["a", "b"]
    universe = all_worlds(atoms)
    # a stock of sentences to quantify over
    sentences = [
        atom("a"), neg(atom("a")), conj(atom("a"), atom("b")),
        disj(atom("a"), atom("b")), imp(atom("a"), atom("b")),
        disj(atom("a"), neg(atom("a"))),  # a validity
    ]

    def all_pairs_reachable(w: World, v: World) -> bool:
        return reachable(w, v)

    ok_T = ok_4 = ok_B = ok_5 = ok_max = True
    for w in universe:
        for p in sentences:
            # T: Box p -> p
            if box(universe, w, p) and not evaluate(w, p):
                ok_T = False
            # 4: Box p -> Box Box p  (here: Box p -> Box_v p for reachable v)
            if box(universe, w, p):
                for v in universe:
                    if all_pairs_reachable(w, v) and not box(universe, v, p):
                        ok_4 = False
            # B: p -> Box Diamond p
            if evaluate(w, p):
                for v in universe:
                    if all_pairs_reachable(w, v) and not diamond(universe, v, p):
                        ok_B = False
            # 5: Diamond p -> Box Diamond p
            if diamond(universe, w, p):
                for v in universe:
                    if all_pairs_reachable(w, v) and not diamond(universe, v, p):
                        ok_5 = False
            # Maximality: Diamond Box p -> Box p
            poss_nec = any(
                all_pairs_reachable(w, v) and box(universe, v, p)
                for v in universe
            )
            if poss_nec and not box(universe, w, p):
                ok_max = False

    print(f"  Axiom T  (Box p -> p)            : {ok_T}")
    print(f"  Axiom 4  (Box p -> Box Box p)     : {ok_4}")
    print(f"  Axiom B  (p -> Box Diamond p)     : {ok_B}")
    print(f"  Axiom 5  (Diamond p -> Box Dia p) : {ok_5}")
    print(f"  Maximality (Dia Box p -> Box p)   : {ok_max}")
    print()


def demo_switches() -> None:
    print("=" * 68)
    print("Every atom is a switch; no atom is necessary")
    print("=" * 68)
    atoms = ["CH", "VeqL", "Meas"]
    universe = all_worlds(atoms)
    for a in atoms:
        w = universe[0]
        can_true = diamond(universe, w, atom(a))
        can_false = diamond(universe, w, neg(atom(a)))
        necessary = box(universe, w, atom(a))
        print(f"  {a:6s}: Diamond(a)={can_true}, Diamond(not a)={can_false}, "
              f"Box(a)={necessary}  -> switch={can_true and can_false}")

    print("\n  Concrete: CH at Goedel inside {Goedel, Cohen}")
    godel: World = {"CH": True, "VeqL": True, "Meas": False}
    cohen: World = {"CH": False, "VeqL": False, "Meas": False}
    gc = [godel, cohen]
    print(f"    Goedel |= CH                 : {evaluate(godel, atom('CH'))}")
    print(f"    Box CH at Goedel (necessary) : {box(gc, godel, atom('CH'))}")
    print(f"    Diamond (not CH) at Goedel   : "
          f"{diamond(gc, godel, neg(atom('CH')))}")
    print()


def main() -> None:
    demo_godel_cohen()
    demo_forcing_settles_nothing()
    demo_s5_axioms()
    demo_switches()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
