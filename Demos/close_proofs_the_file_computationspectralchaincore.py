"""
demo.py — Numerical demonstrations for the theory of Strong Divisibility Sequences.

A sequence u : N -> N is a *strong divisibility sequence* (SDS) when

        u(gcd(m, n)) = gcd(u(m), u(n))     for all m, n.

This single identity is the engine behind the entire elementary theory of primitive
divisors and apparition. This script empirically verifies, for the two canonical
instances --- the Fibonacci numbers and the Mersenne-type numbers a^n - 1 --- every
result of the accompanying paper:

  * the strong divisibility identity itself,
  * the weak divisibility law           m | n  =>  u(m) | u(n),
  * the meet law                        d | u(gcd m n)  <=>  d | u(m) and d | u(n),
  * uniqueness of the apparition index,
  * the law of apparition               p | u(m)  <=>  rank | m,
  * the join law (lcm of two ranks),
  * exact apparition counts             #{e < N : p | u(e+1)} = floor(N / rank).

Everything is self-contained: only the Python standard library is used.
"""

from __future__ import annotations

from math import gcd
from typing import Callable, List, Optional, Tuple


# --------------------------------------------------------------------------- #
# Sequence constructors                                                       #
# --------------------------------------------------------------------------- #
def fib(n: int) -> int:
    """The n-th Fibonacci number, F(0) = 0, F(1) = 1, F(n+2) = F(n+1) + F(n)."""
    a, b = 0, 1
    for _ in range(n):
        a, b = b, a + b
    return a


def mersenne_like(a: int) -> Callable[[int], int]:
    """Return the strong divisibility sequence u(n) = a**n - 1 for a fixed base a."""
    def u(n: int) -> int:
        return a ** n - 1
    return u


def lcm(x: int, y: int) -> int:
    """Least common multiple, with lcm(0, y) = 0."""
    if x == 0 or y == 0:
        return 0
    return x // gcd(x, y) * y


# --------------------------------------------------------------------------- #
# Core theory                                                                 #
# --------------------------------------------------------------------------- #
def is_strong_divisibility_sequence(u: Callable[[int], int], bound: int) -> bool:
    """Check u(gcd(m, n)) == gcd(u(m), u(n)) for all 0 <= m, n <= bound."""
    for m in range(bound + 1):
        for n in range(bound + 1):
            if u(gcd(m, n)) != gcd(u(m), u(n)):
                return False
    return True


def apparition_rank(u: Callable[[int], int], p: int, search: int = 2000) -> Optional[int]:
    """Least n > 0 with p | u(n) (the rank of apparition / first appearance), or None."""
    if p == 0:
        return None
    for n in range(1, search + 1):
        if u(n) % p == 0:
            return n
    return None


def is_primitive(u: Callable[[int], int], p: int, n: int) -> bool:
    """p is a primitive divisor of u(n): p | u(n) and p divides no u(k), 0 < k < n."""
    if u(n) % p != 0:
        return False
    return all(u(k) % p != 0 for k in range(1, n))


def apparition_count(u: Callable[[int], int], p: int, big_n: int) -> int:
    """Count e in {0,...,big_n-1} with p | u(e+1)."""
    return sum(1 for e in range(big_n) if u(e + 1) % p == 0)


def joint_apparition_count(
    u: Callable[[int], int], p: int, q: int, big_n: int
) -> int:
    """Count e in {0,...,big_n-1} with p | u(e+1) and q | u(e+1)."""
    return sum(1 for e in range(big_n) if u(e + 1) % p == 0 and u(e + 1) % q == 0)


# --------------------------------------------------------------------------- #
# Demonstrations                                                              #
# --------------------------------------------------------------------------- #
def demo_strong_divisibility(u: Callable[[int], int], name: str, bound: int = 25) -> None:
    ok = is_strong_divisibility_sequence(u, bound)
    print(f"[{name}] strong divisibility identity holds for 0<=m,n<={bound}: {ok}")


def demo_weak_divisibility(u: Callable[[int], int], name: str, bound: int = 20) -> None:
    failures: List[Tuple[int, int]] = []
    for m in range(1, bound + 1):
        for n in range(m, bound + 1):
            if n % m == 0 and u(n) % u(m) != 0:
                failures.append((m, n))
    print(f"[{name}] weak law (m|n => u(m)|u(n)) holds up to {bound}: {not failures}")


