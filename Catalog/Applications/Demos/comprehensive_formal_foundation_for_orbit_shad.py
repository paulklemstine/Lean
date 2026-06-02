#!/usr/bin/env python3
"""
Tropical Orbit Shadowing: Demonstrations

Numerical examples demonstrating the key theorems from the tropical orbit
shadowing theory.
"""

import numpy as np
from algorithms import (
    trop_mv, oscillation, birkhoff_contraction_coefficient,
    accum_error_sum, non_autonomous_shadowing_bound,
    autonomous_shadowing_bound, simulate_contraction_pseudo_orbit,
    cosine_annealing_lipschitz, compose_certificates
)


def demo_tropical_nonexpansiveness():
    """Demonstrate that tropical MV product is 1-Lipschitz."""
    print("=" * 60)
    print("DEMO 1: Tropical Max-Plus Non-Expansiveness")
    print("=" * 60)

    A = np.array([[0, -1, -2],
                  [-2, 0, -1],
                  [-1, -2, 0]], dtype=float)

    np.random.seed(42)
    n_trials = 10000
    max_ratio = 0.0

    for _ in range(n_trials):
        x = np.random.randn(3) * 5
        y = np.random.randn(3) * 5
        Ax = trop_mv(A, x)
        Ay = trop_mv(A, y)

        input_dist = np.max(np.abs(x - y))   # sup-norm distance
        output_dist = np.max(np.abs(Ax - Ay))  # sup-norm distance

        if input_dist > 1e-12:
            ratio = output_dist / input_dist
            max_ratio = max(max_ratio, ratio)

    print(f"  Max ratio ||A⊗x - A⊗y||_∞ / ||x - y||_∞ over {n_trials} trials: {max_ratio:.6f}")
    print(f"  Theoretical upper bound (non-expansive): 1.000000")
    print(f"  Non-expansiveness {'VERIFIED' if max_ratio <= 1.0 + 1e-10 else 'VIOLATED'}!")
    print()


def demo_birkhoff_contraction():
    """Test the Birkhoff contraction conjecture for a scrambling matrix."""
    print("=" * 60)
    print("DEMO 2: Birkhoff Contraction Coefficient (Conjecture Test)")
    print("=" * 60)

    A = np.array([[0, -1, -2],
                  [-2, 0, -1],
                  [-1, -2, 0]], dtype=float)

    # Theoretical prediction: τ = tanh(diam(A)/4)
    # diam(A) = max_{i,j,k} (A_ij - A_ik) = 0 - (-2) = 2
    diam = 2.0
    tau_predicted = np.tanh(diam / 4)

    tau_estimated = birkhoff_contraction_coefficient(A, num_samples=50000)

    print(f"  Matrix A:")
    print(f"    {A[0]}")
    print(f"    {A[1]}")
    print(f"    {A[2]}")
    print(f"  Diameter of A: {diam}")
    print(f"  Predicted τ(A) = tanh(diam/4) = {tau_predicted:.6f}")
    print(f"  Estimated τ(A) (from 50000 samples): {tau_estimated:.6f}")
    print(f"  τ < 1: {'YES' if tau_estimated < 1.0 else 'NO'} (contraction)")
    print(f"  Close to prediction: {'YES' if abs(tau_estimated - tau_predicted) < 0.05 else 'NO'}")
    print()


def demo_variable_rate_shadowing():
    """Demonstrate the variable-rate shadowing bound."""
    print("=" * 60)
    print("DEMO 3: Variable-Rate vs Autonomous Shadowing Bound")
    print("=" * 60)

    # SGD with cosine annealing
    mu = 1.0
    eta0 = 0.1
    T = 100
    delta = 0.01

    L = cosine_annealing_lipschitz(mu, eta0, T)
    L_max = max(L)

    print(f"  SGD with cosine annealing: μ={mu}, η₀={eta0}, T={T}, σ={delta}")
    print(f"  Max Lipschitz constant: L_max = {L_max:.6f}")
    print(f"  Min Lipschitz constant: L_min = {min(L):.6f}")
    print()

    # Compare bounds at several time points
    print(f"  {'Step':>6}  {'Variable-Rate':>14}  {'Autonomous':>12}  {'Ratio':>8}")
    print(f"  {'-'*6}  {'-'*14}  {'-'*12}  {'-'*8}")

    for t in [10, 25, 50, 75, 100]:
        var_bound = non_autonomous_shadowing_bound(L, delta, t)
        auto_bound = autonomous_shadowing_bound(L_max, delta)
        ratio = var_bound / auto_bound if auto_bound > 0 else float('inf')
        print(f"  {t:>6}  {var_bound:>14.6f}  {auto_bound:>12.6f}  {ratio:>8.4f}")

    print()
    print(f"  The variable-rate bound is tighter because it accounts for the")
    print(f"  varying contraction rates in the cosine annealing schedule.")
    print()


