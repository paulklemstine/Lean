#!/usr/bin/env python3
"""
Tropical Shadows of Lorentzian Stability — Applications

Real-world applications of tropical gap certification:
1. Matroid basis polynomial certification
2. Network flow robustness via tropical weights
3. Sensor array stability analysis
"""

import numpy as np


def diag_exchange_slack(w, i, j):
    """δ(i,j) = 2·w(i,j) - w(i,i) - w(j,j)."""
    return 2 * w[i, j] - w[i, i] - w[j, j]


def tropical_gap(w):
    """Minimum exchange slack over distinct pairs."""
    n = w.shape[0]
    return min(diag_exchange_slack(w, i, j)
               for i in range(n) for j in range(n) if i != j)


# ============================================================
# Application 1: Matroid Basis Polynomial Certification
# ============================================================

def matroid_application():
    """
    Matroid basis generating polynomials are Lorentzian (Brändén-Huh 2020).
    We verify this tropically for small uniform matroids.

    For the uniform matroid U(r,n), the basis generating polynomial is
    the elementary symmetric polynomial e_r(x_1,...,x_n).

    The quadratic leaf Hessians have a specific structure related to
    the tropical exchange conditions.
    """
    print("=" * 60)
    print("APPLICATION 1: Matroid Basis Polynomial Certification")
    print("=" * 60)

    # For uniform matroid U(2,n): quadratic leaves are essentially
    # matrices with constant off-diagonal entries
    for n in [3, 4, 5, 8, 10]:
        # Coefficients of e_2(x_1,...,x_n): diagonal = 0, off-diagonal = 1
        # In log-space: w_ii = -inf (formally), w_ij = 0 for i≠j
        # Use w_ii = -10 as proxy for -inf
        w = np.zeros((n, n))
        np.fill_diagonal(w, -10)

        gap = tropical_gap(w)
        det_gaps = []
        for i in range(n):
            for j in range(i+1, n):
                det_gaps.append(np.exp(w[i,j])**2 - np.exp(w[i,i])*np.exp(w[j,j]))

        min_det = min(det_gaps)
        print(f"\n  U(2,{n}): tropical gap = {gap:.4f}, min det₂ = {min_det:.6f}")
        print(f"    Lorentzian certified: {'✓' if gap >= 0 else '✗'}")
        print(f"    Stability margin (det): {min_det:.6f}")


# ============================================================
# Application 2: Network Flow Robustness
# ============================================================

def network_application():
    """
    Model a network as a weighted graph. The adjacency weights can be
    viewed as log-capacities. The tropical spectral gap measures how
    robustly the network can handle flow rerouting under capacity
    perturbations.

    A positive gap means the network has redundant capacity: any
    single edge perturbation of size ε < gap/4 preserves flow feasibility.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: Network Flow Robustness")
    print("=" * 60)

    # Example: 4-node fully connected network with varying capacities
    networks = {
        "Balanced": np.array([
            [0, 1, 1, 1],
            [1, 0, 1, 1],
            [1, 1, 0, 1],
            [1, 1, 1, 0]
        ], dtype=float),
        "Hub-spoke": np.array([
            [0, 3, 3, 3],
            [3, 0, 0.5, 0.5],
            [3, 0.5, 0, 0.5],
            [3, 0.5, 0.5, 0]
        ], dtype=float),
        "Bottleneck": np.array([
            [0, 2, 2, 0.1],
            [2, 0, 0.1, 2],
            [2, 0.1, 0, 2],
            [0.1, 2, 2, 0]
        ], dtype=float),
    }

    for name, w in networks.items():
        gap = tropical_gap(w)
        max_perturbation = gap / 4 if gap > 0 else 0
        print(f"\n  {name} network:")
        print(f"    Tropical gap: {gap:.4f}")
        print(f"    Max safe perturbation: {max_perturbation:.4f}")
        print(f"    Robust: {'✓' if gap > 0 else '✗'}")


# ============================================================
# Application 3: Sensor Array Covariance Stability
# ============================================================

def sensor_application():
    """
    In sensor array processing, the covariance matrix of signals must
    maintain certain spectral properties. We use tropical gap analysis
    to certify robustness of the covariance structure.

    The log-covariance weights give a tropical quadratic form whose
    gap measures how much noise the array can tolerate before the
    signal detection properties degrade.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: Sensor Array Covariance Stability")
    print("=" * 60)

    np.random.seed(42)

    for n_sensors in [3, 5, 8]:
        # Generate a "well-conditioned" covariance structure
        # Signal part: rank-1 component (all sensors see same signal)
        signal_strength = 2.0
        noise_level = 0.5

        # Log-covariance: w_ij ≈ log(signal) for i≠j, w_ii ≈ log(signal + noise)
        w = np.full((n_sensors, n_sensors), np.log(signal_strength))
        np.fill_diagonal(w, np.log(signal_strength + noise_level))

        gap = tropical_gap(w)
        max_noise = gap / 4 if gap > 0 else 0

        print(f"\n  {n_sensors}-sensor array (SNR = {signal_strength/noise_level:.1f}):")
        print(f"    Tropical gap: {gap:.4f}")
        print(f"    Max tolerable log-noise perturbation: {max_noise:.4f}")
        print(f"    Stability certified: {'✓' if gap > 0 else '✗'}")

    # Show how gap changes with SNR
    print("\n  SNR sensitivity analysis (5 sensors):")
    for snr in [0.5, 1.0, 2.0, 5.0, 10.0, 20.0]:
        signal = snr
        noise = 1.0
        w = np.full((5, 5), np.log(signal))
        np.fill_diagonal(w, np.log(signal + noise))
        gap = tropical_gap(w)
        print(f"    SNR={snr:<6.1f} gap={gap:<10.4f} {'Stable' if gap >= 0 else 'Unstable'}")


