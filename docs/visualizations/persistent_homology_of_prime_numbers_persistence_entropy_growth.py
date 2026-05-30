#!/usr/bin/env python3
"""
Visualization 3: Persistence Entropy Growth of the Prime Barcode

Shows how persistence entropy H(N) grows with N, compared to log(log(N)).
This connects prime distribution (number theory) to information theory
via the barcode formalism — a cross-domain bridge.

What this visualizes: The information-theoretic complexity of the prime
gap distribution, suggesting deep connections between entropy and the
Prime Number Theorem.
"""

import matplotlib.pyplot as plt
import numpy as np
from math import log2, log


def sieve_primes(N):
    if N < 2:
        return []
    is_prime = [True] * (N + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(N**0.5) + 1):
        if is_prime[i]:
            for j in range(i * i, N + 1, i):
                is_prime[j] = False
    return [i for i in range(2, N + 1) if is_prime[i]]


def persistence_entropy(primes):
    if len(primes) <= 1:
        return 0.0
    gaps = [primes[i + 1] - primes[i] for i in range(len(primes) - 1)]
    total = sum(gaps)
    if total == 0:
        return 0.0
    entropy = 0.0
    for g in gaps:
        if g > 0:
            p = g / total
            entropy -= p * log2(p)
    return entropy


def main():
    fig, axes = plt.subplots(1, 3, figsize=(18, 6))

    # Compute entropy for various N
    all_primes = sieve_primes(100000)
    N_values = list(range(50, 100001, 100))
    entropies = []
    for N in N_values:
        primes_N = [p for p in all_primes if p <= N]
        entropies.append(persistence_entropy(primes_N))

    # --- Left: Entropy growth ---
    ax = axes[0]
    ax.plot(N_values, entropies, color='#2c3e50', linewidth=1.5, label='H(N)')

    # Theoretical comparison: c * log(log(N))
    log_log = [1.8 * log(log(N)) / log(2) if N > 2 else 0 for N in N_values]
    ax.plot(N_values, log_log, color='#e74c3c', linewidth=2, linestyle='--',
            label='c · log₂(log N)', alpha=0.7)

    ax.set_xlabel('N', fontsize=13)
    ax.set_ylabel('Persistence Entropy H(N) [bits]', fontsize=13)
    ax.set_title('Persistence Entropy Growth\nof the Prime Barcode',
                 fontsize=14, fontweight='bold')
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)

    # --- Middle: Entropy vs π(N) ---
    ax = axes[1]
    prime_counts = []
    for N in N_values:
        prime_counts.append(len([p for p in all_primes if p <= N]))

    ax.scatter(prime_counts, entropies, s=3, alpha=0.5, color='#3498db')
    ax.set_xlabel('π(N) = Number of Primes ≤ N', fontsize=13)
    ax.set_ylabel('Persistence Entropy H(N) [bits]', fontsize=13)
    ax.set_title('Entropy vs Prime Count\nCross-Domain: Number Theory ↔ Information Theory',
                 fontsize=14, fontweight='bold')
    ax.grid(True, alpha=0.3)

    # Fit line
    log_pc = [log2(pc) if pc > 0 else 0 for pc in prime_counts]
    valid = [(lp, e) for lp, e in zip(log_pc, entropies) if lp > 0]
    if valid:
        x_fit = np.array([v[0] for v in valid])
        y_fit = np.array([v[1] for v in valid])
        coeffs = np.polyfit(x_fit, y_fit, 1)
        x_line = np.linspace(min(x_fit), max(x_fit), 100)
        ax.plot(np.power(2, x_line), np.polyval(coeffs, x_line),
                color='#e74c3c', linewidth=2, linestyle='--',
                label=f'Fit: H ≈ {coeffs[0]:.2f}·log₂(π(N)) + {coeffs[1]:.2f}')
        ax.legend(fontsize=10)

    # --- Right: Comparison with random ---
    ax = axes[2]

    # Prime entropy
    ax.plot(N_values[::5], entropies[::5], 'o-', color='#2c3e50',
            markersize=3, linewidth=1, label='Prime barcode entropy')

    # Random: entropy of uniform gaps
    np.random.seed(42)
    random_entropies = []
    for N in N_values[::5]:
        n_points = len([p for p in all_primes if p <= N])
        if n_points <= 1:
            random_entropies.append(0)
            continue
        random_points = sorted(np.random.choice(range(2, N + 1), size=n_points, replace=False))
        random_gaps = [random_points[i + 1] - random_points[i] for i in range(len(random_points) - 1)]
        total = sum(random_gaps)
        if total == 0:
            random_entropies.append(0)
            continue
        ent = 0
        for g in random_gaps:
            if g > 0:
                p = g / total
                ent -= p * log2(p)
        random_entropies.append(ent)

    ax.plot(N_values[::5], random_entropies, 's-', color='#e74c3c',
            markersize=3, linewidth=1, label='Random point cloud entropy')

    # Maximum possible entropy
    max_ent = [log2(len([p for p in all_primes if p <= N]) - 1)
               if len([p for p in all_primes if p <= N]) > 1 else 0
               for N in N_values[::5]]
    ax.plot(N_values[::5], max_ent, '--', color='#27ae60',
            linewidth=1.5, label='Max entropy (uniform)')

    ax.set_xlabel('N', fontsize=13)
    ax.set_ylabel('Entropy [bits]', fontsize=13)
    ax.set_title('Prime vs Random Entropy\nPrimes have lower entropy → more structure',
                 fontsize=14, fontweight='bold')
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('viz_entropy.png', dpi=150, bbox_inches='tight')
    print("Saved viz_entropy.png")


if __name__ == "__main__":
    main()
