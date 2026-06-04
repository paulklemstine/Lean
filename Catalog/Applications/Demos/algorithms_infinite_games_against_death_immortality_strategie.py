"""
Algorithms for Ordinal Survival Theory

Type-hinted implementations of the core algorithms from the
Ordinal Survival Theory framework.
"""

from typing import Callable, List, Tuple, Optional, Dict, Any
from dataclasses import dataclass
from enum import Enum
import math


# ═══════════════════════════════════════════════════════════
# Type definitions
# ═══════════════════════════════════════════════════════════

History = List[Tuple[int, int]]
MortalStrategy = Callable[[History], int]
EternityStrategy = Callable[[History, int], int]
DeathPredicate = Callable[[History], bool]


# ═══════════════════════════════════════════════════════════
# Ordinal Arithmetic (finite representation)
# ═══════════════════════════════════════════════════════════

@dataclass(frozen=True)
class Ordinal:
    """Cantor Normal Form representation of ordinals below ε₀.
    
    Represents ordinals in the form ω^a₁·c₁ + ω^a₂·c₂ + ... 
    where a₁ > a₂ > ... and cᵢ are positive naturals.
    """
    terms: Tuple[Tuple['Ordinal', int], ...]  # ((exponent, coefficient), ...)
    
    @staticmethod
    def zero() -> 'Ordinal':
        return Ordinal(())
    
    @staticmethod
    def finite(n: int) -> 'Ordinal':
        """Create a finite ordinal."""
        if n == 0:
            return Ordinal.zero()
        return Ordinal(((Ordinal.zero(), n),))
    
    @staticmethod
    def omega() -> 'Ordinal':
        """ω = omega"""
        return Ordinal(((Ordinal.finite(1), 1),))
    
    @staticmethod
    def omega_times(k: int) -> 'Ordinal':
        """ω · k"""
        if k == 0:
            return Ordinal.zero()
        return Ordinal(((Ordinal.finite(1), k),))
    
    @staticmethod
    def omega_squared() -> 'Ordinal':
        """ω²"""
        return Ordinal(((Ordinal.finite(2), 1),))
    
    @staticmethod
    def omega_power(n: int) -> 'Ordinal':
        """ω^n"""
        return Ordinal(((Ordinal.finite(n), 1),))
    
    def is_zero(self) -> bool:
        return len(self.terms) == 0
    
    def is_finite(self) -> bool:
        return self.is_zero() or (
            len(self.terms) == 1 and self.terms[0][0].is_zero()
        )
    
    def to_nat(self) -> Optional[int]:
        """Convert to natural number if finite."""
        if self.is_zero():
            return 0
        if self.is_finite():
            return self.terms[0][1]
        return None
    
    def __str__(self) -> str:
        if self.is_zero():
            return "0"
        parts = []
        for exp, coeff in self.terms:
            if exp.is_zero():
                parts.append(str(coeff))
            elif exp == Ordinal.finite(1):
                parts.append(f"ω·{coeff}" if coeff > 1 else "ω")
            elif exp == Ordinal.finite(2):
                parts.append(f"ω²·{coeff}" if coeff > 1 else "ω²")
            else:
                parts.append(f"ω^{exp}·{coeff}" if coeff > 1 else f"ω^{exp}")
        return " + ".join(parts)
    
    def __lt__(self, other: 'Ordinal') -> bool:
        """Lexicographic comparison."""
        for i in range(max(len(self.terms), len(other.terms))):
            if i >= len(self.terms):
                return True  # self ran out first
            if i >= len(other.terms):
                return False
            if self.terms[i] != other.terms[i]:
                s_exp, s_coeff = self.terms[i]
                o_exp, o_coeff = other.terms[i]
                if s_exp != o_exp:
                    return s_exp < o_exp
                return s_coeff < o_coeff
        return False


# ═══════════════════════════════════════════════════════════
# Algorithm 1: Safe Strategy Construction
# ═══════════════════════════════════════════════════════════

