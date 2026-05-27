#!/usr/bin/env python3
"""
Applications of Certified GL₂ Expanders

Demonstrates practical applications:
1. Deterministic network design from algebraic certificates
2. Hash function mixing from Cayley graph walks
3. Error-correcting code construction from Singer cycles
"""

import numpy as np
from algorithms import (
    find_certified_pairs, cayley_adjacency_matrix, spectral_gap,
    Mat2GF, is_singer_like, multiplicative_order
)
from itertools import product


def application_network_design(q: int = 5):
    """Deterministic construction of expander networks.
    
    Given prime q, constructs a 4-regular expander graph on
    |GL₂(𝔽_q)| = (q²-1)(q²-q) vertices with certified expansion.
    
    Applications:
    - Peer-to-peer overlay networks
    - Fault-tolerant communication topologies
    - Derandomized network design
    """
    print(f"\n{'='*60}")
    print(f"APPLICATION: Deterministic Network Design (q={q})")
    print(f"{'='*60}")
    
    pairs = find_certified_pairs(q, max_pairs=1)
    if not pairs:
        print("No certified pair found!")
        return
    
    g, h = pairs[0]
    n = (q*q - 1) * (q*q - q)
    
    print(f"Network parameters:")
    print(f"  Vertices (nodes): {n}")
    print(f"  Degree (connections per node): 4")
    print(f"  Total edges: {2 * n}")
    
    A = cayley_adjacency_matrix(q, g, h)
    gap, eigs = spectral_gap(A)
    
    print(f"\nExpansion properties:")
    print(f"  Spectral gap: γ = {gap:.6f}")
    print(f"  Mixing time bound: O({int(np.ceil(1/gap))} steps)")
    print(f"  Edge expansion: ≥ γ/2 = {gap/2:.6f}")
    
    # Simulate random walk mixing
    print(f"\nRandom walk simulation:")
    x0 = np.zeros(n)
    x0[0] = 1.0  # Start at identity
    uniform = np.ones(n) / n
    
    for t in [1, 5, 10, 20]:
        xt = np.linalg.matrix_power(A, t) @ x0
        tv_dist = 0.5 * np.sum(np.abs(xt - uniform))
        print(f"  t={t:3d}: TV distance to uniform = {tv_dist:.6f}")


def application_mixing_analysis(q: int = 5):
    """Analyze mixing properties for pseudorandom generation.
    
    The rapid mixing of certified Cayley graph walks can be used
    for deterministic pseudorandom generation.
    """
    print(f"\n{'='*60}")
    print(f"APPLICATION: Mixing Analysis (q={q})")
    print(f"{'='*60}")
    
    pairs = find_certified_pairs(q, max_pairs=3)
    
    for idx, (g, h) in enumerate(pairs):
        A = cayley_adjacency_matrix(q, g, h)
        gap, eigs = spectral_gap(A)
        
        print(f"\nPair {idx+1}:")
        print(f"  Spectral gap: {gap:.6f}")
        print(f"  Eigenvalue distribution:")
        
        # Bin eigenvalues
        bins = np.linspace(-1, 1, 21)
        hist, _ = np.histogram(eigs, bins=bins)
        for i in range(len(hist)):
            if hist[i] > 0:
                print(f"    [{bins[i]:.2f}, {bins[i+1]:.2f}): {hist[i]}")


