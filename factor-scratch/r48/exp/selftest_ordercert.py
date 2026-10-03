#!/usr/bin/env python3
"""
SELF-TEST for the "order certificate" harness (R2).  Written BEFORE the
experiment, per the earned rules.

The harness measures: given (N, g, verified factorization of ord_N(g)),
does the gcd-descent ladder return a nontrivial factor of N?

A harness that cannot detect a synthetic 100% generator and a synthetic
0% generator is BROKEN.  We force that check here with generators whose
success is 1.000 and 0.000 BY CONSTRUCTION, not by luck.

GENERATOR A (must give 1.000):  N = p*q, g chosen so that ord_p(g) and
ord_q(g) are FORCED to differ, because g is a primitive root mod p and an
element of small order mod q.  We build g by CRT after factoring, so the
construction is exact -- not statistical.

GENERATOR B (must give 0.000):  N = p*q with p and q chosen so that
g = 2 (or a fixed g) has ord_p(g) = ord_q(g).  We build this by *search*:
for a target order T that is B-smooth, look for two primes r with
ord_r(g) = T for the SAME fixed g.  If we find them, the valuations agree
on every prime and the descent provably cannot split N.  This is a REAL
instance of the degenerate case, found by search rather than assumed.

If the harness reports anything other than 1.000 and 0.000 on A and B, it
is broken and every downstream number is void.
"""
import random
import sympy
from sympy.ntheory import n_order, isprime

random.seed(20261003)


def factor_M(M):
    return sympy.factorint(M)


def verify_certificate(N, g, M, fac):
    """Check in poly(log N) time that ord_N(g) == M with the given factorization.
    Sound, deterministic given the factor list."""
    # 1. fac really multiplies to M
    prod = 1
    for q, e in fac.items():
        if not isprime(q):
            return False, "not prime"
        prod *= q ** e
    if prod != M:
        return False, "product mismatch"
    # 2. g^M == 1 mod N  => ord | M
    if pow(g, M, N) != 1 % N:
        return False, "g^M != 1"
    # 3. g^(M/q) != 1 for each q => ord does not divide M/q
    for q in fac:
        if pow(g, M // q, N) == 1 % N:
            return False, "order too small"
    return True, "ok"


def descend(N, g, M, fac):
    """The ORDER CERTIFICATE descent.

    For each distinct prime q | M:
        d = gcd(g^(M/q) - 1, N)
    If 1 < d < N, return d.
    Else the ladder certifies: ord_r(g) is INDEPENDENT of the prime r | N.
    """
    certs = []
    for q in fac:
        d = sympy.gcd(pow(g, M // q, N) - 1, N)
        if 1 < d < N:
            return d, f"SPLIT via q={q}", certs
        certs.append((q, int(d)))
    return None, "DEGENERATE (ord_r(g) constant over r|N)", certs


def gen_A(force_order_T=None):
    """100% generator. CRT-constructed g: primitive root mod p, order 2 mod q."""
    while True:
        p = sympy.randprime(10**9, 10**10)
        q = sympy.randprime(10**9, 10**10)
        if p == q:
            continue
        N = p * q
        a = sympy.primitive_root(p)
        # want g ≡ a (mod p), g ≡ 1 (mod q)  => ord_q(g)=1, ord_p(g)=p-1
        g = (a + p * ((1 - a) * pow(p, -1, q) % q)) % N
        M = n_order(g, N)
        fac = factor_M(M)
        return N, g, M, fac


def gen_B(T, g_fixed):
    """0% generator by SEARCH: find two primes r with ord_r(g_fixed) == T."""
    T = int(T)
    for delta in range(0, 400000):
        for r in (sympy.nextprime(10**9 + delta), sympy.nextprime(10**9 + delta + 1)):
            pass
        a = sympy.randprime(10**9, 10**11)
        if n_order(g_fixed, a) == T:
            yield a


def main():
    print("=" * 68)
    print("SELF-TEST 1: certificate verifier rejects forged certificates")
    N, g, M, fac = gen_A()
    ok, why = verify_certificate(N, g, M, fac)
    print(f"  honest cert          -> {ok}  ({why})   [must be True]")
    assert ok, "honest certificate rejected -- harness broken"
    bad = dict(fac)
    # forge: drop a prime factor of M
    for q in list(bad):
        if bad[q] >= 2:
            bad[q] -= 1
            break
        else:
            del bad[q]
            break
    ok2, why2 = verify_certificate(N, g, M, bad)
    print(f"  forged cert (M too big)-> {ok2}  ({why2})   [must be False]")
    assert not ok2, "forged certificate ACCEPTED -- harness broken"

    print("=" * 68)
    print("SELF-TEST 2: descent splits on the 100% generator")
    hits = 0
    trials = 40
    for _ in range(trials):
        N, g, M, fac = gen_A()
        d, why, _ = descend(N, g, M, fac)
        if d is not None:
            assert N % d == 0 and 1 < d < N, "descent returned a NON-FACTOR"
            hits += 1
    rate = hits / trials
    print(f"  success rate = {rate:.3f} over {trials} trials   [must be 1.000]")
    assert rate == 1.0, f"100% generator gave {rate} -- harness broken"

    print("=" * 68)
    print("SELF-TEST 3: descent certifies DEGENERACY on a searched 0% generator")
    # Find p,q primes with ord_?(2) equal -- instead use CRT-free construction:
    # take g = 2 and search primes q with ord_q(2) = ord_p(2) for a fixed p.
    found = 0
    trialsB = 0
    p = sympy.randprime(10**7, 10**8)
    T = n_order(2, p)
    print(f"  fixed prime p, T = ord_2(p) = {T}  (factors {factor_M(T)})")
    seen = {p: T}
    for _ in range(4000):
        trialsB += 1
        r = sympy.randprime(10**7, 10**9)
        if n_order(2, r) == T:
            N = p * r
            g = 2
            M = T
            fac = factor_M(M)
            d, why, certs = descend(N, g, M, fac)
            assert d is None, "descent split a DEGENERATE instance -- broken"
            found += 1
            if found >= 5:
                break
    print(f"  degenerate instances constructed & correctly certified: {found}")
    if found:
        print(f"  success rate = 0.000 on {found} degenerate instances  [must be 0.000]")
        print("  SELF-TEST PASSED (all three checks)")
        return
    print("  !! could not construct a degenerate instance in the search budget.")
    print("  !! SYNTHETIC 0% CHECK INCONCLUSIVE -- do not trust downstream rates.")


if __name__ == "__main__":
    main()