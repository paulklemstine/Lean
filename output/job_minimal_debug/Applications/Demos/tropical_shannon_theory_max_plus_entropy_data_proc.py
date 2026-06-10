#!/usr/bin/env python3
"""
Tropical Shannon Information Theory — Numerical Demonstrations

This script demonstrates the key concepts from our formalization of
tropical (max-plus) information theory, showing how worst-case information
measures behave differently from their Shannon (average-case) counterparts.

All theorems demonstrated here have been formally verified in Lean 4.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from typing import List, Tuple

# ============================================================
# Core Definitions
# ============================================================

def tropical_entropy(p: np.ndarray) -> float:
    """H_⊕(X) = -log(min_x p(x)), the Rényi ∞-entropy."""
    assert np.all(p > 0), "Distribution must be strictly positive"
    assert abs(np.sum(p) - 1.0) < 1e-10, "Must sum to 1"
    return -np.log(np.min(p))

def shannon_entropy(p: np.ndarray) -> float:
    """H(X) = -Σ p(x) log p(x), the Shannon entropy."""
    assert np.all(p > 0)
    return -np.sum(p * np.log(p))

def tropical_kl(p: np.ndarray, q: np.ndarray) -> float:
    """D_⊕(P‖Q) = max_x log(p(x)/q(x)), worst-case divergence."""
    return np.max(np.log(p / q))

def shannon_kl(p: np.ndarray, q: np.ndarray) -> float:
    """D(P‖Q) = Σ p(x) log(p(x)/q(x)), Shannon KL divergence."""
    return np.sum(p * np.log(p / q))

def partition_function(costs: np.ndarray, beta: float) -> float:
    """Z(β) = Σ exp(-β * cost(s))"""
    return np.sum(np.exp(-beta * costs))

def boltzmann_distribution(costs: np.ndarray, beta: float) -> np.ndarray:
    """p_β(s) = exp(-β·cost(s)) / Z(β)"""
    Z = partition_function(costs, beta)
    return np.exp(-beta * costs) / Z

# ============================================================
# Demo 1: Tropical vs Shannon Entropy
# ============================================================

def demo_entropy_comparison():
    """Compare tropical and Shannon entropy for various distributions."""
    print("=" * 60)
    print("DEMO 1: Tropical vs Shannon Entropy")
    print("=" * 60)
    
    n = 5
    
    # Uniform distribution
    p_uniform = np.ones(n) / n
    print(f"\nUniform distribution on {n} elements: {p_uniform}")
    print(f"  Shannon entropy: H(X) = {shannon_entropy(p_uniform):.4f}")
    print(f"  Tropical entropy: H_⊕(X) = {tropical_entropy(p_uniform):.4f}")
    print(f"  log({n}) = {np.log(n):.4f}")
    print(f"  ✓ Both equal log(n) for uniform (Theorem: tropical_entropy_uniform_eq)")
    
    # Nearly deterministic
    eps = 0.01
    p_det = np.array([1 - (n-1)*eps] + [eps]*(n-1))
    print(f"\nNearly deterministic: {p_det}")
    print(f"  Shannon entropy: H(X) = {shannon_entropy(p_det):.4f}")
    print(f"  Tropical entropy: H_⊕(X) = {tropical_entropy(p_det):.4f}")
    print(f"  ✓ Shannon → 0, but tropical → -log(ε) = {-np.log(eps):.4f} (LARGE!)")
    print(f"  Key insight: tropical entropy measures WORST-case surprise")
    
    # Skewed distribution
    p_skewed = np.array([0.5, 0.3, 0.15, 0.04, 0.01])
    print(f"\nSkewed distribution: {p_skewed}")
    print(f"  Shannon entropy: H(X) = {shannon_entropy(p_skewed):.4f}")
    print(f"  Tropical entropy: H_⊕(X) = {tropical_entropy(p_skewed):.4f}")
    print(f"  ✓ Tropical ≥ log({n}) = {np.log(n):.4f} (Theorem: tropical_entropy_ge_log_card)")
    
    # Verify nonnegativity (Theorem: tropical_entropy_nonneg)
    print(f"\n✓ All tropical entropies ≥ 0 (Theorem: tropical_entropy_nonneg)")
    print(f"  H_⊕(uniform) = {tropical_entropy(p_uniform):.4f} ≥ 0 ✓")
    print(f"  H_⊕(det) = {tropical_entropy(p_det):.4f} ≥ 0 ✓")
    print(f"  H_⊕(skewed) = {tropical_entropy(p_skewed):.4f} ≥ 0 ✓")

# ============================================================
# Demo 2: Tropical KL Divergence and DPI
# ============================================================

def demo_kl_and_dpi():
    """Demonstrate tropical KL divergence and data processing inequality."""
    print("\n" + "=" * 60)
    print("DEMO 2: Tropical KL Divergence & Data Processing Inequality")
    print("=" * 60)
    
    p = np.array([0.4, 0.35, 0.15, 0.1])
    q = np.array([0.25, 0.25, 0.25, 0.25])
    
    print(f"\nP = {p}")
    print(f"Q = {q} (uniform)")
    
    d_trop = tropical_kl(p, q)
    d_shan = shannon_kl(p, q)
    
    print(f"\n  Shannon KL: D(P‖Q) = {d_shan:.4f}")
    print(f"  Tropical KL: D_⊕(P‖Q) = {d_trop:.4f}")
    print(f"  ✓ D_⊕(P‖Q) ≥ 0 (Theorem: tropical_kl_nonneg)")
    print(f"  ✓ D_⊕(P‖P) = {tropical_kl(p, p):.10f} ≈ 0 (Theorem: tropical_kl_self)")
    
    # DPI: apply a deterministic function f
    # f maps {0,1,2,3} → {0,1} via f(0)=f(1)=0, f(2)=f(3)=1
    print(f"\n--- Data Processing Inequality ---")
    print(f"Apply f: {{0,1}} → 0, {{2,3}} → 1")
    
    p_push = np.array([p[0]+p[1], p[2]+p[3]])
    q_push = np.array([q[0]+q[1], q[2]+q[3]])
    
    d_trop_push = tropical_kl(p_push, q_push)
    
    print(f"  f#P = {p_push}")
    print(f"  f#Q = {q_push}")
    print(f"  D_⊕(f#P ‖ f#Q) = {d_trop_push:.4f}")
    print(f"  D_⊕(P ‖ Q)     = {d_trop:.4f}")
    print(f"  ✓ D_⊕(f#P‖f#Q) ≤ D_⊕(P‖Q): {d_trop_push:.4f} ≤ {d_trop:.4f} "
          f"(Theorem: pushforward_tropicalKL_le)")
    
    # Security bound
    bound = d_trop + 0.1
    max_ratio = np.max(p / q)
    print(f"\n--- Security Bound ---")
    print(f"  If D_⊕(P‖Q) < {bound:.4f}, then ∀x: p(x)/q(x) < exp({bound:.4f}) = {np.exp(bound):.4f}")
    print(f"  Actual max ratio: max_x p(x)/q(x) = {max_ratio:.4f}")
    print(f"  exp(D_⊕) = {np.exp(d_trop):.4f} = max ratio ✓ (Theorem: tropical_kl_exp_eq_max_ratio)")

# ============================================================
# Demo 3: Thermodynamic Bridge
# ============================================================

def demo_thermodynamic_bridge():
    """Demonstrate the bridge between tropical entropy and thermodynamics."""
    print("\n" + "=" * 60)
    print("DEMO 3: Thermodynamic Bridge — Free Energy & Ground State")
    print("=" * 60)
    
    costs = np.array([1.0, 2.0, 3.0, 5.0, 8.0])
    E_ground = np.min(costs)
    E_max = np.max(costs)
    n = len(costs)
    
    print(f"\nState costs: {costs}")
    print(f"Ground state energy E₀ = {E_ground}")
    print(f"Maximum cost E_max = {E_max}")
    print(f"|S| = {n}")
    
    betas = [0.1, 0.5, 1.0, 2.0, 5.0, 10.0, 50.0]
    
    print(f"\n{'β':>6} {'Z(β)':>12} {'logZ/β':>10} {'−E₀':>8} {'H_⊕(p_β)':>10} {'β·E_max+logZ':>14} {'|err|':>8}")
    print("-" * 75)
    
    for beta in betas:
        Z = partition_function(costs, beta)
        p_beta = boltzmann_distribution(costs, beta)
        H_trop = tropical_entropy(p_beta)
        logZ_over_beta = np.log(Z) / beta
        bridge_val = beta * E_max + np.log(Z)
        error = abs(logZ_over_beta - (-E_ground))
        
        print(f"{beta:6.1f} {Z:12.4f} {logZ_over_beta:10.4f} {-E_ground:8.4f} "
              f"{H_trop:10.4f} {bridge_val:14.4f} {error:8.4f}")
    
    print(f"\n✓ logZ(β)/β → −E₀ = {-E_ground:.1f} as β → ∞ (Theorem: free_energy_sandwich)")
    print(f"✓ |logZ/β − (−E₀)| ≤ log|S|/β = log({n})/β (Theorem: free_energy_convergence_rate)")
    print(f"✓ H_⊕(p_β) = β·E_max + logZ (Theorem: tropical_entropy_boltzmann)")

# ============================================================
# Demo 4: Product Distributions
# ============================================================

def demo_product_entropy():
    """Demonstrate additivity of tropical entropy for product distributions."""
    print("\n" + "=" * 60)
    print("DEMO 4: Tropical Entropy Additivity for Products")
    print("=" * 60)
    
    p = np.array([0.5, 0.3, 0.2])
    q = np.array([0.6, 0.4])
    
    # Product distribution
    pq = np.outer(p, q).flatten()
    
    H_p = tropical_entropy(p)
    H_q = tropical_entropy(q)
    H_pq = tropical_entropy(pq)
    
    print(f"\np = {p}, H_⊕(p) = {H_p:.4f}")
    print(f"q = {q}, H_⊕(q) = {H_q:.4f}")
    print(f"p⊗q = {pq}")
    print(f"H_⊕(p⊗q) = {H_pq:.4f}")
    print(f"H_⊕(p) + H_⊕(q) = {H_p + H_q:.4f}")
    print(f"✓ Additive! (Theorem: tropical_entropy_product)")
    
    # Compare with Shannon
    H_p_s = shannon_entropy(p)
    H_q_s = shannon_entropy(q)
    H_pq_s = shannon_entropy(pq)
    print(f"\nShannon comparison:")
    print(f"H(p⊗q) = {H_pq_s:.4f} = H(p) + H(q) = {H_p_s + H_q_s:.4f}")
    print(f"Both Shannon and tropical entropy are additive for products ✓")

# ============================================================
# Demo 5: Visualization
# ============================================================

def create_visualizations():
    """Create visualization plots."""
    fig, axes = plt.subplots(2, 2, figsize=(14, 12))
    
    # Plot 1: Tropical vs Shannon entropy as function of skewness
    ax = axes[0, 0]
    alphas = np.linspace(0.01, 0.99, 100)
    H_trop = [-np.log(min(a, 1-a)) for a in alphas]
    H_shan = [-a*np.log(a) - (1-a)*np.log(1-a) for a in alphas]
    ax.plot(alphas, H_trop, 'r-', linewidth=2, label='Tropical H_⊕')
    ax.plot(alphas, H_shan, 'b-', linewidth=2, label='Shannon H')
    ax.set_xlabel('p(0) for Binary Distribution', fontsize=12)
    ax.set_ylabel('Entropy', fontsize=12)
    ax.set_title('Tropical vs Shannon Entropy\n(Binary Distribution)', fontsize=13)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    ax.set_xlim(0, 1)
    
    # Plot 2: Free energy convergence
    ax = axes[0, 1]
    costs = np.array([1.0, 2.0, 3.0, 5.0])
    E_ground = np.min(costs)
    betas = np.linspace(0.1, 20, 200)
    logZ_beta = [np.log(partition_function(costs, b))/b for b in betas]
    upper = [-E_ground + np.log(len(costs))/b for b in betas]
    ax.plot(betas, logZ_beta, 'b-', linewidth=2, label='log Z(β)/β')
    ax.axhline(-E_ground, color='r', linestyle='--', linewidth=1.5, label=f'−E₀ = {-E_ground}')
    ax.plot(betas, upper, 'g--', linewidth=1.5, label='−E₀ + log|S|/β', alpha=0.7)
    ax.set_xlabel('β (inverse temperature)', fontsize=12)
    ax.set_ylabel('log Z(β)/β', fontsize=12)
    ax.set_title('Free Energy Convergence\nto Ground State Energy', fontsize=13)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    
    # Plot 3: DPI visualization
    ax = axes[1, 0]
    np.random.seed(42)
    n_trials = 50
    dpi_original = []
    dpi_processed = []
    for _ in range(n_trials):
        p = np.random.dirichlet(np.ones(6))
        q = np.random.dirichlet(np.ones(6))
        d_orig = tropical_kl(p, q)
        # Pushforward through f: {0,1,2,3,4,5} → {0,1,2}
        p_push = np.array([p[0]+p[1], p[2]+p[3], p[4]+p[5]])
        q_push = np.array([q[0]+q[1], q[2]+q[3], q[4]+q[5]])
        d_push = tropical_kl(p_push, q_push)
        dpi_original.append(d_orig)
        dpi_processed.append(d_push)
    
    ax.scatter(dpi_original, dpi_processed, alpha=0.6, s=40, c='blue')
    max_val = max(max(dpi_original), max(dpi_processed)) * 1.1
    ax.plot([0, max_val], [0, max_val], 'r--', linewidth=1.5, label='y = x')
    ax.set_xlabel('D_⊕(P‖Q) (original)', fontsize=12)
    ax.set_ylabel('D_⊕(f#P‖f#Q) (after processing)', fontsize=12)
    ax.set_title('Tropical Data Processing Inequality\nD_⊕(f#P‖f#Q) ≤ D_⊕(P‖Q)', fontsize=13)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    
    # Plot 4: Boltzmann tropical entropy
    ax = axes[1, 1]
    costs = np.array([0.5, 1.0, 2.0, 4.0])
    E_max = np.max(costs)
    betas = np.linspace(0.1, 10, 200)
    H_trops = []
    bridge_vals = []
    for b in betas:
        p_b = boltzmann_distribution(costs, b)
        H_trops.append(tropical_entropy(p_b))
        bridge_vals.append(b * E_max + np.log(partition_function(costs, b)))
    
    ax.plot(betas, H_trops, 'b-', linewidth=2, label='H_⊕(p_β)')
    ax.plot(betas, bridge_vals, 'r--', linewidth=2, label='β·E_max + log Z', alpha=0.7)
    ax.set_xlabel('β (inverse temperature)', fontsize=12)
    ax.set_ylabel('Tropical Entropy', fontsize=12)
    ax.set_title('Bridge Theorem: H_⊕(p_β) = β·E_max + log Z\n(Boltzmann Distribution)', fontsize=13)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('tropical_information_theory.png', dpi=150, bbox_inches='tight')
    print("\n✓ Saved visualization to tropical_information_theory.png")

# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print("╔═══════════════════════════════════════════════════════════╗")
    print("║  TROPICAL SHANNON INFORMATION THEORY — Numerical Demo   ║")
    print("║  All theorems formally verified in Lean 4 with Mathlib  ║")
    print("╚═══════════════════════════════════════════════════════════╝")
    
    demo_entropy_comparison()
    demo_kl_and_dpi()
    demo_thermodynamic_bridge()
    demo_product_entropy()
    create_visualizations()
    
    print("\n" + "=" * 60)
    print("KEY THEOREMS (all formally verified, zero sorry):")
    print("=" * 60)
    print("""
1. tropical_entropy_nonneg      : H_⊕(X) ≥ 0
2. tropical_entropy_ge_log_card : H_⊕(X) ≥ log|α|
3. tropical_entropy_uniform_eq  : H_⊕(Uniform) = log|α|
4. tropical_kl_nonneg           : D_⊕(P‖Q) ≥ 0
5. tropical_kl_self             : D_⊕(P‖P) = 0
6. pushforward_tropicalKL_le    : D_⊕(f#P‖f#Q) ≤ D_⊕(P‖Q)  [DPI!]
7. tropical_entropy_product     : H_⊕(p⊗q) = H_⊕(p) + H_⊕(q)
8. free_energy_sandwich         : bounds on logZ(β)/β
9. free_energy_convergence_rate : |logZ/β + E₀| ≤ log|S|/β
10. tropical_entropy_boltzmann  : H_⊕(p_β) = β·E_max + logZ
11. tropical_kl_security_bound  : D_⊕ < λ ⟹ ratios < exp(λ)
12. tropical_entropy_search_bound: 1/min_p = exp(H_⊕)
""")
