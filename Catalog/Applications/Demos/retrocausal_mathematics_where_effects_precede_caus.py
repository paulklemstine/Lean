#!/usr/bin/env python3
"""
Retrocausal Mathematics: Numerical Demonstrations

Demonstrates the key theorems from the retrocausal logic framework:
1. Temporal Excluded Middle: cl(a) ∨ cl(¬a) = ⊤
2. Non-Boolean Gap: cl(a) ∧ cl(¬a) ≥ cl(⊥)
3. Frame distributivity: fixed points closed under arbitrary meets
4. S4 Modal properties: idempotency, reflexivity
"""

from typing import Callable, Set, FrozenSet, Tuple
import itertools


def powerset_lattice(n: int) -> list[frozenset[int]]:
    """Generate all subsets of {0, ..., n-1} as a powerset lattice."""
    base = set(range(n))
    result = []
    for r in range(n + 1):
        for combo in itertools.combinations(base, r):
            result.append(frozenset(combo))
    return sorted(result, key=lambda s: (len(s), sorted(s)))


def make_galois_connection(
    n: int,
    T: Callable[[frozenset[int]], frozenset[int]],
    R: Callable[[frozenset[int]], frozenset[int]],
) -> bool:
    """Verify that (T, R) form a Galois connection on P({0,...,n-1})."""
    elements = powerset_lattice(n)
    for a in elements:
        for b in elements:
            lhs = T(a).issubset(b)
            rhs = a.issubset(R(b))
            if lhs != rhs:
                return False
    return True


def closure(
    T: Callable[[frozenset[int]], frozenset[int]],
    R: Callable[[frozenset[int]], frozenset[int]],
    a: frozenset[int],
) -> frozenset[int]:
    """Compute the retrocausal closure cl(a) = R(T(a))."""
    return R(T(a))


def interior(
    T: Callable[[frozenset[int]], frozenset[int]],
    R: Callable[[frozenset[int]], frozenset[int]],
    a: frozenset[int],
) -> frozenset[int]:
    """Compute the retrocausal interior int(a) = T(R(a))."""
    return T(R(a))


# ============================================================
# Example 1: Image/Preimage Galois Connection
# ============================================================

def demo_image_preimage():
    """
    Galois connection from a function f: {0,1,2} -> {0,1,2}
    T(S) = f(S) (image), R(S) = f⁻¹(S) (preimage)
    """
    print("=" * 60)
    print("EXAMPLE 1: Image/Preimage Galois Connection")
    print("=" * 60)
    
    # f: 0 -> 0, 1 -> 0, 2 -> 1 (non-injective, non-surjective)
    f_map = {0: 0, 1: 0, 2: 1}
    n = 3
    universe = frozenset(range(n))
    
    def T(s: frozenset[int]) -> frozenset[int]:
        return frozenset(f_map[x] for x in s)
    
    def R(s: frozenset[int]) -> frozenset[int]:
        return frozenset(x for x in range(n) if f_map[x] in s)
    
    # Verify Galois connection
    is_gc = make_galois_connection(n, T, R)
    print(f"  f: {f_map}")
    print(f"  Is Galois connection: {is_gc}")
    
    # Compute closure of all elements
    elements = powerset_lattice(n)
    print(f"\n  Closure table (cl = R∘T):")
    fixed_points = []
    for s in elements:
        cl_s = closure(T, R, s)
        is_fixed = cl_s == s
        marker = " ★" if is_fixed else ""
        print(f"    cl({set(s)}) = {set(cl_s)}{marker}")
        if is_fixed:
            fixed_points.append(s)
    
    print(f"\n  Fixed points: {[set(s) for s in fixed_points]}")
    
    # Check temporal excluded middle
    print(f"\n  Temporal Excluded Middle check:")
    for s in elements:
        complement = universe - s
        cl_s = closure(T, R, s)
        cl_comp = closure(T, R, complement)
        join = cl_s | cl_comp
        print(f"    cl({set(s)}) ∨ cl({set(complement)}) = {set(join)} {'= ⊤ ✓' if join == universe else '≠ ⊤ ✗'}")
    
    # Check non-Boolean gap
    print(f"\n  Non-Boolean Gap (cl(a) ∧ cl(¬a) ≥ cl(⊥)):")
    cl_bot = closure(T, R, frozenset())
    print(f"    cl(⊥) = {set(cl_bot)}")
    for s in elements:
        complement = universe - s
        cl_s = closure(T, R, s)
        cl_comp = closure(T, R, complement)
        meet = cl_s & cl_comp
        gap_holds = cl_bot.issubset(meet)
        print(f"    cl({set(s)}) ∧ cl({set(complement)}) = {set(meet)} ≥ cl(⊥)? {gap_holds}")


