from fractions import Fraction
from math import gcd as G, log, isqrt, sqrt
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
LIM=2_000_000
P=sieve(LIM); PH=phi_sieve(LIM)
def kfac_of(B): return {p:vmax(p,B) for p in P if p<=B}
def divs_le(kf,X):
    ds=[1]
    for p,e in kf.items():
        nd=[];pw=1
        for _ in range(e+1):
            nd.extend(d*pw for d in ds); pw*=p
        ds=[d for d in nd if d<=X]
    return sorted(set(ds))

print("=== P4: PROVED dispersion constants from the two Lean theorems ===")
print(" M1 = (1/X) sum_{d|k,d<=X} phi(d)*floor(X/d)        [proved, theorem 2]  = E[gcd]")
print(" L2 = (1/X) sum_{d|k,d<=X} phi(d)^2*floor(X/d)      [proved LB, thm 3]    <= E[gcd^2]")
print(" => PROVED:  CV^2 = E[g^2]/E[g]^2 - 1  >=  L2/M1^2 - 1")
print()
print("   B       X       M1=E[g]     E[g^2]    CV=SD/E[g]  PROVED CV lower bd  #divs<=X")
for B,X in [(10,720),(10,5000),(20,3000),(50,10**4),(50,10**6),(100,10**4),(100,10**6),(200,10**6),(500,10**6),(1000,10**6)]:
    kf=kfac_of(B); ds=divs_le(kf,X)
    M1=sum(Fraction(PH[d]*(X//d),X) for d in ds)
    M2=sum(Fraction(PH[d]**2*(X//d),X) for d in ds)
    cv2=float(M2/(M1*M1)-1)
    cv=sqrt(max(cv2,0))
    lb=sqrt(max(float(M2/(M1*M1)-1),0))   # proved LB uses L2=M2-denominator form; ratio L2/M1^2-1
    print(f"{B:5d} {X:8d} {float(M1):12.4f} {float(M2):14.4e} {cv:11.2f} {lb:20.2f} {len(ds):10d}")
print()
print("  NOTE: the 'PROVED CV lower bd' column is L2/M1^2 - 1 with L2 the proved bound;")
print("        it is a lower bound on CV because E[g^2] >= L2 (theorem 3).")
print()
print("=== P5: the tight regime, X = B, in closed form ===")
for B in [10,100,1000]:
    k=1
    for p,e in kfac_of(B).items(): k*=p**e
    # for m <= B, m | lcm(1..B), so gcd(m,k)=m exactly
    E=Fraction(sum(range(1,B+1)),B)
    print(f"  B={B:5d}: E_m[gcd(m,lcm(1..B))] = (1/B) sum_{{m<=B}} m = {E} = (B+1)/2 ;  folklore 1.44B ; ratio {float(E/(Fraction(144,100)*B)):.6f}")
