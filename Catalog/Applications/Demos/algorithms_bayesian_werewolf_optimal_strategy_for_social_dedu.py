#!/usr/bin/env python3
"""
Algorithms for Bayesian Werewolf game analysis.

Provides:
  1. Exact win probability computation (memoized recursion)
  2. Monte Carlo simulation for validation
  3. Bayesian posterior update for social deduction
  4. Game tree analysis for optimal strategy computation
"""
from fractions import Fraction
from functools import lru_cache
from typing import List, Tuple, Dict, Optional
import random


# ============================================================
# Algorithm 1: Exact Win Probability (Dynamic Programming)
# ============================================================

@lru_cache(maxsize=None)
def random_win_prob(v: int, w: int) -> Fraction:
    """Compute exact villager win probability under random elimination.
    
    Uses the recursion:
        P(v, 0) = 1
        P(v, w) = 0                           if v ≤ w + 1
        P(v, w) = (w/(v+w-1)) * P(v-1, w-1) 
                + ((v-1)/(v+w-1)) * P(v-2, w)  otherwise
    
    Args:
        v: Number of remaining villagers (≥ 0)
        w: Number of remaining werewolves (≥ 0)
    
    Returns:
        Exact rational probability as a Fraction
    
    Complexity: O(v * w) time and space with memoization.
    """
    if w == 0:
        return Fraction(1)
    if v <= w + 1:
        return Fraction(0)
    total = v + w - 1
    return (Fraction(w, total) * random_win_prob(v - 1, w - 1) +
            Fraction(v - 1, total) * random_win_prob(v - 2, w))


def random_win_prob_table(max_v: int, max_w: int) -> Dict[Tuple[int, int], Fraction]:
    """Compute win probability for all (v, w) up to given bounds.
    
    Args:
        max_v: Maximum number of villagers
        max_w: Maximum number of werewolves
    
    Returns:
        Dictionary mapping (v, w) to exact win probability
    """
    table: Dict[Tuple[int, int], Fraction] = {}
    for w in range(max_w + 1):
        for v in range(max_v + 1):
            table[(v, w)] = random_win_prob(v, w)
    return table


# ============================================================
# Algorithm 2: Monte Carlo Simulation
# ============================================================

def simulate_game(v: int, w: int) -> bool:
    """Simulate a single game with random elimination.
    
    Args:
        v: Initial number of villagers
        w: Initial number of werewolves
    
    Returns:
        True if villagers win, False if werewolves win
    """
    cv, cw = v, w
    while cw > 0:
        # Night phase: werewolves kill one villager
        cv -= 1
        # Check werewolf victory
        if cw >= cv:
            return False
        # Day phase: random elimination
        total = cv + cw
        if random.random() < cw / total:
            cw -= 1  # Werewolf caught
        else:
            cv -= 1  # Villager lost
    return True  # All werewolves eliminated


def monte_carlo_win_prob(v: int, w: int, num_trials: int = 100000) -> float:
    """Estimate win probability by Monte Carlo simulation.
    
    Args:
        v: Number of villagers
        w: Number of werewolves
        num_trials: Number of simulation runs
    
    Returns:
        Estimated win probability (float between 0 and 1)
    """
    if w == 0:
        return 1.0
    if v <= w + 1:
        return 0.0
    wins = sum(1 for _ in range(num_trials) if simulate_game(v, w))
    return wins / num_trials


# ============================================================
# Algorithm 3: Bayesian Posterior Update
# ============================================================

