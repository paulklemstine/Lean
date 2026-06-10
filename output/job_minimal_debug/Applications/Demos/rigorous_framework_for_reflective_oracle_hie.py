#!/usr/bin/env python3
"""
Oracle Closure Algebras — Interactive Demo

Demonstrates the key results:
1. Non-idempotence of oracle closure
2. Strict descent of incompleteness kernels
3. Diagonal antichain of consistency sentences
4. Hierarchy collapse impossibility
5. Unbounded diagonal resistance
"""

from algorithms import OracleHierarchy, compute_kernel_descent, verify_non_idempotence


def main():
    H = OracleHierarchy()

    print("╔════════════════════════════════════════════════════════════╗")
    print("║     Oracle Closure Algebras — Demonstration               ║")
    print("╚════════════════════════════════════════════════════════════╝")
    print()

    # === Demo 1: Non-idempotence ===
    print("━━━ Demo 1: Non-Idempotence of Oracle Closure ━━━")
    print()
    print("The oracle closure operator Cl(n, k) = Prov(n+k) is NOT idempotent:")
    print("applying one more jump always gives strictly more provable sentences.")
    print()
    for n in range(6):
        cl1 = H.oracle_closure(n, 1, max_sentence=40)
        cl2 = H.oracle_closure(n, 2, max_sentence=40)
        diff = cl2 - cl1
        print(f"  Cl({n}, 1) has {len(cl1)} sentences, Cl({n}, 2) has {len(cl2)}")
        print(f"    New in Cl({n}, 2): {sorted(diff)}")
        print(f"    This is Con({n+1}) = {H.con_sentence(n+1)}")
    print()

    # === Demo 2: Kernel Descent ===
    print("━━━ Demo 2: Strict Descent of Incompleteness Kernels ━━━")
    print()
    print("K(n) = {φ : True_(φ) ∧ ¬Provable(n, φ)} decreases strictly:")
    print()
    max_s = 30
    for n in range(8):
        kernel = H.incompleteness_kernel(n, max_s)
        print(f"  K({n}) = {sorted(kernel)}")
        print(f"    |K({n})| = {len(kernel)}")
        if n > 0:
            prev_kernel = H.incompleteness_kernel(n - 1, max_s)
            exited = prev_kernel - kernel
            print(f"    Exited kernel: {sorted(exited)} (= Con({n-1}) = {H.con_sentence(n-1)})")
    print()

    # === Demo 3: Diagonal Antichain ===
    print("━━━ Demo 3: Diagonal Antichain of Consistency Sentences ━━━")
    print()
    print("Con(m) and Con(n) are incomparable in resolvability for m ≠ n:")
    print()
    for m in range(5):
        for n in range(m + 1, 5):
            le_mn = H.resolvability_le(H.con_sentence(m), H.con_sentence(n))
            le_nm = H.resolvability_le(H.con_sentence(n), H.con_sentence(m))
            both = le_mn and le_nm
            print(f"  Con({m}) vs Con({n}): "
                  f"Con({m})≤Con({n})={le_mn}, Con({n})≤Con({m})={le_nm}, "
                  f"comparable={both}")
    print()

    # === Demo 4: Hierarchy Collapse ===
    print("━━━ Demo 4: Hierarchy Collapse Impossibility ━━━")
    print()
    print("No finite Cl(n, k) equals the union Prov(ω):")
    print()
    max_s = 50
    union_size = sum(1 for s in range(max_s) if H.is_true(s))
    print(f"  |Prov(ω) ∩ [0, {max_s})| = {union_size} (all odd numbers)")
    for n in range(4):
        for k in range(4):
            cl = H.oracle_closure(n, k, max_s)
            print(f"  |Cl({n}, {k})| = {len(cl)}  (gap = {union_size - len(cl)})")
    print()

    # === Demo 5: Diagonal Resistance ===
    print("━━━ Demo 5: Unbounded Diagonal Resistance ━━━")
    print()
    print("The diagonal resistance of Con(n) is exactly n+1:")
    print()
    for n in range(10):
        s = H.con_sentence(n)
        r = H.diagonal_resistance(s)
        print(f"  Con({n}) = {s:3d}, resistance = {r:3d}, "
              f"first provable at level {r}")
    print()
    print("No finite bound suffices: resistance grows without bound!")
    print()

    # === Summary ===
    print("━━━ Summary ━━━")
    print()
    print("The oracle hierarchy exhibits a fundamental asymmetry:")
    print("  • Consistency is one-step resolvable (Σ₁)")
    print("  • Completeness is permanently unresolvable (Π₂)")
    print()
    print("Algebraically:")
    print("  • Oracle closure is extensive and monotone ✓")
    print("  • Oracle closure is NOT idempotent ✗ (= Gödel's theorem!)")
    print()
    print("The incompleteness kernels K(n) form a strictly decreasing chain,")
    print("and the consistency sentences form an antichain in resolvability.")
    print("No finite extension can collapse the hierarchy.")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Oracle Hierarchy Structure

