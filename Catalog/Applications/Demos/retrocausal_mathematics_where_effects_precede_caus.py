#!/usr/bin/env python3
"""
Retrocausal Mathematics: Numerical Demonstrations

Demonstrates the key results:
1. Three-element Heyting algebra and LEM failure
2. Temporal excluded middle on Boolean lattices
3. Galois connection → nucleus construction
4. CPT symmetry verification
5. Nucleus fixed-point enumeration
"""

from itertools import product
from typing import Callable

# ============================================================
# 1. Three-element Heyting algebra
# ============================================================

class Three:
    """The 3-element Heyting algebra: bot < mid < top."""
    BOT, MID, TOP = 0, 1, 2
    
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
        """Heyting implication: a ⇨ b = max{c | c ⊓ a ≤ b}."""
        if a <= b:
            return Three.TOP
        return b
    
    @staticmethod
    def compl(a: int) -> int:
        """Heyting complement: ¬a = a ⇨ ⊥."""
        return Three.himp(a, Three.BOT)

def demo_lem_failure():
    """Demonstrate that LEM fails in the 3-element chain."""
    print("=" * 60)
    print("1. LEM FAILURE IN 3-ELEMENT HEYTING ALGEBRA")
    print("=" * 60)
    
    names = {0: "⊥", 1: "mid", 2: "⊤"}
    
    print("\nHeyting implication table (a ⇨ b):")
    print("      ", "  ".join(f"{names[b]:>3}" for b in range(3)))
    for a in range(3):
        row = [Three.himp(a, b) for b in range(3)]
        print(f"  {names[a]:>3}", "  ".join(f"{names[r]:>3}" for r in row))
    
    print("\nLEM check: a ⊔ ¬a for each element:")
    for a in range(3):
        neg_a = Three.compl(a)
        lem = Three.sup(a, neg_a)
        status = "✓ LEM holds" if lem == Three.TOP else "✗ LEM FAILS"
        print(f"  {names[a]} ⊔ ¬{names[a]} = {names[a]} ⊔ {names[neg_a]} = {names[lem]}  {status}")
    
    print("\nDouble negation check:")
    for a in range(3):
        dbl = Three.compl(Three.compl(a))
        status = "= a" if dbl == a else f"≠ a (got {names[dbl]})"
        print(f"  ¬¬{names[a]} = {names[dbl]}  {status}")

# ============================================================
# 2. Temporal excluded middle on power set
# ============================================================

def demo_temporal_em():
    """Temporal EM on the power set of {0,1,2} with a Galois connection."""
    print("\n" + "=" * 60)
    print("2. TEMPORAL EXCLUDED MIDDLE")
    print("=" * 60)
    
    universe = frozenset({0, 1, 2})
    
    # Define a Galois connection: T maps to the down-closure under ≤
    # T(S) = {x | ∃ y ∈ S, x ≤ y}  (down-closure)
    # R(S) = {x | ∀ y ≤ x, y ∈ S}  (up-interior)
    def T(S: frozenset) -> frozenset:
        return frozenset(x for x in universe if any(x <= y for y in S))
    
    def R(S: frozenset) -> frozenset:
        return frozenset(x for x in universe if all(y in S for y in universe if y <= x))
    
    print(f"\nUniverse: {set(universe)}")
    print("T = down-closure, R = up-interior")
    
    # Verify Galois connection: T(a) ⊆ b ⟺ a ⊆ R(b)
    all_subsets = []
    for r in range(len(universe) + 1):
        from itertools import combinations
        for combo in combinations(universe, r):
            all_subsets.append(frozenset(combo))
    
    gc_holds = True
    for a in all_subsets:
        for b in all_subsets:
            lhs = T(a).issubset(b)
            rhs = a.issubset(R(b))
            if lhs != rhs:
                gc_holds = False
    print(f"Galois connection verified: {gc_holds}")
    
    # Temporal EM: R(T(S)) ∪ R(T(Sᶜ)) = universe
    print("\nTemporal EM check: R(T(S)) ∪ R(T(Sᶜ)) = U for all S:")
    for S in all_subsets:
        Sc = universe - S
        closure_S = R(T(S))
        closure_Sc = R(T(Sc))
        union = closure_S | closure_Sc
        status = "✓" if union == universe else "✗"
        print(f"  S={str(set(S)):>12}  □S={str(set(closure_S)):>12}  □Sᶜ={str(set(closure_Sc)):>12}  union={str(set(union)):>12}  {status}")

# ============================================================
# 3. CPT symmetry
# ============================================================

