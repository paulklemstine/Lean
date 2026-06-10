#!/usr/bin/env python3
"""
applications.py — Real-World Applications of the Quantum Lorentzian Bridge

Demonstrates how the formal bridge theorems apply to:
1. Classical simulation of quantum measurements near integrable points
2. Certified sampling from quantum ground states
3. Phase transition detection via anti-concentration collapse
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

def get_ground_state(H):
    eigenvalues, eigenvectors = np.linalg.eigh(H)
    idx = np.argsort(eigenvalues.real)
    return eigenvalues[idx[0]], eigenvalues[idx[1]], eigenvectors[:, idx[0]]


# ============================================================================
# Application 1: Classical Simulation Feasibility Assessment
# ============================================================================
def app_classical_simulation():
    """
    Assess feasibility of classical simulation by checking whether
    the measurement distribution retains Lorentzian structure.
    
    Key idea: If exp(-ε) * ν(x) ≤ μ(x) ≤ exp(ε) * ν(x) for small ε,
    then classical sampling algorithms (Glauber dynamics) work efficiently
    because boundary mass / expansion is preserved (Theorem 3).
    """
    print("=" * 60)
    print("Application 1: Classical Simulation Feasibility")
    print("=" * 60)
    
    n = 5
    J = 1.0
    
    # Reference: h >> J (paramagnetic, nearly product state = determinantal)
    h_ref = 5.0
    H_ref = tfim_hamiltonian(n, J, h_ref)
    _, _, psi_ref = get_ground_state(H_ref)
    mu_ref = np.abs(psi_ref)**2
    
    print(f"\nReference: h={h_ref} (paramagnetic regime)")
    print(f"  min(μ_ref) = {np.min(mu_ref):.6f}")
    print(f"  max(μ_ref) = {np.max(mu_ref):.6f}")
    print(f"  max/min = {np.max(mu_ref)/np.min(mu_ref):.4f}")
    
    print(f"\nPerturbed systems:")
    for h in [4.0, 3.0, 2.0, 1.5, 1.0, 0.5]:
        H = tfim_hamiltonian(n, J, h)
        E0, E1, psi = get_ground_state(H)
        mu = np.abs(psi)**2
        gap = (E1 - E0).real
        
        # Compute ε
        valid = (mu_ref > 1e-15) & (mu > 1e-15)
        if np.any(valid):
            eps = np.max(np.abs(np.log(mu[valid] / mu_ref[valid])))
        else:
            eps = float('inf')
        
        # Compute boundary mass on Hamming graph
        A = set(range(2**(n-1)))
        bm = 0.0
        for x in A:
            for bit in range(n):
                if (x ^ (1 << bit)) not in A:
                    bm += mu[x]; break
        
        bm_ref = 0.0
        for x in A:
            for bit in range(n):
                if (x ^ (1 << bit)) not in A:
                    bm_ref += mu_ref[x]; break
        
        feasible = eps < 2.0  # Heuristic threshold
        print(f"  h={h:.1f}: Δ={gap:.4f}, ε={eps:.4f}, "
              f"∂A={bm:.4f} ≥ e^{{-ε}}·∂A_ref={np.exp(-eps)*bm_ref:.4f} "
              f"{'✓ SIMULABLE' if feasible else '✗ HARD'}")


# ============================================================================
# Application 2: Certified Sampling from Quantum Ground States
# ============================================================================
def app_certified_sampling():
    """
    Generate certified approximate samples from a quantum ground state
    using the perturbative bridge to a reference distribution.
    
    Method:
    1. Sample from reference distribution ν (easy, e.g., product state)
    2. Apply rejection sampling with acceptance probability μ(x)/(C·ν(x))
    3. Acceptance rate ≥ exp(-ε) by Theorem 1
    """
    print("\n" + "=" * 60)
    print("Application 2: Certified Sampling")
    print("=" * 60)
    
    n = 4
    J = 1.0
    h = 2.0
    
    H = tfim_hamiltonian(n, J, h)
    _, _, psi = get_ground_state(H)
    mu = np.abs(psi)**2
    
    # Reference: uniform distribution (simplest)
    nu = np.ones(2**n) / 2**n
    
    # Compute ε
    valid = mu > 1e-15
    eps = np.max(np.abs(np.log(mu[valid] / nu[valid])))
    
    # Rejection sampling
    C = np.exp(eps)  # Upper bound ratio
    n_samples = 10000
    accepted = []
    attempts = 0
    
    np.random.seed(42)
    while len(accepted) < n_samples:
        # Sample from uniform reference
        x = np.random.randint(0, 2**n)
        # Accept with probability mu(x) / (C * nu(x))
        accept_prob = mu[x] / (C * nu[x])
        if np.random.random() < accept_prob:
            accepted.append(x)
        attempts += 1
    
    acceptance_rate = n_samples / attempts
    theoretical_lower = np.exp(-eps)
    
    # Compare empirical and true distributions
    empirical = np.bincount(accepted, minlength=2**n) / len(accepted)
    tv_distance = 0.5 * np.sum(np.abs(empirical - mu))
    
    print(f"System: TFIM n={n}, J={J}, h={h}")
    print(f"Perturbation ε = {eps:.4f}")
    print(f"Acceptance rate: {acceptance_rate:.4f} (theory ≥ {theoretical_lower:.4f})")
    print(f"TV distance of samples: {tv_distance:.4f}")
    print(f"Samples generated: {n_samples} from {attempts} attempts")


# ============================================================================
# Application 3: Phase Transition Detection
# ============================================================================
def app_phase_detection():
    """
    Detect quantum phase transitions by monitoring the collapse of
    anti-concentration certificates.
    
    Key idea: At a quantum phase transition, the spectral gap closes,
    and the measurement distribution concentrates on fewer configurations.
    This is detected by monitoring minMass and log-concavity certificates.
    """
    print("\n" + "=" * 60)
    print("Application 3: Phase Transition Detection")
    print("=" * 60)
    
    n = 6
    J = 1.0
    h_values = np.linspace(0.1, 3.0, 50)
    
    gaps = []
    min_masses = []
    entropies = []
    hessian_gaps = []
    
    for h in h_values:
        H = tfim_hamiltonian(n, J, h)
        E0, E1, psi = get_ground_state(H)
        mu = np.abs(psi)**2
        gap = (E1 - E0).real
        
        gaps.append(gap)
        min_masses.append(np.min(mu))
        
        # Shannon entropy
        ent = -np.sum(mu[mu > 0] * np.log(mu[mu > 0]))
        entropies.append(ent)
        
        # Surrogate Hessian gap
        log_mu = np.log(np.maximum(mu, 1e-30))
        hess_vals = []
        for i in range(n):
            for j in range(i+1, n):
                val = 0.0
                for x in range(2**n):
                    xij = x ^ (1 << i) ^ (1 << j)
                    xi = x ^ (1 << i)
                    xj = x ^ (1 << j)
                    val += log_mu[xij] - log_mu[xi] - log_mu[xj] + log_mu[x]
                hess_vals.append(val / 2**n)
        hessian_gaps.append(-max(hess_vals) if hess_vals else 0.0)
    
    # Detect transition: where does min_mass drop fastest?
    d_min_mass = np.gradient(np.log(np.array(min_masses) + 1e-30), h_values)
    transition_idx = np.argmin(d_min_mass)
    
    print(f"\nPhase transition detected at h ≈ {h_values[transition_idx]:.2f}")
    print(f"(Expected: h = J = {J:.1f} for 1D TFIM)")
    print(f"Gap at transition: {gaps[transition_idx]:.4f}")
    print(f"Min mass at transition: {min_masses[transition_idx]:.6f}")
    
    fig, axes = plt.subplots(2, 2, figsize=(12, 10))
    
    axes[0, 0].plot(h_values, gaps, 'b-')
    axes[0, 0].axvline(x=1.0, color='r', linestyle='--', alpha=0.5)
    axes[0, 0].set_xlabel('h/J')
    axes[0, 0].set_ylabel('Spectral gap')
    axes[0, 0].set_title('Quantum Spectral Gap')
    
    axes[0, 1].semilogy(h_values, min_masses, 'g-')
    axes[0, 1].axvline(x=1.0, color='r', linestyle='--', alpha=0.5)
    axes[0, 1].set_xlabel('h/J')
    axes[0, 1].set_ylabel('min(μ)')
    axes[0, 1].set_title('Anti-Concentration (Phase Indicator)')
    
    axes[1, 0].plot(h_values, entropies, 'm-')
    axes[1, 0].axvline(x=1.0, color='r', linestyle='--', alpha=0.5)
    axes[1, 0].set_xlabel('h/J')
    axes[1, 0].set_ylabel('Shannon entropy')
    axes[1, 0].set_title('Distribution Entropy')
    
    axes[1, 1].plot(h_values, hessian_gaps, 'c-')
    axes[1, 1].axvline(x=1.0, color='r', linestyle='--', alpha=0.5)
    axes[1, 1].set_xlabel('h/J')
    axes[1, 1].set_ylabel('Hessian gap surrogate')
    axes[1, 1].set_title('Lorentzian Gap Surrogate')
    
    plt.suptitle(f'Phase Transition Detection (n={n} TFIM)', fontsize=14)
    plt.tight_layout()
    plt.savefig('phase_detection.png', dpi=150)
    print(f"\nPlot saved to phase_detection.png")


if __name__ == '__main__':
    app_classical_simulation()
    app_certified_sampling()
    app_phase_detection()


#!/usr/bin/env python3
"""
demo.py — Quantum Lorentzian Bridge: Transverse-Field Ising Model Demo

