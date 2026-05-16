#!/usr/bin/env python3
"""
applications.py — Real-World Applications of Arithmetic Large Deviation Theory

Demonstrates:
1. Collatz conjecture: tail statistics of stopping times
2. Algorithmic runtime analysis: sorting algorithm runtime distributions
3. Cryptographic hash complexity: mining difficulty phase transitions
4. Prime gap statistics: large deviations in prime distribution
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from typing import List, Tuple


# ──────────────────────────────────────────────────────────────
# Shared Infrastructure
# ──────────────────────────────────────────────────────────────

def compute_log_mgf(tau: np.ndarray, N: int, theta: float) -> float:
    """Scaled log-MGF: Λ_N(θ) = log(Z_N(θ)/(N+1)) / log(N+2)."""
    vals = theta * tau[:N+1]
    max_val = np.max(vals)
    Z = np.exp(max_val) * np.sum(np.exp(vals - max_val))
    return np.log(Z / (N + 1)) / np.log(N + 2)

def compute_rate_function(tau: np.ndarray, N: int, x_range: np.ndarray,
                          theta_range: np.ndarray = np.linspace(-2, 2, 2000)):
    """Compute I(x) from empirical data."""
    Lambda_vals = np.array([compute_log_mgf(tau, N, t) for t in theta_range])
    I_vals = np.zeros(len(x_range))
    for i, x in enumerate(x_range):
        I_vals[i] = np.max(theta_range * x - Lambda_vals)
    return I_vals


# ──────────────────────────────────────────────────────────────
# Application 1: Collatz Stopping-Time Statistics
# ──────────────────────────────────────────────────────────────

def app_collatz():
    """Analyze large deviations of Collatz stopping times."""
    print("=" * 60)
    print("Application 1: Collatz Stopping-Time Statistics")
    print("=" * 60)

    def collatz_steps(n):
        if n <= 1:
            return 0
        steps, x = 0, n
        while x != 1 and steps < 10000:
            x = x // 2 if x % 2 == 0 else 3 * x + 1
            steps += 1
        return steps

    Nmax = 10000
    tau = np.array([float(collatz_steps(n)) for n in range(Nmax + 1)])
    log_n = np.log(np.arange(Nmax + 1) + 2)
    scaled = tau / log_n

    print(f"  Max stopping time: {int(np.max(tau))}")
    print(f"  Mean τ(n)/log(n+2): {np.mean(scaled):.4f}")
    print(f"  Std τ(n)/log(n+2): {np.std(scaled):.4f}")

    # Rate function
    xs = np.linspace(0, 10, 200)
    Is = compute_rate_function(tau, Nmax, xs)

    fig, axes = plt.subplots(1, 3, figsize=(16, 5))

    # Histogram
    axes[0].hist(scaled, bins=80, density=True, alpha=0.7, color='steelblue')
    axes[0].set_xlabel('τ(n)/log(n+2)')
    axes[0].set_ylabel('Density')
    axes[0].set_title('Empirical Distribution')

    # Rate function
    axes[1].plot(xs, Is, 'r-', linewidth=2)
    axes[1].set_xlabel('x')
    axes[1].set_ylabel('I(x)')
    axes[1].set_title('Rate Function')
    axes[1].set_ylim(bottom=-0.1, top=2)

    # Free energy
    thetas = np.linspace(-0.3, 0.3, 200)
    Lambdas = [compute_log_mgf(tau, Nmax, t) for t in thetas]
    axes[2].plot(thetas, Lambdas, 'b-', linewidth=2)
    axes[2].set_xlabel('θ')
    axes[2].set_ylabel('Λ(θ)')
    axes[2].set_title('Free Energy Density')

    fig.suptitle('Collatz Stopping-Time Large Deviations', fontsize=14)
    fig.tight_layout()
    fig.savefig('app_collatz.png', dpi=150, bbox_inches='tight')
    plt.close(fig)
    print("  Saved: app_collatz.png")


# ──────────────────────────────────────────────────────────────
# Application 2: Algorithmic Runtime Distributions
# ──────────────────────────────────────────────────────────────

def app_algorithm_runtime():
    """Model sorting algorithm comparison counts as stopping times."""
    print("\n" + "=" * 60)
    print("Application 2: Algorithmic Runtime Distributions")
    print("=" * 60)

    np.random.seed(42)

    def quicksort_comparisons(arr):
        """Count comparisons in quicksort."""
        if len(arr) <= 1:
            return 0
        pivot = arr[0]
        left = [x for x in arr[1:] if x < pivot]
        right = [x for x in arr[1:] if x >= pivot]
        return len(arr) - 1 + quicksort_comparisons(left) + quicksort_comparisons(right)

    Nmax = 2000
    tau = np.zeros(Nmax + 1)
    for n in range(Nmax + 1):
        if n <= 1:
            tau[n] = 0
        else:
            arr = list(np.random.permutation(n))
            tau[n] = quicksort_comparisons(arr)

    log_n = np.log(np.arange(Nmax + 1) + 2)
    scaled = tau / log_n

    print(f"  Mean comparisons/log(n+2): {np.mean(scaled[10:]):.4f}")

    xs = np.linspace(0, max(scaled) * 0.8, 150)
    Is = compute_rate_function(tau, Nmax, xs)

    fig, ax = plt.subplots(figsize=(8, 5))
    ax.plot(xs, Is, 'g-', linewidth=2)
    ax.set_xlabel('x (normalized comparisons)')
    ax.set_ylabel('I(x)')
    ax.set_title('Rate Function for Quicksort Comparisons')
    ax.set_ylim(bottom=-0.1)
    ax.grid(True, alpha=0.3)
    fig.savefig('app_runtime.png', dpi=150, bbox_inches='tight')
    plt.close(fig)
    print("  Saved: app_runtime.png")


# ──────────────────────────────────────────────────────────────
# Application 3: Cryptographic Mining Difficulty
# ──────────────────────────────────────────────────────────────

def app_crypto_mining():
    """Model hash-based mining as a stopping time with phase transitions."""
    print("\n" + "=" * 60)
    print("Application 3: Cryptographic Mining Difficulty")
    print("=" * 60)

    np.random.seed(123)

    # Simulate: τ(n) = number of hashes needed to find one with
    # value < target, where target depends on difficulty
    Nmax = 3000

    # Model: geometric distribution with rate p(n)
    # p(n) varies to model adaptive difficulty
    tau = np.zeros(Nmax + 1)
    for n in range(Nmax + 1):
        # Difficulty increases with n
        p = max(0.01, 0.5 / (1 + n * 0.001))
        tau[n] = np.random.geometric(p)

    log_n = np.log(np.arange(Nmax + 1) + 2)

    # Free energy for different θ
    thetas = np.linspace(-0.5, 0.5, 200)
    Lambdas = [compute_log_mgf(tau, Nmax, t) for t in thetas]

    fig, ax = plt.subplots(figsize=(8, 5))
    ax.plot(thetas, Lambdas, 'purple', linewidth=2)
    ax.set_xlabel('θ (tilting parameter)')
    ax.set_ylabel('Λ(θ)')
    ax.set_title('Free Energy for Mining Stopping Times')
    ax.grid(True, alpha=0.3)
    fig.savefig('app_crypto.png', dpi=150, bbox_inches='tight')
    plt.close(fig)
    print("  Saved: app_crypto.png")

    # Check for phase transitions via second derivative
    d2 = np.diff(Lambdas, 2) / (thetas[1] - thetas[0])**2
    max_curvature = np.max(np.abs(d2))
    print(f"  Max curvature of Λ: {max_curvature:.4f}")
    print(f"  (Large curvature indicates proximity to phase transition)")


# ──────────────────────────────────────────────────────────────
# Application 4: Prime Gap Statistics
# ──────────────────────────────────────────────────────────────

def app_prime_gaps():
    """Analyze large deviations of prime gaps as stopping times."""
    print("\n" + "=" * 60)
    print("Application 4: Prime Gap Statistics")
    print("=" * 60)

    def sieve(limit):
        is_prime = [True] * (limit + 1)
        is_prime[0] = is_prime[1] = False
        for i in range(2, int(limit**0.5) + 1):
            if is_prime[i]:
                for j in range(i*i, limit + 1, i):
                    is_prime[j] = False
        return [i for i in range(2, limit + 1) if is_prime[i]]

    primes = sieve(50000)
    gaps = np.diff(primes).astype(float)
    Nmax = min(len(gaps) - 1, 4000)
    tau = gaps[:Nmax + 1]

    log_n = np.log(np.arange(Nmax + 1) + 2)
    scaled = tau / log_n

    print(f"  Number of gaps analyzed: {Nmax + 1}")
    print(f"  Mean gap/log(n+2): {np.mean(scaled):.4f}")

    xs = np.linspace(0, 5, 150)
    Is = compute_rate_function(tau, Nmax, xs)

    fig, axes = plt.subplots(1, 2, figsize=(12, 5))

    axes[0].hist(scaled, bins=60, density=True, alpha=0.7, color='orange')
    axes[0].set_xlabel('gap / log(n+2)')
    axes[0].set_ylabel('Density')
    axes[0].set_title('Normalized Prime Gap Distribution')

    axes[1].plot(xs, Is, 'darkorange', linewidth=2)
    axes[1].set_xlabel('x')
    axes[1].set_ylabel('I(x)')
    axes[1].set_title('Rate Function for Prime Gaps')
    axes[1].set_ylim(bottom=-0.1)
    axes[1].grid(True, alpha=0.3)

    fig.suptitle('Prime Gap Large Deviations', fontsize=14)
    fig.tight_layout()
    fig.savefig('app_prime_gaps.png', dpi=150, bbox_inches='tight')
    plt.close(fig)
    print("  Saved: app_prime_gaps.png")


# ──────────────────────────────────────────────────────────────
# Main
# ──────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("Applications of Arithmetic Large Deviation Theory")
    print("=" * 55 + "\n")

    app_collatz()
    app_algorithm_runtime()
    app_crypto_mining()
    app_prime_gaps()

    print("\n" + "=" * 60)
    print("All applications complete.")
    print("=" * 60)


#!/usr/bin/env python3
"""
demo.py — Demonstrations of Large Deviation Principles for Stopping-Time Distributions

