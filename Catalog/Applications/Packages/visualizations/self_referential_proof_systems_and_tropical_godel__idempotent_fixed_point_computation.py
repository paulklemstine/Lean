#!/usr/bin/env python3
"""
Tropical Metamathematics: Algorithms

Implements the core algorithms from the tropical metamathematics research,
including tropical fixed-point computation, closure operator iteration,
diagonal sentence detection, and incompleteness verification.
"""

import numpy as np
from typing import Callable, Optional, Tuple, List, Dict
from dataclasses import dataclass

INF = float('inf')
TropicalState = np.ndarray


@dataclass
class TropicalProofSystem:
    """
    A tropical proof system on n sentences.
    
    Attributes:
        n: Number of sentences
        evaluator: Monotone idempotent map Φ: R^n → R^n
        name: Human-readable name
    """
    n: int
    evaluator: Callable[[TropicalState], TropicalState]
    name: str = "unnamed"
    
    def is_fixed_point(self, x: TropicalState, tol: float = 1e-10) -> bool:
        """Check if x is a fixed point of the evaluator."""
        return np.allclose(self.evaluator(x), x, atol=tol)
    
    def find_fixed_point(self, x0: Optional[TropicalState] = None, 
                         max_iter: int = 1000) -> TropicalState:
        """
        Find a fixed point by iterating the evaluator.
        
        For idempotent operators, Φ(x) is already a fixed point for any x.
        For non-idempotent monotone operators, we iterate until convergence.
        
        Args:
            x0: Starting point (default: zero vector)
            max_iter: Maximum iterations
            
        Returns:
            Fixed point x such that Φ(x) = x
        """
        if x0 is None:
            x0 = np.zeros(self.n)
        
        x = x0.copy()
        for _ in range(max_iter):
            x_new = self.evaluator(x)
            if np.allclose(x_new, x):
                return x_new
            x = x_new
        
        return x
    
    def verify_idempotency(self, num_samples: int = 100) -> bool:
        """Verify idempotency on random samples."""
        for _ in range(num_samples):
            x = np.random.uniform(0, 10, self.n)
            fx = self.evaluator(x)
            ffx = self.evaluator(fx)
            if not np.allclose(fx, ffx):
                return False
        return True
    
    def verify_monotonicity(self, num_samples: int = 100) -> bool:
        """Verify monotonicity on random sample pairs."""
        for _ in range(num_samples):
            x = np.random.uniform(0, 10, self.n)
            y = x + np.random.uniform(0, 5, self.n)  # y ≥ x
            fx = self.evaluator(x)
            fy = self.evaluator(y)
            if not np.all(fx <= fy + 1e-10):
                return False
        return True


def find_tropical_fixed_point_idempotent(
    phi: Callable[[TropicalState], TropicalState],
    n: int,
    x0: Optional[TropicalState] = None
) -> TropicalState:
    """
    Algorithm 1: Fixed-Point Computation for Idempotent Operators
    
    For an idempotent operator Φ (where Φ(Φ(x)) = Φ(x)), the image of any
    point is a fixed point. This is O(n) — a single application of Φ.
    
    Complexity: O(T_Φ) where T_Φ is the cost of one Φ evaluation.
    
    Args:
        phi: Idempotent operator
        n: Dimension
        x0: Starting point (default: zero vector)
        
    Returns:
        Fixed point x with Φ(x) = x
    """
    if x0 is None:
        x0 = np.zeros(n)
    return phi(x0)


