print("== (A) the 8.46x origin: is MEASURED a CENSORED value? ==")
print("   C_fixed.txt:5  rho(u)=1.182e-05  MEASURED=1.000e-04  ratio=8.46")
print("   1.000e-04 == 1/10^4 exactly ->", abs(1e-4-1/1e4)<1e-18, " (a 4-per-10^4 count, i.e. CENSORED)")
print("   recomputed ratio: %.4f"%(1.000e-4/1.182e-05))
print()
print("== (B) '0.1% of cost' vs the SAME file's stride row ==")
mults=480184; smops=10807557
print("   stride: mults/attempt=%d  smops/attempt=%d"%(mults,smops))
print("   smops/(mults+smops) = %.4f  -> smoothness is %.1f%% of stride's cost"%(smops/(mults+smops),100*smops/(mults+smops)))
print("   smops/mults = %.2f   -> smoothness ops are %.0fx the multiplications"%(smops/mults,smops/mults))
print("   census says 0.1%%.  CONTRADICTED by %.1f%%."%(100*smops/(mults+smops)))
print()
print("   random row: mults=197798 (2^33). from the 28-bit stride rows smops~1.2e7/541933 ~ 22 as well.")
print()
print("== (C) the 186x figure vs its own stated denominator ==")
b=2.22e5; tgt=2724
print("   census: 2.22e5 -> 2,724  => %.2fx  (census claims 186x)"%(b/tgt))
print("   for 186x the baseline must be %.0f"%(186*tgt))
exp_rel=23490.0; rate=20/27
print("   cost model (b+c)*exp/rel/rate:")
for c in [10,1]:
    v=(6+c)*exp_rel/rate
    print("      c=%2d -> %10.0f   (/2724 = %.1fx)"%(c,v,v/tgt))
print("   => the printed baseline 2.22e5 is the c=1 value;")
print("      186x is computed against the c=10 value %.0f, which is NOT in the table."%((6+10)*exp_rel/rate))
print("      best-b-only 3269: %.2fx vs printed baseline, %.1fx vs c=10 baseline"%(b/3269,((6+10)*exp_rel/rate)/3269))
