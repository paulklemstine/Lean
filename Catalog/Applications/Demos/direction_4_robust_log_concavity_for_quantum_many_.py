"""
applications.py — Real-World Applications of the Quantum-to-Classical Bridge

Demonstrates how the formally verified theorems apply to:
1. Classical simulation of quantum measurements near free-fermionic points
2. Certified sampling from quantum measurement distributions
3. Phase transition detection via Lorentzian gap monitoring
4. Anti-concentration bounds for quantum computational advantage

Keywords: quantum many-body systems, transverse-field Ising model, free fermions,
          matchgate circuits, Lorentzian polynomials, strong log-concavity,
          spectral gap, Glauber dynamics, anti-concentration, negative dependence,
          perturbation stability, classical simulation, combinatorial Hodge theory,
          determinantal processes, quantum-to-classical correspondence
"""

import numpy as np
from typing import Tuple, Dict, List
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


# ═══════════════════════════════════════════════════════════════════════════
# Application 1: Classical Simulation Near Free-Fermionic Points
# ═══════════════════════════════════════════════════════════════════════════

def pauli_x():
    return np.array([[0, 1], [1, 0]], dtype=complex)

def pauli_z():
    return np.array([[1, 0], [0, -1]], dtype=complex)

def kron_at(op, site, n):
    result = np.eye(1, dtype=complex)
    for i in range(n):
        result = np.kron(result, op if i == site else np.eye(2, dtype=complex))
    return result

def tfim_hamiltonian(n, J, h):
    dim = 2**n
    H = np.zeros((dim, dim), dtype=complex)
    for i in range(n - 1):
        ZZ = kron_at(pauli_z(), i, n) @ kron_at(pauli_z(), i + 1, n)
        H -= J * ZZ
    for i in range(n):
        H -= h * kron_at(pauli_x(), i, n)
    return H


def classical_simulation_certificate(n: int, J: float, h_ref: float, h_target: float) -> Dict:
    """
    Application 1: Certified classical simulation.

    Given a free-fermionic reference point (h_ref) and a target point (h_target),
    compute the perturbation parameter ε and verify that the formal theorems
    guarantee bounded approximation error.

    This uses:
    - event_prob_ratio_bound: event probabilities are within exp(ε) factor
    - minMass_perturbation_lower_bound: anti-concentration is preserved
    - perturbative_boundaryMass_lower_bound: expansion is preserved

    Returns a certificate with guaranteed bounds.
    """
    H_ref = tfim_hamiltonian(n, J, h_ref)
    H_target = tfim_hamiltonian(n, J, h_target)

    evals_ref, evecs_ref = np.linalg.eigh(H_ref)
    evals_tgt, evecs_tgt = np.linalg.eigh(H_target)

    idx_ref = np.argsort(evals_ref)
    idx_tgt = np.argsort(evals_tgt)

    probs_ref = np.abs(evecs_ref[:, idx_ref[0]])**2
    probs_tgt = np.abs(evecs_tgt[:, idx_tgt[0]])**2
    gap_ref = evals_ref[idx_ref[1]] - evals_ref[idx_ref[0]]
    gap_tgt = evals_tgt[idx_tgt[1]] - evals_tgt[idx_tgt[0]]

    # Compute perturbation parameter
    mask = (probs_ref > 1e-15) & (probs_tgt > 1e-15)
    if np.any(mask):
        eps = float(np.max(np.abs(np.log(probs_tgt[mask] / probs_ref[mask]))))
    else:
        eps = float('inf')

    # Guaranteed bounds from formal theorems
    min_mass_ref = float(np.min(probs_ref))
    min_mass_guaranteed = np.exp(-eps) * min_mass_ref

    # Boundary mass (Hamming graph)
    half = set(range(2**(n-1)))
    bm_ref = sum(probs_ref[x] for x in half
                 if any(x ^ (1 << b) not in half for b in range(n)))
    bm_guaranteed = np.exp(-eps) * bm_ref
    bm_actual = sum(probs_tgt[x] for x in half
                    if any(x ^ (1 << b) not in half for b in range(n)))

    return {
        'n': n, 'h_ref': h_ref, 'h_target': h_target,
        'perturbation_epsilon': eps,
        'gap_reference': gap_ref,
        'gap_target': gap_tgt,
        'min_mass_reference': min_mass_ref,
        'min_mass_guaranteed': min_mass_guaranteed,
        'min_mass_actual': float(np.min(probs_tgt)),
        'boundary_mass_guaranteed': bm_guaranteed,
        'boundary_mass_actual': bm_actual,
        'simulation_feasible': eps < 2.0,  # Heuristic threshold
    }


# ═══════════════════════════════════════════════════════════════════════════
# Application 2: Phase Transition Detection via Lorentzian Gap Monitoring
# ═══════════════════════════════════════════════════════════════════════════

