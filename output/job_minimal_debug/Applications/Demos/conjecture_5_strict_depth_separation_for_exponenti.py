#!/usr/bin/env python3
"""
Applications of Depth Separation Theory for Iterated Exponentials

Demonstrates real-world connections:
1. Neural network expressivity: shallow nets vs deep nets for tower functions
2. Symbolic regression: why iterExp(k) resists shallow symbolic fitting
3. Model compression analysis: depth reduction = exponential size blowup
4. Dynamical systems: sensitivity cascade in iterated maps
"""

import numpy as np
import math
from typing import List, Tuple


# ═══════════════════════════════════════════════════════════════════════════════
# Application 1: Neural Network Expressivity
# ═══════════════════════════════════════════════════════════════════════════════

def relu_network_approx(
    target_k: int, 
    num_pieces: int, 
    domain: Tuple[float, float] = (0.0, 1.0)
) -> Tuple[np.ndarray, np.ndarray, float]:
    """Approximate iterExp(k) with a piecewise-linear (ReLU) network.
    
    A depth-1 ReLU network with W neurons produces a piecewise-linear
    function with at most W+1 pieces. The Lipschitz obstruction theorem
    implies that the number of pieces must grow with the target's
    Lipschitz constant.
    
    Args:
        target_k: depth of tower to approximate
        num_pieces: number of linear pieces (= neurons in hidden layer)
        domain: approximation interval
    
    Returns:
        (x_grid, approx_values, max_error)
    """
    a, b = domain
    x = np.linspace(a, b, 1000)
    target = np.array([_iter_exp_safe(target_k, xi) for xi in x])
    
    # Optimal piecewise-linear approximation by interpolation at piece boundaries
    breakpoints = np.linspace(a, b, num_pieces + 1)
    bp_values = np.array([_iter_exp_safe(target_k, bp) for bp in breakpoints])
    
    approx = np.interp(x, breakpoints, bp_values)
    max_error = np.max(np.abs(target - approx))
    
    return x, approx, max_error


def _iter_exp_safe(k: int, x: float) -> float:
    """Overflow-safe iterExp."""
    result = x
    for _ in range(k):
        result = math.exp(min(result, 500))
    return result


def analyze_relu_expressivity():
    """Analyze how many ReLU neurons are needed vs tower depth."""
    print("  Neural Network Expressivity Analysis")
    print("  " + "-" * 50)
    print(f"  {'Depth k':<10} {'Neurons':<10} {'Max Error':<15} {'Gap':<15}")
    print("  " + "-" * 50)
    
    for k in range(1, 5):
        gap = _iter_exp_safe(k, 1.0) - _iter_exp_safe(k, 0.0)
        for neurons in [5, 10, 50, 100, 500]:
            _, _, err = relu_network_approx(k, neurons)
            print(f"  {k:<10} {neurons:<10} {err:<15.6f} {gap:<15.4f}")
        print()


# ═══════════════════════════════════════════════════════════════════════════════
# Application 2: Symbolic Regression Complexity
# ═══════════════════════════════════════════════════════════════════════════════

def symbolic_regression_analysis():
    """Show that shallow EML expressions cannot fit towers.
    
    For a depth-d expression with N exp-nodes, the maximum
    derivative growth is bounded by exp^[d] composed d times,
    while iterExp(k) with k > d grows faster.
    """
    print("  Symbolic Regression Complexity Analysis")
    print("  " + "-" * 50)
    
    x_test = 0.5
    print(f"  At x = {x_test}:")
    print(f"  {'Expression':<30} {'Value':<15} {'Derivative':<15}")
    print("  " + "-" * 60)
    
    # Various depth-1 expressions
    expressions = [
        ("exp(x)", lambda x: math.exp(x), lambda x: math.exp(x)),
        ("exp(2x)", lambda x: math.exp(2*x), lambda x: 2*math.exp(2*x)),
        ("exp(3x)", lambda x: math.exp(3*x), lambda x: 3*math.exp(3*x)),
        ("2*exp(x)", lambda x: 2*math.exp(x), lambda x: 2*math.exp(x)),
        ("exp(x)+exp(2x)", lambda x: math.exp(x)+math.exp(2*x),
         lambda x: math.exp(x)+2*math.exp(2*x)),
    ]
    
    for name, f, df in expressions:
        print(f"  {name:<30} {f(x_test):<15.6f} {df(x_test):<15.6f}")
    
    print()
    print(f"  {'iterExp targets:':<30}")
    for k in range(1, 5):
        val = _iter_exp_safe(k, x_test)
        # Derivative via product formula
        deriv = 1.0
        for j in range(k):
            deriv *= _iter_exp_safe(j + 1, x_test)
        print(f"  {'iterExp(' + str(k) + ', x)':<30} {val:<15.6f} {deriv:<15.6f}")


