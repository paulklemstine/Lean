"""
Multiverse Set Theory --- The Combinatorial Core.

A self-contained numerical demonstration of the combinatorial model of the
set-theoretic multiverse:

  * a WORLD is a truth assignment to a fixed list of atomic assertions;
  * a SENTENCE is a propositional combination of atoms;
  * a MULTIVERSE is a collection of worlds;
  * a sentence is INDEPENDENT in a multiverse when it is true in some world
    and false in another;
  * FORCING is modeled by the `flip` operation (toggle one atom), and a
    multiverse is FORCING-CLOSED when stable under all flips.

The script reproduces every headline result:
  - the laws of logic are absolute (valid in every multiverse);
  - in a nonempty forcing-closed multiverse every atom is independent;
  - CH is independent in {Godel, Cohen}, and stays independent even after
    adopting (V=L) -> CH as a law;
  - the full multiverse over n atoms has exactly 2**n worlds.

Run with:  python demo.py
"""

from __future__ import annotations

from dataclasses import dataclass
from itertools import product
from typing import Callable, Dict, FrozenSet, Iterable, List, Tuple

# ---------------------------------------------------------------------------
# Sentences: an algebraic data type over a set of atoms (represented as str).
# ---------------------------------------------------------------------------

Atom = str
World = Dict[Atom, bool]          # a truth assignment
Multiverse = List[World]          # a collection of worlds


@dataclass(frozen=True)
class Sentence:
    """A propositional set-theoretic sentence.

    `kind` is one of: 'atom', 'true', 'false', 'neg', 'and', 'or', 'imp'.
    `atom` is set for kind == 'atom'; `left`/`right` for the connectives.
    """
    kind: str
    atom: Atom | None = None
    left: "Sentence | None" = None
    right: "Sentence | None" = None


def atom(a: Atom) -> Sentence:
    return Sentence("atom", atom=a)


TRUE = Sentence("true")
FALSE = Sentence("false")


def neg(p: Sentence) -> Sentence:
    return Sentence("neg", left=p)


def conj(p: Sentence, q: Sentence) -> Sentence:
    return Sentence("and", left=p, right=q)


def disj(p: Sentence, q: Sentence) -> Sentence:
    return Sentence("or", left=p, right=q)


def imp(p: Sentence, q: Sentence) -> Sentence:
    return Sentence("imp", left=p, right=q)


def evaluate(w: World, p: Sentence) -> bool:
    """Boolean evaluation of sentence `p` in world `w`."""
    if p.kind == "atom":
        return w[p.atom]                       # type: ignore[index]
    if p.kind == "true":
        return True
    if p.kind == "false":
        return False
    if p.kind == "neg":
        return not evaluate(w, p.left)          # type: ignore[arg-type]
    if p.kind == "and":
        return evaluate(w, p.left) and evaluate(w, p.right)   # type: ignore[arg-type]
    if p.kind == "or":
        return evaluate(w, p.left) or evaluate(w, p.right)    # type: ignore[arg-type]
    if p.kind == "imp":
        return (not evaluate(w, p.left)) or evaluate(w, p.right)  # type: ignore[arg-type]
    raise ValueError(f"unknown sentence kind: {p.kind}")


def sat(w: World, p: Sentence) -> bool:
    """World `w` satisfies `p`."""
    return evaluate(w, p)


# ---------------------------------------------------------------------------
# Multiverse-relative status of a sentence.
# ---------------------------------------------------------------------------

def is_valid(M: Multiverse, p: Sentence) -> bool:
    return all(sat(w, p) for w in M)


def is_refutable(M: Multiverse, p: Sentence) -> bool:
    return all(not sat(w, p) for w in M)


def is_independent(M: Multiverse, p: Sentence) -> bool:
    return any(sat(w, p) for w in M) and any(not sat(w, p) for w in M)


def is_settled(M: Multiverse, p: Sentence) -> bool:
    return is_valid(M, p) or is_refutable(M, p)


def status(M: Multiverse, p: Sentence) -> str:
    if is_independent(M, p):
        return "INDEPENDENT"
    if is_valid(M, p):
        return "valid"
    if is_refutable(M, p):
        return "refutable"
    return "undetermined (empty multiverse)"


# ---------------------------------------------------------------------------
# Forcing = flip.
# ---------------------------------------------------------------------------

def flip(w: World, a: Atom) -> World:
    """The generic extension of `w` along atom `a`: toggle the value of `a`."""
    new = dict(w)
    new[a] = not new[a]
    return new


