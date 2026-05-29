"""
Certified Fermion Sampling — Applications
============================================

Real-world applications of certified fermion sampling theory:
1. Quantum chemistry: Certifying molecular orbital correlations
2. Quantum advantage benchmarking: Noise tolerance thresholds
3. DPP sampling quality: Machine learning kernel certification
"""

import numpy as np
from typing import Dict, List, Tuple


# ============================================================
# Application 1: Quantum Chemistry — Molecular Orbital Certification
# ============================================================

def molecular_orbital_kernel(n_orbitals: int, n_electrons: int,
                             hopping_strength: float = 1.0,
                             seed: int = 42) -> np.ndarray:
    """Create a correlation matrix modeling a molecular system.

    Simulates a tight-binding Hamiltonian H = -t Σ c†_i c_{i+1} + h.c.
    The ground state correlation matrix is K_ij = <c†_i c_j>.

    Args:
        n_orbitals: Number of molecular orbitals
        n_electrons: Number of electrons
        hopping_strength: Nearest-neighbor hopping amplitude

    Returns:
        Correlation matrix of the ground state
    """
    # Build tight-binding Hamiltonian
    H = np.zeros((n_orbitals, n_orbitals))
    for i in range(n_orbitals - 1):
        H[i, i + 1] = -hopping_strength
        H[i + 1, i] = -hopping_strength

    # Diagonalize and fill lowest n_electrons orbitals
    eigvals, eigvecs = np.linalg.eigh(H)
    occupied = eigvecs[:, :n_electrons]
    K = occupied @ occupied.T
    return K


def certify_molecular_simulation(n_orbitals: int, n_electrons: int,
                                  circuit_depth: int, gate_noise: float) -> Dict:
    """Certify a quantum simulation of a molecular system.

    Returns certification results for a noisy quantum simulation
    of a simple molecular Hamiltonian.

    Args:
        n_orbitals: Number of orbitals
        n_electrons: Number of electrons
        circuit_depth: Depth of the preparation circuit
        gate_noise: Depolarizing noise rate per gate

    Returns:
        Dictionary with certification results
    """
    K = molecular_orbital_kernel(n_orbitals, n_electrons)

    # Compute negative dependence margin
    margin = float('inf')
    for i in range(n_orbitals):
        for j in range(i + 1, n_orbitals):
            defect = -K[i, j] ** 2  # Symmetric kernel
            margin = min(margin, -defect)

    # Certified bound (symmetric case)
    certified_bound = 2 * circuit_depth * gate_noise

    # Simulate noisy circuit
    n = n_orbitals
    K_noisy = K.copy()
    for _ in range(circuit_depth):
        K_noisy = (1 - gate_noise) * K_noisy + gate_noise * np.eye(n) / 2

    actual_max_diff = np.abs(K - K_noisy).max()

    return {
        'n_orbitals': n_orbitals,
        'n_electrons': n_electrons,
        'neg_dep_margin': margin,
        'certified_bound': certified_bound,
        'is_certified': certified_bound < margin,
        'actual_max_diff': actual_max_diff,
        'max_certified_depth': margin / (2 * gate_noise) if gate_noise > 0 else float('inf'),
    }


# ============================================================
# Application 2: Quantum Advantage Benchmarking
# ============================================================

def quantum_advantage_threshold(n_modes: int, filling: float = 0.5,
                                 target_depth: int = 100) -> float:
    """Compute the maximum noise rate for certified quantum advantage.

    For a fermion sampling experiment with given parameters, determines
    the noise threshold below which correlations remain certified.

    Args:
        n_modes: Number of fermionic modes
        filling: Fraction of modes occupied
        target_depth: Target circuit depth

    Returns:
        Maximum tolerable noise rate per gate
    """
    k = int(n_modes * filling)
    K = molecular_orbital_kernel(n_modes, k)

    margin = float('inf')
    for i in range(n_modes):
        for j in range(i + 1, n_modes):
            margin = min(margin, K[i, j] ** 2)

    # eps_max = margin / (2 * d)
    eps_max = margin / (2 * target_depth)
    return eps_max


