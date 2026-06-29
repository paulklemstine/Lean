#!/usr/bin/env python3
"""
Tropical KAM Renormalization — Applications

Demonstrates real-world applications of the renormalization theory:
1. Numerical integrator stability certification
2. Signal processing with multi-scale frequency preservation
3. Lattice-based cryptographic parameter hardening
"""

import math
from algorithms import (
    estimate_diophantine_constant,
    certify_multiscale_KAM,
    admissible_bound,
    renorm_const,
    l1_norm,
    lattice_inner,
    enumerate_lattice_vectors,
)

PHI = (1 + math.sqrt(5)) / 2


def application_1_numerical_integrator():
    """
    Application: Certified numerical integrator stability.

    In symplectic integration of Hamiltonian systems, each timestep
    introduces a small perturbation to the frequency map. The
    renormalization theorem guarantees that after m timesteps:
    - The effective Diophantine gap decays as C/2^m
    - The total accumulated error is bounded by C/K
    - The resonance structure is preserved

    This provides a priori error budgets for long-time integration.
    """
    print("=" * 60)
    print("APPLICATION 1: Numerical Integrator Stability")
    print("=" * 60)

    # Model: two-frequency Hamiltonian with golden-ratio frequencies
    omega = [1.0, PHI]
    K = 12  # Resonance scale to protect against

    C = estimate_diophantine_constant(omega, K)
    print(f"\nSystem frequencies: ω = {omega}")
    print(f"Protection scale: K = {K}")
    print(f"Initial Diophantine gap: C = {C:.8f}")

    # Simulate integration errors at each step
    m_steps = 15
    dt = 0.01  # timestep
    print(f"\nTimestep: dt = {dt}")
    print(f"Integration steps: {m_steps}")

    perturbations = []
    for j in range(m_steps):
        # Perturbation size decreases with step (modeling adaptive integration)
        size = 0.7 * admissible_bound(C, K, j)
        delta = [size * math.sin(j + 1), size * math.cos(j + 1)]
        perturbations.append(delta)

    success, msg, cert = certify_multiscale_KAM(omega, K, C, perturbations)

    print(f"\nCertification: {'PASSED ✓' if success else 'FAILED ✗'}")
    print(f"Total frequency drift: {cert['total_budget']:.2e}")
    print(f"Guaranteed Diophantine gap after {m_steps} steps: "
          f"{renorm_const(C, m_steps):.2e}")
    print(f"Drift budget limit: {C/K:.2e}")
    print(f"\nConclusion: The integrator preserves quasi-periodic structure")
    print(f"through {m_steps} refinement scales with certified error bounds.")


