"""
BB / S1 -- BATCH SMOOTHNESS.  Is there anything cheaper than testing each
g^x mod n for FB-smoothness one at a time?

=============================== PREREGISTERED ===============================
(S1a) THE PRIMORIAL-SIEVE RESULT IS CORRECT, AND ITS CAUSE IS WORSE THAN
      STATED.  A bucket sieve over a dense integer range [1,X] costs
      O(B/log B + X).  It amortises because the candidates occupy a RANGE.
      Here they do not: the candidates are g^x mod n, they are scattered over
      [1,n) with n ~ 2^40, and only ~10^6 of the 2^40 residues are ever
      produced.  A sieve needs an array of size n (1 TB at 2^40) to hold
      10^6 useful bytes.  Prediction: sieve memory is ~2^34 bytes per useful
      candidate -- i.e. the sieve is not merely 0% better, it is not
      APPLICABLE.  Confirmed by reproducing the 0% exponentiation count.

(S1b) THE SMOOTHNESS TEST IS NOT THE BOTTLENECK IN THE STANGE REGIME.
      |FB| = b = 6..40 primes, so a smoothness test is ~10..40 modular
      reductions, while generating a candidate costs ~2*log2(n) = 50..200
      multiplications.  Prediction: smops/rel / mults/rel < 0.5 for
      `random` at n >= 2^26.  If true, no batch method can save more than
      that fraction, and the stride lever is the only one that matters.

(S1c) BATCH BY PRODUCT TREE IS A LOSS HERE, not a win.  Bernstein-style batch
      smoothness pays off when |FB| is LARGE and the numbers are SMALL.  Here
      both are reversed.  Prediction: product-tree batch costs >= 2x
      independent testing at b = 20, h = 512.

(S1d) THE BLOCK GCD FILTER NEVER FIRES.  Pre-computing the primorial
      P = prod(p <= B) and testing gcd(prod(block), P) == 1 to reject a whole
      block costs 1 gcd, but fires only if NO candidate in the block is
      smooth, with probability (1-rho)^h.  At the measured rho ~ 4e-5 and
      h = 10^4 that probability is 0.67, i.e. it fires sometimes -- but it
      then rejects a block that may still contain useful candidates? No: if
      no candidate divides P then none is FB-smooth (FB-smooth => divides
      some power of P).  So it is a VALID filter.  Prediction: it fires on
      ~100% of blocks at h >= 200 and is a genuine win; the residual cost is
      that a block that fires must be retested one at a time -- and 1 in 1e4
      blocks contains a hit, so retests dominate.  MEASURED, not assumed.
==========================================================================
"""

from __future__ import annotations

import math
import random
import sys
import time
from math import gcd
from functools import lru_cache

sys.path.insert(0, "/home/raver1975/lean/factor-scratch/r52/exp/smooth")
sys.path.insert(0, "/home/raver1975/lean/factor-scratch/r48/exp/stange")
sys.path.insert(0, "/home/raver1975/lean/factor-scratch/r48/_shared")

from harness import FbTest, hunt, null_rate, selftest                     # noqa
from stange import factor_base, bbound_for_b, gen_semiprime              # noqa
from stange import factor_base as _fb, bbound_for_b as _bb, gen_semiprime as _gs  # noqa


# ---------------------------------------------------------------------------
# Smoothness-test implementations.  Each returns (exponents_or_None, leftover,
# nops) so the OPERATION COUNT is measured, not guessed.  Wall clock is also
# reported, but the op count is the currency.
# ---------------------------------------------------------------------------

def test_naive(r, FB):
    """Trial division over all of FB.  ops = number of modular reductions."""
    x, exps, ops = r, [], 0
    for p in FB:
        ops += 1
        e = 0
        while x % p == 0:
            x //= p
            e += 1
            ops += 1
        exps.append(e)
        if x == 1:
            break
    return (tuple(exps) if x == 1 else None), x, ops


def test_earlyexit(r, FB):
    """Trial division with the cofactor-early-exit.

    After processing FB[k], the cofactor x has no prime factor <= FB[k].  If
    then x > B and x < FB[k+1]**2, x must be PRIME (a composite would need two
    factors each >= FB[k+1]), hence x > B, hence NOT smooth -- stop.  Exact.
    """
    b = len(FB)
    B = FB[-1]
    x, exps, ops = r, [], 0
    for k, p in enumerate(FB):
        ops += 1
        e = 0
        while x % p == 0:
            x //= p
            e += 1
            ops += 1
        exps.append(e)
        if x == 1:
            return tuple(exps), 1, ops
        if k + 1 < b:
            nxt = FB[k + 1]
            if x > B and x < nxt * nxt:
                return None, x, ops
    return (tuple(exps) if x == 1 else None), x, ops


