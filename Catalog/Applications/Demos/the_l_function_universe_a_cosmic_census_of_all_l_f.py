#!/usr/bin/env python3
"""
The L-Function Universe: Numerical Demonstrations

Demonstrates key properties of the Selberg class: countability via
enumeration, spectral complexity ordering, conductor counting functions,
and density estimates for Dirichlet L-functions.
"""

import math
from collections import defaultdict


def euler_totient(n: int) -> int:
    """Compute Euler's totient function φ(n)."""
    if n <= 0:
        return 0
    result = n
    p = 2
    temp = n
    while p * p <= temp:
        if temp % p == 0:
            while temp % p == 0:
                temp //= p
            result -= result // p
        p += 1
    if temp > 1:
        result -= result // temp
    return result


def count_dirichlet_characters(Q: int) -> int:
    """Count total Dirichlet characters with modulus ≤ Q.
    
    For each modulus n, there are φ(n) Dirichlet characters mod n.
    The total count is ∑_{n=1}^{Q} φ(n).
    """
    return sum(euler_totient(n) for n in range(1, Q + 1))


def totient_sum_asymptotic(Q: int) -> float:
    """Asymptotic estimate: ∑_{n≤Q} φ(n) ~ 3Q²/π²."""
    return 3 * Q**2 / (math.pi**2)


def spectral_complexity(degree: int, conductor: int,
                         spectral_params: list[tuple[float, float]]) -> float:
    """Compute the spectral complexity of a Selberg datum."""
    param_sum = sum(abs(r) + abs(s) for r, s in spectral_params)
    return degree + conductor + param_sum


def enumerate_selberg_data(max_complexity: float) -> list[dict]:
    """Enumerate Selberg data with spectral complexity ≤ max_complexity.
    
    For simplicity, restrict to integer spectral parameters.
    This demonstrates the finiteness of the set below any bound.
    """
    results = []
    max_degree = int(max_complexity)
    
    for d in range(max_degree + 1):
        max_cond = int(max_complexity - d)
        if max_cond < 1:
            continue
        for q in range(1, max_cond + 1):
            remaining = max_complexity - d - q
            if remaining < 0:
                continue
            if d == 0:
                # No spectral parameters
                results.append({
                    'degree': d, 'conductor': q,
                    'spectral_params': [], 
                    'complexity': d + q
                })
            elif d == 1:
                # One spectral parameter (r, s) with |r| + |s| ≤ remaining
                bound = int(remaining)
                for r in range(-bound, bound + 1):
                    s_bound = bound - abs(r)
                    for s in range(-s_bound, s_bound + 1):
                        c = spectral_complexity(d, q, [(r, s)])
                        if c <= max_complexity:
                            results.append({
                                'degree': d, 'conductor': q,
                                'spectral_params': [(r, s)],
                                'complexity': c
                            })
    return sorted(results, key=lambda x: x['complexity'])


def conductor_counting_function(data: list[dict], Q: int) -> int:
    """Count data with conductor ≤ Q."""
    return sum(1 for d in data if d['conductor'] <= Q)


def main():
    print("=" * 70)
    print("THE L-FUNCTION UNIVERSE: NUMERICAL DEMONSTRATIONS")
    print("=" * 70)
    
    # Demo 1: Dirichlet character counts
    print("\n--- Demo 1: Dirichlet Character Counts ---")
    print(f"{'Q':>6} {'Σφ(n)':>10} {'3Q²/π²':>12} {'Ratio':>8}")
    print("-" * 40)
    for Q in [10, 50, 100, 500, 1000, 5000, 10000]:
        actual = count_dirichlet_characters(Q)
        asymp = totient_sum_asymptotic(Q)
        ratio = actual / asymp if asymp > 0 else 0
        print(f"{Q:>6} {actual:>10} {asymp:>12.1f} {ratio:>8.4f}")
    
    # Demo 2: Enumerate low-complexity Selberg data
    print("\n--- Demo 2: Selberg Data Enumeration (complexity ≤ 8) ---")
    data = enumerate_selberg_data(8)
    print(f"Total Selberg data with integer params and complexity ≤ 8: {len(data)}")
    print("\nFirst 20 by complexity:")
    print(f"{'#':>3} {'d':>3} {'q':>4} {'params':>20} {'complexity':>12}")
    print("-" * 50)
    for i, datum in enumerate(data[:20]):
        params_str = str(datum['spectral_params']) if datum['spectral_params'] else '[]'
        print(f"{i+1:>3} {datum['degree']:>3} {datum['conductor']:>4} "
              f"{params_str:>20} {datum['complexity']:>12.1f}")
    
    # Demo 3: Growth by complexity level
    print("\n--- Demo 3: Growth of N(C) = #{data with complexity ≤ C} ---")
    print(f"{'C':>6} {'N(C)':>8} {'ΔN':>6}")
    prev = 0
    for C in range(1, 16):
        count = len([d for d in enumerate_selberg_data(C)])
        print(f"{C:>6} {count:>8} {count - prev:>6}")
        prev = count
    
    # Demo 4: Conductor counting monotonicity
    print("\n--- Demo 4: Conductor Counting Function (monotonicity) ---")
    all_data = enumerate_selberg_data(10)
    print(f"{'Q':>4} {'N(Q)':>6}")
    for Q in range(1, 12):
        n_q = conductor_counting_function(all_data, Q)
        print(f"{Q:>4} {n_q:>6}")
    
    # Demo 5: Degree distribution
    print("\n--- Demo 5: Degree Distribution (complexity ≤ 10) ---")
    data10 = enumerate_selberg_data(10)
    degree_counts = defaultdict(int)
    for d in data10:
        degree_counts[d['degree']] += 1
    for deg in sorted(degree_counts.keys()):
        print(f"  Degree {deg}: {degree_counts[deg]} data")
    
    print("\n" + "=" * 70)
    print("KEY INSIGHT: The Selberg class is countable — there are only")
    print("as many well-behaved L-functions as there are natural numbers.")
    print("Each one contains infinite depth, but there are countably many.")
    print("=" * 70)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Spectral complexity distribution of L-functions.

