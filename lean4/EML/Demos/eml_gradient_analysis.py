#!/usr/bin/env python3
"""
EML Gradient Analysis
=====================
Analyzes the gradient structure of EML trees for understanding
training dynamics in symbolic regression.

Key findings:
1. EML gradients can explode (exp pathway) or vanish (log pathway)
2. The asymmetry between left and right inputs creates directional bias
3. Complex-valued gradients are essential for training
"""

import numpy as np
from typing import Tuple

def eml(x: complex, y: complex) -> complex:
    """EML operator."""
    return np.exp(x) - np.log(y)

def eml_grad(x: complex, y: complex) -> Tuple[complex, complex]:
    """Analytical gradient of eml(x,y).
    ∂eml/∂x = exp(x)
    ∂eml/∂y = -1/y
    """
    return np.exp(x), -1.0/y

def analyze_gradient_magnitudes():
    """Study how gradient magnitudes vary across the input space."""
    print("=" * 60)
    print("EML GRADIENT MAGNITUDE ANALYSIS")
    print("=" * 60)
    
    print("\n∂eml/∂x = exp(x)  [exponential growth]")
    print("∂eml/∂y = -1/y    [hyperbolic decay]")
    
    print(f"\n{'x':>8} {'|∂/∂x|':>12} {'y':>8} {'|∂/∂y|':>12} {'ratio':>10}")
    print("-" * 55)
    
    test_x = [-2, -1, 0, 1, 2, 5, 10]
    test_y = [0.01, 0.1, 0.5, 1, 2, 5, 10]
    
    for x, y in zip(test_x, test_y):
        dx, dy = eml_grad(complex(x), complex(y))
        ratio = abs(dx) / abs(dy) if abs(dy) > 0 else float('inf')
        print(f"{x:>8.1f} {abs(dx):>12.4f} {y:>8.2f} {abs(dy):>12.4f} {ratio:>10.2f}")

def analyze_chain_gradients():
    """Analyze gradient propagation through chains of EML operations."""
    print("\n" + "=" * 60)
    print("GRADIENT PROPAGATION THROUGH EML CHAINS")
    print("=" * 60)
    
    print("\nFor a chain eml(eml(...eml(x, 1)..., 1), 1) of depth d:")
    print("This computes exp^(d)(x) (iterated exponential)")
    print("The gradient is the product of all intermediate exp values\n")
    
    x0 = 0.5
    
    print(f"Starting value: x₀ = {x0}")
    print(f"{'Depth':>6} {'Value':>20} {'|Gradient|':>20} {'log₁₀|grad|':>14}")
    print("-" * 65)
    
    z = complex(x0)
    grad = complex(1.0)
    
    for d in range(10):
        if abs(z) < 1e100:
            print(f"{d:>6} {z.real:>20.6f} {abs(grad):>20.6e} {np.log10(max(abs(grad), 1e-300)):>14.2f}")
            local_grad = np.exp(z)
            grad *= local_grad
            z = eml(z, 1)  # = exp(z)
        else:
            print(f"{d:>6} {'OVERFLOW':>20} {'OVERFLOW':>20}")
            break
    
    print("\n→ Gradients grow as exp(exp(exp(...))) — faster than any tower!")
    print("  This is why deep EML trees are hard to train.")

def analyze_log_chain_gradients():
    """Analyze gradients through the logarithmic pathway."""
    print("\n" + "=" * 60)
    print("LOGARITHMIC PATHWAY GRADIENTS")
    print("=" * 60)
    
    print("\nFor eml(1, z): gradient w.r.t. z is -1/z")
    print("For a chain eml(1, eml(1, ...eml(1, z)...))")
    print("The gradient involves products of -1/z_i terms\n")
    
    z0 = 2.0
    z = complex(z0)
    grad = complex(1.0)
    
    print(f"Starting: z₀ = {z0}")
    print(f"{'Step':>6} {'z_n':>15} {'|gradient|':>15}")
    print("-" * 40)
    
    for n in range(15):
        if abs(z) > 1e-100 and abs(z) < 1e100:
            print(f"{n:>6} {z.real:>15.8f} {abs(grad):>15.8e}")
            local_grad = -1.0 / z
            grad *= local_grad
            z = eml(1, z)  # = e - ln(z)
        else:
            break
    
    print("\n→ Log-pathway gradients can stabilize or oscillate.")
    print("  This pathway is more trainable than the exp pathway.")

