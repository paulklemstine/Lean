#!/usr/bin/env python3
"""
Power-Sum GCD Factor Revelation and Carmichael Periodicity
==========================================================

Numerical demonstration of the complete structure theory for the arithmetic
function

        F_N(k) = sum_{a=1}^{N} a^k ,      g_N(k) = gcd(F_N(k), N).

The results demonstrated here:

  (1) Master formula.  For N = p*q with p != q prime and k >= 1,
          g_N(k) = (1 if (p-1)|k else p) * (1 if (q-1)|k else q).

  (2) Unconditional factor reveal.  For p < q, g_N(p-1) = q.

  (3) Robustness.  The base a = N-1 is bad for Pollard's p-1 method at EVERY
      exponent: gcd((N-1)^M - 1, N) is N for even M and 1 for odd M, never a
      proper factor.  The base-free power sum succeeds at the same exponent.

  (4) Carmichael periodicity.  g_N has least period lambda(N) = lcm(p-1,q-1),
      and g_N(k) = 1 exactly when lambda(N) | k, so lambda(N) is the index of
      the first 1 in the sequence.

  (5) First hit and density.  The least k with g_N(k) != N is
      k* = min(p-1,q-1), and (k*+1)^2 <= N.  Within one period the number of
      revealing exponents is exactly lambda/(p-1) + lambda/(q-1) - 2.

  (6) Recovery.  The naive formula p+q = N - lambda(N) + 1 is FALSE
      (p=5, q=13).  The correct identity is
          gcd(p-1,q-1) * lambda(N) + (p+q) = N + 1,
      which recovers the factors when gcd(p-1,q-1) = 1.

  (7) Korselt bridge.  For squarefree N, gcd(F_N(N-1), N) = 1 exactly when N
      satisfies Korselt's criterion, i.e. for Carmichael numbers.

  (8) Prime powers.  For an odd prime p, sum_{a<p^e} a^k = -p^(e-1) mod p^e if
      (p-1)|k, else 0 mod p^e.  The condition is (p-1)|k, NOT lambda(p^e)|k.

Run with:  python3 demo.py
"""

from __future__ import annotations

from math import gcd, isqrt
from typing import Dict, Iterable, List, Optional, Tuple


# ---------------------------------------------------------------------------
# Core arithmetic
# ---------------------------------------------------------------------------


def lcm(a: int, b: int) -> int:
    """Least common multiple of two non-negative integers."""
    if a == 0 or b == 0:
        return 0
    return a // gcd(a, b) * b


def lcm_all(values: Iterable[int]) -> int:
    """Least common multiple of a finite family of positive integers."""
    result = 1
    for v in values:
        result = lcm(result, v)
    return result


def power_sum_mod(n: int, k: int) -> int:
    """F_N(k) mod N  =  (1^k + 2^k + ... + N^k) mod N.

    Cost: O(N) modular exponentiations, which is the dominant cost of the
    whole method and the reason it is asymptotically worse than trial
    division.
    """
    total = 0
    for a in range(1, n + 1):
        total += pow(a, k, n)
    return total % n


def power_sum_gcd(n: int, k: int) -> int:
    """g_N(k) = gcd(F_N(k), N)."""
    return gcd(power_sum_mod(n, k), n)


def is_prime(n: int) -> bool:
    """Deterministic trial-division primality test (adequate at these sizes)."""
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


def factorize(n: int) -> Dict[int, int]:
    """Prime factorization of n >= 1 as an exponent dictionary."""
    factors: Dict[int, int] = {}
    m = n
    d = 2
    while d * d <= m:
        while m % d == 0:
            factors[d] = factors.get(d, 0) + 1
            m //= d
        d += 1 if d == 2 else 2
    if m > 1:
        factors[m] = factors.get(m, 0) + 1
    return factors


def carmichael_squarefree(n: int) -> int:
    """lambda(N) = lcm over primes p | N of (p-1); valid for squarefree N."""
    return lcm_all(p - 1 for p in factorize(n))


# ---------------------------------------------------------------------------
# (1) + (2)  The master formula and the unconditional reveal
# ---------------------------------------------------------------------------


def master_formula(p: int, q: int, k: int) -> int:
    """Predicted value of g_{pq}(k) from the master formula, for k >= 1."""
    left = 1 if k % (p - 1) == 0 else p
    right = 1 if k % (q - 1) == 0 else q
    return left * right