def demo_meet_law(u: Callable[[int], int], name: str, bound: int = 15) -> None:
    ok = True
    for d in range(1, 30):
        for m in range(1, bound + 1):
            for n in range(1, bound + 1):
                lhs = (u(gcd(m, n)) % d == 0)
                rhs = (u(m) % d == 0) and (u(n) % d == 0)
                if lhs != rhs:
                    ok = False
    print(f"[{name}] meet law (d|u(gcd) <=> d|u(m) & d|u(n)): {ok}")


def demo_law_of_apparition(
    u: Callable[[int], int], name: str, primes: List[int], bound: int = 60
) -> None:
    print(f"[{name}] law of apparition  p | u(m) <=> rank(p) | m :")
    for p in primes:
        r = apparition_rank(u, p)
        if r is None:
            print(f"    p={p:>3}: no apparition found")
            continue
        prim = is_primitive(u, p, r)
        ok = all((u(m) % p == 0) == (m % r == 0) for m in range(1, bound + 1))
        print(f"    p={p:>3}: rank={r:>3}  primitive={prim}  law holds up to {bound}: {ok}")


def demo_join_law(
    u: Callable[[int], int], name: str, p: int, q: int, bound: int = 80
) -> None:
    rp = apparition_rank(u, p)
    rq = apparition_rank(u, q)
    if rp is None or rq is None:
        print(f"[{name}] join law: missing rank for p={p} or q={q}")
        return
    L = lcm(rp, rq)
    ok = all(
        ((u(n) % p == 0) and (u(n) % q == 0)) == (n % L == 0)
        for n in range(1, bound + 1)
    )
    print(
        f"[{name}] join law for p={p} (rank {rp}), q={q} (rank {rq}): "
        f"joint period = lcm = {L}, verified up to {bound}: {ok}"
    )


def demo_counting(
    u: Callable[[int], int], name: str, p: int, q: int, big_n: int = 90
) -> None:
    rp = apparition_rank(u, p)
    rq = apparition_rank(u, q)
    assert rp is not None and rq is not None
    single = apparition_count(u, p, big_n)
    pred_single = big_n // rp
    joint = joint_apparition_count(u, p, q, big_n)
    pred_joint = big_n // lcm(rp, rq)
    print(
        f"[{name}] counting up to N={big_n}: "
        f"#{{p|u(e+1)}}={single} (predicted {pred_single}); "
        f"joint={joint} (predicted {pred_joint})"
    )


def main() -> None:
    print("=" * 72)
    print("STRONG DIVISIBILITY SEQUENCES — numerical demonstrations")
    print("=" * 72)

    print("\n--- Instance 1: Fibonacci numbers F(n) ---")
    demo_strong_divisibility(fib, "Fib")
    demo_weak_divisibility(fib, "Fib")
    demo_meet_law(fib, "Fib")
    demo_law_of_apparition(fib, "Fib", primes=[2, 3, 5, 7, 11, 13])
    demo_join_law(fib, "Fib", p=2, q=5)        # ranks 3 and 5, lcm 15
    demo_counting(fib, "Fib", p=2, q=5, big_n=90)

    print("\n--- Instance 2: Mersenne-type numbers u(n) = 2^n - 1 ---")
    u2 = mersenne_like(2)
    demo_strong_divisibility(u2, "2^n-1")
    demo_weak_divisibility(u2, "2^n-1")
    demo_meet_law(u2, "2^n-1")
    demo_law_of_apparition(u2, "2^n-1", primes=[3, 5, 7, 11, 13, 31])
    demo_join_law(u2, "2^n-1", p=7, q=5)        # ranks 3 and 4, lcm 12
    demo_counting(u2, "2^n-1", p=7, q=5, big_n=84)

    print("\n--- Uniqueness of the apparition index (Theorem 4.2) ---")
    p = 2
    r = apparition_rank(fib, p)
    others = [n for n in range(1, 40) if is_primitive(fib, p, n)]
    print(f"[Fib] p={p}: indices n with Prim(F; {p}, n) in 1..39 = {others} (rank={r})")

    print("\nAll demonstrations complete.")


if __name__ == "__main__":
    main()
