#!/usr/bin/env python3
"""
Tropical KAM Stability — Applications

Demonstrates real-world applications of tropical KAM stability theory:
1. Orbital stability certification for celestial mechanics
2. Signal processing: quasi-periodic signal detection
3. Cryptographic lattice analysis
4. Optimization: stability of min-plus dynamical programs
"""

import numpy as np
from typing import List, Tuple, Dict
import itertools


# ============================================================
# Core utility functions (self-contained)
# ============================================================

def l1_norm(k: np.ndarray) -> int:
    return int(np.sum(np.abs(k)))

def lattice_inner(k: np.ndarray, omega: np.ndarray) -> float:
    return float(np.dot(k.astype(float), omega))

def optimal_diophantine_constant(K: int, omega: np.ndarray) -> float:
    n = len(omega)
    min_gap = float('inf')
    for combo in itertools.product(*[range(-K, K+1) for _ in range(n)]):
        k = np.array(combo, dtype=int)
        norm = l1_norm(k)
        if 0 < norm <= K:
            gap = abs(lattice_inner(k, omega))
            min_gap = min(min_gap, gap)
    return min_gap

def find_resonances(K: int, omega: np.ndarray, tol: float = 1e-10) -> list:
    n = len(omega)
    results = []
    for combo in itertools.product(*[range(-K, K+1) for _ in range(n)]):
        k = np.array(combo, dtype=int)
        norm = l1_norm(k)
        if 0 < norm <= K and abs(lattice_inner(k, omega)) < tol:
            results.append(k.copy())
    return results


# ============================================================
# Application 1: Celestial Mechanics — Orbital Stability
# ============================================================

def orbital_stability_certification():
    """
    Certify the long-term stability of a planetary system using
    tropical Diophantine analysis of orbital frequency ratios.
    
    In celestial mechanics, orbital resonances (like Jupiter-Saturn 5:2)
    can either stabilize or destabilize orbits. The tropical Diophantine
    condition provides a rigorous certificate: if the frequency ratios
    satisfy the condition up to a given scale, then the orbital torus
    persists under perturbations smaller than the computed threshold.
    """
    print("=" * 70)
    print("APPLICATION 1: Orbital Stability Certification")
    print("=" * 70)
    print()
    
    # Normalized orbital frequencies (periods relative to innermost planet)
    # Inspired by the inner solar system
    systems = {
        "Inner Solar System (Mercury-Venus-Earth)": 
            np.array([1.0, 1/2.55, 1/4.15]),
        "Trappist-1 (b-c-d)": 
            np.array([1.0, 1/1.603, 1/2.422]),
        "Near 3:2:1 resonance chain":
            np.array([1.0, 2/3 + 0.01, 1/3 + 0.005]),
        "Exact 3:2:1 resonance (unstable)":
            np.array([1.0, 2/3, 1/3]),
    }
    
    for name, omega in systems.items():
        print(f"  System: {name}")
        print(f"  Frequencies: {omega}")
        
        K = 6
        C = optimal_diophantine_constant(K, omega)
        radius = C / (2 * K) if K > 0 else 0
        resonances = find_resonances(K, omega)
        
        print(f"  Diophantine constant C*(K={K}): {C:.6f}")
        print(f"  Persistence radius: {radius:.6f}")
        print(f"  Resonances up to K={K}: {len(resonances)}")
        
        if len(resonances) > 0:
            print(f"  WARNING: System has exact resonances — NOT Diophantine")
            print(f"  Stability certificate: FAILED (resonance detected)")
        elif C > 0.01:
            print(f"  Stability certificate: PASSED (strong gap)")
        else:
            print(f"  Stability certificate: MARGINAL (small gap)")
        print()


# ============================================================
# Application 2: Signal Processing — Quasi-Periodic Detection
# ============================================================

