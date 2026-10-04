from sympy import symbols, solve, ln, N, Eq, Function, diff, dsolve, oo, exp, log
from sympy import lambdify, Rational
L=symbols('L',positive=True)
# census: (kN)^{1/4} > L[1/2] for every k>=1 once N>1.8e29
# BSGS on class group of discriminant D=kN costs (kN)^{1/4}; L[1/2]=sqrt(2*(lnN)(lnlnN))
# so need (kN)^{1/4} > sqrt(2 ln N ln ln N)
# k>=1 so worst case k=1: N^{1/4} > sqrt(2 lnN lnlnN)
# square: N^{1/2} > 2 lnN lnlnN ; with L=lnN: e^{L/2} > 2*L*lnL
print("== census: '16 ln L < L  <=>  N > 1.8e29' ==")
# L = 2 ln L + ln 2  (approx, from e^{L/2} > 2 L ln L)
f=L-2*ln(L)-ln(2)
roots=solve(f,L)
print("   solve L - 2ln L - ln2 = 0 :",roots)
Lr=[r for r in roots if r.is_real and r>0][0]
print("   positive root L = %.6f"%float(Lr))
import math
Ne=math.exp(float(Lr))
print("   N = e^L = %.6e   (census claims 1.8e29)"%Ne)
print()
print("== census: 'the inequality reduces to 16 ln L < L  <=> L < 67.36' ==")
# 16 ln L < L  =>  solve L - 16 ln L = 0
g=L-16*ln(L)
rg=solve(g,L)
print("   roots of L = 16 ln L :",rg)
print("   largest root = %.4f  (census claims 67.36)"%float(rg[-1]))
print()
print("== census: 'the paper had a factor-2 error giving N < 5400' ==")
# N<5400 => lnN = 8.594
print("   ln(5400) = %.4f"%math.log(5400))
print("   is 5400 consistent with a factor-2 error? Check L - 4lnL = ln2 variant:")
h=L-4*ln(L)-ln(2)
rh=solve(h,L)
print("   solve L - 4lnL - ln2 = 0 (the 4ln form):",[float(r) for r in rh if r.is_real and r>0])
print("   => N = %.4e"%(math.exp(float([r for r in rh if r.is_real and r>0][-1]))))
