#!/usr/bin/env python3
"""
Demo: The Unreasonable Effectiveness of Wrong Theories
Numerical experiments illustrating perturbation theory on theory space.
"""

import numpy as np
from typing import Tuple, List


def perturbation_partial_sum(base: float, corrections: np.ndarray,
                              coupling: float, order: int) -> float:
    """Compute the partial sum of a perturbation series at given order."""
    result = base
    for k in range(order):
        result += coupling ** (k + 1) * corrections[k]
    return result


def truth_value(base: float, corrections: np.ndarray,
                coupling: float) -> float:
    """Compute the 'truth' (full series sum) for a convergent perturbation theory."""
    n = len(corrections)
    return perturbation_partial_sum(base, corrections, coupling, n)


def truncation_error_bound(M: float, coupling: float, order: int) -> float:
    """Compute the truncation error bound M * |ε|^(n+1) / (1 - |ε|)."""
    eps = abs(coupling)
    if eps >= 1:
        return float('inf')
    return M * eps ** (order + 1) / (1 - eps)


def find_optimal_truncation(base: float, corrections: np.ndarray,
                             coupling: float) -> Tuple[int, float]:
    """Find the optimal truncation order (minimizing error)."""
    true_val = truth_value(base, corrections, coupling)
    best_order = 0
    best_error = abs(true_val - base)
    for n in range(1, len(corrections) + 1):
        pred = perturbation_partial_sum(base, corrections, coupling, n)
        error = abs(true_val - pred)
        if error <= best_error:
            best_error = error
            best_order = n
    return best_order, best_error


# ============================================================
# Demo 1: Convergence of the Wrongness Series
# ============================================================
print("=" * 60)
print("Demo 1: Convergence of the Wrongness Series")
print("=" * 60)

np.random.seed(42)
base = 1.0
coupling = 0.3
corrections = np.random.uniform(-5, 5, 50)
M = np.max(np.abs(corrections))

print(f"\nBase prediction: {base:.4f}")
print(f"Coupling parameter: {coupling}")
print(f"Max correction magnitude M: {M:.4f}")
print(f"\nTruncation order | Partial sum | Error | Error bound")
print("-" * 60)

true_val = truth_value(base, corrections, coupling)
for n in [0, 1, 2, 3, 5, 10, 20, 50]:
    pred = perturbation_partial_sum(base, corrections, coupling, n)
    error = abs(true_val - pred)
    bound = truncation_error_bound(M, coupling, n)
    print(f"  {n:14d} | {pred:11.6f} | {error:.2e} | {bound:.2e}")

print(f"\nTruth value (full series): {true_val:.6f}")


# ============================================================
# Demo 2: Approximation Overshoot
# ============================================================
print("\n" + "=" * 60)
print("Demo 2: Approximation Overshoot — When Wrong Beats Right")
print("=" * 60)

print("\nWhen the first correction overshoots, the base theory wins:")
print(f"{'c1':>8} {'c2':>8} {'truth':>8} {'base_err':>10} {'corr_err':>10} {'winner':>8}")
print("-" * 60)

test_cases = [
    (10.0, -9.5),   # Massive overshoot
    (1.0, -0.8),    # Moderate overshoot
    (0.5, -0.4),    # Small overshoot
    (2.0, -1.5),    # Significant overshoot
    (0.3, 0.2),     # Same sign — correction helps
]

for c1, c2 in test_cases:
    truth_val = c1 + c2  # truth - base = c1 + c2
    base_err = abs(c1 + c2)
    corr_err = abs(c2)
    winner = "base" if base_err <= corr_err else "corrected"
    opposite = c1 * c2 <= 0
    overshoot = abs(c1) <= 2 * abs(c2)
    theorem_applies = opposite and overshoot
    note = " (theorem applies)" if theorem_applies else ""
    print(f"{c1:8.2f} {c2:8.2f} {truth_val:8.2f} {base_err:10.4f} "
          f"{corr_err:10.4f} {winner:>8}{note}")


# ============================================================
# Demo 3: Testing the Asymptotic Wrongness Conjecture
# ============================================================
print("\n" + "=" * 60)
print("Demo 3: Testing the Asymptotic Wrongness Conjecture")
print("=" * 60)

