"""BB -- does stride need a LARGER c than random?

The held-out test showed stride at rate 0.700 vs random 0.783 (z = +1.04, so
not significant on its own), but stride had all_zero alpha_t on 7/60 instances
and random on 0/60.  7/60 = 0.117, which is the whole 0.083 gap.

MECHANISM (predicted in the P3 preregistration).  Under a stride the exponents
are x_j = x0 + s*j, so

    alpha_t = sum_j v_j x_j = x0 * (sum_j v_j) + s * (sum_j j v_j).

For a KERNEL vector v, alpha_t = 0 now needs TWO constraints on v instead of
one, but the kernel has dimension c, so more of its basis vectors satisfy them.
With larger c the probability that ALL c chosen vectors vanish drops.

PREDICTION: stride's success rate rises back to ~20/27 as c doubles, and its
all_zero rate falls roughly like 1/c.
"""
import math, random, sys
from math import gcd
sys.path.insert(0, "/home/raver1975/lean/factor-scratch/r52/exp/smooth")
sys.path.insert(0, "/home/raver1975/lean/factor-scratch/r48/exp/stange")
from harness import FbTest, hunt, selftest
from exp_batch import psi_selftest
from stange import (factor_base, bbound_for_b, gen_semiprime, factor_from_multiple,
                    kernel_basis, primitive, build_M, order_mod_n)
T = 20 / 27


def one(n, p, q, g, FB, b, c, sampler, rng, kw, cap=8_000_000):
    h = hunt(n, g, FB, b + c, rng, sampler, cap=cap, **(kw or {}))
    if len(h["rels"]) < b + c:
        return None
    rels = h["rels"]
    K, rank = kernel_basis(build_M(rels, b))
    xs = [rels[j][1] for j in range(len(rels))]
    cc = min(c, len(K))
    betas = [sum(primitive(v)[j] * xs[j] for j in range(len(rels))) for v in K[:cc]]
    G = 0
    for a in betas:
        G = gcd(G, abs(a))
    return {"factor": factor_from_multiple(G, g, n) if G else None,
            "zero_frac": sum(1 for a in betas if a == 0) / max(cc, 1),
            "all_zero": all(a == 0 for a in betas), "ops": h["mults"] + h["smoothops"],
            "mults": h["mults"], "trials": h["trials"]}


def run(bits=28, b=10, N=60, seed0=900000, cs=(6, 12, 24)):
    print("=" * 92)
    print(f"c-SWEEP for stride vs random (n~2^{bits}, b={b}, BB={bbound_for_b(b)}, "
          f"N={N}, seeds {seed0}+)")
    print("=" * 92)
    print(f"  {'sampler':>8} {'c':>4} {'rels/att':>9} {'rate':>7} {'z/20-27':>8} "
          f"{'zero_frac':>10} {'all_zero':>9} {'ops/factor':>12} {'mults/fact':>12}")
    for sampler in ("random", "stride"):
        for c in cs:
            ok = 0; zf = 0.0; az = 0; nops = 0; nmul = 0; rels = 0
            for i in range(N):
                sd = seed0 + i
                n, p, q = gen_semiprime(bits, random.Random(sd))
                FB = factor_base(bbound_for_b(b), n)
                kw = {}
                if sampler == "stride":
                    kw = dict(x0=n // 4,
                              stride=random.Random(sd + 7).randrange(n // 4, n // 2) | 1)
                r = one(n, p, q, 2, FB, b, c, sampler, random.Random(sd + 3), kw)
                if r is None:
                    continue
                rels += 1
                zf += r["zero_frac"]; az += r["all_zero"]
                if r["factor"] in (p, q):
                    ok += 1; nops += r["ops"]; nmul += r["mults"]
            m = N
            rate = ok / m
            sig = math.sqrt(T * (1 - T) / m)
            print(f"  {sampler:>8} {c:>4} {rels:>9} {rate:>7.3f} "
                  f"{(rate-T)/sig:>+8.2f} {zf/m:>10.3f} {az:>4}/{m:<4} "
                  f"{nops/max(ok,1):>12,.0f} {nmul/max(ok,1):>12,.0f}")
    print()


if __name__ == "__main__":
    assert selftest(verbose=False); assert psi_selftest(verbose=False)
    run()