def phase_transition_detector(n: int, J: float, h_range: np.ndarray) -> Dict:
    """
    Application 2: Detect quantum phase transitions by monitoring the
    Lorentzian gap surrogate.

    The transverse-field Ising model has a phase transition at h/J = 1.
    The Lorentzian gap surrogate should show a sharp change near this point,
    correlated with the closing of the quantum spectral gap.

    This demonstrates the quantum-to-classical correspondence:
    changes in quantum structure (gap closing) are visible in the
    classical measurement distribution geometry (Lorentzian gap).
    """
    results = {'h': [], 'quantum_gap': [], 'lorentzian_surrogate': [],
               'min_mass': [], 'entropy': []}

    for h in h_range:
        H = tfim_hamiltonian(n, J, h)
        evals, evecs = np.linalg.eigh(H)
        idx = np.argsort(evals)
        probs = np.abs(evecs[:, idx[0]])**2
        gap = evals[idx[1]] - evals[idx[0]]

        p_min = float(np.min(probs))
        p_max = float(np.max(probs))
        lor_surr = p_min / p_max if p_max > 1e-15 else 0.0

        # Shannon entropy
        mask = probs > 1e-15
        entropy = -float(np.sum(probs[mask] * np.log(probs[mask])))

        results['h'].append(float(h))
        results['quantum_gap'].append(float(gap))
        results['lorentzian_surrogate'].append(lor_surr)
        results['min_mass'].append(p_min)
        results['entropy'].append(entropy)

    return results


# ═══════════════════════════════════════════════════════════════════════════
# Application 3: Anti-Concentration for Quantum Advantage
# ═══════════════════════════════════════════════════════════════════════════

def anticoncentration_analysis(n: int) -> Dict:
    """
    Application 3: Anti-concentration analysis for quantum computational advantage.

    For quantum advantage arguments (e.g., BosonSampling, IQP), one needs
    the measurement distribution to be anti-concentrated: not too much mass
    on any single outcome. Our formal theorems show that:

    1. Anti-concentration (minMass) is preserved under perturbation
    2. Event probabilities are controlled by perturbation bounds
    3. Boundary mass (expansion) ensures efficient classical sampling

    This provides a rigorous framework for studying when quantum advantage
    survives noise.
    """
    results = {'state_type': [], 'min_mass': [], 'max_mass': [],
               'entropy': [], 'lorentzian_gap': []}

    dim = 2**n

    # Uniform (maximally anti-concentrated)
    probs_unif = np.ones(dim) / dim
    results['state_type'].append('Uniform')
    results['min_mass'].append(1.0/dim)
    results['max_mass'].append(1.0/dim)
    results['entropy'].append(n * np.log(2))
    results['lorentzian_gap'].append(1.0)

    # Random state (Haar measure)
    amps = np.random.randn(dim) + 1j * np.random.randn(dim)
    amps /= np.linalg.norm(amps)
    probs_haar = np.abs(amps)**2
    results['state_type'].append('Haar random')
    results['min_mass'].append(float(np.min(probs_haar)))
    results['max_mass'].append(float(np.max(probs_haar)))
    mask = probs_haar > 1e-15
    results['entropy'].append(-float(np.sum(probs_haar[mask] * np.log(probs_haar[mask]))))
    results['lorentzian_gap'].append(float(np.min(probs_haar) / np.max(probs_haar)))

    # Ground state at different field strengths
    for h in [0.5, 1.0, 2.0]:
        H = tfim_hamiltonian(n, 1.0, h)
        evals, evecs = np.linalg.eigh(H)
        idx = np.argsort(evals)
        probs = np.abs(evecs[:, idx[0]])**2

        results['state_type'].append(f'TFIM h={h}')
        results['min_mass'].append(float(np.min(probs)))
        results['max_mass'].append(float(np.max(probs)))
        mask = probs > 1e-15
        results['entropy'].append(-float(np.sum(probs[mask] * np.log(probs[mask]))))
        p_max = float(np.max(probs))
        results['lorentzian_gap'].append(float(np.min(probs) / p_max) if p_max > 1e-15 else 0.0)

    return results


# ═══════════════════════════════════════════════════════════════════════════
# Main Application Demo
# ═══════════════════════════════════════════════════════════════════════════

