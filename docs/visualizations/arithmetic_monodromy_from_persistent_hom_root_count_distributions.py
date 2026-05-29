"""
Visualization 1: Root-Count Distributions for Different Galois Groups

This script visualizes the Newton persistence statistic S_p(f) — the number of
Newton fixed points modulo p — across many primes, for polynomials with different
known Galois groups. By Theorem 3, S_p(f) = R_p(f) (root count) for squarefree f.
The different distributions reflect the Chebotarev density theorem: each Galois
group produces a characteristic fingerprint.
"""

import matplotlib.pyplot as plt
import numpy as np
from collections import Counter


# ─── Self-contained implementations ────────────────────────────────────────

def poly_eval(coeffs, x, p):
    result, power = 0, 1
    for c in coeffs:
        result = (result + c * power) % p
        power = (power * x) % p
    return result

def poly_derivative(coeffs):
    if len(coeffs) <= 1:
        return [0]
    return [i * coeffs[i] for i in range(1, len(coeffs))]

def newton_step(coeffs, x, p):
    deriv = poly_derivative(coeffs)
    fx = poly_eval(coeffs, x, p)
    fpx = poly_eval(deriv, x, p)
    if fpx % p == 0:
        return None
    return (x - fx * pow(fpx, p - 2, p)) % p

def newton_fixed_count(coeffs, p):
    count = 0
    for x in range(p):
        ns = newton_step(coeffs, x, p)
        if ns is not None and ns == x:
            count += 1
    return count

def sieve_primes(n):
    if n < 2: return []
    is_prime = [True] * (n + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(n**0.5) + 1):
        if is_prime[i]:
            for j in range(i*i, n + 1, i): is_prime[j] = False
    return [i for i in range(2, n + 1) if is_prime[i]]


# ─── Compute data ──────────────────────────────────────────────────────────

polys = {
    r"$x^3 - 2$  (Gal = $S_3$)": [-2, 0, 0, 1],
    r"$x^3 - 3x - 1$  (Gal = $\mathbb{Z}/3$)": [-1, -3, 0, 1],
    r"$x^5 - x - 1$  (Gal = $S_5$)": [-1, -1, 0, 0, 0, 1],
    r"$x^4 - x^2 + 1$  (Gal = $V_4$)": [1, 0, -1, 0, 1],
}

primes = [p for p in sieve_primes(400) if p > 5]

data = {}
for name, coeffs in polys.items():
    counts = [newton_fixed_count(coeffs, p) for p in primes]
    data[name] = counts


# ─── Plot ───────────────────────────────────────────────────────────────────

fig, axes = plt.subplots(2, 2, figsize=(12, 10))
fig.suptitle("Newton Persistence Statistic $S_p(f)$ — Galois Group Fingerprints",
             fontsize=14, fontweight='bold')

colors = ['#2196F3', '#FF5722', '#4CAF50', '#9C27B0']

for idx, (name, counts) in enumerate(data.items()):
    ax = axes[idx // 2][idx % 2]
    counter = Counter(counts)
    max_count = max(counts) if counts else 0
    x_vals = list(range(max_count + 1))
    y_vals = [counter.get(k, 0) / len(counts) for k in x_vals]

    ax.bar(x_vals, y_vals, color=colors[idx], alpha=0.8, edgecolor='white',
           linewidth=1.5)
    ax.set_title(name, fontsize=11)
    ax.set_xlabel("$S_p(f)$ = Newton fixed points = roots mod $p$", fontsize=9)
    ax.set_ylabel("Frequency", fontsize=9)
    ax.set_xticks(x_vals)

    # Add mean line
    mean_val = np.mean(counts)
    ax.axvline(mean_val, color='red', linestyle='--', alpha=0.7, linewidth=1.5)
    ax.text(mean_val + 0.1, max(y_vals) * 0.9, f"mean={mean_val:.2f}",
            fontsize=8, color='red')

    ax.set_ylim(0, max(y_vals) * 1.15)
    ax.grid(axis='y', alpha=0.3)

plt.tight_layout()
plt.savefig("viz_root_distributions.png", dpi=150, bbox_inches='tight')
print("Saved: viz_root_distributions.png")
