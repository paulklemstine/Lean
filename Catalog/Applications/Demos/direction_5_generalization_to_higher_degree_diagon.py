#!/usr/bin/env python3
"""
Diagonal Obstruction Calculus — Applications

Demonstrates practical applications of the local obstruction framework:
1. Waring's problem local analysis
2. Identifying impossible representations
3. Predicting representability from local data
4. Cross-degree comparison of obstruction patterns
"""

from math import gcd


def nth_power_residues(n: int, m: int) -> set[int]:
    return {pow(a, n, m) for a in range(m)}


def diagonal_residue_sums(n: int, s: int, m: int) -> set[int]:
    if m <= 0:
        raise ValueError(f"Modulus must be positive, got {m}")
    if s <= 0:
        return {0}
    residues = nth_power_residues(n, m)
    current = {0}
    for _ in range(s):
        current = {(a + r) % m for a in current for r in residues}
    return current


def is_universally_surjective(n: int, s: int, m: int) -> bool:
    return len(diagonal_residue_sums(n, s, m)) == m


def factorize(n: int) -> dict[int, int]:
    if n <= 1:
        return {}
    factors: dict[int, int] = {}
    d = 2
    while d * d <= n:
        while n % d == 0:
            factors[d] = factors.get(d, 0) + 1
            n //= d
        d += 1
    if n > 1:
        factors[n] = factors.get(n, 0) + 1
    return factors


def application_1_impossible_representations():
    """
    APPLICATION 1: Detecting impossible Diophantine equations.

    Use local obstructions to prove that certain integers CANNOT be
    represented as sums of powers in specific ways.
    """
    print("=" * 70)
    print("APPLICATION 1: Impossible Representations")
    print("=" * 70)

    # Classic: sums of three cubes mod 9
    print("\n--- Sums of Three Cubes (n=3, s=3) ---")
    residues_mod9 = diagonal_residue_sums(3, 3, 9)
    print(f"Representable residues mod 9: {sorted(residues_mod9)}")
    impossible = set(range(9)) - residues_mod9
    print(f"Impossible residues mod 9: {sorted(impossible)}")
    print("=> Integers k ≡ 4 or 5 (mod 9) can NEVER be written as x³+y³+z³")

    # Application: check specific famous numbers
    famous_numbers = [33, 42, 114, 165, 390, 579, 627, 906]
    for k in famous_numbers:
        residue = k % 9
        possible = residue in residues_mod9
        status = "POSSIBLE" if possible else "IMPOSSIBLE"
        print(f"  k={k}: k≡{residue} (mod 9) → {status}")

    # Biquadratic case
    print("\n--- Sums of Four Biquadrates (n=4, s=4) ---")
    for m in [2, 4, 8, 16, 5, 13, 17]:
        residues = diagonal_residue_sums(4, 4, m)
        if len(residues) < m:
            missing = sorted(set(range(m)) - residues)
            print(f"  mod {m:3d}: {len(residues)}/{m} representable, "
                  f"obstructed: {missing}")
        else:
            print(f"  mod {m:3d}: ALL representable (surjective)")


