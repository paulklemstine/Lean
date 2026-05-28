#!/usr/bin/env python3
"""
Visualization: K=1 Valuated Exchange Derivative Closure

This script creates a heatmap showing the success rate of the K=1 valuated
exchange condition and its derivative closure across different polynomial
parameters (degree d and number of variables n).

It visualizes the theorem's prediction that derivative closure holds universally
for nonneg homogeneous polynomials with M-convex support and K=1 exchange.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from itertools import combinations
from typing import Dict, List, Tuple, Optional
import random


# ---- Inlined core functions ----

def exchange_vec(m, i, j):
    result = list(m)
    result[i] = max(0, result[i] - 1)
    if i != j:
        result[j] += 1
    return tuple(result)


def check_valuated_exchange_one(w, eps=1e-10):
    support = [m for m, v in w.items() if v > eps]
    if len(support) <= 1:
        return True
    n = len(support[0])
    for alpha in support:
        wa = w.get(alpha, 0.0)
        if wa <= eps:
            continue
        for beta in support:
            wb = w.get(beta, 0.0)
            if wb <= eps:
                continue
            for i in range(n):
                if alpha[i] <= beta[i]:
                    continue
                found = False
                for j in range(n):
                    if j == i or beta[j] <= alpha[j]:
                        continue
                    ea = exchange_vec(alpha, i, j)
                    eb = exchange_vec(beta, j, i)
                    w_ea = w.get(ea, 0.0)
                    w_eb = w.get(eb, 0.0)
                    if w_ea * w_eb >= wa * wb - eps:
                        found = True
                        break
                if not found:
                    return False
    return True


def partial_derivative_weight(var_idx, w):
    dw = {}
    for alpha, val in w.items():
        if val == 0 or alpha[var_idx] < 1:
            continue
        m = list(alpha)
        m[var_idx] -= 1
        m_tuple = tuple(m)
        dw[m_tuple] = alpha[var_idx] * val
    return dw


def weighted_uniform_matroid(n, d, weights=None):
    if d > n:
        return {}
    if weights is None:
        weights = [1.0] * n
    w = {}
    for combo in combinations(range(n), d):
        vec = [0] * n
        for i in combo:
            vec[i] = 1
        weight = 1.0
        for i in combo:
            weight *= weights[i]
        w[tuple(vec)] = weight
    return w


# ---- Experiment ----

def run_experiment():
    rng = random.Random(42)
    max_d = 5
    max_n = 7
    num_samples = 200
    
    # Data arrays
    original_rate = np.full((max_d, max_n), np.nan)
    closure_rate = np.full((max_d, max_n), np.nan)
    
    for d in range(1, max_d + 1):
        for n in range(d, max_n + 1):
            orig_pass = 0
            deriv_pass = 0
            total = 0
            
            for _ in range(num_samples):
                weights = [rng.expovariate(1.0) for _ in range(n)]
                w = weighted_uniform_matroid(n, d, weights)
                if not w:
                    continue
                
                total += 1
                ok = check_valuated_exchange_one(w)
                if not ok:
                    continue
                orig_pass += 1
                
                all_ok = True
                for var_idx in range(n):
                    dw = partial_derivative_weight(var_idx, w)
                    if not dw:
                        continue
                    ok_d = check_valuated_exchange_one(dw)
                    if not ok_d:
                        all_ok = False
                        break
                if all_ok:
                    deriv_pass += 1
            
            if total > 0:
                original_rate[d-1, n-1] = orig_pass / total
            if orig_pass > 0:
                closure_rate[d-1, n-1] = deriv_pass / orig_pass
    
    return original_rate, closure_rate


def main():
    original_rate, closure_rate = run_experiment()
    
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))
    
    # Plot 1: Original exchange rate
    ax1 = axes[0]
    im1 = ax1.imshow(original_rate, cmap='RdYlGn', vmin=0, vmax=1,
                     aspect='auto', origin='lower')
    ax1.set_xlabel('Number of Variables (n)', fontsize=12)
    ax1.set_ylabel('Degree (d)', fontsize=12)
    ax1.set_title('K=1 Exchange Satisfaction Rate\n(Weighted Uniform Matroids)', fontsize=13)
    ax1.set_xticks(range(7))
    ax1.set_xticklabels(range(1, 8))
    ax1.set_yticks(range(5))
    ax1.set_yticklabels(range(1, 6))
    
    for i in range(5):
        for j in range(7):
            val = original_rate[i, j]
            if not np.isnan(val):
                color = 'white' if val < 0.5 else 'black'
                ax1.text(j, i, f'{val:.2f}', ha='center', va='center',
                        color=color, fontsize=9, fontweight='bold')
    
    plt.colorbar(im1, ax=ax1, shrink=0.8)
    
    # Plot 2: Derivative closure rate
    ax2 = axes[1]
    im2 = ax2.imshow(closure_rate, cmap='RdYlGn', vmin=0, vmax=1,
                     aspect='auto', origin='lower')
    ax2.set_xlabel('Number of Variables (n)', fontsize=12)
    ax2.set_ylabel('Degree (d)', fontsize=12)
    ax2.set_title('Derivative Closure Rate\n(Among K=1 Exchange Polynomials)', fontsize=13)
    ax2.set_xticks(range(7))
    ax2.set_xticklabels(range(1, 8))
    ax2.set_yticks(range(5))
    ax2.set_yticklabels(range(1, 6))
    
    for i in range(5):
        for j in range(7):
            val = closure_rate[i, j]
            if not np.isnan(val):
                color = 'white' if val < 0.5 else 'black'
                ax2.text(j, i, f'{val:.2f}', ha='center', va='center',
                        color=color, fontsize=9, fontweight='bold')
    
    plt.colorbar(im2, ax=ax2, shrink=0.8)
    
    plt.suptitle('Derivative Closure of K=1 Valuated Exchange\n'
                 'Computational Verification on Weighted Uniform Matroids',
                 fontsize=14, fontweight='bold', y=1.02)
    
    plt.tight_layout()
    plt.savefig('exchange_heatmap.png', dpi=150, bbox_inches='tight')
    print("Saved exchange_heatmap.png")


if __name__ == "__main__":
    main()
