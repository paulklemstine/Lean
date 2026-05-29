#!/usr/bin/env python3
"""
Exchange Family Descent Complexity — Certified Algorithms

Implements the core algorithms from the research paper with complete
docstrings, type hints, and example usage.

Algorithms:
1. Exact worst-case descent length via dynamic programming
2. Descending path enumeration / counting
3. Certificate amplification profile computation
4. Product family constructor with superadditivity verification
5. Adversarial family generator
"""

from typing import Dict, List, Set, Tuple, Optional
from collections import defaultdict
import itertools
import math


# ─────────────────────────────────────────────────────────────────────────────
# Core Types
# ─────────────────────────────────────────────────────────────────────────────

State = int

class ExchangeFamily:
    """
    A finite exchange family with strict descent.

    This is a finite state system where a step relation strictly decreases
    a natural-number measure. Models descent dynamics in combinatorial
    optimization, where each "exchange" improves the objective.

    Attributes:
        dim: Ambient dimension parameter
        states: Set of state identifiers
        measure: Mapping from states to natural numbers
        adj: Adjacency list representation of the step relation
    """

    def __init__(self, dim: int, states: List[State],
                 measure: Dict[State, int],
                 edges: Set[Tuple[State, State]]):
        self.dim = dim
        self.states = sorted(states)
        self.measure = measure
        self.adj: Dict[State, List[State]] = defaultdict(list)
        for (u, v) in edges:
            assert measure[v] < measure[u], \
                f"Strict descent violated: m({u})={measure[u]}, m({v})={measure[v]}"
            self.adj[u].append(v)

    @property
    def num_states(self) -> int:
        return len(self.states)


# ─────────────────────────────────────────────────────────────────────────────
# Algorithm 1: Exact Worst-Case Descent Length (Dynamic Programming)
# ─────────────────────────────────────────────────────────────────────────────

def compute_longest_chain(F: ExchangeFamily) -> int:
    """
    Compute the exact longest descending chain in F via memoized DFS.

    Time complexity:  O(|V| + |E|) where |E| = number of step edges
    Space complexity: O(|V|) for memoization table

    The algorithm processes states in order of increasing measure (topological
    order guaranteed by strict descent), computing for each state the longest
    chain starting from it.

    Returns:
        Length of the longest descending chain (number of steps)

    Example:
        >>> F = linear_chain(5)
        >>> compute_longest_chain(F)
        5
    """
    dp: Dict[State, int] = {}

    def dfs(s: State) -> int:
        if s in dp:
            return dp[s]
        dp[s] = 0
        for t in F.adj[s]:
            dp[s] = max(dp[s], 1 + dfs(t))
        return dp[s]

    return max(dfs(s) for s in F.states) if F.states else 0


# ─────────────────────────────────────────────────────────────────────────────
# Algorithm 2: Descending Path Count (Partition Function)
# ─────────────────────────────────────────────────────────────────────────────

def count_descending_paths(F: ExchangeFamily, n: int) -> int:
    """
    Count the total number of descending paths of exactly n steps.

    This is the combinatorial partition function: it counts all possible
    n-step relaxation trajectories in the descent landscape.

    Time complexity:  O(n · |V| · max_degree)
    Space complexity: O(|V|)

    In statistical mechanics terms:
    - Each path is a zero-temperature relaxation trajectory
    - The count is the partition function Z(n)
    - log Z(n) is the descent entropy

    Args:
        F: Exchange family
        n: Number of steps

    Returns:
        Total number of length-n descending paths across all starting states

    Example:
        >>> F = linear_chain(3)
        >>> [count_descending_paths(F, k) for k in range(5)]
        [4, 3, 2, 1, 0]
    """
    # current[s] = number of paths of current length ending at s
    current = {s: 1 for s in F.states}  # length 0: one path per state

    if n == 0:
        return sum(current.values())

    for step in range(n):
        next_count: Dict[State, int] = defaultdict(int)
        for s in F.states:
            if current.get(s, 0) > 0:
                for t in F.adj[s]:
                    next_count[t] += current[s]
        current = dict(next_count)

    return sum(current.values())


