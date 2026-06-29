#!/usr/bin/env python3
"""
Applications of Arithmetic Thermodynamics

Real-world applications demonstrating the connection between
statistical mechanics and discrete dynamical systems.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from typing import List, Tuple


# ============================================================
# Application 1: Cryptographic Hash Function Analysis
# ============================================================

def hash_iteration_analysis():
    """
    Analyze iteration counts of a hash-like function using thermodynamic tools.

    In cryptographic hash functions, the number of iterations to reach a
    fixed point or cycle is an important security parameter. Thermodynamic
    analysis reveals the statistical structure of these iteration counts.
    """
    np.random.seed(42)

    # Simulate a hash-like iteration: f(x) = (ax + b) mod p
    p = 1009  # prime
    a, b = 137, 541

    def iterations_to_cycle(x0: int, max_iter: int = 500) -> int:
        seen = set()
        x = x0
        for i in range(max_iter):
            if x in seen:
                return i
            seen.add(x)
            x = (a * x + b) % p
        return max_iter

    N = p
    tau = np.array([iterations_to_cycle(x) for x in range(N)], dtype=float)
    w = np.ones(N)

    theta = np.linspace(-0.05, 0.15, 200)

    # Compute thermodynamic quantities
    results = []
    for th in theta:
        exps = w * np.exp(-th * tau)
        Z = np.sum(exps)
        p_gibbs = exps / Z
        mean = np.sum(p_gibbs * tau)
        var = np.sum(p_gibbs * tau**2) - mean**2
        entropy = -np.sum(p_gibbs[p_gibbs > 0] * np.log(p_gibbs[p_gibbs > 0]))
        results.append((np.log(Z), -mean, var, entropy))

    F, Fp, Fpp, S = zip(*results)

    fig, axes = plt.subplots(2, 2, figsize=(12, 10))

    axes[0, 0].plot(theta, F, 'b-', linewidth=2)
    axes[0, 0].set_title('Free Energy F(θ)')
    axes[0, 0].set_xlabel('θ')
    axes[0, 0].grid(True, alpha=0.3)

    axes[0, 1].plot(theta, Fp, 'r-', linewidth=2)
    axes[0, 1].set_title('Mean Iteration Count -⟨τ⟩_θ')
    axes[0, 1].set_xlabel('θ')
    axes[0, 1].grid(True, alpha=0.3)

    axes[1, 0].plot(theta, Fpp, 'g-', linewidth=2)
    axes[1, 0].set_title('Variance (Specific Heat)')
    axes[1, 0].set_xlabel('θ')
    axes[1, 0].grid(True, alpha=0.3)

    axes[1, 1].plot(theta, S, 'm-', linewidth=2)
    axes[1, 1].set_title('Gibbs Entropy S(θ)')
    axes[1, 1].set_xlabel('θ')
    axes[1, 1].grid(True, alpha=0.3)

    plt.suptitle('Cryptographic Hash: Thermodynamic Analysis of Iteration Counts',
                 fontsize=13, fontweight='bold')
    plt.tight_layout()
    plt.savefig('fig_hash_analysis.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Hash function analysis saved: fig_hash_analysis.png")


# ============================================================
# Application 2: Random Walk First-Passage Times
# ============================================================

def random_walk_application():
    """
    Thermodynamics of first-passage times in random walks.

    First-passage times are natural stopping-time observables.
    Their thermodynamic analysis reveals the structure of
    return-time distributions.
    """
    np.random.seed(123)

    # Simple random walk on Z: first return to origin
    n_samples = 2000
    max_steps = 500

    first_return_times = []
    for _ in range(n_samples):
        pos = 0
        for t in range(1, max_steps + 1):
            pos += np.random.choice([-1, 1])
            if pos == 0:
                first_return_times.append(t)
                break
        else:
            first_return_times.append(max_steps)

    tau = np.array(first_return_times, dtype=float)
    w = np.ones(len(tau))

    theta = np.linspace(-0.02, 0.1, 200)

    F_vals = []
    var_vals = []
    for th in theta:
        exps = w * np.exp(-th * tau)
        Z = np.sum(exps)
        p_gibbs = exps / Z
        mean = np.sum(p_gibbs * tau)
        var = np.sum(p_gibbs * tau**2) - mean**2
        F_vals.append(np.log(Z))
        var_vals.append(var)

    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    axes[0].hist(tau, bins=50, density=True, alpha=0.7, color='steelblue')
    axes[0].set_xlabel('First return time τ')
    axes[0].set_ylabel('Density')
    axes[0].set_title('Distribution of First Return Times')
    axes[0].grid(True, alpha=0.3)

    axes[1].plot(theta, F_vals, 'b-', linewidth=2)
    axes[1].set_xlabel('θ')
    axes[1].set_ylabel('F(θ)')
    axes[1].set_title('Free Energy (Convex)')
    axes[1].grid(True, alpha=0.3)

    axes[2].plot(theta, var_vals, 'r-', linewidth=2)
    axes[2].axhline(y=0, color='k', alpha=0.3)
    axes[2].set_xlabel('θ')
    axes[2].set_ylabel('Var_θ(τ)')
    axes[2].set_title('Gibbs Variance = F\'\'(θ) ≥ 0')
    axes[2].grid(True, alpha=0.3)

    plt.suptitle('Random Walk First-Passage: Arithmetic Thermodynamics',
                 fontsize=13, fontweight='bold')
    plt.tight_layout()
    plt.savefig('fig_random_walk.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Random walk analysis saved: fig_random_walk.png")


# ============================================================
# Application 3: Number-Theoretic Observable
# ============================================================

def number_theory_application():
    """
    Thermodynamics of number-theoretic stopping times:
    the number of steps of the Euclidean algorithm.
    """
    def gcd_steps(a: int, b: int) -> int:
        steps = 0
        while b > 0:
            a, b = b, a % b
            steps += 1
        return steps

    N = 500
    # τ(n) = number of steps in gcd(n, N)
    tau = np.array([gcd_steps(n, N) for n in range(1, N + 1)], dtype=float)
    w = np.ones(N)

    theta = np.linspace(-1, 3, 300)

    F_vals = []
    mean_vals = []
    var_vals = []
    for th in theta:
        exps = w * np.exp(-th * tau)
        Z = np.sum(exps)
        p = exps / Z
        mean = np.sum(p * tau)
        var = np.sum(p * tau**2) - mean**2
        F_vals.append(np.log(Z))
        mean_vals.append(mean)
        var_vals.append(var)

    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    axes[0].plot(theta, F_vals, 'b-', linewidth=2)
    axes[0].set_title('Free Energy: GCD Steps')
    axes[0].set_xlabel('θ')
    axes[0].grid(True, alpha=0.3)

    axes[1].plot(theta, mean_vals, 'r-', linewidth=2)
    axes[1].set_title('Gibbs Mean ⟨τ⟩_θ')
    axes[1].set_xlabel('θ')
    axes[1].grid(True, alpha=0.3)

    axes[2].plot(theta, var_vals, 'g-', linewidth=2)
    axes[2].axhline(y=0, color='k', alpha=0.3)
    axes[2].set_title('Gibbs Variance = Specific Heat ≥ 0')
    axes[2].set_xlabel('θ')
    axes[2].grid(True, alpha=0.3)

    plt.suptitle('Number-Theoretic Thermodynamics: Euclidean Algorithm Steps',
                 fontsize=13, fontweight='bold')
    plt.tight_layout()
    plt.savefig('fig_number_theory.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Number theory analysis saved: fig_number_theory.png")


if __name__ == "__main__":
    print("=" * 60)
    print("APPLICATIONS OF ARITHMETIC THERMODYNAMICS")
    print("=" * 60)

    hash_iteration_analysis()
    random_walk_application()
    number_theory_application()

    print("\n✓ All applications complete.")


#!/usr/bin/env python3
"""
Arithmetic Thermodynamics: Demonstrations and Numerical Experiments