n_trials = 100000
max_ratio = 0.0
conjecture_holds = 0
max_terms = 50

for trial in range(n_trials):
    coupling = np.random.uniform(-0.5, 0.5)
    if abs(coupling) < 0.01:
        coupling = 0.1

    # Generate alternating corrections
    magnitudes = np.random.uniform(0.1, 10, max_terms)
    corrections = np.array([
        magnitudes[k] * (-1)**k for k in range(max_terms)
    ])

    base = 0.0
    true_val = truth_value(base, corrections, coupling)

    # Find optimal truncation
    opt_order, opt_error = find_optimal_truncation(base, corrections, coupling)
    base_error = abs(true_val - base)

    if opt_error > 1e-15:  # Avoid division by near-zero
        ratio = base_error / opt_error
        max_ratio = max(max_ratio, ratio)
        if ratio <= 2.0:
            conjecture_holds += 1
        else:
            print(f"  COUNTEREXAMPLE at trial {trial}: ratio = {ratio:.6f}")
    else:
        conjecture_holds += 1

print(f"\nTrials: {n_trials}")
print(f"Conjecture holds: {conjecture_holds}/{n_trials}")
print(f"Maximum ratio observed: {max_ratio:.6f}")
print(f"Conjecture bound: 2.0")
print(f"Result: {'SUPPORTED' if conjecture_holds == n_trials else 'REFUTED'}")


# ============================================================
# Demo 4: Phenomenon Selection
# ============================================================
print("\n" + "=" * 60)
print("Demo 4: Phenomenon Selection — Finding the Sweet Spot")
print("=" * 60)

N_phenomena = 20
coupling = 0.2
n_terms = 30
truncation_order = 3

print(f"\n{N_phenomena} phenomena, coupling = {coupling}, truncated at order {truncation_order}")
print(f"\n{'Phenomenon':>10} {'Truth':>10} {'Prediction':>10} {'Error':>10}")
print("-" * 45)

errors = []
for i in range(N_phenomena):
    np.random.seed(100 + i)
    corrections = np.random.uniform(-5, 5, n_terms)
    base = 0.0
    true_val = truth_value(base, corrections, coupling)
    pred = perturbation_partial_sum(base, corrections, coupling, truncation_order)
    error = abs(true_val - pred)
    errors.append(error)
    print(f"{i+1:10d} {true_val:10.4f} {pred:10.4f} {error:10.6f}")

avg_error = np.mean(errors)
min_error_idx = np.argmin(errors)
print(f"\nAverage error: {avg_error:.6f}")
print(f"Best phenomenon: #{min_error_idx + 1} with error {errors[min_error_idx]:.6f}")
print(f"Best error ≤ average? {errors[min_error_idx] <= avg_error} ✓ (Theorem guaranteed)")


if __name__ == "__main__":
    print("\n\nAll demos completed successfully.")


#!/usr/bin/env python3
"""
Visualization: Testing the Asymptotic Wrongness Conjecture
Histogram of base_error / optimal_error ratios for alternating series.
"""
import numpy as np
import matplotlib.pyplot as plt


def perturbation_partial_sum(base, corrections, coupling, order):
    result = base
    for k in range(min(order, len(corrections))):
        result += coupling ** (k + 1) * corrections[k]
    return result


np.random.seed(42)
n_trials = 50000
max_terms = 50
ratios = []

for _ in range(n_trials):
    coupling = np.random.uniform(-0.5, 0.5)
    if abs(coupling) < 0.01:
        coupling = 0.1

    magnitudes = np.random.uniform(0.1, 10, max_terms)
    corrections = np.array([magnitudes[k] * (-1)**k for k in range(max_terms)])

    base = 0.0
    truth = perturbation_partial_sum(base, corrections, coupling, max_terms)
    base_error = abs(truth - base)

    best_error = base_error
    for n in range(1, max_terms + 1):
        pred = perturbation_partial_sum(base, corrections, coupling, n)
        err = abs(truth - pred)
        best_error = min(best_error, err)

    if best_error > 1e-15:
        ratios.append(base_error / best_error)

ratios = np.array(ratios)

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Histogram
ax1 = axes[0]
ax1.hist(ratios, bins=100, color='#4dabf7', edgecolor='white', alpha=0.8,
         density=True)
