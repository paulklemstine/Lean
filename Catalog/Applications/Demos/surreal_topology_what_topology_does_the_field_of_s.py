"""
Surreal Topology Demonstrations

Demonstrates the key mathematical concepts from the surreal topology research:
1. Dedekind gaps in the rationals (showing disconnection)
2. Linear path parametrization of intervals
3. Tameness verification for real numbers
4. Cofinality sequences
"""

import math


def demonstrate_rational_gap():
    """Demonstrate a Dedekind gap in the rationals at sqrt(2).
    
    The rationals Q have a gap at sqrt(2): the sets 
    L = {q in Q : q < sqrt(2)} and U = {q in Q : q > sqrt(2)}
    form a Dedekind gap (L has no max, U has no min).
    """
    print("=" * 60)
    print("1. DEDEKIND GAP IN THE RATIONALS AT sqrt(2)")
    print("=" * 60)
    
    sqrt2 = math.sqrt(2)
    print(f"\nsqrt(2) ≈ {sqrt2:.15f}")
    
    # Show that L has no maximum: for any rational q < sqrt(2),
    # there exists a rational q' with q < q' < sqrt(2)
    print("\nShowing L = {q ∈ Q : q < √2} has no maximum:")
    q = 1.0  # Start with q = 1
    for i in range(8):
        q_next = (q + sqrt2) / 2  # Midpoint (rational approx)
        print(f"  q = {q:.10f} < q' = {q_next:.10f} < √2 = {sqrt2:.10f}")
        q = q_next
    
    # Show U has no minimum similarly
    print("\nShowing U = {q ∈ Q : q > √2} has no minimum:")
    q = 2.0
    for i in range(8):
        q_next = (q + sqrt2) / 2
        print(f"  √2 = {sqrt2:.10f} < q' = {q_next:.10f} < q = {q:.10f}")
        q = q_next
    
    print("\n→ This gap makes Q DISCONNECTED in the order topology.")
    print("  L and U are both open sets that partition Q.")


def demonstrate_linear_path():
    """Demonstrate the linear path t ↦ (1-t)*a + t*b mapping [0,1] to [a,b]."""
    print("\n" + "=" * 60)
    print("2. LINEAR PATH PARAMETRIZATION")
    print("=" * 60)
    
    a, b = 3.0, 7.0
    print(f"\nLinear path from a={a} to b={b}: f(t) = (1-t)·{a} + t·{b}")
    print(f"  f(0) = {(1-0)*a + 0*b} = a ✓")
    print(f"  f(1) = {(1-1)*a + 1*b} = b ✓")
    
    print("\nPath values (monotone increasing):")
    for t in [0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0]:
        val = (1 - t) * a + t * b
        bar = "█" * int(val * 3)
        print(f"  t = {t:.1f} → f(t) = {val:.1f}  {bar}")
    
    print(f"\n→ f is continuous, monotone, and f([0,1]) = [{a}, {b}]")
    print("  This proves ℝ is path-connected.")


def demonstrate_tameness():
    """Demonstrate that all points of ℝ are tame."""
    print("\n" + "=" * 60)
    print("3. TAMENESS OF REAL NUMBERS")
    print("=" * 60)
    
    x = math.pi
    print(f"\nPoint x = π ≈ {x:.10f}")
    
    # Left cofinal sequence: x - 1/(n+1)
    print("\nLeft cofinal sequence: a_n = x - 1/(n+1)")
    for n in range(10):
        a_n = x - 1.0 / (n + 1)
        print(f"  a_{n} = {a_n:.10f} < π")
    print("  ... → π from below")
    
    # Right coinitial sequence: x + 1/(n+1)
    print("\nRight coinitial sequence: b_n = x + 1/(n+1)")
    for n in range(10):
        b_n = x + 1.0 / (n + 1)
        print(f"  b_{n} = {b_n:.10f} > π")
    print("  ... → π from above")
    
    # Verify cofinality property
    y = x - 0.001  # A point just below π
    print(f"\nCofinality check: y = {y:.10f} < π")
    for n in range(1000):
        if x - 1.0 / (n + 1) >= y:
            print(f"  Found a_{n} = {x - 1.0/(n+1):.10f} ≥ y ✓")
            break
    
    print("\n→ π is TAME: it has countable cofinality from both sides.")
    print("  Therefore 𝓝(π) is countably generated (first-countable).")


