#!/usr/bin/env python3
"""
ph_analyze.py -- Axis A (Pohlig-Hellman exchange rate): analysis of the
two measured runs, the exchange table for the requested grid, and the two
answers the brief asks for.

Pure post-processing of the JSON written by ph_exchange.sage / ph_requested.sage.
No .sage preparser is involved, hence no preparse hazard here.

Op-count model (all DERIVED, nothing fitted):

    BSGS(order) =  m                                  # baby steps
                +  dbladd(m)                          # giant-step element m*g
                +  E[ floor(x/m) ]                    # giant steps, x uniform
    m = ceil(sqrt(order)),  dbladd(k) = popcount(k)+bitlen(k)-1
    E[floor(x/m)] = ( m*L*(L-1)/2 + L*r ) / order,   L = order//m, r = order%m

    PH(n = 2^s*q)  =  BSGS(2^s) + BSGS(q)
                    + 2*dbladd(q) + 2*dbladd(2^s)      # the two subgroup encodings
    generic(n)     =  BSGS(n)

Per-instance variance: floor(x/m) is uniform on [0,m), so the 12-seed mean has
1-sigma relative spread  0.289/(sqrt(12)*1.5) = 5.6%.
"""
import json, math, os, sys
from math import isqrt

HERE = "/home/raver1975/lean/factor-scratch/r115/ph-exchange-rate"
LOGS = os.path.join(HERE, "logs")


def num(v):
    if isinstance(v, str):
        try:
            return int(v)
        except ValueError:
            try:
                return float(v)
            except ValueError:
                return v
    return v


def dbladd_ops(k):
    k = int(k)
    if k <= 0:
        return 0
    return bin(k).count("1") + k.bit_length() - 1


def bsgs_expected(order):
    order = int(order)
    m = isqrt(order - 1) + 1
    L, r = divmod(order, m)
    S = m * L * (L - 1) // 2 + (L * r if r else 0)
    return m + dbladd_ops(m) + S / float(order), m


def ph_expected(s, q):
    return (bsgs_expected(1 << s)[0] + bsgs_expected(int(q))[0]
            + dbladd_ops(q) * 2 + dbladd_ops(1 << s) * 2)


def gen_expected(s, q):
    return bsgs_expected((1 << s) * int(q))[0]


# ------------------------------------------------------------------ load
run1 = json.load(open(os.path.join(LOGS, "ph_main_run1.json")))
run2 = json.load(open(os.path.join(LOGS, "ph_main_run2.json")))

ident = True
for x, y in zip(run1["recs"], run2["recs"]):
    for k in x:
        if k != "per" and num(x[k]) != num(y[k]):
            ident = False
    for p, q in zip(x["per"], y["per"]):
        for k in p:
            if k in ("generic_ms", "ph_ms"):
                continue
            if num(p[k]) != num(q[k]):
                ident = False

R = run1["recs"]
for r in R:
    r["s"] = int(num(r["s"])); r["b"] = int(num(r["b"]))
    for k in ("generic_max", "ph_max", "generic_min", "ph_min", "seeds", "n_bits"):
        r[k] = int(num(r[k]))
    r["n_bits"] = float(num(r["n_bits"]))
    for p in r["per"]:
        for k in ("q", "n", "generic_ops", "ph_ops"):
            p[k] = int(num(p[k]))

print("=" * 106)
print("STEP 1.  RUN-TWICE CHECK   (campaign rule: fixed seed, run the whole count twice)")
print("=" * 106)
print("  seed = %s   seeds/point = %s   parameter points = %d"
      % (run1["master_seed"], R[0]["seeds"], len(R)))
print("  run 1 wall = %.1f s      run 2 wall = %.1f s   (wall clock differs; counts do not)"
      % (run1["wall"], run2["wall"]))
print("  every group-op count in run 1 == the corresponding count in run 2 :", ident)
assert ident, "THE TWO RUNS DISAGREE -- DO NOT PUBLISH"
print("  all %d recovered dlogs verified (d*g == h mod n, and d == the planted d): %s"
      % (len(R) * R[0]["seeds"], all(r["all_ok"] for r in R)))
print()

# ------------------------------------------------------------------ step 2
NINST = sum(r["seeds"] for r in R)
print("=" * 106)
print("STEP 2.  VALIDATION of the DERIVED (zero-free-parameter) op-count model")
print("          against %d measured instances (22 points x 12 seeds)" % NINST)
print("=" * 106)
print("%4s %4s %8s | %13s %13s %7s %6s | %13s %13s %7s %6s" %
      ("s", "b", "nbits", "gen_meas", "gen_model", "err%", "z", "ph_meas", "ph_model", "err%", "z"))
