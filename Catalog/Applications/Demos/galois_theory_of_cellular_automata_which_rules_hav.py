#!/usr/bin/env python3
"""
Demo: Galois Theory of Cellular Automata — Reversibility Groups

Demonstrates the key mathematical results:
1. Enumeration of reversible elementary CA rules
2. Group structure of the reversibility group
3. Necklace (orbit) counting via Burnside's lemma
4. Centralizer computation for the shift action
"""

from itertools import product
from math import gcd, factorial
from collections import Counter


def eca_rule(rule_number: int, left: int, center: int, right: int) -> int:
    """Apply elementary CA rule to a neighborhood (left, center, right)."""
    index = 4 * left + 2 * center + right
    return (rule_number >> index) & 1


def apply_eca_global(rule_number: int, config: tuple) -> tuple:
    """Apply ECA rule globally to a periodic configuration."""
    n = len(config)
    return tuple(
        eca_rule(rule_number, config[(i - 1) % n], config[i], config[(i + 1) % n])
        for i in range(n)
    )


def is_reversible_on_period(rule_number: int, n: int) -> bool:
    """Check if rule is reversible (bijective) on configurations of period n."""
    configs = list(product([0, 1], repeat=n))
    images = [apply_eca_global(rule_number, c) for c in configs]
    return len(set(images)) == len(configs)


def find_reversible_rules(n: int = 5) -> list:
    """Find all 256 ECA rules that are reversible on period-n configurations."""
    return [r for r in range(256) if is_reversible_on_period(r, n)]


def shift_cycle_type(n: int) -> dict:
    """Compute the cycle type of the shift σ acting on {0,1}^n.

    Returns a dict: cycle_length -> number_of_cycles
    """
    configs = list(product([0, 1], repeat=n))
    config_to_idx = {c: i for i, c in enumerate(configs)}
    visited = [False] * len(configs)
    cycles = []

    for i, c in enumerate(configs):
        if visited[i]:
            continue
        cycle = []
        j = i
        while not visited[j]:
            visited[j] = True
            cycle.append(j)
            # Shift: move each element one position to the left (cyclic)
            shifted = configs[j][1:] + (configs[j][0],)
            j = config_to_idx[shifted]
        cycles.append(len(cycle))

    return dict(Counter(cycles))


def centralizer_order(cycle_type: dict) -> int:
    """Compute |C_{S_N}(σ)| from the cycle type of σ.

    For a permutation with a_k cycles of length k,
    |centralizer| = ∏_k (a_k! · k^{a_k})
    """
    result = 1
    for k, a_k in cycle_type.items():
        result *= factorial(a_k) * (k ** a_k)
    return result


