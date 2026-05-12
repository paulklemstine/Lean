#!/usr/bin/env python3
"""
Closure-Hankel Realization Theory: Core Algorithms

This module implements the key algorithms from the closure-Hankel
realization theory:

1. Hankel matrix construction and rank computation
2. Realization extraction from Hankel data (Myhill-Nerode construction)
3. Closure-Hankel rank stabilization detection
4. Minimal realization via reachability/observability reduction

Usage:
    from algorithms import *
    realizer = HankelRealizer(behavior, alphabet)
    realization = realizer.extract_realization(max_depth=4)
"""

import numpy as np
from typing import Callable, Dict, List, Tuple, Optional, Any
from itertools import product as iter_product
from dataclasses import dataclass


# ============================================================
# Data Structures
# ============================================================

@dataclass
class LinearRealization:
    """A finite-dimensional linear realization (α, β, A).

    B(w) = α · A_w · β where A_w is the composition of transition
    matrices along word w.

    Attributes:
        dim: State space dimension n.
        alpha: Output vector α ∈ S^n.
        beta: Initial vector β ∈ S^n.
        transitions: Dict mapping each letter to an n×n matrix.
        alphabet: List of alphabet symbols.
    """
    dim: int
    alpha: np.ndarray
    beta: np.ndarray
    transitions: Dict[str, np.ndarray]
    alphabet: List[str]

    def evaluate(self, word: str) -> float:
        """Evaluate B(w) = α · A_w · β."""
        state = self.beta.copy()
        for letter in word:
            state = self.transitions[letter] @ state
        return self.alpha @ state

    def state_at(self, word: str) -> np.ndarray:
        """Compute the state vector after reading word w."""
        state = self.beta.copy()
        for letter in word:
            state = self.transitions[letter] @ state
        return state


# ============================================================
# Hankel Matrix Operations
# ============================================================

