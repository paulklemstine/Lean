#!/usr/bin/env python3
"""
PAC-Bayes Generalization Bounds: Interactive Demonstrations

Demonstrates the key theorems formalized in the Lean 4 library:
1. McAllester and Catoni PAC-Bayes bounds
2. Gaussian KL divergence formulas
3. Asymptotic rate scaling (d/n)
4. Bound comparison and optimization
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from typing import Tuple

# ═══════════════════════════════════════════════════════════════
# Core PAC-Bayes Functions (matching Lean definitions)
# ═══════════════════════════════════════════════════════════════

def gaussian_shift_kl(w: np.ndarray, sigma: float) -> float:
    """KL(N(w, σ²I) ‖ N(0, σ²I)) = ‖w‖²/(2σ²)"""
    return np.sum(w**2) / (2 * sigma**2)

def gaussian_shift_kl_full(w: np.ndarray, sigma: float, tau: float) -> float:
    """KL(N(w, σ²I) ‖ N(0, τ²I))"""
    d = len(w)
    ratio = sigma**2 / tau**2
    return d/2 * (ratio - 1 - np.log(ratio)) + np.sum(w**2) / (2 * tau**2)

def mcallester_bound(emp_risk: float, kl: float, n: int, delta: float) -> float:
    """McAllester PAC-Bayes bound"""
    complexity = (kl + np.log(2 * np.sqrt(n) / delta)) / (2 * n)
    return emp_risk + np.sqrt(max(0, complexity))

def catoni_bound(emp_risk: float, kl: float, n: int, delta: float, lam: float) -> float:
    """Catoni PAC-Bayes bound"""
    denom = 1 - np.exp(-lam)
    exponent = -lam * emp_risk - (kl + np.log(1/delta)) / n
    return (1/denom) * (1 - np.exp(exponent))

def kl_bernoulli(p: float, q: float) -> float:
    """KL(Ber(p) ‖ Ber(q))"""
    if p <= 0:
        return -np.log(1 - q)
    if p >= 1:
        return -np.log(q)
    return p * np.log(p/q) + (1-p) * np.log((1-p)/(1-q))

# ═══════════════════════════════════════════════════════════════
# Demo 1: McAllester vs Catoni Bound Comparison
# ═══════════════════════════════════════════════════════════════

def demo_bound_comparison():
    """Compare McAllester and Catoni bounds across empirical risk values"""
    print("=" * 60)
    print("Demo 1: McAllester vs Catoni Bound Comparison")
    print("=" * 60)

    n = 1000
    delta = 0.05
    kl = 10.0
    emp_risks = np.linspace(0.01, 0.5, 100)

    mc_bounds = [mcallester_bound(r, kl, n, delta) for r in emp_risks]

    # Find optimal lambda for each emp_risk
    best_catoni = []
    for r in emp_risks:
        lambdas = np.linspace(0.1, 20, 200)
        bounds = [catoni_bound(r, kl, n, delta, l) for l in lambdas]
        best_catoni.append(min(bounds))

    fig, ax = plt.subplots(1, 1, figsize=(10, 6))
    ax.plot(emp_risks, mc_bounds, 'b-', linewidth=2, label='McAllester')
    ax.plot(emp_risks, best_catoni, 'r--', linewidth=2, label='Catoni (optimal λ)')
    ax.plot(emp_risks, emp_risks, 'k:', linewidth=1, label='Empirical risk')
    ax.set_xlabel('Empirical Risk', fontsize=14)
    ax.set_ylabel('Bound on True Risk', fontsize=14)
    ax.set_title(f'PAC-Bayes Bounds (n={n}, KL={kl}, δ={delta})', fontsize=16)
    ax.legend(fontsize=12)
    ax.grid(True, alpha=0.3)
    ax.set_xlim(0, 0.5)
    ax.set_ylim(0, 1.0)
    plt.tight_layout()
    plt.savefig('bound_comparison.png', dpi=150)
    plt.close()
    print("Saved: bound_comparison.png")

    # Print some values
    for r in [0.05, 0.1, 0.2]:
        mc = mcallester_bound(r, kl, n, delta)
        lambdas = np.linspace(0.1, 20, 200)
        cat = min([catoni_bound(r, kl, n, delta, l) for l in lambdas])
        print(f"  Emp risk = {r:.2f}: McAllester = {mc:.4f}, Catoni = {cat:.4f}, improvement = {(mc-cat)/mc*100:.1f}%")

# ═══════════════════════════════════════════════════════════════
# Demo 2: Gaussian KL Divergence Visualization
# ═══════════════════════════════════════════════════════════════

def demo_gaussian_kl():
    """Visualize Gaussian KL as function of norm and variance"""
    print("\n" + "=" * 60)
    print("Demo 2: Gaussian KL Divergence")
    print("=" * 60)

    # KL vs norm for different sigma
    norms = np.linspace(0, 10, 100)
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    for sigma in [0.5, 1.0, 2.0, 5.0]:
        kls = norms**2 / (2 * sigma**2)
        ax1.plot(norms, kls, linewidth=2, label=f'σ = {sigma}')

    ax1.set_xlabel('‖w‖', fontsize=14)
    ax1.set_ylabel('KL(N(w,σ²I) ‖ N(0,σ²I))', fontsize=14)
    ax1.set_title('Equal-Variance KL', fontsize=16)
    ax1.legend(fontsize=12)
    ax1.grid(True, alpha=0.3)

    # Full KL vs sigma for different tau
    sigmas = np.linspace(0.1, 5, 100)
    d = 10
    w = np.ones(d)

    for tau in [0.5, 1.0, 2.0]:
        kls_full = [gaussian_shift_kl_full(w, s, tau) for s in sigmas]
        ax2.plot(sigmas, kls_full, linewidth=2, label=f'τ = {tau}')

    ax2.set_xlabel('σ (posterior std)', fontsize=14)
    ax2.set_ylabel('KL(N(w,σ²I) ‖ N(0,τ²I))', fontsize=14)
    ax2.set_title(f'Full KL (d={d}, ‖w‖={np.linalg.norm(w):.1f})', fontsize=16)
    ax2.legend(fontsize=12)
    ax2.grid(True, alpha=0.3)
    ax2.set_ylim(0, 50)

    plt.tight_layout()
    plt.savefig('gaussian_kl.png', dpi=150)
    plt.close()
    print("Saved: gaussian_kl.png")

# ═══════════════════════════════════════════════════════════════
# Demo 3: Asymptotic Rate d/n
# ═══════════════════════════════════════════════════════════════

def demo_asymptotic_rate():
    """Demonstrate O(d/n) complexity scaling"""
    print("\n" + "=" * 60)
    print("Demo 3: Asymptotic Rate Scaling")
    print("=" * 60)

    ns = np.arange(10, 5000, 10)
    tau = 1.0
    w_norm_sq = 5.0

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    # Complexity vs n for different d
    for d in [5, 10, 50, 100]:
        w = np.sqrt(w_norm_sq / d) * np.ones(d)
        complexities = []
        for n in ns:
            sigma = 1.0 / np.sqrt(n)
            kl = gaussian_shift_kl_full(w, sigma, tau)
            complexities.append(kl / n)
        ax1.plot(ns, complexities, linewidth=2, label=f'd = {d}')

    ax1.set_xlabel('Sample size n', fontsize=14)
    ax1.set_ylabel('KL/n', fontsize=14)
    ax1.set_title('Complexity Term vs Sample Size', fontsize=16)
    ax1.legend(fontsize=12)
    ax1.grid(True, alpha=0.3)
    ax1.set_yscale('log')

    # Verify d/n scaling
    ds = np.arange(1, 201)
    n_fixed = 1000

    for w_norm in [1.0, 5.0, 10.0]:
        ratios = []
        for d in ds:
            w = np.sqrt(w_norm / d) * np.ones(d)
            sigma = 1.0 / np.sqrt(n_fixed)
            kl = gaussian_shift_kl_full(w, sigma, tau)
            ratios.append(kl / n_fixed)
        ax2.plot(ds, ratios, linewidth=2, label=f'‖w‖² = {w_norm}')

    # Reference line
    ax2.plot(ds, 0.01 * ds / n_fixed, 'k--', alpha=0.5, label='O(d/n) reference')

    ax2.set_xlabel('Dimension d', fontsize=14)
    ax2.set_ylabel('KL/n', fontsize=14)
    ax2.set_title(f'Complexity vs Dimension (n={n_fixed})', fontsize=16)
    ax2.legend(fontsize=12)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('asymptotic_rate.png', dpi=150)
    plt.close()
    print("Saved: asymptotic_rate.png")

    # Numerical verification of rate
    d, n = 50, 10000
    w = np.ones(d) * 0.3
    sigma = 1.0 / np.sqrt(n)
    kl = gaussian_shift_kl_full(w, sigma, tau)
    print(f"  d={d}, n={n}: KL/n = {kl/n:.6f}, d/n = {d/n:.6f}, ratio = {kl/n/(d/n):.4f}")

# ═══════════════════════════════════════════════════════════════
# Demo 4: Neural Network Generalization Certificate
# ═══════════════════════════════════════════════════════════════

def demo_neural_certification():
    """Compute a PAC-Bayes generalization certificate for a simple network"""
    print("\n" + "=" * 60)
    print("Demo 4: Neural Network Generalization Certificate")
    print("=" * 60)

    # Simulated network parameters
    d = 1000  # number of parameters
    n = 10000  # training samples
    delta = 0.05
    emp_risk = 0.02  # 2% training error

    print(f"\n  Network: d={d} parameters, n={n} samples")
    print(f"  Training error: {emp_risk*100:.1f}%")
    print(f"  Confidence: 1-δ = {1-delta:.2f}")

    results = []
    sigmas = [0.01, 0.05, 0.1, 0.5, 1.0, 2.0]

    for sigma in sigmas:
        w = np.random.randn(d) * 0.1  # small random weights
        kl = gaussian_shift_kl(w, sigma)
        mc = mcallester_bound(emp_risk, kl, n, delta)

        # Optimal Catoni
        lambdas = np.linspace(0.1, 50, 500)
        cat = min([catoni_bound(emp_risk, kl, n, delta, l) for l in lambdas])

        results.append((sigma, kl, mc, cat))
        print(f"  σ={sigma:.2f}: KL={kl:.1f}, McAllester={mc:.4f}, Catoni={cat:.4f}")

    # Find best sigma
    best_mc = min(results, key=lambda x: x[2])
    best_cat = min(results, key=lambda x: x[3])
    print(f"\n  Best McAllester: σ={best_mc[0]:.2f}, bound={best_mc[2]:.4f}")
    print(f"  Best Catoni:     σ={best_cat[0]:.2f}, bound={best_cat[3]:.4f}")

# ═══════════════════════════════════════════════════════════════
# Demo 5: Hoeffding's Lemma Visualization
# ═══════════════════════════════════════════════════════════════

def demo_hoeffding():
    """Visualize Hoeffding's lemma"""
    print("\n" + "=" * 60)
    print("Demo 5: Hoeffding's Lemma Verification")
    print("=" * 60)

    ts = np.linspace(-5, 5, 200)
    mu_values = [0.1, 0.3, 0.5, 0.7, 0.9]

    fig, ax = plt.subplots(figsize=(10, 6))

    # Plot exp(t²/8) bound
    ax.plot(ts, np.exp(ts**2 / 8), 'k-', linewidth=3, label='exp(t²/8) bound')

    for mu in mu_values:
        # Exact MGF for Bernoulli(mu)
        mgf = (1-mu) * np.exp(-ts*mu) + mu * np.exp(ts*(1-mu))
        ax.plot(ts, mgf, '--', linewidth=1.5, label=f'Ber(μ={mu})')

    ax.set_xlabel('t', fontsize=14)
    ax.set_ylabel('E[exp(t(X-μ))]', fontsize=14)
    ax.set_title("Hoeffding's Lemma: MGF Bound for Bounded RVs", fontsize=16)
    ax.legend(fontsize=11, loc='upper center')
    ax.grid(True, alpha=0.3)
    ax.set_ylim(0, 30)
    plt.tight_layout()
    plt.savefig('hoeffding_lemma.png', dpi=150)
    plt.close()
    print("Saved: hoeffding_lemma.png")

# ═══════════════════════════════════════════════════════════════

if __name__ == '__main__':
    print("PAC-Bayes Generalization Bounds: Demonstrations")
    print("Corresponding to formally verified theorems in Lean 4")
    print()

    demo_bound_comparison()
    demo_gaussian_kl()
    demo_asymptotic_rate()
    demo_neural_certification()
    demo_hoeffding()

    print("\n" + "=" * 60)
    print("All demos complete. Generated figures:")
    print("  - bound_comparison.png")
    print("  - gaussian_kl.png")
    print("  - asymptotic_rate.png")
    print("  - hoeffding_lemma.png")
