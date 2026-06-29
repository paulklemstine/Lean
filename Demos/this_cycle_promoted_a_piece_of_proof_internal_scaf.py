"""
demo.py — The entry-point invariant of strong divisibility sequences.

Numerical demonstrations of the results in the accompanying paper:

  * the renormalization identity  gcd(u(m), u(n)) = u(gcd(m, n))
  * the entry point (rank of apparition)  entry(m)
  * the law of apparition  m | u(k)  <=>  entry(m) | k
  * fractal injectivity: a modulus is a primitive divisor of at most one term
  * the Pisano period and pure periodicity of the pair-map
  * multiplicativity of the Fibonacci entry point on coprime moduli

Everything is computed by modular iteration on (Z/mZ)^2; the astronomically
large sequence values never enter the runtime.  Pure standard library.

Run:  python3 demo.py
"""

from __future__ import annotations

from math import gcd
from typing import Callable, Dict, List, Optional, Tuple


# --------------------------------------------------------------------------- #
# Strong divisibility sequences (raw values, for small-index sanity checks)   #
# --------------------------------------------------------------------------- #

def fib(n: int) -> int:
    """The n-th Fibonacci number with F(0)=0, F(1)=1, F(2)=1, ..."""
    a, b = 0, 1
    for _ in range(n):
        a, b = b, a + b
    return a


def mersenne(a: int) -> Callable[[int], int]:
    """The base-`a` Mersenne/repunit sequence  u(n) = a^n - 1."""
    def u(n: int) -> int:
        return a ** n - 1
    return u


# --------------------------------------------------------------------------- #
# The entry point, computed without big integers (Fibonacci model)            #
# --------------------------------------------------------------------------- #

def fib_entry(m: int) -> int:
    """
    entry(m): the least k > 0 with m | F(k), via the pair-map (F(n), F(n+1)) mod m.

    Terminates within m^2 + 1 steps by the existence theorem.  Complexity:
    O(entry(m)) modular additions on numbers < m.
    """
    if m <= 0:
        raise ValueError("entry point is defined for m > 0")
    if m == 1:
        return 1  # 1 divides F(1) = 1
    a, b = 0 % m, 1 % m  # (F(0), F(1)) mod m
    for k in range(1, m * m + 2):
        a, b = b, (a + b) % m
        # after this step (a, b) = (F(k), F(k+1)) mod m
        if a == 0:
            return k
    raise RuntimeError("unreachable: existence theorem guarantees termination")


def pisano_period(m: int) -> int:
    """
    pi(m): least d > 0 with (F(d), F(d+1)) == (F(0), F(1)) = (0, 1) mod m.

    By backward determinism the pair-map orbit is purely periodic, so this is
    the true period and entry(m) | pi(m).
    """
    if m <= 0:
        raise ValueError("Pisano period is defined for m > 0")
    if m == 1:
        return 1
    a, b = 0, 1
    for d in range(1, m * m + 2):
        a, b = b, (a + b) % m
        if a == 0 and b == 1:
            return d
    raise RuntimeError("unreachable")


# --------------------------------------------------------------------------- #
# Generic entry point for any strong divisibility sequence (small range)      #
# --------------------------------------------------------------------------- #

def entry_generic(u: Callable[[int], int], m: int, search: int = 2000) -> Optional[int]:
    """entry(m) for an arbitrary sequence u, by direct search up to `search`."""
    for k in range(1, search + 1):
        if u(k) % m == 0:
            return k
    return None


def is_primitive(u: Callable[[int], int], m: int, n: int) -> bool:
    """IsPrimitive(m, n): m | u(n) but m | u(k) for no 0 < k < n."""
    if n <= 0 or u(n) % m != 0:
        return False
    return all(u(k) % m != 0 for k in range(1, n))


# --------------------------------------------------------------------------- #
# Demonstrations                                                              #
# --------------------------------------------------------------------------- #

def demo_renormalization_identity() -> None:
    print("=" * 70)
    print("1. Renormalization identity  gcd(F(m), F(n)) = F(gcd(m, n))")
    print("=" * 70)
    pairs: List[Tuple[int, int]] = [(8, 12), (10, 15), (6, 9), (14, 21), (7, 11)]
    for m, n in pairs:
        lhs = gcd(fib(m), fib(n))
        rhs = fib(gcd(m, n))
        ok = "OK" if lhs == rhs else "FAIL"
        print(f"  gcd(F({m}), F({n})) = {lhs:>6}   F(gcd({m},{n})) = {rhs:>6}   [{ok}]")
    print()


def demo_entry_points() -> None:
    print("=" * 70)
    print("2. Entry points (rank of apparition) of small primes in Fibonacci")
    print("=" * 70)
    for p in [2, 3, 5, 7, 11, 13, 17, 19, 23]:
        e = fib_entry(p)
        print(f"  entry({p:>2}) = {e:>3}   (F({e}) = {fib(e)}, divisible by {p}: "
              f"{fib(e) % p == 0})")
    print()


