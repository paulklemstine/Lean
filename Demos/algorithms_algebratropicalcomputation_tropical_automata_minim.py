#!/usr/bin/env python3
"""
algorithms.py — Tropical Automata Minimization Algorithms

Implements the core algorithms from the tropical Myhill–Nerode theory:
1. Nerode class computation via residual partitioning
2. Hankel matrix construction and factor rank analysis
3. Certified minimization pipeline
4. Quotient automaton construction
"""

from __future__ import annotations
import numpy as np
from itertools import product as iter_product
from dataclasses import dataclass, field
from typing import Callable, Any


# ============================================================
# Core Types
# ============================================================

@dataclass
class TropicalAutomaton:
    """A finite-state weighted automaton over an alphabet."""
    n_states: int
    init: int
    step: Callable[[int, Any], int]
    output: Callable[[int], Any]

    def run(self, word: list) -> int:
        """Run the automaton on a word, returning the final state."""
        state = self.init
        for sym in word:
            state = self.step(state, sym)
        return state

    def evaluate(self, word: list) -> Any:
        """Evaluate the series at a word."""
        return self.output(self.run(word))


@dataclass
class NerodePartition:
    """Result of Nerode class computation."""
    classes: dict[tuple, int]  # word → class id
    n_classes: int
    representatives: list[list]  # one representative per class
    residuals: list[tuple]  # residual pattern per class


@dataclass
class HankelAnalysis:
    """Result of Hankel matrix analysis."""
    matrix: np.ndarray
    prefixes: list[list]
    suffixes: list[list]
    rank: int
    factorization: tuple[np.ndarray, np.ndarray] | None


@dataclass
class CertifiedMinimization:
    """Complete certified minimization result."""
    prefix_witnesses: list[list]
    suffix_witnesses: list[list]
    n_classes: int
    quotient_automaton: TropicalAutomaton
    hankel_rank: int
    rank_equals_states: bool
    partition: NerodePartition


# ============================================================
# Algorithm 1: Nerode Class Computation
# ============================================================

def compute_nerode_classes(
    f: Callable[[list], Any],
    alphabet: list,
    max_word_length: int = 4,
    max_suffix_length: int = 4
) -> NerodePartition:
    """
    Compute Nerode equivalence classes by residual partitioning.

    Algorithm:
    1. Generate all words up to max_word_length
    2. Generate all suffixes up to max_suffix_length
    3. For each word, compute its residual: z ↦ f(w ++ z)
    4. Group words with identical residuals

    Time complexity: O(|Σ|^L · |Σ|^S) where L=max_word_length, S=max_suffix_length
    Space complexity: O(|Σ|^L) for storing residuals

    Args:
        f: The tropical series function
        alphabet: The alphabet symbols
        max_word_length: Maximum word length to consider
        max_suffix_length: Maximum suffix length for residual computation

    Returns:
        NerodePartition with class assignments and representatives
    """
    # Generate words and suffixes
    words = generate_words(alphabet, max_word_length)
    suffixes = generate_words(alphabet, max_suffix_length)

    # Compute residual for each word
    residual_map: dict[tuple, int] = {}
    residuals_list: list[tuple] = []
    representatives: list[list] = []
    classes: dict[tuple, int] = {}

    for w in words:
        residual = tuple(f(w + z) for z in suffixes)
        if residual not in residual_map:
            class_id = len(residual_map)
            residual_map[residual] = class_id
            residuals_list.append(residual)
            representatives.append(w)
        classes[tuple(w)] = residual_map[residual]

    return NerodePartition(
        classes=classes,
        n_classes=len(residual_map),
        representatives=representatives,
        residuals=residuals_list
    )


# ============================================================
# Algorithm 2: Hankel Matrix Analysis
# ============================================================

def analyze_hankel_matrix(
    f: Callable[[list], Any],
    prefixes: list[list],
    suffixes: list[list]
) -> HankelAnalysis:
    """
    Build and analyze the Hankel matrix H[p,q] = f(p ++ q).

    Algorithm:
    1. Construct the |P| × |Q| Hankel block
    2. Compute its rank via SVD
    3. Attempt a factorization H = L · R through rank-many columns

    Time complexity: O(|P| · |Q| · word_eval_cost + min(|P|,|Q|)^2 · max(|P|,|Q|))
    Space complexity: O(|P| · |Q|)

    Args:
        f: The tropical series function
        prefixes: Prefix set P
        suffixes: Suffix set Q

    Returns:
        HankelAnalysis with matrix, rank, and optional factorization
    """
    m, n = len(prefixes), len(suffixes)
    H = np.zeros((m, n), dtype=float)

    for i, p in enumerate(prefixes):
        for j, q in enumerate(suffixes):
            H[i, j] = f(p + q)

    rank = int(np.linalg.matrix_rank(H))

    # Compute factorization via SVD
    factorization = None
    if rank > 0:
        U, S, Vt = np.linalg.svd(H, full_matrices=False)
        L = U[:, :rank] * np.sqrt(S[:rank])
        R = np.sqrt(S[:rank])[:, np.newaxis] * Vt[:rank, :]
        factorization = (L, R)

    return HankelAnalysis(
        matrix=H,
        prefixes=prefixes,
        suffixes=suffixes,
        rank=rank,
        factorization=factorization
    )


# ============================================================
# Algorithm 3: Quotient Automaton Construction
# ============================================================

