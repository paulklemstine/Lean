#!/usr/bin/env python3
"""
analyze.py -- Axis K (r115): fit the interval-ECDLP cost law from the
measured runs and build the extrapolation table.

  Measured : kangaroo_law_run1.json / run2.json, bsgs_interval_*.json
  Fitted   : log2(ops) = c + beta*log2(w), with beta expected = 0.5
  Seed-to-seed spread reported from the 12 seeds per cell.
  Extrapolation to b = 96..224 uses the MEASURED group-op rate from
  rate.json.  The wall-clock column is an extrapolation from a measured
  rate, NOT a prediction of future hardware.
"""
import json, os, sys, math

LOGDIR = "/home/raver1975/lean/factor-scratch/r115/interval-kangaroo/logs"

def load(fn):
    p = os.path.join(LOGDIR, fn)
    if not os.path.exists(p):
        return None
    with open(p) as fh:
        return json.load(fh)

def fit(xs, ys):
    """least squares y = c + beta*x ; returns (beta, c, r2, n, se_beta)"""
    n = len(xs)
    mx = sum(xs) / n; my = sum(ys) / n
    sxx = sum((x - mx) ** 2 for x in xs)
    sxy = sum((x - mx) * (y - my) for x, y in zip(xs, ys))
    beta = sxy / sxx
    c = my - beta * mx
    ss_tot = sum((y - my) ** 2 for y in ys)
    ss_res = sum((y - (c + beta * x)) ** 2 for x, y in zip(xs, ys))
    r2 = 1.0 - ss_res / ss_tot if ss_tot > 0 else float('nan')
    if n > 2 and sxx > 0:
        s2 = ss_res / (n - 2)
        se_beta = math.sqrt(s2 / sxx)
    else:
        se_beta = float('nan')
    return beta, c, r2, n, se_beta

def summarise(rows, nseed):
    """per-size mean ops, recovery rate, and spread"""
    out = {}
    for r in rows:
        out.setdefault(r['b'], []).append(r)
    res = []
    for b in sorted(out):
        sub = out[b]
        ops = [r['total_ops'] for r in sub]
        alg = [r.get('alg_ops', r['total_ops']) for r in sub]
        ok = sum(1 for r in sub if r['ok'])
        mean_ops = sum(ops) / len(ops)
        var = sum((o - mean_ops) ** 2 for o in ops) / max(1, len(ops) - 1)
        res.append(dict(b=b, w=1 << b, n=len(sub), ok=ok,
                        rate=ok / float(len(sub)),
                        mean_ops=mean_ops, sd_ops=math.sqrt(var),
                        mean_alg=sum(alg) / len(alg),
                        mean_tame=sum(r.get('tame_ops', 0) for r in sub) / len(sub),
                        mean_wild=sum(r.get('wild_ops', 0) for r in sub) / len(sub),
                        log2_ops=math.log(mean_ops, 2),
                        log2_sd=math.sqrt(var) / (mean_ops * math.log(2)),
                        Mmax=sub[0].get('Mmax', 0), K=sub[0].get('K', 0),
                        mean_t=sum(r.get('t_total', 0) for r in sub) / len(sub),
                        mean_giant=sum(r.get('giant_steps', 0) for r in sub) / len(sub),
                        m=sub[0].get('m', 0),
                        ntable=sub[0].get('ntable', 0)))
    return res

print("=" * 78)
print("Axis K analysis -- short-interval ECDLP on secp256k1")
print("=" * 78)

# ---------------- run-twice check on the kangaroo law ------------------
r1 = load("kangaroo_law_run1.json")
r2 = load("kangaroo_law_run2.json")

print("\n[1] RUN-TWICE CHECK (fixed seed; op counts should be identical)")
if r1 and r2:
    d1 = r1['rows']; d2 = r2['rows']
    keyf = lambda r: (r['b'], r['seed'], r['plant'])
    m1 = dict((keyf(r), r) for r in d1)
    m2 = dict((keyf(r), r) for r in d2)
    common = sorted(set(m1) & set(m2))
    same_ops = same_hit = 0
    tmax = 0.0
    for k in common:
        a, bb = m1[k], m2[k]
        if a['total_ops'] == bb['total_ops']:
            same_ops += 1
        if (a['hit'] is None) == (bb['hit'] is None) and a['ok'] == bb['ok']:
            same_hit += 1
        tmax = max(tmax, abs(a['t_total'] - bb['t_total']))
    print("   cells matched: %d" % len(common))
    print("   identical total_ops: %d / %d" % (same_ops, len(common)))
    print("   identical hit/success: %d / %d" % (same_hit, len(common)))
    print("   max |wall-clock difference|: %.3f s" % tmax)
else:
    print("   (only one run present -- run-twice check pending)")

rows = (r1 or r2 or {}).get('rows', [])
if not rows:
    print("NO KANGAROO DATA")
    sys.exit(1)

