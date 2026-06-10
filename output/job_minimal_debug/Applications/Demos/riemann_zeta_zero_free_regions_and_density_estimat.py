#!/usr/bin/env python3
"""
Applications of zero-free region infrastructure to practical problems.

This module demonstrates how the formally verified framework applies to:
1. Certified prime gap estimation
2. Zero-free region parameter optimization
3. Comparative analysis of different barrier constants
4. Explicit PNT error tables for number-theoretic applications
"""

import math
from typing import List, Tuple
from algorithms import (
    LogZeroFreeDatum, PrimeCountingTransferDatum,
    BarrierComputer, PrimeErrorEstimator, RVMEstimator
)


# ─────────────────────────────────────────────────────────────
# Application 1: Certified Prime Counting Error Tables
# ─────────────────────────────────────────────────────────────

def prime_counting_error_table():
    """
    Generate a table of certified prime counting error bounds.
    
    For each x, shows the upper bound on |π(x) - li(x)| derived from
    the transfer datum with specific constants A, B.
    """
    print("=" * 70)
    print("APPLICATION 1: Certified Prime Counting Error Bounds")
    print("=" * 70)
    print()
    print("Bound: |ψ(x) - x| ≤ A · x · exp(-B · √(log x))")
    print("This implies |π(x) - li(x)| ≤ (A/log x) · x · exp(-B · √(log x))")
    print()
    
    # Classical de la Vallée-Poussin constants (approximate)
    datum = PrimeCountingTransferDatum(A=2.0, B=0.5)
    pe = PrimeErrorEstimator(datum)
    
    x_values = [1e3, 1e4, 1e5, 1e6, 1e8, 1e10, 1e12, 1e15, 1e18, 1e20]
    
    print(f"{'x':>14s} {'|ψ(x)-x| bound':>18s} {'Relative error':>18s} {'π(x) error est.':>18s}")
    print("-" * 70)
    
    for x in x_values:
        abs_bound = pe.error_bound(x)
        rel_bound = pe.relative_error(x)
        pi_bound = abs_bound / math.log(x)  # approximate π(x) error
        print(f"{x:14.0e} {abs_bound:18.4e} {rel_bound:18.6e} {pi_bound:18.4e}")


# ─────────────────────────────────────────────────────────────
# Application 2: Zero-Free Region Comparison
# ─────────────────────────────────────────────────────────────

def zero_free_region_comparison():
    """
    Compare zero-free regions with different constants.
    
    Shows how the strip width varies with the constant c,
    demonstrating the region inheritance theorem.
    """
    print()
    print("=" * 70)
    print("APPLICATION 2: Zero-Free Region Constant Comparison")
    print("=" * 70)
    print()
    print("Theorem: c' ≤ c ⟹ region(c') ⊂ region(c)")
    print("(Formally verified as zero_free_of_smaller_constant)")
    print()
    
    c_values = [0.01, 0.05, 0.1, 0.2, 0.5, 1.0]
    T = 1e6
    
    print(f"At height T = {T:.0e}:")
    print(f"{'c':>8s} {'Barrier σ':>14s} {'Strip width':>14s} {'% of critical':>14s}")
    print("-" * 52)
    
    for c in c_values:
        datum = LogZeroFreeDatum(c=c)
        bc = BarrierComputer(datum)
        b = bc.barrier(T)
        w = bc.strip_width(T)
        pct = w * 100
        print(f"{c:8.2f} {b:14.8f} {w:14.8f} {pct:13.6f}%")


# ─────────────────────────────────────────────────────────────
# Application 3: Height-Dependent Strip Tables
# ─────────────────────────────────────────────────────────────

def height_dependent_strips():
    """
    Generate tables showing how the zero-free strip narrows with height.
    
    This demonstrates the vertical strip theorem: at height T,
    F(s) ≠ 0 for Re(s) > 1 - c/log(T+2) and |Im(s)| ≤ T.
    """
    print()
    print("=" * 70)
    print("APPLICATION 3: Height-Dependent Zero-Free Strips")
    print("=" * 70)
    print()
    print("Theorem: |Im(s)| ≤ T and Re(s) > 1 - c/log(T+2) ⟹ F(s) ≠ 0")
    print("(Formally verified as zero_free_vertical_strip)")
    print()
    
    c = 0.1
    datum = LogZeroFreeDatum(c=c)
    bc = BarrierComputer(datum)
    
    print(f"Constant c = {c}")
    print(f"{'Height T':>14s} {'Strip boundary σ':>18s} {'Strip width':>14s} {'Zeros excluded':>16s}")
    print("-" * 64)
    
    for exp in range(1, 21):
        T = 10 ** exp
        b = bc.barrier(T)
        w = bc.strip_width(T)
        # Approximate number of zeros in the strip using RVM
        n_zeros = RVMEstimator.main_term(T)
        print(f"{T:14.0e} {b:18.10f} {w:14.10f} {n_zeros:16.1f}")


