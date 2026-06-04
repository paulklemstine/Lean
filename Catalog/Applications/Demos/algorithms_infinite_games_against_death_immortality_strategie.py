#!/usr/bin/env python3
"""
Algorithms for Asymmetric Computation Games
============================================
Type-hinted implementations of the key algorithms from the Mortal vs. Eternity
game theory framework.
"""

from dataclasses import dataclass
from typing import Callable, List, Optional, Tuple
from enum import Enum


class OrdinalSymbol(Enum):
    """Symbolic ordinal representations."""
    ZERO = "0"
    FINITE = "finite"
    OMEGA = "ω"
    OMEGA_K = "ω·k"
    OMEGA_SQ = "ω²"
    OMEGA_D = "ω^d"
    OMEGA_OMEGA = "ω^ω"


@dataclass
class SurvivalProfile:
    """
    A survival profile: which finite durations Mortal can guarantee.
    
    Invariant: can_survive is downward-closed and contains 0.
    """
    can_survive: Callable[[int], bool]
    name: str = "unnamed"
    
    def is_full(self) -> bool:
        """Check if profile is full (heuristic: test up to large N)."""
        return all(self.can_survive(n) for n in range(10000))
    
    def survival_ordinal(self) -> OrdinalSymbol:
        """Compute the symbolic survival ordinal."""
        if self.is_full():
            return OrdinalSymbol.OMEGA
        # Find upper bound
        for n in range(10001):
            if not self.can_survive(n):
                return OrdinalSymbol.FINITE
        return OrdinalSymbol.OMEGA


def full_profile() -> SurvivalProfile:
    """The full profile: survives any finite number of rounds."""
    return SurvivalProfile(
        can_survive=lambda n: True,
        name="full"
    )


def bounded_profile(k: int) -> SurvivalProfile:
    """Bounded profile: survives at most k rounds."""
    return SurvivalProfile(
        can_survive=lambda n: n <= k,
        name=f"bounded({k})"
    )


def empty_profile() -> SurvivalProfile:
    """Empty profile: survives only 0 rounds."""
    return SurvivalProfile(
        can_survive=lambda n: n == 0,
        name="empty"
    )


def seq_compose(p1: SurvivalProfile, p2: SurvivalProfile) -> SurvivalProfile:
    """
    Sequential composition: play p1, then p2.
    can_survive(n) iff ∃ a,b: p1.can_survive(a) ∧ p2.can_survive(b) ∧ a+b=n
    
    Algorithm: O(n) per query, check all partitions a + b = n.
    """
    def can_survive(n: int) -> bool:
        return any(
            p1.can_survive(a) and p2.can_survive(n - a)
            for a in range(n + 1)
        )
    return SurvivalProfile(
        can_survive=can_survive,
        name=f"seq({p1.name}, {p2.name})"
    )


def family_profile(profiles: Callable[[int], SurvivalProfile]) -> SurvivalProfile:
    """
    Family profile: nondeterministically pick index k, play profiles(k).
    can_survive(n) iff ∃ k: profiles(k).can_survive(n)
    
    Algorithm: Search over indices up to some bound.
    """
    def can_survive(n: int) -> bool:
        # Search: profile k = bounded(k), so try k = n
        for k in range(n + 10):
            if profiles(k).can_survive(n):
                return True
        return False
    return SurvivalProfile(
        can_survive=can_survive,
        name="family"
    )


def ascending_family() -> SurvivalProfile:
    """The ascending family: profile k = bounded(k)."""
    return family_profile(lambda k: bounded_profile(k))


def nested_family(depth: int) -> SurvivalProfile:
    """d-fold nested family of full profiles."""
    if depth == 0:
        return full_profile()
    return family_profile(lambda _: nested_family(depth - 1))


def seq_pow(p: SurvivalProfile, k: int) -> SurvivalProfile:
    """k-fold sequential composition of p with itself."""
    if k == 0:
        return empty_profile()
    result = p
    for _ in range(k - 1):
        result = seq_compose(result, p)
    return result