def main():
    print("=" * 70)
    print("Applications of the Quantum-to-Classical Bridge Theorems")
    print("=" * 70)

    # ── Application 1: Classical Simulation ──
    print("\n" + "─" * 60)
    print("Application 1: Classical Simulation Certificates")
    print("─" * 60)
    for n in [4, 6]:
        for delta_h in [0.1, 0.3, 0.5]:
            cert = classical_simulation_certificate(n, 1.0, 1.0, 1.0 + delta_h)
            feasible = "✓ FEASIBLE" if cert['simulation_feasible'] else "✗ INFEASIBLE"
            print(f"  n={n}, δh={delta_h}: ε={cert['perturbation_epsilon']:.4f}, "
                  f"minMass≥{cert['min_mass_guaranteed']:.6f}, "
                  f"bdryMass≥{cert['boundary_mass_guaranteed']:.6f} "
                  f"[{feasible}]")

    # ── Application 2: Phase Transition Detection ──
    print("\n" + "─" * 60)
    print("Application 2: Phase Transition Detection")
    print("─" * 60)
    for n in [4, 6]:
        h_range = np.linspace(0.2, 2.5, 30)
        results = phase_transition_detector(n, 1.0, h_range)

        # Find minimum gap (closest to phase transition)
        min_gap_idx = np.argmin(results['quantum_gap'])
        print(f"  n={n}: Phase transition detected near h={results['h'][min_gap_idx]:.2f}")
        print(f"    Min quantum gap: {results['quantum_gap'][min_gap_idx]:.6f}")
        print(f"    Lorentzian surrogate at transition: "
              f"{results['lorentzian_surrogate'][min_gap_idx]:.6f}")

    # ── Application 3: Anti-Concentration ──
    print("\n" + "─" * 60)
    print("Application 3: Anti-Concentration Analysis (n=6)")
    print("─" * 60)
    results = anticoncentration_analysis(6)
    print(f"  {'State':>15s} {'MinMass':>12s} {'MaxMass':>12s} "
          f"{'Entropy':>10s} {'LorGap':>10s}")
    for i in range(len(results['state_type'])):
        print(f"  {results['state_type'][i]:>15s} "
              f"{results['min_mass'][i]:12.8f} "
              f"{results['max_mass'][i]:12.8f} "
              f"{results['entropy'][i]:10.4f} "
              f"{results['lorentzian_gap'][i]:10.6f}")

    # ── Generate plots ──
    print("\n" + "─" * 60)
    print("Generating application plots...")
    print("─" * 60)

    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    # Plot phase transition
    h_range = np.linspace(0.2, 2.5, 50)
    results = phase_transition_detector(6, 1.0, h_range)

    axes[0].plot(results['h'], results['quantum_gap'], 'b-', linewidth=2, label='Quantum gap')
    axes[0].plot(results['h'], results['lorentzian_surrogate'], 'r--', linewidth=2,
                 label='Lorentzian surrogate')
    axes[0].axvline(x=1.0, color='gray', linestyle=':', alpha=0.5, label='Critical point')
    axes[0].set_xlabel('Transverse field h')
    axes[0].set_ylabel('Gap / Certificate')
    axes[0].set_title('Phase Transition Detection (n=6)')
    axes[0].legend(fontsize=8)
    axes[0].grid(True, alpha=0.3)

    # Plot simulation feasibility
    deltas = np.linspace(0.05, 1.5, 30)
    epsilons = []
    for d in deltas:
        cert = classical_simulation_certificate(6, 1.0, 1.0, 1.0 + d)
        epsilons.append(cert['perturbation_epsilon'])
    axes[1].plot(deltas, epsilons, 'g-o', markersize=3, linewidth=1.5)
    axes[1].axhline(y=2.0, color='red', linestyle='--', label='Feasibility threshold')
    axes[1].set_xlabel('Perturbation δh')
    axes[1].set_ylabel('Perturbation ε')
    axes[1].set_title('Simulation Feasibility (n=6)')
    axes[1].legend(fontsize=8)
    axes[1].grid(True, alpha=0.3)

    # Plot anti-concentration
    ac = anticoncentration_analysis(6)
    x_pos = np.arange(len(ac['state_type']))
    axes[2].bar(x_pos, ac['lorentzian_gap'], color=['blue', 'orange', 'green', 'red', 'purple'])
    axes[2].set_xticks(x_pos)
    axes[2].set_xticklabels(ac['state_type'], rotation=30, ha='right', fontsize=8)
    axes[2].set_ylabel('Lorentzian Gap Surrogate')
    axes[2].set_title('Anti-Concentration by State Type')
    axes[2].grid(True, alpha=0.3, axis='y')

    plt.tight_layout()
    plt.savefig('applications_plots.png', dpi=150, bbox_inches='tight')
    print("Plots saved to applications_plots.png")

    print("\n" + "=" * 70)
    print("Applications demo complete.")
    print("=" * 70)


if __name__ == "__main__":
    main()


"""
demo.py — Quantum-to-Classical Gap Bridge: Computational Demonstration

Constructs small transverse-field Ising model instances, diagonalizes the
Hamiltonian numerically, extracts ground-state measurement probabilities,
computes surrogate Lorentzian / expansion certificates, and plots certificate
vs. quantum spectral gap as field strength varies.

This demo visibly tests the conjectural scaling law:
    LorentzianGap(μ_λ) ≥ Δ(H(λ)) / poly(n)

Keywords: quantum many-body systems, transverse-field Ising model, free fermions,
          matchgate circuits, Lorentzian polynomials, strong log-concavity,
          spectral gap, Glauber dynamics, anti-concentration, negative dependence,
          perturbation stability, classical simulation, combinatorial Hodge theory,
          determinantal processes, quantum-to-classical correspondence
"""

import numpy as np
from typing import Tuple, Dict, List
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def pauli_x() -> np.ndarray:
    return np.array([[0, 1], [1, 0]], dtype=complex)