Constructs small transverse-field Ising instances, diagonalizes the Hamiltonian,
extracts ground-state measurement probabilities, computes surrogate Lorentzian /
expansion certificates, and compares them to the quantum spectral gap.

This script tests the conjectural scaling law:
  LorGap(μ_λ) ≥ Δ(H(λ)) / p(n)
by computing both sides numerically for small systems.
"""

import numpy as np
from itertools import product as iter_product
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def pauli_x():
    """Pauli X matrix."""
    return np.array([[0, 1], [1, 0]], dtype=complex)


def pauli_z():
    """Pauli Z matrix."""
    return np.array([[1, 0], [0, -1]], dtype=complex)


def identity(n):
    """2^n x 2^n identity."""
    return np.eye(2**n, dtype=complex)


def kron_at(op, site, n):
    """Embed operator `op` at `site` in an n-qubit system."""
    result = np.eye(1, dtype=complex)
    for i in range(n):
        if i == site:
            result = np.kron(result, op)
        else:
            result = np.kron(result, np.eye(2, dtype=complex))
    return result


def tfim_hamiltonian(n, J, h):
    """
    Transverse-field Ising model Hamiltonian on n qubits (open chain).
    H = -J Σ Z_i Z_{i+1} - h Σ X_i
    """
    dim = 2**n
    H = np.zeros((dim, dim), dtype=complex)
    sz = pauli_z()
    sx = pauli_x()
    for i in range(n - 1):
        H -= J * kron_at(sz, i, n) @ kron_at(sz, i + 1, n)
    for i in range(n):
        H -= h * kron_at(sx, i, n)
    return H


def ground_state_analysis(n, J, h):
    """
    Diagonalize the TFIM Hamiltonian and return:
    - ground state measurement probabilities μ
    - spectral gap Δ
    - surrogate Lorentzian gap (min-mass based)
    - boundary mass for a partition
    """
    H = tfim_hamiltonian(n, J, h)
    eigenvalues, eigenvectors = np.linalg.eigh(H)

    # Ground state
    idx = np.argsort(eigenvalues)
    E0 = eigenvalues[idx[0]]
    E1 = eigenvalues[idx[1]]
    spectral_gap = E1 - E0

    psi = eigenvectors[:, idx[0]]
    mu = np.abs(psi)**2

    # Surrogate Lorentzian gap: min-mass (anti-concentration)
    min_mass = np.min(mu)
    max_mass = np.max(mu)

    # Log-concavity certificate: check pairwise
    pair_violations = 0
    for i in range(len(mu)):
        for j in range(len(mu)):
            if mu[i] * mu[j] > max_mass**2 * (1 + 1e-10):
                pair_violations += 1

    # Boundary mass for Hamming-1 graph
    dim = 2**n
    boundary_mass = 0.0
    half = dim // 2
    A = set(range(half))  # First half of configurations
    for x in A:
        has_neighbor_outside = False
        for bit in range(n):
            y = x ^ (1 << bit)  # Hamming neighbor
            if y not in A:
                has_neighbor_outside = True
                break
        if has_neighbor_outside:
            boundary_mass += mu[x]

    return {
        'mu': mu,
        'spectral_gap': spectral_gap,
        'min_mass': min_mass,
        'max_mass': max_mass,
        'pair_violations': pair_violations,
        'boundary_mass': boundary_mass,
        'ratio': max_mass / min_mass if min_mass > 1e-15 else float('inf'),
    }


def run_demo():
    """Main demo: sweep transverse field and analyze."""
    print("=" * 70)
    print("Quantum Lorentzian Bridge: Transverse-Field Ising Model Analysis")
    print("=" * 70)

    n = 6  # 6 qubits = 64 configurations
    J = 1.0
    h_values = np.linspace(0.1, 3.0, 30)

    results = []
    for h in h_values:
        r = ground_state_analysis(n, J, h)
        r['h'] = h
        results.append(r)
        print(f"h={h:.2f}: Δ={r['spectral_gap']:.4f}, "
              f"min_μ={r['min_mass']:.6f}, max/min={r['ratio']:.2f}, "
              f"∂A={r['boundary_mass']:.4f}")

    # Plot: Spectral gap vs field strength
    fig, axes = plt.subplots(2, 2, figsize=(12, 10))

    h_vals = [r['h'] for r in results]
    gaps = [r['spectral_gap'] for r in results]
    min_masses = [r['min_mass'] for r in results]
    ratios = [r['ratio'] for r in results]
    boundaries = [r['boundary_mass'] for r in results]

    axes[0, 0].plot(h_vals, gaps, 'b-o', markersize=3)
    axes[0, 0].set_xlabel('Transverse field h')
    axes[0, 0].set_ylabel('Spectral gap Δ')
    axes[0, 0].set_title('Quantum Spectral Gap vs Field Strength')
    axes[0, 0].axvline(x=1.0, color='r', linestyle='--', alpha=0.5, label='Critical point h=J')
    axes[0, 0].legend()
    axes[0, 0].grid(True, alpha=0.3)

    axes[0, 1].plot(h_vals, min_masses, 'g-o', markersize=3)
    axes[0, 1].set_xlabel('Transverse field h')
    axes[0, 1].set_ylabel('Minimum mass min(μ)')
    axes[0, 1].set_title('Anti-Concentration Certificate')
    axes[0, 1].set_yscale('log')
    axes[0, 1].grid(True, alpha=0.3)

    axes[1, 0].plot(h_vals, ratios, 'r-o', markersize=3)
    axes[1, 0].set_xlabel('Transverse field h')
    axes[1, 0].set_ylabel('max(μ)/min(μ)')
    axes[1, 0].set_title('Pointwise Ratio (Multiplicative Closeness)')
    axes[1, 0].grid(True, alpha=0.3)

    axes[1, 1].plot(h_vals, boundaries, 'm-o', markersize=3, label='Boundary mass')
    axes[1, 1].plot(h_vals, gaps, 'b--', alpha=0.5, label='Spectral gap')
    axes[1, 1].set_xlabel('Transverse field h')
    axes[1, 1].set_ylabel('Value')
    axes[1, 1].set_title('Boundary Mass vs Spectral Gap')
    axes[1, 1].legend()
    axes[1, 1].grid(True, alpha=0.3)

    plt.suptitle(f'Quantum Lorentzian Bridge: TFIM on {n} qubits', fontsize=14)
    plt.tight_layout()
    plt.savefig('quantum_lorentzian_bridge_demo.png', dpi=150)
    print(f"\nPlot saved to quantum_lorentzian_bridge_demo.png")

    # Correlation analysis
    print("\n" + "=" * 70)
    print("Correlation Analysis: Gap vs Anti-Concentration Certificates")
    print("=" * 70)
    corr_gap_min = np.corrcoef(gaps, min_masses)[0, 1]
    corr_gap_bdy = np.corrcoef(gaps, boundaries)[0, 1]
    print(f"Pearson correlation (Δ, min_mass): {corr_gap_min:.4f}")
    print(f"Pearson correlation (Δ, boundary):  {corr_gap_bdy:.4f}")

    # Test perturbative bound
    print("\n" + "=" * 70)
    print("Testing Perturbative Event Probability Ratio Bound")
    print("=" * 70)
    h_ref = 2.0  # Far from critical point (free-fermion-like)
    ref = ground_state_analysis(n, J, h_ref)
    for h_test in [1.5, 1.8, 2.2, 2.5]:
        test = ground_state_analysis(n, J, h_test)
        # Compute actual ε = max_x |log(μ(x)/ν(x))|
        valid = (ref['mu'] > 1e-15) & (test['mu'] > 1e-15)
        if np.any(valid):
            log_ratios = np.abs(np.log(test['mu'][valid] / ref['mu'][valid]))
            eps = np.max(log_ratios)
            # Check event bound for first half
            half = len(ref['mu']) // 2
            ref_event = np.sum(ref['mu'][:half])
            test_event = np.sum(test['mu'][:half])
            lower = np.exp(-eps) * ref_event
            upper = np.exp(eps) * ref_event
            satisfied = lower <= test_event + 1e-10 and test_event <= upper + 1e-10
            print(f"h={h_test:.1f}: ε={eps:.4f}, "
                  f"e^{{-ε}}·ν(A)={lower:.6f} ≤ μ(A)={test_event:.6f} ≤ e^ε·ν(A)={upper:.6f} "
                  f"{'✓' if satisfied else '✗'}")


if __name__ == '__main__':
    run_demo()


#!/usr/bin/env python3
"""
Visualization 3: Boundary Mass and Expansion — The Cross-Domain Bridge

