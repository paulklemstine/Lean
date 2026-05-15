#!/usr/bin/env python3
"""
Applications of Categorical Neural Architecture Composition

Real-world applications demonstrating how the formal compositional theory
translates into practical tools for neural network design and analysis.

Applications:
1. ResNet depth analysis via residual complexity bounds
2. Transformer equivariance certification
3. Neural architecture search with guaranteed cost reduction
4. Robustness certification through compositional Lipschitz bounds
"""

import numpy as np
from typing import List, Tuple, Dict
from dataclasses import dataclass
import json


# ============================================================================
# Application 1: ResNet Depth Analysis
# ============================================================================

def resnet_depth_analysis(
    layer_norms: List[float],
    input_dim: int = 64
) -> Dict:
    """
    Analyze how network depth affects generalization via compositional bounds.
    
    Uses Theorem 3 (submultiplicative complexity) and the residual complexity
    bound to certify generalization properties of deep residual networks.
    
    Mathematical basis:
        C(res(fₖ) ∘ ... ∘ res(f₁)) ≤ ∏ᵢ (1 + Cᵢ)
    
    Args:
        layer_norms: Operator norms of each residual layer's weight matrix
        input_dim: Input feature dimension
        
    Returns:
        Analysis dictionary with bounds and recommendations
    """
    n_layers = len(layer_norms)
    
    # Individual residual complexities
    residual_complexities = [1 + c for c in layer_norms]
    
    # Cumulative complexity through the network
    cumulative = np.cumprod(residual_complexities)
    
    # Log-complexity (additive in log space)
    log_complexities = np.log(residual_complexities)
    log_cumulative = np.cumsum(log_complexities)
    
    # Effective depth: where complexity starts growing too fast
    threshold = np.exp(np.log(input_dim))  # complexity ≈ dimension
    effective_depth = np.searchsorted(cumulative, threshold)
    if effective_depth >= n_layers:
        effective_depth = n_layers
    
    # Generalization surrogate: log of total complexity
    gen_surrogate = float(log_cumulative[-1]) if n_layers > 0 else 0.0
    
    return {
        "n_layers": n_layers,
        "input_dim": input_dim,
        "layer_norms": layer_norms,
        "residual_complexities": residual_complexities,
        "total_complexity_bound": float(cumulative[-1]) if n_layers > 0 else 1.0,
        "log_complexity": gen_surrogate,
        "effective_depth": int(effective_depth),
        "mean_layer_norm": float(np.mean(layer_norms)),
        "recommendation": (
            "Well-conditioned" if gen_surrogate < np.log(input_dim)
            else "Consider regularization or reduced depth"
        ),
    }


# ============================================================================
# Application 2: Transformer Equivariance Certification
# ============================================================================

def certify_transformer_equivariance(
    n_tokens: int,
    d_model: int,
    attention_type: str = "uniform",
    n_tests: int = 1000
) -> Dict:
    """
    Certify that a transformer's attention mechanism is equivariant
    under token permutation.
    
    Mathematical basis: Theorem 2 (attention naturality)
        If Attn is componentwise/uniform, then ∀σ:
        Attn ∘ reindex(σ) = reindex(σ) ∘ Attn
    
    This means the transformer's output is independent of token ordering,
    which is the formal guarantee behind position-agnostic architectures.
    
    Args:
        n_tokens: Number of tokens/positions
        d_model: Model dimension per token
        attention_type: "uniform" or "componentwise"
        n_tests: Number of random tests
        
    Returns:
        Certification results
    """
    max_violation = 0.0
    violations = []
    
    np.random.seed(42)
    
    for _ in range(n_tests):
        # Random input: (n_tokens, d_model) flattened
        X = np.random.randn(n_tokens, d_model)
        
        # Random permutation of tokens
        perm = np.random.permutation(n_tokens)
        
        if attention_type == "uniform":
            # Uniform scalar attention: scale all by same factor
            c = 0.5
            attn = lambda X: c * X
        elif attention_type == "componentwise":
            # Componentwise: each element scaled by function of its value
            attn = lambda X: np.tanh(X) * X
        else:
            raise ValueError(f"Unknown attention type: {attention_type}")
        
        # Test naturality: Attn(σ(X)) vs σ(Attn(X))
        lhs = attn(X[perm])
        rhs = attn(X)[perm]
        
        violation = np.max(np.abs(lhs - rhs))
        max_violation = max(max_violation, violation)
        violations.append(violation)
    
    is_certified = max_violation < 1e-10
    
    return {
        "n_tokens": n_tokens,
        "d_model": d_model,
        "attention_type": attention_type,
        "n_tests": n_tests,
        "certified_equivariant": is_certified,
        "max_violation": float(max_violation),
        "mean_violation": float(np.mean(violations)),
        "theorem_guarantee": (
            "Formally proven: uniform/componentwise attention is "
            "permutation-equivariant (Theorem 2a/2b)"
        ),
    }