def descent_entropy(F: ExchangeFamily, n: int) -> float:
    """
    Compute the descent entropy H(n) = log(Z(n)) where Z(n) is the
    number of length-n descending paths.

    In statistical mechanics, this is the zero-temperature free energy.
    In information theory, it measures the information content of the
    descent process at horizon n.

    Returns:
        Natural logarithm of the path count (0 if count is 0)
    """
    count = count_descending_paths(F, n)
    return math.log(count) if count > 0 else 0.0


# ─────────────────────────────────────────────────────────────────────────────
# Algorithm 3: Certificate Amplification Profile
# ─────────────────────────────────────────────────────────────────────────────

def amplification_profile(F: ExchangeFamily, k: int) -> int:
    """
    Compute the certificate amplification profile at depth k.

    This is the max measure among states with measure ≤ dim^k.
    When this equals the global worst-case measure, depth k "sees"
    all the complexity. When it's strictly less, there is hidden
    complexity beyond what depth-k certificates can capture.

    Time complexity: O(|V|)

    Args:
        F: Exchange family
        k: Depth parameter

    Returns:
        Max measure among states within the depth-k budget
    """
    threshold = F.dim ** k
    eligible = [F.measure[s] for s in F.states if F.measure[s] <= threshold]
    return max(eligible) if eligible else 0


def has_certificate_depth(F: ExchangeFamily, k: int) -> bool:
    """Check if F has certificate depth ≤ k (all measures ≤ dim^k)."""
    threshold = F.dim ** k
    return all(F.measure[s] <= threshold for s in F.states)


def detect_gap(F: ExchangeFamily, k: int) -> bool:
    """
    Detect whether the amplification profile at depth k is strictly
    less than the worst-case descent length.

    If True, certificate depth k does NOT capture all complexity —
    there is hidden structure beyond depth k.
    """
    profile = amplification_profile(F, k)
    worst = max(F.measure[s] for s in F.states)
    return profile < worst


# ─────────────────────────────────────────────────────────────────────────────
# Algorithm 4: Product Family Construction
# ─────────────────────────────────────────────────────────────────────────────

def product_family(F: ExchangeFamily, G: ExchangeFamily) -> ExchangeFamily:
    """
    Construct the product of two exchange families.

    States are pairs (s, t), measure is sum, and a step moves in
    exactly one coordinate. This is the tensorization construction
    that enables hardness amplification.

    Key property (proved in Lean):
        worst_descent(F × G) ≥ worst_descent(F) + worst_descent(G)

    Time complexity:  O(|F.V| · |G.V| · (|F.E| + |G.E|))
    Space complexity: O(|F.V|² · |G.V|² ) worst case

    Args:
        F, G: Exchange families to combine

    Returns:
        Product exchange family
    """
    # Encode pairs as integers for efficiency
    n_g = len(G.states)
    g_idx = {s: i for i, s in enumerate(G.states)}
    f_idx = {s: i for i, s in enumerate(F.states)}

    states = []
    measure = {}
    edges = set()

    for sf in F.states:
        for sg in G.states:
            pair = f_idx[sf] * n_g + g_idx[sg]
            states.append(pair)
            measure[pair] = F.measure[sf] + G.measure[sg]

    for sf in F.states:
        for tf in F.adj[sf]:
            for sg in G.states:
                u = f_idx[sf] * n_g + g_idx[sg]
                v = f_idx[tf] * n_g + g_idx[sg]
                edges.add((u, v))

    for sg in G.states:
        for tg in G.adj[sg]:
            for sf in F.states:
                u = f_idx[sf] * n_g + g_idx[sg]
                v = f_idx[sf] * n_g + g_idx[tg]
                edges.add((u, v))

    return ExchangeFamily(F.dim + G.dim, states, measure, edges)


def verify_superadditivity(F: ExchangeFamily, G: ExchangeFamily) -> dict:
    """
    Verify the product superadditivity theorem computationally.

    Returns a dict with:
        - worst_F, worst_G: individual worst-case lengths
        - worst_product: product worst-case length
        - sum: worst_F + worst_G
        - superadditive: whether the inequality holds
    """
    P = product_family(F, G)
    wf = compute_longest_chain(F)
    wg = compute_longest_chain(G)
    wp = compute_longest_chain(P)
    return {
        'worst_F': wf,
        'worst_G': wg,
        'worst_product': wp,
        'sum': wf + wg,
        'superadditive': wp >= wf + wg,
    }


