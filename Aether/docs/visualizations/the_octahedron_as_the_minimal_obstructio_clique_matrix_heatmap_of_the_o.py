import matplotlib.pyplot as plt
import numpy as np
from itertools import combinations

def octa():
    g={v:set() for v in range(6)}
    for u,v in combinations(range(6),2):
        if u//2!=v//2: g[u].add(v); g[v].add(u)
    return g

def is_clique(g,s):
    return all(v in g[u] for u,v in combinations(sorted(s),2))

def max_cliques(g):
    found=[]
    for r in range(1,7):
        for c in combinations(range(6),r):
            s=set(c)
            if is_clique(g,s): found.append(s)
    return [frozenset(s) for s in found if not any(s<t for t in found)]

g=octa()
cols=sorted((tuple(sorted(c)) for c in max_cliques(g)))
M=np.array([[1 if v in c else 0 for c in cols] for v in range(6)])
fig,ax=plt.subplots(figsize=(8,4))
ax.imshow(M,cmap="Blues",aspect="auto")
ax.set_xticks(range(len(cols))); ax.set_xticklabels([str(c) for c in cols],rotation=45,ha="right",fontsize=8)
ax.set_yticks(range(6)); ax.set_yticklabels(["v%d"%v for v in range(6)])
for i in range(6):
    for j in range(len(cols)):
        ax.text(j,i,str(M[i,j]),ha="center",va="center",color="black",fontsize=8)
ax.set_title("Clique matrix of the octahedron (6 vertices x 8 maximal triangles)")
plt.tight_layout(); plt.savefig("clique_matrix.png",dpi=150)
print("saved clique_matrix.png")
