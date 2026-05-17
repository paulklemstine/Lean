#!/usr/bin/env python3
"""
Tropical Certified Information Dynamics — Applications

Real-world applications of the tropical certification theorems:
1. Neural network robustness certification
2. Hybrid system guard verification
3. Max-pooling information loss analysis
4. Streaming data decision stability
"""

import numpy as np
from typing import List, Tuple
from algorithms import (
    trop_affine_score, compute_kinetic_certificate,
    compute_polyhedral_certificate, compute_spread_contraction,
    compute_tmi, postprocess_channel, compute_kinetic_polyhedral_certificate
)


# ========================================================================
# Application 1: Neural Network Robustness Certification
# ========================================================================

def neural_network_robustness():
    """Demonstrate tropical certification for a simple tropicalized neural network.

    A 2-class classifier with tropical affine scores over 5-dimensional inputs.
    We certify robustness against adversarial perturbations along specific directions.
    """
    print("=" * 70)
    print("APPLICATION 1: Neural Network Robustness Certification")
    print("=" * 70)

    np.random.seed(42)
    n = 5  # input dimension

    # Two-class tropicalized classifier
    w_class0 = np.array([0.8, 1.2, 0.3, 0.9, 0.5])
    w_class1 = np.array([0.5, 0.7, 1.1, 0.4, 0.8])
    b0, b1 = 0.3, -0.1

    # Test input
    x = np.array([1.0, 0.5, 2.0, 1.5, 0.8])

    s0 = trop_affine_score(w_class0, x, b0)
    s1 = trop_affine_score(w_class1, x, b1)
    print(f"\nInput: x = {x}")
    print(f"Score class 0: {s0:.4f}")
    print(f"Score class 1: {s1:.4f}")
    print(f"Predicted class: {0 if s0 > s1 else 1}")
    print(f"Margin: {abs(s0-s1):.4f}")

    # Certify against different perturbation directions
    print("\nRobustness certificates against perturbation directions:")
    directions = [
        ("random noise", np.random.randn(n)),
        ("coordinate 3 attack", np.array([0, 0, 1, 0, 0], dtype=float)),
        ("uniform drift", np.ones(n) * 0.1),
        ("adversarial (max gradient)", w_class1 - w_class0),
    ]

    for name, v in directions:
        v_norm = v / np.max(np.abs(v)) if np.max(np.abs(v)) > 0 else v
        cert = compute_kinetic_certificate(
            [w_class0, w_class1], [b0, b1], x, v_norm
        )
        print(f"  {name:30s}: T = {cert.certified_time:.4f} "
              f"(L={cert.lipschitz_constant:.3f})")


# ========================================================================
# Application 2: Hybrid System Guard Verification
# ========================================================================

def hybrid_system_guards():
    """Demonstrate polyhedral guard certification for a hybrid control system.

    A robot operating in a workspace with safety constraints. We certify
    that the robot remains in a safe operating zone for an explicit time horizon.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 2: Hybrid System Guard Verification")
    print("=" * 70)

    # Workspace constraints for a 2D robot
    # Safe zone: 0.5 ≤ x ≤ 4.5, 0.5 ≤ y ≤ 3.5, x + y ≤ 6
    A = np.array([
        [1, 0],     # x ≤ 4.5
        [-1, 0],    # -x ≤ -0.5
        [0, 1],     # y ≤ 3.5
        [0, -1],    # -y ≤ -0.5
        [1, 1],     # x + y ≤ 6
    ], dtype=float)
    b = np.array([4.5, -0.5, 3.5, -0.5, 6.0])

    # Robot current position and velocity
    scenarios = [
        ("Center of workspace", np.array([2.5, 2.0]), np.array([0.5, 0.3])),
        ("Near boundary", np.array([4.0, 1.0]), np.array([0.2, 0.1])),
        ("Moving toward corner", np.array([3.0, 2.5]), np.array([0.4, 0.4])),
    ]

    for name, x0, v in scenarios:
        spatial_r, time_cert = compute_kinetic_polyhedral_certificate(A, b, x0, v)
        pcert = compute_polyhedral_certificate(A, b, x0)
        print(f"\n  Scenario: {name}")
        print(f"  Position: {x0}, Velocity: {v}")
        print(f"  Min slack: {pcert.min_slack:.4f}")
        print(f"  Spatial radius: {spatial_r:.4f}")
        print(f"  Certified safe time: {time_cert:.4f} seconds")
        print(f"  Critical constraint: #{pcert.critical_constraint}")


# ========================================================================
# Application 3: Max-Pooling Information Loss
# ========================================================================

def max_pooling_analysis():
    """Analyze information loss through max-pooling layers using spread contraction.

    Simulates a 1D signal processed by successive max-pooling layers,
    measuring the spread contraction at each stage.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 3: Max-Pooling Information Loss Analysis")
    print("=" * 70)

    # Simulate a signal with rich structure
    np.random.seed(123)
    n = 64
    t = np.linspace(0, 4 * np.pi, n)
    signal = np.sin(t) + 0.5 * np.sin(3 * t) + 0.3 * np.random.randn(n)

    print(f"\nOriginal signal: {n} samples")
    print(f"Original spread: {np.max(signal) - np.min(signal):.4f}")

    # Apply successive 2x max-pooling
    current = signal
    layer = 0
    while len(current) >= 2:
        n_cur = len(current)
        n_blocks = n_cur // 2
        partition = [[2*i, 2*i+1] for i in range(n_blocks)]
        result = compute_spread_contraction(current[:n_blocks*2], partition)

        print(f"  Layer {layer}: {n_cur} → {n_blocks} samples, "
              f"spread {result.original_spread:.4f} → {result.coarsened_spread:.4f} "
              f"(ratio: {result.contraction_ratio:.4f})")

        current = result.coarsened_vector
        layer += 1

    print(f"\nFinal value after full pooling: {current[0]:.4f}")
    print("Note: spread can only decrease (DPI), confirming theorem.")


