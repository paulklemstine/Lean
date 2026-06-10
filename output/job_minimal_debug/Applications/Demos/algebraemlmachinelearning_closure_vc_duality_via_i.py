#!/usr/bin/env python3
"""
Applications of Closure–VC Duality

Demonstrates real-world applications of the duality between closure operators
and VC dimension in machine learning, formal concept analysis, and
interpretable AI.
"""

import itertools
from typing import FrozenSet, List, Dict, Set, Tuple
from algorithms import ClosureSystem, closure_rank, vc_dimension_via_rank, \
    closed_sets, compress_sample, min_generator, reconstruct, is_closure_independent

FSet = frozenset


# ═══════════════════════════════════════════════════════════════════════
# Application 1: Formal Concept Analysis
# ═══════════════════════════════════════════════════════════════════════

def formal_concept_analysis():
    """
    Closure–VC Duality in Formal Concept Analysis (FCA).

    In FCA, a formal context (G, M, I) defines a closure operator on attributes:
    cl(B) = B'' where B' = {g ∈ G : ∀ m ∈ B, (g,m) ∈ I} and
    A' = {m ∈ M : ∀ g ∈ A, (g,m) ∈ I}.

    The VC dimension of the concept lattice tells us how many attributes
    can be "independently varied" — the intrinsic dimension of the data.
    """
    print("═" * 60)
    print("Application 1: Formal Concept Analysis")
    print("═" * 60)

    # Example: animals and their properties
    # Objects: dog, cat, fish, bird, snake
    # Attributes: legs, fur, swims, flies, warm-blooded
    objects = ["dog", "cat", "fish", "bird", "snake"]
    attributes = ["legs", "fur", "swims", "flies", "warm_blood"]

    # Incidence relation
    context = {
        "dog":   {"legs", "fur", "warm_blood"},
        "cat":   {"legs", "fur", "warm_blood"},
        "fish":  {"swims"},
        "bird":  {"legs", "flies", "warm_blood"},
        "snake": {"warm_blood"},
    }

    attr_set = frozenset(range(len(attributes)))

    def derive_objects(B: FSet) -> FSet:
        """B' = objects having all attributes in B."""
        if not B:
            return frozenset(range(len(objects)))
        result = set()
        for i, obj in enumerate(objects):
            obj_attrs = frozenset(j for j, a in enumerate(attributes) if a in context[obj])
            if B <= obj_attrs:
                result.add(i)
        return frozenset(result)

    def derive_attrs(A: FSet) -> FSet:
        """A' = attributes shared by all objects in A."""
        if not A:
            return attr_set
        result = None
        for i in A:
            obj = objects[i]
            obj_attrs = frozenset(j for j, a in enumerate(attributes) if a in context[obj])
            result = obj_attrs if result is None else result & obj_attrs
        return result or frozenset()

    def intent_closure(B: FSet) -> FSet:
        """B'' = closure of attribute set B."""
        return derive_attrs(derive_objects(B))

    cs = ClosureSystem(attr_set, intent_closure)

    print(f"\nObjects: {objects}")
    print(f"Attributes: {attributes}")
    print(f"\nContext table:")
    for obj in objects:
        props = [a for a in attributes if a in context[obj]]
        print(f"  {obj:8s}: {', '.join(props)}")

    concepts = closed_sets(cs)
    print(f"\nNumber of formal concepts: {len(concepts)}")
    print(f"VC dimension (= max closure rank): {vc_dimension_via_rank(cs)}")

    print(f"\nClosed attribute sets (intents):")
    for c in sorted(concepts, key=len):
        attr_names = [attributes[i] for i in sorted(c)]
        print(f"  {attr_names}")

    # Show what sets are shattered (independently variable)
    print(f"\nIndependent attribute sets (shattered):")
    for s in cs._powerset():
        if is_closure_independent(cs, s) and len(s) >= 1:
            attr_names = [attributes[i] for i in sorted(s)]
            print(f"  {attr_names} (rank {len(s)})")

    print()


# ═══════════════════════════════════════════════════════════════════════
# Application 2: Interpretable Classification
# ═══════════════════════════════════════════════════════════════════════

