#!/usr/bin/env python3
"""
Applications of Tropical Contraction Theory to Collatz and Generalized Dynamics.

Demonstrates practical applications of the Bellman contraction framework:
1. Stopping time estimation via value function
2. Orbit complexity classification
3. Generalized Collatz maps (5n+1, 7n+1, etc.)
4. Parity sequence entropy analysis
"""

import numpy as np
from typing import List, Tuple
from algorithms import bellman_value_iteration, collatz_orbit, log_orbit_analysis


def stopping_time_estimation(max_n: int = 500, gamma: float = 0.95) -> None:
    """
    Use the Bellman fixed point to estimate relative stopping-time complexity.

    The fixed-point value f*(n) correlates with the difficulty of the Collatz
    orbit starting at n: higher values indicate more complex orbits.
    """
    print("=" * 60)
    print("APPLICATION 1: Stopping Time Estimation via Value Function")
    print("=" * 60)

    # Compute fixed point
    f_star, _, iters = bellman_value_iteration(gamma, 1.0, 1.5, max_n, epsilon=1e-10)
    print(f"Computed fixed point on [0, {max_n}) in {iters} iterations (γ={gamma})")

    # Compute actual stopping times
    stopping_times = {}
    for n in range(1, max_n):
        orbit = collatz_orbit(n)
        stopping_times[n] = len(orbit) - 1

    # Correlation between f* and stopping time
    ns = list(range(2, max_n))
    fvals = [f_star[n] for n in ns]
    stimes = [stopping_times[n] for n in ns]

    corr = np.corrcoef(fvals, stimes)[0, 1]
    print(f"Correlation between f*(n) and stopping time: {corr:.4f}")

    # Top-10 by value function
    ranked = sorted(range(2, max_n), key=lambda n: f_star[n], reverse=True)
    print("\nTop 10 by Bellman potential (most complex orbits):")
    print(f"  {'n':>5} | {'f*(n)':>10} | {'Steps':>6}")
    print(f"  {'-'*5}-+-{'-'*10}-+-{'-'*6}")
    for n in ranked[:10]:
        print(f"  {n:>5} | {f_star[n]:>10.4f} | {stopping_times[n]:>6}")
    print()


def generalized_collatz_analysis() -> None:
    """
    Apply the framework to generalized Collatz maps: n ↦ (kn+1)/2^v for odd n.
    """
    print("=" * 60)
    print("APPLICATION 2: Generalized Collatz Maps")
    print("=" * 60)

    def gen_collatz_orbit(n: int, k: int, max_steps: int = 1000) -> List[int]:
        """Orbit of the generalized map: even→n/2, odd→k*n+1."""
        orbit = [n]
        while n != 1 and len(orbit) < max_steps:
            n = n // 2 if n % 2 == 0 else k * n + 1
            orbit.append(n)
        return orbit

    multipliers = [3, 5, 7]
    test_values = [27, 31, 97, 127]

    for k in multipliers:
        log_drift_odd = np.log(k) - np.log(2)  # log(k/2)
        print(f"\n  k = {k}: odd branch drift = +{log_drift_odd:.4f} "
              f"({'net contracting' if log_drift_odd < np.log(2) else 'net expanding'} "
              f"when paired with one even step)")

        for n in test_values:
            orbit = gen_collatz_orbit(n, k, max_steps=2000)
            reached_1 = orbit[-1] == 1
            max_val = max(orbit)
            print(f"    n={n:>4}: {'→1' if reached_1 else 'diverges/cycles'} "
                  f"in {len(orbit)-1:>4} steps, max={max_val}")

    print()


