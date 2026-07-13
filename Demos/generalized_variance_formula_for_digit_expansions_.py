"""
Generalized mean and variance of the repetend digits of 1/p in base b.

This self-contained script demonstrates the exact closed-form identities that
govern the digits appearing in the repeating expansion of a unit fraction 1/p
written in an integer base b.

For a base b >= 2 and a modulus p >= 2 with gcd(p, b) = 1, long division of
1 by p produces a purely periodic sequence of digits.  Writing one full period
of length l, and letting

    S = sum of the digits,
    T = sum of the squares of the digits,

the *orbit sums* of the remainders control everything:

    R = sum of the remainders,
    Q = sum of the squares of the remainders,
    C = sum of remainder(k) * remainder(k+1)   (cyclically over the period).

The theorems demonstrated here are:

    (1) Digit-sum identity          p * S = (b - 1) * R
    (2) Sum-of-squares identity     p^2 * T + 2 b * C = (b^2 + 1) * Q
    (3) Variance identity           p^2 * (l*T - S^2)
                                       = l * ((b^2 + 1) * Q - 2 b * C)
                                         - (b - 1)^2 * R^2
    (4) Midy complementarity        paired digits sum to b - 1 under reflection
    (5) Full-reptend mean           2 S = (b - 1)(p - 1) when 2R = p(p-1)
    (6) The mean is NOT always (b-1)/2  (witness: 1/7 in base 2).

Everything is exact rational / integer arithmetic; no floating point is used
for the identities themselves.
"""

from __future__ import annotations

from fractions import Fraction
from math import gcd
from typing import List, Tuple


def digit_orbit(p: int, b: int) -> Tuple[List[int], List[int]]:
    """Return (remainders, digits) for one full period of 1/p in base b.

    The remainder recurrence is r_0 = 1, r_{n+1} = (b * r_n) mod p, and the
    n-th digit is d_n = (b * r_n) // p.  The period ends when the remainder
    returns to 1.  Requires gcd(p, b) = 1 so that the orbit is purely periodic.
    """
    if gcd(p, b) != 1:
        raise ValueError("require gcd(p, b) = 1 for a purely periodic expansion")
    remainders: List[int] = []
    digits: List[int] = []
    r: int = 1
    while True:
        remainders.append(r)
        digits.append((b * r) // p)
        r = (b * r) % p
        if r == 1:
            break
    return remainders, digits


def orbit_sums(remainders: List[int]) -> Tuple[int, int, int]:
    """Return the orbit sums (R, Q, C) for one cyclic period of remainders."""
    l: int = len(remainders)
    R: int = sum(remainders)
    Q: int = sum(r * r for r in remainders)
    C: int = sum(remainders[k] * remainders[(k + 1) % l] for k in range(l))
    return R, Q, C


def digit_statistics(p: int, b: int) -> dict:
    """Compute S, T, the variance, and verify all closed-form identities."""
    remainders, digits = digit_orbit(p, b)
    l: int = len(digits)
    S: int = sum(digits)
    T: int = sum(d * d for d in digits)
    R, Q, C = orbit_sums(remainders)

    mean: Fraction = Fraction(S, l)
    variance: Fraction = Fraction(l * T - S * S, l * l)

    identity_1: bool = (p * S == (b - 1) * R)
    identity_2: bool = (p * p * T + 2 * b * C == (b * b + 1) * Q)
    identity_3: bool = (
        p * p * (l * T - S * S)
        == l * ((b * b + 1) * Q - 2 * b * C) - (b - 1) ** 2 * R * R
    )

    return {
        "p": p,
        "b": b,
        "period_length": l,
        "digits": digits,
        "remainders": remainders,
        "S": S,
        "T": T,
        "R": R,
        "Q": Q,
        "C": C,
        "mean": mean,
        "variance": variance,
        "identity_pS_eq_bR": identity_1,
        "identity_sum_squares": identity_2,
        "identity_variance": identity_3,
    }


def check_midy(p: int, b: int) -> bool:
    """Verify Midy-type complementarity for even period length.

    When the period length l is even and the remainder orbit reflects
    (r_{k + l/2} + r_k = p), the paired digits satisfy d_k + d_{k+l/2} = b - 1.
    """
    remainders, digits = digit_orbit(p, b)
    l: int = len(digits)
    if l % 2 != 0:
        return True  # vacuously: statement is about even periods
    h: int = l // 2
    reflects: bool = all(remainders[k] + remainders[k + h] == p for k in range(h))
    if not reflects:
        return True  # orbit does not reflect; Midy hypothesis not met
    return all(digits[k] + digits[k + h] == b - 1 for k in range(h))


def demo() -> None:
    print("=" * 72)
    print("Generalized variance of the digits of 1/p in base b")
    print("=" * 72)

    examples: List[Tuple[int, int]] = [
        (7, 10),   # classic 0.(142857), full reptend, mean 4.5
        (7, 2),    # 0.(001) length 3, mean 1/3 -- NOT (b-1)/2 = 1/2
        (13, 10),  # 0.(076923) length 6, half reptend
        (11, 10),  # 0.(09) length 2
        (17, 10),  # length 16, full reptend
        (3, 2),    # 0.(01)
    ]

    for p, b in examples:
        st = digit_statistics(p, b)
        print(f"\n1/{p} in base {b}:")
        print(f"  repetend digits : {st['digits']}")
        print(f"  period length l : {st['period_length']}")
        print(f"  S = {st['S']},  T = {st['T']}")
        print(f"  R = {st['R']},  Q = {st['Q']},  C = {st['C']}")
        print(f"  mean     = {st['mean']}  (= {float(st['mean']):.6f})")
        print(f"  variance = {st['variance']}  (= {float(st['variance']):.6f})")
        print(f"  [identity] p*S = (b-1)*R           : {st['identity_pS_eq_bR']}")
        print(f"  [identity] p^2*T + 2b*C=(b^2+1)*Q  : {st['identity_sum_squares']}")
        print(f"  [identity] variance closed form    : {st['identity_variance']}")
        print(f"  [Midy]     complementary pairs     : {check_midy(p, b)}")

    print("\n" + "=" * 72)
    print("The mean is NOT always (b-1)/2:")
    st = digit_statistics(7, 2)
    print(f"  1/7 in base 2 has digits {st['digits']}, mean {st['mean']} != 1/2")
    print("  This happens exactly because 2 is not a primitive root mod 7")
    print("  (its order is 3, strictly less than 6).")
    print("=" * 72)


if __name__ == "__main__":
    demo()
