#!/usr/bin/env python3
"""
demo.py — Numerical demonstrations of non-standard arithmetic concepts.

Demonstrates the key ideas from the Overspill Semiring theory:
1. Ultrafilter-like selection on finite approximations
2. Factorial divisibility (infinitely composite elements)
3. Transfer of primality through product structures
4. The non-Archimedean nature of ultrapowers
"""

import math
from collections import Counter


def demo_factorial_divisibility():
    """
    Demonstrate that n! is divisible by every k ≤ n.
    In UltraNat, [i ↦ i!] is divisible by EVERY standard k.
    """
    print("=" * 60)
    print("DEMO 1: Factorial — The Infinitely Composite Element")
    print("=" * 60)
    print()
    print("In UltraNat, the element [i ↦ i!] is divisible by every")
    print("standard natural number k > 0. Here we verify for small cases:")
    print()

    N = 20  # size of approximation
    for k in range(1, 11):
        divisible_indices = [i for i in range(k, N + 1) if math.factorial(i) % k == 0]
        density = len(divisible_indices) / N
        print(f"  k={k:2d}: {{i | k divides i!}} = {{i | i ≥ {k}}} "
              f"— density {density:.2f} (→ 1 as N → ∞)")

    print()
    print("For any free ultrafilter U, ALL these sets are U-large,")
    print("so [i ↦ i!] is simultaneously divisible by 1, 2, 3, 4, ...")
    print("This is impossible for any standard natural number!")


def demo_parity_transfer():
    """
    Demonstrate that every sequence has definite U-parity.
    """
    print()
    print("=" * 60)
    print("DEMO 2: Parity Transfer — Every Element Has Definite Parity")
    print("=" * 60)
    print()

    sequences = {
        "f(i) = i": lambda i: i,
        "f(i) = i²": lambda i: i * i,
        "f(i) = 2i+1": lambda i: 2 * i + 1,
        "f(i) = i!": lambda i: math.factorial(i),
        "f(i) = fib(i)": lambda i: fib(i),
    }

    for name, f in sequences.items():
        N = 50
        even_count = sum(1 for i in range(1, N + 1) if f(i) % 2 == 0)
        odd_count = N - even_count
        parity = "EVEN" if even_count > odd_count else "ODD"
        print(f"  {name:15s}: even={even_count}/{N}, odd={odd_count}/{N} "
              f"→ U-parity: {parity}")

    print()
    print("By the ultrafilter prime property, exactly one parity class")
    print("is U-large — every UltraNat element is internally even or odd.")


def fib(n):
    """Compute n-th Fibonacci number."""
    a, b = 0, 1
    for _ in range(n):
        a, b = b, a + b
    return a


def demo_prime_growth():
    """
    Demonstrate that the n-th prime grows without bound,
    giving 'infinite primes' in UltraNat.
    """
    print()
    print("=" * 60)
    print("DEMO 3: Infinite Primes — Primes Beyond All Standard Numbers")
    print("=" * 60)
    print()

    def nth_prime(n):
        """Return the n-th prime (0-indexed)."""
        primes = []
        candidate = 2
        while len(primes) <= n:
            if all(candidate % p != 0 for p in primes):
                primes.append(candidate)
            candidate += 1
        return primes[n]

    print("The sequence p(i) = (i+1)-th prime is always prime and → ∞:")
    print()
    for i in range(20):
        p = nth_prime(i)
        print(f"  p({i:2d}) = {p:4d}  (prime: True, exceeds {i}: {p > i})")

    print()
    print("In UltraNat, [i ↦ p(i)] is BOTH prime (cannot be factored)")
    print("and infinite (larger than every standard number).")
    print("Standard arithmetic forbids infinite primes — UltraNat has them!")


def demo_transfer_coloring():
    """
    Demonstrate the ultrafilter coloring theorem.
    """
    print()
    print("=" * 60)
    print("DEMO 4: Ultrafilter Coloring — Exactly One Color Survives")
    print("=" * 60)
    print()

    N = 100
    colorings = {
        "c(i) = i mod 2": lambda i: i % 2,
        "c(i) = i mod 3": lambda i: i % 3,
        "c(i) = (i²+1) mod 4": lambda i: (i * i + 1) % 4,
    }

    for name, c in colorings.items():
        num_colors = max(c(i) for i in range(N)) + 1
        counts = Counter(c(i) for i in range(N))
        print(f"  {name}:")
        for color in range(num_colors):
            density = counts.get(color, 0) / N
            print(f"    Color {color}: density = {density:.3f}")
        print(f"    → Any ultrafilter selects EXACTLY ONE color class")
        print()


def demo_non_archimedean():
    """
    Demonstrate the non-Archimedean property of UltraNat.
    """
    print()
    print("=" * 60)
    print("DEMO 5: Non-Archimedean — Breaking the Archimedean Axiom")
    print("=" * 60)
    print()

    print("In ℕ (Archimedean): for every x, ∃ n with x ≤ n.")
    print("In UltraNat: [id] = [i ↦ i] exceeds every constant [i ↦ n].")
    print()

    print("Verification: for each n, {i | n < i} has density → 1:")
    for n in [1, 10, 100, 1000]:
        N = 10000
        count = sum(1 for i in range(N) if n < i)
        print(f"  n = {n:4d}: |{{i < {N} | {n} < i}}| / {N} = {count/N:.4f}")

    print()
    print("Every such set is cofinite, hence in any free ultrafilter.")
    print("So [id] > [const n] for ALL n — truly non-Archimedean!")