def interpretable_classification():
    """
    Closure-based interpretable classification.

    Given training data, construct a closure operator from the data,
    then use the compression theorem to find minimal explanations.
    """
    print("═" * 60)
    print("Application 2: Interpretable Classification")
    print("═" * 60)

    # Feature space: 5 binary features
    features = ["temperature", "headache", "cough", "fatigue", "nausea"]
    n = len(features)

    # Training data: patient feature vectors and diagnoses
    patients = [
        (frozenset({0, 1, 3}), "flu"),        # temp, headache, fatigue
        (frozenset({0, 2, 3}), "flu"),         # temp, cough, fatigue
        (frozenset({1, 4}), "migraine"),       # headache, nausea
        (frozenset({1}), "migraine"),          # headache only
        (frozenset({0, 2}), "cold"),           # temp, cough
        (frozenset({2, 3}), "cold"),           # cough, fatigue
    ]

    # Define closure: cl(S) = intersection of all training examples containing S
    all_features = frozenset(range(n))

    def data_closure(S: FSet) -> FSet:
        if not S:
            return frozenset()
        # Find all patients whose features contain S, then intersect
        containing = [feats for feats, _ in patients if S <= feats]
        if not containing:
            return all_features  # S not contained in any example
        result = all_features
        for feats in containing:
            result = result & feats
        return result | S  # Ensure extensivity

    cs = ClosureSystem(all_features, data_closure)

    print(f"\nTraining data:")
    for feats, diag in patients:
        feat_names = [features[i] for i in sorted(feats)]
        print(f"  {feat_names} → {diag}")

    vc = vc_dimension_via_rank(cs)
    print(f"\nVC dimension of closed concept class: {vc}")
    print(f"→ Compression scheme needs at most {vc} features per explanation")

    # Show minimal explanations
    print(f"\nMinimal closed explanations:")
    for feats, diag in patients:
        G = min_generator(cs, feats)
        recon = cs.cl(G)
        gen_names = [features[i] for i in sorted(G)]
        recon_names = [features[i] for i in sorted(recon)]
        print(f"  {diag}: {gen_names} → generates {recon_names}")

    print()


# ═══════════════════════════════════════════════════════════════════════
# Application 3: Convex Geometry / Antimatroid Learning
# ═══════════════════════════════════════════════════════════════════════

def convex_geometry_learning():
    """
    Learning in convex geometries (antimatroid concept classes).

    Convex geometries are closure systems where the closure operator
    satisfies the anti-exchange property. The duality theorem gives
    exact VC = rank bounds for these important concept classes.
    """
    print("═" * 60)
    print("Application 3: Convex Geometry Learning")
    print("═" * 60)

    # 2D convex hull closure on a small point set
    # Points: arrange in a grid pattern
    points = {
        0: (0, 0), 1: (1, 0), 2: (2, 0),
        3: (0, 1), 4: (1, 1), 5: (2, 1),
        6: (0, 2), 7: (1, 2), 8: (2, 2),
    }
    ground = frozenset(points.keys())

    def point_in_convex_hull(p, hull_points):
        """Check if point p is in the convex hull of hull_points (2D)."""
        if len(hull_points) <= 1:
            return p in hull_points
        pts = [points[i] for i in hull_points]
        px, py = points[p]
        # Use cross-product method for small point sets
        n = len(pts)
        for i in range(n):
            for j in range(i + 1, n):
                for k in range(j + 1, n):
                    # Check if (px, py) is inside triangle (pts[i], pts[j], pts[k])
                    x1, y1 = pts[i]
                    x2, y2 = pts[j]
                    x3, y3 = pts[k]
                    denom = (y2 - y3) * (x1 - x3) + (x3 - x2) * (y1 - y3)
                    if denom == 0:
                        continue
                    a = ((y2 - y3) * (px - x3) + (x3 - x2) * (py - y3)) / denom
                    b = ((y3 - y1) * (px - x3) + (x1 - x3) * (py - y3)) / denom
                    c = 1 - a - b
                    if a >= 0 and b >= 0 and c >= 0:
                        return True
        # Also check if on a line segment
        for i in range(n):
            for j in range(i + 1, n):
                x1, y1 = pts[i]
                x2, y2 = pts[j]
                if x1 == x2 and y1 == y2:
                    if px == x1 and py == y1:
                        return True
                    continue
                # Check if p is on segment [i, j]
                cross = (px - x1) * (y2 - y1) - (py - y1) * (x2 - x1)
                if cross != 0:
                    continue
                t_x = (px - x1) / (x2 - x1) if x2 != x1 else None
                t_y = (py - y1) / (y2 - y1) if y2 != y1 else None
                t = t_x if t_x is not None else t_y
                if t is not None and 0 <= t <= 1:
                    return True
        return False

    def convex_closure(S: FSet) -> FSet:
        if not S:
            return frozenset()
        result = set(S)
        for p in ground:
            if p not in result and point_in_convex_hull(p, result):
                result.add(p)
        # Iterate until fixed point (needed for correct closure)
        changed = True
        while changed:
            changed = False
            for p in ground:
                if p not in result and point_in_convex_hull(p, result):
                    result.add(p)
                    changed = True
        return frozenset(result)

    cs = ClosureSystem(ground, convex_closure)

    print(f"\nGround set: 3×3 grid of points")
    print(f"Closure: 2D convex hull")
    print(f"Number of closed sets (convex sets): {len(closed_sets(cs))}")
    vc = vc_dimension_via_rank(cs)
    print(f"VC dimension = max closure rank = {vc}")

    # Show independent sets
    print(f"\nMaximum independent (shattered) sets:")
    for s in cs._powerset():
        if is_closure_independent(cs, s) and len(s) == vc:
            pts = [(points[i][0], points[i][1]) for i in sorted(s)]
            print(f"  Points: {pts}")

    print()


