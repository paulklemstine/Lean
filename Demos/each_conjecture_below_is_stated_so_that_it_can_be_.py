"""
The Pell Spine: numerical demonstrations
========================================

Self-contained numerical companion to the study of the integer sequences

    P: 0, 1, 2, 5, 12, 29, 70, 169, 408, ...      (Pell numbers)
    Q: 1, 1, 3, 7, 17, 41, 99, 239, 577, ...      (half-companion Pell numbers)

both governed by x_{n+2} = 2 x_{n+1} + x_n, and jointly encoding the powers of the
silver unit 1 + sqrt(2) via  (1 + sqrt 2)^n = Q(n) + P(n) sqrt(2).

Every claim printed below is a numerical instance of a theorem stated and proved in
the accompanying paper, or of one of the explicit counterexamples that refute the
tempting-but-false strengthenings of those theorems.

Run:  python3 demo.py
"""

from __future__ import annotations

from math import gcd, isqrt, lcm
from typing import Dict, Iterator, List, Optional, Tuple

# ----------------------------------------------------------------------------
# 1. The two strands of the spine
# ----------------------------------------------------------------------------


def pell_P(n: int) -> int:
    """Pell number P(n): P(0)=0, P(1)=1, P(n+2)=2P(n+1)+P(n)."""
    a, b = 0, 1
    for _ in range(n):
        a, b = b, 2 * b + a
    return a


def pell_Q(n: int) -> int:
    """Half-companion Pell number Q(n): Q(0)=Q(1)=1, Q(n+2)=2Q(n+1)+Q(n)."""
    a, b = 1, 1
    for _ in range(n):
        a, b = b, 2 * b + a
    return a


def pell_pair(n: int) -> Tuple[int, int]:
    """Return (Q(n), P(n)), i.e. the coordinates of (1+sqrt 2)^n in Z[sqrt 2]."""
    return pell_Q(n), pell_P(n)


def pell_P_mod(n: int, m: int) -> int:
    """P(n) mod m, computed without ever forming the (huge) integer P(n)."""
    if m == 1:
        return 0
    a, b = 0 % m, 1 % m
    for _ in range(n):
        a, b = b, (2 * b + a) % m
    return a


# ----------------------------------------------------------------------------
# 2. Rank of apparition
# ----------------------------------------------------------------------------


def pell_rank(m: int, bound: Optional[int] = None) -> int:
    """Rank of apparition of m: least n > 0 with m | P(n).

    The apparition theorem guarantees this exists for every m >= 1; the search is
    bounded a priori by m^2 (the number of states (P(n), P(n+1)) mod m).
    """
    if m <= 0:
        raise ValueError("modulus must be positive")
    if bound is None:
        bound = m * m + 1
    a, b = 0, 1 % m
    for n in range(1, bound + 1):
        a, b = b, (2 * b + a) % m
        if a == 0:
            return n
    raise RuntimeError(f"no rank found for m={m} below {bound}")


def pell_period(m: int) -> int:
    """Pisano-style period: least t > 0 with (P(t), P(t+1)) = (P(0), P(1)) mod m."""
    if m == 1:
        return 1
    a, b = 0, 1 % m
    for t in range(1, m * m + 2):
        a, b = b, (2 * b + a) % m
        if (a, b) == (0, 1 % m):
            return t
    raise RuntimeError("period not found")


# ----------------------------------------------------------------------------
# 3. Utility predicates
# ----------------------------------------------------------------------------


def is_prime(n: int) -> bool:
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


def is_square(n: int) -> bool:
    return n >= 0 and isqrt(n) ** 2 == n


def is_squarefree(n: int) -> bool:
    d = 2
    while d * d <= n:
        if n % (d * d) == 0:
            return False
        d += 1
    return n >= 1


def legendre_two(p: int) -> int:
    """The Legendre symbol (2/p) for an odd prime p: +1 iff p = +-1 mod 8."""
    return 1 if p % 8 in (1, 7) else -1


# ----------------------------------------------------------------------------
# 4. Demonstrations
# ----------------------------------------------------------------------------


