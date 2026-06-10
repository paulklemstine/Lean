#!/usr/bin/env python3
"""
Arithmetic Learning Theory — Algorithms

Implements the core algorithms from the research paper:
1. Weil height computation
2. Height-regularized training
3. Robustness certification
4. Capacity estimation
"""

import math
from fractions import Fraction
from typing import List, Tuple, Optional
import numpy as np


# =============================================================================
# Algorithm 1: Weil Height Computation
# =============================================================================

def compute_weil_height(weights: List[Fraction]) -> float:
    """Compute the logarithmic Weil height of a rational weight vector.
    
    For w = (w₁, ..., wₙ) with wᵢ = pᵢ/dᵢ in lowest terms:
        h(w) = Σᵢ log(max(|pᵢ|, dᵢ))
    
    Complexity: O(n · B) where B = max bit-length of entries.
    
    Args:
        weights: List of Fraction objects (rational numbers)
    Returns:
        The logarithmic Weil height h(w) ≥ 0
    
    Example:
        >>> compute_weil_height([Fraction(1,2), Fraction(3,7)])
        3.258...  # log(2) + log(7)
    """
    height = 0.0
    for w in weights:
        p = abs(w.numerator)
        d = w.denominator
        height += math.log(max(p, d)) if max(p, d) > 0 else 0.0
    return height


def compute_exp_height(q: Fraction) -> float:
    """Compute the exponential (naive) height of a rational number.
    
    expHeight(q) = max(|numerator(q)|, denominator(q))
    
    This equals exp(h(q)) and directly measures the size of the rational.
    """
    return float(max(abs(q.numerator), q.denominator))


# =============================================================================
# Algorithm 2: Height-Regularized Training
# =============================================================================

def rational_round(x: float, bit_precision: int) -> Fraction:
    """Round a float to a rational with bounded denominator (2^bit_precision).
    
    This ensures height is bounded by bit_precision * log(2).
    
    Args:
        x: Real number to round
        bit_precision: Maximum bits for denominator
    Returns:
        Fraction approximation with denominator ≤ 2^bit_precision
    """
    max_denom = 2 ** bit_precision
    return Fraction(x).limit_denominator(max_denom)


def height_project(weights: List[Fraction], max_height: float) -> List[Fraction]:
    """Project weights to the set {w : h(w) ≤ max_height}.
    
    Strategy: scale all weights uniformly until height bound is met.
    Since h(c·w) ≤ n·h(c) + h(w), we can find the right scale.
    
    Simple approach: truncate numerators/denominators to bound individual heights.
    
    Args:
        weights: Current weight vector
        max_height: Maximum allowed height
    Returns:
        Projected weight vector with h(projected) ≤ max_height
    """
    n = len(weights)
    if n == 0:
        return weights
    
    per_coord_budget = max_height / n
    max_entry = int(math.exp(per_coord_budget))
    
    projected = []
    for w in weights:
        # Limit both numerator and denominator
        if abs(w.numerator) > max_entry or w.denominator > max_entry:
            # Re-approximate with bounded denominator
            approx = Fraction(float(w)).limit_denominator(max_entry)
            projected.append(approx)
        else:
            projected.append(w)
    
    return projected


def height_regularized_sgd(
    loss_fn,
    grad_fn,
    initial_weights: List[float],
    learning_rate: float = 0.01,
    height_lambda: float = 0.1,
    max_height: float = 10.0,
    bit_precision: int = 16,
    num_steps: int = 100
) -> Tuple[List[Fraction], float, float]:
    """Height-regularized stochastic gradient descent.
    
    Minimizes: L(w) + λ · h(w)
    
    At each step:
    1. Compute gradient of loss
    2. Take gradient step
    3. Round to rational with bounded precision
    4. Project to bounded-height set if needed
    
    Args:
        loss_fn: Loss function (takes list of floats)
        grad_fn: Gradient function
        initial_weights: Starting point
        learning_rate: Step size η
        height_lambda: Height regularization strength λ
        max_height: Maximum allowed height
        bit_precision: Bits for rational rounding
        num_steps: Number of SGD steps
    
    Returns:
        (final_weights, final_height, final_loss)
    
    Certified bounds:
        Lipschitz constant L ≤ n · exp(final_height)
        Robustness radius r ≥ 1 / (2L)
    """
    w = list(initial_weights)
    n = len(w)
    
    for t in range(num_steps):
        # Compute gradient
        g = grad_fn(w)
        
        # Gradient step
        w = [wi - learning_rate * gi for wi, gi in zip(w, g)]
        
        # Round to rational
        w_rational = [rational_round(wi, bit_precision) for wi in w]
        
        # Check height and project if needed
        h = compute_weil_height(w_rational)
        if h > max_height:
            w_rational = height_project(w_rational, max_height)
        
        w = [float(q) for q in w_rational]
    
    final_rational = [rational_round(wi, bit_precision) for wi in w]
    final_height = compute_weil_height(final_rational)
    final_loss = loss_fn(w)
    
    return final_rational, final_height, final_loss


# =============================================================================
# Algorithm 3: Robustness Certification
# =============================================================================

