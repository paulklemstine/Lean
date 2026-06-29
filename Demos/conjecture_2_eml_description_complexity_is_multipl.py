#!/usr/bin/env python3
"""
Applications of EML Description Complexity Theory

Demonstrates real-world applications of multiplicative subadditivity:
1. Polynomial evaluation via Horner form
2. Correlation function approximation (many-body physics)
3. Neural network gating analysis
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from typing import List, Tuple


# ============================================================
# Application 1: Polynomial Evaluation Complexity
# ============================================================

def horner_complexity(degree: int, id_complexity: int) -> int:
    """
    Compute the EML complexity of polynomial evaluation via Horner's method.

    Horner form: p(x) = (...((a_d * x + a_{d-1}) * x + ...) * x + a_0)

    Each Horner step is: multiply by x (cost: current + id_complexity + 1)
    then add constant (cost: +2, for the constant leaf and add node).

    Total: d * (id_complexity + 3) + 1 for the initial coefficient.

    Args:
        degree: Polynomial degree.
        id_complexity: EML complexity of the identity function x.

    Returns:
        Upper bound on polynomial evaluation complexity.
    """
    if degree == 0:
        return 1  # Just a constant leaf
    # a_d (leaf: 1) then d iterations of: * x (id_complexity + 1) + a_i (2)
    return 1 + degree * (id_complexity + 1 + 2)


def demo_polynomial_complexity():
    """
    Visualize polynomial complexity growth via Horner form
    vs. naive monomial evaluation.
    """
    print("=" * 60)
    print("Application 1: Polynomial Evaluation Complexity")
    print("=" * 60)

    id_complexity = 1  # Identity is a leaf

    degrees = list(range(1, 21))
    horner_costs = [horner_complexity(d, id_complexity) for d in degrees]

    # Naive monomial: x^k needs k-1 multiplications + k leaves = 2k-1
    # p(x) = sum of d+1 monomials, each with cost ~2k, plus additions
    naive_costs = [sum(2*k + 1 for k in range(d+1)) + d for d in degrees]

    print(f"  {'Degree':>8} {'Horner':>10} {'Naive':>10} {'Ratio':>8}")
    print(f"  {'-'*8} {'-'*10} {'-'*10} {'-'*8}")
    for d in [1, 2, 5, 10, 15, 20]:
        h = horner_complexity(d, id_complexity)
        n = sum(2*k + 1 for k in range(d+1)) + d
        print(f"  {d:8d} {h:10d} {n:10d} {n/h:8.2f}x")

    fig, ax = plt.subplots(1, 1, figsize=(8, 5))
    ax.plot(degrees, horner_costs, 'b-o', label='Horner form', markersize=4)
    ax.plot(degrees, naive_costs, 'r--^', label='Naive monomial', markersize=4)
    ax.set_xlabel('Polynomial degree')
    ax.set_ylabel('Expression tree size')
    ax.set_title('Polynomial Evaluation Complexity')
    ax.legend()
    ax.grid(True, alpha=0.3)
    fig.tight_layout()
    fig.savefig('app_polynomial_complexity.png', dpi=150)
    plt.close()
    print(f"\n  → Saved: app_polynomial_complexity.png\n")


# ============================================================
# Application 2: Correlation Functions (Many-Body Physics)
# ============================================================

def demo_correlation_functions():
    """
    Show that products of bounded local observables inherit
    controlled description complexity.

    In statistical mechanics, correlation functions are:
        C(x₁,...,x_k) = ⟨O₁(x₁) · O₂(x₂) · ... · O_k(x_k)⟩

    For 1D systems restricted to an interval, these are
    products of bounded functions, and our theorem applies.
    """
    print("=" * 60)
    print("Application 2: Correlation Function Complexity")
    print("=" * 60)

    # Simulate bounded local observables
    B = 2.0
    epsilon = 0.01
    k_values = list(range(1, 11))

    print(f"  B = {B}, ε = {epsilon}")
    print(f"  Observable: O_i(x) = B · sin(i·x) (bounded by B)")
    print()

    x = np.linspace(0, np.pi, 200)

    per_observable_complexity = 5  # Assume each needs ~5 nodes
    correlation_bounds = []
    budgets = []

    for k in k_values:
        # Total complexity bound
        total = k * per_observable_complexity + (k - 1)
        correlation_bounds.append(total)

        # Error budget per factor
        delta = epsilon / (2 * k * (B + 1) ** (k - 1))
        budgets.append(delta)

        # Compute actual correlation function
        corr = np.ones_like(x)
        for i in range(1, k + 1):
            corr *= B * np.sin(i * x)

        if k in [1, 3, 5, 7, 10]:
            print(f"  k={k:2d}-point correlation: "
                  f"complexity ≤ {total:4d}, "
                  f"budget δ = {delta:.2e}, "
                  f"max|C| = {np.max(np.abs(corr)):.4f}")

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

    ax1.plot(k_values, correlation_bounds, 'b-o', markersize=4)
    ax1.set_xlabel('Number of observables k')
    ax1.set_ylabel('Complexity upper bound')
    ax1.set_title('Correlation Function Complexity')
    ax1.grid(True, alpha=0.3)

    ax2.semilogy(k_values, budgets, 'r-s', markersize=4)
    ax2.set_xlabel('Number of observables k')
    ax2.set_ylabel('Per-observable error budget')
    ax2.set_title('Error Budget for Correlations')
    ax2.grid(True, alpha=0.3)

    fig.tight_layout()
    fig.savefig('app_correlation_functions.png', dpi=150)
    plt.close()
    print(f"\n  → Saved: app_correlation_functions.png\n")


# ============================================================
# Application 3: Neural Network Gating Analysis
# ============================================================

def demo_gating_complexity():
    """
    Analyze the approximation cost of multiplicative gating,
    as used in attention mechanisms and gated recurrent units.

    A gating unit computes: gate(x) · value(x)
    where gate ∈ [0,1] and value is bounded.

    Our binary theorem says:
        C(gate · value) ≤ C(gate) + C(value) + 1

    For a stack of k gating layers:
        C(∏ gates_i · value) ≤ ∑ C(gate_i) + C(value) + k
    """
    print("=" * 60)
    print("Application 3: Neural Network Gating Complexity")
    print("=" * 60)

    # Simulate gating layers
    B_gate = 1.0  # Gates are sigmoid-bounded
    B_value = 5.0  # Values can be larger
    epsilon = 0.01

    gate_complexity = 3   # Sigmoid approximation
    value_complexity = 10  # More complex value function

    k_values = list(range(1, 16))

    print(f"  Gate complexity: {gate_complexity} (sigmoid)")
    print(f"  Value complexity: {value_complexity}")
    print()

    total_complexities = []
    for k in k_values:
        # k gates + 1 value = k+1 factors, k multiplications
        total = k * gate_complexity + value_complexity + k
        total_complexities.append(total)

        if k in [1, 5, 10, 15]:
            print(f"  {k:2d} gating layers: "
                  f"complexity ≤ {total:4d} "
                  f"({k}×{gate_complexity} + {value_complexity} + {k})")

    fig, ax = plt.subplots(1, 1, figsize=(8, 5))
    ax.plot(k_values, total_complexities, 'g-o', markersize=4)
    ax.plot(k_values, [value_complexity + k for k in k_values],
            'b--', label='Minimum (value + gates only)', alpha=0.5)
    ax.set_xlabel('Number of gating layers')
    ax.set_ylabel('Total complexity upper bound')
    ax.set_title('Gated Network Complexity Growth')
    ax.legend()
    ax.grid(True, alpha=0.3)
    fig.tight_layout()
    fig.savefig('app_gating_complexity.png', dpi=150)
    plt.close()
    print(f"\n  → Saved: app_gating_complexity.png\n")


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print("\n" + "=" * 60)
    print("EML Description Complexity: Applications")
    print("=" * 60 + "\n")

    demo_polynomial_complexity()
    demo_correlation_functions()
    demo_gating_complexity()

    print("=" * 60)
    print("All applications complete!")
    print("=" * 60)


#!/usr/bin/env python3
"""
Demo: EML Description Complexity — Multiplicative Subadditivity

