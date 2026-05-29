#!/usr/bin/env python3
"""
Arithmetic Monsters: Applications

Demonstrates real-world applications of the digit-interaction theory:
1. Congruence sieves for factorization search spaces
2. Digit-constrained number generation (e.g., for checksums, codes)
3. Base-dependent structure analysis
"""

from collections import Counter, defaultdict
import math


def digits_base(n: int, b: int) -> list[int]:
    if n == 0 or b < 2:
        return []
    result = []
    while n > 0:
        result.append(n % b)
        n //= b
    return result


def digit_bag(n: int, b: int) -> Counter:
    return Counter(digits_base(n, b))


def digit_overlap(m: int, n: int, b: int) -> int:
    bm, bn = digit_bag(m, b), digit_bag(n, b)
    return sum(min(bm.get(d, 0), bn.get(d, 0)) for d in range(b))


def is_vampire(v: int, x: int, y: int, b: int = 10) -> bool:
    return v == x * y and digit_bag(v, b) == digit_bag(x, b) + digit_bag(y, b)


# ─────────────────────────────────────────────────────────────
# Application 1: Congruence Sieve for Factorization
# ─────────────────────────────────────────────────────────────

def congruence_sieve_demo():
    """
    Show how the mod-(b-1) obstruction acts as a sieve
    for narrowing factorization search spaces.

    In cryptographic contexts, when searching for factor pairs
    with specific digit properties, the congruence condition
    (x-1)(y-1) ≡ 1 (mod b-1) eliminates most candidates.
    """
    print("APPLICATION 1: Congruence Sieve for Factor Pair Search")
    print("=" * 60)
    print()

    for base in [10, 16, 256]:
        m = base - 1
        # Count admissible residue classes
        admissible = 0
        for rx in range(m):
            for ry in range(m):
                if (rx * ry) % m == (rx + ry) % m:
                    admissible += 1
        total = m * m
        print(f"  Base {base}: {admissible}/{total} residue classes admissible "
              f"({100*admissible/total:.1f}%)")
        print(f"    Sieve eliminates {100*(1-admissible/total):.1f}% of candidates")

    print()
    # Practical example: searching for 4-digit vampire numbers
    print("  Example: 4-digit decimal vampire number search")
    total_pairs = 0
    sieved_pairs = 0
    vampire_count = 0
    for x in range(10, 100):
        for y in range(x, 100):
            v = x * y
            if 1000 <= v <= 9999:
                total_pairs += 1
                if (x * y) % 9 == (x + y) % 9:
                    sieved_pairs += 1
                    if is_vampire(v, x, y, 10):
                        vampire_count += 1

    print(f"    Total factor pairs: {total_pairs}")
    print(f"    After mod-9 sieve: {sieved_pairs} ({100*sieved_pairs/total_pairs:.1f}%)")
    print(f"    Actual vampires: {vampire_count}")
    print(f"    Speedup factor: {total_pairs/sieved_pairs:.1f}x\n")


# ─────────────────────────────────────────────────────────────
# Application 2: Digit-Constrained Code Generation
# ─────────────────────────────────────────────────────────────

def digit_constraint_demo():
    """
    Show how digit-disjointness can be used to design
    error-detecting codes where different fields use
    non-overlapping digit sets.
    """
    print("APPLICATION 2: Digit-Disjoint Code Design")
    print("=" * 60)
    print()
    print("  Partition base-10 digits into disjoint sets:")
    print("  Set A = {1, 2, 3}  (field 1)")
    print("  Set B = {4, 5, 6}  (field 2)")
    print("  Set C = {7, 8, 9}  (field 3)")
    print()

    # Numbers using only digits from each set
    def uses_only(n: int, allowed: set, b: int = 10) -> bool:
        return all(d in allowed for d in digits_base(n, b))

    sets = [
        ({1, 2, 3}, "A"),
        ({4, 5, 6}, "B"),
        ({7, 8, 9}, "C"),
    ]

    for allowed, name in sets:
        nums = [n for n in range(1, 10000) if uses_only(n, allowed)]
        print(f"  Set {name} numbers up to 9999: {len(nums)} total")
        print(f"    Examples: {nums[:8]}...")

    print()
    print("  Property: Any two numbers from different sets are digit-disjoint")
    print("  This enables field identification from digit inspection alone")

    # Verify
    violations = 0
    for a in range(1, 100):
        if not uses_only(a, {1, 2, 3}):
            continue
        for b_val in range(1, 100):
            if not uses_only(b_val, {4, 5, 6}):
                continue
            if digit_overlap(a, b_val, 10) > 0:
                violations += 1
    print(f"  Verification (1-99): {violations} overlap violations (expected: 0)")


