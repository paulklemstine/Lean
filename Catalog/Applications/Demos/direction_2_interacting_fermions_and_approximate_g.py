#!/usr/bin/env python3
"""
Applications of Entropy Stability Theory for Approximate Gaussianity

Demonstrates real-world applications:
1. DMRG benchmarking: certify entropy error bars from numerical simulations
2. Hubbard chain: weak interaction entropy bounds
3. Mean-field certification: validate mean-field approximation quality
4. Tensor network certification: entropy bounds from approximate spectra
"""

import numpy as np
from typing import List, Tuple
from math import comb


def binary_entropy(x: float) -> float:
    if x <= 0 or x >= 1:
        return 0.0
    return -x * np.log(x) - (1 - x) * np.log(1 - x)


def region_entropy(spectrum: np.ndarray) -> float:
    return sum(binary_entropy(x) for x in spectrum)


def entropy_stability_constant(delta: float) -> float:
    return np.log((1 - delta) / delta)


def entropy_certificate(m, delta, eta, spec0):
    S0 = region_entropy(spec0)
    correction = m * entropy_stability_constant(delta) * eta
    return (S0 - correction, S0 + correction)


# ============================================================
# Application 1: DMRG Benchmarking
# ============================================================
def dmrg_entropy_certification(
    numerical_spectrum: np.ndarray,
    numerical_accuracy: float,
    spectral_gap: float = 0.05,
) -> dict:
    """
    Certify entropy error bars for DMRG numerical simulations.

    In DMRG (Density Matrix Renormalization Group), the correlation
    matrix eigenvalues are computed numerically with finite precision.
    This function provides rigorous error bars on the entanglement
    entropy using the formally verified stability theorem.

    Args:
        numerical_spectrum: Numerically computed eigenvalues.
        numerical_accuracy: Maximum error in each eigenvalue.
        spectral_gap: Minimum distance from 0 and 1.

    Returns:
        Dictionary with entropy bounds and certificate.
    """
    m = len(numerical_spectrum)
    S_numerical = region_entropy(numerical_spectrum)
    lo, hi = entropy_certificate(m, spectral_gap, numerical_accuracy, numerical_spectrum)
    L = entropy_stability_constant(spectral_gap)

    return {
        "m": m,
        "numerical_entropy": S_numerical,
        "certified_lower": lo,
        "certified_upper": hi,
        "certificate_width": hi - lo,
        "lipschitz_constant": L,
        "max_error_per_mode": numerical_accuracy,
        "relative_uncertainty": (hi - lo) / S_numerical if S_numerical > 0 else float('inf'),
    }


# ============================================================
# Application 2: Hubbard Chain Simulation
# ============================================================
def hubbard_chain_entropy_bound(
    m: int,
    free_spectrum: np.ndarray,
    interaction_strength: float,
    spectral_gap: float = 0.1,
) -> dict:
    """
    Entropy bound for a weakly interacting Hubbard chain.

    For a 1D Hubbard model with hopping t and interaction U,
    the free-fermion (U=0) spectrum is known exactly. For small U/t,
    the eigenvalue perturbation is bounded by C * U/t.

    This function computes the certified entropy interval using
    the formally verified approximate Gaussianity theorem.

    Args:
        m: Subsystem size (number of sites).
        free_spectrum: Free-fermion eigenvalues (U=0 case).
        interaction_strength: U/t ratio.
        spectral_gap: Minimum eigenvalue gap from 0 and 1.

    Returns:
        Dictionary with entropy analysis.
    """
    # In first-order perturbation theory, eigenvalue shift ~ C0 * U/t
    C0 = 1.0  # Conservative bound for weak coupling
    epsilon = C0 * interaction_strength

    S_free = region_entropy(free_spectrum)
    L = entropy_stability_constant(spectral_gap)
    correction = m * L * epsilon

    # Simulate interacting spectrum (toy model)
    np.random.seed(42)
    perturbation = np.random.uniform(-epsilon, epsilon, m)
    interacting_spectrum = np.clip(free_spectrum + perturbation,
                                    spectral_gap, 1 - spectral_gap)
    S_interacting = region_entropy(interacting_spectrum)

    return {
        "m": m,
        "interaction_strength": interaction_strength,
        "free_entropy": S_free,
        "interacting_entropy": S_interacting,
        "certified_upper_bound": S_free + correction,
        "correction_term": correction,
        "entropy_difference": abs(S_interacting - S_free),
        "bound_holds": S_interacting <= S_free + correction + 1e-10,
        "correction_per_site": correction / m if m > 0 else 0,
    }


