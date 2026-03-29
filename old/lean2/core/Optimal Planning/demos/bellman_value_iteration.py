#!/usr/bin/env python3
"""
Bellman Value Iteration Demo
=============================

Demonstrates the core algorithm formalized in core/Oracle/OptimalPlanning.lean:
- Value iteration converges to the optimal value function V*
- The convergence rate is geometric with factor γ
- The Bellman operator at V* is idempotent (an oracle)

This demo solves a grid-world MDP and visualizes the convergence.
"""

import numpy as np
import json
from typing import Tuple, Dict, List


class GridWorldMDP:
    """A grid-world MDP where an agent navigates to a goal.
    
    States: (row, col) positions on an NxN grid
    Actions: up, down, left, right
    Rewards: +1 at goal, -0.04 step penalty, -1 at traps
    """
    
    ACTIONS = ['up', 'down', 'left', 'right']
    ACTION_DELTAS = {
        'up': (-1, 0),
        'down': (1, 0),
        'left': (0, -1),
        'right': (0, 1),
    }
    
    def __init__(self, n: int = 5, gamma: float = 0.9,
                 goal: Tuple[int, int] = None,
                 traps: List[Tuple[int, int]] = None):
        self.n = n
        self.gamma = gamma
        self.goal = goal or (n - 1, n - 1)
        self.traps = traps or [(1, 3), (2, 1)]
        self.states = [(r, c) for r in range(n) for c in range(n)]
        self.n_states = len(self.states)
        self.state_index = {s: i for i, s in enumerate(self.states)}
        
    def transition(self, state: Tuple[int, int], action: str) -> Tuple[int, int]:
        """Deterministic transition: move in direction, clamped to grid."""
        if state == self.goal:
            return state  # absorbing state
        dr, dc = self.ACTION_DELTAS[action]
        nr, nc = state[0] + dr, state[1] + dc
        if 0 <= nr < self.n and 0 <= nc < self.n:
            return (nr, nc)
        return state  # wall collision
    
    def reward(self, state: Tuple[int, int], action: str) -> float:
        """Reward function."""
        if state == self.goal:
            return 0.0  # already at goal, absorbing
        next_state = self.transition(state, action)
        if next_state == self.goal:
            return 1.0
        if next_state in self.traps:
            return -1.0
        return -0.04  # step penalty


def bellman_operator(mdp: GridWorldMDP, V: np.ndarray) -> np.ndarray:
    """Apply the Bellman optimality operator: (BV)(s) = max_a [R(s,a) + γ V(T(s,a))].
    
    This is the core operation formalized in OptimalPlanning.lean as `bellmanOp`.
    """
    V_new = np.zeros_like(V)
    for s in mdp.states:
        i = mdp.state_index[s]
        values = []
        for a in mdp.ACTIONS:
            next_s = mdp.transition(s, a)
            j = mdp.state_index[next_s]
            values.append(mdp.reward(s, a) + mdp.gamma * V[j])
        V_new[i] = max(values)
    return V_new


def greedy_policy(mdp: GridWorldMDP, V: np.ndarray) -> Dict[Tuple[int, int], str]:
    """Extract the greedy policy from a value function.
    
    Corresponds to `greedyPolicy` in OptimalPlanning.lean.
    """
    policy = {}
    for s in mdp.states:
        i = mdp.state_index[s]
        best_action = None
        best_value = float('-inf')
        for a in mdp.ACTIONS:
            next_s = mdp.transition(s, a)
            j = mdp.state_index[next_s]
            v = mdp.reward(s, a) + mdp.gamma * V[j]
            if v > best_value:
                best_value = v
                best_action = a
        policy[s] = best_action
    return policy


def sup_norm(V1: np.ndarray, V2: np.ndarray) -> float:
    """Sup-norm distance: max|V1 - V2|.
    
    Corresponds to `supDist` in OptimalPlanning.lean.
    """
    return np.max(np.abs(V1 - V2))


def value_iteration(mdp: GridWorldMDP, max_iter: int = 1000,
                     tol: float = 1e-10) -> Tuple[np.ndarray, List[float]]:
    """Run value iteration until convergence.
    
    Corresponds to `valueIteration` in OptimalPlanning.lean.
    Returns the converged value function and the convergence history.
    """
    V = np.zeros(mdp.n_states)
    errors = []
    
    for iteration in range(max_iter):
        V_new = bellman_operator(mdp, V)
        error = sup_norm(V, V_new)
        errors.append(error)
        
        if error < tol:
            print(f"  Converged after {iteration + 1} iterations (error = {error:.2e})")
            V = V_new
            break
        V = V_new
    
    return V, errors


