#!/usr/bin/env python3
"""
Demonstration of the Transfinite Oracle Hierarchy framework.

This script illustrates the key concepts from the formalization:
- Jump operators and oracle chains
- Diagonal escape
- Information gaps
- Essential-accidental gap
- Cardinality barriers
"""

from typing import Set, Callable, List, Tuple


def diagonal_jump(S: Set[int], universe_size: int = 100) -> Set[int]:
    """
    A concrete jump operator: adds the smallest element of the complement.
    This satisfies both expansion (S ⊆ J(S)) and nontriviality (∃x ∈ J(S) \ S).
    """
    result = set(S)
    for i in range(universe_size):
        if i not in S:
            result.add(i)
            return result
    # Fallback: add universe_size itself
    result.add(universe_size)
    return result


def enriched_jump(S: Set[int], universe_size: int = 1000) -> Set[int]:
    """
    A richer jump operator: adds the first k elements not in S,
    where k = |S| + 1. This models a jump that becomes more powerful
    as the base set grows.
    """
    result = set(S)
    to_add = len(S) + 1
    added = 0
    for i in range(universe_size):
        if i not in S:
            result.add(i)
            added += 1
            if added >= to_add:
                break
    return result


def build_oracle_chain(jump: Callable, base: Set[int], levels: int) -> List[Set[int]]:
    """Build an oracle chain by iterating the jump operator."""
    chain = [set(base)]
    for _ in range(levels):
        chain.append(jump(chain[-1]))
    return chain


def compute_information_gaps(chain: List[Set[int]]) -> List[Set[int]]:
    """Compute the information gap at each level."""
    gaps = []
    for i in range(len(chain) - 1):
        gap = chain[i + 1] - chain[i]
        gaps.append(gap)
    return gaps


def demonstrate_diagonal_escape():
    """
    Demonstrate the diagonal escape theorem:
    No decision procedure at level n can decide level n+1.
    """
    print("=" * 60)
    print("DIAGONAL ESCAPE DEMONSTRATION")
    print("=" * 60)
    
    chain = build_oracle_chain(diagonal_jump, set(), 10)
    
    for n in range(min(8, len(chain) - 1)):
        level_n = chain[n]
        level_n1 = chain[n + 1]
        
        # A "decision procedure" for level n
        def decide_n(x: int, level=level_n) -> bool:
            return x in level
        
        # Find where it fails on level n+1
        new_elements = level_n1 - level_n
        if new_elements:
            witness = min(new_elements)
            correct_at_n = decide_n(witness)
            should_be_at_n1 = witness in level_n1
            print(f"Level {n}: |S| = {len(level_n):3d}, "
                  f"Level {n+1}: |S| = {len(level_n1):3d}, "
                  f"Gap element: {witness}, "
                  f"decide_n says {'IN' if correct_at_n else 'OUT'}, "
                  f"actually {'IN' if should_be_at_n1 else 'OUT'} at level {n+1}")
    print()


def demonstrate_information_gaps():
    """Demonstrate that information gaps are always nonempty and growing."""
    print("=" * 60)
    print("INFORMATION GAP ANALYSIS")
    print("=" * 60)
    
    # Diagonal jump
    chain_diag = build_oracle_chain(diagonal_jump, set(), 20)
    gaps_diag = compute_information_gaps(chain_diag)
    
    print("\nDiagonal Jump (adds 1 element per level):")
    for i, gap in enumerate(gaps_diag):
        print(f"  Gap({i:2d}): size = {len(gap):3d}, elements = {sorted(gap)[:5]}{'...' if len(gap) > 5 else ''}")
    
    # Enriched jump
    chain_rich = build_oracle_chain(enriched_jump, set(), 10)
    gaps_rich = compute_information_gaps(chain_rich)
    
    print("\nEnriched Jump (adds |S|+1 elements per level):")
    for i, gap in enumerate(gaps_rich):
        print(f"  Gap({i:2d}): size = {len(gap):3d}, elements = {sorted(gap)[:8]}{'...' if len(gap) > 8 else ''}")
    
    # Verify gaps are always nonempty (theorem: information_gap_nonempty)
    all_nonempty = all(len(g) > 0 for g in gaps_diag + gaps_rich)
    print(f"\nAll gaps nonempty: {all_nonempty} ✓")
    print()


