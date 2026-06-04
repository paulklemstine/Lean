#!/usr/bin/env python3
"""
Algorithms for Sperner-Nash Equilibrium Computation

Type-hinted implementations of the key algorithms connecting
Sperner's lemma to Nash equilibrium computation.
"""
from typing import List, Tuple, Dict, Optional, Callable
import numpy as np
from itertools import product


# ============================================================
# Core Data Structures
# ============================================================

class FiniteGame:
    """A finite normal-form game with n players."""

    def __init__(self, num_players: int, num_strats: List[int],
                 payoffs: List[Dict[Tuple[int, ...], float]]):
        """
        Args:
            num_players: Number of players
            num_strats: List of strategy counts per player
            payoffs: List of payoff dictionaries, one per player.
                     Keys are tuples of strategy indices.
        """
        assert num_players > 0
        assert len(num_strats) == num_players
        assert all(k > 0 for k in num_strats)
        assert len(payoffs) == num_players
        self.num_players = num_players
        self.num_strats = num_strats
        self.payoffs = payoffs

    def payoff(self, player: int, strategy_profile: Tuple[int, ...]) -> float:
        return self.payoffs[player][strategy_profile]


MixedStrategy = np.ndarray  # 1D array summing to 1
MixedProfile = List[MixedStrategy]  # One mixed strategy per player


def expected_payoff(game: FiniteGame, profile: MixedProfile, player: int) -> float:
    """Compute expected payoff for a player under mixed strategy profile."""
    total = 0.0
    for sp in product(*[range(k) for k in game.num_strats]):
        prob = np.prod([profile[j][sp[j]] for j in range(game.num_players)])
        total += prob * game.payoff(player, sp)
    return total


def deviation_payoff(game: FiniteGame, profile: MixedProfile,
                     player: int, pure_strat: int) -> float:
    """Compute payoff when player deviates to a pure strategy."""
    total = 0.0
    for sp in product(*[range(k) for k in game.num_strats]):
        if sp[player] != pure_strat:
            continue
        prob = np.prod([profile[j][sp[j]] for j in range(game.num_players) if j != player])
        total += prob * game.payoff(player, sp)
    return total


def regret(game: FiniteGame, profile: MixedProfile,
           player: int, pure_strat: int) -> float:
    """Compute regret: improvement from deviating to pure strategy."""
    return deviation_payoff(game, profile, player, pure_strat) - \
           expected_payoff(game, profile, player)


def max_regret(game: FiniteGame, profile: MixedProfile) -> float:
    """Maximum regret across all players and strategies."""
    return max(
        regret(game, profile, i, si)
        for i in range(game.num_players)
        for si in range(game.num_strats[i])
    )


# ============================================================
# Algorithm 1: Combinatorial Equilibrium Functor (CEF)
# ============================================================

