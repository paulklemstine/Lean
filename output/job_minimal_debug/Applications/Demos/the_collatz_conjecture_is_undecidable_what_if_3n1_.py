#!/usr/bin/env python3
"""
Collatz Orbit Structure Demo
=============================
Demonstrates the key results from the Collatz proof barrier research:
1. Orbit tree structure and merging
2. Parity word affine encoding
3. Syracuse acceleration
4. Stopping time distribution
"""

from fractions import Fraction
from typing import List, Tuple


def collatz_step(n: int) -> int:
    """The Collatz step function T(n)."""
    return n // 2 if n % 2 == 0 else 3 * n + 1


def collatz_orbit(n: int, max_steps: int = 10000) -> List[int]:
    """Compute the Collatz orbit of n until reaching 1 or max_steps."""
    orbit = [n]
    while n != 1 and len(orbit) < max_steps:
        n = collatz_step(n)
        orbit.append(n)
    return orbit


def syracuse(n: int) -> int:
    """The Syracuse function S(n) = (3n+1)/2 for odd n."""
    assert n % 2 == 1, f"Syracuse requires odd input, got {n}"
    return (3 * n + 1) // 2


def parity_word(n: int, k: int) -> List[bool]:
    """Extract the parity word: True if the i-th iterate is odd."""
    word = []
    for _ in range(k):
        word.append(n % 2 == 1)
        n = collatz_step(n)
    return word


def affine_encode(word: List[bool]) -> Tuple[Fraction, Fraction]:
    """Compute (multiplier, offset) for a parity word over Q.
    
    The word is in chronological order: word[i] = parity at step i.
    The encoding gives affine_image(n) = mult * n + off = T^k(n).
    """
    mult = Fraction(1)
    off = Fraction(0)
    for b in word:
        if b:  # odd step: x -> 3x + 1
            mult = 3 * mult
            off = 3 * off + 1
        else:  # even step: x -> x/2
            mult = mult / 2
            off = off / 2
    return mult, off


def verify_affine_encoding(n: int, k: int) -> bool:
    """Verify that the affine encoding correctly predicts the k-th iterate."""
    word = parity_word(n, k)
    mult, off = affine_encode(word)
    predicted = mult * n + off
    # Compute actual k-th iterate
    actual = n
    for _ in range(k):
        actual = collatz_step(actual)
    return predicted == actual


def stopping_time(n: int, max_steps: int = 100000) -> int:
    """Compute the stopping time (steps to reach 1)."""
    steps = 0
    while n != 1 and steps < max_steps:
        n = collatz_step(n)
        steps += 1
    return steps if n == 1 else -1


def demo_orbit_merge():
    """Demonstrate the orbit merge theorem."""
    print("=" * 60)
    print("DEMO 1: Orbit Merge Theorem")
    print("=" * 60)
    print("\nIf two orbits meet, they merge permanently.\n")

    a, b = 7, 15
    orbit_a = collatz_orbit(a)
    orbit_b = collatz_orbit(b)

    # Find first common value
    set_a = set(orbit_a)
    for i, v in enumerate(orbit_b):
        if v in set_a:
            j = orbit_a.index(v)
            print(f"Orbit of {a}: {orbit_a[:j+3]}...")
            print(f"Orbit of {b}: {orbit_b[:i+3]}...")
            print(f"\nMerge point: orbit_a[{j}] = orbit_b[{i}] = {v}")
            print(f"After merge: orbit_a[{j}:] == orbit_b[{i}:]? "
                  f"{orbit_a[j:] == orbit_b[i:]}")
            break


def demo_parity_encoding():
    """Demonstrate the affine parity encoding."""
    print("\n" + "=" * 60)
    print("DEMO 2: Affine Parity Encoding")
    print("=" * 60)
    print("\nEach parity word defines an affine map over Q.\n")

    for n in [7, 27, 97]:
        orbit = collatz_orbit(n)
        k = min(10, len(orbit) - 1)
        word = parity_word(n, k)
        mult, off = affine_encode(word)
        print(f"n = {n}, parity word (first {k} steps): "
              f"{''.join('O' if b else 'E' for b in word)}")
        print(f"  Multiplier = {mult} = 3^{sum(word)}/2^{k}")
        print(f"  Offset = {off}")
        print(f"  Predicted T^{k}({n}) = {mult}·{n} + {off} = {mult * n + off}")
        print(f"  Actual T^{k}({n}) = {orbit[k]}")
        print(f"  Match: {int(mult * n + off) == orbit[k]}")
        print()


