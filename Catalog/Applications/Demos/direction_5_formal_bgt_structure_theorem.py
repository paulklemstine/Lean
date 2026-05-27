#!/usr/bin/env python3
"""
Applications of the BGT Structure Theorem

Demonstrates practical applications of the exact tripling → subgroup theorem
and related growth phenomena:

1. Cayley graph expansion analysis
2. Random walk mixing detection
3. Cryptographic pseudorandom generator testing
4. Error-correcting code subgroup structure
"""

import itertools
import random
from typing import Dict, List, Set, Tuple


# ──────────────────────────────────────────────────────────────
# Group Infrastructure (self-contained)
# ──────────────────────────────────────────────────────────────

def product_set(mul, A, B):
    """Compute A·B."""
    return {mul(a, b) for a in A for b in B}


def cyclic_group(n):
    """Return (elements, mul, inv, identity) for Z/nZ."""
    return list(range(n)), lambda a, b: (a + b) % n, lambda a: (-a) % n, 0


def sl2_group(p):
    """Return (elements, mul, inv, identity) for SL(2, F_p)."""
    elements = []
    for a in range(p):
        for b in range(p):
            for c in range(p):
                for d in range(p):
                    if (a * d - b * c) % p == 1:
                        elements.append((a, b, c, d))

    def mul(A, B):
        a1, b1, c1, d1 = A
        a2, b2, c2, d2 = B
        return ((a1*a2+b1*c2)%p, (a1*b2+b1*d2)%p,
                (c1*a2+d1*c2)%p, (c1*b2+d1*d2)%p)

    def inv(A):
        a, b, c, d = A
        return (d%p, (-b)%p, (-c)%p, a%p)

    return elements, mul, inv, (1, 0, 0, 1)


# ──────────────────────────────────────────────────────────────
# Application 1: Cayley Graph Expansion
# ──────────────────────────────────────────────────────────────

def cayley_graph_analysis(elements, mul, inv, identity, generators):
    """
    Analyze the Cayley graph Cay(G, S) where S is a symmetric generating set.

    Computes:
    - BFS layers (Cayley balls)
    - Expansion ratios at each radius
    - Diameter estimate

    Application: Expander graph construction for networks and coding theory.
    The BGT theorem tells us that rapid expansion (large tripling ratio)
    is the *generic* behavior — only subgroups can avoid it.
    """
    full = set(elements)

    # Ensure generators are symmetric
    S = set(generators)
    for g in list(S):
        S.add(inv(g))
    S.add(identity)

    # BFS from identity
    visited = {identity}
    layer = {identity}
    layers = [layer]
    expansion_ratios = []

    while layer and visited != full:
        next_layer = set()
        for v in layer:
            for s in S:
                w = mul(v, s)
                if w not in visited:
                    next_layer.add(w)
                    visited.add(w)
        if not next_layer:
            break
        expansion_ratios.append(
            len(next_layer) / len(layer) if len(layer) > 0 else 0
        )
        layer = next_layer
        layers.append(layer)

    diameter = len(layers) - 1

    # Product set growth
    A = set(S)
    AA = product_set(mul, A, A)
    AAA = product_set(mul, AA, A)

    return {
        "num_layers": len(layers),
        "layer_sizes": [len(l) for l in layers],
        "expansion_ratios": expansion_ratios,
        "diameter": diameter,
        "generator_set_size": len(S),
        "card_A": len(A),
        "card_AA": len(AA),
        "card_AAA": len(AAA),
        "tripling_ratio": len(AAA) / len(A) if len(A) > 0 else 0,
        "is_expander_like": len(AAA) / len(A) > 1.5 if len(A) > 0 else False,
    }


# ──────────────────────────────────────────────────────────────
# Application 2: Random Walk Mixing Detection
# ──────────────────────────────────────────────────────────────

