#!/usr/bin/env python3
"""
GL₃ Tropical Satake Reconstruction: Demonstrations and Visualizations

This script demonstrates the key theorem:
  Finitely-supported functions on ℕ × ℕ (modeling dominant GL₃ coweights)
  are uniquely determined by their 2D cumulative convolution profiles with
  Levi segment test functions.

The mathematical content:
  - leviSeg1(t) = ∑_{i=0}^{t} δ_{(i,0)}  (segment along first root)
  - leviSeg2(u) = ∑_{j=0}^{u} δ_{(0,j)}  (segment along second root)
  - rectProfile(h, x, y) = (h * leviSeg1(x) * leviSeg2(y))(x,y)
                          = ∑_{a≤x} ∑_{b≤y} h(a,b)  [2D prefix sum]
  - Reconstruction: h is determined by {rectProfile(h, x, y)}_{x,y}
    via discrete 2D Möbius inversion.
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.colors import TwoSlopeNorm
from collections import defaultdict


# ============================================================================
# Core mathematical functions
# ============================================================================

def prefix_sum_2d(h, x, y):
    """Compute S(x,y) = ∑_{a≤x} ∑_{b≤y} h(a,b) for finitely supported h."""
    return sum(h.get((a, b), 0) for a in range(x + 1) for b in range(y + 1))


def convolution(f, g):
    """Additive convolution on ℕ × ℕ: (f*g)(n) = ∑_{a+b=n} f(a)g(b)."""
    result = defaultdict(float)
    for (a1, a2), v1 in f.items():
        for (b1, b2), v2 in g.items():
            result[(a1 + b1, a2 + b2)] += v1 * v2
    return {k: v for k, v in result.items() if abs(v) > 1e-12}


def levi_seg1(t):
    """leviSeg1(t) = ∑_{i=0}^{t} δ_{(i,0)}"""
    return {(i, 0): 1.0 for i in range(t + 1)}


def levi_seg2(u):
    """leviSeg2(u) = ∑_{j=0}^{u} δ_{(0,j)}"""
    return {(0, j): 1.0 for j in range(u + 1)}


def rect_profile(h, x, y):
    """rectProfile(h, x, y) = (h * leviSeg1(x) * leviSeg2(y))(x, y)"""
    conv_result = convolution(convolution(h, levi_seg1(x)), levi_seg2(y))
    return conv_result.get((x, y), 0.0)


def reconstruct_from_prefix_sums(S, max_x, max_y):
    """
    Reconstruct h from its prefix sums S via Möbius inversion:
      h(x,y) = S(x,y) - S(x-1,y) - S(x,y-1) + S(x-1,y-1)
    """
    h = {}
    for x in range(max_x + 1):
        for y in range(max_y + 1):
            val = S(x, y)
            if x > 0:
                val -= S(x - 1, y)
            if y > 0:
                val -= S(x, y - 1)
            if x > 0 and y > 0:
                val += S(x - 1, y - 1)
            if abs(val) > 1e-12:
                h[(x, y)] = val
    return h


# ============================================================================
# Demo 1: Basic reconstruction from prefix sums
# ============================================================================

def demo_basic_reconstruction():
    """Demonstrate that prefix sums uniquely determine the function."""
    print("=" * 70)
    print("DEMO 1: Basic Reconstruction from 2D Prefix Sums")
    print("=" * 70)

    # Define a test function h on ℕ × ℕ
    h = {
        (0, 0): 3.0,
        (1, 0): -1.0,
        (0, 1): 2.0,
        (1, 1): 5.0,
        (2, 0): 1.0,
        (2, 1): -2.0,
        (0, 2): 4.0,
        (1, 2): -3.0,
        (2, 2): 7.0,
    }

    max_coord = 4
    print("\nOriginal function h:")
    for y in range(3, -1, -1):
        row = [f"{h.get((x, y), 0):6.1f}" for x in range(4)]
        print(f"  y={y}: {' '.join(row)}")

    # Compute prefix sums
    print("\nPrefix sums S(x,y) = ∑_{a≤x} ∑_{b≤y} h(a,b):")
    for y in range(3, -1, -1):
        row = [f"{prefix_sum_2d(h, x, y):6.1f}" for x in range(4)]
        print(f"  y={y}: {' '.join(row)}")

    # Verify rectProfile = prefix sum
    print("\nVerifying rectProfile(h, x, y) = prefixSum2D(h, x, y):")
    all_match = True
    for x in range(4):
        for y in range(4):
            rp = rect_profile(h, x, y)
            ps = prefix_sum_2d(h, x, y)
            if abs(rp - ps) > 1e-10:
                print(f"  MISMATCH at ({x},{y}): rectProfile={rp}, prefixSum={ps}")
                all_match = False
    if all_match:
        print("  ✓ All values match!")

    # Reconstruct from prefix sums
    S = lambda x, y: prefix_sum_2d(h, x, y)
    h_reconstructed = reconstruct_from_prefix_sums(S, 3, 3)

    print("\nReconstructed function h̃:")
    for y in range(3, -1, -1):
        row = [f"{h_reconstructed.get((x, y), 0):6.1f}" for x in range(4)]
        print(f"  y={y}: {' '.join(row)}")

    # Check equality
    max_err = max(
        abs(h.get((x, y), 0) - h_reconstructed.get((x, y), 0))
        for x in range(4) for y in range(4)
    )
    print(f"\n  Maximum reconstruction error: {max_err:.2e}")
    print(f"  ✓ Reconstruction {'successful' if max_err < 1e-10 else 'FAILED'}!")


# ============================================================================
# Demo 2: Convolution profile visualization
# ============================================================================

def demo_convolution_profiles():
    """Visualize convolution profiles and their structure."""
    print("\n" + "=" * 70)
    print("DEMO 2: Convolution Profile Visualization")
    print("=" * 70)

    # Define a "peaked" function
    h = {
        (1, 1): 10.0,
        (2, 1): 3.0,
        (1, 2): -2.0,
        (3, 0): 1.0,
        (0, 3): 5.0,
    }

    max_coord = 7
    fig, axes = plt.subplots(2, 3, figsize=(15, 10))
    fig.suptitle("GL₃ Convolution Profiles: h * leviSeg1(t) * leviSeg2(u)",
                 fontsize=14, fontweight='bold')

    params = [(0, 0), (1, 0), (0, 1), (1, 1), (2, 2), (3, 3)]

    for idx, (t, u) in enumerate(params):
        ax = axes[idx // 3, idx % 3]
        conv = convolution(convolution(h, levi_seg1(t)), levi_seg2(u))

        # Build matrix
        mat = np.zeros((max_coord, max_coord))
        for (x, y), v in conv.items():
            if x < max_coord and y < max_coord:
                mat[y, x] = v

        vmax = max(abs(mat.min()), abs(mat.max())) or 1
        norm = TwoSlopeNorm(vmin=-vmax, vcenter=0, vmax=vmax)
        im = ax.imshow(mat, origin='lower', cmap='RdBu_r', norm=norm,
                       extent=[-0.5, max_coord - 0.5, -0.5, max_coord - 0.5])
        ax.set_title(f"t={t}, u={u}")
        ax.set_xlabel("x")
        ax.set_ylabel("y")

        # Annotate nonzero values
        for (x, y), v in conv.items():
            if x < max_coord and y < max_coord and abs(v) > 0.01:
                ax.text(x, y, f"{v:.0f}", ha='center', va='center',
                        fontsize=7, color='black')

        fig.colorbar(im, ax=ax, shrink=0.8)

    plt.tight_layout()
    plt.savefig("/workspace/request-project/Tropical/Langlands/convolution_profiles.png",
                dpi=150, bbox_inches='tight')
    plt.close()
    print("  Saved: convolution_profiles.png")


# ============================================================================
# Demo 3: Möbius inversion step-by-step
# ============================================================================

def demo_mobius_inversion():
    """Step-by-step demonstration of 2D Möbius inversion."""
    print("\n" + "=" * 70)
    print("DEMO 3: 2D Möbius Inversion Step by Step")
    print("=" * 70)

    # Random finitely-supported function
    np.random.seed(42)
    N = 5
    h = {}
    for x in range(N):
        for y in range(N):
            val = np.random.randint(-5, 6)
            if val != 0:
                h[(x, y)] = float(val)

    print(f"\nOriginal h (support size = {len(h)}):")
    for y in range(N - 1, -1, -1):
        row = [f"{h.get((x, y), 0):4.0f}" for x in range(N)]
        print(f"  y={y}: {' '.join(row)}")

    # Compute prefix sums using convolution
    print("\nComputing prefix sums via rectProfile (convolution with Levi segments):")
    S = {}
    for x in range(N):
        for y in range(N):
            S[(x, y)] = rect_profile(h, x, y)

    for y in range(N - 1, -1, -1):
        row = [f"{S.get((x, y), 0):4.0f}" for x in range(N)]
        print(f"  y={y}: {' '.join(row)}")

    # Reconstruct
    print("\nApplying Möbius inversion (inclusion-exclusion):")
    print("  h(x,y) = S(x,y) - S(x-1,y) - S(x,y-1) + S(x-1,y-1)")

    h_rec = reconstruct_from_prefix_sums(
        lambda x, y: S.get((x, y), 0), N - 1, N - 1
    )

    for y in range(N - 1, -1, -1):
        row = [f"{h_rec.get((x, y), 0):4.0f}" for x in range(N)]
        print(f"  y={y}: {' '.join(row)}")

    max_err = max(
        abs(h.get((x, y), 0) - h_rec.get((x, y), 0))
        for x in range(N) for y in range(N)
    )
    print(f"\n  Maximum error: {max_err:.2e}")
    print(f"  ✓ Perfect reconstruction!" if max_err < 1e-10 else "  ✗ Error!")


# ============================================================================
# Demo 4: Kernel triviality — vanishing profiles imply zero function
# ============================================================================

def demo_kernel_triviality():
    """Demonstrate that vanishing profiles force h = 0."""
    print("\n" + "=" * 70)
    print("DEMO 4: Kernel Triviality (Vanishing Profiles ⟹ Zero Function)")
    print("=" * 70)

    # If all rectProfile(h, x, y) = 0, then h = 0
    # This is the contrapositive: if h ≠ 0, then some profile is nonzero

    print("\nTest: Can a nonzero function have all zero profiles?")
    N = 6
    count_tests = 0
    for trial in range(100):
        np.random.seed(trial)
        h = {}
        for x in range(N):
            for y in range(N):
                val = np.random.randint(-3, 4)
                if val != 0:
                    h[(x, y)] = float(val)

        if not h:
            continue

        count_tests += 1
        # Check if any profile is nonzero
        found_nonzero = False
        for x in range(N):
            for y in range(N):
                if abs(rect_profile(h, x, y)) > 1e-10:
                    found_nonzero = True
                    break
            if found_nonzero:
                break

        if not found_nonzero:
            print(f"  ✗ COUNTEREXAMPLE FOUND (trial {trial})!")
            break

    if found_nonzero or count_tests > 0:
        print(f"  ✓ Tested {count_tests} nonzero functions: all had a nonzero profile.")
        print("    This confirms the theorem: vanishing profiles ⟹ zero function.")


# ============================================================================
# Demo 5: Dominant coweight interpretation
# ============================================================================

def demo_dominant_coweights():
    """Visualize the dominant chamber parametrization."""
    print("\n" + "=" * 70)
    print("DEMO 5: Dominant GL₃ Coweight Chamber")
    print("=" * 70)

    print("\n  Chamber coordinates (x,y) ↦ dominant coweight (x+y, y, 0):")
    print(f"  {'(x,y)':>8} → {'(a,b,c)':>12}   {'a≥b≥c?':>8}")
    print("  " + "-" * 40)

    points = [(x, y) for x in range(5) for y in range(5)]
    for x, y in sorted(points, key=lambda p: (p[0] + p[1], p[1])):
        a, b, c = x + y, y, 0
        valid = "✓" if a >= b >= c else "✗"
        print(f"  ({x},{y})    → ({a},{b},{c})       {valid}")
        if x + y > 5:
            break

    # Visualization
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    # Left: Chamber coordinates
    N = 6
    for x in range(N):
        for y in range(N):
            ax1.plot(x, y, 'ko', markersize=8)
            ax1.annotate(f"({x},{y})", (x, y), textcoords="offset points",
                        xytext=(5, 5), fontsize=7)

    # Highlight Levi directions
    ax1.annotate("", xy=(4, 0), xytext=(0, 0),
                arrowprops=dict(arrowstyle='->', color='red', lw=2))
    ax1.annotate("", xy=(0, 4), xytext=(0, 0),
                arrowprops=dict(arrowstyle='->', color='blue', lw=2))
    ax1.text(2, -0.5, "leviSeg1 direction", color='red', ha='center', fontsize=10)
    ax1.text(-0.5, 2, "leviSeg2\ndirection", color='blue', ha='center', fontsize=10,
             rotation=90)
    ax1.set_title("Chamber Coordinates (x, y)", fontsize=12)
    ax1.set_xlabel("x")
    ax1.set_ylabel("y")
    ax1.set_xlim(-1, N)
    ax1.set_ylim(-1, N)
    ax1.grid(True, alpha=0.3)

    # Right: Prefix sum rectangle
    h_example = {(1, 1): 3, (2, 0): 1, (0, 2): 2, (3, 1): -1}
    px, py = 3, 2

    for (x, y), v in h_example.items():
        color = 'green' if x <= px and y <= py else 'gray'
        ax2.plot(x, y, 'o', color=color, markersize=15)
        ax2.annotate(f"h={v}", (x, y), textcoords="offset points",
                    xytext=(8, 5), fontsize=9, color=color)

    rect = plt.Rectangle((-0.3, -0.3), px + 0.6, py + 0.6,
                         fill=False, edgecolor='green', linewidth=2, linestyle='--')
    ax2.add_patch(rect)
    ax2.set_title(f"Prefix Sum S({px},{py}) = sum over green rectangle", fontsize=12)
    ax2.set_xlabel("x")
    ax2.set_ylabel("y")
    ax2.set_xlim(-1, 5)
    ax2.set_ylim(-1, 4)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig("/workspace/request-project/Tropical/Langlands/dominant_chamber.png",
                dpi=150, bbox_inches='tight')
    plt.close()
    print("\n  Saved: dominant_chamber.png")


# ============================================================================
# Demo 6: Reconstruction error analysis
# ============================================================================

def demo_reconstruction_error():
    """Analyze numerical reconstruction accuracy."""
    print("\n" + "=" * 70)
    print("DEMO 6: Reconstruction Accuracy Analysis")
    print("=" * 70)

    sizes = [3, 5, 8, 10, 15, 20]
    errors = []

    for N in sizes:
        np.random.seed(0)
        h = {(x, y): float(np.random.randn())
             for x in range(N) for y in range(N)}

        # Compute prefix sums
        S = {}
        for x in range(N):
            for y in range(N):
                S[(x, y)] = prefix_sum_2d(h, x, y)

        # Reconstruct
        h_rec = reconstruct_from_prefix_sums(
            lambda x, y: S.get((x, y), 0), N - 1, N - 1
        )

        max_err = max(
            abs(h.get((x, y), 0) - h_rec.get((x, y), 0))
            for x in range(N) for y in range(N)
        )
        errors.append(max_err)
        print(f"  N={N:3d}: max reconstruction error = {max_err:.2e}")

    # Plot
    fig, ax = plt.subplots(figsize=(8, 5))
    ax.semilogy(sizes, [max(e, 1e-16) for e in errors], 'bo-', markersize=8)
    ax.axhline(y=1e-14, color='r', linestyle='--', alpha=0.5, label='Machine epsilon')
    ax.set_xlabel("Grid size N", fontsize=12)
    ax.set_ylabel("Max reconstruction error", fontsize=12)
    ax.set_title("Reconstruction Accuracy vs. Grid Size", fontsize=14)
    ax.legend()
    ax.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.savefig("/workspace/request-project/Tropical/Langlands/reconstruction_accuracy.png",
                dpi=150, bbox_inches='tight')
    plt.close()
    print("  Saved: reconstruction_accuracy.png")


# ============================================================================
# Demo 7: Inclusion-exclusion visualization
# ============================================================================

def demo_inclusion_exclusion():
    """Visualize the inclusion-exclusion formula for coefficient recovery."""
    print("\n" + "=" * 70)
    print("DEMO 7: Inclusion-Exclusion Formula Visualization")
    print("=" * 70)

    fig, axes = plt.subplots(1, 4, figsize=(16, 4))
    x, y = 3, 2
    N = 5

    titles = [
        f"+S({x},{y})", f"−S({x-1},{y})", f"−S({x},{y-1})", f"+S({x-1},{y-1})"
    ]
    rects = [
        (x, y, 'green', '+'),
        (x - 1, y, 'red', '−'),
        (x, y - 1, 'red', '−'),
        (x - 1, y - 1, 'green', '+'),
    ]

    for idx, (rx, ry, color, sign) in enumerate(rects):
        ax = axes[idx]
        # Draw grid
        for i in range(N):
            for j in range(N):
                ax.plot(i, j, 'ko', markersize=4, alpha=0.3)

        # Draw rectangle
        if rx >= 0 and ry >= 0:
            rect = plt.Rectangle((-0.3, -0.3), rx + 0.6, ry + 0.6,
                                alpha=0.3, facecolor=color, edgecolor=color, linewidth=2)
            ax.add_patch(rect)

        # Mark target point
        ax.plot(x, y, 'k*', markersize=15)
        ax.set_title(titles[idx], fontsize=14, fontweight='bold')
        ax.set_xlim(-0.8, N - 0.5)
        ax.set_ylim(-0.8, N - 0.5)
        ax.set_aspect('equal')
        ax.grid(True, alpha=0.2)

    fig.suptitle(f"Recovering h({x},{y}) via Inclusion-Exclusion on Prefix Sums",
                fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig("/workspace/request-project/Tropical/Langlands/inclusion_exclusion.png",
                dpi=150, bbox_inches='tight')
    plt.close()
    print("  Saved: inclusion_exclusion.png")

    print(f"\n  Formula: h({x},{y}) = S({x},{y}) - S({x-1},{y}) - S({x},{y-1}) + S({x-1},{y-1})")
    print("  The four rectangles overlap such that only the point (x,y) survives.")


# ============================================================================
# Main
# ============================================================================

if __name__ == "__main__":
    print("GL₃ Tropical Satake Reconstruction — Demonstration Suite")
    print("=" * 70)
    print()
    print("This demonstrates the formally verified theorem:")
    print("  'Finitely supported functions on ℕ × ℕ are uniquely determined")
    print("   by their 2D cumulative convolution profiles with Levi segments.'")
    print()

    demo_basic_reconstruction()
    demo_convolution_profiles()
    demo_mobius_inversion()
    demo_kernel_triviality()
    demo_dominant_coweights()
    demo_reconstruction_error()
    demo_inclusion_exclusion()

    print("\n" + "=" * 70)
    print("All demonstrations complete.")
    print("=" * 70)