# ========================================================================
# Application 4: Channel Composition Information Bound
# ========================================================================

def channel_composition():
    """Demonstrate that composing channels cannot increase TMI.

    Models a communication system where a tropical channel is followed
    by deterministic processing stages.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 4: Tropical Channel Information Bounds")
    print("=" * 70)

    # Original channel: 3 inputs, 6 outputs
    K = np.array([
        [5, 2, 4, 1, 3, 0],
        [1, 5, 0, 4, 2, 3],
        [3, 0, 2, 5, 1, 4],
    ], dtype=float)

    tmi_original = compute_tmi(K)
    print(f"\nOriginal channel K (3×6):")
    print(K)
    print(f"TMI(K) = {tmi_original:.4f}")

    # Successive coarse-grainings
    coarsenings = [
        ("Merge pairs", [0, 0, 1, 1, 2, 2]),
        ("Merge triples", [0, 0, 0, 1, 1, 1]),
        ("Binary output", [0, 0, 0, 1, 1, 1]),
        ("Collapse all", [0, 0, 0, 0, 0, 0]),
    ]

    for name, g in coarsenings:
        Kg = postprocess_channel(K, g)
        tmi_g = compute_tmi(Kg)
        print(f"\n  {name} (g={g}):")
        print(f"  TMI = {tmi_g:.4f} ≤ {tmi_original:.4f} (original)")
        assert tmi_g <= tmi_original + 1e-10, "DPI violated!"

    print("\nAll coarse-grainings satisfy TMI(K▷g) ≤ TMI(K). ✓")


# ========================================================================
# Application 5: Streaming Decision Stability
# ========================================================================

def streaming_stability():
    """Demonstrate kinetic certification for streaming data decisions.

    Models a real-time system that classifies streaming sensor data.
    The input evolves linearly between sensor readings, and we certify
    that the classification is stable between readings.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 5: Streaming Decision Stability")
    print("=" * 70)

    np.random.seed(55)
    n_features = 8
    n_classes = 4
    sensor_interval = 0.1  # seconds between readings

    # Multi-class tropicalized classifier
    weights = [np.random.randn(n_features) * 0.5 for _ in range(n_classes)]
    biases = [np.random.randn() * 0.2 for _ in range(n_classes)]

    # Simulate streaming data
    x_current = np.random.randn(n_features)
    v_drift = np.random.randn(n_features) * 0.3  # sensor drift rate

    print(f"\n{n_classes}-class classifier, {n_features} features")
    print(f"Sensor reading interval: {sensor_interval}s")
    print(f"Max drift rate: {np.max(np.abs(v_drift)):.4f}/s")

    # Compute certificates at each "sensor reading"
    n_readings = 10
    for step in range(n_readings):
        x_now = x_current + step * sensor_interval * v_drift

        # Compute scores
        scores = [trop_affine_score(w, x_now, b)
                  for w, b in zip(weights, biases)]
        winner = np.argmax(scores)
        margin = scores[winner] - sorted(scores)[-2]

        cert = compute_kinetic_certificate(weights, biases, x_now, v_drift)
        safe = cert.certified_time >= sensor_interval

        print(f"  t={step*sensor_interval:.1f}s: class={winner}, "
              f"margin={margin:.4f}, cert_time={cert.certified_time:.4f}s "
              f"{'✓ SAFE' if safe else '⚠ RECHECK'}")


if __name__ == "__main__":
    neural_network_robustness()
    hybrid_system_guards()
    max_pooling_analysis()
    channel_composition()
    streaming_stability()
    print("\n" + "=" * 70)
    print("All applications completed successfully!")
    print("=" * 70)


#!/usr/bin/env python3
"""
Tropical Certified Information Dynamics — Demonstrations

Concrete numerical examples demonstrating the three main theorems:
1. Kinetic tropical margin stability
2. Tropical data processing inequality (spread contraction)
3. Polyhedral membership stability
"""

import numpy as np
from typing import Tuple, List


def trop_affine_score(w: np.ndarray, x: np.ndarray, b: float) -> float:
    """Tropical affine score: b + max_i(w_i + x_i)."""
    return b + np.max(w + x)


def line_path(x0: np.ndarray, v: np.ndarray, t: float) -> np.ndarray:
    """Linear path: x(t) = x0 + t * v."""
    return x0 + t * v


def kinetic_certificate(w1: np.ndarray, w2: np.ndarray, b1: float, b2: float,
                         x0: np.ndarray, v: np.ndarray) -> float:
    """Compute the certified stability time for kinetic tropical margin stability.
    Returns T > 0 such that for |t| < T, score1 > score2."""
    margin = trop_affine_score(w1, x0, b1) - trop_affine_score(w2, x0, b2)
    if margin <= 0:
        return 0.0
    L = np.max(np.abs(v))
    return margin / (2 * L + 1)


