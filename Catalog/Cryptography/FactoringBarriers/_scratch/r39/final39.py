from fractions import Fraction
from math import gcd as G, log, isqrt

def sieve(n):
    s=bytearray([1])*(n+1); s[0]=s[1]=0
    for i in range(2,isqrt(n)+1):
        if s[i]: s[i*i::i]=bytearray(len(s[i*i::i]))
    return [i for i in range(n+1) if s[i]]

def phi_sieve(N):
    ph=list(range(N+1))
    for p in range(2,N+1):
        if ph[p]==p:
            for j in range(p,N+1,p): ph[j]-=ph[j]//p
    return ph

def vmax(p,B):
    a=0; q=1
    while q*p<=B: q*=p; a+=1
    return a

PH=phi_sieve(2_000_000)
P=sieve(2_000_000)

def divisors_le(kfac, X):
    """all divisors of k, capped at X, from the prime-power factorisation dict"""
    ds=[1]
    for p,e in kfac.items():
        nd=[]
        pw=1
        for _ in range(e+1):
            nd.extend(d*pw for d in ds)
            pw*=p
        ds=[d for d in nd if d<=X]
    return sorted(set(ds))

def kfac_of(B):
    return {p:vmax(p,B) for p in P if p<=B}

# ---------- P1 / P2 : validate the two proved theorems exactly ----------
print("=== P1/P2: exact validation of the two PROVED Lean theorems ===")
print(" k=lcm(1..B);  T1 = sum_{m<=X} gcd(m,k)  vs  sum_{d|k} phi(d)*floor(X/d)")
print("               T2 = sum_{m<=X} gcd(m,k)^2 vs  sum_{d|k} phi(d)^2*floor(X/d)  (proved LB)")
ok=True
for B,X in [(10,2000),(10,5000),(20,3000),(30,3000),(50,2000),(100,1000)]:
    kf=kfac_of(B)
    k=1
    for p,e in kf.items(): k*=p**e
    T1=sum(G(m,k) for m in range(1,X+1))
    R1=sum(PH[d]*(X//d) for d in divisors_le(kf,X))
    T2=sum(G(m,k)**2 for m in range(1,X+1))
    R2=sum(PH[d]**2*(X//d) for d in divisors_le(kf,X))
    ok &= (T1==R1) and (T2>=R2)
    print(f"  B={B:4d} X={X:6d}  T1==R1: {T1==R1}   T2>=R2: {T2>=R2}   slack(T2/R2)={float(Fraction(T2,R2)):.6f}")
print("  ALL EXACT:",ok)