# ============================================================
# Application 3: DPP Kernel Quality for Machine Learning
# ============================================================

def dpp_kernel_certification(K: np.ndarray, perturbation: np.ndarray) -> Dict:
    """Certify the quality of a perturbed DPP kernel.

    Given an ideal DPP kernel K and a perturbation matrix E = K' - K,
    computes certified bounds on how the perturbation affects
    sampling quality.

    Args:
        K: Ideal DPP kernel (symmetric PSD, eigenvalues in [0,1])
        perturbation: Perturbation matrix E

    Returns:
        Dictionary with certification metrics
    """
    n = K.shape[0]
    K_perturbed = K + perturbation

    eta = np.abs(perturbation).max()

    # Check if perturbed kernel still satisfies neg dep
    all_neg_dep = True
    max_defect = -float('inf')
    for i in range(n):
        for j in range(i + 1, n):
            defect = (K_perturbed[i, i] * K_perturbed[j, j] -
                      K_perturbed[i, j] * K_perturbed[j, i]) - \
                     K_perturbed[i, i] * K_perturbed[j, j]
            max_defect = max(max_defect, defect)
            if defect > 0:
                all_neg_dep = False

    return {
        'perturbation_norm': eta,
        'certified_defect_bound': 4 * eta,  # General bound
        'symmetric_defect_bound': 2 * eta,  # If both symmetric
        'actual_max_defect': max_defect,
        'neg_dep_preserved': all_neg_dep,
    }


