#!/usr/bin/env python3
"""
Egyptian Fraction Decomposition Explorer
=========================================
Investigates the Divisor Decomposition Law:
    D(n) ~ C · d(n)^α
where D(n) = number of ways to write 1 as a sum of n unit fractions,
and d(n) is the number of divisors of n.

We explore a related, more tractable formulation:
    E(n) = number of Egyptian fraction representations of n/m for small m,
and correlate with divisor-like functions.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from collections import defaultdict
from fractions import Fraction
from functools import lru_cache
import json
import os

# --- Egyptian Fraction Decomposition Counter ---

def egyptian_representations(p, q, max_terms=3, min_denom=1):
    """
    Count the number of ways to write p/q as a sum of distinct unit fractions
    1/a1 + 1/a2 + ... + 1/ak where a1 < a2 < ... < ak, k <= max_terms.
    """
    results = []
    _find_egyptian(Fraction(p, q), [], min_denom, max_terms, results)
    return results

def _find_egyptian(target, current, min_d, max_terms, results):
    if target == 0:
        results.append(list(current))
        return
    if len(current) >= max_terms:
        return
    if target <= 0:
        return
    
    remaining = max_terms - len(current)
    # Minimum denominator: ceil(1/target)
    p_t, q_t = target.numerator, target.denominator
    start = max(min_d, (q_t + p_t - 1) // p_t)  # ceil(q/p)
    
    # Upper bound: we need remaining fractions, smallest is 1/max_d
    # remaining * 1/max_d >= target => max_d <= remaining * q / p
    max_d = min(remaining * q_t // p_t + 1, 300)
    
    for d in range(start, max_d + 1):
        f = Fraction(1, d)
        if f > target:
            continue
        new_target = target - f
        if new_target < 0:
            continue
        current.append(d)
        _find_egyptian(new_target, current, d + 1, max_terms, results)
        current.pop()


def divisor_count(n):
    """Count divisors of n."""
    if n <= 0:
        return 0
    count = 0
    for i in range(1, int(n**0.5) + 1):
        if n % i == 0:
            count += 2 if i * i != n else 1
    return count


def sigma_k(n, k=1):
    """Sum of k-th powers of divisors."""
    if n <= 0:
        return 0
    total = 0
    for i in range(1, int(n**0.5) + 1):
        if n % i == 0:
            total += i**k
            if i != n // i:
                total += (n // i)**k
    return total


# --- Experiment 1: Egyptian fraction count for 1/n ---

def experiment_unit_fractions():
    """Count Egyptian fraction representations of 1/n for various n."""
    print("=" * 60)
    print("EXPERIMENT 1: Egyptian Fraction Representations of 1/n")
    print("=" * 60)
    
    data = {}
    ns = list(range(2, 41))
    
    for n in ns:
        reps = egyptian_representations(1, n, max_terms=3, min_denom=2)
        d_n = divisor_count(n)
        data[n] = {
            'D': len(reps),
            'd': d_n,
            'sigma1': sigma_k(n, 1),
        }
        if len(reps) <= 20:
            print(f"  1/{n}: D={len(reps):3d} representations, d({n})={d_n}, σ₁({n})={sigma_k(n,1)}")
        else:
            print(f"  1/{n}: D={len(reps):3d} representations, d({n})={d_n}, σ₁({n})={sigma_k(n,1)}")
    
    return ns, data


def experiment_fraction_pq():
    """Count Egyptian fraction representations for p/q with small p, q."""
    print("\n" + "=" * 60)
    print("EXPERIMENT 2: Egyptian Fractions for General p/q")
    print("=" * 60)
    
    results = []
    for q in range(2, 21):
        for p in range(1, q):
            if Fraction(p, q) != Fraction(p, q):  # skip non-reduced
                continue
            from math import gcd
            g = gcd(p, q)
            if g > 1:
                continue  # skip non-reduced fractions
            reps = egyptian_representations(p, q, max_terms=3, min_denom=1)
            d_q = divisor_count(q)
            d_p = divisor_count(p)
            results.append({
                'p': p, 'q': q,
                'D': len(reps),
                'd_q': d_q,
                'd_p': d_p,
                'd_pq': divisor_count(p * q),
            })
            if len(reps) > 0:
                print(f"  {p}/{q}: D={len(reps):3d}, d(q)={d_q}, d(p·q)={divisor_count(p*q)}")
    
    return results


# --- Visualization ---

def plot_divisor_decomposition(ns, data, output_dir):
    """Create visualization of the Divisor Decomposition Law."""
    
    D_vals = np.array([data[n]['D'] for n in ns], dtype=float)
    d_vals = np.array([data[n]['d'] for n in ns], dtype=float)
    s_vals = np.array([data[n]['sigma1'] for n in ns], dtype=float)
    
    fig, axes = plt.subplots(2, 2, figsize=(14, 11))
    fig.suptitle('The Divisor Decomposition Law: Egyptian Fractions & Divisor Structure',
                 fontsize=14, fontweight='bold')
    
    # Plot 1: D(n) vs d(n) scatter
    ax = axes[0, 0]
    mask = D_vals > 0
    ax.scatter(d_vals[mask], D_vals[mask], c=np.array(ns)[mask], cmap='viridis', 
               s=50, alpha=0.7, edgecolors='black', linewidth=0.5)
    ax.set_xlabel('d(n) — Divisor Count', fontsize=11)
    ax.set_ylabel('D(n) — Egyptian Fraction Count', fontsize=11)
    ax.set_title('D(n) vs d(n): Correlation Structure', fontsize=12)
    
    # Fit power law where both are positive
    valid = mask & (d_vals > 0) & (D_vals > 0)
    if np.sum(valid) > 2:
        log_d = np.log(d_vals[valid])
        log_D = np.log(D_vals[valid])
        coeffs = np.polyfit(log_d, log_D, 1)
        alpha_fit = coeffs[0]
        C_fit = np.exp(coeffs[1])
        d_range = np.linspace(d_vals[valid].min(), d_vals[valid].max(), 100)
        ax.plot(d_range, C_fit * d_range**alpha_fit, 'r--', linewidth=2,
                label=f'Fit: D ≈ {C_fit:.2f} · d(n)^{alpha_fit:.2f}')
        ax.legend(fontsize=10)
    
    # Plot 2: D(n) vs n with highlighting
    ax = axes[0, 1]
    colors = ['#e74c3c' if n % 2 == 0 else '#3498db' for n in ns]
    bars = ax.bar(ns, D_vals, color=colors, alpha=0.7, edgecolor='black', linewidth=0.3)
    ax.set_xlabel('n', fontsize=11)
    ax.set_ylabel('D(n)', fontsize=11)
    ax.set_title('Egyptian Fraction Count D(n) for 1/n', fontsize=12)
    ax.legend(handles=[
        plt.Rectangle((0,0),1,1, color='#e74c3c', alpha=0.7, label='Even n'),
        plt.Rectangle((0,0),1,1, color='#3498db', alpha=0.7, label='Odd n'),
    ])
    
    # Plot 3: Log-log analysis
    ax = axes[1, 0]
    valid = (D_vals > 0) & (d_vals > 0)
    if np.sum(valid) > 0:
        ax.scatter(np.log(d_vals[valid]), np.log(D_vals[valid]), 
                   c=np.array(ns)[valid], cmap='plasma', s=40, alpha=0.7,
                   edgecolors='black', linewidth=0.5)
        if np.sum(valid) > 2:
            x_fit = np.linspace(np.log(d_vals[valid]).min(), np.log(d_vals[valid]).max(), 100)
            ax.plot(x_fit, coeffs[0] * x_fit + coeffs[1], 'r-', linewidth=2,
                    label=f'α = {alpha_fit:.3f}')
            ax.legend(fontsize=11)
    ax.set_xlabel('log d(n)', fontsize=11)
    ax.set_ylabel('log D(n)', fontsize=11)
    ax.set_title('Log-Log Plot: Power Law Detection', fontsize=12)
    
    # Plot 4: Ratio D(n)/d(n)^alpha
    ax = axes[1, 1]
    if np.sum(valid) > 2:
        ratio = D_vals[valid] / (d_vals[valid] ** alpha_fit)
        ax.plot(np.array(ns)[valid], ratio, 'o-', color='#2ecc71', markersize=5)
        ax.axhline(y=C_fit, color='red', linestyle='--', linewidth=2, 
                    label=f'C ≈ {C_fit:.3f}')
        ax.fill_between(np.array(ns)[valid], C_fit * 0.5, C_fit * 1.5, 
                        alpha=0.1, color='red')
        ax.set_xlabel('n', fontsize=11)
        ax.set_ylabel(f'D(n) / d(n)^{alpha_fit:.2f}', fontsize=11)
        ax.set_title('Convergence to Universal Constant C', fontsize=12)
        ax.legend(fontsize=11)
    
    plt.tight_layout()
    plt.savefig(os.path.join(output_dir, 'divisor_decomposition_law.png'), dpi=150, bbox_inches='tight')
    plt.close()
    print(f"\n  Saved: divisor_decomposition_law.png")
    
    if np.sum(valid) > 2:
        return C_fit, alpha_fit
    return None, None


def plot_correlation_matrix(ns, data, pq_data, output_dir):
    """Analyze correlation structure between arithmetic functions and Egyptian fractions."""
    
    fig, axes = plt.subplots(1, 3, figsize=(16, 5))
    fig.suptitle('Arithmetic Correlations with Egyptian Fraction Counts', 
                 fontsize=13, fontweight='bold')
    
    D_vals = [data[n]['D'] for n in ns]
    d_vals = [data[n]['d'] for n in ns]
    s_vals = [data[n]['sigma1'] for n in ns]
    
    # Correlation: D vs sigma_1
    ax = axes[0]
    ax.scatter(s_vals, D_vals, c='#9b59b6', s=40, alpha=0.7, edgecolors='black', linewidth=0.5)
    ax.set_xlabel('σ₁(n) — Sum of Divisors')
    ax.set_ylabel('D(n)')
    ax.set_title('D(n) vs σ₁(n)')
    
    # Correlation: D vs Euler's totient
    euler_vals = []
    for n in ns:
        phi = n
        temp = n
        p = 2
        while p * p <= temp:
            if temp % p == 0:
                while temp % p == 0:
                    temp //= p
                phi -= phi // p
            p += 1
        if temp > 1:
            phi -= phi // temp
        euler_vals.append(phi)
    
    ax = axes[1]
    ax.scatter(euler_vals, D_vals, c='#e67e22', s=40, alpha=0.7, edgecolors='black', linewidth=0.5)
    ax.set_xlabel('φ(n) — Euler Totient')
    ax.set_ylabel('D(n)')
    ax.set_title('D(n) vs φ(n)')
    
    # p/q data analysis
    if pq_data:
        ax = axes[2]
        D_pq = [r['D'] for r in pq_data if r['D'] > 0]
        d_q_vals = [r['d_q'] for r in pq_data if r['D'] > 0]
        d_pq_vals = [r['d_pq'] for r in pq_data if r['D'] > 0]
        
        ax.scatter(d_pq_vals, D_pq, c='#1abc9c', s=30, alpha=0.6, edgecolors='black', linewidth=0.3)
        ax.set_xlabel('d(p·q)')
        ax.set_ylabel('D(p/q)')
        ax.set_title('D(p/q) vs d(p·q)')
    
    plt.tight_layout()
    plt.savefig(os.path.join(output_dir, 'correlation_analysis.png'), dpi=150, bbox_inches='tight')
    plt.close()
    print(f"  Saved: correlation_analysis.png")


# --- Hypothesis Testing ---

def test_multiplicativity_hypothesis(ns, data):
    """Test if D is related to multiplicative structure."""
    print("\n" + "=" * 60)
    print("HYPOTHESIS TEST: Multiplicative Structure")
    print("=" * 60)
    
    # Check D(p) for primes vs D(composite)
    def is_prime(n):
        if n < 2: return False
        for i in range(2, int(n**0.5)+1):
            if n % i == 0: return False
        return True
    
    primes = [n for n in ns if is_prime(n)]
    composites = [n for n in ns if not is_prime(n) and n > 1]
    
    prime_D = [data[n]['D'] for n in primes]
    comp_D = [data[n]['D'] for n in composites]
    
    print(f"  Primes: mean D = {np.mean(prime_D):.2f}, median = {np.median(prime_D):.1f}")
    print(f"  Composites: mean D = {np.mean(comp_D):.2f}, median = {np.median(comp_D):.1f}")
    print(f"  Ratio (composite/prime): {np.mean(comp_D)/np.mean(prime_D):.3f}")
    
    # Test: D(mn) vs D(m) * D(n) for coprime m, n
    from math import gcd
    print("\n  Testing weak multiplicativity: D(mn) vs D(m)·D(n):")
    for m in range(2, 8):
        for n in range(m+1, 10):
            mn = m * n
            if mn in data and m in data and n in data and gcd(m, n) == 1:
                Dmn = data[mn]['D']
                Dm_Dn = data[m]['D'] * data[n]['D']
                ratio = Dmn / Dm_Dn if Dm_Dn > 0 else float('inf')
                print(f"    D({m}·{n}={mn}) = {Dmn}, D({m})·D({n}) = {Dm_Dn}, ratio = {ratio:.3f}")
    
    return prime_D, comp_D


def test_growth_rate_hypothesis(ns, data):
    """Test growth rate hypotheses."""
    print("\n" + "=" * 60)
    print("HYPOTHESIS TEST: Growth Rate Analysis")
    print("=" * 60)
    
    D_vals = np.array([data[n]['D'] for n in ns], dtype=float)
    d_vals = np.array([data[n]['d'] for n in ns], dtype=float)
    n_arr = np.array(ns, dtype=float)
    
    # Test several growth models
    valid = D_vals > 0
    if np.sum(valid) < 3:
        print("  Insufficient data")
        return
    
    log_D = np.log(D_vals[valid])
    log_n = np.log(n_arr[valid])
    log_d = np.log(d_vals[valid])
    
    # Model 1: D(n) ~ C * n^beta
    c1 = np.polyfit(log_n, log_D, 1)
    resid1 = np.sum((log_D - c1[0]*log_n - c1[1])**2)
    print(f"  Model D ~ C·n^β: β={c1[0]:.3f}, C={np.exp(c1[1]):.3f}, SSR={resid1:.3f}")
    
    # Model 2: D(n) ~ C * d(n)^alpha
    c2 = np.polyfit(log_d, log_D, 1)
    resid2 = np.sum((log_D - c2[0]*log_d - c2[1])**2)
    print(f"  Model D ~ C·d(n)^α: α={c2[0]:.3f}, C={np.exp(c2[1]):.3f}, SSR={resid2:.3f}")
    
    # Model 3: D(n) ~ C * sigma_1(n)^gamma
    s_vals = np.array([data[n]['sigma1'] for n in ns], dtype=float)
    log_s = np.log(s_vals[valid])
    c3 = np.polyfit(log_s, log_D, 1)
    resid3 = np.sum((log_D - c3[0]*log_s - c3[1])**2)
    print(f"  Model D ~ C·σ₁(n)^γ: γ={c3[0]:.3f}, C={np.exp(c3[1]):.3f}, SSR={resid3:.3f}")
    
    # Model 4: Combined
    X = np.column_stack([log_d, log_n, np.ones_like(log_d)])
    c4, resid4, _, _ = np.linalg.lstsq(X, log_D, rcond=None)
    resid4_val = np.sum((log_D - X @ c4)**2) if len(resid4) == 0 else resid4[0]
    print(f"  Model D ~ C·d(n)^α·n^β: α={c4[0]:.3f}, β={c4[1]:.3f}, C={np.exp(c4[2]):.3f}, SSR={resid4_val:.3f}")
    
    print(f"\n  Best single-variable model: {'d(n)^α' if resid2 < resid1 else 'n^β'}")
    print(f"  Winner: α = {c2[0]:.4f}, C = {np.exp(c2[1]):.4f}")
    
    return c2[0], np.exp(c2[1])


# --- Main ---

if __name__ == '__main__':
    output_dir = os.path.dirname(os.path.abspath(__file__))
    
    print("╔══════════════════════════════════════════════════════════╗")
    print("║   EGYPTIAN FRACTION DECOMPOSITION EXPLORER              ║")
    print("║   Investigating the Divisor Decomposition Law           ║")
    print("╚══════════════════════════════════════════════════════════╝")
    
    # Run experiments
    ns, data = experiment_unit_fractions()
    pq_data = experiment_fraction_pq()
    
    # Hypothesis tests
    test_multiplicativity_hypothesis(ns, data)
    alpha, C = test_growth_rate_hypothesis(ns, data)
    
    # Visualizations
    C_fit, alpha_fit = plot_divisor_decomposition(ns, data, output_dir)
    plot_correlation_matrix(ns, data, pq_data, output_dir)
    
    # Summary
    print("\n" + "=" * 60)
    print("FINDINGS SUMMARY")
    print("=" * 60)
    if C_fit and alpha_fit:
        print(f"  Fitted power law: D(n) ≈ {C_fit:.4f} · d(n)^{alpha_fit:.4f}")
        print(f"  Universal constant C ≈ {C_fit:.4f}")
        print(f"  Scaling exponent α ≈ {alpha_fit:.4f}")
    
    # Save results
    results = {
        'fitted_C': C_fit,
        'fitted_alpha': alpha_fit,
        'data': {str(n): data[n] for n in ns}
    }
    with open(os.path.join(output_dir, 'egyptian_fraction_results.json'), 'w') as f:
        json.dump(results, f, indent=2)
    print(f"\n  Results saved to egyptian_fraction_results.json")
