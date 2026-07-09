"""Visualization: squared energy sum lambda^2 = 2|E| for several graphs."""
import math
import matplotlib.pyplot as plt

def eigs_via_numpy(adj):
    import numpy as np
    return sorted(np.linalg.eigvalsh(np.array(adj, dtype=float)).tolist(), reverse=True)

def path(n):
    a=[[0]*n for _ in range(n)]
    for i in range(n-1): a[i][i+1]=a[i+1][i]=1
    return a
def cycle(n):
    a=[[0]*n for _ in range(n)]
    for i in range(n): a[i][(i+1)%n]=a[(i+1)%n][i]=1
    return a
def star(n):
    a=[[0]*n for _ in range(n)]
    for i in range(1,n): a[0][i]=a[i][0]=1
    return a

n=6
graphs={"P_6":path(n),"C_6":cycle(n),"Star":star(n)}
names=list(graphs); vals=[sum(l*l for l in eigs_via_numpy(g)) for g in graphs.values()]
plt.bar(names, vals, color="steelblue")
plt.axhline(2*(n-1), color="crimson", ls="--", label="2(n-1) lower bound")
plt.ylabel("sum lambda^2 = 2|E|"); plt.title("Squared spectral energy, n=6")
plt.legend(); plt.tight_layout(); plt.savefig("squared_energy_bars.png", dpi=150)
print("wrote squared_energy_bars.png")
