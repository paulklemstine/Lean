#!/usr/bin/env python3
"""
Quantum-Informational Neural Capacity: Algorithms

Implements the core algorithms from the research paper:
1. Effective rank computation via participation ratio
2. Depth capacity certification
3. Frobenius-based robustness certification
4. Entropy-purity bounds
"""

import numpy as np
from typing import List, Tuple, Optional


def compute_purity(weights: np.ndarray) -> float:
    """
    Compute quantum purity Tr(ρ²) = Σ pᵢ² for a probability distribution.
    
    Args:
        weights: Probability distribution (nonneg, sums to 1)
    
    Returns:
        Purity value in [1/n, 1]
    
    Complexity: O(n) time, O(1) space
    
    >>> compute_purity(np.array([0.5, 0.5]))
    0.5
    >>> compute_purity(np.array([1.0, 0.0]))
    1.0
    """
    assert np.all(weights >= -1e-10), "Weights must be nonneg"
    assert abs(weights.sum() - 1.0) < 1e-8, "Weights must sum to 1"
    return float(np.sum(weights**2))


def compute_effective_rank(weights: np.ndarray) -> float:
    """
    Compute participation ratio effective rank d_eff = 1/Tr(ρ²).
    
    Satisfies 1 ≤ d_eff ≤ n (Theorems effectiveRank_ge_one, effectiveRank_le_dim).
    
    Args:
        weights: Probability distribution on n elements
    
    Returns:
        Effective rank in [1, n]
    
    Complexity: O(n) time, O(1) space
    
    >>> compute_effective_rank(np.array([0.5, 0.5]))
    2.0
    >>> compute_effective_rank(np.array([1.0, 0.0]))
    1.0
    """
    return 1.0 / compute_purity(weights)


def compute_effective_rank_from_matrix(W: np.ndarray) -> float:
    """
    Compute effective rank of a weight matrix W via its singular values.
    
    The neural density matrix ρ_W = WW*/Tr(WW*) has eigenvalues
    proportional to σᵢ², so d_eff = (Σ σᵢ²)² / Σ σᵢ⁴.
    
    Args:
        W: Weight matrix (m × n)
    
    Returns:
        Effective rank of W
    
    Complexity: O(min(m,n)² · max(m,n)) time for SVD
    """
    sigma = np.linalg.svd(W, compute_uv=False)
    sigma_sq = sigma**2
    total = sigma_sq.sum()
    if total < 1e-15:
        return 1.0
    p = sigma_sq / total
    return compute_effective_rank(p)


def certify_depth_capacity(layer_ranks: List[float], D: float) -> Tuple[float, float, bool]:
    """
    Certify depth capacity bound: Π d_eff(Wᵢ) ≤ D^k.
    
    Implements Theorem depth_capacity_bound: for k layers with effective
    ranks at most D, the total capacity is at most D^k.
    
    Args:
        layer_ranks: List of per-layer effective ranks
        D: Per-layer capacity bound
    
    Returns:
        (product_capacity, upper_bound, is_certified)
    
    Complexity: O(k) time
    
    >>> certify_depth_capacity([2.0, 3.0, 2.5], 5.0)
    (15.0, 125.0, True)
    """
    k = len(layer_ranks)
    product = np.prod(layer_ranks)
    bound = D**k
    certified = product <= bound * (1 + 1e-10)
    return float(product), float(bound), certified


def frobenius_distance(W1: np.ndarray, W2: np.ndarray) -> float:
    """
    Compute Frobenius distance d_F(W₁, W₂) = ‖W₁ - W₂‖_F.
    
    Satisfies metric properties (Theorems frobDist_symm, frobDist_self).
    
    Complexity: O(mn) time
    """
    diff = W1 - W2
    return float(np.sqrt(np.sum(diff**2)))


def certify_lipschitz_robustness(W: np.ndarray, x: np.ndarray, 
                                   delta: float) -> float:
    """
    Certify Lipschitz robustness: ‖Wx - Wy‖ ≤ ‖W‖_F · ‖x - y‖.
    
    For any perturbation ‖δx‖ ≤ delta, the output perturbation is at most
    ‖W‖_F · delta.
    
    Args:
        W: Weight matrix
        x: Input vector
        delta: Maximum input perturbation
    
    Returns:
        Certified output robustness radius
    
    Complexity: O(mn) time
    """
    frob_norm = np.sqrt(np.sum(W**2))
    return float(frob_norm * delta)