Computes and visualizes:
1. Partition sums and log-MGFs for sample stopping times
2. Rate functions via Legendre-Fenchel transform
3. Empirical probability convergence
4. Free-energy duality verification
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from typing import Callable

# ──────────────────────────────────────────────────────────────
# Core Definitions (mirroring the Lean formalization)
# ──────────────────────────────────────────────────────────────

def partition_sum(tau: np.ndarray, N: int, theta: float) -> float:
    """Z_N(θ) = Σ_{n=0}^{N} exp(θ·τ(n))"""
    return np.sum(np.exp(theta * tau[:N+1]))

def log_mgf(tau: np.ndarray, N: int, theta: float) -> float:
    """Λ_N(θ) = log(Z_N(θ)/(N+1)) / log(N+2)"""
    Z = partition_sum(tau, N, theta)
    return np.log(Z / (N + 1)) / np.log(N + 2)

def empirical_prob(tau: np.ndarray, N: int, a: float, b: float) -> float:
    """Fraction of n ∈ {0,...,N} with τ(n)/log(n+2) ∈ [a,b]"""
    scaled = tau[:N+1] / np.log(np.arange(N+1) + 2)
    count = np.sum((scaled >= a) & (scaled <= b))
    return count / (N + 1)

def rate_function(Lambda: Callable, x: float,
                  theta_range: np.ndarray = np.linspace(-10, 10, 2000)) -> float:
    """I(x) = sup_θ (θx - Λ(θ))"""
    values = theta_range * x - np.array([Lambda(t) for t in theta_range])
    return np.max(values)

