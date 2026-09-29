from fractions import Fraction
from math import gcd as G, lcm, sqrt, isqrt
def sieve(n):
    s=bytearray([1])*(n+1); s[0]=s[1]=0
    for i in range(2,isqrt(n)+1):
        if s[i]: s[i*i::i]=bytearray(len(s[i*i::i]))
    return [i for i in range(n+1) if s[i]]
P=sieve(2_000_000)
def vmax(p,B):
    a=0;q=1
    while q*p<=B: q*=p; a+=1
    return a
def kB(B):
    k=1
    for p in P:
        if p>B: break
        k*=p**vmax(p,B)
    return k
print("=== AUDIT of round-38's headline numbers ===")
print("kB(10)=",kB(10)," (record's stage1Scalar 10 = 2520)")
for B,X in [(10,720),(10,5000),(50,20000),(100,50000)]:
    k=kB(B)
    mean_rate=sum(Fraction(G(m,k),m) for m in range(1,X+1))/X
    Em=Fraction(X+1,2)
    folk=Fraction(144,100)*B/Em
    g=[G(m,k) for m in range(1,X+1)]
    m1=sum(g)/X; m2=sum(x*x for x in g)/X
    cv=sqrt(float(m2-m1*m1))/float(m1)
    print(f" B={B:4d} X={X:6d}  E[gcd/m]={float(mean_rate):.4e}  1.44B/E[m]={float(folk):.4e}  ratio={float(mean_rate/folk):.4f}   E[gcd]={float(m1):.4f}  SD/mean(gcd)={cv:.3f}")
print()
print(" round-38 claimed: rate ratio 0.23/0.23/0.32/0.24 and SD/mean 1.23/1.23/5.6/9.2")
print()
print("=== CROSSOVER: where does 1.44*B stop over-stating the proved mean count? ===")
def phi_sieve(N):
    ph=list(range(N+1))
    for p in range(2,N+1):
        if ph[p]==p:
            for j in range(p,N+1,p): ph[j]-=ph[j]//p
    return ph
LIM=4_000_000; PH=phi_sieve(LIM)
def kfac_of(B): return {p:vmax(p,B) for p in P if p<=B}
def divs_le(kf,X):
    ds=[1]
    for p,e in kf.items():
        nd=[];pw=1
        for _ in range(e+1):
            nd.extend(d*pw for d in ds); pw*=p
        ds=[d for d in nd if d<=X]
    return sorted(set(ds))
for B in [100,1000]:
    kf=kfac_of(B)
    lo,hi=B,10**7
    for X in [B,10*B,100*B,10**4,10**5,10**6,10**7]:
        if X>LIM: break
        ds=divs_le(kf,X)
        M=sum(Fraction(PH[d]*(X//d),X) for d in ds)
        print(f"  B={B:5d} X/B={X/B:9.0f}  proved mean={float(M):14.2f}  folklore={1.44*B:9.1f}  ratio={float(M/(1.44*B)):.3f}")
    print()
