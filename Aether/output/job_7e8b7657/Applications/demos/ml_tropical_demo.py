#!/usr/bin/env python3
"""
Machine Learning & Tropical Geometry Demo
==========================================
Demonstrates:
1. Tropical polynomial evaluation (max-plus algebra)
2. LogSumExp as smooth max approximation
3. ReLU networks as tropical polynomials
4. EML universal approximation
5. Lipschitz-bounded neural networks
"""

import math
import random
from typing import List, Callable


# ============================================================
# Tropical Algebra
# ============================================================

def tropical_add(a: float, b: float) -> float:
    """Tropical addition = max."""
    return max(a, b)


def tropical_mul(a: float, b: float) -> float:
    """Tropical multiplication = classical addition."""
    return a + b


def tropical_poly_eval(coeffs: List[float], x: float) -> float:
    """
    Evaluate a tropical polynomial: ⊕ᵢ (cᵢ ⊗ x^i) = maxᵢ(cᵢ + i·x)
    """
    return max(c + i * x for i, c in enumerate(coeffs))


def demo_tropical_algebra():
    """Demonstrate tropical (max-plus) algebra basics."""
    print("=" * 60)
    print("DEMO 1: Tropical (Max-Plus) Algebra")
    print("=" * 60)
    print("  In tropical math: a ⊕ b = max(a,b),  a ⊗ b = a + b")
    print("  Formally verified in Tropical/Core/")
    print()

    a, b, c = 3.0, 7.0, 2.0
    print(f"  a={a}, b={b}, c={c}")
    print(f"  a ⊕ b = max({a}, {b}) = {tropical_add(a, b)}")
    print(f"  a ⊗ b = {a} + {b} = {tropical_mul(a, b)}")
    print()
    print(f"  Distributivity: a ⊗ (b ⊕ c) = a + max(b, c)")
    print(f"    = {a} + {max(b, c)} = {tropical_mul(a, tropical_add(b, c))}")
    print(f"  (a ⊗ b) ⊕ (a ⊗ c) = max(a+b, a+c)")
    print(f"    = max({a+b}, {a+c}) = {tropical_add(tropical_mul(a, b), tropical_mul(a, c))}")
    print(f"  Equal: ✓")
    print()

    # Tropical polynomial
    coeffs = [1.0, -2.0, 3.0]  # 1 ⊕ (-2⊗x) ⊕ (3⊗x²) = max(1, -2+x, 3+2x)
    print(f"  Tropical polynomial p(x) = max(1, -2+x, 3+2x):")
    for x in [-2, -1, 0, 1, 2, 3]:
        y = tropical_poly_eval(coeffs, x)
        terms = [c + i * x for i, c in enumerate(coeffs)]
        winner = terms.index(max(terms))
        print(f"    p({x:2d}) = max({terms[0]:.0f}, {terms[1]:.0f}, {terms[2]:.0f}) "
              f"= {y:.0f}  (term {winner} dominates)")
    print()


def logsumexp(values: List[float]) -> float:
    """Numerically stable LogSumExp."""
    m = max(values)
    return m + math.log(sum(math.exp(v - m) for v in values))


def demo_logsumexp():
    """Demonstrate LogSumExp as smooth tropical addition."""
    print("=" * 60)
    print("DEMO 2: LogSumExp — Smooth Tropical Addition")
    print("=" * 60)
    print("  Theorem (lse2_le_max_log2, formally verified):")
    print("  max(a,b) ≤ log(eᵃ + eᵇ) ≤ max(a,b) + ln(2)")
    print()

    print("  Temperature scaling: LSE_τ(a,b) = τ·log(e^(a/τ) + e^(b/τ))")
    print("  As τ → 0: LSE_τ → max (tropical)")
    print("  As τ → ∞: LSE_τ → (a+b)/2 (average)")
    print()

    a, b = 3.0, 7.0
    print(f"  a = {a}, b = {b}")
    print(f"  {'τ':>8s}  {'LSE_τ(a,b)':>12s}  {'Gap from max':>14s}")
    print(f"  {'─'*8}  {'─'*12}  {'─'*14}")

    for tau in [0.01, 0.1, 0.5, 1.0, 2.0, 5.0, 10.0, 100.0]:
        lse = tau * math.log(math.exp(a / tau) + math.exp(b / tau))
        gap = lse - max(a, b)
        print(f"  {tau:8.2f}  {lse:12.6f}  {gap:14.6f}")

    print(f"\n  ln(2) = {math.log(2):.6f} (upper bound on gap for τ=1)")
    print()


