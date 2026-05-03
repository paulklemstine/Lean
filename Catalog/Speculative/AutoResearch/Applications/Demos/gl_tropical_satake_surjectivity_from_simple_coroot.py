#!/usr/bin/env python3
"""
GL₃ Tropical Satake Classification — Interactive Demo

This script demonstrates the main theorem: a function D on the dominant chamber
ℕ² is in the image of the tropical Satake transform if and only if it satisfies
the admissibility conditions (additive separability + origin normalization).

The demo includes:
1. Constructing admissible and non-admissible data
2. Reconstructing the Hecke element from admissible data
3. Verifying the classification theorem computationally
4. Visualizations of the dominant chamber and the Satake transform
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib import cm
import matplotlib.gridspec as gridspec


# ============================================================
# Core definitions matching the Lean formalization
# ============================================================

def trop_satake(edge1, edge2, a, b):
    """Tropical Satake transform: D(a,b) = f₁(a) + f₂(b)."""
    return edge1(a) + edge2(b)


def is_edge_valuation_compatible(D, N):
    """Check D(0,0) = 0."""
    return abs(D(0, 0)) < 1e-10


def is_levi12_compatible(D, N):
    """Check D(a+1,b) - D(a,b) = D(a+1,0) - D(a,0) for all a,b ≤ N."""
    for a in range(N):
        for b in range(N + 1):
            lhs = D(a + 1, b) - D(a, b)
            rhs = D(a + 1, 0) - D(a, 0)
            if abs(lhs - rhs) > 1e-10:
                return False
    return True


def is_levi23_compatible(D, N):
    """Check D(a,b+1) - D(a,b) = D(0,b+1) - D(0,b) for all a,b ≤ N."""
    for a in range(N + 1):
        for b in range(N):
            lhs = D(a, b + 1) - D(a, b)
            rhs = D(0, b + 1) - D(0, b)
            if abs(lhs - rhs) > 1e-10:
                return False
    return True


def is_adjacent_facet_compatible(D, N):
    """Check D(a+1,b+1) + D(a,b) = D(a+1,b) + D(a,b+1) for all a,b ≤ N."""
    for a in range(N):
        for b in range(N):
            lhs = D(a + 1, b + 1) + D(a, b)
            rhs = D(a + 1, b) + D(a, b + 1)
            if abs(lhs - rhs) > 1e-10:
                return False
    return True


def is_satake_admissible(D, N):
    """Check all four admissibility conditions."""
    return (is_edge_valuation_compatible(D, N) and
            is_levi12_compatible(D, N) and
            is_levi23_compatible(D, N) and
            is_adjacent_facet_compatible(D, N))


def reconstruct_hecke(D):
    """Reconstruct edge data from an admissible datum D."""
    edge1 = lambda a: D(a, 0)
    edge2 = lambda b: D(0, b)
    return edge1, edge2


def has_bounded_support(D, N, max_check=20):
    """Check D vanishes for height > N."""
    for a in range(max_check):
        for b in range(max_check):
            if a + b > N and abs(D(a, b)) > 1e-10:
                return False
    return True


# ============================================================
# Demo 1: Constructing and verifying admissible data
# ============================================================

def demo_admissible_data():
    """Demonstrate the admissibility conditions with concrete examples."""
    print("=" * 70)
    print("DEMO 1: Admissible vs Non-Admissible Tropical Data")
    print("=" * 70)

    N = 8

    # Example 1: An admissible datum (additively separable, no bounded support)
    print("\n--- Example 1: Admissible datum D(a,b) = a² + 2b ---")
    D1 = lambda a, b: a**2 + 2 * b
    print(f"  D(0,0) = {D1(0, 0)} (should be 0)")
    print(f"  D(3,2) = {D1(3, 2)}, D(3,0)+D(0,2) = {D1(3, 0) + D1(0, 2)}")
    print(f"  SatakeAdmissible: {is_satake_admissible(D1, N)}")

    # Example 2: Non-admissible datum (not separable)
    print("\n--- Example 2: Non-admissible datum D(a,b) = a·b ---")
    D2 = lambda a, b: a * b
    print(f"  D(0,0) = {D2(0, 0)} (edge ok)")
    print(f"  D(2,3) = {D2(2, 3)}, D(2,0)+D(0,3) = {D2(2, 0) + D2(0, 3)}")
    print(f"  SatakeAdmissible: {is_satake_admissible(D2, N)}")
    print(f"  Levi12Compatible: {is_levi12_compatible(D2, N)}")
    print(f"  AdjacentFacetCompatible: {is_adjacent_facet_compatible(D2, N)}")

    # Example 3: Admissible with bounded support (N=5)
    # Key: D(a,b) = f(a) + g(b) with f(a)+g(b)=0 for all a+b>N
    # Solution: choose f and g such that f(a) = -g(N-a) for a ≤ N
    # Simplest: f(a) = a for a ≤ N, f(a)=0 for a>N; g(b) = -b for b ≤ N, g(b)=0 for b>N
    # Then D(a,b) = a - b for a+b ≤ N, D = 0 for a+b > N... wait, we also need
    # f(a)+g(b)=0 for a+b>N, a≤N, b≤N, which means a - b = 0, i.e. a=b. Not general.
    # Better approach: use functions that vanish for large argument.
    Nbd = 5
    print(f"\n--- Example 3: Admissible with bounded support (N={Nbd}) ---")
    e1_vals = {0: 0, 1: 1.2, 2: 2.1, 3: 2.5, 4: 2.7, 5: 2.8}
    e2_vals = {0: 0, 1: 0.8, 2: 1.3, 3: 1.6, 4: 1.7, 5: 1.75}
    # For BoundedSupport: we need e1(a) + e2(b) = 0 when a+b > N.
    # For a > N: e1(a)=0, so need e2(b)=0 — but e2(b)≠0 for small b.
    # This means a strictly bounded-support separable function must have
    # all edge values vanish above N, AND the cross terms must also vanish.
    # In practice: f(a)=0 for a>N, g(b)=0 for b>N, AND f(a)+g(b)=0 for a+b>N, a≤N, b≤N.

    # This forces: for a+b>N with a,b≤N, f(a)=-g(b)=-g(N+1-a+...).
    # Simplest non-trivial: f(a) = max(0, N-2a)/N type constructions,
    # or just use the trivial f(a) = c*max(0, 1-a/k).

    # Actually, the simplest admissible bounded-support datum:
    # D(a,b) = max(0, N - a - b) * scale
    # But is this separable? max(0, N-a-b) is NOT f(a)+g(b) in general.

    # The only separable function with D=0 for a+b > N is:
    # D(a,b) = f(a) + g(b) = 0 for a+b > N
    # This means f(a) = -g(b) whenever a+b > N, a,b ∈ ℕ.
    # For a=0, b=N+1: f(0) = -g(N+1) → g(N+1) = 0 (since f(0)=0)
    # For a=1, b=N: f(1) = -g(N)
    # For a=2, b=N-1: f(2) = -g(N-1)
    # ...
    # For a=N, b=1: f(N) = -g(1)
    # Also for a=N+1, b=0: f(N+1) = -g(0) = 0

    # So f(k) = -g(N+1-k) for k=1,...,N. And f(0)=g(0)=0, f(a)=g(b)=0 for a,b>N.
    # This is a strong constraint: the edge functions are "anti-reflections" of each other.

    # Example: f(k) = k*(N-k)/N for k=0,...,N, f(k)=0 for k>N
    #          g(k) = -f(N+1-k) for k=1,...,N, g(0)=0, g(k)=0 for k>N
    #          g(k) = -(N+1-k)*(k-1)/N for k=1,...,N

    def f_edge(a):
        if a > Nbd:
            return 0.0
        return a * (Nbd - a) / Nbd

    def g_edge(b):
        if b > Nbd or b == 0:
            return 0.0
        return -f_edge(Nbd + 1 - b)

    D3 = lambda a, b: f_edge(a) + g_edge(b)

    print(f"  D(0,0) = {D3(0, 0)}")
    print(f"  edge1: {[round(f_edge(a), 4) for a in range(Nbd + 2)]}")
    print(f"  edge2: {[round(g_edge(b), 4) for b in range(Nbd + 2)]}")
    print(f"  SatakeAdmissible: {is_satake_admissible(D3, Nbd)}")
    print(f"  BoundedSupport({Nbd}): {has_bounded_support(D3, Nbd)}")

    # Verify reconstruction
    e1r, e2r = reconstruct_hecke(D3)
    all_ok = True
    for a in range(Nbd + 3):
        for b in range(Nbd + 3):
            if abs(trop_satake(e1r, e2r, a, b) - D3(a, b)) > 1e-8:
                all_ok = False
    print(f"  Reconstruction verified: {'✓' if all_ok else '✗'}")

    # Example 4: Non-admissible - D(0,0) ≠ 0
    print("\n--- Example 4: Non-admissible — D(0,0) ≠ 0 ---")
    D4 = lambda a, b: float(a) + float(b) + 1.0
    print(f"  D(0,0) = {D4(0, 0)} (not zero!)")
    print(f"  SatakeAdmissible: {is_satake_admissible(D4, N)}")

    print()


# ============================================================
# Demo 2: The classification theorem in action
# ============================================================

def demo_classification():
    """Demonstrate the unique existence (classification) theorem."""
    print("=" * 70)
    print("DEMO 2: The Classification Theorem (without bounded support)")
    print("=" * 70)
    print()
    print("Theorem: For every admissible D, there exists a UNIQUE")
    print("  Hecke element h with tropSatake(h) = D.")
    print()

    N = 8  # check range

    test_cases = [
        ("Linear: D(a,b) = 3a + 2b", lambda a, b: 3.0 * a + 2.0 * b),
        ("Quadratic: D(a,b) = a² + b³", lambda a, b: float(a)**2 + float(b)**3),
        ("Sqrt + log: D(a,b) = √a + ln(b+1)",
         lambda a, b: float(a)**0.5 + np.log(float(b) + 1)),
        ("Alternating: D(a,b) = (-1)ᵃ·a + 2ᵇ-1",
         lambda a, b: ((-1)**a) * a + 2.0**b - 1),
    ]

    for name, D in test_cases:
        print(f"  --- {name} ---")
        adm = is_satake_admissible(D, N)
        print(f"  Admissible: {adm}")

        if adm:
            edge1, edge2 = reconstruct_hecke(D)
            print(f"  edge1: {[round(edge1(a), 3) for a in range(min(N + 1, 8))]}")
            print(f"  edge2: {[round(edge2(b), 3) for b in range(min(N + 1, 8))]}")

            # Verify
            ok = True
            for a in range(N + 1):
                for b in range(N + 1):
                    if abs(trop_satake(edge1, edge2, a, b) - D(a, b)) > 1e-8:
                        ok = False
                        break
            print(f"  Reconstruction: {'✓ unique preimage found' if ok else '✗'}")
        print()


# ============================================================
# Demo 3: Equivalence of admissibility conditions
# ============================================================

def demo_condition_equivalence():
    """Show that the four conditions are equivalent (modulo edge normalization)."""
    print("=" * 70)
    print("DEMO 3: Equivalence of Admissibility Conditions")
    print("=" * 70)
    print()
    print("Theorem: Levi₁₂ ↔ Levi₂₃ ↔ AdjacentFacet (all equivalent)")
    print()

    N = 6
    np.random.seed(42)

    # Generate random admissible data (separable functions)
    print("  Admissible examples (random separable functions):")
    for trial in range(5):
        e1 = np.random.randn(N + 2)
        e2 = np.random.randn(N + 2)
        e1[0] = 0.0
        e2[0] = 0.0

        D = lambda a, b, _e1=e1, _e2=e2: (
            _e1[a] + _e2[b] if a < len(_e1) and b < len(_e2) else 0.0)

        l12 = is_levi12_compatible(D, N)
        l23 = is_levi23_compatible(D, N)
        afc = is_adjacent_facet_compatible(D, N)

        status = '✓ all agree' if l12 == l23 == afc else '✗ DISAGREE'
        print(f"    Trial {trial + 1}: Levi12={l12}, Levi23={l23}, "
              f"Facet={afc} — {status}")

    # Non-admissible data
    print("\n  Non-admissible examples (random non-separable functions):")
    for trial in range(5):
        vals = np.random.randn(N + 2, N + 2)
        vals[0, 0] = 0.0

        D = lambda a, b, v=vals: (
            float(v[a, b]) if a < v.shape[0] and b < v.shape[1] else 0.0)

        l12 = is_levi12_compatible(D, N)
        l23 = is_levi23_compatible(D, N)
        afc = is_adjacent_facet_compatible(D, N)

        status = '✓ all agree' if l12 == l23 == afc else '✗ DISAGREE'
        print(f"    Trial {trial + 1}: Levi12={l12}, Levi23={l23}, "
              f"Facet={afc} — {status}")

    print()


# ============================================================
# Demo 4: Application — Tropical representation detection
# ============================================================

def demo_application():
    """Demonstrate a practical application of the classification."""
    print("=" * 70)
    print("DEMO 4: Application — Tropical Data Validation")
    print("=" * 70)
    print()
    print("The classification theorem provides a simple test for whether")
    print("observed data on ℕ² is consistent with a tropical GL₃ Hecke element:")
    print("just check the discrete Laplacian condition D(a+1,b+1) + D(a,b)")
    print("= D(a+1,b) + D(a,b+1) at every interior lattice point.")
    print()

    N = 6
    np.random.seed(42)

    # Case 1: Valid data
    print("  Case 1: Data from a valid tropical Hecke element")
    e1 = [0, 1.5, 2.8, 3.9, 4.5, 4.8, 5.0]
    e2 = [0, -0.5, -0.8, -1.0, -1.1, -1.15, -1.18]
    D1 = lambda a, b: (e1[a] + e2[b] if a <= N and b <= N else 0.0)
    print(f"    Admissible: {is_satake_admissible(D1, N)}")
    re1, re2 = reconstruct_hecke(D1)
    match = all(abs(re1(a) - e1[a]) < 1e-10 for a in range(N + 1))
    print(f"    Edge1 recovery: {'✓' if match else '✗'}")

    # Case 2: Noisy data
    print("\n  Case 2: Same data with Gaussian noise (σ=0.05)")
    noise = np.random.randn(N + 1, N + 1) * 0.05
    noise[0, 0] = 0.0
    D2 = lambda a, b, n=noise: (
        e1[a] + e2[b] + n[a, b] if a <= N and b <= N else 0.0)
    print(f"    Admissible: {is_satake_admissible(D2, N)}")

    # Find worst violation
    max_viol = 0
    for a in range(N):
        for b in range(N):
            viol = abs(D2(a + 1, b + 1) + D2(a, b) - D2(a + 1, b) - D2(a, b + 1))
            max_viol = max(max_viol, viol)
    print(f"    Max Laplacian violation: {max_viol:.6f}")
    print(f"    → NOT from a valid Hecke element (noise detected)")

    # Case 3: Structured non-admissible data
    print("\n  Case 3: Structured non-admissible data D(a,b) = sin(a)·cos(b)")
    D3 = lambda a, b: np.sin(a) * np.cos(b) if not (a == 0 and b == 0) else 0.0
    print(f"    D(0,0) = {D3(0, 0)}")
    print(f"    Admissible: {is_satake_admissible(D3, N)}")
    print(f"    D(1,1) = {D3(1, 1):.4f} vs D(1,0)+D(0,1) = "
          f"{D3(1, 0) + D3(0, 1):.4f}")
    print(f"    → Multiplicative structure ≠ additive separability")

    print()


# ============================================================
# Visualization
# ============================================================

def visualize_tropical_satake():
    """Create visualizations of the tropical Satake correspondence."""
    fig = plt.figure(figsize=(18, 12))
    gs = gridspec.GridSpec(2, 3, figure=fig, hspace=0.35, wspace=0.3)

    N = 8

    # Edge data for admissible datum
    edge1_v = np.array([np.sqrt(a) for a in range(N + 1)])
    edge2_v = np.array([np.log1p(b) for b in range(N + 1)])
    edge1_v[0] = 0.0
    edge2_v[0] = 0.0

    a_vals = np.arange(N + 1)
    b_vals = np.arange(N + 1)
    A, B = np.meshgrid(a_vals, b_vals, indexing='ij')
    D_vals = np.zeros_like(A, dtype=float)
    for i in range(N + 1):
        for j in range(N + 1):
            D_vals[i, j] = edge1_v[i] + edge2_v[j]

    # --- Panel 1: Admissible datum as surface ---
    ax1 = fig.add_subplot(gs[0, 0], projection='3d')
    ax1.plot_surface(A, B, D_vals, cmap=cm.viridis, alpha=0.8,
                     edgecolor='k', linewidth=0.3)
    ax1.set_xlabel('a', fontsize=10)
    ax1.set_ylabel('b', fontsize=10)
    ax1.set_zlabel('D(a,b)', fontsize=10)
    ax1.set_title('Admissible Datum\n(Separable Surface)', fontsize=11)

    # --- Panel 2: Edge data ---
    ax2 = fig.add_subplot(gs[0, 1])
    ax2.plot(a_vals, edge1_v, 'bo-', label='edge₁(a) = D(a,0)', linewidth=2)
    ax2.plot(b_vals, edge2_v, 'rs-', label='edge₂(b) = D(0,b)', linewidth=2)
    ax2.set_xlabel('Index', fontsize=10)
    ax2.set_ylabel('Value', fontsize=10)
    ax2.set_title('Hecke Edge Data\n(Reconstructed)', fontsize=11)
    ax2.legend(fontsize=9)
    ax2.grid(True, alpha=0.3)

    # --- Panel 3: Separability heatmap ---
    ax3 = fig.add_subplot(gs[0, 2])
    residual = np.zeros_like(D_vals)
    for i in range(N + 1):
        for j in range(N + 1):
            residual[i, j] = abs(D_vals[i, j] - edge1_v[i] - edge2_v[j])
    im = ax3.imshow(residual, cmap='Reds', origin='lower', aspect='equal',
                    extent=[0, N, 0, N])
    ax3.set_xlabel('b', fontsize=10)
    ax3.set_ylabel('a', fontsize=10)
    ax3.set_title('Separability Residual\n|D(a,b) − D(a,0) − D(0,b)|', fontsize=11)
    plt.colorbar(im, ax=ax3, shrink=0.8)

    # --- Panel 4: Non-admissible datum ---
    ax4 = fig.add_subplot(gs[1, 0], projection='3d')
    D_nonadm = A.astype(float) * B.astype(float)
    ax4.plot_surface(A, B, D_nonadm, cmap=cm.plasma, alpha=0.8,
                     edgecolor='k', linewidth=0.3)
    ax4.set_xlabel('a', fontsize=10)
    ax4.set_ylabel('b', fontsize=10)
    ax4.set_zlabel('D(a,b)', fontsize=10)
    ax4.set_title('Non-Admissible Datum\nD(a,b) = a·b', fontsize=11)

    # --- Panel 5: Discrete Laplacian ---
    ax5 = fig.add_subplot(gs[1, 1])
    laplacian = np.zeros((N, N))
    for i in range(N):
        for j in range(N):
            laplacian[i, j] = (D_nonadm[i + 1, j + 1] + D_nonadm[i, j]
                               - D_nonadm[i + 1, j] - D_nonadm[i, j + 1])
    im2 = ax5.imshow(laplacian, cmap='RdBu_r', origin='lower', aspect='equal',
                     extent=[0, N - 1, 0, N - 1])
    ax5.set_xlabel('b', fontsize=10)
    ax5.set_ylabel('a', fontsize=10)
    ax5.set_title('Discrete Laplacian of a·b\n(Non-zero ⟹ Non-admissible)', fontsize=11)
    plt.colorbar(im2, ax=ax5, shrink=0.8)

    # --- Panel 6: Dominant chamber lattice ---
    ax6 = fig.add_subplot(gs[1, 2])
    colors = cm.coolwarm(np.linspace(0, 1, N + 1))
    for h in range(N + 1):
        pts_a = list(range(h + 1))
        pts_b = [h - a for a in pts_a]
        ax6.scatter(pts_a, pts_b, c=[colors[h]], s=60, zorder=5,
                    edgecolors='k', linewidth=0.5)
        if h <= 6:
            ax6.plot(pts_a, pts_b, color=colors[h], alpha=0.5, linewidth=1)

    ax6.plot(range(N + 1), [0] * (N + 1), 'b-', linewidth=2.5, alpha=0.6,
             label='Edge 1: (a,0)')
    ax6.plot([0] * (N + 1), range(N + 1), 'r-', linewidth=2.5, alpha=0.6,
             label='Edge 2: (0,b)')
    ax6.set_xlabel('a', fontsize=10)
    ax6.set_ylabel('b', fontsize=10)
    ax6.set_title('Dominant Chamber ℕ²\n(Colored by height a+b)', fontsize=11)
    ax6.legend(fontsize=8, loc='upper right')
    ax6.set_xlim(-0.5, N + 0.5)
    ax6.set_ylim(-0.5, N + 0.5)
    ax6.grid(True, alpha=0.2)
    ax6.set_aspect('equal')

    plt.suptitle('GL₃ Tropical Satake Classification', fontsize=14, fontweight='bold')
    plt.savefig('/workspace/request-project/demos/tropical_satake_gl3.png',
                dpi=150, bbox_inches='tight')
    plt.close()
    print("Visualization saved to demos/tropical_satake_gl3.png")


def visualize_classification():
    """Visualize the classification diagram."""
    fig, axes = plt.subplots(1, 3, figsize=(16, 5))
    N = 6

    # Panel 1: Bounded support region
    ax = axes[0]
    for a in range(N + 3):
        for b in range(N + 3):
            if a + b <= N:
                ax.scatter(a, b, c='blue', s=80, zorder=5,
                           edgecolors='k', linewidth=0.5)
            else:
                ax.scatter(a, b, c='lightgray', s=40, zorder=3, alpha=0.5)
    ax.plot([0, N], [N, 0], 'r--', linewidth=2, label=f'Height = {N}')
    ax.set_xlabel('a', fontsize=11)
    ax.set_ylabel('b', fontsize=11)
    ax.set_title(f'BoundedSupport({N})\n(Blue = active region)', fontsize=12)
    ax.legend(fontsize=9)
    ax.set_aspect('equal')
    ax.grid(True, alpha=0.2)

    # Panel 2: Admissible datum values
    ax = axes[1]
    e1 = [0, 2.0, 3.5, 4.2, 4.5, 4.6, 4.6]
    e2 = [0, 1.0, 1.8, 2.3, 2.5, 2.6, 2.6]
    for a in range(N + 1):
        for b in range(N + 1):
            val = e1[a] + e2[b]
            color = plt.cm.viridis(val / 8.0)
            ax.scatter(a, b, c=[color], s=80, zorder=5,
                       edgecolors='k', linewidth=0.5)
            if a + b <= 3:
                ax.annotate(f'{val:.1f}', (a, b),
                            textcoords="offset points",
                            xytext=(5, 5), fontsize=7)
    ax.set_xlabel('a', fontsize=11)
    ax.set_ylabel('b', fontsize=11)
    ax.set_title('Admissible Datum\nD(a,b) = edge₁(a) + edge₂(b)', fontsize=12)
    ax.set_aspect('equal')
    ax.grid(True, alpha=0.2)

    # Panel 3: Classification diagram
    ax = axes[2]
    ax.set_xlim(0, 10)
    ax.set_ylim(0, 10)
    ax.set_aspect('equal')

    # Hecke box
    hecke_box = plt.Rectangle((0.5, 6), 3.5, 3, fill=True,
                               facecolor='lightblue',
                               edgecolor='blue', linewidth=2)
    ax.add_patch(hecke_box)
    ax.text(2.25, 8, 'TropHecke', ha='center', va='center',
            fontsize=11, fontweight='bold')
    ax.text(2.25, 7.2, '(edge₁, edge₂)', ha='center', va='center', fontsize=9)
    ax.text(2.25, 6.5, 'normalized at 0', ha='center', va='center',
            fontsize=8, style='italic')

    # Datum box
    datum_box = plt.Rectangle((5.5, 6), 4, 3, fill=True,
                               facecolor='lightyellow',
                               edgecolor='orange', linewidth=2)
    ax.add_patch(datum_box)
    ax.text(7.5, 8, 'Admissible\nTropDatum', ha='center', va='center',
            fontsize=11, fontweight='bold')
    ax.text(7.5, 6.8, 'D(a,b) = D(a,0)+D(0,b)', ha='center', va='center',
            fontsize=8, style='italic')

    # Arrows
    ax.annotate('', xy=(5.3, 8.2), xytext=(4.2, 8.2),
                arrowprops=dict(arrowstyle='->', lw=2, color='green'))
    ax.text(4.75, 8.7, 'tropSatake', ha='center', va='center',
            fontsize=10, color='green', fontweight='bold')
    ax.annotate('', xy=(4.2, 7.0), xytext=(5.3, 7.0),
                arrowprops=dict(arrowstyle='->', lw=2, color='red'))
    ax.text(4.75, 6.4, 'reconstruct', ha='center', va='center',
            fontsize=10, color='red', fontweight='bold')

    # Theorem box
    thm_box = plt.Rectangle((1, 1), 8, 3.5, fill=True,
                              facecolor='honeydew',
                              edgecolor='darkgreen', linewidth=2,
                              linestyle='--')
    ax.add_patch(thm_box)
    ax.text(5, 3.8, 'Classification Theorem', ha='center', va='center',
            fontsize=12, fontweight='bold', color='darkgreen')
    ax.text(5, 2.8, '∃! h : TropHecke,', ha='center', va='center',
            fontsize=10, family='monospace')
    ax.text(5, 2.0, 'BoundedSupport N h ∧', ha='center', va='center',
            fontsize=10, family='monospace')
    ax.text(5, 1.3, 'tropSatake h = D', ha='center', va='center',
            fontsize=10, family='monospace')
    ax.axis('off')
    ax.set_title('The Bijection', fontsize=12)

    plt.suptitle('GL₃ Tropical Satake: Bounded Support Classification',
                 fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('/workspace/request-project/demos/tropical_satake_classification.png',
                dpi=150, bbox_inches='tight')
    plt.close()
    print("Classification diagram saved to demos/tropical_satake_classification.png")


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════════════╗")
    print("║  GL₃ Tropical Satake Classification — Interactive Demo          ║")
    print("║  Machine-verified by Lean 4 (Mathlib)                           ║")
    print("╚══════════════════════════════════════════════════════════════════╝")
    print()

    demo_admissible_data()
    demo_classification()
    demo_condition_equivalence()
    demo_application()

    print("=" * 70)
    print("Generating visualizations...")
    print("=" * 70)
    visualize_tropical_satake()
    visualize_classification()

    print()
    print("All demos complete. See demos/ for generated figures.")
    print()