# ── Game Simulation ──

@dataclass
class GameState:
    """State in the Mortal vs. Eternity game."""
    resource: int
    round_num: int = 0
    alive: bool = True


def mortal_strategy_depth_k(state: GameState, k: int) -> int:
    """
    Mortal's strategy with depth-k lookahead.
    Returns the resource allocation for this round.
    
    Simple strategy: spend 1 resource per round.
    """
    return min(1, state.resource)


def eternity_strategy_greedy(state: GameState) -> int:
    """
    Eternity's greedy strategy: force maximum resource depletion.
    Returns the attack strength for this round.
    """
    return 1  # Attack with full force


def simulate_game(
    initial_resource: int,
    mortal_depth: int,
    max_rounds: int = 1000
) -> Tuple[int, List[GameState]]:
    """
    Simulate a Mortal vs. Eternity game.
    
    Returns (survival_length, trace).
    """
    state = GameState(resource=initial_resource)
    trace: List[GameState] = [state]
    
    for r in range(1, max_rounds + 1):
        if state.resource <= 0:
            state = GameState(resource=0, round_num=r, alive=False)
            trace.append(state)
            break
        
        # Mortal plays
        spend = mortal_strategy_depth_k(state, mortal_depth)
        
        # Eternity responds
        attack = eternity_strategy_greedy(state)
        
        # Update state
        new_resource = state.resource - max(spend, attack)
        state = GameState(resource=new_resource, round_num=r, alive=new_resource > 0)
        trace.append(state)
    
    survival_length = sum(1 for s in trace if s.alive)
    return survival_length, trace


# ── ITTM Connection ──

def ittm_level(profile: SurvivalProfile) -> int:
    """Compute the ITTM computation level of a profile."""
    if profile.is_full():
        return 1
    return 0


def ordinal_hierarchy_display() -> List[Tuple[str, str, str]]:
    """
    Display the ordinal hierarchy for survival profiles.
    
    Returns list of (profile_description, survival_ordinal, ittm_level).
    """
    return [
        ("empty", "0", "N/A"),
        ("bounded(k)", "k", "Level 0"),
        ("full", "ω", "Level 1"),
        ("nested(d)", "≥ ω", f"Level d"),
        ("ascending family", "ω", "Level 1"),
        ("seq^k(full)", "ω (k≥1)", "Level 1"),
    ]


if __name__ == "__main__":
    print("=== Survival Profile Tests ===")
    
    fp = full_profile()
    bp = bounded_profile(10)
    ep = empty_profile()
    
    print(f"full.can_survive(1000) = {fp.can_survive(1000)}")
    print(f"bounded(10).can_survive(10) = {bp.can_survive(10)}")
    print(f"bounded(10).can_survive(11) = {bp.can_survive(11)}")
    print(f"empty.can_survive(0) = {ep.can_survive(0)}")
    print(f"empty.can_survive(1) = {ep.can_survive(1)}")
    
    print(f"\nfull.survival_ordinal() = {fp.survival_ordinal()}")
    print(f"bounded(10).survival_ordinal() = {bp.survival_ordinal()}")
    print(f"empty.survival_ordinal() = {ep.survival_ordinal()}")
    
    print("\n=== Sequential Composition ===")
    sq = seq_compose(bp, bp)
    print(f"seq(bounded(10), bounded(10)).can_survive(20) = {sq.can_survive(20)}")
    print(f"seq(bounded(10), bounded(10)).can_survive(21) = {sq.can_survive(21)}")
    
    print("\n=== Game Simulation ===")
    survival, trace = simulate_game(initial_resource=15, mortal_depth=5)
    print(f"Survival length with resource=15, depth=5: {survival} rounds")
    
    print("\n=== Ordinal Hierarchy ===")
    for desc, ordinal, level in ordinal_hierarchy_display():
        print(f"  {desc:<25} survival={ordinal:<10} ITTM={level}")
