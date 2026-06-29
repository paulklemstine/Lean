"""
demo.py — The Fibonacci Rank-of-Apparition Map as a Lattice Adjoint
===================================================================

Self-contained numerical demonstration of the main results:

    entry(m) = least k > 0 with m | F(k)            (rank of apparition)

    Apparition law:        m | F(n)  <=>  entry(m) | n
    Unitality:             entry(1) = 1
    Monotonicity:          a | b  =>  entry(a) | entry(b)
    Join homomorphism:     entry(lcm(a,b)) = lcm(entry(a), entry(b))      (central result)
    Retraction of F:       entry(F(k)) = k   for k >= 3
    Meet defect:           entry(gcd(a,b)) = gcd(entry(a),entry(b))  is FALSE in general

Everything is inlined; run `python3 demo.py`.
"""

from __future__ import annotations

from math import gcd
from typing import Dict, List, Tuple


# --------------------------------------------------------------------------
# Fibonacci numbers, indexed so that F(1) = F(2) = 1.
# --------------------------------------------------------------------------
def fib(n: int) -> int:
    """Return the n-th Fibonacci number with F(0) = 0, F(1) = F(2) = 1."""
    a, b = 0, 1
    for _ in range(n):
        a, b = b, a + b
    return a


def lcm(a: int, b: int) -> int:
    """Least common multiple of two positive integers."""
    return a * b // gcd(a, b)


# --------------------------------------------------------------------------
# Rank of apparition (entry point), computed with O(entry(m)) modular steps.
# --------------------------------------------------------------------------
def entry(m: int) -> int:
    """The least positive index k with m | F(k). Requires m >= 1."""
    if m < 1:
        raise ValueError("entry(m) requires m >= 1")
    if m == 1:
        return 1
    a, b = 0, 1            # a = F(0) mod m, b = F(1) mod m
    k = 1
    while b % m != 0:
        a, b = b, (a + b) % m
        k += 1
    return k


# --------------------------------------------------------------------------
# Demonstrations.
# --------------------------------------------------------------------------
def demo_entry_table(upto: int = 15) -> Dict[int, int]:
    """Print the table of entry points and the first Fibonacci multiple."""
    print("=" * 64)
    print("Rank of apparition table:  entry(m) and F(entry(m))")
    print("=" * 64)
    print(f"{'m':>4} | {'entry(m)':>9} | first Fibonacci multiple F(entry(m))")
    print("-" * 64)
    table: Dict[int, int] = {}
    for m in range(1, upto + 1):
        e = entry(m)
        table[m] = e
        print(f"{m:>4} | {e:>9} | F({e}) = {fib(e)}")
    return table


def demo_apparition_law(max_m: int = 12, max_n: int = 60) -> None:
    """Verify  m | F(n)  <=>  entry(m) | n  exhaustively on a grid."""
    print("\n" + "=" * 64)
    print("Apparition law:  m | F(n)  <=>  entry(m) | n")
    print("=" * 64)
    failures = 0
    for m in range(1, max_m + 1):
        e = entry(m)
        for n in range(1, max_n + 1):
            lhs = (fib(n) % m == 0)
            rhs = (n % e == 0)
            if lhs != rhs:
                failures += 1
                print(f"  MISMATCH at m={m}, n={n}")
    print(f"checked m<={max_m}, n<={max_n}:  {'ALL CONSISTENT' if failures == 0 else f'{failures} FAILURES'}")


def demo_unital_and_monotone(upto: int = 25) -> None:
    """Verify entry(1) = 1 and  a | b => entry(a) | entry(b)."""
    print("\n" + "=" * 64)
    print("Unitality and monotonicity")
    print("=" * 64)
    print(f"entry(1) = {entry(1)}   (expected 1)")
    bad = 0
    for a in range(1, upto + 1):
        for b in range(1, upto + 1):
            if b % a == 0:  # a | b
                if entry(b) % entry(a) != 0:
                    bad += 1
                    print(f"  monotonicity fails: a={a}, b={b}")
    print(f"monotonicity a|b => entry(a)|entry(b) on pairs <= {upto}: "
          f"{'HOLDS' if bad == 0 else f'{bad} FAILURES'}")


