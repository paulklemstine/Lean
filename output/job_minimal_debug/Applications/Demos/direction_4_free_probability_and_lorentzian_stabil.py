"""
Applications of the free spectral edge functional.

Demonstrates real-world applications to:
1. Signal detection in spiked covariance models
2. Quantum Hamiltonian stability margins
3. Certified robustness under structured noise
"""

import numpy as np
from algorithms import (
    FiniteSpectrumLaw, SpectralAtom, spike_law,
    approximate_free_right_edge, solve_spike_edge_quartic,
)


def signal_detection_threshold():
    """Application 1: Signal detection in spiked covariance models.

    In PCA, one observes X = signal + noise. The signal has rank r << n,
    and the noise is modeled as GOE-type. The detection threshold is the
    spectral edge of the noise-only model. Using the free edge instead
    of 2σ gives a structure-aware threshold.
    """
    print("=" * 70)
    print("APPLICATION 1: Signal Detection Thresholds")
    print("=" * 70)

    n = 200  # ambient dimension
    sigma = 1.0  # noise level

    # Scenario: k signals at various strengths
    signals = [0.5, 1.0, 1.5, 2.0, 3.0, 5.0]

    print(f"\nn = {n}, σ = {sigma}")
    print(f"{'Signal λ':>10} | {'Free Edge':>10} | {'2σ':>8} | {'Detectable (free)':>18} | {'Detectable (2σ)':>16}")
    print("-" * 75)

    for lam in signals:
        mu = spike_law(n, lam)
        edge = approximate_free_right_edge(mu, sigma)
        naive = 2 * sigma

        # A signal is detectable if it exceeds the edge
        detect_free = "YES" if lam > edge else "NO"
        detect_naive = "YES" if lam > naive else "NO"

        print(f"{lam:10.2f} | {edge:10.4f} | {naive:8.4f} | {detect_free:>18} | {detect_naive:>16}")

    print("\nNote: The free edge accounts for the spike's own contribution to the")
    print("spectral law, giving more accurate detection thresholds.")


def quantum_hamiltonian_stability():
    """Application 2: Quantum Hamiltonian stability margins.

    For a quantum system with known energy levels, the quantum spectral
    margin quantifies how much semicircular-type noise can be tolerated
    before energy levels are pushed beyond a critical threshold.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 2: Quantum Hamiltonian Stability")
    print("=" * 70)

    # Hydrogen-like energy levels (simplified, scaled)
    energy_levels = [-1.0, -0.25, -0.111, -0.0625]
    weights = [0.4, 0.3, 0.2, 0.1]
    atoms = [SpectralAtom(e, w) for e, w in zip(energy_levels, weights)]
    mu = FiniteSpectrumLaw(atoms)

    print(f"\nHamiltonian energy levels: {energy_levels}")
    print(f"Weights: {weights}")

    noise_levels = [0.1, 0.2, 0.5, 1.0, 2.0]
    print(f"\n{'Noise σ':>10} | {'Free Edge':>10} | {'Max Energy':>11} | {'Margin':>10}")
    print("-" * 50)

    max_e = max(energy_levels)
    for sigma in noise_levels:
        edge = approximate_free_right_edge(mu, sigma)
        margin = edge - max_e
        print(f"{sigma:10.2f} | {edge:10.4f} | {max_e:11.4f} | {margin:10.4f}")

    print("\nThe margin quantifies the energy excursion tolerance under noise.")


def certified_robustness_comparison():
    """Application 3: Certified robustness bound comparison.

    Compare the SharpFailureUpperBound using 2σ vs the free edge.
    Shows that structure-aware certification is strictly tighter.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 3: Certified Robustness Bounds")
    print("=" * 70)

    n_dim = 100  # matrix dimension
    sigma = 1.0
    C = 1.0  # universal constant

    # Various gap parameters ε
    gaps = [1.5, 2.0, 2.5, 3.0, 3.5, 4.0, 5.0]

    # Spike model: one eigenvalue at 1.0
    spike_val = 1.0
    mu = spike_law(n_dim, spike_val)
    free_edge = approximate_free_right_edge(mu, sigma)

    print(f"\nn = {n_dim}, σ = {sigma}, spike = {spike_val}")
    print(f"Classical edge (2σ) = {2*sigma:.4f}")
    print(f"Free edge           = {free_edge:.4f}")
    print()
    print(f"{'Gap ε':>8} | {'Bound (2σ)':>12} | {'Bound (free)':>13} | {'Ratio':>8}")
    print("-" * 50)

    for eps in gaps:
        # Classical: exp(-(max(ε - 2σ, 0))² · n / (C · σ²))
        classical = np.exp(-max(eps - 2*sigma, 0)**2 * n_dim / (C * sigma**2))
        # Free: exp(-(max(ε - R, 0))² · n / (C · σ²))
        free = np.exp(-max(eps - free_edge, 0)**2 * n_dim / (C * sigma**2))

        ratio = free / classical if classical > 1e-300 else float('inf')
        print(f"{eps:8.2f} | {classical:12.6e} | {free:13.6e} | {ratio:8.4f}")

    print("\nRatio < 1 means the free-edge bound is tighter (lower failure probability).")
    print("The improvement is largest near the edge, where structure matters most.")


