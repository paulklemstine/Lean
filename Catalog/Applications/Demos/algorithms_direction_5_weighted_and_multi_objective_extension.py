#!/usr/bin/env python3
"""
algorithms.py — Certified Multi-Criteria Hypergraph Transversal Algorithms

Implements:
  1. ThresholdRounder: The core threshold rounding operator
  2. WeightedTransversalLP: Weighted fractional transversal solver
  3. MultiObjectiveScalarizer: Pareto frontier exploration via scalarization
  4. SimultaneousApproximationCertifier: Verification of multi-objective bounds

All algorithms include docstrings, type hints, and example usage.
"""

from typing import List, Tuple, Set, Optional, Dict
import numpy as np
from scipy.optimize import linprog


class HypergraphInstance:
    """A finite hypergraph with optional vertex weights and multiple cost functions.

    Attributes:
        n: Number of vertices (vertices are 0..n-1)
        edges: List of edges, each edge is a tuple of vertex indices
        d_max: Maximum edge size
    """

    def __init__(self, n: int, edges: List[Tuple[int, ...]]):
        self.n = n
        self.edges = edges
        self.d_max = max((len(e) for e in edges), default=0)

    @classmethod
    def random(cls, n: int, m: int,
               edge_sizes: Tuple[int, ...] = (2, 3, 4),
               seed: Optional[int] = None) -> 'HypergraphInstance':
        """Generate a random hypergraph.

        Args:
            n: Number of vertices
            m: Number of edges to generate
            edge_sizes: Possible edge sizes
            seed: Random seed

        Returns:
            HypergraphInstance with random edges

        Example:
            >>> H = HypergraphInstance.random(10, 15, seed=42)
            >>> print(f"n={H.n}, m={len(H.edges)}, d_max={H.d_max}")
        """
        rng = np.random.default_rng(seed)
        edges_set = set()
        for _ in range(m):
            k = rng.choice(edge_sizes)
            e = tuple(sorted(rng.choice(n, size=min(k, n), replace=False)))
            edges_set.add(e)
        return cls(n, list(edges_set))

    def is_transversal(self, S: Set[int]) -> bool:
        """Check if S is a transversal (hits every edge)."""
        return all(any(v in S for v in e) for e in self.edges)


class ThresholdRounder:
    """The threshold rounding operator for fractional transversals.

    Given a fractional solution x : V -> R and a threshold θ = 1/d,
    produces the integral set S = {v : x(v) >= 1/d}.

    Mathematical guarantee (Theorem 1):
        If x is a feasible fractional transversal and d >= max edge size,
        then S is a transversal and for any nonneg cost w:
            sum_{v in S} w(v) <= d * sum_v w(v) * x(v)

    Time complexity: O(n) for rounding, O(n*m) for verification
    Space complexity: O(n)
    """

    def __init__(self, d: int):
        """
        Args:
            d: Threshold parameter (typically d_max of the hypergraph)
        """
        if d <= 0:
            raise ValueError("d must be positive")
        self.d = d
        self.threshold = 1.0 / d

    def round(self, x: np.ndarray) -> np.ndarray:
        """Apply threshold rounding.

        Args:
            x: Fractional solution, shape (n,)

        Returns:
            Boolean array indicating membership in S

        Example:
            >>> rounder = ThresholdRounder(d=3)
            >>> x = np.array([0.5, 0.2, 0.4, 0.1])
            >>> S = rounder.round(x)
            >>> print(S)  # [True, False, True, False]
        """
        return x >= self.threshold - 1e-12

    def round_indices(self, x: np.ndarray) -> np.ndarray:
        """Return indices of vertices in the rounded set."""
        return np.where(self.round(x))[0]

    def weighted_cost(self, x: np.ndarray, w: np.ndarray) -> float:
        """Compute weighted cost of the rounded set.

        Args:
            x: Fractional solution
            w: Vertex weights

        Returns:
            sum_{v in S} w(v)
        """
        S = self.round(x)
        return float(np.dot(w, S))

    def gap_ratio(self, x: np.ndarray, w: np.ndarray) -> float:
        """Compute the approximation gap ratio: cost(S) / (d * frac_cost).

        Returns:
            Ratio; should be <= 1.0 by the theorem
        """
        int_cost = self.weighted_cost(x, w)
        frac_cost = float(np.dot(w, x))
        if frac_cost < 1e-12:
            return 0.0
        return int_cost / (self.d * frac_cost)

    def verify_bound(self, x: np.ndarray, w: np.ndarray) -> Tuple[bool, float]:
        """Verify the weighted threshold cost bound.

        Returns:
            (bound_holds, gap_ratio)
        """
        ratio = self.gap_ratio(x, w)
        return ratio <= 1.0 + 1e-9, ratio