# ─────────────────────────────────────────────────────────────
# Application 3: Base-Dependent Structure Analysis
# ─────────────────────────────────────────────────────────────

def base_structure_demo():
    """
    Analyze how the digit-disjointness graph changes with base,
    revealing phase transitions in digit-interaction structure.
    """
    print("\nAPPLICATION 3: Base-Dependent Phase Transitions")
    print("=" * 60)
    print()
    print("  Edge density of digit-disjointness graph on {1,...,N}:")
    print()

    N = 30
    max_edges = N * (N - 1) // 2

    for base in range(2, 17):
        edges = 0
        for m in range(1, N + 1):
            for n in range(m + 1, N + 1):
                if digit_overlap(m, n, base) == 0:
                    edges += 1
        density = edges / max_edges
        bar = "█" * int(density * 40)
        print(f"    Base {base:2d}: {edges:4d}/{max_edges} edges "
              f"(density {density:.4f}) {bar}")

    print()
    print("  Phase transition at base 2 → 3:")
    print("    Base 2: 0 edges (theorem: impossible for positive numbers)")
    print("    Base 3+: positive density (theorem: infinitely many pairs)")
    print("    Density increases with base (more digits to separate)")


def main():
    print("╔════════════════════════════════════════════════════════╗")
    print("║  ARITHMETIC MONSTERS: Applications of the Theory     ║")
    print("╚════════════════════════════════════════════════════════╝\n")

    congruence_sieve_demo()
    digit_constraint_demo()
    base_structure_demo()

    print("\n" + "=" * 60)
    print("APPLICATIONS DEMO COMPLETE")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Arithmetic Monsters: Interactive Exploration and Conjecture Testing

