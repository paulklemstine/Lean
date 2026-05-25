#!/usr/bin/env python3
"""
applications.py — Real-world applications of cubic obstruction theory.

Demonstrates how obstruction profiles can be used as:
1. Certified search pruning for Diophantine solvers
2. Classification of integers by representability status
3. Density estimation for representable integers
"""

from typing import List, Tuple, Dict, Set
from algorithms import (
    has_cubic_solution_mod,
    obstruction_profile_up_to,
    bounded_three_cube_search,
    find_minimal_obstructions,
    classify_residue_classes_mod9,
)


def certified_search_with_pruning(k_values: List[int], B: int, M: int) -> Dict[int, dict]:
    """
    Demonstrate certified search pruning using obstruction profiles.

    For each k, first check if any modular obstruction exists (up to M).
    If obstructed, skip the expensive search entirely — this is
    mathematically certified to save time without missing solutions.

    This is the practical realization of Theorem 4:
    obstructionProfile_prunes_search
    """
    results = {}
    total_pruned = 0
    total_searched = 0

    for k in k_values:
        profile = obstruction_profile_up_to(k, M)
        if profile:
            # Certified: no solution exists, skip search
            results[k] = {
                'status': 'PRUNED',
                'obstruction': profile[0],
                'search_performed': False,
                'solution': None
            }
            total_pruned += 1
        else:
            # No obstruction found, must search
            solution = bounded_three_cube_search(k, B)
            results[k] = {
                'status': 'FOUND' if solution else 'UNKNOWN',
                'obstruction': None,
                'search_performed': True,
                'solution': solution
            }
            total_searched += 1

    return results


def classify_integers(N: int, M: int = 100) -> Dict[str, List[int]]:
    """
    Classify integers 1..N into categories:
    - 'mod9_obstructed': k ≡ 4 or 5 (mod 9)
    - 'other_obstructed': obstructed by some modulus ≤ M (not just mod 9)
    - 'congruence_compatible': passes all tests up to M
    """
    classification = {
        'mod9_obstructed': [],
        'other_obstructed': [],
        'congruence_compatible': []
    }

    for k in range(1, N + 1):
        if k % 9 in [4, 5]:
            classification['mod9_obstructed'].append(k)
        else:
            profile = obstruction_profile_up_to(k, M)
            if profile:
                classification['other_obstructed'].append(k)
            else:
                classification['congruence_compatible'].append(k)

    return classification


def density_analysis(N: int, M: int = 100) -> Dict[str, float]:
    """
    Compute density statistics for representability classes.
    """
    classification = classify_integers(N, M)
    total = N
    return {
        'mod9_obstructed_fraction': len(classification['mod9_obstructed']) / total,
        'other_obstructed_fraction': len(classification['other_obstructed']) / total,
        'compatible_fraction': len(classification['congruence_compatible']) / total,
        'mod9_obstructed_count': len(classification['mod9_obstructed']),
        'other_obstructed_count': len(classification['other_obstructed']),
        'compatible_count': len(classification['congruence_compatible']),
    }


def search_pruning_efficiency(k_range: range, B: int, M: int) -> Dict[str, float]:
    """
    Measure how much computation obstruction pruning saves.
    """
    pruned = 0
    searched = 0
    found = 0

    for k in k_range:
        profile = obstruction_profile_up_to(k, M)
        if profile:
            pruned += 1
        else:
            searched += 1
            result = bounded_three_cube_search(k, min(B, 50))
            if result:
                found += 1

    total = len(k_range)
    return {
        'total': total,
        'pruned': pruned,
        'searched': searched,
        'found': found,
        'pruning_rate': pruned / total if total > 0 else 0,
        'search_success_rate': found / searched if searched > 0 else 0,
    }


