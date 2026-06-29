#!/usr/bin/env python3
"""
Algorithms for Tropical Convexity and Mean-Payoff Game Reduction
================================================================

Implements the core algorithms from the formal development:
1. Tropical convex hull membership (certified)
2. Shapley operator iteration for tropical feasibility
3. Mean-payoff game construction from tropical LP instances
4. Policy iteration for mean-payoff games

All algorithms include complexity analysis and docstrings matching
the formal Lean 4 definitions.
"""

import numpy as np
from typing import Optional, Tuple, List, Dict


# ============================================================================
# Algorithm 1: Tropical Convex Hull Membership
# ============================================================================

def tropical_hull_membership(
    generators: np.ndarray,
    x: np.ndarray,
    tol: float = 1e-9
) -> Tuple[bool, Optional[np.ndarray]]:
    """
    Decide membership in the tropical convex hull of a finite generator set.
    
    Given generators v_1, ..., v_m ∈ ℝ^n, check whether x ∈ tconv(v_1,...,v_m),
    i.e., whether there exist c_1, ..., c_m ∈ ℝ such that
        x_i = max_j (c_j + v_{j,i})  for all i ∈ {0,...,n-1}.
    
    Algorithm:
        For each generator j, the maximum feasible coefficient is
            c_j^* = min_i (x_i - v_{j,i})
        because c_j + v_{j,i} ≤ x_i must hold for all i where j is not the maximizer.
        We set c_j = c_j^* and verify max_j(c_j + v_{j,i}) = x_i for all i.
    
    Complexity: O(m * n)
    
    Args:
        generators: (m, n) array of generator points
        x: (n,) target point
        tol: numerical tolerance
    
    Returns:
        (is_member, coefficients): membership flag and optimal coefficients if member
    """
    m, n = generators.shape
    assert x.shape == (n,), f"Point dimension {x.shape} doesn't match generators {(n,)}"
    
    if m == 0:
        return False, None
    
    # Compute optimal coefficients: c_j = min_i(x_i - v_{j,i})
    c = np.min(x[np.newaxis, :] - generators, axis=1)  # shape (m,)
    
    # Reconstruct: hull_i = max_j(c_j + v_{j,i})
    shifted = c[:, np.newaxis] + generators  # shape (m, n)
    hull_point = np.max(shifted, axis=0)     # shape (n,)
    
    if np.allclose(hull_point, x, atol=tol):
        return True, c
    return False, None


def tropical_hull_support(
    generators: np.ndarray,
    x: np.ndarray,
    tol: float = 1e-9
) -> Tuple[bool, Optional[np.ndarray], Optional[set]]:
    """
    Compute membership and active support of a tropical hull point.
    
    The active support is the set of generator indices j such that
    c_j + v_{j,i} = x_i for at least one coordinate i.
    
    Related to the Tropical Carathéodory conjecture: is |support| ≤ n+1?
    
    Complexity: O(m * n)
    """
    is_member, c = tropical_hull_membership(generators, x, tol)
    if not is_member:
        return False, None, None
    
    m, n = generators.shape
    active = set()
    for i in range(n):
        vals = c + generators[:, i]
        max_val = np.max(vals)
        for j in range(m):
            if abs(vals[j] - max_val) < tol:
                active.add(j)
    
    return True, c, active


# ============================================================================
# Algorithm 2: Shapley Operator and Tropical Feasibility
# ============================================================================

def shapley_operator(
    A: np.ndarray,
    B: np.ndarray,
    x: np.ndarray
) -> np.ndarray:
    """
    Compute the Shapley operator T(x) for a tropical inequality system.
    
    Definition (matching Lean formalization):
        T(x)_i = min_j (max_k (B_{j,k} + x_k) - A_{j,i})
    
    Properties (formally verified):
        - Monotone: x ≤ y ⟹ T(x) ≤ T(y)
        - Additively homogeneous: T(x + c·1) = T(x) + c·1
    
    The sub-fixed-point condition x ≤ T(x) is equivalent to feasibility
    of the tropical halfspace system (tropical_feasibility_iff_subfixed_point).
    
    Complexity: O(p * n) per evaluation
    
    Args:
        A: (p, n) left-hand side coefficient matrix
        B: (p, n) right-hand side coefficient matrix
        x: (n,) current point
    
    Returns:
        T(x): (n,) Shapley operator value
    """
    p, n = A.shape
    
    # sup_k (B_{j,k} + x_k) for each j
    Bx = np.max(B + x[np.newaxis, :], axis=1)  # shape (p,)
    
    # T(x)_i = min_j (Bx_j - A_{j,i})
    # For each i, compute min over j of (Bx_j - A_{j,i})
    result = np.min(Bx[:, np.newaxis] - A, axis=0)  # shape (n,)
    
    return result


