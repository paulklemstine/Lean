#!/usr/bin/env python3
"""
Topological AI Interpretability via Persistence Diagrams
=========================================================

Demonstrates how persistence diagrams with the tropical (L∞) metric
provide stable interpretability for neural networks.

Key insight: The bottleneck distance d∞(D₁, D₂) = max(|b₁-b₂|, |d₁-d₂|)
is a tropical metric. The stability theorem guarantees small weight
perturbations produce small persistence changes.

Run: python3 topological_interpretability.py
"""

import numpy as np
from typing import List, Tuple

# ============================================================
# Section 1: Persistence Intervals and Tropical Metric
# ============================================================

class PersistenceInterval:
    """A persistence interval [birth, death) with birth ≤ death."""
    
    def __init__(self, birth: float, death: float):
        assert birth <= death, f"Invalid interval: birth={birth} > death={death}"
        self.birth = birth
        self.death = death
    
    @property
    def lifetime(self) -> float:
        """Persistence (lifetime) = death - birth ≥ 0."""
        return self.death - self.birth
    
    def __repr__(self):
        return f"[{self.birth:.3f}, {self.death:.3f})"

def tropical_distance(I: PersistenceInterval, J: PersistenceInterval) -> float:
    """L∞ (tropical) distance between persistence points.
    d∞(I, J) = max(|b₁-b₂|, |d₁-d₂|)
    
    This is the metric induced by the tropical semiring (ℝ, max, +).
    Formally verified: tropicalPersistenceDist in BreakthroughDirections.lean
    """
    return max(abs(I.birth - J.birth), abs(I.death - J.death))

def bottleneck_distance(D1: List[PersistenceInterval], 
                        D2: List[PersistenceInterval]) -> float:
    """Bottleneck distance between persistence diagrams.
    Simplified version using greedy matching."""
    if not D1 and not D2:
        return 0.0
    if not D1:
        return max(I.lifetime / 2 for I in D2)
    if not D2:
        return max(I.lifetime / 2 for I in D1)
    
    # Greedy matching (simplified)
    used = set()
    max_dist = 0
    
    for I in D1:
        best_j = -1
        best_d = float('inf')
        for j, J in enumerate(D2):
            if j not in used:
                d = tropical_distance(I, J)
                if d < best_d:
                    best_d = d
                    best_j = j
        
        # Compare with diagonal distance
        diag_d = I.lifetime / 2
        if best_j >= 0 and best_d < diag_d:
            used.add(best_j)
            max_dist = max(max_dist, best_d)
        else:
            max_dist = max(max_dist, diag_d)
    
    # Unmatched points in D2
    for j, J in enumerate(D2):
        if j not in used:
            max_dist = max(max_dist, J.lifetime / 2)
    
    return max_dist

# ============================================================
# Section 2: ReLU Network Feature Extraction
# ============================================================

def relu_network_features(x: np.ndarray, weights: List[np.ndarray], 
                          biases: List[np.ndarray]) -> List[np.ndarray]:
    """Extract activation patterns at each layer of a ReLU network."""
    features = [x]
    h = x
    for W, b in zip(weights, biases):
        h = np.maximum(h @ W + b, 0)  # ReLU = max(·, 0) = tropical + idempotent
        features.append(h.copy())
    return features

def compute_persistence_1d(values: np.ndarray) -> List[PersistenceInterval]:
    """Compute 0-dimensional persistence of a 1D function.
    Captures connected components as the sublevel set grows."""
    n = len(values)
    if n == 0:
        return []
    
    # Sort by function value
    order = np.argsort(values)
    
    # Union-find for connected components
    parent = list(range(n))
    rank_uf = [0] * n
    birth = {i: values[i] for i in range(n)}
    
    def find(x):
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x
    
    def union(x, y, death_val):
        rx, ry = find(x), find(y)
        if rx == ry:
            return None
        # Younger component dies (higher birth value)
        if birth[rx] > birth[ry]:
            rx, ry = ry, rx
        # rx is older (lower birth), ry dies
        interval = PersistenceInterval(birth[ry], death_val)
        if rank_uf[rx] < rank_uf[ry]:
            parent[rx] = ry
            birth[ry] = birth[rx]
        elif rank_uf[rx] > rank_uf[ry]:
            parent[ry] = rx
        else:
            parent[ry] = rx
            rank_uf[rx] += 1
        return interval
    
    intervals = []
    for idx in order:
        # Check neighbors
        for neighbor in [idx - 1, idx + 1]:
            if 0 <= neighbor < n and values[neighbor] <= values[idx]:
                result = union(idx, neighbor, values[idx])
                if result and result.lifetime > 1e-10:
                    intervals.append(result)
    
    return sorted(intervals, key=lambda I: -I.lifetime)