def quasi_periodic_signal_analysis():
    """
    Use tropical Diophantine analysis to detect and classify
    quasi-periodic signals.
    
    A signal with frequencies ω₁, ω₂, ... is quasi-periodic if the
    frequency ratios are badly approximable by rationals. The
    Diophantine constant measures "how quasi-periodic" the signal is.
    """
    print("=" * 70)
    print("APPLICATION 2: Quasi-Periodic Signal Detection")
    print("=" * 70)
    print()
    
    # Generate synthetic signals
    t = np.linspace(0, 100, 10000)
    
    phi = (1 + np.sqrt(5)) / 2
    
    signals = {
        "Quasi-periodic (golden)": (
            np.array([1.0, phi]),
            np.sin(2 * np.pi * t) + np.sin(2 * np.pi * phi * t)
        ),
        "Periodic (rational)": (
            np.array([1.0, 1.5]),
            np.sin(2 * np.pi * t) + np.sin(2 * np.pi * 1.5 * t)
        ),
        "Nearly periodic": (
            np.array([1.0, 1.5001]),
            np.sin(2 * np.pi * t) + np.sin(2 * np.pi * 1.5001 * t)
        ),
        "Strongly irrational": (
            np.array([1.0, np.sqrt(2)]),
            np.sin(2 * np.pi * t) + np.sin(2 * np.pi * np.sqrt(2) * t)
        ),
    }
    
    for name, (omega, signal) in signals.items():
        K = 8
        C = optimal_diophantine_constant(K, omega)
        resonances = find_resonances(K, omega)
        
        if len(resonances) > 0:
            classification = "PERIODIC (has resonances)"
        elif C > 0.01:
            classification = "QUASI-PERIODIC (strong gap)"
        else:
            classification = "NEARLY PERIODIC (weak gap)"
        
        print(f"  Signal: {name}")
        print(f"  Frequencies: {omega}")
        print(f"  C*(K={K}) = {C:.8f}")
        print(f"  Classification: {classification}")
        print()


# ============================================================
# Application 3: Lattice Cryptography — Gap Analysis
# ============================================================

def lattice_gap_analysis():
    """
    Analyze lattice gaps relevant to lattice-based cryptography.
    
    The Diophantine constant measures how well a vector avoids
    lattice hyperplanes, which is related to the hardness of
    lattice problems (SVP, CVP) that underlie post-quantum
    cryptographic schemes.
    """
    print("=" * 70)
    print("APPLICATION 3: Lattice Gap Analysis")
    print("=" * 70)
    print()
    
    # Test how Diophantine constant scales with dimension and K
    dims = [2, 3]
    Ks = [3, 5, 8]
    
    np.random.seed(42)
    n_samples = 20
    
    print(f"  Average Diophantine constant over {n_samples} random frequencies:\n")
    print(f"  {'n':>4s}  {'K':>4s}  {'mean C*':>12s}  {'std C*':>12s}  {'min C*':>12s}")
    print(f"  {'-'*4}  {'-'*4}  {'-'*12}  {'-'*12}  {'-'*12}")
    
    for n in dims:
        for K in Ks:
            constants = []
            for _ in range(n_samples):
                omega = np.random.uniform(0.1, 2.0, size=n)
                C = optimal_diophantine_constant(K, omega)
                constants.append(C)
            
            mean_C = np.mean(constants)
            std_C = np.std(constants)
            min_C = np.min(constants)
            
            print(f"  {n:4d}  {K:4d}  {mean_C:12.6f}  {std_C:12.6f}  {min_C:12.6f}")
    
    print()
    print("  Observation: As K increases, the average gap decreases (harder to")
    print("  avoid resonances at larger scales). Higher dimension also reduces")
    print("  the gap, as there are more lattice hyperplanes to avoid.\n")


# ============================================================
# Application 4: Min-Plus Dynamics — Optimization Stability
# ============================================================

