"""
s2core -- hardened core for round 49 (agent U): can Stange's alpha_t bias be
exploited to BEAT the 0.75 baseline, or is the index causally irrelevant?

REUSES r48's validated implementation (/home/raver1975/lean/factor-scratch/r48/
exp/stange/stange.py) rather than rewriting it. Everything here is additive:
the sampler, kernel-over-Q, primitive() and factor_from_multiple are imported
from there so that the five defects that agent's self-test caught cannot be
reintroduced by a re-implementation.

-------------------------------------------------------------------------------
PREREGISTRATION -- written 2026-10-03, BEFORE any measurement below.
Nothing in this file's experiment drivers may be tuned after these are set.
-------------------------------------------------------------------------------
PREREG-0 (baseline)  The r48 kill configuration reproduces a per-attempt factor
                     rate of 0.70-0.85 (reported total 181/240 = 0.754).
                     FAILURE => stop the round.

PREREG-1 (H1)        A small-prime-valuation-BIASED relation selection raises
                     the per-attempt factor rate ABOVE 0.85 (i.e. at least +0.10
                     over the 0.75 baseline, and outside the baseline's own
                     binomial 95% band).

PREREG-2 (H2a)       P(success | max_t v2(alpha_t) >= 1)  >=
                     1.20 * P(success | max_t v2(alpha_t) == 0).

PREREG-3 (H2b)       P(success) is MONOTONE INCREASING in h.  Falsified if the
                     trend coefficient is <= 0 or if P(succ | h>=2) <=
                     P(succ | h==1).

PREREG-4 (H3)        A small-prime smoothness sieve cuts WALL-CLOCK cost per
                     successful factor by >= 2x versus exhaustive trial division
                     at equal success rate.

PREREG-5 (H4)        The per-attempt factor rate at n ~ 2^60 is >= 0.70, i.e.
                     no decay beyond the 2^40 measurement's 0.750.  A decay of
                     >= 0.10 between 2^40 and 2^60 is recorded as decay.

PREREG-6 (COST)      THE KEY STRUCTURAL PREDICTION.  Because
                     factor_from_multiple() strips G down to ord(g) exactly, the
                     index h = G/ord(g) is stripped away and cannot cause a
                     factoring failure.  Therefore: the per-attempt success rate
                     is FLAT in c (|P(c) - P(c=10)| <= 0.10), while
                     relation-spend per attempt is b+c.  CONSEQUENCE PREREGISTERED
                     NOW: cost per successful factor is minimised at the SMALLEST
                     workable c, giving a ~1.5-2x reduction versus c=10 at
                     IDENTICAL success rate.
"""

from __future__ import annotations

import math
import random
import sys
import time
from math import gcd

R48 = "/home/raver1975/lean/factor-scratch/r48/exp/stange"
if R48 not in sys.path:
    sys.path.insert(0, R48)

# ---- reused, validated primitives (do NOT re-implement) ---------------------
from stange import (  # noqa: E402
    alg22, bbound_for_b, build_M, factor_base, factor_from_multiple,
    fb_exponents, find_relations, gen_semiprime, index_S_full, kernel_basis,
    order_mod_n, primitive, zeta,
)
from sympy import nextprime, primerange  # noqa: E402
from sympy.ntheory import n_order  # noqa: E402

PRIMES_CACHE: dict[int, list[int]] = {}


def primes_upto(y: int) -> list[int]:
    if y not in PRIMES_CACHE:
        PRIMES_CACHE[y] = list(primerange(2, y + 1))
    return PRIMES_CACHE[y]


def jacobi(a: int, n: int) -> int:
    """The Jacobi symbol (a/n) for odd n > 0, WITHOUT factoring n.

    THE BUG THIS REPLACES, recorded because it is a general hazard:
        pow(g, (n-1)//2, n) == n-1
    is Euler's criterion, which equals the Jacobi symbol ONLY when n is
    PRIME.  For n = p*q it never holds, so a sampler conditioned on it spins
    forever -- I lost ~40 minutes of a run to exactly this, and it would have
    silently removed the arm entirely had it been bounded instead of infinite.
    """
    a %= n
    if n <= 0 or n % 2 == 0:
        raise ValueError("jacobi needs odd positive n")
    result = 1
    while a:
        while a % 2 == 0:
            a //= 2
            if n % 8 in (3, 5):
                result = -result
        a, n = n, a
        if a % 4 == 3 and n % 4 == 3:
            result = -result
        a %= n
    return result if n == 1 else 0