Generates a matplotlib visualization showing:
1. The strict descent of incompleteness kernels
2. The strictly increasing oracle closure chain
3. Diagonal resistance as a function of sentence index
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def oracle_con_sentence(k: int) -> int:
    return 2 * k + 1


def is_provable(n: int, s: int) -> bool:
    if s % 2 == 0:
        return False
    k = (s - 1) // 2
    return k < n


def is_true(s: int) -> bool:
    return s % 2 == 1


def incompleteness_kernel_size(n: int, max_s: int) -> int:
    return sum(1 for s in range(max_s) if is_true(s) and not is_provable(n, s))


def oracle_closure_size(n: int, k: int, max_s: int) -> int:
    return sum(1 for s in range(max_s) if is_provable(n + k, s))


def diagonal_resistance(s: int) -> int:
    if not is_true(s):
        return -1
    k = (s - 1) // 2
    return k + 1


def main():
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    fig.suptitle("Oracle Closure Algebras: Structure of the Hierarchy",
                 fontsize=16, fontweight='bold')

    max_s = 50
    max_level = 15

    # Plot 1: Kernel descent
    ax1 = axes[0, 0]
    levels = list(range(max_level))
    kernel_sizes = [incompleteness_kernel_size(n, max_s) for n in levels]
    ax1.bar(levels, kernel_sizes, color='steelblue', alpha=0.8, edgecolor='navy')
    ax1.set_xlabel('Level n')
    ax1.set_ylabel('|K(n)|')
    ax1.set_title('Incompleteness Kernel Descent')
    ax1.annotate('K(n) ⊋ K(n+1) for all n',
                 xy=(max_level // 2, max(kernel_sizes) * 0.7),
                 fontsize=10, ha='center', style='italic')

    # Plot 2: Closure chain
    ax2 = axes[0, 1]
    max_depth = 15
    depths = list(range(max_depth))
    closure_sizes = [oracle_closure_size(0, k, max_s) for k in depths]
    ax2.plot(depths, closure_sizes, 'o-', color='darkred', markersize=6,
             linewidth=2)
    ax2.fill_between(depths, closure_sizes, alpha=0.2, color='red')
    union_size = sum(1 for s in range(max_s) if is_true(s))
    ax2.axhline(y=union_size, color='green', linestyle='--', linewidth=2,
                label=f'Prov(ω) = {union_size}')
    ax2.set_xlabel('Depth k')
    ax2.set_ylabel('|Cl(0, k)|')
    ax2.set_title('Oracle Closure Growth (from level 0)')
    ax2.legend()
    ax2.annotate('Never reaches Prov(ω)!',
                 xy=(max_depth * 0.6, union_size - 2),
                 fontsize=10, ha='center', color='green', fontweight='bold')

    # Plot 3: Diagonal resistance
    ax3 = axes[1, 0]
    sentences = [oracle_con_sentence(k) for k in range(15)]
    resistances = [diagonal_resistance(s) for s in sentences]
    colors = plt.cm.viridis(np.linspace(0.2, 0.9, len(sentences)))
    ax3.bar(range(len(sentences)), resistances, color=colors,
            edgecolor='black', linewidth=0.5)
    ax3.set_xlabel('k (index of Con(k))')
    ax3.set_ylabel('Diagonal Resistance')
    ax3.set_title('Resistance of Con(k) = k + 1')
    ax3.plot(range(len(sentences)), [k + 1 for k in range(len(sentences))],
             'r--', linewidth=2, label='y = k + 1')
    ax3.legend()

    # Plot 4: Resolvability antichain visualization
    ax4 = axes[1, 1]
    n_cons = 8
    for k in range(n_cons):
        con = oracle_con_sentence(k)
        first_level = k + 1
        # Draw horizontal line from first_level to max_level
        ax4.plot([first_level, max_level], [k, k], 'o-',
                 color=plt.cm.Set1(k / n_cons), linewidth=3,
                 markersize=8, label=f'Con({k})')
        # Draw X marks for unprovable levels
        for lvl in range(first_level):
            ax4.plot(lvl, k, 'x', color='red', markersize=10, markeredgewidth=2)

    ax4.set_xlabel('Level n')
    ax4.set_ylabel('Consistency sentence index k')
    ax4.set_title('Antichain: Provability Patterns')
    ax4.legend(loc='lower right', fontsize=7, ncol=2)
    ax4.set_xlim(-0.5, max_level)
    # Add annotations
    red_x = mpatches.Patch(color='red', label='Not provable (✗)')
    green_line = mpatches.Patch(color='steelblue', label='Provable (●—)')

    plt.tight_layout()
    plt.savefig('oracle_hierarchy_structure.png', dpi=150, bbox_inches='tight')
    plt.savefig('oracle_hierarchy_structure.pdf', bbox_inches='tight')
    print("Saved: oracle_hierarchy_structure.png, oracle_hierarchy_structure.pdf")


if __name__ == "__main__":
    main()