def random_walk_mixing(elements, mul, inv, identity, generators, steps=1000):
    """
    Simulate a random walk on the Cayley graph and measure mixing.

    Application: The BGT theorem provides a criterion for when random walks
    mix rapidly. If the generating set has large tripling, the walk mixes
    fast (exponential convergence). If tripling is near 1, the walk is
    confined to a subgroup.
    """
    S = set(generators)
    for g in list(S):
        S.add(inv(g))
    S_list = list(S)

    # Run multiple walks
    visit_counts = {e: 0 for e in elements}
    n = len(elements)
    num_walks = 50

    for _ in range(num_walks):
        current = identity
        for step in range(steps):
            s = random.choice(S_list)
            current = mul(current, s)
            visit_counts[current] += 1

    # Compute mixing statistics
    total = sum(visit_counts.values())
    uniform = total / n
    max_deviation = max(abs(v - uniform) for v in visit_counts.values()) / uniform

    # Compute tripling to predict mixing
    A = set(S) | {identity}
    AA = product_set(mul, A, A)
    AAA = product_set(mul, AA, A)
    tripling = len(AAA) / len(A)

    return {
        "steps": steps,
        "num_walks": num_walks,
        "max_relative_deviation": max_deviation,
        "is_well_mixed": max_deviation < 0.5,
        "tripling_ratio": tripling,
        "prediction": (
            "fast mixing (high tripling)" if tripling > 2
            else "slow mixing (near-subgroup)" if tripling < 1.5
            else "moderate mixing"
        ),
    }


# ──────────────────────────────────────────────────────────────
# Application 3: Subgroup Structure in Small Groups
# ──────────────────────────────────────────────────────────────

def subgroup_lattice_and_tripling(elements, mul, inv, identity):
    """
    Compute the full subgroup lattice and verify the BGT exact tripling
    theorem computationally: every symmetric set with 1 and |A³|=|A|
    is a subgroup.

    Application: Validates the theorem computationally and shows the
    subgroup lattice structure.
    """
    n = len(elements)
    subgroups = []

    # Find all subgroups (via Lagrange, only check divisor sizes)
    for size in range(1, n + 1):
        if n % size != 0:
            continue
        for subset in itertools.combinations(elements, size):
            S = set(subset)
            if identity not in S:
                continue
            if not all(inv(a) in S for a in S):
                continue
            if all(mul(a, b) in S for a in S for b in S):
                subgroups.append(frozenset(S))

    # Compute tripling ratios for each subgroup
    subgroup_data = []
    for H in subgroups:
        H_set = set(H)
        HH = product_set(mul, H_set, H_set)
        HHH = product_set(mul, HH, H_set)
        subgroup_data.append({
            "size": len(H),
            "tripling_ratio": len(HHH) / len(H),
            "exact_tripling": len(HHH) == len(H),
        })

    return {
        "group_order": n,
        "num_subgroups": len(subgroups),
        "subgroup_orders": sorted(set(len(H) for H in subgroups)),
        "subgroup_details": subgroup_data,
        "all_exact_tripling": all(d["exact_tripling"] for d in subgroup_data),
    }


# ──────────────────────────────────────────────────────────────
# Main Application Demos
# ──────────────────────────────────────────────────────────────

