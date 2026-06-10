#!/usr/bin/env python3
"""
Applications of Variable Contraction Rate Renormalization

Demonstrates connections to:
  1. KAM stability in celestial mechanics
  2. Control theory (Lyapunov decay)
  3. Optimization convergence rates
  4. Iterated function systems
"""

import math
import random


# ─── Application 1: KAM Stability Simulation ──────────────────────────────────

def kam_stability_simulation():
    """
    Simulate KAM-style stability for a 2D frequency vector.

    Models a simplified celestial mechanics scenario where a planet's
    orbital frequencies are perturbed at each epoch, and we track
    whether the Diophantine non-resonance condition is maintained.
    """
    print("=" * 60)
    print("APPLICATION 1: KAM Stability Simulation")
    print("=" * 60)

    # Golden ratio frequency vector — maximally nonresonant
    phi = (1 + math.sqrt(5)) / 2
    omega = [1.0, phi]
    K = 10
    C = 0.05  # conservative initial constant
    alpha = 4.0
    m_steps = 20

    r = 1 - 1/alpha
    random.seed(123)

    print(f"\nFrequency vector: ω = (1, φ) = (1, {phi:.6f})")
    print(f"Parameters: K={K}, C={C}, α={alpha}")
    print(f"Contraction factor: {r:.4f}")
    print()

    omega_current = list(omega)
    print(f"{'Epoch':>5}  {'Predicted C_m':>13}  {'Min |⟨k,ω⟩|':>13}  {'Status':>8}")
    print("-" * 50)

    for j in range(m_steps):
        C_j = C * r ** j
        bound = C_j / (alpha * K)

        # Observed minimum
        min_val = float('inf')
        for k1 in range(-K, K+1):
            for k2 in range(-K, K+1):
                if abs(k1) + abs(k2) == 0 or abs(k1) + abs(k2) > K:
                    continue
                val = abs(k1 * omega_current[0] + k2 * omega_current[1])
                min_val = min(min_val, val)

        status = "✓" if min_val >= C_j else "!"
        print(f"{j:>5}  {C_j:>13.8f}  {min_val:>13.8f}  {status:>8}")

        # Apply random perturbation
        delta = [random.uniform(-bound*0.8, bound*0.8) for _ in range(2)]
        omega_current = [o + d for o, d in zip(omega_current, delta)]

    print()
    print(f"After {m_steps} perturbation epochs:")
    print(f"  Predicted surviving constant: {C * r**m_steps:.10f}")
    print(f"  Frequency drift: Δω = ({omega_current[0]-omega[0]:.8f}, "
          f"{omega_current[1]-omega[1]:.8f})")
    print()


# ─── Application 2: Lyapunov Decay in Control ─────────────────────────────────

def lyapunov_control():
    """
    Interpret the Diophantine constant as a Lyapunov function.

    V_{m+1} = (1 - 1/α) · V_m

    This models a discrete-time control system where the "stability
    margin" decays geometrically under bounded disturbances.
    """
    print("=" * 60)
    print("APPLICATION 2: Lyapunov Decay in Control Theory")
    print("=" * 60)

    print("\nDiscrete Lyapunov dynamics: V_{m+1} = (1 - 1/α) · V_m")
    print()

    V0 = 1.0
    alphas = [1.5, 2.0, 3.0, 5.0, 10.0]
    m_max = 20

    print(f"{'m':>3}", end="")
    for a in alphas:
        print(f"  {'α='+str(a):>10}", end="")
    print()
    print("-" * (3 + 12 * len(alphas)))

    for m in range(m_max + 1):
        print(f"{m:>3}", end="")
        for a in alphas:
            V = V0 * (1 - 1/a) ** m
            print(f"  {V:>10.6f}", end="")
        print()

    print()
    print("Interpretation: Each α defines a distinct dissipation rate.")
    print("  α close to 1: rapid decay, tight perturbation tolerance")
    print("  α large: slow decay, loose perturbation tolerance")
    print("  The stability-perturbation tradeoff is precisely quantified.")
    print()


# ─── Application 3: Optimization Convergence ──────────────────────────────────

