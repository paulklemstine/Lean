"""Numerical demonstrations for the smooth-number counting function L(x, y).

This self-contained script reproduces, in pure Python, every quantity defined in
the accompanying formal development:

  * IsSmooth(y, n)            -- n is y-smooth (all prime factors <= y)
  * L(x, y)                   -- count of y-smooth integers in (0, x]
  * large_primes(x, y)        -- primes in (y, x]
  * prime_contribution(x, y)  -- sum_{y < p <= x} floor(x / p)  (union bound)
  * hypothesis_U(x, y, c)     -- prime_contribution(x, y) + c <= x

and it verifies the main theorems:

  * L_lower_sieve            : x - prime_contribution(x, y) <= L(x, y)
  * L_lower_under_U          : Hypothesis U  =>  c <= L(x, y)
  * L_eq_sieve (exactness)   : no double large factor  =>  equality
  * L_eq_iff_no_prime_between: L(x, y) = x  iff  no prime in (y, x]
  * L_two_mul_lt (Bertrand)  : L(2y, y) < 2y
  * Bonferroni bracket       : sieve lower bound <= L <= sieve + S_2

Run:  python demo.py
"""

from __future__ import annotations

from typing import List


# --------------------------------------------------------------------------- #
#  Primitive number theory                                                     #
# --------------------------------------------------------------------------- #

def is_prime(n: int) -> bool:
    """Return True iff n is a prime number."""
    if n < 2:
        return False
    if n % 2 == 0:
        return n == 2
    d = 3
    while d * d <= n:
        if n % d == 0:
            return False
        d += 2
    return True


def prime_factors(n: int) -> List[int]:
    """Return the sorted list of distinct prime factors of n (empty for n <= 1)."""
    factors: List[int] = []
    m = n
    d = 2
    while d * d <= m:
        if m % d == 0:
            factors.append(d)
            while m % d == 0:
                m //= d
        d += 1 if d == 2 else 2
    if m > 1:
        factors.append(m)
    return factors


def is_smooth(y: int, n: int) -> bool:
    """IsSmooth(y, n): every prime factor of n is at most y.

    n = 1 has no prime factors and is vacuously y-smooth for every y.
    """
    return all(p <= y for p in prime_factors(n))


# --------------------------------------------------------------------------- #
#  Core definitions mirroring the formal development                          #
# --------------------------------------------------------------------------- #

def L(x: int, y: int) -> int:
    """L(x, y): the number of y-smooth integers in the interval (0, x]."""
    return sum(1 for n in range(1, x + 1) if is_smooth(y, n))


def large_primes(x: int, y: int) -> List[int]:
    """The primes in the half-open interval (y, x]."""
    return [p for p in range(y + 1, x + 1) if is_prime(p)]


