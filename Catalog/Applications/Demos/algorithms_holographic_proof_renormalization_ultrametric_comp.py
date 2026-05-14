#!/usr/bin/env python3
"""
Algorithms for Holographic Proof Renormalization

Implements the core algorithms from the research paper with
full docstrings, type hints, and complexity analysis.
"""

from dataclasses import dataclass
from typing import List, Set, FrozenSet, Optional, Tuple, Callable, Iterator
import itertools
from math import gcd


# ============================================================
# Core Data Structures
# ============================================================

@dataclass(frozen=True)
class ProofSketch:
    """
    A proof sketch: a finite sequence of rule-cost steps targeting a goal.

    Attributes:
        steps: Tuple of non-negative integers representing step costs
        goal_id: Identifier for the proof target

    This is the fundamental combinatorial object in the theory.
    Proof sketches live in a discrete space equipped with:
    - A complexity functional (sum of steps)
    - A semantic signature (set of distinct step types)
    - An ultrametric distance
    """
    steps: tuple
    goal_id: int

    @property
    def complexity(self) -> int:
        """Sum of all step costs. O(n) where n = len(steps)."""
        return sum(self.steps)

    @property
    def semantic_signature(self) -> frozenset:
        """Set of distinct step types used. O(n)."""
        return frozenset(self.steps)

    @property
    def length(self) -> int:
        """Number of steps."""
        return len(self.steps)


# ============================================================
# Algorithm 1: Ultrametric Proof Distance
# ============================================================

def ultrametric_distance(P: ProofSketch, Q: ProofSketch) -> int:
    """
    Compute the ultrametric proof distance.

    d(P, Q) = 0 if P = Q, else 1 + max(complexity(P), complexity(Q))

    This satisfies the strong (ultrametric) triangle inequality:
        d(P, R) ≤ max(d(P, Q), d(Q, R))

    Time complexity: O(n + m) where n, m are lengths of P, Q
    Space complexity: O(1)

    Args:
        P: First proof sketch
        Q: Second proof sketch

    Returns:
        Non-negative integer distance

    >>> P = ProofSketch((1,2,3), 0)
    >>> Q = ProofSketch((4,5), 0)
    >>> ultrametric_distance(P, P)
    0
    >>> ultrametric_distance(P, Q)
    10
    """
    if P == Q:
        return 0
    return 1 + max(P.complexity, Q.complexity)


def semantic_distance(P: ProofSketch, Q: ProofSketch) -> int:
    """
    Compute the semantic distance (symmetric difference of signatures).

    Time complexity: O(n + m)
    Space complexity: O(n + m)

    >>> P = ProofSketch((1,2,3), 0)
    >>> Q = ProofSketch((2,3,4), 0)
    >>> semantic_distance(P, Q)
    2
    """
    sig_p = P.semantic_signature
    sig_q = Q.semantic_signature
    return len(sig_p - sig_q) + len(sig_q - sig_p)


# ============================================================
# Algorithm 2: Renormalization Step (Deduplication)
# ============================================================

def renorm_step(P: ProofSketch) -> ProofSketch:
    """
    Apply one step of proof renormalization via deduplication.

    Removes duplicate steps while preserving order of first occurrences.
    This is a concrete instance of a complexity-reducing, semantics-preserving
    renormalization operator.

    Properties (proved formally):
    - Complexity non-increasing: complexity(renorm(P)) ≤ complexity(P)
    - Semantics preserving: signature(renorm(P)) = signature(P)
    - Idempotent: renorm(renorm(P)) = renorm(P)

    Time complexity: O(n)
    Space complexity: O(n)

    Args:
        P: Input proof sketch

    Returns:
        Deduplicated proof sketch

    >>> P = ProofSketch((3,1,4,1,5,9,2,6,5,3,5), 0)
    >>> renorm_step(P)
    ProofSketch(steps=(3, 1, 4, 5, 9, 2, 6), goal_id=0)
    """
    seen: set = set()
    deduped: list = []
    for s in P.steps:
        if s not in seen:
            seen.add(s)
            deduped.append(s)
    return ProofSketch(steps=tuple(deduped), goal_id=P.goal_id)


# ============================================================
# Algorithm 3: Iterated Renormalization to Fixed Point
# ============================================================

