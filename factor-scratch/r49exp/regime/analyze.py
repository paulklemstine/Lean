"""
analyze.py -- the statistics that actually decide P4 and P5.

The pooled in-regime vs out-of-regime factor rate is CONFOUNDED: different
sweeps use different moduli, and the per-modulus success rate p_split(p,q)
ranges over [0.5, 1.0].  So the honest statistic is the paired excess

        delta = rate - p_split(p,q)

which subtracts the modulus's own Shor baseline from every cell.  delta = 0
means the method adds nothing; delta > 0 would mean it does.
"""

import json
import math
import sys

D = json.load(open("/home/raver1975/lean/factor-scratch/r49exp/regime/results/"
                   + (sys.argv[1] if len(sys.argv) > 1 else "cliff_A.json")))
R = D["records"]


def wilson(k, n):
    """Wilson score interval -- behaves at k/n near 1, unlike normal approx."""
    if n == 0:
        return (float("nan"), float("nan"))
    z = 1.959963984540054
    ph = k / n
    d = 1 + z * z / n
    c = (ph + z * z / (2 * n)) / d
    h = z * math.sqrt(ph * (1 - ph) / n + z * z / (4 * n * n)) / d
    return (max(0.0, c - h), min(1.0, c + h))


def pooled(sel, name):
    n = sum(r["N"] for r in sel)
    k = sum(r["factors"] for r in sel)
    ps = sum(r["p_split"] * r["N"] for r in sel) / n if n else float("nan")
    lo, hi = wilson(k, n)
    print(f"  {name:<34} {k:>5d}/{n:<5d} = {k/n:.4f}  95%CI[{lo:.4f},{hi:.4f}]"
          f"   mean p_split = {ps:.4f}   EXCESS = {k/n - ps:+.4f}")
    return k, n, k / n - ps


print("=" * 92)
print("P4  DOES THE METHOD FACTOR BEYOND THE PROVED REGIME?")
print("=" * 92)
print("The raw pooled rate is confounded by modulus, so the excess over each")
print("cell's own p_split(p,q) is the statistic that decides it.\n")

print("P4a  by regime membership (all cells):")
a = pooled([r for r in R if r["in_regime"]], "IN  regime")
b = pooled([r for r in R if not r["in_regime"]], "OUT of regime")
print(f"       difference of excess (IN - OUT) = {a[2] - b[2]:+.4f}")

print("\nP4b  WITHIN one (modulus, c) sweep only -- the honest cliff test.")
print("      Same n, same p_split, c fixed at 10; only b changes.")
for bits in sorted({r["bits"] for r in R if r["label"] in ("A2","B")}):
    sel = [r for r in R if r["label"] in ("A2","B") and r["bits"] == bits]
    sel.sort(key=lambda r: r["b"])
    bm = sel[0]["b_max"]
    ps = sel[0]["p_split"]
    print(f"\n   n ~ 2^{bits}   b_max = {bm}   p_split = {ps:.3f} "
          f"(m_p={sel[0]['v2_p_1']}, m_q={sel[0]['v2_q_1']})   c = 10")
    print(f"     {'b':>3} {'regime':>8} {'rate':>7} {'excess':>8}  bar")
    for r in sel:
        ex = r["rate"] - ps
        bar = "#" * max(0, int(round(ex * 40)))
        print(f"     {r['b']:>3} {'IN' if r['in_regime'] else 'OUT':>8} "
              f"{r['rate']:>7.3f} {ex:>+8.3f}  {bar}")
    ins = [r for r in sel if r["in_regime"]]
    outs = [r for r in sel if not r["in_regime"]]
    mi = sum(r["factors"] for r in ins) / sum(r["N"] for r in ins)
    mo = sum(r["factors"] for r in outs) / sum(r["N"] for r in outs)
    print(f"     mean excess  IN = {mi - ps:+.4f}   OUT = {mo - ps:+.4f}"
          f"   (b sweep {sel[0]['b']}..{sel[-1]['b']}, i.e. up to "
          f"{sel[-1]['b'] - bm} past b_max)")
    # a two-proportion z on OUT vs IN
    k1, n1 = sum(r["factors"] for r in ins), sum(r["N"] for r in ins)
    k2, n2 = sum(r["factors"] for r in outs), sum(r["N"] for r in outs)
    if n1 and n2:
        p1, p2 = k1 / n1, k2 / n2
        pp = (k1 + k2) / (n1 + n2)
        se = math.sqrt(pp * (1 - pp) * (1 / n1 + 1 / n2))
        z = (p1 - p2) / se if se > 0 else 0.0
        print(f"     z(OUT - IN) = {z:+.2f}   "
              f"{'NO CLIFF (|z| < 2)' if abs(z) < 2 else 'a real drop'}")

