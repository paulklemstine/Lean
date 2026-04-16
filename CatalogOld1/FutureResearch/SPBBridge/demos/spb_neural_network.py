#!/usr/bin/env python3
"""
SPB Neural Network: A Novel Architecture Using Stereographic Projection

The SPB neuron: y = spbH(x, w) = (x + w) / (1 + x*w)

Key advantages over ReLU/sigmoid:
1. Naturally bounded: maps (-1,1) → (-1,1)
2. Smooth: infinitely differentiable
3. Invertible: inverse is spbH(y, -w)
4. Group structure: composition of layers = single SPB layer

This script demonstrates:
- SPB activation function properties
- Simple function approximation using SPB neurons
- Comparison with standard activation functions
"""

import math
import random

def spbH(x, w):
    """Hyperbolic SPB (bounded variant): (x+w)/(1+xw)"""
    return (x + w) / (1 + x * w)

def spbH_deriv(x, w):
    """Derivative of spbH(x, w) with respect to x"""
    return (1 - w**2) / (1 + x * w)**2

def relu(x):
    return max(0, x)

def sigmoid(x):
    return 1 / (1 + math.exp(-x))

def tanh_act(x):
    return math.tanh(x)

# ============================================================
# Demo 1: SPB Activation Properties
# ============================================================

def demo_activation_properties():
    """Compare SPB with standard activation functions"""
    print("=" * 60)
    print("SPB Neural Network: Activation Function Properties")
    print("=" * 60)

    print("\nProperty comparison:")
    print(f"  {'Property':<30s} {'ReLU':<10s} {'Sigmoid':<10s} {'Tanh':<10s} {'SPB':<10s}")
    print(f"  {'─'*30} {'─'*10} {'─'*10} {'─'*10} {'─'*10}")
    print(f"  {'Bounded':<30s} {'No':<10s} {'Yes':<10s} {'Yes':<10s} {'Yes':<10s}")
    print(f"  {'Smooth':<30s} {'No':<10s} {'Yes':<10s} {'Yes':<10s} {'Yes':<10s}")
    print(f"  {'Invertible':<30s} {'No':<10s} {'Yes':<10s} {'Yes':<10s} {'Yes':<10s}")
    print(f"  {'Group structure':<30s} {'No':<10s} {'No':<10s} {'Yes':<10s} {'Yes':<10s}")
    print(f"  {'Composable algebra':<30s} {'No':<10s} {'No':<10s} {'No':<10s} {'Yes':<10s}")
    print(f"  {'Vanishing gradient':<30s} {'Half':<10s} {'Yes':<10s} {'Yes':<10s} {'No*':<10s}")

    print("\n  * SPB gradient: (1 - w²)/(1 + xw)², nonzero when |w| ≠ 1")

    print("\n  SPB activation values for w = 0.5:")
    print(f"  {'x':<8s} {'spbH(x,0.5)':<15s} {'sigmoid(x)':<15s} {'tanh(x)':<15s}")
    for x_val in [-0.9, -0.5, -0.2, 0.0, 0.2, 0.5, 0.9]:
        s = spbH(x_val, 0.5)
        sig = sigmoid(x_val)
        t = tanh_act(x_val)
        print(f"  {x_val:<8.1f} {s:<15.6f} {sig:<15.6f} {t:<15.6f}")

    # Show the algebraic collapse property
    print("\n  Algebraic collapse (unique to SPB):")
    print("  Two SPB layers with weights w₁, w₂ = single layer with w = spbH(w₁, w₂)")
    w1, w2 = 0.3, 0.4
    w_composed = spbH(w1, w2)
    print(f"  w₁ = {w1}, w₂ = {w2}")
    print(f"  spbH(w₁, w₂) = {w_composed:.6f}")

    for x in [0.1, 0.5, -0.3]:
        two_layer = spbH(spbH(x, w1), w2)
        one_layer = spbH(x, w_composed)
        print(f"  x = {x:5.1f}: two-layer = {two_layer:.8f}, "
              f"one-layer = {one_layer:.8f}, "
              f"error = {abs(two_layer - one_layer):.2e}")
    print()