# ─────────────────────────────────────────────────────────────
# Application 4: Transfer Bound Quality Assessment
# ─────────────────────────────────────────────────────────────

def transfer_quality_assessment():
    """
    Assess how the prime error decay rate depends on the transfer constants.
    
    For different (A, B) pairs, compute when the relative error drops below
    various thresholds.
    """
    print()
    print("=" * 70)
    print("APPLICATION 4: Transfer Bound Quality Assessment")
    print("=" * 70)
    print()
    print("Finding x such that A·exp(-B·√(log x)) < ε")
    print("(Sublinearity certified by psiError_small_o_identity)")
    print()
    
    configs = [
        (1.0, 0.5, "Weak transfer"),
        (1.0, 1.0, "Moderate transfer"),
        (2.0, 1.0, "Large A"),
        (1.0, 2.0, "Strong transfer"),
    ]
    
    thresholds = [0.1, 0.01, 1e-3, 1e-6, 1e-10]
    
    header = f"{'Config':>20s}"
    for eps in thresholds:
        header += f" {'ε=' + f'{eps:.0e}':>14s}"
    print(header)
    print("-" * (20 + 14 * len(thresholds)))
    
    for A, B, name in configs:
        datum = PrimeCountingTransferDatum(A=A, B=B)
        pe = PrimeErrorEstimator(datum)
        row = f"{name:>20s}"
        for eps in thresholds:
            threshold = pe.find_threshold(eps)
            if threshold < 1e18:
                row += f" {threshold:14.2e}"
            else:
                row += f" {'> 10^18':>14s}"
        print(row)


# ─────────────────────────────────────────────────────────────
# Application 5: Barrier Convergence Rate
# ─────────────────────────────────────────────────────────────

def barrier_convergence_rate():
    """
    Analyze the rate at which the barrier approaches 1.
    
    The barrier_tendsto_one theorem says b_c(y) → 1.
    Here we quantify the convergence rate: 1 - b_c(y) = c/log(y+2).
    """
    print()
    print("=" * 70)
    print("APPLICATION 5: Barrier Convergence Rate Analysis")
    print("=" * 70)
    print()
    print("Theorem: b_c(y) → 1 as y → ∞ (formally: barrier_tendsto_one)")
    print("Rate: 1 - b_c(y) = c/log(y+2) = O(1/log y)")
    print()
    
    c = 0.1
    datum = LogZeroFreeDatum(c=c)
    bc = BarrierComputer(datum)
    
    print(f"c = {c}")
    print(f"{'y':>14s} {'b_c(y)':>16s} {'1 - b_c(y)':>16s} {'c/log(y+2)':>16s} {'Match':>8s}")
    print("-" * 72)
    
    for exp in range(0, 31):
        y = 10 ** exp
        b = bc.barrier(y)
        gap = 1 - b
        expected = c / math.log(y + 2)
        match = abs(gap - expected) < 1e-12
        print(f"{y:14.0e} {b:16.12f} {gap:16.12e} {expected:16.12e} {'✓' if match else '✗':>8s}")


# ─────────────────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────────────────

if __name__ == "__main__":
    prime_counting_error_table()
    zero_free_region_comparison()
    height_dependent_strips()
    transfer_quality_assessment()
    barrier_convergence_rate()
    
    print()
    print("=" * 70)
    print("All applications complete.")
    print("=" * 70)


