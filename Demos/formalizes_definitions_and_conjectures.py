"""
Applications of Tropical Proof Theory
======================================

Real-world applications of the certified tropical stability theorems.
"""

import numpy as np
from typing import List, Tuple


def tropical_agg(w: np.ndarray, x: np.ndarray) -> float:
    return float(np.max(w + x))


# ──────────────────────────────────────────────────────────────
# Application 1: Certified Robust Routing in Neural Networks
# ──────────────────────────────────────────────────────────────

def certified_robust_routing():
    """
    Application: Certifying robustness of neural routing decisions.
    
    In mixture-of-experts or routing networks, the routing decision
    is: select expert i* = argmax_i (score_i + value_i).
    
    Our theorem guarantees: if input features are perturbed by at most ε
    in sup norm, the routing score changes by at most ε.
    This means adversarial perturbations cannot drastically change
    which expert is selected, unless the margin between experts is < 2ε.
    """
    print("=" * 60)
    print("APPLICATION 1: Certified Robust Neural Routing")
    print("=" * 60)
    
    np.random.seed(42)
    n_experts = 8
    input_dim = 16
    
    # Expert scoring weights
    W = np.random.randn(n_experts, input_dim) * 0.5
    
    # Clean input
    x_clean = np.random.randn(input_dim)
    
    # Compute expert scores
    expert_scores = np.array([tropical_agg(W[j], x_clean) for j in range(n_experts)])
    selected = np.argmax(expert_scores)
    margin = np.sort(expert_scores)[-1] - np.sort(expert_scores)[-2]
    
    print(f"\n  {n_experts} experts, {input_dim}-dimensional input")
    print(f"  Selected expert: {selected}")
    print(f"  Expert scores: {expert_scores.round(3)}")
    print(f"  Selection margin: {margin:.4f}")
    
    # Certified robustness radius
    eps_cert = margin / 2  # if perturbation < margin/2, selection is stable
    print(f"\n  Certified robustness radius: ε < {eps_cert:.4f}")
    print(f"  (Any perturbation smaller than this cannot change the routing)")
    
    # Verify empirically
    n_attacks = 1000
    flips = 0
    for _ in range(n_attacks):
        delta = np.random.randn(input_dim)
        delta = delta / np.max(np.abs(delta)) * eps_cert * 0.99
        x_pert = x_clean + delta
        
        pert_scores = np.array([tropical_agg(W[j], x_pert) for j in range(n_experts)])
        if np.argmax(pert_scores) != selected:
            flips += 1
    
    print(f"  Empirical verification: {flips}/{n_attacks} routing flips "
          f"within certified radius")
    print(f"  (Expected: 0 flips — theorem guarantees this)")


# ──────────────────────────────────────────────────────────────
# Application 2: Robust Priority Scheduling
# ──────────────────────────────────────────────────────────────