Interactive demonstrations of the key theorems:
1. Product perturbation bounds
2. Error budget allocation
3. Complexity growth under multiplication
4. Balanced vs. linear tree comparison
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from typing import Callable, List, Tuple


# ============================================================
# Core mathematical functions
# ============================================================

def product_perturbation_bound(k: int, B: float, delta: float) -> float:
    """Theoretical upper bound: |∏u - ∏v| ≤ k * B^(k-1) * δ"""
    if k == 0:
        return 0.0
    return k * B ** (k - 1) * delta


def prod_error_budget(k: int, B: float, eps: float) -> float:
    """Error budget for k-fold product: δ = ε / (2k(B+1)^(k-1))"""
    if k == 0:
        return eps
    return eps / (2 * k * (B + 1) ** (k - 1))


def complexity_upper_bound(complexities: List[int]) -> int:
    """Upper bound on product complexity: sum + (k-1)"""
    k = len(complexities)
    if k == 0:
        return 0
    return sum(complexities) + (k - 1)


# ============================================================
# Demo 1: Product Perturbation Bound Visualization
# ============================================================

def demo_perturbation_bound():
    """
    Visualize the product perturbation bound k*B^(k-1)*δ
    compared to actual perturbation for random bounded sequences.
    """
    print("=" * 60)
    print("Demo 1: Product Perturbation Bound")
    print("=" * 60)

    np.random.seed(42)
    B = 2.0
    delta = 0.1
    k_values = list(range(1, 11))
    n_trials = 1000

    theoretical_bounds = []
    empirical_maxes = []

    for k in k_values:
        max_diff = 0.0
        for _ in range(n_trials):
            u = np.random.uniform(-B, B, size=k)
            perturbation = np.random.uniform(-delta, delta, size=k)
            v = np.clip(u + perturbation, -B, B)
            diff = abs(np.prod(u) - np.prod(v))
            max_diff = max(max_diff, diff)

        theoretical = product_perturbation_bound(k, B, delta)
        theoretical_bounds.append(theoretical)
        empirical_maxes.append(max_diff)

        print(f"  k={k:2d}: theoretical ≤ {theoretical:10.4f}, "
              f"empirical max = {max_diff:10.4f}, "
              f"ratio = {max_diff/theoretical:.4f}")

    fig, ax = plt.subplots(1, 1, figsize=(8, 5))
    ax.semilogy(k_values, theoretical_bounds, 'b-o', label='Theoretical bound: k·B^(k-1)·δ')
    ax.semilogy(k_values, empirical_maxes, 'r--x', label='Empirical maximum')
    ax.set_xlabel('Number of factors k')
    ax.set_ylabel('Product perturbation')
    ax.set_title(f'Product Perturbation Bound (B={B}, δ={delta})')
    ax.legend()
    ax.grid(True, alpha=0.3)
    fig.tight_layout()
    fig.savefig('demo_perturbation_bound.png', dpi=150)
    plt.close()
    print(f"\n  → Saved: demo_perturbation_bound.png\n")