Shows how the number of Selberg data grows with the complexity bound,
demonstrating the "cosmic census" structure.
"""
import math


def enumerate_count_by_complexity(max_c: int) -> dict[int, int]:
    """Count integer-parameter Selberg data at each complexity level."""
    counts: dict[int, int] = {}
    for c in range(1, max_c + 1):
        count = 0
        for d in range(c + 1):
            for q in range(1, c - d + 1):
                remaining = c - d - q
                if remaining < 0:
                    continue
                if d == 0:
                    count += 1
                elif d == 1:
                    bound = int(remaining)
                    for r in range(-bound, bound + 1):
                        s_bound = bound - abs(r)
                        for s in range(-s_bound, s_bound + 1):
                            if abs(r) + abs(s) + d + q <= c:
                                count += 1
        counts[c] = count
    return counts


def main():
    try:
        import matplotlib.pyplot as plt
        import matplotlib
    except ImportError:
        print("matplotlib not available; printing data instead")
        counts = enumerate_count_by_complexity(15)
        for c, n in sorted(counts.items()):
            print(f"C={c}: {n} Selberg data")
        return

    counts = enumerate_count_by_complexity(20)
    cumulative = {}
    running = 0
    for c in sorted(counts.keys()):
        running += counts[c]
        cumulative[c] = running

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    cs = sorted(counts.keys())
    ns = [counts[c] for c in cs]
    ax1.bar(cs, ns, color='steelblue', alpha=0.8, edgecolor='navy')
    ax1.set_xlabel('Spectral Complexity C', fontsize=12)
    ax1.set_ylabel('Number of Selberg Data', fontsize=12)
    ax1.set_title('L-Functions at Each Complexity Level', fontsize=14)
    ax1.grid(True, alpha=0.3, axis='y')

    cums = [cumulative[c] for c in cs]
    ax2.plot(cs, cums, 'o-', color='darkred', markersize=5, linewidth=2)
    ax2.set_xlabel('Spectral Complexity Bound C', fontsize=12)
    ax2.set_ylabel('Cumulative Count N(≤C)', fontsize=12)
    ax2.set_title('Cumulative Census of the L-Function Universe', fontsize=14)
    ax2.set_yscale('log')
    ax2.grid(True, alpha=0.3)

    plt.suptitle('The Cosmic Census of L-Functions', fontsize=16, y=1.02)
    plt.tight_layout()
    plt.savefig('complexity_spectrum.png', dpi=150, bbox_inches='tight')
    print("Saved complexity_spectrum.png")
    plt.close()


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Density of L-functions ordered by conductor.

Plots the conductor counting function N(Q) = ∑_{n≤Q} φ(n) against
the asymptotic prediction 3Q²/π², showing convergence.
"""
import math


def euler_totient(n: int) -> int:
    if n <= 0:
        return 0
    result = n
    p = 2
    temp = n
    while p * p <= temp:
        if temp % p == 0:
            while temp % p == 0:
                temp //= p
            result -= result // p
        p += 1
    if temp > 1:
        result -= result // temp
    return result


def main():
    try:
        import matplotlib.pyplot as plt
    except ImportError:
        print("matplotlib not available; printing data instead")
        for Q in range(1, 201):
            actual = sum(euler_totient(n) for n in range(1, Q + 1))
            asymp = 3 * Q**2 / math.pi**2
            print(f"Q={Q}, N(Q)={actual}, 3Q²/π²={asymp:.1f}")
        return

    Q_values = list(range(1, 501))
    actual_values = []
    asymptotic_values = []
    ratios = []

    running = 0
    for Q in Q_values:
        running += euler_totient(Q)
        actual_values.append(running)
        asymp = 3 * Q**2 / math.pi**2
        asymptotic_values.append(asymp)
        ratios.append(running / asymp if asymp > 0 else 1)

    fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(10, 8))

    ax1.plot(Q_values, actual_values, 'b-', linewidth=1.5, label=r'$N(Q) = \sum_{n \leq Q} \varphi(n)$')
    ax1.plot(Q_values, asymptotic_values, 'r--', linewidth=1.5, label=r'$3Q^2/\pi^2$')
    ax1.set_xlabel('Conductor bound Q')
    ax1.set_ylabel('Count of degree-1 L-functions')
    ax1.set_title('Density of Dirichlet L-functions by Conductor')
    ax1.legend(fontsize=12)
    ax1.grid(True, alpha=0.3)

    ax2.plot(Q_values, ratios, 'g-', linewidth=1.5)
    ax2.axhline(y=1.0, color='k', linestyle='--', alpha=0.5)
    ax2.set_xlabel('Conductor bound Q')
    ax2.set_ylabel(r'$N(Q) / (3Q^2/\pi^2)$')
    ax2.set_title('Convergence to Asymptotic Density')
    ax2.set_ylim(0.9, 1.1)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('selberg_density.png', dpi=150, bbox_inches='tight')
    print("Saved selberg_density.png")
    plt.close()


if __name__ == "__main__":
    main()