def robust_priority_scheduling():
    """
    Application: Priority scheduling with guaranteed stability.
    
    In real-time systems, tasks have priorities computed from features.
    Tropical aggregation computes: priority = max_i(weight_i + feature_i).
    
    The 1-Lipschitz theorem guarantees: noisy sensor readings
    (±ε error) change priority scores by at most ε.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: Robust Priority Scheduling")
    print("=" * 60)
    
    np.random.seed(123)
    n_tasks = 5
    n_features = 4
    
    task_names = ["Emergency", "Maintenance", "Logging", "Backup", "Monitoring"]
    
    # Priority weights for each task
    W = np.array([
        [10, 5, 0, 2],    # Emergency: heavily weights urgency
        [2, 8, 1, 3],     # Maintenance: weights resource availability
        [0, 0, 7, 1],     # Logging: weights data freshness
        [1, 3, 2, 9],     # Backup: weights storage state
        [3, 3, 3, 3],     # Monitoring: balanced
    ], dtype=float)
    
    # True sensor readings
    features = np.array([2.0, 5.0, 3.0, 1.0])
    sensor_noise = 0.5  # ±0.5 measurement error
    
    priorities = np.array([tropical_agg(W[j], features) for j in range(n_tasks)])
    
    print(f"\n  True features: {features}")
    print(f"  Sensor noise: ±{sensor_noise}")
    print(f"\n  Task priorities:")
    for i, (name, p) in enumerate(zip(task_names, priorities)):
        print(f"    {name:>12}: {p:.2f}")
    
    print(f"\n  By the 1-Lipschitz theorem:")
    print(f"  Each priority can shift by at most {sensor_noise:.2f}")
    print(f"  Priority ordering is stable if margins exceed {2*sensor_noise:.2f}")
    
    sorted_idx = np.argsort(-priorities)
    for i in range(len(sorted_idx) - 1):
        margin = priorities[sorted_idx[i]] - priorities[sorted_idx[i+1]]
        stable = "✓ stable" if margin > 2 * sensor_noise else "⚠ may swap"
        print(f"    {task_names[sorted_idx[i]]} → {task_names[sorted_idx[i+1]]}: "
              f"margin={margin:.2f} {stable}")


# ──────────────────────────────────────────────────────────────
# Application 3: Tropical Proof Search with Stability Guarantees
# ──────────────────────────────────────────────────────────────

def tropical_proof_search():
    """
    Application: Proof search interpreted as tropical optimization.
    
    Proof terms are scored by a tropical aggregator.
    The stability theorem ensures that approximate scoring
    (e.g., from a learned heuristic) gives near-optimal proof selection.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: Tropical Proof Search")
    print("=" * 60)
    
    np.random.seed(456)
    
    # Proof candidates with feature scores
    proof_names = [
        "Direct computation",
        "Induction on n",
        "Contradiction",
        "Case analysis",
        "Algebraic manipulation",
    ]
    
    n_proofs = len(proof_names)
    n_criteria = 3  # simplicity, generality, efficiency
    
    # Scoring weights (learned or handcrafted)
    true_weights = np.array([2.0, 3.0, 1.5])  # true preference
    
    # Proof features
    features = np.array([
        [5, 2, 4],   # direct: simple but specific
        [3, 5, 3],   # induction: general
        [4, 3, 2],   # contradiction: moderate
        [2, 4, 5],   # case analysis: efficient
        [4, 4, 4],   # algebraic: balanced
    ], dtype=float)
    
    # True scores
    true_scores = np.array([tropical_agg(true_weights, features[i])
                           for i in range(n_proofs)])
    best = np.argmax(true_scores)
    
    print(f"\n  Criteria weights: simplicity={true_weights[0]}, "
          f"generality={true_weights[1]}, efficiency={true_weights[2]}")
    print(f"\n  Proof scores (tropical aggregation):")
    for i, (name, score) in enumerate(zip(proof_names, true_scores)):
        marker = " ← BEST" if i == best else ""
        print(f"    {name:>25}: {score:.2f}{marker}")
    
    # Now: what if weights are only approximately known?
    weight_error = 0.3
    print(f"\n  If weights are known only to ±{weight_error}:")
    print(f"  Score error ≤ {weight_error} (by 1-Lipschitz theorem)")
    print(f"  Selection is stable if margin > {2*weight_error}")
    
    margin = true_scores[best] - np.sort(true_scores)[-2]
    print(f"  Best-to-second margin: {margin:.2f}")
    if margin > 2 * weight_error:
        print(f"  → Approximate weights still select the optimal proof ✓")
    else:
        print(f"  → Selection may change (margin too small)")


if __name__ == "__main__":
    certified_robust_routing()
    robust_priority_scheduling()
    tropical_proof_search()
    
    print("\n" + "=" * 60)
    print("ALL APPLICATIONS DEMONSTRATED")
    print("=" * 60)


"""
Quantitative Tropical Proof Theory — Demonstrations
====================================================

Concrete numerical examples demonstrating the certified theorems:
1. Tropical aggregation is 1-Lipschitz
2. Tropical selection (hard attention) is 2-Lipschitz
3. ReLU-tropical composition preserves the Lipschitz bound
4. Tropical residuation (implication)
5. Composition of tropical layers preserves stability
"""

import numpy as np
from typing import Callable

# ──────────────────────────────────────────────────────────────
# Core definitions (matching the Lean formalization)
# ──────────────────────────────────────────────────────────────

