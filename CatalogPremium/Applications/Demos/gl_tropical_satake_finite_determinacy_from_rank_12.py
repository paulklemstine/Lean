#!/usr/bin/env python3
"""
GL₃ Tropical Satake Finite Determinacy — Interactive Demo

This script demonstrates the finite-determinacy theorem for the GL₃ tropical
Satake correspondence with concrete numerical examples and visualizations.

The theorem states: functions on GL₃ dominant coweights with bounded support
are uniquely determined by finitely many tropical Satake observables (rank-1
profiles, rank-2 profiles, and edge moments).
"""

import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D
from itertools import product
import matplotlib.patches as mpatches

# ============================================================
# Part 1: Core Definitions
# ============================================================

def dominant_coweights_in_box(B):
    """Generate all dominant coweights (a,b,c) with a ≥ b ≥ c ≥ 0 and a ≤ B."""
    result = []
    for a in range(B + 1):
        for b in range(a + 1):
            for c in range(b + 1):
                result.append((a, b, c))
    return result

def rank1_profile(f, a, b, c):
    """Rank-1 tropical convolution: max of f shifted by weights of ω₁ = std rep.
    Weights: e₁=(1,0,0), e₂=(0,1,0), e₃=(0,0,1).
    rank1Profile(f, a, b, c) = max{f(a-1,b,c), f(a,b-1,c), f(a,b,c-1)}"""
    v1 = f.get((a-1, b, c), 0) if a >= 1 else 0
    v2 = f.get((a, b-1, c), 0) if b >= 1 else 0
    v3 = f.get((a, b, c-1), 0) if c >= 1 else 0
    return max(v1, v2, v3)

def rank2_profile(f, a, b, c):
    """Rank-2 tropical convolution: max of f shifted by weights of ω₂ = ∧².
    Weights: e₁+e₂=(1,1,0), e₁+e₃=(1,0,1), e₂+e₃=(0,1,1).
    rank2Profile(f, a, b, c) = max{f(a-1,b-1,c), f(a-1,b,c-1), f(a,b-1,c-1)}"""
    v1 = f.get((a-1, b-1, c), 0) if a >= 1 and b >= 1 else 0
    v2 = f.get((a-1, b, c-1), 0) if a >= 1 and c >= 1 else 0
    v3 = f.get((a, b-1, c-1), 0) if b >= 1 and c >= 1 else 0
    return max(v1, v2, v3)

def edge_moment(f, a, b, c):
    """Edge moment (determinant convolution): shift by ω₃ = (1,1,1).
    edgeMoment(f, a, b, c) = f(a-1, b-1, c-1) when a,b,c ≥ 1."""
    if a >= 1 and b >= 1 and c >= 1:
        return f.get((a-1, b-1, c-1), 0)
    return 0

def triple_conv_observable(f, t, s):
    """Combined triple convolution: rank1 + rank2."""
    return rank1_profile(f, *t) + rank2_profile(f, *s)

# ============================================================
# Part 2: Reconstruction Algorithm
# ============================================================

def reconstruct_from_edge_moments(edge_moment_values, B):
    """Reconstruct a function f from its edge moment values.

    The key identity: edgeMoment(f, a+1, b+1, c+1) = f(a, b, c).
    So f(a,b,c) = edge_moment_values[(a+1, b+1, c+1)].
    """
    reconstructed = {}
    for a, b, c in dominant_coweights_in_box(B):
        key = (a+1, b+1, c+1)
        if key in edge_moment_values:
            reconstructed[(a, b, c)] = edge_moment_values[key]
    return reconstructed

def compute_all_observables(f, B):
    """Compute all tropical Satake observables for f on BoxDom(B)."""
    rank1_data = {}
    rank2_data = {}
    edge_data = {}

    # Compute on extended range (up to B+1)
    for a in range(B + 2):
        for b in range(a + 1):
            for c in range(b + 1):
                rank1_data[(a,b,c)] = rank1_profile(f, a, b, c)
                rank2_data[(a,b,c)] = rank2_profile(f, a, b, c)
                if c >= 1:
                    edge_data[(a,b,c)] = edge_moment(f, a, b, c)

    return rank1_data, rank2_data, edge_data

# ============================================================
# Part 3: Demonstration Examples
# ============================================================

