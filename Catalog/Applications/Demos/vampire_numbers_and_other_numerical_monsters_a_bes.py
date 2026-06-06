#!/usr/bin/env python3
"""
Vampire Numbers and Arithmetic Creatures: Interactive Demo

Demonstrates the key results from our formalization:
1. The mod-9 sieve for vampire numbers
2. Enumeration and classification of arithmetic creatures
3. Density analysis across digit ranges
4. The digit-counting polynomial bridge
"""

from collections import Counter
import sys


def digits(n: int) -> list:
    if n == 0:
        return [0]
    result = []
    while n > 0:
        result.append(n % 10)
        n //= 10
    return result


def num_digits(n: int) -> int:
    return len(str(n))


def is_vampire(v: int) -> bool:
    nd = num_digits(v)
    if nd < 4 or nd % 2 != 0:
        return False
    n = nd // 2
    lo = 10 ** (n - 1)
    hi = 10 ** n
    for x in range(lo, hi):
        if v % x != 0:
            continue
        y = v // x
        if y < lo or y >= hi:
            continue
        if x % 10 == 0 and y % 10 == 0:
            continue
        if sorted(digits(v)) == sorted(digits(x) + digits(y)):
            return True
    return False


def find_fangs(v: int) -> list:
    nd = num_digits(v)
    if nd < 4 or nd % 2 != 0:
        return []
    n = nd // 2
    lo = 10 ** (n - 1)
    hi = 10 ** n
    fangs = []
    for x in range(lo, hi):
        if v % x != 0:
            continue
        y = v // x
        if y < x or y >= hi:
            continue
        if x % 10 == 0 and y % 10 == 0:
            continue
        if sorted(digits(v)) == sorted(digits(x) + digits(y)):
            fangs.append((x, y))
    return fangs


def is_ghost(v: int) -> bool:
    v_digits = set(digits(v))
    for x in range(2, int(v ** 0.5) + 1):
        if v % x != 0:
            continue
        y = v // x
        if y <= 1:
            continue
        if v_digits.isdisjoint(set(digits(x))) and v_digits.isdisjoint(set(digits(y))):
            return True
    return False


def mod9_analysis():
    """Demonstrate the mod-9 sieve theorem."""
    print("=" * 60)
    print("THE MOD-9 VAMPIRE SIEVE")
    print("=" * 60)
    print()
    print("Theorem: For vampire fangs x, y: x*y ≡ x+y (mod 9)")
    print("Equivalently: (x-1)(y-1) ≡ 1 (mod 9)")
    print()
    
    valid = []
    print("Residue pairs (a, b) mod 9 with a*b ≡ a+b:")
    print("-" * 40)
    for a in range(9):
        for b in range(9):
            if (a * b) % 9 == (a + b) % 9:
                valid.append((a, b))
                print(f"  ({a}, {b}): {a}×{b} = {a*b} ≡ {(a*b)%9}, "
                      f"{a}+{b} = {a+b} ≡ {(a+b)%9} ✓")
    
    print(f"\nTotal valid pairs: {len(valid)} out of 81")
    print(f"Fraction: {len(valid)}/81 = 2/27 ≈ {len(valid)/81:.4f}")
    print(f"This eliminates {100*(1 - len(valid)/81):.1f}% of candidates!")
    print()
    
    # Verify the nine-divides-both-or-neither theorem
    print("The Nine Dichotomy:")
    print("  If 9|x then 9|y, and vice versa (both or neither)")
    for a, b in valid:
        nine_a = (a == 0)
        nine_b = (b == 0)
        print(f"  ({a},{b}): 9|x={nine_a}, 9|y={nine_b} → {'BOTH' if nine_a and nine_b else 'NEITHER'}")
    print()