# ============================================================
# Demo 2: Error Budget Allocation
# ============================================================

def demo_error_budget():
    """
    Visualize how the per-factor error budget shrinks
    as the number of factors increases.
    """
    print("=" * 60)
    print("Demo 2: Error Budget Allocation")
    print("=" * 60)

    eps = 0.1
    B_values = [1.0, 2.0, 5.0]
    k_values = list(range(1, 16))

    fig, ax = plt.subplots(1, 1, figsize=(8, 5))

    for B in B_values:
        budgets = [prod_error_budget(k, B, eps) for k in k_values]
        ax.semilogy(k_values, budgets, '-o', label=f'B = {B}', markersize=4)
        print(f"  B = {B}:")
        for k in [1, 2, 5, 10, 15]:
            if k <= len(k_values):
                budget = prod_error_budget(k, B, eps)
                print(f"    k={k:2d}: δ = {budget:.2e}")

    ax.set_xlabel('Number of factors k')
    ax.set_ylabel('Per-factor error budget δ')
    ax.set_title(f'Error Budget Allocation (ε = {eps})')
    ax.legend()
    ax.grid(True, alpha=0.3)
    fig.tight_layout()
    fig.savefig('demo_error_budget.png', dpi=150)
    plt.close()
    print(f"\n  → Saved: demo_error_budget.png\n")