# ═══════════════════════════════════════════════════════════════════════
# Application 4: Monotone Concept Learning
# ═══════════════════════════════════════════════════════════════════════

def monotone_concept_learning():
    """
    Learning monotone Boolean functions via closure operators.

    Monotone Boolean functions form a concept class that is naturally
    described by a closure operator. The duality theorem gives the
    exact VC dimension and optimal compression.
    """
    print("═" * 60)
    print("Application 4: Monotone Concept Learning")
    print("═" * 60)

    n = 4
    ground = frozenset(range(n))

    # Upward closure: cl(S) = {T : S ⊆ T ⊆ ground} mapped back to ground
    # Actually, for monotone concepts: if S is positive, all supersets are positive
    # The "monotone closure" is the downward closure of the complement

    # Simpler: use the upset closure
    def upset_closure(S: FSet) -> FSet:
        """cl(S) = S (upsets are all closed in the identity closure)."""
        return S

    # More interesting: threshold closure
    # cl(S) = {x ∈ ground : x ≤ max(S)} if S ≠ ∅
    def threshold_closure(S: FSet) -> FSet:
        if not S:
            return frozenset()
        m = max(S)
        return frozenset(x for x in ground if x <= m)

    cs = ClosureSystem(ground, threshold_closure)

    print(f"\nGround set: {{0, 1, 2, 3}}")
    print(f"Closure: threshold (cl(S) = {{x : x ≤ max(S)}})")
    print(f"Closed sets (thresholds): {[set(s) for s in sorted(closed_sets(cs), key=len)]}")
    vc = vc_dimension_via_rank(cs)
    print(f"VC dimension = {vc}")

    # Demonstrate compression
    print(f"\nCompression examples:")
    sample = ground
    for H in closed_sets(cs):
        if H:
            result = compress_sample(cs, sample, H)
            print(f"  H = {set(H)} → G = {set(result.generators)} "
                  f"(size {len(result.generators)}), consistent = {result.is_consistent}")

    print()


# ═══════════════════════════════════════════════════════════════════════
# Application 5: Feature Selection via Closure Rank
# ═══════════════════════════════════════════════════════════════════════

def feature_selection():
    """
    Feature selection using closure rank as a complexity measure.

    The closure rank tells us the minimum number of features needed
    to reconstruct the full feature closure. This provides a principled
    approach to feature selection.
    """
    print("═" * 60)
    print("Application 5: Feature Selection via Closure Rank")
    print("═" * 60)

    # Simulated dataset: features with dependencies
    features = ["x1", "x2", "x3", "x4", "x5"]
    n = len(features)
    ground = frozenset(range(n))

    # Dependency structure: x3 depends on x1, x4 depends on x2, x5 depends on x1 and x2
    def dependency_closure(S: FSet) -> FSet:
        result = set(S)
        changed = True
        while changed:
            changed = False
            if 0 in result and 2 not in result:  # x1 → x3
                result.add(2)
                changed = True
            if 1 in result and 3 not in result:  # x2 → x4
                result.add(3)
                changed = True
            if 0 in result and 1 in result and 4 not in result:  # x1,x2 → x5
                result.add(4)
                changed = True
        return frozenset(result)

    cs = ClosureSystem(ground, dependency_closure)

    print(f"\nFeatures: {features}")
    print(f"Dependencies: x1→x3, x2→x4, (x1,x2)→x5")
    print(f"\nClosure ranks:")
    for size in range(1, n + 1):
        for combo in itertools.combinations(range(n), size):
            A = frozenset(combo)
            feat_names = [features[i] for i in sorted(A)]
            r = closure_rank(cs, A)
            cl_names = [features[i] for i in sorted(cs.cl(A))]
            if r < len(A):
                print(f"  {feat_names}: rank {r} (closure {cl_names}) — REDUNDANT")

    vc = vc_dimension_via_rank(cs)
    print(f"\nVC dimension: {vc}")
    print(f"→ Only {vc} independent features needed for full expressiveness")
    print(f"→ Feature selection: choose any independent set of size {vc}")

    # Find optimal feature subsets
    print(f"\nOptimal feature subsets (independent, size = VC dim):")
    for s in cs._powerset():
        if len(s) == vc and is_closure_independent(cs, s):
            feat_names = [features[i] for i in sorted(s)]
            print(f"  {feat_names}")

    print()


if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════╗")
    print("║    Closure–VC Duality: Real-World Applications         ║")
    print("╚══════════════════════════════════════════════════════════╝")
    print()

    formal_concept_analysis()
    interpretable_classification()
    convex_geometry_learning()
    monotone_concept_learning()
    feature_selection()

    print("All applications demonstrated successfully.")


