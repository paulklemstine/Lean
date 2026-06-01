#!/usr/bin/env python3
"""
Demonstration of Truth Density Profile analysis.

Computes density profiles for several natural predicates on binary strings,
estimates their box-counting dimensions, and tests the Density Dimension
Gap Conjecture empirically.
"""

import math
from itertools import product as itertools_product
from typing import Callable, Tuple, List


def binary_strings(n: int):
    if n == 0:
        return [()]
    return list(itertools_product([0, 1], repeat=n))


def truth_count(n: int, pred: Callable) -> int:
    return sum(1 for s in binary_strings(n) if pred(s))


def truth_density(n: int, pred: Callable) -> float:
    if n == 0:
        return 1.0 if pred(()) else 0.0
    return truth_count(n, pred) / (2 ** n)


def binary_entropy(p: float) -> float:
    if p <= 0.0 or p >= 1.0:
        return 0.0
    return -p * math.log2(p) - (1 - p) * math.log2(1 - p)


# ─── Predicates ───

def half_profile(s):
    """First bit is 0 — density = 1/2"""
    return len(s) == 0 or s[0] == 0

def fibonacci_profile(s):
    """No consecutive 1s — count grows as Fibonacci, dimension ≈ log₂(φ) ≈ 0.694"""
    for i in range(len(s) - 1):
        if s[i] == 1 and s[i+1] == 1:
            return False
    return True

def palindrome_profile(s):
    """Palindromes — count grows as 2^(n/2), dimension ≈ 0.5"""
    return s == s[::-1]

def runs_profile(s):
    """At most 2 runs of consecutive identical bits"""
    if len(s) <= 1:
        return True
    runs = 1
    for i in range(1, len(s)):
        if s[i] != s[i-1]:
            runs += 1
    return runs <= 2

def singleton_profile(s):
    """Only the all-zeros string — sparse profile, dimension → 0"""
    return all(b == 0 for b in s)


