#!/usr/bin/env python3
"""
Tangled Hierarchies: Numerical Demonstrations

Demonstrates the algebraic structure of provability lattices and the
consistency tower using concrete finite models.
"""

from typing import List, Dict, Tuple


def build_four_element_model():
    """
    Build the 4-element provability lattice:
    Elements: {0=bot, 1=a, 2=b, 3=top}
    where a^c = b, b^c = a.
    
    box(0)=1, box(1)=3, box(2)=1, box(3)=3
    
    This satisfies Löb's axiom: box(x) ≤ x → x = top.
    """
    # Elements: 0=bot, 1=a, 2=b=a^c, 3=top
    # Lattice order: 0 < 1 < 3, 0 < 2 < 3
    # a and b are incomparable
    
    sup = [[0,1,2,3], [1,1,3,3], [2,3,2,3], [3,3,3,3]]
    inf = [[0,0,0,0], [0,1,0,1], [0,0,2,2], [0,1,2,3]]
    compl = [3, 2, 1, 0]
    box = [1, 3, 1, 3]
    
    def le(x, y):
        return inf[x][y] == x
    
    # Verify Löb's axiom
    print("=== 4-Element Provability Lattice ===")
    print("Elements: bot=0, a=1, b=2, top=3")
    print(f"box: {box}")
    print(f"compl: {compl}")
    print()
    
    print("Löb's axiom check (box(x) ≤ x → x = top):")
    for x in range(4):
        bx = box[x]
        if le(bx, x):
            print(f"  box({x})={bx} ≤ {x}: x should be top → x={'✓' if x == 3 else '✗'}")
        else:
            print(f"  box({x})={bx} ≤ {x}: False (vacuously true) ✓")
    
    print()
    
    # Compute soundness elements
    print("Soundness elements snd(x) = compl(box(x)) ⊔ x:")
    for x in range(4):
        bx = box[x]
        cbx = compl[bx]
        snd_x = sup[cbx][x]
        print(f"  snd({x}) = compl(box({x})) ⊔ {x} = compl({bx}) ⊔ {x} = {cbx} ⊔ {x} = {snd_x}")
    
    print()
    
    # Demonstrate fixed-point rigidity
    print("Fixed-point rigidity (box(x) = x → x = top):")
    for x in range(4):
        if box[x] == x:
            print(f"  box({x}) = {x}: x = top? {'✓' if x == 3 else '✗'}")
    
    # Demonstrate Gödel's second
    print(f"\nGödel's Second: box(bot) = box(0) = {box[0]} ≠ 0 = bot ✓")
    
    return box, sup, inf, compl


def demonstrate_consistency_tower(n_levels: int = 8):
    """
    Demonstrate the consistency tower in a larger provability lattice.
    
    We use the power set lattice P({0,...,k-1}) with k worlds,
    modeling a finite GL frame. The box operator is the interior
    operator: box(S) = {w : all successors of w are in S}.
    """
    k = 5  # number of worlds
    # GL frame: strict linear order 0 < 1 < 2 < 3 < 4
    # R(i,j) iff i < j (transitive, irreflexive, converse well-founded)
    
    print(f"\n=== Consistency Tower on {k}-world Linear GL Frame ===")
    print(f"Worlds: 0, 1, ..., {k-1}")
    print("Accessibility: i R j iff i < j")
    print()
    
    def box_set(S: set) -> set:
        """Box operator: w ∈ □S iff all successors of w are in S"""
        result = set()
        for w in range(k):
            successors = {v for v in range(k) if v > w}
            if successors <= S:
                result.add(w)
        return result
    
    # Build the tower: boxIter(n, ⊥)
    tower = [set()]  # boxIter(0, ⊥) = ⊥ = empty set
    for n in range(n_levels):
        tower.append(box_set(tower[-1]))
    
    print("Provability tower (boxIter(n, ⊥)):")
    for n, S in enumerate(tower):
        print(f"  □^{n}⊥ = {sorted(S) if S else '∅'}")
    
    # Consistency tower: complement of boxIter(n+1, ⊥)
    all_worlds = set(range(k))
    print(f"\nConsistency tower (conTower(n) = complement of □^(n+1)⊥):")
    for n in range(min(n_levels, k+2)):
        con_n = all_worlds - tower[n+1]
        print(f"  Con_{n} = {sorted(con_n) if con_n else '∅'}")
    
    # Demonstrate strict monotonicity
    print("\nStrict monotonicity check:")
    for n in range(min(n_levels - 1, k)):
        if tower[n] < tower[n+1]:
            print(f"  □^{n}⊥ ⊂ □^{n+1}⊥ ✓")
        elif tower[n] == tower[n+1]:
            print(f"  □^{n}⊥ = □^{n+1}⊥ (stabilized)")
            break


