#!/usr/bin/env python3
"""
Reflective Convergence Architecture — Algorithm Implementations

Implements the core algorithms from the research paper:
1. Reflective iteration with stabilization detection
2. Quality-maximizing selector over admissible moves
3. Finite stabilization with score tracking
4. Local optimality verification
5. Grand composition: find locally optimal fixed points
"""

from typing import (
    TypeVar, Generic, Callable, Optional, List, Dict, Set,
    Tuple, NamedTuple
)
from dataclasses import dataclass, field
import math

S = TypeVar('S')


# =============================================================================
# Core Data Structures
# =============================================================================

@dataclass
class ConvergenceResult(Generic[S]):
    """Result of a reflective iteration run."""
    trajectory: List[S]
    qualities: List[float]
    stabilized: bool
    stabilization_step: Optional[int]
    fixed_point: Optional[S]
    limit_quality: Optional[float]
    
    @property
    def num_steps(self) -> int:
        return len(self.trajectory) - 1


@dataclass
class ResearchSystem(Generic[S]):
    """
    A research system with outcome-dependent strategy spaces.
    
    Attributes:
        admissible: Maps each state to its set of admissible next states.
        quality: Maps each state to a real-valued quality score.
        score: Optional ℕ-valued score for strict progress tracking.
    """
    admissible: Callable[[S], List[S]]
    quality: Callable[[S], float]
    score: Optional[Callable[[S], int]] = None


# =============================================================================
# Algorithm 1: Reflective Iteration
# =============================================================================

def reflective_iterate(
    next_fn: Callable[[S], S],
    s0: S,
    quality: Optional[Callable[[S], float]] = None,
    max_iter: int = 1000,
) -> ConvergenceResult[S]:
    """
    Iterate a reflective improvement operator until stabilization.
    
    This implements the core loop of Theorem 3.1 (convergence) and
    Theorem 4.1 (stabilization).
    
    Args:
        next_fn: The improvement operator s ↦ next(s).
        s0: Initial state.
        quality: Optional quality function for tracking convergence.
        max_iter: Maximum number of iterations.
    
    Returns:
        ConvergenceResult with trajectory, qualities, and stabilization info.
    
    Complexity: O(N * C_next) where N is stabilization step, C_next is cost of next_fn.
    """
    trajectory = [s0]
    qualities = [quality(s0)] if quality else []
    s = s0
    
    for i in range(1, max_iter + 1):
        s_next = next_fn(s)
        trajectory.append(s_next)
        if quality:
            qualities.append(quality(s_next))
        
        if s_next == s:
            return ConvergenceResult(
                trajectory=trajectory,
                qualities=qualities,
                stabilized=True,
                stabilization_step=i,
                fixed_point=s,
                limit_quality=quality(s) if quality else None,
            )
        s = s_next
    
    return ConvergenceResult(
        trajectory=trajectory,
        qualities=qualities,
        stabilized=False,
        stabilization_step=None,
        fixed_point=None,
        limit_quality=qualities[-1] if qualities else None,
    )


# =============================================================================
# Algorithm 2: Quality-Maximizing Selector
# =============================================================================

def argmax_selector(
    admissible: Callable[[S], List[S]],
    quality: Callable[[S], float],
) -> Callable[[S], S]:
    """
    Construct a quality-maximizing selector over admissible moves.
    
    Given admissibility function A and quality q, returns a function
    next(s) = argmax_{t ∈ A(s)} q(t).
    
    This implements the selector used in Theorem 5.1 (local optimality).
    
    Args:
        admissible: Maps each state to its list of admissible successors.
        quality: Quality function.
    
    Returns:
        Selector function next : S → S.
    
    Complexity per call: O(|A(s)| * C_q)
    """
    def selector(s: S) -> S:
        candidates = admissible(s)
        if not candidates:
            return s
        return max(candidates, key=quality)
    return selector


# =============================================================================
# Algorithm 3: Finite Stabilization with Score Tracking
# =============================================================================

