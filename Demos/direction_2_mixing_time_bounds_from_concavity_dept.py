#!/usr/bin/env python3
"""
applications.py — Real-world applications of concavity depth mixing theory.

Demonstrates three application domains:
1. Bayesian inference: faster MCMC on structured posteriors
2. Combinatorial optimization: sampling from discrete log-concave distributions
3. Statistical physics: equilibration of one-dimensional lattice models
"""

import numpy as np
from algorithms import (
    verify_klc, concavity_depth_profile, metropolis_birth_death,
    spectral_gap_dense, mixing_time_bound, discrete_gaussian,
    stretched_exponential, edge_conductances, variance_pi, dirichlet_form
)


# ============================================================================
# Application 1: Bayesian Posterior Sampling
# ============================================================================

def bayesian_posterior_example():
    """
    Demonstrate concavity depth analysis for Bayesian posterior distributions.

    Consider a discrete posterior on {0,...,n} arising from a Gaussian prior
    and binomial likelihood. Higher-order log-concavity of the posterior
    controls how fast MCMC sampling converges.
    """
    print("=" * 70)
    print("APPLICATION 1: Bayesian Posterior Sampling")
    print("=" * 70)
    print()
    print("Scenario: Estimating a binomial proportion θ ∈ {0, 1/n, ..., 1}")
    print("with Gaussian prior and binomial likelihood.")
    print()

    for n in [20, 50, 100]:
        # Prior: discretized Gaussian centered at 0.5
        prior = discrete_gaussian(n, a=2.0)

        # Likelihood: binomial with k=n/2 successes (peaked near 0.5)
        from math import comb
        k_obs = n // 2
        likelihood = np.array([
            comb(n, k_obs) * ((i / n) ** k_obs) * ((1 - i / n) ** (n - k_obs))
            if 0 < i < n else 1e-10
            for i in range(n + 1)
        ], dtype=float)
        likelihood = np.maximum(likelihood, 1e-15)

        posterior = prior * likelihood
        posterior = posterior / posterior.sum()

        depth = concavity_depth_profile(posterior, max_depth=5)
        P = metropolis_birth_death(posterior)
        gap = spectral_gap_dense(P)
        t_mix = mixing_time_bound(gap, posterior.min())

        print(f"  n = {n}:")
        print(f"    Concavity depth: {depth}")
        print(f"    Spectral gap: {gap:.6f}")
        print(f"    Mixing time bound: {t_mix:.1f}")
        print(f"    π_min = {posterior.min():.2e}, π_max = {posterior.max():.4f}")
        print()


# ============================================================================
# Application 2: Combinatorial Sampling
# ============================================================================

def combinatorial_sampling_example():
    """
    Sample from distributions arising in combinatorial optimization.

    Example: sampling graph colorings via a birth-death chain on
    the number of monochromatic edges, or sampling from distributions
    over partition sizes.
    """
    print("=" * 70)
    print("APPLICATION 2: Combinatorial Distribution Sampling")
    print("=" * 70)
    print()
    print("Scenario: Sampling from 'partition-like' distributions")
    print("where π(k) ∝ p(k) · exp(-β·k) for various shapes p(k).")
    print()

    for n in [30, 60]:
        print(f"  n = {n}:")

        # Family 1: Quadratic energy
        pi_quad = np.array([np.exp(-0.01 * i ** 2) for i in range(n + 1)])
        pi_quad /= pi_quad.sum()

        # Family 2: Linear energy (geometric)
        pi_lin = np.array([np.exp(-0.1 * i) for i in range(n + 1)])
        pi_lin /= pi_lin.sum()

        # Family 3: Sublinear energy (stretched exponential)
        pi_sub = stretched_exponential(n, p=0.5, a=0.5, center=0)

        for name, pi in [("Quadratic", pi_quad), ("Linear", pi_lin),
                          ("Sublinear", pi_sub)]:
            depth = concavity_depth_profile(pi)
            P = metropolis_birth_death(pi)
            gap = spectral_gap_dense(P)
            t_mix = mixing_time_bound(gap, pi.min())

            print(f"    {name:12s} | depth={depth}, γ={gap:.6f}, "
                  f"t_mix≤{t_mix:.0f}")
        print()


