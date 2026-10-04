import math
from fisher import fisher_p, ratio_ci_katz
print("=== #521 sec 10.5 / census: 'class vs odd-uniform at the TOP u : Fisher p = 0.4951' ===")
print("  Run B top u=3.0: class 7/267 ; odd-uniform rate printed as 0.036 on n=4000")
for x0 in (144,145,136,152,120):
    print(f"    Fisher(7/267 vs {x0}/4000) = {fisher_p(7,260,x0,4000-x0):.4f}")
# what count would give 0.4951?
best=None
for x0 in range(1,600):
    p=fisher_p(7,260,x0,4000-x0)
    if best is None or abs(p-0.4951)<abs(best[1]-0.4951): best=(x0,p)
print(f"  closest achievable: {best[0]}/4000 -> p={best[1]:.4f}  (paper & census print 0.4951)")
print("  Run A: class 0/60 vs odd-uniform? -> Fisher(0,60,x,60-x) for x=1:",fisher_p(0,60,1,59))
print("  ALTERNATIVE reading - 0/267 vs 0/4000:",fisher_p(0,267,0,4000),"  <- this is exactly 1.0, i.e. if BOTH arms were 0")
print()
print("=== CENSUS line 100 vs PAPER line 393/394 (JOB 5 cross-check) ===")
print("  census : 'ratio reverses, 0.78 and 0.58, Fisher p = 0.0000 / 0.0028'")
print("  paper  : u=2.0 p=0.0230 ; u=2.5 p=0.00572")
print("  mine   : u=2.0 p=%.6g ; u=2.5 p=%.6g"%(fisher_p(64,203,1224,2776),fisher_p(22,245,564,3436)))
print("  -> the census STILL carries BOTH pre-amendment p-values. Half-applied fix propagated.")
print()
print("=== JOB 5: repeated literals across the two papers and the census ===")
rows=[("exclusion threshold","1.8e29","#522 hdr L8","#522 L29 1.797e29","#522 L68","#522 L203","#522 L358","census L60,L201,L518"),
      ("trials","0/890","#521?","#522 L71,L160,L227,L358","census L58,L201")]
for r in rows: print("  ",r[0],"->",r[1],"in:",r[2:])
print()
print("=== 0/890 arithmetic (JOB 2/4) ===")
print("  arm1: k-set {1,2,3,4,5,6,8,12,16,24,32,64,128,256,1024,4096} = 16 values x 40 instances = 640  OK")
print("  arm2: k<=5 = 5 values x 30 instances = 150  OK")
print("  sum = 790   paper prints 890 at #522:71,160,227,358 and census:58,201  -> **MISMATCH, off by 100**")
print()
print("=== #522 sec 3.5 'cost vs k=1' column: is it rho(7.35)/rho(k*7.35)? ===")
print("  paper 1.00/3.18/5.74/8.54 ; k=1,2,3,4 ; consecutive ratios 1.805,1.488 (not geometric) -> not a 1/k law")
for a,b in ((3.18,5.74),(5.74,8.54),(8.54,3.18*1)): pass
print("  implied base per level: 3.18^(1/1)=%.3f  5.74^(1/2)=%.3f  8.54^(1/3)=%.3f  -> inconsistent"%(3.18,5.74**.5,8.54**(1/3)))
print("  and 'A tower costs k^3-ish more' -> k=2 would be 8, k=3 27, k=4 64; paper prints 3.18/5.74/8.54")