This demo explores vampire numbers, ghost numbers, and digit-disjoint pairs
in arbitrary bases, testing conjectures from the formal theory.
"""

from collections import Counter, defaultdict
import math


def digits_base(n: int, b: int) -> list[int]:
    """Return the base-b digits of n (least significant first)."""
    if n == 0:
        return []
    if b < 2:
        return []
    result = []
    while n > 0:
        result.append(n % b)
        n //= b
    return result


def digit_bag(n: int, b: int) -> Counter:
    """Return the digit bag (multiset of digits) of n in base b."""
    return Counter(digits_base(n, b))


def digit_overlap(m: int, n: int, b: int) -> int:
    """Count shared digit occurrences between m and n in base b."""
    bag_m = digit_bag(m, b)
    bag_n = digit_bag(n, b)
    return sum(min(bag_m[d], bag_n[d]) for d in range(b))


def is_vampire(v: int, x: int, y: int, b: int = 10) -> bool:
    """Check if (x, y) is a vampire pair for v in base b."""
    if v != x * y:
        return False
    bag_v = digit_bag(v, b)
    bag_x = digit_bag(x, b)
    bag_y = digit_bag(y, b)
    return bag_v == bag_x + bag_y


def is_ghost(v: int, x: int, y: int, b: int = 10) -> bool:
    """Check if (v, x, y) is a ghost triple in base b."""
    if v != x * y:
        return False
    return digit_overlap(v, x, b) == 0 and digit_overlap(v, y, b) == 0


def is_digit_disjoint(m: int, n: int, b: int = 10) -> bool:
    """Check if m and n are digit-disjoint in base b."""
    return digit_overlap(m, n, b) == 0


def find_vampires(N: int, b: int = 10) -> list[tuple[int, int, int]]:
    """Find all vampire triples (v, x, y) with v ≤ N in base b."""
    results = []
    for v in range(4, N + 1):
        sqrt_v = int(math.isqrt(v))
        for x in range(2, sqrt_v + 1):
            if v % x != 0:
                continue
            y = v // x
            if y < x:
                continue
            if is_vampire(v, x, y, b):
                results.append((v, x, y))
    return results


def find_ghosts(N: int, b: int = 10) -> list[tuple[int, int, int]]:
    """Find all ghost triples (v, x, y) with v ≤ N in base b."""
    results = []
    for v in range(4, N + 1):
        sqrt_v = int(math.isqrt(v))
        for x in range(2, sqrt_v + 1):
            if v % x != 0:
                continue
            y = v // x
            if y < x:
                continue
            if is_ghost(v, x, y, b):
                results.append((v, x, y))
    return results


def mod_sieve_check(x: int, y: int, b: int = 10) -> bool:
    """Check the modular sieve condition: x*y ≡ x+y (mod b-1)."""
    m = b - 1
    return (x * y) % m == (x + y) % m


def demonstrate_theorem1():
    """Demonstrate Theorem 1: Modular digit-sum obstruction."""
    print("=" * 70)
    print("THEOREM 1: Modular Digit-Sum Obstruction for Vampire Pairs")
    print("For any vampire pair (x,y) with v = x*y: v ≡ x+y (mod b-1)")
    print("=" * 70)

    # Base 10: mod 9 condition
    print("\nBase 10 vampire numbers up to 100,000:")
    vampires = find_vampires(100_000, 10)
    for v, x, y in vampires[:20]:
        v_mod = v % 9
        sum_mod = (x + y) % 9
        prod_check = (x - 1) * (y - 1) % 9
        print(f"  {v} = {x} × {y}  |  v mod 9 = {v_mod}, "
              f"(x+y) mod 9 = {sum_mod}, (x-1)(y-1) mod 9 = {prod_check}")
    if len(vampires) > 20:
        print(f"  ... ({len(vampires)} total vampire triples found)")

    # Verify all satisfy the congruence
    all_pass = all((v % 9) == ((x + y) % 9) for v, x, y in vampires)
    print(f"\n  All {len(vampires)} triples satisfy v ≡ x+y (mod 9): {all_pass}")

    # Sieve effectiveness
    total_pairs = 0
    sieve_pass = 0
    for v in range(1000, 10000):
        sqrt_v = int(math.isqrt(v))
        for x in range(10, sqrt_v + 1):
            if v % x != 0:
                continue
            y = v // x
            if 10 <= y < 100 and x <= y:
                total_pairs += 1
                if mod_sieve_check(x, y, 10):
                    sieve_pass += 1
    print(f"\n  4-digit numbers: {total_pairs} factor pairs, "
          f"{sieve_pass} pass mod-9 sieve ({100*sieve_pass/total_pairs:.1f}%)")
    print(f"  Sieve eliminates {100*(1 - sieve_pass/total_pairs):.1f}% of candidates")


def demonstrate_theorem2():
    """Demonstrate Theorem 2: Ghost impossibility in base 2."""
    print("\n" + "=" * 70)
    print("THEOREM 2: Ghost Numbers Are Impossible in Base 2")
    print("Every positive binary number contains digit 1 → no digit-disjoint pairs")
    print("=" * 70)

    # Show that no positive pair is digit-disjoint in base 2
    count = 0
    for m in range(1, 200):
        for n in range(m, 200):
            if is_digit_disjoint(m, n, 2):
                count += 1
                print(f"  FOUND: {m}, {n} are digit-disjoint in base 2!")
    print(f"\n  Checked all pairs (m,n) with 1 ≤ m ≤ n ≤ 199: "
          f"{count} digit-disjoint pairs found (expected: 0)")

    # Contrast with base 3
    dd_base3 = []
    for m in range(1, 100):
        for n in range(m, 100):
            if is_digit_disjoint(m, n, 3):
                dd_base3.append((m, n))
    print(f"\n  In base 3, found {len(dd_base3)} digit-disjoint pairs among 1..99")
    for m, n in dd_base3[:10]:
        print(f"    {m} (digits: {digits_base(m, 3)}) and "
              f"{n} (digits: {digits_base(n, 3)})")


def demonstrate_theorem3():
    """Demonstrate Theorem 3: Length additivity."""
    print("\n" + "=" * 70)
    print("THEOREM 3: Length Additivity for Vampire Pairs")
    print("digitLen(v) = digitLen(x) + digitLen(y) for vampire pairs")
    print("=" * 70)

    vampires = find_vampires(100_000, 10)
    print(f"\n  Checking {len(vampires)} vampire triples in base 10:")

    by_lengths = defaultdict(int)
    for v, x, y in vampires:
        len_v = len(digits_base(v, 10))
        len_x = len(digits_base(x, 10))
        len_y = len(digits_base(y, 10))
        by_lengths[(len_v, len_x, len_y)] += 1
        assert len_v == len_x + len_y, f"VIOLATION: {v} = {x} × {y}"

    print("  All satisfy length additivity ✓")
    print("\n  Distribution by digit lengths (len_v, len_x, len_y):")
    for (lv, lx, ly), count in sorted(by_lengths.items()):
        print(f"    ({lv}, {lx}, {ly}): {count} triples")

    print("\n  COROLLARY: Vampire numbers must have even number of digits")
    print("  (when both fangs have equal length)")


def demonstrate_theorem4():
    """Demonstrate Theorem 4: Infinitude of digit-disjoint pairs in base ≥ 3."""
    print("\n" + "=" * 70)
    print("THEOREM 4: Infinitely Many Digit-Disjoint Pairs for Base ≥ 3")
    print("Uses b^k and b^(k+1)-1 as explicit witnesses")
    print("=" * 70)

    for base in [3, 5, 10, 16]:
        print(f"\n  Base {base}:")
        for k in range(1, 6):
            m = base ** k
            n = base ** (k + 1) - 1
            dd = is_digit_disjoint(m, n, base)
            m_digits = digits_base(m, base)
            n_digits = digits_base(n, base)
            print(f"    k={k}: m={m} (digits {m_digits}), "
                  f"n={n} (digits {n_digits}), disjoint={dd}")


def test_conjecture_ghost_scarcity():
    """Test Conjecture A: Ghost scarcity in base 10."""
    print("\n" + "=" * 70)
    print("CONJECTURE TEST: Ghost Scarcity in Base 10")
    print("G(N) = #{v ≤ N : ∃ ghost factorization} grows sub-polynomially?")
    print("=" * 70)

    bounds = [100, 500, 1000, 5000, 10000, 50000]
    for N in bounds:
        ghosts = find_ghosts(N, 10)
        ghost_values = set(v for v, _, _ in ghosts)
        count = len(ghost_values)
        ratio = count / N if N > 0 else 0
        log_ratio = math.log10(count + 1) / math.log10(N) if N > 1 and count > 0 else 0
        print(f"  N={N:>6}: G(N)={count:>4}, "
              f"G(N)/N={ratio:.6f}, log G(N)/log N={log_ratio:.4f}")


def test_conjecture_congruence_bias():
    """Test Conjecture B: Congruence-biased vampire scarcity."""
    print("\n" + "=" * 70)
    print("CONJECTURE TEST: Mod-9 Sieve Effectiveness")
    print("Proportion of factor pairs eliminated by (x-1)(y-1) ≡ 1 (mod 9)")
    print("=" * 70)

    for num_digits in [4, 6]:
        lo = 10 ** (num_digits - 1)
        hi = 10 ** num_digits - 1
        fang_lo = 10 ** (num_digits // 2 - 1)
        fang_hi = 10 ** (num_digits // 2) - 1

        total = 0
        passes = 0
        for x in range(fang_lo, min(fang_hi + 1, fang_lo + 500)):
            for y in range(x, min(fang_hi + 1, x + 500)):
                v = x * y
                if lo <= v <= hi:
                    total += 1
                    if mod_sieve_check(x, y, 10):
                        passes += 1

        if total > 0:
            print(f"  {num_digits}-digit numbers: {passes}/{total} "
                  f"pass sieve ({100*passes/total:.1f}%), "
                  f"eliminated {100*(1-passes/total):.1f}%")


def explore_digit_disjointness_graph():
    """Explore the digit-disjointness graph structure."""
    print("\n" + "=" * 70)
    print("DIGIT-DISJOINTNESS GRAPH EXPLORATION")
    print("Vertices: positive integers, Edges: digit-disjoint pairs")
    print("=" * 70)

    for base in [2, 3, 5, 10]:
        edges = []
        N = 50
        for m in range(1, N + 1):
            for n in range(m + 1, N + 1):
                if is_digit_disjoint(m, n, base):
                    edges.append((m, n))

        # Find degrees
        degrees = Counter()
        for m, n in edges:
            degrees[m] += 1
            degrees[n] += 1

        max_deg = max(degrees.values()) if degrees else 0
        avg_deg = sum(degrees.values()) / N if N > 0 else 0

        print(f"\n  Base {base}, vertices 1..{N}:")
        print(f"    Edges: {len(edges)}, Max degree: {max_deg}, "
              f"Avg degree: {avg_deg:.2f}")
        if edges and len(edges) <= 10:
            for m, n in edges[:10]:
                print(f"      {m} -- {n}")


def main():
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║  ARITHMETIC MONSTERS: Interactive Exploration & Conjecture Testing  ║")
    print("╚══════════════════════════════════════════════════════════════════════╝\n")

    demonstrate_theorem1()
    demonstrate_theorem2()
    demonstrate_theorem3()
    demonstrate_theorem4()

    test_conjecture_ghost_scarcity()
    test_conjecture_congruence_bias()

    explore_digit_disjointness_graph()

    print("\n" + "=" * 70)
    print("DEMO COMPLETE")
    print("=" * 70)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Digit-Disjointness Heatmap

Visualizes the digit-disjointness adjacency matrix for small numbers
across multiple bases, revealing the base-2 → base-3 phase transition.
Each pixel (i,j) is colored by digit overlap: darker = more overlap,
white = digit-disjoint (overlap = 0).
"""