def demonstrate_cofinality_spectrum():
    """Demonstrate the cofinality spectrum concept."""
    print("\n" + "=" * 60)
    print("4. COFINALITY SPECTRUM")
    print("=" * 60)
    
    print("\nIn ℝ: every point has cofinality (ℵ₀, ℵ₀) — all points are tame.")
    print("In the surreals No:")
    print("  • Finite surreals: cofinality (ℵ₀, ℵ₀) — tame, like ℝ")
    print("  • ω (first infinite ordinal): cofinality (ℵ₀, ?) — ")
    print("    approachable from below by 0, 1, 2, ...")
    print("  • ω₁ (first uncountable ordinal): cofinality (ℵ₁, ?) — ")
    print("    NOT approachable from below by any countable sequence!")
    print("  • 1/ω (first infinitesimal): lies in a gap")
    print()
    print("The cofinality spectrum classifies points into:")
    print("  TAME = (ℵ₀, ℵ₀) → first-countable neighborhoods")
    print("  WILD = (κ, λ) with κ or λ > ℵ₀ → non-first-countable")
    print()
    print("Key Theorem: A dense linear order is CONNECTED iff")
    print("             it has NO Dedekind gaps.")
    print("             This is equivalent to Dedekind completeness")
    print("             for dense orders without endpoints.")


def main():
    """Run all demonstrations."""
    print("╔══════════════════════════════════════════════════════════╗")
    print("║     SURREAL TOPOLOGY: The Shape of Infinite Numbers     ║")
    print("╚══════════════════════════════════════════════════════════╝")
    
    demonstrate_rational_gap()
    demonstrate_linear_path()
    demonstrate_tameness()
    demonstrate_cofinality_spectrum()
    
    print("\n" + "=" * 60)
    print("SUMMARY OF VERIFIED RESULTS")
    print("=" * 60)
    print("1. Dedekind gaps ⟹ disconnected order topology")
    print("2. Conditionally complete + dense ⟹ connected")
    print("3. Conditionally complete + dense ⟹ no gaps")
    print("4. Tame points ⟹ countably generated neighborhoods")
    print("5. All points of ℝ are tame")
    print("6. Linear paths parametrize intervals: f([0,1]) = [a,b]")
    print("7. ℝ is path-connected via linear interpolation")


if __name__ == "__main__":
    main()