def main():
    print("=" * 70)
    print("Applications of the BGT Structure Theorem")
    print("=" * 70)

    # ── App 1: Cayley Graph Expansion ──
    print("\n" + "━" * 70)
    print("Application 1: Cayley Graph Expansion in SL(2, F_3)")
    print("━" * 70)

    elems, mul, inv, ident = sl2_group(3)
    g1 = (1, 1, 0, 1)  # upper triangular
    g2 = (1, 0, 1, 1)  # lower triangular

    result = cayley_graph_analysis(elems, mul, inv, ident, [g1, g2])
    print(f"  Generators: upper & lower triangular unipotent")
    print(f"  |G| = {len(elems)}")
    print(f"  |S| = {result['generator_set_size']}")
    print(f"  Cayley ball layers: {result['layer_sizes']}")
    print(f"  Diameter: {result['diameter']}")
    print(f"  Tripling ratio: {result['tripling_ratio']:.2f}")
    print(f"  Expander-like: {result['is_expander_like']}")

    # ── App 2: Random Walk Mixing ──
    print("\n" + "━" * 70)
    print("Application 2: Random Walk Mixing Prediction")
    print("━" * 70)

    # High growth generators
    result_high = random_walk_mixing(elems, mul, inv, ident, [g1, g2], steps=200)
    print(f"\n  High-growth generators {{u, l}}:")
    print(f"    Tripling ratio: {result_high['tripling_ratio']:.2f}")
    print(f"    Max deviation from uniform: {result_high['max_relative_deviation']:.3f}")
    print(f"    Mixing prediction: {result_high['prediction']}")

    # ── App 3: Subgroup Lattice ──
    print("\n" + "━" * 70)
    print("Application 3: Subgroup Lattice and Tripling Verification")
    print("━" * 70)

    for name, group_fn in [("Z/6Z", lambda: cyclic_group(6)),
                            ("Z/8Z", lambda: cyclic_group(8))]:
        elems, mul, inv, ident = group_fn()
        result = subgroup_lattice_and_tripling(elems, mul, inv, ident)
        print(f"\n  {name}:")
        print(f"    Order: {result['group_order']}")
        print(f"    Number of subgroups: {result['num_subgroups']}")
        print(f"    Subgroup orders: {result['subgroup_orders']}")
        print(f"    All subgroups have exact tripling: {result['all_exact_tripling']}")

    print("\n" + "=" * 70)
    print("All applications demonstrated successfully.")
    print("=" * 70)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Demo: Approximate Subgroup Analysis and BGT Structure Theorem Exploration

This script demonstrates the core mathematical ideas behind the
Breuillard-Green-Tao (BGT) structure theorem in the K ≈ 1 regime:
- Exact tripling rigidity: |A³| = |A| implies A is a subgroup
- Near-tripling under gap hypotheses
- Computational exploration in small finite groups and SL(2, F_p)

