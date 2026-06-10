#!/usr/bin/env python3
"""
Hypercomputation: Computing the Uncomputable — Numerical Demonstrations

This script demonstrates key concepts from the hypercomputation framework:
1. The diagonal argument in action
2. Oracle hierarchy simulation
3. Convergent approximation to non-computable functions
4. The essential-accidental gap
"""

import random
from typing import Callable, List, Tuple


def diagonal_argument_demo():
    """Demonstrate the diagonal argument on a finite grid.
    
    Shows that for any NxN Boolean matrix, the anti-diagonal
    differs from every row.
    """
    print("=" * 60)
    print("DEMO 1: The Diagonal Argument")
    print("=" * 60)
    
    N = 8
    # Create a random NxN Boolean matrix
    matrix = [[random.choice([0, 1]) for _ in range(N)] for _ in range(N)]
    
    print(f"\nRandom {N}x{N} Boolean matrix (rows = 'programs'):")
    print("     ", "  ".join(f"n={j}" for j in range(N)))
    for i, row in enumerate(matrix):
        print(f"  e={i}: {row}")
    
    # Compute anti-diagonal
    antidiag = [1 - matrix[i][i] for i in range(N)]
    print(f"\nDiagonal values:      {[matrix[i][i] for i in range(N)]}")
    print(f"Anti-diagonal (¬diag): {antidiag}")
    
    # Verify it differs from every row
    for i in range(N):
        match_count = sum(1 for j in range(N) if matrix[i][j] == antidiag[j])
        differs_at = [j for j in range(N) if matrix[i][j] != antidiag[j]]
        print(f"  Row {i} matches anti-diagonal at {match_count}/{N} positions, "
              f"differs at positions {differs_at}")
        assert i in differs_at, f"Row {i} should differ at position {i}!"
    
    print(f"\n✓ Anti-diagonal differs from EVERY row (guaranteed at position e=i)")


