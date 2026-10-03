#!/usr/bin/env python3
"""
V1: INDEPENDENT RE-RUN OF E-7.

E-7 claims: P(|Cl(Q(sqrt(-q)))| is B-smooth) = 0.400 vs "0.320 EC baseline",
milestone PASSED, for q = random primes = 3 mod 4.

The committed artifact (Experiments/e7_results.json) is a single line:
    {"n": 25, "p_linked_smooth": 0.4, "ec_smooth": 0.32}
There is NO harness script anywhere in git history, so B, the bit-length of
h(-q), the bit-length of the EC orders, and the RNG seed are all UNRECORDED.

This script reconstructs the experiment from scratch with full disclosure of
every parameter, and runs the TWIN CONTROL: the same measurement with the EC
arm at MATCHED ORDER BIT-LENGTH (not matched parameter value).

EARNED RULE APPLIED: a control that only runs at the parameter you derived it at
is not a control. Here the derived parameter is h(-q) ~ sqrt(q)/pi, so a control
at "matched q" would be at HALF the order bit-length. We run both scales.

DESIGN
------
arms:
  A "class"  : D = -q, q prime = 3 (mod 4). h = qfbclassno(-q).  h is ODD.
  B "ec"     : p prime. random curve E: y^2 = x^3 + ax + b over F_p.
                N = #E(F_p) = ellcard.  N is even or odd ~ 50/50.

Both arms bucketed into the SAME order-bit-length band [2^L, 2^(L+1)).

Smoothness is scored two ways -- this is the crux:
  (i)  whole-order:  P(order is B-smooth).  This is what E-6c/E-7 report.
  (ii) odd-part:     P(oddpart(order) is B-smooth).  Odd parts are
                      intrinsically more B-smooth (no factor of 2), so (ii)
                      is the fair, parity-matched comparison AND it is what ECM
                      actually consumes.

B is set from a FIXED u = log(order)/log(B), so both arms use the SAME relative
bound. That is the standard ECM smoothness parameterisation and is the only way
to compare two families of different absolute sizes at all.

Outputs JSON to e7_results_v1.json.
"""
import json, math, random, sys, time
from fractions import Fraction

import cypari2
from sympy import primerange, factorint

P = cypari2.Pari()

# ---------------------------------------------------------------- utilities
def is_prime(n):
    return P.isprime(n)

def bitlen(x):
    return int(x).bit_length()

def prime_le(B):
    return list(primerange(2, B + 1))

_SIEVE = [None]          # one sieve, grown once to the largest B needed
_SIEVE_MAX = 1

def primes_upto(B):
    """cached sieve, monotonically grown -- NOT re-run per distinct B"""
    global _SIEVE, _SIEVE_MAX
    if B > _SIEVE_MAX:
        _SIEVE = prime_le(B)
        _SIEVE_MAX = B
    return _SIEVE

def is_smooth(n, B):
    """True iff n has no prime factor > B.

    The cached sieve may be LONGER than B, so the loop must stop at B:
    testing divisibility by a prime q > B would divide it out and wrongly
    certify n as smooth.  (Caught by selftest_e7.py.)
    """
    n = int(n)
    if n <= 1:
        return True
    for q in primes_upto(B):
        if q > B or q * q > n:
            break
        while n % q == 0:
            n //= q
        if n == 1:
            return True
    # n is now 1, or a number whose least prime factor is > B
    return n <= B


def oddpart(n):
    n = int(n)
    while n % 2 == 0:
        n //= 2
    return n

# ---------------------------------------------------------------- arms
def sample_class_orders(L, n_want, rng, budget_s):
    """Return list of h(-q) with q prime = 3 mod 4, band [2^L, 2^(L+1))."""
    lo, hi = 1 << L, 1 << (L + 1)
    # h(-q) ~ sqrt(q)*L(1,chi)/pi  =>  q ~ (pi*h)^2 * (pi/L)^2  ~ (3*h)^2
    qlo = int(4 * lo * lo) + 11
    qhi = int(4 * hi * hi) + 11
    out = []
    t0 = time.time()
    tries = 0
    while len(out) < n_want and time.time() - t0 < budget_s:
        q = rng.randrange(qlo, qhi) | 1
        if q % 4 != 3:
            q += 2
        tries += 1
        if not P.isprime(q):
            continue
        try:
            h = int(P.qfbclassno(-q))
        except Exception:
            continue
        if lo <= h < hi:
            out.append((q, h))
    return out, tries, time.time() - t0

def sample_ec_orders(L, n_want, rng, budget_s):
    """Return list of (#E(F_p), p) for random curves, band [2^L, 2^(L+1))."""
    lo, hi = 1 << L, 1 << (L + 1)
    out = []
    t0 = time.time()
    tries = 0
    while len(out) < n_want and time.time() - t0 < budget_s:
        p = rng.randrange(lo, hi) | 1
        if p < 3 or not P.isprime(p):
            continue
        tries += 1
        a = rng.randrange(0, p)
        b = rng.randrange(0, p)
        if (4 * a * a * a + 27 * b * b) % p == 0:
            continue
        try:
            E = P.ellinit([0, 0, 0, a, b], p)
            card = int(P.ellcard(E))
        except Exception:
            continue
        out.append((card, p))
    return out, tries, time.time() - t0

# ---------------------------------------------------------------- stats
def wilson(k, n):
    """Wilson score interval for a binomial proportion, 95%."""
    if n == 0:
        return (0.0, 1.0)
    z = 1.959963985
    ph = k / n
    denom = 1 + z * z / n
    c = (ph + z * z / (2 * n)) / denom
    h = z * math.sqrt(ph * (1 - ph) / n + z * z / (4 * n * n)) / denom
    return (max(0.0, c - h), min(1.0, c + h))

