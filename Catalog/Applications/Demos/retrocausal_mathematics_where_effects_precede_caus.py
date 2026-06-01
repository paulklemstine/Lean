#!/usr/bin/env python3
"""
Retrocausal Mathematics: Numerical Demonstrations

Demonstrates key theorems from the retrocausal logic framework:
1. Temporal Galois connections on finite lattices
2. Retrocausal closure operators and their fixed points
3. CPT symmetry and the reversal property
4. Temporal coherence laws
"""

import itertools
from typing import Callable, TypeVar

T = TypeVar("T")


def demo_galois_connection():
    """Demonstrate a temporal Galois connection on a power set lattice."""
    print("=" * 60)
    print("Demo 1: Temporal Galois Connection on P({0,1,2})")
    print("=" * 60)

    # Universe
    U = frozenset({0, 1, 2})

    # Forward propagation: add the successor element (mod 3)
    def T(s: frozenset) -> frozenset:
        return frozenset((x + 1) % 3 for x in s)

    # Backward propagation: add the predecessor element (mod 3)
    def R(s: frozenset) -> frozenset:
        return frozenset((x - 1) % 3 for x in s)

    # Verify Galois connection: T(a) ⊆ b iff a ⊆ R(b)
    all_subsets = []
    for r in range(len(U) + 1):
        for combo in itertools.combinations(U, r):
            all_subsets.append(frozenset(combo))

    gc_holds = True
    for a in all_subsets:
        for b in all_subsets:
            lhs = T(a).issubset(b)
            rhs = a.issubset(R(b))
            if lhs != rhs:
                gc_holds = False
                print(f"  FAIL: T({set(a)}) ⊆ {set(b)} is {lhs}, but {set(a)} ⊆ R({set(b)}) is {rhs}")

    print(f"\n  Galois connection verified: {gc_holds}")

    # Demonstrate closure and interior
    print("\n  Retrocausal Closure R∘T:")
    for s in sorted(all_subsets, key=lambda x: (len(x), sorted(x))):
        cl = R(T(s))
        print(f"    cl({set(s)}) = {set(cl)}")

    # Verify idempotency
    print("\n  Idempotency check (cl∘cl = cl):")
    idempotent = all(R(T(R(T(s)))) == R(T(s)) for s in all_subsets)
    print(f"    Idempotent: {idempotent}")

    # Fixed points
    fixed = [s for s in all_subsets if R(T(s)) == s]
    print(f"\n  Fixed points of closure: {[set(s) for s in fixed]}")

    # Temporal coherence
    print("\n  Temporal coherence T∘R∘T = T:")
    coherent_l = all(T(R(T(s))) == T(s) for s in all_subsets)
    print(f"    T∘R∘T = T: {coherent_l}")

    coherent_r = all(R(T(R(s))) == R(s) for s in all_subsets)
    print(f"    R∘T∘R = R: {coherent_r}")


def demo_temporal_excluded_middle():
    """Demonstrate the Temporal Excluded Middle on a Boolean algebra."""
    print("\n" + "=" * 60)
    print("Demo 2: Temporal Excluded Middle")
    print("=" * 60)

    U = frozenset({0, 1, 2, 3})

    # T shifts each element by 1 (mod 4)
    def T(s: frozenset) -> frozenset:
        return frozenset((x + 1) % 4 for x in s)

    def R(s: frozenset) -> frozenset:
        return frozenset((x - 1) % 4 for x in s)

    all_subsets = []
    for r in range(len(U) + 1):
        for combo in itertools.combinations(U, r):
            all_subsets.append(frozenset(combo))

    print("\n  Checking cl(a) ∪ cl(aᶜ) = U for all a:")
    tem_holds = True
    for a in all_subsets:
        a_comp = U - a
        cl_a = R(T(a))
        cl_comp = R(T(a_comp))
        union = cl_a | cl_comp
        if union != U:
            tem_holds = False
            print(f"    FAIL: a={set(a)}, cl(a)∪cl(aᶜ)={set(union)} ≠ U")

    print(f"  Temporal Excluded Middle holds: {tem_holds}")


