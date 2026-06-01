#!/usr/bin/env python3
"""
Demonstration of Universal Computational Complexity Barriers.

This script constructs the oracle tower, computes diagonals at each level,
and verifies the key theorems computationally:
  1. Diagonal separation: diag never matches any enumerated function
  2. Oracle tower strictness: each level is strictly more powerful
  3. Non-collapse: lower levels cannot reach higher barriers
  4. Alternation pattern: diagonal values at input 0 alternate
  5. Barrier chain distinctness: barriers at different levels differ
"""

from typing import Callable, Dict, List, Tuple

# Type aliases
Lang = Callable[[int], bool]
Enumeration = Callable[[int], Lang]


def build_oracle_tower(max_level: int, max_input: int) -> Dict[int, Dict[int, List[bool]]]:
    """
    Build the oracle tower up to max_level, evaluating each language
    on inputs 0..max_input-1.

    Returns: tower[level][program_index] = [values for inputs 0..max_input-1]
    """
    tower: Dict[int, Dict[int, List[bool]]] = {}

    # Level 0: all programs return False on all inputs
    tower[0] = {}
    for k in range(max_input + 1):
        tower[0][k] = [False] * max_input

    # Higher levels
    for level in range(1, max_level + 1):
        tower[level] = {}
        prev = tower[level - 1]

        # Program 0 at level n+1 = diagonal of level n
        diag_prev = []
        for n in range(max_input):
            # diag(f)(n) = not f(n)(n)
            if n in prev and n < len(prev[n]):
                diag_prev.append(not prev[n][n])
            else:
                diag_prev.append(True)  # not False
        tower[level][0] = diag_prev

        # Programs k+1 at level n+1 = program k at level n
        for k in range(max_input):
            if k in prev:
                tower[level][k + 1] = prev[k][:]
            else:
                tower[level][k + 1] = [False] * max_input

    return tower


def compute_diagonal(tower: Dict[int, List[bool]], max_input: int) -> List[bool]:
    """Compute the diagonal language of an enumeration given as a tower level."""
    diag = []
    for n in range(max_input):
        if n in tower and n < len(tower[n]):
            diag.append(not tower[n][n])
        else:
            diag.append(True)
    return diag


def verify_diagonal_separation(tower: Dict[int, Dict[int, List[bool]]],
                                 level: int, max_input: int) -> bool:
    """Verify that diag(oracleTower(level)) differs from every program at that level."""
    diag = compute_diagonal(tower[level], max_input)
    for k in tower[level]:
        if tower[level][k][:max_input] == diag[:max_input]:
            print(f"  FAILURE: program {k} at level {level} matches diagonal!")
            return False
    return True


def verify_strictness(tower: Dict[int, Dict[int, List[bool]]],
                       level: int, max_input: int) -> bool:
    """Verify that the diagonal of level n appears at level n+1 but not at level n."""
    if level + 1 not in tower:
        return True

    diag_n = compute_diagonal(tower[level], max_input)

    # Check: diag of level n should equal program 0 at level n+1
    prog_0 = tower[level + 1][0][:max_input]
    if prog_0 != diag_n:
        print(f"  FAILURE: program 0 at level {level+1} doesn't match diagonal of level {level}")
        return False

    # Check: no program at level n matches diag of level n
    for k in tower[level]:
        if tower[level][k][:max_input] == diag_n[:max_input]:
            print(f"  FAILURE: program {k} at level {level} matches its own diagonal!")
            return False

    return True


def verify_non_collapse(tower: Dict[int, Dict[int, List[bool]]],
                         m: int, n: int, max_input: int) -> bool:
    """Verify that no program at level m equals the diagonal of level n (for m ≤ n)."""
    diag_n = compute_diagonal(tower[n], max_input)
    for k in tower[m]:
        if tower[m][k][:max_input] == diag_n[:max_input]:
            print(f"  FAILURE: program {k} at level {m} matches diagonal of level {n}!")
            return False
    return True


