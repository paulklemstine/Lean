# INDEPENDENT implementation: no sympy jacobi; compute Legendre via pow. Tests the CRUX claim:
# "(g/p)=-1  <=>  v2(ord_p(g)) = s_p"   and  "success  <=>  v2(ord_p g) != v2(ord_q g)"
import random, math
from fractions import Fraction as F
def is_prime(n):
    if n<2: return False
    for p in [2,3,5,7,11,13,17,19,23,29,31,37]:
        if n%p==0: return n==p
    d=n-1;r=0
    while d%2==0: d//=2;r+=1
    for a in [2,3,5,7,11,13,17,19,23,29,31,37]:
        x=pow(a,d,n)
        if x in (1,n-1): continue
        for _ in range(r-1):
            x=x*x%n
            if x==n-1: break
        else: return False
    return True
def primes_upto(N): return [n for n in range(2,N) if is_prime(n)]
def v2(x):
    k=0
    while x%2==0: x//=2;k+=1
    return k
def legendre(a,p):
    a%=p
    if a==0: return 0
    return 1 if pow(a,(p-1)//2,p)==1 else -1
def jacobi(a,n):
    r=1; a%=n
    while a:
        while a%2==0:
            a//=2
            if n%8 in (3,5): r=-r
        a,n=n,a
        if a%4==3 and n%4==3: r=-r
        a%=n
    return r if n==1 else 0
def ord2(p,g):
    s=v2(p-1)
    for i in range(s+1):
        if pow(g,(p-1)//2**i,p)!=1: return s-i+1
    return 0
# self-tests
assert jacobi(2,15)==1, jacobi(2,15)          # (2/3)(2/5)=(-1)(-1)=1
assert jacobi(2,21)==-1, jacobi(2,21)        # (2/3)(2/7)=(-1)(1)=-1
assert jacobi(7,15)==-1                       # (7/3)(7/5)=(1)(2->-1)=-1
P=primes_upto(400)
viol=0; tot=0
for p in P[1:]:
    for g in range(2,min(p,120)):
        if g%p==0: continue
        tot+=1
        if (legendre(g,p)==-1)!=(ord2(p,g)==v2(p-1)): viol+=1
print("CRUX lemma violations: %d / %d"%(viol,tot))
# independent MC of the headline
random.seed(1234)
big=[p for p in primes_upto(60000) if p>3]
U=UJ=CJ=CJok=0
for _ in range(40000):
    p=random.choice(big); q=random.choice(big)
    if p==q: continue
    n=p*q; g=random.randrange(2,n)
    if math.gcd(g,n)!=1: continue
    ok=(ord2(p,g)!=ord2(q,g)); U+=1; UJ+=ok
    if jacobi(g,n)==-1: CJ+=1; CJok+=ok
fu,fj=20/27.,8/9.
print("indep MC uniform = %.5f [%.5f] z=%+.2f"%(UJ/U,fu,(UJ/U-fu)/math.sqrt(fu*(1-fu)/U)))
print("indep MC jacobi  = %.5f [%.5f] z=%+.2f"%(CJok/CJ,fj,(CJok/CJ-fj)/math.sqrt(fj*(1-fj)/CJ)))
print("indep ratio      = %.5f  [1.20000]"%((CJok/CJ)/(UJ/U)))
