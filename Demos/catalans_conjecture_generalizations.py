#!/usr/bin/env python3
"""
Demo: Pillai's Conjecture and Exponential Diophantine Equations
Numerical exploration of x^a - y^b = k for small k values.
"""

from algorithms import (
    find_pillai_solutions, pillai_gap_bound, count_perfect_powers,
    perfect_power_density, classify_sq_diff, pillai_exhaustive_search, power_gap
)


def main():
    print("=" * 70)
    print("PILLAI'S CONJECTURE: Exponential Diophantine Equations")
    print("Finding solutions to x^a - y^b = k with x,y,a,b >= 2")
    print("=" * 70)

    # Solutions for small k
    print("\n--- Solutions for small k values ---")
    for k in range(1, 11):
        sols = find_pillai_solutions(k, max_base=200, max_exp=30)
        if sols:
            print(f"\nk = {k}: {len(sols)} solution(s)")
            for x, a, y, b in sols[:10]:
                print(f"  {x}^{a} - {y}^{b} = {x**a} - {y**b} = {k}")
        else:
            print(f"\nk = {k}: no solutions found (up to base 200, exp 30)")

    # Square difference classification
    print("\n\n--- Square difference x^2 - y^2 = k (complete classification) ---")
    for k in [1, 2, 3, 4, 5, 7, 8, 9, 12, 15, 16, 20, 21, 24, 25]:
        sols = classify_sq_diff(k)
        if sols:
            print(f"k = {k:3d}: {sols}")
        else:
            print(f"k = {k:3d}: no solutions with x,y >= 2")

    # Gap between consecutive powers
    print("\n\n--- Gap growth: (b+1)^e - b^e ---")
    for e in [2, 3, 4, 5]:
        print(f"\nExponent e = {e}:")
        for b in [2, 5, 10, 20, 50, 100]:
            gap = power_gap(b, e)
            print(f"  b = {b:4d}: gap = {gap:>15,}")

    # Pillai gap bounds
    print("\n\n--- Effective bounds: smallest b0 where (b+1)^e - b^e > k ---")
    for e in [2, 3, 4]:
        for k in [1, 5, 10, 50, 100, 1000]:
            b0 = pillai_gap_bound(e, k)
            print(f"  e={e}, k={k:5d}: b0 = {b0}")

    # Perfect power counting
    print("\n\n--- Perfect power counting function pi_PP(N) ---")
    for N in [10, 100, 1000, 10000, 100000, 1000000]:
        count = count_perfect_powers(N)
        density = perfect_power_density(N)
        # Theoretical: ~ sqrt(N) for large N (dominated by squares)
        import math
        sqrt_n = int(math.sqrt(N))
        print(f"  N = {N:>10,}: pi_PP(N) = {count:>6}, density = {density:.6f}, "
              f"sqrt(N)-1 = {sqrt_n - 1}")

    # Exhaustive search for k=2 (testing PillaiK2Conjecture)
    print("\n\n--- Testing PillaiK2Conjecture: all solutions to x^a - y^b = 2 ---")
    sols_k2 = pillai_exhaustive_search(2, bound=500, max_exp=15)
    if sols_k2:
        print(f"Found {len(sols_k2)} solution(s):")
        for x, a, y, b in sols_k2:
            print(f"  {x}^{a} - {y}^{b} = {x**a} - {y**b} = 2")
        if len(sols_k2) == 1 and sols_k2[0] == (3, 3, 5, 2):
            print("  => Consistent with conjecture: (3,3,5,2) is the unique solution")
    else:
        print("No solutions found!")

    # Known Catalan solution
    print("\n\n--- Catalan's Theorem (k=1) verification ---")
    print(f"  3^2 - 2^3 = {3**2} - {2**3} = {3**2 - 2**3}")
    print(f"  This is the ONLY solution to x^a - y^b = 1 (Mihailescu 2002)")
    sols_k1 = find_pillai_solutions(1, max_base=1000, max_exp=30)
    print(f"  Search up to base 1000: found {len(sols_k1)} solution(s)")
    for x, a, y, b in sols_k1:
        print(f"    {x}^{a} - {y}^{b} = {x**a} - {y**b} = 1")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Perfect power gaps and Pillai solution landscape.
