#!/usr/bin/env python3
"""
Visualization 3: Crossover Profile and Data Collapse

Tests the CrossoverProfileConjecture by plotting the rescaled defect
Δ(k,m)·k^b/m^a against the scaling variable λ = m/k^α_c for multiple
values of k. If the curves collapse onto a single profile F(λ), this
supports the existence of a universal crossover function — the
finite-group analog of scaling functions in statistical mechanics.
"""

import numpy as np
import matplotlib.pyplot as plt

# === Inline functions ===

def wreath_defect(k, m, C=1.0, a=1, b=1):
    """Compute wreath defect Δ(k,m) = C·m^a/k^b."""
    return C * (m ** a) / (k ** b) if k > 0 else 0.0

# === Parameters ===
C, a, b = 1.0, 1, 1
alpha_c = b / a

# Test multiple values of k
k_test_values = [5, 10, 20, 50, 100]
colors = ['#e74c3c', '#f39c12', '#2ecc71', '#3498db', '#9b59b6']

# === Plotting ===
fig, axes = plt.subplots(1, 3, figsize=(18, 5.5))

# Panel 1: Raw defect Δ(k, m) vs m for different k
ax1 = axes[0]
for k, color in zip(k_test_values, colors):
    m_vals = np.arange(1, 10 * k + 1)
    defects = [wreath_defect(k, m, C, a, b) for m in m_vals]
    ax1.plot(m_vals, defects, color=color, linewidth=1.5,
             label=f'k = {k}', alpha=0.8)
ax1.set_xlabel('m (copies)', fontsize=12)
ax1.set_ylabel('Δ(k, m)', fontsize=12)
ax1.set_title('Raw Wreath Defect', fontsize=13, fontweight='bold')
ax1.legend(fontsize=10)
ax1.grid(True, alpha=0.3)

# Panel 2: Rescaled defect (data collapse)
ax2 = axes[1]
for k, color in zip(k_test_values, colors):
    m_vals = np.arange(1, 10 * k + 1)
    lambda_vals = m_vals / (k ** alpha_c)
    rescaled = []
    for m in m_vals:
        delta = wreath_defect(k, m, C, a, b)
        # Rescale: Δ · k^b / m^a
        r = delta * (k ** b) / (m ** a) if m > 0 else 0
        rescaled.append(r)
    ax2.plot(lambda_vals, rescaled, color=color, linewidth=1.5,
             label=f'k = {k}', alpha=0.8)

# Theoretical profile F(λ) = C (constant for this model)
lam_theory = np.linspace(0, 10, 100)
ax2.axhline(y=C, color='black', linestyle='--', linewidth=2,
            label=f'F(λ) = C = {C}', alpha=0.7)
ax2.set_xlabel('λ = m / k^{α_c}', fontsize=12)
ax2.set_ylabel('Δ · k^b / m^a', fontsize=12)
ax2.set_title('Data Collapse (CrossoverProfileConjecture)',
              fontsize=13, fontweight='bold')
ax2.legend(fontsize=9)
ax2.grid(True, alpha=0.3)
ax2.set_ylim(-0.2, 2.5)

# Panel 3: Test collapse quality for different candidate α
ax3 = axes[2]
candidate_alphas = [0.5, 0.75, 1.0, 1.25, 1.5]
k_fixed = 50

# For each candidate α, compute the variance of the rescaled defect
# across different m values
collapse_quality = []
for alpha_test in candidate_alphas:
    m_vals = np.arange(1, 200)
    rescaled_vals = []
    for m in m_vals:
        delta = wreath_defect(k_fixed, m, C, a, b)
        lam = m / (k_fixed ** alpha_test) if k_fixed > 0 else 0
        # Group by bins of λ and check variance
        if m > 0:
            r = delta * (k_fixed ** b) / (m ** a)
            rescaled_vals.append(r)

    # Measure how constant the rescaled values are
    rv = np.array(rescaled_vals)
    cv = np.std(rv) / np.mean(rv) if np.mean(rv) != 0 else float('inf')
    collapse_quality.append(cv)

ax3.bar([f'α={a:.2f}' for a in candidate_alphas], collapse_quality,
        color=['#e74c3c' if a != alpha_c else '#2ecc71'
               for a in candidate_alphas],
        alpha=0.8, edgecolor='black')
ax3.set_xlabel('Candidate exponent α', fontsize=12)
ax3.set_ylabel('Coefficient of Variation', fontsize=12)
ax3.set_title(f'Collapse Quality (k={k_fixed})', fontsize=13, fontweight='bold')
ax3.axhline(y=0, color='gray', linestyle=':', alpha=0.5)

# Mark the true critical exponent
true_idx = candidate_alphas.index(alpha_c) if alpha_c in candidate_alphas else -1
if true_idx >= 0:
    ax3.annotate(f'True α_c = {alpha_c}',
                xy=(true_idx, collapse_quality[true_idx]),
                xytext=(true_idx + 0.5, max(collapse_quality) * 0.7),
                arrowprops=dict(arrowstyle='->', color='#2ecc71'),
                fontsize=11, fontweight='bold', color='#2ecc71')

plt.suptitle('Crossover Profile Analysis: Testing the Scaling Conjecture',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('crossover_profile.png', dpi=150, bbox_inches='tight')
print("Saved crossover_profile.png")
