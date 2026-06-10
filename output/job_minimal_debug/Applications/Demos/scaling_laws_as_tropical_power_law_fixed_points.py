#!/usr/bin/env python3
"""
Applications of Tropical Scaling Laws

Real-world applications demonstrating how tropical geometry
provides rigorous tools for analyzing neural network scaling:

1. Chinchilla-style compute-optimal training
2. Emergent capability threshold prediction
3. Multi-regime scaling diagnostics
4. Resource allocation under budget constraints
"""

import numpy as np
from typing import Tuple, List, Dict


def tropical_loss(a: float, b: float, c: float,
                  A: float, B: float, C: float,
                  x: float, y: float, z: float) -> float:
    """Tropical scaling loss T(x,y,z) = min(A+ax, B+by, C+cz)."""
    return min(A + a * x, min(B + b * y, C + c * z))


# ============================================================
# Application 1: Chinchilla-Style Compute-Optimal Training
# ============================================================

def chinchilla_optimal_allocation():
    """
    Demonstrate compute-optimal training using tropical geometry.

    The Chinchilla insight (Hoffmann et al., 2022) is that for a fixed
    compute budget C = 6*N*D, there exists an optimal ratio N/D.
    In tropical geometry, this becomes: along the constraint z = x + y
    in log-space, find the point where the loss is minimized.

    The tropical framework makes this exact: the optimal point is where
    two regime terms are equal (a corner of the constrained tropical loss).
    """
    print("=" * 70)
    print("APPLICATION 1: Compute-Optimal Training (Chinchilla Analysis)")
    print("=" * 70)

    # Empirical scaling exponents (approximately from Kaplan et al.)
    # L ~ N^(-0.076) for parameters, L ~ D^(-0.095) for data
    # In log-coordinates: loss ≈ A - 0.076 * log(N) or B - 0.095 * log(D)
    a = -0.076  # parameter scaling exponent
    b = -0.095  # data scaling exponent
    c = -0.050  # compute scaling exponent (combined)
    A = 0.0     # normalized intercepts
    B = 0.5
    C = 1.0

    print(f"\nScaling exponents: α_N={a}, α_D={b}, α_C={c}")
    print(f"Intercepts: A={A}, B={B}, C={C}")
    print(f"\nCompute constraint: log(C) = log(N) + log(D)  [C ∝ N·D]")

    print(f"\n{'log(N)':>8} {'log(D)':>8} {'log(C)':>8} {'Loss':>10} {'Regime':>12}")
    print("-" * 52)

    # Sweep the N/D ratio for fixed total compute
    total_compute = 30.0  # log(C)

    best_loss = float('inf')
    best_split = None

    for ratio in np.linspace(0.1, 0.9, 17):
        x = ratio * total_compute       # log(N)
        y = (1 - ratio) * total_compute  # log(D)
        z = x + y                        # log(C)
        loss = tropical_loss(a, b, c, A, B, C, x, y, z)

        f_n = A + a * x
        f_d = B + b * y
        f_c = C + c * z
        regime = "N" if f_n <= f_d and f_n <= f_c else \
                 "D" if f_d <= f_n and f_d <= f_c else "C"

        print(f"{x:8.2f} {y:8.2f} {z:8.2f} {loss:10.4f} {regime:>12}")

        if loss < best_loss:
            best_loss = loss
            best_split = (x, y, z, ratio)

    print(f"\nOptimal split: {best_split[3]*100:.1f}% params, "
          f"{(1-best_split[3])*100:.1f}% data")
    print(f"Optimal loss: {best_loss:.4f}")

    # Find the exact corner (N-D boundary)
    # A + a*x = B + b*y, with x + y = total_compute
    # A + a*x = B + b*(total_compute - x)
    # x = (B + b*total_compute - A) / (a - b)
    if abs(a - b) > 1e-15:
        x_corner = (B + b * total_compute - A) / (a - b)
        y_corner = total_compute - x_corner
        loss_corner = tropical_loss(a, b, c, A, B, C, x_corner, y_corner,
                                    x_corner + y_corner)
        print(f"\nExact N-D corner: log(N)={x_corner:.4f}, log(D)={y_corner:.4f}")
        print(f"Corner loss: {loss_corner:.4f}")
        print(f"N/D ratio at corner: {x_corner/y_corner:.4f}")


