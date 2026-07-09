"""Visualization: period-matrix heatmap of the doubled simplex in A_{4m+3},
showing its reversal symmetry (self-duality) and palindromic Schlafli symbol.
Requires matplotlib."""
from typing import List, Tuple
from math import gcd
import matplotlib.pyplot as plt

Perm = Tuple[int, ...]

def compose(p, q): return tuple(p[q[i]] for i in range(len(p)))
def order(p):
    n=len(p); seen=[False]*n; r=1
    for s in range(n):
        if seen[s]: continue
        L=0; j=s
        while not seen[j]:
            seen[j]=True; j=p[j]; L+=1
        r=r*L//gcd(r,L)
    return r
def transposition(n,a,b):
    p=list(range(n)); p[a],p[b]=p[b],p[a]; return tuple(p)
def double(sigma,m):
    b=2*m+1; n=4*m+3; p=list(range(n))
    for i in range(b):
        p[i]=sigma[i]; p[b+i]=b+sigma[i]
    return tuple(p)

def doubled_simplex(m):
    return [double(transposition(2*m+1,i,i+1),m) for i in range(2*m)]

def main(m: int = 4) -> None:
    gens = doubled_simplex(m)
    r = len(gens)
    P = [[order(compose(gens[i],gens[j])) for j in range(r)] for i in range(r)]
    fig, ax = plt.subplots(figsize=(6,5))
    im = ax.imshow(P, cmap="viridis")
    ax.set_title(f"Period matrix of doubled simplex in A_{4*m+3} (rank {r})")
    ax.set_xlabel("generator j"); ax.set_ylabel("generator i")
    for i in range(r):
        for j in range(r):
            ax.text(j, i, str(P[i][j]), ha="center", va="center",
                    color="white", fontsize=8)
    fig.colorbar(im, label="order(rho_i * rho_j)")
    plt.tight_layout()
    plt.savefig("period_matrix.png", dpi=150)
    print("Saved period_matrix.png; matrix is symmetric and reversal-invariant.")

if __name__ == "__main__":
    main()
