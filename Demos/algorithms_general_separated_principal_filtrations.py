"""Exact Intersection Computation in the D+M Domain Z + X*Q[X].

In S = { p in Q[X] : p(0) in Z } the element 2 is a nonzero non-unit, yet

        ⋂_n (2^n) = X*Q[X] = { p in S : p(0) = 0 } ≠ 0.

This module decides membership in the intersection exactly (by a single test on
the constant coefficient), produces the divisibility witnesses p = 2^n q with
q in S, and verifies that X*Q[X] is a fixed point of the ideal map I -> (2)·I,
hence the greatest 2-divisible ideal.
"""

from __future__ import annotations

from fractions import Fraction
from typing import List, Optional, Sequence, Tuple

Poly = Tuple[Fraction, ...]  # coefficients, constant term first


def normalise(coeffs: Sequence[object]) -> Poly:
    cs = [Fraction(c) for c in coeffs]  # type: ignore[arg-type]
    while cs and cs[-1] == 0:
        cs.pop()
    return tuple(cs)


def constant_coefficient(p: Poly) -> Fraction:
    return p[0] if p else Fraction(0)


def in_S(p: Poly) -> bool:
    """Membership in S = Z + X*Q[X]: the constant coefficient must be an integer."""
    return constant_coefficient(p).denominator == 1


def scale(p: Poly, factor: Fraction) -> Poly:
    return normalise([c * factor for c in p])


def divisibility_witness(p: Poly, n: int) -> Optional[Poly]:
    """Return q in S with p = 2^n q, if it exists."""
    q = scale(p, Fraction(1, 2**n))
    return q if in_S(q) else None


def in_infinite_intersection(p: Poly) -> bool:
    """Decide membership in ⋂_n (2^n) exactly.

    Theory: p lies in the intersection iff its constant coefficient is an
    integer divisible by every power of 2, i.e. iff p(0) = 0. The test is O(1),
    even though the defining condition quantifies over all n.
    """
    if not in_S(p):
        raise ValueError("p is not an element of S")
    return constant_coefficient(p) == 0


def certificate(p: Poly, upto: int) -> List[Tuple[int, Optional[Poly]]]:
    """Witnesses p = 2^n q for n = 0..upto (None where no witness exists in S)."""
    return [(n, divisibility_witness(p, n)) for n in range(upto + 1)]


def is_two_divisible_ideal_sample(elements: Sequence[Poly]) -> bool:
    """Check I ⊆ (2)·I on a sample: each element is 2 times an element of I."""
    for p in elements:
        half = scale(p, Fraction(1, 2))
        if not (in_S(half) and constant_coefficient(half) == 0):
            return False
    return True


def show(p: Optional[Poly]) -> str:
    if p is None:
        return "no witness in S"
    if not p:
        return "0"
    terms = []
    for i, c in enumerate(p):
        if c == 0:
            continue
        terms.append(f"{c}" if i == 0 else (f"{c}*X" if i == 1 else f"{c}*X^{i}"))
    return " + ".join(terms)


if __name__ == "__main__":
    X: Poly = normalise([0, 1])
    p1: Poly = normalise([3, 1])            # 3 + X, constant term 3
    p2: Poly = normalise([0, Fraction(5, 7), 0, 2])  # (5/7)X + 2X^3

    for name, p in [("X", X), ("3 + X", p1), ("(5/7)X + 2X^3", p2)]:
        print(f"{name}:  in the intersection? {in_infinite_intersection(p)}")
        for n, q in certificate(p, 4):
            print(f"    n = {n}: witness q = {show(q)}")
        print()

    print("X*Q[X] is 2-divisible on the sample:",
          is_two_divisible_ideal_sample([X, p2, scale(X, Fraction(11, 3))]))


"""Separation Certification by Height Verification.

A height function for a is any v : R -> N with v(x) < v(ax) for all nonzero x.
Exhibiting one certifies that ⋂_n (a^n) = 0 over a domain — and, conversely,
separation always admits such a v (the adic order, which is the pointwise
minimal choice). This module verifies a candidate height on a finite sample,
derives the resulting explicit bound on how far divisibility can persist, and
compares the candidate against the canonical adic order.
"""

from __future__ import annotations

from typing import Callable, Iterable, List, Sequence, Tuple, TypeVar

T = TypeVar("T")


def verify_height(
    v: Callable[[T], int],
    multiply_by_a: Callable[[T], T],
    sample: Iterable[T],
    is_zero: Callable[[T], bool],
) -> Tuple[bool, List[T]]:
    """Check v(x) < v(a x) on a sample. Returns (all_passed, counterexamples)."""
    bad: List[T] = []
    for x in sample:
        if is_zero(x):
            continue
        if not v(x) < v(multiply_by_a(x)):
            bad.append(x)
    return (len(bad) == 0), bad


