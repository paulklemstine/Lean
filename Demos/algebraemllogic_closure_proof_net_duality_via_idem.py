#!/usr/bin/env python3
"""
Applications of Closure–Proof-Net Duality

Demonstrates real-world applications:
1. Knowledge compilation for expert systems
2. Proof compression in automated reasoning
3. Concept lattice analysis (Formal Concept Analysis connection)
"""

from itertools import combinations, chain
from typing import FrozenSet, Set, Dict, List, Tuple


def powerset(s):
    s = list(s)
    return [frozenset(c) for c in chain.from_iterable(
        combinations(s, r) for r in range(len(s) + 1))]


def fmt(s):
    if not s:
        return "∅"
    return "{" + ", ".join(sorted(s)) + "}"


# ─────────────────────────────────────────────────────────────────────
# Application 1: Medical Diagnosis Expert System
# ─────────────────────────────────────────────────────────────────────

def app_medical_diagnosis():
    """
    Model a simple medical diagnosis system as a closure system.

    Symptoms: fever, cough, fatigue, rash, headache
    Rules:
      fever + cough → diagnosis:flu
      fever + rash → diagnosis:measles
      fever + fatigue + headache → diagnosis:meningitis_risk

    The closure system captures all derivable diagnoses from observed symptoms.
    Minimization tells us the smallest diagnostic engine needed.
    """
    print("=" * 70)
    print("APPLICATION 1: Medical Diagnosis Expert System")
    print("=" * 70)
    print()

    H = {"fever", "cough", "fatigue", "rash", "headache",
         "flu", "measles", "mening_risk"}

    def cl(A: frozenset) -> frozenset:
        result = set(A)
        changed = True
        while changed:
            changed = False
            if {"fever", "cough"} <= result and "flu" not in result:
                result.add("flu"); changed = True
            if {"fever", "rash"} <= result and "measles" not in result:
                result.add("measles"); changed = True
            if {"fever", "fatigue", "headache"} <= result and "mening_risk" not in result:
                result.add("mening_risk"); changed = True
        return frozenset(result)

    # Compute states
    all_subsets = powerset(H)
    closed_sets = sorted(set(cl(A) for A in all_subsets),
                         key=lambda s: (len(s), sorted(s)))

    print(f"Total hypotheses/symptoms/diagnoses: {len(H)}")
    print(f"Total possible contexts: {len(all_subsets)}")
    print(f"Canonical diagnostic states: {len(closed_sets)}")
    print(f"Compression: {len(all_subsets)/len(closed_sets):.1f}×")
    print()

    # Show some interesting states
    print("Example diagnostic trajectories:")
    for symptoms in [
        frozenset({"fever"}),
        frozenset({"fever", "cough"}),
        frozenset({"fever", "rash"}),
        frozenset({"fever", "fatigue", "headache"}),
        frozenset({"fever", "cough", "rash"}),
    ]:
        closure = cl(symptoms)
        diagnoses = closure - symptoms
        print(f"  Observe {fmt(symptoms):40s} → Derive {fmt(diagnoses) if diagnoses else 'nothing'}")
    print()

    # Irredundant rules
    print("Irredundant diagnostic rules (minimal premise sets):")
    for gamma in all_subsets:
        for h in H:
            if h in cl(gamma) and h not in gamma:
                irredundant = True
                for gp in all_subsets:
                    if gp < gamma and h in cl(gp):
                        irredundant = False
                        break
                if irredundant:
                    print(f"  {fmt(gamma)} ⊢ {h}")
    print()


# ─────────────────────────────────────────────────────────────────────
# Application 2: Proof Compression
# ─────────────────────────────────────────────────────────────────────

