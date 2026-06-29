#!/usr/bin/env python3
"""
Algorithms for Categorical Neural Architecture Composition

Implements the core algorithms derived from the compositional architecture theory:

1. Residual factorization via universal product construction
2. Naturality-preserving attention composition
3. Compositional complexity analysis for layer stacks
4. Greedy architecture search with certified cost monotonicity

All algorithms have proven correctness guarantees from the formal theory.
"""

import numpy as np
from typing import Callable, List, Tuple, Optional
from dataclasses import dataclass


# ============================================================================
# Core Types
# ============================================================================

@dataclass
class BoundedArch:
    """Architecture with certified complexity bound.
    
    Corresponds to ArchCat.BoundedArch in the Lean formalization.
    
    Attributes:
        weight: Weight matrix (n x m) defining the linear map
        complexity: Certified upper bound on operator norm
        name: Human-readable identifier
    """
    weight: np.ndarray
    complexity: float
    name: str = "unnamed"
    
    @classmethod
    def from_matrix(cls, W: np.ndarray, name: str = "layer") -> 'BoundedArch':
        """Create a BoundedArch with complexity = spectral norm."""
        complexity = float(np.linalg.norm(W, ord=2))
        return cls(weight=W, complexity=complexity, name=name)
    
    def apply(self, x: np.ndarray) -> np.ndarray:
        """Apply the architecture to input."""
        return self.weight @ x


# ============================================================================
# Algorithm 1: Residual Factorization
# ============================================================================

def residual_factorize(f: BoundedArch) -> Tuple[np.ndarray, np.ndarray]:
    """
    Factor a residual layer through the universal product construction.
    
    Given f : State n → State n, produces:
      - pair_output: pairMap(id, f)(x) ∈ State(n+n)
      - The property that sumMap(pair_output) = x + f(x)
    
    Complexity: O(n²) for matrix-vector multiply
    Space: O(n) additional for the paired state
    
    Returns:
        (identity_component, layer_component) — the two halves of the paired output
    """
    n = f.weight.shape[0]
    I = np.eye(n)
    
    # The factorization: residual = sumMap ∘ pairMap(id, f)
    # pairMap(id, f) produces [I; W] as a block matrix
    pair_matrix = np.vstack([I, f.weight])
    
    # sumMap adds the two halves: [I + W]
    residual_matrix = I + f.weight
    
    return pair_matrix, residual_matrix


def compose_residuals(layers: List[BoundedArch]) -> Tuple[np.ndarray, float]:
    """
    Compose a stack of residual layers with certified complexity tracking.
    
    For layers f₁, ..., fₖ, computes:
      res(fₖ) ∘ ... ∘ res(f₁)
    
    with certified complexity bound: ∏ᵢ (1 + Cᵢ)
    
    Complexity: O(k · n²) for k layers of dimension n
    
    Args:
        layers: List of BoundedArch, each representing a layer
        
    Returns:
        (composed_matrix, complexity_bound)
    """
    if not layers:
        n = 1
        return np.eye(n), 1.0
    
    n = layers[0].weight.shape[0]
    composed = np.eye(n)
    complexity_bound = 1.0
    
    for layer in layers:
        residual_matrix = np.eye(n) + layer.weight
        composed = residual_matrix @ composed
        complexity_bound *= (1 + layer.complexity)
    
    return composed, complexity_bound


# ============================================================================
# Algorithm 2: Naturality-Preserving Attention
# ============================================================================

def verify_attention_naturality(
    attn: Callable[[np.ndarray], np.ndarray],
    n: int,
    n_perms: int = 100
) -> Tuple[bool, float]:
    """
    Verify that an attention operator is natural (permutation-equivariant).
    
    Tests: Attn ∘ reindex(σ) = reindex(σ) ∘ Attn
    for random permutations σ and random inputs x.
    
    Complexity: O(n_perms · n · T_attn) where T_attn is attention cost
    
    Args:
        attn: Attention operator State n → State n
        n: Dimension
        n_perms: Number of random permutations to test
        
    Returns:
        (is_natural, max_violation) — whether naturality holds approximately
    """
    max_violation = 0.0
    
    for _ in range(n_perms):
        sigma = np.random.permutation(n)
        x = np.random.randn(n)
        
        # Left side: Attn(σ(x))
        lhs = attn(x[sigma])
        
        # Right side: σ(Attn(x))
        rhs = attn(x)[sigma]
        
        violation = np.max(np.abs(lhs - rhs))
        max_violation = max(max_violation, violation)
    
    return max_violation < 1e-10, max_violation


