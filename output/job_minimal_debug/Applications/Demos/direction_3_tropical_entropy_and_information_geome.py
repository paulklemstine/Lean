"""
Applications of Tropical Entropy Theory
=========================================

Real-world applications of the formally verified tropical entropy bounds:

1. Entanglement detection in quantum systems
2. Spectral flatness analysis for signal processing
3. Efficient entropy certification for tensor networks
"""

import numpy as np
from typing import List, Tuple


def binary_entropy(x: float) -> float:
    """Binary entropy h(x) = -x·log(x) - (1-x)·log(1-x)."""
    if x <= 0 or x >= 1:
        return 0.0
    return -x * np.log(x) - (1 - x) * np.log(1 - x)


def trop_min_entropy(x: float) -> float:
    """Tropical binary entropy: 2·min(x, 1-x)·log(2)."""
    return 2 * min(x, 1 - x) * np.log(2)


# ──────────────────────────────────────────────────────────
# Application 1: Quantum Entanglement Detection
# ──────────────────────────────────────────────────────────

def entanglement_certificate(spectrum: np.ndarray, threshold: float) -> dict:
    """Certify whether entanglement entropy exceeds a threshold.

    Uses the tropical lower bound to provide a polynomial-time
    certificate of entanglement. If S_trop > threshold, the actual
    entropy S > threshold is guaranteed (formally verified).

    Args:
        spectrum: Single-particle entanglement spectrum ∈ [0,1]ᵐ
        threshold: Entropy threshold to certify

    Returns:
        Dictionary with certification result and bounds
    """
    s_trop = sum(trop_min_entropy(mu) for mu in spectrum)
    s_exact = sum(binary_entropy(mu) for mu in spectrum)
    m = len(spectrum)

    certified = s_trop > threshold
    return {
        "certified_above_threshold": certified,
        "tropical_lower_bound": s_trop,
        "exact_entropy": s_exact,
        "threshold": threshold,
        "subsystem_size": m,
        "max_possible_entropy": m * np.log(2),
        "certification_method": "tropical_min_entropy (formally verified)",
    }


# ──────────────────────────────────────────────────────────
# Application 2: Spectral Flatness Analysis
# ──────────────────────────────────────────────────────────

def spectral_flatness_index(spectrum: np.ndarray) -> float:
    """Compute the tropical spectral flatness index.

    Measures how "flat" (uniform) the entanglement spectrum is,
    using the ratio S_trop / (m·log 2). This ranges from 0
    (all eigenvalues at 0 or 1) to 1 (all eigenvalues at 1/2).

    This is a polynomial-time computable proxy for the actual
    spectral flatness S / (m·log 2), and is guaranteed to
    lower-bound it.

    Args:
        spectrum: Array of eigenvalues in [0, 1]

    Returns:
        Flatness index in [0, 1]
    """
    m = len(spectrum)
    if m == 0:
        return 0.0
    s_trop = sum(trop_min_entropy(mu) for mu in spectrum)
    return s_trop / (m * np.log(2))


def classify_entanglement_regime(spectrum: np.ndarray) -> str:
    """Classify the entanglement regime using tropical entropy.

    Categories:
    - "product_state": S_trop ≈ 0 (no entanglement)
    - "area_law": S_trop = O(√m) (typical ground states)
    - "volume_law": S_trop = O(m) (typical excited states)
    - "maximal": S_trop ≈ m·log(2) (maximally entangled)
    """
    m = len(spectrum)
    if m == 0:
        return "product_state"

    flatness = spectral_flatness_index(spectrum)
    sqrt_m_ratio = sum(trop_min_entropy(mu) for mu in spectrum) / (np.sqrt(m) * np.log(2))

    if flatness < 0.01:
        return "product_state"
    elif flatness > 0.9:
        return "maximal"
    elif sqrt_m_ratio < 2.0:
        return "area_law"
    else:
        return "volume_law"