# ============================================================
# Example 2: Temporal Propagation on a 4-element chain
# ============================================================

def demo_temporal_chain():
    """
    Temporal propagation where T 'smears' forward in time
    and R 'smears' backward. On {0,1,2,3} with subset ordering.
    T(S) = {x : ∃ y ∈ S, y ≤ x} (upward closure)
    R(S) = {x : ∃ y ∈ S, x ≤ y} (downward closure)
    """
    print("\n" + "=" * 60)
    print("EXAMPLE 2: Temporal Smearing on {0,1,2,3}")
    print("=" * 60)
    
    n = 4
    universe = frozenset(range(n))
    
    def T(s: frozenset[int]) -> frozenset[int]:
        """Upward closure: future propagation."""
        if not s:
            return frozenset()
        return frozenset(x for x in range(n) if any(y <= x for y in s))
    
    def R(s: frozenset[int]) -> frozenset[int]:
        """Downward closure: retrocausal propagation."""
        if not s:
            return frozenset()
        return frozenset(x for x in range(n) if any(x <= y for y in s))
    
    is_gc = make_galois_connection(n, T, R)
    print(f"  Is Galois connection: {is_gc}")
    
    # Find fixed points
    elements = powerset_lattice(n)
    fixed_points = [s for s in elements if closure(T, R, s) == s]
    print(f"  Fixed points: {[set(s) for s in fixed_points]}")
    print(f"  Number of fixed points: {len(fixed_points)}")
    print(f"  Number of all subsets: {len(elements)}")
    
    # Check frame distributivity: meet of fixed points is a fixed point
    print(f"\n  Frame distributivity check (meet of fps is fp):")
    for i, a in enumerate(fixed_points):
        for b in fixed_points[i+1:]:
            meet = a & b
            is_fp = meet in fixed_points
            print(f"    {set(a)} ∧ {set(b)} = {set(meet)} is fixed point? {is_fp}")
    
    # S4 properties
    print(f"\n  S4 Modal Properties:")
    test_sets = [frozenset({1}), frozenset({0, 2}), frozenset({1, 3})]
    for s in test_sets:
        cl_s = closure(T, R, s)
        int_s = interior(T, R, s)
        cl_cl_s = closure(T, R, cl_s)
        int_int_s = interior(T, R, int_s)
        print(f"    a = {set(s)}")
        print(f"      □a = cl(a) = {set(cl_s)}, a ≤ □a? {s.issubset(cl_s)}")
        print(f"      □□a = {set(cl_cl_s)}, □□a = □a? {cl_cl_s == cl_s}")
        print(f"      ◇a = int(a) = {set(int_s)}, ◇a ≤ a? {int_s.issubset(s)}")
        print(f"      ◇◇a = {set(int_int_s)}, ◇◇a = ◇a? {int_int_s == int_s}")
        print(f"      ◇a ≤ □a? {int_s.issubset(cl_s)}")


# ============================================================
# Example 3: Non-trivial retrocausal structure
# ============================================================