def app_proof_compression():
    """
    Demonstrate proof compression via minimization.

    Consider a simple type system with inference rules.
    Types: Int, Float, Number, Comparable, Printable
    Rules:
      Int → Number
      Float → Number
      Number → Comparable
      Number → Printable
    """
    print("=" * 70)
    print("APPLICATION 2: Type Inference Proof Compression")
    print("=" * 70)
    print()

    H = {"Int", "Float", "Number", "Comparable", "Printable"}

    def cl(A: frozenset) -> frozenset:
        result = set(A)
        changed = True
        while changed:
            changed = False
            if "Int" in result and "Number" not in result:
                result.add("Number"); changed = True
            if "Float" in result and "Number" not in result:
                result.add("Number"); changed = True
            if "Number" in result and "Comparable" not in result:
                result.add("Comparable"); changed = True
            if "Number" in result and "Printable" not in result:
                result.add("Printable"); changed = True
        return frozenset(result)

    all_subsets = powerset(H)
    closed_sets = sorted(set(cl(A) for A in all_subsets),
                         key=lambda s: (len(s), sorted(s)))

    print(f"Types in the system: {len(H)}")
    print(f"Possible type contexts: {len(all_subsets)}")
    print(f"Distinct type configurations: {len(closed_sets)}")
    print(f"Compression: {len(all_subsets)/len(closed_sets):.1f}×")
    print()

    print("Closed type configurations:")
    for i, s in enumerate(closed_sets):
        print(f"  Config {i:2d}: {fmt(s)}")
    print()

    # Show equivalence classes
    classes = {}
    for A in all_subsets:
        key = cl(A)
        if key not in classes:
            classes[key] = []
        classes[key].append(A)

    print("Contexts mapped to same configuration (redundant reasoning eliminated):")
    for closure, contexts in sorted(classes.items(), key=lambda x: len(x[1]), reverse=True):
        if len(contexts) > 1:
            print(f"  Config = {fmt(closure)}:")
            for ctx in sorted(contexts, key=lambda s: (len(s), sorted(s)))[:3]:
                print(f"    {fmt(ctx)}")
            if len(contexts) > 3:
                print(f"    ... ({len(contexts)} total)")
    print()


# ─────────────────────────────────────────────────────────────────────
# Application 3: Concept Lattice / FCA Connection
# ─────────────────────────────────────────────────────────────────────

def app_concept_lattice():
    """
    Connection to Formal Concept Analysis.

    Objects: animals
    Attributes: has_wings, can_fly, has_feathers, warm_blooded, lays_eggs

    The attribute closure models attribute implications learned from data.
    """
    print("=" * 70)
    print("APPLICATION 3: Concept Analysis (Attribute Implications)")
    print("=" * 70)
    print()

    H = {"wings", "flies", "feathers", "warm_blood", "lays_eggs"}

    # Implications from data:
    # feathers → wings, warm_blood, lays_eggs
    # flies → wings
    # wings + warm_blood → lays_eggs (birds)
    def cl(A: frozenset) -> frozenset:
        result = set(A)
        changed = True
        while changed:
            changed = False
            if "feathers" in result:
                for attr in ["wings", "warm_blood", "lays_eggs"]:
                    if attr not in result:
                        result.add(attr); changed = True
            if "flies" in result and "wings" not in result:
                result.add("wings"); changed = True
            if {"wings", "warm_blood"} <= result and "lays_eggs" not in result:
                result.add("lays_eggs"); changed = True
        return frozenset(result)

    all_subsets = powerset(H)
    closed_sets = sorted(set(cl(A) for A in all_subsets),
                         key=lambda s: (len(s), sorted(s)))

    print(f"Attributes: {sorted(H)}")
    print(f"Possible attribute sets: {len(all_subsets)}")
    print(f"Closed attribute sets (concepts): {len(closed_sets)}")
    print(f"Compression: {len(all_subsets)/len(closed_sets):.1f}×")
    print()

    print("Closed attribute configurations:")
    for i, s in enumerate(closed_sets):
        print(f"  Concept {i:2d}: {fmt(s)}")
    print()

    # Irredundant implications
    print("Irredundant attribute implications:")
    for gamma in all_subsets:
        for h in H:
            if h in cl(gamma) and h not in gamma:
                irredundant = True
                for gp in all_subsets:
                    if gp < gamma and h in cl(gp):
                        irredundant = False
                        break
                if irredundant:
                    print(f"  {fmt(gamma)} → {h}")
    print()

    print("Interpretation: These are the minimal attribute dependencies.")
    print("No implication can be simplified without losing information.")
    print()


if __name__ == "__main__":
    app_medical_diagnosis()
    print()
    app_proof_compression()
    print()
    app_concept_lattice()


