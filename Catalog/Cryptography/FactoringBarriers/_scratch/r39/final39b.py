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
    a=0;q=1
    while q*p<=B: q*=p; a+=1
    return a
LIM=4_000_000
P=sieve(LIM); PH=phi_sieve(LIM)
def kfac_of(B): return {p:vmax(p,B) for p in P if p<=B}
def divisors_le(kf,X):
    ds=[1]
    for p,e in kf.items():
        nd=[];pw=1
        for _ in range(e+1):
            nd.extend(d*pw for d in ds); pw*=p
        ds=[d for d in nd if d<=X]
    return sorted(set(ds))

print("=== P3: MEAN FIRING COUNT in the realistic regime ===")
print(" proved:  E_m[gcd(m,k(B))] = (1/X) sum_{d | lcm(1..B), d <= X} phi(d)/d   [theorem 2]")
print(" folklore collision model claims the typical count is  1.44*B")
print()
print("   B      X        E[count]=T(B,X)   1.44*B     ratio E/1.44B")
for B in [10,20,50,100,200,500,1000]:
    kf=kfac_of(B)
    for X in [B, 10*B, 10**4, 10**6, 4*10**6]:
        if X< B or X>LIM: continue
        ds=divisors_le(kf,X)
        T=sum(Fraction(PH[d],d) for d in ds)
        # exact mean = (1/X) sum_{d} phi(d)*floor(X/d)
        mean=sum(Fraction(PH[d]*(X//d),X) for d in ds)
        print(f"{B:5d} {X:9d}   {float(mean):16.4f} {1.44*B:9.2f}   {float(mean/(1.44*B)):12.4f}")
    print()
