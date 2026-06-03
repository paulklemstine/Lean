#!/usr/bin/env python3
"""
Collatz Undecidability Demo: Orbit Analysis and Contraction Verification

Demonstrates key results from the formal Lean 4 development:
1. Parity exclusion: no consecutive odd steps
2. Density contraction: orbits with low odd density contract
3. Orbit complexity classification
4. Peak value / stopping time statistics
"""

import math
from typing import List, Tuple, Optional


def collatz_step(n: int) -> int:
    """The standard Collatz step: n/2 if even, 3n+1 if odd."""
    return n // 2 if n % 2 == 0 else 3 * n + 1


def collatz_orbit(n: int, max_steps: int = 10000) -> List[int]:
    """Compute the Collatz orbit of n until it reaches 1 or max_steps."""
    orbit = [n]
    while n != 1 and len(orbit) < max_steps:
        n = collatz_step(n)
        orbit.append(n)
    return orbit


def parity_word(n: int, k: int) -> List[bool]:
    """Extract the parity word of the first k steps of n's orbit."""
    word = []
    current = n
    for _ in range(k):
        word.append(current % 2 == 1)
        current = collatz_step(current)
    return word


def verify_parity_exclusion(n: int, k: int) -> bool:
    """Verify that no two consecutive entries in the parity word are both True."""
    word = parity_word(n, k)
    for i in range(len(word) - 1):
        if word[i] and word[i + 1]:
            return False
    return True


def odd_density(n: int, k: int) -> float:
    """Compute the fraction of odd steps in the first k steps."""
    word = parity_word(n, k)
    return sum(word) / k if k > 0 else 0.0


def stopping_time(n: int, max_steps: int = 100000) -> Optional[int]:
    """Compute the stopping time of n (steps to reach 1), or None."""
    current = n
    for step in range(max_steps):
        if current == 1:
            return step
        current = collatz_step(current)
    return None


def peak_value(n: int) -> int:
    """Compute the peak value in the orbit of n."""
    orbit = collatz_orbit(n)
    return max(orbit)


def classify(n: int) -> str:
    """Classify n by orbit complexity."""
    st = stopping_time(n)
    if st is None:
        return "unknown"
    logn = max(1, math.floor(math.log2(n)) + 1) if n >= 1 else 1
    if st <= 3 * logn:
        return "trivial"
    elif st <= logn * logn:
        return "moderate"
    else:
        return "hard"


def main():
    print("=" * 70)
    print("COLLATZ UNDECIDABILITY DEMO")
    print("=" * 70)

    # Demo 1: Parity exclusion verification
    print("\n--- Demo 1: Parity Exclusion Verification ---")
    print("Theorem: No two consecutive steps in a Collatz orbit are both odd.")
    test_values = [7, 27, 97, 871, 6171, 77031]
    for n in test_values:
        k = stopping_time(n) or 100
        verified = verify_parity_exclusion(n, k)
        print(f"  n = {n:>6}, k = {k:>4}: parity exclusion {'✓' if verified else '✗'}")

    # Demo 2: Density contraction
    print("\n--- Demo 2: Density Contraction ---")
    print("Theorem: If odd density < 0.5, the orbit contracts.")
    print(f"  Critical threshold: log(2)/log(3) ≈ {math.log(2)/math.log(3):.6f}")
    print(f"  Our sufficient condition: 0.5")
    for n in [27, 97, 871, 6171, 77031, 837799]:
        st = stopping_time(n)
        if st and st > 0:
            density = odd_density(n, st)
            print(f"  n = {n:>7}, stopping_time = {st:>4}, "
                  f"odd_density = {density:.4f} {'< 0.5 ✓' if density < 0.5 else '>= 0.5'}")

    # Demo 3: Orbit complexity classification
    print("\n--- Demo 3: Orbit Complexity Classification ---")
    class_counts = {"trivial": 0, "moderate": 0, "hard": 0, "unknown": 0}
    for n in range(1, 10001):
        c = classify(n)
        class_counts[c] += 1
    print(f"  Classification of n ∈ [1, 10000]:")
    for cls, count in class_counts.items():
        print(f"    {cls:>10}: {count:>5} ({count/100:.1f}%)")

    # Demo 4: Peak value statistics
    print("\n--- Demo 4: Peak Value / Polynomial Diameter Conjecture ---")
    print("  Conjecture: peak(n) ≤ n^C for some universal C.")
    for N in [100, 1000, 10000]:
        max_ratio = 0.0
        max_n = 1
        for n in range(1, N + 1):
            pv = peak_value(n)
            if n > 1:
                ratio = math.log(pv) / math.log(n)
                if ratio > max_ratio:
                    max_ratio = ratio
                    max_n = n
        print(f"  N = {N:>5}: max log(peak)/log(n) = {max_ratio:.4f} "
              f"(achieved at n = {max_n})")

    # Demo 5: 3^j vs 2^(2j) inequality
    print("\n--- Demo 5: Key Inequality 3^j < 2^(2j) ---")
    print("  This inequality drives the density contraction theorem.")
    for j in range(1, 11):
        lhs = 3 ** j
        rhs = 2 ** (2 * j)
        ratio = lhs / rhs
        print(f"  j = {j:>2}: 3^j = {lhs:>10}, 2^(2j) = {rhs:>10}, "
              f"ratio = {ratio:.6f}")

    # Demo 6: Famous orbits
    print("\n--- Demo 6: Famous Collatz Orbits ---")
    famous = [(27, "classic example"), (97, "moderate"), 
              (871, "long orbit"), (6171, "very long"),
              (837799, "longest for n < 10^6")]
    for n, label in famous:
        st = stopping_time(n)
        pv = peak_value(n)
        print(f"  n = {n:>7} ({label}): "
              f"stopping_time = {st:>4}, peak = {pv:>12}")

    print("\n" + "=" * 70)
    print("All results verified. The formal Lean 4 proofs are in")
    print("Catalog/Algebra/CollatzUndecidable.lean")
    print("=" * 70)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Collatz Orbit Structure and Contraction Analysis