def demo_master_formula() -> None:
    print("=" * 74)
    print("(1) MASTER FORMULA:  g_N(k) = (1 if (p-1)|k else p)*(1 if (q-1)|k else q)")
    print("=" * 74)
    for p, q in [(3, 5), (5, 7), (7, 11)]:
        n = p * q
        lam = lcm(p - 1, q - 1)
        print(f"\n  N = {p}*{q} = {n},  lambda(N) = lcm({p-1},{q-1}) = {lam}")
        print("    k  : " + " ".join(f"{k:>4}" for k in range(1, 2 * lam + 1)))
        computed = [power_sum_gcd(n, k) for k in range(1, 2 * lam + 1)]
        predicted = [master_formula(p, q, k) for k in range(1, 2 * lam + 1)]
        print("  g(k) : " + " ".join(f"{v:>4}" for v in computed))
        print("  pred : " + " ".join(f"{v:>4}" for v in predicted))
        assert computed == predicted, "master formula mismatch"
        print("    -> computed sequence matches the master formula exactly.")


def demo_factor_reveal() -> None:
    print()
    print("=" * 74)
    print("(2) UNCONDITIONAL FACTOR REVEAL:  for p < q,  g_{pq}(p-1) = q")
    print("=" * 74)
    print(f"\n  {'p':>4} {'q':>4} {'N':>7} {'k=p-1':>7} {'gcd(F(k),N)':>13} "
          f"{'expected':>9} {'lambda(N)':>10}")
    print("  " + "-" * 60)
    pairs: List[Tuple[int, int]] = [
        (3, 5), (5, 7), (7, 11), (11, 13), (13, 17), (17, 19), (23, 29), (89, 97)
    ]
    for p, q in pairs:
        n = p * q
        g = power_sum_gcd(n, p - 1)
        lam = lcm(p - 1, q - 1)
        flag = "OK" if g == q else "FAIL"
        print(f"  {p:>4} {q:>4} {n:>7} {p-1:>7} {g:>13} {q:>9} {lam:>10}   {flag}")
        assert g == q
    print("\n  -> all 8 test semiprimes reveal the larger factor at k = p-1.")


# ---------------------------------------------------------------------------
# (3)  Robustness against the bad-base failure of Pollard's p-1
# ---------------------------------------------------------------------------


def pollard_gcd(n: int, a: int, m: int) -> int:
    """Pollard p-1 style gcd:  gcd(a^M - 1, N)."""
    r = gcd(pow(a, m, n) - 1, n)
    return n if r == 0 else r


def demo_bad_base() -> None:
    print()
    print("=" * 74)
    print("(3) ROBUSTNESS: the base a = N-1 is bad for Pollard at EVERY exponent")
    print("=" * 74)
    for p, q in [(5, 7), (7, 11), (11, 13)]:
        n = p * q
        a = n - 1
        print(f"\n  N = {n} = {p}*{q},  base a = N-1 = {a}  (1 < a < N, gcd(a,N)=1)")
        row_m, row_pol, row_ps = [], [], []
        for m in range(1, 13):
            pol = pollard_gcd(n, a, m)
            row_m.append(m)
            row_pol.append(pol)
            row_ps.append(power_sum_gcd(n, m))
            expected = n if m % 2 == 0 else 1
            assert pol == expected, (m, pol, expected)
        print("    M        : " + " ".join(f"{v:>4}" for v in row_m))
        print("    Pollard  : " + " ".join(f"{v:>4}" for v in row_pol))
        print("    power sum: " + " ".join(f"{v:>4}" for v in row_ps))
        k = p - 1
        print(f"    at M = k = p-1 = {k}: Pollard gives {row_pol[k-1]} (useless), "
              f"power sum gives {row_ps[k-1]} (a factor).")
    print("\n  -> Pollard with this base returns only N (even M) or 1 (odd M),")
    print("     never a proper factor; the base-free power sum still succeeds.")


# ---------------------------------------------------------------------------
# (4)  Carmichael periodicity
# ---------------------------------------------------------------------------


def read_period(n: int, max_k: int = 4000) -> Optional[int]:
    """Least k >= 1 with g_N(k) = 1; equals lambda(N) for squarefree N."""
    for k in range(1, max_k + 1):
        if power_sum_gcd(n, k) == 1:
            return k
    return None


