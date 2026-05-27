#!/usr/bin/env python3
"""
Algorithms for Approximate Subgroup Analysis

Implements the computational methods underlying the BGT structure theorem
in the K ≈ 1 regime. These algorithms detect subgroup structure from
product-set growth data.

Core algorithms:
1. Product tower computation (A, A², A³, ..., Aᵏ)
2. Subgroup detection from exact tripling
3. Growth gap estimation
4. Trace set analysis for SL(2, F_p)
"""

from typing import Callable, Dict, List, Optional, Set, Tuple
import itertools


# ──────────────────────────────────────────────────────────────
# Core Data Structures
# ──────────────────────────────────────────────────────────────

class GroupOps:
    """
    Encapsulates group operations for a finite group.

    Attributes:
        elements: list of group elements
        mul: binary operation (a, b) -> a*b
        inv: unary inverse a -> a^{-1}
        identity: the identity element
    """
    def __init__(self, elements: list, mul: Callable, inv: Callable, identity):
        self.elements = elements
        self.mul = mul
        self.inv = inv
        self.identity = identity
        self.size = len(elements)


class ApproxSubgroupReport:
    """
    Report from analyzing a subset of a finite group.

    Mirrors the Lean `ApproxSubgroupReport` structure.
    """
    def __init__(self, carrier: set, G: GroupOps):
        self.carrier = carrier
        self.G = G
        self.card_A = len(carrier)

        # Compute product sets
        self.AA = product_set(G, carrier, carrier)
        self.AAA = product_set(G, self.AA, carrier)

        self.card_AA = len(self.AA)
        self.card_AAA = len(self.AAA)

        # Ratios
        self.doubling_ratio = self.card_AA / self.card_A if self.card_A > 0 else float('inf')
        self.tripling_ratio = self.card_AAA / self.card_A if self.card_A > 0 else float('inf')

        # Structural properties
        self.has_one = G.identity in carrier
        self.is_symmetric = all(G.inv(a) in carrier for a in carrier)
        self.is_mul_closed = all(
            G.mul(a, b) in carrier for a in carrier for b in carrier
        )
        self.is_subgroup = self.has_one and self.is_symmetric and self.is_mul_closed

        # Exact tripling check
        self.has_exact_tripling = (self.card_AAA == self.card_A)

        # Classify
        self.classification = self._classify()

    def _classify(self) -> str:
        """Classify the subset according to BGT structure theory."""
        if not self.has_one:
            return "NOT_APPROX_SUBGROUP (missing identity)"
        if not self.is_symmetric:
            return "NOT_APPROX_SUBGROUP (not symmetric)"
        if self.has_exact_tripling:
            if self.is_subgroup:
                return "EXACT_SUBGROUP (|A³|=|A|, confirmed subgroup by Theorem 2)"
            else:
                return "ERROR (|A³|=|A| but not subgroup — contradicts theorem)"
        if self.tripling_ratio < 2:
            return f"NEAR_SUBGROUP (|A³|/|A| = {self.tripling_ratio:.3f} < 2)"
        return f"GROWING (|A³|/|A| = {self.tripling_ratio:.3f})"

    def __repr__(self) -> str:
        return (f"ApproxSubgroupReport(|A|={self.card_A}, |A²|={self.card_AA}, "
                f"|A³|={self.card_AAA}, ratio={self.tripling_ratio:.3f}, "
                f"class={self.classification})")


# ──────────────────────────────────────────────────────────────
# Algorithm 1: Product Set Computation
# ──────────────────────────────────────────────────────────────

def product_set(G: GroupOps, A: set, B: set) -> set:
    """
    Compute the product set A·B = {a*b : a ∈ A, b ∈ B}.

    Time complexity: O(|A| · |B|)
    Space complexity: O(|A·B|)

    Args:
        G: group operations
        A: first subset
        B: second subset

    Returns:
        The product set A·B
    """
    return {G.mul(a, b) for a in A for b in B}