def analyze_master_formula_gradients():
    """Analyze the gradient landscape of a level-2 master formula."""
    print("\n" + "=" * 60)
    print("MASTER FORMULA GRADIENT LANDSCAPE (Level 2)")
    print("=" * 60)
    
    # Level 2 master formula: F(x) = eml(a + bx, c + dx) 
    # where a,b,c,d are softmax selections
    
    # ∂F/∂a = exp(a + bx) · ∂a/∂logit_a
    # ∂F/∂c = -1/(c + dx) · ∂c/∂logit_c
    
    print("\nFor the simplest case F(x) = eml(α·1 + β·x, γ·1 + δ·x):")
    print("∂F/∂α = exp(α + βx)")
    print("∂F/∂β = x · exp(α + βx)")
    print("∂F/∂γ = -1/(γ + δx)")
    print("∂F/∂δ = -x/(γ + δx)")
    
    print("\nGradient condition numbers at various (α,β,γ,δ):")
    print(f"{'config':>20} {'x':>5} {'max|grad|':>12} {'min|grad|':>12} {'cond':>12}")
    print("-" * 65)
    
    configs = [
        ("exp(x): (0,1,1,0)", (0, 1, 1, 0)),
        ("e:      (1,0,1,0)", (1, 0, 1, 0)),
        ("e-ln(x):(1,0,0,1)", (1, 0, 0, 1)),
    ]
    
    for name, (a, b, c, d) in configs:
        for x in [0.5, 1.0, 2.0]:
            grads = [
                abs(np.exp(a + b*x)),           # ∂/∂α
                abs(x * np.exp(a + b*x)),        # ∂/∂β
                abs(-1/(c + d*x)) if (c + d*x) != 0 else float('inf'),  # ∂/∂γ
                abs(-x/(c + d*x)) if (c + d*x) != 0 else float('inf'),  # ∂/∂δ
            ]
            max_g = max(grads)
            min_g = min(g for g in grads if g > 0 and g < float('inf'))
            cond = max_g / min_g if min_g > 0 else float('inf')
            print(f"{name:>20} {x:>5.1f} {max_g:>12.4f} {min_g:>12.4f} {cond:>12.2f}")

def gradient_flow_recommendations():
    """Print recommendations for training EML trees."""
    print("\n" + "=" * 60)
    print("RECOMMENDATIONS FOR TRAINING EML TREES")
    print("=" * 60)
    
    print("""
  1. GRADIENT CLIPPING: Essential. Clamp exp inputs to [-20, 20]
     to prevent gradient explosion through the exponential pathway.
  
  2. LEARNING RATE SCHEDULING: Start with small lr (1e-4) and
     increase gradually. The exp pathway makes large steps dangerous.
  
  3. COMPLEX ARITHMETIC: Use complex128 to avoid precision loss.
     Many EML trees produce large intermediate imaginary parts.
  
  4. INITIALIZATION: Don't start with all zeros — this puts
     everything on the exp(0) = 1 manifold. Use small random
     perturbations around meaningful configurations.
  
  5. TEMPERATURE ANNEALING: In softmax parameterization, start
     with high temperature (soft mixing) and anneal to low
     temperature (hard selection) over training.
  
  6. HIERARCHICAL TRAINING: Train small subtrees first (depth 2),
     then compose them. This breaks the double-exponential
     gradient problem.
  
  7. LOSS FUNCTION: Use log-MSE or relative error instead of MSE.
     EML outputs span many orders of magnitude.
  
  8. REGULARIZATION: Penalize large intermediate values to keep
     the computation in a numerically stable regime.
    """)

def main():
    analyze_gradient_magnitudes()
    analyze_chain_gradients()
    analyze_log_chain_gradients()
    analyze_master_formula_gradients()
    gradient_flow_recommendations()

if __name__ == "__main__":
    main()
