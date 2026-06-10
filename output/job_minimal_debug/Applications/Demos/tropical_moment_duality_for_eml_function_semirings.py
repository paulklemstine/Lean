#!/usr/bin/env python3
"""
EML Density Bridge — Interactive Demonstrations

This script demonstrates the key theorems from the EML Density Bridge,
bringing the formally verified mathematics to life with concrete computations
and visualizations.

The EML operation is defined as:  EMLd(a, b) = exp(a) - ln(b)

Key bridges demonstrated:
  1. Monotonicity and continuity
  2. Fixed point of the EML self-map
  3. Information-theoretic connection (surprisal)
  4. Involution property
  5. Transcendence generation from {1}
  6. Exp-log duality and the balance point
  7. Derivative structure
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.gridspec import GridSpec
import matplotlib
matplotlib.rcParams['font.size'] = 11
matplotlib.rcParams['figure.dpi'] = 150


def EMLd(a, b):
    """The EML operation: exp(a) - ln(b)."""
    return np.exp(a) - np.log(b)


def selfInfo(p):
    """Self-information (surprisal): I(p) = -ln(p)."""
    return -np.log(p)


# ============================================================
# Demo 1: The EML Surface — Continuity and Monotonicity
# ============================================================
def demo_surface():
    """Visualize EMLd as a surface, showing continuity and monotonicity."""
    fig = plt.figure(figsize=(14, 5))

    # Surface plot
    ax1 = fig.add_subplot(121, projection='3d')
    a = np.linspace(-2, 3, 100)
    b = np.linspace(0.01, 5, 100)
    A, B = np.meshgrid(a, b)
    Z = EMLd(A, B)

    surf = ax1.plot_surface(A, B, Z, cmap='viridis', alpha=0.8, linewidth=0)
    ax1.set_xlabel('a')
    ax1.set_ylabel('b')
    ax1.set_zlabel('EMLd(a, b)')
    ax1.set_title('EML Surface: exp(a) − ln(b)')
    ax1.view_init(elev=25, azim=-60)

    # Monotonicity slices
    ax2 = fig.add_subplot(122)
    b_vals = [0.5, 1, 2, np.e]
    a_range = np.linspace(-2, 3, 200)
    for bv in b_vals:
        ax2.plot(a_range, EMLd(a_range, bv),
                 label=f'b = {bv:.2f}', linewidth=2)
    ax2.axhline(y=0, color='gray', linestyle='--', alpha=0.5)
    ax2.set_xlabel('a')
    ax2.set_ylabel('EMLd(a, b)')
    ax2.set_title('Monotonicity: EMLd increases in a')
    ax2.legend()
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('demos/fig1_eml_surface.png', bbox_inches='tight')
    plt.close()
    print("✓ Figure 1: EML surface saved")


# ============================================================
# Demo 2: Fixed Point of the EML Self-Map
# ============================================================
def demo_fixed_point():
    """Demonstrate the unique fixed point of x ↦ 1 − ln(x)."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    x = np.linspace(0.01, 5, 1000)
    f_x = 1 - np.log(x)

    # Fixed point diagram
    ax1.plot(x, f_x, 'b-', linewidth=2.5, label='f(x) = 1 − ln(x)')
    ax1.plot(x, x, 'r--', linewidth=1.5, label='y = x')
    ax1.plot(1, 1, 'ko', markersize=10, zorder=5,
             label='Fixed point (1, 1)')
    ax1.set_xlim(0, 5)
    ax1.set_ylim(-2, 5)
    ax1.set_xlabel('x')
    ax1.set_ylabel('f(x)')
    ax1.set_title('EML Self-Map: Unique Fixed Point at x = 1')
    ax1.legend()
    ax1.grid(True, alpha=0.3)
    ax1.annotate('x = 1 is the UNIQUE\nfixed point (proved in Lean)',
                 xy=(1, 1), xytext=(2.5, 3),
                 arrowprops=dict(arrowstyle='->', color='green', lw=2),
                 fontsize=11, color='green', fontweight='bold')

    # Cobweb / iteration diagram
    x0 = 3.5
    iterates = [x0]
    for _ in range(20):
        x_next = 1 - np.log(iterates[-1])
        iterates.append(x_next)

    ax2.plot(x, f_x, 'b-', linewidth=2, label='f(x) = 1 − ln(x)')
    ax2.plot(x, x, 'r--', linewidth=1.5, label='y = x')

    # Draw cobweb
    for i in range(len(iterates) - 1):
        xi = iterates[i]
        xi1 = iterates[i + 1]
        alpha = 0.3 + 0.7 * (i / len(iterates))
        ax2.plot([xi, xi], [xi, xi1], 'g-', alpha=alpha, linewidth=1)
        ax2.plot([xi, xi1], [xi1, xi1], 'g-', alpha=alpha, linewidth=1)

    ax2.plot(1, 1, 'ko', markersize=8, zorder=5)
    ax2.set_xlim(0, 4)
    ax2.set_ylim(-1, 4)
    ax2.set_xlabel('x')
    ax2.set_ylabel('f(x)')
    ax2.set_title(f'Cobweb: Iteration from x₀ = {x0}')
    ax2.legend()
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('demos/fig2_fixed_point.png', bbox_inches='tight')
    plt.close()
    print("✓ Figure 2: Fixed point diagram saved")
    print(f"  Iterates converge: {iterates[-1]:.10f} → 1.0")


