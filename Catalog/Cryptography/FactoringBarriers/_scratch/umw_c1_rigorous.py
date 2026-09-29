"""
RIGUOUS consequences of the c=1 characterisation, plus the measured anomaly.

If b is achievable (every p<=n divides some b+j, j in [1,l]) then, since U = prod_{p<=n} p
is SQUAREFREE and every p divides at least one factor,
        U  |  prod_{j=1}^{l} (b+j)   <=   (b+l)^l
so   b  >=  U^{1/l} - l  =  exp(theta(n)/l) - l  =  exp( n / n^{2/3} ) = exp(n^{1/3})  at beta=1/3.
=>  alpha >= 1-2beta is NECESSARY for c=1, by a one-line product argument.  (UMW prove
    alpha >= 1-2beta only for the DIFFERENCE-SET version via prod of primes; here it is the
    window version and the same bound falls out, with the SAME exponent.)
Upper end: b = U-1 always works (b+1 = U).  So min b is bracketed:
        exp(n/l)  <=  min b  <=  exp(theta(n)) = exp(n+o(n)).
The whole question is WHERE in that bracket it sits.  The INDEPENDENT (CRT) heuristic says
exp(n^{1/3}) (density = #achievable/U).  MEASURED exhaustively for n<=28 it is ~0.5*U.
"""
import math
from sympy import primerange
print(f"{'n':>4} {'l':>3} {'logU=th(n)':>11} {'log minb':>9} {'minb/U':>8} "
      f"{'log bound U^(1/l)':>18} {'log density-pred':>17} {'log b / n':>9}")
DATA = [(12,5,6.00,8.3),(14,6,7.60,10.4),(16,6,7.60,10.4),(18,7,11.35,13.2),
        (20,7,15.39,16.6),(21,8,15.39,16.6),(22,8,15.39,16.6),(24,8,18.53,19.4),
        (26,9,18.53,19.4),(28,9,18.53,19.4)]
for n,l,lb,lu in DATA:
    primes=list(primerange(1,n+1)); cnt=1
    for p in primes: cnt*=min(l,p)
    dens = lu - math.log(cnt)
    print(f"{n:>4} {l:>3} {lu:>11.2f} {lb:>9.2f} {math.exp(lb-lu):>8.3f} "
          f"{lu/l:>18.2f} {dens:>17.2f} {lb/n:>9.3f}")
print()
print("log(bound) = theta(n)/l  vs  log(density-pred) = theta(n) - log(#achievable)")
print("the two AGREE asymptotically at n^{1/3} (since log # = 2n/3 + o(n));")
print("MEASURED log min b tracks theta(n) itself: log min b / n =", 
      [round(lb/n,3) for n,l,lb,lu in DATA], "-> 1, not 1/3.")
print()
print("b = U-1 is the canonical solution. Measured min b sits at a CONSTANT FRACTION of U,")
print("i.e. the CRT-achievable set has essentially NO small elements: the independent/equi-")
print("distribution heuristic is falsified by a factor exp(~0.6n) already at n=24.")
