"""
The Converse Cost Curve: numerical demonstrations.

Self-contained numerical verification of every theorem in the accompanying
paper on the cost-information plane of factor-revealing witnesses of
semiprimes N = p*q.

Contents
--------
1. gcd-sum closed form                M1(pq) + 2(p+q) = 4pq + 1
2. class-wide gcd-statistic formula   S_f(pq) = f(pq)+(q-1)f(p)+(p-1)f(q)+(p-1)(q-1)f(1)
3. totient equivalence                M1(N) + 1 = 2*phi(N) + 2N
4. reach chain                        (N, M1) -> s -> {p, q}
5. zero-divisor scan                  first hit = min(p,q); hits = p+q-1; misses = phi(N)
6. idempotent ladder                  #{x : x^2 = x mod N} = 2^omega(N)
7. square-root ladder                 #{x : x^2 = 1 mod N} = 2^omega(N) for odd N
   (and its failure at N = 8)
8. reveal lemmas                      nontrivial witness -> gcd -> prime factor
9. no-polylog-route table             route costs vs (log2 N)^d
10. black-box blindness               two semiprimes, identical all-ones transcript

Run:  python3 demo.py
"""

from __future__ import annotations

from math import gcd, isqrt
from typing import Callable, Dict, List, Tuple


# ----------------------------------------------------------------------
# elementary number theory helpers (all inlined, no external dependencies)
# ----------------------------------------------------------------------

def is_prime(n: int) -> bool:
    """Deterministic trial-division primality test (sufficient for demo sizes)."""
    if n < 2:
        return False
    if n % 2 == 0:
        return n == 2
    f = 3
    while f * f <= n:
        if n % f == 0:
            return False
        f += 2
    return True


def next_prime(n: int) -> int:
    """Least prime strictly greater than n."""
    c = n + 1
    while not is_prime(c):
        c += 1
    return c


def prime_factors(n: int) -> List[int]:
    """Sorted list of the distinct prime factors of n >= 1."""
    out: List[int] = []
    m, f = n, 2
    while f * f <= m:
        if m % f == 0:
            out.append(f)
            while m % f == 0:
                m //= f
        f += 1 if f == 2 else 2
    if m > 1:
        out.append(m)
    return out


def omega(n: int) -> int:
    """Number of distinct prime factors of n."""
    return len(prime_factors(n))


def totient(n: int) -> int:
    """Euler's totient, by the product formula over distinct primes."""
    result = n
    for p in prime_factors(n):
        result = result // p * (p - 1)
    return result


# ----------------------------------------------------------------------
# 1-4.  The gcd-sum witness W1
# ----------------------------------------------------------------------

def pillai(n: int) -> int:
    """W1: the gcd-sum M1(N) = sum_{x<N} gcd(x, N), by its Theta(N) definition route."""
    return sum(gcd(x, n) for x in range(n))


def pillai_closed_form(p: int, q: int) -> int:
    """Closed form 4pq - 2(p+q) + 1 for distinct primes p, q."""
    return 4 * p * q - 2 * (p + q) + 1


def gcd_stat(f: Callable[[int], int], n: int) -> int:
    """General local gcd-statistic S_f(N) = sum_{x<N} f(gcd(x,N))."""
    return sum(f(gcd(x, n)) for x in range(n))


def gcd_stat_closed_form(f: Callable[[int], int], p: int, q: int) -> int:
    """Four-cell closed form f(pq) + (q-1)f(p) + (p-1)f(q) + (p-1)(q-1)f(1)."""
    return f(p * q) + (q - 1) * f(p) + (p - 1) * f(q) + (p - 1) * (q - 1) * f(1)