def demo_basic_reconstruction():
    """Demonstrate the reconstruction algorithm for a simple function."""
    B = 3
    print("=" * 70)
    print("DEMO 1: Basic Reconstruction from Edge Moments")
    print("=" * 70)
    print(f"\nBox bound B = {B}")
    print(f"Number of dominant coweights in BoxDom({B}): "
          f"{len(dominant_coweights_in_box(B))}")

    # Define a test function
    f = {
        (0,0,0): 5,
        (1,0,0): -3,
        (1,1,0): 7,
        (1,1,1): 2,
        (2,0,0): 1,
        (2,1,0): -4,
        (2,1,1): 8,
        (2,2,0): 3,
        (2,2,1): -1,
        (2,2,2): 6,
        (3,0,0): 0,
        (3,1,0): -2,
        (3,1,1): 4,
        (3,2,0): -5,
        (3,2,1): 9,
        (3,2,2): -7,
        (3,3,0): 1,
        (3,3,1): 3,
        (3,3,2): -6,
        (3,3,3): 10,
    }

    print("\nOriginal function f:")
    for key in sorted(f.keys()):
        print(f"  f{key} = {f[key]}")

    # Compute observables
    rank1_data, rank2_data, edge_data = compute_all_observables(f, B)

    print(f"\nNumber of rank-1 test points: {len(rank1_data)}")
    print(f"Number of rank-2 test points: {len(rank2_data)}")
    print(f"Number of edge moment test points: {len(edge_data)}")

    # Reconstruct from edge moments
    reconstructed = reconstruct_from_edge_moments(edge_data, B)

    print("\nReconstructed function (from edge moments alone):")
    match = True
    for key in sorted(f.keys()):
        rec_val = reconstructed.get(key, 0)
        status = "✓" if rec_val == f[key] else "✗"
        if rec_val != f[key]:
            match = False
        print(f"  f{key} = {rec_val} {status}")

    print(f"\n{'PERFECT RECONSTRUCTION!' if match else 'RECONSTRUCTION FAILED!'}")
    return match

def demo_rank1_top_level():
    """Demonstrate rank-1 profile at the top level gives exact values."""
    B = 2
    print("\n" + "=" * 70)
    print("DEMO 2: Rank-1 Profile Top-Level Recovery")
    print("=" * 70)
    print(f"\nBox bound B = {B}")

    f = {
        (0,0,0): 3, (1,0,0): -1, (1,1,0): 5, (1,1,1): 2,
        (2,0,0): 4, (2,1,0): -3, (2,1,1): 7, (2,2,0): 1,
        (2,2,1): -2, (2,2,2): 6,
    }

    print("\nRank-1 profile at top level (a = B+1 = 3):")
    print("These should equal f(B=2, b, c) when f(B+1,...) = 0:")
    for b in range(B + 1):
        for c in range(b + 1):
            r1_val = rank1_profile(f, B + 1, b, c)
            f_val = f.get((B, b, c), 0)
            # rank1 at (B+1, b, c) = max{f(B,b,c), 0, 0} since f(B+1,...) = 0
            expected = max(f_val, 0)
            match = "✓" if r1_val == expected else "✗"
            print(f"  rank1Profile(f, {B+1}, {b}, {c}) = {r1_val} "
                  f"= max(f({B},{b},{c})={f_val}, 0) = {expected} {match}")

    print("\nNote: rank-1 profile recovers f(B,b,c) exactly when f(B,b,c) ≥ 0.")
    print("For negative values, the max with 0 causes information loss.")
    print("This is why the determinant convolution (edge moments) is essential!")

