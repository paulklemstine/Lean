#!/usr/bin/env python3
"""
PAC-Bayesian Prime-Spectral Generalization: Numerical Demonstrations

This script demonstrates the core theorems formalized in Lean:
1. KL divergence nonnegativity (Gibbs inequality)
2. The Donsker-Varadhan / log-sum-exp variational inequality
3. Gibbs posterior construction and its optimality
4. PAC-Bayes generalization bounds

We use concrete finite "prime spectra" to make the abstract theory tangible.
"""

import numpy as np
import matplotlib.pyplot as plt
from scipy.special import rel_entr
from typing import Callable

# ============================================================
# Core definitions (matching the Lean formalization)
# ============================================================

def kl_div(Q: np.ndarray, P: np.ndarray) -> float:
    """KL divergence KL(Q || P) for finite distributions."""
    result = 0.0
    for q, p in zip(Q, P):
        if q > 0 and p > 0:
            result += q * np.log(q / p)
    return result

def gibbs_posterior(P: np.ndarray, energy: np.ndarray, beta: float) -> np.ndarray:
    """Gibbs posterior: G(p) = P(p) * exp(-beta * E(p)) / Z"""
    log_unnorm = np.log(P) - beta * energy
    log_unnorm -= np.max(log_unnorm)  # numerical stability
    unnorm = np.exp(log_unnorm)
    return unnorm / unnorm.sum()

def free_energy(Q: np.ndarray, energy: np.ndarray, P: np.ndarray, beta: float) -> float:
    """Free energy: <E>_Q + (1/beta) * KL(Q || P)"""
    return np.dot(Q, energy) + (1.0 / beta) * kl_div(Q, P)

def log_sum_exp_bound(Q: np.ndarray, f: np.ndarray, P: np.ndarray) -> tuple:
    """Returns (LHS, RHS) of the Donsker-Varadhan inequality:
    sum Q*f <= KL(Q||P) + log(sum P*exp(f))"""
    lhs = np.dot(Q, f)
    rhs = kl_div(Q, P) + np.log(np.dot(P, np.exp(f)))
    return lhs, rhs

# ============================================================
# Demo 1: KL Divergence Properties
# ============================================================

def demo_kl_properties():
    """Demonstrate KL divergence nonnegativity and information-theoretic properties."""
    print("=" * 60)
    print("Demo 1: KL Divergence Properties (Gibbs Inequality)")
    print("=" * 60)

    n_points = 5  # "prime spectrum" size
    np.random.seed(42)

    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    # Test KL nonnegativity for many random pairs
    n_trials = 1000
    kl_values = []
    for _ in range(n_trials):
        P = np.random.dirichlet(np.ones(n_points))
        Q = np.random.dirichlet(np.ones(n_points))
        kl_values.append(kl_div(Q, P))

    axes[0].hist(kl_values, bins=50, color='steelblue', edgecolor='black', alpha=0.7)
    axes[0].axvline(x=0, color='red', linestyle='--', linewidth=2, label='KL = 0')
    axes[0].set_xlabel('KL(Q || P)')
    axes[0].set_ylabel('Count')
    axes[0].set_title(f'KL Nonnegativity: min = {min(kl_values):.6f}')
    axes[0].legend()

    # KL = 0 iff Q = P
    alphas = np.linspace(0.01, 2, 100)
    P_fixed = np.array([0.3, 0.2, 0.1, 0.25, 0.15])
    Q_fixed = np.array([0.1, 0.4, 0.15, 0.2, 0.15])
    kl_interp = []
    for a in alphas:
        Q_a = a * Q_fixed + (1 - a) * P_fixed
        Q_a = Q_a / Q_a.sum()
        kl_interp.append(kl_div(Q_a, P_fixed))

    axes[1].plot(alphas, kl_interp, 'b-', linewidth=2)
    axes[1].axhline(y=0, color='red', linestyle='--', alpha=0.5)
    axes[1].set_xlabel('Interpolation parameter α')
    axes[1].set_ylabel('KL(Q_α || P)')
    axes[1].set_title('KL along interpolation (minimum at Q=P)')

    # Asymmetry of KL
    kl_forward = []
    kl_backward = []
    for _ in range(200):
        P = np.random.dirichlet(np.ones(n_points))
        Q = np.random.dirichlet(np.ones(n_points))
        kl_forward.append(kl_div(Q, P))
        kl_backward.append(kl_div(P, Q))

    axes[2].scatter(kl_forward, kl_backward, alpha=0.5, s=20, color='steelblue')
    axes[2].plot([0, max(kl_forward)], [0, max(kl_forward)], 'r--', label='y=x')
    axes[2].set_xlabel('KL(Q || P)')
    axes[2].set_ylabel('KL(P || Q)')
    axes[2].set_title('KL Asymmetry')
    axes[2].legend()

    plt.tight_layout()
    plt.savefig('Bridges/demos/kl_properties.png', dpi=150, bbox_inches='tight')
    plt.close()
    print(f"  Generated kl_properties.png")
    print(f"  All {n_trials} KL values nonneg: {all(k >= -1e-12 for k in kl_values)}")
    print()

