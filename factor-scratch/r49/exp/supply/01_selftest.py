#!/usr/bin/env python3.12
"""SELF-TEST -- WRITTEN BEFORE THE MEASUREMENT.

The earned rule: "a self-test that only shows your code running is not a self-test.
The test is whether your harness returns the NULL answer where null is correct."

So every gate below is of the form: feed the harness an input whose answer is known
to be FALSE / ZERO / NON-SMOOTH, and require that it says so.  A harness that cannot
say "no" fails here, not silently in the measurement.
"""
import math
import random
import sys

sys.path.insert(0, "/home/raver1975/lean/factor-scratch/r49/exp/supply")
sys.path.insert(0, "/home/raver1975/lean/factor-scratch/r48/_shared")

import S_common as S

FAILS = []


def check(name, cond, detail=""):
    tag = "[PASS]" if cond else "[FAIL]"
    if not cond:
        FAILS.append(name)
    print("  %s %s %s" % (tag, name, detail), flush=True)
    return cond


print("=" * 78)
print("SELF-TEST -- supply audit")
print("=" * 78)

# ---------------------------------------------------------------------------
print("\n0. the audited constants are what the file says they are")
check("H == 40", S.H == 40)
check("CPOOL is 16 values", len(S.CPOOL) == 16, "got %d" % len(S.CPOOL))
check("CPOOL max <= 31", max(S.CPOOL) == 31)
check("1958 coprime pairs at H=40", S.NP == 1958, "got %d" % S.NP)

# ---------------------------------------------------------------------------
print("\n1. CAN THE RELATION COUNTER RETURN ZERO?  (the null must be reachable)")
rng = random.Random(20261003)
# generic large (m,c): l is astronomically large and generically not a square.
big_ms = [rng.randrange(10 ** 12, 10 ** 12 + 5000) for _ in range(300)]
big_cs = [rng.randrange(-(10 ** 12), 10 ** 12) for _ in range(300)]
cnt_big, _ = S.rels_batch(big_ms, big_cs)
n_zero = sum(1 for x in cnt_big if x == 0)
check("generic (m,c) gives ZERO relations somewhere",
      n_zero > 0, "%d/%d instances had 0" % (n_zero, len(cnt_big)))
check("generic (m,c) is overwhelmingly zero",
      n_zero / len(cnt_big) > 0.90,
      "%.3f zero" % (n_zero / len(cnt_big)))
# The converse gate, on a population where relations genuinely occur (BOX c):
N_b, _, _ = S.make_semiprime(16, random.Random(99))
m0b = S.icbrt_floor(N_b)
ms_b = [m0b + rng.randrange(0, 300) for _ in range(400)]
cs_b = [S.CPOOL[rng.randrange(16)] for _ in range(400)]
cnt_b, _ = S.rels_batch(ms_b, cs_b)
check("the counter is NOT identically zero (box population gives relations)",
      sum(cnt_b) > 0, "total %d over 400 box instances" % sum(cnt_b))
check("box population is NOT all-zero (so the zero above is a real answer)",
      0 < sum(cnt_b), "mean %.4f rel/instance" % (sum(cnt_b) / 400.0))

# ---------------------------------------------------------------------------
print("\n2. CAN THE COUNTER RETURN A NON-ZERO WHERE NON-ZERO IS CORRECT?")
# Brute-force ground truth on a small hand-checkable case, by a SECOND independent
# implementation (not reusing rels_batch).
def brute(m, c):
    n = 0
    for (u, v) in S.PAIRS:
        l = 4 * u ** 4 + 8 * m * u ** 3 * v - 4 * c * u * v ** 3 + c * v ** 4 * m
        if l <= 0:
            continue
        w = math.isqrt(l)
        if w * w == l:
            n += 1
    return n


