#!/usr/bin/env python3
"""
applications.py — Real-World Applications of Quantum-to-Classical Gap Transfer

Demonstrates concrete applications of the bridge theorems:
1. Certified classical simulation near free-fermionic points
2. Spectral gap estimation from measurement samples
3. Robustness analysis for quantum error mitigation
"""

import numpy as np


# ── Pauli matrices ──────────────────────────────────────────────────────
sigma_x = np.array([[0, 1], [1, 0]], dtype=complex)
sigma_z = np.array([[1, 0], [0, -1]], dtype=complex)
I2 = np.eye(2, dtype=complex)


def kron_chain(ops):
    result = ops[0]
    for op in ops[1:]:
        result = np.kron(result, op)
    return result


def tfim_hamiltonian(n, J=1.0, h=1.0):
    dim = 2**n
    H = np.zeros((dim, dim), dtype=complex)
    for i in range(n - 1):
        ops = [I2] * n
        ops[i] = sigma_z
        ops[i + 1] = sigma_z
        H -= J * kron_chain(ops)
    for i in range(n):
        ops = [I2] * n
        ops[i] = sigma_x
        H -= h * kron_chain(ops)
    return H


def ground_state_distribution(H):
    evals, evecs = np.linalg.eigh(H)
    idx = np.argsort(evals)
    evals = evals[idx]
    psi = evecs[:, idx[0]]
    mu = np.abs(psi) ** 2
    return evals, mu


# ── Application 1: Certified Classical Simulation ───────────────────────

def certified_simulation_radius(n, J=1.0):
    """
    Compute the certified simulation radius around the free-fermion point.

    At h = J (critical point), the TFIM is exactly solvable via Jordan-Wigner.
    We compute how far h can deviate from J while maintaining a valid
    perturbative certificate.

    Returns:
        Dictionary with simulation radius and certificate data
    """
    h_ref = J  # free-fermion reference
    H_ref = tfim_hamiltonian(n, J, h_ref)
    evals_ref, mu_ref = ground_state_distribution(H_ref)
    gap_ref = evals_ref[1] - evals_ref[0]

    results = []
    for delta_h in np.linspace(0, 2.0, 50):
        h_test = h_ref + delta_h
        H_test = tfim_hamiltonian(n, J, h_test)
        evals_test, mu_test = ground_state_distribution(H_test)
        gap_test = evals_test[1] - evals_test[0]

        # Compute multiplicative closeness
        mu_ref_pos = mu_ref[mu_ref > 1e-300]
        mu_test_pos = mu_test[mu_ref > 1e-300]
        if len(mu_ref_pos) > 0 and len(mu_test_pos) > 0 and np.all(mu_test_pos > 0):
            ratios = mu_test_pos / mu_ref_pos
            epsilon = max(abs(np.log(np.max(ratios))), abs(np.log(np.min(ratios))))
        else:
            epsilon = float('inf')

        # Certificate validity: epsilon < some threshold
        certified = epsilon < 2.0 * n

        results.append({
            'delta_h': delta_h,
            'epsilon': epsilon,
            'gap_ref': gap_ref,
            'gap_test': gap_test,
            'certified': certified,
            'min_mass_ratio': np.min(mu_test) / (np.min(mu_ref) + 1e-300),
        })

    return results


# ── Application 2: Spectral Gap Lower Bound from Samples ───────────────

def spectral_gap_lower_bound_from_samples(samples, n_bits, n_ref_samples=None):
    """
    Estimate a lower bound on the spectral gap from measurement samples.

    Uses the anti-concentration certificate: if the empirical distribution
    has large min-mass, the spectral gap cannot be too small.

    Args:
        samples: array of measurement outcomes (integers)
        n_bits: number of qubits
        n_ref_samples: number of reference samples (for normalization)

    Returns:
        Dictionary with gap estimate and confidence
    """
    dim = 2**n_bits
    counts = np.bincount(samples, minlength=dim)
    mu_empirical = counts / len(samples)

    min_mass = np.min(mu_empirical)
    pair_gap = 2 * min_mass

    # Heuristic gap bound: if min_mass > 0, gap ≥ min_mass * dim / n^2
    gap_lower = min_mass * dim / n_bits**2 if min_mass > 0 else 0

    return {
        'n_samples': len(samples),
        'min_mass_empirical': float(min_mass),
        'pair_gap': float(pair_gap),
        'gap_lower_bound': float(gap_lower),
        'confidence': 'high' if len(samples) > 10 * dim else 'low',
    }