# ============================================================
# Demo 2: Donsker-Varadhan Variational Inequality
# ============================================================

def demo_donsker_varadhan():
    """Demonstrate the log-sum-exp / Donsker-Varadhan inequality."""
    print("=" * 60)
    print("Demo 2: Donsker-Varadhan Variational Inequality")
    print("=" * 60)

    n_points = 6
    np.random.seed(123)

    P = np.random.dirichlet(np.ones(n_points) * 2)
    f = np.random.randn(n_points) * 2

    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    # Test inequality for many random Q
    n_trials = 2000
    lhs_vals = []
    rhs_vals = []
    gaps = []
    for _ in range(n_trials):
        Q = np.random.dirichlet(np.ones(n_points))
        lhs, rhs = log_sum_exp_bound(Q, f, P)
        lhs_vals.append(lhs)
        rhs_vals.append(rhs)
        gaps.append(rhs - lhs)

    axes[0].scatter(lhs_vals, rhs_vals, alpha=0.3, s=10, color='steelblue')
    mn, mx = min(min(lhs_vals), min(rhs_vals)), max(max(lhs_vals), max(rhs_vals))
    axes[0].plot([mn, mx], [mn, mx], 'r--', linewidth=2, label='LHS = RHS')
    axes[0].set_xlabel('∑ Q(p)·f(p)  (LHS)')
    axes[0].set_ylabel('KL(Q||P) + log ∑ P(p)·exp(f(p))  (RHS)')
    axes[0].set_title('Donsker-Varadhan: LHS ≤ RHS always')
    axes[0].legend()

    # The Gibbs posterior achieves equality
    G = gibbs_posterior(P, -f, 1.0)  # energy = -f, so posterior ∝ P*exp(f)
    lhs_gibbs, rhs_gibbs = log_sum_exp_bound(G, f, P)
    axes[0].scatter([lhs_gibbs], [rhs_gibbs], color='red', s=100, zorder=5,
                    marker='*', label=f'Gibbs (gap={rhs_gibbs-lhs_gibbs:.2e})')
    axes[0].legend()

    axes[1].hist(gaps, bins=50, color='steelblue', edgecolor='black', alpha=0.7)
    axes[1].axvline(x=0, color='red', linestyle='--', linewidth=2)
    axes[1].set_xlabel('Gap (RHS - LHS)')
    axes[1].set_ylabel('Count')
    axes[1].set_title(f'All gaps ≥ 0: min = {min(gaps):.2e}')

    plt.tight_layout()
    plt.savefig('Bridges/demos/donsker_varadhan.png', dpi=150, bbox_inches='tight')
    plt.close()
    print(f"  Generated donsker_varadhan.png")
    print(f"  All {n_trials} gaps nonneg: {all(g >= -1e-10 for g in gaps)}")
    print(f"  Gibbs posterior gap: {rhs_gibbs - lhs_gibbs:.2e} (≈ 0, equality)")
    print()

# ============================================================
# Demo 3: Gibbs Posterior Variational Optimality
# ============================================================

