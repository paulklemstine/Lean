def primerange(a,b):
    return [n for n in range(max(a,2),b) if all(n%d for d in range(2,int(n**0.5)+1))]
from math import gcd
import random
# 1. MPQS column density
print("MPQS column set vs single-poly split set")
random.seed(1)
for N in [10403, 1000003*1000033, 2**31-1 * 3]:
    tot=same=0; split=0
    for p in primerange(3,2000):
        if N%p==0: continue
        sp = pow(N% p,(p-1)//2,p)==1
        a=random.randrange(1,p); b=random.randrange(p)
        hit = any(((a*x+b)**2-N)%p==0 for x in range(p))
        tot+=1; same += (hit==sp); split+=sp
    print(N, "primes",tot,"agree",same,"split density %.3f"%(split/tot))
# 2. leg triples
print("Leg triples")
for N in [15,21,45,77,91,105,9,25]:
    rows=[]
    for u in range(1,N):
        if (N*N)%u==0:
            v=N*N//u
            if (u+v)%2==0 and u<v:
                b=(v-u)//2; c=(v+u)//2; rows.append((u,b,c,gcd(u,N)))
    print(N, rows)
# 3. which-factor wall
P=list(primerange(2,60))
pairs=[(p,q) for p in P for q in P if p!=q]
print("pairs",len(pairs),"minFac correct",sum(1 for p,q in pairs if min(p,q)==p))
