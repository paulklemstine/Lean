"""
CHEAT CODE #5: CONCENTRATION INEQUALITIES
===========================================
Demonstrates how random variables concentrate around their means.

Key insight: In high dimensions, randomness is surprisingly predictable.
The right inequality gives exponentially tight bounds.

Experiments:
1. Comparing Markov, Chebyshev, Hoeffding, and Chernoff bounds
2. High-dimensional concentration: random projections
3. Johnson-Lindenstrauss lemma: dimension reduction preserves distances
4. The blessing of dimensionality
"""

import numpy as np
from scipy import stats


def experiment_1_bound_comparison():
    """Compare different concentration inequalities."""
    print("=" * 60)
    print("EXPERIMENT 1: Tail Bound Comparison")
    print("=" * 60)
    
    np.random.seed(42)
    
    # Sum of n independent Bernoulli(0.5) random variables
    n = 100
    p = 0.5
    mu = n * p  # = 50
    N_samples = 1000000
    
    samples = np.sum(np.random.binomial(1, p, (N_samples, n)), axis=1)
    
    print(f"\nX = sum of {n} independent Bernoulli({p}) RVs")
    print(f"E[X] = {mu}, Var(X) = {n*p*(1-p)}")
    
    # Compare tail probabilities P(X ≥ μ + t)
    t_values = [5, 10, 15, 20, 25, 30]
    
    print(f"\n{'t':>4} | {'P(X ≥ μ+t)':>12} | {'Markov':>10} | {'Chebyshev':>10} | {'Hoeffding':>10} | {'Chernoff':>10}")
    print("-" * 75)
    
    for t in t_values:
        # Empirical
        empirical = np.mean(samples >= mu + t)
        
        # Markov (applied to X, not great for deviations)
        markov = mu / (mu + t)  # P(X ≥ a) ≤ E[X]/a
        
        # Chebyshev
        var = n * p * (1 - p)
        chebyshev = var / t**2  # P(|X-μ| ≥ t) ≤ Var/t²
        
        # Hoeffding (bounded RVs in [0,1])
        hoeffding = np.exp(-2 * t**2 / n)
        
        # Chernoff (multiplicative form for Binomial)
        delta = t / mu
        if delta < 1:
            chernoff = np.exp(-mu * (delta**2) / 3)  # Simplified bound
        else:
            chernoff = np.exp(-mu * delta / 3)
        
        print(f"{t:>4} | {empirical:>12.6f} | {min(markov,1):>10.6f} | {min(chebyshev,1):>10.6f} | {hoeffding:>10.6f} | {chernoff:>10.6f}")
    
    print("\n✓ Hoeffding and Chernoff give EXPONENTIALLY tighter bounds.")
    print("  Chebyshev decays polynomially (1/t²) — much weaker.\n")


def experiment_2_random_projection():
    """Demonstrate concentration of random projections."""
    print("=" * 60)
    print("EXPERIMENT 2: Random Projection Concentration")
    print("=" * 60)
    
    np.random.seed(42)
    
    # A random unit vector in R^d has nearly the same projection onto
    # any fixed direction, when d is large
    
    dims = [10, 50, 100, 500, 1000, 5000]
    N_samples = 10000
    
    print(f"\nProject random unit vectors onto e₁ = (1,0,...,0):")
    print(f"By concentration, |projection| ≈ 1/√d with small variance.\n")
    
    print(f"{'d':>6} | {'E[|proj|]':>10} | {'1/√d':>10} | {'Std(proj)':>10} | {'Max |proj|':>10}")
    print("-" * 55)
    
    for d in dims:
        # Random unit vectors
        X = np.random.randn(N_samples, d)
        X = X / np.linalg.norm(X, axis=1, keepdims=True)
        
        projections = X[:, 0]  # Project onto e_1
        
        print(f"{d:>6} | {np.mean(np.abs(projections)):>10.6f} | {1/np.sqrt(d):>10.6f} | {np.std(projections):>10.6f} | {np.max(np.abs(projections)):>10.6f}")
    
    print("\n✓ In high dimensions, random vectors are NEARLY ORTHOGONAL")
    print("  to any fixed direction. This is concentration at work.\n")