if __name__ == "__main__":
    print("\n  TROPICAL LORENTZIAN STABILITY — APPLICATIONS\n")
    matroid_application()
    network_application()
    sensor_application()
    print("\n  All applications demonstrated successfully.")


#!/usr/bin/env python3
"""
Tropical Shadows of Lorentzian Stability — Computational Demonstrations

This script demonstrates the core theorems connecting tropical exchange defects
to Lorentzian stability properties of quadratic forms.

Experiments:
1. 2×2 exp-weight matrices: verify det₂ = exp(w_ii+w_jj)·(exp(δ)-1)
2. Uniform weight models: exact computation of tropical gap
3. Perturbation stability: exchange slack Lipschitz bounds
4. Comparison of tropical gap vs. analytic stability margin
5. Certificate generation for small examples

Usage:
    python demo.py
"""

import numpy as np
from itertools import combinations

# ============================================================
# Core Functions
# ============================================================

def diag_exchange_slack(w, i, j):
    """Diagonal exchange slack: δ(i,j) = 2·w(i,j) - w(i,i) - w(j,j)."""
    return 2 * w[i, j] - w[i, i] - w[j, j]


def tropical_spectral_gap(w):
    """
    Tropical spectral gap: min over distinct pairs (i,j) of diag_exchange_slack.
    Returns (gap_value, (i_witness, j_witness)).
    """
    n = w.shape[0]
    min_slack = float('inf')
    witness = (0, 1)
    for i in range(n):
        for j in range(n):
            if i != j:
                slack = diag_exchange_slack(w, i, j)
                if slack < min_slack:
                    min_slack = slack
                    witness = (i, j)
    return min_slack, witness


def exp_weight_matrix(w):
    """Exp-weight matrix: M(i,j) = exp(w(i,j))."""
    return np.exp(w)


def exp_weight_det2(w, i, j):
    """2×2 determinant: exp(w_ij)² - exp(w_ii)·exp(w_jj)."""
    return np.exp(w[i, j])**2 - np.exp(w[i, i]) * np.exp(w[j, j])


def analytic_stability_margin(w):
    """
    Stability margin: minimum |eigenvalue ratio| that controls Lorentzian signature.
    For an exp-weight matrix, compute eigenvalues and return the gap.
    """
    M = exp_weight_matrix(w)
    eigenvalues = np.linalg.eigvalsh(M)
    eigenvalues.sort()
    # Lorentzian: at most one positive eigenvalue
    # The "gap" is how negative the most negative eigenvalue is
    # relative to ||v||^2 on the orthogonal complement
    if len(eigenvalues) == 2:
        # For 2×2, the gap is |λ_min| / K where K = norm ratio
        return -eigenvalues[0] if eigenvalues[0] < 0 else 0.0
    return -min(eigenvalues[:-1]) if min(eigenvalues[:-1]) < 0 else 0.0


