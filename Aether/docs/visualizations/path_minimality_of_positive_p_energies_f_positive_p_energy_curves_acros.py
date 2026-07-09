"""Visualization: positive p-energy vs exponent p for connected graphs on n=6."""
import math
import matplotlib.pyplot as plt

def eigs(adj):
    import numpy as np
    return np.linalg.eigvalsh(np.array(adj, dtype=float)).tolist()
def path(n):
    a=[[0]*n for _ in range(n)]
    for i in range(n-1): a[i][i+1]=a[i+1][i]=1
    return a
def cycle(n):
    a=[[0]*n for _ in range(n)]
    for i in range(n): a[i][(i+1)%n]=a[(i+1)%n][i]=1
    return a
def kbip(a_,b_):
    n=a_+b_; a=[[0]*n for _ in range(n)]
    for i in range(a_):
        for j in range(a_,n): a[i][j]=a[j][i]=1
    return a

ps=[2+0.1*i for i in range(31)]
graphs={"P_6":path(6),"C_6":cycle(6),"K_2,4":kbip(2,4)}
for name,g in graphs.items():
    ev=eigs(g)
    plt.plot(ps,[sum(l**p for l in ev if l>1e-9) for p in ps],label=name)
plt.xlabel("exponent p"); plt.ylabel("positive p-energy E_p^+")
plt.title("Positive p-energy vs p (path stays lowest)")
plt.legend(); plt.tight_layout(); plt.savefig("penergy_curves.png", dpi=150)
print("wrote penergy_curves.png")