def tropical_agg(w: np.ndarray, x: np.ndarray) -> float:
    """T_w(x) = max_i (w_i + x_i)"""
    return np.max(w + x)

def tropical_select(scores: np.ndarray, values: np.ndarray) -> float:
    """S(scores, values) = max_i (scores_i + values_i)"""
    return np.max(scores + values)

def tropical_relu_agg(w: np.ndarray, x: np.ndarray, b: float) -> float:
    """R_{w,b}(x) = max(T_w(x) + b, 0)"""
    return max(tropical_agg(w, x) + b, 0.0)

def trop_imp(a: float, c: float) -> float:
    """Tropical implication: a =>_T c := c - a"""
    return c - a


# ──────────────────────────────────────────────────────────────
# Demo 1: Tropical Aggregation is 1-Lipschitz
# ──────────────────────────────────────────────────────────────

def demo_lipschitz():
    """Demonstrate that |T_w(x) - T_w(y)| ≤ max_i |x_i - y_i|."""
    print("=" * 60)
    print("DEMO 1: Tropical Aggregation is 1-Lipschitz")
    print("=" * 60)
    
    np.random.seed(42)
    n = 5
    w = np.random.randn(n)
    
    print(f"\nWeights w = {w.round(3)}")
    print(f"\nTesting with 10,000 random perturbations...")
    
    max_ratio = 0.0
    for _ in range(10000):
        x = np.random.randn(n)
        eps = np.random.uniform(0.01, 2.0)
        delta = np.random.randn(n)
        delta = delta / np.max(np.abs(delta)) * eps  # scale so max|delta_i| = eps
        y = x + delta
        
        lhs = abs(tropical_agg(w, x) - tropical_agg(w, y))
        rhs = np.max(np.abs(x - y))
        
        ratio = lhs / rhs if rhs > 1e-15 else 0.0
        max_ratio = max(max_ratio, ratio)
        
        assert lhs <= rhs + 1e-10, f"Lipschitz violated! {lhs} > {rhs}"
    
    print(f"  All 10,000 tests passed ✓")
    print(f"  Maximum ratio |T_w(x)-T_w(y)| / sup|x_i-y_i| = {max_ratio:.6f}")
    print(f"  (must be ≤ 1.0, and it is: {max_ratio <= 1.0 + 1e-10})")
    
    # Concrete example
    x = np.array([1.0, 3.0, 2.0, 0.5, 4.0])
    y = np.array([1.1, 2.8, 2.3, 0.6, 3.9])
    eps = np.max(np.abs(x - y))
    
    print(f"\nConcrete example:")
    print(f"  x = {x}")
    print(f"  y = {y}")
    print(f"  w = {w.round(3)}")
    print(f"  T_w(x) = {tropical_agg(w, x):.4f}")
    print(f"  T_w(y) = {tropical_agg(w, y):.4f}")
    print(f"  |T_w(x) - T_w(y)| = {abs(tropical_agg(w, x) - tropical_agg(w, y)):.4f}")
    print(f"  max|x_i - y_i| = {eps:.4f}")
    print(f"  Bound holds: {abs(tropical_agg(w, x) - tropical_agg(w, y)) <= eps + 1e-10} ✓")


# ──────────────────────────────────────────────────────────────
# Demo 2: Tropical Selection is 2-Lipschitz
# ──────────────────────────────────────────────────────────────

