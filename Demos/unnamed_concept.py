"""Numerical demonstrations for the arithmetic of Pythagorean triples and quadruples.

This self-contained script illustrates the main results:

  * Leg Realizability: every integer n >= 3 is a leg, via an explicit
    parity-split construction; 1 and 2 are not legs.
  * The classical parametrization (m^2 - n^2, 2mn, m^2 + n^2) is always a triple.
  * Universal divisibility laws for triples: 3 | ab, 4 | ab, 12 | ab,
    area = ab/2 is a multiple of 6, 5 | abc, 60 | abc.
  * Quadruple parity: in a^2 + b^2 + c^2 = d^2 at least two of a, b, c are even,
    hence 4 | abc.

Run:  python demo.py
"""

from __future__ import annotations

from typing import Iterator


# --------------------------------------------------------------------------
# 1. Leg realizability
# --------------------------------------------------------------------------
def leg_witness(n: int) -> tuple[int, int]:
    """Return integers (b, c) with 0 < b < c and n^2 + b^2 = c^2, for n >= 3.

    Even n = 2k:      (b, c) = (k^2 - 1, k^2 + 1),  so c - b = 2.
    Odd  n = 2k + 1:  (b, c) = (2k^2 + 2k, 2k^2 + 2k + 1), so c - b = 1.
    """
    if n < 3:
        raise ValueError("Only integers n >= 3 are legs; 1 and 2 are not.")
    if n % 2 == 0:
        k = n // 2
        return (k * k - 1, k * k + 1)
    k = (n - 1) // 2
    b = 2 * k * k + 2 * k
    return (b, b + 1)


def is_leg_bruteforce(n: int, search: int = 200000) -> bool:
    """Brute-force check whether n is a leg, confirming 1 and 2 fail."""
    n2 = n * n
    for b in range(1, search):
        c2 = n2 + b * b
        c = int(c2 ** 0.5)
        for cc in (c - 1, c, c + 1):
            if cc > b and cc * cc == c2:
                return True
    return False


# --------------------------------------------------------------------------
# 2. Parametrization
# --------------------------------------------------------------------------
def parametrize(m: int, n: int) -> tuple[int, int, int]:
    """Classical Euclid parametrization P(m, n) = (m^2 - n^2, 2mn, m^2 + n^2)."""
    return (m * m - n * n, 2 * m * n, m * m + n * n)


# --------------------------------------------------------------------------
# 3. Divisibility laws
# --------------------------------------------------------------------------
def triple_divisibility_report(a: int, b: int, c: int) -> dict[str, bool]:
    """Verify the universal divisibility laws for one triple."""
    assert a * a + b * b == c * c, "not a Pythagorean triple"
    ab = a * b
    abc = a * b * c
    return {
        "3 | ab": ab % 3 == 0,
        "4 | ab": ab % 4 == 0,
        "12 | ab": ab % 12 == 0,
        "area = ab/2 divisible by 6": (ab // 2) % 6 == 0,
        "5 | abc": abc % 5 == 0,
        "60 | abc": abc % 60 == 0,
    }


def quadruple_report(a: int, b: int, c: int, d: int) -> dict[str, bool]:
    """Verify the parity/divisibility laws for one quadruple."""
    assert a * a + b * b + c * c == d * d, "not a Pythagorean quadruple"
    num_even = sum(1 for x in (a, b, c) if x % 2 == 0)
    return {
        "at least two of a,b,c even": num_even >= 2,
        "4 | abc": (a * b * c) % 4 == 0,
    }


def enumerate_triples(bound: int) -> Iterator[tuple[int, int, int]]:
    """Yield primitive-and-scaled triples from parametrization with m <= bound."""
    for m in range(2, bound + 1):
        for n in range(1, m):
            yield parametrize(m, n)


# --------------------------------------------------------------------------
# Main
# --------------------------------------------------------------------------
def main() -> None:
    print("=" * 68)
    print("1. LEG REALIZABILITY")
    print("=" * 68)
    for n in range(3, 14):
        b, c = leg_witness(n)
        ok = n * n + b * b == c * c
        print(f"  n={n:2d}: {n}^2 + {b}^2 = {c}^2   [{'OK' if ok else 'FAIL'}]")
    print(f"  Is 1 a leg? {is_leg_bruteforce(1)}   Is 2 a leg? {is_leg_bruteforce(2)}")
    print(f"  Is 3 a leg? {is_leg_bruteforce(3)}   Is 4 a leg? {is_leg_bruteforce(4)}")

    print("\n" + "=" * 68)
    print("2. PARAMETRIZATION IS ALWAYS A TRIPLE")
    print("=" * 68)
    for (m, n) in [(2, 1), (3, 2), (4, 1), (5, 2)]:
        a, b, c = parametrize(m, n)
        print(f"  P({m},{n}) = ({a}, {b}, {c}):  {a}^2+{b}^2=={c}^2 -> "
              f"{a*a + b*b == c*c}")

    print("\n" + "=" * 68)
    print("3. UNIVERSAL DIVISIBILITY LAWS FOR TRIPLES")
    print("=" * 68)
    all_ok = True
    for (a, b, c) in enumerate_triples(30):
        rep = triple_divisibility_report(a, b, c)
        all_ok = all_ok and all(rep.values())
    print(f"  Checked all triples P(m,n), 2<=m<=30: all laws hold = {all_ok}")
    for (a, b, c) in [(3, 4, 5), (5, 12, 13), (8, 15, 17), (7, 24, 25)]:
        area = a * b // 2
        print(f"  ({a},{b},{c}): area={area} (6|area: {area % 6 == 0}), "
              f"abc={a*b*c} (60|abc: {(a*b*c) % 60 == 0})")

    print("\n" + "=" * 68)
    print("4. QUADRUPLE PARITY")
    print("=" * 68)
    quads = [(1, 2, 2, 3), (2, 3, 6, 7), (1, 4, 8, 9), (4, 4, 7, 9)]
    for (a, b, c, d) in quads:
        rep = quadruple_report(a, b, c, d)
        print(f"  ({a},{b},{c},{d}): {rep}")


if __name__ == "__main__":
    main()