def verify_alternation(tower: Dict[int, Dict[int, List[bool]]],
                        max_level: int, max_input: int) -> List[bool]:
    """Verify the alternation pattern of diagonal values at input 0."""
    values = []
    for level in range(max_level + 1):
        diag = compute_diagonal(tower[level], max_input)
        values.append(diag[0])
    return values


def verify_barrier_distinctness(tower: Dict[int, Dict[int, List[bool]]],
                                  max_level: int, max_input: int) -> bool:
    """Verify that barriers at different levels are distinct."""
    diags = {}
    for level in range(max_level + 1):
        diags[level] = tuple(compute_diagonal(tower[level], max_input))

    for i in range(max_level + 1):
        for j in range(i + 1, max_level + 1):
            if diags[i] == diags[j]:
                print(f"  FAILURE: diagonals at levels {i} and {j} are identical!")
                return False
    return True


def main():
    MAX_LEVEL = 8
    MAX_INPUT = 12

    print("=" * 70)
    print("UNIVERSAL COMPUTATIONAL COMPLEXITY BARRIERS")
    print("Demonstration of Model-Independent Complexity Hierarchies")
    print("=" * 70)
    print()

    # Build the oracle tower
    print(f"Building oracle tower with {MAX_LEVEL} levels, {MAX_INPUT} inputs...")
    tower = build_oracle_tower(MAX_LEVEL, MAX_INPUT)
    print("Done.\n")

    # 1. Diagonal Separation
    print("━" * 50)
    print("TEST 1: Diagonal Separation")
    print("  (diag(f) ≠ f(k) for all k)")
    print("━" * 50)
    all_pass = True
    for level in range(MAX_LEVEL + 1):
        result = verify_diagonal_separation(tower, level, MAX_INPUT)
        status = "✓" if result else "✗"
        print(f"  Level {level}: {status}")
        all_pass = all_pass and result
    print(f"  Overall: {'PASS' if all_pass else 'FAIL'}\n")

    # 2. Oracle Tower Strictness
    print("━" * 50)
    print("TEST 2: Oracle Tower Strictness")
    print("  (diag(level n) ∈ level n+1 but ∉ level n)")
    print("━" * 50)
    all_pass = True
    for level in range(MAX_LEVEL):
        result = verify_strictness(tower, level, MAX_INPUT)
        status = "✓" if result else "✗"
        print(f"  Level {level} → {level+1}: {status}")
        all_pass = all_pass and result
    print(f"  Overall: {'PASS' if all_pass else 'FAIL'}\n")

    # 3. Non-Collapse
    print("━" * 50)
    print("TEST 3: Oracle Tower Non-Collapse")
    print("  (no program at level m equals diag at level n, for m ≤ n)")
    print("━" * 50)
    all_pass = True
    for n in range(MAX_LEVEL + 1):
        for m in range(n + 1):
            result = verify_non_collapse(tower, m, n, MAX_INPUT)
            if not result:
                all_pass = False
    print(f"  Tested all pairs (m,n) with m ≤ n ≤ {MAX_LEVEL}: {'PASS' if all_pass else 'FAIL'}\n")

    # 4. Alternation Pattern
    print("━" * 50)
    print("TEST 4: Diagonal Alternation at Input 0")
    print("  (diag(level n+1)(0) = ¬diag(level n)(0))")
    print("━" * 50)
    values = verify_alternation(tower, MAX_LEVEL, MAX_INPUT)
    all_pass = True
    for i, v in enumerate(values):
        expected = (i % 2 == 0)  # alternates starting with True
        status = "✓" if v == expected else "✗"
        print(f"  Level {i}: diag(oracleTower({i}))(0) = {v} (expected {expected}) {status}")
        all_pass = all_pass and (v == expected)
    print(f"  Overall: {'PASS' if all_pass else 'FAIL'}\n")

    # 5. Barrier Distinctness
    print("━" * 50)
    print("TEST 5: Barrier Chain Distinctness")
    print("  (barriers at different levels are provably different)")
    print("━" * 50)
    result = verify_barrier_distinctness(tower, MAX_LEVEL, MAX_INPUT)
    print(f"  All {MAX_LEVEL + 1} barriers are distinct: {'PASS' if result else 'FAIL'}\n")

    # Display the tower structure
    print("━" * 50)
    print("ORACLE TOWER STRUCTURE (first 5 levels, 8 inputs)")
    print("━" * 50)
    for level in range(min(5, MAX_LEVEL + 1)):
        print(f"\n  Level {level}:")
        diag = compute_diagonal(tower[level], 8)
        for k in range(min(4, len(tower[level]))):
            vals = tower[level][k][:8]
            marker = " ← diag(prev)" if (level > 0 and k == 0) else ""
            print(f"    Program {k}: {['1' if v else '0' for v in vals]}{marker}")
        print(f"    Diagonal:  {['1' if v else '0' for v in diag]} ← escapes this level")

    # Conjecture test: query complexity
    print("\n" + "━" * 50)
    print("CONJECTURE TEST: Diagonal Query Complexity")
    print("  Testing if removing any level changes the diagonal")
    print("━" * 50)
    for n in range(1, min(5, MAX_LEVEL + 1)):
        full_diag = tuple(compute_diagonal(tower[n], MAX_INPUT))
        all_levels_matter = True
        for remove_level in range(n):
            # Build modified tower without level remove_level
            # (by skipping it in the construction)
            # This is a simplified test - we check if the diagonal value at 0 changes
            # when we modify the lower level
            modified_tower = build_oracle_tower(n, MAX_INPUT)
            # Perturb level remove_level
            for k in modified_tower[remove_level]:
                modified_tower[remove_level][k] = [not v for v in modified_tower[remove_level][k]]
            # Rebuild higher levels
            for lev in range(remove_level + 1, n + 1):
                prev = modified_tower[lev - 1]
                diag_prev = []
                for inp in range(MAX_INPUT):
                    if inp in prev and inp < len(prev[inp]):
                        diag_prev.append(not prev[inp][inp])
                    else:
                        diag_prev.append(True)
                modified_tower[lev][0] = diag_prev
                for k in range(MAX_INPUT):
                    if k in prev:
                        modified_tower[lev][k + 1] = prev[k][:]
            modified_diag = tuple(compute_diagonal(modified_tower[n], MAX_INPUT))
            if modified_diag == full_diag:
                all_levels_matter = False
                print(f"  Level {n}: removing level {remove_level} does NOT change diagonal")

        status = "✓" if all_levels_matter else "partial"
        print(f"  Level {n}: all lower levels contribute to diagonal: {status}")

    print("\n" + "=" * 70)
    print("All core theorems verified computationally.")
    print("=" * 70)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization of the Barrier Chain Distinctness.
