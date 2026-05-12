#!/usr/bin/env python3
"""
Tropical Residuation Realization: Algorithms

Implements the core algorithms from the tropical Hankel realization theory:
1. Hankel matrix construction and row analysis
2. Hankel equivalence class discovery  
3. Minimal automaton reconstruction from Hankel data
4. Generator rank computation
5. Certified block reconstruction
"""

import numpy as np
from typing import Callable, Dict, List, Tuple, Set, Optional
from dataclasses import dataclass

# ---------------------------------------------------------------------------
# Data Structures
# ---------------------------------------------------------------------------

@dataclass
class OutputDFA:
    """Deterministic finite automaton with output weights.
    f(w) = out[reach(q0, w)]
    """
    n_states: int
    alphabet_size: int
    delta: Dict[Tuple[int, int], int]
    q0: int
    out: List[float]
    
    def reach(self, q: int, word: List[int]) -> int:
        """State reached from q after reading word."""
        state = q
        for a in word:
            state = self.delta[(state, a)]
        return state
    
    def eval(self, word: List[int]) -> float:
        """Evaluate f(word) = out[reach(q0, word)]."""
        return self.out[self.reach(self.q0, word)]

@dataclass
class HankelAnalysis:
    """Result of Hankel row analysis."""
    n_classes: int
    representatives: List[List[int]]  # One representative per class
    class_map: Dict[int, int]  # prefix_index -> class_index
    class_rows: List[Tuple[float, ...]]  # Canonical row per class

@dataclass
class ReconstructedAutomaton:
    """Result of automaton reconstruction."""
    dfa: OutputDFA
    basis_words: List[List[int]]
    generator_rank: int

# ---------------------------------------------------------------------------
# Algorithm 1: Hankel Matrix Construction
# ---------------------------------------------------------------------------

def build_hankel_matrix(f: Callable[[List[int]], float],
                        prefixes: List[List[int]],
                        suffixes: List[List[int]]) -> np.ndarray:
    """Build the Hankel matrix H[i,j] = f(prefixes[i] ++ suffixes[j]).
    
    Time complexity: O(|P| * |T| * max_word_length)
    Space complexity: O(|P| * |T|)
    
    Args:
        f: The weighted language (black-box function)
        prefixes: List of prefix words (rows)
        suffixes: List of suffix words (columns)
    
    Returns:
        Hankel matrix as numpy array
    """
    n, m = len(prefixes), len(suffixes)
    H = np.zeros((n, m))
    for i, u in enumerate(prefixes):
        for j, v in enumerate(suffixes):
            H[i, j] = f(u + v)
    return H

# ---------------------------------------------------------------------------
# Algorithm 2: Hankel Equivalence Class Discovery
# ---------------------------------------------------------------------------

def discover_hankel_classes(f: Callable[[List[int]], float],
                           prefixes: List[List[int]],
                           suffixes: List[List[int]],
                           tol: float = 1e-10) -> HankelAnalysis:
    """Discover Hankel equivalence classes from finite data.
    
    Two prefixes u1, u2 are Hankel-equivalent if f(u1++v) = f(u2++v) for all v.
    We check this on the finite suffix set T.
    
    Time complexity: O(|P|^2 * |T|)
    Space complexity: O(|P| * |T|)
    
    Args:
        f: The weighted language
        prefixes: Prefix words to analyze
        suffixes: Suffix words for comparison
        tol: Numerical tolerance for floating-point comparison
    
    Returns:
        HankelAnalysis with discovered classes
    """
    H = build_hankel_matrix(f, prefixes, suffixes)
    
    class_map: Dict[int, int] = {}
    class_rows: List[Tuple[float, ...]] = []
    representatives: List[List[int]] = []
    
    for i in range(len(prefixes)):
        row = tuple(np.round(H[i, :] / tol) * tol)  # Round for comparison
        
        found = False
        for ci, canonical in enumerate(class_rows):
            if all(abs(a - b) < tol for a, b in zip(row, canonical)):
                class_map[i] = ci
                found = True
                break
        
        if not found:
            class_map[i] = len(class_rows)
            class_rows.append(row)
            representatives.append(prefixes[i])
    
    return HankelAnalysis(
        n_classes=len(class_rows),
        representatives=representatives,
        class_map=class_map,
        class_rows=class_rows
    )

# ---------------------------------------------------------------------------
# Algorithm 3: Minimal Automaton Reconstruction
# ---------------------------------------------------------------------------