def renormalize_to_fixed_point(
    P: ProofSketch,
    renorm: Callable[[ProofSketch], ProofSketch] = renorm_step,
    max_iter: Optional[int] = None
) -> Tuple[ProofSketch, int, List[ProofSketch]]:
    """
    Iterate a renormalization operator until a fixed point is reached.

    By the Convergence Theorem (renorm_eventually_fixed_of_strict_descent),
    if renorm strictly decreases complexity at non-fixed points, this
    terminates in at most complexity(P) steps.

    Time complexity: O(C * T) where C = complexity(P), T = cost per step
    Space complexity: O(C * n) for storing the orbit

    Args:
        P: Starting proof sketch
        renorm: Renormalization operator (default: deduplication)
        max_iter: Safety bound on iterations (default: complexity + 1)

    Returns:
        (fixed_point, num_iterations, orbit)

    >>> P = ProofSketch((3,1,4,1,5,9,2,6,5,3,5), 0)
    >>> fp, n, orbit = renormalize_to_fixed_point(P)
    >>> fp.steps
    (3, 1, 4, 5, 9, 2, 6)
    >>> n
    1
    """
    if max_iter is None:
        max_iter = P.complexity + 1

    orbit = [P]
    current = P
    for i in range(max_iter):
        next_p = renorm(current)
        if next_p == current:
            return current, i, orbit
        current = next_p
        orbit.append(current)

    raise RuntimeError(f"Did not converge in {max_iter} iterations")


# ============================================================
# Algorithm 4: Bounded Codebook Generation
# ============================================================

def generate_bounded_codebook(
    max_length: int,
    max_value: int,
    goal_id: int = 0
) -> List[ProofSketch]:
    """
    Generate all proof sketches with bounded length and step values.

    The codebook has size (max_value + 1)^0 + ... + (max_value + 1)^max_length
    = ((max_value + 1)^(max_length + 1) - 1) / max_value.

    Time complexity: O(V^L) where V = max_value + 1, L = max_length
    Space complexity: O(V^L * L)

    Args:
        max_length: Maximum number of steps
        max_value: Maximum value per step
        goal_id: Goal identifier for all generated sketches

    Returns:
        List of all bounded proof sketches

    >>> len(generate_bounded_codebook(2, 1, 0))
    7
    """
    codebook = []
    for length in range(max_length + 1):
        for steps in itertools.product(range(max_value + 1), repeat=length):
            codebook.append(ProofSketch(steps=steps, goal_id=goal_id))
    return codebook


# ============================================================
# Algorithm 5: Decidable Approximate Theoremhood Search
# ============================================================

def search_approx_theorem(
    epsilon: int,
    target: FrozenSet[int],
    codebook: List[ProofSketch]
) -> Optional[ProofSketch]:
    """
    Search for an ε-approximate proof in a finite codebook.

    A proof P is ε-approximate if:
        |signature(P) \\ target| + |target \\ signature(P)| ≤ ε

    By the Decidability Theorem (decidable_bounded_approx_theoremhood),
    this search always terminates with a definite answer.

    Time complexity: O(|codebook| * (max_sig_size + |target|))
    Space complexity: O(max_sig_size + |target|)

    Args:
        epsilon: Approximation tolerance
        target: Target semantic signature
        codebook: Finite set of candidate proofs

    Returns:
        A matching proof sketch, or None if no ε-approximate proof exists

    >>> target = frozenset({1, 3, 5})
    >>> codebook = generate_bounded_codebook(3, 5)
    >>> result = search_approx_theorem(0, target, codebook)
    >>> result is not None
    True
    """
    for P in codebook:
        sig = P.semantic_signature
        dist = len(sig - target) + len(target - sig)
        if dist <= epsilon:
            return P
    return None


def search_all_approx_theorems(
    epsilon: int,
    target: FrozenSet[int],
    codebook: List[ProofSketch]
) -> List[ProofSketch]:
    """
    Find ALL ε-approximate proofs in a finite codebook.

    Returns them sorted by complexity (ascending).

    >>> target = frozenset({1, 2})
    >>> cb = generate_bounded_codebook(2, 3)
    >>> results = search_all_approx_theorems(0, target, cb)
    >>> all(r.semantic_signature == target for r in results)
    True
    """
    matches = []
    for P in codebook:
        sig = P.semantic_signature
        dist = len(sig - target) + len(target - sig)
        if dist <= epsilon:
            matches.append(P)
    matches.sort(key=lambda P: P.complexity)
    return matches


# ============================================================
# Algorithm 6: Renormalized Codebook (Canonical Representatives)
# ============================================================

