import math
print("=== #521 sec 9: 'birthday prediction: sqrt(pi/8) = 0.354' and 'a factor of 1.26' ===")
print("  observed: first repeat at k=282, sqrt(p)=1000, ratio = 282/1000 = %.4f (paper prints 0.282)"%(282/1000))
print("  sqrt(pi/8)      = %.6f   <-- paper prints 0.354  **MISMATCH**"%(math.sqrt(math.pi/8)))
print("  sqrt(1/8)       = %.6f   <-- 0.354 IS sqrt(1/8); looks like 'pi' was dropped"%(math.sqrt(1/8)))
print("  sqrt(pi/2)      = %.6f   (the usual birthday scale for the FIRST collision index)"%(math.sqrt(math.pi/2)))
print("  paper's 'factor of 1.26' = 0.354/0.282 = %.4f  -> self-consistent ONLY with the wrong 0.354"%(0.354/0.282))
print("  with the CORRECT sqrt(pi/8)=%.4f the factor is %.3f, not 1.26"%(math.sqrt(math.pi/8),math.sqrt(math.pi/8)/0.282))
print("  against sqrt(pi/2)*sqrt(p) = %.1f (true birthday expectation): 282 is a factor %.2f off"%(math.sqrt(math.pi/2)*1000,math.sqrt(math.pi/2)*1000/282))
print()
print("=== #521 sec 10.1: prose vs its own table ===")
tbl=[(16,256,0.043,0.030),(20,1024,0.263,0.300),(24,4096,0.255,0.305),
     (24,256,0.045,0.030),(29,23170,0.300,0.350),(29,812,0.085,0.085)]
gaps=[c-e for _,_,c,e in tbl]
print("  gap column as printed: +0.013, -0.037, -0.050, +0.015, -0.050, +0.000")
for (k,B,c,e),g in zip(tbl,gaps):
    print(f"    k={k:>2} B={B:>5}: class={c:.3f} EC={e:.3f} -> class-EC = {g:+.3f}  (printed {'OK' if abs(round(g,3)-{0.013:0.013}.get(0,0) if False else g)<1 else ''})")
print("  max |gap| = %.3f = %.1f pp"%(max(abs(g) for g in gaps),max(abs(g) for g in gaps)*100))
print("  paper prose: 'Every cell is <= 2 pp'  -> max is %.1f pp  **FALSE**"%(max(abs(g) for g in gaps)*100))
neg=sum(1 for g in gaps if g<0); zero=sum(1 for g in gaps if g==0)
print("  signs: %d negative, %d positive, %d exactly zero"%(neg,6-neg-zero,zero))
print("  paper prose: 'four of six are negative' -> actually %d are negative  **FALSE**"%neg)
print("  preregistered gate 'gap < 10 pp at every matched cell': max %.1f pp < 10 -> gate verdict HOLDS"%(max(abs(g) for g in gaps)*100))
print()
print("=== #521 sec 11: 'E-6c reports 0.720 at 29 bits where Dickman predicts 0.0587' ===")
import sys; sys.path.insert(0,'.')
from dick import rho
# 29-bit object: u = log2(order)/log2(B).  find B giving rho=0.0587
for lgB in (12,14,16,20,24,29):
    u=29.0/lgB; print(f"    B=2^{lgB:<2} u={u:6.3f} rho={rho(u):.4f}")
lo,hi=1.0,40.0
for _ in range(300):
    mid=(lo+hi)/2
    if rho(mid)>0.0587: lo=mid
    else: hi=mid
print(f"    rho(u)=0.0587 at u={lo:.4f} -> 29-bit order needs B=2^(29/{lo:.4f})=2^{29/lo:.2f}")
print("    0.720 vs that prediction: ratio %.1f"%(0.720/0.0587))