# ============================================================
# Application 2: Emergent Capability Prediction
# ============================================================

def emergent_capability_prediction():
    """
    Predict when emergent capabilities appear using tropical corners.

    Key insight: emergent capabilities correspond to crossing a loss threshold τ.
    In tropical geometry, the threshold surface T(x,y,z) = τ is a tropical
    hyperplane. The intersection of this surface with the compute constraint
    gives the critical model size.

    Phase transitions (corners) are where the binding constraint switches
    from one resource to another — this is where capabilities appear to
    "emerge suddenly" because the effective scaling exponent changes.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 2: Emergent Capability Prediction")
    print("=" * 70)

    a, b, c = -0.076, -0.095, -0.050
    A, B, C = 0.0, 0.5, 1.0

    # Capability thresholds
    thresholds = {
        "Basic language": -0.5,
        "Few-shot learning": -1.5,
        "Chain-of-thought": -2.5,
        "Complex reasoning": -3.5,
    }

    print(f"\n{'Capability':<25} {'τ':>6} {'log(N_min)':>12} {'N_min':>15}")
    print("-" * 62)

    for capability, tau in thresholds.items():
        # Minimum N to reach threshold (in N-limited regime)
        if abs(a) > 1e-15:
            x_min = (tau - A) / a
            n_min = np.exp(x_min)
            print(f"{capability:<25} {tau:6.1f} {x_min:12.2f} {n_min:15.0f}")

    print("\n--- Phase Transition Analysis ---")
    print("As compute increases, the binding constraint shifts:")

    for z in [10, 20, 30, 40, 50]:
        # Which regime dominates?
        x = z * 0.4  # assume 40% goes to params
        y = z * 0.6  # 60% to data
        f_n = A + a * x
        f_d = B + b * y
        f_c = C + c * z
        dominant = "Parameters" if f_n <= f_d and f_n <= f_c else \
                   "Data" if f_d <= f_n and f_d <= f_c else "Compute"
        loss = min(f_n, f_d, f_c)
        print(f"  log(C)={z:3d}: Loss={loss:.3f}, Binding constraint: {dominant}")


# ============================================================
# Application 3: Multi-Model Scaling Diagnostics
# ============================================================

def scaling_diagnostics():
    """
    Diagnose scaling behavior of a model family.

    Given a series of models at different scales, determine:
    1. Which scaling regime each model is in
    2. Whether the training is data-limited or parameter-limited
    3. The distance to the nearest phase boundary
    """
    print("\n" + "=" * 70)
    print("APPLICATION 3: Multi-Model Scaling Diagnostics")
    print("=" * 70)

    a, b, c = -0.076, -0.095, -0.050
    A, B, C = 0.0, 0.5, 1.0

    # Simulated model family (GPT-style)
    models = [
        {"name": "Small",  "params": 1e8,  "data": 1e9,  "compute": 1e17},
        {"name": "Medium", "params": 1e9,  "data": 2e10, "compute": 1e19},
        {"name": "Large",  "params": 1e10, "data": 3e11, "compute": 1e21},
        {"name": "XL",     "params": 1e11, "data": 5e12, "compute": 1e23},
        {"name": "XXL",    "params": 1e12, "data": 1e13, "compute": 1e25},
    ]

    print(f"\n{'Model':<8} {'Params':>10} {'Data':>10} {'Compute':>10} "
          f"{'Loss':>8} {'Regime':>12} {'Dist to Corner':>16}")
    print("-" * 78)

    for model in models:
        x = np.log(model["params"])
        y = np.log(model["data"])
        z = np.log(model["compute"])

        f_n = A + a * x
        f_d = B + b * y
        f_c = C + c * z
        loss = min(f_n, f_d, f_c)

        # Regime
        if f_n <= f_d and f_n <= f_c:
            regime = "Param-limited"
            dist = min(abs(f_n - f_d), abs(f_n - f_c))
        elif f_d <= f_n and f_d <= f_c:
            regime = "Data-limited"
            dist = min(abs(f_d - f_n), abs(f_d - f_c))
        else:
            regime = "Compute-lim"
            dist = min(abs(f_c - f_n), abs(f_c - f_d))

        print(f"{model['name']:<8} {model['params']:10.0e} {model['data']:10.0e} "
              f"{model['compute']:10.0e} {loss:8.3f} {regime:>12} {dist:16.4f}")


# ============================================================
# Application 4: Budget-Constrained Resource Allocation
# ============================================================

def budget_allocation():
    """
    Optimal resource allocation under a total budget constraint.

    Given dollar costs per unit of parameters, data, and compute,
    and a total budget, find the allocation that minimizes loss.

    This is a tropical linear programming problem:
        minimize  T(x, y, z) = min(A+ax, B+by, C+cz)
        subject to  p_x * e^x + p_y * e^y + p_z * e^z ≤ Budget
    """
    print("\n" + "=" * 70)
    print("APPLICATION 4: Budget-Constrained Resource Allocation")
    print("=" * 70)

    a, b, c = -0.076, -0.095, -0.050
    A, B, C = 0.0, 0.5, 1.0

    # Cost per unit in each dimension (simplified)
    cost_per_param = 1e-6    # $ per parameter (training cost)
    cost_per_token = 1e-8    # $ per training token
    cost_per_flop = 1e-18    # $ per FLOP

    budgets = [1e6, 1e7, 1e8, 1e9, 1e10]

    print(f"\n{'Budget ($)':>12} {'Params':>12} {'Tokens':>12} {'FLOPs':>12} "
          f"{'Loss':>8} {'Regime':>14}")
    print("-" * 74)

    for budget in budgets:
        # Simplified: allocate budget equally, then optimize
        # In practice, this would use the tropical LP structure
        param_budget = budget * 0.3
        data_budget = budget * 0.2
        compute_budget = budget * 0.5

        n = param_budget / cost_per_param
        d = data_budget / cost_per_token
        flops = compute_budget / cost_per_flop

        x = np.log(max(n, 1))
        y = np.log(max(d, 1))
        z = np.log(max(flops, 1))

        f_n = A + a * x
        f_d = B + b * y
        f_c = C + c * z
        loss = min(f_n, f_d, f_c)

        regime = "Param-limited" if f_n <= f_d and f_n <= f_c else \
                 "Data-limited" if f_d <= f_n and f_d <= f_c else "Compute-lim"

        print(f"{budget:12.0e} {n:12.2e} {d:12.2e} {flops:12.2e} "
              f"{loss:8.3f} {regime:>14}")


if __name__ == "__main__":
    chinchilla_optimal_allocation()
    emergent_capability_prediction()
    scaling_diagnostics()
    budget_allocation()

    print("\n" + "=" * 70)
    print("All applications completed successfully.")
    print("=" * 70)


#!/usr/bin/env python3
"""
Tropical Scaling Laws: Interactive Demonstrations

