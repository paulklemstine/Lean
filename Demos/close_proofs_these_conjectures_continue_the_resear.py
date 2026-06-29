"""
Numerical demonstration of Carmichael's theorem on primitive prime divisors
of Fibonacci numbers.

A prime p is a *primitive prime divisor* of F(n) if p | F(n) but p does not
divide F(k) for any 0 < k < n.  Carmichael's theorem states that F(n) has a
primitive prime divisor for every n >= 13 (the only exceptional indices are
1, 2, 6, 12).

This script mirrors the formal development:
  * fib              -- fast-doubling Fibonacci
  * strip_all_aux    -- iterated gcd-stripping (the `stripAllAux` definition)
  * proper_divisors  -- `propDivs`
  * prim_part        -- the primitive part `primPart`
  * primitive_divisors / least_primitive_divisor
and verifies the three regimes of the proof:
  * prime indices (fib_primitive_divisor_prime),
  * the computational range 13..N (primPart_check),
  * the equivalence primPart(n) > 1  <=>  a primitive divisor exists.

Run:  python3 demo.py
"""

from __future__ import annotations

from math import gcd
from typing import Dict, List, Tuple


def fib(n: int) -> int:
    """Return the n-th Fibonacci number with F(1) = F(2) = 1 via fast doubling."""
    def _fd(k: int) -> Tuple[int, int]:
        if k == 0:
            return (0, 1)
        a, b = _fd(k >> 1)
        c = a * (2 * b - a)
        d = a * a + b * b
        if k & 1:
            return (d, c + d)
        return (c, d)
    return _fd(n)[0]


def strip_all_aux(r: int, m: int) -> int:
    """Repeatedly divide r by gcd(r, m) until r and m are coprime.

    This is the `stripAllAux` definition; fuel is implicit (the loop always
    terminates because r strictly decreases on every productive step).
    """
    if m <= 1:
        return r
    while True:
        g = gcd(r, m)
        if g <= 1:
            return r
        r //= g


def proper_divisors(n: int) -> List[int]:
    """List of d with 0 < d < n and d | n  (the `propDivs` definition)."""
    return [d for d in range(1, n) if n % d == 0]


def prim_part(n: int) -> int:
    """The primitive part of F(n): strip from F(n) all factors shared with
    F(d) for each proper divisor d of n  (the `primPart` definition)."""
    r = fib(n)
    for d in proper_divisors(n):
        r = strip_all_aux(r, fib(d))
    return r


def factorize(m: int) -> Dict[int, int]:
    """Trial-division prime factorization (fine for the moderate F(n) here)."""
    factors: Dict[int, int] = {}
    d = 2
    while d * d <= m:
        while m % d == 0:
            factors[d] = factors.get(d, 0) + 1
            m //= d
        d += 1 if d == 2 else 2
    if m > 1:
        factors[m] = factors.get(m, 0) + 1
    return factors


def primitive_divisors(n: int) -> List[int]:
    """All primitive prime divisors of F(n), found directly from the definition."""
    fn = fib(n)
    earlier = set()
    for k in range(1, n):
        earlier |= set(factorize(fib(k)))
    return sorted(p for p in factorize(fn) if p not in earlier)


def least_primitive_divisor(n: int) -> int:
    """The smallest prime factor of primPart(n); by the theorem this is a
    primitive prime divisor of F(n) whenever primPart(n) > 1."""
    pp = prim_part(n)
    if pp <= 1:
        return 0
    return min(factorize(pp))


def is_prime(n: int) -> bool:
    if n < 2:
        return False
    d = 2
    while d * d <= n:
        if n % d == 0:
            return False
        d += 1
    return True


def demo_table(lo: int = 7, hi: int = 25) -> None:
    """Show F(n), its factorization, and the primitive divisor for each n."""
    print(f"{'n':>3} {'F(n)':>10} {'factorization':<22} {'primPart':>10} {'prim. divs':<14}")
    print("-" * 64)
    for n in range(lo, hi + 1):
        fn = fib(n)
        fac = factorize(fn)
        fac_str = " * ".join(f"{p}^{e}" if e > 1 else f"{p}" for p, e in sorted(fac.items())) or "1"
        pds = primitive_divisors(n)
        pds_str = ", ".join(map(str, pds)) if pds else "(none)"
        print(f"{n:>3} {fn:>10} {fac_str:<22} {prim_part(n):>10} {pds_str:<14}")


def verify_carmichael(lo: int = 13, hi: int = 2000) -> None:
    """Verify primPart(n) > 1 for every n in [lo, hi] (the `primPart_check`
    computation), and that the least prime factor of primPart(n) is genuinely
    primitive on a sample (the equivalence used in the proof)."""
    bad = [n for n in range(lo, hi + 1) if prim_part(n) <= 1]
    assert not bad, f"primPart(n) <= 1 at: {bad}"
    print(f"[OK] primPart(n) > 1 for all {lo} <= n <= {hi}  ({hi - lo + 1} cases)")

    # Spot-check the equivalence: least primitive divisor matches the brute force.
    for n in list(range(13, 31)) + [37, 41, 47]:
        lp = least_primitive_divisor(n)
        brute = primitive_divisors(n)
        assert lp in brute, f"mismatch at n={n}: {lp} not in {brute}"
    print("[OK] least prime factor of primPart(n) is a genuine primitive divisor")


def verify_exceptions() -> None:
    """Confirm 1, 2, 6, 12 are exactly the exceptional indices below 13."""
    exceptions = [n for n in range(1, 13) if not primitive_divisors(n)]
    print(f"[OK] exceptional indices below 13: {exceptions}  (expected [1, 2, 6, 12])")
    assert exceptions == [1, 2, 6, 12]


def verify_prime_index_case(hi: int = 60) -> None:
    """For prime n >= 3, ANY prime factor of F(n) is primitive
    (fib_primitive_divisor_prime)."""
    for n in range(3, hi + 1):
        if is_prime(n):
            prims = set(primitive_divisors(n))
            for p in factorize(fib(n)):
                assert p in prims, f"prime-index case failed at n={n}, p={p}"
    print(f"[OK] prime-index case: every prime factor of F(n) is primitive for prime n <= {hi}")


if __name__ == "__main__":
    print("=" * 64)
    print("Primitive prime divisors of Fibonacci numbers")
    print("=" * 64)
    demo_table()
    print()
    verify_exceptions()
    verify_prime_index_case()
    verify_carmichael()
    print()
    print("All checks passed.")
