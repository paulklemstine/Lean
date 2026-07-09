"""Actual vs. predicted nu_2 for m=9, exposing the universal formula's failure."""
import matplotlib.pyplot as plt

def tm_sign(n): return -1 if bin(n).count("1")&1 else 1
def tmpow(m, L):
    c=[tm_sign(n) for n in range(L)]; r=[1]+[0]*(L-1)
    for _ in range(m):
        nw=[0]*L
        for i in range(L):
            if r[i]:
                for j in range(L-i): nw[i+j]+=r[i]*c[j]
        r=nw
    return r
def v2(a):
    if a==0: return 0
    a,e=abs(a),0
    while a%2==0: a//=2; e+=1
    return e

L=200; t9=tmpow(9,L)
xs=list(range(24))
actual=[v2(t9[8*n]) for n in xs]
def universal(n):
    v=v2(n+1); return 8*((v+1)//2)-2*(v%2)
def m9law(n):
    v=v2(n+1); return (5*v+(v%2))//2
pred_u=[universal(n) for n in xs]
pred_9=[m9law(n) for n in xs]
plt.figure(figsize=(12,5))
plt.plot(xs, actual, "o-", label="actual nu_2(t_9(8n))")
plt.plot(xs, pred_u, "s--", label="universal formula (refuted)")
plt.plot(xs, pred_9, "^:", label="corrected m=9 law")
plt.legend(); plt.xlabel("n"); plt.ylabel("2-adic valuation")
plt.title("m=9: universal formula overshoots; corrected law matches")
plt.tight_layout(); plt.savefig("m9_refutation.png", dpi=130)
print("wrote m9_refutation.png")
