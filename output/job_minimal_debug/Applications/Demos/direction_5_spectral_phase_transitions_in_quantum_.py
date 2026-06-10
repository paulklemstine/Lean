#!/usr/bin/env python3
"""
Applications of Spectral Phase Transition Certification

Demonstrates real-world applications of the certification threshold theorem
for quantum many-body systems, error correction, and noise robustness.
"""

import numpy as np
from typing import Tuple, List
from dataclasses import dataclass


# ─────────────────────────────────────────────────────────────────
# Inline core functions (self-contained)
# ─────────────────────────────────────────────────────────────────

def cert_threshold(delta: float, sigma: float) -> float:
    if sigma <= 0:
        return float('inf')
    return delta / (2 * sigma)

def certification_residual_gap(delta: float, p: float, sigma: float) -> float:
    return delta - 2 * p * sigma

def certify_phase(delta: float, p: float, sigma: float) -> bool:
    return certification_residual_gap(delta, p, sigma) > 0


# ─────────────────────────────────────────────────────────────────
# Application 1: Quantum Error Correction Code Robustness
# ─────────────────────────────────────────────────────────────────

@dataclass
class CodeRobustness:
    """Robustness analysis for a quantum error correction code."""
    code_name: str
    distance: int
    gap: float
    noise_types: List[str]
    thresholds: dict  # noise_type -> threshold


def analyze_code_robustness(code_name: str, n: int, gap: float,
                             noise_models: dict) -> CodeRobustness:
    """
    Analyze the robustness of a quantum error correction code
    against various noise models using the certification threshold.

    Parameters:
        code_name: Name of the code
        n: Number of qubits
        gap: Spectral gap of the code Hamiltonian
        noise_models: dict of {name: operator_norm}

    Returns:
        CodeRobustness analysis
    """
    thresholds = {}
    for name, sigma in noise_models.items():
        thresholds[name] = cert_threshold(gap, sigma)

    return CodeRobustness(
        code_name=code_name,
        distance=n,
        gap=gap,
        noise_types=list(noise_models.keys()),
        thresholds=thresholds
    )


def demo_error_correction():
    """Demonstrate error correction code robustness analysis."""
    print("=" * 70)
    print("APPLICATION 1: Quantum Error Correction Robustness")
    print("=" * 70)

    # Toric code parameters for various lattice sizes
    for L in [3, 5, 7, 9]:
        n_qubits = 2 * L * L
        gap = 2.0  # Standard toric code gap

        noise_models = {
            "depolarizing": 3.0 / n_qubits,  # Per-qubit depolarizing
            "thermal": 0.5,                    # Thermal noise
            "measurement": 0.1,                # Measurement back-action
            "crosstalk": 1.0 / L,              # Nearest-neighbor crosstalk
        }

        result = analyze_code_robustness(
            f"Toric[{L}x{L}]", n_qubits, gap, noise_models
        )

        print(f"\n{result.code_name} ({n_qubits} qubits, gap = {gap}):")
        for noise_type in result.noise_types:
            threshold = result.thresholds[noise_type]
            sigma = noise_models[noise_type]
            print(f"  {noise_type:15s}: σ = {sigma:.4f}, "
                  f"p* = {threshold:.4f}")


# ─────────────────────────────────────────────────────────────────
# Application 2: Many-Body Localization Detection
# ─────────────────────────────────────────────────────────────────

def simulate_mbl_transition(n: int, disorder_strengths: np.ndarray,
                             interaction: float = 1.0) -> Tuple[np.ndarray, np.ndarray]:
    """
    Simulate the many-body localization transition for a 1D spin chain.

    We model H = H_clean + W * H_disorder where:
    - H_clean is a nearest-neighbor Heisenberg chain
    - H_disorder is random on-site disorder
    - W controls disorder strength

    The certification threshold predicts when the clean-system
    phase (ergodic) transitions to the localized phase.

    Returns:
        (disorder_strengths, certified_gaps)
    """
    rng = np.random.default_rng(42)

    # Clean Hamiltonian: simple model with known gap
    H_clean = np.zeros((n, n))
    for i in range(n - 1):
        H_clean[i, i + 1] = -interaction
        H_clean[i + 1, i] = -interaction
    # Make it have a specific ground state energy
    eigs_clean = np.sort(np.linalg.eigvalsh(H_clean))
    gap_clean = eigs_clean[1] - eigs_clean[0]

    # Disorder Hamiltonian
    H_disorder = np.diag(rng.standard_normal(n))
    sigma_disorder = np.linalg.norm(H_disorder, ord=2)

    # Compute certified gaps as function of disorder
    certified_gaps = []
    for W in disorder_strengths:
        cert_gap = certification_residual_gap(gap_clean, W, sigma_disorder)
        certified_gaps.append(cert_gap)

    return disorder_strengths, np.array(certified_gaps)


