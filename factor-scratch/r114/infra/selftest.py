"""
selftest.py -- ACCEPTANCE TEST for the r114 shared infrastructure.

    cd /home/raver1975/lean/factor-scratch/r114/infra && python3 selftest.py

Every component is exercised against a case where the correct answer is known.
A harness that has never been shown to fire has measured nothing, so each
check here is stated as a MUST, and the script exits non-zero if any fails.

Coverage:
  1. baseline MUST factor a 60-bit number
  2. baseline MUST NOT factor a 2048-bit RSA modulus within T
  3. baseline's timeout MUST actually reclaim CPU and leave no orphan
  4. every backend MUST find a planted 20-bit factor (positive control)
  5. verify MUST reject wrong arithmetic
  6. verify MUST flag a small-factor instance VACUOUS automatically
  7. generator MUST be deterministic and MUST refuse a vacuous size
  8. double_run MUST catch simulated drift and MUST ignore timing jitter
  9. rate() CI MUST NOT collapse to a point at 0/n
"""
import os
import random
import subprocess
import sys
import time

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from baseline import baseline_factor, fmt          # noqa: E402
from verify import verify_claim, verdict_line      # noqa: E402
from instances import gen_instance, gen_family, gen_gifp_like, MIN_SMALL_BITS  # noqa: E402
from doublerun import double_run, rate, report     # noqa: E402

FAIL = []


def check(name, cond, detail=""):
    status = "PASS" if cond else "FAIL"
    print("  [%s] %s%s" % (status, name, ("  -- " + detail) if detail else ""))
    if not cond:
        FAIL.append(name)
    return cond


def hdr(t):
    print()
    print("=" * 78)
    print(t)
    print("=" * 78)