class BayesianTracker:
    """Tracks posterior probabilities in a social deduction game.
    
    Maintains P(W_i | evidence) for each player i, updated after
    each round of voting and elimination.
    """
    
    def __init__(self, num_players: int, num_werewolves: int):
        """Initialize with uniform prior.
        
        Args:
            num_players: Total number of players
            num_werewolves: Number of werewolves
        """
        self.n = num_players
        self.k = num_werewolves
        self.alive = list(range(num_players))
        # Prior: each player has probability k/n of being a werewolf
        self.posterior = {i: Fraction(num_werewolves, num_players) 
                        for i in range(num_players)}
        self.eliminated: List[int] = []
        self.known_roles: Dict[int, str] = {}
    
    def update_after_night_kill(self, victim: int) -> None:
        """Update posteriors after a night kill.
        
        The victim is confirmed to be a villager (werewolves only kill villagers).
        This increases the posterior probability for all surviving players.
        
        Args:
            victim: Index of the eliminated player
        """
        self.alive.remove(victim)
        self.eliminated.append(victim)
        self.known_roles[victim] = "villager"
        del self.posterior[victim]
        
        # Renormalize: remaining werewolves are k - (known werewolves eliminated)
        known_wolves = sum(1 for p, r in self.known_roles.items() if r == "werewolf")
        remaining_wolves = self.k - known_wolves
        total_alive = len(self.alive)
        
        if total_alive > 0 and remaining_wolves > 0:
            for i in self.alive:
                self.posterior[i] = Fraction(remaining_wolves, total_alive)
    
    def update_after_day_vote(self, eliminated: int, was_werewolf: bool) -> None:
        """Update posteriors after a day elimination.
        
        Args:
            eliminated: Index of the eliminated player
            was_werewolf: Whether the eliminated player was a werewolf
        """
        self.alive.remove(eliminated)
        self.eliminated.append(eliminated)
        self.known_roles[eliminated] = "werewolf" if was_werewolf else "villager"
        del self.posterior[eliminated]
        
        # Renormalize
        known_wolves = sum(1 for p, r in self.known_roles.items() if r == "werewolf")
        remaining_wolves = self.k - known_wolves
        total_alive = len(self.alive)
        
        if total_alive > 0 and remaining_wolves > 0:
            for i in self.alive:
                self.posterior[i] = Fraction(remaining_wolves, total_alive)
    
    def recommend_target(self) -> int:
        """Recommend the player with highest posterior probability.
        
        Returns:
            Index of the player most likely to be a werewolf
        """
        return max(self.alive, key=lambda i: self.posterior.get(i, Fraction(0)))
    
    def get_posteriors(self) -> Dict[int, float]:
        """Get current posteriors as floats.
        
        Returns:
            Dictionary mapping player index to posterior probability
        """
        return {i: float(self.posterior[i]) for i in self.alive}


# ============================================================
# Algorithm 4: Game Tree Analysis (Small Games)
# ============================================================

@lru_cache(maxsize=None)
def optimal_win_prob(v: int, w: int) -> Fraction:
    """Compute optimal win probability with perfect information.
    
    This assumes villagers can always identify werewolves perfectly
    (best case). It gives an upper bound on Bayesian play.
    
    Under perfect information, villagers always vote correctly,
    so the game reduces to: can villagers eliminate all werewolves
    before werewolves reach parity?
    
    Args:
        v: Number of villagers
        w: Number of werewolves
    
    Returns:
        Win probability with perfect information (always 0 or 1)
    """
    if w == 0:
        return Fraction(1)
    if v <= w:  # Werewolves win immediately
        return Fraction(0)
    # Night: v → v-1. If w ≥ v-1, werewolves win.
    if w >= v - 1:
        return Fraction(0)
    # Day: with perfect info, always catch a werewolf
    # State becomes (v-1, w-1)
    return optimal_win_prob(v - 1, w - 1)


def verify_conjecture(max_v: int = 50, max_w: int = 20) -> bool:
    """Verify the skip-two monotonicity conjecture computationally.
    
    Checks P(v, w) ≤ P(v+2, w) for all v ≤ max_v, w ≤ max_w.
    
    Args:
        max_v: Maximum v to check
        max_w: Maximum w to check
    
    Returns:
        True if no violations found
    """
    for w in range(1, max_w + 1):
        for v in range(1, max_v + 1):
            if random_win_prob(v, w) > random_win_prob(v + 2, w):
                return False
    return True


if __name__ == "__main__":
    # Validate Monte Carlo against exact computation
    print("Validation: Monte Carlo vs. Exact")
    print("-" * 50)
    test_cases = [(3, 1), (5, 2), (7, 2), (5, 1), (6, 2)]
    for v, w in test_cases:
        exact = float(random_win_prob(v, w))
        mc = monte_carlo_win_prob(v, w, num_trials=100000)
        print(f"  P({v},{w}): exact={exact:.4f}, MC={mc:.4f}, diff={abs(exact-mc):.4f}")
    
    print()
    print(f"Skip-two conjecture verified: {verify_conjecture()}")
    
    print()
    print("Perfect information upper bounds:")
    for v, w in test_cases:
        opt = optimal_win_prob(v, w)
        rand = random_win_prob(v, w)
        print(f"  ({v},{w}): random={float(rand):.4f}, perfect={float(opt):.4f}")