# ============================================================================
# Application 3: Statistical Physics
# ============================================================================

def statistical_physics_example():
    """
    Analyze equilibration times for one-dimensional lattice models.

    For π(i) ∝ exp(-V(i)), the concavity depth of π measures the
    multiscale convexity of the potential V. Deeper concavity implies
    fewer metastable states and faster equilibration.
    """
    print("=" * 70)
    print("APPLICATION 3: Statistical Physics — Equilibration Times")
    print("=" * 70)
    print()
    print("Scenario: Gibbs measure π(i) ∝ exp(-β·V(i)) on a 1D lattice,")
    print("where V is a discrete potential. Concavity depth of π")
    print("characterizes the multiscale convexity of V.")
    print()

    n = 50

    # Potential 1: Quadratic (harmonic oscillator)
    V_quad = np.array([(i - n / 2) ** 2 for i in range(n + 1)])

    # Potential 2: Double well
    V_double = np.array([0.01 * (i - n / 4) ** 2 * (i - 3 * n / 4) ** 2
                          for i in range(n + 1)])
    V_double = V_double / V_double.max() * 10  # normalize

    # Potential 3: Quartic
    V_quartic = np.array([(i - n / 2) ** 4 for i in range(n + 1)])
    V_quartic = V_quartic / V_quartic.max() * 5

    for beta in [0.01, 0.05, 0.1]:
        print(f"  Inverse temperature β = {beta}:")

        for name, V in [("Quadratic", V_quad), ("Double-well", V_double),
                          ("Quartic", V_quartic)]:
            pi = np.exp(-beta * V)
            pi /= pi.sum()

            depth = concavity_depth_profile(pi, max_depth=5)
            P = metropolis_birth_death(pi)
            gap = spectral_gap_dense(P)
            t_mix = mixing_time_bound(gap, pi.min())

            print(f"    {name:12s} | depth={depth}, γ={gap:.6f}, "
                  f"t_mix≤{t_mix:.0f}")
        print()


# ============================================================================
# Application 4: Poincaré Inequality Verification
# ============================================================================

def poincare_inequality_test():
    """
    Empirically verify the conjectured Poincaré inequality:
        Var_π(f) ≤ C · n^{2/k} · E(f,f)

    Test with random test functions to estimate the Poincaré constant.
    """
    print("=" * 70)
    print("APPLICATION 4: Poincaré Inequality Estimation")
    print("=" * 70)
    print()

    np.random.seed(42)

    for n in [20, 50]:
        pi = discrete_gaussian(n, a=0.1)
        P = metropolis_birth_death(pi)
        depth = concavity_depth_profile(pi)

        # Estimate Poincaré constant from random test functions
        max_ratio = 0.0
        for _ in range(1000):
            f = np.random.randn(n + 1)
            var = variance_pi(pi, f)
            energy = dirichlet_form(pi, P, f)
            if energy > 1e-12:
                ratio = var / energy
                max_ratio = max(max_ratio, ratio)

        gap = spectral_gap_dense(P)
        poincare_const = 1.0 / gap

        print(f"  n = {n}, depth = {depth}:")
        print(f"    Spectral gap: {gap:.6f}")
        print(f"    Theoretical Poincaré const (1/γ): {poincare_const:.2f}")
        print(f"    Empirical max Var/E ratio: {max_ratio:.2f}")
        print(f"    Ratio (empirical/theoretical): {max_ratio/poincare_const:.4f}")
        print()


# ============================================================================
# Main
# ============================================================================

if __name__ == "__main__":
    bayesian_posterior_example()
    print()
    combinatorial_sampling_example()
    print()
    statistical_physics_example()
    print()
    poincare_inequality_test()


#!/usr/bin/env python3
"""
demo.py — Numerical exploration of the concavity-depth mixing conjecture.

Tests the conjecture that for k-fold log-concave distributions on {0,...,n},
the spectral gap γ of the nearest-neighbor reversible chain satisfies:
    γ · n^{2/k} ≥ c_k > 0

for k = 1, 2, 3 and n = 10, 20, 50, 100.

Constructs explicit k-fold log-concave families and computes spectral gaps
of the associated tridiagonal reversible birth-death chains.
"""