def demo_cpt_symmetry():
    """Demonstrate CPT reversal and the counterexample to the iff."""
    print("\n" + "=" * 60)
    print("Demo 3: CPT Symmetry")
    print("=" * 60)

    n = 3

    # Counterexample: C = swap(0,1), P = swap(0,2), T = swap(0,1)
    def C(x: int) -> int:
        return {0: 1, 1: 0, 2: 2}[x]

    def P(x: int) -> int:
        return {0: 2, 1: 1, 2: 0}[x]

    def T_rev(x: int) -> int:
        return {0: 1, 1: 0, 2: 2}[x]

    # Check involutions
    print(f"\n  C is involution: {all(C(C(x)) == x for x in range(n))}")
    print(f"  P is involution: {all(P(P(x)) == x for x in range(n))}")
    print(f"  T is involution: {all(T_rev(T_rev(x)) == x for x in range(n))}")

    # CPT composition
    def CPT(x: int) -> int:
        return C(P(T_rev(x)))

    print(f"\n  CPT mapping: {[CPT(x) for x in range(n)]}")
    print(f"  CPT is involution: {all(CPT(CPT(x)) == x for x in range(n))}")

    # Check pairwise commutativity
    cp_commute = all(C(P(x)) == P(C(x)) for x in range(n))
    ct_commute = all(C(T_rev(x)) == T_rev(C(x)) for x in range(n))
    pt_commute = all(P(T_rev(x)) == T_rev(P(x)) for x in range(n))

    print(f"\n  C,P commute: {cp_commute}")
    print(f"  C,T commute: {ct_commute}")
    print(f"  P,T commute: {pt_commute}")

    # Reversal property: CPT = TPC
    def TPC(x: int) -> int:
        return T_rev(P(C(x)))

    reversal = all(CPT(x) == TPC(x) for x in range(n))
    print(f"\n  CPT reversal (CPT = TPC): {reversal}")

    # Commuting example
    print("\n  --- Commuting example ---")

    def C2(x: int) -> int:
        return {0: 1, 1: 0, 2: 2}[x]

    def P2(x: int) -> int:
        return {0: 0, 1: 2, 2: 1}[x]

    def T2(x: int) -> int:
        return {0: 0, 1: 1, 2: 2}[x]  # identity

    cp2 = all(C2(P2(x)) == P2(C2(x)) for x in range(n))
    ct2 = all(C2(T2(x)) == T2(C2(x)) for x in range(n))
    pt2 = all(P2(T2(x)) == T2(P2(x)) for x in range(n))
    cpt2_invol = all(C2(P2(T2(C2(P2(T2(x)))))) == x for x in range(n))

    print(f"  All commute: {cp2 and ct2 and pt2}")
    print(f"  CPT is involution: {cpt2_invol}")


def demo_kripke_frame():
    """Demonstrate a retrocausal Kripke frame with 3 worlds."""
    print("\n" + "=" * 60)
    print("Demo 4: Retrocausal Kripke Frame")
    print("=" * 60)

    worlds = ["past", "present", "future"]

    # Linear order: past ≤ present ≤ future
    order = {
        (0, 0), (0, 1), (0, 2),
        (1, 1), (1, 2),
        (2, 2),
    }

    # Retrocausal access: future can influence past
    access = {(0, 2)}  # past ← future

    print(f"\n  Worlds: {worlds}")
    print(f"  Order: {', '.join(f'{worlds[i]}≤{worlds[j]}' for i, j in sorted(order) if i != j)}")
    print(f"  Retrocausal access: {', '.join(f'{worlds[j]}→{worlds[i]}' for i, j in access)}")

    # Upward-closed sets (intuitionistic propositions)
    upward_closed = []
    for r in range(4):
        for combo in itertools.combinations(range(3), r):
            s = set(combo)
            is_up = all(
                (j in s) for i in s for j in range(3) if (i, j) in order
            )
            if is_up:
                upward_closed.append(s)

    print(f"\n  Upward-closed sets (intuitionistic propositions):")
    for s in upward_closed:
        name = "{" + ", ".join(worlds[i] for i in sorted(s)) + "}" if s else "∅"
        comp = set(range(3)) - s
        comp_name = "{" + ", ".join(worlds[i] for i in sorted(comp)) + "}" if comp else "∅"
        trivial = s == set() or s == set(range(3))
        lem = s == set(range(3)) or comp == set(range(3))
        print(f"    {name:30s} complement: {comp_name:30s} trivial: {trivial}")

    # The set {present, future} is upward-closed, non-trivial, with non-trivial complement
    S = {1, 2}
    print(f"\n  Proposition {{present, future}}:")
    print(f"    Non-trivial: {S != set() and S != set(range(3))}")
    print(f"    Complement non-trivial: {(set(range(3)) - S) != set() and (set(range(3)) - S) != set(range(3))}")
    print(f"    → Classical LEM fails: neither S nor Sᶜ covers all worlds")


