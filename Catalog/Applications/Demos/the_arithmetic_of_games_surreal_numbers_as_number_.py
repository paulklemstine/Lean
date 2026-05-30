#!/usr/bin/env python3
"""
Demo: Surreal Number Birthday Hierarchy

Demonstrates the constructive hierarchy of surreal numbers, showing how each
birthday level produces exactly the dyadic rationals with bounded denominators.

Conway's surreal numbers are constructed day by day:
  Day 0: {0}
  Day 1: {-1, 0, 1}
  Day 2: {-2, -1, -1/2, 0, 1/2, 1, 2}
  Day n: all dyadic rationals a/2^k with |a| ≤ 2^(n-1) and k ≤ n-1

This demo computes the surreals at each day and verifies the birthday hierarchy
conjecture for small cases.
"""

from fractions import Fraction
from typing import Set, Dict, List, Tuple


def surreals_at_day(n: int) -> Set[Fraction]:
    """Compute the set of surreal numbers born by day n.
    
    The surreal number construction proceeds as follows:
    - Day 0: Only 0 = {|}
    - Day k+1: For each gap (a, b) where a < b are consecutive surreals
      from day k (including -∞ and +∞), add the simplest number in (a, b).
      Also add -max-1 and max+1 at the boundaries.
    
    Returns the set of all surreals born by day n.
    """
    if n == 0:
        return {Fraction(0)}
    
    prev = sorted(surreals_at_day(n - 1))
    result = set(prev)
    
    # Add new integers at the boundaries
    result.add(prev[0] - 1)
    result.add(prev[-1] + 1)
    
    # Add midpoints between consecutive surreals
    for i in range(len(prev) - 1):
        midpoint = (prev[i] + prev[i + 1]) / 2
        result.add(midpoint)
    
    return result


def verify_dyadic(surreals: Set[Fraction]) -> bool:
    """Verify that all numbers in the set are dyadic rationals."""
    for q in surreals:
        denom = q.denominator
        # Check if denominator is a power of 2
        while denom > 1:
            if denom % 2 != 0:
                return False
            denom //= 2
    return True


def surreals_count_formula(n: int) -> int:
    """The expected count of surreals by day n: 2^(n+1) - 1."""
    return 2 ** (n + 1) - 1


def new_surreals_at_day(n: int) -> int:
    """The expected count of NEW surreals born exactly at day n."""
    return 1 if n == 0 else 2 ** n


def dyadic_resolution(n: int) -> Fraction:
    """The finest grid spacing at birthday level n."""
    if n == 0:
        return Fraction(0)
    return Fraction(1, 2 ** (n - 1))


def print_surreal_table(max_day: int = 6):
    """Print a detailed table of surreal numbers at each day."""
    print("=" * 80)
    print("SURREAL NUMBER BIRTHDAY HIERARCHY")
    print("=" * 80)
    print()
    
    for n in range(max_day + 1):
        surreals = surreals_at_day(n)
        sorted_surreals = sorted(surreals)
        expected_count = surreals_count_formula(n)
        actual_count = len(surreals)
        all_dyadic = verify_dyadic(surreals)
        
        print(f"Day {n}:")
        print(f"  Count: {actual_count} (expected: {expected_count}, "
              f"{'✓' if actual_count == expected_count else '✗'})")
        print(f"  All dyadic: {'✓' if all_dyadic else '✗'}")
        print(f"  Resolution: {dyadic_resolution(n)}")
        
        if n <= 4:
            # Print all values for small days
            values_str = ", ".join(str(q) for q in sorted_surreals)
            print(f"  Values: {{{values_str}}}")
        else:
            # Just print range for larger days
            print(f"  Range: [{sorted_surreals[0]}, {sorted_surreals[-1]}]")
            print(f"  Smallest positive: {min(q for q in sorted_surreals if q > 0)}")
        print()


def verify_recurrence(max_day: int = 10):
    """Verify the recurrence s(n+1) = 2*s(n) + 1."""
    print("=" * 80)
    print("VERIFYING RECURRENCE: s(n+1) = 2*s(n) + 1")
    print("=" * 80)
    print()
    
    for n in range(max_day):
        sn = surreals_count_formula(n)
        sn1 = surreals_count_formula(n + 1)
        expected = 2 * sn + 1
        print(f"  s({n}) = {sn}, 2*s({n})+1 = {expected}, "
              f"s({n+1}) = {sn1} {'✓' if sn1 == expected else '✗'}")
    print()


def verify_sum_formula(max_day: int = 8):
    """Verify s(n) = Σ_{k=0}^{n} new(k)."""
    print("=" * 80)
    print("VERIFYING SUM FORMULA: s(n) = Σ new(k)")
    print("=" * 80)
    print()
    
    for n in range(max_day + 1):
        sn = surreals_count_formula(n)
        total = sum(new_surreals_at_day(k) for k in range(n + 1))
        print(f"  n={n}: s({n}) = {sn}, Σnew(k) = {total} "
              f"{'✓' if sn == total else '✗'}")
    print()


