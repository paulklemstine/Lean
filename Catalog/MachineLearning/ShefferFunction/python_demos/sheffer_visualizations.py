"""
Sheffer Algebra Visualizations
==============================

Interactive demonstrations of the key results from the Sheffer function program.
Generates publication-quality figures illustrating:

1. The Three-Barrier System
2. Iterated Softplus Orbits and Merging
3. Derivative Limit Pairs
4. Bounded Sheffer Functions
5. Sigmoid-Tanh Equivalence
6. The Fourth Barrier: Asymptotic Linear Structure

Usage:
    python sheffer_visualizations.py
    # Generates PNG files in the current directory
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.gridspec import GridSpec

# ─── Core Sheffer Functions ───

def softplus(x):
    """σ(x) = log(1 + eˣ), numerically stable."""
    return np.where(x > 20, x, np.log1p(np.exp(np.clip(x, -500, 20))))

def sigmoid(x):
    """S(x) = eˣ/(1+eˣ) = σ'(x), numerically stable."""
    return np.where(x > 0, 1 / (1 + np.exp(-x)), np.exp(x) / (1 + np.exp(x)))

def softplus_iter(n, x):
    """σⁿ(x) = log(n + eˣ), the general iterated softplus identity."""
    return np.log(n + np.exp(x))

def softplus_iter_deriv(n, x):
    """(σⁿ)'(x) = eˣ/(n + eˣ)."""
    return np.exp(x) / (n + np.exp(x))


# ─── Figure 1: The Three-Barrier System ───