def application_2_waring_variable_count():
    """
    APPLICATION 2: Estimating the minimum number of variables for
    local completeness at each degree.

    This gives lower bounds for Waring-type problems from local data alone.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 2: Waring Variable Count from Local Data")
    print("=" * 70)

    max_m = 50

    print(f"\nFor each degree n, find min s such that all m ≤ {max_m} are surjective:")
    print(f"{'n':>3s} | {'s_min':>5s} | {'Known g(n)':>10s} | {'Known G(n)':>10s}")
    print("-" * 45)

    # Known values of g(n) and G(n) for reference
    known_g = {2: 4, 3: 9, 4: 19, 5: 37, 6: 73}
    known_G = {2: 4, 3: 7, 4: 15, 5: "≤21", 6: "≤31"}

    for n_deg in range(2, 7):
        for s in range(1, 40):
            if all(is_universally_surjective(n_deg, s, m)
                   for m in range(1, max_m + 1)):
                g_val = known_g.get(n_deg, "?")
                G_val = known_G.get(n_deg, "?")
                print(f"{n_deg:3d} | {s:5d} | {str(g_val):>10s} | {str(G_val):>10s}")
                break


def application_3_cross_degree_patterns():
    """
    APPLICATION 3: Cross-degree comparison of obstruction primes.

    Different degrees exhibit different obstruction patterns.
    This reveals the arithmetic structure underlying Waring's problem.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 3: Cross-Degree Obstruction Patterns")
    print("=" * 70)

    max_m = 50

    for n_deg in range(2, 7):
        print(f"\n--- Degree n={n_deg} ---")
        # Find the minimal s for which most moduli work
        for s in [n_deg, n_deg + 1, 2 * n_deg]:
            obstruction_moduli = []
            for m in range(2, max_m + 1):
                if not is_universally_surjective(n_deg, s, m):
                    obstruction_moduli.append(m)

            if obstruction_moduli:
                # Find obstruction prime powers
                pp_obstructions = []
                for m in obstruction_moduli:
                    f = factorize(m)
                    if len(f) == 1:
                        pp_obstructions.append(m)
                print(f"  s={s:2d}: {len(obstruction_moduli):3d} obstructed moduli, "
                      f"prime-power obstructions: {pp_obstructions[:10]}")
            else:
                print(f"  s={s:2d}: ALL moduli surjective (no obstructions)")


def application_4_prediction():
    """
    APPLICATION 4: Predict representability using local data.

    For a given k, check all moduli up to a bound to see if there
    are any local obstructions. If none found, k is "locally everywhere
    admissible" — a necessary condition for representability.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 4: Representability Prediction")
    print("=" * 70)

    n, s = 3, 3
    max_m = 50

    print(f"\nChecking local admissibility for x³+y³+z³=k, k=1..100, mod m≤{max_m}")
    print()

    locally_admissible = []
    locally_obstructed = []

    for k in range(1, 101):
        obstructed_at = None
        for m in range(2, max_m + 1):
            residues = diagonal_residue_sums(n, s, m)
            if k % m not in residues:
                obstructed_at = m
                break
        if obstructed_at is None:
            locally_admissible.append(k)
        else:
            locally_obstructed.append((k, obstructed_at))

    print(f"Locally admissible k (no obstruction mod any m ≤ {max_m}):")
    print(f"  {locally_admissible}")
    print(f"\nLocally obstructed k (with first obstruction modulus):")
    for k, m in locally_obstructed[:20]:
        print(f"  k={k:3d}: obstructed mod {m} (k≡{k%m} mod {m})")
    if len(locally_obstructed) > 20:
        print(f"  ... and {len(locally_obstructed) - 20} more")


def application_5_unit_symmetry():
    """
    APPLICATION 5: Exploiting unit power symmetry to reduce computation.

    The unit power symmetry theorem says multiplication by n-th power units
    preserves the representable set. This can dramatically reduce the
    number of residues that need to be checked.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 5: Computation Reduction via Unit Symmetry")
    print("=" * 70)

    n, s = 4, 4

    for m in [5, 13, 16, 17, 25]:
        res_set = diagonal_residue_sums(n, s, m)
        units = [a for a in range(m) if gcd(a, m) == 1]
        nth_power_units = {pow(u, n, m) for u in units}

        # Compute orbits
        visited = set()
        orbits = []
        for r in sorted(res_set):
            if r in visited:
                continue
            orbit = {(u * r) % m for u in nth_power_units}
            visited.update(orbit)
            orbits.append(sorted(orbit))

        print(f"\n  m={m}: {len(res_set)}/{m} representable, "
              f"{len(nth_power_units)} 4th-power units, "
              f"{len(orbits)} orbits")
        for i, orb in enumerate(orbits[:5]):
            print(f"    Orbit {i}: {orb}")
        if len(orbits) > 5:
            print(f"    ... and {len(orbits) - 5} more orbits")

        reduction = 1 - len(orbits) / max(len(res_set), 1)
        print(f"    Computation reduction: {reduction:.0%} "
              f"({len(res_set)} residues → {len(orbits)} orbits)")


if __name__ == "__main__":
    application_1_impossible_representations()
    application_2_waring_variable_count()
    application_3_cross_degree_patterns()
    application_4_prediction()
    application_5_unit_symmetry()


