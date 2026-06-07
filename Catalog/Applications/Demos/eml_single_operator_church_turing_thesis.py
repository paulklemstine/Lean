#!/usr/bin/env python3
"""
EML Closure Algebra — Numerical Demonstrations

Demonstrates the key results of the EML (Exp-Minus-Log) single-operator theory:
1. Recovery of exp and log from the eml operator
2. Transcendental depth classification of functions
3. The EML diagonal gap theorem
4. Size-depth tradeoff
5. Lambert W connection via critical point
"""

import math
from typing import Callable

# ============================================================
# §1. The EML Operator
# ============================================================

def eml(a: float, b: float) -> float:
    """The EML operator: eml(a, b) = exp(a) - log(b)"""
    return math.exp(a) - math.log(b)


def demo_recovery():
    """Demonstrate that eml recovers exp and log."""
    print("=" * 60)
    print("§1. EML RECOVERY IDENTITIES")
    print("=" * 60)
    
    test_values = [0.0, 0.5, 1.0, 2.0, -1.0, 3.0]
    
    print("\n  exp(x) = eml(x, 1):")
    print(f"  {'x':>8} | {'exp(x)':>15} | {'eml(x,1)':>15} | {'error':>12}")
    print("  " + "-" * 58)
    for x in test_values:
        exp_x = math.exp(x)
        eml_x = eml(x, 1.0)
        err = abs(exp_x - eml_x)
        print(f"  {x:8.3f} | {exp_x:15.10f} | {eml_x:15.10f} | {err:12.2e}")
    
    print("\n  log(y) = 1 - eml(0, y):")
    pos_values = [0.1, 0.5, 1.0, 2.0, 5.0, 10.0]
    print(f"  {'y':>8} | {'log(y)':>15} | {'1-eml(0,y)':>15} | {'error':>12}")
    print("  " + "-" * 58)
    for y in pos_values:
        log_y = math.log(y)
        eml_y = 1.0 - eml(0.0, y)
        err = abs(log_y - eml_y)
        print(f"  {y:8.3f} | {log_y:15.10f} | {eml_y:15.10f} | {err:12.2e}")


# ============================================================
# §2. Transcendental Depth Examples
# ============================================================

def demo_depth_examples():
    """Demonstrate functions at various transcendental depths."""
    print("\n" + "=" * 60)
    print("§2. TRANSCENDENTAL DEPTH CLASSIFICATION")
    print("=" * 60)
    
    # Depth 0: polynomials
    poly = lambda x: 3*x**2 - 2*x + 1
    
    # Depth 1: exp, log, sinh, cosh
    exp_f = lambda x: math.exp(x)
    log_f = lambda x: math.log(abs(x)) if x != 0 else float('-inf')
    sinh_f = lambda x: math.sinh(x)
    cosh_f = lambda x: math.cosh(x)
    
    # Depth 2: exp(exp(x)), tetration
    exp_exp = lambda x: math.exp(math.exp(x))
    tetration = lambda x: math.exp(x * math.log(x)) if x > 0 else 0.0
    
    x = 1.5
    
    print(f"\n  At x = {x}:")
    print(f"\n  Depth 0 (rational functions):")
    print(f"    3x² - 2x + 1 = {poly(x):.6f}")
    
    print(f"\n  Depth 1 (single exp/log layer):")
    print(f"    exp(x)  = {exp_f(x):.6f}")
    print(f"    log(x)  = {log_f(x):.6f}")
    print(f"    sinh(x) = {sinh_f(x):.6f}")
    print(f"    cosh(x) = {cosh_f(x):.6f}")
    
    print(f"\n  Depth 2 (double exp/log layer):")
    print(f"    exp(exp(x)) = {exp_exp(x):.6f}")
    print(f"    x^x = exp(x·log(x)) = {tetration(x):.6f}")


# ============================================================
# §3. EML Diagonal Gap Theorem
# ============================================================

def eml_diag(z: float) -> float:
    """The EML diagonal: d(z) = exp(z) - log(z)"""
    return math.exp(z) - math.log(z)