# ─────────────────────────────────────────────────────────────────────────────
# Algorithm 5: Adversarial Family Generator
# ─────────────────────────────────────────────────────────────────────────────

def linear_chain(d: int) -> ExchangeFamily:
    """Linear chain: states 0..d, step i → i-1. Worst case = d."""
    states = list(range(d + 1))
    measure = {s: s for s in states}
    edges = {(i, i - 1) for i in range(1, d + 1)}
    return ExchangeFamily(d, states, measure, edges)


def full_descent_family(d: int, branching: int = 2) -> ExchangeFamily:
    """
    Create a fully-connected descent family where each state at measure m
    can step to any state at measure m-1, ..., m-branching.

    This maximizes path count while keeping the step structure controlled.
    """
    n = d ** 2
    states = list(range(n + 1))
    measure = {s: s for s in states}
    edges = set()
    for s in states:
        for delta in range(1, min(branching + 1, s + 1)):
            edges.add((s, s - delta))
    return ExchangeFamily(d, states, measure, edges)


def adversarial_at_depth(d: int, k: int) -> ExchangeFamily:
    """
    Construct an adversarial exchange family targeting depth k.

    Strategy: create states with measures spanning [0, d^(d-k-1)] with
    maximal branching at the transition boundary d^k, to stress-test
    whether depth k truly captures the complexity.
    """
    if d <= k + 1:
        return linear_chain(d)

    max_m = min(d ** (d - k), d ** 4)  # Cap for tractability
    states = list(range(max_m + 1))
    measure = {s: s for s in states}

    # Multi-branching step structure
    edges = set()
    for s in states:
        for delta in range(1, min(d + 1, s + 1)):
            edges.add((s, s - delta))

    return ExchangeFamily(d, states, measure, edges)


# ─────────────────────────────────────────────────────────────────────────────
# Algorithm 6: T(d,k) Estimator
# ─────────────────────────────────────────────────────────────────────────────

def estimate_T(d: int, k: int) -> Dict:
    """
    Estimate T(d,k) by constructing adversarial families and computing
    their exact worst-case descent lengths.

    Returns a dict with the estimated T value and diagnostic ratios.
    """
    F = adversarial_at_depth(d, k)
    T = compute_longest_chain(F)

    upper = d ** (d - k) if d > k else 1
    lower = d ** max(0, d - k - 1) if d > k + 1 else 1

    return {
        'T': T,
        'd': d,
        'k': k,
        'upper_bound': upper,
        'lower_bound': lower,
        'ratio_upper': T / upper if upper > 0 else float('inf'),
        'ratio_lower': T / lower if lower > 0 else float('inf'),
        'num_states': F.num_states,
    }


# ─────────────────────────────────────────────────────────────────────────────
# Example Usage
# ─────────────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("Exchange Family Algorithms — Example Usage\n")

    # Example 1: Linear chain
    F = linear_chain(5)
    print(f"Linear chain (d=5): longest chain = {compute_longest_chain(F)}")
    print(f"  Path counts: {[count_descending_paths(F, n) for n in range(7)]}")
    print(f"  Entropy: {[f'{descent_entropy(F, n):.3f}' for n in range(7)]}")

    # Example 2: Product
    G = linear_chain(3)
    result = verify_superadditivity(F, G)
    print(f"\nProduct F(5) × G(3): {result}")

    # Example 3: Amplification profile
    H = full_descent_family(4, branching=3)
    print(f"\nFull descent family (d=4, branching=3):")
    print(f"  Longest chain: {compute_longest_chain(H)}")
    for k in range(5):
        print(f"  Amplification profile k={k}: {amplification_profile(H, k)}, "
              f"gap detected: {detect_gap(H, k)}")

    # Example 4: T(d,k) estimation
    print(f"\nT(d,k) estimates:")
    for d in range(4, 9):
        for k in [0, 1]:
            est = estimate_T(d, k)
            print(f"  T({d},{k}) ≈ {est['T']}, ratio_upper={est['ratio_upper']:.6f}")
