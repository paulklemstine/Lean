"""
Tropical Spectrum Duality — Interactive Demonstration
=====================================================

This script demonstrates the core ideas of tropical spectrum duality
using concrete numerical examples on finite spaces and the interval [0,1].

The main theorem (formalized in Lean 4) states:
    For a compact Hausdorff space X and an algebra A of continuous functions
    that kernel-separates points, the evaluation-to-spectrum map
        x ↦ ker(evₓ)
    is a homeomorphism from X to the tropical evaluation spectrum.

We visualize:
1. Evaluation congruences on a finite set
2. Tropical vanishing loci
3. The spectrum reconstruction for functions on [0,1]
4. Kernel separation vs value separation
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import FancyBboxPatch
from itertools import combinations
import os

# ─── 1. Evaluation Congruences on a Finite Set ────────────────────────────

def demo_finite_congruences():
    """
    Demonstrate evaluation congruences on X = {0, 1, 2} with
    A = {f₁, f₂, f₃} where fᵢ : X → ℝ.
    """
    print("=" * 60)
    print("DEMO 1: Evaluation Congruences on a Finite Set")
    print("=" * 60)

    X = [0, 1, 2]
    # Function algebra: three functions on X = {0, 1, 2}
    # f₁(x) = x,  f₂(x) = x²,  f₃(x) = 2x
    functions = {
        'f₁': lambda x: x,
        'f₂': lambda x: x**2,
        'f₃': lambda x: 2*x,
    }

    print("\nFunction values:")
    print(f"{'':>5} | {'f₁':>5} | {'f₂':>5} | {'f₃':>5}")
    print("-" * 30)
    for x in X:
        vals = [f(x) for f in functions.values()]
        print(f"x={x:>2} | {vals[0]:>5} | {vals[1]:>5} | {vals[2]:>5}")

    print("\nEvaluation congruences (fᵢ ≡ fⱼ at point x):")
    func_names = list(functions.keys())
    for x in X:
        equivs = []
        for i, j in combinations(range(len(func_names)), 2):
            fi, fj = list(functions.values())[i], list(functions.values())[j]
            if fi(x) == fj(x):
                equivs.append(f"{func_names[i]}≡{func_names[j]}")
        cong = ", ".join(equivs) if equivs else "all distinct"
        print(f"  ker(ev_{x}): {cong}")

    # Check kernel separation
    print("\nKernel separation check:")
    for x, y in combinations(X, 2):
        separated = False
        for fi_name, fi in functions.items():
            for fj_name, fj in functions.items():
                if fi(x) == fj(x) and fi(y) != fj(y):
                    print(f"  x={x}, y={y}: {fi_name}(x)={fj_name}(x) but "
                          f"{fi_name}(y)≠{fj_name}(y) ✓")
                    separated = True
                    break
            if separated:
                break
        if not separated:
            print(f"  x={x}, y={y}: NOT kernel-separated ✗")

    return True


# ─── 2. Tropical Vanishing Loci ──────────────────────────────────────────

def demo_vanishing_loci():
    """
    Visualize tropical vanishing loci V(f, g) = {x ∈ [0,1] | f(x) = g(x)}
    and their relation to the spectrum topology.
    """
    print("\n" + "=" * 60)
    print("DEMO 2: Tropical Vanishing Loci on [0, 1]")
    print("=" * 60)

    x = np.linspace(0, 1, 1000)

    # Define some continuous functions
    f1 = np.sin(2 * np.pi * x)
    f2 = np.cos(2 * np.pi * x)
    f3 = 2 * x - 1
    f4 = x * (1 - x) * 4 - 1

    fig, axes = plt.subplots(2, 2, figsize=(14, 10))

    # Plot 1: Functions
    ax = axes[0, 0]
    ax.plot(x, f1, label='f₁ = sin(2πx)', color='blue')
    ax.plot(x, f2, label='f₂ = cos(2πx)', color='red')
    ax.plot(x, f3, label='f₃ = 2x-1', color='green')
    ax.set_title('Function Algebra on [0, 1]')
    ax.legend()
    ax.grid(True, alpha=0.3)
    ax.set_xlabel('x')

    # Plot 2: Vanishing locus V(f₁, f₂) = {x | sin = cos}
    ax = axes[0, 1]
    diff12 = np.abs(f1 - f2)
    ax.fill_between(x, 0, 1, where=diff12 < 0.05, alpha=0.3, color='purple',
                    label='V(f₁, f₂) ≈ {x | f₁(x) = f₂(x)}')
    ax.plot(x, f1, 'b-', alpha=0.5, label='f₁')
    ax.plot(x, f2, 'r-', alpha=0.5, label='f₂')
    # Mark intersection points
    crossings = np.where(np.diff(np.sign(f1 - f2)))[0]
    for c in crossings:
        ax.axvline(x[c], color='purple', linestyle='--', alpha=0.7)
        ax.plot(x[c], f1[c], 'ko', markersize=8)
    ax.set_title('Vanishing Locus V(f₁, f₂)')
    ax.legend(fontsize=8)
    ax.grid(True, alpha=0.3)

    # Plot 3: Intersection of vanishing loci
    ax = axes[1, 0]
    diff13 = np.abs(f1 - f3)
    both = (diff12 < 0.05) & (diff13 < 0.05)
    ax.fill_between(x, 0, 1, where=diff12 < 0.05, alpha=0.2, color='purple',
                    label='V(f₁, f₂)')
    ax.fill_between(x, 0, 1, where=diff13 < 0.05, alpha=0.2, color='orange',
                    label='V(f₁, f₃)')
    ax.fill_between(x, 0, 1, where=both, alpha=0.5, color='red',
                    label='V(f₁,f₂) ∩ V(f₁,f₃)')
    ax.set_title('Intersection of Vanishing Loci')
    ax.legend(fontsize=8)
    ax.grid(True, alpha=0.3)

    # Plot 4: Congruence classes at selected points
    ax = axes[1, 1]
    eval_points = [0.0, 0.125, 0.25, 0.5, 0.75, 1.0]
    funcs = {'f₁': f1, 'f₂': f2, 'f₃': f3, 'f₄': f4}
    func_names = list(funcs.keys())

    # Create a matrix showing which functions agree at each point
    n_funcs = len(func_names)
    n_points = len(eval_points)

    matrix = np.zeros((n_points, n_funcs))
    for i, xp in enumerate(eval_points):
        idx = np.argmin(np.abs(x - xp))
        for j, fn in enumerate(funcs.values()):
            matrix[i, j] = fn[idx]

    im = ax.imshow(matrix, aspect='auto', cmap='RdYlBu')
    ax.set_xticks(range(n_funcs))
    ax.set_xticklabels(func_names)
    ax.set_yticks(range(n_points))
    ax.set_yticklabels([f'x={p:.3f}' for p in eval_points])
    ax.set_title('Function Values (Evaluation Map)')
    plt.colorbar(im, ax=ax, label='Value')

    plt.suptitle('Tropical Spectrum Duality: Vanishing Loci & Evaluation Map',
                 fontsize=14, fontweight='bold')
    plt.tight_layout()

    output_path = os.path.join(os.path.dirname(__file__), 'tropical_vanishing_loci.png')
    plt.savefig(output_path, dpi=150, bbox_inches='tight')
    print(f"\nFigure saved to {output_path}")
    plt.close()


# ─── 3. Spectrum Reconstruction ─────────────────────────────────────────

def demo_spectrum_reconstruction():
    """
    Demonstrate how the space X = [0, 1] can be reconstructed from
    evaluation congruences of its function algebra.
    """
    print("\n" + "=" * 60)
    print("DEMO 3: Spectrum Reconstruction")
    print("=" * 60)

    # Sample points from [0, 1]
    n_points = 50
    X_points = np.linspace(0, 1, n_points)

    # Function algebra: polynomials up to degree 3
    def make_polys(x):
        return np.array([1, x, x**2, x**3, np.sin(np.pi*x)])

    # Compute "distance" between congruences
    # d(ker(evₓ), ker(evᵧ)) = sup_{f,g} |1_{f(x)=g(x)} - 1_{f(y)=g(y)}|
    # In practice, use the metric: how different are the evaluation maps
    n_funcs = 5
    eval_matrix = np.array([make_polys(x) for x in X_points])

    # Congruence distance: based on kernel disagreement
    # Two points have the same congruence iff they give the same
    # partition of functions into equality classes
    def congruence_signature(vals, threshold=1e-10):
        """Return a signature encoding which functions agree."""
        n = len(vals)
        sig = []
        for i in range(n):
            for j in range(i+1, n):
                sig.append(1 if abs(vals[i] - vals[j]) < threshold else 0)
        return tuple(sig)

    signatures = [congruence_signature(eval_matrix[i]) for i in range(n_points)]

    # Check injectivity: all signatures should be distinct
    unique_sigs = len(set(signatures))
    print(f"\nPoints: {n_points}")
    print(f"Distinct congruence signatures: {unique_sigs}")
    print(f"Injective: {'YES ✓' if unique_sigs == n_points else 'NO ✗'}")

    # Visualize the "spectral embedding"
    fig, axes = plt.subplots(1, 3, figsize=(16, 5))

    # Plot 1: Original space X = [0, 1]
    ax = axes[0]
    colors = plt.cm.viridis(X_points)
    ax.scatter(X_points, np.zeros_like(X_points), c=colors, s=50)
    ax.set_title('Original Space X = [0, 1]')
    ax.set_xlabel('x')
    ax.set_yticks([])
    ax.set_xlim(-0.05, 1.05)

    # Plot 2: Evaluation map image (in function space)
    ax = axes[1]
    ax.scatter(eval_matrix[:, 1], eval_matrix[:, 2], c=colors, s=50)
    ax.set_title('Evaluation Image in Function Space')
    ax.set_xlabel('f₂(x) = x')
    ax.set_ylabel('f₃(x) = x²')

    # Plot 3: Congruence distance matrix
    ax = axes[2]
    dist_matrix = np.zeros((n_points, n_points))
    for i in range(n_points):
        for j in range(n_points):
            # Count disagreements between congruence signatures
            dist_matrix[i, j] = sum(
                1 for s1, s2 in zip(signatures[i], signatures[j]) if s1 != s2
            )
    im = ax.imshow(dist_matrix, cmap='hot', interpolation='nearest')
    ax.set_title('Congruence Distance Matrix')
    ax.set_xlabel('Point index')
    ax.set_ylabel('Point index')
    plt.colorbar(im, ax=ax, label='# kernel disagreements')

    plt.suptitle('Reconstructing X from Evaluation Congruences',
                 fontsize=14, fontweight='bold')
    plt.tight_layout()

    output_path = os.path.join(os.path.dirname(__file__), 'spectrum_reconstruction.png')
    plt.savefig(output_path, dpi=150, bbox_inches='tight')
    print(f"Figure saved to {output_path}")
    plt.close()


# ─── 4. Kernel Separation vs Value Separation ───────────────────────────

def demo_kernel_vs_value_separation():
    """
    Demonstrate the crucial difference between value separation
    (eval x f ≠ eval y f) and kernel separation
    (∃ f g, eval x f = eval x g ∧ eval y f ≠ eval y g).

    Value separation is necessary but NOT sufficient for the
    congruence map to be injective.
    """
    print("\n" + "=" * 60)
    print("DEMO 4: Kernel Separation vs Value Separation")
    print("=" * 60)

    # Example: A = {f} with f(0) = 0, f(1) = 1
    # Value separation: f(0) ≠ f(1) ✓
    # Kernel separation: NO, because with only one function,
    # ker(ev₀) = ker(ev₁) = {(f,f)} (the trivial congruence)

    print("\nExample 1: Single function f(x) = x on {0, 1}")
    print("  f(0) = 0, f(1) = 1")
    print("  Value separation: f(0) ≠ f(1) ✓")
    print("  ker(ev₀) = {(f,f)} (trivial)")
    print("  ker(ev₁) = {(f,f)} (trivial)")
    print("  ker(ev₀) = ker(ev₁)  →  NOT kernel-separated ✗")
    print("  → Congruence map is NOT injective!")

    print("\nExample 2: Two functions f(x) = x, g(x) = 0 on {0, 1}")
    print("  f(0) = 0, f(1) = 1, g(0) = 0, g(1) = 0")
    print("  At x=0: f(0) = g(0) = 0, so f ≡ g in ker(ev₀)")
    print("  At x=1: f(1) = 1 ≠ 0 = g(1), so f ≢ g in ker(ev₁)")
    print("  ker(ev₀) ≠ ker(ev₁)  →  kernel-separated ✓")
    print("  → Adding constants enables kernel separation!")

    print("\nKey Insight (Formalized in Lean):")
    print("  kernel_sep_of_value_sep_and_constants:")
    print("  Value separation + constant functions → Kernel separation")

    # Visualization
    fig, axes = plt.subplots(1, 2, figsize=(12, 5))

    # Case 1: Not kernel-separated
    ax = axes[0]
    ax.set_title('NOT Kernel-Separated\n(Single function)', fontsize=11)
    x = [0, 1]
    ax.plot(x, [0, 1], 'bo-', markersize=10, label='f(x) = x')
    ax.set_xlabel('x')
    ax.set_ylabel('Function value')

    # Draw congruence classes
    ax.annotate('ker(ev₀) = ker(ev₁)\n= trivial', xy=(0.5, 0.3),
                fontsize=10, ha='center',
                bbox=dict(boxstyle='round', facecolor='lightyellow'))
    ax.legend()
    ax.grid(True, alpha=0.3)

    # Case 2: Kernel-separated
    ax = axes[1]
    ax.set_title('Kernel-Separated\n(With constants)', fontsize=11)
    ax.plot(x, [0, 1], 'bo-', markersize=10, label='f(x) = x')
    ax.plot(x, [0, 0], 'rs-', markersize=10, label='g(x) = 0')

    # Highlight the key point
    ax.annotate('f(0) = g(0) = 0\nf ≡ g in ker(ev₀)',
                xy=(0, 0), xytext=(0.2, -0.3),
                fontsize=9, ha='center',
                arrowprops=dict(arrowstyle='->', color='green'),
                bbox=dict(boxstyle='round', facecolor='lightgreen'))
    ax.annotate('f(1) = 1 ≠ 0 = g(1)\nf ≢ g in ker(ev₁)',
                xy=(1, 0.5), xytext=(0.7, -0.3),
                fontsize=9, ha='center',
                arrowprops=dict(arrowstyle='->', color='red'),
                bbox=dict(boxstyle='round', facecolor='lightsalmon'))
    ax.legend()
    ax.grid(True, alpha=0.3)
    ax.set_xlabel('x')

    plt.suptitle('Kernel Separation: The Key Condition for Spectral Duality',
                 fontsize=14, fontweight='bold')
    plt.tight_layout()

    output_path = os.path.join(os.path.dirname(__file__), 'kernel_vs_value_separation.png')
    plt.savefig(output_path, dpi=150, bbox_inches='tight')
    print(f"\nFigure saved to {output_path}")
    plt.close()


# ─── 5. Application: Neural Network Decision Boundaries ─────────────────

def demo_neural_network_application():
    """
    Show how tropical spectrum duality applies to understanding
    ReLU neural network decision boundaries as tropical vanishing loci.
    """
    print("\n" + "=" * 60)
    print("DEMO 5: Application — Neural Network Decision Boundaries")
    print("=" * 60)

    # A simple max-plus (tropical) neural network
    # f(x, y) = max(2x + y, x + 2y, 3)
    # g(x, y) = max(x + y + 1, 2x, 2y)

    x = np.linspace(-2, 4, 200)
    y = np.linspace(-2, 4, 200)
    X, Y = np.meshgrid(x, y)

    # Tropical polynomial functions (max-plus)
    F = np.maximum(np.maximum(2*X + Y, X + 2*Y), 3)
    G = np.maximum(np.maximum(X + Y + 1, 2*X), 2*Y)

    # The tropical vanishing locus V(F, G) = {(x,y) | F(x,y) = G(x,y)}
    diff = F - G

    fig, axes = plt.subplots(1, 3, figsize=(16, 5))

    # Plot F
    ax = axes[0]
    im = ax.contourf(X, Y, F, levels=20, cmap='viridis')
    ax.set_title('f(x,y) = max(2x+y, x+2y, 3)')
    ax.set_xlabel('x')
    ax.set_ylabel('y')
    plt.colorbar(im, ax=ax)

    # Plot G
    ax = axes[1]
    im = ax.contourf(X, Y, G, levels=20, cmap='viridis')
    ax.set_title('g(x,y) = max(x+y+1, 2x, 2y)')
    ax.set_xlabel('x')
    ax.set_ylabel('y')
    plt.colorbar(im, ax=ax)

    # Plot the vanishing locus
    ax = axes[2]
    ax.contourf(X, Y, np.abs(diff), levels=[0, 0.1, 0.5, 1, 2, 5],
                cmap='Reds_r', alpha=0.7)
    ax.contour(X, Y, diff, levels=[0], colors='black', linewidths=2)
    ax.set_title('V(f, g) = {(x,y) | f = g}\n(Tropical Vanishing Locus)')
    ax.set_xlabel('x')
    ax.set_ylabel('y')
    ax.annotate('Decision\nBoundary', xy=(1.5, 1.5), fontsize=10,
                ha='center', fontweight='bold',
                bbox=dict(boxstyle='round', facecolor='white', alpha=0.8))

    plt.suptitle('Neural Network Boundaries as Tropical Vanishing Loci',
                 fontsize=14, fontweight='bold')
    plt.tight_layout()

    output_path = os.path.join(os.path.dirname(__file__), 'neural_network_tropical.png')
    plt.savefig(output_path, dpi=150, bbox_inches='tight')
    print(f"Figure saved to {output_path}")
    plt.close()

    print("\nInterpretation:")
    print("  • Each ReLU network layer computes a max-plus linear function")
    print("  • Decision boundaries = loci where two network outputs agree")
    print("  • These are exactly the tropical vanishing loci V(f, g)")
    print("  • The spectrum duality theorem says these loci generate")
    print("    the topology of the input space")
    print("  • This gives a rigorous algebraic framework for understanding")
    print("    what neural networks 'see' in terms of input geometry")


# ─── Main ────────────────────────────────────────────────────────────────

if __name__ == '__main__':
    print("╔══════════════════════════════════════════════════════════╗")
    print("║    TROPICAL SPECTRUM DUALITY — Interactive Demo          ║")
    print("║    Formalized in Lean 4 with complete proofs             ║")
    print("╚══════════════════════════════════════════════════════════╝")

    demo_finite_congruences()
    demo_vanishing_loci()
    demo_spectrum_reconstruction()
    demo_kernel_vs_value_separation()
    demo_neural_network_application()

    print("\n" + "=" * 60)
    print("All demos complete!")
    print("Generated figures:")
    print("  • tropical_vanishing_loci.png")
    print("  • spectrum_reconstruction.png")
    print("  • kernel_vs_value_separation.png")
    print("  • neural_network_tropical.png")
    print("=" * 60)