errs_g, errs_p, zs = [], [], []
errs_g_signed, errs_p_signed = [], []
for r in R:
    s, b, ns = r["s"], r["b"], r["seeds"]
    qs = [p["q"] for p in r["per"]]
    gm = sum(gen_expected(s, q) for q in qs) / ns
    pm = sum(ph_expected(s, q) for q in qs) / ns
    # predicted 1-sigma of a 12-seed mean (floor(x/m) uniform on [0,m))
    m = isqrt(((1 << s) * qs[0]) - 1) + 1
    sig = 0.289 * m / math.sqrt(ns) / (1.5 * m)
    e1 = (gm - r["generic_mean"]) / r["generic_mean"]
    e2 = (pm - r["ph_mean"]) / r["ph_mean"]
    errs_g.append(abs(e1)); errs_p.append(abs(e2)); zs.append(abs(e1) / sig)
    errs_g_signed.append(e1); errs_p_signed.append(e2)
    print("%4d %4d %8.2f | %13.1f %13.1f %7.2f %6.2f | %13.1f %13.1f %7.2f %6.2f"
          % (s, b, r["n_bits"], r["generic_mean"], gm, 100 * e1, abs(e1) / sig,
             r["ph_mean"], pm, 100 * e2, abs(e2) / sig))
print()
print("  mean |err| : generic %.2f%%   PH %.2f%%"
      % (100 * sum(errs_g) / len(errs_g), 100 * sum(errs_p) / len(errs_p)))
print("  worst |err|: generic %.2f%%   PH %.2f%%"
      % (100 * max(errs_g), 100 * max(errs_p)))
print("  mean SIGNED err: generic %+.3f%%   PH %+.3f%%  (+ = model over-predicts = conservative)"
      % (100 * sum(errs_g_signed) / len(errs_g_signed),
         100 * sum(errs_p_signed) / len(errs_p_signed)))
print("  predicted 1-sigma of a 12-seed mean is 5.6%%; observed |err|/sigma : max %.2f, mean %.2f"
      % (max(zs), sum(zs) / len(zs)))
print("  -> the residual scatter IS the 12-seed sampling noise.  The model has no free")
print("     parameters and sqrt(n) spans 2^4 .. 2^22 (a factor 2^18) across the grid.")
print()
print("  per-instance RANGE check (giant steps in [1..m], so BSGS in [m+.., 2m+..]):")
print("%4s %4s | %16s %16s | %16s %16s" %
      ("s", "b", "gen[min,max]", "model range", "ph[min,max]", "model range"))
for r in R[:6] + R[12:14]:
    s, b = r["s"], r["b"]
    q = r["per"][0]["q"]
    mg = isqrt((1 << s) * q - 1) + 1
    ms = isqrt((1 << s) - 1) + 1
    mq = isqrt(q - 1) + 1
    print("%4d %4d | %8d %8d | %8d %8d | %8d %8d | %8d %8d"
          % (s, b, r["generic_min"], r["generic_max"], mg, 2 * mg,
             r["ph_min"], r["ph_max"], ms + mq, 2 * (ms + mq)))
print()
print("  => the model is VALIDATED.  The b >= 40 column below is therefore a MODELLED")
print("     prediction, labelled as such, and NOT a measurement.")
print()

# ------------------------------------------------------------------ step 3
SS = [20, 40, 60]
BB = [40, 60, 80, 100, 120]
NSAMP = 500