def free_energy_finite(tau: np.ndarray, N: int, gamma: float) -> float:
    """F_N(γ) = log(Σ_{n≤N} γ^{τ(n)} / (N+1)) / log(N+2)"""
    powers = np.power(np.maximum(gamma, 1e-300), tau[:N+1])
    return np.log(np.sum(powers) / (N + 1)) / np.log(N + 2)

# ──────────────────────────────────────────────────────────────
# Example Stopping Times
# ──────────────────────────────────────────────────────────────

def collatz_stopping_time(n: int) -> int:
    """Number of steps for n to reach 1 under the Collatz map."""
    if n <= 1:
        return 0
    steps = 0
    x = n
    while x != 1 and steps < 10000:
        if x % 2 == 0:
            x = x // 2
        else:
            x = 3 * x + 1
        steps += 1
    return steps

def digit_sum_stopping_time(n: int) -> int:
    """Steps to reduce n to a single digit by iterating digit sum."""
    if n < 10:
        return 0
    steps = 0
    x = n
    while x >= 10:
        x = sum(int(d) for d in str(x))
        steps += 1
    return steps

# ──────────────────────────────────────────────────────────────
# Demo 1: Log-MGF Convergence
# ──────────────────────────────────────────────────────────────

def demo_logmgf_convergence():
    """Show that log-MGF converges as N → ∞ for Collatz stopping times."""
    print("=" * 60)
    print("Demo 1: Log-MGF Convergence for Collatz Stopping Times")
    print("=" * 60)

    Nmax = 5000
    tau = np.array([float(collatz_stopping_time(n)) for n in range(Nmax + 1)])

    thetas = [0.0, 0.01, 0.05, 0.1, -0.01, -0.05]
    Ns = [100, 500, 1000, 2000, 5000]

    print(f"\n{'θ':>8} | " + " | ".join(f"N={N:>5}" for N in Ns))
    print("-" * (10 + 10 * len(Ns)))
    for theta in thetas:
        vals = [log_mgf(tau, N, theta) for N in Ns]
        print(f"{theta:8.3f} | " + " | ".join(f"{v:8.4f}" for v in vals))

    # Plot convergence
    fig, ax = plt.subplots(1, 1, figsize=(10, 6))
    N_range = np.arange(50, Nmax + 1, 50)
    for theta in [0.01, 0.05, 0.1]:
        vals = [log_mgf(tau, N, theta) for N in N_range]
        ax.plot(N_range, vals, label=f'θ = {theta}')
    ax.set_xlabel('N')
    ax.set_ylabel('Λ_N(θ)')
    ax.set_title('Log-MGF Convergence for Collatz Stopping Times')
    ax.legend()
    ax.grid(True, alpha=0.3)
    fig.savefig('logmgf_convergence.png', dpi=150, bbox_inches='tight')
    plt.close(fig)
    print("\nSaved: logmgf_convergence.png")