def tropical_feasibility_shapley(
    A: np.ndarray,
    B: np.ndarray,
    x0: Optional[np.ndarray] = None,
    max_iter: int = 1000,
    tol: float = 1e-10,
    step_size: float = 0.5
) -> Tuple[Optional[np.ndarray], bool, int, List[np.ndarray]]:
    """
    Solve tropical feasibility via Shapley operator iteration.
    
    Finds x such that x ≤ T(x), which by the formally verified theorem
    `tropical_feasibility_iff_subfixed_point` is equivalent to feasibility
    of max_i(A_{j,i} + x_i) ≤ max_i(B_{j,i} + x_i) for all j.
    
    Algorithm (Krasnoselskii-Mann iteration):
        x_{k+1} = (1-α) x_k + α T(x_k)
    where α ∈ (0,1) is the step size.
    
    Complexity: O(p * n * max_iter) worst case
    
    Args:
        A, B: (p, n) coefficient matrices
        x0: initial point (default: zero vector)
        max_iter: maximum iterations
        tol: convergence tolerance
        step_size: damping parameter α
    
    Returns:
        (solution, converged, iterations, trajectory)
    """
    p, n = A.shape
    if x0 is None:
        x0 = np.zeros(n)
    
    x = x0.copy()
    trajectory = [x.copy()]
    
    for it in range(max_iter):
        Tx = shapley_operator(A, B, x)
        
        # Check sub-fixed-point condition
        if np.all(x <= Tx + tol):
            return x, True, it, trajectory
        
        # Krasnoselskii-Mann update
        x = (1 - step_size) * x + step_size * Tx
        trajectory.append(x.copy())
    
    # Check final point
    Tx = shapley_operator(A, B, x)
    if np.all(x <= Tx + tol):
        return x, True, max_iter, trajectory
    
    return None, False, max_iter, trajectory


def verify_tropical_feasibility(
    A: np.ndarray,
    B: np.ndarray,
    x: np.ndarray,
    tol: float = 1e-9
) -> Tuple[bool, Optional[int]]:
    """
    Verify that x satisfies the tropical halfspace system.
    
    Checks: ∀ j, max_i(A_{j,i} + x_i) ≤ max_i(B_{j,i} + x_i)
    
    Returns: (feasible, first_violated_constraint_index)
    """
    p, n = A.shape
    for j in range(p):
        lhs = np.max(A[j] + x)
        rhs = np.max(B[j] + x)
        if lhs > rhs + tol:
            return False, j
    return True, None


# ============================================================================
# Algorithm 3: Mean-Payoff Game Construction
# ============================================================================

class MeanPayoffGame:
    """
    Mean-payoff game constructed from a tropical LP instance.
    
    Matches the formal Lean definition:
        structure MeanPayoffGame where
          numVerts : ℕ
          isMaxVertex : Fin numVerts → Bool
          numEdges : ℕ
          edgeSrc, edgeTgt : Fin numEdges → Fin numVerts
          edgeWeight : Fin numEdges → ℝ
          hasOutEdge : ∀ v, ∃ e, edgeSrc e = v
    """
    
    def __init__(self, num_verts: int, is_max_vertex: List[bool],
                 edges: List[Tuple[int, int, float]]):
        self.num_verts = num_verts
        self.is_max_vertex = is_max_vertex
        self.edges = edges  # List of (src, tgt, weight)
    
    def check_potential(self, pot: np.ndarray, tol: float = 1e-9) -> bool:
        """
        Check if potential certifies nonneg game value.
        
        HasNonnegValue: ∃ pot, ∀ e, w(e) + pot(tgt) ≥ pot(src) ∨ isMax(src)
        """
        for src, tgt, w in self.edges:
            if not self.is_max_vertex[src]:
                if w + pot[tgt] < pot[src] - tol:
                    return False
        return True
    
    def describe(self) -> str:
        """Human-readable description of the game."""
        lines = [f"Mean-Payoff Game: {self.num_verts} vertices, {len(self.edges)} edges"]
        for v in range(self.num_verts):
            player = "Max" if self.is_max_vertex[v] else "Min"
            lines.append(f"  Vertex {v}: {player}")
        for src, tgt, w in self.edges:
            lines.append(f"  Edge {src} → {tgt}, weight {w:.3f}")
        return "\n".join(lines)


def tropical_to_game(A: np.ndarray, B: np.ndarray) -> MeanPayoffGame:
    """
    Reduce tropical feasibility to a mean-payoff game.
    
    Construction (matching formal theorem `tropical_feasibility_reduces_to_mean_payoff`):
    - n Max vertices (variables x_0, ..., x_{n-1})
    - p Min vertices (constraints C_0, ..., C_{p-1})
    - Edges Max(i) → Min(j) with weight -A_{j,i}
    - Edges Min(j) → Max(k) with weight B_{j,k}
    
    The game has nonneg value ⟺ the tropical system is feasible.
    
    Complexity: O(n*p) edges
    """
    p, n = A.shape
    
    is_max = [True] * n + [False] * p
    edges = []
    
    # Max → Min edges
    for i in range(n):
        for j in range(p):
            edges.append((i, n + j, -A[j][i]))
    
    # Min → Max edges
    for j in range(p):
        for k in range(n):
            edges.append((n + j, k, B[j][k]))
    
    return MeanPayoffGame(n + p, is_max, edges)