def demonstrate_essential_accidental_gap():
    """
    Demonstrate the essential-accidental gap:
    A function can agree with some computable function at every point
    without being equal to any single computable function.
    """
    print("=" * 60)
    print("ESSENTIAL-ACCIDENTAL GAP")
    print("=" * 60)
    
    N = 20  # universe size
    
    # Family of "computable" functions: φ_n(x) = (n + x) % 2
    def computable(n: int, x: int) -> bool:
        return (n + x) % 2 == 0
    
    # The diagonal function: f(x) = NOT computable(x, x)
    def f(x: int) -> bool:
        return not computable(x, x)
    
    print(f"\nFamily: φ_n(x) = ((n + x) % 2 == 0)")
    print(f"Diagonal: f(x) = ¬φ_x(x)")
    print()
    
    # Show f is not essentially computable
    print("f is NOT essentially computable:")
    for n in range(min(10, N)):
        matches = all(computable(n, x) == f(x) for x in range(N))
        if not matches:
            # Find first disagreement
            for x in range(N):
                if computable(n, x) != f(x):
                    print(f"  φ_{n} ≠ f: disagree at x={x} "
                          f"(φ_{n}({x})={computable(n, x)}, f({x})={f(x)})")
                    break
    
    # Show f is accidentally correct everywhere
    print(f"\nf IS accidentally correct at every point:")
    for x in range(min(15, N)):
        target = f(x)
        for n in range(N * 2):
            if computable(n, x) == target:
                print(f"  x={x:2d}: f(x)={target}, matched by φ_{n}({x})={computable(n, x)}")
                break
    print()


def demonstrate_uncountability():
    """
    Demonstrate that the oracle space is uncountable via Cantor's diagonal.
    """
    print("=" * 60)
    print("CANTOR'S DIAGONAL (ORACLE SPACE UNCOUNTABLE)")
    print("=" * 60)
    
    # Any attempted enumeration of functions ℕ → Bool
    # We show the diagonal function differs from every enumerated function
    
    N = 12  # finite approximation
    
    # Attempted enumeration: enum(n) = binary representation of n, padded
    def enum(n: int, x: int) -> bool:
        return bool((n >> x) & 1)
    
    # Diagonal function
    def diag(x: int) -> bool:
        return not enum(x, x)
    
    print(f"\nEnumeration: enum(n, x) = bit x of n")
    print(f"Diagonal:    d(x) = ¬enum(x, x)")
    print()
    
    print("Showing d ≠ enum(n) for each n:")
    for n in range(N):
        enum_at_n = enum(n, n)
        diag_at_n = diag(n)
        print(f"  n={n:2d}: enum({n},{n})={int(enum_at_n)}, d({n})={int(diag_at_n)} → differ at position {n}")
    
    print(f"\nNo finite enumeration can capture all oracles. ✓")
    print()


def demonstrate_convergence():
    """Demonstrate the unbounded convergence principle."""
    print("=" * 60)
    print("UNBOUNDED CONVERGENCE PRINCIPLE")
    print("=" * 60)
    
    # Target: the characteristic function of even numbers
    def target(x: int) -> bool:
        return x % 2 == 0
    
    # Stages: at stage N, correct on [0, N) but wrong at N
    def stage(N: int, x: int) -> bool:
        if x < N:
            return target(x)
        else:
            return not target(x)  # deliberately wrong beyond N
    
    print(f"\nTarget: f(x) = (x is even)")
    print(f"Stage N: correct on [0,N), wrong at x=N")
    print()
    
    for N in [1, 5, 10, 50, 100]:
        # Count errors in [0, 200]
        errors = sum(1 for x in range(200) if stage(N, x) != target(x))
        first_error = next(x for x in range(200) if stage(N, x) != target(x))
        print(f"  Stage {N:3d}: first error at x={first_error:3d}, "
              f"total errors in [0,200) = {errors}")
    
    print(f"\nNo single stage is universally correct. ✓")
    print(f"For every N, there exists x where stage N errs. ✓")
    print()


if __name__ == "__main__":
    demonstrate_diagonal_escape()
    demonstrate_information_gaps()
    demonstrate_essential_accidental_gap()
    demonstrate_uncountability()
    demonstrate_convergence()
    
    print("=" * 60)
    print("ALL DEMONSTRATIONS COMPLETE")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization of the Unbounded Convergence Principle for physical hypercomputers.
