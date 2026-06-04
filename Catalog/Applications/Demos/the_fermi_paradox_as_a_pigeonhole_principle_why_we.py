#!/usr/bin/env python3
"""
Cascade Filter Demo: The Mathematics of Cosmic Silence

Demonstrates the key theorems from the Cascade Filter framework
applied to the Fermi paradox.
"""

import math
import random

def cascade_throughput(probs: list[float]) -> float:
    """Product of all stage probabilities."""
    result = 1.0
    for p in probs:
        result *= p
    return result

def expected_survivors(base_pop: float, probs: list[float]) -> float:
    """Expected survivors = base_population × throughput."""
    return base_pop * cascade_throughput(probs)

def cofactor(probs: list[float], i: int) -> float:
    """Product of all probabilities EXCEPT stage i."""
    result = 1.0
    for j, p in enumerate(probs):
        if j != i:
            result *= p
    return result

def drake_equation(R_star=1.5, f_p=0.5, n_e=0.01, f_l=0.01,
                   f_i=0.01, f_c=0.01, L=100) -> float:
    """Drake equation: expected detectable civilizations."""
    return R_star * f_p * n_e * f_l * f_i * f_c * L


# ──────────────────────────────────────────────────────────
# Example 1: Pessimistic Drake Equation
# ──────────────────────────────────────────────────────────
print("=" * 60)
print("EXAMPLE 1: Pessimistic Drake Equation")
print("=" * 60)

N = drake_equation()
print(f"Parameters: R*=1.5, f_p=0.5, n_e=0.01, f_l=0.01, f_i=0.01, f_c=0.01, L=100")
print(f"Drake N = {N:.2e}")
print(f"N < 1? {N < 1} ✓ (Theorem: pessimistic_drake_lt_one)")
print()

# ──────────────────────────────────────────────────────────
# Example 2: Cascade Filter Power Bound
# ──────────────────────────────────────────────────────────
print("=" * 60)
print("EXAMPLE 2: Uniform Power Bound (throughput_le_pow)")
print("=" * 60)

for n_stages in [3, 5, 7, 10, 15]:
    p = 0.1
    throughput = p ** n_stages
    print(f"  {n_stages} stages, each p=0.1: throughput ≤ {throughput:.2e}")

print()
print("With 7 stages (Drake) and p=0.1 each: throughput ≤ 10^{-7}")
print("This is the 'silence_of_uniform_filter' theorem in action.")
print()

# ──────────────────────────────────────────────────────────
# Example 3: Sensitivity Analysis (bottleneck_dominates)
# ──────────────────────────────────────────────────────────
print("=" * 60)
print("EXAMPLE 3: Sensitivity Analysis — Bottleneck Dominates")
print("=" * 60)

probs = [0.5, 0.8, 0.001, 0.3, 0.9, 0.7, 0.6]
print(f"Stage probabilities: {probs}")
print(f"Throughput: {cascade_throughput(probs):.6e}")
print()
print("Cofactors (sensitivity to each stage):")
for i in range(len(probs)):
    c = cofactor(probs, i)
    print(f"  Stage {i} (p={probs[i]}): cofactor = {c:.6e}")

bottleneck = min(range(len(probs)), key=lambda i: probs[i])
print(f"\nBottleneck: stage {bottleneck} (p={probs[bottleneck]})")
print(f"Bottleneck cofactor: {cofactor(probs, bottleneck):.6e}")
print(f"This is the LARGEST cofactor — improving the bottleneck helps most.")
print(f"(Theorem: bottleneck_dominates)")
print()

# ──────────────────────────────────────────────────────────
# Example 4: Exponential Silence (Phase Transition)
# ──────────────────────────────────────────────────────────
print("=" * 60)
print("EXAMPLE 4: Exponential Silence — Phase Transition")
print("=" * 60)

B = 1e22  # ~number of stars in observable universe
p = 0.1
print(f"Base population: B = {B:.0e}")
print(f"Per-stage probability: p = {p}")
print()

for n in range(1, 30):
    E = B * p**n
    marker = " ← SILENCE THRESHOLD" if n == 23 else ""
    if n <= 5 or n >= 20 or abs(n - 23) <= 2:
        print(f"  n={n:2d}: E[survivors] = {E:.2e}{marker}")
    elif n == 6:
        print(f"  ...")

print()
print(f"Critical stage count n* ≈ log(B)/log(1/p) = {math.log(B)/math.log(1/p):.1f}")
print(f"With n > n*, silence is guaranteed. (Theorem: exponential_silence)")
print()

# ──────────────────────────────────────────────────────────
# Example 5: Monte Carlo — Silence is Generic
# ──────────────────────────────────────────────────────────
print("=" * 60)
print("EXAMPLE 5: Monte Carlo — Log-Uniform Drake Parameters")
print("=" * 60)

random.seed(42)
N_SAMPLES = 1_000_000
n_silence = 0
n_factors = 7

for _ in range(N_SAMPLES):
    # Draw each Drake factor from log-uniform on [10^-6, 1]
    factors = [10 ** random.uniform(-6, 0) for _ in range(n_factors)]
    # Base rate ~ 1.5 (star formation × lifetime normalization)
    N_val = 1.5 * cascade_throughput(factors) * 1e10  # generous base
    if N_val < 1:
        n_silence += 1