def compose_natural_attentions(
    attentions: List[Callable[[np.ndarray], np.ndarray]]
) -> Callable[[np.ndarray], np.ndarray]:
    """
    Compose multiple natural attention operators.
    
    By the composition theorem (natural_attn_comp_natural), the result
    is automatically natural if each component is.
    
    Complexity: O(k · T_attn) for k attention operators
    
    Args:
        attentions: List of natural attention operators
        
    Returns:
        Composed attention operator (also natural)
    """
    def composed(x: np.ndarray) -> np.ndarray:
        result = x
        for attn in attentions:
            result = attn(result)
        return result
    return composed


# ============================================================================
# Algorithm 3: Compositional Complexity Analysis
# ============================================================================

def analyze_stack_complexity(
    layers: List[BoundedArch],
    mode: str = "multiplicative"
) -> dict:
    """
    Analyze complexity of a layered architecture stack.
    
    Implements the compositional complexity analysis from Theorem 3:
    - Multiplicative: C(g∘f) ≤ C(g)·C(f), total ≤ ∏ Cᵢ
    - Residual: C(res(f)) ≤ 1 + C(f), total ≤ ∏(1 + Cᵢ)
    
    Complexity: O(k) where k is the number of layers
    
    Args:
        layers: List of BoundedArch with certified complexities
        mode: "multiplicative" or "residual"
        
    Returns:
        Dictionary with complexity analysis results
    """
    complexities = [l.complexity for l in layers]
    
    if mode == "multiplicative":
        total_bound = np.prod(complexities)
        cumulative = np.cumprod(complexities)
    elif mode == "residual":
        residual_complexities = [1 + c for c in complexities]
        total_bound = np.prod(residual_complexities)
        cumulative = np.cumprod(residual_complexities)
    else:
        raise ValueError(f"Unknown mode: {mode}")
    
    return {
        "n_layers": len(layers),
        "mode": mode,
        "individual_complexities": complexities,
        "total_bound": total_bound,
        "cumulative_bounds": cumulative.tolist(),
        "is_contractive": total_bound < 1.0,
        "log_complexity": np.log(total_bound) if total_bound > 0 else float('-inf'),
    }


# ============================================================================
# Algorithm 4: Greedy Architecture Search with Monotone Cost
# ============================================================================

@dataclass
class ArchDiagram:
    """Architecture diagram: assignment of bounded architectures to components.
    
    Corresponds to ArchCat.ArchDiagram in the Lean formalization.
    """
    components: List[BoundedArch]
    
    @property
    def cost(self) -> float:
        """Total diagram cost = sum of component complexities."""
        return sum(c.complexity for c in self.components)
    
    def improve_component(self, index: int, new_arch: BoundedArch) -> 'ArchDiagram':
        """
        Replace one component with a cheaper alternative.
        
        By diagram_cost_improve_component, if C(new) ≤ C(old),
        then Cost(new_diagram) ≤ Cost(old_diagram).
        """
        new_components = list(self.components)
        new_components[index] = new_arch
        return ArchDiagram(components=new_components)


