"""
STRIDE SAMPLING: recover the cheap sampler without the spurious kernel.

THE PROBLEM. Stange's relation finder has two samplers (factor-scratch/r48/exp/stange/
stange.py::find_relations):

  random : x uniform in [1,n), candidate = pow(g,x,n)   -- O(log x) multiplications EACH
  seq    : x = 1,2,3,...,  candidate = r*g % n          -- ONE multiplication each

`seq` is ~O(log x) times cheaper, which matters enormously: the round-48 baseline measured
exp/rel = 22 at 2^20 rising to 26,213 at 2^40.

But `seq` was REJECTED, and correctly: consecutive x give g^(x+1) = g * g^x, i.e. the
relation vectors satisfy FINITE DIFFERENCES. Round 48 recorded that this makes 84%/55% of
the alpha_t exactly ZERO -- a spurious kernel that looks like a high hit rate.

THE IDEA. Use a STRIDE: x = 1, 1+s, 1+2s, ... Then

    r_{k+1} = r_k * g^s  (mod n)

still ONE multiplication per candidate, but the exponents are no longer consecutive, so
there is no finite-difference structure among them.

THE QUESTION. Does stride sampling preserve the smoothness rate AND avoid the degenerate
kernel? If yes, this is a real algorithmic saving on the one method that works.

SELF-TEST FIRST, and it must exercise the QUANTITY BEING CLAIMED -- round 48's twice-earned
rule. Specifically: it must show the harness can DETECT the degenerate seq kernel, or it
cannot demonstrate that stride avoids it.
"""

from __future__ import annotations

import math
import random
import sys

sys.path.insert(0, "/home/raver1975/lean/factor-scratch/r48/exp/stange")

from stange import factor_base, fb_exponents  # noqa: E402


def gen_semiprime(bits: int, rng: random.Random):
    from sympy import nextprime
    half = bits // 2
    p = int(nextprime(rng.getrandbits(half) | (1 << (half - 1))))
    q = int(nextprime(rng.getrandbits(half) | (1 << (half - 1))))
    return p * q, p, q


def hunt(n, g, FB, need, rng, mode, s=2, cap=400000):
    """Return (relations found, trials used, exponents seen)."""
    rels, trials = [], 0
    seen = set()
    if mode == "random":
        while len(rels) < need and trials < cap:
            trials += 1
            x = rng.randrange(1, n)
            if x in seen:
                continue
            r = pow(g, x, n)
            exps, rem = fb_exponents(r, FB)
            if rem == 1:
                seen.add(x)
                rels.append(exps)
    elif mode == "seq":
        x, r = 1, g % n
        while len(rels) < need and trials < cap:
            trials += 1
            exps, rem = fb_exponents(r, FB)
            if rem == 1 and x not in seen:
                seen.add(x)
                rels.append(exps)
            r = (r * g) % n
            x += 1
    elif mode == "stride":
        gs = pow(g, s, n)
        x, r = 1, g % n
        while len(rels) < need and trials < cap:
            trials += 1
            exps, rem = fb_exponents(r, FB)
            if rem == 1 and x not in seen:
                seen.add(x)
                rels.append(exps)
            r = (r * gs) % n
            x += s
    return rels, trials


def selftest() -> bool:
    """MUST be able to DETECT the degenerate seq kernel. If it cannot detect the
    known-bad case, it cannot certify the known-good one."""
    ok = True
    print("SELFTEST: can the harness DETECT the degenerate seq kernel?")
    print("  (round 48 recorded 84%/55% of alpha_t exactly zero under seq sampling)")

    rng = random.Random(4242)
    n, p, q = gen_semiprime(30, rng)
    g = 2
    FB = factor_base(400, n)
    print(f"  n={n} (bits {n.bit_length()}), |FB|={len(FB)}")

    # seq with stride 1 must show MANY repeated/zero-difference structure;
    # stride sampling must not. We detect degeneracy as: consecutive found
    # exponents differing by a constant vector (finite difference).
    for mode, s in (("seq", 1), ("stride", 2), ("stride", 7)):
        rels, trials = hunt(n, g, FB, 12, rng, mode, s=s)
        if len(rels) < 4:
            print(f"  [{mode} s={s}] only {len(rels)} relations -- cap too small to judge")
            continue
        # degeneracy metric: how often consecutive exponent vectors share a
        # support / difference structure. For a genuine (random) relation set
        # the vectors are unrelated; for finite differences they are not.
        same_support = 0
        for i in range(len(rels) - 1):
            a, b = set(rels[i]), set(rels[i + 1])
            if a == b:
                same_support += 1
        frac = same_support / (len(rels) - 1)
        tag = "OK" if frac < 0.5 else "DEGENERATE"
        if mode == "seq" and tag == "OK":
            print(f"  [FAIL] seq sampler did NOT register as degenerate "
                  f"(same-support frac {frac:.2f}) -- harness is blind")
            ok = False
        if mode == "stride" and tag == "DEGENERATE":
            print(f"  [FAIL] stride s={s} registered as degenerate "
                  f"(same-support frac {frac:.2f})")
            ok = False
        print(f"  [{tag}] {mode} s={s}: {len(rels)} rels, {trials} trials, "
              f"same-support frac {frac:.2f}")

    print()
    print("ALL SELFTESTS PASS" if ok else "!!! SELFTEST FAILURE -- harness cannot judge")
    return ok


def main() -> None:
    if not selftest():
        raise SystemExit(1)

    print("=" * 72)
    print("MEASUREMENT: smoothness rate and trials per relation, by sampler")
    print("=" * 72)
    print(f"  {'sampler':>16} {'rels':>5} {'trials/rel':>11} {'vs random':>10}")
    for bits in (28, 34):
        rng = random.Random(20261003)
        n, p, q = gen_semiprime(bits, rng)
        g = 2
        FB = factor_base(1 << (bits // 2), n)
        need = 12
        base = None
        print(f"\n  n ~ 2^{bits}  ({n.bit_length()} bits), |FB| = {len(FB)}, need {need} rels")
        for label, mode, s in (("random", "random", 0), ("seq (s=1)", "seq", 1),
                               ("stride s=2", "stride", 2), ("stride s=7", "stride", 7)):
            r2 = random.Random(777)
            rels, trials = hunt(n, g, FB, need, r2, mode, s=s)
            tpr = trials / max(len(rels), 1)
            if base is None:
                base = tpr
            print(f"  {label:>16} {len(rels):5d} {tpr:11.1f} {tpr/base:9.2f}x")
    print()
    print("INTERPRETATION RULE, preregistered:")
    print("  trials/rel for stride should approach the SEQ figure (one multiply per")
    print("  candidate), NOT the random figure (a full pow per candidate), while the")
    print("  degeneracy metric stays clean. If stride costs ~random, the saving is")
    print("  illusory and must be reported as such.")


if __name__ == "__main__":
    main()