def demo_cpt():
    """Demonstrate CPT involutivity with commuting involutions."""
    print("\n" + "=" * 60)
    print("3. CPT SYMMETRY")
    print("=" * 60)
    
    # Work on {0,1,2,3}: C = swap(0,1), P = swap(2,3), T = swap(0,2)∘swap(1,3)
    def C(x): return {0: 1, 1: 0, 2: 2, 3: 3}[x]
    def P(x): return {0: 0, 1: 1, 2: 3, 3: 2}[x]
    def T(x): return {0: 2, 1: 3, 2: 0, 3: 1}[x]
    
    elements = [0, 1, 2, 3]
    
    # Verify involutions
    print("Involution check:")
    for name, f in [("C", C), ("P", P), ("T", T)]:
        is_invol = all(f(f(x)) == x for x in elements)
        print(f"  {name}∘{name} = id: {is_invol}")
    
    # Check commutativity
    print("\nCommutativity check:")
    for n1, f1, n2, f2 in [("C", C, "P", P), ("C", C, "T", T), ("P", P, "T", T)]:
        commutes = all(f1(f2(x)) == f2(f1(x)) for x in elements)
        print(f"  {n1}∘{n2} = {n2}∘{n1}: {commutes}")
    
    # CPT composition
    def CPT(x): return C(P(T(x)))
    def TPC(x): return T(P(C(x)))
    
    is_invol = all(CPT(CPT(x)) == x for x in elements)
    print(f"\nCPT is involution: {is_invol}")
    
    equals_tpc = all(CPT(x) == TPC(x) for x in elements)
    print(f"CPT = TPC: {equals_tpc}")
    
    print("\nCPT table:")
    for x in elements:
        print(f"  CPT({x}) = {CPT(x)},  TPC({x}) = {TPC(x)}")

# ============================================================
# 4. Nucleus enumeration on P(Fin(2))
# ============================================================

def demo_nucleus_enumeration():
    """Enumerate all nuclei on the power set of {0,1} and count fixed points."""
    print("\n" + "=" * 60)
    print("4. NUCLEUS ENUMERATION ON P({0,1})")
    print("=" * 60)
    
    universe = frozenset({0, 1})
    subsets = [frozenset(), frozenset({0}), frozenset({1}), universe]
    
    def is_nucleus(j: dict) -> bool:
        # Extensive: S ⊆ j(S)
        for S in subsets:
            if not S.issubset(j[S]):
                return False
        # Idempotent: j(j(S)) = j(S)
        for S in subsets:
            if j[j[S]] != j[S]:
                return False
        # Preserves meets: j(S ∩ T) = j(S) ∩ j(T)
        for S in subsets:
            for T_set in subsets:
                meet_input = S & T_set
                if j[meet_input] != j[S] & j[T_set]:
                    return False
        return True
    
    nuclei = []
    # Enumerate all functions j: subsets → subsets
    for values in product(subsets, repeat=4):
        j = dict(zip(subsets, values))
        if is_nucleus(j):
            fixed = [S for S in subsets if j[S] == S]
            nuclei.append((j, fixed))
    
    print(f"\nFound {len(nuclei)} nuclei on P({{0,1}}):")
    for i, (j, fixed) in enumerate(nuclei):
        j_str = {str(set(k)): str(set(v)) for k, v in j.items()}
        print(f"\n  Nucleus {i+1}:")
        for k, v in j_str.items():
            print(f"    j({k}) = {v}")
        print(f"    Fixed points ({len(fixed)}): {[str(set(s)) for s in fixed]}")
    
    max_fixed = max(len(fixed) for _, fixed in nuclei)
    bound = 2**(2-1) + 1  # 2^(n-1) + 1 for n=2
    print(f"\nMax fixed points found: {max_fixed}")
    print(f"Conjectured bound (2^(n-1)+1 = {bound}): {'Holds' if max_fixed <= bound else 'FAILS'}")

# ============================================================
# 5. S4 Modal Logic verification
# ============================================================