def fisher_two_sided(k1, n1, k2, n2, iters=200000, seed=12345):
    """Fisher exact two-sided p for the 2x2 table. Deterministic."""
    rng = random.Random(seed)
    def hyper(k):
        # p = sum over tables at least as extreme as observed (in prob<=0.05)
        tot = 0.0
        row1, col1 = n1, k1 + k2
        N = n1 + n2
        for k in range(0, min(n1, col1) + 1):
            k2c = col1 - k
            if k2c < 0 or k2c > n2:
                continue
            p = (math.comb(row1, k) * math.comb(N - row1, col1 - k)
                 / math.comb(N, col1))
            pk1 = k1
            # observed prob at (k1, k2)
            def prob(x):
                y = col1 - x
                if x < 0 or x > row1 or y < 0 or y > N - row1:
                    return 0.0
                return math.comb(row1, x) * math.comb(N - row1, y) / math.comb(N, col1)
            if p <= prob(k1) + 1e-15:
                tot += p
        return tot
    return hyper(0)

# ---------------------------------------------------------------- main
def measure(L, n_want, us, seed, budget_s, tag):
    rng = random.Random(seed)
    cls, ct, ctime = sample_class_orders(L, n_want, rng, budget_s)
    ecs, et, etime = sample_ec_orders(L, n_want, rng, budget_s)
    rec = {
        "tag": tag, "L_order_bits": L,
        "band": [L, L + 1],
        "n_class": len(cls), "n_ec": len(ecs),
        "class_q_range_bits": [bitlen(cls[0][0]) if cls else None,
                               bitlen(cls[-1][0]) if cls else None],
        "ec_p_range_bits": [bitlen(ecs[0][1]) if ecs else None,
                            bitlen(ecs[-1][1]) if ecs else None],
        "seconds": [round(ctime, 1), round(etime, 1)],
        "u_sweep": {},
    }
    # max B needed
    maxB = max([int(x[1]) for x in cls] + [int(x[0]) for x in ecs])
    rec["max_order"] = maxB
    for u in us:
        row = {}
        # per-sample B = order**(1/u); score whole-order and oddpart
        ck_w = cw = 0
        ek_w = ew = 0
        ck_o = eo = 0
        Bmin, Bmax = None, None
        for q, h in cls:
            B = max(2, int(round(math.pow(h, 1.0 / u))))
            Bmin = B if Bmin is None else min(Bmin, B)
            Bmax = B if Bmax is None else max(Bmax, B)
            cw += is_smooth(h, B)
            ck_o += is_smooth(oddpart(h), B)
        for card, p in ecs:
            B = max(2, int(round(math.pow(card, 1.0 / u))))
            Bmin = B if Bmin is None else min(Bmin, B)
            Bmax = B if Bmax is None else max(Bmax, B)
            ew += is_smooth(card, B)
            eo += is_smooth(oddpart(card), B)
        nc, ne = len(cls), len(ecs)
        row["B_range"] = [Bmin, Bmax]
        row["class_whole"] = [ck_w, nc, cw / nc if nc else None]
        row["ec_whole"] = [ew, ne, ew / ne if ne else None]
        row["class_oddpart"] = [ck_o, nc, ck_o / nc if nc else None]
        row["ec_oddpart"] = [eo, ne, eo / ne if ne else None]
        row["class_parity"] = [sum(1 for _, h in cls if h % 2 == 0), nc]
        row["ec_parity"] = [sum(1 for c, _ in ecs if c % 2 == 0), ne]
        if nc and ne:
            row["fisher_whole"] = fisher_two_sided(ck_w, nc, ew, ne)
            row["fisher_oddpart"] = fisher_two_sided(ck_o, nc, eo, ne)
            row["wilson_class_whole"] = [round(x, 4) for x in wilson(ck_w, nc)]
            row["wilson_ec_whole"] = [round(x, 4) for x in wilson(ew, ne)]
        rec["u_sweep"][str(u)] = row
        print(f"  [{tag}] u={u}: class_whole={ck_w}/{nc}={cw/nc if nc else 0:.3f} "
              f"ec_whole={ew}/{ne}={ew/ne if ne else 0:.3f} | "
              f"class_odd={ck_o}/{nc} ec_odd={eo}/{ne} | B in [{Bmin},{Bmax}]",
              flush=True)
    return rec, cls, ecs


if __name__ == "__main__":
    L = int(sys.argv[1]) if len(sys.argv) > 1 else 29
    N = int(sys.argv[2]) if len(sys.argv) > 2 else 60
    BUD = float(sys.argv[3]) if len(sys.argv) > 3 else 240.0
    US = [1.5, 2.0, 2.5, 3.0]
    print(f"V1 E-7 audit: L={L} order bits, n_target={N}, budget {BUD}s", flush=True)
    rec, cls, ecs = measure(L, N, US, seed=20261003, budget_s=BUD,
                            tag=f"matched-L{L}")
    out = {"experiment": "V1 independent re-run of E-7",
           "claim_under_test": "class 0.400 vs EC 0.320, milestone PASSED",
           "note": "no harness existed in git; B/scale/seed unrecorded in the claim",
           "runs": [rec]}
    with open("e7_results_v1.json", "w") as f:
        json.dump(out, f, indent=1)
    print("wrote e7_results_v1.json")