def greedy_architecture_search(
    initial: ArchDiagram,
    candidates: List[List[BoundedArch]],
    max_iterations: int = 100
) -> Tuple[ArchDiagram, List[float]]:
    """
    Greedy architecture search with certified cost monotonicity.
    
    At each step, finds the component where replacement gives the largest
    cost reduction, and applies it. By diagram_cost_monotone, the cost
    sequence is guaranteed to be non-increasing.
    
    Complexity: O(max_iterations · J · K) where J = #components, K = max #candidates
    
    Args:
        initial: Starting architecture diagram
        candidates: For each component, list of alternative architectures
        max_iterations: Maximum search steps
        
    Returns:
        (best_diagram, cost_history)
    """
    current = initial
    cost_history = [current.cost]
    
    for _ in range(max_iterations):
        best_improvement = 0.0
        best_index = -1
        best_candidate = None
        
        for j, component_candidates in enumerate(candidates):
            current_complexity = current.components[j].complexity
            for candidate in component_candidates:
                if candidate.complexity < current_complexity:
                    improvement = current_complexity - candidate.complexity
                    if improvement > best_improvement:
                        best_improvement = improvement
                        best_index = j
                        best_candidate = candidate
        
        if best_index == -1:
            break  # No improving move found
        
        current = current.improve_component(best_index, best_candidate)
        cost_history.append(current.cost)
        
        # Verify monotonicity (guaranteed by Theorem 4)
        assert cost_history[-1] <= cost_history[-2] + 1e-10, \
            "Cost monotonicity violation! (should never happen)"
    
    return current, cost_history


# ============================================================================
# Example Usage
# ============================================================================

if __name__ == "__main__":
    np.random.seed(42)
    n = 4
    
    print("Algorithm 1: Residual Factorization")
    print("-" * 40)
    W = np.random.randn(n, n) * 0.3
    layer = BoundedArch.from_matrix(W, "layer1")
    pair_mat, res_mat = residual_factorize(layer)
    print(f"  Layer complexity: {layer.complexity:.4f}")
    print(f"  Pair matrix shape: {pair_mat.shape}")
    print(f"  Residual matrix = I + W, shape: {res_mat.shape}")
    
    layers = [BoundedArch.from_matrix(np.random.randn(n, n) * 0.2, f"L{i}") for i in range(4)]
    composed, bound = compose_residuals(layers)
    actual = np.linalg.norm(composed, ord=2)
    print(f"  Composed residual norm: {actual:.4f} ≤ {bound:.4f} (certified bound)")
    
    print("\nAlgorithm 2: Attention Naturality Verification")
    print("-" * 40)
    c = 0.5
    uniform = lambda x: c * x
    is_nat, viol = verify_attention_naturality(uniform, n=6)
    print(f"  Uniform attention natural: {is_nat} (max violation: {viol:.2e})")
    
    tanh_attn = lambda x: np.tanh(x) * x
    is_nat2, viol2 = verify_attention_naturality(tanh_attn, n=6)
    print(f"  Componentwise (tanh) natural: {is_nat2} (max violation: {viol2:.2e})")
    
    print("\nAlgorithm 3: Complexity Analysis")
    print("-" * 40)
    analysis = analyze_stack_complexity(layers, mode="multiplicative")
    print(f"  Multiplicative bound: {analysis['total_bound']:.4f}")
    analysis_res = analyze_stack_complexity(layers, mode="residual")
    print(f"  Residual bound: {analysis_res['total_bound']:.4f}")
    print(f"  Contractive (mult): {analysis['is_contractive']}")
    
    print("\nAlgorithm 4: Architecture Search")
    print("-" * 40)
    initial_diagram = ArchDiagram([
        BoundedArch.from_matrix(np.random.randn(n, n) * 0.5, f"comp{i}")
        for i in range(5)
    ])
    candidates = [
        [BoundedArch.from_matrix(np.random.randn(n, n) * s, f"alt{j}")
         for j, s in enumerate([0.4, 0.3, 0.2])]
        for _ in range(5)
    ]
    best, history = greedy_architecture_search(initial_diagram, candidates)
    print(f"  Initial cost: {history[0]:.4f}")
    print(f"  Final cost:   {history[-1]:.4f}")
    print(f"  Steps: {len(history)-1}")
    print(f"  Monotone: {all(history[i] >= history[i+1] - 1e-10 for i in range(len(history)-1))}")
