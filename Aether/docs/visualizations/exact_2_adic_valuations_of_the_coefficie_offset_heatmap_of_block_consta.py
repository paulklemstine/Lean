"""Heatmap of nu_2(t_m((m-1)n+j)) over offsets j, showing block-constancy break."""
import matplotlib.pyplot as plt
import numpy as np

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

fig, axes = plt.subplots(1, 3, figsize=(15,4))
for ax, m in zip(axes, (5, 9, 13)):
    L=(m-1)*16+m; t=tmpow(m, L)
    M=np.array([[v2(t[(m-1)*n+j]) for j in range(m-1)] for n in range(16)])
    im=ax.imshow(M, aspect="auto", cmap="viridis")
    ax.set_title(f"m={m}"); ax.set_xlabel("offset j"); ax.set_ylabel("block n")
    fig.colorbar(im, ax=ax)
fig.suptitle("nu_2 across offsets: constant rows for m=5,9; varying rows for m=13")
plt.tight_layout(); plt.savefig("blockconstancy_heatmap.png", dpi=130)
print("wrote blockconstancy_heatmap.png")