def demo_diagonal_gap():
    """Verify the diagonal gap theorem: d(z) - z ≥ 1 for z > 0."""
    print("\n" + "=" * 60)
    print("§3. EML DIAGONAL GAP THEOREM: d(z) - z ≥ 1")
    print("=" * 60)
    
    test_z = [0.01, 0.1, 0.5, 0.567, 1.0, 2.0, 5.0, 10.0, 100.0]
    
    print(f"\n  {'z':>8} | {'d(z)':>15} | {'d(z)-z':>12} | {'≥ 1?':>6}")
    print("  " + "-" * 50)
    
    min_gap = float('inf')
    min_gap_z = 0.0
    
    for z in test_z:
        d_z = eml_diag(z)
        gap = d_z - z
        check = "✓" if gap >= 1.0 else "✗"
        print(f"  {z:8.3f} | {d_z:15.6f} | {gap:12.6f} | {check:>6}")
        if gap < min_gap:
            min_gap = gap
            min_gap_z = z
    
    # Find the minimum gap numerically
    print(f"\n  Minimum gap found near z = {min_gap_z:.3f}: gap = {min_gap:.6f}")
    
    # Refine search for minimum
    best_z = min_gap_z
    for _ in range(100):
        # Newton's method on d'(z) - 1 = exp(z) - 1/z - 1
        deriv = math.exp(best_z) - 1.0/best_z - 1.0
        deriv2 = math.exp(best_z) + 1.0/best_z**2
        best_z -= deriv / deriv2
        if best_z <= 0:
            best_z = 0.01
    
    min_gap = eml_diag(best_z) - best_z
    print(f"  Refined: minimum gap at z₀ ≈ {best_z:.10f}, gap ≈ {min_gap:.10f}")
    print(f"  (Theorem guarantees gap ≥ 1; actual minimum gap ≈ {min_gap:.6f})")


# ============================================================
# §4. Critical Point and Lambert W
# ============================================================

def demo_lambert_w():
    """Demonstrate the connection between the EML diagonal critical 
    point and the Lambert W function."""
    print("\n" + "=" * 60)
    print("§4. LAMBERT W CONNECTION")
    print("=" * 60)
    
    # Critical point satisfies exp(z₀) = 1/z₀, i.e., z₀·exp(z₀) = 1
    # This means z₀ = W(1) where W is the Lambert W function
    
    # Find z₀ by Newton's method on exp(z) - 1/z = 0
    z0 = 0.5  # initial guess
    for _ in range(100):
        f = math.exp(z0) - 1.0/z0
        fp = math.exp(z0) + 1.0/z0**2
        z0 -= f / fp
    
    print(f"\n  Critical point of d(z) = exp(z) - log(z):")
    print(f"    z₀ = {z0:.15f}")
    print(f"    exp(z₀) = {math.exp(z0):.15f}")
    print(f"    1/z₀    = {1.0/z0:.15f}")
    print(f"    |exp(z₀) - 1/z₀| = {abs(math.exp(z0) - 1.0/z0):.2e}")
    print(f"    z₀·exp(z₀) = {z0 * math.exp(z0):.15f}  (should be 1)")
    print(f"\n  This z₀ = W(1), the Lambert W function at 1.")
    print(f"  d(z₀) = {eml_diag(z0):.15f} (minimum of the diagonal)")
    print(f"  d(z₀) - z₀ = {eml_diag(z0) - z0:.15f} (≥ 1 ✓)")


# ============================================================
# §5. Size-Depth Tradeoff
# ============================================================

def demo_size_depth():
    """Demonstrate the 2d+1 ≤ size bound."""
    print("\n" + "=" * 60)
    print("§5. SIZE-DEPTH TRADEOFF: 2d + 1 ≤ size")
    print("=" * 60)
    
    examples = [
        ("const(π)", 0, 1),
        ("var(0)", 0, 1),
        ("var(0) + const(1)", 0, 3),
        ("eml(var(0), const(1))  [= exp(x)]", 1, 3),
        ("1 + neg(eml(0, var(0)))  [= log(x)]", 1, 5),
        ("eml(eml(var(0), const(1)), const(1))  [= exp(exp(x))]", 2, 5),
        ("eml(mul(var(0), add(const(1), neg(eml(const(0), var(0))))), const(1))\n" +
         "                                     [= exp(x·log(x))]", 2, 11),
    ]
    
    print(f"\n  {'Expression':<55} | {'Depth':>5} | {'Size':>4} | {'2d+1':>4} | {'OK':>3}")
    print("  " + "-" * 80)
    for name, depth, size in examples:
        bound = 2 * depth + 1
        check = "✓" if size >= bound else "✗"
        if '\n' in name:
            parts = name.split('\n')
            print(f"  {parts[0]:<55} | {depth:>5} | {size:>4} | {bound:>4} | {check:>3}")
            for p in parts[1:]:
                print(f"  {p}")
        else:
            print(f"  {name:<55} | {depth:>5} | {size:>4} | {bound:>4} | {check:>3}")


