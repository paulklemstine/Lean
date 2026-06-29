import math
import matplotlib.pyplot as plt

def cantor_points(depth):
    iv=[(0.0,1.0)]
    for _ in range(depth):
        nxt=[]
        for a,b in iv:
            t=(b-a)/3.0; nxt+=[(a,a+t),(b-t,b)]
        iv=nxt
    pts=[]
    for a,b in iv: pts+=[a,b]
    return pts

def logNs(points, scales):
    return [(math.log(1/eps), math.log(len({math.floor(p/eps) for p in points}))) for eps in scales]

depth=8
pts=cantor_points(depth)
scales=[3.0**-k for k in range(1,depth+1)]
A=logNs(pts,scales)
B=logNs([2.7*x-4 for x in pts],[2.7*s for s in scales])
plt.scatter([x for x,_ in A],[y for _,y in A],label='original')
plt.scatter([x for x,_ in B],[y for _,y in B],marker='x',label='bi-Lipschitz image')
plt.xlabel('log(1/eps)'); plt.ylabel('log N(eps)')
plt.title('Box-counting fit: dimension preserved (Theorem 6.1)')
plt.legend(); plt.grid(True, alpha=0.3); plt.tight_layout()
plt.savefig('boxcount_fit.png', dpi=150)
print('saved boxcount_fit.png')