# ============================================================
# Demo 3: Complexity Growth Under Multiplication
# ============================================================

def demo_complexity_growth():
    """
    Show how product complexity grows with the number of factors.
    Compare theoretical upper bound with simulated complexity.
    """
    print("=" * 60)
    print("Demo 3: Complexity Growth Under Multiplication")
    print("=" * 60)

    np.random.seed(123)
    k_values = list(range(1, 21))

    # Simulate functions with random complexities
    base_complexities = np.random.randint(3, 15, size=20)

    cumulative_sums = []
    upper_bounds = []

    for k in k_values:
        cs = base_complexities[:k].tolist()
        bound = complexity_upper_bound(cs)
        cumulative_sums.append(sum(cs))
        upper_bounds.append(bound)

        if k in [1, 5, 10, 15, 20]:
            print(f"  k={k:2d}: ∑cᵢ = {sum(cs):4d}, "
                  f"bound = {bound:4d} (= ∑cᵢ + {k-1})")

    fig, ax = plt.subplots(1, 1, figsize=(8, 5))
    ax.plot(k_values, cumulative_sums, 'b-o', label='∑ cᵢ (sum of factor complexities)',
            markersize=4)
    ax.plot(k_values, upper_bounds, 'r--^', label='∑ cᵢ + (k-1) (product complexity bound)',
            markersize=4)
    ax.fill_between(k_values, cumulative_sums, upper_bounds, alpha=0.2, color='red',
                    label='Overhead: k-1 multiplication gates')
    ax.set_xlabel('Number of factors k')
    ax.set_ylabel('Complexity (tree size)')
    ax.set_title('Complexity Growth Under Multiplication')
    ax.legend()
    ax.grid(True, alpha=0.3)
    fig.tight_layout()
    fig.savefig('demo_complexity_growth.png', dpi=150)
    plt.close()
    print(f"\n  → Saved: demo_complexity_growth.png\n")


# ============================================================
# Demo 4: Balanced vs. Linear Tree Comparison
# ============================================================

def build_linear_tree_error(k: int, B: float, delta: float) -> float:
    """
    Error from left-to-right multiplication tree.
    Each multiplication accumulates error via the Leibniz rule.
    """
    # Track accumulated bound and error
    if k == 0:
        return 0.0
    if k == 1:
        return delta

    # After first factor: bound = B, error = delta
    acc_bound = B
    acc_error = delta

    for i in range(1, k):
        # Multiply accumulated product by factor i
        # |P*f - P'*f'| ≤ |P|*|f-f'| + |f'|*|P-P'|
        # ≤ acc_bound * delta + (B + delta) * acc_error
        new_error = acc_bound * delta + (B + delta) * acc_error
        new_bound = acc_bound * (B + delta)
        acc_error = new_error
        acc_bound = new_bound

    return acc_error


def build_balanced_tree_error(k: int, B: float, delta: float) -> float:
    """
    Error from balanced binary multiplication tree.
    Recursively splits the product into two halves.
    """
    if k == 0:
        return 0.0
    if k == 1:
        return delta

    half = k // 2
    err_left = build_balanced_tree_error(half, B, delta)
    err_right = build_balanced_tree_error(k - half, B, delta)

    bound_left = (B + delta) ** half
    bound_right = (B + delta) ** (k - half)

    # |L*R - L'*R'| ≤ |L|*err_R + |R'|*err_L
    return bound_left * err_right + bound_right * err_left