def plot_three_barriers():
    """Visualize which functions pass/fail the three barriers."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    x = np.linspace(-4, 4, 1000)

    # Barrier 1: Analyticity (Cω)
    ax = axes[0]
    ax.set_title("Barrier 1: Analyticity (Cω)", fontsize=13, fontweight='bold')
    ax.plot(x, softplus(x), 'b-', linewidth=2, label='σ(x) ✓')
    ax.plot(x, np.exp(x), 'r--', linewidth=2, label='eˣ (not Lip) ✗')
    bump = np.exp(-1/np.where(np.abs(x) < 1, 1 - x**2, 1e-10))
    bump = np.where(np.abs(x) < 1, bump, 0)
    ax.plot(x, bump * 3, 'g:', linewidth=2, label='bump fn (C∞ not Cω) ✗')
    ax.legend(fontsize=9)
    ax.set_ylim(-1, 8)
    ax.grid(True, alpha=0.3)

    # Barrier 2: Lipschitz
    ax = axes[1]
    ax.set_title("Barrier 2: Lipschitz Continuity", fontsize=13, fontweight='bold')
    ax.plot(x, softplus(x), 'b-', linewidth=2, label='σ(x) (Lip=1) ✓')
    ax.plot(x, x**2, 'r--', linewidth=2, label='x² (not Lip) ✗')
    relu = np.maximum(x, 0)
    ax.plot(x, relu, 'g:', linewidth=2, label='ReLU (Lip but ∉ Cω) ✗')
    ax.legend(fontsize=9)
    ax.set_ylim(-1, 8)
    ax.grid(True, alpha=0.3)

    # Barrier 3: Derivative Convergence
    ax = axes[2]
    ax.set_title("Barrier 3: Derivative Convergence at ±∞", fontsize=13, fontweight='bold')
    ax.plot(x, sigmoid(x), 'b-', linewidth=2, label="σ'(x) → 1,0 ✓")
    ax.plot(x, np.cos(x), 'r--', linewidth=2, label="sin'(x) = cos(x) ✗")
    ax.plot(x, np.ones_like(x), 'g:', linewidth=2, label="id'(x) = 1 ✓")
    ax.axhline(y=1, color='gray', linestyle=':', alpha=0.3)
    ax.axhline(y=0, color='gray', linestyle=':', alpha=0.3)
    ax.legend(fontsize=9)
    ax.set_ylim(-1.5, 1.5)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('fig1_three_barriers.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Generated fig1_three_barriers.png")


# ─── Figure 2: Iterated Softplus Orbits ───

def plot_iterated_softplus():
    """Demonstrate σⁿ(x) = log(n + eˣ) and orbit merging."""
    fig, axes = plt.subplots(1, 3, figsize=(16, 5))

    # Panel 1: Multiple orbits
    ax = axes[0]
    ax.set_title("Iterated Softplus Orbits", fontsize=13, fontweight='bold')
    starts = [-2, -1, 0, 1, 2, 3]
    colors = plt.cm.viridis(np.linspace(0.1, 0.9, len(starts)))
    ns = np.arange(0, 30)
    for x0, c in zip(starts, colors):
        orbit = [softplus_iter(n, x0) for n in ns]
        ax.plot(ns, orbit, 'o-', color=c, markersize=3, linewidth=1.5,
                label=f'x₀ = {x0}')
    ax.plot(ns, np.log(ns + 1), 'k--', linewidth=2, alpha=0.5, label='log(n+1)')
    ax.legend(fontsize=8, ncol=2)
    ax.set_xlabel('Iteration n')
    ax.set_ylabel('σⁿ(x₀)')
    ax.grid(True, alpha=0.3)

    # Panel 2: Orbit differences (merging)
    ax = axes[1]
    ax.set_title("Orbit Merging: σⁿ(x) - σⁿ(0) → 0", fontsize=13, fontweight='bold')
    ns_fine = np.arange(1, 100)
    for x0, c in zip(starts, colors):
        diff = [softplus_iter(n, x0) - softplus_iter(n, 0) for n in ns_fine]
        ax.plot(ns_fine, diff, '-', color=c, linewidth=1.5, label=f'x₀ = {x0}')
    ax.axhline(y=0, color='black', linestyle='-', alpha=0.3)
    ax.legend(fontsize=8)
    ax.set_xlabel('Iteration n')
    ax.set_ylabel('σⁿ(x₀) - σⁿ(0)')
    ax.grid(True, alpha=0.3)

    # Panel 3: Derivative decay
    ax = axes[2]
    ax.set_title("Derivative Decay: (σⁿ)'(x) → 0", fontsize=13, fontweight='bold')
    x = np.linspace(-3, 5, 200)
    for n in [1, 2, 5, 10, 20, 50]:
        ax.plot(x, softplus_iter_deriv(n, x), linewidth=1.5, label=f'n = {n}')
    ax.set_xlabel('x')
    ax.set_ylabel("(σⁿ)'(x)")
    ax.legend(fontsize=8)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('fig2_iterated_softplus.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Generated fig2_iterated_softplus.png")


# ─── Figure 3: Derivative Limit Pairs ───

def plot_derivative_limit_pairs():
    """Demonstrate that any (L₊, L₋) pair is achievable."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    x = np.linspace(-6, 6, 1000)

    # Panel 1: Example functions achieving various pairs
    ax = axes[0]
    ax.set_title("Sheffer Functions with Prescribed Derivative Limits",
                 fontsize=12, fontweight='bold')
    pairs = [(2, -1), (1, 0), (0, 0), (1, 1), (-1, 3)]
    colors = ['red', 'blue', 'green', 'orange', 'purple']
    for (a, b), c in zip(pairs, colors):
        f = (a - b) * softplus(x) + b * x
        ax.plot(x, f, color=c, linewidth=2, label=f'(L₊,L₋) = ({a},{b})')
    ax.legend(fontsize=9)
    ax.set_xlabel('x')
    ax.set_ylabel('f(x)')
    ax.grid(True, alpha=0.3)

    # Panel 2: Their derivatives converging
    ax = axes[1]
    ax.set_title("Derivatives Converging to Prescribed Limits",
                 fontsize=12, fontweight='bold')
    for (a, b), c in zip(pairs, colors):
        fprime = (a - b) * sigmoid(x) + b
        ax.plot(x, fprime, color=c, linewidth=2, label=f'f\'→({a},{b})')
        ax.axhline(y=a, color=c, linestyle=':', alpha=0.3)
        ax.axhline(y=b, color=c, linestyle='--', alpha=0.3)
    ax.legend(fontsize=9)
    ax.set_xlabel('x')
    ax.set_ylabel("f'(x)")
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('fig3_derivative_limit_pairs.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Generated fig3_derivative_limit_pairs.png")


# ─── Figure 4: Bounded Sheffer Functions ───

def plot_bounded_sheffer():
    """Show σ(x) - σ(x+c) as bounded non-constant Sheffer functions."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    x = np.linspace(-6, 6, 1000)

    # Panel 1: Various shift parameters
    ax = axes[0]
    ax.set_title("Bounded Sheffer Functions: σ(x) - σ(x+c)", fontsize=13, fontweight='bold')
    for c in [0.5, 1, 2, 3, 5]:
        f = softplus(x) - softplus(x + c)
        ax.plot(x, f, linewidth=2, label=f'c = {c}')
    ax.axhline(y=0, color='gray', linestyle=':', alpha=0.3)
    ax.legend(fontsize=9)
    ax.set_xlabel('x')
    ax.set_ylabel('σ(x) - σ(x+c)')
    ax.grid(True, alpha=0.3)

    # Panel 2: Comparison with sigmoid
    ax = axes[1]
    ax.set_title("Bounded Functions: Sheffer vs Sigmoid", fontsize=13, fontweight='bold')
    ax.plot(x, softplus(x) - softplus(x + 1), 'b-', linewidth=2,
            label='σ(x)-σ(x+1) ∈ ShefferAlg ✓')
    ax.plot(x, sigmoid(x), 'r--', linewidth=2,
            label='S(x) = sigmoid ∈ ShefferAlg? (Q38)')
    ax.plot(x, np.tanh(x/2), 'g:', linewidth=2,
            label='tanh(x/2) ∈ ShefferAlg? (Q36)')
    ax.legend(fontsize=9)
    ax.set_xlabel('x')
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('fig4_bounded_sheffer.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Generated fig4_bounded_sheffer.png")


# ─── Figure 5: Sigmoid-Tanh Equivalence ───

def plot_sigmoid_tanh():
    """Demonstrate tanh(x) = 2·S(2x) - 1 and S(x) = (tanh(x/2)+1)/2."""
    fig, axes = plt.subplots(1, 3, figsize=(16, 5))

    x = np.linspace(-4, 4, 1000)

    # Panel 1: Sigmoid and tanh
    ax = axes[0]
    ax.set_title("Sigmoid and Tanh", fontsize=13, fontweight='bold')
    ax.plot(x, sigmoid(x), 'b-', linewidth=2, label='S(x) = sigmoid')
    ax.plot(x, np.tanh(x), 'r-', linewidth=2, label='tanh(x)')
    ax.axhline(y=0, color='gray', linestyle=':', alpha=0.3)
    ax.axhline(y=0.5, color='blue', linestyle=':', alpha=0.3)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    # Panel 2: The identity tanh(x) = 2·S(2x) - 1
    ax = axes[1]
    ax.set_title("Identity: tanh(x) = 2·S(2x) − 1", fontsize=13, fontweight='bold')
    ax.plot(x, np.tanh(x), 'r-', linewidth=3, label='tanh(x)')
    ax.plot(x, 2*sigmoid(2*x) - 1, 'b--', linewidth=2, label='2·S(2x) − 1')
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    # Panel 3: log(S(x)) = x - σ(x) ∈ ShefferAlg
    ax = axes[2]
    ax.set_title("log(S(x)) = x − σ(x) ∈ ShefferAlg", fontsize=13, fontweight='bold')
    ax.plot(x, x - softplus(x), 'b-', linewidth=2, label='x − σ(x) = log(S(x))')
    ax.plot(x, -softplus(-x), 'r--', linewidth=2, label='−σ(−x) (= same)')
    ax.plot(x, np.log(sigmoid(x) + 1e-20), 'g:', linewidth=2, label='log(S(x)) (direct)')
    ax.legend(fontsize=9)
    ax.set_xlabel('x')
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('fig5_sigmoid_tanh_equivalence.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Generated fig5_sigmoid_tanh_equivalence.png")


# ─── Figure 6: Growth Decomposition ───

def plot_growth_decomposition():
    """Visualize σⁿ(x) = log(n) + log(1 + eˣ/n)."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    # Panel 1: σⁿ(0) vs log(n+1)
    ax = axes[0]
    ax.set_title("σⁿ(0) = log(n+1): Logarithmic Growth", fontsize=13, fontweight='bold')
    ns = np.arange(1, 50)
    ax.plot(ns, np.log(ns + 1), 'b-', linewidth=2, label='σⁿ(0) = log(n+1)')
    ax.plot(ns, np.log(ns), 'r--', linewidth=2, label='log(n)')
    correction = np.log(1 + 1/ns)
    ax.fill_between(ns, np.log(ns), np.log(ns+1), alpha=0.2, color='blue',
                    label='Correction: log(1+1/n)')
    ax.legend(fontsize=10)
    ax.set_xlabel('n')
    ax.set_ylabel('σⁿ(0)')
    ax.grid(True, alpha=0.3)

    # Panel 2: The correction term
    ax = axes[1]
    ax.set_title("Correction: σⁿ(x) − log(n) = log(1 + eˣ/n)", fontsize=13, fontweight='bold')
    ns = np.arange(1, 100)
    for x0 in [-2, 0, 1, 3]:
        correction = np.log(1 + np.exp(x0)/ns)
        ax.plot(ns, correction, linewidth=2, label=f'x₀ = {x0}')
    ax.axhline(y=0, color='gray', linestyle=':', alpha=0.3)
    ax.legend(fontsize=10)
    ax.set_xlabel('n')
    ax.set_ylabel('σⁿ(x₀) − log(n)')
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('fig6_growth_decomposition.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Generated fig6_growth_decomposition.png")


# ─── Figure 7: The Sheffer Algebra Landscape ───

def plot_sheffer_landscape():
    """Comprehensive overview of the Sheffer algebra barrier system."""
    fig = plt.figure(figsize=(12, 10))

    # Function catalog
    functions = [
        ("σ(x)", lambda x: softplus(x), True, "Cω ✓", "Lip ✓", "DC ✓"),
        ("x", lambda x: x, True, "Cω ✓", "Lip ✓", "DC ✓"),
        ("σ(x)−σ(x+1)", lambda x: softplus(x)-softplus(x+1), True, "Cω ✓", "Lip ✓", "DC ✓"),
        ("S(x)", lambda x: sigmoid(x), None, "Cω ✓", "Lip ✓", "DC ✓"),
        ("tanh(x)", lambda x: np.tanh(x), None, "Cω ✓", "Lip ✓", "DC ✓"),
        ("eˣ", lambda x: np.exp(x), False, "Cω ✓", "Lip ✗", "—"),
        ("x²", lambda x: x**2, False, "Cω ✓", "Lip ✗", "—"),
        ("sin(x)", lambda x: np.sin(x), False, "Cω ✓", "Lip ✓", "DC ✗"),
        ("cos(x)", lambda x: np.cos(x), False, "Cω ✓", "Lip ✓", "DC ✗"),
        ("|x|", lambda x: np.abs(x), False, "Cω ✗", "Lip ✓", "—"),
    ]

    x = np.linspace(-4, 4, 500)

    for i, (name, f, in_sheffer, b1, b2, b3) in enumerate(functions):
        ax = fig.add_subplot(3, 4, i + 1)
        y = f(x)
        color = 'green' if in_sheffer == True else ('red' if in_sheffer == False else 'orange')
        ax.plot(x, y, color=color, linewidth=2)
        status = "✓" if in_sheffer == True else ("✗" if in_sheffer == False else "?")
        ax.set_title(f"{name} [{status}]", fontsize=11, fontweight='bold',
                     color=color)
        ax.text(0.02, 0.98, f"{b1}\n{b2}\n{b3}",
                transform=ax.transAxes, fontsize=7, va='top',
                bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.5))
        ax.grid(True, alpha=0.3)
        ax.set_xlim(-4, 4)

    # Add legend
    ax = fig.add_subplot(3, 4, 11)
    ax.axis('off')
    legend_text = (
        "Sheffer Algebra Barriers\n"
        "━━━━━━━━━━━━━━━━━━━━━\n"
        "🟢 In ShefferAlg\n"
        "🔴 NOT in ShefferAlg\n"
        "🟠 Unknown (Q36/Q38)\n\n"
        "Barrier 1: Cω (analytic)\n"
        "Barrier 2: Lip (Lipschitz)\n"
        "Barrier 3: DC (deriv conv.)\n"
        "Barrier 4: Asymptotic\n"
        "          linear structure"
    )
    ax.text(0.1, 0.95, legend_text, transform=ax.transAxes,
            fontsize=10, va='top', fontfamily='monospace',
            bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))

    ax = fig.add_subplot(3, 4, 12)
    ax.axis('off')
    result_text = (
        "Key Results (v7)\n"
        "━━━━━━━━━━━━━━━━\n"
        "• σⁿ(x) = log(n + eˣ)\n"
        "• sin, cos ∉ ShefferAlg\n"
        "• ∀ (a,b) ∈ ℝ²:\n"
        "  ∃ f ∈ ShefferAlg with\n"
        "  f'→a at +∞, f'→b at −∞\n"
        "• tanh ∈ S ⟺ S ∈ S\n"
        "• log(S(x)) ∈ ShefferAlg\n"
        "• Bounded non-constant\n"
        "  functions exist in S"
    )
    ax.text(0.1, 0.95, result_text, transform=ax.transAxes,
            fontsize=10, va='top', fontfamily='monospace',
            bbox=dict(boxstyle='round', facecolor='lightcyan', alpha=0.8))

    plt.suptitle("The Sheffer Algebra: A Complete Barrier Analysis",
                 fontsize=16, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig('fig7_sheffer_landscape.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Generated fig7_sheffer_landscape.png")


# ─── Figure 8: Approximation Demo ───

def plot_approximation_demo():
    """Demonstrate approximating target functions with Sheffer expressions."""
    fig, axes = plt.subplots(1, 3, figsize=(16, 5))

    x = np.linspace(-5, 5, 1000)

    # Panel 1: Approximating sigmoid with σ differences
    ax = axes[0]
    ax.set_title("Approximating Sigmoid", fontsize=13, fontweight='bold')
    ax.plot(x, sigmoid(x), 'r-', linewidth=3, alpha=0.5, label='S(x) (target)')
    # Best affine combination attempt
    # σ(x) - σ(x+c) goes from 0 to -c, rescale:
    for c in [0.5, 1, 2, 4]:
        approx = (softplus(x) - softplus(x + c)) / (-c)
        ax.plot(x, approx, '--', linewidth=1.5, label=f'(σ(x)−σ(x+{c}))/−{c}')
    ax.legend(fontsize=8)
    ax.grid(True, alpha=0.3)

    # Panel 2: Approximating step function
    ax = axes[1]
    ax.set_title("Sheffer Smoothing of Step", fontsize=13, fontweight='bold')
    step = np.heaviside(x, 0.5)
    ax.plot(x, step, 'k-', linewidth=2, alpha=0.3, label='Step function')
    for temp in [0.2, 0.5, 1, 2, 5]:
        ax.plot(x, sigmoid(x / temp), linewidth=1.5, label=f'S(x/{temp})')
    ax.legend(fontsize=8)
    ax.grid(True, alpha=0.3)

    # Panel 3: Temperature-parameterized softplus
    ax = axes[2]
    ax.set_title("Temperature Softplus: σ_T(x) = T·σ(x/T)", fontsize=13, fontweight='bold')
    relu = np.maximum(x, 0)
    ax.plot(x, relu, 'k-', linewidth=2, alpha=0.3, label='ReLU (T→0)')
    for T in [0.2, 0.5, 1, 2, 5]:
        ax.plot(x, T * softplus(x / T), linewidth=1.5, label=f'T = {T}')
    ax.legend(fontsize=8)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('fig8_approximation_demo.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Generated fig8_approximation_demo.png")


# ─── Main ───

if __name__ == '__main__':
    print("=" * 60)
    print("Sheffer Algebra Visualization Suite (v7)")
    print("=" * 60)
    print()

    plot_three_barriers()
    plot_iterated_softplus()
    plot_derivative_limit_pairs()
    plot_bounded_sheffer()
    plot_sigmoid_tanh()
    plot_growth_decomposition()
    plot_sheffer_landscape()
    plot_approximation_demo()

    print()
    print("=" * 60)
    print("All figures generated successfully!")
    print("=" * 60)
