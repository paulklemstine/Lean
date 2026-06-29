"""
demo.py — The Fibonacci rank of apparition as a Galois adjunction `fibRank ⊣ fib`.

This self-contained script numerically demonstrates every headline result of the
package:

  * the rank of apparition `fibRank m` (least k > 0 with m | F(k)),
  * the Law of Apparition           m | F(n)  <=>  fibRank m | n,
  * the closure operator c(m) = F(fibRank m) and its idempotence,
  * the representation theorem: fixed points of c are exactly Fibonacci values,
  * the unification capstones:
        F(gcd(a,b)) = gcd(F(a), F(b))                 (right adjoint preserves meets)
        fibRank(lcm(a,b)) = lcm(fibRank a, fibRank b) (left adjoint preserves joins),
  * the p-adic height corollary: p | F(n)  <=>  fibRank p | n.

No third-party dependencies. Run with:  python demo.py
"""

from __future__ import annotations

from math import gcd
from functools import lru_cache


# --------------------------------------------------------------------------- #
#  Core arithmetic
# --------------------------------------------------------------------------- #
@lru_cache(maxsize=None)
def fib(n: int) -> int:
    """The n-th Fibonacci number, F(0)=0, F(1)=1, F(n+2)=F(n)+F(n+1)."""
    if n < 2:
        return n
    a, b = 0, 1
    for _ in range(n - 1):
        a, b = b, a + b
    return b


def lcm(a: int, b: int) -> int:
    """Least common multiple (with lcm(0, x) = 0)."""
    if a == 0 or b == 0:
        return 0
    return a // gcd(a, b) * b


def fib_rank(m: int) -> int:
    """
    Rank of apparition of m: the least k > 0 with m | F(k).

    Computed by iterating the state pair (F(k), F(k+1)) mod m, which is the
    constructive content of the existence proof (finite-state periodicity of the
    shift T(a, b) = (b, a + b)).  Returns 0 for m = 0 (convention fibRank 0 = 0).
    """
    if m == 0:
        return 0
    a, b = 0 % m, 1 % m  # (F(0), F(1)) mod m
    k = 0
    while True:
        k += 1
        a, b = b, (a + b) % m
        if a == 0:  # a = F(k) mod m
            return k


def is_fibonacci(m: int) -> bool:
    """True iff m is a Fibonacci value F(k) for some k >= 0."""
    k = 0
    while fib(k) < m:
        k += 1
    return fib(k) == m


def closure(m: int) -> int:
    """The adjunction closure operator c(m) = F(fibRank m)."""
    return fib(fib_rank(m))


def padic_norm_lt_one(p: int, x: int) -> bool:
    """True iff the p-adic norm of x is < 1, i.e. p | x (for x != 0)."""
    return x != 0 and x % p == 0


# --------------------------------------------------------------------------- #
#  Demonstrations
# --------------------------------------------------------------------------- #
def demo_ranks() -> None:
    print("=" * 70)
    print("1. Ranks of apparition fibRank m  (least k>0 with m | F(k))")
    print("=" * 70)
    print(f"{'m':>3} | {'fibRank m':>9} | first Fibonacci multiple F(fibRank m)")
    print("-" * 70)
    for m in range(1, 16):
        r = fib_rank(m)
        print(f"{m:>3} | {r:>9} | F({r}) = {fib(r)}")
    print()


def demo_law_of_apparition() -> None:
    print("=" * 70)
    print("2. Law of Apparition:  m | F(n)  <=>  fibRank m | n")
    print("=" * 70)
    ok = True
    for m in range(1, 12):
        r = fib_rank(m)
        for n in range(0, 40):
            lhs = (fib(n) % m == 0)
            rhs = (n % r == 0)
            if lhs != rhs:
                ok = False
                print(f"  MISMATCH m={m}, n={n}: {lhs} vs {rhs}")
    print(f"  Verified for all m in 1..11, n in 0..39:  {'PASS' if ok else 'FAIL'}")
    print("  Example: does 4 | F(18)?  fibRank 4 =", fib_rank(4),
          "and 18 %", fib_rank(4), "=", 18 % fib_rank(4),
          "  =>", 18 % fib_rank(4) == 0, " (F(18) =", fib(18), ")")
    print()


def demo_closure_and_representation() -> None:
    print("=" * 70)
    print("3. Closure c(m) = F(fibRank m): extensive, idempotent;")
    print("   fixed points are EXACTLY the Fibonacci numbers")
    print("=" * 70)
    print(f"{'m':>3} | {'c(m)':>5} | {'m | c(m)?':>9} | {'c(c(m))':>7} | "
          f"{'fixed?':>6} | {'Fib?':>5}")
    print("-" * 70)
    rep_ok = True
    for m in range(1, 16):
        c = closure(m)
        cc = closure(c)
        extensive = (c % m == 0)
        idempotent = (cc == c)
        fixed = (c == m)
        isfib = is_fibonacci(m)
        if fixed != isfib:
            rep_ok = False
        assert extensive and idempotent
        print(f"{m:>3} | {c:>5} | {str(extensive):>9} | {cc:>7} | "
              f"{str(fixed):>6} | {str(isfib):>5}")
    print("-" * 70)
    print(f"  Representation theorem (fixed point  <=>  Fibonacci):  "
          f"{'PASS' if rep_ok else 'FAIL'}")
    print()


def demo_unification() -> None:
    print("=" * 70)
    print("4. Unification capstones (one adjunction fact, two faces)")
    print("=" * 70)
    print("   (a) right adjoint preserves meets:  F(gcd(a,b)) = gcd(F(a),F(b))")
    print("   (b) left  adjoint preserves joins:  fibRank(lcm) = lcm(fibRank,fibRank)")
    print("-" * 70)
    pairs = [(8, 12), (6, 9), (4, 6), (10, 15), (7, 14)]
    for a, b in pairs:
        lhs_g = fib(gcd(a, b))
        rhs_g = gcd(fib(a), fib(b))
        lhs_l = fib_rank(lcm(a, b))
        rhs_l = lcm(fib_rank(a), fib_rank(b))
        print(f"  a={a:>2}, b={b:>2}: "
              f"F(gcd)={lhs_g:<4}=gcd(F,F)={rhs_g:<4} [{lhs_g == rhs_g}]   "
              f"fibRank(lcm)={lhs_l:<3}=lcm(rk,rk)={rhs_l:<3} [{lhs_l == rhs_l}]")
    print()
    print("   Note the asymmetry: the left adjoint fibRank does NOT preserve meets.")
    a, b = 4, 6
    print(f"   a={a}, b={b}: fibRank(gcd)={fib_rank(gcd(a, b))}, "
          f"gcd(fibRank a, fibRank b)={gcd(fib_rank(a), fib_rank(b))}"
          f"  (divides, but strictly).")
    print()


def demo_padic() -> None:
    print("=" * 70)
    print("5. p-adic height corollary:  p | F(n)  <=>  fibRank p | n")
    print("=" * 70)
    for p in (2, 3, 5, 7, 11):
        r = fib_rank(p)
        small = [n for n in range(1, 30) if padic_norm_lt_one(p, fib(n))]
        predicted = [n for n in range(1, 30) if n % r == 0]
        status = "PASS" if small == predicted else "FAIL"
        print(f"  p={p:>2} (fibRank {p}={r}):  indices with p|F(n) = {small}  [{status}]")
    print()


def main() -> None:
    demo_ranks()
    demo_law_of_apparition()
    demo_closure_and_representation()
    demo_unification()
    demo_padic()
    print("All demonstrations complete.")


if __name__ == "__main__":
    main()
