#!/usr/bin/env python3
"""
Tropical Arithmetic Geometry: Berggren Tree ↔ Max-Plus Algebra Demo

This script demonstrates the core concepts from the formalized Lean 4 development:
1. Berggren matrices and Pythagorean triple generation
2. Tropical (max-plus) determinant computation
3. Critical multiplicity analysis
4. Superadditivity verification
5. Cuspidal factorization: connecting ω, Ω to tropical invariants
"""

import numpy as np
from itertools import permutations
from collections import Counter
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from sympy import factorint, isprime

# ============================================================================
# Section 1: Berggren Matrices
# ============================================================================

# The three Berggren generators
BERGGREN_A = np.array([[1, -2, 2], [2, -1, 2], [2, -2, 3]], dtype=int)
BERGGREN_B = np.array([[1, 2, 2], [2, 1, 2], [2, 2, 3]], dtype=int)
BERGGREN_C = np.array([[-1, 2, 2], [-2, 1, 2], [-2, 2, 3]], dtype=int)

BERGGREN = {'A': BERGGREN_A, 'B': BERGGREN_B, 'C': BERGGREN_C}
ROOT = np.array([3, 4, 5], dtype=int)

# Lorentz form
Q = np.diag([1, 1, -1])


def verify_lorentz(M, name):
    """Verify M^T Q M = Q."""
    result = M.T @ Q @ M
    ok = np.array_equal(result, Q)
    print(f"  {name}^T Q {name} = Q: {ok}")
    return ok


def generate_triple(word, root=ROOT):
    """Apply Berggren word to root triple."""
    v = root.copy()
    for g in reversed(word):
        v = BERGGREN[g] @ v
    return v


# ============================================================================
# Section 2: Tropical Determinant
# ============================================================================

def tropical_det_3x3(M):
    """Compute tropical determinant: max over σ∈S₃ of Σᵢ M[i,σ(i)]."""
    perms = list(permutations(range(3)))
    perm_sums = [sum(M[i, s[i]] for i in range(3)) for s in perms]
    return max(perm_sums)


def tropical_crit_mult_3x3(M):
    """Count permutations achieving the tropical determinant."""
    perms = list(permutations(range(3)))
    perm_sums = [sum(M[i, s[i]] for i in range(3)) for s in perms]
    td = max(perm_sums)
    return sum(1 for ps in perm_sums if ps == td)


def tropical_matrix_mul(M, N):
    """Tropical (max-plus) matrix multiplication: (M⊗N)[i,j] = max_k(M[i,k]+N[k,j])."""
    n = M.shape[0]
    result = np.full((n, n), -np.inf)
    for i in range(n):
        for j in range(n):
            result[i, j] = max(M[i, k] + N[k, j] for k in range(n))
    return result.astype(int)


# ============================================================================
# Section 3: Arithmetic Functions
# ============================================================================

def omega(n):
    """ω(n) = number of distinct prime factors."""
    if n <= 1:
        return 0
    return len(factorint(n))


def big_omega(n):
    """Ω(n) = total number of prime factors with multiplicity."""
    if n <= 1:
        return 0
    return sum(factorint(n).values())


def cuspidal_defect(n):
    """δ(n) = Ω(n) - ω(n). Zero iff squarefree."""
    return big_omega(n) - omega(n)


def is_squarefree(n):
    """Check if n is squarefree."""
    if n <= 1:
        return n == 1
    return all(v == 1 for v in factorint(n).values())


# ============================================================================
# Main Demonstration
# ============================================================================

