#!/usr/bin/env python3
"""
Holographic Proof Renormalization — Core Algorithms

Implements the algorithmic content of the renormalization framework:
1. Proof renormalization with convergence tracking
2. Semantic codebook search for approximate theoremhood
3. Ultrametric-based proof clustering
4. p-adic complexity analysis
"""

from dataclasses import dataclass, field
from typing import List, Tuple, Set, FrozenSet, Optional, Dict, Iterator
import math


# ═══════════════════════════════════════════════════════════════
# Core Data Structures
# ═══════════════════════════════════════════════════════════════

@dataclass(frozen=True)
class ProofSketch:
    """
    A proof sketch: a finite sequence of rule-costs and a goal identifier.

    This is the fundamental object of non-Archimedean proof theory.
    Each step represents a rule application with associated cost.
    """
    steps: Tuple[int, ...]
    goal_id: int = 0

    def complexity(self) -> int:
        """Total complexity: sum of all step costs."""
        return sum(self.steps)

    def semantic_signature(self) -> FrozenSet[int]:
        """The set of distinct rule-costs used."""
        return frozenset(self.steps)

    def length(self) -> int:
        """Number of steps."""
        return len(self.steps)


@dataclass
class RenormOrbit:
    """Records the orbit of a proof sketch under renormalization."""
    initial: ProofSketch
    iterates: List[ProofSketch] = field(default_factory=list)
    fixed_point_index: Optional[int] = None
    complexities: List[int] = field(default_factory=list)


# ═══════════════════════════════════════════════════════════════
# Algorithm 1: Proof Renormalization with Convergence Tracking
# ═══════════════════════════════════════════════════════════════

def renorm_step(P: ProofSketch) -> ProofSketch:
    """
    Renormalization step: deduplicate proof steps.

    Time complexity: O(n) where n = len(P.steps)
    Space complexity: O(n)

    This is a concrete instance of an RG operator that:
    - Never increases complexity (monotonicity)
    - Strictly decreases complexity off fixed points (strict descent)
    - Preserves semantic signature exactly (semantic stability)
    - Is idempotent (reaches fixed point in one step)
    """
    seen: set = set()
    deduped: list = []
    for s in P.steps:
        if s not in seen:
            seen.add(s)
            deduped.append(s)
    return ProofSketch(steps=tuple(deduped), goal_id=P.goal_id)


def compute_orbit(F, P: ProofSketch, max_steps: Optional[int] = None) -> RenormOrbit:
    """
    Compute the full renormalization orbit of P under F.

    By the convergence theorem, this terminates in at most
    complexity(P) steps for any strict-descent operator F.

    Time complexity: O(C(P) * T_F) where T_F is cost of one F application
    Space complexity: O(C(P) * S_P) where S_P is size of one proof sketch

    Args:
        F: Renormalization operator
        P: Initial proof sketch
        max_steps: Override for maximum iterations (default: complexity(P))

    Returns:
        RenormOrbit with full trajectory and fixed point index
    """
    bound = max_steps if max_steps is not None else P.complexity()
    orbit = RenormOrbit(initial=P)
    current = P

    for i in range(bound + 1):
        orbit.iterates.append(current)
        orbit.complexities.append(current.complexity())
        next_p = F(current)
        if next_p == current:
            orbit.fixed_point_index = i
            break
        current = next_p

    return orbit


# ═══════════════════════════════════════════════════════════════
# Algorithm 2: Semantic Codebook Search
# ═══════════════════════════════════════════════════════════════

def generate_bounded_codebook(
    max_step_value: int,
    max_length: int,
    goal_id: int = 0
) -> Iterator[ProofSketch]:
    """
    Generate all proof sketches in the bounded codebook.

    Yields all proof sketches with:
    - Steps drawn from {0, 1, ..., max_step_value - 1}
    - Length at most max_length
    - Fixed goal_id

    Total codebook size: sum_{k=0}^{max_length} max_step_value^k

    Time complexity: O(codebook_size)
    Space complexity: O(max_length) per sketch (generator)
    """
    from itertools import product as iterproduct

    for length in range(max_length + 1):
        if length == 0:
            yield ProofSketch(steps=(), goal_id=goal_id)
        else:
            for steps in iterproduct(range(max_step_value), repeat=length):
                yield ProofSketch(steps=steps, goal_id=goal_id)