if __name__ == "__main__":
    print("=" * 70)
    print("APPLICATIONS OF CUBIC OBSTRUCTION THEORY")
    print("=" * 70)

    # Application 1: Certified search pruning
    print("\n--- Application 1: Certified Search Pruning ---\n")
    test_values = list(range(1, 51))
    results = certified_search_with_pruning(test_values, B=100, M=50)

    pruned = [k for k, r in results.items() if r['status'] == 'PRUNED']
    found = [k for k, r in results.items() if r['status'] == 'FOUND']
    unknown = [k for k, r in results.items() if r['status'] == 'UNKNOWN']

    print(f"  Testing k = 1..50 with M=50 (congruence), B=100 (search)")
    print(f"  Pruned (certified impossible): {pruned}")
    print(f"  Found (solution exists):       {found}")
    print(f"  Unknown (no obstruction, no solution found): {unknown}")
    print(f"  Pruning saved {len(pruned)}/{len(test_values)} searches = "
          f"{len(pruned)/len(test_values):.0%}")

    # Application 2: Classification
    print("\n--- Application 2: Integer Classification ---\n")
    density = density_analysis(1000, M=100)
    print(f"  Classification of k = 1..1000:")
    print(f"    Mod 9 obstructed: {density['mod9_obstructed_count']} "
          f"({density['mod9_obstructed_fraction']:.1%})")
    print(f"    Other obstructed: {density['other_obstructed_count']} "
          f"({density['other_obstructed_fraction']:.1%})")
    print(f"    Congruence compatible: {density['compatible_count']} "
          f"({density['compatible_fraction']:.1%})")

    # Application 3: Search efficiency
    print("\n--- Application 3: Search Efficiency ---\n")
    efficiency = search_pruning_efficiency(range(1, 201), B=50, M=50)
    print(f"  Range: k = 1..200, M=50, B=50")
    print(f"  Pruned: {efficiency['pruned']}/{efficiency['total']} "
          f"({efficiency['pruning_rate']:.1%})")
    print(f"  Searched: {efficiency['searched']}")
    print(f"  Solutions found: {efficiency['found']} "
          f"({efficiency['search_success_rate']:.1%} of searched)")

    # Application 4: Minimal obstruction generators
    print("\n--- Application 4: Minimal Obstruction Analysis ---\n")
    print("  The upward closure theorem means obstructions propagate to multiples.")
    print("  Minimal obstructions are the generators of the entire profile.\n")
    for k in [4, 5, 13, 14, 22, 23]:
        minimal = find_minimal_obstructions(k, 200)
        print(f"  k = {k}: minimal obstructions up to 200 = {minimal}")

    print(f"\n{'=' * 70}")
    print("All applications demonstrate the bridge between arithmetic")
    print("geometry (obstruction theory) and computational practice")
    print("(certified search pruning).")
    print(f"{'=' * 70}")


#!/usr/bin/env python3
"""
demo.py — Interactive demonstration of cubic obstruction profiles
for the Diophantine equation x³ + y³ + z³ = k.

Computes obstruction profiles, performs bounded integer searches,
and compares structural obstructions against computational evidence.
"""

import sys
from typing import List, Tuple, Optional


def has_cubic_solution_mod(k: int, m: int) -> bool:
    """Check if x³ + y³ + z³ ≡ k (mod m) has a solution."""
    if m <= 0:
        return True
    target = k % m
    cubes = set()
    for x in range(m):
        cubes.add(pow(x, 3, m))
    for c1 in cubes:
        for c2 in cubes:
            remainder = (target - c1 - c2) % m
            if remainder in cubes:
                return True
    return False


def obstruction_profile_up_to(k: int, M: int) -> List[int]:
    """Compute the obstruction profile of k up to modulus M."""
    return [m for m in range(1, M + 1) if not has_cubic_solution_mod(k, m)]