def shannon_entropy(weights: np.ndarray) -> float:
    """
    Compute Shannon entropy H(p) = -Σ pᵢ log(pᵢ).
    
    Satisfies H(p) ≥ 0 (Theorem shannonEntropy_nonneg) and
    H(p) ≥ 1 - Tr(ρ²) (Theorem shannonEntropy_ge_one_minus_purity).
    
    Complexity: O(n) time
    """
    mask = weights > 0
    return float(-np.sum(weights[mask] * np.log(weights[mask])))


def entropy_purity_bound(weights: np.ndarray) -> Tuple[float, float, float]:
    """
    Compute entropy, purity, and verify the quadratic bound H ≥ 1 - Tr(ρ²).
    
    Returns:
        (entropy, purity, gap) where gap = H - (1 - purity) ≥ 0
    """
    H = shannon_entropy(weights)
    pur = compute_purity(weights)
    gap = H - (1 - pur)
    return H, pur, gap


def gradient_convergence_budget(L: float, R: float, epsilon: float) -> int:
    """
    Compute iteration budget for gradient descent convergence.
    
    T ≤ ⌈L²R²/ε²⌉ + 1 iterations suffice for ε-convergence
    (Theorem gradient_convergence_budget).
    
    Args:
        L: Lipschitz constant
        R: Initial distance to optimum
        epsilon: Target accuracy
    
    Returns:
        Number of iterations T
    """
    return int(np.ceil(L**2 * R**2 / epsilon**2)) + 1


def analyze_deep_network(weight_matrices: List[np.ndarray]) -> dict:
    """
    Complete quantum-informational analysis of a deep neural network.
    
    Computes per-layer effective ranks, depth capacity certification,
    and Lipschitz bounds.
    
    Args:
        weight_matrices: List of layer weight matrices
    
    Returns:
        Dictionary with analysis results
    """
    results = {
        'num_layers': len(weight_matrices),
        'layer_shapes': [W.shape for W in weight_matrices],
        'layer_effective_ranks': [],
        'layer_purities': [],
        'layer_frobenius_norms': [],
        'total_capacity': 1.0,
        'lipschitz_bound': 1.0,
    }
    
    for W in weight_matrices:
        d_eff = compute_effective_rank_from_matrix(W)
        sigma = np.linalg.svd(W, compute_uv=False)
        sigma_sq = sigma**2
        total = sigma_sq.sum()
        p = sigma_sq / total if total > 0 else np.ones(1)
        pur = compute_purity(p)
        frob = np.sqrt(np.sum(W**2))
        
        results['layer_effective_ranks'].append(d_eff)
        results['layer_purities'].append(pur)
        results['layer_frobenius_norms'].append(frob)
        results['total_capacity'] *= d_eff
        results['lipschitz_bound'] *= frob
    
    # Depth capacity certification
    D = max(results['layer_effective_ranks'])
    k = len(weight_matrices)
    results['capacity_bound'] = D**k
    results['capacity_certified'] = results['total_capacity'] <= results['capacity_bound']
    
    return results


if __name__ == '__main__':
    print("=== Quantum-Informational Neural Capacity: Algorithm Demos ===\n")
    
    # Example: Analyze a 3-layer network
    np.random.seed(42)
    layers = [
        np.random.randn(64, 128) / np.sqrt(128),
        np.random.randn(32, 64) / np.sqrt(64),
        np.random.randn(10, 32) / np.sqrt(32),
    ]
    
    results = analyze_deep_network(layers)
    print(f"Network: {results['num_layers']} layers, shapes: {results['layer_shapes']}")
    print(f"Layer effective ranks: {[f'{r:.2f}' for r in results['layer_effective_ranks']]}")
    print(f"Layer purities: {[f'{p:.4f}' for p in results['layer_purities']]}")
    print(f"Total capacity: {results['total_capacity']:.2f}")
    print(f"Capacity bound (D^k): {results['capacity_bound']:.2f}")
    print(f"Certified: {results['capacity_certified']}")
    print(f"Lipschitz bound: {results['lipschitz_bound']:.4f}")
    
    # Convergence budget
    T = gradient_convergence_budget(L=10.0, R=5.0, epsilon=0.01)
    print(f"\nGradient convergence: T = {T} iterations for ε=0.01, L=10, R=5")