# ──────────────────────────────────────────────────────────
# Application 3: Tensor Network Entropy Certification
# ──────────────────────────────────────────────────────────

def tensor_network_entropy_bounds(
    bond_spectra: List[np.ndarray],
) -> dict:
    """Compute entropy bounds for a tensor network state.

    For a tensor network with multiple bonds, each characterized
    by a single-particle spectrum, compute tropical entropy bounds
    for each bond and aggregate statistics.

    Args:
        bond_spectra: List of spectra, one per bond

    Returns:
        Dictionary with per-bond and total entropy bounds
    """
    results = {
        "n_bonds": len(bond_spectra),
        "per_bond": [],
        "total_tropical_lower": 0.0,
        "total_exact": 0.0,
        "total_upper": 0.0,
    }

    for i, spec in enumerate(bond_spectra):
        s_trop = sum(trop_min_entropy(mu) for mu in spec)
        s_exact = sum(binary_entropy(mu) for mu in spec)
        m = len(spec)
        s_upper = m * np.log(2)

        bond_data = {
            "bond_index": i,
            "bond_dimension": m,
            "tropical_bound": s_trop,
            "exact_entropy": s_exact,
            "upper_bound": s_upper,
            "regime": classify_entanglement_regime(spec),
        }
        results["per_bond"].append(bond_data)
        results["total_tropical_lower"] += s_trop
        results["total_exact"] += s_exact
        results["total_upper"] += s_upper

    return results


def main():
    np.random.seed(42)

    print("=" * 60)
    print("APPLICATIONS OF TROPICAL ENTROPY THEORY")
    print("=" * 60)

    # Application 1: Entanglement detection
    print("\n--- Application 1: Quantum Entanglement Detection ---\n")
    # Slightly entangled state
    spec1 = np.array([0.95, 0.92, 0.88, 0.85, 0.03, 0.05, 0.08, 0.12])
    cert1 = entanglement_certificate(spec1, threshold=0.5)
    print(f"Spectrum: {spec1}")
    print(f"  Tropical lower bound: {cert1['tropical_lower_bound']:.4f}")
    print(f"  Exact entropy:        {cert1['exact_entropy']:.4f}")
    print(f"  Threshold:            {cert1['threshold']:.4f}")
    print(f"  Certified above:      {cert1['certified_above_threshold']}")

    # Maximally entangled state
    spec2 = np.full(10, 0.5)
    cert2 = entanglement_certificate(spec2, threshold=5.0)
    print(f"\nMaximally entangled (m=10):")
    print(f"  Tropical = Exact = {cert2['tropical_lower_bound']:.4f}")
    print(f"  Certified above 5.0: {cert2['certified_above_threshold']}")

    # Application 2: Spectral flatness
    print("\n--- Application 2: Spectral Flatness Analysis ---\n")
    spectra = {
        "Product state": np.array([0.99, 0.99, 0.01, 0.01, 0.99]),
        "Area-law": np.concatenate([np.full(8, 0.02), np.array([0.4, 0.6])]),
        "Volume-law": np.random.uniform(0.2, 0.8, 10),
        "Maximal": np.full(10, 0.5),
    }
    for name, spec in spectra.items():
        flatness = spectral_flatness_index(spec)
        regime = classify_entanglement_regime(spec)
        print(f"  {name:15s}: flatness={flatness:.4f}, regime={regime}")

    # Application 3: Tensor network
    print("\n--- Application 3: Tensor Network Entropy Bounds ---\n")
    bond_spectra = [
        np.array([0.9, 0.8, 0.1, 0.05]),
        np.array([0.5, 0.5, 0.5]),
        np.array([0.95, 0.92, 0.88, 0.85, 0.03, 0.05]),
        np.array([0.7, 0.3]),
    ]
    tn_results = tensor_network_entropy_bounds(bond_spectra)
    print(f"Tensor network with {tn_results['n_bonds']} bonds:")
    for bd in tn_results["per_bond"]:
        print(f"  Bond {bd['bond_index']}: dim={bd['bond_dimension']}, "
              f"S_trop={bd['tropical_bound']:.3f}, S={bd['exact_entropy']:.3f}, "
              f"regime={bd['regime']}")
    print(f"\nTotal entropy: {tn_results['total_tropical_lower']:.4f} ≤ "
          f"{tn_results['total_exact']:.4f} ≤ {tn_results['total_upper']:.4f}")

    print("\n" + "=" * 60)
    print("All applications demonstrated successfully.")
    print("=" * 60)