ax1.axvline(x=2.0, color='red', linestyle='--', linewidth=2,
            label=f'Conjecture bound = 2')
ax1.axvline(x=np.max(ratios), color='orange', linestyle='-', linewidth=2,
            label=f'Max observed = {np.max(ratios):.4f}')
ax1.set_xlabel('Ratio: base error / optimal error', fontsize=12)
ax1.set_ylabel('Density', fontsize=12)
ax1.set_title('Asymptotic Wrongness Conjecture Test', fontsize=14)
ax1.legend(fontsize=10)
ax1.grid(True, alpha=0.3)

# CDF
ax2 = axes[1]
sorted_ratios = np.sort(ratios)
cdf = np.arange(1, len(sorted_ratios) + 1) / len(sorted_ratios)
ax2.plot(sorted_ratios, cdf, 'b-', linewidth=2)
ax2.axvline(x=2.0, color='red', linestyle='--', linewidth=2,
            label='Conjecture bound = 2')
ax2.set_xlabel('Ratio: base error / optimal error', fontsize=12)
ax2.set_ylabel('CDF', fontsize=12)
ax2.set_title('Cumulative Distribution of Ratios', fontsize=14)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)

stats_text = (f'Mean: {np.mean(ratios):.4f}\n'
              f'Median: {np.median(ratios):.4f}\n'
              f'Max: {np.max(ratios):.4f}\n'
              f'% ≤ 2.0: {100 * np.mean(ratios <= 2.0):.2f}%')
ax2.text(0.05, 0.95, stats_text, transform=ax2.transAxes, fontsize=10,
         verticalalignment='top', bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.5))

plt.suptitle(f'Testing with {n_trials} random alternating perturbation series',
             fontsize=15, y=1.02)
plt.tight_layout()
plt.savefig('conjecture_plot.png', dpi=150, bbox_inches='tight')
plt.close()
print(f"Saved conjecture_plot.png")
print(f"Max ratio: {np.max(ratios):.6f}")
print(f"Conjecture {'SUPPORTED' if np.max(ratios) <= 2.0 else 'REFUTED'}")


#!/usr/bin/env python3
"""
Visualization: Convergence of the Wrongness Series
Shows how partial sums of the perturbation series converge to truth.
"""
import numpy as np
import matplotlib.pyplot as plt


def perturbation_partial_sum(base, corrections, coupling, order):
    result = base
    for k in range(min(order, len(corrections))):
        result += coupling ** (k + 1) * corrections[k]
    return result


def truncation_error_bound(M, coupling, order):
    eps = abs(coupling)
    if eps >= 1:
        return float('inf')
    return M * eps ** (order + 1) / (1 - eps)


np.random.seed(42)
base = 1.0
coupling = 0.3
n_terms = 40
corrections = np.random.uniform(-5, 5, n_terms)
M = np.max(np.abs(corrections))

truth = perturbation_partial_sum(base, corrections, coupling, n_terms)
orders = range(n_terms + 1)
partial_sums = [perturbation_partial_sum(base, corrections, coupling, n) for n in orders]
errors = [abs(truth - ps) for ps in partial_sums]
bounds = [truncation_error_bound(M, coupling, n) for n in orders]

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Plot 1: Partial sums convergence
ax1 = axes[0]
ax1.plot(list(orders), partial_sums, 'b.-', markersize=4, label='Partial sum $T_n$')
ax1.axhline(y=truth, color='r', linestyle='--', linewidth=2, label=f'Truth $T^* = {truth:.4f}$')
ax1.fill_between(list(orders),
                  [truth - b for b in bounds],
                  [truth + b for b in bounds],
                  alpha=0.15, color='green', label='Error bound envelope')
ax1.set_xlabel('Truncation order $n$', fontsize=12)
ax1.set_ylabel('Prediction', fontsize=12)
ax1.set_title('Convergence of Perturbation Series', fontsize=14)
ax1.legend(fontsize=10)
ax1.grid(True, alpha=0.3)

# Plot 2: Error decay (log scale)
ax2 = axes[1]
ax2.semilogy(list(orders), [max(e, 1e-16) for e in errors], 'b.-', markersize=4,
             label='Actual error $|T^* - T_n|$')
ax2.semilogy(list(orders), bounds, 'r--', linewidth=2,
             label='Bound $M|\\varepsilon|^{n+1}/(1-|\\varepsilon|)$')