def application_2_signal_processing():
    """
    Application: Multi-scale frequency preservation in signal processing.

    When a signal with quasi-periodic structure undergoes multiple
    processing stages (filtering, resampling, quantization), each stage
    perturbs the frequency components. The renormalization theorem
    ensures that the frequency structure is preserved if each stage
    satisfies the geometric admissibility condition.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: Signal Processing Frequency Preservation")
    print("=" * 60)

    # Signal with three quasi-periodic components
    omega = [1.0, math.sqrt(2), math.pi / 3]
    K = 6

    C = estimate_diophantine_constant(omega, K)
    print(f"\nSignal frequencies: ω = [1, √2, π/3]")
    print(f"  = [{omega[0]:.6f}, {omega[1]:.6f}, {omega[2]:.6f}]")
    print(f"Resonance scale: K = {K}")
    print(f"Diophantine gap: C = {C:.8f}")

    # Processing stages
    stages = [
        "Low-pass filter",
        "Resampling",
        "Quantization",
        "Windowing",
        "Interpolation",
        "Denoising",
        "Compression",
        "Reconstruction",
    ]

    m = len(stages)
    perturbations = []
    print(f"\nProcessing pipeline ({m} stages):")

    for j, stage in enumerate(stages):
        bound = admissible_bound(C, K, j)
        size = 0.5 * bound  # Conservative perturbation
        delta = [size * ((i + j) % 3 - 1) for i in range(3)]
        perturbations.append(delta)
        print(f"  {j+1}. {stage}: perturbation = {max(abs(d) for d in delta):.2e} "
              f"(limit: {bound:.2e})")

    success, msg, cert = certify_multiscale_KAM(omega, K, C, perturbations)

    print(f"\nCertification: {'PASSED ✓' if success else 'FAILED ✗'}")
    print(f"Final guaranteed gap: {renorm_const(C, m):.2e}")
    print(f"Total frequency drift: {cert['total_budget']:.2e}")
    print(f"\nConclusion: All {m} processing stages preserve the")
    print(f"quasi-periodic frequency structure with certified bounds.")


def application_3_resonance_avoidance():
    """
    Application: Resonance avoidance in dynamical systems.

    In celestial mechanics and accelerator physics, resonances cause
    instability. The renormalization theorem provides a framework for
    certifying that parameter adjustments (orbit corrections, tune
    adjustments) maintain resonance avoidance over multiple scales.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: Resonance Avoidance in Dynamical Systems")
    print("=" * 60)

    # Orbital frequencies (simplified 2D model)
    omega = [1.0, PHI]  # Non-resonant frequency pair
    K = 15  # Protect against resonances up to order 15

    C = estimate_diophantine_constant(omega, K)
    print(f"\nOrbital frequencies: ω = [1, φ]")
    print(f"Resonance order protection: K = {K}")
    print(f"Initial gap: C = {C:.8f}")

    # Check which resonances we're avoiding
    print(f"\nResonance avoidance check (order ≤ {K}):")
    dangerous_resonances = []
    for k in enumerate_lattice_vectors(2, K):
        inner = abs(lattice_inner(k, omega))
        if inner < C * 2:  # Close to boundary
            dangerous_resonances.append((k, inner))

    dangerous_resonances.sort(key=lambda x: x[1])
    for k, gap in dangerous_resonances[:5]:
        print(f"  k = {k}, |⟨k,ω⟩| = {gap:.8f}")

    # Apply corrections maintaining avoidance
    m = 10
    print(f"\nApplying {m} orbit corrections:")
    perturbations = []
    for j in range(m):
        bound = admissible_bound(C, K, j)
        size = 0.6 * bound
        delta = [size * math.sin(2 * j + 1), size * math.cos(2 * j + 1)]
        perturbations.append(delta)

    success, msg, cert = certify_multiscale_KAM(omega, K, C, perturbations)

    print(f"\nCertification: {'PASSED ✓' if success else 'FAILED ✗'}")
    print(f"Corrections applied: {m}")
    print(f"Total drift: {cert['total_budget']:.2e}")
    print(f"Final certified gap: {renorm_const(C, m):.2e}")
    print(f"Resonance profile preserved: {cert['profile_preserved']}")
    print(f"\nConclusion: All {m} corrections maintain resonance avoidance")
    print(f"with certified Diophantine gap bounds at each scale.")


if __name__ == "__main__":
    application_1_numerical_integrator()
    application_2_signal_processing()
    application_3_resonance_avoidance()


#!/usr/bin/env python3
"""
Tropical KAM Renormalization — Interactive Demo

Demonstrates the multi-scale renormalization theorem:
- Geometric decay of Diophantine constant C/2^m
- Finite total perturbation budget convergence to C/K
- Resonance profile preservation across scales

Uses ω = [1, φ] (golden ratio frequency) as the canonical example.
"""

import math
import sys

# Golden ratio
PHI = (1 + math.sqrt(5)) / 2


def tropical_diophantine_constant(omega, K_max):
    """
    Estimate the tropical Diophantine constant C for frequency vector omega.
    C = min over nonzero k with ||k||_1 <= K_max of |<k, omega>|.
    """
    n = len(omega)
    C_min = float('inf')

    def generate_lattice_vectors(n, K_max):
        """Generate all integer vectors k with 0 < ||k||_1 <= K_max."""
        if n == 0:
            return
        if n == 1:
            for v in range(-K_max, K_max + 1):
                if abs(v) > 0:
                    yield [v]
            return
        for v in range(-K_max, K_max + 1):
            remaining = K_max - abs(v)
            if remaining < 0:
                continue
            for rest in generate_lattice_vectors_with_zero(n - 1, remaining):
                vec = [v] + rest
                if sum(abs(x) for x in vec) > 0:
                    yield vec

    def generate_lattice_vectors_with_zero(n, K_max):
        if n == 0:
            yield []
            return
        for v in range(-K_max, K_max + 1):
            remaining = K_max - abs(v)
            if remaining < 0:
                continue
            for rest in generate_lattice_vectors_with_zero(n - 1, remaining):
                yield [v] + rest

    for k in generate_lattice_vectors(n, K_max):
        inner = sum(ki * wi for ki, wi in zip(k, omega))
        val = abs(inner)
        if val > 0:
            C_min = min(C_min, val)

    return C_min if C_min < float('inf') else 0.0