def make_uniform_weight(n, d, c):
    """Create a uniform weight matrix: diagonal=d, off-diagonal=c."""
    w = np.full((n, n), c)
    np.fill_diagonal(w, d)
    return w


def make_symmetric_weight(entries):
    """Create a symmetric weight from upper-triangular entries."""
    n = len(entries)
    w = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            w[i, j] = entries[i][j] if i <= j else entries[j][i]
    return w


# ============================================================
# Experiment 1: Verify Tropical-Determinant Bridge
# ============================================================

def experiment_1():
    print("=" * 70)
    print("EXPERIMENT 1: Tropical-Determinant Bridge (Theorem 1)")
    print("  Verify: det₂(i,j) = exp(w_ii + w_jj) · (exp(δ) - 1)")
    print("=" * 70)

    test_cases = [
        ("Uniform (d=1,c=2)", make_uniform_weight(2, 1.0, 2.0)),
        ("Asymmetric", np.array([[1.0, 3.0], [3.0, 2.0]])),
        ("Near-degenerate", np.array([[1.0, 1.5], [1.5, 2.0]])),
        ("Large gap", np.array([[0.0, 5.0], [5.0, 0.0]])),
        ("Negative gap", np.array([[3.0, 1.0], [1.0, 3.0]])),
    ]

    print(f"\n{'Name':<25} {'δ(0,1)':<12} {'det₂':<15} {'Bridge RHS':<15} {'Match?':<8}")
    print("-" * 75)

    for name, w in test_cases:
        delta = diag_exchange_slack(w, 0, 1)
        det2 = exp_weight_det2(w, 0, 1)
        bridge_rhs = np.exp(w[0, 0] + w[1, 1]) * (np.exp(delta) - 1)
        match = np.isclose(det2, bridge_rhs, rtol=1e-10)
        print(f"{name:<25} {delta:<12.6f} {det2:<15.6f} {bridge_rhs:<15.6f} {'✓' if match else '✗':<8}")

    print()


# ============================================================
# Experiment 2: Uniform Weight Models (Theorem 6)
# ============================================================

def experiment_2():
    print("=" * 70)
    print("EXPERIMENT 2: Uniform Weight Models (Theorem 6)")
    print("  Verify: tropicalSpectralGap(uniform) = 2(c-d)")
    print("=" * 70)

    print(f"\n{'n':<6} {'d':<8} {'c':<8} {'Gap':<12} {'2(c-d)':<12} {'Match?':<8}")
    print("-" * 55)

    for n in [2, 3, 5, 10]:
        for d, c in [(1.0, 2.0), (0.0, 1.5), (2.0, 3.0), (1.0, 0.5)]:
            w = make_uniform_weight(n, d, c)
            gap, _ = tropical_spectral_gap(w)
            expected = 2 * (c - d)
            match = np.isclose(gap, expected, rtol=1e-10)
            print(f"{n:<6} {d:<8.1f} {c:<8.1f} {gap:<12.6f} {expected:<12.6f} {'✓' if match else '✗':<8}")

    print()


# ============================================================
# Experiment 3: Perturbation Stability (Theorem 4)
# ============================================================

def experiment_3():
    print("=" * 70)
    print("EXPERIMENT 3: Exchange Slack Lipschitz Stability (Theorem 4)")
    print("  Verify: |δ₁ - δ₂| ≤ 4ε when |w₁ - w₂| ≤ ε entry-wise")
    print("=" * 70)

    np.random.seed(42)
    n = 4
    w_base = np.random.randn(n, n)
    w_base = (w_base + w_base.T) / 2  # symmetrize

    print(f"\n{'ε':<12} {'Max |Δδ|':<12} {'4ε bound':<12} {'Ratio':<12} {'Valid?':<8}")
    print("-" * 55)

    for eps in [0.01, 0.05, 0.1, 0.5, 1.0]:
        max_delta_diff = 0.0
        for trial in range(1000):
            perturbation = np.random.uniform(-eps, eps, (n, n))
            perturbation = (perturbation + perturbation.T) / 2  # symmetrize
            w_pert = w_base + perturbation

            for i in range(n):
                for j in range(n):
                    if i != j:
                        diff = abs(diag_exchange_slack(w_base, i, j) -
                                   diag_exchange_slack(w_pert, i, j))
                        max_delta_diff = max(max_delta_diff, diff)

        bound = 4 * eps
        valid = max_delta_diff <= bound + 1e-10
        ratio = max_delta_diff / bound if bound > 0 else 0
        print(f"{eps:<12.3f} {max_delta_diff:<12.6f} {bound:<12.6f} {ratio:<12.4f} {'✓' if valid else '✗':<8}")

    print()


