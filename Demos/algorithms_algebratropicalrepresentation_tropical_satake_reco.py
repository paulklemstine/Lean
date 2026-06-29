#!/usr/bin/env python3
"""
Algorithms for Tropical Satake Recognition Duality

Implements:
1. Tropical Hankel matrix construction and analysis
2. Syntactic semimodule (minimal realization) construction
3. Nerode equivalence partition refinement
4. Canonical basis extraction from finite samples
5. Recognition test: compare two automata via Hankel kernels

All algorithms work over the tropical (min-plus) semiring:
    ⊕ = min,  ⊗ = +,  𝟎 = ∞,  𝟏 = 0
"""

from itertools import product
from collections import defaultdict
from typing import List, Tuple, Dict, Optional, Set
import numpy as np

INF = float('inf')


# ──────────────────────────────────────────────────────────
# Algorithm 1: Tropical Semiring Operations
# ──────────────────────────────────────────────────────────

def trop_add(a: float, b: float) -> float:
    """Tropical addition: min(a, b)"""
    return min(a, b)

def trop_mul(a: float, b: float) -> float:
    """Tropical multiplication: a + b (with ∞ absorbing)"""
    if a == INF or b == INF:
        return INF
    return a + b

def trop_matrix_mul(A: np.ndarray, B: np.ndarray) -> np.ndarray:
    """Tropical matrix multiplication.
    
    (A ⊗ B)_{i,k} = min_j (A_{i,j} + B_{j,k})
    
    Complexity: O(m * n * p) for m×n times n×p matrices
    """
    m, n = A.shape
    _, p = B.shape
    C = np.full((m, p), INF)
    for i in range(m):
        for k in range(p):
            for j in range(n):
                C[i, k] = trop_add(C[i, k], trop_mul(A[i, j], B[j, k]))
    return C


# ──────────────────────────────────────────────────────────
# Algorithm 2: Hankel Matrix Construction
# ──────────────────────────────────────────────────────────

class TropicalSeries:
    """A tropical series over a finite alphabet.
    
    Represents f: Σ* → ℝ ∪ {∞} where Σ is a finite alphabet.
    """
    
    def __init__(self, alphabet: List[str], evaluate_fn):
        """
        Args:
            alphabet: list of symbols
            evaluate_fn: function mapping word (list of symbols) to tropical value
        """
        self.alphabet = alphabet
        self._evaluate = evaluate_fn
    
    def evaluate(self, word: List[str]) -> float:
        """Evaluate the series on a word."""
        return self._evaluate(word)
    
    def residual(self, prefix: List[str]):
        """
        Compute the residual series at a prefix.
        
        residual_x(z) = f(x ++ z)
        
        This is the key operation for Nerode theory.
        """
        def eval_residual(suffix):
            return self.evaluate(prefix + suffix)
        return TropicalSeries(self.alphabet, eval_residual)
    
    def hankel_entry(self, prefix: List[str], suffix: List[str]) -> float:
        """Compute K(x, y) = f(x ++ y)."""
        return self.evaluate(prefix + suffix)


def build_hankel_matrix(series: TropicalSeries, 
                       prefixes: List[List[str]], 
                       suffixes: List[List[str]]) -> np.ndarray:
    """
    Build the Hankel block matrix H[i,j] = f(prefix_i ++ suffix_j).
    
    Pseudocode:
        INPUT: series f, prefix set P, suffix set S
        OUTPUT: |P| × |S| matrix H
        
        for i = 0 to |P|-1:
            for j = 0 to |S|-1:
                H[i,j] ← f(P[i] ++ S[j])
        return H
    
    Complexity: O(|P| * |S| * max_word_length) for evaluation
    """
    m = len(prefixes)
    n = len(suffixes)
    H = np.full((m, n), INF)
    for i, p in enumerate(prefixes):
        for j, s in enumerate(suffixes):
            H[i, j] = series.hankel_entry(p, s)
    return H


def tropical_hankel_rank(H: np.ndarray, tol: float = 1e-10) -> int:
    """
    Compute the tropical rank of a Hankel matrix.
    
    The tropical rank is the minimum number of tropical rank-1 matrices
    whose tropical sum equals H. We approximate this by counting
    distinct rows up to tropical scaling.
    
    Pseudocode:
        INPUT: Hankel matrix H
        OUTPUT: tropical rank r
        
        Normalize each row by subtracting its minimum
        Count distinct normalized rows
        return count
    
    Complexity: O(m * n + m * m * n) for m rows, n columns
    """
    m, n = H.shape
    normalized = []
    for i in range(m):
        row = H[i, :]
        min_val = np.min(row[row < INF]) if np.any(row < INF) else INF
        if min_val == INF:
            norm = tuple([INF] * n)
        else:
            norm = tuple(v - min_val if v < INF else INF for v in row)
        normalized.append(norm)
    
    return len(set(normalized))