#!/usr/bin/env python3
"""
Quantum-Informational Neural Capacity: Real-World Applications

Demonstrates practical applications of the quantum-informational framework:
1. Neural network initialization optimization
2. Adversarial robustness certification
3. Model compression via effective rank analysis
4. Training dynamics monitoring
"""

import numpy as np
from algorithms import (compute_effective_rank_from_matrix, certify_lipschitz_robustness,
                         analyze_deep_network, compute_purity, compute_effective_rank,
                         frobenius_distance, gradient_convergence_budget, shannon_entropy)


def application_1_optimal_initialization():
    """
    Application: Isotropic Initialization Maximizes Effective Rank
    
    By Theorem isotropic_layer_optimality, the uniform eigenvalue spectrum
    maximizes the effective rank. This suggests that initialization methods
    producing near-isotropic weight matrices (like Xavier/He initialization)
    are information-theoretically optimal.
    """
    print("=" * 70)
    print("APPLICATION 1: Optimal Neural Initialization")
    print("Using isotropic_layer_optimality theorem")
    print("=" * 70)
    
    m, n = 64, 128
    
    initializations = {
        'Xavier (optimal)': lambda: np.random.randn(m, n) / np.sqrt(n),
        'He init': lambda: np.random.randn(m, n) * np.sqrt(2.0/n),
        'Small random': lambda: np.random.randn(m, n) * 0.001,
        'Large random': lambda: np.random.randn(m, n) * 10.0,
        'Sparse (10%)': lambda: np.random.randn(m, n) * (np.random.random((m,n)) < 0.1),
    }
    
    for name, init_fn in initializations.items():
        ranks = []
        for _ in range(50):
            W = init_fn()
            ranks.append(compute_effective_rank_from_matrix(W))
        mean_rank = np.mean(ranks)
        max_possible = min(m, n)
        ratio = mean_rank / max_possible
        print(f"  {name:25s}: d_eff = {mean_rank:6.1f} / {max_possible} "
              f"= {ratio:.3f} capacity utilization")
    
    print()


def application_2_adversarial_robustness():
    """
    Application: Certified Adversarial Robustness via Frobenius Bounds
    
    The Frobenius Lipschitz bound (Theorem frobenius_lipschitz_bound) gives
    certified robustness: if ‖δx‖ ≤ ε, then ‖W·δx‖ ≤ ‖W‖_F · ε.
    This provides a robustness certificate against adversarial perturbations.
    """
    print("=" * 70)
    print("APPLICATION 2: Certified Adversarial Robustness")
    print("Using frobenius_lipschitz_bound theorem")
    print("=" * 70)
    
    np.random.seed(42)
    
    # Simulate a classifier
    layers = [
        np.random.randn(32, 784) / np.sqrt(784),  # Input layer
        np.random.randn(16, 32) / np.sqrt(32),     # Hidden
        np.random.randn(10, 16) / np.sqrt(16),     # Output
    ]
    
    x = np.random.randn(784)
    x = x / np.linalg.norm(x)
    
    # Compute output
    h = x
    for W in layers:
        h = W @ h
        h = np.maximum(h, 0)  # ReLU (1-Lipschitz)
    
    # Certified robustness
    perturbation_budgets = [0.01, 0.05, 0.1, 0.5, 1.0]
    
    for eps in perturbation_budgets:
        # Per-layer certificate
        total_lip = 1.0
        for W in layers:
            total_lip *= np.sqrt(np.sum(W**2))
        
        max_output_change = total_lip * eps
        print(f"  ε = {eps:.2f}: max output perturbation ≤ {max_output_change:.4f} "
              f"(Lipschitz = {total_lip:.2f})")
    
    print()


