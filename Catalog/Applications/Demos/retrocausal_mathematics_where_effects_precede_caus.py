#!/usr/bin/env python3
"""
Retrocausal Nucleus Theory — Demonstration

Numerical examples illustrating the key theorems:
1. The Chain3 Heyting algebra and LEM failure
2. Galois connections and the nucleus property
3. Temporal excluded middle
4. CPT involution
"""

from typing import Callable, TypeVar

# === Chain3 Heyting Algebra ===

class Chain3:
    """The three-element chain {bot, mid, top} as a Heyting algebra."""
    BOT, MID, TOP = 0, 1, 2
    NAMES = {0: "⊥", 1: "mid", 2: "⊤"}

    @staticmethod
    def le(a: int, b: int) -> bool:
        return a <= b

    @staticmethod
    def sup(a: int, b: int) -> int:
        return max(a, b)

    @staticmethod
    def inf(a: int, b: int) -> int:
        return min(a, b)

    @staticmethod
    def himp(a: int, b: int) -> int:
        """Heyting implication a ⇨ b = max{c | a ⊓ c ≤ b}"""
        if a == Chain3.BOT:
            return Chain3.TOP
        if a == Chain3.MID:
            return Chain3.TOP if b >= Chain3.MID else Chain3.BOT
        # a == TOP
        return b

    @staticmethod
    def compl(a: int) -> int:
        """Heyting negation ¬a = a ⇨ ⊥"""
        return Chain3.himp(a, Chain3.BOT)

    @staticmethod
    def name(a: int) -> str:
        return Chain3.NAMES[a]


def demo_chain3():
    """Demonstrate LEM failure and double negation elimination failure on Chain3."""
    print("=" * 60)
    print("Chain3 Heyting Algebra: LEM and DNE Failure")
    print("=" * 60)

    C = Chain3
    elements = [C.BOT, C.MID, C.TOP]

    print("\nHeyting implication table (a ⇨ b):")
    print("      ", "  ".join(f"{C.name(b):>3}" for b in elements))
    for a in elements:
        row = "  ".join(f"{C.name(C.himp(a, b)):>3}" for b in elements)
        print(f"  {C.name(a):>3}  {row}")

    print("\nNegation: ¬a = a ⇨ ⊥")
    for a in elements:
        print(f"  ¬{C.name(a)} = {C.name(C.compl(a))}")

    print("\nLaw of Excluded Middle: a ⊔ ¬a = ⊤ ?")
    for a in elements:
        result = C.sup(a, C.compl(a))
        holds = "✓" if result == C.TOP else "✗ FAILS"
        print(f"  {C.name(a)} ⊔ ¬{C.name(a)} = {C.name(result)}  {holds}")

    print("\nDouble Negation Elimination: ¬¬a = a ?")
    for a in elements:
        dne = C.compl(C.compl(a))
        holds = "✓" if dne == a else f"✗ (¬¬{C.name(a)} = {C.name(dne)})"
        print(f"  ¬¬{C.name(a)} = {C.name(dne)}  {holds}")


# === Galois Connection and Nucleus ===

def demo_galois_connection():
    """Demonstrate a retrocausal nucleus on the power set of {0,1,2}."""
    print("\n" + "=" * 60)
    print("Retrocausal Nucleus on P({0,1,2})")
    print("=" * 60)

    # Galois connection: T(S) = S ∩ {0,1} (projection), R(U) = U ∪ {2}
    # T preserves meets: T(A ∩ B) = (A ∩ B) ∩ {0,1} = (A ∩ {0,1}) ∩ (B ∩ {0,1}) = T(A) ∩ T(B)
    # j(S) = R(T(S)) = (S ∩ {0,1}) ∪ {2}

    def T(s: frozenset) -> frozenset:
        """Forward propagation: projection onto {0,1}"""
        return s & frozenset({0, 1})

    def R(s: frozenset) -> frozenset:
        """Backward propagation: R(U) = U ∪ {2}"""
        return s | frozenset({2})

    def j(s: frozenset) -> frozenset:
        """Retrocausal closure: R ∘ T"""
        return R(T(s))

    def show(s: frozenset) -> str:
        if not s:
            return "∅"
        return "{" + ",".join(str(x) for x in sorted(s)) + "}"

    # Verify Galois connection: T(a) ⊆ b ⟺ a ⊆ R(b)
    print("\nVerifying Galois connection T ⊣ R:")
    all_sets = [frozenset(s) for s in [set(), {0}, {1}, {2}, {0,1}, {0,2}, {1,2}, {0,1,2}]]
    gc_holds = True
    for a in all_sets:
        for b in all_sets:
            lhs = T(a).issubset(b)
            rhs = a.issubset(R(b))
            if lhs != rhs:
                gc_holds = False
                print(f"  FAILED: T({show(a)}) ⊆ {show(b)} is {lhs}, but {show(a)} ⊆ R({show(b)}) is {rhs}")
    if gc_holds:
        print("  ✓ Galois connection verified for all pairs")

    # Show nucleus property: j(a ∩ b) = j(a) ∩ j(b)
    print("\nNucleus property: j(a ∩ b) = j(a) ∩ j(b)")
    nucleus_holds = True
    for a in all_sets:
        for b in all_sets:
            lhs = j(a & b)
            rhs = j(a) & j(b)
            if lhs != rhs:
                nucleus_holds = False
                print(f"  FAILED: j({show(a)} ∩ {show(b)}) = {show(lhs)} ≠ {show(rhs)} = j({show(a)}) ∩ j({show(b)})")
    if nucleus_holds:
        print("  ✓ Nucleus property verified for all pairs")

    # Show fixed points
    print("\nFixed points of j (retrocausal completions):")
    for s in all_sets:
        js = j(s)
        fixed = "  ← fixed point" if js == s else f"  → j = {show(js)}"
        print(f"  j({show(s)}) = {show(js)}{fixed}")

    # Temporal coherence
    print("\nTemporal coherence: T∘R∘T = T")
    for s in all_sets:
        trt = T(R(T(s)))
        ts = T(s)
        status = "✓" if trt == ts else "✗"
        print(f"  T(R(T({show(s)}))) = {show(trt)}, T({show(s)}) = {show(ts)}  {status}")


