import math
from mpmath import mp, mpf
mp.dps=40; LN2=math.log(2)
print("=== #522 sec 1.1 table, recomputed correctly ===")
print("  y = exp[(1/sqrt2)(ln n lnln n)^(1/2)] ; pi(y) ~ y/ln y ; runtime = exp[(2sqrt2)(ln n lnln n)^(1/2)]")
paper={256:(26.5,123.7),1024:(64.0,278.5),2048:(97.4,414.2),4096:(146.5,613.1)}
for bits,(pv,pa) in paper.items():
    L=mpf(bits)*mpf(LN2); S=mpf(math.sqrt(float(L*mp.log(L))))
    lny   = S/mpf(math.sqrt(2))                 # ln y
    ly    = lny/LN2                            # log2 y
    lpi   = ly - mp.log(lny)/mp.log(2)                  # log2 pi(y)
    lalg  = 2*mpf(math.sqrt(2))*S/LN2          # log2 runtime
    print(f"  n={bits:>5} log2 y={float(ly):>7.2f} | log2 pi(y): paper={pv:>6} mine={float(lpi):>7.2f} "
          f"{'OK' if abs(float(lpi)-pv)<0.06 else '**MISMATCH**'}"
          f" | log2 runtime: paper={pa:>6} mine={float(lalg):>7.2f} {'OK' if abs(float(lalg)-pa)<0.06 else '**MISMATCH**'}"
          f" | dominated={float(lalg)>float(lpi)}")
print()
print("  TIGHTEST case check (smallest n in the table dominates the least):")
# ratio of runtime to verification, and where it crosses
for bits in (256,512,1024,2048,4096,8192,16384):
    L=mpf(bits)*mpf(LN2); S=mpf(math.sqrt(float(L*mp.log(L))))
    lny=S/mpf(math.sqrt(2)); lpi=lny/LN2-mp.log(lny)/mp.log(2); lalg=2*mpf(math.sqrt(2))*S/LN2
    print(f"    n={bits:>6}: log2(runtime) - log2(pi(y)) = {float(lalg-lpi):+8.2f}")