class HankelRealizer:
    """Extract linear realizations from behavior via Hankel analysis.

    Given a behavior B : Σ* → S (represented as a callable),
    this class:
    1. Builds Hankel submatrices from prefix/suffix enumerations
    2. Computes the Hankel rank
    3. Extracts a minimal linear realization when rank stabilizes

    This implements the constructive direction of the Closure-Hankel
    Realization Theorem.

    Args:
        behavior: Callable mapping words (strings) to scalars.
        alphabet: List of alphabet symbols.
    """

    def __init__(self, behavior: Callable[[str], float],
                 alphabet: List[str]):
        self.behavior = behavior
        self.alphabet = alphabet

    def _enumerate_words(self, max_length: int) -> List[str]:
        """Enumerate all words up to given length."""
        words = ['']
        for length in range(1, max_length + 1):
            for w in iter_product(self.alphabet, repeat=length):
                words.append(''.join(w))
        return words

    def build_hankel_matrix(self, prefixes: List[str],
                            suffixes: List[str]) -> np.ndarray:
        """Build the Hankel submatrix H[u,v] = B(u·v).

        Args:
            prefixes: List of prefix words (row indices).
            suffixes: List of suffix words (column indices).

        Returns:
            Matrix H where H[i,j] = B(prefixes[i] + suffixes[j]).
        """
        m, n = len(prefixes), len(suffixes)
        H = np.zeros((m, n))
        for i, u in enumerate(prefixes):
            for j, v in enumerate(suffixes):
                H[i, j] = self.behavior(u + v)
        return H

    def compute_rank(self, max_depth: int = 4,
                     tol: float = 1e-10) -> Tuple[int, List[str], List[str]]:
        """Compute the Hankel rank by increasing prefix/suffix depth.

        Returns:
            Tuple of (rank, prefixes, suffixes) where rank has stabilized.
        """
        prev_rank = 0
        for depth in range(1, max_depth + 1):
            words = self._enumerate_words(depth)
            H = self.build_hankel_matrix(words, words)
            rank = np.linalg.matrix_rank(H, tol=tol)
            if rank == prev_rank and depth > 1:
                return rank, words, words
            prev_rank = rank
        return prev_rank, words, words

    def extract_realization(self, max_depth: int = 4,
                            tol: float = 1e-10) -> Optional[LinearRealization]:
        """Extract a linear realization from Hankel data.

        Implements the constructive Myhill-Nerode / Ho-Kalman algorithm:
        1. Build Hankel matrix until rank stabilizes
        2. Find basis rows (linearly independent Hankel rows)
        3. Define transitions by expressing shifted rows in the basis
        4. Extract initial and output vectors

        Returns:
            LinearRealization if extraction succeeds, None otherwise.

        Complexity:
            Time: O(|Σ|^d · n^2) where d is max_depth, n is rank
            Space: O(|Σ|^(2d)) for the Hankel matrix
        """
        # Step 1: Compute rank and build Hankel matrix
        rank, prefixes, suffixes = self.compute_rank(max_depth, tol)

        if rank == 0:
            return LinearRealization(
                dim=0, alpha=np.array([]), beta=np.array([]),
                transitions={a: np.zeros((0, 0)) for a in self.alphabet},
                alphabet=self.alphabet
            )

        H = self.build_hankel_matrix(prefixes, suffixes)

        # Step 2: Find basis rows via QR decomposition with pivoting
        Q, R, perm = np.linalg.qr(H.T, mode='full')  # type: ignore

        # Use SVD for more robust basis selection
        U, S_vals, Vt = np.linalg.svd(H, full_matrices=False)
        n = rank  # Number of significant singular values

        # Basis: use the first n rows of Vt (right singular vectors)
        # These span the row space of H
        basis_rows = Vt[:n, :]  # n × len(suffixes)

        # Step 3: Express each row as combination of basis rows
        # H ≈ C · basis_rows, solve for C
        C, _, _, _ = np.linalg.lstsq(basis_rows.T, H.T, rcond=None)
        C = C.T  # len(prefixes) × n

        # Step 4: Extract realization components
        # Find index of empty word
        eps_idx = prefixes.index('')

        # Initial vector β = C[ε, :] (coefficients of empty word row)
        beta = C[eps_idx, :]

        # Output vector α: B(u) = C[u,:] · α for basis, α_j = basis_rows[j] evaluated at ε
        eps_col_idx = suffixes.index('')
        alpha = basis_rows[:, eps_col_idx]

        # Step 5: Compute transition matrices
        transitions = {}
        for a in self.alphabet:
            # For each letter a, the shifted row at u is the row at u·a
            # Find C[u·a, :] as a function of C[u, :]
            # Build the matrix M(a) such that C[u·a, :] ≈ C[u, :] · M(a)

            # Collect pairs (C[u,:], C[u·a,:])
            X_list, Y_list = [], []
            for i, u in enumerate(prefixes):
                ua = u + a
                if ua in prefixes:
                    j = prefixes.index(ua)
                    X_list.append(C[i, :])
                    Y_list.append(C[j, :])

            if len(X_list) >= n:
                X = np.array(X_list)
                Y = np.array(Y_list)
                # Solve X · M(a) ≈ Y
                M_a, _, _, _ = np.linalg.lstsq(X, Y, rcond=None)
                transitions[a] = M_a.T  # Transpose for our convention
            else:
                transitions[a] = np.eye(n)

        return LinearRealization(
            dim=n, alpha=alpha, beta=beta,
            transitions=transitions, alphabet=self.alphabet
        )

    def verify_realization(self, realization: LinearRealization,
                           test_words: Optional[List[str]] = None,
                           tol: float = 1e-6) -> Tuple[bool, float]:
        """Verify a realization against the original behavior.

        Returns:
            Tuple of (all_correct, max_error).
        """
        if test_words is None:
            test_words = self._enumerate_words(4)

        max_error = 0.0
        for w in test_words:
            expected = self.behavior(w)
            computed = realization.evaluate(w)
            error = abs(expected - computed)
            max_error = max(max_error, error)

        return max_error <= tol, max_error


# ============================================================
# Closure Operators
# ============================================================

class IdentityClosure:
    """The identity closure: cl(B) = B."""

    def __call__(self, B: Callable) -> Callable:
        return B


class TruncationClosure:
    """Truncation closure: caps values at a maximum."""

    def __init__(self, cap: float):
        self.cap = cap

    def __call__(self, B: Callable) -> Callable:
        cap = self.cap
        def clB(w):
            return min(B(w), cap)
        return clB


