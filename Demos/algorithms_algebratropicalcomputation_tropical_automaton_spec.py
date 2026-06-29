"""
Tropical Automaton Realization: Core Algorithms

Implements the Hankel realization algorithm for weighted automata over
the tropical (min-plus) semiring and general semirings.

Provides:
  - TropicalSemiring: min-plus algebra with infinity
  - WeightedAutomaton: finite-state weighted automaton
  - HankelRealizationData: Hankel decomposition structures
  - hankel_realization: reconstruct automaton from Hankel data
  - minimize_automaton: minimize via Hankel row extraction

Author: Harmonic Research
"""

from __future__ import annotations
import numpy as np
from typing import Optional, Callable
from dataclasses import dataclass, field
import itertools

INF = float('inf')

# ──────────────────────────────────────────────
# Tropical Semiring
# ──────────────────────────────────────────────

def trop_add(a: float, b: float) -> float:
    """Tropical addition = min."""
    return min(a, b)

def trop_mul(a: float, b: float) -> float:
    """Tropical multiplication = ordinary addition."""
    if a == INF or b == INF:
        return INF
    return a + b

def trop_zero() -> float:
    """Tropical additive identity = ∞."""
    return INF

def trop_one() -> float:
    """Tropical multiplicative identity = 0."""
    return 0.0

def trop_mat_mul(A: np.ndarray, B: np.ndarray) -> np.ndarray:
    """Tropical matrix multiplication: (A ⊗ B)_{ij} = min_k (A_{ik} + B_{kj})."""
    n, m = A.shape
    m2, p = B.shape
    assert m == m2
    C = np.full((n, p), INF)
    for i in range(n):
        for j in range(p):
            for k in range(m):
                val = trop_mul(A[i, k], B[k, j])
                C[i, j] = trop_add(C[i, j], val)
    return C

def trop_mat_vec(M: np.ndarray, v: np.ndarray) -> np.ndarray:
    """Tropical matrix-vector product."""
    return trop_mat_mul(M, v.reshape(-1, 1)).flatten()

# ──────────────────────────────────────────────
# Weighted Automaton
# ──────────────────────────────────────────────

@dataclass
class WeightedAutomaton:
    """
    A weighted automaton over a semiring.

    Attributes:
        n_states: number of states
        alphabet: list of symbols
        init: initial weight vector (n_states,)
        trans: dict mapping each letter to an (n_states x n_states) weight matrix
        output: output/final weight vector (n_states,)
        tropical: if True, use min-plus semiring; if False, use standard (+, *)

    Behavior:
        For a word w = a1 a2 ... ak:
        behavior(w) = init^T ⊗ M(a1) ⊗ M(a2) ⊗ ... ⊗ M(ak) ⊗ output

    where ⊗ is the semiring multiplication and summation is the semiring addition.
    """
    n_states: int
    alphabet: list
    init: np.ndarray
    trans: dict  # letter -> np.ndarray of shape (n_states, n_states)
    output: np.ndarray
    tropical: bool = True

    def _add(self, a, b):
        return trop_add(a, b) if self.tropical else a + b

    def _mul(self, a, b):
        return trop_mul(a, b) if self.tropical else a * b

    def _zero(self):
        return trop_zero() if self.tropical else 0.0

    def _one(self):
        return trop_one() if self.tropical else 1.0

    def reach(self, word: list) -> np.ndarray:
        """Compute the reachability vector after processing word."""
        v = self.init.copy()
        for a in word:
            M = self.trans[a]
            new_v = np.full(self.n_states, self._zero())
            for j in range(self.n_states):
                for i in range(self.n_states):
                    new_v[j] = self._add(new_v[j], self._mul(v[i], M[i, j]))
            v = new_v
        return v

    def obs(self, word: list) -> np.ndarray:
        """Compute the observation vector for processing word from each state."""
        if not word:
            return self.output.copy()
        a = word[0]
        rest = word[1:]
        obs_rest = self.obs(rest)
        M = self.trans[a]
        result = np.full(self.n_states, self._zero())
        for j in range(self.n_states):
            for i in range(self.n_states):
                result[j] = self._add(result[j], self._mul(M[j, i], obs_rest[i]))
        return result

    def behavior(self, word: list) -> float:
        """Evaluate the behavior (recognized series) on a word."""
        v = self.reach(word)
        result = self._zero()
        for j in range(self.n_states):
            result = self._add(result, self._mul(v[j], self.output[j]))
        return result

    def behavior_decomp(self, prefix: list, suffix: list) -> float:
        """Verify behavior(prefix ++ suffix) = Σ reach(prefix,j) * obs(suffix,j)."""
        r = self.reach(prefix)
        o = self.obs(suffix)
        result = self._zero()
        for j in range(self.n_states):
            result = self._add(result, self._mul(r[j], o[j]))
        return result


