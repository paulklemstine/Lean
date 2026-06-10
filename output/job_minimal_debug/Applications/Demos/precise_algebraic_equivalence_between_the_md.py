#!/usr/bin/env python3
"""
MDS–Uncertainty Equivalence: Numerical Demonstrations

Demonstrates the key results:
1. Vandermonde matrices with distinct points are nonsingular
2. MDS property ↔ Uncertainty principle
3. Critical submatrices yield uncertainty violations
4. Behavior over finite fields (GF(p))
"""

import numpy as np
from algorithms import (
    vandermonde_matrix, check_mds, uncertainty_profile,
    find_critical_submatrix, mds_order, GaloisField
)


def demo_vandermonde_nonsingularity():
    """Demonstrate that Vandermonde matrices with distinct points are nonsingular."""
    print("=" * 70)
    print("DEMO 1: Vandermonde Nonsingularity")
    print("=" * 70)

    for n in [3, 4, 5, 6]:
        # Distinct points
        points = list(range(1, n + 1))
        V = vandermonde_matrix([float(p) for p in points])
        det = np.linalg.det(V)
        print(f"\n  n={n}, points={points}")
        print(f"  det(V) = {det:.6f}")
        print(f"  Nonsingular: {abs(det) > 1e-10}")

        # Verify formula: det = ∏_{i<j} (v_j - v_i)
        expected = 1.0
        for i in range(n):
            for j in range(i + 1, n):
                expected *= (points[j] - points[i])
        print(f"  ∏(v_j - v_i) = {expected:.6f}")
        print(f"  Match: {abs(det - expected) < 1e-6}")


def demo_mds_uncertainty_equivalence():
    """Demonstrate MDS ↔ Uncertainty for various matrices."""
    print("\n" + "=" * 70)
    print("DEMO 2: MDS–Uncertainty Equivalence")
    print("=" * 70)

    # Example 1: 3×3 Vandermonde with points 1, 2, 3 (should be MDS over ℝ)
    print("\n--- 3×3 Vandermonde (points 1, 2, 3) ---")
    V = vandermonde_matrix([1.0, 2.0, 3.0])
    print(f"  V = \n{V}")
    is_mds, info = check_mds(V)
    print(f"  Is MDS: {is_mds}")
    profile = uncertainty_profile(V, num_random=5000)
    print(f"  Min uncertainty: {profile['min_uncertainty']} (need ≥ {profile['n_plus_1']})")
    print(f"  Satisfies UP: {profile['satisfies_up']}")

    # Example 2: Identity matrix (MDS)
    print("\n--- 4×4 Identity matrix ---")
    I4 = np.eye(4)
    is_mds, info = check_mds(I4)
    print(f"  Is MDS: {is_mds}")
    if not is_mds:
        print(f"  First singular submatrix: k={info[0]}, rows={info[1]}, cols={info[2]}")

    # Example 3: Matrix with zero entry (not MDS)
    print("\n--- 3×3 matrix with zero entry ---")
    M = np.array([[1, 2, 3], [4, 0, 6], [7, 8, 9]], dtype=float)
    print(f"  M = \n{M}")
    is_mds, info = check_mds(M)
    print(f"  Is MDS: {is_mds}")
    if not is_mds:
        print(f"  First singular submatrix: k={info[0]}, rows={info[1]}, cols={info[2]}")
        crit = find_critical_submatrix(M)
        if crit:
            print(f"  Uncertainty-violating vector f: {crit['f']}")
            print(f"  |supp(f)| = {crit['supp_f']}, |supp(Mf)| = {crit['supp_Mf']}")
            print(f"  Total = {crit['uncertainty']} ≤ n = {M.shape[0]}")


def demo_critical_submatrix():
    """Demonstrate the critical submatrix → uncertainty violation construction."""
    print("\n" + "=" * 70)
    print("DEMO 3: Critical Submatrix Construction")
    print("=" * 70)

    # Singular matrix
    M = np.array([
        [1, 1, 1, 1],
        [1, 2, 4, 8],
        [1, 3, 9, 27],
        [1, 4, 16, 64]
    ], dtype=float)
    # This is Vandermonde with points 1,2,3,4 — should be MDS

    print("\n--- Vandermonde(1,2,3,4) ---")
    is_mds, _ = check_mds(M)
    print(f"  Is MDS: {is_mds}")
    print(f"  MDS order: {mds_order(M)}")

    # Now corrupt an entry to break MDS
    M_bad = M.copy()
    M_bad[1, 2] = 0  # Zero out entry
    print("\n--- Corrupted Vandermonde ---")
    print(f"  M = \n{M_bad}")
    is_mds, info = check_mds(M_bad)
    print(f"  Is MDS: {is_mds}")
    print(f"  MDS order: {mds_order(M_bad)}")

    crit = find_critical_submatrix(M_bad)
    if crit:
        print(f"  Critical submatrix: k={crit['k']}, rows={crit['rows']}, cols={crit['cols']}")
        print(f"  Uncertainty-violating vector:")
        print(f"    f = {crit['f']}")
        print(f"    Mf = {crit['Mf']}")
        print(f"    |supp(f)| + |supp(Mf)| = {crit['uncertainty']} ≤ n = {M_bad.shape[0]}")


def demo_finite_field():
    """Demonstrate MDS behavior over finite fields."""
    print("\n" + "=" * 70)
    print("DEMO 4: Finite Field MDS Analysis")
    print("=" * 70)

    for p in [5, 7, 11, 13]:
        gf = GaloisField(p)
        print(f"\n--- GF({p}) ---")

        for n in range(2, min(p, 7)):
            points = list(range(1, n + 1))  # nonzero distinct points
            V = gf.vandermonde(points)
            is_mds, info = gf.check_mds(V)
            status = "MDS ✓" if is_mds else f"NOT MDS (fails at k={info[0]})"
            print(f"  n={n}, points={points}: {status}")