if __name__ == "__main__":
    signal_detection_threshold()
    quantum_hamiltonian_stability()
    certified_robustness_comparison()


"""
Demo: Free Spectral Edge vs Classical 2σ Threshold

Demonstrates that the structured free edge prediction departs from 2σ
for spike models and matches Monte Carlo eigenvalue simulations.
"""

import numpy as np
from algorithms import spike_law, approximate_free_right_edge, solve_spike_edge_quartic


def goe_matrix(n: int, sigma: float) -> np.ndarray:
    """Generate an n×n GOE matrix with variance σ²/n."""
    A = np.random.randn(n, n) * sigma / np.sqrt(n)
    return (A + A.T) / 2


def monte_carlo_max_eigenvalue(
    n: int, spike: float, sigma: float, trials: int = 1000
) -> dict:
    """Estimate the maximum eigenvalue of diag(spike,0,...,0) + GOE(σ).

    Returns dict with 'mean', 'std', 'percentile_95'.
    """
    D = np.zeros(n)
    D[0] = spike
    max_eigs = []
    for _ in range(trials):
        M = np.diag(D) + goe_matrix(n, sigma)
        eigs = np.linalg.eigvalsh(M)
        max_eigs.append(eigs[-1])
    return {
        'mean': np.mean(max_eigs),
        'std': np.std(max_eigs),
        'percentile_95': np.percentile(max_eigs, 95),
    }


def main():
    np.random.seed(42)
    n = 100
    sigma = 1.0
    spikes = [0.0, 0.5, 1.0, 1.5, 2.0, 3.0, 5.0]
    trials = 1000

    print("=" * 80)
    print("FREE SPECTRAL EDGE vs CLASSICAL 2σ THRESHOLD")
    print("=" * 80)
    print(f"\nDimension n = {n}, noise σ = {sigma}, MC trials = {trials}")
    print()

    header = f"{'Spike λ':>8} | {'2σ':>8} | {'Free Edge':>10} | {'Quartic':>10} | {'MC Mean':>10} | {'MC 95%':>10}"
    print(header)
    print("-" * len(header))

    for spike in spikes:
        mu = spike_law(n, spike)
        edge_bisect = approximate_free_right_edge(mu, sigma)
        edge_quartic = solve_spike_edge_quartic(n, spike, sigma)
        mc = monte_carlo_max_eigenvalue(n, spike, sigma, trials)

        quartic_str = f"{edge_quartic:.4f}" if edge_quartic else "N/A"
        print(
            f"{spike:8.1f} | {2*sigma:8.4f} | {edge_bisect:10.4f} | "
            f"{quartic_str:>10} | {mc['mean']:10.4f} | {mc['percentile_95']:10.4f}"
        )

    print()
    print("=" * 80)
    print("MULTI-ATOM SPECTRUM TEST")
    print("=" * 80)

    from algorithms import FiniteSpectrumLaw, SpectralAtom

    # 3-atom law: eigenvalues at -1, 0, 2 with weights 0.3, 0.4, 0.3
    atoms = [
        SpectralAtom(-1.0, 0.3),
        SpectralAtom(0.0, 0.4),
        SpectralAtom(2.0, 0.3),
    ]
    mu3 = FiniteSpectrumLaw(atoms)
    sigma = 1.0
    edge3 = approximate_free_right_edge(mu3, sigma)
    print(f"\n3-atom law: atoms at -1(0.3), 0(0.4), 2(0.3)")
    print(f"  Free edge (bisection): {edge3:.6f}")
    print(f"  Naive 2σ:              {2*sigma:.6f}")
    print(f"  Max atom location:     2.0")
    print(f"  Gap (edge - max atom): {edge3 - 2.0:.6f}")

    # Monte Carlo for the 3-atom model
    D3 = np.zeros(30)
    D3[:9] = -1.0
    D3[9:21] = 0.0
    D3[21:] = 2.0
    max_eigs = []
    for _ in range(trials):
        M = np.diag(D3) + goe_matrix(30, sigma)
        max_eigs.append(np.linalg.eigvalsh(M)[-1])
    print(f"  MC mean max eig:       {np.mean(max_eigs):.6f}")
    print(f"  MC 95th percentile:    {np.percentile(max_eigs, 95):.6f}")