"""

import matplotlib.pyplot as plt
import numpy as np


def plot_convergence():
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    fig.suptitle("Unbounded Convergence Principle", fontsize=16, fontweight='bold')
    
    # Target function: characteristic of primes
    def is_prime(n: int) -> bool:
        if n < 2:
            return False
        for i in range(2, int(n**0.5) + 1):
            if n % i == 0:
                return False
        return True
    
    N_max = 100
    target = [is_prime(x) for x in range(N_max)]
    
    # Stages: stage N is correct on [0, N), uses a bad heuristic beyond
    def stage(N: int, x: int) -> bool:
        if x < N:
            return is_prime(x)
        else:
            # Bad heuristic: "odd numbers > 1 are prime"
            return x > 1 and x % 2 == 1
    
    # Plot 1: Error profile across stages
    ax1 = axes[0]
    stages_to_show = [5, 10, 20, 40, 60, 80]
    
    for i, N_stage in enumerate(stages_to_show):
        errors = []
        for x in range(N_max):
            errors.append(0 if stage(N_stage, x) == target[x] else 1)
        
        y_offset = i * 1.5
        color = plt.cm.coolwarm(i / len(stages_to_show))
        
        for x in range(N_max):
            if errors[x]:
                ax1.plot(x, y_offset, 's', color='red', markersize=2, alpha=0.7)
            else:
                ax1.plot(x, y_offset, 's', color='green', markersize=1, alpha=0.3)
        
        ax1.text(-5, y_offset, f"Stage {N_stage}", ha='right', va='center', fontsize=8)
        # Mark the boundary
        ax1.axvline(x=N_stage, ymin=(y_offset - 0.3) / (len(stages_to_show) * 1.5),
                    ymax=(y_offset + 0.3) / (len(stages_to_show) * 1.5),
                    color='blue', linewidth=1, alpha=0.5)
    
    ax1.set_xlabel('Input x')
    ax1.set_title('Error Profile at Each Stage\n(red = error, green = correct)')
    ax1.set_yticks([])
    ax1.set_xlim(-10, N_max)
    
    # Plot 2: First error position vs stage number
    ax2 = axes[1]
    
    stage_numbers = list(range(1, 80))
    first_errors = []
    total_errors = []
    
    for N in stage_numbers:
        first_err = None
        err_count = 0
        for x in range(N_max):
            if stage(N, x) != target[x]:
                if first_err is None:
                    first_err = x
                err_count += 1
        first_errors.append(first_err if first_err is not None else N_max)
        total_errors.append(err_count)
    
    ax2_twin = ax2.twinx()
    
    l1 = ax2.plot(stage_numbers, first_errors, 'b-', linewidth=2, label='First error position')
    l2 = ax2_twin.plot(stage_numbers, total_errors, 'r--', linewidth=1.5, alpha=0.7, label='Total errors in [0,100)')
    
    # The key insight: first error always exists but moves further out
    ax2.fill_between(stage_numbers, first_errors, N_max, alpha=0.1, color='red')
    ax2.plot(stage_numbers, stage_numbers, 'k:', alpha=0.3, label='y = N (boundary)')
    
    ax2.set_xlabel('Stage N')
    ax2.set_ylabel('First error position', color='blue')
    ax2_twin.set_ylabel('Total errors', color='red')
    ax2.set_title('Unbounded Convergence:\nFirst error → ∞ but never disappears')
    
    lines = l1 + l2
    labels = [l.get_label() for l in lines]
    ax2.legend(lines, labels, fontsize=8, loc='upper left')
    ax2.grid(True, alpha=0.3)
    
    # Add annotation
    ax2.annotate('No stage N makes\nALL errors vanish',
                xy=(50, 50), fontsize=10, style='italic',
                bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8),
                ha='center')
    
    plt.tight_layout()
    plt.savefig('convergence_principle.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: convergence_principle.png")


if __name__ == "__main__":
    plot_convergence()


#!/usr/bin/env python3
"""
Visualization of Cantor's diagonal argument and the essential-accidental gap.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def plot_diagonal_and_gap():
    fig, axes = plt.subplots(1, 2, figsize=(16, 7))
    fig.suptitle("Diagonal Arguments in Oracle Theory", fontsize=16, fontweight='bold')
    
    # Plot 1: Cantor's diagonal
    ax1 = axes[0]
    N = 12
    
    # Enumeration: enum(n, x) = bit x of n
    matrix = np.zeros((N, N), dtype=int)
    for n in range(N):
        for x in range(N):
            matrix[n, x] = (n >> x) & 1
    
    # Diagonal
    diagonal = np.array([1 - matrix[i, i] for i in range(N)])
    
    # Plot the matrix
    im = ax1.imshow(matrix, cmap='Blues', aspect='auto', interpolation='nearest')
    
    # Highlight the diagonal
    for i in range(N):
        color = 'red' if matrix[i, i] == 1 else 'darkred'
        rect = mpatches.FancyBboxPatch((i - 0.4, i - 0.4), 0.8, 0.8,
                                        boxstyle="round,pad=0.05",
                                        facecolor='red', alpha=0.4, edgecolor='red', linewidth=2)
        ax1.add_patch(rect)
        ax1.text(i, i, str(matrix[i, i]), ha='center', va='center', fontsize=8, fontweight='bold', color='red')
    
    # Show diagonal function values on the right
    for i in range(N):
        ax1.text(N + 0.3, i, f"d({i})={diagonal[i]}", ha='left', va='center', fontsize=7, color='darkred')
    
    ax1.set_xlabel('Position x')
    ax1.set_ylabel('Function index n')
    ax1.set_title("Cantor's Diagonal: d(n) ≠ enum(n,n)")
    ax1.set_xticks(range(N))
    ax1.set_yticks(range(N))
    ax1.set_xlim(-0.5, N + 2)
    
    # Plot 2: Essential-Accidental Gap visualization
    ax2 = axes[1]
    
    # Family: φ_n(x) = (n + x) mod 3 == 0
    M = 15  # number of functions and inputs to show
    family = np.zeros((M, M), dtype=int)
    for n in range(M):
        for x in range(M):
            family[n, x] = 1 if (n + x) % 3 == 0 else 0
    
    # Non-computable function: diagonal
    f_vals = np.array([1 - family[x, x] for x in range(M)])
    
    # For each x, find which n matches
    match_indices = []
    for x in range(M):
        target = f_vals[x]
        found = -1
        for n in range(M * 2):
            val = 1 if (n + x) % 3 == 0 else 0
            if val == target:
                found = n
                break
        match_indices.append(found)
    
    # Plot: show that f agrees with different family members at different points
    colors = plt.cm.Set3(np.linspace(0, 1, M))
    
    x_positions = range(M)
    for x in x_positions:
        n = match_indices[x]
        ax2.bar(x, f_vals[x] * 0.9 + 0.05, color=colors[n % M], edgecolor='black', linewidth=0.5)
        ax2.text(x, -0.15, f"φ_{n}", ha='center', va='top', fontsize=6, rotation=45)
    
    ax2.set_xlabel('Input x')
    ax2.set_ylabel('f(x)')
    ax2.set_title('Essential-Accidental Gap\n(each bar colored by matching φₙ)')
    ax2.set_xticks(range(M))
    ax2.set_ylim(-0.4, 1.3)
    ax2.axhline(y=0, color='gray', linewidth=0.5)
    ax2.axhline(y=1, color='gray', linewidth=0.5)
    
    # Add annotation
    ax2.text(M/2, 1.15, "f matches a DIFFERENT φₙ at each point\nbut equals NO single φₙ globally",
             ha='center', va='bottom', fontsize=9, style='italic',
             bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))
    
    plt.tight_layout()
    plt.savefig('diagonal_analysis.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: diagonal_analysis.png")


if __name__ == "__main__":
    plot_diagonal_and_gap()


#!/usr/bin/env python3
"""
Visualization of the Oracle Hierarchy structure.
Shows the strict hierarchy, information gaps, and gap growth patterns.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from typing import Set, FrozenSet, List, Callable


def diagonal_jump(S: FrozenSet[int], universe: int = 10000) -> FrozenSet[int]:
    for i in range(universe):
        if i not in S:
            return S | frozenset({i})
    return S | frozenset({universe})


def enriched_jump(S: FrozenSet[int], universe: int = 10000) -> FrozenSet[int]:
    to_add = len(S) + 1
    new_elements: set = set()
    for i in range(universe):
        if i not in S:
            new_elements.add(i)
            if len(new_elements) >= to_add:
                break
    return S | frozenset(new_elements)


def doubling_jump(S: FrozenSet[int], universe: int = 10000) -> FrozenSet[int]:
    target_size = max(len(S) * 2, len(S) + 1)
    result = set(S)
    for i in range(universe):
        if i not in result:
            result.add(i)
            if len(result) >= target_size:
                break
    return frozenset(result)


def build_chain(jump_fn: Callable, levels: int) -> List[FrozenSet[int]]:
    chain = [frozenset[int]()]
    for _ in range(levels):
        chain.append(jump_fn(chain[-1]))
    return chain


def plot_hierarchy():
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    fig.suptitle("Transfinite Oracle Hierarchy Analysis", fontsize=16, fontweight='bold')
    
    jumps = {
        'Diagonal (minimal)': diagonal_jump,
        'Enriched (|S|+1)': enriched_jump,
        'Doubling (2|S|)': doubling_jump,
    }
    
    # Plot 1: Set sizes across levels
    ax1 = axes[0, 0]
    for name, jump_fn in jumps.items():
        chain = build_chain(jump_fn, 15)
        sizes = [len(s) for s in chain]
        ax1.plot(range(len(sizes)), sizes, 'o-', label=name, markersize=4)
    ax1.set_xlabel('Level n')
    ax1.set_ylabel('|Level n|')
    ax1.set_title('Oracle Chain Growth')
    ax1.legend(fontsize=8)
    ax1.set_yscale('log')
    ax1.grid(True, alpha=0.3)
    
    # Plot 2: Information gap sizes
    ax2 = axes[0, 1]
    for name, jump_fn in jumps.items():
        chain = build_chain(jump_fn, 15)
        gaps = [len(chain[i+1] - chain[i]) for i in range(len(chain)-1)]
        ax2.plot(range(len(gaps)), gaps, 's-', label=name, markersize=4)
    ax2.set_xlabel('Level n')
    ax2.set_ylabel('|Gap(n)|')
    ax2.set_title('Information Gap Size')
    ax2.legend(fontsize=8)
    ax2.grid(True, alpha=0.3)
    
    # Plot 3: Visualization of the enriched hierarchy as nested sets
    ax3 = axes[1, 0]
    chain = build_chain(enriched_jump, 8)
    colors = plt.cm.viridis(np.linspace(0.2, 0.9, len(chain)))
    for i, level in enumerate(reversed(chain)):
        idx = len(chain) - 1 - i
        elements = sorted(level)
        if elements:
            ax3.barh(idx, len(elements), color=colors[idx], alpha=0.7, edgecolor='black', linewidth=0.5)
            # Mark the gap elements
            if idx > 0:
                gap = level - chain[idx - 1]
                ax3.barh(idx, len(gap), left=len(chain[idx-1]), color='red', alpha=0.4)
    ax3.set_ylabel('Level n')
    ax3.set_xlabel('Number of elements')
    ax3.set_title('Oracle Levels (red = gap)')
    ax3.grid(True, alpha=0.3, axis='x')
    
    # Plot 4: Gap ratio (Gap(n+1)/Gap(n)) — tests the gap growth conjecture
    ax4 = axes[1, 1]
    for name, jump_fn in jumps.items():
        chain = build_chain(jump_fn, 15)
        gaps = [len(chain[i+1] - chain[i]) for i in range(len(chain)-1)]
        ratios = [gaps[i+1] / gaps[i] if gaps[i] > 0 else 0 for i in range(len(gaps)-1)]
        ax4.plot(range(len(ratios)), ratios, 'd-', label=name, markersize=4)
    ax4.axhline(y=1.0, color='gray', linestyle='--', alpha=0.5, label='Ratio = 1')
    ax4.set_xlabel('Level n')
    ax4.set_ylabel('Gap(n+1) / Gap(n)')
    ax4.set_title('Gap Growth Ratio (Conjecture Test)')
    ax4.legend(fontsize=8)
    ax4.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('oracle_hierarchy.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: oracle_hierarchy.png")


if __name__ == "__main__":
    plot_hierarchy()