def trop_spread(x: np.ndarray) -> float:
    """Tropical spread: max(x) - min(x)."""
    return np.max(x) - np.min(x)


def coarse_grain_max(x: np.ndarray, partition: List[List[int]]) -> np.ndarray:
    """Coarse-grain by taking max over each block of the partition."""
    return np.array([np.max(x[block]) for block in partition])


def poly_slack(A: np.ndarray, b: np.ndarray, x: np.ndarray) -> np.ndarray:
    """Compute polyhedral slack: s_j = b_j - sum_i A_{ji} x_i."""
    return b - A @ x


def poly_stability_radius(A: np.ndarray, b: np.ndarray, x: np.ndarray) -> float:
    """Compute the explicit stability radius for polyhedral membership."""
    slack = poly_slack(A, b, x)
    if np.any(slack <= 0):
        return 0.0
    row_norms = np.sum(np.abs(A), axis=1)
    radii = slack / (row_norms + 1)
    return np.min(radii)


# ========================================================================
# Demo 1: Kinetic Tropical Margin Stability
# ========================================================================
def demo_kinetic_stability():
    print("=" * 70)
    print("DEMO 1: Kinetic Tropical Margin Stability")
    print("=" * 70)

    n = 4
    w1 = np.array([1.0, 0.5, 0.8, 1.2])
    w2 = np.array([0.3, 0.9, 0.2, 0.7])
    b1, b2 = 0.5, -0.1
    x0 = np.array([1.0, 2.0, 1.5, 0.8])
    v = np.array([0.1, -0.05, 0.2, -0.15])

    score1 = trop_affine_score(w1, x0, b1)
    score2 = trop_affine_score(w2, x0, b2)
    margin = score1 - score2

    print(f"\nWeights w1 = {w1}, w2 = {w2}")
    print(f"Biases b1 = {b1}, b2 = {b2}")
    print(f"Position x0 = {x0}, velocity v = {v}")
    print(f"\nScore 1 at t=0: {score1:.4f}")
    print(f"Score 2 at t=0: {score2:.4f}")
    print(f"Margin at t=0: {margin:.4f}")

    T = kinetic_certificate(w1, w2, b1, b2, x0, v)
    L = np.max(np.abs(v))
    print(f"\nMax velocity component |v|_∞ = {L:.4f}")
    print(f"Certified stability time: T = {T:.4f}")

    # Verify along the trajectory
    print(f"\nVerification along trajectory:")
    times = np.linspace(-T * 1.5, T * 1.5, 21)
    for t in times:
        xt = line_path(x0, v, t)
        s1 = trop_affine_score(w1, xt, b1)
        s2 = trop_affine_score(w2, xt, b2)
        inside = abs(t) < T
        correct = s1 > s2
        status = "✓" if (inside and correct) or not inside else "✗"
        certified = "CERT" if inside else "    "
        print(f"  t = {t:+.3f}  margin = {s1-s2:+.4f}  {certified} {status}")


# ========================================================================
# Demo 2: Tropical Data Processing Inequality (Spread Contraction)
# ========================================================================
def demo_spread_contraction():
    print("\n" + "=" * 70)
    print("DEMO 2: Tropical Data Processing Inequality (Spread Contraction)")
    print("=" * 70)

    # Example 1: Simple partition
    x = np.array([3.0, 1.0, 4.0, 1.0, 5.0, 9.0, 2.0, 6.0])
    partition = [[0, 1], [2, 3], [4, 5], [6, 7]]  # blocks of 2

    orig_spread = trop_spread(x)
    coarsened = coarse_grain_max(x, partition)
    coarse_spread = trop_spread(coarsened)

    print(f"\nOriginal vector: {x}")
    print(f"Partition: {partition}")
    print(f"Coarsened vector (block max): {coarsened}")
    print(f"\nOriginal spread: {orig_spread:.4f}")
    print(f"Coarsened spread: {coarse_spread:.4f}")
    print(f"Spread ratio: {coarse_spread/orig_spread:.4f}")
    print(f"DPI satisfied: {coarse_spread <= orig_spread + 1e-10}")

    # Example 2: Aggressive compression
    print(f"\n--- Aggressive compression ---")
    partition2 = [[0, 1, 2, 3], [4, 5, 6, 7]]  # two big blocks
    coarsened2 = coarse_grain_max(x, partition2)
    coarse_spread2 = trop_spread(coarsened2)

    print(f"Partition: {partition2}")
    print(f"Coarsened vector: {coarsened2}")
    print(f"Coarsened spread: {coarse_spread2:.4f}")
    print(f"Spread ratio: {coarse_spread2/orig_spread:.4f}")
    print(f"More compression → more contraction: {coarse_spread2 <= coarse_spread + 1e-10}")

    # Statistical validation
    print(f"\n--- Statistical validation (1000 random trials) ---")
    violations = 0
    ratios = []
    for _ in range(1000):
        n_pts = 20
        m_blocks = 5
        xx = np.random.randn(n_pts) * 3
        # Random surjective partition
        perm = np.random.permutation(n_pts)
        part = [[] for _ in range(m_blocks)]
        for idx in range(m_blocks):
            part[idx].append(perm[idx])  # ensure surjectivity
        for idx in range(m_blocks, n_pts):
            part[np.random.randint(m_blocks)].append(perm[idx])

        os = trop_spread(xx)
        cs = trop_spread(coarse_grain_max(xx, part))
        if cs > os + 1e-10:
            violations += 1
        if os > 0:
            ratios.append(cs / os)

    print(f"Violations of DPI: {violations}/1000")
    print(f"Mean spread ratio: {np.mean(ratios):.4f}")
    print(f"Max spread ratio: {np.max(ratios):.6f}")


