"""(b) DECISIVE: is the two-factor leak an AMPLIFIER, or just a re-statement of p's bits?

The T3 trap: at kq=0 the joint interval pins p exactly, so "both" trivially wins.
That is knowing q, not an amplifier.  The correct question is INFORMATION-THEORETIC:

  Given p-leak of kp bits, does the q-leak of kq bits reduce the uncertainty about p
  BELOW what kp bits of p alone already give?

  p-leak kp  =>  |uncertainty about p| = 2^kp  (exactly).
  The q-leak cannot beat that, because the joint interval width measured in T2 is
     min(2^kp, 2^kq * p/q),
  i.e. the q-leak only helps when it is FINER than the p-leak, and then it helps by
  exactly the amount it is finer -- it is a SECOND, INDEPENDENT leak, not an amplifier.

DECISIVE TEST: at FIXED total information budget, does the pair beat the single leak?
  single: kp bits of p.
  pair  : kp bits of p AND kq bits of q, with kq <= kp (so the q-leak is COARSER).
  If the pair were an amplifier, it would beat the single leak at kq = kp.
Prediction (THEORY.md): at kq <= kp the pair is WORSE-OR-EQUAL, because the p-leak
already implies the q-leak to precision kp*(q/p) ~ kp.
"""
import sys, json, math
sys.path.insert(0, "/home/raver1975/lean/factor-scratch/r113/aux-amplifiers")
from core import make_instance, verified_factor

SEEDS = list(range(1, 13))
PBITS = 128
out = []

print("=== DECISIVE: joint interval width vs the p-leak alone, exact arithmetic ===", flush=True)
print("(width = number of integers p consistent with the leak; 2^kp = the single leak)", flush=True)
for kp in [48, 56, 60]:
    for kq in [24, 40, 48, 56, 60, 64]:
        wid = []
        for sd in SEEDS:
            p, q, N = make_instance(PBITS, sd)
            a = (p >> kp) << kp
            b = (q >> kq) << kq
            p_lo, p_hi = a, a + (1 << kp) - 1
            q_lo, q_hi = b, b + (1 << kq) - 1
            lo = max(p_lo, N // q_hi + 1)
            hi = min(p_hi, N // q_lo)
            assert lo <= p <= hi, "true p outside joint interval"
            wid.append(math.log2(hi - lo + 1))
        w = sum(wid) / len(wid)
        verdict = "SAME as p-leak" if abs(w - kp) < 0.35 else ("BETTER (q-leak active)" if w < kp - 0.35 else "WORSE")
        print(f"kp={kp} kq={kq:3d}  joint width 2^{w:6.2f}   (p-leak alone = 2^{kp})   {verdict}", flush=True)
        out.append(dict(kp=kp, kq=kq, joint_log2=round(w, 3), single_log2=kp))

print()
print("=== AMPLIFIER GAIN = log2(single-leak width) - log2(joint width) ===", flush=True)
print("An amplifier would show a LARGE POSITIVE gain that grows with kq.", flush=True)
for kp in [48, 56, 60]:
    gains = []
    for kq in [24, 40, 48, 56, 60]:
        g = []
        for sd in SEEDS:
            p, q, N = make_instance(PBITS, sd)
            a = (p >> kp) << kp
            b = (q >> kq) << kq
            lo = max(a, N // (b + (1 << kq)) + 1)
            hi = min(a + (1 << kp) - 1, N // b)
            assert lo <= p <= hi
            g.append(kp - math.log2(hi - lo + 1))
        gains.append((kq, sum(g) / len(g)))
    print(f"kp={kp}: " + "  ".join(f"kq={k}:gain={v:+.2f}b" for k, v in gains), flush=True)

json.dump(out, open("out_b3_decisive.json", "w"), indent=1)
print("wrote out_b3_decisive.json")
