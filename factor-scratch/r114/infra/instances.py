"""
instances.py -- SEEDED instance generator with a HARD non-vacuity guarantee.

    from instances import gen_instance
    inst = gen_instance(nbits=800, small_bits=60, seed=1)
    inst["N"], inst["p"], inst["q"]      # p is the SMALL factor, small_bits wide
    inst["seed_recorded"]                 # reproduce with exactly these args

THE GUARANTEE
-------------
Every instance returned has  small_factor_bits > 2^40  by construction, so no
GIFP / NFS / recombination result built on it can be vacuous for the trivial
reason.  That is the failure that cost r110 its headline.

DETERMINISM
-----------
The seed is (seed, nbits, small_bits, tag) run through SHA-256 to derive a
Python int, and `random.Random` is seeded from THAT.  Two reasons:
  * Python's `hash()` of str/tuple is randomized per process under
    PYTHONHASHSEED.  `random.Random(x.__hash__())` produced two different
    "same-seed" passes in r112 (28/40 vs 33/40).  sha256 is stable.
  * Sage's `set_random_seed` governs Sage's OWN global stream, which other
    scripts mutate; a local `random.Random` cannot be perturbed by them.

NO GIFP REUSE
-------------
This generator is written from scratch and shares NO code with
Experiments/UMWWindow/gifp_ref/gifp.sage, per the r113 addendum "Do not import
or reuse r110-r112 harnesses for a verification claim".  A separate
`gen_gifp_like` below provides the shared-bit shape WITHOUT gifp.sage's known
None-returning generator; it is labelled as a SHAPE, not as the published
construction.
"""
from __future__ import annotations

import hashlib
import json
import random

# r113 addendum: below this a factoring claim is decoration.
MIN_SMALL_BITS = 41          # strictly greater than 2^40


def _rng(seed, nbits, small_bits, tag):
    h = hashlib.sha256(("%d|%d|%d|%s" % (seed, nbits, small_bits, tag)).encode()).digest()
    return random.Random(int.from_bytes(h, "big"))


def gen_instance(nbits=800, small_bits=60, seed=1, tag="plain", blum=False):
    """N = p*q with bitlen(p) == small_bits EXACTLY and bitlen(N) == nbits EXACTLY.

    `small_bits` is the SMALL factor's width -- this is the quantity that
    decides vacuity.  Returns a dict with N, p, q, seed_recorded, and the
    verified bit lengths.
    """
    if small_bits < MIN_SMALL_BITS:
        raise ValueError("small_bits=%d is <= 2^%d; the instance would be VACUOUS "
                         "by construction. Pass small_bits >= %d."
                         % (small_bits, MIN_SMALL_BITS - 1, MIN_SMALL_BITS))
    if small_bits >= nbits:
        raise ValueError("small_bits must be < nbits")
    from sympy import nextprime, isprime

    rng = _rng(seed, nbits, small_bits, tag)
    big_bits = nbits - small_bits
    for _ in range(200):
        p = int(nextprime(rng.randrange(2 ** (small_bits - 1), 2 ** small_bits)))
        q = int(nextprime(rng.randrange(2 ** (big_bits - 1), 2 ** big_bits)))
        if blum:
            while p % 4 != 3:
                p = int(nextprime(p + 2))
            while q % 4 != 3:
                q = int(nextprime(q + 2))
        if p == q:
            continue
        N = p * q
        # EXACT bit lengths, not approximate.  A generator that returns an
        # instance one bit short silently changes alpha and every downstream
        # threshold with it.
        if N.bit_length() != nbits or min(p, q).bit_length() != small_bits:
            continue
        if not (isprime(p) and isprime(q)):
            continue
        assert p * q == N, "GROUND TRUTH FAILURE"
        assert min(p, q).bit_length() > 40, "vacuity guard failed"
        return dict(N=N, p=min(p, q), q=max(p, q),
                    nbits=nbits, small_bits=small_bits,
                    seed_recorded=seed, tag=tag, blum=blum,
                    alpha=small_bits / nbits)


def gen_family(n=12, nbits=800, small_bits=60, seed0=1000, **kw):
    """n DISTINCT seeds.  r113 addendum: >=12 seeds wherever a rate is claimed;
    4 cannot distinguish 0.8 from 0.2."""
    return [gen_instance(nbits=nbits, small_bits=small_bits, seed=seed0 + i, **kw)
            for i in range(n)]