#!/usr/bin/env python3
"""
Diagonal Obstruction Calculus — Computational Experiments

Computes admissible residue sets for sums of 4 fourth powers (biquadrates)
modulo all m ≤ 100, identifies obstruction moduli, analyzes prime-power
patterns, and compares with the conjectural pattern.
"""

import itertools
from collections import defaultdict
from math import gcd


def nth_power_residues(n: int, m: int) -> set:
    """Compute the set of n-th power residues modulo m."""
    return {pow(a, n, m) for a in range(m)}


def diagonal_residue_sums(n: int, s: int, m: int) -> set:
    """
    Compute the set of all sums of s n-th powers modulo m.
    Returns the set of residues r mod m such that
    r ≡ x₁ⁿ + x₂ⁿ + ⋯ + xₛⁿ (mod m) for some x₁,...,xₛ.
    """
    residues = nth_power_residues(n, m)
    # Start with {0} and iteratively add one term
    current = {0}
    for _ in range(s):
        current = {(a + r) % m for a in current for r in residues}
    return current


def is_universally_surjective(n: int, s: int, m: int) -> bool:
    """Check if every residue class mod m is a sum of s n-th powers."""
    return len(diagonal_residue_sums(n, s, m)) == m


def factorize(n: int) -> dict:
    """Return prime factorization as {prime: exponent}."""
    factors = {}
    d = 2
    while d * d <= n:
        while n % d == 0:
            factors[d] = factors.get(d, 0) + 1
            n //= d
        d += 1
    if n > 1:
        factors[n] = factors.get(n, 0) + 1
    return factors


def prime_power_divisors(m: int) -> list:
    """Return all prime power divisors p^a of m."""
    factors = factorize(m)
    result = []
    for p, e in factors.items():
        for a in range(1, e + 1):
            result.append((p, a, p ** a))
    return result