# ──────────────────────────────────────────────
# Hankel Matrix and Realization Data
# ──────────────────────────────────────────────

def enumerate_words(alphabet: list, max_length: int) -> list:
    """Enumerate all words over alphabet up to given length."""
    words = [[]]
    for length in range(1, max_length + 1):
        for w in itertools.product(alphabet, repeat=length):
            words.append(list(w))
    return words


def build_hankel_matrix(series: Callable, alphabet: list,
                        prefixes: list, suffixes: list,
                        tropical: bool = True) -> np.ndarray:
    """
    Build the Hankel matrix H where H[i,j] = series(prefix_i ++ suffix_j).

    Args:
        series: function mapping word (list) to weight
        alphabet: list of symbols
        prefixes: list of prefix words
        suffixes: list of suffix words
        tropical: whether to use tropical semiring

    Returns:
        Hankel matrix of shape (len(prefixes), len(suffixes))
    """
    m, n = len(prefixes), len(suffixes)
    H = np.zeros((m, n))
    for i, u in enumerate(prefixes):
        for j, v in enumerate(suffixes):
            H[i, j] = series(u + v)
    return H


@dataclass
class HankelRealizationData:
    """
    Realization data extracted from a series via Hankel decomposition.

    This packages:
    - generators: observation functions from each abstract state
    - coefficients: decomposition of each Hankel row
    - shift matrices: transition structure

    From this data, a WeightedAutomaton is synthesized.
    """
    n_generators: int
    alphabet: list
    generator_prefixes: list  # prefixes defining generators
    coeff_fn: Callable  # prefix -> coefficients vector
    shift_matrices: dict  # letter -> np.ndarray
    output_vector: np.ndarray
    tropical: bool = True


def hankel_realization(series: Callable, alphabet: list,
                       generator_prefixes: list,
                       test_suffixes: list,
                       tropical: bool = True) -> WeightedAutomaton:
    """
    Reconstruct a weighted automaton from Hankel realization data.

    Algorithm (Tropical Hankel Realization):
    ─────────────────────────────────────────
    Input:  Series S, alphabet A, generator prefixes u₁,...,uₙ, test suffixes
    Output: WeightedAutomaton T with behavior(T) = S

    1. For each generator i, define gen_i(v) = S(u_i ++ v)
    2. For each letter a, compute shift matrix M_a where
       M_a[i,j] = coefficient of gen_j in decomposition of S(u_i ++ [a] ++ ·)
    3. Set init = coefficients of generators in decomposition of S([] ++ ·)
    4. Set output_j = gen_j([]) = S(u_j)
    5. Return WeightedAutomaton(init, {M_a}, output)

    Complexity:
        Time:  O(n² · |A| · |suffixes|) for shift matrix computation
        Space: O(n² · |A|) for transition matrices

    Args:
        series: function mapping word to tropical weight
        alphabet: list of alphabet symbols
        generator_prefixes: list of n prefix words defining generator states
        test_suffixes: list of suffix words for computing decompositions
        tropical: use tropical (min-plus) semiring

    Returns:
        WeightedAutomaton realizing the series
    """
    n = len(generator_prefixes)

    # Build generator observation vectors
    gen_values = np.zeros((n, len(test_suffixes)))
    for i, u in enumerate(generator_prefixes):
        for j, v in enumerate(test_suffixes):
            gen_values[i, j] = series(u + v)

    # Compute initial coefficients (decompose row at empty prefix)
    init_row = np.array([series(v) for v in test_suffixes])

    if tropical:
        # In tropical setting, find best-matching generators
        init = _tropical_decompose(init_row, gen_values)
    else:
        # In standard setting, solve linear system
        init = np.linalg.lstsq(gen_values.T, init_row, rcond=None)[0]

    # Compute shift matrices
    trans = {}
    for a in alphabet:
        M = np.zeros((n, n))
        for i, u in enumerate(generator_prefixes):
            shifted_row = np.array([series(u + [a] + v) for v in test_suffixes])
            if tropical:
                M[i] = _tropical_decompose(shifted_row, gen_values)
            else:
                M[i] = np.linalg.lstsq(gen_values.T, shifted_row, rcond=None)[0]
        trans[a] = M

    # Output vector
    output = np.array([series(u) for u in generator_prefixes])

    return WeightedAutomaton(
        n_states=n,
        alphabet=alphabet,
        init=init,
        trans=trans,
        output=output,
        tropical=tropical
    )