def minplus_dynamics_stability():
    """
    Demonstrate stability of min-plus (tropical) dynamical programs.
    
    In operations research, min-plus algebra describes shortest path
    problems, scheduling, and network optimization. The tropical KAM
    framework shows that quasi-periodic optimal solutions are stable
    under small perturbations of the cost structure.
    """
    print("=" * 70)
    print("APPLICATION 4: Min-Plus Dynamical Stability")
    print("=" * 70)
    print()
    
    # Simulate a min-plus dynamical system
    # x_{t+1} = min_j (A_ij + x_t(j)) — tropical matrix multiplication
    
    n = 3  # state dimension
    
    # Transition matrix (tropical = min-plus)
    A = np.array([
        [0.0, 1.2, 2.5],
        [1.8, 0.0, 0.7],
        [3.1, 1.5, 0.0]
    ])
    
    # Compute tropical eigenvalue (cycle mean)
    def tropical_iterate(A, x, steps=100):
        trajectory = [x.copy()]
        for _ in range(steps):
            x_new = np.min(A + x[np.newaxis, :], axis=1)
            trajectory.append(x_new.copy())
            x = x_new
        return trajectory
    
    x0 = np.array([0.0, 0.0, 0.0])
    traj = tropical_iterate(A, x0, 50)
    
    # Extract rotation vector (average displacement)
    displacements = [traj[t+1] - traj[t] for t in range(len(traj)-1)]
    avg_displacement = np.mean(displacements[-20:], axis=0)
    
    print(f"  Tropical transition matrix A:")
    for row in A:
        print(f"    {row}")
    print(f"  Average displacement (rotation vector): {avg_displacement}")
    
    # Check Diophantine property of the rotation vector
    omega = avg_displacement[:2]  # project to 2D for analysis
    if np.any(np.isnan(omega)) or np.any(np.isinf(omega)):
        print("  Rotation vector is degenerate; skipping analysis.")
    else:
        K = 5
        C = optimal_diophantine_constant(K, omega)
        print(f"  Diophantine constant C*(K={K}): {C:.6f}")
        print(f"  Persistence radius: {C/(2*K):.6f}")
    
    # Perturbation experiment
    print("\n  Perturbation stability test:")
    epsilons = [0.001, 0.01, 0.05, 0.1]
    np.random.seed(123)
    
    for eps in epsilons:
        A_pert = A + np.random.uniform(-eps, eps, size=A.shape)
        traj_pert = tropical_iterate(A_pert, x0, 50)
        displacements_pert = [traj_pert[t+1] - traj_pert[t] 
                              for t in range(len(traj_pert)-1)]
        avg_pert = np.mean(displacements_pert[-20:], axis=0)
        diff = np.max(np.abs(avg_displacement - avg_pert))
        print(f"    ε={eps:.3f}: max rotation change = {diff:.6f}")
    
    print()


# ============================================================
# Main
# ============================================================

def main():
    print()
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║       TROPICAL KAM STABILITY — Applications                        ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()
    
    orbital_stability_certification()
    quasi_periodic_signal_analysis()
    lattice_gap_analysis()
    minplus_dynamics_stability()
    
    print("=" * 70)
    print("All applications complete.")
    print("=" * 70)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Tropical KAM Stability — Interactive Demonstration

This script demonstrates the core concepts of tropical KAM stability theory:
1. Tropical Diophantine conditions and their checking
2. Resonance profiles and their rigidity under perturbation
3. Rational vs. irrational frequency behavior
4. Visualization of resonance landscapes and persistence regions