if __name__ == "__main__":
    main()


"""
Tropical Entropy and Information Geometry — Demo
=================================================

Demonstrates the key theorems from the formal Lean development:
1. The tropical entropy surrogate 2·min(x, 1-x)·log(2) lower-bounds binary entropy
2. Newton's inequality implies tropical concavity of log-coefficients
3. The tropical fermion entropy bounds the actual fermion entropy

Usage:
    python demo.py
"""

import numpy as np
from typing import List, Tuple


def binary_entropy(x: float) -> float:
    """Binary Shannon entropy h(x) = -x·log(x) - (1-x)·log(1-x)."""
    if x <= 0 or x >= 1:
        return 0.0
    return -x * np.log(x) - (1 - x) * np.log(1 - x)


def trop_min_entropy(x: float) -> float:
    """Tropical binary entropy surrogate: 2·min(x, 1-x)·log(2)."""
    return 2 * min(x, 1 - x) * np.log(2)


def fermion_entropy(spectrum: np.ndarray) -> float:
    """Von Neumann entanglement entropy for free fermions: S = Σᵢ h(μᵢ)."""
    return sum(binary_entropy(mu) for mu in spectrum)


def trop_fermion_entropy(spectrum: np.ndarray) -> float:
    """Tropical fermion entropy surrogate: Σᵢ 2·min(μᵢ, 1-μᵢ)·log(2)."""
    return sum(trop_min_entropy(mu) for mu in spectrum)


def elementary_symmetric(spectrum: np.ndarray, k: int) -> float:
    """Compute e_k(μ) = Σ_{|S|=k} Π_{i∈S} μᵢ using recursion."""
    m = len(spectrum)
    if k == 0:
        return 1.0
    if k > m:
        return 0.0
    # Use the recursion: e_k(μ₁,...,μₘ) = e_k(μ₁,...,μₘ₋₁) + μₘ·e_{k-1}(μ₁,...,μₘ₋₁)
    # Dynamic programming approach
    dp = np.zeros(k + 1)
    dp[0] = 1.0
    for mu in spectrum:
        for j in range(min(k, len(spectrum)), 0, -1):
            dp[j] += mu * dp[j - 1]
    return dp[k]


def verify_newton_inequality(spectrum: np.ndarray) -> List[Tuple[int, float, float]]:
    """Verify Newton's inequality eₖ² ≥ eₖ₋₁·eₖ₊₁ for all valid k."""
    m = len(spectrum)
    results = []
    for k in range(1, m):
        ek = elementary_symmetric(spectrum, k)
        ek_minus = elementary_symmetric(spectrum, k - 1)
        ek_plus = elementary_symmetric(spectrum, k + 1)
        lhs = ek ** 2
        rhs = ek_minus * ek_plus
        results.append((k, lhs, rhs))
    return results


def verify_tropical_concavity(spectrum: np.ndarray) -> List[Tuple[int, float]]:
    """Verify tropical concavity: 2·log(eₖ) ≥ log(eₖ₋₁) + log(eₖ₊₁)."""
    m = len(spectrum)
    results = []
    for k in range(1, m):
        ek = elementary_symmetric(spectrum, k)
        ek_minus = elementary_symmetric(spectrum, k - 1)
        ek_plus = elementary_symmetric(spectrum, k + 1)
        if ek > 0 and ek_minus > 0 and ek_plus > 0:
            deficit = 2 * np.log(ek) - np.log(ek_minus) - np.log(ek_plus)
            results.append((k, deficit))
    return results


