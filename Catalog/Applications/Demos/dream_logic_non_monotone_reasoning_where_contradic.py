#!/usr/bin/env python3
"""
Dream Logic Demo: Paraconsistent Reasoning Where Contradictions Coexist

Demonstrates:
1. Belnap's four-valued logic operations
2. Dream frame belief computation and non-monotone retraction
3. Coherent openness and quasi-topological structure
"""

from enum import Enum
from typing import Dict, List, Set, Tuple, Optional


class BVal(Enum):
    """Belnap's four truth values."""
    NEITHER = 0  # Unknown
    FALSE = 1    # False only
    TRUE = 2     # True only
    BOTH = 3     # Both true and false (dialetheia)

    def is_designated(self) -> bool:
        """A value is designated if it is 'at least true'."""
        return self in (BVal.TRUE, BVal.BOTH)

    def bneg(self) -> 'BVal':
        """Belnap negation: swaps T↔F, fixes Both and Neither."""
        return {BVal.TRUE: BVal.FALSE, BVal.FALSE: BVal.TRUE,
                BVal.BOTH: BVal.BOTH, BVal.NEITHER: BVal.NEITHER}[self]

    def band(self, other: 'BVal') -> 'BVal':
        """Belnap conjunction (truth-order meet)."""
        table = {
            (BVal.FALSE, BVal.FALSE): BVal.FALSE, (BVal.FALSE, BVal.TRUE): BVal.FALSE,
            (BVal.FALSE, BVal.BOTH): BVal.FALSE, (BVal.FALSE, BVal.NEITHER): BVal.FALSE,
            (BVal.TRUE, BVal.FALSE): BVal.FALSE, (BVal.TRUE, BVal.TRUE): BVal.TRUE,
            (BVal.TRUE, BVal.BOTH): BVal.BOTH, (BVal.TRUE, BVal.NEITHER): BVal.NEITHER,
            (BVal.BOTH, BVal.FALSE): BVal.FALSE, (BVal.BOTH, BVal.TRUE): BVal.BOTH,
            (BVal.BOTH, BVal.BOTH): BVal.BOTH, (BVal.BOTH, BVal.NEITHER): BVal.FALSE,
            (BVal.NEITHER, BVal.FALSE): BVal.FALSE, (BVal.NEITHER, BVal.TRUE): BVal.NEITHER,
            (BVal.NEITHER, BVal.BOTH): BVal.FALSE, (BVal.NEITHER, BVal.NEITHER): BVal.NEITHER,
        }
        return table[(self, other)]

    def bor(self, other: 'BVal') -> 'BVal':
        """Belnap disjunction (truth-order join)."""
        table = {
            (BVal.FALSE, BVal.FALSE): BVal.FALSE, (BVal.FALSE, BVal.TRUE): BVal.TRUE,
            (BVal.FALSE, BVal.BOTH): BVal.BOTH, (BVal.FALSE, BVal.NEITHER): BVal.NEITHER,
            (BVal.TRUE, BVal.FALSE): BVal.TRUE, (BVal.TRUE, BVal.TRUE): BVal.TRUE,
            (BVal.TRUE, BVal.BOTH): BVal.TRUE, (BVal.TRUE, BVal.NEITHER): BVal.TRUE,
            (BVal.BOTH, BVal.FALSE): BVal.BOTH, (BVal.BOTH, BVal.TRUE): BVal.TRUE,
            (BVal.BOTH, BVal.BOTH): BVal.BOTH, (BVal.BOTH, BVal.NEITHER): BVal.TRUE,
            (BVal.NEITHER, BVal.FALSE): BVal.NEITHER, (BVal.NEITHER, BVal.TRUE): BVal.TRUE,
            (BVal.NEITHER, BVal.BOTH): BVal.TRUE, (BVal.NEITHER, BVal.NEITHER): BVal.NEITHER,
        }
        return table[(self, other)]


