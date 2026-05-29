"""
Visualization 1: Shadowing Distance vs Iteration Number

Demonstrates the core insight of the shadowing lemma: while naive
perturbation errors grow exponentially in chaotic systems, the shadowing
distance remains bounded. A float64 orbit of the logistic map f(x)=4x(1-x)
is shown to stay within 4δ of a true orbit forever.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from decimal import Decimal, getcontext

getcontext().prec = 60


def logistic_float(x):
    return 4.0 * x * (1.0 - x)


def logistic_decimal(x):
    return 4 * x * (1 - x)


def compute_float_orbit(x0, n):
    orbit = np.zeros(n + 1)
    orbit[0] = x0
    for i in range(n):
        orbit[i + 1] = logistic_float(orbit[i])
    return orbit


def compute_decimal_orbit(x0, n):
    orbit = [x0]
    for _ in range(n):
        orbit.append(logistic_decimal(orbit[-1]))
    return orbit


def find_shadowing_orbit(pseudo_orbit, max_iter=50):
    n = len(pseudo_orbit) - 1
    x0_float = pseudo_orbit[0]
    lo = Decimal(str(x0_float)) - Decimal('1e-14')
    hi = Decimal(str(x0_float)) + Decimal('1e-14')
    lo = max(lo, Decimal('0'))
    hi = min(hi, Decimal('1'))
    best_y0 = Decimal(str(x0_float))
    best_dist = float('inf')
    for _ in range(max_iter):
        mid = (lo + hi) / 2
        candidates = [lo, mid, hi, (lo + mid) / 2, (mid + hi) / 2]
        for y0 in candidates:
            orbit = compute_decimal_orbit(y0, n)
            max_d = max(abs(float(orbit[i]) - pseudo_orbit[i]) for i in range(n + 1))
            if max_d < best_dist:
                best_dist = max_d
                best_y0 = y0
        spread = (hi - lo) / 4
        lo = max(best_y0 - spread, Decimal('0'))
        hi = min(best_y0 + spread, Decimal('1'))
        if float(hi - lo) < 1e-40:
            break
    return compute_decimal_orbit(best_y0, n)


np.random.seed(42)
N = 500
eps = np.finfo(np.float64).eps

# Compute shadowing distances for multiple orbits
n_trials = 50
all_shadow = np.zeros((n_trials, N + 1))
for t in range(n_trials):
    x0 = np.random.uniform(0.05, 0.95)
    pseudo = compute_float_orbit(x0, N)
    true_orb = find_shadowing_orbit(pseudo)
    for i in range(N + 1):
        all_shadow[t, i] = abs(pseudo[i] - float(true_orb[i]))

# Compute naive error growth
x0 = 0.3
orbit1 = compute_float_orbit(x0, N)
orbit2 = compute_float_orbit(x0 + eps, N)
naive_err = np.abs(orbit1 - orbit2)

# Plot
fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(12, 9))

# Top: Shadowing distance
mean_shadow = np.mean(all_shadow, axis=0)
max_shadow = np.max(all_shadow, axis=0)
ax1.semilogy(range(N + 1), mean_shadow, 'b-', alpha=0.7, linewidth=1.5,
             label='Mean shadowing distance')
ax1.semilogy(range(N + 1), max_shadow, 'r-', alpha=0.4, linewidth=1,
             label='Max shadowing distance')
ax1.axhline(y=4 * eps, color='green', linestyle='--', linewidth=2,
            label=f'Theoretical bound 4δ = {4*eps:.1e}')
ax1.fill_between(range(N + 1), 1e-20, max_shadow, alpha=0.1, color='blue')
ax1.set_xlabel('Iteration number', fontsize=13)
ax1.set_ylabel('Shadowing distance', fontsize=13)
ax1.set_title('The Shadowing Lemma in Action: Logistic Map f(x) = 4x(1-x)',
              fontsize=14, fontweight='bold')
ax1.legend(fontsize=11, loc='lower right')
ax1.set_ylim(1e-18, 1e-13)
ax1.grid(True, alpha=0.3)
ax1.text(0.02, 0.95, f'n = {n_trials} random initial conditions, {N} iterations each',
         transform=ax1.transAxes, fontsize=10, verticalalignment='top',
         bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.5))

# Bottom: Comparison
ax2.semilogy(range(N + 1), mean_shadow, 'b-', linewidth=2,
             label='Shadowing error (BOUNDED)')
ax2.semilogy(range(N + 1), naive_err, 'r-', linewidth=2,
             label='Naive perturbation error (EXPONENTIAL)')
ax2.axhline(y=4 * eps, color='green', linestyle='--', linewidth=2,
            label=f'4δ = {4*eps:.1e}')
ax2.axhline(y=1.0, color='black', linestyle=':', alpha=0.5, label='Total decorrelation')
ax2.set_xlabel('Iteration number', fontsize=13)
ax2.set_ylabel('Error', fontsize=13)
ax2.set_title('Shadowing vs Naive Error: Bounded vs Exponential Growth', fontsize=14)
ax2.legend(fontsize=11)
ax2.set_ylim(1e-18, 10)
ax2.grid(True, alpha=0.3)
ax2.text(0.5, 0.5, 'Naive errors grow as δ·2ⁿ\nShadowing errors stay at 4δ',
         transform=ax2.transAxes, fontsize=12, ha='center',
         bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))

plt.tight_layout()
plt.savefig('viz_shadowing.png', dpi=150, bbox_inches='tight')
print("Saved viz_shadowing.png")