print("\n" + "=" * 92)
print("P5  IS THE SUCCESS RATE A FUNCTION OF c?  (fixed modulus, fixed b)")
print("=" * 92)
print("Prediction P5: NO.  c buys accuracy on an index that is erased before")
print("the gcd, so the rate should track p_split alone.\n")
for key in sorted({(r["bits"], r["b"]) for r in R if r["label"] == "A1"}):
    sel = sorted([r for r in R if r["label"] == "A1" and
                  (r["bits"], r["b"]) == key], key=lambda r: r["c"])
    ps = sel[0]["p_split"]
    tot = sum(r["factors"] for r in sel)
    nn = sum(r["N"] for r in sel)
    print(f"  n ~ 2^{key[0]}, b = {key[1]}, p_split = {ps:.3f}")
    print(f"    {'c':>4} {'rate':>7} {'excess':>8}   note")
    for r in sel:
        note = ""
        if r["c"] == r["b"] + 1:
            note = "<- c = b+1, the PROVED regime's value"
        if r["c"] == 1:
            note = "<- c = 1, r49/U's 'c is wasted work'"
        print(f"    {r['c']:>4} {r['rate']:>7.3f} {r['rate']-ps:>+8.3f}   {note}")
    lo, hi = wilson(tot, nn)
    print(f"    pooled over c: {tot}/{nn} = {tot/nn:.4f} 95%CI[{lo:.4f},{hi:.4f}]"
          f"  excess {tot/nn - ps:+.4f}")
    # Proper test: each c-cell against the pooled rate (two-proportion z).
    # A Poisson chi-square is invalid here because the rate sits near 1, where
    # the binomial variance is far below the Poisson one -- my first version of
    # this test used Poisson and flagged a spurious "c-EFFECT" at chi2=29.5.
    pr = tot / nn
    zs = []
    for r in sel:
        se = math.sqrt(max(pr * (1 - pr), 1e-12) * (1 / r["N"] + 1 / nn))
        z = (r["rate"] - pr) / se if se > 0 else 0.0
        zs.append((r["c"], z))
        print(f"      c={r['c']:>3} vs pooled: z = {z:+.2f}"
              f"{'   <-- significant' if abs(z) > 2 else ''}")
    n_sig = sum(1 for _, z in zs if abs(z) > 2)
    print(f"    cells significantly different from the pooled rate: {n_sig}"
          f"/{len(zs)}  -> "
          f"{'NO c-EFFECT' if n_sig == 0 else 'c-EFFECT present'}")
    # trend in c: excess vs log c, with a slope CI
    xs = [math.log(r["c"]) for r in sel]
    ys = [r["rate"] - ps for r in sel]
    Ns = [r["N"] for r in sel]
    mx = sum(xs) / len(xs)
    my = sum(ys) / len(ys)
    sxx = sum((x - mx) ** 2 for x in xs)
    sxy = sum((x - mx) * (y - my) for x, y in zip(xs, ys))
    slope = sxy / sxx if sxx else 0.0
    var = sum((y - my - slope * (x - mx)) ** 2 for x, y in zip(xs, ys)) / \
        (len(xs) - 2) if len(xs) > 2 else 0.0
    s2 = var / sxx if sxx else float("inf")
    tstat = slope / math.sqrt(s2) if s2 > 0 else 0.0
    print(f"    trend  excess ~ {slope:+.4f} * log(c)   t = {tstat:+.2f} on "
          f"{len(xs)-2} df  -> "
          f"{'no trend in c' if abs(tstat) < 2.78 else 'TREND'}")
    print()

print("=" * 92)
print("P3  THE PROVED GUARANTEE vs WHAT IS ACHIEVED")
print("=" * 92)
sys.path.insert(0, "/home/raver1975/lean/factor-scratch/r49exp/regime")
import fwregime as F
tot = sum(r["factors"] for r in R)
nn = sum(r["N"] for r in R)
ps = sum(r["p_split"] * r["N"] for r in R) / nn
print(f"  measured factor rate, all {len(R)} cells : {tot}/{nn} = {tot/nn:.4f}")
print(f"  measured p_split weighted mean          : {ps:.4f}")
for b in (10, 15, 20, 26):
    print(f"  proved lower bound alpha_{b:<3d}                : {F.alpha_n(b):.4f}"
          f"   (ratio measured/alpha = {tot/nn/F.alpha_n(b):.1f}x)")
print(f"  zhat = prod zeta(i)^-1 (Prop 2.5)        : {F.zeta_hat():.4f}")
print(f"  the paper's Hypothesis 3.1 target 1/zeta(c+1) at c=10: "
      f"{1/F.zeta(11):.6f}")
print("\n  => the regime GUARANTEES ~0.17 but the ALGORITHM ACHIEVES ~%.2f." % (tot / nn))
print("     The guarantee is the binding constraint, not the method.")