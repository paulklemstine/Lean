"""
Exchange Family Descent Complexity: Core Algorithms

Type-hinted implementations of the exchange family descent framework.
Provides data structures for exchange families, descent chains, tropical
valuations, and product tensorization.
"""

from __future__ import annotations
from dataclasses import dataclass, field
from typing import Callable, Generic, TypeVar, Optional
import math

T = TypeVar('T')
S = TypeVar('S')


@dataclass
class ExchangeFamily(Generic[T]):
    """An exchange family: states with a measure and exchange relation.

    The measure strictly decreases under exchanges, guaranteeing termination
    of any descent process.

    Attributes:
        states: List of all states in the family.
        measure: Maps each state to a non-negative integer measure.
        can_exchange: Returns True if state x can exchange to state y.
    """
    states: list[T]
    measure: Callable[[T], int]
    can_exchange: Callable[[T, T], bool]

    def validate(self) -> bool:
        """Check that all exchanges strictly decrease the measure."""
        for x in self.states:
            for y in self.states:
                if self.can_exchange(x, y):
                    if self.measure(y) >= self.measure(x):
                        return False
        return True

    def local_minima(self) -> list[T]:
        """Find all local minima (states with no exchange successors)."""
        return [x for x in self.states if not any(
            self.can_exchange(x, y) for y in self.states
        )]

    def successors(self, x: T) -> list[T]:
        """All states reachable from x by one exchange."""
        return [y for y in self.states if self.can_exchange(x, y)]

    def max_measure(self) -> int:
        """Maximum measure across all states."""
        return max(self.measure(x) for x in self.states)


@dataclass
class DescentChain(Generic[T]):
    """A descent chain in an exchange family.

    A sequence of states where each consecutive pair is related by exchange.
    """
    family: ExchangeFamily[T]
    chain: list[T]

    def is_valid(self) -> bool:
        """Verify this is a valid descent chain."""
        for i in range(len(self.chain) - 1):
            if not self.family.can_exchange(self.chain[i], self.chain[i + 1]):
                return False
        return True

    def length(self) -> int:
        """Number of states in the chain."""
        return len(self.chain)

    def depth(self) -> int:
        """Number of exchange steps (length - 1)."""
        return max(0, len(self.chain) - 1)

    def measures(self) -> list[int]:
        """Sequence of measures along the chain."""
        return [self.family.measure(x) for x in self.chain]

    def is_maximal(self) -> bool:
        """True if the chain cannot be extended."""
        if not self.chain:
            return True
        last = self.chain[-1]
        return not any(self.family.can_exchange(last, y)
                       for y in self.family.states)


@dataclass
class TropicalDescentValuation(Generic[T]):
    """A tropical descent valuation assigns costs to exchanges.

    Creates a dual view of descent: instead of counting steps (depth),
    we measure total computational weight (cost).
    """
    family: ExchangeFamily[T]
    cost: Callable[[T, T], int]

    def chain_cost(self, chain: list[T]) -> int:
        """Total cost along a descent chain."""
        return sum(self.cost(chain[i], chain[i + 1])
                   for i in range(len(chain) - 1))

    def min_cost_per_step(self) -> int:
        """Minimum cost of any single exchange."""
        costs = []
        for x in self.family.states:
            for y in self.family.states:
                if self.family.can_exchange(x, y):
                    costs.append(self.cost(x, y))
        return min(costs) if costs else 0

    def max_cost_per_step(self) -> int:
        """Maximum cost of any single exchange."""
        costs = []
        for x in self.family.states:
            for y in self.family.states:
                if self.family.can_exchange(x, y):
                    costs.append(self.cost(x, y))
        return max(costs) if costs else 0


def greedy_descent(family: ExchangeFamily[T], start: T) -> DescentChain[T]:
    """Find a greedy descent chain starting from `start`.

    At each step, choose the successor with the largest measure decrease.
    Guaranteed to terminate by the exchange_decreasing property.
    """
    chain = [start]
    current = start
    while True:
        succs = family.successors(current)
        if not succs:
            break
        # Choose successor with smallest measure (greediest descent)
        best = min(succs, key=family.measure)
        chain.append(best)
        current = best
    return DescentChain(family, chain)