def gen_gifp_like(nbits=800, alpha=0.10, gamma=0.10, beta2=0.20, seed=1,
                  min_small_bits=MIN_SMALL_BITS):
    """Two moduli sharing a high BIT STRING, in the shape gifp.sage builds.

    THIS IS A SHAPE, NOT THE PUBLISHED CONSTRUCTION.  It reproduces the
    parameterisation (p_i = MSB_i * 2^(gamma*n + beta_i*n) + shared * 2^(beta_i*n)
    + ...) but is written independently and is NOT verified to be equivalent to
    gifp.sage's output.  Use gifp_ref/gifp.sage if you need the real thing, and
    check it does not return None.

    GUARANTEE: raises if the resulting small factor would be <= 2^40 bits,
    which for this parameterisation means nbits*alpha must exceed it.
    """
    from sympy import nextprime, isprime
    small_bits = int(round(alpha * nbits))
    if small_bits < MIN_SMALL_BITS:
        raise ValueError("alpha=%g at n=%d gives a %d-bit small factor (<= 2^%d): "
                         "VACUOUS BY CONSTRUCTION. Raise nbits or alpha."
                         % (alpha, nbits, small_bits, MIN_SMALL_BITS - 1))
    beta1 = beta2
    rng = _rng(seed, nbits, small_bits, "gifp_like")
    share_bits = max(1, int(gamma * nbits))
    share = rng.randrange(2 ** (share_bits - 1) + 1, 2 ** share_bits) if share_bits > 1 else 1
    q1 = int(nextprime(rng.randrange(2 ** (small_bits - 1), 2 ** small_bits)))
    q2 = int(nextprime(rng.randrange(2 ** (small_bits - 1), 2 ** small_bits)))

    def mkp(beta):
        """p = MSB*2^(gamma*n+beta*n) + share*2^(beta*n) + 2^(beta*n) - 1 style."""
        b_bits = int(round(beta * nbits))
        head_bits = nbits - small_bits - share_bits - b_bits
        if head_bits < 1:
            return None
        msb = rng.randrange(2 ** (head_bits - 1), 2 ** head_bits)
        lo = msb * 2 ** (share_bits + b_bits) + share * 2 ** b_bits + 2 ** (b_bits - 1)
        hi = msb * 2 ** (share_bits + b_bits) + share * 2 ** b_bits + 2 ** b_bits - 1
        if lo >= hi:
            return None
        p = int(nextprime(rng.randrange(lo, hi)))
        return p if (isprime(p) and p.bit_length() == nbits - small_bits) else None

    for _ in range(200):
        p1 = mkp(beta1)
        p2 = mkp(beta2)
        if not p1 or not q1 or not q2:
            continue
        N1, N2 = p1 * q1, p2 * q2
        if N1.bit_length() != nbits or N2.bit_length() != nbits:
            continue
        return dict(N=N1, p=min(p1, q1), q=max(p1, q1), N2=N2,
                    p1=p1, q1=q1, p2=p2, q2=q2, share=share,
                    nbits=nbits, small_bits=small_bits, alpha=alpha,
                    gamma=gamma, beta1=beta1, beta2=beta2,
                    seed_recorded=seed, shape_only=True)


def repro_line(inst):
    """The exact call that reproduces this instance.  Paste it in a RESULT.md."""
    if inst.get("shape_only"):
        return ("from instances import gen_gifp_like; "
                "gen_gifp_like(nbits=%d, alpha=%r, gamma=%r, beta2=%r, seed=%d)"
                % (inst["nbits"], inst["alpha"], inst["gamma"], inst["beta2"],
                   inst["seed_recorded"]))
    return ("from instances import gen_instance; "
            "gen_instance(nbits=%d, small_bits=%d, seed=%d, tag=%r)"
            % (inst["nbits"], inst["small_bits"], inst["seed_recorded"], inst["tag"]))


if __name__ == "__main__":
    import sys
    print("== TEST 6: generator determinism and the 2^40 guarantee ==")
    a = gen_instance(nbits=800, small_bits=60, seed=42)
    b = gen_instance(nbits=800, small_bits=60, seed=42)
    c = gen_instance(nbits=800, small_bits=60, seed=43)
    print("  seed 42 N bits=%d small=%d bits" % (a["N"].bit_length(), a["p"].bit_length()))
    assert a["N"] == b["N"], "same seed must give same N"
    assert a["N"] != c["N"], "different seed must give different N"
    assert a["N"] == a["p"] * a["q"]
    assert a["p"].bit_length() == 60 and a["N"].bit_length() == 800
    print("  PASS: same seed -> same N, different seed -> different N")
    print("  PASS: exact bit lengths, multiply-back holds, small factor 60 > 40 bits")
    print("  reproduce:", repro_line(a))

    print()
    print("== TEST 6b: the vacuity guard FIRES (asks for a 30-bit small factor) ==")
    try:
        gen_instance(nbits=800, small_bits=30, seed=1)
        raise AssertionError("guard did not fire -- an instance with a 30-bit factor was built")
    except ValueError as e:
        print("  ValueError:", e)
        print("  PASS: vacuous instance refused at construction time")

    print()
    print("== TEST 6c: a 12-seed family, all with small factor > 2^40 ==")
    fam = gen_family(n=12, nbits=800, small_bits=60, seed0=1000)
    assert len({i["N"] for i in fam}) == 12, "seeds collided"
    assert all(i["p"].bit_length() == 60 for i in fam)
    print("  12 distinct N, all 800 bits, all small factors 60 bits")
    print("  PASS: >=12 seeds available for any rate claim")

    print()
    print("== TEST 6d: gifp-shaped instance at n=800, alpha=0.10 (80-bit small factor) ==")
    g = gen_gifp_like(nbits=800, alpha=0.10, gamma=0.10, beta2=0.20, seed=5)
    print("  N1 bits=%d  N2 bits=%d  small factor=%d bits  share=%d bits"
          % (g["N"].bit_length(), g["N2"].bit_length(), g["p"].bit_length(),
             g["share"].bit_length()))
    assert g["N"].bit_length() == 800 and g["N2"].bit_length() == 800
    assert g["p"].bit_length() == 80
    assert g["N"] == g["p"] * g["q"] and g["N2"] == g["p2"] * g["q2"]
    print("  PASS: non-vacuous by construction (80 bits > 2^40)")
    print("  reproduce:", repro_line(g))
    print()
    print("== TEST 6e: gifp-shaped instance at n=200 is REFUSED ==")
    try:
        gen_gifp_like(nbits=200, alpha=0.10, gamma=0.10, beta2=0.20, seed=5)
        raise AssertionError("n=200 alpha=0.1 was accepted -- that is the vacuous r110 regime")
    except ValueError as e:
        print("  ValueError:", e)
        print("  PASS: the exact regime that voided r110 cannot be built here")
    print()
    print("ALL GENERATOR TESTS PASS")