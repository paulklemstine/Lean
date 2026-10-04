import math
from fisher import fisher_p, ratio_ci_katz
from scipy.stats import fisher_exact
print("=== JOB 3, the u=3.0 row in detail (the one the amendment did NOT fix) ===")
a,b,c,d=7,260,212,3788
print(f"  counts 7/267 = {7/267:.6f}   212/4000 = {212/4000:.6f}   ratio = {(7/267)/(212/4000):.6f}")
print(f"  my Fisher two-sided p      = {fisher_p(a,b,c,d):.6f}")
print(f"  scipy fisher_exact p       = {fisher_exact([[a,b],[c,d]])[1]:.6f}")
print(f"  PAPER line 395 prints       = 1.0000")
print(f"  UPSTREAM notes/G_adversary.md:117 also prints 1.0000  <- inherited, NOT corrected")
print()
print("  WHY 1.0000 is impossible: a two-sided Fisher p is a sum of hypergeometric")
print("  probabilities; it equals 1 only when the observed cell is the unique mode.")
print("  Test the null case deliberately (positive control that p CAN be ~1):")
print(f"    0/267 vs 0/4000 -> p = {fisher_p(0,267,0,4000):.6f}  <- genuinely 1.0, both arms empty")
print(f"    7/267 vs 212/4000 -> p = {fisher_p(7,260,212,3788):.6f}  <- arms NOT empty, so p != 1")
print()
print("=== CI vs p coherence, all four rows (the defect the correction claims to fix) ===")
for u,x1,n1,x0,n0,ppr in ((1.5,135,267,2404,4000,0.00244),(2.0,64,267,1224,4000,0.0230),
                          (2.5,22,267,564,4000,0.00572),(3.0,7,267,212,4000,1.0000)):
    lo,hi=ratio_ci_katz(x1,n1,x0,n0); p=fisher_p(x1,n1-x1,x0,n0-x0)
    print(f"  u={u}: Katz CI [{lo:.4f},{hi:.4f}] excludes 1? {not(lo<=1<=hi)}   | p={p:.6f} sig@0.05? {p<0.05}"
          f"   | paper CI excludes 1? {u!=3.0}  paper p sig? {ppr<0.05}")
print()
print("=== multiplicity: 4 tests on the SAME 267 class / 4000 EC sample ===")
ps=[fisher_p(x1,n1-x1,x0,n0-x0) for _,x1,n1,x0,n0 in
    ((1.5,135,267,2404,4000),(2.0,64,267,1224,4000),(2.5,22,267,564,4000),(3.0,7,267,212,4000))]
print("  raw p      :", [f"{p:.5f}" for p in ps])
print("  Bonferroni :", [f"{min(p*4,1):.5f}" for p in ps], " (alpha 0.0125)")
print("  -> u=2.0 (p=0.0230) does NOT survive Bonferroni; paper calls all of {1.5,2.0,2.5} significant")
print()
print("=== independence / sidedness (what the paper actually did) ===")
print("  Fisher column is TWO-SIDED (verified against scipy default). CI column is a two-sided 95% Katz interval.")
print("  BUT Fisher tests EQUAL PROPORTIONS; the Katz interval tests ratio == 1.")
print("  With UNEQUAL n (267 vs 4000) these are the same H0 but different statistics -> they can disagree,")
print("  so pairing them in one row as if they were one test is the structural defect.")
