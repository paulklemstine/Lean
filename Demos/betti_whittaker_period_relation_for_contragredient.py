"""
Numerical demonstrations of the Betti--Whittaker contragredient period relation
for GL(n) over a number field.

The central identity is

    P^b(pi_dual) = eps(disc(k)) ** b * P^b(pi),

where
    b = r1 * floor(n^2 / 4) + r2 * C(n, 2)       (the bottom cohomological degree),
    eps(disc(k)) in {+1, -1}                       (a quadratic character value),
    disc(k) has sign (-1)^r2                       (Brill's theorem).

Because eps is quadratic, eps(disc)**b is +1 when eps(disc) = +1, and (-1)**b
otherwise -- so the entire twist is governed by the parity of b.

This file is self-contained: every function is inlined and type-hinted.
Run with `python demo.py`.
"""

from __future__ import annotations

from typing import Dict, List, Tuple


# --------------------------------------------------------------------------- #
# Core arithmetic: the bottom degree and its closed forms                     #
# --------------------------------------------------------------------------- #

def quarter_square(n: int) -> int:
    """floor(n^2 / 4), the real-place contribution per real place.

    Verifies the quarter-square identity floor(n^2/4) = floor(n/2)*floor((n+1)/2).
    """
    return (n // 2) * ((n + 1) // 2)


def binom2(n: int) -> int:
    """C(n, 2) = n*(n-1)/2, the complex-place contribution per complex place."""
    return n * (n - 1) // 2


def bottom_degree(n: int, r1: int, r2: int) -> int:
    """The bottom cohomological degree b = r1*floor(n^2/4) + r2*C(n,2)."""
    return r1 * quarter_square(n) + r2 * binom2(n)


def disc_sign(r2: int) -> int:
    """Sign of disc(k) = (-1)^r2 (Brill's theorem)."""
    return -1 if (r2 % 2 == 1) else 1


def twist_factor(eps_disc: int, b: int) -> int:
    """The discriminant twist eps(disc(k))**b in {+1, -1}.

    eps_disc must be +1 or -1 (a quadratic character value).
    """
    assert eps_disc in (1, -1), "eps(disc) must be a quadratic value +1 or -1"
    return 1 if eps_disc == 1 else (-1) ** b


# --------------------------------------------------------------------------- #
# The period relation as a verifiable identity                                #
# --------------------------------------------------------------------------- #

def period_dual(period_pi: complex, eps_disc: int, b: int) -> complex:
    """P^b(pi_dual) = eps(disc)**b * P^b(pi)."""
    return twist_factor(eps_disc, b) * period_pi


def check_double_contragredient(period_pi: complex, eps_disc: int, b: int) -> bool:
    """Consistency: applying the relation twice returns the original period,
    because eps(disc)**(2b) = (eps(disc)^2)**b = 1 (quadraticity)."""
    once = period_dual(period_pi, eps_disc, b)
    twice = period_dual(once, eps_disc, b)
    return abs(twice - period_pi) < 1e-12


# --------------------------------------------------------------------------- #
# Identity self-tests for the closed forms                                    #
# --------------------------------------------------------------------------- #

def verify_quarter_square_identity(max_n: int = 40) -> bool:
    """floor(n^2/4) == floor(n/2)*floor((n+1)/2) for all 0 <= n <= max_n."""
    return all((n * n) // 4 == quarter_square(n) for n in range(max_n + 1))


def verify_complex_term_even(max_n: int = 40) -> bool:
    """n*(n-1) is always even, so C(n,2) is a genuine integer."""
    return all((n * (n - 1)) % 2 == 0 for n in range(max_n + 1))


# --------------------------------------------------------------------------- #
# Tables and demonstrations                                                    #
# --------------------------------------------------------------------------- #

def bottom_degree_table(field: Tuple[str, int, int],
                        n_values: List[int]) -> List[Tuple[int, int, int]]:
    """Return (n, b, parity) for a given field (name, r1, r2)."""
    _, r1, r2 = field
    return [(n, bottom_degree(n, r1, r2), bottom_degree(n, r1, r2) % 2)
            for n in n_values]


def sign_flip_set_over_Q(max_n: int) -> List[int]:
    """Over Q (r1=1, r2=0) with eps(disc) = -1, the n for which periods flip
    sign are exactly those with odd b = floor(n^2/4), i.e. n == 2 (mod 4)."""
    return [n for n in range(1, max_n + 1) if quarter_square(n) % 2 == 1]


def main() -> None:
    print("=" * 70)
    print("Betti--Whittaker contragredient period relation -- numerical demo")
    print("=" * 70)

    print("\n[1] Closed-form self-tests")
    print(f"    quarter-square identity floor(n^2/4)=floor(n/2)floor((n+1)/2): "
          f"{verify_quarter_square_identity()}")
    print(f"    n(n-1) always even (C(n,2) integral): "
          f"{verify_complex_term_even()}")

    print("\n[2] Bottom degree b over Q  (r1=1, r2=0):  b = floor(n^2/4)")
    for n, b, par in bottom_degree_table(("Q", 1, 0), list(range(1, 11))):
        print(f"    GL({n:2d}):  b = {b:3d}   ({'even' if par == 0 else 'odd '})")

    print("\n[3] Bottom degree b over Q(i)  (r1=0, r2=1):  b = C(n,2)")
    for n, b, par in bottom_degree_table(("Q(i)", 0, 1), list(range(1, 11))):
        print(f"    GL({n:2d}):  b = {b:3d}   ({'even' if par == 0 else 'odd '})")

    print("\n[4] Discriminant sign (-1)^r2")
    for r2 in range(0, 4):
        print(f"    r2 = {r2}:  sign(disc) = {disc_sign(r2):+d}")

    print("\n[5] Period relation over Q with eps(disc) = -1  (real field, "
          "nontrivial signature character)")
    period_pi = 3.0 + 1.0j
    eps = -1
    print(f"    base period P^b(pi) = {period_pi}")
    for n in [2, 3, 4, 6]:
        b = bottom_degree(n, 1, 0)
        pd = period_dual(period_pi, eps, b)
        rel = "equal " if pd == period_pi else "FLIPPED"
        print(f"    GL({n}): b={b:2d}, twist={twist_factor(eps, b):+d}, "
              f"P^b(pi_dual) = {pd}   [{rel}]")

    print("\n[6] Double-contragredient consistency (must all be True)")
    for n in [2, 3, 4, 5, 6, 7]:
        b = bottom_degree(n, 1, 0)
        ok = check_double_contragredient(period_pi, eps, b)
        print(f"    GL({n}): (pi_dual)_dual == pi ?  {ok}")

    print("\n[7] Sign-flip set over Q for eps(disc) = -1 (predicted n == 2 mod 4)")
    flips = sign_flip_set_over_Q(20)
    print(f"    n with odd bottom degree: {flips}")
    print(f"    all == 2 (mod 4)?  {all(n % 4 == 2 for n in flips)}")

    print("\nDone.")


if __name__ == "__main__":
    main()