def longest_descent(family: ExchangeFamily[T], start: T) -> DescentChain[T]:
    """Find the longest descent chain from `start` (exhaustive search).

    Uses DFS to find the longest path in the exchange DAG.
    Exponential in the worst case but guaranteed to find the optimum.
    """
    best_chain: list[T] = [start]

    def dfs(current: T, path: list[T]) -> None:
        nonlocal best_chain
        if len(path) > len(best_chain):
            best_chain = list(path)
        for y in family.successors(current):
            path.append(y)
            dfs(y, path)
            path.pop()

    dfs(start, [start])
    return DescentChain(family, best_chain)


def product_family(
    e1: ExchangeFamily[T],
    e2: ExchangeFamily[S]
) -> ExchangeFamily[tuple[T, S]]:
    """Construct the product of two exchange families.

    The product measure is the sum. Exchanges happen in one component at a time.
    """
    states = [(a, b) for a in e1.states for b in e2.states]

    def measure(p: tuple[T, S]) -> int:
        return e1.measure(p[0]) + e2.measure(p[1])

    def can_exchange(p: tuple[T, S], q: tuple[T, S]) -> bool:
        return ((e1.can_exchange(p[0], q[0]) and p[1] == q[1]) or
                (p[0] == q[0] and e2.can_exchange(p[1], q[1])))

    return ExchangeFamily(states, measure, can_exchange)


def depth_cost_tradeoff(
    valuation: TropicalDescentValuation[T],
    chain: list[T]
) -> dict[str, float]:
    """Compute the depth-cost tradeoff for a given chain.

    Returns bounds and ratios from the fundamental tradeoff theorem.
    """
    w = valuation.min_cost_per_step()
    W = valuation.max_cost_per_step()
    depth = max(0, len(chain) - 1)
    total_cost = valuation.chain_cost(chain)
    head_measure = valuation.family.measure(chain[0]) if chain else 0

    return {
        'depth': depth,
        'total_cost': total_cost,
        'min_cost_per_step': w,
        'max_cost_per_step': W,
        'lower_bound': w * depth,
        'upper_bound': W * depth,
        'measure_bound': head_measure,
        'cost_per_depth': total_cost / depth if depth > 0 else 0,
        'lower_satisfied': w * depth <= total_cost,
        'upper_satisfied': total_cost <= W * depth,
        'depth_satisfied': depth <= head_measure,
    }


def compute_exchange_graph(family: ExchangeFamily[T]) -> dict[T, list[T]]:
    """Build the exchange DAG as an adjacency list."""
    return {x: family.successors(x) for x in family.states}


def count_states_by_measure(family: ExchangeFamily[T]) -> dict[int, int]:
    """Count states at each measure level."""
    counts: dict[int, int] = {}
    for x in family.states:
        m = family.measure(x)
        counts[m] = counts.get(m, 0) + 1
    return dict(sorted(counts.items()))


def verify_binary_conjecture(
    family: ExchangeFamily[T]
) -> dict[str, object]:
    """Test the binary exchange depth bound conjecture.

    Checks whether n+1 ≤ 2^(max_measure + 1) when every state has
    at most 2 exchange predecessors.
    """
    n_plus_1 = len(family.states)
    max_m = family.max_measure()

    # Check binary in-degree
    in_degrees: dict[T, int] = {x: 0 for x in family.states}
    for x in family.states:
        for y in family.states:
            if family.can_exchange(x, y):
                in_degrees[y] = in_degrees.get(y, 0) + 1

    max_in_degree = max(in_degrees.values()) if in_degrees else 0
    is_binary = max_in_degree <= 2

    bound = 2 ** (max_m + 1)
    conjecture_holds = n_plus_1 <= bound

    return {
        'n_plus_1': n_plus_1,
        'max_measure': max_m,
        'bound': bound,
        'is_binary': is_binary,
        'conjecture_holds': conjecture_holds,
        'max_in_degree': max_in_degree,
        'log2_ratio': math.log2(n_plus_1) / (max_m + 1) if max_m >= 0 else None,
    }