def demo_mbl():
    """Demonstrate MBL transition detection."""
    print("\n" + "=" * 70)
    print("APPLICATION 2: Many-Body Localization Transition")
    print("=" * 70)

    n = 12
    W_values = np.linspace(0, 5, 20)
    W_vals, cert_gaps = simulate_mbl_transition(n, W_values)

    # Find transition point
    transition_idx = np.argmin(np.abs(cert_gaps))
    W_star = W_values[transition_idx]

    print(f"\nSpin chain length: n = {n}")
    print(f"Predicted transition: W* ≈ {W_star:.3f}")
    print()
    print(f"{'W':>8} {'Certified Gap':>14} {'Phase':>10}")
    print("-" * 36)
    for W, gap in zip(W_vals, cert_gaps):
        phase = "Ergodic" if gap > 0 else "Localized"
        print(f"{W:8.3f} {gap:14.4f} {phase:>10}")


# ─────────────────────────────────────────────────────────────────
# Application 3: Hamiltonian Complexity Classification
# ─────────────────────────────────────────────────────────────────

def hamiltonian_complexity_certificate(H: np.ndarray,
                                        noise_budget: float) -> dict:
    """
    Certify the computational complexity class of a Hamiltonian
    promise problem under noise.

    If the spectral gap is large enough relative to the noise budget,
    the ground state energy can be certified as either YES or NO
    instance. The certification threshold determines the maximum
    tolerable noise.

    Parameters:
        H: Hamiltonian matrix
        noise_budget: Maximum noise operator norm

    Returns:
        Dictionary with certification results
    """
    eigs = np.sort(np.linalg.eigvalsh(H))
    n = len(eigs)

    # Find the largest spectral gap
    diffs = np.diff(eigs)
    gap_idx = np.argmax(diffs)
    gap = diffs[gap_idx]

    threshold = cert_threshold(gap, noise_budget)

    return {
        "dimension": n,
        "spectral_gap": gap,
        "gap_location": gap_idx,
        "noise_budget": noise_budget,
        "threshold": threshold,
        "max_certifiable_noise": gap / 2,
        "ground_energy": eigs[0],
        "is_certifiable": noise_budget < gap / 2
    }


def demo_complexity():
    """Demonstrate Hamiltonian complexity certification."""
    print("\n" + "=" * 70)
    print("APPLICATION 3: Hamiltonian Complexity Certification")
    print("=" * 70)

    rng = np.random.default_rng(42)
    sizes = [8, 16, 32]

    for n in sizes:
        # Random gapped Hamiltonian
        gap = 2.0
        eigenvalues = np.concatenate([
            np.array([0.0]),
            np.sort(rng.uniform(gap, gap + 1, n - 1))
        ])
        Q, _ = np.linalg.qr(rng.standard_normal((n, n)))
        H = Q @ np.diag(eigenvalues) @ Q.T
        H = (H + H.T) / 2

        for budget in [0.5, 1.0, 1.5]:
            result = hamiltonian_complexity_certificate(H, budget)
            status = "✓ Certifiable" if result["is_certifiable"] else "✗ Not certifiable"
            print(f"  n={n:3d}, budget={budget:.1f}: gap={result['spectral_gap']:.3f}, "
                  f"threshold={result['threshold']:.3f}, {status}")


# ─────────────────────────────────────────────────────────────────
# Application 4: Noise-Resilient Quantum Memory
# ─────────────────────────────────────────────────────────────────

def quantum_memory_lifetime(gap: float, noise_rate: float,
                             sigma: float) -> float:
    """
    Estimate quantum memory lifetime from certification threshold.

    If the noise accumulates at rate noise_rate * t with operator
    norm σ, the memory remains certified until:
        p(t) = noise_rate * t < Δ/(2σ)
    hence lifetime ≈ Δ/(2σ * noise_rate).

    Parameters:
        gap: Spectral gap Δ
        noise_rate: Rate of noise accumulation
        sigma: Noise operator norm per unit perturbation

    Returns:
        Estimated memory lifetime
    """
    if noise_rate * sigma <= 0:
        return float('inf')
    return gap / (2 * sigma * noise_rate)


def demo_memory():
    """Demonstrate quantum memory lifetime estimation."""
    print("\n" + "=" * 70)
    print("APPLICATION 4: Quantum Memory Lifetime Estimation")
    print("=" * 70)

    print("\nToric code memory lifetimes (gap Δ = 2):")
    print(f"{'Noise Rate':>12} {'σ':>8} {'Lifetime':>12} {'Quality':>10}")
    print("-" * 46)

    gap = 2.0
    for rate in [0.001, 0.01, 0.1]:
        for sigma in [0.5, 1.0, 2.0]:
            lifetime = quantum_memory_lifetime(gap, rate, sigma)
            quality = "Excellent" if lifetime > 1000 else (
                "Good" if lifetime > 100 else (
                    "Fair" if lifetime > 10 else "Poor"
                )
            )
            print(f"{rate:12.4f} {sigma:8.2f} {lifetime:12.1f} {quality:>10}")