def main():
    n, s = 4, 4
    max_m = 100

    print("=" * 70)
    print(f"DIAGONAL OBSTRUCTION CALCULUS — BIQUADRATIC EXPERIMENTS")
    print(f"Equation: x₁⁴ + x₂⁴ + x₃⁴ + x₄⁴ = k")
    print(f"Degree n={n}, Variables s={s}, Moduli m=1..{max_m}")
    print("=" * 70)

    # 1. Compute admissible residue sets
    print("\n1. ADMISSIBLE RESIDUE SETS")
    print("-" * 40)

    surjective_moduli = []
    non_surjective_moduli = []

    for m in range(1, max_m + 1):
        residues = diagonal_residue_sums(n, s, m)
        density = len(residues) / m
        if len(residues) == m:
            surjective_moduli.append(m)
        else:
            non_surjective_moduli.append((m, len(residues), m - len(residues)))
            missing = set(range(m)) - residues
            if m <= 30:
                print(f"  m={m:3d}: {len(residues):3d}/{m:3d} residues "
                      f"(density={density:.3f}), missing: {sorted(missing)}")

    print(f"\n  Total surjective moduli (1..{max_m}): {len(surjective_moduli)}")
    print(f"  Total non-surjective moduli: {len(non_surjective_moduli)}")

    # 2. Identify moduli where surjectivity fails
    print("\n2. NON-SURJECTIVE MODULI (OBSTRUCTION MODULI)")
    print("-" * 40)

    for m, count, missing_count in non_surjective_moduli:
        factors = factorize(m)
        factor_str = " × ".join(f"{p}^{e}" if e > 1 else str(p)
                                for p, e in sorted(factors.items()))
        print(f"  m={m:3d} = {factor_str:15s}: "
              f"{count:3d}/{m:3d} admissible ({missing_count} missing)")

    # 3. Factor and summarize prime-power pattern
    print("\n3. PRIME-POWER ANALYSIS")
    print("-" * 40)

    # Check which prime powers are non-surjective
    print("  Prime power obstruction analysis:")
    obstruction_primes = set()
    for p in range(2, max_m + 1):
        if all(factorize(p).values()) and len(factorize(p)) == 1:  # p is prime power
            factors = factorize(p)
            prime = list(factors.keys())[0]
            exp = list(factors.values())[0]
            if not is_universally_surjective(n, s, p):
                obstruction_primes.add(prime)
                print(f"    {prime}^{exp} = {p}: NOT surjective "
                      f"({len(diagonal_residue_sums(n, s, p))}/{p} residues)")

    print(f"\n  Obstruction primes: {sorted(obstruction_primes)}")
    print(f"  Primes ≡ 1 (mod 4) up to {max_m}: "
          f"{sorted(p for p in range(2, max_m+1) if len(factorize(p)) == 1 and list(factorize(p).values()) == [1] and p % 4 == 1)}")

    # 4. Compare with conjectural pattern
    print("\n4. CONJECTURE COMPARISON")
    print("-" * 40)
    print("  Conjecture: For m ≤ 100, surjectivity fails only when m has")
    print("  a prime factor p=2 or p ≡ 1 (mod 4).")
    print()

    conjecture_holds = True
    for m, count, missing_count in non_surjective_moduli:
        factors = factorize(m)
        has_bad_prime = any(p == 2 or p % 4 == 1 for p in factors)
        if not has_bad_prime:
            print(f"  COUNTEREXAMPLE: m={m} is non-surjective but has no "
                  f"'bad' prime factors!")
            conjecture_holds = False

    if conjecture_holds:
        print("  All non-surjective moduli have a prime factor that is 2 or ≡ 1 (mod 4).")
        print("  Conjecture is CONSISTENT with data up to m=100.")
    else:
        print("  Conjecture is REFUTED!")

    # Check the converse: are there surjective moduli with 'bad' primes?
    print()
    bad_but_surjective = []
    for m in surjective_moduli:
        if m == 1:
            continue
        factors = factorize(m)
        has_bad_prime = any(p == 2 or p % 4 == 1 for p in factors)
        if has_bad_prime:
            bad_but_surjective.append(m)

    if bad_but_surjective:
        print(f"  Note: {len(bad_but_surjective)} surjective moduli have 'bad' primes")
        print(f"  (conjecture only claims necessary condition for obstruction)")
        if len(bad_but_surjective) <= 20:
            print(f"  Examples: {bad_but_surjective}")

    # 5. Density summary
    print("\n5. ADMISSIBLE DENSITY BY MODULUS")
    print("-" * 40)
    for m in range(1, min(51, max_m + 1)):
        residues = diagonal_residue_sums(n, s, m)
        density = len(residues) / m
        bar = "█" * int(density * 40)
        surj = "✓" if density == 1.0 else " "
        print(f"  m={m:3d}: {density:.3f} {surj} |{bar}")

    # 6. Fourth-power residue analysis
    print("\n6. FOURTH-POWER RESIDUE COUNTS")
    print("-" * 40)
    for m in range(2, 31):
        res = nth_power_residues(4, m)
        print(f"  mod {m:2d}: {len(res):2d} residues = {sorted(res)}")

    # 7. Unit power symmetry demonstration
    print("\n7. UNIT POWER SYMMETRY (Theorem 4 demo)")
    print("-" * 40)
    m = 16
    res_set = diagonal_residue_sums(n, s, m)
    print(f"  For m={m}, residue sums = {sorted(res_set)}")

    # Find 4th power units
    units = [a for a in range(m) if gcd(a, m) == 1]
    fourth_power_units = {pow(a, 4, m) for a in units}
    print(f"  Units mod {m}: {sorted(units)}")
    print(f"  4th power units mod {m}: {sorted(fourth_power_units)}")

    for u in sorted(fourth_power_units):
        scaled = {(u * r) % m for r in res_set}
        invariant = scaled == res_set
        print(f"    u={u}: u·R = {sorted(scaled)}, "
              f"invariant: {'YES ✓' if invariant else 'NO ✗'}")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Admissible Density Heatmap for Biquadratic Sums

