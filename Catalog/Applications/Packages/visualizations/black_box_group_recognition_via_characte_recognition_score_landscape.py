"""
Visualization: Recognition Score Landscape

This plot shows how the fingerprint loss (recognition score) varies across
candidate field sizes for a fixed true parameter pair. The true parameters
produce a sharp minimum at score=0, while all other candidates have positive
scores — this is the uniqueness theorem (true_params_unique_minimizer) in action.

Multiple curves show different true field sizes, demonstrating that each
creates a distinct, non-overlapping minimum.
"""

import matplotlib.pyplot as plt
import numpy as np


def mobius(n):
    if n <= 0:
        return 0
    if n == 1:
        return 1
    factors = 0
    d = 2
    temp = n
    while d * d <= temp:
        if temp % d == 0:
            temp //= d
            if temp % d == 0:
                return 0
            factors += 1
        d += 1
    if temp > 1:
        factors += 1
    return (-1) ** factors


def divisors(n):
    divs = []
    for d in range(1, int(n**0.5) + 1):
        if n % d == 0:
            divs.append(d)
            if d != n // d:
                divs.append(n // d)
    return sorted(divs)


def num_irreducible_monic(q, n):
    if n <= 0 or q <= 0:
        return 0
    total = sum(mobius(n // d) * q**d for d in divisors(n))
    return total // n


def irreducible_rate(q, n):
    if q <= 0 or n <= 0:
        return 0.0
    return num_irreducible_monic(q, n) / q**n


def split_rate(q, n):
    if q <= 0 or n <= 0:
        return 0.0
    if n > q:
        return 0.0
    result = 1.0
    for i in range(n):
        result *= (q - i) / q
    return result


# Parameters
n = 3  # fixed dimension
candidate_qs = list(range(2, 30))
true_qs = [2, 3, 5, 7, 11, 13]
colors = ['#e41a1c', '#377eb8', '#4daf4a', '#984ea3', '#ff7f00', '#a65628']

fig, axes = plt.subplots(1, 2, figsize=(16, 6))

# Left panel: Score landscape for irreducible rate only
ax1 = axes[0]
for idx, q_true in enumerate(true_qs):
    true_ir = irreducible_rate(q_true, n)
    scores = []
    for q_cand in candidate_qs:
        cand_ir = irreducible_rate(q_cand, n)
        score = (true_ir - cand_ir)**2
        scores.append(score)
    ax1.plot(candidate_qs, scores, 'o-', color=colors[idx],
             label=f'True q={q_true}', markersize=4, linewidth=1.5)
    # Mark the minimum
    min_idx = np.argmin(scores)
    ax1.plot(candidate_qs[min_idx], scores[min_idx], '*',
             color=colors[idx], markersize=15)

ax1.set_xlabel('Candidate field size q', fontsize=12)
ax1.set_ylabel('Score (irred rate only)', fontsize=12)
ax1.set_title(f'Score Landscape: Irreducible Rate (n={n})', fontsize=13, fontweight='bold')
ax1.legend(fontsize=9)
ax1.set_yscale('log')
ax1.set_ylim(bottom=1e-8)
ax1.grid(True, alpha=0.3)

# Right panel: Combined score (irred + split)
ax2 = axes[1]
for idx, q_true in enumerate(true_qs):
    true_ir = irreducible_rate(q_true, n)
    true_sr = split_rate(q_true, n)
    scores = []
    for q_cand in candidate_qs:
        cand_ir = irreducible_rate(q_cand, n)
        cand_sr = split_rate(q_cand, n)
        score = (true_ir - cand_ir)**2 + (true_sr - cand_sr)**2
        scores.append(score)
    ax2.plot(candidate_qs, scores, 'o-', color=colors[idx],
             label=f'True q={q_true}', markersize=4, linewidth=1.5)
    min_idx = np.argmin(scores)
    ax2.plot(candidate_qs[min_idx], scores[min_idx], '*',
             color=colors[idx], markersize=15)

ax2.set_xlabel('Candidate field size q', fontsize=12)
ax2.set_ylabel('Score (irred + split)', fontsize=12)
ax2.set_title(f'Score Landscape: Combined (n={n})', fontsize=13, fontweight='bold')
ax2.legend(fontsize=9)
ax2.set_yscale('log')
ax2.set_ylim(bottom=1e-8)
ax2.grid(True, alpha=0.3)

plt.suptitle('The True Parameters Uniquely Minimize the Fingerprint Loss',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_score_landscape.png', dpi=150, bbox_inches='tight')
print("Saved viz_score_landscape.png")