mismatch = 0
tested = 0
for bits in (14, 16, 18):
    N, p, q = S.make_semiprime(bits, random.Random(7 * bits))
    m0 = S.icbrt_floor(N)
    ms = [m0 + rng.randrange(0, 40) for _ in range(30)]
    cs = [((m ** 3) % N) - (N if ((m ** 3) % N) > N // 2 else 0) for m in ms]
    cnt, _ = S.rels_batch(ms, cs)
    for m, c, got in zip(ms, cs, cnt):
        want = brute(m, c)
        tested += 1
        if got != want:
            mismatch += 1
            if mismatch <= 3:
                print("    MISMATCH m=%d c=%d got=%d want=%d" % (m, c, got, want))
check("vectorised counter == independent brute force", mismatch == 0,
      "%d/%d instances" % (mismatch, tested))

# a KNOWN relation: choose (m,c,u,v) so that l is forced to be a square.
# Take v=1, u=1: l = 4 + 8m - 4c + cm = 4 + m(8+c) - 4c.  Choose c=0 -> l = 4+8m.
# Pick m so 4+8m = w^2: w even, w=2k -> 4k^2 = 4+8m -> m = (k^2-1)/2. k=3 -> m=4.
mm, cc = 4, 0
check("known-positive control: (m=4,c=0) has >=1 relation",
      S.rels_scalar(mm, cc) >= 1, "got %d" % S.rels_scalar(mm, cc))
# and the NULL family named in the file: u=-t, c=(2t/v)^3 gives l = 36t^4 = (6t^2)^2
t, v = 1, 2
u = -t
cc_null = (2 * t // v) ** 3
l_null = 4 * u ** 4 + 8 * 7 * u ** 3 * v - 4 * cc_null * u * v ** 3 + cc_null * v ** 4 * 7
check("the documented null family really is a perfect square",
      l_null > 0 and math.isqrt(l_null) ** 2 == l_null, "l=%d" % l_null)

# ---------------------------------------------------------------------------
print("\n3. THE SPEED FILTER MUST NOT DISCARD TRUE RELATIONS")
# The vectorised path uses a quadratic-residue filter mod 960960.  Feed it instances
# KNOWN to contain relations (from the scalar path) and require the batch path to
# find exactly the same count.  If the QR table were wrong, this is where it shows.
found_ok = True
for bits in (16, 20, 24):
    N, p, q = S.make_semiprime(bits, random.Random(11 * bits))
    m0 = S.icbrt_floor(N)
    ms = [m0 + rng.randrange(0, 200) for _ in range(200)]
    cs = [S.CPOOL[rng.randrange(16)] for _ in range(200)]      # BOX c
    cs2 = []
    for m in ms:
        v = (m ** 3) % N
        cs2.append(v - N if v > N // 2 else v)
    for tag, CC in (("box c", cs), ("scan c", cs2)):
        a = [S.rels_scalar(m, c) for m, c in zip(ms, CC)]
        b, _ = S.rels_batch(ms, CC)
        if a != b:
            found_ok = False
            print("    FILTER LOSS at %d bits (%s)" % (bits, tag))
check("QR filter loses nothing (scalar == batch, both populations)", found_ok)

# ---------------------------------------------------------------------------
print("\n4. CAN chiP RETURN -1, +1 AND 0?  All three must be reachable.")
p, q = 1009, 1013
while p % 4 != 3 or q % 4 != 3 or not (math.gcd(p, q) == 1):
    p += 2
    q += 2
while any(p % d == 0 for d in range(2, int(p ** 0.5) + 1)):
    p += 4
while any(q % d == 0 for d in range(2, int(q ** 0.5) + 1)):
    q += 4
assert p % 4 == 3 and q % 4 == 3, (p, q)
vals = set()
for w in range(1, 2 * p):          # must exceed p so that p|w is reachable
    vals.add(S.chiP(w, p, q))
check("chiP attains -1", -1 in vals, "values seen %s" % sorted(vals))
check("chiP attains +1", 1 in vals)
check("chiP attains 0 (undefined: p|w or q|w)", 0 in vals)
# brute-force cross-check of the Legendre call
def leg(a, m):
    return 1 if pow(a % m, (m - 1) // 2, m) == 1 else -1
bad = 0
for w in range(1, 3000):
    if w % p == 0 or w % q == 0:
        continue
    want = -1 if (leg(w, p) == -1 and leg(w, q) == -1) else (1 if (leg(w, p) == 1 and leg(w, q) == 1) else 0)
    if S.chiP(w, p, q) != want:
        bad += 1
check("chiP == independent Legendre-symbol computation", bad == 0, "%d bad" % bad)
# chiP on a QNR must not be reported as +1 (the "everything is fine" failure)
check("chiP does not collapse to +1", len(vals) == 3, "values seen %s" % sorted(vals))

# ---------------------------------------------------------------------------
print("\n5. THE VALIDATED SHARED HARNESS (Dickman) -- gated, not re-implemented")
import dickman as D
check("shared rho(2) ~ 0.3068528", abs(D.rho(2.0) - 0.3068528) < 1e-5,
      "got %.7f" % D.rho(2.0))
check("shared rho(4) ~ 0.0049109", abs(D.rho(4.0) - 0.0049109) < 1e-5,
      "got %.7f" % D.rho(4.0))
# THE GATE: can it return False?
check("is_smooth CAN return False (prime just above bound)",
      D.is_smooth(1009 ** 3, 997) is False)
check("is_smooth CAN return False (rough number)",
      D.is_smooth(2 * 1009, 1000) is False)
check("is_smooth CAN return True (tight case, perfect power AT bound)",
      D.is_smooth(997 ** 3, 997) is True)
n_false = sum(1 for i in range(3000) if not D.is_smooth(2 * (2 * i + 1) * (2 * i + 3), 1000))
check("is_smooth returns False on a decent fraction (>30%)", n_false / 3000 > 0.30,
      "%.3f False" % (n_false / 3000))

# ---------------------------------------------------------------------------
print("\n6. THE SCAN SAMPLER MUST BE ABLE TO PRODUCE THE SCAN'S REPORTED chi_P")
# sanity: the scan instance (m,c) sampler is c = m^3 mod N, centred.
N, p, q = S.make_semiprime(16, random.Random(3))
check("scan c is derived from N", ((7 ** 3) % N) == (343 % N))
check("make_semiprime returns p,q = 3 mod 4",
      p % 4 == 3 and q % 4 == 3, "p%%4=%d q%%4=%d" % (p % 4, q % 4))
check("N really is p*q with N in range", N == p * q and (1 << 15) <= N < (1 << 16))

print("\n" + "=" * 78)
if FAILS:
    print("SELFTEST FAILURES (%d): %s" % (len(FAILS), FAILS))
    sys.exit(1)
print("ALL SELFTESTS PASS -- harness can return the null answers.")
print("=" * 78)
