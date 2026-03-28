#!/usr/bin/env python3
"""
Oracle Bootstrap: Algebraic Decomposition and Cryptographic Implications
=========================================================================

The bootstrap map f(x) = 3x² - 2x³ has a remarkable algebraic property:
it decomposes elements into "idempotent-like" components. When applied
to modular arithmetic (Z/nZ), this decomposition can reveal the factor
structure of n.

Key insight: In Z/nZ where n = p*q, the bootstrap map's fixed points
correspond to the idempotents of Z/nZ, which by CRT correspond to
factors of n.

Run: python encryption_attack.py
Outputs: bootstrap_factoring.png, padic_convergence.png
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.gridspec as gridspec
from collections import Counter
import time

def bootstrap_mod(x, n, iterations=100):
    """Apply f(x) = 3x² - 2x³ mod n, iterated."""
    for _ in range(iterations):
        x = (3 * x * x - 2 * x * x * x) % n
    return x

def find_idempotents_bootstrap(n, max_iter=200):
    """Find idempotents of Z/nZ using the bootstrap map.
    Idempotents e satisfy e² ≡ e (mod n).
    For n = p*q, the non-trivial idempotents reveal factors."""
    idempotents = set()
    for x in range(n):
        result = bootstrap_mod(x, n, max_iter)
        if (result * result) % n == result:
            idempotents.add(result)
    return sorted(idempotents)

def gcd(a, b):
    while b:
        a, b = b, a % b
    return a

def factor_via_bootstrap(n, verbose=False):
    """Attempt to factor n using the bootstrap map's idempotent convergence.

    The idea: For n = p*q (RSA modulus), Z/nZ ≅ Z/pZ × Z/qZ by CRT.
    The idempotents of Z/nZ are (0,0), (1,1), (1,0), (0,1).
    The non-trivial ones (1,0) and (0,1) give factors via gcd(e, n).

    The bootstrap map f(x) = 3x² - 2x³ converges to idempotents!
    """
    start_time = time.time()
    factors_found = set()

    for x0 in range(2, min(n, 1000)):
        x = x0
        for i in range(500):
            x_new = (3 * x * x - 2 * x * x * x) % n
            if x_new == x:
                break
            x = x_new

        # Check if x is a non-trivial idempotent
        if (x * x) % n == x and x != 0 and x != 1:
            g = gcd(x, n)
            if 1 < g < n:
                factors_found.add(g)
                if verbose:
                    print(f"  x₀={x0}: converged to e={x}, gcd(e,n) = {g}")

    elapsed = time.time() - start_time
    return sorted(factors_found), elapsed

# ══════════════════════════════════════════════════════
# Experiment 1: Factor small semiprimes
# ══════════════════════════════════════════════════════
print("=" * 60)
print("EXPERIMENT: Factoring via Oracle Bootstrap")
print("=" * 60)

test_cases = [
    (15, "3 × 5"),
    (21, "3 × 7"),
    (35, "5 × 7"),
    (77, "7 × 11"),
    (91, "7 × 13"),
    (143, "11 × 13"),
    (221, "13 × 17"),
    (323, "17 × 19"),
    (437, "19 × 23"),
    (667, "23 × 29"),
    (899, "29 × 31"),
    (1147, "31 × 37"),
    (2021, "43 × 47"),
    (3127, "53 × 59"),
    (4087, "61 × 67"),
]

results = []
print(f"\n{'n':>8} {'= p×q':>12} {'Factors Found':>20} {'Time (ms)':>12} {'Status':>10}")
print("-" * 70)

for n, desc in test_cases:
    factors, elapsed = factor_via_bootstrap(n)
    status = "✓ FOUND" if factors else "✗ MISS"
    factors_str = str(factors) if factors else "—"
    results.append((n, desc, factors, elapsed * 1000))
    print(f"{n:>8} {desc:>12} {factors_str:>20} {elapsed*1000:>10.2f}ms {status:>10}")

# ══════════════════════════════════════════════════════
# Experiment 2: Visualize bootstrap orbits mod n
# ══════════════════════════════════════════════════════
fig = plt.figure(figsize=(18, 14))
fig.suptitle('Oracle Bootstrap Factoring: f(x) = 3x² − 2x³ mod n\n'
             'Convergence to idempotents reveals prime factors',
             fontsize=14, fontweight='bold')

# Show orbits for n = 15 = 3 × 5
n = 15
gs = gridspec.GridSpec(2, 2, hspace=0.4, wspace=0.3)

ax1 = fig.add_subplot(gs[0, 0])
# Plot all orbits
for x0 in range(n):
    orbit = [x0]
    x = x0
    for _ in range(20):
        x = (3 * x * x - 2 * x * x * x) % n
        orbit.append(x)
    # Color by convergence target
    final = orbit[-1]
    if final == 0:
        color = 'blue'
    elif final == 1:
        color = 'red'
    elif final == 6:  # Non-trivial idempotent for n=15
        color = 'green'
    elif final == 10:  # Other non-trivial idempotent
        color = 'purple'
    else:
        color = 'gray'
    ax1.plot(orbit, 'o-', color=color, markersize=3, linewidth=1, alpha=0.6)

ax1.set_xlabel('Iteration')
ax1.set_ylabel('x mod 15')
ax1.set_title(f'Bootstrap Orbits mod 15 = 3×5\n'
              f'Idempotents: 0 (blue), 1 (red), 6 (green), 10 (purple)')
ax1.grid(True, alpha=0.3)

# Convergence histogram for n = 77
ax2 = fig.add_subplot(gs[0, 1])
n = 77
final_values = []
for x0 in range(n):
    x = x0
    for _ in range(100):
        x = (3 * x * x - 2 * x * x * x) % n
    final_values.append(x)

counter = Counter(final_values)
vals = sorted(counter.keys())
counts = [counter[v] for v in vals]

colors = []
for v in vals:
    if (v * v) % n == v:
        g = gcd(v, n)
        if g == 1 or g == n:
            colors.append('gray')
        else:
            colors.append('gold')
    else:
        colors.append('steelblue')

ax2.bar(vals, counts, color=colors, edgecolor='navy', alpha=0.7)
ax2.set_xlabel('Final value')
ax2.set_ylabel('Number of starting points')
ax2.set_title(f'Bootstrap Convergence mod 77 = 7×11\n'
              f'Gold = non-trivial idempotents (reveal factors)')
ax2.grid(True, alpha=0.3)

# Success rate across semiprimes
ax3 = fig.add_subplot(gs[1, 0])
ns = [r[0] for r in results]
success = [1 if r[2] else 0 for r in results]
times = [r[3] for r in results]

ax3.bar(range(len(ns)), success, color=['green' if s else 'red' for s in success],
        edgecolor='darkgray', alpha=0.7)
ax3.set_xticks(range(len(ns)))
ax3.set_xticklabels([str(n) for n in ns], rotation=45, fontsize=8)
ax3.set_ylabel('Factored? (1=yes, 0=no)')
ax3.set_title('Bootstrap Factoring Success Rate')
ax3.grid(True, alpha=0.3)

# Timing
ax4 = fig.add_subplot(gs[1, 1])
ax4.plot(ns, times, 'ro-', markersize=6, linewidth=2)
ax4.set_xlabel('n (semiprime)')
ax4.set_ylabel('Time (ms)')
ax4.set_title('Bootstrap Factoring Time')
ax4.grid(True, alpha=0.3)
ax4.set_yscale('log')

plt.savefig('/workspace/request-project/core/Oracle/CosmicBootstrap/demos/bootstrap_factoring.png',
            dpi=150, bbox_inches='tight', facecolor='white')
plt.close()
print("\n✓ Generated: bootstrap_factoring.png")

# ══════════════════════════════════════════════════════
# Experiment 3: p-adic convergence
# ══════════════════════════════════════════════════════
print("\n" + "=" * 60)
print("EXPERIMENT: p-adic Bootstrap Convergence")
print("=" * 60)

fig, axes = plt.subplots(1, 3, figsize=(18, 6))
fig.suptitle('p-adic Oracle Bootstrap: Convergence mod p^k\n'
             'The bootstrap map discovers p-adic structure',
             fontsize=14, fontweight='bold')

for idx, p in enumerate([3, 5, 7]):
    ax = axes[idx]
    max_k = 8

    # Track convergence mod p^k for various starting points
    for x0 in [2, 3, 5, 7, 11, 13, 17]:
        residues = []
        for k in range(1, max_k + 1):
            n = p ** k
            x = x0 % n
            for _ in range(200):
                x = (3 * x * x - 2 * x * x * x) % n
            residues.append(x)

        ax.plot(range(1, max_k + 1), residues, 'o-', markersize=4,
                linewidth=1.5, alpha=0.6, label=f'x₀={x0}')

    ax.set_xlabel(f'k (precision: mod {p}^k)')
    ax.set_ylabel(f'Bootstrap fixed point mod {p}^k')
    ax.set_title(f'p = {p}: p-adic convergence')
    ax.legend(fontsize=7)
    ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('/workspace/request-project/core/Oracle/CosmicBootstrap/demos/padic_convergence.png',
            dpi=150, bbox_inches='tight', facecolor='white')
plt.close()
print("✓ Generated: padic_convergence.png")
