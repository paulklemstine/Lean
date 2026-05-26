#!/usr/bin/env python3
"""
Visualization 1: Growth Profile of Polynomially Definable Families

Visualizes the |A^k| growth curves for multiple families in GL(2, F_p),
showing the dichotomy between subgroup families (flat curves) and
non-subgroup families (strictly growing curves until stabilization).

This illustrates the core theorem: symmetric sets containing the identity
either ARE subgroups (constant size) or exhibit STRICT growth at every step.
"""

import matplotlib.pyplot as plt
import matplotlib
matplotlib.use('Agg')
import itertools


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

def power_sizes(A, p, maxk=10):
    sizes = [len(A)]; cur = A
    for _ in range(maxk-1):
        cur = product(cur, A, p)
        sizes.append(len(cur))
        if sizes[-1] == sizes[-2]: break
    return sizes


# Families
def unipotent(p):
    return {to_t([[1,t],[0,1]]) for t in range(p)}

def diagonal(p):
    return {to_t([[a,0],[0,b]]) for a in range(1,p) for b in range(1,p)}

def shear(p):
    r = set()
    for t in range(p):
        M = [[1,t],[(t*t)%p,1]]
        if mat_det(M,p) != 0: r.add(to_t(M))
    return r

def mixed(p):
    r = unipotent(p)
    if p > 2:
        g = 2%p; gi = pow(g,p-2,p)
        r.add(to_t([[g,0],[0,gi]])); r.add(to_t([[gi,0],[0,g]]))
    return r

def small_gen(p):
    return {to_t([[1,1],[0,1]]), to_t([[1,0],[1,1]])}


p = 7
gl_size = (p**2-1)*(p**2-p)

families = [
    ("Unipotent (subgroup)", unipotent, "tab:blue", "-o"),
    ("Diagonal (subgroup)", diagonal, "tab:orange", "-s"),
    ("Poly shear (non-subgroup)", shear, "tab:green", "-^"),
    ("Mixed generators", mixed, "tab:red", "-D"),
    ("Two generators", small_gen, "tab:purple", "-v"),
]

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

for name, gen, color, marker in families:
    A = symmetrize(gen(p), p)
    sizes = power_sizes(A, p, 10)
    ks = list(range(1, len(sizes)+1))
    ax1.plot(ks, sizes, marker, color=color, label=f"{name} (|A|={sizes[0]})",
             markersize=8, linewidth=2)

ax1.axhline(y=gl_size, color='gray', linestyle='--', alpha=0.5, label=f"|GL(2,F_{p})| = {gl_size}")
ax1.set_xlabel("Power k", fontsize=13)
ax1.set_ylabel("|A^k|", fontsize=13)
ax1.set_title(f"Growth Profiles in GL(2, F_{p})", fontsize=15, fontweight='bold')
ax1.legend(fontsize=9, loc='lower right')
ax1.set_yscale('log')
ax1.grid(True, alpha=0.3)

# Right panel: growth ratios
for name, gen, color, marker in families:
    A = symmetrize(gen(p), p)
    sizes = power_sizes(A, p, 10)
    if len(sizes) > 1:
        ratios = [sizes[i]/sizes[i-1] for i in range(1, len(sizes))]
        ks = list(range(2, len(sizes)+1))
        ax2.plot(ks, ratios, marker, color=color, label=name,
                 markersize=8, linewidth=2)

ax2.axhline(y=1.0, color='black', linestyle='-', alpha=0.3, linewidth=2)
ax2.set_xlabel("Power k", fontsize=13)
ax2.set_ylabel("|A^k| / |A^(k-1)|", fontsize=13)
ax2.set_title("Growth Ratios (= 1 iff stabilized)", fontsize=15, fontweight='bold')
ax2.legend(fontsize=9)
ax2.grid(True, alpha=0.3)

fig.suptitle("Growth-or-Control Dichotomy: Subgroups vs. Expanding Sets",
             fontsize=16, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig("growth_profile.png", dpi=150, bbox_inches='tight')
print("Saved growth_profile.png")