#!/usr/bin/env python3
"""
Interactive demonstration of logarithmic zero-free region barriers
and their arithmetic consequences.

This script visualizes:
1. The logarithmic barrier b_c(y) = 1 - c / log(y + 2)
2. Induced vertical zero-free strips at finite height T
3. The Riemann-von Mangoldt main term T/(2π) · log(T/(2πe))
4. Prime error decay: A · x · exp(-B · √(log x))

Usage:
    python demo.py
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import Rectangle
from matplotlib.collections import PatchCollection
import os

# ─────────────────────────────────────────────────────────────
# 1. Logarithmic Barrier Visualization
# ─────────────────────────────────────────────────────────────

def barrier(y, c):
    """Compute the logarithmic barrier b_c(y) = 1 - c / log(y + 2)."""
    return 1.0 - c / np.log(y + 2)

def plot_barrier_curves(cs=None, T0=0, save_path="barrier_curves.png"):
    """Plot the barrier function for multiple values of c."""
    if cs is None:
        cs = [0.05, 0.1, 0.2, 0.5, 1.0]
    
    y = np.linspace(0, 1e6, 10000)
    
    fig, ax = plt.subplots(1, 1, figsize=(10, 6))
    
    for c in cs:
        b = barrier(y, c)
        ax.plot(y, b, label=f"c = {c}", linewidth=2)
    
    ax.axhline(y=1, color='red', linestyle='--', linewidth=1.5, label='Re(s) = 1 (critical line)')
    ax.set_xlabel('Height y = |Im(s)|', fontsize=13)
    ax.set_ylabel('Barrier value b_c(y)', fontsize=13)
    ax.set_title('Logarithmic Zero-Free Barrier: b_c(y) = 1 - c / log(y + 2)', fontsize=14)
    ax.legend(fontsize=11)
    ax.set_ylim(0.0, 1.05)
    ax.grid(True, alpha=0.3)
    
    fig.tight_layout()
    fig.savefig(save_path, dpi=150)
    plt.close(fig)
    print(f"[Saved] {save_path}")

# ─────────────────────────────────────────────────────────────
# 2. Vertical Strip Visualization
# ─────────────────────────────────────────────────────────────

def plot_vertical_strip(c=0.1, T_values=None, save_path="vertical_strip.png"):
    """Visualize the zero-free strip induced at different heights T."""
    if T_values is None:
        T_values = [10, 100, 1000, 10000]
    
    fig, ax = plt.subplots(1, 1, figsize=(10, 7))
    
    # Plot the curved barrier
    y = np.linspace(0, max(T_values) * 1.2, 5000)
    b = barrier(y, c)
    ax.plot(b, y, 'b-', linewidth=2.5, label=f'Barrier (c={c})')
    ax.axvline(x=1, color='red', linestyle='--', linewidth=1.5, label='Re(s) = 1')
    
    colors = plt.cm.viridis(np.linspace(0.2, 0.8, len(T_values)))
    
    for T, color in zip(T_values, colors):
        sigma = barrier(T, c)
        rect = Rectangle((sigma, 0), 1 - sigma, T, 
                         alpha=0.15, facecolor=color, edgecolor=color, linewidth=2)
        ax.add_patch(rect)
        ax.annotate(f'T={T}\nσ={sigma:.4f}', 
                   xy=(sigma, T), fontsize=9,
                   xytext=(sigma - 0.05, T + max(T_values)*0.03),
                   arrowprops=dict(arrowstyle='->', color=color),
                   color=color, fontweight='bold')
    
    ax.set_xlabel('Re(s)', fontsize=13)
    ax.set_ylabel('|Im(s)|', fontsize=13)
    ax.set_title(f'Vertical Zero-Free Strips from Logarithmic Barrier (c={c})', fontsize=14)
    ax.legend(fontsize=11, loc='upper left')
    ax.set_xlim(0.85, 1.02)
    ax.grid(True, alpha=0.3)
    
    fig.tight_layout()
    fig.savefig(save_path, dpi=150)
    plt.close(fig)
    print(f"[Saved] {save_path}")

# ─────────────────────────────────────────────────────────────
# 3. Riemann-von Mangoldt Main Term
# ─────────────────────────────────────────────────────────────

def rvm_main_term(T):
    """Compute the Riemann-von Mangoldt main term: T/(2π) · log(T/(2πe))."""
    if T <= 0:
        return 0.0
    two_pi = 2 * np.pi
    return (T / two_pi) * np.log(T / (two_pi * np.e))

def plot_rvm(save_path="rvm_main_term.png"):
    """Plot the Riemann-von Mangoldt main term."""
    T = np.linspace(10, 1e5, 10000)
    N = np.array([rvm_main_term(t) for t in T])
    
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))
    
    # Left: absolute growth
    axes[0].plot(T, N, 'b-', linewidth=2)
    axes[0].set_xlabel('T', fontsize=13)
    axes[0].set_ylabel('N(T) main term', fontsize=13)
    axes[0].set_title('Riemann-von Mangoldt: N(T) ~ (T/2π)log(T/2πe)', fontsize=13)
    axes[0].grid(True, alpha=0.3)
    
    # Right: N(T) / (T log T) ratio
    TlogT = T * np.log(T)
    ratio = N / TlogT
    axes[1].plot(T, ratio, 'r-', linewidth=2)
    axes[1].set_xlabel('T', fontsize=13)
    axes[1].set_ylabel('N(T) / (T log T)', fontsize=13)
    axes[1].set_title('Growth rate: N(T) = O(T log T)', fontsize=13)
    axes[1].axhline(y=1/(2*np.pi), color='green', linestyle='--', label=f'1/(2π) ≈ {1/(2*np.pi):.4f}')
    axes[1].legend(fontsize=11)
    axes[1].grid(True, alpha=0.3)
    
    fig.tight_layout()
    fig.savefig(save_path, dpi=150)
    plt.close(fig)
    print(f"[Saved] {save_path}")

# ─────────────────────────────────────────────────────────────
# 4. Prime Error Decay
# ─────────────────────────────────────────────────────────────

def prime_error_bound(x, A=1.0, B=1.0):
    """Compute A · x · exp(-B · √(log x))."""
    if x < 2:
        return 0.0
    return A * x * np.exp(-B * np.sqrt(np.log(x)))

def plot_prime_error(save_path="prime_error_decay.png"):
    """Plot the prime error bound and its sublinearity."""
    x = np.linspace(2, 1e8, 100000)
    
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))
    
    # Left: absolute error bound
    for B in [0.5, 1.0, 1.5]:
        err = np.array([prime_error_bound(xi, A=1.0, B=B) for xi in x])
        axes[0].plot(x, err, linewidth=2, label=f'B={B}')
    axes[0].plot(x, x, 'k--', linewidth=1, alpha=0.5, label='x (identity)')
    axes[0].set_xlabel('x', fontsize=13)
    axes[0].set_ylabel('Error bound', fontsize=13)
    axes[0].set_title('Prime Error Bound: A·x·exp(-B·√(log x))', fontsize=13)
    axes[0].legend(fontsize=11)
    axes[0].set_yscale('log')
    axes[0].set_xscale('log')
    axes[0].grid(True, alpha=0.3)
    
    # Right: sublinearity — error/x → 0
    for B in [0.5, 1.0, 1.5]:
        err = np.array([prime_error_bound(xi, A=1.0, B=B) for xi in x])
        axes[1].plot(x, err / x, linewidth=2, label=f'B={B}')
    axes[1].set_xlabel('x', fontsize=13)
    axes[1].set_ylabel('Error / x', fontsize=13)
    axes[1].set_title('Sublinearity: |ψ(x)-x|/x → 0 (PNT)', fontsize=13)
    axes[1].legend(fontsize=11)
    axes[1].set_xscale('log')
    axes[1].grid(True, alpha=0.3)
    
    fig.tight_layout()
    fig.savefig(save_path, dpi=150)
    plt.close(fig)
    print(f"[Saved] {save_path}")

# ─────────────────────────────────────────────────────────────
# 5. Barrier Monotonicity Verification
# ─────────────────────────────────────────────────────────────

def verify_barrier_monotonicity(c=0.1, num_samples=10000):
    """Numerically verify barrier monotonicity: y1 ≤ y2 ⟹ b_c(y1) ≤ b_c(y2)."""
    y_values = np.sort(np.random.uniform(0, 1e8, num_samples))
    violations = 0
    for i in range(len(y_values) - 1):
        b1 = barrier(y_values[i], c)
        b2 = barrier(y_values[i+1], c)
        if b1 > b2 + 1e-15:  # numerical tolerance
            violations += 1
    print(f"[Monotonicity check] c={c}, samples={num_samples}, violations={violations}")
    return violations == 0

# ─────────────────────────────────────────────────────────────
# 6. Constant Scaling Experiment (for FUTURE_DIRECTIONS)
# ─────────────────────────────────────────────────────────────

def constant_scaling_experiment(save_path="constant_scaling.png"):
    """
    Test the hypothesis: for a family of barriers b_a(T), the strip width
    at height T scales linearly in a.
    """
    T = 1e6
    a_values = np.linspace(0.01, 2.0, 200)
    strip_widths = 1 - np.array([barrier(T, a) for a in a_values])
    
    fig, ax = plt.subplots(1, 1, figsize=(8, 5))
    ax.plot(a_values, strip_widths, 'b-', linewidth=2, label='Strip width at T=10⁶')
    ax.plot(a_values, a_values / np.log(T + 2), 'r--', linewidth=2, label='Linear fit: a/log(T+2)')
    ax.set_xlabel('Constant a', fontsize=13)
    ax.set_ylabel('Strip width 1 - b_a(T)', fontsize=13)
    ax.set_title(f'Strip Width vs. Zero-Free Constant at T={T:.0e}', fontsize=14)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    
    fig.tight_layout()
    fig.savefig(save_path, dpi=150)
    plt.close(fig)
    print(f"[Saved] {save_path}")

# ─────────────────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("=" * 60)
    print("Zero-Free Region Infrastructure — Demonstrations")
    print("=" * 60)
    
    print("\n1. Plotting barrier curves...")
    plot_barrier_curves()
    
    print("\n2. Plotting vertical strips...")
    plot_vertical_strip()
    
    print("\n3. Plotting Riemann-von Mangoldt main term...")
    plot_rvm()
    
    print("\n4. Plotting prime error decay...")
    plot_prime_error()
    
    print("\n5. Verifying barrier monotonicity...")
    verify_barrier_monotonicity()
    
    print("\n6. Running constant scaling experiment...")
    constant_scaling_experiment()
    
    print("\n" + "=" * 60)
    print("All demonstrations complete.")
    print("=" * 60)