def show_spine(n: int = 12) -> None:
    print("=" * 74)
    print("1. THE SPINE  (1 + sqrt2)^n = Q(n) + P(n) sqrt2")
    print("=" * 74)
    print(f"{'n':>3} {'P(n)':>12} {'Q(n)':>12} {'Q^2-2P^2':>10} {'Q/P':>18}")
    for k in range(n + 1):
        q, p = pell_pair(k)
        norm = q * q - 2 * p * p
        ratio = f"{q / p:.12f}" if p else "-"
        print(f"{k:>3} {p:>12} {q:>12} {norm:>10} {ratio:>18}")
    print("The norm column is exactly (-1)^n: every spine point is a unit of Z[sqrt2].")
    print("The ratios Q(n)/P(n) converge to sqrt2 = 1.41421356237..., alternating sides.")
    print()


def show_strong_divisibility(limit: int = 12) -> None:
    print("=" * 74)
    print("2. STRONG DIVISIBILITY:  gcd(P(m), P(n)) = P(gcd(m, n))")
    print("=" * 74)
    ok = True
    for m in range(limit + 1):
        for n in range(limit + 1):
            if gcd(pell_P(m), pell_P(n)) != pell_P(gcd(m, n)):
                ok = False
                print(f"  FAILURE at (m,n) = ({m},{n})")
    print(f"  checked all 0 <= m,n <= {limit}: {'holds everywhere' if ok else 'FAILED'}")
    print("  sample: gcd(P(12), P(18)) = gcd(13860, 470832) =",
          gcd(pell_P(12), pell_P(18)), "= P(6) =", pell_P(6))
    print()
    print("  The companion strand Q is NOT a strong divisibility sequence:")
    print(f"    3 | 6 but gcd(Q(3), Q(6)) = gcd({pell_Q(3)}, {pell_Q(6)}) ="
          f" {gcd(pell_Q(3), pell_Q(6))}, while Q(gcd(3,6)) = Q(3) = {pell_Q(3)}")
    print(f"    Q(2) = {pell_Q(2)} does not divide Q(4) = {pell_Q(4)} "
          f"(even index quotient)")
    print()