Demonstrates the core mathematical results:
1. Piecewise-affine structure of the tropical scaling loss
2. Phase transitions as corner loci
3. Idempotence of tropical aggregation
4. Compute-constrained reduction
5. Translation invariance
"""

import numpy as np


def tropical_scaling_loss(a: float, b: float, c: float,
                          A: float, B: float, C: float,
                          x: float, y: float, z: float) -> float:
    """Tropical scaling loss: T(x,y,z) = min(A + a*x, B + b*y, C + c*z)."""
    return min(A + a * x, min(B + b * y, C + c * z))


def classify_regime(a: float, b: float, c: float,
                    A: float, B: float, C: float,
                    x: float, y: float, z: float) -> str:
    """Classify a point into its scaling regime or corner."""
    f_n = A + a * x
    f_d = B + b * y
    f_c = C + c * z
    tol = 1e-12

    ties = []
    if abs(f_n - f_d) < tol:
        ties.append(("N", "D"))
    if abs(f_n - f_c) < tol:
        ties.append(("N", "C"))
    if abs(f_d - f_c) < tol:
        ties.append(("D", "C"))

    if len(ties) >= 2:
        return "TRIPLE_CORNER"
    elif len(ties) == 1:
        return f"CORNER_{ties[0][0]}_{ties[0][1]}"
    else:
        m = min(f_n, f_d, f_c)
        if f_n == m:
            return "N_REGION"
        elif f_d == m:
            return "D_REGION"
        else:
            return "C_REGION"


def demo_affine_structure():
    """Demonstrate that the tropical loss equals affine functions on strict regions."""
    print("=" * 70)
    print("DEMO 1: Piecewise-Affine Structure on Strict Regions")
    print("=" * 70)

    # Typical scaling law parameters (Chinchilla-like)
    a, b, c = -0.34, -0.28, -0.15
    A, B, C = 1.0, 2.0, 3.0

    print(f"\nParameters: a={a}, b={b}, c={c}")
    print(f"Intercepts: A={A}, B={B}, C={C}")
    print()

    test_points = [
        (20, 5, 5, "N should dominate (large x)"),
        (5, 20, 5, "D should dominate (large y)"),
        (5, 5, 20, "C should dominate (large z)"),
    ]

    for x, y, z, desc in test_points:
        loss = tropical_scaling_loss(a, b, c, A, B, C, x, y, z)
        f_n = A + a * x
        f_d = B + b * y
        f_c = C + c * z
        regime = classify_regime(a, b, c, A, B, C, x, y, z)

        print(f"  ({x}, {y}, {z}): {desc}")
        print(f"    f_N = {f_n:.4f}, f_D = {f_d:.4f}, f_C = {f_c:.4f}")
        print(f"    T = {loss:.4f}, Regime: {regime}")
        print()


def demo_phase_transitions():
    """Demonstrate that corners occur exactly where regimes tie."""
    print("=" * 70)
    print("DEMO 2: Phase Transitions as Corner Loci")
    print("=" * 70)

    a, b, c = -0.34, -0.28, -0.15
    A, B, C = 1.0, 2.0, 3.0

    print("\nSweeping x from 0 to 30 with y=10, z=10:")
    print(f"{'x':>6} {'f_N':>10} {'f_D':>10} {'f_C':>10} {'T':>10} {'Regime':>18}")
    print("-" * 66)

    for x_int in range(0, 31, 2):
        x = float(x_int)
        y, z = 10.0, 10.0
        loss = tropical_scaling_loss(a, b, c, A, B, C, x, y, z)
        regime = classify_regime(a, b, c, A, B, C, x, y, z)
        f_n = A + a * x
        f_d = B + b * y
        f_c = C + c * z
        print(f"{x:6.1f} {f_n:10.4f} {f_d:10.4f} {f_c:10.4f} {loss:10.4f} {regime:>18}")

    # Find exact corner
    # A + a*x = B + b*y => x = (B + b*y - A) / a
    y, z = 10.0, 10.0
    x_corner_nd = (B + b * y - A) / a
    x_corner_nc = (C + c * z - A) / a
    print(f"\nExact N-D corner at x = {x_corner_nd:.4f}")
    print(f"Exact N-C corner at x = {x_corner_nc:.4f}")


def demo_idempotence():
    """Demonstrate that tropical aggregation is idempotent."""
    print("\n" + "=" * 70)
    print("DEMO 3: Idempotence of Tropical Aggregation")
    print("=" * 70)

    np.random.seed(42)
    for trial in range(5):
        u, v, w = np.random.randn(3) * 5

        agg1 = min(u, min(v, w))
        agg2 = min(agg1, min(v, w))

        print(f"  Trial {trial+1}: u={u:.3f}, v={v:.3f}, w={w:.3f}")
        print(f"    agg₁ = min(u, min(v,w)) = {agg1:.3f}")
        print(f"    agg₂ = min(agg₁, min(v,w)) = {agg2:.3f}")
        print(f"    Idempotent: {abs(agg1 - agg2) < 1e-15}")
        print()


def demo_translation_invariance():
    """Demonstrate translation invariance of phase geometry."""
    print("=" * 70)
    print("DEMO 4: Translation Invariance")
    print("=" * 70)

    a, b, c = -0.34, -0.28, -0.15
    A, B, C = 1.0, 2.0, 3.0
    x, y, z = 10.0, 8.0, 12.0

    for k in [-5.0, 0.0, 5.0, 100.0]:
        loss_orig = tropical_scaling_loss(a, b, c, A, B, C, x, y, z)
        loss_shifted = tropical_scaling_loss(a, b, c, A + k, B + k, C + k, x, y, z)
        regime_orig = classify_regime(a, b, c, A, B, C, x, y, z)
        regime_shifted = classify_regime(a, b, c, A + k, B + k, C + k, x, y, z)

        print(f"  k = {k:>6.1f}: T_orig = {loss_orig:.4f}, "
              f"T_shifted = {loss_shifted:.4f} = {k:.1f} + {loss_orig:.4f}")
        print(f"           Regime preserved: {regime_orig == regime_shifted} "
              f"({regime_orig})")


def demo_compute_constraint():
    """Demonstrate the compute-constrained reduction z = x + y."""
    print("\n" + "=" * 70)
    print("DEMO 5: Compute-Constrained Reduction (z = x + y)")
    print("=" * 70)

    a, b, c = -0.34, -0.28, -0.15
    A, B, C = 1.0, 2.0, 3.0

    print("\nSweeping along the compute constraint z = x + y:")
    print(f"{'x':>6} {'y':>6} {'z=x+y':>8} {'f_N':>10} {'f_D':>10} "
          f"{'f_C':>10} {'T':>10} {'Regime':>18}")
    print("-" * 82)

    for x_int in range(1, 21, 2):
        x = float(x_int)
        y = 20.0 - x
        z = x + y
        loss = tropical_scaling_loss(a, b, c, A, B, C, x, y, z)
        regime = classify_regime(a, b, c, A, B, C, x, y, z)
        f_n = A + a * x
        f_d = B + b * y
        f_c = C + c * z
        print(f"{x:6.1f} {y:6.1f} {z:8.1f} {f_n:10.4f} {f_d:10.4f} "
              f"{f_c:10.4f} {loss:10.4f} {regime:>18}")


def demo_tropical_absorption():
    """Demonstrate the tropical absorption law (zero-temperature analogy)."""
    print("\n" + "=" * 70)
    print("DEMO 6: Tropical Absorption (Zero-Temperature Limit)")
    print("=" * 70)

    print("\nShowing: if w >= min(u,v), then min(min(u,v), w) = min(u,v)")
    print("This models how dominated states are irrelevant at zero temperature.\n")

    test_cases = [
        (1.0, 3.0, 5.0),
        (2.0, 2.0, 4.0),
        (-1.0, 0.0, 0.0),
        (10.0, 5.0, 5.0),
    ]

    for u, v, w in test_cases:
        m = min(u, v)
        absorbed = min(m, w)
        print(f"  u={u:5.1f}, v={v:5.1f}, w={w:5.1f}: "
              f"min(u,v)={m:5.1f}, w >= min(u,v): {w >= m}, "
              f"min(min(u,v),w) = {absorbed:5.1f} = min(u,v): {abs(absorbed - m) < 1e-15}")


def demo_trichotomy():
    """Demonstrate the complete polyhedral decomposition."""
    print("\n" + "=" * 70)
    print("DEMO 7: Complete Polyhedral Decomposition (Trichotomy)")
    print("=" * 70)

    a, b, c = -0.34, -0.28, -0.15
    A, B, C = 1.0, 2.0, 3.0

    np.random.seed(123)
    counts = {"N_REGION": 0, "D_REGION": 0, "C_REGION": 0, "CORNER": 0}

    n_samples = 10000
    for _ in range(n_samples):
        x, y, z = np.random.uniform(-10, 30, 3)
        regime = classify_regime(a, b, c, A, B, C, x, y, z)
        if "CORNER" in regime:
            counts["CORNER"] += 1
        else:
            counts[regime] += 1

    print(f"\nRandom sampling of {n_samples} points in [-10,30]³:")
    for regime, count in counts.items():
        print(f"  {regime:>10}: {count:>5} ({100*count/n_samples:.1f}%)")
    print(f"\n  Every point classified: {sum(counts.values()) == n_samples}")
    print("  (Corners have measure zero, so few are found by random sampling)")


if __name__ == "__main__":
    demo_affine_structure()
    demo_phase_transitions()
    demo_idempotence()
    demo_translation_invariance()
    demo_compute_constraint()
    demo_tropical_absorption()
    demo_trichotomy()

    print("\n" + "=" * 70)
    print("All demonstrations completed successfully.")
    print("=" * 70)


#!/usr/bin/env python3
"""
Visualizations for Tropical Scaling Laws