Visualizes the density of representable residues for x₁⁴+x₂⁴+x₃⁴+x₄⁴ ≡ k (mod m)
across varying numbers of variables s and moduli m.
Dark cells indicate obstruction moduli where not all residues are representable.
"""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def nth_power_residues(n, m):
    return {pow(a, n, m) for a in range(m)}


def diagonal_residue_sums(n, s, m):
    if s <= 0:
        return {0}
    residues = nth_power_residues(n, m)
    current = {0}
    for _ in range(s):
        current = {(a + r) % m for a in current for r in residues}
    return current


n = 4
max_m = 60
max_s = 10

# Compute density matrix
density = np.zeros((max_s, max_m - 1))
for s in range(1, max_s + 1):
    for m in range(2, max_m + 1):
        res = diagonal_residue_sums(n, s, m)
        density[s - 1, m - 2] = len(res) / m

fig, ax = plt.subplots(figsize=(16, 6))
im = ax.imshow(density, aspect='auto', cmap='RdYlGn',
               vmin=0, vmax=1, interpolation='nearest',
               extent=[2, max_m + 0.5, max_s + 0.5, 0.5])

ax.set_xlabel('Modulus m', fontsize=13)
ax.set_ylabel('Number of variables s', fontsize=13)
ax.set_title(f'Density of Representable Residues: Sums of s Fourth Powers mod m\n'
             f'(Green = surjective, Red = obstructed)', fontsize=14)

# Mark integer ticks
ax.set_yticks(range(1, max_s + 1))

cbar = plt.colorbar(im, ax=ax, label='Density |R(n,s,m)| / m')

# Annotate obstruction moduli for s=4
for m in range(2, max_m + 1):
    if density[3, m - 2] < 1.0:
        ax.plot(m, 4, 'kx', markersize=6, markeredgewidth=1.5)

ax.legend(['Obstruction (s=4)'], loc='upper right', fontsize=10)

plt.tight_layout()
plt.savefig('viz_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved viz_heatmap.png")


#!/usr/bin/env python3
"""
Visualization: Obstruction Prime Powers for Diagonal Forms

Shows which prime powers cause local obstructions for x₁ⁿ+⋯+xₛⁿ=k
across degrees n=2..6 and variable counts s=n..2n.
Reveals the arithmetic structure underlying Waring-type problems.
"""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from math import gcd


def nth_power_residues(n, m):
    return {pow(a, n, m) for a in range(m)}


def diagonal_residue_sums(n, s, m):
    if s <= 0:
        return {0}
    residues = nth_power_residues(n, m)
    current = {0}
    for _ in range(s):
        current = {(a + r) % m for a in current for r in residues}
    return current


def is_surjective(n, s, m):
    return len(diagonal_residue_sums(n, s, m)) == m


def factorize(n):
    factors = {}
    d = 2
    while d * d <= n:
        while n % d == 0:
            factors[d] = factors.get(d, 0) + 1
            n //= d
        d += 1
    if n > 1:
        factors[n] = factors.get(n, 0) + 1
    return factors


# Compute obstruction data
primes = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31]
max_exp = 4
degrees = [2, 3, 4, 5, 6]

fig, axes = plt.subplots(len(degrees), 1, figsize=(14, 12), sharex=True)

for idx, n in enumerate(degrees):
    ax = axes[idx]
    s_values = list(range(n, 2 * n + 1))

    pp_labels = []
    for p in primes:
        for e in range(1, max_exp + 1):
            if p ** e <= 100:
                pp_labels.append(f"{p}^{e}" if e > 1 else str(p))

    matrix = np.zeros((len(s_values), len(pp_labels)))

    col = 0
    for p in primes:
        for e in range(1, max_exp + 1):
            m = p ** e
            if m > 100:
                continue
            for row, s in enumerate(s_values):
                density = len(diagonal_residue_sums(n, s, m)) / m
                matrix[row, col] = density
            col += 1

    im = ax.imshow(matrix[:, :col], aspect='auto', cmap='RdYlGn',
                   vmin=0, vmax=1, interpolation='nearest')

    ax.set_yticks(range(len(s_values)))
    ax.set_yticklabels([str(s) for s in s_values])
    ax.set_ylabel(f'n={n}\n(s vars)', fontsize=10)

    if idx == len(degrees) - 1:
        ax.set_xticks(range(col))
        ax.set_xticklabels(pp_labels[:col], rotation=45, ha='right', fontsize=8)
        ax.set_xlabel('Prime power modulus', fontsize=12)

    # Mark non-surjective cells
    for row in range(len(s_values)):
        for c in range(col):
            if matrix[row, c] < 1.0:
                ax.text(c, row, f'{matrix[row,c]:.1f}', ha='center', va='center',
                        fontsize=6, color='black')

fig.suptitle('Local Surjectivity at Prime Powers: Degrees 2–6\n'
             '(Green = surjective, Red = obstructed, numbers show density)',
             fontsize=14, fontweight='bold')

plt.tight_layout()
plt.savefig('viz_obstruction_primes.png', dpi=150, bbox_inches='tight')
print("Saved viz_obstruction_primes.png")


#!/usr/bin/env python3
"""
Visualization: Orbit Structure of Residue Sums Under Unit Actions

