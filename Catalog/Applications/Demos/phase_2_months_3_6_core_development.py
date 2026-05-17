#!/usr/bin/env python3
"""
Applications of Tropical Kinetic Certification

Real-world applications demonstrating the practical impact of the theorems:
1. Certified robustness of ReLU neural network classifiers
2. Streaming data temporal stability guarantees
3. Max-pooling information loss quantification
4. Polyhedral decision boundary verification
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from typing import List, Tuple


# ============================================================================
# Application 1: Certified Robustness for Tropicalized Neural Networks
# ============================================================================

def tropicalized_relu_network(
    W1: np.ndarray, b1: np.ndarray,
    W2: np.ndarray, b2: np.ndarray,
    x: np.ndarray
) -> np.ndarray:
    """
    Simulate a 2-layer ReLU network in tropical form.

    In the tropical limit, ReLU(Wx + b) becomes max-plus:
    output_j = max_i(W_{j,i} + x_i) + b_j (approximately, for dominant terms).
    """
    # Layer 1: tropical max-plus
    h = np.array([b1[j] + np.max(W1[j] + x) for j in range(len(b1))])
    h = np.maximum(h, 0)  # ReLU

    # Layer 2: standard linear (classification head)
    return W2 @ h + b2


def certify_neural_classifier(
    W1: np.ndarray, b1: np.ndarray,
    W2: np.ndarray, b2: np.ndarray,
    x0: np.ndarray, v: np.ndarray,
    num_classes: int
) -> dict:
    """
    Certify temporal robustness of a neural classifier.

    Uses tropical margin analysis to guarantee that the classifier's
    decision is stable under the trajectory x(t) = x0 + t*v.
    """
    # Compute class scores at t=0
    scores = tropicalized_relu_network(W1, b1, W2, b2, x0)
    winner = int(np.argmax(scores))

    # Compute margins to each other class
    margins = scores[winner] - scores
    margins[winner] = float('inf')
    min_margin = np.min(margins)

    # Lipschitz bound
    L = np.max(np.abs(v))
    eps = min_margin / (2 * L + 1) if min_margin > 0 else 0.0

    return {
        'scores': scores,
        'winner': winner,
        'min_margin': min_margin,
        'lipschitz': L,
        'stability_radius': eps,
        'is_robust': min_margin > 0
    }


def demo_neural_robustness():
    """Demonstrate certified robustness for a tropical neural network."""
    print("=" * 70)
    print("APPLICATION 1: Neural Network Temporal Robustness")
    print("=" * 70)

    np.random.seed(42)

    # Create a simple 3-class classifier
    n_input = 5
    n_hidden = 4
    n_classes = 3

    W1 = np.random.randn(n_hidden, n_input) * 0.5
    b1 = np.random.randn(n_hidden) * 0.1
    W2 = np.random.randn(n_classes, n_hidden) * 0.5
    b2 = np.zeros(n_classes)

    # Test multiple input points
    n_points = 100
    stability_radii = []

    for _ in range(n_points):
        x0 = np.random.randn(n_input)
        v = np.random.randn(n_input) * 0.5

        result = certify_neural_classifier(W1, b1, W2, b2, x0, v, n_classes)
        if result['is_robust']:
            stability_radii.append(result['stability_radius'])

    print(f"\nTested {n_points} random inputs with random velocities")
    print(f"Certifiable: {len(stability_radii)} / {n_points}")
    print(f"Mean stability radius: {np.mean(stability_radii):.4f}")
    print(f"Min stability radius: {np.min(stability_radii):.4f}")
    print(f"Max stability radius: {np.max(stability_radii):.4f}")

    # Detailed example
    x0 = np.array([1.0, -0.5, 0.3, 0.8, -0.2])
    v = np.array([0.1, -0.1, 0.05, -0.05, 0.02])
    result = certify_neural_classifier(W1, b1, W2, b2, x0, v, n_classes)

    print(f"\nDetailed example:")
    print(f"  Input: x0 = {x0}")
    print(f"  Velocity: v = {v}")
    print(f"  Scores: {result['scores']}")
    print(f"  Winner: class {result['winner']}")
    print(f"  Margin: {result['min_margin']:.4f}")
    print(f"  Certified stability: |t| < {result['stability_radius']:.4f}")


# ============================================================================
# Application 2: Streaming Data Stability
# ============================================================================

def demo_streaming_stability():
    """
    Demonstrate temporal stability guarantees for streaming classification.

    Models a sensor reading that drifts over time and certifies
    how long a classification decision remains valid.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 2: Streaming Data Temporal Stability")
    print("=" * 70)

    # Scenario: 3 sensors monitoring system health
    # Classification: Normal / Warning / Critical
    n_sensors = 3
    n_classes = 3

    # Tropical weight vectors (learned from training data)
    weights = [
        np.array([2.0, 1.0, 0.5]),   # Normal
        np.array([0.5, 2.0, 1.5]),    # Warning
        np.array([-0.5, 0.5, 3.0]),   # Critical
    ]
    biases = [1.0, 0.0, -1.0]

    # Current sensor readings
    sensor_reading = np.array([3.0, 2.0, 1.0])

    # Expected drift rate (from sensor noise model)
    drift_rate = np.array([0.1, 0.15, 0.05])

    # Compute scores
    scores = [biases[c] + np.max(weights[c] + sensor_reading) for c in range(n_classes)]
    winner = int(np.argmax(scores))
    class_names = ['Normal', 'Warning', 'Critical']

    print(f"\nSensor readings: {sensor_reading}")
    print(f"Drift rate: {drift_rate}")
    print(f"\nClass scores:")
    for c in range(n_classes):
        print(f"  {class_names[c]}: {scores[c]:.3f}")
    print(f"Classification: {class_names[winner]}")

    # Compute certified stability
    L = np.max(np.abs(drift_rate))
    min_margin = float('inf')
    for c in range(n_classes):
        if c != winner:
            margin = scores[winner] - scores[c]
            min_margin = min(min_margin, margin)

    eps = min_margin / (2 * L + 1)
    print(f"\nMinimum margin: {min_margin:.3f}")
    print(f"Lipschitz constant: {L:.3f}")
    print(f"Certified valid for: |t| < {eps:.3f} time units")
    print(f"  → No re-classification needed for {eps:.1f} time units")

    # Plot score evolution
    t_range = np.linspace(-2*eps, 5*eps, 500)
    fig, ax = plt.subplots(figsize=(10, 6))

    for c in range(n_classes):
        scores_t = [biases[c] + np.max(weights[c] + sensor_reading + t * drift_rate)
                    for t in t_range]
        ax.plot(t_range, scores_t, linewidth=2, label=class_names[c])

    ax.axvspan(-eps, eps, alpha=0.15, color='green', label=f'Certified window (|t| < {eps:.2f})')
    ax.axvline(x=0, color='black', linestyle=':', alpha=0.5)
    ax.set_xlabel('Time', fontsize=12)
    ax.set_ylabel('Class Score', fontsize=12)
    ax.set_title('Streaming Classification: Certified Temporal Stability', fontsize=14)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('streaming_stability.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Plot saved to streaming_stability.png")


# ============================================================================
# Application 3: Max-Pooling Information Loss
# ============================================================================

def demo_max_pooling_info():
    """
    Quantify information loss through max-pooling layers.

    Uses tropical spread as an information measure to show that
    max-pooling provably reduces distinguishability.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 3: Max-Pooling Information Loss Quantification")
    print("=" * 70)

    # Simulate feature map (8 channels)
    np.random.seed(123)
    feature_map = np.array([5.2, 2.1, 8.7, 1.3, 6.5, 3.8, 7.2, 4.1])
    print(f"\nFeature map: {feature_map}")
    print(f"Spread: {np.max(feature_map) - np.min(feature_map):.3f}")

    # Apply max-pooling with different pool sizes
    pool_sizes = [2, 4, 8]
    results = []

    for ps in pool_sizes:
        n_pools = len(feature_map) // ps
        pooled = np.array([np.max(feature_map[i*ps:(i+1)*ps]) for i in range(n_pools)])
        spread = np.max(pooled) - np.min(pooled)
        results.append((ps, pooled, spread))
        print(f"\nPool size {ps}: {pooled}")
        print(f"  Spread: {spread:.3f}")
        print(f"  Reduction: {(1 - spread / (np.max(feature_map) - np.min(feature_map)))*100:.1f}%")

    # Iterated pooling
    print("\n--- Iterated Max-Pooling ---")
    current = np.random.randn(16) * 3 + 5
    print(f"Layer 0 ({len(current)} features): spread = {np.max(current)-np.min(current):.3f}")

    spreads = [np.max(current) - np.min(current)]
    sizes = [len(current)]

    while len(current) > 1:
        n = len(current)
        current = np.array([np.max(current[i:i+2]) for i in range(0, n, 2)])
        spread = np.max(current) - np.min(current)
        spreads.append(spread)
        sizes.append(len(current))
        print(f"Layer {len(spreads)-1} ({len(current)} features): spread = {spread:.3f}")

    print(f"\nSpread monotonically decreasing: {all(s1 >= s2 - 1e-10 for s1, s2 in zip(spreads, spreads[1:]))}")

    # Plot
    fig, ax = plt.subplots(figsize=(8, 5))
    ax.plot(range(len(spreads)), spreads, 'bo-', linewidth=2, markersize=8)
    ax.set_xlabel('Pooling Layer', fontsize=12)
    ax.set_ylabel('Tropical Spread', fontsize=12)
    ax.set_title('Information Loss Through Iterated Max-Pooling', fontsize=14)
    ax.set_xticks(range(len(spreads)))
    ax.set_xticklabels([f'Layer {i}\n({s} feat.)' for i, s in enumerate(sizes)], fontsize=9)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('max_pooling_info.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Plot saved to max_pooling_info.png")


# ============================================================================
# Application 4: Polyhedral Decision Boundary Verification
# ============================================================================

def demo_decision_boundary():
    """
    Verify safety of a polyhedral decision region for autonomous systems.

    Models a self-driving scenario where the vehicle must stay within
    a safe operating polyhedron.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 4: Decision Boundary Verification")
    print("=" * 70)

    # Safe operating region for a 2D vehicle:
    # Speed and steering angle constraints
    # speed ∈ [0, 30], steering ∈ [-45°, 45°]
    # Plus stability constraint: speed + |steering| <= 50
    A = np.array([
        [1, 0],     # speed <= 30
        [-1, 0],    # -speed <= 0
        [0, 1],     # steering <= 45
        [0, -1],    # -steering <= 45
        [1, 1],     # speed + steering <= 50
        [1, -1],    # speed - steering <= 50
    ])
    b = np.array([30, 0, 45, 45, 50, 50])

    # Current state
    state = np.array([15.0, 10.0])  # speed=15, steering=10

    # Expected state change rate
    velocity = np.array([2.0, -1.5])  # accelerating, straightening

    slacks = b - A @ state
    rn = np.sum(np.abs(A), axis=1)
    eps_per = slacks / (rn + 1)
    eps = np.min(eps_per[slacks > 0]) if np.any(slacks > 0) else 0

    v_bound = np.sum(np.abs(velocity)) + 1
    time_horizon = eps / v_bound

    print(f"\nCurrent state: speed={state[0]}, steering={state[1]}")
    print(f"Rate of change: Δspeed={velocity[0]}/s, Δsteering={velocity[1]}/s")
    print(f"\nConstraint slacks: {slacks}")
    print(f"Minimum slack: {np.min(slacks):.2f}")
    print(f"Spatial stability radius: {eps:.4f}")
    print(f"Certified safe for: {time_horizon:.4f} seconds")
    print(f"  → No safety re-check needed for {time_horizon:.2f} seconds")


# ============================================================================
# Main
# ============================================================================

if __name__ == '__main__':
    demo_neural_robustness()
    demo_streaming_stability()
    demo_max_pooling_info()
    demo_decision_boundary()

    print("\n" + "=" * 70)
    print("All applications completed successfully!")
    print("=" * 70)


#!/usr/bin/env python3
"""
Tropical Kinetic Certification: Concrete Numerical Demonstrations

Demonstrates the three main theorems:
1. Kinetic Tropical Margin Stability
2. Tropical Data Processing Inequality (Spread Monotonicity)
3. Polyhedral Membership Stability

Each demo uses concrete numerical examples to illustrate the theorems.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from typing import List, Tuple, Callable

# ============================================================================
# Core Definitions
# ============================================================================

def trop_affine_score(w: np.ndarray, x: np.ndarray, b: float) -> float:
    """Tropical affine score: b + max_i(w_i + x_i)."""
    return b + np.max(w + x)

def line_path(x0: np.ndarray, v: np.ndarray, t: float) -> np.ndarray:
    """Linear path: x(t) = x0 + t * v."""
    return x0 + t * v

def trop_spread(x: np.ndarray) -> float:
    """Tropical spread: max(x) - min(x)."""
    return np.max(x) - np.min(x)

def coarse_grain_max(x: np.ndarray, pi_map: Callable[[int], int], m: int) -> np.ndarray:
    """Coarse-grain by taking max over fibers of pi."""
    result = np.full(m, -np.inf)
    for i in range(len(x)):
        j = pi_map(i)
        result[j] = max(result[j], x[i])
    return result

def affine_form(c: np.ndarray, x: np.ndarray) -> float:
    """Affine form: sum_i c_i * x_i."""
    return np.dot(c, x)

def poly_slack(A: np.ndarray, b: np.ndarray, x: np.ndarray) -> np.ndarray:
    """Polyhedral slack: b_j - sum_i A_{j,i} * x_i."""
    return b - A @ x

def in_polyhedron(A: np.ndarray, b: np.ndarray, x: np.ndarray) -> bool:
    """Check if x is in the polyhedron {x : Ax <= b}."""
    return np.all(A @ x <= b + 1e-12)

def row_norm(A: np.ndarray) -> np.ndarray:
    """Row norms: sum_i |A_{j,i}| for each row j."""
    return np.sum(np.abs(A), axis=1)

# ============================================================================
# Demo 1: Kinetic Tropical Margin Stability
# ============================================================================

def demo_kinetic_stability():
    """Demonstrate kinetic tropical margin stability."""
    print("=" * 70)
    print("DEMO 1: Kinetic Tropical Margin Stability")
    print("=" * 70)

    # Setup: two competing tropical affine scores
    n = 4
    w1 = np.array([1.0, 3.0, 2.0, 0.5])
    w2 = np.array([2.0, 1.0, 1.5, 1.0])
    b1, b2 = 0.5, 0.0
    x0 = np.array([1.0, 0.5, 2.0, 1.5])
    v = np.array([0.3, -0.2, 0.1, -0.4])  # velocity

    # Compute margin at t=0
    score1_0 = trop_affine_score(w1, x0, b1)
    score2_0 = trop_affine_score(w2, x0, b2)
    margin = score1_0 - score2_0

    print(f"\nWeight vectors: w1 = {w1}, w2 = {w2}")
    print(f"Biases: b1 = {b1}, b2 = {b2}")
    print(f"Initial position: x0 = {x0}")
    print(f"Velocity: v = {v}")
    print(f"\nScore 1 at t=0: {score1_0:.4f}")
    print(f"Score 2 at t=0: {score2_0:.4f}")
    print(f"Margin at t=0: {margin:.4f}")

    # Compute explicit stability bound
    L = np.max(np.abs(v))
    eps_bound = margin / (2 * L + 1)
    print(f"\nLipschitz constant L = max|v_i| = {L:.4f}")
    print(f"Certified stability radius: ε = m/(2L+1) = {eps_bound:.4f}")

    # Verify: compute scores over time
    t_values = np.linspace(-2 * eps_bound, 2 * eps_bound, 1000)
    scores1 = [trop_affine_score(w1, line_path(x0, v, t), b1) for t in t_values]
    scores2 = [trop_affine_score(w2, line_path(x0, v, t), b2) for t in t_values]
    margins = np.array(scores1) - np.array(scores2)

    # Find actual crossing time
    sign_changes = np.where(np.diff(np.sign(margins)))[0]
    if len(sign_changes) > 0:
        actual_crossing = np.min(np.abs(t_values[sign_changes]))
        print(f"Actual first crossing at |t| ≈ {actual_crossing:.4f}")
        print(f"Certified bound is conservative by factor {actual_crossing/eps_bound:.2f}x")
    else:
        print("No crossing observed in the range — margin remains positive")

    # Plot
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    ax1.plot(t_values, scores1, 'b-', linewidth=2, label='Score 1')
    ax1.plot(t_values, scores2, 'r-', linewidth=2, label='Score 2')
    ax1.axvline(x=-eps_bound, color='green', linestyle='--', alpha=0.7, label=f'ε = {eps_bound:.3f}')
    ax1.axvline(x=eps_bound, color='green', linestyle='--', alpha=0.7)
    ax1.axvspan(-eps_bound, eps_bound, alpha=0.1, color='green')
    ax1.set_xlabel('Time t', fontsize=12)
    ax1.set_ylabel('Tropical Affine Score', fontsize=12)
    ax1.set_title('Kinetic Tropical Scores Along Path', fontsize=14)
    ax1.legend(fontsize=11)
    ax1.grid(True, alpha=0.3)

    ax2.plot(t_values, margins, 'purple', linewidth=2)
    ax2.axhline(y=0, color='black', linestyle='-', alpha=0.3)
    ax2.axvline(x=-eps_bound, color='green', linestyle='--', alpha=0.7, label=f'Certified ε = {eps_bound:.3f}')
    ax2.axvline(x=eps_bound, color='green', linestyle='--', alpha=0.7)
    ax2.axvspan(-eps_bound, eps_bound, alpha=0.1, color='green')
    ax2.set_xlabel('Time t', fontsize=12)
    ax2.set_ylabel('Margin (Score 1 - Score 2)', fontsize=12)
    ax2.set_title('Certified Margin Stability', fontsize=14)
    ax2.legend(fontsize=11)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('kinetic_stability.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("\nPlot saved to kinetic_stability.png")

# ============================================================================
# Demo 2: Tropical Data Processing Inequality
# ============================================================================

def demo_data_processing():
    """Demonstrate tropical spread monotonicity under coarse-graining."""
    print("\n" + "=" * 70)
    print("DEMO 2: Tropical Data Processing Inequality")
    print("=" * 70)

    # Example 1: Simple coarse-graining
    x = np.array([5.0, 2.0, 8.0, 1.0, 6.0, 3.0])
    n = len(x)

    # Surjection π: {0,1,2,3,4,5} → {0,1,2}
    # Fibers: {0,1} → 0, {2,3} → 1, {4,5} → 2
    pi_map = lambda i: i // 2
    m = 3

    cg_x = coarse_grain_max(x, pi_map, m)
    spread_before = trop_spread(x)
    spread_after = trop_spread(cg_x)

    print(f"\nOriginal vector x = {x}")
    print(f"Partition: {{0,1}}→0, {{2,3}}→1, {{4,5}}→2")
    print(f"Coarse-grained: T_π(x) = {cg_x}")
    print(f"\nSpread before: {spread_before:.4f}")
    print(f"Spread after:  {spread_after:.4f}")
    print(f"Spread decreased: {spread_before >= spread_after}")
    print(f"Reduction: {(1 - spread_after/spread_before)*100:.1f}%")

    # Example 2: Many random trials
    np.random.seed(42)
    n_trials = 10000
    n_dim = 10
    violations = 0
    reductions = []

    for _ in range(n_trials):
        x = np.random.randn(n_dim) * 5
        # Random surjection onto m outputs
        m_out = np.random.randint(2, n_dim)
        # Build a guaranteed surjection
        pi_vals = np.random.randint(0, m_out, size=n_dim)
        # Ensure surjectivity: place each output value at least once
        perm = np.random.permutation(n_dim)
        for j in range(m_out):
            pi_vals[perm[j]] = j
        pi_map_rand = lambda i, pv=pi_vals: pv[i]

        cg = coarse_grain_max(x, pi_map_rand, m_out)
        s_before = trop_spread(x)
        s_after = trop_spread(cg)

        if s_after > s_before + 1e-10:
            violations += 1
        if s_before > 0:
            reductions.append(1 - s_after / s_before)

    print(f"\nRandom verification ({n_trials} trials):")
    print(f"  Violations: {violations}")
    print(f"  Mean spread reduction: {np.mean(reductions)*100:.1f}%")
    print(f"  Max spread reduction: {np.max(reductions)*100:.1f}%")

    # Plot: spread reduction histogram
    fig, ax = plt.subplots(figsize=(8, 5))
    ax.hist(reductions, bins=50, color='steelblue', edgecolor='white', alpha=0.8)
    ax.axvline(x=0, color='red', linestyle='--', linewidth=2, label='No reduction')
    ax.set_xlabel('Spread Reduction Fraction', fontsize=12)
    ax.set_ylabel('Count', fontsize=12)
    ax.set_title('Tropical Data Processing: Spread Reduction under Coarse-Graining', fontsize=14)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.savefig('data_processing.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Plot saved to data_processing.png")

# ============================================================================
# Demo 3: Polyhedral Membership Stability
# ============================================================================

def demo_polyhedral_stability():
    """Demonstrate polyhedral membership stability with explicit bounds."""
    print("\n" + "=" * 70)
    print("DEMO 3: Polyhedral Membership Stability")
    print("=" * 70)

    # Define a simple polyhedron in 2D: a square [-1,1] x [-1,1]
    # Constraints: x1 <= 1, -x1 <= 1, x2 <= 1, -x2 <= 1
    A = np.array([
        [1.0, 0.0],   # x1 <= 1
        [-1.0, 0.0],  # -x1 <= 1
        [0.0, 1.0],   # x2 <= 1
        [0.0, -1.0],  # -x2 <= 1
    ])
    b = np.array([1.0, 1.0, 1.0, 1.0])

    # Test point inside
    x = np.array([0.3, 0.5])

    slacks = poly_slack(A, b, x)
    rn = row_norm(A)
    eps_per_constraint = slacks / (rn + 1)
    eps = np.min(eps_per_constraint)

    print(f"\nPolyhedron: [-1,1] × [-1,1]")
    print(f"Test point: x = {x}")
    print(f"Inside polyhedron: {in_polyhedron(A, b, x)}")
    print(f"\nSlacks per constraint: {slacks}")
    print(f"Row norms: {rn}")
    print(f"ε per constraint: {eps_per_constraint}")
    print(f"Certified stability radius: ε = {eps:.4f}")

    # Verify with random perturbations
    n_tests = 10000
    violations_inside = 0
    violations_outside = 0

    for _ in range(n_tests):
        delta = np.random.uniform(-eps, eps, size=2)
        y_inside = x + delta * 0.99
        y_outside = x + delta * 2.0

        if not in_polyhedron(A, b, y_inside):
            violations_inside += 1
        # Check if outside bound gives violations
        if not in_polyhedron(A, b, y_outside):
            violations_outside += 1

    print(f"\nVerification ({n_tests} random perturbations):")
    print(f"  Within ε: {violations_inside} violations (should be 0)")
    print(f"  Beyond 2ε: {violations_outside} violations (may occur)")

    # Plot
    fig, ax = plt.subplots(figsize=(8, 8))

    # Draw polyhedron
    rect = plt.Rectangle((-1, -1), 2, 2, fill=False, edgecolor='black', linewidth=2)
    ax.add_patch(rect)

    # Draw certified region
    circle = plt.Circle(x, eps, fill=True, facecolor='lightgreen', edgecolor='green',
                        linewidth=2, alpha=0.4, label=f'Certified ε = {eps:.3f}')
    ax.add_patch(circle)

    # Draw point
    ax.plot(x[0], x[1], 'ro', markersize=10, zorder=5, label=f'x = ({x[0]}, {x[1]})')

    # Draw some perturbations
    np.random.seed(123)
    for _ in range(200):
        angle = np.random.uniform(0, 2*np.pi)
        r = np.random.uniform(0, eps * 0.99)
        y = x + r * np.array([np.cos(angle), np.sin(angle)])
        ax.plot(y[0], y[1], 'g.', markersize=2, alpha=0.5)

    ax.set_xlim(-1.5, 1.5)
    ax.set_ylim(-1.5, 1.5)
    ax.set_aspect('equal')
    ax.set_xlabel('x₁', fontsize=12)
    ax.set_ylabel('x₂', fontsize=12)
    ax.set_title('Polyhedral Membership Stability Certificate', fontsize=14)
    ax.legend(fontsize=11, loc='upper left')
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('polyhedral_stability.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Plot saved to polyhedral_stability.png")

# ============================================================================
# Demo 4: Combined Kinetic Polyhedral Stability
# ============================================================================

def demo_kinetic_polyhedral():
    """Demonstrate the synthesis theorem: kinetic polyhedral stability."""
    print("\n" + "=" * 70)
    print("DEMO 4: Kinetic Polyhedral Stability (Synthesis)")
    print("=" * 70)

    # Polyhedron in 2D: triangle
    A = np.array([
        [1.0, 1.0],    # x1 + x2 <= 3
        [-1.0, 0.0],   # -x1 <= 0 (i.e., x1 >= 0)
        [0.0, -1.0],   # -x2 <= 0 (i.e., x2 >= 0)
    ])
    b = np.array([3.0, 0.0, 0.0])

    # Starting point inside triangle
    x0 = np.array([1.0, 1.0])
    v = np.array([0.5, 0.3])  # velocity

    slacks = poly_slack(A, b, x0)
    print(f"\nPolyhedron: x1+x2 ≤ 3, x1 ≥ 0, x2 ≥ 0 (triangle)")
    print(f"Starting point: x0 = {x0}")
    print(f"Velocity: v = {v}")
    print(f"Slacks at x0: {slacks}")

    # Compute certified time horizon
    rn = row_norm(A)
    eps_spatial = np.min(slacks / (rn + 1))

    # Time bound: need |t * v_i| < eps for all i
    v_sum = np.sum(np.abs(v)) + 1
    eps_time = eps_spatial / v_sum

    print(f"Certified spatial radius: {eps_spatial:.4f}")
    print(f"Certified time horizon: |t| < {eps_time:.4f}")

    # Trace trajectory
    t_values = np.linspace(-3 * eps_time, 3 * eps_time, 500)
    inside = [in_polyhedron(A, b, line_path(x0, v, t)) for t in t_values]

    # Find actual exit time
    inside_arr = np.array(inside, dtype=float)
    transitions = np.where(np.diff(inside_arr))[0]

    print(f"\nTrajectory analysis:")
    if len(transitions) > 0:
        actual_exit = np.min(np.abs(t_values[transitions]))
        print(f"  Actual exit time: |t| ≈ {actual_exit:.4f}")
        print(f"  Conservatism factor: {actual_exit/eps_time:.2f}x")
    else:
        print("  No exit observed in range")

    # Plot
    fig, ax = plt.subplots(figsize=(8, 8))

    # Draw triangle
    triangle = plt.Polygon([(0, 0), (3, 0), (0, 3)], fill=True,
                           facecolor='lightyellow', edgecolor='black', linewidth=2)
    ax.add_patch(triangle)

    # Draw trajectory
    trajectory_x = [line_path(x0, v, t)[0] for t in t_values]
    trajectory_y = [line_path(x0, v, t)[1] for t in t_values]

    # Color trajectory by inside/outside
    for i in range(len(t_values) - 1):
        color = 'green' if inside[i] else 'red'
        ax.plot(trajectory_x[i:i+2], trajectory_y[i:i+2], color=color, linewidth=2)

    # Mark certified region
    t_cert = np.linspace(-eps_time, eps_time, 100)
    cert_x = [line_path(x0, v, t)[0] for t in t_cert]
    cert_y = [line_path(x0, v, t)[1] for t in t_cert]
    ax.plot(cert_x, cert_y, 'b-', linewidth=4, alpha=0.6, label=f'Certified (|t| < {eps_time:.3f})')

    ax.plot(x0[0], x0[1], 'ko', markersize=10, zorder=5, label='x₀')
    ax.arrow(x0[0], x0[1], v[0]*0.3, v[1]*0.3, head_width=0.05,
             head_length=0.02, fc='black', ec='black')

    ax.set_xlim(-0.5, 3.5)
    ax.set_ylim(-0.5, 3.5)
    ax.set_aspect('equal')
    ax.set_xlabel('x₁', fontsize=12)
    ax.set_ylabel('x₂', fontsize=12)
    ax.set_title('Kinetic Polyhedral Stability: Certified Path', fontsize=14)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('kinetic_polyhedral.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Plot saved to kinetic_polyhedral.png")

# ============================================================================
# Main
# ============================================================================

if __name__ == '__main__':
    demo_kinetic_stability()
    demo_data_processing()
    demo_polyhedral_stability()
    demo_kinetic_polyhedral()

    print("\n" + "=" * 70)
    print("All demos completed successfully!")
    print("=" * 70)
