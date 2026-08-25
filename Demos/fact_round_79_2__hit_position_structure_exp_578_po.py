#!/usr/bin/env python3
"""
exp579B -- PRE-REGISTERED (header written before any data was generated).

DECISIVE TEST OF "BEYOND-MAGNITUDE POSITIONAL STRUCTURE".

Within a single N the sieve value v_N(j) = (m+j)^2 - N (m = isqrt(N)+1) is
STRICTLY INCREASING in j, so position and magnitude are functionally
dependent: any within-N stratification by |v| cuts j into contiguous blocks
and cannot separate the two variables (this is proved in Lean as
`FermatPosition.sizeClass_preimage_ordConnected` / the cell-collapse bound).

The only clean way to break the dependence is ACROSS SCALES: for an 80-bit N
one has v(j) ~ 2^41 * j, for a 96-bit N one has v(j) ~ 2^49 * j.  A value of
size 2^55 therefore sits at position j ~ 2^14 for the small modulus and at
j ~ 2^6 for the large one -- a 256-fold difference in position at MATCHED
magnitude.

PRE-STATED RULE (fixed before running):
  For each shared bin of bitlen(v) with >= 40 hits on both arms, compute the
  hit rate per position on each arm.  Let R = rate(small-j arm) / rate(large-j
  arm) = rate(96-bit N) / rate(80-bit N).
  * POSITIONAL-STRUCTURE-REAL fires iff R > 1.20 in a majority of shared bins
    and the pooled two-proportion z-test gives p < 0.001 in that direction.
  * MAGNITUDE-ONLY fires iff the pooled R lies in [0.9, 1.1] and no bin is
    individually significant at p < 0.001 in either direction.
  * Anything else = INCONCLUSIVE / mixed.

Arms:  A96: 300 balanced 96-bit semiprimes, j in [1, 2048].
       A80:  12 balanced 80-bit semiprimes, j in [1, 300000].
Smoothness: exact, full sieve-and-divide, bound B = 10^6.  Seed 20260830.
"""

import os, sys, json, random
from math import gcd, isqrt

SEED = int(os.environ.get("EXP579B_SEED", 20260830))
B = int(os.environ.get("EXP579B_B", 10**6))
N96 = int(os.environ.get("EXP579B_N96", 300))
J96 = int(os.environ.get("EXP579B_J96", 2048))
N80 = int(os.environ.get("EXP579B_N80", 12))
J80 = int(os.environ.get("EXP579B_J80", 300000))


def sieve(limit):
    bs = bytearray([1]) * (limit + 1)
    bs[0] = bs[1] = 0
    for i in range(2, isqrt(limit) + 1):
        if bs[i]:
            bs[i*i::i] = bytearray(len(bs[i*i::i]))
    return [i for i in range(limit + 1) if bs[i]]


def is_prime(n):
    if n < 2: return False
    for p in (2,3,5,7,11,13,17,19,23,29,31,37):
        if n % p == 0: return n == p
    d, r = n - 1, 0
    while d % 2 == 0: d //= 2; r += 1
    for a in (2,3,5,7,11,13,17,19,23,29,31,37):
        x = pow(a, d, n)
        if x in (1, n-1): continue
        for _ in range(r-1):
            x = x * x % n
            if x == n-1: break
        else:
            return False
    return True


def rand_prime(rng, bits):
    while True:
        p = rng.getrandbits(bits) | (1 << (bits-1)) | 1
        if is_prime(p): return p