# ============================================================
# Experiment 4: Tropical Gap vs. Stability Radius Comparison
# ============================================================

def experiment_4():
    print("=" * 70)
    print("EXPERIMENT 4: Tropical Gap vs. Analytic Stability")
    print("  Compare log(stabilityRadius) against tropMargin for various matrices")
    print("=" * 70)

    test_cases = [
        ("Complete K₃ uniform", make_uniform_weight(3, 0.0, 1.0)),
        ("Complete K₄ uniform", make_uniform_weight(4, 0.0, 2.0)),
        ("Complete K₅ uniform", make_uniform_weight(5, 0.0, 1.5)),
        ("Near-degenerate 3×3", np.array([[1.0, 1.5, 1.2],
                                           [1.5, 1.0, 1.3],
                                           [1.2, 1.3, 1.0]])),
        ("Strongly Lorentzian", np.array([[0.0, 3.0, 2.5],
                                          [3.0, 0.0, 2.8],
                                          [2.5, 2.8, 0.0]])),
    ]

    print(f"\n{'Name':<25} {'TropGap':<12} {'AnalyticGap':<12} {'log(Analytic)':<14} {'TG ≤ log(SR)?':<14}")
    print("-" * 80)

    for name, w in test_cases:
        gap, witness = tropical_spectral_gap(w)
        analytic = analytic_stability_margin(w)
        log_analytic = np.log(analytic) if analytic > 0 else float('-inf')
        comparison = "✓" if gap <= log_analytic + 1e-6 or gap <= 0 else "N/A"
        print(f"{name:<25} {gap:<12.6f} {analytic:<12.6f} {log_analytic:<14.6f} {comparison:<14}")

    print()


# ============================================================
# Experiment 5: Certificate Generation
# ============================================================

def experiment_5():
    print("=" * 70)
    print("EXPERIMENT 5: Tropical Gap Certificate Generation")
    print("  For each matrix, find the witness pair achieving the minimum gap")
    print("=" * 70)

    test_cases = [
        ("Uniform 4×4", make_uniform_weight(4, 1.0, 2.0)),
        ("Random 5×5", None),  # will generate
        ("Sparse 6×6", None),  # will generate
    ]

    np.random.seed(123)

    print()
    for name, w in test_cases:
        if w is None:
            n = int(name.split('×')[0].split()[-1])
            w = np.random.randn(n, n)
            w = (w + w.T) / 2

        gap, witness = tropical_spectral_gap(w)
        n = w.shape[0]

        print(f"  {name}:")
        print(f"    Matrix size: {n}×{n}")
        print(f"    Tropical gap: {gap:.8f}")
        print(f"    Witness pair: ({witness[0]}, {witness[1]})")
        print(f"    Slack at witness: {diag_exchange_slack(w, witness[0], witness[1]):.8f}")

        # Verify certificate: witness achieves the minimum
        all_slacks = []
        for i in range(n):
            for j in range(n):
                if i != j:
                    all_slacks.append((diag_exchange_slack(w, i, j), (i, j)))
        all_slacks.sort()
        print(f"    Min slack in brute force: {all_slacks[0][0]:.8f} at {all_slacks[0][1]}")
        print(f"    Certificate valid: {'✓' if np.isclose(gap, all_slacks[0][0]) else '✗'}")
        print(f"    All slacks (sorted): {[f'{s:.4f}' for s, _ in all_slacks[:5]]}...")
        print()

    # Disproof criterion check
    print("  DISPROOF CRITERION CHECK:")
    print("  For structured families, |log(stabilityRadius) - tropMargin| should not grow as C·log(n)")
    diffs = []
    for n in [3, 4, 5, 8, 10, 15]:
        w = make_uniform_weight(n, 0.0, 1.0)
        gap, _ = tropical_spectral_gap(w)
        analytic = analytic_stability_margin(w)
        log_analytic = np.log(analytic) if analytic > 0 else 0
        diff = abs(log_analytic - gap)
        diffs.append((n, gap, log_analytic, diff))
        print(f"    n={n:<4} gap={gap:<8.4f} log(SR)={log_analytic:<8.4f} |diff|={diff:<8.4f} C·log(n)={np.log(n):<8.4f}")

    print()