# ──────────────────────────────────────────────────────────
# Algorithm 3: Nerode Partition Refinement
# ──────────────────────────────────────────────────────────

def compute_nerode_partition(series: TropicalSeries,
                            words: List[List[str]],
                            test_suffixes: List[List[str]]) -> Dict:
    """
    Compute the Nerode equivalence partition.
    
    Two words x, y are Nerode-equivalent iff:
        ∀z ∈ test_suffixes: f(x ++ z) = f(y ++ z)
    
    Pseudocode:
        INPUT: series f, word set W, test suffix set T
        OUTPUT: partition of W into equivalence classes
        
        for each w ∈ W:
            sig(w) ← (f(w ++ t) for t ∈ T)
        
        Group words by identical signatures
        return partition
    
    Complexity: O(|W| * |T| * eval_cost + |W| * |T| * log|W|)
    """
    signatures = {}
    for w in words:
        key = tuple(w)
        sig = tuple(series.hankel_entry(w, s) for s in test_suffixes)
        signatures[key] = sig
    
    classes = defaultdict(list)
    for w, sig in signatures.items():
        classes[sig].append(w)
    
    # Build class map
    class_map = {}
    class_reps = []
    for sig, members in classes.items():
        rep = members[0]
        class_reps.append(rep)
        for w in members:
            class_map[w] = rep
    
    return {
        'class_map': class_map,
        'class_reps': class_reps,
        'classes': dict(classes),
        'n_classes': len(classes)
    }


def iterative_nerode_refinement(series: TropicalSeries,
                                alphabet: List[str],
                                max_depth: int = 5) -> Dict:
    """
    Iteratively refine the Nerode partition until stable.
    
    Start with test suffixes = {ε}, then iteratively add
    suffixes until the partition stabilizes.
    
    Pseudocode:
        INPUT: series f, alphabet Σ, max depth d
        OUTPUT: stable Nerode partition
        
        T ← {ε}
        W ← words of length ≤ d
        P_prev ← trivial partition
        
        repeat:
            P ← compute_nerode_partition(f, W, T)
            if P = P_prev: break
            P_prev ← P
            T ← T ∪ {a·t | a ∈ Σ, t ∈ T}  (extend test suffixes)
        
        return P
    
    Complexity: O(d * |W|² * |T| * eval_cost) worst case
    """
    # Generate all words
    words = [()]
    for length in range(1, max_depth + 1):
        for w in product(alphabet, repeat=length):
            words.append(w)
    words_list = [list(w) for w in words]
    
    # Start with empty suffix
    test_suffixes = [[]]
    prev_n_classes = 0
    
    for iteration in range(max_depth):
        result = compute_nerode_partition(series, words_list, test_suffixes)
        
        if result['n_classes'] == prev_n_classes:
            break
        
        prev_n_classes = result['n_classes']
        
        # Extend test suffixes
        new_suffixes = []
        for t in test_suffixes:
            for a in alphabet:
                new_suffix = [a] + t
                if new_suffix not in test_suffixes and new_suffix not in new_suffixes:
                    new_suffixes.append(new_suffix)
        test_suffixes.extend(new_suffixes)
    
    return result


# ──────────────────────────────────────────────────────────
# Algorithm 4: Minimal Realization (Syntactic Semimodule)
# ──────────────────────────────────────────────────────────