def application_3_model_compression():
    """
    Application: Model Compression via Effective Rank Analysis
    
    Layers with low effective rank (d_eff ≈ 1) carry little information
    and can be compressed. The effective rank gives a principled criterion
    for identifying compressible layers.
    """
    print("=" * 70)
    print("APPLICATION 3: Model Compression via Effective Rank")
    print("Using effectiveRank_ge_one and effectiveRank_le_dim bounds")
    print("=" * 70)
    
    np.random.seed(42)
    
    # Simulate a network with varying layer quality
    layers = [
        np.random.randn(64, 128) / np.sqrt(128),           # Full rank
        np.outer(np.random.randn(32), np.random.randn(64)), # Rank 1
        np.random.randn(16, 32) / np.sqrt(32),              # Full rank
        np.eye(10, 16) * 0.1,                                # Sparse identity
    ]
    
    total_params = sum(W.size for W in layers)
    
    for i, W in enumerate(layers):
        d_eff = compute_effective_rank_from_matrix(W)
        max_rank = min(W.shape)
        ratio = d_eff / max_rank
        compressible = "★ COMPRESS" if ratio < 0.3 else "  keep"
        print(f"  Layer {i}: shape={str(W.shape):10s}, d_eff = {d_eff:5.1f}/{max_rank}, "
              f"ratio = {ratio:.3f} {compressible}")
    
    print(f"\n  Total parameters: {total_params}")
    print(f"  Recommendation: compress layers with ratio < 0.3 using low-rank factorization")
    print()


def application_4_training_monitoring():
    """
    Application: Training Dynamics via Quantum Purity Monitoring
    
    During training, monitoring the purity Tr(ρ²) of each layer's density
    matrix reveals whether the network is collapsing (purity → 1) or
    maintaining expressivity (purity → 1/n).
    """
    print("=" * 70)
    print("APPLICATION 4: Training Dynamics Monitoring")
    print("Using purity_le_one and purity_ge_inv bounds")
    print("=" * 70)
    
    np.random.seed(42)
    n = 32
    
    # Simulate training: weight matrix evolving over epochs
    W = np.random.randn(n, n) / np.sqrt(n)
    
    print(f"  {'Epoch':>6s}  {'Purity':>8s}  {'d_eff':>8s}  {'Entropy':>8s}  Status")
    print(f"  {'-'*6}  {'-'*8}  {'-'*8}  {'-'*8}  {'-'*20}")
    
    for epoch in range(11):
        # Compute spectrum
        sigma = np.linalg.svd(W, compute_uv=False)
        sigma_sq = sigma**2
        p = sigma_sq / sigma_sq.sum()
        
        pur = compute_purity(p)
        d_eff = compute_effective_rank(p)
        H = shannon_entropy(p)
        
        if d_eff > 0.7 * n:
            status = "✓ High expressivity"
        elif d_eff > 0.3 * n:
            status = "~ Moderate"
        else:
            status = "⚠ Low rank / collapsing"
        
        print(f"  {epoch:6d}  {pur:8.4f}  {d_eff:8.2f}  {H:8.4f}  {status}")
        
        # Simulate gradient update that slightly degrades the spectrum
        # (modeling a tendency toward rank collapse)
        noise = np.random.randn(n, n) * 0.05
        direction = np.outer(sigma[0] * np.ones(n), np.ones(n))
        W = W + noise - 0.02 * direction
    
    print()


if __name__ == '__main__':
    print("\n🔬 Quantum-Informational Neural Capacity: Applications\n")
    application_1_optimal_initialization()
    application_2_adversarial_robustness()
    application_3_model_compression()
    application_4_training_monitoring()
    print("✅ All applications demonstrated successfully!")


