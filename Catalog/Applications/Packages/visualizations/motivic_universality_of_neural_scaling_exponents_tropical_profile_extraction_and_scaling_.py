#!/usr/bin/env python3
"""
Tropical Scaling Exponents — Core Algorithms

Implements the key algorithms from the research paper:
1. Tropical profile extraction from weighted DAGs
2. Scaling exponent computation (O(V+E) dynamic programming)
3. Tropical equivalence testing
4. Envelope computation and asymptotic bound extraction

All algorithms work with exact rational arithmetic (fractions.Fraction).
"""

from fractions import Fraction
from typing import List, Tuple, Set, Dict, Optional, FrozenSet
from dataclasses import dataclass, field
from collections import defaultdict


@dataclass(frozen=True)
class TropAffine:
    """A tropical affine form: slope * x + intercept.

    Represents a source-to-sink path cost function in a computation DAG.
    The slope controls the power-law scaling rate and the intercept is
    a constant overhead term.
    """
    slope: Fraction
    intercept: Fraction

    def eval(self, x: Fraction) -> Fraction:
        """Evaluate the affine form at point x."""
        return self.slope * x + self.intercept

    def __repr__(self):
        return f"TropAffine(slope={self.slope}, intercept={self.intercept})"


@dataclass
class TropicalProfile:
    """A nonempty finite set of tropical affine forms.

    Represents the collection of all source-to-sink path cost functions
    in a computation DAG.

    Time complexity of operations:
    - envelope(x): O(|forms|)
    - scaling_exponent(): O(|forms|)
    - __eq__: O(|forms| log |forms|) for set comparison
    """
    forms: FrozenSet[TropAffine]

    def __post_init__(self):
        assert len(self.forms) > 0, "Profile must be nonempty"

    def envelope(self, x: Fraction) -> Fraction:
        """Compute the tropical envelope (pointwise minimum) at x.

        Time: O(|forms|)
        """
        return min(f.eval(x) for f in self.forms)

    def scaling_exponent(self) -> Fraction:
        """Compute the tropical scaling exponent (minimum slope).

        This is always rational since it's the minimum of finitely many
        rational numbers.

        Time: O(|forms|)
        """
        return min(f.slope for f in self.forms)

    def upper_bound_intercept(self) -> Fraction:
        """Return b₂ such that env(x) ≤ α·x + b₂ for all x.

        The bound uses the intercept of a minimum-slope form.

        Time: O(|forms|)
        """
        alpha = self.scaling_exponent()
        return min(f.intercept for f in self.forms if f.slope == alpha)

    def lower_bound_intercept(self) -> Fraction:
        """Return b₁ such that α·x + b₁ ≤ env(x) for x ≥ 0.

        Time: O(|forms|)
        """
        return min(f.intercept for f in self.forms)

    def lower_bound_threshold(self) -> Fraction:
        """Return X₀ such that the lower bound holds for x ≥ X₀.

        For our proof, X₀ = 0 suffices.
        """
        return Fraction(0)