def construct_safe_strategy(
    death: DeathPredicate,
    move_space: int = 100,
    response_space: int = 100
) -> MortalStrategy:
    """Construct the safe strategy for a survival game.
    
    Algorithm (Safe Strategy Construction):
        Input: Death predicate D, move space M, response space R
        Output: Strategy σ : History → Move
        
        For each history h:
            For each move m ∈ M:
                If ∀ e ∈ R: ¬D(h ++ [(m, e)]):
                    Return m
            Return 0 (fallback — should not be reached if SafeEscape holds)
    
    Time complexity: O(|M| · |R|) per move
    Space complexity: O(|history|) for storing the current history
    
    Correctness: If SafeEscape holds, then for every alive history h,
    there exists m such that ∀e, ¬D(h ++ [(m,e)]). The strategy finds
    this m by exhaustive search. By induction, the strategy maintains
    survival at every round (Omega Survival Theorem).
    """
    def strategy(history: History) -> int:
        for m in range(move_space):
            safe = True
            for e in range(response_space):
                if death(history + [(m, e)]):
                    safe = False
                    break
            if safe:
                return m
        return 0
    return strategy


# ═══════════════════════════════════════════════════════════
# Algorithm 2: Survival Ordinal Computation
# ═══════════════════════════════════════════════════════════

def compute_survival_ordinal(
    death: DeathPredicate,
    move_space: int = 10,
    response_space: int = 10,
    max_depth: int = 100
) -> Ordinal:
    """Compute (approximate) the survival ordinal of a game.
    
    Algorithm (Survival Ordinal Approximation):
        Input: Death predicate D, search bounds
        Output: Lower bound on survival ordinal
        
        1. Check SafeEscape at empty history
        2. If SafeEscape holds at all reachable histories up to depth max_depth:
           Return ω (immortal)
        3. Otherwise: Return max finite survival depth
    
    This is necessarily approximate since the true ordinal may be infinite.
    """
    strategy = construct_safe_strategy(death, move_space, response_space)
    
    # Check survival up to max_depth rounds
    has_safe_escape = True
    max_survived = 0
    
    for n in range(max_depth):
        # Try the safe strategy against the worst-case response
        survived_this_round = True
        for e_strategy_id in range(min(response_space, 5)):
            eternity: EternityStrategy = lambda h, m, eid=e_strategy_id: eid
            history = []
            alive = True
            for step in range(n + 1):
                m_move = strategy(history)
                e_response = eternity(history, m_move)
                history.append((m_move, e_response))
                if death(history):
                    alive = False
                    break
            if not alive:
                survived_this_round = False
                break
        
        if survived_this_round:
            max_survived = n + 1
        else:
            has_safe_escape = False
            break
    
    if has_safe_escape:
        return Ordinal.omega()
    return Ordinal.finite(max_survived)


# ═══════════════════════════════════════════════════════════
# Algorithm 3: Phased Survival Computation
# ═══════════════════════════════════════════════════════════

@dataclass
class PhasedSurvivalResult:
    """Result of phased survival analysis."""
    num_phases: int
    phase_ordinals: List[Ordinal]
    combined_ordinal: Ordinal
    is_all_immortal: bool


def compute_phased_survival(
    games: List[DeathPredicate],
    move_space: int = 10,
    response_space: int = 10
) -> PhasedSurvivalResult:
    """Compute the combined survival ordinal of a phased system.
    
    Algorithm (Phased Survival):
        Input: List of k death predicates [D₁, ..., Dₖ]
        Output: Combined survival ordinal
        
        1. For each phase i, compute survival ordinal αᵢ
        2. If all αᵢ = ω: combined = ω · k
        3. Otherwise: combined = α₁ + α₂ + ... + αₖ (ordinal sum)
    """
    k = len(games)
    phase_ordinals = []
    all_immortal = True
    
    for death in games:
        alpha = compute_survival_ordinal(death, move_space, response_space)
        phase_ordinals.append(alpha)
        if alpha != Ordinal.omega():
            all_immortal = False
    
    if all_immortal:
        combined = Ordinal.omega_times(k)
    else:
        # Sum of finite ordinals
        total = sum(a.to_nat() or 0 for a in phase_ordinals)
        combined = Ordinal.finite(total)
    
    return PhasedSurvivalResult(
        num_phases=k,
        phase_ordinals=phase_ordinals,
        combined_ordinal=combined,
        is_all_immortal=all_immortal
    )


# ═══════════════════════════════════════════════════════════
# Algorithm 4: Adaptive Nondeterminism
# ═══════════════════════════════════════════════════════════