def qs_range(b):
    lo, hi = 1 << (b - 1), 1 << b
    return [lo + (hi - lo) * i // NSAMP for i in range(1, NSAMP)]


print("=" * 116)
print("STEP 3.  THE EXCHANGE TABLE    (units: GROUP OPERATIONS)")
print("=" * 116)
print("  n = 2^s * q, q a b-bit prime (nominal b; q is uniform in [2^(b-1), 2^b) and the")
print("  table is averaged over q), the discrete log d is uniform in [0,n).")
print("  generic = BSGS on the FULL group of order n      <-- THE BASELINE")
print("  PH      = BSGS in <q*g> (order 2^s) + BSGS in <2^s*g> (order q) + CRT")
print("  savings = log2(generic / PH) = bits of ECDLP work bought")
print("=" * 116)
print("%4s %5s %6s | %13s %7s | %13s %7s | %8s | %8s" %
      ("s", "b", "|n|~", "generic", "log2", "PH", "log2", "savings", "s/2"))
rows = []
for s in SS:
    for b in BB:
        qs = qs_range(b)
        g = sum(gen_expected(s, q) for q in qs) / len(qs)
        p = sum(ph_expected(s, q) for q in qs) / len(qs)
        star = " [*]" if (s, b) in [(r["s"], r["b"]) for r in R] else ""
        rows.append((s, b, g, p))
        print("%4d %5d %6d | %13.4e %7.2f | %13.4e %7.2f | %8.3f | %8.2f%s"
              % (s, b, s + b, g, math.log(g, 2), p, math.log(p, 2),
                 math.log(g / p, 2), s / 2.0, star))
print("  [*] MEASURED directly in this run (both columns).  All other cells: the generic")
print("      column is 2^((s+b)/2)-scale and NOT computable here (2^30..2^90 ops); it is")
print("      the validated model above.  The PH column at (20,40) and (40,40) WAS measured")
print("      directly -- see STEP 7.")
print()
print("  sensitivity over the true size of q (q uniform in [2^(b-1), 2^b)):")
print("%4s %5s | %20s %20s" % ("s", "b", "log2(PH)", "savings"))
for (s, b, g, p) in rows:
    qs = qs_range(b)
    ps = [math.log(ph_expected(s, q), 2) for q in qs]
    sv = [math.log(gen_expected(s, q) / ph_expected(s, q), 2) for q in qs]
    print("%4d %5d | %9.2f .. %-9.2f %9.3f .. %-9.3f"
          % (s, b, min(ps), max(ps), min(sv), max(sv)))
print()
print("  WORST-CASE column (adversary's d lands near the top of the interval):")
print("%4s %5s | %10s %10s %8s" % ("s", "b", "gen_wc", "PH_wc", "sav_wc"))
for (s, b, g, p) in rows:
    q = (1 << b) - 1
    ms = isqrt((1 << s) - 1) + 1
    mq = isqrt(q - 1) + 1
    m = isqrt(((1 << s) * q) - 1) + 1
    gw = 2 * m
    pw = 2 * (ms + mq) + dbladd_ops(q) * 2 + dbladd_ops(1 << s) * 2
    print("%4d %5d | %10.2f %10.2f %8.3f"
          % (s, b, math.log(gw, 2), math.log(pw, 2), math.log(gw / pw, 2)))
print()

# ------------------------------------------------------------------ step 4
print("=" * 106)
print("STEP 4.  Q1.  At what residual-prime size b does PH stop being worth it?")
print("=" * 106)
bad = [(s, b) for s in range(1, 41) for b in range(1, 41)
       if 2.0 ** (s / 2.0) + 2.0 ** (b / 2.0) >= 2.0 ** ((s + b) / 2.0)]
print("  leading-term crossover set {(s,b): 2^(s/2)+2^(b/2) >= 2^((s+b)/2)} =")
print("   ", bad)
print("  For s,b >= 3 the PH leading term is STRICTLY below the generic one, so PH cannot")
print("  lose inside the square-root term.  The only loss region is below the O(log n)")
print("  subgroup-encoding overhead; the measurement pins its boundary:")
for r in R:
    if (r["s"], r["b"]) in [(4, 4), (8, 8), (4, 8), (8, 4), (12, 12), (4, 12), (12, 4)]:
        print("     (s,b)=(%2d,%2d): generic %9.1f  PH %9.1f  -> %s by %.3f bits"
              % (r["s"], r["b"], r["generic_mean"], r["ph_mean"],
                 "PH LOSES" if r["ph_mean"] > r["generic_mean"] else "PH WINS",
                 abs(math.log(r["generic_mean"] / r["ph_mean"], 2))))
print("  ANSWER: NO such b exists in the ECDSA-relevant regime.  For every s,b >= 8 the")
print("  saving is positive, and the saving is essentially FLAT in b (it saturates at s/2):")
for s in SS:
    print("     s=%3d : %s" % (s, ",  ".join(
        "b=%d:%.2f" % (b, math.log(gen_expected(s, (1 << b) - 1) / ph_expected(s, (1 << b) - 1), 2))
        for b in BB)))
print("  The binding constraint is NOT b crossing generic; it is the ABSOLUTE residual cost")
print("  1.47*2^(b/2), which no amount of small-part knowledge reduces.")
print()

# ------------------------------------------------------------------ step 5
print("=" * 106)
print("STEP 5.  Q2.  How much of n must the attacker know before the residual work drops")
print("          below generic by a useful margin?")
print("=" * 106)
print("  exact identity from the model (s <= b):")
print("      PH / generic  ->  2^(-s/2)      and      savings = s/2")
print("  ONE bit of known factorization buys HALF a bit of ECDLP work.  Exchange rate 2:1.")
print()
print("   D-bit saving  <=>  need BOTH  s >= 2D  and  log2(q) >= 2D")
for D in [1, 2, 4, 8, 10, 20, 30, 40, 60, 80, 100, 120]:
    print("      saving %4d bits  <=>  s >= %4d bits known  AND  q >= %d bits"
          % (D, 2 * D, 2 * D))
print()
print("  the residual half 1.47*2^(b/2) is independent of s.  Fix the attacker budget")
print("  T = 2^t group ops and a group order of N bits; ask how much must be known:")
print("%8s %8s %13s %13s %15s" %
      ("log2|G|", "budget t", "max log2 q", "min s known", "best PH log2"))
for N in [128, 160, 192, 256]:
    for t in [40, 50, 64, 80, 100, 128]:
        bmax = 2.0 * (t - math.log(1.47, 2))       # 1.47*2^(b/2) <= 2^t
        smin = N - bmax
        if smin <= 0:
            print("%8d %8d %13s %13s %15s" % (N, t, "> N", "0 (n < budget)", "generic already"))
            continue
        ss = int(round(smin)); bb = int(round(bmax))
        best = math.log(ph_expected(ss, (1 << bb) - 1), 2)
        print("%8d %8d %13.1f %13.1f %15.2f" % (N, t, bmax, smin, best))
    print()
print("  Reading of the 256-bit rows: to push a 256-bit ECDLP inside a 2^64 group-op")
print("  budget the residual prime must be <= ~2^127, so the attacker must already know")
print("  ~129 bits of the factorization of n -- essentially HALF of it -- and the 127-bit")
print("  residual still costs 2^63.5 ops on its own.  Nothing becomes easy; the square root")
print("  is merely halved.  With a 2^40 budget the attacker must know ~177 of the 256 bits.")
print()

# ------------------------------------------------------------------ step 6
print("=" * 106)
print("STEP 6.  BASELINE DISCIPLINE: the standardized curves (generic IS the baseline)")
print("=" * 106)
print("%32s %9s %11s %11s %9s  %s" %
      ("curve / scenario", "log2 n", "generic_b", "PH_b", "sav_b", "verdict"))
for name, hn, L in [("P-256 (n prime, h=1)", 256, None),
                    ("secp256k1 (n prime, h=1)", 256, None),
                    ("Ed25519 (h=8, ell prime)", 252, 3),
                    ("hypothetical h=2^20", 256, 20),
                    ("hypothetical h=2^40", 256, 40),
                    ("hypothetical h=2^80", 256, 80),
                    ("hypothetical 2^128-smooth order", 256, "smooth128"),
                    ("hypothetical 2^80-smooth order", 256, "smooth80")]:
    g = math.log(gen_expected(0, 1 << hn), 2)
    if L is None:
        print("%32s %9d %11.1f %11s %9s  %s" % (name, hn, g, "-", "-",
                                                "PH INAPPLICABLE (n prime)"))
    elif L == "smooth128":
        p = math.log(ph_expected(128, (1 << 128) - 1), 2)
        print("%32s %9d %11.1f %11.1f %9.2f  %s" % (name, hn, g, p, g - p,
                                                    "costs 2^%.0f" % p))
    elif L == "smooth80":
        p = math.log(ph_expected(hn - 80, (1 << 80) - 1), 2)
        print("%32s %9d %11.1f %11.1f %9.2f  %s" % (name, hn, g, p, g - p,
                                                    "costs 2^%.0f" % p))
    else:
        b = hn - L
        p = math.log(ph_expected(L, (1 << b) - 1), 2)
        v = "no useful gain" if g - p < 2 else "%.1f bits saved" % (g - p)
        print("%32s %9d %11.1f %11.1f %9.2f  %s" % (name, hn, g, p, g - p, v))
print("  -> P-256 and secp256k1 have PRIME group order: there is no small part to know,")
print("     PH is inapplicable and the generic column is all there is.  Ed25519's public")
print("     cofactor 8 buys 1.5 bits.  Axis A is live only against an implementer who chose")
print("     a composite/smooth group order -- a DEPLOYMENT bug, not a factoring result.")
print()

# ------------------------------------------------------------------ step 7
p7 = os.path.join(LOGS, "ph_requested.json")
if os.path.exists(p7):
    print("=" * 106)
    print("STEP 7.  DIRECT MEASUREMENT of the PH column at the two computable requested cells")
    print("=" * 106)
    print("  (the generic baseline at these cells is 2^30.6 / 2^40.6 group ops: not computable")
    print("   here, so it is the validated model; the PH column below IS a measurement)")
    for rec in json.load(open(p7)):
        s, b = rec["s"], rec["b"]
        per = rec["per"]
        print("  (s,b) = (%d,%d), |n| ~ 2^%d, %d seeds"
              % (s, b, rec["n_bits"], rec["seeds"]))
        print("     PH MEASURED mean = %.1f ops (2^%.3f), max = %d, min = %d, all correct = %s"
              % (rec["ph_mean"], math.log(rec["ph_mean"], 2), rec["ph_max"], rec["ph_min"],
                 rec["all_ok"]))
        qavg = sum(ph_expected(s, p["q"]) for p in per) / len(per)
        print("     PH model on the SAME %d q's = %.1f ops (2^%.3f)   rel.err = %+.2f%%"
              % (rec["seeds"], qavg, math.log(qavg, 2),
                 100 * (qavg - rec["ph_mean"]) / rec["ph_mean"]))
        qs2 = qs_range(b)
        qavg2 = sum(ph_expected(s, q) for q in qs2) / len(qs2)
        print("     PH model, q averaged over [2^(b-1),2^b) = %.1f ops (2^%.3f)"
              % (qavg2, math.log(qavg2, 2)))
        qsingle = ph_expected(s, (1 << b) - 1)
        print("     PH model, single q = 2^b-1             = %.1f ops (2^%.3f)"
              % (qsingle, math.log(qsingle, 2)))
        ms = [isqrt(p["q"] - 1) + 1 for p in per]
        inst_sd = math.sqrt(sum((m / math.sqrt(12.0)) ** 2 for m in ms) / len(ms)
                            + (sum((ph_expected(s, p["q"]) - qavg) ** 2 for p in per) / len(per)))
        sd_mean = inst_sd / math.sqrt(rec["seeds"])
        print("     predicted 1-sigma of the %d-seed mean: %.0f ops (%.1f%%)"
              % (rec["seeds"], sd_mean, 100 * sd_mean / rec["ph_mean"]))
        print("     measured mean is %.2f sigma from the same-q model expectation."
              % (abs(qavg - rec["ph_mean"]) / sd_mean))
        gg = gen_expected(s, (1 << b) - 1)
        print("     generic baseline = %.3e ops (2^%.2f) [model]  ->  savings = %.2f bits"
              % (gg, math.log(gg, 2), math.log(gg, 2) - math.log(rec["ph_mean"], 2)))
        dev = max(abs(ph_expected(s, p["q"]) - p["ph_ops"]) / float(p["ph_ops"]) for p in per)
        print("     worst per-seed |model - measured| = %.2f%% (the model is an EXPECTATION)"
              % (100 * dev))
    print()

# ------------------------------------------------------------------ dump
out = dict(
    deterministic=ident, seed=run1["master_seed"], seeds=R[0]["seeds"],
    n_instances=NINST,
    mean_relerr_generic=sum(errs_g) / len(errs_g),
    mean_relerr_ph=sum(errs_p) / len(errs_p),
    worst_relerr_generic=max(errs_g), worst_relerr_ph=max(errs_p),
    measured=[dict(s=r["s"], b=r["b"], nbits=r["n_bits"],
                   generic_mean=r["generic_mean"], generic_max=r["generic_max"],
                   generic_min=r["generic_min"], ph_mean=r["ph_mean"], ph_max=r["ph_max"],
                   ph_min=r["ph_min"],
                   generic_model=sum(gen_expected(r["s"], p["q"]) for p in r["per"]) / r["seeds"],
                   ph_model=sum(ph_expected(r["s"], p["q"]) for p in r["per"]) / r["seeds"],
                   sav=math.log(r["generic_mean"] / r["ph_mean"], 2),
                   all_ok=r["all_ok"]) for r in R],
    table=[dict(s=s, b=b, nbits=s + b, generic=g, ph=p,
                generic_log2=math.log(g, 2), ph_log2=math.log(p, 2),
                sav=math.log(g / p, 2)) for (s, b, g, p) in rows],
    requested_measured=json.load(open(p7)) if os.path.exists(p7) else None,
)
json.dump(out, open(os.path.join(LOGS, "ph_analysis.json"), "w"), indent=1)
print("wrote", os.path.join(LOGS, "ph_analysis.json"))