def main():
    max_n = 18
    predicates = [
        ("Half (first bit=0)", half_profile, "Dimension should be exactly 1.0"),
        ("Fibonacci (no 11)", fibonacci_profile, "Dimension ≈ log₂(φ) ≈ 0.694"),
        ("Palindrome", palindrome_profile, "Dimension ≈ 0.5"),
        ("≤2 runs", runs_profile, "Sparse — dimension → 0"),
        ("Singleton (all 0s)", singleton_profile, "Dimension = 0"),
    ]

    for name, pred, note in predicates:
        print(f"\n{'='*60}")
        print(f"Profile: {name}")
        print(f"Note: {note}")
        print(f"{'='*60}")
        print(f"{'n':>4} {'count':>10} {'density':>10} {'entropy':>10} {'log₂(c)/n':>10}")
        print("-" * 50)

        exponents = []
        for n in range(1, max_n + 1):
            c = truth_count(n, pred)
            d = c / (2**n) if n > 0 else 0.0
            ent = binary_entropy(d)
            exp = math.log2(c) / n if c > 0 else 0.0
            exponents.append(exp)
            if n <= 14 or n == max_n:
                print(f"{n:4d} {c:10d} {d:10.6f} {ent:10.6f} {exp:10.6f}")

        # Estimate dimension from last 5 points
        tail = exponents[-5:]
        avg_dim = sum(tail) / len(tail)
        print(f"\nEstimated dimension (avg of last 5): {avg_dim:.6f}")
        print(f"Dimension gap: [{min(tail):.6f}, {max(tail):.6f}]")
        print(f"Gap size: {max(tail) - min(tail):.8f}")

    # ─── Complement Duality Verification ───
    print(f"\n{'='*60}")
    print("Complement Duality Verification")
    print(f"{'='*60}")
    for n in range(1, 13):
        c = truth_count(n, fibonacci_profile)
        c_comp = 2**n - c
        print(f"  n={n:2d}: count={c:5d}, complement={c_comp:5d}, sum={c + c_comp:5d}, 2^n={2**n:5d}, ✓={c + c_comp == 2**n}")

    # ─── Entropy Profile ───
    print(f"\n{'='*60}")
    print("Binary Entropy of Truth Density")
    print(f"{'='*60}")
    for p_val in [0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0]:
        h = binary_entropy(p_val)
        print(f"  H({p_val:.1f}) = {h:.6f} {'≥ 0 ✓' if h >= 0 else '< 0 ✗'}")

    # ─── Density Dimension Gap Conjecture Test ───
    print(f"\n{'='*60}")
    print("Density Dimension Gap Conjecture — Empirical Test")
    print(f"{'='*60}")
    print("For each profile, we check if upper and lower dimension estimates converge.")
    print("The conjecture predicts they do NOT converge for 'complex' profiles.\n")

    for name, pred, _ in predicates:
        exps = []
        for n in range(1, max_n + 1):
            c = truth_count(n, pred)
            if c > 0:
                exps.append(math.log2(c) / n)
        if len(exps) >= 5:
            tail = exps[-5:]
            gap = max(tail) - min(tail)
            status = "CONVERGING" if gap < 0.01 else "GAP PRESENT"
            print(f"  {name:25s}: gap = {gap:.6f}  [{status}]")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""Visualization: Truth Density Profiles across string lengths."""
import math
from itertools import product as itertools_product
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

def binary_strings(n):
    if n == 0: return [()]
    return list(itertools_product([0, 1], repeat=n))

def truth_count(n, pred):
    return sum(1 for s in binary_strings(n) if pred(s))

def half_profile(s):
    return len(s) == 0 or s[0] == 0

def fibonacci_profile(s):
    for i in range(len(s) - 1):
        if s[i] == 1 and s[i+1] == 1:
            return False
    return True

def palindrome_profile(s):
    return s == s[::-1]

def singleton_profile(s):
    return all(b == 0 for b in s)

max_n = 16
profiles = [
    ("Half (d≈1)", half_profile, '#2196F3'),
    ("Fibonacci (d≈0.694)", fibonacci_profile, '#FF9800'),
    ("Palindrome (d≈0.5)", palindrome_profile, '#4CAF50'),
    ("Singleton (d→0)", singleton_profile, '#F44336'),
]

fig, axes = plt.subplots(1, 3, figsize=(15, 5))

for name, pred, color in profiles:
    ns = list(range(1, max_n + 1))
    densities = [truth_count(n, pred) / 2**n for n in ns]
    exponents = [math.log2(truth_count(n, pred)) / n if truth_count(n, pred) > 0 else 0 for n in ns]
    counts = [truth_count(n, pred) for n in ns]

    axes[0].plot(ns, densities, 'o-', label=name, color=color, markersize=4)
    axes[1].plot(ns, exponents, 'o-', label=name, color=color, markersize=4)
    axes[2].semilogy(ns, counts, 'o-', label=name, color=color, markersize=4)

axes[0].set_xlabel('String length n')
axes[0].set_ylabel('Truth density')
axes[0].set_title('Truth Density vs Length')
axes[0].legend(fontsize=8)
axes[0].grid(True, alpha=0.3)

axes[1].set_xlabel('String length n')
axes[1].set_ylabel('log₂(count) / n')
axes[1].set_title('Density Exponent (→ Dimension)')
axes[1].legend(fontsize=8)
axes[1].grid(True, alpha=0.3)

axes[2].set_xlabel('String length n')
axes[2].set_ylabel('Truth count (log scale)')
axes[2].set_title('Truth Count Growth')
axes[2].legend(fontsize=8)
axes[2].grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('viz_density_profiles.png', dpi=150)
print("Saved viz_density_profiles.png")


#!/usr/bin/env python3
"""Visualization: Binary entropy landscape and truth density entropy."""
import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

def binary_entropy(p):
    if p <= 0.0 or p >= 1.0:
        return 0.0
    return -p * math.log2(p) - (1 - p) * math.log2(1 - p)

fig, axes = plt.subplots(1, 2, figsize=(12, 5))

# Binary entropy function
ps = np.linspace(0, 1, 1000)
hs = [binary_entropy(p) for p in ps]
axes[0].plot(ps, hs, 'b-', linewidth=2)
axes[0].fill_between(ps, 0, hs, alpha=0.15, color='blue')
axes[0].set_xlabel('Truth density p')
axes[0].set_ylabel('Binary entropy H(p)')
axes[0].set_title('Binary Shannon Entropy (always ≥ 0)')
axes[0].axhline(y=0, color='k', linewidth=0.5)
axes[0].grid(True, alpha=0.3)

# Mark key points
for p_val, label in [(0.5, 'max'), (0.694/1, 'Fibonacci')]:
    h = binary_entropy(p_val)
    axes[0].plot(p_val, h, 'ro', markersize=8)
    axes[0].annotate(f'p={p_val:.2f}\nH={h:.3f}', (p_val, h),
                    textcoords="offset points", xytext=(15, -15), fontsize=9)

# Entropy of truth density at each level for different profiles
from itertools import product as itertools_product
def binary_strings(n):
    if n == 0: return [()]
    return list(itertools_product([0, 1], repeat=n))
def truth_count(n, pred):
    return sum(1 for s in binary_strings(n) if pred(s))

def fibonacci_profile(s):
    for i in range(len(s) - 1):
        if s[i] == 1 and s[i+1] == 1: return False
    return True
def palindrome_profile(s):
    return s == s[::-1]
def half_profile(s):
    return len(s) == 0 or s[0] == 0

max_n = 14
for name, pred, color in [
    ("Half", half_profile, '#2196F3'),
    ("Fibonacci", fibonacci_profile, '#FF9800'),
    ("Palindrome", palindrome_profile, '#4CAF50'),
]:
    ns = list(range(1, max_n + 1))
    entropies = [binary_entropy(truth_count(n, pred) / 2**n) for n in ns]
    axes[1].plot(ns, entropies, 'o-', label=name, color=color, markersize=4)

axes[1].set_xlabel('String length n')
axes[1].set_ylabel('H(density(n))')
axes[1].set_title('Entropy of Truth Density')
axes[1].legend()
axes[1].grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('viz_entropy_landscape.png', dpi=150)
print("Saved viz_entropy_landscape.png")