def v_p(x: int, p: int) -> int:
    if x == 0:
        return 99
    e = 0
    x = abs(x)
    while x % p == 0:
        x //= p
        e += 1
    return e


# ---------------------------------------------------------------------------
# the relation-sampler, with a SIEVE variant (H3)
# ---------------------------------------------------------------------------

def find_relations_sieve(n, g, FB, need, rng, Z=None, max_mult=None):
    """H3, the ONLY sieve form that is SOUND for this sampler.

    Two wrong forms were written and rejected before this one; both are worth
    recording because they are the general hazard:

    (i)  Sieve with primes l <= Y, testing "r mod l is Y-smooth".  This is a
         NO-OP: a residue u mod l with l <= Y satisfies u < l <= Y and is
         therefore trivially Y-smooth, so it rejects nothing.  Caught by the
         self-test's efficiency readout (survival 7978/7978 = 1.000).

    (ii) Sieve with primes Y < l <= BB, again testing "r mod l is Y-smooth".
         This is UNSOUND.  r FB-smooth does NOT imply r mod l is Y-smooth:
         r is a product of small primes but r - k*l is not.  Caught by T5 as
         18 false rejects out of 60 genuinely FB-smooth candidates.  This is
         also the structural obstruction, and it is why H3 fails:

             in NFS the sieved quantity is LINEAR in the sieved variable
             (r = a - x mod q), so r mod l is linear in x mod l, ONE sieve
             value per prime amortizes over a whole bucket;
             here r = g^x mod n is EXPONENTIAL in x, so r mod l =
             g^(x mod ord_l(g)) mod l -- it must be recomputed for every
             candidate, at the cost of an exponentiation.  The amortization
             that makes NFS sieving pay is exactly what is missing.

    The sound form: r is FB-smooth => no prime in (BB, Z] divides r, so
    gcd(r, primorial(BB,Z]) = 1 is NECESSARY.  One gcd rejects a candidate.
    This does not need r mod l for pre-computable l, so it buys nothing --
    it is measured here only to document the null empirically.
    """
    BB = FB[-1]
    if Z is None:
        Z = BB * 16
    if max_mult is None:
        max_mult = 200
    PZ = 1
    for l in primes_upto(Z):
        if l > BB:
            PZ *= l
    rels, seen = [], set()
    trials = sieved = 0
    while len(rels) < need:
        trials += 1
        if trials > max_mult * max(need, 1) * 2000 + 4_000_000:
            raise RuntimeError("relation finding stalled (sieve)")
        x = rng.randrange(1, n)
        if x in seen:
            continue
        r = pow(g, x, n)
        sieved += 1
        if gcd(r, PZ) != 1:
            continue
        exps, rem = fb_exponents(r, FB)
        if rem == 1:
            seen.add(x)
            rels.append((exps, x))
    return rels, trials, sieved


# ---------------------------------------------------------------------------
# one Algorithm-2.2 attempt, instrumented
# ---------------------------------------------------------------------------

def strip_bounded(G, g, n, Y=200000):
    """Reduce a multiple G of ord(g) down to M' = ord(g)*s with s ODD, using
    only trial division by primes <= Y -- no factorint() of a huge number.

    WHY THIS IS ENOUGH (and it is what unlocks the c=1 cost reduction):
    after the loop, G' = ord(g) * s with s odd, because every prime <= Y is
    fully stripped (2 included) and any prime factor of the remaining
    cofactor is > Y, hence odd.  Then
        g^(G'/2) = g^(ord*s/2) = (g^(ord/2))^s = g^(ord/2)      [s odd]
    because g^(ord/2) is a square root of unity modulo n, of order <= 2.  So
    the gcd computed from G' is IDENTICAL to the gcd computed from ord(g)
    itself.  If ord(g) is odd then G' is odd and no factor exists -- which is
    the correct answer, matching the full stripper.

    Self-test T8 checks this against factor_from_multiple on real instances.
    """
    M = abs(int(G))
    if M == 0:
        return 0
    for l in primes_upto(Y):
        while M % l == 0:
            h = M // l
            if pow(g, h, n) != 1:
                break
            M = h
    return M