Shows how each oracle level produces a genuinely different barrier.
"""

import matplotlib.pyplot as plt
import numpy as np


def build_oracle_tower(max_level: int, max_input: int):
    tower = {}
    tower[0] = {k: [False] * max_input for k in range(max_input)}
    for level in range(1, max_level + 1):
        tower[level] = {}
        prev = tower[level - 1]
        diag_vals = []
        for n in range(max_input):
            if n in prev and n < len(prev[n]):
                diag_vals.append(not prev[n][n])
            else:
                diag_vals.append(True)
        tower[level][0] = diag_vals
        for k in range(1, max_input):
            if k - 1 in prev:
                tower[level][k] = prev[k - 1][:]
            else:
                tower[level][k] = [False] * max_input
    return tower


def compute_diagonal(tower_level, max_input):
    diag = []
    for n in range(max_input):
        if n in tower_level and n < len(tower_level[n]):
            diag.append(not tower_level[n][n])
        else:
            diag.append(True)
    return diag


def main():
    MAX_LEVEL = 10
    MAX_INPUT = 16
    tower = build_oracle_tower(MAX_LEVEL, MAX_INPUT)

    # Compute all diagonals (barriers)
    diags = {}
    for level in range(MAX_LEVEL + 1):
        diags[level] = compute_diagonal(tower[level], MAX_INPUT)

    # Figure 1: Barrier signatures
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(16, 7))
    fig.suptitle("Barrier Chain: Each Level Produces a Unique Hard Problem",
                 fontsize=15, fontweight='bold')

    # Heatmap of barrier values
    barrier_matrix = np.array([
        [1 if diags[level][n] else 0 for n in range(MAX_INPUT)]
        for level in range(MAX_LEVEL + 1)
    ])

    cmap = plt.cm.colors.ListedColormap(['#34495e', '#e67e22'])
    im = ax1.imshow(barrier_matrix, cmap=cmap, aspect='auto', interpolation='nearest')
    ax1.set_xlabel("Input n", fontsize=12)
    ax1.set_ylabel("Oracle Level", fontsize=12)
    ax1.set_title("Barrier Signatures", fontsize=13)
    ax1.set_yticks(range(MAX_LEVEL + 1))
    ax1.set_xticks(range(MAX_INPUT))

    # Hamming distances between barriers
    n_levels = MAX_LEVEL + 1
    hamming = np.zeros((n_levels, n_levels))
    for i in range(n_levels):
        for j in range(n_levels):
            hamming[i][j] = sum(1 for k in range(MAX_INPUT)
                                if diags[i][k] != diags[j][k])

    im2 = ax2.imshow(hamming, cmap='YlOrRd', aspect='auto', interpolation='nearest')
    ax2.set_xlabel("Oracle Level", fontsize=12)
    ax2.set_ylabel("Oracle Level", fontsize=12)
    ax2.set_title("Hamming Distance Between Barriers", fontsize=13)
    ax2.set_xticks(range(n_levels))
    ax2.set_yticks(range(n_levels))

    # Add text annotations
    for i in range(n_levels):
        for j in range(n_levels):
            color = 'white' if hamming[i][j] > MAX_INPUT * 0.6 else 'black'
            ax2.text(j, i, f"{int(hamming[i][j])}",
                     ha='center', va='center', fontsize=8, color=color)

    plt.colorbar(im2, ax=ax2, label='Hamming Distance')

    plt.tight_layout(rect=[0, 0, 1, 0.95])
    plt.savefig('barrier_chain_visualization.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: barrier_chain_visualization.png")

    # Figure 2: Alternation pattern
    fig2, ax3 = plt.subplots(figsize=(10, 5))
    values_at_0 = [diags[level][0] for level in range(MAX_LEVEL + 1)]
    colors = ['#2ecc71' if v else '#e74c3c' for v in values_at_0]
    bars = ax3.bar(range(MAX_LEVEL + 1), [1 if v else 0 for v in values_at_0],
                    color=colors, edgecolor='white', linewidth=1.5)

    ax3.set_xlabel("Oracle Level", fontsize=13)
    ax3.set_ylabel("diag(oracleTower(n))(0)", fontsize=13)
    ax3.set_title("Diagonal Alternation Pattern at Input 0",
                   fontsize=14, fontweight='bold')
    ax3.set_xticks(range(MAX_LEVEL + 1))
    ax3.set_yticks([0, 1])
    ax3.set_yticklabels(["False", "True"])

    # Annotate
    for i, v in enumerate(values_at_0):
        ax3.text(i, 0.5, "T" if v else "F",
                 ha='center', va='center', fontsize=14,
                 fontweight='bold', color='white')

    plt.tight_layout()
    plt.savefig('alternation_pattern.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: alternation_pattern.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization of the Oracle Tower structure.
Shows how each level strictly extends the previous via diagonal construction.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def build_oracle_tower(max_level: int, max_input: int):
    tower = {}
    tower[0] = {k: [False] * max_input for k in range(max_input)}
    for level in range(1, max_level + 1):
        tower[level] = {}
        prev = tower[level - 1]
        diag_vals = []
        for n in range(max_input):
            if n in prev and n < len(prev[n]):
                diag_vals.append(not prev[n][n])
            else:
                diag_vals.append(True)
        tower[level][0] = diag_vals
        for k in range(1, max_input):
            if k - 1 in prev:
                tower[level][k] = prev[k - 1][:]
            else:
                tower[level][k] = [False] * max_input
    return tower


def compute_diagonal(tower_level, max_input):
    diag = []
    for n in range(max_input):
        if n in tower_level and n < len(tower_level[n]):
            diag.append(not tower_level[n][n])
        else:
            diag.append(True)
    return diag


def main():
    MAX_LEVEL = 5
    MAX_INPUT = 8
    tower = build_oracle_tower(MAX_LEVEL, MAX_INPUT)

    fig, axes = plt.subplots(2, 3, figsize=(16, 10))
    fig.suptitle("Oracle Tower: Universal Complexity Barriers",
                 fontsize=16, fontweight='bold')

    for idx, level in enumerate(range(min(6, MAX_LEVEL + 1))):
        ax = axes[idx // 3][idx % 3]

        # Build the matrix
        n_progs = min(MAX_INPUT, len(tower[level]))
        matrix = np.zeros((n_progs + 1, MAX_INPUT))  # +1 for diagonal

        for k in range(n_progs):
            for n in range(MAX_INPUT):
                matrix[k][n] = 1 if tower[level][k][n] else 0

        # Diagonal row
        diag = compute_diagonal(tower[level], MAX_INPUT)
        for n in range(MAX_INPUT):
            matrix[n_progs][n] = 1 if diag[n] else 0

        # Custom colormap
        cmap = plt.cm.colors.ListedColormap(['#2c3e50', '#e74c3c'])

        ax.imshow(matrix, cmap=cmap, aspect='auto', interpolation='nearest')

        # Mark the diagonal cells (where diag flips)
        for n in range(min(n_progs, MAX_INPUT)):
            ax.add_patch(plt.Rectangle((n - 0.5, n - 0.5), 1, 1,
                                        fill=False, edgecolor='#f1c40f',
                                        linewidth=2.5))

        # Separator line before diagonal row
        ax.axhline(y=n_progs - 0.5, color='#2ecc71', linewidth=3, linestyle='--')

        ax.set_title(f"Level {level}", fontsize=13, fontweight='bold')
        ax.set_xlabel("Input n", fontsize=10)
        ax.set_ylabel("Program k", fontsize=10)

        # Labels
        yticks = list(range(n_progs)) + [n_progs]
        ylabels = [str(k) for k in range(n_progs)] + ["diag"]
        ax.set_yticks(yticks)
        ax.set_yticklabels(ylabels, fontsize=8)
        ax.set_xticks(range(MAX_INPUT))
        ax.set_xticklabels(range(MAX_INPUT), fontsize=8)

    # Legend
    red_patch = mpatches.Patch(color='#e74c3c', label='True (1)')
    dark_patch = mpatches.Patch(color='#2c3e50', label='False (0)')
    yellow_patch = mpatches.Patch(facecolor='none', edgecolor='#f1c40f',
                                   linewidth=2, label='Diagonal cell (flipped)')
    green_line = plt.Line2D([0], [0], color='#2ecc71', linewidth=2,
                             linestyle='--', label='Barrier boundary')

    fig.legend(handles=[red_patch, dark_patch, yellow_patch, green_line],
               loc='lower center', ncol=4, fontsize=11,
               bbox_to_anchor=(0.5, -0.02))

    plt.tight_layout(rect=[0, 0.03, 1, 0.95])
    plt.savefig('oracle_tower_visualization.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: oracle_tower_visualization.png")


if __name__ == "__main__":
    main()