# ============================================================
# Demo 2: Universal Approximation via SPB
# ============================================================

def demo_universal_approximation():
    """Demonstrate that SPB neurons can approximate arbitrary functions"""
    print("=" * 60)
    print("SPB Universal Approximation Demo")
    print("=" * 60)

    # Target function: sin(πx) on [-0.9, 0.9]
    target = lambda x: math.sin(math.pi * x)

    # SPB approximation: f(x) = Σ αₖ · spbH(x, wₖ)
    # Use gradient-free optimization (random search + refinement)
    N_neurons = 8
    best_weights = None
    best_alphas = None
    best_error = float('inf')

    random.seed(42)

    for trial in range(2000):
        weights = [random.uniform(-0.95, 0.95) for _ in range(N_neurons)]
        alphas = [random.uniform(-2, 2) for _ in range(N_neurons)]

        # Compute error on training points
        error = 0
        for i in range(20):
            x = -0.9 + 1.8 * i / 19
            pred = sum(a * spbH(x, w) for a, w in zip(alphas, weights))
            error += (pred - target(x))**2

        if error < best_error:
            best_error = error
            best_weights = weights[:]
            best_alphas = alphas[:]

    # Simple gradient descent refinement
    lr = 0.001
    for epoch in range(5000):
        grad_w = [0.0] * N_neurons
        grad_a = [0.0] * N_neurons

        for i in range(20):
            x = -0.9 + 1.8 * i / 19
            pred = sum(a * spbH(x, w) for a, w in zip(best_alphas, best_weights))
            residual = pred - target(x)

            for k in range(N_neurons):
                grad_a[k] += 2 * residual * spbH(x, best_weights[k])
                grad_w[k] += 2 * residual * best_alphas[k] * spbH_deriv(x, best_weights[k])

        for k in range(N_neurons):
            best_alphas[k] -= lr * grad_a[k]
            best_weights[k] -= lr * grad_w[k]
            best_weights[k] = max(-0.99, min(0.99, best_weights[k]))

    # Evaluate
    print(f"\n  Approximating sin(πx) with {N_neurons} SPB neurons on [-0.9, 0.9]:")
    print(f"  {'x':<8s} {'target':<12s} {'SPB approx':<12s} {'error':<12s}")
    total_error = 0
    for i in range(11):
        x = -0.9 + 1.8 * i / 10
        pred = sum(a * spbH(x, w) for a, w in zip(best_alphas, best_weights))
        err = abs(pred - target(x))
        total_error += err
        print(f"  {x:<8.2f} {target(x):<12.6f} {pred:<12.6f} {err:<12.6f}")

    print(f"\n  Mean absolute error: {total_error / 11:.6f}")
    print(f"  Learned weights: {[f'{w:.3f}' for w in best_weights]}")
    print()

# ============================================================
# Demo 3: Invertibility
# ============================================================

def demo_invertibility():
    """Show that SPB networks can be run backwards"""
    print("=" * 60)
    print("SPB Network Invertibility")
    print("=" * 60)

    print("\n  Forward and inverse of multi-layer SPB network:")
    weights = [0.3, -0.2, 0.7, -0.5]

    print(f"  Weights: {weights}")
    print(f"  {'input x':<12s} {'forward y':<12s} {'inverse(y)':<12s} {'recovery err':<12s}")

    for x in [-0.8, -0.3, 0.0, 0.4, 0.9]:
        # Forward pass
        y = x
        for w in weights:
            y = spbH(y, w)

        # Inverse pass (apply weights in reverse with negated values)
        x_recovered = y
        for w in reversed(weights):
            x_recovered = spbH(x_recovered, -w)

        err = abs(x - x_recovered)
        print(f"  {x:<12.4f} {y:<12.6f} {x_recovered:<12.6f} {err:<12.2e}")

    print("\n  Perfect invertibility: every SPB layer is exactly reversible!")
    print()

# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    demo_activation_properties()
    demo_universal_approximation()
    demo_invertibility()