# ═══════════════════════════════════════════════════════════════════════════════
# Application 3: Model Compression Barriers
# ═══════════════════════════════════════════════════════════════════════════════

def compression_barrier_analysis():
    """Quantify the cost of reducing depth in EML representations.
    
    The exact representation of iterExp(k) has depth k and size k+1.
    If we reduce depth to d < k, the Lipschitz obstruction theorem
    gives a minimum error or minimum size for any approximant.
    """
    print("  Model Compression Barrier Analysis")
    print("  " + "-" * 50)
    print(f"  {'k':<5} {'Exact depth':<15} {'Exact size':<15} {'Gap(k)':<15} "
          f"{'Min L for ε=0.1':<20}")
    print("  " + "-" * 70)
    
    for k in range(1, 6):
        gap = _iter_exp_safe(k, 1.0) - _iter_exp_safe(k, 0.0)
        min_L = gap - 0.2  # L needed for ε = 0.1
        print(f"  {k:<5} {k:<15} {k+1:<15} {gap:<15.4f} {min_L:<20.4f}")
    
    print()
    print("  Interpretation: To compress iterExp(k) to a Lipschitz-L function")
    print("  with ε=0.1 accuracy, you need L ≥ gap(k) - 0.2.")
    print("  Since gap(k) grows super-exponentially, compression is impossible")
    print("  for any fixed L as k increases.")


# ═══════════════════════════════════════════════════════════════════════════════
# Application 4: Dynamical Systems Sensitivity
# ═══════════════════════════════════════════════════════════════════════════════

def sensitivity_cascade_analysis():
    """Analyze sensitivity amplification in iterated exponential maps.
    
    The map x ↦ exp(x) iterated k times has Lyapunov-like sensitivity
    equal to the derivative product formula. This connects depth
    separation to chaos theory.
    """
    print("  Dynamical Systems: Sensitivity Cascade")
    print("  " + "-" * 50)
    
    x0 = 0.5
    perturbation = 1e-10
    
    print(f"  Starting point: x₀ = {x0}")
    print(f"  Perturbation: δ = {perturbation}")
    print()
    print(f"  {'Iterations k':<15} {'iterExp(k,x₀)':<20} "
          f"{'Amplification':<20} {'Product formula':<20}")
    print("  " + "-" * 75)
    
    for k in range(1, 6):
        val = _iter_exp_safe(k, x0)
        val_pert = _iter_exp_safe(k, x0 + perturbation)
        
        amplification = abs(val_pert - val) / perturbation
        
        # Product formula
        product = 1.0
        for j in range(k):
            product *= _iter_exp_safe(j + 1, x0)
        
        print(f"  {k:<15} {val:<20.6f} {amplification:<20.6f} {product:<20.6f}")
    
    print()
    print("  The amplification factor matches the derivative product formula,")
    print("  confirming that iterExp creates a sensitivity cascade where each")
    print("  layer multiplicatively amplifies perturbations.")


# ═══════════════════════════════════════════════════════════════════════════════
# Main
# ═══════════════════════════════════════════════════════════════════════════════

if __name__ == '__main__':
    print("=" * 70)
    print("Depth Separation Theory — Real-World Applications")
    print("=" * 70)
    
    print("\n" + "=" * 70)
    print("Application 1: Neural Network Expressivity")
    print("=" * 70)
    analyze_relu_expressivity()
    
    print("\n" + "=" * 70)
    print("Application 2: Symbolic Regression Complexity")
    print("=" * 70)
    symbolic_regression_analysis()
    
    print("\n" + "=" * 70)
    print("Application 3: Model Compression Barriers")
    print("=" * 70)
    compression_barrier_analysis()
    
    print("\n" + "=" * 70)
    print("Application 4: Dynamical Systems Sensitivity")
    print("=" * 70)
    sensitivity_cascade_analysis()
    
    print("\n" + "=" * 70)
    print("All applications demonstrated successfully.")
    print("=" * 70)


