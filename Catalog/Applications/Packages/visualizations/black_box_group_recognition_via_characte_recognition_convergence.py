"""
Visualization: Recognition Accuracy vs Sample Size

This plot shows how recognition accuracy improves with the number of
characteristic polynomial samples (k). It tests the main conjecture
that k=20 suffices for reliable identification.

Multiple curves show different (n, q) parameter pairs. The horizontal
dashed line at 90% marks the conjecture threshold.
"""

import matplotlib.pyplot as plt
import numpy as np
from scipy.stats import binom  # type: ignore


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


def simulate_recognition_accuracy(n_true, q_true, k, num_trials=500,
                                   candidate_qs=None):
    """Simulate recognition accuracy using binomial sampling model.

    For each trial:
    1. Draw num_irred ~ Binomial(k, true_irred_rate)
    2. Draw num_split ~ Binomial(k, true_split_rate)
    3. Score all candidate q's
    4. Check if best candidate is q_true
    """
    if candidate_qs is None:
        candidate_qs = [2, 3, 5, 7, 11, 13]

    true_ir = irreducible_rate(q_true, n_true)
    true_sr = split_rate(q_true, n_true)
    rng = np.random.default_rng(42 + n_true * 100 + q_true * 10 + k)

    successes = 0
    for _ in range(num_trials):
        emp_irred = rng.binomial(k, min(true_ir, 1.0)) / k
        emp_split = rng.binomial(k, min(true_sr, 1.0)) / k

        best_q = None
        best_score = float('inf')
        for q_cand in candidate_qs:
            cand_ir = irreducible_rate(q_cand, n_true)
            cand_sr = split_rate(q_cand, n_true)
            score = (emp_irred - cand_ir)**2 + (emp_split - cand_sr)**2
            if score < best_score:
                best_score = score
                best_q = q_cand

        if best_q == q_true:
            successes += 1

    return successes / num_trials


# Parameters
ks = [3, 5, 8, 10, 15, 20, 30, 50, 75, 100, 150, 200]
test_cases = [
    (2, 2, '#e41a1c', 's'),
    (2, 5, '#377eb8', 'o'),
    (3, 3, '#4daf4a', '^'),
    (3, 7, '#984ea3', 'D'),
    (4, 5, '#ff7f00', 'v'),
    (5, 2, '#a65628', 'p'),
]

fig, ax = plt.subplots(figsize=(12, 7))

for n_true, q_true, color, marker in test_cases:
    accuracies = []
    for k in ks:
        acc = simulate_recognition_accuracy(n_true, q_true, k, num_trials=500)
        accuracies.append(acc)
    ax.plot(ks, accuracies, f'{marker}-', color=color,
            label=f'GL_{n_true}(F_{q_true})', markersize=7, linewidth=2)

# Add threshold lines
ax.axhline(y=0.9, color='gray', linestyle='--', linewidth=1.5, alpha=0.7,
           label='90% threshold')
ax.axvline(x=20, color='gray', linestyle=':', linewidth=1.5, alpha=0.7,
           label='k=20 conjecture')

ax.set_xlabel('Number of samples (k)', fontsize=13)
ax.set_ylabel('Recognition accuracy', fontsize=13)
ax.set_title('Recognition Accuracy vs Sample Size:\n'
             'How Many Characteristic Polynomials Suffice?',
             fontsize=14, fontweight='bold')
ax.legend(fontsize=10, loc='lower right')
ax.set_ylim(-0.05, 1.05)
ax.set_xlim(0, max(ks) + 5)
ax.grid(True, alpha=0.3)

# Add annotation
ax.annotate('Conjecture: k=20 suffices\nfor ≥90% accuracy',
            xy=(20, 0.9), xytext=(60, 0.5),
            fontsize=11, ha='center',
            arrowprops=dict(arrowstyle='->', color='gray'),
            bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow'))

plt.tight_layout()
plt.savefig('viz_convergence.png', dpi=150, bbox_inches='tight')
print("Saved viz_convergence.png")