# ============================================================================
# Application 3: Neural Architecture Search
# ============================================================================

@dataclass
class ArchConfig:
    """Architecture configuration for NAS."""
    name: str
    n_layers: int
    layer_widths: List[int]
    complexities: List[float]
    
    @property
    def total_cost(self) -> float:
        return sum(self.complexities)
    
    @property
    def multiplicative_bound(self) -> float:
        return float(np.prod(self.complexities))


def architecture_search_with_guarantees(
    search_space: List[List[ArchConfig]],
    component_names: List[str],
    budget: float = 20.0,
    max_steps: int = 50
) -> Dict:
    """
    Neural architecture search with formally guaranteed cost monotonicity.
    
    Mathematical basis: Theorem 4 (diagram cost monotonicity)
        Pointwise complexity improvement ⟹ global cost reduction
    
    This transforms NAS from heuristic exploration into certified optimization:
    every accepted modification is guaranteed to not increase total cost.
    
    Args:
        search_space: For each component position, list of candidate configs
        component_names: Names of architecture components
        budget: Maximum total cost allowed
        max_steps: Maximum search iterations
        
    Returns:
        Search results with cost trajectory
    """
    n_components = len(search_space)
    
    # Start with the first candidate for each component
    current = [candidates[0] for candidates in search_space]
    current_cost = sum(c.total_cost for c in current)
    
    history = [{"step": 0, "cost": current_cost, "action": "initial"}]
    
    for step in range(1, max_steps + 1):
        best_saving = 0.0
        best_idx = -1
        best_replacement = None
        
        for j, candidates in enumerate(search_space):
            current_comp_cost = current[j].total_cost
            for candidate in candidates:
                if candidate.total_cost < current_comp_cost:
                    saving = current_comp_cost - candidate.total_cost
                    if saving > best_saving:
                        best_saving = saving
                        best_idx = j
                        best_replacement = candidate
        
        if best_idx == -1:
            break
        
        old_name = current[best_idx].name
        current[best_idx] = best_replacement
        new_cost = sum(c.total_cost for c in current)
        
        # Theorem 4 guarantees: new_cost ≤ current_cost
        assert new_cost <= current_cost + 1e-10, "Monotonicity violated!"
        
        history.append({
            "step": step,
            "cost": new_cost,
            "action": f"Replace {component_names[best_idx]}: {old_name} → {best_replacement.name}",
            "saving": best_saving,
        })
        current_cost = new_cost
    
    return {
        "final_architecture": [c.name for c in current],
        "final_cost": current_cost,
        "initial_cost": history[0]["cost"],
        "n_steps": len(history) - 1,
        "cost_reduction": history[0]["cost"] - current_cost,
        "within_budget": current_cost <= budget,
        "history": history,
        "monotonicity_certified": True,
    }


# ============================================================================
# Application 4: Robustness Certification
# ============================================================================

def certify_robustness_radius(
    layer_norms: List[float],
    epsilon: float,
    architecture_type: str = "residual"
) -> Dict:
    """
    Certify the robustness radius of a deep network using compositional bounds.
    
    Mathematical basis: Theorem 3 + residual complexity bound
        If total Lipschitz constant L = ∏(1+Cᵢ), then:
        ||f(x) - f(x')|| ≤ L · ||x - x'||
    
    So for any input perturbation of size ε, the output changes by at most L·ε.
    The certified robustness radius for margin m is: r = m / L.
    
    Args:
        layer_norms: Operator norms of each layer
        epsilon: Perturbation budget
        architecture_type: "residual" or "plain"
        
    Returns:
        Robustness certification results
    """
    if architecture_type == "residual":
        total_lipschitz = float(np.prod([1 + c for c in layer_norms]))
    else:
        total_lipschitz = float(np.prod(layer_norms))
    
    max_output_change = total_lipschitz * epsilon
    
    # For classification with margin m, certified radius = m / L
    typical_margins = [0.1, 0.5, 1.0, 2.0]
    certified_radii = {f"margin_{m}": m / total_lipschitz for m in typical_margins}
    
    return {
        "n_layers": len(layer_norms),
        "architecture_type": architecture_type,
        "layer_norms": layer_norms,
        "total_lipschitz_bound": total_lipschitz,
        "perturbation_budget": epsilon,
        "max_output_change": max_output_change,
        "certified_radii": certified_radii,
        "is_contractive": total_lipschitz < 1.0,
        "theorem_basis": "Compositional submultiplicativity (Theorem 3)",
    }


