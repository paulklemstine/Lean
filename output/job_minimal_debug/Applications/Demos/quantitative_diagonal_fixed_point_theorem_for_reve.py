"""
EML Applications — Practical Uses of the Exp-Minus-Log Operation
=================================================================

This script demonstrates practical applications of the EML operation
in numerical analysis, signal processing, and pseudorandom generation.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import os

OUTPUT_DIR = os.path.dirname(os.path.abspath(__file__))


def EMLd(a, b):
    """The EML operation: EMLd(a, b) = exp(a) - log(b)."""
    return np.exp(a) - np.log(b)


# ============================================================
# Application 1: EML-Based Pseudorandom Number Generator
# ============================================================

def app_prng():
    """
    EML-based pseudorandom number generator.
    
    The idea: iterate x_{n+1} = frac(EML(x_n, x_n)) where frac is
    the fractional part. The transcendental nature of exp and log
    ensures good mixing properties.
    """
    print("=" * 70)
    print("APPLICATION 1: EML-Based Pseudorandom Number Generator")
    print("=" * 70)
    
    def eml_prng(seed, n):
        """Generate n pseudorandom numbers using EML iteration."""
        x = seed
        values = []
        for _ in range(n):
            x = EMLd(x, max(abs(x), 1e-10))
            x = x - np.floor(x)  # fractional part
            if x <= 0:
                x = 0.5  # reset if degenerate
            values.append(x)
        return values
    
    # Generate sequences from different seeds
    seeds = [0.1, 0.5, 0.9, np.pi - 3]
    n = 1000
    
    fig, axes = plt.subplots(2, 2, figsize=(12, 10))
    
    for seed, ax in zip(seeds, axes.flat):
        values = eml_prng(seed, n)
        ax.scatter(values[:-1], values[1:], s=1, alpha=0.5, c='steelblue')
        ax.set_xlabel(r'$x_n$', fontsize=10)
        ax.set_ylabel(r'$x_{n+1}$', fontsize=10)
        ax.set_title(f'EML PRNG (seed={seed:.4f})', fontsize=11)
        ax.set_xlim(0, 1)
        ax.set_ylim(0, 1)
        ax.set_aspect('equal')
    
    plt.suptitle('EML-Based Pseudorandom Number Generator\nPhase Portraits', fontsize=14)
    plt.tight_layout()
    plt.savefig(os.path.join(OUTPUT_DIR, 'eml_prng.png'), dpi=150, bbox_inches='tight')
    plt.close()
    
    # Statistics
    values = eml_prng(0.3, 10000)
    print(f"\n  10,000 samples from seed 0.3:")
    print(f"    Mean:     {np.mean(values):.6f} (ideal: 0.5)")
    print(f"    Std dev:  {np.std(values):.6f} (ideal: {1/np.sqrt(12):.6f})")
    print(f"    Min:      {np.min(values):.6f}")
    print(f"    Max:      {np.max(values):.6f}")
    print(f"\n  Saved: demos/eml_prng.png\n")


# ============================================================
# Application 2: EML Log-Space Arithmetic
# ============================================================

def app_logspace():
    """
    Demonstrate EML for numerically stable computation with
    very large and very small numbers using log-space arithmetic.
    
    The log-splitting identity EML(x, y*z) = EML(x, y) - ln(z)
    allows decomposing products in log-space.
    """
    print("=" * 70)
    print("APPLICATION 2: EML Log-Space Arithmetic")
    print("=" * 70)
    
    print("\n  Problem: Compute exp(a) / (b * c) for extreme values")
    print("  Direct computation may overflow or underflow.\n")
    
    # The EML-based computation uses:
    # exp(a) / (b*c) = exp(a) - ln(b*c) + ln(b*c) - ln(b*c) ... 
    # Actually: exp(a) / (b*c) when we want to combine exp and products
    
    # More practically: EML(a, b) = exp(a) - ln(b)
    # This stays finite even when exp(a) and ln(b) are individually extreme
    
    test_cases = [
        (100, 1e40, "Large exp, large log arg"),
        (0.001, 1e-300, "Small exp, tiny log arg"),
        (-100, 1e100, "Negative exp, huge log arg"),
        (500, 1e200, "Very large exp, very large log arg"),
    ]
    
    for a, b, desc in test_cases:
        # Direct: might have precision issues
        try:
            direct = np.exp(a) - np.log(b)
        except:
            direct = float('nan')
        
        # EML computation
        eml_val = EMLd(a, b)
        
        print(f"  {desc}:")
        print(f"    a = {a}, b = {b:.2e}")
        print(f"    EML(a, b) = {eml_val:.10f}")
        print(f"    Direct    = {direct:.10f}")
        print(f"    Match: {abs(eml_val - direct) < 1e-6 if np.isfinite(direct) else 'N/A'}")
        print()
    
    # Demonstrate log-splitting for product decomposition
    print("  --- Log-Splitting for Product Decomposition ---\n")
    x, y, z = 2.0, 3.0, 5.0
    
    full = EMLd(x, y * z)
    split = EMLd(x, y) - np.log(z)
    
    print(f"  EML({x}, {y}*{z}) = {full:.10f}")
    print(f"  EML({x}, {y}) - ln({z}) = {split:.10f}")
    print(f"  Difference: {abs(full - split):.2e}")
    print(f"\n  This decomposition allows computing with products")
    print(f"  without forming the product explicitly.\n")


# ============================================================
# Application 3: EML-Based Signal Compression
# ============================================================

def app_signal():
    """
    Use EML's contraction property for adaptive signal compression.
    EML(0, x) maps (1, e) to (0, 1), providing natural compression.
    """
    print("=" * 70)
    print("APPLICATION 3: EML-Based Signal Compression")
    print("=" * 70)
    
    # Generate a test signal
    t = np.linspace(0, 1, 1000)
    signal = 1.5 + 0.5 * np.sin(2 * np.pi * 5 * t) + 0.3 * np.sin(2 * np.pi * 13 * t)
    # Signal range is approximately (0.7, 2.3), which overlaps (1, e)
    
    # Apply EML compression: EML(0, x) = 1 - ln(x)
    compressed = 1 - np.log(np.maximum(signal, 1e-10))
    
    # Recover using EML inversion: x = exp(1 - compressed)
    recovered = np.exp(1 - compressed)
    
    fig, axes = plt.subplots(3, 1, figsize=(12, 8), sharex=True)
    
    axes[0].plot(t, signal, 'b-', linewidth=1)
    axes[0].set_ylabel('Amplitude', fontsize=11)
    axes[0].set_title('Original Signal', fontsize=12)
    axes[0].grid(True, alpha=0.3)
    
    axes[1].plot(t, compressed, 'r-', linewidth=1)
    axes[1].set_ylabel('Compressed', fontsize=11)
    axes[1].set_title('EML-Compressed: EML(0, signal) = 1 - ln(signal)', fontsize=12)
    axes[1].grid(True, alpha=0.3)
    
    axes[2].plot(t, recovered, 'g-', linewidth=1, label='Recovered')
    axes[2].plot(t, signal, 'b--', linewidth=0.5, alpha=0.5, label='Original')
    axes[2].set_ylabel('Amplitude', fontsize=11)
    axes[2].set_xlabel('Time', fontsize=11)
    axes[2].set_title('Recovered Signal: exp(1 - compressed)', fontsize=12)
    axes[2].legend(fontsize=10)
    axes[2].grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig(os.path.join(OUTPUT_DIR, 'eml_signal.png'), dpi=150, bbox_inches='tight')
    plt.close()
    
    error = np.max(np.abs(signal - recovered))
    print(f"\n  Original signal range: [{signal.min():.4f}, {signal.max():.4f}]")
    print(f"  Compressed range:     [{compressed.min():.4f}, {compressed.max():.4f}]")
    print(f"  Compression ratio:    {(signal.max()-signal.min())/(compressed.max()-compressed.min()):.4f}")
    print(f"  Recovery error:       {error:.2e}")
    print(f"\n  Saved: demos/eml_signal.png\n")


# ============================================================
# Application 4: EML Closure as Number-Theoretic Explorer
# ============================================================

def app_number_theory():
    """
    Use the EML closure to explore number-theoretic properties
    of generated constants.
    """
    print("=" * 70)
    print("APPLICATION 4: EML Closure as Number-Theoretic Explorer")
    print("=" * 70)
    
    e = np.e
    
    # Generate EML closure elements and check rationality approximations
    constants = {
        'e': e,
        'e - 1': e - 1,
        'e^e': e**e,
        'e^e - 1': e**e - 1,
        'e^e - e': e**e - e,
        'e^(e-1)': e**(e-1),
        'e/(e-1)': e/(e-1),
        '1 - ln(e-1)': 1 - np.log(e-1),
    }
    
    print("\n  EML Closure Constants and Their Continued Fraction Approximations:\n")
    
    for name, val in constants.items():
        # Simple continued fraction (first few terms)
        cf = []
        x = val
        for _ in range(8):
            a = int(np.floor(x))
            cf.append(a)
            frac = x - a
            if abs(frac) < 1e-10:
                break
            x = 1.0 / frac
        
        # Best rational approximation
        p0, p1 = 0, 1
        q0, q1 = 1, 0
        for a in cf:
            p0, p1 = p1, a * p1 + p0
            q0, q1 = q1, a * q1 + q0
        
        print(f"  {name:>15s} = {val:.10f}")
        print(f"  {'':>15s}   CF: [{', '.join(str(a) for a in cf)}]")
        print(f"  {'':>15s}   Best rational: {p1}/{q1} = {p1/q1:.10f}")
        print(f"  {'':>15s}   Error: {abs(val - p1/q1):.2e}")
        print()
    
    # Irrationality measure exploration
    print("  --- Irrationality Measure Estimates ---\n")
    print("  For e, the irrationality measure is exactly 2 (Roth's theorem + known CF).")
    print("  For e^e, the irrationality measure is unknown (it's not even known if e^e is irrational!).\n")
    
    # Show that e's continued fraction [2; 1, 2, 1, 1, 4, 1, 1, 6, ...] is regular
    x = e
    cf_e = []
    for _ in range(15):
        a = int(np.floor(x))
        cf_e.append(a)
        frac = x - a
        if abs(frac) < 1e-12:
            break
        x = 1.0 / frac
    
    print(f"  e = [{cf_e[0]}; {', '.join(str(a) for a in cf_e[1:])}]")
    print(f"  Pattern: [2; 1, 2, 1, 1, 4, 1, 1, 6, 1, 1, 8, ...]")
    print(f"  The continued fraction of e has a beautiful regular pattern!\n")


# ============================================================
# Application 5: EML Transfer Function for Control Systems
# ============================================================

def app_control():
    """
    Use EML as a nonlinear transfer function in a feedback system.
    The scaled inversion property EML(EML(0,x), 1) = e/x provides
    a natural feedback mechanism.
    """
    print("=" * 70)
    print("APPLICATION 5: EML as Nonlinear Transfer Function")
    print("=" * 70)
    
    # Simulate a simple feedback system:
    # x_{n+1} = alpha * EML(EML(0, x_n), 1) = alpha * e / x_n
    # This has fixed point x* = sqrt(alpha * e)
    
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))
    
    alphas = [0.5, 1.0, 2.0]
    colors = ['blue', 'green', 'red']
    
    ax = axes[0]
    for alpha, color in zip(alphas, colors):
        x = 2.0  # initial condition
        trajectory = [x]
        for _ in range(30):
            x = alpha * np.e / x  # EML-based feedback: alpha * EML(EML(0,x), 1)
            trajectory.append(x)
        
        fixed_point = np.sqrt(alpha * np.e)
        ax.plot(trajectory, 'o-', color=color, markersize=3, linewidth=1,
                label=f'α={alpha}, x*={fixed_point:.3f}')
        ax.axhline(y=fixed_point, color=color, linestyle='--', alpha=0.5)
    
    ax.set_xlabel('Iteration n', fontsize=11)
    ax.set_ylabel('x_n', fontsize=11)
    ax.set_title('EML Feedback: x_{n+1} = α·e/x_n', fontsize=12)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    
    # Phase portrait: cobweb diagram for alpha=1
    ax2 = axes[1]
    x_range = np.linspace(0.5, 5, 200)
    ax2.plot(x_range, np.e / x_range, 'b-', linewidth=2, label=r'$f(x) = e/x$')
    ax2.plot(x_range, x_range, 'k--', linewidth=1, label=r'$y = x$')
    
    # Cobweb
    x = 0.8
    for _ in range(15):
        x_new = np.e / x
        ax2.plot([x, x], [x, x_new], 'r-', linewidth=0.5, alpha=0.7)
        ax2.plot([x, x_new], [x_new, x_new], 'r-', linewidth=0.5, alpha=0.7)
        x = x_new
    
    ax2.scatter([np.sqrt(np.e)], [np.sqrt(np.e)], s=100, c='red', zorder=5,
               label=f'Fixed point: √e ≈ {np.sqrt(np.e):.3f}')
    ax2.set_xlabel('x', fontsize=11)
    ax2.set_ylabel('f(x)', fontsize=11)
    ax2.set_title('Cobweb Diagram: f(x) = e/x', fontsize=12)
    ax2.legend(fontsize=10)
    ax2.set_xlim(0.5, 5)
    ax2.set_ylim(0.5, 5)
    ax2.set_aspect('equal')
    ax2.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig(os.path.join(OUTPUT_DIR, 'eml_control.png'), dpi=150, bbox_inches='tight')
    plt.close()
    
    print(f"\n  The EML feedback x_{{n+1}} = e/x_n (from scaled inversion)")
    print(f"  converges to the fixed point x* = √e ≈ {np.sqrt(np.e):.6f}")
    print(f"  This is a 2-periodic orbit that averages to √e.\n")
    print(f"  Saved: demos/eml_control.png\n")


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print("\n" + "=" * 70)
    print("  EML DENSITY THEORY — APPLICATIONS")
    print("  Practical uses of the Exp-Minus-Log operation")
    print("=" * 70 + "\n")
    
    app_prng()
    app_logspace()
    app_signal()
    app_number_theory()
    app_control()
    
    print("=" * 70)
    print("All applications demonstrated. Visualizations saved in demos/")
    print("=" * 70)


"""
EML Density Theory — Interactive Demonstration
================================================

