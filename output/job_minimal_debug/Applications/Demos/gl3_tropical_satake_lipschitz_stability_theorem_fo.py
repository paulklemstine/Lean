#!/usr/bin/env python3
"""
GL₃ Tropical Satake Score Stability — Interactive Demo

Demonstrates the perturbation-transfer principle for 3-class score classifiers:
if the original score map has pairwise margins > 2ε, then any ε-close perturbation
preserves all top-1, top-2, and pairwise decisions.

This Python code mirrors the formally verified Lean theorems in
  Bridges/GL3TropicalSatakeScoreStability.lean
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib.collections import PatchCollection

# ─── Core definitions (matching the Lean formalization) ─────────────────────

def score_sup_close(f, g, eps):
    """Check if two score maps are ε-close in sup-norm."""
    return np.all(np.abs(f - g) <= eps + 1e-12)

def pair_margin(scores, i, j):
    """Pairwise margin: scores[i] - scores[j]."""
    return scores[i] - scores[j]

def is_top1_winner(scores, i):
    """Check if class i is the strict top-1 winner."""
    return all(scores[j] < scores[i] for j in range(3) if j != i)

def in_top2(scores, i):
    """Check if class i is in the top-2 (beats at least one competitor)."""
    return any(scores[j] < scores[i] for j in range(3) if j != i)

def min_decisive_margin(scores):
    """Minimum margin among all decisive (strictly ordered) pairs."""
    margins = []
    for i in range(3):
        for j in range(3):
            if i != j and scores[i] > scores[j]:
                margins.append(scores[i] - scores[j])
    return min(margins) if margins else 0.0


# ─── Demo 1: Perturbation bound visualization ──────────────────────────────

def demo_perturbation_bound():
    """Visualize how pairwise margins change under perturbation."""
    np.random.seed(42)

    # Original scores for 3 classes
    f = np.array([5.0, 2.0, 0.5])
    print("=" * 60)
    print("DEMO 1: Pairwise Margin Perturbation Bound")
    print("=" * 60)
    print(f"\nOriginal scores: {f}")
    print(f"  Margin(0,1) = {pair_margin(f, 0, 1):.2f}")
    print(f"  Margin(0,2) = {pair_margin(f, 0, 2):.2f}")
    print(f"  Margin(1,2) = {pair_margin(f, 1, 2):.2f}")
    print(f"  Min decisive margin = {min_decisive_margin(f):.2f}")

    eps_values = np.linspace(0, 1.0, 200)
    n_trials = 500

    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    for ax_idx, (i, j) in enumerate([(0, 1), (0, 2), (1, 2)]):
        orig_margin = pair_margin(f, i, j)
        max_deviations = []
        all_perturbed_margins = []

        for eps in eps_values:
            worst_dev = 0
            for _ in range(n_trials):
                noise = np.random.uniform(-eps, eps, size=3)
                g = f + noise
                new_margin = pair_margin(g, i, j)
                dev = abs(new_margin - orig_margin)
                worst_dev = max(worst_dev, dev)
                all_perturbed_margins.append((eps, new_margin))
            max_deviations.append(worst_dev)

        ax = axes[ax_idx]
        ax.plot(eps_values, max_deviations, 'b-', linewidth=2, label='Max observed |Δmargin|')
        ax.plot(eps_values, 2 * eps_values, 'r--', linewidth=2, label='Theoretical bound 2ε')
        ax.set_xlabel('Perturbation ε')
        ax.set_ylabel('Max margin deviation')
        ax.set_title(f'Margin({i},{j}), original = {orig_margin:.1f}')
        ax.legend()
        ax.grid(True, alpha=0.3)

    plt.suptitle('Theorem: |pairMargin(f) - pairMargin(g)| ≤ 2ε', fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('Bridges/fig_perturbation_bound.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("\n→ Saved: Bridges/fig_perturbation_bound.png")


# ─── Demo 2: Top-1 stability regions ───────────────────────────────────────

def demo_top1_stability():
    """Show the decision boundary and the stability region."""
    print("\n" + "=" * 60)
    print("DEMO 2: Top-1 Winner Stability Under Perturbation")
    print("=" * 60)

    # Fix score[2] = 0, vary score[0] and score[1]
    n = 300
    s0 = np.linspace(-2, 4, n)
    s1 = np.linspace(-2, 4, n)
    S0, S1 = np.meshgrid(s0, s1)

    eps = 0.5
    # Winner under original scores
    winner = np.zeros_like(S0, dtype=int)
    stable = np.zeros_like(S0, dtype=bool)

    for ii in range(n):
        for jj in range(n):
            scores = np.array([S0[ii, jj], S1[ii, jj], 0.0])
            # Determine winner
            w = np.argmax(scores)
            winner[ii, jj] = w
            # Check stability: all margins > 2ε
            margins = [scores[w] - scores[k] for k in range(3) if k != w]
            stable[ii, jj] = all(m > 2 * eps for m in margins)

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    # Original decision regions
    cmap = plt.cm.Set1
    ax1.contourf(S0, S1, winner, levels=[-0.5, 0.5, 1.5, 2.5],
                 colors=['#ff7f7f', '#7fbf7f', '#7f7fff'], alpha=0.5)
    ax1.contour(S0, S1, winner, levels=[0.5, 1.5], colors='black', linewidths=2)
    ax1.set_xlabel('Score class 0')
    ax1.set_ylabel('Score class 1')
    ax1.set_title('Original Decision Regions\n(score class 2 = 0)')
    ax1.set_aspect('equal')
    ax1.grid(True, alpha=0.3)

    # Stability regions
    stability_map = np.where(stable, winner + 1, 0)
    colors_stable = ['#dddddd', '#ff4444', '#44aa44', '#4444ff']
    ax2.contourf(S0, S1, stability_map, levels=[-0.5, 0.5, 1.5, 2.5, 3.5],
                 colors=colors_stable, alpha=0.6)
    ax2.contour(S0, S1, winner, levels=[0.5, 1.5], colors='black', linewidths=2)
    ax2.set_xlabel('Score class 0')
    ax2.set_ylabel('Score class 1')
    ax2.set_title(f'Certified Stable Regions (ε = {eps})\n(gray = margin ≤ 2ε, unstable)')
    ax2.set_aspect('equal')
    ax2.grid(True, alpha=0.3)

    patches = [mpatches.Patch(color='#dddddd', label='Unstable (margin ≤ 2ε)'),
               mpatches.Patch(color='#ff4444', label='Class 0 certified'),
               mpatches.Patch(color='#44aa44', label='Class 1 certified'),
               mpatches.Patch(color='#4444ff', label='Class 2 certified')]
    ax2.legend(handles=patches, loc='upper left', fontsize=8)

    plt.suptitle('Top-1 Stability: decisions preserved when all margins > 2ε',
                 fontsize=13, fontweight='bold')
    plt.tight_layout()
    plt.savefig('Bridges/fig_top1_stability.png', dpi=150, bbox_inches='tight')
    plt.close()
    print(f"\n→ Saved: Bridges/fig_top1_stability.png")
    print(f"  ε = {eps}, stability requires all pairwise margins > {2*eps}")


# ─── Demo 3: Monte Carlo verification ──────────────────────────────────────

def demo_monte_carlo_verification():
    """Empirically verify the stability theorems with random perturbations."""
    print("\n" + "=" * 60)
    print("DEMO 3: Monte Carlo Verification of Stability Theorems")
    print("=" * 60)

    np.random.seed(123)
    n_samples = 100_000

    # Original scores with known margins
    f = np.array([4.0, 1.5, 0.0])
    eps = 0.5
    min_margin = min_decisive_margin(f)

    print(f"\nOriginal scores: {f}")
    print(f"Min decisive margin: {min_margin:.2f}")
    print(f"Perturbation bound ε: {eps}")
    print(f"2ε = {2*eps:.2f}")
    print(f"Margin > 2ε? {min_margin > 2*eps}")

    # Generate random perturbations
    noise = np.random.uniform(-eps, eps, size=(n_samples, 3))
    perturbed = f + noise

    # Check top-1 stability
    orig_winner = np.argmax(f)
    perturbed_winners = np.argmax(perturbed, axis=1)
    top1_preserved = np.sum(perturbed_winners == orig_winner)

    # Check pairwise preference stability
    pairwise_preserved = 0
    for trial in range(n_samples):
        g = perturbed[trial]
        all_ok = True
        for i in range(3):
            for j in range(3):
                if i != j and f[i] > f[j]:
                    if g[i] <= g[j]:
                        all_ok = False
        if all_ok:
            pairwise_preserved += 1

    # Check top-2 stability
    orig_top2 = set(i for i in range(3) if in_top2(f, i))
    top2_preserved = 0
    for trial in range(n_samples):
        g = perturbed[trial]
        new_top2 = set(i for i in range(3) if in_top2(g, i))
        if new_top2 == orig_top2:
            top2_preserved += 1

    print(f"\nResults over {n_samples:,} random ε-perturbations:")
    print(f"  Top-1 winner preserved: {top1_preserved}/{n_samples} "
          f"({100*top1_preserved/n_samples:.1f}%)")
    print(f"  All pairwise preferences preserved: {pairwise_preserved}/{n_samples} "
          f"({100*pairwise_preserved/n_samples:.1f}%)")
    print(f"  Top-2 set preserved: {top2_preserved}/{n_samples} "
          f"({100*top2_preserved/n_samples:.1f}%)")

    if min_margin > 2 * eps:
        print("\n✓ Since min margin > 2ε, the formal theorem guarantees 100% preservation.")
        assert top1_preserved == n_samples, "Top-1 should be 100% preserved!"
        assert pairwise_preserved == n_samples, "Pairwise should be 100% preserved!"
        assert top2_preserved == n_samples, "Top-2 should be 100% preserved!"
        print("  All Monte Carlo trials confirm the theorem. ✓")

    # Now test with tighter margins
    print("\n--- Testing near-boundary case ---")
    f2 = np.array([2.0, 1.1, 0.0])
    min_margin2 = min_decisive_margin(f2)
    print(f"Scores: {f2}, min margin = {min_margin2:.2f}, 2ε = {2*eps:.2f}")
    print(f"Margin > 2ε? {min_margin2 > 2*eps}")

    noise2 = np.random.uniform(-eps, eps, size=(n_samples, 3))
    perturbed2 = f2 + noise2
    orig_winner2 = np.argmax(f2)
    top1_preserved2 = np.sum(np.argmax(perturbed2, axis=1) == orig_winner2)
    print(f"Top-1 preserved: {top1_preserved2}/{n_samples} "
          f"({100*top1_preserved2/n_samples:.1f}%)")
    print(f"  (Not guaranteed since min margin = {min_margin2:.2f} ≤ 2ε = {2*eps:.2f})")


# ─── Demo 4: Application to quantized score pipelines ──────────────────────

def demo_quantization_pipeline():
    """Show how quantization of scores is handled by the stability theorem."""
    print("\n" + "=" * 60)
    print("DEMO 4: Application — Quantized Score Pipeline")
    print("=" * 60)

    # Simulate a "tropical Satake" score function (additive separable)
    def tropical_satake_score(x, edge1, edge2):
        """Score(x) = edge1(x[0]) + edge2(x[1]) for each class."""
        return np.array([
            edge1[0](x[0]) + edge2[0](x[1]),
            edge1[1](x[0]) + edge2[1](x[1]),
            edge1[2](x[0]) + edge2[2](x[1]),
        ])

    # Define edge functions (piecewise linear for simplicity)
    edge1 = [lambda t: 3*t + 1, lambda t: t + 0.5, lambda t: 0.2*t]
    edge2 = [lambda t: 2*t, lambda t: 1.5*t + 1, lambda t: 0.5*t + 0.3]

    # Test point
    x = np.array([1.0, 0.8])
    f = tropical_satake_score(x, edge1, edge2)
    print(f"\nInput: x = {x}")
    print(f"Exact scores: {f}")
    print(f"Top-1 winner: class {np.argmax(f)}")

    # Quantize to fixed-point with different bit widths
    print("\nQuantization test (rounding to fixed-point):")
    for bits in [8, 6, 4, 3]:
        scale = 2**bits
        f_quant = np.round(f * scale) / scale
        quant_error = np.max(np.abs(f - f_quant))
        quant_winner = np.argmax(f_quant)
        margin = min_decisive_margin(f)

        stable = margin > 2 * quant_error
        print(f"  {bits}-bit: quantized={f_quant}, "
              f"max_error={quant_error:.4f}, "
              f"2·error={2*quant_error:.4f}, "
              f"min_margin={margin:.4f}, "
              f"{'STABLE ✓' if stable else 'UNSTABLE ✗'} "
              f"(winner={quant_winner})")


# ─── Demo 5: Stability margin heatmap ──────────────────────────────────────

def demo_stability_heatmap():
    """Heatmap of maximum tolerable ε for each score configuration."""
    print("\n" + "=" * 60)
    print("DEMO 5: Maximum Tolerable Perturbation Heatmap")
    print("=" * 60)

    n = 200
    s0 = np.linspace(0, 5, n)
    s1 = np.linspace(0, 5, n)
    S0, S1 = np.meshgrid(s0, s1)

    max_eps = np.zeros_like(S0)

    for ii in range(n):
        for jj in range(n):
            scores = np.array([S0[ii, jj], S1[ii, jj], 1.0])
            margin = min_decisive_margin(scores)
            max_eps[ii, jj] = margin / 2  # max ε such that 2ε < margin

    fig, ax = plt.subplots(figsize=(8, 7))
    im = ax.pcolormesh(S0, S1, max_eps, cmap='viridis', shading='auto')
    ax.contour(S0, S1, np.argmax(np.stack([S0, S1, np.ones_like(S0)], axis=-1), axis=-1),
               levels=[0.5, 1.5], colors='white', linewidths=2, linestyles='--')
    plt.colorbar(im, ax=ax, label='Max tolerable ε (= min_margin / 2)')
    ax.set_xlabel('Score class 0')
    ax.set_ylabel('Score class 1')
    ax.set_title('Maximum Perturbation for Certified Stability\n(score class 2 = 1.0, white = decision boundaries)')
    plt.tight_layout()
    plt.savefig('Bridges/fig_stability_heatmap.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("→ Saved: Bridges/fig_stability_heatmap.png")


# ─── Main ───────────────────────────────────────────────────────────────────

if __name__ == '__main__':
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  GL₃ Tropical Satake Score Stability — Python Demo      ║")
    print("║  Companion to Bridges/GL3TropicalSatakeScoreStability.lean ║")
    print("╚══════════════════════════════════════════════════════════╝")

    demo_perturbation_bound()
    demo_top1_stability()
    demo_monte_carlo_verification()
    demo_quantization_pipeline()
    demo_stability_heatmap()

    print("\n" + "=" * 60)
    print("All demos complete.")
    print("=" * 60)