# ============================================================
# Application 3: Mean-Field Certification
# ============================================================
def mean_field_certification(
    exact_spectrum: np.ndarray,
    mean_field_spectrum: np.ndarray,
    spectral_gap: float = 0.1,
) -> dict:
    """
    Validate mean-field approximation quality using entropy stability.

    Compares the exact many-body spectrum with a mean-field approximation
    and certifies how much entropy can differ.

    Args:
        exact_spectrum: Exact eigenvalues (from ED or high-accuracy numerics).
        mean_field_spectrum: Mean-field approximation eigenvalues.
        spectral_gap: Minimum gap from spectral edges.

    Returns:
        Dictionary with validation results.
    """
    m = len(exact_spectrum)
    assert len(mean_field_spectrum) == m

    # Compute actual perturbation
    max_perturbation = np.max(np.abs(exact_spectrum - mean_field_spectrum))
    l1_perturbation = np.sum(np.abs(exact_spectrum - mean_field_spectrum))

    S_exact = region_entropy(exact_spectrum)
    S_mf = region_entropy(mean_field_spectrum)
    L = entropy_stability_constant(spectral_gap)

    # Sup-norm bound
    sup_bound = m * L * max_perturbation
    # L1 bound (tighter when perturbation is localized)
    l1_bound = L * l1_perturbation

    return {
        "m": m,
        "exact_entropy": S_exact,
        "mean_field_entropy": S_mf,
        "actual_entropy_diff": abs(S_exact - S_mf),
        "sup_norm_bound": sup_bound,
        "l1_bound": l1_bound,
        "max_eigenvalue_diff": max_perturbation,
        "l1_eigenvalue_diff": l1_perturbation,
        "mean_field_quality": 1 - abs(S_exact - S_mf) / S_exact if S_exact > 0 else 1.0,
        "sup_bound_holds": abs(S_exact - S_mf) <= sup_bound + 1e-10,
        "l1_bound_holds": abs(S_exact - S_mf) <= l1_bound + 1e-10,
    }


# ============================================================
# Application 4: Tensor Network Output Certification
# ============================================================
def tensor_network_certification(
    approximate_spectrum: np.ndarray,
    truncation_error: float,
    bond_dimension: int,
    spectral_gap: float = 0.05,
) -> dict:
    """
    Certify entropy from tensor network approximate spectra.

    Tensor network methods (MPS, MERA, PEPS) compute approximate
    correlation matrices with controlled truncation errors. This
    function provides certified entropy intervals.

    Args:
        approximate_spectrum: Spectrum from tensor network computation.
        truncation_error: Bound on per-eigenvalue error from truncation.
        bond_dimension: Bond dimension used (for reporting).
        spectral_gap: Spectral gap parameter.

    Returns:
        Dictionary with certification results.
    """
    m = len(approximate_spectrum)
    lo, hi = entropy_certificate(m, spectral_gap, truncation_error,
                                  approximate_spectrum)
    S_approx = region_entropy(approximate_spectrum)

    return {
        "m": m,
        "bond_dimension": bond_dimension,
        "approximate_entropy": S_approx,
        "certified_lower": lo,
        "certified_upper": hi,
        "certificate_width": hi - lo,
        "truncation_error": truncation_error,
        "relative_width": (hi - lo) / S_approx if S_approx > 0 else float('inf'),
    }


# ============================================================
# Main: Run all applications
# ============================================================
if __name__ == "__main__":
    print("=" * 70)
    print("APPLICATIONS: Entropy Stability for Quantum Many-Body Systems")
    print("=" * 70)

    # Application 1: DMRG
    print("\n--- Application 1: DMRG Entropy Certification ---")
    spectrum_dmrg = np.array([0.12, 0.28, 0.45, 0.52, 0.67, 0.78, 0.88, 0.35])
    result = dmrg_entropy_certification(spectrum_dmrg, numerical_accuracy=0.001, spectral_gap=0.05)
    for k, v in result.items():
        print(f"  {k}: {v}")

    # Application 2: Hubbard Chain
    print("\n--- Application 2: Hubbard Chain Entropy Bounds ---")
    m = 10
    # Free fermion spectrum for a 1D tight-binding chain
    k_vals = np.pi * np.arange(1, m + 1) / (m + 1)
    free_spec = 0.5 * (1 - np.cos(k_vals))  # Occupation numbers
    free_spec = np.clip(free_spec, 0.1, 0.9)  # Ensure gap

    for U_over_t in [0.01, 0.05, 0.1, 0.5]:
        result = hubbard_chain_entropy_bound(m, free_spec, U_over_t, spectral_gap=0.1)
        print(f"\n  U/t = {U_over_t}:")
        print(f"    Free entropy:     {result['free_entropy']:.6f}")
        print(f"    Correction term:  {result['correction_term']:.6f}")
        print(f"    Upper bound:      {result['certified_upper_bound']:.6f}")
        print(f"    Bound holds:      {result['bound_holds']}")

    # Application 3: Mean-Field
    print("\n--- Application 3: Mean-Field Certification ---")
    np.random.seed(42)
    exact_spec = np.array([0.15, 0.32, 0.48, 0.55, 0.71, 0.85])
    mf_spec = exact_spec + np.random.normal(0, 0.02, len(exact_spec))
    mf_spec = np.clip(mf_spec, 0.1, 0.9)
    result = mean_field_certification(exact_spec, mf_spec, spectral_gap=0.1)
    for k, v in result.items():
        print(f"  {k}: {v}")

    # Application 4: Tensor Network
    print("\n--- Application 4: Tensor Network Certification ---")
    for chi in [10, 50, 100, 500]:
        trunc_error = 0.1 / chi  # Error decreases with bond dimension
        tn_spec = np.array([0.2, 0.35, 0.5, 0.65, 0.8])
        result = tensor_network_certification(tn_spec, trunc_error, chi, spectral_gap=0.1)
        print(f"\n  Bond dimension χ = {chi}:")
        print(f"    Truncation error: {result['truncation_error']:.6f}")
        print(f"    Certificate width: {result['certificate_width']:.6f}")
        print(f"    Relative width: {result['relative_width']:.4f}")

    print("\n" + "=" * 70)
    print("All applications completed successfully!")