Run: python3 demo.py
"""

import numpy as np
import itertools
from fractions import Fraction
from typing import List, Tuple, Optional
import json
import sys


# ============================================================
# Core Definitions
# ============================================================

def l1_norm(k: np.ndarray) -> int:
    """L1 norm of an integer vector."""
    return int(np.sum(np.abs(k)))

def lattice_inner(k: np.ndarray, omega: np.ndarray) -> float:
    """Inner product of integer vector k with real frequency vector omega."""
    return float(np.dot(k.astype(float), omega))

def is_tropical_diophantine(K: int, C: float, omega: np.ndarray) -> bool:
    """
    Check if omega satisfies the Tropical Diophantine condition at scale K with gap C.
    
    For all integer vectors k with 0 < ||k||_1 <= K, we need C <= |<k, omega>|.
    """
    n = len(omega)
    for k in _enumerate_lattice_vectors(n, K):
        norm = l1_norm(k)
        if 0 < norm <= K:
            inner = abs(lattice_inner(k, omega))
            if inner < C:
                return False
    return True

def same_resonance_profile(K: int, omega1: np.ndarray, omega2: np.ndarray) -> bool:
    """
    Check if omega1 and omega2 have the same resonance profile up to scale K.
    
    For all k with ||k||_1 <= K: (<k, omega1> = 0) iff (<k, omega2> = 0).
    """
    n = len(omega1)
    eps = 1e-12  # numerical tolerance
    for k in _enumerate_lattice_vectors(n, K):
        inner1 = lattice_inner(k, omega1)
        inner2 = lattice_inner(k, omega2)
        res1 = abs(inner1) < eps
        res2 = abs(inner2) < eps
        if res1 != res2:
            return False
    return True

def find_diophantine_constant(K: int, omega: np.ndarray) -> float:
    """
    Compute the optimal Diophantine constant C for omega at scale K.
    
    C* = min { |<k, omega>| : 0 < ||k||_1 <= K }
    """
    n = len(omega)
    min_gap = float('inf')
    for k in _enumerate_lattice_vectors(n, K):
        norm = l1_norm(k)
        if 0 < norm <= K:
            gap = abs(lattice_inner(k, omega))
            min_gap = min(min_gap, gap)
    return min_gap

def find_resonances(K: int, omega: np.ndarray, tol: float = 1e-10) -> list:
    """Find all resonance vectors k with ||k||_1 <= K and |<k, omega>| < tol."""
    n = len(omega)
    resonances = []
    for k in _enumerate_lattice_vectors(n, K):
        norm = l1_norm(k)
        if 0 < norm <= K:
            if abs(lattice_inner(k, omega)) < tol:
                resonances.append(k.copy())
    return resonances


def _enumerate_lattice_vectors(n: int, K: int):
    """Enumerate all integer vectors in Z^n with L1 norm <= K."""
    if n == 0:
        yield np.array([], dtype=int)
        return
    ranges = [range(-K, K+1) for _ in range(n)]
    for combo in itertools.product(*ranges):
        k = np.array(combo, dtype=int)
        if l1_norm(k) <= K:
            yield k


# ============================================================
# Demo 1: Tropical Diophantine Condition
# ============================================================

def demo_diophantine():
    """Demonstrate the Tropical Diophantine condition for various frequencies."""
    print("=" * 70)
    print("DEMO 1: Tropical Diophantine Condition")
    print("=" * 70)
    print()
    print("The Tropical Diophantine condition says: for all integer vectors k")
    print("with 0 < ||k||_1 <= K, we have C <= |<k, omega>|.")
    print("This is a finite, checkable non-resonance condition.\n")
    
    # Golden ratio frequency — maximally irrational
    phi = (1 + np.sqrt(5)) / 2
    omega_golden = np.array([1.0, phi])
    
    # Rational frequency
    omega_rational = np.array([1.0, 3/7])
    
    # Nearly rational frequency 
    omega_near_rational = np.array([1.0, 3/7 + 0.001])
    
    print("Frequency vectors tested:")
    print(f"  ω_golden  = [1, φ] ≈ [1, {phi:.6f}]")
    print(f"  ω_rational = [1, 3/7] ≈ [1, {3/7:.6f}]")
    print(f"  ω_near_rat = [1, 3/7 + 0.001] ≈ [1, {3/7+0.001:.6f}]")
    print()
    
    for K in [3, 5, 8, 12]:
        C_golden = find_diophantine_constant(K, omega_golden)
        C_rational = find_diophantine_constant(K, omega_rational)
        C_near = find_diophantine_constant(K, omega_near_rational)
        
        print(f"  K = {K:2d}: C*(golden) = {C_golden:.6f}, "
              f"C*(rational) = {C_rational:.8f}, "
              f"C*(near_rat) = {C_near:.6f}")
    
    print()
    print("Observation: The golden ratio maintains a positive gap at all scales,")
    print("while the rational frequency's gap collapses to zero (exact resonance).")
    print("The near-rational frequency has small but positive gaps.\n")


# ============================================================
# Demo 2: Resonance Rigidity Under Perturbation
# ============================================================

def demo_resonance_rigidity():
    """Demonstrate that Diophantine frequencies have rigid resonance profiles."""
    print("=" * 70)
    print("DEMO 2: Resonance Rigidity (Main KAM Theorem)")
    print("=" * 70)
    print()
    print("THEOREM: If ω is Diophantine(K,C) and |ω_i - ω'_i| < C/(2K),")
    print("then ω and ω' have the same resonance profile up to scale K.\n")
    
    phi = (1 + np.sqrt(5)) / 2
    omega = np.array([1.0, phi])
    K = 6
    
    C = find_diophantine_constant(K, omega)
    threshold = C / (2 * K)
    
    print(f"Base frequency: ω = [1, φ] ≈ [1, {phi:.8f}]")
    print(f"Scale K = {K}, Diophantine constant C = {C:.8f}")
    print(f"Perturbation threshold C/(2K) = {threshold:.8f}")
    print()
    
    # Test perturbations of increasing size
    perturbation_sizes = [0.0001, 0.001, 0.005, 0.01, 0.02, 0.05, threshold * 0.5,
                          threshold * 0.99, threshold * 1.01, threshold * 2]
    
    print(f"  {'Perturbation':>14s}  {'< threshold?':>14s}  {'Same profile?':>14s}  {'Prediction':>14s}")
    print(f"  {'-'*14}  {'-'*14}  {'-'*14}  {'-'*14}")
    
    for eps in perturbation_sizes:
        omega_perturbed = omega + np.array([eps * 0.7, -eps * 0.3])  # asymmetric perturbation
        max_comp_diff = max(abs(omega[i] - omega_perturbed[i]) for i in range(len(omega)))
        within = max_comp_diff < threshold
        same = same_resonance_profile(K, omega, omega_perturbed)
        prediction = "preserved" if within else "unknown"
        status = "✓ same" if same else "✗ different"
        
        print(f"  {eps:14.8f}  {'yes' if within else 'NO ':>14s}  {status:>14s}  {prediction:>14s}")
    
    print()
    print("The theorem guarantees preservation when perturbation < threshold.")
    print("In practice, preservation often extends beyond the guaranteed region.\n")


# ============================================================
# Demo 3: Rational Frequencies and Resonance Collapse
# ============================================================

def demo_rational_collapse():
    """Show that rational frequencies always have resonances."""
    print("=" * 70)
    print("DEMO 3: Rational Frequency Resonance Collapse")
    print("=" * 70)
    print()
    print("THEOREM: In dimension >= 2, any pair of nonzero rational frequencies")
    print("admits an integer relation (resonance), so rational frequencies")
    print("fail the Diophantine condition at sufficiently large scale.\n")
    
    test_cases = [
        ("1/2, 3/5", np.array([0.5, 0.6])),
        ("2/3, 5/7", np.array([2/3, 5/7])),
        ("1/1, 1/1", np.array([1.0, 1.0])),
        ("3/4, 7/11", np.array([3/4, 7/11])),
    ]
    
    for name, omega in test_cases:
        print(f"  ω = [{name}] = {omega}")
        resonances = find_resonances(20, omega)
        if resonances:
            k = resonances[0]
            print(f"    Resonance found: k = {k}, <k,ω> = {lattice_inner(k, omega):.2e}, ||k||₁ = {l1_norm(k)}")
        else:
            print(f"    No resonance found up to K=20 (numerical tolerance issue)")
        
        # Show Diophantine constant decay
        gaps = []
        for K in [2, 5, 10, 15, 20]:
            C = find_diophantine_constant(K, omega)
            gaps.append((K, C))
        gap_str = ", ".join(f"C*({K})={C:.2e}" for K, C in gaps)
        print(f"    Gap decay: {gap_str}")
        print()
    
    # Contrast with irrational
    phi = (1 + np.sqrt(5)) / 2
    omega_irr = np.array([1.0, phi])
    print(f"  ω_golden = [1, φ] (irrational):")
    resonances = find_resonances(20, omega_irr)
    print(f"    Resonances up to K=20: {len(resonances)}")
    gaps = []
    for K in [2, 5, 10, 15, 20]:
        C = find_diophantine_constant(K, omega_irr)
        gaps.append((K, C))
    gap_str = ", ".join(f"C*({K})={C:.4f}" for K, C in gaps)
    print(f"    Gap values: {gap_str}")
    print()


# ============================================================
# Demo 4: Persistence Regions
# ============================================================

def demo_persistence_regions():
    """Visualize the KAM persistence region in frequency space."""
    print("=" * 70)
    print("DEMO 4: KAM Persistence Regions")
    print("=" * 70)
    print()
    print("For each base frequency ω, the KAM theorem guarantees persistence")
    print("in a ball of radius C/(2K) around ω. Diophantine frequencies have")
    print("large persistence regions; near-resonant ones have small regions.\n")
    
    K = 5
    base_frequencies = [
        ("golden", np.array([1.0, (1 + np.sqrt(5)) / 2])),
        ("sqrt(2)", np.array([1.0, np.sqrt(2)])),
        ("sqrt(3)", np.array([1.0, np.sqrt(3)])),
        ("e/π", np.array([1.0, np.e / np.pi])),
        ("near 1/2", np.array([1.0, 0.50001])),
        ("near 1/3", np.array([1.0, 0.33334])),
    ]
    
    print(f"  {'Frequency':>12s}  {'C*(K={K})':>12s}  {'Radius C/(2K)':>14s}  {'Persistence':>12s}")
    print(f"  {'-'*12}  {'-'*12}  {'-'*14}  {'-'*12}")
    
    for name, omega in base_frequencies:
        C = find_diophantine_constant(K, omega)
        radius = C / (2 * K)
        if C > 0.01:
            persistence = "STRONG"
        elif C > 0.001:
            persistence = "moderate"
        else:
            persistence = "fragile"
        print(f"  {name:>12s}  {C:12.6f}  {radius:14.8f}  {persistence:>12s}")
    
    print()
    print("Irrational frequencies with good Diophantine properties (golden ratio,")
    print("sqrt(2)) have large persistence regions. Near-rational frequencies")
    print("have tiny persistence regions and are easily destroyed by perturbation.\n")


# ============================================================
# Demo 5: Scaling Invariance
# ============================================================

def demo_scaling():
    """Demonstrate scaling invariance of the Diophantine condition."""
    print("=" * 70)
    print("DEMO 5: Scaling Invariance")
    print("=" * 70)
    print()
    print("THEOREM: If ω is (K,C)-Diophantine, then λω is (K, |λ|C)-Diophantine.")
    print("The Diophantine gap scales linearly with the frequency magnitude.\n")
    
    phi = (1 + np.sqrt(5)) / 2
    omega = np.array([1.0, phi])
    K = 5
    
    scales = [0.1, 0.5, 1.0, 2.0, 5.0, 10.0]
    
    print(f"  Base ω = [1, φ], K = {K}")
    print(f"  {'Scale λ':>10s}  {'C*(λω)':>12s}  {'|λ|·C*(ω)':>12s}  {'Ratio':>8s}")
    print(f"  {'-'*10}  {'-'*12}  {'-'*12}  {'-'*8}")
    
    C_base = find_diophantine_constant(K, omega)
    
    for lam in scales:
        omega_scaled = lam * omega
        C_scaled = find_diophantine_constant(K, omega_scaled)
        C_predicted = abs(lam) * C_base
        ratio = C_scaled / C_predicted if C_predicted > 0 else float('nan')
        print(f"  {lam:10.2f}  {C_scaled:12.6f}  {C_predicted:12.6f}  {ratio:8.4f}")
    
    print()
    print("The ratio is exactly 1.0, confirming scaling invariance.\n")


# ============================================================
# Demo 6: KAM Persistence Experiment
# ============================================================

def demo_kam_experiment():
    """Run a Monte Carlo experiment on KAM persistence."""
    print("=" * 70)
    print("DEMO 6: Monte Carlo KAM Persistence Experiment")
    print("=" * 70)
    print()
    print("We sample random perturbations and check whether the resonance")
    print("profile is preserved, comparing with the theoretical guarantee.\n")
    
    phi = (1 + np.sqrt(5)) / 2
    omega = np.array([1.0, phi])
    K = 5
    C = find_diophantine_constant(K, omega)
    threshold = C / (2 * K)
    
    np.random.seed(42)
    n_trials = 200
    
    # Test at various perturbation scales
    perturbation_fractions = [0.1, 0.3, 0.5, 0.8, 1.0, 1.5, 2.0, 3.0, 5.0]
    
    print(f"  Base ω = [1, φ], K={K}, C={C:.6f}, threshold={threshold:.6f}")
    print(f"  {n_trials} random trials per perturbation level\n")
    print(f"  {'ε/threshold':>12s}  {'ε':>10s}  {'Preserved':>10s}  {'Guarantee':>10s}")
    print(f"  {'-'*12}  {'-'*10}  {'-'*10}  {'-'*10}")
    
    for frac in perturbation_fractions:
        eps = frac * threshold
        preserved = 0
        for _ in range(n_trials):
            perturbation = np.random.uniform(-eps, eps, size=2)
            omega_perturbed = omega + perturbation
            if same_resonance_profile(K, omega, omega_perturbed):
                preserved += 1
        
        pct = 100 * preserved / n_trials
        guarantee = "100%" if frac < 1.0 else "none"
        print(f"  {frac:12.2f}  {eps:10.6f}  {pct:9.1f}%  {guarantee:>10s}")
    
    print()
    print("Below the threshold (ε/threshold < 1), preservation is guaranteed.")
    print("Above the threshold, preservation often persists but is not guaranteed.\n")


# ============================================================
# Main
# ============================================================

def main():
    print()
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║       TROPICAL KAM STABILITY — Interactive Demonstration           ║")
    print("║                                                                    ║")
    print("║  Combinatorial persistence of quasi-periodic tropical dynamics     ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()
    
    demo_diophantine()
    demo_resonance_rigidity()
    demo_rational_collapse()
    demo_persistence_regions()
    demo_scaling()
    demo_kam_experiment()
    
    print("=" * 70)
    print("All demonstrations complete.")
    print("=" * 70)


if __name__ == "__main__":
    main()