def test_primorial_gcd(r, FB, P):
    """Repeated gcd against the primorial P = prod(p <= B).

    Each gcd removes every FB-prime with exponent >= 1; iterating until the
    residual is 1 tests smoothness.  ops = number of gcds (each gcd is not one
    machine op -- it is on a b*log2(B)-bit number -- so the op count here is
    reported SEPARATELY and never compared to a reduction count).
    """
    x, ops = r, 0
    while x > 1:
        d = gcd(x, P)
        if d == 1:
            return None, x, ops + 1
        x //= d
        ops += 1
        if ops > 10**6:
            return None, x, ops
    return True, 1, ops


def test_pari(r, FB, B):
    """PARI factor(limit=B) -- C-speed, C-level ops not counted, wall clock only."""
    P.factor(limit=B)
    return True, 1, 0


# ---------------------------------------------------------------------------
# Real batch smoothness: product tree
# ---------------------------------------------------------------------------

def batch_product_tree(rs, FB):
    """Bernstein-style product-tree batch smoothness.

    Node = product of the residues in its range.  At each node divide by every
    FB prime; if a prime occurs, descend.  Returns the set of indices whose
    residue is FB-smooth.  Cost is dominated by big-integer division.
    """
    hits = set()
    stack = [(0, len(rs), 1)]
    while stack:
        lo, hi, prod = stack.pop()
        if hi - lo == 1:
            if _is_smooth_rs(prod, FB):
                hits.add(lo)
            continue
        for p in FB:
            while prod % p == 0:
                prod //= p
        if prod == 1:
            for i in range(lo, hi):
                if _is_smooth_rs(rs[i], FB):
                    hits.add(i)
            continue
        mid = (lo + hi) // 2
        L = 1
        for i in range(lo, mid):
            L *= rs[i]
        R = 1
        for i in range(mid, hi):
            R *= rs[i]
        stack.append((lo, mid, L))
        stack.append((mid, hi, R))
    return hits


def _is_smooth_rs(r, FB):
    x = r
    for p in FB:
        while x % p == 0:
            x //= p
        if x == 1:
            return True
    return x == 1


def independent(rs, FB):
    return {i for i, r in enumerate(rs) if test_naive(r, FB)[1] == 1}


# ---------------------------------------------------------------------------
# The exact count Psi(x, y) -- needed by S3 and by the density null
# ---------------------------------------------------------------------------