def demo_select_lipschitz():
    """Demonstrate that changing scores and values by ε each
    changes the selection by at most 2ε."""
    print("\n" + "=" * 60)
    print("DEMO 2: Tropical Selection (Hard Attention) is 2-Lipschitz")
    print("=" * 60)
    
    np.random.seed(123)
    n = 6
    
    print(f"\nTesting with 10,000 random perturbations (n={n})...")
    
    max_ratio = 0.0
    for _ in range(10000):
        scores1 = np.random.randn(n)
        values1 = np.random.randn(n)
        eps = np.random.uniform(0.01, 2.0)
        
        ds = np.random.randn(n)
        ds = ds / np.max(np.abs(ds)) * eps
        dv = np.random.randn(n)
        dv = dv / np.max(np.abs(dv)) * eps
        
        scores2 = scores1 + ds
        values2 = values1 + dv
        
        lhs = abs(tropical_select(scores1, values1) - tropical_select(scores2, values2))
        rhs = 2 * eps
        
        ratio = lhs / rhs if rhs > 1e-15 else 0.0
        max_ratio = max(max_ratio, ratio)
        
        assert lhs <= rhs + 1e-10, f"2-Lipschitz violated!"
    
    print(f"  All 10,000 tests passed ✓")
    print(f"  Maximum ratio = {max_ratio:.6f} (must be ≤ 1.0)")
    
    # Show the 2ε bound is tight
    print(f"\n  The factor 2 is tight:")
    scores1 = np.array([0.0, 0.0])
    values1 = np.array([0.0, 0.0])
    eps = 1.0
    scores2 = np.array([eps, -eps])
    values2 = np.array([eps, -eps])
    diff = abs(tropical_select(scores1, values1) - tropical_select(scores2, values2))
    print(f"  scores₁ = {scores1}, values₁ = {values1}")
    print(f"  scores₂ = {scores2}, values₂ = {values2}")
    print(f"  |S₁ - S₂| = {diff}, 2ε = {2*eps}")
    print(f"  Ratio = {diff/(2*eps):.4f} (approaches 1 = tight)")


# ──────────────────────────────────────────────────────────────
# Demo 3: ReLU-Tropical Composition is 1-Lipschitz
# ──────────────────────────────────────────────────────────────

def demo_relu_lipschitz():
    """Demonstrate that ReLU ∘ tropical_agg is still 1-Lipschitz."""
    print("\n" + "=" * 60)
    print("DEMO 3: ReLU-Tropical Aggregation is 1-Lipschitz")
    print("=" * 60)
    
    np.random.seed(456)
    n = 4
    w = np.random.randn(n)
    b = -1.5  # bias that creates interesting ReLU behavior
    
    print(f"\nWeights w = {w.round(3)}, bias b = {b}")
    print(f"Testing with 10,000 random perturbations...")
    
    max_ratio = 0.0
    relu_active_count = 0
    for _ in range(10000):
        x = np.random.randn(n) * 2
        eps = np.random.uniform(0.01, 2.0)
        delta = np.random.randn(n)
        delta = delta / np.max(np.abs(delta)) * eps
        y = x + delta
        
        rx = tropical_relu_agg(w, x, b)
        ry = tropical_relu_agg(w, y, b)
        
        if rx > 0 or ry > 0:
            relu_active_count += 1
        
        lhs = abs(rx - ry)
        rhs = np.max(np.abs(x - y))
        
        ratio = lhs / rhs if rhs > 1e-15 else 0.0
        max_ratio = max(max_ratio, ratio)
        
        assert lhs <= rhs + 1e-10, f"ReLU Lipschitz violated!"
    
    print(f"  All 10,000 tests passed ✓")
    print(f"  Maximum ratio = {max_ratio:.6f}")
    print(f"  ReLU was active in {relu_active_count}/10,000 cases")
    print(f"  (ReLU can only reduce the Lipschitz constant, never increase it)")


# ──────────────────────────────────────────────────────────────
# Demo 4: Tropical Residuation (Implication)
# ──────────────────────────────────────────────────────────────

def demo_residuation():
    """Demonstrate the adjunction: a + b ≤ c ⟺ b ≤ c - a."""
    print("\n" + "=" * 60)
    print("DEMO 4: Tropical Residuation (Quantitative Implication)")
    print("=" * 60)
    
    examples = [
        (3.0, 2.0, 6.0),
        (3.0, 4.0, 6.0),
        (-1.0, 5.0, 3.0),
        (0.0, 0.0, 0.0),
    ]
    
    print(f"\n{'a':>6} {'b':>6} {'c':>6} | {'a+b≤c':>8} {'b≤c-a':>8} | {'Match':>6}")
    print("-" * 55)
    for a, b, c in examples:
        lhs = (a + b <= c)
        rhs = (b <= trop_imp(a, c))
        print(f"{a:>6.1f} {b:>6.1f} {c:>6.1f} | {str(lhs):>8} {str(rhs):>8} | {str(lhs == rhs):>6}")
    
    print(f"\n  The adjunction a + b ≤ c ⟺ b ≤ (a ⇒_T c) always holds ✓")
    print(f"  This is tropical modus ponens: from b ≤ c-a, conclude a+b ≤ c")
    
    # Interpretation
    print(f"\n  Curry–Howard interpretation:")
    print(f"  - 'a' = strength of assumption/evidence")
    print(f"  - 'b' = strength of implication/transformation")
    print(f"  - 'c' = required conclusion strength")
    print(f"  - a ⇒_T c = c - a = 'how much capacity the implication needs'")


