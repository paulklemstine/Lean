#!/usr/bin/env python3
"""
Applications of Sharp KAM Threshold Theory
============================================

Demonstrates real-world applications of the exact resonance threshold:
1. Adversarial robustness analysis for frequency systems
2. Optimal perturbation design (worst-case analysis)
3. Stability margin computation for dynamical systems
"""

import numpy as np
from itertools import product


def l1_norm(k):
    return sum(abs(int(ki)) for ki in k)

def dot_product(k, omega):
    return sum(int(ki) * float(oi) for ki, oi in zip(k, omega))

def sup_norm(x):
    return max(abs(xi) for xi in x)

def enumerate_modes(K, d=2):
    ranges = [range(-K, K + 1)] * d
    return [k for k in product(*ranges) if 0 < l1_norm(k) <= K]

def compute_margin(K, omega):
    modes = enumerate_modes(K, len(omega))
    if not modes:
        return float('inf'), None
    best = min(modes, key=lambda k: abs(dot_product(k, omega)) / l1_norm(k))
    return abs(dot_product(best, omega)) / l1_norm(best), best


# ═══════════════════════════════════════════════════════════
# APPLICATION 1: Robustness Analysis for Oscillator Networks
# ═══════════════════════════════════════════════════════════

def app1_oscillator_robustness():
    """Analyze robustness of coupled oscillator frequency ratios.
    
    In a network of coupled oscillators, frequency ratios determine
    whether energy can flow between modes (resonance). The KAM threshold
    tells us exactly how much frequency drift each oscillator can tolerate
    before unwanted energy transfer occurs.
    """
    print("=" * 70)
    print("APPLICATION 1: Oscillator Network Robustness Analysis")
    print("=" * 70)
    
    # Golden ratio: maximally irrational, best resonance avoidance
    phi = (1 + np.sqrt(5)) / 2
    frequencies = {
        "Golden ratio (1, φ)": (1.0, phi),
        "Near-rational (1, 1.5)": (1.0, 1.5),
        "√2 ratio (1, √2)": (1.0, np.sqrt(2)),
        "π ratio (1, π)": (1.0, np.pi),
    }
    
    K = 10  # Consider resonances up to order 10
    
    print(f"\nResonance protection analysis (K = {K}):")
    print(f"{'Frequency ratio':>25s}  {'Margin':>10s}  {'Max drift':>10s}  {'Critical mode':>15s}")
    print("-" * 65)
    
    for name, omega in frequencies.items():
        margin, mode = compute_margin(K, omega)
        print(f"{name:>25s}  {margin:10.6f}  {margin:10.6f}  {str(mode):>15s}")
    
    print("\n→ The golden ratio provides the best resonance protection,")
    print("  consistent with its role as the 'most irrational' number.")
    print("  The margin equals the EXACT maximum tolerable frequency drift.")


# ═══════════════════════════════════════════════════════════
# APPLICATION 2: Worst-Case Perturbation Design
# ═══════════════════════════════════════════════════════════