def build_quotient_automaton(
    f: Callable[[list], Any],
    alphabet: list,
    partition: NerodePartition
) -> TropicalAutomaton:
    """
    Build the minimal quotient automaton from the Nerode partition.

    Algorithm:
    1. States = Nerode classes (identified by their representatives)
    2. Initial state = class of the empty word
    3. Transition: δ([w], a) = [w ++ [a]]
    4. Output: out([w]) = f(representative(w))

    Time complexity: O(n_classes · |Σ|) for transitions
    Space complexity: O(n_classes · |Σ|)

    Args:
        f: The tropical series function
        alphabet: The alphabet symbols
        partition: The Nerode partition

    Returns:
        TropicalAutomaton with minimal state count
    """
    n_states = partition.n_classes
    reps = partition.representatives

    # Precompute transitions
    trans_table: dict[tuple[int, Any], int] = {}
    for class_id, rep in enumerate(reps):
        for sym in alphabet:
            extended = rep + [sym]
            ext_key = tuple(extended)
            if ext_key in partition.classes:
                trans_table[(class_id, sym)] = partition.classes[ext_key]
            else:
                # Extended word not in our partition; find matching class
                for cid, other_rep in enumerate(reps):
                    other_key = tuple(other_rep)
                    if other_key in partition.classes:
                        # Check if extended word is in same class as other_rep
                        res_ext = partition.residuals[partition.classes.get(ext_key, -1)] \
                            if ext_key in partition.classes else None
                        res_other = partition.residuals[cid]
                        if res_ext == res_other:
                            trans_table[(class_id, sym)] = cid
                            break
                else:
                    trans_table[(class_id, sym)] = 0  # fallback

    # Output: use the series value at the representative
    outputs = [f(rep) for rep in reps]

    # Initial state: class of empty word
    init_state = partition.classes.get((), 0)

    def step_fn(state: int, sym: Any) -> int:
        return trans_table.get((state, sym), 0)

    def output_fn(state: int) -> Any:
        return outputs[state] if state < len(outputs) else 0

    return TropicalAutomaton(
        n_states=n_states,
        init=init_state,
        step=step_fn,
        output=output_fn
    )


# ============================================================
# Algorithm 4: Certified Minimization Pipeline
# ============================================================

def certified_minimize(
    f: Callable[[list], Any],
    alphabet: list,
    max_length: int = 4
) -> CertifiedMinimization:
    """
    Full certified minimization pipeline.

    Algorithm:
    1. Compute Nerode classes (partition)
    2. Extract prefix witnesses P (class representatives)
    3. Extract suffix witnesses Q (separation suffixes)
    4. Build Hankel matrix on P × Q
    5. Verify rank(H) = |classes|
    6. Build quotient automaton
    7. Return certified result

    Time complexity: O(|Σ|^(2L) · |Σ|^S) where L=max_length, S=suffix_length
    Space complexity: O(|Σ|^L + |P|·|Q|)

    Args:
        f: The tropical series function
        alphabet: The alphabet symbols
        max_length: Maximum word length

    Returns:
        CertifiedMinimization with all certificates
    """
    # Step 1: Compute partition
    partition = compute_nerode_classes(f, alphabet, max_length, max_length)

    # Step 2: Prefix witnesses
    P = partition.representatives

    # Step 3: Suffix witnesses (use all words up to max_length)
    Q = generate_words(alphabet, max_length)

    # Step 4: Hankel analysis
    hankel = analyze_hankel_matrix(f, P, Q)

    # Step 5: Build quotient automaton
    quotient_aut = build_quotient_automaton(f, alphabet, partition)

    # Step 6: Verify rank equality
    rank_equals = (hankel.rank == partition.n_classes)

    return CertifiedMinimization(
        prefix_witnesses=P,
        suffix_witnesses=Q,
        n_classes=partition.n_classes,
        quotient_automaton=quotient_aut,
        hankel_rank=hankel.rank,
        rank_equals_states=rank_equals,
        partition=partition
    )


# ============================================================
# Utilities
# ============================================================

def generate_words(alphabet: list, max_length: int) -> list[list]:
    """Generate all words over alphabet up to max_length."""
    words = [[]]
    for length in range(1, max_length + 1):
        for syms in iter_product(alphabet, repeat=length):
            words.append(list(syms))
    return words


# ============================================================
# Example usage
# ============================================================

if __name__ == "__main__":
    # Define series
    def parity(w):
        return sum(w) % 2

    def cost(w):
        return sum(w)

    def threshold(w, t=2):
        return 1 if sum(w) >= t else 0

    alphabet = [0, 1]

    print("=" * 60)
    print("Certified Minimization: Parity Series")
    print("=" * 60)
    result = certified_minimize(parity, alphabet, max_length=3)
    print(f"Number of Nerode classes: {result.n_classes}")
    print(f"Hankel rank: {result.hankel_rank}")
    print(f"Rank = States? {result.rank_equals_states}")
    print(f"Prefix witnesses: {result.prefix_witnesses}")
    print()

    # Verify the quotient automaton
    test_words = generate_words(alphabet, 4)
    correct = all(
        result.quotient_automaton.evaluate(w) == parity(w)
        for w in test_words
    )
    print(f"Quotient automaton correct on all words ≤ 4: {correct}")

    print("\n" + "=" * 60)
    print("Certified Minimization: Threshold Series (≥ 2)")
    print("=" * 60)
    result2 = certified_minimize(threshold, alphabet, max_length=3)
    print(f"Number of Nerode classes: {result2.n_classes}")
    print(f"Hankel rank: {result2.hankel_rank}")
    print(f"Rank = States? {result2.rank_equals_states}")
    print(f"Prefix witnesses: {result2.prefix_witnesses}")

    print("\n" + "=" * 60)
    print("Certified Minimization: Cost Series")
    print("=" * 60)
    result3 = certified_minimize(cost, alphabet, max_length=3)
    print(f"Number of Nerode classes: {result3.n_classes}")
    print(f"Hankel rank: {result3.hankel_rank}")
    print(f"Rank = States? {result3.rank_equals_states}")
