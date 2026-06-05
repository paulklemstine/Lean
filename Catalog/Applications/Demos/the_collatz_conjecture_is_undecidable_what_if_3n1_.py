#!/usr/bin/env python3
"""
Collatz Undecidability: Numerical Demonstrations

Demonstrates the key mathematical results formalized in Lean 4:
1. Residue class acceleration (mod 4, mod 8)
2. Density contraction statistics
3. Parity exclusion verification
4. Proof resistance analysis
"""

def collatz_step(n: int) -> int:
    """Standard Collatz step: n/2 if even, 3n+1 if odd."""
    return n // 2 if n % 2 == 0 else 3 * n + 1

def collatz_orbit(n: int, max_steps: int = 10000) -> list[int]:
    """Compute the Collatz orbit of n until it reaches 1 or max_steps."""
    orbit = [n]
    while n != 1 and len(orbit) < max_steps:
        n = collatz_step(n)
        orbit.append(n)
    return orbit

def stopping_time(n: int, max_steps: int = 10000) -> int:
    """Number of steps to reach 1, or -1 if not reached."""
    for k in range(max_steps):
        if n == 1:
            return k
        n = collatz_step(n)
    return -1

def peak_value(n: int) -> int:
    """Maximum value in the orbit of n."""
    orbit = collatz_orbit(n)
    return max(orbit)

def parity_word(n: int, k: int) -> list[bool]:
    """Parity word: True at position i iff the i-th iterate is odd."""
    val = n
    word = []
    for _ in range(k):
        word.append(val % 2 == 1)
        val = collatz_step(val)
    return word

def odd_count(word: list[bool]) -> int:
    """Count odd steps in a parity word."""
    return sum(word)

def verify_parity_exclusion(n: int, k: int = 100) -> bool:
    """Verify no consecutive odd values in orbit parity word."""
    word = parity_word(n, k)
    for i in range(len(word) - 1):
        if word[i] and word[i + 1]:
            return False
    return True