class WeightedTransversalLP:
    """Weighted fractional transversal LP solver.

    Solves: min sum_v w(v) * x(v)
            s.t. sum_{v in e} x(v) >= 1  for all e in H
                 x(v) >= 0

    Time complexity: O(poly(n, m)) via interior point methods
    Space complexity: O(n * m)
    """

    def __init__(self, H: HypergraphInstance):
        self.H = H

    def solve(self, w: np.ndarray) -> Tuple[Optional[np.ndarray], float]:
        """Solve the weighted fractional transversal LP.

        Args:
            w: Vertex cost function, shape (n,)

        Returns:
            (x_optimal, optimal_value) or (None, inf) if infeasible

        Example:
            >>> H = HypergraphInstance(4, [(0,1), (1,2), (2,3)])
            >>> solver = WeightedTransversalLP(H)
            >>> x, cost = solver.solve(np.ones(4))
            >>> print(f"Fractional cost: {cost:.4f}")
        """
        n = self.H.n
        c = w.copy()

        A_ub = []
        b_ub = []
        for e in self.H.edges:
            row = np.zeros(n)
            for v in e:
                row[v] = -1.0
            A_ub.append(row)
            b_ub.append(-1.0)

        if not A_ub:
            return np.zeros(n), 0.0

        bounds = [(0, None)] * n
        result = linprog(c, A_ub=A_ub, b_ub=b_ub, bounds=bounds, method='highs')

        if result.success:
            return result.x, result.fun
        return None, float('inf')


class MultiObjectiveScalarizer:
    """Multi-objective scalarization for hypergraph transversals.

    For k cost functions c_1, ..., c_k and weights lambda_1, ..., lambda_k >= 0:
        min sum_i lambda_i * (sum_v c_i(v) * x(v))
        s.t. x is a feasible fractional transversal

    Mathematical guarantee (Theorem 3):
        Any minimizer of a strictly positive scalarization is Pareto optimal.

    Time complexity: O(G * poly(n, m)) where G = number of grid points
    Space complexity: O(G * n + n * m)
    """

    def __init__(self, H: HypergraphInstance, costs: List[np.ndarray]):
        """
        Args:
            H: Hypergraph instance
            costs: List of k cost functions, each shape (n,)
        """
        self.H = H
        self.costs = costs
        self.k = len(costs)
        self.solver = WeightedTransversalLP(H)

    def scalarized_solve(self, weights: np.ndarray) -> Tuple[Optional[np.ndarray], np.ndarray]:
        """Solve for a single scalarization weight vector.

        Args:
            weights: Scalarization weights, shape (k,)

        Returns:
            (x_optimal, objective_values) where objective_values[i] = c_i^T x
        """
        w_combined = sum(weights[i] * self.costs[i] for i in range(self.k))
        x_opt, _ = self.solver.solve(w_combined)
        if x_opt is None:
            return None, np.full(self.k, np.inf)
        obj_vals = np.array([np.dot(c, x_opt) for c in self.costs])
        return x_opt, obj_vals

    def sweep_pareto_frontier(self, grid_size: int = 21
                              ) -> List[Dict]:
        """Sweep the Pareto frontier for bi-objective case.

        Args:
            grid_size: Number of lambda values in [0, 1]

        Returns:
            List of dicts with keys:
                'lambda': scalarization weight
                'frac_objectives': fractional objective values
                'int_objectives': integral (rounded) objective values
                'gap_ratios': approximation ratios per objective
        """
        if self.k != 2:
            raise ValueError("Pareto sweep only implemented for k=2")

        rounder = ThresholdRounder(self.H.d_max)
        results = []

        for lam in np.linspace(0.0, 1.0, grid_size):
            weights = np.array([lam, 1.0 - lam])
            x_opt, frac_obj = self.scalarized_solve(weights)
            if x_opt is None:
                continue

            S = rounder.round_indices(x_opt)
            indicator = np.zeros(self.H.n)
            indicator[S] = 1.0
            int_obj = np.array([np.dot(c, indicator) for c in self.costs])

            gap = np.where(frac_obj > 1e-10, int_obj / frac_obj, 0.0)

            results.append({
                'lambda': float(lam),
                'frac_objectives': frac_obj.tolist(),
                'int_objectives': int_obj.tolist(),
                'gap_ratios': gap.tolist(),
            })

        return results


