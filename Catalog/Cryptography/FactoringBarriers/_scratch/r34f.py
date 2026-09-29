import math, sys
from sympy import isprime, gcd, nextprime
def P(*a): print(*a); sys.stdout.flush()
p=2003   # p-1 = 2002 = 2*7*11*13
def findq(M,sign,lim=200000):
    c=int(nextprime(M))
    while c<lim:
        if isprime(c) and c%M==sign: return c
        c=int(nextprime(c))
    return None
def dens(q,E):
    N=p*q; dp=int(gcd(E,p-1)); dq=int(gcd(E,q-1))
    R=dp*(q-1)+dq*(p-1)-2*dp*dq; phi=(p-1)*(q-1)
    return R/phi, phi/R
P(f"MATCHED-promise head-to-head: p={p}, p-1={p-1}. Euler: E=N-1, q=+1 mod M. Crossed: E=N+1, q=-1 mod M.")
P(f"{'M':>6} | {'q(+1)':>8} {'Euler dens':>11} {'tr':>9} | {'q(-1)':>8} {'Cross dens':>11} {'tr':>8}")
for M in [2,7,11,13,14,26,77,143,286,1001,2002]:
    q1=findq(M,1); q2=findq(M,M-1)
    s1=f"{q1:8d} {dens(q1,p*q1-1)[0]:11.6f} {dens(q1,p*q1-1)[1]:9.1f}" if q1 else f"{'-':>8} {'-':>11} {'-':>9}"
    s2=f"{q2:8d} {dens(q2,p*q2+1)[0]:11.6f} {dens(q2,p*q2+1)[1]:8.3f}" if q2 else f"{'-':>8} {'-':>11} {'-':>8}"
    P(f"{M:6d} | {s1} | {s2}")
P("")
P("NOTE: Euler density ~ 2*(M/(p-1)) (BOTH sides get the promise); Crossed ~ 1*(M/(p-1)) (ONE side).")