class SmoothingClosure:
    """Moving average closure: averages over letter-extensions."""

    def __init__(self, alphabet: List[str], weight: float = 0.5):
        self.alphabet = alphabet
        self.weight = weight

    def __call__(self, B: Callable) -> Callable:
        alpha = self.alphabet
        w = self.weight
        def clB(word):
            val = B(word)
            if not alpha:
                return val
            avg = sum(B(word + a) for a in alpha) / len(alpha)
            return w * val + (1 - w) * avg
        return clB


# ============================================================
# Rank Stabilization Detection
# ============================================================

def detect_rank_stabilization(
        behavior: Callable[[str], float],
        alphabet: List[str],
        max_depth: int = 6,
        tol: float = 1e-10
) -> Tuple[int, int, List[str], List[str]]:
    """Detect when the Hankel rank stabilizes.

    Incrementally builds Hankel matrices of increasing size
    and checks when the rank stops growing.

    Args:
        behavior: The behavior function.
        alphabet: Alphabet symbols.
        max_depth: Maximum word length to consider.
        tol: Tolerance for rank computation.

    Returns:
        Tuple of (stabilized_rank, stabilization_depth, prefixes, suffixes).

    Complexity:
        Time: O(d · |Σ|^(2d) · min(|Σ|^d, n)^2)
        Space: O(|Σ|^(2d))
    """
    realizer = HankelRealizer(behavior, alphabet)
    prev_rank = 0
    stable_count = 0

    for depth in range(1, max_depth + 1):
        words = realizer._enumerate_words(depth)
        H = realizer.build_hankel_matrix(words, words)
        rank = np.linalg.matrix_rank(H, tol=tol)

        if rank == prev_rank:
            stable_count += 1
            if stable_count >= 2:
                return rank, depth - 1, words, words
        else:
            stable_count = 0

        prev_rank = rank

    return prev_rank, max_depth, words, words


# ============================================================
# Demonstration
# ============================================================

if __name__ == '__main__':
    print("Algorithms Module: Hankel Realization Extraction Demo")
    print("=" * 55)

    # Example: B(w) = number of 'a's in w
    def count_a(w: str) -> float:
        return float(sum(1 for c in w if c == 'a'))

    alphabet = ['a', 'b']
    realizer = HankelRealizer(count_a, alphabet)

    # Compute Hankel rank
    rank, prefixes, suffixes = realizer.compute_rank(max_depth=4)
    print(f"\nBehavior: B(w) = count of 'a' in w")
    print(f"Hankel rank: {rank}")

    # Extract realization
    realization = realizer.extract_realization(max_depth=4)
    if realization:
        print(f"Extracted realization dimension: {realization.dim}")
        print(f"  α = {realization.alpha}")
        print(f"  β = {realization.beta}")

        # Verify
        correct, max_error = realizer.verify_realization(realization)
        print(f"  Verification: {'PASS' if correct else 'FAIL'} (max error: {max_error:.2e})")

    # Example 2: B(w) = length of w
    def word_length(w: str) -> float:
        return float(len(w))

    realizer2 = HankelRealizer(word_length, alphabet)
    rank2, _, _ = realizer2.compute_rank(max_depth=4)
    realization2 = realizer2.extract_realization(max_depth=4)
    print(f"\nBehavior: B(w) = length of w")
    print(f"Hankel rank: {rank2}")
    if realization2:
        correct2, err2 = realizer2.verify_realization(realization2)
        print(f"Realization dim: {realization2.dim}, verified: {'PASS' if correct2 else 'FAIL'} (err: {err2:.2e})")

    # Rank stabilization detection
    print("\nRank stabilization detection:")
    stab_rank, stab_depth, _, _ = detect_rank_stabilization(count_a, alphabet)
    print(f"  count_a: rank={stab_rank}, stabilized at depth={stab_depth}")
    stab_rank2, stab_depth2, _, _ = detect_rank_stabilization(word_length, alphabet)
    print(f"  length:  rank={stab_rank2}, stabilized at depth={stab_depth2}")