#!/usr/bin/env python3
"""
Demonstration: Entropy Stability for Approximately Gaussian Fermionic States

This demo illustrates the main theorems:
1. Binary entropy Lipschitz continuity on compact intervals
2. Entropy stability under eigenvalue perturbation
3. Certified entropy intervals for weakly interacting systems
4. Scaling of certificate width with subsystem size m, gap δ, and perturbation ε

Run: python demo.py
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def binary_entropy(x):
    """h(x) = -x log(x) - (1-x) log(1-x), with h(0)=h(1)=0."""
    x = np.asarray(x, dtype=float)
    result = np.zeros_like(x)
    mask = (x > 0) & (x < 1)
    xm = x[mask]
    result[mask] = -xm * np.log(xm) - (1 - xm) * np.log(1 - xm)
    return result


def region_entropy(spec):
    """S(spec) = sum_i h(spec_i)."""
    return np.sum(binary_entropy(spec))


def entropy_stability_constant(delta):
    """L_delta = log((1-delta)/delta)."""
    return np.log((1 - delta) / delta)


def entropy_certificate(m, delta, eta, spec0):
    """Certified interval [lo, hi] for entropy of any spectrum within eta of spec0."""
    S0 = region_entropy(spec0)
    correction = m * entropy_stability_constant(delta) * eta
    return (S0 - correction, S0 + correction)


def elem_symm(k, spec):
    """k-th elementary symmetric polynomial of spec."""
    from itertools import combinations
    m = len(spec)
    if k > m or k < 0:
        return 0.0
    if k == 0:
        return 1.0
    return sum(np.prod([spec[i] for i in S]) for S in combinations(range(m), k))


# ============================================================
# Demo 1: Binary entropy and its Lipschitz bound
# ============================================================
print("=" * 60)
print("DEMO 1: Binary Entropy Lipschitz Continuity")
print("=" * 60)

delta = 0.1
x_vals = np.linspace(0.001, 0.999, 500)
h_vals = binary_entropy(x_vals)
L_delta = entropy_stability_constant(delta)

# Derivative h'(x) = log((1-x)/x)
x_interior = np.linspace(delta, 1 - delta, 300)
h_deriv = np.log((1 - x_interior) / x_interior)

print(f"  δ = {delta}")
print(f"  L_δ = log((1-δ)/δ) = {L_delta:.4f}")
print(f"  Max |h'(x)| on [{delta}, {1-delta}] = {np.max(np.abs(h_deriv)):.4f}")
print(f"  Bound matches: {np.max(np.abs(h_deriv)) <= L_delta + 1e-10}")

# Test Lipschitz bound
x_test, y_test = 0.3, 0.7
lip_lhs = abs(binary_entropy(x_test) - binary_entropy(y_test))
lip_rhs = L_delta * abs(x_test - y_test)
print(f"\n  Example: |h({x_test}) - h({y_test})| = {lip_lhs:.6f}")
print(f"           L_δ · |{x_test} - {y_test}| = {lip_rhs:.6f}")
print(f"           Bound holds: {lip_lhs <= lip_rhs + 1e-10}")

# ============================================================
# Demo 2: Entropy stability under perturbation
# ============================================================
print("\n" + "=" * 60)
print("DEMO 2: Entropy Stability Under Eigenvalue Perturbation")
print("=" * 60)

m = 10
delta = 0.1
np.random.seed(42)
spec0 = np.random.uniform(delta, 1 - delta, m)
S0 = region_entropy(spec0)
print(f"  Subsystem size m = {m}")
print(f"  Reference entropy S(spec0) = {S0:.6f}")

for eta in [0.01, 0.05, 0.1]:
    # Generate 1000 random perturbations
    max_diff = 0
    for _ in range(1000):
        perturbation = np.random.uniform(-eta, eta, m)
        spec = np.clip(spec0 + perturbation, delta, 1 - delta)
        S = region_entropy(spec)
        max_diff = max(max_diff, abs(S - S0))

    bound = m * L_delta * eta
    print(f"\n  η = {eta}:")
    print(f"    Max observed |S - S0| = {max_diff:.6f}")
    print(f"    Theorem bound m·L_δ·η = {bound:.6f}")
    print(f"    Bound holds: {max_diff <= bound + 1e-10}")

# ============================================================
# Demo 3: Certified entropy intervals
# ============================================================
print("\n" + "=" * 60)
print("DEMO 3: Certified Entropy Intervals")
print("=" * 60)

m = 8
delta = 0.15
eta = 0.05
spec0 = np.array([0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.35])
S0 = region_entropy(spec0)
lo, hi = entropy_certificate(m, delta, eta, spec0)

print(f"  m = {m}, δ = {delta}, η = {eta}")
print(f"  Reference spectrum: {spec0}")
print(f"  Reference entropy S0 = {S0:.6f}")
print(f"  Certified interval: [{lo:.6f}, {hi:.6f}]")
print(f"  Certificate width: {hi - lo:.6f}")

# Verify with random samples
n_samples = 10000
all_in = True
for _ in range(n_samples):
    perturbation = np.random.uniform(-eta, eta, m)
    spec = np.clip(spec0 + perturbation, delta, 1 - delta)
    S = region_entropy(spec)
    if S < lo - 1e-10 or S > hi + 1e-10:
        all_in = False
        break
print(f"  All {n_samples} random samples in interval: {all_in}")

# ============================================================
# Demo 4: Scaling with m, δ, and ε
# ============================================================
print("\n" + "=" * 60)
print("DEMO 4: Certificate Width Scaling")
print("=" * 60)

# Scaling with m
print("\n  Scaling with subsystem size m (δ=0.1, η=0.05):")
delta_fixed = 0.1
eta_fixed = 0.05
for m_val in [2, 5, 10, 20, 50, 100]:
    width = 2 * m_val * entropy_stability_constant(delta_fixed) * eta_fixed
    print(f"    m = {m_val:3d}: width = {width:.4f} (ratio width/m = {width/m_val:.4f})")

# Scaling with epsilon
print("\n  Scaling with perturbation ε (m=10, δ=0.1):")
m_fixed = 10
for eps_val in [0.001, 0.01, 0.05, 0.1, 0.2]:
    width = 2 * m_fixed * entropy_stability_constant(delta_fixed) * eps_val
    print(f"    ε = {eps_val:.3f}: width = {width:.4f}")

# Scaling with delta
print("\n  Scaling with spectral gap δ (m=10, η=0.05):")
for delta_val in [0.01, 0.05, 0.1, 0.2, 0.4, 0.49]:
    L = entropy_stability_constant(delta_val)
    width = 2 * m_fixed * L * eta_fixed
    print(f"    δ = {delta_val:.2f}: L_δ = {L:.4f}, width = {width:.4f}")

# ============================================================
# Demo 5: Elementary symmetric polynomial stability
# ============================================================
print("\n" + "=" * 60)
print("DEMO 5: Elementary Symmetric Polynomial Stability")
print("=" * 60)

m = 6
eta = 0.05
np.random.seed(123)
spec0 = np.random.uniform(0.1, 0.9, m)
print(f"  m = {m}, η = {eta}")

for k in range(m + 1):
    e0 = elem_symm(k, spec0)
    max_diff = 0
    from math import comb
    for _ in range(5000):
        perturbation = np.random.uniform(-eta, eta, m)
        spec = np.clip(spec0 + perturbation, 0, 1)
        e = elem_symm(k, spec)
        max_diff = max(max_diff, abs(e - e0))

    bound = comb(m, k) * k * eta
    print(f"  k={k}: |e_k(spec)-e_k(spec0)| ≤ {max_diff:.6f}, bound = {bound:.6f}, "
          f"holds = {max_diff <= bound + 1e-8}")

# ============================================================
# Demo 6: Conjecture test — m log m correction
# ============================================================
print("\n" + "=" * 60)
print("DEMO 6: Conjecture Test — m·log(m+1) Correction")
print("=" * 60)

eps_values = [0.01, 0.05, 0.1]
m_values = [2, 4, 8, 16, 32]

print("  Testing (S_int - S_free) / (ε·m) vs log(m+1):")
for eps in eps_values:
    print(f"\n  ε = {eps}:")
    for m_val in m_values:
        delta = 0.15
        spec0 = np.random.uniform(delta + 0.05, 1 - delta - 0.05, m_val)
        perturbation = np.random.uniform(-eps, eps, m_val)
        spec = np.clip(spec0 + perturbation, delta, 1 - delta)
        S_free = region_entropy(spec0)
        S_int = region_entropy(spec)
        ratio = abs(S_int - S_free) / (eps * m_val) if eps * m_val > 0 else 0
        log_bound = np.log(m_val + 1)
        print(f"    m={m_val:2d}: ratio = {ratio:.4f}, log(m+1) = {log_bound:.4f}, "
              f"ratio < log(m+1): {ratio < log_bound}")

# ============================================================
# Generate visualization
# ============================================================
fig, axes = plt.subplots(2, 2, figsize=(12, 10))

# Plot 1: Binary entropy and Lipschitz bound
ax = axes[0, 0]
x_plot = np.linspace(0.001, 0.999, 500)
ax.plot(x_plot, binary_entropy(x_plot), 'b-', linewidth=2, label='h(x)')
for d in [0.1, 0.2, 0.3]:
    ax.axvline(d, color='gray', linestyle='--', alpha=0.3)
    ax.axvline(1 - d, color='gray', linestyle='--', alpha=0.3)
ax.set_xlabel('x')
ax.set_ylabel('h(x)')
ax.set_title('Binary Entropy Function')
ax.legend()
ax.grid(True, alpha=0.3)

# Plot 2: Derivative bound
ax = axes[0, 1]
x_int = np.linspace(0.05, 0.95, 500)
ax.plot(x_int, np.log((1 - x_int) / x_int), 'r-', linewidth=2, label="|h'(x)|")
for d in [0.1, 0.2]:
    L = entropy_stability_constant(d)
    ax.axhline(L, linestyle='--', label=f'L_{{δ={d}}} = {L:.2f}')
    ax.axhline(-L, linestyle='--', alpha=0.3)
ax.set_xlabel('x')
ax.set_ylabel("h'(x)")
ax.set_title("Derivative h'(x) = log((1-x)/x)")
ax.legend()
ax.grid(True, alpha=0.3)

# Plot 3: Certificate width vs m
ax = axes[1, 0]
m_range = np.arange(1, 101)
for d in [0.05, 0.1, 0.2]:
    L = entropy_stability_constant(d)
    widths = 2 * m_range * L * 0.05
    ax.plot(m_range, widths, linewidth=2, label=f'δ = {d}')
ax.set_xlabel('Subsystem size m')
ax.set_ylabel('Certificate width')
ax.set_title('Certificate Width vs m (η=0.05)')
ax.legend()
ax.grid(True, alpha=0.3)

# Plot 4: Certificate width vs epsilon
ax = axes[1, 1]
eps_range = np.linspace(0, 0.2, 100)
for m_val in [5, 10, 20]:
    L = entropy_stability_constant(0.1)
    widths = 2 * m_val * L * eps_range
    ax.plot(eps_range, widths, linewidth=2, label=f'm = {m_val}')
ax.set_xlabel('Perturbation ε')
ax.set_ylabel('Certificate width')
ax.set_title('Certificate Width vs ε (δ=0.1)')
ax.legend()
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('entropy_stability_demo.png', dpi=150, bbox_inches='tight')
print("\nVisualization saved to entropy_stability_demo.png")
print("\nAll demos completed successfully!")


#!/usr/bin/env python3
"""
Visualization 3: 3D Certificate Surface and Application Landscape

