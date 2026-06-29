"""
Belnap's FOUR: paraconsistency and the product representation FOUR ≅ 2 ⊙ 2.

This self-contained script demonstrates, numerically and exhaustively, the
results proved formally in `Catalog/Logic/BelnapFour/Paraconsistency.lean`:

  * Non-explosion (paraconsistency): the contradiction premise
    `designated(a) ∧ designated(neg a)` is SATISFIABLE (witness B), yet
    does NOT entail an arbitrary conclusion.
  * Classical explosion is vacuous: the Boolean premise `b ∧ ¬b` is
    UNSATISFIABLE, so classical explosion holds only for lack of a witness.
  * The product representation: `toProd : Belnap -> (Bool, Bool)` is a
    bijection under which the two orders and all operations become
    componentwise Boolean operations (knowledge = product order, truth =
    twisted product order, negation = swap, conflation = swap-then-negate).

Run:  python3 demo.py
"""

from __future__ import annotations

from enum import Enum
from itertools import product
from typing import Callable


# ----------------------------------------------------------------------------
# The carrier FOUR = {N, F, T, B}
# ----------------------------------------------------------------------------
class Belnap(Enum):
    N = "N"  # None / Neither : told neither true nor false (a gap)
    F = "F"  # False          : told only false
    T = "T"  # True           : told only true
    B = "B"  # Both           : told both true and false (a glut)


ALL: tuple[Belnap, ...] = (Belnap.N, Belnap.F, Belnap.T, Belnap.B)


# ----------------------------------------------------------------------------
# Product representation: value <-> (evidence_for, evidence_against)
# ----------------------------------------------------------------------------
def to_prod(a: Belnap) -> tuple[bool, bool]:
    """(evidence-for, evidence-against)."""
    return {
        Belnap.N: (False, False),
        Belnap.F: (False, True),
        Belnap.T: (True, False),
        Belnap.B: (True, True),
    }[a]


def of_prod(p: tuple[bool, bool]) -> Belnap:
    return {
        (False, False): Belnap.N,
        (False, True): Belnap.F,
        (True, False): Belnap.T,
        (True, True): Belnap.B,
    }[p]


# ----------------------------------------------------------------------------
# Designation and the involutions
# ----------------------------------------------------------------------------
def designated(a: Belnap) -> bool:
    """The designated ("at least true") values are exactly T and B."""
    return a in (Belnap.T, Belnap.B)


def neg(a: Belnap) -> Belnap:
    """Negation = swap the two coordinates (for <-> against)."""
    f, g = to_prod(a)
    return of_prod((g, f))


def conf(a: Belnap) -> Belnap:
    """Conflation = swap-then-negate: (!against, !for)."""
    f, g = to_prod(a)
    return of_prod((not g, not f))


# ----------------------------------------------------------------------------
# The two orders (defined directly via the product representation)
# ----------------------------------------------------------------------------
def kle(a: Belnap, b: Belnap) -> bool:
    """Knowledge order = product order: more info in BOTH channels."""
    (a1, a2), (b1, b2) = to_prod(a), to_prod(b)
    return (a1 <= b1) and (a2 <= b2)


def tle(a: Belnap, b: Belnap) -> bool:
    """Truth order = twisted product order: more for, LESS against."""
    (a1, a2), (b1, b2) = to_prod(a), to_prod(b)
    return (a1 <= b1) and (b2 <= a2)


# ----------------------------------------------------------------------------
# The four lattice operations (componentwise Boolean)
# ----------------------------------------------------------------------------
def kmeet(a: Belnap, b: Belnap) -> Belnap:  # knowledge meet (consensus)
    (a1, a2), (b1, b2) = to_prod(a), to_prod(b)
    return of_prod((a1 and b1, a2 and b2))


def kjoin(a: Belnap, b: Belnap) -> Belnap:  # knowledge join (gather)
    (a1, a2), (b1, b2) = to_prod(a), to_prod(b)
    return of_prod((a1 or b1, a2 or b2))


def tmeet(a: Belnap, b: Belnap) -> Belnap:  # truth meet (conjunction)
    (a1, a2), (b1, b2) = to_prod(a), to_prod(b)
    return of_prod((a1 and b1, a2 or b2))


def tjoin(a: Belnap, b: Belnap) -> Belnap:  # truth join (disjunction)
    (a1, a2), (b1, b2) = to_prod(a), to_prod(b)
    return of_prod((a1 or b1, a2 and b2))


# ----------------------------------------------------------------------------
# Demonstrations
# ----------------------------------------------------------------------------
def demo_bijection() -> None:
    print("=" * 64)
    print("Theorem 4.1 / 5.1 : toProd is a bijection; |FOUR| = 4")
    print("=" * 64)
    assert all(of_prod(to_prod(a)) == a for a in ALL)
    assert all(to_prod(of_prod(p)) == p for p in product([False, True], repeat=2))
    print("  round-trips verified:  ofProd∘toProd = id  and  toProd∘ofProd = id")
    print(f"  cardinality of FOUR = {len(ALL)} = 2^2\n")