def is_forcing_closed(M: Multiverse, atoms: Iterable[Atom]) -> bool:
    keyset = {frozenset(w.items()) for w in M}
    for w in M:
        for a in atoms:
            if frozenset(flip(w, a).items()) not in keyset:
                return False
    return True


def full_multiverse(atoms: List[Atom]) -> Multiverse:
    """Every conceivable world over `atoms`: all 2**n truth assignments."""
    worlds: Multiverse = []
    for bits in product([False, True], repeat=len(atoms)):
        worlds.append({a: b for a, b in zip(atoms, bits)})
    return worlds


# ---------------------------------------------------------------------------
# Demonstrations.
# ---------------------------------------------------------------------------

def demo_absoluteness() -> None:
    print("=" * 70)
    print("1. Absoluteness of logic: laws hold in EVERY multiverse")
    print("=" * 70)
    atoms = ["CH", "VeqL", "Meas"]
    M = full_multiverse(atoms)
    p = atom("CH")
    laws = {
        "excluded middle  p | -p": disj(p, neg(p)),
        "non-contradiction -(p & -p)": neg(conj(p, neg(p))),
        "self-implication  p -> p": imp(p, p),
    }
    for name, s in laws.items():
        print(f"  {name:32s} -> {status(M, s)}")
    print()


def demo_forcing_settles_nothing() -> None:
    print("=" * 70)
    print("2. Headline theorem: in a nonempty forcing-closed multiverse")
    print("   EVERY atom is independent (forcing settles nothing)")
    print("=" * 70)
    atoms = ["CH", "VeqL", "Meas"]
    M = full_multiverse(atoms)
    print(f"  full multiverse forcing-closed? {is_forcing_closed(M, atoms)}")
    print(f"  full multiverse nonempty?       {len(M) > 0}")
    for a in atoms:
        print(f"  atom {a:6s} -> {status(M, atom(a))}")
    print()


def demo_CH_independent() -> None:
    print("=" * 70)
    print("3. The Continuum Hypothesis in {Godel, Cohen}")
    print("=" * 70)
    godel: World = {"CH": True, "VeqL": True, "Meas": False}
    cohen: World = {"CH": False, "VeqL": False, "Meas": False}
    GC: Multiverse = [godel, cohen]
    print(f"  CH               -> {status(GC, atom('CH'))}")
    print(f"  V=L              -> {status(GC, atom('VeqL'))}")
    law = imp(atom("VeqL"), atom("CH"))
    print(f"  (V=L) -> CH      -> {status(GC, law)}   (a settled law!)")
    print()
    print("  Adopt (V=L) -> CH as a law: keep only law-abiding worlds.")
    full3 = full_multiverse(["CH", "VeqL", "Meas"])
    law_mv = [w for w in full3 if sat(w, law)]
    print(f"  law-abiding worlds: {len(law_mv)} of {len(full3)}")
    print(f"  CH in the law multiverse -> {status(law_mv, atom('CH'))}")
    print("  => CH remains INDEPENDENT even after adopting the law.")
    print()


def demo_counting() -> None:
    print("=" * 70)
    print("4. Counting: the full multiverse over n atoms has 2**n worlds")
    print("=" * 70)
    for n in range(0, 6):
        atoms = [f"A{i}" for i in range(n)]
        M = full_multiverse(atoms)
        assert len(M) == 2 ** n
        print(f"  n = {n}: |full| = {len(M):3d}  (2**{n} = {2 ** n})")
    print()
    three = full_multiverse(["CH", "VeqL", "Meas"])
    print(f"  Over {{CH, V=L, Meas}}: {len(three)} worlds (should be 8).")
    print()


def demo_joint_realizability() -> None:
    print("=" * 70)
    print("5. Joint realizability: CH & -(V=L) has a model in the full")
    print("   multiverse (all four joint patterns of two atoms occur)")
    print("=" * 70)
    atoms = ["CH", "VeqL", "Meas"]
    M = full_multiverse(atoms)
    s = conj(atom("CH"), neg(atom("VeqL")))
    print(f"  CH & -(V=L)  -> {status(M, s)}")
    witnesses = [w for w in M if sat(w, s)]
    print(f"  number of witnessing worlds: {len(witnesses)}")
    print(f"  one witness: {witnesses[0]}")
    print()


def main() -> None:
    print()
    print("#" * 70)
    print("#  MULTIVERSE SET THEORY --- Mathematics Across Branches")
    print("#" * 70)
    print()
    demo_absoluteness()
    demo_forcing_settles_nothing()
    demo_CH_independent()
    demo_counting()
    demo_joint_realizability()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