# === Temporal Excluded Middle ===

def demo_temporal_em():
    """Demonstrate temporal excluded middle on a Boolean algebra."""
    print("\n" + "=" * 60)
    print("Temporal Excluded Middle")
    print("=" * 60)

    # Use P({0,1}) as a Boolean algebra
    universe = frozenset({0, 1})

    def T(s: frozenset) -> frozenset:
        """Simple forward propagation"""
        if 0 in s:
            return frozenset({0, 1})
        return s

    def R(s: frozenset) -> frozenset:
        """Right adjoint of T"""
        if frozenset({0, 1}).issubset(s):
            return frozenset({0, 1})
        if frozenset({1}).issubset(s):
            return frozenset({1})
        return frozenset()

    def j(s: frozenset) -> frozenset:
        return R(T(s))

    def complement(s: frozenset) -> frozenset:
        return universe - s

    def show(s: frozenset) -> str:
        if not s:
            return "∅"
        if s == universe:
            return "{0,1}"
        return "{" + ",".join(str(x) for x in sorted(s)) + "}"

    all_sets = [frozenset(), frozenset({0}), frozenset({1}), frozenset({0, 1})]

    print("\nj(a) ⊔ j(aᶜ) = ⊤ for all a:")
    for s in all_sets:
        sc = complement(s)
        js = j(s)
        jsc = j(sc)
        union = js | jsc
        status = "✓" if union == universe else "✗"
        print(f"  j({show(s)}) ⊔ j({show(sc)}) = {show(js)} ⊔ {show(jsc)} = {show(union)}  {status}")


# === CPT Involution ===

def demo_cpt():
    """Demonstrate CPT involution with commuting involutions on Z/2 × Z/2 × Z/2."""
    print("\n" + "=" * 60)
    print("CPT Involution on (Z/2)³")
    print("=" * 60)

    def C(a):
        return (1 - a[0], a[1], a[2])

    def P(a):
        return (a[0], 1 - a[1], a[2])

    def Tr(a):
        return (a[0], a[1], 1 - a[2])

    def CPT(a):
        return C(P(Tr(a)))

    def TPC(a):
        return Tr(P(C(a)))

    elements = [(i, j, k) for i in range(2) for j in range(2) for k in range(2)]

    print("\nVerifying involution properties:")
    for name, f in [("C", C), ("P", P), ("T", Tr)]:
        all_invol = all(f(f(a)) == a for a in elements)
        print(f"  {name} ∘ {name} = id: {'✓' if all_invol else '✗'}")

    print("\nVerifying commutativity:")
    for n1, f1, n2, f2 in [("C", C, "P", P), ("C", C, "T", Tr), ("P", P, "T", Tr)]:
        commutes = all(f1(f2(a)) == f2(f1(a)) for a in elements)
        print(f"  {n1} ∘ {n2} = {n2} ∘ {n1}: {'✓' if commutes else '✗'}")

    print("\nVerifying CPT ∘ CPT = id:")
    all_invol = all(CPT(CPT(a)) == a for a in elements)
    print(f"  CPT ∘ CPT = id: {'✓' if all_invol else '✗'}")

    print("\nVerifying CPT = TPC:")
    all_eq = all(CPT(a) == TPC(a) for a in elements)
    print(f"  CPT = TPC: {'✓' if all_eq else '✗'}")

    print("\nCPT action on each element:")
    for a in elements:
        print(f"  CPT{a} = {CPT(a)}")