def canonical_codebook(
    codebook: List[ProofSketch],
    renorm: Callable[[ProofSketch], ProofSketch] = renorm_step
) -> List[ProofSketch]:
    """
    Compute the canonical (renormalized) codebook.

    Maps each proof to its fixed point under renormalization,
    then deduplicates. This is the "holographic compression" of
    the original codebook.

    By renorm_preserves_approx_theoremhood, the canonical codebook
    decides the same approximate theoremhood questions.

    Time complexity: O(|codebook| * C * T) where C = max complexity, T = step cost
    Space complexity: O(|codebook|)

    Args:
        codebook: Original codebook
        renorm: Renormalization operator

    Returns:
        Deduplicated list of canonical representatives
    """
    canonical = set()
    for P in codebook:
        fp, _, _ = renormalize_to_fixed_point(P, renorm)
        canonical.add(fp)
    result = sorted(canonical, key=lambda P: (P.complexity, P.steps))
    return result


# ============================================================
# Algorithm 7: p-adic Complexity
# ============================================================

def padic_valuation(p: int, n: int) -> int:
    """
    Compute the p-adic valuation v_p(n).

    v_p(0) is defined as infinity (returned as -1 here).
    v_p(n) = largest k such that p^k divides n.

    Time complexity: O(log_p(n))
    Space complexity: O(1)

    Args:
        p: Prime number
        n: Non-negative integer

    Returns:
        p-adic valuation (or -1 for n=0)

    >>> padic_valuation(2, 8)
    3
    >>> padic_valuation(3, 9)
    2
    >>> padic_valuation(5, 7)
    0
    """
    if n == 0:
        return -1  # infinity
    v = 0
    while n % p == 0:
        v += 1
        n //= p
    return v


def padic_complexity(p: int, P: ProofSketch) -> int:
    """
    p-adic complexity: v_p(complexity(P) + 1).

    This is a valuation-theoretic complexity measure that captures
    the p-adic "depth" of a proof's complexity.

    >>> P = ProofSketch((1, 2, 4), 0)  # complexity = 7, v_2(8) = 3
    >>> padic_complexity(2, P)
    3
    """
    return padic_valuation(p, P.complexity + 1)


# ============================================================
# Algorithm 8: Compression Ratio Analysis
# ============================================================

def compression_analysis(
    codebook: List[ProofSketch],
    universe: Optional[Set[int]] = None
) -> dict:
    """
    Analyze the compression achieved by renormalization.

    Computes statistics on codebook size, signature diversity,
    and compression ratios before and after renormalization.

    Args:
        codebook: List of proof sketches
        universe: Optional universe of step values

    Returns:
        Dictionary with compression statistics
    """
    # Before renormalization
    signatures_before = {P.semantic_signature for P in codebook}
    total_complexity_before = sum(P.complexity for P in codebook)

    # After renormalization
    canonical = canonical_codebook(codebook)
    signatures_after = {P.semantic_signature for P in canonical}
    total_complexity_after = sum(P.complexity for P in canonical)

    # Universe bound
    if universe is None:
        universe = set()
        for P in codebook:
            universe.update(P.steps)
    n = len(universe)

    return {
        "codebook_size_before": len(codebook),
        "codebook_size_after": len(canonical),
        "compression_ratio": len(codebook) / max(1, len(canonical)),
        "signatures_before": len(signatures_before),
        "signatures_after": len(signatures_after),
        "universe_size": n,
        "theoretical_bound": 2 ** n,
        "bound_satisfied": len(signatures_after) <= 2 ** n,
        "total_complexity_before": total_complexity_before,
        "total_complexity_after": total_complexity_after,
        "complexity_reduction": 1 - total_complexity_after / max(1, total_complexity_before),
    }


if __name__ == "__main__":
    # Quick self-test
    P = ProofSketch((3, 1, 4, 1, 5, 9, 2, 6, 5, 3, 5), 0)
    print(f"Original: {P}, complexity={P.complexity}")

    fp, n, orbit = renormalize_to_fixed_point(P)
    print(f"Fixed point: {fp}, complexity={fp.complexity}, iterations={n}")

    # Codebook test
    cb = generate_bounded_codebook(3, 3)
    print(f"Codebook size (length≤3, val≤3): {len(cb)}")

    target = frozenset({1, 2, 3})
    result = search_approx_theorem(0, target, cb)
    print(f"Exact match for {{{', '.join(map(str, sorted(target)))}}}: {result}")

    # Compression analysis
    stats = compression_analysis(cb)
    print(f"\nCompression analysis:")
    for k, v in stats.items():
        print(f"  {k}: {v}")