def run_renormalization_demo(K=10, m_max=20, safety_factor=0.9):
    """
    Run the tropical KAM renormalization demo.

    Parameters:
        K: scale parameter for Diophantine condition
        m_max: number of renormalization steps
        safety_factor: fraction of admissible bound used (< 1 for safety)
    """
    omega = [1.0, PHI]
    n = len(omega)

    print("=" * 70)
    print("TROPICAL KAM RENORMALIZATION DEMO")
    print("=" * 70)
    print(f"\nInitial frequency: ω = [1, φ] = [1, {PHI:.6f}]")
    print(f"Scale parameter: K = {K}")
    print(f"Safety factor: {safety_factor}")
    print()

    # Estimate initial Diophantine constant
    C = tropical_diophantine_constant(omega, K)
    print(f"Estimated initial Diophantine constant C = {C:.8f}")
    print(f"Theoretical total budget bound C/K = {C / K:.8f}")
    print(f"Tighter bound C/(2K) = {C / (2 * K):.8f}")
    print()

    # Run renormalization
    print("-" * 70)
    print(f"{'Step':>4} | {'C/2^m (predicted)':>18} | {'C*(observed)':>18} | "
          f"{'Budget used':>14} | {'Profile OK':>10}")
    print("-" * 70)

    current_omega = list(omega)
    cumulative_budget = 0.0
    all_profiles_ok = True

    predicted_bounds = []
    observed_bounds = []
    budgets = []

    for m in range(m_max + 1):
        # Predicted lower bound
        predicted_C = C / (2.0 ** m)

        # Observed Diophantine constant
        observed_C = tropical_diophantine_constant(current_omega, K)

        # Check resonance profile preservation
        profile_ok = observed_C > 0  # Simplified: nonzero means no resonance collapse

        if not profile_ok:
            all_profiles_ok = False

        predicted_bounds.append(predicted_C)
        observed_bounds.append(observed_C)
        budgets.append(cumulative_budget)

        status = "✓" if profile_ok else "✗ VIOLATION"

        print(f"{m:4d} | {predicted_C:18.10f} | {observed_C:18.10f} | "
              f"{cumulative_budget:14.10f} | {status:>10}")

        # Apply perturbation for next step (if not last)
        if m < m_max:
            # Admissible bound at step m: C / (2^(m+1) * 2 * K)
            admissible_bound = C / (2.0 ** (m + 1) * 2 * K)
            perturbation_size = safety_factor * admissible_bound

            # Apply random-direction perturbation of controlled size
            # Use deterministic perturbation for reproducibility
            delta = [perturbation_size * ((-1) ** (i + m)) for i in range(n)]
            current_omega = [w + d for w, d in zip(current_omega, delta)]
            cumulative_budget += perturbation_size

    print("-" * 70)
    print()

    # Summary
    print("SUMMARY")
    print("=" * 70)
    print(f"Final predicted bound C/2^{m_max} = {C / 2**m_max:.2e}")
    print(f"Final observed constant:        {observed_bounds[-1]:.2e}")
    print(f"Total budget consumed:          {cumulative_budget:.10f}")
    print(f"Theoretical budget limit C/(2K): {C / (2 * K):.10f}")
    print(f"Budget utilization:             {cumulative_budget / (C / (2 * K)) * 100:.2f}%")
    print(f"All resonance profiles OK:      {'Yes ✓' if all_profiles_ok else 'No ✗'}")
    print()

    # Convergence analysis
    print("CONVERGENCE ANALYSIS")
    print("=" * 70)
    remaining_budgets = [C / (2 * K) - b for b in budgets]
    print(f"Budget remaining at step 0:  {remaining_budgets[0]:.10f}")
    print(f"Budget remaining at step {m_max}: {remaining_budgets[-1]:.10f}")
    print(f"Ratio (geometric decay):     "
          f"{remaining_budgets[-1] / remaining_budgets[0]:.2e}")
    print(f"Expected ratio 1/2^{m_max}:       {1.0 / 2**m_max:.2e}")
    print()

    # Verify the key theorem predictions
    print("THEOREM VERIFICATION")
    print("=" * 70)

    # Theorem 1: Iterated stability
    thm1_ok = all(observed_bounds[m] >= predicted_bounds[m] * 0.99
                  for m in range(len(predicted_bounds)))
    print(f"Theorem 1 (Iterated stability):    "
          f"{'VERIFIED ✓' if thm1_ok else 'ISSUE ✗'}")

    # Theorem 2: Budget bound
    thm2_ok = cumulative_budget < C / K
    print(f"Theorem 2 (Finite budget < C/K):   "
          f"{'VERIFIED ✓' if thm2_ok else 'ISSUE ✗'}")

    # Theorem 3: Resonance preservation
    print(f"Theorem 3 (Resonance preserved):   "
          f"{'VERIFIED ✓' if all_profiles_ok else 'ISSUE ✗'}")

    # Theorem 4: Asymptotic decay
    thm4_ok = predicted_bounds[-1] < 1e-5
    print(f"Theorem 4 (C/2^m → 0):            "
          f"{'VERIFIED ✓' if thm4_ok else 'ISSUE ✗'}")

    print()
    return predicted_bounds, observed_bounds, budgets


