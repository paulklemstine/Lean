#!/usr/bin/env python3
"""
Applications of DPP-Lorentzian Entanglement Entropy Theory

Demonstrates practical applications of the proven bounds:
1. Rapid entanglement estimation without full diagonalization
2. Entanglement witnesses from polynomial coefficients
3. Area-law verification for free-fermion chains
"""

import numpy as np
from algorithms import (
    elementary_symmetric_dp, fermion_entropy, subsystem_variance,
    entropy_bounds, verify_newton_inequality
)


def tight_binding_kernel(L: int, n_particles: int) -> np.ndarray:
    """
    Correlation kernel for a 1D tight-binding chain of length L
    with n_particles fermions in the ground state.

    K_ij = sum_{k in occupied} phi_k(i) phi_k(j)
    where phi_k(i) = sqrt(2/(L+1)) sin(pi*k*i/(L+1))
    """
    K = np.zeros((L, L))
    for k in range(1, n_particles + 1):
        psi = np.array([np.sqrt(2/(L+1)) * np.sin(np.pi * k * i / (L+1))
                        for i in range(1, L+1)])
        K += np.outer(psi, psi)
    return K


def subsystem_kernel(K: np.ndarray, subsystem: list) -> np.ndarray:
    """Extract the subsystem kernel K_A."""
    return K[np.ix_(subsystem, subsystem)]


def app1_rapid_estimation():
    """
    Application 1: Rapid entanglement estimation using traces only.

    Key insight: e₁ = tr(K_A) and e₂ = (tr(K_A)² - tr(K_A²))/2
    can be computed in O(m²) time, avoiding full O(m³) diagonalization.
    The bound S ≥ 2(e₁ - e₁² + 2e₂) then gives a certified lower bound.
    """
    print("=" * 60)
    print("Application 1: Rapid Entanglement Estimation")
    print("=" * 60)

    L = 50    # chain length
    n = 25    # half-filled
    K = tight_binding_kernel(L, n)

    for m in [4, 8, 12, 16]:
        subsys = list(range(m))
        KA = subsystem_kernel(K, subsys)

        # Method 1: Full diagonalization (O(m³))
        eigenvalues = np.linalg.eigvalsh(KA)
        eigenvalues = np.clip(eigenvalues, 0, 1)
        S_exact = fermion_entropy(eigenvalues)

        # Method 2: Trace-based bound (O(m²))
        e1 = np.trace(KA)
        e2 = (np.trace(KA)**2 - np.trace(KA @ KA)) / 2
        lower_bound = 2 * (e1 - e1**2 + 2 * e2)
        upper_bound = m * np.log(2)

        print(f"\n  Subsystem size m = {m}:")
        print(f"    Exact entropy:      S = {S_exact:.4f}")
        print(f"    Trace lower bound:  2(e₁-e₁²+2e₂) = {lower_bound:.4f}")
        print(f"    Upper bound:        m·log(2) = {upper_bound:.4f}")
        print(f"    Bound tightness:    {lower_bound/S_exact*100:.1f}%")


def app2_entanglement_witness():
    """
    Application 2: Entanglement witness from Newton ratios.

    If ρ_k = e_k²/(e_{k-1}·e_{k+1}) is close to 1 for all k,
    the spectrum is "flat" (close to uniform), indicating high
    entanglement. Large ρ_k indicates spectral concentration.
    """
    print("\n" + "=" * 60)
    print("Application 2: Entanglement Witness from Newton Ratios")
    print("=" * 60)

    cases = [
        ("Maximally entangled", np.full(6, 0.5)),
        ("Near product", np.array([0.99, 0.01, 0.98, 0.02, 0.97, 0.03])),
        ("Mixed", np.array([0.3, 0.7, 0.4, 0.6, 0.5, 0.5])),
        ("One-mode entangled", np.array([0.5, 0.0, 0.0, 0.0, 0.0, 0.0])),
    ]

    for name, spec in cases:
        bounds = entropy_bounds(spec)
        newton = verify_newton_inequality(spec)
        min_ratio = min(r for _, r, _ in newton if r < 1e10) if newton else float('inf')

        print(f"\n  {name}:")
        print(f"    Entropy S = {bounds['entropy']:.4f}")
        print(f"    Min Newton ratio: {min_ratio:.4f}")
        print(f"    Newton ratios: {[f'{r:.2f}' for _, r, _ in newton]}")
        # High entropy correlates with Newton ratios close to 1
        if min_ratio < 2:
            print(f"    → Ratios near 1: HIGH entanglement")
        elif min_ratio < 10:
            print(f"    → Moderate ratios: MODERATE entanglement")
        else:
            print(f"    → Large ratios: LOW entanglement")