if __name__ == "__main__":
    demo_factorial_divisibility()
    demo_parity_transfer()
    demo_prime_growth()
    demo_transfer_coloring()
    demo_non_archimedean()


#!/usr/bin/env python3
"""
viz_transfer.py — Visualization of ultrafilter transfer principles.

Produces a figure showing how properties transfer through ultraproducts,
with examples of divisibility, primality, and parity transfer.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
import math


def is_prime(n):
    if n < 2:
        return False
    for d in range(2, int(n**0.5) + 1):
        if n % d == 0:
            return False
    return True


def nth_prime(n):
    """Return the n-th prime (0-indexed)."""
    count = 0
    candidate = 2
    while True:
        if is_prime(candidate):
            if count == n:
                return candidate
            count += 1
        candidate += 1


def main():
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    fig.suptitle("Ultrafilter Transfer Principles in Non-Standard Arithmetic",
                 fontsize=14, fontweight='bold')

    N = 60

    # Panel 1: Factorial divisibility
    ax = axes[0, 0]
    for k in [2, 3, 5, 7, 11]:
        xs = list(range(1, N + 1))
        ys = [1 if math.factorial(i) % k == 0 else 0 for i in xs]
        offset = {2: 0, 3: 0.15, 5: 0.3, 7: 0.45, 11: 0.6}[k]
        colors = ['green' if y else 'red' for y in ys]
        ax.scatter([x + offset * 0.3 for x in xs], [k] * len(xs),
                   c=colors, s=8, alpha=0.7)
    ax.set_xlabel("Index i")
    ax.set_ylabel("Divisor k")
    ax.set_title("Factorial Divisibility: k | i!")
    ax.set_yticks([2, 3, 5, 7, 11])
    green_patch = mpatches.Patch(color='green', label='k | i! (True)')
    red_patch = mpatches.Patch(color='red', label='k | i! (False)')
    ax.legend(handles=[green_patch, red_patch], loc='lower right', fontsize=8)

    # Panel 2: Primality of nth prime sequence
    ax = axes[0, 1]
    primes_seq = [nth_prime(i) for i in range(N)]
    id_seq = list(range(N))
    ax.plot(range(N), primes_seq, 'b-', linewidth=1.5, label='p(i) = (i+1)-th prime')
    ax.plot(range(N), id_seq, 'r--', linewidth=1, alpha=0.5, label='id(i) = i')
    ax.fill_between(range(N), id_seq, primes_seq, alpha=0.1, color='blue')
    ax.set_xlabel("Index i")
    ax.set_ylabel("Value")
    ax.set_title("Infinite Primes: p(i) > i for all i")
    ax.legend(fontsize=8)

    # Panel 3: Parity transfer
    ax = axes[1, 0]
    sequences = {
        'i': lambda i: i,
        'i²': lambda i: i * i,
        '2i+1': lambda i: 2 * i + 1,
        'i!': lambda i: math.factorial(i) if i < 20 else 0,
        'fib(i)': lambda i: fib(i) if i < 30 else 0,
    }
    y_pos = 0
    for name, f in sequences.items():
        xs = list(range(1, min(N, 25) + 1))
        parities = [f(i) % 2 for i in xs]
        colors = ['blue' if p == 0 else 'orange' for p in parities]
        ax.scatter(xs, [y_pos] * len(xs), c=colors, s=15, marker='s')
        ax.text(-2, y_pos, name, ha='right', va='center', fontsize=9)
        y_pos += 1
    ax.set_xlabel("Index i")
    ax.set_title("Parity Transfer: Even (blue) vs Odd (orange)")
    ax.set_yticks([])
    ax.set_xlim(-5, min(N, 25) + 2)
    blue_patch = mpatches.Patch(color='blue', label='Even')
    orange_patch = mpatches.Patch(color='orange', label='Odd')
    ax.legend(handles=[blue_patch, orange_patch], loc='upper right', fontsize=8)

    # Panel 4: Non-Archimedean growth
    ax = axes[1, 1]
    xs = list(range(1, N + 1))
    id_vals = xs
    fact_vals = [min(math.factorial(i), 1e8) for i in xs]
    const_vals = {10: [10] * len(xs), 100: [100] * len(xs), 1000: [1000] * len(xs)}

    ax.semilogy(xs, fact_vals, 'b-', linewidth=2, label='[i ↦ i!] (infinite)')
    ax.semilogy(xs, id_vals, 'g-', linewidth=1.5, label='[i ↦ i] (infinite)')
    for n, vals in const_vals.items():
        ax.semilogy(xs, vals, '--', alpha=0.4, label=f'[const {n}] (standard)')
    ax.set_xlabel("Index i")
    ax.set_ylabel("Value (log scale)")
    ax.set_title("Non-Archimedean: Infinite Elements Exceed All Constants")
    ax.legend(fontsize=7, loc='lower right')

    plt.tight_layout()
    plt.savefig("transfer_visualization.png", dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved transfer_visualization.png")


def fib(n):
    a, b = 0, 1
    for _ in range(n):
        a, b = b, a + b
    return a


if __name__ == "__main__":
    main()
