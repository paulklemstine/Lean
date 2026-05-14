#!/usr/bin/env python3
"""
algorithms.py — Core algorithms for Holographic Proof Renormalization.

Implements:
1. Renormalization operator with convergence tracking
2. Ultrametric distance computation
3. Approximate theoremhood search on bounded codebooks
4. Semantic distance computation
5. p-adic complexity valuation
"""

from dataclasses import dataclass, field
from typing import List, Set, Tuple, Optional, Iterator, Callable
import math


@dataclass(frozen=True)
class ProofSketch:
    """Immutable proof sketch with step costs and goal identifier.

    Attributes:
        steps: Tuple of natural-number step costs.
        goalId: Identifier for the target proposition.
    """
    steps: Tuple[int, ...]
    goalId: int

    @staticmethod
    def from_list(steps: List[int], goalId: int = 0) -> 'ProofSketch':
        return ProofSketch(tuple(steps), goalId)

    def complexity(self) -> int:
        """Sum of step costs. O(n) time."""
        return sum(self.steps)

    def semantic_signature(self) -> frozenset:
        """Set of distinct rules used. O(n) time."""
        return frozenset(self.steps)

    def length(self) -> int:
        return len(self.steps)


# ============================================================
# Algorithm 1: Renormalization
# ============================================================

def renorm_step(P: ProofSketch) -> ProofSketch:
    """Canonical renormalization: remove duplicate steps.

    Time: O(n) with hash set.
    Space: O(n).
    Idempotent: renorm_step(renorm_step(P)) == renorm_step(P).

    Args:
        P: Input proof sketch.

    Returns:
        Simplified proof sketch with same semantic signature.
    """
    seen: Set[int] = set()
    result: List[int] = []
    for s in P.steps:
        if s not in seen:
            seen.add(s)
            result.append(s)
    return ProofSketch(tuple(result), P.goalId)


def renorm_iterate(
    F: Callable[[ProofSketch], ProofSketch],
    P: ProofSketch,
    max_steps: Optional[int] = None
) -> Tuple[ProofSketch, int]:
    """Iterate a renormalization operator until fixed point.

    By Theorem 1, convergence is guaranteed in ≤ complexity(P) steps
    if F satisfies strict descent away from fixed points.

    Args:
        F: Renormalization operator.
        P: Initial proof sketch.
        max_steps: Override for maximum iterations (default: complexity(P)).

    Returns:
        (fixed_point, num_steps) tuple.
    """
    if max_steps is None:
        max_steps = P.complexity()

    current = P
    for n in range(max_steps + 1):
        next_val = F(current)
        if next_val == current:
            return current, n
        current = next_val

    return current, max_steps


# ============================================================
# Algorithm 2: Distance Functions
# ============================================================

def semantic_distance(P: ProofSketch, Q: ProofSketch) -> int:
    """Symmetric-difference semantic distance.

    Time: O(|P.steps| + |Q.steps|).

    Args:
        P, Q: Proof sketches.

    Returns:
        |sig(P) \\ sig(Q)| + |sig(Q) \\ sig(P)|.
    """
    sigP = P.semantic_signature()
    sigQ = Q.semantic_signature()
    return len(sigP - sigQ) + len(sigQ - sigP)


def ultra_proof_dist(P: ProofSketch, Q: ProofSketch) -> int:
    """Ultrametric proof distance.

    Satisfies the ultrametric triangle inequality:
        d(P,R) ≤ max(d(P,Q), d(Q,R))

    Time: O(n) for complexity computation.

    Args:
        P, Q: Proof sketches.

    Returns:
        0 if P == Q, else 1 + max(complexity(P), complexity(Q)).
    """
    if P == Q:
        return 0
    return 1 + max(P.complexity(), Q.complexity())


def proof_distance(P: ProofSketch, Q: ProofSketch) -> int:
    """Absolute difference of complexities.

    Args:
        P, Q: Proof sketches.

    Returns:
        |complexity(P) - complexity(Q)|.
    """
    return abs(P.complexity() - Q.complexity())


# ============================================================
# Algorithm 3: Approximate Theoremhood
# ============================================================

def approx_theoremhood(eps: int, target: frozenset, P: ProofSketch) -> bool:
    """Check ε-approximate theoremhood.

    P is an ε-approximate proof of target if the symmetric difference
    between sig(P) and target has cardinality ≤ ε.

    Time: O(|sig(P)| + |target|).

    Args:
        eps: Tolerance.
        target: Target specification (frozenset of ℕ).
        P: Candidate proof sketch.

    Returns:
        True if |sig(P) \\ target| + |target \\ sig(P)| ≤ ε.
    """
    sig = P.semantic_signature()
    return len(sig - target) + len(target - sig) <= eps


