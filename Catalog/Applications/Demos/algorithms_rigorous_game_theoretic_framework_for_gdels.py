#!/usr/bin/env python3
"""
Gödel's Casino: Core Algorithms

Type-hinted implementations of the key algorithms from the epistemic
game-theoretic framework for Gödel's incompleteness theorems.
"""

from dataclasses import dataclass, field
from typing import List, Dict, Callable, Tuple, Optional
import math


# ============================================================
# Core Data Structures
# ============================================================

@dataclass
class OracleCasino:
    """
    A casino game indexed by positions 0..n-1.
    truth[i] = ground truth of statement i
    oracle[i] = whether the oracle can decide statement i
    """
    truth: List[bool]
    oracle: List[bool]

    @property
    def n(self) -> int:
        return len(self.truth)

    def dec_count(self) -> int:
        """Number of decidable rounds."""
        return sum(1 for o in self.oracle if o)

    def undec_count(self) -> int:
        """Number of undecidable rounds."""
        return self.n - self.dec_count()


@dataclass
class CascadeOracle:
    """
    A sequence of oracles modeling the arithmetic hierarchy.
    level[k] is the set of indices decidable at level k.
    Invariant: level[k] ⊂ level[k+1] for all k.
    """
    truth: List[bool]
    levels: List[List[bool]]  # levels[k][i] = decidable at level k

    @property
    def depth(self) -> int:
        return len(self.levels) - 1

    @property
    def n(self) -> int:
        return len(self.truth)

    def dec_count_at(self, k: int) -> int:
        """Decidable count at level k."""
        return sum(1 for d in self.levels[k] if d)

    def cascade_gap(self, k: int) -> int:
        """Additional decidable rounds from level k to k+1."""
        return self.dec_count_at(k + 1) - self.dec_count_at(k)


@dataclass
class CalibratedCasino:
    """
    A casino where the oracle provides predictions, not just flags.
    Calibration: predictions[i] == truth[i] whenever oracle[i] is True.
    """
    truth: List[bool]
    oracle: List[bool]
    predictions: List[bool]

    def is_calibrated(self) -> bool:
        """Check the calibration condition."""
        return all(self.predictions[i] == self.truth[i]
                   for i in range(len(self.truth))
                   if self.oracle[i])


# ============================================================
# Strategy Algorithms
# ============================================================

def selective_strategy(casino: OracleCasino) -> List[int]:
    """
    The selective strategy: bet correctly on decidable rounds, abstain otherwise.
    Returns list of payoffs: +1 (correct), -1 (wrong), 0 (abstain).

    Time: O(n)
    Space: O(n)
    """
    payoffs = []
    for i in range(casino.n):
        if casino.oracle[i]:
            payoffs.append(1)  # Always correct when decidable
        else:
            payoffs.append(0)  # Abstain
    return payoffs


def omniscient_strategy(casino: OracleCasino) -> List[int]:
    """
    The omniscient strategy: always bets correctly (knows all truth values).
    Returns list of payoffs (always +1).

    Time: O(n)
    """
    return [1] * casino.n


def compute_regret(casino: OracleCasino,
                   payoffs: List[int]) -> Tuple[int, int, int]:
    """
    Decompose strategy regret into components.

    Returns: (total_regret, decidable_mistakes, undecidable_exposure)

    The Regret Decomposition Theorem guarantees:
        total_regret = decidable_mistakes + undecidable_exposure

    Time: O(n)
    """
    total_regret = 0
    dec_mistakes = 0
    undec_exposure = 0

    for i in range(casino.n):
        round_regret = 1 - payoffs[i]
        total_regret += round_regret
        if casino.oracle[i]:
            dec_mistakes += round_regret
        else:
            undec_exposure += round_regret

    return total_regret, dec_mistakes, undec_exposure


# ============================================================
# Oracle Operations
# ============================================================

def oracle_complement(oracle: List[bool]) -> List[bool]:
    """Complement oracle: decides what the original cannot."""
    return [not o for o in oracle]


def oracle_union(o1: List[bool], o2: List[bool]) -> List[bool]:
    """Union oracle: decides whatever either can decide."""
    return [a or b for a, b in zip(o1, o2)]


def oracle_intersection(o1: List[bool], o2: List[bool]) -> List[bool]:
    """Intersection oracle: decides only what both can decide."""
    return [a and b for a, b in zip(o1, o2)]


def verify_inclusion_exclusion(o1: List[bool], o2: List[bool]) -> bool:
    """
    Verify the inclusion-exclusion identity:
    |O₁ ∪ O₂| + |O₁ ∩ O₂| = |O₁| + |O₂|
    """
    count = lambda xs: sum(1 for x in xs if x)
    lhs = count(oracle_union(o1, o2)) + count(oracle_intersection(o1, o2))
    rhs = count(o1) + count(o2)
    return lhs == rhs


