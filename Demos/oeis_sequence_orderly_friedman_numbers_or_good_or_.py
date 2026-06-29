"""Orderly Friedman numbers: numerical demonstrations.

This module is a self-contained reference implementation of the formal theory of
orderly Friedman numbers (OEIS A080035). It mirrors the Lean development:

    * `FExpr`          -- digit-expression trees (lit / neg / bin)
    * `evaluate`       -- integer value of an expression
    * `digit_seq`      -- left-to-right list of digit leaves
    * `num_lits`       -- number of digit leaves
    * `is_orderly_friedman` / `is_friedman` -- the two membership predicates
    * `reachable2`     -- two-digit reachability calculus

It then:
    1. verifies the five canonical witnesses (127, 343, 736, 1285, 2592),
    2. exercises the MAIN theorem (decision by bounded enumeration) by
       recovering the first orderly Friedman numbers from scratch, and
    3. demonstrates the reachability calculus proving there are no two-digit
       orderly Friedman numbers.

All arithmetic is exact integer arithmetic. Run with `python3 demo.py`.
"""

from __future__ import annotations

from dataclasses import dataclass
from itertools import product
from typing import Iterator, List, Optional, Set, Tuple, Union

# ---------------------------------------------------------------------------
# Expression language (mirrors FOp / FExpr / eval / digitSeq / numLits)
# ---------------------------------------------------------------------------

FOp = str  # one of "add", "mul", "pow"
OPS: Tuple[FOp, ...] = ("add", "mul", "pow")

# Cap to keep exponentiation finite during enumeration.
POW_CAP: int = 10 ** 7


def op_apply(op: FOp, a: int, b: int) -> Optional[int]:
    """Apply a binary op; exponent truncated to a natural number (max(b, 0))."""
    if op == "add":
        return a + b
    if op == "mul":
        return a * b
    if op == "pow":
        e = max(b, 0)
        # Guard against runaway values (0**0 == 1 here, matching Nat semantics).
        if abs(a) > 1 and e > 64:
            return None
        val = a ** e
        if abs(val) > POW_CAP:
            return None
        return val
    raise ValueError(f"unknown op {op}")


@dataclass(frozen=True)
class Lit:
    d: int


@dataclass(frozen=True)
class Neg:
    e: "FExpr"


@dataclass(frozen=True)
class Bin:
    op: FOp
    l: "FExpr"
    r: "FExpr"


FExpr = Union[Lit, Neg, Bin]


def evaluate(e: FExpr) -> Optional[int]:
    """Integer value of an expression, or None if a power overflowed the cap."""
    if isinstance(e, Lit):
        return e.d
    if isinstance(e, Neg):
        v = evaluate(e.e)
        return None if v is None else -v
    if isinstance(e, Bin):
        a, b = evaluate(e.l), evaluate(e.r)
        if a is None or b is None:
            return None
        return op_apply(e.op, a, b)
    raise TypeError(e)


def digit_seq(e: FExpr) -> List[int]:
    """Left-to-right list of digit leaves."""
    if isinstance(e, Lit):
        return [e.d]
    if isinstance(e, Neg):
        return digit_seq(e.e)
    if isinstance(e, Bin):
        return digit_seq(e.l) + digit_seq(e.r)
    raise TypeError(e)


def num_lits(e: FExpr) -> int:
    """Number of digit leaves."""
    if isinstance(e, Lit):
        return 1
    if isinstance(e, Neg):
        return num_lits(e.e)
    if isinstance(e, Bin):
        return num_lits(e.l) + num_lits(e.r)
    raise TypeError(e)


def reading_order_digits(n: int) -> List[int]:
    """Digits of n most-significant first (reverse of little-endian digits)."""
    return [int(c) for c in str(n)]


def render(e: FExpr) -> str:
    """Human-readable infix rendering of an expression."""
    if isinstance(e, Lit):
        return str(e.d)
    if isinstance(e, Neg):
        return f"-{render(e.e)}"
    if isinstance(e, Bin):
        sym = {"add": "+", "mul": "*", "pow": "^"}[e.op]
        return f"({render(e.l)} {sym} {render(e.r)})"
    raise TypeError(e)


# ---------------------------------------------------------------------------
# Bounded enumeration: the MAIN decision procedure
# ---------------------------------------------------------------------------

def all_expressions(digits: List[int], allow_top_neg: bool = True) -> Iterator[FExpr]:
    """Yield every expression tree whose digit sequence equals `digits`.

    Mirrors the search space of the orderly predicate: all binary
    parenthesizations and operator assignments over the fixed leaf list, with
    an optional negation on every node.
    """
    n = len(digits)
    if n == 1:
        yield Lit(digits[0])
        yield Neg(Lit(digits[0]))
        return
    for split in range(1, n):
        for left in all_expressions(digits[:split]):
            for right in all_expressions(digits[split:]):
                for op in OPS:
                    node: FExpr = Bin(op, left, right)
                    yield node
                    if allow_top_neg:
                        yield Neg(node)