p_silence = n_silence / N_SAMPLES
print(f"Samples: {N_SAMPLES:,}")
print(f"Fraction with N < 1 (silence): {p_silence:.4f} ({p_silence*100:.2f}%)")
print(f"Conjecture: P(silence) > 0.99 → {'CONFIRMED' if p_silence > 0.99 else 'REFUTED'}")
print()

# ──────────────────────────────────────────────────────────
# Example 6: Birthday Bound (Injection Count)
# ──────────────────────────────────────────────────────────
print("=" * 60)
print("EXAMPLE 6: Birthday Bound — Injection Count")
print("=" * 60)

def desc_factorial(n, k):
    result = 1
    for i in range(k):
        result *= (n - i)
    return result

for k in [2, 5, 10, 23]:
    n = 365
    injections = desc_factorial(n, k)
    total = n**k
    p_no_collision = injections / total
    p_collision = 1 - p_no_collision
    print(f"  k={k:2d} items in n={n} slots: P(collision) = {p_collision:.4f}")

print()
print("(Theorem: injection_count)")

# ──────────────────────────────────────────────────────────
# Summary
# ──────────────────────────────────────────────────────────
print()
print("=" * 60)
print("SUMMARY: The Fermi Paradox is Not a Paradox")
print("=" * 60)
print("""
The cascade filter framework shows that cosmic silence is the 
EXPECTED outcome, not a puzzle requiring exotic explanations:

1. Each Drake factor independently reduces probability (throughput_le_pow)
2. The bottleneck factor dominates sensitivity (bottleneck_dominates)
3. Enough stages guarantee silence exponentially (exponential_silence)
4. Conservative estimates give E[N] < 10^{-6} (pessimistic_drake_lt_one)
5. Silence is the generic outcome for uncertain parameters (Monte Carlo)

The Fermi paradox is the anti-pigeonhole principle in action:
too few civilizations, too many planets, too much space.
""")


#!/usr/bin/env python3
"""
Visualization: Cascade Filter Phase Transition

Shows how expected survivors decrease exponentially with the number of
filter stages, illustrating the phase transition from "many civilizations"
to "cosmic silence."
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

def cascade_expected(B: float, p: float, n_stages: np.ndarray) -> np.ndarray:
    return B * p ** n_stages

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Panel 1: Phase transition for different base populations
ax = axes[0]
p = 0.1
stages = np.arange(0, 30)
for log_B, color in [(5, '#2196F3'), (10, '#4CAF50'), (15, '#FF9800'), (22, '#F44336')]:
    B = 10.0 ** log_B
    E = cascade_expected(B, p, stages)
    n_star = int(np.ceil(log_B / np.log10(1/p)))
    ax.semilogy(stages, E, color=color, linewidth=2, label=f'B = 10$^{{{log_B}}}$')
    ax.axvline(n_star, color=color, linestyle=':', alpha=0.5)

ax.axhline(1.0, color='black', linestyle='--', linewidth=1, alpha=0.7, label='Silence threshold')
ax.set_xlabel('Number of filter stages (n)', fontsize=12)
ax.set_ylabel('Expected survivors E[N]', fontsize=12)
ax.set_title('Phase Transition to Silence\n(each stage p = 0.1)', fontsize=13)
ax.legend(fontsize=9)
ax.set_ylim(1e-10, 1e25)
ax.grid(True, alpha=0.3)

# Panel 2: Sensitivity analysis
ax = axes[1]
probs = [0.5, 0.8, 0.001, 0.3, 0.9, 0.7, 0.6]
labels = ['f_p', 'n_e', 'f_l', 'f_i', 'f_c', 'R*', 'L']
cofactors = []
for i in range(len(probs)):
    c = 1.0
    for j, p in enumerate(probs):
        if j != i:
            c *= p
    cofactors.append(c)

colors = ['#2196F3'] * len(probs)
bottleneck = np.argmax(cofactors)
colors[bottleneck] = '#F44336'

ax.barh(range(len(probs)), cofactors, color=colors, edgecolor='white', linewidth=0.5)
ax.set_yticks(range(len(probs)))
ax.set_yticklabels([f'{labels[i]} (p={probs[i]})' for i in range(len(probs))])
ax.set_xlabel('Cofactor (sensitivity)', fontsize=12)
ax.set_title('Sensitivity Dominance\n(red = bottleneck)', fontsize=13)
ax.set_xscale('log')
ax.grid(True, alpha=0.3, axis='x')

# Panel 3: Monte Carlo distribution
ax = axes[2]
np.random.seed(42)
n_samples = 100_000
n_factors = 7
log_products = np.zeros(n_samples)
for _ in range(n_factors):
    log_products += np.random.uniform(-6, 0, n_samples)

log_N = np.log10(1.5e10) + log_products
ax.hist(log_N, bins=100, density=True, color='#673AB7', alpha=0.7, edgecolor='white', linewidth=0.3)
ax.axvline(0, color='#F44336', linewidth=2, linestyle='--', label='N = 1 (silence threshold)')
fraction_above = np.mean(log_N > 0)
ax.set_xlabel('log₁₀(N)', fontsize=12)
ax.set_ylabel('Density', fontsize=12)
ax.set_title(f'Distribution of Drake N\n(log-uniform priors, P(N>1) = {fraction_above:.4f})', fontsize=13)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('cascade_filter_visualization.png', dpi=150, bbox_inches='tight')
print("Saved: cascade_filter_visualization.png")