class DreamState:
    """A dream state with positive and negative extensions."""
    def __init__(self, pos: Set[int], neg: Set[int]):
        self.pos = pos
        self.neg = neg

    @property
    def contradictions(self) -> Set[int]:
        return self.pos & self.neg

    @property
    def gaps(self) -> Set[int]:
        all_props = self.pos | self.neg
        return set()  # Would need universe

    def is_consistent(self) -> bool:
        return len(self.contradictions) == 0

    def to_bval(self, p: int) -> BVal:
        in_pos = p in self.pos
        in_neg = p in self.neg
        if in_pos and in_neg: return BVal.BOTH
        if in_pos: return BVal.TRUE
        if in_neg: return BVal.FALSE
        return BVal.NEITHER


class DreamFrame:
    """A dream frame with worlds, accessibility, and valuations."""
    def __init__(self, worlds: List[int], access: Dict[int, Set[int]],
                 val: Dict[int, DreamState]):
        self.worlds = worlds
        self.access = access
        self.val = val

    def beliefs(self, w: int) -> Set[int]:
        """Propositions true at ALL accessible worlds."""
        result = None
        for w2 in self.access.get(w, set()):
            world_pos = self.val[w2].pos
            if result is None:
                result = set(world_pos)
            else:
                result &= world_pos
        return result if result is not None else set()

    def is_coherently_open(self, w0: int, s: Set[int]) -> bool:
        """Check if s is coherently open (supported by a single world)."""
        for w in self.access.get(w0, set()):
            consistent_pos = self.val[w].pos - self.val[w].neg
            if s <= consistent_pos:
                return True
        return False


def demo_belnap():
    """Demonstrate Belnap's four-valued logic."""
    print("=" * 60)
    print("BELNAP'S FOUR-VALUED LOGIC")
    print("=" * 60)

    # Show negation table
    print("\nNegation table:")
    for v in BVal:
        print(f"  ¬{v.name:8s} = {v.bneg().name}")

    # Show explosion failure
    print("\nExplosion failure demonstration:")
    v = BVal.BOTH
    print(f"  v = {v.name}")
    print(f"  v is designated: {v.is_designated()}")
    print(f"  ¬v = {v.bneg().name}, designated: {v.bneg().is_designated()}")
    print(f"  Both v and ¬v are designated, yet FALSE is not designated!")
    print(f"  → Explosion FAILS ✓")

    # Show modus ponens failure
    print("\nModus ponens failure:")
    p, q = BVal.BOTH, BVal.FALSE
    impl = p.bneg().bor(q)  # P → Q = ¬P ∨ Q
    print(f"  P = {p.name}, Q = {q.name}")
    print(f"  P → Q = ¬P ∨ Q = {p.bneg().name} ∨ {q.name} = {impl.name}")
    print(f"  P designated: {p.is_designated()}")
    print(f"  P → Q designated: {impl.is_designated()}")
    print(f"  Q designated: {q.is_designated()}")
    print(f"  → Modus ponens FAILS ✓")

    # De Morgan laws
    print("\nDe Morgan laws verification:")
    verified = True
    for a in BVal:
        for b in BVal:
            lhs1 = a.band(b).bneg()
            rhs1 = a.bneg().bor(b.bneg())
            lhs2 = a.bor(b).bneg()
            rhs2 = a.bneg().band(b.bneg())
            if lhs1 != rhs1 or lhs2 != rhs2:
                verified = False
    print(f"  ¬(a ∧ b) = ¬a ∨ ¬b: {'✓' if verified else '✗'}")
    print(f"  ¬(a ∨ b) = ¬a ∧ ¬b: {'✓' if verified else '✗'}")


def demo_dream_frames():
    """Demonstrate dream frame non-monotone retraction."""
    print("\n" + "=" * 60)
    print("DREAM FRAME NON-MONOTONE RETRACTION")
    print("=" * 60)

    # Frame 1: world 0 sees only itself
    df1 = DreamFrame(
        worlds=[0, 1],
        access={0: {0}, 1: {1}},
        val={0: DreamState({0, 1}, set()), 1: DreamState(set(), {0})}
    )

    # Frame 2: world 0 sees both worlds
    df2 = DreamFrame(
        worlds=[0, 1],
        access={0: {0, 1}, 1: {1}},
        val={0: DreamState({0, 1}, set()), 1: DreamState(set(), {0})}
    )

    print(f"\nFrame 1 (restricted access):")
    print(f"  World 0 accesses: {df1.access[0]}")
    print(f"  World 0 pos: {df1.val[0].pos}")
    print(f"  Beliefs at world 0: {df1.beliefs(0)}")

    print(f"\nFrame 2 (extended access):")
    print(f"  World 0 accesses: {df2.access[0]}")
    print(f"  World 0 pos: {df2.val[0].pos}, World 1 pos: {df2.val[1].pos}")
    print(f"  Beliefs at world 0: {df2.beliefs(0)}")

    retracted = df1.beliefs(0) - df2.beliefs(0)
    print(f"\n  Retracted beliefs: {retracted}")
    print(f"  → Non-monotone retraction ✓" if retracted else "  → No retraction")