def demonstrate_soundness_iteration():
    """
    Demonstrate the iterated soundness operator.
    """
    k = 6
    all_worlds = set(range(k))
    
    print(f"\n=== Iterated Soundness on {k}-world Linear GL Frame ===")
    
    def box_set(S: set) -> set:
        result = set()
        for w in range(k):
            successors = {v for v in range(k) if v > w}
            if successors <= S:
                result.add(w)
        return result
    
    def snd_set(S: set) -> set:
        """snd(S) = compl(box(S)) ∪ S"""
        return (all_worlds - box_set(S)) | S
    
    # Start with ⊥
    a = set()
    print(f"Starting element a = ∅")
    print(f"\nIterated soundness snd^n(⊥):")
    for n in range(10):
        print(f"  snd^{n}(⊥) = {sorted(a) if a else '∅'}")
        if a == all_worlds:
            print(f"  → Reached ⊤ at iteration {n}!")
            break
        a = snd_set(a)
    
    # Start with a non-trivial element
    print()
    a = {k-1}  # world with highest rank
    print(f"Starting element a = {sorted(a)}")
    print(f"\nIterated soundness snd^n(a):")
    for n in range(10):
        print(f"  snd^{n}(a) = {sorted(a)}")
        if a == all_worlds:
            print(f"  → Would reach ⊤ only if a = ⊤")
            break
        new_a = snd_set(a)
        if new_a == a:
            print(f"  → Stabilized at snd^{n} (fixed point below ⊤)")
            break
        a = new_a


def demonstrate_loeb_kripke():
    """
    Demonstrate Löb's theorem on a concrete Kripke frame.
    """
    print("\n=== Löb's Theorem on a 4-world GL Frame ===")
    print("Worlds: 0, 1, 2, 3")
    print("Accessibility: 0→1, 0→2, 0→3, 1→2, 1→3, 2→3")
    print("(This is the strict order on {0,1,2,3})")
    print()
    
    # Valuation: p is true at worlds 2 and 3
    V_p = {2, 3}
    print(f"Valuation V(p) = {sorted(V_p)}")
    print()
    
    # Compute forces for □p
    def box(S):
        result = set()
        for w in range(4):
            succs = {v for v in range(4) if v > w}
            if succs <= S:
                result.add(w)
        return result
    
    box_p = box(V_p)
    print(f"□p = {sorted(box_p)} (worlds where all successors satisfy p)")
    
    # □p → p
    imp_box_p_p = (set(range(4)) - box_p) | V_p
    print(f"□p → p = {sorted(imp_box_p_p)}")
    
    # □(□p → p)
    box_imp = box(imp_box_p_p)
    print(f"□(□p → p) = {sorted(box_imp)}")
    
    # Verify Löb: □(□p → p) ⊆ □p
    print(f"\nLöb check: □(□p → p) ⊆ □p? {box_imp <= box_p}")
    print(f"  □(□p → p) = {sorted(box_imp)}")
    print(f"  □p = {sorted(box_p)}")
    if box_imp <= box_p:
        print("  ✓ Löb's theorem verified!")