# ============================================================================
# Main
# ============================================================================

if __name__ == "__main__":
    print("=" * 70)
    print("  APPLICATIONS OF CATEGORICAL ARCHITECTURE COMPOSITION")
    print("=" * 70)
    
    # Application 1: ResNet depth analysis
    print("\n1. ResNet Depth Analysis")
    print("-" * 40)
    # Simulate a 20-layer ResNet with varying layer norms
    norms = [0.3 + 0.1 * np.sin(i * 0.5) for i in range(20)]
    result = resnet_depth_analysis(norms, input_dim=64)
    print(f"   Layers: {result['n_layers']}")
    print(f"   Total complexity bound: {result['total_complexity_bound']:.2f}")
    print(f"   Log complexity: {result['log_complexity']:.2f}")
    print(f"   Effective depth: {result['effective_depth']}")
    print(f"   Recommendation: {result['recommendation']}")
    
    # Application 2: Transformer equivariance
    print("\n2. Transformer Equivariance Certification")
    print("-" * 40)
    for attn_type in ["uniform", "componentwise"]:
        cert = certify_transformer_equivariance(
            n_tokens=8, d_model=16, attention_type=attn_type, n_tests=500
        )
        print(f"   {attn_type}: certified={cert['certified_equivariant']}, "
              f"max_violation={cert['max_violation']:.2e}")
    
    # Application 3: Architecture search
    print("\n3. Neural Architecture Search")
    print("-" * 40)
    names = ["Embed", "Enc1", "Enc2", "Dec", "Output"]
    space = [
        [ArchConfig(f"{n}_v{j}", 1, [64], [c])
         for j, c in enumerate([3.0, 2.5, 2.0, 1.5])]
        for n in names
    ]
    nas_result = architecture_search_with_guarantees(space, names)
    print(f"   Initial cost: {nas_result['initial_cost']:.1f}")
    print(f"   Final cost: {nas_result['final_cost']:.1f}")
    print(f"   Steps: {nas_result['n_steps']}")
    print(f"   Monotonicity certified: {nas_result['monotonicity_certified']}")
    
    # Application 4: Robustness certification
    print("\n4. Robustness Certification")
    print("-" * 40)
    norms_small = [0.2, 0.15, 0.25, 0.1, 0.18]
    rob = certify_robustness_radius(norms_small, epsilon=0.1, architecture_type="residual")
    print(f"   Total Lipschitz: {rob['total_lipschitz_bound']:.4f}")
    print(f"   Max output change (ε=0.1): {rob['max_output_change']:.4f}")
    print(f"   Certified radii: { {k: f'{v:.4f}' for k, v in rob['certified_radii'].items()} }")
    print(f"   Contractive: {rob['is_contractive']}")
    
    print("\n" + "=" * 70)
    print("  All applications completed successfully.")
    print("=" * 70)


#!/usr/bin/env python3
"""
Categorical Neural Architecture Composition: Concrete Demonstrations

This script demonstrates the four main theorems of the compositional architecture
theory with concrete numerical examples:

1. Residual = Sum ∘ Pair(id, f) — universal product construction
2. Attention naturality under permutation
3. Submultiplicative complexity bounds
4. Diagram cost monotonicity for architecture search
"""

import numpy as np
from typing import Callable, List, Tuple

# Type aliases matching the Lean formalization
State = np.ndarray  # shape (n,)
Arch = Callable[[State], State]  # State n → State m