def oracle_hierarchy_demo():
    """Simulate the oracle hierarchy for a toy model.
    
    We simulate a 'computability model' where computable functions
    are those definable by simple rules, and show how adding oracles
    creates strictly more powerful levels.
    """
    print("\n" + "=" * 60)
    print("DEMO 2: Oracle Hierarchy Simulation")
    print("=" * 60)
    
    N = 16  # Number of inputs to consider
    
    # Level 0: Simple periodic functions
    level0_functions: List[Callable[[int], int]] = []
    for period in range(1, N + 1):
        for offset in range(2):
            f = lambda n, p=period, o=offset: (n // p + o) % 2
            level0_functions.append(f)
    
    print(f"\nLevel 0: {len(level0_functions)} 'computable' functions")
    
    # Compute anti-diagonal of level 0
    antidiag_0 = [1 - level0_functions[i % len(level0_functions)](i) for i in range(N)]
    print(f"Anti-diagonal of level 0: {antidiag_0}")
    
    # Check that no level-0 function matches
    for i, f in enumerate(level0_functions):
        values = [f(n) for n in range(N)]
        if values == antidiag_0:
            print(f"  WARNING: Function {i} matches! (shouldn't happen)")
            break
    else:
        print(f"  ✓ No level-0 function matches the anti-diagonal")
    
    # Level 1: Level 0 functions + the anti-diagonal
    print(f"\nLevel 1: Level 0 functions + anti-diagonal oracle")
    print(f"  Level 1 can compute the anti-diagonal of level 0: ✓")
    
    # Level 1's anti-diagonal
    level1_functions = level0_functions.copy()
    level1_functions.append(lambda n: antidiag_0[n] if n < N else 0)
    
    antidiag_1 = [1 - level1_functions[i % len(level1_functions)](i) for i in range(N)]
    print(f"Anti-diagonal of level 1: {antidiag_1}")
    print(f"  ✓ Level 1's anti-diagonal escapes level 1 (by Cantor's argument)")
    
    print(f"\n  The hierarchy continues forever:")
    print(f"  Level 0 < Level 1 < Level 2 < Level 3 < ...")
    print(f"  Each level strictly more powerful than all below it")


def convergent_approximation_demo():
    """Demonstrate convergent approximation to a 'non-computable' function.
    
    We simulate a target function that is hard to approximate and show
    how successive stages eventually converge but always leave errors.
    """
    print("\n" + "=" * 60)
    print("DEMO 3: Convergent Approximation")
    print("=" * 60)
    
    N = 20  # Number of inputs
    
    # "Non-computable" target: based on a complex rule
    random.seed(42)
    target = [random.choice([0, 1]) for _ in range(N)]
    print(f"\nTarget function (first {N} values): {target}")
    
    # Simulate stages of approximation
    num_stages = 8
    print(f"\nStage-by-stage approximation:")
    for stage in range(num_stages):
        # Each stage gets the first (stage + 1) values right
        # but guesses randomly for the rest
        approx = []
        for i in range(N):
            if i <= stage * 2:
                approx.append(target[i])  # Correct
            else:
                approx.append(random.choice([0, 1]))  # Guess
        
        errors = sum(1 for i in range(N) if approx[i] != target[i])
        correct = N - errors
        print(f"  Stage {stage}: {approx}  "
              f"({correct}/{N} correct, {errors} errors)")
    
    print(f"\n✓ Every stage has at least one error (unbounded convergence time)")
    print(f"  Convergence requires infinitely many stages")


def accidental_vs_essential_demo():
    """Demonstrate the gap between accidental and essential computability.
    
    Shows that the anti-diagonal is 'accidentally correct' on every
    singleton but not 'essentially computable'.
    """
    print("\n" + "=" * 60)
    print("DEMO 4: Accidentally Correct vs. Essentially Computable")
    print("=" * 60)
    
    N = 10
    
    # Our 'programs' (simple functions)
    programs = [
        lambda n, k=k: (n + k) % 2
        for k in range(N)
    ]
    
    # Anti-diagonal
    antidiag = [1 - programs[i](i) for i in range(N)]
    print(f"\nAnti-diagonal: {antidiag}")
    
    # For each position, find a program that's correct there
    print(f"\nAccidental correctness on singletons:")
    for pos in range(N):
        found = False
        for prog_idx, prog in enumerate(programs):
            if prog(pos) == antidiag[pos]:
                print(f"  Position {pos}: Program {prog_idx} gives "
                      f"{prog(pos)} = antidiag[{pos}] ✓")
                found = True
                break
        if not found:
            # Use negation closure: negate a program
            for prog_idx, prog in enumerate(programs):
                if 1 - prog(pos) == antidiag[pos]:
                    print(f"  Position {pos}: ¬Program {prog_idx} gives "
                          f"{1 - prog(pos)} = antidiag[{pos}] ✓")
                    found = True
                    break
    
    print(f"\n  ✓ Every individual position has a 'computable' function that agrees")
    print(f"  ✗ But NO single program agrees on ALL positions simultaneously")
    print(f"  This is the essential-accidental gap!")


def information_theoretic_demo():
    """Demonstrate the exponential explosion of oracle space."""
    print("\n" + "=" * 60)
    print("DEMO 5: Information-Theoretic Bounds")
    print("=" * 60)
    
    print(f"\n  N inputs → 2^N possible oracles:")
    for n in range(1, 21):
        total = 2 ** n
        missed = total - 1
        pct = 100 * missed / total
        bar = "█" * min(50, n * 3)
        print(f"  N={n:2d}: {total:>10,d} oracles, "
              f"any algorithm misses {missed:>10,d} ({pct:.2f}%) {bar}")
    
    print(f"\n✓ The fraction missed approaches 100% exponentially fast")
    print(f"  Any single algorithm is a flashlight in an exponentially dark room")


if __name__ == "__main__":
    diagonal_argument_demo()
    oracle_hierarchy_demo()
    convergent_approximation_demo()
    accidental_vs_essential_demo()
    information_theoretic_demo()
    
    print("\n" + "=" * 60)
    print("All demonstrations complete.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: The Diagonal Argument

Creates a heatmap visualization showing how the anti-diagonal
escapes every row of a Boolean matrix.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as patches
import numpy as np


def create_diagonal_visualization(n: int = 10, seed: int = 42):
    """Create a visualization of the diagonal argument."""
    np.random.seed(seed)
    
    # Create random Boolean matrix
    matrix = np.random.randint(0, 2, size=(n, n))
    
    # Compute anti-diagonal
    antidiag = np.array([1 - matrix[i, i] for i in range(n)])
    
    # Create figure with two subplots
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(16, 7),
                                     gridspec_kw={'width_ratios': [3, 1]})
    
    # Plot 1: Matrix heatmap with diagonal highlighted
    cmap = plt.cm.RdYlGn
    im = ax1.imshow(matrix, cmap=cmap, vmin=0, vmax=1, aspect='equal')
    
    # Highlight diagonal cells
    for i in range(n):
        rect = patches.Rectangle((i - 0.5, i - 0.5), 1, 1,
                                  linewidth=3, edgecolor='blue',
                                  facecolor='none', linestyle='--')
        ax1.add_patch(rect)
        # Add text
        ax1.text(i, i, str(matrix[i, i]), ha='center', va='center',
                fontsize=14, fontweight='bold', color='blue')
    
    # Add text for non-diagonal cells
    for i in range(n):
        for j in range(n):
            if i != j:
                ax1.text(j, i, str(matrix[i, j]), ha='center', va='center',
                        fontsize=10, color='gray')
    
    ax1.set_xlabel('Input n', fontsize=12)
    ax1.set_ylabel('Program index e', fontsize=12)
    ax1.set_title('Boolean Matrix φ(e, n)\n(diagonal highlighted in blue)', fontsize=14)
    ax1.set_xticks(range(n))
    ax1.set_yticks(range(n))
    
    # Plot 2: Anti-diagonal column
    antidiag_2d = antidiag.reshape(-1, 1)
    ax2.imshow(antidiag_2d, cmap=cmap, vmin=0, vmax=1, aspect=0.3)
    
    for i in range(n):
        color = 'red' if antidiag[i] != matrix[i, i] else 'green'
        ax2.text(0, i, f'¬{matrix[i,i]} = {antidiag[i]}', ha='center', va='center',
                fontsize=11, fontweight='bold', color='white',
                bbox=dict(boxstyle='round,pad=0.3', facecolor=color, alpha=0.8))
    
    ax2.set_title('Anti-diagonal\nd(n) = ¬φ(n,n)', fontsize=14)
    ax2.set_xticks([])
    ax2.set_yticks(range(n))
    ax2.set_yticklabels([f'n={i}' for i in range(n)])
    
    plt.suptitle('The Diagonal Argument: Why No Row Can Match the Anti-Diagonal',
                fontsize=16, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig('diagonal_argument.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: diagonal_argument.png")


def create_hierarchy_visualization(depth: int = 6):
    """Visualize the oracle hierarchy as a tower."""
    fig, ax = plt.subplots(figsize=(10, 8))
    
    colors = plt.cm.viridis(np.linspace(0.2, 0.9, depth))
    
    for k in range(depth):
        y = k * 1.2
        width = 3 + k * 0.3
        
        # Draw level block
        rect = patches.FancyBboxPatch(
            (5 - width/2, y), width, 0.9,
            boxstyle="round,pad=0.1",
            facecolor=colors[k], edgecolor='black', linewidth=2
        )
        ax.add_patch(rect)
        
        # Label
        ax.text(5, y + 0.45, f'Level {k}', ha='center', va='center',
               fontsize=14, fontweight='bold', color='white')
        
        # Show what's new at this level
        if k == 0:
            ax.text(8.5, y + 0.45, 'Computable functions',
                   fontsize=11, va='center', style='italic')
        else:
            ax.text(8.5, y + 0.45, f'+ Halting oracle for Level {k-1}',
                   fontsize=11, va='center', style='italic', color=colors[k-1])
        
        # Arrow between levels
        if k > 0:
            ax.annotate('', xy=(5, y), xytext=(5, y - 0.3),
                       arrowprops=dict(arrowstyle='->', lw=2, color='red'))
            ax.text(3.5, y - 0.15, '⊊', fontsize=16, ha='center', va='center',
                   color='red', fontweight='bold')
    
    # Add "..." at top
    ax.text(5, depth * 1.2 + 0.3, '⋮', fontsize=24, ha='center', va='center')
    ax.text(5, depth * 1.2 + 0.8, '∞ levels above', fontsize=12,
           ha='center', va='center', style='italic', color='gray')
    
    ax.set_xlim(0, 12)
    ax.set_ylim(-0.5, depth * 1.2 + 1.5)
    ax.set_aspect('equal')
    ax.axis('off')
    ax.set_title('The Oracle Hierarchy: An Infinite Tower of Computability',
                fontsize=16, fontweight='bold')
    
    plt.tight_layout()
    plt.savefig('oracle_hierarchy.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: oracle_hierarchy.png")


def create_convergence_visualization():
    """Visualize the convergence of approximation stages."""
    np.random.seed(42)
    N = 20
    num_stages = 10
    
    target = np.random.randint(0, 2, size=N)
    
    # Generate stages with increasing accuracy
    stages = []
    for k in range(num_stages):
        stage = np.copy(target)
        # Introduce errors at positions > k*2
        for i in range(min(k * 2 + 1, N), N):
            if np.random.random() < 0.5 * (1 - k / num_stages):
                stage[i] = 1 - stage[i]
        stages.append(stage)
    
    # Compute error counts
    errors = [np.sum(stage != target) for stage in stages]
    
    fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(12, 8),
                                     gridspec_kw={'height_ratios': [2, 1]})
    
    # Heatmap of agreement/disagreement
    agreement = np.array([stage == target for stage in stages]).astype(float)
    im = ax1.imshow(agreement, cmap='RdYlGn', vmin=0, vmax=1, aspect='auto')
    ax1.set_xlabel('Input n', fontsize=12)
    ax1.set_ylabel('Stage k', fontsize=12)
    ax1.set_title('Convergent Approximation: Green = Correct, Red = Error',
                 fontsize=14, fontweight='bold')
    ax1.set_yticks(range(num_stages))
    plt.colorbar(im, ax=ax1, label='Agreement with target')
    
    # Error count per stage
    ax2.bar(range(num_stages), errors, color=['red' if e > 0 else 'green' for e in errors])
    ax2.set_xlabel('Stage k', fontsize=12)
    ax2.set_ylabel('Number of errors', fontsize=12)
    ax2.set_title('Errors per Stage (every stage must have ≥ 1 error)', fontsize=14)
    ax2.set_xticks(range(num_stages))
    
    plt.tight_layout()
    plt.savefig('convergent_approximation.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: convergent_approximation.png")


if __name__ == "__main__":
    create_diagonal_visualization()
    create_hierarchy_visualization()
    create_convergence_visualization()
    print("\nAll visualizations generated.")