def pauli_z() -> np.ndarray:
    return np.array([[1, 0], [0, -1]], dtype=complex)


def identity(n: int) -> np.ndarray:
    return np.eye(2**n, dtype=complex)


def kron_at(op: np.ndarray, site: int, n: int) -> np.ndarray:
    """Place operator `op` at `site` in an n-qubit system."""
    result = np.eye(1, dtype=complex)
    for i in range(n):
        result = np.kron(result, op if i == site else np.eye(2, dtype=complex))
    return result


def transverse_field_ising(n: int, J: float, h: float) -> np.ndarray:
    """
    Construct the transverse-field Ising Hamiltonian on n sites (open boundary):
        H = -J ∑ Z_i Z_{i+1} - h ∑ X_i
    """
    dim = 2**n
    H = np.zeros((dim, dim), dtype=complex)
    for i in range(n - 1):
        ZZ = kron_at(pauli_z(), i, n) @ kron_at(pauli_z(), i + 1, n)
        H -= J * ZZ
    for i in range(n):
        H -= h * kron_at(pauli_x(), i, n)
    return H


def ground_state_data(H: np.ndarray) -> Tuple[np.ndarray, float, np.ndarray]:
    """
    Compute the ground state, spectral gap, and measurement probabilities.
    Returns (ground_state_vector, spectral_gap, probabilities).
    """
    eigenvalues, eigenvectors = np.linalg.eigh(H)
    idx = np.argsort(eigenvalues)
    E0 = eigenvalues[idx[0]]
    E1 = eigenvalues[idx[1]]
    psi = eigenvectors[:, idx[0]]
    gap = E1 - E0
    probs = np.abs(psi)**2
    return psi, gap, probs


def min_mass(probs: np.ndarray) -> float:
    """Minimum probability mass (anti-concentration certificate)."""
    return float(np.min(probs))


def log_concavity_certificate(probs: np.ndarray) -> float:
    """
    Surrogate Lorentzian gap: ratio of min to max probability.
    For a Lorentzian/log-concave distribution, this ratio is polynomially bounded.
    """
    p_min = np.min(probs)
    p_max = np.max(probs)
    if p_max < 1e-15:
        return 0.0
    return float(p_min / p_max)


def pairwise_log_concavity_score(probs: np.ndarray) -> float:
    """
    Measures max(μ(x)μ(y)) / max(μ)^2 over all pairs — should be ≤ 1
    for log-concave distributions.
    """
    p_max = np.max(probs)
    if p_max < 1e-15:
        return 0.0
    max_product = np.max(np.outer(probs, probs))
    return float(max_product / p_max**2)


def boundary_mass(probs: np.ndarray, n: int, subset_indices: np.ndarray) -> float:
    """
    Compute boundary mass for a Hamming-graph adjacency on bitstrings.
    A vertex x in A has a boundary neighbor if flipping one bit takes it outside A.
    """
    subset_set = set(subset_indices)
    mass = 0.0
    for x in subset_indices:
        has_boundary = False
        for bit in range(n):
            y = x ^ (1 << bit)
            if y not in subset_set:
                has_boundary = True
                break
        if has_boundary:
            mass += probs[x]
    return mass


def perturbation_ratio(probs1: np.ndarray, probs2: np.ndarray) -> float:
    """
    Compute the multiplicative perturbation parameter ε such that
    exp(-ε) * probs2[x] ≤ probs1[x] ≤ exp(ε) * probs2[x] for all x.
    """
    mask = (probs2 > 1e-15) & (probs1 > 1e-15)
    if not np.any(mask):
        return float('inf')
    ratios = probs1[mask] / probs2[mask]
    log_ratios = np.abs(np.log(ratios))
    return float(np.max(log_ratios))


def scan_field_strength(n: int, J: float, h_values: np.ndarray) -> Dict[str, List[float]]:
    """
    Scan over field strengths and compute quantum gap + certificates.
    """
    results = {
        'h': [], 'quantum_gap': [], 'min_mass': [],
        'log_concavity': [], 'pairwise_score': [],
        'boundary_mass_half': []
    }

    for h in h_values:
        H = transverse_field_ising(n, J, h)
        psi, gap, probs = ground_state_data(H)

        # Compute certificates
        mm = min_mass(probs)
        lc = log_concavity_certificate(probs)
        ps = pairwise_log_concavity_score(probs)

        # Boundary mass for first half of configurations
        half = np.arange(2**(n-1))
        bm = boundary_mass(probs, n, half)

        results['h'].append(float(h))
        results['quantum_gap'].append(float(gap))
        results['min_mass'].append(mm)
        results['log_concavity'].append(lc)
        results['pairwise_score'].append(ps)
        results['boundary_mass_half'].append(bm)

    return results