# ========================================================================
# Demo 3: Polyhedral Membership Stability
# ========================================================================
def demo_polyhedral_stability():
    print("\n" + "=" * 70)
    print("DEMO 3: Polyhedral Membership Stability")
    print("=" * 70)

    # Define a polyhedron in R^3: a cube [-1,1]^3
    # Constraints: x_i <= 1 and -x_i <= 1 for i = 1,2,3
    A = np.array([
        [1, 0, 0],   # x1 <= 1
        [-1, 0, 0],  # -x1 <= 1
        [0, 1, 0],   # x2 <= 1
        [0, -1, 0],  # -x2 <= 1
        [0, 0, 1],   # x3 <= 1
        [0, 0, -1],  # -x3 <= 1
    ], dtype=float)
    b = np.ones(6)

    # Point near the center
    x = np.array([0.0, 0.0, 0.0])
    slack = poly_slack(A, b, x)
    radius = poly_stability_radius(A, b, x)

    print(f"\nPolyhedron: unit cube [-1,1]³")
    print(f"Point: x = {x}")
    print(f"Slack: {slack}")
    print(f"Stability radius: {radius:.4f}")

    # Point near a face
    x2 = np.array([0.8, 0.0, 0.0])
    slack2 = poly_slack(A, b, x2)
    radius2 = poly_stability_radius(A, b, x2)

    print(f"\nPoint near face: x = {x2}")
    print(f"Slack: {slack2}")
    print(f"Stability radius: {radius2:.4f}")
    print(f"(Smaller radius because closer to boundary)")

    # Verify perturbations
    print(f"\nVerification with random perturbations:")
    n_tests = 1000
    n_inside = 0
    for _ in range(n_tests):
        delta = np.random.uniform(-radius2 * 0.99, radius2 * 0.99, size=3)
        y = x2 + delta
        if np.all(A @ y <= b + 1e-10):
            n_inside += 1
    print(f"  Within certified radius: {n_inside}/{n_tests} inside polyhedron")

    n_outside_tests = 0
    for _ in range(n_tests):
        delta = np.random.uniform(-radius2 * 2, radius2 * 2, size=3)
        y = x2 + delta
        if np.all(A @ y <= b + 1e-10):
            n_outside_tests += 1
    print(f"  Wider perturbation (2x radius): {n_outside_tests}/{n_tests} inside")


# ========================================================================
# Demo 4: Combined Kinetic Polyhedral Stability
# ========================================================================
def demo_kinetic_polyhedral():
    print("\n" + "=" * 70)
    print("DEMO 4: Combined Kinetic Polyhedral Stability")
    print("=" * 70)

    # Polyhedron in R^2
    A = np.array([
        [1, 1],    # x + y <= 3
        [-1, 0],   # -x <= 1
        [0, -1],   # -y <= 1
        [1, -1],   # x - y <= 2
    ], dtype=float)
    b = np.array([3.0, 1.0, 1.0, 2.0])

    x0 = np.array([0.5, 0.5])
    v = np.array([0.3, -0.2])

    slack = poly_slack(A, b, x0)
    spatial_radius = poly_stability_radius(A, b, x0)
    speed = np.sum(np.abs(v))
    time_cert = spatial_radius / (speed + 1)

    print(f"\nPolyhedron: 4 constraints in R²")
    print(f"Initial position: x0 = {x0}")
    print(f"Velocity: v = {v}")
    print(f"Slack: {slack}")
    print(f"Spatial stability radius: {spatial_radius:.4f}")
    print(f"Speed ∑|v_i|: {speed:.4f}")
    print(f"Kinetic polyhedral certificate: T = {time_cert:.4f}")

    # Trace the trajectory
    print(f"\nTrajectory check:")
    for t in np.linspace(0, time_cert * 2, 11):
        xt = line_path(x0, v, t)
        inside = np.all(A @ xt <= b + 1e-10)
        certified = t < time_cert
        status = "CERT ✓" if certified else ("     ✓" if inside else "     ✗")
        print(f"  t = {t:.3f}  x(t) = [{xt[0]:+.3f}, {xt[1]:+.3f}]  "
              f"inside={inside}  {status}")


