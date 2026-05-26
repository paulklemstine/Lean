#!/usr/bin/env python3
"""
Visualization 3: Stabilization Staircase

Visualizes the "staircase" pattern of power set growth for multiple
families, showing how each family grows strictly at every step until
it stabilizes into a subgroup. This directly illustrates the
stabilization theorem: A^k = A^(k+1) implies A^k is a subgroup.

The plot shows normalized growth (fraction of GL(2, F_p) covered)
as a function of the power k, creating a characteristic staircase
shape where each step is strictly positive until the final plateau.
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


def two_gen(p): return {to_t([[1,1],[0,1]]), to_t([[1,0],[1,1]])}
def three_gen(p): return {to_t([[1,1],[0,1]]), to_t([[0,1],[(-1)%p,0]])}
def shear(p):
    r = set()
    for t in range(p):
        M = [[1,t],[(t*t)%p,1]]
        if mat_det(M,p) != 0: r.add(to_t(M))
    return r
def mixed(p):
    r = {to_t([[1,t],[0,1]]) for t in range(p)}
    if p > 2:
        g = 2%p; gi = pow(g,p-2,p)
        r.add(to_t([[g,0],[0,gi]])); r.add(to_t([[gi,0],[0,g]]))
    return r


p = 7
gl_size = (p**2-1)*(p**2-p)

families = [
    ("2 generators (SL₂ type)", two_gen, "tab:blue"),
    ("Permutation + unipotent", three_gen, "tab:orange"),
    ("Polynomial shear", shear, "tab:green"),
    ("Mixed (unipotent + diagonal)", mixed, "tab:red"),
]

fig, axes = plt.subplots(2, 2, figsize=(14, 10))
axes = axes.flatten()

for idx, (name, gen, color) in enumerate(families):
    ax = axes[idx]
    A = symmetrize(gen(p), p)

    sizes = [len(A)]
    cur = A
    for _ in range(15):
        cur = product(cur, A, p)
        sizes.append(len(cur))
        if sizes[-1] == sizes[-2]:
            # Pad to show plateau
            for _ in range(3):
                sizes.append(sizes[-1])
            break

    ks = list(range(1, len(sizes)+1))
    normalized = [s/gl_size for s in sizes]

    # Fill area
    ax.fill_between(ks, 0, normalized, alpha=0.3, color=color)
    ax.plot(ks, normalized, 'o-', color=color, markersize=6, linewidth=2)

    # Mark stabilization point
    stab_k = None
    for i in range(1, len(sizes)):
        if sizes[i] == sizes[i-1]:
            stab_k = i
            break

    if stab_k:
        ax.axvline(x=stab_k, color='red', linestyle='--', alpha=0.7)
        ax.annotate(f'Stabilized\nk={stab_k}\n|A^k|={sizes[stab_k-1]}',
                    xy=(stab_k, normalized[stab_k-1]),
                    xytext=(stab_k+1, normalized[stab_k-1]*0.7),
                    fontsize=9, arrowprops=dict(arrowstyle='->', color='red'),
                    color='red', fontweight='bold')

    # Mark each strict growth step
    for i in range(1, min(len(sizes), stab_k or len(sizes))):
        if sizes[i] > sizes[i-1]:
            ax.annotate('', xy=(i+1, normalized[i]),
                       xytext=(i+1, normalized[i-1]),
                       arrowprops=dict(arrowstyle='->', color='green', lw=1.5))

    ax.set_xlabel("Power k", fontsize=11)
    ax.set_ylabel("Fraction of GL(2,F₇)", fontsize=11)
    ax.set_title(f"{name}\n|A|={sizes[0]}, stabilizes at |A^k|={sizes[stab_k-1] if stab_k else '?'}",
                 fontsize=12, fontweight='bold')
    ax.set_ylim(0, 1.1)
    ax.axhline(y=1.0, color='gray', linestyle=':', alpha=0.5)
    ax.grid(True, alpha=0.2)

fig.suptitle(f"Stabilization Staircase in GL(2, F_{p})\n"
             "Every step is strictly positive until the final subgroup plateau\n"
             "(Theorem 4: stabilization_is_subgroup)",
             fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig("stabilization_staircase.png", dpi=150, bbox_inches='tight')
print("Saved stabilization_staircase.png")
