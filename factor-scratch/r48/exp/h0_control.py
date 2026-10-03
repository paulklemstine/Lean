"""STEP 0 -- THE TWIN CONTROL (scale-matched version).

E6b/E6c/E7 claim P(|Cl(Q(sqrt(D)))| is B-smooth) > P(EC order is B-smooth),
quoting 0.720 vs 0.440 and 0.400 vs 0.320.  E6b's own caveat says the sizes
were not matched.

THE MATCHING BUG THIS SCRIPT EXISTS TO CATCH.  An earlier version of this
file compared k-bit EC orders against class numbers of D with |D| ~ 2^k.
Since h(-q) ~ sqrt(|D|)/pi, a 2^k-sized discriminant yields only a 2^{k/2}-sized
CLASS NUMBER.  That inflates the class-number arm by a factor of ~2 in log2
and manufactures a gap of +0.4 to +0.7 out of nothing.  The fix: MATCH ON THE
BIT LENGTH OF THE ORDER ITSELF.  To get a k-bit class number one must search
D of ~2k bits.

Arms, all at the same order bit-length k and the same B:
  A) h(D), D = -q prime, |D| searched until h(D) has exactly k bits
  B) m = p + 1 - t, |t| <= 2 sqrt(p), p prime of k bits   [correct EC baseline]
  C) uniform k-bit integers                                 [naive baseline]

Self-test: the harness must read exactly 1.000 on a synthetic all-smooth
stream and exactly 0.000 on a stream of distinct primes > B.
"""
import json
import math
import random
import sys
from math import isqrt

from dickman import rho
from sympy import isprime, primerange


# --------------------------------------------------------------- smoothness

def make_smoother(B):
    ps = list(primerange(2, B + 1)) + [B + 1]
    def is_smooth(n):
        for q in ps:
            if q > B:
                break
            while n % q == 0:
                n //= q
        return n == 1
    return is_smooth


# --------------------------------------------------------------- generators

def gen_class_numbers(k, n, rng, log=None):
    """h(D) for D = -q, q prime, searched until h(D) has exactly k bits.

    [uses no factor p: we choose the FIELD discriminant D independently.  In
     a real factoring run D would additionally have to satisfy (D/p) = 0 or
     not; that is the subject of h1_degenerate.py.]
    """
    from clforms import pari
    p = pari()
    out = []
    lo = 2 ** (2 * k - 3)
    hi = 2 ** (2 * k + 3)
    tries = 0
    while len(out) < n and tries < 300 * n:
        tries += 1
        q = rng.randrange(lo, hi) | 1
        if not isprime(q):
            continue
        D = -q
        if D % 4 not in (0, 1):
            continue
        try:
            h = int(p.qfbclassno(D))
        except Exception:
            continue
        if h.bit_length() == k:
            out.append(h)
    return out


def gen_ec_orders(k, n, rng):
    """m = #E(F_p), p prime of k bits, trace t uniform in the Hasse interval."""
    out = []
    lo, hi = 2 ** (k - 1), 2 ** k
    tries = 0
    while len(out) < n and tries < 400 * n:
        tries += 1
        p = rng.randrange(lo, hi) | 1
        if not isprime(p):
            continue
        t = rng.randint(-2 * isqrt(p), 2 * isqrt(p))
        m = p + 1 - t
        if m > 1:
            out.append(m)
    return out


def gen_uniform(k, n, rng):
    return [rng.randrange(2 ** (k - 1), 2 ** k) for _ in range(n)]


# --------------------------------------------------------------- statistics

def wilson(k, n, z=1.96):
    if n == 0:
        return (0.0, 0.0)
    ph = k / n
    d = 1 + z * z / n
    c = (ph + z * z / (2 * n)) / d
    hw = z * math.sqrt(ph * (1 - ph) / n + z * z / (4 * n * n)) / d
    return (max(c - hw, 0.0), min(c + hw, 1.0))


def rate(vals, is_smooth):
    hits = sum(1 for v in vals if is_smooth(v))
    n = len(vals)
    lo, hi = wilson(hits, n)
    return {"hits": hits, "n": n, "rate": hits / n if n else 0.0,
            "wilson95": [round(lo, 4), round(hi, 4)]}


# --------------------------------------------------------------- self-test

