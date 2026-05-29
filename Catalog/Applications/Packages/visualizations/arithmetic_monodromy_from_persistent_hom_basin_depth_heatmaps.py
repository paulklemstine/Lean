"""
Visualization 3: Basin-Depth Heatmap Across Primes

This script creates a heatmap showing the basin-depth histogram of a polynomial
across many primes. Each row is a prime p, each column is a depth level,
and the color intensity shows the fraction of Z/pZ at that depth.

The depth-0 column (leftmost) shows the root count — by Theorem 4, this equals
the Frobenius fixed-point count. The deeper columns show the richer persistence
data that may distinguish Galois groups beyond root counts alone.
"""

import matplotlib.pyplot as plt
import numpy as np


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

def basin_depth_histogram(coeffs, p, max_depth=8):
    graph = {x: newton_step(coeffs, x, p) for x in range(p)}
    depth = {x: 0 for x in range(p) if graph[x] is not None and graph[x] == x}
    for d in range(1, max_depth + 1):
        for x in range(p):
            if x not in depth:
                y = graph[x]
                if y is not None and y in depth and depth[y] == d - 1:
                    depth[x] = d
    hist = {}
    for d in range(-1, max_depth + 1):
        hist[d] = sum(1 for x in range(p) if depth.get(x, -1) == d)
    return hist

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
    r"$x^5 - x - 1$  (Gal = $S_5$)": [-1, -1, 0, 0, 0, 1],
}

max_depth = 6
primes = [p for p in sieve_primes(150) if p > 5]

fig, axes = plt.subplots(1, 2, figsize=(16, 8))
fig.suptitle("Basin-Depth Heatmaps: Newton Persistence Across Primes\n"
             "Column 0 = root count (Frobenius statistic), deeper columns = persistence data",
             fontsize=13, fontweight='bold')

for idx, (name, coeffs) in enumerate(polys.items()):
    ax = axes[idx]

    # Build heatmap matrix
    matrix = np.zeros((len(primes), max_depth + 2))  # depths 0..max_depth + unreached
    for i, p in enumerate(primes):
        hist = basin_depth_histogram(coeffs, p, max_depth)
        for d in range(max_depth + 1):
            matrix[i, d] = hist.get(d, 0) / p  # Normalize by p
        matrix[i, max_depth + 1] = hist.get(-1, 0) / p

    # Plot
    im = ax.imshow(matrix, aspect='auto', cmap='YlOrRd',
                   interpolation='nearest', vmin=0)
    ax.set_title(name, fontsize=11)
    ax.set_xlabel("Basin Depth", fontsize=10)
    ax.set_ylabel("Prime $p$", fontsize=10)

    # X-axis labels
    x_labels = [str(d) for d in range(max_depth + 1)] + ["∞"]
    ax.set_xticks(range(len(x_labels)))
    ax.set_xticklabels(x_labels)

    # Y-axis labels (show subset of primes)
    tick_positions = list(range(0, len(primes), max(1, len(primes) // 15)))
    ax.set_yticks(tick_positions)
    ax.set_yticklabels([str(primes[i]) for i in tick_positions])

    plt.colorbar(im, ax=ax, label="Fraction of $\\mathbb{F}_p$", shrink=0.8)

plt.tight_layout()
plt.savefig("viz_depth_heatmap.png", dpi=150, bbox_inches='tight')
print("Saved: viz_depth_heatmap.png")