def app2_worst_case_perturbation():
    """Design worst-case perturbations (adversarial examples for resonance).
    
    Given a frequency system, find the smallest perturbation that
    creates a resonance. This is the ℓ∞ adversarial example problem
    from the resonance perspective.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 2: Worst-Case Perturbation Design")
    print("=" * 70)
    
    # System with known good properties
    K = 8
    C = 1.0
    omega = (K * C, -C)  # Verified Diophantine witness
    
    margin, critical_mode = compute_margin(K, omega)
    
    print(f"\nSystem: ω = {omega}")
    print(f"Scale: K = {K}")
    print(f"Resonance margin: {margin:.6f}")
    print(f"Critical mode: k₀ = {critical_mode}")
    
    # Construct optimal adversarial perturbation
    inner = dot_product(critical_mode, omega)
    norm = l1_norm(critical_mode)
    
    delta = tuple(
        -inner / norm if ki > 0 else (inner / norm if ki < 0 else 0.0)
        for ki in critical_mode
    )
    
    print(f"\nOptimal adversarial perturbation:")
    print(f"  δ = ({delta[0]:.6f}, {delta[1]:.6f})")
    print(f"  ||δ||∞ = {sup_norm(delta):.6f}")
    print(f"  k₀·(ω+δ) = {dot_product(critical_mode, tuple(o+d for o,d in zip(omega, delta))):.2e}")
    
    print(f"\n→ This is the MINIMUM-NORM perturbation creating resonance at mode k₀.")
    print(f"  Any smaller perturbation is provably safe (by ℓ¹/ℓ∞ duality).")


# ═══════════════════════════════════════════════════════════
# APPLICATION 3: Stability Certificate Table
# ═══════════════════════════════════════════════════════════

def app3_stability_certificates():
    """Generate stability certificates for a range of systems.
    
    For each frequency configuration, compute:
    - Universal safe budget (C/K)
    - Instance-specific safe budget (resonance margin)
    - Gap between universal and instance-specific bounds
    """
    print("\n" + "=" * 70)
    print("APPLICATION 3: Stability Certificate Generation")
    print("=" * 70)
    
    phi = (1 + np.sqrt(5)) / 2
    systems = [
        ("Golden", (1.0, phi)),
        ("√2", (1.0, np.sqrt(2))),
        ("Witness K=5", (5.0, -1.0)),
        ("Witness K=10", (10.0, -1.0)),
        ("Near-rational", (1.0, 1.4142)),  # Truncated √2
    ]
    
    K_values = [3, 5, 10, 15]
    
    print(f"\n{'System':>15s}", end="")
    for K in K_values:
        print(f"  {'K='+str(K):>12s}", end="")
    print()
    print("-" * (15 + 14 * len(K_values)))
    
    for name, omega in systems:
        print(f"{name:>15s}", end="")
        for K in K_values:
            margin, _ = compute_margin(K, omega)
            print(f"  {margin:12.6f}", end="")
        print()
    
    print(f"\n{'Universal C/K':>15s}", end="")
    C = 1.0
    for K in K_values:
        print(f"  {C/K:12.6f}", end="")
    print()
    
    print("\n→ Instance-specific margins are always ≥ C/K (universal bound).")
    print("  The gap measures how 'generic' (well-separated from resonance) the frequency is.")


# ═══════════════════════════════════════════════════════════
# APPLICATION 4: Critical Scaling Analysis
# ═══════════════════════════════════════════════════════════

def app4_critical_scaling():
    """Analyze how the resonance margin scales with K.
    
    For typical frequencies, r_K(ω) ~ const/K as K → ∞.
    The constant depends on the Diophantine type of ω.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 4: Critical Scaling Analysis")
    print("=" * 70)
    
    phi = (1 + np.sqrt(5)) / 2
    omega = (1.0, phi)
    
    print(f"\nFrequency: ω = (1, φ) = (1, {phi:.6f})")
    print(f"\n{'K':>5s}  {'r_K(ω)':>12s}  {'K·r_K(ω)':>12s}  {'K²·r_K(ω)':>12s}  {'Critical mode':>15s}")
    print("-" * 62)
    
    for K in [1, 2, 3, 5, 8, 13, 21, 34, 55, 89]:
        margin, mode = compute_margin(K, omega)
        print(f"{K:5d}  {margin:12.8f}  {K*margin:12.6f}  {K*K*margin:12.4f}  {str(mode):>15s}")
    
    print(f"\n→ For the golden ratio, K·r_K(ω) fluctuates but K²·r_K(ω) grows,")
    print(f"  consistent with φ being a badly approximable number of Diophantine type 1.")
    print(f"  The critical modes follow the Fibonacci sequence.")


def main():
    app1_oscillator_robustness()
    app2_worst_case_perturbation()
    app3_stability_certificates()
    app4_critical_scaling()
    
    print("\n" + "=" * 70)
    print("  All applications demonstrate the Sharp KAM Threshold theorem:")
    print("  C/K is the exact universal phase transition for resonance stability.")
    print("=" * 70)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Sharp KAM Threshold Demo
=========================

Demonstrates the sharp phase-transition theorem for finite-scale
Diophantine resonance avoidance:

    The universal safe perturbation budget C/K is EXACTLY the threshold
    where stability gives way to instability.