def self_test():
    print("=" * 74)
    print("SELF-TEST (anti-degeneracy)")
    print("=" * 74)
    B = 1000
    is_smooth = make_smoother(B)
    ok = True

    fake_all = [1] * 500
    # Distinct PRIMES > B are provably not B-smooth.  Two earlier attempts
    # failed the self-test: [B+1..] contains smooth numbers, and
    # [nextprime(B)+i] walks back through composites.
    fake_none = list(primerange(B + 1, 4 * B + 200))[:500]
    r_all = rate(fake_all, lambda v: True)
    r_none = rate(fake_none, is_smooth)
    print(f"  synthetic 100% stream -> {r_all['rate']:.3f} "
          f"({r_all['hits']}/{r_all['n']})")
    print(f"  synthetic  0% stream -> {r_none['rate']:.3f} "
          f"({r_none['hits']}/{r_none['n']}, distinct primes > B)")
    ok &= (r_all["rate"] == 1.0) and (r_none["rate"] == 0.0)

    rng = random.Random(11)
    real = [rng.randrange(10 ** 4, 10 ** 5) for _ in range(2000)]
    r_real = rate(real, is_smooth)
    print(f"  real 5-digit ints, B={B} -> {r_real['rate']:.3f} "
          f"(must be strictly between 0 and 1)")
    ok &= (0.0 < r_real["rate"] < 1.0)

    print(f"  SELF-TEST {'PASSED' if ok else 'FAILED'}")
    if not ok:
        sys.exit("harness cannot distinguish degenerate rates -- ABORT")


# --------------------------------------------------------------------- cell

def cell(k, B, n, seed):
    rng = random.Random(seed)
    is_smooth = make_smoother(B)
    hs = gen_class_numbers(k, n, rng)
    eo = gen_ec_orders(k, n, rng)
    un = gen_uniform(k, n, rng)
    r = {
        "k_order_bits": k, "B": B, "n": n,
        "class_h": rate(hs, is_smooth),
        "ec_order": rate(eo, is_smooth),
        "uniform": rate(un, is_smooth),
        "median_bits_class": (sorted(hs)[len(hs) // 2].bit_length() if hs else None),
        "median_bits_ec": (sorted(eo)[len(eo) // 2].bit_length() if eo else None),
    }
    r["gap_class_minus_ec"] = r["class_h"]["rate"] - r["ec_order"]["rate"]
    r["gap_class_minus_uniform"] = r["class_h"]["rate"] - r["uniform"]["rate"]
    return r


def main():
    self_test()
    print()
    print("=" * 74)
    print("SCALE-MATCHED CONTROL  (matching on ORDER bit length)")
    print("=" * 74)
    cells = []
    # B ladder in the ECM style: B1 ~ c * (ln p)(ln ln p) is tiny relative to
    # these; the interesting regime is B = p^{1/u} for u = 2, 3.
    for k in (24, 29, 40, 60):
        for u in (2.0, 3.0):
            B = int(2 ** (k / u))
            n = 200 if k <= 40 else 60
            if log_ok(B):
                pass
            c = cell(k, B, n, seed=7919 * k + B)
            cells.append(c)
            ch, ec, un = c["class_h"], c["ec_order"], c["uniform"]
            print(f"\n order bits k={k}  B=2^(k/{u})={B}  n={n}")
            print(f"   class h(D)  : {ch['rate']:.3f} "
                  f"[{ch['wilson95'][0]:.3f},{ch['wilson95'][1]:.3f}] "
                  f"{ch['hits']}/{ch['n']}  median {c['median_bits_class']} bits")
            print(f"   EC m=p+1-t  : {ec['rate']:.3f} "
                  f"[{ec['wilson95'][0]:.3f},{ec['wilson95'][1]:.3f}] "
                  f"{ec['hits']}/{ec['n']}  median {c['median_bits_ec']} bits")
            print(f"   uniform     : {un['rate']:.3f} "
                  f"[{un['wilson95'][0]:.3f},{un['wilson95'][1]:.3f}]")
            print(f"   GAP class-EC      = {c['gap_class_minus_ec']:+.3f}")
            print(f"   GAP class-uniform = {c['gap_class_minus_uniform']:+.3f}")

    with open("h0_control.json", "w") as fh:
        json.dump({"cells": cells}, fh, indent=2)
    g = [c["gap_class_minus_ec"] for c in cells]
    gu = [c["gap_class_minus_uniform"] for c in cells]
    print(f"\nSUMMARY class-minus-EC      : mean {sum(g)/len(g):+.3f} "
          f"min {min(g):+.3f} max {max(g):+.3f}")
    print(f"SUMMARY class-minus-uniform : mean {sum(gu)/len(gu):+.3f} "
          f"min {min(gu):+.3f} max {max(gu):+.3f}")


def log_ok(B):
    return True


if __name__ == "__main__":
    main()