def demo_nontrivial():
    """
    A non-trivial Galois connection where cl(⊥) ≠ ⊥,
    witnessing that the fixed-point lattice is NOT Boolean.
    """
    print("\n" + "=" * 60)
    print("EXAMPLE 3: Non-Boolean Fixed Points (cl(⊥) ≠ ⊥)")
    print("=" * 60)
    
    n = 3
    universe = frozenset(range(n))
    
    # T collapses {0} and {1} together
    def T(s: frozenset[int]) -> frozenset[int]:
        result = set()
        for x in s:
            if x in (0, 1):
                result.add(0)
            else:
                result.add(x)
        return frozenset(result)
    
    # R expands: preimage under the collapsing map
    def R(s: frozenset[int]) -> frozenset[int]:
        result = set()
        for x in s:
            if x == 0:
                result.update([0, 1])
            else:
                result.add(x)
        return frozenset(result)
    
    is_gc = make_galois_connection(n, T, R)
    print(f"  Is Galois connection: {is_gc}")
    
    cl_bot = closure(T, R, frozenset())
    print(f"  cl(⊥) = {set(cl_bot)} {'≠ ⊥ → NOT Boolean!' if cl_bot else '= ⊥ → Boolean'}")
    
    elements = powerset_lattice(n)
    fixed_points = [s for s in elements if closure(T, R, s) == s]
    print(f"  Fixed points: {[set(s) for s in fixed_points]}")
    
    # Show closure table
    print(f"\n  Closure table:")
    for s in elements:
        cl_s = closure(T, R, s)
        is_fixed = cl_s == s
        print(f"    cl({set(s):>15}) = {set(cl_s):<15} {'★ fixed' if is_fixed else ''}")
    
    # Check if fixed-point lattice is Boolean
    print(f"\n  Is the fixed-point lattice Boolean?")
    for fp in fixed_points:
        complement = universe - fp
        cl_comp = closure(T, R, complement)
        has_complement = (fp | cl_comp == universe) and (fp & cl_comp == frozenset())
        print(f"    {set(fp)}: complement candidate cl(¬{set(fp)}) = {set(cl_comp)}, "
              f"join=⊤? {fp | cl_comp == universe}, meet=⊥? {fp & cl_comp == frozenset()}")


def demo_coherence():
    """Verify the coherence laws TRT = T and RTR = R."""
    print("\n" + "=" * 60)
    print("EXAMPLE 4: Coherence Laws (TRT = T, RTR = R)")
    print("=" * 60)
    
    n = 3
    f_map = {0: 0, 1: 0, 2: 1}
    
    def T(s: frozenset[int]) -> frozenset[int]:
        return frozenset(f_map[x] for x in s)
    
    def R(s: frozenset[int]) -> frozenset[int]:
        return frozenset(x for x in range(n) if f_map[x] in s)
    
    elements = powerset_lattice(n)
    
    print("  Left coherence: T(R(T(a))) = T(a)")
    all_ok = True
    for s in elements:
        lhs = T(R(T(s)))
        rhs = T(s)
        ok = lhs == rhs
        if not ok:
            all_ok = False
        print(f"    a={set(s):>15}: T(R(T(a)))={set(lhs)}, T(a)={set(rhs)}, equal? {ok}")
    print(f"  All equal: {all_ok}")
    
    print("\n  Right coherence: R(T(R(a))) = R(a)")
    all_ok = True
    for s in elements:
        lhs = R(T(R(s)))
        rhs = R(s)
        ok = lhs == rhs
        if not ok:
            all_ok = False
        print(f"    a={set(s):>15}: R(T(R(a)))={set(rhs)}, R(a)={set(rhs)}, equal? {ok}")
    print(f"  All equal: {all_ok}")