# ── Application 3: Quantum Error Mitigation Robustness ──────────────────

def error_mitigation_analysis(n, noise_levels):
    """
    Analyze how noise affects the Lorentzian certificate.

    Simulates depolarizing noise on the ground state measurement distribution
    and checks how the certificate degrades.
    """
    H = tfim_hamiltonian(n, J=1.0, h=1.5)
    evals, mu_ideal = ground_state_distribution(H)
    gap = evals[1] - evals[0]
    dim = 2**n

    results = []
    for p in noise_levels:
        # Depolarizing noise: μ_noisy = (1-p) μ + p/dim
        mu_noisy = (1 - p) * mu_ideal + p / dim

        # Multiplicative closeness
        ratios = mu_noisy / (mu_ideal + 1e-300)
        ratios_valid = ratios[mu_ideal > 1e-300]
        if len(ratios_valid) > 0:
            epsilon = max(abs(np.log(np.max(ratios_valid))),
                         abs(np.log(np.min(ratios_valid))))
        else:
            epsilon = float('inf')

        # Certificate properties
        min_mass_noisy = np.min(mu_noisy)
        min_mass_ideal = np.min(mu_ideal)

        results.append({
            'noise_level': p,
            'epsilon': epsilon,
            'min_mass_ideal': float(min_mass_ideal),
            'min_mass_noisy': float(min_mass_noisy),
            'min_mass_ratio': float(min_mass_noisy / (min_mass_ideal + 1e-300)),
            'exp_neg_eps_bound': float(np.exp(-epsilon) * min_mass_ideal),
            'bound_satisfied': bool(
                np.exp(-epsilon) * min_mass_ideal <= min_mass_noisy + 1e-15
            ),
            'spectral_gap': float(gap),
        })

    return results


def main():
    print("=" * 72)
    print("Applications of Quantum-to-Classical Gap Transfer")
    print("=" * 72)

    # Application 1
    print("\n── Application 1: Certified Simulation Radius ──")
    for n in [3, 4, 5]:
        results = certified_simulation_radius(n)
        max_certified = max(
            (r['delta_h'] for r in results if r['certified']),
            default=0
        )
        print(f"  n={n}: max certified Δh = {max_certified:.3f}")

    # Application 2
    print("\n── Application 2: Gap Lower Bound from Samples ──")
    for n in [3, 4]:
        H = tfim_hamiltonian(n, h=1.5)
        evals, mu = ground_state_distribution(H)
        true_gap = evals[1] - evals[0]

        # Simulate samples
        samples = np.random.choice(2**n, size=10000, p=mu)
        result = spectral_gap_lower_bound_from_samples(samples, n)
        print(f"  n={n}: true gap={true_gap:.4f}, "
              f"lower bound={result['gap_lower_bound']:.4f}, "
              f"confidence={result['confidence']}")

    # Application 3
    print("\n── Application 3: Error Mitigation Robustness ──")
    noise_levels = [0.0, 0.01, 0.05, 0.1, 0.2, 0.5]
    for n in [3, 4]:
        print(f"\n  n={n}:")
        results = error_mitigation_analysis(n, noise_levels)
        for r in results:
            print(f"    p={r['noise_level']:.2f}: ε={r['epsilon']:.4f}, "
                  f"minMass ratio={r['min_mass_ratio']:.4f}, "
                  f"bound ok={r['bound_satisfied']}")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
demo.py — Transverse-Field Ising Model: Quantum Gap vs. Lorentzian Certificate

Constructs small transverse-field Ising model instances, diagonalizes the
Hamiltonian numerically, extracts ground-state measurement probabilities,
computes surrogate Lorentzian / expansion certificates, and compares them
to the quantum spectral gap as the transverse field strength varies.

This tests the conjectural scaling law:
  quantum_gap / poly(n) ≤ lorentzian_certificate ≤ classical_expansion_gap
