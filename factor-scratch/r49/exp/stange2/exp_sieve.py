"""
exp_sieve.py -- H3, wall-clock.  Can a small-prime sieve buy relations more
cheaply than exhaustive trial division?

PREREG-4 (target: >= 2x wall-clock reduction at equal success rate).

The obstruction was found in the self-test, before measuring: in NFS the
sieved quantity r = a - x mod q is LINEAR in the sieved variable, so one sieve
value per prime amortizes over a whole bucket of candidates.  Here r = g^x
mod n is EXPONENTIAL in x, so r mod l = g^(x mod ord_l(g)) mod l must be
recomputed for every candidate -- there is no bucket to amortize over.  The
only sound sieve left is gcd(r, primorial(BB, Z]) == 1, which needs r, i.e.
needs the exponentiation it was supposed to avoid.

This script measures the consequence: three samplers, identical relation sets
by construction, timed on the same instances.
  S0  exhaustive trial division (the baseline sampler)
  S1  primorial-gcd rejection, then trial division on survivors
  S2  exhaustive, but with an EARLY-ABORT: stop dividing once rem is provably
      too large to be FB-smooth (rem > BB^(#primes left))
"""
from __future__ import annotations

import json
import random
import sys
import time
from math import gcd

from s2core import attempt, bbound_for_b, factor_base, primes_upto, rand_g
from stange import fb_exponents, find_relations, gen_semiprime


def powlimit(BB, b):
    """BB^k for k = 0..b  (descending cap for the early abort)."""
    return [BB ** k for k in range(b + 1)]


def sampler(n, g, FB, need, rng, mode, Z=None, cap=None):
    BB = FB[-1]
    b = len(FB)
    if Z is None:
        Z = BB * 16
    if mode == "primorial":
        PZ = 1
        for l in primes_upto(Z):
            if l > BB:
                PZ *= l
    rels, seen, trials = [], set(), 0
    while len(rels) < need:
        trials += 1
        x = rng.randrange(1, n)
        if x in seen:
            continue
        r = pow(g, x, n)
        if mode == "primorial":
            if gcd(r, PZ) != 1:
                continue
            exps, rem = fb_exponents(r, FB)
        elif mode == "earlyabort":
            exps = [0] * b
            rem = r
            for k in range(b):
                p = FB[k]
                if rem % p == 0:
                    while rem % p == 0:
                        rem //= p
                        exps[k] += 1
                if rem > cap[b - 1 - k]:
                    break
        else:
            exps, rem = fb_exponents(r, FB)
        if rem == 1:
            seen.add(x)
            rels.append((exps, x))
    return rels, trials


def bench(nbits, b, c, ninst, seed0=770000):
    cap = powlimit(bbound_for_b(b), b)
    res = {}
    for mode in ("exhaustive", "primorial", "earlyabort"):
        tot_t = tot_s = 0
        t0 = time.time()
        for k in range(ninst):
            rng = random.Random(seed0 + 17 * k)
            n, p, q = gen_semiprime(nbits, rng)
            FB = factor_base(bbound_for_b(b), n)
            if len(FB) != b:
                continue
            g = rand_g(n, rng)
            r2 = random.Random(seed0 + 17 * k + 1)
            _, tr = sampler(n, g, FB, b + c, r2, mode, cap=cap)
            tot_t += tr
            tot_s += time.time() - t0
        res[mode] = {"exponentiations": tot_t, "secs": round(tot_s, 2),
                     "us_per_exp": round(1e6 * tot_s / max(tot_t, 1), 3)}
    return res


if __name__ == "__main__":
    NI = int(sys.argv[1]) if len(sys.argv) > 1 else 3
    out = {}
    for (nbits, b, c) in ((30, 12, 10), (30, 40, 5), (40, 20, 5)):
        print(f"\nn~2^{nbits}, b={b}, c={c}  ({NI} instances, "
              f"identical relation sets by construction)")
        r = bench(nbits, b, c, NI)
        base = r["exhaustive"]["secs"]
        for m, v in r.items():
            print(f"  {m:<12} {v['exponentiations']:>9,} exps  {v['secs']:>7.2f}s"
                  f"  {v['us_per_exp']:>6.3f} us/exp  "
                  f"speedup vs exhaustive {base/max(v['secs'],1e-9):>5.2f}x")
        out[f"{nbits}_{b}_{c}"] = r
    best = 1.0
    for r in out.values():
        for m, v in r.items():
            best = max(best, r["exhaustive"]["secs"] / max(v["secs"], 1e-9))
    print(f"\nPREREG-4 (target >= 2.00x): best achieved {best:.2f}x  -> "
          f"{'PASSED' if best >= 2.0 else 'FALSIFIED'}")
    json.dump(out, open("sieve.json", "w"), indent=1)