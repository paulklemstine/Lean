from itertools import product
from math import gcd
# exact count of #{a,b mod p^k : p^k | a^2-b^3}
for p in [2,3,5,7,11,13]:
    row=[]
    for k in [1,2,3]:
        m=p**k
        c=0
        for a in range(m):
            a2=(a*a)%m
            for b in range(m):
                if (a2-(b*b*b))%m==0: c+=1
        P=c/(m*m)
        row.append((k,P,P/p**k))
    print("p=%2d"%p, " ".join("k=%d P=%.6f P/p^k=%.5f"%(k,P,r) for k,P,r in row))
print()
print("census formula (2p-1)/p^k:")
for p in [3,5,7]:
    for k in [2,3]:
        print("  p=%d k=%d -> %.6f"%(p,k,(2*p-1)/p**k))
print("note bottom-line formula (1+1/p)p^-k:")
for p in [3,5,7]:
    for k in [2,3]:
        print("  p=%d k=%d -> %.6f"%(p,k,(1+1/p)/p**k))