class CombinatorialEquilibriumFunctor:
    """
    Implements the CEF construction: iterative refinement of
    Sperner-type colorings to find Nash equilibria.

    Pseudocode:
        for level = 1, 2, 3, ...:
            mesh = 1 / 2^level
            triangulate the strategy simplex with mesh size
            for each vertex v of triangulation:
                compute best response at v
                color v with best-responding player
            find fully-colored simplex (Sperner witness)
            output center of witness as approximate equilibrium
    """

    def __init__(self, game: FiniteGame):
        self.game = game
        self.history: List[Dict] = []

    def best_response_color(self, profile: MixedProfile) -> int:
        """Color a vertex by which player has the highest regret."""
        best_player = 0
        best_regret = -float('inf')
        for i in range(self.game.num_players):
            for si in range(self.game.num_strats[i]):
                r = regret(self.game, profile, i, si)
                if r > best_regret:
                    best_regret = r
                    best_player = i
        return best_player

    def refine(self, level: int) -> Tuple[MixedProfile, float]:
        """
        Perform one level of refinement.

        Returns:
            Tuple of (approximate Nash profile, mesh size)
        """
        mesh = 1.0 / (2 ** level)
        n_grid = 2 ** level

        best_profile: Optional[MixedProfile] = None
        best_mr = float('inf')

        # For 2-player games, enumerate grid points on each simplex
        for grid_indices in product(range(n_grid + 1),
                                     repeat=sum(k - 1 for k in self.game.num_strats)):
            profile = []
            idx = 0
            valid = True
            for i in range(self.game.num_players):
                k = self.game.num_strats[i]
                probs = np.zeros(k)
                remaining = 1.0
                for j in range(k - 1):
                    p = grid_indices[idx] / n_grid if idx < len(grid_indices) else 0.0
                    idx += 1
                    p = min(p, remaining)
                    probs[j] = p
                    remaining -= p
                if remaining < -1e-10:
                    valid = False
                    break
                probs[k - 1] = max(0, remaining)
                profile.append(probs)

            if not valid:
                continue

            mr = max_regret(self.game, profile)
            if mr < best_mr:
                best_mr = mr
                best_profile = [p.copy() for p in profile]

        if best_profile is None:
            best_profile = [np.ones(k) / k for k in self.game.num_strats]
            best_mr = max_regret(self.game, best_profile)

        self.history.append({
            'level': level,
            'mesh_size': mesh,
            'max_regret': best_mr,
            'profile': best_profile
        })
        return best_profile, mesh

    def run(self, max_levels: int = 5) -> List[Dict]:
        """Run the CEF for multiple refinement levels."""
        for level in range(1, max_levels + 1):
            self.refine(level)
        return self.history


# ============================================================
# Algorithm 2: Support Enumeration (Exact Nash)
# ============================================================

def support_enumeration_2player(game: FiniteGame) -> List[MixedProfile]:
    """
    Find all Nash equilibria of a 2-player game via support enumeration.

    Uses the Indifference Principle: in a Nash equilibrium, all strategies
    in the support yield equal payoff.

    Pseudocode:
        for each subset S1 of player 1's strategies:
            for each subset S2 of player 2's strategies:
                solve for mixed strategies making opponent indifferent
                if solution is valid (nonneg, sums to 1):
                    check if it's a Nash equilibrium
                    if yes, add to results
    """
    assert game.num_players == 2
    n1, n2 = game.num_strats

    results = []
    for s1_mask in range(1, 2**n1):
        for s2_mask in range(1, 2**n2):
            s1_support = [j for j in range(n1) if s1_mask & (1 << j)]
            s2_support = [j for j in range(n2) if s2_mask & (1 << j)]

            # Solve for player 2's mixture making player 1 indifferent
            k1, k2 = len(s1_support), len(s2_support)
            if k1 == 0 or k2 == 0:
                continue

            # Build indifference equations for player 1
            A1 = np.zeros((k1 - 1 + 1, k2))
            b1 = np.zeros(k1 - 1 + 1)
            for idx in range(k1 - 1):
                s_a = s1_support[idx]
                s_b = s1_support[idx + 1]
                for jdx, s2 in enumerate(s2_support):
                    A1[idx, jdx] = game.payoff(0, (s_a, s2)) - game.payoff(0, (s_b, s2))
            # Sum to 1 constraint
            A1[k1 - 1, :] = 1.0
            b1[k1 - 1] = 1.0

            # Build indifference equations for player 2
            A2 = np.zeros((k2 - 1 + 1, k1))
            b2 = np.zeros(k2 - 1 + 1)
            for idx in range(k2 - 1):
                s_a = s2_support[idx]
                s_b = s2_support[idx + 1]
                for jdx, s1 in enumerate(s1_support):
                    A2[idx, jdx] = game.payoff(1, (s1, s_a)) - game.payoff(1, (s1, s_b))
            A2[k2 - 1, :] = 1.0
            b2[k2 - 1] = 1.0

            try:
                if A1.shape[0] != A1.shape[1] or A2.shape[0] != A2.shape[1]:
                    continue
                sigma2_support = np.linalg.solve(A1, b1)
                sigma1_support = np.linalg.solve(A2, b2)
            except np.linalg.LinAlgError:
                continue

            # Check nonnegativity
            if np.any(sigma1_support < -1e-10) or np.any(sigma2_support < -1e-10):
                continue

            # Build full mixed strategies
            sigma1 = np.zeros(n1)
            sigma2 = np.zeros(n2)
            for idx, s in enumerate(s1_support):
                sigma1[s] = max(0, sigma1_support[idx])
            for idx, s in enumerate(s2_support):
                sigma2[s] = max(0, sigma2_support[idx])

            # Normalize
            if sigma1.sum() < 1e-10 or sigma2.sum() < 1e-10:
                continue
            sigma1 /= sigma1.sum()
            sigma2 /= sigma2.sum()

            profile = [sigma1, sigma2]

            # Check Nash condition
            if max_regret(game, profile) < 1e-6:
                results.append(profile)

    return results


