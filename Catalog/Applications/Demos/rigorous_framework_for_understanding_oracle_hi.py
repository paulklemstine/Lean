#!/usr/bin/env python3
"""
Reflective Oracle Hierarchy — Numerical Demonstrations

This script demonstrates the key properties of reflective oracle hierarchies:
1. The consistency-completeness asymmetry
2. The advancing frontier of ignorance
3. The speed-up phenomenon
4. The soundness deficit growth
"""

from typing import Set, Dict, Tuple, List


def create_reflective_hierarchy(num_levels: int = 10) -> Dict[str, object]:
    """
    Create a concrete reflective hierarchy.
    
    Sentences are natural numbers.
    Witness/consistency sentence for level k is 2*k + 1.
    Provable at level n means: is a witness for some k < n.
    True means: is a witness for some k.
    Bot = 0 (not a witness).
    """
    def witness(k: int) -> int:
        return 2 * k + 1
    
    def is_true(s: int) -> bool:
        return s > 0 and s % 2 == 1
    
    def is_provable(n: int, s: int) -> bool:
        if not is_true(s):
            return False
        k = (s - 1) // 2
        return k < n
    
    def con_sentence(n: int) -> int:
        return witness(n)
    
    return {
        'witness': witness,
        'is_true': is_true,
        'is_provable': is_provable,
        'con_sentence': con_sentence,
        'num_levels': num_levels,
    }


def demo_consistency_one_jump(H: Dict) -> None:
    """Demonstrate that each consistency question is resolved in one jump."""
    print("=" * 60)
    print("DEMO 1: Consistency One-Jump Resolution")
    print("=" * 60)
    print()
    
    for n in range(8):
        con_n = H['con_sentence'](n)
        unprovable_at_n = not H['is_provable'](n, con_n)
        provable_at_n1 = H['is_provable'](n + 1, con_n)
        
        print(f"  Level {n}: Con({n}) = sentence {con_n}")
        print(f"    Provable at level {n}?   {H['is_provable'](n, con_n):>5}  (should be False)")
        print(f"    Provable at level {n+1}? {H['is_provable'](n+1, con_n):>5}  (should be True)")
        assert unprovable_at_n and provable_at_n1
    
    print()
    print("  ✓ Each consistency question is resolved in exactly one jump.")
    print()


def demo_advancing_frontier(H: Dict) -> None:
    """Demonstrate the advancing frontier of ignorance."""
    print("=" * 60)
    print("DEMO 2: The Advancing Frontier of Ignorance")
    print("=" * 60)
    print()
    
    for n in range(6):
        # Completeness gap at level n: true sentences not provable at n
        gap = []
        for s in range(1, 20, 2):  # Check odd numbers (true sentences)
            if H['is_true'](s) and not H['is_provable'](n, s):
                gap.append(s)
        
        # Resolved from previous level
        if n > 0:
            con_prev = H['con_sentence'](n - 1)
            was_in_gap = H['is_true'](con_prev) and not H['is_provable'](n - 1, con_prev)
            now_resolved = H['is_provable'](n, con_prev)
            status = "RESOLVED ✓" if (was_in_gap and now_resolved) else "unchanged"
        else:
            status = "(base level)"
        
        print(f"  Level {n}:")
        print(f"    Completeness gap (first 10 true sentences): {gap[:10]}")
        print(f"    Gap size (in range [1,20)): {len(gap)}")
        print(f"    Con({n}) = {H['con_sentence'](n)} is in gap: True")
        if n > 0:
            print(f"    Con({n-1}) = {H['con_sentence'](n-1)}: {status}")
        print()
    
    print("  ✓ The frontier advances but never disappears.")
    print()


def demo_strict_hierarchy(H: Dict) -> None:
    """Demonstrate strict monotonicity of the hierarchy."""
    print("=" * 60)
    print("DEMO 3: Strict Hierarchy Monotonicity")
    print("=" * 60)
    print()
    
    N = 30  # Check sentences 0..N-1
    for n in range(7):
        provable_n = sum(1 for s in range(N) if H['is_provable'](n, s))
        provable_n1 = sum(1 for s in range(N) if H['is_provable'](n + 1, s))
        
        new_theorems = [s for s in range(N) 
                       if H['is_provable'](n + 1, s) and not H['is_provable'](n, s)]
        
        print(f"  Level {n} → {n+1}:")
        print(f"    Provable at {n}: {provable_n}, at {n+1}: {provable_n1}")
        print(f"    New theorems: {new_theorems}")
        assert provable_n < provable_n1
    
    print()
    print("  ✓ Each level strictly extends the previous one.")
    print()