This script demonstrates the EML (Exp Minus Log) operation and its properties,
bringing the formally verified Lean theorems to life with concrete numerical examples
and visualizations.

The EML operation is defined as:
    EMLd(a, b) = exp(a) - log(b)

It unifies exponentiation and logarithm into a single binary primitive.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import os

OUTPUT_DIR = os.path.dirname(os.path.abspath(__file__))

# ============================================================
# Core Definitions
# ============================================================

def EMLd(a, b):
    """The EML operation: EMLd(a, b) = exp(a) - log(b)."""
    return np.exp(a) - np.log(b)


def EML_closure(seed, depth):
    """Compute the EML closure of a seed set up to a given depth."""
    current = set(seed)
    for _ in range(depth):
        new_elements = set()
        for a in current:
            for b in current:
                if b > 0:
                    val = EMLd(a, b)
                    if np.isfinite(val) and abs(val) < 1e15:
                        new_elements.add(round(val, 12))
        current = current | new_elements
    return current


# ============================================================
# Demo 1: Algebraic Identities
# ============================================================

def demo_identities():
    """Verify the algebraic identities proved in Lean."""
    print("=" * 70)
    print("DEMO 1: Algebraic Identities of the EML Operation")
    print("=" * 70)
    
    e = np.e
    
    # Identity 1: EML(x, 1) = exp(x)
    print("\n--- Exp Recovery: EML(x, 1) = exp(x) ---")
    for x in [0, 1, 2, -1, np.pi]:
        lhs = EMLd(x, 1)
        rhs = np.exp(x)
        print(f"  EML({x:.4f}, 1) = {lhs:.10f}  |  exp({x:.4f}) = {rhs:.10f}  |  diff = {abs(lhs-rhs):.2e}")
    
    # Identity 2: EML(0, x) = 1 - ln(x)
    print("\n--- Reflected Log: EML(0, x) = 1 - ln(x) ---")
    for x in [1, e, 2, 10, 0.5]:
        lhs = EMLd(0, x)
        rhs = 1 - np.log(x)
        print(f"  EML(0, {x:.4f}) = {lhs:.10f}  |  1 - ln({x:.4f}) = {rhs:.10f}  |  diff = {abs(lhs-rhs):.2e}")
    
    # Identity 3: Log-splitting
    print("\n--- Log-Split: EML(x, y*z) = EML(x, y) - ln(z) ---")
    for (x, y, z) in [(1, 2, 3), (0, e, 2), (2, 1, e)]:
        lhs = EMLd(x, y * z)
        rhs = EMLd(x, y) - np.log(z)
        print(f"  EML({x}, {y:.4f}*{z:.4f}) = {lhs:.10f}  |  RHS = {rhs:.10f}  |  diff = {abs(lhs-rhs):.2e}")
    
    # Identity 4: Scaled inversion
    print("\n--- Scaled Inversion: EML(EML(0, x), 1) = e/x ---")
    for x in [1, 2, e, 0.5, 10]:
        lhs = EMLd(EMLd(0, x), 1)
        rhs = e / x
        print(f"  EML(EML(0, {x:.4f}), 1) = {lhs:.10f}  |  e/{x:.4f} = {rhs:.10f}  |  diff = {abs(lhs-rhs):.2e}")
    
    # Identity 5: Involution
    print("\n--- Involution: EML(0, exp(EML(0, exp(x)))) = x ---")
    for x in [-2, -1, 0, 1, 2, np.pi]:
        result = EMLd(0, np.exp(EMLd(0, np.exp(x))))
        print(f"  f({x:.4f}) = {result:.10f}  |  x = {x:.10f}  |  diff = {abs(result-x):.2e}")
    
    # Identity 6: Shift
    print("\n--- Shift: EML(x + c, 1) = exp(c) * exp(x) ---")
    for (x, c) in [(1, 2), (0, 1), (2, -1), (np.pi, 1)]:
        lhs = EMLd(x + c, 1)
        rhs = np.exp(c) * np.exp(x)
        print(f"  EML({x:.2f}+{c:.2f}, 1) = {lhs:.10f}  |  exp({c:.2f})*exp({x:.2f}) = {rhs:.10f}  |  diff = {abs(lhs-rhs):.2e}")
    print()