def necklace_count(n: int, k: int = 2) -> int:
    """Count binary necklaces of length n using Burnside's lemma.

    Number of orbits = (1/n) Σ_{d|n} φ(n/d) · k^d
    where φ is Euler's totient function.
    """
    from sympy import totient
    total = sum(totient(n // d) * k ** d for d in range(1, n + 1) if n % d == 0)
    return total // n


def fixed_points_shift_power(n: int, m: int) -> int:
    """Number of configurations in {0,1}^n fixed by σ^m.

    A configuration c is fixed by σ^m iff c has period dividing gcd(m, n).
    Number of such configurations = 2^{gcd(m, n)}.
    """
    return 2 ** gcd(m, n)


def main():
    print("=" * 70)
    print("GALOIS THEORY OF CELLULAR AUTOMATA: REVERSIBILITY GROUPS")
    print("=" * 70)

    # 1. Find reversible elementary CA rules
    print("\n1. REVERSIBLE ELEMENTARY CA RULES")
    print("-" * 40)
    rev_rules = find_reversible_rules(n=5)
    print(f"   Reversible rules (tested on period 5): {rev_rules}")
    print(f"   Count: {len(rev_rules)} out of 256")

    # Describe each reversible rule
    rule_descriptions = {
        15: "NOT(left neighbor) — right shift + complement",
        51: "NOT(center) — complement/negation",
        85: "NOT(right neighbor) — left shift + complement",
        170: "Right neighbor — left shift",
        204: "Center — identity",
        240: "Left neighbor — right shift",
    }
    for r in rev_rules:
        desc = rule_descriptions.get(r, "unknown")
        print(f"   Rule {r:3d}: {desc}")

    # 2. Shift cycle type and centralizer
    print("\n2. SHIFT CYCLE TYPE AND CENTRALIZER ORDER")
    print("-" * 40)
    for n in range(2, 8):
        ct = shift_cycle_type(n)
        co = centralizer_order(ct)
        full_sym = factorial(2**n)
        ratio = co / full_sym
        print(f"   n={n}: cycle type = {dict(sorted(ct.items()))}")
        print(f"         |centralizer| = {co}")
        print(f"         |S_{{{2**n}}}| = {full_sym}")
        print(f"         ratio = {ratio:.2e}")

    # 3. Fixed-point formula verification
    print("\n3. FIXED-POINT FORMULA: |Fix(σ^m)| = 2^gcd(m,n)")
    print("-" * 40)
    for n in [3, 4, 5, 6]:
        print(f"   n = {n}:")
        configs = list(product([0, 1], repeat=n))
        for m in range(1, n + 1):
            # Count fixed points by brute force
            fixed = 0
            for c in configs:
                shifted = c
                for _ in range(m):
                    shifted = shifted[1:] + (shifted[0],)
                if shifted == c:
                    fixed += 1
            predicted = fixed_points_shift_power(n, m)
            status = "✓" if fixed == predicted else "✗"
            print(f"     m={m}: actual={fixed}, predicted=2^gcd({m},{n})=2^{gcd(m,n)}={predicted} {status}")

    # 4. Necklace counting
    print("\n4. BINARY NECKLACE COUNTS (Burnside's lemma)")
    print("-" * 40)
    for n in range(1, 13):
        try:
            nc = necklace_count(n)
            print(f"   n={n:2d}: {nc} necklaces")
        except ImportError:
            # Fallback without sympy
            fixed_sum = sum(fixed_points_shift_power(n, m) for m in range(1, n + 1))
            nc = fixed_sum // n
            print(f"   n={n:2d}: {nc} necklaces (Burnside)")

    # 5. Reversibility group structure
    print("\n5. REVERSIBILITY GROUP STRUCTURE")
    print("-" * 40)
    print("   The reversibility group RevGroup(G, α) satisfies:")
    print("   • RevGroup = Centralizer of translation action in Sym(α^G)")
    print("   • Sym(α) ≤ RevGroup via pointwise action")
    print("   • G ≤ RevGroup (abelian case) via translation")
    print("   • RevGroup preserves translation orbits (necklaces)")
    print()
    print("   Key theorems proved in Lean 4:")
    print("   • inv_translationEquivariant: F⁻¹ equivariant if F is")
    print("   • mem_revGroup_iff_centralizer: RevGroup = centralizer")
    print("   • revGroup_preserves_orbits: necklace preservation")
    print("   • revGroup_ne_top: proper subgroup for |G|,|α| ≥ 2")
    print("   • revGroup_trivial_group: boundary case G = {e}")
    print("   • translatePerm_mem_revGroup_comm: abelian embedding")
    print("   • translatePerm_injective: G embeds faithfully")
    print("   • pointwiseHom_injective: Sym(α) embeds faithfully")

    # 6. Growth of centralizer vs symmetric group
    print("\n6. GROWTH COMPARISON: |RevGroup| vs |Sym(α^G)|")
    print("-" * 40)
    print(f"   {'n':>3} {'|RevGroup| ≥':>15} {'|Sym(2^n)|':>20} {'log ratio':>12}")
    for n in range(1, 9):
        ct = shift_cycle_type(n)
        co = centralizer_order(ct)
        full = factorial(2**n)
        import math
        log_ratio = math.log10(co) - math.log10(full) if co > 0 and full > 0 else float('-inf')
        print(f"   {n:3d} {co:15d} {full:20d} {log_ratio:12.1f}")

    print("\n" + "=" * 70)
    print("The centralizer grows, but much slower than the full symmetric group.")
    print("This proves the reversibility group is an exponentially thin slice")
    print("of all possible permutations — only a vanishing fraction of")
    print("transformations respect the translational symmetry of the lattice.")
    print("=" * 70)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Centralizer Order Growth vs Symmetric Group

Shows the exponential gap between |RevGroup| and |Sym(α^G)| as |G| grows.
"""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from math import factorial, gcd, log10
from itertools import product
from collections import Counter


def shift_cycle_type(n):
    configs = list(product([0, 1], repeat=n))
    config_idx = {c: i for i, c in enumerate(configs)}
    visited = [False] * len(configs)
    cycles = []
    for i in range(len(configs)):
        if visited[i]:
            continue
        length = 0
        j = i
        while not visited[j]:
            visited[j] = True
            length += 1
            shifted = configs[j][1:] + (configs[j][0],)
            j = config_idx[shifted]
        cycles.append(length)
    return dict(Counter(cycles))


def centralizer_order(ct):
    result = 1
    for k, a_k in ct.items():
        result *= factorial(a_k) * (k ** a_k)
    return result


def main():
    ns = list(range(1, 11))
    log_cent = []
    log_sym = []
    log_lower = []

    for n in ns:
        ct = shift_cycle_type(n)
        co = centralizer_order(ct)
        sym = factorial(2**n)
        lower = n * factorial(2)  # |G| * |α|! = n * 2

        log_cent.append(log10(co) if co > 0 else 0)
        log_sym.append(log10(sym) if sym > 0 else 0)
        log_lower.append(log10(lower) if lower > 0 else 0)

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    # Plot 1: Log scale comparison
    ax1.plot(ns, log_sym, 'r-o', linewidth=2, markersize=8, label=r'$\log_{10}|S_{2^n}|$')
    ax1.plot(ns, log_cent, 'b-s', linewidth=2, markersize=8, label=r'$\log_{10}|C_{S_{2^n}}(\sigma)|$')
    ax1.plot(ns, log_lower, 'g--^', linewidth=2, markersize=8, label=r'$\log_{10}(n \cdot 2!)$')
    ax1.fill_between(ns, log_lower, log_cent, alpha=0.15, color='blue', label='RevGroup range')
    ax1.set_xlabel('Period n', fontsize=14)
    ax1.set_ylabel(r'$\log_{10}$(group order)', fontsize=14)
    ax1.set_title('Reversibility Group vs Full Symmetric Group', fontsize=14)
    ax1.legend(fontsize=11)
    ax1.grid(True, alpha=0.3)

    # Plot 2: Ratio
    ratios = [log_cent[i] / log_sym[i] if log_sym[i] > 0 else 1 for i in range(len(ns))]
    ax2.plot(ns, ratios, 'purple', linewidth=2, marker='D', markersize=8)
    ax2.set_xlabel('Period n', fontsize=14)
    ax2.set_ylabel(r'$\log|C|/\log|S|$', fontsize=14)
    ax2.set_title('Ratio of Log-Orders (→ 0 as n → ∞)', fontsize=14)
    ax2.set_ylim(0, 1.05)
    ax2.axhline(y=0, color='red', linestyle='--', alpha=0.5)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('/workspace/request-project/Applications/centralizer_growth.png', dpi=150, bbox_inches='tight')
    print("Saved centralizer_growth.png")


if __name__ == "__main__":
    main()