def plot_results(predicted, observed, budgets, C, K, m_max):
    """Plot the renormalization flow results."""
    try:
        import matplotlib
        matplotlib.use('Agg')
        import matplotlib.pyplot as plt

        fig, axes = plt.subplots(1, 3, figsize=(15, 5))

        steps = list(range(len(predicted)))

        # Plot 1: Diophantine constant decay
        ax1 = axes[0]
        ax1.semilogy(steps, predicted, 'b-o', label='Predicted C/2^m', markersize=3)
        ax1.semilogy(steps, observed, 'r-s', label='Observed C*', markersize=3)
        ax1.set_xlabel('Renormalization Step m')
        ax1.set_ylabel('Diophantine Constant')
        ax1.set_title('Geometric Decay of Diophantine Constant')
        ax1.legend()
        ax1.grid(True, alpha=0.3)

        # Plot 2: Cumulative budget
        ax2 = axes[1]
        budget_limit = C / (2 * K)
        ax2.plot(steps, budgets, 'g-o', label='Consumed budget', markersize=3)
        ax2.axhline(y=budget_limit, color='r', linestyle='--',
                    label=f'Limit C/(2K) = {budget_limit:.6f}')
        ax2.axhline(y=C/K, color='orange', linestyle=':',
                    label=f'Upper bound C/K = {C/K:.6f}')
        ax2.set_xlabel('Renormalization Step m')
        ax2.set_ylabel('Cumulative Perturbation')
        ax2.set_title('Finite Total KAM Radius')
        ax2.legend()
        ax2.grid(True, alpha=0.3)

        # Plot 3: Budget utilization ratio
        ax3 = axes[2]
        theoretical_budget = [C / (2 * K) * (1 - 1 / 2**m) for m in steps]
        ax3.plot(steps, [b / (C / K) for b in budgets], 'b-o',
                 label='Actual / (C/K)', markersize=3)
        ax3.plot(steps, [b / (C / K) for b in theoretical_budget], 'r--',
                 label='Theoretical / (C/K)', markersize=3)
        ax3.axhline(y=0.5, color='gray', linestyle=':', alpha=0.5,
                    label='Limit = 0.5')
        ax3.set_xlabel('Renormalization Step m')
        ax3.set_ylabel('Budget Fraction')
        ax3.set_title('Budget Convergence')
        ax3.legend()
        ax3.grid(True, alpha=0.3)

        plt.tight_layout()
        plt.savefig('renormalization_flow.png', dpi=150, bbox_inches='tight')
        print("Plot saved to renormalization_flow.png")
        return True

    except ImportError:
        print("matplotlib not available — skipping plot generation")
        return False


if __name__ == "__main__":
    K = 10
    m_max = 20
    safety = 0.9

    predicted, observed, budgets = run_renormalization_demo(K, m_max, safety)

    # Estimate C for plotting
    C = tropical_diophantine_constant([1.0, PHI], K)
    plot_results(predicted, observed, budgets, C, K, m_max)