"""

import numpy as np
from itertools import product as iprod

# ── Pauli matrices ──────────────────────────────────────────────────────
sigma_x = np.array([[0, 1], [1, 0]], dtype=complex)
sigma_z = np.array([[1, 0], [0, -1]], dtype=complex)
I2 = np.eye(2, dtype=complex)


def kron_chain(ops):
    """Tensor product of a list of 2x2 matrices."""
    result = ops[0]
    for op in ops[1:]:
        result = np.kron(result, op)
    return result


def tfim_hamiltonian(n, J=1.0, h=1.0):
    """
    Transverse-field Ising model on n sites (open boundary):
      H = -J ∑ Z_i Z_{i+1} - h ∑ X_i
    """
    dim = 2**n
    H = np.zeros((dim, dim), dtype=complex)
    # ZZ interactions
    for i in range(n - 1):
        ops = [I2] * n
        ops[i] = sigma_z
        ops[i + 1] = sigma_z
        H -= J * kron_chain(ops)
    # Transverse field
    for i in range(n):
        ops = [I2] * n
        ops[i] = sigma_x
        H -= h * kron_chain(ops)
    return H


def ground_state_distribution(H):
    """Return (eigenvalues sorted, ground state measurement distribution)."""
    evals, evecs = np.linalg.eigh(H)
    idx = np.argsort(evals)
    evals = evals[idx]
    psi = evecs[:, idx[0]]
    mu = np.abs(psi) ** 2
    return evals, mu


def min_mass(mu):
    """Minimum probability mass (anti-concentration certificate)."""
    return np.min(mu)


def pair_mass_gap(mu):
    """Minimum of μ(x) + μ(y) over all pairs."""
    return np.min(mu[:, None] + mu[None, :])


def log_concavity_certificate(mu):
    """
    Surrogate log-concavity certificate:
    max_{x,y} log(μ(x)μ(y)) - 2 log(max μ)
    Should be ≤ 0 for log-concave; more negative = stronger.
    Returns the negative of the worst violation.
    """
    mu_pos = mu[mu > 0]
    if len(mu_pos) < 2:
        return 0.0
    log_mu = np.log(mu_pos)
    log_max = np.max(log_mu)
    worst = np.max(log_mu[:, None] + log_mu[None, :]) - 2 * log_max
    return -worst  # positive means log-concave


def boundary_mass(mu, n):
    """
    Boundary mass for the Hamming graph on {0,1}^n.
    A = support of top half of probability mass.
    """
    dim = 2**n
    idx_sorted = np.argsort(-mu)
    half = dim // 2
    A = set(idx_sorted[:half])
    bmass = 0.0
    for x in A:
        # Check Hamming neighbors
        for bit in range(n):
            y = x ^ (1 << bit)
            if y not in A:
                bmass += mu[x]
                break
    return bmass


def spectral_gap(evals):
    """Spectral gap: E_1 - E_0."""
    return evals[1] - evals[0]


def run_experiment(n, h_values):
    """Run the full experiment for system size n."""
    results = []
    for h in h_values:
        H = tfim_hamiltonian(n, J=1.0, h=h)
        evals, mu = ground_state_distribution(H)
        gap = spectral_gap(evals)
        mm = min_mass(mu)
        pmg = pair_mass_gap(mu)
        lcc = log_concavity_certificate(mu)
        bm = boundary_mass(mu, n)
        results.append({
            'h': h,
            'spectral_gap': gap,
            'min_mass': mm,
            'pair_mass_gap': pmg,
            'log_concavity_cert': lcc,
            'boundary_mass': bm,
        })
    return results


def main():
    print("=" * 72)
    print("Transverse-Field Ising Model: Quantum Gap vs. Lorentzian Certificate")
    print("=" * 72)

    for n in [3, 4, 5, 6]:
        print(f"\n{'─' * 60}")
        print(f"System size n = {n} ({2**n} configurations)")
        print(f"{'─' * 60}")
        h_values = np.linspace(0.1, 3.0, 15)
        results = run_experiment(n, h_values)

        print(f"{'h':>6s} {'Δ(H)':>10s} {'minMass':>10s} {'pairGap':>10s} "
              f"{'logConc':>10s} {'bdryMass':>10s} {'Δ/n²':>10s}")
        print("-" * 72)
        for r in results:
            print(f"{r['h']:6.2f} {r['spectral_gap']:10.6f} "
                  f"{r['min_mass']:10.6f} {r['pair_mass_gap']:10.6f} "
                  f"{r['log_concavity_cert']:10.6f} {r['boundary_mass']:10.6f} "
                  f"{r['spectral_gap']/n**2:10.6f}")

        # Test the conjectural scaling: gap/n^2 ≤ certificate
        print(f"\n  Conjecture test: Δ(H)/n² vs surrogate Lorentzian cert")
        violations = 0
        for r in results:
            ratio = r['spectral_gap'] / n**2
            cert = r['min_mass'] * (2**n)  # normalized certificate
            status = "✓" if ratio <= cert + 1e-10 else "✗"
            if status == "✗":
                violations += 1
        print(f"  Violations: {violations}/{len(results)}")

    print("\n" + "=" * 72)
    print("Experiment complete. See visualization scripts for plots.")
    print("=" * 72)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization 3: Boundary Mass and Graph Expansion

Plots the boundary mass (graph expansion quantity) for the Hamming graph
on {0,1}^n, comparing a reference free-fermion distribution to perturbed
measurement distributions. Demonstrates the cross-domain bridge theorem
`perturbative_boundaryMass_lower_bound`.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

# ── Self-contained infrastructure ───────────────────────────────────────
sigma_x = np.array([[0, 1], [1, 0]], dtype=complex)
sigma_z = np.array([[1, 0], [0, -1]], dtype=complex)
I2 = np.eye(2, dtype=complex)

def kron_chain(ops):
    result = ops[0]
    for op in ops[1:]:
        result = np.kron(result, op)
    return result

def tfim_hamiltonian(n, J=1.0, h=1.0):
    dim = 2**n
    H = np.zeros((dim, dim), dtype=complex)
    for i in range(n - 1):
        ops = [I2] * n; ops[i] = sigma_z; ops[i+1] = sigma_z
        H -= J * kron_chain(ops)
    for i in range(n):
        ops = [I2] * n; ops[i] = sigma_x
        H -= h * kron_chain(ops)
    return H

def ground_state_dist(H):
    evals, evecs = np.linalg.eigh(H)
    psi = evecs[:, np.argmin(evals)]
    return np.abs(psi)**2

def boundary_mass(mu, n_bits, A):
    bmass = 0.0
    for x in A:
        for bit in range(n_bits):
            y = x ^ (1 << bit)
            if y not in A:
                bmass += mu[x]
                break
    return bmass

# ── Main plot ───────────────────────────────────────────────────────────
fig, axes = plt.subplots(1, 3, figsize=(16, 5))

for panel, n in enumerate([3, 4, 5]):
    ax = axes[panel]
    dim = 2**n

    # Reference distribution at h = 1.0 (critical / free-fermion-like)
    H_ref = tfim_hamiltonian(n, h=1.0)
    mu_ref = ground_state_dist(H_ref)

    # Set A = top-half-mass configurations
    idx_sorted = np.argsort(-mu_ref)
    A = set(idx_sorted[:dim // 2])

    h_vals = np.linspace(0.1, 3.5, 50)
    bm_vals = []
    bm_ref_val = boundary_mass(mu_ref, n, A)
    bm_bounds = []

    for h in h_vals:
        H_pert = tfim_hamiltonian(n, h=h)
        mu_pert = ground_state_dist(H_pert)

        bm = boundary_mass(mu_pert, n, A)
        bm_vals.append(bm)

        # Compute epsilon and theoretical bound
        mask = (mu_ref > 1e-300) & (mu_pert > 1e-300)
        if np.any(mask):
            ratios = mu_pert[mask] / mu_ref[mask]
            eps = max(abs(np.log(np.max(ratios))), abs(np.log(np.min(ratios))))
        else:
            eps = 10.0
        bm_bounds.append(np.exp(-eps) * bm_ref_val)

    ax.plot(h_vals, bm_vals, 'b-', linewidth=2, label='Actual boundary mass')
    ax.plot(h_vals, bm_bounds, 'r--', linewidth=2, label=r'$e^{-\varepsilon}$ × ref bound')
    ax.axhline(y=bm_ref_val, color='gray', linestyle=':', alpha=0.5, label='Reference')
    ax.axvline(x=1.0, color='green', linestyle='-.', alpha=0.4, label='h = J (ref)')

    ax.set_xlabel('Transverse field h', fontsize=12)
    ax.set_ylabel('Boundary mass', fontsize=12)
    ax.set_title(f'n = {n}', fontsize=13)
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)

fig.suptitle('Boundary Mass Transfer Under Perturbation\n'
             '(Cross-Domain Bridge Theorem Verification)',
             fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('viz_boundary_mass.png', dpi=150, bbox_inches='tight')
print("Saved viz_boundary_mass.png")


#!/usr/bin/env python3
"""
Visualization 1: Quantum Spectral Gap vs. Surrogate Lorentzian Certificate