def demo_law_of_apparition() -> None:
    print("=" * 70)
    print("3. Law of apparition:  m | F(k)  <=>  entry(m) | k")
    print("=" * 70)
    for m in [7, 11, 4]:
        e = fib_entry(m)
        appearing = [k for k in range(1, 41) if fib(k) % m == 0]
        predicted = [k for k in range(1, 41) if k % e == 0]
        ok = "OK" if appearing == predicted else "FAIL"
        print(f"  m={m:>2}, entry={e:>2}:  indices of appearance {appearing}")
        print(f"            multiples of entry {predicted}   [{ok}]")
    print()


def demo_fractal_injectivity() -> None:
    print("=" * 70)
    print("4. Fractal injectivity: each prime is a primitive divisor of ONE F(n)")
    print("=" * 70)
    # For each n, find the primitive prime divisors of F(n); collect (prime -> n).
    debut: Dict[int, int] = {}
    conflict = False
    for n in range(1, 25):
        fn = fib(n)
        if fn <= 1:
            continue
        # primitive prime divisors of F(n): primes p | F(n) with entry(p) == n
        f = fn
        primes: List[int] = []
        d = 2
        while d * d <= f:
            if f % d == 0:
                primes.append(d)
                while f % d == 0:
                    f //= d
            d += 1
        if f > 1:
            primes.append(f)
        prim = [p for p in primes if fib_entry(p) == n]
        for p in prim:
            if p in debut and debut[p] != n:
                conflict = True
            debut[p] = n
        if prim:
            print(f"  F({n:>2}) = {fn:>6}   primitive prime divisors: {prim}")
    print(f"\n  Any prime debuting at two different indices? {conflict}  "
          f"(expected: False)")
    print()


def demo_pisano_period() -> None:
    print("=" * 70)
    print("5. Pisano period pi(m) and the divisibility entry(m) | pi(m)")
    print("=" * 70)
    for m in [2, 3, 5, 7, 10, 11, 12]:
        e = fib_entry(m)
        pi = pisano_period(m)
        ok = "OK" if pi % e == 0 else "FAIL"
        print(f"  m={m:>2}:  entry={e:>3}, pi={pi:>3}, "
              f"pi % entry = {pi % e}, pi <= m^2-1={m * m - 1}  [{ok}]")
    print()


def demo_multiplicativity() -> None:
    print("=" * 70)
    print("6. Multiplicativity:  entry(a*b) = lcm(entry(a), entry(b)) for coprime a,b")
    print("=" * 70)
    coprime_pairs: List[Tuple[int, int]] = [(2, 3), (3, 5), (4, 7), (5, 11), (7, 9)]
    for a, b in coprime_pairs:
        assert gcd(a, b) == 1
        ea, eb, eab = fib_entry(a), fib_entry(b), fib_entry(a * b)
        lcm = ea * eb // gcd(ea, eb)
        ok = "OK" if eab == lcm else "FAIL"
        print(f"  a={a:>2}, b={b:>2}:  entry({a*b:>3})={eab:>3}, "
              f"lcm(entry {ea}, entry {eb})={lcm:>3}   [{ok}]")
    print()


def demo_mersenne_transfer() -> None:
    print("=" * 70)
    print("7. Same theory, Mersenne sequence u(n) = 2^n - 1")
    print("=" * 70)
    u = mersenne(2)
    # gcd identity check
    for m, n in [(4, 6), (6, 9), (3, 5)]:
        lhs = gcd(u(m), u(n))
        rhs = u(gcd(m, n))
        ok = "OK" if lhs == rhs else "FAIL"
        print(f"  gcd(2^{m}-1, 2^{n}-1) = {lhs:>4}   2^gcd({m},{n})-1 = {rhs:>4}  [{ok}]")
    # entry points
    print("  entry points in u(n) = 2^n - 1:")
    for p in [3, 5, 7, 11, 13, 31]:
        e = entry_generic(u, p)
        print(f"    entry({p:>2}) = {e}   (2^{e}-1 = {u(e)} divisible by {p})")
    # injectivity: 7 debuts once
    debuts = [n for n in range(1, 13) if is_primitive(u, 7, n)]
    print(f"  indices where 7 is a PRIMITIVE divisor of 2^n - 1: {debuts}  "
          f"(expected exactly one)")
    print()


def main() -> None:
    demo_renormalization_identity()
    demo_entry_points()
    demo_law_of_apparition()
    demo_fractal_injectivity()
    demo_pisano_period()
    demo_multiplicativity()
    demo_mersenne_transfer()
    print("All demonstrations complete.")


if __name__ == "__main__":
    main()