import numpy as np
from typing import Tuple, List, Dict


def is_log_concave(seq: np.ndarray) -> bool:
    """Check if a positive sequence is log-concave: a[i]^2 >= a[i-1]*a[i+1]."""
    for i in range(1, len(seq) - 1):
        if seq[i] ** 2 < seq[i - 1] * seq[i + 1] - 1e-12:
            return False
    return True


def ratio_sequence(seq: np.ndarray) -> np.ndarray:
    """Compute the ratio sequence r[i] = a[i+1] / a[i]."""
    return seq[1:] / seq[:-1]


def check_k_fold_log_concave(seq: np.ndarray, k: int) -> bool:
    """Check if seq is k-fold log-concave."""
    if k == 0:
        return np.all(seq > 0)
    if not np.all(seq > 0):
        return False
    if not is_log_concave(seq):
        return False
    if len(seq) <= 2:
        return True
    r = ratio_sequence(seq)
    return check_k_fold_log_concave(r, k - 1)


def build_birth_death_chain(pi: np.ndarray) -> np.ndarray:
    """
    Build the transition matrix of the Metropolis birth-death chain
    reversible w.r.t. pi on {0, ..., n}.

    P(i, i+1) = min(1, pi[i+1]/pi[i]) / 2
    P(i, i-1) = min(1, pi[i-1]/pi[i]) / 2
    P(i, i) = 1 - P(i, i+1) - P(i, i-1)
    """
    n = len(pi) - 1
    P = np.zeros((n + 1, n + 1))
    for i in range(n + 1):
        right = 0.0
        left = 0.0
        if i < n:
            right = min(1.0, pi[i + 1] / pi[i]) / 2
            P[i, i + 1] = right
        if i > 0:
            left = min(1.0, pi[i - 1] / pi[i]) / 2
            P[i, i - 1] = left
        P[i, i] = 1.0 - right - left
    return P


def spectral_gap(P: np.ndarray) -> float:
    """Compute the spectral gap of a transition matrix P.
    gap = 1 - lambda_2, where lambda_2 is the second-largest eigenvalue."""
    eigenvalues = np.sort(np.real(np.linalg.eigvals(P)))[::-1]
    return 1.0 - eigenvalues[1]


def discrete_gaussian(n: int, a: float = 1.0, center: float = None) -> np.ndarray:
    """Discrete Gaussian: pi(i) ∝ exp(-a * (i - center)^2)."""
    if center is None:
        center = n / 2
    x = np.arange(n + 1, dtype=float)
    logpi = -a * (x - center) ** 2
    pi = np.exp(logpi - logpi.max())
    return pi / pi.sum()


def stretched_exponential(n: int, p: float, a: float = 1.0,
                          center: float = None) -> np.ndarray:
    """Stretched exponential: pi(i) ∝ exp(-a * |i - center|^p)."""
    if center is None:
        center = n / 2
    x = np.arange(n + 1, dtype=float)
    logpi = -a * np.abs(x - center) ** p
    pi = np.exp(logpi - logpi.max())
    return pi / pi.sum()


def truncated_binomial(n: int, p_param: float = 0.5) -> np.ndarray:
    """Truncated binomial: pi(i) ∝ C(n, i) * p^i * (1-p)^{n-i}."""
    from math import comb
    pi = np.array([comb(n, i) * p_param ** i * (1 - p_param) ** (n - i)
                   for i in range(n + 1)], dtype=float)
    return pi / pi.sum()


