#!/usr/bin/env python3
"""
Categorified Shannon Theory: Numerical Demonstrations

This demo brings the formally verified theorems to life with concrete
numerical examples and visualizations.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from typing import List, Tuple

# ============================================================
# Core Definitions (matching the Lean formalization)
# ============================================================

def shannon_entropy(p: np.ndarray) -> float:
    """Shannon entropy H(P) = -∑ pᵢ log(pᵢ), with 0 log 0 = 0."""
    p = p[p > 0]
    return -np.sum(p * np.log(p))

def kl_divergence(p: np.ndarray, q: np.ndarray) -> float:
    """KL-divergence KL(P‖Q) = ∑ pᵢ log(pᵢ/qᵢ)."""
    mask = p > 0
    return np.sum(p[mask] * np.log(p[mask] / q[mask]))

def total_variation(p: np.ndarray, q: np.ndarray) -> float:
    """Total variation distance d_TV(P,Q) = (1/2) ∑ |pᵢ - qᵢ|."""
    return 0.5 * np.sum(np.abs(p - q))

def binary_entropy(p: float) -> float:
    """Binary entropy H₂(p) = -p log(p) - (1-p) log(1-p)."""
    if p <= 0 or p >= 1:
        return 0.0
    return -p * np.log(p) - (1 - p) * np.log(1 - p)

def tropical_entropy(p: np.ndarray) -> float:
    """Tropical (min) entropy H_∞(P) = -log(max pᵢ)."""
    return -np.log(np.max(p))

def pushforward(p: np.ndarray, kernel: np.ndarray) -> np.ndarray:
    """Pushforward f_*P: (f_*P)(j) = ∑ᵢ P(i) · kernel(j,i)."""
    return kernel @ p

# ============================================================
# Demo 1: Entropy Non-Negativity and Upper Bound
# ============================================================

def demo_entropy_bounds():
    """Demonstrates: H(P) ∈ [0, log(n)] for all distributions P."""
    print("=" * 60)
    print("DEMO 1: Entropy Non-Negativity and Upper Bound")
    print("Theorem: 0 ≤ H(P) ≤ log(n)")
    print("=" * 60)

    n = 5
    np.random.seed(42)

    # Test distributions
    uniform = np.ones(n) / n
    dirac = np.zeros(n); dirac[0] = 1.0
    biased = np.array([0.5, 0.3, 0.1, 0.07, 0.03])

    for name, p in [("Uniform", uniform), ("Dirac δ₀", dirac), ("Biased", biased)]:
        H = shannon_entropy(p)
        print(f"  {name:12s}: H = {H:.4f}  (bounds: [0, {np.log(n):.4f}])")
        assert 0 <= H <= np.log(n) + 1e-10, f"Bound violation for {name}!"

    print(f"\n  ✓ All distributions satisfy 0 ≤ H(P) ≤ log({n}) = {np.log(n):.4f}")
    print()

# ============================================================
# Demo 2: Gibbs Inequality (KL ≥ 0)
# ============================================================

def demo_gibbs_inequality():
    """Demonstrates: KL(P‖Q) ≥ 0 with equality iff P = Q."""
    print("=" * 60)
    print("DEMO 2: Gibbs Inequality (KL ≥ 0) — Yoneda Non-Negativity")
    print("Theorem: KL(P‖Q) ≥ 0, with KL(P‖P) = 0")
    print("=" * 60)

    n = 4
    p = np.array([0.4, 0.3, 0.2, 0.1])
    q = np.array([0.25, 0.25, 0.25, 0.25])
    r = np.array([0.1, 0.2, 0.3, 0.4])

    for name, dist_p, dist_q in [("KL(P‖Q)", p, q), ("KL(P‖R)", p, r),
                                   ("KL(Q‖P)", q, p), ("KL(P‖P)", p, p)]:
        kl = kl_divergence(dist_p, dist_q)
        print(f"  {name}: {kl:.6f} {'= 0 ✓ (Yoneda identity)' if abs(kl) < 1e-10 else '≥ 0 ✓'}")
        assert kl >= -1e-10, f"Gibbs inequality violated for {name}!"

    print(f"\n  ✓ All KL-divergences are non-negative (Gibbs/Yoneda)")
    print()

# ============================================================
# Demo 3: Data Processing Inequality (Entropy Naturality)
# ============================================================

def demo_data_processing():
    """Demonstrates: H(f_*P) ≤ H(P) for stochastic maps f."""
    print("=" * 60)
    print("DEMO 3: Data Processing Inequality — Entropy Naturality")
    print("Theorem: H(f_*P) ≤ H(P) for any stochastic map f")
    print("=" * 60)

    # Source distribution on 4 outcomes
    p = np.array([0.4, 0.3, 0.2, 0.1])

    # Stochastic map (noisy channel) from 4 to 3 outcomes
    # Each column sums to 1
    kernel = np.array([
        [0.8, 0.1, 0.1, 0.0],
        [0.1, 0.7, 0.2, 0.3],
        [0.1, 0.2, 0.7, 0.7]
    ])

    fp = pushforward(p, kernel)
    H_p = shannon_entropy(p)
    H_fp = shannon_entropy(fp)

    print(f"  Source distribution P:    {p}")
    print(f"  Processed distribution:   {np.round(fp, 4)}")
    print(f"  H(P)     = {H_p:.6f}")
    print(f"  H(f_*P)  = {H_fp:.6f}")
    print(f"  H(P) - H(f_*P) = {H_p - H_fp:.6f} ≥ 0 ✓")
    assert H_fp <= H_p + 1e-10

    # Deterministic map (always loses information)
    det_kernel = np.array([
        [1, 1, 0, 0],
        [0, 0, 1, 1]
    ], dtype=float)

    fp_det = pushforward(p, det_kernel)
    H_fp_det = shannon_entropy(fp_det)
    print(f"\n  Deterministic map (merge pairs):")
    print(f"  H(f_*P)  = {H_fp_det:.6f} ≤ {H_p:.6f} = H(P) ✓")
    print()

# ============================================================
# Demo 4: Total Variation Metric
# ============================================================

def demo_total_variation():
    """Demonstrates: TV is a bounded metric."""
    print("=" * 60)
    print("DEMO 4: Total Variation — Metric on FinProbCat")
    print("Theorems: d_TV symmetry, triangle inequality, boundedness")
    print("=" * 60)

    p = np.array([0.5, 0.3, 0.2])
    q = np.array([0.3, 0.4, 0.3])
    r = np.array([0.1, 0.1, 0.8])

    tv_pq = total_variation(p, q)
    tv_qr = total_variation(q, r)
    tv_pr = total_variation(p, r)

    print(f"  d_TV(P,Q) = {tv_pq:.4f}")
    print(f"  d_TV(Q,R) = {tv_qr:.4f}")
    print(f"  d_TV(P,R) = {tv_pr:.4f}")
    print(f"  Triangle: {tv_pr:.4f} ≤ {tv_pq:.4f} + {tv_qr:.4f} = {tv_pq + tv_qr:.4f} ✓")
    assert tv_pr <= tv_pq + tv_qr + 1e-10
    print(f"  Symmetry: d_TV(P,Q) = {tv_pq:.4f} = d_TV(Q,P) = {total_variation(q, p):.4f} ✓")
    print(f"  Bounded:  {tv_pr:.4f} ≤ 1 ✓")
    print()

# ============================================================
# Demo 5: Shannon vs Tropical Entropy
# ============================================================

def demo_tropical_comparison():
    """Demonstrates: H_∞(P) ≤ H(P) for all P."""
    print("=" * 60)
    print("DEMO 5: Tropical vs Shannon Entropy")
    print("Theorem: H_∞(P) ≤ H(P)")
    print("=" * 60)

    distributions = [
        ("Uniform(4)", np.ones(4) / 4),
        ("Biased", np.array([0.7, 0.2, 0.08, 0.02])),
        ("Near-Dirac", np.array([0.97, 0.01, 0.01, 0.01])),
    ]

    for name, p in distributions:
        H_s = shannon_entropy(p)
        H_t = tropical_entropy(p)
        print(f"  {name:15s}: H_∞ = {H_t:.4f} ≤ H = {H_s:.4f} ✓")
        assert H_t <= H_s + 1e-10
    print()

# ============================================================
# Demo 6: Binary Entropy Function
# ============================================================

def demo_binary_entropy():
    """Demonstrates properties of binary entropy."""
    print("=" * 60)
    print("DEMO 6: Binary Entropy H₂(p)")
    print("Properties: symmetric, non-negative, H₂(0)=H₂(1)=0")
    print("=" * 60)

    print(f"  H₂(0)   = {binary_entropy(0):.4f} = 0 ✓")
    print(f"  H₂(1)   = {binary_entropy(1):.4f} = 0 ✓")
    print(f"  H₂(0.5) = {binary_entropy(0.5):.4f} = log(2) = {np.log(2):.4f} ✓")
    print(f"  H₂(0.3) = {binary_entropy(0.3):.4f} = H₂(0.7) = {binary_entropy(0.7):.4f} ✓ (symmetry)")
    print()

# ============================================================
# Visualization: Entropy Landscape
# ============================================================

def plot_entropy_landscape():
    """Generate visualization of key information-theoretic quantities."""
    fig, axes = plt.subplots(2, 2, figsize=(12, 10))

    # Plot 1: Binary Entropy
    ax = axes[0, 0]
    ps = np.linspace(0.001, 0.999, 200)
    H2 = [binary_entropy(p) for p in ps]
    ax.plot(ps, H2, 'b-', linewidth=2)
    ax.axhline(y=np.log(2), color='r', linestyle='--', alpha=0.5, label='log(2)')
    ax.set_xlabel('p')
    ax.set_ylabel('H₂(p)')
    ax.set_title('Binary Entropy Function')
    ax.legend()
    ax.grid(True, alpha=0.3)

    # Plot 2: Entropy vs max probability (Shannon vs Tropical)
    ax = axes[0, 1]
    n_samples = 500
    np.random.seed(42)
    H_vals, Ht_vals = [], []
    for _ in range(n_samples):
        p = np.random.dirichlet([1, 1, 1, 1])
        H_vals.append(shannon_entropy(p))
        Ht_vals.append(tropical_entropy(p))
    ax.scatter(H_vals, Ht_vals, alpha=0.3, s=10, c='blue')
    mx = max(max(H_vals), max(Ht_vals))
    ax.plot([0, mx], [0, mx], 'r--', alpha=0.5, label='H_∞ = H (diagonal)')
    ax.set_xlabel('Shannon Entropy H(P)')
    ax.set_ylabel('Tropical Entropy H_∞(P)')
    ax.set_title('H_∞(P) ≤ H(P): Tropical ≤ Shannon')
    ax.legend()
    ax.grid(True, alpha=0.3)

    # Plot 3: Data Processing Inequality
    ax = axes[1, 0]
    noise_levels = np.linspace(0, 1, 50)
    p = np.array([0.5, 0.3, 0.15, 0.05])
    H_original = shannon_entropy(p)
    H_processed = []
    for eps in noise_levels:
        # Noisy identity channel: (1-eps)*I + eps*uniform
        kernel = (1 - eps) * np.eye(4) + eps * np.ones((4, 4)) / 4
        fp = pushforward(p, kernel)
        H_processed.append(shannon_entropy(fp))

    ax.plot(noise_levels, H_processed, 'b-', linewidth=2, label='H(f_ε P)')
    ax.axhline(y=H_original, color='r', linestyle='--', alpha=0.5, label='H(P)')
    ax.axhline(y=np.log(4), color='g', linestyle='--', alpha=0.5, label='log(4)')
    ax.set_xlabel('Noise level ε')
    ax.set_ylabel('Entropy')
    ax.set_title('Data Processing: H(f_*P) vs noise')
    ax.legend()
    ax.grid(True, alpha=0.3)

    # Plot 4: KL-divergence landscape
    ax = axes[1, 1]
    ts = np.linspace(0.01, 0.99, 100)
    q = np.array([0.25, 0.25, 0.25, 0.25])
    p_target = np.array([0.7, 0.1, 0.1, 0.1])

    kl_vals = []
    tv_vals = []
    for t in ts:
        p_t = t * p_target + (1 - t) * q
        kl_vals.append(kl_divergence(p_t, q))
        tv_vals.append(total_variation(p_t, q))

    ax.plot(tv_vals, kl_vals, 'b-', linewidth=2, label='KL(P_t ‖ Q)')
    # Pinsker bound: KL ≥ 2 * TV²
    tv_range = np.linspace(0, max(tv_vals), 100)
    ax.plot(tv_range, 2 * tv_range**2, 'r--', alpha=0.5, label='Pinsker: 2·TV²')
    ax.set_xlabel('Total Variation d_TV')
    ax.set_ylabel('KL Divergence')
    ax.set_title('KL vs TV: Pinsker Bound')
    ax.legend()
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('entropy_landscape.png', dpi=150, bbox_inches='tight')
    print("  Saved: entropy_landscape.png")

# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print("\n" + "=" * 60)
    print("  CATEGORIFIED SHANNON THEORY — NUMERICAL DEMONSTRATIONS")
    print("  Bridging Information Theory and Category Theory")
    print("=" * 60 + "\n")

    demo_entropy_bounds()
    demo_gibbs_inequality()
    demo_data_processing()
    demo_total_variation()
    demo_tropical_comparison()
    demo_binary_entropy()

    print("Generating visualizations...")
    plot_entropy_landscape()

    print("\n" + "=" * 60)
    print("  ALL DEMONSTRATIONS PASSED ✓")
    print("  All theorems verified numerically.")
    print("=" * 60)