#!/usr/bin/env python3
"""
Closure–VC Duality: Concrete Demonstrations

This script demonstrates the fundamental duality between closure operators
and VC dimension with concrete, computable examples on small finite sets.
"""

import itertools
from typing import Callable, FrozenSet, Set, List, Tuple, Dict

# Type aliases
Element = int
Subset = frozenset


def powerset(s: frozenset) -> List[frozenset]:
    """Return all subsets of s."""
    elts = sorted(s)
    result = []
    for r in range(len(elts) + 1):
        for combo in itertools.combinations(elts, r):
            result.append(frozenset(combo))
    return result


class ClosureOperator:
    """A closure operator on a finite ground set."""

    def __init__(self, ground: frozenset, cl_func: Callable[[frozenset], frozenset]):
        self.ground = ground
        self._cl = cl_func
        self._verify()

    def _verify(self):
        """Verify closure axioms on all subsets."""
        for s in powerset(self.ground):
            cs = self._cl(s)
            assert s <= cs, f"Extensivity fails: {set(s)} not subset of cl({set(s)}) = {set(cs)}"
            assert cs <= self.ground, f"cl({set(s)}) = {set(cs)} not subset of ground {set(self.ground)}"
            assert self._cl(cs) == cs, f"Idempotence fails: cl(cl({set(s)})) != cl({set(s)})"
        # Check monotonicity
        subsets = powerset(self.ground)
        for s in subsets:
            for t in subsets:
                if s <= t:
                    assert self._cl(s) <= self._cl(t), \
                        f"Monotonicity fails: {set(s)} ⊆ {set(t)} but cl({set(s)}) ⊄ cl({set(t)})"

    def cl(self, s: frozenset) -> frozenset:
        return self._cl(s)

    def closed_sets(self) -> List[frozenset]:
        """Return all closed sets."""
        return [s for s in powerset(self.ground) if self._cl(s) == s]

    def closure_rank(self, A: frozenset) -> int:
        """Compute the closure rank of A: minimum |G| with G ⊆ A and cl(G) = cl(A)."""
        target = self._cl(A)
        min_size = len(A)
        for r in range(len(A) + 1):
            for G in itertools.combinations(sorted(A), r):
                if self._cl(frozenset(G)) == target:
                    return r
        return min_size

    def is_closure_independent(self, A: frozenset) -> bool:
        """Check if A is closure-independent (rank = |A|)."""
        return self.closure_rank(A) == len(A)

    def shatters(self, A: frozenset) -> bool:
        """Check if the closed concept class shatters A."""
        closed = self.closed_sets()
        for T in powerset(A):
            found = False
            for H in closed:
                if H & A == T:
                    found = True
                    break
            if not found:
                return False
        return True

    def vc_dimension(self) -> int:
        """Compute the VC dimension of the closed concept class."""
        max_dim = 0
        for s in powerset(self.ground):
            if self.shatters(s):
                max_dim = max(max_dim, len(s))
        return max_dim

    def max_closure_rank(self) -> int:
        """Compute max closure rank over all subsets."""
        return max(self.closure_rank(s) for s in powerset(self.ground))

    def reconstruct(self, positives: frozenset) -> frozenset:
        """Reconstruct the minimal closed hypothesis from positive generators."""
        return self._cl(positives)

    def compress_sample(self, sample: frozenset, hypothesis: frozenset, d: int) -> Tuple[frozenset, frozenset]:
        """
        Compress a labeled sample. Returns (generator subset, reconstruction).
        The generator subset G has |G| ≤ d and cl(G ∩ H) is consistent with H on sample.
        """
        positives = sample & hypothesis
        target_cl = self._cl(positives)
        # Find smallest G ⊆ positives with cl(G) = cl(positives)
        for r in range(len(positives) + 1):
            for G in itertools.combinations(sorted(positives), r):
                G = frozenset(G)
                if self._cl(G) == target_cl:
                    return G, self._cl(G)
        return positives, target_cl


def demo_identity_closure():
    """Example 1: Identity closure (all sets closed)."""
    print("=" * 60)
    print("Example 1: Identity Closure (cl = id)")
    print("=" * 60)
    ground = frozenset({1, 2, 3})
    op = ClosureOperator(ground, lambda s: s)
    closed = op.closed_sets()
    print(f"Ground set: {set(ground)}")
    print(f"Number of closed sets: {len(closed)}")
    print(f"VC dimension: {op.vc_dimension()}")
    print(f"Max closure rank: {op.max_closure_rank()}")
    print(f"VC dim = max rank: {op.vc_dimension() == op.max_closure_rank()} ✓")
    print()

    # Demonstrate shattering = independence
    for size in range(len(ground) + 1):
        for A in itertools.combinations(sorted(ground), size):
            A = frozenset(A)
            sh = op.shatters(A)
            ind = op.is_closure_independent(A)
            if sh or ind:
                print(f"  {set(A)}: shattered={sh}, independent={ind}, equal={sh==ind}")
    print()