def build_syntactic_semimodule(series: TropicalSeries,
                               alphabet: List[str],
                               max_depth: int = 4):
    """
    Construct the syntactic semimodule (= minimal realization).
    
    This is the tropical Myhill-Nerode construction:
    - States = Nerode equivalence classes
    - Transitions = class of (representative ++ [a])
    - Initial state = class of ε
    - Output = f(representative)
    
    Pseudocode:
        INPUT: series f, alphabet Σ, depth bound d
        OUTPUT: minimal automaton (states, transitions, init, output)
        
        P ← stable Nerode partition of words up to depth d
        states ← class representatives from P
        init ← class of ε
        
        for each state s (with representative w_s):
            output(s) ← f(w_s)
            for each a ∈ Σ:
                δ(a, s) ← class of (w_s ++ [a])
        
        return (states, δ, init, output)
    
    Complexity: O(d * |Σ|^d * |Σ|^d * eval_cost)
    
    Correctness: By the Nerode theorem (formally proved), this automaton
    is the unique minimal realization of the series.
    """
    partition = iterative_nerode_refinement(series, alphabet, max_depth)
    
    class_reps = partition['class_reps']
    class_map = partition['class_map']
    n_states = partition['n_classes']
    
    # Map representatives to state indices
    rep_to_idx = {rep: i for i, rep in enumerate(class_reps)}
    
    # Build transitions
    transitions = {}
    for i, rep in enumerate(class_reps):
        for a in alphabet:
            extended = list(rep) + [a]
            ext_key = tuple(extended)
            if ext_key in class_map:
                target_rep = class_map[ext_key]
                transitions[(a, i)] = rep_to_idx[target_rep]
            # else: transition undefined (word too long)
    
    # Build output
    output = [series.evaluate(list(rep)) for rep in class_reps]
    
    # Initial state
    init_state = rep_to_idx[class_map[()]]
    
    return {
        'n_states': n_states,
        'transitions': transitions,
        'output': output,
        'init_state': init_state,
        'class_reps': class_reps,
        'partition': partition
    }


# ──────────────────────────────────────────────────────────
# Algorithm 5: Canonical Basis Extraction
# ──────────────────────────────────────────────────────────

def extract_canonical_basis(series: TropicalSeries,
                           alphabet: List[str],
                           max_depth: int = 4) -> Dict:
    """
    Extract the canonical basis of the syntactic semimodule.
    
    In the tropical setting, canonical basis elements correspond to
    extremal (join-irreducible) states: states whose residual profiles
    cannot be decomposed as tropical sums of other states' profiles.
    
    Pseudocode:
        INPUT: series f, alphabet Σ, depth d
        OUTPUT: canonical basis B ⊆ states, sample sets P, T
        
        (states, δ, init, output) ← build_syntactic_semimodule(f, Σ, d)
        
        # Compute residual profile for each state
        T ← sufficient test suffixes
        for each state s:
            profile(s) ← (f(rep(s) ++ t) for t ∈ T)
        
        # Find extremal states (not tropically dominated)
        B ← ∅
        for each state s:
            if ¬∃ other states s₁,...,sₖ:
                profile(s) = min(profile(s₁), ..., profile(sₖ))
            then:
                B ← B ∪ {s}
        
        return B
    
    Complexity: O(n² * |T|) for n states, |T| test suffixes
    """
    semimodule = build_syntactic_semimodule(series, alphabet, max_depth)
    partition = semimodule['partition']
    class_reps = semimodule['class_reps']
    n_states = semimodule['n_states']
    
    # Build residual profiles
    words = [[]]
    for length in range(1, max_depth + 1):
        for w in product(alphabet, repeat=length):
            words.append(list(w))
    
    test_suffixes = words[:min(20, len(words))]
    
    profiles = []
    for rep in class_reps:
        profile = [series.hankel_entry(list(rep), s) for s in test_suffixes]
        profiles.append(profile)
    
    # Find extremal states
    extremal = []
    for i in range(n_states):
        is_extremal = True
        for j in range(n_states):
            if i == j:
                continue
            # Check if profile[i] is tropically dominated by profile[j]
            # i.e., profile[i] ≥ profile[j] componentwise
            dominated = all(
                profiles[i][k] >= profiles[j][k] 
                for k in range(len(test_suffixes))
                if profiles[j][k] < INF
            )
            if dominated and profiles[i] != profiles[j]:
                is_extremal = False
                break
        if is_extremal:
            extremal.append(i)
    
    return {
        'basis_indices': extremal,
        'basis_reps': [class_reps[i] for i in extremal],
        'n_basis': len(extremal),
        'n_states': n_states,
        'semimodule': semimodule,
        'profiles': profiles,
        'test_suffixes': test_suffixes
    }


# ──────────────────────────────────────────────────────────
# Algorithm 6: Recognition Test
# ──────────────────────────────────────────────────────────

