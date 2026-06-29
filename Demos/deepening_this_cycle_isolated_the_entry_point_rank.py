"""
demo.py — The Pisano Period as the Order of the Fibonacci Shift.

This script demonstrates, numerically, the main results of the package:

  (1) The Fibonacci sequence mod m is the orbit of (0,1) under the shift
      Q(a,b) = (b, a+b)  on  (Z/mZ)^2.                          [representation]
  (2) The closed form  Q^k (a,b) = (a(F_{k+1}-F_k)+b F_k, a F_k + b F_{k+1}).
  (3) The Pisano period pi(m) = order of Q = least k>0 with Q^k = identity.
  (4) Period-return duality: pi(m) | k  <=>  F_k = 0 and F_{k+1} = 1 (mod m).
  (5) Periodicity: F_{n+pi(m)} = F_n (mod m).
  (6) Apparition bound: m | F_{pi(m)}, hence z(m) | pi(m).
  (7) Spectral law: gcd(m,n)=1  =>  pi(mn) = lcm(pi(m), pi(n)).

Pure standard library, fully self-contained, type-hinted.
"""

from __future__ import annotations

from math import gcd
from typing import List, Tuple

Pair = Tuple[int, int]


# --------------------------------------------------------------------------
# Fibonacci numbers (modular, fast doubling) and the shift permutation Q.
# --------------------------------------------------------------------------
def fib_mod(k: int, m: int) -> int:
    """Return F_k mod m using the fast-doubling identities. O(log k)."""
    def fd(n: int) -> Tuple[int, int]:
        # returns (F_n mod m, F_{n+1} mod m)
        if n == 0:
            return (0 % m, 1 % m)
        a, b = fd(n >> 1)
        c = (a * ((2 * b - a) % m)) % m       # F_{2i}
        d = (a * a + b * b) % m               # F_{2i+1}
        if n & 1:
            return (d, (c + d) % m)
        return (c, d)
    return fd(k)[0]


def shift(p: Pair, m: int) -> Pair:
    """The Fibonacci shift Q(a,b) = (b, a+b) on (Z/mZ)^2."""
    a, b = p
    return (b % m, (a + b) % m)


def shift_inv(p: Pair, m: int) -> Pair:
    """The inverse shift Q^{-1}(a,b) = (b-a, a)."""
    a, b = p
    return ((b - a) % m, a % m)


def shift_iterate(p: Pair, k: int, m: int) -> Pair:
    """Apply Q exactly k times to p (direct iteration)."""
    for _ in range(k):
        p = shift(p, m)
    return p


def shift_iterate_closed_form(p: Pair, k: int, m: int) -> Pair:
    """Closed form Q^k(a,b) = (a(F_{k+1}-F_k)+b F_k, a F_k + b F_{k+1})."""
    a, b = p
    fk = fib_mod(k, m)
    fk1 = fib_mod(k + 1, m)
    first = (a * ((fk1 - fk) % m) + b * fk) % m
    second = (a * fk + b * fk1) % m
    return (first, second)


# --------------------------------------------------------------------------
# Pisano period (= order of Q) and entry point z(m).
# --------------------------------------------------------------------------
def pisano_period(m: int) -> int:
    """pi(m): least k>0 with the orbit of (0,1) under Q returning to (0,1)."""
    if m == 1:
        return 1
    a, b = 0, 1
    for k in range(1, 6 * m + 1):
        a, b = b % m, (a + b) % m
        if a == 0 and b == 1:
            return k
    raise RuntimeError("period not found within bound (should never happen)")


def entry_point(m: int) -> int:
    """z(m): least k>0 with m | F_k (rank of apparition)."""
    if m == 1:
        return 1
    a, b = 0, 1
    for k in range(1, 6 * m + 1):
        a, b = b % m, (a + b) % m
        if a == 0:
            return k
    raise RuntimeError("entry point not found (should never happen)")


def lcm(x: int, y: int) -> int:
    return x // gcd(x, y) * y