This module demonstrates the core theorems of arithmetic thermodynamics:
1. Free energy convexity for finite partition functions
2. Derivative = negative Gibbs expectation
3. Second derivative = Gibbs variance (nonneg → convexity)
4. Two-phase limit → max of free energies
5. Complex partition zeros for two-level models
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from typing import Callable, List, Tuple

# ============================================================
# Core Definitions
# ============================================================

def partition_function(theta: np.ndarray, w: np.ndarray, tau: np.ndarray) -> np.ndarray:
    """Z(θ) = Σ_i w_i exp(-θ τ_i)"""
    return np.sum(w * np.exp(-np.outer(theta, tau)), axis=1)

def free_energy(theta: np.ndarray, w: np.ndarray, tau: np.ndarray) -> np.ndarray:
    """F(θ) = log Z(θ)"""
    return np.log(partition_function(theta, w, tau))

def gibbs_expectation(theta: np.ndarray, w: np.ndarray, tau: np.ndarray) -> np.ndarray:
    """⟨τ⟩_θ = Σ w_i τ_i exp(-θ τ_i) / Z(θ)"""
    Z = partition_function(theta, w, tau)
    num = np.sum(w * tau * np.exp(-np.outer(theta, tau)), axis=1)
    return num / Z

def gibbs_variance(theta: np.ndarray, w: np.ndarray, tau: np.ndarray) -> np.ndarray:
    """Var_θ(τ) = ⟨τ²⟩_θ - ⟨τ⟩_θ²"""
    Z = partition_function(theta, w, tau)
    exp_terms = np.exp(-np.outer(theta, tau))
    e_tau = np.sum(w * tau * exp_terms, axis=1) / Z
    e_tau2 = np.sum(w * tau**2 * exp_terms, axis=1) / Z
    return e_tau2 - e_tau**2