def demo_uncertainty_spectrum():
    """Show the full uncertainty spectrum for specific matrices."""
    print("\n" + "=" * 70)
    print("DEMO 5: Uncertainty Spectrum")
    print("=" * 70)

    n = 4
    V = vandermonde_matrix([1.0, 2.0, 3.0, 4.0])
    profile = uncertainty_profile(V, num_random=50000)

    print(f"\n  Vandermonde(1,2,3,4), n={n}")
    print(f"  Vectors tested: {profile['num_tested']}")
    print(f"  Min |supp(f)| + |supp(Mf)|: {profile['min_uncertainty']}")
    print(f"  Max |supp(f)| + |supp(Mf)|: {profile['max_uncertainty']}")
    print(f"  Mean: {profile['mean_uncertainty']:.2f}")
    print(f"  n + 1 = {profile['n_plus_1']}")
    print(f"  Satisfies UP: {profile['satisfies_up']}")


def demo_mds_conjecture_test():
    """Test the MDS conjecture: for which (n, q) is Vandermonde MDS over GF(q)?"""
    print("\n" + "=" * 70)
    print("DEMO 6: MDS Conjecture — When is Vandermonde MDS over GF(q)?")
    print("=" * 70)
    print()
    print("  Testing: V(1,2,...,n) over GF(p) for various p, n")
    print()

    primes = [5, 7, 11, 13, 17, 19, 23, 29, 31]
    header = 'n\\p'
    print(f"  {header:>4}", end="")
    for p in primes:
        print(f"  {p:>3}", end="")
    print()
    print("  " + "-" * (4 + 5 * len(primes)))

    for n in range(2, 10):
        print(f"  {n:>4}", end="")
        for p in primes:
            if n >= p:
                print(f"  {'---':>3}", end="")
                continue
            gf = GaloisField(p)
            points = list(range(1, n + 1))
            V = gf.vandermonde(points)
            is_mds, _ = gf.check_mds(V)
            print(f"  {'✓':>3}" if is_mds else f"  {'✗':>3}", end="")
        print()

    print()
    print("  Legend: ✓ = MDS, ✗ = not MDS, --- = n ≥ p (insufficient distinct points)")
    print()
    print("  Conjecture: V(1,...,n) is MDS over GF(p) when p ≥ 2n - 1")
    print("  (i.e., the field is large enough relative to the matrix size)")


if __name__ == "__main__":
    demo_vandermonde_nonsingularity()
    demo_mds_uncertainty_equivalence()
    demo_critical_submatrix()
    demo_finite_field()
    demo_uncertainty_spectrum()
    demo_mds_conjecture_test()

    print("\n" + "=" * 70)
    print("All demonstrations complete.")
    print("=" * 70)


#!/usr/bin/env python3
"""
Visualization: Uncertainty Principle Heatmap

Shows |supp(f)| vs |supp(Mf)| for a Vandermonde matrix,
illustrating the forbidden region below the uncertainty bound.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from algorithms import vandermonde_matrix


def main():
    n = 5
    V = vandermonde_matrix([1.0, 2.0, 3.0, 4.0, 5.0])
    tol = 1e-10

    # Sample many vectors
    rng = np.random.default_rng(42)
    counts = np.zeros((n + 1, n + 1), dtype=int)

    # Sparse vectors of each sparsity
    for sparsity in range(1, n + 1):
        for _ in range(20000):
            v = np.zeros(n)
            idx = rng.choice(n, size=sparsity, replace=False)
            v[idx] = rng.standard_normal(sparsity)
            sf = int(np.sum(np.abs(v) > tol))
            smf = int(np.sum(np.abs(V @ v) > tol))
            counts[sf, smf] += 1

    # Dense random vectors
    for _ in range(50000):
        v = rng.standard_normal(n)
        sf = int(np.sum(np.abs(v) > tol))
        smf = int(np.sum(np.abs(V @ v) > tol))
        counts[sf, smf] += 1

    fig, ax = plt.subplots(1, 1, figsize=(8, 7))

    # Plot heatmap
    log_counts = np.log10(counts + 1)
    im = ax.imshow(log_counts, origin='lower', cmap='YlOrRd',
                   extent=[-0.5, n + 0.5, -0.5, n + 0.5],
                   aspect='equal')

    # Draw the uncertainty bound line
    xs = np.linspace(0, n, 100)
    ys = n + 1 - xs
    ax.plot(xs, ys, 'b--', linewidth=2, label=f'|supp(f)| + |supp(Mf)| = {n+1}')

    # Shade the forbidden region
    ax.fill_between(xs, 0, np.maximum(ys, 0), alpha=0.15, color='blue',
                    label='Forbidden region (UP violation)')

    ax.set_xlabel('|supp(Mf)|', fontsize=13)
    ax.set_ylabel('|supp(f)|', fontsize=13)
    ax.set_title(f'Uncertainty Profile: Vandermonde(1,...,{n})\n'
                 f'MDS ⟹ |supp(f)| + |supp(Mf)| ≥ {n+1}', fontsize=14)
    ax.set_xlim(0.5, n + 0.5)
    ax.set_ylim(0.5, n + 0.5)
    ax.set_xticks(range(1, n + 1))
    ax.set_yticks(range(1, n + 1))
    ax.legend(loc='upper right', fontsize=11)

    cbar = plt.colorbar(im, ax=ax, label='log₁₀(count + 1)')

    plt.tight_layout()
    plt.savefig('uncertainty_heatmap.png', dpi=150)
    print("Saved uncertainty_heatmap.png")


if __name__ == "__main__":
    main()