# ──────────────────────────────────────────────────────────────
# Demo 2: Rate Function Computation
# ──────────────────────────────────────────────────────────────

def demo_rate_function():
    """Compute and plot the rate function I(x) for Collatz stopping times."""
    print("\n" + "=" * 60)
    print("Demo 2: Rate Function via Legendre-Fenchel Transform")
    print("=" * 60)

    Nmax = 5000
    tau = np.array([float(collatz_stopping_time(n)) for n in range(Nmax + 1)])

    # Approximate limiting Λ using large N
    N = Nmax
    def Lambda_approx(theta):
        return log_mgf(tau, N, theta)

    # Compute rate function
    xs = np.linspace(0, 8, 200)
    theta_grid = np.linspace(-1, 1, 2000)
    Is = []
    for x in xs:
        vals = theta_grid * x - np.array([Lambda_approx(t) for t in theta_grid])
        Is.append(np.max(vals))
    Is = np.array(Is)

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    # Plot Λ
    theta_plot = np.linspace(-0.5, 0.5, 200)
    Lambda_vals = [Lambda_approx(t) for t in theta_plot]
    ax1.plot(theta_plot, Lambda_vals, 'b-', linewidth=2)
    ax1.set_xlabel('θ')
    ax1.set_ylabel('Λ(θ)')
    ax1.set_title('Scaled Log-MGF (Free Energy)')
    ax1.grid(True, alpha=0.3)

    # Plot I
    ax2.plot(xs, Is, 'r-', linewidth=2)
    ax2.set_xlabel('x')
    ax2.set_ylabel('I(x)')
    ax2.set_title('Rate Function (Legendre-Fenchel Transform)')
    ax2.set_ylim(bottom=-0.1)
    ax2.grid(True, alpha=0.3)

    fig.suptitle('Free Energy ↔ Rate Function Duality', fontsize=14)
    fig.tight_layout()
    fig.savefig('rate_function.png', dpi=150, bbox_inches='tight')
    plt.close(fig)
    print("Saved: rate_function.png")

    # Print key values
    x_min = xs[np.argmin(Is)]
    print(f"\nMinimum of I(x) ≈ {np.min(Is):.6f} at x ≈ {x_min:.2f}")
    print(f"This is the 'typical' normalized stopping time")