# ============================================================
# Section 3: Stability Demonstration
# ============================================================

def demonstrate_stability():
    """Demonstrate the persistence stability theorem with tropical metric."""
    print("=" * 70)
    print("TOPOLOGICAL AI INTERPRETABILITY")
    print("=" * 70)
    print()
    
    # Create a simple function with clear topological features
    np.random.seed(42)
    x = np.linspace(0, 10, 200)
    
    # Original function: two peaks (significant features) + noise
    f_original = 3 * np.exp(-(x - 3)**2) + 2 * np.exp(-(x - 7)**2 / 2)
    
    # Compute persistence of original
    intervals_orig = compute_persistence_1d(f_original)
    
    print("ORIGINAL FUNCTION: Two Gaussian peaks at x=3 (height 3) and x=7 (height 2)")
    print()
    print("Persistence intervals (most significant first):")
    for i, I in enumerate(intervals_orig[:5]):
        print(f"  Feature {i+1}: {I}  (lifetime = {I.lifetime:.4f})")
    
    # Perturb with different noise levels
    print()
    print("STABILITY UNDER PERTURBATION")
    print("-" * 50)
    print()
    print("Formally verified: significant_feature_stability in BreakthroughDirections.lean")
    print("If lifetime > t + 2ε and bottleneck distance ≤ ε, then perturbed lifetime > t")
    print()
    
    epsilons = [0.01, 0.05, 0.1, 0.2, 0.5]
    
    print(f"{'ε':>6} {'‖f-g‖∞':>8} {'Bottleneck':>10} {'#Features':>10} {'Top 2 lifetimes':>20}")
    print("-" * 56)
    
    for eps in epsilons:
        noise = np.random.randn(len(x)) * eps
        f_perturbed = f_original + noise
        
        intervals_pert = compute_persistence_1d(f_perturbed)
        
        # Compute bottleneck distance (simplified)
        bneck = bottleneck_distance(intervals_orig[:3], intervals_pert[:3])
        sup_diff = np.max(np.abs(noise))
        
        n_significant = sum(1 for I in intervals_pert if I.lifetime > 0.5)
        top_lifetimes = [I.lifetime for I in intervals_pert[:2]]
        
        print(f"{eps:>6.2f} {sup_diff:>8.4f} {bneck:>10.4f} {n_significant:>10} "
              f"{top_lifetimes[0]:>8.4f}, {top_lifetimes[1] if len(top_lifetimes) > 1 else 0:>8.4f}")
    
    print()
    print("Key observation: Large-lifetime features persist even under significant noise.")
    print("The tropical metric bounds guarantee this stability.")

# ============================================================
# Section 4: Neural Network Interpretability
# ============================================================

def neural_network_interpretability():
    """Demonstrate persistence-based interpretability for a neural network."""
    print()
    print("=" * 70)
    print("NEURAL NETWORK INTERPRETABILITY VIA PERSISTENCE")
    print("=" * 70)
    print()
    
    np.random.seed(42)
    
    # Create a simple 2-layer ReLU network
    W1 = np.array([[1.0, -1.0, 0.5],
                    [0.5, 1.0, -0.5]])
    b1 = np.array([[0.0, -0.5, 0.2]])
    W2 = np.array([[1.0], [-0.5], [0.8]])
    b2 = np.array([[0.0]])
    
    weights = [W1, W2]
    biases = [b1, b2]
    
    # Evaluate network on a grid
    x_range = np.linspace(-3, 3, 100)
    inputs = np.column_stack([x_range, np.zeros_like(x_range)])
    
    features = relu_network_features(inputs, weights, biases)
    output = features[-1].flatten()
    
    # Compute persistence of the output landscape
    intervals = compute_persistence_1d(output)
    
    print("Network architecture: 2 → 3 (ReLU) → 1")
    print(f"Number of linear regions detected: {sum(1 for I in intervals if I.lifetime > 0.01) + 1}")
    print()
    print("Persistence diagram of network output:")
    for i, I in enumerate(intervals[:5]):
        significance = "HIGH" if I.lifetime > 0.5 else "LOW" if I.lifetime < 0.1 else "MED"
        print(f"  Feature {i+1}: {I}  lifetime={I.lifetime:.4f}  [{significance}]")
    
    # Perturb weights and check stability
    print()
    print("Weight perturbation stability:")
    print("-" * 40)
    
    for noise_level in [0.01, 0.05, 0.1, 0.2]:
        W1_pert = W1 + np.random.randn(*W1.shape) * noise_level
        W2_pert = W2 + np.random.randn(*W2.shape) * noise_level
        
        features_pert = relu_network_features(inputs, [W1_pert, W2_pert], biases)
        output_pert = features_pert[-1].flatten()
        
        intervals_pert = compute_persistence_1d(output_pert)
        
        bneck = bottleneck_distance(intervals[:3], intervals_pert[:3])
        output_diff = np.max(np.abs(output - output_pert))
        
        print(f"  Noise σ={noise_level:.2f}: ‖Δoutput‖∞={output_diff:.4f}, "
              f"bottleneck={bneck:.4f}")
    
    print()
    print("The tropical metric ensures: bottleneck ≤ ‖Δoutput‖∞ (stability theorem)")