def experiment_3_johnson_lindenstrauss():
    """Demonstrate the Johnson-Lindenstrauss lemma."""
    print("=" * 60)
    print("EXPERIMENT 3: Johnson-Lindenstrauss Lemma")
    print("=" * 60)
    
    # JL Lemma: n points in R^d can be projected to R^k with
    # k = O(log(n)/ε²) while preserving all pairwise distances
    # up to factor (1 ± ε)
    
    np.random.seed(42)
    
    d_original = 1000  # Ambient dimension
    n_points = 200     # Number of points
    epsilon = 0.3      # Distortion tolerance
    
    # Generate random points
    X = np.random.randn(n_points, d_original)
    
    # Compute true pairwise distances
    from itertools import combinations
    pairs = list(combinations(range(n_points), 2))
    true_dists = np.array([np.linalg.norm(X[i] - X[j]) for i, j in pairs])
    
    # JL bound on target dimension
    k_jl = int(np.ceil(8 * np.log(n_points) / epsilon**2))
    print(f"\nOriginal dimension: d = {d_original}")
    print(f"Number of points: n = {n_points}")
    print(f"Distortion tolerance: ε = {epsilon}")
    print(f"JL target dimension: k ≥ {k_jl}")
    
    target_dims = [5, 10, 20, 50, k_jl, 200, 500]
    
    print(f"\n{'k':>6} | {'Max distortion':>15} | {'Mean distortion':>16} | {'% pairs with |dist-1|>ε':>25}")
    print("-" * 70)
    
    for k in target_dims:
        if k > d_original:
            continue
        
        # Random projection matrix (scaled Gaussian)
        P = np.random.randn(d_original, k) / np.sqrt(k)
        
        # Project
        Y = X @ P
        
        # Compute projected distances
        proj_dists = np.array([np.linalg.norm(Y[i] - Y[j]) for i, j in pairs])
        
        # Distortion ratios
        ratios = proj_dists / true_dists
        max_distortion = max(np.max(ratios) - 1, 1 - np.min(ratios))
        mean_distortion = np.mean(np.abs(ratios - 1))
        pct_violated = np.mean(np.abs(ratios - 1) > epsilon) * 100
        
        marker = " ← JL bound" if k == k_jl else ""
        print(f"{k:>6} | {max_distortion:>15.4f} | {mean_distortion:>16.6f} | {pct_violated:>24.1f}%{marker}")
    
    print(f"\n✓ At k = {k_jl} (JL bound), distances are preserved within ε = {epsilon}.")
    print("  This is O(log n / ε²) — independent of the original dimension!\n")


def experiment_4_blessing_of_dimensionality():
    """The blessing of dimensionality: high-d random variables are predictable."""
    print("=" * 60)
    print("EXPERIMENT 4: The Blessing of Dimensionality")
    print("=" * 60)
    
    np.random.seed(42)
    N_samples = 50000
    
    # In d dimensions, the norm of a random Gaussian vector concentrates
    # around √d with std ≈ 1/√2
    
    dims = [1, 2, 5, 10, 50, 100, 500, 1000]
    
    print(f"\n‖X‖ where X ~ N(0, I_d):")
    print(f"Theory: E[‖X‖] ≈ √d, Std[‖X‖] ≈ 1/√2 (for large d)\n")
    
    print(f"{'d':>6} | {'E[‖X‖]':>10} | {'√d':>10} | {'Std[‖X‖]':>10} | {'1/√2':>10} | {'CV':>8}")
    print("-" * 65)
    
    for d in dims:
        X = np.random.randn(N_samples, d)
        norms = np.linalg.norm(X, axis=1)
        
        mean_norm = np.mean(norms)
        std_norm = np.std(norms)
        cv = std_norm / mean_norm  # Coefficient of variation
        
        print(f"{d:>6} | {mean_norm:>10.4f} | {np.sqrt(d):>10.4f} | {std_norm:>10.4f} | {1/np.sqrt(2):>10.4f} | {cv:>8.4f}")
    
    print(f"\n  CV (coefficient of variation) → 0 as d → ∞")
    print(f"  In high dimensions, the norm is essentially DETERMINISTIC!")
    
    # Consequence: random vectors are nearly orthogonal
    print(f"\nAngle between random vectors in R^d:")
    
    print(f"\n{'d':>6} | {'Mean angle':>12} | {'Std angle':>12} | {'→ 90°?':>8}")
    print("-" * 50)
    
    for d in [2, 5, 10, 50, 100, 1000]:
        X = np.random.randn(N_samples, d)
        Y = np.random.randn(N_samples, d)
        
        cos_angles = np.sum(X * Y, axis=1) / (np.linalg.norm(X, axis=1) * np.linalg.norm(Y, axis=1))
        angles = np.arccos(np.clip(cos_angles, -1, 1)) * 180 / np.pi
        
        print(f"{d:>6} | {np.mean(angles):>11.2f}° | {np.std(angles):>11.2f}° | {'YES' if np.std(angles) < 5 else 'no':>8}")
    
    print("\n✓ THE BLESSING: In high dimensions, everything is predictable.")
    print("  Norms concentrate, angles concentrate at 90°, distances concentrate.")
    print("  This is why randomized algorithms work so well in high-d!\n")


if __name__ == "__main__":
    print("\n" + "=" * 60)
    print("  MATHEMATICS CHEAT CODE #5: CONCENTRATION INEQUALITIES")
    print("  'Randomness is surprisingly predictable.'")
    print("=" * 60 + "\n")
    
    experiment_1_bound_comparison()
    experiment_2_random_projection()
    experiment_3_johnson_lindenstrauss()
    experiment_4_blessing_of_dimensionality()
    
    print("=" * 60)
    print("SUMMARY: Concentration inequalities show that high-dimensional")
    print("random variables are predictable. Chernoff/Hoeffding give")
    print("exponential bounds. JL lemma compresses dimensions. The 'curse'")
    print("of dimensionality is also a 'blessing' — concentration makes")
    print("randomized algorithms reliable.")
    print("=" * 60)
