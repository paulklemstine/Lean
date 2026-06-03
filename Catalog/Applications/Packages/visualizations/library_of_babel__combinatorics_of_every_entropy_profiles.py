#!/usr/bin/env python3
"""
Visualization: Entropy Profiles

Compares entropy profiles of constant, periodic, and random words,
showing how multi-scale complexity differs across word types.
"""

import random
import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def entropy_profile(word, max_scale=15):
    n = len(word)
    profile = {}
    for s in range(1, min(max_scale + 1, n + 1)):
        sgrams = set()
        for i in range(n - s + 1):
            sgrams.add(tuple(word[i:i + s]))
        profile[s] = len(sgrams)
    return profile


def max_possible(n, k, s):
    return min(n - s + 1, k ** s)


def main():
    random.seed(42)
    n = 500
    k = 10
    max_s = 12

    # Generate words
    constant_word = [0] * n
    periodic_word = [(i % 3) for i in range(n)]
    random_word = [random.randint(0, k-1) for _ in range(n)]
    structured_word = [i % k for i in range(n)]  # sequential cycling

    words = {
        'Constant (aaaa...)': constant_word,
        'Periodic (period 3)': periodic_word,
        'Random': random_word,
        'Sequential cycling': structured_word,
    }

    colors = ['#e74c3c', '#f39c12', '#2ecc71', '#3498db']

    fig, ax = plt.subplots(figsize=(10, 6))

    for (name, word), color in zip(words.items(), colors):
        profile = entropy_profile(word, max_s)
        scales = sorted(profile.keys())
        values = [profile[s] for s in scales]
        ax.plot(scales, values, 'o-', color=color, linewidth=2, markersize=6, label=name)

    # Maximum possible
    scales = list(range(1, max_s + 1))
    max_vals = [max_possible(n, k, s) for s in scales]
    ax.plot(scales, max_vals, 'k--', linewidth=1.5, alpha=0.5, label='Maximum possible')

    ax.set_xlabel('Scale s (s-gram length)', fontsize=13)
    ax.set_ylabel('Distinct s-grams', fontsize=13)
    ax.set_title(f'Entropy Profile Comparison\n(n={n}, alphabet size k={k})', fontsize=14)
    ax.legend(fontsize=11)
    ax.set_yscale('log')
    ax.set_xticks(scales)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('entropy_profiles.png', dpi=150, bbox_inches='tight')
    print("Saved entropy_profiles.png")


if __name__ == "__main__":
    main()