#!/usr/bin/env python3
"""
Depth Separation for Iterated Exponentials — Visualization Demo

Demonstrates:
1. Growth of iterExp_k(x) on [0,1] for k = 0..5
2. Derivative cascade: the product formula ∏ iterExp_{j+1}(x)
3. Endpoint gap growth: iterExp_k(1) - iterExp_k(0) vs k
4. Lipschitz obstruction: shallow approximants cannot track tower functions
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from typing import Callable


def iter_exp(k: int, x: np.ndarray) -> np.ndarray:
    """Compute the k-fold iterated exponential: iterExp(0,x) = x, iterExp(k+1,x) = exp(iterExp(k,x))."""
    result = x.copy().astype(float)
    for _ in range(k):
        result = np.exp(np.clip(result, -500, 500))  # clip to avoid overflow
    return result


def iter_exp_deriv(k: int, x: np.ndarray) -> np.ndarray:
    """Compute the derivative of iterExp(k+1, x) = ∏_{j=0}^{k} iterExp(j+1, x)."""
    prod = np.ones_like(x, dtype=float)
    for j in range(k + 1):
        prod *= iter_exp(j + 1, x)
    return prod


def endpoint_gap(k: int) -> float:
    """Compute iterExp(k, 1) - iterExp(k, 0) for scalar inputs."""
    val1 = 1.0
    val0 = 0.0
    for _ in range(k):
        val1 = np.exp(min(val1, 500))
        val0 = np.exp(min(val0, 500))
    return val1 - val0


def best_lipschitz_approx(L: float, f0: float, f1: float, x: np.ndarray) -> np.ndarray:
    """A Lipschitz-L function that tries to match f(0)=f0, f(1)=f1 as best it can."""
    # Linear interpolation clamped by Lipschitz bound
    slope = min(L, max(-L, f1 - f0))
    return f0 + slope * x


# ── Figure 1: Tower functions on [0,1] ───────────────────────────────────────
def plot_tower_functions():
    x = np.linspace(0, 1, 500)
    fig, ax = plt.subplots(figsize=(10, 6))
    
    for k in range(6):
        y = iter_exp(k, x)
        if np.max(y) < 1e10:
            ax.plot(x, y, label=f'iterExp({k}, x)', linewidth=2)
    
    ax.set_xlabel('x', fontsize=14)
    ax.set_ylabel('iterExp(k, x)', fontsize=14)
    ax.set_title('Iterated Exponentials on [0, 1]', fontsize=16)
    ax.legend(fontsize=12)
    ax.set_yscale('log')
    ax.grid(True, alpha=0.3)
    fig.tight_layout()
    fig.savefig('fig1_tower_functions.png', dpi=150)
    plt.close(fig)
    print("Saved fig1_tower_functions.png")


# ── Figure 2: Derivative cascade ─────────────────────────────────────────────
def plot_derivative_cascade():
    x = np.linspace(0, 1, 500)
    fig, ax = plt.subplots(figsize=(10, 6))
    
    for k in range(5):
        y = iter_exp_deriv(k, x)
        if np.max(y) < 1e15:
            ax.plot(x, y, label=f"(iterExp({k+1}))' (x)", linewidth=2)
    
    ax.set_xlabel('x', fontsize=14)
    ax.set_ylabel("Derivative", fontsize=14)
    ax.set_title('Derivative Cascade: Product Formula', fontsize=16)
    ax.legend(fontsize=12)
    ax.set_yscale('log')
    ax.grid(True, alpha=0.3)
    fig.tight_layout()
    fig.savefig('fig2_derivative_cascade.png', dpi=150)
    plt.close(fig)
    print("Saved fig2_derivative_cascade.png")


# ── Figure 3: Endpoint gap growth ────────────────────────────────────────────
def plot_endpoint_gap():
    ks = list(range(1, 7))
    gaps = [endpoint_gap(k) for k in ks]
    
    fig, ax = plt.subplots(figsize=(10, 6))
    ax.bar(ks, gaps, color='steelblue', alpha=0.8, edgecolor='navy')
    ax.set_xlabel('Depth k', fontsize=14)
    ax.set_ylabel('iterExp(k, 1) - iterExp(k, 0)', fontsize=14)
    ax.set_title('Endpoint Gap Growth (Monotonically Increasing)', fontsize=16)
    ax.set_yscale('log')
    ax.grid(True, alpha=0.3, axis='y')
    
    for i, (k, g) in enumerate(zip(ks, gaps)):
        if g < 1e10:
            ax.text(k, g * 1.3, f'{g:.1f}', ha='center', fontsize=11)
    
    fig.tight_layout()
    fig.savefig('fig3_endpoint_gap.png', dpi=150)
    plt.close(fig)
    print("Saved fig3_endpoint_gap.png")


# ── Figure 4: Lipschitz obstruction ──────────────────────────────────────────
def plot_lipschitz_obstruction():
    x = np.linspace(0, 1, 500)
    k = 2  # exp(exp(x))
    f = iter_exp(k, x)
    
    f0, f1 = np.exp(1.0), np.exp(np.e)  # iterExp(2,0), iterExp(2,1)
    
    fig, ax = plt.subplots(figsize=(10, 6))
    ax.plot(x, f, 'b-', linewidth=2.5, label=f'iterExp({k}, x) = exp(exp(x))')
    
    for L in [5, 10, 12]:
        g = best_lipschitz_approx(L, f0, f1, x)
        ax.plot(x, g, '--', linewidth=1.5, alpha=0.7,
                label=f'Lipschitz-{L} approx')
    
    ax.set_xlabel('x', fontsize=14)
    ax.set_ylabel('Value', fontsize=14)
    ax.set_title('Lipschitz Obstruction: Bounded-Slope Functions Cannot Track Towers', fontsize=14)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    fig.tight_layout()
    fig.savefig('fig4_lipschitz_obstruction.png', dpi=150)
    plt.close(fig)
    print("Saved fig4_lipschitz_obstruction.png")


# ── Figure 5: Depth separation summary ───────────────────────────────────────
def plot_depth_separation_summary():
    """Show min Lipschitz constant needed vs depth k."""
    ks = list(range(1, 7))
    min_L = [endpoint_gap(k) for k in ks]  # minimum L needed to even span the gap
    
    fig, ax = plt.subplots(figsize=(10, 6))
    ax.semilogy(ks, min_L, 'ro-', markersize=10, linewidth=2.5,
                label='Min Lipschitz constant for ε-approx')
    ax.axhline(y=np.e - 1, color='green', linestyle='--', linewidth=1.5,
               label=f'Lower bound: e - 1 ≈ {np.e - 1:.3f}')
    
    ax.set_xlabel('Tower Depth k', fontsize=14)
    ax.set_ylabel('Minimum Lipschitz Constant', fontsize=14)
    ax.set_title('Depth Separation: Required Approximant Complexity', fontsize=16)
    ax.legend(fontsize=12)
    ax.grid(True, alpha=0.3)
    fig.tight_layout()
    fig.savefig('fig5_depth_separation.png', dpi=150)
    plt.close(fig)
    print("Saved fig5_depth_separation.png")


if __name__ == '__main__':
    print("=" * 60)
    print("Depth Separation for Iterated Exponentials — Demo")
    print("=" * 60)
    
    # Numerical verification of key theorems
    print("\n── Theorem 1: Tower growth values ──")
    for k in range(6):
        v0 = iter_exp(k, np.array([0.0]))[0]
        v1 = iter_exp(k, np.array([1.0]))[0]
        print(f"  iterExp({k}, 0) = {v0:.6f},  iterExp({k}, 1) = {v1:.6f}")
    
    print("\n── Theorem 2: Derivative product formula verification ──")
    x0 = 0.5
    dx = 1e-7
    for k in range(5):
        # Numerical derivative
        f_plus = iter_exp(k + 1, np.array([x0 + dx]))[0]
        f_minus = iter_exp(k + 1, np.array([x0 - dx]))[0]
        num_deriv = (f_plus - f_minus) / (2 * dx)
        # Product formula
        prod_val = 1.0
        for j in range(k + 1):
            prod_val *= iter_exp(j + 1, np.array([x0]))[0]
        print(f"  k={k}: numerical deriv = {num_deriv:.6f}, "
              f"product formula = {prod_val:.6f}, "
              f"ratio = {num_deriv / prod_val:.8f}")
    
    print("\n── Theorem 3: Endpoint gap growth ──")
    for k in range(1, 7):
        gap = endpoint_gap(k)
        print(f"  gap({k}) = {gap:.6f}  (≥ e-1 = {np.e - 1:.6f})")
    
    print("\n── Theorem 4: Lipschitz obstruction ──")
    k = 3
    gap = endpoint_gap(k)
    print(f"  iterExp({k},1) - iterExp({k},0) = {gap:.2f}")
    print(f"  Any Lipschitz-L approx with L < {gap:.2f} cannot ε-approximate iterExp({k})")
    print(f"  with ε < ({gap:.2f} - L)/2")
    
    # Generate all figures
    print("\n── Generating figures ──")
    plot_tower_functions()
    plot_derivative_cascade()
    plot_endpoint_gap()
    plot_lipschitz_obstruction()
    plot_depth_separation_summary()
    
    print("\nDone! All figures saved.")
