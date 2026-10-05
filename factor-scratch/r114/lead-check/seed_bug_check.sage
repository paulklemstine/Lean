#!/usr/bin/env sage
# r114 lead-check: independent verification of the seed-overwrite defect in
# gifp.sage line 49. Self-contained; run with sage (never exec a fragment).
#
# CLAIM: generate_gifp_instance(seed=S) is NOT reproducible. Line 49, inside the
# retry loop, executes `seed = int(time.time()*1e6)`, discarding the caller's seed
# whenever the bit-length check fails. Since exact bit budgets are the exception,
# the retry path is the NORM, so the same seed yields different instances.
#
# FALSIFIER: if two calls with the same seed return the same N1, the claim is false.

import sys
sys.path.insert(0, '/home/raver1975/lean/Experiments/UMWWindow/gifp_ref')
from sage.all import ZZ, load
load('/home/raver1975/lean/Experiments/UMWWindow/gifp_ref/gifp.sage')

NB, ALPHA, GAMMA, B1, B2 = 96, 0.20, 0.05, 0.10, 0.15
S = 12345

print("calling generate_gifp_instance TWICE with the SAME seed=%d ..." % S)
runs = []
for i in (1, 2):
    (p1, q1, N1), (p2, q2, N2), share, sol = generate_gifp_instance(
        NB, ALPHA, GAMMA, B1, B2, seed=S, max_attempts=10)
    if N1 == 0:
        print("  run %d: generator REFUSED (returned zero) -- raise max_attempts" % i)
        sys.exit(1)
    runs.append((ZZ(N1), ZZ(N2)))
    print("  run %d: N1 bits=%d  N1[:24]=%s..." % (i, ZZ(N1).nbits(), str(ZZ(N1))[:24]))

same = runs[0] == runs[1]
print()
print("REPRODUCIBLE with a fixed seed? %s" % same)
print()
if not same:
    print("*** SEED-OVERWRITE DEFECT CONFIRMED ***")
    print("The caller's seed is discarded by gifp.sage:49 inside the retry loop.")
    print("Consequence for this campaign: ANY GIFP count that crossed a retry was")
    print("an UNSEEDED count. This is the mechanical cause of the recorded drift")
    print("(13/40 -> 12/40; 17/40 withdrawn; 3/8 -> 5/8).")
    print()
    print("THE FIX (one line, gifp.sage:49 and :23, example.sage:22 and :48):")
    print("    seed = int(time.time() * 1e6)")
    print("  becomes, inside the retry loop:")
    print("    seed = seed + attempts")
else:
    print("Claim REFUTED: same seed gave the same instance.")
print()
print("Also note gifp.sage:23 does the same when seed is None, so an UNSEEDED")
print("call is unreproducible by construction -- and gifp.sage:49 makes a SEEDED")
print("call unreproducible too whenever the bit budget is not exact.")