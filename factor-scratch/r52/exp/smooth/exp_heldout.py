"""
BB / THE DECISIVE TEST.  Does the stride sampler actually FACTOR at rate 20/27?

Part C gave stride 0/4 while random gave 2/4 on fresh n ~ 2^40.  Four
instances cannot distinguish "stride breaks the method" (P = 0.26^4 = 0.0046,
so 0/4 is unlikely by chance) from noise, and the round's whole priority-1
claim hangs on it.  This runs a properly powered held-out comparison.

PREREGISTRATION (written before running):
  H1  success rate(stride) is within 3 sigma of 20/27, i.e. >= 0.55 at N=60.
  H2  success rate(stride) is within 2 sigma of success rate(random), paired
      on the SAME instances.
  H3  stride costs >= 2x fewer operations per successful factor.
  If H1 fails the repair is reported UNSAFE and the round's lead is retracted.
  Seeds are disjoint from every tuning seed used in Parts A/B/C (81xxxx, 82xxxx,
  83xxxx) and from exp_s2s3 (88xxxx): this block uses 90xxxx.
"""
import math, random, sys, time
from math import gcd
sys.path.insert(0, "/home/raver1975/lean/factor-scratch/r52/exp/smooth")
sys.path.insert(0, "/home/raver1975/lean/factor-scratch/r48/exp/stange")
from harness import FbTest, hunt, selftest
from exp_batch import psi_selftest, density
from stange import (factor_base, bbound_for_b, gen_semiprime, factor_from_multiple,
                    kernel_basis, primitive, build_M, order_mod_n)

TWENTY_OVER_27 = 20 / 27


def one(n, p, q, g, FB, b, c, sampler, rng, kw, cap=8_000_000):
    h = hunt(n, g, FB, b + c, rng, sampler, cap=cap, **(kw or {}))
    if len(h["rels"]) < b + c:
        return {"factor": None, "stalled": True}
    rels = h["rels"]
    Mrows = build_M(rels, b)
    K, rank = kernel_basis(Mrows)
    xs = [rels[j][1] for j in range(len(rels))]
    cc = min(c, len(K))
    betas = [sum(primitive(v)[j] * xs[j] for j in range(len(rels))) for v in K[:cc]]
    G = 0
    for a in betas:
        G = gcd(G, abs(a))
    og = order_mod_n(g, n, p, q)
    fac = factor_from_multiple(G, g, n) if G else None
    return {"factor": fac, "G": G, "ord": og, "rank": rank, "dimK": len(K),
            "zero_frac": sum(1 for a in betas if a == 0) / max(cc, 1),
            "all_zero": all(a == 0 for a in betas),
            "G_is_mult": (G != 0 and G % og == 0),
            "mults": h["mults"], "trials": h["trials"], "smoothops": h["smoothops"],
            "ops": h["mults"] + h["smoothops"], "rel": len(rels)}


def run(bits=28, b=10, c=6, N=60, seed0=900000):
    print("=" * 90)
    print(f"HELD-OUT SUCCESS-RATE TEST  n~2^{bits}, b={b}, c={c}, "
          f"BB={bbound_for_b(b)}, N={N} fresh instances, seeds {seed0}+")
    print("=" * 90)
    agg = {}
    for sname in ("random", "stride"):
        ok = 0
        stalls = 0
        zb = zf = az = 0.0
        nmul = nops = ntri = 0
        nsuc_mult = nsuc_ops = 0
        w = 0.0
        t0 = time.perf_counter()
        for i in range(N):
            sd = seed0 + i
            rng = random.Random(sd)
            n, p, q = gen_semiprime(bits, rng)
            FB = factor_base(bbound_for_b(b), n)
            g = 2
            kw = {}
            if sname == "stride":
                kw = dict(x0=n // 4,
                          stride=random.Random(sd + 7).randrange(n // 4, n // 2) | 1)
            r = one(n, p, q, g, FB, b, c, sname, random.Random(sd + 3), kw)
            if r.get("stalled"):
                stalls += 1
                continue
            zb += (r["rank"] != b)
            zf += r["zero_frac"]
            az += r["all_zero"]
            ntri += r["trials"]; nmul += r["mults"]; nops += r["ops"]
            if r["factor"] in (p, q):
                ok += 1
                nsuc_mult += r["mults"]; nsuc_ops += r["ops"]
        dt = time.perf_counter() - t0
        m = N - stalls
        rate = ok / m
        sig = math.sqrt(TWENTY_OVER_27 * (1 - TWENTY_OVER_27) / m)
        z = (rate - TWENTY_OVER_27) / sig
        agg[sname] = {"ok": ok, "m": m, "rate": rate, "z": z,
                      "ops_per_suc": nsuc_ops / max(ok, 1),
                      "mul_per_suc": nsuc_mult / max(ok, 1),
                      "tri_per_suc": ntri / max(ok, 1), "secs": dt,
                      "rankdef": zb, "zero_frac": zf / m, "all_zero": az,
                      "stalls": stalls}
    for sname, a in agg.items():
        print(f"  [{sname:>6}] factors {a['ok']}/{a['m']}  rate {a['rate']:.4f}  "
              f"z vs 20/27 = {a['z']:+.2f}")
        print(f"            rank(M)<b on {a['rankdef']:.0f}/{a['m']}  "
              f"mean zero_frac(alpha) = {a['zero_frac']:.3f}  "
              f"all_zero on {a['all_zero']:.0f}/{a['m']}  stalls {a['stalls']}")
        print(f"            per SUCCESS: trials={a['tri_per_suc']:,.0f}  "
              f"mults={a['mul_per_suc']:,.0f}  ops={a['ops_per_suc']:,.0f}  "
              f"wall(total)={a['secs']:.1f}s")
    r, s = agg["random"], agg["stride"]
    print()
    print(f"  ==> H1 stride rate >= 0.55 : {s['rate']:.3f}  "
          f"{'PASS' if s['rate'] >= 0.55 else 'FAIL'}")
    # paired test on the same instances is not available (separate runs), so do
    # a two-proportion z-test, which is the right unpaired comparison here.
    p1, p2 = s["rate"], r["rate"]
    pp = (s["ok"] + r["ok"]) / (s["m"] + r["m"])
    se = math.sqrt(pp * (1 - pp) * (1 / s["m"] + 1 / r["m"]))
    zz = (p2 - p1) / se if se else 0.0
    print(f"  ==> H2 |rate(random) - rate(stride)| within 2 sigma : "
          f"diff {p2-p1:+.3f}, z = {zz:+.2f}  {'PASS' if abs(zz) < 2 else 'FAIL'}")
    print(f"  ==> H3 ops per successful factor: random {r['ops_per_suc']:,.0f} "
          f"vs stride {s['ops_per_suc']:,.0f}  = "
          f"{r['ops_per_suc']/s['ops_per_suc']:.2f}x  "
          f"{'PASS' if r['ops_per_suc']/s['ops_per_suc'] >= 2 else 'FAIL'}")
    print(f"      (multiplications only: {r['mul_per_suc']/s['mul_per_suc']:.1f}x)")
    print()
    return agg


if __name__ == "__main__":
    assert selftest(verbose=False)
    assert psi_selftest(verbose=False)
    N = int(sys.argv[1]) if len(sys.argv) > 1 else 60
    bits = int(sys.argv[2]) if len(sys.argv) > 2 else 28
    b = int(sys.argv[3]) if len(sys.argv) > 3 else 10
    run(bits=bits, b=b, N=N)
