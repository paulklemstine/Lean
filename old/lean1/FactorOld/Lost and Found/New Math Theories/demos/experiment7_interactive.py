#!/usr/bin/env python3
"""
╔════════════════════════════════════════════════════════════════╗
║        INTERACTIVE MATHEMATICAL EXPLORER                       ║
║        Exploring the Hidden Architecture of Numbers            ║
║                                                                ║
║  Run this script and explore the concepts from our paper!      ║
╚════════════════════════════════════════════════════════════════╝

This interactive demo lets you explore:
  1. The Arithmetic Derivative and its orbits
  2. The Collatz Merge Distance metric
  3. Cross-Base Resonance Index
  4. Prime Gap Curvature
  5. Multiplicative Persistence
"""

import math
from collections import Counter

# ─── Core Functions ───────────────────────────────────────────

def factorize(n):
    if n <= 1:
        return []
    factors = []
    d = 2
    while d * d <= n:
        exp = 0
        while n % d == 0:
            exp += 1
            n //= d
        if exp > 0:
            factors.append((d, exp))
        d += 1
    if n > 1:
        factors.append((n, 1))
    return factors

def arithmetic_derivative(n):
    if n <= 1:
        return 0
    factors = factorize(n)
    return sum(n * e // p for p, e in factors)

def is_prime(n):
    if n < 2: return False
    if n < 4: return True
    if n % 2 == 0 or n % 3 == 0: return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i + 2) == 0: return False
        i += 6
    return True

def digit_sum(n, base=10):
    s = 0
    while n > 0:
        s += n % base
        n //= base
    return s

def digits(n, base=10):
    if n == 0: return [0]
    d = []
    while n > 0:
        d.append(n % base)
        n //= base
    return d

def resonance_index(n, bases=range(2, 20)):
    ratios = []
    for b in bases:
        if n >= b:
            d = digits(n, b)
            if d:
                digit_mean = sum(d) / len(d)
                max_digit = b - 1
                ratios.append(digit_mean / max_digit if max_digit > 0 else 0)
    if len(ratios) < 2:
        return 0
    mean_r = sum(ratios) / len(ratios)
    return sum((r - mean_r)**2 for r in ratios) / len(ratios)

def multiplicative_persistence(n, base=10):
    steps = 0
    while n >= base:
        product = 1
        while n > 0:
            product *= n % base
            n //= base
        n = product
        steps += 1
    return steps

# ─── Display Functions ────────────────────────────────────────

def explore_arithmetic_derivative(n):
    """Deep exploration of the arithmetic derivative of n."""
    print(f"\n{'═' * 50}")
    print(f"  ARITHMETIC DERIVATIVE EXPLORER: n = {n}")
    print(f"{'═' * 50}")
    
    factors = factorize(n)
    nd = arithmetic_derivative(n)
    
    print(f"\n  Factorization: {n} = ", end="")
    parts = [f"{p}^{e}" if e > 1 else str(p) for p, e in factors]
    print(" × ".join(parts) if parts else "1")
    
    print(f"  n' = {nd}")
    print(f"  n'/n = {nd/n:.6f}" if n > 0 else "")
    
    if nd == n:
        print(f"  ★ FIXED POINT! {n} = {n}'")
    elif nd == 1:
        print(f"  ◆ Prime number (derivative = 1)")
    
    # Compute orbit
    print(f"\n  Orbit: ", end="")
    current = n
    orbit = [current]
    for _ in range(15):
        nd = arithmetic_derivative(current)
        if nd > 10**12:
            print(f" → ∞ (diverges)")
            break
        orbit.append(nd)
        if nd == current:
            print(f" → ⊙ (fixed point)")
            break
        if nd <= 1:
            print(f" → {nd} (terminates)")
            break
        current = nd
    else:
        print(" ...")
    
    print(f"  Full orbit: {' → '.join(str(x) for x in orbit[:12])}")
    
    # Acceleration
    if len(orbit) >= 3:
        acc = orbit[2] - 2*orbit[1] + orbit[0]
        print(f"\n  Acceleration (n'' - 2n' + n) = {acc}")
        if acc > 0:
            print(f"  → Orbit is ACCELERATING (convex)")
        elif acc < 0:
            print(f"  → Orbit is DECELERATING (concave)")
        else:
            print(f"  → Orbit has ZERO acceleration (linear)")

def explore_collatz_distance(a, b):
    """Explore the Collatz merge distance between two numbers."""
    print(f"\n{'═' * 50}")
    print(f"  COLLATZ MERGE DISTANCE: {a} and {b}")
    print(f"{'═' * 50}")
    
    orbit_a = [a]
    orbit_b = [b]
    set_a = {a: 0}
    set_b = {b: 0}
    
    va, vb = a, b
    merge_step = -1
    merge_val = -1
    
    for step in range(1, 200):
        if va != 1:
            va = va // 2 if va % 2 == 0 else 3 * va + 1
            orbit_a.append(va)
            set_a[va] = step
        if vb != 1:
            vb = vb // 2 if vb % 2 == 0 else 3 * vb + 1
            orbit_b.append(vb)
            set_b[vb] = step
        
        for v in set_a:
            if v in set_b:
                merge_step = set_a[v] + set_b[v]
                merge_val = v
                break
        if merge_val > 0:
            break
    
    print(f"\n  Orbit of {a}: {' → '.join(str(x) for x in orbit_a[:15])}...")
    print(f"  Orbit of {b}: {' → '.join(str(x) for x in orbit_b[:15])}...")
    
    if merge_val > 0:
        print(f"\n  ✦ Orbits merge at value {merge_val}")
        print(f"    Distance d({a}, {b}) = {merge_step}")
        print(f"    ({a} reaches {merge_val} in {set_a[merge_val]} steps)")
        print(f"    ({b} reaches {merge_val} in {set_b[merge_val]} steps)")
    else:
        print(f"\n  Orbits did not merge within 200 steps")