def verify_mod4_acceleration(n: int) -> dict:
    """Verify mod-4 acceleration formulas."""
    orbit = collatz_orbit(n, max_steps=5)
    r = n % 4
    result = {"n": n, "n_mod_4": r, "iter_2": orbit[2] if len(orbit) > 2 else None}
    if r == 0:
        result["formula"] = f"n/4 = {n // 4}"
        result["matches"] = (orbit[2] == n // 4) if len(orbit) > 2 else None
    elif r == 1:
        result["formula"] = f"(3n+1)/2 = {(3*n+1)//2}"
        result["matches"] = (orbit[2] == (3*n+1)//2) if len(orbit) > 2 else None
    elif r == 2:
        result["formula"] = f"3*(n/2)+1 = {3*(n//2)+1}"
        result["matches"] = (orbit[2] == 3*(n//2)+1) if len(orbit) > 2 else None
    elif r == 3:
        result["formula"] = f"(3n+1)/2 = {(3*n+1)//2}"
        result["matches"] = (orbit[2] == (3*n+1)//2) if len(orbit) > 2 else None
    return result


def demo_residue_acceleration():
    """Demo 1: Residue class acceleration."""
    print("=" * 60)
    print("DEMO 1: Residue Class Acceleration (Mod 4)")
    print("=" * 60)
    for n in [4, 8, 12, 16, 20]:  # 0 mod 4
        r = verify_mod4_acceleration(n)
        print(f"  n={n:4d} (mod 4 = {r['n_mod_4']}): iter(n,2) = {r['iter_2']}, "
              f"formula = {r['formula']}, matches = {r['matches']}")
    for n in [1, 5, 9, 13, 17]:  # 1 mod 4
        r = verify_mod4_acceleration(n)
        print(f"  n={n:4d} (mod 4 = {r['n_mod_4']}): iter(n,2) = {r['iter_2']}, "
              f"formula = {r['formula']}, matches = {r['matches']}")
    for n in [2, 6, 10, 14, 18]:  # 2 mod 4
        r = verify_mod4_acceleration(n)
        print(f"  n={n:4d} (mod 4 = {r['n_mod_4']}): iter(n,2) = {r['iter_2']}, "
              f"formula = {r['formula']}, matches = {r['matches']}")
    for n in [3, 7, 11, 15, 19]:  # 3 mod 4
        r = verify_mod4_acceleration(n)
        print(f"  n={n:4d} (mod 4 = {r['n_mod_4']}): iter(n,2) = {r['iter_2']}, "
              f"formula = {r['formula']}, matches = {r['matches']}")


def demo_density_contraction():
    """Demo 2: Density contraction statistics."""
    print("\n" + "=" * 60)
    print("DEMO 2: Odd Density and Contraction")
    print("=" * 60)
    print(f"  {'n':>6} {'steps':>6} {'odd':>6} {'even':>6} {'density':>8} {'peak':>10} {'contracts':>10}")
    print("  " + "-" * 58)
    for n in [27, 97, 171, 231, 447, 871, 6171]:
        orbit = collatz_orbit(n)
        k = len(orbit) - 1
        word = parity_word(n, k)
        o = odd_count(word)
        e = k - o
        density = o / k if k > 0 else 0
        pk = peak_value(n)
        contracts = "YES" if 2 * o <= e else "NO"
        print(f"  {n:6d} {k:6d} {o:6d} {e:6d} {density:8.4f} {pk:10d} {contracts:>10}")

    # Verify 3^j < 2^(2j) for relevant densities
    print("\n  Key inequality: 3^j < 2^(2j)")
    for j in range(1, 10):
        print(f"    j={j}: 3^{j} = {3**j}, 2^{2*j} = {2**(2*j)}, "
              f"ratio = {3**j / 2**(2*j):.6f}")


def demo_parity_exclusion():
    """Demo 3: Parity exclusion verification."""
    print("\n" + "=" * 60)
    print("DEMO 3: Parity Exclusion (No Consecutive Odds)")
    print("=" * 60)
    for n in [1, 7, 27, 97, 231, 871, 6171, 77031]:
        passed = verify_parity_exclusion(n, k=500)
        orbit = collatz_orbit(n, max_steps=500)
        k = min(len(orbit) - 1, 500)
        word = parity_word(n, k)
        o = odd_count(word)
        bound = (k + 1) // 2
        print(f"  n={n:6d}: exclusion holds = {passed}, "
              f"odd steps = {o}, bound ⌊(k+1)/2⌋ = {bound}, "
              f"within bound = {o <= bound}")


def demo_proof_resistance():
    """Demo 4: Proof resistance analysis."""
    print("\n" + "=" * 60)
    print("DEMO 4: Proof Resistance (Verification Difficulty)")
    print("=" * 60)
    import math
    print(f"  {'n':>8} {'stop_time':>10} {'peak':>12} {'log2_peak':>10} {'resistance':>12}")
    print("  " + "-" * 54)
    for n in [27, 97, 231, 447, 871, 6171, 77031, 837799]:
        st = stopping_time(n)
        pk = peak_value(n)
        log_pk = math.log2(pk) if pk > 0 else 0
        resistance = st * (int(log_pk) + 1)
        print(f"  {n:8d} {st:10d} {pk:12d} {log_pk:10.2f} {resistance:12d}")


def demo_power_of_two_halvings():
    """Demo 5: Power-of-two halvings theorem."""
    print("\n" + "=" * 60)
    print("DEMO 5: Power-of-Two Halvings (2^k · m → m in k steps)")
    print("=" * 60)
    for m in [1, 3, 5, 7, 11]:
        for k in range(1, 6):
            n = (2**k) * m
            orbit = collatz_orbit(n, max_steps=k+1)
            result = orbit[k] if len(orbit) > k else "?"
            print(f"  2^{k}·{m} = {n:5d} → iter({n}, {k}) = {result} "
                  f"(expected {m}, match = {result == m})")


if __name__ == "__main__":
    demo_residue_acceleration()
    demo_density_contraction()
    demo_parity_exclusion()
    demo_proof_resistance()
    demo_power_of_two_halvings()


#!/usr/bin/env python3
"""
Visualization: Collatz Orbit Density and Contraction

Generates plots showing:
1. Odd-step density vs stopping time
2. Density contraction threshold
3. Proof resistance landscape
"""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import math


def collatz_step(n: int) -> int:
    return n // 2 if n % 2 == 0 else 3 * n + 1

def stopping_time(n: int, max_steps: int = 100000) -> int:
    for k in range(max_steps):
        if n == 1:
            return k
        n = collatz_step(n)
    return -1

def peak_value(n: int) -> int:
    peak = n
    val = n
    while val != 1:
        val = collatz_step(val)
        peak = max(peak, val)
    return peak

def odd_density(n: int) -> float:
    val = n
    odd_count = 0
    total = 0
    while val != 1:
        if val % 2 == 1:
            odd_count += 1
        total += 1
        val = collatz_step(val)
    return odd_count / total if total > 0 else 0.0


def plot_density_vs_stopping_time():
    """Plot odd-step density vs stopping time for n ∈ [1, 5000]."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    
    ns = range(2, 5001)
    densities = []
    stop_times = []
    for n in ns:
        d = odd_density(n)
        st = stopping_time(n)
        densities.append(d)
        stop_times.append(st)
    
    # Left: density histogram
    ax = axes[0]
    ax.hist(densities, bins=50, color='steelblue', alpha=0.7, edgecolor='black')
    ax.axvline(x=1/3, color='red', linestyle='--', linewidth=2,
               label='Contraction threshold (1/3)')
    ax.axvline(x=0.5, color='orange', linestyle='--', linewidth=2,
               label='Parity exclusion bound (1/2)')
    ax.set_xlabel('Odd-Step Density', fontsize=12)
    ax.set_ylabel('Count', fontsize=12)
    ax.set_title('Distribution of Odd-Step Density\n(n = 2 to 5000)', fontsize=13)
    ax.legend(fontsize=10)
    
    # Right: density vs stopping time
    ax = axes[1]
    scatter = ax.scatter(stop_times, densities, c=list(ns), cmap='viridis',
                         s=3, alpha=0.5)
    ax.axhline(y=1/3, color='red', linestyle='--', linewidth=2,
               label='Contraction threshold')
    ax.axhline(y=0.5, color='orange', linestyle='--', linewidth=2,
               label='Parity exclusion bound')
    ax.set_xlabel('Stopping Time', fontsize=12)
    ax.set_ylabel('Odd-Step Density', fontsize=12)
    ax.set_title('Odd Density vs Stopping Time', fontsize=13)
    ax.legend(fontsize=10)
    plt.colorbar(scatter, ax=ax, label='Starting value n')
    
    plt.tight_layout()
    plt.savefig('collatz_density_analysis.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: collatz_density_analysis.png")


def plot_proof_resistance():
    """Plot proof resistance landscape."""
    fig, ax = plt.subplots(figsize=(10, 6))
    
    ns = range(2, 10001)
    resistances = []
    for n in ns:
        st = stopping_time(n)
        pk = peak_value(n)
        log_pk = math.log2(pk) if pk > 0 else 0
        resistance = st * (int(log_pk) + 1)
        resistances.append(resistance)
    
    ax.scatter(list(ns), resistances, s=1, alpha=0.3, c='darkblue')
    ax.set_xlabel('Starting Value n', fontsize=12)
    ax.set_ylabel('Proof Resistance', fontsize=12)
    ax.set_title('Proof Resistance Landscape\n'
                 '(stopping_time × log₂(peak))', fontsize=13)
    ax.set_yscale('log')
    
    # Highlight extreme values
    max_idx = np.argmax(resistances)
    ax.annotate(f'n={max_idx+2}\nR={resistances[max_idx]}',
                xy=(max_idx+2, resistances[max_idx]),
                fontsize=9, color='red',
                arrowprops=dict(arrowstyle='->', color='red'))
    
    plt.tight_layout()
    plt.savefig('collatz_proof_resistance.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: collatz_proof_resistance.png")


def plot_contraction_inequality():
    """Plot the key inequality 3^j vs 2^(2j)."""
    fig, ax = plt.subplots(figsize=(8, 6))
    
    js = np.arange(0, 20)
    pow3 = 3.0 ** js
    pow4 = 4.0 ** js
    
    ax.semilogy(js, pow3, 'ro-', label='3^j (odd-step growth)', markersize=6)
    ax.semilogy(js, pow4, 'bs-', label='4^j = 2^(2j) (two even-step shrinkage)',
                markersize=6)
    ax.fill_between(js, pow3, pow4, alpha=0.2, color='green',
                    label='Contraction gap')
    ax.set_xlabel('j (number of odd steps)', fontsize=12)
    ax.set_ylabel('Factor', fontsize=12)
    ax.set_title('The Contraction Engine: 3^j < 4^j\n'
                 'Each odd step can be "paid for" by two even steps',
                 fontsize=13)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('collatz_contraction_inequality.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: collatz_contraction_inequality.png")


if __name__ == "__main__":
    plot_density_vs_stopping_time()
    plot_proof_resistance()
    plot_contraction_inequality()