def search_approximate_proofs(
    target: FrozenSet[int],
    epsilon: int,
    max_step_value: int,
    max_length: int,
    goal_id: int = 0,
    max_results: int = 100
) -> List[Tuple[ProofSketch, int]]:
    """
    Search for ε-approximate proofs in the bounded codebook.

    An approximate proof P satisfies:
        |sig(P) \\ target| + |target \\ sig(P)| ≤ ε

    This is the decidable bounded approximate theoremhood algorithm.

    Time complexity: O(codebook_size * |target|)
    Space complexity: O(max_results * max_length)

    Returns:
        List of (proof, symmetric_difference) pairs, sorted by complexity
    """
    results = []
    for P in generate_bounded_codebook(max_step_value, max_length, goal_id):
        sig = P.semantic_signature()
        sym_diff = len(sig - target) + len(target - sig)
        if sym_diff <= epsilon:
            results.append((P, sym_diff))
            if len(results) >= max_results * 10:  # Collect extras for sorting
                break

    results.sort(key=lambda x: (x[1], x[0].complexity()))
    return results[:max_results]


# ═══════════════════════════════════════════════════════════════
# Algorithm 3: Ultrametric Proof Clustering
# ═══════════════════════════════════════════════════════════════

def proof_distance(P: ProofSketch, Q: ProofSketch) -> int:
    """Ultrametric-style distance based on complexity difference."""
    return abs(P.complexity() - Q.complexity())


def semantic_distance(P: ProofSketch, Q: ProofSketch) -> int:
    """Symmetric difference of semantic signatures."""
    sig_p = P.semantic_signature()
    sig_q = Q.semantic_signature()
    return len(sig_p - sig_q) + len(sig_q - sig_p)


def cluster_by_signature(proofs: List[ProofSketch]) -> Dict[FrozenSet[int], List[ProofSketch]]:
    """
    Cluster proofs by semantic signature (exact semantic equivalence).

    Two proofs in the same cluster are semantically equivalent under
    the eraseDups renormalization — they normalize to proofs with
    the same set of rule-costs.

    Time complexity: O(n * max_length) where n = len(proofs)
    Space complexity: O(n * max_length)
    """
    clusters: Dict[FrozenSet[int], List[ProofSketch]] = {}
    for P in proofs:
        sig = P.semantic_signature()
        if sig not in clusters:
            clusters[sig] = []
        clusters[sig].append(P)
    return clusters


def find_canonical_representatives(
    proofs: List[ProofSketch]
) -> List[ProofSketch]:
    """
    Find canonical (minimal complexity) representatives for each
    semantic equivalence class.

    This implements the variational principle: the fixed point
    of renormalization is the minimal-complexity representative.

    Time complexity: O(n * max_length)
    Space complexity: O(n)
    """
    clusters = cluster_by_signature(proofs)
    representatives = []
    for sig, cluster in clusters.items():
        # The canonical representative has minimal complexity
        canonical = min(cluster, key=lambda P: P.complexity())
        representatives.append(canonical)
    return sorted(representatives, key=lambda P: P.complexity())


# ═══════════════════════════════════════════════════════════════
# Algorithm 4: p-adic Complexity Analysis
# ═══════════════════════════════════════════════════════════════

def padic_valuation(n: int, p: int) -> int:
    """
    Compute the p-adic valuation of n.
    Returns the largest k such that p^k divides n.
    For n = 0, returns infinity (represented as -1).
    """
    if n == 0:
        return -1  # Convention for infinity
    if p < 2:
        raise ValueError(f"p must be prime, got {p}")
    val = 0
    while n % p == 0:
        val += 1
        n //= p
    return val


def padic_complexity(p: int, P: ProofSketch) -> int:
    """
    p-adic complexity: v_p(complexity(P) + 1).

    Measures how "p-adically smooth" the proof complexity is.
    Higher p-adic complexity means the proof complexity + 1 is
    highly divisible by p.
    """
    return padic_valuation(P.complexity() + 1, p)