def explore_resonance(n):
    """Explore the resonance index and multi-base representation of n."""
    print(f"\n{'═' * 50}")
    print(f"  RESONANCE INDEX EXPLORER: n = {n}")
    print(f"{'═' * 50}")
    
    ri = resonance_index(n)
    print(f"\n  Resonance Index R({n}) = {ri:.6f}")
    
    if ri < 0.01:
        print(f"  → HARMONIOUS: similar digit efficiency across bases")
    elif ri > 0.05:
        print(f"  → DISCORDANT: very different behavior across bases")
    else:
        print(f"  → MODERATE resonance")
    
    print(f"\n  Multi-base representations:")
    for base in [2, 3, 5, 7, 8, 10, 12, 16]:
        d = digits(n, base)
        d_str = ''.join(str(x) if x < 10 else chr(55+x) for x in reversed(d))
        ds = digit_sum(n, base)
        print(f"    Base {base:2d}: {d_str:>20s}  (digit sum = {ds})")
    
    # Multiplicative persistence
    mp = multiplicative_persistence(n)
    print(f"\n  Multiplicative persistence (base 10): {mp}")
    
    # Show persistence chain
    current = n
    chain = [current]
    while current >= 10:
        product = 1
        while current > 0:
            product *= current % 10
            current //= 10
        current = product
        chain.append(current)
    print(f"  Chain: {' → '.join(str(x) for x in chain)}")

# ─── Main Demo ────────────────────────────────────────────────

def main():
    print("╔════════════════════════════════════════════════════════════╗")
    print("║    THE HIDDEN ARCHITECTURE OF NUMBERS                     ║")
    print("║    Interactive Mathematical Explorer                      ║")
    print("╚════════════════════════════════════════════════════════════╝")
    
    # Demo 1: The p^p Fixed Points
    print("\n\n▶ SECTION 1: THE p^p FIXED POINT THEOREM")
    print("  The arithmetic derivative has exactly the fixed points p^p")
    print("  for prime p: 4, 27, 3125, 823543, ...")
    
    for p in [2, 3, 5, 7]:
        explore_arithmetic_derivative(p ** p)
    
    # Demo 2: Interesting orbits
    print("\n\n▶ SECTION 2: FASCINATING ORBITS")
    for n in [6, 15, 33, 64, 100, 256]:
        explore_arithmetic_derivative(n)
    
    # Demo 3: Collatz Metric
    print("\n\n▶ SECTION 3: THE COLLATZ MERGE METRIC")
    print("  A new metric on positive integers based on orbit merging")
    
    for a, b in [(7, 11), (15, 27), (42, 100), (64, 128)]:
        explore_collatz_distance(a, b)
    
    # Demo 4: Resonance
    print("\n\n▶ SECTION 4: THE RESONANCE INDEX")
    print("  How harmoniously does a number behave across bases?")
    
    for n in [3, 7, 15, 42, 100, 255, 1000, 8412]:
        explore_resonance(n)
    
    # Demo 5: Summary statistics
    print("\n\n▶ SECTION 5: STATISTICAL LANDSCAPE")
    print("═" * 50)
    
    # Fixed points
    print("\nArithmetic derivative fixed points p^p for p ≤ 13:")
    for p in [2, 3, 5, 7, 11, 13]:
        pp = p**p
        nd = arithmetic_derivative(pp)
        print(f"  {p}^{p} = {pp:>15,}: {'✓ FIXED' if nd == pp else '✗ ERROR'}")
    
    # Highest resonance numbers up to 1000
    print("\nTop 10 most resonant numbers ≤ 1000:")
    res_list = [(n, resonance_index(n)) for n in range(2, 1001)]
    res_list.sort(key=lambda x: -x[1])
    for n, r in res_list[:10]:
        prime_str = " (prime)" if is_prime(n) else ""
        print(f"  n={n:4d}: R = {r:.6f}{prime_str}")
    
    # Highest multiplicative persistence
    print("\nHighest multiplicative persistence ≤ 10^6:")
    best = {}
    for n in range(1, 1000001):
        mp = multiplicative_persistence(n)
        if mp not in best or n < best[mp]:
            best[mp] = n
    for mp in sorted(best.keys()):
        print(f"  Persistence {mp}: smallest example = {best[mp]:,}")

    print("\n" + "═" * 60)
    print("  Explorer complete! See paper/paper.md for full analysis.")
    print("═" * 60)

if __name__ == "__main__":
    main()