# ---------------- positive control -------------------------------------
print("\n[2] POSITIVE CONTROL -- recovery of the PLANTED d (known d)")
print("    %-6s %-6s %-12s %-10s %-9s %-9s" % ("b", "M", "mean ops", "2^ops", "tame", "wild"))
S = summarise(rows, 12)
for s in S:
    print("    %-6d %-6d %-12.0f %-10.3f %-9.0f %-9.0f   recovery %d/%d"
          % (s['b'], s['Mmax'], s['mean_ops'], s['log2_ops'], s['mean_tame'],
             s['mean_wild'], s['ok'], s['n']))

# ---------------- scaling law ------------------------------------------
print("\n[3] SCALING LAW  log2(ops) = c + beta*log2(w)")
xs = [math.log(s['w'], 2) for s in S]
ys = [s['log2_ops'] for s in S]
beta, c, r2, n, se = fit(xs, ys)
print("   measured points: %s" % ", ".join("b=%d" % s['b'] for s in S))
print("   beta = %.5f  +/- %.5f" % (beta, se))
print("   c     = %.5f" % c)
print("   R^2   = %.9f" % r2)
print("   predicted beta = 0.5")
dev = abs(beta - 0.5)
print("   |beta - 0.5| = %.5f   (%.2f standard errors)" % (dev, dev / se if se else float('nan')))
print("   => %s" % ("CONSISTENT with sqrt(w)" if dev < 3 * se else "INCONSISTENT"))

# spread: per-size seed-to-seed sd in log2 units
sd_all = [s['log2_sd'] for s in S]
print("   seed-to-seed sd of log2(ops): mean %.4f, max %.4f"
      % (sum(sd_all) / len(sd_all), max(sd_all)))

# exclude the degenerate tiny sizes where the O(log n) setup dominates
Sbig = [s for s in S if s['b'] >= 16]
if len(Sbig) >= 3:
    xs2 = [math.log(s['w'], 2) for s in Sbig]
    ys2 = [s['log2_ops'] for s in Sbig]
    b2, c2, r22, n2, se2 = fit(xs2, ys2)
    print("   refit on b>=%d only: beta = %.5f +/- %.5f, R^2 = %.9f, c = %.4f"
          % (min(s['b'] for s in Sbig), b2, se2, r22, c2))

# ---------------- throughput -------------------------------------------
print("\n[4] MEASURED THROUGHPUT (this machine)")
rate = load("rate.json")
if rate:
    print("   machine: %s, sage %s" % (rate['machine'], rate['sage']))
    for k, v in sorted(rate['results'].items()):
        print("     %-16s %12.0f ops/s   (%.3f us/op)" % (k, v['best'], 1e6 / v['best']))

# empirical rate from the measured runs themselves (ops / wall clock)
rates = []
for s in S:
    if s['mean_t'] > 0:
        rates.append(s['mean_ops'] / s['mean_t'])
if rates:
    print("   empirical rate from the runs themselves (ops/mean seconds):")
    print("     mean %.0f  min %.0f  max %.0f ops/s" % (sum(rates) / len(rates), min(rates), max(rates)))

# ---------------- extrapolation ----------------------------------------
print("\n[5] EXTRAPOLATION TABLE  (b = interval half-width in bits)")
print("    w = 2^b, cost = C * 2^(b/2) group ops, C from the fit")
C = 2 ** c
print("    fitted C = 2^%.4f = %.3f  (kangaroo, kfac=3, full trap table)" % (c, C))
RS = 63364.0            # measured kangaroo step rate, best of 5 reps
RADD = 75277.0          # measured pure addition rate
BR = 77130.0            # measured BSGS step rate
print("    measured group-op rates used for wall clock:")
print("       kangaroo step (hash+add+dict) : %.0f ops/s" % RS)
print("       BSGS step (add+dict lookup)   : %.0f ops/s" % BR)

print("\n    %-5s %-14s %-14s %-16s %-20s" % ("b", "kangaroo ops", "BSGS ops", "kang. wall", "BSGS wall"))
print("    " + "-" * 74)
BSGS_C = 1.4           # measured BSGS constant (ops/sqrt(w))
table = []
for b in (96, 112, 128, 160, 192, 224, 256):
    ops = C * (2.0 ** (b / 2.0))
    bsgs = BSGS_C * (2.0 ** (b / 2.0))
    tk = ops / RS
    tb = bsgs / BR
    def fmt_time(t):
        units = [("s", 1.0), ("min", 60.0), ("hour", 3600.0), ("day", 86400.0),
                 ("year", 86400.0 * 365.25), ("millennia", 86400.0 * 365.25 * 1000.0),
                 ("Myr", 86400.0 * 365.25 * 1e6), ("Gyr", 86400.0 * 365.25 * 1e9),
                 ("e14yr", 86400.0 * 365.25 * 1e14)]
        for unit, div in units:
            if t / div < 999.5:
                return "%.2f %s" % (t / div, unit)
        return "%.2e s" % t
    print("    %-5d %-14.3g %-14.3g %-16s %-20s"
          % (b, ops, bsgs, fmt_time(tk), fmt_time(tb)))
    table.append(dict(b=b, kang_ops=ops, bsgs_ops=bsgs, t_kang=tk, t_bsgs=tb,
                      t_kang_s=fmt_time(tk), t_bsgs_s=fmt_time(tb)))