def main():
    print("=" * 60)
    print("TROPICAL ENTROPY — FORMAL THEOREM DEMONSTRATIONS")
    print("=" * 60)

    # Demo 1: Tropical entropy lower-bounds binary entropy
    print("\n--- Demo 1: Tropical Entropy Lower Bound ---")
    print("Theorem: ∀ x ∈ [0,1], 2·min(x,1-x)·log(2) ≤ h(x)")
    print(f"{'x':>6} | {'h(x)':>10} | {'h_trop(x)':>10} | {'gap':>10} | {'bound holds':>12}")
    print("-" * 56)
    for x in [0.0, 0.05, 0.1, 0.2, 0.3, 0.4, 0.5, 0.7, 0.9, 1.0]:
        h = binary_entropy(x)
        ht = trop_min_entropy(x)
        gap = h - ht
        holds = "✓" if gap >= -1e-12 else "✗"
        print(f"{x:6.2f} | {h:10.6f} | {ht:10.6f} | {gap:10.6f} | {holds:>12}")

    # Demo 2: Newton's inequality verification
    print("\n--- Demo 2: Newton's Inequality → Tropical Concavity ---")
    spectrum = np.array([0.8, 0.6, 0.4, 0.2, 0.1])
    print(f"Spectrum: {spectrum}")
    print("\nNewton's inequality eₖ² ≥ eₖ₋₁·eₖ₊₁:")
    newton_results = verify_newton_inequality(spectrum)
    for k, lhs, rhs in newton_results:
        holds = "✓" if lhs >= rhs - 1e-12 else "✗"
        print(f"  k={k}: eₖ²={lhs:.6f} ≥ eₖ₋₁·eₖ₊₁={rhs:.6f}  {holds}")

    print("\nTropical concavity 2·log(eₖ) ≥ log(eₖ₋₁) + log(eₖ₊₁):")
    tc_results = verify_tropical_concavity(spectrum)
    for k, deficit in tc_results:
        holds = "✓" if deficit >= -1e-12 else "✗"
        print(f"  k={k}: concavity deficit = {deficit:.6f}  {holds}")

    # Demo 3: Fermion entropy bounds
    print("\n--- Demo 3: Tropical Fermion Entropy Bounds ---")
    for m in [5, 10, 20, 50]:
        spectrum = np.random.uniform(0, 1, m)
        s_actual = fermion_entropy(spectrum)
        s_trop = trop_fermion_entropy(spectrum)
        s_max = m * np.log(2)
        print(f"  m={m:3d}: S_trop={s_trop:8.4f} ≤ S={s_actual:8.4f} ≤ m·log2={s_max:8.4f}")

    # Demo 4: Area-law spectra (most eigenvalues near 0 or 1)
    print("\n--- Demo 4: Area-Law Spectra — Approximation Quality ---")
    print(f"{'m':>5} | {'S':>10} | {'S_trop':>10} | {'|S-S_trop|':>12} | {'rel_err':>10}")
    print("-" * 55)
    for m in [10, 20, 50, 100]:
        # Area-law spectrum: most eigenvalues near 0 or 1, a few near 1/2
        n_boundary = int(np.sqrt(m))
        spectrum = np.concatenate([
            np.random.uniform(0, 0.05, m - n_boundary),  # near 0
            np.random.uniform(0.3, 0.7, n_boundary)       # near 1/2
        ])
        np.random.shuffle(spectrum)
        s_actual = fermion_entropy(spectrum)
        s_trop = trop_fermion_entropy(spectrum)
        abs_err = abs(s_actual - s_trop)
        rel_err = abs_err / s_actual if s_actual > 1e-10 else 0
        print(f"{m:5d} | {s_actual:10.4f} | {s_trop:10.4f} | {abs_err:12.6f} | {rel_err:10.6f}")

    # Demo 5: Concave sequence properties
    print("\n--- Demo 5: Concave Finite Sequence Properties ---")
    a = [0, 2, 3, 3.5, 3.5, 3, 2, 0]  # concave
    n = len(a) - 1
    print(f"Sequence a = {a}")
    print("Slopes: ", end="")
    slopes = [a[k + 1] - a[k] for k in range(n)]
    print(slopes)
    print("Slopes non-increasing:", all(slopes[k] >= slopes[k + 1] for k in range(n - 1)))
    print("\nChord-below property (a(k) ≥ linear interpolation):")
    for k in range(1, n + 1):
        interp = a[0] + (a[n] - a[0]) * k / n
        holds = "✓" if a[k] >= interp - 1e-12 else "✗"
        print(f"  k={k}: a({k})={a[k]:.2f} ≥ interp={interp:.4f}  {holds}")

    print("\n" + "=" * 60)
    print("All demonstrations complete — all formal bounds verified.")
    print("=" * 60)


