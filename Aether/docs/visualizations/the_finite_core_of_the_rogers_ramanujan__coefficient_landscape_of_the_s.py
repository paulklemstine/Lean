"""Heatmap of the coefficients of the Schur polynomials D_n (a q-Fibonacci
triangle). Requires matplotlib and numpy."""
import numpy as np
import matplotlib.pyplot as plt
from typing import List

Poly = List[int]

def add(a, b):
    out = [0]*max(len(a),len(b))
    for i,c in enumerate(a): out[i]+=c
    for i,c in enumerate(b): out[i]+=c
    while out and out[-1]==0: out.pop()
    return out

def schur(n: int) -> Poly:
    a,b=[1],[1]
    if n==0: return a
    for i in range(n-1):
        a,b=b,add(b,[0]*(i+1)+a)
    return b

N = 14
polys = [schur(n) for n in range(N)]
W = max(len(p) for p in polys)
M = np.zeros((N, W))
for n,p in enumerate(polys):
    for e,c in enumerate(p):
        M[n,e]=c
plt.figure(figsize=(9,5))
plt.imshow(M, aspect="auto", cmap="magma", origin="lower")
plt.colorbar(label="coefficient of q^m in D_n")
plt.xlabel("exponent m")
plt.ylabel("n")
plt.title("Coefficient landscape of the Schur / Rogers-Ramanujan polynomials D_n")
plt.tight_layout()
plt.savefig("schur_coefficients.png", dpi=150)
print("wrote schur_coefficients.png")