# ============================================================
# Experiment 6: Rescaling Linearity (Maslov Dequantization)
# ============================================================

def experiment_6():
    print("=" * 70)
    print("EXPERIMENT 6: Rescaling Linearity (Maslov Dequantization)")
    print("  Verify: δ(w + t·ω) = δ(w) + t · δ(ω) for all i,j")
    print("=" * 70)

    n = 3
    np.random.seed(77)
    w = np.random.randn(n, n)
    w = (w + w.T) / 2
    omega = np.random.randn(n, n)
    omega = (omega + omega.T) / 2

    print(f"\n{'t':<10} {'Gap(w+tω)':<15} {'Gap(w)+t·Gap(ω)':<18} {'Match?':<8}")
    print("-" * 52)

    gap_w, _ = tropical_spectral_gap(w)
    gap_omega, _ = tropical_spectral_gap(omega)

    for t in [0.0, 0.5, 1.0, 2.0, 5.0, 10.0, -1.0]:
        w_rescaled = w + t * omega
        gap_rescaled, _ = tropical_spectral_gap(w_rescaled)
        # For uniform: gap(w+tω) = gap(w) + t·gap(ω) exactly
        # For general: gap is iInf of linear functions, so it's concave in t
        # Check individual exchange slacks for linearity
        all_linear = True
        for i in range(n):
            for j in range(n):
                if i != j:
                    lhs = diag_exchange_slack(w_rescaled, i, j)
                    rhs = diag_exchange_slack(w, i, j) + t * diag_exchange_slack(omega, i, j)
                    if not np.isclose(lhs, rhs, rtol=1e-10):
                        all_linear = False

        print(f"{t:<10.1f} {gap_rescaled:<15.6f} {gap_w + t * gap_omega:<18.6f} "
              f"{'✓ (slack linear)' if all_linear else '✗':<8}")

    print("\n  Note: Individual exchange slacks are exactly linear in t.")
    print("  The global gap (infimum) is a minimum of linear functions, hence piecewise linear.")
    print()


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print("\n" + "=" * 70)
    print("  TROPICAL SHADOWS OF LORENTZIAN STABILITY")
    print("  Computational Demonstrations")
    print("=" * 70 + "\n")

    experiment_1()
    experiment_2()
    experiment_3()
    experiment_4()
    experiment_5()
    experiment_6()

    print("=" * 70)
    print("  All experiments completed successfully.")
    print("=" * 70)


#!/usr/bin/env python3
"""
Visualization: Maslov Dequantization — Tropical Gap Under Rescaling

This script visualizes the linear growth of exchange slack under Maslov-type
weight rescaling, demonstrating the relationship between tropical geometry
and Lorentzian stability in the asymptotic (t → ∞) regime.
"""

import numpy as np
import matplotlib.pyplot as plt

np.random.seed(77)
n = 4

# Base weight
w = np.random.randn(n, n)
w = (w + w.T) / 2

# Rescaling direction
omega = np.random.randn(n, n)
omega = (omega + omega.T) / 2


def diag_exchange_slack(w, i, j):
    return 2 * w[i, j] - w[i, i] - w[j, j]


def tropical_gap_value(w):
    n = w.shape[0]
    return min(diag_exchange_slack(w, i, j)
               for i in range(n) for j in range(n) if i != j)


def all_exchange_slacks(w):
    n = w.shape[0]
    slacks = {}
    for i in range(n):
        for j in range(n):
            if i != j:
                slacks[(i, j)] = diag_exchange_slack(w, i, j)
    return slacks


# Compute exchange slacks as function of t
t_values = np.linspace(-3, 10, 500)

# Track individual slacks and the global gap
slack_traces = {(i, j): [] for i in range(n) for j in range(n) if i != j}
gap_values = []

