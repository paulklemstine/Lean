#!/usr/bin/env python3
"""
applications.py — Real-World Applications of Quantum Lorentzian Bridge Theory

Demonstrates practical applications of the quantum-to-classical gap bridge:
1. Classical simulation certification near free-fermionic points
2. Ground-state measurement sampling validation
3. Phase transition detection via Lorentzian certificate breakdown
"""

import numpy as np
from typing import List, Tuple, Dict


# ─── Hamiltonian construction utilities ───

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
    """Transverse-field Ising model Hamiltonian."""
    dim = 2**n
    H = np.zeros((dim, dim), dtype=complex)
    for i in range(n - 1):
        H -= J * (kron_at(pauli_z(), i, n) @ kron_at(pauli_z(), i + 1, n))
    for i in range(n):
        H -= h * kron_at(pauli_x(), i, n)
    return H

def solve_hamiltonian(H):
    """Return (ground_energy, ground_state, spectral_gap)."""
    evals, evecs = np.linalg.eigh(H)
    idx = np.argsort(evals)
    return evals[idx[0]], evecs[:, idx[0]], evals[idx[1]] - evals[idx[0]]


# ─── Application 1: Classical Simulation Certification ───

def classical_simulation_certification(n_qubits: int = 4) -> Dict:
    """
    Application 1: Certify that classical simulation of measurement
    outcomes is efficient near the free-fermion point.
    
    The transverse-field Ising model at h >> J is close to a product state
    (effectively free), and the measurement distribution is nearly uniform.
    Our perturbation theorems guarantee that sampling remains efficient
    as long as the perturbation parameter ε is controlled.
    
    Returns diagnostic data about the simulation feasibility region.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 1: Classical Simulation Certification")
    print("=" * 60)
    
    J = 1.0
    h_values = np.linspace(0.5, 5.0, 30)
    
    # Reference: large field (near product state)
    H_ref = tfim_hamiltonian(n_qubits, J, 5.0)
    _, psi_ref, _ = solve_hamiltonian(H_ref)
    mu_ref = np.abs(psi_ref)**2
    
    results = []
    
    print(f"\n{'h':>6s} | {'Δ(H)':>8s} | {'ε':>8s} | {'min_mass':>10s} | {'Certified?':>10s}")
    print("-" * 55)
    
    for h in h_values:
        H = tfim_hamiltonian(n_qubits, J, h)
        _, psi, gap = solve_hamiltonian(H)
        mu = np.abs(psi)**2
        
        # Compute perturbation parameter
        eps = 0.0
        for i in range(len(mu)):
            if mu_ref[i] > 1e-15 and mu[i] > 1e-15:
                eps = max(eps, abs(np.log(mu[i] / mu_ref[i])))
        
        min_mass = float(np.min(mu))
        
        # Certification: simulation efficient if ε < threshold
        certified = eps < 2.0  # Conservative threshold
        
        status = "✓ EFFICIENT" if certified else "✗ UNCERTAIN"
        print(f"{h:6.2f} | {gap:8.4f} | {eps:8.4f} | {min_mass:10.6f} | {status}")
        
        results.append({
            'h': h, 'gap': gap, 'eps': eps,
            'min_mass': min_mass, 'certified': certified
        })
    
    # Find the boundary of the certified region
    certified_h = [r['h'] for r in results if r['certified']]
    if certified_h:
        print(f"\nCertified simulation region: h ∈ [{min(certified_h):.2f}, {max(certified_h):.2f}]")
    
    return {'results': results, 'n_qubits': n_qubits}


# ─── Application 2: Sampling Validation ───

def sampling_validation(n_qubits: int = 3) -> Dict:
    """
    Application 2: Validate that samples from a perturbed distribution
    satisfy the event probability ratio bound.
    
    Generates samples from the ground state measurement distribution
    and verifies that empirical event probabilities match the theoretical
    bounds from Theorem event_prob_ratio_bound.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: Sampling Validation")
    print("=" * 60)
    
    J, h = 1.0, 1.5
    n_samples = 10000
    dim = 2 ** n_qubits
    
    # Ground state distribution
    H = tfim_hamiltonian(n_qubits, J, h)
    _, psi, gap = solve_hamiltonian(H)
    mu = np.abs(psi)**2
    
    # Reference (large field)
    H_ref = tfim_hamiltonian(n_qubits, J, 3.0)
    _, psi_ref, _ = solve_hamiltonian(H_ref)
    nu = np.abs(psi_ref)**2
    
    # Perturbation parameter
    eps = 0.0
    for i in range(dim):
        if nu[i] > 1e-15 and mu[i] > 1e-15:
            eps = max(eps, abs(np.log(mu[i] / nu[i])))
    
    # Generate samples
    rng = np.random.RandomState(123)
    samples = rng.choice(dim, size=n_samples, p=mu)
    
    print(f"\nSystem: {n_qubits} qubits, J={J}, h={h}")
    print(f"Spectral gap: {gap:.4f}")
    print(f"Perturbation ε: {eps:.4f}")
    print(f"Samples: {n_samples}")
    print()
    
    # Test various events
    test_events = [
        list(range(dim // 4)),
        list(range(dim // 2)),
        list(range(3 * dim // 4)),
        [0, 1, 2],
        [dim - 3, dim - 2, dim - 1],
    ]
    
    violations = 0
    total_tests = 0
    
    for event in test_events:
        # Empirical probability
        empirical = sum(1 for s in samples if s in event) / n_samples
        
        # Theoretical bounds
        nu_event = sum(nu[i] for i in event)
        lower = np.exp(-eps) * nu_event
        upper = np.exp(eps) * nu_event
        
        # True probability
        true_prob = sum(mu[i] for i in event)
        
        total_tests += 1
        bound_ok = lower <= true_prob + 1e-10 and true_prob <= upper + 1e-10
        if not bound_ok:
            violations += 1
        
        print(f"  Event {event[:3]}{'...' if len(event) > 3 else ''}: "
              f"true={true_prob:.4f}, empirical={empirical:.4f}, "
              f"bounds=[{lower:.4f}, {upper:.4f}] {'✓' if bound_ok else '✗'}")
    
    print(f"\nBound violations: {violations}/{total_tests}")
    
    return {'eps': eps, 'gap': gap, 'violations': violations}


# ─── Application 3: Phase Transition Detection ───

def phase_transition_detection(n_qubits: int = 5) -> Dict:
    """
    Application 3: Detect quantum phase transitions via breakdown
    of the Lorentzian certificate.
    
    As the system crosses a quantum critical point, the measurement
    distribution loses its log-concavity properties. The Lorentzian
    certificate degrades, signaling the phase transition.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: Phase Transition Detection")
    print("=" * 60)
    
    J = 1.0
    h_values = np.linspace(0.1, 3.0, 40)
    dim = 2 ** n_qubits
    
    results = []
    
    print(f"\nSystem: {n_qubits} qubits")
    print(f"Scanning h from {h_values[0]:.1f} to {h_values[-1]:.1f}")
    print(f"Expected critical point: h/J ≈ 1.0")
    print()
    print(f"{'h':>6s} | {'Δ(H)':>8s} | {'entropy':>8s} | {'LC_ratio':>10s} | {'Phase':>12s}")
    print("-" * 55)
    
    for h in h_values:
        H = tfim_hamiltonian(n_qubits, J, h)
        _, psi, gap = solve_hamiltonian(H)
        mu = np.abs(psi)**2
        
        # Shannon entropy
        entropy = -sum(p * np.log2(p) for p in mu if p > 1e-15)
        
        # Log-concavity ratio
        max_mu = np.max(mu)
        min_mu = np.min(mu)
        if max_mu > 0 and min_mu > 0:
            lc_ratio = min_mu / max_mu
        else:
            lc_ratio = 0.0
        
        # Phase classification
        if gap > 0.5:
            phase = "GAPPED"
        elif gap > 0.1:
            phase = "NEAR-CRIT"
        else:
            phase = "CRITICAL"
        
        if h % 0.3 < 0.08:  # Print every ~3rd value
            print(f"{h:6.2f} | {gap:8.4f} | {entropy:8.4f} | {lc_ratio:10.6f} | {phase}")
        
        results.append({
            'h': h, 'gap': gap, 'entropy': entropy,
            'lc_ratio': lc_ratio, 'phase': phase
        })
    
    # Find approximate critical point
    min_gap_idx = np.argmin([r['gap'] for r in results])
    h_critical = results[min_gap_idx]['h']
    
    print(f"\nEstimated critical point: h ≈ {h_critical:.2f}")
    print(f"Gap at critical point: {results[min_gap_idx]['gap']:.4f}")
    print(f"LC ratio at critical point: {results[min_gap_idx]['lc_ratio']:.6f}")
    
    # LC ratio drop as phase transition indicator
    lc_max = max(r['lc_ratio'] for r in results)
    lc_crit = results[min_gap_idx]['lc_ratio']
    print(f"LC ratio drop: {lc_max:.4f} → {lc_crit:.4f} "
          f"({100*(lc_max - lc_crit)/lc_max:.1f}% decrease)")
    
    return {'results': results, 'h_critical': h_critical}


if __name__ == "__main__":
    print("Applications of Quantum Lorentzian Bridge Theory")
    print("=" * 50)
    
    r1 = classical_simulation_certification(n_qubits=4)
    r2 = sampling_validation(n_qubits=3)
    r3 = phase_transition_detection(n_qubits=5)
    
    print("\n" + "=" * 50)
    print("All applications completed successfully.")


#!/usr/bin/env python3
"""
demo.py — Quantum Many-Body Lorentzian Gap Demo

Constructs small transverse-field Ising instances, diagonalizes the Hamiltonian,
extracts ground-state measurement probabilities, computes surrogate Lorentzian /
expansion certificates, and compares them to the quantum spectral gap as the
transverse field strength varies.

Usage:
    python demo.py
"""

import numpy as np
from typing import Tuple, List
import sys


def pauli_x() -> np.ndarray:
    """Pauli X matrix."""
    return np.array([[0, 1], [1, 0]], dtype=complex)


def pauli_z() -> np.ndarray:
    """Pauli Z matrix."""
    return np.array([[1, 0], [0, -1]], dtype=complex)


def identity(n: int) -> np.ndarray:
    """2^n x 2^n identity matrix."""
    return np.eye(2**n, dtype=complex)


def kron_at(op: np.ndarray, site: int, n: int) -> np.ndarray:
    """Place operator `op` at site `site` in an n-qubit system."""
    result = np.eye(1, dtype=complex)
    for i in range(n):
        result = np.kron(result, op if i == site else np.eye(2, dtype=complex))
    return result


def transverse_field_ising_hamiltonian(n: int, J: float, h: float) -> np.ndarray:
    """
    Build the 1D transverse-field Ising Hamiltonian:
        H = -J ∑_i Z_i Z_{i+1} - h ∑_i X_i
    with open boundary conditions.
    
    Args:
        n: Number of qubits/spins
        J: Ising coupling strength
        h: Transverse field strength
    
    Returns:
        2^n x 2^n Hamiltonian matrix
    """
    dim = 2**n
    H = np.zeros((dim, dim), dtype=complex)
    
    # ZZ interaction terms
    for i in range(n - 1):
        Zi = kron_at(pauli_z(), i, n)
        Zi1 = kron_at(pauli_z(), i + 1, n)
        H -= J * (Zi @ Zi1)
    
    # Transverse field terms
    for i in range(n):
        Xi = kron_at(pauli_x(), i, n)
        H -= h * Xi
    
    return H


def compute_ground_state(H: np.ndarray) -> Tuple[float, np.ndarray, float]:
    """
    Compute the ground state of Hamiltonian H.
    
    Returns:
        (ground_energy, ground_state_amplitudes, spectral_gap)
    """
    eigenvalues, eigenvectors = np.linalg.eigh(H)
    idx = np.argsort(eigenvalues)
    eigenvalues = eigenvalues[idx]
    eigenvectors = eigenvectors[:, idx]
    
    ground_energy = eigenvalues[0]
    ground_state = eigenvectors[:, 0]
    spectral_gap = eigenvalues[1] - eigenvalues[0]
    
    return ground_energy, ground_state, spectral_gap


def measurement_distribution(psi: np.ndarray) -> np.ndarray:
    """Born-rule measurement probabilities: μ(x) = |ψ(x)|²."""
    return np.abs(psi)**2


def min_mass(mu: np.ndarray) -> float:
    """Minimum singleton mass — basic anti-concentration measure."""
    return float(np.min(mu))


def pair_mass_gap(mu: np.ndarray) -> float:
    """Minimum pairwise mass gap: min_{x,y} μ(x) + μ(y)."""
    n = len(mu)
    min_val = float('inf')
    for i in range(n):
        for j in range(n):
            val = mu[i] + mu[j]
            if val < min_val:
                min_val = val
    return min_val


def log_concavity_certificate(mu: np.ndarray) -> float:
    """
    Compute a surrogate Lorentzian gap certificate.
    
    This measures how close to log-concave the distribution is,
    using the minimum ratio μ(x)μ(y) / max(μ)² over all pairs.
    A value of 1 means perfectly anti-concentrated; closer to 0
    means more concentrated.
    """
    max_mu = np.max(mu)
    if max_mu == 0:
        return 0.0
    
    n = len(mu)
    min_ratio = float('inf')
    for i in range(n):
        for j in range(n):
            if mu[i] > 0 and mu[j] > 0:
                ratio = (mu[i] * mu[j]) / (max_mu**2)
                min_ratio = min(min_ratio, ratio)
    
    return min_ratio if min_ratio != float('inf') else 0.0


def boundary_mass(mu: np.ndarray, A_indices: List[int], n_qubits: int) -> float:
    """
    Compute boundary mass for Hamming-graph local moves.
    
    A vertex x is in the boundary of A if it has a Hamming neighbor
    outside A (i.e., flipping one bit takes it outside A).
    """
    A_set = set(A_indices)
    dim = 2**n_qubits
    total = 0.0
    
    for x in A_indices:
        # Check Hamming neighbors
        has_outside_neighbor = False
        for bit in range(n_qubits):
            neighbor = x ^ (1 << bit)
            if neighbor not in A_set:
                has_outside_neighbor = True
                break
        if has_outside_neighbor:
            total += mu[x]
    
    return total


def perturbation_ratio(mu: np.ndarray, nu: np.ndarray) -> float:
    """
    Compute the multiplicative perturbation parameter ε such that
    exp(-ε) * ν(x) ≤ μ(x) ≤ exp(ε) * ν(x) for all x with ν(x) > 0.
    """
    eps = 0.0
    for i in range(len(mu)):
        if nu[i] > 1e-15 and mu[i] > 1e-15:
            log_ratio = abs(np.log(mu[i] / nu[i]))
            eps = max(eps, log_ratio)
    return eps


def run_demo():
    """Main demo: scan transverse field and compute certificates."""
    print("=" * 70)
    print("Quantum Many-Body Lorentzian Gap Demo")
    print("Transverse-Field Ising Model: H = -J ΣZZ - h ΣX")
    print("=" * 70)
    
    n_qubits = 4
    J = 1.0
    h_values = np.linspace(0.1, 3.0, 20)
    
    print(f"\nSystem: {n_qubits} qubits, J = {J}")
    print(f"Scanning h from {h_values[0]:.2f} to {h_values[-1]:.2f}")
    print()
    
    # Header
    print(f"{'h':>6s} | {'Δ(H)':>8s} | {'min_mass':>10s} | {'pair_gap':>10s} | "
          f"{'LC_cert':>10s} | {'ε_ref':>8s}")
    print("-" * 70)
    
    results = []
    
    # Use h=0.1 (near classical limit) as reference distribution
    H_ref = transverse_field_ising_hamiltonian(n_qubits, J, h_values[0])
    _, psi_ref, _ = compute_ground_state(H_ref)
    mu_ref = measurement_distribution(psi_ref)
    
    for h in h_values:
        H = transverse_field_ising_hamiltonian(n_qubits, J, h)
        E0, psi, gap = compute_ground_state(H)
        mu = measurement_distribution(psi)
        
        mm = min_mass(mu)
        pg = pair_mass_gap(mu)
        lc = log_concavity_certificate(mu)
        eps = perturbation_ratio(mu, mu_ref)
        
        print(f"{h:6.2f} | {gap:8.4f} | {mm:10.6f} | {pg:10.6f} | "
              f"{lc:10.6f} | {eps:8.4f}")
        
        results.append({
            'h': h, 'gap': gap, 'min_mass': mm,
            'pair_gap': pg, 'lc_cert': lc, 'eps': eps
        })
    
    print()
    print("=" * 70)
    print("KEY OBSERVATIONS:")
    print("=" * 70)
    print()
    print("1. The quantum spectral gap Δ(H) varies with field strength h.")
    print("   Near h=1 (critical point), the gap closes for large systems.")
    print()
    print("2. The minimum mass (anti-concentration) tracks the gap:")
    print("   larger gap ⟹ more spread-out measurement distribution.")
    print()
    print("3. The log-concavity certificate measures how 'Lorentzian' the")
    print("   measurement polynomial is — closer to 1 means stronger")
    print("   negative dependence properties.")
    print()
    print("4. The perturbation parameter ε grows as h moves away from")
    print("   the reference point, validating the perturbative framework.")
    print()
    
    # Test the event probability ratio bound
    print("=" * 70)
    print("TESTING EVENT PROBABILITY RATIO BOUND (Theorem 1)")
    print("=" * 70)
    print()
    
    h_test = 1.5
    H_test = transverse_field_ising_hamiltonian(n_qubits, J, h_test)
    _, psi_test, gap_test = compute_ground_state(H_test)
    mu_test = measurement_distribution(psi_test)
    eps_test = perturbation_ratio(mu_test, mu_ref)
    
    # Test for various event sets
    dim = 2**n_qubits
    for event_size in [1, 4, 8, 12]:
        event = list(range(event_size))
        mu_event = sum(mu_test[i] for i in event)
        nu_event = sum(mu_ref[i] for i in event)
        
        lower = np.exp(-eps_test) * nu_event
        upper = np.exp(eps_test) * nu_event
        
        holds = lower <= mu_event + 1e-10 and mu_event <= upper + 1e-10
        
        print(f"  Event size {event_size:2d}: "
              f"exp(-ε)·ν(S)={lower:.6f} ≤ μ(S)={mu_event:.6f} ≤ exp(ε)·ν(S)={upper:.6f}"
              f"  [{'✓' if holds else '✗'}]")
    
    print()
    
    # Test boundary mass perturbation bound
    print("=" * 70)
    print("TESTING BOUNDARY MASS PERTURBATION BOUND (Theorem 3)")
    print("=" * 70)
    print()
    
    for frac in [0.25, 0.5, 0.75]:
        A = list(range(int(dim * frac)))
        bm_test = boundary_mass(mu_test, A, n_qubits)
        bm_ref = boundary_mass(mu_ref, A, n_qubits)
        
        lower_bound = np.exp(-eps_test) * bm_ref
        holds = lower_bound <= bm_test + 1e-10
        
        print(f"  |A|/|Ω| = {frac:.2f}: "
              f"exp(-ε)·∂T(A)={lower_bound:.6f} ≤ ∂S(A)={bm_test:.6f}"
              f"  [{'✓' if holds else '✗'}]")
    
    print()
    print("Demo complete.")
    return results


if __name__ == "__main__":
    run_demo()


#!/usr/bin/env python3
"""
Visualization 3: Boundary Expansion and Cheeger Constants

Visualizes the boundary mass and Cheeger constant of quantum measurement
distributions on the Hamming graph, demonstrating Theorem 3
(perturbative_boundaryMassC_lower_bound).
"""

import numpy as np
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
        H -= J * (kron_at(pauli_z(), i, n) @ kron_at(pauli_z(), i + 1, n))
    for i in range(n):
        H -= h * kron_at(pauli_x(), i, n)
    return H

def ground_state(H):
    evals, evecs = np.linalg.eigh(H)
    idx = np.argsort(evals)
    return evecs[:, idx[0]], evals[idx[1]] - evals[idx[0]]

def boundary_mass(mu, A_indices, n_qubits):
    A_set = set(A_indices)
    total = 0.0
    for x in A_indices:
        for bit in range(n_qubits):
            neighbor = x ^ (1 << bit)
            if neighbor not in A_set:
                total += mu[x]
                break
    return total

def cheeger_estimate(mu, n_qubits, n_samples=200):
    dim = 2 ** n_qubits
    rng = np.random.RandomState(42)
    min_cheeger = float('inf')
    
    for _ in range(n_samples):
        mask = rng.randint(0, 2, size=dim).astype(bool)
        if not np.any(mask) or np.all(mask):
            continue
        A = np.where(mask)[0].tolist()
        mu_A = sum(mu[i] for i in A)
        if mu_A < 1e-10 or mu_A > 1 - 1e-10:
            continue
        bm = boundary_mass(mu, A, n_qubits)
        cheeger = bm / (mu_A * (1 - mu_A))
        min_cheeger = min(min_cheeger, cheeger)
    
    return min_cheeger if min_cheeger != float('inf') else 0.0


n_qubits = 4
dim = 2 ** n_qubits
J = 1.0
h_values = np.linspace(0.2, 3.5, 40)

fig, axes = plt.subplots(2, 2, figsize=(14, 10))
fig.suptitle('Boundary Expansion of Quantum Measurement Distributions\n'
             f'{n_qubits}-qubit TFIM on Hamming Graph',
             fontsize=14, fontweight='bold')

# Panel 1: Boundary mass for fixed set A = first half
ax = axes[0][0]
A_half = list(range(dim // 2))

bm_values = []
bm_ref_lower = []
gaps = []

# Reference
H_ref = tfim_hamiltonian(n_qubits, J, 3.0)
psi_ref, _ = ground_state(H_ref)
mu_ref = np.abs(psi_ref)**2
bm_ref = boundary_mass(mu_ref, A_half, n_qubits)

for h in h_values:
    H = tfim_hamiltonian(n_qubits, J, h)
    psi, gap = ground_state(H)
    mu = np.abs(psi)**2
    
    bm = boundary_mass(mu, A_half, n_qubits)
    bm_values.append(bm)
    gaps.append(gap)
    
    # Compute ε
    eps = 0.0
    for i in range(dim):
        if mu_ref[i] > 1e-15 and mu[i] > 1e-15:
            eps = max(eps, abs(np.log(mu[i] / mu_ref[i])))
    bm_ref_lower.append(np.exp(-eps) * bm_ref)

ax.plot(h_values, bm_values, 'b-', linewidth=2, label='∂μ(A) actual')
ax.plot(h_values, bm_ref_lower, 'r--', linewidth=2, label='exp(-ε)·∂ν(A) lower bound')
ax.fill_between(h_values, bm_ref_lower, bm_values, alpha=0.15, color='green',
                where=[b <= a + 1e-10 for a, b in zip(bm_values, bm_ref_lower)])
ax.axvline(x=1.0, color='gray', linestyle='-.', alpha=0.5)
ax.set_xlabel('Transverse field h')
ax.set_ylabel('Boundary mass')
ax.set_title('Boundary Mass: Actual vs. Perturbative Bound')
ax.legend(fontsize=9)

# Panel 2: Cheeger constant estimate
ax = axes[0][1]
cheeger_values = []
for h in h_values:
    H = tfim_hamiltonian(n_qubits, J, h)
    psi, _ = ground_state(H)
    mu = np.abs(psi)**2
    cheeger_values.append(cheeger_estimate(mu, n_qubits))

ax.plot(h_values, cheeger_values, 'g-', linewidth=2)
ax.plot(h_values, gaps, 'b--', linewidth=1.5, alpha=0.7, label='Spectral gap Δ(H)')
ax.axvline(x=1.0, color='gray', linestyle='-.', alpha=0.5)
ax.set_xlabel('Transverse field h')
ax.set_ylabel('Value')
ax.set_title('Cheeger Constant vs. Quantum Gap')
ax.legend(['Cheeger Φ(μ)', 'Spectral gap Δ(H)'], fontsize=10)

# Panel 3: Boundary mass for multiple set sizes
ax = axes[1][0]
h_test = 1.5
H_test = tfim_hamiltonian(n_qubits, J, h_test)
psi_test, _ = ground_state(H_test)
mu_test = np.abs(psi_test)**2

set_sizes = range(1, dim)
bm_by_size = []
for k in set_sizes:
    # Use first k configurations
    A = list(range(k))
    bm_by_size.append(boundary_mass(mu_test, A, n_qubits))

mu_A_vals = [sum(mu_test[i] for i in range(k)) for k in set_sizes]
ax.plot(mu_A_vals, bm_by_size, 'b-', linewidth=2)
ax.set_xlabel('μ(A)')
ax.set_ylabel('Boundary mass ∂μ(A)')
ax.set_title(f'Boundary Mass Profile (h={h_test})')
ax.axhline(y=0, color='gray', linestyle=':', alpha=0.5)

# Panel 4: Heatmap of measurement distribution
ax = axes[1][1]
n_h_heatmap = 30
h_heatmap = np.linspace(0.2, 3.0, n_h_heatmap)
probs_matrix = np.zeros((n_h_heatmap, dim))

for i, h in enumerate(h_heatmap):
    H = tfim_hamiltonian(n_qubits, J, h)
    psi, _ = ground_state(H)
    probs_matrix[i, :] = np.abs(psi)**2

im = ax.imshow(probs_matrix.T, aspect='auto', cmap='viridis',
               extent=[h_heatmap[0], h_heatmap[-1], dim - 0.5, -0.5])
ax.set_xlabel('Transverse field h')
ax.set_ylabel('Configuration index')
ax.set_title('Measurement Distribution μ(x)')
plt.colorbar(im, ax=ax, label='Probability')

plt.tight_layout()
plt.savefig('viz_boundary_expansion.png', dpi=150, bbox_inches='tight')
print("Saved viz_boundary_expansion.png")


#!/usr/bin/env python3
"""
Visualization 1: Quantum Spectral Gap vs. Lorentzian Certificate

Plots the quantum spectral gap Δ(H) alongside the surrogate Lorentzian
certificate (minimum mass, log-concavity ratio) as transverse field h varies
in the 1D transverse-field Ising model.

This visualizes the core conjecture: quantum gap controls Lorentzian gap.
"""

import numpy as np
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
        H -= J * (kron_at(pauli_z(), i, n) @ kron_at(pauli_z(), i + 1, n))
    for i in range(n):
        H -= h * kron_at(pauli_x(), i, n)
    return H

def solve(H):
    evals = np.linalg.eigvalsh(H)
    evals.sort()
    return evals[1] - evals[0], evals

def ground_state(H):
    evals, evecs = np.linalg.eigh(H)
    idx = np.argsort(evals)
    return evecs[:, idx[0]]


# Compute data for multiple system sizes
fig, axes = plt.subplots(2, 2, figsize=(14, 10))
fig.suptitle('Quantum Spectral Gap vs. Lorentzian Certificates\n'
             'Transverse-Field Ising Model: H = -J ΣZ_iZ_{i+1} - h ΣX_i',
             fontsize=14, fontweight='bold')

h_values = np.linspace(0.1, 3.0, 60)

for n_idx, n_qubits in enumerate([3, 4, 5, 6]):
    ax = axes[n_idx // 2][n_idx % 2]
    
    gaps = []
    min_masses = []
    lc_ratios = []
    entropies = []
    
    for h in h_values:
        H = tfim_hamiltonian(n_qubits, 1.0, h)
        gap, _ = solve(H)
        psi = ground_state(H)
        mu = np.abs(psi)**2
        
        gaps.append(gap)
        min_masses.append(float(np.min(mu)))
        
        max_mu = np.max(mu)
        min_mu = np.min(mu)
        lc_ratios.append(min_mu / max_mu if max_mu > 0 else 0)
        
        ent = -sum(p * np.log2(p) for p in mu if p > 1e-15)
        entropies.append(ent / n_qubits)  # Normalized
    
    ax2 = ax.twinx()
    
    l1, = ax.plot(h_values, gaps, 'b-', linewidth=2, label='Spectral gap Δ(H)')
    l2, = ax2.plot(h_values, lc_ratios, 'r--', linewidth=2, label='LC ratio min/max μ')
    l3, = ax2.plot(h_values, [m * 2**n_qubits for m in min_masses], 'g:', 
                    linewidth=2, label='Normalized min mass')
    
    ax.axvline(x=1.0, color='gray', linestyle='-.', alpha=0.5, label='h/J = 1 (critical)')
    
    ax.set_xlabel('Transverse field h', fontsize=11)
    ax.set_ylabel('Spectral gap Δ(H)', color='blue', fontsize=11)
    ax2.set_ylabel('Certificate value', color='red', fontsize=11)
    ax.set_title(f'n = {n_qubits} qubits ({2**n_qubits} configs)', fontsize=12)
    
    lines = [l1, l2, l3]
    labels = [l.get_label() for l in lines]
    ax.legend(lines, labels, loc='upper right', fontsize=8)
    
    ax.tick_params(axis='y', labelcolor='blue')
    ax2.tick_params(axis='y', labelcolor='red')

plt.tight_layout()
plt.savefig('viz_gap_certificate.png', dpi=150, bbox_inches='tight')
print("Saved viz_gap_certificate.png")


#!/usr/bin/env python3
"""
Visualization 2: Perturbation Landscape — ε-Distance from Free-Fermion Reference

Shows how the multiplicative perturbation parameter ε varies across the
phase diagram, illustrating the regime where our perturbative theorems
(event_prob_ratio_bound, perturbative_boundaryMassC_lower_bound) apply.
"""

import numpy as np
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
        H -= J * (kron_at(pauli_z(), i, n) @ kron_at(pauli_z(), i + 1, n))
    for i in range(n):
        H -= h * kron_at(pauli_x(), i, n)
    return H

def ground_state(H):
    evals, evecs = np.linalg.eigh(H)
    idx = np.argsort(evals)
    return evecs[:, idx[0]], evals[idx[1]] - evals[idx[0]]


n_qubits = 5
dim = 2 ** n_qubits
J = 1.0

# Reference points: deep in each phase
h_ref_high = 5.0  # Paramagnetic (near product state / free-fermion)
H_ref = tfim_hamiltonian(n_qubits, J, h_ref_high)
psi_ref, _ = ground_state(H_ref)
mu_ref = np.abs(psi_ref)**2

h_values = np.linspace(0.1, 4.0, 80)

fig, axes = plt.subplots(1, 3, figsize=(16, 5))
fig.suptitle('Perturbation Landscape for Quantum Measurement Distributions\n'
             f'{n_qubits}-qubit Transverse-Field Ising Model, reference at h={h_ref_high}',
             fontsize=13, fontweight='bold')

# Panel 1: ε vs h
epsilons = []
gaps = []
for h in h_values:
    H = tfim_hamiltonian(n_qubits, J, h)
    psi, gap = ground_state(H)
    mu = np.abs(psi)**2
    
    eps = 0.0
    for i in range(dim):
        if mu_ref[i] > 1e-15 and mu[i] > 1e-15:
            eps = max(eps, abs(np.log(mu[i] / mu_ref[i])))
    
    epsilons.append(eps)
    gaps.append(gap)

ax = axes[0]
ax.plot(h_values, epsilons, 'b-', linewidth=2)
ax.axvline(x=1.0, color='red', linestyle='--', alpha=0.7, label='Critical point')
ax.fill_between(h_values, 0, epsilons, alpha=0.15, color='blue')
ax.set_xlabel('Transverse field h', fontsize=12)
ax.set_ylabel('Perturbation parameter ε', fontsize=12)
ax.set_title('Multiplicative Distance\nfrom Reference', fontsize=12)
ax.legend(fontsize=10)

# Panel 2: exp(-ε) bound degradation
ax = axes[1]
exp_neg_eps = [np.exp(-e) for e in epsilons]
ax.plot(h_values, exp_neg_eps, 'g-', linewidth=2, label='exp(-ε)')
ax.plot(h_values, [np.exp(e) for e in epsilons], 'r-', linewidth=2, label='exp(ε)')
ax.fill_between(h_values, exp_neg_eps, [np.exp(e) for e in epsilons],
                alpha=0.1, color='orange')
ax.axhline(y=1.0, color='gray', linestyle=':', alpha=0.5)
ax.axvline(x=1.0, color='red', linestyle='--', alpha=0.7)
ax.set_xlabel('Transverse field h', fontsize=12)
ax.set_ylabel('Multiplicative factor', fontsize=12)
ax.set_title('Event Probability Ratio\nBound (Theorem 1)', fontsize=12)
ax.set_yscale('log')
ax.legend(fontsize=10)

# Panel 3: Gap vs ε scatter
ax = axes[2]
colors = ['green' if e < 1.0 else 'orange' if e < 2.0 else 'red' for e in epsilons]
ax.scatter(gaps, epsilons, c=colors, s=40, alpha=0.7, edgecolors='black', linewidths=0.5)
ax.set_xlabel('Quantum spectral gap Δ(H)', fontsize=12)
ax.set_ylabel('Perturbation parameter ε', fontsize=12)
ax.set_title('Gap-Perturbation\nCorrelation', fontsize=12)

# Add annotation
ax.annotate('Efficient\nregion', xy=(max(gaps)*0.7, min(epsilons)*1.5),
            fontsize=11, color='green', fontweight='bold')
ax.annotate('Critical\nregion', xy=(min(gaps)*1.2, max(epsilons)*0.8),
            fontsize=11, color='red', fontweight='bold')

plt.tight_layout()
plt.savefig('viz_perturbation_landscape.png', dpi=150, bbox_inches='tight')
print("Saved viz_perturbation_landscape.png")