# --------------------------------------------------------------------------
# Demonstrations.
# --------------------------------------------------------------------------
def demo_representation(m: int, n_terms: int = 12) -> None:
    print(f"[Representation]  Fibonacci mod {m} as the orbit of (0,1) under Q")
    p: Pair = (0, 1)
    seq: List[int] = []
    for _ in range(n_terms):
        seq.append(p[0])
        p = shift(p, m)
    direct = [fib_mod(k, m) for k in range(n_terms)]
    print(f"   orbit first coords : {seq}")
    print(f"   F_k mod m directly : {direct}")
    assert seq == direct
    print("   OK: the orbit reproduces the Fibonacci sequence.\n")


def demo_closed_form(m: int) -> None:
    print(f"[Closed form]  Q^k by iteration vs. Fibonacci-matrix formula (m={m})")
    for (a, b) in [(0, 1), (2, 3), (5, 7)]:
        for k in [0, 1, 5, 13, 30]:
            it = shift_iterate((a, b), k, m)
            cf = shift_iterate_closed_form((a, b), k, m)
            assert it == cf, (a, b, k, it, cf)
    print("   OK: closed form matches direct iteration on all samples.\n")


def demo_duality(m: int) -> None:
    pi = pisano_period(m)
    print(f"[Duality]  pi({m}) = {pi};  pi(m)|k  <=>  F_k=0 and F_{{k+1}}=1 (mod m)")
    for k in range(1, 3 * pi + 1):
        lhs = (k % pi == 0)
        rhs = (fib_mod(k, m) == 0 % m and fib_mod(k + 1, m) == 1 % m)
        assert lhs == rhs, (k, lhs, rhs)
    print("   OK: divisibility by the period <=> return to the seed (0,1).\n")


def demo_periodicity(m: int) -> None:
    pi = pisano_period(m)
    print(f"[Periodicity]  F_{{n+pi(m)}} = F_n (mod {m}),  pi={pi}")
    for n in range(0, 40):
        assert fib_mod(n + pi, m) == fib_mod(n, m)
    print("   OK: shifting the index by a full period changes nothing.\n")


def demo_apparition(m: int) -> None:
    pi = pisano_period(m)
    z = entry_point(m)
    print(f"[Apparition]  z({m})={z},  pi({m})={pi},  m|F_pi, z|pi, pi/z={pi // z}")
    assert fib_mod(pi, m) == 0 % m         # m | F_{pi(m)}
    assert pi % z == 0                      # z(m) | pi(m)
    assert (pi // z) in (1, 2, 4)           # classical trichotomy
    print("   OK: period is an apparition index; ratio pi/z in {1,2,4}.\n")


def demo_spectral(pairs: List[Tuple[int, int]]) -> None:
    print("[Spectral law]  gcd(m,n)=1  =>  pi(mn) = lcm(pi(m), pi(n))")
    for (m, n) in pairs:
        assert gcd(m, n) == 1
        lhs = pisano_period(m * n)
        rhs = lcm(pisano_period(m), pisano_period(n))
        flag = "OK " if lhs == rhs else "XX "
        print(f"   {flag} pi({m*n}) = {lhs:5d}   lcm(pi({m})={pisano_period(m)},"
              f" pi({n})={pisano_period(n)}) = {rhs}")
        assert lhs == rhs
    print()


def demo_table(limit: int = 16) -> None:
    print(f"[Table]  m, pi(m), z(m), pi/z  for m = 1..{limit}")
    print("   m :  pi(m)   z(m)   pi/z")
    for m in range(1, limit + 1):
        pi = pisano_period(m)
        z = entry_point(m)
        print(f"  {m:2d} : {pi:6d} {z:6d}   {pi // z}")
    print()


def main() -> None:
    print("=" * 68)
    print(" The Pisano Period as the Order of the Fibonacci Shift Q(a,b)=(b,a+b)")
    print("=" * 68 + "\n")
    demo_representation(12)
    demo_closed_form(97)
    demo_duality(14)
    demo_periodicity(12)
    for m in (7, 11, 12, 29):
        demo_apparition(m)
    demo_spectral([(3, 5), (4, 25), (2, 7), (8, 9), (9, 5), (11, 13)])
    demo_table(16)
    print("All checks passed.")


if __name__ == "__main__":
    main()