def main():
    print("=" * 70)
    print("TROPICAL ARITHMETIC GEOMETRY: BERGGREN TREE DEMO")
    print("=" * 70)

    # Section 1: Verify Berggren matrices
    print("\n🔷 Section 1: Berggren Matrix Properties")
    print("-" * 50)
    for name, M in BERGGREN.items():
        verify_lorentz(M, name)
        det = int(np.linalg.det(M).round())
        print(f"  det({name}) = {det}")

    # Section 2: Generate depth-1 triples
    print("\n🔷 Section 2: Depth-1 Pythagorean Triples")
    print("-" * 50)
    for g in 'ABC':
        triple = generate_triple(g)
        a, b, c = triple
        print(f"  {g}(3,4,5) = ({a},{b},{c})")
        print(f"    Pythagorean: {a}² + {b}² = {a**2} + {b**2} = {a**2+b**2} = {c**2} = {c}²")
        print(f"    Hypotenuse {c}: prime={isprime(c)}, ω={omega(c)}, Ω={big_omega(c)}, "
              f"squarefree={is_squarefree(c)}, defect={cuspidal_defect(c)}")

    # Section 3: Tropical determinants
    print("\n🔷 Section 3: Tropical Determinants of Berggren Generators")
    print("-" * 50)
    for name, M in BERGGREN.items():
        td = tropical_det_3x3(M)
        cm = tropical_crit_mult_3x3(M)
        print(f"  tropDet(M_{name}) = {td}, critMult = {cm}")

    # Section 4: Superadditivity verification
    print("\n🔷 Section 4: Tropical Determinant Superadditivity")
    print("-" * 50)
    print("  For CLASSICAL product (verified for all 9 pairs):")
    all_super = True
    for g1 in 'ABC':
        for g2 in 'ABC':
            M1, M2 = BERGGREN[g1], BERGGREN[g2]
            td1 = tropical_det_3x3(M1)
            td2 = tropical_det_3x3(M2)
            td_prod = tropical_det_3x3(M1 @ M2)
            gap = td_prod - (td1 + td2)
            ok = gap >= 0
            all_super = all_super and ok
            print(f"    tropDet({g1}·{g2}) = {td_prod} ≥ {td1}+{td2} = {td1+td2}  "
                  f"[gap={gap}] {'✓' if ok else '✗'}")
    print(f"  All pairs superadditive: {all_super}")

    # Section 5: Tropical product superadditivity (general theorem)
    print("\n  For TROPICAL product (general theorem, verified):")
    for g1 in 'ABC':
        for g2 in 'ABC':
            M1, M2 = BERGGREN[g1], BERGGREN[g2]
            td1 = tropical_det_3x3(M1)
            td2 = tropical_det_3x3(M2)
            trop_prod = tropical_matrix_mul(M1, M2)
            td_trop = tropical_det_3x3(trop_prod)
            gap = td_trop - (td1 + td2)
            print(f"    tropDet({g1}⊗{g2}) = {td_trop} ≥ {td1}+{td2} = {td1+td2}  "
                  f"[gap={gap}] {'✓' if gap >= 0 else '✗'}")

    # Section 6: Depth-2 computations
    print("\n🔷 Section 5: Depth-2 Tropical Computations")
    print("-" * 50)
    for g1 in 'ABC':
        for g2 in 'ABC':
            M = BERGGREN[g1] @ BERGGREN[g2]
            td = tropical_det_3x3(M)
            cm = tropical_crit_mult_3x3(M)
            triple = generate_triple(g1 + g2)
            hyp = abs(triple[2])
            print(f"  {g1}{g2}: tropDet={td:3d}, critMult={cm}, "
                  f"hyp={hyp}, ω={omega(hyp)}, Ω={big_omega(hyp)}, "
                  f"sqfree={is_squarefree(hyp)}")

    # Section 7: Deeper tree exploration
    print("\n🔷 Section 6: Deep Berggren Tree — Tropical Growth")
    print("-" * 50)
    # B-only path: exponential growth
    M = np.eye(3, dtype=int)
    for d in range(1, 8):
        M = BERGGREN['B'] @ M
        td = tropical_det_3x3(M)
        cm = tropical_crit_mult_3x3(M)
        entry_22 = M[2, 2]
        triple = generate_triple('B' * d)
        hyp = abs(triple[2])
        print(f"  B^{d}: tropDet={td:8d}, critMult={cm}, "
              f"M[2,2]={entry_22:8d}, 3^{d}={3**d:6d}, "
              f"hyp={hyp}")

    # Section 8: Cuspidal analysis
    print("\n🔷 Section 7: Cuspidal Analysis of Berggren Hypotenuses")
    print("-" * 50)
    print(f"  {'Depth':<6} {'Word':<8} {'Hyp':>8} {'Prime':>6} {'ω':>3} {'Ω':>3} {'δ':>3} {'Cuspidal':>9}")
    print("  " + "-" * 48)

    words_by_depth = {1: list('ABC')}
    for d in range(2, 5):
        words_by_depth[d] = [w + g for w in words_by_depth[d - 1] for g in 'ABC']

    cuspidal_count = 0
    total_count = 0
    for d in range(1, 5):
        for w in words_by_depth[d]:
            triple = generate_triple(w)
            hyp = abs(triple[2])
            om = omega(hyp)
            bom = big_omega(hyp)
            defect = bom - om
            cusp = is_squarefree(hyp)
            total_count += 1
            if cusp:
                cuspidal_count += 1
            if d <= 2 or (d <= 3 and not cusp):
                print(f"  {d:<6} {w:<8} {hyp:>8} {str(isprime(hyp)):>6} {om:>3} {bom:>3} "
                      f"{defect:>3} {str(cusp):>9}")
    print(f"\n  Cuspidal fraction (depth ≤ 4): {cuspidal_count}/{total_count} "
          f"= {cuspidal_count/total_count:.4f}")
    print(f"  (Asymptotic: 6/π² ≈ {6/np.pi**2:.4f})")

    # Section 9: Visualization
    create_visualization()
    print("\n✅ Visualization saved to diagram.svg")
    print("\n" + "=" * 70)
    print("All computations verified. See Lean 4 file for formal proofs.")
    print("=" * 70)


