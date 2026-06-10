"""
Idempotent Kantorovich-Rubinstein Duality: Computational Demonstrations

This script demonstrates the core concepts of tropical/idempotent optimal transport
with concrete numerical examples and visualizations.

Key objects:
- MaxitiveProb: log-possibility profiles μ : X → ℝ with max(μ) = 0
- Maxitive integral: Λ_μ(f) = max_x(μ(x) + f(x))
- KR discrepancy: sup_{f 1-Lip}(Λ_μ(f) - Λ_ν(f))
- Transport cost: C(π) = max_{x,y}(π(x,y) + d(x,y))
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import product


class MaxitiveProb:
    """A maxitive probability profile on a finite set {0,...,n-1}."""
    def __init__(self, values):
        values = np.array(values, dtype=float)
        assert np.max(values) == 0, f"Must be normalized: max={np.max(values)}"
        assert np.all(values <= 0), "Must be non-positive"
        self.values = values
        self.n = len(values)

    def __repr__(self):
        return f"MaxitiveProb({self.values})"

    def integral(self, f):
        """Maxitive integral Λ_μ(f) = max_x(μ(x) + f(x))."""
        return np.max(self.values + f)


def kr_discrepancy(mu, nu, dist_matrix):
    """Compute the KR discrepancy by optimizing over 1-Lipschitz functions.

    For finite types, we use a discrete optimization approach.
    The KR discrepancy is sup_{f 1-Lip}(Λ_μ(f) - Λ_ν(f)).
    """
    n = mu.n
    # For small n, enumerate a grid of functions
    # A function is 1-Lip iff f(x)-f(y) ≤ d(x,y) for all x,y
    # Fix f(0) = 0 (wlog by translation invariance of the difference)
    best = -np.inf
    best_f = None

    # Use the Dijkstra-like construction: f_z(x) = d(x,z) is always 1-Lip
    for z in range(n):
        f = dist_matrix[:, z]
        disc = mu.integral(f) - nu.integral(f)
        if disc > best:
            best = disc
            best_f = f.copy()

    # Also try negated distance functions
    for z in range(n):
        f = -dist_matrix[:, z]
        disc = mu.integral(f) - nu.integral(f)
        if disc > best:
            best = disc
            best_f = f.copy()

    # For n small, also try a finer grid
    if n <= 5:
        # Random search over 1-Lip functions
        for _ in range(10000):
            f = np.random.randn(n) * np.max(dist_matrix)
            # Project onto 1-Lip cone
            for _ in range(100):
                changed = False
                for i in range(n):
                    for j in range(n):
                        if f[i] - f[j] > dist_matrix[i, j]:
                            avg = (f[i] + f[j] + dist_matrix[i, j]) / 2
                            f[i] = min(f[i], avg)
                            f[j] = max(f[j], avg - dist_matrix[i, j])
                            changed = True
                if not changed:
                    break
            disc = mu.integral(f) - nu.integral(f)
            if disc > best:
                best = disc
                best_f = f.copy()

    return best, best_f


def transport_cost(pi, dist_matrix):
    """Compute C(π) = max_{x,y}(π(x,y) + d(x,y))."""
    return np.max(pi + dist_matrix)


def maxitive_coupling(mu, nu, dist_matrix):
    """Construct a simple maxitive coupling by sending modes to modes."""
    n = mu.n
    # Simple coupling: diagonal with adjustments
    pi = np.full((n, n), -1e10)

    # For each x, find the best y to couple with
    mode_mu = np.argmax(mu.values)
    mode_nu = np.argmax(nu.values)

    # Set π(mode_μ, mode_ν) = 0
    pi[mode_mu, mode_nu] = 0

    # Fill in to satisfy marginals approximately
    for x in range(n):
        pi[x, mode_nu] = max(pi[x, mode_nu], mu.values[x])
    for y in range(n):
        pi[mode_mu, y] = max(pi[mode_mu, y], nu.values[y])

    return pi


# ============================================================
# DEMO 1: Two-point space
# ============================================================
def demo_two_point():
    print("=" * 60)
    print("DEMO 1: Two-point space {a, b} with dist(a,b) = 1")
    print("=" * 60)

    D = 1.0
    dist_mat = np.array([[0, D], [D, 0]])

    mu = MaxitiveProb([0, -0.5])    # Mode at a
    nu = MaxitiveProb([-0.5, 0])    # Mode at b

    print(f"μ = {mu.values}  (mode at point 0)")
    print(f"ν = {nu.values}  (mode at point 1)")

    # KR discrepancy
    disc, best_f = kr_discrepancy(mu, nu, dist_mat)
    print(f"\nKR discrepancy = {disc:.4f}")
    print(f"Optimal test function: f = {best_f}")

    # Profile distance bound
    profile_diff = np.max(mu.values - nu.values)
    print(f"Profile distance bound: max(μ-ν) = {profile_diff:.4f}")

    # Coupling
    pi = maxitive_coupling(mu, nu, dist_mat)
    cost = transport_cost(pi, dist_mat)
    print(f"\nTransport cost C(π) = {cost:.4f}")
    print(f"Coupling π = \n{pi}")

    # Verify weak duality
    print(f"\nWeak duality check: {disc:.4f} ≤ {cost:.4f}: {disc <= cost + 1e-10}")

    return disc, cost


# ============================================================
# DEMO 2: Three-point space with asymmetric modes
# ============================================================
def demo_three_point():
    print("\n" + "=" * 60)
    print("DEMO 2: Three-point space with varying distances")
    print("=" * 60)

    dist_mat = np.array([
        [0, 1, 3],
        [1, 0, 2],
        [3, 2, 0]
    ], dtype=float)

    mu = MaxitiveProb([0, -1, -2])    # Mode at point 0
    nu = MaxitiveProb([-2, -1, 0])    # Mode at point 2

    print(f"μ = {mu.values}")
    print(f"ν = {nu.values}")
    print(f"Distance matrix:\n{dist_mat}")

    disc, best_f = kr_discrepancy(mu, nu, dist_mat)
    print(f"\nKR discrepancy = {disc:.4f}")
    print(f"Optimal test function: f = {np.round(best_f, 3)}")

    profile_diff = np.max(mu.values - nu.values)
    print(f"Profile distance bound: max(μ-ν) = {profile_diff:.4f}")

    pi = maxitive_coupling(mu, nu, dist_mat)
    cost = transport_cost(pi, dist_mat)
    print(f"Transport cost C(π) = {cost:.4f}")

    # Test several 1-Lip functions
    print("\nTest functions and discrepancies:")
    for z in range(3):
        f = dist_mat[:, z]
        d = mu.integral(f) - nu.integral(f)
        print(f"  f = d(·,{z}) = {f}: Λ_μ(f)-Λ_ν(f) = {d:.3f}")

    return disc, cost


# ============================================================
# DEMO 3: Visualization of maxitive integral
# ============================================================
def demo_visualization():
    print("\n" + "=" * 60)
    print("DEMO 3: Maxitive integral visualization")
    print("=" * 60)

    n = 20
    X = np.linspace(0, 1, n)
    dist_mat = np.abs(X[:, None] - X[None, :])

    # Gaussian-like maxitive profiles
    center_mu = 0.3
    center_nu = 0.7
    sigma = 0.15

    mu_vals = -((X - center_mu) / sigma) ** 2
    mu_vals -= np.max(mu_vals)
    mu = MaxitiveProb(mu_vals)

    nu_vals = -((X - center_nu) / sigma) ** 2
    nu_vals -= np.max(nu_vals)
    nu = MaxitiveProb(nu_vals)

    fig, axes = plt.subplots(2, 2, figsize=(12, 10))

    # Plot 1: Maxitive profiles
    axes[0, 0].plot(X, mu.values, 'b-o', markersize=3, label='μ (mode at 0.3)')
    axes[0, 0].plot(X, nu.values, 'r-s', markersize=3, label='ν (mode at 0.7)')
    axes[0, 0].set_xlabel('x')
    axes[0, 0].set_ylabel('Log-possibility weight')
    axes[0, 0].set_title('Maxitive Probability Profiles')
    axes[0, 0].legend()
    axes[0, 0].grid(True, alpha=0.3)

    # Plot 2: Discrepancy as function of test point z (f = d(·,z))
    discs = []
    for z in range(n):
        f = dist_mat[:, z]
        d = mu.integral(f) - nu.integral(f)
        discs.append(d)

    axes[0, 1].plot(X, discs, 'g-^', markersize=3)
    axes[0, 1].axhline(y=0, color='k', linestyle='--', alpha=0.3)
    axes[0, 1].set_xlabel('Test point z')
    axes[0, 1].set_ylabel('Λ_μ(d(·,z)) - Λ_ν(d(·,z))')
    axes[0, 1].set_title('KR Discrepancy for Distance Test Functions')
    axes[0, 1].grid(True, alpha=0.3)

    # Plot 3: Maxitive integral values
    integrals_mu = []
    integrals_nu = []
    for z in range(n):
        f = dist_mat[:, z]
        integrals_mu.append(mu.integral(f))
        integrals_nu.append(nu.integral(f))

    axes[1, 0].plot(X, integrals_mu, 'b-', label='Λ_μ(d(·,z))')
    axes[1, 0].plot(X, integrals_nu, 'r-', label='Λ_ν(d(·,z))')
    axes[1, 0].set_xlabel('Test point z')
    axes[1, 0].set_ylabel('Integral value')
    axes[1, 0].set_title('Maxitive Integrals')
    axes[1, 0].legend()
    axes[1, 0].grid(True, alpha=0.3)

    # Plot 4: Profile difference bound
    profile_diffs = mu.values - nu.values
    axes[1, 1].bar(X, profile_diffs, width=0.04, color='purple', alpha=0.7)
    axes[1, 1].axhline(y=np.max(profile_diffs), color='orange', linestyle='--',
                        label=f'max(μ-ν) = {np.max(profile_diffs):.3f}')
    axes[1, 1].set_xlabel('x')
    axes[1, 1].set_ylabel('μ(x) - ν(x)')
    axes[1, 1].set_title('Profile Difference (Proved Bound)')
    axes[1, 1].legend()
    axes[1, 1].grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('/workspace/request-project/Bridges/IdempotentKR/maxitive_demo.png', dpi=150)
    print("Saved visualization to maxitive_demo.png")
    plt.close()


# ============================================================
# DEMO 4: Functorial nonexpansiveness
# ============================================================
def demo_functorial():
    print("\n" + "=" * 60)
    print("DEMO 4: Functorial nonexpansiveness under Lipschitz maps")
    print("=" * 60)

    n = 5
    X = np.linspace(0, 1, n)
    dist_X = np.abs(X[:, None] - X[None, :])

    mu = MaxitiveProb(-np.abs(X - 0.25) * 2)
    nu = MaxitiveProb(-np.abs(X - 0.75) * 2)

    # Verify normalization
    mu.values -= np.max(mu.values)
    nu.values -= np.max(nu.values)

    disc_X, _ = kr_discrepancy(mu, nu, dist_X)
    print(f"Discrepancy on X: {disc_X:.4f}")

    # Apply a 1-Lipschitz map T: x ↦ x/2 (contraction)
    T = lambda x: x / 2
    Y_points = T(X)
    dist_Y = np.abs(Y_points[:, None] - Y_points[None, :])

    disc_Y, _ = kr_discrepancy(mu, nu, dist_Y)
    print(f"Discrepancy after contraction T(x)=x/2: {disc_Y:.4f}")
    print(f"Nonexpansive: {disc_Y:.4f} ≤ {disc_X:.4f}: {disc_Y <= disc_X + 1e-10}")


if __name__ == "__main__":
    demo_two_point()
    demo_three_point()
    demo_visualization()
    demo_functorial()

    print("\n" + "=" * 60)
    print("All demos completed successfully!")
    print("=" * 60)
