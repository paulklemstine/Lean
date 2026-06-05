#!/usr/bin/env python3
"""
Visualization: Collatz Orbit Density and Contraction

Generates plots showing:
1. Odd-step density vs stopping time
2. Density contraction threshold
3. Proof resistance landscape
"""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import math


def collatz_step(n: int) -> int:
    return n // 2 if n % 2 == 0 else 3 * n + 1

def stopping_time(n: int, max_steps: int = 100000) -> int:
    for k in range(max_steps):
        if n == 1:
            return k
        n = collatz_step(n)
    return -1

def peak_value(n: int) -> int:
    peak = n
    val = n
    while val != 1:
        val = collatz_step(val)
        peak = max(peak, val)
    return peak

def odd_density(n: int) -> float:
    val = n
    odd_count = 0
    total = 0
    while val != 1:
        if val % 2 == 1:
            odd_count += 1
        total += 1
        val = collatz_step(val)
    return odd_count / total if total > 0 else 0.0


def plot_density_vs_stopping_time():
    """Plot odd-step density vs stopping time for n ∈ [1, 5000]."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    
    ns = range(2, 5001)
    densities = []
    stop_times = []
    for n in ns:
        d = odd_density(n)
        st = stopping_time(n)
        densities.append(d)
        stop_times.append(st)
    
    # Left: density histogram
    ax = axes[0]
    ax.hist(densities, bins=50, color='steelblue', alpha=0.7, edgecolor='black')
    ax.axvline(x=1/3, color='red', linestyle='--', linewidth=2,
               label='Contraction threshold (1/3)')
    ax.axvline(x=0.5, color='orange', linestyle='--', linewidth=2,
               label='Parity exclusion bound (1/2)')
    ax.set_xlabel('Odd-Step Density', fontsize=12)
    ax.set_ylabel('Count', fontsize=12)
    ax.set_title('Distribution of Odd-Step Density\n(n = 2 to 5000)', fontsize=13)
    ax.legend(fontsize=10)
    
    # Right: density vs stopping time
    ax = axes[1]
    scatter = ax.scatter(stop_times, densities, c=list(ns), cmap='viridis',
                         s=3, alpha=0.5)
    ax.axhline(y=1/3, color='red', linestyle='--', linewidth=2,
               label='Contraction threshold')
    ax.axhline(y=0.5, color='orange', linestyle='--', linewidth=2,
               label='Parity exclusion bound')
    ax.set_xlabel('Stopping Time', fontsize=12)
    ax.set_ylabel('Odd-Step Density', fontsize=12)
    ax.set_title('Odd Density vs Stopping Time', fontsize=13)
    ax.legend(fontsize=10)
    plt.colorbar(scatter, ax=ax, label='Starting value n')
    
    plt.tight_layout()
    plt.savefig('collatz_density_analysis.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: collatz_density_analysis.png")


def plot_proof_resistance():
    """Plot proof resistance landscape."""
    fig, ax = plt.subplots(figsize=(10, 6))
    
    ns = range(2, 10001)
    resistances = []
    for n in ns:
        st = stopping_time(n)
        pk = peak_value(n)
        log_pk = math.log2(pk) if pk > 0 else 0
        resistance = st * (int(log_pk) + 1)
        resistances.append(resistance)
    
    ax.scatter(list(ns), resistances, s=1, alpha=0.3, c='darkblue')
    ax.set_xlabel('Starting Value n', fontsize=12)
    ax.set_ylabel('Proof Resistance', fontsize=12)
    ax.set_title('Proof Resistance Landscape\n'
                 '(stopping_time × log₂(peak))', fontsize=13)
    ax.set_yscale('log')
    
    # Highlight extreme values
    max_idx = np.argmax(resistances)
    ax.annotate(f'n={max_idx+2}\nR={resistances[max_idx]}',
                xy=(max_idx+2, resistances[max_idx]),
                fontsize=9, color='red',
                arrowprops=dict(arrowstyle='->', color='red'))
    
    plt.tight_layout()
    plt.savefig('collatz_proof_resistance.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: collatz_proof_resistance.png")


def plot_contraction_inequality():
    """Plot the key inequality 3^j vs 2^(2j)."""
    fig, ax = plt.subplots(figsize=(8, 6))
    
    js = np.arange(0, 20)
    pow3 = 3.0 ** js
    pow4 = 4.0 ** js
    
    ax.semilogy(js, pow3, 'ro-', label='3^j (odd-step growth)', markersize=6)
    ax.semilogy(js, pow4, 'bs-', label='4^j = 2^(2j) (two even-step shrinkage)',
                markersize=6)
    ax.fill_between(js, pow3, pow4, alpha=0.2, color='green',
                    label='Contraction gap')
    ax.set_xlabel('j (number of odd steps)', fontsize=12)
    ax.set_ylabel('Factor', fontsize=12)
    ax.set_title('The Contraction Engine: 3^j < 4^j\n'
                 'Each odd step can be "paid for" by two even steps',
                 fontsize=13)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('collatz_contraction_inequality.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: collatz_contraction_inequality.png")


if __name__ == "__main__":
    plot_density_vs_stopping_time()
    plot_proof_resistance()
    plot_contraction_inequality()