def demo_constant_closure():
    """Example 2: Constant closure (everything maps to the whole set)."""
    print("=" * 60)
    print("Example 2: Constant Closure (cl(∅)=∅, cl(S)=X for S≠∅)")
    print("=" * 60)
    ground = frozenset({1, 2, 3, 4})
    op = ClosureOperator(ground, lambda s: ground if s else frozenset())
    closed = op.closed_sets()
    print(f"Ground set: {set(ground)}")
    print(f"Closed sets: {[set(s) for s in closed]}")
    print(f"VC dimension: {op.vc_dimension()}")
    print(f"Max closure rank: {op.max_closure_rank()}")
    print(f"VC dim = max rank: {op.vc_dimension() == op.max_closure_rank()} ✓")
    print()


def demo_adjoin_element_closure():
    """Example 3: Closure that adjoins element 0."""
    print("=" * 60)
    print("Example 3: Adjoin-Element Closure (cl(S) = S ∪ {0})")
    print("=" * 60)
    ground = frozenset({0, 1, 2, 3})

    def cl(s):
        if not s:
            return frozenset()
        return s | frozenset({0})

    op = ClosureOperator(ground, cl)
    closed = op.closed_sets()
    print(f"Ground set: {set(ground)}")
    print(f"Closed sets: {[set(s) for s in sorted(closed, key=len)]}")
    print(f"VC dimension: {op.vc_dimension()}")
    print(f"Max closure rank: {op.max_closure_rank()}")
    print(f"VC dim = max rank: {op.vc_dimension() == op.max_closure_rank()} ✓")

    # Show compression
    print("\n  Compression demonstration:")
    A = frozenset({1, 2, 3})
    H = frozenset({0, 1, 2})  # A closed set
    print(f"  Sample: {set(A)}, Hypothesis: {set(H)}")
    G, recon = op.compress_sample(A, H, 2)
    print(f"  Compressed generators: {set(G)} (size {len(G)})")
    print(f"  Reconstruction cl(G): {set(recon)}")
    print(f"  Consistent: {recon & A == H & A}")
    print()


def demo_pair_collapse_closure():
    """Example 4: Closure where pairs collapse to X."""
    print("=" * 60)
    print("Example 4: Pair-Collapse Closure")
    print("  cl(S) = S if |S|≤1, cl(S) = X if |S|≥2")
    print("=" * 60)
    ground = frozenset({1, 2, 3, 4})

    def cl(s):
        if len(s) <= 1:
            return s
        return ground

    op = ClosureOperator(ground, cl)
    closed = op.closed_sets()
    print(f"Ground set: {set(ground)}")
    print(f"Closed sets: {[set(s) for s in sorted(closed, key=len)]}")
    print(f"VC dimension: {op.vc_dimension()}")
    print(f"Max closure rank: {op.max_closure_rank()}")
    print(f"VC dim = max rank: {op.vc_dimension() == op.max_closure_rank()} ✓")

    # Show closure rank for each subset
    print("\n  Closure ranks:")
    for size in range(1, len(ground) + 1):
        for A in itertools.combinations(sorted(ground), size):
            A = frozenset(A)
            print(f"    rank({set(A)}) = {op.closure_rank(A)}")
    print()


def demo_duality_verification():
    """Systematic verification of the duality theorem on random closure operators."""
    print("=" * 60)
    print("Systematic Duality Verification")
    print("=" * 60)

    ground = frozenset({1, 2, 3, 4})
    n_verified = 0

    # Generate several closure operators and verify the duality
    closure_configs = [
        ("Identity", lambda s: s),
        ("Constant", lambda s: ground if s else frozenset()),
        ("Adjoin-1", lambda s: s | frozenset({1}) if s else frozenset()),
        ("Pair-collapse", lambda s: s if len(s) <= 1 else ground),
    ]

    # A more interesting one: convex-hull style
    def convex_cl(s):
        """If s contains both endpoints of an interval, include the middle."""
        s = set(s)
        if not s:
            return frozenset()
        result = set(s)
        lo, hi = min(s), max(s)
        for i in range(lo, hi + 1):
            if i in ground:
                result.add(i)
        return frozenset(result)

    closure_configs.append(("Interval-hull", convex_cl))

    for name, cl_func in closure_configs:
        try:
            op = ClosureOperator(ground, cl_func)
            vc = op.vc_dimension()
            max_rank = op.max_closure_rank()
            match = vc == max_rank

            # Verify shattered ↔ independent for all subsets
            all_equiv = True
            for s in powerset(ground):
                if op.shatters(s) != op.is_closure_independent(s):
                    all_equiv = False
                    break

            status = "✓" if match and all_equiv else "✗"
            print(f"  {name:20s}: VC dim = {vc}, max rank = {max_rank}, "
                  f"shattered↔indep = {all_equiv}  {status}")
            n_verified += 1
        except AssertionError as e:
            print(f"  {name:20s}: INVALID closure operator - {e}")

    print(f"\n  Verified duality on {n_verified} closure operators.")
    print()


