"""
demo.py — A finite infinitesimal probability model.

Numerical demonstration of the non-Archimedean probability measure formalized in
the accompanying Lean development. Probability values live in the ring

    LexRat = Q x Q,   read as   (a, b) := a + b*eps,

with eps a single positive infinitesimal, componentwise addition, and a
*lexicographic* order under which eps is positive but smaller than every positive
rational. For each n, the sample space is Option(Fin n): n "visible" atoms each of
weight eps, plus one "reservoir" atom of weight 1 - n*eps, so that the total mass
is exactly 1.

All arithmetic is exact (Python's fractions.Fraction). Each demo prints the
mathematical fact it verifies, mirroring a theorem from the formal development:

    eps_infinitesimal, prob_eq_closed_form, prob_nonneg,
    prob_union_disjoint, prob_univ, visible_singleton_infinitesimal.
"""

from __future__ import annotations

from dataclasses import dataclass
from fractions import Fraction
from typing import Iterable, Optional


# --------------------------------------------------------------------------- #
#  The value ring LexRat = Q x Q, read as (std, inf) := std + inf * eps         #
# --------------------------------------------------------------------------- #
@dataclass(frozen=True)
class LexRat:
    """An element a + b*eps of the lexicographically ordered ring Q x Q."""

    std: Fraction  # standard (order-0) coefficient a
    inf: Fraction  # infinitesimal (order-1) coefficient b

    @staticmethod
    def of_rat(q: Fraction) -> "LexRat":
        return LexRat(Fraction(q), Fraction(0))

    def __add__(self, other: "LexRat") -> "LexRat":
        return LexRat(self.std + other.std, self.inf + other.inf)

    def __sub__(self, other: "LexRat") -> "LexRat":
        return LexRat(self.std - other.std, self.inf - other.inf)

    def __neg__(self) -> "LexRat":
        return LexRat(-self.std, -self.inf)

    def lex_lt(self, other: "LexRat") -> bool:
        """Strict lexicographic order: std dominates, inf breaks ties."""
        if self.std != other.std:
            return self.std < other.std
        return self.inf < other.inf

    def lex_le(self, other: "LexRat") -> bool:
        if self.std != other.std:
            return self.std < other.std
        return self.inf <= other.inf

    def is_nonneg(self) -> bool:
        return ZERO.lex_le(self)

    def __repr__(self) -> str:
        return f"({self.std} + {self.inf}*eps)"


ZERO: LexRat = LexRat(Fraction(0), Fraction(0))
ONE: LexRat = LexRat(Fraction(1), Fraction(0))
EPS: LexRat = LexRat(Fraction(0), Fraction(1))


# --------------------------------------------------------------------------- #
#  The model: sample space Option(Fin n), atom weights, and the measure         #
# --------------------------------------------------------------------------- #
# We represent an outcome as Optional[int]: None is the reservoir atom; an
# integer i in range(n) is the visible atom "some i". An event is a set of these.

def atom_weight(n: int, x: Optional[int]) -> LexRat:
    """Weight of a single atom: reservoir = 1 - n*eps, visible = eps."""
    if x is None:
        return LexRat(Fraction(1), Fraction(-n))
    return EPS


def prob_direct(n: int, event: Iterable[Optional[int]]) -> LexRat:
    """Probability as the finite sum of atom weights (the definition `prob`)."""
    total = ZERO
    for x in set(event):
        total = total + atom_weight(n, x)
    return total


def prob_closed(n: int, event: Iterable[Optional[int]]) -> LexRat:
    """Closed form (`prob_eq_closed_form`).

    std coordinate = 1 if reservoir present else 0;
    inf coordinate = (number of visible atoms) - (n if reservoir present else 0).
    """
    ev = set(event)
    has_reservoir = None in ev
    visible = sum(1 for x in ev if x is not None)
    std = Fraction(1) if has_reservoir else Fraction(0)
    inf = Fraction(visible) - (Fraction(n) if has_reservoir else Fraction(0))
    return LexRat(std, inf)


def universe(n: int) -> set:
    """The whole sample space: reservoir plus all n visible atoms."""
    return {None} | set(range(n))


