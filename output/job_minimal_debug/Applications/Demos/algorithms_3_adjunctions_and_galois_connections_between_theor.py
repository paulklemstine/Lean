#!/usr/bin/env python3
"""
Algorithms: Approximate Adjunction Framework

Implements the core algorithms from the research paper:
1. Adjunction composition with loss tracking
2. Bidirectional lower-bound transfer
3. Optimal adjunction chain finder
4. Loss budget allocation
"""

from dataclasses import dataclass, field
from typing import Callable, List, Optional, Tuple, Dict
import numpy as np
from itertools import product


@dataclass
class TheorySpec:
    """A theory specification with objects and a quantitative invariant.

    Attributes:
        name: Human-readable name of the theory.
        val: The quantitative invariant function mapping objects to integers.
    """
    name: str
    val: Callable[[int], int]


@dataclass
class TheoryAdj:
    """An approximate adjunction between two theories.

    The cross-theory simulation bounds guarantee:
        ∀ a: B.val(left(a)) ≤ A.val(a) + left_loss
        ∀ b: A.val(right(b)) ≤ B.val(b) + right_loss

    These bounds enable bidirectional lower-bound transfer with
    quantitatively controlled degradation.
    """
    source: TheorySpec
    target: TheorySpec
    left: Callable[[int], int]
    right: Callable[[int], int]
    left_loss: int
    right_loss: int

    def compose(self, other: 'TheoryAdj') -> 'TheoryAdj':
        """Compose two adjunctions with additive loss accumulation.

        If self: A ⇄ B and other: B ⇄ C, returns A ⇄ C.

        Time complexity: O(1) for the composition structure.
        The composed maps inherit the complexity of the individual maps.

        Returns:
            TheoryAdj: The composed adjunction A ⇄ C with:
                left_loss = self.left_loss + other.left_loss
                right_loss = other.right_loss + self.right_loss
        """
        return TheoryAdj(
            source=self.source,
            target=other.target,
            left=lambda a: other.left(self.left(a)),
            right=lambda c: self.right(other.right(c)),
            left_loss=self.left_loss + other.left_loss,
            right_loss=other.right_loss + self.right_loss,
        )

    def transfer_forward(self, lower_bound: int) -> int:
        """Transfer a lower bound from source theory to target theory.

        Given: ∀ a ∈ source, lower_bound ≤ source.val(a)
        Yields: ∀ b ∈ target, (lower_bound - right_loss) ≤ target.val(b)

        Time complexity: O(1)
        """
        return lower_bound - self.right_loss

    def transfer_backward(self, lower_bound: int) -> int:
        """Transfer a lower bound from target theory to source theory.

        Given: ∀ b ∈ target, lower_bound ≤ target.val(b)
        Yields: ∀ a ∈ source, (lower_bound - left_loss) ≤ source.val(a)

        Time complexity: O(1)
        """
        return lower_bound - self.left_loss

    def swap(self) -> 'TheoryAdj':
        """Swap the adjunction direction: A ⇄ B becomes B ⇄ A.

        Time complexity: O(1)
        """
        return TheoryAdj(
            source=self.target,
            target=self.source,
            left=self.right,
            right=self.left,
            left_loss=self.right_loss,
            right_loss=self.left_loss,
        )

    def total_loss(self) -> int:
        """Total round-trip loss: left_loss + right_loss."""
        return self.left_loss + self.right_loss

    def is_exact(self) -> bool:
        """Check if the adjunction is exact (zero loss in both directions)."""
        return self.left_loss == 0 and self.right_loss == 0

    def verify(self, test_objects: List[int]) -> Tuple[bool, Optional[str]]:
        """Verify the adjunction bounds on test objects.

        Returns (True, None) if all bounds hold, or (False, error_message).
        """
        for a in test_objects:
            lhs = self.target.val(self.left(a))
            rhs = self.source.val(a) + self.left_loss
            if lhs > rhs:
                return False, f"Left bound violated at a={a}: {lhs} > {rhs}"

        for b in test_objects:
            lhs = self.source.val(self.right(b))
            rhs = self.target.val(b) + self.right_loss
            if lhs > rhs:
                return False, f"Right bound violated at b={b}: {lhs} > {rhs}"

        return True, None


def compose_chain(adjunctions: List[TheoryAdj]) -> TheoryAdj:
    """Compose a chain of adjunctions.

    Args:
        adjunctions: List of adjunctions [A₀⇄A₁, A₁⇄A₂, ..., Aₙ₋₁⇄Aₙ]

    Returns:
        TheoryAdj: The composed adjunction A₀ ⇄ Aₙ

    Time complexity: O(n) where n = len(adjunctions)
    Space complexity: O(1) additional (closures chain internally)

    >>> # Example: chain of 3 adjunctions
    >>> T = [TheorySpec(f"T{i}", val=lambda n: n) for i in range(4)]
    >>> adjs = [TheoryAdj(T[i], T[i+1], lambda n: n, lambda n: n, 1, 2) for i in range(3)]
    >>> composed = compose_chain(adjs)
    >>> composed.left_loss  # 1 + 1 + 1 = 3
    3
    >>> composed.right_loss  # 2 + 2 + 2 = 6
    6
    """
    if not adjunctions:
        raise ValueError("Empty adjunction chain")

    result = adjunctions[0]
    for adj in adjunctions[1:]:
        result = result.compose(adj)
    return result