def mk(bits, seed):
    from sympy import nextprime
    rng = random.Random(seed)
    while True:
        p = int(nextprime(rng.randrange(2 ** (bits // 2 - 1), 2 ** (bits // 2))))
        q = int(nextprime(rng.randrange(2 ** (bits // 2 - 1), 2 ** (bits // 2))))
        N = p * q
        if N.bit_length() == bits:
            return N, p, q


# ---------------------------------------------------------------- 1
hdr("1. baseline MUST factor a 60-bit number")
N60, p60, q60 = mk(60, 12345)
st = baseline_factor(N60, T=60.0, backend="sympy")
print("  N = %d (%d bits)" % (N60, N60.bit_length()))
print("  -> %-9s | %s" % (st["status"], fmt(st)))
check("60-bit factored", st["status"] == "factored")
check("multiply-back verified inside baseline", st["status"] != "factored"
      or st["factors"][0] * st["factors"][1] == N60)

# ---------------------------------------------------------------- 2
hdr("2. baseline MUST time out on a 2048-bit RSA modulus")
N2048, _, _ = mk(2048, 999)
print("  N = 2048-bit RSA modulus (%d decimal digits)" % len(str(N2048)))
for b in ("ecm", "sympy", "pari", "rho"):
    st = baseline_factor(N2048, T=20.0, backend=b)
    print("  %-6s -> %-9s | %s" % (b, st["status"], fmt(st)))
    check("2048-bit not factored by %s" % b, st["status"] != "factored")

# ---------------------------------------------------------------- 3
hdr("3. the timeout MUST reclaim CPU (no orphan keeps burning it)")
t0 = time.time()
st = baseline_factor(N2048, T=5.0, backend="sympy")
el = time.time() - t0
print("  asked T=5.0s, returned in %.2fs, status=%s" % (el, st["status"]))
check("returned promptly", el < 12.0, "took %.2fs" % el)
check("status is gave_up", st["status"] == "gave_up")
time.sleep(1.5)
out = subprocess.run(
    ["bash", "-c",
     "ps -eo pid,args --no-headers | grep -F '_baseline_worker.py' | grep -v grep | wc -l"],
    capture_output=True, text=True)
n = int(out.stdout.strip() or 0)
print("  live _baseline_worker.py processes: %d" % n)
check("no orphaned worker", n == 0)

# ---------------------------------------------------------------- 4
hdr("4. every backend MUST find a planted 20-bit factor (POSITIVE CONTROL)")
from sympy import nextprime
rng = random.Random(7)
while True:
    sp = int(nextprime(rng.randrange(2 ** 19, 2 ** 20)))
    lq = int(nextprime(rng.randrange(2 ** 199, 2 ** 200)))
    Nvac = sp * lq
    if Nvac.bit_length() == 220:
        break
print("  N = 220 bits with a planted 20-bit factor")
for b in ("ecm", "sympy", "pari", "rho"):
    st = baseline_factor(Nvac, T=60.0, backend=b)
    print("  %-6s -> %-9s | %s" % (b, st["status"], fmt(st)))
    check("%s fires on the planted factor" % b, st["status"] == "factored")
    check("%s found the RIGHT factor" % b,
          st["status"] != "factored" or st["factors"][0] * st["factors"][1] == Nvac)
    check("%s flags it VACUOUS" % b,
          st["status"] != "factored" or st["small_factor_bits"] <= 40)

# ---------------------------------------------------------------- 5
hdr("5. verify MUST reject wrong arithmetic")
r = verify_claim(N60, p60, q60 - 2, baseline_T=5.0)
print(" ", verdict_line(r))
check("bad p*q -> INVALID", r["verdict"] == "INVALID")
r = verify_claim(N60, p60, p60, baseline_T=5.0)
check("p == q -> INVALID", r["verdict"] == "INVALID")

# ---------------------------------------------------------------- 6
hdr("6. verify MUST flag a small-factor instance VACUOUS automatically")
r = verify_claim(Nvac, sp, lq, baseline_T=30.0, backend="sympy")
print(" ", verdict_line(r))
check("20-bit factor -> VACUOUS", r["verdict"] == "VACUOUS")
check("verdict cites the bit count", any("bits" in x for x in r["reasons"]))

# ---------------------------------------------------------------- 7
hdr("7. generator: determinism + the 2^40 guard")
a = gen_instance(nbits=800, small_bits=60, seed=42)
b = gen_instance(nbits=800, small_bits=60, seed=42)
c = gen_instance(nbits=800, small_bits=60, seed=43)
print("  seed42 N=%d... (%d bits, small %d bits)"
      % (a["N"] % 10**6, a["N"].bit_length(), a["p"].bit_length()))
check("same seed -> same N", a["N"] == b["N"])
check("different seed -> different N", a["N"] != c["N"])
check("exact bit lengths", a["N"].bit_length() == 800 and a["p"].bit_length() == 60)
check("multiply-back", a["N"] == a["p"] * a["q"])
check("small factor > 2^40", a["p"].bit_length() > 40)
try:
    gen_instance(nbits=800, small_bits=30, seed=1)
    check("guard refuses a 30-bit small factor", False)
except ValueError as e:
    print("  ValueError:", e)
    check("guard refuses a 30-bit small factor", True)
try:
    gen_gifp_like(nbits=200, alpha=0.10, gamma=0.10, beta2=0.20, seed=5)
    check("guard refuses the n=200/alpha=0.1 regime that voided r110", False)
except ValueError as e:
    print("  ValueError:", e)
    check("guard refuses the n=200/alpha=0.1 regime that voided r110", True)
fam = gen_family(n=12, nbits=800, small_bits=60, seed0=1000)
check("12-seed family, all distinct", len({i["N"] for i in fam}) == 12)
check("12-seed family, all non-vacuous",
      all(i["p"].bit_length() > 40 for i in fam))
g = gen_gifp_like(nbits=800, alpha=0.10, gamma=0.10, beta2=0.20, seed=5)
check("gifp-shaped n=800 has an 80-bit small factor", g["p"].bit_length() == 80)
check("gifp-shaped instance multiply-back",
      g["N"] == g["p"] * g["q"] and g["N2"] == g["p2"] * g["q2"])

# ---------------------------------------------------------------- 8
hdr("8. double_run: catches drift, ignores timing jitter")
r = double_run(lambda s: {"hit": (s * 7) % 3 == 0}, seeds=range(12))
check("stable fn agrees", r["agree"])
_calls = {"n": 0}


def flaky(s):
    _calls["n"] += 1
    return {"hit": ((s * 7) % 3 == 0) if _calls["n"] <= 12 else ((s * 7) % 3 == 1)}


r = double_run(flaky, seeds=range(12), label="simulated unseeded drift")
check("unstable fn is FLAGGED", not r["agree"])
check("flaky seeds are named", bool(r["flaky_seeds"]))
print(report(r))
r = double_run(lambda s: time.sleep(0.001 * (s % 3)) or {"hit": True},
               seeds=range(6), label="jitter only")
check("timing jitter is NOT a disagreement", r["agree"])

# ---------------------------------------------------------------- 9
hdr("9. rate(): a CI that does not collapse at the boundary")
check("0/12 CI upper > 0.10", rate([False] * 12)["ci95"][1] > 0.10)
check("12/12 CI lower < 0.90", rate([True] * 12)["ci95"][0] < 0.90)
print("  0/12  -> %s" % rate([False] * 12)["text"])
print("  12/12 -> %s" % rate([True] * 12)["text"])

# ---------------------------------------------------------------- verdict
hdr("VERDICT")
if FAIL:
    print("  %d CHECK(S) FAILED:" % len(FAIL))
    for f in FAIL:
        print("    - %s" % f)
    sys.exit(1)
print("  ALL CHECKS PASS -- the r114 infrastructure is validated.")
print()
print("  Ground truth for what each piece does:")
print("    baseline_factor  : generic factoring with a HARD wall-clock kill")
print("    verify_claim     : arithmetic gate + vacuity gate, one verdict string")
print("    gen_instance     : seeded, small factor GUARANTEED > 2^%d bits" % MIN_SMALL_BITS)
print("    double_run       : exact-agreement check on a per-seed outcome vector")
sys.exit(0)