def ratio_constructed_klc(n: int, k: int, decay: float = 0.1) -> np.ndarray:
    """
    Construct a k-fold log-concave sequence by building from the bottom up.
    Start with a constant ratio sequence at depth k, then integrate up.
    """
    # Start with a constant at the deepest level
    seq = np.ones(max(n + 1 - k, 2))

    # Integrate up k times: from ratio sequence back to original
    for _ in range(k):
        # Given ratios r[i], reconstruct a[i] = a[0] * prod(r[0..i-1])
        new_len = len(seq) + 1
        new_seq = np.ones(new_len)
        for i in range(1, new_len):
            if i - 1 < len(seq):
                new_seq[i] = new_seq[i - 1] * max(seq[i - 1], 0.01)
            else:
                new_seq[i] = new_seq[i - 1] * seq[-1]
        seq = new_seq

    # Pad or truncate to n+1
    if len(seq) < n + 1:
        seq = np.pad(seq, (0, n + 1 - len(seq)), constant_values=seq[-1])
    seq = seq[:n + 1]
    seq = seq / seq.sum()
    return seq


def run_experiment(n: int, k: int, families: Dict[str, np.ndarray]) -> Dict:
    """Run the conjecture test for given n, k on multiple families."""
    results = {}
    exponent = 2.0 / k

    for name, pi in families.items():
        if not check_k_fold_log_concave(pi, k):
            results[name] = {
                'is_klc': False,
                'spectral_gap': None,
                'rescaled_gap': None
            }
            continue

        P = build_birth_death_chain(pi)
        gap = spectral_gap(P)
        rescaled = gap * (n ** exponent)

        results[name] = {
            'is_klc': True,
            'spectral_gap': gap,
            'rescaled_gap': rescaled,
            'pi_min': pi.min(),
            'pi_max': pi.max()
        }

    return results


def main():
    print("=" * 80)
    print("CONCAVITY DEPTH MIXING CONJECTURE — NUMERICAL EXPLORATION")
    print("=" * 80)
    print()
    print("Conjecture: For k-fold log-concave π on {0,...,n},")
    print("  γ(P_π) · n^{2/k} ≥ c_k > 0")
    print()

    ns = [10, 20, 50, 100]
    ks = [1, 2, 3]

    for k in ks:
        print(f"\n{'=' * 70}")
        print(f"  k = {k}  |  Exponent 2/k = {2.0/k:.4f}")
        print(f"{'=' * 70}")

        for n in ns:
            print(f"\n  n = {n}")
            print(f"  {'Family':<30} {'KLC?':<6} {'γ':<12} {'γ·n^(2/k)':<12}")
            print(f"  {'-' * 60}")

            families = {
                'Gaussian(a=0.1)': discrete_gaussian(n, a=0.1),
                'Gaussian(a=1.0)': discrete_gaussian(n, a=1.0),
                'Binomial(p=0.5)': truncated_binomial(n, p_param=0.5),
                'Stretch-exp(p=1)': stretched_exponential(n, p=1.0, a=0.1),
                'Stretch-exp(p=2)': stretched_exponential(n, p=2.0, a=0.05),
                'Stretch-exp(p=3)': stretched_exponential(n, p=3.0, a=0.01),
                'Ratio-constructed': ratio_constructed_klc(n, k),
                'Uniform': np.ones(n + 1) / (n + 1),
            }

            results = run_experiment(n, k, families)

            for name, res in results.items():
                if res['is_klc']:
                    print(f"  {name:<30} {'Yes':<6} {res['spectral_gap']:<12.6f} "
                          f"{res['rescaled_gap']:<12.6f}")
                else:
                    print(f"  {name:<30} {'No':<6} {'—':<12} {'—':<12}")

    # Summary table
    print(f"\n\n{'=' * 70}")
    print("SUMMARY: Minimum rescaled gap γ·n^(2/k) across all tested families")
    print(f"{'=' * 70}")
    print(f"{'k':<6} {'n=10':<15} {'n=20':<15} {'n=50':<15} {'n=100':<15}")
    print(f"{'-' * 66}")

    for k in ks:
        row = f"{k:<6} "
        for n in ns:
            families = {
                'Gaussian(a=0.1)': discrete_gaussian(n, a=0.1),
                'Gaussian(a=1.0)': discrete_gaussian(n, a=1.0),
                'Binomial(p=0.5)': truncated_binomial(n, p_param=0.5),
                'Uniform': np.ones(n + 1) / (n + 1),
            }
            results = run_experiment(n, k, families)
            min_rescaled = min(
                r['rescaled_gap'] for r in results.values()
                if r['is_klc'] and r['rescaled_gap'] is not None
            )
            row += f"{min_rescaled:<15.6f}"
        print(row)

    print(f"\n{'=' * 70}")
    print("INTERPRETATION:")
    print("If γ·n^(2/k) stays bounded away from 0 as n grows,")
    print("the conjecture is supported. If it collapses to 0, it is falsified.")
    print(f"{'=' * 70}")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization 3: Mixing Time Comparison