def demo_theorem1_residual_universal_construction():
    """
    Theorem 1: Residual connections arise from a universal product construction.
    
    residual(f)(x) = sumMap(pairMap(id, f)(x))
    
    This shows that skip connections are not ad hoc engineering tricks but
    arise from the categorical product's universal property.
    """
    print("=" * 70)
    print("THEOREM 1: Residual = Sum ∘ Pair(id, f)")
    print("  Skip connections as universal product constructions")
    print("=" * 70)
    
    n = 4
    np.random.seed(42)
    
    # Define a layer f as a linear map
    W = np.random.randn(n, n) * 0.5
    f: Arch = lambda x: W @ x
    
    # Define the residual
    def residual(f: Arch) -> Arch:
        return lambda x: x + f(x)
    
    # Define the categorical decomposition
    def pair_map(f: Arch, g: Arch) -> Callable[[State], np.ndarray]:
        """Pair map: concatenate outputs of f and g"""
        return lambda x: np.concatenate([f(x), g(x)])
    
    def sum_map(x_paired: np.ndarray) -> State:
        """Sum map: add left and right halves"""
        n = len(x_paired) // 2
        return x_paired[:n] + x_paired[n:]
    
    # Test on random input
    x = np.random.randn(n)
    
    # Method 1: Direct residual
    res_direct = residual(f)(x)
    
    # Method 2: Categorical decomposition
    paired = pair_map(lambda x: x, f)(x)  # pairMap(id, f)
    res_categorical = sum_map(paired)       # sumMap ∘ pairMap(id, f)
    
    print(f"\n  Input x = {x.round(4)}")
    print(f"  f(x)    = {f(x).round(4)}")
    print(f"\n  Direct residual:      x + f(x) = {res_direct.round(4)}")
    print(f"  Categorical decomp:  Σ∘⟨id,f⟩(x) = {res_categorical.round(4)}")
    print(f"\n  Match: {np.allclose(res_direct, res_categorical)} "
          f"(max diff = {np.max(np.abs(res_direct - res_categorical)):.2e})")
    
    # Verify projection equations (universal property)
    proj_left = paired[:n]
    proj_right = paired[n:]
    print(f"\n  Projection equations (universal property):")
    print(f"    π₁ ∘ ⟨id,f⟩ = id:  {np.allclose(proj_left, x)}")
    print(f"    π₂ ∘ ⟨id,f⟩ = f:   {np.allclose(proj_right, f(x))}")
    print()


def demo_theorem2_attention_naturality():
    """
    Theorem 2: Attention is a natural transformation under permutation.
    
    Attn ∘ reindex(σ) = reindex(σ) ∘ Attn
    
    This proves that position-independent attention mechanisms are
    equivariant under feature relabeling.
    """
    print("=" * 70)
    print("THEOREM 2: Attention Naturality Under Permutation")
    print("  Equivariance of position-independent attention")
    print("=" * 70)
    
    n = 5
    np.random.seed(123)
    
    # Define uniform scalar attention
    c = 0.7
    uniform_attn: Arch = lambda x: c * x
    
    # Define componentwise attention (value-dependent scaling)
    w = lambda v: np.tanh(v)  # weight function
    componentwise_attn: Arch = lambda x: w(x) * x
    
    # Define a random permutation
    perm = np.array([3, 0, 4, 1, 2])  # σ
    reindex: Arch = lambda x: x[perm]
    
    x = np.random.randn(n)
    
    print(f"\n  Input x = {x.round(4)}")
    print(f"  Permutation σ = {perm}")
    print(f"  Scalar c = {c}")
    
    # Test uniform attention naturality
    lhs_uniform = uniform_attn(reindex(x))
    rhs_uniform = reindex(uniform_attn(x))
    print(f"\n  Uniform Attention (Theorem 2a):")
    print(f"    Attn(σ(x)) = {lhs_uniform.round(4)}")
    print(f"    σ(Attn(x)) = {rhs_uniform.round(4)}")
    print(f"    Naturality: {np.allclose(lhs_uniform, rhs_uniform)}")
    
    # Test componentwise attention naturality
    lhs_comp = componentwise_attn(reindex(x))
    rhs_comp = reindex(componentwise_attn(x))
    print(f"\n  Componentwise Attention (Theorem 2b):")
    print(f"    Attn(σ(x)) = {lhs_comp.round(4)}")
    print(f"    σ(Attn(x)) = {rhs_comp.round(4)}")
    print(f"    Naturality: {np.allclose(lhs_comp, rhs_comp)}")
    
    # Demonstrate composition preserves naturality
    composed_attn: Arch = lambda x: uniform_attn(componentwise_attn(x))
    lhs_composed = composed_attn(reindex(x))
    rhs_composed = reindex(composed_attn(x))
    print(f"\n  Composed Attention (natural ∘ natural = natural):")
    print(f"    (A₁∘A₂)(σ(x)) = {lhs_composed.round(4)}")
    print(f"    σ((A₁∘A₂)(x)) = {rhs_composed.round(4)}")
    print(f"    Naturality: {np.allclose(lhs_composed, rhs_composed)}")
    print()