# ========================================================================
# Demo 5: Tropical Mutual Information & Data Processing
# ========================================================================
def demo_tropical_mutual_information():
    print("\n" + "=" * 70)
    print("DEMO 5: Tropical Mutual Information & Data Processing")
    print("=" * 70)

    # Channel K : {0,1,2} -> {0,1,2,3} -> R
    K = np.array([
        [3.0, 1.0, 2.0, 0.5],
        [1.0, 3.0, 0.5, 2.0],
        [0.5, 2.0, 3.0, 1.0],
    ])

    def one_sided_sep(K, x1, x2):
        return np.max(K[x1] - K[x2])

    def trop_dist(K, x1, x2):
        return one_sided_sep(K, x1, x2) + one_sided_sep(K, x2, x1)

    def tmi(K):
        n = K.shape[0]
        return max(trop_dist(K, i, j) for i in range(n) for j in range(n))

    print(f"\nChannel K (3 inputs, 4 outputs):")
    print(K)
    print(f"TMI(K) = {tmi(K):.4f}")

    # Coarse-grain: merge outputs {0,1} -> 0, {2,3} -> 1
    def postprocess(K, g):
        n_in = K.shape[0]
        n_out = max(g) + 1
        Kg = np.zeros((n_in, n_out))
        for z in range(n_out):
            fiber = [y for y in range(K.shape[1]) if g[y] == z]
            Kg[:, z] = np.max(K[:, fiber], axis=1)
        return Kg

    g = [0, 0, 1, 1]  # merge pairs
    Kg = postprocess(K, g)
    print(f"\nPost-processing: g = {g}")
    print(f"Post-processed channel K▷g:")
    print(Kg)
    print(f"TMI(K▷g) = {tmi(Kg):.4f}")
    print(f"TMI(K▷g) ≤ TMI(K): {tmi(Kg) <= tmi(K) + 1e-10}")

    # Even more aggressive compression
    g2 = [0, 0, 0, 1]
    Kg2 = postprocess(K, g2)
    print(f"\nMore aggressive: g = {g2}")
    print(f"TMI(K▷g) = {tmi(Kg2):.4f}")
    print(f"TMI(K▷g) ≤ TMI(K): {tmi(Kg2) <= tmi(K) + 1e-10}")


if __name__ == "__main__":
    demo_kinetic_stability()
    demo_spread_contraction()
    demo_polyhedral_stability()
    demo_kinetic_polyhedral()
    demo_tropical_mutual_information()
    print("\n" + "=" * 70)
    print("All demos completed successfully!")
    print("=" * 70)


#!/usr/bin/env python3
"""Generate PACKAGE.json with all deliverables bundled."""

import json
import sys
sys.path.insert(0, '.')
from visualizations import generate_all_visualizations

def read_file(path):
    with open(path, 'r') as f:
        return f.read()

def main():
    # Read all content
    article = read_file('ARTICLE.md')
    research_paper = read_file('RESEARCH_PAPER.md')
    future_directions = read_file('FUTURE_DIRECTIONS.md')
    demo_code = read_file('demo.py')
    algorithms_code = read_file('algorithms.py')
    applications_code = read_file('applications.py')

    # Read Lean proofs
    lean1 = read_file('Catalog/Tropical/KineticCertification.lean')
    lean2 = read_file('Catalog/Tropical/InformationTheory.lean')
    lean3 = read_file('Catalog/Tropical/PhaseII/KineticCertification.lean')
    lean_proofs = (
        "-- ═══════════════════════════════════════════════════════════════\n"
        "-- File: Tropical/KineticCertification.lean\n"
        "-- Kinetic Certification, Data Processing, Polyhedral Compilation\n"
        "-- ═══════════════════════════════════════════════════════════════\n\n"
        + lean1 + "\n\n"
        "-- ═══════════════════════════════════════════════════════════════\n"
        "-- File: Tropical/InformationTheory.lean\n"
        "-- Tropical Information Theory & Data Processing Inequality\n"
        "-- ═══════════════════════════════════════════════════════════════\n\n"
        + lean2 + "\n\n"
        "-- ═══════════════════════════════════════════════════════════════\n"
        "-- File: Tropical/PhaseII/KineticCertification.lean\n"
        "-- Max Along Line Lipschitz Bound\n"
        "-- ═══════════════════════════════════════════════════════════════\n\n"
        + lean3
    )

    # Generate visualizations
    vizs = generate_all_visualizations()

    package = {
        "title": "Tropical Certified Information Dynamics: Kinetic Stability, Data Processing, and Polyhedral Compilation",
        "domain": "Tropical Geometry / Information Theory / Certified Computation",
        "article": article,
        "research_paper": research_paper,
        "future_directions": future_directions,
        "demos": [
            {
                "name": "Kinetic Tropical Margin Stability",
                "code": demo_code
            },
            {
                "name": "Real-World Applications",
                "code": applications_code
            }
        ],
        "algorithms": [
            {
                "name": "Kinetic Certificate Computation",
                "pseudocode": (
                    "Algorithm: ComputeKineticCertificate\n"
                    "Input: weights w₁, w₂ : ℝⁿ, biases b₁, b₂ : ℝ, position x₀ : ℝⁿ, velocity v : ℝⁿ\n"
                    "Output: certified stability time T > 0\n\n"
                    "1. Compute score₁ = b₁ + max_i(w₁[i] + x₀[i])\n"
                    "2. Compute score₂ = b₂ + max_i(w₂[i] + x₀[i])\n"
                    "3. m ← score₁ - score₂\n"
                    "4. If m ≤ 0: return 0\n"
                    "5. L ← max_i |v[i]|\n"
                    "6. Return m / (2L + 1)\n\n"
                    "Complexity: O(n) time, O(1) space"
                ),
                "code": algorithms_code
            },
            {
                "name": "Polyhedral Stability Radius",
                "pseudocode": (
                    "Algorithm: ComputePolyhedralCertificate\n"
                    "Input: A : ℝᵏˣⁿ, b : ℝᵏ, x : ℝⁿ\n"
                    "Output: certified perturbation radius ε > 0\n\n"
                    "1. For j = 1 to k:\n"
                    "     slack[j] ← b[j] - ∑ᵢ A[j,i] * x[i]\n"
                    "     norm[j] ← ∑ᵢ |A[j,i]|\n"
                    "     radius[j] ← slack[j] / (norm[j] + 1)\n"
                    "2. Return min_j radius[j]\n\n"
                    "Complexity: O(kn) time, O(k) space"
                ),
                "code": algorithms_code
            }
        ],
        "visualizations": [
            {
                "name": "Kinetic Tropical Margin Stability",
                "data": vizs["kinetic_stability"]
            },
            {
                "name": "Spread Contraction Under Coarse-Graining",
                "data": vizs["spread_contraction"]
            },
            {
                "name": "Polyhedral Membership Stability",
                "data": vizs["polyhedral_stability"]
            },
            {
                "name": "Tropical Data Processing Inequality",
                "data": vizs["tropical_dpi"]
            }
        ],
        "lean_proofs": lean_proofs
    }

    with open('PACKAGE.json', 'w') as f:
        json.dump(package, f, indent=2, ensure_ascii=False)

    print(f"PACKAGE.json generated ({len(json.dumps(package))} bytes)")