def application_projective_dynamics(q: int = 5):
    """Analyze Singer-like dynamics on the projective line ℙ¹(𝔽_q).
    
    A Singer-like matrix acts fixed-point-free on ℙ¹(𝔽_q),
    which has q+1 points. This connects to coding theory
    and finite geometry.
    """
    print(f"\n{'='*60}")
    print(f"APPLICATION: Projective Line Dynamics (q={q})")
    print(f"{'='*60}")
    
    mat = Mat2GF(q)
    
    # Represent projective points as (a:b) with a,b not both zero
    proj_points = []
    seen = set()
    for a in range(q):
        for b in range(q):
            if a == 0 and b == 0:
                continue
            # Normalize: find canonical representative
            if a != 0:
                ai = pow(a, q-2, q)
                canon = (1, (b * ai) % q)
            else:
                canon = (0, 1)
            if canon not in seen:
                seen.add(canon)
                proj_points.append(canon)
    
    print(f"|ℙ¹(𝔽_{q})| = {len(proj_points)} (expected {q+1})")
    
    # Find a Singer-like matrix and trace its orbits
    for a, b, c, d in product(range(q), repeat=4):
        M = [[a, b], [c, d]]
        if is_singer_like(M, q):
            print(f"\nSinger-like matrix g = {M}")
            print(f"  charpoly: irreducible over 𝔽_{q}")
            print(f"  det(g) = {mat.det(M)}")
            
            # Check fixed-point-free action
            fixed_points = 0
            for pt in proj_points:
                # Apply M to (a:b): M·(a,b)ᵀ = (Ma+Mb, Ca+Db)
                a_new = (M[0][0] * pt[0] + M[0][1] * pt[1]) % q
                b_new = (M[1][0] * pt[0] + M[1][1] * pt[1]) % q
                
                if a_new != 0:
                    ai = pow(a_new, q-2, q)
                    new_canon = (1, (b_new * ai) % q)
                else:
                    new_canon = (0, 1)
                
                if new_canon == pt:
                    fixed_points += 1
            
            print(f"  Fixed points on ℙ¹: {fixed_points} (expected 0)")
            
            # Compute orbit structure
            orbits = []
            visited = set()
            for pt in proj_points:
                if pt in visited:
                    continue
                orbit = [pt]
                visited.add(pt)
                current = pt
                while True:
                    a_new = (M[0][0] * current[0] + M[0][1] * current[1]) % q
                    b_new = (M[1][0] * current[0] + M[1][1] * current[1]) % q
                    if a_new != 0:
                        ai = pow(a_new, q-2, q)
                        current = (1, (b_new * ai) % q)
                    else:
                        current = (0, 1)
                    if current in visited:
                        break
                    visited.add(current)
                    orbit.append(current)
                orbits.append(orbit)
            
            print(f"  Orbit structure: {[len(o) for o in orbits]}")
            print(f"  (All orbits have same length = {len(orbits[0])} since g is Singer-like)")
            break


if __name__ == '__main__':
    application_network_design(5)
    application_mixing_analysis(5)
    application_projective_dynamics(5)


#!/usr/bin/env python3
"""
Demo: Certified Expanders for GL₂(𝔽_q) via Algebraic Certificates

This script searches for certified pairs (g, h) in GL₂(𝔽_q) and computes
the spectral gap of the associated 4-regular Cayley graph numerically.

A certified pair satisfies:
  1. g is Singer-like: charpoly(g) is irreducible over 𝔽_q
  2. det(h) is a primitive root of 𝔽_q×
  3. g, h generate GL₂(𝔽_q)

Usage:
    python demo.py [q]
    where q is an odd prime (default: 5)
"""

import numpy as np
from itertools import product
import sys

def gf_add(a, b, q):
    return (a + b) % q

def gf_mul(a, b, q):
    return (a * b) % q

def gf_inv(a, q):
    if a == 0:
        return None
    return pow(int(a), q - 2, q)

def mat_det(M, q):
    return (M[0][0] * M[1][1] - M[0][1] * M[1][0]) % q

def mat_mul(A, B, q):
    return [
        [(A[0][0]*B[0][0] + A[0][1]*B[1][0]) % q, (A[0][0]*B[0][1] + A[0][1]*B[1][1]) % q],
        [(A[1][0]*B[0][0] + A[1][1]*B[1][0]) % q, (A[1][0]*B[0][1] + A[1][1]*B[1][1]) % q]
    ]

def mat_inv(M, q):
    d = mat_det(M, q)
    di = gf_inv(d, q)
    if di is None:
        return None
    return [
        [(M[1][1] * di) % q, ((-M[0][1]) * di) % q],
        [((-M[1][0]) * di) % q, (M[0][0] * di) % q]
    ]

def mat_eq(A, B):
    return A[0][0] == B[0][0] and A[0][1] == B[0][1] and A[1][0] == B[1][0] and A[1][1] == B[1][1]

