"""
Algorithms for Mortal-Eternity Survival Games.

Implements the core algorithms from the formalization:
- Safe strategy construction
- Survival simulation
- Safe Escape property checking
- Ordinal survival computation
"""

from typing import Callable, List, Tuple, Optional, Dict, Set
from dataclasses import dataclass
import random


# Type aliases
Move = int
History = List[Tuple[Move, Move]]
MortalStrategy = Callable[[History], Move]
EternityStrategy = Callable[[History, Move], Move]
DeathPredicate = Callable[[History], bool]


@dataclass
class SurvivalGame:
    """A survival game between Mortal and Eternity.
    
    Attributes:
        has_died: Predicate on play histories. Returns True if Mortal has died.
        num_mortal_moves: Number of moves available to Mortal (finite).
        num_eternity_moves: Number of moves available to Eternity (finite approx).
        name: Human-readable name for the game.
    """
    has_died: DeathPredicate
    num_mortal_moves: int = 2
    num_eternity_moves: int = 2
    name: str = "Unnamed Game"
    
    def start_alive(self) -> bool:
        """Verify the empty history is alive."""
        return not self.has_died([])
    
    def check_death_permanent(self, hist: History, pair: Tuple[Move, Move]) -> bool:
        """Check that death is permanent for a specific extension."""
        if self.has_died(hist):
            return self.has_died(hist + [pair])
        return True  # Vacuously true if not dead


def play_rounds(ms: MortalStrategy, es: EternityStrategy, n: int) -> History:
    """Play the game for n rounds, returning the complete history.
    
    Corresponds to `playRounds` in the Lean formalization.
    
    Args:
        ms: Mortal's strategy function.
        es: Eternity's strategy function.
        n: Number of rounds to play.
    
    Returns:
        List of (mortal_move, eternity_response) pairs.
    """
    hist: History = []
    for _ in range(n):
        m = ms(hist)
        e = es(hist, m)
        hist = hist + [(m, e)]
    return hist


def check_safe_escape(game: SurvivalGame, hist: History) -> Optional[Move]:
    """Check if Safe Escape holds at a given history.
    
    Tests all possible Mortal moves to find one that survives
    against all Eternity responses. Returns the safe move if found.
    
    Corresponds to `SafeEscape` in the Lean formalization.
    
    Args:
        game: The survival game.
        hist: Current play history.
    
    Returns:
        A safe move if one exists, None otherwise.
    """
    if game.has_died(hist):
        return None
    
    for m in range(game.num_mortal_moves):
        safe = True
        for e in range(game.num_eternity_moves):
            if game.has_died(hist + [(m, e)]):
                safe = False
                break
        if safe:
            return m
    return None


def safe_strategy(game: SurvivalGame) -> MortalStrategy:
    """Construct the greedy safe strategy.
    
    At each alive history, picks the first move that's safe against
    all of Eternity's responses. Corresponds to `safeStrategy` in Lean.
    
    This is the strategy guaranteed to achieve omega survival by
    the Omega Survival Theorem.
    
    Args:
        game: A survival game (should have Safe Escape property).
    
    Returns:
        A Mortal strategy function.
    """
    def strategy(hist: History) -> Move:
        safe_move = check_safe_escape(game, hist)
        if safe_move is not None:
            return safe_move
        return 0  # Default move at dead positions
    
    return strategy


def check_global_safe_escape(game: SurvivalGame, max_depth: int = 10) -> bool:
    """Check if Safe Escape holds at all reachable alive histories up to depth max_depth.
    
    This is an approximation of the full Safe Escape property,
    which would require checking infinitely many histories.
    
    Args:
        game: The survival game.
        max_depth: Maximum history depth to check.
    
    Returns:
        True if Safe Escape holds at all checked histories.
    """
    def _check(hist: History, depth: int) -> bool:
        if depth >= max_depth:
            return True
        if game.has_died(hist):
            return True  # Dead histories don't need safe escape
        
        safe_move = check_safe_escape(game, hist)
        if safe_move is None:
            return False
        
        # Recursively check extensions
        for e in range(game.num_eternity_moves):
            if not _check(hist + [(safe_move, e)], depth + 1):
                return False
        return True
    
    return _check([], 0)


def simulate_survival(game: SurvivalGame, ms: MortalStrategy, 
                       es: EternityStrategy, max_rounds: int = 1000) -> int:
    """Simulate a survival game and return the number of rounds survived.
    
    Args:
        game: The survival game.
        ms: Mortal's strategy.
        es: Eternity's strategy.
        max_rounds: Maximum rounds to simulate.
    
    Returns:
        Number of rounds survived (max_rounds if immortal up to that point).
    """
    hist: History = []
    for n in range(max_rounds):
        if game.has_died(hist):
            return n
        m = ms(hist)
        e = es(hist, m)
        hist = hist + [(m, e)]
    return max_rounds


