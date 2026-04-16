#!/usr/bin/env python3
"""
EML Neural Network: Neural networks with EML activation

Demonstrates the concept of replacing standard neural network
activation functions with EML trees for interpretable symbolic
computation.
"""

import math
import cmath
import random
from typing import List, Tuple

# ============================================================
# EML-based Neuron
# ============================================================

class EMLNeuron:
    """A neuron that computes eml(w1*input + b1, w2*input + b2).

    Instead of the standard σ(w·x + b), this neuron computes
    exp(w1*x + b1) - ln(w2*x + b2), which is an EML operation
    on affine transformations of the input.
    """

    def __init__(self, input_dim: int = 1):
        self.input_dim = input_dim
        # Parameters for the left (exp) branch
        self.w1 = [random.gauss(0, 0.1) for _ in range(input_dim)]
        self.b1 = random.gauss(0, 0.1)
        # Parameters for the right (log) branch
        self.w2 = [random.gauss(0, 0.1) for _ in range(input_dim)]
        self.b2 = 1.0  # Start positive to keep log defined

    def forward(self, x: List[float]) -> complex:
        """Compute the neuron output."""
        left = sum(w * xi for w, xi in zip(self.w1, x)) + self.b1
        right = sum(w * xi for w, xi in zip(self.w2, x)) + self.b2
        try:
            return cmath.exp(left) - cmath.log(right)
        except (ValueError, OverflowError):
            return complex(float('nan'))

    def symbolic_expr(self, var_names: List[str] = None) -> str:
        """Return symbolic expression."""
        if var_names is None:
            var_names = [f'x{i}' for i in range(self.input_dim)]

        left_parts = []
        for w, name in zip(self.w1, var_names):
            if abs(w) > 1e-10:
                left_parts.append(f"{w:.3f}*{name}")
        left = " + ".join(left_parts) if left_parts else "0"
        if abs(self.b1) > 1e-10:
            left += f" + {self.b1:.3f}"

        right_parts = []
        for w, name in zip(self.w2, var_names):
            if abs(w) > 1e-10:
                right_parts.append(f"{w:.3f}*{name}")
        right = " + ".join(right_parts) if right_parts else "0"
        if abs(self.b2) > 1e-10:
            right += f" + {self.b2:.3f}"

        return f"exp({left}) - ln({right})"


class EMLLayer:
    """A layer of EML neurons."""

    def __init__(self, input_dim: int, num_neurons: int):
        self.neurons = [EMLNeuron(input_dim) for _ in range(num_neurons)]

    def forward(self, x: List[float]) -> List[complex]:
        return [n.forward(x) for n in self.neurons]


class EMLNetwork:
    """A simple feedforward network with EML neurons."""

    def __init__(self, architecture: List[int]):
        """architecture: list of layer sizes, e.g., [1, 4, 4, 1]"""
        self.layers = []
        for i in range(len(architecture) - 1):
            self.layers.append(EMLLayer(architecture[i], architecture[i + 1]))

    def forward(self, x: List[float]) -> List[complex]:
        current = x
        for layer in self.layers:
            outputs = layer.forward([c.real if isinstance(c, complex) else c
                                    for c in current])
            current = outputs
        return current


# ============================================================
# Demonstration
# ============================================================

def demo_eml_neuron():
    """Demonstrate a single EML neuron."""
    print("=" * 60)
    print("EML NEURON DEMO")
    print("=" * 60)

    # Create a neuron that computes exp(x) - ln(1) = exp(x)
    neuron = EMLNeuron(input_dim=1)
    neuron.w1 = [1.0]
    neuron.b1 = 0.0
    neuron.w2 = [0.0]
    neuron.b2 = 1.0  # ln(1) = 0

    print("\nNeuron configured as exp(x):")
    print(f"  Expression: {neuron.symbolic_expr(['x'])}")
    for x_val in [0, 0.5, 1.0, 2.0]:
        result = neuron.forward([x_val])
        expected = math.exp(x_val)
        print(f"  f({x_val}) = {result.real:.6f} (expected {expected:.6f})")

    # Create a neuron that approximates x^2
    # x^2 = exp(2*ln(x)), but we can't do this directly
    # Instead, show that EML neurons can learn various shapes
    print("\nRandom EML neuron outputs:")
    random.seed(42)
    rand_neuron = EMLNeuron(input_dim=1)
    print(f"  Expression: {rand_neuron.symbolic_expr(['x'])}")
    for x_val in [0.5, 1.0, 1.5, 2.0]:
        result = rand_neuron.forward([x_val])
        if not cmath.isnan(result):
            print(f"  f({x_val}) = {result.real:.6f}")
        else:
            print(f"  f({x_val}) = undefined")


def demo_interpretability():
    """Show how EML networks provide interpretability."""
    print("\n" + "=" * 60)
    print("EML NETWORK INTERPRETABILITY")
    print("=" * 60)

    print("\nKey insight: Every trained EML neuron has a closed-form expression.")
    print("Unlike ReLU/sigmoid networks, we can read off the learned formula.\n")

    # Example: a 2-layer network for exp(x)
    print("Example: Single EML neuron learns exp(x)")
    print("  Architecture: 1 → 1")
    print("  Learned: exp(1.0*x + 0.0) - ln(0.0*x + 1.0)")
    print("         = exp(x) - 0 = exp(x)")

    print("\nExample: Two EML neurons composing to get exp(exp(x))")
    print("  Architecture: 1 → 1 → 1")
    print("  Layer 1: exp(x) - ln(1) = exp(x)")
    print("  Layer 2: exp(exp(x)) - ln(1) = exp(exp(x))")

    print("\nAdvantages over standard neural networks:")
    print("  1. Every neuron has a symbolic formula")
    print("  2. Composition is transparent")
    print("  3. Universal approximation via EML completeness")
    print("  4. Natural connection to KAN (Kolmogorov-Arnold Networks)")

    print("\nChallenges:")
    print("  1. exp can overflow during training")
    print("  2. log requires positive arguments")
    print("  3. Complex arithmetic overhead for trig functions")
    print("  4. Non-convex loss landscape")


def demo_comparison_to_kan():
    """Compare EML networks to KAN networks."""
    print("\n" + "=" * 60)
    print("EML vs KAN COMPARISON")
    print("=" * 60)

    comparison = [
        ("Activation", "Learned B-splines", "eml(x,y) = exp(x) - ln(y)"),
        ("Interpretability", "Moderate (spline shapes)", "High (closed-form formulas)"),
        ("Universality", "Universal approx.", "Exact for elementary funcs"),
        ("# Parameters", "O(G²kL)", "O(2^L) per tree"),
        ("Training", "Standard backprop", "Gradient + combinatorial"),
        ("Complex numbers", "Not native", "Essential for trig"),
        ("Theory basis", "Kolmogorov-Arnold", "Sheffer stroke / magma"),
    ]

    print(f"\n{'Property':20s} {'KAN':30s} {'EML Network':30s}")
    print("-" * 80)
    for prop, kan, eml_net in comparison:
        print(f"{prop:20s} {kan:30s} {eml_net:30s}")


if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════╗")
    print("║        EML NEURAL NETWORK DEMONSTRATION                 ║")
    print("╚══════════════════════════════════════════════════════════╝")

    demo_eml_neuron()
    demo_interpretability()
    demo_comparison_to_kan()

    print("\n" + "=" * 60)
    print("Demo complete.")
    print("=" * 60)
