#!/usr/bin/env python3
"""
Visualization 2: Dichotomy Heatmap across Fields and Families

Creates a heatmap showing the growth ratio |A²|/|A| for various
polynomially definable families across different finite fields F_p.

Green cells (ratio = 1.0) indicate subgroups.
Warm cells (ratio > 1.0) indicate strict growth.
This directly illustrates the binary nature of the dichotomy theorem.
"""

import matplotlib.pyplot as plt
import matplotlib
matplotlib.use('Agg')
import numpy as np


# Self-contained matrix arithmetic
def mat_mul(A, B, p):
    return [[(A[0][0]*B[0][0]+A[0][1]*B[1][0])%p, (A[0][0]*B[0][1]+A[0][1]*B[1][1])%p],
            [(A[1][0]*B[0][0]+A[1][1]*B[1][0])%p, (A[1][0]*B[0][1]+A[1][1]*B[1][1])%p]]

def mat_det(M, p): return (M[0][0]*M[1][1]-M[0][1]*M[1][0])%p

def mat_inv(M, p):
    d = mat_det(M, p)
    if d == 0: return None
    di = pow(d, p-2, p)
    return [[(M[1][1]*di)%p,((-M[0][1])*di)%p],[((-M[1][0])*di)%p,(M[0][0]*di)%p]]

def to_t(M): return (M[0][0],M[0][1],M[1][0],M[1][1])
def to_m(t): return [[t[0],t[1]],[t[2],t[3]]]

def symmetrize(S, p):
    r = set(S); r.add(to_t([[1,0],[0,1]]))
    for s in list(S):
        inv = mat_inv(to_m(s), p)
        if inv: r.add(to_t(inv))
    return r

def product(A, B, p):
    return {to_t(mat_mul(to_m(a), to_m(b), p)) for a in A for b in B}


# Family generators
def unipotent(p):
    return {to_t([[1,t],[0,1]]) for t in range(p)}

def diagonal(p):
    return {to_t([[a,0],[0,b]]) for a in range(1,p) for b in range(1,p)}

def scalar(p):
    return {to_t([[a,0],[0,a]]) for a in range(1,p)}

def shear(p):
    r = set()
    for t in range(p):
        M = [[1,t],[(t*t)%p,1]]
        if mat_det(M,p) != 0: r.add(to_t(M))
    return r

def circle(p):
    r = set()
    for a in range(p):
        for b in range(p):
            M = [[a,b],[(-b)%p,a]]
            if mat_det(M,p) != 0: r.add(to_t(M))
    return r

def two_gen(p):
    return {to_t([[1,1],[0,1]]), to_t([[1,0],[1,1]])}

def lower_tri(p):
    return {to_t([[1,0],[t,1]]) for t in range(p)}

def mixed(p):
    r = unipotent(p)
    if p > 2:
        g = 2%p; gi = pow(g,p-2,p)
        r.add(to_t([[g,0],[0,gi]]))
    return r


primes = [3, 5, 7, 11, 13]
family_names = ["Unipotent", "Diagonal", "Scalar", "Shear", "Circle",
                "2-gen", "Lower tri", "Mixed"]
family_gens = [unipotent, diagonal, scalar, shear, circle,
               two_gen, lower_tri, mixed]

data = np.zeros((len(family_names), len(primes)))
annotations = [['' for _ in primes] for _ in family_names]

for j, p in enumerate(primes):
    for i, (name, gen) in enumerate(zip(family_names, family_gens)):
        A = symmetrize(gen(p), p)
        AA = product(A, A, p)
        ratio = len(AA) / len(A) if len(A) > 0 else 0
        data[i, j] = ratio
        annotations[i][j] = f"{ratio:.2f}\n({len(A)}→{len(AA)})"

fig, ax = plt.subplots(figsize=(12, 8))

# Custom colormap: green for ratio=1 (subgroup), red for high ratio
from matplotlib.colors import LinearSegmentedColormap
colors = ['#2ecc71', '#f1c40f', '#e74c3c', '#8e44ad']
cmap = LinearSegmentedColormap.from_list('growth', colors, N=256)

im = ax.imshow(data, cmap=cmap, aspect='auto', vmin=1.0, vmax=max(3.0, data.max()))

# Annotations
for i in range(len(family_names)):
    for j in range(len(primes)):
        color = 'white' if data[i,j] > 2.0 else 'black'
        ax.text(j, i, annotations[i][j], ha='center', va='center',
                fontsize=8, color=color, fontweight='bold')

ax.set_xticks(range(len(primes)))
ax.set_xticklabels([f"F_{p}" for p in primes], fontsize=12)
ax.set_yticks(range(len(family_names)))
ax.set_yticklabels(family_names, fontsize=11)

cbar = plt.colorbar(im, ax=ax, shrink=0.8)
cbar.set_label("|A²|/|A| (Growth Ratio)", fontsize=12)

ax.set_title("Growth-or-Control Dichotomy Heatmap\nGreen = Subgroup (ratio 1.0), Warm = Strict Growth",
             fontsize=14, fontweight='bold')

# Add grid
for i in range(len(family_names)+1):
    ax.axhline(i-0.5, color='white', linewidth=2)
for j in range(len(primes)+1):
    ax.axvline(j-0.5, color='white', linewidth=2)

plt.tight_layout()
plt.savefig("dichotomy_heatmap.png", dpi=150, bbox_inches='tight')
print("Saved dichotomy_heatmap.png")