For sums of 4 fourth powers, shows how the representable residue set
decomposes into orbits under multiplication by 4th-power units.
This illustrates the unit power symmetry theorem.
"""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from math import gcd


def nth_power_residues(n, m):
    return {pow(a, n, m) for a in range(m)}


def diagonal_residue_sums(n, s, m):
    if s <= 0:
        return {0}
    residues = nth_power_residues(n, m)
    current = {0}
    for _ in range(s):
        current = {(a + r) % m for a in current for r in residues}
    return current


n, s = 4, 4
moduli = [8, 16, 25, 32]

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

for idx, m in enumerate(moduli):
    ax = axes[idx // 2][idx % 2]

    res_set = diagonal_residue_sums(n, s, m)
    units = [a for a in range(m) if gcd(a, m) == 1]
    nth_power_units = sorted({pow(u, n, m) for u in units})

    # Compute orbits
    visited = set()
    orbits = []
    for r in range(m):
        if r in visited:
            continue
        orbit = {(u * r) % m for u in nth_power_units}
        visited.update(orbit)
        in_set = orbit & res_set
        out_set = orbit - res_set
        orbits.append((sorted(orbit), len(in_set) > 0))

    # Create circular layout
    angles = np.linspace(0, 2 * np.pi, m, endpoint=False)
    x_pos = np.cos(angles)
    y_pos = np.sin(angles)

    # Color by orbit membership
    colors = []
    for r in range(m):
        if r in res_set:
            colors.append('#2ecc71')  # Green for representable
        else:
            colors.append('#e74c3c')  # Red for non-representable

    ax.scatter(x_pos, y_pos, c=colors, s=200, zorder=5, edgecolors='black', linewidth=0.5)

    # Label residues
    for r in range(m):
        offset = 1.15
        ax.text(x_pos[r] * offset, y_pos[r] * offset, str(r),
                ha='center', va='center', fontsize=7)

    # Draw orbit connections with lines
    orbit_colors = plt.cm.Set2(np.linspace(0, 1, len(orbits)))
    for oi, (orbit, in_res) in enumerate(orbits):
        if len(orbit) > 1:
            for i in range(len(orbit)):
                for j in range(i + 1, len(orbit)):
                    r1, r2 = orbit[i], orbit[j]
                    ax.plot([x_pos[r1], x_pos[r2]],
                           [y_pos[r1], y_pos[r2]],
                           color=orbit_colors[oi], alpha=0.3, linewidth=0.8)

    ax.set_title(f'm = {m}: {len(res_set)}/{m} representable, '
                 f'{len(orbits)} orbits\n'
                 f'4th-power units: {nth_power_units}',
                 fontsize=10)
    ax.set_xlim(-1.4, 1.4)
    ax.set_ylim(-1.4, 1.4)
    ax.set_aspect('equal')
    ax.axis('off')

# Add legend
from matplotlib.patches import Patch
legend_elements = [
    Patch(facecolor='#2ecc71', edgecolor='black', label='Representable'),
    Patch(facecolor='#e74c3c', edgecolor='black', label='Obstructed'),
]
fig.legend(handles=legend_elements, loc='lower center', ncol=2, fontsize=11)

fig.suptitle('Orbit Decomposition of Residue Sums Under 4th-Power Unit Action\n'
             'x₁⁴ + x₂⁴ + x₃⁴ + x₄⁴ ≡ k (mod m)',
             fontsize=14, fontweight='bold')

plt.tight_layout(rect=[0, 0.05, 1, 0.93])
plt.savefig('viz_orbit_structure.png', dpi=150, bbox_inches='tight')
print("Saved viz_orbit_structure.png")