Compares mixing time bounds for distributions with different concavity depths,
showing how the O(n^{2/k} log n) scaling varies with k.
"""

import numpy as np
import matplotlib.pyplot as plt
from algorithms import (
    discrete_gaussian, stretched_exponential, metropolis_birth_death,
    spectral_gap_dense, mixing_time_bound, concavity_depth_profile
)

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

# Left panel: Theoretical mixing time curves
ns = np.arange(5, 201)

for k, color, label in [(1, '#F44336', 'k=1: O(n² log n)'),
                          (2, '#2196F3', 'k=2: O(n log n)'),
                          (3, '#4CAF50', 'k=3: O(n^{2/3} log n)'),
                          (5, '#FF9800', 'k=5: O(n^{2/5} log n)')]:
    t_mix = ns ** (2.0 / k) * np.log(ns + 1)
    ax1.plot(ns, t_mix, color=color, label=label, linewidth=2)

ax1.set_xlabel('State space size n', fontsize=12)
ax1.set_ylabel('Mixing time bound', fontsize=12)
ax1.set_title('Theoretical Mixing Time Scaling\nby Concavity Depth k',
              fontsize=13, fontweight='bold')
ax1.legend(fontsize=10)
ax1.set_yscale('log')
ax1.grid(True, alpha=0.3)

# Right panel: Empirical mixing times for Gaussian families
ns_test = [10, 15, 20, 25, 30, 40, 50]

families = {
    'Gauss a=0.01': (0.01, '#F44336'),
    'Gauss a=0.05': (0.05, '#2196F3'),
    'Gauss a=0.1': (0.1, '#4CAF50'),
    'Gauss a=0.5': (0.5, '#FF9800'),
}

for name, (a_val, color) in families.items():
    t_mixes = []
    valid_ns = []
    for n in ns_test:
        pi = discrete_gaussian(n, a=a_val)
        depth = concavity_depth_profile(pi, max_depth=5)
        P = metropolis_birth_death(pi)
        gap = spectral_gap_dense(P)
        t = mixing_time_bound(gap, pi.min())
        if t < 1e10:
            t_mixes.append(t)
            valid_ns.append(n)

    if valid_ns:
        depth = concavity_depth_profile(discrete_gaussian(valid_ns[0], a=a_val))
        ax2.plot(valid_ns, t_mixes, 'o-', color=color,
                 label=f'{name} (depth≥{depth})', linewidth=2, markersize=5)

ax2.set_xlabel('State space size n', fontsize=12)
ax2.set_ylabel('Mixing time bound (1/γ · log(1/π_min))', fontsize=12)
ax2.set_title('Empirical Mixing Times\nDiscrete Gaussian Families',
              fontsize=13, fontweight='bold')
ax2.legend(fontsize=9)
ax2.set_yscale('log')
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('mixing_comparison.png', dpi=150, bbox_inches='tight')
print("Saved mixing_comparison.png")


#!/usr/bin/env python3
"""
Visualization 2: Ratio Tower

