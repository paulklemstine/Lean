#!/usr/bin/env python3
"""
👽 Area 51 — The Prime Number Conspiracy

Demonstrates hidden structure in the distribution of primes:
1. The Ulam Spiral — primes form diagonal lines when arranged in a spiral
2. The Prime Conspiracy (Lemke Oliver & Soundararajan) — last-digit biases
3. Prime gaps distribution — arbitrarily large gaps exist
4. Benford's law failure — primes are "too uniform"
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from collections import Counter

def sieve_primes(limit):
    """Sieve of Eratosthenes."""
    is_prime = [True] * (limit + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(limit**0.5) + 1):
        if is_prime[i]:
            for j in range(i*i, limit + 1, i):
                is_prime[j] = False
    return [i for i in range(2, limit + 1) if is_prime[i]]

def ulam_spiral(n):
    """Generate coordinates for the Ulam spiral of size n×n."""
    grid = np.zeros((n, n), dtype=int)
    x, y = n // 2, n // 2
    dx, dy = 1, 0
    steps = 1
    num = 1

    while num <= n * n:
        for _ in range(2):
            for _ in range(steps):
                if 0 <= x < n and 0 <= y < n:
                    grid[y][x] = num
                num += 1
                x += dx
                y += dy
            dx, dy = -dy, dx
        steps += 1

    return grid

def main():
    fig, axes = plt.subplots(2, 2, figsize=(16, 16))
    fig.suptitle('👽 Area 51: The Prime Number Conspiracy\n'
                 'Hidden structure in the distribution of primes',
                 fontsize=16, fontweight='bold')

    # Panel 1: Ulam Spiral
    ax1 = axes[0, 0]
    n = 201
    grid = ulam_spiral(n)
    primes_set = set(sieve_primes(n * n))

    prime_x, prime_y = [], []
    for i in range(n):
        for j in range(n):
            if grid[i][j] in primes_set:
                prime_x.append(j)
                prime_y.append(i)

    ax1.scatter(prime_x, prime_y, s=0.3, c='lime', alpha=0.8)
    ax1.set_facecolor('black')
    ax1.set_xlim(0, n)
    ax1.set_ylim(0, n)
    ax1.set_aspect('equal')
    ax1.set_title('The Ulam Spiral (201×201)\nPrimes form mysterious diagonal lines!', fontsize=12)
    ax1.axis('off')

    # Panel 2: Prime Last-Digit Conspiracy
    ax2 = axes[0, 1]
    primes = sieve_primes(10_000_000)
    # Count consecutive prime last-digit transitions
    last_digits = [p % 10 for p in primes if p > 5]  # Skip 2, 3, 5
    transitions = Counter()
    for i in range(len(last_digits) - 1):
        transitions[(last_digits[i], last_digits[i+1])] += 1

    digits = [1, 3, 7, 9]
    matrix = np.zeros((4, 4))
    for i, d1 in enumerate(digits):
        total = sum(transitions[(d1, d2)] for d2 in digits)
        for j, d2 in enumerate(digits):
            matrix[i][j] = transitions[(d1, d2)] / total * 100 if total > 0 else 0

    im = ax2.imshow(matrix, cmap='YlOrRd', aspect='auto')
    ax2.set_xticks(range(4))
    ax2.set_xticklabels(digits, fontsize=12)
    ax2.set_yticks(range(4))
    ax2.set_yticklabels(digits, fontsize=12)
    ax2.set_xlabel('Next prime ends in...', fontsize=12)
    ax2.set_ylabel('Current prime ends in...', fontsize=12)
    ax2.set_title('Prime Last-Digit Conspiracy\n(Lemke Oliver & Soundararajan, 2016)', fontsize=12)

    for i in range(4):
        for j in range(4):
            color = 'white' if matrix[i][j] > 30 else 'black'
            ax2.text(j, i, f'{matrix[i][j]:.1f}%', ha='center', va='center',
                    fontsize=11, fontweight='bold', color=color)

    plt.colorbar(im, ax=ax2, label='Probability (%)')
    ax2.annotate('Diagonal should be 25% if random\nbut is consistently LOWER!',
                xy=(0.5, -0.15), xycoords='axes fraction',
                ha='center', fontsize=10, color='red', fontweight='bold')

    # Panel 3: Prime Gaps
    ax3 = axes[1, 0]
    gaps = np.diff(primes[:100000])
    gap_counts = Counter(gaps)
    gap_sizes = sorted(gap_counts.keys())
    gap_freqs = [gap_counts[g] for g in gap_sizes]

    ax3.bar(gap_sizes[:30], [gap_counts[g] for g in gap_sizes[:30]],
           color='steelblue', edgecolor='navy', alpha=0.8)
    ax3.set_xlabel('Gap size', fontsize=12)
    ax3.set_ylabel('Frequency', fontsize=12)
    ax3.set_title('Prime Gap Distribution\n(first 100,000 primes)', fontsize=12)
    ax3.annotate(f'Max gap in first 10M primes: {max(gaps)}',
                xy=(0.5, 0.9), xycoords='axes fraction',
                ha='center', fontsize=10,
                bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.8))

    # Panel 4: Benford's Law for Primes vs Fibonacci
    ax4 = axes[1, 1]
    # Fibonacci leading digits
    fibs = [1, 1]
    for _ in range(10000):
        fibs.append(fibs[-1] + fibs[-2])
    fib_leading = [int(str(f)[0]) for f in fibs if f > 0]
    fib_counts = Counter(fib_leading)

    # Prime leading digits
    prime_leading = [int(str(p)[0]) for p in primes]
    prime_counts = Counter(prime_leading)

    digits_1_9 = list(range(1, 10))
    benford = [np.log10(1 + 1/d) for d in digits_1_9]

    x_pos = np.arange(len(digits_1_9))
    width = 0.25

    fib_freq = [fib_counts[d] / len(fib_leading) for d in digits_1_9]
    prime_freq = [prime_counts[d] / len(prime_leading) for d in digits_1_9]

    ax4.bar(x_pos - width, benford, width, label="Benford's Law", color='green', alpha=0.7)
    ax4.bar(x_pos, fib_freq, width, label='Fibonacci', color='orange', alpha=0.7)
    ax4.bar(x_pos + width, prime_freq, width, label='Primes', color='red', alpha=0.7)

    ax4.set_xticks(x_pos)
    ax4.set_xticklabels(digits_1_9)
    ax4.set_xlabel('Leading digit', fontsize=12)
    ax4.set_ylabel('Frequency', fontsize=12)
    ax4.set_title("Benford's Law: Fibonacci follows, Primes DON'T", fontsize=12)
    ax4.legend(fontsize=10)
    ax4.annotate("Primes are 'too uniform' — a\nhidden structural property!",
                xy=(0.6, 0.85), xycoords='axes fraction',
                fontsize=10, color='red', fontweight='bold')

    plt.tight_layout()
    plt.savefig('/workspace/request-project/demos/area51_primes.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved area51_primes.png")

    # Wilson's theorem verification
    print("\n🔬 Wilson's Theorem Verification (p-1)! ≡ -1 (mod p):")
    print("-" * 60)
    small_primes = sieve_primes(30)
    for p in small_primes:
        fact = 1
        for k in range(1, p):
            fact = (fact * k) % p
        print(f"  p={p:2d}: ({p-1})! mod {p} = {fact} {'✓' if fact == p-1 else '✗'} (expected {p-1})")

    # Fermat's Little Theorem verification
    print("\n🔬 Fermat's Little Theorem: a^p ≡ a (mod p):")
    print("-" * 60)
    for p in [3, 5, 7, 11, 13]:
        for a in [2, 3, 4, 5]:
            result = pow(a, p, p)
            expected = a % p
            print(f"  {a}^{p} mod {p} = {result} {'✓' if result == expected else '✗'} (expected {expected})")

if __name__ == "__main__":
    main()