def demo_periodicity() -> None:
    print()
    print("=" * 74)
    print("(4) CARMICHAEL PERIODICITY: least period = lambda(N); first 1 at k=lambda")
    print("=" * 74)
    print(f"\n  {'N':>7} {'p':>4} {'q':>4} {'lcm(p-1,q-1)':>13} {'first k with g=1':>17}")
    print("  " + "-" * 50)
    for p, q in [(3, 5), (5, 7), (7, 11), (11, 13), (13, 17), (5, 13)]:
        n = p * q
        lam = lcm(p - 1, q - 1)
        first = read_period(n)
        print(f"  {n:>7} {p:>4} {q:>4} {lam:>13} {str(first):>17}")
        assert first == lam
    print("\n  -> the position of the first 1 IS the Carmichael number lambda(N).")

    # Verify exact minimality of the period for N = 35.
    n, lam = 35, 12
    seq = [power_sum_gcd(n, k) for k in range(1, 4 * lam + 1)]
    assert all(seq[k] == seq[k + lam] for k in range(2 * lam))
    for d in range(1, lam):
        assert any(seq[k] != seq[k + d] for k in range(2 * lam)), d
    print(f"  Checked for N = 35: shifting by {lam} is invariant, and no")
    print(f"  d in 1..{lam-1} is a period.  lambda(35) = {lam} is exactly least.")


# ---------------------------------------------------------------------------
# (5)  First hit and density
# ---------------------------------------------------------------------------


def demo_first_hit_and_density() -> None:
    print()
    print("=" * 74)
    print("(5) FIRST HIT k* = min(p-1,q-1) < sqrt(N), and density per period")
    print("=" * 74)
    print(f"\n  {'N':>7} {'k*':>4} {'g(k*)':>6} {'(k*+1)^2':>9} {'sqrt(N)':>8} "
          f"{'#reveal':>8} {'formula':>8}")
    print("  " + "-" * 60)
    for p, q in [(3, 5), (5, 7), (7, 11), (11, 13), (13, 17), (17, 19)]:
        n = p * q
        lam = lcm(p - 1, q - 1)
        kstar = min(p - 1, q - 1)
        # least k with g != N
        least = next(k for k in range(1, lam + 1) if power_sum_gcd(n, k) != n)
        assert least == kstar, (n, least, kstar)
        revealing = [k for k in range(1, lam + 1)
                     if power_sum_gcd(n, k) not in (1, n)]
        formula = lam // (p - 1) + lam // (q - 1) - 2
        assert len(revealing) == formula
        assert (kstar + 1) ** 2 <= n
        print(f"  {n:>7} {kstar:>4} {power_sum_gcd(n, kstar):>6} "
              f"{(kstar+1)**2:>9} {isqrt(n):>8} {len(revealing):>8} {formula:>8}")
    n, p, q = 35, 5, 7
    lam = 12
    rev = [k for k in range(1, lam + 1) if power_sum_gcd(n, k) not in (1, n)]
    print(f"\n  For N = 35 the revealing exponents in 1..{lam} are {rev},")
    print(f"  with values {[power_sum_gcd(n, k) for k in rev]}; "
          f"count = {lam//4} + {lam//6} - 2 = {lam//4 + lam//6 - 2}.")


# ---------------------------------------------------------------------------
# (6)  Factor recovery: the false formula and the correct identity
# ---------------------------------------------------------------------------


def demo_recovery() -> None:
    print()
    print("=" * 74)
    print("(6) FACTOR RECOVERY: the naive formula is FALSE; the corrected one holds")
    print("=" * 74)
    print(f"\n  {'p':>4} {'q':>4} {'N':>6} {'lam':>5} {'naive N-lam+1':>14} "
          f"{'p+q':>5} {'gcd(p-1,q-1)*lam+(p+q)':>24} {'N+1':>6}")
    print("  " + "-" * 74)
    for p, q in [(5, 13), (3, 5), (5, 7), (7, 11), (2, 7), (2, 11), (11, 13)]:
        n = p * q
        lam = lcm(p - 1, q - 1)
        g = gcd(p - 1, q - 1)
        naive = n - lam + 1
        corrected = g * lam + (p + q)
        assert corrected == n + 1
        mark = "  <-- naive OK" if naive == p + q else "  <-- naive WRONG"
        print(f"  {p:>4} {q:>4} {n:>6} {lam:>5} {naive:>14} {p+q:>5} "
              f"{corrected:>24} {n+1:>6}{mark}")
    print("\n  Counterexample in detail: p=5, q=13, N=65.")
    print("    lambda(65) = lcm(4,12) = 12,  naive gives 65-12+1 = 54, but p+q = 18.")
    print("    corrected: gcd(4,12)*12 + 18 = 4*12 + 18 = 66 = 65 + 1.  OK")
    print("\n  NOTE: if p and q are both odd then 2 | gcd(p-1,q-1), so the guard")
    print("  gcd(p-1,q-1)=1 fails; the naive formula is wrong in every such case.")


