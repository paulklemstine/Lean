"""
Retrocausal Proof Theory: Core Algorithms

Implements the retrocausal proof search framework including:
- Hypothesis space and consequence oracle representations
- Candidate narrowing (consequence verification)
- Retrocausal search with unique survivor detection
- Adaptive consequence selection (greedy)
- Compression factor computation and conjecture testing
"""

from typing import List, Set, Tuple, Optional, Callable
import numpy as np
from dataclasses import dataclass


@dataclass
class HypothesisSpace:
    """A finite universe of candidate propositions over worlds.
    
    eval[h, w] = True iff hypothesis h holds in world w.
    """
    n: int  # number of hypotheses
    m: int  # number of worlds
    eval: np.ndarray  # shape (n, m), dtype bool

    @staticmethod
    def random(n: int, m: int, density: float = 0.5) -> 'HypothesisSpace':
        """Generate a random hypothesis space."""
        return HypothesisSpace(
            n=n, m=m,
            eval=np.random.random((n, m)) < density
        )


@dataclass
class ConsequenceOracle:
    """A mechanism for testing consequences in worlds.
    
    test[c, w] = True iff consequence c holds in world w.
    """
    k: int  # number of consequences
    m: int  # number of worlds
    test: np.ndarray  # shape (k, m), dtype bool

    @staticmethod
    def random(k: int, m: int, density: float = 0.5) -> 'ConsequenceOracle':
        """Generate a random consequence oracle."""
        return ConsequenceOracle(
            k=k, m=m,
            test=np.random.random((k, m)) < density
        )


def is_consistent_with(hs: HypothesisSpace, co: ConsequenceOracle,
                       h: int, c: int) -> bool:
    """Check if hypothesis h is consistent with consequence c.
    
    h is consistent with c iff for every world w where h holds, c also holds.
    This models the implication h → c.
    """
    h_worlds = hs.eval[h]  # worlds where h holds
    c_worlds = co.test[c]  # worlds where c holds
    # h → c means: wherever h is True, c must also be True
    return bool(np.all(~h_worlds | c_worlds))


def candidates_consistent_with(hs: HypothesisSpace, co: ConsequenceOracle,
                                consequences: Set[int]) -> Set[int]:
    """Return the set of hypotheses consistent with ALL given consequences.
    
    This is the core narrowing operation: each additional consequence
    can only shrink or maintain the candidate set.
    """
    candidates = set()
    for h in range(hs.n):
        if all(is_consistent_with(hs, co, h, c) for c in consequences):
            candidates.add(h)
    return candidates


def retrocausal_search(hs: HypothesisSpace, co: ConsequenceOracle,
                       consequences: List[int]) -> Tuple[Set[int], int]:
    """Run retrocausal search: verify consequences and narrow candidates.
    
    Returns:
        candidates: remaining candidate set
        steps: number of consequences verified before termination
    """
    candidates = set(range(hs.n))
    for step, c in enumerate(consequences):
        candidates = {h for h in candidates
                      if is_consistent_with(hs, co, h, c)}
        if len(candidates) <= 1:
            return candidates, step + 1
    return candidates, len(consequences)


def adaptive_consequence_selection(
    hs: HypothesisSpace, co: ConsequenceOracle,
    available_consequences: Set[int]
) -> List[int]:
    """Greedily select consequences that maximize candidate elimination.
    
    At each step, selects the consequence that eliminates the most candidates.
    Returns the ordered list of selected consequences.
    """
    candidates = set(range(hs.n))
    remaining = set(available_consequences)
    selected: List[int] = []

    while len(candidates) > 1 and remaining:
        best_c = -1
        best_eliminated = -1
        for c in remaining:
            new_candidates = {h for h in candidates
                              if is_consistent_with(hs, co, h, c)}
            eliminated = len(candidates) - len(new_candidates)
            if eliminated > best_eliminated:
                best_eliminated = eliminated
                best_c = c
        if best_c == -1 or best_eliminated == 0:
            break
        remaining.discard(best_c)
        selected.append(best_c)
        candidates = {h for h in candidates
                      if is_consistent_with(hs, co, h, best_c)}
    return selected


def compression_factor(n: int, k: int) -> int:
    """Maximum compression from k consequences over n hypotheses."""
    return min(n, 2 ** k)


def proof_search_reduction(hs: HypothesisSpace, co: ConsequenceOracle,
                           consequences: Set[int]) -> int:
    """Number of eliminated candidates after consequence verification."""
    return hs.n - len(candidates_consistent_with(hs, co, consequences))


def test_compression_conjecture(n: int, k: int, m: int,
                                 trials: int = 1000) -> dict:
    """Test the retrocausal compression conjecture.
    
    Conjecture: For random hypothesis spaces of size n with k independent
    binary consequences, |candidates after full verification| ≤ n/2^k + 1.
    
    Returns:
        dict with keys: mean_survivors, max_survivors, conjecture_holds_pct,
                        theoretical_bound
    """
    bound = n // (2 ** k) + 1
    survivors_list = []
    violations = 0

    for _ in range(trials):
        hs = HypothesisSpace.random(n, m)
        co = ConsequenceOracle.random(k, m)
        all_consequences = set(range(k))
        candidates = candidates_consistent_with(hs, co, all_consequences)
        num_survivors = len(candidates)
        survivors_list.append(num_survivors)
        if num_survivors > bound:
            violations += 1

    return {
        'n': n,
        'k': k,
        'm': m,
        'trials': trials,
        'theoretical_bound': bound,
        'mean_survivors': np.mean(survivors_list),
        'max_survivors': max(survivors_list),
        'conjecture_holds_pct': 100.0 * (1 - violations / trials),
    }


def consequence_depth(succ: Callable[[int], Set[int]],
                      verified: Set[int], x: int) -> int:
    """Compute the consequence depth of element x.
    
    Depth is 0 if x is not verified, otherwise 1 + number of verified successors.
    """
    if x not in verified:
        return 0
    return 1 + len(succ(x) & verified)


def is_consequence_stable(hs: HypothesisSpace, co: ConsequenceOracle,
                          verified: Set[int]) -> bool:
    """Check if the verified consequence set is stable.
    
    Stable means adding any new consequence doesn't change the candidates.
    """
    current = candidates_consistent_with(hs, co, verified)
    for c in range(co.k):
        if c not in verified:
            extended = candidates_consistent_with(hs, co, verified | {c})
            if extended != current:
                return False
    return True


def is_self_certifying(hs: HypothesisSpace, co: ConsequenceOracle,
                       target: int) -> Optional[Set[int]]:
    """Check if target hypothesis is self-certifying.
    
    Returns the minimal consequence set that uniquely determines target,
    or None if target is not self-certifying.
    """
    # Try all subsets of consequences (brute force for small k)
    from itertools import combinations
    for size in range(1, co.k + 1):
        for subset in combinations(range(co.k), size):
            candidates = candidates_consistent_with(hs, co, set(subset))
            if candidates == {target}:
                return set(subset)
    return None
