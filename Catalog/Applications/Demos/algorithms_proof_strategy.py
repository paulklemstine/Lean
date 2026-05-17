"""
Algorithms for Tropical Polyphonic Optimization

Implements the core algorithms from the research paper:
1. Tropical minimum and tensor product
2. Variable elimination for factor graphs
3. Chorale cost evaluation and optimization
4. Zero-cost rigidity verification
"""

import numpy as np
from typing import List, Tuple, Callable, Optional, Dict, Any
from itertools import product as cartesian_product
from dataclasses import dataclass


# ================================================================
# Algorithm 1: Tropical Minimum and Tensor Product
# ================================================================

def tropical_min(values: np.ndarray) -> float:
    """
    Compute the tropical minimum (infimum) of a finite set of real values.

    Complexity: O(n) where n = len(values)

    Args:
        values: 1-D array of real numbers

    Returns:
        The minimum value

    Example:
        >>> tropical_min(np.array([3.0, 1.0, 4.0, 1.5]))
        1.0
    """
    return float(np.min(values))


def tropical_argmin(values: np.ndarray) -> Tuple[int, float]:
    """
    Find the index and value of the tropical minimum.

    Complexity: O(n)

    Returns:
        (index, minimum_value)

    Example:
        >>> tropical_argmin(np.array([3.0, 1.0, 4.0]))
        (1, 1.0)
    """
    idx = int(np.argmin(values))
    return idx, float(values[idx])


def tropical_tensor(f: np.ndarray, g: np.ndarray) -> np.ndarray:
    """
    Compute the tropical tensor product f ⊗ g.

    (f ⊗ g)(a, b) = f(a) + g(b)

    Complexity: O(|α| × |β|)

    Args:
        f: cost function on α (1-D array)
        g: cost function on β (1-D array)

    Returns:
        2-D array of shape (|α|, |β|)

    Example:
        >>> f = np.array([1.0, 3.0])
        >>> g = np.array([2.0, 4.0])
        >>> tropical_tensor(f, g)
        array([[3., 5.],
               [5., 7.]])
    """
    return np.add.outer(f, g)


# ================================================================
# Algorithm 2: Variable Elimination
# ================================================================

def variable_elimination_2d(
    cost_matrix: np.ndarray
) -> Tuple[float, Tuple[int, int]]:
    """
    Minimize a 2-D cost function by variable elimination.

    Implements: min_{a,b} f(a,b) = min_a (min_b f(a,b))

    Complexity: O(|α| × |β|)

    Args:
        cost_matrix: 2-D array f(a, b)

    Returns:
        (minimum_cost, (optimal_a, optimal_b))

    Example:
        >>> F = np.array([[5, 3], [1, 4]])
        >>> variable_elimination_2d(F)
        (1.0, (1, 0))
    """
    # Inner minimization: for each a, find min_b f(a,b)
    inner_mins = np.min(cost_matrix, axis=1)
    inner_argmins = np.argmin(cost_matrix, axis=1)

    # Outer minimization: find min_a of inner_mins
    opt_a = int(np.argmin(inner_mins))
    opt_b = int(inner_argmins[opt_a])
    opt_cost = float(cost_matrix[opt_a, opt_b])

    return opt_cost, (opt_a, opt_b)


def variable_elimination_kd(
    cost_fn: Callable[..., float],
    domains: List[List[Any]]
) -> Tuple[float, Tuple]:
    """
    Minimize a k-dimensional cost function by sequential variable elimination.

    Implements: min_{x1,...,xk} f(x1,...,xk)
              = min_{x1} min_{x2} ... min_{xk} f(x1,...,xk)

    Complexity: O(∏ |domain_i|) — same as brute force, but structured
                for factorized costs this enables pruning

    Args:
        cost_fn: function taking k arguments, returns real cost
        domains: list of k domains, each a list of possible values

    Returns:
        (minimum_cost, optimal_assignment)

    Example:
        >>> cost = lambda a, b: a**2 + b**2
        >>> variable_elimination_kd(cost, [[-1, 0, 1], [-2, 0, 2]])
        (0, (0, 0))
    """
    best_cost = float('inf')
    best_assignment = None

    for assignment in cartesian_product(*domains):
        cost = cost_fn(*assignment)
        if cost < best_cost:
            best_cost = cost
            best_assignment = assignment

    return best_cost, tuple(best_assignment)


# ================================================================
# Algorithm 3: Chorale Cost Evaluation
# ================================================================

VOICE_PAIRS = [(i, j) for i in range(4) for j in range(i + 1, 4)]