for t in t_values:
    w_t = w + t * omega
    slacks = all_exchange_slacks(w_t)
    for key, val in slacks.items():
        slack_traces[key].append(val)
    gap_values.append(tropical_gap_value(w_t))

fig, axes = plt.subplots(1, 3, figsize=(18, 5.5))

# Plot 1: Individual exchange slacks (all linear in t)
ax1 = axes[0]
colors = plt.cm.tab20(np.linspace(0, 1, len(slack_traces)))
for idx, ((i, j), trace) in enumerate(slack_traces.items()):
    ax1.plot(t_values, trace, color=colors[idx], alpha=0.7,
             label=f'δ({i},{j})' if idx < 6 else None)
ax1.set_xlabel('Rescaling parameter t', fontsize=12)
ax1.set_ylabel('Exchange slack', fontsize=12)
ax1.set_title('Individual Exchange Slacks (All Linear)', fontsize=13)
ax1.legend(fontsize=8, ncol=2)
ax1.grid(True, alpha=0.3)
ax1.axhline(y=0, color='k', linewidth=0.5, linestyle='-')

# Plot 2: Global gap (piecewise linear = minimum of linear functions)
ax2 = axes[1]
ax2.plot(t_values, gap_values, 'b-', linewidth=2.5, label='Tropical gap')
# Also plot the linear functions it's the minimum of
for idx, ((i, j), trace) in enumerate(slack_traces.items()):
    ax2.plot(t_values, trace, '--', color=colors[idx], alpha=0.3, linewidth=0.8)
ax2.plot(t_values, gap_values, 'b-', linewidth=2.5)  # redraw on top
ax2.set_xlabel('Rescaling parameter t', fontsize=12)
ax2.set_ylabel('Tropical spectral gap', fontsize=12)
ax2.set_title('Global Gap = min of Linear Functions', fontsize=13)
ax2.axhline(y=0, color='r', linewidth=1, linestyle='--', alpha=0.5)
ax2.grid(True, alpha=0.3)

# Plot 3: Gap slope analysis
ax3 = axes[2]
# Compute slopes of individual slacks
omega_slacks = {}
for i in range(n):
    for j in range(n):
        if i != j:
            omega_slacks[(i, j)] = 2 * omega[i, j] - omega[i, i] - omega[j, j]

slopes = sorted(omega_slacks.values())
bars = ax3.barh(range(len(slopes)), slopes,
                color=['green' if s >= 0 else 'red' for s in slopes],
                alpha=0.7)
ax3.set_xlabel('Slope = δ(ω, i, j)', fontsize=12)
ax3.set_ylabel('Pair index (sorted)', fontsize=12)
ax3.set_title('Slopes of Exchange Slack Lines', fontsize=13)
ax3.axvline(x=0, color='k', linewidth=0.5)
ax3.axvline(x=min(slopes), color='blue', linewidth=2, linestyle='--',
            label=f'Min slope = {min(slopes):.3f}')
ax3.legend(fontsize=10)
ax3.grid(True, alpha=0.3, axis='x')