#!/usr/bin/env python3
"""
Closure–Proof-Net Duality: Demonstrations

Concrete numerical examples demonstrating the algebraic duality between
closure-based entailment and minimal sequent presentations.
"""

from itertools import combinations, chain
from typing import FrozenSet, Set, Dict, Callable, Tuple, List

Hyp = str
Context = frozenset


def powerset(s):
    """All subsets of s."""
    s = list(s)
    return list(chain.from_iterable(combinations(s, r) for r in range(len(s) + 1)))


# ─────────────────────────────────────────────────────────────────────
# Example 1: Matroid closure (linear dependence over F2)
# ─────────────────────────────────────────────────────────────────────

def make_f2_matroid_closure():
    """
    Vectors over F2^3:
      e1 = (1,0,0), e2 = (0,1,0), e3 = (0,0,1),
      e4 = (1,1,0) = e1+e2, e5 = (1,0,1) = e1+e3
    Closure = span in F2^3.
    This is a rank-3 matroid on 5 elements, satisfying exchange.
    """
    H = {"e1", "e2", "e3", "e4", "e5"}
    vecs = {
        "e1": (1, 0, 0),
        "e2": (0, 1, 0),
        "e3": (0, 0, 1),
        "e4": (1, 1, 0),
        "e5": (1, 0, 1),
    }

    def f2_span(vectors):
        """Compute the F2-span of a set of vectors, return all H elements in it."""
        if not vectors:
            return frozenset()
        # Generate all F2 linear combinations
        span_vecs = set()
        span_vecs.add((0, 0, 0))
        vlist = list(vectors)
        for r in range(1, len(vlist) + 1):
            for combo in combinations(vlist, r):
                v = [0, 0, 0]
                for c in combo:
                    for i in range(3):
                        v[i] = (v[i] + c[i]) % 2
                span_vecs.add(tuple(v))
        # Find which H elements are in the span
        result = set()
        for name, vec in vecs.items():
            if vec in span_vecs:
                result.add(name)
        return result

    def cl(A: frozenset) -> frozenset:
        input_vecs = [vecs[h] for h in A]
        in_span = f2_span(input_vecs)
        return frozenset(A | in_span)

    return H, cl


def verify_closure_axioms(H, cl):
    """Verify extensivity, monotonicity, idempotence."""
    subsets = [frozenset(s) for s in powerset(H)]

    print("Verifying closure axioms...")
    for A in subsets:
        assert A <= cl(A), f"Extensivity failed for {A}"
    print("  ✓ Extensivity")

    for A in subsets:
        for B in subsets:
            if A <= B:
                assert cl(A) <= cl(B), f"Monotonicity failed for {A} ⊆ {B}"
    print("  ✓ Monotonicity")

    for A in subsets:
        assert cl(cl(A)) == cl(A), f"Idempotence failed for {A}"
    print("  ✓ Idempotence")


def verify_exchange(H, cl):
    """Verify the exchange axiom."""
    subsets = [frozenset(s) for s in powerset(H)]
    print("Verifying exchange axiom...")
    count = 0
    for A in subsets:
        for a in H:
            for b in H:
                if a != b and a not in cl(A) and b not in cl(A):
                    if b in cl(A | {a}):
                        assert a in cl(A | {b}), \
                            f"Exchange failed: A={set(A)}, a={a}, b={b}"
                        count += 1
    print(f"  ✓ Exchange ({count} instances verified)")


def verify_absorption(H, cl):
    """Verify the absorption axiom."""
    subsets = [frozenset(s) for s in powerset(H)]
    print("Verifying absorption axiom...")
    for A in subsets:
        for B in subsets:
            if B <= cl(A):
                assert cl(A | B) == cl(A), \
                    f"Absorption failed: A={set(A)}, B={set(B)}"
    print("  ✓ Absorption")


def compute_canonical_states(H, cl):
    """Compute canonical states = images of cl (= closed sets)."""
    subsets = [frozenset(s) for s in powerset(H)]
    states = set()
    for A in subsets:
        states.add(cl(A))
    return sorted(states, key=lambda s: (len(s), sorted(s)))