def demonstrate_infinitesimal_approximation(terms: int = 15):
    """Show the dyadic approximation sequence converging to 0."""
    print("=" * 80)
    print("DYADIC APPROXIMATION SEQUENCE (approaching infinitesimal)")
    print("=" * 80)
    print()
    print("The surreal infinitesimal ε = {0 | 1, 1/2, 1/4, ...}")
    print("is the limit of the sequence 1/2^n as n → ∞")
    print()
    
    for n in range(terms):
        val = Fraction(1, 2 ** n)
        float_val = float(val)
        print(f"  n={n:2d}: 1/2^{n:2d} = {str(val):>12s} = {float_val:.10f}")
    print()


def birthday_tree_structure(max_day: int = 4):
    """Visualize the binary tree structure of surreal birthdays."""
    print("=" * 80)
    print("BINARY TREE STRUCTURE OF SURREAL BIRTHDAYS")
    print("=" * 80)
    print()
    print("Each new day adds midpoints between consecutive existing surreals,")
    print("plus new integers at the boundaries — a binary splitting process.")
    print()
    
    for n in range(max_day + 1):
        surreals = sorted(surreals_at_day(n))
        
        if n == 0:
            new = surreals
            old = []
        else:
            old_set = surreals_at_day(n - 1)
            new = [q for q in surreals if q not in old_set]
            old = [q for q in surreals if q in old_set]
        
        print(f"Day {n}: ", end="")
        for q in surreals:
            if q in new:
                print(f"[{q}]", end=" ")
            else:
                print(f" {q} ", end=" ")
        print()
        print(f"  New: {len(new)}, Total: {len(surreals)}")
        print()


if __name__ == "__main__":
    print_surreal_table()
    verify_recurrence()
    verify_sum_formula()
    demonstrate_infinitesimal_approximation()
    birthday_tree_structure()
    
    print("=" * 80)
    print("BIRTHDAY HIERARCHY CONJECTURE VERIFICATION")
    print("=" * 80)
    print()
    print("Conjecture: Surreals born by day ω = dyadic rationals ℤ[1/2]")
    print()
    print("Evidence (finite cases):")
    all_pass = True
    for n in range(7):
        surreals = surreals_at_day(n)
        is_dyadic = verify_dyadic(surreals)
        count_ok = len(surreals) == surreals_count_formula(n)
        status = "✓" if (is_dyadic and count_ok) else "✗"
        print(f"  Day {n}: all dyadic = {is_dyadic}, count = {count_ok} {status}")
        if not (is_dyadic and count_ok):
            all_pass = False
    
    print()
    if all_pass:
        print("All tests PASS — consistent with the conjecture.")
    else:
        print("Some tests FAIL — conjecture may be false!")