def reconstruct_minimal_automaton(f: Callable[[List[int]], float],
                                  alphabet_size: int,
                                  max_prefix_len: int = 5,
                                  max_suffix_len: int = 5,
                                  tol: float = 1e-10
                                  ) -> ReconstructedAutomaton:
    """Reconstruct the minimal automaton from Hankel data.
    
    This implements the tropical Myhill-Nerode construction:
    1. Enumerate prefixes and suffixes up to given lengths
    2. Discover Hankel equivalence classes
    3. Build transitions from class structure
    4. Output = f(representative)
    
    Time complexity: O(|Σ|^L * |Σ|^L) where L = max length
    Space complexity: O(n_classes * |Σ|)
    
    Args:
        f: The weighted language (black-box function)
        alphabet_size: Size of the alphabet Σ
        max_prefix_len: Maximum prefix length to explore
        max_suffix_len: Maximum suffix length to explore
        tol: Numerical tolerance
    
    Returns:
        ReconstructedAutomaton with the minimal DFA
    """
    # Generate word sets
    def gen_words(max_len: int) -> List[List[int]]:
        words = [[]]
        queue = [[]]
        while queue:
            w = queue.pop(0)
            if len(w) < max_len:
                for a in range(alphabet_size):
                    new_w = w + [a]
                    words.append(new_w)
                    queue.append(new_w)
        return words
    
    prefixes = gen_words(max_prefix_len)
    suffixes = gen_words(max_suffix_len)
    
    # Discover classes
    analysis = discover_hankel_classes(f, prefixes, suffixes, tol)
    
    # Build transitions
    delta: Dict[Tuple[int, int], int] = {}
    for ci, rep in enumerate(analysis.representatives):
        for a in range(alphabet_size):
            extended = rep + [a]
            # Find the class of extended prefix
            ext_row = tuple(f(extended + s) for s in suffixes)
            
            target = None
            for cj, canonical in enumerate(analysis.class_rows):
                if all(abs(x - y) < tol for x, y in zip(ext_row, canonical)):
                    target = cj
                    break
            
            if target is None:
                # This shouldn't happen if prefix set is large enough
                target = 0  # fallback
            
            delta[(ci, a)] = target
    
    # Build output
    out = [f(rep) for rep in analysis.representatives]
    
    # Find initial state (class of empty word)
    q0 = 0  # Empty word is always first prefix
    for ci, rep in enumerate(analysis.representatives):
        if rep == []:
            q0 = ci
            break
    
    dfa = OutputDFA(
        n_states=analysis.n_classes,
        alphabet_size=alphabet_size,
        delta=delta,
        q0=q0,
        out=out
    )
    
    return ReconstructedAutomaton(
        dfa=dfa,
        basis_words=analysis.representatives,
        generator_rank=analysis.n_classes
    )

# ---------------------------------------------------------------------------
# Algorithm 4: Generator Rank Computation
# ---------------------------------------------------------------------------

def compute_generator_rank(f: Callable[[List[int]], float],
                           alphabet_size: int,
                           max_len: int = 6,
                           tol: float = 1e-10) -> int:
    """Compute the generator rank (= minimal state count).
    
    The generator rank is the number of distinct Hankel rows, which equals
    the minimal number of states in any OutputDFA recognizing f.
    
    Time complexity: O(|Σ|^L * |Σ|^L)
    Space complexity: O(|Σ|^L)
    
    Args:
        f: The weighted language
        alphabet_size: Size of alphabet
        max_len: Maximum word length to explore
        tol: Numerical tolerance
    
    Returns:
        The generator rank (number of distinct Hankel row classes)
    """
    def gen_words(max_l):
        words = [[]]
        queue = [[]]
        while queue:
            w = queue.pop(0)
            if len(w) < max_l:
                for a in range(alphabet_size):
                    new_w = w + [a]
                    words.append(new_w)
                    queue.append(new_w)
        return words
    
    words = gen_words(max_len)
    suffixes = gen_words(max_len)
    
    unique_rows: Set[Tuple[float, ...]] = set()
    for u in words:
        row = tuple(round(f(u + v) / tol) * tol for v in suffixes)
        unique_rows.add(row)
    
    return len(unique_rows)

# ---------------------------------------------------------------------------
# Algorithm 5: Certified Block Reconstruction
# ---------------------------------------------------------------------------

@dataclass
class CertifiedBlock:
    """A certified Hankel block with basis and transition data."""
    prefixes: List[List[int]]
    suffixes: List[List[int]]
    basis_indices: List[int]
    hankel_matrix: np.ndarray
    transition_targets: Dict[Tuple[int, int], int]  # (basis_idx, letter) -> class
    is_saturated: bool

