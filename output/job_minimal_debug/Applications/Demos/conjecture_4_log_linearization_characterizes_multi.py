#!/usr/bin/env python3
"""
applications.py — Real-World Applications of Log-Linearization

Demonstrates the log-linearization theorem in practical contexts:
  1. Statistical independence detection (joint vs. product of marginals)
  2. Thermodynamic decoupling (partition functions)
  3. Feature interaction detection (ML-style)
  4. Economics: Cobb-Douglas production functions
"""

import numpy as np
from typing import Callable

# ─────────────────────────────────────────────────────────────
# Utility: Interaction defect computation
# ─────────────────────────────────────────────────────────────

def max_log_interaction_defect(f, x_grid, y_grid):
    """Max |log f(x1,y1) + log f(x2,y2) - log f(x1,y2) - log f(x2,y1)| over grid."""
    n, m = len(x_grid), len(y_grid)
    max_d = 0.0
    for i in range(n):
        for j in range(i + 1, n):
            for k in range(m):
                for l in range(k + 1, m):
                    d = abs(
                        np.log(f(x_grid[i], y_grid[k]))
                        + np.log(f(x_grid[j], y_grid[l]))
                        - np.log(f(x_grid[i], y_grid[l]))
                        - np.log(f(x_grid[j], y_grid[k]))
                    )
                    max_d = max(max_d, d)
    return max_d


# ─────────────────────────────────────────────────────────────
# Application 1: Statistical Independence
# ─────────────────────────────────────────────────────────────

def app_statistical_independence():
    """
    In probability, two positive random variables X, Y are independent iff
    their joint density f(x,y) = g(x)*h(y) — i.e., f is multiplicatively
    separable. The interaction defect detects dependence.
    """
    print("APPLICATION 1: Statistical Independence Detection")
    print("=" * 60)
    print()

    # Independent: f(x,y) = x*exp(-x) * y^2*exp(-y) (product of Gamma-like)
    f_indep = lambda x, y: x * np.exp(-x) * y**2 * np.exp(-y)

    # Dependent: f(x,y) = exp(-(x^2 + y^2 + x*y)) (correlated Gaussian-like)
    f_dep = lambda x, y: np.exp(-(x**2 + y**2 + x * y))

    # Dependent: f(x,y) = exp(-(x-y)^2) * exp(-x) * exp(-y)
    f_dep2 = lambda x, y: np.exp(-(x - y)**2 - x - y)

    grid = np.array([0.5, 1.0, 1.5, 2.0, 3.0, 4.0])

    cases = [
        ("x·e^(-x) · y²·e^(-y)  [independent]", f_indep),
        ("exp(-(x²+y²+xy))      [dependent]", f_dep),
        ("exp(-(x-y)²-x-y)      [dependent]", f_dep2),
    ]

    for name, f in cases:
        defect = max_log_interaction_defect(f, grid, grid)
        status = "INDEPENDENT" if defect < 1e-10 else "DEPENDENT"
        print(f"  {name}")
        print(f"    Defect: {defect:.2e}  →  {status}")
        print()


# ─────────────────────────────────────────────────────────────
# Application 2: Thermodynamic Decoupling
# ─────────────────────────────────────────────────────────────

def app_thermodynamics():
    """
    In statistical mechanics, if the partition function Z(β₁, β₂) of a system
    with two subsystems factorizes as Z₁(β₁)·Z₂(β₂), the subsystems are
    thermodynamically decoupled. The log (= free energy) becomes additive.
    """
    print("APPLICATION 2: Thermodynamic Decoupling")
    print("=" * 60)
    print()

    # Decoupled: Z(β1,β2) = (1+exp(-β1)) * (1+exp(-β2)+exp(-2β2))
    Z_decoupled = lambda b1, b2: (1 + np.exp(-b1)) * (1 + np.exp(-b2) + np.exp(-2*b2))

    # Coupled: Z(β1,β2) = 1 + exp(-β1) + exp(-β2) + exp(-β1-β2-β1*β2)
    Z_coupled = lambda b1, b2: 1 + np.exp(-b1) + np.exp(-b2) + np.exp(-b1 - b2 - b1*b2)

    grid = np.array([0.1, 0.5, 1.0, 2.0, 5.0])

    for name, Z in [
        ("Z₁(β₁)·Z₂(β₂)  [decoupled]", Z_decoupled),
        ("Coupled partition function", Z_coupled),
    ]:
        defect = max_log_interaction_defect(Z, grid, grid)
        status = "DECOUPLED" if defect < 1e-10 else "COUPLED"
        print(f"  {name}")
        print(f"    Defect: {defect:.2e}  →  {status}")
        print()

    print("  Interpretation: log Z = free energy. Additive free energy")
    print("  means no interaction between subsystems.")
    print()


# ─────────────────────────────────────────────────────────────
# Application 3: Feature Interaction in ML
# ─────────────────────────────────────────────────────────────