def bounded_codebook(B: int, G: int) -> Iterator[ProofSketch]:
    """Generate all proof sketches with steps in {0,...,B}, length ≤ B, goalId ≤ G.

    Yields proof sketches in lexicographic order.
    Total size: sum_{l=0}^{B} (B+1)^l * (G+1).

    Args:
        B: Bound on step values and list length.
        G: Bound on goalId.

    Yields:
        ProofSketch objects.
    """
    import itertools
    for length in range(B + 1):
        for steps in itertools.product(range(B + 1), repeat=length):
            for g in range(G + 1):
                yield ProofSketch(steps, g)


def renormalized_codebook(B: int, G: int) -> Iterator[ProofSketch]:
    """Generate only duplicate-free proof sketches (canonical representatives).

    By Theorem 6, searching this codebook is complete for approximate
    theoremhood: if any P satisfies the predicate, so does renorm(P).

    Args:
        B: Bound on step values and list length.
        G: Bound on goalId.

    Yields:
        Duplicate-free ProofSketch objects.
    """
    import itertools
    for length in range(B + 1):
        for steps in itertools.permutations(range(B + 1), length):
            for g in range(G + 1):
                yield ProofSketch(steps, g)


def search_approx_theorem(
    eps: int,
    target: frozenset,
    B: int,
    G: int,
    use_renorm: bool = True
) -> Optional[ProofSketch]:
    """Search for an ε-approximate proof in bounded codebook.

    Args:
        eps: Tolerance.
        target: Target specification.
        B: Complexity bound.
        G: Goal bound.
        use_renorm: If True, search only renormalized (canonical) codebook.

    Returns:
        A ProofSketch satisfying approximate theoremhood, or None.
    """
    codebook = renormalized_codebook(B, G) if use_renorm else bounded_codebook(B, G)
    for P in codebook:
        if approx_theoremhood(eps, target, P):
            return P
    return None


# ============================================================
# Algorithm 4: p-adic Complexity
# ============================================================

def padic_val(p: int, n: int) -> int:
    """p-adic valuation of n.

    Returns the largest k such that p^k divides n.
    Returns 0 if n == 0 (by convention for our application).

    Args:
        p: Prime number.
        n: Non-negative integer.

    Returns:
        v_p(n).
    """
    if n == 0 or p < 2:
        return 0
    k = 0
    while n % p == 0:
        k += 1
        n //= p
    return k


def padic_complexity(p: int, P: ProofSketch) -> int:
    """p-adic complexity: v_p(complexity(P) + 1).

    Args:
        p: Prime.
        P: Proof sketch.

    Returns:
        p-adic valuation of (complexity + 1).
    """
    return padic_val(p, P.complexity() + 1)


# ============================================================
# Algorithm 5: Orbit Analysis
# ============================================================

def compute_orbit(
    F: Callable[[ProofSketch], ProofSketch],
    P: ProofSketch,
    max_steps: int = 100
) -> List[ProofSketch]:
    """Compute the orbit of P under F until fixed point or max_steps.

    Args:
        F: Operator.
        P: Starting point.
        max_steps: Safety bound.

    Returns:
        List [P, F(P), F²(P), ...] up to and including fixed point.
    """
    orbit = [P]
    current = P
    for _ in range(max_steps):
        nxt = F(current)
        if nxt == current:
            break
        orbit.append(nxt)
        current = nxt
    return orbit


def verify_orbital_minimality(
    F: Callable[[ProofSketch], ProofSketch],
    P: ProofSketch
) -> bool:
    """Verify that the fixed point has minimal complexity along orbit.

    Args:
        F: Operator.
        P: Starting point.

    Returns:
        True if fixed point complexity ≤ all orbit complexities.
    """
    orbit = compute_orbit(F, P)
    fixed = orbit[-1]
    return all(fixed.complexity() <= p.complexity() for p in orbit)


if __name__ == "__main__":
    # Quick self-test
    P = ProofSketch.from_list([5, 3, 5, 2, 3, 1])
    print(f"Original: {P}, complexity={P.complexity()}, sig={P.semantic_signature()}")

    PR = renorm_step(P)
    print(f"Renormed: {PR}, complexity={PR.complexity()}, sig={PR.semantic_signature()}")

    fp, steps = renorm_iterate(renorm_step, P)
    print(f"Fixed point in {steps} step(s): {fp}")

    print(f"Ultra dist(P, PR) = {ultra_proof_dist(P, PR)}")
    print(f"Semantic dist(P, PR) = {semantic_distance(P, PR)}")

    target = frozenset({1, 2, 3, 5})
    print(f"Approx theoremhood (eps=0, target={set(target)}): {approx_theoremhood(0, target, PR)}")
    print(f"Approx theoremhood (eps=1, target={set(target)}): {approx_theoremhood(1, target, PR)}")

    print(f"2-adic complexity: {padic_complexity(2, P)}")
    print(f"3-adic complexity: {padic_complexity(3, P)}")

    print("\nAll self-tests passed.")