def product_tower(G: GroupOps, A: set, k: int) -> List[set]:
    """
    Compute the product tower [A, A², A³, ..., Aᵏ].

    Time complexity: O(k · |G|²) worst case
    Space complexity: O(k · |G|)

    Args:
        G: group operations
        A: the base set
        k: maximum power

    Returns:
        List of sets [A¹, A², ..., Aᵏ]
    """
    tower = [set(A)]
    current = set(A)
    for i in range(1, k):
        current = product_set(G, current, A)
        tower.append(current)
    return tower


# ──────────────────────────────────────────────────────────────
# Algorithm 2: Subgroup Detection from Exact Tripling
# ──────────────────────────────────────────────────────────────

def detect_subgroup_from_tripling(G: GroupOps, A: set) -> Optional[set]:
    """
    Given a symmetric set A with 1 ∈ A, check if |A³| = |A|.
    If so, return A (which must be a subgroup by Theorem 2).

    This implements the cardinal rigidity detection:
    1. Compute A² and A³
    2. Check |A³| = |A|
    3. If yes, verify subgroup axioms (should always pass)

    Time complexity: O(|A|³) for product computation
    Space complexity: O(|A|²)

    Args:
        G: group operations
        A: candidate set

    Returns:
        A if it's a subgroup (exact tripling), None otherwise
    """
    if G.identity not in A:
        return None
    if not all(G.inv(a) in A for a in A):
        return None

    AA = product_set(G, A, A)
    AAA = product_set(G, AA, A)

    if len(AAA) == len(A):
        # By Theorem 2 (subgroup_of_card_triple_eq_card), A is a subgroup
        return A
    return None


# ──────────────────────────────────────────────────────────────
# Algorithm 3: Growth Gap Estimation
# ──────────────────────────────────────────────────────────────

def estimate_growth_gap(G: GroupOps, sample_size: int = 100) -> float:
    """
    Estimate the growth gap δ for a finite group G.

    The growth gap is:
      δ = min { |A³|/|A| - 1 : A symmetric, 1 ∈ A, A generates G, A ≠ G }

    We sample random symmetric generating sets and compute the minimum
    tripling growth ratio minus 1.

    Time complexity: O(sample_size · |G|³)

    Args:
        G: group operations
        sample_size: number of random sets to test

    Returns:
        Estimated growth gap δ
    """
    import random
    full = set(G.elements)
    min_gap = float('inf')

    for _ in range(sample_size):
        # Generate a random symmetric set containing identity
        size = random.randint(2, G.size - 1)
        subset = random.sample(G.elements, min(size, G.size))
        A = {G.identity}
        for g in subset:
            A.add(g)
            A.add(G.inv(g))

        if A == full:
            continue

        # Check if A generates G
        generated = set(A)
        prev = 0
        while len(generated) > prev:
            prev = len(generated)
            new = set()
            for a in generated:
                for b in A:
                    new.add(G.mul(a, b))
            generated |= new

        if generated != full:
            continue

        # Compute tripling ratio
        AA = product_set(G, A, A)
        AAA = product_set(G, AA, A)
        ratio = len(AAA) / len(A)
        gap = ratio - 1

        if gap > 0:
            min_gap = min(min_gap, gap)

    return min_gap if min_gap < float('inf') else 0.0


# ──────────────────────────────────────────────────────────────
# Algorithm 4: Trace Set Analysis for SL(2, F_p)
# ──────────────────────────────────────────────────────────────

def sl2_trace_analysis(p: int, A: set) -> Dict:
    """
    Analyze the trace set of a subset A ⊆ SL(2, F_p).

    For each matrix (a,b,c,d), trace = a + d mod p.
    The trace set captures arithmetic structure from multiplicative data.

    Args:
        p: prime
        A: subset of SL(2, F_p) as set of (a,b,c,d) tuples

    Returns:
        Dict with trace statistics
    """
    traces = {(a + d) % p for (a, b, c, d) in A}
    return {
        "trace_set": traces,
        "trace_count": len(traces),
        "field_size": p,
        "trace_density": len(traces) / p,
        "missing_traces": set(range(p)) - traces,
    }