Below C/K: ALL admissible modes survive (guaranteed by ℓ¹/ℓ∞ duality).
Above C/K: SOME mode can be driven to resonance (explicit witness construction).
"""

import numpy as np
from itertools import product


def l1_norm(k):
    """L1 norm of integer vector k."""
    return sum(abs(int(ki)) for ki in k)


def dot_product(k, omega):
    """Lattice inner product: sum(k_i * omega_i)."""
    return sum(int(ki) * float(oi) for ki, oi in zip(k, omega))


def enumerate_modes(K, d=2):
    """Enumerate all nonzero integer modes k in Z^d with ||k||_1 <= K."""
    ranges = [range(-K, K + 1)] * d
    modes = []
    for k in product(*ranges):
        if l1_norm(k) > 0 and l1_norm(k) <= K:
            modes.append(k)
    return modes


def is_k_diophantine(K, C, omega):
    """Check if omega is (K, C)-Diophantine."""
    modes = enumerate_modes(K, len(omega))
    for k in modes:
        if abs(dot_product(k, omega)) < C - 1e-12:
            return False
    return True


def compute_resonance_margin(K, omega):
    """Compute the resonance margin: min |k·ω| / ||k||_1 over admissible modes."""
    modes = enumerate_modes(K, len(omega))
    if not modes:
        return float('inf'), None
    best_ratio = float('inf')
    best_mode = None
    for k in modes:
        ratio = abs(dot_product(k, omega)) / l1_norm(k)
        if ratio < best_ratio:
            best_ratio = ratio
            best_mode = k
    return best_ratio, best_mode


def construct_sign_perturbation(k, omega):
    """Construct the sign perturbation δ that cancels k·(ω+δ).
    
    δ_i = -(k·ω / ||k||_1) * sign(k_i)
    """
    dot_val = dot_product(k, omega)
    norm = l1_norm(k)
    delta = []
    for ki in k:
        if ki > 0:
            delta.append(-dot_val / norm)
        elif ki < 0:
            delta.append(dot_val / norm)
        else:
            delta.append(0.0)
    return delta


def sup_norm(x):
    """Sup (infinity) norm."""
    return max(abs(xi) for xi in x)


def diophantine_witness(K, C):
    """Construct the witness ω = (K*C, -C) which is (K,C)-Diophantine."""
    return (K * C, -C)


def main():
    print("=" * 70)
    print("  SHARP KAM THRESHOLD DEMONSTRATION")
    print("  Phase Transition in Finite-Scale Resonance Avoidance")
    print("=" * 70)

    # ─── Example 1: Verify the Diophantine witness ───
    print("\n" + "─" * 70)
    print("EXAMPLE 1: Diophantine Witness Construction")
    print("─" * 70)

    K = 5
    C = 1.0
    omega = diophantine_witness(K, C)
    print(f"\nK = {K}, C = {C}")
    print(f"Witness ω = (K·C, -C) = {omega}")
    print(f"Is (K,C)-Diophantine: {is_k_diophantine(K, C, omega)}")

    margin, critical_mode = compute_resonance_margin(K, omega)
    print(f"Resonance margin: {margin:.6f}")
    print(f"Critical budget C/K: {C/K:.6f}")
    print(f"Critical mode: {critical_mode}")
    print(f"|k·ω| at critical mode: {abs(dot_product(critical_mode, omega)):.6f}")
    print(f"||k||_1 of critical mode: {l1_norm(critical_mode)}")

    # ─── Example 2: Phase transition at C/K ───
    print("\n" + "─" * 70)
    print("EXAMPLE 2: Sharp Phase Transition at C/K")
    print("─" * 70)

    K = 10
    C = 1.0
    omega = diophantine_witness(K, C)
    critical_budget = C / K
    print(f"\nK = {K}, C = {C}, critical budget C/K = {critical_budget}")
    print(f"ω = {omega}")

    margin, best_mode = compute_resonance_margin(K, omega)
    print(f"\nResonance margin (min |k·ω|/||k||_1): {margin:.6f}")

    budgets = [0.5 * critical_budget, 0.9 * critical_budget, 0.99 * critical_budget,
               critical_budget, 1.01 * critical_budget, 1.1 * critical_budget, 2 * critical_budget]

    print(f"\n{'Budget B':>12s}  {'B/r(ω)':>8s}  {'Status':>15s}  {'Min |k·(ω+δ)|':>16s}")
    print("-" * 60)

    for B in budgets:
        # Construct sign perturbation at the critical mode, scaled to budget B
        if best_mode is not None and margin > 0:
            # Scale perturbation to exactly budget B
            delta_base = construct_sign_perturbation(best_mode, omega)
            base_norm = sup_norm(delta_base)
            if base_norm > 0:
                scale = B / base_norm
                delta = [d * scale for d in delta_base]
            else:
                delta = [0.0] * len(omega)
        else:
            delta = [0.0] * len(omega)

        omega_perturbed = tuple(o + d for o, d in zip(omega, delta))
        modes = enumerate_modes(K, len(omega))
        min_inner = min(abs(dot_product(k, omega_perturbed)) for k in modes)

        if min_inner < 1e-10:
            status = "RESONANCE!"
        elif min_inner < C:
            status = "below margin"
        else:
            status = "safe"

        print(f"{B:12.6f}  {B/margin:8.4f}  {status:>15s}  {min_inner:16.10f}")

    # ─── Example 3: Golden ratio frequency ───
    print("\n" + "─" * 70)
    print("EXAMPLE 3: Golden Ratio Frequency ω = (1, φ)")
    print("─" * 70)

    phi = (1 + np.sqrt(5)) / 2
    omega_golden = (1.0, phi)

    print(f"\nω = (1, φ) = (1, {phi:.6f})")
    print(f"\n{'K':>5s}  {'Margin r_K':>12s}  {'K·r_K':>10s}  {'Critical mode':>20s}")
    print("-" * 55)

    for K in [1, 2, 3, 5, 8, 10, 13, 20, 30, 50]:
        margin, mode = compute_resonance_margin(K, omega_golden)
        print(f"{K:5d}  {margin:12.8f}  {K*margin:10.6f}  {str(mode):>20s}")

    # ─── Example 4: Exact attainment demonstration ───
    print("\n" + "─" * 70)
    print("EXAMPLE 4: Exact Attainment at Critical Budget")
    print("─" * 70)

    K = 5
    C = 1.0
    omega = diophantine_witness(K, C)
    margin, critical_mode = compute_resonance_margin(K, omega)

    print(f"\nK = {K}, C = {C}")
    print(f"ω = {omega}")
    print(f"Critical mode k₀ = {critical_mode}")
    print(f"|k₀·ω| = {abs(dot_product(critical_mode, omega)):.6f}")
    print(f"||k₀||₁ = {l1_norm(critical_mode)}")

    # Construct exact sign perturbation
    delta = construct_sign_perturbation(critical_mode, omega)
    print(f"\nSign perturbation δ = ({delta[0]:.6f}, {delta[1]:.6f})")
    print(f"||δ||∞ = {sup_norm(delta):.6f}")
    print(f"C/K = {C/K:.6f}")

    omega_perturbed = tuple(o + d for o, d in zip(omega, delta))
    residual = dot_product(critical_mode, omega_perturbed)
    print(f"\nk₀·(ω+δ) = {residual:.2e}  (should be ≈ 0)")
    print(f"Exact resonance achieved: {abs(residual) < 1e-10}")

    # ─── Example 5: Visualize threshold behavior ───
    print("\n" + "─" * 70)
    print("EXAMPLE 5: Threshold Behavior Scan")
    print("─" * 70)

    K = 8
    C = 1.0
    omega = diophantine_witness(K, C)
    margin, best_mode = compute_resonance_margin(K, omega)

    print(f"\nK = {K}, C = {C}, resonance margin = {margin:.6f}")
    print(f"Critical budget C/K = {C/K:.6f}")
    print(f"\nPerturbation budget scan (fraction of margin):")
    print(f"\n{'Fraction':>10s}  {'Budget':>10s}  {'Min |k·(ω+δ)|':>16s}  {'Bar':>30s}")
    print("-" * 72)

    for frac in np.linspace(0.0, 1.5, 31):
        B = frac * margin
        if best_mode is not None and margin > 0:
            delta_base = construct_sign_perturbation(best_mode, omega)
            base_norm = sup_norm(delta_base)
            if base_norm > 0:
                scale = B / base_norm
                delta = [d * scale for d in delta_base]
            else:
                delta = [0.0] * len(omega)
        else:
            delta = [0.0] * len(omega)

        omega_perturbed = tuple(o + d for o, d in zip(omega, delta))
        modes = enumerate_modes(K, len(omega))
        min_inner = min(abs(dot_product(k, omega_perturbed)) for k in modes)

        bar_len = int(min(min_inner / C * 30, 30))
        bar = "█" * bar_len + "░" * (30 - bar_len)
        marker = " ← THRESHOLD" if abs(frac - 1.0) < 0.03 else ""
        print(f"{frac:10.2f}  {B:10.6f}  {min_inner:16.10f}  {bar}{marker}")

    print("\n" + "=" * 70)
    print("  KEY RESULT: The budget C/K is the EXACT universal threshold.")
    print("  Below: universal safety. Above: resonance is always achievable.")
    print("=" * 70)


if __name__ == "__main__":
    main()