#!/usr/bin/env python3
"""
Visualization: The Surreal Number Birthday Tree

Shows how surreal numbers are constructed day by day, forming a binary
tree structure where each level doubles the number of values.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from fractions import Fraction
from typing import Set, List, Dict


def surreals_at_day(n: int) -> Set[Fraction]:
    """Compute surreal numbers born by day n."""
    if n == 0:
        return {Fraction(0)}
    prev = sorted(surreals_at_day(n - 1))
    result = set(prev)
    result.add(prev[0] - 1)
    result.add(prev[-1] + 1)
    for i in range(len(prev) - 1):
        result.add((prev[i] + prev[i + 1]) / 2)
    return result


def birthday_of(q: Fraction, max_day: int = 10) -> int:
    """Find the birthday (first day of appearance) of a surreal number."""
    for n in range(max_day + 1):
        if q in surreals_at_day(n):
            return n
    return -1


def plot_birthday_tree(max_day: int = 5):
    """Create a visualization of the surreal number birthday tree."""
    fig, axes = plt.subplots(2, 1, figsize=(16, 12), 
                              gridspec_kw={'height_ratios': [3, 1]})
    
    colors = ['#e74c3c', '#3498db', '#2ecc71', '#f39c12', '#9b59b6', '#1abc9c']
    
    # Top plot: Birthday tree
    ax = axes[0]
    ax.set_title('Surreal Number Birthday Hierarchy', fontsize=16, fontweight='bold')
    
    all_surreals = {}  # value -> birthday
    
    for day in range(max_day + 1):
        current = surreals_at_day(day)
        for q in current:
            if q not in all_surreals:
                all_surreals[q] = day
    
    # Plot each surreal number at its birthday level
    for q, day in all_surreals.items():
        color = colors[day % len(colors)]
        ax.scatter(float(q), day, c=color, s=80, zorder=5, 
                   edgecolors='black', linewidth=0.5)
        
        if max_day <= 4 or (day <= 2) or (abs(q) <= 2 and day <= 3):
            label = str(q) if q.denominator <= 4 else f"{q.numerator}/{q.denominator}"
            ax.annotate(label, (float(q), day), 
                       textcoords="offset points", xytext=(0, 10),
                       ha='center', fontsize=7, color=color)
    
    # Draw connections (each new number is the midpoint of two parents)
    for day in range(1, max_day + 1):
        prev_sorted = sorted(surreals_at_day(day - 1))
        current = surreals_at_day(day)
        new_at_day = current - surreals_at_day(day - 1)
        
        for q in new_at_day:
            # Find the "parents" - the closest surreals from previous day
            parents = []
            for i, p in enumerate(prev_sorted):
                if p < q:
                    parents = [p]
                elif p > q:
                    if parents:
                        parents.append(p)
                    break
            
            for p in parents:
                ax.plot([float(p), float(q)], [day - 1, day], 
                       color='gray', alpha=0.3, linewidth=0.5)
    
    ax.set_ylabel('Birthday (Day)', fontsize=12)
    ax.set_xlabel('Value', fontsize=12)
    ax.set_yticks(range(max_day + 1))
    ax.invert_yaxis()
    ax.grid(True, alpha=0.2)
    
    # Add legend
    legend_patches = [mpatches.Patch(color=colors[i], label=f'Day {i}') 
                      for i in range(min(max_day + 1, len(colors)))]
    ax.legend(handles=legend_patches, loc='upper right', fontsize=9)
    
    # Bottom plot: Count growth
    ax2 = axes[1]
    days = list(range(max_day + 1))
    counts = [len(surreals_at_day(n)) for n in days]
    expected = [2 ** (n + 1) - 1 for n in days]
    
    ax2.bar(days, counts, color=[colors[d % len(colors)] for d in days],
            alpha=0.7, edgecolor='black', linewidth=0.5)
    ax2.plot(days, expected, 'k--', linewidth=2, label='2^(n+1) - 1')
    
    ax2.set_xlabel('Day', fontsize=12)
    ax2.set_ylabel('Count', fontsize=12)
    ax2.set_title('Number of Surreals Born by Each Day', fontsize=14, fontweight='bold')
    ax2.legend(fontsize=10)
    ax2.set_xticks(days)
    
    plt.tight_layout()
    plt.savefig('surreal_birthday_tree.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: surreal_birthday_tree.png")


def plot_resolution_decay(max_day: int = 10):
    """Visualize how the dyadic resolution decays exponentially."""
    fig, ax = plt.subplots(figsize=(10, 6))
    
    days = list(range(1, max_day + 1))
    resolutions = [float(Fraction(1, 2 ** (n - 1))) for n in days]
    
    ax.semilogy(days, resolutions, 'bo-', markersize=8, linewidth=2)
    
    # Annotate each point
    for n, r in zip(days, resolutions):
        label = f"1/{2**(n-1)}" if n > 1 else "1"
        ax.annotate(label, (n, r), textcoords="offset points", 
                   xytext=(10, 5), fontsize=9)
    
    ax.set_xlabel('Birthday Level n', fontsize=12)
    ax.set_ylabel('Resolution (log scale)', fontsize=12)
    ax.set_title('Dyadic Resolution Decay: Finer Grids at Higher Birthdays', 
                fontsize=14, fontweight='bold')
    ax.grid(True, alpha=0.3)
    ax.set_xticks(days)
    
    plt.tight_layout()
    plt.savefig('dyadic_resolution_decay.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: dyadic_resolution_decay.png")


def plot_number_line_evolution(max_day: int = 5):
    """Show how the surreal number line fills in day by day."""
    fig, ax = plt.subplots(figsize=(16, 8))
    
    colors = ['#e74c3c', '#3498db', '#2ecc71', '#f39c12', '#9b59b6', '#1abc9c']
    
    for day in range(max_day + 1):
        surreals = sorted(surreals_at_day(day))
        if day > 0:
            prev = surreals_at_day(day - 1)
            new = [q for q in surreals if q not in prev]
            old = [q for q in surreals if q in prev]
        else:
            new = surreals
            old = []
        
        y = max_day - day
        
        # Plot old numbers (gray)
        for q in old:
            ax.scatter(float(q), y, c='lightgray', s=30, zorder=3,
                      edgecolors='gray', linewidth=0.3)
        
        # Plot new numbers (colored)
        for q in new:
            ax.scatter(float(q), y, c=colors[day % len(colors)], s=60, 
                      zorder=5, edgecolors='black', linewidth=0.5)
            if max_day <= 4:
                label = str(q)
                ax.annotate(label, (float(q), y), 
                           textcoords="offset points", xytext=(0, 8),
                           ha='center', fontsize=6)
        
        ax.text(-max_day - 1.5, y, f'Day {day}', fontsize=11, 
                fontweight='bold', va='center',
                color=colors[day % len(colors)])
        
        # Draw number line
        ax.axhline(y=y, color='gray', alpha=0.1, linewidth=0.5)
    
    ax.set_xlabel('Value', fontsize=12)
    ax.set_title('Evolution of the Surreal Number Line', 
                fontsize=16, fontweight='bold')
    ax.set_yticks([])
    ax.spines['left'].set_visible(False)
    ax.spines['top'].set_visible(False)
    ax.spines['right'].set_visible(False)
    
    plt.tight_layout()
    plt.savefig('number_line_evolution.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: number_line_evolution.png")


if __name__ == "__main__":
    plot_birthday_tree()
    plot_resolution_decay()
    plot_number_line_evolution()
    print("All visualizations generated.")