def demo_composition_law():
    """Demonstrate the composition law for parity words."""
    print("=" * 60)
    print("DEMO 3: Composition Law")
    print("=" * 60)
    print("\naffine_image(w1 ++ w2, q) = affine_image(w1, affine_image(w2, q))\n")

    n = 27
    w_full = parity_word(n, 8)
    w1 = w_full[:4]
    w2 = w_full[4:]

    m_full, o_full = affine_encode(w_full)
    m1, o1 = affine_encode(w1)
    m2, o2 = affine_encode(w2)

    result_full = m_full * n + o_full
    result_composed = m1 * (m2 * n + o2) + o1

    print(f"w_full = {''.join('O' if b else 'E' for b in w_full)}")
    print(f"w1 = {''.join('O' if b else 'E' for b in w1)}, "
          f"w2 = {''.join('O' if b else 'E' for b in w2)}")
    print(f"\nDirect: mult(w_full) = {m_full}, off(w_full) = {o_full}")
    # Chronological composition: w2 wraps around w1
    print(f"Composed: mult(w2)·mult(w1) = {m2 * m1}, "
          f"mult(w2)·off(w1) + off(w2) = {m2 * o1 + o2}")
    print(f"\nMultiplier match: {m_full == m2 * m1}")
    print(f"Offset match: {o_full == m2 * o1 + o2}")
    result_composed = m2 * (m1 * n + o1) + o2
    print(f"Result match: {result_full == result_composed} "
          f"(both = {result_full})")


def demo_parity_ratio():
    """Demonstrate the parity ratio bound."""
    print("\n" + "=" * 60)
    print("DEMO 4: Parity Ratio Bound")
    print("=" * 60)
    print("\nOdd steps ≤ ⌈k/2⌉ in any orbit segment.\n")

    for n in [3, 7, 27, 97, 871]:
        orbit = collatz_orbit(n)
        k = min(20, len(orbit) - 1)
        odd_count = sum(1 for i in range(k) if orbit[i] % 2 == 1)
        bound = (k + 1) // 2
        print(f"n={n:4d}, k={k:2d}: odd_steps={odd_count:2d}, "
              f"bound=⌈{k}/2⌉={bound:2d}, "
              f"satisfies: {odd_count <= bound}")


def demo_stopping_times():
    """Demonstrate stopping time distribution."""
    print("\n" + "=" * 60)
    print("DEMO 5: Stopping Time Distribution")
    print("=" * 60)
    print()

    for N in [100, 1000, 10000]:
        times = [stopping_time(n) for n in range(1, N + 1)]
        max_t = max(times)
        avg_t = sum(times) / len(times)
        import math
        log_N = math.log2(N)
        ratio = max_t / (log_N ** 2)
        print(f"N={N:6d}: max_stop={max_t:4d}, avg={avg_t:.1f}, "
              f"max/(log₂N)²={ratio:.2f}")


def demo_no_cycles():
    """Demonstrate the no-fixed-point and no-2-cycle theorems."""
    print("\n" + "=" * 60)
    print("DEMO 6: No Fixed Points or 2-Cycles")
    print("=" * 60)
    print()

    print("Checking T(n) ≠ n for n = 2..1000:")
    fixed = [n for n in range(2, 1001) if collatz_step(n) == n]
    print(f"  Fixed points found: {fixed if fixed else 'None'}")

    print("\nChecking T(T(n)) ≠ n for n = 2..1000:")
    two_cycles = [n for n in range(2, 1001)
                  if collatz_step(collatz_step(n)) == n]
    print(f"  2-cycles found: {two_cycles if two_cycles else 'None'}")


if __name__ == "__main__":
    demo_orbit_merge()
    demo_parity_encoding()
    demo_composition_law()
    demo_parity_ratio()
    demo_stopping_times()
    demo_no_cycles()