import matplotlib.pyplot as plt
import numpy as np
from collections import Counter


def digits_base(n, b):
    if n == 0 or b < 2:
        return []
    result = []
    while n > 0:
        result.append(n % b)
        n //= b
    return result


def digit_overlap(m, n, b):
    bm = Counter(digits_base(m, b))
    bn = Counter(digits_base(n, b))
    return sum(min(bm.get(d, 0), bn.get(d, 0)) for d in range(b))


N = 40
bases = [2, 3, 5, 10]

fig, axes = plt.subplots(1, 4, figsize=(16, 4))
fig.suptitle("Digit Overlap Matrices by Base\n(White = digit-disjoint, dark = high overlap)",
             fontsize=13, fontweight='bold')

for idx, b in enumerate(bases):
    mat = np.zeros((N, N))
    for i in range(1, N + 1):
        for j in range(1, N + 1):
            mat[i-1, j-1] = digit_overlap(i, j, b)

    ax = axes[idx]
    im = ax.imshow(mat, cmap='YlOrRd', origin='lower', aspect='equal',
                   extent=[1, N, 1, N])
    ax.set_title(f"Base {b}", fontsize=12)
    ax.set_xlabel("n")
    if idx == 0:
        ax.set_ylabel("m")

    # Mark diagonal
    ax.plot([1, N], [1, N], 'k--', alpha=0.3, linewidth=0.5)

    plt.colorbar(im, ax=ax, shrink=0.8, label="Overlap")

