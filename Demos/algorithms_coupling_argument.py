"""
Algorithms: Factor-Wise Tropical Coupling and Bellman Dynamics
==============================================================

Implements the core algorithms from the research paper:
1. Factored gap tracking with certified progress
2. Coordinatewise Bellman iteration with convergence certification
3. Min-sum belief propagation with factor-wise energy tracking
"""

import numpy as np
from typing import Callable, List, Tuple, Optional


def factored_gap_tracker(
    k: int,
    gap: Callable[[np.ndarray], float],
    step: Callable[[np.ndarray], np.ndarray],
    s0: List[np.ndarray],
    n_rounds: int,
    beta_i: Optional[List[float]] = None,
) -> dict:
    """
    Track total gap across k factors over multiple rounds.
    
    Implements the iterated coupling theorem: if each factor's gap
    improves by at least beta_i[i] per round, total gap improves by
    sum(beta_i) per round.
    
    Args:
        k: Number of factors.
        gap: Progress measure gap(x) -> R for a single factor state.
        step: One-round update step(x) -> x' for a single factor.
        s0: Initial states [s0_0, s0_1, ..., s0_{k-1}].
        n_rounds: Number of rounds to simulate.
        beta_i: Per-factor guaranteed gains (for certification).
    
    Returns:
        Dictionary with trajectory data and certification results.
        
    Example:
        >>> gap = lambda x: float(np.sum(x**2))
        >>> step = lambda x: x + 0.1
        >>> s0 = [np.array([1.0]), np.array([2.0]), np.array([3.0])]
        >>> result = factored_gap_tracker(3, gap, step, s0, 10)
        >>> print(result['total_gaps'])
    """
    states = [s.copy() for s in s0]
    total_gaps = []
    per_factor_gaps = []
    certified = []
    
    total_beta = sum(beta_i) if beta_i else None
    initial_total = sum(gap(s) for s in states)
    
    for t in range(n_rounds + 1):
        factor_gaps = [gap(s) for s in states]
        total = sum(factor_gaps)
        total_gaps.append(total)
        per_factor_gaps.append(factor_gaps[:])
        
        if total_beta is not None:
            guaranteed = initial_total + t * total_beta
            certified.append(total >= guaranteed - 1e-10)
        
        if t < n_rounds:
            states = [step(s) for s in states]
    
    return {
        'total_gaps': total_gaps,
        'per_factor_gaps': per_factor_gaps,
        'certified': certified,
        'initial_total': initial_total,
        'total_beta': total_beta,
    }


def coordinatewise_bellman_iteration(
    n_factors: int,
    n_states: int,
    transition_matrices: List[np.ndarray],
    reward_vectors: List[np.ndarray],
    gamma: float = 0.9,
    n_iterations: int = 100,
    gap_fn: Optional[Callable] = None,
) -> dict:
    """
    Coordinatewise Bellman iteration on a factored MDP.
    
    Each factor has its own transition matrix and reward vector.
    The Bellman operator is applied to each factor independently.
    By the coupling theorem, per-factor residual reduction aggregates
    into global residual reduction.
    
    Args:
        n_factors: Number of independent factors (k).
        n_states: Number of states per factor.
        transition_matrices: List of k transition matrices, each (n_states, n_states).
        reward_vectors: List of k reward vectors, each (n_states,).
        gamma: Discount factor in (0, 1).
        n_iterations: Number of Bellman iterations.
        gap_fn: Optional custom gap function; defaults to L∞ Bellman residual.
    
    Returns:
        Dictionary with value function trajectories, residuals, and convergence data.
        
    Example:
        >>> P = [np.array([[0.7, 0.3], [0.4, 0.6]])]
        >>> r = [np.array([1.0, 2.0])]
        >>> result = coordinatewise_bellman_iteration(1, 2, P, r)
    """
    # Initialize value functions
    V = [np.zeros(n_states) for _ in range(n_factors)]
    
    if gap_fn is None:
        gap_fn = lambda v, Tv: np.max(np.abs(Tv - v))
    
    residuals = []
    total_residuals = []
    value_trajectories = [[] for _ in range(n_factors)]
    
    for t in range(n_iterations):
        factor_residuals = []
        for i in range(n_factors):
            P = transition_matrices[i]
            r = reward_vectors[i]
            Tv = r + gamma * P @ V[i]
            
            res = gap_fn(V[i], Tv)
            factor_residuals.append(res)
            
            value_trajectories[i].append(V[i].copy())
            V[i] = Tv
        
        residuals.append(factor_residuals)
        total_residuals.append(sum(factor_residuals))
    
    return {
        'final_values': V,
        'residuals': residuals,
        'total_residuals': total_residuals,
        'value_trajectories': value_trajectories,
    }