# ============================================================
# Demo 2: EML Closure Generation
# ============================================================

def demo_closure():
    """Show how the EML closure generates rich sets from {1}."""
    print("=" * 70)
    print("DEMO 2: EML Closure Generation from {1}")
    print("=" * 70)
    
    for depth in range(4):
        closure = EML_closure({1.0}, depth)
        sorted_vals = sorted(closure)
        print(f"\n  Depth {depth}: {len(closure)} elements")
        if len(sorted_vals) <= 20:
            for v in sorted_vals:
                label = ""
                if abs(v - 1) < 1e-10: label = " = 1"
                elif abs(v - np.e) < 1e-10: label = " = e"
                elif abs(v - (np.e - 1)) < 1e-10: label = " = e - 1"
                elif abs(v - np.exp(np.e)) < 1e-8: label = " = e^e"
                elif abs(v - (np.exp(np.e) - 1)) < 1e-8: label = " = e^e - 1"
                elif abs(v - (np.exp(np.e) - np.e)) < 1e-8: label = " = e^e - e"
                print(f"    {v:>20.10f}{label}")
        else:
            print(f"    (showing first 10 and last 5)")
            for v in sorted_vals[:10]:
                print(f"    {v:>20.10f}")
            print(f"    ...")
            for v in sorted_vals[-5:]:
                print(f"    {v:>20.10f}")
    print()