plt.tight_layout()
plt.savefig("viz_heatmap.png", dpi=150, bbox_inches='tight')
print("Saved viz_heatmap.png")


#!/usr/bin/env python3
"""
Visualization: Phase Transition in Digit-Disjointness

Shows the dramatic phase transition from base 2 (zero digit-disjoint pairs
among positive integers) to base 3+ (infinitely many such pairs).
Plots edge density of the digit-disjointness graph as a function of base.
"""

import matplotlib.pyplot as plt
import numpy as np
from collections import Counter


def digits_base(n, b):
    if n == 0 or b < 2:
        return []
    result = []
    while n > 0:
        result.append(n % b)
        n //= b
    return result


def digit_overlap(m, n, b):
    bm = Counter(digits_base(m, b))
    bn = Counter(digits_base(n, b))
    return sum(min(bm.get(d, 0), bn.get(d, 0)) for d in range(b))


N = 50
bases = list(range(2, 21))
max_edges = N * (N - 1) / 2

edge_counts = []
densities = []
max_degrees = []

for b in bases:
    edges = 0
    degrees = [0] * (N + 1)
    for m in range(1, N + 1):
        for n in range(m + 1, N + 1):
            if digit_overlap(m, n, b) == 0:
                edges += 1
                degrees[m] += 1
                degrees[n] += 1
    edge_counts.append(edges)
    densities.append(edges / max_edges)
    max_degrees.append(max(degrees[1:]))

fig, axes = plt.subplots(1, 3, figsize=(15, 5))
fig.suptitle(f"Digit-Disjointness Graph: Phase Transition (vertices 1..{N})",
             fontsize=14, fontweight='bold')

# Plot 1: Edge count
ax1 = axes[0]
colors = ['red' if b == 2 else 'steelblue' for b in bases]
ax1.bar(bases, edge_counts, color=colors, alpha=0.8)
ax1.set_xlabel("Base b")
ax1.set_ylabel("Number of edges")
ax1.set_title("Edge Count")
ax1.annotate("Base 2: 0 edges\n(proved impossible)", xy=(2, 0),
             xytext=(5, max(edge_counts) * 0.3),
             arrowprops=dict(arrowstyle='->', color='red'),
             fontsize=9, color='red', fontweight='bold')