def recover_factors_from_period(n: int, lam: int) -> Optional[Tuple[int, int]]:
    """Recover {p,q} from N and lambda(N), valid when gcd(p-1,q-1) = 1.

    Solves X^2 - sX + N = 0 with s = N + 1 - lambda; returns None if the
    discriminant is not a perfect square (which signals that the guard fails).
    """
    s = n + 1 - lam
    disc = s * s - 4 * n
    if disc < 0:
        return None
    r = isqrt(disc)
    if r * r != disc or (s - r) % 2 != 0:
        return None
    a, b = (s - r) // 2, (s + r) // 2
    if a * b != n or a < 1:
        return None
    return (a, b)


def demo_recovery_algorithm() -> None:
    print()
    print("  Period-reading recovery under the guard gcd(p-1,q-1) = 1:")
    for p, q in [(2, 7), (2, 11), (2, 13), (2, 17)]:
        n = p * q
        lam = read_period(n)
        assert lam is not None
        rec = recover_factors_from_period(n, lam)
        print(f"    N = {n:>4}: read lambda = {lam:>3}  ->  recovered {rec}  "
              f"(true {(p, q)})")
        assert rec == (p, q)
    print("  Without the guard the same procedure fails, as it must:")
    for p, q in [(5, 13), (5, 7)]:
        n = p * q
        lam = read_period(n)
        rec = recover_factors_from_period(n, lam) if lam else None
        print(f"    N = {n:>4}: read lambda = {lam:>3}  ->  recovered {rec}  "
              f"(true {(p, q)})  [guard gcd={gcd(p-1,q-1)}]")


# ---------------------------------------------------------------------------
# (7)  Korselt bridge: Carmichael numbers are the blind spot at k = N-1
# ---------------------------------------------------------------------------


def is_squarefree(n: int) -> bool:
    return all(e == 1 for e in factorize(n).values())


def satisfies_korselt(n: int) -> bool:
    """(p-1) | (N-1) for every prime p | N, with N squarefree."""
    return is_squarefree(n) and all((n - 1) % (p - 1) == 0 for p in factorize(n))


def demo_korselt() -> None:
    print()
    print("=" * 74)
    print("(7) KORSELT BRIDGE: gcd(F_N(N-1), N) = 1  <=>  N is Carmichael")
    print("=" * 74)
    print(f"\n  {'N':>6} {'factors':>16} {'lambda(N)':>10} {'lambda|N-1':>11} "
          f"{'gcd(F(N-1),N)':>14} {'Carmichael':>11}")
    print("  " + "-" * 74)
    for n in [15, 35, 561, 1105, 1729, 2465, 91, 341]:
        if not is_squarefree(n):
            continue
        f = factorize(n)
        lam = carmichael_squarefree(n)
        divides = (n - 1) % lam == 0
        g = power_sum_gcd(n, n - 1)
        kors = satisfies_korselt(n) and not is_prime(n)
        fstr = "*".join(str(p) for p in sorted(f))
        print(f"  {n:>6} {fstr:>16} {lam:>10} {str(divides):>11} {g:>14} "
              f"{str(kors):>11}")
        assert (g == 1) == divides
    print("\n  -> the reveal at k = N-1 is blind exactly on the Carmichael numbers")
    print("     561 = 3*11*17, 1105 = 5*13*17, 1729 = 7*13*19, 2465 = 5*17*29.")
    print("     For 561: lambda = lcm(2,10,16) = 80 and 80 | 560, so gcd = 1.")
    print("     The blindness is exponent-specific: e.g. for N = 561,")
    print(f"     g(1) = {power_sum_gcd(561,1)}, g(2) = {power_sum_gcd(561,2)}, "
          f"g(3) = {power_sum_gcd(561,3)} all leak information.")


# ---------------------------------------------------------------------------
# (8)  Odd prime powers
# ---------------------------------------------------------------------------