def demo_rank2_floor_level():
    """Demonstrate rank-2 profile at c=0 gives exact values."""
    B = 2
    print("\n" + "=" * 70)
    print("DEMO 3: Rank-2 Profile Floor-Level Recovery")
    print("=" * 70)

    f = {
        (0,0,0): 3, (1,0,0): -1, (1,1,0): 5, (1,1,1): 2,
        (2,0,0): 4, (2,1,0): -3, (2,1,1): 7, (2,2,0): 1,
        (2,2,1): -2, (2,2,2): 6,
    }

    print("\nRank-2 profile at floor level (c = 0):")
    print("rank2Profile(f, a+1, b+1, 0) = max(f(a,b,0), 0):")
    for a in range(B + 1):
        for b in range(a + 1):
            r2_val = rank2_profile(f, a + 1, b + 1, 0)
            f_val = f.get((a, b, 0), 0)
            expected = max(f_val, 0)
            match = "✓" if r2_val == expected else "✗"
            print(f"  rank2Profile(f, {a+1}, {b+1}, 0) = {r2_val} "
                  f"= max(f({a},{b},0)={f_val}, 0) = {expected} {match}")

    print("\nThe c=0 case is special: the ω₂-weight shifts involving c-1")
    print("fall outside ℕ, so only the (1,1,0)-weight shift contributes.")

def demo_finite_determinacy():
    """Demonstrate the finite-determinacy theorem with two functions."""
    B = 2
    print("\n" + "=" * 70)
    print("DEMO 4: Finite Determinacy — Two Functions")
    print("=" * 70)

    f = {
        (0,0,0): 3, (1,0,0): -1, (1,1,0): 5, (1,1,1): 2,
        (2,0,0): 4, (2,1,0): -3, (2,1,1): 7, (2,2,0): 1,
        (2,2,1): -2, (2,2,2): 6,
    }

    g = dict(f)  # Start with same function

    print(f"\nf and g agree on all BoxDom({B}) points.")

    # Compute observables
    _, _, edge_f = compute_all_observables(f, B)
    _, _, edge_g = compute_all_observables(g, B)

    edge_match = all(edge_f[k] == edge_g[k] for k in edge_f)
    print(f"Edge moments agree: {edge_match}")
    print("Theorem conclusion: f = g ✓")

    # Now modify g at one point
    print("\n--- Modifying g(2,1,0) from -3 to 10 ---")
    g[(2, 1, 0)] = 10

    _, _, edge_g2 = compute_all_observables(g, B)

    print("\nEdge moments that differ:")
    for k in sorted(edge_f.keys()):
        if k in edge_g2 and edge_f[k] != edge_g2[k]:
            print(f"  edgeMoment at {k}: f → {edge_f[k]}, g → {edge_g2[k]}")

    print("\nThe edge moment at (3,2,1) = f(2,1,0) detects the difference!")

# ============================================================
# Part 4: Visualization
# ============================================================