# Plot 2: Edge density
ax2 = axes[1]
ax2.plot(bases, densities, 'o-', color='darkgreen', markersize=6)
ax2.axvline(x=2.5, color='red', linestyle='--', alpha=0.5, label='Phase transition')
ax2.set_xlabel("Base b")
ax2.set_ylabel("Edge density")
ax2.set_title("Edge Density")
ax2.legend()
ax2.fill_between([1.5, 2.5], 0, 1, alpha=0.1, color='red')
ax2.fill_between([2.5, 21], 0, 1, alpha=0.05, color='green')
ax2.set_ylim(0, max(densities) * 1.1)

# Plot 3: Maximum degree
ax3 = axes[2]
ax3.plot(bases, max_degrees, 's-', color='purple', markersize=6)
ax3.set_xlabel("Base b")
ax3.set_ylabel("Maximum vertex degree")
ax3.set_title("Max Degree (hub structure)")
ax3.axvline(x=2.5, color='red', linestyle='--', alpha=0.5)

plt.tight_layout()
plt.savefig("viz_phase_transition.png", dpi=150, bbox_inches='tight')
print("Saved viz_phase_transition.png")


#!/usr/bin/env python3
"""
Visualization: Modular Sieve Effectiveness

Shows how the mod-(b-1) congruence sieve eliminates candidate factor pairs
for vampire numbers. Plots the admissible residue classes and sieve
effectiveness across different bases.
"""

import matplotlib.pyplot as plt
import numpy as np


def mod_sieve_effectiveness(b):
    """Fraction of residue pairs (rx, ry) mod (b-1) that pass the sieve."""
    m = b - 1
    if m == 0:
        return 1.0
    admissible = 0
    total = m * m
    for rx in range(m):
        for ry in range(m):
            if (rx * ry) % m == (rx + ry) % m:
                admissible += 1
    return admissible / total


fig, axes = plt.subplots(1, 3, figsize=(15, 5))
fig.suptitle("Modular Sieve for Vampire Number Candidates",
             fontsize=14, fontweight='bold')

# Plot 1: Sieve effectiveness vs base
bases = list(range(3, 51))
survival = [mod_sieve_effectiveness(b) for b in bases]
elimination = [1 - s for s in survival]

ax1 = axes[0]
ax1.bar(bases, elimination, color='steelblue', alpha=0.7, width=0.8)
ax1.set_xlabel("Base b")
ax1.set_ylabel("Fraction eliminated")
ax1.set_title("Sieve Elimination Rate by Base")
ax1.set_ylim(0, 1)
ax1.axhline(y=0.5, color='red', linestyle='--', alpha=0.5, label='50%')
ax1.legend()

# Plot 2: Admissible residue grid for base 10
ax2 = axes[1]
m = 9  # base 10, mod 9
grid = np.zeros((m, m))
for rx in range(m):
    for ry in range(m):
        if (rx * ry) % m == (rx + ry) % m:
            grid[rx, ry] = 1
ax2.imshow(grid, cmap='RdYlGn', origin='lower', aspect='equal',
           extent=[-0.5, m-0.5, -0.5, m-0.5])
ax2.set_xlabel("y mod 9")
ax2.set_ylabel("x mod 9")
ax2.set_title("Admissible Residues (Base 10)\nGreen = passes sieve")
ax2.set_xticks(range(m))
ax2.set_yticks(range(m))

# Plot 3: Admissible residue grid for base 16
ax3 = axes[2]
m = 15  # base 16, mod 15
grid = np.zeros((m, m))
for rx in range(m):
    for ry in range(m):
        if (rx * ry) % m == (rx + ry) % m:
            grid[rx, ry] = 1
ax3.imshow(grid, cmap='RdYlGn', origin='lower', aspect='equal',
           extent=[-0.5, m-0.5, -0.5, m-0.5])
ax3.set_xlabel("y mod 15")
ax3.set_ylabel("x mod 15")
ax3.set_title("Admissible Residues (Base 16)\nGreen = passes sieve")
ax3.set_xticks(range(0, m, 3))
ax3.set_yticks(range(0, m, 3))

plt.tight_layout()
plt.savefig("viz_sieve.png", dpi=150, bbox_inches='tight')
print("Saved viz_sieve.png")
