"""
Numerical demonstration of the Pell obstruction to the proposed family of
optimal equidistant codes / symmetric block designs for n = 2 (mod 4).

Family parameters, indexed by a nonnegative integer u:

    v(u)     = 12*u**2 + 8*u + 2        (number of points)
    k(u)     = 6*u**2 + u               (block size)
    lam(u)   = 3*u**2 - u               (index; equals k(k-1)/(v-1))
    order(u) = k(u) - lam(u) = u*(3u+2) (design order)

Central facts demonstrated here:

  1. lam(u) = k(k-1)/(v-1) exactly (the quotient collapses to a polynomial).
  2. v(u) = 2 (mod 4) is always even, so Bruck-Ryser-Chowla applies and
     forces the order u*(3u+2) to be a perfect square.
  3. (3u+1)**2 = 3*order(u) + 1, so order is a perfect square iff
     (3u+1, m) solves the Pell equation x**2 - 3*y**2 = 1.
  4. The admissible u (order a perfect square) form the sparse Pell orbit
     0, 2, 32, 450, 6272, ...  --  NOT all of N.  In particular u = 1 fails.

Self-contained: standard library only.
"""

from __future__ import annotations

from math import isqrt
from typing import Iterator


# --------------------------------------------------------------------------
# Parameter functions
# --------------------------------------------------------------------------
def v(u: int) -> int:
    """Number of points of the proposed symmetric design."""
    return 12 * u ** 2 + 8 * u + 2


def k(u: int) -> int:
    """Block size of the proposed symmetric design."""
    return 6 * u ** 2 + u


def lam(u: int) -> int:
    """Index lambda, as the polynomial 3u^2 - u."""
    return 3 * u ** 2 - u


def order(u: int) -> int:
    """Design order k - lambda = u(3u+2)."""
    return u * (3 * u + 2)


def is_square(n: int) -> bool:
    """True iff n is a perfect square (n >= 0)."""
    if n < 0:
        return False
    r = isqrt(n)
    return r * r == n


# --------------------------------------------------------------------------
# 1. The lambda quotient collapses to a polynomial
# --------------------------------------------------------------------------
def check_lambda_collapse(u_max: int = 40) -> None:
    print("=" * 68)
    print("1. lambda = k(k-1)/(v-1) collapses to the polynomial 3u^2 - u")
    print("=" * 68)
    print(f"{'u':>4} {'v-1':>10} {'k(k-1)':>14} {'quotient':>10} {'3u^2-u':>10}")
    for u in range(0, min(u_max, 12) + 1):
        num = k(u) * (k(u) - 1)
        den = v(u) - 1
        assert num % den == 0, f"non-integral lambda at u={u}"
        quot = num // den
        assert quot == lam(u)
        print(f"{u:>4} {den:>10} {num:>14} {quot:>10} {lam(u):>10}")
    for u in range(u_max + 1):
        assert (k(u) * (k(u) - 1)) % (v(u) - 1) == 0
        assert (k(u) * (k(u) - 1)) // (v(u) - 1) == lam(u)
    print(f"Verified integrality + collapse for all u in [0, {u_max}].\n")


# --------------------------------------------------------------------------
# 2. v = 2 (mod 4) always; Bruck-Ryser-Chowla applies
# --------------------------------------------------------------------------
def check_parity(u_max: int = 40) -> None:
    print("=" * 68)
    print("2. v(u) = 2 (mod 4) always -> v even -> BRC forces order to be square")
    print("=" * 68)
    for u in range(u_max + 1):
        assert v(u) % 4 == 2
    print(f"Verified v(u) % 4 == 2 for all u in [0, {u_max}].\n")


# --------------------------------------------------------------------------
# 3. Pell identity (3u+1)^2 = 3*order + 1
# --------------------------------------------------------------------------
def check_pell_identity(u_max: int = 40) -> None:
    print("=" * 68)
    print("3. Pell identity: (3u+1)^2 = 3*order(u) + 1")
    print("=" * 68)
    for u in range(u_max + 1):
        assert (3 * u + 1) ** 2 == 3 * order(u) + 1
    print(f"Verified for all u in [0, {u_max}].")
    print("Hence order is a perfect square  <=>  (3u+1, m) solves x^2 - 3y^2 = 1.\n")