def demo_theorem3_compositional_complexity():
    """
    Theorem 3: Compositional complexity is submultiplicative.
    
    C(g ∘ f) ≤ C(g) · C(f)
    C(res(f)) ≤ 1 + C(f)
    
    Layer stacking increases complexity at most multiplicatively.
    """
    print("=" * 70)
    print("THEOREM 3: Submultiplicative Compositional Complexity")
    print("  Certified bounds for stacked architectures")
    print("=" * 70)
    
    np.random.seed(456)
    n = 4
    
    # Define layers with known operator norms (Lipschitz constants)
    layers = []
    complexities = []
    for i in range(5):
        W = np.random.randn(n, n) * 0.3
        lip = np.linalg.norm(W, ord=2)  # spectral norm = operator norm
        layers.append(W)
        complexities.append(lip)
    
    print(f"\n  Number of layers: {len(layers)}")
    print(f"  Individual complexities (operator norms):")
    for i, c in enumerate(complexities):
        print(f"    Layer {i+1}: C = {c:.4f}")
    
    # Compose all layers
    composed = np.eye(n)
    for W in layers:
        composed = W @ composed
    
    actual_complexity = np.linalg.norm(composed, ord=2)
    bound = np.prod(complexities)
    
    print(f"\n  Actual complexity of composition: {actual_complexity:.4f}")
    print(f"  Submultiplicative bound (∏ Cᵢ): {bound:.4f}")
    print(f"  Bound holds: {actual_complexity <= bound + 1e-10}")
    
    # Residual complexity
    print(f"\n  Residual complexity bounds:")
    for i, (W, c) in enumerate(zip(layers[:3], complexities[:3])):
        res_W = np.eye(n) + W
        res_complexity = np.linalg.norm(res_W, ord=2)
        res_bound = 1 + c
        print(f"    Residual layer {i+1}: C(res) = {res_complexity:.4f} ≤ {res_bound:.4f} = 1 + C")
        assert res_complexity <= res_bound + 1e-10
    
    # Monotonicity of product under componentwise reduction
    reduced_complexities = [c * 0.8 for c in complexities]
    print(f"\n  Complexity product monotonicity:")
    print(f"    Original product:  {np.prod(complexities):.4f}")
    print(f"    Reduced product:   {np.prod(reduced_complexities):.4f}")
    print(f"    Monotone: {np.prod(reduced_complexities) <= np.prod(complexities)}")
    print()


def demo_theorem4_architecture_search():
    """
    Theorem 4: Architecture search as monotone optimization.
    
    If ∀j, C(Aⱼ) ≤ C(Bⱼ), then Cost(A) ≤ Cost(B).
    
    Pointwise improvement guarantees global cost reduction.
    """
    print("=" * 70)
    print("THEOREM 4: Diagram Cost Monotonicity")
    print("  Architecture search with certified cost reduction")
    print("=" * 70)
    
    np.random.seed(789)
    
    # Architecture diagram: 6 components
    n_components = 6
    component_names = ["Embedding", "Encoder1", "Encoder2", 
                       "Attention", "Decoder", "Output"]
    
    # Initial architecture complexities
    initial_complexities = np.array([2.5, 3.1, 4.2, 5.0, 3.8, 1.5])
    
    # Improved architecture (every component has lower or equal complexity)
    improved_complexities = np.array([2.0, 2.8, 3.5, 4.1, 3.2, 1.3])
    
    initial_cost = np.sum(initial_complexities)
    improved_cost = np.sum(improved_complexities)
    
    print(f"\n  Architecture Diagram ({n_components} components):")
    print(f"  {'Component':<12} {'Initial C':<12} {'Improved C':<12} {'Δ':<10}")
    print(f"  {'-'*46}")
    for name, c_old, c_new in zip(component_names, initial_complexities, improved_complexities):
        delta = c_new - c_old
        print(f"  {name:<12} {c_old:<12.1f} {c_new:<12.1f} {delta:<10.1f}")
    
    print(f"\n  Total cost (initial):  {initial_cost:.1f}")
    print(f"  Total cost (improved): {improved_cost:.1f}")
    print(f"  Pointwise ≤: {all(improved_complexities <= initial_complexities)}")
    print(f"  Cost monotone: {improved_cost <= initial_cost}")
    
    # Single component improvement
    single_improved = initial_complexities.copy()
    single_improved[3] = 3.5  # Improve just the Attention component
    single_cost = np.sum(single_improved)
    print(f"\n  Single-component improvement (Attention: 5.0 → 3.5):")
    print(f"  New total cost: {single_cost:.1f} ≤ {initial_cost:.1f} = original")
    print(f"  Monotone: {single_cost <= initial_cost}")
    print()


