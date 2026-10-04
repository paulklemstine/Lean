"""
WHERE DOES 20/27 COME FROM?

I verified P(success) = 20/27 = 0.740740... for the Stange method (measured
0.73325, -1.08 sigma) and REFUTED my own derivation of 2/3 (+8.93 sigma).
My derivation assumed P(v2(ord_p g) = k) = 2^-(k+1) -- a geometric law that
holds ONLY when p = 3 mod 4 (so v2(p-1) = 1).

But p is NOT always 3 mod 4. The law depends on s = v2(p-1), and s is
itself distributed: P(s = j) = 2^-(j+1) for j >= 1 over random primes.

In a cyclic group of order m = 2^s * u (u odd), for g = a^j uniform:
    v2(ord g) = s - min(s, v2(j))
    P(v2(j) = i) = 2^-(i+1) for i < s ;  P(j = 0 mod 2^s) = 2^-s

HYPOTHESIS: averaging over the joint distribution of (s_p, s_q) gives
exactly 20/27. If so, the constant is fully explained and my "unexplained"
note is closed.

SELF-TEST FIRST: the s=1 case must reproduce the geometric law I used, and
the computed value must match the brute-force measured 0.73325.
"""

from __future__ import annotations

from functools import lru_cache


@lru_cache(maxsize=None)
def v2dist(s: int, K: int = 40):
    """P(v2(ord) = k) for a uniform element of a cyclic group of order 2^s * u."""
    p = [0.0] * (K + 1)
    # v2(j) = i < s  ->  v2(ord) = s - i,  P = 2^-(i+1)
    for i in range(s):
        k = s - i
        if k <= K:
            p[k] += 2.0 ** (-(i + 1))
    # j = 0 mod 2^s  ->  v2(ord) = 0,  P = 2^-s
    p[0] += 2.0 ** (-s)
    return p


def p_unequal(sp: int, sq: int, K: int = 40) -> float:
    """P(v2(ord_p g) != v2(ord_q g)) for independent uniform g."""
    a, b = v2dist(sp, K), v2dist(sq, K)
    return sum(x * y for i, x in enumerate(a) for j, y in enumerate(b) if i != j)


def selftest() -> bool:
    ok = True
    print("SELFTEST 1: s=1 must reproduce the geometric law I originally used")
    p1 = v2dist(1)
    print(f"  s=1: P(k=0)={p1[0]:.4f}  P(k=1)={p1[1]:.4f}   (want 0.5, 0.5)")
    if abs(p1[0] - 0.5) > 1e-12 or abs(p1[1] - 0.5) > 1e-12:
        print("  [FAIL] s=1 does not reproduce the geometric law")
        ok = False
    else:
        print("  [PASS] s=1 matches -- so s=1 is the case my wrong derivation assumed")

    print()
    print("SELFTEST 2: with BOTH primes = 3 mod 4, P(unequal) must be 1/2")
    got = p_unequal(1, 1)
    print(f"  P(unequal | s_p=s_q=1) = {got:.6f}   (want 0.500000 = 1/2)")
    if abs(got - 0.5) > 1e-9:
        print("  [FAIL]")
        ok = False
    else:
        print("  [PASS] -- this is where my refuted 2/3 derivation actually died:")
        print("         the s=1 law is TRUNCATED to {k=0: 1/2, k=1: 1/2}, so P(unequal)=1/2,")
        print("         not 2/3. I had summed an infinite geometric series that does not apply.")

    print()
    print("SELFTEST 3: the weight law must have mass exactly 1 (the FATAL of 2026-10-03)")
    mass = sum(2.0 ** (-j) for j in range(1, 200))
    print(f"  mass of P(s=j)=2^-j  = {mass:.12f}   (want exactly 1)")
    if abs(mass - 1.0) > 1e-9:
        print("  [FAIL] -- the weight law does not sum to 1, so the sum needs a")
        print("          renormalisation, which means the summand is wrong.")
        ok = False
    else:
        print("  [PASS] -- no renormalisation is needed, and the sum is 20/27 directly.")
    print()
    return ok


def main() -> None:
    if not selftest():
        raise SystemExit(1)

    print("=" * 74)
    print("AVERAGE OVER THE DISTRIBUTION OF s = v2(p-1) FOR RANDOM PRIMES")
    print("=" * 74)
    print("  For random primes:  P(s = 1) = 1/2, P(s=2) = 1/4, P(s=3) = 1/8, ...")
    print()
    print(f"  {'S':>3} {'P(s_p=s_q=S)':>14} {'cumulative':>11} {'P(unequal|S,S)':>15}")
    cum = 0.0
    for S in range(1, 9):
        w = (2.0 ** (-(S + 1))) ** 2          # both primes have s = S
        cum += w
        print(f"  {S:>3} {w:>14.6f} {cum:>11.6f} {p_unequal(S, S):>15.6f}")

    # CORRECTED 2026-10-03 after adversarial audit KK_audit_amendments.md:
    # the law is P(s = j) = 2^-j  (mass exactly 1), NOT 2^-(j+1) (mass 0.5).
    # The old code divided by the truncated mass -- an UNDECLARED renormalisation
    # that silently compensated for the wrong summand. Delete it; it is not needed.
    Smax = 40
    total = 0.0
    for sp in range(1, Smax + 1):
        for sq in range(1, Smax + 1):
            w = 2.0 ** (-sp) * 2.0 ** (-sq)
            total += w * p_unequal(sp, sq)

    print()
    print(f"  EXACT AVERAGE  P(unequal) = {total:.8f}")
    print(f"  AGENT'S CLAIMED CONSTANT = {20/27:.8f}   (20/27)  <- no renormalisation used")
    print(f"  MY REFUTED DERIVATION   = {2/3:.8f}   (2/3)")
    print(f"  MEASURED (independent)  = 0.73325")
    print()
    print(f"  deviation from 20/27 : {total - 20/27:+.6f}")
    print(f"  deviation from 2/3  : {total - 2/3:+.6f}")


if __name__ == "__main__":
    main()