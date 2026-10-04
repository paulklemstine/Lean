from sympy import symbols, solve, ln, Function, oo, exp
import math
L=symbols('L',positive=True)
rg=solve(L-16*ln(L),L)
roots=sorted(float(r) for r in rg if r.is_real)
print("roots of L = 16 ln L :",["%.4f"%r for r in roots])
for r in roots:
    print("   L=%.4f  ->  N = e^L = %.4e"%(r,math.exp(r)))
print()
print("census claims: '16 ln L < L  <=>  N > 1.8e29'  AND  'L < 67.36'")
print("  L=67.36 corresponds to N = e^67.36 = %.3e"%math.exp(67.3611))
print("  N = 1.8e29 corresponds to L = ln(1.8e29) = %.3f"%math.log(1.8e29))
print()
print("SIGN CHECK of 16 ln L < L:")
lo,hi=roots
def f(x): return x-16*math.log(x)
for x in [0.01,0.1,0.5,1.0,5,20,50,67.0,67.36,67.5,100,200,1000]:
    print("   L=%8.2f  L-16lnL=%12.4f  -> 16lnL<L is %s"%(x,f(x),f(x)>0))
print()
print("=> 16 ln L < L holds for L < %.3f  OR  L > %.2f."%(lo,hi))
print("   The census writes the equivalence as 'L < 67.36', dropping the small-L branch.")
print("   Small L means N < e^%.3f = %.2f  (N<2.5), i.e. no RSA-scale N."%(lo,math.exp(lo)))