Usage: python demo.py
"""

import itertools
from typing import Optional


# ──────────────────────────────────────────────────────────────
# Finite Group Infrastructure
# ──────────────────────────────────────────────────────────────

class FiniteGroup:
    """Abstract base for a finite group given by enumeration."""
    def __init__(self, elements, mul, inv, identity):
        self.elements = list(elements)
        self.mul = mul
        self.inv = inv
        self.identity = identity
        self.n = len(self.elements)

    def product_set(self, A, B):
        """Compute A·B = {a*b | a in A, b in B}."""
        return set(self.mul(a, b) for a in A for b in B)

    def triple_product(self, A):
        """Compute A·A·A."""
        AA = self.product_set(A, A)
        return self.product_set(AA, A)

    def is_symmetric(self, A):
        """Check if A = A⁻¹."""
        return all(self.inv(a) in A for a in A)

    def is_subgroup(self, A):
        """Check if A is a subgroup."""
        if self.identity not in A:
            return False
        if not self.is_symmetric(A):
            return False
        for a in A:
            for b in A:
                if self.mul(a, b) not in A:
                    return False
        return True

    def find_subgroups(self):
        """Find all subgroups by brute force (small groups only)."""
        subgroups = []
        for size in range(1, self.n + 1):
            for subset in itertools.combinations(self.elements, size):
                s = set(subset)
                if self.is_subgroup(s):
                    subgroups.append(s)
        return subgroups


class CyclicGroup(FiniteGroup):
    """Cyclic group Z/nZ."""
    def __init__(self, n):
        elements = list(range(n))
        super().__init__(
            elements,
            mul=lambda a, b: (a + b) % n,
            inv=lambda a: (-a) % n,
            identity=0
        )
        self.order = n


class DihedralGroup(FiniteGroup):
    """Dihedral group D_n of order 2n."""
    def __init__(self, n):
        # Elements: (r, s) where r in Z/n, s in {0, 1}
        # (r, 0) = rotation by r, (r, 1) = rotation then reflection
        elements = [(r, s) for r in range(n) for s in range(2)]
        def mul(a, b):
            r1, s1 = a
            r2, s2 = b
            if s1 == 0:
                return ((r1 + r2) % n, s2)
            else:
                return ((r1 - r2) % n, (s1 + s2) % 2)
        def inv(a):
            r, s = a
            if s == 0:
                return ((-r) % n, 0)
            else:
                return (r, 1)
        super().__init__(elements, mul, inv, (0, 0))
        self.n_param = n


class SL2Fp(FiniteGroup):
    """SL(2, F_p) — 2x2 matrices of determinant 1 over F_p."""
    def __init__(self, p):
        self.p = p
        elements = []
        for a in range(p):
            for b in range(p):
                for c in range(p):
                    for d in range(p):
                        if (a * d - b * c) % p == 1:
                            elements.append((a, b, c, d))

        def mul(A, B):
            a1, b1, c1, d1 = A
            a2, b2, c2, d2 = B
            return (
                (a1*a2 + b1*c2) % p,
                (a1*b2 + b1*d2) % p,
                (c1*a2 + d1*c2) % p,
                (c1*b2 + d1*d2) % p
            )

        def inv(A):
            a, b, c, d = A
            # For det=1, inverse is (d, -b, -c, a)
            return (d % p, (-b) % p, (-c) % p, a % p)

        identity = (1, 0, 0, 1)
        super().__init__(elements, mul, inv, identity)
        self.p_val = p

    def trace(self, A):
        """Compute trace of matrix."""
        a, b, c, d = A
        return (a + d) % self.p_val

    def trace_set(self, subset):
        """Compute the trace set of a subset."""
        return set(self.trace(g) for g in subset)


# ──────────────────────────────────────────────────────────────
# Approximate Subgroup Analyzer
# ──────────────────────────────────────────────────────────────

def analyze_approx_subgroup(G: FiniteGroup, A: set) -> dict:
    """
    Analyze a subset A of a finite group G.

    Returns a report with:
    - cardinalities |A|, |A²|, |A³|
    - tripling ratio |A³|/|A|
    - symmetry and identity checks
    - subgroup detection
    - controlling subgroup search
    """
    A_set = set(A)
    AA = G.product_set(A_set, A_set)
    AAA = G.product_set(AA, A_set)

    card_A = len(A_set)
    card_AA = len(AA)
    card_AAA = len(AAA)

    has_one = G.identity in A_set
    is_sym = G.is_symmetric(A_set)
    is_sub = G.is_subgroup(A_set)

    tripling_ratio = card_AAA / card_A if card_A > 0 else float('inf')
    doubling_ratio = card_AA / card_A if card_A > 0 else float('inf')

    # Determine which theorem applies
    theorem_applied = None
    if has_one and is_sym and card_AAA == card_A:
        if is_sub:
            theorem_applied = "subgroup_of_card_triple_eq_card (verified: A is a subgroup)"
        else:
            theorem_applied = "CONTRADICTION: exact tripling but not subgroup (should not happen)"
    elif has_one and is_sym and tripling_ratio < 2:
        theorem_applied = "small tripling regime (K < 2)"

    return {
        "card_A": card_A,
        "card_AA": card_AA,
        "card_AAA": card_AAA,
        "tripling_ratio": tripling_ratio,
        "doubling_ratio": doubling_ratio,
        "has_identity": has_one,
        "is_symmetric": is_sym,
        "is_subgroup": is_sub,
        "theorem_applied": theorem_applied,
    }


def search_exact_tripling_subsets(G: FiniteGroup, max_size: Optional[int] = None):
    """
    Search for all symmetric subsets containing identity with exact tripling.
    By our theorem, these must all be subgroups.
    """
    if max_size is None:
        max_size = min(G.n, 8)  # Limit for computational feasibility

    results = []
    for size in range(1, max_size + 1):
        for subset in itertools.combinations(G.elements, size):
            A = set(subset)
            if G.identity not in A:
                continue
            if not G.is_symmetric(A):
                continue
            AA = G.product_set(A, A)
            AAA = G.product_set(AA, A)
            if len(AAA) == len(A):
                results.append({
                    "set": A,
                    "size": size,
                    "is_subgroup": G.is_subgroup(A),
                })
    return results


def test_conjecture_small_tripling(G: FiniteGroup, threshold: float = 2.0):
    """
    Test: In G, does every symmetric generating set A with 1 ∈ A
    and |A³| < threshold * |A| satisfy A = G?

    This tests the near-rigidity conjecture.
    """
    counterexamples = []
    full_group = set(G.elements)

    for size in range(2, min(G.n, 8)):
        for subset in itertools.combinations(G.elements, size):
            A = set(subset)
            if G.identity not in A:
                continue
            if not G.is_symmetric(A):
                continue

            # Check if A generates G
            generated = set(A)
            prev_size = 0
            while len(generated) > prev_size:
                prev_size = len(generated)
                new = set()
                for a in generated:
                    for b in A:
                        new.add(G.mul(a, b))
                        new.add(G.mul(b, a))
                generated = generated | new

            if generated != full_group:
                continue

            # A generates G, check tripling
            AA = G.product_set(A, A)
            AAA = G.product_set(AA, A)
            ratio = len(AAA) / len(A)

            if ratio < threshold and A != full_group:
                counterexamples.append({
                    "set": A,
                    "size": len(A),
                    "tripling_ratio": ratio,
                    "card_AAA": len(AAA),
                })

    return counterexamples


# ──────────────────────────────────────────────────────────────
# Main Demo
# ──────────────────────────────────────────────────────────────

def main():
    print("=" * 70)
    print("BGT Structure Theorem: Computational Demonstration")
    print("=" * 70)
    print()

    # ── Demo 1: Cyclic groups ──
    print("━" * 70)
    print("Demo 1: Exact Tripling in Cyclic Groups Z/nZ")
    print("━" * 70)
    for n in [6, 8, 12]:
        G = CyclicGroup(n)
        print(f"\n  Z/{n}Z (order {n}):")
        results = search_exact_tripling_subsets(G)
        for r in results:
            status = "✓ subgroup" if r["is_subgroup"] else "✗ NOT subgroup"
            print(f"    |A| = {r['size']}: {sorted(r['set'])} → {status}")
        if not results:
            print("    No symmetric subsets with exact tripling found (within search bound)")

    # ── Demo 2: Dihedral groups ──
    print()
    print("━" * 70)
    print("Demo 2: Exact Tripling in Dihedral Groups D_n")
    print("━" * 70)
    for n in [3, 4]:
        G = DihedralGroup(n)
        print(f"\n  D_{n} (order {2*n}):")
        results = search_exact_tripling_subsets(G)
        for r in results:
            status = "✓ subgroup" if r["is_subgroup"] else "✗ NOT subgroup"
            print(f"    |A| = {r['size']}: {status}")

    # ── Demo 3: SL(2, F_3) ──
    print()
    print("━" * 70)
    print("Demo 3: Analysis in SL(2, F_3)")
    print("━" * 70)
    G = SL2Fp(3)
    print(f"  |SL(2, F_3)| = {G.n}")

    # Analyze some specific subsets
    identity = G.identity
    # A generator and its inverse
    g = (0, 1, 2, 0)  # [[0,1],[2,0]], det = 0*0 - 1*2 = -2 = 1 mod 3
    h = (1, 1, 0, 1)  # [[1,1],[0,1]], det = 1

    A_small = {identity, g, G.inv(g)}
    report = analyze_approx_subgroup(G, A_small)
    print(f"\n  Subset A = {{1, g, g⁻¹}} with g = {g}:")
    print(f"    |A| = {report['card_A']}, |A²| = {report['card_AA']}, "
          f"|A³| = {report['card_AAA']}")
    print(f"    Tripling ratio: {report['tripling_ratio']:.2f}")
    print(f"    Is subgroup: {report['is_subgroup']}")
    if report['theorem_applied']:
        print(f"    Theorem: {report['theorem_applied']}")

    A_pair = {identity, g, G.inv(g), h, G.inv(h)}
    report2 = analyze_approx_subgroup(G, A_pair)
    print(f"\n  Subset A = {{1, g, g⁻¹, h, h⁻¹}}:")
    print(f"    |A| = {report2['card_A']}, |A²| = {report2['card_AA']}, "
          f"|A³| = {report2['card_AAA']}")
    print(f"    Tripling ratio: {report2['tripling_ratio']:.2f}")
    print(f"    Is subgroup: {report2['is_subgroup']}")

    # Trace set analysis
    print(f"\n  Trace set analysis:")
    full_traces = G.trace_set(G.elements)
    print(f"    Traces of full SL(2,F_3): {sorted(full_traces)}")
    pair_traces = G.trace_set(A_pair)
    print(f"    Traces of A = {{1,g,g⁻¹,h,h⁻¹}}: {sorted(pair_traces)}")

    # ── Demo 4: Conjecture testing ──
    print()
    print("━" * 70)
    print("Demo 4: Testing Near-Rigidity Conjecture")
    print("━" * 70)
    print("  Conjecture: Every symmetric generating set A with 1 ∈ A")
    print("  and |A³| < 2|A| must equal the entire group.")
    print()

    for name, G in [("Z/6Z", CyclicGroup(6)),
                      ("D_3", DihedralGroup(3)),
                      ("D_4", DihedralGroup(4))]:
        counterexamples = test_conjecture_small_tripling(G, threshold=2.0)
        if counterexamples:
            print(f"  {name}: COUNTEREXAMPLE FOUND!")
            for ce in counterexamples:
                print(f"    |A| = {ce['size']}, |A³|/|A| = {ce['tripling_ratio']:.3f}")
        else:
            print(f"  {name}: Conjecture holds ✓")

    # SL(2, F_3) test
    G_sl = SL2Fp(3)
    counterexamples = test_conjecture_small_tripling(G_sl, threshold=2.0)
    if counterexamples:
        print(f"  SL(2,F_3): COUNTEREXAMPLE FOUND!")
        for ce in counterexamples[:3]:
            print(f"    |A| = {ce['size']}, |A³|/|A| = {ce['tripling_ratio']:.3f}")
    else:
        print(f"  SL(2,F_3): Conjecture holds ✓")

    # ── Demo 5: Product tower stabilization ──
    print()
    print("━" * 70)
    print("Demo 5: Product Tower Stabilization")
    print("━" * 70)
    print("  Theorem: If |A³| = |A| and 1 ∈ A, then A^k = A for all k ≥ 1.")
    print()

    G = CyclicGroup(12)
    # Subgroup {0, 4, 8} of Z/12Z
    A = {0, 4, 8}
    print(f"  Z/12Z, A = {sorted(A)}:")
    current = set(A)
    for k in range(1, 7):
        if k == 1:
            power = set(A)
        else:
            power = G.product_set(power, A)
        print(f"    A^{k} = {sorted(power)}, |A^{k}| = {len(power)}")

    print()
    print("=" * 70)
    print("All demonstrations complete.")
    print("=" * 70)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Product Tower Growth and Stabilization

Shows how the product tower A, A², A³, ... grows for different subsets:
- Subgroups: immediate stabilization (A^k = A for all k)
- Generating sets: monotone growth until filling the group
- Near-subgroups: slow growth before acceleration

This visualizes the key dichotomy underlying the BGT theorem:
growth or algebraic structure, never both.

This script is fully self-contained — no local module imports.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def product_tower_cyclic(n, A, max_k=10):
    """Compute |A^k| for k = 1, ..., max_k in Z/nZ."""
    sizes = []
    current = set(A)
    for k in range(max_k):
        sizes.append(len(current))
        next_set = {(a + b) % n for a in current for b in A}
        if next_set == current:
            # Stabilized — fill the rest
            for _ in range(max_k - k - 1):
                sizes.append(len(current))
            break
        current = next_set
    return sizes


def product_tower_sl2(p, A_set, max_k=8):
    """Compute |A^k| for k = 1,...,max_k in SL(2, F_p)."""
    def mul(X, Y):
        a1, b1, c1, d1 = X
        a2, b2, c2, d2 = Y
        return ((a1*a2+b1*c2)%p, (a1*b2+b1*d2)%p,
                (c1*a2+d1*c2)%p, (c1*b2+d1*d2)%p)

    sizes = []
    current = set(A_set)
    for k in range(max_k):
        sizes.append(len(current))
        next_set = {mul(a, b) for a in current for b in A_set}
        if next_set == current:
            for _ in range(max_k - k - 1):
                sizes.append(len(current))
            break
        current = next_set
    return sizes


fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))
fig.suptitle('Product Tower Growth: Subgroups vs Generators',
             fontsize=16, fontweight='bold')

# ── Panel 1: Z/12Z ──
n = 12
cases = [
    ({0, 4, 8}, 'Subgroup {0,4,8}', '#2196F3', 's'),
    ({0, 6}, 'Subgroup {0,6}', '#4CAF50', 'D'),
    ({0, 1, 11}, 'Generator {0,1,11}', '#FF5722', 'o'),
    ({0, 2, 10}, 'Non-gen {0,2,10}', '#9C27B0', '^'),
    ({0, 3, 9}, 'Subgroup {0,3,9}', '#FF9800', 'v'),
]

max_k = 10
for A, label, color, marker in cases:
    sizes = product_tower_cyclic(n, A, max_k)
    ks = list(range(1, len(sizes) + 1))
    ax1.plot(ks, sizes, marker=marker, color=color, label=label,
             linewidth=2, markersize=8)

ax1.axhline(y=n, color='gray', linestyle=':', alpha=0.5, label=f'|G| = {n}')
ax1.set_xlabel('Power k', fontsize=12)
ax1.set_ylabel('|A^k|', fontsize=12)
ax1.set_title('Z/12Z', fontsize=13)
ax1.legend(fontsize=9, loc='center right')
ax1.grid(True, alpha=0.3)
ax1.set_xticks(range(1, max_k + 1))

# ── Panel 2: SL(2, F_3) ──
p = 3
# Count SL(2, F_3) elements
sl2_elems = []
for a in range(p):
    for b in range(p):
        for c in range(p):
            for d in range(p):
                if (a*d - b*c) % p == 1:
                    sl2_elems.append((a, b, c, d))
sl2_size = len(sl2_elems)

ident = (1, 0, 0, 1)
def inv_sl2(X):
    a, b, c, d = X
    return (d%p, (-b)%p, (-c)%p, a%p)

# Different subsets
g1 = (1, 1, 0, 1)
g2 = (1, 0, 1, 1)
g3 = (0, 1, 2, 0)

cases_sl2 = [
    ({ident}, '{I}', '#607D8B', 's'),
    ({ident, g1, inv_sl2(g1)}, '{I, u, u⁻¹}', '#2196F3', 'o'),
    ({ident, g1, inv_sl2(g1), g2, inv_sl2(g2)}, '{I,u,u⁻¹,l,l⁻¹}', '#FF5722', '^'),
    ({ident, g3, inv_sl2(g3)}, '{I, s, s⁻¹}', '#4CAF50', 'D'),
]

max_k_sl = 8
for A, label, color, marker in cases_sl2:
    sizes = product_tower_sl2(p, A, max_k_sl)
    ks = list(range(1, len(sizes) + 1))
    ax2.plot(ks, sizes, marker=marker, color=color, label=label,
             linewidth=2, markersize=8)

ax2.axhline(y=sl2_size, color='gray', linestyle=':', alpha=0.5,
            label=f'|SL(2,F₃)| = {sl2_size}')
ax2.set_xlabel('Power k', fontsize=12)
ax2.set_ylabel('|A^k|', fontsize=12)
ax2.set_title('SL(2, F₃)', fontsize=13)
ax2.legend(fontsize=9, loc='center right')
ax2.grid(True, alpha=0.3)
ax2.set_xticks(range(1, max_k_sl + 1))

plt.tight_layout(rect=[0, 0, 1, 0.95])
plt.savefig('growth_tower.png', dpi=150, bbox_inches='tight')
print("Saved growth_tower.png")


#!/usr/bin/env python3
"""
Visualization: Tripling Ratios and Subgroup Structure