def factor_from_bounded(G, g, n, Y=200000):
    """Same as stange.factor_from_multiple but using the bounded stripper."""
    M = strip_bounded(G, g, n, Y)
    if M == 0 or M % 2 == 1:
        return None
    v = pow(g, M // 2, n)
    f = gcd(v - 1, n)
    if 1 < f < n:
        return f
    f = gcd(v + 1, n)
    if 1 < f < n:
        return f
    return None


def alpha_stats(alphas):
    """max_t v2(alpha_t), max_t v3(alpha_t), and the gcd-normalised h."""
    nz = [abs(a) for a in alphas if a != 0]
    mx2 = max((v_p(a, 2) for a in nz), default=0)
    mx3 = max((v_p(a, 3) for a in nz), default=0)
    any2 = sum(1 for a in nz if a % 2 == 0)
    any3 = sum(1 for a in nz if a % 3 == 0)
    return {"maxv2": mx2, "maxv3": mx3, "n2": any2, "n3": any3, "nalpha": len(nz)}


def attempt(n, p, q, g, FB, c, rng, sieve=0, vmod=None, strip="full"):
    """Full Algorithm 2.2 attempt. vmod (optional callable) scores a relation
    BEFORE accepting it: relations with vmod((exps, x)) < 0 are REJECTED. That
    is the H1 biasing knob; vmod=None reproduces the unbiased baseline."""
    b = len(FB)
    if sieve:
        rels, trials, sieved = find_relations_sieve(n, g, FB, b + c, rng, Y=sieve)
    elif vmod is None:
        rels, trials = find_relations(n, g, FB, b + c, rng, "random")
        sieved = trials
    else:
        rels, seen, trials = [], set(), 0
        while len(rels) < b + c:
            trials += 1
            if trials > 40_000_000:
                raise RuntimeError("stalled (vmod)")
            x = rng.randrange(1, n)
            if x in seen:
                continue
            r = pow(g, x, n)
            exps, rem = fb_exponents(r, FB)
            if rem != 1:
                continue
            sc = vmod((exps, x))
            if sc < 0:
                continue
            seen.add(x)
            rels.append((exps, x))
        sieved = trials
    Mrows = build_M(rels, b)
    K, rank = kernel_basis(Mrows)
    xs = [rels[j][1] for j in range(len(rels))]
    betas = [sum(primitive(v)[j] * xs[j] for j in range(len(rels)))
             for v in K[:c]]
    G = 0
    for a in betas:
        G = gcd(G, abs(a))
    og = order_mod_n(g, n, p, q)
    assert G == 0 or G % og == 0, "p.4 correctness: ord(g) divides every alpha_t"
    if strip == "full":
        fac = factor_from_multiple(G, g, n) if G else None
    else:
        fac = factor_from_bounded(G, g, n) if G else None
    h = (G // og) if (G and G % og == 0) else None
    out = {"n": n, "g": g, "b": b, "c": c, "G": G, "ord_g": og, "h": h,
           "factor": fac, "trials": trials, "sieved": sieved,
           "rels": b + c, "rank": rank, "dimK": len(K), "strip": strip,
           "ok": fac in (p, q)}
    out.update(alpha_stats(betas))
    # NORMALISED alpha_t -- the quantity Hypothesis 3.1 actually models.
    # r48 reported "the alpha_t are 4-5x over 2-divisible".  But EVERY alpha_t
    # is a multiple of ord(g), and ord(g) is even with probability 8/9, so the
    # RAW alpha_t are divisible by 2 almost always for a reason that has
    # nothing to do with the alpha_t/ord(g) the hypothesis is about.  The
    # normalised values remove that confound; both are reported.
    na = [a // og for a in betas if a]
    nst = alpha_stats(na) if na else {"maxv2": 0, "maxv3": 0}
    out["norm_maxv2"] = nst["maxv2"]
    out["norm_maxv3"] = nst["maxv3"]
    nz = [abs(a) for a in betas if a]
    out["raw_frac2"] = sum(1 for a in nz if a % 2 == 0) / max(len(nz), 1)
    out["raw_frac3"] = sum(1 for a in nz if a % 3 == 0) / max(len(nz), 1)
    out["norm_frac2"] = (sum(1 for a in na if a % 2 == 0) / len(na)) if na else 0.0
    out["norm_frac3"] = (sum(1 for a in na if a % 3 == 0) / len(na)) if na else 0.0
    out["norm_n"] = len(na)
    return out


def rand_g(n, rng):
    g = rng.randrange(2, n)
    while gcd(g, n) != 1:
        g = rng.randrange(2, n)
    return g


def prereg_dump():
    print(__doc__)