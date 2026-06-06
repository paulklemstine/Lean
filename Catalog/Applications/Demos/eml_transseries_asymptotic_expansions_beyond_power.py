#!/usr/bin/env python3
"""
Transseries Demo: Numerical Examples of Asymptotic Dominance

Demonstrates the key theorems from the transseries formalization:
1. Exponential dominates polynomial
2. Double-exponential dominates exponential
3. Logarithmic negligibility
4. EML diagonal gap
5. Iterated exp-log cancellation
"""

import math
from typing import Tuple


def growth_level_eval(depth: int, exponent: float, x: float) -> float:
    """Evaluate a growth level (depth, exponent) at x.
    
    depth=0: x^exponent
    depth>0: exp^depth(x^exponent)
    depth<0: log^|depth|(x^exponent)
    """
    val = x ** exponent
    if depth > 0:
        for _ in range(depth):
            val = math.exp(min(val, 700))  # clamp to avoid overflow
    elif depth < 0:
        for _ in range(-depth):
            if val > 0:
                val = math.log(val)
            else:
                return float('-inf')
    return val


def demo_exp_dominates_poly():
    """Theorem: exp(x) / x^n → ∞ for all n."""
    print("=" * 60)
    print("THEOREM 3.1: Exponential Dominates Polynomial")
    print("  exp(x) / x^(n+1) → ∞ as x → ∞")
    print("=" * 60)
    
    for n in [1, 5, 10, 20]:
        print(f"\n  n = {n}:")
        for x in [10, 50, 100, 200]:
            ratio = math.exp(x) / (x ** (n + 1))
            print(f"    x = {x:>4}: exp(x)/x^{n+1} = {ratio:.2e}")


def demo_double_exp_separation():
    """Theorem: exp(exp(x)) / exp(cx) → ∞ for all c."""
    print("\n" + "=" * 60)
    print("THEOREM 3.3: Double-Exponential Dominates Exponential")
    print("  exp(exp(x)) / exp(cx) → ∞ for all c")
    print("=" * 60)
    
    for c in [1, 10, 100]:
        print(f"\n  c = {c}:")
        for x in [3, 5, 7, 10]:
            # exp(exp(x) - cx) to avoid overflow
            exponent = math.exp(x) - c * x
            print(f"    x = {x:>2}: exp(exp(x)-{c}x) = exp({exponent:.1f})"
                  f" [≈ 10^{exponent/math.log(10):.0f}]")


def demo_log_negligibility():
    """Theorem: log(x) / x^α → 0 for α > 0."""
    print("\n" + "=" * 60)
    print("THEOREM 3.5: Log Negligible vs Any Power")
    print("  log(x) / x^α → 0 for α > 0")
    print("=" * 60)
    
    for alpha in [0.01, 0.1, 0.5, 1.0]:
        print(f"\n  α = {alpha}:")
        for x in [10, 100, 1000, 10000, 1e6]:
            ratio = math.log(x) / (x ** alpha)
            print(f"    x = {x:>8.0f}: log(x)/x^{alpha} = {ratio:.6f}")


def demo_diagonal_gap():
    """Theorem: exp(x) - log(x) ≥ 2 for x > 0, with equality never achieved."""
    print("\n" + "=" * 60)
    print("THEOREM 5.4-5.5: EML Diagonal Gap")
    print("  exp(x) - log(x) ≥ 2 for x > 0, strict for x ≠ 1")
    print("=" * 60)
    
    print("\n  Searching for minimum of exp(x) - log(x) on (0, ∞):")
    min_val = float('inf')
    min_x = 0
    for i in range(1, 10000):
        x = i * 0.001
        val = math.exp(x) - math.log(x)
        if val < min_val:
            min_val = val
            min_x = x
    
    print(f"    Minimum found at x ≈ {min_x:.4f}: f(x) = {min_val:.6f}")
    print(f"    Gap above 2: {min_val - 2:.6f}")
    
    print("\n  Sample values:")
    for x in [0.01, 0.1, 0.5, 1.0, 2.0, 5.0, 10.0]:
        val = math.exp(x) - math.log(x)
        print(f"    x = {x:>5.2f}: exp(x) - log(x) = {val:.4f} (gap = {val - 2:.4f})")


def demo_exp_log_cancellation():
    """Theorem: exp(exp(log(log(x)))) = x for x > 1."""
    print("\n" + "=" * 60)
    print("THEOREM 4.1: Iterated Exp-Log Cancellation")
    print("  exp(exp(log(log(x)))) = x for x > 1")
    print("=" * 60)
    
    print("\n  Verification:")
    for x in [2, 3, 5, 10, 100, 1000, 1e6]:
        result = math.exp(math.exp(math.log(math.log(x))))
        error = abs(result - x) / x
        print(f"    x = {x:>8.0f}: exp(exp(log(log(x)))) = {result:.6f}, "
              f"relative error = {error:.2e}")


def demo_growth_level_hierarchy():
    """Demonstrate the growth level hierarchy at a fixed x."""
    print("\n" + "=" * 60)
    print("GROWTH LEVEL HIERARCHY at x = 10")
    print("=" * 60)
    
    levels = [
        (-2, 1.0, "log(log(x))"),
        (-1, 0.5, "log(√x)"),
        (-1, 1.0, "log(x)"),
        (-1, 2.0, "log(x²)"),
        (0, 0.5, "√x"),
        (0, 1.0, "x"),
        (0, 2.0, "x²"),
        (0, 10.0, "x^10"),
        (1, 0.5, "exp(√x)"),
        (1, 1.0, "exp(x)"),
    ]
    
    x = 10.0
    print(f"\n  {'Level':>12} | {'Function':>12} | {'Value':>15}")
    print("  " + "-" * 45)
    for depth, exp, name in levels:
        val = growth_level_eval(depth, exp, x)
        print(f"  ({depth:>2}, {exp:>3.1f})  | {name:>12} | {val:>15.2f}")