def find_irredundant_sequents(H, cl):
    """Find all irredundant sequents Γ ⊢ h."""
    subsets = [frozenset(s) for s in powerset(H)]
    sequents = []
    for gamma in subsets:
        for h in H:
            if h in cl(gamma) and h not in gamma:
                irredundant = True
                for gamma_prime in subsets:
                    if gamma_prime < gamma and h in cl(gamma_prime):
                        irredundant = False
                        break
                if irredundant:
                    sequents.append((gamma, h))
    return sequents


def compute_quotient(H, cl):
    """Compute the quotient of contexts by closure equivalence."""
    subsets = [frozenset(s) for s in powerset(H)]
    classes = {}
    for A in subsets:
        key = cl(A)
        if key not in classes:
            classes[key] = []
        classes[key].append(A)
    return classes


def fmt(s):
    """Format a frozenset nicely."""
    if not s:
        return "∅"
    return "{" + ", ".join(sorted(s)) + "}"


# ─────────────────────────────────────────────────────────────────────
# Demo 1: F2 Matroid
# ─────────────────────────────────────────────────────────────────────

def demo_matroid():
    """Full demonstration with F2 matroid closure."""
    print("=" * 70)
    print("DEMO 1: F2 Matroid Closure System (rank-3 on 5 elements)")
    print("=" * 70)
    print()

    H, cl = make_f2_matroid_closure()
    print(f"Hypotheses: {sorted(H)}")
    print("e1=(1,0,0), e2=(0,1,0), e3=(0,0,1), e4=e1+e2, e5=e1+e3")
    print()

    verify_closure_axioms(H, cl)
    verify_exchange(H, cl)
    verify_absorption(H, cl)
    print()

    states = compute_canonical_states(H, cl)
    print(f"Canonical states (closed sets): {len(states)}")
    for i, s in enumerate(states):
        print(f"  State {i:2d}: {fmt(s)}")
    print()

    classes = compute_quotient(H, cl)
    print(f"Equivalence classes: {len(classes)}")
    total_contexts = sum(len(v) for v in classes.values())
    print(f"Total contexts: {total_contexts}")
    print(f"Compression: {total_contexts} → {len(classes)} ({total_contexts/len(classes):.1f}x)")
    print()

    sequents = find_irredundant_sequents(H, cl)
    print(f"Irredundant sequents: {len(sequents)}")
    for gamma, h in sequents:
        print(f"  {fmt(gamma)} ⊢ {h}")
    print()

    # Exchange demonstration
    print("Exchange axiom in action:")
    A = frozenset({"e1"})
    a, b = "e2", "e4"
    print(f"  A = {fmt(A)}, a = {a}, b = {b}")
    print(f"  cl(A) = {fmt(cl(A))}")
    print(f"  {a} ∉ cl(A): {a not in cl(A)}")
    print(f"  {b} ∉ cl(A): {b not in cl(A)}")
    print(f"  {b} ∈ cl(A ∪ {{{a}}}) = {fmt(cl(A | {a}))}: {b in cl(A | {a})}")
    print(f"  ⟹ {a} ∈ cl(A ∪ {{{b}}}) = {fmt(cl(A | {b}))}: {a in cl(A | {b})}")
    print()


# ─────────────────────────────────────────────────────────────────────
# Demo 2: Trivial closure (identity)
# ─────────────────────────────────────────────────────────────────────

def demo_trivial():
    """Trivial closure where cl = id. Every set is closed."""
    print("=" * 70)
    print("DEMO 2: Trivial Closure (Identity)")
    print("=" * 70)
    print()

    H = {"a", "b", "c"}
    cl = lambda A: A

    print(f"Hypotheses: {sorted(H)}")
    print("cl(A) = A for all A (no derivation)")
    print()

    verify_closure_axioms(H, cl)
    verify_exchange(H, cl)
    verify_absorption(H, cl)
    print()

    states = compute_canonical_states(H, cl)
    print(f"Canonical states: {len(states)} (= 2^|H| = {2**len(H)})")
    print("Every context is its own state — no compression possible.")
    print("No irredundant sequents exist (nothing is derivable).")
    print()


# ─────────────────────────────────────────────────────────────────────
# Demo 3: Rank-2 matroid (graphic matroid of triangle)
# ─────────────────────────────────────────────────────────────────────