def app_feature_interaction():
    """
    In machine learning, detecting whether a model's output depends on
    features x, y independently or through their interaction is key.
    A positive response r(x,y) has no feature interaction iff it is
    multiplicatively separable in original coordinates (or additively
    separable in log coordinates).
    """
    print("APPLICATION 3: Feature Interaction Detection (ML)")
    print("=" * 60)
    print()

    # No interaction: r(x,y) = sigmoid(x) * sigmoid(y)
    sigmoid = lambda z: 1 / (1 + np.exp(-z))
    r_no_interact = lambda x, y: sigmoid(x) * sigmoid(y)

    # Interaction present: r(x,y) = sigmoid(x + y + x*y)
    r_interact = lambda x, y: sigmoid(x + y + x * y)

    # Interaction present: r(x,y) = sigmoid(x*y)
    r_interact2 = lambda x, y: sigmoid(x * y)

    grid = np.array([0.1, 0.5, 1.0, 2.0, 3.0, 5.0])

    cases = [
        ("σ(x)·σ(y)        [no interaction]", r_no_interact),
        ("σ(x+y+xy)        [interaction]", r_interact),
        ("σ(xy)            [interaction]", r_interact2),
    ]

    for name, r in cases:
        defect = max_log_interaction_defect(r, grid, grid)
        status = "NO INTERACTION" if defect < 1e-10 else "INTERACTION DETECTED"
        print(f"  {name}")
        print(f"    Defect: {defect:.2e}  →  {status}")
        print()


# ─────────────────────────────────────────────────────────────
# Application 4: Cobb-Douglas Production Functions
# ─────────────────────────────────────────────────────────────

def app_economics():
    """
    The Cobb-Douglas production function Y = A·K^α·L^β is multiplicatively
    separable in capital K and labor L. More general CES functions are not.
    """
    print("APPLICATION 4: Economics — Production Functions")
    print("=" * 60)
    print()

    # Cobb-Douglas: Y = K^0.3 * L^0.7
    cobb_douglas = lambda K, L: K**0.3 * L**0.7

    # CES (Constant Elasticity of Substitution): Y = (α·K^ρ + β·L^ρ)^(1/ρ)
    ces = lambda K, L: (0.3 * K**(-0.5) + 0.7 * L**(-0.5))**(-2)

    # Leontief (fixed proportions): Y = min(K, L) — limit of CES
    leontief = lambda K, L: np.minimum(K, L)

    grid = np.array([0.5, 1.0, 2.0, 3.0, 5.0, 10.0])

    cases = [
        ("Cobb-Douglas K^0.3·L^0.7   [separable]", cobb_douglas),
        ("CES function                [non-separable]", ces),
        ("Leontief min(K,L)           [non-separable]", leontief),
    ]

    for name, f in cases:
        defect = max_log_interaction_defect(f, grid, grid)
        status = "SEPARABLE" if defect < 1e-10 else "NOT SEPARABLE"
        print(f"  {name}")
        print(f"    Defect: {defect:.2e}  →  {status}")
        print()

    print("  Interpretation: Cobb-Douglas assumes independent factor contributions.")
    print("  CES and Leontief have genuine factor interaction.")
    print()


# ─────────────────────────────────────────────────────────────
# Run all applications
# ─────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print()
    print("*" * 65)
    print("  REAL-WORLD APPLICATIONS OF LOG-LINEARIZATION")
    print("*" * 65)
    print()

    app_statistical_independence()
    print()
    app_thermodynamics()
    print()
    app_feature_interaction()
    print()
    app_economics()

    print("*" * 65)
    print("  ALL APPLICATIONS COMPLETE")
    print("*" * 65)


#!/usr/bin/env python3
"""
demo.py — Interaction Detection via Log-Linearization

Demonstrates the core theorem computationally:
  - A multiplicatively separable function has zero interaction defect.
  - A non-separable function like (x+y)^2 has nonzero defect.
  - Fits u(s) + v(t) to log f(e^s, e^t) and visualizes residuals.
"""

import numpy as np
import warnings
warnings.filterwarnings("ignore")

# ─────────────────────────────────────────────────────────────
# 1. Interaction Defect Computation
# ─────────────────────────────────────────────────────────────

def log_interaction_defect(f, x1, x2, y1, y2):
    """Compute log interaction defect:
    log f(x1,y1) + log f(x2,y2) - log f(x1,y2) - log f(x2,y1)
    For multiplicatively separable f, this is exactly 0.
    """
    return (np.log(f(x1, y1)) + np.log(f(x2, y2))
            - np.log(f(x1, y2)) - np.log(f(x2, y1)))


def max_defect_on_grid(f, grid):
    """Compute maximum absolute log interaction defect over all 4-tuples from grid."""
    n = len(grid)
    max_d = 0.0
    for i in range(n):
        for j in range(i+1, n):
            for k in range(n):
                for l in range(k+1, n):
                    d = abs(log_interaction_defect(f, grid[i], grid[j], grid[k], grid[l]))
                    max_d = max(max_d, d)
    return max_d


# ─────────────────────────────────────────────────────────────
# 2. Test Functions
# ─────────────────────────────────────────────────────────────

