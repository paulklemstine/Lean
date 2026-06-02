#!/usr/bin/env python3
"""
Gödel's Casino: Core Algorithms

Type-hinted implementations of the key algorithms from the formalization.
"""

from typing import List, Tuple, Dict, Callable, Optional
from dataclasses import dataclass
from enum import Enum


class Bet(Enum):
    """A bet in Gödel's Casino."""
    TRUE = "true"
    FALSE = "false"
    ABSTAIN = "abstain"


@dataclass
class CasinoRound:
    """A single round: ground truth and decidability flag."""
    truth: bool
    decidable: bool


@dataclass
class OracleCasino:
    """A full casino game with n rounds."""
    rounds: List[CasinoRound]

    @property
    def n(self) -> int:
        return len(self.rounds)

    @property
    def dec_count(self) -> int:
        return sum(1 for r in self.rounds if r.decidable)

    @property
    def undec_count(self) -> int:
        return self.n - self.dec_count

    @property
    def incompleteness_entropy(self) -> float:
        if self.n == 0:
            return 0.0
        return self.undec_count / self.n

    @property
    def decidable_fraction(self) -> float:
        if self.n == 0:
            return 0.0
        return self.dec_count / self.n


Strategy = Callable[[CasinoRound], Bet]


def payoff(truth: bool, bet: Bet) -> int:
    """Compute the payoff of a bet given the truth value."""
    if bet == Bet.ABSTAIN:
        return 0
    elif bet == Bet.TRUE:
        return 1 if truth else -1
    else:  # FALSE
        return -1 if truth else 1


def selective_strategy(round: CasinoRound) -> Bet:
    """
    The selective strategy: bet correctly on decidable rounds, abstain otherwise.
    
    This is the optimal strategy in Gödel's Casino.
    Guaranteed profit = number of decidable rounds.
    """
    if round.decidable:
        return Bet.TRUE if round.truth else Bet.FALSE
    return Bet.ABSTAIN


def naive_true_strategy(_round: CasinoRound) -> Bet:
    """Always bet TRUE. Vulnerable to adversarial truth assignments."""
    return Bet.TRUE


def naive_false_strategy(_round: CasinoRound) -> Bet:
    """Always bet FALSE. Vulnerable to adversarial truth assignments."""
    return Bet.FALSE


def casino_profit(casino: OracleCasino, strategy: Strategy) -> int:
    """Compute the total profit of a strategy on a casino game."""
    return sum(payoff(r.truth, strategy(r)) for r in casino.rounds)


def verify_selective_profit(casino: OracleCasino) -> Tuple[int, int, bool]:
    """
    Verify that selective strategy profit equals decidable count.
    
    Returns (profit, dec_count, they_match).
    """
    profit = casino_profit(casino, selective_strategy)
    dec = casino.dec_count
    return profit, dec, profit == dec


def verify_entropy_duality(casino: OracleCasino) -> Tuple[float, float, float]:
    """
    Verify the entropy-profit duality: entropy + dec_fraction = 1.
    
    Returns (entropy, dec_fraction, sum).
    """
    e = casino.incompleteness_entropy
    d = casino.decidable_fraction
    return e, d, e + d


@dataclass
class AugmentedCasino:
    """Casino with base decidability and oracle extension."""
    rounds: List[CasinoRound]
    oracle_extension: List[bool]

    def combined_decidable(self, i: int) -> bool:
        return self.rounds[i].decidable or self.oracle_extension[i]

    @property
    def base_count(self) -> int:
        return sum(1 for r in self.rounds if r.decidable)

    @property
    def combined_count(self) -> int:
        return sum(1 for i in range(len(self.rounds)) if self.combined_decidable(i))

    @property
    def information_value(self) -> int:
        """The information value of the oracle extension."""
        return self.combined_count - self.base_count


def oracle_union(o1: List[bool], o2: List[bool]) -> List[bool]:
    """Compute the union of two oracles."""
    return [a or b for a, b in zip(o1, o2)]


@dataclass
class LayeredCasino:
    """
    A layered casino with L+1 oracle levels.
    Each level decides a superset of the previous level.
    """
    truths: List[bool]
    oracles: List[List[bool]]  # oracles[level][statement]

    def layer_dec_count(self, level: int) -> int:
        return sum(1 for d in self.oracles[level] if d)

    def layer_profit(self, level: int) -> int:
        """Selective strategy profit at a given level."""
        return self.layer_dec_count(level)

    def verify_monotonicity(self) -> bool:
        """Verify that layer profits are monotonically increasing."""
        for k in range(len(self.oracles) - 1):
            if self.layer_dec_count(k) > self.layer_dec_count(k + 1):
                return False
        return True


def strategy_dominates(
    s1: Callable[[bool], Bet],
    s2: Callable[[bool], Bet],
    oracle: List[bool]
) -> bool:
    """
    Check if strategy s1 dominates s2 by testing all truth assignments.
    
    For small n, this is exhaustive. For large n, it samples.
    """
    n = len(oracle)
    if n > 20:
        # Sample-based check
        import random
        for _ in range(10000):
            truths = [random.choice([True, False]) for _ in range(n)]
            profit1 = sum(payoff(t, s1(t)) for t in truths)
            profit2 = sum(payoff(t, s2(t)) for t in truths)
            if profit1 < profit2:
                return False
        return True
    else:
        # Exhaustive check
        for mask in range(2 ** n):
            truths = [(mask >> i) & 1 == 1 for i in range(n)]
            profit1 = sum(payoff(t, s1(t)) for t in truths)
            profit2 = sum(payoff(t, s2(t)) for t in truths)
            if profit1 < profit2:
                return False
        return True


def binary_zero_sum_check() -> bool:
    """Verify the binary casino zero-sum property."""
    for bet in [Bet.TRUE, Bet.FALSE]:
        s = payoff(True, bet) + payoff(False, bet)
        if s != 0:
            return False
    return True


if __name__ == '__main__':
    import random
    random.seed(42)
    
    # Create a sample casino
    n = 20
    rounds = [CasinoRound(
        truth=random.choice([True, False]),
        decidable=random.random() < 0.4
    ) for _ in range(n)]
    casino = OracleCasino(rounds)
    
    print("=== Gödel's Casino Algorithms ===\n")
    
    # Verify selective profit
    profit, dec, match = verify_selective_profit(casino)
    print(f"Selective profit: {profit}, Decidable count: {dec}, Match: {match}")
    
    # Verify entropy duality
    e, d, s = verify_entropy_duality(casino)
    print(f"Entropy: {e:.3f}, Dec fraction: {d:.3f}, Sum: {s:.3f}")
    
    # Verify binary zero-sum
    print(f"Binary zero-sum holds: {binary_zero_sum_check()}")
    
    # Test layered casino
    truths = [random.choice([True, False]) for _ in range(n)]
    oracles = []
    decided = set()
    for level in range(5):
        new = set(random.sample(
            [i for i in range(n) if i not in decided],
            min(3, n - len(decided))
        ))
        decided |= new
        oracles.append([i in decided for i in range(n)])
    
    layered = LayeredCasino(truths, oracles)
    print(f"\nLayered casino monotonicity holds: {layered.verify_monotonicity()}")
    for level in range(5):
        print(f"  Level {level}: decidable={layered.layer_dec_count(level)}, "
              f"profit={layered.layer_profit(level)}")