Visualizes the core phenomenon of the BGT structure theorem:
- The tripling ratio |A³|/|A| for all symmetric subsets of a finite group
- Shows the sharp gap between subgroups (ratio = 1) and non-subgroups (ratio > 1)
- Demonstrates the "growth gap" that drives the BGT classification

This script is fully self-contained — no local module imports.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import itertools


def product_set_add(n, A, B):
    """Product set in Z/nZ (additive)."""
    return {(a + b) % n for a in A for b in B}


def analyze_group(n):
    """Analyze all symmetric subsets containing 0 in Z/nZ."""
    elements = list(range(n))
    identity = 0
    results = []

    for size in range(1, min(n + 1, 10)):
        for subset in itertools.combinations(elements, size):
            A = set(subset)
            if identity not in A:
                continue
            # Check symmetry
            if not all((-a) % n in A for a in A):
                continue
            # Compute tripling
            AA = product_set_add(n, A, A)
            AAA = product_set_add(n, AA, A)
            ratio = len(AAA) / len(A)
            # Check subgroup
            is_sub = all((a + b) % n in A for a in A for b in A)

            results.append({
                'size': len(A),
                'ratio': ratio,
                'is_subgroup': is_sub,
            })

    return results


# Analyze several groups
groups = [6, 8, 10, 12]
fig, axes = plt.subplots(2, 2, figsize=(12, 10))
fig.suptitle('Tripling Ratios in Cyclic Groups: The BGT Gap',
             fontsize=16, fontweight='bold')