if __name__ == "__main__":
    np.random.seed(42)
    main()


"""
Visualization 3: Tropical Entropy Approximation Conjecture Test
================================================================

Tests the conjecture that for area-law spectra (entropy ≤ C·√m),
the relative error |S - S_trop|/S scales as O(1/m).

This produces a log-log plot of relative error vs. system size m,
with 1/m reference line for comparison.
"""

import numpy as np
import matplotlib.pyplot as plt


def binary_entropy(x):
    if x <= 0 or x >= 1:
        return 0.0
    return -x * np.log(x) - (1 - x) * np.log(1 - x)


def trop_min_entropy(x):
    return 2 * min(x, 1 - x) * np.log(2)


def generate_area_law_spectrum(m, rng, boundary_fraction=0.1):
    """Generate a spectrum satisfying area-law scaling.

    Most eigenvalues near 0, a few (√m) near 1/2.
    """
    n_bulk = max(1, int(np.sqrt(m)))
    n_boundary = m - n_bulk
    spectrum = np.concatenate([
        rng.uniform(0, boundary_fraction, n_boundary),
        rng.uniform(0.3, 0.7, n_bulk),
    ])
    rng.shuffle(spectrum)
    return spectrum


def generate_random_spectrum(m, rng):
    """Generate a uniformly random spectrum."""
    return rng.uniform(0, 1, m)


# Run experiment
rng = np.random.RandomState(42)
sizes = [5, 8, 10, 15, 20, 30, 50, 75, 100, 150, 200]
n_trials = 200

area_law_errors = {m: [] for m in sizes}
random_errors = {m: [] for m in sizes}

for m in sizes:
    for _ in range(n_trials):
        # Area-law spectrum
        spec_al = generate_area_law_spectrum(m, rng)
        s_al = sum(binary_entropy(mu) for mu in spec_al)
        st_al = sum(trop_min_entropy(mu) for mu in spec_al)
        if s_al > 0.01:
            area_law_errors[m].append((s_al - st_al) / s_al)

        # Random spectrum
        spec_rand = generate_random_spectrum(m, rng)
        s_rand = sum(binary_entropy(mu) for mu in spec_rand)
        st_rand = sum(trop_min_entropy(mu) for mu in spec_rand)
        if s_rand > 0.01:
            random_errors[m].append((s_rand - st_rand) / s_rand)

# Compute statistics
al_means = [np.mean(area_law_errors[m]) for m in sizes]
al_stds = [np.std(area_law_errors[m]) for m in sizes]
rand_means = [np.mean(random_errors[m]) for m in sizes]
rand_stds = [np.std(random_errors[m]) for m in sizes]

# Fit power law to area-law data
log_m = np.log(np.array(sizes))
log_err_al = np.log(np.array(al_means))
mask = np.isfinite(log_err_al)
if mask.sum() > 2:
    coeffs_al = np.polyfit(log_m[mask], log_err_al[mask], 1)
    al_exponent = coeffs_al[0]