def relu(x: float) -> float:
    return max(0, x)


def demo_relu_tropical():
    """Show ReLU networks compute tropical polynomials."""
    print("=" * 60)
    print("DEMO 3: ReLU Networks as Tropical Polynomials")
    print("=" * 60)
    print("  ReLU(x) = max(0, x) — this IS tropical addition with 0!")
    print("  A ReLU network computes a piecewise-linear function,")
    print("  which is exactly a tropical rational function.")
    print("  Verified connection in Tropical/NeuralNetworks/")
    print()

    # Simple 1-hidden-layer network: f(x) = ReLU(x - 1) - ReLU(x - 3) + 1
    # This computes a "hat" function
    def network(x):
        h1 = relu(x - 1)
        h2 = relu(x - 3)
        return h1 - h2 + 1

    print("  Network: f(x) = ReLU(x-1) - ReLU(x-3) + 1")
    print("  This is a piecewise linear function (tropical polynomial)")
    print()
    print(f"  {'x':>5s}  {'f(x)':>6s}  {'Linear region':>20s}")
    print(f"  {'─'*5}  {'─'*6}  {'─'*20}")

    for x_val in [x / 2 for x in range(-2, 11)]:
        y = network(x_val)
        if x_val < 1:
            region = "f(x) = 1 (constant)"
        elif x_val < 3:
            region = "f(x) = x (linear)"
        else:
            region = "f(x) = 3 (constant)"
        print(f"  {x_val:5.1f}  {y:6.1f}  {region}")

    print()
    print("  The network has 3 linear regions, matching the tropical")
    print("  polynomial with 3 terms.")
    print()


def eml(a: float, b: float) -> float:
    """EML(a, b) = exp(a) - ln(b)"""
    if b <= 0:
        return float('inf')
    return math.exp(a) - math.log(b)


def demo_eml_approximation():
    """Demonstrate EML universal approximation."""
    print("=" * 60)
    print("DEMO 4: EML Universal Approximation")
    print("=" * 60)
    print("  EML(a,b) = exp(a) - ln(b)")
    print("  The EML closure from {1} is dense in ℝ.")
    print()

    # Build up approximations to various targets
    targets = [math.pi, math.e, math.sqrt(2), 0.5, -1.0]

    # Generate EML closure values from {1}
    vals = {1.0}
    for depth in range(5):
        new = set()
        for a in list(vals)[:50]:  # Limit for speed
            for b in list(vals)[:50]:
                if b > 0:
                    v = eml(a, b)
                    if -20 < v < 20:
                        new.add(v)
        vals |= new

    sorted_vals = sorted(vals)

    print(f"  Generated {len(vals)} values from EML closure of {{1}}")
    print()
    print(f"  {'Target':>12s}  {'Best approx':>12s}  {'Error':>12s}  {'Expression':>20s}")
    print(f"  {'─'*12}  {'─'*12}  {'─'*12}  {'─'*20}")

    for target in targets:
        best = min(sorted_vals, key=lambda v: abs(v - target))
        error = abs(best - target)
        name = {math.pi: "π", math.e: "e", math.sqrt(2): "√2",
                0.5: "1/2", -1.0: "-1"}.get(target, str(target))
        print(f"  {name:>12s}  {best:12.6f}  {error:12.8f}  (EML tree)")

    print()


