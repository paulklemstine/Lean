#!/usr/bin/env python3
"""
algorithms.py — Core algorithms for reflective convergence analysis.

Implements the improvement iteration, weakness descent, and convergence
detection algorithms formalized in the Lean proofs.
"""

from typing import (
    TypeVar, Generic, Callable, Set, FrozenSet, List, Optional,
    Tuple, Dict, Any
)
from dataclasses import dataclass, field
import time

T = TypeVar('T')


@dataclass
class ConvergenceResult(Generic[T]):
    """Result of running an improvement iteration to convergence."""
    fixed_point: T
    steps: int
    trace: List[T]
    rank_trace: Optional[List[int]] = None
    weakness_trace: Optional[List[int]] = None
    elapsed_seconds: float = 0.0

    def summary(self) -> str:
        lines = [
            f"Converged in {self.steps} steps",
            f"Fixed point: {self.fixed_point}",
        ]
        if self.rank_trace:
            lines.append(f"Rank progression: {self.rank_trace}")
        if self.weakness_trace:
            lines.append(f"Weakness card progression: {self.weakness_trace}")
        lines.append(f"Time: {self.elapsed_seconds:.6f}s")
        return "\n".join(lines)


def reflective_iterate(
    improve: Callable[[T], T],
    start: T,
    rank: Optional[Callable[[T], int]] = None,
    max_iter: int = 10_000,
) -> ConvergenceResult[T]:
    """
    Iterate `improve` starting from `start` until a fixed point is found.

    By the reflective convergence theorem, if `improve` is inflationary with
    strictly increasing rank on non-fixed points, this always terminates
    within |σ| steps (where |σ| is the size of the strategy space).

    Args:
        improve: The improvement operator.
        start: Initial strategy.
        rank: Optional ranking function for tracking progress.
        max_iter: Safety bound on iterations.

    Returns:
        ConvergenceResult with the fixed point, trace, and diagnostics.

    Complexity:
        Time: O(n · C_improve) where n = steps to convergence, C_improve = cost of one improve call.
        Space: O(n) for the trace.
    """
    t0 = time.time()
    trace = [start]
    rank_trace = [rank(start)] if rank else None
    current = start

    for step in range(max_iter):
        next_val = improve(current)
        trace.append(next_val)
        if rank_trace is not None:
            rank_trace.append(rank(next_val))

        if next_val == current:
            elapsed = time.time() - t0
            return ConvergenceResult(
                fixed_point=current,
                steps=step,
                trace=trace,
                rank_trace=rank_trace,
                elapsed_seconds=elapsed,
            )
        current = next_val

    raise RuntimeError(f"Did not converge within {max_iter} iterations")


def weakness_descent_iterate(
    improve: Callable[[T], T],
    weakness: Callable[[T], FrozenSet],
    start: T,
    max_iter: int = 10_000,
) -> ConvergenceResult[T]:
    """
    Iterate `improve` tracking the weakness set until it stabilizes.

    By the weakness descent theorem, if `weakness(improve(s)) ⊆ weakness(s)`
    and strict decrease occurs when they differ, this always terminates
    within |δ| steps (where |δ| is the defect universe size).

    Args:
        improve: The improvement operator.
        weakness: Extracts the current weakness/defect set.
        start: Initial strategy.
        max_iter: Safety bound.

    Returns:
        ConvergenceResult with weakness trace information.

    Complexity:
        Time: O(|δ| · C_improve) where |δ| = max weakness cardinality.
        Space: O(|δ|) for the trace.
    """
    t0 = time.time()
    trace = [start]
    w_trace = [len(weakness(start))]
    current = start

    for step in range(max_iter):
        next_val = improve(current)
        w_curr = weakness(current)
        w_next = weakness(next_val)
        trace.append(next_val)
        w_trace.append(len(w_next))

        if w_next == w_curr:
            elapsed = time.time() - t0
            return ConvergenceResult(
                fixed_point=current,
                steps=step,
                trace=trace,
                weakness_trace=w_trace,
                elapsed_seconds=elapsed,
            )
        current = next_val

    raise RuntimeError(f"Weakness did not stabilize within {max_iter} iterations")


def find_all_fixed_points(
    improve: Callable[[T], T],
    universe: List[T],
) -> List[T]:
    """
    Find all fixed points of `improve` in a finite universe by enumeration.

    Complexity: O(|universe| · C_improve)
    """
    return [x for x in universe if improve(x) == x]


def convergence_basin(
    improve: Callable[[T], T],
    universe: List[T],
) -> Dict[T, List[T]]:
    """
    Compute the basin of attraction for each fixed point.

    For each element in the universe, iterate `improve` to find which
    fixed point it converges to. Group elements by their attractor.

    Complexity: O(|universe|² · C_improve) worst case.
    """
    basins: Dict[T, List[T]] = {}

    for x in universe:
        current = x
        seen = set()
        while current not in seen:
            seen.add(current)
            next_val = improve(current)
            if next_val == current:
                break
            current = next_val
        # current is the fixed point
        if current not in basins:
            basins[current] = []
        basins[current].append(x)

    return basins


def query_strategy_outcomes(
    k: int,
    decide: Callable[[Tuple[bool, ...]], Any],
) -> Set:
    """
    Enumerate all possible outcomes of a k-query strategy.

    By the query bound theorem, |outcomes| ≤ 2^k.

    Complexity: O(2^k · C_decide)
    """
    import itertools
    outcomes = set()
    for bits in itertools.product([False, True], repeat=k):
        outcomes.add(decide(bits))
    return outcomes


# ── Example usage ──

if __name__ == "__main__":
    print("=== Reflective Iteration ===")
    result = reflective_iterate(
        improve=lambda s: min(s + 1, 10),
        start=0,
        rank=lambda s: s,
    )
    print(result.summary())
    print()

    print("=== Weakness Descent ===")
    result = weakness_descent_iterate(
        improve=lambda s: s - {min(s)} if s else s,
        weakness=lambda s: frozenset(s),
        start=frozenset({0, 1, 2, 3, 4}),
    )
    print(result.summary())
    print()

    print("=== Fixed Points ===")
    improve_mod = lambda x: min(x + 1, 5)
    fps = find_all_fixed_points(improve_mod, list(range(10)))
    print(f"Fixed points of min(x+1, 5) in {{0..9}}: {fps}")
    print()

    print("=== Convergence Basins ===")
    basins = convergence_basin(improve_mod, list(range(10)))
    for fp, basin in sorted(basins.items()):
        print(f"  Fixed point {fp} ← {basin}")
    print()

    print("=== Query Strategy Bound ===")
    for k in range(1, 6):
        outcomes = query_strategy_outcomes(k, lambda bits: sum(bits) % 3)
        print(f"  k={k}: {len(outcomes)} distinct outcomes ≤ {2**k}")