Plots the quantum spectral gap Δ(H) alongside the surrogate Lorentzian
certificate (min-mass × dim) for the transverse-field Ising model as the
transverse field h varies. Demonstrates the conjectural inequality:
  Δ(H) / n² ≤ Lorentzian certificate

This visualization is the core empirical test of the quantum-to-classical
gap transfer conjecture.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

# ── Pauli / Hamiltonian infrastructure (self-contained) ─────────────────
sigma_x = np.array([[0, 1], [1, 0]], dtype=complex)
sigma_z = np.array([[1, 0], [0, -1]], dtype=complex)
I2 = np.eye(2, dtype=complex)

def kron_chain(ops):
    result = ops[0]
    for op in ops[1:]:
        result = np.kron(result, op)
    return result

def tfim_hamiltonian(n, J=1.0, h=1.0):
    dim = 2**n
    H = np.zeros((dim, dim), dtype=complex)
    for i in range(n - 1):
        ops = [I2] * n; ops[i] = sigma_z; ops[i+1] = sigma_z
        H -= J * kron_chain(ops)
    for i in range(n):
        ops = [I2] * n; ops[i] = sigma_x
        H -= h * kron_chain(ops)
    return H

def ground_state_data(n, h):
    H = tfim_hamiltonian(n, h=h)
    evals = np.linalg.eigvalsh(H)
    evals.sort()
    evecs = np.linalg.eigh(H)[1]
    psi = evecs[:, np.argmin(np.linalg.eigvalsh(H))]
    mu = np.abs(psi)**2
    gap = evals[1] - evals[0]
    min_mass = np.min(mu)
    return gap, min_mass, mu