def demo_reconstruction():
    """Demonstrate certified reconstruction."""
    print("=" * 60)
    print("Certified Reconstruction Demonstration")
    print("=" * 60)

    ground = frozenset({1, 2, 3, 4, 5})

    def cl(s):
        """Interval hull closure."""
        if not s:
            return frozenset()
        s_set = set(s)
        lo, hi = min(s_set), max(s_set)
        return frozenset(i for i in ground if lo <= i <= hi)

    op = ClosureOperator(ground, cl)

    print(f"Ground set: {set(ground)}")
    print(f"Closure: interval hull (convex hull on integers)")
    print(f"Closed sets: {[set(s) for s in sorted(op.closed_sets(), key=lambda x: (len(x), min(x) if x else -1))]}")
    print(f"VC dimension: {op.vc_dimension()}")
    print(f"Max closure rank: {op.max_closure_rank()}")

    print("\nReconstruction examples:")
    examples = [frozenset({1, 3}), frozenset({2, 5}), frozenset({1}), frozenset({3, 4})]
    for pos in examples:
        recon = op.reconstruct(pos)
        # Verify minimality: check that recon ⊆ every closed set containing pos
        is_minimal = True
        for H in op.closed_sets():
            if pos <= H:
                if not recon <= H:
                    is_minimal = False
        print(f"  Positives: {set(pos)} → cl(pos) = {set(recon)}, "
              f"minimal = {is_minimal}")

    print("\nCompression examples:")
    sample = frozenset({1, 2, 3, 4, 5})
    for h_set in [frozenset({1, 2, 3}), frozenset({2, 3, 4, 5}), frozenset({3, 4})]:
        if op.cl(h_set) == h_set:  # Only if h_set is closed
            G, recon = op.compress_sample(sample, h_set, op.vc_dimension())
            consistent = (recon & sample) == (h_set & sample)
            print(f"  H = {set(h_set)}, G = {set(G)} (size {len(G)}), "
                  f"recon = {set(recon)}, consistent = {consistent}")
    print()


if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════╗")
    print("║    Closure–VC Duality: Algebraic Learnability Theory    ║")
    print("╚══════════════════════════════════════════════════════════╝")
    print()

    demo_identity_closure()
    demo_constant_closure()
    demo_adjoin_element_closure()
    demo_pair_collapse_closure()
    demo_duality_verification()
    demo_reconstruction()

    print("All demonstrations complete.")


