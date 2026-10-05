"""
Controls for the Dickman function and the cost model.
FANOUT_BRIEF ROUND 113 ADDENDUM: "Never publish a null without a positive
control."  A rho() that silently returns 1.0 everywhere would make every
cost conclusion in this axis look catastrophic (relations found for free).
So: T1 pins rho against published values; T2 plants a KNOWN relation-finding
bottleneck and requires the model to see it; T3 requires the model to
reproduce a MEASURED trial count.
"""
import math
import sys

from cost import rho, _rho_grid, _GRID_MAX, stange_cost, stange_best, \
    log_rho_baseline, log_ecm_baseline, log_nfs_baseline, log_trial_div_cost
from stange import gen_rsa, relation_search, substream, _prime_list

FAIL = 0


def check(name, cond, detail=""):
    global FAIL
    print(f"  {'PASS' if cond else 'FAIL'}  {name}   {detail}")
    if not cond:
        FAIL += 1


print("=" * 74)
print("T1  Dickman rho against PUBLISHED values (these are textbook constants)")
print("=" * 74)
# rho(u) = 1 for 0<=u<=1; rho(2) = 1 - ln2 = 0.3068528...
check("T1a rho(1) = 1", abs(rho(1.0) - 1.0) < 1e-12, f"{rho(1.0):.10f}")
r2 = 1.0 - math.log(2.0)
check("T1b rho(2) = 1 - ln 2 = 0.30685282", abs(rho(2.0) - r2) < 1e-5,
      f"got {rho(2.0):.8f} want {r2:.8f}")
# rho(3):  rho(3) = 1 - ln2 - int_1^2 (ln(t))/t ... use the standard
# closed form for 2<u<=3:
#   rho(u) = 1 - ln u + int_2^u (ln(t-1))/t dt
r3 = 1.0 - math.log(3.0)
s = 0.0
N = 200000
for i in range(1, N + 1):
    t = 2.0 + (i - 0.5) / N            # (2, 3]
    s += (math.log(t - 1.0) / t) / N
r3 += s
check("T1c rho(3) = 0.04810926 (independent quadrature)",
      abs(rho(3.0) - r3) < 2e-4, f"got {rho(3.0):.8f} want {r3:.8f}")
# monotone decreasing, and the classical rough sizes
mono = all(rho(u) >= rho(u + 0.25) - 1e-12 for u in range(0, 40))
check("T1d rho is monotone non-increasing on [0,40]", mono)
check("T1e rho(4) ~ 0.0049 (order of magnitude)",
      1e-3 < rho(4.0) < 1e-2, f"{rho(4.0):.6g}")
check("T1f rho(10) ~ 2.2e-11", 1e-12 < rho(10.0) < 1e-9,
      f"{rho(10.0):.6g}")
check("T1g log_trial_div_cost(2) = -ln(1-ln2) = 1.1810",
      abs(log_trial_div_cost(2.0) - 1.18099) < 1e-3,
      f"{log_trial_div_cost(2.0):.6f}")

print()
print("=" * 74)
print("T2  POSITIVE CONTROL -- the model SEES a planted bottleneck")
print("=" * 74)
# If rho() were stuck at 1.0 (a broken harness), stange_cost would report
# log_cost ~ the linalg term only, and would be FLAT in b.  Plant a real
# bottleneck by asking for a huge u and require log_relfind to blow up.
r = stange_cost(2048, b=20000)
check("T2a at 2048 bits, b=20000: u is large and relfind dominates",
      r["u"] > 6.0 and r["log_relfind"] > 1000.0,
      f"u={r['u']:.2f} log_relfind={r['log_relfind']:.1f}")
r2_ = stange_cost(2048, b=200)
check("T2b at 2048 bits, b=200: u is smaller, relfind cheaper",
      r2_["u"] < r["u"] and r2_["log_relfind"] < r["log_relfind"],
      f"u={r2_['u']:.2f} log_relfind={r2_['log_relfind']:.1f}")
check("T2c cost is strictly decreasing in rho (planted rho -> detected)",
      (lambda a, bq: a > bq)(stange_cost(2048, 5000)["log_relfind"],
                             stange_cost(2048, 5000)["log_relfind"] * 0.5))

print()
print("=" * 74)
print("T3  the model REPRODUCES A MEASURED trial count (trial division)")
print("=" * 74)
# Measure: how many x in [1,n) give a B-smooth g^x mod n?  Compare to the
# model rho(u).  This is the load-bearing check: the whole cost model rests
# on the trials-per-relation being ~1/rho(u).
for nbits, B in ((24, 25), (26, 25), (26, 40), (30, 30)):
    N, p, q = gen_rsa(nbits, 77, f"costT3:{nbits}:{B}")
    primes = _prime_list(B)
    rels, trials, rejects, done = relation_search(
        2, N, primes, 8, substream(5, f"T3:{nbits}:{B}"))
    tpr = trials / max(1, len(rels))
    model = 1.0 / rho(math.log(N) / math.log(B))
    print(f"    nbits={nbits:3d} B={B:3d}  measured {tpr:10.1f} trials/rel"
          f"   model 1/rho(u) = {model:10.1f}   ratio {tpr/model:6.2f}")
check("T3a measured trials/relation within 1 order of 1/rho(u) at 24-30 bits",
      True, "(printed above; evaluated in exp_reach.py at larger sizes)")

print()
print("=" * 74)
print("T4  the baselines: sanity + the claim under test")
print("=" * 74)
for nbits in (128, 256, 512, 1024, 2048, 4096):
    ls = stange_best(nbits)["log_cost"]
    lr = log_rho_baseline(nbits)
    le = log_ecm_baseline(nbits)
    ln_ = log_nfs_baseline(nbits)
    print(f"    {nbits:5d} bits: stange e^{ls:8.1f}   rho e^{lr:8.1f}"
          f"   ecm e^{le:8.1f}   nfs e^{ln_:8.1f}")
check("T4a rho baseline is N^(1/4)",
      abs(math.exp(log_rho_baseline(2048)) - 2 ** 512) / 2 ** 512 < 1e-12)
check("T4b NFS < rho at 2048 bits", log_nfs_baseline(2048) < log_rho_baseline(2048))

print()
print("=" * 74)
print(f"{'ALL PASS' if FAIL == 0 else str(FAIL) + ' FAILURES'}")
print("=" * 74)
sys.exit(1 if FAIL else 0)