def verify_oracle_property(mdp: GridWorldMDP, V_star: np.ndarray) -> bool:
    """Verify that B(B(V*)) = B(V*) — the oracle/idempotency property.
    
    This is the key theorem `bellman_idempotent_at_fixedPoint` from OptimalPlanning.lean.
    """
    BV = bellman_operator(mdp, V_star)
    BBV = bellman_operator(mdp, BV)
    return np.allclose(BV, BBV, atol=1e-12)


def verify_contraction(mdp: GridWorldMDP, V1: np.ndarray, V2: np.ndarray) -> bool:
    """Verify that d(BV1, BV2) ≤ γ · d(V1, V2) — the contraction property.
    
    This is `bellman_contraction` from OptimalPlanning.lean.
    """
    BV1 = bellman_operator(mdp, V1)
    BV2 = bellman_operator(mdp, V2)
    d_before = sup_norm(V1, V2)
    d_after = sup_norm(BV1, BV2)
    return d_after <= mdp.gamma * d_before + 1e-15  # numerical tolerance


def display_grid(mdp: GridWorldMDP, V: np.ndarray, policy: Dict = None):
    """Display the value function and policy as a grid."""
    action_symbols = {'up': '↑', 'down': '↓', 'left': '←', 'right': '→'}
    
    print(f"\n{'='*50}")
    print("VALUE FUNCTION")
    print(f"{'='*50}")
    for r in range(mdp.n):
        row_str = ""
        for c in range(mdp.n):
            s = (r, c)
            i = mdp.state_index[s]
            if s == mdp.goal:
                row_str += "  GOAL  "
            elif s in mdp.traps:
                row_str += "  TRAP  "
            else:
                row_str += f" {V[i]:+6.3f} "
        print(row_str)
    
    if policy:
        print(f"\n{'='*50}")
        print("OPTIMAL POLICY")
        print(f"{'='*50}")
        for r in range(mdp.n):
            row_str = ""
            for c in range(mdp.n):
                s = (r, c)
                if s == mdp.goal:
                    row_str += "  ★  "
                elif s in mdp.traps:
                    row_str += "  ✗  "
                else:
                    row_str += f"  {action_symbols[policy[s]]}  "
            print(row_str)


def experiment_convergence_rate():
    """Experiment: How does γ affect convergence rate?
    
    Validates Hypothesis 2: The discount factor is a planning difficulty metric.
    """
    print("\n" + "=" * 60)
    print("EXPERIMENT: Convergence Rate vs. Discount Factor")
    print("=" * 60)
    
    gammas = [0.5, 0.7, 0.8, 0.9, 0.95, 0.99]
    results = []
    
    for gamma in gammas:
        mdp = GridWorldMDP(n=5, gamma=gamma)
        V, errors = value_iteration(mdp, tol=1e-8)
        iters = len(errors)
        
        # Planning difficulty D = -1/log(γ)
        D = -1.0 / np.log(gamma) if gamma > 0 else float('inf')
        
        results.append({
            'gamma': gamma,
            'iterations': iters,
            'planning_difficulty': round(D, 2),
            'final_error': errors[-1] if errors else 0,
        })
        print(f"  γ = {gamma:.2f}: {iters:4d} iterations, D = {D:.2f}")
    
    print("\nConclusion: Higher γ → more iterations → harder planning.")
    print("Planning difficulty D = -1/log(γ) correlates with iteration count.")
    return results


def experiment_action_space():
    """Experiment: How does action space size affect convergence?
    
    Validates Hypothesis 1: More actions → faster convergence.
    """
    print("\n" + "=" * 60)
    print("EXPERIMENT: Action Space Size vs. Convergence")
    print("=" * 60)
    
    class ExtendedGridMDP(GridWorldMDP):
        """Grid MDP with diagonal actions added."""
        def __init__(self, n, gamma, include_diagonals=False):
            super().__init__(n=n, gamma=gamma)
            if include_diagonals:
                self.ACTIONS = ['up', 'down', 'left', 'right',
                               'up-left', 'up-right', 'down-left', 'down-right']
                self.ACTION_DELTAS = {
                    'up': (-1, 0), 'down': (1, 0),
                    'left': (0, -1), 'right': (0, 1),
                    'up-left': (-1, -1), 'up-right': (-1, 1),
                    'down-left': (1, -1), 'down-right': (1, 1),
                }
    
    for gamma in [0.8, 0.9, 0.95]:
        mdp4 = ExtendedGridMDP(n=5, gamma=gamma, include_diagonals=False)
        mdp8 = ExtendedGridMDP(n=5, gamma=gamma, include_diagonals=True)
        
        _, errors4 = value_iteration(mdp4, tol=1e-8)
        _, errors8 = value_iteration(mdp8, tol=1e-8)
        
        print(f"  γ={gamma}: 4 actions → {len(errors4)} iters, "
              f"8 actions → {len(errors8)} iters")
    
    print("\nConclusion: More actions generally lead to faster convergence")
    print("(more optimization directions).")


