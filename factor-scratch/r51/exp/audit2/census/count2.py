# Independent check of P(p^k | a^2 - b^3) using CRT / direct count for more (p,k)
from sympy import primerange
def count(p,k):
    m=p**k; c=0
    for a in range(m):
        a2=(a*a)%m
        for b in range(m):
            if (a2-(b**3))%m==0: c+=1
    return c,m*m
print("%-4s %-3s %-10s %-12s %-12s %-12s"%("p","k","count","P measured","(2p-1)/p^k","(2p-1)/p^(k+1)"))
for p in [5,7,11]:
    for k in [2,3,4]:
        c,tot=count(p,k)
        P=c/tot
        print("%-4d %-3d %-10d %-12.8f %-12.8f %-12.8f  %s"%(p,k,c,P,(2*p-1)/p**k,(2*p-1)/p**(k+1),
              "MATCHES (2p-1)/p^k" if abs(P-(2*p-1)/p**k)<1e-12 else ("matches (2p-1)/p^(k+1)" if abs(P-(2*p-1)/p**(k+1))<1e-12 else "neither")))