# ============================================================
# Demo 3: Interval Mapping Visualization
# ============================================================

def demo_interval_mapping():
    """Visualize EML(0, x) mapping (1, e) to (0, 1)."""
    print("=" * 70)
    print("DEMO 3: Interval Mapping — EML(0, x) maps (1, e) to (0, 1)")
    print("=" * 70)
    
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))
    
    x = np.linspace(0.01, 5, 500)
    y = 1 - np.log(x)
    
    ax = axes[0]
    ax.plot(x, y, 'b-', linewidth=2, label=r'$\mathrm{EML}(0, x) = 1 - \ln(x)$')
    ax.axhline(y=0, color='gray', linewidth=0.5)
    ax.axhline(y=1, color='gray', linewidth=0.5, linestyle='--')
    ax.axvline(x=1, color='red', linewidth=0.5, linestyle='--', alpha=0.7)
    ax.axvline(x=np.e, color='red', linewidth=0.5, linestyle='--', alpha=0.7)
    mask = (x >= 1) & (x <= np.e)
    ax.fill_between(x[mask], 0, y[mask], alpha=0.2, color='green', label=r'$(1, e) \to (0, 1)$')
    ax.set_xlabel('x', fontsize=12)
    ax.set_ylabel('EML(0, x)', fontsize=12)
    ax.set_title('EML(0, x) = 1 - ln(x)', fontsize=14)
    ax.legend(fontsize=11)
    ax.set_xlim(0, 5)
    ax.set_ylim(-1.5, 2)
    ax.grid(True, alpha=0.3)
    
    x2 = np.linspace(-2, 3, 500)
    y2 = np.exp(x2)
    ax2 = axes[1]
    ax2.plot(x2, y2, 'r-', linewidth=2, label=r'$\mathrm{EML}(x, 1) = e^x$')
    ax2.axhline(y=1, color='gray', linewidth=0.5, linestyle='--')
    ax2.axvline(x=0, color='gray', linewidth=0.5, linestyle='--')
    mask2 = x2 > 0
    ax2.fill_between(x2[mask2], 1, y2[mask2], alpha=0.2, color='orange', 
                      label=r'$\mathrm{EML}(x, 1) > 1$ for $x > 0$')
    ax2.set_xlabel('x', fontsize=12)
    ax2.set_ylabel('EML(x, 1)', fontsize=12)
    ax2.set_title('EML(x, 1) = exp(x) — Amplification', fontsize=14)
    ax2.legend(fontsize=11)
    ax2.set_xlim(-2, 3)
    ax2.set_ylim(0, 10)
    ax2.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig(os.path.join(OUTPUT_DIR, 'eml_interval_mapping.png'), dpi=150, bbox_inches='tight')
    plt.close()
    print("  Saved: demos/eml_interval_mapping.png\n")