def demo_contraction_pseudo_orbit():
    """Simulate a contraction pseudo-orbit and verify shadowing."""
    print("=" * 60)
    print("DEMO 4: Contraction Pseudo-Orbit Shadowing")
    print("=" * 60)

    L = 0.7
    delta = 0.1
    f = lambda x: L * x  # Linear contraction

    pseudo, true_orb, distances = simulate_contraction_pseudo_orbit(
        f, x0=5.0, delta=delta, n_steps=200
    )

    theoretical_radius = delta / (1 - L)
    max_dist = max(distances)

    print(f"  Map: f(x) = {L}x")
    print(f"  Per-step error bound: δ = {delta}")
    print(f"  Theoretical shadowing radius: δ/(1-L) = {theoretical_radius:.4f}")
    print(f"  Maximum observed distance: {max_dist:.6f}")
    print(f"  Shadowing bound satisfied: {'YES' if max_dist <= theoretical_radius + 1e-10 else 'NO'}")
    print()

    # Show convergence of distance to the theoretical bound
    print(f"  Distances at selected steps:")
    for step in [0, 10, 50, 100, 150, 200]:
        print(f"    Step {step:>4}: dist = {distances[step]:.6f}")
    print()


def demo_certificate_composition():
    """Demonstrate certificate composition bound."""
    print("=" * 60)
    print("DEMO 5: Shadowing Certificate Composition")
    print("=" * 60)

    configs = [
        (0.1, 0.5, 0.2, 0.3),
        (0.05, 0.8, 0.05, 0.9),
        (0.01, 0.3, 0.1, 0.7),
    ]

    for delta1, L1, delta2, L2 in configs:
        max_R, composed = compose_certificates(delta1, L1, delta2, L2)
        print(f"  Cert1: δ={delta1}, L={L1} → R={delta1/(1-L1):.4f}")
        print(f"  Cert2: δ={delta2}, L={L2} → R={delta2/(1-L2):.4f}")
        print(f"  max(R1, R2) = {max_R:.4f}")
        print(f"  Composed bound = {composed:.4f}")
        print(f"  Bound satisfied: {'YES' if max_R <= composed + 1e-10 else 'NO'}")
        print()


def demo_tightness():
    """Demonstrate tightness of the δ/(1-L) bound."""
    print("=" * 60)
    print("DEMO 6: Tightness of the Shadowing Bound")
    print("=" * 60)

    L = 0.5
    delta = 1.0
    theoretical = delta / (1 - L)  # = 2.0

    print(f"  Map: f(x) = {L}x, δ = {delta}")
    print(f"  Theoretical bound: δ/(1-L) = {theoretical}")
    print()

    # Construct the witness pseudo-orbit: x_n = δ * Σ_{i=0}^{n-1} L^i
    # True orbit starting at 0: always 0
    print(f"  {'Step':>6}  {'Pseudo-orbit':>14}  {'True orbit':>12}  {'Distance':>10}  {'Ratio to bound':>15}")
    for n in [1, 2, 5, 10, 20, 50, 100]:
        pseudo_n = delta * sum(L**i for i in range(n))
        true_n = 0.0  # f^n(0) = 0
        dist_n = abs(pseudo_n - true_n)
        ratio = dist_n / theoretical
        print(f"  {n:>6}  {pseudo_n:>14.6f}  {true_n:>12.6f}  {dist_n:>10.6f}  {ratio:>15.6f}")

    print()
    print(f"  The distance converges to {theoretical} from below, proving tightness.")
    print()


if __name__ == "__main__":
    print("\n" + "=" * 60)
    print("  TROPICAL ORBIT SHADOWING: NUMERICAL DEMONSTRATIONS")
    print("=" * 60 + "\n")

    demo_tropical_nonexpansiveness()
    demo_birkhoff_contraction()
    demo_variable_rate_shadowing()
    demo_contraction_pseudo_orbit()
    demo_certificate_composition()
    demo_tightness()

    print("All demonstrations completed successfully!")


#!/usr/bin/env python3
"""
Visualization 1: Orbit Shadowing - Pseudo-orbit vs True Orbit

Shows a contractive pseudo-orbit being shadowed by the true orbit,
with the δ/(1-L) bound envelope.
"""