def demo_s4_axioms():
    """Verify S4 axioms for □ and ◇ on a concrete Galois connection."""
    print("\n" + "=" * 60)
    print("5. S4 MODAL AXIOMS VERIFICATION")
    print("=" * 60)
    
    # Work on the power set of {0,1,2} with a simple Galois connection
    universe = frozenset({0, 1, 2})
    all_subsets = []
    from itertools import combinations
    for r in range(4):
        for combo in combinations(universe, r):
            all_subsets.append(frozenset(combo))
    
    # T = down-closure, R = up-interior (same as before)
    def T(S):
        return frozenset(x for x in universe if any(x <= y for y in S))
    def R(S):
        return frozenset(x for x in universe if all(y in S for y in universe if y <= x))
    
    def box(S): return R(T(S))
    def diamond(S): return T(R(S))
    
    # S4 for □: □□ = □
    s4_box = all(box(box(S)) == box(S) for S in all_subsets)
    print(f"□□ = □ (S4 for box): {s4_box}")
    
    # S4 for ◇: ◇◇ = ◇
    s4_dia = all(diamond(diamond(S)) == diamond(S) for S in all_subsets)
    print(f"◇◇ = ◇ (S4 for diamond): {s4_dia}")
    
    # Extensiveness: S ⊆ □S
    ext = all(S.issubset(box(S)) for S in all_subsets)
    print(f"S ⊆ □S (extensiveness): {ext}")
    
    # Contractiveness: ◇S ⊆ S
    contr = all(diamond(S).issubset(S) for S in all_subsets)
    print(f"◇S ⊆ S (contractiveness): {contr}")
    
    # K axiom: □(S ∩ T) ⊆ □S ∩ □T
    k_axiom = all(box(S & T_set).issubset(box(S) & box(T_set))
                  for S in all_subsets for T_set in all_subsets)
    print(f"□(S∩T) ⊆ □S ∩ □T (K axiom): {k_axiom}")
    
    # Coherence: T∘R∘T = T and R∘T∘R = R
    left_coh = all(T(R(T(S))) == T(S) for S in all_subsets)
    right_coh = all(R(T(R(S))) == R(S) for S in all_subsets)
    print(f"T∘R∘T = T (left coherence): {left_coh}")
    print(f"R∘T∘R = R (right coherence): {right_coh}")

# ============================================================

if __name__ == "__main__":
    demo_lem_failure()
    demo_temporal_em()
    demo_cpt()
    demo_nucleus_enumeration()
    demo_s4_axioms()
    print("\n" + "=" * 60)
    print("All demonstrations complete.")


#!/usr/bin/env python3
"""Visualization: 3-element Heyting algebra and LEM failure."""
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np

fig, axes = plt.subplots(1, 3, figsize=(15, 5))

# 1. Hasse diagram of the 3-element chain
ax = axes[0]
ax.set_title("3-Element Chain\n(Retrocausal Fixed Points)", fontsize=12, fontweight='bold')
positions = {0: (0.5, 0.1), 1: (0.5, 0.5), 2: (0.5, 0.9)}
labels = {0: "⊥ (impossible)", 1: "mid (contingent)", 2: "⊤ (necessary)"}
colors = {0: '#e74c3c', 1: '#f39c12', 2: '#27ae60'}

for val, (x, y) in positions.items():
    ax.plot(x, y, 'o', markersize=20, color=colors[val], zorder=5)
    ax.annotate(labels[val], (x, y), textcoords="offset points",
                xytext=(60, 0), fontsize=10, va='center')

# Draw edges
ax.plot([0.5, 0.5], [0.1, 0.5], 'k-', linewidth=2)
ax.plot([0.5, 0.5], [0.5, 0.9], 'k-', linewidth=2)
ax.set_xlim(-0.1, 1.5)
ax.set_ylim(-0.05, 1.05)
ax.axis('off')

# 2. LEM failure visualization
ax = axes[1]
ax.set_title("Law of Excluded Middle\na ⊔ ¬a = ?", fontsize=12, fontweight='bold')

elements = ['⊥', 'mid', '⊤']
neg_vals = ['⊤', '⊥', '⊥']
lem_vals = ['⊤', 'mid', '⊤']
lem_holds = [True, False, True]

bar_colors = ['#27ae60' if h else '#e74c3c' for h in lem_holds]
bars = ax.bar(range(3), [2, 1, 2], color=bar_colors, alpha=0.7, edgecolor='black')

ax.set_xticks(range(3))
ax.set_xticklabels([f'a={e}\n¬a={n}\na⊔¬a={v}' for e, n, v in zip(elements, neg_vals, lem_vals)],
                   fontsize=9)
ax.set_yticks([0, 1, 2])
ax.set_yticklabels(['⊥', 'mid', '⊤'])
ax.axhline(y=2, color='gray', linestyle='--', alpha=0.5, label='⊤ (needed for LEM)')
ax.legend(fontsize=9)

# 3. Double negation failure
ax = axes[2]
ax.set_title("Double Negation\n¬¬a vs a", fontsize=12, fontweight='bold')