# ──────────────────────────────────────────────────────────────
# Algorithm 5: Exhaustive Subgroup Finder
# ──────────────────────────────────────────────────────────────

def find_all_subgroups(G: GroupOps) -> List[set]:
    """
    Find all subgroups of G by checking all subsets.
    Only feasible for |G| ≤ 20 or so.

    Uses the optimization: only check subsets whose size divides |G|
    (by Lagrange's theorem).

    Time complexity: O(2^|G| · |G|²) worst case, pruned by Lagrange
    Space complexity: O(|G|)

    Args:
        G: group operations

    Returns:
        List of all subgroups (as sets)
    """
    subgroups = []
    n = G.size

    for size in range(1, n + 1):
        if n % size != 0:  # Lagrange's theorem
            continue
        for subset in itertools.combinations(G.elements, size):
            S = set(subset)
            if G.identity not in S:
                continue
            if not all(G.inv(a) in S for a in S):
                continue
            if all(G.mul(a, b) in S for a in S for b in S):
                subgroups.append(S)

    return subgroups


# ──────────────────────────────────────────────────────────────
# Convenience: Group Constructors
# ──────────────────────────────────────────────────────────────

def cyclic_group(n: int) -> GroupOps:
    """Construct Z/nZ."""
    return GroupOps(
        list(range(n)),
        lambda a, b: (a + b) % n,
        lambda a: (-a) % n,
        0
    )


def sl2_group(p: int) -> GroupOps:
    """Construct SL(2, F_p)."""
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
            (a1*a2 + b1*c2) % p, (a1*b2 + b1*d2) % p,
            (c1*a2 + d1*c2) % p, (c1*b2 + d1*d2) % p
        )

    def inv(A):
        a, b, c, d = A
        return (d % p, (-b) % p, (-c) % p, a % p)

    return GroupOps(elements, mul, inv, (1, 0, 0, 1))


# ──────────────────────────────────────────────────────────────
# Example Usage
# ──────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("Algorithm Demonstrations")
    print("=" * 50)

    # Product tower in Z/12Z
    G = cyclic_group(12)
    A = {0, 3, 6, 9}  # Subgroup of order 4
    tower = product_tower(G, A, 5)
    print(f"\nProduct tower of {{0,3,6,9}} in Z/12Z:")
    for i, s in enumerate(tower):
        print(f"  A^{i+1} = {sorted(s)}, |A^{i+1}| = {len(s)}")

    # Growth gap estimation
    print(f"\nGrowth gap estimation for Z/6Z:")
    G6 = cyclic_group(6)
    gap = estimate_growth_gap(G6, sample_size=200)
    print(f"  Estimated δ = {gap:.4f}")

    # SL(2, F_3) trace analysis
    print(f"\nSL(2, F_3) trace analysis:")
    G_sl = sl2_group(3)
    print(f"  |SL(2, F_3)| = {G_sl.size}")
    full_trace = sl2_trace_analysis(3, set(G_sl.elements))
    print(f"  Full trace set: {sorted(full_trace['trace_set'])}")
    print(f"  Trace density: {full_trace['trace_density']:.2f}")

    # Subgroup detection
    print(f"\nSubgroup detection via exact tripling:")
    for A_test in [{0, 2, 4}, {0, 3, 6, 9}, {0, 1, 2}]:
        G12 = cyclic_group(12)
        result = detect_subgroup_from_tripling(G12, A_test)
        print(f"  A = {sorted(A_test)}: {'subgroup ✓' if result else 'not exact tripling'}")

    # Full analysis
    print(f"\nFull approximate subgroup reports:")
    G_sl = sl2_group(3)
    id_elem = G_sl.identity
    g = (0, 1, 2, 0)
    A_test = {id_elem, g, G_sl.inv(g)}
    report = ApproxSubgroupReport(A_test, G_sl)
    print(f"  {report}")
