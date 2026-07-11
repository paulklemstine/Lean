"""
Transreal Arithmetic --- Numerical Demonstrations
=================================================

A self-contained implementation of Anderson's transreal number system

    T = R  U  { -inf, PHI, +inf }

with TOTAL operations: every arithmetic expression has a value, including
1/0 = +inf, 0/0 = PHI, inf - inf = PHI, and 0 * inf = PHI.

This script implements the arithmetic from scratch and then *demonstrates*,
by direct computation, the main theorems of the accompanying paper:

  * Totality of the operations.
  * PHI (nullity) is absorbing.
  * Commutative-monoid structure survives.
  * The ring axioms fail:
        - infinities have no additive inverse,
        - zero fails to annihilate  (0 * inf = PHI),
        - distributivity fails       (witness: inf*(1 + -inf) != inf*1 + inf*-inf).
  * The transreals are NOT a wheel:
        - infinity is signed          (inf + inf = inf, not the wheel's bottom),
        - reciprocal is not involutive (fails at -inf).

Run:  python3 demo.py
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Iterator, List, Tuple, Callable
import itertools


# --------------------------------------------------------------------------- #
#  The transreal number type
# --------------------------------------------------------------------------- #
@dataclass(frozen=True)
class Transreal:
    """A transreal number.

    kind == "fin"  -> an ordinary real, stored in `value`
    kind == "pinf" -> +infinity
    kind == "ninf" -> -infinity
    kind == "phi"  -> nullity (the value of 0/0)
    """
    kind: str
    value: float = 0.0

    def __repr__(self) -> str:
        return {
            "pinf": "+inf",
            "ninf": "-inf",
            "phi": "PHI",
        }.get(self.kind, _fmt(self.value))

    # Structural equality on the represented transreal value.
    def __eq__(self, other: object) -> bool:
        if not isinstance(other, Transreal):
            return NotImplemented
        if self.kind != other.kind:
            return False
        return self.kind != "fin" or self.value == other.value

    def __hash__(self) -> int:
        return hash((self.kind, self.value if self.kind == "fin" else 0.0))


def _fmt(x: float) -> str:
    return str(int(x)) if float(x).is_integer() else str(x)


# Constructors / constants.
def real(x: float) -> Transreal:
    return Transreal("fin", float(x))


PINF: Transreal = Transreal("pinf")
NINF: Transreal = Transreal("ninf")
PHI: Transreal = Transreal("phi")
ZERO: Transreal = real(0.0)
ONE: Transreal = real(1.0)


def _sign(t: Transreal) -> int:
    """Sign of a strict (non-PHI) element: -1, 0, or +1."""
    if t.kind == "pinf":
        return 1
    if t.kind == "ninf":
        return -1
    if t.value > 0:
        return 1
    if t.value < 0:
        return -1
    return 0


# --------------------------------------------------------------------------- #
#  Total operations (Definitions 2.2 - 2.5 of the paper)
# --------------------------------------------------------------------------- #
def neg(x: Transreal) -> Transreal:
    if x.kind == "phi":
        return PHI
    if x.kind == "pinf":
        return NINF
    if x.kind == "ninf":
        return PINF
    return real(-x.value)


def recip(x: Transreal) -> Transreal:
    """Reciprocal: 1/0 = +inf, 1/(+-inf) = 0, 1/PHI = PHI."""
    if x.kind == "phi":
        return PHI
    if x.kind in ("pinf", "ninf"):
        return ZERO
    if x.value == 0.0:
        return PINF
    return real(1.0 / x.value)


def add(x: Transreal, y: Transreal) -> Transreal:
    if x.kind == "phi" or y.kind == "phi":
        return PHI
    if x.kind == "fin" and y.kind == "fin":
        return real(x.value + y.value)
    # At least one infinite, neither PHI.
    xi = x.kind in ("pinf", "ninf")
    yi = y.kind in ("pinf", "ninf")
    if xi and yi:
        return PHI if x.kind != y.kind else x  # inf + inf = inf; inf + -inf = PHI
    # exactly one infinite -> that infinity wins
    return x if xi else y


def mul(x: Transreal, y: Transreal) -> Transreal:
    if x.kind == "phi" or y.kind == "phi":
        return PHI
    if x.kind == "fin" and y.kind == "fin":
        return real(x.value * y.value)
    # At least one infinite, neither PHI.
    sx, sy = _sign(x), _sign(y)
    if sx == 0 or sy == 0:          # 0 * inf  (or inf * 0)
        return PHI
    return PINF if sx * sy > 0 else NINF


def sub(x: Transreal, y: Transreal) -> Transreal:
    return add(x, neg(y))


def div(x: Transreal, y: Transreal) -> Transreal:
    return mul(x, recip(y))


# --------------------------------------------------------------------------- #
#  A small, representative test set (one per sign / edge class)
# --------------------------------------------------------------------------- #
TEST_SET: List[Transreal] = [real(-2), real(-1), ZERO, real(1), real(2), NINF, PHI, PINF]


# --------------------------------------------------------------------------- #
#  Demonstrations
# --------------------------------------------------------------------------- #
def demo_defining_identities() -> None:
    print("=" * 68)
    print("1.  Defining identities: division is total")
    print("=" * 68)
    print(f"   1 / 0   = {div(ONE, ZERO)}          (should be +inf)")
    print(f"  -1 / 0   = {div(neg(ONE), ZERO)}          (should be -inf)")
    print(f"   0 / 0   = {div(ZERO, ZERO)}           (should be PHI)")
    print(f"  inf - inf= {sub(PINF, PINF)}           (should be PHI)")
    print(f"   0 * inf = {mul(ZERO, PINF)}           (should be PHI)")
    print()


def demo_absorption() -> None:
    print("=" * 68)
    print("2.  Nullity PHI is absorbing (a bottom element)")
    print("=" * 68)
    for t in TEST_SET:
        assert add(PHI, t) == PHI and mul(PHI, t) == PHI
    print("  PHI + t = PHI  and  PHI * t = PHI  for every t in the test set.  [OK]")
    print(f"  -PHI = {neg(PHI)},   1/PHI = {recip(PHI)}")
    print()


def demo_monoid() -> None:
    print("=" * 68)
    print("3.  Commutative-monoid structure survives")
    print("=" * 68)
    comm_add = all(add(a, b) == add(b, a) for a in TEST_SET for b in TEST_SET)
    comm_mul = all(mul(a, b) == mul(b, a) for a in TEST_SET for b in TEST_SET)
    assoc_add = all(
        add(add(a, b), c) == add(a, add(b, c))
        for a in TEST_SET for b in TEST_SET for c in TEST_SET
    )
    assoc_mul = all(
        mul(mul(a, b), c) == mul(a, mul(b, c))
        for a in TEST_SET for b in TEST_SET for c in TEST_SET
    )
    ident = all(add(ZERO, t) == t and mul(ONE, t) == t for t in TEST_SET)
    print(f"  addition:       commutative={comm_add}, associative={assoc_add}, id 0 ={ident}")
    print(f"  multiplication: commutative={comm_mul}, associative={assoc_mul}, id 1 ={ident}")
    assert comm_add and comm_mul and assoc_add and assoc_mul and ident
    print("  Both (T,+,0) and (T,*,1) are commutative monoids.  [OK]")
    print()


def demo_ring_failures() -> None:
    print("=" * 68)
    print("4.  The ring axioms FAIL")
    print("=" * 68)

    # (a) No additive inverse for +inf.
    reachable = {add(PINF, t) for t in TEST_SET}
    print(f"  (a) +inf + t  ranges over {sorted(map(str, reachable))};")
    print(f"      0 is never reached  ->  +inf has no additive inverse.")
    assert ZERO not in reachable

    # (b) Annihilation fails.
    print(f"  (b) 0 * (+inf) = {mul(ZERO, PINF)}  != 0   ->  zero does not annihilate.")
    assert mul(ZERO, PINF) == PHI

    # (c) Distributivity fails with an explicit witness.
    a, b, c = PINF, ONE, NINF
    lhs = mul(a, add(b, c))
    rhs = add(mul(a, b), mul(a, c))
    print(f"  (c) a*(b+c) with a=+inf, b=1, c=-inf:")
    print(f"          a*(b+c) = +inf*(1 + -inf) = +inf*(-inf) = {lhs}")
    print(f"          a*b+a*c = +inf*1 + +inf*(-inf) = +inf + -inf = {rhs}")
    print(f"          {lhs}  !=  {rhs}   ->  distributivity fails.")
    assert lhs != rhs
    print()


def find_distributivity_counterexamples() -> List[Tuple[Transreal, Transreal, Transreal]]:
    """Brute-force search of the test set for a*(b+c) != a*b + a*c."""
    out: List[Tuple[Transreal, Transreal, Transreal]] = []
    for a, b, c in itertools.product(TEST_SET, repeat=3):
        if mul(a, add(b, c)) != add(mul(a, b), mul(a, c)):
            out.append((a, b, c))
    return out


def demo_axiom_auditor() -> None:
    print("=" * 68)
    print("5.  Axiom auditor: automatically discover distributivity failures")
    print("=" * 68)
    cex = find_distributivity_counterexamples()
    print(f"  Found {len(cex)} counterexamples to a*(b+c) = a*b + a*c on the test set.")
    for a, b, c in cex[:6]:
        print(f"    a={a!s:>5}, b={b!s:>5}, c={c!s:>5} : "
              f"LHS={mul(a, add(b, c))!s:>5}  RHS={add(mul(a,b), mul(a,c))!s:>5}")
    print("    ...")
    print()


def demo_not_a_wheel() -> None:
    print("=" * 68)
    print("6.  The transreals are NOT a wheel")
    print("=" * 68)
    # Signed infinity: inf + inf = inf (a wheel would give the bottom element).
    print(f"  (a) +inf + +inf = {add(PINF, PINF)}   (signed: a wheel forces the bottom here)")
    assert add(PINF, PINF) == PINF

    # Reciprocal is total but not involutive.
    print("  (b) Double reciprocal 1/(1/x):")
    for x in [real(3), ZERO, PINF, NINF]:
        rr = recip(recip(x))
        flag = "" if rr == x else "   <-- NOT restored!"
        print(f"        x = {x!s:>5} :  1/(1/x) = {rr!s:>5}{flag}")
    assert recip(recip(NINF)) == PINF and recip(recip(NINF)) != NINF
    print("      Reciprocal is total but fails involution at -inf.")
    print()


def demo_indeterminate_forms() -> None:
    print("=" * 68)
    print("7.  PHI names the classical indeterminate forms")
    print("=" * 68)
    # 0 * inf and inf - inf approached numerically both 'want' to be PHI.
    print("  Sequences illustrating why 0*inf and inf-inf are indeterminate:")
    for n in (1.0, 10.0, 100.0):
        # a_n -> 0, b_n -> inf, but a_n * b_n depends on the chosen rates
        print(f"    n={n:5.0f}:  (1/n)*(n)={ (1/n)*n :>4},  (1/n)*(n*n)={ (1/n)*(n*n) :>6},"
              f"  (5/n)*(n)={ (5/n)*n :>4}")
    print("  Different rates give different finite/infinite limits -> genuinely")
    print(f"  indeterminate, so the transreals assign the dedicated value: 0*inf = {mul(ZERO, PINF)}.")
    print()


def main() -> None:
    demo_defining_identities()
    demo_absorption()
    demo_monoid()
    demo_ring_failures()
    demo_axiom_auditor()
    demo_not_a_wheel()
    demo_indeterminate_forms()
    print("All demonstrations completed successfully.")


if __name__ == "__main__":
    main()