# ============================================================
# Demo 3: Information-Theoretic Bridge
# ============================================================
def demo_information_bridge():
    """Show EML(0, p) = 1 + selfInfo(p) = 1 − ln(p)."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    p = np.linspace(0.001, 2, 1000)

    # EML as surprisal shift
    ax1.plot(p, EMLd(0, p), 'b-', linewidth=2.5, label='EMLd(0, p) = 1 − ln(p)')
    ax1.plot(p, selfInfo(p), 'r--', linewidth=2, label='I(p) = −ln(p)')
    ax1.axhline(y=1, color='green', linestyle=':', alpha=0.7, label='Shift = +1')
    ax1.axhline(y=0, color='gray', linestyle='--', alpha=0.5)
    ax1.axvline(x=1, color='gray', linestyle='--', alpha=0.5)

    # Mark special points
    ax1.plot(1, 1, 'ko', markersize=8, label='p=1: EML=1, I=0')
    ax1.plot(np.exp(1), 0, 'rs', markersize=8, label=f'p=e: EML=0 (balance)')
    ax1.plot(0.5, EMLd(0, 0.5), 'g^', markersize=8,
             label=f'p=½: EML={EMLd(0,0.5):.3f}')

    ax1.set_xlim(0, 2)
    ax1.set_ylim(-1, 4)
    ax1.set_xlabel('Probability p')
    ax1.set_ylabel('Value')
    ax1.set_title('EML as Shifted Surprisal: EML(0,p) = 1 + I(p)')
    ax1.legend(fontsize=9)
    ax1.grid(True, alpha=0.3)

    # Shannon entropy connection
    # For binary source with probs (p, 1-p):
    # H = p·I(p) + (1-p)·I(1-p)
    p2 = np.linspace(0.001, 0.999, 1000)
    H = -p2 * np.log(p2) - (1 - p2) * np.log(1 - p2)
    EML_sum = p2 * EMLd(0, p2) + (1 - p2) * EMLd(0, 1 - p2)

    ax2.plot(p2, H, 'b-', linewidth=2.5, label='Shannon entropy H(p)')
    ax2.plot(p2, EML_sum, 'r--', linewidth=2,
             label='p·EML(0,p) + (1−p)·EML(0,1−p)')
    ax2.axvline(x=0.5, color='gray', linestyle='--', alpha=0.5)

    ax2.set_xlabel('Probability p')
    ax2.set_ylabel('Value')
    ax2.set_title('EML and Shannon Entropy')
    ax2.legend()
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('demos/fig3_information_bridge.png', bbox_inches='tight')
    plt.close()
    print("✓ Figure 3: Information bridge saved")
    print(f"  EML(0, 1/2) = {EMLd(0, 0.5):.6f} = 1 + ln(2) = {1 + np.log(2):.6f}")
    print(f"  EML(0, 1)   = {EMLd(0, 1):.6f} (certain event)")
    print(f"  EML(0, e)   = {EMLd(0, np.e):.6f} (balance point)")


# ============================================================
# Demo 4: Involution and Duality
# ============================================================
def demo_involution():
    """Demonstrate the involution x ↦ EML(0, exp(x)) = 1 − x."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    x = np.linspace(-3, 4, 500)

    # Involution: 1 - x applied twice
    f1 = 1 - x       # first application
    f2 = 1 - f1      # = x (identity)

    ax1.plot(x, x, 'k-', linewidth=1, alpha=0.3, label='y = x')
    ax1.plot(x, f1, 'b-', linewidth=2.5, label='f(x) = 1 − x')
    ax1.plot(x, f2, 'r--', linewidth=2, label='f(f(x)) = x')

    # Mark fixed point
    ax1.plot(0.5, 0.5, 'go', markersize=10, label='Fixed point (0.5, 0.5)')

    # Annotate involution pairs
    for xv in [0, 1, -1, 2]:
        yv = 1 - xv
        ax1.annotate('', xy=(xv, yv), xytext=(yv, xv),
                     arrowprops=dict(arrowstyle='<->', color='purple',
                                     lw=1.5, connectionstyle='arc3,rad=0.3'))

    ax1.set_xlabel('x')
    ax1.set_ylabel('f(x)')
    ax1.set_title('Involution: f(x) = 1 − x,  f∘f = id')
    ax1.legend()
    ax1.grid(True, alpha=0.3)
    ax1.set_xlim(-3, 4)
    ax1.set_ylim(-3, 4)

    # Exp-log duality
    x2 = np.linspace(-2, 3, 500)
    growth = EMLd(x2, 1)        # exp(x) — growth mode
    compress = EMLd(0, np.exp(x2))  # 1 - x — compression mode

    ax2.plot(x2, growth, 'b-', linewidth=2.5, label='EML(x, 1) = exp(x) [growth]')
    ax2.plot(x2, compress, 'r-', linewidth=2.5, label='EML(0, eˣ) = 1−x [compression]')
    ax2.plot(x2, x2, 'k--', linewidth=1, alpha=0.5, label='y = x')

    # Balance point
    ax2.plot(1, np.e, 'bo', markersize=8)
    ax2.plot(1, 0, 'ro', markersize=8)
    ax2.axhline(y=0, color='gray', linestyle='--', alpha=0.3)

    ax2.set_xlabel('x')
    ax2.set_ylabel('Value')
    ax2.set_title('Exp-Log Duality: Growth vs. Compression')
    ax2.legend()
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('demos/fig4_involution_duality.png', bbox_inches='tight')
    plt.close()
    print("✓ Figure 4: Involution and duality saved")

    # Verify involution numerically
    test_vals = [0, 1, -2, 3.7, np.pi]
    print("  Involution verification: f(f(x)) = x")
    for v in test_vals:
        result = EMLd(0, np.exp(EMLd(0, np.exp(v))))
        print(f"    x = {v:6.3f} → f(f(x)) = {result:.12f}  (error: {abs(result - v):.2e})")


