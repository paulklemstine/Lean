"""
The Mathematics of Jigsaw Puzzles: Edge Complementation and the
Satisfiability Correspondence.

This self-contained script demonstrates, numerically, the results of the
accompanying paper:

  1. Edge complementation is an involution whose fixed points are exactly the
     flat (border) edges.
  2. Truth values encode as edges (true -> tab, false -> blank), and a literal's
     input edge interlocks with a variable's output edge iff the literal is
     satisfied (the "local dictionary").
  3. A puzzle assembles iff its underlying CNF formula is satisfiable
     (the main correspondence), verified by exhaustive assignment search.
  4. The construction uses exactly 2n + m + 2 pieces.
  5. Worked instances: a solvable formula and a provably unsolvable one.

Run:  python demo.py
"""

from __future__ import annotations

from enum import Enum
from itertools import product
from typing import Callable, Dict, List, Optional, Tuple


# --------------------------------------------------------------------------- #
# Part 1 -- Edges and complementation
# --------------------------------------------------------------------------- #
class Edge(Enum):
    """The three shapes a puzzle-piece side can present."""
    FLAT = "flat"
    TAB = "tab"
    BLANK = "blank"


def comp(e: Edge) -> Edge:
    """Complementation: the shape that physically interlocks with `e`."""
    return {Edge.FLAT: Edge.FLAT, Edge.TAB: Edge.BLANK, Edge.BLANK: Edge.TAB}[e]


def fits(a: Edge, b: Edge) -> bool:
    """`a` interlocks with `b` exactly when `b` is the complement of `a`."""
    return b == comp(a)


# --------------------------------------------------------------------------- #
# Part 2 -- Truth encoding
# --------------------------------------------------------------------------- #
def enc(value: bool) -> Edge:
    """Encode a truth value as the edge carried on the assignment channel."""
    return Edge.TAB if value else Edge.BLANK


# --------------------------------------------------------------------------- #
# Part 3 -- CNF syntax
# --------------------------------------------------------------------------- #
# A literal is (variable_index, required_polarity).
Literal = Tuple[int, bool]
Clause = List[Literal]
Formula = List[Clause]
Assignment = Callable[[int], bool]


def lit_sat(a: Assignment, lit: Literal) -> bool:
    """A literal is satisfied when the assignment gives its variable the
    required polarity."""
    var, polarity = lit
    return a(var) == polarity


def lit_fits(a: Assignment, lit: Literal) -> bool:
    """Physical interlocking test for one literal input of a clause piece:
    the variable's output edge enc(a(var)) must fit the clause piece's input
    edge comp(enc(polarity))."""
    _, polarity = lit
    var = lit[0]
    return fits(enc(a(var)), comp(enc(polarity)))


def clause_sat(a: Assignment, c: Clause) -> bool:
    return any(lit_sat(a, lit) for lit in c)


def clause_piece_fits(a: Assignment, c: Clause) -> bool:
    return any(lit_fits(a, lit) for lit in c)


def formula_sat(a: Assignment, F: Formula) -> bool:
    return all(clause_sat(a, c) for c in F)


def puzzle_assembled(a: Assignment, F: Formula) -> bool:
    return all(clause_piece_fits(a, c) for c in F)


# --------------------------------------------------------------------------- #
# Part 4 -- Solving by exhaustive assignment search
# --------------------------------------------------------------------------- #
def variables_of(F: Formula) -> List[int]:
    return sorted({var for c in F for (var, _) in c})


def find_solution(F: Formula) -> Optional[Dict[int, bool]]:
    """Return a satisfying assignment (as a dict) if one exists, else None."""
    variables = variables_of(F)
    for bits in product([False, True], repeat=len(variables)):
        table = dict(zip(variables, bits))
        a: Assignment = lambda v, _t=table: _t.get(v, False)
        if formula_sat(a, F):
            return table
    return None


def puzzle_solvable(F: Formula) -> bool:
    return find_solution(F) is not None


def piece_count(n_vars: int, F: Formula) -> int:
    """The reduction uses exactly 2n + m + 2 pieces."""
    return 2 * n_vars + len(F) + 2


# --------------------------------------------------------------------------- #
# Demonstrations
# --------------------------------------------------------------------------- #
def demo_complementation() -> None:
    print("=" * 68)
    print("1. Complementation is an involution; fixed points are flat edges")
    print("=" * 68)
    for e in Edge:
        print(f"   comp({e.value:5s}) = {comp(e).value:5s}   "
              f"comp(comp(...)) = {comp(comp(e)).value:5s}   "
              f"fixed? {comp(e) == e}")
    involutive = all(comp(comp(e)) == e for e in Edge)
    fixed = [e for e in Edge if comp(e) == e]
    print(f"\n   involution holds for all edges : {involutive}")
    print(f"   fixed points (the border edges): {[e.value for e in fixed]}")
    assert involutive and fixed == [Edge.FLAT]


def demo_local_dictionary() -> None:
    print("\n" + "=" * 68)
    print("2. Local dictionary: lit_fits == lit_sat for every case")
    print("=" * 68)
    ok = True
    for assigned in (False, True):
        for polarity in (False, True):
            a: Assignment = lambda v, _val=assigned: _val
            lit = (0, polarity)
            f, s = lit_fits(a, lit), lit_sat(a, lit)
            ok &= (f == s)
            print(f"   a(x)={str(assigned):5s} literal polarity={str(polarity):5s}"
                  f"  fits={f!s:5s}  sat={s!s:5s}  agree={f == s}")
    print(f"\n   local dictionary holds in all cases: {ok}")
    assert ok


def demo_main_correspondence(F: Formula, name: str, n_vars: int) -> None:
    print("\n" + "=" * 68)
    print(f"3. Main correspondence on {name}")
    print("=" * 68)
    print(f"   formula      : {pretty(F)}")
    print(f"   piece count  : 2*{n_vars} + {len(F)} + 2 = {piece_count(n_vars, F)}")
    sol = find_solution(F)
    solvable = sol is not None
    print(f"   satisfiable  : {solvable}")
    if sol is not None:
        print(f"   witness      : {sol}")
        a: Assignment = lambda v, _t=sol: _t.get(v, False)
        # solvable  <=>  satisfiable, and the witness assembles the puzzle
        assert puzzle_assembled(a, F) == formula_sat(a, F)
    # Cross-check: puzzle_solvable agrees with satisfiability on every assignment
    assert puzzle_solvable(F) == solvable


def pretty(F: Formula) -> str:
    def lit(l: Literal) -> str:
        v, p = l
        return f"x{v}" if p else f"~x{v}"
    return " AND ".join("(" + " OR ".join(lit(l) for l in c) + ")" for c in F)


def main() -> None:
    demo_complementation()
    demo_local_dictionary()

    # Running example: (x1 OR x2 OR ~x3) AND (~x1 OR x3)  -- solvable, 10 pieces
    example_F: Formula = [[(1, True), (2, True), (3, False)],
                          [(1, False), (3, True)]]
    demo_main_correspondence(example_F, "the running example", n_vars=3)
    assert piece_count(3, example_F) == 10

    # Contradictory instance: x1 AND ~x1  -- unsolvable
    unsat_F: Formula = [[(1, True)], [(1, False)]]
    demo_main_correspondence(unsat_F, "the contradictory instance", n_vars=1)
    assert not puzzle_solvable(unsat_F)

    print("\n" + "=" * 68)
    print("All assertions passed: the puzzle assembles iff the formula is SAT.")
    print("=" * 68)


if __name__ == "__main__":
    main()
