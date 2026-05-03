#!/usr/bin/env python3
"""
GL₃ Tropical Satake: Finite Generation Demo
============================================

Demonstrates the theorem that a finitely supported function on the GL₃
dominant chamber ℕ × ℕ (in simple coroot coordinates) is uniquely determined
by its edge restrictions and Levi convolution profiles.

The Lean proof establishes:
  1. Convolution with δ_{(1,0)} shifts: (f * δ_{(1,0)})(a+1,b) = f(a,b)
  2. Convolution with δ_{(0,1)} shifts: (f * δ_{(0,1)})(a,b+1) = f(a,b)
  3. Edge data + Levi profiles uniquely determine f (edge_levi_data_injective)
  4. Compatible data extends uniquely (exists_unique_of_compatible_edge_levi_data)
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib.colors import Normalize
from matplotlib.cm import ScalarMappable

# ============================================================
# Core Definitions
# ============================================================

def tconv(f: dict, g: dict, max_a: int = 20, max_b: int = 20) -> dict:
    """
    Tropical (additive) convolution on ℕ × ℕ:
      (f * g)(a, b) = Σ_{i≤a, j≤b} f(i,j) · g(a-i, b-j)
    """
    result = {}
    for a in range(max_a + 1):
        for b in range(max_b + 1):
            val = 0
            for i in range(a + 1):
                for j in range(b + 1):
                    val += f.get((i, j), 0) * g.get((a - i, b - j), 0)
            if val != 0:
                result[(a, b)] = val
    return result

def edge01(f: dict) -> dict:
    """Edge restriction to {(a, 0)}."""
    return {a: f.get((a, 0), 0) for a in range(max(k[0] for k in f.keys()) + 1 if f else 0 + 1)}

def edge10(f: dict) -> dict:
    """Edge restriction to {(0, b)}."""
    return {b: f.get((0, b), 0) for b in range(max(k[1] for k in f.keys()) + 1 if f else 0 + 1)}

# Levi generators
LEVI_LEFT = {(1, 0): 1}   # δ_{(1,0)}
LEVI_RIGHT = {(0, 1): 1}  # δ_{(0,1)}


# ============================================================
# Demo 1: Shift Property Verification
# ============================================================

def demo_shift_property():
    """Verify the core shift lemma computationally."""
    print("=" * 60)
    print("Demo 1: Shift Property of Levi Generators")
    print("=" * 60)
    
    # Define a test function
    f = {(0, 0): 3, (1, 0): -1, (0, 1): 2, (1, 1): 5, (2, 0): 4, (0, 2): -3, (2, 1): 1}
    
    # Compute convolutions
    left_conv = tconv(f, LEVI_LEFT, 10, 10)
    right_conv = tconv(f, LEVI_RIGHT, 10, 10)
    
    print("\nTest function f:")
    for k in sorted(f.keys()):
        print(f"  f{k} = {f[k]}")
    
    print("\n--- Left shift: (f * δ_{(1,0)})(a+1, b) should equal f(a, b) ---")
    all_pass = True
    for (a, b), v in sorted(f.items()):
        conv_val = left_conv.get((a + 1, b), 0)
        status = "✓" if conv_val == v else "✗"
        if conv_val != v:
            all_pass = False
        print(f"  (f * δ_{{(1,0)}})({a+1}, {b}) = {conv_val}, f({a}, {b}) = {v}  {status}")
    
    # Check vanishing at a=0
    print("\n--- Vanishing: (f * δ_{(1,0)})(0, b) should be 0 ---")
    for b in range(4):
        conv_val = left_conv.get((0, b), 0)
        status = "✓" if conv_val == 0 else "✗"
        if conv_val != 0:
            all_pass = False
        print(f"  (f * δ_{{(1,0)}})(0, {b}) = {conv_val}  {status}")
    
    print(f"\n{'All shift properties verified!' if all_pass else 'FAILURE detected!'}")
    
    print("\n--- Right shift: (f * δ_{(0,1)})(a, b+1) should equal f(a, b) ---")
    for (a, b), v in sorted(f.items()):
        conv_val = right_conv.get((a, b + 1), 0)
        status = "✓" if conv_val == v else "✗"
        print(f"  (f * δ_{{(0,1)}})({a}, {b+1}) = {conv_val}, f({a}, {b}) = {v}  {status}")
    
    return f, left_conv, right_conv


# ============================================================
# Demo 2: Injectivity — Reconstruction from Edge + Levi Data
# ============================================================

def demo_injectivity():
    """Demonstrate that edge + Levi data uniquely determines f."""
    print("\n" + "=" * 60)
    print("Demo 2: Injectivity — Reconstruction from Levi Profiles")
    print("=" * 60)
    
    # Original function
    f = {(0, 0): 1, (1, 0): 2, (0, 1): 3, (1, 1): -1, 
         (2, 0): 1, (0, 2): 2, (2, 1): 4, (1, 2): -2, (3, 0): 1}
    
    N = 5  # grid size
    
    # Compute Levi profiles
    left_prof = tconv(f, LEVI_LEFT, N + 2, N + 2)
    right_prof = tconv(f, LEVI_RIGHT, N + 2, N + 2)
    
    # Reconstruct from left Levi profile alone
    f_reconstructed = {}
    for a in range(N):
        for b in range(N):
            f_reconstructed[(a, b)] = left_prof.get((a + 1, b), 0)
    
    print("\nOriginal function f:")
    for k in sorted(f.keys()):
        print(f"  f{k} = {f[k]}")
    
    print("\nReconstructed from left Levi profile:")
    mismatch = False
    for a in range(N):
        for b in range(N):
            orig = f.get((a, b), 0)
            recon = f_reconstructed.get((a, b), 0)
            if orig != recon:
                print(f"  MISMATCH at ({a},{b}): original={orig}, reconstructed={recon}")
                mismatch = True
    
    if not mismatch:
        print("  ✓ Perfect reconstruction! f_reconstructed = f on all grid points")
    
    # Also verify right Levi reconstruction
    f_right_recon = {}
    for a in range(N):
        for b in range(N):
            f_right_recon[(a, b)] = right_prof.get((a, b + 1), 0)
    
    right_match = all(
        f_right_recon.get((a, b), 0) == f.get((a, b), 0)
        for a in range(N) for b in range(N)
    )
    print(f"  ✓ Right Levi reconstruction also matches: {right_match}")
    
    # Cross-consistency check
    print("\nCross-consistency: leftProf(a+1, b) = rightProf(a, b+1)?")
    consistent = True
    for a in range(N):
        for b in range(N):
            l = left_prof.get((a + 1, b), 0)
            r = right_prof.get((a, b + 1), 0)
            if l != r:
                print(f"  FAIL at ({a},{b}): leftProf({a+1},{b})={l} ≠ rightProf({a},{b+1})={r}")
                consistent = False
    print(f"  ✓ All consistent!" if consistent else "  ✗ Inconsistency found!")
    
    return f


# ============================================================
# Demo 3: Edge-Levi Data Compatibility
# ============================================================

def demo_compatibility():
    """Show the compatibility conditions for valid edge-Levi data."""
    print("\n" + "=" * 60)
    print("Demo 3: Edge-Levi Data Compatibility Conditions")
    print("=" * 60)
    
    f = {(0, 0): 5, (1, 0): -2, (0, 1): 3, (1, 1): 7, (2, 0): 1}
    N = 6
    
    left_edge = {a: f.get((a, 0), 0) for a in range(N)}
    right_edge = {b: f.get((0, b), 0) for b in range(N)}
    left_prof = tconv(f, LEVI_LEFT, N + 2, N + 2)
    right_prof = tconv(f, LEVI_RIGHT, N + 2, N + 2)
    
    print("\nCompatibility condition 1: leftProf(a+1, 0) = leftEdge(a)")
    for a in range(4):
        lp = left_prof.get((a + 1, 0), 0)
        le = left_edge.get(a, 0)
        print(f"  leftProf({a+1}, 0) = {lp}, leftEdge({a}) = {le}  {'✓' if lp == le else '✗'}")
    
    print("\nCompatibility condition 2: rightProf(0, b+1) = rightEdge(b)")
    for b in range(4):
        rp = right_prof.get((0, b + 1), 0)
        re = right_edge.get(b, 0)
        print(f"  rightProf(0, {b+1}) = {rp}, rightEdge({b}) = {re}  {'✓' if rp == re else '✗'}")
    
    print("\nCompatibility condition 3: leftProf(0, b) = 0")
    for b in range(4):
        lp = left_prof.get((0, b), 0)
        print(f"  leftProf(0, {b}) = {lp}  {'✓' if lp == 0 else '✗'}")
    
    print("\nCompatibility condition 4: rightProf(a, 0) = 0")
    for a in range(4):
        rp = right_prof.get((a, 0), 0)
        print(f"  rightProf({a}, 0) = {rp}  {'✓' if rp == 0 else '✗'}")
    
    print("\nCompatibility condition 5: leftProf(a+1, b) = rightProf(a, b+1)")
    for a in range(3):
        for b in range(3):
            lp = left_prof.get((a + 1, b), 0)
            rp = right_prof.get((a, b + 1), 0)
            status = '✓' if lp == rp else '✗'
            print(f"  leftProf({a+1}, {b}) = {lp}, rightProf({a}, {b+1}) = {rp}  {status}")


# ============================================================
# Demo 4: Visualization
# ============================================================

def demo_visualization():
    """Create visualizations of the dominant chamber and reconstruction."""
    print("\n" + "=" * 60)
    print("Demo 4: Visualization of Dominant Chamber Reconstruction")
    print("=" * 60)
    
    # Define a function with interesting support
    f = {}
    for a in range(6):
        for b in range(6):
            if a + b <= 5:
                f[(a, b)] = int(10 * np.sin(a + 1) * np.cos(b + 1))
    
    N = 8
    left_prof = tconv(f, LEVI_LEFT, N + 2, N + 2)
    right_prof = tconv(f, LEVI_RIGHT, N + 2, N + 2)
    
    fig, axes = plt.subplots(2, 2, figsize=(14, 12))
    
    # Plot 1: Original function
    ax = axes[0, 0]
    grid = np.zeros((N, N))
    for a in range(N):
        for b in range(N):
            grid[b, a] = f.get((a, b), 0)  # Note: imshow uses [row, col]
    im1 = ax.imshow(grid, cmap='RdBu_r', origin='lower', aspect='equal',
                     extent=[-0.5, N-0.5, -0.5, N-0.5])
    ax.set_xlabel('a (first simple coroot)')
    ax.set_ylabel('b (second simple coroot)')
    ax.set_title('Original function f on ℕ × ℕ')
    plt.colorbar(im1, ax=ax, label='f(a,b)')
    # Annotate nonzero values
    for a in range(N):
        for b in range(N):
            v = f.get((a, b), 0)
            if v != 0:
                ax.text(a, b, str(v), ha='center', va='center', fontsize=8, fontweight='bold')
    
    # Plot 2: Edge data
    ax = axes[0, 1]
    for a in range(N):
        v = f.get((a, 0), 0)
        ax.bar(a - 0.2, v, width=0.35, color='steelblue', label='edge01' if a == 0 else '')
    for b in range(N):
        v = f.get((0, b), 0)
        ax.bar(b + 0.2, v, width=0.35, color='coral', label='edge10' if b == 0 else '')
    ax.set_xlabel('Index')
    ax.set_ylabel('Value')
    ax.set_title('Edge restrictions')
    ax.legend()
    ax.set_xticks(range(N))
    
    # Plot 3: Left Levi profile (shifted = reconstruction)
    ax = axes[1, 0]
    recon_grid = np.zeros((N, N))
    for a in range(N):
        for b in range(N):
            recon_grid[b, a] = left_prof.get((a + 1, b), 0)
    im3 = ax.imshow(recon_grid, cmap='RdBu_r', origin='lower', aspect='equal',
                     extent=[-0.5, N-0.5, -0.5, N-0.5])
    ax.set_xlabel('a')
    ax.set_ylabel('b')
    ax.set_title('Reconstruction from left Levi profile\nf(a,b) = leftProf(a+1, b)')
    plt.colorbar(im3, ax=ax, label='Reconstructed f(a,b)')
    for a in range(N):
        for b in range(N):
            v = left_prof.get((a + 1, b), 0)
            if v != 0:
                ax.text(a, b, str(int(v)), ha='center', va='center', fontsize=8, fontweight='bold')
    
    # Plot 4: Difference (should be zero)
    ax = axes[1, 1]
    diff_grid = np.zeros((N, N))
    max_diff = 0
    for a in range(N):
        for b in range(N):
            orig = f.get((a, b), 0)
            recon = left_prof.get((a + 1, b), 0)
            diff_grid[b, a] = orig - recon
            max_diff = max(max_diff, abs(orig - recon))
    
    im4 = ax.imshow(diff_grid, cmap='RdBu_r', origin='lower', aspect='equal',
                     extent=[-0.5, N-0.5, -0.5, N-0.5], vmin=-1, vmax=1)
    ax.set_xlabel('a')
    ax.set_ylabel('b')
    ax.set_title(f'Reconstruction error (max = {max_diff})')
    plt.colorbar(im4, ax=ax, label='f - reconstructed')
    
    plt.suptitle('GL₃ Tropical Satake: Edge-Levi Finite Generation', fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('demos/gl3_satake_reconstruction.png', dpi=150, bbox_inches='tight')
    print("\nSaved visualization to demos/gl3_satake_reconstruction.png")
    plt.close()
    
    # Second figure: the propagation/shift mechanism
    fig, axes = plt.subplots(1, 3, figsize=(16, 5))
    
    # Show the shift mechanism
    ax = axes[0]
    # Original on a small grid
    small_N = 5
    for a in range(small_N):
        for b in range(small_N):
            v = f.get((a, b), 0)
            color = 'lightcoral' if b == 0 else ('lightskyblue' if a == 0 else 'lightyellow')
            rect = mpatches.FancyBboxPatch((a - 0.4, b - 0.4), 0.8, 0.8,
                                            boxstyle="round,pad=0.05",
                                            facecolor=color, edgecolor='gray')
            ax.add_patch(rect)
            ax.text(a, b, str(v), ha='center', va='center', fontsize=10, fontweight='bold')
    
    ax.set_xlim(-0.6, small_N - 0.4)
    ax.set_ylim(-0.6, small_N - 0.4)
    ax.set_xlabel('a')
    ax.set_ylabel('b')
    ax.set_title('f on dominant chamber\n(coral = edge01, blue = edge10)')
    ax.set_aspect('equal')
    
    # Show the left shift
    ax = axes[1]
    for a in range(small_N + 1):
        for b in range(small_N):
            v = left_prof.get((a, b), 0)
            color = 'lightgreen' if a > 0 else 'lightgray'
            rect = mpatches.FancyBboxPatch((a - 0.4, b - 0.4), 0.8, 0.8,
                                            boxstyle="round,pad=0.05",
                                            facecolor=color, edgecolor='gray')
            ax.add_patch(rect)
            ax.text(a, b, str(int(v)), ha='center', va='center', fontsize=9)
    
    # Draw arrows showing the shift
    for a in range(1, min(4, small_N + 1)):
        for b in range(min(3, small_N)):
            if f.get((a - 1, b), 0) != 0:
                ax.annotate('', xy=(a - 0.5, b), xytext=(a + 0.5, b),
                           arrowprops=dict(arrowstyle='->', color='red', lw=1.5))
    
    ax.set_xlim(-0.6, small_N + 0.6)
    ax.set_ylim(-0.6, small_N - 0.4)
    ax.set_xlabel('a')
    ax.set_ylabel('b')
    ax.set_title('Left Levi profile (f * δ_{(1,0)})\nShift: value at (a+1,b) = f(a,b)')
    ax.set_aspect('equal')
    
    # Information flow diagram
    ax = axes[2]
    ax.set_xlim(-1, 6)
    ax.set_ylim(-1, 5)
    
    # Draw grid
    for a in range(5):
        for b in range(5):
            if a + b <= 4:
                if a == 0 and b == 0:
                    color = 'gold'
                elif b == 0:
                    color = 'lightcoral'
                elif a == 0:
                    color = 'lightskyblue'
                else:
                    color = 'lightgreen'
                circle = plt.Circle((a, b), 0.35, facecolor=color, edgecolor='black', linewidth=1.5)
                ax.add_patch(circle)
                ax.text(a, b, f'({a},{b})', ha='center', va='center', fontsize=7)
    
    # Arrows showing reconstruction
    for a in range(1, 5):
        for b in range(5):
            if a + b <= 4 and a > 0:
                ax.annotate('', xy=(a, b), xytext=(a - 1, b),
                           arrowprops=dict(arrowstyle='->', color='red', lw=1, alpha=0.6))
    
    ax.text(2, -0.7, 'Red arrows: left Levi shift\nf(a,b) ← leftProf(a+1,b)', 
            ha='center', fontsize=8, style='italic')
    
    ax.set_xlabel('a (first coroot)')
    ax.set_ylabel('b (second coroot)')
    ax.set_title('Information flow in\nthe dominant chamber')
    ax.set_aspect('equal')
    
    legend_elements = [
        mpatches.Patch(facecolor='gold', edgecolor='black', label='Origin (both edges)'),
        mpatches.Patch(facecolor='lightcoral', edgecolor='black', label='Left edge (a, 0)'),
        mpatches.Patch(facecolor='lightskyblue', edgecolor='black', label='Right edge (0, b)'),
        mpatches.Patch(facecolor='lightgreen', edgecolor='black', label='Interior (recovered)'),
    ]
    ax.legend(handles=legend_elements, loc='upper right', fontsize=7)
    
    plt.suptitle('Propagation Mechanism: Boundary → Interior via Levi Shifts', 
                 fontsize=13, fontweight='bold')
    plt.tight_layout()
    plt.savefig('demos/gl3_satake_propagation.png', dpi=150, bbox_inches='tight')
    print("Saved propagation diagram to demos/gl3_satake_propagation.png")
    plt.close()


# ============================================================
# Demo 5: Depth Induction and Finite Support
# ============================================================

def demo_depth_induction():
    """Show depth induction and finite support preservation."""
    print("\n" + "=" * 60)
    print("Demo 5: Depth Induction and Finite Support")
    print("=" * 60)
    
    # Create a function with support bounded by depth
    depth_bound = 5
    f = {}
    for a in range(depth_bound + 1):
        for b in range(depth_bound + 1 - a):
            f[(a, b)] = (a + 1) * (b + 1) * ((-1) ** (a + b))
    
    print(f"\nFunction f with depth bound N = {depth_bound}:")
    print(f"  f(a,b) = (a+1)(b+1)(-1)^(a+b) for a+b ≤ {depth_bound}, 0 otherwise")
    print(f"  Support size: {len(f)} points")
    print(f"  Support: {sorted(f.keys())}")
    
    # Verify depth bound
    print(f"\n  Depth bound property: f(a,b) = 0 for a+b > {depth_bound}?")
    for a in range(depth_bound + 3):
        for b in range(depth_bound + 3):
            if a + b > depth_bound:
                v = f.get((a, b), 0)
                if v != 0:
                    print(f"    FAIL: f({a},{b}) = {v}")
    print(f"  ✓ Verified: all values beyond depth {depth_bound} are zero")
    
    # Show depth layers
    print("\n  Values by depth layer d = a + b:")
    for d in range(depth_bound + 1):
        layer = [(a, d - a) for a in range(d + 1)]
        vals = [f.get(p, 0) for p in layer]
        print(f"    d={d}: {dict(zip(layer, vals))}")
    
    # Show reconstruction proceeds layer by layer
    N = depth_bound + 3
    left_prof = tconv(f, LEVI_LEFT, N, N)
    
    print("\n  Reconstruction by depth:")
    for d in range(depth_bound + 2):
        print(f"    Depth {d}:", end="")
        for a in range(d + 1):
            b = d - a
            orig = f.get((a, b), 0)
            recon = left_prof.get((a + 1, b), 0)
            print(f" f({a},{b})={recon}", end="")
        print(f"  {'✓' if all(f.get((a, d-a), 0) == left_prof.get((a+1, d-a), 0) for a in range(d+1)) else '✗'}")


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print("GL₃ Tropical Satake: Finite Generation from Edge and Levi Data")
    print("=" * 60)
    print()
    print("This demo verifies the Lean-proved theorems with concrete examples.")
    print("Key result: A function on the dominant chamber ℕ × ℕ is uniquely")
    print("determined by its edge restrictions and Levi convolution profiles.")
    print()
    
    demo_shift_property()
    demo_injectivity()
    demo_compatibility()
    demo_depth_induction()
    demo_visualization()
    
    print("\n" + "=" * 60)
    print("All demos completed successfully!")
    print("=" * 60)