def is_orderly_friedman(n: int) -> Optional[FExpr]:
    """Return a witnessing expression if n is orderly Friedman, else None."""
    digits = reading_order_digits(n)
    if len(digits) < 2:
        return None
    for e in all_expressions(digits):
        if num_lits(e) >= 2 and digit_seq(e) == digits and evaluate(e) == n:
            return e
    return None


def is_friedman(n: int) -> Optional[FExpr]:
    """Return a witnessing expression if n is Friedman (any digit order)."""
    from itertools import permutations
    base = reading_order_digits(n)
    if len(base) < 2:
        return None
    seen: Set[Tuple[int, ...]] = set()
    for perm in permutations(base):
        if perm in seen:
            continue
        seen.add(perm)
        for e in all_expressions(list(perm)):
            if num_lits(e) >= 2 and evaluate(e) == n:
                return e
    return None


# ---------------------------------------------------------------------------
# Two-digit reachability calculus (reachable2 / reachable2_of / reachable2_neg)
# ---------------------------------------------------------------------------

def reachable2(a: int, b: int) -> Set[int]:
    """All values obtainable from ordered digits (a, b) with one operation."""
    values: Set[int] = set()
    for s0, s1, s2 in product((1, -1), repeat=3):
        x, y = s1 * a, s2 * b
        for op in OPS:
            v = op_apply(op, x, y)
            if v is not None:
                values.add(s0 * v)
    return values


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

CANONICAL: List[Tuple[int, FExpr, str]] = [
    (127, Bin("add", Neg(Lit(1)), Bin("pow", Lit(2), Lit(7))), "-1 + 2^7"),
    (343, Bin("pow", Bin("add", Lit(3), Lit(4)), Lit(3)), "(3 + 4)^3"),
    (736, Bin("add", Lit(7), Bin("pow", Lit(3), Lit(6))), "7 + 3^6"),
    (1285, Bin("mul", Bin("add", Lit(1), Bin("pow", Lit(2), Lit(8))), Lit(5)),
     "(1 + 2^8) * 5"),
    (2592, Bin("mul", Bin("pow", Lit(2), Lit(5)), Bin("pow", Lit(9), Lit(2))),
     "2^5 * 9^2"),
]


def demo_witnesses() -> None:
    print("== Five canonical orderly witnesses ==")
    for n, e, label in CANONICAL:
        ds = digit_seq(e)
        ro = reading_order_digits(n)
        ok = num_lits(e) >= 2 and ds == ro and evaluate(e) == n
        print(f"  {n} = {label:14s}  digits={ds}  reading-order={ro}  "
              f"value={evaluate(e)}  orderly={ok}")
    assert all(
        num_lits(e) >= 2 and digit_seq(e) == reading_order_digits(n)
        and evaluate(e) == n
        for n, e, _ in CANONICAL
    )
    print("  all five verified.\n")


def demo_enumeration(bound: int = 760) -> None:
    print(f"== Rediscovering orderly Friedman numbers up to {bound} ==")
    found: List[int] = []
    for n in range(10, bound + 1):
        w = is_orderly_friedman(n)
        if w is not None:
            found.append(n)
    print(f"  found up to {bound}: {found}")
    for expected in (127, 343, 736):
        assert expected in found, f"missing {expected}"
    # The two larger canonical witnesses are recovered directly (a full scan of
    # the 4-digit range is feasible but slow in pure Python, so we target them).
    for n in (1285, 2592):
        w = is_orderly_friedman(n)
        assert w is not None, f"missing {n}"
        print(f"  recovered {n} = {render(w)} from scratch")
    print("  (all five canonical witnesses recovered from scratch)\n")


def demo_orderly_implies_friedman() -> None:
    print("== orderly => Friedman (the proven implication) ==")
    for n, _, _ in CANONICAL:
        assert is_orderly_friedman(n) is not None
        assert is_friedman(n) is not None
        print(f"  {n}: orderly=True  Friedman=True")
    print()


def demo_no_two_digit() -> None:
    print("== No two-digit orderly Friedman numbers (reachability calculus) ==")
    hits: List[int] = []
    for n in range(10, 100):
        a, b = reading_order_digits(n)
        if n in reachable2(a, b):
            hits.append(n)
    print(f"  two-digit n with n in reachable2(a,b): {hits}")
    assert hits == [], "found an unexpected two-digit term"
    print("  confirmed: none exist; the sequence starts at 127.\n")


def main() -> None:
    demo_witnesses()
    demo_enumeration()
    demo_orderly_implies_friedman()
    demo_no_two_digit()
    print("All demonstrations passed.")


if __name__ == "__main__":
    main()