# ──────────────────────────────────────────────────────────────
# Demo 5: Layered Composition Preserves Stability
# ──────────────────────────────────────────────────────────────

def demo_composition():
    """Demonstrate that composing tropical layers preserves the Lipschitz bound."""
    print("\n" + "=" * 60)
    print("DEMO 5: Layered Tropical Composition is 1-Lipschitz")
    print("=" * 60)
    
    np.random.seed(789)
    m = 4   # input dimension
    n = 3   # number of intermediate nodes
    
    # Two-layer tropical network
    W = np.random.randn(n, m)  # first layer weights
    w1 = np.random.randn(n)    # second layer weights
    
    def two_layer(x):
        intermediates = np.array([tropical_agg(W[i], x) for i in range(n)])
        return tropical_agg(w1, intermediates)
    
    print(f"\nTwo-layer tropical network: {m} inputs → {n} hidden → 1 output")
    print(f"Testing 1-Lipschitz property through composition...")
    
    max_ratio = 0.0
    for _ in range(10000):
        x = np.random.randn(m) * 2
        eps = np.random.uniform(0.01, 2.0)
        delta = np.random.randn(m)
        delta = delta / np.max(np.abs(delta)) * eps
        y = x + delta
        
        lhs = abs(two_layer(x) - two_layer(y))
        rhs = np.max(np.abs(x - y))
        
        ratio = lhs / rhs if rhs > 1e-15 else 0.0
        max_ratio = max(max_ratio, ratio)
        
        assert lhs <= rhs + 1e-10, "Composition Lipschitz violated!"
    
    print(f"  All 10,000 tests passed ✓")
    print(f"  Maximum ratio through 2 layers = {max_ratio:.6f}")
    print(f"  (Still ≤ 1.0: composition does NOT amplify perturbations)")
    
    # Three layers
    p = 2
    W2 = np.random.randn(p, n)
    w2 = np.random.randn(p)
    
    def three_layer(x):
        layer1 = np.array([tropical_agg(W[i], x) for i in range(n)])
        layer2 = np.array([tropical_agg(W2[j], layer1) for j in range(p)])
        return tropical_agg(w2, layer2)
    
    max_ratio_3 = 0.0
    for _ in range(10000):
        x = np.random.randn(m) * 2
        eps = np.random.uniform(0.01, 2.0)
        delta = np.random.randn(m)
        delta = delta / np.max(np.abs(delta)) * eps
        y = x + delta
        
        lhs = abs(three_layer(x) - three_layer(y))
        rhs = np.max(np.abs(x - y))
        
        ratio = lhs / rhs if rhs > 1e-15 else 0.0
        max_ratio_3 = max(max_ratio_3, ratio)
    
    print(f"\n  Three-layer network ({m}→{n}→{p}→1):")
    print(f"  Maximum ratio = {max_ratio_3:.6f}")
    print(f"  Still 1-Lipschitz through 3 layers! ✓")


if __name__ == "__main__":
    demo_lipschitz()
    demo_select_lipschitz()
    demo_relu_lipschitz()
    demo_residuation()
    demo_composition()
    
    print("\n" + "=" * 60)
    print("ALL DEMONSTRATIONS COMPLETE")
    print("=" * 60)
    print("\nThese numerical experiments confirm the certified theorems:")
    print("  1. tropicalAgg_lipschitz_of_pointwise")
    print("  2. tropicalSelect_lipschitz")
    print("  3. tropicalReluAgg_lipschitz_of_pointwise")
    print("  4. trop_residuation")
    print("  5. tropicalAgg_comp_lipschitz")