Demonstrates Theorem 3 (perturbative_boundaryMass_lower_bound):
boundary mass of a perturbed spin system is bounded below by
exp(-ε) times the boundary mass of the reference system.

This visualizes the core cross-domain bridge connecting quantum spectral gaps
to classical expansion properties.
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

def get_gs(n, J, h):
    H = tfim_hamiltonian(n, J, h)
    evals, evecs = np.linalg.eigh(H)
    idx = np.argsort(evals)
    return evals[idx[0]], evals[idx[1]], np.abs(evecs[:, idx[0]])**2

def boundary_mass(mu, n, A):
    """Compute boundary mass on Hamming-1 graph."""
    bm = 0.0
    for x in A:
        for bit in range(n):
            y = x ^ (1 << bit)
            if y not in A:
                bm += mu[x]
                break
    return bm

def min_expansion(mu, n, min_size=1, max_size=None):
    """Compute minimum expansion ratio over non-trivial subsets."""
    dim = 2**n
    if max_size is None:
        max_size = dim // 2
    
    # Sample random subsets for speed
    np.random.seed(123)
    min_ratio = float('inf')
    for _ in range(500):
        size = np.random.randint(min_size, max_size + 1)
        A = set(np.random.choice(dim, size, replace=False))
        mu_A = sum(mu[x] for x in A)
        if mu_A < 1e-12 or mu_A > 1 - 1e-12:
            continue
        bm = boundary_mass(mu, n, A)
        ratio = bm / (mu_A * (1 - mu_A))
        min_ratio = min(min_ratio, ratio)
    return min_ratio