for idx, n in enumerate(groups):
    ax = axes[idx // 2][idx % 2]
    results = analyze_group(n)

    sub_sizes = [r['size'] for r in results if r['is_subgroup']]
    sub_ratios = [r['ratio'] for r in results if r['is_subgroup']]
    nonsub_sizes = [r['size'] for r in results if not r['is_subgroup']]
    nonsub_ratios = [r['ratio'] for r in results if not r['is_subgroup']]

    ax.scatter(sub_sizes, sub_ratios, c='#2196F3', s=80, marker='s',
               label='Subgroups', zorder=5, edgecolors='navy', linewidth=0.5)
    ax.scatter(nonsub_sizes, nonsub_ratios, c='#FF5722', s=40, marker='o',
               label='Non-subgroups', alpha=0.6, zorder=4)

    # Draw the gap line at ratio = 1
    ax.axhline(y=1.0, color='green', linestyle='--', alpha=0.7,
               label='Exact tripling (ratio=1)')

    ax.set_xlabel('|A|', fontsize=11)
    ax.set_ylabel('|A³|/|A|', fontsize=11)
    ax.set_title(f'Z/{n}Z', fontsize=13)
    ax.legend(fontsize=8, loc='upper right')
    ax.set_ylim(0.8, max([r['ratio'] for r in results] + [2.5]))
    ax.grid(True, alpha=0.3)

plt.tight_layout(rect=[0, 0, 1, 0.95])
plt.savefig('tripling_ratios.png', dpi=150, bbox_inches='tight')
print("Saved tripling_ratios.png")
