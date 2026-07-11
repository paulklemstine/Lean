"""
Reflective Provability: a self-contained model checker for the provability
modality (Box) and numerical demonstrations of the main results.

We implement propositional modal formulas with a Box modality read as
"is provable", a finite Kripke-model satisfaction checker, and then
demonstrate:

  1. The Goedelian reflection  G(A) = Box A AND NOT Box Box A
     ("A is provable but not provably provable") is SATISFIABLE in an
     explicit non-transitive three-world model.
  2. On every TRANSITIVE frame axiom 4 (Box A -> Box Box A) holds, hence
     G(A) is UNSATISFIABLE there.
  3. Loeb's theorem  Box(Box A -> A) -> Box A  holds on transitive,
     converse-well-founded (GL) frames.
  4. Goedel's second incompleteness theorem  Box(NOT Box _|_) -> Box _|_
     as the A := _|_ instance of Loeb.

Everything is elementary and requires only the standard library.
"""

from __future__ import annotations

from dataclasses import dataclass
from itertools import product
from typing import Callable, Dict, FrozenSet, List, Set, Tuple


# ---------------------------------------------------------------------------
# Syntax:  formulas are nested tuples with a leading tag.
# ---------------------------------------------------------------------------
# ("atom", n)        atom p_n
# ("bot",)           falsum
# ("imp", A, B)      A -> B
# ("box", A)         Box A
Formula = tuple


def atom(n: int) -> Formula:
    return ("atom", n)


BOT: Formula = ("bot",)


def imp(a: Formula, b: Formula) -> Formula:
    return ("imp", a, b)


def box(a: Formula) -> Formula:
    return ("box", a)


def neg(a: Formula) -> Formula:
    """NOT A := A -> _|_."""
    return imp(a, BOT)


def conj(a: Formula, b: Formula) -> Formula:
    """A AND B := NOT (A -> NOT B)."""
    return neg(imp(a, neg(b)))


def dia(a: Formula) -> Formula:
    """Diamond A := NOT Box NOT A."""
    return neg(box(neg(a)))


def godelian_reflection(a: Formula) -> Formula:
    """G(A) = Box A AND NOT Box Box A."""
    return conj(box(a), neg(box(box(a))))


# ---------------------------------------------------------------------------
# Semantics:  a finite Kripke model over integer-labelled worlds.
# ---------------------------------------------------------------------------
@dataclass(frozen=True)
class Model:
    worlds: Tuple[int, ...]
    # accessibility relation as a set of (w, v) pairs meaning w R v
    relation: FrozenSet[Tuple[int, int]]
    # valuation: (atom_index, world) -> bool
    valuation: Callable[[int, int], bool]

    def successors(self, w: int) -> List[int]:
        return [v for v in self.worlds if (w, v) in self.relation]


def sat(m: Model, phi: Formula, w: int) -> bool:
    """Does formula phi hold at world w of model m?"""
    tag = phi[0]
    if tag == "atom":
        return m.valuation(phi[1], w)
    if tag == "bot":
        return False
    if tag == "imp":
        return (not sat(m, phi[1], w)) or sat(m, phi[2], w)
    if tag == "box":
        return all(sat(m, phi[1], v) for v in m.successors(w))
    raise ValueError(f"unknown formula tag: {tag}")


def valid(m: Model, phi: Formula) -> bool:
    return all(sat(m, phi, w) for w in m.worlds)


def is_transitive(m: Model) -> bool:
    r = m.relation
    return all(
        (a, c) in r
        for (a, b) in r
        for (b2, c) in r
        if b == b2
    )


# ---------------------------------------------------------------------------
# The witnessing model  a -> b -> c,  atoms true exactly at b.
# ---------------------------------------------------------------------------
A_W, B_W, C_W = 0, 1, 2


def witness_model() -> Model:
    return Model(
        worlds=(A_W, B_W, C_W),
        relation=frozenset({(A_W, B_W), (B_W, C_W)}),
        valuation=lambda n, w: w == B_W,
    )


# ---------------------------------------------------------------------------
# Enumerate all finite frames on `size` worlds (for brute-force checks).
# ---------------------------------------------------------------------------
def all_relations(size: int) -> List[FrozenSet[Tuple[int, int]]]:
    pairs = [(i, j) for i in range(size) for j in range(size)]
    rels: List[FrozenSet[Tuple[int, int]]] = []
    for bits in product([False, True], repeat=len(pairs)):
        rels.append(frozenset(p for p, b in zip(pairs, bits) if b))
    return rels