ax2.set_xlabel('Truncation order $n$', fontsize=12)
ax2.set_ylabel('Error (log scale)', fontsize=12)
ax2.set_title('Exponential Decay of Truncation Error', fontsize=14)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)

plt.suptitle(f'Perturbation Theory: $\\varepsilon = {coupling}$, $M = {M:.2f}$',
             fontsize=15, y=1.02)
plt.tight_layout()
plt.savefig('convergence_plot.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved convergence_plot.png")


#!/usr/bin/env python3
"""
Visualization: Approximation Overshoot Regions
Shows when the base theory outperforms the corrected theory in (c1, c2) space.
"""
import numpy as np
import matplotlib.pyplot as plt
from matplotlib.colors import ListedColormap


def compute_winner(c1, c2):
    """Returns 1 if base wins, 0 if corrected wins, 0.5 if tie."""
    base_err = abs(c1 + c2)
    corr_err = abs(c2)
    if base_err < corr_err - 1e-12:
        return 1.0
    elif corr_err < base_err - 1e-12:
        return 0.0
    else:
        return 0.5


def theorem_applies(c1, c2):
    """Check if the Approximation Overshoot Theorem applies."""
    return c1 * c2 <= 0 and abs(c1) <= 2 * abs(c2)


resolution = 500
c_range = np.linspace(-5, 5, resolution)
C1, C2 = np.meshgrid(c_range, c_range)

# Compute winner at each point
winners = np.vectorize(compute_winner)(C1, C2)
theorem_region = np.vectorize(theorem_applies)(C1, C2).astype(float)

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Plot 1: Who wins?
cmap1 = ListedColormap(['#ff6b6b', '#f0f0f0', '#4dabf7'])
ax1 = axes[0]
im1 = ax1.contourf(C1, C2, winners, levels=[-0.1, 0.25, 0.75, 1.1],
                     colors=['#ff6b6b', '#f0f0f0', '#4dabf7'])
ax1.set_xlabel('$c_1$ (first correction)', fontsize=12)
ax1.set_ylabel('$c_2$ (second correction)', fontsize=12)
ax1.set_title('Who Wins? Base Theory vs Corrected Theory', fontsize=14)
ax1.axhline(0, color='black', linewidth=0.5)
ax1.axvline(0, color='black', linewidth=0.5)

# Add legend
from matplotlib.patches import Patch
legend_elements = [
    Patch(facecolor='#4dabf7', label='Base theory wins'),
    Patch(facecolor='#ff6b6b', label='Corrected theory wins'),
    Patch(facecolor='#f0f0f0', label='Tie'),
]
ax1.legend(handles=legend_elements, loc='upper left', fontsize=9)

# Plot 2: Theorem coverage
ax2 = axes[1]
ax2.contourf(C1, C2, winners, levels=[-0.1, 0.25, 0.75, 1.1],
              colors=['#ff6b6b', '#f0f0f0', '#4dabf7'], alpha=0.3)
ax2.contour(C1, C2, theorem_region, levels=[0.5], colors=['green'],
             linewidths=2)
ax2.contourf(C1, C2, theorem_region * winners, levels=[0.5, 1.1],
              colors=['#2ecc71'], alpha=0.5)
ax2.set_xlabel('$c_1$ (first correction)', fontsize=12)
ax2.set_ylabel('$c_2$ (second correction)', fontsize=12)
ax2.set_title('Overshoot Theorem Coverage', fontsize=14)
ax2.axhline(0, color='black', linewidth=0.5)
ax2.axvline(0, color='black', linewidth=0.5)

legend_elements2 = [
    Patch(facecolor='#2ecc71', alpha=0.7, label='Theorem guarantees base wins'),
    Patch(facecolor='#4dabf7', alpha=0.3, label='Base wins (all cases)'),
    Patch(facecolor='#ff6b6b', alpha=0.3, label='Corrected wins'),
]
ax2.legend(handles=legend_elements2, loc='upper left', fontsize=9)

plt.suptitle('The Unreasonable Effectiveness of Wrong Theories', fontsize=15, y=1.02)
plt.tight_layout()
plt.savefig('overshoot_plot.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved overshoot_plot.png")