def demo_closure_properties():
    """Demonstrate closure operator properties on a concrete lattice."""
    print("\n" + "=" * 60)
    print("Demo 5: Closure Operator Properties")
    print("=" * 60)

    # Divisibility lattice on {1, 2, 3, 6}
    # Order: a | b
    elements = [1, 2, 3, 6]

    def divides(a, b):
        return b % a == 0

    # T: multiply by 2 (capped at 6)
    def T(a):
        return min(2 * a, 6)

    # R: divide by 2 (floor, minimum 1)
    def R(a):
        return max(a // 2, 1)

    # Check if this is a Galois connection
    print("\n  Elements: {1, 2, 3, 6} with divisibility order")
    print(f"  T(a) = min(2a, 6): {[T(a) for a in elements]}")
    print(f"  R(a) = max(⌊a/2⌋, 1): {[R(a) for a in elements]}")

    # Closure R∘T
    print("\n  Retrocausal closure R(T(a)):")
    for a in elements:
        cl = R(T(a))
        cl2 = R(T(cl))
        print(f"    cl({a}) = {cl}, cl(cl({a})) = {cl2}, idempotent: {cl == cl2}")

    # Verify coherence
    print("\n  Temporal coherence:")
    for a in elements:
        trt = T(R(T(a)))
        t_a = T(a)
        rtr = R(T(R(a)))
        r_a = R(a)
        print(f"    T(R(T({a})))={trt}, T({a})={t_a}, equal: {trt == t_a}")
        print(f"    R(T(R({a})))={rtr}, R({a})={r_a}, equal: {rtr == r_a}")


if __name__ == "__main__":
    demo_galois_connection()
    demo_temporal_excluded_middle()
    demo_cpt_symmetry()
    demo_kripke_frame()
    demo_closure_properties()
    print("\n" + "=" * 60)
    print("All demonstrations complete.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Retrocausal Closure Operator on Power Set Lattice

Shows how the closure operator R∘T maps each element of a power set lattice
to its closure, highlighting fixed points and the temporal excluded middle.
"""

import itertools

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def powerset(universe):
    """Generate all subsets of universe."""
    result = []
    for r in range(len(universe) + 1):
        for combo in itertools.combinations(sorted(universe), r):
            result.append(frozenset(combo))
    return result


def hasse_positions(n):
    """Compute positions for elements of P({0,...,n-1}) in a Hasse diagram."""
    elements = powerset(range(n))
    positions = {}
    by_size = {}
    for s in elements:
        sz = len(s)
        if sz not in by_size:
            by_size[sz] = []
        by_size[sz].append(s)

    for sz, elems in by_size.items():
        count = len(elems)
        for i, s in enumerate(sorted(elems, key=lambda x: sorted(x))):
            x = (i - (count - 1) / 2) * 1.5
            y = sz * 1.5
            positions[s] = (x, y)
    return elements, positions


def main():
    n = 3
    U = frozenset(range(n))

    # Forward: shift by 1 mod n
    def T(s):
        return frozenset((x + 1) % n for x in s)

    # Backward: shift by -1 mod n
    def R(s):
        return frozenset((x - 1) % n for x in s)

    elements, positions = hasse_positions(n)
    closure = {s: R(T(s)) for s in elements}
    fixed = {s for s in elements if closure[s] == s}

    fig, axes = plt.subplots(1, 2, figsize=(16, 8))

    for ax_idx, ax in enumerate(axes):
        ax.set_aspect("equal")
        ax.set_title(
            "Retrocausal Closure on P({0,1,2})" if ax_idx == 0
            else "Fixed Points & Temporal EM",
            fontsize=14, fontweight="bold"
        )

        # Draw Hasse edges
        for s1 in elements:
            for s2 in elements:
                if s1 < s2 and len(s2) - len(s1) == 1:
                    x1, y1 = positions[s1]
                    x2, y2 = positions[s2]
                    ax.plot([x1, x2], [y1, y2], "k-", alpha=0.3, linewidth=0.8)

        if ax_idx == 0:
            # Draw closure arrows
            for s in elements:
                if closure[s] != s:
                    x1, y1 = positions[s]
                    x2, y2 = positions[closure[s]]
                    ax.annotate(
                        "", xy=(x2, y2), xytext=(x1, y1),
                        arrowprops=dict(arrowstyle="->", color="red", lw=1.5, alpha=0.7),
                    )

            for s in elements:
                x, y = positions[s]
                color = "gold" if s in fixed else "lightblue"
                label = "{" + ",".join(str(x) for x in sorted(s)) + "}" if s else "∅"
                ax.plot(x, y, "o", markersize=25, color=color, markeredgecolor="black")
                ax.text(x, y, label, ha="center", va="center", fontsize=7)

            legend_elements = [
                mpatches.Patch(facecolor="gold", edgecolor="black", label="Fixed point"),
                mpatches.Patch(facecolor="lightblue", edgecolor="black", label="Non-fixed"),
                mpatches.FancyArrowPatch((0, 0), (1, 0), arrowstyle="->", color="red",
                                         label="Closure map"),
            ]
            ax.legend(handles=legend_elements[:2], loc="upper left", fontsize=9)

        else:
            # Temporal Excluded Middle visualization
            # Pick a = {0}
            a = frozenset({0})
            a_comp = U - a
            cl_a = closure[a]
            cl_comp = closure[a_comp]

            for s in elements:
                x, y = positions[s]
                if s == cl_a and s == cl_comp:
                    color = "purple"
                elif s <= cl_a:
                    color = "blue"
                elif s <= cl_comp:
                    color = "red"
                else:
                    color = "lightgray"
                label = "{" + ",".join(str(x) for x in sorted(s)) + "}" if s else "∅"
                ax.plot(x, y, "o", markersize=25, color=color, markeredgecolor="black",
                        alpha=0.7)
                ax.text(x, y, label, ha="center", va="center", fontsize=7)

            a_label = "{" + ",".join(str(x) for x in sorted(a)) + "}"
            ax.text(0, -1, f"a = {a_label}\ncl(a) ∪ cl(aᶜ) = U  ✓",
                    ha="center", fontsize=10, style="italic")

        ax.set_xlim(-3, 3)
        ax.set_ylim(-1.5, 5.5)
        ax.axis("off")

    plt.tight_layout()
    plt.savefig("retrocausal_closure.png", dpi=150, bbox_inches="tight")
    plt.close()
    print("Saved retrocausal_closure.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: CPT Symmetry and Defect Analysis

Shows the CPT composition on finite sets, the reversal property,
and the commutativity defect for all CPT triples.
"""

import itertools
from typing import List, Optional, Tuple

import matplotlib.pyplot as plt
import numpy as np


def generate_involutions(n: int) -> List[List[int]]:
    """Generate all involutions (self-inverse permutations) on {0,...,n-1}."""
    result: List[List[int]] = []

    def backtrack(perm: List[Optional[int]], pos: int):
        if pos == n:
            result.append(list(perm))  # type: ignore
            return
        if perm[pos] is not None:
            backtrack(perm, pos + 1)
            return
        perm[pos] = pos
        backtrack(perm, pos + 1)
        perm[pos] = None
        for j in range(pos + 1, n):
            if perm[j] is None:
                perm[pos] = j
                perm[j] = pos
                backtrack(perm, pos + 1)
                perm[pos] = None
                perm[j] = None

    backtrack([None] * n, 0)
    return result


def compose(f: List[int], g: List[int]) -> List[int]:
    """Compose permutations: (f∘g)(x) = f(g(x))."""
    return [f[g[x]] for x in range(len(f))]


def is_involution(perm: List[int]) -> bool:
    """Check if a permutation is an involution."""
    return all(perm[perm[x]] == x for x in range(len(perm)))


def commutativity_defect(f: List[int], g: List[int]) -> int:
    """Count points where f∘g ≠ g∘f."""
    n = len(f)
    return sum(1 for x in range(n) if f[g[x]] != g[f[x]])


def main():
    fig, axes = plt.subplots(1, 3, figsize=(18, 6))

    # Panel 1: CPT on Fin 3 (counterexample)
    ax = axes[0]
    ax.set_title("CPT on {0,1,2}: Non-commuting Involution", fontsize=12, fontweight="bold")

    c = [1, 0, 2]  # swap(0,1)
    p = [2, 1, 0]  # swap(0,2)
    t = [1, 0, 2]  # swap(0,1)
    cpt = compose(c, compose(p, t))
    tpc = compose(t, compose(p, c))

    theta = np.linspace(0, 2 * np.pi, 4)[:-1]
    points = np.column_stack([np.cos(theta + np.pi / 2), np.sin(theta + np.pi / 2)])

    for i in range(3):
        ax.plot(*points[i], "ko", markersize=20, zorder=5)
        ax.text(points[i][0], points[i][1] + 0.15, str(i), ha="center", va="bottom",
                fontsize=14, fontweight="bold")

    for i in range(3):
        j = cpt[i]
        if i != j:
            ax.annotate("", xy=points[j] * 0.85, xytext=points[i] * 0.85,
                         arrowprops=dict(arrowstyle="->", color="red", lw=2))

    ax.text(0, -1.3, f"C = swap(0,1), P = swap(0,2), T = swap(0,1)\n"
                       f"CPT = {cpt} (= swap(1,2))\n"
                       f"CPT = TPC: {cpt == tpc} ✓\n"
                       f"C,P commute: {commutativity_defect(c, p) == 0} ✗",
            ha="center", fontsize=9, family="monospace",
            bbox=dict(boxstyle="round", facecolor="lightyellow"))

    ax.set_xlim(-1.5, 1.5)
    ax.set_ylim(-2, 1.5)
    ax.set_aspect("equal")
    ax.axis("off")

    # Panel 2: Defect histogram for n=4
    ax = axes[1]
    n = 4
    involutions = generate_involutions(n)
    defects = []
    for c_perm in involutions:
        for p_perm in involutions:
            for t_perm in involutions:
                cpt_comp = compose(c_perm, compose(p_perm, t_perm))
                if is_involution(cpt_comp):
                    d = (commutativity_defect(c_perm, p_perm) +
                         commutativity_defect(c_perm, t_perm) +
                         commutativity_defect(p_perm, t_perm))
                    defects.append(d)

    ax.hist(defects, bins=range(max(defects) + 2), color="steelblue",
            edgecolor="black", alpha=0.8, align="left")
    ax.axvline(x=2 * n - 2, color="red", linestyle="--", linewidth=2,
               label=f"Conjectured bound 2n−2 = {2*n-2}")
    ax.set_xlabel("Commutativity Defect", fontsize=11)
    ax.set_ylabel("Count", fontsize=11)
    ax.set_title(f"CPT Defect Distribution (n={n})", fontsize=12, fontweight="bold")
    ax.legend(fontsize=9)

    # Panel 3: Reversal property verification
    ax = axes[2]
    sizes = [2, 3, 4, 5]
    reversal_rates = []
    total_triples_list = []

    for n in sizes:
        invols = generate_involutions(n)
        total = 0
        reversal_count = 0
        for c_perm in invols:
            for p_perm in invols:
                for t_perm in invols:
                    cpt_comp = compose(c_perm, compose(p_perm, t_perm))
                    if is_involution(cpt_comp):
                        total += 1
                        tpc_comp = compose(t_perm, compose(p_perm, c_perm))
                        if cpt_comp == tpc_comp:
                            reversal_count += 1
        reversal_rates.append(reversal_count / total if total > 0 else 0)
        total_triples_list.append(total)

    bars = ax.bar(range(len(sizes)), reversal_rates, color="forestgreen",
                  edgecolor="black", alpha=0.8)
    ax.set_xticks(range(len(sizes)))
    ax.set_xticklabels([f"n={s}" for s in sizes])
    ax.set_ylabel("Fraction satisfying CPT = TPC", fontsize=11)
    ax.set_title("CPT Reversal Property\n(among involutive CPT triples)", fontsize=12,
                 fontweight="bold")
    ax.set_ylim(0, 1.15)
    ax.axhline(y=1.0, color="red", linestyle="--", alpha=0.5, label="100%")

    for bar, rate, total in zip(bars, reversal_rates, total_triples_list):
        ax.text(bar.get_x() + bar.get_width() / 2, bar.get_height() + 0.03,
                f"{rate:.0%}\n({total} triples)", ha="center", fontsize=8)
    ax.legend(fontsize=9)

    plt.tight_layout()
    plt.savefig("cpt_symmetry.png", dpi=150, bbox_inches="tight")
    plt.close()
    print("Saved cpt_symmetry.png")


if __name__ == "__main__":
    main()