def recover_pair_from_pillai(n: int, m1: int) -> Tuple[int, int]:
    """Reach chain: (N, M1) -> s = (4N+1-M1)/2 -> {p,q} by the symmetric-function step."""
    s = (4 * n + 1 - m1) // 2
    disc = s * s - 4 * n
    t = isqrt(disc)
    assert t * t == disc, "s^2 - 4N is not a perfect square"
    return ((s - t) // 2, (s + t) // 2)


# ----------------------------------------------------------------------
# 5.  The zero-divisor scan W2
# ----------------------------------------------------------------------

def zero_divisor_scan(n: int) -> Tuple[int, int]:
    """Walk x = 1,2,3,... and stop at the first hit. Returns (first hit, #iterations)."""
    x = 1
    while gcd(x, n) == 1:
        x += 1
    return x, x


def hits(n: int) -> List[int]:
    """Residues below N sharing a factor with N."""
    return [x for x in range(n) if gcd(x, n) > 1]


def misses(n: int) -> List[int]:
    """Residues below N coprime to N: the wasted probes."""
    return [x for x in range(n) if gcd(x, n) == 1]


# ----------------------------------------------------------------------
# 6-8.  The two counting ladders and the reveal lemmas
# ----------------------------------------------------------------------

def idempotents(n: int) -> List[int]:
    """Solutions of x^2 = x mod N, including the trivial idempotent x = 0."""
    return [x for x in range(n) if (x * x) % n == x % n]


def sqrt_one(n: int) -> List[int]:
    """Solutions of x^2 = 1 mod N."""
    return [x for x in range(n) if (x * x) % n == 1 % n]


def reveal_from_idempotent(n: int, x: int) -> Tuple[int, int]:
    """A nontrivial idempotent x yields gcd(x, N) in {p, q} and its cofactor."""
    g = gcd(x, n)
    return g, n // g


def reveal_from_square_congruence(n: int, x: int, y: int) -> Tuple[int, int]:
    """x^2 = y^2 mod N with x != +-y yields gcd(x-y, N) in {p, q} and its cofactor."""
    g = gcd(abs(x - y), n)
    return g, n // g


# ----------------------------------------------------------------------
# 10.  The black-box gcd-probe model
# ----------------------------------------------------------------------

Strategy = Callable[[List[int]], int]


def transcript(strategy: Strategy, n: int, budget: int) -> List[int]:
    """The answer transcript of an adaptive gcd-probe strategy on hidden modulus N."""
    tr: List[int] = []
    for _ in range(budget):
        tr = tr + [gcd(strategy(tr), n)]
    return tr


def null_probes(strategy: Strategy, budget: int) -> List[int]:
    """The probes the strategy would make if every answer were 1."""
    return [strategy([1] * k) for k in range(budget)]


def blind_pair(strategy: Strategy, budget: int) -> Tuple[int, int, int, int]:
    """Two semiprimes with disjoint factorisations on which the strategy is blind."""
    bound = max(null_probes(strategy, budget))
    p1 = next_prime(bound)
    q1 = next_prime(p1)
    p2 = next_prime(q1)
    q2 = next_prime(p2)
    return p1, q1, p2, q2


# ----------------------------------------------------------------------
# demonstrations
# ----------------------------------------------------------------------

def banner(title: str) -> None:
    print()
    print("=" * 72)
    print(title)
    print("=" * 72)


def demo_gcd_sum() -> None:
    banner("1. The gcd-sum closed form:  M1(pq) + 2(p+q) = 4pq + 1")
    print(f"{'N':>7} {'p':>4} {'q':>4} {'M1 (scan)':>11} {'closed form':>12} {'ok':>4}")
    for p, q in [(3, 5), (5, 7), (11, 13), (13, 17), (23, 29), (31, 37)]:
        n = p * q
        scanned = pillai(n)
        closed = pillai_closed_form(p, q)
        print(f"{n:7d} {p:4d} {q:4d} {scanned:11d} {closed:12d} "
              f"{'OK' if scanned == closed else 'FAIL':>4}")
        assert scanned == closed
        assert scanned + 2 * (p + q) == 4 * n + 1


def demo_class_formula() -> None:
    banner("2. Every local gcd-statistic: the four-cell formula")
    summands: Dict[str, Callable[[int], int]] = {
        "f = 1 (blind)": lambda d: 1,
        "f = id (W1)": lambda d: d,
        "f = d^2": lambda d: d * d,
        "f = [d > 1]": lambda d: 1 if d > 1 else 0,
        "f = d^3 - 2d": lambda d: d ** 3 - 2 * d,
    }
    for p, q in [(5, 7), (11, 13)]:
        n = p * q
        print(f"\n  N = {n} = {p}*{q}")
        for name, f in summands.items():
            direct = gcd_stat(f, n)
            closed = gcd_stat_closed_form(f, p, q)
            print(f"    {name:16s}  scan = {direct:10d}   closed = {closed:10d}   "
                  f"{'OK' if direct == closed else 'FAIL'}")
            assert direct == closed
        print(f"    information-free member f=1 returns N itself: "
              f"{gcd_stat(lambda d: 1, n)} == {n}")


def demo_totient_bridge() -> None:
    banner("3. Affine equivalence with Euler's totient:  M1(N) + 1 = 2*phi(N) + 2N")
    for p, q in [(3, 5), (5, 7), (11, 13), (17, 19)]:
        n = p * q
        lhs = pillai(n) + 1
        rhs = 2 * totient(n) + 2 * n
        print(f"  N = {n:5d}:  M1+1 = {lhs:6d}   2*phi+2N = {rhs:6d}   "
              f"{'OK' if lhs == rhs else 'FAIL'}")
        assert lhs == rhs


def demo_reach_chain() -> None:
    banner("4. The reach chain:  (N, M1) -> s = p+q -> {p, q}")
    for p, q in [(3, 5), (11, 13), (29, 31), (101, 103)]:
        n = p * q
        m1 = pillai_closed_form(p, q)   # value the Theta(N) scan would return
        s = (4 * n + 1 - m1) // 2
        rec = recover_pair_from_pillai(n, m1)
        print(f"  N = {n:6d}:  M1 = {m1:7d}  ->  s = {s:5d}  ->  {{p,q}} = {rec}   "
              f"{'OK' if rec == (p, q) else 'FAIL'}")
        assert rec == (p, q)


def demo_scan_costs() -> None:
    banner("5. The zero-divisor scan: exact cost, hit count, miss count")
    print(f"{'N':>8} {'min(p,q)':>9} {'first hit':>10} {'#hits':>7} {'p+q-1':>7} "
          f"{'#misses':>8} {'phi(N)':>8}")
    for p, q in [(3, 5), (5, 7), (11, 13), (13, 17), (23, 29), (41, 43)]:
        n = p * q
        first, _ = zero_divisor_scan(n)
        h, m = len(hits(n)), len(misses(n))
        print(f"{n:8d} {min(p, q):9d} {first:10d} {h:7d} {p + q - 1:7d} "
              f"{m:8d} {totient(n):8d}")
        assert first == min(p, q)
        assert h == p + q - 1
        assert m == totient(n)
    print("\n  Random probing pays the same wall: #hits * min(p,q) <= 2N")
    for p, q in [(11, 13), (23, 29), (41, 43)]:
        n = p * q
        lhs = len(hits(n)) * min(p, q)
        print(f"    N = {n:5d}:  {lhs:7d} <= {2 * n:7d}   "
              f"hit density <= {2 / min(p, q):.4f}")
        assert lhs <= 2 * n
    print("\n  The sqrt(N) wall for balanced semiprimes:  sqrt(N/2) <= cost <= sqrt(N)")
    for p, q in [(11, 13), (23, 29), (41, 43), (101, 103)]:
        n = p * q
        assert n <= 2 * min(p, q) ** 2 and min(p, q) ** 2 <= n
        print(f"    N = {n:6d}:  cost = {min(p, q):4d},  "
              f"sqrt(N/2) = {(n / 2) ** 0.5:8.2f},  sqrt(N) = {n ** 0.5:8.2f}")


def demo_idempotent_ladder() -> None:
    banner("6. The idempotent ladder:  #{x : x^2 = x mod N} = 2^omega(N)")
    print(f"{'N':>6} {'factorisation':>18} {'omega':>6} {'#idem':>6} {'2^omega':>8} "
          f"{'idempotents':>28}")
    for n in [9, 15, 35, 45, 49, 105, 143, 231]:
        idem = idempotents(n)
        w = omega(n)
        shown = str(idem) if len(idem) <= 8 else str(idem[:8]) + "..."
        print(f"{n:6d} {'*'.join(map(str, prime_factors(n))):>18} {w:6d} "
              f"{len(idem):6d} {2 ** w:8d} {shown:>28}")
        assert len(idem) == 2 ** w
    print("\n  Consequence: on semiprimes the counter is the constant 4 --")
    print("  a Theta(N) scan whose output carries zero factorisation information.")


def demo_sqrt_ladder() -> None:
    banner("7. The square-root ladder:  #{x : x^2 = 1 mod N} = 2^omega(N) for odd N")
    print(f"{'N':>6} {'odd':>5} {'omega':>6} {'#roots':>7} {'2^omega':>8} {'roots':>26}")
    for n in [9, 15, 35, 45, 105, 143, 231]:
        roots = sqrt_one(n)
        w = omega(n)
        shown = str(roots) if len(roots) <= 6 else str(roots[:6]) + "..."
        print(f"{n:6d} {'yes':>5} {w:6d} {len(roots):7d} {2 ** w:8d} {shown:>26}")
        assert len(roots) == 2 ** w
    print("\n  The oddness hypothesis is necessary -- the ladder breaks at the prime 2:")
    for n in [8, 16, 24]:
        roots = sqrt_one(n)
        print(f"    N = {n:3d}:  omega = {omega(n)},  2^omega = {2 ** omega(n)},  "
              f"but #roots = {len(roots)}  {roots}")
    assert len(sqrt_one(8)) == 4 and omega(8) == 1


def demo_reveal() -> None:
    banner("8. Reveal lemmas: one nontrivial witness, one gcd, one prime factor")
    for p, q in [(3, 5), (5, 7), (11, 13), (23, 29)]:
        n = p * q
        print(f"\n  N = {n} = {p}*{q}")
        for x in idempotents(n):
            if x in (0, 1):
                continue
            g, cof = reveal_from_idempotent(n, x)
            print(f"    idempotent x = {x:5d}:  gcd(x,N) = {g:4d}, cofactor = {cof:4d}"
                  f"   {'OK' if {g, cof} == {p, q} else 'FAIL'}")
            assert {g, cof} == {p, q}
        for x in sqrt_one(n):
            if x in (1, n - 1):
                continue
            g, cof = reveal_from_square_congruence(n, x, 1)
            print(f"    sqrt of unity x = {x:5d}: gcd(x-1,N) = {g:4d}, "
                  f"cofactor = {cof:4d}   {'OK' if {g, cof} == {p, q} else 'FAIL'}")
            assert {g, cof} == {p, q}


def demo_no_polylog() -> None:
    banner("9. No polylogarithmic route anywhere: costs vs (log2 N)^d")
    degrees = [1, 2, 3]
    print(f"{'N':>14} {'bits':>5} {'cheapest cost':>14} "
          + " ".join(f"{'(log2 N)^' + str(d):>14}" for d in degrees))
    p = 1000003
    for _ in range(5):
        p = next_prime(p)
        q = next_prime(p)
        n = p * q
        k = n.bit_length() - 1
        cheapest = min(p, q)
        row = " ".join(f"{k ** d:14d}" for d in degrees)
        print(f"{n:14d} {k + 1:5d} {cheapest:14d} {row}")
        for d in degrees:
            assert k ** d < cheapest
        p = q
    print("\n  For each fixed degree d the cheapest route cost min(p,q) ~ sqrt(N)")
    print("  outruns (log2 N)^d beyond an explicit threshold: no route is poly(log N).")


def demo_black_box() -> None:
    banner("10. The black-box converse: two semiprimes, one identical transcript")

    def naive_scan(answers: List[int]) -> int:
        """The naive increasing scan: the n-th probe is n+1, ignoring the answers."""
        return len(answers) + 1

    def adaptive_jumper(answers: List[int]) -> int:
        """An adaptive strategy: jump by the last answer, squared, plus a stride."""
        last = answers[-1] if answers else 1
        return 3 * len(answers) + last * last + 1

    for name, strategy in [("naive increasing scan", naive_scan),
                           ("adaptive jumper", adaptive_jumper)]:
        budget = 12
        p1, q1, p2, q2 = blind_pair(strategy, budget)
        n1, n2 = p1 * q1, p2 * q2
        t1 = transcript(strategy, n1, budget)
        t2 = transcript(strategy, n2, budget)
        print(f"\n  strategy: {name}, budget T = {budget}")
        print(f"    probes of the null run : {null_probes(strategy, budget)}")
        print(f"    N1 = {n1} = {p1}*{q1}   transcript = {t1}")
        print(f"    N2 = {n2} = {p2}*{q2}   transcript = {t2}")
        print(f"    identical all-ones transcripts: "
              f"{'YES' if t1 == t2 == [1] * budget else 'NO'}")
        print(f"    factorisations disjoint: "
              f"{'YES' if {p1, q1}.isdisjoint({p2, q2}) else 'NO'}")
        assert t1 == t2 == [1] * budget
        assert {p1, q1}.isdisjoint({p2, q2})
    print("\n  Any output rule reading only the transcript returns the same pair on")
    print("  both instances, so at least one of them is answered incorrectly.")


def main() -> None:
    print("THE CONVERSE COST CURVE -- numerical demonstrations")
    print("Semiprimes N = p*q: what each factor-revealing witness costs, "
          "and what it knows.")
    demo_gcd_sum()
    demo_class_formula()
    demo_totient_bridge()
    demo_reach_chain()
    demo_scan_costs()
    demo_idempotent_ladder()
    demo_sqrt_ladder()
    demo_reveal()
    demo_no_polylog()
    demo_black_box()
    banner("All demonstrations completed; every assertion held.")


if __name__ == "__main__":
    main()
