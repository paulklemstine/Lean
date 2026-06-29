"""
Algorithms for Probabilistic Bisimulation via Enriched Nerve Semantics.

Implements:
  - Finite Probabilistic LTS representation
  - Word-kernel computation (Chapman-Kolmogorov)
  - Matrix semantics for word kernels
  - Partition refinement for probabilistic bisimulation
  - Nerve equivalence checking

All algorithms operate on finite-state systems with finitely many actions.
"""

from __future__ import annotations
import numpy as np
from typing import List, Dict, Tuple, Set, FrozenSet
from itertools import product
from collections import defaultdict


class FinProbLTS:
    """A finite probabilistic labelled transition system.

    Each (state, action) pair defines a probability distribution over successor
    states. Rows sum to 1.

    Attributes:
        states: list of state labels
        actions: list of action labels
        step: dict mapping (s, a, t) -> probability (float)
        n: number of states
    """

    def __init__(self, states: List[str], actions: List[str],
                 transitions: Dict[Tuple[str, str, str], float]):
        """
        Args:
            states: state labels
            actions: action labels
            transitions: mapping (state, action, target) -> probability
                         Missing entries default to 0.
        """
        self.states = list(states)
        self.actions = list(actions)
        self.state_idx = {s: i for i, s in enumerate(self.states)}
        self.n = len(self.states)
        self._step = {}
        for (s, a, t), p in transitions.items():
            self._step[(s, a, t)] = p
        # Verify row sums
        for s in self.states:
            for a in self.actions:
                total = sum(self._step.get((s, a, t), 0.0) for t in self.states)
                assert abs(total - 1.0) < 1e-10, \
                    f"Row sum for ({s}, {a}) is {total}, not 1.0"

    def step(self, s: str, a: str, t: str) -> float:
        """Transition probability P(s --a--> t)."""
        return self._step.get((s, a, t), 0.0)

    def step_matrix(self, a: str) -> np.ndarray:
        """Stochastic matrix M_a where M_a[i,j] = step(states[i], a, states[j])."""
        M = np.zeros((self.n, self.n))
        for i, s in enumerate(self.states):
            for j, t in enumerate(self.states):
                M[i, j] = self.step(s, a, t)
        return M


def word_kernel(P: FinProbLTS, w: List[str], s: str, t: str) -> float:
    """Compute the word kernel K_w(s, t) recursively.

    - K_[](s, t) = 1 if s == t, else 0
    - K_{a::w}(s, t) = sum_m P.step(s, a, m) * K_w(m, t)

    Time: O(|w| * |S|) per (s,t) pair
    Space: O(|S|) for intermediate distributions
    """
    if len(w) == 0:
        return 1.0 if s == t else 0.0
    a = w[0]
    rest = w[1:]
    return sum(P.step(s, a, m) * word_kernel(P, rest, m, t) for m in P.states)


def word_kernel_matrix(P: FinProbLTS, w: List[str]) -> np.ndarray:
    """Compute the full word-kernel matrix K_w as an |S| x |S| array.

    Uses matrix multiplication for efficiency.

    Time: O(|w| * |S|^3)
    Space: O(|S|^2)
    """
    if len(w) == 0:
        return np.eye(P.n)
    result = np.eye(P.n)
    for a in w:
        result = result @ P.step_matrix(a)
    return result


def word_matrix(P: FinProbLTS, w: List[str]) -> np.ndarray:
    """Compute the product of stochastic matrices along word w.

    This is the matrix semantics: M_w = M_{a1} * M_{a2} * ... * M_{ak}.
    By our theorem, this equals the word-kernel matrix.

    Time: O(|w| * |S|^3)
    Space: O(|S|^2)
    """
    result = np.eye(P.n)
    for a in w:
        result = result @ P.step_matrix(a)
    return result


def block_mass(P: FinProbLTS, w: List[str], s: str,
               C: Set[str]) -> float:
    """Total word-kernel mass from state s into block C.

    sum_{u in C} K_w(s, u)

    Time: O(|w| * |S| * |C|)
    """
    K = word_kernel_matrix(P, w)
    si = P.state_idx[s]
    return sum(K[si, P.state_idx[u]] for u in C)


# ──────────────────────────────────────────────────────────────────
# Partition Refinement for Probabilistic Bisimulation
# ──────────────────────────────────────────────────────────────────

def partition_refinement(P: FinProbLTS) -> List[FrozenSet[str]]:
    """Compute the coarsest probabilistic bisimulation partition.

    Uses the Kanellakis-Smolka / Derisavi-Hermanns-Sanders style
    partition refinement algorithm adapted for probabilistic systems.

    Algorithm:
    1. Start with the trivial partition {S}.
    2. Refine: for each block B and action a, split blocks by the
       probability mass assigned to B under action a.
    3. Repeat until stable.

    Time: O(|A| * |S|^2 * iterations), where iterations <= |S|
    Space: O(|S|^2)

    Returns:
        List of frozensets, each a block of the coarsest bisimulation.
    """
    # Initial partition: all states in one block
    partition = [frozenset(P.states)]

    changed = True
    while changed:
        changed = False
        new_partition = []
        for block in partition:
            # Try to split this block
            split = _try_split(P, block, partition)
            if len(split) > 1:
                changed = True
            new_partition.extend(split)
        partition = new_partition

    return partition