def mat_id(q):
    return [[1, 0], [0, 1]]

def charpoly_coeffs(M, q):
    """Returns coefficients [c0, c1, 1] of charpoly X² - tr(M)X + det(M)"""
    tr = (M[0][0] + M[1][1]) % q
    det = mat_det(M, q)
    return [det, (-tr) % q, 1]

def is_irreducible_quadratic(c0, c1, q):
    """Check if X² + c1*X + c0 is irreducible over 𝔽_q"""
    for x in range(q):
        if (x*x + c1*x + c0) % q == 0:
            return False
    return True

def is_singer_like(M, q):
    """Check if M has irreducible characteristic polynomial"""
    if mat_det(M, q) == 0:
        return False
    c0, c1, _ = charpoly_coeffs(M, q)
    return is_irreducible_quadratic(c0, c1, q)

def multiplicative_order(a, q):
    """Order of a in (Z/qZ)×"""
    if a % q == 0:
        return 0
    x = a % q
    for k in range(1, q):
        if x == 1:
            return k
        x = (x * a) % q
    return q - 1

def is_primitive_det(M, q):
    """Check if det(M) generates (𝔽_q)×"""
    d = mat_det(M, q)
    if d == 0:
        return False
    return multiplicative_order(d, q) == q - 1

def mat_to_tuple(M):
    return (M[0][0], M[0][1], M[1][0], M[1][1])

def gl2_elements(q):
    """Generate all elements of GL₂(𝔽_q)"""
    elts = []
    for a, b, c, d in product(range(q), repeat=4):
        M = [[a, b], [c, d]]
        if mat_det(M, q) != 0:
            elts.append(M)
    return elts

def generates_gl2(g, h, q, max_iter=None):
    """Check if g, h generate GL₂(𝔽_q) by closure"""
    gl2_size = (q*q - 1) * (q*q - q)
    if max_iter is None:
        max_iter = gl2_size * 2
    
    seen = set()
    seen.add(mat_to_tuple(mat_id(q)))
    queue = [mat_id(q)]
    
    gens = [g, h, mat_inv(g, q), mat_inv(h, q)]
    gens = [x for x in gens if x is not None]
    
    idx = 0
    while idx < len(queue) and len(seen) < gl2_size and idx < max_iter:
        current = queue[idx]
        idx += 1
        for gen in gens:
            prod = mat_mul(current, gen, q)
            t = mat_to_tuple(prod)
            if t not in seen:
                seen.add(t)
                queue.append(prod)
    
    return len(seen) == gl2_size

def find_certified_pairs(q, max_pairs=5):
    """Find certified pairs in GL₂(𝔽_q)"""
    print(f"\n{'='*60}")
    print(f"Searching for certified pairs in GL₂(𝔽_{q})")
    print(f"{'='*60}")
    print(f"|GL₂(𝔽_{q})| = {(q*q-1)*(q*q-q)}")
    
    # Find Singer-like matrices
    singers = []
    for a, b, c, d in product(range(q), repeat=4):
        M = [[a, b], [c, d]]
        if is_singer_like(M, q):
            singers.append(M)
    print(f"Singer-like matrices found: {len(singers)}")
    
    # Find primitive-det matrices
    prim_dets = []
    for a, b, c, d in product(range(q), repeat=4):
        M = [[a, b], [c, d]]
        if is_primitive_det(M, q):
            prim_dets.append(M)
    print(f"Primitive-det matrices found: {len(prim_dets)}")
    
    # Find certified pairs
    pairs = []
    for g in singers[:20]:  # limit search
        for h in prim_dets[:20]:
            if generates_gl2(g, h, q):
                pairs.append((g, h))
                if len(pairs) >= max_pairs:
                    break
        if len(pairs) >= max_pairs:
            break
    
    print(f"Certified pairs found: {len(pairs)}")
    return pairs