a_vals = [0, 1, 2]
dbl_neg = [0, 2, 2]  # ¬¬⊥=⊥, ¬¬mid=⊤, ¬¬⊤=⊤

x = np.arange(3)
width = 0.35
bars1 = ax.bar(x - width/2, a_vals, width, label='a', color='#3498db', alpha=0.7, edgecolor='black')
bars2 = ax.bar(x + width/2, dbl_neg, width, label='¬¬a', color='#e67e22', alpha=0.7, edgecolor='black')

ax.set_xticks(x)
ax.set_xticklabels(elements)
ax.set_yticks([0, 1, 2])
ax.set_yticklabels(['⊥', 'mid', '⊤'])
ax.legend(fontsize=10)

# Highlight mismatch
ax.annotate('≠', (1, 1.5), fontsize=16, ha='center', color='red', fontweight='bold')

plt.tight_layout()
plt.savefig('heyting_lem_failure.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: heyting_lem_failure.png")


#!/usr/bin/env python3
"""Visualization: S4 modal logic structure of temporal operators."""
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from itertools import combinations

# Setup
universe = frozenset({0, 1, 2})
subsets = []
for r in range(4):
    for combo in combinations(range(3), r):
        subsets.append(frozenset(combo))

def T(S):
    return frozenset(x for x in universe if any(x <= y for y in S))

def R(S):
    return frozenset(x for x in universe if all(y in S for y in universe if y <= x))

def box(S): return R(T(S))
def diamond(S): return T(R(S))

fig, axes = plt.subplots(2, 2, figsize=(12, 10))

# 1. Box operator: S → □S
ax = axes[0, 0]
ax.set_title("Box Operator □ = R∘T\n(Temporal Necessity)", fontsize=11, fontweight='bold')
for i, S in enumerate(subsets):
    bS = box(S)
    s_label = str(set(S)) if S else '∅'
    b_label = str(set(bS)) if bS else '∅'
    y = len(subsets) - i - 1
    ax.annotate('', xy=(3, y), xytext=(0.5, y),
                arrowprops=dict(arrowstyle='->', color='#3498db', lw=1.5))
    ax.text(0.2, y, s_label, ha='right', va='center', fontsize=8,
            bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow'))
    ax.text(3.3, y, b_label, ha='left', va='center', fontsize=8,
            bbox=dict(boxstyle='round,pad=0.3', 
                      facecolor='lightgreen' if S == bS else 'lightyellow'))
ax.set_xlim(-1, 5)
ax.set_ylim(-0.5, len(subsets))
ax.axis('off')

# 2. Diamond operator: S → ◇S
ax = axes[0, 1]
ax.set_title("Diamond Operator ◇ = T∘R\n(Temporal Possibility)", fontsize=11, fontweight='bold')
for i, S in enumerate(subsets):
    dS = diamond(S)
    s_label = str(set(S)) if S else '∅'
    d_label = str(set(dS)) if dS else '∅'
    y = len(subsets) - i - 1
    ax.annotate('', xy=(3, y), xytext=(0.5, y),
                arrowprops=dict(arrowstyle='->', color='#e74c3c', lw=1.5))
    ax.text(0.2, y, s_label, ha='right', va='center', fontsize=8,
            bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow'))
    ax.text(3.3, y, d_label, ha='left', va='center', fontsize=8,
            bbox=dict(boxstyle='round,pad=0.3',
                      facecolor='lightcoral' if S == dS else 'lightyellow'))
ax.set_xlim(-1, 5)
ax.set_ylim(-0.5, len(subsets))
ax.axis('off')

# 3. S4 axiom verification: □□ = □ and ◇◇ = ◇
ax = axes[1, 0]
ax.set_title("S4 Axiom Verification\n□□ = □ and ◇◇ = ◇", fontsize=11, fontweight='bold')

labels_list = [str(set(S)) if S else '∅' for S in subsets]
box_box_eq = [box(box(S)) == box(S) for S in subsets]
dia_dia_eq = [diamond(diamond(S)) == diamond(S) for S in subsets]

x = np.arange(len(subsets))
width = 0.35
colors_bb = ['#27ae60' if v else '#e74c3c' for v in box_box_eq]
colors_dd = ['#27ae60' if v else '#e74c3c' for v in dia_dia_eq]

ax.barh(x - width/2, [1]*len(subsets), width, color=colors_bb, alpha=0.7, label='□□=□')
ax.barh(x + width/2, [1]*len(subsets), width, color=colors_dd, alpha=0.7, label='◇◇=◇')
ax.set_yticks(x)
ax.set_yticklabels(labels_list, fontsize=8)
ax.set_xticks([])
ax.text(0.5, -1.5, f"□□=□: ALL PASS   ◇◇=◇: ALL PASS", 
        ha='center', fontsize=10, fontweight='bold', color='#27ae60')

# 4. Coherence laws
ax = axes[1, 1]
ax.set_title("Temporal Coherence Laws\nT∘R∘T = T and R∘T∘R = R", fontsize=11, fontweight='bold')

left_coh = [T(R(T(S))) == T(S) for S in subsets]
right_coh = [R(T(R(S))) == R(S) for S in subsets]

colors_l = ['#27ae60' if v else '#e74c3c' for v in left_coh]
colors_r = ['#27ae60' if v else '#e74c3c' for v in right_coh]

ax.barh(x - width/2, [1]*len(subsets), width, color=colors_l, alpha=0.7, label='T∘R∘T=T')
ax.barh(x + width/2, [1]*len(subsets), width, color=colors_r, alpha=0.7, label='R∘T∘R=R')
ax.set_yticks(x)
ax.set_yticklabels(labels_list, fontsize=8)
ax.set_xticks([])
ax.text(0.5, -1.5, f"Left coherence: ALL PASS   Right coherence: ALL PASS",
        ha='center', fontsize=10, fontweight='bold', color='#27ae60')

plt.tight_layout()
plt.savefig('s4_modal.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: s4_modal.png")


#!/usr/bin/env python3
"""Visualization: Temporal excluded middle vs propositional LEM failure."""
import matplotlib.pyplot as plt
import numpy as np
from itertools import combinations

# Setup: Galois connection on P({0,1,2})
universe = frozenset({0, 1, 2})
subsets = []
for r in range(4):
    for combo in combinations(range(3), r):
        subsets.append(frozenset(combo))

def T(S):
    return frozenset(x for x in universe if any(x <= y for y in S))

def R(S):
    return frozenset(x for x in universe if all(y in S for y in universe if y <= x))

def box(S):
    return R(T(S))

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# 1. Temporal EM: show R(T(S)) ∪ R(T(Sᶜ)) = U for all S
ax = axes[0]
ax.set_title("Temporal Excluded Middle\n□S ∪ □Sᶜ = U always holds", fontsize=12, fontweight='bold')

data = []
for i, S in enumerate(subsets):
    Sc = universe - S
    bS = box(S)
    bSc = box(Sc)
    union = bS | bSc
    data.append((str(set(S) if S else '∅'), len(bS), len(bSc), len(union)))

labels = [d[0] for d in data]
box_s = [d[1] for d in data]
box_sc = [d[2] for d in data]
unions = [d[3] for d in data]

x = np.arange(len(labels))
width = 0.25
ax.bar(x - width, box_s, width, label='|□S|', color='#3498db', alpha=0.7)
ax.bar(x, box_sc, width, label='|□Sᶜ|', color='#e74c3c', alpha=0.7)
ax.bar(x + width, unions, width, label='|□S ∪ □Sᶜ|', color='#27ae60', alpha=0.7)
ax.axhline(y=3, color='gray', linestyle='--', alpha=0.5, label='|U| = 3')
ax.set_xticks(x)
ax.set_xticklabels(labels, rotation=45, ha='right', fontsize=8)
ax.set_ylabel('Set size')
ax.legend(fontsize=9)

# 2. Fixed points and the nucleus
ax = axes[1]
ax.set_title("Nucleus Fixed Points\n□S = S (temporally stable propositions)", fontsize=12, fontweight='bold')

fixed = [(str(set(S) if S else '∅'), S == box(S)) for S in subsets]
colors = ['#27ae60' if f else '#e74c3c' for _, f in fixed]
bars = ax.barh(range(len(fixed)), [1]*len(fixed), color=colors, alpha=0.7, edgecolor='black')

ax.set_yticks(range(len(fixed)))
ax.set_yticklabels([f[0] for f in fixed], fontsize=9)
ax.set_xticks([])

legend_elements = [
    plt.Rectangle((0,0), 1, 1, facecolor='#27ae60', alpha=0.7, edgecolor='black', label='Fixed (□S = S)'),
    plt.Rectangle((0,0), 1, 1, facecolor='#e74c3c', alpha=0.7, edgecolor='black', label='Not fixed (□S ≠ S)')
]
ax.legend(handles=legend_elements, fontsize=9)

plt.tight_layout()
plt.savefig('temporal_em.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: temporal_em.png")