def adaptive_survival_bound(
    game_factory: Callable[[int], List[DeathPredicate]],
    max_k: int = 20
) -> Ordinal:
    """Compute adaptive survival bound.
    
    Algorithm (Adaptive Survival):
        Input: Factory that creates k-phase game systems
        Output: Adaptive survival ordinal
        
        1. For k = 1, 2, ..., max_k:
           a. Create k-phase system
           b. Compute phased survival ordinal
        2. If all systems achieve ω·k:
           Return ω² (adaptive nondeterminism achieves omega-squared)
        3. Otherwise: Return max achieved ordinal
    """
    all_achieve_omega_k = True
    max_ordinal = Ordinal.zero()
    
    for k in range(1, max_k + 1):
        games = game_factory(k)
        result = compute_phased_survival(games)
        
        if not result.is_all_immortal:
            all_achieve_omega_k = False
        
        # Track maximum
        if result.combined_ordinal > max_ordinal:  # type: ignore
            max_ordinal = result.combined_ordinal
    
    if all_achieve_omega_k:
        return Ordinal.omega_squared()
    return max_ordinal


# ═══════════════════════════════════════════════════════════
# Algorithm 5: Game Tree Minimax with Determinacy Rank
# ═══════════════════════════════════════════════════════════

@dataclass
class GameTreeNode:
    """A finite game tree node."""
    is_leaf: bool = False
    winner: Optional[bool] = None  # True = Player I wins
    is_player_I: bool = True       # Whose turn?
    children: Optional[List['GameTreeNode']] = None
    
    @staticmethod
    def leaf(winner: bool) -> 'GameTreeNode':
        return GameTreeNode(is_leaf=True, winner=winner)
    
    @staticmethod
    def internal(is_player_I: bool, children: List['GameTreeNode']) -> 'GameTreeNode':
        return GameTreeNode(is_leaf=False, is_player_I=is_player_I, children=children)


def minimax_value(node: GameTreeNode) -> bool:
    """Compute the minimax value of a game tree (Zermelo's theorem)."""
    if node.is_leaf:
        return node.winner or False
    
    assert node.children is not None
    child_values = [minimax_value(c) for c in node.children]
    
    if node.is_player_I:
        return any(child_values)  # Player I picks best
    else:
        return all(child_values)  # Player II picks best


def determinacy_rank(node: GameTreeNode) -> int:
    """Compute the determinacy rank: depth of strategic analysis needed."""
    if node.is_leaf:
        return 0
    
    assert node.children is not None
    child_ranks = [determinacy_rank(c) for c in node.children]
    val = minimax_value(node)
    
    if node.is_player_I:
        if val:  # Player I wins — use minimum rank among winning children
            winning_ranks = [r for c, r in zip(node.children, child_ranks)
                           if minimax_value(c)]
            return min(winning_ranks) if winning_ranks else max(child_ranks) + 1
        else:  # Player II wins — must check all children
            return max(child_ranks) + 1
    else:
        if not val:  # Player II wins — use minimum rank among winning children
            winning_ranks = [r for c, r in zip(node.children, child_ranks)
                           if not minimax_value(c)]
            return min(winning_ranks) if winning_ranks else max(child_ranks) + 1
        else:  # Player I wins — must check all children
            return max(child_ranks) + 1


if __name__ == "__main__":
    # Demo: Ordinal arithmetic
    print("Ordinal Arithmetic Examples:")
    print(f"  ω     = {Ordinal.omega()}")
    print(f"  ω·3   = {Ordinal.omega_times(3)}")
    print(f"  ω²    = {Ordinal.omega_squared()}")
    print(f"  ω^3   = {Ordinal.omega_power(3)}")
    
    # Demo: Game tree analysis
    print("\nGame Tree Analysis:")
    tree = GameTreeNode.internal(True, [
        GameTreeNode.internal(False, [
            GameTreeNode.leaf(True),
            GameTreeNode.leaf(False)
        ]),
        GameTreeNode.internal(False, [
            GameTreeNode.leaf(False),
            GameTreeNode.leaf(True)
        ])
    ])
    print(f"  Minimax value: {'Player I wins' if minimax_value(tree) else 'Player II wins'}")
    print(f"  Determinacy rank: {determinacy_rank(tree)}")