Generates publication-quality figures showing:
1. Tropical scaling loss surface with phase boundaries
2. Phase diagram in 2D cross-section
3. Regime classification map
4. Softmin to tropical-min convergence
5. Compute-optimal frontier
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.colors import ListedColormap
import base64
from io import BytesIO


def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64 data URI."""
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    data = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{data}"


def tropical_loss_2d(a, b, A, B, x, y):
    """2D tropical loss: min(A + a*x, B + b*y)."""
    return np.minimum(A + a * x, B + b * y)


def tropical_loss_3term(a, b, c, A, B, C, x, y):
    """3-term tropical loss with z fixed or constrained."""
    f1 = A + a * x
    f2 = B + b * y
    f3 = C + c * (x + y)  # compute constraint z = x + y
    return np.minimum(f1, np.minimum(f2, f3))


def plot_phase_diagram():
    """Generate the 2D phase diagram showing scaling regimes."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 8))

    a, b, c = -0.34, -0.28, -0.15
    A, B, C = 1.0, 2.0, 3.0

    x = np.linspace(-5, 25, 500)
    y = np.linspace(-5, 25, 500)
    X, Y = np.meshgrid(x, y)

    # Three terms with z = 10 (fixed compute)
    z_fixed = 10.0
    F_N = A + a * X
    F_D = B + b * Y
    F_C = C + c * z_fixed

    # Regime assignment
    regime = np.zeros_like(X)
    regime[F_N <= np.minimum(F_D, F_C)] = 1  # N dominates
    regime[F_D < np.minimum(F_N, F_C)] = 2   # D dominates
    regime[F_C < np.minimum(F_N, F_D)] = 3   # C dominates

    cmap = ListedColormap(['#f0f0f0', '#3498db', '#e74c3c', '#2ecc71'])
    ax.contourf(X, Y, regime, levels=[-0.5, 0.5, 1.5, 2.5, 3.5],
                cmap=cmap, alpha=0.6)

    # Phase boundaries
    # N-D boundary: A + a*x = B + b*y => y = (A + a*x - B) / b
    x_line = np.linspace(-5, 25, 200)

    if abs(b) > 1e-10:
        y_nd = (A + a * x_line - B) / b
        mask_nd = (A + a * x_line <= C + c * z_fixed)
        ax.plot(x_line[mask_nd], y_nd[mask_nd], 'k-', linewidth=2.5,
                label='N-D boundary')

    # N-C boundary: A + a*x = C + c*z => x = (C + c*z - A) / a
    if abs(a) > 1e-10:
        x_nc = (C + c * z_fixed - A) / a
        y_range = np.linspace(-5, 25, 200)
        # Valid where A + a*x_nc <= B + b*y
        if abs(b) > 1e-10:
            y_min_nc = (A + a * x_nc - B) / b
            valid = y_range >= y_min_nc
            ax.axvline(x=x_nc, color='k', linestyle='--', linewidth=2.5,
                       label='N-C boundary')

    # D-C boundary: B + b*y = C + c*z => y = (C + c*z - B) / b
    if abs(b) > 1e-10:
        y_dc = (C + c * z_fixed - B) / b
        # Valid where B + b*y_dc <= A + a*x
        if abs(a) > 1e-10:
            x_min_dc = (B + b * y_dc - A) / a
            ax.axhline(y=y_dc, color='k', linestyle=':', linewidth=2.5,
                       label='D-C boundary')

    # Triple point
    if abs(a) > 1e-10 and abs(b) > 1e-10:
        x_tp = (C + c * z_fixed - A) / a
        y_tp = (C + c * z_fixed - B) / b
        ax.plot(x_tp, y_tp, 'k*', markersize=20, zorder=5,
                label='Triple point')

    ax.set_xlabel('log(N) — Model Parameters', fontsize=14)
    ax.set_ylabel('log(D) — Training Data', fontsize=14)
    ax.set_title('Tropical Phase Diagram of Neural Scaling\n'
                 f'(fixed log(C) = {z_fixed})', fontsize=16)

    # Add regime labels
    ax.text(20, 3, 'Parameter\nLimited', fontsize=14, ha='center',
            color='#2471a3', fontweight='bold')
    ax.text(3, 20, 'Data\nLimited', fontsize=14, ha='center',
            color='#c0392b', fontweight='bold')
    ax.text(3, 3, 'Compute\nLimited', fontsize=14, ha='center',
            color='#27ae60', fontweight='bold')

    ax.legend(fontsize=12, loc='upper right')
    ax.set_xlim(-5, 25)
    ax.set_ylim(-5, 25)
    ax.grid(True, alpha=0.3)

    fig.savefig('/workspace/request-project/phase_diagram.png', dpi=150,
                bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


def plot_loss_surface():
    """Generate 3D-style loss surface showing piecewise-affine structure."""
    fig, axes = plt.subplots(1, 2, figsize=(16, 6))

    a, b = -0.34, -0.28
    A, B = 1.0, 2.0

    x = np.linspace(0, 20, 300)

    # Left: 2-term tropical loss (1D cross-section)
    ax = axes[0]
    f_n = A + a * x
    f_d = B + b * 10  # fixed y = 10
    loss = np.minimum(f_n, f_d)

    ax.plot(x, f_n, '--', color='#3498db', linewidth=1.5, alpha=0.7, label='A + a·x')
    ax.axhline(y=f_d, color='#e74c3c', linestyle='--', linewidth=1.5, alpha=0.7,
               label=f'B + b·10 = {f_d:.2f}')
    ax.plot(x, loss, 'k-', linewidth=3, label='Tropical loss')

    # Mark corner
    x_corner = (f_d - A) / a
    ax.plot(x_corner, f_d, 'r*', markersize=15, zorder=5)
    ax.annotate('Phase\nTransition', xy=(x_corner, f_d),
                xytext=(x_corner + 3, f_d + 0.5),
                fontsize=12, ha='center',
                arrowprops=dict(arrowstyle='->', color='red', lw=2))

    ax.set_xlabel('log(N)', fontsize=13)
    ax.set_ylabel('Loss', fontsize=13)
    ax.set_title('1D Cross-Section: Piecewise-Affine Loss', fontsize=14)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)

    # Right: Contour plot of 3-term tropical loss
    ax = axes[1]
    xx = np.linspace(0, 20, 200)
    yy = np.linspace(0, 20, 200)
    XX, YY = np.meshgrid(xx, yy)

    c, C = -0.15, 3.0
    ZZ = tropical_loss_3term(a, b, c, A, B, C, XX, YY)

    contours = ax.contourf(XX, YY, ZZ, levels=20, cmap='viridis')
    fig.colorbar(contours, ax=ax, label='Tropical Loss')

    # Phase boundaries
    x_line = np.linspace(0, 20, 200)
    if abs(b) > 1e-10:
        y_nd = (A + a * x_line - B) / b
        ax.plot(x_line, y_nd, 'w-', linewidth=2, label='N-D boundary')

    ax.set_xlabel('log(N)', fontsize=13)
    ax.set_ylabel('log(D)', fontsize=13)
    ax.set_title('Tropical Loss Contours (z = x + y)', fontsize=14)
    ax.legend(fontsize=11)
    ax.set_xlim(0, 20)
    ax.set_ylim(0, 20)

    fig.tight_layout()
    fig.savefig('/workspace/request-project/loss_surface.png', dpi=150,
                bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


def plot_softmin_convergence():
    """Show convergence of softmin to tropical min."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    # Left: softmin function for various beta
    ax = axes[0]
    x = np.linspace(-3, 3, 300)
    f1 = x
    f2 = np.zeros_like(x)

    for beta in [0.5, 1, 2, 5, 20, 100]:
        softmin = -np.log(np.exp(-beta * f1) + np.exp(-beta * f2)) / beta
        alpha_val = min(1.0, 0.3 + beta / 30)
        ax.plot(x, softmin, linewidth=1.5, alpha=alpha_val,
                label=f'β={beta}')

    ax.plot(x, np.minimum(f1, f2), 'k-', linewidth=3, label='min (β→∞)')
    ax.set_xlabel('x', fontsize=13)
    ax.set_ylabel('Softmin(x, 0)', fontsize=13)
    ax.set_title('Softmin → Tropical Min (Zero-Temperature Limit)', fontsize=14)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    # Right: convergence rate
    ax = axes[1]
    betas = np.logspace(-1, 3, 100)
    f_vals = [1.0, 2.0, 3.0]  # three terms
    true_min = min(f_vals)

    errors = []
    upper_bound = []
    for beta in betas:
        softmin = -np.log(sum(np.exp(-beta * f) for f in f_vals)) / beta
        errors.append(abs(softmin - true_min))
        upper_bound.append(np.log(len(f_vals)) / beta)

    ax.loglog(betas, errors, 'b-', linewidth=2, label='Actual error')
    ax.loglog(betas, upper_bound, 'r--', linewidth=2, label='log(k)/β bound')
    ax.set_xlabel('β (inverse temperature)', fontsize=13)
    ax.set_ylabel('|S_β - min|', fontsize=13)
    ax.set_title('Convergence Rate: O(log k / β)', fontsize=14)
    ax.legend(fontsize=12)
    ax.grid(True, alpha=0.3)

    fig.tight_layout()
    fig.savefig('/workspace/request-project/softmin_convergence.png', dpi=150,
                bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


def plot_compute_frontier():
    """Plot the compute-optimal frontier under tropical constraints."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 7))

    a, b, c = -0.076, -0.095, -0.050
    A, B, C = 0.0, 0.5, 1.0

    compute_budgets = np.linspace(5, 60, 200)
    optimal_x = []
    optimal_y = []
    optimal_loss = []
    optimal_regime = []

    for z_budget in compute_budgets:
        best_loss = float('inf')
        best_x = 0
        best_y = 0
        best_regime = 'N'

        for ratio in np.linspace(0.05, 0.95, 200):
            x = ratio * z_budget
            y = (1 - ratio) * z_budget
            z = x + y
            f_n = A + a * x
            f_d = B + b * y
            f_c = C + c * z
            loss = min(f_n, f_d, f_c)

            if loss < best_loss:
                best_loss = loss
                best_x = x
                best_y = y
                if f_n <= f_d and f_n <= f_c:
                    best_regime = 'N'
                elif f_d <= f_n and f_d <= f_c:
                    best_regime = 'D'
                else:
                    best_regime = 'C'

        optimal_x.append(best_x)
        optimal_y.append(best_y)
        optimal_loss.append(best_loss)
        optimal_regime.append(best_regime)

    # Color by regime
    colors = {'N': '#3498db', 'D': '#e74c3c', 'C': '#2ecc71'}
    for i in range(len(compute_budgets) - 1):
        ax.plot(compute_budgets[i:i+2], optimal_loss[i:i+2],
                color=colors[optimal_regime[i]], linewidth=3)

    # Add legend patches
    from matplotlib.patches import Patch
    legend_elements = [
        Patch(facecolor='#3498db', label='Parameter-limited'),
        Patch(facecolor='#e74c3c', label='Data-limited'),
        Patch(facecolor='#2ecc71', label='Compute-limited'),
    ]
    ax.legend(handles=legend_elements, fontsize=12, loc='upper right')

    ax.set_xlabel('Total Compute Budget (log scale)', fontsize=14)
    ax.set_ylabel('Optimal Loss', fontsize=14)
    ax.set_title('Compute-Optimal Scaling Frontier\n'
                 '(Tropical Pareto Curve under C ∝ N·D)', fontsize=16)
    ax.grid(True, alpha=0.3)

    fig.savefig('/workspace/request-project/compute_frontier.png', dpi=150,
                bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


def generate_all_visualizations() -> dict:
    """Generate all visualizations and return base64 data."""
    results = {}

    print("Generating phase diagram...")
    results['phase_diagram'] = plot_phase_diagram()

    print("Generating loss surface...")
    results['loss_surface'] = plot_loss_surface()

    print("Generating softmin convergence...")
    results['softmin_convergence'] = plot_softmin_convergence()

    print("Generating compute frontier...")
    results['compute_frontier'] = plot_compute_frontier()

    print("All visualizations generated.")
    return results


if __name__ == "__main__":
    results = generate_all_visualizations()
    for name, data in results.items():
        print(f"  {name}: {len(data)} chars")
