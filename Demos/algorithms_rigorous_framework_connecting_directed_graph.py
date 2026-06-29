#!/usr/bin/env python3
"""
Spectral Proof Complexity — Core Algorithms

Type-hinted implementations of derivation system analysis:
proof ball computation, frontier analysis, expansion certificates,
depth lower bounds, and proof domination checking.
"""

from dataclasses import dataclass, field
from typing import Callable, Dict, FrozenSet, List, Optional, Set, Tuple


@dataclass
class DerivationSystem:
    """A derivation system: axioms and a one-step derivation function."""

    axioms: FrozenSet[int]
    derives: Dict[int, FrozenSet[int]]

    def get_derives(self, a: int) -> FrozenSet[int]:
        return self.derives.get(a, frozenset())


@dataclass
class ProofBallResult:
    """Result of computing proof balls up to depth k."""

    balls: List[FrozenSet[int]]
    frontiers: List[FrozenSet[int]]
    stabilization_depth: Optional[int]


@dataclass
class ExpansionCertificate:
    """Certificate that a derivation system has sustained expansion."""

    steps: int
    min_frontier: int
    frontier_sizes: List[int]

    def ball_growth_lower_bound(self, axiom_count: int) -> int:
        """Lower bound on |Ball(steps)| from the certificate."""
        return axiom_count + self.steps * self.min_frontier


def compute_proof_balls(system: DerivationSystem, max_depth: int) -> ProofBallResult:
    """
    Compute proof balls Ball(0), ..., Ball(max_depth).

    Returns ProofBallResult with balls, frontiers, and stabilization depth.

    Time: O(max_depth * |Ball(max_depth)| * max_degree)
    Space: O(max_depth * |Ball(max_depth)|)
    """
    balls: List[FrozenSet[int]] = [system.axioms]
    frontiers: List[FrozenSet[int]] = []
    stabilization_depth: Optional[int] = None

    for k in range(max_depth):
        current = balls[-1]
        new_statements: Set[int] = set()
        for a in current:
            new_statements |= system.get_derives(a)
        frontier = frozenset(new_statements - current)
        frontiers.append(frontier)

        next_ball = frozenset(current | frontier)
        balls.append(next_ball)

        if next_ball == current and stabilization_depth is None:
            stabilization_depth = k

    return ProofBallResult(balls, frontiers, stabilization_depth)


def compute_expansion_certificate(
    system: DerivationSystem, max_depth: int
) -> ExpansionCertificate:
    """
    Compute an expansion certificate for the derivation system.

    Returns the number of active expansion steps and the minimum frontier size.
    """
    result = compute_proof_balls(system, max_depth)
    active_frontiers = [
        (i, len(f)) for i, f in enumerate(result.frontiers) if len(f) > 0
    ]

    if not active_frontiers:
        return ExpansionCertificate(steps=0, min_frontier=0, frontier_sizes=[])

    steps = len(active_frontiers)
    sizes = [s for _, s in active_frontiers]
    return ExpansionCertificate(
        steps=steps, min_frontier=min(sizes), frontier_sizes=sizes
    )


def depth_lower_bound(target_card: int, axiom_card: int, max_frontier: int) -> int:
    """
    Compute the depth lower bound: (target_card - axiom_card) // max_frontier.

    This is a proof-length lower bound: any derivation system reaching
    target_card statements from axiom_card axioms with frontier ≤ max_frontier
    requires at least this many steps.
    """
    if max_frontier <= 0:
        return 0
    return max(0, target_card - axiom_card) // max_frontier


def check_proof_domination(
    d1: DerivationSystem, d2: DerivationSystem, max_depth: int
) -> Tuple[bool, Optional[int]]:
    """
    Check if D1 proof-dominates D2 up to depth max_depth.

    Returns (dominates, first_violation_depth).
    D1 dominates D2 if Ball_{D2}(k) ⊆ Ball_{D1}(k) for all k.
    """
    r1 = compute_proof_balls(d1, max_depth)
    r2 = compute_proof_balls(d2, max_depth)

    for k in range(min(len(r1.balls), len(r2.balls))):
        if not r2.balls[k] <= r1.balls[k]:
            return False, k

    return True, None


def is_derivation_closed(system: DerivationSystem, s: FrozenSet[int]) -> bool:
    """Check if a set S is closed under derivation: ∀a ∈ S, derives(a) ⊆ S."""
    for a in s:
        if not system.get_derives(a) <= s:
            return False
    return True


def find_derivation_depth(
    system: DerivationSystem, target: int, max_depth: int = 1000
) -> Optional[int]:
    """Find the minimum derivation depth for a target statement."""
    result = compute_proof_balls(system, max_depth)
    for k, ball in enumerate(result.balls):
        if target in ball:
            return k
    return None


def verify_reachability_dichotomy(
    system: DerivationSystem, universe: FrozenSet[int], max_depth: int
) -> Tuple[FrozenSet[int], FrozenSet[int]]:
    """
    Compute the reachability dichotomy: partition the universe into
    derivable and permanently unreachable sets.
    """
    result = compute_proof_balls(system, max_depth)

    # Find stabilization
    derivable = result.balls[-1]
    if result.stabilization_depth is not None:
        derivable = result.balls[result.stabilization_depth]

    unreachable = universe - derivable
    return derivable, unreachable


# ============================================================
# Example usage
# ============================================================
if __name__ == "__main__":
    # Binary tree derivation system
    system = DerivationSystem(
        axioms=frozenset({1}),
        derives={i: frozenset({2 * i, 2 * i + 1}) for i in range(1, 32)},
    )

    result = compute_proof_balls(system, 5)
    cert = compute_expansion_certificate(system, 5)

    print("Binary Tree Derivation System")
    print(f"  Balls: {[len(b) for b in result.balls]}")
    print(f"  Frontiers: {[len(f) for f in result.frontiers]}")
    print(f"  Expansion certificate: steps={cert.steps}, min_frontier={cert.min_frontier}")
    print(
        f"  Growth lower bound: {cert.ball_growth_lower_bound(len(system.axioms))}"
    )
    print(f"  Depth to reach node 15: {find_derivation_depth(system, 15)}")

    # Check closure
    ball3 = result.balls[3]
    print(f"  Ball(3) closed under derivation: {is_derivation_closed(system, ball3)}")
    ball5 = result.balls[5]
    print(f"  Ball(5) closed under derivation: {is_derivation_closed(system, ball5)}")