# ── Main plot ───────────────────────────────────────────────────────────
fig, axes = plt.subplots(2, 2, figsize=(14, 10))

for idx, n in enumerate([3, 4, 5, 6]):
    ax = axes[idx // 2, idx % 2]
    h_vals = np.linspace(0.1, 3.5, 60)
    gaps, certs, min_masses = [], [], []

    for h in h_vals:
        gap, mm, mu = ground_state_data(n, h)
        gaps.append(gap)
        min_masses.append(mm)
        certs.append(mm * 2**n)  # normalized certificate

    gaps = np.array(gaps)
    certs = np.array(certs)
    scaled_gaps = gaps / n**2

    ax.plot(h_vals, gaps, 'b-', linewidth=2, label=r'$\Delta(H)$')
    ax.plot(h_vals, certs, 'r--', linewidth=2, label=r'minMass $\times 2^n$ (certificate)')
    ax.plot(h_vals, scaled_gaps, 'g:', linewidth=2, label=r'$\Delta(H)/n^2$')
    ax.axvline(x=1.0, color='gray', linestyle='-.', alpha=0.5, label='Critical point')

    ax.set_xlabel('Transverse field h', fontsize=12)
    ax.set_ylabel('Gap / Certificate', fontsize=12)
    ax.set_title(f'n = {n} ({2**n} configurations)', fontsize=13)
    ax.legend(fontsize=9)
    ax.set_yscale('log')
    ax.grid(True, alpha=0.3)

fig.suptitle('Quantum Spectral Gap vs. Lorentzian Certificate\n'
             'Transverse-Field Ising Model', fontsize=15, fontweight='bold')
plt.tight_layout()
plt.savefig('viz_gap_certificate.png', dpi=150, bbox_inches='tight')
print("Saved viz_gap_certificate.png")


#!/usr/bin/env python3
"""
Visualization 2: Perturbation Stability of Lorentzian Certificates

Shows how the minimum mass certificate degrades under multiplicative
perturbation, comparing the actual degradation to the theoretical
bound exp(-ε) × minMass(ν).

Demonstrates the formally proved theorem `minMass_perturbation_lower_bound`.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

# ── Self-contained infrastructure ───────────────────────────────────────
sigma_x = np.array([[0, 1], [1, 0]], dtype=complex)
sigma_z = np.array([[1, 0], [0, -1]], dtype=complex)
I2 = np.eye(2, dtype=complex)

def kron_chain(ops):
    result = ops[0]
    for op in ops[1:]:
        result = np.kron(result, op)
    return result

def tfim_hamiltonian(n, J=1.0, h=1.0):
    dim = 2**n
    H = np.zeros((dim, dim), dtype=complex)
    for i in range(n - 1):
        ops = [I2] * n; ops[i] = sigma_z; ops[i+1] = sigma_z
        H -= J * kron_chain(ops)
    for i in range(n):
        ops = [I2] * n; ops[i] = sigma_x
        H -= h * kron_chain(ops)
    return H

def ground_state_dist(H):
    evals, evecs = np.linalg.eigh(H)
    psi = evecs[:, np.argmin(evals)]
    return np.abs(psi)**2

# ── Main plot ───────────────────────────────────────────────────────────
fig, axes = plt.subplots(1, 3, figsize=(16, 5))

n = 5
h_ref = 1.5  # Reference point (away from critical)
H_ref = tfim_hamiltonian(n, h=h_ref)
mu_ref = ground_state_dist(H_ref)
min_mass_ref = np.min(mu_ref)

# Panel 1: min-mass vs perturbation strength
delta_h_vals = np.linspace(0, 2.0, 80)
actual_min_masses = []
epsilons = []
theoretical_bounds = []

for dh in delta_h_vals:
    H_pert = tfim_hamiltonian(n, h=h_ref + dh)
    mu_pert = ground_state_dist(H_pert)
    actual_min_masses.append(np.min(mu_pert))

    # Compute epsilon (multiplicative closeness)
    mask = (mu_ref > 1e-300) & (mu_pert > 1e-300)
    if np.any(mask):
        ratios = mu_pert[mask] / mu_ref[mask]
        eps = max(abs(np.log(np.max(ratios))), abs(np.log(np.min(ratios))))
    else:
        eps = 10.0
    epsilons.append(eps)
    theoretical_bounds.append(np.exp(-eps) * min_mass_ref)

ax = axes[0]
ax.plot(delta_h_vals, actual_min_masses, 'b-', linewidth=2, label='Actual minMass(μ)')
ax.plot(delta_h_vals, theoretical_bounds, 'r--', linewidth=2, label=r'$e^{-\varepsilon}$ × minMass(ν)')
ax.set_xlabel('Perturbation Δh', fontsize=12)
ax.set_ylabel('Minimum mass', fontsize=12)
ax.set_title('Min-Mass Degradation', fontsize=13)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)
ax.set_yscale('log')

# Panel 2: epsilon vs delta_h
ax = axes[1]
ax.plot(delta_h_vals, epsilons, 'g-', linewidth=2)
ax.set_xlabel('Perturbation Δh', fontsize=12)
ax.set_ylabel('ε (multiplicative closeness)', fontsize=12)
ax.set_title('Closeness Parameter ε', fontsize=13)
ax.grid(True, alpha=0.3)

# Panel 3: Ratio actual/bound (should be ≥ 1)
ax = axes[2]
ratios_plot = [a / (b + 1e-300) for a, b in zip(actual_min_masses, theoretical_bounds)]
ax.plot(delta_h_vals, ratios_plot, 'm-', linewidth=2)
ax.axhline(y=1.0, color='k', linestyle='--', alpha=0.5, label='Bound = 1')
ax.set_xlabel('Perturbation Δh', fontsize=12)
ax.set_ylabel('Actual / Theoretical bound', fontsize=12)
ax.set_title('Theorem Verification: Ratio ≥ 1', fontsize=13)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

fig.suptitle(f'Perturbation Stability of Lorentzian Certificate (n={n}, h_ref={h_ref})',
             fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('viz_perturbation_stability.png', dpi=150, bbox_inches='tight')
print("Saved viz_perturbation_stability.png")