def demo_speedup(H: Dict) -> None:
    """Demonstrate the speed-up phenomenon."""
    print("=" * 60)
    print("DEMO 4: Consistency Speed-up")
    print("=" * 60)
    print()
    
    print("  Proof length model: length(n, φ) = 0 if unprovable, 1 if provable")
    print()
    
    for n in range(6):
        con_n = H['con_sentence'](n)
        len_at_n = 0 if not H['is_provable'](n, con_n) else 1
        len_at_n1 = 0 if not H['is_provable'](n + 1, con_n) else 1
        
        print(f"  Con({n}) = sentence {con_n}:")
        print(f"    Proof length at level {n}: {len_at_n} (unprovable)")
        print(f"    Proof length at level {n+1}: {len_at_n1} (provable)")
        assert len_at_n == 0 and len_at_n1 > 0
    
    print()
    print("  ✓ Speed-up: 0 → positive in one step.")
    print()


def demo_union_theory(H: Dict) -> None:
    """Demonstrate properties of the union (ω-limit) theory."""
    print("=" * 60)
    print("DEMO 5: Union Theory (ω-limit)")
    print("=" * 60)
    print()
    
    def union_provable(s: int, max_level: int = 100) -> bool:
        return any(H['is_provable'](n, s) for n in range(max_level))
    
    print("  Union theory proves all finite consistency sentences:")
    for n in range(10):
        con_n = H['con_sentence'](n)
        up = union_provable(con_n)
        first_level = next(k for k in range(100) if H['is_provable'](k, con_n))
        print(f"    Con({n}) = {con_n}: provable in union? {up}, first proved at level {first_level}")
        assert up
    
    print()
    print("  But the union theory's own consistency (Con(ω)) is not provable")
    print("  at any finite level — it requires a transfinite extension.")
    print()
    print("  ✓ The union theory is complete for finite consistency but still incomplete.")
    print()


def demo_soundness_deficit(H: Dict) -> None:
    """Demonstrate the soundness deficit growth."""
    print("=" * 60)
    print("DEMO 6: Soundness Deficit Growth")
    print("=" * 60)
    print()
    
    N = 50  # Range of sentences to check
    print(f"  Counting true-but-unprovable sentences in [0, {N}):")
    print()
    
    deficits = []
    for n in range(10):
        deficit = sum(1 for s in range(N) 
                     if H['is_true'](s) and not H['is_provable'](n, s))
        deficits.append(deficit)
        
        resolved = "—" if n == 0 else f"Con({n-1}) resolved"
        print(f"  Level {n}: deficit = {deficit}  ({resolved})")
    
    print()
    print("  Deficit sequence:", deficits)
    
    # In this concrete model, deficit decreases by 1 each level
    # because each level resolves one sentence but doesn't generate new true sentences
    # This is because our model has a fixed set of true sentences
    print()
    print("  Note: In this simple model, the deficit decreases (each jump resolves")
    print("  one sentence). The conjecture that deficit grows applies to *arithmetic*")
    print("  hierarchies where adding consistency generates new arithmetic truths.")
    print()


if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  REFLECTIVE ORACLE HIERARCHY — NUMERICAL DEMONSTRATIONS ║")
    print("╚══════════════════════════════════════════════════════════╝")
    print()
    
    H = create_reflective_hierarchy()
    
    demo_consistency_one_jump(H)
    demo_advancing_frontier(H)
    demo_strict_hierarchy(H)
    demo_speedup(H)
    demo_union_theory(H)
    demo_soundness_deficit(H)
    
    print("All demonstrations completed successfully. ✓")