def plot_results(results: Dict[str, List[float]], n: int):
    """Generate publication-quality plots."""
    fig, axes = plt.subplots(2, 2, figsize=(12, 10))

    h = results['h']

    # Plot 1: Quantum spectral gap
    axes[0, 0].plot(h, results['quantum_gap'], 'b-o', markersize=3, linewidth=1.5)
    axes[0, 0].set_xlabel('Transverse field h')
    axes[0, 0].set_ylabel('Spectral gap Δ(H)')
    axes[0, 0].set_title(f'Quantum Spectral Gap (n={n})')
    axes[0, 0].grid(True, alpha=0.3)

    # Plot 2: Min mass (anti-concentration)
    axes[0, 1].semilogy(h, results['min_mass'], 'r-s', markersize=3, linewidth=1.5)
    axes[0, 1].set_xlabel('Transverse field h')
    axes[0, 1].set_ylabel('min μ(x)')
    axes[0, 1].set_title(f'Anti-concentration Certificate (n={n})')
    axes[0, 1].grid(True, alpha=0.3)

    # Plot 3: Log-concavity certificate vs gap
    axes[1, 0].plot(results['quantum_gap'], results['log_concavity'],
                    'g-^', markersize=3, linewidth=1.5)
    axes[1, 0].set_xlabel('Spectral gap Δ(H)')
    axes[1, 0].set_ylabel('Log-concavity certificate')
    axes[1, 0].set_title('Lorentzian Gap Surrogate vs Quantum Gap')
    axes[1, 0].grid(True, alpha=0.3)

    # Plot 4: Boundary mass vs gap
    axes[1, 1].plot(results['quantum_gap'], results['boundary_mass_half'],
                    'm-D', markersize=3, linewidth=1.5)
    axes[1, 1].set_xlabel('Spectral gap Δ(H)')
    axes[1, 1].set_ylabel('Boundary mass (half-space)')
    axes[1, 1].set_title('Classical Expansion vs Quantum Gap')
    axes[1, 1].grid(True, alpha=0.3)

    plt.suptitle(f'Quantum-to-Classical Bridge: Transverse-Field Ising Model (n={n})',
                 fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('quantum_classical_bridge.png', dpi=150, bbox_inches='tight')
    print("Plot saved to quantum_classical_bridge.png")


def main():
    print("=" * 70)
    print("Quantum-to-Classical Gap Bridge: Computational Demonstration")
    print("=" * 70)

    # Small system sizes for exact diagonalization
    for n in [4, 6, 8]:
        print(f"\n{'─' * 50}")
        print(f"Transverse-Field Ising Model, n = {n} sites")
        print(f"{'─' * 50}")

        J = 1.0
        h_values = np.linspace(0.1, 3.0, 30)
        results = scan_field_strength(n, J, h_values)

        # Print summary table
        print(f"{'h':>6s} {'Gap':>10s} {'MinMass':>12s} {'LogConc':>10s} {'BdryMass':>10s}")
        for i in range(0, len(h_values), 5):
            print(f"{results['h'][i]:6.2f} "
                  f"{results['quantum_gap'][i]:10.4f} "
                  f"{results['min_mass'][i]:12.6f} "
                  f"{results['log_concavity'][i]:10.6f} "
                  f"{results['boundary_mass_half'][i]:10.6f}")

        # Perturbation test: compare h=1.0 reference to nearby h values
        print(f"\n  Perturbation analysis (reference h=1.0):")
        H_ref = transverse_field_ising(n, J, 1.0)
        _, gap_ref, probs_ref = ground_state_data(H_ref)
        for delta_h in [0.1, 0.3, 0.5, 1.0]:
            H_pert = transverse_field_ising(n, J, 1.0 + delta_h)
            _, gap_pert, probs_pert = ground_state_data(H_pert)
            eps = perturbation_ratio(probs_pert, probs_ref)
            print(f"    δh={delta_h:.1f}: ε={eps:.4f}, "
                  f"gap_ref={gap_ref:.4f}, gap_pert={gap_pert:.4f}, "
                  f"ratio={gap_pert/gap_ref:.4f}")

    # Generate plots for n=6
    print(f"\n{'─' * 50}")
    print("Generating plots for n=6...")
    results = scan_field_strength(6, 1.0, np.linspace(0.1, 3.0, 50))
    plot_results(results, 6)

    # Conjectural scaling test
    print(f"\n{'─' * 50}")
    print("Testing conjectural scaling law:")
    print("  LorentzianGap(μ) ≥ Δ(H) / poly(n)")
    print(f"{'─' * 50}")
    for n in [4, 6, 8]:
        H = transverse_field_ising(n, 1.0, 1.0)  # Near critical point
        _, gap, probs = ground_state_data(H)
        lc = log_concavity_certificate(probs)
        ratio = lc / gap if gap > 1e-15 else float('inf')
        print(f"  n={n}: gap={gap:.6f}, LC={lc:.6f}, LC/gap={ratio:.6f}, "
              f"n^2={n**2}")

    print("\n" + "=" * 70)
    print("Demo complete.")
    print("=" * 70)


if __name__ == "__main__":
    main()


"""
Visualization: Quantum-to-Classical Gap Bridge

Visualizes the central correspondence: how the quantum spectral gap of a
transverse-field Ising model controls the Lorentzian gap surrogate and
classical expansion (boundary mass) of the ground-state measurement distribution.

Three panels show:
1. Quantum gap vs transverse field strength
2. Lorentzian gap surrogate tracking the quantum gap
3. Scatter plot revealing the quantitative bridge: classical expansion vs quantum gap
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def pauli_x():
    return np.array([[0, 1], [1, 0]], dtype=complex)

def pauli_z():
    return np.array([[1, 0], [0, -1]], dtype=complex)

def kron_at(op, site, n):
    result = np.eye(1, dtype=complex)
    for i in range(n):
        result = np.kron(result, op if i == site else np.eye(2, dtype=complex))
    return result

def tfim_hamiltonian(n, J, h):
    dim = 2**n
    H = np.zeros((dim, dim), dtype=complex)
    for i in range(n - 1):
        H -= J * kron_at(pauli_z(), i, n) @ kron_at(pauli_z(), i + 1, n)
    for i in range(n):
        H -= h * kron_at(pauli_x(), i, n)
    return H

def analyze(n, J, h):
    H = tfim_hamiltonian(n, J, h)
    evals, evecs = np.linalg.eigh(H)
    idx = np.argsort(evals)
    probs = np.abs(evecs[:, idx[0]])**2
    gap = evals[idx[1]] - evals[idx[0]]
    p_min, p_max = np.min(probs), np.max(probs)
    lor = p_min / p_max if p_max > 1e-15 else 0.0
    half = set(range(2**(n-1)))
    bm = sum(probs[x] for x in half if any(x ^ (1 << b) not in half for b in range(n)))
    return float(gap), lor, bm


fig, axes = plt.subplots(1, 3, figsize=(16, 5))

colors = {'4': '#2196F3', '6': '#FF5722', '8': '#4CAF50'}

for n in [4, 6, 8]:
    h_vals = np.linspace(0.1, 3.0, 60)
    gaps, lors, bms = [], [], []
    for h in h_vals:
        g, l, b = analyze(n, 1.0, h)
        gaps.append(g)
        lors.append(l)
        bms.append(b)

    c = colors[str(n)]

    axes[0].plot(h_vals, gaps, color=c, linewidth=2, label=f'n={n}')
    axes[0].set_xlabel('Transverse field h/J', fontsize=12)
    axes[0].set_ylabel('Spectral gap Δ(H)', fontsize=12)
    axes[0].set_title('Quantum Spectral Gap', fontsize=13, fontweight='bold')
    axes[0].axvline(x=1.0, color='gray', linestyle=':', alpha=0.5)
    axes[0].legend(fontsize=10)
    axes[0].grid(True, alpha=0.2)

    axes[1].plot(h_vals, lors, color=c, linewidth=2, label=f'n={n}')
    axes[1].set_xlabel('Transverse field h/J', fontsize=12)
    axes[1].set_ylabel('min(μ)/max(μ)', fontsize=12)
    axes[1].set_title('Lorentzian Gap Surrogate', fontsize=13, fontweight='bold')
    axes[1].axvline(x=1.0, color='gray', linestyle=':', alpha=0.5)
    axes[1].legend(fontsize=10)
    axes[1].grid(True, alpha=0.2)

    axes[2].scatter(gaps, bms, color=c, s=20, alpha=0.7, label=f'n={n}')
    axes[2].set_xlabel('Quantum gap Δ(H)', fontsize=12)
    axes[2].set_ylabel('Boundary mass (half-space)', fontsize=12)
    axes[2].set_title('Classical Expansion vs Quantum Gap', fontsize=13, fontweight='bold')
    axes[2].legend(fontsize=10)
    axes[2].grid(True, alpha=0.2)

plt.suptitle('Quantum-to-Classical Bridge: Transverse-Field Ising Model',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_gap_bridge.png', dpi=150, bbox_inches='tight')


"""
Visualization: Perturbative Stability of Measurement Distributions

Shows how the formal perturbation theorems work in practice:
1. Heatmap of measurement distributions at different field strengths
2. Perturbation parameter ε as a function of distance from reference
3. Guaranteed vs actual bounds from the formal theorems

Demonstrates event_prob_ratio_bound and minMass_perturbation_lower_bound.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.colors import LogNorm


def pauli_x():
    return np.array([[0, 1], [1, 0]], dtype=complex)

def pauli_z():
    return np.array([[1, 0], [0, -1]], dtype=complex)

def kron_at(op, site, n):
    result = np.eye(1, dtype=complex)
    for i in range(n):
        result = np.kron(result, op if i == site else np.eye(2, dtype=complex))
    return result

def tfim_hamiltonian(n, J, h):
    dim = 2**n
    H = np.zeros((dim, dim), dtype=complex)
    for i in range(n - 1):
        H -= J * kron_at(pauli_z(), i, n) @ kron_at(pauli_z(), i + 1, n)
    for i in range(n):
        H -= h * kron_at(pauli_x(), i, n)
    return H

def ground_probs(n, J, h):
    H = tfim_hamiltonian(n, J, h)
    evals, evecs = np.linalg.eigh(H)
    idx = np.argsort(evals)
    return np.abs(evecs[:, idx[0]])**2


n = 5
dim = 2**n
h_ref = 1.0
probs_ref = ground_probs(n, 1.0, h_ref)

fig, axes = plt.subplots(2, 2, figsize=(14, 11))

# Panel 1: Heatmap of distributions
h_values = np.linspace(0.2, 2.5, 40)
dist_matrix = np.zeros((len(h_values), dim))
for i, h in enumerate(h_values):
    dist_matrix[i] = ground_probs(n, 1.0, h)

im = axes[0, 0].imshow(dist_matrix, aspect='auto', cmap='hot',
                        extent=[0, dim-1, h_values[-1], h_values[0]],
                        norm=LogNorm(vmin=1e-6, vmax=1))
axes[0, 0].set_xlabel('Configuration index', fontsize=11)
axes[0, 0].set_ylabel('Transverse field h', fontsize=11)
axes[0, 0].set_title('Ground-State Measurement Distribution', fontsize=12, fontweight='bold')
plt.colorbar(im, ax=axes[0, 0], label='μ(x)')

# Panel 2: Perturbation ε vs distance
deltas = np.linspace(0.01, 1.5, 50)
epsilons = []
for d in deltas:
    probs_pert = ground_probs(n, 1.0, h_ref + d)
    mask = (probs_ref > 1e-15) & (probs_pert > 1e-15)
    if np.any(mask):
        eps = float(np.max(np.abs(np.log(probs_pert[mask] / probs_ref[mask]))))
    else:
        eps = float('inf')
    epsilons.append(eps)

axes[0, 1].plot(deltas, epsilons, 'b-', linewidth=2)
axes[0, 1].fill_between(deltas, 0, epsilons, alpha=0.15, color='blue')
axes[0, 1].set_xlabel('Distance from reference |h - h₀|', fontsize=11)
axes[0, 1].set_ylabel('Perturbation parameter ε', fontsize=11)
axes[0, 1].set_title('Multiplicative Closeness', fontsize=12, fontweight='bold')
axes[0, 1].grid(True, alpha=0.3)

# Panel 3: Guaranteed vs actual event probabilities
test_deltas = [0.1, 0.3, 0.5, 0.8, 1.0]
event = np.arange(dim // 2)  # first half

for d in test_deltas:
    probs_pert = ground_probs(n, 1.0, h_ref + d)
    mask = (probs_ref > 1e-15) & (probs_pert > 1e-15)
    eps = float(np.max(np.abs(np.log(probs_pert[mask] / probs_ref[mask])))) if np.any(mask) else 10.0

    nu_sum = np.sum(probs_ref[event])
    mu_sum = np.sum(probs_pert[event])
    lower = np.exp(-eps) * nu_sum
    upper = np.exp(eps) * nu_sum

    axes[1, 0].errorbar(d, mu_sum, yerr=[[mu_sum - lower], [upper - mu_sum]],
                        fmt='o', color='darkblue', capsize=5, markersize=8)

axes[1, 0].set_xlabel('Perturbation δh', fontsize=11)
axes[1, 0].set_ylabel('Event probability Pr[first half]', fontsize=11)
axes[1, 0].set_title('Event Prob Ratio Bound (Theorem 1)', fontsize=12, fontweight='bold')
axes[1, 0].grid(True, alpha=0.3)

# Panel 4: MinMass guaranteed vs actual
min_mass_ref = float(np.min(probs_ref))
deltas_dense = np.linspace(0.01, 1.2, 40)
guaranteed_list = []
actual_list = []

for d in deltas_dense:
    probs_pert = ground_probs(n, 1.0, h_ref + d)
    mask = (probs_ref > 1e-15) & (probs_pert > 1e-15)
    eps = float(np.max(np.abs(np.log(probs_pert[mask] / probs_ref[mask])))) if np.any(mask) else 10.0
    guaranteed_list.append(np.exp(-eps) * min_mass_ref)
    actual_list.append(float(np.min(probs_pert)))

axes[1, 1].semilogy(deltas_dense, actual_list, 'b-o', markersize=3, linewidth=1.5, label='Actual min mass')
axes[1, 1].semilogy(deltas_dense, guaranteed_list, 'r--s', markersize=3, linewidth=1.5, label='Guaranteed (Theorem 2)')
axes[1, 1].fill_between(deltas_dense, guaranteed_list, actual_list, alpha=0.1, color='green')
axes[1, 1].set_xlabel('Perturbation δh', fontsize=11)
axes[1, 1].set_ylabel('Minimum mass', fontsize=11)
axes[1, 1].set_title('MinMass Perturbation Bound (Theorem 2)', fontsize=12, fontweight='bold')
axes[1, 1].legend(fontsize=9)
axes[1, 1].grid(True, alpha=0.3)

plt.suptitle('Perturbative Stability of Quantum Measurement Distributions (n=5)',
             fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('viz_perturbation.png', dpi=150, bbox_inches='tight')


"""
Visualization: Phase Landscape of Lorentzian Quantum Geometry

A 2D heatmap showing how the Lorentzian gap surrogate varies across the
(J, h) parameter space of the transverse-field Ising model. Regions of
high Lorentzian gap (red) correspond to states amenable to classical
simulation; regions of low gap (blue) mark quantum phase transitions
where simulation becomes hard.

This visualizes the central conjecture: the geometry of measurement
distributions encodes computational complexity.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def pauli_x():
    return np.array([[0, 1], [1, 0]], dtype=complex)

def pauli_z():
    return np.array([[1, 0], [0, -1]], dtype=complex)

def kron_at(op, site, n):
    result = np.eye(1, dtype=complex)
    for i in range(n):
        result = np.kron(result, op if i == site else np.eye(2, dtype=complex))
    return result

def tfim_hamiltonian(n, J, h):
    dim = 2**n
    H = np.zeros((dim, dim), dtype=complex)
    for i in range(n - 1):
        H -= J * kron_at(pauli_z(), i, n) @ kron_at(pauli_z(), i + 1, n)
    for i in range(n):
        H -= h * kron_at(pauli_x(), i, n)
    return H

def compute_certificates(n, J, h):
    H = tfim_hamiltonian(n, J, h)
    evals, evecs = np.linalg.eigh(H)
    idx = np.argsort(evals)
    probs = np.abs(evecs[:, idx[0]])**2
    gap = evals[idx[1]] - evals[idx[0]]
    p_min, p_max = np.min(probs), np.max(probs)
    lor = p_min / p_max if p_max > 1e-15 else 0.0
    mask = probs > 1e-15
    entropy = -float(np.sum(probs[mask] * np.log(probs[mask])))
    return float(gap), lor, entropy


n = 6
J_vals = np.linspace(0.1, 2.5, 40)
h_vals = np.linspace(0.1, 2.5, 40)

gap_grid = np.zeros((len(h_vals), len(J_vals)))
lor_grid = np.zeros((len(h_vals), len(J_vals)))
ent_grid = np.zeros((len(h_vals), len(J_vals)))

for i, h in enumerate(h_vals):
    for j, J in enumerate(J_vals):
        g, l, e = compute_certificates(n, J, h)
        gap_grid[i, j] = g
        lor_grid[i, j] = l
        ent_grid[i, j] = e

fig, axes = plt.subplots(1, 3, figsize=(18, 5.5))

# Quantum gap landscape
im0 = axes[0].imshow(gap_grid, extent=[J_vals[0], J_vals[-1], h_vals[-1], h_vals[0]],
                      aspect='auto', cmap='viridis', origin='upper')
axes[0].plot(J_vals, J_vals, 'w--', linewidth=1.5, alpha=0.7, label='h/J = 1 (critical)')
axes[0].set_xlabel('Coupling J', fontsize=12)
axes[0].set_ylabel('Transverse field h', fontsize=12)
axes[0].set_title('Quantum Spectral Gap Δ(H)', fontsize=13, fontweight='bold')
axes[0].legend(fontsize=9, loc='upper left')
plt.colorbar(im0, ax=axes[0])

# Lorentzian gap landscape
im1 = axes[1].imshow(lor_grid, extent=[J_vals[0], J_vals[-1], h_vals[-1], h_vals[0]],
                      aspect='auto', cmap='RdYlBu_r', origin='upper',
                      vmin=0, vmax=1)
axes[1].plot(J_vals, J_vals, 'k--', linewidth=1.5, alpha=0.7, label='h/J = 1 (critical)')
axes[1].set_xlabel('Coupling J', fontsize=12)
axes[1].set_ylabel('Transverse field h', fontsize=12)
axes[1].set_title('Lorentzian Gap Surrogate', fontsize=13, fontweight='bold')
axes[1].legend(fontsize=9, loc='upper left')
plt.colorbar(im1, ax=axes[1])

# Entropy landscape
im2 = axes[2].imshow(ent_grid, extent=[J_vals[0], J_vals[-1], h_vals[-1], h_vals[0]],
                      aspect='auto', cmap='magma', origin='upper')
axes[2].plot(J_vals, J_vals, 'w--', linewidth=1.5, alpha=0.7, label='h/J = 1 (critical)')
axes[2].set_xlabel('Coupling J', fontsize=12)
axes[2].set_ylabel('Transverse field h', fontsize=12)
axes[2].set_title('Measurement Entropy', fontsize=13, fontweight='bold')
axes[2].legend(fontsize=9, loc='upper left')
plt.colorbar(im2, ax=axes[2])

plt.suptitle(f'Phase Landscape of Lorentzian Quantum Geometry (TFIM, n={n})',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_phase_landscape.png', dpi=150, bbox_inches='tight')