if __name__ == "__main__":
    main()


"""
Visualization 3: BBP-Type Phase Transition in the Free Edge

Shows how the deviation R(μ,σ) - 2σ transitions as spike strength
crosses the critical threshold, revealing the BBP phase transition.
"""

import numpy as np
import matplotlib.pyplot as plt


def stieltjes_denom_spike(n, spike, x):
    """Stieltjes denominator for spike law μ_{n,λ}."""
    return (1.0/n) / (x - spike)**2 + ((n-1.0)/n) / x**2

def free_edge_spike(n, spike, sigma, steps=300):
    """Compute free edge for spike law by bisection."""
    target = 1.0 / sigma**2
    max_loc = max(0, spike)
    left = max_loc + 1e-8
    right = max_loc + 10*sigma + 10
    for _ in range(steps):
        mid = (left + right) / 2
        if stieltjes_denom_spike(n, spike, mid) > target:
            left = mid
        else:
            right = mid
    return (left + right) / 2


sigma = 1.0
fig, axes = plt.subplots(1, 2, figsize=(14, 5.5))

# Left: BBP transition for various n
ax = axes[0]
ns = [10, 50, 200, 1000]
spikes = np.linspace(0, 4, 200)
colors = plt.cm.viridis(np.linspace(0.2, 0.9, len(ns)))

for n, color in zip(ns, colors):
    deviations = []
    for spike in spikes:
        edge = free_edge_spike(n, spike, sigma)
        deviations.append(edge - 2*sigma)
    ax.plot(spikes, deviations, '-', color=color, linewidth=2,
            label=f'n = {n}')

# BBP critical threshold (for σ=1, threshold is roughly σ²=1 in the limit)
ax.axvline(x=sigma**2, color='red', linestyle=':', linewidth=2, alpha=0.7,
           label=f'BBP threshold λ_c ≈ σ² = {sigma**2}')
ax.axhline(y=0, color='gray', linestyle='-', linewidth=0.5)

ax.set_xlabel('Spike strength λ', fontsize=13)
ax.set_ylabel('R(μ,σ) − 2σ', fontsize=13)
ax.set_title('BBP-Type Phase Transition in Free Edge', fontsize=13)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Right: Heat map of free edge as function of (λ, σ)
ax = axes[1]
n = 100
spikes_grid = np.linspace(0, 5, 100)
sigmas_grid = np.linspace(0.2, 3, 100)
edge_matrix = np.zeros((len(sigmas_grid), len(spikes_grid)))

for i, sig in enumerate(sigmas_grid):
    for j, spk in enumerate(spikes_grid):
        edge_matrix[i, j] = free_edge_spike(n, spk, sig)

