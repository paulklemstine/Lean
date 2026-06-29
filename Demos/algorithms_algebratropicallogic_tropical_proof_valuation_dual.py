#!/usr/bin/env python3
"""
Algorithms for Tropical Proof-Valuation Duality

Implements the core algorithms from the research paper:
1. Bellman iteration for computing minimal derivation costs
2. Witness reconstruction for extracting optimal derivation trees
3. Consequence operator evaluation
"""

from dataclasses import dataclass, field
from typing import Optional

INF = float('inf')


@dataclass
class WeightedRule:
    """A weighted inference rule."""
    premises: list[int]
    conclusion: int
    weight: int


@dataclass
class WeightedProofSystem:
    """A weighted proof system."""
    num_props: int
    rules: list[WeightedRule]
    axioms: set[int]


@dataclass
class DerivationNode:
    """A node in a derivation tree."""
    proposition: int
    cost: int
    is_axiom: bool
    rule: Optional[WeightedRule] = None
    children: list['DerivationNode'] = field(default_factory=list)

    def size(self) -> int:
        """Number of nodes in this derivation tree."""
        return 1 + sum(c.size() for c in self.children)

    def depth(self) -> int:
        """Depth of this derivation tree."""
        if not self.children:
            return 0
        return 1 + max(c.depth() for c in self.children)


def consequence_operator(
    system: WeightedProofSystem,
    valuation: list[float]
) -> list[float]:
    """
    Evaluate the consequence operator T(f).

    T(f)(q) = min(axiomCost(q), min over rules r concluding q of ruleCost(f, r))

    Time complexity: O(sum of premise counts across all rules)
    Space complexity: O(|P|)
    """
    result = [0.0 if q in system.axioms else INF
              for q in range(system.num_props)]
    for rule in system.rules:
        premise_cost = sum(valuation[p] for p in rule.premises)
        if premise_cost == INF:
            continue
        total = rule.weight + premise_cost
        result[rule.conclusion] = min(result[rule.conclusion], total)
    return result


def compute_min_deriv_cost(
    system: WeightedProofSystem,
    max_iterations: int = 10000
) -> tuple[list[float], int]:
    """
    Compute minDerivCost by Bellman iteration from ⊤.

    Returns (optimal_valuation, num_iterations).

    Correctness: Guaranteed by tropical_proof_valuation_duality theorem.
    Convergence: For n propositions, stabilizes in at most n+1 iterations
                 (each iteration makes at least one new proposition reachable).

    Time complexity: O(n * m * k) where n = |P|, m = |rules|, k = max premises
    Space complexity: O(n)
    """
    f = [INF] * system.num_props
    for i in range(max_iterations):
        f_new = consequence_operator(system, f)
        if f_new == f:
            return f, i + 1
        f = f_new
    return f, max_iterations


def reconstruct_optimal_derivation(
    system: WeightedProofSystem,
    valuation: list[float],
    target: int
) -> Optional[DerivationNode]:
    """
    Reconstruct an optimal derivation tree from the fixed-point valuation.

    Correctness: Guaranteed by exists_optimal_derivation theorem.

    Time complexity: O(tree_size * m) where m = |rules|
    Space complexity: O(tree_size)
    """
    if valuation[target] == INF:
        return None

    if target in system.axioms:
        return DerivationNode(proposition=target, cost=0, is_axiom=True)

    for rule in system.rules:
        if rule.conclusion != target:
            continue
        premise_cost = sum(valuation[p] for p in rule.premises)
        total = rule.weight + premise_cost
        if abs(total - valuation[target]) < 1e-9:
            children = []
            valid = True
            for p in rule.premises:
                child = reconstruct_optimal_derivation(system, valuation, p)
                if child is None:
                    valid = False
                    break
                children.append(child)
            if valid:
                return DerivationNode(
                    proposition=target,
                    cost=int(valuation[target]),
                    is_axiom=False,
                    rule=rule,
                    children=children
                )
    return None


def is_fixed_point(system: WeightedProofSystem, f: list[float]) -> bool:
    """Check if f is a fixed point of the consequence operator."""
    f_new = consequence_operator(system, f)
    return all(
        (a == INF and b == INF) or abs(a - b) < 1e-9
        for a, b in zip(f, f_new)
    )


def derivable_propositions(
    system: WeightedProofSystem,
    valuation: list[float]
) -> set[int]:
    """Return the set of derivable propositions (those with finite cost)."""
    return {q for q in range(system.num_props) if valuation[q] < INF}


# ============================================================
# Example usage
# ============================================================

if __name__ == "__main__":
    # Example from the Lean formalization
    system = WeightedProofSystem(
        num_props=3,
        rules=[
            WeightedRule(premises=[0], conclusion=1, weight=3),
            WeightedRule(premises=[0, 1], conclusion=2, weight=2),
        ],
        axioms={0}
    )

    print("Computing minDerivCost...")
    valuation, iters = compute_min_deriv_cost(system)
    print(f"  Converged in {iters} iterations")
    print(f"  Valuation: {valuation}")
    print(f"  Is fixed point: {is_fixed_point(system, valuation)}")
    print(f"  Derivable: {derivable_propositions(system, valuation)}")

    print("\nOptimal derivation trees:")
    for q in range(system.num_props):
        tree = reconstruct_optimal_derivation(system, valuation, q)
        if tree:
            print(f"  P{q}: cost={tree.cost}, size={tree.size()}, depth={tree.depth()}")
