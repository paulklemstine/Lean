#!/usr/bin/env python3
"""
Tropical Min-Plus Stone–Weierstrass: Demonstrations

This script demonstrates the core ideas formalized in our Lean 4 proof:
1. The negation duality between min-plus and max-plus
2. Uniform approximation of continuous functions by min-plus tropical polynomials
3. Applications to shortest-path value functions and morphological erosions

Author: Harmonic Research
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.gridspec import GridSpec
import os

# ─── Configuration ───────────────────────────────────────────────────────────
OUTPUT_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "figures")
os.makedirs(OUTPUT_DIR, exist_ok=True)

# ─── Min-plus / max-plus operations ─────────────────────────────────────────
def trop_min_add(f, g):
    """Tropical addition: pointwise min."""
    return np.minimum(f, g)

def trop_min_mul(f, g):
    """Tropical multiplication: pointwise sum."""
    return f + g

def trop_neg(f):
    """Order-reversing involution: f ↦ -f."""
    return -f

# ─── Demo 1: Negation duality visualization ─────────────────────────────────
def demo_negation_duality():
    """Show that negation converts min-plus → max-plus and vice versa."""
    x = np.linspace(0, 1, 500)
    f = np.sin(4 * np.pi * x)
    g = 0.5 * np.cos(2 * np.pi * x) + 0.3

    fig, axes = plt.subplots(2, 2, figsize=(12, 8))
    fig.suptitle("Negation Duality: Min-Plus ↔ Max-Plus", fontsize=14, fontweight='bold')

    # Top-left: f and g
    axes[0, 0].plot(x, f, 'b-', label='f(x)', linewidth=1.5)
    axes[0, 0].plot(x, g, 'r-', label='g(x)', linewidth=1.5)
    axes[0, 0].set_title('Original functions f, g')
    axes[0, 0].legend()
    axes[0, 0].grid(True, alpha=0.3)

    # Top-right: min(f,g) — tropical addition
    axes[0, 1].plot(x, f, 'b--', alpha=0.4, linewidth=0.8)
    axes[0, 1].plot(x, g, 'r--', alpha=0.4, linewidth=0.8)
    axes[0, 1].plot(x, trop_min_add(f, g), 'k-', label='f ⊕ g = min(f,g)', linewidth=2)
    axes[0, 1].set_title('Tropical Addition (min)')
    axes[0, 1].legend()
    axes[0, 1].grid(True, alpha=0.3)

    # Bottom-left: -f and -g
    axes[1, 0].plot(x, -f, 'b-', label='-f(x)', linewidth=1.5)
    axes[1, 0].plot(x, -g, 'r-', label='-g(x)', linewidth=1.5)
    axes[1, 0].set_title('Negated functions -f, -g')
    axes[1, 0].legend()
    axes[1, 0].grid(True, alpha=0.3)

    # Bottom-right: max(-f,-g) = -(min(f,g))
    neg_min = trop_neg(trop_min_add(f, g))
    max_neg = np.maximum(-f, -g)
    axes[1, 1].plot(x, neg_min, 'k-', label='−(f ⊕ g) = max(−f,−g)', linewidth=2)
    axes[1, 1].plot(x, max_neg, 'g--', label='max(−f,−g) [direct]', linewidth=1.5)
    axes[1, 1].set_title('Duality: −min = max after negation')
    axes[1, 1].legend()
    axes[1, 1].grid(True, alpha=0.3)

    # Verify identity
    err = np.max(np.abs(neg_min - max_neg))
    fig.text(0.5, 0.02,
             f'Verification: ‖−min(f,g) − max(−f,−g)‖∞ = {err:.2e} (machine zero)',
             ha='center', fontsize=11, style='italic')

    plt.tight_layout(rect=[0, 0.05, 1, 0.95])
    plt.savefig(os.path.join(OUTPUT_DIR, "negation_duality.png"), dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Demo 1: Negation duality visualization saved.")


# ─── Demo 2: Tropical polynomial approximation ──────────────────────────────
def tropical_affine_combination(x, generators, weights):
    """
    Compute a tropical affine combination:
       g(x) = inf_i (w_i + G_i(x))
    This is a finite infimum (min) of shifted generators.
    """
    terms = np.array([w + gen(x) for w, gen in zip(weights, generators)])
    return np.min(terms, axis=0)


def demo_tropical_approximation():
    """
    Approximate a target function by min-plus tropical polynomials
    (finite infima of affine/shifted generator functions).
    """
    x = np.linspace(0, 1, 1000)

    # Target function to approximate
    target = lambda t: np.sin(2 * np.pi * t) + 0.5 * np.cos(6 * np.pi * t)

    # Generator: identity function and constant
    generators = [
        lambda t: t,           # G_0(x) = x
        lambda t: 1.0 - t,     # G_1(x) = 1-x
        lambda t: np.abs(t - 0.5),  # G_2(x) = |x - 0.5|
    ]

    # Increasing number of tropical terms
    fig, axes = plt.subplots(2, 3, figsize=(15, 8))
    fig.suptitle("Tropical Min-Plus Approximation of f(x) = sin(2πx) + ½cos(6πx)",
                 fontsize=13, fontweight='bold')

    # Use distance templates for approximation (McShane–Whitney style)
    K = 20.0  # Lipschitz constant upper bound

    for idx, n_points in enumerate([3, 5, 10, 20, 50, 200]):
        ax = axes.flat[idx]

        # Sample points for distance templates
        sample_pts = np.linspace(0, 1, n_points)
        f_target = target(x)
        f_sample = target(sample_pts)

        # Lower envelope: max over φ_a(x) = f(a) - K|x-a|
        # Upper envelope: min over ψ_a(x) = f(a) + K|x-a|
        upper_envelope = np.full_like(x, np.inf)
        for a, fa in zip(sample_pts, f_sample):
            template = fa + K * np.abs(x - a)
            upper_envelope = np.minimum(upper_envelope, template)

        err = np.max(np.abs(f_target - upper_envelope))

        ax.plot(x, f_target, 'b-', label='target f', linewidth=1.5)
        ax.plot(x, upper_envelope, 'r-', label=f'tropical approx', linewidth=1.2)
        ax.fill_between(x, f_target, upper_envelope, alpha=0.15, color='red')
        ax.set_title(f'N={n_points}, ‖f−g‖∞ = {err:.4f}')
        ax.legend(fontsize=8)
        ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig(os.path.join(OUTPUT_DIR, "tropical_approximation.png"), dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Demo 2: Tropical polynomial approximation saved.")


# ─── Demo 3: Norm invariance under negation ─────────────────────────────────
def demo_norm_invariance():
    """
    Numerically verify the key transport lemma: ‖tropNeg f - tropNeg g‖ = ‖f - g‖.
    """
    x = np.linspace(0, 1, 10000)
    np.random.seed(42)

    results = []
    for trial in range(20):
        # Random continuous functions (sums of sinusoids)
        freqs_f = np.random.randn(5)
        freqs_g = np.random.randn(5)
        f = sum(a * np.sin((k+1) * np.pi * x) for k, a in enumerate(freqs_f))
        g = sum(a * np.sin((k+1) * np.pi * x) for k, a in enumerate(freqs_g))

        norm_fg = np.max(np.abs(f - g))
        norm_neg = np.max(np.abs((-f) - (-g)))
        results.append((norm_fg, norm_neg, abs(norm_fg - norm_neg)))

    fig, ax = plt.subplots(figsize=(8, 6))
    norms_orig = [r[0] for r in results]
    norms_neg = [r[1] for r in results]
    errors = [r[2] for r in results]

    ax.scatter(norms_orig, norms_neg, c='blue', s=60, zorder=5, label='(‖f−g‖, ‖−f−(−g)‖)')
    lim = max(max(norms_orig), max(norms_neg)) * 1.1
    ax.plot([0, lim], [0, lim], 'r--', linewidth=1, label='y = x (perfect agreement)')
    ax.set_xlabel('‖f − g‖∞', fontsize=12)
    ax.set_ylabel('‖tropNeg(f) − tropNeg(g)‖∞', fontsize=12)
    ax.set_title('Norm Invariance Under Negation (20 random trials)', fontsize=13, fontweight='bold')
    ax.legend()
    ax.grid(True, alpha=0.3)

    max_err = max(errors)
    ax.text(0.05, 0.95, f'Max discrepancy: {max_err:.2e}\n(machine precision)',
            transform=ax.transAxes, fontsize=10, verticalalignment='top',
            bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))

    plt.tight_layout()
    plt.savefig(os.path.join(OUTPUT_DIR, "norm_invariance.png"), dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Demo 3: Norm invariance verification saved.")


# ─── Demo 4: Shortest-path value function approximation ─────────────────────
def demo_shortest_path():
    """
    Application: Approximate a shortest-path value function
    using tropical min-plus envelopes (distance templates).

    This demonstrates the connection to dynamic programming:
    V(x) = inf_a [c(a) + K·d(x,a)] is exactly a tropical polynomial.
    """
    x = np.linspace(0, 1, 500)

    # "Cost landscape" — a complex value function
    V = 2.0 * np.exp(-20 * (x - 0.3)**2) + 1.5 * np.exp(-30 * (x - 0.7)**2) + 0.5

    # Approximate with distance templates (tropical min-plus polynomials)
    K = 15.0
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))
    fig.suptitle("Shortest-Path Value Function via Tropical Envelopes",
                 fontsize=13, fontweight='bold')

    for idx, n in enumerate([5, 15, 50]):
        ax = axes[idx]
        pts = np.linspace(0, 1, n)
        V_pts = np.interp(pts, x, V)

        # Upper tropical envelope: min_a [V(a) + K|x-a|]
        envelope = np.full_like(x, np.inf)
        for a, va in zip(pts, V_pts):
            template = va + K * np.abs(x - a)
            if idx == 1 and n == 15:  # Show individual templates for middle plot
                ax.plot(x, template, 'gray', alpha=0.2, linewidth=0.5)
            envelope = np.minimum(envelope, template)

        err = np.max(np.abs(V - envelope))

        ax.plot(x, V, 'b-', label='V(x) (value function)', linewidth=2)
        ax.plot(x, envelope, 'r--', label=f'tropical approx (N={n})', linewidth=1.5)
        ax.set_title(f'N={n} templates, ε = {err:.4f}')
        ax.legend(fontsize=9)
        ax.grid(True, alpha=0.3)
        ax.set_xlabel('x')
        ax.set_ylabel('V(x)')

    plt.tight_layout()
    plt.savefig(os.path.join(OUTPUT_DIR, "shortest_path_approx.png"), dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Demo 4: Shortest-path value function approximation saved.")


# ─── Demo 5: Morphological erosion as tropical operation ─────────────────────
def demo_morphological_erosion():
    """
    Application: Morphological erosion is a tropical min-plus operation.
    Erosion of f by structuring element b:
        (f ⊖ b)(x) = inf_y [f(y) - b(y-x)] = inf_y [f(y) + (-b)(y-x)]
    This is a tropical (min-plus) convolution.
    """
    x = np.linspace(0, 1, 500)

    # Signal
    signal = np.zeros_like(x)
    signal[100:150] = 1.0
    signal[200:350] = 0.7
    signal[380:420] = 1.2

    # Structuring elements of different radii
    fig, axes = plt.subplots(1, 3, figsize=(15, 4.5))
    fig.suptitle("Morphological Erosion as Tropical Min-Plus Convolution",
                 fontsize=13, fontweight='bold')

    for idx, radius in enumerate([10, 30, 60]):
        ax = axes[idx]

        # Erosion: slide a flat structuring element
        eroded = np.full_like(signal, np.inf)
        for shift in range(-radius, radius + 1):
            shifted = np.roll(signal, shift)
            # Handle boundary
            if shift > 0:
                shifted[:shift] = signal[0]
            elif shift < 0:
                shifted[shift:] = signal[-1]
            eroded = np.minimum(eroded, shifted)

        ax.plot(x, signal, 'b-', label='original signal', linewidth=1.5)
        ax.plot(x, eroded, 'r-', label=f'erosion (r={radius})', linewidth=1.5)
        ax.fill_between(x, eroded, signal, alpha=0.15, color='orange')
        ax.set_title(f'Flat erosion, radius = {radius}')
        ax.legend(fontsize=9)
        ax.grid(True, alpha=0.3)
        ax.set_ylim(-0.1, 1.4)

    plt.tight_layout()
    plt.savefig(os.path.join(OUTPUT_DIR, "morphological_erosion.png"), dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Demo 5: Morphological erosion demonstration saved.")


# ─── Demo 6: Convergence rate analysis ──────────────────────────────────────
def demo_convergence_rate():
    """
    Analyze the convergence rate of tropical min-plus approximation
    as a function of the number of template points, for Lipschitz functions.
    """
    x = np.linspace(0, 1, 5000)

    # Test functions with known Lipschitz constants
    test_fns = [
        ("sin(2πx)", lambda t: np.sin(2*np.pi*t), 2*np.pi),
        ("x²", lambda t: t**2, 2.0),
        ("|x−½|", lambda t: np.abs(t - 0.5), 1.0),
    ]

    fig, ax = plt.subplots(figsize=(9, 6))
    colors = ['blue', 'red', 'green']

    for (name, fn, K), color in zip(test_fns, colors):
        ns = np.array([2, 3, 5, 8, 12, 20, 35, 60, 100, 200, 500])
        errors = []

        f_target = fn(x)
        for n in ns:
            pts = np.linspace(0, 1, n)
            f_pts = fn(pts)
            envelope = np.full_like(x, np.inf)
            for a, fa in zip(pts, f_pts):
                envelope = np.minimum(envelope, fa + K * np.abs(x - a))
            errors.append(np.max(np.abs(f_target - envelope)))

        ax.loglog(ns, errors, 'o-', color=color, label=f'{name} (K={K:.1f})',
                  linewidth=1.5, markersize=4)

    # Reference line: O(1/n) convergence
    ns_ref = np.array([2, 500])
    ax.loglog(ns_ref, 5.0 / ns_ref, 'k--', alpha=0.5, label='O(1/N) reference')

    ax.set_xlabel('Number of template points N', fontsize=12)
    ax.set_ylabel('Approximation error ‖f − g‖∞', fontsize=12)
    ax.set_title('Convergence Rate of Tropical Approximation', fontsize=13, fontweight='bold')
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3, which='both')

    plt.tight_layout()
    plt.savefig(os.path.join(OUTPUT_DIR, "convergence_rate.png"), dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Demo 6: Convergence rate analysis saved.")


# ─── Main ────────────────────────────────────────────────────────────────────
if __name__ == "__main__":
    print("=" * 60)
    print("  Tropical Min-Plus Stone–Weierstrass Demonstrations")
    print("=" * 60)
    print()

    demo_negation_duality()
    demo_tropical_approximation()
    demo_norm_invariance()
    demo_shortest_path()
    demo_morphological_erosion()
    demo_convergence_rate()

    print()
    print(f"All figures saved to: {OUTPUT_DIR}/")
    print()
    print("Key takeaways:")
    print("  1. Negation f ↦ −f is an exact algebraic + metric bridge")
    print("     between min-plus and max-plus tropical structures.")
    print("  2. Tropical min-plus polynomials (finite infima of shifted")
    print("     generators) converge uniformly to any continuous function.")
    print("  3. Distance templates give O(1/N) convergence for Lipschitz")
    print("     functions — exactly the language of dynamic programming.")
    print("  4. Morphological erosions are tropical min-plus convolutions,")
    print("     so the Stone–Weierstrass theorem certifies their")
    print("     approximation power.")