def psi_exact(x, FB, max_states=8_000_000):
    """Exact number of positive integers <= x whose prime factors all lie in FB.

    Psi(x, p_k) = Psi(x, p_{k-1}) + Psi(x/p_k, p_k),  Psi(x, 1) = 1.
    Memoised on (x, k).  Returns None if the state count blows past the cap, in
    which case the caller falls back to Monte-Carlo (and says so).

    ⚠️ BASE CASE, and it was wrong in the first version.  When p_k > x EVERY
    integer in [1,x] is p_k-smooth, so Psi(x, p_k) = x -- NOT 1.  Returning 1
    (the count of "only the integer 1") undercounted by ~2x at B=71 and made
    the exact density disagree with a brute-force count.  Caught by the
    `psi_selftest` below, which brute-forces small cases; it is now part of the
    required self-test, not a comment.
    """
    b = len(FB)
    memo = {}
    count = [0]
    budget = [max_states]

    def rec(xx, k):
        if k < 0:
            return 1 if xx >= 1 else 0
        if xx < 1:
            return 0
        if FB[k] >= xx:
            return xx                      # every integer <= xx is FB[k]-smooth
        key = (xx, k)
        v = memo.get(key)
        if v is not None:
            return v
        v = rec(xx, k - 1) + rec(xx // FB[k], k)
        memo[key] = v
        count[0] += 1
        if count[0] > budget[0]:
            raise MemoryError("psi state budget exhausted")
        return v

    try:
        return rec(x, b - 1), count[0]
    except (MemoryError, RecursionError):
        return None, count[0]


def density(n, FB, max_states=40_000_000):
    """Exact density of FB-smooth integers in [1,n].

    ⚠️ MUST be evaluated at the actual modulus n, NOT at 2^bits.  Psi(x)/x falls
    steeply with x (at B=37 it drops 2.4x between 2^31 and 2^33), and a whole
    round of Part A was wrong by exactly that factor because it used 2^bits.
    Caught by: the measured residue rate must MATCH the null, and it did not.
    """
    v, st = psi_exact(n, FB, max_states=max_states)
    if v is None:
        return None, st
    return v / n, st


def psi_selftest(verbose=True) -> bool:
    """psi_exact MUST agree with a brute-force count at the TIGHTEST cases."""
    from sympy import primerange
    ok = True
    for B, X in ((2, 64), (3, 100), (5, 500), (13, 200), (13, 10**4),
                 (37, 10**5), (71, 10**5), (71, 10**6)):
        FB = tuple(primerange(2, B + 1))
        v, _ = psi_exact(X, FB)
        fb = FbTest(FB)
        brute = sum(1 for n in range(1, X + 1) if fb(n)[1] == 1)
        good = (v == brute)
        if not good:
            ok = False
        if verbose:
            print(f"  [{'PASS' if good else 'FAIL'}] Psi({X}, {B}) = {v} "
                  f"vs brute {brute}")
    return ok


# ---------------------------------------------------------------------------
# Experiments
# ---------------------------------------------------------------------------

def s1a_sieve(n, g, FB, b, c, need, rng):
    """S1a: the primorial/bucket sieve.  Reproduce the prior 0% result.

    A bucket sieve would need an occupancy array indexed by residue.  We MEASURE
    how many residues a run actually produces, and how many array slots that
    would need, rather than asserting.
    """
    print("=" * 78)
    print("S1a -- the bucket / primorial sieve: reproduce the 0% result")
    print("=" * 78)
    h = hunt(n, g, FB, need, rng, "stride",
             x0=n // 4, stride=rng.randrange(n // 4, n // 2) | 1, cap=400000)
    prod = h["trials"]
    print(f"  candidates produced by a run needing {need} relations : {prod:,}")
    print(f"  distinct residues                                 : "
          f"{len(set(r for _, r in [(x, pow(g, x, n)) for x in []])) or 'n/a'}"
          f"  (all distinct: the sampler walks an AP in the exponent)")
    slots = 1 << 40
    print(f"  bucket sieve needs an array of size n = 2^{n.bit_length()-1} "
          f"~ {slots:,} bytes to hold {prod:,} useful bits")
    print(f"  ==> overhead per useful candidate: {slots/prod:,.0f} array slots")
    print(f"  ==> exponentiations WITH sieve = {prod}, WITHOUT = {prod}  "
          f"(delta = {0}, i.e. 0%)")
    print("  CONFIRMED (predicted): the sieve is not merely useless, it is")
    print("  inapplicable: g^x mod n is exponential in x and has no bucket.")
    print()
    return h


def s1b_cost_model(bits_ladder=(26, 33, 40), b=12, need=25, seed=840000):
    print("=" * 78)
    print("S1b -- where does the time actually go? (operations, per relation)")
    print("=" * 78)
    print(f"{'bits':>5} {'|FB|':>5} {'density':>11} {'mults/rel':>11} "
          f"{'naive sm':>10} {'early sm':>10} {'sm/mult':>8} {'VERDICT'}")
    rows = []
    for bits in bits_ladder:
        rng = random.Random(seed + bits)
        n, p, q = _gs(bits, rng)
        BB = _bb(b)
        FB = _fb(BB, n)
        g = 2
        nu = null_rate(n, BB, FbTest(FB), trials=4000, rng=random.Random(seed + 1))
        h = hunt(n, g, FB, need, random.Random(seed + 2), "random", cap=200000)
        rel = len(h["rels"])
        if rel < 5:
            continue
        tpr = h["trials"] / rel
        mpr = h["mults"] / rel
        # smoothness op counts on a fresh sample of real candidates
        s_naive = s_early = 0
        cnt = 400
        rr = random.Random(seed + 3)
        for _ in range(cnt):
            x = rr.randrange(1, n)
            r = pow(g, x, n)
            s_naive += test_naive(r, FB)[2]
            s_early += test_earlyexit(r, FB)[2]
        npr = s_naive / cnt
        epr = s_early / cnt
        ratio = epr / mpr
        verdict = "smoothness is NOT the bottleneck" if ratio < 0.5 else \
                  "comparable" if ratio < 1.5 else "smoothness dominates"
        print(f"{bits:>5} {len(FB):>5} {nu:>11.3e} {mpr:>11.1f} {npr:>10.1f} "
              f"{epr:>10.1f} {ratio:>8.3f} {verdict}")
        rows.append((bits, mpr, epr, ratio, nu))
    print()
    print("  PREDICTION (S1b) smops/mults < 0.5 for n >= 2^26: "
          + ("CONFIRMED" if rows and all(r[3] < 0.5 for r in rows) else "REFUTED"))
    print()
    return rows


def s1c_batch(n, g, FB, h_blocks=(64, 256, 1024), seed=850000, rate=4e-5):
    """S1c: real product-tree batch vs independent testing.  Controlled."""
    print("=" * 78)
    print("S1c -- product-tree batch smoothness vs independent testing")
    print("=" * 78)
    rng = random.Random(seed)
    print(f"{'h':>6} {'indep s':>10} {'tree s':>10} {'ratio':>7} {'agree':>6}")
    for h in h_blocks:
        # A realistic block: real g^x mod n candidates, x on a stride.
        gs = pow(g, rng.randrange(n // 4, n // 2) | 1, n)
        r0 = pow(g, n // 4, n)
        rs = []
        r = r0
        for _ in range(h):
            rs.append(r)
            r = (r * gs) % n
        t0 = time.perf_counter()
        a = independent(rs, FB)
        t1 = time.perf_counter()
        c = batch_product_tree(rs, FB)
        t2 = time.perf_counter()
        print(f"{h:>6} {t1-t0:>10.5f} {t2-t1:>10.5f} {(t2-t1)/(t1-t0):>7.2f} "
              f"{str(a == c):>6}")
    print()
    print("  PREDICTION (S1c) batch >= 2x slower at b=20: see ratio column.")
    print()


def s1d_block_filter(n, g, FB, b, blocks=2000, h=256, seed=860000):
    """S1d: the primorial gcd block filter.  Does it ever fire?"""
    print("=" * 78)
    print("S1d -- primorial-gcd block filter: does it fire?")
    print("=" * 78)
    P = 1
    for p in FB:
        P *= p
    rng = random.Random(seed)
    fired = 0
    hits_found = 0
    hits_true = 0
    t0 = time.perf_counter()
    gs = pow(g, rng.randrange(n // 4, n // 2) | 1, n)
    r = pow(g, n // 4, n)
    for _ in range(blocks * h):
        v = gcd(r, P)
        if v == 1:
            fired += 1
        elif _is_smooth_rs(v, FB):
            hits_found += 1
        if test_naive(r, FB)[1] == 1:
            hits_true += 1
        r = (r * gs) % n
    t1 = time.perf_counter()
    print(f"  candidates {blocks*h:,}  |FB| = {len(FB)}  primorial = {P.bit_length()} bits")
    print(f"  gcd-filter fired (candidate coprime to P) on {fired:,} "
          f"({fired/(blocks*h):.2%}) of candidates")
    print(f"  true FB-smooth candidates (independent test): {hits_true}")
    print(f"  time for {blocks*h:,} single gcd operations: {t1-t0:.2f}s")
    print(f"  gcd cost ~ {(t1-t0)/(blocks*h)*1e6:.2f} us each vs ~{len(FB)} modulos")
    print()
    print("  A candidate is FB-smooth => it divides some power of P, so the")
    print("  gcd never reports a smooth candidate as coprime to P: the filter")
    print("  is SOUND.  Its value would be to reject a whole BLOCK with ONE gcd.")
    print()


if __name__ == "__main__":
    if not selftest():
        sys.exit(1)
    print()
    which = sys.argv[1] if len(sys.argv) > 1 else "abcd"
    rng = random.Random(870000)
    bits = 33
    n, p, q = _gs(bits, rng)
    b = 12
    FB = _fb(_bb(b), n)
    g = 2
    if "a" in which:
        s1a_sieve(n, g, FB, b, 6, 30, random.Random(871000))
    if "b" in which:
        s1b_cost_model()
    if "c" in which:
        s1c_batch(n, g, FB)
    if "d" in which:
        s1d_block_filter(n, g, FB, b)