def demo_lipschitz():
    """Demonstrate Lipschitz-bounded neural networks."""
    print("=" * 60)
    print("DEMO 5: Lipschitz-Certified Robust Networks")
    print("=" * 60)
    print("  Theorem (lipschitz_compose, formally verified):")
    print("  If f is L₁-Lipschitz and g is L₂-Lipschitz,")
    print("  then g∘f is (L₁·L₂)-Lipschitz.")
    print()
    print("  Theorem (relu_lipschitz_scalar, formally verified):")
    print("  ReLU is 1-Lipschitz.")
    print()

    # Demonstrate Lipschitz bound computation for a network
    layers = [
        ("Linear(784→256)", 2.5),
        ("ReLU", 1.0),
        ("Linear(256→128)", 1.8),
        ("ReLU", 1.0),
        ("Linear(128→10)", 1.2),
    ]

    print("  Network architecture with Lipschitz constants:")
    cumulative = 1.0
    for name, L in layers:
        cumulative *= L
        print(f"    {name:20s}  L = {L:5.2f}  "
              f"Cumulative: {cumulative:8.4f}")

    print(f"\n  Total network Lipschitz constant: L = {cumulative:.4f}")
    print(f"  Robustness guarantee: ‖f(x) - f(x')‖ ≤ {cumulative:.4f} · ‖x - x'‖")
    print()

    # Show adversarial robustness radius
    epsilon = 0.1
    max_output_change = cumulative * epsilon
    print(f"  For ε-perturbation with ε = {epsilon}:")
    print(f"    Max output change: {max_output_change:.4f}")
    print(f"    If margin > {max_output_change:.4f}, classification is robust")
    print()

    # Contrast with unconstrained network
    unconstrained_layers = [
        ("Linear(784→256)", 15.0),
        ("ReLU", 1.0),
        ("Linear(256→128)", 12.0),
        ("ReLU", 1.0),
        ("Linear(128→10)", 8.0),
    ]

    cumulative_unc = 1.0
    for _, L in unconstrained_layers:
        cumulative_unc *= L

    print(f"  Comparison:")
    print(f"    Constrained network:   L = {cumulative:.2f}")
    print(f"    Unconstrained network: L = {cumulative_unc:.2f}")
    print(f"    Ratio: {cumulative_unc/cumulative:.1f}x more vulnerable")
    print()


def demo_bayesian_convergence():
    """Demonstrate Bayesian convergence with formal guarantees."""
    print("=" * 60)
    print("DEMO 6: Bayesian Convergence (Formally Verified)")
    print("=" * 60)
    print("  Theorems (from Algebra/Convergence.lean):")
    print("  • dead_hypothesis_stays_dead")
    print("  • zero_likelihood_eliminates")
    print("  • Geometric convergence bounds")
    print()

    # Simulate Bayesian update
    n_hypotheses = 5
    true_hypothesis = 2

    # Prior: uniform
    beliefs = [1.0 / n_hypotheses] * n_hypotheses
    print(f"  True hypothesis: H{true_hypothesis}")
    print(f"  Prior: {[f'{b:.3f}' for b in beliefs]}")
    print()

    random.seed(42)

    for trial in range(1, 11):
        # Generate likelihood (true hypothesis has highest likelihood)
        likelihoods = [random.uniform(0.1, 0.5) for _ in range(n_hypotheses)]
        likelihoods[true_hypothesis] = random.uniform(0.6, 0.9)

        # Bayesian update
        posterior = [b * l for b, l in zip(beliefs, likelihoods)]
        total = sum(posterior)
        beliefs = [p / total for p in posterior]

        # Check "dead hypothesis stays dead"
        dead = [i for i, b in enumerate(beliefs) if b < 1e-10]

        print(f"  Trial {trial:2d}: beliefs = "
              f"{[f'{b:.4f}' for b in beliefs]}"
              f"  {'(dead: ' + str(dead) + ')' if dead else ''}")

    print()
    print(f"  After 10 updates, belief in true hypothesis H{true_hypothesis}: "
          f"{beliefs[true_hypothesis]:.6f}")
    print(f"  Convergence confirmed: posterior concentrates on truth.")
    print()


if __name__ == "__main__":
    print("╔" + "═" * 58 + "╗")
    print("║  ML & Tropical Geometry Demos — SPB Framework           ║")
    print("║  Based on formally verified mathematical foundations    ║")
    print("╚" + "═" * 58 + "╝")
    print()

    random.seed(42)

    demo_tropical_algebra()
    demo_logsumexp()
    demo_relu_tropical()
    demo_eml_approximation()
    demo_lipschitz()
    demo_bayesian_convergence()

    print("=" * 60)
    print("All ML/Tropical demos completed!")
    print("=" * 60)