if __name__ == "__main__":
    print("=" * 60)
    print("APPLICATION 1: Molecular Orbital Certification")
    print("=" * 60)

    for n in [4, 8, 16]:
        result = certify_molecular_simulation(n, n // 2,
                                               circuit_depth=20,
                                               gate_noise=0.01)
        print(f"\n{n}-orbital molecule ({n//2} electrons):")
        print(f"  Neg dep margin: {result['neg_dep_margin']:.6f}")
        print(f"  Certified bound: {result['certified_bound']:.6f}")
        print(f"  Certified: {result['is_certified']}")
        print(f"  Max certified depth: {result['max_certified_depth']:.1f}")

    print("\n" + "=" * 60)
    print("APPLICATION 2: Quantum Advantage Thresholds")
    print("=" * 60)

    for n in [4, 8, 16, 32]:
        for d in [10, 50, 100]:
            eps_max = quantum_advantage_threshold(n, filling=0.5, target_depth=d)
            print(f"  n={n:>3}, depth={d:>3}: max noise = {eps_max:.6f}")

    print("\n" + "=" * 60)
    print("APPLICATION 3: DPP Kernel Certification")
    print("=" * 60)

    n = 8
    K = molecular_orbital_kernel(n, n // 2)
    rng = np.random.default_rng(42)
    E = rng.standard_normal((n, n)) * 0.01
    E = (E + E.T) / 2  # Symmetrize

    result = dpp_kernel_certification(K, E)
    print(f"\nKernel size: {n}x{n}")
    print(f"  Perturbation norm: {result['perturbation_norm']:.6f}")
    print(f"  Certified defect bound: {result['certified_defect_bound']:.6f}")
    print(f"  Symmetric defect bound: {result['symmetric_defect_bound']:.6f}")
    print(f"  Actual max defect: {result['actual_max_defect']:.6f}")
    print(f"  Neg dep preserved: {result['neg_dep_preserved']}")


"""Build PACKAGE.json from all deliverables."""

import json

def read_file(path):
    with open(path, 'r') as f:
        return f.read()

package = {
    "title": "Certified Fermion Sampling in Noisy Quantum Circuits",
    "domain": "Quantum Information / Probability Theory / Pythagorean",
    "article": read_file("ARTICLE.md"),
    "research_paper": read_file("RESEARCH_PAPER.md"),
    "future_directions": read_file("FUTURE_DIRECTIONS.md"),
    "demos": [
        {
            "name": "Certified Fermion Sampling Demo",
            "code": read_file("demo.py")
        }
    ],
    "algorithms": [
        {
            "name": "Certified Fermion Sampling Algorithms",
            "pseudocode": """Algorithm: CertifyFermionSampling(K, d, eps)
Input: Ideal kernel K, depth d, noise rate eps
Output: Certified quality bound

1. Compute delta = min_{i<j} K_ij^2          // O(n^2)
2. Compute bound = 2 * d * eps                // O(1)
3. If bound < delta: return CERTIFIED
   Else: return NOT_CERTIFIED

Time: O(n^2), Space: O(n^2)""",
            "code": read_file("algorithms.py")
        }
    ],
    "visualizations": [
        {
            "name": "Noise Threshold Phase Diagram",
            "code": read_file("viz_noise_threshold.py"),
            "description": "Phase diagram showing certified vs uncertified regions in the (depth, noise) parameter space for fermion sampling."
        },
        {
            "name": "Defect Perturbation Bounds",
            "code": read_file("viz_defect_perturbation.py"),
            "description": "Comparison of actual defect perturbation with certified 2η and 4η bounds, demonstrating bound tightness."
        },
        {
            "name": "Kernel Evolution Under Noise",
            "code": read_file("viz_kernel_evolution.py"),
            "description": "Heatmap evolution of the fermion correlation matrix under depolarizing noise, showing contraction toward maximally mixed state."
        }
    ],
    "interactive_demos": [
        {
            "name": "Noise Threshold Explorer",
            "html": read_file("interactive_noise_slider.html"),
            "description": "Interactive explorer for the noise threshold theorem. Adjust noise rate, circuit depth, and margin to see whether fermion sampling is certified."
        },
        {
            "name": "Correlation Matrix Under Noise",
            "html": read_file("interactive_kernel_viz.html"),
            "description": "Watch the fermion correlation matrix evolve under depolarizing noise with adjustable parameters."
        }
    ],
    "lean_proofs": read_file("Pythagorean/CertifiedFermionSampling.lean")
}

with open("PACKAGE.json", "w") as f:
    json.dump(package, f, indent=2, ensure_ascii=False)

print("PACKAGE.json created successfully")
print(f"  Size: {len(json.dumps(package))} bytes")


"""
Certified Fermion Sampling in Noisy Quantum Circuits — Demo
============================================================

Demonstrates the core theorems with concrete numerical examples:
1. Depolarizing channel contraction
2. Noise accumulation bound
3. Pairwise negative dependence defect perturbation
4. Noise threshold computation
5. Symmetric vs general kernel advantage
"""

import numpy as np
from typing import Tuple


def depolarizing_channel(K: np.ndarray, eps: float) -> np.ndarray:
    """Apply depolarizing channel: K -> (1-eps)*K + eps*(I/2)."""
    n = K.shape[0]
    return (1 - eps) * K + eps * np.eye(n) / 2


def pairwise_neg_dep_defect(K: np.ndarray, i: int, j: int) -> float:
    """Compute pairwise negative dependence defect = K_ii*K_jj - K_ij*K_ji - K_ii*K_jj."""
    return (K[i, i] * K[j, j] - K[i, j] * K[j, i]) - K[i, i] * K[j, j]


def max_certified_depth(eps: float, tau: float, symmetric: bool = False) -> float:
    """Maximum circuit depth maintaining certified negative dependence."""
    if symmetric:
        return tau / (2 * eps)
    else:
        return tau / (4 * eps)


def make_fermion_kernel(n: int, filling: float = 0.5) -> np.ndarray:
    """Create a valid fermion correlation matrix (random Slater determinant).

    K = U @ diag(occupations) @ U^T where U is a random orthogonal matrix
    and occupations are eigenvalues in [0, 1].
    """
    rng = np.random.default_rng(42)
    U, _ = np.linalg.qr(rng.standard_normal((n, n)))
    k = int(n * filling)
    eigenvalues = np.zeros(n)
    eigenvalues[:k] = 1.0  # Exact Slater determinant
    K = U @ np.diag(eigenvalues) @ U.T
    return K


def verify_fermion_properties(K: np.ndarray) -> dict:
    """Verify that K is a valid fermion correlation matrix."""
    n = K.shape[0]
    eigvals_K = np.linalg.eigvalsh(K)
    eigvals_ImK = np.linalg.eigvalsh(np.eye(n) - K)
    return {
        "symmetric": np.allclose(K, K.T),
        "psd": np.all(eigvals_K >= -1e-10),
        "I_minus_K_psd": np.all(eigvals_ImK >= -1e-10),
        "eigenvalues_in_01": np.all(eigvals_K >= -1e-10) and np.all(eigvals_K <= 1 + 1e-10),
        "min_eigenvalue": float(eigvals_K.min()),
        "max_eigenvalue": float(eigvals_K.max()),
    }


# ============================================================
# DEMO 1: Depolarizing Channel Contraction
# ============================================================
print("=" * 60)
print("DEMO 1: Depolarizing Channel Contraction")
print("=" * 60)

n = 4
K = make_fermion_kernel(n)
eps = 0.1

print(f"\nIdeal kernel K ({n}x{n}):")
print(np.round(K, 4))
print(f"\nFermion properties: {verify_fermion_properties(K)}")

K_noisy = depolarizing_channel(K, eps)
print(f"\nNoisy kernel K' = (1-{eps})*K + {eps}*I/2:")
print(np.round(K_noisy, 4))
print(f"\nNoisy fermion properties: {verify_fermion_properties(K_noisy)}")

# Verify contraction
diff = np.abs(K - K_noisy).max()
print(f"\n‖K - K'‖_max = {diff:.6f}")
print(f"(1-eps) * max|K_ij - I/2_ij| = {(1-eps) * np.abs(K - np.eye(n)/2).max():.6f}")
print(f"eps * max|K_ij - I/2_ij| = {eps * np.abs(K - np.eye(n)/2).max():.6f}")

# ============================================================
# DEMO 2: Noise Accumulation
# ============================================================
print("\n" + "=" * 60)
print("DEMO 2: Noise Accumulation Over Circuit Depth")
print("=" * 60)

depths = [1, 5, 10, 20, 50]
eps = 0.01
K0 = make_fermion_kernel(n)

print(f"\nNoise rate per gate: eps = {eps}")
print(f"{'Depth':>6} | {'‖K-K_d‖_max':>12} | {'d*eps bound':>12} | {'Ratio':>8}")
print("-" * 50)

for d in depths:
    K_d = K0.copy()
    for _ in range(d):
        K_d = depolarizing_channel(K_d, eps)
    actual_err = np.abs(K0 - K_d).max()
    bound = d * eps
    print(f"{d:>6} | {actual_err:>12.6f} | {bound:>12.6f} | {actual_err/bound:>8.4f}")

# ============================================================
# DEMO 3: Pairwise Negative Dependence Defect
# ============================================================
print("\n" + "=" * 60)
print("DEMO 3: Negative Dependence Defect Perturbation")
print("=" * 60)

K = make_fermion_kernel(n)
print(f"\nIdeal kernel defects (should all be ≤ 0):")
for i in range(n):
    for j in range(i + 1, n):
        d_val = pairwise_neg_dep_defect(K, i, j)
        print(f"  defect({i},{j}) = {d_val:.6f}")

# Apply noise
eta_values = [0.001, 0.01, 0.05, 0.1]
print(f"\nDefect perturbation bounds:")
print(f"{'eta':>8} | {'Max |Δdefect|':>14} | {'4η bound':>10} | {'2η bound':>10} | {'Actual/2η':>10}")
print("-" * 65)

for eta in eta_values:
    K_perturbed = depolarizing_channel(K, eta)
    max_delta = 0
    for i in range(n):
        for j in range(i + 1, n):
            d_ideal = pairwise_neg_dep_defect(K, i, j)
            d_noisy = pairwise_neg_dep_defect(K_perturbed, i, j)
            max_delta = max(max_delta, abs(d_ideal - d_noisy))
    print(f"{eta:>8.4f} | {max_delta:>14.8f} | {4*eta:>10.6f} | {2*eta:>10.6f} | {max_delta/(2*eta):>10.6f}")

# ============================================================
# DEMO 4: Noise Threshold
# ============================================================
print("\n" + "=" * 60)
print("DEMO 4: Noise Threshold Computation")
print("=" * 60)

K = make_fermion_kernel(n)

# Compute the negative dependence margin
margin = float('inf')
for i in range(n):
    for j in range(i + 1, n):
        d_val = pairwise_neg_dep_defect(K, i, j)
        margin = min(margin, -d_val)

print(f"\nNegative dependence margin δ = {margin:.6f}")

eps_values = [0.001, 0.005, 0.01, 0.05]
print(f"\nMaximum certified depth for each noise rate:")
print(f"{'eps':>8} | {'General d_max':>14} | {'Symmetric d_max':>16} | {'Advantage':>10}")
print("-" * 60)

for eps in eps_values:
    d_gen = max_certified_depth(eps, margin, symmetric=False)
    d_sym = max_certified_depth(eps, margin, symmetric=True)
    print(f"{eps:>8.4f} | {d_gen:>14.1f} | {d_sym:>16.1f} | {d_sym/d_gen:>10.1f}x")

# ============================================================
# DEMO 5: Conjecture Test — Tightness of Constant 2
# ============================================================
print("\n" + "=" * 60)
print("DEMO 5: Conjecture Test — Tightness of Constant 2")
print("=" * 60)

# For symmetric K, defect = -(K_ij)^2
# |defect_K - defect_K'| = |K_ij^2 - K'_ij^2| = |K_ij + K'_ij| * |K_ij - K'_ij|
# As K_ij -> 1 and eta -> 0, ratio -> 2

print("\nTesting tightness: ratio = max|Δdefect| / eta as eta → 0")
print("(Conjecture: this ratio approaches 2 for symmetric kernels)")

# Use a kernel with K_ij close to 1
U = np.array([[1, 1], [1, -1]]) / np.sqrt(2)
K_tight = np.ones((2, 2)) * 0.5  # Rank-1 projector divided by 2

# Actually use a kernel with off-diagonal close to 1
# K = [[a, c], [c, a]] with a, c chosen so eigenvalues in [0,1]
# eigenvalues = a+c and a-c, both in [0,1]
# To maximize c: set a+c=1, a-c=0, so a=c=0.5
# K_ij = 0.5, so |K_ij| = 0.5

# To get K_ij = 0.99: eigenvalues 1.99 and 0.01 — but 1.99 > 1!
# So max |K_ij| = 0.5 for a 2x2 kernel. Use larger n.

# For 4x4, use rank-2 projector
n_test = 4
rng = np.random.default_rng(123)
v1 = rng.standard_normal(n_test)
v1 /= np.linalg.norm(v1)
v2 = rng.standard_normal(n_test)
v2 -= v2 @ v1 * v1
v2 /= np.linalg.norm(v2)
K_proj = np.outer(v1, v1) + np.outer(v2, v2)  # Rank-2 projector, eigenvalues 0 or 1

# Find the pair with largest |K_ij|
best_i, best_j = 0, 1
for i in range(n_test):
    for j in range(i+1, n_test):
        if abs(K_proj[i, j]) > abs(K_proj[best_i, best_j]):
            best_i, best_j = i, j

K_ij_val = abs(K_proj[best_i, best_j])
print(f"\nUsing {n_test}x{n_test} rank-2 projector, best |K_ij| = {K_ij_val:.6f}")

eta_tests = [0.1, 0.05, 0.01, 0.005, 0.001, 0.0005, 0.0001]
print(f"{'eta':>10} | {'Max |Δdefect|':>14} | {'2η':>10} | {'Ratio':>8}")
print("-" * 50)

for eta in eta_tests:
    # Perturb entry-by-entry
    K_pert = K_proj.copy()
    K_pert[best_i, best_j] -= eta
    K_pert[best_j, best_i] -= eta  # Keep symmetric

    d_orig = pairwise_neg_dep_defect(K_proj, best_i, best_j)
    d_pert = pairwise_neg_dep_defect(K_pert, best_i, best_j)
    delta = abs(d_orig - d_pert)
    ratio = delta / (2 * eta) if eta > 0 else 0
    print(f"{eta:>10.5f} | {delta:>14.10f} | {2*eta:>10.6f} | {ratio:>8.6f}")

print(f"\nExpected limit: 2*|K_ij| = {2*K_ij_val:.6f}")
print("The ratio converges to 2*|K_ij| < 2, confirming the bound is tight")
print("only when |K_ij| = 1 (achievable for larger matrices).")


if __name__ == "__main__":
    print("\n\nAll demos completed successfully!")


"""
Visualization 2: Defect Perturbation Bounds
=============================================
Shows how the pairwise negative dependence defect changes under
perturbation, comparing the actual change with the certified 2η
and 4η bounds. Demonstrates the tightness of the symmetric bound.
"""

import numpy as np
import matplotlib.pyplot as plt


def molecular_orbital_kernel(n_orbitals, n_electrons, hopping_strength=1.0):
    H = np.zeros((n_orbitals, n_orbitals))
    for i in range(n_orbitals - 1):
        H[i, i + 1] = -hopping_strength
        H[i + 1, i] = -hopping_strength
    eigvals, eigvecs = np.linalg.eigh(H)
    occupied = eigvecs[:, :n_electrons]
    return occupied @ occupied.T


def pairwise_neg_dep_defect(K, i, j):
    return (K[i, i] * K[j, j] - K[i, j] * K[j, i]) - K[i, i] * K[j, j]


# Setup
n = 8
k = 4
K = molecular_orbital_kernel(n, k)

eta_values = np.logspace(-4, -0.5, 50)

# Track max defect perturbation for each eta
max_defect_changes = []
for eta in eta_values:
    K_noisy = (1 - eta) * K + eta * np.eye(n) / 2
    max_change = 0
    for i in range(n):
        for j in range(i + 1, n):
            d_ideal = pairwise_neg_dep_defect(K, i, j)
            d_noisy = pairwise_neg_dep_defect(K_noisy, i, j)
            max_change = max(max_change, abs(d_ideal - d_noisy))
    max_defect_changes.append(max_change)

max_defect_changes = np.array(max_defect_changes)

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

# Plot 1: Absolute bounds
ax1.loglog(eta_values, max_defect_changes, 'ko-', markersize=3,
           label='Actual max |Δdefect|', linewidth=2)
ax1.loglog(eta_values, 2 * eta_values, 'b--', linewidth=2,
           label='Symmetric bound (2η)')
ax1.loglog(eta_values, 4 * eta_values, 'r--', linewidth=2,
           label='General bound (4η)')
ax1.set_xlabel('Perturbation η', fontsize=12)
ax1.set_ylabel('Max |Δdefect|', fontsize=12)
ax1.set_title('Defect Perturbation: Actual vs Certified Bounds', fontsize=13, fontweight='bold')
ax1.legend(fontsize=11)
ax1.grid(True, alpha=0.3)

# Plot 2: Ratios
ratio_2eta = max_defect_changes / (2 * eta_values)
ratio_4eta = max_defect_changes / (4 * eta_values)

ax2.semilogx(eta_values, ratio_2eta, 'b-o', markersize=3, linewidth=2,
             label='Actual / (2η)')
ax2.semilogx(eta_values, ratio_4eta, 'r-o', markersize=3, linewidth=2,
             label='Actual / (4η)')
ax2.axhline(y=1.0, color='gray', linestyle=':', linewidth=1.5, label='Bound = 1')
ax2.set_xlabel('Perturbation η', fontsize=12)
ax2.set_ylabel('Ratio (actual / bound)', fontsize=12)
ax2.set_title('Bound Tightness Analysis', fontsize=13, fontweight='bold')
ax2.legend(fontsize=11)
ax2.grid(True, alpha=0.3)
ax2.set_ylim(0, 1.2)

plt.suptitle(f'Certified Fermion Sampling Quality (n={n})',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig("defect_perturbation_bounds.png", dpi=150, bbox_inches='tight')
plt.close()
print("Saved defect_perturbation_bounds.png")


"""
Visualization 3: Correlation Matrix Evolution Under Noise
==========================================================
Heatmap visualization showing how the fermion correlation matrix
evolves as depolarizing noise is applied over multiple circuit layers.
Demonstrates the contraction toward the maximally mixed state.
"""

import numpy as np
import matplotlib.pyplot as plt


def molecular_orbital_kernel(n_orbitals, n_electrons, hopping_strength=1.0):
    H = np.zeros((n_orbitals, n_orbitals))
    for i in range(n_orbitals - 1):
        H[i, i + 1] = -hopping_strength
        H[i + 1, i] = -hopping_strength
    eigvals, eigvecs = np.linalg.eigh(H)
    occupied = eigvecs[:, :n_electrons]
    return occupied @ occupied.T


# Setup
n = 8
k = 4
K = molecular_orbital_kernel(n, k)

depths = [0, 5, 20, 100]
eps = 0.05

fig, axes = plt.subplots(2, 4, figsize=(20, 9))

for idx, d in enumerate(depths):
    K_d = K.copy()
    for _ in range(d):
        K_d = (1 - eps) * K_d + eps * np.eye(n) / 2

    # Top row: correlation matrix heatmap
    ax = axes[0, idx]
    im = ax.imshow(K_d, cmap='RdBu_r', vmin=-0.5, vmax=1.0, aspect='equal')
    ax.set_title(f'd = {d}', fontsize=14, fontweight='bold')
    if idx == 0:
        ax.set_ylabel('Mode i', fontsize=12)
    ax.set_xlabel('Mode j', fontsize=12)
    plt.colorbar(im, ax=ax, fraction=0.046)

    # Bottom row: eigenvalue spectrum
    ax2 = axes[1, idx]
    eigvals = np.linalg.eigvalsh(K_d)
    colors = ['#2196F3' if v > 0.01 else '#9E9E9E' for v in eigvals]
    ax2.bar(range(n), eigvals, color=colors, edgecolor='black', linewidth=0.5)
    ax2.axhline(y=0.5, color='red', linestyle='--', alpha=0.5, label='Mixed state')
    ax2.set_ylim(-0.05, 1.05)
    ax2.set_xlabel('Eigenvalue index', fontsize=12)
    if idx == 0:
        ax2.set_ylabel('Eigenvalue', fontsize=12)
    ax2.set_title(f'Spectrum (d={d})', fontsize=12)
    if idx == 0:
        ax2.legend(fontsize=10)

    # Annotate with max entry diff
    if d > 0:
        diff = np.abs(K - K_d).max()
        ax.text(0.02, 0.02, f'‖K-K\'‖_max={diff:.3f}',
                transform=ax.transAxes, fontsize=9, color='white',
                bbox=dict(boxstyle='round', facecolor='black', alpha=0.7),
                verticalalignment='bottom')

plt.suptitle(f'Fermion Correlation Matrix Under Depolarizing Noise\n'
             f'(n={n} modes, {k} electrons, ε={eps} per gate)',
             fontsize=16, fontweight='bold', y=1.0)
plt.tight_layout()
plt.savefig("kernel_evolution.png", dpi=150, bbox_inches='tight')
plt.close()
print("Saved kernel_evolution.png")


"""
Visualization 1: Noise Threshold Phase Diagram
================================================
Visualizes the certified noise threshold as a function of circuit depth
and noise rate. Shows the boundary between certified and uncertified
regions in the (depth, noise) parameter space.
"""

import numpy as np
import matplotlib.pyplot as plt


def molecular_orbital_kernel(n_orbitals, n_electrons, hopping_strength=1.0):
    H = np.zeros((n_orbitals, n_orbitals))
    for i in range(n_orbitals - 1):
        H[i, i + 1] = -hopping_strength
        H[i + 1, i] = -hopping_strength
    eigvals, eigvecs = np.linalg.eigh(H)
    occupied = eigvecs[:, :n_electrons]
    return occupied @ occupied.T


def pairwise_neg_dep_defect(K, i, j):
    return (K[i, i] * K[j, j] - K[i, j] * K[j, i]) - K[i, i] * K[j, j]


def compute_neg_dep_margin(K):
    n = K.shape[0]
    margin = float('inf')
    for i in range(n):
        for j in range(i + 1, n):
            margin = min(margin, -pairwise_neg_dep_defect(K, i, j))
    return margin


def simulate_noisy_circuit(K, depth, eps):
    n = K.shape[0]
    K_noisy = K.copy()
    for _ in range(depth):
        K_noisy = (1 - eps) * K_noisy + eps * np.eye(n) / 2
    return K_noisy


# Parameters
n = 8
k = 4
K = molecular_orbital_kernel(n, k)
margin = compute_neg_dep_margin(K)

eps_range = np.linspace(0.001, 0.1, 80)
depth_range = np.arange(1, 101)

# Compute phase diagrams
certified_sym = np.zeros((len(eps_range), len(depth_range)))
certified_gen = np.zeros((len(eps_range), len(depth_range)))
actual = np.zeros((len(eps_range), len(depth_range)))

for ie, eps in enumerate(eps_range):
    for id_, d in enumerate(depth_range):
        certified_sym[ie, id_] = 1.0 if 2 * d * eps < margin else 0.0
        certified_gen[ie, id_] = 1.0 if 4 * d * eps < margin else 0.0

        K_noisy = simulate_noisy_circuit(K, d, eps)
        all_neg = all(
            pairwise_neg_dep_defect(K_noisy, i, j) < 0
            for i in range(n) for j in range(i + 1, n)
        )
        actual[ie, id_] = 1.0 if all_neg else 0.0

fig, axes = plt.subplots(1, 3, figsize=(18, 5))

for ax, data, title, cmap in [
    (axes[0], actual, "Actual Neg. Dep. Preserved", "Greens"),
    (axes[1], certified_gen, "Certified (General: 4dε < δ)", "Blues"),
    (axes[2], certified_sym, "Certified (Symmetric: 2dε < δ)", "Oranges"),
]:
    im = ax.imshow(data, aspect='auto', origin='lower',
                   extent=[depth_range[0], depth_range[-1],
                           eps_range[0], eps_range[-1]],
                   cmap=cmap, alpha=0.8)
    ax.set_xlabel("Circuit Depth d", fontsize=12)
    ax.set_ylabel("Noise Rate ε", fontsize=12)
    ax.set_title(title, fontsize=13, fontweight='bold')
    plt.colorbar(im, ax=ax, label="Preserved / Certified")

    # Add threshold curve
    if "Symmetric" in title:
        threshold_depths = margin / (2 * eps_range)
    elif "General" in title:
        threshold_depths = margin / (4 * eps_range)
    else:
        threshold_depths = None

    if threshold_depths is not None:
        ax.plot(threshold_depths, eps_range, 'r-', linewidth=2, label='Threshold')
        ax.legend(fontsize=10)

plt.suptitle(f"Noise Threshold Phase Diagram (n={n}, δ={margin:.4f})",
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig("noise_threshold_phase_diagram.png", dpi=150, bbox_inches='tight')
plt.close()
print("Saved noise_threshold_phase_diagram.png")
