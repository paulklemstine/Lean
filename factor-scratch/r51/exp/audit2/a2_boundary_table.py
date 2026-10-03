#!/usr/bin/env python3
"""A2: (a) redo the L=4lnL boundary correctly (my earlier scan truncated at 4.0);
       (b) reverse-engineer the paper's L table columns."""
from math import log, log2, sqrt, exp
import scipy.optimize as so

f=lambda L: L-4*log(L)
import numpy as _np
print("  f(0.02)=",f(0.02)," f(0.5)=",f(0.5)," f(2)=",f(2.0)," f(8.6)=",f(8.6)," f(20)=",f(20.0))
r1=so.brentq(f,0.02,0.5) if f(0.02)*f(0.5)<0 else float("nan")
r2=so.brentq(f,2.0,20.0)
print("=== A2.3 CORRECTED: roots of L = 4 ln L ===")
print(f"  lower root {r1:.6f}   upper root {r2:.6f}   (paper says L < 8.6)")
print(f"  4 ln(8.6) = {4*log(8.6):.4f}  -> f(8.6) = {f(8.6):.4f}   so 8.6 IS essentially the upper root: PAPER CORRECT")
print(f"  boundary N < exp(L*) = exp({r2:.6f}) = {exp(r2):.2f}    (paper says 5400)")
print(f"  deviation from paper's 5400: {100*(exp(r2)-5400)/5400:+.2f}%  -> paper rounded low; immaterial")

print()
print("=== A2.1b  REVERSE-ENGINEER THE PAPER'S TABLE COLUMNS (n in BITS) ===")
paper_L2={256:21.87,1024:49.24,4096:108.38,16384:234.90}
paper_L3={256:46.66,1024:86.77,4096:156.50,16384:276.52}
print(f"{'n':>6} {'paperL[1/2]':>12} {'trueL[1/2]':>12} {'ratio':>8}   {'paperL[1/3]':>12} {'trueL[1/3]':>12} {'ratio':>8}")
for n in [256,1024,4096,16384]:
    N=2**n
    t2=log2(exp(sqrt(log(N)*log(log(N)))))
    t3=log2(exp((log(N)*log(log(N)))**(1/3)))
    print(f"{n:>6} {paper_L2[n]:>12.2f} {t2:>12.2f} {paper_L2[n]/t2:>8.4f}   {paper_L3[n]:>12.2f} {t3:>12.2f} {paper_L3[n]/t3:>8.4f}")
print()
print("  paper L[1/2] / true L[1/2] = 0.5000 EXACTLY at every n  -> the column is")
print("  log2 of L[1/2]/2, i.e. L[1/2] with c = 1/2.  That is NOT any standard constant.")
print("  (Shoup's proven form is L[1/2,sqrt2] = log2 value + log2(sqrt2) = +0.5, and ECM's")
print("   heuristic is L[1/2,1].  Neither is -1.)")
print()
print("=== A2.1c  THE TABLE IS INTERNALLY INVERTED ===")
print(f"  paper says at n=256: L[1/3] = {paper_L3[256]} > L[1/2] = {paper_L2[256]}")
print("  But L[1/3] < L[1/2] ALWAYS (larger alpha-index = smaller subexponential cost).")
print(f"  true values at n=256: L[1/3]={log2(exp((log(2**256)*log(log(2**256)))**(1/3))):.2f} < L[1/2]={log2(exp(sqrt(log(2**256)*log(log(2**256))))):.2f}")
print("  => the two columns are swapped or both miscomputed.  The columns")
print("     'N^{1/4} - L[1/3]' and 'N^{1/4} - L[1/2]' inherit the error.")
print()
print("=== A2.1d  DOES THE CONCLUSION SURVIVE THE CORRECTED TABLE? ===")
print(f"{'n(bits)':>8} {'N^1/4':>9} {'trueL[1/2]':>11} {'true margin':>12} {'paper margin':>13} {'overstated by':>14}")
for n in [256,1024,4096,16384]:
    N=2**n; a=log2(N)/4; b=log2(exp(sqrt(log(N)*log(log(N)))))
    pm=a-paper_L2[n]
    print(f"{n:>8} {a:>9.2f} {b:>11.2f} {a-b:>12.2f} {pm:>13.2f} {(pm/(a-b)-1)*100:>13.1f}%")