def potential_from_feasible_point(
    A: np.ndarray, B: np.ndarray, x: np.ndarray
) -> np.ndarray:
    """
    Construct a game potential from a feasible point of the tropical system.
    
    If x satisfies max_i(A_{j,i} + x_i) ≤ max_i(B_{j,i} + x_i) for all j,
    then the potential pot with:
        pot(Max(i)) = x_i
        pot(Min(j)) = max_i(A_{j,i} + x_i)
    certifies nonneg game value.
    """
    p, n = A.shape
    pot = np.zeros(n + p)
    pot[:n] = x
    for j in range(p):
        pot[n + j] = np.max(A[j] + x)
    return pot


# ============================================================================
# Algorithm 4: Policy Iteration for Mean-Payoff Games
# ============================================================================

def policy_iteration_mean_payoff(
    game: MeanPayoffGame,
    max_iter: int = 100
) -> Tuple[Optional[np.ndarray], bool, int]:
    """
    Policy iteration for mean-payoff games (simplified version).
    
    This implements the standard policy iteration algorithm:
    1. Start with an arbitrary Min strategy (choose one outgoing edge per Min vertex)
    2. Solve the resulting linear system for the potential
    3. Improve the strategy by switching edges where beneficial
    4. Repeat until stable
    
    Complexity: O(|V| * |E|) per iteration, at most O(|E|^|V_Min|) iterations
    (but empirically polynomial).
    
    Returns: (potential, has_nonneg_value, iterations)
    """
    n_verts = game.num_verts
    
    # Build adjacency lists
    out_edges = [[] for _ in range(n_verts)]
    for idx, (src, tgt, w) in enumerate(game.edges):
        out_edges[src].append((idx, tgt, w))
    
    # Initialize Min strategy: pick first outgoing edge for each Min vertex
    min_strategy = {}
    for v in range(n_verts):
        if not game.is_max_vertex[v] and out_edges[v]:
            min_strategy[v] = out_edges[v][0]
    
    for iteration in range(max_iter):
        # Under current Min strategy, try to find a potential
        # For Min vertices, the chosen edge gives: w + pot(tgt) ≥ pot(src)
        # For Max vertices, at least one edge must satisfy it
        
        # Simple approach: set all potentials to 0 and check
        pot = np.zeros(n_verts)
        
        # Iterate value updates
        for _ in range(n_verts * 10):
            new_pot = pot.copy()
            for v in range(n_verts):
                if game.is_max_vertex[v]:
                    # Max vertex: take max over outgoing edges
                    if out_edges[v]:
                        new_pot[v] = max(w + pot[tgt] for _, tgt, w in out_edges[v])
                else:
                    # Min vertex: use strategy edge
                    if v in min_strategy:
                        _, tgt, w = min_strategy[v]
                        new_pot[v] = w + pot[tgt]
            
            # Normalize (subtract mean to prevent drift)
            new_pot -= np.mean(new_pot)
            if np.allclose(pot, new_pot, atol=1e-12):
                break
            pot = new_pot
        
        # Try to improve Min strategy
        improved = False
        for v in range(n_verts):
            if not game.is_max_vertex[v]:
                current_val = pot[v]
                best_val = current_val
                best_edge = min_strategy.get(v)
                for edge_data in out_edges[v]:
                    _, tgt, w = edge_data
                    val = w + pot[tgt]
                    if val < best_val - 1e-10:
                        best_val = val
                        best_edge = edge_data
                        improved = True
                if best_edge is not None:
                    min_strategy[v] = best_edge
        
        if not improved:
            return pot, game.check_potential(pot), iteration
    
    return pot, game.check_potential(pot), max_iter


# ============================================================================
# Example Usage
# ============================================================================

if __name__ == "__main__":
    print("Tropical Convexity Algorithms")
    print("=" * 50)
    
    # Example 1: Hull membership
    gens = np.array([[0, 0], [3, 1], [1, 4]], dtype=float)
    x = np.array([1.5, 2.0])
    member, coeff = tropical_hull_membership(gens, x)
    print(f"\nHull membership: {member}")
    if coeff is not None:
        print(f"Coefficients: {coeff}")
    
    # Example 2: Feasibility
    A = np.array([[2.0, 0.0], [0.0, 1.0]])
    B = np.array([[0.0, 3.0], [2.0, 0.0]])
    sol, converged, iters, _ = tropical_feasibility_shapley(A, B)
    print(f"\nFeasibility: converged={converged}, iterations={iters}")
    if sol is not None:
        print(f"Solution: {sol}")
        feasible, _ = verify_tropical_feasibility(A, B, sol)
        print(f"Verified: {feasible}")
    
    # Example 3: Game reduction
    game = tropical_to_game(A, B)
    print(f"\n{game.describe()}")
    pot, has_val, iters = policy_iteration_mean_payoff(game)
    print(f"Policy iteration: nonneg_value={has_val}, iterations={iters}")
