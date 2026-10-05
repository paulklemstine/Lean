"""
Self-test / controls for stange.py.  Run:  python3 selftest.py
Every test prints PASS/FAIL.  A null result is only publishable because T6
shows the harness cannot manufacture factors, and T1 shows it fires on the
paper's own example.
"""
import math
import sys

import sympy

from stange import (substream, gen_rsa, algorithm_2_2, factor_from_multiple,
                    _order_mod, v2, _prime_list, relation_search)

FAIL = 0


def check(name, cond, detail=""):
    global FAIL
    print(f"  {'PASS' if cond else 'FAIL'}  {name}   {detail}")
    if not cond:
        FAIL += 1


print("=" * 72)
print("T1  POSITIVE CONTROL -- the paper's OWN worked example (Stange p.7)")
print("=" * 72)
# Paper Section 5, verbatim numbers:
#   n = 62389, g = 43, B = 50 -> b = 15 primes 2<=p<=47, c = 10, 25 relations,
#   "With 188 smoothness tests"; alphas listed; gcd = 15400;
#   43^15400 = 1, 43^7700 = 51174 != +-1 mod n, gcd(51174-1, 62389) = 701.
N, g, B, c = 62389, 43, 50, 10
check("T1a 62389 = 701 * 89 (paper p.7)", 701 * 89 == 62389)
check("T1b 43^15400 = 1 mod 62389 (paper p.7)", pow(g, 15400, N) == 1)
check("T1c 43^7700 = 51174 mod 62389 (paper p.7)", pow(g, 7700, N) == 51174)
check("T1d gcd(51174-1,62389) = 701 (paper p.7)",
      math.gcd(51174 - 1, 62389) == 701)
# and the published relation vector set factorises back to g^x mod n
# Reproduce the pipeline end to end with our own sampler.
res = algorithm_2_2(N, g, B, c, substream(1, "T1"), verify=True)
check("T1e our Alg 2.2 returns a valid multiple G of ord(g)",
      res["G"] > 0 and pow(g, res["G"], N) == 1,
      f"G={res['G']} b={res['b']} trials={res['trials']}")
f, why = factor_from_multiple(g, N, res["G"])
check("T1f our Alg 2.2 + strip factors 62389", f == 701, f"f={f} why={why}")

# Reproduce the paper's PRINTED OUTPUT rather than its printed input.
# The relation list in the PDF is typeset with superscripts; `pdftotext`
# merges them (it renders `43^5571 = 2^3 . 3^1 . 7^5 . 11^1` as
# "4355571 = 23 . 33 . 7 . 29"), so transcribing the exponent vectors by
# hand from the text layer is UNRELIABLE -- exactly the OCR trap the
# FANOUT_BRIEF warns about.  Instead we check the paper's OUTPUT, which is
# plain digits and survives pdftotext intact: the 11 printed alphas and
# their gcd.  (Read off the 300dpi render lit/pg7_top.png.)
print()
print("  -- the paper's PRINTED OUTPUT, verified arithmetically --")
paper_alphas = [1201200, 631400, -61600, 708400, 1232000, 323400,
                277200, 754600, 169400, 662200, 1309000]
check("T1g all 11 printed alphas satisfy 43^alpha = 1 mod 62389",
      all(pow(g, a, N) == 1 for a in paper_alphas),
      f"{sum(pow(g,a,N)==1 for a in paper_alphas)}/11")
Gg = 0
for a in paper_alphas:
    Gg = math.gcd(Gg, abs(a))
check("T1h gcd of the 11 printed alphas = 15400 (paper p.7)",
      Gg == 15400, f"got {Gg}")
check("T1i b = pi(50) = 15 primes < 50 (paper p.7)",
      len(_prime_list(50)) == 15, f"b={len(_prime_list(50))}")
# and our OWN independent run lands on the paper's G exactly
check("T1j our sampler reproduces the paper's G = 15400",
      res["G"] == 15400, f"ours={res['G']} paper=15400")