"""
Visualization: Dedekind Gaps and Connectedness in Ordered Spaces

Generates a figure showing:
1. A Dedekind gap in the rationals at sqrt(2)
2. The clopen partition created by the gap
3. Linear path parametrization of an interval
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def plot_dedekind_gap():
    """Plot the Dedekind gap at sqrt(2) in the rationals."""
    fig, axes = plt.subplots(3, 1, figsize=(12, 10))
    
    # Panel 1: Dedekind gap at sqrt(2)
    ax = axes[0]
    ax.set_title("Dedekind Gap in ℚ at √2 ≈ 1.4142...", fontsize=14, fontweight='bold')
    
    sqrt2 = np.sqrt(2)
    
    # Plot rational points colored by which side of the gap they're on
    rationals_lower = [q/10 for q in range(-20, 15) if q/10 < sqrt2]
    rationals_upper = [q/10 for q in range(15, 40) if q/10 > sqrt2]
    
    ax.scatter(rationals_lower, [0]*len(rationals_lower), c='blue', s=30, 
               zorder=5, label='L = {q ∈ ℚ : q < √2}')
    ax.scatter(rationals_upper, [0]*len(rationals_upper), c='red', s=30, 
               zorder=5, label='U = {q ∈ ℚ : q > √2}')
    
    # Mark the gap
    ax.axvline(x=sqrt2, color='green', linestyle='--', linewidth=2, 
               label=f'Gap at √2 ≈ {sqrt2:.4f}')
    ax.annotate('GAP', xy=(sqrt2, 0), xytext=(sqrt2, 0.3),
                fontsize=16, fontweight='bold', color='green',
                ha='center', arrowprops=dict(arrowstyle='->', color='green'))
    
    ax.set_xlim(-2.5, 4)
    ax.set_ylim(-0.5, 0.5)
    ax.set_yticks([])
    ax.legend(loc='upper left', fontsize=10)
    ax.set_xlabel('ℚ (rational number line)')
    
    # Add clopen labels
    ax.fill_between([-2.5, sqrt2-0.01], -0.15, 0.15, alpha=0.15, color='blue')
    ax.fill_between([sqrt2+0.01, 4], -0.15, 0.15, alpha=0.15, color='red')
    ax.text(-1, -0.35, 'OPEN & CLOSED', fontsize=10, color='blue', ha='center')
    ax.text(3, -0.35, 'OPEN & CLOSED', fontsize=10, color='red', ha='center')
    
    # Panel 2: ℝ fills the gap — connected
    ax = axes[1]
    ax.set_title("ℝ Fills All Gaps → Connected (No Clopen Partition)", 
                 fontsize=14, fontweight='bold')
    
    x = np.linspace(-2.5, 4, 1000)
    ax.plot(x, np.zeros_like(x), 'purple', linewidth=3)
    ax.scatter([sqrt2], [0], c='green', s=100, zorder=5, marker='*',
               label=f'√2 ∈ ℝ fills the gap')
    ax.fill_between(x, -0.15, 0.15, alpha=0.1, color='purple')
    
    ax.set_xlim(-2.5, 4)
    ax.set_ylim(-0.5, 0.5)
    ax.set_yticks([])
    ax.legend(loc='upper left', fontsize=10)
    ax.set_xlabel('ℝ (real number line) — no gaps, CONNECTED')
    ax.text(0.5, -0.35, 'One connected piece — no nontrivial clopen sets', 
            fontsize=10, color='purple', ha='center')
    
    # Panel 3: Linear path
    ax = axes[2]
    ax.set_title("Linear Path: f(t) = (1-t)·a + t·b maps [0,1] → [a,b]", 
                 fontsize=14, fontweight='bold')
    
    a_val, b_val = 2.0, 6.0
    t = np.linspace(0, 1, 100)
    f_t = (1 - t) * a_val + t * b_val
    
    ax.plot(t, f_t, 'darkgreen', linewidth=3, label='f(t) = (1-t)·2 + t·6')
    ax.scatter([0, 1], [a_val, b_val], c='red', s=100, zorder=5)
    ax.annotate(f'f(0) = a = {a_val}', xy=(0, a_val), xytext=(0.1, a_val-0.5),
                fontsize=11, arrowprops=dict(arrowstyle='->'))
    ax.annotate(f'f(1) = b = {b_val}', xy=(1, b_val), xytext=(0.7, b_val+0.5),
                fontsize=11, arrowprops=dict(arrowstyle='->'))
    
    # Show monotonicity
    ax.fill_between(t, a_val, f_t, alpha=0.1, color='green')
    ax.set_xlabel('Parameter t ∈ [0, 1]')
    ax.set_ylabel('f(t)')
    ax.legend(fontsize=10)
    ax.text(0.5, 3, 'Monotone ↗ (since a ≤ b)\nContinuous\nSurjective onto [a,b]',
            fontsize=10, ha='center', bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.8))
    
    plt.tight_layout()
    plt.savefig('surreal_topology_gaps.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: surreal_topology_gaps.png")


def plot_cofinality_spectrum():
    """Plot the cofinality spectrum concept."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 6))
    ax.set_title("Cofinality Spectrum: Tame vs Wild Points", 
                 fontsize=14, fontweight='bold')
    
    # Draw the number line with different point types
    x_tame = np.linspace(-3, 3, 20)
    ax.scatter(x_tame, np.zeros_like(x_tame), c='blue', s=40, zorder=5,
               label='Tame (ℵ₀, ℵ₀) — like ℝ')
    
    # Mark some "wild" points
    wild_points = [4, 5, 6]
    ax.scatter(wild_points, [0]*3, c='red', s=80, marker='D', zorder=5,
               label='Wild (ℵ₁, ℵ₀) — surreal-like')
    
    # Draw convergent sequences for a tame point
    x0 = 1.0
    n_terms = 8
    left_seq = [x0 - 1/(n+1) for n in range(n_terms)]
    right_seq = [x0 + 1/(n+1) for n in range(n_terms)]
    
    for i, (l, r) in enumerate(zip(left_seq, right_seq)):
        alpha = 0.3 + 0.7 * i / n_terms
        ax.plot([l, l], [-0.05, 0.05], 'b-', alpha=alpha)
        ax.plot([r, r], [-0.05, 0.05], 'b-', alpha=alpha)
    
    ax.annotate('Tame: sequences\nconverge from both sides', 
                xy=(x0, 0), xytext=(x0, 0.4),
                fontsize=10, ha='center',
                arrowprops=dict(arrowstyle='->', color='blue'))
    
    # Show that wild point can't be approached
    ax.annotate('Wild: NO countable\nsequence converges\nfrom left', 
                xy=(4, 0), xytext=(4.5, 0.4),
                fontsize=10, ha='center', color='red',
                arrowprops=dict(arrowstyle='->', color='red'))
    
    ax.set_xlim(-4, 7.5)
    ax.set_ylim(-0.6, 0.8)
    ax.set_yticks([])
    ax.axhline(y=0, color='gray', linewidth=0.5)
    ax.legend(loc='upper left', fontsize=10)
    ax.set_xlabel('Ordered space α')
    
    # Add theorem box
    textstr = ('Theorem: Tame ⟹ 𝓝(x) countably generated\n'
               'Theorem: All points of ℝ are tame\n'
               'Conjecture: Cofinality pair is a complete local invariant')
    props = dict(boxstyle='round', facecolor='lightyellow', alpha=0.8)
    ax.text(0.98, 0.95, textstr, transform=ax.transAxes, fontsize=9,
            verticalalignment='top', horizontalalignment='right', bbox=props)
    
    plt.tight_layout()
    plt.savefig('cofinality_spectrum.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: cofinality_spectrum.png")


if __name__ == "__main__":
    plot_dedekind_gap()
    plot_cofinality_spectrum()