class SimultaneousApproximationCertifier:
    """Certifies simultaneous multi-objective approximation bounds.

    Verifies Theorem 4: threshold rounding at 1/d simultaneously
    d-approximates every nonneg linear objective.

    Time complexity: O(k * n) per verification
    Space complexity: O(k * n)
    """

    def __init__(self, H: HypergraphInstance, d: Optional[int] = None):
        self.H = H
        self.d = d or H.d_max

    def certify(self, x: np.ndarray,
                costs: List[np.ndarray]) -> Dict:
        """Certify the simultaneous approximation bound.

        Args:
            x: Feasible fractional transversal
            costs: List of k nonneg cost functions

        Returns:
            Dict with certification results
        """
        rounder = ThresholdRounder(self.d)
        S = rounder.round_indices(x)

        is_trans = self.H.is_transversal(set(S))

        indicator = np.zeros(self.H.n)
        indicator[S] = 1.0

        results = {
            'is_transversal': is_trans,
            'd': self.d,
            'rounded_set_size': len(S),
            'objectives': []
        }

        all_certified = True
        for i, c in enumerate(costs):
            int_cost = float(np.dot(c, indicator))
            frac_cost = float(np.dot(c, x))
            bound = self.d * frac_cost
            certified = int_cost <= bound + 1e-9

            results['objectives'].append({
                'index': i,
                'integral_cost': int_cost,
                'fractional_cost': frac_cost,
                'bound': bound,
                'certified': certified,
                'ratio': int_cost / max(frac_cost, 1e-12)
            })

            if not certified:
                all_certified = False

        results['all_certified'] = all_certified and is_trans
        return results


# ── Example usage ──

if __name__ == "__main__":
    print("=" * 60)
    print("Algorithms.py — Example Usage")
    print("=" * 60)

    # Create a hypergraph
    H = HypergraphInstance.random(20, 15, seed=42)
    print(f"\nHypergraph: n={H.n}, m={len(H.edges)}, d_max={H.d_max}")

    # Solve weighted LP
    w = np.random.default_rng(42).uniform(0.5, 5.0, size=H.n)
    solver = WeightedTransversalLP(H)
    x_opt, frac_cost = solver.solve(w)
    print(f"Fractional optimal cost: {frac_cost:.4f}")

    # Threshold rounding
    rounder = ThresholdRounder(H.d_max)
    S = rounder.round_indices(x_opt)
    int_cost = rounder.weighted_cost(x_opt, w)
    print(f"Rounded set size: {len(S)}")
    print(f"Integral cost: {int_cost:.4f}")
    print(f"Gap ratio: {int_cost / frac_cost:.4f} (d_max = {H.d_max})")

    # Multi-objective
    rng = np.random.default_rng(123)
    costs = [rng.uniform(0.1, 5.0, size=H.n) for _ in range(2)]
    mscaler = MultiObjectiveScalarizer(H, costs)
    results = mscaler.sweep_pareto_frontier(grid_size=11)

    print(f"\nPareto sweep ({len(results)} points):")
    for r in results[:5]:
        print(f"  λ={r['lambda']:.2f}: frac={r['frac_objectives']}, "
              f"gaps={[f'{g:.3f}' for g in r['gap_ratios']]}")

    # Simultaneous certification
    certifier = SimultaneousApproximationCertifier(H)
    cert = certifier.certify(x_opt, costs)
    print(f"\nSimultaneous certification: {cert['all_certified']}")
    for obj in cert['objectives']:
        print(f"  Obj {obj['index']}: ratio={obj['ratio']:.4f}, "
              f"certified={obj['certified']}")