def adversarial_eternity(game: SurvivalGame) -> EternityStrategy:
    """Construct an adversarial Eternity strategy.
    
    Eternity tries to force Mortal into death by choosing the response
    most likely to lead to death (greedy adversarial).
    
    Args:
        game: The survival game.
    
    Returns:
        An Eternity strategy function.
    """
    def strategy(hist: History, mortal_move: Move) -> Move:
        # Try each response and pick the one leading to death soonest
        for e in range(game.num_eternity_moves):
            if game.has_died(hist + [(mortal_move, e)]):
                return e
        return 0  # No immediately killing response found
    
    return strategy


def random_eternity(num_moves: int = 2) -> EternityStrategy:
    """Construct a random Eternity strategy."""
    def strategy(hist: History, mortal_move: Move) -> Move:
        return random.randint(0, num_moves - 1)
    return strategy


def compute_asymmetry_gap(game: SurvivalGame, max_rounds: int = 100,
                           num_trials: int = 100) -> Dict[str, float]:
    """Estimate the computational asymmetry gap.
    
    Compares survival against adversarial vs random Eternity strategies
    to measure how much computational power matters.
    
    Args:
        game: The survival game.
        max_rounds: Maximum rounds per trial.
        num_trials: Number of random trials.
    
    Returns:
        Dictionary with survival statistics.
    """
    ms = safe_strategy(game)
    adv_es = adversarial_eternity(game)
    
    # Against adversarial Eternity
    adv_survival = simulate_survival(game, ms, adv_es, max_rounds)
    
    # Against random Eternity (average over trials)
    random_survivals = []
    for _ in range(num_trials):
        rand_es = random_eternity(game.num_eternity_moves)
        s = simulate_survival(game, ms, rand_es, max_rounds)
        random_survivals.append(s)
    
    avg_random = sum(random_survivals) / len(random_survivals)
    
    return {
        "adversarial_survival": adv_survival,
        "random_avg_survival": avg_random,
        "asymmetry_gap": abs(adv_survival - avg_random),
        "safe_escape_holds": check_global_safe_escape(game, min(max_rounds, 8)),
    }


# --- Example Games ---

def create_threshold_game(threshold: int = 10) -> SurvivalGame:
    """A game where Mortal dies if the sum of moves exceeds a threshold.
    
    This game does NOT have Safe Escape if Eternity can push the sum
    past the threshold.
    """
    def has_died(hist: History) -> bool:
        total = sum(m + e for m, e in hist)
        return total > threshold
    
    return SurvivalGame(
        has_died=has_died,
        num_mortal_moves=3,
        num_eternity_moves=3,
        name=f"Threshold Game (threshold={threshold})"
    )


def create_parity_game() -> SurvivalGame:
    """A game where Mortal dies if the parity of moves doesn't match.
    
    Mortal survives if at each step, mortal_move ≡ step_number (mod 2).
    This has Safe Escape: Mortal just needs to play the right parity.
    """
    def has_died(hist: History) -> bool:
        for i, (m, e) in enumerate(hist):
            if m % 2 != i % 2:
                return True
        return False
    
    return SurvivalGame(
        has_died=has_died,
        num_mortal_moves=4,
        num_eternity_moves=2,
        name="Parity Game"
    )


def create_safe_escape_game() -> SurvivalGame:
    """A game with guaranteed Safe Escape property.
    
    Death requires Mortal to play 0 when Eternity plays 0.
    Safe escape: Mortal can always play 1 to avoid death.
    """
    def has_died(hist: History) -> bool:
        for m, e in hist:
            if m == 0 and e == 0:
                return True
        return False
    
    return SurvivalGame(
        has_died=has_died,
        num_mortal_moves=2,
        num_eternity_moves=2,
        name="Safe Escape Game"
    )


def create_random_game(num_mortal: int = 2, num_eternity: int = 2, 
                        death_prob: float = 0.3, seed: int = 42) -> SurvivalGame:
    """Create a random survival game with given death probability.
    
    Args:
        num_mortal: Number of Mortal moves.
        num_eternity: Number of Eternity responses.
        death_prob: Probability of death at each extension.
        seed: Random seed for reproducibility.
    """
    rng = random.Random(seed)
    death_cache: Dict[str, bool] = {"": False}  # Empty history is alive
    
    def has_died(hist: History) -> bool:
        key = str(hist)
        if key not in death_cache:
            # Check if prefix is dead (permanence)
            if len(hist) > 0:
                prefix_key = str(hist[:-1])
                if prefix_key in death_cache and death_cache[prefix_key]:
                    death_cache[key] = True
                    return True
            # Random death
            rng_local = random.Random(hash(key) + seed)
            death_cache[key] = rng_local.random() < death_prob
        return death_cache[key]
    
    return SurvivalGame(
        has_died=has_died,
        num_mortal_moves=num_mortal,
        num_eternity_moves=num_eternity,
        name=f"Random Game (p={death_prob}, seed={seed})"
    )