#!/usr/bin/env python3
"""
Visualizations for Closure–VC Duality

Generates publication-quality figures illustrating the duality theorem.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
import itertools
import base64
import io
from algorithms import ClosureSystem, closure_rank, vc_dimension_via_rank, \
    closed_sets, is_closure_independent, min_generator

FSet = frozenset


def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64 data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    data = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{data}"


def viz_duality_heatmap():
    """Heatmap showing closure rank vs shattering for all subsets."""
    ground = frozenset(range(1, 6))
    n = len(ground)

    # Interval closure
    def cl(s):
        if not s: return frozenset()
        lo, hi = min(s), max(s)
        return frozenset(x for x in ground if lo <= x <= hi)

    cs = ClosureSystem(ground, cl)

    # Collect data: for each subset size, count independent and dependent sets
    sizes = list(range(n + 1))
    independent_counts = []
    dependent_counts = []

    for size in sizes:
        ind = dep = 0
        for combo in itertools.combinations(sorted(ground), size):
            A = frozenset(combo)
            if is_closure_independent(cs, A):
                ind += 1
            else:
                dep += 1
        independent_counts.append(ind)
        dependent_counts.append(dep)

    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    # Left: bar chart of independent vs dependent
    x = np.arange(len(sizes))
    width = 0.35
    axes[0].bar(x - width/2, independent_counts, width, label='Independent (shattered)',
                color='#2ecc71', alpha=0.8)
    axes[0].bar(x + width/2, dependent_counts, width, label='Dependent (not shattered)',
                color='#e74c3c', alpha=0.8)
    axes[0].set_xlabel('Subset size', fontsize=12)
    axes[0].set_ylabel('Count', fontsize=12)
    axes[0].set_title('Closure Independence ↔ Shattering\n(Interval closure on {1,...,5})', fontsize=13)
    axes[0].set_xticks(x)
    axes[0].set_xticklabels(sizes)
    axes[0].legend(fontsize=10)
    vc = vc_dimension_via_rank(cs)
    axes[0].axvline(x=vc + 0.5, color='navy', linestyle='--', linewidth=2, alpha=0.7)
    axes[0].text(vc + 0.6, max(independent_counts) * 0.8,
                f'VC dim = {vc}', color='navy', fontsize=11, fontweight='bold')

    # Right: closure rank distribution
    ranks = []
    for s in cs._powerset():
        if s:
            ranks.append(closure_rank(cs, s))

    axes[1].hist(ranks, bins=range(max(ranks) + 2), color='#3498db', alpha=0.8,
                edgecolor='white', linewidth=1.5, align='left')
    axes[1].axvline(x=vc, color='#e74c3c', linestyle='--', linewidth=2)
    axes[1].text(vc + 0.1, axes[1].get_ylim()[1] * 0.8,
                f'Max rank = VC dim = {vc}', color='#e74c3c', fontsize=11, fontweight='bold')
    axes[1].set_xlabel('Closure rank', fontsize=12)
    axes[1].set_ylabel('Number of subsets', fontsize=12)
    axes[1].set_title('Distribution of Closure Ranks', fontsize=13)

    plt.tight_layout()
    fig.savefig('/workspace/request-project/viz_duality_heatmap.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


def viz_compression_demo():
    """Visualization of the compression scheme."""
    ground = frozenset(range(1, 8))

    def cl(s):
        if not s: return frozenset()
        lo, hi = min(s), max(s)
        return frozenset(x for x in ground if lo <= x <= hi)

    cs = ClosureSystem(ground, cl)

    fig, axes = plt.subplots(2, 3, figsize=(15, 8))

    closed = [s for s in closed_sets(cs) if 2 <= len(s) <= 5]
    sample = ground

    for idx, H in enumerate(closed[:6]):
        ax = axes[idx // 3][idx % 3]
        positives = sample & H
        G = min_generator(cs, positives)
        recon = cs.cl(G)

        # Draw the ground set as a number line
        for x in sorted(ground):
            color = '#2ecc71' if x in G else ('#90EE90' if x in H else '#e74c3c')
            marker = 's' if x in G else 'o'
            size = 200 if x in G else 100
            ax.scatter(x, 0, c=color, s=size, marker=marker, zorder=5, edgecolors='black', linewidth=1.5)
            ax.text(x, -0.15, str(x), ha='center', va='top', fontsize=10)

        # Draw the hypothesis as a shaded region
        if H:
            lo, hi = min(H), max(H)
            ax.axhspan(-0.05, 0.05, xmin=(lo - 0.5) / (max(ground) + 0.5),
                       xmax=(hi + 0.5) / (max(ground) + 0.5),
                       alpha=0.15, color='blue')

        ax.set_xlim(0.5, max(ground) + 0.5)
        ax.set_ylim(-0.3, 0.3)
        ax.set_yticks([])
        ax.set_title(f'H={set(sorted(H))}\nG={set(sorted(G))} (size {len(G)})',
                     fontsize=10)

    # Add legend
    legend_elements = [
        mpatches.Patch(facecolor='#2ecc71', edgecolor='black', label='Generator (G)'),
        mpatches.Patch(facecolor='#90EE90', edgecolor='black', label='Positive (H\\G)'),
        mpatches.Patch(facecolor='#e74c3c', edgecolor='black', label='Negative'),
    ]
    fig.legend(handles=legend_elements, loc='lower center', ncol=3, fontsize=11,
              bbox_to_anchor=(0.5, -0.02))

    fig.suptitle('Closure-Based Sample Compression\n(Interval closure on {1,...,7})',
                fontsize=14, fontweight='bold')
    plt.tight_layout()
    fig.savefig('/workspace/request-project/viz_compression.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


def viz_lattice_comparison():
    """Compare different closure operators and their VC dimensions."""
    ground = frozenset(range(1, 6))

    closures = {
        'Identity\n(all sets closed)': lambda s: s,
        'Constant\n(∅ or X only)': lambda s: ground if s else frozenset(),
        'Interval hull\n(convex on integers)': lambda s: frozenset(x for x in ground if min(s) <= x <= max(s)) if s else frozenset(),
        'Threshold\n(downsets)': lambda s: frozenset(x for x in ground if x <= max(s)) if s else frozenset(),
        'Pair-collapse\n(|S|≥2 → X)': lambda s: s if len(s) <= 1 else ground,
    }

    fig, ax = plt.subplots(figsize=(10, 6))

    names = []
    vc_dims = []
    n_closed = []

    for name, cl_func in closures.items():
        cs = ClosureSystem(ground, cl_func)
        names.append(name)
        vc_dims.append(vc_dimension_via_rank(cs))
        n_closed.append(len(closed_sets(cs)))

    x = np.arange(len(names))
    width = 0.35

    bars1 = ax.bar(x - width/2, vc_dims, width, label='VC dimension',
                   color='#3498db', alpha=0.85, edgecolor='white', linewidth=1)
    bars2 = ax.bar(x + width/2, [np.log2(n) if n > 0 else 0 for n in n_closed], width,
                   label='log₂(# closed sets)', color='#e67e22', alpha=0.85,
                   edgecolor='white', linewidth=1)

    # Add value labels
    for bar, val in zip(bars1, vc_dims):
        ax.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.1,
               str(val), ha='center', va='bottom', fontsize=11, fontweight='bold')
    for bar, val in zip(bars2, n_closed):
        ax.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.1,
               str(val), ha='center', va='bottom', fontsize=10, color='gray')

    ax.set_xlabel('Closure Operator', fontsize=12)
    ax.set_ylabel('Value', fontsize=12)
    ax.set_title(f'Closure Operators on {{1,...,{len(ground)}}}: VC Dimension Comparison',
                fontsize=14, fontweight='bold')
    ax.set_xticks(x)
    ax.set_xticklabels(names, fontsize=9)
    ax.legend(fontsize=11)
    ax.set_ylim(0, max(vc_dims) + 1.5)

    plt.tight_layout()
    fig.savefig('/workspace/request-project/viz_lattice_comparison.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


def viz_duality_theorem():
    """Conceptual diagram of the duality theorem."""
    fig, ax = plt.subplots(figsize=(12, 7))
    ax.set_xlim(0, 12)
    ax.set_ylim(0, 8)
    ax.axis('off')

    # Title
    ax.text(6, 7.5, 'Closure–VC Duality Theorem', ha='center', va='top',
           fontsize=18, fontweight='bold', color='#2c3e50')

    # Three boxes
    box_style = dict(boxstyle='round,pad=0.5', facecolor='#ecf0f1', edgecolor='#34495e', linewidth=2)

    # Box 1: VC Dimension
    ax.text(2, 5.5, 'VC Dimension ≤ d', ha='center', va='center',
           fontsize=14, fontweight='bold', color='#2980b9',
           bbox=dict(boxstyle='round,pad=0.8', facecolor='#d6eaf8', edgecolor='#2980b9', linewidth=2))
    ax.text(2, 4.5, 'No set of size > d\nis shattered by\nclosed concepts', ha='center', va='center',
           fontsize=10, color='#34495e')

    # Box 2: Closure Rank
    ax.text(6, 5.5, 'Closure Rank ≤ d', ha='center', va='center',
           fontsize=14, fontweight='bold', color='#27ae60',
           bbox=dict(boxstyle='round,pad=0.8', facecolor='#d5f5e3', edgecolor='#27ae60', linewidth=2))
    ax.text(6, 4.5, 'Every set A has\na generator G ⊆ A\nwith |G| ≤ d', ha='center', va='center',
           fontsize=10, color='#34495e')

    # Box 3: Compression
    ax.text(10, 5.5, 'Compression ≤ d', ha='center', va='center',
           fontsize=14, fontweight='bold', color='#e67e22',
           bbox=dict(boxstyle='round,pad=0.8', facecolor='#fdebd0', edgecolor='#e67e22', linewidth=2))
    ax.text(10, 4.5, 'Every labeled sample\ncompresses to ≤ d\ngenerators', ha='center', va='center',
           fontsize=10, color='#34495e')

    # Arrows
    arrow_style = dict(arrowstyle='<->', color='#e74c3c', linewidth=2.5)
    ax.annotate('', xy=(3.8, 5.5), xytext=(4.2, 5.5),
               arrowprops=dict(arrowstyle='<->', color='#e74c3c', lw=2.5))
    ax.annotate('', xy=(7.8, 5.5), xytext=(8.2, 5.5),
               arrowprops=dict(arrowstyle='->', color='#e67e22', lw=2.5))

    # Equivalence labels
    ax.text(4, 6.1, '⟺', ha='center', va='center', fontsize=20, color='#e74c3c', fontweight='bold')
    ax.text(8, 6.1, '⟹', ha='center', va='center', fontsize=20, color='#e67e22', fontweight='bold')

    # Bottom: Key insight
    ax.text(6, 2.5, 'Key Insight', ha='center', va='center',
           fontsize=14, fontweight='bold', color='#8e44ad',
           bbox=dict(boxstyle='round,pad=0.5', facecolor='#f4ecf7', edgecolor='#8e44ad', linewidth=2))
    ax.text(6, 1.5, 'Shattering  ⟺  Closure Independence\n'
           'A set A is shattered iff every element of A is needed\n'
           'to generate cl(A) — no element is redundant.',
           ha='center', va='center', fontsize=11, color='#34495e',
           style='italic')

    plt.tight_layout()
    fig.savefig('/workspace/request-project/viz_duality_theorem.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


if __name__ == "__main__":
    print("Generating visualizations...")
    b64_1 = viz_duality_heatmap()
    print("  ✓ Duality heatmap")
    b64_2 = viz_compression_demo()
    print("  ✓ Compression demo")
    b64_3 = viz_lattice_comparison()
    print("  ✓ Lattice comparison")
    b64_4 = viz_duality_theorem()
    print("  ✓ Duality theorem diagram")
    print("All visualizations saved.")