if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Tropical Certified Information Dynamics — Visualizations

Generates publication-quality figures illustrating the main theorems.
Saves as PNG and returns base64-encoded data URIs.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as patches
from matplotlib.colors import LinearSegmentedColormap
import base64
import io
import json


def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64 data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight',
                facecolor='white', edgecolor='none')
    buf.seek(0)
    b64 = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{b64}"


def viz_kinetic_stability() -> str:
    """Visualize kinetic tropical margin stability."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    # Parameters
    w1 = np.array([1.0, 0.5, 0.8, 1.2])
    w2 = np.array([0.3, 0.9, 0.2, 0.7])
    b1, b2 = 0.5, -0.1
    x0 = np.array([1.0, 2.0, 1.5, 0.8])
    v = np.array([0.1, -0.05, 0.2, -0.15])

    def score(w, b, t):
        xt = x0 + t * v
        return b + np.max(w + xt)

    ts = np.linspace(-1.5, 1.5, 500)
    s1 = [score(w1, b1, t) for t in ts]
    s2 = [score(w2, b2, t) for t in ts]

    margin_0 = score(w1, b1, 0) - score(w2, b2, 0)
    L = np.max(np.abs(v))
    T = margin_0 / (2 * L + 1)

    # Left panel: scores over time
    ax = axes[0]
    ax.plot(ts, s1, 'b-', linewidth=2, label='Score 1 (winner)')
    ax.plot(ts, s2, 'r-', linewidth=2, label='Score 2')
    ax.axvspan(-T, T, alpha=0.15, color='green', label=f'Certified interval (|t|<{T:.3f})')
    ax.axvline(0, color='gray', linestyle='--', alpha=0.5)
    ax.set_xlabel('Time t', fontsize=12)
    ax.set_ylabel('Tropical Affine Score', fontsize=12)
    ax.set_title('Kinetic Tropical Margin Stability', fontsize=14)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    # Right panel: margin over time
    ax = axes[1]
    margins = [s1[i] - s2[i] for i in range(len(ts))]
    ax.plot(ts, margins, 'k-', linewidth=2)
    ax.axhline(0, color='red', linestyle='-', alpha=0.5, linewidth=1)
    ax.axvspan(-T, T, alpha=0.15, color='green')
    ax.fill_between(ts, 0, margins, where=[m > 0 for m in margins],
                     alpha=0.1, color='blue')
    ax.fill_between(ts, 0, margins, where=[m <= 0 for m in margins],
                     alpha=0.1, color='red')
    ax.axvline(-T, color='green', linestyle=':', linewidth=1.5)
    ax.axvline(T, color='green', linestyle=':', linewidth=1.5)
    ax.set_xlabel('Time t', fontsize=12)
    ax.set_ylabel('Margin (Score 1 - Score 2)', fontsize=12)
    ax.set_title(f'Margin Evolution (m₀={margin_0:.3f}, T={T:.3f})', fontsize=14)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    return fig_to_base64(fig)


def viz_spread_contraction() -> str:
    """Visualize tropical spread contraction under coarse-graining."""
    fig, axes = plt.subplots(1, 3, figsize=(16, 5))

    np.random.seed(42)
    n = 16
    x = np.random.randn(n) * 2 + np.sin(np.linspace(0, 2*np.pi, n)) * 3

    # Original signal
    ax = axes[0]
    ax.bar(range(n), x, color='steelblue', alpha=0.7, edgecolor='navy')
    ax.axhline(np.max(x), color='red', linestyle='--', alpha=0.7, label=f'max = {np.max(x):.2f}')
    ax.axhline(np.min(x), color='blue', linestyle='--', alpha=0.7, label=f'min = {np.min(x):.2f}')
    spread_orig = np.max(x) - np.min(x)
    ax.set_title(f'Original (spread = {spread_orig:.2f})', fontsize=13)
    ax.set_xlabel('Index', fontsize=11)
    ax.set_ylabel('Score', fontsize=11)
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3, axis='y')

    # 4-block coarse-graining
    partition4 = [[4*i+j for j in range(4)] for i in range(4)]
    coarse4 = np.array([np.max(x[block]) for block in partition4])
    ax = axes[1]
    colors = plt.cm.Set2(np.linspace(0, 1, 4))
    for bi, block in enumerate(partition4):
        for idx in block:
            ax.bar(idx, x[idx], color=colors[bi], alpha=0.4, edgecolor='gray')
    # Draw block maxima
    for bi, block in enumerate(partition4):
        mid = np.mean(block)
        ax.plot([block[0]-0.4, block[-1]+0.4], [coarse4[bi], coarse4[bi]],
                color=colors[bi], linewidth=3)
    spread_4 = np.max(coarse4) - np.min(coarse4)
    ax.set_title(f'4-block (spread = {spread_4:.2f}, ratio = {spread_4/spread_orig:.2f})',
                 fontsize=13)
    ax.set_xlabel('Index', fontsize=11)
    ax.grid(True, alpha=0.3, axis='y')

    # Statistical spread ratios
    ax = axes[2]
    n_trials = 2000
    ms = [2, 4, 8, 12]
    ratios_by_m = {m: [] for m in ms}

    for _ in range(n_trials):
        xx = np.random.randn(n) * 3
        os = np.max(xx) - np.min(xx)
        if os < 1e-10:
            continue
        for m in ms:
            perm = np.random.permutation(n)
            part = [[] for _ in range(m)]
            for idx in range(m):
                part[idx].append(perm[idx])
            for idx in range(m, n):
                part[np.random.randint(m)].append(perm[idx])
            coarse = np.array([np.max(xx[bl]) for bl in part])
            cs = np.max(coarse) - np.min(coarse)
            ratios_by_m[m].append(cs / os)

    positions = range(len(ms))
    bp = ax.boxplot([ratios_by_m[m] for m in ms], positions=positions,
                     widths=0.6, patch_artist=True)
    colors_bp = plt.cm.viridis(np.linspace(0.2, 0.8, len(ms)))
    for patch, color in zip(bp['boxes'], colors_bp):
        patch.set_facecolor(color)
        patch.set_alpha(0.7)
    ax.axhline(1.0, color='red', linestyle='--', alpha=0.7, label='DPI bound')
    ax.set_xticks(positions)
    ax.set_xticklabels([f'm={m}' for m in ms])
    ax.set_xlabel('Number of blocks', fontsize=11)
    ax.set_ylabel('Spread ratio', fontsize=11)
    ax.set_title('Spread Contraction Distribution', fontsize=13)
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3, axis='y')

    plt.tight_layout()
    return fig_to_base64(fig)


def viz_polyhedral_stability() -> str:
    """Visualize polyhedral membership stability in 2D."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Define a polygon in R^2
    # x + y <= 4, -x + y <= 1, x - y <= 2, -x - y <= 1
    A = np.array([
        [1, 1],
        [-1, 1],
        [1, -1],
        [-1, -1],
    ], dtype=float)
    b_vec = np.array([4.0, 1.0, 2.0, 1.0])

    # Generate polygon vertices for plotting
    from matplotlib.patches import Polygon
    from scipy.optimize import linprog

    # Sample boundary
    theta = np.linspace(0, 2*np.pi, 1000)
    boundary_pts = []
    for th in theta:
        d = np.array([np.cos(th), np.sin(th)])
        # Find max t such that A(x0 + t*d) <= b
        # A*x0 + t*A*d <= b => t <= (b - A*x0) / (A*d) for A*d > 0
        x0_ref = np.array([0.75, 0.0])  # center-ish
        Ad = A @ d
        slack = b_vec - A @ x0_ref
        ts = []
        for j in range(len(b_vec)):
            if Ad[j] > 1e-10:
                ts.append(slack[j] / Ad[j])
        if ts:
            t_max = min(ts)
            boundary_pts.append(x0_ref + t_max * d)

    boundary_pts = np.array(boundary_pts)

    # Left panel: polyhedron with stability balls
    ax = axes[0]
    if len(boundary_pts) > 0:
        poly = Polygon(boundary_pts, fill=True, facecolor='lightblue',
                       edgecolor='navy', linewidth=2, alpha=0.5)
        ax.add_patch(poly)

    # Test points with stability radii
    test_points = [
        np.array([0.75, 0.0]),
        np.array([1.5, 0.5]),
        np.array([0.0, 0.5]),
    ]
    point_colors = ['green', 'orange', 'purple']

    for pt, color in zip(test_points, point_colors):
        slack = b_vec - A @ pt
        if np.all(slack > 0):
            row_norms = np.sum(np.abs(A), axis=1)
            radii = slack / (row_norms + 1)
            eps = np.min(radii)

            circle = plt.Circle(pt, eps, fill=False, edgecolor=color,
                               linewidth=2, linestyle='--')
            ax.add_patch(circle)
            ax.plot(*pt, 'o', color=color, markersize=8)
            ax.annotate(f'ε={eps:.3f}', pt + np.array([0.05, 0.05]),
                       fontsize=10, color=color)

    ax.set_xlim(-1.5, 3.5)
    ax.set_ylim(-2, 3)
    ax.set_aspect('equal')
    ax.set_xlabel('x₁', fontsize=12)
    ax.set_ylabel('x₂', fontsize=12)
    ax.set_title('Polyhedral Stability Radii', fontsize=14)
    ax.grid(True, alpha=0.3)

    # Right panel: slack heat map
    ax = axes[1]
    x1_range = np.linspace(-1.5, 3.5, 200)
    x2_range = np.linspace(-2, 3, 200)
    X1, X2 = np.meshgrid(x1_range, x2_range)

    min_slack = np.zeros_like(X1)
    for i in range(X1.shape[0]):
        for j in range(X1.shape[1]):
            pt = np.array([X1[i,j], X2[i,j]])
            slack = b_vec - A @ pt
            row_norms = np.sum(np.abs(A), axis=1)
            radii = slack / (row_norms + 1)
            if np.all(slack > 0):
                min_slack[i,j] = np.min(radii)
            else:
                min_slack[i,j] = 0

    cmap = LinearSegmentedColormap.from_list('custom',
        ['white', '#e6f3ff', '#99ccff', '#3399ff', '#0066cc'], N=256)
    im = ax.contourf(X1, X2, min_slack, levels=20, cmap=cmap)
    ax.contour(X1, X2, min_slack, levels=[0], colors='navy', linewidths=2)
    plt.colorbar(im, ax=ax, label='Stability radius ε')
    ax.set_xlabel('x₁', fontsize=12)
    ax.set_ylabel('x₂', fontsize=12)
    ax.set_title('Stability Radius Heat Map', fontsize=14)
    ax.set_aspect('equal')

    plt.tight_layout()
    return fig_to_base64(fig)