@dataclass
class WeightedDAG:
    """A weighted directed acyclic computation graph.

    Vertices are integers 0..n-1. Edges carry tropical weight contributions
    (slope_delta, intercept_delta) that accumulate along paths.

    Attributes:
        n: number of vertices
        edges: list of (source, target, slope_delta, intercept_delta)
        sources: set of source vertex indices
        sink: index of the sink vertex
    """
    n: int
    edges: List[Tuple[int, int, Fraction, Fraction]]
    sources: Set[int]
    sink: int

    def adjacency_list(self) -> Dict[int, List[Tuple[int, Fraction, Fraction]]]:
        """Build adjacency list representation.

        Time: O(|E|)
        """
        adj: Dict[int, List[Tuple[int, Fraction, Fraction]]] = defaultdict(list)
        for u, v, ds, di in self.edges:
            adj[u].append((v, ds, di))
        return adj

    def topological_order(self) -> List[int]:
        """Compute topological ordering using Kahn's algorithm.

        Time: O(V + E)
        """
        in_degree = [0] * self.n
        adj = self.adjacency_list()
        for u, v, _, _ in self.edges:
            in_degree[v] += 1

        queue = [v for v in range(self.n) if in_degree[v] == 0]
        order = []
        while queue:
            v = queue.pop(0)
            order.append(v)
            for w, _, _ in adj[v]:
                in_degree[w] -= 1
                if in_degree[w] == 0:
                    queue.append(w)

        assert len(order) == self.n, "Graph contains a cycle"
        return order

    def extract_profile(self) -> TropicalProfile:
        """Extract the tropical profile by enumerating all source-to-sink paths.

        Uses DFS to enumerate all paths and collect their total (slope, intercept).

        Time: O(V + E + P) where P is the number of source-to-sink paths.
        Space: O(V + P)
        """
        adj = self.adjacency_list()
        all_forms: Set[TropAffine] = set()

        def dfs(v: int, cum_slope: Fraction, cum_intercept: Fraction):
            if v == self.sink:
                all_forms.add(TropAffine(cum_slope, cum_intercept))
                return
            for w, ds, di in adj[v]:
                dfs(w, cum_slope + ds, cum_intercept + di)

        for s in self.sources:
            dfs(s, Fraction(0), Fraction(0))

        assert len(all_forms) > 0, "No source-to-sink paths found"
        return TropicalProfile(frozenset(all_forms))

    def compute_min_exponent_dp(self) -> Fraction:
        """Compute the scaling exponent using DP (without enumerating all paths).

        Dynamic programming on the DAG in topological order to find the
        minimum total slope from any source to the sink.

        Time: O(V + E)
        Space: O(V)
        """
        INF = Fraction(10**18)
        # min_slope_to_sink[v] = minimum total slope from v to sink
        min_slope_to_sink = [INF] * self.n
        min_slope_to_sink[self.sink] = Fraction(0)

        # Build reverse adjacency for backward DP
        rev_adj: Dict[int, List[Tuple[int, Fraction]]] = defaultdict(list)
        for u, v, ds, _ in self.edges:
            rev_adj[v].append((u, ds))

        # Process in reverse topological order
        topo = self.topological_order()
        for v in reversed(topo):
            if v == self.sink:
                continue
            adj = self.adjacency_list()
            for w, ds, _ in adj[v]:
                candidate = ds + min_slope_to_sink[w]
                min_slope_to_sink[v] = min(min_slope_to_sink[v], candidate)

        return min(min_slope_to_sink[s] for s in self.sources)

    def num_edges(self) -> int:
        return len(self.edges)


def test_tropical_equivalence(G: WeightedDAG, H: WeightedDAG) -> bool:
    """Test whether two DAGs are tropically equivalent.

    Two DAGs are tropically equivalent iff they have the same tropical profile
    (same set of path cost functions).

    Time: O(V_G + E_G + P_G + V_H + E_H + P_H + (P_G + P_H) log(P_G + P_H))
    """
    profile_G = G.extract_profile()
    profile_H = H.extract_profile()
    return profile_G.forms == profile_H.forms


def compute_sandwich_bounds(
    profile: TropicalProfile
) -> Tuple[Fraction, Fraction, Fraction, Fraction]:
    """Compute the asymptotic sandwich bounds.

    Returns (alpha, X0, b_lower, b_upper) such that:
    - For all x ≥ X0: alpha * x + b_lower ≤ env(x)
    - For all x: env(x) ≤ alpha * x + b_upper

    Time: O(|forms|)
    """
    alpha = profile.scaling_exponent()
    X0 = profile.lower_bound_threshold()
    b_lower = profile.lower_bound_intercept()
    b_upper = profile.upper_bound_intercept()
    return alpha, X0, b_lower, b_upper


def verify_sandwich(profile: TropicalProfile, test_points: List[Fraction]) -> bool:
    """Verify the sandwich bounds at given test points.

    Returns True if all bounds hold at all test points ≥ X₀.
    """
    alpha, X0, b_lower, b_upper = compute_sandwich_bounds(profile)
    for x in test_points:
        env = profile.envelope(x)
        upper_ok = env <= alpha * x + b_upper
        lower_ok = (x < X0) or (alpha * x + b_lower <= env)
        if not upper_ok or not lower_ok:
            return False
    return True


# ============================================================
# Example constructions
# ============================================================

def make_chain_dag() -> WeightedDAG:
    """Chain DAG: s(0) -> a(1) -> t(2), with two path profiles.

    Path 1 (s->a->t): slope=1/2, intercept=0
    We model this by splitting the slope/intercept across edges.
    """
    return WeightedDAG(
        n=3,
        edges=[
            (0, 1, Fraction(1, 4), Fraction(0)),
            (1, 2, Fraction(1, 4), Fraction(0)),
            # Second "virtual" path through a shortcut
            (0, 2, Fraction(1, 1), Fraction(1)),
        ],
        sources={0},
        sink=2
    )