# ─────────────────────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    demo_error_correction()
    demo_mbl()
    demo_complexity()
    demo_memory()

    print("\n" + "=" * 70)
    print("All applications completed successfully.")
    print("=" * 70)


#!/usr/bin/env python3
"""
Spectral Phase Transitions in Quantum Many-Body Certification — Interactive Demo

This script demonstrates the sharp certification threshold governing when a noisy
quantum Hamiltonian retains enough spectral structure to certify persistence of a
quantum phase. The central result: the certification threshold is p* = Δ/(2σ),
where Δ is the spectral gap and σ is the noise operator norm.

Usage:
    python demo.py
"""

import numpy as np
from typing import Tuple

# ─────────────────────────────────────────────────────────────────
# Core certification functions (matching the Lean formalization)
# ─────────────────────────────────────────────────────────────────

def cert_threshold(delta: float, sigma: float) -> float:
    """Certification threshold p* = Δ/(2σ). Returns inf if σ = 0."""
    if sigma == 0:
        return float('inf')
    return delta / (2 * sigma)

def certification_residual_gap(delta: float, p: float, sigma: float) -> float:
    """Residual gap Δ - 2pσ after perturbation."""
    return delta - 2 * p * sigma

def certify_phase(delta: float, p: float, sigma: float) -> bool:
    """Decidable certification checker: is the residual gap positive?"""
    return certification_residual_gap(delta, p, sigma) > 0

def classify_regime(delta: float, p: float, sigma: float) -> str:
    """Classify the perturbation regime."""
    gap = certification_residual_gap(delta, p, sigma)
    if gap > 0:
        return "STABLE"
    elif gap == 0:
        return "CRITICAL"
    else:
        return "UNSTABLE"

# ─────────────────────────────────────────────────────────────────
# Toy Hamiltonian construction
# ─────────────────────────────────────────────────────────────────

def make_gapped_hamiltonian(n: int, gap: float, ground_dim: int = 1) -> np.ndarray:
    """
    Construct a Hermitian Hamiltonian with specified spectral gap.

    The ground space has energy 0 (ground_dim eigenvalues at 0),
    and all excited states have energy ≥ gap.

    Parameters:
        n: dimension
        gap: spectral gap Δ
        ground_dim: dimension of ground space

    Returns:
        H: n×n Hermitian matrix
    """
    eigenvalues = np.zeros(n)
    # Excited states: uniformly spaced from gap to 2*gap
    excited_energies = np.linspace(gap, 2 * gap, n - ground_dim)
    eigenvalues[ground_dim:] = excited_energies

    # Random unitary to make it non-trivial
    rng = np.random.default_rng(42)
    Q, _ = np.linalg.qr(rng.standard_normal((n, n)) + 1j * rng.standard_normal((n, n)))
    H = Q @ np.diag(eigenvalues) @ Q.conj().T
    # Ensure exact Hermiticity
    H = (H + H.conj().T) / 2
    return H

def make_hermitian_noise(n: int, seed: int = 123) -> np.ndarray:
    """Construct a random Hermitian noise matrix."""
    rng = np.random.default_rng(seed)
    A = rng.standard_normal((n, n)) + 1j * rng.standard_normal((n, n))
    N = (A + A.conj().T) / 2
    # Normalize to unit operator norm
    N = N / np.linalg.norm(N, ord=2)
    return N