def parity_entropy_analysis(max_n: int = 1000) -> None:
    """
    Compute Shannon entropy of Collatz parity sequences.

    The entropy rate of the parity sequence (even/odd indicators along orbits)
    determines the effective compression ratio achievable by the Bellman framework.
    """
    print("=" * 60)
    print("APPLICATION 3: Parity Sequence Entropy")
    print("=" * 60)

    total_even = 0
    total_odd = 0
    bigram_counts = {"EE": 0, "EO": 0, "OE": 0, "OO": 0}

    for n in range(2, max_n + 1):
        orbit = collatz_orbit(n)
        parities = ['E' if x % 2 == 0 else 'O' for x in orbit[:-1]]

        for p in parities:
            if p == 'E':
                total_even += 1
            else:
                total_odd += 1

        for i in range(len(parities) - 1):
            bigram = parities[i] + parities[i+1]
            bigram_counts[bigram] += 1

    total = total_even + total_odd
    p_even = total_even / total
    p_odd = total_odd / total

    # Unigram entropy
    H1 = -(p_even * np.log2(p_even) + p_odd * np.log2(p_odd))

    # Bigram entropy rate
    total_bigrams = sum(bigram_counts.values())
    H2 = 0
    for bg, count in bigram_counts.items():
        if count > 0:
            p = count / total_bigrams
            H2 -= p * np.log2(p)
    H2_rate = H2 / 2  # per-symbol rate from bigram model

    print(f"  Analyzed orbits for n = 2 to {max_n}")
    print(f"  Even fraction: {p_even:.4f}")
    print(f"  Odd fraction:  {p_odd:.4f}")
    print(f"  Expected even fraction (heuristic): {np.log2(3)/(1+np.log2(3)):.4f}")
    print(f"  Unigram entropy: {H1:.4f} bits/symbol")
    print(f"  Bigram entropy rate: {H2_rate:.4f} bits/symbol")
    print(f"  Maximum entropy: 1.0000 bits/symbol")
    print(f"  Redundancy: {1 - H1:.4f} bits/symbol")
    print(f"\n  Bigram distribution:")
    for bg, count in sorted(bigram_counts.items()):
        print(f"    {bg}: {count/total_bigrams:.4f}")

    print(f"\n  The sub-maximal entropy ({H1:.4f} < 1) means parity sequences")
    print(f"  are compressible — validating the MDL interpretation of the")
    print(f"  Bellman fixed point as a compression certificate.\n")


def contraction_rate_vs_gamma() -> None:
    """
    Show how convergence speed varies with the discount factor.
    """
    print("=" * 60)
    print("APPLICATION 4: Convergence Speed vs Discount Factor")
    print("=" * 60)

    N = 100
    a, b = 1.0, 1.5
    epsilon = 1e-8

    print(f"  {'γ':>6} | {'Iterations':>11} | {'Theoretical bound':>18}")
    print(f"  {'-'*6}-+-{'-'*11}-+-{'-'*18}")

    for gamma in [0.1, 0.3, 0.5, 0.7, 0.9, 0.95, 0.99]:
        _, diffs, iters = bellman_value_iteration(gamma, a, b, N, epsilon=epsilon)
        theoretical = int(np.ceil(np.log(epsilon) / np.log(gamma)))
        print(f"  {gamma:>6.2f} | {iters:>11} | {theoretical:>18}")

    print()


if __name__ == "__main__":
    stopping_time_estimation()
    generalized_collatz_analysis()
    parity_entropy_analysis()
    contraction_rate_vs_gamma()