def demo_join_homomorphism(upto: int = 30) -> None:
    """Central result: entry(lcm(a,b)) = lcm(entry(a), entry(b))."""
    print("\n" + "=" * 64)
    print("Join-homomorphism law:  entry(lcm(a,b)) = lcm(entry(a), entry(b))")
    print("=" * 64)
    examples: List[Tuple[int, int]] = [(2, 3), (2, 5), (3, 4), (4, 7), (6, 10)]
    for a, b in examples:
        lhs = entry(lcm(a, b))
        rhs = lcm(entry(a), entry(b))
        print(f"  a={a:>2}, b={b:>2}: entry(lcm={lcm(a,b):>3}) = {lhs:>3}  | "
              f"lcm(entry={entry(a)},entry={entry(b)}) = {rhs:>3}  -> {'OK' if lhs == rhs else 'FAIL'}")
    bad = 0
    for a in range(1, upto + 1):
        for b in range(1, upto + 1):
            if entry(lcm(a, b)) != lcm(entry(a), entry(b)):
                bad += 1
    print(f"exhaustive check on all pairs <= {upto}: "
          f"{'JOIN LAW HOLDS' if bad == 0 else f'{bad} FAILURES'}")


def demo_retraction(kmax: int = 15) -> None:
    """Verify entry(F(k)) = k for k >= 3, and show failure at k = 2."""
    print("\n" + "=" * 64)
    print("Retraction of F:  entry(F(k)) = k  for k >= 3")
    print("=" * 64)
    for k in range(2, kmax + 1):
        e = entry(fib(k))
        tag = "OK" if (k >= 3 and e == k) else ("(boundary: F(2)=1)" if k == 2 else "FAIL")
        print(f"  k={k:>2}: F(k)={fib(k):>4}, entry(F(k))={e:>2}   {tag}")


def demo_meet_defect(upto: int = 20) -> None:
    """Show entry(gcd(a,b)) = gcd(entry(a),entry(b)) FAILS, with the lax law holding."""
    print("\n" + "=" * 64)
    print("Meet defect:  entry(gcd) vs gcd(entry)  (left adjoint need not preserve meets)")
    print("=" * 64)
    a, b = 3, 7
    left = entry(gcd(a, b))
    right = gcd(entry(a), entry(b))
    print(f"  a={a}, b={b}: entry(gcd={gcd(a,b)}) = {left}  but  gcd(entry={entry(a)},entry={entry(b)}) = {right}")
    print(f"  -> equality {'HOLDS' if left == right else 'FAILS'};  "
          f"lax law entry(gcd) | gcd(entry): {'holds' if right % left == 0 else 'violated'}")
    worst = (0, 0, 1)
    for x in range(1, upto + 1):
        for y in range(1, upto + 1):
            lo = entry(gcd(x, y))
            hi = gcd(entry(x), entry(y))
            assert hi % lo == 0, "lax containment must always hold"
            if hi // lo > worst[2]:
                worst = (x, y, hi // lo)
    print(f"  largest defect ratio gcd(entry)/entry(gcd) for pairs <= {upto}: "
          f"{worst[2]} at (a,b)=({worst[0]},{worst[1]})")


def demo_prime_power_reduction() -> None:
    """Formula (5.2): entry(m) = lcm over prime powers of entry(p^e)."""
    print("\n" + "=" * 64)
    print("Composite reduction (Formula 5.2):  entry(m) = lcm_i entry(p_i^e_i)")
    print("=" * 64)

    def factorize(n: int) -> List[Tuple[int, int]]:
        factors: List[Tuple[int, int]] = []
        d = 2
        while d * d <= n:
            if n % d == 0:
                e = 0
                while n % d == 0:
                    n //= d
                    e += 1
                factors.append((d, e))
            d += 1
        if n > 1:
            factors.append((n, 1))
        return factors

    for m in [12, 60, 100, 144]:
        direct = entry(m)
        via = 1
        for p, e in factorize(m):
            via = lcm(via, entry(p ** e))
        print(f"  m={m:>4}: entry(m)={direct:>3}, via prime powers {factorize(m)} -> {via:>3}  "
              f"{'OK' if direct == via else 'FAIL'}")


def main() -> None:
    demo_entry_table()
    demo_apparition_law()
    demo_unital_and_monotone()
    demo_join_homomorphism()
    demo_retraction()
    demo_meet_defect()
    demo_prime_power_reduction()
    print("\nAll demonstrations complete.")


if __name__ == "__main__":
    main()