def separation_bound(v: Callable[[T], int], x: T) -> int:
    """Given a verified height v, the least n for which a^n | x must fail.

    The growth lemma n + v(y) <= v(a^n y) shows that if x = a^n y with y nonzero
    then n <= v(x). Hence divisibility by a^(v(x)+1) forces x = 0.
    """
    return v(x) + 1


def compare_with_adic_order(
    v: Callable[[T], int],
    adic_order: Callable[[T], int],
    sample: Sequence[T],
    is_zero: Callable[[T], bool],
) -> List[Tuple[T, int, int, bool]]:
    """Tabulate (x, ord_a x, v(x), ord_a x <= v(x)); the last column is always True."""
    rows: List[Tuple[T, int, int, bool]] = []
    for x in sample:
        if is_zero(x):
            continue
        o, vv = adic_order(x), v(x)
        rows.append((x, o, vv, o <= vv))
    return rows


if __name__ == "__main__":
    sample_ints = [1, 3, -12, 40, 96, 1024]

    ok, bad = verify_height(
        v=abs,
        multiply_by_a=lambda x: 2 * x,
        sample=sample_ints,
        is_zero=lambda x: x == 0,
    )
    print(f"|.| is a height function for a = 2 on the sample: {ok} (failures: {bad})")

    def ord2(x: int) -> int:
        k = 0
        while x % 2 == 0:
            x //= 2
            k += 1
        return k

    for x in sample_ints:
        print(
            f"  x = {x:>6}: divisibility by 2^n must fail by n = {separation_bound(abs, x)};"
            f" ord_2(x) = {ord2(x)}"
        )

    print("\nMinimality of the adic order against the inflated height 3*ord + (|x| mod 5):")
    for row in compare_with_adic_order(
        v=lambda x: 3 * ord2(x) + (abs(x) % 5),
        adic_order=ord2,
        sample=sample_ints,
        is_zero=lambda x: x == 0,
    ):
        print(f"  x = {row[0]:>6}, ord = {row[1]}, v = {row[2]}, ord <= v: {row[3]}")


"""Adic Order by Exhaustive Trial Division.

Computes ord_a(x), the largest n with a^n | x, for a nonzero x in a ring with
exact division. Termination is *equivalent* to separation of the principal
filtration at a: the loop halts on every nonzero input exactly when
⋂_n (a^n) = 0.
"""

from __future__ import annotations

from fractions import Fraction
from typing import Callable, Optional, Tuple, TypeVar

T = TypeVar("T")


def adic_order(
    x: T,
    divides: Callable[[T], bool],
    divide: Callable[[T], T],
    is_zero: Callable[[T], bool],
    step_budget: Optional[int] = None,
) -> Tuple[int, bool]:
    """Return (order, terminated).

    Parameters
    ----------
    x            : the ring element whose a-adic order is wanted (must be nonzero)
    divides      : predicate y |-> (a divides y)
    divide       : exact division y |-> y / a, valid when divides(y)
    is_zero      : zero test for the ring
    step_budget  : optional guard; if exceeded, returns (budget, False).
                   A finite budget is only needed in rings where separation
                   may fail.

    Returns
    -------
    (order, terminated) where `terminated` is False only if the budget was hit,
    which certifies (for that budget) infinite divisibility, i.e. failure of
    separation at the element x.
    """
    if is_zero(x):
        raise ValueError("the adic order is undefined at 0 (formally +infinity)")
    k = 0
    cur = x
    while divides(cur):
        cur = divide(cur)
        k += 1
        if step_budget is not None and k >= step_budget:
            return k, False
    return k, True


def integer_adic_order(a: int, x: int) -> int:
    """ord_a(x) for integers with |a| >= 2. Runs in O(log_|a| |x|) exact divisions."""
    if abs(a) < 2:
        raise ValueError("a must be a nonzero non-unit integer")
    order, _ = adic_order(
        x,
        divides=lambda y: y % a == 0,
        divide=lambda y: y // a,
        is_zero=lambda y: y == 0,
    )
    return order


def adic_absolute_value(order: Optional[int]) -> Fraction:
    """||x||_a = 2^(-ord_a x), with ||0||_a = 0 encoded by order = None."""
    return Fraction(0) if order is None else Fraction(1, 2**order)


if __name__ == "__main__":
    for value in (12, 96, 1024, 3, -48):
        k = integer_adic_order(2, value)
        print(f"ord_2({value}) = {k},  ||{value}||_2 = {adic_absolute_value(k)}")