def visualize_dominant_cone(B):
    """Visualize the dominant cone and the reconstruction structure."""
    fig = plt.figure(figsize=(16, 6))

    # Plot 1: The dominant cone BoxDom(B)
    ax1 = fig.add_subplot(131, projection='3d')
    coweights = dominant_coweights_in_box(B)

    # Color by type: edge, wall, interior
    edges_pts = []
    walls_pts = []
    interior_pts = []

    for a, b, c in coweights:
        is_edge = (b == 0 and c == 0) or (a == b and c == 0) or (a == b == c)
        is_wall = (a == b or b == c) and not is_edge
        if is_edge:
            edges_pts.append((a, b, c))
        elif is_wall:
            walls_pts.append((a, b, c))
        else:
            interior_pts.append((a, b, c))

    if edges_pts:
        xs, ys, zs = zip(*edges_pts)
        ax1.scatter(xs, ys, zs, c='red', s=80, label=f'Edges ({len(edges_pts)})',
                   marker='o', edgecolors='darkred')
    if walls_pts:
        xs, ys, zs = zip(*walls_pts)
        ax1.scatter(xs, ys, zs, c='blue', s=50, label=f'Walls ({len(walls_pts)})',
                   marker='s', edgecolors='darkblue')
    if interior_pts:
        xs, ys, zs = zip(*interior_pts)
        ax1.scatter(xs, ys, zs, c='green', s=50, label=f'Interior ({len(interior_pts)})',
                   marker='^', edgecolors='darkgreen')

    ax1.set_xlabel('a')
    ax1.set_ylabel('b')
    ax1.set_zlabel('c')
    ax1.set_title(f'BoxDom({B}): {len(coweights)} points')
    ax1.legend(fontsize=7, loc='upper left')

    # Plot 2: Edge moment test range
    ax2 = fig.add_subplot(132, projection='3d')
    test_pts = []
    for a in range(B + 2):
        for b in range(1, a + 1):
            for c in range(1, b + 1):
                test_pts.append((a, b, c))

    # Map each test point to the coweight it reconstructs
    recon_pts = [(a-1, b-1, c-1) for a, b, c in test_pts]

    if test_pts:
        xs, ys, zs = zip(*test_pts)
        ax2.scatter(xs, ys, zs, c='purple', s=50, alpha=0.6,
                   label=f'Test points ({len(test_pts)})')
    if recon_pts:
        xs, ys, zs = zip(*recon_pts)
        ax2.scatter(xs, ys, zs, c='orange', s=30, alpha=0.4,
                   label=f'Reconstructed ({len(recon_pts)})')

    # Draw arrows from test to reconstructed
    for tp, rp in list(zip(test_pts, recon_pts))[:15]:
        ax2.plot([tp[0], rp[0]], [tp[1], rp[1]], [tp[2], rp[2]],
                'k-', alpha=0.2, linewidth=0.5)

    ax2.set_xlabel('a')
    ax2.set_ylabel('b')
    ax2.set_zlabel('c')
    ax2.set_title(f'Edge Moment Reconstruction')
    ax2.legend(fontsize=7, loc='upper left')

    # Plot 3: Observable count scaling
    ax3 = fig.add_subplot(133)
    Bs = range(1, 12)
    box_sizes = [len(dominant_coweights_in_box(b)) for b in Bs]
    edge_sizes = [sum(1 for a in range(b+2) for bb in range(1, a+1)
                      for c in range(1, bb+1)) for b in Bs]
    rank1_sizes = [sum(1 for a in range(b+2) for bb in range(a+1)
                       for c in range(bb+1)) for b in Bs]

    ax3.plot(list(Bs), box_sizes, 'go-', label='|BoxDom(B)| ~ B³/6', linewidth=2)
    ax3.plot(list(Bs), edge_sizes, 'r^-', label='Edge moments ~ B³/6', linewidth=2)
    ax3.plot(list(Bs), rank1_sizes, 'bs-', label='Rank-1 tests ~ B³/6', linewidth=2)
    ax3.set_xlabel('Box bound B')
    ax3.set_ylabel('Number of points')
    ax3.set_title('Observable Count Scaling')
    ax3.legend(fontsize=8)
    ax3.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('tropical_satake_visualization.png', dpi=150, bbox_inches='tight')
    print("\nVisualization saved to tropical_satake_visualization.png")
    plt.close()

def visualize_reconstruction_heatmap():
    """Show reconstruction quality as a heatmap."""
    B = 4

    # Random function on BoxDom(B)
    np.random.seed(42)
    coweights = dominant_coweights_in_box(B)
    f = {cw: int(np.random.randint(-10, 11)) for cw in coweights}

    # Compute edge moments and reconstruct
    _, _, edge_data = compute_all_observables(f, B)
    reconstructed = reconstruct_from_edge_moments(edge_data, B)

    # Check reconstruction
    errors = []
    for cw in coweights:
        orig = f[cw]
        recon = reconstructed.get(cw, 0)
        errors.append(abs(orig - recon))

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    # Plot original vs reconstructed
    indices = range(len(coweights))
    orig_vals = [f[cw] for cw in coweights]
    recon_vals = [reconstructed.get(cw, 0) for cw in coweights]

    ax1.bar([i - 0.15 for i in indices], orig_vals, 0.3, label='Original f',
            color='steelblue', alpha=0.8)
    ax1.bar([i + 0.15 for i in indices], recon_vals, 0.3, label='Reconstructed',
            color='coral', alpha=0.8)
    ax1.set_xlabel('Coweight index')
    ax1.set_ylabel('Value')
    ax1.set_title(f'Reconstruction from Edge Moments (B={B})')
    ax1.legend()
    ax1.grid(True, alpha=0.3)

    # Plot error
    ax2.bar(indices, errors, color='green' if max(errors) == 0 else 'red', alpha=0.7)
    ax2.set_xlabel('Coweight index')
    ax2.set_ylabel('|Error|')
    ax2.set_title(f'Reconstruction Error (max = {max(errors)})')
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('tropical_reconstruction_demo.png', dpi=150, bbox_inches='tight')
    print("Reconstruction demo saved to tropical_reconstruction_demo.png")
    plt.close()

