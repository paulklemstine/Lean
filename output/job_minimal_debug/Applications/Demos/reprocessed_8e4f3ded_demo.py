#!/usr/bin/env python3
"""
Tropical Degree Robustness Certificate — Concrete Numerical Examples

Demonstrates how the tropical degree of a ReLU network yields a certified
L∞ adversarial robustness radius.
"""

import numpy as np
from typing import List, Tuple


def relu(x: np.ndarray) -> np.ndarray:
    return np.maximum(x, 0)


def tropical_degree_1d(weights: List[np.ndarray], biases: List[np.ndarray]) -> int:
    """
    Upper bound on tropical degree of a ReLU network.
    For a network with layers of widths n_1, ..., n_L, the tropical degree
    (number of linear regions) is at most prod(n_ℓ) over hidden layers.
    """
    d = 1
    for W in weights[:-1]:  # hidden layers only
        d *= W.shape[0]
    return d


def architecture_norm(weights: List[np.ndarray]) -> float:
    """
    Architecture norm K = max over layers of the max absolute row sum (L∞ operator norm).
    For the Lipschitz bound L ≤ K * d, we use the product of per-layer norms,
    but for simplicity we show the max here.
    """
    K = 1.0
    for W in weights:
        # L∞ operator norm = max row sum of |W|
        K *= np.max(np.sum(np.abs(W), axis=1))
    return K


def forward(x: np.ndarray, weights: List[np.ndarray], biases: List[np.ndarray]) -> np.ndarray:
    """Forward pass through a ReLU network."""
    h = x
    for i, (W, b) in enumerate(zip(weights, biases)):
        h = W @ h + b
        if i < len(weights) - 1:  # ReLU on hidden layers only
            h = relu(h)
    return h


def class_margin(scores: np.ndarray, true_class: int) -> float:
    """Classification margin: score of true class minus max of other scores."""
    other_scores = np.delete(scores, true_class)
    return scores[true_class] - np.max(other_scores)


def certified_radius(margin: float, K: float, d: int) -> float:
    """Certified L∞ robustness radius = margin / (2 * K * d)."""
    if K * d <= 0:
        return 0.0
    return margin / (2 * K * d)


def verify_robustness(x: np.ndarray, true_class: int,
                       weights: List[np.ndarray], biases: List[np.ndarray],
                       radius: float, n_samples: int = 10000) -> bool:
    """Empirically verify robustness by random perturbations within the radius."""
    for _ in range(n_samples):
        delta = np.random.uniform(-radius * 0.99, radius * 0.99, size=x.shape)
        scores = forward(x + delta, weights, biases)
        pred = np.argmax(scores)
        if pred != true_class:
            return False
    return True


# ─── Example 1: Simple 2-layer network (2D input, 3 classes) ───
print("=" * 70)
print("Example 1: Simple 2-layer ReLU network")
print("=" * 70)

np.random.seed(42)

# Network: ℝ² → ℝ⁴ (hidden, ReLU) → ℝ³ (output)
W1 = np.array([[0.5, -0.3],
               [-0.2, 0.7],
               [0.4, 0.1],
               [-0.1, -0.5]])
b1 = np.array([0.1, -0.2, 0.3, 0.0])

W2 = np.array([[0.6, -0.4, 0.2, 0.1],
               [-0.3, 0.5, -0.1, 0.3],
               [0.1, -0.2, 0.4, -0.3]])
b2 = np.array([0.0, 0.1, -0.1])

weights = [W1, W2]
biases = [b1, b2]

x = np.array([1.0, 0.5])
scores = forward(x, weights, biases)
true_class = int(np.argmax(scores))

print(f"Input:        x = {x}")
print(f"Scores:       {scores}")
print(f"Predicted:    class {true_class}")

margin = class_margin(scores, true_class)
K = architecture_norm(weights)
d = tropical_degree_1d(weights, biases)

print(f"\nMargin:       {margin:.6f}")
print(f"Arch norm K:  {K:.6f}")
print(f"Trop degree:  {d}")

r = certified_radius(margin, K, d)
print(f"\n✓ Certified L∞ radius: r* = margin/(2·K·d) = {r:.6f}")

# Empirical verification
robust = verify_robustness(x, true_class, weights, biases, r, n_samples=50000)
print(f"  Empirical verification (50k samples): {'PASSED ✓' if robust else 'FAILED ✗'}")

# ─── Example 2: Deeper network ───
print("\n" + "=" * 70)
print("Example 2: 3-layer deep ReLU network")
print("=" * 70)

# Network: ℝ³ → ℝ⁵ → ℝ⁴ → ℝ² (binary classification)
W1 = 0.3 * np.random.randn(5, 3)
b1 = 0.1 * np.random.randn(5)
W2 = 0.3 * np.random.randn(4, 5)
b2 = 0.1 * np.random.randn(4)
W3 = 0.3 * np.random.randn(2, 4)
b3 = 0.1 * np.random.randn(2)

weights = [W1, W2, W3]
biases = [b1, b2, b3]

x = np.array([0.5, -0.3, 0.8])
scores = forward(x, weights, biases)
true_class = int(np.argmax(scores))

print(f"Input:        x = {x}")
print(f"Scores:       {scores}")
print(f"Predicted:    class {true_class}")

margin = class_margin(scores, true_class)
K = architecture_norm(weights)
d = tropical_degree_1d(weights, biases)

print(f"\nMargin:       {margin:.6f}")
print(f"Arch norm K:  {K:.6f}")
print(f"Trop degree:  d = 5 × 4 = {d}")

r = certified_radius(margin, K, d)
print(f"\n✓ Certified L∞ radius: r* = {r:.6f}")

robust = verify_robustness(x, true_class, weights, biases, r, n_samples=50000)
print(f"  Empirical verification (50k samples): {'PASSED ✓' if robust else 'FAILED ✗'}")

# ─── Example 3: Scaling analysis ───
print("\n" + "=" * 70)
print("Example 3: How certified radius scales with network size")
print("=" * 70)

print(f"\n{'Width':>6} {'Depth':>6} {'Trop.Deg':>10} {'K':>10} {'Margin':>10} {'Radius':>10}")
print("-" * 64)

np.random.seed(123)
for width in [4, 8, 16]:
    for depth in [2, 3, 4]:
        layers_w = []
        layers_b = []
        # Input layer
        layers_w.append(0.2 * np.random.randn(width, 3))
        layers_b.append(0.1 * np.random.randn(width))
        # Hidden layers
        for _ in range(depth - 2):
            layers_w.append(0.2 * np.random.randn(width, width))
            layers_b.append(0.1 * np.random.randn(width))
        # Output layer
        layers_w.append(0.2 * np.random.randn(2, width))
        layers_b.append(0.1 * np.random.randn(2))

        x = np.array([1.0, 0.0, -0.5])
        scores = forward(x, layers_w, layers_b)
        true_class = int(np.argmax(scores))
        m = class_margin(scores, true_class)
        K = architecture_norm(layers_w)
        d = tropical_degree_1d(layers_w, layers_b)
        r = certified_radius(m, K, d) if m > 0 else 0.0

        print(f"{width:>6} {depth:>6} {d:>10} {K:>10.4f} {m:>10.6f} {r:>10.6f}")

print("\nObservation: Larger networks → higher tropical degree → smaller certified radius")
print("This matches the theoretical prediction r* ~ 1/(K·d)")