def demo_paraconsistency() -> None:
    print("=" * 64)
    print("Theorems 3.1 & 3.2 : paraconsistency (non-explosion)")
    print("=" * 64)
    witnesses = [a for a in ALL if designated(a) and designated(neg(a))]
    print(f"  contradiction premise satisfiable by: {[w.value for w in witnesses]}")
    assert Belnap.B in witnesses, "B must witness the satisfiable contradiction"

    # explosion would say: forall a q, des(a) & des(neg a) -> des(q)
    explosion_holds = all(
        designated(q)
        for a in ALL
        for q in ALL
        if designated(a) and designated(neg(a))
    )
    print(f"  does explosion hold?  {explosion_holds}")
    assert not explosion_holds, "FOUR must be paraconsistent"
    # explicit counterexample
    a, q = Belnap.B, Belnap.F
    print(f"  counterexample: a=B (designated, neg B=B designated), q=F undesignated")
    assert designated(a) and designated(neg(a)) and not designated(q)
    print("  => a designated contradiction does NOT entail every conclusion.\n")


def demo_classical_vacuous() -> None:
    print("=" * 64)
    print("Theorems 3.3 & 3.4 : classical explosion is VACUOUS")
    print("=" * 64)
    sat = [b for b in (False, True) if b is True and (not b) is True]
    print(f"  classical premise (b and not b) satisfiable by: {sat}  (none!)")
    assert sat == []
    # explosion vacuously true:
    vac = all(
        q is True
        for b in (False, True)
        for q in (False, True)
        if (b is True and (not b) is True)
    )
    print(f"  classical explosion holds vacuously: {vac}")
    assert vac
    print("  => classical logic explodes only because the premise never occurs.\n")


def demo_orders_transport() -> None:
    print("=" * 64)
    print("Theorem 4.2 : orders transport (knowledge=product, truth=twisted)")
    print("=" * 64)

    def bool_le(x: bool, y: bool) -> bool:
        return (not x) or y

    for a, b in product(ALL, repeat=2):
        (a1, a2), (b1, b2) = to_prod(a), to_prod(b)
        assert kle(a, b) == (bool_le(a1, b1) and bool_le(a2, b2))
        assert tle(a, b) == (bool_le(a1, b1) and bool_le(b2, a2))
    print("  knowledge order = product order            (verified, 16 pairs)")
    print("  truth order     = twisted product order    (verified, 16 pairs)\n")


def demo_operations_transport() -> None:
    print("=" * 64)
    print("Theorem 4.3 : every operation is componentwise Boolean")
    print("=" * 64)
    for a, b in product(ALL, repeat=2):
        (a1, a2), (b1, b2) = to_prod(a), to_prod(b)
        assert to_prod(kmeet(a, b)) == (a1 and b1, a2 and b2)
        assert to_prod(kjoin(a, b)) == (a1 or b1, a2 or b2)
        assert to_prod(tmeet(a, b)) == (a1 and b1, a2 or b2)
        assert to_prod(tjoin(a, b)) == (a1 or b1, a2 and b2)
    for a in ALL:
        a1, a2 = to_prod(a)
        assert to_prod(neg(a)) == (a2, a1)
        assert to_prod(conf(a)) == (not a2, not a1)
    print("  ⊗ₖ=(&&,&&)  ⊕ₖ=(||,||)  ⊓ₜ=(&&,||)  ⊔ₜ=(||,&&)")
    print("  neg=swap    conf=swap-then-negate          (all verified)\n")


def demo_two_dimensional() -> None:
    print("=" * 64)
    print("Theorem 5.2 : the two orders are genuinely two-dimensional")
    print("=" * 64)
    t_not_k = [(a, b) for a, b in product(ALL, repeat=2) if tle(a, b) and not kle(a, b)]
    k_not_t = [(a, b) for a, b in product(ALL, repeat=2) if kle(a, b) and not tle(a, b)]
    print(f"  tle but not kle, e.g.: {t_not_k[0][0].value} ≤t {t_not_k[0][1].value}")
    print(f"  kle but not tle, e.g.: {k_not_t[0][0].value} ≤k {k_not_t[0][1].value}")
    assert t_not_k and k_not_t
    print("  => neither order refines the other.\n")


def print_tables() -> None:
    print("=" * 64)
    print("Reference tables")
    print("=" * 64)
    print("  value : (for, against)   designated   neg   conf")
    for a in ALL:
        f, g = to_prod(a)
        print(
            f"    {a.value}   :  ({int(f)}, {int(g)})        "
            f"{str(designated(a)):5}     {neg(a).value}     {conf(a).value}"
        )
    print()


def main() -> None:
    print_tables()
    demo_bijection()
    demo_paraconsistency()
    demo_classical_vacuous()
    demo_orders_transport()
    demo_operations_transport()
    demo_two_dimensional()
    print("All demonstrations passed: FOUR is the smallest paraconsistent bilattice 2 ⊙ 2.")


if __name__ == "__main__":
    main()