im = ax.imshow(edge_matrix, aspect='auto', origin='lower',
               extent=[spikes_grid[0], spikes_grid[-1],
                       sigmas_grid[0], sigmas_grid[-1]],
               cmap='magma')
plt.colorbar(im, ax=ax, label='Free edge R(μ,σ)')
ax.set_xlabel('Spike strength λ', fontsize=13)
ax.set_ylabel('Noise σ', fontsize=13)
ax.set_title(f'Free Edge Landscape (n={n})', fontsize=13)

# Overlay the BBP critical curve λ_c = σ²
sigmas_curve = np.linspace(0.2, np.sqrt(5), 100)
ax.plot(sigmas_curve**2, sigmas_curve, 'w--', linewidth=2,
        label='BBP curve λ = σ²')
ax.legend(fontsize=10, loc='upper left')

plt.tight_layout()
plt.savefig('viz_bbp_transition.png', dpi=150, bbox_inches='tight')
print("Saved viz_bbp_transition.png")


"""
Visualization 1: Free Spectral Edge vs Classical 2σ Threshold

Shows how the structured free edge departs from the naive 2σ threshold
as the spike strength increases. Includes Monte Carlo validation.
"""

import numpy as np
import matplotlib.pyplot as plt


class SpectralAtom:
    def __init__(self, loc, weight):
        self.loc = loc
        self.weight = weight

class FiniteSpectrumLaw:
    def __init__(self, atoms):
        self.atoms = atoms
    def stieltjes_denom(self, x):
        return sum(a.weight / (x - a.loc)**2 for a in self.atoms)
    def max_loc(self):
        return max(a.loc for a in self.atoms)

def spike_law(n, spike):
    return FiniteSpectrumLaw([
        SpectralAtom(spike, 1.0/n),
        SpectralAtom(0.0, (n-1.0)/n),
    ])

def approximate_free_right_edge(mu, sigma, steps=200):
    target = 1.0 / sigma**2
    left = mu.max_loc() + 1e-6
    right = mu.max_loc() + 10*sigma + 10
    for _ in range(steps):
        mid = (left + right) / 2
        if mu.stieltjes_denom(mid) > target:
            left = mid
        else:
            right = mid
    return (left + right) / 2

def goe_matrix(n, sigma):
    A = np.random.randn(n, n) * sigma / np.sqrt(n)
    return (A + A.T) / 2


np.random.seed(42)
n = 100
sigma = 1.0
spikes = np.linspace(0, 6, 30)
trials = 500

free_edges = []
mc_means = []
mc_95 = []

for spike in spikes:
    mu = spike_law(n, spike)
    free_edges.append(approximate_free_right_edge(mu, sigma))

    D = np.zeros(n)
    D[0] = spike
    max_eigs = []
    for _ in range(trials):
        M = np.diag(D) + goe_matrix(n, sigma)
        max_eigs.append(np.linalg.eigvalsh(M)[-1])
    mc_means.append(np.mean(max_eigs))
    mc_95.append(np.percentile(max_eigs, 95))

fig, ax = plt.subplots(1, 1, figsize=(10, 6))
ax.plot(spikes, [2*sigma]*len(spikes), 'r--', linewidth=2, label='Classical 2σ')
ax.plot(spikes, free_edges, 'b-', linewidth=2.5, label='Free spectral edge R(μ,σ)')
ax.plot(spikes, mc_means, 'g^', markersize=5, alpha=0.7, label='Monte Carlo mean max eigenvalue')
ax.fill_between(spikes, mc_means, mc_95, alpha=0.15, color='green', label='MC mean → 95th percentile')
ax.plot(spikes, spikes, 'k:', linewidth=1, alpha=0.5, label='y = λ (spike location)')

ax.set_xlabel('Spike strength λ', fontsize=13)
ax.set_ylabel('Spectral edge / Max eigenvalue', fontsize=13)
ax.set_title('Free Spectral Edge vs Classical 2σ Threshold (n=100, σ=1)', fontsize=14)
ax.legend(fontsize=11, loc='upper left')
ax.grid(True, alpha=0.3)
ax.set_xlim(0, 6)
ax.set_ylim(1.5, 7)