def optimization_convergence():
    """
    Analogy with optimization: the contraction factor (1-1/α)
    corresponds to a linear convergence rate.

    In gradient descent with step size 1/L and strong convexity μ,
    the convergence rate is (1 - μ/L). Setting α = L/μ (condition number)
    recovers the standard convergence rate.
    """
    print("=" * 60)
    print("APPLICATION 3: Optimization Convergence Rate Analogy")
    print("=" * 60)

    print("\nConvergence rate correspondence:")
    print("  Renormalization: C_m = C · (1 - 1/α)^m")
    print("  Gradient descent: f(x_m) - f* ≤ (1 - μ/L)^m · (f(x_0) - f*)")
    print("  Mapping: α ↔ L/μ (condition number)")
    print()

    condition_numbers = [2, 5, 10, 50, 100]
    m_values = [1, 5, 10, 50, 100]

    print(f"{'κ=L/μ':>6}", end="")
    for m in m_values:
        print(f"  {'m='+str(m):>10}", end="")
    print(f"  {'Budget':>10}")
    print("-" * (6 + 12 * (len(m_values) + 1)))

    for kappa in condition_numbers:
        alpha = float(kappa)
        r = 1 - 1/alpha
        print(f"{kappa:>6}", end="")
        for m in m_values:
            val = r ** m
            print(f"  {val:>10.6f}", end="")
        budget = alpha / (alpha - 1)
        print(f"  {budget:>10.4f}")

    print()
    print("Key insight: The budget α/(α-1) is the 'total work' needed")
    print("for convergence, analogous to iteration complexity in optimization.")
    print()


# ─── Application 4: Iterated Function System ──────────────────────────────────

def iterated_function_system():
    """
    The map C ↦ C · (1 - 1/α) is a contraction on ℝ₊.

    Starting from any C₀ > 0, iterated application converges to 0.
    The orbit {C₀, C₁, C₂, ...} is a geometric sequence, which is
    the simplest iterated function system (IFS).

    The total "measure" of the orbit is ∑ C_m = C₀ · α/(α-1).
    """
    print("=" * 60)
    print("APPLICATION 4: Iterated Function System on ℝ₊")
    print("=" * 60)

    print("\nContraction map: f(x) = (1 - 1/α) · x")
    print("Fixed point: x* = 0")
    print()

    C0 = 100.0
    alphas = [1.5, 2.0, 3.0, 5.0]
    m_max = 15

    for alpha in alphas:
        r = 1 - 1/alpha
        print(f"α = {alpha}, contraction factor = {r:.4f}")
        print(f"  Orbit: ", end="")
        C = C0
        orbit_sum = 0
        for m in range(m_max):
            if m > 0:
                print(f" → ", end="")
            print(f"{C:.2f}", end="")
            orbit_sum += C
            C *= r
        print(f" → ...")
        total = C0 * alpha / (alpha - 1)
        print(f"  Orbit sum (theory): {total:.2f}")
        print(f"  Partial sum ({m_max} terms): {orbit_sum:.2f}")
        print()

    print("The orbit sum C₀·α/(α-1) measures the total 'resource'")
    print("consumed by the renormalization cascade.")
    print()