def app3_area_law():
    """
    Application 3: Area law verification for free-fermion chains.

    For a 1D free-fermion chain at half-filling, the entanglement
    entropy of a subsystem of size m grows as S ~ (1/3)·log(m).
    We verify this using our coefficient-based bounds.
    """
    print("\n" + "=" * 60)
    print("Application 3: Area Law Verification")
    print("=" * 60)

    L = 100
    n = 50  # half-filling
    K = tight_binding_kernel(L, n)

    sizes = [2, 4, 8, 12, 16, 20, 25]
    print(f"\n  Chain length L = {L}, filling fraction = {n/L}")
    print(f"  {'m':>4s} {'S_exact':>10s} {'S_lower':>10s} {'S_upper':>10s} {'Var':>10s}")
    print("  " + "-" * 50)

    for m in sizes:
        subsys = list(range(m))
        KA = subsystem_kernel(K, subsys)
        eigenvalues = np.clip(np.linalg.eigvalsh(KA), 0, 1)

        S = fermion_entropy(eigenvalues)
        V = subsystem_variance(eigenvalues)
        lower = 2 * V
        upper = m * np.log(2)

        print(f"  {m:4d} {S:10.4f} {lower:10.4f} {upper:10.4f} {V:10.4f}")


if __name__ == "__main__":
    app1_rapid_estimation()
    app2_entanglement_witness()
    app3_area_law()


#!/usr/bin/env python3
"""
Demonstration: Entanglement Entropy Bounds via DPP-Lorentzian Structure

Samples random PSD contractions with eigenvalues in [0,1], computes exact
free-fermion entropy, Lorentzian coefficient surrogates, and visualizes
the proven bounds:
  - S ≥ 2·Var(N_A)  (entropy lower bound from variance)
  - S ≤ m·log(2)    (entropy upper bound)
  - Newton: e_k² ≥ e_{k-1}·e_{k+1}  (ultra-log-concavity)

Also tests the conjecture: can Lorentzian ratio profiles predict entropy?
"""

import numpy as np
from itertools import combinations
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

def binary_entropy(x):
    """h(x) = -x log x - (1-x) log(1-x), with h(0)=h(1)=0."""
    x = np.clip(x, 1e-15, 1 - 1e-15)
    return -x * np.log(x) - (1 - x) * np.log(1 - x)

def fermion_entropy(spectrum):
    """S = sum_i h(lambda_i) for spectrum in [0,1]."""
    return np.sum(binary_entropy(spectrum))

def subsystem_variance(spectrum):
    """Var(N_A) = sum_i lambda_i(1-lambda_i)."""
    return np.sum(spectrum * (1 - spectrum))

def esymm(spectrum, k):
    """k-th elementary symmetric polynomial of spectrum."""
    m = len(spectrum)
    if k < 0 or k > m:
        return 0.0
    if k == 0:
        return 1.0
    total = 0.0
    for S in combinations(range(m), k):
        total += np.prod([spectrum[i] for i in S])
    return total

def newton_ratios(spectrum):
    """Compute rho_k = e_k^2 / (e_{k-1} * e_{k+1}) for k=1,...,m-1."""
    m = len(spectrum)
    ratios = []
    for k in range(1, m):
        ek = esymm(spectrum, k)
        ekm1 = esymm(spectrum, k - 1)
        ekp1 = esymm(spectrum, k + 1)
        denom = ekm1 * ekp1
        if denom > 1e-15:
            ratios.append(ek**2 / denom)
        else:
            ratios.append(float('inf'))
    return ratios

def entropy_surrogate_phi(spectrum, alpha=4.0):
    """
    Candidate surrogate: Phi = alpha * log(2) * (e1 - e1^2 + 2*e2) / m
    Normalized version of the variance-based bound.
    """
    e1 = esymm(spectrum, 1)
    e2 = esymm(spectrum, 2)
    m = len(spectrum)
    return alpha * np.log(2) * (e1 - e1**2 + 2 * e2) / m if m > 0 else 0