def finite_stabilize(
    update: Callable[[S], S],
    score: Callable[[S], int],
    s0: S,
    max_iter: int = 10000,
) -> Tuple[S, int, List[Tuple[S, int]]]:
    """
    Find the stabilization point of a finite reflective system.
    
    Implements Theorem 4.1: under strict progress (update(s) ≠ s ⟹ score(s) < score(update(s))),
    the iteration must stabilize.
    
    Args:
        update: The update function.
        score: ℕ-valued score function.
        s0: Initial state.
        max_iter: Safety bound on iterations.
    
    Returns:
        (fixed_point, stabilization_step, history) where history is [(state, score)].
    
    Raises:
        RuntimeError: If max_iter exceeded (shouldn't happen under theorem hypotheses).
    """
    history = [(s0, score(s0))]
    s = s0
    
    for i in range(1, max_iter + 1):
        s_next = update(s)
        history.append((s_next, score(s_next)))
        
        if s_next == s:
            return s, i, history
        
        # Verify strict progress (runtime check of theorem hypothesis)
        assert score(s) < score(s_next), (
            f"Strict progress violated: score({s}) = {score(s)} "
            f"≥ score({s_next}) = {score(s_next)}"
        )
        s = s_next
    
    raise RuntimeError(f"Stabilization not achieved within {max_iter} steps")


# =============================================================================
# Algorithm 4: Local Optimality Verification
# =============================================================================

def verify_local_optimality(
    state: S,
    admissible: Callable[[S], List[S]],
    quality: Callable[[S], float],
) -> Tuple[bool, Optional[S]]:
    """
    Verify that a state is locally optimal.
    
    Implements the check from Definition 2.3:
    s is locally optimal iff ∀ t ∈ A(s), q(t) ≤ q(s).
    
    Args:
        state: The state to check.
        admissible: Admissibility function.
        quality: Quality function.
    
    Returns:
        (is_optimal, counterexample) where counterexample is a better
        admissible state if not optimal, None otherwise.
    """
    q_s = quality(state)
    for t in admissible(state):
        if quality(t) > q_s:
            return False, t
    return True, None


# =============================================================================
# Algorithm 5: Grand Composition
# =============================================================================

def find_local_optimum(
    system: ResearchSystem[S],
    s0: S,
    max_iter: int = 10000,
) -> ConvergenceResult[S]:
    """
    Find a locally optimal state by reflective iteration.
    
    Implements Theorem 6.1: given a finite reflective system with
    quality-maximizing updates and strict progress, find the locally
    optimal fixed point.
    
    Args:
        system: A ResearchSystem with admissible, quality, and optionally score.
        s0: Initial state.
        max_iter: Maximum iterations.
    
    Returns:
        ConvergenceResult with the locally optimal fixed point.
    """
    selector = argmax_selector(system.admissible, system.quality)
    result = reflective_iterate(
        next_fn=selector,
        s0=s0,
        quality=system.quality,
        max_iter=max_iter,
    )
    
    if result.stabilized and result.fixed_point is not None:
        is_optimal, _ = verify_local_optimality(
            result.fixed_point, system.admissible, system.quality
        )
        assert is_optimal, "Fixed point should be locally optimal (Theorem 5.1)"
    
    return result


# =============================================================================
# Example Usage
# =============================================================================

if __name__ == "__main__":
    print("=== Algorithm Demonstrations ===\n")
    
    # Example: 8-state system
    n = 8
    import random
    random.seed(123)
    
    qs = {i: random.uniform(0, 10) for i in range(n)}
    adj = {i: sorted(set([i] + random.sample(range(n), 3))) for i in range(n)}
    
    system = ResearchSystem(
        admissible=lambda s: adj[s],
        quality=lambda s: qs[s],
        score=lambda s: int(qs[s] * 1000),
    )
    
    print("State qualities:", {k: f"{v:.2f}" for k, v in qs.items()})
    print("Admissibility:", adj)
    print()
    
    for s0 in range(n):
        result = find_local_optimum(system, s0)
        opt_check, _ = verify_local_optimality(
            result.fixed_point, system.admissible, system.quality
        )
        print(
            f"Start={s0}: fixed_pt={result.fixed_point}, "
            f"quality={system.quality(result.fixed_point):.2f}, "
            f"steps={result.stabilization_step}, "
            f"locally_optimal={opt_check}"
        )
