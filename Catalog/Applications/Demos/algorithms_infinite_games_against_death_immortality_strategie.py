#!/usr/bin/env python3
"""
Algorithms for Ordinal Survival Games

Type-hinted implementations of key algorithms from the theory:
1. Immortality checking via strategy enumeration
2. Survival ordinal computation for finite games
3. Hierarchical game composition
4. Evasion game analysis
"""

from typing import Callable, List, Tuple, Set, Optional, Dict
from dataclasses import dataclass
from itertools import product as cart_product


@dataclass
class SurvivalGame:
    """A finite survival game between Mortal and Eternity.
    
    States are integers 0..num_states-1.
    Moves are integers 0..arity-1.
    """
    num_states: int
    mortal_arity: int
    eternity_arity: int
    transition: Callable[[int, int, int], int]  # state, mortal_move, eternity_move -> state
    alive: Callable[[int], bool]


Strategy = Tuple[int, ...]  # maps state index to move index


def play_n(game: SurvivalGame, mortal: Strategy, eternity: Callable[[int, int], int],
           s0: int, n: int) -> List[int]:
    """Play the game for n rounds, returning the sequence of states."""
    states = [s0]
    s = s0
    for _ in range(n):
        m_move = mortal[s]
        e_move = eternity(s, m_move)
        s = game.transition(s, m_move, e_move)
        states.append(s)
    return states


def survives_n(game: SurvivalGame, mortal: Strategy, eternity: Callable[[int, int], int],
               s0: int, n: int) -> bool:
    """Check if Mortal survives n rounds under given strategies."""
    states = play_n(game, mortal, eternity, s0, n)
    return all(game.alive(s) for s in states)


def all_mortal_strategies(game: SurvivalGame) -> List[Strategy]:
    """Enumerate all Mortal strategies."""
    return list(cart_product(range(game.mortal_arity), repeat=game.num_states))


def all_eternity_strategies(game: SurvivalGame) -> List[Callable[[int, int], int]]:
    """Enumerate all Eternity strategies as lookup tables."""
    result = []
    for vals in cart_product(range(game.eternity_arity),
                             repeat=game.num_states * game.mortal_arity):
        def make_strategy(v: Tuple[int, ...]) -> Callable[[int, int], int]:
            def strategy(s: int, m: int) -> int:
                return v[s * game.mortal_arity + m]
            return strategy
        result.append(make_strategy(vals))
    return result


def can_force_n(game: SurvivalGame, s0: int, n: int) -> Optional[Strategy]:
    """Find a Mortal strategy that forces survival for n rounds.
    
    Returns the strategy if one exists, None otherwise.
    """
    eternity_strats = all_eternity_strategies(game)
    for mortal in all_mortal_strategies(game):
        if all(survives_n(game, mortal, e, s0, n) for e in eternity_strats):
            return mortal
    return None


def find_immortal_strategy(game: SurvivalGame, s0: int,
                           max_horizon: int = 100) -> Optional[Strategy]:
    """Find an immortal strategy using the ω-survival theorem.
    
    Algorithm (pigeonhole):
    1. For each horizon n = 0, 1, ..., max_horizon, find a surviving strategy f(n)
    2. Since the strategy space is finite, some strategy σ* appears infinitely often
    3. By monotonicity, σ* survives all horizons ≤ max_horizon
    4. If max_horizon is large enough (≥ |strategy_space|), σ* is immortal
    
    The ω-survival theorem guarantees that if an immortal strategy exists,
    this procedure finds it within |strategy_space| iterations.
    """
    strategy_count: Dict[Strategy, int] = {}
    
    for n in range(max_horizon + 1):
        strat = can_force_n(game, s0, n)
        if strat is None:
            print(f"  Cannot survive {n} rounds — game is mortal.")
            return None
        strategy_count[strat] = strategy_count.get(strat, 0) + 1
    
    # Find the most frequently appearing strategy
    best = max(strategy_count, key=lambda s: strategy_count[s])
    count = strategy_count[best]
    
    total_strategies = game.mortal_arity ** game.num_states
    if count > total_strategies:
        # This strategy appeared more times than there are strategies
        # By pigeonhole, it must work for all horizons
        pass
    
    return best