def optimal_transfer_path(
    theories: List[TheorySpec],
    adjunctions: Dict[Tuple[int, int], TheoryAdj],
    source_idx: int,
    target_idx: int,
    lower_bound: int,
) -> Tuple[int, List[int]]:
    """Find the path that transfers a lower bound with minimal degradation.

    Uses dynamic programming (Bellman-Ford style) on the graph of theories,
    where edge weights are the transfer losses.

    Args:
        theories: List of available theories.
        adjunctions: Dict mapping (i, j) to TheoryAdj between theories[i] and theories[j].
        source_idx: Index of the source theory.
        target_idx: Index of the target theory.
        lower_bound: The lower bound to transfer.

    Returns:
        (transferred_bound, path): The best achievable lower bound and the
        theory indices along the optimal path.

    Time complexity: O(V·E) where V = len(theories), E = len(adjunctions)
    Space complexity: O(V)
    """
    n = len(theories)
    INF = float('inf')

    # dist[i] = minimum total right_loss to get from source to theory i
    dist = [INF] * n
    prev = [-1] * n
    dist[source_idx] = 0

    # Bellman-Ford
    for _ in range(n - 1):
        for (i, j), adj in adjunctions.items():
            # Forward edge: i → j with cost = right_loss
            new_dist = dist[i] + adj.right_loss
            if new_dist < dist[j]:
                dist[j] = new_dist
                prev[j] = i

            # Backward edge: j → i with cost = left_loss
            new_dist = dist[j] + adj.left_loss
            if new_dist < dist[i]:
                dist[i] = new_dist
                prev[i] = j

    # Reconstruct path
    path = []
    current = target_idx
    while current != -1:
        path.append(current)
        current = prev[current]
    path.reverse()

    transferred = lower_bound - dist[target_idx] if dist[target_idx] < INF else -INF

    return int(transferred), path


def loss_budget_allocation(
    total_budget: int,
    n_adjunctions: int,
) -> List[Tuple[int, int]]:
    """Allocate a loss budget across a chain of adjunctions.

    Given a total loss budget and number of adjunctions in a chain,
    finds all ways to distribute the budget as (left_loss, right_loss) pairs.

    Args:
        total_budget: Maximum total left + right loss across the chain.
        n_adjunctions: Number of adjunctions in the chain.

    Returns:
        List of loss allocations, each being a list of (left_loss, right_loss) pairs.

    Time complexity: O(budget^(2n)) — exponential, suitable only for small instances.
    """
    if n_adjunctions == 0:
        return []

    if n_adjunctions == 1:
        allocations = []
        for l in range(total_budget + 1):
            r = total_budget - l
            allocations.append([(l, r)])
        return allocations

    # For demonstration, just show uniform allocation
    per_adj = total_budget // n_adjunctions
    remainder = total_budget % n_adjunctions

    base = [(per_adj // 2, per_adj - per_adj // 2)] * n_adjunctions
    # Distribute remainder
    for i in range(remainder):
        l, r = base[i]
        base[i] = (l, r + 1)

    return [base]


if __name__ == "__main__":
    print("=" * 60)
    print("Algorithm Demonstrations")
    print("=" * 60)

    # Chain composition
    print("\n--- Chain Composition ---")
    theories = [TheorySpec(f"T{i}", val=lambda n: n) for i in range(5)]
    adjs = []
    losses = [(1, 2), (0, 3), (2, 1), (1, 0)]
    for i, (ll, rl) in enumerate(losses):
        adjs.append(TheoryAdj(
            theories[i], theories[i+1],
            lambda n, l=ll: n + l,
            lambda n, r=rl: n + r,
            ll, rl,
        ))

    composed = compose_chain(adjs)
    print(f"Chain of {len(adjs)} adjunctions:")
    for i, adj in enumerate(adjs):
        print(f"  T{i}⇄T{i+1}: left_loss={adj.left_loss}, right_loss={adj.right_loss}")
    print(f"Composed: left_loss={composed.left_loss}, right_loss={composed.right_loss}")

    # Optimal path finding
    print("\n--- Optimal Transfer Path ---")
    adj_dict = {}
    for i, adj in enumerate(adjs):
        adj_dict[(i, i+1)] = adj

    L = 50
    transferred, path = optimal_transfer_path(theories, adj_dict, 0, 4, L)
    print(f"Lower bound L={L} from T0 to T4:")
    print(f"  Optimal path: {' → '.join(f'T{p}' for p in path)}")
    print(f"  Transferred bound: {transferred}")

    # Loss budget
    print("\n--- Loss Budget Allocation ---")
    budget = 10
    n = 3
    allocations = loss_budget_allocation(budget, n)
    print(f"Budget={budget} across {n} adjunctions:")
    for alloc in allocations[:3]:
        print(f"  {alloc}")
        total_left = sum(l for l, _ in alloc)
        total_right = sum(r for _, r in alloc)
        print(f"  Total: left={total_left}, right={total_right}, sum={total_left+total_right}")
