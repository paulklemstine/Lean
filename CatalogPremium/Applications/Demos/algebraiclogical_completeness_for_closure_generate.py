#!/usr/bin/env python3
"""
Closure-Generated Proof Semiring: Demonstrations & Visualizations

This script demonstrates the algebraic completeness theorem for closure-generated
proof semirings. The central insight: two proof expressions are semantically
indistinguishable under a closure operator C if and only if they map to the same
element under the canonical evaluation into closed sets — i.e., closure logic
IS the kernel congruence of the proof evaluation map.

We illustrate this with:
1. A concrete closure operator on finite sets
2. The proof equivalence relation and kernel characterization
3. The finite separating model theorem
4. EML closure on real numbers
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from itertools import combinations
from collections import defaultdict
import os


# ============================================================
# Part 1: Closure operators on finite sets
# ============================================================

def powerset(s):
    """Return the powerset of a set as a list of frozensets."""
    s = list(s)
    return [frozenset(c) for r in range(len(s) + 1) for c in combinations(s, r)]


def make_topological_closure(base_set, closed_sets):
    """
    Build a closure operator from a family of closed sets.
    C(S) = intersection of all closed sets containing S.
    """
    def closure(s):
        s = frozenset(s)
        result = frozenset(base_set)
        for cs in closed_sets:
            if s <= cs and cs <= result:
                result = cs
        return result
    return closure


def verify_closure_axioms(C, base_set):
    """Verify extensive, monotone, idempotent for a closure operator."""
    ps = powerset(base_set)
    for s in ps:
        assert s <= C(s), f"Extensive fails: {s} ⊄ {C(s)}"
    for s in ps:
        for t in ps:
            if s <= t:
                assert C(s) <= C(t), f"Monotone fails: C({s}) ⊄ C({t})"
    for s in ps:
        assert C(C(s)) == C(s), f"Idempotent fails: C(C({s})) ≠ C({s})"
    print("✓ All closure axioms verified")


def demonstrate_kernel_characterization():
    """
    Demonstrate the kernel characterization theorem:
    p ≈ q ⟺ C(sem(p)) = C(sem(q))
    """
    print("=" * 60)
    print("PART 1: Kernel Characterization Theorem")
    print("=" * 60)

    base = frozenset({'a', 'b', 'c'})
    closed_sets = [
        frozenset(),
        frozenset({'a'}),
        frozenset({'a', 'b'}),
        frozenset({'a', 'b', 'c'}),
    ]
    C = make_topological_closure(base, closed_sets)
    verify_closure_axioms(C, base)

    proof_expressions = {
        'p1': frozenset({'a'}),
        'p2': frozenset({'b'}),
        'p3': frozenset({'a', 'b'}),
        'p4': frozenset({'b', 'c'}),
        'p5': frozenset({'c'}),
        'p6': frozenset(),
        'p7': frozenset({'a', 'c'}),
    }

    print("\nProof expressions and their closures:")
    print(f"{'Expr':>6} | {'sem(p)':>12} | {'C(sem(p))':>12}")
    print("-" * 40)
    for name, sem_val in proof_expressions.items():
        closed_val = C(sem_val)
        print(f"{name:>6} | {str(set(sem_val)):>12} | {str(set(closed_val)):>12}")

    print("\nEquivalence classes (kernel of closureEval):")
    classes = defaultdict(list)
    for name, sem_val in proof_expressions.items():
        key = C(sem_val)
        classes[key].append(name)
    for closed_set, members in classes.items():
        print(f"  C(sem(·)) = {set(closed_set)}: {members}")

    print("\nKernel Characterization: p ≈ q ⟺ closureEval(p) = closureEval(q)")
    for (n1, s1), (n2, s2) in combinations(proof_expressions.items(), 2):
        if C(s1) == C(s2):
            print(f"  {n1} ≈ {n2}  (both map to {set(C(s1))})")

    return base, closed_sets, C, proof_expressions


def visualize_closure_lattice(base, closed_sets, C, proof_expressions):
    """Visualize the closure operator and equivalence classes."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    ax = axes[0]
    ax.set_title("Closure Lattice\n(closed sets form a chain)", fontsize=13)
    for i, cs in enumerate(closed_sets):
        y = i * 1.5
        label = str(set(cs)) if cs else '∅'
        ax.annotate(label, (2, y), fontsize=12, ha='center', va='center',
                   bbox=dict(boxstyle='round,pad=0.5', facecolor='lightblue', alpha=0.8))
    for i in range(len(closed_sets) - 1):
        y1, y2 = i * 1.5, (i + 1) * 1.5
        ax.annotate('', xy=(2, y2 - 0.3), xytext=(2, y1 + 0.3),
                    arrowprops=dict(arrowstyle='->', lw=1.5))
    ax.set_xlim(0, 4)
    ax.set_ylim(-0.5, 5.5)
    ax.axis('off')

    ax = axes[1]
    ax.set_title("Proof Equivalence Classes\n(kernel of closureEval)", fontsize=13)
    classes = defaultdict(list)
    for name, sem_val in proof_expressions.items():
        classes[frozenset(C(sem_val))].append((name, sem_val))

    colors = ['#FF6B6B', '#4ECDC4', '#45B7D1', '#96CEB4', '#FFEAA7']
    y_pos = 0
    for i, (closed_set, members) in enumerate(sorted(classes.items(), key=lambda x: len(x[0]))):
        color = colors[i % len(colors)]
        label = str(set(closed_set)) if closed_set else '∅'
        rect = mpatches.FancyBboxPatch((0.5, y_pos), 5, 0.8 + 0.4 * len(members),
                                        boxstyle="round,pad=0.1",
                                        facecolor=color, alpha=0.3, edgecolor=color, lw=2)
        ax.add_patch(rect)
        ax.text(0.7, y_pos + 0.8 + 0.4 * len(members) - 0.2,
                f"C(sem(·)) = {label}", fontsize=10, fontweight='bold')
        for j, (name, sem_val) in enumerate(members):
            ax.text(1.5, y_pos + 0.3 + 0.4 * j,
                    f"{name}: sem = {set(sem_val) if sem_val else '∅'}",
                    fontsize=9)
        y_pos += 1.2 + 0.4 * len(members)

    ax.set_xlim(0, 7)
    ax.set_ylim(-0.5, y_pos + 0.5)
    ax.axis('off')

    plt.tight_layout()
    plt.savefig('demos/kernel_characterization.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("\n✓ Saved: demos/kernel_characterization.png")


# ============================================================
# Part 2: Finite separating model theorem
# ============================================================

def demonstrate_finite_separation():
    print("\n" + "=" * 60)
    print("PART 2: Finite Separating Model Theorem")
    print("=" * 60)

    base = frozenset({1, 2, 3, 4, 5})
    closed_sets = [
        frozenset(),
        frozenset({1, 2}),
        frozenset({1, 2, 3}),
        frozenset({1, 2, 3, 4, 5}),
    ]
    C = make_topological_closure(base, closed_sets)
    verify_closure_axioms(C, base)

    proofs = {
        'α': frozenset({1}),
        'β': frozenset({3}),
        'γ': frozenset({4, 5}),
        'δ': frozenset({1, 3}),
        'ε': frozenset({2, 4}),
    }

    print(f"\nBase set: {set(base)}")
    print(f"Closed sets: {[set(s) for s in closed_sets]}")
    print(f"Number of closed sets (= |T|): {len(closed_sets)}")

    print("\nSeparation results:")
    for (n1, s1), (n2, s2) in combinations(proofs.items(), 2):
        c1, c2 = C(s1), C(s2)
        if c1 != c2:
            print(f"  {n1} ≉ {n2}: closureEval({n1}) = {set(c1)} ≠ {set(c2)} = closureEval({n2})")
        else:
            print(f"  {n1} ≈ {n2}: both map to {set(c1)}")

    print(f"\n✓ All inequivalent pairs separated by f : ProofExpr → ClosedSet(C)")
    print(f"  with |ClosedSet(C)| = {len(closed_sets)} (finite!)")


# ============================================================
# Part 3: RingCon — semiring congruence structure
# ============================================================

def demonstrate_ringcon():
    print("\n" + "=" * 60)
    print("PART 3: Semiring Congruence (RingCon)")
    print("=" * 60)

    base = frozenset({1, 2, 3})
    closed_sets = [
        frozenset(),
        frozenset({1}),
        frozenset({1, 2}),
        frozenset({1, 2, 3}),
    ]
    C = make_topological_closure(base, closed_sets)

    print("\nChecking congruence compatibility:")
    print("  + = union, * = intersection")

    print("\n  Closure-union compatibility:")
    all_ok = True
    for s1 in powerset(base):
        for s2 in powerset(base):
            if C(C(s1) | C(s2)) != C(s1 | s2):
                print(f"    FAIL at {set(s1)}, {set(s2)}")
                all_ok = False
                break
        if not all_ok:
            break
    if all_ok:
        print("    ✓ C(C(s) ∪ C(t)) = C(s ∪ t) for all s, t")

    print("\n  Closure-intersection compatibility:")
    failures = 0
    for s1 in powerset(base):
        for s2 in powerset(base):
            if C(C(s1) & C(s2)) != C(s1 & s2):
                if failures < 3:
                    print(f"    Note: C(C({set(s1)}) ∩ C({set(s2)})) = {set(C(C(s1) & C(s2)))} "
                          f"≠ {set(C(s1 & s2))} = C({set(s1)} ∩ {set(s2)})")
                failures += 1
    if failures == 0:
        print("    ✓ C(C(s) ∩ C(t)) = C(s ∩ t) for all s, t")
    else:
        print(f"    ({failures} pairs where intersection compatibility fails)")
        print("    This is expected: not all closure operators preserve intersection!")
        print("    The RingCon theorem requires this as a hypothesis (ClosureCompatible).")

    print("\n  Quotient semiring elements:")
    classes = defaultdict(list)
    for s in powerset(base):
        classes[C(s)].append(s)
    for closed_set, members in sorted(classes.items(), key=lambda x: len(x[0])):
        label = set(closed_set) if closed_set else '∅'
        strs = [str(set(m)) if m else '∅' for m in members[:4]]
        if len(members) > 4:
            strs.append('...')
        print(f"    [{label}] ← {{ {', '.join(strs)} }}")


# ============================================================
# Part 4: EML Closure
# ============================================================

def eml_op(a, b):
    if b <= 0:
        return float('inf')
    return np.exp(a) - np.log(b)


def eml_closure(seed, depth):
    current = set(seed)
    for _ in range(depth):
        new = set()
        for a in list(current):
            for b in list(current):
                if b > 0:
                    val = eml_op(a, b)
                    if np.isfinite(val) and abs(val) < 1e10:
                        new.add(round(val, 10))
        current = current | new
    return current


def demonstrate_eml_closure():
    print("\n" + "=" * 60)
    print("PART 4: EML Closure Operator")
    print("=" * 60)

    seed = {1.0}
    print(f"\nSeed set: {seed}")

    for d in range(4):
        vals = eml_closure(seed, d)
        prev = eml_closure(seed, d - 1) if d > 0 else set()
        new = sorted(vals - prev)
        print(f"\n  Depth {d}: {len(vals)} elements")
        if len(new) <= 8:
            print(f"    New: {[round(v, 4) for v in new[:8]]}")
        else:
            print(f"    New (first 8): {[round(v, 4) for v in new[:8]]}...")

    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    ax = axes[0]
    sizes = [len(eml_closure(seed, d)) for d in range(5)]
    ax.bar(range(5), sizes, color=['#4ECDC4', '#45B7D1', '#FF6B6B', '#96CEB4', '#FFEAA7'])
    ax.set_xlabel('Depth', fontsize=12)
    ax.set_ylabel('Number of elements', fontsize=12)
    ax.set_title('EML Closure Growth from {1}', fontsize=13)
    ax.set_xticks(range(5))

    ax = axes[1]
    vals_d2 = sorted(eml_closure(seed, 2))
    vals_d2 = [v for v in vals_d2 if abs(v) < 20]
    ax.hist(vals_d2, bins=30, color='#45B7D1', alpha=0.7, edgecolor='black')
    ax.set_xlabel('Value', fontsize=12)
    ax.set_ylabel('Count', fontsize=12)
    ax.set_title('Distribution of EML Closure Values (depth 2)', fontsize=13)
    ax.axvline(x=1, color='red', linestyle='--', label='seed = 1')
    ax.axvline(x=np.e, color='green', linestyle='--', label=f'e = {np.e:.3f}')
    ax.legend()

    plt.tight_layout()
    plt.savefig('demos/eml_closure_growth.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("\n✓ Saved: demos/eml_closure_growth.png")

    print("\n  EML Proof Equivalence:")
    print("  Two seed sets are EML-equivalent if they generate the same closure.")
    s1 = {1.0}
    s2 = {1.0, round(np.e, 10)}
    c1 = eml_closure(s1, 2)
    c2 = eml_closure(s2, 2)
    print(f"\n  {s1}: {len(c1)} values at depth 2")
    print(f"  {s2}: {len(c2)} values at depth 2")
    if c1 == c2:
        print("  ✓ Same closure → EML-equivalent")
    else:
        print(f"  Closures differ by {len(c2 - c1)} elements (may converge at higher depth)")


# ============================================================
# Part 5: Algebraic completeness diagram
# ============================================================

def demonstrate_algebraic_completeness():
    print("\n" + "=" * 60)
    print("PART 5: Algebraic Completeness Diagram")
    print("=" * 60)

    fig, ax = plt.subplots(1, 1, figsize=(10, 8))
    ax.set_xlim(-1, 11)
    ax.set_ylim(-1, 9)
    ax.axis('off')
    ax.set_title("Algebraic Completeness for Closure-Generated Proof Semirings",
                 fontsize=14, fontweight='bold', pad=20)

    boxes = {
        'PE': (1, 7, 'ProofExpr(σ)\n(free semiring)'),
        'SS': (7, 7, 'Set σ\n(semantic domain)'),
        'PQ': (1, 2, 'ProofSemiring(C)\n(quotient semiring)'),
        'CS': (7, 2, 'ClosedSet(C)\n(closed subsets)'),
    }
    for key, (x, y, label) in boxes.items():
        color = '#E8F4FD' if 'Proof' in label else '#FFF3E0'
        rect = mpatches.FancyBboxPatch((x - 1.5, y - 0.8), 3, 1.6,
                                        boxstyle="round,pad=0.3",
                                        facecolor=color, edgecolor='#333', lw=2)
        ax.add_patch(rect)
        ax.text(x, y, label, ha='center', va='center', fontsize=11, fontweight='bold')

    ax.annotate('', xy=(5.5, 7), xytext=(2.5, 7),
                arrowprops=dict(arrowstyle='->', lw=2, color='#2196F3'))
    ax.text(4, 7.4, 'sem', fontsize=12, ha='center', color='#2196F3', fontstyle='italic')

    ax.annotate('', xy=(1, 2.8), xytext=(1, 6.2),
                arrowprops=dict(arrowstyle='->', lw=2, color='#E91E63'))
    ax.text(-0.2, 4.5, 'quotient\n(mod ≈)', fontsize=10, ha='center', color='#E91E63',
            fontstyle='italic')

    ax.annotate('', xy=(7, 2.8), xytext=(7, 6.2),
                arrowprops=dict(arrowstyle='->', lw=2, color='#4CAF50'))
    ax.text(8.3, 4.5, 'closure\nC(·)', fontsize=10, ha='center', color='#4CAF50',
            fontstyle='italic')

    ax.annotate('', xy=(5.5, 2), xytext=(2.5, 2),
                arrowprops=dict(arrowstyle='->', lw=2, color='#FF9800'))
    ax.text(4, 1.4, 'closureEval\n(injective!)', fontsize=11, ha='center',
            color='#FF9800', fontstyle='italic', fontweight='bold')

    theorem_text = (
        "KERNEL CHARACTERIZATION THEOREM\n"
        "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
        "p ≈ q  ⟺  C(sem(p)) = C(sem(q))\n"
        "      ⟺  closureEval(p) = closureEval(q)\n\n"
        "Proof equivalence = ker(closureEval)"
    )
    rect = mpatches.FancyBboxPatch((2, -0.8), 6, 1.8,
                                    boxstyle="round,pad=0.3",
                                    facecolor='#FFEBEE', edgecolor='#C62828', lw=2)
    ax.add_patch(rect)
    ax.text(5, 0.1, theorem_text, ha='center', va='center', fontsize=9,
            fontfamily='monospace', color='#C62828')

    plt.savefig('demos/algebraic_completeness.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved: demos/algebraic_completeness.png")


# ============================================================
# Main
# ============================================================

if __name__ == '__main__':
    os.makedirs('demos', exist_ok=True)

    base, closed_sets, C, proofs = demonstrate_kernel_characterization()
    visualize_closure_lattice(base, closed_sets, C, proofs)
    demonstrate_finite_separation()
    demonstrate_ringcon()
    demonstrate_eml_closure()
    demonstrate_algebraic_completeness()

    print("\n" + "=" * 60)
    print("All demonstrations complete!")
    print("=" * 60)
    print("\nKey takeaway: Closure-generated proof semantics factors through")
    print("an algebraic kernel. This means:")
    print("  1. Proof equivalence has an exact algebraic characterization")
    print("  2. The quotient ProofSemiring(C) is well-defined")
    print("  3. Finite σ ⟹ finite separating models exist")
    print("  4. The EML closure from density theory is a concrete instance")