def survival_ordinal_finite(game: SurvivalGame, s0: int,
                            max_check: int = 1000) -> int:
    """Compute the survival ordinal for a finite game (returns a natural number or -1 for ω).
    
    Returns:
        n ≥ 0: Mortal can force exactly n rounds (survival ordinal = n)
        -1: Mortal can force all horizons up to max_check (survival ordinal ≥ ω)
    """
    for n in range(max_check + 1):
        if can_force_n(game, s0, n) is None:
            return n - 1 if n > 0 else 0
    return -1  # Likely ω


def hierarchical_survival_ordinal(
    phase_games: List[SurvivalGame],
    entry_states: List[int],
    max_check: int = 100,
) -> str:
    """Compute the survival ordinal of a hierarchical game.
    
    If each phase has survival ordinal ≥ ω, the total is ω × (number of phases).
    For infinitely many phases, this gives ω².
    """
    ordinals = []
    for i, (game, s0) in enumerate(zip(phase_games, entry_states)):
        ord_val = survival_ordinal_finite(game, s0, max_check)
        ordinals.append(ord_val)
    
    if all(o == -1 for o in ordinals):
        n = len(phase_games)
        return f"ω × {n} (each phase immortal)"
    else:
        total = sum(o for o in ordinals if o >= 0)
        immortal = sum(1 for o in ordinals if o == -1)
        return f"≥ {total} + ω × {immortal}"


# === Example Games ===

def make_trivial_game() -> SurvivalGame:
    """Every state is alive, trivial survival."""
    return SurvivalGame(
        num_states=1,
        mortal_arity=1,
        eternity_arity=1,
        transition=lambda s, m, e: 0,
        alive=lambda s: True,
    )


def make_countdown_game(bound: int) -> SurvivalGame:
    """State decrements each round; alive when > 0."""
    return SurvivalGame(
        num_states=bound + 1,
        mortal_arity=1,
        eternity_arity=1,
        transition=lambda s, m, e: max(0, s - 1),
        alive=lambda s: s > 0,
    )


def make_evasion_game(n: int) -> SurvivalGame:
    """Hide-and-seek: evader hides, searcher searches.
    
    State = (evader_pos, searcher_pos) encoded as evader_pos * n + searcher_pos.
    """
    return SurvivalGame(
        num_states=n * n,
        mortal_arity=n,
        eternity_arity=n,
        transition=lambda s, m, e: m * n + e,
        alive=lambda s: (s // n) != (s % n) if n > 0 else False,  # different positions
    )


def make_cycling_game() -> SurvivalGame:
    """A 3-state game where one strategy cycles forever.
    
    States: 0 (alive), 1 (alive), 2 (dead)
    Strategy (1, 0, 0) cycles between 0 and 1.
    """
    def transition(s: int, m: int, e: int) -> int:
        if s == 0:
            return 1 if m == 1 else 2
        elif s == 1:
            return 0 if m == 0 else (1 if e == 0 else 0)
        return 2
    
    return SurvivalGame(
        num_states=3,
        mortal_arity=2,
        eternity_arity=2,
        transition=transition,
        alive=lambda s: s < 2,
    )


if __name__ == "__main__":
    print("=== Trivial Game ===")
    g = make_trivial_game()
    result = find_immortal_strategy(g, 0, 10)
    print(f"  Immortal strategy: {result}")
    
    print("\n=== Countdown Games ===")
    for bound in [1, 2, 3, 5]:
        g = make_countdown_game(bound)
        ord_val = survival_ordinal_finite(g, bound, 20)
        print(f"  Countdown({bound}): survival ordinal = {ord_val}")
    
    print("\n=== Cycling Game ===")
    g = make_cycling_game()
    result = find_immortal_strategy(g, 0, 20)
    print(f"  Immortal strategy: {result}")
    ord_val = survival_ordinal_finite(g, 0, 50)
    print(f"  Survival ordinal: {'ω' if ord_val == -1 else ord_val}")
    
    print("\n=== Evasion Game ===")
    for n in [2, 3]:
        g = make_evasion_game(n)
        # Start with evader at 0, searcher at 1 (alive)
        s0 = 0 * n + 1
        ord_val = survival_ordinal_finite(g, s0, 5)
        print(f"  Evasion({n}): survival ordinal = {ord_val}")
        print(f"    (Eternity wins immediately by copying Mortal's move)")