def recognition_test(series1: TropicalSeries,
                    series2: TropicalSeries,
                    alphabet: List[str],
                    max_depth: int = 4) -> Dict:
    """
    Test whether two tropical series have the same syntactic semimodule.
    
    By the Recognition Theorem (formally proved), this is equivalent
    to checking Hankel kernel equality.
    
    Pseudocode:
        INPUT: series f₁, f₂, alphabet Σ, depth d
        OUTPUT: {equivalent: bool, witness: word pair if not}
        
        for each word w of length ≤ 2d:
            for each word w' of length ≤ 2d:
                if f₁(w ++ w') ≠ f₂(w ++ w'):
                    return {equivalent: False, witness: (w, w')}
        
        return {equivalent: True}
    
    Complexity: O(|Σ|^(4d) * eval_cost)
    """
    words = [[]]
    for length in range(1, max_depth + 1):
        for w in product(alphabet, repeat=length):
            words.append(list(w))
    
    for p in words:
        for s in words:
            v1 = series1.hankel_entry(p, s)
            v2 = series2.hankel_entry(p, s)
            if abs(v1 - v2) > 1e-10 if v1 != INF and v2 != INF else v1 != v2:
                return {
                    'equivalent': False,
                    'witness_prefix': p,
                    'witness_suffix': s,
                    'value1': v1,
                    'value2': v2
                }
    
    # Build semimodules
    sm1 = build_syntactic_semimodule(series1, alphabet, max_depth)
    sm2 = build_syntactic_semimodule(series2, alphabet, max_depth)
    
    return {
        'equivalent': True,
        'semimodule_size_1': sm1['n_states'],
        'semimodule_size_2': sm2['n_states']
    }


# ──────────────────────────────────────────────────────────
# Example usage and tests
# ──────────────────────────────────────────────────────────

if __name__ == '__main__':
    print("="*60)
    print("Tropical Satake Recognition — Algorithm Tests")
    print("="*60)
    
    # Define a simple tropical series: shortest path length
    alphabet = ['a', 'b']
    
    def shortest_path_series(word):
        """Simple series: count of 'a's + 2 * count of 'b's"""
        return sum(1 if c == 'a' else 2 for c in word) if word else 0
    
    series = TropicalSeries(alphabet, shortest_path_series)
    
    # Test 1: Hankel matrix
    print("\n--- Test 1: Hankel Matrix ---")
    prefixes = [[], ['a'], ['b'], ['a', 'a']]
    suffixes = [[], ['a'], ['b'], ['a', 'b']]
    H = build_hankel_matrix(series, prefixes, suffixes)
    print("Hankel matrix:")
    for i, p in enumerate(prefixes):
        row = [f"{H[i,j]:.0f}" if H[i,j] < INF else "∞" for j in range(len(suffixes))]
        print(f"  {''.join(p) if p else 'ε':>4}: {row}")
    print(f"Tropical rank: {tropical_hankel_rank(H)}")
    
    # Test 2: Nerode partition
    print("\n--- Test 2: Nerode Partition ---")
    result = iterative_nerode_refinement(series, alphabet, max_depth=3)
    print(f"Number of classes: {result['n_classes']}")
    for sig, members in result['classes'].items():
        reps_str = [(''.join(m) if m else 'ε') for m in members[:5]]
        print(f"  Class (sig={sig[:3]}...): {reps_str}")
    
    # Test 3: Minimal realization
    print("\n--- Test 3: Minimal Realization ---")
    semimodule = build_syntactic_semimodule(series, alphabet, max_depth=3)
    print(f"Minimal states: {semimodule['n_states']}")
    print(f"Transitions: {len(semimodule['transitions'])} defined")
    
    # Test 4: Canonical basis
    print("\n--- Test 4: Canonical Basis ---")
    basis = extract_canonical_basis(series, alphabet, max_depth=3)
    print(f"Basis size: {basis['n_basis']} out of {basis['n_states']} states")
    for idx in basis['basis_indices']:
        rep = basis['basis_reps'][basis['basis_indices'].index(idx)]
        print(f"  Extremal state {idx}: representative = {''.join(rep) if rep else 'ε'}")
    
    # Test 5: Recognition test
    print("\n--- Test 5: Recognition Test ---")
    
    # Same series, different implementation
    def same_series_v2(word):
        return shortest_path_series(word)
    
    series2 = TropicalSeries(alphabet, same_series_v2)
    result = recognition_test(series, series2, alphabet, max_depth=3)
    print(f"Same series test: equivalent = {result['equivalent']}")
    
    # Different series
    def different_series(word):
        return len(word)
    
    series3 = TropicalSeries(alphabet, different_series)
    result = recognition_test(series, series3, alphabet, max_depth=3)
    print(f"Different series test: equivalent = {result['equivalent']}")
    if not result['equivalent']:
        p = result['witness_prefix']
        s = result['witness_suffix']
        print(f"  Witness: prefix={''.join(p) if p else 'ε'}, suffix={''.join(s) if s else 'ε'}")
        print(f"  Values: {result['value1']} vs {result['value2']}")
    
    print("\n--- All tests complete ---")