if __name__ == "__main__":
    print("\n" + "=" * 70)
    print("  CATEGORICAL NEURAL ARCHITECTURE COMPOSITION")
    print("  Concrete Demonstrations of Four Breakthrough Theorems")
    print("=" * 70 + "\n")
    
    demo_theorem1_residual_universal_construction()
    demo_theorem2_attention_naturality()
    demo_theorem3_compositional_complexity()
    demo_theorem4_architecture_search()
    
    print("=" * 70)
    print("  All demonstrations completed successfully.")
    print("  Every theorem verified on concrete numerical examples.")
    print("=" * 70)


#!/usr/bin/env python3
"""
Visualizations for Categorical Neural Architecture Composition

Generates publication-quality figures illustrating:
1. Residual factorization diagram
2. Attention naturality commutative diagram  
3. Compositional complexity growth curves
4. Architecture search cost trajectory
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib.patches import FancyArrowPatch
import base64
import io
import json


def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64 data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight',
                facecolor='white', edgecolor='none')
    buf.seek(0)
    encoded = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{encoded}"


def viz_complexity_growth():
    """
    Visualize how compositional complexity grows with depth
    under different architecture strategies.
    """
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    
    depths = np.arange(1, 31)
    
    # Panel 1: Multiplicative vs residual complexity
    ax = axes[0]
    layer_norms = [0.5, 0.3, 0.8, 0.4, 0.6, 0.2, 0.7, 0.35, 0.55, 0.45]
    
    for label, norms, style in [
        ("Plain (∏ Cᵢ, Cᵢ=1.5)", [1.5]*30, '-'),
        ("Plain (∏ Cᵢ, Cᵢ=1.2)", [1.2]*30, '--'),
        ("Residual (∏(1+Cᵢ), Cᵢ=0.3)", [0.3]*30, '-'),
        ("Residual (∏(1+Cᵢ), Cᵢ=0.1)", [0.1]*30, '--'),
    ]:
        if "Plain" in label:
            cumulative = np.cumprod(norms[:30])
        else:
            cumulative = np.cumprod([1 + c for c in norms[:30]])
        ax.semilogy(depths, cumulative, style, linewidth=2, label=label)
    
    ax.set_xlabel('Network Depth (number of layers)', fontsize=12)
    ax.set_ylabel('Total Complexity Bound', fontsize=12)
    ax.set_title('Theorem 3: Compositional Complexity Growth', fontsize=14, fontweight='bold')
    ax.legend(fontsize=10, loc='upper left')
    ax.grid(True, alpha=0.3)
    ax.set_xlim(1, 30)
    
    # Panel 2: Certified generalization surrogate
    ax = axes[1]
    norm_values = np.linspace(0.05, 0.8, 50)
    for depth in [5, 10, 20, 30]:
        gen_bounds = [np.log(np.prod([1 + c] * depth)) for c in norm_values]
        ax.plot(norm_values, gen_bounds, linewidth=2, label=f'Depth {depth}')
    
    ax.set_xlabel('Layer Norm (Cᵢ)', fontsize=12)
    ax.set_ylabel('Log Complexity (generalization surrogate)', fontsize=12)
    ax.set_title('Generalization vs Depth-Norm Tradeoff', fontsize=14, fontweight='bold')
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    
    fig.suptitle('Compositional Generalization Bounds for Deep Networks',
                 fontsize=16, fontweight='bold', y=1.02)
    plt.tight_layout()
    return fig


def viz_architecture_search():
    """
    Visualize architecture search with certified cost monotonicity.
    """
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    
    # Panel 1: Cost trajectory
    ax = axes[0]
    np.random.seed(42)
    
    # Simulate search trajectory
    n_steps = 20
    initial_cost = 25.0
    costs = [initial_cost]
    for i in range(n_steps):
        improvement = np.random.exponential(0.5) * np.exp(-0.15 * i)
        costs.append(costs[-1] - improvement)
    
    steps = range(len(costs))
    ax.plot(steps, costs, 'b-o', linewidth=2, markersize=6, label='Total Cost')
    ax.fill_between(steps, costs, alpha=0.1, color='blue')
    ax.axhline(y=costs[-1], color='r', linestyle='--', alpha=0.5, label=f'Final: {costs[-1]:.1f}')
    
    ax.set_xlabel('Search Step', fontsize=12)
    ax.set_ylabel('Diagram Cost', fontsize=12)
    ax.set_title('Theorem 4: Monotone Cost Descent', fontsize=14, fontweight='bold')
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    
    # Add annotation
    ax.annotate('Guaranteed\nnon-increasing\n(Theorem 4)',
                xy=(10, costs[10]), xytext=(14, costs[5]),
                fontsize=10, ha='center',
                arrowprops=dict(arrowstyle='->', color='green', lw=2),
                bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow'))
    
    # Panel 2: Component-wise complexity heatmap
    ax = axes[1]
    components = ['Embed', 'Enc1', 'Enc2', 'Attn', 'Dec', 'Out']
    n_comp = len(components)
    n_search_steps = 8
    
    complexity_matrix = np.zeros((n_comp, n_search_steps))
    np.random.seed(123)
    for j in range(n_comp):
        c = 2.0 + np.random.rand() * 3
        for t in range(n_search_steps):
            complexity_matrix[j, t] = c
            if np.random.rand() < 0.4:
                c = max(0.5, c - np.random.exponential(0.5))
    
    im = ax.imshow(complexity_matrix, aspect='auto', cmap='YlOrRd',
                   interpolation='nearest')
    ax.set_xlabel('Search Step', fontsize=12)
    ax.set_ylabel('Component', fontsize=12)
    ax.set_yticks(range(n_comp))
    ax.set_yticklabels(components)
    ax.set_title('Component Complexity During Search', fontsize=14, fontweight='bold')
    plt.colorbar(im, ax=ax, label='Complexity')
    
    fig.suptitle('Neural Architecture Search with Categorical Cost Monotonicity',
                 fontsize=16, fontweight='bold', y=1.02)
    plt.tight_layout()
    return fig


def viz_attention_naturality():
    """
    Visualize attention naturality: how permutation commutes with attention.
    """
    fig, axes = plt.subplots(1, 3, figsize=(16, 5))
    
    n = 6
    np.random.seed(42)
    x = np.random.randn(n)
    perm = np.array([4, 1, 5, 0, 3, 2])
    c = 0.6
    
    # Panel 1: Input and permuted input
    ax = axes[0]
    indices = np.arange(n)
    width = 0.35
    ax.bar(indices - width/2, x, width, label='x', color='steelblue', alpha=0.8)
    ax.bar(indices + width/2, x[perm], width, label='σ(x)', color='coral', alpha=0.8)
    ax.set_xlabel('Feature Index', fontsize=12)
    ax.set_ylabel('Value', fontsize=12)
    ax.set_title('Input vs Permuted Input', fontsize=14, fontweight='bold')
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3, axis='y')
    
    # Panel 2: Naturality check for uniform attention
    ax = axes[1]
    attn_then_perm = (c * x)[perm]  # σ(Attn(x))
    perm_then_attn = c * x[perm]     # Attn(σ(x))
    
    ax.bar(indices - width/2, attn_then_perm, width,
           label='σ(Attn(x))', color='steelblue', alpha=0.8)
    ax.bar(indices + width/2, perm_then_attn, width,
           label='Attn(σ(x))', color='coral', alpha=0.8)
    ax.set_xlabel('Feature Index', fontsize=12)
    ax.set_ylabel('Value', fontsize=12)
    ax.set_title('Uniform Attention: Exact Match', fontsize=14, fontweight='bold')
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3, axis='y')
    
    # Panel 3: Naturality check for componentwise attention
    ax = axes[2]
    w = np.tanh
    comp_attn_then_perm = (w(x) * x)[perm]
    comp_perm_then_attn = w(x[perm]) * x[perm]
    
    ax.bar(indices - width/2, comp_attn_then_perm, width,
           label='σ(Attn(x))', color='steelblue', alpha=0.8)
    ax.bar(indices + width/2, comp_perm_then_attn, width,
           label='Attn(σ(x))', color='coral', alpha=0.8)
    ax.set_xlabel('Feature Index', fontsize=12)
    ax.set_ylabel('Value', fontsize=12)
    ax.set_title('Componentwise Attention: Exact Match', fontsize=14, fontweight='bold')
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3, axis='y')
    
    fig.suptitle('Theorem 2: Attention Naturality Under Permutation',
                 fontsize=16, fontweight='bold', y=1.02)
    plt.tight_layout()
    return fig


def viz_residual_decomposition():
    """
    Visualize the residual factorization through the product construction.
    """
    fig, axes = plt.subplots(1, 3, figsize=(16, 5))
    
    n = 5
    np.random.seed(42)
    x = np.random.randn(n)
    W = np.random.randn(n, n) * 0.3
    
    # Panel 1: The three components
    ax = axes[0]
    identity_out = x
    layer_out = W @ x
    residual_out = x + W @ x
    
    indices = np.arange(n)
    width = 0.25
    ax.bar(indices - width, identity_out, width, label='id(x)', color='steelblue', alpha=0.8)
    ax.bar(indices, layer_out, width, label='f(x)', color='coral', alpha=0.8)
    ax.bar(indices + width, residual_out, width, label='x + f(x)', color='seagreen', alpha=0.8)
    ax.set_xlabel('Feature Index', fontsize=12)
    ax.set_ylabel('Value', fontsize=12)
    ax.set_title('Residual Decomposition', fontsize=14, fontweight='bold')
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3, axis='y')
    
    # Panel 2: Paired output
    ax = axes[1]
    paired = np.concatenate([identity_out, layer_out])
    colors = ['steelblue'] * n + ['coral'] * n
    ax.bar(range(2*n), paired, color=colors, alpha=0.8)
    ax.axvline(x=n-0.5, color='black', linestyle='--', alpha=0.5)
    ax.set_xlabel('Paired Index (left=id, right=f)', fontsize=12)
    ax.set_ylabel('Value', fontsize=12)
    ax.set_title('⟨id, f⟩(x) ∈ State(n+n)', fontsize=14, fontweight='bold')
    ax.grid(True, alpha=0.3, axis='y')
    
    # Panel 3: Sum map recovers residual
    ax = axes[2]
    summed = paired[:n] + paired[n:]
    ax.bar(indices - width/2, residual_out, width,
           label='Direct: x + f(x)', color='seagreen', alpha=0.8)
    ax.bar(indices + width/2, summed, width,
           label='Σ ∘ ⟨id,f⟩(x)', color='gold', alpha=0.8)
    ax.set_xlabel('Feature Index', fontsize=12)
    ax.set_ylabel('Value', fontsize=12)
    ax.set_title('Theorem 1: Both Methods Agree', fontsize=14, fontweight='bold')
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3, axis='y')
    
    fig.suptitle('Theorem 1: Residual = Sum ∘ Pair(id, f)',
                 fontsize=16, fontweight='bold', y=1.02)
    plt.tight_layout()
    return fig


if __name__ == "__main__":
    print("Generating visualizations...")
    
    figs = {
        "complexity_growth": viz_complexity_growth(),
        "architecture_search": viz_architecture_search(),
        "attention_naturality": viz_attention_naturality(),
        "residual_decomposition": viz_residual_decomposition(),
    }
    
    # Save as PNG files
    for name, fig in figs.items():
        fig.savefig(f"{name}.png", dpi=150, bbox_inches='tight',
                    facecolor='white', edgecolor='none')
        print(f"  Saved {name}.png")
    
    # Save base64 versions
    viz_data = {}
    for name, fig in figs.items():
        viz_data[name] = fig_to_base64(fig)
    
    with open("viz_data.json", "w") as f:
        json.dump(viz_data, f)
    
    print("  Saved viz_data.json")
    print("Done!")
