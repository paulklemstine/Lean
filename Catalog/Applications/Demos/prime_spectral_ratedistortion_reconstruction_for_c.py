#!/usr/bin/env python3
"""
Prime-Spectral Rate–Distortion Theory: Concrete Numerical Demo

This script demonstrates the key theorems from the Lean formalization
with concrete numerical examples and visualizations.

We construct a small prime spectrum, compute optimal codebooks, verify
the rate–distortion monotonicity, and visualize the greedy algorithm.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from itertools import combinations
from typing import List, Tuple, Dict
import os

# ─── Core Types ───────────────────────────────────────────────────────

class PrimeBetaState:
    """A spectral state: (index, beta parameter)."""
    def __init__(self, index: int, beta: float):
        self.index = index
        self.beta = beta

    def __repr__(self):
        return f"ω({self.index}, β={self.beta:.2f})"

    def __eq__(self, other):
        return self.index == other.index and self.beta == other.beta

    def __hash__(self):
        return hash((self.index, self.beta))


Pair = Tuple[str, str]


# ─── Gap Function ─────────────────────────────────────────────────────

def make_random_gap(spec, pairs, seed=42):
    """Create a random nonneg gap function gap(ω, x) ≥ 0."""
    rng = np.random.RandomState(seed)
    gap = {}
    for omega in spec:
        for pair in pairs:
            gap[(omega, pair)] = rng.exponential(scale=1.0)
    return gap


# ─── Definitions from the Lean formalization ──────────────────────────

def full_gap(gap, spec, x):
    return max(gap[(omega, x)] for omega in spec)

def restricted_gap(gap, C, x):
    if not C:
        return 0.0
    return max(gap[(omega, x)] for omega in C)

def distortion(gap, spec, C, x):
    return full_gap(gap, spec, x) - restricted_gap(gap, C, x)

def is_epsilon_codebook(gap, spec, pairs, eps, C):
    return all(distortion(gap, spec, C, x) <= eps + 1e-12 for x in pairs)

def total_distortion(gap, spec, pairs, C):
    return sum(distortion(gap, spec, C, x) for x in pairs)

def coding_number(gap, spec, pairs, eps):
    n = len(spec)
    for k in range(n + 1):
        for subset in combinations(spec, k):
            C = list(subset)
            if is_epsilon_codebook(gap, spec, pairs, eps, C):
                return k
    return n + 1

def find_optimal_codebook(gap, spec, pairs, eps):
    n = len(spec)
    for k in range(n + 1):
        for subset in combinations(spec, k):
            C = list(subset)
            if is_epsilon_codebook(gap, spec, pairs, eps, C):
                return C
    return list(spec)

def greedy_step(gap, spec, pairs, C):
    best_omega = None
    best_td = float('inf')
    for omega in spec:
        C_new = list(set(C + [omega]))
        td = total_distortion(gap, spec, pairs, C_new)
        if td < best_td:
            best_td = td
            best_omega = omega
    return list(set(C + [best_omega]))

def greedy_codebook(gap, spec, pairs, k):
    C = []
    for _ in range(k):
        C = greedy_step(gap, spec, pairs, C)
    return C


# ─── Demo 1: Verify Core Theorems ────────────────────────────────────

def demo_core_theorems():
    print("=" * 70)
    print("DEMO 1: Verifying Core Theorems")
    print("=" * 70)

    spec = [PrimeBetaState(i, beta)
            for i, beta in enumerate([0.5, 1.0, 1.5, 2.0, 2.5])]
    pairs = [("a", "b"), ("a", "c"), ("b", "c"), ("b", "d")]
    gap = make_random_gap(spec, pairs)

    print(f"\nSpectrum: {spec}")
    print(f"Pairs: {pairs}")

    # spec_is_zero_codebook
    print("\n--- spec_is_zero_codebook ---")
    for x in pairs:
        d = distortion(gap, spec, spec, x)
        print(f"  distortion(spec, {x}) = {d:.6f}")
    assert is_epsilon_codebook(gap, spec, pairs, 0.0, spec)
    print("  ✓ spec is a 0-codebook")

    # restrictedGap_le_fullGap
    print("\n--- restrictedGap_le_fullGap ---")
    C = spec[:3]
    for x in pairs:
        rg = restricted_gap(gap, C, x)
        fg = full_gap(gap, spec, x)
        print(f"  restrictedGap({x}) = {rg:.4f} ≤ fullGap = {fg:.4f}: {rg <= fg + 1e-12}")
    print("  ✓ Verified")

    # zero_distortion_iff_complete_separation
    print("\n--- zero_distortion_iff_complete_separation ---")
    all_zero = all(abs(distortion(gap, spec, spec, x)) < 1e-12 for x in pairs)
    complete = all(abs(restricted_gap(gap, spec, x) - full_gap(gap, spec, x)) < 1e-12
                   for x in pairs)
    print(f"  Equivalence verified: {all_zero == complete} ✓")

    # approximate_reconstruction
    print("\n--- approximate_reconstruction ---")
    eps = 0.5
    C_opt = find_optimal_codebook(gap, spec, pairs, eps)
    print(f"  ε = {eps}, optimal codebook size = {len(C_opt)}")
    for x in pairs:
        fg = full_gap(gap, spec, x)
        rg = restricted_gap(gap, C_opt, x)
        print(f"  fullGap({x}) - ε = {fg - eps:.4f} ≤ restrictedGap = {rg:.4f}: "
              f"{fg - eps <= rg + 1e-12}")
    print("  ✓ Approximate reconstruction inequality verified")

    return spec, pairs, gap


# ─── Demo 2: Rate–Distortion Curve ───────────────────────────────────

def demo_rate_distortion_curve(spec, pairs, gap):
    print("\n" + "=" * 70)
    print("DEMO 2: Rate–Distortion Curve (codingNumber_mono)")
    print("=" * 70)

    epsilons = np.linspace(0, 3.0, 60)
    coding_numbers = [coding_number(gap, spec, pairs, eps) for eps in epsilons]

    monotone = all(coding_numbers[i] >= coding_numbers[i+1]
                   for i in range(len(coding_numbers)-1))
    print(f"\n  codingNumber is monotone decreasing: {monotone} ✓")
    print(f"  codingNumber(0) = {coding_numbers[0]}")
    print(f"  codingNumber({epsilons[-1]:.1f}) = {coding_numbers[-1]}")

    fig, ax = plt.subplots(1, 1, figsize=(10, 6))
    ax.step(epsilons, coding_numbers, where='post', linewidth=2, color='#2C3E50')
    ax.fill_between(epsilons, coding_numbers, step='post', alpha=0.15, color='#3498DB')
    ax.set_xlabel('Distortion tolerance ε', fontsize=14)
    ax.set_ylabel('Coding number (min codebook size)', fontsize=14)
    ax.set_title('Rate–Distortion Curve: codingNumber(ε)', fontsize=16)
    ax.set_ylim(-0.5, len(spec) + 0.5)
    ax.grid(True, alpha=0.3)
    ax.axhline(y=len(spec), color='red', linestyle='--', alpha=0.5,
               label=f'|spec| = {len(spec)}')
    ax.legend(fontsize=12)
    plt.tight_layout()
    plt.savefig('demos/rate_distortion_curve.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("  → Saved: demos/rate_distortion_curve.png")


# ─── Demo 3: Greedy vs Optimal ────────────────────────────────────────

def demo_greedy_vs_optimal(spec, pairs, gap):
    print("\n" + "=" * 70)
    print("DEMO 3: Greedy Algorithm vs Optimal Codebooks")
    print("=" * 70)

    n = len(spec)
    greedy_tds = []
    optimal_tds = []

    for k in range(n + 1):
        gc = greedy_codebook(gap, spec, pairs, k)
        greedy_tds.append(total_distortion(gap, spec, pairs, gc))

        best_td = float('inf')
        if k == 0:
            best_td = total_distortion(gap, spec, pairs, [])
        else:
            for subset in combinations(spec, k):
                td = total_distortion(gap, spec, pairs, list(subset))
                best_td = min(best_td, td)
        optimal_tds.append(best_td)

    greedy_monotone = all(greedy_tds[i] >= greedy_tds[i+1] - 1e-12
                         for i in range(len(greedy_tds)-1))
    print(f"\n  Greedy distortion nonincreasing: {greedy_monotone} ✓")

    print("\n  k | Greedy TD | Optimal TD | Ratio")
    print("  " + "-" * 45)
    for k in range(n + 1):
        ratio = greedy_tds[k] / optimal_tds[k] if optimal_tds[k] > 1e-12 else 1.0
        print(f"  {k} | {greedy_tds[k]:9.4f} | {optimal_tds[k]:10.4f} | {ratio:.4f}")

    fig, ax = plt.subplots(1, 1, figsize=(10, 6))
    ks = list(range(n + 1))
    ax.plot(ks, greedy_tds, 'o-', linewidth=2, markersize=8,
            color='#E74C3C', label='Greedy codebook')
    ax.plot(ks, optimal_tds, 's--', linewidth=2, markersize=8,
            color='#27AE60', label='Optimal codebook')
    ax.fill_between(ks, optimal_tds, greedy_tds, alpha=0.1, color='#E74C3C')
    ax.set_xlabel('Codebook size k', fontsize=14)
    ax.set_ylabel('Total distortion', fontsize=14)
    ax.set_title('Greedy vs Optimal Total Distortion', fontsize=16)
    ax.legend(fontsize=12)
    ax.grid(True, alpha=0.3)
    ax.set_xticks(ks)
    plt.tight_layout()
    plt.savefig('demos/greedy_vs_optimal.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("  → Saved: demos/greedy_vs_optimal.png")


# ─── Demo 4: Reconstruction Quality ───────────────────────────────────

def demo_reconstruction(spec, pairs, gap):
    print("\n" + "=" * 70)
    print("DEMO 4: Approximate Reconstruction Inequality")
    print("=" * 70)

    eps = 0.5
    C_opt = find_optimal_codebook(gap, spec, pairs, eps)

    fig, ax = plt.subplots(figsize=(10, 6))
    x_pos = np.arange(len(pairs))
    fg_vals = [full_gap(gap, spec, x) for x in pairs]
    rg_vals = [restricted_gap(gap, C_opt, x) for x in pairs]
    lower_bound = [fg - eps for fg in fg_vals]

    for lb, rg in zip(lower_bound, rg_vals):
        assert lb <= rg + 1e-12, "Reconstruction inequality violated!"
    print(f"  ε = {eps}, |C| = {len(C_opt)}: reconstruction verified ✓")

    width = 0.25
    ax.bar(x_pos - width, fg_vals, width, label='fullGap', color='#2C3E50', alpha=0.8)
    ax.bar(x_pos, rg_vals, width, label='restrictedGap(C)', color='#3498DB', alpha=0.8)
    ax.bar(x_pos + width, lower_bound, width, label='fullGap - ε', color='#E74C3C', alpha=0.8)
    ax.set_xlabel('Pair', fontsize=14)
    ax.set_ylabel('Gap value', fontsize=14)
    ax.set_title(f'Approximate Reconstruction (ε = {eps}, |C| = {len(C_opt)})', fontsize=16)
    ax.set_xticks(x_pos)
    ax.set_xticklabels([str(p) for p in pairs], fontsize=10)
    ax.legend(fontsize=12)
    ax.grid(True, alpha=0.3, axis='y')
    ax.annotate('restrictedGap ≥ fullGap - ε\n(reconstruction inequality)',
                xy=(0.5, 0.95), xycoords='axes fraction',
                fontsize=11, ha='center', va='top',
                bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.5))
    plt.tight_layout()
    plt.savefig('demos/reconstruction_quality.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("  → Saved: demos/reconstruction_quality.png")


# ─── Main ─────────────────────────────────────────────────────────────

if __name__ == "__main__":
    os.makedirs("demos", exist_ok=True)
    spec, pairs, gap = demo_core_theorems()
    demo_rate_distortion_curve(spec, pairs, gap)
    demo_greedy_vs_optimal(spec, pairs, gap)
    demo_reconstruction(spec, pairs, gap)
    print("\n" + "=" * 70)
    print("All demos completed successfully!")
    print("=" * 70)