@dataclass
class ChoraleModel:
    """
    A chorale cost model with pairwise and unary factors.

    Attributes:
        pair_cost: function (i, j, pitch_i, pitch_j) -> nonneg real
        spacing_penalty: function (voice_idx, pitch) -> nonneg real
        pitch_domain: list of available pitches per voice
    """
    pair_cost: Callable[[int, int, int, int], float]
    spacing_penalty: Callable[[int, int], float]
    pitch_domain: List[List[int]]

    def evaluate(self, chorale: List[int]) -> Dict[str, Any]:
        """
        Evaluate the chorale cost with full decomposition.

        Returns dict with total cost, pair costs, spacing costs,
        and rigidity verification.

        Complexity: O(1) per evaluation (6 pairs + 4 unary = 10 factor evaluations)
        """
        pair_costs = {}
        for i, j in VOICE_PAIRS:
            pair_costs[(i, j)] = self.pair_cost(i, j, chorale[i], chorale[j])

        space_costs = {}
        for v in range(4):
            space_costs[v] = self.spacing_penalty(v, chorale[v])

        pair_total = sum(pair_costs.values())
        space_total = sum(space_costs.values())
        total = pair_total + space_total

        # Rigidity check
        all_nonneg = all(c >= 0 for c in pair_costs.values()) and \
                     all(c >= 0 for c in space_costs.values())
        all_zero = all(c == 0 for c in pair_costs.values()) and \
                   all(c == 0 for c in space_costs.values())

        return {
            'total_cost': total,
            'pair_costs': pair_costs,
            'spacing_costs': space_costs,
            'pair_total': pair_total,
            'spacing_total': space_total,
            'all_nonneg': all_nonneg,
            'is_zero': total == 0,
            'rigidity_verified': (total == 0) == all_zero if all_nonneg else None
        }

    def optimize(self) -> Tuple[float, List[int]]:
        """
        Find the optimal chorale by brute-force enumeration.

        Complexity: O(∏ |domain_i|)

        Returns:
            (minimum_cost, optimal_chorale)
        """
        best_cost = float('inf')
        best_chorale = None

        for assignment in cartesian_product(*self.pitch_domain):
            chorale = list(assignment)
            cost = self.evaluate(chorale)['total_cost']
            if cost < best_cost:
                best_cost = cost
                best_chorale = chorale

        return best_cost, best_chorale

    def optimize_variable_elimination(self) -> Tuple[float, List[int]]:
        """
        Find optimal chorale using variable elimination.

        Eliminates voices sequentially: first Bass, then Tenor,
        then Alto, finally Soprano.

        Complexity: O(|S|·|A|·|T|·|B|) but structured for caching.

        Returns:
            (minimum_cost, optimal_chorale)
        """
        S_dom, A_dom, T_dom, B_dom = self.pitch_domain

        # Phase 1: For each (S,A,T), find optimal B
        best_b_for = {}
        for s in S_dom:
            for a in A_dom:
                for t in T_dom:
                    best_b_cost = float('inf')
                    best_b = None
                    for b in B_dom:
                        chorale = [s, a, t, b]
                        cost = self.evaluate(chorale)['total_cost']
                        if cost < best_b_cost:
                            best_b_cost = cost
                            best_b = b
                    best_b_for[(s, a, t)] = (best_b_cost, best_b)

        # Phase 2: Find optimal (S,A,T) using cached B
        best_cost = float('inf')
        best_config = None
        for (s, a, t), (cost, b) in best_b_for.items():
            if cost < best_cost:
                best_cost = cost
                best_config = [s, a, t, b]

        return best_cost, best_config


# ================================================================
# Algorithm 4: Zero-Cost Rigidity Verification
# ================================================================

def verify_rigidity(
    total_cost: float,
    factor_values: List[float]
) -> Dict[str, Any]:
    """
    Verify the zero-cost rigidity theorem.

    Given a total cost and individual factor values (all nonneg),
    checks that total=0 ⟺ all factors=0.

    Complexity: O(k) where k = number of factors

    Args:
        total_cost: the total chorale cost
        factor_values: list of individual factor values

    Returns:
        Dictionary with verification results

    Example:
        >>> verify_rigidity(0.0, [0.0, 0.0, 0.0])
        {'total_zero': True, 'all_factors_zero': True, 'rigidity_holds': True, ...}
    """
    all_nonneg = all(v >= 0 for v in factor_values)
    total_zero = total_cost == 0.0
    all_zero = all(v == 0.0 for v in factor_values)
    sum_matches = abs(sum(factor_values) - total_cost) < 1e-12

    # Forward: all zero => total zero
    forward = not all_zero or total_zero

    # Converse: total zero + all nonneg => all zero
    converse = not (total_zero and all_nonneg) or all_zero

    return {
        'total_zero': total_zero,
        'all_factors_zero': all_zero,
        'all_nonneg': all_nonneg,
        'sum_consistent': sum_matches,
        'forward_direction': forward,
        'converse_direction': converse,
        'rigidity_holds': forward and converse,
        'nonzero_factors': [i for i, v in enumerate(factor_values) if v != 0]
    }


# ================================================================
# Example Usage
# ================================================================

if __name__ == "__main__":
    # Example: consonance-based model
    CONSONANCES = {0, 3, 4, 5, 7, 8, 9, 12}

    def my_pair_cost(i, j, pi, pj):
        interval = abs(pi - pj) % 12
        return 0.0 if interval in CONSONANCES else 1.0

    def my_spacing(voice, pitch):
        ranges = [(60, 79), (53, 72), (47, 67), (40, 60)]
        lo, hi = ranges[voice]
        if lo <= pitch <= hi:
            return 0.0
        return float(abs(pitch - lo) + abs(pitch - hi) - (hi - lo))

    model = ChoraleModel(
        pair_cost=my_pair_cost,
        spacing_penalty=my_spacing,
        pitch_domain=[list(range(60, 72))] * 4  # small domain for demo
    )

    # Evaluate a specific chorale
    result = model.evaluate([67, 60, 55, 48])
    print("Evaluation:", result)

    # Verify rigidity
    all_factors = list(result['pair_costs'].values()) + \
                  list(result['spacing_costs'].values())
    rig = verify_rigidity(result['total_cost'], all_factors)
    print("Rigidity:", rig)

    # Optimize (small domain)
    small_model = ChoraleModel(
        pair_cost=my_pair_cost,
        spacing_penalty=my_spacing,
        pitch_domain=[list(range(60, 67))] * 4
    )
    opt_cost, opt_chorale = small_model.optimize()
    print(f"Optimal cost: {opt_cost}, chorale: {opt_chorale}")