plt.tight_layout()
plt.savefig('viz_edge_comparison.png', dpi=150, bbox_inches='tight')
print("Saved viz_edge_comparison.png")


"""
Visualization 2: Stieltjes Denominator and Edge Equation

Illustrates the strict monotonicity of f_μ(x) and how the free edge
is determined by the intersection f_μ(x) = 1/σ².
"""

import numpy as np
import matplotlib.pyplot as plt


def stieltjes_denom(locs, weights, x):
    """Compute f_μ(x) = Σ wᵢ/(x - aᵢ)²."""
    return sum(w / (x - a)**2 for a, w in zip(locs, weights))


# Setup: 3-atom law
locs = [-1.0, 0.5, 2.0]
weights = [0.3, 0.3, 0.4]
max_loc = max(locs)

# Compute f_μ on x > max_loc
x_vals = np.linspace(max_loc + 0.05, max_loc + 5, 500)
f_vals = [stieltjes_denom(locs, weights, x) for x in x_vals]

fig, axes = plt.subplots(1, 2, figsize=(14, 5.5))

# Left: f_μ(x) with threshold lines
ax = axes[0]
ax.plot(x_vals, f_vals, 'b-', linewidth=2.5, label=r'$f_\mu(x) = \sum w_i/(x-a_i)^2$')

sigmas = [0.5, 1.0, 2.0]
colors = ['red', 'orange', 'green']
for sigma, color in zip(sigmas, colors):
    target = 1.0 / sigma**2
    ax.axhline(y=target, color=color, linestyle='--', linewidth=1.5,
               label=f'1/σ² (σ={sigma})', alpha=0.8)

    # Find intersection
    for i in range(len(x_vals)-1):
        if f_vals[i] >= target >= f_vals[i+1]:
            frac = (target - f_vals[i+1]) / (f_vals[i] - f_vals[i+1])
            x_edge = x_vals[i+1] + frac * (x_vals[i] - x_vals[i+1])
            ax.plot(x_edge, target, 'o', color=color, markersize=10, zorder=5)
            ax.annotate(f'R={x_edge:.2f}', (x_edge, target),
                       textcoords="offset points", xytext=(10, 10),
                       fontsize=10, color=color)
            break

ax.set_xlabel('x', fontsize=13)
ax.set_ylabel(r'$f_\mu(x)$', fontsize=13)
ax.set_title('Stieltjes Denominator (Strictly Decreasing)', fontsize=13)
ax.set_ylim(0, 10)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Vertical lines for atom locations
for a, w in zip(locs, weights):
    ax.axvline(x=a, color='gray', linestyle=':', alpha=0.5)

# Right: Noise monotonicity
ax = axes[1]
sigmas_range = np.linspace(0.2, 3.0, 100)
edges = []
for sigma in sigmas_range:
    target = 1.0 / sigma**2
    # Bisection
    left, right = max_loc + 1e-6, max_loc + 20
    for _ in range(200):
        mid = (left + right) / 2
        if stieltjes_denom(locs, weights, mid) > target:
            left = mid
        else:
            right = mid
    edges.append((left + right) / 2)

ax.plot(sigmas_range, edges, 'b-', linewidth=2.5, label='Free edge R(μ,σ)')
ax.plot(sigmas_range, 2*sigmas_range, 'r--', linewidth=2, label='Classical 2σ')
ax.plot(sigmas_range, [max_loc]*len(sigmas_range), 'k:', linewidth=1.5,
        alpha=0.5, label=f'Max atom loc = {max_loc}')

ax.set_xlabel('Noise strength σ', fontsize=13)
ax.set_ylabel('Edge location', fontsize=13)
ax.set_title('Free Edge Monotonicity in Noise (Theorem 7)', fontsize=13)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('viz_stieltjes_monotonicity.png', dpi=150, bbox_inches='tight')
print("Saved viz_stieltjes_monotonicity.png")
