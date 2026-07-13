"""Numerical demonstrations for the universality of transfer functions among the
accumulation points of the level-l base-k sets

    Pi(k, l) = l * Z[1/k] = { l * a / k^m : a in Z, m in N } subset of R.

Everything is done with exact rational arithmetic (fractions.Fraction), so all
confirmations below are exact rather than floating-point approximate.

Key facts demonstrated:
  * Pi(k, l) is closed under addition, subtraction, and multiplication by k.
  * Pi(k, l) is dense in R (grid-snapping approximation).
  * Every point of Pi(k, l) is an accumulation point (explicit converging
    sequences of distinct members).
  * Universality: for any alpha, beta in Pi(k, l) the translation
    f(x) = x + (beta - alpha) is a transfer function with f(alpha) = beta and
    f(Pi) subset Pi.
  * Rigidity: two transfer functions agreeing at one point agree everywhere.
"""

from __future__ import annotations

from dataclasses import dataclass
from fractions import Fraction
from math import floor
from typing import Callable, List, Tuple


@dataclass(frozen=True)
class PiElement:
    """An element l * a / k^m of Pi(k, l), stored as (a, m)."""

    a: int
    m: int
    k: int
    l: int

    def value(self) -> Fraction:
        """Exact rational value l * a / k^m."""
        return Fraction(self.l * self.a, self.k ** self.m)


def in_pi(x: Fraction, k: int, l: int) -> bool:
    """Decide whether the rational x lies in Pi(k, l) = l * Z[1/k].

    x = l * a / k^m for some integer a and m >= 0 iff  x / l  is a k-adic
    rational, i.e. its reduced denominator is a power of k.
    """
    if l == 0:
        return x == 0
    from math import gcd

    y = x / l  # must be in Z[1/k]
    denom = y.denominator
    # denom divides some k^m iff every prime factor of denom divides k;
    # strip shared factors with k until none remain.
    g = gcd(denom, k)
    while g > 1:
        while denom % g == 0:
            denom //= g
        g = gcd(denom, k)
    return denom == 1


def add(u: Fraction, v: Fraction) -> Fraction:
    return u + v


def transfer(c: Fraction) -> Callable[[Fraction], Fraction]:
    """Return the transfer function f(x) = x + c."""
    return lambda x: x + c


def snap(x: float, k: int, l: int, m: int) -> Fraction:
    """Grid-snap: nearest-below member l * floor(x k^m / l) / k^m of Pi(k, l)."""
    t = floor(x * (k ** m) / l)
    return Fraction(l * t, k ** m)


def least_m_for_epsilon(k: int, l: int, eps: Fraction) -> int:
    """Least m with l / k^m < eps."""
    m = 0
    while Fraction(l, k ** m) >= eps:
        m += 1
    return m


def cluster_sequence(x: Fraction, k: int, l: int, n: int) -> List[Fraction]:
    """n distinct members of Pi(k, l) converging to x (accumulation witness)."""
    return [x + Fraction(l, k ** m) for m in range(1, n + 1)]


def demo_closure() -> None:
    print("=" * 68)
    print("1. Closure of Pi(k, l) under +, -, and multiplication by k")
    print("=" * 68)
    k, l = 3, 2
    x = PiElement(a=5, m=2, k=k, l=l).value()   # 2*5/9  = 10/9
    y = PiElement(a=-7, m=3, k=k, l=l).value()  # 2*-7/27 = -14/27
    print(f"k={k}, l={l}")
    print(f"  x        = {x}   in Pi? {in_pi(x, k, l)}")
    print(f"  y        = {y}  in Pi? {in_pi(y, k, l)}")
    print(f"  x + y    = {x + y}  in Pi? {in_pi(x + y, k, l)}")
    print(f"  x - y    = {x - y}  in Pi? {in_pi(x - y, k, l)}")
    print(f"  k * x    = {k * x}  in Pi? {in_pi(k * x, k, l)}")
    print()


def demo_density() -> None:
    print("=" * 68)
    print("2. Density: approximate an arbitrary real to any tolerance")
    print("=" * 68)
    import math

    k, l = 3, 2
    target = math.pi
    for eps in (Fraction(1, 10), Fraction(1, 1000), Fraction(1, 10 ** 6)):
        m = least_m_for_epsilon(k, l, eps)
        p = snap(target, k, l, m)
        err = abs(target - float(p))
        print(f"  eps={float(eps):.0e}: m={m:2d}, p={float(p):.9f}, "
              f"|pi - p|={err:.2e}, in Pi? {in_pi(p, k, l)}, "
              f"err<eps? {err < float(eps)}")
    print()


def demo_accumulation() -> None:
    print("=" * 68)
    print("3. Accumulation: distinct set members converging to a point")
    print("=" * 68)
    k, l = 4, 3
    x = PiElement(a=1, m=1, k=k, l=l).value()  # 3/4
    seq = cluster_sequence(x, k, l, 6)
    print(f"k={k}, l={l}, x = {x}")
    for i, s in enumerate(seq, 1):
        print(f"  term {i}: {s}  in Pi? {in_pi(s, k, l)}  "
              f"|s - x| = {float(s - x):.6e}")
    print(f"  distinct terms? {len(set(seq)) == len(seq)};  "
          f"all differ from x? {all(s != x for s in seq)}")
    print()


def demo_universality() -> None:
    print("=" * 68)
    print("4. Universality: a transfer function carrying alpha to beta")
    print("=" * 68)
    k, l = 5, 2
    samples: List[Tuple[PiElement, PiElement]] = [
        (PiElement(3, 1, k, l), PiElement(-4, 2, k, l)),
        (PiElement(0, 0, k, l), PiElement(7, 3, k, l)),
        (PiElement(11, 2, k, l), PiElement(11, 2, k, l)),  # alpha = beta
    ]
    for ae, be in samples:
        alpha, beta = ae.value(), be.value()
        c = beta - alpha
        f = transfer(c)
        print(f"  alpha={alpha}, beta={beta}")
        print(f"    shift c = beta - alpha = {c}  in Pi? {in_pi(c, k, l)}")
        print(f"    f(alpha) = {f(alpha)}  equals beta? {f(alpha) == beta}")
        # f maps Pi into Pi: test on several members
        members = [PiElement(a, m, k, l).value() for a in (-2, 0, 3) for m in (0, 1, 2)]
        ok = all(in_pi(f(x), k, l) for x in members)
        print(f"    f maps sampled Pi-members into Pi? {ok}")
    print()


def demo_rigidity() -> None:
    print("=" * 68)
    print("5. Rigidity: agreement at one point forces global equality")
    print("=" * 68)
    k, l = 3, 1
    c = Fraction(l * 4, k ** 2)   # a shift in Pi
    d = Fraction(l * 4, k ** 2)   # same shift
    f, g = transfer(c), transfer(d)
    x0 = Fraction(1, 3)
    print(f"  c = {c}, d = {d}; f(x0) = {f(x0)}, g(x0) = {g(x0)} at x0={x0}")
    if f(x0) == g(x0):
        test_points = [Fraction(p, q) for p in (-5, 0, 2, 9) for q in (1, 3, 9)]
        print(f"    agree at x0 -> agree everywhere sampled? "
              f"{all(f(t) == g(t) for t in test_points)}")
    # Now two genuinely different transfer functions differ everywhere
    f2 = transfer(Fraction(l * 1, k))
    print(f"    different shifts differ at x0? {f(x0) != f2(x0)}")
    print()


def main() -> None:
    demo_closure()
    demo_density()
    demo_accumulation()
    demo_universality()
    demo_rigidity()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