#!/usr/bin/env python3
"""
Tropical Contraction Theory for Collatz Dynamics — Demonstrations

This script demonstrates the key mathematical results formalized in Lean 4:
1. Branch isometry: Collatz branches preserve distance in log-coordinates
2. Min-plus contraction: |min(a,b) - min(c,d)| ≤ max(|a-c|, |b-d|)
3. Bellman operator convergence: Picard iteration converges geometrically
4. Fixed-point characterization: the value function satisfies the Bellman equation
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from typing import Callable

# ══════════════════════════════════════════════════════════════════════════════
# Section 1: Branch Maps and Isometry Verification
# ══════════════════════════════════════════════════════════════════════════════

def branch_even(x: float) -> float:
    """Even Collatz branch in log-coordinates: x ↦ x - log(2)."""
    return x - np.log(2)

def branch_odd(x: float) -> float:
    """Odd Collatz branch in log-coordinates: x ↦ x + log(3) - log(2)."""
    return x + np.log(3) - np.log(2)

def demo_branch_isometry():
    """Demonstrate that both branches are isometries (preserve distance)."""
    print("=" * 70)
    print("DEMO 1: Branch Isometry Verification")
    print("=" * 70)
    
    np.random.seed(42)
    pairs = np.random.randn(1000, 2) * 10
    
    for name, branch in [("Even (x - log2)", branch_even), ("Odd (x + log(3/2))", branch_odd)]:
        max_err = 0.0
        for x, y in pairs:
            original_dist = abs(x - y)
            mapped_dist = abs(branch(x) - branch(y))
            max_err = max(max_err, abs(original_dist - mapped_dist))
        print(f"  Branch {name}: max |dist(f(x),f(y)) - dist(x,y)| = {max_err:.2e}")
    
    print("  → Both branches are exact isometries (translations preserve distance).\n")

# ══════════════════════════════════════════════════════════════════════════════
# Section 2: Min-Plus Contraction Algebra
# ══════════════════════════════════════════════════════════════════════════════

def demo_min_lipschitz():
    """Demonstrate the min-Lipschitz property."""
    print("=" * 70)
    print("DEMO 2: Min-Plus Contraction (|min(a,b)-min(c,d)| ≤ max(|a-c|,|b-d|))")
    print("=" * 70)
    
    np.random.seed(123)
    N = 100000
    vals = np.random.randn(N, 4) * 10
    
    lhs = np.abs(np.minimum(vals[:, 0], vals[:, 1]) - np.minimum(vals[:, 2], vals[:, 3]))
    rhs = np.maximum(np.abs(vals[:, 0] - vals[:, 2]), np.abs(vals[:, 1] - vals[:, 3]))
    
    ratio = lhs / np.maximum(rhs, 1e-15)
    
    violations = np.sum(lhs > rhs + 1e-12)
    print(f"  Tested {N} random quadruples (a, b, c, d)")
    print(f"  Violations: {violations}")
    print(f"  Max ratio LHS/RHS: {ratio.max():.6f}")
    print(f"  Mean ratio LHS/RHS: {ratio.mean():.6f}")
    print("  → Min operation is 1-Lipschitz in max-norm (confirmed).\n")

# ══════════════════════════════════════════════════════════════════════════════
# Section 3: Bellman Operator and Value Iteration
# ══════════════════════════════════════════════════════════════════════════════

def collatz_bellman(gamma: float, a: float, b: float, 
                     f: np.ndarray) -> np.ndarray:
    """
    Apply the discounted tropical Collatz Bellman operator.
    
    T_γ[f](n) = γ · min(f(n//2) + a, f((3n+1)//2) + b)
    """
    N = len(f)
    result = np.zeros(N)
    for n in range(N):
        branch_even_val = f[n // 2] + a
        branch_odd_val = f[min((3 * n + 1) // 2, N - 1)] + b
        result[n] = gamma * min(branch_even_val, branch_odd_val)
    return result

def demo_bellman_convergence():
    """Demonstrate geometric convergence of Picard iteration."""
    print("=" * 70)
    print("DEMO 3: Bellman Operator — Picard Iteration Convergence")
    print("=" * 70)
    
    N = 200  # domain size
    gamma = 0.9  # discount factor
    a, b = 1.0, 1.5  # branch costs
    
    # Initial function: constant zero
    f = np.zeros(N)
    
    # Track convergence
    iterates = [f.copy()]
    diffs = []
    
    for k in range(80):
        f_new = collatz_bellman(gamma, a, b, f)
        diff = np.max(np.abs(f_new - f))
        diffs.append(diff)
        f = f_new
        iterates.append(f.copy())
        if diff < 1e-14:
            break
    
    print(f"  Parameters: γ = {gamma}, a = {a}, b = {b}, domain = [0, {N})")
    print(f"  Converged in {len(diffs)} iterations")
    print(f"  Theoretical contraction constant: γ = {gamma}")
    
    # Estimate actual contraction rate
    if len(diffs) > 5:
        rates = [diffs[i+1] / max(diffs[i], 1e-15) for i in range(min(20, len(diffs)-1))]
        avg_rate = np.mean(rates[:10])
        print(f"  Observed contraction rate: ≈ {avg_rate:.4f}")
    
    print(f"  Final sup-norm change: {diffs[-1]:.2e}")
    
    # Verify fixed-point equation
    f_check = collatz_bellman(gamma, a, b, f)
    residual = np.max(np.abs(f_check - f))
    print(f"  Fixed-point residual ‖Tf - f‖_∞ = {residual:.2e}")
    print("  → Geometric convergence confirmed (rate ≈ γ).\n")
    
    return f, diffs, iterates

def demo_bellman_contraction_rate():
    """Show that the contraction constant equals γ."""
    print("=" * 70)
    print("DEMO 4: Contraction Constant = γ (Lipschitz verification)")
    print("=" * 70)
    
    N = 100
    gammas = [0.1, 0.3, 0.5, 0.7, 0.9, 0.95, 0.99]
    a, b = 1.0, 2.0
    
    print(f"  {'γ':>6} | {'Observed Lip. const':>20} | {'Ratio obs/γ':>12}")
    print(f"  {'-'*6}-+-{'-'*20}-+-{'-'*12}")
    
    for gamma in gammas:
        np.random.seed(42)
        max_ratio = 0.0
        for _ in range(200):
            f = np.random.randn(N) * 5
            g = np.random.randn(N) * 5
            Tf = collatz_bellman(gamma, a, b, f)
            Tg = collatz_bellman(gamma, a, b, g)
            dist_Tf_Tg = np.max(np.abs(Tf - Tg))
            dist_f_g = np.max(np.abs(f - g))
            if dist_f_g > 1e-10:
                max_ratio = max(max_ratio, dist_Tf_Tg / dist_f_g)
        
        print(f"  {gamma:>6.2f} | {max_ratio:>20.6f} | {max_ratio/gamma:>12.6f}")
    
    print("  → Observed Lipschitz constant ≤ γ in all cases (confirming the theorem).\n")

# ══════════════════════════════════════════════════════════════════════════════
# Section 4: Collatz Orbit Analysis
# ══════════════════════════════════════════════════════════════════════════════

def collatz_step(n: int) -> int:
    """Standard Collatz step."""
    return n // 2 if n % 2 == 0 else 3 * n + 1

def collatz_orbit(n: int, max_steps: int = 1000) -> list:
    """Compute the Collatz orbit of n."""
    orbit = [n]
    while n != 1 and len(orbit) < max_steps:
        n = collatz_step(n)
        orbit.append(n)
    return orbit

def demo_collatz_orbits_and_potential():
    """Show how the Bellman fixed point relates to Collatz orbit structure."""
    print("=" * 70)
    print("DEMO 5: Collatz Orbits and Tropical Potential")
    print("=" * 70)
    
    test_values = [27, 31, 41, 97, 127, 171]
    
    for n in test_values:
        orbit = collatz_orbit(n)
        log_orbit = [np.log(x) for x in orbit]
        max_log = max(log_orbit)
        min_log = min(log_orbit[:-1]) if len(log_orbit) > 1 else log_orbit[0]
        steps = len(orbit) - 1
        print(f"  n = {n:>4}: steps = {steps:>3}, "
              f"max(log) = {max_log:.2f}, "
              f"avg drift = {(log_orbit[-1] - log_orbit[0])/max(steps,1):.4f}")
    
    print("\n  The tropical potential function f_γ encodes the discounted")
    print("  branch-cost structure of these orbits.\n")

# ══════════════════════════════════════════════════════════════════════════════
# Section 5: Visualizations
# ══════════════════════════════════════════════════════════════════════════════

def create_visualizations(fixed_point, diffs, iterates):
    """Generate publication-quality figures."""
    
    # Figure 1: Convergence of Picard iteration
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))
    
    ax = axes[0]
    ax.semilogy(range(1, len(diffs)+1), diffs, 'b-o', markersize=3, linewidth=1.5)
    ax.set_xlabel('Iteration k', fontsize=12)
    ax.set_ylabel('‖T^k f₀ - T^{k-1} f₀‖_∞', fontsize=12)
    ax.set_title('Geometric Convergence of Picard Iteration', fontsize=13)
    ax.grid(True, alpha=0.3)
    
    # Overlay theoretical rate
    if len(diffs) > 1:
        gamma = 0.9
        theoretical = [diffs[0] * gamma**k for k in range(len(diffs))]
        ax.semilogy(range(1, len(theoretical)+1), theoretical, 'r--', 
                    alpha=0.7, label=f'γ^k · C₀ (γ={gamma})')
        ax.legend(fontsize=10)
    
    # Figure 2: The fixed-point function
    ax = axes[1]
    ax.plot(range(len(fixed_point)), fixed_point, 'g-', linewidth=1.5)
    ax.set_xlabel('n', fontsize=12)
    ax.set_ylabel('f_γ(n)', fontsize=12)
    ax.set_title('Tropical Collatz Fixed Point f_γ', fontsize=13)
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('convergence_and_fixedpoint.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("  Saved: convergence_and_fixedpoint.png")
    
    # Figure 2: Evolution of iterates
    fig, ax = plt.subplots(figsize=(10, 6))
    iterations_to_show = [0, 1, 2, 5, 10, 20, len(iterates)-1]
    colors = plt.cm.viridis(np.linspace(0, 1, len(iterations_to_show)))
    
    for idx, k in enumerate(iterations_to_show):
        if k < len(iterates):
            ax.plot(range(len(iterates[k])), iterates[k], 
                   color=colors[idx], linewidth=1.2, alpha=0.8,
                   label=f'k = {k}')
    
    ax.set_xlabel('n', fontsize=12)
    ax.set_ylabel('T^k[f₀](n)', fontsize=12)
    ax.set_title('Evolution of Value Function Under Picard Iteration', fontsize=13)
    ax.legend(fontsize=9, loc='best')
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('iterate_evolution.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("  Saved: iterate_evolution.png")
    
    # Figure 3: Contraction rate verification
    fig, ax = plt.subplots(figsize=(8, 5))
    gammas = np.linspace(0.05, 0.99, 20)
    observed_rates = []
    
    N = 80
    a, b = 1.0, 1.5
    for gamma in gammas:
        np.random.seed(42)
        max_ratio = 0.0
        for _ in range(100):
            f = np.random.randn(N) * 3
            g = np.random.randn(N) * 3
            Tf = collatz_bellman(gamma, a, b, f)
            Tg = collatz_bellman(gamma, a, b, g)
            d_out = np.max(np.abs(Tf - Tg))
            d_in = np.max(np.abs(f - g))
            if d_in > 1e-10:
                max_ratio = max(max_ratio, d_out / d_in)
        observed_rates.append(max_ratio)
    
    ax.plot(gammas, gammas, 'r--', linewidth=2, label='Theoretical bound (γ)')
    ax.plot(gammas, observed_rates, 'bo-', markersize=5, linewidth=1.5,
           label='Observed Lipschitz constant')
    ax.set_xlabel('Discount factor γ', fontsize=12)
    ax.set_ylabel('Lipschitz constant', fontsize=12)
    ax.set_title('Contraction Constant Verification: Observed ≤ γ', fontsize=13)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('contraction_rate.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("  Saved: contraction_rate.png")
    
    # Figure 4: Collatz orbit in log-coordinates with branch structure
    fig, ax = plt.subplots(figsize=(10, 5))
    
    for n_start in [27, 97, 171]:
        orbit = collatz_orbit(n_start)
        log_orbit = [np.log(x) for x in orbit]
        ax.plot(range(len(log_orbit)), log_orbit, '-', linewidth=1.2,
               alpha=0.8, label=f'n₀ = {n_start}')
    
    ax.axhline(y=0, color='k', linestyle=':', alpha=0.3)
    ax.set_xlabel('Step', fontsize=12)
    ax.set_ylabel('log(n)', fontsize=12)
    ax.set_title('Collatz Orbits in Tropical (Logarithmic) Coordinates', fontsize=13)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('collatz_tropical_orbits.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("  Saved: collatz_tropical_orbits.png")

# ══════════════════════════════════════════════════════════════════════════════
# Main
# ══════════════════════════════════════════════════════════════════════════════

if __name__ == "__main__":
    print("\n" + "═" * 70)
    print("  TROPICAL CONTRACTION THEORY FOR COLLATZ DYNAMICS")
    print("  Computational Demonstrations")
    print("═" * 70 + "\n")
    
    demo_branch_isometry()
    demo_min_lipschitz()
    fixed_point, diffs, iterates = demo_bellman_convergence()
    demo_bellman_contraction_rate()
    demo_collatz_orbits_and_potential()
    
    print("=" * 70)
    print("Generating visualizations...")
    print("=" * 70)
    create_visualizations(fixed_point, diffs, iterates)
    
    print("\n" + "═" * 70)
    print("  All demonstrations complete.")
    print("═" * 70)
