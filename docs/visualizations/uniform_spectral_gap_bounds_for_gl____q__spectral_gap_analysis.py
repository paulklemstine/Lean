#!/usr/bin/env python3
"""
Visualization: Spectral Gap Analysis for Certified GL₂ Expanders

Produces a plot showing:
1. Eigenvalue distribution of certified Cayley graphs
2. Spectral gap as a function of q
3. The q·γ product testing the uniform bound conjecture

This script is fully self-contained — no local imports.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import product


# ── Inline helpers (no local imports) ───────────────────────────

def _mat_det(M, q):
    return (M[0][0]*M[1][1] - M[0][1]*M[1][0]) % q

def _mat_mul(A, B, q):
    return [
        [(A[0][0]*B[0][0]+A[0][1]*B[1][0])%q, (A[0][0]*B[0][1]+A[0][1]*B[1][1])%q],
        [(A[1][0]*B[0][0]+A[1][1]*B[1][0])%q, (A[1][0]*B[0][1]+A[1][1]*B[1][1])%q]
    ]

def _mat_inv(M, q):
    d = _mat_det(M, q)
    di = pow(int(d), q-2, q) if d != 0 else None
    if di is None: return None
    return [[(M[1][1]*di)%q, ((-M[0][1])*di)%q],
            [((-M[1][0])*di)%q, (M[0][0]*di)%q]]

def _is_singer(M, q):
    if _mat_det(M, q) == 0: return False
    tr = (M[0][0]+M[1][1]) % q
    det = _mat_det(M, q)
    c0, c1 = det, (-tr) % q
    for x in range(q):
        if (x*x + c1*x + c0) % q == 0: return False
    return True

def _mult_order(a, q):
    if a % q == 0: return 0
    x = a % q
    for k in range(1, q):
        if x == 1: return k
        x = (x*a) % q
    return q-1

def _is_prim_det(M, q):
    d = _mat_det(M, q)
    return d != 0 and _mult_order(d, q) == q-1

def _generates(g, h, q):
    gl2_size = (q*q-1)*(q*q-q)
    seen = {(1,0,0,1)}
    queue = [[[1,0],[0,1]]]
    gi, hi = _mat_inv(g, q), _mat_inv(h, q)
    gens = [x for x in [g,h,gi,hi] if x]
    idx = 0
    while idx < len(queue) and len(seen) < gl2_size:
        cur = queue[idx]; idx += 1
        for gen in gens:
            p = _mat_mul(cur, gen, q)
            t = (p[0][0],p[0][1],p[1][0],p[1][1])
            if t not in seen:
                seen.add(t); queue.append(p)
    return len(seen) == gl2_size

def _find_pair(q):
    for a,b,c,d in product(range(q), repeat=4):
        g = [[a,b],[c,d]]
        if not _is_singer(g, q): continue
        for a2,b2,c2,d2 in product(range(q), repeat=4):
            h = [[a2,b2],[c2,d2]]
            if _is_prim_det(h, q) and _generates(g, h, q):
                return g, h
    return None, None

def _cayley_adj(q, g, h):
    elts = []
    for a,b,c,d in product(range(q), repeat=4):
        M = [[a,b],[c,d]]
        if _mat_det(M, q) != 0: elts.append(M)
    n = len(elts)
    idx = {(M[0][0],M[0][1],M[1][0],M[1][1]): i for i, M in enumerate(elts)}
    gi, hi = _mat_inv(g, q), _mat_inv(h, q)
    A = np.zeros((n, n))
    for i, M in enumerate(elts):
        for gen in [g, gi, h, hi]:
            p = _mat_mul(M, gen, q)
            j = idx[(p[0][0],p[0][1],p[1][0],p[1][1])]
            A[i, j] += 1.0
    return A / 4.0

def _spec_gap(A):
    eigs = np.sort(np.linalg.eigvalsh(A))[::-1]
    lam2 = max(abs(eigs[1]), abs(eigs[-1]))
    return eigs[0] - lam2, eigs


# ── Main visualization ──────────────────────────────────────────

def main():
    fig, axes = plt.subplots(1, 3, figsize=(16, 5))
    
    primes = [5, 7]
    colors = ['#2196F3', '#FF5722', '#4CAF50']
    
    # Panel 1: Eigenvalue distribution for q=5
    ax1 = axes[0]
    g, h = _find_pair(5)
    if g:
        A = _cayley_adj(5, g, h)
        gap, eigs = _spec_gap(A)
        ax1.hist(eigs, bins=50, color=colors[0], alpha=0.7, edgecolor='black', linewidth=0.5)
        ax1.axvline(x=1, color='red', linestyle='--', linewidth=2, label='λ₁ = 1')
        ax1.axvline(x=1-gap, color='orange', linestyle='--', linewidth=2, label=f'1-γ = {1-gap:.3f}')
        ax1.set_xlabel('Eigenvalue', fontsize=12)
        ax1.set_ylabel('Count', fontsize=12)
        ax1.set_title(f'Spectrum of Cay(GL₂(𝔽₅), S)\nγ = {gap:.4f}', fontsize=13)
        ax1.legend(fontsize=10)
    
    # Panel 2: Spectral gap vs q
    ax2 = axes[1]
    gaps = []
    q_gaps = []
    for p in primes:
        g, h = _find_pair(p)
        if g:
            A = _cayley_adj(p, g, h)
            gap, _ = _spec_gap(A)
            gaps.append(gap)
            q_gaps.append(p * gap)
    
    if gaps:
        ax2.plot(primes[:len(gaps)], gaps, 'o-', color=colors[0], markersize=10, linewidth=2, label='γ(q)')
        # Overlay C/q reference
        C_est = min(q_gaps)
        q_range = np.linspace(4, max(primes) + 1, 100)
        ax2.plot(q_range, C_est / q_range, '--', color='gray', linewidth=1.5, 
                label=f'C/q (C={C_est:.2f})')
        ax2.set_xlabel('Prime q', fontsize=12)
        ax2.set_ylabel('Spectral gap γ', fontsize=12)
        ax2.set_title('Spectral Gap vs. Prime q', fontsize=13)
        ax2.legend(fontsize=10)
        ax2.grid(True, alpha=0.3)
    
    # Panel 3: q·γ product (uniform bound test)
    ax3 = axes[2]
    if q_gaps:
        ax3.bar(primes[:len(q_gaps)], q_gaps, color=colors[1], alpha=0.8, edgecolor='black')
        ax3.axhline(y=min(q_gaps), color='green', linestyle='--', linewidth=2,
                   label=f'C = {min(q_gaps):.3f}')
        ax3.set_xlabel('Prime q', fontsize=12)
        ax3.set_ylabel('q · γ', fontsize=12)
        ax3.set_title('Uniform Gap Test: q·γ ≥ C?', fontsize=13)
        ax3.legend(fontsize=10)
        ax3.grid(True, alpha=0.3, axis='y')
    
    plt.tight_layout()
    plt.savefig('spectral_gap_analysis.png', dpi=150, bbox_inches='tight')
    print("Saved: spectral_gap_analysis.png")
    plt.close()


if __name__ == '__main__':
    main()