def demo_gibbs_optimality():
    """Demonstrate that the Gibbs posterior minimizes free energy."""
    print("=" * 60)
    print("Demo 3: Gibbs Posterior Variational Optimality")
    print("=" * 60)

    n_points = 5
    np.random.seed(456)

    P = np.ones(n_points) / n_points  # uniform prior
    energy = np.array([0.1, 0.8, 0.3, 0.9, 0.5])  # semantic gap / loss

    betas = np.logspace(-1, 2, 50)

    fig, axes = plt.subplots(1, 3, figsize=(16, 5))

    # For each beta, compare Gibbs free energy to random posteriors
    for beta in [0.5, 2.0, 10.0]:
        G = gibbs_posterior(P, energy, beta)
        fe_gibbs = free_energy(G, energy, P, beta)

        fe_random = []
        for _ in range(500):
            Q = np.random.dirichlet(np.ones(n_points))
            fe_random.append(free_energy(Q, energy, P, beta))

        idx = [0.5, 2.0, 10.0].index(beta)
        axes[idx].hist(fe_random, bins=40, color='steelblue', edgecolor='black',
                       alpha=0.7, label='Random Q')
        axes[idx].axvline(x=fe_gibbs, color='red', linewidth=2,
                          label=f'Gibbs (β={beta})')
        axes[idx].set_xlabel('Free Energy')
        axes[idx].set_ylabel('Count')
        axes[idx].set_title(f'β = {beta}: Gibbs = {fe_gibbs:.4f}')
        axes[idx].legend()

    plt.tight_layout()
    plt.savefig('Bridges/demos/gibbs_optimality.png', dpi=150, bbox_inches='tight')
    plt.close()
    print(f"  Generated gibbs_optimality.png")

    # Temperature sweep: show concentration as beta → ∞
    fig, axes = plt.subplots(1, 2, figsize=(12, 5))

    betas_sweep = np.logspace(-1, 2, 200)
    posteriors = []
    free_energies = []
    for beta in betas_sweep:
        G = gibbs_posterior(P, energy, beta)
        posteriors.append(G)
        free_energies.append(free_energy(G, energy, P, beta))

    posteriors = np.array(posteriors)
    for i in range(n_points):
        axes[0].semilogx(betas_sweep, posteriors[:, i],
                         label=f'p{i} (E={energy[i]:.1f})', linewidth=2)
    axes[0].set_xlabel('Inverse temperature β')
    axes[0].set_ylabel('Posterior weight')
    axes[0].set_title('Gibbs posterior concentration')
    axes[0].legend(fontsize=8)

    axes[1].semilogx(betas_sweep, free_energies, 'b-', linewidth=2)
    axes[1].set_xlabel('Inverse temperature β')
    axes[1].set_ylabel('Free energy F(G_β)')
    axes[1].set_title('Free energy vs temperature')

    plt.tight_layout()
    plt.savefig('Bridges/demos/temperature_sweep.png', dpi=150, bbox_inches='tight')
    plt.close()
    print(f"  Generated temperature_sweep.png")
    print(f"  At β→∞, Gibbs concentrates on min-energy prime (p0, E=0.1)")
    print()

# ============================================================
# Demo 4: PAC-Bayes Generalization Bound
# ============================================================

def demo_pac_bayes_bound():
    """Demonstrate the PAC-Bayes generalization bound."""
    print("=" * 60)
    print("Demo 4: PAC-Bayes Generalization Bound")
    print("=" * 60)

    n_primes = 8  # prime spectrum size
    np.random.seed(789)

    P = np.ones(n_primes) / n_primes  # uniform prior
    delta = 0.05

    # Simulate: each prime p assigns a "true loss" to data
    true_losses = np.random.rand(n_primes) * 0.5 + 0.25  # bounded in [0.25, 0.75]

    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    sample_sizes = np.arange(10, 501, 10)
    n_experiments = 200

    bound_vals = []
    actual_gaps = []

    for n in sample_sizes:
        gaps = []
        for _ in range(n_experiments):
            # Generate dataset: empirical losses
            empirical_losses = np.zeros(n_primes)
            for p_idx in range(n_primes):
                samples = np.random.binomial(1, true_losses[p_idx], n) / 1.0
                empirical_losses[p_idx] = samples.mean()

            # Choose a posterior (Gibbs with beta=2)
            Q = gibbs_posterior(P, empirical_losses, 2.0)

            true_risk = np.dot(Q, true_losses)
            emp_risk = np.dot(Q, empirical_losses)
            gaps.append(true_risk - emp_risk)

        kl = kl_div(Q, P)
        bound = np.sqrt((kl + np.log(1 / delta)) / (2 * n))
        bound_vals.append(bound)
        actual_gaps.append(np.percentile(gaps, 95))  # 95th percentile

    axes[0].plot(sample_sizes, bound_vals, 'r-', linewidth=2,
                 label='PAC-Bayes bound')
    axes[0].plot(sample_sizes, actual_gaps, 'b-', linewidth=2,
                 label='95th percentile gap')
    axes[0].fill_between(sample_sizes, 0, bound_vals, alpha=0.1, color='red')
    axes[0].set_xlabel('Sample size n')
    axes[0].set_ylabel('Generalization gap')
    axes[0].set_title('PAC-Bayes Bound vs Actual Gap')
    axes[0].legend()
    axes[0].set_ylim(bottom=-0.05)

    # Effect of KL divergence on bound
    kl_range = np.linspace(0.01, 5, 100)
    n_fixed = 100
    for delta_val in [0.01, 0.05, 0.1]:
        bounds = np.sqrt((kl_range + np.log(1 / delta_val)) / (2 * n_fixed))
        axes[1].plot(kl_range, bounds, linewidth=2,
                     label=f'δ={delta_val}')

    axes[1].set_xlabel('KL(Q || P)')
    axes[1].set_ylabel('Bound (sqrt term)')
    axes[1].set_title(f'Bound vs KL divergence (n={n_fixed})')
    axes[1].legend()

    plt.tight_layout()
    plt.savefig('Bridges/demos/pac_bayes_bound.png', dpi=150, bbox_inches='tight')
    plt.close()
    print(f"  Generated pac_bayes_bound.png")
    print()