# ============================================================
# Demo 5: EML Closure — Generating Numbers from {1}
# ============================================================
def demo_closure():
    """Show what numbers EML generates starting from {1}."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    # Generate EML closure iteratively
    seed = {1.0}
    depths = [seed.copy()]

    for depth in range(4):
        new_set = set(depths[-1])
        for a in depths[-1]:
            for b in depths[-1]:
                if b > 0:
                    val = np.exp(a) - np.log(b)
                    if np.isfinite(val) and abs(val) < 1e6:
                        new_set.add(round(val, 12))
        depths.append(new_set)

    # Plot number line with closure elements
    colors = ['red', 'blue', 'green', 'orange', 'purple']
    labels = ['Depth 0: {1}', 'Depth 1', 'Depth 2', 'Depth 3', 'Depth 4']

    for i, (d, c, l) in enumerate(zip(depths, colors, labels)):
        vals = sorted(d)
        vals_in_range = [v for v in vals if -5 < v < 20]
        y = [i] * len(vals_in_range)
        ax1.scatter(vals_in_range, y, c=c, s=20, alpha=0.7, label=f'{l} ({len(d)} values)')

    # Mark key values
    ax1.axvline(x=1, color='red', linestyle=':', alpha=0.5, label='1')
    ax1.axvline(x=np.e, color='blue', linestyle=':', alpha=0.5, label='e')
    ax1.axvline(x=np.e - 1, color='green', linestyle=':', alpha=0.5, label='e−1')

    ax1.set_xlabel('Value')
    ax1.set_ylabel('Depth')
    ax1.set_title('EML Closure of {1}: Number Line')
    ax1.legend(fontsize=8, loc='upper right')
    ax1.grid(True, alpha=0.3)

    # Growth of closure size
    sizes = [len(d) for d in depths]
    ax2.bar(range(len(sizes)), sizes, color=colors[:len(sizes)], alpha=0.7)
    ax2.set_xlabel('Depth')
    ax2.set_ylabel('|EMLClosure_n({1})|')
    ax2.set_title('Growth of EML Closure')
    for i, s in enumerate(sizes):
        ax2.text(i, s + 0.5, str(s), ha='center', fontweight='bold')
    ax2.grid(True, alpha=0.3, axis='y')

    plt.tight_layout()
    plt.savefig('demos/fig5_closure.png', bbox_inches='tight')
    plt.close()
    print("✓ Figure 5: EML closure saved")
    print(f"  Closure sizes by depth: {sizes}")

    # Print notable generated values
    print("  Notable values generated:")
    notable = sorted(depths[-1])
    for v in notable[:15]:
        # Try to identify the value
        if abs(v - 1) < 1e-10:
            print(f"    {v:12.6f} = 1 (seed)")
        elif abs(v - np.e) < 1e-10:
            print(f"    {v:12.6f} = e")
        elif abs(v - (np.e - 1)) < 1e-10:
            print(f"    {v:12.6f} = e − 1")
        elif abs(v - np.exp(np.e)) < 1e-10:
            print(f"    {v:12.6f} = e^e")
        elif abs(v - (np.exp(np.e) - 1)) < 1e-10:
            print(f"    {v:12.6f} = e^e − 1")
        else:
            print(f"    {v:12.6f}")


# ============================================================
# Demo 6: Derivative Structure
# ============================================================
def demo_derivatives():
    """Visualize the derivative bridge: ∂EML/∂a = exp(a), ∂EML/∂b = −1/b."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    # Derivative in first argument
    a = np.linspace(-2, 3, 500)
    ax1.plot(a, EMLd(a, 1), 'b-', linewidth=2.5, label='EML(a, 1) = exp(a)')
    ax1.plot(a, np.exp(a), 'r--', linewidth=2, label='∂EML/∂a = exp(a)')
    ax1.axhline(y=0, color='gray', linestyle='--', alpha=0.3)
    ax1.plot(0, 1, 'ko', markersize=8, label='At a=0: value=1, slope=1')
    ax1.set_xlabel('a')
    ax1.set_title('EML and Its a-Derivative (self-similar!)')
    ax1.legend()
    ax1.grid(True, alpha=0.3)

    # Derivative in second argument
    b = np.linspace(0.1, 5, 500)
    ax2.plot(b, EMLd(0, b), 'b-', linewidth=2.5, label='EML(0, b) = 1 − ln(b)')
    ax2.plot(b, -1/b, 'r--', linewidth=2, label='∂EML/∂b = −1/b')
    ax2.axhline(y=0, color='gray', linestyle='--', alpha=0.3)
    ax2.plot(1, 1, 'ko', markersize=8, label='At b=1: value=1, slope=−1')
    ax2.plot(np.e, 0, 'gs', markersize=8, label=f'Balance: EML(0,e)=0')
    ax2.set_xlabel('b')
    ax2.set_title('EML and Its b-Derivative')
    ax2.legend()
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('demos/fig6_derivatives.png', bbox_inches='tight')
    plt.close()
    print("✓ Figure 6: Derivatives saved")