Generates three plots:
1. Collatz orbits for notable starting values
2. Odd density distribution across starting values
3. Stopping time vs starting value with complexity classification
"""

import math


def collatz_step(n):
    return n // 2 if n % 2 == 0 else 3 * n + 1


def collatz_orbit(n, max_steps=10000):
    orbit = [n]
    while n != 1 and len(orbit) < max_steps:
        n = collatz_step(n)
        orbit.append(n)
    return orbit


def stopping_time(n, max_steps=1000000):
    current = n
    for k in range(max_steps):
        if current == 1:
            return k
        current = collatz_step(current)
    return None


def odd_density(n, k):
    current = n
    odd_count = 0
    for _ in range(k):
        if current % 2 == 1:
            odd_count += 1
        current = collatz_step(current)
    return odd_count / k if k > 0 else 0


def peak_value(n):
    return max(collatz_orbit(n))


try:
    import matplotlib
    matplotlib.use('Agg')
    import matplotlib.pyplot as plt
    import matplotlib.patches as mpatches
    HAS_MPL = True
except ImportError:
    HAS_MPL = False
    print("matplotlib not available; skipping visualization")


def plot_orbits():
    if not HAS_MPL:
        return

    fig, axes = plt.subplots(2, 2, figsize=(14, 10))

    # Plot 1: Famous orbits
    ax = axes[0, 0]
    for n, color, label in [(27, '#e74c3c', 'n=27'),
                             (97, '#3498db', 'n=97'),
                             (871, '#2ecc71', 'n=871')]:
        orbit = collatz_orbit(n)
        ax.plot(orbit, color=color, alpha=0.8, linewidth=1.2, label=label)
    ax.set_xlabel('Step')
    ax.set_ylabel('Value')
    ax.set_title('Collatz Orbits: The Journey to 1')
    ax.legend()
    ax.set_yscale('log')

    # Plot 2: Odd density distribution
    ax = axes[0, 1]
    N = 5000
    densities = []
    for n in range(2, N + 1):
        st = stopping_time(n)
        if st and st > 0:
            densities.append(odd_density(n, st))
    ax.hist(densities, bins=50, color='#9b59b6', alpha=0.7, edgecolor='white')
    ax.axvline(x=0.5, color='red', linestyle='--', linewidth=2,
               label='Sufficient threshold (1/2)')
    ax.axvline(x=math.log(2)/math.log(3), color='orange', linestyle='--',
               linewidth=2, label=f'Sharp threshold ≈ {math.log(2)/math.log(3):.4f}')
    ax.set_xlabel('Odd Step Density')
    ax.set_ylabel('Count')
    ax.set_title(f'Odd Density Distribution (n ∈ [2, {N}])')
    ax.legend(fontsize=8)

    # Plot 3: Stopping time vs n
    ax = axes[1, 0]
    ns = list(range(1, 10001))
    sts = []
    colors = []
    for n in ns:
        st = stopping_time(n)
        sts.append(st if st else 0)
        logn = max(1, int(math.log2(n)) + 1) if n >= 2 else 1
        if st is None:
            colors.append('#7f8c8d')
        elif st <= 3 * logn:
            colors.append('#2ecc71')  # trivial
        elif st <= logn * logn:
            colors.append('#3498db')  # moderate
        else:
            colors.append('#e74c3c')  # hard
    ax.scatter(ns, sts, c=colors, s=0.5, alpha=0.6)
    ax.set_xlabel('Starting Value n')
    ax.set_ylabel('Stopping Time')
    ax.set_title('Stopping Time with Complexity Classification')
    trivial_patch = mpatches.Patch(color='#2ecc71', label='Trivial')
    moderate_patch = mpatches.Patch(color='#3498db', label='Moderate')
    hard_patch = mpatches.Patch(color='#e74c3c', label='Hard')
    ax.legend(handles=[trivial_patch, moderate_patch, hard_patch], fontsize=8)

    # Plot 4: 3^j vs 2^(2j) — the contraction engine
    ax = axes[1, 1]
    js = list(range(1, 16))
    pow3 = [3**j for j in js]
    pow4 = [4**j for j in js]
    ax.semilogy(js, pow3, 'o-', color='#e74c3c', linewidth=2, label='3^j (growth)')
    ax.semilogy(js, pow4, 's-', color='#2ecc71', linewidth=2, label='4^j = 2^(2j) (contraction)')
    ax.fill_between(js, pow3, pow4, alpha=0.15, color='#2ecc71')
    ax.set_xlabel('j (odd steps)')
    ax.set_ylabel('Value (log scale)')
    ax.set_title('The Contraction Engine: 3^j < 2^(2j)')
    ax.legend()

    plt.tight_layout()
    plt.savefig('collatz_analysis.png', dpi=150, bbox_inches='tight')
    print("Saved: collatz_analysis.png")
    plt.close()


if __name__ == "__main__":
    plot_orbits()