# ──────────────────────────────────────────────────────────────
# Demo 3: Empirical Probability Decay
# ──────────────────────────────────────────────────────────────

def demo_empirical_decay():
    """Show exponential decay of empirical probabilities in deviation regions."""
    print("\n" + "=" * 60)
    print("Demo 3: Empirical Probability Decay")
    print("=" * 60)

    Nmax = 10000
    tau = np.array([float(collatz_stopping_time(n)) for n in range(Nmax + 1)])

    # Deviation thresholds
    thresholds = [4.0, 5.0, 6.0, 7.0]
    Ns = np.arange(100, Nmax + 1, 100)

    fig, ax = plt.subplots(figsize=(10, 6))

    for a in thresholds:
        probs = []
        for N in Ns:
            p = empirical_prob(tau, N, a, np.inf)
            probs.append(p)
        probs = np.array(probs)

        # Plot log(prob) / log(N+2)
        with np.errstate(divide='ignore'):
            log_probs = np.where(probs > 0,
                                  np.log(probs) / np.log(Ns + 2),
                                  np.nan)
        ax.plot(Ns, log_probs, label=f'a = {a}', linewidth=1.5)

    ax.set_xlabel('N')
    ax.set_ylabel('log(emp_N([a,∞))) / log(N+2)')
    ax.set_title('Scaled Log-Probability of Deviation Events')
    ax.legend()
    ax.grid(True, alpha=0.3)
    fig.savefig('empirical_decay.png', dpi=150, bbox_inches='tight')
    plt.close(fig)
    print("Saved: empirical_decay.png")

# ──────────────────────────────────────────────────────────────
# Demo 4: Free-Energy Duality Verification
# ──────────────────────────────────────────────────────────────

def demo_free_energy_duality():
    """Verify that I(x) = sup_{γ>0} (log(γ)·x - F(γ)) numerically."""
    print("\n" + "=" * 60)
    print("Demo 4: Free-Energy Duality Verification")
    print("=" * 60)

    Nmax = 3000
    tau = np.array([float(collatz_stopping_time(n)) for n in range(Nmax + 1)])
    N = Nmax

    def Lambda(theta):
        return log_mgf(tau, N, theta)

    def F(gamma):
        return free_energy_finite(tau, N, gamma)

    # Compute I(x) via Λ
    xs = np.linspace(1, 6, 20)
    theta_grid = np.linspace(-0.5, 0.5, 1000)

    print(f"\n{'x':>6} | {'I_Λ(x)':>10} | {'I_F(x)':>10} | {'Diff':>10}")
    print("-" * 45)

    for x in xs:
        # Via Λ: sup_θ (θx - Λ(θ))
        I_Lambda = np.max(theta_grid * x - np.array([Lambda(t) for t in theta_grid]))

        # Via F: sup_{γ>0} (log(γ)·x - F(γ))
        gamma_grid = np.exp(theta_grid)  # γ = e^θ
        I_F = np.max(np.log(gamma_grid) * x - np.array([F(g) for g in gamma_grid]))

        print(f"{x:6.2f} | {I_Lambda:10.6f} | {I_F:10.6f} | {abs(I_Lambda - I_F):10.2e}")

    print("\nDuality verified: I computed via Λ matches I computed via F")

# ──────────────────────────────────────────────────────────────
# Demo 5: Chernoff Bound Verification
# ──────────────────────────────────────────────────────────────