def separable_monomial(x, y):
    """f(x,y) = x^2 * y^3 — multiplicatively separable."""
    return x**2 * y**3

def non_separable_add_sq(x, y):
    """f(x,y) = (x + y)^2 — NOT multiplicatively separable."""
    return (x + y)**2

def separable_exp(x, y):
    """f(x,y) = exp(x) * exp(y^2) — multiplicatively separable."""
    return np.exp(x) * np.exp(y**2)

def non_separable_product_sum(x, y):
    """f(x,y) = x*y + 1 — NOT multiplicatively separable on positives."""
    return x * y + 1


# ─────────────────────────────────────────────────────────────
# 3. Run Tests
# ─────────────────────────────────────────────────────────────

print("=" * 65)
print("  LOG-LINEARIZATION INTERACTION DETECTION DEMO")
print("=" * 65)
print()

grid = np.array([0.5, 1.0, 1.5, 2.0, 3.0, 4.0, 5.0])

test_cases = [
    ("x^2 * y^3 (separable)", separable_monomial, True),
    ("(x + y)^2 (non-separable)", non_separable_add_sq, False),
    ("exp(x) * exp(y^2) (separable)", separable_exp, True),
    ("x*y + 1 (non-separable)", non_separable_product_sum, False),
]

print("Testing max |log interaction defect| on grid [0.5, 1, 1.5, 2, 3, 4, 5]:")
print("-" * 65)

for name, f, expected_sep in test_cases:
    defect = max_defect_on_grid(f, grid)
    status = "SEPARABLE" if defect < 1e-10 else "NOT SEPARABLE"
    correct = "✓" if (defect < 1e-10) == expected_sep else "✗"
    print(f"  {correct} {name}")
    print(f"    Max defect: {defect:.2e}  →  {status}")
    print()

# ─────────────────────────────────────────────────────────────
# 4. Explicit cross-ratio failure for (x+y)^2
# ─────────────────────────────────────────────────────────────

print("-" * 65)
print("Cross-ratio failure for (x+y)^2 at (x1,x2,y1,y2) = (1,2,1,2):")
f = non_separable_add_sq
lhs = f(1, 1) * f(2, 2)  # 4 * 16 = 64
rhs = f(1, 2) * f(2, 1)  # 9 * 9 = 81
print(f"  f(1,1)*f(2,2) = {lhs}")
print(f"  f(1,2)*f(2,1) = {rhs}")
print(f"  Ratio (interaction defect) = {lhs/rhs:.6f}")
print(f"  These are NOT equal → (x+y)^2 is not multiplicatively separable.")
print()

# ─────────────────────────────────────────────────────────────
# 5. Log-additive separability fitting
# ─────────────────────────────────────────────────────────────

print("-" * 65)
print("Fitting log f(e^s, e^t) = u(s) + v(t) for f(x,y) = x^2 * y^3:")
print()

s_vals = np.linspace(-2, 2, 20)
t_vals = np.linspace(-2, 2, 20)
S, T = np.meshgrid(s_vals, t_vals)

# G(s,t) = log(f(e^s, e^t)) = log((e^s)^2 * (e^t)^3) = 2s + 3t
G = np.log(separable_monomial(np.exp(S), np.exp(T)))

# Fit: G(s,t) ≈ u(s) + v(t) via row/column means
row_mean = G.mean(axis=1, keepdims=True)  # average over t → estimate of u(s) + const
col_mean = G.mean(axis=0, keepdims=True)  # average over s → estimate of v(t) + const
grand_mean = G.mean()
G_fit = row_mean + col_mean - grand_mean
residual = np.abs(G - G_fit).max()

print(f"  Max |residual| of additive fit: {residual:.2e}")
print(f"  (Should be ~0 for separable functions)")
print()

# Same for (x+y)^2
G2 = np.log(non_separable_add_sq(np.exp(S), np.exp(T)))
row_mean2 = G2.mean(axis=1, keepdims=True)
col_mean2 = G2.mean(axis=0, keepdims=True)
grand_mean2 = G2.mean()
G2_fit = row_mean2 + col_mean2 - grand_mean2
residual2 = np.abs(G2 - G2_fit).max()

print(f"Fitting log f(e^s, e^t) = u(s) + v(t) for f(x,y) = (x+y)^2:")
print(f"  Max |residual| of additive fit: {residual2:.2e}")
print(f"  (Should be large for non-separable functions)")
print()

# ─────────────────────────────────────────────────────────────
# 6. Stability test: perturbed separable function
# ─────────────────────────────────────────────────────────────

print("-" * 65)
print("Stability test: f(x,y) = x^2 * y^3 * (1 + ε*sin(xy))")
print()

for eps in [0.0, 0.01, 0.1, 0.5]:
    f_perturbed = lambda x, y, e=eps: x**2 * y**3 * (1 + e * np.sin(x * y))
    defect = max_defect_on_grid(f_perturbed, grid)
    print(f"  ε = {eps:.2f}:  max defect = {defect:.4e}")

print()
print("=" * 65)
print("  DEMO COMPLETE")
print("=" * 65)