# ============================================================
# §6. Generating Function
# ============================================================

def iter_exp(n: int, x: float) -> float:
    """n-fold iterated exponential: exp^n(x)"""
    result = x
    for _ in range(n):
        result = math.exp(result)
    return result


def eml_generating_partial(N: int, x: float, t: float) -> float:
    """Partial sum of the EML generating function: Σ_{n<N} exp^n(x) · t^n / n!"""
    total = 0.0
    for n in range(N):
        total += iter_exp(n, x) * t**n / math.factorial(n)
    return total


def demo_generating_function():
    """Demonstrate the EML generating function."""
    print("\n" + "=" * 60)
    print("§6. EML GENERATING FUNCTION")
    print("=" * 60)
    
    x = 0.5
    print(f"\n  G_N(x={x}, t) = Σ_{{n<N}} exp^n({x}) · t^n / n!")
    print(f"\n  Iterated exponentials at x = {x}:")
    for n in range(6):
        val = iter_exp(n, x)
        print(f"    exp^{n}({x}) = {val:.8f}")
    
    print(f"\n  G_N({x}, 0) = {x} (recovers x, as proved):")
    for N in [1, 3, 5, 10]:
        val = eml_generating_partial(N, x, 0.0)
        print(f"    G_{N}({x}, 0) = {val:.10f}")


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print("╔" + "═" * 58 + "╗")
    print("║  EML CLOSURE ALGEBRA — NUMERICAL DEMONSTRATIONS         ║")
    print("║  Single-Operator Universality for Elementary Functions   ║")
    print("╚" + "═" * 58 + "╝")
    
    demo_recovery()
    demo_depth_examples()
    demo_diagonal_gap()
    demo_lambert_w()
    demo_size_depth()
    demo_generating_function()
    
    print("\n" + "=" * 60)
    print("All demonstrations complete.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: EML Compilation — From exp/log to Single Operator

Shows how traditional mathematical expressions are compiled
to EML-only form, with size and depth analysis.
"""

import numpy as np
import matplotlib.pyplot as plt
import math


def main():
    fig, axes = plt.subplots(1, 3, figsize=(16, 5))
    fig.suptitle('EML Compilation: Traditional → Single Operator', 
                 fontsize=14, fontweight='bold')

    # Panel 1: Function comparison — traditional vs EML
    ax1 = axes[0]
    x = np.linspace(0.1, 3.0, 300)

    # exp(x) via eml(x, 1)
    exp_trad = np.exp(x)
    exp_eml = np.exp(x) - np.log(np.ones_like(x))  # eml(x, 1) = exp(x) - log(1) = exp(x)

    # log(x) via 1 - eml(0, x) 
    log_trad = np.log(x)
    log_eml = 1.0 - (np.exp(np.zeros_like(x)) - np.log(x))  # 1 - eml(0, x) = 1 - (1 - log(x)) = log(x)

    ax1.plot(x, exp_trad, 'b-', linewidth=2, label='exp(x) [traditional]')
    ax1.plot(x, exp_eml, 'b--', linewidth=2, alpha=0.5, label='eml(x, 1) [EML form]')
    ax1.plot(x, log_trad, 'r-', linewidth=2, label='log(x) [traditional]')
    ax1.plot(x, log_eml, 'r--', linewidth=2, alpha=0.5, label='1 − eml(0, x) [EML form]')
    ax1.axhline(y=0, color='k', linewidth=0.5)
    ax1.set_xlabel('x')
    ax1.set_ylabel('f(x)')
    ax1.set_title('Recovery: exp & log from eml')
    ax1.legend(fontsize=8)
    ax1.grid(True, alpha=0.3)

    # Panel 2: Depth hierarchy inhabitants
    ax2 = axes[1]
    depths = [0, 1, 2, 3, 4, 5]
    functions = {
        0: ['1', 'x', 'x²', 'x³', '1/x', 'x²+x'],
        1: ['eˣ', 'ln x', 'sinh x', 'cosh x', 'eˣ/x', 'x·ln x'],
        2: ['eᵉˣ', 'ln ln x', 'xˣ', 'eˣ·ln x', 'eˣ²', 'eˣ⁺ˡⁿˣ'],
        3: ['eᵉᵉˣ', 'ln ln ln x', 'xˣˣ'],
        4: ['exp⁴(x)'],
        5: ['exp⁵(x)'],
    }
    
    colors = plt.cm.viridis(np.linspace(0.2, 0.9, 6))
    y_positions = []
    y_labels = []
    y_colors = []
    
    y = 0
    for d in depths:
        for fname in functions.get(d, []):
            y_positions.append(y)
            y_labels.append(fname)
            y_colors.append(colors[d])
            y += 1
        y += 0.5  # gap between depth levels
    
    ax2.barh(range(len(y_positions)), [depths[min(i, len(depths)-1)] for i, _ in enumerate(y_labels)],
             color=[colors[min(i, len(colors)-1)] for i in range(len(y_labels))],
             height=0.6, alpha=0.7)
    
    # Simpler approach: just show depth levels as horizontal bars
    ax2.clear()
    for d in range(6):
        fns = functions.get(d, [])
        label_text = ', '.join(fns[:4])
        if len(fns) > 4:
            label_text += ', ...'
        bar = ax2.barh(d, len(fns), color=colors[d], alpha=0.8, height=0.7)
        ax2.text(len(fns) + 0.1, d, label_text, va='center', fontsize=8)
    
    ax2.set_xlabel('Number of example functions')
    ax2.set_ylabel('Transcendental Depth')
    ax2.set_title('Depth Hierarchy: Function Count per Level')
    ax2.set_yticks(range(6))
    ax2.set_xlim(0, 12)
    ax2.grid(True, alpha=0.3, axis='x')

    # Panel 3: Size-depth tradeoff
    ax3 = axes[2]
    # Theoretical lower bound: 2d + 1 ≤ size
    d_range = np.arange(0, 8)
    lower_bound = 2 * d_range + 1
    
    # Example expressions at each depth
    example_sizes = {
        0: [1, 1, 3, 5, 3, 5],  # const, var, add, mul-add, neg, inv
        1: [3, 5, 9, 9],        # exp(x), log(x), sinh, cosh
        2: [5, 7, 11],          # exp(exp(x)), log(log(x)), x^x
        3: [7, 9],
        4: [9],
        5: [11],
    }
    
    ax3.plot(d_range, lower_bound, 'r-', linewidth=2, marker='s', 
             label='Lower bound: 2d + 1', zorder=3)
    
    for d, sizes in example_sizes.items():
        for s in sizes:
            ax3.scatter(d, s, c='blue', alpha=0.5, s=60, zorder=2)
    
    ax3.scatter([], [], c='blue', alpha=0.5, s=60, label='Actual expressions')
    ax3.fill_between(d_range, lower_bound, 0, alpha=0.1, color='red', 
                     label='Infeasible region')
    ax3.set_xlabel('Transcendental Depth')
    ax3.set_ylabel('Expression Size (nodes)')
    ax3.set_title('Size-Depth Tradeoff: 2d+1 ≤ size')
    ax3.legend(fontsize=9)
    ax3.grid(True, alpha=0.3)
    ax3.set_xlim(-0.5, 6)
    ax3.set_ylim(0, 14)

    plt.tight_layout()
    plt.savefig('eml_compilation_analysis.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: eml_compilation_analysis.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: EML Diagonal Function and Its Properties

Plots the EML diagonal d(z) = exp(z) - log(z) on (0, ∞),
showing the gap theorem, strict convexity, and Lambert W critical point.
"""

import numpy as np
import matplotlib.pyplot as plt
import math


def eml_diagonal(z):
    """The EML diagonal: d(z) = exp(z) - log(z)."""
    return np.exp(z) - np.log(z)


def find_critical_point():
    """Find z₀ where exp(z₀) = 1/z₀ via Newton's method."""
    z = 0.5
    for _ in range(100):
        f = math.exp(z) - 1.0 / z
        fp = math.exp(z) + 1.0 / z**2
        z -= f / fp
    return z


def main():
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    fig.suptitle('EML Diagonal: d(z) = exp(z) − log(z)', fontsize=16, fontweight='bold')

    z0 = find_critical_point()
    d_z0 = eml_diagonal(np.array([z0]))[0]

    # Panel 1: The diagonal function
    ax1 = axes[0, 0]
    z = np.linspace(0.01, 3, 500)
    d_z = eml_diagonal(z)
    ax1.plot(z, d_z, 'b-', linewidth=2, label='d(z) = exp(z) − log(z)')
    ax1.plot(z, z, 'r--', linewidth=1, label='y = z')
    ax1.plot(z, z + 1, 'g--', linewidth=1, alpha=0.7, label='y = z + 1')
    ax1.plot(z0, d_z0, 'ko', markersize=8, zorder=5)
    ax1.annotate(f'z₀ = W(1) ≈ {z0:.4f}\nd(z₀) ≈ {d_z0:.4f}',
                 xy=(z0, d_z0), xytext=(z0 + 0.5, d_z0 + 1),
                 arrowprops=dict(arrowstyle='->', color='black'),
                 fontsize=10, bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.5))
    ax1.set_xlabel('z')
    ax1.set_ylabel('d(z)')
    ax1.set_title('The EML Diagonal')
    ax1.legend(loc='upper left')
    ax1.set_ylim(-1, 15)
    ax1.grid(True, alpha=0.3)

    # Panel 2: The gap function
    ax2 = axes[0, 1]
    gap = d_z - z
    ax2.plot(z, gap, 'b-', linewidth=2, label='d(z) − z')
    ax2.axhline(y=1, color='r', linestyle='--', linewidth=1, label='gap = 1 (lower bound)')
    ax2.plot(z0, d_z0 - z0, 'ko', markersize=8, zorder=5)
    ax2.fill_between(z, 1, gap, where=(gap >= 1), alpha=0.15, color='blue')
    ax2.set_xlabel('z')
    ax2.set_ylabel('d(z) − z')
    ax2.set_title('Gap Theorem: d(z) − z ≥ 1')
    ax2.legend()
    ax2.set_ylim(0, 12)
    ax2.grid(True, alpha=0.3)

    # Panel 3: Depth hierarchy
    ax3 = axes[1, 0]
    x = np.linspace(-1, 2, 200)
    depth_funcs = {
        'x (depth 0)': x,
        'x² (depth 0)': x**2,
        'exp(x) (depth 1)': np.exp(x),
        'log(|x|+1) (depth 1)': np.log(np.abs(x) + 1),
        'sinh(x) (depth 1)': np.sinh(x),
    }
    colors = ['#1f77b4', '#aec7e8', '#ff7f0e', '#ffbb78', '#2ca02c']
    for (label, vals), color in zip(depth_funcs.items(), colors):
        depth_level = int(label.split('depth ')[1].split(')')[0])
        ls = '-' if depth_level == 0 else '--' if depth_level == 1 else ':'
        ax3.plot(x, vals, linewidth=2, label=label, color=color, linestyle=ls)
    ax3.set_xlabel('x')
    ax3.set_ylabel('f(x)')
    ax3.set_title('EML Depth Hierarchy')
    ax3.legend(loc='upper left', fontsize=8)
    ax3.set_ylim(-3, 8)
    ax3.grid(True, alpha=0.3)

    # Panel 4: Convexity — second derivative
    ax4 = axes[1, 1]
    z_pos = np.linspace(0.05, 3, 500)
    d2 = np.exp(z_pos) + 1.0 / z_pos**2
    d1 = np.exp(z_pos) - 1.0 / z_pos
    ax4.plot(z_pos, d2, 'r-', linewidth=2, label="d''(z) = exp(z) + 1/z²")
    ax4.plot(z_pos, d1, 'b-', linewidth=2, label="d'(z) = exp(z) − 1/z")
    ax4.axhline(y=0, color='k', linewidth=0.5)
    ax4.plot(z0, 0, 'ko', markersize=8, zorder=5)
    ax4.annotate(f'z₀ ≈ {z0:.4f}', xy=(z0, 0), xytext=(z0 + 0.5, 2),
                 arrowprops=dict(arrowstyle='->', color='black'),
                 fontsize=10)
    ax4.set_xlabel('z')
    ax4.set_ylabel('Derivative value')
    ax4.set_title("Strict Convexity: d''(z) > 0 on ℝ₊")
    ax4.legend(loc='upper left')
    ax4.set_ylim(-5, 15)
    ax4.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('eml_diagonal_analysis.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: eml_diagonal_analysis.png")


if __name__ == "__main__":
    main()
