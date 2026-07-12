"""
Numerical demonstrations for
"The Secret Number Theory of the Mandelbrot Set".

Each function is self-contained and uses type hints. Running this file prints
demonstrations of:

  1. The escape-radius theorem (M is contained in the disk of radius 2).
  2. The doubling map on Z/qZ, the odd/even periodicity dichotomy, and the
     identification of the bulb period of 1/q with the multiplicative order of 2.
  3. The Mersenne-type divisibility and the Fermat bound for prime denominators.
  4. Two false conjectures (2 not always primitive root; period not always prime).
  5. The Farey/Fibonacci golden path: mediants, Cassini's identity, coprimality.

No third-party dependencies are required.
"""

from __future__ import annotations

from math import gcd
from typing import List, Optional, Tuple


# ---------------------------------------------------------------------------
# 1. Quadratic escape dynamics
# ---------------------------------------------------------------------------

def critical_orbit(c: complex, steps: int) -> List[complex]:
    """Return the first `steps`+1 iterates 0, f_c(0), f_c^2(0), ... of z -> z^2 + c."""
    orbit: List[complex] = [0j]
    z: complex = 0j
    for _ in range(steps):
        z = z * z + c
        orbit.append(z)
    return orbit


def escape_step(c: complex, cap: int = 1000) -> Optional[int]:
    """
    Return the first step k at which |z| > 2 (guaranteeing divergence), or None if
    the orbit stays within radius 2 for `cap` steps (a bounded candidate).
    """
    z: complex = 0j
    for k in range(1, cap + 1):
        z = z * z + c
        if abs(z) > 2.0:
            return k
    return None


def demo_escape() -> None:
    print("=" * 70)
    print("1. Escape-radius theorem:  M is contained in the disk {|c| <= 2}")
    print("=" * 70)
    for c in [0j, -1 + 0j, -0.75 + 0.1j, 0.26 + 0j, 3 + 0j, 1 + 1j]:
        k = escape_step(c)
        status = "BOUNDED (candidate in M)" if k is None else f"escaped at step {k}"
        print(f"  c = {c:>12}:  |c| = {abs(c):.3f}   ->  {status}")
    print("  Note: every c with |c| > 2 escapes, matching M ⊆ {|c| ≤ 2}.")
    print("  Orbit of c = -1 is the 2-cycle:",
          [round(z.real, 3) for z in critical_orbit(-1 + 0j, 5)])
    print()


# ---------------------------------------------------------------------------
# 2 & 3. Doubling map, multiplicative order, Fermat / Mersenne
# ---------------------------------------------------------------------------

def double_map(x: int, q: int) -> int:
    """The doubling map on Z/qZ: x -> 2x mod q."""
    return (2 * x) % q


def is_bijective_doubling(q: int) -> bool:
    """True iff x -> 2x mod q is a bijection on Z/qZ (iff q is odd)."""
    images = {double_map(x, q) for x in range(q)}
    return len(images) == q


def multiplicative_order_2(q: int) -> Optional[int]:
    """
    Multiplicative order of 2 modulo q: least n >= 1 with 2^n ≡ 1 (mod q).
    Returns None if 2 is not invertible mod q (i.e. q even), where no order exists.
    """
    if gcd(2, q) != 1 or q <= 1:
        return None
    r, n = 1, 0
    while True:
        r = (2 * r) % q
        n += 1
        if r == 1:
            return n


def is_prime(n: int) -> bool:
    if n < 2:
        return False
    i = 2
    while i * i <= n:
        if n % i == 0:
            return False
        i += 1
    return True


def demo_doubling() -> None:
    print("=" * 70)
    print("2. Doubling map on Z/qZ  (bijection  <=>  q odd)")
    print("=" * 70)
    for q in range(2, 13):
        bij = is_bijective_doubling(q)
        parity = "odd " if q % 2 == 1 else "even"
        print(f"  q = {q:2d} ({parity}):  doubling bijective? {bij}")
    print()

    print("=" * 70)
    print("3. Period of angle 1/q = ord_q(2);  Mersenne & Fermat")
    print("=" * 70)
    for q in [3, 5, 7, 9, 11, 13, 15, 17]:
        order = multiplicative_order_2(q)
        assert order is not None
        mersenne_ok = (2 ** order - 1) % q == 0
        fermat = ""
        if is_prime(q):
            fermat = f"  |  Fermat: {order} divides q-1={q - 1}? {(q - 1) % order == 0}"
        print(f"  q = {q:2d}:  ord_q(2) = {order:2d}   "
              f"|  q divides 2^{order}-1? {mersenne_ok}{fermat}")
    print()


# ---------------------------------------------------------------------------
# 4. Two false conjectures
# ---------------------------------------------------------------------------

def demo_false_conjectures() -> None:
    print("=" * 70)
    print("4. Contrarian section: two tempting FALSE conjectures")
    print("=" * 70)
    o7 = multiplicative_order_2(7)
    print(f"  Conjecture A: '2 is a primitive root mod every odd prime' (ord = q-1).")
    print(f"    Counterexample q = 7:  ord_7(2) = {o7} != 6.  FALSE.")
    o5 = multiplicative_order_2(5)
    assert o5 is not None
    print(f"  Conjecture B: 'every bulb period is prime'.")
    print(f"    Counterexample q = 5:  ord_5(2) = {o5}, which is composite.  FALSE.")
    print()


# ---------------------------------------------------------------------------
# 5. Farey / Fibonacci golden path
# ---------------------------------------------------------------------------

def fib(n: int) -> int:
    """The n-th Fibonacci number, F_0 = 0, F_1 = 1."""
    a, b = 0, 1
    for _ in range(n):
        a, b = b, a + b
    return a


def mediant(a: Tuple[int, int], b: Tuple[int, int]) -> Tuple[int, int]:
    """Mediant of two fractions given as (numerator, denominator) pairs."""
    return (a[0] + b[0], a[1] + b[1])


def cassini(n: int) -> int:
    """F_{n+1}^2 - F_n * F_{n+2}, which equals (-1)^n."""
    return fib(n + 1) ** 2 - fib(n) * fib(n + 2)


def demo_farey_fibonacci() -> None:
    print("=" * 70)
    print("5. Farey mediants, Fibonacci golden path, Cassini's identity")
    print("=" * 70)
    print("  Golden path of external angles F_n / F_{n+1}:")
    for n in range(1, 9):
        p, q = fib(n), fib(n + 1)
        print(f"    F_{n}/F_{n + 1} = {p}/{q} = {p / q:.6f}"
              f"   (gcd = {gcd(p, q)}, in lowest terms)")
    print(f"  Limit  ->  1/phi = {(5 ** 0.5 - 1) / 2:.6f}")
    print()
    print("  Mediant law: med(F_n/F_{n+1}, F_{n+1}/F_{n+2}) = F_{n+2}/F_{n+3}:")
    for n in range(0, 6):
        m = mediant((fib(n), fib(n + 1)), (fib(n + 1), fib(n + 2)))
        expect = (fib(n + 2), fib(n + 3))
        print(f"    n={n}: mediant = {m},  expected {expect},  match = {m == expect}")
    print()
    print("  Cassini's identity F_{n+1}^2 - F_n F_{n+2} = (-1)^n:")
    for n in range(0, 8):
        print(f"    n={n}: {cassini(n):+d}  (= (-1)^{n} = {(-1) ** n:+d}),  "
              f"|.| = {abs(cassini(n))}  (Farey neighbour)")
    print()


def main() -> None:
    demo_escape()
    demo_doubling()
    demo_false_conjectures()
    demo_farey_fibonacci()


if __name__ == "__main__":
    main()