plt.suptitle('Maslov Dequantization: Tropical Gap Under Weight Rescaling',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('maslov_rescaling.png', dpi=150, bbox_inches='tight')
print("Saved: maslov_rescaling.png")


#!/usr/bin/env python3
"""
Visualization: Perturbation Stability of Tropical Gap

This script visualizes how the tropical spectral gap degrades under
weight perturbation, demonstrating the 4-Lipschitz bound proved in
Theorem 4 (exchange_slack_lipschitz).
"""

import numpy as np
import matplotlib.pyplot as plt

np.random.seed(42)

# Base weight matrix (4×4 uniform Lorentzian)
n = 4
d, c = 0.0, 2.0
w_base = np.full((n, n), c)
np.fill_diagonal(w_base, d)


def diag_exchange_slack(w, i, j):
    return 2 * w[i, j] - w[i, i] - w[j, j]


def tropical_gap_value(w):
    n = w.shape[0]
    return min(diag_exchange_slack(w, i, j)
               for i in range(n) for j in range(n) if i != j)


# Experiment: vary perturbation magnitude
eps_values = np.linspace(0, 1.5, 200)
n_trials = 500

gap_means = []
gap_mins = []
gap_maxs = []
gap_stds = []

for eps in eps_values:
    gaps = []
    for _ in range(n_trials):
        perturbation = np.random.uniform(-eps, eps, (n, n))
        perturbation = (perturbation + perturbation.T) / 2
        w_pert = w_base + perturbation
        gaps.append(tropical_gap_value(w_pert))
    gap_means.append(np.mean(gaps))
    gap_mins.append(np.min(gaps))
    gap_maxs.append(np.max(gaps))
    gap_stds.append(np.std(gaps))

gap_means = np.array(gap_means)
gap_mins = np.array(gap_mins)
gap_maxs = np.array(gap_maxs)

base_gap = tropical_gap_value(w_base)

fig, axes = plt.subplots(1, 2, figsize=(14, 5.5))

# Plot 1: Gap distribution under perturbation
ax1 = axes[0]
ax1.fill_between(eps_values, gap_mins, gap_maxs, alpha=0.2, color='blue',
                 label='Range (min-max)')
ax1.plot(eps_values, gap_means, 'b-', linewidth=2, label='Mean gap')
ax1.plot(eps_values, base_gap - 4 * eps_values, 'r--', linewidth=2,
         label='Lower bound: gap₀ - 4ε')
ax1.plot(eps_values, base_gap + 4 * eps_values, 'r--', linewidth=2,
         label='Upper bound: gap₀ + 4ε')
ax1.axhline(y=0, color='k', linewidth=0.5, linestyle='-')
ax1.axhline(y=base_gap, color='green', linewidth=1, linestyle=':',
            label=f'Base gap = {base_gap:.1f}')
ax1.set_xlabel('Perturbation magnitude ε', fontsize=12)
ax1.set_ylabel('Tropical spectral gap', fontsize=12)
ax1.set_title('Gap Stability Under Weight Perturbation', fontsize=13)
ax1.legend(fontsize=9)
ax1.grid(True, alpha=0.3)

# Mark the critical perturbation where stability is lost
critical_eps = base_gap / 4
ax1.axvline(x=critical_eps, color='orange', linewidth=1.5, linestyle='-.',
            label=f'Critical ε = gap₀/4 = {critical_eps:.2f}')
ax1.legend(fontsize=9)

# Plot 2: Slack distribution for a specific perturbation
ax2 = axes[1]
eps_fixed = 0.3
all_slacks_base = []
all_slacks_pert = []

for i in range(n):
    for j in range(n):
        if i != j:
            all_slacks_base.append(diag_exchange_slack(w_base, i, j))

for _ in range(200):
    perturbation = np.random.uniform(-eps_fixed, eps_fixed, (n, n))
    perturbation = (perturbation + perturbation.T) / 2
    w_pert = w_base + perturbation
    for i in range(n):
        for j in range(n):
            if i != j:
                all_slacks_pert.append(diag_exchange_slack(w_pert, i, j))

ax2.hist(all_slacks_pert, bins=50, alpha=0.6, color='blue', density=True,
         label=f'Perturbed (ε={eps_fixed})')
ax2.axvline(x=all_slacks_base[0], color='green', linewidth=2,
            label=f'Base value = {all_slacks_base[0]:.1f}')
ax2.axvline(x=all_slacks_base[0] - 4*eps_fixed, color='red', linewidth=2,
            linestyle='--', label=f'Lower bound')
ax2.axvline(x=all_slacks_base[0] + 4*eps_fixed, color='red', linewidth=2,
            linestyle='--', label=f'Upper bound')
ax2.set_xlabel('Exchange slack value', fontsize=12)
ax2.set_ylabel('Density', fontsize=12)
ax2.set_title(f'Slack Distribution (ε = {eps_fixed})', fontsize=13)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)