def padic_distance(p: int, P: ProofSketch, Q: ProofSketch) -> float:
    """
    p-adic distance between proofs: p^{-v_p(|c(P) - c(Q)|)}.

    Returns 0 if complexities are equal.
    """
    diff = abs(P.complexity() - Q.complexity())
    if diff == 0:
        return 0.0
    val = padic_valuation(diff, p)
    return p ** (-val)


# ═══════════════════════════════════════════════════════════════
# Algorithm 5: Rate-Distortion Analysis
# ═══════════════════════════════════════════════════════════════

def rate_distortion_curve(
    proofs: List[ProofSketch],
    target: FrozenSet[int],
    max_rate: int
) -> List[Tuple[int, int]]:
    """
    Compute the rate-distortion curve for proof compression.

    Rate = complexity (code length analog)
    Distortion = semantic distance to target

    Returns pairs (rate, min_distortion) showing the tradeoff
    between proof complexity and semantic accuracy.

    Time complexity: O(n * log(n))
    """
    # Compute (complexity, distortion) for each proof
    points = []
    for P in proofs:
        sig = P.semantic_signature()
        dist = len(sig - target) + len(target - sig)
        points.append((P.complexity(), dist))

    # For each rate budget, find minimum achievable distortion
    curve = []
    for rate in range(max_rate + 1):
        feasible = [d for c, d in points if c <= rate]
        min_dist = min(feasible) if feasible else len(target)
        curve.append((rate, min_dist))

    return curve


# ═══════════════════════════════════════════════════════════════
# Example Usage
# ═══════════════════════════════════════════════════════════════

if __name__ == "__main__":
    print("Holographic Proof Renormalization — Algorithm Suite")
    print("=" * 60)

    # Example 1: Orbit computation
    P = ProofSketch(steps=(3, 1, 4, 1, 5, 9, 2, 6, 5, 3, 5), goal_id=0)
    orbit = compute_orbit(renorm_step, P)
    print(f"\nOrbit of {P}:")
    for i, (iterate, c) in enumerate(zip(orbit.iterates, orbit.complexities)):
        print(f"  F^[{i}]: complexity={c}, steps={list(iterate.steps)}")
    print(f"  Fixed point at index: {orbit.fixed_point_index}")

    # Example 2: Codebook search
    target = frozenset({1, 2, 3})
    results = search_approximate_proofs(target, epsilon=1, max_step_value=5, max_length=4)
    print(f"\nApproximate proofs for target {sorted(target)}, ε=1:")
    for P, sd in results[:5]:
        print(f"  {P} (sym_diff={sd}, complexity={P.complexity()})")

    # Example 3: Clustering
    proofs = [
        ProofSketch((1, 2, 3), 0),
        ProofSketch((3, 2, 1), 0),
        ProofSketch((1, 2, 3, 1), 0),
        ProofSketch((4, 5), 0),
        ProofSketch((5, 4, 5), 0),
    ]
    clusters = cluster_by_signature(proofs)
    print(f"\nSemantic clusters:")
    for sig, cluster in clusters.items():
        print(f"  Signature {sorted(sig)}: {[list(p.steps) for p in cluster]}")

    reps = find_canonical_representatives(proofs)
    print(f"  Canonical representatives: {[list(r.steps) for r in reps]}")

    # Example 4: p-adic analysis
    print(f"\np-adic complexity (p=2):")
    for P in proofs:
        pc = padic_complexity(2, P)
        print(f"  {list(P.steps)}: complexity={P.complexity()}, v_2({P.complexity()+1})={pc}")

    # Example 5: Rate-distortion
    all_proofs = list(generate_bounded_codebook(4, 3, 0))
    curve = rate_distortion_curve(all_proofs[:500], frozenset({1, 2, 3}), 10)
    print(f"\nRate-distortion curve for target {{1,2,3}}:")
    for rate, dist in curve:
        bar = "█" * (10 - dist) + "░" * dist
        print(f"  Rate {rate:2d}: min_distortion={dist}  {bar}")