def main():
    np.random.seed(42)
    m = 6  # subsystem size

    n_samples = 2000
    entropies = []
    variances = []
    lower_bounds = []
    upper_bounds = []
    e1_vals = []
    e2_vals = []
    newton_violations = 0

    print("=" * 60)
    print("DPP-Lorentzian Entanglement Entropy Bounds")
    print("=" * 60)
    print(f"Subsystem size m = {m}")
    print(f"Number of random spectra: {n_samples}")
    print()

    for _ in range(n_samples):
        # Random spectrum in [0,1]^m
        spectrum = np.random.beta(2, 2, size=m)

        S = fermion_entropy(spectrum)
        V = subsystem_variance(spectrum)
        lb = 2 * V    # proved lower bound: S >= 2*Var
        ub = m * np.log(2)  # proved upper bound: S <= m*log(2)

        entropies.append(S)
        variances.append(V)
        lower_bounds.append(lb)
        upper_bounds.append(ub)
        e1_vals.append(esymm(spectrum, 1))
        e2_vals.append(esymm(spectrum, 2))

        # Check Newton's inequality
        for k in range(1, m):
            ek = esymm(spectrum, k)
            ekm1 = esymm(spectrum, k - 1)
            ekp1 = esymm(spectrum, k + 1)
            if ek**2 < ekm1 * ekp1 - 1e-10:
                newton_violations += 1

    entropies = np.array(entropies)
    variances = np.array(variances)
    lower_bounds = np.array(lower_bounds)
    upper_bounds = np.array(upper_bounds)

    # --- Results ---
    print("=== Theorem Verification ===")
    print(f"  S >= 2*Var holds for all samples: {np.all(entropies >= lower_bounds - 1e-10)}")
    print(f"  S <= m*log(2) holds for all samples: {np.all(entropies <= upper_bounds + 1e-10)}")
    print(f"  Newton inequality violations: {newton_violations}")
    print()

    print("=== Statistics ===")
    print(f"  Entropy range: [{entropies.min():.4f}, {entropies.max():.4f}]")
    print(f"  Variance range: [{variances.min():.4f}, {variances.max():.4f}]")
    print(f"  Upper bound: {m * np.log(2):.4f}")
    print(f"  Average tightness (S / upper_bound): {np.mean(entropies / upper_bounds):.4f}")
    print(f"  Average lower bound ratio (lower / S): {np.mean(lower_bounds / entropies):.4f}")
    print()

    # --- Conjecture testing ---
    print("=== Conjecture: Lorentzian Ratio Entropy Surrogate ===")
    print("Testing: S ≤ Phi_m(rho_1, ..., rho_{m-1})")
    print()

    # Test candidate: Phi = min(rho_k) * f(e1, e2)
    # Simple surrogate: S_surrogate = m * log(2) * (1 - 1/min_rho) when min_rho > 1
    n_test = 500
    conjecture_holds = True
    for _ in range(n_test):
        spectrum = np.random.beta(2, 2, size=m)
        S = fermion_entropy(spectrum)
        ratios = newton_ratios(spectrum)
        finite_ratios = [r for r in ratios if r < 1e10]
        if finite_ratios:
            min_rho = min(finite_ratios)
            # Candidate: S <= m * log(2) * min(1, 2 / min_rho)
            bound = m * np.log(2) * min(1.0, 2.0 / min_rho) if min_rho > 0 else m * np.log(2)
            if S > bound + 1e-8:
                conjecture_holds = False
                print(f"  Counterexample found: S = {S:.4f} > bound = {bound:.4f}")
                print(f"    spectrum = {spectrum}")
                print(f"    min_rho = {min_rho:.4f}")
                break

    if conjecture_holds:
        print(f"  Candidate Phi_m = m*log(2)*min(1, 2/min_rho) held for {n_test} samples")
    print()

    # --- Visualization ---
    fig, axes = plt.subplots(2, 2, figsize=(12, 10))

    # 1. Entropy vs Variance
    ax = axes[0, 0]
    ax.scatter(variances, entropies, alpha=0.3, s=10, c='steelblue')
    v_range = np.linspace(0, variances.max(), 100)
    ax.plot(v_range, 2 * v_range, 'r-', linewidth=2, label=r'$S = 2 \cdot \mathrm{Var}$ (lower bound)')
    ax.axhline(y=m * np.log(2), color='green', linestyle='--', linewidth=2, label=r'$S = m \log 2$ (upper bound)')
    ax.set_xlabel('Variance Var(N_A)')
    ax.set_ylabel('Entropy S')
    ax.set_title('Entropy vs Variance: Proven Bounds')
    ax.legend(fontsize=9)

    # 2. Binary entropy vs quadratic
    ax = axes[0, 1]
    x = np.linspace(0.001, 0.999, 1000)
    hx = binary_entropy(x)
    quad = 2 * x * (1 - x)
    ax.plot(x, hx, 'b-', linewidth=2, label='h(x) = binary entropy')
    ax.plot(x, quad, 'r--', linewidth=2, label='2x(1-x) (lower bound)')
    ax.axhline(y=np.log(2), color='green', linestyle=':', linewidth=2, label='log 2 (upper bound)')
    ax.fill_between(x, quad, hx, alpha=0.15, color='blue')
    ax.set_xlabel('x')
    ax.set_ylabel('h(x)')
    ax.set_title('Binary Entropy Bounds')
    ax.legend(fontsize=9)

    # 3. Newton ratios
    ax = axes[1, 0]
    sample_ratios = []
    for _ in range(200):
        spectrum = np.random.beta(2, 2, size=m)
        ratios = newton_ratios(spectrum)
        sample_ratios.append(ratios)

    for k in range(m - 1):
        vals = [r[k] for r in sample_ratios if r[k] < 100]
        if vals:
            ax.boxplot(vals, positions=[k + 1], widths=0.5)
    ax.axhline(y=1, color='red', linestyle='--', linewidth=1, label=r'$\rho_k = 1$ (Newton bound)')
    ax.set_xlabel('k')
    ax.set_ylabel(r'$\rho_k = e_k^2 / (e_{k-1} e_{k+1})$')
    ax.set_title("Newton Ratios (all ≥ 1)")
    ax.legend()

    # 4. Coefficient-based bounds
    ax = axes[1, 1]
    e1 = np.array(e1_vals)
    e2 = np.array(e2_vals)
    coeff_bound = 2 * (e1 - e1**2 + 2 * e2)
    ax.scatter(coeff_bound, entropies, alpha=0.3, s=10, c='purple')
    line_range = np.linspace(min(coeff_bound.min(), 0), coeff_bound.max(), 100)
    ax.plot(line_range, line_range, 'r-', linewidth=2, label='S = bound (equality line)')
    ax.set_xlabel(r'$2(e_1 - e_1^2 + 2e_2)$ (coefficient lower bound)')
    ax.set_ylabel('Entropy S')
    ax.set_title('Entropy ≥ Coefficient Bound')
    ax.legend(fontsize=9)

    plt.tight_layout()
    plt.savefig('entropy_bounds.png', dpi=150, bbox_inches='tight')
    print("Figure saved to entropy_bounds.png")

    # --- Specific examples ---
    print()
    print("=== Specific Examples ===")
    for name, spec in [
        ("Maximally entangled", np.full(m, 0.5)),
        ("Product state", np.array([1.0, 0.0, 1.0, 0.0, 1.0, 0.0])),
        ("Weak entanglement", np.array([0.9, 0.1, 0.95, 0.05, 0.8, 0.2])),
    ]:
        S = fermion_entropy(spec)
        V = subsystem_variance(spec)
        e_1 = esymm(spec, 1)
        e_2 = esymm(spec, 2)
        coeff_lb = 2 * (e_1 - e_1**2 + 2 * e_2)
        print(f"\n  {name}: λ = {spec}")
        print(f"    Entropy S = {S:.4f}")
        print(f"    Variance = {V:.4f}")
        print(f"    e₁ = {e_1:.4f}, e₂ = {e_2:.4f}")
        print(f"    Coefficient lower bound = {coeff_lb:.4f}")
        print(f"    Upper bound = {m * np.log(2):.4f}")
        print(f"    S ≥ 2·Var: {S:.4f} ≥ {2*V:.4f} ✓" if S >= 2*V - 1e-10 else f"    VIOLATION!")
        ratios = newton_ratios(spec)
        for k, rho in enumerate(ratios):
            print(f"    ρ_{k+1} = {rho:.4f} {'≥ 1 ✓' if rho >= 1 - 1e-10 else '< 1 VIOLATION!'}")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Binary Entropy Bounds and DPP-Lorentzian Structure