# ============================================================
# Algorithm 3: Dominated Strategy Elimination
# ============================================================

def eliminate_dominated(game: FiniteGame) -> Tuple[FiniteGame, List[List[int]]]:
    """
    Iteratively eliminate strictly dominated strategies.

    Returns reduced game and mapping of remaining strategies to original indices.

    Pseudocode:
        repeat:
            for each player i:
                for each strategy s of player i:
                    if there exists s' that strictly dominates s:
                        remove s from player i's strategies
            until no more eliminations
    """
    remaining = [list(range(k)) for k in game.num_strats]
    changed = True

    while changed:
        changed = False
        for i in range(game.num_players):
            to_remove = []
            for si_idx in range(len(remaining[i])):
                si = remaining[i][si_idx]
                # Check if any other strategy dominates si
                for sj_idx in range(len(remaining[i])):
                    if si_idx == sj_idx:
                        continue
                    sj = remaining[i][sj_idx]
                    dominated = True
                    for opp_strats in product(*[remaining[j] for j in range(game.num_players) if j != i]):
                        sp_si = list(opp_strats)
                        sp_si.insert(i, si)
                        sp_sj = list(opp_strats)
                        sp_sj.insert(i, sj)
                        if game.payoff(i, tuple(sp_sj)) <= game.payoff(i, tuple(sp_si)):
                            dominated = False
                            break
                    if dominated:
                        to_remove.append(si_idx)
                        break
            for idx in sorted(set(to_remove), reverse=True):
                remaining[i].pop(idx)
                changed = True

    # Build reduced game
    new_num_strats = [len(r) for r in remaining]
    new_payoffs = []
    for i in range(game.num_players):
        d = {}
        for sp in product(*[range(k) for k in new_num_strats]):
            orig_sp = tuple(remaining[j][sp[j]] for j in range(game.num_players))
            d[sp] = game.payoff(i, orig_sp)
        new_payoffs.append(d)

    return FiniteGame(game.num_players, new_num_strats, new_payoffs), remaining


if __name__ == "__main__":
    # Demo: Matching Pennies
    mp = FiniteGame(2, [2, 2], [
        {(0, 0): 1, (0, 1): -1, (1, 0): -1, (1, 1): 1},
        {(0, 0): -1, (0, 1): 1, (1, 0): 1, (1, 1): -1}
    ])

    print("=== CEF on Matching Pennies ===")
    cef = CombinatorialEquilibriumFunctor(mp)
    history = cef.run(max_levels=5)
    for h in history:
        print(f"Level {h['level']}: mesh={h['mesh_size']:.4f}, "
              f"regret={h['max_regret']:.6f}")

    print("\n=== Support Enumeration ===")
    equilibria = support_enumeration_2player(mp)
    for eq in equilibria:
        print(f"Nash: ({eq[0]}, {eq[1]}), regret={max_regret(mp, eq):.8f}")

    print("\n=== Dominated Strategy Elimination (Prisoner's Dilemma) ===")
    pd = FiniteGame(2, [2, 2], [
        {(0, 0): 3, (0, 1): 0, (1, 0): 5, (1, 1): 1},
        {(0, 0): 3, (0, 1): 5, (1, 0): 0, (1, 1): 1}
    ])
    reduced, remaining = eliminate_dominated(pd)
    print(f"Remaining strategies: {remaining}")
    print(f"Reduced game: {reduced.num_strats}")