def demo_balanced_vs_linear():
    """
    Compare error propagation in linear vs. balanced tree strategies.
    Tests whether balanced trees give better error control.
    """
    print("=" * 60)
    print("Demo 4: Balanced vs. Linear Tree Comparison")
    print("=" * 60)

    B = 1.5
    delta = 0.01
    k_values = list(range(2, 21))

    linear_errors = []
    balanced_errors = []
    theoretical_bounds = []

    for k in k_values:
        lin_err = build_linear_tree_error(k, B, delta)
        bal_err = build_balanced_tree_error(k, B, delta)
        theo_bound = product_perturbation_bound(k, B + 1, delta)

        linear_errors.append(lin_err)
        balanced_errors.append(bal_err)
        theoretical_bounds.append(theo_bound)

        if k in [2, 5, 10, 15, 20]:
            print(f"  k={k:2d}: linear err = {lin_err:.6f}, "
                  f"balanced err = {bal_err:.6f}, "
                  f"ratio = {bal_err/lin_err:.4f}")

    fig, ax = plt.subplots(1, 1, figsize=(8, 5))
    ax.semilogy(k_values, linear_errors, 'b-o', label='Linear (left-to-right)', markersize=4)
    ax.semilogy(k_values, balanced_errors, 'g-s', label='Balanced (binary tree)', markersize=4)
    ax.semilogy(k_values, theoretical_bounds, 'r--', label='Theoretical bound', linewidth=1)
    ax.set_xlabel('Number of factors k')
    ax.set_ylabel('Product approximation error')
    ax.set_title(f'Error Propagation: Linear vs Balanced (B={B}, δ={delta})')
    ax.legend()
    ax.grid(True, alpha=0.3)
    fig.tight_layout()
    fig.savefig('demo_balanced_vs_linear.png', dpi=150)
    plt.close()
    print(f"\n  → Saved: demo_balanced_vs_linear.png\n")


# ============================================================
# Demo 5: Falsifiable Conjecture Test
# ============================================================

def demo_conjecture_test():
    """
    Test the balanced tree improvement conjecture:
    Can the linear overhead (k-1) be reduced to O(log k)?

    We compare the error achieved by balanced vs linear trees
    at matching tree sizes to see if balanced trees are strictly better.
    """
    print("=" * 60)
    print("Demo 5: Balanced Tree Conjecture Test")
    print("=" * 60)

    B = 2.0
    eps = 0.1
    k_values = [2, 4, 8, 16, 32]

    print(f"\n  Testing if balanced trees need fewer total nodes...")
    print(f"  (Both strategies have the same total tree size = ∑cᵢ + k-1)")
    print(f"  The question is whether balanced trees achieve better ERROR.\n")

    for k in k_values:
        # For fixed tree size, compare error
        delta_budget = prod_error_budget(k, B, eps)
        lin_err = build_linear_tree_error(k, B, delta_budget)
        bal_err = build_balanced_tree_error(k, B, delta_budget)

        improvement = (lin_err - bal_err) / lin_err * 100 if lin_err > 0 else 0

        print(f"  k={k:3d}: δ_budget = {delta_budget:.2e}, "
              f"linear err = {lin_err:.2e}, "
              f"balanced err = {bal_err:.2e}, "
              f"improvement = {improvement:+.1f}%")

    print(f"\n  Conclusion: Balanced trees {'DO' if improvement > 0 else 'do NOT'} "
          f"improve error at the same tree size.")
    print(f"  The conjecture predicts this translates to fewer nodes needed.\n")


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print("\n" + "=" * 60)
    print("EML Description Complexity: Multiplicative Subadditivity")
    print("Interactive Demonstrations")
    print("=" * 60 + "\n")

    demo_perturbation_bound()
    demo_error_budget()
    demo_complexity_growth()
    demo_balanced_vs_linear()
    demo_conjecture_test()

    print("=" * 60)
    print("All demos complete!")
    print("=" * 60)