# --------------------------------------------------------------------------- #
#  Demonstrations                                                               #
# --------------------------------------------------------------------------- #
def demo_eps_infinitesimal() -> None:
    print("=" * 70)
    print("THEOREM eps_infinitesimal:  eps is positive but below every q > 0")
    print("=" * 70)
    print(f"  0 < eps ?  {ZERO.lex_lt(EPS)}")
    for q in [Fraction(1, 2), Fraction(1, 1000), Fraction(1, 10**9)]:
        print(f"  eps < {q!s:>12} ?  {EPS.lex_lt(LexRat.of_rat(q))}")
    print("  => eps is a genuine infinitesimal.\n")


def demo_closed_form_matches_direct() -> None:
    print("=" * 70)
    print("THEOREM prob_eq_closed_form:  closed form == direct summation")
    print("=" * 70)
    n = 5
    events = [
        set(),
        {0},
        {None},
        {0, 2, 4},
        {None, 1, 3},
        universe(n),
    ]
    for ev in events:
        d, c = prob_direct(n, ev), prob_closed(n, ev)
        tag = sorted((str(x) for x in ev)) or ["(empty)"]
        print(f"  A={tag!s:<28} direct={d}  closed={c}  match={d == c}")
    print()


def demo_singletons() -> None:
    print("=" * 70)
    print("THEOREM visible_singleton_infinitesimal & prob_singleton_none")
    print("=" * 70)
    n = 4
    print(f"  prob({{some 0}})  = {prob_direct(n, {0})}   == eps ? {prob_direct(n, {0}) == EPS}")
    print(f"  prob({{some 0}}) < 1 ? {prob_direct(n, {0}).lex_lt(ONE)}  (positive but infinitesimal)")
    print(f"  prob({{none}})    = {prob_direct(n, {None})}   (reservoir: 1 - n*eps)")
    print()


def demo_normalization() -> None:
    print("=" * 70)
    print("THEOREM prob_univ:  total mass is exactly 1")
    print("=" * 70)
    for n in [1, 3, 10, 100]:
        p = prob_direct(n, universe(n))
        print(f"  n={n:<4} prob(univ) = {p}   == 1 ? {p == ONE}")
    print("  Infinitesimal parts cancel: n*eps + (1 - n*eps) = 1.\n")


def demo_finite_additivity() -> None:
    print("=" * 70)
    print("THEOREM prob_union_disjoint:  prob(A u B) = prob A + prob B (disjoint)")
    print("=" * 70)
    n = 6
    A, B = {0, 1, None}, {2, 3, 4}  # disjoint
    lhs = prob_direct(n, A | B)
    rhs = prob_direct(n, A) + prob_direct(n, B)
    print(f"  A={sorted(map(str,A))}  B={sorted(map(str,B))}  disjoint={A.isdisjoint(B)}")
    print(f"  prob(A u B) = {lhs}")
    print(f"  prob A + prob B = {rhs}")
    print(f"  equal ? {lhs == rhs}\n")


def demo_nonnegativity() -> None:
    print("=" * 70)
    print("THEOREM prob_nonneg:  every event has nonnegative probability")
    print("=" * 70)
    n = 5
    import itertools
    atoms = [None] + list(range(n))
    all_nonneg = True
    count = 0
    for r in range(len(atoms) + 1):
        for ev in itertools.combinations(atoms, r):
            count += 1
            if not prob_direct(n, set(ev)).is_nonneg():
                all_nonneg = False
    print(f"  checked all {count} events over n={n}: all nonneg ? {all_nonneg}\n")


def demo_no_overflow() -> None:
    print("=" * 70)
    print("Finitely many visible atoms never reach 1 (the lottery is fair)")
    print("=" * 70)
    for n in [10, 100, 1000]:
        visible_all = prob_direct(n, set(range(n)))  # all visible, no reservoir
        print(f"  n={n:<5} sum of all visible = {visible_all}  < 1 ? {visible_all.lex_lt(ONE)}")
    print()


def main() -> None:
    demo_eps_infinitesimal()
    demo_closed_form_matches_direct()
    demo_singletons()
    demo_normalization()
    demo_finite_additivity()
    demo_nonnegativity()
    demo_no_overflow()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