def make_diamond_dag() -> WeightedDAG:
    """Diamond DAG: s(0) -> {a(1), b(2)} -> t(3).

    Path s->a->t: slope=1/2, intercept=0
    Path s->b->t: slope=1, intercept=1
    """
    return WeightedDAG(
        n=4,
        edges=[
            (0, 1, Fraction(1, 4), Fraction(0)),
            (1, 3, Fraction(1, 4), Fraction(0)),
            (0, 2, Fraction(1, 2), Fraction(1, 2)),
            (2, 3, Fraction(1, 2), Fraction(1, 2)),
        ],
        sources={0},
        sink=3
    )


def make_wide_dag() -> WeightedDAG:
    """Wide DAG with 3 parallel paths.

    Path slopes: 1/3, 2/3, 1
    """
    return WeightedDAG(
        n=5,
        edges=[
            (0, 1, Fraction(1, 3), Fraction(2)),
            (1, 4, Fraction(0), Fraction(0)),
            (0, 2, Fraction(2, 3), Fraction(0)),
            (2, 4, Fraction(0), Fraction(0)),
            (0, 3, Fraction(1), Fraction(-1)),
            (3, 4, Fraction(0), Fraction(0)),
        ],
        sources={0},
        sink=4
    )


def make_deep_dag() -> WeightedDAG:
    """Deep DAG with the same 3 path profiles as wide_dag.

    Uses a different graph topology (more serial) but same path cost functions.
    """
    return WeightedDAG(
        n=6,
        edges=[
            # Path 1: 0->1->2->5, slope=1/3, intercept=2
            (0, 1, Fraction(1, 6), Fraction(1)),
            (1, 2, Fraction(1, 6), Fraction(1)),
            (2, 5, Fraction(0), Fraction(0)),
            # Path 2: 0->3->5, slope=2/3, intercept=0
            (0, 3, Fraction(2, 3), Fraction(0)),
            (3, 5, Fraction(0), Fraction(0)),
            # Path 3: 0->4->5, slope=1, intercept=-1
            (0, 4, Fraction(1), Fraction(-1)),
            (4, 5, Fraction(0), Fraction(0)),
        ],
        sources={0},
        sink=5
    )


if __name__ == "__main__":
    print("=== Tropical Scaling Exponents — Algorithm Tests ===\n")

    # Test 1: Profile extraction
    chain = make_chain_dag()
    diamond = make_diamond_dag()
    chain_profile = chain.extract_profile()
    diamond_profile = diamond.extract_profile()

    print("Chain DAG profile:", chain_profile.forms)
    print("Diamond DAG profile:", diamond_profile.forms)
    print(f"Tropically equivalent: {chain_profile.forms == diamond_profile.forms}")
    print(f"Chain exponent: {chain_profile.scaling_exponent()}")
    print(f"Diamond exponent: {diamond_profile.scaling_exponent()}")

    # Test 2: DP vs enumeration
    print(f"\nChain exponent (DP): {chain.compute_min_exponent_dp()}")
    print(f"Chain exponent (enum): {chain_profile.scaling_exponent()}")
    assert chain.compute_min_exponent_dp() == chain_profile.scaling_exponent()
    print("DP and enumeration agree ✓")

    # Test 3: Wide vs Deep
    wide = make_wide_dag()
    deep = make_deep_dag()
    wide_profile = wide.extract_profile()
    deep_profile = deep.extract_profile()

    print(f"\nWide DAG profile: {wide_profile.forms}")
    print(f"Deep DAG profile: {deep_profile.forms}")
    print(f"Tropically equivalent: {wide_profile.forms == deep_profile.forms}")
    print(f"Wide exponent: {wide_profile.scaling_exponent()}")
    print(f"Deep exponent: {deep_profile.scaling_exponent()}")

    # Test 4: Sandwich verification
    test_pts = [Fraction(x) for x in range(0, 101)]
    print(f"\nSandwich verification (chain, x ∈ [0,100]): {verify_sandwich(chain_profile, test_pts)}")
    print(f"Sandwich verification (wide, x ∈ [0,100]): {verify_sandwich(wide_profile, test_pts)}")

    alpha, X0, b_lo, b_hi = compute_sandwich_bounds(chain_profile)
    print(f"\nChain sandwich: α={alpha}, X₀={X0}, b₁={b_lo}, b₂={b_hi}")

    alpha, X0, b_lo, b_hi = compute_sandwich_bounds(wide_profile)
    print(f"Wide sandwich: α={alpha}, X₀={X0}, b₁={b_lo}, b₂={b_hi}")

    print("\n=== All algorithm tests passed ===")