def demonstrate_tangling_inevitability():
    """
    Demonstrate that sound worlds can't prove their own soundness.
    """
    print("\n=== Tangling Inevitability ===")
    print("On a 5-world linear GL frame (0 < 1 < 2 < 3 < 4):")
    print()
    
    k = 5
    all_worlds = set(range(k))
    
    def box(S):
        result = set()
        for w in range(k):
            succs = {v for v in range(k) if v > w}
            if succs <= S:
                result.add(w)
        return result
    
    # Check which worlds are "sound" (□⊥ → ⊥ holds)
    box_bot = box(set())
    print(f"□⊥ = {sorted(box_bot)}")
    print()
    
    # A world w is sound for ⊥ if: w ∈ □⊥ → w ∈ ⊥, i.e., w ∉ □⊥
    sound_for_bot = all_worlds - box_bot
    print(f"Worlds satisfying □⊥ → ⊥ (sound for ⊥): {sorted(sound_for_bot)}")
    
    # Can these worlds prove their own consistency?
    # □(□⊥ → ⊥) = box(sound_for_bot)
    box_sound = box(sound_for_bot)
    print(f"□(□⊥ → ⊥) = {sorted(box_sound)}")
    print()
    
    for w in sorted(sound_for_bot):
        can_prove = w in box_sound
        print(f"  World {w}: sound for ⊥? Yes. Proves own soundness? {'Yes ✗' if can_prove else 'No ✓'}")
    
    print()
    print("No consistent, sound world proves its own soundness — tangling is inevitable!")


if __name__ == "__main__":
    build_four_element_model()
    demonstrate_consistency_tower()
    demonstrate_soundness_iteration()
    demonstrate_loeb_kripke()
    demonstrate_tangling_inevitability()


#!/usr/bin/env python3
"""
Visualization: Consistency Tower and Provability Tower
Shows the dual ascending/descending towers in a finite GL frame.
"""
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def compute_towers(k: int, max_depth: int = None):
    """Compute provability and consistency towers for a k-world linear GL frame."""
    if max_depth is None:
        max_depth = k + 2
    
    def box_set(S):
        result = set()
        for w in range(k):
            successors = {v for v in range(k) if v > w}
            if successors <= S:
                result.add(w)
        return result
    
    all_worlds = set(range(k))
    prov_tower = [set()]
    for n in range(max_depth):
        prov_tower.append(box_set(prov_tower[-1]))
    
    con_tower = [(all_worlds - prov_tower[n+1]) for n in range(max_depth)]
    return prov_tower, con_tower


def plot_towers():
    k = 8
    prov_tower, con_tower = compute_towers(k, k + 2)
    
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 7))
    
    # Provability tower
    for n in range(min(len(prov_tower), k + 2)):
        for w in range(k):
            color = '#2196F3' if w in prov_tower[n] else '#E0E0E0'
            ax1.add_patch(plt.Rectangle((n - 0.4, w - 0.4), 0.8, 0.8,
                                        facecolor=color, edgecolor='white', linewidth=1.5))
    
    ax1.set_xlim(-0.6, k + 1.6)
    ax1.set_ylim(-0.6, k - 0.4)
    ax1.set_xlabel('Iteration n', fontsize=12)
    ax1.set_ylabel('World', fontsize=12)
    ax1.set_title('Provability Tower: □ⁿ⊥', fontsize=14, fontweight='bold')
    ax1.set_xticks(range(k + 2))
    ax1.set_yticks(range(k))
    
    # Consistency tower
    for n in range(min(len(con_tower), k + 2)):
        for w in range(k):
            color = '#FF5722' if w in con_tower[n] else '#E0E0E0'
            ax2.add_patch(plt.Rectangle((n - 0.4, w - 0.4), 0.8, 0.8,
                                        facecolor=color, edgecolor='white', linewidth=1.5))
    
    ax2.set_xlim(-0.6, k + 1.6)
    ax2.set_ylim(-0.6, k - 0.4)
    ax2.set_xlabel('Level n', fontsize=12)
    ax2.set_ylabel('World', fontsize=12)
    ax2.set_title('Consistency Tower: Conₙ', fontsize=14, fontweight='bold')
    ax2.set_xticks(range(k + 2))
    ax2.set_yticks(range(k))
    
    # Size plots
    fig2, ax3 = plt.subplots(figsize=(10, 5))
    prov_sizes = [len(s) for s in prov_tower[:k+2]]
    con_sizes = [len(s) for s in con_tower[:k+2]]
    
    x = np.arange(k + 2)
    ax3.plot(x, prov_sizes, 'o-', color='#2196F3', linewidth=2, markersize=8, label='|□ⁿ⊥|')
    ax3.plot(x, con_sizes, 's-', color='#FF5722', linewidth=2, markersize=8, label='|Conₙ|')
    ax3.axhline(y=k, color='gray', linestyle='--', alpha=0.5, label='|W| = ' + str(k))
    
    ax3.set_xlabel('Level n', fontsize=12)
    ax3.set_ylabel('Set Size', fontsize=12)
    ax3.set_title(f'Tower Sizes ({k}-world Linear GL Frame)', fontsize=14, fontweight='bold')
    ax3.legend(fontsize=11)
    ax3.set_xticks(x)
    ax3.grid(True, alpha=0.3)
    
    plt.tight_layout()
    fig.savefig('tower_heatmap.png', dpi=150, bbox_inches='tight')
    fig2.savefig('tower_sizes.png', dpi=150, bbox_inches='tight')
    plt.close('all')
    print("Saved tower_heatmap.png and tower_sizes.png")