Visualizes:
- 3D surface of certificate width as a function of (m, delta)
- Application landscape: different physical regimes
- Comparison across interaction strengths
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D


def binary_entropy(x):
    x = np.asarray(x, dtype=float)
    result = np.zeros_like(x)
    mask = (x > 0) & (x < 1)
    xm = x[mask]
    result[mask] = -xm * np.log(xm) - (1 - xm) * np.log(1 - xm)
    return result


def region_entropy(spec):
    return np.sum(binary_entropy(spec))


def entropy_stability_constant(delta):
    return np.log((1 - delta) / delta)


fig = plt.figure(figsize=(18, 12))

# Panel 1: 3D surface of certificate width
ax = fig.add_subplot(2, 2, 1, projection='3d')
m_range = np.arange(1, 41)
delta_range = np.linspace(0.02, 0.48, 40)
M, D = np.meshgrid(m_range, delta_range)
eta_fixed = 0.05
L_vals = np.log((1 - D) / D)
W = 2 * M * L_vals * eta_fixed

surf = ax.plot_surface(M, D, W, cmap='viridis', alpha=0.8, edgecolor='none')
ax.set_xlabel('Subsystem size m', fontsize=10)
ax.set_ylabel('Spectral gap δ', fontsize=10)
ax.set_zlabel('Certificate width', fontsize=10)
ax.set_title('Certificate Width Surface\n(η = 0.05)', fontsize=12, fontweight='bold')
ax.view_init(elev=25, azim=135)