def build_certified_block(f: Callable[[List[int]], float],
                          alphabet_size: int,
                          max_len: int = 4,
                          tol: float = 1e-10) -> CertifiedBlock:
    """Build a certified Hankel block for reconstruction.
    
    This constructs a finite Hankel block that is saturated: every one-letter
    extension of a basis element's prefix has its class represented in the block.
    
    The block serves as a finite certificate that the reconstruction is correct.
    
    Args:
        f: The weighted language
        alphabet_size: Size of alphabet
        max_len: Maximum word length
        tol: Numerical tolerance
    
    Returns:
        CertifiedBlock with all reconstruction data
    """
    def gen_words(max_l):
        words = [[]]
        queue = [[]]
        while queue:
            w = queue.pop(0)
            if len(w) < max_l:
                for a in range(alphabet_size):
                    new_w = w + [a]
                    words.append(new_w)
                    queue.append(new_w)
        return words
    
    prefixes = gen_words(max_len)
    suffixes = gen_words(max_len)
    
    H = build_hankel_matrix(f, prefixes, suffixes)
    
    # Find basis (one representative per distinct row)
    basis_indices = []
    seen_rows: List[Tuple[float, ...]] = []
    row_class_map = {}
    
    for i in range(len(prefixes)):
        row = tuple(np.round(H[i, :] / tol) * tol)
        found = False
        for ci, seen in enumerate(seen_rows):
            if all(abs(a - b) < tol for a, b in zip(row, seen)):
                row_class_map[i] = ci
                found = True
                break
        if not found:
            row_class_map[i] = len(seen_rows)
            seen_rows.append(row)
            basis_indices.append(i)
    
    # Build transitions for basis elements
    transition_targets = {}
    is_saturated = True
    
    for bi, basis_idx in enumerate(basis_indices):
        basis_prefix = prefixes[basis_idx]
        for a in range(alphabet_size):
            extended = basis_prefix + [a]
            ext_row = tuple(f(extended + s) for s in suffixes)
            
            found_target = None
            for ci, seen in enumerate(seen_rows):
                if all(abs(x - y) < tol for x, y in zip(ext_row, seen)):
                    found_target = ci
                    break
            
            if found_target is not None:
                transition_targets[(bi, a)] = found_target
            else:
                is_saturated = False
                transition_targets[(bi, a)] = 0
    
    return CertifiedBlock(
        prefixes=prefixes,
        suffixes=suffixes,
        basis_indices=basis_indices,
        hankel_matrix=H,
        transition_targets=transition_targets,
        is_saturated=is_saturated
    )

# ---------------------------------------------------------------------------
# Verification Utilities
# ---------------------------------------------------------------------------

def verify_reconstruction(f: Callable[[List[int]], float],
                         dfa: OutputDFA,
                         test_words: List[List[int]],
                         tol: float = 1e-10) -> Tuple[bool, List[Tuple[List[int], float, float]]]:
    """Verify that a reconstructed DFA matches the original function.
    
    Returns (all_match, list of (word, original_value, reconstructed_value))
    """
    results = []
    all_match = True
    for w in test_words:
        orig = f(w)
        recon = dfa.eval(w)
        if abs(orig - recon) > tol:
            all_match = False
        results.append((w, orig, recon))
    return all_match, results

# ---------------------------------------------------------------------------
# Example Usage
# ---------------------------------------------------------------------------

if __name__ == "__main__":
    print("Tropical Hankel Realization: Algorithm Demonstrations")
    print("=" * 55)
    
    # Define a test function via a hidden automaton
    delta = {(0, 0): 1, (0, 1): 0, (1, 0): 0, (1, 1): 1}
    hidden = OutputDFA(2, 2, delta, 0, [10.0, 25.0])
    f = hidden.eval
    
    # Algorithm 1: Build Hankel matrix
    prefixes = [[], [0], [1], [0,0], [0,1]]
    suffixes = [[], [0], [1]]
    H = build_hankel_matrix(f, prefixes, suffixes)
    print(f"\nHankel matrix shape: {H.shape}")
    print(H)
    
    # Algorithm 2: Discover classes
    analysis = discover_hankel_classes(f, prefixes, suffixes)
    print(f"\nHankel classes found: {analysis.n_classes}")
    
    # Algorithm 3: Reconstruct minimal automaton
    result = reconstruct_minimal_automaton(f, 2, max_prefix_len=4, max_suffix_len=4)
    print(f"\nReconstructed DFA: {result.dfa.n_states} states")
    print(f"Generator rank: {result.generator_rank}")
    
    # Algorithm 4: Compute generator rank
    rank = compute_generator_rank(f, 2, max_len=4)
    print(f"\nGenerator rank (independent computation): {rank}")
    
    # Algorithm 5: Build certified block
    block = build_certified_block(f, 2, max_len=4)
    print(f"\nCertified block: {len(block.basis_indices)} basis elements, saturated={block.is_saturated}")
    
    # Verify
    test_words = [[], [0], [1], [0,0], [0,1], [1,0], [1,1], [0,0,0], [1,0,1]]
    ok, results = verify_reconstruction(f, result.dfa, test_words)
    print(f"\nVerification: {'PASS' if ok else 'FAIL'}")
    for w, orig, recon in results:
        label = ''.join(map(str, w)) if w else 'ε'
        print(f"  f({label}) = {orig:.1f} (reconstructed: {recon:.1f})")