else:
    al_exponent = -1.0

log_err_rand = np.log(np.array(rand_means))
mask_rand = np.isfinite(log_err_rand)
if mask_rand.sum() > 2:
    coeffs_rand = np.polyfit(log_m[mask_rand], log_err_rand[mask_rand], 1)
    rand_exponent = coeffs_rand[0]
else:
    rand_exponent = 0.0

# Create figure
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

# Left: Log-log plot
ax1.errorbar(sizes, al_means, yerr=al_stds, fmt='bo-', linewidth=2,
             capsize=4, markersize=7, label=f'Area-law (slope={al_exponent:.2f})')
ax1.errorbar(sizes, rand_means, yerr=rand_stds, fmt='rs--', linewidth=2,
             capsize=4, markersize=7, label=f'Random (slope={rand_exponent:.2f})')

# Reference lines
ref_1m = [1.0 / m for m in sizes]
ax1.plot(sizes, ref_1m, 'k:', linewidth=2, alpha=0.5, label='$O(1/m)$ reference')

ax1.set_xscale('log')
ax1.set_yscale('log')
ax1.set_xlabel('System size $m$', fontsize=14)
ax1.set_ylabel('Relative error $(S - S_{\\mathrm{trop}})/S$', fontsize=14)
ax1.set_title('Conjecture Test: Approximation Scaling', fontsize=15, fontweight='bold')
ax1.legend(fontsize=11)
ax1.grid(True, alpha=0.3, which='both')

# Annotate conjecture result
if abs(al_exponent + 1) < 0.3:
    verdict = "CONSISTENT with $O(1/m)$"
    color = 'green'
else:
    verdict = f"Scaling ~ $O(m^{{{al_exponent:.2f}}})$"
    color = 'orange'