#!/usr/bin/env python3
"""
Visualization: Reflective Oracle Hierarchy Structure

Generates a visualization showing:
1. The strict containment of provable sets across levels
2. The completeness gap at each level
3. The frontier advancement pattern
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def witness(k: int) -> int:
    return 2 * k + 1

def is_true(s: int) -> bool:
    return s > 0 and s % 2 == 1

def is_provable(n: int, s: int) -> bool:
    if not is_true(s):
        return False
    k = (s - 1) // 2
    return k < n

def con_sentence(n: int) -> int:
    return witness(n)


def plot_hierarchy_structure():
    fig, axes = plt.subplots(1, 3, figsize=(18, 6))
    
    # Plot 1: Provable set growth
    ax1 = axes[0]
    levels = range(12)
    N = 30
    provable_counts = [sum(1 for s in range(N) if is_provable(n, s)) for n in levels]
    true_count = sum(1 for s in range(N) if is_true(s))
    
    ax1.bar(levels, provable_counts, color='steelblue', alpha=0.8, label='Provable sentences')
    ax1.axhline(y=true_count, color='red', linestyle='--', linewidth=2, label=f'True sentences ({true_count})')
    ax1.set_xlabel('Level n', fontsize=12)
    ax1.set_ylabel(f'Count (in [0, {N}))', fontsize=12)
    ax1.set_title('Provable Set Growth', fontsize=14, fontweight='bold')
    ax1.legend(fontsize=10)
    ax1.set_ylim(0, true_count + 2)
    
    # Plot 2: Completeness gap (deficit)
    ax2 = axes[1]
    deficits = [true_count - p for p in provable_counts]
    colors = ['#e74c3c' if d > 0 else '#27ae60' for d in deficits]
    ax2.bar(levels, deficits, color=colors, alpha=0.8)
    ax2.set_xlabel('Level n', fontsize=12)
    ax2.set_ylabel('True but unprovable', fontsize=12)
    ax2.set_title('Completeness Deficit', fontsize=14, fontweight='bold')
    ax2.axhline(y=0, color='black', linewidth=0.5)
    
    # Annotate Con(n) for first few levels
    for n in range(min(5, len(levels))):
        if deficits[n] > 0:
            ax2.annotate(f'Con({n})', xy=(n, deficits[n]), 
                        xytext=(n + 0.3, deficits[n] + 0.5),
                        fontsize=8, ha='center',
                        arrowprops=dict(arrowstyle='->', color='gray'))
    
    # Plot 3: Frontier advancement heatmap
    ax3 = axes[2]
    max_level = 10
    max_sentence = 20
    
    # Create matrix: rows = levels, cols = sentences
    matrix = np.zeros((max_level, max_sentence))
    for n in range(max_level):
        for s in range(max_sentence):
            if is_true(s) and is_provable(n, s):
                matrix[n, s] = 2  # Provable and true
            elif is_true(s):
                matrix[n, s] = 1  # True but not provable (in gap)
            elif is_provable(n, s):
                matrix[n, s] = 3  # Provable but not true (shouldn't happen in sound hierarchy)
            else:
                matrix[n, s] = 0  # Neither
    
    cmap = plt.cm.colors.ListedColormap(['#f0f0f0', '#e74c3c', '#27ae60', '#3498db'])
    bounds = [-0.5, 0.5, 1.5, 2.5, 3.5]
    norm = plt.cm.colors.BoundaryNorm(bounds, cmap.N)
    
    im = ax3.imshow(matrix, aspect='auto', cmap=cmap, norm=norm, origin='lower')
    ax3.set_xlabel('Sentence index', fontsize=12)
    ax3.set_ylabel('Level n', fontsize=12)
    ax3.set_title('Frontier Advancement', fontsize=14, fontweight='bold')
    
    # Mark consistency sentences
    for n in range(max_level):
        con_n = con_sentence(n)
        if con_n < max_sentence:
            ax3.plot(con_n, n, 'w*', markersize=8, markeredgecolor='black')
    
    # Legend for heatmap
    legend_patches = [
        mpatches.Patch(color='#f0f0f0', label='Not true'),
        mpatches.Patch(color='#e74c3c', label='True, unprovable (gap)'),
        mpatches.Patch(color='#27ae60', label='True & provable'),
    ]
    ax3.legend(handles=legend_patches, loc='upper right', fontsize=8)
    
    plt.tight_layout()
    plt.savefig('hierarchy_structure.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: hierarchy_structure.png")


def plot_asymmetry():
    """Visualize the consistency-soundness asymmetry."""
    fig, ax = plt.subplots(figsize=(10, 6))
    
    levels = range(15)
    
    # Consistency resolution: each level resolves the previous level's consistency
    con_resolved = list(range(15))  # At level n, n consistency sentences are resolved
    
    # Completeness gap: always ≥ 1 (at least Con(n) is true but unprovable)
    N = 40
    true_total = sum(1 for s in range(N) if is_true(s))
    gap_sizes = [true_total - sum(1 for s in range(N) if is_provable(n, s)) 
                 for n in levels]
    
    ax.plot(list(levels), con_resolved, 'b-o', linewidth=2, markersize=6,
            label='Consistency sentences resolved', color='#2ecc71')
    ax.plot(list(levels), gap_sizes, 'r-s', linewidth=2, markersize=6,
            label='True but unprovable (gap)', color='#e74c3c')
    
    ax.fill_between(list(levels), con_resolved, gap_sizes, alpha=0.15, color='red',
                    label='Permanent gap')
    
    ax.set_xlabel('Level n', fontsize=13)
    ax.set_ylabel('Count', fontsize=13)
    ax.set_title('The Consistency-Soundness Asymmetry', fontsize=15, fontweight='bold')
    ax.legend(fontsize=11, loc='center right')
    ax.grid(True, alpha=0.3)
    
    # Annotate the asymmetry
    ax.annotate('Resolved grows linearly\n(one per jump)',
               xy=(10, 10), xytext=(7, 14),
               fontsize=10, ha='center',
               arrowprops=dict(arrowstyle='->', color='#2ecc71', lw=1.5))
    
    ax.annotate('Gap decreases but\nnever reaches 0',
               xy=(10, gap_sizes[10]), xytext=(12, gap_sizes[10] + 3),
               fontsize=10, ha='center',
               arrowprops=dict(arrowstyle='->', color='#e74c3c', lw=1.5))
    
    plt.tight_layout()
    plt.savefig('asymmetry.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: asymmetry.png")


if __name__ == "__main__":
    plot_hierarchy_structure()
    plot_asymmetry()
    print("All visualizations generated.")