# ---------------- baseline ---------------------------------------------
print("\n[6] BASELINE -- full-group generic cost (b = 256)")
n_bits = 256
base = 1.5 * math.sqrt(2) ** n_bits     # c*sqrt(n) with c = 1.5 (measured for rho/BSGS)
print("    n = 2^256, sqrt(n) = 2^128 = %.4g" % (math.sqrt(2) ** 256))
print("    generic BSGS/rho baseline ~ 1.5 * sqrt(n) = %.4g group ops" % base)
print("    at %.0f ops/s that is %.3e s = %.3e years" % (RS, base / RS, base / RS / (86400 * 365.25)))
print("    (memory for BSGS at b=256: 2^128 entries -- infeasible;")
print("     Pollard rho is the practical generic method, O(1) memory)")

# largest feasible b today
print("\n    'largest feasible b today' (kangaroo, full trap table):")
budget = 1.0 * 365.25 * 86400        # 1 year on this machine, one core
bfeas = 2 * math.log(RS * budget / C, 2)
print("       one core, one year of the MEASURED rate: b ~ %.1f" % bfeas)
for cores, yrs in ((1, 1), (100, 1), (10000, 1), (1000000, 1)):
    bf = 2 * math.log(RS * cores * yrs * 365.25 * 86400 / C, 2)
    print("       %8d cores, 1 year : b ~ %.1f" % (cores, bf))

# ---------------- BSGS law + memory ------------------------------------
print("\n[7] BSGS ON THE INTERVAL (counterpoint: cheap ops, sqrt(w) memory)")
bl = load("bsgs_interval_run1.json")
BS = []
if bl:
    BS = summarise(bl['rows'], 12)
    xs3 = [math.log(s['w'], 2) for s in BS]
    ys3 = [s['log2_ops'] for s in BS]
    b3, c3, r23, n3, se3 = fit(xs3, ys3)
    print("   fit log2(BSGS ops) = c + beta*log2(w):  beta = %.5f +/- %.5f  c = %.4f  R^2 = %.6f"
          % (b3, se3, c3, r23))
    print("   kangaroo/BSGS ops ratio at matched b: %.2f x"
          % (sum(s['mean_ops'] / t['mean_ops']
                 for s, t in zip([x for x in S if x['b'] in (16, 20, 24, 28, 32, 36)],
                                 [x for x in BS if x['b'] in (16, 20, 24, 28, 32, 36)])
                 ) / 6.0))
    print("    %-5s %-12s %-14s %-14s %-14s" % ("b", "m=sqrt(w)", "BSGS ops", "BSGS mem(MB)", "kang traps"))
    for s in BS:
        m = int(math.ceil(math.sqrt(s['w'])))
        mm = max(4, int(round(2.0 * math.sqrt(s['w']))))
        K = max(2, int(round(3.0 * ((mm + 1) // 2))))
        mem_bsgs = m * 61.0 / 1048576.0
        print("    %-5d %-12d %-14.0f %-14.3f %-14.0f (%.0f MB)"
              % (s['b'], m, s['mean_ops'], mem_bsgs, float(K), K * 61.0 / 1048576.0))
else:
    print("    (no bsgs data)")

# ---------------- DP frontier ------------------------------------------
print("\n[8] DISTINGUISHED-POINT FRONTIER (memory vs ops)")
dp = load("kangaroo_dp_run1.json")
if dp:
    print("    %-4s %-6s %-9s %-12s %-10s %-10s"
          % ("b", "dplen", "traps", "mem(MB)", "2^ops", "rate"))
    seen = set()
    for r in sorted(dp['rows'], key=lambda r: (r['b'], r['dplen'])):
        k = (r['b'], r['dplen'])
        if k in seen:
            continue
        seen.add(k)
        sub = [x for x in dp['rows'] if x['b'] == r['b'] and x['dplen'] == r['dplen']]
        ok = sum(1 for x in sub if x['ok'])
        traps = sum(x['ntraps'] for x in sub) / len(sub)
        ops = sum(x['total_ops'] for x in sub) / len(sub)
        mem = traps * 61.0 / 1048576.0
        print("    %-4d %-6d %-9.0f %-12.4f %-10.2f %d/%d"
              % (r['b'], r['dplen'], traps, mem, math.log(ops, 2), ok, len(sub)))
    print("\n    collapse (zero traps -> impossible):")
    for b in sorted(set(r['b'] for r in dp['rows'])):
        zero = [r['dplen'] for r in dp['rows']
                if r['b'] == b and r['ntraps'] == 0]
        if zero:
            sub = [r for r in dp['rows'] if r['b'] == b and r['dplen'] == min(zero)]
            print("      b=%-3d : dplen >= %d gives no traps at all (K=2^%.1f)"
                  % (b, min(zero), math.log(sub[0]['K'], 2)))

out = dict(beta=beta, c=c, r2=r2, se_beta=se, n=n,
           sizes=[s['b'] for s in S], summary=S, table=table,
           C=C, rate_kang=RS, rate_bsgs=BR)
with open(os.path.join(LOGDIR, "analysis.json"), "w") as fh:
    json.dump(out, fh, indent=1)
print("\nwrote analysis.json")