if __name__ == "__main__":
    demo_exp_dominates_poly()
    demo_double_exp_separation()
    demo_log_negligibility()
    demo_diagonal_gap()
    demo_exp_log_cancellation()
    demo_growth_level_hierarchy()
    
    print("\n" + "=" * 60)
    print("All demonstrations completed successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""Visualization: Asymptotic Dominance Hierarchy

Plots the fundamental asymptotic comparisons:
1. exp(x) vs x^n for various n
2. exp(exp(x)) vs exp(cx) 
3. The EML diagonal gap
"""

import numpy as np

def plot_exp_vs_poly():
    """Plot exp(x)/x^n for various n, showing exp dominance."""
    try:
        import matplotlib.pyplot as plt
    except ImportError:
        print("matplotlib not available, skipping plot")
        return
    
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))
    
    # Panel 1: exp(x) vs polynomials
    ax = axes[0]
    x = np.linspace(0, 20, 500)
    ax.plot(x, np.exp(x), 'r-', linewidth=2, label='exp(x)')
    for n in [2, 4, 6, 8]:
        ax.plot(x, x**n, '--', linewidth=1, label=f'x^{n}')
    ax.set_yscale('log')
    ax.set_xlabel('x')
    ax.set_ylabel('f(x) [log scale]')
    ax.set_title('Exp vs Polynomial')
    ax.legend(fontsize=8)
    ax.set_ylim(1, 1e15)
    ax.grid(True, alpha=0.3)
    
    # Panel 2: Ratios exp(x)/x^n
    ax = axes[1]
    x = np.linspace(1, 30, 500)
    for n in [1, 3, 5, 10]:
        with np.errstate(divide='ignore', invalid='ignore'):
            ratio = np.exp(x) / x**(n+1)
        ax.plot(x, ratio, linewidth=1.5, label=f'exp(x)/x^{n+1}')
    ax.set_yscale('log')
    ax.set_xlabel('x')
    ax.set_ylabel('Ratio [log scale]')
    ax.set_title('Exponential Dominance Ratios')
    ax.legend(fontsize=8)
    ax.grid(True, alpha=0.3)
    
    # Panel 3: EML diagonal gap
    ax = axes[2]
    x = np.linspace(0.01, 5, 1000)
    gap = np.exp(x) - np.log(x)
    ax.plot(x, gap, 'b-', linewidth=2, label='exp(x) - log(x)')
    ax.axhline(y=2, color='r', linestyle='--', linewidth=1, label='Lower bound = 2')
    ax.set_xlabel('x')
    ax.set_ylabel('exp(x) - log(x)')
    ax.set_title('EML Diagonal Gap ≥ 2')
    ax.legend()
    ax.set_ylim(0, 15)
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('dominance_hierarchy.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: dominance_hierarchy.png")


def plot_log_negligibility():
    """Plot log(x)/x^α for various α, showing log negligibility."""
    try:
        import matplotlib.pyplot as plt
    except ImportError:
        print("matplotlib not available, skipping plot")
        return
    
    fig, ax = plt.subplots(figsize=(8, 5))
    x = np.linspace(1.1, 1000, 2000)
    
    for alpha in [0.01, 0.05, 0.1, 0.5, 1.0]:
        ratio = np.log(x) / x**alpha
        ax.plot(x, ratio, linewidth=1.5, label=f'α = {alpha}')
    
    ax.axhline(y=0, color='k', linestyle='-', linewidth=0.5)
    ax.set_xlabel('x')
    ax.set_ylabel('log(x) / x^α')
    ax.set_title('Logarithmic Negligibility: log(x)/x^α → 0')
    ax.legend()
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('log_negligibility.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: log_negligibility.png")


def plot_growth_hierarchy():
    """Plot the full growth level hierarchy."""
    try:
        import matplotlib.pyplot as plt
    except ImportError:
        print("matplotlib not available, skipping plot")
        return
    
    fig, ax = plt.subplots(figsize=(10, 6))
    x = np.linspace(1.5, 5, 500)
    
    functions = [
        (lambda x: np.log(np.log(x)), 'log(log(x))', (-2, 1), 'C0'),
        (lambda x: np.log(x), 'log(x)', (-1, 1), 'C1'),
        (lambda x: np.sqrt(x), '√x', (0, 0.5), 'C2'),
        (lambda x: x, 'x', (0, 1), 'C3'),
        (lambda x: x**2, 'x²', (0, 2), 'C4'),
        (lambda x: np.exp(np.sqrt(x)), 'exp(√x)', (1, 0.5), 'C5'),
        (lambda x: np.exp(x), 'exp(x)', (1, 1), 'C6'),
    ]
    
    for func, name, level, color in functions:
        with np.errstate(invalid='ignore'):
            y = func(x)
            mask = np.isfinite(y) & (y > 0) & (y < 1e6)
            ax.plot(x[mask], y[mask], linewidth=2, color=color,
                   label=f'{name}  [{level}]')
    
    ax.set_yscale('log')
    ax.set_xlabel('x', fontsize=12)
    ax.set_ylabel('f(x) [log scale]', fontsize=12)
    ax.set_title('Growth Level Hierarchy: Transseries Classification', fontsize=14)
    ax.legend(fontsize=9, loc='upper left')
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('growth_hierarchy.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: growth_hierarchy.png")


if __name__ == "__main__":
    plot_exp_vs_poly()
    plot_log_negligibility()
    plot_growth_hierarchy()
    print("All visualizations generated.")
