"""
Visualization: Filtration Profile Heatmap

Visualizes how the persistence filtration profile varies across primes for
different polynomial families. Each row is a prime, each column is a filtration
level, and the color intensity represents the cardinality of the lower support
at that level. This reveals the arithmetic fingerprint of a polynomial.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.gridspec as gridspec


def padic_val(n, p):
    if n == 0: return 100
    n = abs(n)
    v = 0
    while n % p == 0:
        v += 1
        n //= p
    return v

def is_prime(n):
    if n < 2: return False
    if n < 4: return True
    if n % 2 == 0 or n % 3 == 0: return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i + 2) == 0: return False
        i += 6
    return True

def primes_up_to(n):
    return [p for p in range(2, n + 1) if is_prime(p)]

def filtration_profile(support, coeffs, p, max_level=10):
    return [sum(1 for m in support if coeffs.get(m, 0) != 0 and padic_val(coeffs[m], p) <= t)
            for t in range(max_level + 1)]


# Setup
primes = primes_up_to(50)
max_level = 8

# Define polynomial families
families = {
    r"$x^6 + 360$" + "\n(binomial, highly composite)": {
        "support": [(0,), (6,)],
        "coeffs": {(0,): 360, (6,): 1}
    },
    r"$x^6 + 120x + 360$" + "\n(trinomial, mixed)": {
        "support": [(0,), (1,), (6,)],
        "coeffs": {(0,): 360, (1,): 120, (6,): 1}
    },
    r"$x^6 + 30x^3 + 120x + 360$" + "\n(sparse, varied weights)": {
        "support": [(0,), (1,), (3,), (6,)],
        "coeffs": {(0,): 360, (1,): 120, (3,): 30, (6,): 1}
    },
    r"$x^6 + x^5 + x^4 + x^3 + x^2 + x + 1$" + "\n(dense, unit coefficients)": {
        "support": [(i,) for i in range(7)],
        "coeffs": {(i,): 1 for i in range(7)}
    },
}

fig = plt.figure(figsize=(16, 12))
fig.suptitle("Arithmetic Persistence Filtration Profiles Across Primes",
             fontsize=16, fontweight='bold', y=0.98)

gs = gridspec.GridSpec(2, 2, hspace=0.4, wspace=0.3)

for idx, (title, data) in enumerate(families.items()):
    ax = fig.add_subplot(gs[idx])
    
    support = data["support"]
    coeffs = data["coeffs"]
    
    # Build heatmap data
    matrix = np.zeros((len(primes), max_level + 1))
    for i, p in enumerate(primes):
        prof = filtration_profile(support, coeffs, p, max_level)
        for j, val in enumerate(prof):
            matrix[i, j] = val
    
    im = ax.imshow(matrix, aspect='auto', cmap='YlOrRd', interpolation='nearest',
                   vmin=0, vmax=len(support))
    
    ax.set_xlabel("Filtration Level t", fontsize=11)
    ax.set_ylabel("Prime p", fontsize=11)
    ax.set_title(title, fontsize=10)
    
    # Label axes
    ax.set_xticks(range(0, max_level + 1, 2))
    
    # Show every 3rd prime label to avoid crowding
    y_ticks = list(range(0, len(primes), 3))
    ax.set_yticks(y_ticks)
    ax.set_yticklabels([str(primes[i]) for i in y_ticks])
    
    plt.colorbar(im, ax=ax, label="Support size", shrink=0.8)

fig.text(0.5, 0.01,
         "Each heatmap shows |lowerSupportAtLevel(σ, a, p, t)| — the number of monomials\n"
         "visible at filtration level t for prime p. Different arithmetic structures produce\n"
         "distinct visual fingerprints, demonstrating the family separation theorem.",
         ha='center', fontsize=10, style='italic')

plt.savefig("filtration_heatmap.png", dpi=150, bbox_inches='tight')
print("Saved filtration_heatmap.png")