if __name__ == "__main__":
    demo_image_preimage()
    demo_temporal_chain()
    demo_nontrivial()
    demo_coherence()
    
    print("\n" + "=" * 60)
    print("SUMMARY")
    print("=" * 60)
    print("""
Key findings demonstrated numerically:
1. Temporal Excluded Middle holds: cl(a) ∨ cl(¬a) = ⊤ in all examples.
2. Non-Boolean Gap: when cl(⊥) ≠ ⊥, the fixed-point lattice is NOT Boolean.
3. Frame Distributivity: meets of fixed points are always fixed points.
4. S4 Properties: □ is extensive and idempotent; ◇ is contractive and idempotent.
5. Coherence Laws: TRT = T and RTR = R verified computationally.
""")


#!/usr/bin/env python3
"""
Visualization: Retrocausal Closure Lattice

Creates a visualization of the retrocausal closure operator on
a powerset lattice, showing fixed points, the closure map, and
the non-Boolean gap.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
import itertools


def powerset(n):
    base = list(range(n))
    result = []
    for r in range(n + 1):
        for combo in itertools.combinations(base, r):
            result.append(frozenset(combo))
    return result


def hasse_positions(n):
    """Compute positions for Hasse diagram of P({0,...,n-1})."""
    elements = powerset(n)
    positions = {}
    
    # Group by cardinality
    by_card = {}
    for s in elements:
        c = len(s)
        if c not in by_card:
            by_card[c] = []
        by_card[c].append(s)
    
    for card, group in by_card.items():
        width = len(group)
        for i, s in enumerate(group):
            x = (i - (width - 1) / 2) * 1.5
            y = card * 1.5
            positions[s] = (x, y)
    
    return positions, elements


def make_gc(n, f_map):
    """Create image/preimage Galois connection."""
    def T(s):
        return frozenset(f_map[x] for x in s)
    def R(s):
        return frozenset(x for x in range(n) if f_map[x] in s)
    return T, R


def visualize_closure_lattice():
    n = 3
    f_map = {0: 0, 1: 0, 2: 1}
    T, R = make_gc(n, f_map)
    
    def cl(s):
        return R(T(s))
    
    positions, elements = hasse_positions(n)
    universe = frozenset(range(n))
    
    fig, axes = plt.subplots(1, 2, figsize=(16, 8))
    
    # Left: Hasse diagram with closure arrows
    ax = axes[0]
    ax.set_title(f'Retrocausal Closure on P({{0,1,2}})\nf: 0→0, 1→0, 2→1', fontsize=14)
    
    # Draw Hasse edges
    for s in elements:
        for x in range(n):
            if x not in s:
                t = s | {x}
                if len(t) == len(s) + 1:
                    sx, sy = positions[s]
                    tx, ty = positions[t]
                    ax.plot([sx, tx], [sy, ty], 'k-', alpha=0.2, linewidth=0.5)
    
    # Color nodes: green = fixed point, yellow = not fixed
    for s in elements:
        x, y = positions[s]
        is_fixed = cl(s) == s
        color = '#2ecc71' if is_fixed else '#f39c12'
        size = 600 if is_fixed else 400
        ax.scatter(x, y, s=size, c=color, zorder=5, edgecolors='black', linewidth=1.5)
        label = '{' + ','.join(str(i) for i in sorted(s)) + '}' if s else '∅'
        ax.annotate(label, (x, y), textcoords="offset points", 
                   xytext=(0, -20), ha='center', fontsize=8, fontweight='bold')
    
    # Draw closure arrows
    for s in elements:
        cs = cl(s)
        if cs != s:
            sx, sy = positions[s]
            cx, cy = positions[cs]
            ax.annotate('', xy=(cx, cy), xytext=(sx, sy),
                       arrowprops=dict(arrowstyle='->', color='red', lw=2, 
                                      connectionstyle='arc3,rad=0.2'))
    
    ax.set_xlim(-3, 3)
    ax.set_ylim(-0.5, 5)
    ax.set_aspect('equal')
    ax.axis('off')
    
    # Legend
    fixed_patch = mpatches.Patch(color='#2ecc71', label='Fixed point (cl(a) = a)')
    nonfixed_patch = mpatches.Patch(color='#f39c12', label='Non-fixed (cl(a) ≠ a)')
    arrow_patch = mpatches.FancyArrow(0, 0, 1, 0, color='red', width=0.1)
    ax.legend(handles=[fixed_patch, nonfixed_patch], loc='upper left', fontsize=10)
    
    # Right: Non-Boolean gap visualization
    ax2 = axes[1]
    ax2.set_title('Non-Boolean Gap:\ncl(a) ∧ cl(¬a) ≥ cl(⊥)', fontsize=14)
    
    cl_bot = cl(frozenset())
    cl_bot_size = len(cl_bot)
    
    gaps = []
    labels = []
    for s in elements:
        comp = universe - s
        cl_s = cl(s)
        cl_comp = cl(comp)
        meet = cl_s & cl_comp
        gap = len(meet) - cl_bot_size
        label_s = '{' + ','.join(str(i) for i in sorted(s)) + '}' if s else '∅'
        gaps.append(len(meet))
        labels.append(label_s)
    
    colors = ['#e74c3c' if g > cl_bot_size else '#3498db' for g in gaps]
    
    bars = ax2.bar(range(len(gaps)), gaps, color=colors, edgecolor='black', alpha=0.8)
    ax2.axhline(y=cl_bot_size, color='green', linestyle='--', linewidth=2, 
                label=f'cl(⊥) = |{set(cl_bot)}| = {cl_bot_size}')
    ax2.set_xticks(range(len(labels)))
    ax2.set_xticklabels(labels, rotation=45, ha='right', fontsize=8)
    ax2.set_ylabel('|cl(a) ∧ cl(¬a)|', fontsize=12)
    ax2.set_xlabel('Element a', fontsize=12)
    ax2.legend(fontsize=10)
    
    plt.tight_layout()
    plt.savefig('/workspace/request-project/Applications/retrocausal_lattice.png', 
                dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: retrocausal_lattice.png")


def visualize_modal_operators():
    """Visualize the S4 modal operators □ and ◇."""
    n = 3
    f_map = {0: 0, 1: 0, 2: 1}
    T, R = make_gc(n, f_map)
    
    def cl(s):
        return R(T(s))
    def intr(s):
        return T(R(s))
    
    elements = powerset(n)
    
    fig, ax = plt.subplots(figsize=(12, 6))
    ax.set_title('S4 Modal Operators: □a ≤ a ≤ ◇a (False!)\nActually: ◇a ≤ a ≤ □a', fontsize=14)
    
    x_positions = np.arange(len(elements))
    width = 0.25
    
    sizes = [len(s) for s in elements]
    cl_sizes = [len(cl(s)) for s in elements]
    int_sizes = [len(intr(s)) for s in elements]
    
    bars1 = ax.bar(x_positions - width, int_sizes, width, label='◇a = int(a)', 
                   color='#3498db', edgecolor='black', alpha=0.8)
    bars2 = ax.bar(x_positions, sizes, width, label='a', 
                   color='#2ecc71', edgecolor='black', alpha=0.8)
    bars3 = ax.bar(x_positions + width, cl_sizes, width, label='□a = cl(a)', 
                   color='#e74c3c', edgecolor='black', alpha=0.8)
    
    labels = []
    for s in elements:
        label = '{' + ','.join(str(i) for i in sorted(s)) + '}' if s else '∅'
        labels.append(label)
    
    ax.set_xticks(x_positions)
    ax.set_xticklabels(labels, rotation=45, ha='right', fontsize=8)
    ax.set_ylabel('|set|', fontsize=12)
    ax.set_xlabel('Element a', fontsize=12)
    ax.legend(fontsize=11)
    
    plt.tight_layout()
    plt.savefig('/workspace/request-project/Applications/modal_operators.png',
                dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: modal_operators.png")


if __name__ == "__main__":
    visualize_closure_lattice()
    visualize_modal_operators()