def all_valuations(size: int, n_atoms: int) -> List[Callable[[int, int], bool]]:
    slots = [(a, w) for a in range(n_atoms) for w in range(size)]
    vals: List[Callable[[int, int], bool]] = []
    for bits in product([False, True], repeat=len(slots)):
        table: Dict[Tuple[int, int], bool] = dict(zip(slots, bits))
        vals.append(lambda a, w, t=table: t.get((a, w), False))
    return vals


def is_conversely_well_founded(m: Model) -> bool:
    """Finite frame: converse-well-founded iff no forward cycle (acyclic)."""
    r = m.relation
    # detect a cycle via DFS
    color: Dict[int, int] = {w: 0 for w in m.worlds}

    def dfs(u: int) -> bool:
        color[u] = 1
        for v in m.successors(u):
            if color[v] == 1:
                return True
            if color[v] == 0 and dfs(v):
                return True
        color[u] = 2
        return False

    return not any(color[w] == 0 and dfs(w) for w in m.worlds)


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------
def demo_satisfiable() -> None:
    print("=" * 68)
    print("1. Goedelian reflection is SATISFIABLE (non-transitive witness)")
    print("=" * 68)
    m = witness_model()
    A = atom(0)
    print(f"  Model worlds: a=0, b=1, c=2   relation: a->b, b->c")
    print(f"  Box A at a          : {sat(m, box(A), A_W)}")
    print(f"  Box Box A at a      : {sat(m, box(box(A)), A_W)}")
    print(f"  G(A) = Box A & ~Box Box A at a : {sat(m, godelian_reflection(A), A_W)}")
    print(f"  Model transitive?   : {is_transitive(m)}")
    assert sat(m, godelian_reflection(A), A_W)
    assert not is_transitive(m)
    print("  --> satisfiable in a genuinely non-transitive model. OK\n")


def demo_transitive_dichotomy() -> None:
    print("=" * 68)
    print("2. On TRANSITIVE frames: axiom 4 holds, G(A) is UNSATISFIABLE")
    print("=" * 68)
    size, n_atoms = 3, 1
    A = atom(0)
    checked = 0
    sat_count = 0
    for rel in all_relations(size):
        m0 = Model(tuple(range(size)), rel, lambda n, w: False)
        if not is_transitive(m0):
            continue
        for val in all_valuations(size, n_atoms):
            m = Model(tuple(range(size)), rel, val)
            checked += 1
            # axiom 4 must be valid
            assert valid(m, imp(box(A), box(box(A))))
            # G(A) must be nowhere satisfied
            if any(sat(m, godelian_reflection(A), w) for w in m.worlds):
                sat_count += 1
    print(f"  Transitive models checked (3 worlds, 1 atom): {checked}")
    print(f"  Axiom 4 (Box A -> Box Box A) valid in all    : True")
    print(f"  Models where G(A) satisfiable                : {sat_count}")
    assert sat_count == 0
    print("  --> provable ALWAYS implies provably provable. OK\n")


def demo_loeb() -> None:
    print("=" * 68)
    print("3. Loeb's theorem on transitive, acyclic (GL) frames")
    print("=" * 68)
    size, n_atoms = 3, 1
    A = atom(0)
    loeb = imp(box(imp(box(A), A)), box(A))
    gl_models = 0
    for rel in all_relations(size):
        m0 = Model(tuple(range(size)), rel, lambda n, w: False)
        if not (is_transitive(m0) and is_conversely_well_founded(m0)):
            continue
        for val in all_valuations(size, n_atoms):
            m = Model(tuple(range(size)), rel, val)
            gl_models += 1
            assert valid(m, loeb)
    print(f"  GL models checked (transitive + acyclic): {gl_models}")
    print(f"  Loeb schema Box(Box A -> A) -> Box A valid in all: True")
    print("  --> Loeb's theorem verified on all small GL frames. OK\n")


def demo_godel2() -> None:
    print("=" * 68)
    print("4. Goedel's second incompleteness theorem (A := _|_)")
    print("=" * 68)
    size = 3
    godel2 = imp(box(neg(box(BOT))), box(BOT))  # Box(~Box _|_) -> Box _|_
    gl_models = 0
    for rel in all_relations(size):
        m = Model(tuple(range(size)), rel, lambda n, w: False)
        if not (is_transitive(m) and is_conversely_well_founded(m)):
            continue
        gl_models += 1
        assert valid(m, godel2)
    print(f"  GL frames checked: {gl_models}")
    print(f"  Box(~Box _|_) -> Box _|_ valid in all: True")
    print("  --> a consistent GL system cannot prove its own consistency. OK\n")


def main() -> None:
    demo_satisfiable()
    demo_transitive_dichotomy()
    demo_loeb()
    demo_godel2()
    print("All demonstrations passed.")


if __name__ == "__main__":
    main()
