"""
Audit of r112/stange_kernel's SURVIVING claim.

That RESULT.md's factoring counts are on RSA moduli of 20-40 bits, which
factorint solves in 0.002-0.7 s -- so "108/135 = 80% verified" is a CORRECTNESS
TEST, not evidence.  But its load-bearing claim is different and is NOT a
factoring claim:

    "success is EXACTLY P = 20/27, predicted by the v2-law, and the Q-kernel
     contributes NO success probability -- plain order-finding + strip + gcd
     delivers the same 20/27."

That claim has a runnable baseline, trivially available at 20-40 bits:
BRUTE-FORCE order finding.  If plain order-finding + strip + gcd gives the same
rate, the claim is CONFIRMED.

Run: python3 stange_baseline.py <seed> [trials]
"""
import random
import sys
from math import gcd
from sympy import nextprime

PRED = 20 / 27


def gen_rsa(nb, rng):
    p = int(nextprime(rng.randrange(2 ** (nb - 1), 2 ** nb)))
    q = int(nextprime(rng.randrange(2 ** (nb - 1), 2 ** nb)))
    return p, q, p * q


def order_mod(g, p):
    """Brute-force multiplicative order of g mod p (p small prime)."""
    x = 1
    for k in range(1, p):
        x = x * g % p
        if x == 1:
            return k
    return None


def baseline_strip_and_gcd(N, g, p, q):
    """CLASSICAL BASELINE: brute-force the exact orders (available free at
    20-40 bits), then the standard 2-part strip and gcd.  No Q-kernel."""
    op = order_mod(g, p)
    oq = order_mod(g, q)
    if op is None or oq is None:
        return None, False
    v2_pred = (op & -op) != (oq & -oq)
    if not v2_pred:
        return None, v2_pred
    e = 1
    while pow(g, e, N) != 1:
        e *= 2
    d = gcd(pow(g, e, N) - 1, N)
    return (d if 1 < d < N else None), v2_pred


def run(seed, trials):
    print("BASELINE = brute-force order finding + strip + gcd (no Q-kernel at all)")
    print("seed=%d  trials/point=%d   predicted rate 20/27 = %.4f" % (seed, trials, PRED))
    print("%-8s %-8s %-9s %-9s %-8s %s" % ("p bits", "trials", "factored", "rate", "z", "v2-predicts"))
    tot_ok = tot_n = tot_pred = 0
    for nb in (26, 30, 40):
        rng = random.Random(seed * 1000 + nb)
        ok = pred = hits = 0
        for _ in range(trials):
            p, q, N = gen_rsa(nb, rng)
            assert p * q == N
            g = rng.randrange(2, N - 1)
            if gcd(g, N) != 1:
                continue
            d, v2 = baseline_strip_and_gcd(N, g, p, q)
            pred += 1
            if v2:
                hits += 1
            if d is not None and N % d == 0 and d in (p, q):
                ok += 1
        tot_ok += ok
        tot_n += pred
        tot_pred += hits
        r = ok / pred if pred else 0.0
        z = (r - PRED) / ((PRED * (1 - PRED) / pred) ** 0.5) if pred else 0.0
        print("%-8d %-8d %-9d %-9.4f %-+8.2f %d/%d" % (nb, pred, ok, r, z, hits, pred))
    r = tot_ok / tot_n
    z = (r - PRED) / ((PRED * (1 - PRED) / tot_n) ** 0.5)
    print("%-8s %-8d %-9d %-9.4f %-+8.2f %d/%d" % ("TOTAL", tot_n, tot_ok, r, z, tot_pred, tot_n))
    print("VERDICT: baseline rate %.4f vs 20/27 = %.4f, z = %+.2f" % (r, PRED, z))
    if abs(z) < 2.0:
        print("=> r112's claim CONFIRMED: the Q-kernel adds no success probability;")
        print("   plain order-finding + strip + gcd delivers the same ~20/27.")
    else:
        print("=> r112's claim is INCONSISTENT with this baseline -- investigate.")
    return r, z


if __name__ == "__main__":
    seed = int(sys.argv[1]) if len(sys.argv) > 1 else 20261005
    trials = int(sys.argv[2]) if len(sys.argv) > 2 else 100
    run(seed, trials)
