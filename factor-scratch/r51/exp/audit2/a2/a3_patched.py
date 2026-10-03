#!/usr/bin/env python3
"""Verify the CURRENT (post-patch a066a4b5b) version of §2.2."""
import math
def L(n): return n*math.log(2.0)
print("="*78)
print("A. THE PATCHED FORMULA  ln k = 4 sqrt(L ln L) - L, and its ln k values.")
print("   Paper (post-patch) still prints -573 / -1217 / -2539.")
print(f"{'n':>7} {'L=lnN':>10} {'2 sqrt(LlnL)':>13} {'lnk(2sqrt)':>11} {'4 sqrt(LlnL)':>13} {'lnk(4sqrt)':>11}  paper")
pp={1024:-573,2048:-1217,4096:-2539}
for n in [256,1024,2048,4096,16384]:
    Ln=L(n); a=2*math.sqrt(Ln*math.log(Ln))-Ln; b=4*math.sqrt(Ln*math.log(Ln))-Ln
    tag=pp.get(n,"")
    ok="" if not tag else ("  *** NOW WRONG ***" if abs(round(b)-tag)>1 else "  ok")
    print(f"{n:7d} {Ln:10.2f} {2*math.sqrt(Ln*math.log(Ln)):13.2f} {a:11.2f} "
          f"{4*math.sqrt(Ln*math.log(Ln)):13.2f} {b:11.2f}  {tag}{ok}")
print("  -> The patch changed 2->4 in the FORMULA but left the 2sqrt NUMBERS.")
print("     The three printed values are the values of the OLD formula.")
print()

print("="*78)
print("B. THE THRESHOLD. Paper (post-patch): 4sqrt(LlnL)<L <=> 16 ln L < L <=> L<67.36 <=> N<1.8e29")
def g(c):
    lo,hi=1.0,1e4
    for _ in range(300):
        m=.5*(lo+hi)
        if c*math.log(m) - m > 0: lo=m
        else: hi=m
    return .5*(lo+hi)
Lstar=g(16); print(f"  root of 16 ln L = L : L* = {Lstar:.4f}   e^L* = {math.exp(Lstar):.4e}")
Lstar4=g(4); print(f"  root of  4 ln L = L : L* = {Lstar4:.4f}   e^L* = {math.exp(Lstar4):.1f}")
print()
print("  DIRECTION.  16 ln L < L holds on the UPPER branch:")
for x in [10,50,67.36,100,709.78,1419.57,2839.14]:
    print(f"    L={x:9.2f}  16lnL-L={16*math.log(x)-x:+14.2f} -> "
          f"{'EXCLUDED (ln k<0)' if 16*math.log(x)-x<0 else 'not excluded'}")
print(f"  ==> CORRECT: 16 ln L < L  <=>  L > {Lstar:.3f}  <=>  N > {math.exp(Lstar):.3e}")
print(f"  ==> PAPER:  16 ln L < L  <=>  L < 67.36   <=>  N < 1.8e29")
print("      *** DIRECTION STILL INVERTED in the displayed chain (2nd time). ***")
print("      Prose now says 'once N > 1.8e29' (correct); the chain says N < 1.8e29.")
print()

print("="*78)
print("C. THE L-COLUMNS. Prior audit claimed BOTH columns were wrong. Recheck.")
def Lhalf(n,c): Ln=L(n); return c*math.sqrt(Ln*math.log(Ln))/math.log(2)
def Lthird(n,c=(64/9)**(1/3)): Ln=L(n); return c*Ln**(1/3)*math.log(Ln)**(2/3)/math.log(2)
tbl={256:(21.87,46.66),1024:(49.24,86.77),4096:(108.38,156.50),16384:(234.90,276.52)}
print(f"{'n':>7} {'L[1/2] c=0.5':>13} {'paper':>8} {'L[1/3] c=1.923':>15} {'paper':>8}")
for n in [256,1024,4096,16384]:
    a,b=Lhalf(n,0.5),Lthird(n); pa,pb=tbl[n]
    print(f"{n:7d} {a:13.2f} {pa:8.2f} {b:15.2f} {pb:8.2f}   "
          f"{'MATCH' if abs(a-pa)<0.01 and abs(b-pb)<0.01 else 'MISMATCH'}")
print("  ==> BOTH COLUMNS REPRODUCE THE PAPER EXACTLY. The prior audit's claim")
print("      that the L-columns 'were wrong' is FALSE; it did not edit the table.")
print()
print("D. IS 'L[1/3] > L[1/2]' (as printed) AN INEQUALITY 'NEVER TRUE'?  NO.")
print(f"{'n':>7} {'L[1/2]':>9} {'L[1/3]':>9} {'L1/3 > L1/2?':>14}")
for n in [256,1024,4096,16384,65536,262144,1048576]:
    a,b=Lhalf(n,0.5),Lthird(n)
    print(f"{n:7d} {a:9.2f} {b:9.2f} {str(b>a):>14}")
print("  Crossover: L[1/3] < L[1/2] only asymptotically. At every size in the")
print("  paper's table, L[1/3] > L[1/2] -- so the printed table is CORRECT and")
print("  the prior audit's 'never true' is wrong.")
print()
print("E. TRUE ECM CONSTANT. ECM = L[1/2,sqrt2] = exp(sqrt2 * sqrt(L ln L)),")
print("   i.e. constant sqrt2 = 1.4142, not the paper's 0.5. The paper UNDERSTATES")
print("   its target, so the exclusion is CONSERVATIVE. Recompute with 1.4142:")
print(f"{'n':>7} {'ln k, c=sqrt2':>15} {'threshold':>14} {'N*':>12}")
for n in [1024,2048,4096]:
    Ln=L(n); lk=4*math.sqrt(2)*math.sqrt(Ln*math.log(Ln))-Ln
    lo,hi=1.0,1e4
    for _ in range(300):
        m=.5*(lo+hi)
        if 32*math.log(m)-m>0: lo=m
        else: hi=m
    Ls=.5*(lo+hi)
    print(f"{n:7d} {lk:15.2f} {Ls:14.3f} {math.exp(Ls):12.3e}")
print("   -> Still negative; exclusion STRENGTHENS. Conclusion robust to the")
print("      constant choice. This is a point in the paper's favour.")