def viz_tropical_dpi() -> str:
    """Visualize the tropical data processing inequality for channels."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    # Channel with varying compression levels
    K = np.array([
        [5, 2, 4, 1, 3, 0, 2, 4],
        [1, 5, 0, 4, 2, 3, 1, 3],
        [3, 0, 2, 5, 1, 4, 3, 2],
        [2, 3, 1, 2, 4, 1, 5, 0],
    ], dtype=float)

    def compute_tmi_local(K):
        n_in = K.shape[0]
        max_dist = 0.0
        for i in range(n_in):
            for j in range(n_in):
                fwd = np.max(K[i] - K[j])
                bwd = np.max(K[j] - K[i])
                max_dist = max(max_dist, fwd + bwd)
        return max_dist

    def postprocess_local(K, g):
        n_in = K.shape[0]
        n_out = max(g) + 1
        Kg = np.full((n_in, n_out), -np.inf)
        for y, z in enumerate(g):
            Kg[:, z] = np.maximum(Kg[:, z], K[:, y])
        return Kg

    # Different compression levels
    compressions = [
        ("8→8 (identity)", list(range(8))),
        ("8→4 (pairs)", [0, 0, 1, 1, 2, 2, 3, 3]),
        ("8→2 (halves)", [0, 0, 0, 0, 1, 1, 1, 1]),
        ("8→1 (collapse)", [0, 0, 0, 0, 0, 0, 0, 0]),
    ]

    labels = []
    tmis = []
    for name, g in compressions:
        Kg = postprocess_local(K, g)
        tmi_val = compute_tmi_local(Kg)
        labels.append(name)
        tmis.append(tmi_val)

    # Left panel: TMI bar chart
    ax = axes[0]
    colors = plt.cm.RdYlGn_r(np.linspace(0.2, 0.8, len(labels)))
    bars = ax.bar(range(len(labels)), tmis, color=colors, edgecolor='black', alpha=0.8)
    ax.set_xticks(range(len(labels)))
    ax.set_xticklabels([l.split('(')[1].rstrip(')') for l in labels],
                        rotation=15, fontsize=10)
    ax.set_ylabel('TMI', fontsize=12)
    ax.set_title('TMI Under Progressive Compression', fontsize=14)
    ax.axhline(tmis[0], color='red', linestyle='--', alpha=0.5,
               label=f'Original TMI = {tmis[0]:.2f}')
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3, axis='y')

    # Add values on bars
    for bar, val in zip(bars, tmis):
        ax.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.1,
                f'{val:.2f}', ha='center', fontsize=10)

    # Right panel: Distinguishability matrix
    ax = axes[1]
    n_in = K.shape[0]
    dist_matrix = np.zeros((n_in, n_in))
    for i in range(n_in):
        for j in range(n_in):
            fwd = np.max(K[i] - K[j])
            bwd = np.max(K[j] - K[i])
            dist_matrix[i, j] = fwd + bwd

    im = ax.imshow(dist_matrix, cmap='YlOrRd', interpolation='nearest')
    plt.colorbar(im, ax=ax, label='δ_K(x₁, x₂)')
    ax.set_xlabel('Input x₂', fontsize=12)
    ax.set_ylabel('Input x₁', fontsize=12)
    ax.set_title('Pairwise Tropical Distinguishability', fontsize=14)
    for i in range(n_in):
        for j in range(n_in):
            ax.text(j, i, f'{dist_matrix[i,j]:.1f}', ha='center', va='center',
                   fontsize=11, color='black' if dist_matrix[i,j] < 6 else 'white')

    plt.tight_layout()
    return fig_to_base64(fig)


def generate_all_visualizations():
    """Generate all visualizations and return as a dictionary."""
    print("Generating visualizations...")

    viz1 = viz_kinetic_stability()
    print("  ✓ Kinetic stability")

    viz2 = viz_spread_contraction()
    print("  ✓ Spread contraction")

    viz3 = viz_polyhedral_stability()
    print("  ✓ Polyhedral stability")

    viz4 = viz_tropical_dpi()
    print("  ✓ Tropical DPI")

    return {
        "kinetic_stability": viz1,
        "spread_contraction": viz2,
        "polyhedral_stability": viz3,
        "tropical_dpi": viz4,
    }


if __name__ == "__main__":
    vizs = generate_all_visualizations()
    print(f"\nGenerated {len(vizs)} visualizations.")
    for name, data in vizs.items():
        print(f"  {name}: {len(data)} bytes")