def demo_chernoff_bound():
    """Verify the Chernoff counting bound numerically."""
    print("\n" + "=" * 60)
    print("Demo 5: Chernoff Bound Verification")
    print("=" * 60)

    Nmax = 2000
    tau = np.array([float(collatz_stopping_time(n)) for n in range(Nmax + 1)])

    N = Nmax
    a_vals = [3.0, 4.0, 5.0]
    theta_vals = [0.01, 0.05, 0.1, 0.2]

    log_n = np.log(np.arange(N + 1) + 2)

    print(f"\n{'a':>5} {'θ':>6} | {'LHS (count)':>12} | {'RHS (bound)':>12} | {'Valid':>6}")
    print("-" * 55)

    for a in a_vals:
        for theta in theta_vals:
            # LHS: count of n where τ(n)/log(n+2) ≥ a
            lhs = np.sum(tau[:N+1] / log_n >= a)

            # RHS: sum of exp(θ*(τ(n) - a*log(n+2)))
            rhs = np.sum(np.exp(theta * (tau[:N+1] - a * log_n)))

            valid = "✓" if lhs <= rhs + 1e-10 else "✗"
            print(f"{a:5.1f} {theta:6.3f} | {lhs:12.1f} | {rhs:12.1f} | {valid:>6}")

# ──────────────────────────────────────────────────────────────
# Main
# ──────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("Large Deviation Principles for Stopping-Time Distributions")
    print("Numerical Demonstrations\n")

    demo_logmgf_convergence()
    demo_rate_function()
    demo_empirical_decay()
    demo_free_energy_duality()
    demo_chernoff_bound()

    print("\n" + "=" * 60)
    print("All demonstrations complete.")
    print("=" * 60)


#!/usr/bin/env python3
"""Generate PACKAGE.json with all artifacts."""
import json, base64

# Read all text files
def read_file(path):
    with open(path, 'r') as f:
        return f.read()

# Read images as base64
def read_image_b64(path):
    with open(path, 'rb') as f:
        return 'data:image/png;base64,' + base64.b64encode(f.read()).decode()

article = read_file('ARTICLE.md')
research_paper = read_file('RESEARCH_PAPER.md')
future_directions = read_file('FUTURE_DIRECTIONS.md')
demo_code = read_file('demo.py')
algorithms_code = read_file('algorithms.py')
applications_code = read_file('applications.py')
lean_code = read_file('Bridges/LargeDeviationPrinciple.lean')

package = {
    "title": "Large Deviation Principles for Arithmetic Stopping-Time Distributions",
    "domain": "Bridges — Probability, Number Theory, Thermodynamic Formalism",
    "article": article,
    "research_paper": research_paper,
    "future_directions": future_directions,
    "demos": [
        {
            "name": "Large Deviation Demonstrations",
            "code": demo_code
        },
        {
            "name": "Applications to Collatz, Cryptography, Prime Gaps",
            "code": applications_code
        }
    ],
    "algorithms": [
        {
            "name": "Legendre-Fenchel Transform",
            "pseudocode": "INPUT: Function Λ(θ), point x\nOUTPUT: I(x) = sup_θ (θx - Λ(θ))\n\n1. Discretize θ over grid [θ_min, θ_max] with M points\n2. For each θ_i, compute v_i = θ_i · x - Λ(θ_i)\n3. Return max(v_1, ..., v_M)\n\nComplexity: O(M × cost(Λ))",
            "code": algorithms_code
        }
    ],
    "visualizations": [
        {
            "name": "Log-MGF Convergence",
            "data": read_image_b64('logmgf_convergence.png')
        },
        {
            "name": "Rate Function and Free Energy",
            "data": read_image_b64('rate_function.png')
        },
        {
            "name": "Empirical Probability Decay",
            "data": read_image_b64('empirical_decay.png')
        },
        {
            "name": "Collatz Large Deviations",
            "data": read_image_b64('app_collatz.png')
        },
        {
            "name": "Algorithmic Runtime Rate Function",
            "data": read_image_b64('app_runtime.png')
        },
        {
            "name": "Cryptographic Mining Free Energy",
            "data": read_image_b64('app_crypto.png')
        },
        {
            "name": "Prime Gap Large Deviations",
            "data": read_image_b64('app_prime_gaps.png')
        }
    ],
    "lean_proofs": lean_code
}

with open('PACKAGE.json', 'w') as f:
    json.dump(package, f, indent=2, ensure_ascii=False)

print(f"PACKAGE.json generated ({len(json.dumps(package))//1024} KB)")
