"""
Deep Compositional Approximation Demo
======================================

This script demonstrates the core mathematical results from the
compositional universal approximation theory:

1. Error propagation through Lipschitz compositions
2. The telescoping error formula for deep networks
3. Coordinatewise approximation of vector-valued functions
4. Visualization of the error bounds vs actual errors

The key insight: if each layer of a deep network is approximated
with error εᵢ, and each true layer has Lipschitz constant Lᵢ,
then the total end-to-end error satisfies the recursive bound:

    E(0) = 0,  E(n+1) = ε(n) + L(n) * E(n)

which unfolds to: E(n) = Σᵢ εᵢ · Πⱼ>ᵢ Lⱼ
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from typing import List


# ============================================================
# Core mathematical functions
# ============================================================

def deep_error_recursive(epsilons: List[float], lipschitz: List[float]) -> List[float]:
    """Compute the recursive error bound E(0), E(1), ..., E(n).

    E(0) = 0
    E(k+1) = ε(k) + L(k) * E(k)
    """
    n = len(epsilons)
    errors = [0.0]
    for k in range(n):
        errors.append(epsilons[k] + lipschitz[k] * errors[-1])
    return errors


def deep_error_sum(epsilons: List[float], lipschitz: List[float]) -> float:
    """Closed-form: E(n) = Σᵢ εᵢ · Πⱼ>ᵢ Lⱼ."""
    n = len(epsilons)
    total = 0.0
    for i in range(n):
        prod = 1.0
        for j in range(i + 1, n):
            prod *= lipschitz[j]
        total += epsilons[i] * prod
    return total


def deep_error_uniform_bound(delta: float, L: float, n: int) -> float:
    """Universal upper bound: n * δ * max(1, L)^n."""
    return n * delta * max(1, L) ** n


# ============================================================
# Demo 1: Error propagation through a deep composition
# ============================================================

def demo_error_propagation():
    """Demonstrate how errors accumulate through deep compositions."""
    print("=" * 60)
    print("Demo 1: Error Propagation Through Deep Compositions")
    print("=" * 60)

    n_layers = 5
    epsilons = [0.01, 0.02, 0.015, 0.01, 0.025]
    lipschitz = [2.0, 1.5, 3.0, 1.0, 2.0]

    errors = deep_error_recursive(epsilons, lipschitz)
    closed_form = deep_error_sum(epsilons, lipschitz)

    print(f"\nPer-layer errors:     {epsilons}")
    print(f"Lipschitz constants:  {lipschitz}")
    print(f"\nRecursive error bounds after each layer:")
    for k, e in enumerate(errors):
        print(f"  After layer {k}: E = {e:.6f}")
    print(f"\nClosed-form total: {closed_form:.6f}")
    print(f"Recursive total:   {errors[-1]:.6f}")
    print(f"Match: {abs(closed_form - errors[-1]) < 1e-10}")

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    ax1.plot(range(n_layers + 1), errors, 'b-o', linewidth=2, markersize=8, label='Recursive bound')
    ax1.axhline(y=sum(epsilons), color='g', linestyle='--', alpha=0.7, label='Sum of εᵢ (no amplification)')
    ax1.set_xlabel('Depth (number of layers)', fontsize=12)
    ax1.set_ylabel('Error bound', fontsize=12)
    ax1.set_title('Error Accumulation Through Deep Composition', fontsize=13)
    ax1.legend(fontsize=11)
    ax1.grid(True, alpha=0.3)

    contributions = []
    for i in range(n_layers):
        prod = 1.0
        for j in range(i + 1, n_layers):
            prod *= lipschitz[j]
        contributions.append(epsilons[i] * prod)

    ax2.bar(range(n_layers), contributions, color='steelblue', alpha=0.8)
    ax2.set_xlabel('Layer index i', fontsize=12)
    ax2.set_ylabel('Contribution εᵢ · Πⱼ>ᵢ Lⱼ', fontsize=12)
    ax2.set_title('Per-Layer Contribution to Total Error', fontsize=13)
    ax2.grid(True, alpha=0.3, axis='y')

    plt.tight_layout()
    plt.savefig('demos/error_propagation.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("\nSaved: demos/error_propagation.png")


# ============================================================
# Demo 2: Actual vs bounded error for concrete functions
# ============================================================

def demo_concrete_approximation():
    """Demonstrate the bound on concrete function compositions."""
    print("\n" + "=" * 60)
    print("Demo 2: Concrete Composition Approximation")
    print("=" * 60)

    eps = [0.05, 0.03, 0.02]
    lipschitz = [2.0, 1.0, 0.5]

    x = np.linspace(-2, 2, 1000)

    # True layers
    true_1 = np.tanh(2 * x)
    true_2 = np.sin(true_1)
    true_comp = 0.5 * true_2 + 0.3

    # Approximate layers
    approx_1 = np.tanh(2 * x) + eps[0] * np.sin(10 * x)
    approx_2 = np.sin(approx_1) + eps[1] * np.cos(5 * approx_1)
    approx_comp = 0.5 * approx_2 + 0.3 + eps[2]

    actual_error = np.abs(true_comp - approx_comp)
    max_actual_error = np.max(actual_error)

    errors = deep_error_recursive(eps, lipschitz)
    theoretical_bound = errors[-1]

    print(f"\nLayers: tanh(2x) → sin(x) → 0.5x + 0.3")
    print(f"Per-layer errors: {eps}")
    print(f"Lipschitz constants: {lipschitz}")
    print(f"\nMax actual error:    {max_actual_error:.6f}")
    print(f"Theoretical bound:   {theoretical_bound:.6f}")
    print(f"Bound is valid:      {max_actual_error <= theoretical_bound + 1e-10}")

    fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(12, 8))

    ax1.plot(x, true_comp, 'b-', linewidth=2, label='True: Φ₃ ∘ Φ₂ ∘ Φ₁')
    ax1.plot(x, approx_comp, 'r--', linewidth=1.5, label='Approx: Ψ₃ ∘ Ψ₂ ∘ Ψ₁')
    ax1.set_xlabel('x', fontsize=12)
    ax1.set_ylabel('Output', fontsize=12)
    ax1.set_title('True vs Approximate Deep Composition', fontsize=13)
    ax1.legend(fontsize=11)
    ax1.grid(True, alpha=0.3)

    ax2.fill_between(x, 0, actual_error, alpha=0.3, color='red', label='Actual error')
    ax2.axhline(y=theoretical_bound, color='blue', linestyle='--', linewidth=2,
                label=f'Telescoping bound = {theoretical_bound:.4f}')
    ax2.axhline(y=max_actual_error, color='red', linestyle=':', linewidth=1.5,
                label=f'Max actual error = {max_actual_error:.4f}')
    ax2.set_xlabel('x', fontsize=12)
    ax2.set_ylabel('|Error|', fontsize=12)
    ax2.set_title('Error Analysis: Actual vs Bound', fontsize=13)
    ax2.legend(fontsize=11)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('demos/concrete_approximation.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: demos/concrete_approximation.png")


# ============================================================
# Demo 3: Depth vs error bound scaling
# ============================================================

def demo_depth_scaling():
    """Show how error bounds scale with network depth."""
    print("\n" + "=" * 60)
    print("Demo 3: Error Bound Scaling with Depth")
    print("=" * 60)

    depths = range(1, 21)
    delta = 0.01

    fig, axes = plt.subplots(1, 3, figsize=(18, 5))

    for idx, (L_val, title) in enumerate([
        (0.8, 'Contractive (L=0.8)'),
        (1.0, 'Isometric (L=1.0)'),
        (1.5, 'Expansive (L=1.5)')
    ]):
        bounds = [deep_error_uniform_bound(delta, L_val, d) for d in depths]
        actual = [deep_error_recursive([delta]*d, [L_val]*d)[-1] for d in depths]
        axes[idx].plot(list(depths), actual, 'b-o', markersize=4, label='Recursive bound')
        axes[idx].plot(list(depths), bounds, 'r--', label='Uniform bound')
        axes[idx].set_title(title, fontsize=13)
        axes[idx].set_xlabel('Depth', fontsize=12)
        if idx == 0:
            axes[idx].set_ylabel('Error bound', fontsize=12)
        axes[idx].legend()
        axes[idx].grid(True, alpha=0.3)
        if L_val > 1:
            axes[idx].set_yscale('log')

    plt.suptitle(f'Error Scaling with Depth (δ = {delta} per layer)', fontsize=14, y=1.02)
    plt.tight_layout()
    plt.savefig('demos/depth_scaling.png', dpi=150, bbox_inches='tight')
    plt.close()

    print(f"\nδ = {delta} per layer")
    for L_val, name in [(0.8, 'Contractive'), (1.0, 'Isometric'), (1.5, 'Expansive')]:
        err = deep_error_recursive([delta]*20, [L_val]*20)[-1]
        print(f"  {name} (L={L_val}): Error at depth 20 = {err:.6f}")
    print("Saved: demos/depth_scaling.png")


# ============================================================
# Demo 4: Vector-valued coordinatewise approximation
# ============================================================

def demo_vector_approx():
    """Demonstrate coordinatewise approximation of vector-valued functions."""
    print("\n" + "=" * 60)
    print("Demo 4: Coordinatewise Vector-Valued Approximation")
    print("=" * 60)

    x = np.linspace(-np.pi, np.pi, 500)
    F_vals = np.array([np.sin(x), np.cos(x), x**2 / 10])
    m = 3

    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    coord_names = ['sin(x)', 'cos(x)', 'x²/10']

    approx_coords = []
    coord_errors = []
    for i in range(m):
        coeffs = np.polyfit(x, F_vals[i], 5)
        approx = np.polyval(coeffs, x)
        approx_coords.append(approx)
        max_err = np.max(np.abs(F_vals[i] - approx))
        coord_errors.append(max_err)

        ax = axes[0, i] if i < 2 else axes[1, 0]
        ax.plot(x, F_vals[i], 'b-', linewidth=2, label=f'F(x)[{i}] = {coord_names[i]}')
        ax.plot(x, approx, 'r--', linewidth=1.5, label=f'Poly approx')
        ax.set_title(f'Coordinate {i} (max err = {max_err:.4f})', fontsize=12)
        ax.legend()
        ax.grid(True, alpha=0.3)

    approx_coords = np.array(approx_coords)
    pointwise_errors = np.max(np.abs(F_vals - approx_coords), axis=0)
    max_sup_error = np.max(pointwise_errors)

    ax = axes[1, 1]
    ax.plot(x, pointwise_errors, 'purple', linewidth=1.5, label='ℓ∞ error')
    ax.axhline(y=max(coord_errors), color='red', linestyle='--',
               label=f'max coord error = {max(coord_errors):.4f}')
    ax.set_title('Vector-Valued Approximation Error', fontsize=12)
    ax.set_xlabel('x')
    ax.legend()
    ax.grid(True, alpha=0.3)

    plt.suptitle('Coordinatewise Approximation: F(x) = (sin x, cos x, x²/10)', fontsize=14)
    plt.tight_layout()
    plt.savefig('demos/vector_approx.png', dpi=150, bbox_inches='tight')
    plt.close()

    print(f"\nPer-coordinate max errors: {[f'{e:.4f}' for e in coord_errors]}")
    print(f"Max ℓ∞ error: {max_sup_error:.4f}")
    print(f"Key insight: ℓ∞ error = max of coordinate errors (no factor of m!)")
    print("Saved: demos/vector_approx.png")


# ============================================================
# Demo 5: Error allocation strategy
# ============================================================

def demo_error_allocation():
    """Show optimal error allocation across layers."""
    print("\n" + "=" * 60)
    print("Demo 5: Error Allocation Strategy")
    print("=" * 60)

    n_layers = 6
    target_error = 0.1
    lipschitz = [2.0, 1.5, 3.0, 1.0, 2.5, 1.8]

    delta_uniform = target_error / n_layers
    error_uniform = deep_error_recursive([delta_uniform]*n_layers, lipschitz)[-1]

    weights = []
    for i in range(n_layers):
        prod = 1.0
        for j in range(i + 1, n_layers):
            prod *= lipschitz[j]
        weights.append(prod)
    total_weight = sum(weights)
    delta_weighted = [target_error / total_weight] * n_layers
    error_weighted = deep_error_recursive(delta_weighted, lipschitz)[-1]

    delta_prop = [target_error / (n_layers * w) for w in weights]
    error_prop = deep_error_recursive(delta_prop, lipschitz)[-1]

    print(f"\nTarget total error: {target_error}")
    print(f"Lipschitz constants: {lipschitz}")
    print(f"\nStrategy 1 (Uniform δ = {delta_uniform:.4f}): error = {error_uniform:.4f}")
    print(f"Strategy 2 (Equal weight δ): error = {error_weighted:.4f}")
    print(f"Strategy 3 (Proportional): error = {error_prop:.4f}")

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    x = np.arange(n_layers)
    width = 0.25
    ax1.bar(x - width, [delta_uniform]*n_layers, width, label='Uniform', alpha=0.8)
    ax1.bar(x, delta_weighted, width, label='Equal weight', alpha=0.8)
    ax1.bar(x + width, delta_prop, width, label='Proportional', alpha=0.8)
    ax1.set_xlabel('Layer index', fontsize=12)
    ax1.set_ylabel('Per-layer tolerance δᵢ', fontsize=12)
    ax1.set_title('Error Allocation Strategies', fontsize=13)
    ax1.legend()
    ax1.grid(True, alpha=0.3, axis='y')

    strategies = ['Uniform', 'Equal\nweight', 'Proportional']
    total_errors = [error_uniform, error_weighted, error_prop]
    colors = ['steelblue', 'darkorange', 'forestgreen']
    ax2.bar(strategies, total_errors, color=colors, alpha=0.8)
    ax2.axhline(y=target_error, color='red', linestyle='--', linewidth=2, label='Target')
    ax2.set_ylabel('Total composition error', fontsize=12)
    ax2.set_title('Resulting Total Error by Strategy', fontsize=13)
    ax2.legend()
    ax2.grid(True, alpha=0.3, axis='y')

    plt.tight_layout()
    plt.savefig('demos/error_allocation.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: demos/error_allocation.png")


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print("Deep Compositional Approximation Theory — Numerical Demos")
    print("=" * 60)

    demo_error_propagation()
    demo_concrete_approximation()
    demo_depth_scaling()
    demo_vector_approx()
    demo_error_allocation()

    print("\n" + "=" * 60)
    print("All demos complete!")
    print("=" * 60)