def find_tropical_fixed_point_monotone(
    phi: Callable[[TropicalState], TropicalState],
    n: int,
    upper_bound: Optional[TropicalState] = None,
    max_iter: int = 10000
) -> Tuple[TropicalState, int]:
    """
    Algorithm 2: Fixed-Point Computation for Monotone Bounded Operators
    
    Uses Kleene iteration: start from the upper bound and iterate downward.
    Convergence is guaranteed for bounded monotone operators on finite lattices.
    
    Complexity: O(B · T_Φ) where B is the max bound value (for integer-valued
    operators) and T_Φ is the evaluation cost.
    
    Args:
        phi: Monotone operator
        n: Dimension
        upper_bound: Componentwise upper bound
        max_iter: Maximum iterations
        
    Returns:
        (fixed_point, num_iterations)
    """
    if upper_bound is None:
        upper_bound = np.full(n, 100.0)
    
    x = upper_bound.copy()
    for i in range(max_iter):
        x_new = phi(x)
        if np.allclose(x_new, x):
            return x_new, i + 1
        x = x_new
    
    return x, max_iter


def check_diagonal_incompleteness(
    system: TropicalProofSystem,
    diag_index: int,
    provability_threshold: float = 0.0
) -> Dict[str, object]:
    """
    Algorithm 3: Diagonal Incompleteness Check
    
    Given a tropical proof system and a diagonal index, determines whether
    the system is sound, complete, or neither at that coordinate.
    
    The diagonal sentence at index i has truth defined as:
        Truth(x, i) ↔ ¬ Provable(x, i)
    where Provable(x, i) ↔ (x[i] ≤ threshold).
    
    Complexity: O(T_Φ) — one fixed-point computation plus constant work.
    
    Args:
        system: Tropical proof system
        diag_index: Index of the diagonal (Gödel) sentence
        provability_threshold: Score at or below which a sentence is "provable"
        
    Returns:
        Dictionary with analysis results
    """
    # Find a fixed point
    fp = system.find_fixed_point()
    
    # Check provability at the diagonal coordinate
    provable = fp[diag_index] <= provability_threshold
    
    # Diagonal truth: true iff not provable
    true_at_diag = not provable
    
    # Soundness: Provable → True (can only fail if provable and not true)
    sound = not provable or true_at_diag
    
    # Completeness: True → Provable (can only fail if true and not provable)
    complete = not true_at_diag or provable
    
    return {
        'fixed_point': fp,
        'diag_index': diag_index,
        'fp_value_at_diag': fp[diag_index],
        'provable': provable,
        'true': true_at_diag,
        'sound': sound,
        'complete': complete,
        'both_sound_and_complete': sound and complete,
        'status': 'UNSOUND' if not sound else ('INCOMPLETE' if not complete else 'IMPOSSIBLE')
    }


def closure_operator_analysis(
    closure: Callable[[TropicalState], TropicalState],
    n: int
) -> Dict[str, object]:
    """
    Algorithm 4: Closure Operator Self-Reference Analysis
    
    Analyzes a closure operator for:
    1. Extensivity (x ≤ c(x))
    2. Monotonicity
    3. Idempotency
    4. Fixed-point structure
    5. Self-referential coordinates
    
    Complexity: O(S · T_c) where S is the number of verification samples.
    
    Args:
        closure: The closure operator c: R^n → R^n
        n: Dimension
        
    Returns:
        Analysis results
    """
    results: Dict[str, object] = {}
    num_samples = 100
    
    # Check extensivity
    extensive = True
    for _ in range(num_samples):
        x = np.random.uniform(-5, 10, n)
        cx = closure(x)
        if not np.all(x <= cx + 1e-10):
            extensive = False
            break
    results['extensive'] = extensive
    
    # Check monotonicity
    monotone = True
    for _ in range(num_samples):
        x = np.random.uniform(0, 10, n)
        y = x + np.random.uniform(0, 5, n)
        if not np.all(closure(x) <= closure(y) + 1e-10):
            monotone = False
            break
    results['monotone'] = monotone
    
    # Check idempotency
    idempotent = True
    for _ in range(num_samples):
        x = np.random.uniform(0, 10, n)
        cx = closure(x)
        ccx = closure(cx)
        if not np.allclose(cx, ccx):
            idempotent = False
            break
    results['idempotent'] = idempotent
    
    # Find fixed points
    fp_from_zero = closure(np.zeros(n))
    fp_from_large = closure(np.full(n, 100.0))
    results['fixed_point_from_zero'] = fp_from_zero
    results['fixed_point_from_large'] = fp_from_large
    results['unique_fixed_point_image'] = np.allclose(fp_from_zero, fp_from_large)
    
    # Self-referential coordinates: where fp[i] == c(fp)[i]
    # (always true at fixed points, but we verify)
    cfp = closure(fp_from_zero)
    self_ref_coords = [i for i in range(n) if np.isclose(fp_from_zero[i], cfp[i])]
    results['self_referential_coordinates'] = self_ref_coords
    results['is_closure_operator'] = extensive and monotone and idempotent
    
    return results