# Panel 2: Physical regime map
ax = fig.add_subplot(2, 2, 2)
# Different physical regimes with typical (delta, epsilon) values
regimes = {
    'Metal\n(gapless)': (0.05, 0.1, 'red'),
    'Weak Mott\ninsulator': (0.2, 0.05, 'blue'),
    'Strong\ninsulator': (0.4, 0.02, 'green'),
    'Near\nhalf-filling': (0.1, 0.08, 'orange'),
    'Superconductor': (0.15, 0.03, 'purple'),
}

for name, (d, e, color) in regimes.items():
    L = entropy_stability_constant(d)
    m_example = 20
    width = 2 * m_example * L * e
    ax.scatter(d, e, s=200, c=color, zorder=5, edgecolors='black')
    ax.annotate(f'{name}\nwidth={width:.2f}', (d, e),
                textcoords="offset points", xytext=(15, 5),
                fontsize=8, color=color)

# Background: contour of certificate width
d_bg = np.linspace(0.01, 0.49, 100)
e_bg = np.linspace(0.001, 0.15, 100)
D_bg, E_bg = np.meshgrid(d_bg, e_bg)
W_bg = 2 * 20 * np.log((1 - D_bg) / D_bg) * E_bg
cs = ax.contourf(D_bg, E_bg, W_bg, levels=20, cmap='YlOrRd', alpha=0.3)
plt.colorbar(cs, ax=ax, label='Certificate width (m=20)')
ax.contour(D_bg, E_bg, W_bg, levels=[1, 2, 5, 10], colors='gray', linewidths=0.5)
ax.set_xlabel('Spectral gap δ', fontsize=12)
ax.set_ylabel('Interaction ε', fontsize=12)
ax.set_title('Physical Regime Map', fontsize=13, fontweight='bold')
ax.grid(True, alpha=0.3)

# Panel 3: Entropy vs interaction strength for different m
ax = fig.add_subplot(2, 2, 3)
delta = 0.15
np.random.seed(42)

for m_val, color in [(4, 'blue'), (8, 'green'), (16, 'red'), (32, 'purple')]:
    spec0 = np.random.uniform(delta + 0.05, 1 - delta - 0.05, m_val)
    S0 = region_entropy(spec0)
    max_ent = m_val * np.log(2)

    eps_range = np.linspace(0, 0.2, 40)
    upper_bounds = []
    actual_maxes = []

    for eps in eps_range:
        L = entropy_stability_constant(delta)
        upper = S0 + m_val * L * eps
        upper_bounds.append(min(upper, max_ent))

        # Sample actual maximum
        max_s = S0
        for _ in range(100):
            pert = np.random.uniform(-eps, eps, m_val)
            spec = np.clip(spec0 + pert, delta, 1 - delta)
            max_s = max(max_s, region_entropy(spec))
        actual_maxes.append(max_s)

    ax.plot(eps_range, upper_bounds, '-', color=color, linewidth=2,
            label=f'm={m_val} bound')
    ax.plot(eps_range, actual_maxes, '--', color=color, linewidth=1, alpha=0.7)
    ax.axhline(max_ent, color=color, linestyle=':', alpha=0.3)

ax.set_xlabel('Interaction ε', fontsize=12)
ax.set_ylabel('Entropy', fontsize=12)
ax.set_title('Entropy Bound vs Interaction (δ=0.15)', fontsize=13, fontweight='bold')
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# Panel 4: Transfer theorem illustration
ax = fig.add_subplot(2, 2, 4)
m_val = 12
delta = 0.15
np.random.seed(42)
spec0 = np.random.uniform(delta + 0.05, 1 - delta - 0.05, m_val)
S_free = region_entropy(spec0)

