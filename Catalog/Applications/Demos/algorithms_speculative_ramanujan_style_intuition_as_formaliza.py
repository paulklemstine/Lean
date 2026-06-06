#!/usr/bin/env python3
"""
Ramanujan Oracle: Algorithms

Type-hinted implementations of the core oracle algorithms formalized in Lean 4.
"""

from typing import Callable, List, Optional, Tuple
from enum import Enum
from dataclasses import dataclass
import math


class OracleResponse(Enum):
    """The three possible responses of a Ramanujan oracle."""
    AFFIRM = "affirm"
    DENY = "deny"
    ABSTAIN = "abstain"


# Type aliases
Oracle = Callable[[int], OracleResponse]
TruthAssignment = Callable[[int], bool]


def oracle_correct_on(response: OracleResponse, truth: bool) -> bool:
    """Check if an oracle response is correct for a given truth value.
    
    Affirm matches True, Deny matches False, Abstain is never correct.
    """
    if response == OracleResponse.AFFIRM and truth:
        return True
    if response == OracleResponse.DENY and not truth:
        return True
    return False


def oracle_accuracy_count(oracle: Oracle, truth: TruthAssignment, 
                          domain: List[int]) -> int:
    """Count the number of correct oracle predictions on a domain.
    
    This implements the formal `oracleAccuracyCount` from Lean.
    """
    return sum(1 for s in domain if oracle_correct_on(oracle(s), truth(s)))


def disagreement_count(oracle: Oracle, truth: TruthAssignment,
                       domain: List[int]) -> int:
    """Count disagreements = |domain| - accuracy_count.
    
    Formally verified: accuracy + disagreement = |domain|.
    """
    return len(domain) - oracle_accuracy_count(oracle, truth, domain)


def is_binary_oracle(oracle: Oracle, domain: List[int]) -> bool:
    """Check if an oracle never abstains on the given domain."""
    return all(oracle(s) != OracleResponse.ABSTAIN for s in domain)


def binary_oracle_to_assignment(oracle: Oracle) -> TruthAssignment:
    """Convert a binary oracle to the unique truth assignment it matches.
    
    Formally verified: this is the unique assignment achieving 100% accuracy.
    """
    def assignment(s: int) -> bool:
        return oracle(s) == OracleResponse.AFFIRM
    return assignment


def oracle_jump(oracle: Oracle) -> Oracle:
    """Compute the jump of an oracle.
    
    The jump negates every response (affirm↔deny, abstain→affirm).
    Formally verified properties:
    - jump_disagrees: jump always differs from source on non-abstentions
    - jump_is_binary: jump never abstains
    """
    def jumped(s: int) -> OracleResponse:
        r = oracle(s)
        if r == OracleResponse.AFFIRM:
            return OracleResponse.DENY
        elif r == OracleResponse.DENY:
            return OracleResponse.AFFIRM
        else:
            return OracleResponse.AFFIRM
    return jumped


def iterated_jump(oracle: Oracle, n: int) -> Oracle:
    """Compute the n-th iterated jump.
    
    jump^0(f) = f, jump^(n+1)(f) = jump(jump^n(f)).
    Formally verified: jump_hierarchy_noncollapse shows consecutive
    levels always differ.
    """
    result = oracle
    for _ in range(n):
        result = oracle_jump(result)
    return result


def oracle_compose(primary: Oracle, fallback: Oracle) -> Oracle:
    """Compose two oracles: use primary, fall back on abstention.
    
    Formally verified: if fallback is binary, composition is binary.
    """
    def composed(s: int) -> OracleResponse:
        r = primary(s)
        if r == OracleResponse.ABSTAIN:
            return fallback(s)
        return r
    return composed


def cantor_diagonal_defeater(family: List[Oracle]) -> TruthAssignment:
    """Construct a truth assignment that defeats every oracle in the family.
    
    For oracle n, looks at its response on statement n (the diagonal)
    and chooses the opposite truth value.
    
    Formally verified: cantor_diagonal_oracle proves this construction
    defeats every oracle on its diagonal statement.
    """
    def defeater(n: int) -> bool:
        if n < len(family):
            r = family[n](n)
            if r == OracleResponse.AFFIRM:
                return False
            else:
                return True
        return True
    return defeater


def oracle_space_cardinality(N: int) -> int:
    """Number of possible oracles on N statements: 3^N.
    
    Formally verified: finite_oracle_space_card.
    """
    return 3 ** N


def truth_space_cardinality(N: int) -> int:
    """Number of possible truth assignments on N statements: 2^N.
    
    Formally verified: finite_truth_space_card.
    """
    return 2 ** N


def computable_oracle_ratio(b: int, n: int) -> float:
    """Ratio of computable oracles to all oracles.
    
    At most b^n programs of length n, but 3^(b^n) possible oracles.
    Formally verified: computable_oracle_ratio_bound shows b^n ≤ 3^(b^n).
    """
    programs = b ** n
    total = 3 ** (b ** n)
    if total == 0:
        return 0.0
    return programs / total


def abstention_coverage(k: int) -> int:
    """Number of truth assignments compatible with k abstentions: 2^k.
    
    Formally verified: abstention_coverage shows 1 ≤ 2^k.
    A binary oracle matches exactly 1 assignment; abstaining on k
    statements multiplies compatibility by 2^k.
    """
    return 2 ** k


@dataclass
class OracleAnalysis:
    """Analysis of an oracle's performance against a truth assignment."""
    accuracy: int
    disagreements: int
    domain_size: int
    accuracy_rate: float
    is_binary: bool
    abstention_count: int


def analyze_oracle(oracle: Oracle, truth: TruthAssignment,
                   domain: List[int]) -> OracleAnalysis:
    """Comprehensive analysis of oracle performance."""
    acc = oracle_accuracy_count(oracle, truth, domain)
    dis = disagreement_count(oracle, truth, domain)
    n = len(domain)
    abstentions = sum(1 for s in domain if oracle(s) == OracleResponse.ABSTAIN)
    return OracleAnalysis(
        accuracy=acc,
        disagreements=dis,
        domain_size=n,
        accuracy_rate=acc / n if n > 0 else 0.0,
        is_binary=is_binary_oracle(oracle, domain),
        abstention_count=abstentions
    )


if __name__ == "__main__":
    # Quick demonstration
    N = 10
    domain = list(range(N))
    
    # Create a simple oracle
    oracle = lambda s: OracleResponse.AFFIRM if s % 2 == 0 else OracleResponse.DENY
    truth = lambda s: s % 2 == 0  # true for evens
    
    analysis = analyze_oracle(oracle, truth, domain)
    print(f"Oracle analysis: {analysis}")
    print(f"Oracle space for N={N}: {oracle_space_cardinality(N)}")
    print(f"Truth space for N={N}: {truth_space_cardinality(N)}")
    print(f"Computable ratio for b=2, n=5: {computable_oracle_ratio(2, 5):.2e}")