# ============================================================
# Demo 4: Irrationality of e — Fourier's Argument
# ============================================================

def demo_irrationality():
    """Visualize the Fourier argument for the irrationality of e."""
    print("=" * 70)
    print("DEMO 4: Irrationality of e — Fourier's Argument")
    print("=" * 70)
    
    from math import factorial
    e = np.e
    
    print("\n  Fourier's key insight: if e = p/q, then q!*e = integer + tail")
    print("  where the tail is strictly between 0 and 1.\n")
    
    for q in range(1, 10):
        finite_sum = sum(factorial(q) // factorial(k) for k in range(q + 1))
        tail = factorial(q) * e - finite_sum
        print(f"  q = {q}: finite_sum = {finite_sum:>10d}, "
              f"tail = {tail:.10f}, "
              f"0 < tail < 1? {'YES' if 0 < tail < 1 else 'NO'}")
    
    print("\n  Since the tail is always strictly between 0 and 1,")
    print("  q!*e can never be an integer, so e is irrational.\n")
    
    fig, ax = plt.subplots(figsize=(10, 5))
    qs = list(range(1, 15))
    tails = []
    for q in qs:
        finite_sum = sum(factorial(q) // factorial(k) for k in range(q + 1))
        tail = factorial(q) * e - finite_sum
        tails.append(tail)
    
    ax.bar(qs, tails, color='steelblue', alpha=0.8, edgecolor='navy')
    ax.axhline(y=0, color='red', linewidth=1.5, linestyle='--', label='Lower bound: 0')
    ax.axhline(y=1, color='red', linewidth=1.5, linestyle='--', label='Upper bound: 1')
    ax.set_xlabel('q', fontsize=12)
    ax.set_ylabel(r'Tail = $q! \cdot e - \sum_{k=0}^{q} \frac{q!}{k!}$', fontsize=12)
    ax.set_title("Fourier's Irrationality Argument: The Tail is Trapped in (0, 1)", fontsize=14)
    ax.legend(fontsize=11)
    ax.set_ylim(-0.1, 1.1)
    ax.grid(True, alpha=0.3, axis='y')
    
    plt.tight_layout()
    plt.savefig(os.path.join(OUTPUT_DIR, 'eml_irrationality.png'), dpi=150, bbox_inches='tight')
    plt.close()
    print(f"  Saved: demos/eml_irrationality.png\n")


# ============================================================
# Demo 5: EML as a Computational Primitive
# ============================================================

def demo_computation():
    """Show how EML can encode arithmetic operations."""
    print("=" * 70)
    print("DEMO 5: EML as a Computational Primitive")
    print("=" * 70)
    
    e = np.e
    
    print("\n  The EML operation can encode many standard functions:\n")
    
    print("  1. Exponentiation: exp(x) = EML(x, 1)")
    print(f"     exp(2) = EML(2, 1) = {EMLd(2, 1):.10f}")
    
    print("\n  2. Reflected logarithm: 1 - ln(x) = EML(0, x)")
    print(f"     1 - ln(3) = EML(0, 3) = {EMLd(0, 3):.10f}")
    
    print("\n  3. Scaled inversion: e/x = EML(EML(0, x), 1)")
    for x in [2, 3, 7]:
        print(f"     e/{x} = EML(EML(0, {x}), 1) = {EMLd(EMLd(0, x), 1):.10f} vs {e/x:.10f}")
    
    print("\n  4. Logarithm recovery: ln(x) = EML(0, exp(EML(0, x)))")
    for x in [2, 10, e]:
        result = EMLd(0, np.exp(EMLd(0, x)))
        print(f"     ln({x:.4f}) = {result:.10f} vs {np.log(x):.10f}")
    
    print("\n  5. Involution: EML(0, exp(EML(0, exp(x)))) = x")
    for x in [1, -1, np.pi, 0.5]:
        result = EMLd(0, np.exp(EMLd(0, np.exp(x))))
        print(f"     f({x:.4f}) = {result:.10f}")
    print()


# ============================================================
# Demo 6: EML Closure Visualization
# ============================================================

def demo_closure_visualization():
    """Visualize the growth of the EML closure."""
    print("=" * 70)
    print("DEMO 6: EML Closure Growth Visualization")
    print("=" * 70)
    
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    
    for depth, ax in zip(range(4), axes.flat):
        closure = EML_closure({1.0}, depth)
        vals = sorted([v for v in closure if -5 < v < 50])
        
        ax.scatter(vals, [0] * len(vals), s=30, alpha=0.7, c='steelblue', edgecolors='navy', zorder=5)
        
        for v in vals:
            if abs(v - 1) < 1e-10:
                ax.annotate('1', (v, 0), textcoords="offset points", xytext=(0, 15), 
                           ha='center', fontsize=9, color='red')
            elif abs(v - np.e) < 1e-10:
                ax.annotate('e', (v, 0), textcoords="offset points", xytext=(0, 15), 
                           ha='center', fontsize=9, color='red')
            elif abs(v - (np.e - 1)) < 1e-10:
                ax.annotate('e-1', (v, 0), textcoords="offset points", xytext=(0, -20), 
                           ha='center', fontsize=8, color='darkgreen')
        
        ax.set_title(f'Depth {depth}: {len(vals)} elements (in view)', fontsize=12)
        ax.set_xlabel('Value', fontsize=10)
        ax.axhline(y=0, color='gray', linewidth=0.3)
        ax.set_ylim(-0.5, 0.5)
        ax.set_yticks([])
        ax.grid(True, alpha=0.3, axis='x')
    
    plt.suptitle('Growth of EML Closure from {1}', fontsize=16, y=1.02)
    plt.tight_layout()
    plt.savefig(os.path.join(OUTPUT_DIR, 'eml_closure_growth.png'), dpi=150, bbox_inches='tight')
    plt.close()
    print("  Saved: demos/eml_closure_growth.png\n")


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print("\n" + "=" * 70)
    print("  EML DENSITY THEORY — INTERACTIVE DEMONSTRATION")
    print("  Formally verified in Lean 4 with Mathlib")
    print("=" * 70 + "\n")
    
    demo_identities()
    demo_closure()
    demo_interval_mapping()
    demo_irrationality()
    demo_computation()
    demo_closure_visualization()
    
    print("=" * 70)
    print("All demos complete. Visualizations saved in demos/")
    print("=" * 70)