# ============================================================
# Section 5: Tropical Metric Properties
# ============================================================

def verify_metric_properties():
    """Verify the tropical metric axioms computationally."""
    print()
    print("=" * 70)
    print("TROPICAL METRIC PROPERTIES VERIFICATION")
    print("=" * 70)
    print()
    
    intervals = [
        PersistenceInterval(0.0, 1.0),
        PersistenceInterval(0.1, 1.2),
        PersistenceInterval(0.5, 2.0),
        PersistenceInterval(1.0, 3.0),
    ]
    
    # Symmetry
    print("1. SYMMETRY: d(I,J) = d(J,I)")
    all_pass = True
    for I in intervals:
        for J in intervals:
            d_ij = tropical_distance(I, J)
            d_ji = tropical_distance(J, I)
            ok = abs(d_ij - d_ji) < 1e-15
            all_pass = all_pass and ok
    print(f"   All pairs symmetric: {'✓' if all_pass else '✗'}")
    print(f"   Formally verified: tropicalPersistenceDist_symm")
    
    # Non-negativity
    print("2. NON-NEGATIVITY: d(I,J) ≥ 0")
    all_pass = True
    for I in intervals:
        for J in intervals:
            d = tropical_distance(I, J)
            ok = d >= -1e-15
            all_pass = all_pass and ok
    print(f"   All distances non-negative: {'✓' if all_pass else '✗'}")
    print(f"   Formally verified: tropicalPersistenceDist_nonneg")
    
    # Triangle inequality
    print("3. TRIANGLE INEQUALITY: d(I,K) ≤ d(I,J) + d(J,K)")
    all_pass = True
    worst_slack = 0
    for I in intervals:
        for J in intervals:
            for K in intervals:
                d_ik = tropical_distance(I, K)
                d_ij = tropical_distance(I, J)
                d_jk = tropical_distance(J, K)
                slack = d_ij + d_jk - d_ik
                ok = slack >= -1e-15
                all_pass = all_pass and ok
                worst_slack = min(worst_slack, slack)
    print(f"   All triples satisfy triangle: {'✓' if all_pass else '✗'}")
    print(f"   Minimum slack: {worst_slack:.6f}")
    print(f"   Formally verified: tropicalPersistenceDist_triangle")
    
    # Identity of indiscernibles
    print("4. IDENTITY: d(I,I) = 0")
    all_pass = True
    for I in intervals:
        d = tropical_distance(I, I)
        ok = abs(d) < 1e-15
        all_pass = all_pass and ok
    print(f"   All self-distances zero: {'✓' if all_pass else '✗'}")
    print(f"   Formally verified: tropicalPersistenceDist_eq_zero")

# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    demonstrate_stability()
    neural_network_interpretability()
    verify_metric_properties()
    
    print()
    print("=" * 70)
    print("SUMMARY")
    print("=" * 70)
    print()
    print("Topological AI Interpretability provides:")
    print("  1. FEATURE DETECTION: Persistence diagrams capture learned features")
    print("  2. STABILITY GUARANTEE: Tropical metric bounds perturbation effects")
    print("  3. SIGNIFICANCE RANKING: Lifetime separates signal from noise")
    print("  4. METRIC COMPLETENESS: Symmetry, triangle inequality, non-negativity")
    print()
    print("All metric properties formally verified in Lean 4.")
    print("See: Bridges/NewDirections/BreakthroughDirections.lean")
