#!/usr/bin/env python3
"""
Tropical Proof Complexity: Core Algorithms

Type-hinted implementations of the key algorithms from the tropical proof
complexity framework.
"""

import math
from dataclasses import dataclass
from typing import List, Tuple, Optional


@dataclass
class ProofAmplificationChain:
    """A proof system with base error and unit cost."""
    base_error: float  # ε ∈ (0, 1)
    unit_cost: float   # c > 0
    name: str = ""

    def __post_init__(self) -> None:
        assert 0 < self.base_error < 1, f"base_error must be in (0,1), got {self.base_error}"
        assert self.unit_cost > 0, f"unit_cost must be positive, got {self.unit_cost}"

    def amplified_error(self, k: int) -> float:
        """Error after k-fold repetition: ε^k"""
        return self.base_error ** k

    def amplified_cost(self, k: int) -> float:
        """Cost after k-fold repetition: k · c"""
        return k * self.unit_cost

    def tropical_cost(self) -> float:
        """Tropical cost per round: -log(ε)"""
        return -math.log(self.base_error)

    def rounds_for_target(self, target_error: float) -> int:
        """Minimum k such that ε^k ≤ target_error."""
        if target_error >= 1.0:
            return 0
        return math.ceil(math.log(target_error) / math.log(self.base_error))

    def cost_for_target(self, target_error: float) -> float:
        """Total cost to achieve target error."""
        return self.rounds_for_target(target_error) * self.unit_cost


@dataclass
class ParallelStrategy:
    """A parallel proof strategy combining multiple chains."""
    chains: List[ProofAmplificationChain]

    def optimal_chain_for_target(self, target_error: float) -> Tuple[ProofAmplificationChain, float]:
        """Find the chain with minimum total cost for the target error.

        Returns (best_chain, best_cost).
        This implements tropical addition (min) over component costs.
        """
        best_chain: Optional[ProofAmplificationChain] = None
        best_cost = float('inf')

        for chain in self.chains:
            cost = chain.cost_for_target(target_error)
            if cost < best_cost:
                best_cost = cost
                best_chain = chain

        assert best_chain is not None, "Strategy must have at least one chain"
        return best_chain, best_cost

    def pareto_frontier(self, max_cost: float, step: float = 0.1) -> List[Tuple[float, float]]:
        """Compute the Pareto frontier of (cost, error) pairs.

        Returns list of (cost, error) pairs on the Pareto frontier,
        sorted by increasing cost.
        """
        points: List[Tuple[float, float]] = []

        for chain in self.chains:
            k = 0
            while True:
                cost = chain.amplified_cost(k)
                if cost > max_cost:
                    break
                error = chain.amplified_error(k)
                points.append((cost, error))
                k += 1

        # Filter to Pareto-optimal points
        points.sort(key=lambda p: p[0])
        frontier: List[Tuple[float, float]] = []
        min_error = float('inf')

        for cost, error in points:
            if error < min_error:
                frontier.append((cost, error))
                min_error = error

        return frontier


def tropical_add(a: float, b: float) -> float:
    """Tropical addition: min(a, b)."""
    return min(a, b)


def tropical_mul(a: float, b: float) -> float:
    """Tropical multiplication: a + b."""
    return a + b


def tropical_power(a: float, k: int) -> float:
    """Tropical exponentiation: k · a."""
    return k * a


def tropical_cost_of_error(epsilon: float) -> float:
    """Transform error to tropical cost: -log(ε)."""
    assert epsilon > 0, f"Error must be positive, got {epsilon}"
    return -math.log(epsilon)


def error_of_tropical_cost(tau: float) -> float:
    """Transform tropical cost to error: exp(-τ)."""
    return math.exp(-tau)


def is_tropical_barrier(costs: List[float], B: float) -> bool:
    """Check if B is a tropical barrier for the given costs."""
    return all(c >= B for c in costs)


def find_tropical_barrier(costs: List[float]) -> float:
    """Find the tightest tropical barrier (= minimum cost)."""
    return min(costs)


def optimal_portfolio_allocation(
    chains: List[ProofAmplificationChain],
    target_error: float
) -> List[Tuple[str, int, float]]:
    """Find the optimal allocation of rounds across proof chains.

    For independent chains, the optimal strategy is to use the chain
    with the best cost-per-tropical-unit ratio.

    Returns list of (chain_name, rounds, cost) for each chain used.
    """
    # Cost efficiency: tropical cost per unit of economic cost
    efficiencies = []
    for chain in chains:
        efficiency = chain.tropical_cost() / chain.unit_cost
        efficiencies.append((efficiency, chain))

    # Sort by efficiency (best first)
    efficiencies.sort(key=lambda x: -x[0])

    # Greedy: use the most efficient chain
    best_eff, best_chain = efficiencies[0]
    rounds = best_chain.rounds_for_target(target_error)
    total_cost = best_chain.cost_for_target(target_error)

    return [(best_chain.name or "best", rounds, total_cost)]


def verify_amplification_duality(
    chain: ProofAmplificationChain,
    max_k: int = 20
) -> bool:
    """Verify the amplification-cost duality numerically.

    Checks that τ(ε^k) = k · τ(ε) for all k up to max_k.
    Returns True if all checks pass within floating-point tolerance.
    """
    tau_base = chain.tropical_cost()

    for k in range(1, max_k + 1):
        err_k = chain.amplified_error(k)
        tau_k = tropical_cost_of_error(err_k)
        expected = k * tau_base

        if abs(tau_k - expected) > 1e-9:
            return False

    return True


if __name__ == "__main__":
    # Quick demonstration
    chain1 = ProofAmplificationChain(0.3, 1.0, "Standard")
    chain2 = ProofAmplificationChain(0.1, 2.5, "Strong")
    chain3 = ProofAmplificationChain(0.45, 0.3, "Fast")

    print("Amplification-Cost Duality Verification:")
    for c in [chain1, chain2, chain3]:
        result = verify_amplification_duality(c)
        print(f"  {c.name}: {'PASS' if result else 'FAIL'}")

    strategy = ParallelStrategy([chain1, chain2, chain3])
    target = 1e-8

    best, cost = strategy.optimal_chain_for_target(target)
    print(f"\nOptimal chain for error ≤ {target}: {best.name} (cost = {cost:.2f})")

    frontier = strategy.pareto_frontier(max_cost=30.0)
    print(f"\nPareto frontier ({len(frontier)} points):")
    for c, e in frontier[:10]:
        print(f"  cost = {c:.1f}, error = {e:.2e}")