"""
Visualizations for Tropical Proof Theory
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import base64
import io
import json


def tropical_agg(w, x):
    return float(np.max(w + x))


def fig_to_base64(fig):
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    data = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{data}"


def viz_lipschitz_cloud():
    """Scatter plot: |T_w(x)-T_w(y)| vs max|x_i-y_i|."""
    np.random.seed(42)
    n = 5
    w = np.random.randn(n)
    
    lhs_vals = []
    rhs_vals = []
    for _ in range(5000):
        x = np.random.randn(n) * 3
        y = x + np.random.randn(n) * np.random.uniform(0.01, 3)
        lhs = abs(tropical_agg(w, x) - tropical_agg(w, y))
        rhs = np.max(np.abs(x - y))
        lhs_vals.append(lhs)
        rhs_vals.append(rhs)
    
    fig, ax = plt.subplots(figsize=(8, 6))
    ax.scatter(rhs_vals, lhs_vals, alpha=0.15, s=8, c='#2196F3')
    mx = max(max(rhs_vals), max(lhs_vals)) * 1.05
    ax.plot([0, mx], [0, mx], 'r-', linewidth=2, label='y = x (Lipschitz bound)')
    ax.set_xlabel('Input perturbation: max_i |x_i − y_i|', fontsize=12)
    ax.set_ylabel('Output change: |T_w(x) − T_w(y)|', fontsize=12)
    ax.set_title('Tropical Aggregation is 1-Lipschitz', fontsize=14, fontweight='bold')
    ax.legend(fontsize=11)
    ax.set_xlim(0, mx)
    ax.set_ylim(0, mx)
    ax.set_aspect('equal')
    ax.grid(True, alpha=0.3)
    
    fig.savefig('/workspace/request-project/fig_lipschitz.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


def viz_relu_contraction():
    """Show how ReLU contracts: |max(a,0)-max(b,0)| ≤ |a-b|."""
    a_vals = np.linspace(-3, 3, 500)
    
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))
    
    # Left: ReLU function
    ax = axes[0]
    ax.plot(a_vals, np.maximum(a_vals, 0), 'b-', linewidth=2.5, label='ReLU(x) = max(x, 0)')
    ax.plot(a_vals, a_vals, 'r--', linewidth=1, alpha=0.5, label='y = x')
    ax.axhline(0, color='gray', linewidth=0.5)
    ax.axvline(0, color='gray', linewidth=0.5)
    ax.set_xlabel('x', fontsize=12)
    ax.set_ylabel('ReLU(x)', fontsize=12)
    ax.set_title('ReLU as Tropical Connective', fontsize=13, fontweight='bold')
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    
    # Right: Contraction property
    ax = axes[1]
    b = 0.5
    diff_original = np.abs(a_vals - b)
    diff_relu = np.abs(np.maximum(a_vals, 0) - np.maximum(b, 0))
    
    ax.fill_between(a_vals, diff_original, diff_relu, alpha=0.2, color='green',
                     label='Contraction region')
    ax.plot(a_vals, diff_original, 'r-', linewidth=2, label='|a − b|')
    ax.plot(a_vals, diff_relu, 'b-', linewidth=2, label='|ReLU(a) − ReLU(b)|')
    ax.set_xlabel('a (with b = 0.5)', fontsize=12)
    ax.set_ylabel('Distance', fontsize=12)
    ax.set_title(f'ReLU Contraction: |ReLU(a)−ReLU(b)| ≤ |a−b|', fontsize=13, fontweight='bold')
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    fig.savefig('/workspace/request-project/fig_relu.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


def viz_composition_depth():
    """Show Lipschitz ratio vs network depth."""
    np.random.seed(789)
    
    depths = list(range(1, 11))
    max_ratios = []
    mean_ratios = []
    
    for depth in depths:
        ratios = []
        for _ in range(2000):
            dim = 5
            x = np.random.randn(dim) * 2
            eps = np.random.uniform(0.1, 2)
            delta = np.random.randn(dim)
            delta = delta / np.max(np.abs(delta)) * eps
            y = x + delta
            
            # Build random network of given depth
            curr_x, curr_y = x.copy(), y.copy()
            for _ in range(depth):
                w_layer = np.random.randn(dim)
                new_x = np.array([np.max(w_layer + curr_x)])
                new_y = np.array([np.max(w_layer + curr_y)])
                # For multi-output, use multiple weight vectors
                w_layers = np.random.randn(dim, len(curr_x) if len(curr_x.shape) > 0 else 1)
                if curr_x.ndim == 0:
                    curr_x = np.array([curr_x])
                    curr_y = np.array([curr_y])
                new_x = np.array([tropical_agg(w_layers[j], curr_x) for j in range(dim)])
                new_y = np.array([tropical_agg(w_layers[j], curr_y) for j in range(dim)])
                curr_x, curr_y = new_x, new_y
            
            out_dist = np.max(np.abs(curr_x - curr_y))
            in_dist = np.max(np.abs(x - y))
            if in_dist > 1e-15:
                ratios.append(out_dist / in_dist)
        
        max_ratios.append(max(ratios))
        mean_ratios.append(np.mean(ratios))
    
    fig, ax = plt.subplots(figsize=(8, 5))
    ax.plot(depths, max_ratios, 'ro-', linewidth=2, markersize=8, label='Maximum ratio')
    ax.plot(depths, mean_ratios, 'b^-', linewidth=2, markersize=8, label='Mean ratio')
    ax.axhline(1.0, color='red', linestyle='--', linewidth=1.5, alpha=0.7, label='Lipschitz bound = 1')
    ax.set_xlabel('Network Depth', fontsize=12)
    ax.set_ylabel('Lipschitz Ratio: ||f(x)−f(y)||∞ / ||x−y||∞', fontsize=12)
    ax.set_title('Tropical Networks: 1-Lipschitz at Any Depth', fontsize=14, fontweight='bold')
    ax.legend(fontsize=11)
    ax.set_ylim(0, 1.3)
    ax.grid(True, alpha=0.3)
    
    fig.savefig('/workspace/request-project/fig_depth.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


def viz_residuation():
    """Visualize the residuation adjunction."""
    fig, ax = plt.subplots(figsize=(8, 6))
    
    a = 2.0
    c_vals = np.linspace(-1, 6, 200)
    
    # For each c, the max b satisfying a+b ≤ c is b = c-a = tropImp(a,c)
    b_max = c_vals - a
    
    ax.fill_between(c_vals, -5, b_max, alpha=0.2, color='#4CAF50',
                     label=f'Feasible region: a + b ≤ c (a={a})')
    ax.plot(c_vals, b_max, 'g-', linewidth=2.5, label=f'b = c − a (tropical implication)')
    ax.axhline(0, color='gray', linewidth=0.5)
    ax.axvline(a, color='orange', linewidth=1.5, linestyle='--', label=f'c = a = {a}')
    
    ax.set_xlabel('Conclusion strength c', fontsize=12)
    ax.set_ylabel('Maximum implication capacity b', fontsize=12)
    ax.set_title('Tropical Residuation: a + b ≤ c ⟺ b ≤ c − a', fontsize=14, fontweight='bold')
    ax.legend(fontsize=10, loc='upper left')
    ax.set_xlim(-1, 6)
    ax.set_ylim(-4, 5)
    ax.grid(True, alpha=0.3)
    
    fig.savefig('/workspace/request-project/fig_residuation.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


if __name__ == "__main__":
    print("Generating visualizations...")
    
    b64_lip = viz_lipschitz_cloud()
    print(f"  Lipschitz cloud: {len(b64_lip)} chars")
    
    b64_relu = viz_relu_contraction()
    print(f"  ReLU contraction: {len(b64_relu)} chars")
    
    b64_depth = viz_composition_depth()
    print(f"  Depth stability: {len(b64_depth)} chars")
    
    b64_res = viz_residuation()
    print(f"  Residuation: {len(b64_res)} chars")
    
    # Save base64 data for JSON package
    viz_data = {
        "lipschitz_cloud": b64_lip,
        "relu_contraction": b64_relu,
        "depth_stability": b64_depth,
        "residuation": b64_res,
    }
    with open('/workspace/request-project/viz_data.json', 'w') as f:
        json.dump(viz_data, f)
    
    print("All visualizations generated ✓")
    print("PNG files saved: fig_lipschitz.png, fig_relu.png, fig_depth.png, fig_residuation.png")