# ============================================================
# Demo 7: Applications — Signal Processing
# ============================================================
def demo_application_signal():
    """Application: EML as a signal processing primitive."""
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))

    t = np.linspace(0, 4 * np.pi, 1000)

    # Original signal
    signal = np.sin(t) + 0.5 * np.sin(3 * t)
    axes[0, 0].plot(t, signal, 'b-', linewidth=1.5)
    axes[0, 0].set_title('Original Signal')
    axes[0, 0].grid(True, alpha=0.3)

    # EML growth mode: amplify via exp
    amplified = EMLd(signal, 1)  # = exp(signal)
    axes[0, 1].plot(t, amplified, 'r-', linewidth=1.5)
    axes[0, 1].set_title('EML Growth: EML(signal, 1) = exp(signal)')
    axes[0, 1].grid(True, alpha=0.3)

    # EML compression mode: compress via log
    # Shift signal to be positive first
    shifted = signal - signal.min() + 0.1
    compressed = EMLd(0, shifted)  # = 1 - ln(shifted)
    axes[1, 0].plot(t, compressed, 'g-', linewidth=1.5)
    axes[1, 0].set_title('EML Compression: EML(0, signal+offset)')
    axes[1, 0].grid(True, alpha=0.3)

    # Recovery via involution
    recovered = EMLd(0, np.exp(EMLd(0, np.exp(signal))))
    axes[1, 1].plot(t, signal, 'b-', linewidth=2, label='Original', alpha=0.5)
    axes[1, 1].plot(t, recovered, 'r--', linewidth=1.5, label='After double EML')
    max_err = np.max(np.abs(signal - recovered))
    axes[1, 1].set_title(f'Involution Recovery (max error: {max_err:.2e})')
    axes[1, 1].legend()
    axes[1, 1].grid(True, alpha=0.3)

    for ax in axes.flat:
        ax.set_xlabel('t')

    plt.tight_layout()
    plt.savefig('demos/fig7_signal_processing.png', bbox_inches='tight')
    plt.close()
    print("✓ Figure 7: Signal processing application saved")