# ============================================================
# Demo 5: Prime-Spectral Semantic Interpretation
# ============================================================

def demo_prime_spectral():
    """Demonstrate the prime-spectral interpretation of countermodel learning."""
    print("=" * 60)
    print("Demo 5: Prime-Spectral Semantic Interpretation")
    print("=" * 60)

    # Simulate a "proof semiring" with 6 prime ideals
    prime_labels = ['𝔭₁', '𝔭₂', '𝔭₃', '𝔭₄', '𝔭₅', '𝔭₆']
    n_primes = len(prime_labels)

    # Each prime represents a potential countermodel
    # Loss measures how well a prime separates claimed from actual provability
    np.random.seed(2024)

    # Prior: uniform over primes
    P = np.ones(n_primes) / n_primes

    # Semantic losses for different "proof attempts"
    proof_attempts = {
        'Strong theorem': np.array([0.9, 0.8, 0.95, 0.85, 0.7, 0.6]),
        'Weak lemma': np.array([0.1, 0.2, 0.15, 0.3, 0.25, 0.4]),
        'False conjecture': np.array([0.05, 0.1, 0.02, 0.08, 0.15, 0.03]),
    }

    fig, axes = plt.subplots(1, 3, figsize=(16, 5))

    for idx, (name, losses) in enumerate(proof_attempts.items()):
        betas = [0.5, 2, 10]
        x = np.arange(n_primes)
        width = 0.2

        axes[idx].bar(x - width, P, width, label='Prior', color='gray', alpha=0.6)
        for j, beta in enumerate(betas):
            G = gibbs_posterior(P, losses, beta)
            axes[idx].bar(x + j * width, G, width,
                          label=f'Gibbs β={beta}', alpha=0.8)

        axes[idx].set_xticks(x)
        axes[idx].set_xticklabels(prime_labels)
        axes[idx].set_ylabel('Probability')
        axes[idx].set_title(f'{name}\n(losses: {losses.min():.2f}–{losses.max():.2f})')
        axes[idx].legend(fontsize=7)

    plt.suptitle('Gibbs Posterior on Prime Spectrum: Countermodel Learning', fontsize=14)
    plt.tight_layout()
    plt.savefig('Bridges/demos/prime_spectral.png', dpi=150, bbox_inches='tight')
    plt.close()
    print(f"  Generated prime_spectral.png")
    print(f"  False conjecture: Gibbs concentrates on low-loss primes (countermodels)")
    print(f"  Strong theorem: all primes have high loss (no countermodel)")
    print()

# ============================================================
# Main
# ============================================================

if __name__ == '__main__':
    print()
    print("PAC-Bayesian Prime-Spectral Generalization")
    print("Numerical Demonstrations of Formally Verified Theorems")
    print("=" * 60)
    print()

    demo_kl_properties()
    demo_donsker_varadhan()
    demo_gibbs_optimality()
    demo_pac_bayes_bound()
    demo_prime_spectral()

    print("=" * 60)
    print("All demonstrations complete.")
    print("Generated plots in Bridges/demos/")
    print()
    print("Summary of verified theorems demonstrated:")
    print("  1. klDiv_nonneg: KL(Q||P) ≥ 0 for all probability distributions")
    print("  2. log_sum_exp_dual: ∑Q·f ≤ KL(Q||P) + log(∑P·exp(f))")
    print("  3. gibbsMeasure_isProb: Gibbs posterior is valid distribution")
    print("  4. gibbs_minimizes_free_energy: Gibbs minimizes <E> + (1/β)·KL")
    print("  5. pac_bayes_prime_spectral_bound_of_mgf: PAC-Bayes bound")
    print("  6. prime_spectral_gibbs_variational_principle: Full variational principle")