def bounded_search(k: int, B: int) -> Optional[Tuple[int, int, int]]:
    """Search for x, y, z with |x|,|y|,|z| ≤ B and x³+y³+z³ = k."""
    for x in range(-B, B + 1):
        x3 = x ** 3
        for y in range(-B, B + 1):
            xy3 = x3 + y ** 3
            z3_needed = k - xy3
            # Check if z3_needed is a perfect cube in range
            if z3_needed == 0:
                z = 0
            else:
                sign = 1 if z3_needed > 0 else -1
                z_approx = round(abs(z3_needed) ** (1/3))
                z = None
                for candidate in [z_approx - 1, z_approx, z_approx + 1]:
                    if candidate >= 0 and (sign * candidate) ** 3 == z3_needed:
                        z = sign * candidate
                        break
                if z is None:
                    continue
            if abs(z) <= B and x**3 + y**3 + z**3 == k:
                return (x, y, z)
    return None


def print_separator():
    print("=" * 70)


def main():
    print_separator()
    print("CUBIC OBSTRUCTION PROFILES — PROTO-BRAUER–MANIN ANALYSIS")
    print("Equation: x³ + y³ + z³ = k")
    print_separator()

    M = 100   # Modulus bound for obstruction profile
    B = 1000  # Search bound for integer solutions

    if len(sys.argv) > 1:
        M = int(sys.argv[1])
    if len(sys.argv) > 2:
        B = int(sys.argv[2])

    print(f"\nParameters: modulus bound M = {M}, search bound B = {B}")

    # Part 1: Obstructed classes (k ≡ 4, 5 mod 9)
    print(f"\n{'─' * 70}")
    print("PART 1: STRUCTURALLY OBSTRUCTED VALUES (k ≡ 4 or 5 mod 9)")
    print(f"{'─' * 70}")

    obstructed_examples = [4, 5, 13, 14, 22, 23, 31, 32]
    for k in obstructed_examples:
        profile = obstruction_profile_up_to(k, min(M, 50))
        mod9_class = k % 9
        print(f"  k = {k:3d}  (k mod 9 = {mod9_class})  "
              f"obstruction profile (up to 50): {profile[:10]}{'...' if len(profile) > 10 else ''}")

    # Part 2: Positive controls — known representable values
    print(f"\n{'─' * 70}")
    print("PART 2: KNOWN REPRESENTABLE VALUES")
    print(f"{'─' * 70}")

    known_reps = {
        0: (0, 0, 0),
        1: (1, 0, 0),
        2: (1, 1, 0),
        8: (2, 0, 0),
        29: (3, 1, 1),
        33: (8866128975287528, -8778405442862239, -2736111468807040),
        42: (-80538738812075974, 80435758145817515, 12602123297335631),
    }

    for k, (x, y, z) in known_reps.items():
        profile = obstruction_profile_up_to(k, M)
        verification = x**3 + y**3 + z**3
        status = "✓" if verification == k else "✗"
        print(f"  k = {k:3d}  obstruction profile: {profile if profile else '∅ (empty)'}")
        print(f"         known solution: ({x}, {y}, {z})  [{status} verified]")

    # Part 3: Borderline cases — pass congruence tests but no small solution
    print(f"\n{'─' * 70}")
    print("PART 3: BORDERLINE CASES — PASS ALL CONGRUENCE TESTS")
    print(f"{'─' * 70}")

    search_bound = min(B, 200)
    borderline = []
    for k in range(1, 1001):
        if k % 9 in [4, 5]:
            continue
        profile = obstruction_profile_up_to(k, M)
        if profile:
            continue  # Has an obstruction
        result = bounded_search(k, search_bound)
        if result is None:
            borderline.append(k)

    print(f"  Values 1..1000 passing all congruence tests up to M={M}")
    print(f"  but with no solution found within B={search_bound}:")
    if borderline:
        # Show first 30
        display = borderline[:30]
        print(f"  {display}{'...' if len(borderline) > 30 else ''}")
        print(f"  Total: {len(borderline)} values")
    else:
        print(f"  None found — all solvable within bounds!")

    # Part 4: The mod 9 obstruction as a 3-adic phenomenon
    print(f"\n{'─' * 70}")
    print("PART 4: 3-ADIC STRUCTURE — MOD 3^e OBSTRUCTION PERSISTENCE")
    print(f"{'─' * 70}")

    for k in [4, 5, 13, 14]:
        print(f"  k = {k} (k mod 9 = {k % 9}):")
        for e in range(1, 8):
            m = 3 ** e
            solvable = has_cubic_solution_mod(k, m)
            status = "✓ solvable" if solvable else "✗ OBSTRUCTED"
            print(f"    mod 3^{e} = {m:>5d}: {status}")
        print()

    # Part 5: Proto-Brauer completeness conjecture test
    print(f"{'─' * 70}")
    print("PART 5: PROTO-BRAUER COMPLETENESS CONJECTURE")
    print(f"{'─' * 70}")
    print()
    print("  Conjecture: If k passes all congruence tests (mod m for all m),")
    print("  then k is representable as a sum of three cubes.")
    print()
    print("  Test: Find k that passes congruence tests up to large M")
    print("  but has no known representation.")
    print()

    # Test a few famous cases
    famous_open = [114, 390, 579, 627, 633, 732, 921, 975]
    for k in famous_open:
        profile = obstruction_profile_up_to(k, M)
        result = bounded_search(k, min(B, 100))
        congruence_status = "PASSES all" if not profile else f"FAILS at {profile}"
        search_status = f"found {result}" if result else "no solution found"
        print(f"  k = {k:4d}: congruence tests up to {M}: {congruence_status}")
        print(f"          bounded search (B={min(B,100)}): {search_status}")

    # Part 6: Statistical summary
    print(f"\n{'─' * 70}")
    print("PART 6: STATISTICAL SUMMARY")
    print(f"{'─' * 70}")

    total = 0
    obstructed_count = 0
    pass_congruence = 0
    for k in range(1, 1001):
        total += 1
        if k % 9 in [4, 5]:
            obstructed_count += 1
        else:
            profile = obstruction_profile_up_to(k, M)
            if not profile:
                pass_congruence += 1
            else:
                obstructed_count += 1

    print(f"  Range: k = 1 to 1000")
    print(f"  Obstructed by mod 9: {sum(1 for k in range(1,1001) if k%9 in [4,5])}")
    print(f"  Obstructed by other moduli (up to {M}): "
          f"{obstructed_count - sum(1 for k in range(1,1001) if k%9 in [4,5])}")
    print(f"  Total obstructed: {obstructed_count}")
    print(f"  Pass all congruence tests: {pass_congruence}")
    print(f"  Fraction passing: {pass_congruence/total:.1%}")

    print(f"\n{'=' * 70}")
    print("KEY INSIGHT: The mod 9 obstruction is not an isolated accident —")
    print("it is the first visible footprint of a deeper adelic/cohomological")
    print("mechanism. Values passing all finite congruence tests become")
    print("genuine Diophantine mysteries requiring infinite search.")
    print(f"{'=' * 70}")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization 2: 3-adic Obstruction Tower