This script visualizes the core mathematical relationships proven in the
formalization: binary entropy squeeze between 2x(1-x) and log(2),
entropy vs variance scatter, and Newton ratio distributions.

Uses matplotlib, saves output as PNG.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from itertools import combinations


def binary_entropy(x):
    x = np.clip(x, 1e-15, 1 - 1e-15)
    return -x * np.log(x) - (1 - x) * np.log(1 - x)


def fermion_entropy(spectrum):
    return sum(binary_entropy(x) for x in spectrum)


def subsystem_variance(spectrum):
    return np.sum(spectrum * (1 - spectrum))


def esymm_dp(spectrum, max_k=None):
    m = len(spectrum)
    if max_k is None:
        max_k = m
    e = np.zeros(max_k + 1)
    e[0] = 1.0
    for i in range(m):
        for k in range(min(i + 1, max_k), 0, -1):
            e[k] += spectrum[i] * e[k - 1]
    return e


fig, axes = plt.subplots(2, 2, figsize=(14, 11))
fig.suptitle("Entanglement Entropy via DPP-Lorentzian Structure", fontsize=16, fontweight='bold')

# Panel 1: Binary entropy squeeze
ax = axes[0, 0]
x = np.linspace(0.001, 0.999, 1000)
hx = binary_entropy(x)
lower = 2 * x * (1 - x)
ax.fill_between(x, lower, np.log(2), alpha=0.1, color='blue', label='Proven range for h(x)')
ax.plot(x, hx, 'b-', linewidth=2.5, label='h(x) = binary entropy')
ax.plot(x, lower, 'r--', linewidth=2, label=r'$2x(1-x)$ (lower bound)')
ax.axhline(y=np.log(2), color='green', linestyle=':', linewidth=2, label=r'$\log 2$ (upper bound)')
ax.set_xlabel('x', fontsize=12)
ax.set_ylabel('h(x)', fontsize=12)
ax.set_title('Theorem: $2x(1-x) \\leq h(x) \\leq \\log 2$', fontsize=13)
ax.legend(fontsize=10)
ax.set_xlim(0, 1)
ax.set_ylim(0, 0.8)