# ============================================================
# Part 5: Application — Finite Certification
# ============================================================

def demo_finite_certification():
    """Demonstrate how finite determinacy enables certification."""
    print("\n" + "=" * 70)
    print("DEMO 5: Finite Certification Procedure")
    print("=" * 70)

    B = 3
    print(f"\nSuppose we have a 'black box' function on BoxDom({B}).")
    print("We want to verify it equals a known target function.")
    print("The finite-determinacy theorem says we only need to check")
    print(f"{len(dominant_coweights_in_box(B))} edge moment values.\n")

    # Target function
    target = {cw: (cw[0] + cw[1] + cw[2]) % 7 - 3
              for cw in dominant_coweights_in_box(B)}

    # "Black box" that we're testing (same as target)
    blackbox = dict(target)

    # Certification: check edge moments
    _, _, edge_target = compute_all_observables(target, B)
    _, _, edge_blackbox = compute_all_observables(blackbox, B)

    all_match = True
    for key in sorted(edge_target.keys()):
        if edge_target[key] != edge_blackbox[key]:
            all_match = False
            print(f"  MISMATCH at {key}: target={edge_target[key]}, "
                  f"blackbox={edge_blackbox[key]}")

    if all_match:
        print(f"All {len(edge_target)} edge moments match.")
        print("By the finite-determinacy theorem: blackbox = target ✓")
    else:
        print("Edge moments differ: blackbox ≠ target ✗")

    # Now test with a modified blackbox
    print("\n--- Introducing a single error at (2,1,0) ---")
    blackbox[(2, 1, 0)] = target[(2, 1, 0)] + 1
    _, _, edge_blackbox2 = compute_all_observables(blackbox, B)

    print("Checking edge moments...")
    detected = False
    for key in sorted(edge_target.keys()):
        if edge_target[key] != edge_blackbox2[key]:
            detected = True
            print(f"  DETECTED at {key}: target={edge_target[key]}, "
                  f"blackbox={edge_blackbox2[key]}")

    if detected:
        print("Error detected! The certification procedure caught the difference.")
    else:
        print("Error NOT detected (this should not happen).")

# ============================================================
# Part 6: Information-Theoretic Analysis
# ============================================================

def info_theoretic_analysis():
    """Analyze the information content of different observables."""
    print("\n" + "=" * 70)
    print("DEMO 6: Information-Theoretic Analysis")
    print("=" * 70)

    for B in range(1, 7):
        n_coweights = len(dominant_coweights_in_box(B))

        # Count test points
        n_edge = sum(1 for a in range(B+2) for b in range(1, a+1)
                     for c in range(1, b+1))
        n_rank1 = sum(1 for a in range(B+2) for b in range(a+1)
                      for c in range(b+1))
        n_rank2 = n_rank1  # Same range

        print(f"\nB = {B}:")
        print(f"  |BoxDom({B})| = {n_coweights} (unknowns to determine)")
        print(f"  Edge moments: {n_edge} tests (EXACT reconstruction)")
        print(f"  Rank-1 tests: {n_rank1} (provides max-based constraints)")
        print(f"  Rank-2 tests: {n_rank2} (provides max-based constraints)")
        print(f"  Total tests: {n_edge + n_rank1 + n_rank2}")

        # The edge moments alone suffice (and equal the number of unknowns)
        if n_edge == n_coweights:
            print(f"  → Edge moments = unknowns: minimal separating set!")
        elif n_edge > n_coweights:
            print(f"  → Edge moments > unknowns: overdetermined (redundancy)")

# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print("GL₃ Tropical Satake Finite Determinacy — Demo")
    print("=" * 70)
    print()

    # Run all demos
    demo_basic_reconstruction()
    demo_rank1_top_level()
    demo_rank2_floor_level()
    demo_finite_determinacy()
    demo_finite_certification()
    info_theoretic_analysis()

    # Generate visualizations
    print("\n" + "=" * 70)
    print("Generating visualizations...")
    print("=" * 70)
    try:
        visualize_dominant_cone(4)
        visualize_reconstruction_heatmap()
    except Exception as e:
        print(f"Visualization skipped (matplotlib not available): {e}")

    print("\n" + "=" * 70)
    print("All demos completed successfully!")
    print("=" * 70)
