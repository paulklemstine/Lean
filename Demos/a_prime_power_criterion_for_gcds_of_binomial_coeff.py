"""
demo.py — The interior Pascal-row gcd as a prime-power detector.

This script numerically demonstrates the main theorem:

    F(k) = gcd_{1 <= i <= k} C(k+1, i)

satisfies, for all k >= 1,

    F(k) = 1   <==>   k+1 is NOT a prime power,

and when k+1 = p^a is a prime power, F(k) = p (the underlying prime).

All helper functions are inlined and self-contained (standard library only).
"""

from __future__ import annotations

from math import comb, gcd, isqrt
from typing import Optional


# --------------------------------------------------------------------------
# Core definitions
# --------------------------------------------------------------------------

def interior_row_gcd(k: int) -> int:
    """F(k) = gcd of the interior entries C(k+1, i), 1 <= i <= k.

    For k >= 1 this is the gcd of the entries of row n = k+1 of Pascal's
    triangle strictly between the bounding 1's.
    """
    if k < 1:
        raise ValueError("k must be >= 1")
    g = 0
    # Use the multiplicative recurrence to avoid recomputing factorials.
    c = 1  # C(k+1, 0)
    n = k + 1
    for i in range(1, k + 1):
        c = c * (n - i + 1) // i  # now c == C(n, i)
        g = gcd(g, c)
        if g == 1:
            # gcd can only stay 1 once it reaches 1; early exit is safe.
            return 1
    return g


def is_prime(n: int) -> bool:
    """Deterministic trial-division primality test."""
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


def prime_power_base(n: int) -> Optional[int]:
    """If n = p^a (prime p, a >= 1) return p, else return None.

    By definition 1 is NOT a prime power, so prime_power_base(1) is None.
    """
    if n < 2:
        return None
    # Find the smallest prime factor p, then check n is a pure power of p.
    p = None
    d = 2
    while d * d <= n:
        if n % d == 0:
            p = d
            break
        d += 1
    if p is None:
        return n  # n itself is prime
    m = n
    while m % p == 0:
        m //= p
    return p if m == 1 else None


def is_prime_power(n: int) -> bool:
    """True iff n = p^a for some prime p and exponent a >= 1."""
    return prime_power_base(n) is not None


# --------------------------------------------------------------------------
# Kummer-carry machinery: the engine behind the hard direction.
# --------------------------------------------------------------------------

def base_p_digits(n: int, p: int) -> list[int]:
    """Digits of n in base p, least significant first."""
    if n == 0:
        return [0]
    digits: list[int] = []
    while n > 0:
        digits.append(n % p)
        n //= p
    return digits


def kummer_carries(a: int, b: int, p: int) -> int:
    """Number of carries when adding a and b in base p.

    By Kummer's theorem this equals v_p( C(a+b, a) ), the exact power of p
    dividing the binomial coefficient.
    """
    da = base_p_digits(a, p)
    db = base_p_digits(b, p)
    length = max(len(da), len(db))
    da += [0] * (length - len(da))
    db += [0] * (length - len(db))
    carries = 0
    carry = 0
    for i in range(length):
        s = da[i] + db[i] + carry
        if s >= p:
            carries += 1
            carry = 1
        else:
            carry = 0
    return carries


def p_adic_val(n: int, p: int) -> int:
    """v_p(n): the largest e with p^e | n (n >= 1)."""
    e = 0
    while n % p == 0:
        n //= p
        e += 1
    return e


# --------------------------------------------------------------------------
# Demonstrations
# --------------------------------------------------------------------------

def demo_main_theorem(kmax: int = 30) -> None:
    """Tabulate F(k) against the prime-power status of k+1."""
    print("=" * 72)
    print("MAIN THEOREM:  F(k) = 1  <=>  k+1 is not a prime power")
    print("=" * 72)
    print(f"{'k':>4} {'n=k+1':>6} {'F(k)':>6} {'pp(n)?':>7} {'theorem holds?':>15}")
    print("-" * 72)
    all_ok = True
    for k in range(1, kmax + 1):
        f = interior_row_gcd(k)
        pp = is_prime_power(k + 1)
        # Theorem: (F == 1) iff (not pp)
        holds = (f == 1) == (not pp)
        all_ok &= holds
        print(f"{k:>4} {k + 1:>6} {f:>6} {str(pp):>7} {str(holds):>15}")
    print("-" * 72)
    print(f"All {kmax} cases consistent with the theorem: {all_ok}")
    print()


def demo_exact_value(kmax: int = 30) -> None:
    """On prime-power rows, F(k) equals the underlying prime."""
    print("=" * 72)
    print("COROLLARY:  if k+1 = p^a then F(k) = p")
    print("=" * 72)
    for k in range(1, kmax + 1):
        base = prime_power_base(k + 1)
        if base is not None:
            f = interior_row_gcd(k)
            tag = "OK" if f == base else "MISMATCH"
            print(f"k={k:>3}  n=k+1={k + 1:>3} = {base}^{p_adic_val(k + 1, base)}"
                  f"   F(k)={f:>3}   underlying prime={base:>3}   [{tag}]")
    print()


def demo_carry_witness(k: int) -> None:
    """Exhibit, for a non-prime-power k+1, a carry-free interior witness for
    each prime p | (k+1), proving p does not divide the whole interior."""
    n = k + 1
    print("=" * 72)
    print(f"CARRY-FREE WITNESSES for k={k}, n=k+1={n}")
    print("=" * 72)
    if is_prime_power(n):
        print(f"  n={n} IS a prime power; no carry-free witness exists for its prime.")
        print()
        return
    # Collect distinct primes dividing n.
    primes: list[int] = [p for p in range(2, n + 1) if is_prime(p) and n % p == 0]
    for p in primes:
        a = p_adic_val(n, p)
        i = p ** a                     # the chosen interior index
        b = n - i
        carries = kummer_carries(i, b, p)
        val = p_adic_val(comb(n, i), p)
        print(f"  prime p={p}: a=v_p(n)={a}, i=p^a={i}, "
              f"C({n},{i})={comb(n, i)}")
        print(f"    base-{p}: {i} + {b} -> carries={carries}  "
              f"=> v_{p}(C)={val}  (p divides interior? {val > 0})")
    print(f"  No prime divides every interior term  =>  F({k}) = {interior_row_gcd(k)}")
    print()


def demo_gcd_is_one_or_prime(kmax: int = 50) -> None:
    """Empirically confirm F(k) is always 1 or a single prime."""
    print("=" * 72)
    print("STRUCTURE:  F(k) is always 1 or a prime")
    print("=" * 72)
    bad = []
    for k in range(1, kmax + 1):
        f = interior_row_gcd(k)
        if f != 1 and not is_prime(f):
            bad.append((k, f))
    if not bad:
        print(f"Verified for k = 1..{kmax}: every F(k) is 1 or prime.")
    else:
        print(f"Unexpected values: {bad}")
    print()


if __name__ == "__main__":
    demo_main_theorem(30)
    demo_exact_value(30)
    demo_gcd_is_one_or_prime(50)
    # A few illustrative carry-free witnesses on non-prime-power rows:
    for k in (5, 9, 11, 13, 20):
        demo_carry_witness(k)
