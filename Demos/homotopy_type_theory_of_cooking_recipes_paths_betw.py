"""
Numerical demonstrations of the Eckmann--Hilton argument.

An *interchange structure* on a finite carrier is a pair of binary operations
(vcomp, hcomp) sharing a two-sided unit and satisfying the interchange law

    (a * b) o (c * d) = (a o c) * (b o d)

where 'o' = vcomp (series composition) and '*' = hcomp (parallel composition).

The Eckmann--Hilton theorem states that any such structure forces:
  1. vcomp == hcomp                     (the two operations coincide),
  2. the common operation is commutative,
  3. the common operation is associative,
so the carrier is a commutative monoid.

This file demonstrates all three conclusions on concrete finite structures,
and shows that dropping either hypothesis breaks the conclusion.

Interpretation (recipes / homotopy of dishes): elements are cooking METHODS,
vcomp combines methods "in series", hcomp combines them "in parallel", and the
unit is the trivial "do nothing" method.
"""

from __future__ import annotations

from itertools import product
from typing import Callable, List, Tuple

BinOp = Callable[[int, int], int]


# ---------------------------------------------------------------------------
# Verification of the interchange-structure axioms
# ---------------------------------------------------------------------------

def is_two_sided_unit(op: BinOp, elems: List[int], unit: int) -> bool:
    """Return True iff `unit` is a two-sided identity for `op` on `elems`."""
    return all(op(unit, a) == a and op(a, unit) == a for a in elems)


def satisfies_interchange(vcomp: BinOp, hcomp: BinOp, elems: List[int]) -> bool:
    """Check (a*b) o (c*d) == (a o c) * (b o d) for all quadruples.  O(|elems|^4)."""
    for a, b, c, d in product(elems, repeat=4):
        lhs = vcomp(hcomp(a, b), hcomp(c, d))
        rhs = hcomp(vcomp(a, c), vcomp(b, d))
        if lhs != rhs:
            return False
    return True


def is_interchange_structure(
    vcomp: BinOp, hcomp: BinOp, elems: List[int], unit: int
) -> bool:
    """Verify all axioms of an interchange structure."""
    return (
        is_two_sided_unit(vcomp, elems, unit)
        and is_two_sided_unit(hcomp, elems, unit)
        and satisfies_interchange(vcomp, hcomp, elems)
    )


# ---------------------------------------------------------------------------
# Auditing the Eckmann--Hilton conclusions
# ---------------------------------------------------------------------------

def operations_coincide(vcomp: BinOp, hcomp: BinOp, elems: List[int]) -> bool:
    return all(vcomp(a, b) == hcomp(a, b) for a in elems for b in elems)


def is_commutative(op: BinOp, elems: List[int]) -> bool:
    return all(op(a, b) == op(b, a) for a in elems for b in elems)


def is_associative(op: BinOp, elems: List[int]) -> bool:
    return all(
        op(op(a, b), c) == op(a, op(b, c))
        for a in elems
        for b in elems
        for c in elems
    )


def audit(vcomp: BinOp, hcomp: BinOp, elems: List[int], unit: int) -> dict:
    """Run the full Eckmann--Hilton audit on a structure and return a report."""
    return {
        "is_interchange_structure": is_interchange_structure(vcomp, hcomp, elems, unit),
        "operations_coincide": operations_coincide(vcomp, hcomp, elems),
        "vcomp_commutative": is_commutative(vcomp, elems),
        "vcomp_associative": is_associative(vcomp, elems),
    }


# ---------------------------------------------------------------------------
# Demo 1: a genuine commutative monoid (Z/m under addition) as both operations
# ---------------------------------------------------------------------------

def demo_cyclic(m: int) -> None:
    elems = list(range(m))
    add: BinOp = lambda a, b: (a + b) % m
    report = audit(add, add, elems, 0)
    print(f"[Demo 1] Z/{m} with vcomp = hcomp = addition, unit = 0")
    for k, v in report.items():
        print(f"    {k}: {v}")
    print()


# ---------------------------------------------------------------------------
# Demo 2: two *syntactically different* operation tables that share a unit and
# interchange -- the collapse (vcomp == hcomp) becomes visible.
# ---------------------------------------------------------------------------

def demo_collapse() -> None:
    # Carrier {0,1,2,3} identified with Z/2 x Z/2; unit = 0 = (0,0).
    # Represent (x,y) as 2*x + y.  Both series and parallel are group addition,
    # but written via two different-looking closures to emphasize the theorem.
    elems = list(range(4))

    def to_pair(n: int) -> Tuple[int, int]:
        return (n // 2, n % 2)

    def of_pair(p: Tuple[int, int]) -> int:
        return 2 * (p[0] % 2) + (p[1] % 2)

    def vcomp(a: int, b: int) -> int:
        (x1, y1), (x2, y2) = to_pair(a), to_pair(b)
        return of_pair((x1 + x2, y1 + y2))

    def hcomp(a: int, b: int) -> int:
        # A deliberately different-looking formula that is nonetheless equal.
        (x1, y1), (x2, y2) = to_pair(a), to_pair(b)
        return of_pair(((x2 + x1), (y2 + y1)))

    report = audit(vcomp, hcomp, elems, 0)
    print("[Demo 2] Two differently-written operations on Z/2 x Z/2")
    for k, v in report.items():
        print(f"    {k}: {v}")
    print()


# ---------------------------------------------------------------------------
# Demo 3: breaking a hypothesis breaks the conclusion.
# A non-commutative operation cannot be part of a valid interchange structure.
# ---------------------------------------------------------------------------

def demo_counterexample() -> None:
    # Left projection: a o b = a.  It has NO two-sided unit, and it is
    # non-commutative, so it is not an interchange structure.
    elems = [0, 1, 2]
    left: BinOp = lambda a, b: a
    print("[Demo 3] Left-projection operation a o b = a")
    print(f"    has two-sided unit (any candidate 0): "
          f"{is_two_sided_unit(left, elems, 0)}")
    print(f"    commutative: {is_commutative(left, elems)}")
    print("    => Not an interchange structure; theorem does not apply.\n")


# ---------------------------------------------------------------------------
# Demo 4: exhaustive search -- among all binary operations on a 2-element set
# that share unit 0 with themselves and self-interchange, all are commutative.
# ---------------------------------------------------------------------------

def demo_exhaustive_two_element() -> None:
    elems = [0, 1]
    count_valid = 0
    all_commutative = True
    # Encode an operation as a tuple of its 4 outputs (00,01,10,11).
    for table in product(elems, repeat=4):
        op: BinOp = lambda a, b, t=table: t[2 * a + b]
        if not is_two_sided_unit(op, elems, 0):
            continue
        if not satisfies_interchange(op, op, elems):
            continue
        count_valid += 1
        if not is_commutative(op, elems):
            all_commutative = False
    print("[Demo 4] All self-interchanging unital operations on a 2-element set")
    print(f"    number found: {count_valid}")
    print(f"    all commutative: {all_commutative}\n")


def main() -> None:
    print("=" * 68)
    print("Eckmann--Hilton argument: numerical demonstrations")
    print("=" * 68 + "\n")
    demo_cyclic(5)
    demo_collapse()
    demo_counterexample()
    demo_exhaustive_two_element()


if __name__ == "__main__":
    main()