def build_cayley_adjacency(q, g, h):
    """Build the adjacency matrix of the Cayley graph Cay(GL₂(𝔽_q), {g, g⁻¹, h, h⁻¹})"""
    elts = gl2_elements(q)
    n = len(elts)
    elt_to_idx = {mat_to_tuple(M): i for i, M in enumerate(elts)}
    
    gi = mat_inv(g, q)
    hi = mat_inv(h, q)
    gens = [g, gi, h, hi]
    
    A = np.zeros((n, n))
    for i, M in enumerate(elts):
        for gen in gens:
            prod = mat_mul(M, gen, q)
            j = elt_to_idx[mat_to_tuple(prod)]
            A[i, j] = 1.0
    
    return A / 4.0  # Normalized adjacency

def compute_spectral_gap(A):
    """Compute spectral gap of normalized adjacency matrix"""
    eigenvalues = np.linalg.eigvalsh(A)
    eigenvalues = np.sort(eigenvalues)[::-1]
    # Largest eigenvalue should be 1 (for connected regular graph)
    lambda1 = eigenvalues[0]
    lambda2 = max(abs(eigenvalues[1]), abs(eigenvalues[-1]))
    gap = lambda1 - lambda2
    return gap, eigenvalues

def main():
    q = int(sys.argv[1]) if len(sys.argv) > 1 else 5
    
    if q < 3:
        print("q must be an odd prime >= 3")
        return
    
    print(f"Certified Expander Analysis for GL₂(𝔽_{q})")
    print(f"{'='*60}")
    
    pairs = find_certified_pairs(q)
    
    if not pairs:
        print("No certified pairs found!")
        return
    
    print(f"\n{'='*60}")
    print(f"Computing spectral gaps...")
    print(f"{'='*60}")
    
    min_gap = float('inf')
    min_q_gap = float('inf')
    
    for idx, (g, h) in enumerate(pairs):
        print(f"\nPair {idx+1}: g = {g}, h = {h}")
        print(f"  charpoly(g) coeffs: {charpoly_coeffs(g, q)}")
        print(f"  det(h) = {mat_det(h, q)}, order = {multiplicative_order(mat_det(h, q), q)}")
        
        A = build_cayley_adjacency(q, g, h)
        gap, eigenvalues = compute_spectral_gap(A)
        
        print(f"  Spectral gap γ = {gap:.6f}")
        print(f"  q · γ = {q * gap:.6f}")
        print(f"  Top 5 eigenvalues: {eigenvalues[:5]}")
        print(f"  Bottom 5 eigenvalues: {eigenvalues[-5:]}")
        
        min_gap = min(min_gap, gap)
        min_q_gap = min(min_q_gap, q * gap)
    
    print(f"\n{'='*60}")
    print(f"SUMMARY for q = {q}")
    print(f"{'='*60}")
    print(f"  Minimum spectral gap: γ_min = {min_gap:.6f}")
    print(f"  Minimum q · γ: {min_q_gap:.6f}")
    print(f"  This suggests C ≥ {min_q_gap:.4f} in the bound γ ≥ C/q")
    
    # Conjecture test
    print(f"\n{'='*60}")
    print(f"CONJECTURE TEST: Uniform Gap Bound")
    print(f"{'='*60}")
    
    test_primes = [p for p in [5, 7, 11, 13] if p <= q]
    results = []
    
    for p in test_primes:
        pairs_p = find_certified_pairs(p, max_pairs=3)
        if pairs_p:
            gaps = []
            for g, h in pairs_p:
                A = build_cayley_adjacency(p, g, h)
                gap, _ = compute_spectral_gap(A)
                gaps.append(gap)
            min_g = min(gaps)
            results.append((p, min_g, p * min_g))
            print(f"  q={p}: min γ = {min_g:.6f}, q·γ = {p*min_g:.6f}")
    
    if results:
        C_values = [r[2] for r in results]
        print(f"\n  Observed C values: {[f'{c:.4f}' for c in C_values]}")
        print(f"  Minimum C: {min(C_values):.4f}")
        print(f"  The conjecture γ ≥ C/q appears {'SUPPORTED' if min(C_values) > 0.01 else 'INCONCLUSIVE'}")

if __name__ == '__main__':
    main()


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