def tropical_bellman_iteration(
    transition_costs: np.ndarray,
    terminal_costs: TropicalState,
    max_iter: int = 100
) -> Tuple[TropicalState, int]:
    """
    Algorithm 5: Tropical Bellman Iteration
    
    Computes the optimal cost-to-go via min-plus matrix iteration.
    This is the canonical example of a tropical fixed-point computation
    that arises in dynamic programming / shortest paths.
    
    The Bellman operator is: T(v)[i] = min_j (c[i,j] + v[j])
    
    Complexity: O(n² · K) where K is the number of iterations to convergence.
    
    Args:
        transition_costs: n×n matrix of transition costs
        terminal_costs: n-vector of terminal costs
        max_iter: Maximum iterations
        
    Returns:
        (optimal_value, num_iterations)
    """
    n = len(terminal_costs)
    v = terminal_costs.copy()
    
    for k in range(max_iter):
        v_new = np.array([
            min(transition_costs[i, j] + v[j] for j in range(n))
            for i in range(n)
        ])
        
        if np.allclose(v_new, v):
            return v_new, k + 1
        v = v_new
    
    return v, max_iter


# Example usage and testing
if __name__ == "__main__":
    print("Tropical Metamathematics: Algorithm Demonstrations")
    print("=" * 60)
    
    # Create a sample proof system
    n = 5
    ceiling = np.array([2.0, 1.0, 3.0, 0.5, 2.0])
    
    system = TropicalProofSystem(
        n=n,
        evaluator=lambda x: np.minimum(x, ceiling),
        name="Ceiling System"
    )
    
    print(f"\n--- Algorithm 1: Idempotent Fixed Point ---")
    fp = find_tropical_fixed_point_idempotent(system.evaluator, n)
    print(f"Fixed point: {fp}")
    print(f"Verified: {system.is_fixed_point(fp)}")
    
    print(f"\n--- Algorithm 3: Diagonal Incompleteness Check ---")
    for diag_idx in range(n):
        result = check_diagonal_incompleteness(system, diag_idx)
        print(f"  Index {diag_idx}: value={result['fp_value_at_diag']:.1f}, "
              f"provable={result['provable']}, status={result['status']}")
    
    print(f"\n--- Algorithm 4: Closure Operator Analysis ---")
    floor_vals = np.array([1.0, 0.0, 0.5, 0.0, 1.0])
    closure = lambda x: np.maximum(x, floor_vals)
    analysis = closure_operator_analysis(closure, n)
    print(f"  Is closure operator: {analysis['is_closure_operator']}")
    print(f"  Fixed point: {analysis['fixed_point_from_zero']}")
    print(f"  Self-ref coordinates: {analysis['self_referential_coordinates']}")
    
    print(f"\n--- Algorithm 5: Tropical Bellman Iteration ---")
    costs = np.array([
        [0, 1, 3, INF],
        [INF, 0, 1, 2],
        [2, INF, 0, 1],
        [1, 3, INF, 0],
    ], dtype=float)
    terminal = np.array([0.0, 0.0, 0.0, 0.0])
    optimal, iters = tropical_bellman_iteration(costs, terminal)
    print(f"  Optimal costs: {optimal}")
    print(f"  Converged in {iters} iterations")