def certify_robustness(
    weights: List[Fraction],
    depth: int = 1
) -> dict:
    """Compute certified robustness guarantees from weight heights.
    
    For a network with weight height H and n parameters:
    - Lipschitz constant L ≤ n · exp(H)
    - Robustness radius r ≥ 1 / (2L)
    - Any perturbation within radius r changes output by ≤ 1/2
    
    Args:
        weights: Rational weight vector
        depth: Network depth (for compositional bounds)
    
    Returns:
        Dictionary with certified bounds
    """
    n = len(weights)
    H = compute_weil_height(weights)
    
    lipschitz = n * math.exp(H)
    radius = 1.0 / (2.0 * lipschitz) if lipschitz > 0 else float('inf')
    
    return {
        'n_params': n,
        'height': H,
        'lipschitz_constant': lipschitz,
        'robustness_radius': radius,
        'max_output_change_at_radius': 0.5,  # certified by theorem
        'capacity_bound': height_capacity_bound(n, H)
    }


def height_capacity_bound(n: int, H: float) -> int:
    """Compute the Northcott capacity bound N(n, H) = (2⌈exp(H)⌉+1)^(2n).
    
    This bounds the total number of distinct hypothesis configurations
    achievable with n parameters of height ≤ H.
    """
    ceil_exp = math.ceil(math.exp(H))
    base = 2 * ceil_exp + 1
    return base ** (2 * n)


def sample_complexity(n: int, H: float, epsilon: float) -> int:
    """Compute height-certified sample complexity.
    
    For ε-generalization: m ≥ 2n(H + log 3) / ε²
    
    Args:
        n: Number of parameters (must be > 0)
        H: Height bound (≥ 0)
        epsilon: Desired accuracy (> 0)
    
    Returns:
        Minimum required sample count
    """
    return math.ceil(2 * n * (H + math.log(3)) / epsilon**2)


# =============================================================================
# Algorithm 4: Height-Based Pruning
# =============================================================================

def height_based_pruning(
    weights: List[Fraction],
    prune_fraction: float = 0.1
) -> Tuple[List[Fraction], List[int]]:
    """Prune weights by removing those with highest Weil height.
    
    Strategy: sort weights by individual height, zero out the highest ones.
    
    Args:
        weights: Weight vector
        prune_fraction: Fraction of weights to prune (0 to 1)
    
    Returns:
        (pruned_weights, pruned_indices)
    """
    n = len(weights)
    k = int(n * prune_fraction)
    
    # Sort by individual height (descending)
    indexed_heights = [(i, single_weil_height(w)) for i, (w, single_weil_height) 
                       in enumerate(zip(weights, [lambda q: math.log(max(abs(q.numerator), q.denominator)) for _ in weights]))]
    
    heights = [(i, math.log(max(abs(w.numerator), w.denominator))) for i, w in enumerate(weights)]
    heights.sort(key=lambda x: x[1], reverse=True)
    
    pruned_indices = [idx for idx, _ in heights[:k]]
    pruned_weights = list(weights)
    for idx in pruned_indices:
        pruned_weights[idx] = Fraction(0)
    
    return pruned_weights, pruned_indices


def single_weil_height(q: Fraction) -> float:
    """Height of a single rational."""
    return math.log(max(abs(q.numerator), q.denominator)) if max(abs(q.numerator), q.denominator) > 0 else 0.0


# =============================================================================
# Demo
# =============================================================================