# Panel 2: Entropy vs Variance (random spectra)
ax = axes[0, 1]
np.random.seed(42)
m = 6
entropies, variances = [], []
for _ in range(3000):
    spec = np.random.beta(2, 2, size=m)
    entropies.append(fermion_entropy(spec))
    variances.append(subsystem_variance(spec))
entropies = np.array(entropies)
variances = np.array(variances)

scatter = ax.scatter(variances, entropies, alpha=0.2, s=8, c=entropies, cmap='viridis')
v_range = np.linspace(0, variances.max() * 1.1, 100)
ax.plot(v_range, 2 * v_range, 'r-', linewidth=2.5, label=r'$S = 2 \cdot \mathrm{Var}$ (lower)')
ax.axhline(y=m * np.log(2), color='green', linestyle='--', linewidth=2, label=r'$S = m\log 2$ (upper)')
ax.set_xlabel(r'Variance $\mathrm{Var}(N_A)$', fontsize=12)
ax.set_ylabel(r'Entropy $S$', fontsize=12)
ax.set_title(f'Entropy Bounds (m={m}, 3000 samples)', fontsize=13)
ax.legend(fontsize=10)
plt.colorbar(scatter, ax=ax, label='Entropy S')

# Panel 3: Elementary symmetric profiles
ax = axes[1, 0]
spectra = {
    'Flat (λ=0.5)': np.full(m, 0.5),
    'Peaked': np.array([0.9, 0.1, 0.05, 0.05, 0.8, 0.1]),
    'Spread': np.array([0.3, 0.7, 0.4, 0.6, 0.5, 0.5]),
}
for name, spec in spectra.items():
    e = esymm_dp(spec)
    ax.semilogy(range(len(e)), e + 1e-15, 'o-', linewidth=2, markersize=6, label=name)
ax.set_xlabel('k', fontsize=12)
ax.set_ylabel(r'$e_k(\lambda)$ (log scale)', fontsize=12)
ax.set_title('Elementary Symmetric Profiles', fontsize=13)
ax.legend(fontsize=10)
ax.set_xticks(range(m + 1))

# Panel 4: Newton ratio heatmap
ax = axes[1, 1]
n_samples = 200
all_ratios = np.zeros((n_samples, m - 1))
entropies_sorted = []
for idx in range(n_samples):
    spec = np.sort(np.random.beta(2, 2, size=m))[::-1]
    e = esymm_dp(spec)
    entropies_sorted.append(fermion_entropy(spec))
    for k in range(1, m):
        denom = e[k-1] * e[k+1]
        if abs(denom) > 1e-15:
            all_ratios[idx, k-1] = min(e[k]**2 / denom, 20)
        else:
            all_ratios[idx, k-1] = 20

sort_idx = np.argsort(entropies_sorted)
all_ratios_sorted = all_ratios[sort_idx]

im = ax.imshow(all_ratios_sorted.T, aspect='auto', cmap='YlOrRd',
               extent=[0, n_samples, m-0.5, 0.5], vmin=1, vmax=10)
ax.set_xlabel('Sample (sorted by entropy ↑)', fontsize=12)
ax.set_ylabel(r'Newton index $k$', fontsize=12)
ax.set_title(r'Newton Ratios $\rho_k = e_k^2/(e_{k-1}e_{k+1})$', fontsize=13)
ax.set_yticks(range(1, m))
plt.colorbar(im, ax=ax, label=r'$\rho_k$ (all ≥ 1)')

plt.tight_layout(rect=[0, 0, 1, 0.96])
plt.savefig('visualize_entropy.png', dpi=150, bbox_inches='tight')
print("Saved visualize_entropy.png")