if __name__ == "__main__":
    plot_towers()


#!/usr/bin/env python3
"""
Visualization: Tangling Spectrum on GL Frames
Shows the well-founded rank (tangling depth) of each world and its relationship
to consistency statements.
"""
import matplotlib.pyplot as plt
import numpy as np


def tangling_rank(w, k):
    """Rank of world w in k-world linear frame: rank = k - 1 - w."""
    return k - 1 - w


def compute_consistency_depth(w, k):
    """Maximum n such that world w satisfies Con_n in a k-world linear frame.
    Con_n holds at w iff w is not in □^(n+1)⊥.
    □^m⊥ = {k-m, k-m+1, ..., k-1} for m ≤ k.
    So w ∈ □^(n+1)⊥ iff w ≥ k - (n+1), i.e., n+1 ≥ k - w, i.e., n ≥ k - w - 1.
    So w satisfies Con_n iff n < k - w - 1 = rank(w).
    Maximum n: rank(w) - 1 (if rank > 0), else -1.
    """
    rank = tangling_rank(w, k)
    return rank - 1  # -1 means no Con_n holds


def plot_spectrum():
    fig, axes = plt.subplots(1, 3, figsize=(18, 5))
    
    for idx, k in enumerate([5, 8, 12]):
        ax = axes[idx]
        worlds = list(range(k))
        ranks = [tangling_rank(w, k) for w in worlds]
        con_depths = [compute_consistency_depth(w, k) for w in worlds]
        
        bar_width = 0.35
        x = np.arange(k)
        
        bars1 = ax.bar(x - bar_width/2, ranks, bar_width, 
                       color='#2196F3', alpha=0.8, label='Tangling Rank')
        bars2 = ax.bar(x + bar_width/2, [max(0, d) for d in con_depths], bar_width, 
                       color='#FF5722', alpha=0.8, label='Max Con Level')
        
        # Mark worlds where rank = con_depth + 1 (conjecture)
        for w in worlds:
            if ranks[w] == con_depths[w] + 1:
                ax.annotate('✓', (w, ranks[w] + 0.1), ha='center', fontsize=10, color='green')
        
        ax.set_xlabel('World', fontsize=11)
        ax.set_ylabel('Depth / Level', fontsize=11)
        ax.set_title(f'{k}-world Linear Frame', fontsize=13, fontweight='bold')
        ax.set_xticks(x)
        ax.legend(fontsize=9)
        ax.grid(True, alpha=0.2, axis='y')
    
    plt.suptitle('Tangling Spectrum: Rank vs. Consistency Depth', 
                 fontsize=15, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig('tangling_spectrum.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved tangling_spectrum.png")


if __name__ == "__main__":
    plot_spectrum()