Visualizes how the mod 9 obstruction persists (or doesn't) through higher
powers of 3. For k ≡ 4, 5 (mod 9), the obstruction persists at all levels
3^e (e ≥ 2). For other values, solvability is maintained.

This illustrates Theorem 5: mod_nine_obstruction_controls_all_three_power_levels
"""

import numpy as np
import matplotlib.pyplot as plt


def has_cubic_solution_mod(k, m):
    if m <= 0:
        return True
    target = k % m
    cubes = {pow(x, 3, m) for x in range(m)}
    for c1 in cubes:
        for c2 in cubes:
            if (target - c1 - c2) % m in cubes:
                return True
    return False


# Analyze k = 0..17 across powers of 3
k_values = list(range(18))
max_exponent = 6
exponents = list(range(1, max_exponent + 1))

fig, ax = plt.subplots(figsize=(12, 7))

# Build data matrix
data = np.zeros((len(exponents), len(k_values)))
for i, e in enumerate(exponents):
    m = 3 ** e
    for j, k in enumerate(k_values):
        data[i, j] = 1 if has_cubic_solution_mod(k, m) else 0

im = ax.imshow(data, aspect='auto', cmap='RdYlGn', interpolation='nearest',
               extent=[-0.5, len(k_values) - 0.5, max_exponent + 0.5, 0.5])

ax.set_xticks(range(len(k_values)))
ax.set_xticklabels(k_values)
ax.set_yticks(range(1, max_exponent + 1))
ax.set_yticklabels([f'3^{e} = {3**e}' for e in exponents])

ax.set_xlabel('k', fontsize=13)
ax.set_ylabel('Modulus (power of 3)', fontsize=13)
ax.set_title('3-adic Obstruction Tower\n'
             'Green = solvable, Red = obstructed', fontsize=14)

# Annotate obstructed columns
for j, k in enumerate(k_values):
    if k % 9 in [4, 5]:
        ax.axvline(x=j, color='black', alpha=0.3, linewidth=2, linestyle=':')
        ax.text(j, 0.2, f'k≡{k%9}', ha='center', va='bottom', fontsize=8,
                color='red', fontweight='bold',
                transform=ax.get_xaxis_transform())

# Add cell annotations
for i, e in enumerate(exponents):
    m = 3 ** e
    for j, k in enumerate(k_values):
        solvable = has_cubic_solution_mod(k, m)
        symbol = '✓' if solvable else '✗'
        color = 'darkgreen' if solvable else 'darkred'
        ax.text(j, i + 1, symbol, ha='center', va='center',
                fontsize=10, color=color, fontweight='bold')

plt.tight_layout()
plt.savefig('viz_3adic_tower.png', dpi=150, bbox_inches='tight')
print("Saved viz_3adic_tower.png")


#!/usr/bin/env python3
"""
Visualization 1: Obstruction Profile Heatmap

Visualizes the cubic obstruction profile as a heatmap where each cell (k, m)
is colored based on whether x³ + y³ + z³ ≡ k (mod m) is solvable.
Dark cells indicate obstructions; light cells indicate solvability.
The mod 9 pattern is clearly visible as vertical dark bands at k ≡ 4, 5 (mod 9).
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors


def has_cubic_solution_mod(k, m):
    if m <= 0:
        return True
    target = k % m
    cubes = {pow(x, 3, m) for x in range(m)}
    for c1 in cubes:
        for c2 in cubes:
            if (target - c1 - c2) % m in cubes:
                return True
    return False


# Parameters
K_max = 100
M_max = 50

# Build the heatmap data
data = np.zeros((M_max, K_max))
for k in range(1, K_max + 1):
    for m in range(1, M_max + 1):
        data[m - 1, k - 1] = 0 if has_cubic_solution_mod(k, m) else 1

fig, ax = plt.subplots(figsize=(14, 8))

# Custom colormap: white (solvable) to dark red (obstructed)
cmap = mcolors.LinearSegmentedColormap.from_list('obstruction', ['#f0f0f0', '#8b0000'])
im = ax.imshow(data, aspect='auto', cmap=cmap, interpolation='nearest',
               extent=[0.5, K_max + 0.5, M_max + 0.5, 0.5])

ax.set_xlabel('k (target value)', fontsize=13)
ax.set_ylabel('m (modulus)', fontsize=13)
ax.set_title('Cubic Obstruction Profile Heatmap\n'
             r'Dark = $x^3+y^3+z^3 \equiv k \pmod{m}$ has no solution',
             fontsize=14)

# Mark the mod 9 obstructed columns
for k in range(1, K_max + 1):
    if k % 9 in [4, 5]:
        ax.axvline(x=k, color='blue', alpha=0.15, linewidth=1)

# Add colorbar
cbar = plt.colorbar(im, ax=ax, fraction=0.02, pad=0.04)
cbar.set_ticks([0, 1])
cbar.set_ticklabels(['Solvable', 'Obstructed'])

# Highlight mod 9 row
ax.axhline(y=9, color='cyan', alpha=0.5, linewidth=2, linestyle='--',
           label='m = 9')
ax.legend(loc='upper right', fontsize=10)

plt.tight_layout()
plt.savefig('viz_obstruction_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved viz_obstruction_heatmap.png")


#!/usr/bin/env python3
"""
Visualization 3: Obstruction Profile Density

Shows the fraction of integers k in [1, N] that are obstructed at each
modulus m. The spike at m = 9 reveals the dominant role of the mod 9
obstruction. Multiples of 9 also show elevated obstruction rates due
to upward closure (Theorem: obstruction_upward_closed).
"""

import numpy as np
import matplotlib.pyplot as plt


def has_cubic_solution_mod(k, m):
    if m <= 0:
        return True
    target = k % m
    cubes = {pow(x, 3, m) for x in range(m)}
    for c1 in cubes:
        for c2 in cubes:
            if (target - c1 - c2) % m in cubes:
                return True
    return False


N = 500
M_max = 80

# For each modulus, count how many k in [1, N] are obstructed
moduli = list(range(2, M_max + 1))
obstruction_rates = []

for m in moduli:
    obstructed = sum(1 for k in range(1, N + 1) if not has_cubic_solution_mod(k, m))
    obstruction_rates.append(obstructed / N)

fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(12, 10))

# Top panel: bar chart of obstruction rates
colors = []
for m in moduli:
    if m == 9:
        colors.append('#8b0000')  # dark red for m=9
    elif m % 9 == 0:
        colors.append('#cc4444')  # lighter red for multiples of 9
    elif m % 3 == 0:
        colors.append('#ff8888')  # pink for multiples of 3
    else:
        colors.append('#4488cc')  # blue for others

ax1.bar(moduli, obstruction_rates, color=colors, width=0.8, alpha=0.85)
ax1.set_xlabel('Modulus m', fontsize=12)
ax1.set_ylabel('Fraction of k ∈ [1,500] obstructed', fontsize=12)
ax1.set_title('Obstruction Rate by Modulus\n'
              'Red = multiples of 3, Dark red = m=9', fontsize=13)
ax1.axhline(y=2/9, color='green', linestyle='--', alpha=0.7,
            label=f'2/9 ≈ {2/9:.3f} (mod 9 prediction)')
ax1.legend(fontsize=10)

# Bottom panel: cumulative obstruction — fraction of k obstructed
# by at least one modulus ≤ m
cumulative_rates = []
for m_cutoff in moduli:
    obstructed = set()
    for m in range(2, m_cutoff + 1):
        for k in range(1, N + 1):
            if not has_cubic_solution_mod(k, m):
                obstructed.add(k)
    cumulative_rates.append(len(obstructed) / N)

ax2.plot(moduli, cumulative_rates, 'b-', linewidth=2, label='Cumulative obstruction rate')
ax2.axhline(y=2/9, color='green', linestyle='--', alpha=0.7,
            label=f'2/9 ≈ {2/9:.3f} (mod 9 alone)')
ax2.fill_between(moduli, cumulative_rates, alpha=0.15, color='blue')
ax2.set_xlabel('Maximum modulus M', fontsize=12)
ax2.set_ylabel('Fraction of k ∈ [1,500] obstructed\nby some m ≤ M', fontsize=12)
ax2.set_title('Cumulative Obstruction Coverage', fontsize=13)
ax2.legend(fontsize=10)
ax2.set_ylim(0, 0.4)

plt.tight_layout()
plt.savefig('viz_profile_density.png', dpi=150, bbox_inches='tight')
print("Saved viz_profile_density.png")