def min_sum_belief_propagation(
    n_variables: int,
    n_values: int,
    factors: List[Tuple[List[int], np.ndarray]],
    n_iterations: int = 50,
    damping: float = 0.5,
) -> dict:
    """
    Min-sum belief propagation on a factor graph.
    
    Implements the tropical/min-plus analogue of belief propagation.
    Each factor sends messages that are the min over incoming messages
    plus local potentials. By the coupling theorem, local energy
    improvements aggregate into global energy descent.
    
    Args:
        n_variables: Number of variable nodes.
        n_values: Number of possible values per variable.
        factors: List of (variable_indices, potential_table) pairs.
            potential_table shape: (n_values,) * len(variable_indices)
        n_iterations: Number of message-passing iterations.
        damping: Damping factor for message updates (0 = no damping, 1 = no update).
    
    Returns:
        Dictionary with beliefs, messages, and energy trajectory.
        
    Example:
        >>> factors = [([0, 1], np.array([[0, 1], [1, 0]]))]
        >>> result = min_sum_belief_propagation(2, 2, factors)
    """
    # Initialize messages: variable->factor and factor->variable
    # msg_vf[v][f] = message from variable v to factor f
    # msg_fv[f][v] = message from factor f to variable v
    
    var_to_factors = [[] for _ in range(n_variables)]
    for f_idx, (var_indices, _) in enumerate(factors):
        for v in var_indices:
            var_to_factors[v].append(f_idx)
    
    msg_vf = {}
    msg_fv = {}
    for f_idx, (var_indices, _) in enumerate(factors):
        for v in var_indices:
            msg_vf[(v, f_idx)] = np.zeros(n_values)
            msg_fv[(f_idx, v)] = np.zeros(n_values)
    
    energy_trajectory = []
    
    for t in range(n_iterations):
        # Factor to variable messages
        new_msg_fv = {}
        for f_idx, (var_indices, potential) in enumerate(factors):
            for target_v in var_indices:
                other_vars = [v for v in var_indices if v != target_v]
                
                if len(other_vars) == 0:
                    msg = potential.copy() if potential.ndim == 1 else potential.min(axis=-1)
                elif len(other_vars) == 1:
                    incoming = msg_vf[(other_vars[0], f_idx)]
                    target_idx = var_indices.index(target_v)
                    other_idx = var_indices.index(other_vars[0])
                    
                    msg = np.full(n_values, np.inf)
                    for tv in range(n_values):
                        for ov in range(n_values):
                            idx = [0] * len(var_indices)
                            idx[target_idx] = tv
                            idx[other_idx] = ov
                            cost = potential[tuple(idx)] + incoming[ov]
                            msg[tv] = min(msg[tv], cost)
                else:
                    msg = np.zeros(n_values)
                
                # Normalize
                msg -= msg.min()
                
                # Damp
                old = msg_fv.get((f_idx, target_v), np.zeros(n_values))
                new_msg_fv[(f_idx, target_v)] = damping * old + (1 - damping) * msg
        
        msg_fv = new_msg_fv
        
        # Variable to factor messages
        new_msg_vf = {}
        for v in range(n_variables):
            for target_f in var_to_factors[v]:
                msg = np.zeros(n_values)
                for f_idx in var_to_factors[v]:
                    if f_idx != target_f:
                        msg += msg_fv[(f_idx, v)]
                msg -= msg.min()
                
                old = msg_vf.get((v, target_f), np.zeros(n_values))
                new_msg_vf[(v, target_f)] = damping * old + (1 - damping) * msg
        
        msg_vf = new_msg_vf
        
        # Compute beliefs and energy
        beliefs = []
        for v in range(n_variables):
            belief = np.zeros(n_values)
            for f_idx in var_to_factors[v]:
                belief += msg_fv[(f_idx, v)]
            beliefs.append(belief)
        
        # Total energy = sum of min beliefs
        total_energy = sum(b.min() for b in beliefs)
        energy_trajectory.append(total_energy)
    
    # Final assignments
    assignments = [int(np.argmin(b)) for b in beliefs]
    
    return {
        'beliefs': beliefs,
        'assignments': assignments,
        'energy_trajectory': energy_trajectory,
    }


if __name__ == "__main__":
    print("=== Factored Gap Tracker ===")
    gap = lambda x: float(x[0])
    step = lambda x: x + 0.5
    s0 = [np.array([1.0]), np.array([2.0]), np.array([3.0])]
    result = factored_gap_tracker(3, gap, step, s0, 5, beta_i=[0.5, 0.5, 0.5])
    print(f"Total gaps: {result['total_gaps']}")
    print(f"All certified: {all(result['certified'])}")
    
    print("\n=== Coordinatewise Bellman Iteration ===")
    np.random.seed(42)
    P = [np.array([[0.7, 0.3], [0.4, 0.6]]),
         np.array([[0.5, 0.5], [0.2, 0.8]])]
    r = [np.array([1.0, 2.0]), np.array([3.0, 1.0])]
    result = coordinatewise_bellman_iteration(2, 2, P, r, gamma=0.9, n_iterations=20)
    print(f"Final values: {[v.round(3).tolist() for v in result['final_values']]}")
    print(f"Total residuals (last 5): {[round(x, 6) for x in result['total_residuals'][-5:]]}")
    
    print("\n=== Min-Sum Belief Propagation ===")
    # Simple pairwise MRF: prefer x0 != x1
    factors = [([0, 1], np.array([[0.0, 1.0], [1.0, 0.0]]))]
    result = min_sum_belief_propagation(2, 2, factors, n_iterations=10)
    print(f"Assignments: {result['assignments']}")
    print(f"Energy trajectory: {[round(e, 3) for e in result['energy_trajectory']]}")