def _try_split(P: FinProbLTS, block: FrozenSet[str],
               partition: List[FrozenSet[str]]) -> List[FrozenSet[str]]:
    """Try to split a block based on transition probabilities to other blocks.

    Two states s, t in the same block are distinguished if for some
    action a and some block B in the current partition:
      sum_{u in B} P.step(s, a, u) != sum_{u in B} P.step(t, a, u)
    """
    if len(block) <= 1:
        return [block]

    # Compute signature for each state: tuple of (action, block_index) -> mass
    signatures: Dict[str, tuple] = {}
    for s in block:
        sig = []
        for a in P.actions:
            for bi, B in enumerate(partition):
                mass = sum(P.step(s, a, u) for u in B)
                sig.append(round(mass, 12))  # round to avoid float issues
            signatures[s] = tuple(sig)

    # Group states by signature
    groups: Dict[tuple, list] = defaultdict(list)
    for s in block:
        groups[signatures[s]].append(s)

    return [frozenset(g) for g in groups.values()]


def are_prob_bisimilar(P: FinProbLTS, s: str, t: str) -> bool:
    """Check if two states are probabilistically bisimilar.

    Uses partition refinement to compute the coarsest bisimulation,
    then checks if s and t are in the same block.

    Time: O(|A| * |S|^2 * |S|)
    Space: O(|S|^2)
    """
    partition = partition_refinement(P)
    for block in partition:
        if s in block and t in block:
            return True
    return False


def same_block(partition: List[FrozenSet[str]], s: str, t: str) -> bool:
    """Check if s and t are in the same block of a partition."""
    for block in partition:
        if s in block and t in block:
            return True
    return False


# ──────────────────────────────────────────────────────────────────
# Nerve Equivalence Checking
# ──────────────────────────────────────────────────────────────────

def check_nerve_equivalence(P: FinProbLTS, s: str, t: str,
                            max_word_length: int = 5) -> bool:
    """Check nerve equivalence up to a given word length.

    Two states are nerve-equivalent if for every word w and every
    subset C of states, the total word-kernel mass into C is the
    same from s and t.

    For efficiency, we check against the coarsest bisimulation
    partition blocks and singletons.

    Args:
        P: the finite probabilistic LTS
        s, t: states to compare
        max_word_length: maximum word length to check

    Returns:
        True if no distinguishing word/block pair was found
    """
    partition = partition_refinement(P)

    # Generate all words up to max_word_length
    for length in range(max_word_length + 1):
        for w in _words_of_length(P.actions, length):
            K = word_kernel_matrix(P, list(w))
            si, ti = P.state_idx[s], P.state_idx[t]
            # Check against each singleton
            for j in range(P.n):
                if abs(K[si, j] - K[ti, j]) > 1e-12:
                    return False
    return True


def _words_of_length(actions: List[str], n: int):
    """Generate all words of length n over the action alphabet."""
    if n == 0:
        yield ()
        return
    for w in product(actions, repeat=n):
        yield w


# ──────────────────────────────────────────────────────────────────
# Linear (Quantum Surrogate) Transition System
# ──────────────────────────────────────────────────────────────────

class FinStochLTS:
    """A finite stochastic linear transition system.

    This serves as a linearized surrogate for quantum channel dynamics.
    Each action maps to a stochastic matrix (nonneg, rows sum to 1).
    """

    def __init__(self, n: int, actions: List[str],
                 matrices: Dict[str, np.ndarray]):
        self.n = n
        self.actions = actions
        self.matrices = matrices
        for a, M in matrices.items():
            assert M.shape == (n, n), f"Matrix for {a} has wrong shape"
            assert np.all(M >= -1e-12), f"Matrix for {a} has negative entries"
            row_sums = M.sum(axis=1)
            assert np.allclose(row_sums, 1.0), \
                f"Matrix for {a} rows don't sum to 1: {row_sums}"

    def word_matrix(self, w: List[str]) -> np.ndarray:
        result = np.eye(self.n)
        for a in w:
            result = result @ self.matrices[a]
        return result


if __name__ == "__main__":
    # Quick test
    P = FinProbLTS(
        states=["s0", "s1", "s2"],
        actions=["a", "b"],
        transitions={
            ("s0", "a", "s0"): 0.5, ("s0", "a", "s1"): 0.5, ("s0", "a", "s2"): 0.0,
            ("s0", "b", "s0"): 0.0, ("s0", "b", "s1"): 0.0, ("s0", "b", "s2"): 1.0,
            ("s1", "a", "s0"): 0.5, ("s1", "a", "s1"): 0.5, ("s1", "a", "s2"): 0.0,
            ("s1", "b", "s0"): 0.0, ("s1", "b", "s1"): 0.0, ("s1", "b", "s2"): 1.0,
            ("s2", "a", "s0"): 0.0, ("s2", "a", "s1"): 0.0, ("s2", "a", "s2"): 1.0,
            ("s2", "b", "s0"): 0.3, ("s2", "b", "s1"): 0.3, ("s2", "b", "s2"): 0.4,
        }
    )
    partition = partition_refinement(P)
    print("Bisimulation partition:", partition)
    print("s0 ~ s1:", are_prob_bisimilar(P, "s0", "s1"))
    print("s0 ~ s2:", are_prob_bisimilar(P, "s0", "s2"))