def marginal_value(base: List[bool], addition: List[bool]) -> int:
    """
    Marginal value of adding oracle `addition` to `base`.
    By submodularity: marginal_value(base, add) <= standalone_value(add)
    """
    union_count = sum(1 for a, b in zip(base, addition) if a or b)
    base_count = sum(1 for b in base if b)
    return union_count - base_count


# ============================================================
# Cascade Analysis
# ============================================================

def build_cascade(n: int, depth: int,
                  base_fraction: float = 0.2,
                  growth_rate: float = 0.15) -> CascadeOracle:
    """
    Build a cascade oracle with monotonically increasing decidability.

    Parameters:
        n: number of rounds
        depth: number of oracle levels (0 to depth)
        base_fraction: fraction of rounds decidable at level 0
        growth_rate: additional fraction per level

    Returns:
        CascadeOracle with monotone refinement property
    """
    import random

    truth = [random.choice([True, False]) for _ in range(n)]
    levels: List[List[bool]] = []

    prev_set: set = set()
    for k in range(depth + 1):
        # Each level adds some new decidable rounds
        target_count = min(n, int(n * (base_fraction + k * growth_rate)))
        remaining = set(range(n)) - prev_set
        new_count = max(0, target_count - len(prev_set))
        if remaining and new_count > 0:
            new_indices = set(random.sample(list(remaining),
                                            min(new_count, len(remaining))))
        else:
            new_indices = set()
        current_set = prev_set | new_indices
        levels.append([i in current_set for i in range(n)])
        prev_set = current_set

    return CascadeOracle(truth=truth, levels=levels)


def analyze_cascade(cascade: CascadeOracle) -> Dict:
    """
    Analyze a cascade oracle's profit structure.

    Returns dict with:
        - profits: list of profits at each level
        - gaps: list of cascade gaps
        - is_monotone: whether the monotonicity property holds
    """
    profits = [cascade.dec_count_at(k) for k in range(cascade.depth + 1)]
    gaps = [cascade.cascade_gap(k) for k in range(cascade.depth)]

    return {
        'profits': profits,
        'gaps': gaps,
        'is_monotone': all(profits[k] <= profits[k+1]
                          for k in range(cascade.depth)),
        'total_gap': profits[-1] - profits[0],
        'max_possible': cascade.n,
    }


# ============================================================
# Epistemic Advantage Analysis
# ============================================================

def epistemic_advantage(casino: OracleCasino,
                        strategy1_payoffs: List[int],
                        strategy2_payoffs: List[int]) -> int:
    """
    Compute the epistemic advantage of strategy 1 over strategy 2.
    Antisymmetric: advantage(s1, s2) = -advantage(s2, s1)
    """
    return sum(strategy1_payoffs) - sum(strategy2_payoffs)


def entropy_profit_duality(casino: OracleCasino) -> Tuple[float, float]:
    """
    Compute the entropy-profit duality:
    incompleteness_entropy + decidable_fraction = 1.0

    Returns: (entropy, decidable_fraction)
    """
    n = casino.n
    if n == 0:
        return (0.0, 0.0)
    entropy = casino.undec_count() / n
    dec_frac = casino.dec_count() / n
    assert abs(entropy + dec_frac - 1.0) < 1e-10, "Conservation violated!"
    return entropy, dec_frac


# ============================================================
# Main Demo
# ============================================================

if __name__ == "__main__":
    import random
    random.seed(42)

    # Create a sample casino
    n = 100
    casino = OracleCasino(
        truth=[random.choice([True, False]) for _ in range(n)],
        oracle=[random.choice([True, False]) for _ in range(n)]
    )

    print(f"Casino with {n} rounds")
    print(f"Decidable: {casino.dec_count()}, Undecidable: {casino.undec_count()}")

    # Selective strategy
    sel = selective_strategy(casino)
    print(f"Selective profit: {sum(sel)}")
    print(f"Expected (= dec_count): {casino.dec_count()}")

    # Regret decomposition
    regret, dec_m, undec_e = compute_regret(casino, sel)
    print(f"Regret: {regret} = {dec_m} + {undec_e}")

    # Entropy-profit duality
    ent, frac = entropy_profit_duality(casino)
    print(f"Entropy: {ent:.3f}, Decidable fraction: {frac:.3f}, Sum: {ent+frac:.3f}")

    # Cascade
    cascade = build_cascade(n, depth=5)
    analysis = analyze_cascade(cascade)
    print(f"\nCascade analysis: {analysis}")