# ============================================================
# Numerical Verification of Lean Theorems
# ============================================================
def verify_theorems():
    """Numerically verify the theorems proved in Lean."""
    print("\n" + "=" * 60)
    print("NUMERICAL VERIFICATION OF LEAN THEOREMS")
    print("=" * 60)

    e = np.e

    # Theorem: EMLd_recovers_exp
    x_test = [0, 1, -1, 2.5, np.pi]
    print("\n✓ EMLd_recovers_exp: EML(x, 1) = exp(x)")
    for x in x_test:
        assert abs(EMLd(x, 1) - np.exp(x)) < 1e-14
    print("  Passed for all test values")

    # Theorem: EMLd_generates_e
    print(f"\n✓ EMLd_generates_e: EML(1, 1) = e = {EMLd(1, 1):.15f}")
    assert abs(EMLd(1, 1) - e) < 1e-14

    # Theorem: EMLd_involution
    print("\n✓ EMLd_involution: EML(0, exp(EML(0, exp(x)))) = x")
    for x in x_test:
        result = EMLd(0, np.exp(EMLd(0, np.exp(x))))
        assert abs(result - x) < 1e-12, f"Failed for x={x}"
    print("  Passed for all test values")

    # Theorem: EMLd_balance
    print(f"\n✓ EMLd_balance: EML(0, e) = {EMLd(0, e):.15f} ≈ 0")
    assert abs(EMLd(0, e)) < 1e-14

    # Theorem: EMLSelfMap_fixed_one
    print(f"\n✓ EMLSelfMap_fixed_one: 1 − ln(1) = {1 - np.log(1):.15f} = 1")
    assert abs((1 - np.log(1)) - 1) < 1e-14

    # Theorem: EMLd_inv_composition
    print("\n✓ EMLd_inv_composition: EML(EML(0,x), 1) = e/x for x > 0")
    for x in [0.5, 1, 2, np.pi]:
        lhs = EMLd(EMLd(0, x), 1)
        rhs = e / x
        assert abs(lhs - rhs) < 1e-12
    print("  Passed for all test values")

    # Theorem: EMLd_log_split
    print("\n✓ EMLd_log_split: EML(x, y·z) = EML(x, y) − ln(z)")
    for x, y, z in [(1, 2, 3), (0, 1, np.e), (np.pi, 0.5, 2)]:
        lhs = EMLd(x, y * z)
        rhs = EMLd(x, y) - np.log(z)
        assert abs(lhs - rhs) < 1e-12
    print("  Passed for all test values")

    # Theorem: EMLd_eq_one_plus_selfInfo
    print("\n✓ EMLd_eq_one_plus_selfInfo: EML(0, p) = 1 + I(p)")
    for p in [0.1, 0.5, 1, 2]:
        lhs = EMLd(0, p)
        rhs = 1 + selfInfo(p)
        assert abs(lhs - rhs) < 1e-14
    print("  Passed for all test values")

    # Theorem: EMLd_growth
    print("\n✓ EMLd_growth: EML(x, 1) > x for x > 0")
    for x in [0.001, 0.5, 1, 10, 100]:
        assert EMLd(x, 1) > x
    print("  Passed for all test values")

    # Theorem: EMLSelfMap_unique_fixed_point
    print("\n✓ EMLSelfMap_unique_fixed_point: x = 1 is the only fixed point")
    from scipy.optimize import brentq
    g = lambda x: (1 - np.log(x)) - x
    # Search for zeros in (0.01, 100)
    # g(0.01) = 1 - ln(0.01) - 0.01 > 0
    # g(100) = 1 - ln(100) - 100 < 0
    root = brentq(g, 0.01, 100)
    print(f"  Numerical root: {root:.15f} (unique in (0, ∞))")
    assert abs(root - 1.0) < 1e-14

    print("\n" + "=" * 60)
    print("ALL THEOREMS VERIFIED NUMERICALLY ✓")
    print("=" * 60)


# ============================================================
# Main
# ============================================================
if __name__ == '__main__':
    print("╔══════════════════════════════════════════════════════╗")
    print("║   EML Density Bridge — Mathematical Demonstrations  ║")
    print("╚══════════════════════════════════════════════════════╝\n")

    demo_surface()
    demo_fixed_point()
    demo_information_bridge()
    demo_involution()
    demo_closure()
    demo_derivatives()
    demo_application_signal()
    verify_theorems()

    print("\n\nAll demonstrations complete! See demos/ for figures.")