# Free bound from variance lower bound
variance = sum(spec0[i] * (1 - spec0[i]) for i in range(m_val))
free_lower = 2 * variance
free_upper = m_val * np.log(2)

eps_range = np.linspace(0, 0.15, 50)
L = entropy_stability_constant(delta)

ax.axhline(S_free, color='blue', linewidth=2, label=f'S_free = {S_free:.3f}')
ax.axhline(free_upper, color='gray', linestyle=':', alpha=0.5,
           label=f'm·log2 = {free_upper:.3f}')

# Correction
corrections = m_val * L * eps_range
ax.fill_between(eps_range, S_free - corrections, S_free + corrections,
                alpha=0.2, color='red', label='Certified interval')
ax.plot(eps_range, S_free + corrections, 'r-', linewidth=2,
        label='Upper bound: S_free + m·L_δ·ε')

# Sample points
for eps in [0.03, 0.06, 0.1]:
    entropies = []
    for _ in range(200):
        pert = np.random.uniform(-eps, eps, m_val)
        spec = np.clip(spec0 + pert, delta, 1 - delta)
        entropies.append(region_entropy(spec))
    ax.scatter([eps] * len(entropies), entropies, s=3, alpha=0.3, c='green')

ax.set_xlabel('Interaction ε', fontsize=12)
ax.set_ylabel('Entropy', fontsize=12)
ax.set_title('Transfer Theorem: Free → Interacting', fontsize=13, fontweight='bold')
ax.legend(fontsize=9, loc='upper left')
ax.grid(True, alpha=0.3)