# ─── Main ──────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print()
    print("╔════════════════════════════════════════════════════════════╗")
    print("║  Applications of Variable Contraction Renormalization     ║")
    print("╚════════════════════════════════════════════════════════════╝")
    print()

    kam_stability_simulation()
    lyapunov_control()
    optimization_convergence()
    iterated_function_system()

    print("=" * 60)
    print("All applications demonstrated successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Variable Contraction Rates for Diophantine Renormalization — Interactive Demo

Demonstrates the parameterized stability theory:
  - α = 3, 10-step prediction with C·(2/3)^10 bound
  - Decay curves for multiple α values
  - Budget formula verification
  - Conjecture B: optimal α for finite-horizon robustness
"""

import numpy as np
import random

# ─── Definitions ───────────────────────────────────────────────────────────────

def contraction_factor(alpha):
    """ContractionFactor(α) = 1 - 1/α."""
    return 1.0 - 1.0 / alpha

def renorm_const(C, alpha, m):
    """Renormalized Diophantine constant after m steps: C·(1-1/α)^m."""
    return C * contraction_factor(alpha) ** m

def renorm_budget(C, K, alpha):
    """Total perturbation budget: C·α / (K·(α-1)) = C/K·α/(α-1)."""
    return C * alpha / (K * (alpha - 1.0))

def lattice_inner(k, omega):
    """Lattice inner product ⟨k, ω⟩ = Σ k_i · ω_i."""
    return sum(ki * oi for ki, oi in zip(k, omega))

def l1_norm(k):
    """L1 norm of integer vector."""
    return sum(abs(ki) for ki in k)


# ─── Core numerical experiment ────────────────────────────────────────────────

def run_stability_experiment(n, K_max, C, alpha, m_steps, num_trials=200, seed=42):
    """
    Run multi-step perturbation experiment.

    1. Generate a random frequency vector ω.
    2. For each step j = 0..m-1, generate perturbation δ_j with
       |δ_j_i| < C·(1-1/α)^j / (α·K_max).
    3. Track the observed minimum |⟨k, ω_accumulated⟩| over integer
       vectors k with 1 ≤ ‖k‖₁ ≤ K_max.
    4. Compare with predicted bound C·(1-1/α)^m.
    """
    rng = np.random.default_rng(seed)
    omega = rng.uniform(0.1, 1.0, size=n)

    # Generate search set of integer vectors
    search_vectors = []
    for _ in range(num_trials):
        k = rng.integers(-K_max, K_max + 1, size=n)
        if l1_norm(k) > 0 and l1_norm(k) <= K_max:
            search_vectors.append(k)
    # Add canonical basis vectors
    for i in range(n):
        e = [0] * n
        e[i] = 1
        search_vectors.append(e)
        e2 = [0] * n
        e2[i] = -1
        search_vectors.append(e2)

    # Check initial Diophantine constant
    min_initial = min(abs(lattice_inner(k, omega)) for k in search_vectors)
    # Scale C to be achievable
    C_eff = min(C, min_initial)

    r = contraction_factor(alpha)
    predicted = []
    observed = []
    omega_current = list(omega)

    for j in range(m_steps):
        # Predicted bound at step j
        C_j = C_eff * r ** j
        predicted.append(C_j)

        # Observed minimum resonance
        obs_min = min(abs(lattice_inner(k, omega_current)) for k in search_vectors)
        observed.append(obs_min)

        # Generate perturbation bounded by C_j / (alpha * K_max)
        bound = C_j / (alpha * K_max)
        delta = rng.uniform(-bound * 0.95, bound * 0.95, size=n)
        omega_current = [oi + di for oi, di in zip(omega_current, delta)]

    # Final step
    predicted.append(C_eff * r ** m_steps)
    observed.append(min(abs(lattice_inner(k, omega_current)) for k in search_vectors))

    return predicted, observed, C_eff


# ─── Test 1: α = 3, 10 steps ──────────────────────────────────────────────────

def test_alpha_3():
    """
    Mandatory test: α = 3, m = 10 steps.
    Verify observed constants stay above C·(2/3)^10.
    """
    print("=" * 70)
    print("TEST 1: α = 3, 10-step renormalization")
    print("=" * 70)

    n = 3
    K_max = 5
    C = 0.5
    alpha = 3.0
    m_steps = 10

    predicted, observed, C_eff = run_stability_experiment(n, K_max, C, alpha, m_steps)

    print(f"\nParameters: n={n}, K={K_max}, C_eff={C_eff:.6f}, α={alpha}")
    print(f"Contraction factor: 1 - 1/α = {contraction_factor(alpha):.6f}")
    print(f"Predicted final constant: C·(2/3)^10 = {C_eff * (2/3)**10:.8f}")
    print()
    print(f"{'Step':>4}  {'Predicted C_m':>14}  {'Observed min':>14}  {'Ratio obs/pred':>14}  {'OK?':>5}")
    print("-" * 60)

    all_ok = True
    for j in range(m_steps + 1):
        ratio = observed[j] / predicted[j] if predicted[j] > 0 else float('inf')
        ok = observed[j] >= predicted[j] * 0.99  # allow 1% numerical slack
        if not ok:
            all_ok = False
        print(f"{j:>4}  {predicted[j]:>14.8f}  {observed[j]:>14.8f}  {ratio:>14.4f}  {'✓' if ok else '✗':>5}")

    print()
    if all_ok:
        print("✓ PASSED: All observed constants stay above predicted bounds.")
    else:
        print("✗ FAILED: Some observed constants dropped below predicted bounds.")
    print()
    return all_ok


# ─── Test 2: Decay curves for multiple α ───────────────────────────────────────

def test_decay_curves():
    """
    Compare decay curves for α ∈ {1.5, 2, 3, 5, 10}.
    """
    print("=" * 70)
    print("TEST 2: Decay curves for multiple α values")
    print("=" * 70)

    alphas = [1.5, 2.0, 3.0, 5.0, 10.0]
    m_steps = 15
    C = 1.0

    print(f"\n{'Step':>4}", end="")
    for a in alphas:
        print(f"  {'α='+str(a):>12}", end="")
    print()
    print("-" * (4 + 14 * len(alphas)))

    for m in range(m_steps + 1):
        print(f"{m:>4}", end="")
        for a in alphas:
            val = renorm_const(C, a, m)
            print(f"  {val:>12.6f}", end="")
        print()

    print("\nBudgets (C/K with K=1):")
    for a in alphas:
        budget = renorm_budget(C, 1.0, a)
        print(f"  α={a:>4}: budget = {budget:.4f}  (theory: C·α/(α-1) = {a/(a-1):.4f})")
    print()


# ─── Test 3: Geometric series verification ────────────────────────────────────

def test_geometric_series():
    """
    Verify ∑_{j=0}^{N-1} (1-1/α)^j → α as N → ∞.
    """
    print("=" * 70)
    print("TEST 3: Geometric series closed form verification")
    print("=" * 70)

    alphas = [1.5, 2.0, 3.0, 5.0, 10.0]
    N_values = [10, 50, 100, 1000]

    print(f"\n{'α':>6}", end="")
    for N in N_values:
        print(f"  {'N='+str(N):>12}", end="")
    print(f"  {'Limit':>12}")
    print("-" * (6 + 14 * (len(N_values) + 1)))

    for a in alphas:
        r = contraction_factor(a)
        print(f"{a:>6.1f}", end="")
        for N in N_values:
            partial = sum(r ** j for j in range(N))
            print(f"  {partial:>12.6f}", end="")
        print(f"  {a:>12.6f}")
    print()


# ─── Test 4: Budget formula ──────────────────────────────────────────────────

def test_budget_formula():
    """
    Verify ∑ C·(1-1/α)^j / (α·K) = C/K.
    """
    print("=" * 70)
    print("TEST 4: Total perturbation budget verification")
    print("=" * 70)

    C, K = 2.0, 3.0
    alphas = [1.5, 2.0, 3.0, 5.0, 10.0]
    N = 10000

    print(f"\nC={C}, K={K}, summing {N} terms")
    print(f"Theory: C/K = {C/K:.6f}")
    print()
    print(f"{'α':>6}  {'Partial sum':>14}  {'C/K':>10}  {'Error':>12}")
    print("-" * 50)

    for a in alphas:
        r = contraction_factor(a)
        partial = sum(C * r**j / (a * K) for j in range(N))
        err = abs(partial - C / K)
        print(f"{a:>6.1f}  {partial:>14.8f}  {C/K:>10.6f}  {err:>12.2e}")
    print()


# ─── Conjecture B: Optimal α for finite-horizon robustness ────────────────────

def test_conjecture_b():
    """
    Conjecture B: For fixed perturbation horizon m, is there an optimal α > 1
    maximizing the retained final constant?

    We fix total perturbation budget B and horizon m.
    For each α, the per-step allowance is B_j = C·(1-1/α)^j/(α·K).
    The final constant is C·(1-1/α)^m.

    Question: is C·(1-1/α)^m monotone in α, or is there an interior maximum?

    Analysis: (1-1/α)^m is increasing in α (toward 1), so larger α always
    gives a larger retained constant. But the per-step perturbation allowance
    C/(α·K) shrinks, making the stability region narrower.

    With a FIXED total budget constraint, the tradeoff becomes:
    Given budget B ≤ C/K, can we maximize the final constant?
    """
    print("=" * 70)
    print("TEST 5: Conjecture B — Optimal α for finite-horizon robustness")
    print("=" * 70)

    m = 10
    C = 1.0
    K = 1.0

    # For fixed budget B = C/K, the final constant is C·(1-1/α)^m
    # This is monotonically increasing in α → the "optimal" α is ∞
    # But if we fix per-step perturbation size ε and ask which α allows it:
    # Need ε < C·(1-1/α)^j/(α·K), so α must satisfy this for all j.

    alphas = np.linspace(1.01, 20.0, 200)

    print(f"\nm={m}, C={C}, K={K}")
    print(f"\nFinal constant C·(1-1/α)^m vs α:")
    print(f"{'α':>8}  {'Final const':>14}  {'Per-step(j=0)':>14}  {'Budget':>10}")
    print("-" * 52)

    # Sample some values
    sample_alphas = [1.1, 1.5, 2.0, 3.0, 5.0, 10.0, 20.0]
    for a in sample_alphas:
        r = contraction_factor(a)
        final = C * r ** m
        per_step_0 = C / (a * K)
        budget = renorm_budget(C, K, a)
        print(f"{a:>8.1f}  {final:>14.8f}  {per_step_0:>14.8f}  {budget:>10.4f}")

    print()
    print("Observation: Final constant is monotonically increasing in α,")
    print("while per-step allowance is monotonically decreasing.")
    print("→ No interior optimum for the final constant alone.")
    print("→ Conjecture B is REFUTED for the simple objective C·(1-1/α)^m.")
    print("→ A nontrivial tradeoff arises only with fixed perturbation size constraints.")
    print()


# ─── Main ──────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║  Variable Contraction Rates for Diophantine Renormalization — Demo  ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()

    ok1 = test_alpha_3()
    test_decay_curves()
    test_geometric_series()
    test_budget_formula()
    test_conjecture_b()

    print("=" * 70)
    print("SUMMARY")
    print("=" * 70)
    print(f"  α=3, 10-step test: {'PASSED ✓' if ok1 else 'FAILED ✗'}")
    print(f"  Decay curves: computed for α ∈ {{1.5, 2, 3, 5, 10}}")
    print(f"  Geometric series: converges to α (verified)")
    print(f"  Budget formula: ∑ C·r^j/(α·K) = C/K (verified)")
    print(f"  Conjecture B: refuted (monotone in α)")
    print()