print()
print("=" * 72)
print("T2  NEGATIVE CONTROL -- the harness cannot invent a factor")
print("=" * 72)
inv = 0
tot = 0
for s in range(12):
    Nx, px, qx = gen_rsa(24, 1000 + s, "T2")
    rng = substream(s, "T2junk")
    bogus = rng.randrange(2, Nx)
    r = algorithm_2_2(Nx, 2, 24, 4, rng, verify=True)
    tot += 1
    if not r["completed"]:
        continue
    f, why = factor_from_multiple(2, Nx, r["G"])
    if f is not None and f * (Nx // f) != Nx:
        inv += 1
check("T2a no unverified factor is ever reported",
      inv == 0, f"{inv}/{tot} bogus")
# also: feeding garbage multiples must not produce a factor
inv2 = 0
for s in range(30):
    Nx, px, qx = gen_rsa(24, 2000 + s, "T2b")
    M = substream(s, "T2garbage").randrange(2, 1 << 40)
    f, _ = factor_from_multiple(2, Nx, M)
    if f is not None and f * (Nx // f) != Nx:
        inv2 += 1
check("T2b 30 random non-multiples give no verified factor", inv2 == 0,
      f"{inv2}/30")
check("T2c factor_from_multiple rejects a non-multiple",
      factor_from_multiple(2, 62389, 15401)[0] is None)

print()
print("=" * 72)
print("T3  the v2 law -- success is EXACTLY v2(ord_p g) != v2(ord_q g)")
print("=" * 72)
agree = dis = 0
ran = 0
for s in range(12):
    Nx, px, qx = gen_rsa(26, 3000 + s, "T3")
    r = algorithm_2_2(Nx, 2, 30, 5, substream(s, "T3"), verify=True)
    if not r["completed"]:
        continue
    ran += 1
    op, oq = _order_mod(2, px), _order_mod(2, qx)
    pred = v2(op) != v2(oq)
    f, _ = factor_from_multiple(2, Nx, r["G"])
    got = f is not None
    if f is not None:
        assert f * (Nx // f) == Nx
    agree += (pred == got)
    dis += (pred != got)
check("T3a v2-law predicts success at 2^26", dis == 0 and ran == 12,
      f"agree={agree} disagree={dis} ran={ran}")
# and at a second size
agree = dis = ran = 0
for s in range(12):
    Nx, px, qx = gen_rsa(30, 3500 + s, "T3b")
    r = algorithm_2_2(Nx, 3, 34, 6, substream(s, "T3b"), verify=True)
    if not r["completed"]:
        continue
    ran += 1
    op, oq = _order_mod(3, px), _order_mod(3, qx)
    pred = v2(op) != v2(oq)
    f, _ = factor_from_multiple(3, Nx, r["G"])
    if f is not None:
        assert f * (Nx // f) == Nx
    agree += (pred == (f is not None)); dis += (pred != (f is not None))
check("T3b v2-law predicts success at 2^30", dis == 0 and ran == 12,
      f"agree={agree} disagree={dis} ran={ran}")

print()
print("=" * 72)
print("T4  ord(g) | G  -- paper section 2.1, asserted on EVERY trial")
print("=" * 72)
bad = 0
n_t = 0
for bits in (22, 26, 30, 34):
    for s in range(6):
        Nx, px, qx = gen_rsa(bits, 4000 + s, f"T4{bits}")
        for B in (26, 32, 40):
            r = algorithm_2_2(Nx, 2, B, 5, substream(s, f"T4:{bits}:{B}"),
                              verify=True)
            n_t += 1
            if r["completed"] and (r["G"] == 0 or pow(2, r["G"], Nx) != 1):
                bad += 1
check("T4a ord(2) | G on every completed run", bad == 0,
      f"{bad}/{n_t} bad, {n_t} runs")

print()
print("=" * 72)
print("T5  ground truth: p*q == N, and _order_mod agrees with a brute force")
print("=" * 72)
badt = 0
for s in range(8):
    Nx, px, qx = gen_rsa(20 + 2 * s, 5000 + s, "T5")
    badt += (px * qx != Nx)
check("T5a p*q == N on 8 moduli", badt == 0)
# brute-force order mod a prime, vs _order_mod
m = 1000003
g0 = 5
brute = next(k for k in range(1, m) if pow(g0, k, m) == 1)
check("T5b _order_mod == brute force mod a prime", brute == _order_mod(g0, m),
      f"brute={brute} got={_order_mod(g0, m)}")

print()
print("=" * 72)
print("T6  determinism of the RNG across processes")
print("=" * 72)
a = algorithm_2_2(62389, 43, 50, 10, substream(1, "T1"), verify=True)
b = algorithm_2_2(62389, 43, 50, 10, substream(1, "T1"), verify=True)
check("T6a same seed -> same G, same trials",
      a["G"] == b["G"] and a["trials"] == b["trials"],
      f"{a['G']}=={b['G']}, {a['trials']}=={b['trials']}")
import subprocess
import os
# r112's reproducibility bug: random.Random(x.__hash__()) is process-
# randomized under PYTHONHASHSEED, so two "same-seed" passes disagreed
# (28/40 vs 33/40).  Our substream is sha256-derived, so it must be
# IDENTICAL under two different PYTHONHASHSEED values.
probe = ("import sys; sys.path.insert(0,'.');\n"
         "from stange import substream\n"
         "r=substream(20261005,'probe')\n"
         "print(r.randrange(1,10**9), r.randrange(1,10**9))")
outs = []
for hs in ("0", "1", "12345"):
    e = dict(os.environ, PYTHONHASHSEED=hs)
    outs.append(subprocess.run([sys.executable, "-c", probe], env=e,
                               capture_output=True, text=True).stdout.strip())
check("T6b substream identical under PYTHONHASHSEED=0,1,12345",
      len(set(outs)) == 1, f"{outs}")
# and the failing pattern really would have broken (positive control for
# the control): random.Random((seed,label).__hash__()) DOES vary.
probe2 = ("import random\n"
          "print(random.Random((20261005,'probe').__hash__()).randrange(1,10**9))")
outs2 = [subprocess.run([sys.executable, "-c", probe2],
                        env=dict(os.environ, PYTHONHASHSEED=hs),
                        capture_output=True, text=True).stdout.strip()
         for hs in ("0", "1", "12345")]
check("T6c the r112 __hash__() pattern really does vary (control fires)",
      len(set(outs2)) > 1, f"{outs2}")

print()
print("=" * 72)
print(f"{'ALL PASS' if FAIL == 0 else str(FAIL) + ' FAILURES'}")
print("=" * 72)
sys.exit(1 if FAIL else 0)