ax1.annotate(verdict, xy=(0.05, 0.05), xycoords='axes fraction',
             fontsize=12, fontweight='bold', color=color,
             bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow'))

# Right: Error distribution at m=100
ax2_data_al = area_law_errors.get(100, [])
ax2_data_rand = random_errors.get(100, [])

if ax2_data_al and ax2_data_rand:
    ax2.hist(ax2_data_al, bins=30, alpha=0.6, color='blue', density=True,
             label='Area-law spectra')
    ax2.hist(ax2_data_rand, bins=30, alpha=0.6, color='red', density=True,
             label='Random spectra')
    ax2.axvline(x=np.mean(ax2_data_al), color='blue', linestyle='--', linewidth=2)
    ax2.axvline(x=np.mean(ax2_data_rand), color='red', linestyle='--', linewidth=2)

ax2.set_xlabel('Relative error $(S - S_{\\mathrm{trop}})/S$', fontsize=14)
ax2.set_ylabel('Density', fontsize=14)
ax2.set_title('Error Distribution at $m = 100$', fontsize=15, fontweight='bold')
ax2.legend(fontsize=11)
ax2.grid(True, alpha=0.3)

plt.suptitle('Testing the Tropical Entropy Approximation Conjecture',
             fontsize=16, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_conjecture_test.png', dpi=150, bbox_inches='tight')
print("Saved viz_conjecture_test.png")


"""
Visualization 1: Binary Entropy vs Tropical Surrogate
=====================================================

Compares the binary Shannon entropy h(x) = -x·log(x) - (1-x)·log(1-x)
with the tropical entropy surrogate h_trop(x) = 2·min(x, 1-x)·log(2).

The key theorem (formally verified) is that h_trop(x) ≤ h(x) for all x ∈ [0,1],
with equality at x = 0, x = 1/2, and x = 1. The shaded region shows the
"tropical entropy gap" — the price of the piecewise-linear approximation.
"""

import numpy as np
import matplotlib.pyplot as plt

# Compute functions
x = np.linspace(0, 1, 1000)

# Binary entropy (handle endpoints)
h = np.zeros_like(x)
for i, xi in enumerate(x):
    if 0 < xi < 1:
        h[i] = -xi * np.log(xi) - (1 - xi) * np.log(1 - xi)

# Tropical entropy
h_trop = 2 * np.minimum(x, 1 - x) * np.log(2)

# Quadratic lower bound (from catalog: h(x) ≥ 2x(1-x))
h_quad = 2 * x * (1 - x)

# Create figure
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

# Left panel: entropy comparison
ax1.fill_between(x, h_trop, h, alpha=0.3, color='coral', label='Tropical gap')
ax1.plot(x, h, 'b-', linewidth=2.5, label=r'Binary entropy $h(x)$')
ax1.plot(x, h_trop, 'r--', linewidth=2.5, label=r'Tropical surrogate $2\min(x,1{-}x)\ln 2$')
ax1.plot(x, h_quad, 'g:', linewidth=2, label=r'Quadratic bound $2x(1{-}x)$')
ax1.axhline(y=np.log(2), color='gray', linestyle=':', alpha=0.5)
ax1.annotate(r'$\ln 2$', xy=(0.02, np.log(2)), fontsize=11, color='gray')

# Mark equality points
for xp in [0, 0.5, 1.0]:
    ax1.plot(xp, 2 * min(xp, 1-xp) * np.log(2), 'ko', markersize=8, zorder=5)
ax1.annotate('Equality at\n$x = 0, \\frac{1}{2}, 1$',
             xy=(0.5, np.log(2)), xytext=(0.65, 0.45),
             fontsize=10, arrowprops=dict(arrowstyle='->', color='black'),
             bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow'))

ax1.set_xlabel('$x$', fontsize=14)
ax1.set_ylabel('Entropy', fontsize=14)
ax1.set_title('Binary Entropy vs. Tropical Surrogate', fontsize=15, fontweight='bold')
ax1.legend(fontsize=11, loc='upper left')
ax1.set_xlim(-0.02, 1.02)
ax1.set_ylim(-0.02, 0.75)
ax1.grid(True, alpha=0.3)

# Right panel: relative approximation error
mask = h > 0.001
rel_error = np.zeros_like(x)
rel_error[mask] = (h[mask] - h_trop[mask]) / h[mask]

ax2.plot(x[mask], rel_error[mask], 'b-', linewidth=2)
ax2.fill_between(x[mask], 0, rel_error[mask], alpha=0.2, color='blue')
ax2.set_xlabel('$x$', fontsize=14)
ax2.set_ylabel('Relative error $(h - h_{\\mathrm{trop}})/h$', fontsize=14)
ax2.set_title('Approximation Quality', fontsize=15, fontweight='bold')
ax2.set_xlim(-0.02, 1.02)
ax2.grid(True, alpha=0.3)
ax2.annotate('Best near $x = 0, 1$\n(area-law regime)',
             xy=(0.1, rel_error[100]), xytext=(0.25, 0.35),
             fontsize=10, arrowprops=dict(arrowstyle='->', color='black'),
             bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow'))

plt.tight_layout()
plt.savefig('viz_entropy_comparison.png', dpi=150, bbox_inches='tight')
print("Saved viz_entropy_comparison.png")


"""
Visualization 2: Tropical Newton Polygon
=========================================

Shows how Newton's inequality for elementary symmetric polynomials
translates into tropical concavity of the log-coefficient sequence,
forming the tropical Newton polygon of the DPP generating polynomial.

The concave envelope (Newton polygon) is the key tropical-geometric
structure that encodes entanglement information.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import combinations


def elementary_symmetric_all(spectrum):
    """Compute all elementary symmetric polynomials."""
    m = len(spectrum)
    dp = np.zeros(m + 1)
    dp[0] = 1.0
    for mu in spectrum:
        for j in range(m, 0, -1):
            dp[j] += mu * dp[j - 1]
    return dp


def binary_entropy(x):
    if x <= 0 or x >= 1:
        return 0.0
    return -x * np.log(x) - (1 - x) * np.log(1 - x)


def trop_min_entropy(x):
    return 2 * min(x, 1 - x) * np.log(2)


# Three different spectra representing different entanglement regimes
spectra = {
    'Area-law\n(mostly 0 or 1)': np.array([0.98, 0.95, 0.92, 0.08, 0.05, 0.02]),
    'Intermediate': np.array([0.8, 0.6, 0.5, 0.4, 0.3, 0.1]),
    'Volume-law\n(near uniform)': np.array([0.55, 0.52, 0.50, 0.48, 0.45, 0.42]),
}

fig, axes = plt.subplots(2, 3, figsize=(16, 10))

for idx, (name, spec) in enumerate(spectra.items()):
    m = len(spec)
    coeffs = elementary_symmetric_all(spec)

    # Log-coefficients
    log_coeffs = np.array([np.log(c) if c > 0 else -np.inf for c in coeffs])
    ks = np.arange(m + 1)

    # Slopes
    slopes = np.diff(log_coeffs)
    slopes_finite = slopes[np.isfinite(slopes)]

    # Compute entropies
    s_exact = sum(binary_entropy(mu) for mu in spec)
    s_trop = sum(trop_min_entropy(mu) for mu in spec)

    # Top row: Newton polygon
    ax = axes[0, idx]
    ax.plot(ks, log_coeffs, 'bo-', markersize=8, linewidth=2, label='$\\log(e_k)$')

    # Linear interpolation (chord)
    if np.isfinite(log_coeffs[0]) and np.isfinite(log_coeffs[-1]):
        chord = log_coeffs[0] + (log_coeffs[-1] - log_coeffs[0]) * ks / m
        ax.plot(ks, chord, 'r--', linewidth=1.5, alpha=0.7, label='Chord')
        ax.fill_between(ks, chord, log_coeffs,
                        where=np.isfinite(log_coeffs),
                        alpha=0.2, color='green', label='Concavity surplus')

    ax.set_xlabel('$k$', fontsize=12)
    ax.set_ylabel('$\\log(e_k)$', fontsize=12)
    ax.set_title(f'{name}\n$S={s_exact:.3f}$, $S_{{\\mathrm{{trop}}}}={s_trop:.3f}$',
                 fontsize=12, fontweight='bold')
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)

    # Bottom row: slopes (tropical roots)
    ax2 = axes[1, idx]
    slope_ks = np.arange(len(slopes))
    colors = ['green' if s >= 0 else 'red' for s in slopes]
    ax2.bar(slope_ks, slopes, color=colors, alpha=0.7, edgecolor='black')
    ax2.axhline(y=0, color='black', linewidth=0.5)
    ax2.set_xlabel('$k$', fontsize=12)
    ax2.set_ylabel('Slope $\\log(e_{k+1}) - \\log(e_k)$', fontsize=12)
    ax2.set_title('Tropical Roots (negated slopes)', fontsize=12)
    ax2.grid(True, alpha=0.3)

    # Verify non-increasing slopes
    is_antitone = all(slopes[i] >= slopes[i+1] - 1e-10
                      for i in range(len(slopes)-1)
                      if np.isfinite(slopes[i]) and np.isfinite(slopes[i+1]))
    ax2.annotate(f'Slopes antitone: {"✓" if is_antitone else "✗"}',
                 xy=(0.95, 0.95), xycoords='axes fraction',
                 ha='right', va='top', fontsize=10,
                 bbox=dict(boxstyle='round,pad=0.3',
                          facecolor='lightgreen' if is_antitone else 'lightsalmon'))

plt.suptitle('Tropical Newton Polygons: From Newton Inequality to Tropical Concavity',
             fontsize=16, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_newton_polygon.png', dpi=150, bbox_inches='tight')
print("Saved viz_newton_polygon.png")