def enumerate_vampires_demo():
    """Enumerate and classify vampire numbers."""
    print("=" * 60)
    print("VAMPIRE NUMBER ENUMERATION")
    print("=" * 60)
    print()
    
    # 4-digit vampires
    vampires = []
    for v in range(1000, 10000):
        if is_vampire(v):
            vampires.append(v)
    
    print(f"4-digit vampire numbers: {len(vampires)} found")
    for v in vampires:
        fangs = find_fangs(v)
        fang_str = ", ".join(f"{x}×{y}" for x, y in fangs)
        mult = len(fangs)
        tag = " [MULTIPLE FANGS!]" if mult > 1 else ""
        print(f"  {v} = {fang_str}{tag}")
    
    # Verify mod-9 constraint
    print(f"\nMod-9 verification for all 4-digit vampires:")
    for v in vampires:
        for x, y in find_fangs(v):
            lhs = (x * y) % 9
            rhs = (x + y) % 9
            status = "✓" if lhs == rhs else "✗"
            print(f"  {v}={x}×{y}: {x}*{y}≡{lhs}, {x}+{y}≡{rhs} {status}")
    print()


def ghost_search():
    """Search for ghost numbers."""
    print("=" * 60)
    print("GHOST NUMBER SEARCH")
    print("=" * 60)
    print()
    
    ghosts = []
    for v in range(4, 10000):
        if is_ghost(v):
            ghosts.append(v)
            if len(ghosts) <= 20:
                v_d = set(digits(v))
                for x in range(2, int(v ** 0.5) + 1):
                    if v % x == 0:
                        y = v // x
                        if y > 1 and v_d.isdisjoint(set(digits(x))) and v_d.isdisjoint(set(digits(y))):
                            print(f"  {v} = {x} × {y}  "
                                  f"(v digits: {v_d}, "
                                  f"x digits: {set(digits(x))}, "
                                  f"y digits: {set(digits(y))})")
                            break
    
    print(f"\nGhost numbers up to 10000: {len(ghosts)}")
    print()


def polynomial_bridge():
    """Demonstrate the digit-counting polynomial bridge."""
    print("=" * 60)
    print("DIGIT-COUNTING POLYNOMIAL BRIDGE")
    print("=" * 60)
    print()
    print("For v=x*y vampire, the digit-counting polynomial satisfies:")
    print("  P_v(X) = P_x(X) + P_y(X)")
    print()
    
    examples = [(1260, 21, 60), (1395, 15, 93), (6880, 80, 86)]
    
    for v, x, y in examples:
        v_poly = Counter(digits(v))
        x_poly = Counter(digits(x))
        y_poly = Counter(digits(y))
        sum_poly = x_poly + y_poly
        
        def poly_str(p):
            terms = []
            for d in sorted(p.keys()):
                if p[d] == 1:
                    terms.append(f"X^{d}")
                else:
                    terms.append(f"{p[d]}·X^{d}")
            return " + ".join(terms) if terms else "0"
        
        print(f"  {v} = {x} × {y}")
        print(f"    P_{v}(X) = {poly_str(v_poly)}")
        print(f"    P_{x}(X) + P_{y}(X) = {poly_str(sum_poly)}")
        match = "✓" if v_poly == sum_poly else "✗"
        print(f"    Equal: {match}")
        
        # Evaluate at X=1: gives digit count
        eval_v = sum(v_poly.values())
        eval_xy = sum(sum_poly.values())
        print(f"    P(1) = {eval_v} = {eval_xy} (digit count)")
        print()


def density_analysis():
    """Analyze vampire number density."""
    print("=" * 60)
    print("DENSITY ANALYSIS")
    print("=" * 60)
    print()
    
    # 4-digit
    count_4 = sum(1 for v in range(1000, 10000) if is_vampire(v))
    total_4 = 9000
    print(f"4-digit: {count_4} vampires out of {total_4} = {count_4/total_4:.6f}")
    
    # 6-digit (sample)
    count_6 = 0
    sample_size = 100000
    import random
    random.seed(42)
    samples = random.sample(range(100000, 1000000), min(sample_size, 900000))
    for v in samples[:10000]:
        if is_vampire(v):
            count_6 += 1
    print(f"6-digit (sample of 10000): {count_6} vampires ≈ density {count_6/10000:.6f}")
    print()
    
    # Mod-9 sieve effectiveness
    print("Mod-9 sieve effectiveness:")
    candidates_4 = 0
    actual_4 = 0
    for v in range(1000, 10000):
        r = v % 9
        valid = any((a * b) % 9 == r for a, b in [(0,0),(2,2),(3,6),(5,8),(6,3),(8,5)])
        if valid:
            candidates_4 += 1
            if is_vampire(v):
                actual_4 += 1
    print(f"  4-digit numbers passing mod-9 sieve: {candidates_4}/{total_4}")
    print(f"  Of those, actual vampires: {actual_4}/{candidates_4}")
    print()