# --------------------------------------------------------------------------
# 4. Which u are admissible?  (order a perfect square)
# --------------------------------------------------------------------------
def admissible_by_search(u_max: int = 500) -> list[int]:
    """Brute-force list of admissible u in [0, u_max]."""
    return [u for u in range(u_max + 1) if is_square(order(u))]


def pell_orbit(u_max: int) -> list[int]:
    """
    Admissible u generated via the Pell/admissibility recurrence.

    Base solutions of x^2 - 3y^2 = 1 with x = 3u+1: (u, m) = (0, 0) and (2, 4).
    Admissibility step: u' = 7u + 4m + 2, m' = 12u + 7m + 4.
    """
    orbit: list[int] = [0]
    u, m = 2, 4
    while u <= u_max:
        orbit.append(u)
        u, m = 7 * u + 4 * m + 2, 12 * u + 7 * m + 4
    return orbit


def check_admissible(u_max: int = 500) -> None:
    print("=" * 68)
    print("4. Admissible u (order a perfect square) form a sparse Pell orbit")
    print("=" * 68)
    searched = admissible_by_search(u_max)
    orbit = [u for u in pell_orbit(u_max) if u <= u_max]
    print(f"Brute-force admissible u in [0, {u_max}]: {searched}")
    print(f"Pell-recurrence orbit          in [0, {u_max}]: {orbit}")
    assert searched == orbit, "Pell orbit disagrees with brute force!"
    print("The two agree exactly -> admissibility IS the Pell orbit, not all of N.\n")

    print("Detailed table of admissible members:")
    print(f"{'u':>6} {'v':>10} {'k':>8} {'lambda':>8} {'order':>10} {'sqrt(order)':>12} {'Pell (x,y)':>14}")
    for u in orbit:
        o = order(u)
        m = isqrt(o)
        x = 3 * u + 1
        assert x ** 2 - 3 * m ** 2 == 1
        print(f"{u:>6} {v(u):>10} {k(u):>8} {lam(u):>8} {o:>10} {m:>12} {f'({x},{m})':>14}")
    print()


# --------------------------------------------------------------------------
# 5. The u = 1 obstruction (the smallest non-trivial FAILURE)
# --------------------------------------------------------------------------
def check_u1_obstruction() -> None:
    print("=" * 68)
    print("5. The u = 1 obstruction: 2-(22,7,2) design cannot exist")
    print("=" * 68)
    u = 1
    print(f"u = 1: (v, k, lambda) = ({v(u)}, {k(u)}, {lam(u)})   order = {order(u)}")
    assert (v(u), k(u), lam(u)) == (22, 7, 2)
    assert order(u) == 5
    assert not is_square(5)
    print("order = 5 is NOT a perfect square, and v = 22 is even,")
    print("so Bruck-Ryser-Chowla rules out the symmetric 2-(22,7,2) design.")
    print("=> the bold 'exists for all u' hypothesis is false at its first step.\n")


# --------------------------------------------------------------------------
# 6. Recurrences for the admissible orbit
# --------------------------------------------------------------------------
def check_recurrences(terms: int = 6) -> None:
    print("=" * 68)
    print("6. Second-order recurrences inherited from the Pell structure")
    print("=" * 68)
    us = [u for u in pell_orbit(10 ** 12)][:terms]
    ms = [isqrt(order(u)) for u in us]
    print(f"u_n = {us}")
    print(f"m_n = {ms}   (order roots)")
    for n in range(2, len(us)):
        assert us[n] == 14 * us[n - 1] - us[n - 2] + 4
    for n in range(2, len(ms)):
        assert ms[n] == 14 * ms[n - 1] - ms[n - 2]
    print("Verified u_{n+1} = 14 u_n - u_{n-1} + 4  and  m_{n+1} = 14 m_n - m_{n-1}.\n")


def main() -> None:
    check_lambda_collapse()
    check_parity()
    check_pell_identity()
    check_admissible()
    check_u1_obstruction()
    check_recurrences()
    print("All demonstrations completed successfully.")


if __name__ == "__main__":
    main()