Visualizes the iterated ratio sequences of a k-fold log-concave distribution,
showing the tower of concavity constraints. Each level shows the ratio
sequence becoming smoother, illustrating how deeper concavity regularizes
the distribution.
"""

import numpy as np
import matplotlib.pyplot as plt
from algorithms import verify_klc, discrete_gaussian, stretched_exponential

fig, axes = plt.subplots(2, 3, figsize=(15, 8))

n = 40

# Top row: discrete Gaussian
pi_gauss = discrete_gaussian(n, a=0.05)
is_klc, tower = verify_klc(pi_gauss, k=5)

for col in range(3):
    ax = axes[0, col]
    if col < len(tower):
        seq = tower[col]
        ax.bar(range(len(seq)), seq, color='#2196F3', alpha=0.7, width=0.8)
        ax.set_title(f'Depth {col}: {"Original" if col == 0 else f"Ratio^{col}"}',
                     fontsize=11)

        # Check and annotate log-concavity
        from algorithms import is_log_concave
        lc = is_log_concave(seq)
        ax.annotate(f'Log-concave: {"✓" if lc else "✗"}',
                    xy=(0.02, 0.95), xycoords='axes fraction',
                    fontsize=10, color='green' if lc else 'red',
                    fontweight='bold', va='top')
    ax.set_xlabel('Index', fontsize=10)

axes[0, 0].set_ylabel('Discrete Gaussian\n(a=0.05)', fontsize=11)

# Bottom row: stretched exponential
pi_stretch = stretched_exponential(n, p=1.5, a=0.1)
is_klc2, tower2 = verify_klc(pi_stretch, k=5)

for col in range(3):
    ax = axes[1, col]
    if col < len(tower2):
        seq = tower2[col]
        ax.bar(range(len(seq)), seq, color='#FF5722', alpha=0.7, width=0.8)
        ax.set_title(f'Depth {col}: {"Original" if col == 0 else f"Ratio^{col}"}',
                     fontsize=11)

        from algorithms import is_log_concave
        lc = is_log_concave(seq)
        ax.annotate(f'Log-concave: {"✓" if lc else "✗"}',
                    xy=(0.02, 0.95), xycoords='axes fraction',
                    fontsize=10, color='green' if lc else 'red',
                    fontweight='bold', va='top')
    ax.set_xlabel('Index', fontsize=10)

axes[1, 0].set_ylabel('Stretched Exp.\n(p=1.5, a=0.1)', fontsize=11)

plt.suptitle('Ratio Tower: Iterated Ratio Sequences\n'
             'Each level shows progressively smoother structure',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('ratio_tower.png', dpi=150, bbox_inches='tight')
print("Saved ratio_tower.png")


#!/usr/bin/env python3
"""
Visualization 1: Spectral Gap Landscape

Plots the rescaled spectral gap γ · n^{2/k} as a function of n
for different concavity depths k = 1, 2, 3, using discrete Gaussian
distributions. Shows how deeper concavity changes the scaling behavior.
"""

import numpy as np
import matplotlib.pyplot as plt
from algorithms import (
    discrete_gaussian, metropolis_birth_death, spectral_gap_dense,
    rescaled_spectral_gap, verify_klc
)

fig, axes = plt.subplots(1, 3, figsize=(15, 5), sharey=False)

ns = list(range(5, 61, 5))
a_values = [0.01, 0.05, 0.1, 0.2]
colors = ['#2196F3', '#FF5722', '#4CAF50', '#9C27B0']

for idx, k in enumerate([1, 2, 3]):
    ax = axes[idx]

    for a_idx, a in enumerate(a_values):
        gaps = []
        valid_ns = []
        for n in ns:
            pi = discrete_gaussian(n, a=a)
            is_klc, _ = verify_klc(pi, k)
            if is_klc:
                P = metropolis_birth_death(pi)
                gap = spectral_gap_dense(P)
                rg = rescaled_spectral_gap(gap, n, k)
                gaps.append(rg)
                valid_ns.append(n)

        if valid_ns:
            ax.plot(valid_ns, gaps, 'o-', color=colors[a_idx],
                    label=f'a={a}', markersize=4, linewidth=1.5)

    ax.set_title(f'k = {k}  (exponent 2/k = {2/k:.2f})', fontsize=13)
    ax.set_xlabel('State space size n', fontsize=11)
    ax.set_ylabel(f'γ · n^{{2/{k}}}', fontsize=11)
    ax.legend(title='Gaussian param a', fontsize=9)
    ax.grid(True, alpha=0.3)
    ax.set_ylim(bottom=0)

plt.suptitle('Rescaled Spectral Gap vs. State Space Size\n'
             'Concavity Depth Mixing Conjecture Test',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('spectral_landscape.png', dpi=150, bbox_inches='tight')
print("Saved spectral_landscape.png")