"""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import math


def count_perfect_powers(N):
    powers = set()
    for e in range(2, max(3, int(math.log2(N)) + 1)):
        b = 2
        while b ** e <= N:
            powers.add(b ** e)
            b += 1
    return len(powers)


def find_pillai_solutions(k, max_base=500, max_exp=20):
    powers = {}
    for base in range(2, max_base + 1):
        for exp in range(2, max_exp + 1):
            val = base ** exp
            if val > max_base ** max_exp:
                break
            if val not in powers:
                powers[val] = []
            powers[val].append((base, exp))
    solutions = []
    for val, reps in powers.items():
        target = val - k
        if target in powers and target > 0:
            for x, a in reps:
                for y, b in powers[target]:
                    solutions.append((x, a, y, b))
    return solutions


def plot_power_gaps():
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    
    # Plot 1: Gap growth for different exponents
    ax = axes[0, 0]
    for e in [2, 3, 4, 5]:
        bs = list(range(2, 51))
        gaps = [(b + 1) ** e - b ** e for b in bs]
        ax.plot(bs, gaps, label=f'e = {e}', linewidth=2)
    ax.set_xlabel('Base b', fontsize=12)
    ax.set_ylabel('Gap (b+1)^e - b^e', fontsize=12)
    ax.set_title('Growth of Consecutive Power Gaps', fontsize=14)
    ax.legend(fontsize=11)
    ax.set_yscale('log')
    ax.grid(True, alpha=0.3)
    
    # Plot 2: Perfect power counting function
    ax = axes[0, 1]
    Ns = list(range(10, 10001, 10))
    counts = [count_perfect_powers(N) for N in Ns]
    sqrts = [int(math.sqrt(N)) - 1 for N in Ns]
    ax.plot(Ns, counts, 'b-', label='π_PP(N)', linewidth=2)
    ax.plot(Ns, sqrts, 'r--', label='√N - 1', linewidth=1.5)
    ax.set_xlabel('N', fontsize=12)
    ax.set_ylabel('Count', fontsize=12)
    ax.set_title('Perfect Power Counting Function', fontsize=14)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    
    # Plot 3: Number of Pillai solutions for each k
    ax = axes[1, 0]
    ks = list(range(1, 51))
    solution_counts = [len(find_pillai_solutions(k, max_base=200, max_exp=15)) for k in ks]
    colors = ['red' if c == 0 else 'steelblue' for c in solution_counts]
    ax.bar(ks, solution_counts, color=colors, alpha=0.8)
    ax.set_xlabel('Gap k', fontsize=12)
    ax.set_ylabel('Number of Solutions', fontsize=12)
    ax.set_title('Pillai Solutions: x^a - y^b = k', fontsize=14)
    ax.grid(True, alpha=0.3, axis='y')
    
    # Plot 4: Perfect powers on the number line
    ax = axes[1, 1]
    N = 200
    powers_set = set()
    for e in range(2, 8):
        b = 2
        while b ** e <= N:
            powers_set.add(b ** e)
            b += 1
    powers_list = sorted(powers_set)
    gaps = [powers_list[i+1] - powers_list[i] for i in range(len(powers_list)-1)]
    ax.scatter(range(1, len(gaps)+1), gaps, c='navy', s=30, alpha=0.7)
    ax.set_xlabel('Gap index', fontsize=12)
    ax.set_ylabel('Gap size', fontsize=12)
    ax.set_title('Gaps Between Consecutive Perfect Powers', fontsize=14)
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('/workspace/request-project/pillai_visualization.png', dpi=150, bbox_inches='tight')
    print("Saved pillai_visualization.png")


if __name__ == "__main__":
    plot_power_gaps()