# ============================================================
# Demo 1: Free Energy Convexity and Variance Identity
# ============================================================

def demo_free_energy():
    """Demonstrate free energy convexity and F'' = Var(τ)."""
    # Collatz-inspired stopping times for first 20 integers
    def collatz_steps(n):
        count = 0
        while n != 1 and count < 100:
            n = n // 2 if n % 2 == 0 else 3 * n + 1
            count += 1
        return count

    N = 50
    tau = np.array([collatz_steps(n) for n in range(1, N + 1)], dtype=float)
    w = np.ones(N)

    theta = np.linspace(-0.5, 1.5, 500)
    F = free_energy(theta, w, tau)
    neg_gibbs = -gibbs_expectation(theta, w, tau)
    variance = gibbs_variance(theta, w, tau)

    # Numerical derivatives
    dtheta = theta[1] - theta[0]
    F_prime_num = np.gradient(F, dtheta)
    F_double_prime_num = np.gradient(F_prime_num, dtheta)

    fig, axes = plt.subplots(2, 2, figsize=(12, 10))

    # Plot 1: Free energy (convex curve)
    ax = axes[0, 0]
    ax.plot(theta, F, 'b-', linewidth=2)
    ax.set_xlabel('θ (inverse temperature)')
    ax.set_ylabel('F(θ) = log Z(θ)')
    ax.set_title('Free Energy (Convex)')
    ax.grid(True, alpha=0.3)

    # Plot 2: F' vs -⟨τ⟩
    ax = axes[0, 1]
    ax.plot(theta, F_prime_num, 'b-', linewidth=2, label="F'(θ) (numerical)")
    ax.plot(theta, neg_gibbs, 'r--', linewidth=2, label="-⟨τ⟩_θ (exact)")
    ax.set_xlabel('θ')
    ax.set_ylabel("F'(θ)")
    ax.set_title("First Derivative = Negative Gibbs Mean")
    ax.legend()
    ax.grid(True, alpha=0.3)

    # Plot 3: F'' vs Var(τ)
    ax = axes[1, 0]
    ax.plot(theta, F_double_prime_num, 'b-', linewidth=2, label="F''(θ) (numerical)")
    ax.plot(theta, variance, 'r--', linewidth=2, label="Var_θ(τ) (exact)")
    ax.axhline(y=0, color='k', linestyle='-', alpha=0.3)
    ax.set_xlabel('θ')
    ax.set_ylabel("F''(θ)")
    ax.set_title("Second Derivative = Gibbs Variance ≥ 0")
    ax.legend()
    ax.grid(True, alpha=0.3)

    # Plot 4: Convexity verification
    ax = axes[1, 1]
    # Check convexity: F(tθ1 + (1-t)θ2) ≤ tF(θ1) + (1-t)F(θ2)
    t_vals = np.linspace(0, 1, 100)
    th1, th2 = -0.3, 1.2
    F1 = free_energy(np.array([th1]), w, tau)[0]
    F2 = free_energy(np.array([th2]), w, tau)[0]
    midpoints = t_vals * th1 + (1 - t_vals) * th2
    F_mid = free_energy(midpoints, w, tau)
    F_lin = t_vals * F1 + (1 - t_vals) * F2

    ax.plot(midpoints, F_mid, 'b-', linewidth=2, label='F(tθ₁ + (1-t)θ₂)')
    ax.plot(midpoints, F_lin, 'r--', linewidth=2, label='tF(θ₁) + (1-t)F(θ₂)')
    ax.fill_between(midpoints, F_mid, F_lin, alpha=0.2, color='green')
    ax.set_xlabel('θ')
    ax.set_ylabel('F')
    ax.set_title('Convexity: F below chord')
    ax.legend()
    ax.grid(True, alpha=0.3)

    plt.suptitle('Arithmetic Thermodynamics: Collatz Stopping-Time Observable', fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('fig_free_energy.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Figure saved: fig_free_energy.png")


# ============================================================
# Demo 2: Two-Phase Limit and Phase Transition
# ============================================================

def demo_two_phase():
    """Demonstrate two-phase limit → max and phase transition."""
    theta = np.linspace(-2, 4, 500)

    # Two competing exponential sectors
    # A_N(θ) = exp(N * a(θ)), B_N(θ) = exp(N * b(θ))
    # with a(θ) = -θ + 1, b(θ) = -2θ + 3
    # Crossing at θ* = 2 where a(2) = -1 = b(2)
    # a'(2) = -1 ≠ -2 = b'(2) → phase transition

    a = lambda th: -th + 1
    b = lambda th: -2 * th + 3

    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    # Plot 1: Finite N approximations
    ax = axes[0]
    for N in [5, 20, 100, 500]:
        A_N = np.exp(N * a(theta))
        B_N = np.exp(N * b(theta))
        fN = (1 / N) * np.log(A_N + B_N)
        ax.plot(theta, fN, linewidth=1.5, label=f'N={N}')

    f_limit = np.maximum(a(theta), b(theta))
    ax.plot(theta, f_limit, 'k--', linewidth=2.5, label='max(a,b)')
    ax.axvline(x=2, color='red', linestyle=':', alpha=0.5)
    ax.set_xlabel('θ')
    ax.set_ylabel('(1/N) log Z_N(θ)')
    ax.set_title('Convergence to max(a,b)')
    ax.legend(fontsize=8)
    ax.grid(True, alpha=0.3)

    # Plot 2: Phase diagram
    ax = axes[1]
    ax.plot(theta, a(theta), 'b-', linewidth=2, label='a(θ) = -θ + 1')
    ax.plot(theta, b(theta), 'r-', linewidth=2, label='b(θ) = -2θ + 3')
    ax.plot(theta, f_limit, 'k-', linewidth=3, alpha=0.5, label='max(a,b)')
    ax.axvline(x=2, color='green', linestyle='--', alpha=0.7, label='θ* = 2 (transition)')
    ax.plot(2, -1, 'go', markersize=10, zorder=5)
    ax.fill_between(theta, a(theta), b(theta),
                     where=a(theta) > b(theta), alpha=0.1, color='blue', label='Phase A dominates')
    ax.fill_between(theta, a(theta), b(theta),
                     where=b(theta) > a(theta), alpha=0.1, color='red', label='Phase B dominates')
    ax.set_xlabel('θ')
    ax.set_ylabel('Free energy density')
    ax.set_title('Phase Coexistence')
    ax.legend(fontsize=7)
    ax.grid(True, alpha=0.3)

    # Plot 3: Non-differentiability at transition
    ax = axes[2]
    N = 200
    A_N = np.exp(N * a(theta))
    B_N = np.exp(N * b(theta))
    fN = (1 / N) * np.log(A_N + B_N)
    dfN = np.gradient(fN, theta[1] - theta[0])

    ax.plot(theta, dfN, 'b-', linewidth=2, label=f"(d/dθ)(1/N)log Z_N, N={N}")
    ax.axvline(x=2, color='red', linestyle=':', alpha=0.5)
    ax.axhline(y=-1, color='blue', linestyle='--', alpha=0.3, label="a'(θ) = -1")
    ax.axhline(y=-2, color='red', linestyle='--', alpha=0.3, label="b'(θ) = -2")
    ax.set_xlabel('θ')
    ax.set_ylabel('Derivative')
    ax.set_title('Slope Jump at Phase Transition')
    ax.legend(fontsize=8)
    ax.grid(True, alpha=0.3)

    plt.suptitle('Two-Phase Limit and First-Order Phase Transition', fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('fig_two_phase.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Figure saved: fig_two_phase.png")


# ============================================================
# Demo 3: Complex Partition Zeros (Yang-Lee)
# ============================================================

def demo_complex_zeros():
    """Demonstrate Yang-Lee zeros for two-level partition function."""
    # Z(z) = a exp(-α z) + b exp(-β z)
    # Zeros: exp((β-α)z) = -b/a
    a_val, b_val = 1.0, 2.0
    alpha, beta = 0.5, 1.5

    # -b/a = -2, so exp((β-α)z) = -2
    # (β-α)z = log(2) + iπ(2k+1), z = (log 2 + iπ(2k+1))/(β-α)
    delta = beta - alpha  # = 1.0
    zeros_real = np.log(b_val / a_val) / delta
    zeros_imag = [np.pi * (2 * k + 1) / delta for k in range(-5, 6)]

    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Plot 1: Zeros in complex plane
    ax = axes[0]
    for k, y in enumerate(zeros_imag):
        ax.plot(zeros_real, y, 'ro', markersize=8)
    ax.axhline(y=0, color='k', alpha=0.3)
    ax.axvline(x=0, color='k', alpha=0.3)
    ax.set_xlabel('Re(z)')
    ax.set_ylabel('Im(z)')
    ax.set_title(f'Yang-Lee Zeros: a={a_val}, b={b_val}, α={alpha}, β={beta}')
    ax.set_xlim(-1, 3)
    ax.grid(True, alpha=0.3)
    ax.set_aspect('equal')

    # Plot 2: |Z(z)| on a grid near the real axis
    ax = axes[1]
    x = np.linspace(-1, 3, 200)
    y = np.linspace(-4 * np.pi, 4 * np.pi, 200)
    X, Y = np.meshgrid(x, y)
    Z_complex = X + 1j * Y
    Z_val = np.abs(a_val * np.exp(-alpha * Z_complex) + b_val * np.exp(-beta * Z_complex))

    im = ax.contourf(X, Y, np.log10(Z_val + 1e-15), levels=30, cmap='viridis')
    plt.colorbar(im, ax=ax, label='log₁₀|Z(z)|')
    for y_zero in zeros_imag:
        ax.plot(zeros_real, y_zero, 'r+', markersize=12, markeredgewidth=2)
    ax.set_xlabel('Re(z)')
    ax.set_ylabel('Im(z)')
    ax.set_title('|Z(z)| with Zeros Marked')
    ax.grid(True, alpha=0.2)

    plt.suptitle('Complex Partition Function Zeros (Yang-Lee Theory)', fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('fig_complex_zeros.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Figure saved: fig_complex_zeros.png")


# ============================================================
# Demo 4: Collatz-specific thermodynamics
# ============================================================

def demo_collatz_thermo():
    """Thermodynamics of Collatz stopping times."""
    def collatz_steps(n):
        count = 0
        while n != 1 and count < 200:
            n = n // 2 if n % 2 == 0 else 3 * n + 1
            count += 1
        return count

    fig, axes = plt.subplots(2, 2, figsize=(12, 10))

    # Different system sizes
    sizes = [50, 200, 1000, 5000]
    theta = np.linspace(-0.1, 0.5, 300)

    for idx, N in enumerate(sizes):
        tau = np.array([collatz_steps(n) for n in range(1, N + 1)], dtype=float)
        w = np.ones(N)

        F = free_energy(theta, w, tau)
        var = gibbs_variance(theta, w, tau)

        ax = axes[idx // 2, idx % 2]
        ax2 = ax.twinx()
        l1 = ax.plot(theta, F, 'b-', linewidth=2, label='F(θ)')
        l2 = ax2.plot(theta, var, 'r-', linewidth=2, label='Var_θ(τ)')
        ax.set_xlabel('θ')
        ax.set_ylabel('F(θ)', color='b')
        ax2.set_ylabel('Var_θ(τ)', color='r')
        ax.set_title(f'N = {N}')
        ax.grid(True, alpha=0.3)

        lines = l1 + l2
        labels = [l.get_label() for l in lines]
        ax.legend(lines, labels, fontsize=8)

    plt.suptitle('Collatz Stopping-Time Thermodynamics: Scaling with System Size',
                 fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('fig_collatz_thermo.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Figure saved: fig_collatz_thermo.png")


# ============================================================
# Numerical verification table
# ============================================================

def print_verification_table():
    """Print numerical verification of the main identities."""
    np.random.seed(42)
    N = 10
    w = np.random.exponential(1, N)
    tau = np.random.randn(N) * 3

    theta0 = 0.5
    h = 1e-6

    Z = lambda th: np.sum(w * np.exp(-th * tau))
    F = lambda th: np.log(Z(th))

    Z0 = Z(theta0)
    F0 = F(theta0)

    # Numerical derivatives
    F_prime_num = (F(theta0 + h) - F(theta0 - h)) / (2 * h)
    F_double_prime_num = (F(theta0 + h) - 2 * F0 + F(theta0 - h)) / h**2

    # Analytical
    exp_terms = np.exp(-theta0 * tau)
    F_prime_exact = -np.sum(w * tau * exp_terms) / Z0
    e_tau = np.sum(w * tau * exp_terms) / Z0
    e_tau2 = np.sum(w * tau**2 * exp_terms) / Z0
    F_double_prime_exact = e_tau2 - e_tau**2

    print("\n" + "=" * 60)
    print("NUMERICAL VERIFICATION OF THERMODYNAMIC IDENTITIES")
    print("=" * 60)
    print(f"System: N={N} random weights and observables")
    print(f"θ₀ = {theta0}")
    print(f"\nPartition function Z(θ₀) = {Z0:.10f}")
    print(f"Free energy F(θ₀) = {F0:.10f}")
    print(f"\n{'Identity':<40} {'Numerical':<15} {'Exact':<15} {'Error':<12}")
    print("-" * 82)
    label1 = "F'(\u03b8) = -\u27e8\u03c4\u27e9_\u03b8"
    label2 = "F''(\u03b8) = Var_\u03b8(\u03c4)"
    label3 = "F''(\u03b8) \u2265 0"
    print(f"{label1:<40} {F_prime_num:<15.10f} {F_prime_exact:<15.10f} {abs(F_prime_num - F_prime_exact):<12.2e}")
    print(f"{label2:<40} {F_double_prime_num:<15.10f} {F_double_prime_exact:<15.10f} {abs(F_double_prime_num - F_double_prime_exact):<12.2e}")
    chk = '\u2713' if F_double_prime_exact >= 0 else '\u2717'
    print(f"{label3:<40} {chk}")
    print()


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print("=" * 60)
    print("ARITHMETIC THERMODYNAMICS: DEMONSTRATIONS")
    print("=" * 60)

    print_verification_table()
    demo_free_energy()
    demo_two_phase()
    demo_complex_zeros()
    demo_collatz_thermo()

    print("\n✓ All demonstrations complete.")