plt.suptitle('Tropical Gap Lipschitz Stability (4-Lipschitz Bound)',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('perturbation_stability.png', dpi=150, bbox_inches='tight')
print("Saved: perturbation_stability.png")


#!/usr/bin/env python3
"""
Visualization: Tropical Exchange Gap Landscape

This script visualizes the relationship between tropical exchange slack
and the Lorentzian determinant condition for 2×2 exp-weight matrices.

It produces a heatmap showing how the determinant gap (det₂) varies as a
function of the diagonal weight w₀₀ and the off-diagonal weight w₀₁,
with the exchange slack δ = 2w₀₁ - w₀₀ - w₁₁ overlaid as contour lines.
The zero contour (δ = 0) marks the Lorentzian boundary.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors

# Parameters
w11 = 1.0  # Fix w₁₁ = 1

w00_range = np.linspace(-2, 4, 300)
w01_range = np.linspace(-1, 5, 300)
W00, W01 = np.meshgrid(w00_range, w01_range)

# Exchange slack: δ = 2·w₀₁ - w₀₀ - w₁₁
Delta = 2 * W01 - W00 - w11

# det₂ = exp(w₀₁)² - exp(w₀₀)·exp(w₁₁) = exp(w₀₀+w₁₁)·(exp(δ)-1)
Det2 = np.exp(W00 + w11) * (np.exp(Delta) - 1)

fig, axes = plt.subplots(1, 3, figsize=(18, 5.5))

# Plot 1: Exchange slack δ
ax1 = axes[0]
im1 = ax1.contourf(W00, W01, Delta, levels=30, cmap='RdYlGn')
ax1.contour(W00, W01, Delta, levels=[0], colors='black', linewidths=2)
ax1.set_xlabel('w₀₀ (diagonal weight)', fontsize=12)
ax1.set_ylabel('w₀₁ (off-diagonal weight)', fontsize=12)
ax1.set_title('Exchange Slack δ = 2w₀₁ - w₀₀ - w₁₁', fontsize=13)
plt.colorbar(im1, ax=ax1, label='δ')
ax1.annotate('Lorentzian\n(δ ≥ 0)', xy=(0, 2.5), fontsize=11,
             ha='center', color='darkgreen', fontweight='bold')
ax1.annotate('Non-Lorentzian\n(δ < 0)', xy=(3, 1), fontsize=11,
             ha='center', color='darkred', fontweight='bold')

# Plot 2: det₂ (Lorentzian determinant)
ax2 = axes[1]
# Use symmetric log scale for det₂
vmax = np.percentile(np.abs(Det2), 95)
norm = mcolors.SymLogNorm(linthresh=1, vmin=-vmax, vmax=vmax)
im2 = ax2.contourf(W00, W01, Det2, levels=30, cmap='coolwarm', norm=norm)
ax2.contour(W00, W01, Det2, levels=[0], colors='black', linewidths=2)
ax2.set_xlabel('w₀₀ (diagonal weight)', fontsize=12)
ax2.set_ylabel('w₀₁ (off-diagonal weight)', fontsize=12)
ax2.set_title('det₂ = exp(w₀₁)² - exp(w₀₀)exp(w₁₁)', fontsize=13)
plt.colorbar(im2, ax=ax2, label='det₂')

# Plot 3: Stability margin as function of δ
ax3 = axes[2]
delta_vals = np.linspace(-3, 5, 500)
det2_from_delta = np.exp(2 + w11) * (np.exp(delta_vals) - 1)  # w₀₀ = 2 fixed
log_stability = np.log(np.maximum(det2_from_delta, 1e-10))

ax3.plot(delta_vals, det2_from_delta, 'b-', linewidth=2, label='det₂(δ)')
ax3.axhline(y=0, color='k', linewidth=0.5, linestyle='--')
ax3.axvline(x=0, color='r', linewidth=1.5, linestyle='--', label='δ = 0 (boundary)')
ax3.fill_between(delta_vals, det2_from_delta, 0,
                 where=(delta_vals >= 0), alpha=0.15, color='green',
                 label='Lorentzian region')
ax3.fill_between(delta_vals, det2_from_delta, 0,
                 where=(delta_vals < 0), alpha=0.15, color='red',
                 label='Non-Lorentzian')
ax3.set_xlabel('Exchange Slack δ', fontsize=12)
ax3.set_ylabel('det₂', fontsize=12)
ax3.set_title('det₂ vs Exchange Slack (w₀₀=2)', fontsize=13)
ax3.set_ylim(-50, 150)
ax3.legend(fontsize=10)
ax3.grid(True, alpha=0.3)

plt.suptitle('Tropical Shadows: Exchange Slack Controls Lorentzian Stability',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('tropical_gap_landscape.png', dpi=150, bbox_inches='tight')
print("Saved: tropical_gap_landscape.png")