def show_companion_law(limit: int = 14) -> None:
    print("=" * 74)
    print("3. THE PARITY-GRADED COMPANION LAW")
    print("=" * 74)
    print("   For m >= 2:   Q(m) | Q(n)  <=>  n = m*k with k ODD.")
    ok = True
    for m in range(2, limit + 1):
        for n in range(0, 3 * limit + 1):
            lhs = pell_Q(n) % pell_Q(m) == 0
            rhs = (n % m == 0) and ((n // m) % 2 == 1)
            if lhs != rhs:
                ok = False
                print(f"  FAILURE at (m,n) = ({m},{n})")
    print(f"   checked 2 <= m <= {limit}, 0 <= n <= {3*limit}: "
          f"{'holds everywhere' if ok else 'FAILED'}")
    print()
    print("   gcd law:  gcd(Q(m), Q(n)) = Q(g) if m/g and n/g are both odd, else 1,")
    print("             where g = gcd(m, n).")
    ok = True
    for m in range(0, limit + 1):
        for n in range(0, limit + 1):
            g = gcd(m, n)
            if g == 0:
                expected = pell_Q(0)
            else:
                both_odd = ((m // g) % 2 == 1) and ((n // g) % 2 == 1)
                expected = pell_Q(g) if both_odd else 1
            if gcd(pell_Q(m), pell_Q(n)) != expected:
                ok = False
                print(f"  FAILURE at (m,n) = ({m},{n})")
    print(f"   checked all 0 <= m,n <= {limit}: "
          f"{'holds everywhere' if ok else 'FAILED'}")
    print(f"   sample: gcd(Q(3), Q(9)) = gcd({pell_Q(3)}, {pell_Q(9)}) ="
          f" {gcd(pell_Q(3), pell_Q(9))} = Q(3)   (quotient 3 is odd)")
    print(f"           gcd(Q(3), Q(6)) = {gcd(pell_Q(3), pell_Q(6))}"
          f"                       (quotient 2 is even)")
    print()


def show_apparition(limit: int = 24) -> None:
    print("=" * 74)
    print("4. RANK OF APPARITION:  m | P(n)  <=>  rank(m) | n")
    print("=" * 74)
    print(f"{'m':>4} {'rank(m)':>8} {'P(rank)':>18}   divisibility law verified")
    for m in range(1, limit + 1):
        r = pell_rank(m)
        law_ok = all((pell_P_mod(n, m) == 0) == (n % r == 0) for n in range(0, 6 * r))
        print(f"{m:>4} {r:>8} {pell_P(r):>18}   {'yes' if law_ok else 'NO'}")
    print()
    print("   Multiplicativity on coprime moduli: rank(a*b) = lcm(rank a, rank b).")
    for a, b in [(3, 5), (5, 7), (8, 9), (7, 13), (11, 13)]:
        if gcd(a, b) == 1:
            print(f"     rank({a}*{b}) = rank({a*b}) = {pell_rank(a*b)}"
                  f"   lcm({pell_rank(a)}, {pell_rank(b)}) ="
                  f" {lcm(pell_rank(a), pell_rank(b))}")
    print()


def show_fermat_law(bound: int = 60) -> None:
    print("=" * 74)
    print("5. THE FERMAT LAW:  p | P(p-1) * P(p+1)  for every odd prime p")
    print("=" * 74)
    print(f"{'p':>5} {'p mod 8':>8} {'(2/p)':>6} {'rank(p)':>8} {'divides':>12}"
          f"  {'P(p) = 2^((p-1)/2) mod p':>26}")
    for p in range(3, bound + 1):
        if not is_prime(p):
            continue
        r = pell_rank(p)
        side = "p-1" if (p - 1) % r == 0 else ("p+1" if (p + 1) % r == 0 else "NEITHER")
        euler_ok = pell_P_mod(p, p) == pow(2, (p - 1) // 2, p)
        print(f"{p:>5} {p % 8:>8} {legendre_two(p):>6} {r:>8} {side:>12}"
              f"  {'confirmed' if euler_ok else 'FAILED':>26}")
    print()
    print("   The side is predicted by the Legendre symbol (2/p): rank divides p - (2/p).")
    print("   Naive guess 'rank(p) | p-1' dies at p = 3, where rank(3) = 4 and 4 does")
    print("   not divide 2 -- but 4 does divide p+1 = 4, exactly as the law demands.")
    print()


def show_wall_sun_sun(bound: int = 4000) -> None:
    print("=" * 74)
    print("6. PELL-WALL-SUN-SUN PRIMES:  p^2 | P(rank(p))")
    print("=" * 74)
    hits: List[int] = []
    for p in range(3, bound + 1):
        if not is_prime(p):
            continue
        r = pell_rank(p)
        if pell_P_mod(r, p * p) == 0:
            hits.append(p)
            print(f"   p = {p:>5}: rank(p) = rank(p^2) = {r},  P({r}) = {pell_P(r)}")
    print(f"   Pell-Wall-Sun-Sun primes below {bound}: {hits}")
    print("   Consequently the Wall-Sun-Sun growth law rank(p^2) = p * rank(p) is FALSE:")
    print(f"     rank(13)  = {pell_rank(13)},  rank(169) = {pell_rank(169)}"
          f"   (P(7) = {pell_P(7)} = 13^2)")
    print(f"     rank(31)  = {pell_rank(31)},  rank(961) = {pell_rank(961)}"
          f"   (31^2 | P(30) = {pell_P(30)})")
    print("   For Fibonacci numbers no analogous prime is known at all.")
    print()


def show_p7_singularity() -> None:
    print("=" * 74)
    print("7. P(7) = 169: A SINGLE POINT OF FAILURE")
    print("=" * 74)
    p7 = pell_P(7)
    print(f"   P(7) = {p7} = 13^2, at the prime index 7.")
    print(f"     prime index => prime value?  {is_prime(p7)}  (refuted)")
    print(f"     Pell numbers squarefree?     {is_squarefree(p7)}  (refuted)")
    print(f"     no Pell number a square?     {not is_square(p7)}  (refuted)")
    print(f"     near-isosceles hypotenuse prime?  119^2 + 120^2 = {119**2 + 120**2}"
          f" = {p7}^1, and {p7} = 13^2  (refuted)")
    print(f"     13 a Pell-Wall-Sun-Sun prime?  {pell_rank(169) == pell_rank(13)}"
          f"  (yes -- same term)")
    print()


def show_near_isosceles(count: int = 7) -> None:
    print("=" * 74)
    print("8. NEAR-ISOSCELES PYTHAGOREAN TRIPLES  a^2 + (a+1)^2 = c^2")
    print("=" * 74)
    print(f"{'k':>3} {'a':>12} {'a+1':>12} {'c = P(2k+1)':>14} {'c mod 4':>8}")
    for k in range(count):
        idx = 2 * k + 1
        q, c = pell_pair(idx)
        a = (q - 1) // 2
        assert a * a + (a + 1) ** 2 == c * c
        print(f"{k:>3} {a:>12} {a+1:>12} {c:>14} {c % 4:>8}")
    print("   Every such triple arises this way, and every hypotenuse is 1 mod 4.")
    print("   The k = 3 row is (119, 120, 169) -- the hypotenuse 169 = 13^2 is composite.")
    print()


def show_unit_classification(bound: int = 200) -> None:
    print("=" * 74)
    print("9. CLASSIFICATION OF x^2 - 2y^2 = +-1")
    print("=" * 74)
    spine = {(pell_Q(n), pell_P(n)) for n in range(0, 12)}
    found: List[Tuple[int, int, int]] = []
    for x in range(0, bound + 1):
        for y in range(0, bound + 1):
            d = x * x - 2 * y * y
            if d in (1, -1):
                found.append((x, y, d))
    on_spine = all((x, y) in spine for x, y, _ in found)
    print(f"   brute-force solutions with 0 <= x,y <= {bound}: {[(x, y) for x, y, _ in found]}")
    print(f"   all lie on the spine: {on_spine}")
    print("   sign of the norm = parity of the index: +1 for even n, -1 for odd n.")
    print(f"   x^2 = 2y^2 + 3 has no solution at all (obstruction mod 8):"
          f" {not any((x*x - 2*y*y) == 3 for x in range(bound) for y in range(bound))}")
    print(f"   but x^2 - 2y^2 = 7 does have one: 3^2 - 2*1^2 = {3*3 - 2*1}")
    print()


def show_approximation(n: int = 14) -> None:
    print("=" * 74)
    print("10. APPROXIMATION OF sqrt2:  |Q(n) - P(n) sqrt2| = (sqrt2 - 1)^n")
    print("=" * 74)
    from decimal import Decimal, getcontext

    getcontext().prec = 50
    root2 = Decimal(2).sqrt()
    print(f"{'n':>3} {'|Q - P sqrt2|':>22} {'(sqrt2-1)^n':>22} {'|sqrt2 - Q/P| * P^2':>22}")
    for k in range(1, n + 1):
        q, p = pell_pair(k)
        err = abs(Decimal(q) - Decimal(p) * root2)
        geo = (root2 - 1) ** k
        scaled = abs(root2 - Decimal(q) / Decimal(p)) * Decimal(p) ** 2
        print(f"{k:>3} {str(err)[:22]:>22} {str(geo)[:22]:>22} {str(scaled)[:22]:>22}")
    print("   The last column is < 1 for every n >= 1 (Dirichlet quality),")
    print("   but at n = 1 it equals 0.414... > 1/3, so the constant 1 is not")
    print("   improvable to 1/3 on the whole spine.")
    print()


def show_identities(n: int = 15) -> None:
    print("=" * 74)
    print("11. IDENTITIES TYING THE TWO STRANDS TOGETHER")
    print("=" * 74)
    ok_sum_q = all(sum(pell_Q(i) for i in range(k + 1)) == pell_P(k + 1)
                   for k in range(n))
    ok_sum_p = all(2 * sum(pell_P(i) for i in range(k + 1)) + 1
                   == pell_P(k + 1) + pell_P(k) for k in range(n))
    ok_sum_sq = all(2 * sum(pell_P(i) ** 2 for i in range(k + 1))
                    == pell_P(k) * pell_P(k + 1) for k in range(n))
    ok_cassini = all(pell_P(k + 2) * pell_P(k) - pell_P(k + 1) ** 2 == (-1) ** (k + 1)
                     for k in range(n))
    print(f"   sum_{{i<=n}} Q(i) = P(n+1)                        : {ok_sum_q}")
    print(f"   2 sum_{{i<=n}} P(i) + 1 = P(n+1) + P(n)           : {ok_sum_p}")
    print(f"   2 sum_{{i<=n}} P(i)^2 = P(n) P(n+1)               : {ok_sum_sq}")
    print(f"   Cassini: P(n+2)P(n) - P(n+1)^2 = (-1)^(n+1)     : {ok_cassini}")
    print()


def rank_table(bound: int = 40) -> Dict[int, int]:
    return {m: pell_rank(m) for m in range(1, bound + 1)}


def main() -> None:
    show_spine()
    show_strong_divisibility()
    show_companion_law()
    show_apparition()
    show_fermat_law()
    show_wall_sun_sun()
    show_p7_singularity()
    show_near_isosceles()
    show_unit_classification()
    show_approximation()
    show_identities()
    print("=" * 74)
    print("All demonstrations completed.")
    print("=" * 74)


if __name__ == "__main__":
    main()