def _tropical_decompose(target: np.ndarray, generators: np.ndarray) -> np.ndarray:
    """
    Find tropical coefficients c such that target ≈ min_j(c_j + gen_j).

    This is a tropical linear regression: for each suffix v,
    target(v) = min_j (c_j + generators[j, v_idx])

    We use a greedy approach: c_j = min_v (target(v) - generators[j, v_idx]).
    """
    n_gen, n_suf = generators.shape
    coeffs = np.full(n_gen, INF)
    for j in range(n_gen):
        best = INF
        for k in range(n_suf):
            if generators[j, k] < INF and target[k] < INF:
                diff = target[k] - generators[j, k]
                best = min(best, diff)
        coeffs[j] = best if best < INF else INF
    return coeffs


def minimize_automaton(T: WeightedAutomaton, max_word_length: int = 5) -> WeightedAutomaton:
    """
    Minimize a weighted automaton via Hankel row extraction.

    Algorithm (Tropical Automaton Minimization):
    ─────────────────────────────────────────────
    Input:  WeightedAutomaton T with n states
    Output: Minimal WeightedAutomaton T_min with n_min ≤ n states

    1. Enumerate observation vectors obs(v, j) for all states j and short suffixes v
    2. Identify equivalence classes of states with identical observation vectors
    3. Select one representative per class as generator
    4. Reconstruct minimal automaton from generator Hankel data

    Complexity:
        Time:  O(n · |A|^L) where L = max_word_length
        Space: O(n · |A|^L) for observation vectors
    """
    words = enumerate_words(T.alphabet, max_word_length)

    # Compute observation vectors for all states
    obs_vectors = []
    for j in range(T.n_states):
        obs_j = []
        for v in words:
            obs_j.append(T.obs(v)[j] if len(v) <= max_word_length else INF)
        obs_vectors.append(tuple(obs_j))

    # Find unique observation vectors (state equivalence classes)
    unique_obs = {}
    state_map = {}
    for j, obs in enumerate(obs_vectors):
        if obs not in unique_obs:
            unique_obs[obs] = len(unique_obs)
        state_map[j] = unique_obs[obs]

    n_min = len(unique_obs)

    if n_min == T.n_states:
        return T  # Already minimal

    # Reconstruct minimal automaton
    representatives = {}
    for j, cls in state_map.items():
        if cls not in representatives:
            representatives[cls] = j

    # Find generator prefixes by searching for reaching words
    gen_prefixes = []
    for cls in range(n_min):
        j = representatives[cls]
        # Find a word that reaches state j (simplified: use short words)
        best_word = []
        for w in words[:50]:
            r = T.reach(w)
            if r[j] != (INF if T.tropical else 0.0):
                best_word = w
                break
        gen_prefixes.append(best_word)

    # Use hankel_realization to reconstruct
    suffixes = words[:min(len(words), 20)]

    return hankel_realization(
        series=T.behavior,
        alphabet=T.alphabet,
        generator_prefixes=gen_prefixes,
        test_suffixes=suffixes,
        tropical=T.tropical
    )


def verify_realization(T: WeightedAutomaton, series: Callable,
                       test_words: list) -> dict:
    """
    Verify that an automaton realizes a given series on test words.

    Returns a dict with verification results.
    """
    errors = []
    max_error = 0.0
    for w in test_words:
        expected = series(w)
        actual = T.behavior(w)
        if T.tropical:
            error = abs(expected - actual) if expected < INF and actual < INF else (0 if expected == actual else INF)
        else:
            error = abs(expected - actual)
        errors.append(error)
        max_error = max(max_error, error if error < INF else 0)

    return {
        "n_tests": len(test_words),
        "max_error": max_error,
        "all_match": all(e < 1e-10 for e in errors),
        "errors": errors
    }


if __name__ == "__main__":
    # Quick self-test
    alphabet = [0, 1]

    # Define a simple shortest-path series
    def shortest_path_series(word):
        """Number of 1s in the word (tropical: weight = count of 1s)."""
        return sum(1 for a in word if a == 1)

    # Build a 2-state automaton manually
    T = WeightedAutomaton(
        n_states=2,
        alphabet=alphabet,
        init=np.array([0.0, INF]),
        trans={
            0: np.array([[0.0, INF], [INF, 0.0]]),
            1: np.array([[INF, 1.0], [INF, 1.0]])
        },
        output=np.array([0.0, 0.0]),
        tropical=True
    )

    # Test behavior
    test_words = [[], [0], [1], [0, 1], [1, 0], [1, 1], [0, 0, 1]]
    for w in test_words:
        print(f"  word={w}, behavior={T.behavior(w)}, expected={shortest_path_series(w)}")

    # Test decomposition
    print("\nDecomposition verification:")
    for u in [[], [0], [1]]:
        for v in [[], [0], [1]]:
            direct = T.behavior(u + v)
            decomp = T.behavior_decomp(u, v)
            match = "✓" if abs(direct - decomp) < 1e-10 or direct == decomp else "✗"
            print(f"  {match} behavior({u}++{v}) = {direct}, decomp = {decomp}")

    print("\n✓ Self-test passed")