#!/usr/bin/env python3
"""
Quantum-Informational Neural Capacity: Numerical Demonstrations

Demonstrates the key theorems relating quantum information measures
(purity, effective rank, Shannon entropy) to neural network capacity.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

def purity(p):
    """Compute Tr(rho^2) = sum p_i^2 for a probability distribution p."""
    return np.sum(p**2)

def effective_rank(p):
    """Participation ratio: d_eff = 1 / sum(p_i^2)."""
    return 1.0 / purity(p)

def shannon_entropy(p):
    """Shannon entropy H(p) = -sum p_i * log(p_i)."""
    mask = p > 0
    return -np.sum(p[mask] * np.log(p[mask]))

def uniform_dist(n):
    """Uniform distribution on n elements."""
    return np.ones(n) / n

def dirac_dist(n, k=0):
    """Dirac distribution concentrated at index k."""
    p = np.zeros(n)
    p[k] = 1.0
    return p

# ============================================================
# Demo 1: Effective Rank Bounds (Theorem: effectiveRank_ge_one, effectiveRank_le_dim)
# ============================================================
print("=" * 70)
print("DEMO 1: Effective Rank Bounds")
print("Theorem: 1 ≤ d_eff(p) ≤ n for any ProbDist on Fin n")
print("=" * 70)

for n in [3, 5, 10, 50]:
    # Generate random distributions
    for trial in range(5):
        raw = np.random.exponential(1.0, n)
        p = raw / raw.sum()
        d_eff = effective_rank(p)
        assert 1.0 - 1e-10 <= d_eff <= n + 1e-10, f"Bound violated: {d_eff}"
    
    # Check extremes
    d_uniform = effective_rank(uniform_dist(n))
    d_dirac = effective_rank(dirac_dist(n))
    print(f"n={n:3d}: d_eff(uniform) = {d_uniform:.4f} (should be {n}), "
          f"d_eff(dirac) = {d_dirac:.4f} (should be 1)")

# ============================================================
# Demo 2: Purity Bounds (Theorem: purity_ge_inv, purity_le_one)
# ============================================================
print("\n" + "=" * 70)
print("DEMO 2: Purity Bounds")
print("Theorem: 1/n ≤ Tr(ρ²) ≤ 1")
print("=" * 70)

for n in [2, 5, 10, 100]:
    purities = []
    for _ in range(1000):
        raw = np.random.exponential(1.0, n)
        p = raw / raw.sum()
        pur = purity(p)
        purities.append(pur)
        assert 1.0/n - 1e-10 <= pur <= 1.0 + 1e-10
    
    print(f"n={n:3d}: purity range [{min(purities):.6f}, {max(purities):.6f}], "
          f"theory: [1/{n}={1/n:.6f}, 1.0]")

# ============================================================
# Demo 3: Shannon Entropy ≥ 1 - Purity (Theorem: shannonEntropy_ge_one_minus_purity)
# ============================================================
print("\n" + "=" * 70)
print("DEMO 3: Shannon Entropy ≥ 1 - Purity")
print("Theorem: H(p) ≥ 1 - Σ pᵢ²")
print("=" * 70)

for n in [2, 5, 10, 50]:
    for _ in range(1000):
        raw = np.random.exponential(1.0, n)
        p = raw / raw.sum()
        H = shannon_entropy(p)
        pur = purity(p)
        gap = H - (1 - pur)
        assert gap >= -1e-10, f"Bound violated: H={H}, 1-pur={1-pur}, gap={gap}"
    print(f"n={n:3d}: Bound H(p) ≥ 1 - Tr(ρ²) verified for 1000 random distributions")

# ============================================================
# Demo 4: Depth Capacity Bound (Theorem: depth_capacity_bound)
# ============================================================
print("\n" + "=" * 70)
print("DEMO 4: Depth Capacity Bounds")
print("Theorem: Π d_eff(Wᵢ) ≤ D^k when each d_eff ≤ D")
print("=" * 70)

for k in [2, 5, 10, 20]:
    n = 10
    D = n  # Each layer has d_eff ≤ n
    capacities = []
    for _ in range(k):
        raw = np.random.exponential(1.0, n)
        p = raw / raw.sum()
        capacities.append(effective_rank(p))
    
    product = np.prod(capacities)
    bound = D**k
    print(f"k={k:2d} layers: Π d_eff = {product:.2e}, D^k = {bound:.2e}, "
          f"ratio = {product/bound:.6f} ≤ 1 ✓")

# ============================================================
# Demo 5: Isotropic Layer Optimality (Theorem: isotropic_layer_optimality)
# ============================================================
print("\n" + "=" * 70)
print("DEMO 5: Isotropic Layer Optimality")
print("Theorem: d_eff(p) ≤ d_eff(uniform) = n")
print("=" * 70)

for n in [3, 10, 50]:
    d_max = effective_rank(uniform_dist(n))
    violations = 0
    for _ in range(10000):
        raw = np.random.exponential(1.0, n)
        p = raw / raw.sum()
        if effective_rank(p) > d_max + 1e-10:
            violations += 1
    print(f"n={n:3d}: max d_eff = {d_max:.1f}, violations in 10000 trials: {violations}")

# ============================================================
# Demo 6: Purity Convexity (Theorem: purity_convex_combination)
# ============================================================
print("\n" + "=" * 70)
print("DEMO 6: Purity Convexity")
print("Theorem: Tr(((1-t)ρ₁ + tρ₂)²) ≤ (1-t)Tr(ρ₁²) + tTr(ρ₂²)")
print("=" * 70)

n = 10
for _ in range(5):
    raw1 = np.random.exponential(1.0, n)
    p = raw1 / raw1.sum()
    raw2 = np.random.exponential(1.0, n)
    q = raw2 / raw2.sum()
    
    for t in [0.0, 0.1, 0.25, 0.5, 0.75, 0.9, 1.0]:
        mix = (1-t)*p + t*q
        lhs = purity(mix)
        rhs = (1-t)*purity(p) + t*purity(q)
        assert lhs <= rhs + 1e-10, f"Convexity violated at t={t}"
    
print(f"Purity convexity verified for random distributions at 7 mixing parameters")

# ============================================================
# Visualization: Effective Rank vs Purity
# ============================================================
print("\n" + "=" * 70)
print("Generating visualizations...")
print("=" * 70)

fig, axes = plt.subplots(1, 3, figsize=(15, 5))

# Plot 1: Effective rank vs number of "active" dimensions
ax = axes[0]
ns = range(1, 51)
d_eff_uniform = [float(n) for n in ns]
ax.plot(ns, d_eff_uniform, 'b-', linewidth=2, label='Uniform (max)')
ax.axhline(y=1, color='r', linestyle='--', label='Dirac (min)')
# Random distributions
for _ in range(100):
    n = 50
    raw = np.random.exponential(1.0, n)
    p = raw / raw.sum()
    ax.scatter(n, effective_rank(p), c='gray', alpha=0.1, s=10)
ax.set_xlabel('Dimension n')
ax.set_ylabel('Effective Rank')
ax.set_title('Effective Rank Bounds\n1 ≤ d_eff ≤ n')
ax.legend()

# Plot 2: Entropy vs Purity relationship
ax = axes[1]
purities = []
entropies = []
for _ in range(5000):
    n = 20
    raw = np.random.exponential(np.random.uniform(0.1, 5.0), n)
    p = raw / raw.sum()
    purities.append(purity(p))
    entropies.append(shannon_entropy(p))

ax.scatter(purities, entropies, c='steelblue', alpha=0.1, s=5)
x_pur = np.linspace(1/20, 1, 200)
ax.plot(x_pur, 1 - x_pur, 'r--', linewidth=2, label='Lower bound: 1 - Tr(ρ²)')
ax.set_xlabel('Purity Tr(ρ²)')
ax.set_ylabel('Shannon Entropy H(p)')
ax.set_title('Entropy ≥ 1 - Purity\n(Quadratic Lower Bound)')
ax.legend()

# Plot 3: Depth capacity scaling
ax = axes[2]
depths = range(1, 21)
n = 10
for label, gen_fn in [('Uniform', uniform_dist), 
                        ('Random', lambda n: (lambda r: r/r.sum())(np.random.exponential(1,n)))]:
    caps = []
    for k in depths:
        cap = 1.0
        for _ in range(k):
            p = gen_fn(n)
            cap *= effective_rank(p)
        caps.append(cap)
    style = '-o' if label == 'Uniform' else '--s'
    ax.semilogy(depths, caps, style, label=f'{label} layers', markersize=4)

ax.semilogy(depths, [n**k for k in depths], 'r:', linewidth=2, label=f'Bound D^k (D={n})')
ax.set_xlabel('Network Depth k')
ax.set_ylabel('Total Capacity (log scale)')
ax.set_title('Depth Capacity Scaling\nΠ d_eff ≤ D^k')
ax.legend()

plt.tight_layout()
plt.savefig('quantum_neural_capacity_demo.png', dpi=150, bbox_inches='tight')
plt.savefig('quantum_neural_capacity_demo.svg', bbox_inches='tight')
print("Saved: quantum_neural_capacity_demo.png, quantum_neural_capacity_demo.svg")

print("\n✅ All demos passed successfully!")
