"""
exp_order.py -- THE DECISIVE CONTROL.

T7 of the self-test established that factor_from_multiple() strips G all the
way down to ord(g) exactly. Therefore the index h = G/ord(g) is erased before
the gcd, and the per-attempt success probability is a property of the ORDER
STEP ALONE:

    success  <=>  v2(ord_p(g)) != v2(ord_q(g))

(the standard Shor criterion: g^{ord/2} is +1 mod one prime and -1 mod the
other exactly when the two 2-adic valuations of the two orders differ).

Consequence: P(success) can be measured EXACTLY and for free, with NO relation
finding, at ANY n -- including n = 2^200.  This is the H4 decay curve.

Closed form (preregistered check):  p, q random odd primes, g uniform.
  P(v2(p-1)=m) = 2^-(m+1)  (m>=1), P(m=0)=1/2
  P(v2(ord_p g)=k | m) = phi(2^k)/2^m
  => P_k = (4/3) phi(2^k) 2^-(2k+1),  P(succ) = 1 - sum_k P_k^2.
"""
from __future__ import annotations

import json
import math
import random
import sys
import time
from collections import Counter

from cypari2 import Pari

P = Pari()


def v2(x):
    return (x & -x).bit_length() - 1 if x else 99


def closed_form():
    """p, q random ODD primes => v2(p-1) = m >= 1 ALWAYS, with P(m) = 2^-m.
    (My first version wrongly allowed m=0 and got 0.5185; the truth is 20/27.)
    P(v2(ord_p g) = k | m) = phi(2^k)/2^m.
    => P_k = phi(2^k) * sum_{m>=max(k,1)} 2^-2m = phi(2^k)*(4/3)*4^-max(k,1)
    => P_0 = 1/3,  P_k = (4/3) 2^-(k+1)  for k>=1
    => sum_k P_k^2 = 1/9 + (16/9)(1/12) = 7/27
    => P(split) = 1 - 7/27 = 20/27 = 0.740740... EXACTLY."""
    Pk = {0: 1.0 / 3.0}
    for k in range(1, 40):
        Pk[k] = (4.0 / 3.0) * 2.0 ** (-(k + 1))
    tot = sum(v * v for v in Pk.values())
    return 1.0 - tot, Pk


def gen_semiprime_fast(bits, rng, P):
    """balanced odd semiprime via PARI nextprime (much faster than sympy)."""
    hb = bits // 2
    while True:
        v = rng.getrandbits(hb) | (1 << (hb - 1)) | 1
        p = int(P.nextprime(v))
        q = int(P.nextprime(int(P.nextprime(v)) + rng.getrandbits(hb // 2)))
        if p != q and p % 2 == 1 and q % 2 == 1:
            return p * q, p, q


def run(nbits, N, seed):
    rng = random.Random(seed)
    succ = 0
    hist = Counter()
    t0 = time.time()
    for _ in range(N):
        n, p, q = gen_semiprime_fast(nbits, rng, P)
        g = rng.randrange(2, n)
        while math.gcd(g, n) != 1:
            g = rng.randrange(2, n)
        op = int(P.znorder(P.Mod(g, p)))
        oq = int(P.znorder(P.Mod(g, q)))
        ok = v2(op) != v2(oq)
        succ += ok
        hist[(v2(op), v2(oq))] += 1
    return {"nbits": nbits, "N": N, "succ": succ, "rate": succ / N,
            "secs": round(time.time() - t0, 1), "hist": {f"{a},{b}": v
                                                          for (a, b), v in hist.items()}}


if __name__ == "__main__":
    cf, Pk = closed_form()
    print(f"closed form  P(v2(op)!=v2(oq)) = 1 - sum P_k^2 = {cf:.6f}")
    print("  P_k =", {k: round(v, 6) for k, v in Pk.items() if v > 1e-6})
    print()
    N = int(sys.argv[1]) if len(sys.argv) > 1 else 2000
    sizes = [20, 26, 30, 40, 50, 60, 70, 80, 100, 140, 200]
    out = []
    for i, nb in enumerate(sizes):
        r = run(nb, N, 900 + i)
        r["closed_form"] = cf
        se = math.sqrt(cf * (1 - cf) / r["N"])
        z = (r["rate"] - cf) / se
        print(f"n~2^{nb:<4d}  P(order step splits) = {r['succ']}/{r['N']} "
              f"= {r['rate']:.4f}   closed form {cf:.4f}  z={z:+.2f}  "
              f"({r['secs']}s)", flush=True)
        out.append(r)
        json.dump(out, open("order_curve.json", "w"))
    print("\nDECAY CURVE (H4): rate vs log2 n")
    for r in out:
        bar = "#" * int(60 * r["rate"])
        print(f"  2^{r['nbits']:<4d} {r['rate']:.4f} {bar}")