def demo_quasi_topology():
    """Demonstrate coherent openness and union failure."""
    print("\n" + "=" * 60)
    print("QUASI-TOPOLOGICAL STRUCTURE: COHERENT OPENNESS")
    print("=" * 60)

    # The complementary contradiction frame
    df = DreamFrame(
        worlds=[0, 1],
        access={0: {0, 1}, 1: {0, 1}},
        val={
            0: DreamState({0, 1}, {0}),  # consistentPos = {1}
            1: DreamState({0, 1}, {1}),  # consistentPos = {0}
        }
    )

    print("\nComplementary contradiction frame:")
    print("  World 0: pos={0,1}, neg={0} → consistent pos = {1}")
    print("  World 1: pos={0,1}, neg={1} → consistent pos = {0}")
    print("  Both worlds accessible from world 0")

    s = {0}
    t = {1}
    u = {0, 1}

    print(f"\n  s = {s}: coherently open? {df.is_coherently_open(0, s)}")
    print(f"    (supported by world 1, where 0 ∈ pos\\neg)")
    print(f"  t = {t}: coherently open? {df.is_coherently_open(0, t)}")
    print(f"    (supported by world 0, where 1 ∈ pos\\neg)")
    print(f"  s ∪ t = {u}: coherently open? {df.is_coherently_open(0, u)}")
    print(f"    (NO world supports both 0 and 1 consistently!)")
    print(f"  → Union closure FAILS ✓ (quasi-topological, not topological)")


def demo_contradiction_counting():
    """Demonstrate contradiction degree computation."""
    print("\n" + "=" * 60)
    print("CONTRADICTION DEGREE AND INFORMATION GROWTH")
    print("=" * 60)

    props = list(range(5))
    states = [
        DreamState({0}, set()),           # 1 truth, 0 contradictions
        DreamState({0, 1}, {1}),          # 2 truths, 1 contradiction
        DreamState({0, 1, 2}, {1, 2}),    # 3 truths, 2 contradictions
        DreamState({0, 1, 2, 3}, {1, 2, 3}),  # 4 truths, 3 contradictions
        DreamState({0, 1, 2, 3, 4}, {0, 1, 2, 3, 4}),  # 5 truths, 5 contradictions
    ]

    print("\nInformation growth creates contradictions:")
    for i, s in enumerate(states):
        n_contra = len(s.contradictions)
        n_info = len(s.pos) + len(s.neg)
        print(f"  State {i}: |pos|={len(s.pos)}, |neg|={len(s.neg)}, "
              f"info={n_info}, contradictions={n_contra}, "
              f"consistent={s.is_consistent()}")

    print("\n  → Information grows monotonically")
    print("  → Contradictions grow monotonically")
    print("  → The information paradox: more knowledge = more contradictions")


