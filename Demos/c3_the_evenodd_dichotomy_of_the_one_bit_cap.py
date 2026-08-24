import math
from math import gcd, log2
from collections import defaultdict

def ordType(n,a): return n//gcd(a,n)
def totient(m):
    return sum(1 for i in range(m) if gcd(i,m)==1)

def Ipair(n):
    # I(typePair ; prodRes) over box n
    joint=defaultdict(int); pg=defaultdict(int); pk=defaultdict(int)
    N=n*n
    for a in range(n):
        for b in range(n):
            t1,t2=ordType(n,a),ordType(n,b)
            t=(min(t1,t2),max(t1,t2)); c=(a+b)%n
            joint[(t,c)]+=1; pg[t]+=1; pk[c]+=1
    I=0.0
    for (t,c),v in joint.items():
        I += v/N*log2((v/N)/((pg[t]/N)*(pk[c]/N)))
    return I

def Ipair_prime_formula(p):
    return log2(p) - (p-1)*(2*p-1)*log2(p-1)/p**2 + (p-1)*(p-2)*log2(p-2)/p**2 if p>2 else 1.0

def primepow_pred(q,k):
    # conjecture: Ipair(q^k) = Ipair(q) * sum_{i<k} q^{-2i}
    base = Ipair_prime_formula(q) if q>2 else 1.0
    return base*sum(q**(-2*i) for i in range(k))

def upperD(q,k):
    L=log2(q); beta=log2(q-1) if q>2 else 0.0
    return (1-q**(-2*k))*(q*q*L/(q*q-1)-beta)

def lowerLB(q,k):
    L=log2(q); beta=log2(q-1) if q>2 else 0.0
    return (1-q**(-2*k))*(L*(2*q-1)-2*(q-1)*beta)/(q*q-1)

print("n, Ipair(n) brute force")
for n in range(2,25):
    print(n, round(Ipair(n),8))
print()
print("prime powers: q k  brute  predicted  upperD  lowerLB")
for (q,k) in [(2,1),(2,2),(2,3),(2,4),(3,1),(3,2),(3,3),(5,1),(5,2),(7,1),(11,1),(13,1)]:
    n=q**k
    bf = Ipair(n) if n<=200 else float('nan')
    print(q,k,round(bf,8),round(primepow_pred(q,k),8),round(upperD(q,k),6),round(lowerLB(q,k),6))
print()
print("CRT check: Ipair(mn) = Ipair(m)+Ipair(n) for coprime")
for (m,n) in [(3,4),(3,5),(4,9),(5,7),(2,9)]:
    print(m,n,round(Ipair(m*n),8), round(Ipair(m)+Ipair(n),8))
print()
print("limit G(q) and sum over odd primes")
def G(q): return Ipair_prime_formula(q)*q*q/(q*q-1)
primes=[p for p in range(3,200) if all(p%d for d in range(2,int(p**.5)+1))]
s=0
for p in primes[:25]:
    s+=G(p); print(p, round(G(p),6), round(s,6))