import numpy as np
import matplotlib.pyplot as plt


def simulate_shadowing(L: float, delta: float, x0: float, n_steps: int, seed: int = 42):
    rng = np.random.RandomState(seed)
    pseudo = [x0]
    true_orb = [x0]
    for k in range(n_steps):
        noise = rng.uniform(-delta, delta)
        pseudo.append(L * pseudo[-1] + noise)
        true_orb.append(L * true_orb[-1])
    return np.array(pseudo), np.array(true_orb)


def main():
    L = 0.7
    delta = 0.3
    x0 = 5.0
    n_steps = 100

    pseudo, true_orb = simulate_shadowing(L, delta, x0, n_steps)
    radius = delta / (1 - L)
    steps = np.arange(n_steps + 1)

    fig, axes = plt.subplots(2, 1, figsize=(12, 8), gridspec_kw={'height_ratios': [2, 1]})

    # Top plot: orbits with shadowing envelope
    ax1 = axes[0]
    ax1.plot(steps, pseudo, 'b-', alpha=0.7, linewidth=1.5, label=f'Pseudo-orbit (δ={delta})')
    ax1.plot(steps, true_orb, 'r-', linewidth=2, label='True orbit (shadow)')
    ax1.fill_between(steps, true_orb - radius, true_orb + radius,
                      alpha=0.15, color='red', label=f'δ/(1-L) = {radius:.2f} envelope')
    ax1.set_xlabel('Step n', fontsize=12)
    ax1.set_ylabel('State x(n)', fontsize=12)
    ax1.set_title(f'Contractive Shadowing: f(x) = {L}x, δ = {delta}, radius = {radius:.2f}',
                  fontsize=14, fontweight='bold')
    ax1.legend(fontsize=11, loc='upper right')
    ax1.grid(True, alpha=0.3)

    # Bottom plot: tracking error
    ax2 = axes[1]
    errors = np.abs(pseudo - true_orb)
    ax2.plot(steps, errors, 'g-', linewidth=1.5, label='|pseudo(n) - true(n)|')
    ax2.axhline(y=radius, color='red', linestyle='--', linewidth=2,
                label=f'Bound δ/(1-L) = {radius:.2f}')
    ax2.set_xlabel('Step n', fontsize=12)
    ax2.set_ylabel('Tracking error', fontsize=12)
    ax2.set_title('Tracking Error vs Theoretical Bound', fontsize=13)
    ax2.legend(fontsize=11)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('shadowing_visualization.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: shadowing_visualization.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization 3: Tropical Birkhoff Contraction

Demonstrates the oscillation contraction property of scrambling tropical
matrices, testing the Birkhoff contraction conjecture.
"""

import numpy as np
import matplotlib.pyplot as plt


def trop_mv(A, x):
    n = A.shape[0]
    return np.array([np.max(A[i, :] + x) for i in range(n)])


def oscillation(x):
    return float(np.max(x) - np.min(x))


def main():
    A = np.array([[0, -1, -2],
                  [-2, 0, -1],
                  [-1, -2, 0]], dtype=float)

    # Theoretical prediction
    diam = 2.0
    tau_predicted = np.tanh(diam / 4)

    np.random.seed(123)
    n_samples = 5000
    ratios = []

    for _ in range(n_samples):
        x = np.random.randn(3) * 10
        osc_x = oscillation(x)
        if osc_x < 1e-12:
            continue
        y = trop_mv(A, x)
        osc_y = oscillation(y)
        ratios.append(osc_y / osc_x)

    ratios = np.array(ratios)

    # Also track oscillation over iterated application
    x0 = np.array([10.0, 0.0, -5.0])
    n_iters = 50
    oscs = [oscillation(x0)]
    x_curr = x0.copy()
    for _ in range(n_iters):
        x_curr = trop_mv(A, x_curr)
        oscs.append(oscillation(x_curr))

    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Left: histogram of contraction ratios
    ax1 = axes[0]
    ax1.hist(ratios, bins=50, density=True, alpha=0.7, color='steelblue',
             edgecolor='white', linewidth=0.5)
    ax1.axvline(x=tau_predicted, color='red', linestyle='--', linewidth=2,
                label=f'Predicted τ = tanh(1/2) ≈ {tau_predicted:.4f}')
    ax1.axvline(x=np.max(ratios), color='orange', linestyle='-', linewidth=2,
                label=f'Max observed ≈ {np.max(ratios):.4f}')
    ax1.axvline(x=1.0, color='black', linestyle=':', linewidth=1.5,
                label='Non-expansive bound = 1')
    ax1.set_xlabel('osc(A⊗x) / osc(x)', fontsize=12)
    ax1.set_ylabel('Density', fontsize=12)
    ax1.set_title('Birkhoff Contraction Ratios', fontsize=14, fontweight='bold')
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)

    # Right: oscillation decay under iteration
    ax2 = axes[1]
    iters = range(n_iters + 1)
    ax2.semilogy(iters, oscs, 'b-o', markersize=3, linewidth=1.5,
                 label='osc(A^⊗n ⊗ x₀)')
    # Predicted decay: osc_0 * tau^n
    predicted_decay = [oscs[0] * tau_predicted**n for n in iters]
    ax2.semilogy(iters, predicted_decay, 'r--', linewidth=2,
                 label=f'Predicted: osc₀ · τⁿ (τ≈{tau_predicted:.3f})')
    ax2.set_xlabel('Iteration n', fontsize=12)
    ax2.set_ylabel('Oscillation (log scale)', fontsize=12)
    ax2.set_title('Oscillation Decay Under Tropical Iteration', fontsize=14, fontweight='bold')
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('tropical_contraction.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: tropical_contraction.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization 2: Variable-Rate vs Autonomous Shadowing Bounds

Compares the non-autonomous variable-rate bound with the autonomous
δ/(1-L) bound for SGD with cosine annealing schedule.
"""

import numpy as np
import matplotlib.pyplot as plt


def cosine_annealing_lipschitz(mu, eta0, T):
    L = []
    for t in range(T):
        eta_t = eta0 * (1 + np.cos(np.pi * t / T)) / 2
        L_t = abs(1 - eta_t * mu)
        L.append(L_t)
    return L


def accum_product(L, k, n):
    product = 1.0
    for j in range(k + 1, n):
        product *= L[j]
    return product


def accum_error_sum(L, n):
    total = 0.0
    for k in range(n):
        total += accum_product(L, k, n)
    return total


def main():
    mu = 1.0
    eta0 = 0.15
    T = 200
    delta = 0.01

    L = cosine_annealing_lipschitz(mu, eta0, T)
    L_max = max(L)

    steps = list(range(1, T + 1))
    var_bounds = [delta * accum_error_sum(L, t) for t in steps]
    auto_bound = delta / (1 - L_max) if L_max < 1 else float('inf')
    auto_bounds = [auto_bound] * len(steps)

    fig, axes = plt.subplots(2, 1, figsize=(12, 8), gridspec_kw={'height_ratios': [1, 2]})

    # Top: Lipschitz constants
    ax1 = axes[0]
    ax1.plot(range(T), L, 'b-', linewidth=1.5, label='L(t) = |1 - η(t)·μ|')
    ax1.axhline(y=L_max, color='red', linestyle='--', linewidth=1.5,
                label=f'L_max = {L_max:.4f}')
    ax1.set_ylabel('Lipschitz constant', fontsize=12)
    ax1.set_title(f'Cosine Annealing: μ={mu}, η₀={eta0}, T={T}', fontsize=14, fontweight='bold')
    ax1.legend(fontsize=11)
    ax1.grid(True, alpha=0.3)

    # Bottom: Shadowing bounds
    ax2 = axes[1]
    ax2.plot(steps, var_bounds, 'b-', linewidth=2, label='Variable-rate bound')
    ax2.plot(steps, auto_bounds, 'r--', linewidth=2, label=f'Autonomous bound δ/(1-L_max) = {auto_bound:.4f}')
    ax2.set_xlabel('Step t', fontsize=12)
    ax2.set_ylabel('Shadowing bound', fontsize=12)
    ax2.set_title('Variable-Rate vs Autonomous Shadowing Bound', fontsize=13)
    ax2.legend(fontsize=11)
    ax2.grid(True, alpha=0.3)

    # Add improvement annotation
    improvement = 1 - var_bounds[T//2] / auto_bound if auto_bound > 0 else 0
    ax2.annotate(f'{improvement*100:.1f}% tighter\nat midpoint',
                xy=(T//2, var_bounds[T//2]), xytext=(T//2 + 20, (var_bounds[T//2] + auto_bound)/2),
                arrowprops=dict(arrowstyle='->', color='green'),
                fontsize=12, color='green', fontweight='bold')

    plt.tight_layout()
    plt.savefig('variable_rate_comparison.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: variable_rate_comparison.png")


if __name__ == "__main__":
    main()