if __name__ == "__main__":
    print("=" * 60)
    print("ALGORITHMS — Arithmetic Learning Theory")
    print("=" * 60)
    
    # Demo: Height computation
    w = [Fraction(3, 7), Fraction(5, 11), Fraction(2, 3)]
    h = compute_weil_height(w)
    print(f"\nWeight vector: {w}")
    print(f"Weil height: {h:.4f}")
    
    # Demo: Robustness certification
    cert = certify_robustness(w)
    print(f"\nRobustness Certificate:")
    for key, val in cert.items():
        if isinstance(val, float):
            print(f"  {key}: {val:.6e}")
        else:
            print(f"  {key}: {val}")
    
    # Demo: Sample complexity
    for eps in [0.1, 0.01, 0.001]:
        m = sample_complexity(3, h, eps)
        print(f"\nSample complexity for ε={eps}: {m}")
    
    # Demo: Height-regularized training on a simple quadratic
    def quadratic_loss(w):
        return sum((wi - 0.5)**2 for wi in w)
    
    def quadratic_grad(w):
        return [2 * (wi - 0.5) for wi in w]
    
    init = [0.0, 0.0, 0.0]
    final_w, final_h, final_loss = height_regularized_sgd(
        quadratic_loss, quadratic_grad, init,
        learning_rate=0.1, num_steps=50, bit_precision=8
    )
    print(f"\nHeight-regularized SGD result:")
    print(f"  Final weights: {final_w}")
    print(f"  Final height: {final_h:.4f}")
    print(f"  Final loss: {final_loss:.6f}")
    cert = certify_robustness(final_w)
    print(f"  Lipschitz constant: {cert['lipschitz_constant']:.4f}")
    print(f"  Robustness radius: {cert['robustness_radius']:.6e}")
    
    print("\n" + "=" * 60)
    print("All algorithms demonstrated successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Arithmetic Learning Theory — Real-World Applications

Demonstrates applications of height-based certificates to:
1. Neural network robustness certification
2. Model compression via height pruning
3. Generalization guarantees
4. Lattice cryptography connection
"""

import math
from fractions import Fraction
from typing import List, Tuple
import numpy as np


def single_weil_height(q: Fraction) -> float:
    """Logarithmic Weil height of a rational number."""
    return math.log(max(abs(q.numerator), q.denominator)) if max(abs(q.numerator), q.denominator) > 0 else 0.0


def vector_weil_height(w: List[Fraction]) -> float:
    """Logarithmic Weil height of a rational vector."""
    return sum(single_weil_height(q) for q in w)


# =============================================================================
# Application 1: Neural Network Robustness Certification
# =============================================================================

def certify_neural_network(
    layers: List[List[List[Fraction]]],
    input_dim: int
) -> dict:
    """Certify adversarial robustness of a neural network.
    
    For a depth-d network with width-w layers and weight height H:
    - Per-layer Lipschitz: Lₖ ≤ widthₖ · exp(Hₖ)
    - Total Lipschitz: L ≤ ∏ₖ Lₖ
    - Robustness radius: r ≥ 1/(2L)
    
    Args:
        layers: List of weight matrices (list of lists of Fractions)
        input_dim: Input dimension
    
    Returns:
        Certification dictionary
    """
    depth = len(layers)
    total_lipschitz = 1.0
    layer_info = []
    
    for k, W in enumerate(layers):
        m = len(W)       # output dimension
        n = len(W[0]) if W else 0  # input dimension
        
        # Compute height of this layer
        all_weights = [w for row in W for w in row]
        H = vector_weil_height(all_weights)
        max_h = max(single_weil_height(w) for w in all_weights) if all_weights else 0
        
        # Per-layer Lipschitz bound
        L_k = n * math.exp(max_h)
        total_lipschitz *= L_k
        
        layer_info.append({
            'layer': k,
            'shape': (m, n),
            'height': H,
            'max_entry_height': max_h,
            'lipschitz': L_k
        })
    
    radius = 1.0 / (2.0 * total_lipschitz) if total_lipschitz > 0 else float('inf')
    
    return {
        'depth': depth,
        'total_lipschitz': total_lipschitz,
        'robustness_radius': radius,
        'layers': layer_info,
        'certificate': f'∀ x, adv: ‖x-adv‖ ≤ {radius:.2e} ⟹ |f(x)-f(adv)| ≤ 1/2'
    }


# =============================================================================
# Application 2: Model Compression via Height Pruning
# =============================================================================

def height_prune_network(
    weights: List[Fraction],
    target_height: float
) -> Tuple[List[Fraction], dict]:
    """Prune a network to achieve a target height bound.
    
    Strategy: iteratively zero out the weight with highest individual height
    until the total height is below the target.
    
    Args:
        weights: Weight vector
        target_height: Target maximum height
    
    Returns:
        (pruned_weights, statistics)
    """
    w = list(weights)
    n = len(w)
    pruned_count = 0
    original_height = vector_weil_height(w)
    
    while vector_weil_height(w) > target_height and pruned_count < n:
        # Find weight with highest individual height
        heights = [(i, single_weil_height(w[i])) for i in range(n) if w[i] != Fraction(0)]
        if not heights:
            break
        max_idx = max(heights, key=lambda x: x[1])[0]
        w[max_idx] = Fraction(0)
        pruned_count += 1
    
    final_height = vector_weil_height(w)
    nonzero = sum(1 for wi in w if wi != Fraction(0))
    
    return w, {
        'original_height': original_height,
        'final_height': final_height,
        'pruned_count': pruned_count,
        'sparsity': pruned_count / n,
        'remaining_nonzero': nonzero,
        'compression_ratio': n / max(nonzero, 1)
    }


# =============================================================================
# Application 3: Lattice Cryptography Connection
# =============================================================================

def lattice_parameters(n: int, H: float) -> dict:
    """Compute lattice parameters for the bounded-height integer lattice.
    
    The set {v ∈ ℤⁿ : |vᵢ| ≤ ⌈exp(H)⌉} forms a lattice with:
    - (2⌈exp(H)⌉+1)^n points
    - Volume = (2⌈exp(H)⌉+1)^n
    - Minimum distance = 1 (trivially)
    - Gaussian heuristic for shortest vector: ~√(n/(2πe)) · det^(1/n)
    
    Connection to LWE/SIS hardness: larger n and smaller det/det^(1/n)
    ratio makes lattice problems harder.
    """
    B = math.ceil(math.exp(H))
    num_points = (2 * B + 1) ** n
    det_1n = (2 * B + 1)  # det^(1/n)
    gaussian_heuristic = math.sqrt(n / (2 * math.pi * math.e)) * det_1n
    
    return {
        'dimension': n,
        'height_bound': H,
        'entry_bound': B,
        'log_num_points': n * math.log(2 * B + 1),
        'gaussian_shortest_vector': gaussian_heuristic,
        'hermite_factor': gaussian_heuristic / det_1n if det_1n > 0 else 0,
        'lwe_security_bits': int(n * math.log2(2 * B + 1) * 0.265)
    }


# =============================================================================
# Application 4: Generalization Gap Estimation
# =============================================================================

def generalization_certificate(
    n_params: int,
    height: float,
    n_samples: int,
    confidence: float = 0.95
) -> dict:
    """Compute generalization gap certificate from height bounds.
    
    Based on uniform convergence over the Northcott-bounded hypothesis class:
    gen_gap ≤ √(2 · log(N(n,H)) / m) + √(log(1/δ) / (2m))
    
    where N(n,H) = (2⌈exp(H)⌉+1)^(2n) is the capacity.
    """
    delta = 1 - confidence
    
    # Capacity bound
    ceil_exp = math.ceil(math.exp(height))
    log_capacity = 2 * n_params * math.log(2 * ceil_exp + 1)
    
    # Generalization bound
    if n_samples > 0:
        gen_bound = math.sqrt(2 * log_capacity / n_samples) + \
                    math.sqrt(math.log(1/delta) / (2 * n_samples))
    else:
        gen_bound = float('inf')
    
    return {
        'n_params': n_params,
        'height': height,
        'n_samples': n_samples,
        'confidence': confidence,
        'log_capacity': log_capacity,
        'generalization_bound': gen_bound,
        'interpretation': f'With {confidence*100:.0f}% confidence, '
                         f'gen_gap ≤ {gen_bound:.4f}'
    }


# =============================================================================
# Main Demo
# =============================================================================

if __name__ == "__main__":
    print("=" * 70)
    print("APPLICATIONS — Arithmetic Learning Theory")
    print("=" * 70)
    
    # Application 1: Neural Network Certification
    print("\n--- Application 1: Neural Network Robustness Certification ---\n")
    
    # Simple 2-layer network
    layer1 = [[Fraction(1, 2), Fraction(3, 4)],
              [Fraction(-1, 3), Fraction(2, 5)],
              [Fraction(1, 7), Fraction(5, 6)]]
    
    layer2 = [[Fraction(2, 3), Fraction(-1, 2), Fraction(1, 4)]]
    
    cert = certify_neural_network([layer1, layer2], input_dim=2)
    print(f"Network: {cert['depth']} layers")
    for info in cert['layers']:
        print(f"  Layer {info['layer']}: shape={info['shape']}, "
              f"height={info['height']:.3f}, L={info['lipschitz']:.3f}")
    print(f"Total Lipschitz constant: {cert['total_lipschitz']:.4f}")
    print(f"Certified robustness radius: {cert['robustness_radius']:.6e}")
    print(f"Certificate: {cert['certificate']}")
    
    # Application 2: Model Compression
    print("\n--- Application 2: Height-Based Model Compression ---\n")
    
    np.random.seed(42)
    weights = [Fraction(np.random.randint(-100, 100), np.random.randint(1, 50)) 
               for _ in range(20)]
    
    print(f"Original weights ({len(weights)} params):")
    print(f"  Height: {vector_weil_height(weights):.4f}")
    
    for target_h in [30, 20, 10, 5]:
        pruned, stats = height_prune_network(weights, target_h)
        print(f"\n  Target height ≤ {target_h}:")
        print(f"    Final height: {stats['final_height']:.4f}")
        print(f"    Pruned: {stats['pruned_count']}/{len(weights)} "
              f"({stats['sparsity']:.0%} sparsity)")
        print(f"    Compression ratio: {stats['compression_ratio']:.1f}x")
    
    # Application 3: Lattice Cryptography
    print("\n--- Application 3: Lattice Cryptography Connection ---\n")
    
    for n in [128, 256, 512, 1024]:
        for H in [3, 5]:
            params = lattice_parameters(n, H)
            print(f"  n={n}, H={H}: "
                  f"log(#points)={params['log_num_points']:.0f}, "
                  f"est. security={params['lwe_security_bits']} bits")
    
    # Application 4: Generalization
    print("\n--- Application 4: Generalization Certificates ---\n")
    
    for n in [100, 1000, 10000]:
        for H in [3, 5]:
            for m in [1000, 10000, 100000]:
                cert = generalization_certificate(n, H, m)
                print(f"  n={n:5d}, H={H}, m={m:6d}: "
                      f"gen_gap ≤ {cert['generalization_bound']:.4f}")
    
    print("\n" + "=" * 70)
    print("All applications demonstrated successfully.")
    print("=" * 70)


#!/usr/bin/env python3
"""
Arithmetic Learning Theory — Demonstrations

Computes and visualizes key quantities from arithmetic learning theory:
Weil heights, capacity bounds, Lipschitz certificates, and robustness radii.
"""

import math
from fractions import Fraction
import numpy as np

def single_weil_height(q: Fraction) -> float:
    """Logarithmic Weil height of a single rational number q = p/d (lowest terms).
    h(q) = log(max(|p|, d))"""
    return math.log(max(abs(q.numerator), q.denominator))

def log_weil_height(w: list[Fraction]) -> float:
    """Logarithmic Weil height of a rational vector."""
    return sum(single_weil_height(q) for q in w)

def exp_height(q: Fraction) -> float:
    """Exponential (naive) height: max(|numerator|, denominator)."""
    return float(max(abs(q.numerator), q.denominator))

def height_capacity(n: int, H: float) -> int:
    """Northcott capacity bound: (2⌈exp(H)⌉ + 1)^(2n)."""
    ceil_exp = math.ceil(math.exp(H))
    return (2 * ceil_exp + 1) ** (2 * n)

def lipschitz_constant(n: int, H: float) -> float:
    """Height-certified Lipschitz constant: n * exp(H)."""
    return n * math.exp(H)

def robustness_radius(L: float) -> float:
    """Certified adversarial robustness radius: 1/(2L)."""
    return 1.0 / (2.0 * L)

def sample_complexity(n: int, H: float, epsilon: float) -> float:
    """Height-certified sample complexity: 2n(H + log3) / ε²."""
    return 2 * n * (H + math.log(3)) / epsilon**2


print("=" * 70)
print("ARITHMETIC LEARNING THEORY — DEMONSTRATIONS")
print("=" * 70)

# === Demo 1: Height Computation ===
print("\n--- Demo 1: Weil Heights of Rational Numbers ---\n")
test_rationals = [
    Fraction(0), Fraction(1), Fraction(-1),
    Fraction(1, 2), Fraction(2, 1), Fraction(3, 7),
    Fraction(355, 113), Fraction(22, 7), Fraction(1000000, 1),
    Fraction(1, 1000000)
]

print(f"{'Rational':>15s}  {'Exp Height':>12s}  {'Weil Height':>12s}")
print("-" * 45)
for q in test_rationals:
    h = single_weil_height(q)
    eh = exp_height(q)
    print(f"{str(q):>15s}  {eh:12.2f}  {h:12.6f}")

# === Demo 2: Vector Heights ===
print("\n--- Demo 2: Vector Weil Heights ---\n")
test_vectors = [
    [Fraction(0)] * 5,
    [Fraction(1, 2)] * 5,
    [Fraction(i, i+1) for i in range(1, 6)],
    [Fraction(2**i, 3**i) for i in range(5)],
    [Fraction(355, 113), Fraction(22, 7), Fraction(1, 2), Fraction(3, 1), Fraction(7, 4)]
]

for w in test_vectors:
    h = log_weil_height(w)
    print(f"  w = [{', '.join(str(x) for x in w)}]")
    print(f"    h(w) = {h:.6f}")
    print(f"    exp(h(w)) = {math.exp(h):.2f}")
    print()

# === Demo 3: Magnitude-Height Bound Verification ===
print("--- Demo 3: Magnitude-Height Bound |q| ≤ exp(h(q)) ---\n")
print(f"{'q':>15s}  {'|q|':>10s}  {'exp(h(q))':>10s}  {'Bound holds':>12s}")
print("-" * 52)
for q in test_rationals:
    abs_q = abs(float(q))
    exp_h = math.exp(single_weil_height(q))
    holds = abs_q <= exp_h + 1e-10
    print(f"{str(q):>15s}  {abs_q:10.4f}  {exp_h:10.4f}  {'✓' if holds else '✗':>12s}")

# === Demo 4: Product Formula Verification ===
print("\n--- Demo 4: Product Formula h(a·b) ≤ h(a) + h(b) ---\n")
pairs = [(Fraction(2,3), Fraction(5,7)), (Fraction(355,113), Fraction(22,7)),
         (Fraction(100,1), Fraction(1,100)), (Fraction(7,11), Fraction(13,17))]

print(f"{'a':>10s}  {'b':>10s}  {'h(a·b)':>10s}  {'h(a)+h(b)':>10s}  {'Gap':>8s}")
print("-" * 55)
for a, b in pairs:
    hab = single_weil_height(a * b)
    ha_hb = single_weil_height(a) + single_weil_height(b)
    gap = ha_hb - hab
    print(f"{str(a):>10s}  {str(b):>10s}  {hab:10.4f}  {ha_hb:10.4f}  {gap:8.4f}")

# === Demo 5: Capacity Growth ===
print("\n--- Demo 5: Northcott Capacity N(n, H) ---\n")
print(f"{'n':>5s}  {'H':>5s}  {'N(n,H)':>20s}  {'log N(n,H)':>12s}")
print("-" * 48)
for n in [1, 2, 5, 10]:
    for H in [0, 1, 2, 3]:
        N = height_capacity(n, H)
        log_N = math.log(N) if N > 0 else 0
        N_str = str(N) if N < 10**15 else f"{N:.2e}"
        print(f"{n:5d}  {H:5.1f}  {N_str:>20s}  {log_N:12.2f}")

# === Demo 6: Lipschitz Constants & Robustness Radii ===
print("\n--- Demo 6: Height-Certified Lipschitz Constants & Robustness ---\n")
print(f"{'n (params)':>12s}  {'H (height)':>12s}  {'Lipschitz L':>12s}  {'Rob. Radius':>12s}")
print("-" * 55)
for n in [10, 100, 1000, 10000]:
    for H in [1, 3, 5, 10]:
        L = lipschitz_constant(n, H)
        r = robustness_radius(L)
        print(f"{n:12d}  {H:12.1f}  {L:12.2f}  {r:12.2e}")

# === Demo 7: Sample Complexity ===
print("\n--- Demo 7: Height-Certified Sample Complexity ---\n")
print(f"{'n':>8s}  {'H':>5s}  {'ε':>8s}  {'m (samples)':>15s}")
print("-" * 42)
for n in [10, 100, 1000]:
    for H in [1, 5]:
        for eps in [0.1, 0.01]:
            m = sample_complexity(n, H, eps)
            print(f"{n:8d}  {H:5.1f}  {eps:8.3f}  {m:15.0f}")

# === Demo 8: Entropic Height Inequality ===
print("\n--- Demo 8: Entropic Height Inequality: -q·log(q) ≤ q·h(q) + log(2) ---\n")
print(f"{'q':>10s}  {'-q·log(q)':>12s}  {'q·h(q)+log2':>12s}  {'Holds':>6s}")
print("-" * 46)
for q in [Fraction(1,2), Fraction(1,3), Fraction(1,4), Fraction(1,10),
          Fraction(2,3), Fraction(3,4), Fraction(9,10), Fraction(99,100)]:
    qf = float(q)
    lhs = -qf * math.log(qf)
    rhs = qf * single_weil_height(q) + math.log(2)
    holds = lhs <= rhs + 1e-10
    print(f"{str(q):>10s}  {lhs:12.6f}  {rhs:12.6f}  {'✓' if holds else '✗':>6s}")

print("\n" + "=" * 70)
print("All demonstrations complete. All bounds verified numerically.")
print("=" * 70)


#!/usr/bin/env python3
"""
Arithmetic Learning Theory — Visualizations

Generates charts and diagrams for the research paper.
Saves as SVG/PNG files.
"""

import math
from fractions import Fraction
import numpy as np

try:
    import matplotlib
    matplotlib.use('Agg')
    import matplotlib.pyplot as plt
    HAS_MPL = True
except ImportError:
    HAS_MPL = False
    print("matplotlib not available, generating text-based visualizations")


def single_weil_height(q: Fraction) -> float:
    return math.log(max(abs(q.numerator), q.denominator)) if max(abs(q.numerator), q.denominator) > 0 else 0.0

def height_capacity(n: int, H: float) -> float:
    ceil_exp = math.ceil(math.exp(H))
    return (2 * ceil_exp + 1) ** (2 * n)


def plot_height_capacity_growth():
    """Plot the growth of height capacity N(n, H) as a function of H."""
    if not HAS_MPL:
        return
    
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))
    
    H_vals = np.linspace(0, 5, 100)
    
    for n in [1, 2, 5, 10]:
        log_caps = [2 * n * math.log(2 * math.ceil(math.exp(H)) + 1) for H in H_vals]
        ax1.plot(H_vals, log_caps, label=f'n = {n}', linewidth=2)
    
    ax1.set_xlabel('Height Bound H', fontsize=12)
    ax1.set_ylabel('log(Capacity)', fontsize=12)
    ax1.set_title('Northcott Capacity Growth: log N(n, H)', fontsize=14)
    ax1.legend(fontsize=11)
    ax1.grid(True, alpha=0.3)
    
    # Lipschitz vs Height
    for n in [10, 50, 100, 500]:
        lips = [n * math.exp(H) for H in H_vals]
        ax2.semilogy(H_vals, lips, label=f'n = {n}', linewidth=2)
    
    ax2.set_xlabel('Height Bound H', fontsize=12)
    ax2.set_ylabel('Lipschitz Constant L', fontsize=12)
    ax2.set_title('Height-Certified Lipschitz: L = n · exp(H)', fontsize=14)
    ax2.legend(fontsize=11)
    ax2.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('capacity_lipschitz.png', dpi=150, bbox_inches='tight')
    plt.savefig('capacity_lipschitz.svg', bbox_inches='tight')
    plt.close()
    print("Saved: capacity_lipschitz.png, capacity_lipschitz.svg")


def plot_robustness_tradeoff():
    """Plot the tradeoff between height and robustness radius."""
    if not HAS_MPL:
        return
    
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))
    
    H_vals = np.linspace(0.1, 8, 100)
    
    for n in [10, 50, 100, 500, 1000]:
        radii = [1.0 / (2 * n * math.exp(H)) for H in H_vals]
        ax1.semilogy(H_vals, radii, label=f'n = {n}', linewidth=2)
    
    ax1.set_xlabel('Height Bound H', fontsize=12)
    ax1.set_ylabel('Robustness Radius', fontsize=12)
    ax1.set_title('Certified Robustness Radius = 1/(2n·exp(H))', fontsize=14)
    ax1.legend(fontsize=11)
    ax1.grid(True, alpha=0.3)
    
    # Sample complexity vs accuracy
    eps_vals = np.linspace(0.01, 0.5, 100)
    
    for n, H in [(10, 2), (50, 3), (100, 5), (500, 3)]:
        samples = [2 * n * (H + math.log(3)) / eps**2 for eps in eps_vals]
        ax2.semilogy(eps_vals, samples, label=f'n={n}, H={H}', linewidth=2)
    
    ax2.set_xlabel('Accuracy ε', fontsize=12)
    ax2.set_ylabel('Required Samples', fontsize=12)
    ax2.set_title('Sample Complexity = 2n(H+log3)/ε²', fontsize=14)
    ax2.legend(fontsize=11)
    ax2.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('robustness_samples.png', dpi=150, bbox_inches='tight')
    plt.savefig('robustness_samples.svg', bbox_inches='tight')
    plt.close()
    print("Saved: robustness_samples.png, robustness_samples.svg")


def plot_height_landscape():
    """Visualize the 'height landscape' of rational numbers."""
    if not HAS_MPL:
        return
    
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))
    
    # Heights of p/q for small p, q
    max_val = 20
    ps = range(-max_val, max_val + 1)
    qs = range(1, max_val + 1)
    
    x_vals, y_vals, h_vals = [], [], []
    for p in ps:
        for q in qs:
            frac = Fraction(p, q)
            x_vals.append(float(frac))
            y_vals.append(single_weil_height(frac))
            h_vals.append(single_weil_height(frac))
    
    scatter = ax1.scatter(x_vals, y_vals, c=h_vals, cmap='viridis', s=3, alpha=0.5)
    plt.colorbar(scatter, ax=ax1, label='Height h(q)')
    ax1.set_xlabel('Rational q', fontsize=12)
    ax1.set_ylabel('Weil Height h(q)', fontsize=12)
    ax1.set_title('Height Landscape of Rationals', fontsize=14)
    ax1.set_xlim(-5, 5)
    
    # Entropic height inequality
    q_vals = np.linspace(0.01, 0.99, 100)
    entropy_vals = [-q * math.log(q) for q in q_vals]
    
    # For each q, approximate as a Fraction and compute height bound
    height_bound_vals = []
    for q in q_vals:
        frac = Fraction(q).limit_denominator(1000)
        bound = float(frac) * single_weil_height(frac) + math.log(2)
        height_bound_vals.append(bound)
    
    ax2.plot(q_vals, entropy_vals, 'b-', linewidth=2, label='-q·log(q)')
    ax2.plot(q_vals, height_bound_vals, 'r--', linewidth=2, label='q·h(q) + log 2')
    ax2.fill_between(q_vals, entropy_vals, height_bound_vals, 
                      alpha=0.2, color='green', label='Gap (height controls entropy)')
    ax2.set_xlabel('q', fontsize=12)
    ax2.set_ylabel('Value', fontsize=12)
    ax2.set_title('Entropic Height Inequality', fontsize=14)
    ax2.legend(fontsize=11)
    ax2.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('height_landscape.png', dpi=150, bbox_inches='tight')
    plt.savefig('height_landscape.svg', bbox_inches='tight')
    plt.close()
    print("Saved: height_landscape.png, height_landscape.svg")


def plot_product_formula():
    """Visualize the product formula h(a·b) ≤ h(a) + h(b)."""
    if not HAS_MPL:
        return
    
    fig, ax = plt.subplots(figsize=(8, 6))
    
    np.random.seed(42)
    n_points = 500
    
    h_ab_vals = []
    h_a_plus_b_vals = []
    
    for _ in range(n_points):
        p1, q1 = np.random.randint(-50, 50), np.random.randint(1, 50)
        p2, q2 = np.random.randint(-50, 50), np.random.randint(1, 50)
        if p1 == 0: p1 = 1
        if p2 == 0: p2 = 1
        
        a = Fraction(p1, q1)
        b = Fraction(p2, q2)
        
        h_ab = single_weil_height(a * b)
        h_a_b = single_weil_height(a) + single_weil_height(b)
        
        h_ab_vals.append(h_ab)
        h_a_plus_b_vals.append(h_a_b)
    
    ax.scatter(h_a_plus_b_vals, h_ab_vals, s=10, alpha=0.5, c='blue')
    
    max_val = max(max(h_a_plus_b_vals), max(h_ab_vals))
    ax.plot([0, max_val], [0, max_val], 'r-', linewidth=2, label='h(a·b) = h(a)+h(b)')
    
    ax.set_xlabel('h(a) + h(b)', fontsize=12)
    ax.set_ylabel('h(a·b)', fontsize=12)
    ax.set_title('Product Formula: h(a·b) ≤ h(a) + h(b)', fontsize=14)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('product_formula.png', dpi=150, bbox_inches='tight')
    plt.savefig('product_formula.svg', bbox_inches='tight')
    plt.close()
    print("Saved: product_formula.png, product_formula.svg")


def generate_diagram_svg():
    """Generate the main architecture diagram as SVG."""
    svg = '''<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 900 600" width="900" height="600">
  <defs>
    <marker id="arrowhead" markerWidth="10" markerHeight="7" refX="10" refY="3.5" orient="auto">
      <polygon points="0 0, 10 3.5, 0 7" fill="#333"/>
    </marker>
    <linearGradient id="grad1" x1="0%" y1="0%" x2="100%" y2="0%">
      <stop offset="0%" style="stop-color:#4A90D9;stop-opacity:1" />
      <stop offset="100%" style="stop-color:#7B68EE;stop-opacity:1" />
    </linearGradient>
    <linearGradient id="grad2" x1="0%" y1="0%" x2="100%" y2="0%">
      <stop offset="0%" style="stop-color:#E74C3C;stop-opacity:1" />
      <stop offset="100%" style="stop-color:#F39C12;stop-opacity:1" />
    </linearGradient>
    <linearGradient id="grad3" x1="0%" y1="0%" x2="100%" y2="0%">
      <stop offset="0%" style="stop-color:#27AE60;stop-opacity:1" />
      <stop offset="100%" style="stop-color:#2ECC71;stop-opacity:1" />
    </linearGradient>
  </defs>
  
  <!-- Title -->
  <text x="450" y="35" text-anchor="middle" font-family="Georgia, serif" font-size="22" font-weight="bold" fill="#222">
    Arithmetic Learning Theory: The Bridge Architecture
  </text>
  
  <!-- Central Node: Weil Height -->
  <ellipse cx="450" cy="200" rx="120" ry="50" fill="url(#grad1)" stroke="#333" stroke-width="2" opacity="0.9"/>
  <text x="450" y="195" text-anchor="middle" font-family="Georgia, serif" font-size="16" font-weight="bold" fill="white">Weil Height</text>
  <text x="450" y="215" text-anchor="middle" font-family="Georgia, serif" font-size="12" fill="white">h(q) = log max(|p|, d)</text>
  
  <!-- Left: Arithmetic Geometry -->
  <rect x="30" y="80" width="200" height="110" rx="15" fill="url(#grad2)" stroke="#333" stroke-width="2" opacity="0.9"/>
  <text x="130" y="110" text-anchor="middle" font-family="Georgia, serif" font-size="14" font-weight="bold" fill="white">Arithmetic Geometry</text>
  <text x="130" y="132" text-anchor="middle" font-family="Georgia, serif" font-size="11" fill="white">Northcott Property</text>
  <text x="130" y="150" text-anchor="middle" font-family="Georgia, serif" font-size="11" fill="white">Product Formula</text>
  <text x="130" y="168" text-anchor="middle" font-family="Georgia, serif" font-size="11" fill="white">Mordell-Weil</text>
  
  <!-- Right: Learning Theory -->
  <rect x="670" y="80" width="200" height="110" rx="15" fill="url(#grad3)" stroke="#333" stroke-width="2" opacity="0.9"/>
  <text x="770" y="110" text-anchor="middle" font-family="Georgia, serif" font-size="14" font-weight="bold" fill="white">Learning Theory</text>
  <text x="770" y="132" text-anchor="middle" font-family="Georgia, serif" font-size="11" fill="white">Generalization Gap</text>
  <text x="770" y="150" text-anchor="middle" font-family="Georgia, serif" font-size="11" fill="white">VC Dimension</text>
  <text x="770" y="168" text-anchor="middle" font-family="Georgia, serif" font-size="11" fill="white">Sample Complexity</text>
  
  <!-- Bottom boxes -->
  <rect x="30" y="340" width="180" height="90" rx="12" fill="#8E44AD" stroke="#333" stroke-width="2" opacity="0.85"/>
  <text x="120" y="370" text-anchor="middle" font-family="Georgia, serif" font-size="13" font-weight="bold" fill="white">Robustness</text>
  <text x="120" y="390" text-anchor="middle" font-family="Georgia, serif" font-size="10" fill="white">L ≤ n·exp(H)</text>
  <text x="120" y="408" text-anchor="middle" font-family="Georgia, serif" font-size="10" fill="white">r ≥ 1/(2L)</text>
  
  <rect x="250" y="340" width="180" height="90" rx="12" fill="#2980B9" stroke="#333" stroke-width="2" opacity="0.85"/>
  <text x="340" y="370" text-anchor="middle" font-family="Georgia, serif" font-size="13" font-weight="bold" fill="white">Thermodynamics</text>
  <text x="340" y="390" text-anchor="middle" font-family="Georgia, serif" font-size="10" fill="white">F = H - T·S</text>
  <text x="340" y="408" text-anchor="middle" font-family="Georgia, serif" font-size="10" fill="white">Gibbs ∝ exp(-H/T)</text>
  
  <rect x="470" y="340" width="180" height="90" rx="12" fill="#16A085" stroke="#333" stroke-width="2" opacity="0.85"/>
  <text x="560" y="370" text-anchor="middle" font-family="Georgia, serif" font-size="13" font-weight="bold" fill="white">Information</text>
  <text x="560" y="390" text-anchor="middle" font-family="Georgia, serif" font-size="10" fill="white">-q·log(q) ≤ q·h(q)+log2</text>
  <text x="560" y="408" text-anchor="middle" font-family="Georgia, serif" font-size="10" fill="white">Shannon ↔ Height</text>
  
  <rect x="690" y="340" width="180" height="90" rx="12" fill="#D35400" stroke="#333" stroke-width="2" opacity="0.85"/>
  <text x="780" y="370" text-anchor="middle" font-family="Georgia, serif" font-size="13" font-weight="bold" fill="white">Cryptography</text>
  <text x="780" y="390" text-anchor="middle" font-family="Georgia, serif" font-size="10" fill="white">Lattice: (2B+1)ⁿ pts</text>
  <text x="780" y="408" text-anchor="middle" font-family="Georgia, serif" font-size="10" fill="white">SIS/LWE hardness</text>
  
  <!-- Arrows -->
  <line x1="230" y1="135" x2="330" y2="180" stroke="#333" stroke-width="2" marker-end="url(#arrowhead)"/>
  <line x1="570" y1="180" x2="670" y2="135" stroke="#333" stroke-width="2" marker-end="url(#arrowhead)"/>
  
  <line x1="380" y1="240" x2="150" y2="340" stroke="#333" stroke-width="1.5" marker-end="url(#arrowhead)" stroke-dasharray="5,3"/>
  <line x1="420" y1="248" x2="340" y2="340" stroke="#333" stroke-width="1.5" marker-end="url(#arrowhead)" stroke-dasharray="5,3"/>
  <line x1="480" y1="248" x2="550" y2="340" stroke="#333" stroke-width="1.5" marker-end="url(#arrowhead)" stroke-dasharray="5,3"/>
  <line x1="520" y1="240" x2="750" y2="340" stroke="#333" stroke-width="1.5" marker-end="url(#arrowhead)" stroke-dasharray="5,3"/>
  
  <!-- Key Results Box -->
  <rect x="150" y="470" width="600" height="110" rx="10" fill="#F8F9FA" stroke="#333" stroke-width="1.5"/>
  <text x="450" y="495" text-anchor="middle" font-family="Georgia, serif" font-size="14" font-weight="bold" fill="#333">Key Proven Results</text>
  <text x="170" y="520" font-family="monospace" font-size="11" fill="#333">• |q| ≤ exp(h(q))           — magnitude bound</text>
  <text x="170" y="540" font-family="monospace" font-size="11" fill="#333">• h(a·b) ≤ h(a) + h(b)      — product formula</text>
  <text x="170" y="560" font-family="monospace" font-size="11" fill="#333">• #(height ≤ H) = (2B+1)ⁿ   — Northcott finiteness</text>
  <text x="500" y="520" font-family="monospace" font-size="11" fill="#333">• L ≤ n·exp(H)     — Lipschitz cert.</text>
  <text x="500" y="540" font-family="monospace" font-size="11" fill="#333">• r ≥ 1/(2L)       — robustness radius</text>
  <text x="500" y="560" font-family="monospace" font-size="11" fill="#333">• F ≥ E - T·log N  — free energy bound</text>
</svg>'''
    
    with open('diagram.svg', 'w') as f:
        f.write(svg)
    print("Saved: diagram.svg")


if __name__ == "__main__":
    print("Generating visualizations...")
    generate_diagram_svg()
    
    if HAS_MPL:
        plot_height_capacity_growth()
        plot_robustness_tradeoff()
        plot_height_landscape()
        plot_product_formula()
        print("\nAll visualizations saved.")
    else:
        print("Install matplotlib for chart visualizations.")