def demo_triangle():
    """Graphic matroid of the triangle graph K3."""
    print("=" * 70)
    print("DEMO 3: Graphic Matroid of Triangle (K3)")
    print("=" * 70)
    print()

    # Edges of K3: ab, bc, ac. Rank 2.
    # Circuit: {ab, bc, ac}
    H = {"ab", "bc", "ac"}

    def cl(A: frozenset) -> frozenset:
        result = set(A)
        # The only circuit is {ab, bc, ac}
        # If any two edges are present, the third is in the closure
        if len(result & {"ab", "bc", "ac"}) >= 2:
            result |= {"ab", "bc", "ac"}
        return frozenset(result)

    print(f"Edges: {sorted(H)}")
    print("Circuit: {ab, bc, ac} (triangle)")
    print()

    verify_closure_axioms(H, cl)
    verify_exchange(H, cl)
    verify_absorption(H, cl)
    print()

    states = compute_canonical_states(H, cl)
    print(f"Canonical states: {len(states)}")
    for i, s in enumerate(states):
        print(f"  State {i}: {fmt(s)}")
    print()

    sequents = find_irredundant_sequents(H, cl)
    print(f"Irredundant sequents: {len(sequents)}")
    for gamma, h in sequents:
        print(f"  {fmt(gamma)} ⊢ {h}")
    print()

    # Show join semilattice
    print("Join semilattice (closed set ⊕ closed set = cl(union)):")
    for s1 in states:
        for s2 in states:
            j = cl(s1 | s2)
            print(f"  {fmt(s1):15s} ⊕ {fmt(s2):15s} = {fmt(j)}")
    print()


# ─────────────────────────────────────────────────────────────────────
# Demo 4: Compression statistics
# ─────────────────────────────────────────────────────────────────────

def demo_compression():
    """Compare compression across different closure systems."""
    print("=" * 70)
    print("DEMO 4: Compression Statistics")
    print("=" * 70)
    print()

    examples = [
        ("Trivial (3 elements)", {"a", "b", "c"}, lambda A: A),
    ]

    H_tri = {"ab", "bc", "ac"}
    def cl_tri(A):
        result = set(A)
        if len(result & {"ab", "bc", "ac"}) >= 2:
            result |= {"ab", "bc", "ac"}
        return frozenset(result)

    H_f2, cl_f2 = make_f2_matroid_closure()

    print(f"{'System':<30s} {'|H|':>4s} {'Contexts':>10s} {'States':>8s} {'Ratio':>8s} {'Sequents':>10s}")
    print("-" * 75)

    # Trivial
    H = {"a", "b", "c"}
    cl = lambda A: A
    n_ctx = 2**len(H)
    states = compute_canonical_states(H, cl)
    seqs = find_irredundant_sequents(H, cl)
    print(f"{'Trivial (3 elem)':<30s} {len(H):>4d} {n_ctx:>10d} {len(states):>8d} {n_ctx/len(states):>8.1f} {len(seqs):>10d}")

    # Triangle
    states_tri = compute_canonical_states(H_tri, cl_tri)
    seqs_tri = find_irredundant_sequents(H_tri, cl_tri)
    n_ctx_tri = 2**len(H_tri)
    print(f"{'Triangle K3':<30s} {len(H_tri):>4d} {n_ctx_tri:>10d} {len(states_tri):>8d} {n_ctx_tri/len(states_tri):>8.1f} {len(seqs_tri):>10d}")

    # F2 matroid
    states_f2 = compute_canonical_states(H_f2, cl_f2)
    seqs_f2 = find_irredundant_sequents(H_f2, cl_f2)
    n_ctx_f2 = 2**len(H_f2)
    print(f"{'F2 matroid (rank 3, 5 elem)':<30s} {len(H_f2):>4d} {n_ctx_f2:>10d} {len(states_f2):>8d} {n_ctx_f2/len(states_f2):>8.1f} {len(seqs_f2):>10d}")

    # Bigger matroid
    H_big = {"v1", "v2", "v3", "v4", "v5", "v6"}
    vecs_big = {
        "v1": (1, 0, 0),
        "v2": (0, 1, 0),
        "v3": (0, 0, 1),
        "v4": (1, 1, 0),
        "v5": (1, 0, 1),
        "v6": (0, 1, 1),
    }
    def f2_span_big(vectors):
        span_vecs = {(0, 0, 0)}
        vlist = list(vectors)
        for r in range(1, len(vlist) + 1):
            for combo in combinations(vlist, r):
                v = [0, 0, 0]
                for c in combo:
                    for i in range(3):
                        v[i] = (v[i] + c[i]) % 2
                span_vecs.add(tuple(v))
        result = set()
        for name, vec in vecs_big.items():
            if vec in span_vecs:
                result.add(name)
        return result

    def cl_big(A):
        input_vecs = [vecs_big[h] for h in A]
        in_span = f2_span_big(input_vecs)
        return frozenset(A | in_span)

    states_big = compute_canonical_states(H_big, cl_big)
    seqs_big = find_irredundant_sequents(H_big, cl_big)
    n_ctx_big = 2**len(H_big)
    print(f"{'F2 matroid (rank 3, 6 elem)':<30s} {len(H_big):>4d} {n_ctx_big:>10d} {len(states_big):>8d} {n_ctx_big/len(states_big):>8.1f} {len(seqs_big):>10d}")

    print()
    print("Key insight: More dependencies → more compression.")
    print("The quotient by closure equivalence dramatically reduces the state space.")
    print()