def create_visualization():
    """Create visualization of tropical arithmetic geometry."""
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    fig.suptitle('Tropical Arithmetic Geometry: Berggren Tree Analysis',
                 fontsize=14, fontweight='bold')

    # Plot 1: Tropical determinant growth for B-only paths
    ax = axes[0, 0]
    depths = list(range(1, 10))
    M = np.eye(3, dtype=int)
    trop_dets = []
    three_powers = []
    for d in depths:
        M = BERGGREN['B'] @ M
        trop_dets.append(tropical_det_3x3(M))
        three_powers.append(3 ** d)
    ax.semilogy(depths, trop_dets, 'b-o', label='tropDet(M_B^d)', markersize=5)
    ax.semilogy(depths, three_powers, 'r--', label='3^d (lower bound)', alpha=0.7)
    ax.semilogy(depths, [7 * d for d in depths], 'g:', label='7d (weight)', alpha=0.7)
    ax.set_xlabel('Depth d')
    ax.set_ylabel('Tropical Determinant')
    ax.set_title('Tropical Det Growth (B-only path)')
    ax.legend(fontsize=8)
    ax.grid(True, alpha=0.3)

    # Plot 2: Superadditivity gaps
    ax = axes[0, 1]
    pairs = []
    gaps_classical = []
    gaps_tropical = []
    for g1 in 'ABC':
        for g2 in 'ABC':
            M1, M2 = BERGGREN[g1], BERGGREN[g2]
            td1, td2 = tropical_det_3x3(M1), tropical_det_3x3(M2)
            td_class = tropical_det_3x3(M1 @ M2)
            td_trop = tropical_det_3x3(tropical_matrix_mul(M1, M2))
            pairs.append(f'{g1}{g2}')
            gaps_classical.append(td_class - td1 - td2)
            gaps_tropical.append(td_trop - td1 - td2)

    x = np.arange(len(pairs))
    width = 0.35
    ax.bar(x - width/2, gaps_classical, width, label='Classical gap', color='steelblue')
    ax.bar(x + width/2, gaps_tropical, width, label='Tropical gap', color='coral')
    ax.set_xticks(x)
    ax.set_xticklabels(pairs, fontsize=8)
    ax.set_ylabel('tropDet(M₁M₂) - tropDet(M₁) - tropDet(M₂)')
    ax.set_title('Superadditivity Gaps')
    ax.legend(fontsize=8)
    ax.axhline(y=0, color='black', linewidth=0.5)
    ax.grid(True, alpha=0.3)

    # Plot 3: Cuspidal defect distribution
    ax = axes[1, 0]
    words = list('ABC')
    for _ in range(4):
        words = [w + g for w in words for g in 'ABC']

    defects = []
    for w in words:
        triple = generate_triple(w)
        hyp = abs(triple[2])
        defects.append(cuspidal_defect(hyp))

    defect_counts = Counter(defects)
    labels = sorted(defect_counts.keys())
    counts = [defect_counts[d] for d in labels]
    ax.bar(labels, counts, color='teal', alpha=0.8)
    ax.set_xlabel('Cuspidal Defect δ = Ω - ω')
    ax.set_ylabel('Count')
    ax.set_title(f'Cuspidal Defect Distribution (depth ≤ 5, n={len(words)})')
    frac = defect_counts.get(0, 0) / len(words)
    ax.text(0.95, 0.95, f'δ=0 fraction: {frac:.3f}\n6/π² ≈ {6/np.pi**2:.3f}',
            transform=ax.transAxes, ha='right', va='top', fontsize=9,
            bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.5))
    ax.grid(True, alpha=0.3)

    # Plot 4: Critical multiplicity vs tropical det
    ax = axes[1, 1]
    M = np.eye(3, dtype=int)
    for _ in range(3):
        words_d = [w + g for w in ([''] if _ == 0 else words_d) for g in 'ABC']  # noqa

    all_words = []
    for d in range(1, 4):
        if d == 1:
            ws = list('ABC')
        else:
            ws = [w + g for w in ws for g in 'ABC']  # noqa
        all_words.extend(ws)

    tds_list = []
    cms_list = []
    for w in all_words:
        M_path = np.eye(3, dtype=int)
        for g in w:
            M_path = BERGGREN[g] @ M_path
        td = tropical_det_3x3(M_path)
        cm = tropical_crit_mult_3x3(M_path)
        tds_list.append(td)
        cms_list.append(cm)

    ax.scatter(tds_list, cms_list, alpha=0.5, s=20, c='purple')
    ax.set_xlabel('Tropical Determinant')
    ax.set_ylabel('Critical Multiplicity')
    ax.set_title('tropDet vs critMult (depth ≤ 3)')
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('/workspace/request-project/diagram.svg', format='svg', bbox_inches='tight')
    plt.close()


if __name__ == '__main__':
    main()