plt.suptitle('Certificate Surface and Application Landscape',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_certificate_3d.png', dpi=150, bbox_inches='tight')
print("Saved viz_certificate_3d.png")


#!/usr/bin/env python3
"""
Visualization 1: Entropy Stability Landscape

Visualizes the binary entropy function, its Lipschitz bounds, and the
certified entropy intervals as a function of spectral gap and perturbation.
Shows how the entropy stability constant L_delta diverges as delta -> 0.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import FancyBboxPatch


def binary_entropy(x):
    x = np.asarray(x, dtype=float)
    result = np.zeros_like(x)
    mask = (x > 0) & (x < 1)
    xm = x[mask]
    result[mask] = -xm * np.log(xm) - (1 - xm) * np.log(1 - xm)
    return result


def entropy_stability_constant(delta):
    return np.log((1 - delta) / delta)


fig, axes = plt.subplots(2, 3, figsize=(18, 11))

# Panel 1: Binary entropy with Lipschitz cones
ax = axes[0, 0]
x = np.linspace(0.001, 0.999, 500)
ax.plot(x, binary_entropy(x), 'b-', linewidth=2.5, label='h(x)')
ax.axhline(np.log(2), color='orange', linestyle='--', alpha=0.7, label='log 2')

# Draw Lipschitz cone at x=0.3 for delta=0.15
x0, delta = 0.3, 0.15
L = entropy_stability_constant(delta)
h0 = binary_entropy(np.array([x0]))[0]
x_cone = np.linspace(delta, 1-delta, 100)
upper_cone = h0 + L * np.abs(x_cone - x0)
lower_cone = h0 - L * np.abs(x_cone - x0)
ax.fill_between(x_cone, np.maximum(lower_cone, 0), upper_cone,
                alpha=0.15, color='red', label=f'Lipschitz cone (δ={delta})')
ax.plot(x0, h0, 'ro', markersize=8, zorder=5)
ax.axvline(delta, color='gray', linestyle=':', alpha=0.5)
ax.axvline(1-delta, color='gray', linestyle=':', alpha=0.5)
ax.set_xlabel('x', fontsize=12)
ax.set_ylabel('h(x)', fontsize=12)
ax.set_title('Binary Entropy with Lipschitz Cone', fontsize=13, fontweight='bold')
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)
ax.set_xlim(0, 1)
ax.set_ylim(-0.05, 0.85)

# Panel 2: Derivative and bounds
ax = axes[0, 1]
x_int = np.linspace(0.02, 0.98, 500)
deriv = np.log((1 - x_int) / x_int)
ax.plot(x_int, deriv, 'b-', linewidth=2, label="h'(x) = log((1-x)/x)")
for d, color in [(0.05, 'red'), (0.1, 'green'), (0.2, 'purple')]:
    L = entropy_stability_constant(d)
    ax.axhline(L, color=color, linestyle='--', alpha=0.7, label=f'L_{{δ={d}}} = {L:.2f}')
    ax.axhline(-L, color=color, linestyle='--', alpha=0.3)
    ax.axvline(d, color=color, linestyle=':', alpha=0.3)
    ax.axvline(1-d, color=color, linestyle=':', alpha=0.3)
ax.axhline(0, color='black', linewidth=0.5)
ax.set_xlabel('x', fontsize=12)
ax.set_ylabel("h'(x)", fontsize=12)
ax.set_title("Derivative Bound Controls Stability", fontsize=13, fontweight='bold')
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# Panel 3: L_delta vs delta
ax = axes[0, 2]
delta_range = np.linspace(0.01, 0.49, 200)
L_vals = [entropy_stability_constant(d) for d in delta_range]
ax.plot(delta_range, L_vals, 'b-', linewidth=2.5)
ax.set_xlabel('δ (spectral gap)', fontsize=12)
ax.set_ylabel('L_δ = log((1-δ)/δ)', fontsize=12)
ax.set_title('Stability Constant vs Spectral Gap', fontsize=13, fontweight='bold')
ax.axhline(np.log(2), color='orange', linestyle='--', alpha=0.7, label='log 2 (δ→1/2)')
ax.annotate('Diverges as δ→0\n(no gap = no stability)',
            xy=(0.03, entropy_stability_constant(0.03)),
            xytext=(0.15, 3.5), fontsize=10,
            arrowprops=dict(arrowstyle='->', color='red'))
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)
ax.set_ylim(0, 5)

# Panel 4: Certificate width heatmap (m vs epsilon)
ax = axes[1, 0]
m_vals = np.arange(1, 51)
eps_vals = np.linspace(0.001, 0.1, 50)
M, E = np.meshgrid(m_vals, eps_vals)
delta_fixed = 0.1
L_fixed = entropy_stability_constant(delta_fixed)
W = 2 * M * L_fixed * E
im = ax.pcolormesh(M, E, W, cmap='YlOrRd', shading='auto')
plt.colorbar(im, ax=ax, label='Certificate width')
ax.set_xlabel('Subsystem size m', fontsize=12)
ax.set_ylabel('Perturbation ε', fontsize=12)
ax.set_title(f'Certificate Width (δ={delta_fixed})', fontsize=13, fontweight='bold')
ax.contour(M, E, W, levels=[0.5, 1, 2, 5], colors='black', linewidths=0.5)

# Panel 5: Random perturbation samples with certificate
ax = axes[1, 1]
m = 8
delta = 0.15
np.random.seed(42)
spec0 = np.array([0.25, 0.35, 0.45, 0.55, 0.65, 0.75, 0.4, 0.6])
S0 = sum(binary_entropy(x) for x in spec0)

eta_vals = [0.02, 0.05, 0.1]
colors = ['green', 'blue', 'red']
for eta, color in zip(eta_vals, colors):
    L = entropy_stability_constant(delta)
    lo = S0 - m * L * eta
    hi = S0 + m * L * eta
    entropies = []
    for _ in range(500):
        pert = np.random.uniform(-eta, eta, m)
        spec = np.clip(spec0 + pert, delta, 1 - delta)
        entropies.append(sum(binary_entropy(x) for x in spec))
    ax.hist(entropies, bins=30, alpha=0.3, color=color, density=True,
            label=f'η={eta}')
    ax.axvline(lo, color=color, linestyle='--', alpha=0.7)
    ax.axvline(hi, color=color, linestyle='--', alpha=0.7)
ax.axvline(S0, color='black', linewidth=2, label='S(ref)')
ax.set_xlabel('Entropy', fontsize=12)
ax.set_ylabel('Density', fontsize=12)
ax.set_title('Entropy Distribution vs Certificate', fontsize=13, fontweight='bold')
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# Panel 6: Quadratic lower bound h(x) >= 2x(1-x)
ax = axes[1, 2]
x = np.linspace(0, 1, 500)
ax.plot(x, binary_entropy(x), 'b-', linewidth=2.5, label='h(x)')
ax.plot(x, 2*x*(1-x), 'r--', linewidth=2, label='2x(1-x)')
ax.fill_between(x, 2*x*(1-x), binary_entropy(x), alpha=0.15, color='green',
                label='Gap: entropy > quadratic')
ax.set_xlabel('x', fontsize=12)
ax.set_ylabel('Value', fontsize=12)
ax.set_title('Entropy ≥ 2x(1-x): Variance Lower Bound', fontsize=13, fontweight='bold')
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)
ax.set_xlim(0, 1)

plt.suptitle('Entropy Stability for Approximately Gaussian Fermionic States',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_entropy_landscape.png', dpi=150, bbox_inches='tight')
print("Saved viz_entropy_landscape.png")


#!/usr/bin/env python3
"""
Visualization 2: Perturbation Scaling and Conjecture Testing

Visualizes:
- How entropy difference scales with perturbation epsilon (linear regime)
- Comparison of sup-norm vs L1 bounds
- Testing the m*log(m+1) conjecture for local interactions
- Elementary symmetric polynomial stability
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from itertools import combinations
from math import comb


def binary_entropy(x):
    x = np.asarray(x, dtype=float)
    result = np.zeros_like(x)
    mask = (x > 0) & (x < 1)
    xm = x[mask]
    result[mask] = -xm * np.log(xm) - (1 - xm) * np.log(1 - xm)
    return result


def region_entropy(spec):
    return np.sum(binary_entropy(spec))


def entropy_stability_constant(delta):
    return np.log((1 - delta) / delta)


def elem_symm(k, spec):
    m = len(spec)
    if k > m or k < 0:
        return 0.0
    if k == 0:
        return 1.0
    return sum(np.prod([spec[i] for i in S]) for S in combinations(range(m), k))


fig, axes = plt.subplots(2, 2, figsize=(14, 11))

# Panel 1: Entropy difference vs epsilon (linearity test)
ax = axes[0, 0]
delta = 0.15
L = entropy_stability_constant(delta)
np.random.seed(42)

for m_val, color in [(5, 'blue'), (10, 'green'), (20, 'red'), (50, 'purple')]:
    spec0 = np.random.uniform(delta + 0.05, 1 - delta - 0.05, m_val)
    eps_range = np.linspace(0, 0.15, 30)
    max_diffs = []
    for eps in eps_range:
        diffs = []
        for _ in range(200):
            pert = np.random.uniform(-eps, eps, m_val)
            spec = np.clip(spec0 + pert, delta, 1 - delta)
            diffs.append(abs(region_entropy(spec) - region_entropy(spec0)))
        max_diffs.append(np.max(diffs))

    ax.plot(eps_range, max_diffs, 'o-', color=color, markersize=3,
            label=f'm={m_val} (observed)')
    ax.plot(eps_range, m_val * L * eps_range, '--', color=color, alpha=0.5,
            label=f'm={m_val} (bound)')

ax.set_xlabel('Perturbation ε', fontsize=12)
ax.set_ylabel('Max |ΔS|', fontsize=12)
ax.set_title('Entropy Difference: Linear in ε', fontsize=13, fontweight='bold')
ax.legend(fontsize=8, ncol=2)
ax.grid(True, alpha=0.3)

# Panel 2: Sup-norm vs L1 bound comparison
ax = axes[0, 1]
m_val = 15
delta = 0.15
L = entropy_stability_constant(delta)
np.random.seed(123)
spec0 = np.random.uniform(delta + 0.05, 1 - delta - 0.05, m_val)

# Generate perturbations with varying localization
n_trials = 500
actual_diffs = []
sup_bounds = []
l1_bounds = []

for _ in range(n_trials):
    # Random localization: perturbation concentrated on random subset
    n_perturbed = np.random.randint(1, m_val + 1)
    eta = 0.08
    pert = np.zeros(m_val)
    indices = np.random.choice(m_val, n_perturbed, replace=False)
    pert[indices] = np.random.uniform(-eta, eta, n_perturbed)
    spec = np.clip(spec0 + pert, delta, 1 - delta)

    actual_diff = abs(region_entropy(spec) - region_entropy(spec0))
    sup_bound = m_val * L * np.max(np.abs(spec - spec0))
    l1_bound = L * np.sum(np.abs(spec - spec0))

    actual_diffs.append(actual_diff)
    sup_bounds.append(sup_bound)
    l1_bounds.append(l1_bound)

ax.scatter(l1_bounds, actual_diffs, alpha=0.3, s=10, c='blue', label='L1 bound')
ax.scatter(sup_bounds, actual_diffs, alpha=0.3, s=10, c='red', label='Sup bound')
max_val = max(max(sup_bounds), max(l1_bounds))
ax.plot([0, max_val], [0, max_val], 'k--', alpha=0.5, label='y = x (tight)')
ax.set_xlabel('Certified bound', fontsize=12)
ax.set_ylabel('Actual |ΔS|', fontsize=12)
ax.set_title('L1 vs Sup-Norm Bounds', fontsize=13, fontweight='bold')
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Panel 3: m*log(m+1) conjecture test
ax = axes[1, 0]
m_values = np.arange(2, 65)
eps = 0.05
delta = 0.15
np.random.seed(42)

ratios_mean = []
ratios_max = []
log_bound = np.log(m_values + 1)

for m_val in m_values:
    spec0 = np.random.uniform(delta + 0.05, 1 - delta - 0.05, m_val)
    trial_ratios = []
    for _ in range(100):
        pert = np.random.uniform(-eps, eps, m_val)
        spec = np.clip(spec0 + pert, delta, 1 - delta)
        diff = abs(region_entropy(spec) - region_entropy(spec0))
        ratio = diff / (eps * m_val) if eps * m_val > 0 else 0
        trial_ratios.append(ratio)
    ratios_mean.append(np.mean(trial_ratios))
    ratios_max.append(np.max(trial_ratios))

ax.plot(m_values, ratios_max, 'r.', markersize=3, alpha=0.5, label='Max ratio')
ax.plot(m_values, ratios_mean, 'b-', linewidth=1.5, label='Mean ratio')
ax.plot(m_values, log_bound, 'g--', linewidth=2, label='log(m+1) conjecture')
L = entropy_stability_constant(delta)
ax.axhline(L, color='orange', linestyle=':', label=f'L_δ={L:.2f} (formal bound)')
ax.set_xlabel('Subsystem size m', fontsize=12)
ax.set_ylabel('|ΔS| / (ε·m)', fontsize=12)
ax.set_title('Conjecture: Correction ~ m·log(m+1)·ε', fontsize=13, fontweight='bold')
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# Panel 4: Elementary symmetric polynomial stability
ax = axes[1, 1]
m_val = 8
np.random.seed(42)
spec0 = np.random.uniform(0.1, 0.9, m_val)

eta_range = np.linspace(0, 0.1, 25)
for k in [1, 2, 3, 4]:
    e0 = elem_symm(k, spec0)
    max_diffs_esymm = []
    bounds_esymm = []
    for eta in eta_range:
        diffs = []
        for _ in range(200):
            pert = np.random.uniform(-eta, eta, m_val)
            spec = np.clip(spec0 + pert, 0, 1)
            diffs.append(abs(elem_symm(k, spec) - e0))
        max_diffs_esymm.append(np.max(diffs))
        bounds_esymm.append(comb(m_val, k) * k * eta)

    ax.plot(eta_range, max_diffs_esymm, 'o-', markersize=3, label=f'k={k} observed')
    ax.plot(eta_range, bounds_esymm, '--', alpha=0.5, label=f'k={k} bound')

ax.set_xlabel('Perturbation η', fontsize=12)
ax.set_ylabel('|e_k(λ) - e_k(μ)|', fontsize=12)
ax.set_title('Elementary Symmetric Polynomial Stability', fontsize=13, fontweight='bold')
ax.legend(fontsize=8, ncol=2)
ax.grid(True, alpha=0.3)

plt.suptitle('Perturbation Scaling and Conjecture Testing',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_perturbation_scaling.png', dpi=150, bbox_inches='tight')
print("Saved viz_perturbation_scaling.png")