if __name__ == "__main__":
    mod9_analysis()
    enumerate_vampires_demo()
    ghost_search()
    polynomial_bridge()
    density_analysis()


#!/usr/bin/env python3
"""
Visualization: The Mod-9 Vampire Sieve

Generates a heatmap of the 9x9 residue grid showing which pairs satisfy
the vampire constraint a*b ≡ a+b (mod 9), and a bar chart comparing
sieve effectiveness.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def create_mod9_heatmap():
    """Create heatmap of valid vampire residue pairs mod 9."""
    grid = np.zeros((9, 9))
    valid_pairs = []
    
    for a in range(9):
        for b in range(9):
            if (a * b) % 9 == (a + b) % 9:
                grid[a][b] = 1
                valid_pairs.append((a, b))
    
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    
    # Heatmap
    ax1 = axes[0]
    colors = np.array([[0.95, 0.95, 0.95], [0.2, 0.6, 0.9]])
    colored_grid = np.zeros((9, 9, 3))
    for i in range(9):
        for j in range(9):
            colored_grid[i][j] = colors[int(grid[i][j])]
    
    ax1.imshow(colored_grid, origin='lower', aspect='equal')
    
    for a in range(9):
        for b in range(9):
            color = 'white' if grid[a][b] == 1 else 'gray'
            weight = 'bold' if grid[a][b] == 1 else 'normal'
            ax1.text(b, a, f'({a},{b})', ha='center', va='center',
                    fontsize=7, color=color, fontweight=weight)
    
    ax1.set_xlabel('b (mod 9)', fontsize=12)
    ax1.set_ylabel('a (mod 9)', fontsize=12)
    ax1.set_title('Vampire Residue Pairs: a·b ≡ a+b (mod 9)\n'
                   f'{len(valid_pairs)} valid out of 81 = 2/27 ≈ 7.4%',
                   fontsize=13)
    ax1.set_xticks(range(9))
    ax1.set_yticks(range(9))
    
    # Add legend
    valid_patch = mpatches.Patch(color=[0.2, 0.6, 0.9], label='Valid pair')
    invalid_patch = mpatches.Patch(color=[0.95, 0.95, 0.95], label='Invalid pair')
    ax1.legend(handles=[valid_patch, invalid_patch], loc='upper right', fontsize=9)
    
    # Bar chart: sieve effectiveness
    ax2 = axes[1]
    
    # Count vampires in 4-digit range
    def digits(n):
        if n == 0: return [0]
        d = []
        while n > 0:
            d.append(n % 10)
            n //= 10
        return d
    
    def is_vampire_4(v):
        for x in range(10, 100):
            if v % x != 0:
                continue
            y = v // x
            if y < 10 or y >= 100:
                continue
            if x % 10 == 0 and y % 10 == 0:
                continue
            if sorted(digits(v)) == sorted(digits(x) + digits(y)):
                return True
        return False
    
    total = 9000
    pass_sieve = sum(1 for v in range(1000, 10000) 
                     if any((a*b)%9 == v%9 for a,b in valid_pairs))
    actual_vampires = sum(1 for v in range(1000, 10000) if is_vampire_4(v))
    
    categories = ['All 4-digit\nnumbers', 'Pass mod-9\nsieve', 'Actual\nvampires']
    values = [total, pass_sieve, actual_vampires]
    colors_bar = ['#cccccc', '#6699cc', '#cc3333']
    
    bars = ax2.bar(categories, values, color=colors_bar, edgecolor='black', linewidth=0.5)
    
    for bar, val in zip(bars, values):
        ax2.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 100,
                str(val), ha='center', va='bottom', fontweight='bold', fontsize=11)
    
    ax2.set_ylabel('Count', fontsize=12)
    ax2.set_title('Mod-9 Sieve Effectiveness\n(4-digit numbers)', fontsize=13)
    ax2.set_ylim(0, total * 1.15)
    
    plt.tight_layout()
    plt.savefig('viz_mod9_sieve.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved viz_mod9_sieve.png")


if __name__ == "__main__":
    create_mod9_heatmap()
