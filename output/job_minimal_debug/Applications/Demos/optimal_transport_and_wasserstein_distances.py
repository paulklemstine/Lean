#!/usr/bin/env python3
"""
Applications of Discrete Optimal Transport Theory

Demonstrates real-world applications:
1. Distributional robustness for ML classifiers
2. Color transfer between images (histogram matching)
3. Fair resource allocation via transport maps
4. Wasserstein barycenter computation
"""

import numpy as np
from scipy.optimize import linprog
import matplotlib.pyplot as plt
import matplotlib
matplotlib.use('Agg')


def solve_ot(c, mu, nu):
    """Solve optimal transport LP."""
    m, n = len(mu), len(nu)
    c_flat = c.flatten()
    A_eq = np.zeros((m + n, m * n))
    b_eq = np.concatenate([mu, nu])
    for i in range(m):
        for j in range(n):
            A_eq[i, i * n + j] = 1.0
            A_eq[m + j, i * n + j] = 1.0
    result = linprog(c_flat, A_eq=A_eq, b_eq=b_eq,
                     bounds=[(0, None)] * (m * n), method='highs')
    return result.x.reshape(m, n), result.fun


# ============================================================
# Application 1: Distributional Robustness
# ============================================================

def app_distributional_robustness():
    """
    Demonstrate how Wasserstein balls provide robustness guarantees.
    
    Key idea: If a classifier performs well on distribution μ, and
    W₁(μ, ν) ≤ ε, then performance on ν is bounded by the
    Lipschitz constant of the loss function times ε.
    """
    print("=" * 60)
    print("APPLICATION 1: Distributional Robustness")
    print("=" * 60)
    
    n = 10  # discrete feature space
    
    # Training distribution
    mu = np.array([0.15, 0.12, 0.10, 0.10, 0.08, 0.08, 0.10, 0.10, 0.09, 0.08])
    
    # Shifted test distribution (domain shift)
    nu = np.array([0.05, 0.05, 0.08, 0.12, 0.15, 0.15, 0.12, 0.10, 0.10, 0.08])
    
    # Feature-space metric
    d = np.abs(np.arange(n)[:, None] - np.arange(n)[None, :]).astype(float)
    
    # Compute Wasserstein distance
    _, w1 = solve_ot(d, mu, nu)
    
    # Loss function (K-Lipschitz)
    K = 2.0
    loss = np.array([0.1, 0.2, 0.3, 0.5, 0.7, 0.9, 0.8, 0.6, 0.4, 0.2])
    
    # Verify Lipschitz constant
    actual_K = max(abs(loss[i] - loss[j]) / max(d[i, j], 1e-10)
                   for i in range(n) for j in range(n) if i != j)
    
    train_risk = np.dot(loss, mu)
    test_risk = np.dot(loss, nu)
    
    print(f"Training risk: {train_risk:.4f}")
    print(f"Test risk: {test_risk:.4f}")
    print(f"Risk gap: {abs(test_risk - train_risk):.4f}")
    print(f"W₁(μ_train, μ_test): {w1:.4f}")
    print(f"Loss Lipschitz constant: {actual_K:.4f}")
    print(f"Guaranteed bound (K × W₁): {actual_K * w1:.4f}")
    print(f"Bound holds: {abs(test_risk - train_risk) <= actual_K * w1 + 1e-8}")
    
    # Visualization
    fig, axes = plt.subplots(1, 2, figsize=(12, 5))
    
    x = np.arange(n)
    axes[0].bar(x - 0.15, mu, 0.3, label='Training μ', color='steelblue', alpha=0.8)
    axes[0].bar(x + 0.15, nu, 0.3, label='Test ν', color='coral', alpha=0.8)
    axes[0].set_title('Distribution Shift')
    axes[0].set_xlabel('Feature')
    axes[0].legend()
    
    axes[1].plot(x, loss, 'ko-', linewidth=2, markersize=8, label='Loss function')
    axes[1].axhline(y=train_risk, color='steelblue', linestyle='--', label=f'Train risk: {train_risk:.3f}')
    axes[1].axhline(y=test_risk, color='coral', linestyle='--', label=f'Test risk: {test_risk:.3f}')
    axes[1].fill_between(x, train_risk - actual_K * w1, train_risk + actual_K * w1,
                         alpha=0.2, color='green', label=f'Robustness band (±K·W₁)')
    axes[1].set_title('Robustness Guarantee')
    axes[1].legend(fontsize=8)
    
    plt.tight_layout()
    plt.savefig('app_robustness.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: app_robustness.png")


# ============================================================
# Application 2: Histogram Color Transfer
# ============================================================

def app_color_transfer():
    """
    Use optimal transport to transfer color histograms between images.
    Demonstrates the monotone rearrangement as a practical algorithm.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: Histogram Transfer via OT")
    print("=" * 60)
    
    n_bins = 20
    
    # Source histogram (bimodal)
    x = np.linspace(0, 1, n_bins)
    source = np.exp(-((x - 0.3) ** 2) / 0.01) + 0.5 * np.exp(-((x - 0.7) ** 2) / 0.02)
    source /= source.sum()
    
    # Target histogram (unimodal)
    target = np.exp(-((x - 0.5) ** 2) / 0.03)
    target /= target.sum()
    
    # Cost matrix
    c = (x[:, None] - x[None, :]) ** 2
    
    # Solve OT
    pi, cost = solve_ot(c, source, target)
    
    # Transport map: for each source bin, find where mass goes
    transport_map = np.zeros(n_bins)
    for i in range(n_bins):
        if source[i] > 1e-10:
            transport_map[i] = np.sum(pi[i, :] * x) / source[i]
        else:
            transport_map[i] = x[i]
    
    print(f"Transport cost: {cost:.6f}")
    print(f"Support size of coupling: {np.sum(pi > 1e-8)}")
    
    fig, axes = plt.subplots(1, 3, figsize=(15, 4))
    
    axes[0].bar(x, source, width=0.04, color='steelblue', alpha=0.8, label='Source')
    axes[0].bar(x, target, width=0.04, color='coral', alpha=0.5, label='Target')
    axes[0].set_title('Source and Target Histograms')
    axes[0].legend()
    
    im = axes[1].imshow(pi, cmap='YlOrRd', aspect='auto', origin='lower')
    axes[1].set_xlabel('Target bin')
    axes[1].set_ylabel('Source bin')
    axes[1].set_title('Optimal Coupling')
    plt.colorbar(im, ax=axes[1])
    
    axes[2].plot(x, transport_map, 'go-', linewidth=2, label='Transport map')
    axes[2].plot([0, 1], [0, 1], 'k--', alpha=0.3, label='Identity')
    axes[2].set_xlabel('Source location')
    axes[2].set_ylabel('Target location')
    axes[2].set_title('Barycentric Transport Map')
    axes[2].legend()
    
    plt.tight_layout()
    plt.savefig('app_color_transfer.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: app_color_transfer.png")


# ============================================================
# Application 3: Wasserstein Barycenter
# ============================================================

def app_wasserstein_barycenter():
    """
    Compute the Wasserstein barycenter of multiple distributions.
    The barycenter minimizes the weighted sum of W₂² distances.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: Wasserstein Barycenter")
    print("=" * 60)
    
    n = 15
    x = np.linspace(0, 1, n)
    c = (x[:, None] - x[None, :]) ** 2
    
    # Three input distributions
    dists = [
        np.exp(-((x - 0.2) ** 2) / 0.005),
        np.exp(-((x - 0.5) ** 2) / 0.005),
        np.exp(-((x - 0.8) ** 2) / 0.005),
    ]
    dists = [d / d.sum() for d in dists]
    weights = [1/3, 1/3, 1/3]
    
    # Iterative Bregman projection for barycenter
    barycenter = np.ones(n) / n
    
    for iteration in range(50):
        grad = np.zeros(n)
        for d, w in zip(dists, weights):
            pi, _ = solve_ot(c, barycenter, d)
            # Gradient: derivative of W₂² w.r.t. barycenter weights
            transport_map = np.zeros(n)
            for i in range(n):
                if barycenter[i] > 1e-10:
                    transport_map[i] = np.sum(pi[i, :] * x) / barycenter[i]
                else:
                    transport_map[i] = x[i]
            displacement = (x - transport_map) ** 2
            grad += w * displacement
        
        # Update barycenter (simplified fixed-point)
        log_bar = np.log(barycenter + 1e-15) - 0.5 * grad
        barycenter = np.exp(log_bar)
        barycenter = np.maximum(barycenter, 1e-10)
        barycenter /= barycenter.sum()
    
    print("Input distributions: 3 Gaussians at 0.2, 0.5, 0.8")
    print(f"Barycenter computed via {iteration+1} iterations")
    
    fig, ax = plt.subplots(figsize=(8, 5))
    colors = ['steelblue', 'coral', 'green']
    for i, (d, color) in enumerate(zip(dists, colors)):
        ax.plot(x, d, '--', color=color, alpha=0.6, label=f'Distribution {i+1}')
    ax.plot(x, barycenter, 'k-', linewidth=3, label='Wasserstein Barycenter')
    ax.set_title('Wasserstein Barycenter of Three Distributions')
    ax.set_xlabel('x')
    ax.set_ylabel('Probability')
    ax.legend()
    
    plt.tight_layout()
    plt.savefig('app_barycenter.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: app_barycenter.png")


# ============================================================
# Application 4: Fair Resource Allocation
# ============================================================

def app_fair_allocation():
    """
    Model fair resource allocation as an optimal transport problem.
    Resources (supply) must be distributed to regions (demand)
    minimizing total transportation cost while satisfying all demands.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 4: Fair Resource Allocation")
    print("=" * 60)
    
    # 4 supply centers, 5 demand regions
    supply = np.array([0.3, 0.2, 0.3, 0.2])
    demand = np.array([0.15, 0.2, 0.25, 0.2, 0.2])
    
    # Cost matrix (distance-based)
    c = np.array([
        [1, 3, 5, 7, 9],
        [2, 1, 3, 5, 7],
        [4, 2, 1, 2, 4],
        [6, 4, 2, 1, 2],
    ], dtype=float)
    
    pi, cost = solve_ot(c, supply, demand)
    
    print("Supply centers:", supply)
    print("Demand regions:", demand)
    print(f"\nOptimal allocation:\n{np.round(pi, 4)}")
    print(f"Total transport cost: {cost:.4f}")
    
    # Verify fairness: each region gets exactly what it needs
    allocation = pi.sum(axis=0)
    print(f"\nAllocation to each region: {np.round(allocation, 4)}")
    print(f"Demand satisfied: {np.allclose(allocation, demand)}")
    
    fig, ax = plt.subplots(figsize=(8, 6))
    im = ax.imshow(pi, cmap='YlGnBu', aspect='auto')
    ax.set_xlabel('Demand Region')
    ax.set_ylabel('Supply Center')
    ax.set_title('Optimal Resource Allocation Plan')
    
    for i in range(len(supply)):
        for j in range(len(demand)):
            text = ax.text(j, i, f'{pi[i,j]:.3f}',
                          ha="center", va="center",
                          color="white" if pi[i,j] > 0.1 else "black")
    
    plt.colorbar(im, ax=ax)
    plt.tight_layout()
    plt.savefig('app_allocation.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: app_allocation.png")


if __name__ == "__main__":
    np.random.seed(42)
    app_distributional_robustness()
    app_color_transfer()
    app_wasserstein_barycenter()
    app_fair_allocation()
    print("\n" + "=" * 60)
    print("All applications completed!")
    print("=" * 60)


#!/usr/bin/env python3
"""
Discrete Optimal Transport: Interactive Demo

Demonstrates the core theorems formalized in our Lean 4 development:
1. Optimal coupling computation for finite distributions
2. Kantorovich duality: primal cost = dual value
3. Complementary slackness verification
4. WGAN critic stability: |critic gap| ≤ K * Wasserstein
5. Quadratic swap inequality and monotone rearrangement
"""

import numpy as np
from scipy.optimize import linprog
import matplotlib.pyplot as plt
import matplotlib
matplotlib.use('Agg')


# ============================================================
# Core Definitions
# ============================================================

def transport_cost(c, pi):
    """Compute ∑_{a,b} c(a,b) * π(a,b)."""
    return np.sum(c * pi)


def solve_optimal_transport(c, mu, nu):
    """
    Solve the Kantorovich optimal transport problem via linear programming.
    
    min ∑ c_{ij} π_{ij}
    s.t. ∑_j π_{ij} = μ_i  (left marginal)
         ∑_i π_{ij} = ν_j  (right marginal)
         π_{ij} ≥ 0
    
    Returns: optimal coupling π, optimal cost, dual potentials (φ, ψ).
    """
    m, n = len(mu), len(nu)
    c_flat = c.flatten()
    
    # Equality constraints: left marginals + right marginals
    A_eq = np.zeros((m + n, m * n))
    b_eq = np.concatenate([mu, nu])
    
    for i in range(m):
        for j in range(n):
            A_eq[i, i * n + j] = 1.0       # left marginal
            A_eq[m + j, i * n + j] = 1.0    # right marginal
    
    result = linprog(c_flat, A_eq=A_eq, b_eq=b_eq, bounds=[(0, None)] * (m * n), method='highs')
    
    pi_opt = result.x.reshape(m, n)
    opt_cost = result.fun
    
    # Extract dual potentials from dual variables
    # The dual of the LP gives φ (first m) and ψ (last n)
    if hasattr(result, 'eqlin') and result.eqlin is not None:
        dual = result.eqlin.marginals
        phi = dual[:m]
        psi = dual[m:]
    else:
        # Fallback: compute c-transform
        phi = np.min(c - np.zeros((m, 1)), axis=1)  # trivial initialization
        psi = np.min(c.T - phi, axis=1)
        # Refine via c-transform iteration
        for _ in range(100):
            phi_new = np.min(c - psi[np.newaxis, :], axis=1)
            psi_new = np.min(c.T - phi_new[:, np.newaxis].T, axis=0)
            if np.max(np.abs(phi_new - phi)) < 1e-12:
                break
            phi, psi = phi_new, psi_new
    
    return pi_opt, opt_cost, phi, psi


def dual_value(mu, nu, phi, psi):
    """Compute ∑_a φ(a)μ(a) + ∑_b ψ(b)ν(b)."""
    return np.dot(phi, mu) + np.dot(psi, nu)


def verify_admissibility(c, phi, psi, tol=1e-8):
    """Check φ(a) + ψ(b) ≤ c(a,b) for all a, b."""
    m, n = len(phi), len(psi)
    for i in range(m):
        for j in range(n):
            if phi[i] + psi[j] > c[i, j] + tol:
                return False
    return True


def verify_complementary_slackness(c, pi, phi, psi, tol=1e-8):
    """Check that π(a,b) > 0 implies φ(a) + ψ(b) = c(a,b)."""
    m, n = pi.shape
    violations = []
    for i in range(m):
        for j in range(n):
            if pi[i, j] > tol:
                gap = abs(phi[i] + psi[j] - c[i, j])
                if gap > tol:
                    violations.append((i, j, gap))
    return len(violations) == 0, violations


# ============================================================
# Demo 1: Basic Optimal Transport
# ============================================================

def demo_basic_ot():
    print("=" * 60)
    print("DEMO 1: Optimal Transport between Two Distributions")
    print("=" * 60)
    
    # Source and target distributions
    mu = np.array([0.3, 0.5, 0.2])
    nu = np.array([0.4, 0.3, 0.3])
    
    # Cost matrix (Euclidean distances on points [0, 1, 3])
    points_src = np.array([0.0, 1.0, 3.0])
    points_tgt = np.array([0.5, 2.0, 4.0])
    c = np.abs(points_src[:, np.newaxis] - points_tgt[np.newaxis, :])
    
    print(f"\nSource distribution μ: {mu}")
    print(f"Target distribution ν: {nu}")
    print(f"Source points: {points_src}")
    print(f"Target points: {points_tgt}")
    print(f"\nCost matrix:\n{c}")
    
    pi_opt, opt_cost, phi, psi = solve_optimal_transport(c, mu, nu)
    
    print(f"\nOptimal coupling π*:\n{np.round(pi_opt, 6)}")
    print(f"Optimal transport cost: {opt_cost:.6f}")
    print(f"Dual potentials φ: {np.round(phi, 6)}")
    print(f"Dual potentials ψ: {np.round(psi, 6)}")
    
    dv = dual_value(mu, nu, phi, psi)
    print(f"Dual value: {dv:.6f}")
    print(f"Duality gap: {abs(opt_cost - dv):.2e}")
    
    # Verify admissibility
    adm = verify_admissibility(c, phi, psi)
    print(f"Admissibility check: {'PASS' if adm else 'FAIL'}")
    
    # Verify complementary slackness
    cs_ok, violations = verify_complementary_slackness(c, pi_opt, phi, psi)
    print(f"Complementary slackness: {'PASS' if cs_ok else 'FAIL'}")
    
    # Verify marginals
    print(f"Left marginal check: {np.allclose(pi_opt.sum(axis=1), mu)}")
    print(f"Right marginal check: {np.allclose(pi_opt.sum(axis=0), nu)}")
    
    # Visualization
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))
    
    # Transport plan heatmap
    im = axes[0].imshow(pi_opt, cmap='Blues', aspect='auto')
    axes[0].set_xlabel('Target index')
    axes[0].set_ylabel('Source index')
    axes[0].set_title('Optimal Coupling π*')
    plt.colorbar(im, ax=axes[0])
    
    # Distributions
    x = np.arange(len(mu))
    axes[1].bar(x - 0.15, mu, 0.3, label='μ (source)', color='steelblue')
    axes[1].bar(x + 0.15, nu, 0.3, label='ν (target)', color='coral')
    axes[1].set_title('Source and Target Distributions')
    axes[1].legend()
    
    # Dual potentials
    axes[2].bar(x - 0.15, phi, 0.3, label='φ (source potential)', color='darkgreen')
    axes[2].bar(x + 0.15, psi, 0.3, label='ψ (target potential)', color='purple')
    axes[2].set_title('Dual Potentials')
    axes[2].legend()
    
    plt.tight_layout()
    plt.savefig('demo_basic_ot.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("\nSaved: demo_basic_ot.png")


# ============================================================
# Demo 2: WGAN Critic Stability
# ============================================================

def demo_wgan_stability():
    print("\n" + "=" * 60)
    print("DEMO 2: WGAN Critic Stability Theorem")
    print("=" * 60)
    
    n = 5
    # Two distributions on n points
    mu = np.random.dirichlet(np.ones(n))
    nu = np.random.dirichlet(np.ones(n))
    
    # Metric: |i - j|
    d = np.abs(np.arange(n)[:, None] - np.arange(n)[None, :]).astype(float)
    
    # Compute W1
    pi_opt, w1, _, _ = solve_optimal_transport(d, mu, nu)
    
    print(f"μ: {np.round(mu, 4)}")
    print(f"ν: {np.round(nu, 4)}")
    print(f"Wasserstein-1 distance: {w1:.6f}")
    
    # Test with K-Lipschitz critics
    K_values = [0.5, 1.0, 2.0, 5.0]
    n_critics = 1000
    
    print(f"\nTesting {n_critics} random critics for each K:")
    print(f"{'K':>6} | {'Max critic gap':>15} | {'K * W1':>10} | {'Bound holds?':>12}")
    print("-" * 55)
    
    results = []
    for K in K_values:
        max_gap = 0
        for _ in range(n_critics):
            # Generate random K-Lipschitz function
            f = np.zeros(n)
            f[0] = np.random.randn()
            for i in range(1, n):
                f[i] = f[i-1] + np.random.uniform(-K, K)
            
            gap = np.dot(f, mu) - np.dot(f, nu)
            max_gap = max(max_gap, abs(gap))
        
        bound = K * w1
        holds = max_gap <= bound + 1e-10
        print(f"{K:6.1f} | {max_gap:15.6f} | {bound:10.6f} | {'PASS' if holds else 'FAIL':>12}")
        results.append((K, max_gap, bound))
    
    # Visualization
    fig, ax = plt.subplots(figsize=(8, 5))
    Ks = [r[0] for r in results]
    gaps = [r[1] for r in results]
    bounds = [r[2] for r in results]
    
    ax.bar(np.arange(len(Ks)) - 0.15, gaps, 0.3, label='Max observed critic gap', color='coral')
    ax.bar(np.arange(len(Ks)) + 0.15, bounds, 0.3, label='K × W₁ bound', color='steelblue')
    ax.set_xticks(np.arange(len(Ks)))
    ax.set_xticklabels([f'K={k}' for k in Ks])
    ax.set_ylabel('Value')
    ax.set_title('WGAN Critic Stability: |critic gap| ≤ K × W₁')
    ax.legend()
    
    plt.tight_layout()
    plt.savefig('demo_wgan_stability.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("\nSaved: demo_wgan_stability.png")


# ============================================================
# Demo 3: Quadratic Swap Inequality and Monotone Rearrangement
# ============================================================

def demo_quadratic_swap():
    print("\n" + "=" * 60)
    print("DEMO 3: Quadratic Swap Inequality")
    print("=" * 60)
    
    # Verify the swap inequality for many random examples
    n_tests = 100000
    violations = 0
    
    for _ in range(n_tests):
        x1, x2 = sorted(np.random.randn(2))
        y1, y2 = sorted(np.random.randn(2))
        
        ordered_cost = (x1 - y1)**2 + (x2 - y2)**2
        crossed_cost = (x1 - y2)**2 + (x2 - y1)**2
        
        if ordered_cost > crossed_cost + 1e-12:
            violations += 1
    
    print(f"Tested {n_tests} random ordered pairs")
    print(f"Violations of (x₁-y₁)² + (x₂-y₂)² ≤ (x₁-y₂)² + (x₂-y₁)²: {violations}")
    print(f"Result: {'VERIFIED' if violations == 0 else 'FAILED'}")
    
    # Demonstrate monotone rearrangement optimality
    print("\n--- Monotone Rearrangement Demo ---")
    n = 6
    x = np.sort(np.random.randn(n))
    y = np.sort(np.random.randn(n))
    
    # Monotone assignment cost
    mono_cost = np.sum((x - y)**2)
    
    # Compare with random permutations
    n_perms = 10000
    min_random_cost = float('inf')
    costs = []
    for _ in range(n_perms):
        perm = np.random.permutation(n)
        cost = np.sum((x - y[perm])**2)
        costs.append(cost)
        min_random_cost = min(min_random_cost, cost)
    
    print(f"Source points x: {np.round(x, 3)}")
    print(f"Target points y: {np.round(y, 3)}")
    print(f"Monotone assignment cost: {mono_cost:.6f}")
    print(f"Best random permutation cost ({n_perms} tries): {min_random_cost:.6f}")
    print(f"Monotone is optimal: {mono_cost <= min_random_cost + 1e-10}")
    
    # Visualization
    fig, axes = plt.subplots(1, 2, figsize=(12, 5))
    
    # Show monotone vs crossed matching
    ax = axes[0]
    ax.scatter(x, np.zeros_like(x), c='steelblue', s=100, zorder=5, label='Source x')
    ax.scatter(y, np.ones_like(y), c='coral', s=100, zorder=5, label='Target y')
    for i in range(n):
        ax.plot([x[i], y[i]], [0, 1], 'g-', alpha=0.7, linewidth=2)
    ax.set_title('Monotone Transport (Optimal)')
    ax.legend()
    ax.set_yticks([0, 1])
    ax.set_yticklabels(['Source', 'Target'])
    
    # Cost histogram
    ax = axes[1]
    ax.hist(costs, bins=50, color='lightgray', edgecolor='black', alpha=0.7)
    ax.axvline(mono_cost, color='green', linewidth=2, label=f'Monotone: {mono_cost:.3f}')
    ax.set_xlabel('Quadratic Transport Cost')
    ax.set_ylabel('Count')
    ax.set_title('Cost Distribution over Random Permutations')
    ax.legend()
    
    plt.tight_layout()
    plt.savefig('demo_quadratic_swap.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("\nSaved: demo_quadratic_swap.png")


# ============================================================
# Demo 4: Complementary Slackness Verification
# ============================================================

def demo_complementary_slackness():
    print("\n" + "=" * 60)
    print("DEMO 4: Complementary Slackness")
    print("=" * 60)
    
    mu = np.array([0.25, 0.25, 0.25, 0.25])
    nu = np.array([0.3, 0.2, 0.3, 0.2])
    
    c = np.array([
        [0, 1, 2, 3],
        [1, 0, 1, 2],
        [2, 1, 0, 1],
        [3, 2, 1, 0]
    ], dtype=float)
    
    pi_opt, cost, phi, psi = solve_optimal_transport(c, mu, nu)
    
    print(f"Cost matrix:\n{c}")
    print(f"\nOptimal coupling:\n{np.round(pi_opt, 6)}")
    print(f"Transport cost: {cost:.6f}")
    print(f"φ: {np.round(phi, 4)}")
    print(f"ψ: {np.round(psi, 4)}")
    
    print("\nComplementary slackness check:")
    print(f"{'(i,j)':>8} | {'π(i,j)':>10} | {'φ(i)+ψ(j)':>12} | {'c(i,j)':>8} | {'Tight?':>8}")
    print("-" * 60)
    
    for i in range(len(mu)):
        for j in range(len(nu)):
            if pi_opt[i, j] > 1e-8:
                dual_sum = phi[i] + psi[j]
                tight = abs(dual_sum - c[i, j]) < 1e-6
                print(f"({i},{j}):    | {pi_opt[i,j]:10.6f} | {dual_sum:12.6f} | {c[i,j]:8.1f} | {'YES' if tight else 'NO':>8}")


# ============================================================
# Demo 5: Gluing Lemma / Triangle Inequality
# ============================================================

def demo_triangle_inequality():
    print("\n" + "=" * 60)
    print("DEMO 5: Triangle Inequality for Wasserstein Distance")
    print("=" * 60)
    
    n = 4
    d = np.abs(np.arange(n)[:, None] - np.arange(n)[None, :]).astype(float)
    
    # Three distributions
    mu = np.array([0.4, 0.3, 0.2, 0.1])
    nu = np.array([0.1, 0.3, 0.3, 0.3])
    rho = np.array([0.25, 0.25, 0.25, 0.25])
    
    _, w_mu_nu, _, _ = solve_optimal_transport(d, mu, nu)
    _, w_nu_rho, _, _ = solve_optimal_transport(d, nu, rho)
    _, w_mu_rho, _, _ = solve_optimal_transport(d, mu, rho)
    
    print(f"W₁(μ, ν) = {w_mu_nu:.6f}")
    print(f"W₁(ν, ρ) = {w_nu_rho:.6f}")
    print(f"W₁(μ, ρ) = {w_mu_rho:.6f}")
    print(f"W₁(μ, ν) + W₁(ν, ρ) = {w_mu_nu + w_nu_rho:.6f}")
    print(f"Triangle inequality: W₁(μ,ρ) ≤ W₁(μ,ν) + W₁(ν,ρ)")
    print(f"Result: {'HOLDS' if w_mu_rho <= w_mu_nu + w_nu_rho + 1e-10 else 'VIOLATED'}")
    
    # Test on many random triples
    n_tests = 1000
    violations = 0
    for _ in range(n_tests):
        m = np.random.dirichlet(np.ones(n))
        n_ = np.random.dirichlet(np.ones(n))
        r = np.random.dirichlet(np.ones(n))
        
        _, w12, _, _ = solve_optimal_transport(d, m, n_)
        _, w23, _, _ = solve_optimal_transport(d, n_, r)
        _, w13, _, _ = solve_optimal_transport(d, m, r)
        
        if w13 > w12 + w23 + 1e-8:
            violations += 1
    
    print(f"\nRandom triangle inequality tests: {n_tests}")
    print(f"Violations: {violations}")


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    np.random.seed(42)
    
    demo_basic_ot()
    demo_wgan_stability()
    demo_quadratic_swap()
    demo_complementary_slackness()
    demo_triangle_inequality()
    
    print("\n" + "=" * 60)
    print("All demos completed successfully!")
    print("=" * 60)