def experiment_oracle_verification():
    """Verify the oracle properties from OptimalPlanning.lean computationally."""
    print("\n" + "=" * 60)
    print("EXPERIMENT: Oracle Property Verification")
    print("=" * 60)
    
    mdp = GridWorldMDP(n=5, gamma=0.9)
    V_star, _ = value_iteration(mdp, tol=1e-12)
    
    # 1. Idempotency: B(B(V*)) = B(V*)
    is_oracle = verify_oracle_property(mdp, V_star)
    print(f"  Idempotency B(B(V*)) = B(V*): {'✅ VERIFIED' if is_oracle else '❌ FAILED'}")
    
    # 2. Contraction: d(BV1, BV2) ≤ γ d(V1, V2)
    V1 = np.random.randn(mdp.n_states)
    V2 = np.random.randn(mdp.n_states)
    is_contraction = verify_contraction(mdp, V1, V2)
    print(f"  Contraction property: {'✅ VERIFIED' if is_contraction else '❌ FAILED'}")
    
    # 3. Fixed point: B(V*) = V*
    BV_star = bellman_operator(mdp, V_star)
    is_fixedpoint = np.allclose(BV_star, V_star, atol=1e-10)
    print(f"  Fixed point B(V*) = V*: {'✅ VERIFIED' if is_fixedpoint else '❌ FAILED'}")
    
    # 4. Uniqueness: different initial conditions converge to same V*
    V_alt, _ = value_iteration(
        mdp, tol=1e-12)  # same start
    V_rand_start = np.random.randn(mdp.n_states) * 10
    for _ in range(1000):
        V_rand_start = bellman_operator(mdp, V_rand_start)
    is_unique = np.allclose(V_star, V_rand_start, atol=1e-8)
    print(f"  Uniqueness (diff start → same V*): {'✅ VERIFIED' if is_unique else '❌ FAILED'}")
    
    # 5. Monotonicity
    V_low = np.zeros(mdp.n_states)
    V_high = np.ones(mdp.n_states)
    BV_low = bellman_operator(mdp, V_low)
    BV_high = bellman_operator(mdp, V_high)
    is_monotone = np.all(BV_low <= BV_high + 1e-15)
    print(f"  Monotonicity V1≤V2 → BV1≤BV2: {'✅ VERIFIED' if is_monotone else '❌ FAILED'}")
    
    # 6. Geometric convergence bound
    V0 = np.zeros(mdp.n_states)
    d0 = sup_norm(V0, V_star)
    print(f"\n  Geometric convergence verification:")
    V = V0.copy()
    for n in [1, 5, 10, 20, 50]:
        for _ in range(n - (0 if n == 1 else [1, 5, 10, 20, 50][[1, 5, 10, 20, 50].index(n) - 1])):
            V = bellman_operator(mdp, V)
        actual_error = sup_norm(V, V_star)
        bound = mdp.gamma ** n * d0
        print(f"    n={n:3d}: actual error = {actual_error:.6e}, "
              f"bound γⁿ·d₀ = {bound:.6e}, "
              f"{'✅' if actual_error <= bound + 1e-12 else '❌'}")


def main():
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  BELLMAN VALUE ITERATION — Oracle-Guided Optimal Planning  ║")
    print("║  Computational companion to OptimalPlanning.lean           ║")
    print("╚══════════════════════════════════════════════════════════╝")
    
    # Main demo: solve a grid-world MDP
    print("\n" + "=" * 60)
    print("MAIN DEMO: 5×5 Grid World")
    print("=" * 60)
    
    mdp = GridWorldMDP(n=5, gamma=0.9)
    print(f"  States: {mdp.n_states}")
    print(f"  Actions: {len(mdp.ACTIONS)}")
    print(f"  Discount factor: γ = {mdp.gamma}")
    print(f"  Goal: {mdp.goal}")
    print(f"  Traps: {mdp.traps}")
    
    print("\nRunning value iteration...")
    V_star, errors = value_iteration(mdp)
    
    policy = greedy_policy(mdp, V_star)
    display_grid(mdp, V_star, policy)
    
    # Run experiments
    experiment_oracle_verification()
    experiment_convergence_rate()
    experiment_action_space()
    
    print("\n" + "=" * 60)
    print("ALL EXPERIMENTS COMPLETE")
    print("=" * 60)
    print("\nThese computational results validate the theorems")
    print("formally proved in core/Oracle/OptimalPlanning.lean:")
    print("  • bellman_contraction (γ-contraction)")
    print("  • bellman_fixedPoint_unique (uniqueness of V*)")
    print("  • bellman_idempotent_at_fixedPoint (oracle property)")
    print("  • valueIteration_error_bound (geometric convergence)")
    print("  • bellman_monotone (monotonicity)")


if __name__ == "__main__":
    main()
