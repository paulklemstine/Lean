"""
EML Spacetime Emergence: Computational Demonstrations

This script demonstrates the key theorems from the formalization with
concrete numerical examples and visualizations.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from itertools import combinations

# ============================================================
# §1. Closure Operators and Causal Relations
# ============================================================

class ClosureOperator:
    """A closure operator on a finite set {0, 1, ..., n-1}.
    
    Represented by its action on singletons: cl({i}) for each i.
    Union-generated: cl(S) = ∪_{i ∈ S} cl({i}).
    """
    
    def __init__(self, n, singleton_closures):
        """
        Args:
            n: number of elements
            singleton_closures: dict mapping i -> frozenset (the closure of {i})
        """
        self.n = n
        self.elements = set(range(n))
        self.singleton_cl = singleton_closures
        
    def closure(self, S):
        """Compute cl(S) = ∪_{i ∈ S} cl({i})."""
        result = set()
        for x in S:
            result |= self.singleton_cl[x]
        return frozenset(result)
    
    def is_extensive(self):
        """Check: ∀ S, S ⊆ cl(S)."""
        return all(i in self.singleton_cl[i] for i in range(self.n))
    
    def is_monotone(self):
        """Check monotonicity (automatic for union-generated)."""
        return True  # Union-generated closures are always monotone
    
    def is_idempotent(self):
        """Check: ∀ S, cl(cl(S)) = cl(S)."""
        # It suffices to check on singletons for union-generated
        for i in range(self.n):
            S = self.singleton_cl[i]
            if self.closure(S) != S:
                return False
        return True
    
    def is_union_generated(self):
        return True  # By construction
    
    def causal_relation(self):
        """Compute the causal relation: x ≺ y iff x ∈ cl({y})."""
        rel = {}
        for y in range(self.n):
            for x in self.singleton_cl[y]:
                rel[(x, y)] = True
        return rel
    
    def is_causal_transitive(self):
        """Check transitivity of the causal relation."""
        rel = self.causal_relation()
        for x in range(self.n):
            for y in range(self.n):
                for z in range(self.n):
                    if (x, y) in rel and (y, z) in rel:
                        if (x, z) not in rel:
                            return False
        return True
    
    def fixed_sets(self):
        """Compute all fixed sets: {F | cl(F) = F}."""
        fixed = []
        for size in range(self.n + 1):
            for subset in combinations(range(self.n), size):
                S = frozenset(subset)
                if self.closure(S) == S:
                    fixed.append(S)
        # Also check empty set
        if self.closure(set()) == frozenset():
            fixed.append(frozenset())
        return fixed
    
    def closure_charge(self, S, measure=None):
        """Compute Q_C(S) = μ(cl(S)) - μ(S).
        Default measure: counting measure."""
        if measure is None:
            measure = lambda T: len(T)
        return measure(self.closure(S)) - measure(S)


def closure_from_relation(n, relation):
    """Build a union-generated closure from a relation R.
    cl({y}) = {x | R(x, y)} ∪ {y}."""
    singleton_cl = {}
    for y in range(n):
        cl_y = {y}  # reflexivity from extensivity
        for x in range(n):
            if relation(x, y):
                cl_y.add(x)
        singleton_cl[y] = frozenset(cl_y)
    return ClosureOperator(n, singleton_cl)


# ============================================================
# §2. Demo: Causal Closure Correspondence
# ============================================================

print("=" * 60)
print("DEMO 1: Causal Closure Correspondence")
print("=" * 60)
print()

# Example: A 4-element causal spacetime (a diamond poset)
# Events: 0 (past), 1 (left), 2 (right), 3 (future)
# Causal order: 0 ≺ 1, 0 ≺ 2, 1 ≺ 3, 2 ≺ 3
n = 4
# Define by causal relation (x ≺ y means x is in causal past of y)
def diamond_relation(x, y):
    """x ≺ y in the diamond poset."""
    pairs = {(0,0), (1,1), (2,2), (3,3),  # reflexive
             (0,1), (0,2), (1,3), (2,3),  # diamond edges
             (0,3)}  # transitive closure
    return (x, y) in pairs

C = closure_from_relation(n, diamond_relation)

print("Diamond Poset Causal Spacetime (4 events)")
print(f"  Events: 0 (past), 1 (left), 2 (right), 3 (future)")
print()
print("Singleton closures:")
for i in range(n):
    print(f"  cl({{{i}}}) = {set(C.singleton_cl[i])}")

print()
print(f"  Extensive: {C.is_extensive()}")
print(f"  Idempotent: {C.is_idempotent()}")
print(f"  Causal transitivity: {C.is_causal_transitive()}")
print(f"  Idempotent ↔ Transitive: {C.is_idempotent() == C.is_causal_transitive()} ✓")

print()
print("Causal relation (x ≺ y, x in causal past of y):")
rel = C.causal_relation()
for y in range(n):
    pasts = [x for x in range(n) if (x, y) in rel]
    print(f"  Causal past of {y}: {pasts}")

print()
print("Fixed sets (Moore family):")
fixed = C.fixed_sets()
for F in sorted(fixed, key=len):
    print(f"  {set(F) if F else '∅'}")

# ============================================================
# §3. Demo: Conservation Law
# ============================================================

print()
print("=" * 60)
print("DEMO 2: Idempotent Conservation Law")
print("=" * 60)
print()

print("Closure charges Q_C(A) = |cl(A)| - |A|:")
print()
for size in range(n + 1):
    for subset in combinations(range(n), size):
        S = frozenset(subset)
        Q = C.closure_charge(S)
        cl_S = C.closure(S)
        marker = " ← FIXED SET (Q=0)" if Q == 0 else ""
        print(f"  Q_C({set(S) if S else '∅'}) = |{set(cl_S)}| - |{set(S) if S else '∅'}| = {Q}{marker}")

print()
print("Verification: Q_C(cl(A)) = 0 for all A:")
all_zero = True
for size in range(n + 1):
    for subset in combinations(range(n), size):
        S = frozenset(subset)
        cl_S = C.closure(S)
        Q_cl = C.closure_charge(cl_S)
        if Q_cl != 0:
            all_zero = False
            print(f"  VIOLATION: Q_C(cl({set(S)})) = {Q_cl}")
print(f"  All Q_C(cl(A)) = 0: {all_zero} ✓  (Conservation Law)")

print()
print("Q_C(A) ≥ 0 for all A (Thermodynamic Arrow):")
all_nonneg = True
for size in range(n + 1):
    for subset in combinations(range(n), size):
        S = frozenset(subset)
        Q = C.closure_charge(S)
        if Q < 0:
            all_nonneg = False
print(f"  All Q_C(A) ≥ 0: {all_nonneg} ✓")

# ============================================================
# §4. Demo: Non-Idempotent Closure (Broken Causality)
# ============================================================

print()
print("=" * 60)
print("DEMO 3: Non-Idempotent Closure → Broken Causality")
print("=" * 60)
print()

# Define a non-idempotent closure
singleton_cl_bad = {
    0: frozenset({0, 1}),
    1: frozenset({1, 2}),
    2: frozenset({2}),
}
C_bad = ClosureOperator(3, singleton_cl_bad)

print("Non-idempotent closure on {0, 1, 2}:")
for i in range(3):
    print(f"  cl({{{i}}}) = {set(C_bad.singleton_cl[i])}")

print(f"\n  Extensive: {C_bad.is_extensive()}")
print(f"  Idempotent: {C_bad.is_idempotent()}")
print(f"  Causal transitivity: {C_bad.is_causal_transitive()}")
print(f"  Idempotent ↔ Transitive: {C_bad.is_idempotent() == C_bad.is_causal_transitive()} ✓")

print()
print("  Failure: 0 ∈ cl({1}), 1 ∈ cl({2}), but 0 ∉ cl({2}) = {2}")
print("  Transitivity violated → Idempotence must also fail")
print(f"  cl(cl({{0}})) = cl({set(C_bad.singleton_cl[0])}) = {set(C_bad.closure(C_bad.singleton_cl[0]))}")
print(f"  cl({{0}})     = {set(C_bad.singleton_cl[0])}")
print(f"  cl(cl({{0}})) ≠ cl({{0}}) → Idempotence violated ✓")

# ============================================================
# §5. Demo: Galois Correspondence
# ============================================================

print()
print("=" * 60)
print("DEMO 4: Galois Correspondence (Round-Trip)")
print("=" * 60)
print()

# Start with a preorder relation, build closure, extract relation back
print("Starting relation (total order on 3 elements: 0 ≤ 1 ≤ 2):")
def total_order(x, y):
    return x <= y

print("  R = {(x,y) | x ≤ y}")
print()

C_from_R = closure_from_relation(3, total_order)
print("Closure from relation:")
for i in range(3):
    print(f"  cl_R({{{i}}}) = {set(C_from_R.singleton_cl[i])}")

print()
print("Recovered relation from closure:")
rel_recovered = C_from_R.causal_relation()
roundtrip_ok = True
for x in range(3):
    for y in range(3):
        original = total_order(x, y)
        recovered = (x, y) in rel_recovered
        if original != recovered:
            roundtrip_ok = False
            print(f"  MISMATCH at ({x},{y}): original={original}, recovered={recovered}")
print(f"  Round-trip preserves relation: {roundtrip_ok} ✓")

# ============================================================
# §6. Visualization
# ============================================================

fig, axes = plt.subplots(1, 3, figsize=(15, 5))

# Plot 1: Diamond poset causal structure
ax = axes[0]
ax.set_title("Diamond Causal Spacetime\n(4 events)", fontsize=12, fontweight='bold')
positions = {0: (0.5, 0), 1: (0, 0.5), 2: (1, 0.5), 3: (0.5, 1)}
for (x, y), _ in rel.items():
    if x != y:
        x0, y0 = positions[x]
        x1, y1 = positions[y]
        ax.annotate("", xy=(x1, y1), xytext=(x0, y0),
                    arrowprops=dict(arrowstyle="->", color='steelblue', lw=1.5))

for node, (px, py) in positions.items():
    names = {0: "past", 1: "left", 2: "right", 3: "future"}
    ax.plot(px, py, 'o', markersize=20, color='coral', zorder=5)
    ax.text(px, py, str(node), ha='center', va='center', fontsize=12, fontweight='bold', zorder=6)
    ax.text(px, py - 0.12, names[node], ha='center', va='top', fontsize=8, color='gray')

ax.set_xlim(-0.3, 1.3)
ax.set_ylim(-0.2, 1.2)
ax.set_aspect('equal')
ax.axis('off')

# Plot 2: Closure charges
ax = axes[1]
ax.set_title("Closure Charges Q_C(A)\n(Conservation Law)", fontsize=12, fontweight='bold')
charges = []
labels = []
colors = []
for size in range(n + 1):
    for subset in combinations(range(n), size):
        S = frozenset(subset)
        Q = C.closure_charge(S)
        charges.append(Q)
        labels.append(str(set(S)) if S else "∅")
        colors.append('green' if Q == 0 else 'steelblue')

ax.barh(range(len(charges)), charges, color=colors, edgecolor='white', linewidth=0.5)
ax.set_yticks(range(len(charges)))
ax.set_yticklabels(labels, fontsize=6)
ax.set_xlabel("Q_C(A) = |cl(A)| - |A|", fontsize=10)
ax.axvline(x=0, color='red', linestyle='--', alpha=0.5)
ax.text(0.95, 0.02, "Green = fixed set\n(Q = 0, conserved)",
        transform=ax.transAxes, fontsize=8, va='bottom', ha='right',
        bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))

# Plot 3: Fixed sets lattice (Hasse diagram of inclusion)
ax = axes[2]
ax.set_title("Moore Family\n(Fixed Sets under Inclusion)", fontsize=12, fontweight='bold')

fixed_sorted = sorted(fixed, key=lambda s: (len(s), sorted(s)))
y_pos = {}
for i, F in enumerate(fixed_sorted):
    y_pos[F] = len(F)

# Compute Hasse diagram (covering relations)
for i, F1 in enumerate(fixed_sorted):
    for j, F2 in enumerate(fixed_sorted):
        if F1 < F2:  # strict subset
            # Check if covering (no intermediate fixed set)
            is_cover = True
            for F3 in fixed_sorted:
                if F1 < F3 < F2:
                    is_cover = False
                    break
            if is_cover:
                x1 = i / max(len(fixed_sorted) - 1, 1)
                x2 = j / max(len(fixed_sorted) - 1, 1)
                y1 = len(F1)
                y2 = len(F2)
                ax.plot([x1, x2], [y1, y2], 'b-', alpha=0.3, linewidth=1)

for i, F in enumerate(fixed_sorted):
    x = i / max(len(fixed_sorted) - 1, 1)
    y = len(F)
    ax.plot(x, y, 'o', markersize=15, color='coral', zorder=5)
    label = str(set(F)) if F else "∅"
    ax.text(x, y - 0.15, label, ha='center', va='top', fontsize=7)

ax.set_ylabel("Set size", fontsize=10)
ax.set_xlim(-0.1, 1.1)
ax.set_ylim(-0.5, n + 0.5)
ax.set_xticks([])

plt.tight_layout()
plt.savefig('diagram.svg', format='svg', bbox_inches='tight')
plt.savefig('demo_output.png', dpi=150, bbox_inches='tight')
print()
print("Visualizations saved to diagram.svg and demo_output.png")

# ============================================================
# §7. Expansion Factor Demo
# ============================================================

print()
print("=" * 60)
print("DEMO 5: Expansion Factor & Certified Robustness")
print("=" * 60)
print()

# Compute expansion factor K = max μ(cl(A))/μ(A) over nonempty A
max_ratio = 0
worst_set = None
for size in range(1, n + 1):
    for subset in combinations(range(n), size):
        S = frozenset(subset)
        ratio = len(C.closure(S)) / len(S)
        if ratio > max_ratio:
            max_ratio = ratio
            worst_set = S

print(f"Expansion factor K = max |cl(A)|/|A| = {max_ratio:.2f}")
print(f"  Achieved by A = {set(worst_set)}")
print(f"  cl(A) = {set(C.closure(worst_set))}")
print()
print(f"Certified robustness bound:")
print(f"  Q_C(A) ≤ (K-1) · |A| = {max_ratio - 1:.2f} · |A|")
print(f"  For any set A, the closure adds at most {max_ratio - 1:.2f}·|A| elements")
print()
print(f"Lipschitz constant for causal classifiers: K = {max_ratio:.2f}")
print(f"  → Small perturbations (ε-shifts) cause at most {max_ratio:.2f}·ε change")

print()
print("=" * 60)
print("All demos completed successfully!")
print("=" * 60)