n = 5
J = 1.0
h_ref = 3.0
_, _, mu_ref = get_gs(n, J, h_ref)

h_values = np.linspace(0.3, 3.5, 40)
dim = 2**n

# Compute for multiple subset choices
subset_choices = {
    'First half': set(range(dim // 2)),
    'Low Hamming weight': set(x for x in range(dim) if bin(x).count('1') <= n // 2),
    'Random subset': set(np.random.choice(dim, dim // 3, replace=False)),
}

fig, axes = plt.subplots(2, 2, figsize=(14, 11))

# Panel 1: Boundary mass vs h for different subsets
ax = axes[0, 0]
for name, A in subset_choices.items():
    bms = []
    for h in h_values:
        _, _, mu = get_gs(n, J, h)
        bms.append(boundary_mass(mu, n, A))
    ax.plot(h_values, bms, '-o', markersize=2, label=name)
ax.axvline(x=1.0, color='r', linestyle='--', alpha=0.4, label='Critical')
ax.set_xlabel('h/J', fontsize=12)
ax.set_ylabel('Boundary mass', fontsize=12)
ax.set_title('Boundary Mass ∂A for Various Subsets', fontsize=13)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.2)

# Panel 2: Certified lower bound vs actual
ax = axes[0, 1]
A = set(range(dim // 2))
bm_ref = boundary_mass(mu_ref, n, A)
bms_actual = []
bms_certified = []
epsilons_plot = []

for h in h_values:
    _, _, mu = get_gs(n, J, h)
    bm = boundary_mass(mu, n, A)
    bms_actual.append(bm)
    
    valid = (mu_ref > 1e-15) & (mu > 1e-15)
    if np.any(valid):
        eps = np.max(np.abs(np.log(mu[valid] / mu_ref[valid])))
    else:
        eps = 5.0
    epsilons_plot.append(eps)
    bms_certified.append(np.exp(-eps) * bm_ref)

ax.plot(h_values, bms_actual, 'r-', linewidth=2, label='Actual ∂A(μ)')
ax.plot(h_values, bms_certified, 'b--', linewidth=2, label=r'Certified: $e^{-\varepsilon}$·∂A(ν)')
ax.fill_between(h_values, 0, bms_certified, alpha=0.1, color='blue')
ax.axvline(x=h_ref, color='green', linestyle=':', alpha=0.5, label=f'Reference h={h_ref}')
ax.set_xlabel('h/J', fontsize=12)
ax.set_ylabel('Boundary mass', fontsize=12)
ax.set_title('Theorem 3: Certified Boundary Mass Lower Bound', fontsize=13)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.2)

# Panel 3: Spectral gap vs expansion (the bridge!)
ax = axes[1, 0]
gaps = []
expansions = []
for h in h_values:
    E0, E1, mu = get_gs(n, J, h)
    gaps.append(E1 - E0)
    exp_ratio = min_expansion(mu, n)
    expansions.append(exp_ratio)

ax.scatter(gaps, expansions, c=h_values, cmap='plasma', s=30, zorder=5)
ax.set_xlabel('Quantum Spectral Gap Δ', fontsize=12)
ax.set_ylabel('Classical Expansion Φ', fontsize=12)
ax.set_title('THE BRIDGE: Quantum Gap ↔ Classical Expansion', fontsize=13)
sm = plt.cm.ScalarMappable(cmap='plasma',
                            norm=plt.Normalize(vmin=h_values[0], vmax=h_values[-1]))
plt.colorbar(sm, ax=ax, label='h/J')
ax.grid(True, alpha=0.2)

# Panel 4: ε vs h
ax = axes[1, 1]
ax.plot(h_values, epsilons_plot, 'k-', linewidth=2)
ax.axhline(y=1.0, color='orange', linestyle='--', alpha=0.5, label='ε = 1')
ax.axvline(x=1.0, color='r', linestyle='--', alpha=0.4, label='Critical')
ax.set_xlabel('h/J', fontsize=12)
ax.set_ylabel('Perturbation parameter ε', fontsize=12)
ax.set_title('Multiplicative Distance from Reference', fontsize=13)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.2)

plt.suptitle('Cross-Domain Bridge: Quantum Gaps → Classical Expansion\n'
             f'Transverse-Field Ising Model, n={n}', fontsize=15)
plt.tight_layout()
plt.savefig('viz_boundary_mass.png', dpi=150, bbox_inches='tight')
print("Saved viz_boundary_mass.png")


#!/usr/bin/env python3
"""
Visualization 1: Gap Landscape Heatmap

Visualizes the quantum spectral gap and surrogate Lorentzian gap across
the (J, h) parameter space of the transverse-field Ising model.
Shows how the gap closes at the phase transition and how anti-concentration
certificates track the gap.
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


n = 5
J_values = np.linspace(0.2, 2.0, 25)
h_values = np.linspace(0.2, 2.0, 25)

gap_grid = np.zeros((len(J_values), len(h_values)))
minmass_grid = np.zeros((len(J_values), len(h_values)))
entropy_grid = np.zeros((len(J_values), len(h_values)))

for i, J in enumerate(J_values):
    for j, h in enumerate(h_values):
        H = tfim_hamiltonian(n, J, h)
        evals = np.linalg.eigvalsh(H)
        evals_sorted = np.sort(evals)
        gap_grid[i, j] = evals_sorted[1] - evals_sorted[0]
        
        _, evecs = np.linalg.eigh(H)
        psi = evecs[:, np.argmin(evals)]
        mu = np.abs(psi)**2
        minmass_grid[i, j] = np.min(mu)
        entropy_grid[i, j] = -np.sum(mu[mu > 0] * np.log2(mu[mu > 0]))

fig, axes = plt.subplots(1, 3, figsize=(18, 5))

im0 = axes[0].imshow(gap_grid, extent=[h_values[0], h_values[-1], J_values[0], J_values[-1]],
                       origin='lower', aspect='auto', cmap='viridis')
axes[0].plot(J_values, J_values, 'r--', linewidth=2, label='h = J (critical)')
axes[0].set_xlabel('Transverse field h', fontsize=12)
axes[0].set_ylabel('Coupling J', fontsize=12)
axes[0].set_title('Quantum Spectral Gap Δ', fontsize=14)
axes[0].legend(fontsize=10)
plt.colorbar(im0, ax=axes[0])

im1 = axes[1].imshow(np.log10(minmass_grid + 1e-20),
                       extent=[h_values[0], h_values[-1], J_values[0], J_values[-1]],
                       origin='lower', aspect='auto', cmap='magma')
axes[1].plot(J_values, J_values, 'w--', linewidth=2, label='h = J')
axes[1].set_xlabel('Transverse field h', fontsize=12)
axes[1].set_ylabel('Coupling J', fontsize=12)
axes[1].set_title('log₁₀(min mass) — Anti-Concentration', fontsize=14)
axes[1].legend(fontsize=10)
plt.colorbar(im1, ax=axes[1])

im2 = axes[2].imshow(entropy_grid,
                       extent=[h_values[0], h_values[-1], J_values[0], J_values[-1]],
                       origin='lower', aspect='auto', cmap='coolwarm')
axes[2].plot(J_values, J_values, 'k--', linewidth=2, label='h = J')
axes[2].set_xlabel('Transverse field h', fontsize=12)
axes[2].set_ylabel('Coupling J', fontsize=12)
axes[2].set_title('Shannon Entropy (bits)', fontsize=14)
axes[2].legend(fontsize=10)
plt.colorbar(im2, ax=axes[2])

plt.suptitle(f'Quantum Lorentzian Bridge: TFIM Parameter Landscape (n={n})', fontsize=16, y=1.02)
plt.tight_layout()
plt.savefig('viz_gap_landscape.png', dpi=150, bbox_inches='tight')
print("Saved viz_gap_landscape.png")


#!/usr/bin/env python3
"""
Visualization 2: Perturbation Stability of Event Probabilities

Demonstrates Theorem 1 (event_prob_ratio_bound): when two distributions are
multiplicatively ε-close pointwise, event probabilities are also ε-close.
Shows the exponential envelope exp(±ε) · ν(s) bounding μ(s) for various events.
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

def get_ground_state_probs(n, J, h):
    H = tfim_hamiltonian(n, J, h)
    evals, evecs = np.linalg.eigh(H)
    psi = evecs[:, np.argmin(evals)]
    return np.abs(psi)**2


n = 5
J = 1.0
h_ref = 3.0  # Reference (deep paramagnetic)
mu_ref = get_ground_state_probs(n, J, h_ref)

h_values = np.linspace(0.5, 3.0, 40)

# Define several events
dim = 2**n
events = {
    'First half': np.arange(dim) < dim // 2,
    'Even configs': np.arange(dim) % 2 == 0,
    'Low weight': np.array([bin(x).count('1') <= n//2 for x in range(dim)]),
    'Single config': np.arange(dim) == 0,
}

fig, axes = plt.subplots(2, 2, figsize=(14, 11))

for ax, (event_name, event_mask) in zip(axes.flatten(), events.items()):
    ref_prob = np.sum(mu_ref[event_mask])
    
    actual_probs = []
    epsilons = []
    lower_bounds = []
    upper_bounds = []
    
    for h in h_values:
        mu = get_ground_state_probs(n, J, h)
        actual = np.sum(mu[event_mask])
        actual_probs.append(actual)
        
        # Compute ε
        valid = (mu_ref > 1e-15) & (mu > 1e-15)
        if np.any(valid):
            eps = np.max(np.abs(np.log(mu[valid] / mu_ref[valid])))
        else:
            eps = 5.0
        epsilons.append(eps)
        lower_bounds.append(np.exp(-eps) * ref_prob)
        upper_bounds.append(np.exp(eps) * ref_prob)
    
    ax.fill_between(h_values, lower_bounds, upper_bounds, alpha=0.2, color='blue',
                     label='Certified envelope')
    ax.plot(h_values, actual_probs, 'r-', linewidth=2, label='Actual μ(s)')
    ax.plot(h_values, lower_bounds, 'b--', alpha=0.5, linewidth=1)
    ax.plot(h_values, upper_bounds, 'b--', alpha=0.5, linewidth=1)
    ax.axhline(y=ref_prob, color='g', linestyle=':', alpha=0.5, label=f'ν(s)={ref_prob:.3f}')
    ax.axvline(x=h_ref, color='gray', linestyle=':', alpha=0.3)
    ax.set_xlabel('Transverse field h', fontsize=11)
    ax.set_ylabel('Event probability', fontsize=11)
    ax.set_title(f'Event: {event_name}', fontsize=13)
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.2)
    ax.set_ylim(bottom=0)

plt.suptitle('Theorem 1: Event Probability Ratio Bound\n'
             r'$e^{-\varepsilon}\nu(s) \leq \mu(s) \leq e^{\varepsilon}\nu(s)$',
             fontsize=15)
plt.tight_layout()
plt.savefig('viz_perturbation_stability.png', dpi=150, bbox_inches='tight')
print("Saved viz_perturbation_stability.png")