def prime_contribution(x: int, y: int) -> int:
    """primeContribution(x, y) = sum_{y < p <= x, p prime} floor(x / p)."""
    return sum(x // p for p in large_primes(x, y))


def hypothesis_U(x: int, y: int, c: int) -> bool:
    """HypothesisU(x, y, c): prime_contribution(x, y) + c <= x."""
    return prime_contribution(x, y) + c <= x


def second_order_correction(x: int, y: int) -> int:
    """S_2(x, y) = sum_{y < p < q <= x} floor(x / (p * q)) (Bonferroni term)."""
    ps = large_primes(x, y)
    total = 0
    for i, p in enumerate(ps):
        for q in ps[i + 1:]:
            total += x // (p * q)
    return total


def no_double_large_factor(x: int, y: int) -> bool:
    """True iff p * q > x for all distinct large primes p, q in (y, x]."""
    ps = large_primes(x, y)
    return all(ps[i] * ps[j] > x
               for i in range(len(ps)) for j in range(i + 1, len(ps)))


def no_prime_between(x: int, y: int) -> bool:
    """True iff there is no prime in (y, x]."""
    return len(large_primes(x, y)) == 0


# --------------------------------------------------------------------------- #
#  Demonstrations                                                              #
# --------------------------------------------------------------------------- #

def demo_sieve_lower_bound() -> None:
    print("=" * 70)
    print("Theorem (L_lower_sieve):  x - primeContribution(x, y) <= L(x, y)")
    print("=" * 70)
    print(f"{'x':>5} {'y':>4} | {'L(x,y)':>7} {'x - contrib':>12} "
          f"{'exact?':>7}")
    print("-" * 50)
    for x, y in [(20, 5), (30, 4), (100, 10), (100, 5), (200, 7), (500, 20)]:
        lv = L(x, y)
        lb = x - prime_contribution(x, y)
        assert lb <= lv, "sieve lower bound violated!"
        print(f"{x:>5} {y:>4} | {lv:>7} {lb:>12} "
              f"{'YES' if lb == lv else 'no':>7}")
    print()


def demo_exactness_regime() -> None:
    print("=" * 70)
    print("Theorem (L_eq_sieve_of_no_double_large_factor):")
    print("  no integer <= x has two distinct prime factors > y")
    print("    =>  L(x, y) = x - primeContribution(x, y)")
    print("=" * 70)
    print(f"{'x':>5} {'y':>4} | {'L':>5} {'x-contrib':>10} "
          f"{'no double?':>11} {'consistent?':>12}")
    print("-" * 60)
    for x, y in [(20, 5), (30, 4), (100, 10), (100, 5), (300, 17), (300, 10)]:
        lv = L(x, y)
        lb = x - prime_contribution(x, y)
        nd = no_double_large_factor(x, y)
        # When no double large factor: equality must hold.
        consistent = (lv == lb) if nd else True
        assert not nd or lv == lb, "exactness theorem violated!"
        print(f"{x:>5} {y:>4} | {lv:>5} {lb:>10} "
              f"{str(nd):>11} {str(consistent):>12}")
    print()


def demo_hypothesis_U() -> None:
    print("=" * 70)
    print("Theorem (L_lower_under_U):  HypothesisU(x, y, c)  =>  c <= L(x, y)")
    print("=" * 70)
    print(f"{'x':>5} {'y':>4} {'c':>5} | {'HypU?':>6} {'L(x,y)':>7} "
          f"{'c <= L?':>8}")
    print("-" * 50)
    for x, y, c in [(100, 10, 40), (100, 10, 46), (200, 7, 30),
                    (500, 20, 200), (1000, 30, 400)]:
        hu = hypothesis_U(x, y, c)
        lv = L(x, y)
        if hu:
            assert c <= lv, "Hypothesis U conclusion violated!"
        print(f"{x:>5} {y:>4} {c:>5} | {str(hu):>6} {lv:>7} "
              f"{str(c <= lv):>8}")
    print()


def demo_saturation_and_bertrand() -> None:
    print("=" * 70)
    print("Theorem (L_eq_iff_no_prime_between):  L(x, y) = x  iff  "
          "no prime in (y, x]")
    print("Corollary (L_two_mul_lt, Bertrand):   L(2y, y) < 2y")
    print("=" * 70)
    print(f"{'x':>5} {'y':>4} | {'L=x?':>6} {'no prime in (y,x]?':>20}")
    print("-" * 45)
    for x, y in [(6, 5), (7, 5), (12, 7), (10, 9), (16, 13)]:
        sat = (L(x, y) == x)
        npb = no_prime_between(x, y)
        assert sat == npb, "saturation criterion violated!"
        print(f"{x:>5} {y:>4} | {str(sat):>6} {str(npb):>20}")
    print()
    print("Bertrand deficiency L(2y, y) < 2y:")
    for y in range(1, 12):
        lv = L(2 * y, y)
        assert lv < 2 * y, "Bertrand deficiency violated!"
        print(f"  y = {y:>2}:  L(2y, y) = L({2*y}, {y}) = {lv}  <  {2*y}")
    print()


def demo_bonferroni_bracket() -> None:
    print("=" * 70)
    print("Bonferroni bracket:")
    print("  x - contrib  <=  L(x, y)  <=  x - contrib + S_2(x, y)")
    print("=" * 70)
    print(f"{'x':>5} {'y':>4} | {'lower':>6} {'L':>5} {'upper':>6} "
          f"{'bracketed?':>11}")
    print("-" * 50)
    for x, y in [(100, 5), (200, 7), (500, 11), (1000, 13), (300, 5)]:
        lower = x - prime_contribution(x, y)
        upper = lower + second_order_correction(x, y)
        lv = L(x, y)
        ok = lower <= lv <= upper
        assert ok, "Bonferroni bracket violated!"
        print(f"{x:>5} {y:>4} | {lower:>6} {lv:>5} {upper:>6} {str(ok):>11}")
    print()


def main() -> None:
    print()
    print("#" * 70)
    print("#  Smooth-number counting function L(x, y): numerical verification")
    print("#" * 70)
    print()
    demo_sieve_lower_bound()
    demo_exactness_regime()
    demo_hypothesis_U()
    demo_saturation_and_bertrand()
    demo_bonferroni_bracket()
    print("All theorem checks passed.")


if __name__ == "__main__":
    main()