def demo_prime_powers() -> None:
    print()
    print("=" * 74)
    print("(8) ODD PRIME POWERS: sum_{a<p^e} a^k = -p^(e-1) mod p^e iff (p-1)|k")
    print("=" * 74)
    for p, e in [(3, 2), (3, 3), (5, 2), (7, 2)]:
        pe = p ** e
        lam_unit = p ** (e - 1) * (p - 1)
        print(f"\n  p^e = {p}^{e} = {pe},  (p-1) = {p-1},  "
              f"lambda(p^e) = {lam_unit}")
        print("    k             : " + " ".join(f"{k:>5}" for k in range(1, 13)))
        vals = [sum(pow(a, k, pe) for a in range(pe)) % pe for k in range(1, 13)]
        print("    sum mod p^e   : " + " ".join(f"{v:>5}" for v in vals))
        pred = [(-(p ** (e - 1))) % pe if k % (p - 1) == 0 else 0
                for k in range(1, 13)]
        print("    predicted     : " + " ".join(f"{v:>5}" for v in pred))
        assert vals == pred
        cond_pm1 = [k for k in range(1, 13) if k % (p - 1) == 0]
        cond_lam = [k for k in range(1, 13) if k % lam_unit == 0]
        print(f"    nonzero at k in {cond_pm1}  (condition (p-1)|k)")
        print(f"    lambda(p^e)|k at k in {cond_lam}  <-- NOT the right condition")

    print("\n  Consequence for a non-squarefree modulus, N = 45 = 3^2 * 5, k = 2:")
    n, k = 45, 2
    print(f"    (3-1)|2 so the 3-part drops from 9 to 3; (5-1) does not divide 2,")
    print(f"    so the 5-part is full.  Predicted gcd = 3*5 = 15;  "
          f"computed = {power_sum_gcd(n, k)}.")
    assert power_sum_gcd(n, k) == 15
    print("\n  The prime 2 is genuinely exceptional.  For N = 8:")
    row = [power_sum_gcd(8, k) for k in range(1, 11)]
    print("    k        : " + " ".join(f"{k:>3}" for k in range(1, 11)))
    print("    g_8(k)   : " + " ".join(f"{v:>3}" for v in row))
    print("    -> for k >= 2 the value is 4 when k is even and 8 when k is odd:")
    print("       it alternates with the parity of k, and the odd-prime formula")
    print("       does not apply.")


# ---------------------------------------------------------------------------
# The reveal algorithm, end to end
# ---------------------------------------------------------------------------


def power_sum_factor(n: int, max_k: Optional[int] = None) -> Optional[Tuple[int, int]]:
    """Find a proper factor of N by scanning k = 1, 2, 3, ...

    Returns (k, d) where d is the first proper nontrivial divisor found, or
    None if none is found within the bound.  By the first-hit theorem the
    successful k is min(p-1, q-1) for a semiprime N = pq.
    """
    if max_k is None:
        max_k = isqrt(n) + 1
    for k in range(1, max_k + 1):
        d = power_sum_gcd(n, k)
        if 1 < d < n:
            return (k, d)
    return None


def demo_algorithm() -> None:
    print()
    print("=" * 74)
    print("END-TO-END: the reveal algorithm on the test semiprimes")
    print("=" * 74)
    print(f"\n  {'N':>7} {'first k':>8} {'factor':>7} {'cofactor':>9} "
          f"{'k* = min(p-1,q-1)':>18}")
    print("  " + "-" * 55)
    for p, q in [(3, 5), (5, 7), (7, 11), (11, 13), (13, 17), (17, 19),
                 (23, 29), (89, 97)]:
        n = p * q
        res = power_sum_factor(n)
        assert res is not None
        k, d = res
        assert n % d == 0 and 1 < d < n
        print(f"  {n:>7} {k:>8} {d:>7} {n // d:>9} {min(p-1, q-1):>18}")
        assert k == min(p - 1, q - 1)
    print("\n  Cost accounting: each F_N(k) costs O(N) modular operations and the")
    print("  first hit is at k* < sqrt(N), so the total is O(N^{3/2}).  Trial")
    print("  division costs O(sqrt(N)).  The method is asymptotically WORSE.")


# ---------------------------------------------------------------------------


def main() -> None:
    print()
    print("#" * 74)
    print("#  POWER-SUM GCD FACTOR REVELATION AND CARMICHAEL PERIODICITY")
    print("#  Numerical demonstration of the complete structure theory")
    print("#" * 74)
    demo_master_formula()
    demo_factor_reveal()
    demo_bad_base()
    demo_periodicity()
    demo_first_hit_and_density()
    demo_recovery()
    demo_recovery_algorithm()
    demo_korselt()
    demo_prime_powers()
    demo_algorithm()
    print()
    print("=" * 74)
    print("All assertions passed: every computed value agrees with the theory.")
    print("=" * 74)
    print()


if __name__ == "__main__":
    main()