if __name__ == "__main__":
    demo_matroid()
    print()
    demo_trivial()
    print()
    demo_triangle()
    print()
    demo_compression()


#!/usr/bin/env python3
"""
Visualizations for Closure–Proof-Net Duality

Generates diagrams showing:
1. Lattice of closed sets
2. Compression statistics
3. Irredundant sequent network
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from itertools import combinations, chain
import base64
from io import BytesIO


def powerset(s):
    s = list(s)
    return [frozenset(c) for c in chain.from_iterable(
        combinations(s, r) for r in range(len(s) + 1))]


def fmt(s):
    if not s:
        return "∅"
    return "{" + ",".join(sorted(s)) + "}"


# ── Build the F2 matroid closure ──

H = {"e1", "e2", "e3", "e4", "e5"}
vecs = {
    "e1": (1, 0, 0), "e2": (0, 1, 0), "e3": (0, 0, 1),
    "e4": (1, 1, 0), "e5": (1, 0, 1),
}

def f2_span(vectors):
    span_vecs = {(0, 0, 0)}
    vlist = list(vectors)
    for r in range(1, len(vlist) + 1):
        for combo in combinations(vlist, r):
            v = [0, 0, 0]
            for c in combo:
                for i in range(3):
                    v[i] = (v[i] + c[i]) % 2
            span_vecs.add(tuple(v))
    result = set()
    for name, vec in vecs.items():
        if vec in span_vecs:
            result.add(name)
    return result

def cl(A):
    input_vecs = [vecs[h] for h in A]
    in_span = f2_span(input_vecs)
    return frozenset(A | in_span)


# ── Figure 1: Lattice of closed sets ──

def plot_closed_set_lattice():
    """Plot the Hasse diagram of the lattice of closed sets."""
    all_subsets = powerset(H)
    closed_sets = sorted(set(cl(A) for A in all_subsets),
                         key=lambda s: (len(s), sorted(s)))

    # Group by rank (cardinality)
    ranks = {}
    for s in closed_sets:
        r = len(s)
        if r not in ranks:
            ranks[r] = []
        ranks[r].append(s)

    # Assign positions
    pos = {}
    for rank, sets in sorted(ranks.items()):
        n = len(sets)
        for i, s in enumerate(sets):
            x = (i - (n - 1) / 2) * 2.5
            y = rank * 2
            pos[s] = (x, y)

    # Find cover relations (edges in Hasse diagram)
    edges = []
    for s1 in closed_sets:
        for s2 in closed_sets:
            if s1 < s2:
                # Check if s2 covers s1 (no intermediate)
                is_cover = True
                for s3 in closed_sets:
                    if s1 < s3 < s2:
                        is_cover = False
                        break
                if is_cover:
                    edges.append((s1, s2))

    fig, ax = plt.subplots(1, 1, figsize=(12, 8))

    # Draw edges
    for s1, s2 in edges:
        x1, y1 = pos[s1]
        x2, y2 = pos[s2]
        ax.plot([x1, x2], [y1, y2], 'k-', alpha=0.3, linewidth=1.5)

    # Draw nodes
    for s in closed_sets:
        x, y = pos[s]
        color = '#4ECDC4' if len(s) == 0 else '#FF6B6B' if len(s) == len(H) else '#45B7D1'
        ax.scatter(x, y, s=800, c=color, zorder=5, edgecolors='black', linewidth=1.5)
        label = fmt(s)
        ax.annotate(label, (x, y), textcoords="offset points",
                    xytext=(0, -25), ha='center', fontsize=7, fontweight='bold')

    ax.set_title("Lattice of Closed Sets\n(F₂-matroid, rank 3, 5 elements)",
                 fontsize=14, fontweight='bold')
    ax.set_ylabel("Rank (cardinality)", fontsize=12)
    ax.set_yticks(sorted(ranks.keys()))
    ax.set_xlim(-8, 8)
    ax.grid(True, alpha=0.2)
    ax.set_aspect('equal')

    plt.tight_layout()
    plt.savefig("lattice_closed_sets.png", dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: lattice_closed_sets.png")


# ── Figure 2: Compression statistics ──

def plot_compression():
    """Bar chart of compression ratios across different closure systems."""
    systems = ["Trivial\n(3 elem)", "Triangle\nK₃", "F₂ matroid\n(5 elem)", "F₂ matroid\n(6 elem)"]
    contexts = [8, 8, 32, 64]
    states = [8, 5, 13, 15]
    sequents = [0, 3, 10, 24]

    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    # Contexts vs States
    x = np.arange(len(systems))
    width = 0.35
    bars1 = axes[0].bar(x - width/2, contexts, width, label='Contexts', color='#FF6B6B', alpha=0.8)
    bars2 = axes[0].bar(x + width/2, states, width, label='States', color='#4ECDC4', alpha=0.8)
    axes[0].set_xlabel('System')
    axes[0].set_ylabel('Count')
    axes[0].set_title('Contexts vs Canonical States', fontweight='bold')
    axes[0].set_xticks(x)
    axes[0].set_xticklabels(systems, fontsize=8)
    axes[0].legend()

    # Compression ratio
    ratios = [c/s for c, s in zip(contexts, states)]
    bars = axes[1].bar(x, ratios, color='#45B7D1', alpha=0.8)
    axes[1].set_xlabel('System')
    axes[1].set_ylabel('Compression Ratio')
    axes[1].set_title('Compression Ratio (Contexts / States)', fontweight='bold')
    axes[1].set_xticks(x)
    axes[1].set_xticklabels(systems, fontsize=8)
    for bar, ratio in zip(bars, ratios):
        axes[1].text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.05,
                     f'{ratio:.1f}×', ha='center', fontweight='bold')

    # Irredundant sequents
    bars = axes[2].bar(x, sequents, color='#96CEB4', alpha=0.8)
    axes[2].set_xlabel('System')
    axes[2].set_ylabel('Count')
    axes[2].set_title('Irredundant Sequents', fontweight='bold')
    axes[2].set_xticks(x)
    axes[2].set_xticklabels(systems, fontsize=8)
    for bar, seq in zip(bars, sequents):
        axes[2].text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.3,
                     str(seq), ha='center', fontweight='bold')

    plt.suptitle("Closure–Proof-Net Duality: Compression Analysis", fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig("compression_stats.png", dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: compression_stats.png")


# ── Figure 3: Irredundant sequent network ──

def plot_sequent_network():
    """Visualize the irredundant sequent network as a bipartite graph."""
    all_subsets = powerset(H)
    closed_sets = sorted(set(cl(A) for A in all_subsets),
                         key=lambda s: (len(s), sorted(s)))

    # Find irredundant sequents
    sequents = []
    for gamma in all_subsets:
        for h in H:
            if h in cl(gamma) and h not in gamma:
                irredundant = True
                for gp in all_subsets:
                    if gp < gamma and h in cl(gp):
                        irredundant = False
                        break
                if irredundant:
                    sequents.append((gamma, h))

    fig, ax = plt.subplots(1, 1, figsize=(14, 8))

    # Layout: hypotheses on the left, premises in the middle
    hyp_list = sorted(H)
    hyp_pos = {h: (10, i * 2) for i, h in enumerate(hyp_list)}

    # Position premise sets
    premise_sets = list(set(s[0] for s in sequents))
    premise_sets.sort(key=lambda s: (len(s), sorted(s)))
    premise_pos = {s: (0, i * 1.5) for i, s in enumerate(premise_sets)}

    # Draw sequent arrows
    colors = plt.cm.Set2(np.linspace(0, 1, len(sequents)))
    for i, (gamma, h) in enumerate(sequents):
        x1, y1 = premise_pos[gamma]
        x2, y2 = hyp_pos[h]
        ax.annotate("", xy=(x2 - 0.5, y2), xytext=(x1 + 2.5, y1),
                     arrowprops=dict(arrowstyle="->", color=colors[i],
                                     connectionstyle="arc3,rad=0.1",
                                     linewidth=2, alpha=0.7))

    # Draw premise nodes
    for s, (x, y) in premise_pos.items():
        ax.add_patch(plt.Rectangle((x - 1.2, y - 0.4), 2.4, 0.8,
                                   facecolor='#E8F4FD', edgecolor='#2196F3',
                                   linewidth=1.5, zorder=5))
        ax.text(x, y, fmt(s), ha='center', va='center', fontsize=7, fontweight='bold')

    # Draw hypothesis nodes
    for h_name, (x, y) in hyp_pos.items():
        ax.add_patch(plt.Circle((x, y), 0.5, facecolor='#FFE0B2',
                                edgecolor='#FF9800', linewidth=1.5, zorder=5))
        ax.text(x, y, h_name, ha='center', va='center', fontsize=9, fontweight='bold')

    ax.set_xlim(-2, 12)
    ax.set_ylim(-1, max(len(hyp_list) * 2, len(premise_sets) * 1.5) + 1)
    ax.set_title("Irredundant Sequent Network\n(Premises → Conclusions)",
                 fontsize=14, fontweight='bold')
    ax.set_xlabel("Premises (left) → Conclusions (right)", fontsize=11)
    ax.axis('off')

    plt.tight_layout()
    plt.savefig("sequent_network.png", dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: sequent_network.png")


# ── Figure 4: Idempotent join heatmap ──

def plot_join_heatmap():
    """Heatmap of the join operation on closed sets."""
    all_subsets = powerset(H)
    closed_sets = sorted(set(cl(A) for A in all_subsets),
                         key=lambda s: (len(s), sorted(s)))
    n = len(closed_sets)
    idx = {s: i for i, s in enumerate(closed_sets)}

    join_matrix = np.zeros((n, n), dtype=int)
    for i, si in enumerate(closed_sets):
        for j, sj in enumerate(closed_sets):
            join_matrix[i, j] = idx[cl(si | sj)]

    fig, ax = plt.subplots(1, 1, figsize=(10, 8))
    im = ax.imshow(join_matrix, cmap='YlOrRd', aspect='equal')
    ax.set_xticks(range(n))
    ax.set_yticks(range(n))
    labels = [fmt(s) for s in closed_sets]
    ax.set_xticklabels(labels, rotation=45, ha='right', fontsize=6)
    ax.set_yticklabels(labels, fontsize=6)
    ax.set_title("Join Semilattice Operation\n(State indices of A ⊕ B = cl(A ∪ B))",
                 fontsize=14, fontweight='bold')
    plt.colorbar(im, ax=ax, label='State index')

    plt.tight_layout()
    plt.savefig("join_heatmap.png", dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: join_heatmap.png")


def fig_to_base64(filename):
    """Convert a PNG file to a base64 data URI."""
    with open(filename, 'rb') as f:
        data = f.read()
    return "data:image/png;base64," + base64.b64encode(data).decode('utf-8')


if __name__ == "__main__":
    plot_closed_set_lattice()
    plot_compression()
    plot_sequent_network()
    plot_join_heatmap()
    print("\nAll visualizations saved.")