def tonelli(n, p):
    n %= p
    if n == 0: return 0
    if pow(n, (p-1)//2, p) != 1: return None
    if p % 4 == 3: return pow(n, (p+1)//4, p)
    q, s = p-1, 0
    while q % 2 == 0: q //= 2; s += 1
    z = 2
    while pow(z, (p-1)//2, p) != p-1: z += 1
    m, c, t, r = s, pow(z, q, p), pow(n, q, p), pow(n, (q+1)//2, p)
    while t != 1:
        i, t2 = 0, t
        while t2 != 1:
            t2 = t2*t2 % p; i += 1
        b = pow(c, 1 << (m-i-1), p)
        m, c = i, b*b % p
        t, r = t*c % p, r*b % p
    return r


PRIMES = sieve(B)


def arm(rng, bits, J, count):
    """Return dict bitlen(v) -> [hits, positions]."""
    acc = {}
    for idx in range(count):
        p = rand_prime(rng, bits//2)
        q = rand_prime(rng, bits//2)
        N = p*q
        m = isqrt(N) + 1
        vals = [0]*(J+1)
        for j in range(1, J+1):
            vals[j] = (m+j)*(m+j) - N
        rem = vals[:]
        for pr in PRIMES:
            if pr == 2:
                roots = [(N - m) % 2]
            else:
                r = tonelli(N % pr, pr)
                if r is None: continue
                roots = {(r - m) % pr, (-r - m) % pr}
            for r0 in roots:
                j = r0 if r0 != 0 else pr
                while j <= J:
                    x = rem[j]
                    while x % pr == 0:
                        x //= pr
                    rem[j] = x
                    j += pr
        for j in range(1, J+1):
            bl = vals[j].bit_length()
            e = acc.setdefault(bl, [0, 0])
            e[1] += 1
            if rem[j] == 1:
                e[0] += 1
        if idx % 25 == 0:
            print(f"  {bits}-bit arm: {idx}/{count}", file=sys.stderr, flush=True)
    return acc


def main():
    rng = random.Random(SEED)
    a96 = arm(rng, 96, J96, N96)
    a80 = arm(rng, 80, J80, N80)
    shared = sorted(set(a96) & set(a80))
    rows = []
    tot = [0, 0, 0, 0]
    for bl in shared:
        h1, n1 = a96[bl]
        h2, n2 = a80[bl]
        if h1 < 40 or h2 < 40:
            continue
        r1, r2 = h1/n1, h2/n2
        rows.append({"bitlen_v": bl, "hits96": h1, "pos96": n1, "rate96": r1,
                     "hits80": h2, "pos80": n2, "rate80": r2,
                     "R": r1/r2 if r2 else None})
        tot[0] += h1; tot[1] += n1; tot[2] += h2; tot[3] += n2
    out = {"seed": SEED, "B": B, "arms": {"n96": N96, "J96": J96,
                                          "n80": N80, "J80": J80},
           "shared_bins": rows,
           "raw96": {str(k): v for k, v in sorted(a96.items())},
           "raw80": {str(k): v for k, v in sorted(a80.items())}}
    if tot[1] and tot[3]:
        p1, p2 = tot[0]/tot[1], tot[2]/tot[3]
        pp = (tot[0]+tot[2])/(tot[1]+tot[3])
        se = (pp*(1-pp)*(1/tot[1] + 1/tot[3]))**0.5
        out["pooled"] = {"rate96": p1, "rate80": p2, "R": p1/p2 if p2 else None,
                         "z": (p1-p2)/se if se else None,
                         "counts": {"h96": tot[0], "n96": tot[1],
                                    "h80": tot[2], "n80": tot[3]}}
    print(json.dumps(out, indent=1))


main()


#!/usr/bin/env python3
"""L0 sanity leg of exp579: the position-gcd law gcd(j, v(j)) = gcd(j, v(0))
checked exhaustively on random balanced semiprimes.  (The law is *proved* in
Catalog/NumberTheory/FermatPositionGeometry.lean; this is an independent check.)"""
import random
from math import gcd, isqrt

def is_prime(n):
    if n < 2: return False
    for p in (2,3,5,7,11,13,17,19,23,29,31,37):
        if n % p == 0: return n == p
    d, r = n-1, 0
    while d % 2 == 0: d //= 2; r += 1
    for a in (2,3,5,7,11,13,17,19,23,29,31,37):
        x = pow(a, d, n)
        if x in (1, n-1): continue
        for _ in range(r-1):
            x = x*x % n
            if x == n-1: break
        else: return False
    return True

def rand_prime(rng, bits):
    while True:
        p = rng.getrandbits(bits) | (1 << (bits-1)) | 1
        if is_prime(p): return p

rng = random.Random(20260829)
bad = 0; checked = 0
for _ in range(40):
    N = rand_prime(rng, 48) * rand_prime(rng, 48)
    m = isqrt(N) + 1
    v0 = m*m - N
    for j in list(range(1, 2000)) + [rng.randrange(1, 150001) for _ in range(2000)]:
        checked += 1
        if gcd(j, (m+j)*(m+j) - N) != gcd(j, v0):
            bad += 1
print(f"L0: checked {checked} (j, N) pairs, violations = {bad}")


#!/usr/bin/env python3
"""
exp579 -- PRE-REGISTERED (this header written before any data was generated).

Context: exp578 reported BEYOND-MAGNITUDE positional structure in the hit
positions of the Fermat/QS sieve polynomial

        v_N(j) = (m + j)^2 - N,     m = isqrt(N) + 1,

i.e. smooth values ("hits") cluster toward small j by more than the pure
size decay of v_N(j) predicts, with monotone-declining u-deciles.

exp579 tests ONE named mechanism as the carrier of that excess:

    THE POSITION-GCD LAW.   v_N(j) - v_N(0) = j*(j + 2m), hence
        gcd(j, v_N(j)) = gcd(j, v_N(0))   for every j,
    and in particular  j | v_N(j)  <=>  j | v_N(0).

    Consequence (the carrier claim): a position j whose gcd g = gcd(j, v0)
    is > 1 carries a *guaranteed* B-smooth factor g of v_N(j) (guaranteed as
    long as g <= B, which holds automatically when j <= B).  Smoothness of
    v_N(j) then only requires smoothness of the smaller cofactor v_N(j)/g.
    This is an ARITHMETIC enrichment invisible to |v_N(j)|, and its density
    in j is 1/j-like: it is exactly the shape of a small-j excess.

PRE-STATED LEGS AND FIRING RULES (fixed before running):

  L0 (sanity, must be exact): gcd(j, v(j)) == gcd(j, v(0)) for all sampled j
      and all N.  Any single failure invalidates the run.

  L1 (carrier, LOCAL-WINDOW magnitude control): partition j in [1,J] into
      consecutive windows of 1000 positions (inside a window v varies by a
      factor < 1.01 for j >= 100k and < 2 everywhere, and we additionally
      report the strict version restricted to j >= J/2 where the within
      window v-ratio is < 1.005).  Compare the hit rate at positions with
      gcd(j,v0) > 1 against positions with gcd(j,v0) = 1 in the SAME window.
      FIRES iff the pooled window-matched rate ratio exceeds 1.10 with a
      two-sided binomial/permutation p < 0.001.

  L2 (dose-response): hit rate as a function of log2(gcd(j,v0)).  FIRES iff
      the rate is monotone non-decreasing across the bins
      g=1, 2<=g<4, 4<=g<16, 16<=g<256, g>=256 and the top bin exceeds the
      g=1 bin by a factor > 1.5.

  L3 (share accounting): what fraction of the small-j excess (decile-1 mass
      above 0.10) is removed when hits are re-weighted by removing the
      guaranteed cofactor, i.e. when the u-KS test is run on the "reduced"
      statistic?  Reported descriptively, no firing rule.

Population: 16 balanced 96-bit semiprimes, seed 20260829 (fresh; independent
of the exp578 seed family).  J = 150000 j-values per N, smoothness bound
B = 10^6, exact smoothness by full sieve-and-divide (no log approximation).
"""

import math, random, json, sys
from math import gcd, isqrt

import os
SEED = int(os.environ.get("EXP579_SEED", 20260829))
NN = int(os.environ.get("EXP579_NN", 16))
BITLEN = int(os.environ.get("EXP579_BITLEN", 96))
J = int(os.environ.get("EXP579_J", 150000))
B = int(os.environ.get("EXP579_B", 10**6))

# ---------- primes ----------
def sieve(limit):
    bs = bytearray([1]) * (limit + 1)
    bs[0] = bs[1] = 0
    for i in range(2, isqrt(limit) + 1):
        if bs[i]:
            bs[i*i::i] = bytearray(len(bs[i*i::i]))
    return [i for i in range(limit + 1) if bs[i]]

def is_prime(n):
    if n < 2: return False
    for p in (2,3,5,7,11,13,17,19,23,29,31,37):
        if n % p == 0: return n == p
    d, r = n - 1, 0
    while d % 2 == 0: d //= 2; r += 1
    for a in (2,3,5,7,11,13,17,19,23,29,31,37):
        x = pow(a, d, n)
        if x in (1, n-1): continue
        for _ in range(r-1):
            x = x * x % n
            if x == n-1: break
        else:
            return False
    return True

def rand_prime(rng, bits):
    while True:
        p = rng.getrandbits(bits) | (1 << (bits-1)) | 1
        if is_prime(p): return p

def tonelli(n, p):
    """sqrt of n mod odd prime p, or None."""
    n %= p
    if n == 0: return 0
    if pow(n, (p-1)//2, p) != 1: return None
    if p % 4 == 3: return pow(n, (p+1)//4, p)
    q, s = p-1, 0
    while q % 2 == 0: q //= 2; s += 1
    z = 2
    while pow(z, (p-1)//2, p) != p-1: z += 1
    m, c, t, r = s, pow(z, q, p), pow(n, q, p), pow(n, (q+1)//2, p)
    while t != 1:
        i, t2 = 0, t
        while t2 != 1:
            t2 = t2*t2 % p; i += 1
        b = pow(c, 1 << (m-i-1), p)
        m, c = i, b*b % p
        t, r = t*c % p, r*b % p
    return r

PRIMES = sieve(B)
print(f"# primes up to {B}: {len(PRIMES)}", file=sys.stderr)

def run_N(N, m):
    """Return (hits, v0, vals) with exact B-smoothness of v(j), j in [1,J]."""
    v0 = m*m - N
    vals = [(m+j)*(m+j) - N for j in range(J+1)]
    rem = vals[:]                      # will be divided down
    for p in PRIMES:
        if p == 2:
            roots = [ (0 if (m*m - N) % 2 == 0 else 1) ]
            # (m+j)^2 = N mod 2  <=>  m+j = N mod 2
            roots = [ (N - m) % 2 ]
        else:
            r = tonelli(N % p, p)
            if r is None: continue
            roots = {(r - m) % p, (-r - m) % p}
        for r0 in roots:
            j = r0
            if j == 0: j = p if p <= J else J+1
            while j <= J:
                x = rem[j]
                while x % p == 0:
                    x //= p
                rem[j] = x
                j += p
    hits = [j for j in range(1, J+1) if rem[j] == 1]
    return hits, v0, vals


def main():
    rng = random.Random(SEED)
    out = {"seed": SEED, "J": J, "B": B, "bitlen": BITLEN, "per_N": []}
    tot_win = {"g1_hit":0, "g1_n":0, "gg_hit":0, "gg_n":0}
    tot_win_hi = {"g1_hit":0, "g1_n":0, "gg_hit":0, "gg_n":0}
    dose_bins = [(1,2),(2,4),(4,16),(16,256),(256,1<<62)]
    dose = [[0,0] for _ in dose_bins]
    deciles = [0]*10
    l0_ok = True
    allhits = 0
    for idx in range(NN):
        p = rand_prime(rng, BITLEN//2)
        q = rand_prime(rng, BITLEN//2)
        N = p*q
        m = isqrt(N) + 1
        hits, v0, vals = run_N(N, m)
        allhits += len(hits)
        # L0
        for j in list(range(1, 200)) + [rng.randrange(1, J+1) for _ in range(300)]:
            if gcd(j, vals[j]) != gcd(j, v0):
                l0_ok = False
        hs = set(hits)
        # L1: window-matched
        for w0 in range(1, J+1, 1000):
            w1 = min(w0+1000, J+1)
            g1h=g1n=ggh=ggn=0
            for j in range(w0, w1):
                if gcd(j, v0) > 1:
                    ggn += 1; ggh += (j in hs)
                else:
                    g1n += 1; g1h += (j in hs)
            if g1n and ggn:
                tot_win["g1_hit"]+=g1h; tot_win["g1_n"]+=g1n
                tot_win["gg_hit"]+=ggh; tot_win["gg_n"]+=ggn
                if w0 > J//2:
                    tot_win_hi["g1_hit"]+=g1h; tot_win_hi["g1_n"]+=g1n
                    tot_win_hi["gg_hit"]+=ggh; tot_win_hi["gg_n"]+=ggn
        # L2 dose
        for j in range(1, J+1):
            g = gcd(j, v0)
            for bi,(lo,hi) in enumerate(dose_bins):
                if lo <= g < hi:
                    dose[bi][1] += 1
                    dose[bi][0] += (j in hs)
                    break
        # deciles of u = j/J
        for j in hits:
            deciles[min(9, (j-1)*10//J)] += 1
        out["per_N"].append({"N": str(N), "v0": str(v0), "hits": len(hits),
                             "frac_j_div_v0": sum(1 for j in range(1,J+1) if v0 % j == 0)})
        print(f"N{idx}: hits={len(hits)}", file=sys.stderr)

    r1 = tot_win["g1_hit"]/tot_win["g1_n"]
    r2 = tot_win["gg_hit"]/tot_win["gg_n"]
    r1h = tot_win_hi["g1_hit"]/tot_win_hi["g1_n"]
    r2h = tot_win_hi["gg_hit"]/tot_win_hi["gg_n"]
    out["L1"] = {"rate_g1": r1, "rate_ggt1": r2, "ratio": r2/r1,
                 "counts": tot_win,
                 "hi_half": {"rate_g1": r1h, "rate_ggt1": r2h, "ratio": r2h/r1h,
                             "counts": tot_win_hi}}
    out["L2"] = [{"bin": f"[{lo},{hi})", "hits": d[0], "n": d[1],
                  "rate": d[0]/d[1] if d[1] else None}
                 for (lo,hi),d in zip(dose_bins, dose)]
    out["deciles"] = [d/allhits for d in deciles]
    out["total_hits"] = allhits
    print(json.dumps(out, indent=1))

main()