#!/usr/bin/env python3
"""
Visualization: Collatz Orbit Tree Structure
=============================================
Shows how Collatz orbits merge into a tree structure rooted at 1.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def collatz_step(n: int) -> int:
    return n // 2 if n % 2 == 0 else 3 * n + 1


def collatz_orbit(n: int) -> list:
    orbit = [n]
    while n != 1 and len(orbit) < 500:
        n = collatz_step(n)
        orbit.append(n)
    return orbit


def build_tree(max_n: int = 30) -> dict:
    """Build the Collatz tree: edges from n to T(n)."""
    edges = {}
    for n in range(2, max_n + 1):
        edges[n] = collatz_step(n)
    return edges


def plot_orbit_tree():
    """Plot the Collatz tree for small values."""
    fig, axes = plt.subplots(1, 2, figsize=(16, 8))

    # Left: Orbits of several numbers showing merging
    ax = axes[0]
    colors = plt.cm.Set1(np.linspace(0, 1, 8))
    starts = [3, 7, 15, 27, 9, 6, 11, 19]

    for i, n in enumerate(starts):
        orbit = collatz_orbit(n)[:25]
        ax.plot(range(len(orbit)), orbit, '-o', color=colors[i],
                markersize=3, linewidth=1.5, label=f'n={n}', alpha=0.8)

    ax.set_xlabel('Step', fontsize=12)
    ax.set_ylabel('Value', fontsize=12)
    ax.set_title('Collatz Orbits Merge Into Shared Paths', fontsize=14)
    ax.legend(loc='upper right', fontsize=9)
    ax.set_yscale('log')
    ax.grid(True, alpha=0.3)

    # Right: Stopping time distribution
    ax = axes[1]
    N = 1000
    times = []
    for n in range(1, N + 1):
        orbit = collatz_orbit(n)
        times.append(len(orbit) - 1)

    ax.scatter(range(1, N + 1), times, s=1, c=times, cmap='viridis', alpha=0.6)
    ax.set_xlabel('Starting Value n', fontsize=12)
    ax.set_ylabel('Stopping Time', fontsize=12)
    ax.set_title('Stopping Times: The Landscape of Difficulty', fontsize=14)
    ax.grid(True, alpha=0.3)

    # Add bound line
    x = np.arange(2, N + 1)
    bound = 6 * np.log2(x) ** 2
    ax.plot(x, bound, 'r--', alpha=0.5, label='6·(log₂ n)²')
    ax.legend(fontsize=10)

    plt.tight_layout()
    plt.savefig('collatz_orbit_tree.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: collatz_orbit_tree.png")


def plot_parity_encoding():
    """Visualize the parity word encoding and multiplier distribution."""
    fig, axes = plt.subplots(1, 2, figsize=(16, 7))

    # Left: Parity words as binary patterns
    ax = axes[0]
    starts = [27, 31, 41, 47, 63, 73, 97, 111]
    k = 30

    for i, n in enumerate(starts):
        orbit = collatz_orbit(n)[:k + 1]
        parities = [1 if v % 2 == 1 else 0 for v in orbit[:k]]
        for j, p in enumerate(parities):
            color = '#d32f2f' if p == 1 else '#1976d2'
            ax.add_patch(plt.Rectangle((j, len(starts) - 1 - i), 1, 0.8,
                                       facecolor=color, edgecolor='white',
                                       linewidth=0.5))

    ax.set_xlim(0, k)
    ax.set_ylim(-0.5, len(starts))
    ax.set_xlabel('Step', fontsize=12)
    ax.set_ylabel('Starting Value', fontsize=12)
    ax.set_yticks([len(starts) - 1 - i + 0.4 for i in range(len(starts))])
    ax.set_yticklabels([str(n) for n in starts])
    ax.set_title('Parity Words (Red=Odd, Blue=Even)', fontsize=14)

    red_patch = mpatches.Patch(color='#d32f2f', label='Odd')
    blue_patch = mpatches.Patch(color='#1976d2', label='Even')
    ax.legend(handles=[red_patch, blue_patch], loc='upper right')

    # Right: Multiplier values for different word lengths
    ax = axes[1]
    from fractions import Fraction

    for n in [7, 27, 97, 231]:
        mults = []
        orbit = collatz_orbit(n)
        for length in range(1, min(40, len(orbit))):
            word = [v % 2 == 1 for v in orbit[:length]]
            s = sum(word)
            mult = float(Fraction(3, 1) ** s / Fraction(2, 1) ** length)
            mults.append(mult)
        ax.plot(range(1, len(mults) + 1), mults, '-', linewidth=1.5,
                label=f'n={n}', alpha=0.8)

    ax.axhline(y=1, color='black', linestyle='--', alpha=0.5, label='mult=1')
    ax.set_xlabel('Word Length k', fontsize=12)
    ax.set_ylabel('Multiplier 3^s / 2^k', fontsize=12)
    ax.set_title('Multiplier Decay Along Orbits', fontsize=14)
    ax.set_yscale('log')
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('collatz_parity_encoding.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: collatz_parity_encoding.png")


if __name__ == "__main__":
    plot_orbit_tree()
    plot_parity_encoding()


#!/usr/bin/env python3
"""
Visualization: Collatz Proof Barriers
=======================================
Shows the growth of stopping times and the bounded-universal gap.
"""

import matplotlib.pyplot as plt
import numpy as np
import math


def collatz_step(n: int) -> int:
    return n // 2 if n % 2 == 0 else 3 * n + 1


def stopping_time(n: int) -> int:
    steps = 0
    while n != 1 and steps < 100000:
        n = collatz_step(n)
        steps += 1
    return steps


def peak_value(n: int) -> int:
    peak = n
    while n != 1 and peak < 10**15:
        n = collatz_step(n)
        peak = max(peak, n)
    return peak


def plot_proof_barrier():
    """Visualize the gap between bounded verification and universal proof."""
    fig, axes = plt.subplots(2, 2, figsize=(16, 12))

    # Top-left: Max stopping time growth
    ax = axes[0, 0]
    Ns = [10, 50, 100, 500, 1000, 5000, 10000]
    max_times = []
    for N in Ns:
        max_t = max(stopping_time(n) for n in range(1, N + 1))
        max_times.append(max_t)

    ax.plot(Ns, max_times, 'bo-', markersize=6, linewidth=2, label='max σ(n), n≤N')
    # Fit log^2
    log_vals = [math.log2(N) for N in Ns]
    coeffs = np.polyfit([l**2 for l in log_vals], max_times, 1)
    fit_x = np.linspace(min(Ns), max(Ns), 100)
    fit_y = [coeffs[0] * math.log2(x)**2 + coeffs[1] for x in fit_x]
    ax.plot(fit_x, fit_y, 'r--', alpha=0.7,
            label=f'Fit: {coeffs[0]:.1f}·(log₂N)² + {coeffs[1]:.0f}')
    ax.set_xlabel('N', fontsize=12)
    ax.set_ylabel('Max Stopping Time', fontsize=12)
    ax.set_title('Maximum Stopping Time Growth', fontsize=14)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    # Top-right: Peak value distribution
    ax = axes[0, 1]
    N = 500
    peaks = [(n, peak_value(n)) for n in range(1, N + 1)]
    ns, pvs = zip(*peaks)
    ax.scatter(ns, pvs, s=3, c='darkblue', alpha=0.5)
    ax.set_xlabel('Starting Value n', fontsize=12)
    ax.set_ylabel('Peak Value', fontsize=12)
    ax.set_title('Peak Values: How High Do Orbits Climb?', fontsize=14)
    ax.set_yscale('log')
    ax.grid(True, alpha=0.3)

    # Bottom-left: Residue class behavior mod 4
    ax = axes[1, 0]
    categories = {
        '0 mod 4': [], '1 mod 4': [], '2 mod 4': [], '3 mod 4': []
    }
    for n in range(1, 1001):
        st = stopping_time(n)
        categories[f'{n % 4} mod 4'].append(st)

    positions = range(4)
    data = [categories[f'{i} mod 4'] for i in range(4)]
    bp = ax.boxplot(data, labels=['0 mod 4', '1 mod 4', '2 mod 4', '3 mod 4'],
                    patch_artist=True)
    colors = ['#42a5f5', '#ef5350', '#42a5f5', '#ef5350']
    for patch, color in zip(bp['boxes'], colors):
        patch.set_facecolor(color)
        patch.set_alpha(0.6)
    ax.set_xlabel('Residue Class mod 4', fontsize=12)
    ax.set_ylabel('Stopping Time', fontsize=12)
    ax.set_title('Stopping Times by Residue Class mod 4', fontsize=14)

    # Bottom-right: 2-adic valuation of 3n+1 for odd n
    ax = axes[1, 1]
    odd_ns = list(range(1, 2001, 2))
    v2s = []
    for n in odd_ns:
        val = 3 * n + 1
        v = 0
        while val % 2 == 0:
            val //= 2
            v += 1
        v2s.append(v)

    ax.scatter(odd_ns, v2s, s=2, c=v2s, cmap='plasma', alpha=0.6)
    ax.set_xlabel('Odd n', fontsize=12)
    ax.set_ylabel('ν₂(3n+1)', fontsize=12)
    ax.set_title('2-Adic Valuation of 3n+1: Halving Depth', fontsize=14)
    ax.grid(True, alpha=0.3)

    # Add distribution inset
    inset = ax.inset_axes([0.6, 0.5, 0.35, 0.45])
    vals, counts = np.unique(v2s, return_counts=True)
    inset.bar(vals, counts / len(v2s), color='purple', alpha=0.7)
    expected = [0.5**v for v in vals]
    inset.plot(vals, expected, 'r--', label='2^{-v}')
    inset.set_xlabel('v₂', fontsize=8)
    inset.set_ylabel('frequency', fontsize=8)
    inset.set_title('Distribution', fontsize=9)

    plt.tight_layout()
    plt.savefig('collatz_proof_barrier.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: collatz_proof_barrier.png")


if __name__ == "__main__":
    plot_proof_barrier()
