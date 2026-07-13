"""
The Uncanny Valley of Prime-Generating Polynomials
==================================================

Numerical demonstrations of the results:

  1. No nonconstant integer polynomial is prime at every integer input.
  2. The set of inputs where such a polynomial is NOT prime is infinite.

Both flow from the *divisibility engine*:

        f(a)  divides  f(a + k * f(a))     for all integers a, k.

Every function is self-contained and uses only the Python standard library.
Run directly:  python demo.py
"""

from __future__ import annotations

from typing import Callable, List, Tuple, Optional


# --------------------------------------------------------------------------- #
# Basic arithmetic helpers
# --------------------------------------------------------------------------- #

def is_prime(n: int) -> bool:
    """Primality test on |n| (a prime integer has prime absolute value)."""
    m = abs(n)
    if m < 2:
        return False
    if m % 2 == 0:
        return m == 2
    d = 3
    while d * d <= m:
        if m % d == 0:
            return False
        d += 2
    return True


# A polynomial with integer coefficients is a callable int -> int.
IntPoly = Callable[[int], int]


def poly_from_coeffs(coeffs: List[int]) -> IntPoly:
    """Build f(x) = c[0] + c[1] x + c[2] x^2 + ... from a coefficient list."""
    def f(x: int) -> int:
        acc = 0
        for c in reversed(coeffs):   # Horner's rule
            acc = acc * x + c
        return acc
    return f


# The archetypal prime-generating polynomial: Euler's n^2 + n + 41.
def euler_poly(n: int) -> int:
    return n * n + n + 41


# --------------------------------------------------------------------------- #
# 1. The divisibility engine  f(a) | f(a + k f(a))
# --------------------------------------------------------------------------- #

def verify_divisibility_engine(f: IntPoly, a: int, k_range: range) -> bool:
    """Check f(a) | f(a + k*f(a)) for all k in k_range. Returns True if all hold."""
    fa = f(a)
    if fa == 0:
        return True  # 0 | 0 trivially along the (constant) progression
    for k in k_range:
        val = f(a + k * fa)
        if val % fa != 0:
            return False
    return True


# --------------------------------------------------------------------------- #
# 2. Prime-run length: how long the illusion lasts
# --------------------------------------------------------------------------- #

def prime_run_length(f: IntPoly, start: int = 0, cap: int = 10_000) -> int:
    """
    Number of consecutive inputs start, start+1, ... on which |f| stays prime.
    Guaranteed to terminate for nonconstant f by the impossibility theorem;
    `cap` is a safety bound.
    """
    n = start
    while n - start < cap and is_prime(f(n)):
        n += 1
    return n - start


# --------------------------------------------------------------------------- #
# 3. Certified failure constructed from a prime value
# --------------------------------------------------------------------------- #

def certified_failure(f: IntPoly, search: range = range(0, 1000)
                      ) -> Optional[Tuple[int, int, int]]:
    """
    Use the divisibility engine to CONSTRUCT a composite value.

    Find a with p = f(a) prime, then the smallest k != 0 with |f(a+k p)| > |p|.
    Then p | f(a+k p) properly, so f(a+k p) is composite.
    Returns (n, divisor p, value f(n)) or None if no prime value is found.
    """
    for a in search:
        p = f(a)
        if not is_prime(p):
            continue
        ap = abs(p)
        k = 1
        while True:
            n = a + k * p
            val = f(n)
            if abs(val) > ap and val % p == 0:
                return (n, p, val)
            k += 1
            if k > 10 * ap + 100:      # safety, essentially never triggered
                break
    return None


# --------------------------------------------------------------------------- #
# 4. Density of prime outputs
# --------------------------------------------------------------------------- #

def prime_density(f: IntPoly, N: int) -> Tuple[int, int, float]:
    """Count prime outputs among f(0..N). Returns (#primes, N+1, fraction)."""
    count = sum(1 for n in range(N + 1) if is_prime(f(n)))
    return count, N + 1, count / (N + 1)


# --------------------------------------------------------------------------- #
# Main demonstration
# --------------------------------------------------------------------------- #

def main() -> None:
    print("=" * 68)
    print("THE UNCANNY VALLEY OF PRIME-GENERATING POLYNOMIALS")
    print("=" * 68)

    # -- Euler's polynomial: the illusion ---------------------------------- #
    print("\n[1] Euler's polynomial f(n) = n^2 + n + 41")
    run = prime_run_length(euler_poly, start=0)
    print(f"    Consecutive primes from n=0: {run}")
    print("    First few values:",
          [euler_poly(n) for n in range(10)])

    # -- The reveal -------------------------------------------------------- #
    print(f"\n[2] The reveal at n = {run}:")
    v = euler_poly(run)
    print(f"    f({run}) = {run}^2 + {run} + 41 = {v} = 41^2 ? {v == 41 ** 2}")
    print(f"    Is it prime? {is_prime(v)}   (composite: {41} x {v // 41})")

    # -- The divisibility engine ------------------------------------------- #
    print("\n[3] Divisibility engine  f(a) | f(a + k f(a))")
    ok = verify_divisibility_engine(euler_poly, a=0, k_range=range(-20, 21))
    print(f"    f(0)=41 divides f(41 k) for k in [-20,20]?  {ok}")
    print("    Sample:  f(0)=41,  f(41) =",
          euler_poly(41), "=> 41 divides it?", euler_poly(41) % 41 == 0)

    # -- Certified failure ------------------------------------------------- #
    print("\n[4] Certified failure constructed from a prime value")
    cf = certified_failure(euler_poly)
    if cf:
        n, p, val = cf
        print(f"    n={n}:  f(n)={val},  divisible by prime p={p}"
              f"  (val/p={val // p}) -> composite")

    # -- Other polynomials also fall -------------------------------------- #
    print("\n[5] Other 'prime-looking' polynomials all fail eventually")
    candidates = {
        "n^2 + n + 41 (Euler)":       poly_from_coeffs([41, 1, 1]),
        "n^2 - n + 41":               poly_from_coeffs([41, -1, 1]),
        "n^2 + n + 17":               poly_from_coeffs([17, 1, 1]),
        "2 n^2 + 29":                 poly_from_coeffs([29, 0, 2]),
        "n^2 + 1":                    poly_from_coeffs([1, 0, 1]),
    }
    for name, f in candidates.items():
        rl = prime_run_length(f, start=0)
        first_fail = f(rl)
        print(f"    {name:26s} prime run = {rl:3d}, "
              f"first non-prime f({rl}) = {first_fail}")

    # -- Density tends to 0 ------------------------------------------------ #
    print("\n[6] Prime-output density of Euler's polynomial")
    for N in (100, 1000, 10000):
        c, tot, frac = prime_density(euler_poly, N)
        print(f"    N={N:6d}:  {c:5d}/{tot:6d} prime  ->  density {frac:.4f}")

    print("\n" + "=" * 68)
    print("Conclusion: every nonconstant integer polynomial leaves the")
    print("prime illusion behind -- infinitely often.")
    print("=" * 68)


if __name__ == "__main__":
    main()