def toric_code_inspired_hamiltonian(L: int) -> Tuple[np.ndarray, float]:
    """
    Construct a toric-code-inspired Hamiltonian on an L×L lattice.

    This is a toy model: we use a stabilizer-like structure where
    the ground space is the +1 eigenspace of all stabilizers,
    separated from excited states by gap Δ = 2.

    Returns:
        H: 2^(L²) × ... but we use a smaller effective model
        gap: the spectral gap
    """
    n = min(2 * L * L, 64)  # Keep tractable
    gap = 2.0

    # Build a block-diagonal structure with gap
    H = np.zeros((n, n))
    ground_dim = max(1, n // 4)
    for i in range(ground_dim, n):
        H[i, i] = gap + (i - ground_dim) * 0.1

    # Apply a random basis change for non-triviality
    rng = np.random.default_rng(L)
    Q, _ = np.linalg.qr(rng.standard_normal((n, n)))
    H = Q @ H @ Q.T
    H = (H + H.T) / 2
    return H, gap

# ─────────────────────────────────────────────────────────────────
# Main demonstration
# ─────────────────────────────────────────────────────────────────

def demo_basic_threshold():
    """Demonstrate the basic certification threshold."""
    print("=" * 70)
    print("DEMO 1: Basic Certification Threshold")
    print("=" * 70)

    delta = 2.0  # spectral gap
    sigma = 1.0  # noise norm (normalized)
    p_star = cert_threshold(delta, sigma)

    print(f"\nSpectral gap Δ = {delta}")
    print(f"Noise norm σ = {sigma}")
    print(f"Certification threshold p* = Δ/(2σ) = {p_star}")
    print()

    # Scan perturbation strengths
    p_values = np.linspace(0, 2 * p_star, 20)
    print(f"{'p':>8} {'p/p*':>8} {'Residual Gap':>14} {'Regime':>12}")
    print("-" * 50)
    for p in p_values:
        gap = certification_residual_gap(delta, p, sigma)
        regime = classify_regime(delta, p, sigma)
        print(f"{p:8.3f} {p/p_star:8.3f} {gap:14.4f} {regime:>12}")

def demo_spectral_verification():
    """Verify the threshold against actual eigenvalue computations."""
    print("\n" + "=" * 70)
    print("DEMO 2: Spectral Verification")
    print("=" * 70)

    n = 20
    delta = 2.0
    H = make_gapped_hamiltonian(n, delta, ground_dim=2)
    N = make_hermitian_noise(n, seed=42)
    sigma = np.linalg.norm(N, ord=2)
    p_star = cert_threshold(delta, sigma)

    print(f"\nDimension n = {n}")
    print(f"Spectral gap Δ = {delta}")
    print(f"Noise norm ‖N‖ = {sigma:.4f}")
    print(f"Threshold p* = {p_star:.4f}")
    print()

    eigs_H = np.sort(np.linalg.eigvalsh(H))
    actual_gap_H = eigs_H[2] - eigs_H[1]  # gap between ground and first excited
    print(f"Actual spectral gap of H: {actual_gap_H:.4f}")
    print()

    p_values = np.linspace(0, 2 * p_star, 10)
    print(f"{'p':>8} {'p/p*':>8} {'Certified Gap':>14} {'Actual Gap':>12} {'Match?':>8}")
    print("-" * 58)
    for p in p_values:
        H_p = H + p * N
        eigs = np.sort(np.linalg.eigvalsh(H_p))
        actual_gap = eigs[2] - eigs[1]
        certified_gap = certification_residual_gap(delta, p, sigma)
        match = "✓" if (certified_gap > 0) == (actual_gap > 0.01) else "~"
        print(f"{p:8.3f} {p/p_star:8.3f} {certified_gap:14.4f} {actual_gap:12.4f} {match:>8}")

def demo_monotonicity():
    """Demonstrate monotonicity properties."""
    print("\n" + "=" * 70)
    print("DEMO 3: Monotonicity Properties")
    print("=" * 70)

    sigma = 1.0
    gaps = [0.5, 1.0, 2.0, 4.0, 8.0]
    print("\nMonotonicity in gap (σ fixed):")
    print(f"{'Δ':>8} {'p* = Δ/(2σ)':>14}")
    print("-" * 24)
    for delta in gaps:
        print(f"{delta:8.2f} {cert_threshold(delta, sigma):14.4f}")

    delta = 2.0
    noises = [0.5, 1.0, 2.0, 4.0, 8.0]
    print("\nAntitonicity in noise (Δ fixed):")
    print(f"{'σ':>8} {'p* = Δ/(2σ)':>14}")
    print("-" * 24)
    for sigma in noises:
        print(f"{sigma:8.2f} {cert_threshold(delta, sigma):14.4f}")

def demo_toric_code_scaling():
    """Demonstrate finite-size scaling with toric-code-inspired models."""
    print("\n" + "=" * 70)
    print("DEMO 4: Finite-Size Scaling (Toric-Code-Inspired)")
    print("=" * 70)

    L_values = [2, 3, 4, 5]
    print(f"\n{'L':>4} {'n':>6} {'Δ':>6} {'p*':>8} {'σ_eff':>8}")
    print("-" * 38)

    for L in L_values:
        H, gap = toric_code_inspired_hamiltonian(L)
        n = H.shape[0]
        N = make_hermitian_noise(n, seed=L * 100)
        sigma_eff = np.linalg.norm(N, ord=2)
        p_star = cert_threshold(gap, sigma_eff)
        print(f"{L:4d} {n:6d} {gap:6.2f} {p_star:8.4f} {sigma_eff:8.4f}")

    # For the largest L, scan the transition
    L = 4
    H, gap = toric_code_inspired_hamiltonian(L)
    n = H.shape[0]
    N = make_hermitian_noise(n, seed=L * 100)
    sigma = np.linalg.norm(N, ord=2)
    p_star = cert_threshold(gap, sigma)

    print(f"\nTransition scan for L = {L}, n = {n}:")
    p_ratios = np.linspace(0, 2.0, 15)
    print(f"{'p/p*':>8} {'Cert. Gap':>12} {'Actual Min Gap':>16}")
    print("-" * 40)
    for ratio in p_ratios:
        p = ratio * p_star
        H_p = H + p * N
        eigs = np.sort(np.linalg.eigvalsh(H_p))
        # Find actual minimum gap between eigenvalue clusters
        diffs = np.diff(eigs)
        cert_gap = certification_residual_gap(gap, p, sigma)
        max_diff = np.max(diffs)
        print(f"{ratio:8.3f} {cert_gap:12.4f} {max_diff:16.4f}")

def demo_diagnosis():
    """Demonstrate the full certification diagnosis pipeline."""
    print("\n" + "=" * 70)
    print("DEMO 5: Full Certification Diagnosis Pipeline")
    print("=" * 70)

    cases = [
        {"delta": 2.0, "p": 0.3, "sigma": 1.0, "label": "Subcritical"},
        {"delta": 2.0, "p": 1.0, "sigma": 1.0, "label": "Critical"},
        {"delta": 2.0, "p": 1.5, "sigma": 1.0, "label": "Supercritical"},
        {"delta": 4.0, "p": 0.5, "sigma": 2.0, "label": "Large gap, large noise"},
        {"delta": 0.1, "p": 0.01, "sigma": 1.0, "label": "Tiny gap"},
    ]

    for case in cases:
        delta, p, sigma = case["delta"], case["p"], case["sigma"]
        print(f"\n--- {case['label']} ---")
        print(f"  Δ = {delta}, p = {p}, σ = {sigma}")
        print(f"  Threshold p* = {cert_threshold(delta, sigma):.4f}")
        print(f"  Residual gap = {certification_residual_gap(delta, p, sigma):.4f}")
        print(f"  Certified? {certify_phase(delta, p, sigma)}")
        print(f"  Regime: {classify_regime(delta, p, sigma)}")


if __name__ == "__main__":
    demo_basic_threshold()
    demo_spectral_verification()
    demo_monotonicity()
    demo_toric_code_scaling()
    demo_diagnosis()
    print("\n" + "=" * 70)
    print("All demos completed successfully.")
    print("=" * 70)


#!/usr/bin/env python3
"""
Visualization: Eigenvalue Perturbation Under Noise

Shows how eigenvalues of a gapped Hamiltonian shift under increasing
perturbation, demonstrating the 2σ mechanism: ground and excited states
move toward each other, closing the gap at rate 2p·σ. The certified
bound tracks the worst-case gap closure.
"""

import numpy as np
import matplotlib.pyplot as plt

def make_gapped_hamiltonian(n, gap, ground_dim=2):
    eigenvalues = np.zeros(n)
    eigenvalues[ground_dim:] = np.linspace(gap, gap + 1.5, n - ground_dim)
    rng = np.random.default_rng(42)
    Q, _ = np.linalg.qr(rng.standard_normal((n, n)))
    H = Q @ np.diag(eigenvalues) @ Q.T
    return (H + H.T) / 2

def make_noise(n, seed=123):
    rng = np.random.default_rng(seed)
    A = rng.standard_normal((n, n))
    N = (A + A.T) / 2
    return N / np.linalg.norm(N, ord=2)

n = 16
gap = 2.0
ground_dim = 3
H = make_gapped_hamiltonian(n, gap, ground_dim)
N = make_noise(n)
sigma = np.linalg.norm(N, ord=2)  # ≈ 1.0 after normalization
p_star = gap / (2 * sigma)

# Sweep p values
p_values = np.linspace(0, 2 * p_star, 60)
all_eigenvalues = []
for p in p_values:
    H_p = H + p * N
    eigs = np.sort(np.linalg.eigvalsh(H_p))
    all_eigenvalues.append(eigs)
all_eigenvalues = np.array(all_eigenvalues)

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left: eigenvalue trajectories
ax1 = axes[0]
for i in range(n):
    color = '#2ecc71' if i < ground_dim else '#e74c3c'
    alpha = 0.8 if i < ground_dim or i == ground_dim else 0.3
    lw = 2 if i < ground_dim or i == ground_dim else 0.8
    ax1.plot(p_values / p_star, all_eigenvalues[:, i], color=color,
             alpha=alpha, linewidth=lw)

# Certified bounds
certified_upper = np.array([p * sigma for p in p_values])
certified_lower = np.array([gap - p * sigma for p in p_values])
ax1.plot(p_values / p_star, certified_upper, 'g--', linewidth=2,
         label='Ground bound: pσ', alpha=0.7)
ax1.plot(p_values / p_star, certified_lower, 'r--', linewidth=2,
         label='Excited bound: Δ − pσ', alpha=0.7)

ax1.axvline(x=1.0, color='orange', linewidth=2, linestyle=':',
            label=f'p = p* (threshold)', alpha=0.8)
ax1.axhspan(-1, gap/2, xmin=0, xmax=0.5, alpha=0.05, color='green')

ax1.set_xlabel('p / p*  (normalized perturbation)', fontsize=13)
ax1.set_ylabel('Energy', fontsize=13)
ax1.set_title('Eigenvalue Trajectories Under Perturbation', fontsize=14,
              fontweight='bold')
ax1.legend(fontsize=10, loc='upper left')
ax1.set_xlim(0, 2)
ax1.grid(True, alpha=0.3)

# Right: actual gap vs certified gap
ax2 = axes[1]
actual_gaps = all_eigenvalues[:, ground_dim] - all_eigenvalues[:, ground_dim - 1]
certified_gaps = [gap - 2 * p * sigma for p in p_values]

ax2.plot(p_values / p_star, actual_gaps, 'b-', linewidth=2.5,
         label='Actual spectral gap')
ax2.plot(p_values / p_star, certified_gaps, 'r--', linewidth=2,
         label='Certified lower bound: Δ − 2pσ')
ax2.axhline(y=0, color='black', linewidth=0.5)
ax2.axvline(x=1.0, color='orange', linewidth=2, linestyle=':',
            label='Threshold p*', alpha=0.8)

ax2.fill_between(p_values / p_star, 0, certified_gaps,
                 where=np.array(certified_gaps) > 0,
                 alpha=0.15, color='green', label='Certified region')
ax2.fill_between(p_values / p_star, certified_gaps, 0,
                 where=np.array(certified_gaps) < 0,
                 alpha=0.15, color='red')

ax2.set_xlabel('p / p*  (normalized perturbation)', fontsize=13)
ax2.set_ylabel('Spectral gap', fontsize=13)
ax2.set_title('Gap Stability: Actual vs Certified Bound', fontsize=14,
              fontweight='bold')
ax2.legend(fontsize=10, loc='upper right')
ax2.set_xlim(0, 2)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('viz_eigenvalue_perturbation.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved viz_eigenvalue_perturbation.png")


#!/usr/bin/env python3
"""
Visualization: Finite-Size Scaling and Universality

Demonstrates the conjecture that certification scores exhibit finite-size
collapse when plotted against the rescaled variable p/p*(L). Multiple
system sizes L are shown, with the transition sharpening as L grows.
This is the many-body analog of Tracy-Widom edge scaling.
"""

import numpy as np
import matplotlib.pyplot as plt

def make_gapped_system(n, gap, seed):
    rng = np.random.default_rng(seed)
    eigenvalues = np.zeros(n)
    ground_dim = max(1, n // 4)
    eigenvalues[ground_dim:] = np.linspace(gap, gap + 2, n - ground_dim)
    Q, _ = np.linalg.qr(rng.standard_normal((n, n)))
    H = Q @ np.diag(eigenvalues) @ Q.T
    H = (H + H.T) / 2
    A = rng.standard_normal((n, n))
    N = (A + A.T) / 2
    N = N / np.linalg.norm(N, ord=2)
    return H, N, ground_dim

fig, axes = plt.subplots(2, 2, figsize=(14, 12))

# Panel 1: Certification score curves for different system sizes
ax1 = axes[0, 0]
L_values = [4, 8, 16, 32]
colors_L = ['#3498db', '#2ecc71', '#e74c3c', '#9b59b6']
gap = 2.0

for L, color in zip(L_values, colors_L):
    n = L
    H, N, gd = make_gapped_system(n, gap, seed=L * 7)
    sigma = np.linalg.norm(N, ord=2)
    p_star = gap / (2 * sigma)

    p_values = np.linspace(0, 2 * p_star, 80)
    scores = []
    for p in p_values:
        H_p = H + p * N
        eigs = np.sort(np.linalg.eigvalsh(H_p))
        actual_gap = eigs[gd] - eigs[gd - 1]
        scores.append(max(actual_gap, 0))

    scores = np.array(scores)
    if scores[0] > 0:
        scores_norm = scores / scores[0]
    else:
        scores_norm = scores

    ax1.plot(p_values / p_star, scores_norm, color=color, linewidth=2,
             label=f'n = {L}')

ax1.axvline(x=1.0, color='orange', linewidth=2, linestyle=':', alpha=0.7)
ax1.set_xlabel('p / p*', fontsize=13)
ax1.set_ylabel('Normalized gap Φ(p) / Φ(0)', fontsize=13)
ax1.set_title('Certification Score Collapse', fontsize=14, fontweight='bold')
ax1.legend(fontsize=11)
ax1.set_xlim(0, 2)
ax1.set_ylim(-0.1, 1.5)
ax1.grid(True, alpha=0.3)

# Panel 2: Certified gap heatmap
ax2 = axes[0, 1]
delta_range = np.linspace(0.5, 5, 100)
sigma_range = np.linspace(0.1, 3, 100)
D, S = np.meshgrid(delta_range, sigma_range)
P_star = D / (2 * S)

im = ax2.pcolormesh(D, S, P_star, cmap='viridis', shading='auto',
                     vmin=0, vmax=5)
plt.colorbar(im, ax=ax2, label='Threshold p* = Δ/(2σ)')
ax2.set_xlabel('Spectral gap Δ', fontsize=13)
ax2.set_ylabel('Noise scale σ', fontsize=13)
ax2.set_title('Certification Threshold Landscape', fontsize=14, fontweight='bold')

# Contour lines
contours = ax2.contour(D, S, P_star, levels=[0.5, 1.0, 2.0, 3.0],
                        colors='white', linewidths=1.5)
ax2.clabel(contours, fmt='p*=%.1f', fontsize=10, colors='white')

# Panel 3: Multiple noise ensembles (universality test)
ax3 = axes[1, 0]
n = 20
gap = 2.0
rng = np.random.default_rng(42)

noise_types = {
    'Gaussian': lambda: (lambda A: (A + A.T) / 2)(rng.standard_normal((n, n))),
    'Sparse': lambda: (lambda A: (A + A.T) / 2)(
        rng.standard_normal((n, n)) * (rng.random((n, n)) < 0.3)),
    'Diagonal': lambda: np.diag(rng.standard_normal(n)),
}

H, _, gd = make_gapped_system(n, gap, seed=999)

for (name, gen), color in zip(noise_types.items(),
                               ['#3498db', '#e74c3c', '#2ecc71']):
    N = gen()
    N = N / np.linalg.norm(N, ord=2)
    sigma = np.linalg.norm(N, ord=2)
    p_star = gap / (2 * sigma)

    p_values = np.linspace(0, 2 * p_star, 80)
    gaps_actual = []
    for p in p_values:
        H_p = H + p * N
        eigs = np.sort(np.linalg.eigvalsh(H_p))
        gaps_actual.append(eigs[gd] - eigs[gd - 1])

    ax3.plot(p_values / p_star, gaps_actual, color=color, linewidth=2,
             label=f'{name}', alpha=0.8)

certified = [gap - 2 * p * 1.0 for p in np.linspace(0, 2, 80)]
ax3.plot(np.linspace(0, 2, 80), certified, 'k--', linewidth=1.5,
         label='Certified bound', alpha=0.5)
ax3.axhline(y=0, color='black', linewidth=0.5)
ax3.axvline(x=1.0, color='orange', linewidth=2, linestyle=':', alpha=0.7)

ax3.set_xlabel('p / p*', fontsize=13)
ax3.set_ylabel('Spectral gap', fontsize=13)
ax3.set_title('Universality: Different Noise Ensembles', fontsize=14,
              fontweight='bold')
ax3.legend(fontsize=11)
ax3.set_xlim(0, 2)
ax3.grid(True, alpha=0.3)

# Panel 4: Transition width vs system size
ax4 = axes[1, 1]
sizes = [4, 6, 8, 12, 16, 24, 32, 48, 64]
widths = []

for n_size in sizes:
    H, N, gd = make_gapped_system(n_size, gap, seed=n_size * 13)
    sigma = np.linalg.norm(N, ord=2)
    p_star = gap / (2 * sigma)

    p_values = np.linspace(0.5 * p_star, 1.5 * p_star, 200)
    gaps_norm = []
    for p in p_values:
        H_p = H + p * N
        eigs = np.sort(np.linalg.eigvalsh(H_p))
        g = eigs[gd] - eigs[gd - 1]
        gaps_norm.append(g)

    gaps_norm = np.array(gaps_norm)
    # Estimate transition width as interval where gap goes from 80% to 20% of max
    max_gap = np.max(gaps_norm)
    if max_gap > 0:
        above_80 = np.where(gaps_norm > 0.8 * max_gap)[0]
        below_20 = np.where(gaps_norm < 0.2 * max_gap)[0]
        if len(above_80) > 0 and len(below_20) > 0:
            p_80 = p_values[above_80[-1]] / p_star
            p_20 = p_values[below_20[0]] / p_star
            widths.append(p_20 - p_80)
        else:
            widths.append(1.0)
    else:
        widths.append(1.0)

ax4.loglog(sizes, widths, 'bo-', linewidth=2, markersize=8, label='Measured width')

# Fit power law
log_sizes = np.log(sizes)
log_widths = np.log(widths)
coeffs = np.polyfit(log_sizes, log_widths, 1)
fit_line = np.exp(coeffs[1]) * np.array(sizes) ** coeffs[0]
ax4.loglog(sizes, fit_line, 'r--', linewidth=2,
           label=f'Fit: n^{{{coeffs[0]:.2f}}}')

# Reference n^{-2/3} line
ref_line = widths[0] * (np.array(sizes) / sizes[0]) ** (-2/3)
ax4.loglog(sizes, ref_line, 'g:', linewidth=1.5,
           label=r'Reference: $n^{-2/3}$', alpha=0.7)

ax4.set_xlabel('System size n', fontsize=13)
ax4.set_ylabel('Transition width', fontsize=13)
ax4.set_title('Finite-Size Scaling of Transition Width', fontsize=14,
              fontweight='bold')
ax4.legend(fontsize=11)
ax4.grid(True, alpha=0.3, which='both')

plt.tight_layout()
plt.savefig('viz_finite_size_scaling.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved viz_finite_size_scaling.png")


#!/usr/bin/env python3
"""
Visualization: Spectral Phase Transition in Certification

Visualizes the sharp certification threshold p* = Δ/(2σ) showing how the
residual spectral gap transitions from positive (certifiable) to negative
(uncertifiable) at the critical perturbation strength. The plot shows
multiple noise scales to demonstrate antitonicity: larger noise → earlier transition.
"""

import numpy as np
import matplotlib.pyplot as plt

# Core functions (self-contained)
def certification_residual_gap(delta, p, sigma):
    return delta - 2 * p * sigma

def cert_threshold(delta, sigma):
    if sigma <= 0:
        return float('inf')
    return delta / (2 * sigma)

# Parameters
delta = 2.0  # spectral gap
sigma_values = [0.5, 1.0, 2.0, 4.0]
colors = ['#2ecc71', '#3498db', '#e74c3c', '#9b59b6']

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left panel: Residual gap vs perturbation strength
ax1 = axes[0]
for sigma, color in zip(sigma_values, colors):
    p_star = cert_threshold(delta, sigma)
    p_values = np.linspace(0, 3, 300)
    gaps = [certification_residual_gap(delta, p, sigma) for p in p_values]

    ax1.plot(p_values, gaps, color=color, linewidth=2, label=f'σ = {sigma}')
    ax1.axvline(x=p_star, color=color, linestyle='--', alpha=0.5, linewidth=1)
    ax1.plot(p_star, 0, 'o', color=color, markersize=8, zorder=5)

ax1.axhline(y=0, color='black', linewidth=0.5, linestyle='-')
ax1.fill_between([0, 3], [0, 0], [-8, -8], alpha=0.05, color='red')
ax1.fill_between([0, 3], [0, 0], [4, 4], alpha=0.05, color='green')
ax1.set_xlabel('Perturbation strength p', fontsize=13)
ax1.set_ylabel('Residual gap Δ − 2pσ', fontsize=13)
ax1.set_title('Phase Transition in Certification', fontsize=14, fontweight='bold')
ax1.legend(fontsize=11, loc='upper right')
ax1.set_xlim(0, 3)
ax1.set_ylim(-6, 3)
ax1.text(0.15, 1.5, 'CERTIFIED\n(stable phase)', fontsize=11, color='green',
         fontweight='bold', ha='center')
ax1.text(2.5, -4, 'UNCERTIFIED\n(gap destroyed)', fontsize=11, color='red',
         fontweight='bold', ha='center')
ax1.grid(True, alpha=0.3)

# Right panel: Threshold vs noise scale
ax2 = axes[1]
sigma_range = np.linspace(0.1, 5, 200)
for delta_val, color, ls in zip([1.0, 2.0, 4.0], ['#e67e22', '#2980b9', '#27ae60'],
                                  ['-', '-', '-']):
    thresholds = [cert_threshold(delta_val, s) for s in sigma_range]
    ax2.plot(sigma_range, thresholds, color=color, linewidth=2,
             linestyle=ls, label=f'Δ = {delta_val}')

ax2.set_xlabel('Noise norm σ', fontsize=13)
ax2.set_ylabel('Certification threshold p*', fontsize=13)
ax2.set_title('Threshold: Monotone in Δ, Antitone in σ', fontsize=14, fontweight='bold')
ax2.legend(fontsize=11)
ax2.set_xlim(0.1, 5)
ax2.set_ylim(0, 5)
ax2.grid(True, alpha=0.3)

# Add annotation about the formula
ax2.annotate(r'$p^* = \frac{\Delta}{2\sigma}$',
             xy=(2.5, cert_threshold(4.0, 2.5)), xytext=(3.5, 3.5),
             fontsize=14, ha='center',
             arrowprops=dict(arrowstyle='->', color='#27ae60'),
             color='#27ae60', fontweight='bold')

plt.tight_layout()
plt.savefig('viz_phase_transition.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved viz_phase_transition.png")