if __name__ == "__main__":
    demo_chain3()
    demo_galois_connection()
    demo_temporal_em()
    demo_cpt()
    print("\n" + "=" * 60)
    print("All demonstrations completed successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Chain3 Heyting Algebra — LEM and DNE Failure

Produces a figure showing the Chain3 lattice, its Heyting implication table,
and the failure of LEM and double negation elimination.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def draw_chain3_lattice(ax):
    """Draw the Chain3 Hasse diagram."""
    ax.set_xlim(-1, 1)
    ax.set_ylim(-0.5, 2.5)
    ax.set_aspect('equal')
    ax.axis('off')
    ax.set_title('Chain3 Lattice', fontsize=14, fontweight='bold')

    # Nodes
    positions = {'⊥': (0, 0), 'mid': (0, 1), '⊤': (0, 2)}
    colors = {'⊥': '#4CAF50', 'mid': '#FF9800', '⊤': '#2196F3'}

    for name, (x, y) in positions.items():
        circle = plt.Circle((x, y), 0.15, color=colors[name], ec='black', lw=2, zorder=3)
        ax.add_patch(circle)
        ax.text(x, y, name, ha='center', va='center', fontsize=12, fontweight='bold',
                color='white', zorder=4)

    # Edges
    ax.plot([0, 0], [0.15, 0.85], 'k-', lw=2, zorder=1)
    ax.plot([0, 0], [1.15, 1.85], 'k-', lw=2, zorder=1)


def draw_himp_table(ax):
    """Draw the Heyting implication table."""
    ax.axis('off')
    ax.set_title('Heyting Implication (a ⇨ b)', fontsize=14, fontweight='bold')

    elements = ['⊥', 'mid', '⊤']
    table_data = [
        ['⊤', '⊤', '⊤'],    # ⊥ ⇨ _
        ['⊥', '⊤', '⊤'],    # mid ⇨ _
        ['⊥', 'mid', '⊤'],  # ⊤ ⇨ _
    ]

    colors_map = {'⊥': '#E8F5E9', 'mid': '#FFF3E0', '⊤': '#E3F2FD'}

    table = ax.table(
        cellText=table_data,
        rowLabels=[f'a={e}' for e in elements],
        colLabels=[f'b={e}' for e in elements],
        loc='center',
        cellLoc='center'
    )
    table.auto_set_font_size(False)
    table.set_fontsize(11)
    table.scale(1.2, 1.8)

    for (i, j), cell in table.get_celld().items():
        if i > 0 and j >= 0:
            val = table_data[i-1][j]
            cell.set_facecolor(colors_map.get(val, 'white'))


def draw_lem_failure(ax):
    """Visualize LEM and DNE failure."""
    ax.axis('off')
    ax.set_title('LEM and DNE Failure', fontsize=14, fontweight='bold')

    elements = ['⊥', 'mid', '⊤']
    negations = {'⊥': '⊤', 'mid': '⊥', '⊤': '⊥'}
    lem_results = {'⊥': '⊤', 'mid': 'mid', '⊤': '⊤'}  # a ⊔ ¬a
    dne_results = {'⊥': '⊥', 'mid': '⊤', '⊤': '⊤'}  # ¬¬a

    y_start = 0.9
    for i, a in enumerate(elements):
        y = y_start - i * 0.25
        neg_a = negations[a]
        lem = lem_results[a]
        dne = dne_results[a]

        lem_color = 'green' if lem == '⊤' else 'red'
        dne_color = 'green' if dne == a else 'red'

        ax.text(0.05, y, f'¬{a} = {neg_a}', fontsize=11, transform=ax.transAxes)
        ax.text(0.35, y, f'{a} ⊔ ¬{a} = {lem}',
                fontsize=11, color=lem_color, fontweight='bold', transform=ax.transAxes)
        ax.text(0.7, y, f'¬¬{a} = {dne}',
                fontsize=11, color=dne_color, fontweight='bold', transform=ax.transAxes)

    # Legend
    ax.text(0.05, 0.1, '• Green = classical (LEM/DNE holds)', fontsize=9,
            color='green', transform=ax.transAxes)
    ax.text(0.05, 0.02, '• Red = intuitionistic (LEM/DNE fails)', fontsize=9,
            color='red', transform=ax.transAxes)


def main():
    fig, axes = plt.subplots(1, 3, figsize=(16, 5))
    fig.suptitle('Retrocausal Nucleus Theory: Chain3 Counterexample',
                 fontsize=16, fontweight='bold', y=1.02)

    draw_chain3_lattice(axes[0])
    draw_himp_table(axes[1])
    draw_lem_failure(axes[2])

    plt.tight_layout()
    plt.savefig('chain3_visualization.png', dpi=150, bbox_inches='tight')
    plt.show()
    print("Saved to chain3_visualization.png")


if __name__ == "__main__":
    main()