if __name__ == "__main__":
    demo_belnap()
    demo_dream_frames()
    demo_quasi_topology()
    demo_contradiction_counting()
    print("\n" + "=" * 60)
    print("All demonstrations complete.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Belnap's Four-Valued Logic Lattice and Truth Tables

Generates a visualization of the FOUR lattice structure and operation tables.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def draw_belnap_lattice(ax):
    """Draw the Belnap FOUR lattice (diamond/bilattice)."""
    # Information order positions
    positions = {
        'Neither': (0, 0),
        'False': (-1, 1),
        'True': (1, 1),
        'Both': (0, 2),
    }
    
    colors = {
        'Neither': '#808080',  # Gray
        'False': '#FF4444',    # Red
        'True': '#44AA44',     # Green
        'Both': '#FFD700',     # Gold
    }
    
    # Draw edges (information order)
    edges = [('Neither', 'False'), ('Neither', 'True'), ('False', 'Both'), ('True', 'Both')]
    for a, b in edges:
        ax.plot([positions[a][0], positions[b][0]], 
                [positions[a][1], positions[b][1]], 
                'k-', linewidth=2, zorder=1)
    
    # Draw nodes
    for name, (x, y) in positions.items():
        circle = plt.Circle((x, y), 0.25, color=colors[name], ec='black', 
                           linewidth=2, zorder=2)
        ax.add_patch(circle)
        ax.text(x, y, name[0], ha='center', va='center', fontsize=14, 
                fontweight='bold', zorder=3)
        ax.text(x, y - 0.45, name, ha='center', va='center', fontsize=9)
    
    # Labels
    ax.set_xlim(-2, 2)
    ax.set_ylim(-0.8, 3)
    ax.set_aspect('equal')
    ax.set_title('Belnap FOUR\n(Information Lattice)', fontsize=13, fontweight='bold')
    ax.axis('off')
    
    # Add designation indicator
    ax.text(1.5, 1.5, 'Designated\n{T, B}', fontsize=9, 
            bbox=dict(boxstyle='round', facecolor='lightgreen', alpha=0.5),
            ha='center')


def draw_truth_table(ax, operation, title, func):
    """Draw a 4x4 truth table."""
    values = ['N', 'F', 'T', 'B']
    colors_map = {'N': '#C0C0C0', 'F': '#FFAAAA', 'T': '#AAFFAA', 'B': '#FFFFAA'}
    
    # Compute table
    table = np.zeros((4, 4), dtype=object)
    for i, a in enumerate(values):
        for j, b in enumerate(values):
            table[i, j] = func(a, b)
    
    ax.set_xlim(-0.5, 4.5)
    ax.set_ylim(-0.5, 4.5)
    
    # Draw cells
    for i in range(4):
        for j in range(4):
            val = table[i, j]
            color = colors_map[val]
            rect = mpatches.FancyBboxPatch((j + 0.55, 3.55 - i), 0.9, 0.9,
                                            boxstyle="round,pad=0.05",
                                            facecolor=color, edgecolor='gray')
            ax.add_patch(rect)
            ax.text(j + 1, 4 - i, val, ha='center', va='center', fontsize=12)
    
    # Headers
    for j, v in enumerate(values):
        ax.text(j + 1, 4.7, v, ha='center', va='center', fontsize=12, fontweight='bold')
        ax.text(-0.2, 4 - j, v, ha='center', va='center', fontsize=12, fontweight='bold')
    
    ax.set_title(title, fontsize=13, fontweight='bold', pad=15)
    ax.axis('off')


def conj_func(a, b):
    table = {
        ('F','F'):'F',('F','T'):'F',('F','B'):'F',('F','N'):'F',
        ('T','F'):'F',('T','T'):'T',('T','B'):'B',('T','N'):'N',
        ('B','F'):'F',('B','T'):'B',('B','B'):'B',('B','N'):'F',
        ('N','F'):'F',('N','T'):'N',('N','B'):'F',('N','N'):'N',
    }
    return table[(a, b)]


def disj_func(a, b):
    table = {
        ('F','F'):'F',('F','T'):'T',('F','B'):'B',('F','N'):'N',
        ('T','F'):'T',('T','T'):'T',('T','B'):'T',('T','N'):'T',
        ('B','F'):'B',('B','T'):'T',('B','B'):'B',('B','N'):'T',
        ('N','F'):'N',('N','T'):'T',('N','B'):'T',('N','N'):'N',
    }
    return table[(a, b)]


def neg_func(v):
    return {'N': 'N', 'F': 'T', 'T': 'F', 'B': 'B'}[v]


def main():
    fig, axes = plt.subplots(1, 3, figsize=(16, 5))
    
    draw_belnap_lattice(axes[0])
    draw_truth_table(axes[1], 'AND', 'Conjunction (∧)', conj_func)
    draw_truth_table(axes[2], 'OR', 'Disjunction (∨)', disj_func)
    
    fig.suptitle("Belnap's Four-Valued Logic: Structure and Operations", 
                 fontsize=15, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig('belnap_four.png', dpi=150, bbox_inches='tight')
    print("Saved belnap_four.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Dream Frame Structure and Non-Monotone Retraction

Shows how adding accessibility connections retracts beliefs.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def draw_frame(ax, title, worlds, access, val, beliefs_at_0):
    """Draw a dream frame diagram."""
    n = len(worlds)
    positions = {0: (-1, 0), 1: (1, 0)} if n == 2 else {i: (i, 0) for i in range(n)}
    
    # Draw accessibility arrows
    for w, targets in access.items():
        for t in targets:
            if w == t:
                # Self-loop
                x, y = positions[w]
                arc = mpatches.FancyArrowPatch(
                    (x - 0.15, y + 0.4), (x + 0.15, y + 0.4),
                    connectionstyle="arc3,rad=1.5",
                    arrowstyle='->', mutation_scale=15,
                    color='blue', linewidth=2
                )
                ax.add_patch(arc)
            else:
                x1, y1 = positions[w]
                x2, y2 = positions[t]
                ax.annotate('', xy=(x2, y2 + 0.35), xytext=(x1, y1 + 0.35),
                          arrowprops=dict(arrowstyle='->', color='blue', lw=2))
    
    # Draw worlds
    for w in worlds:
        x, y = positions[w]
        state = val[w]
        
        # World circle
        color = '#FFFFAA' if state['contra'] else '#AAFFAA'
        circle = plt.Circle((x, y), 0.35, color=color, ec='black', linewidth=2, zorder=5)
        ax.add_patch(circle)
        ax.text(x, y + 0.05, f'w{w}', ha='center', va='center', fontsize=12, 
                fontweight='bold', zorder=6)
        
        # State info below
        pos_str = '{' + ','.join(str(p) for p in sorted(state['pos'])) + '}'
        neg_str = '{' + ','.join(str(p) for p in sorted(state['neg'])) + '}'
        ax.text(x, y - 0.55, f'pos={pos_str}', ha='center', fontsize=9)
        ax.text(x, y - 0.75, f'neg={neg_str}', ha='center', fontsize=9)
        if state['contra']:
            ax.text(x, y - 0.95, f'⚡contra', ha='center', fontsize=9, color='red')
    
    # Beliefs box
    beliefs_str = '{' + ','.join(str(p) for p in sorted(beliefs_at_0)) + '}'
    ax.text(0, -1.5, f'Beliefs at w0: {beliefs_str}', ha='center', fontsize=11,
            bbox=dict(boxstyle='round', facecolor='lightblue', alpha=0.7))
    
    ax.set_xlim(-2, 2)
    ax.set_ylim(-2, 1.5)
    ax.set_aspect('equal')
    ax.set_title(title, fontsize=13, fontweight='bold')
    ax.axis('off')


def main():
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))
    
    # Frame 1: restricted access
    draw_frame(ax1, 'Frame 1: Restricted Access\n(w0 sees only itself)',
               worlds=[0, 1],
               access={0: {0}, 1: {1}},
               val={
                   0: {'pos': {0, 1}, 'neg': set(), 'contra': False},
                   1: {'pos': set(), 'neg': {0}, 'contra': False},
               },
               beliefs_at_0={0, 1})
    
    # Frame 2: extended access
    draw_frame(ax2, 'Frame 2: Extended Access\n(w0 sees both worlds)',
               worlds=[0, 1],
               access={0: {0, 1}, 1: {1}},
               val={
                   0: {'pos': {0, 1}, 'neg': set(), 'contra': False},
                   1: {'pos': set(), 'neg': {0}, 'contra': False},
               },
               beliefs_at_0=set())
    
    # Arrow between frames
    fig.text(0.5, 0.02, '→ Adding w0→w1 access RETRACTS beliefs {0,1} → ∅',
             ha='center', fontsize=13, fontweight='bold', color='red',
             bbox=dict(boxstyle='round', facecolor='mistyrose'))
    
    fig.suptitle('Non-Monotone Belief Retraction in Dream Frames', 
                 fontsize=15, fontweight='bold')
    plt.tight_layout(rect=[0, 0.08, 1, 0.95])
    plt.savefig('dream_retraction.png', dpi=150, bbox_inches='tight')
    print("Saved dream_retraction.png")


if __name__ == "__main__":
    main()
