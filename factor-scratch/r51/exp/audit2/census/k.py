def count(p,k):
    m=p**k; c=0
    for a in range(m):
        a2=(a*a)%m
        for b in range(m):
            if (a2-(b**3))%m==0: c+=1
    return c,m*m
for p in [3,5]:
    for k in [2,3,4,5]:
        c,tot=count(p,k); P=c/tot
        print("p=%d k=%d  P=%.8f  ratio=P/(1/p^k)=%.6f  (2-1/p)=%.6f  census(2p-1)/p^k=%.6f"%(
              p,k,P,P*p**k,2-1/p,(2*p-1)/p**k))
