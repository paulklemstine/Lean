#!/usr/bin/env python3
"""
Berggren–Hecke Spectral Reconstruction: Algorithms

Implements the core algorithms from the research paper:
1. Berggren tree generation and evaluation
2. Hecke operator computation
3. Character moment computation
4. Signal reconstruction from moments
5. Period detection for branch-periodic signals
"""

import numpy as np
from itertools import product
from typing import Tuple, List, Dict, Optional
from collections import defaultdict


# ============================================================
# Algorithm 1: Berggren Tree Evaluation
# ============================================================

# The three Berggren matrices
BERGGREN_MATRICES = [
    np.array([[1, -2, 2], [2, -1, 2], [2, -2, 3]]),   # B1
    np.array([[1, 2, 2], [2, 1, 2], [2, 2, 3]]),       # B2
    np.array([[-1, 2, 2], [-2, 1, 2], [-2, 2, 3]]),    # B3
]


def berggren_eval_matrix(word: List[int]) -> np.ndarray:
    """
    Evaluate a Berggren word using matrix multiplication.

    Args:
        word: List of branch indices in {0, 1, 2}

    Returns:
        The Pythagorean triple as a numpy array [a, b, c]

    Time complexity: O(|word|) matrix multiplications
    Space complexity: O(1) working space
    """
    result = np.array([3, 4, 5])
    for i in reversed(word):
        result = BERGGREN_MATRICES[i] @ result
    return result


def generate_berggren_tree(max_depth: int) -> Dict[tuple, np.ndarray]:
    """
    Generate all Berggren tree vertices up to a given depth.

    Args:
        max_depth: Maximum depth of the tree

    Returns:
        Dictionary mapping word tuples to Pythagorean triples

    Time complexity: O(3^max_depth)
    Space complexity: O(3^max_depth)
    """
    tree = {(): np.array([3, 4, 5])}
    for depth in range(1, max_depth + 1):
        for word in product(range(3), repeat=depth):
            tree[word] = berggren_eval_matrix(list(word))
    return tree


# ============================================================
# Algorithm 2: Hecke Operator on Finite State Space
# ============================================================

class HeckeAlgebra:
    """
    Hecke operator algebra on the word state space (Z/3Z)^n.

    The word state space has 3^n elements. Translation operators
    T_v act by T_v(f)(w) = f(w + v), and the Hecke averaging
    operator H acts by H(f)(w) = sum_v f(w + v).
    """

    def __init__(self, n: int):
        """
        Initialize with word length n.

        Time: O(3^n) to enumerate states
        Space: O(3^n)
        """
        self.n = n
        self.states = list(product(range(3), repeat=n))
        self.state_index = {s: i for i, s in enumerate(self.states)}
        self.num_states = len(self.states)

    def add_words(self, w1: tuple, w2: tuple) -> tuple:
        """Pointwise addition mod 3."""
        return tuple((a + b) % 3 for a, b in zip(w1, w2))

    def translate(self, v: tuple, signal: np.ndarray) -> np.ndarray:
        """
        Apply translation operator T_v to a signal.

        T_v(f)(w) = f(w + v)

        Time: O(3^n)
        Space: O(3^n)
        """
        result = np.zeros(self.num_states)
        for i, w in enumerate(self.states):
            wv = self.add_words(w, v)
            j = self.state_index[wv]
            result[i] = signal[j]
        return result

    def hecke_average(self, signal: np.ndarray) -> np.ndarray:
        """
        Apply the Hecke averaging operator H(f)(w) = sum_v f(w + v).

        Time: O(3^(2n))
        Space: O(3^n)
        """
        result = np.zeros(self.num_states)
        for i, w in enumerate(self.states):
            total = 0.0
            for v in self.states:
                wv = self.add_words(w, v)
                j = self.state_index[wv]
                total += signal[j]
            result[i] = total
        return result

    def translation_matrix(self, v: tuple) -> np.ndarray:
        """
        Build the matrix representation of T_v.

        Time: O(3^(2n))
        Space: O(3^(2n))
        """
        M = np.zeros((self.num_states, self.num_states))
        for i, w in enumerate(self.states):
            wv = self.add_words(w, v)
            j = self.state_index[wv]
            M[i, j] = 1.0
        return M

    def verify_commutativity(self, v1: tuple, v2: tuple) -> float:
        """
        Verify that T_v1 and T_v2 commute, returning the Frobenius norm
        of their commutator.

        Time: O(3^(3n))
        Space: O(3^(2n))
        """
        M1 = self.translation_matrix(v1)
        M2 = self.translation_matrix(v2)
        return np.linalg.norm(M1 @ M2 - M2 @ M1, 'fro')


# ============================================================
# Algorithm 3: Character Moment Computation
# ============================================================

def compute_moments(signal: np.ndarray, states: list) -> np.ndarray:
    """
    Compute moments of a signal against all point indicators.

    moment(f, delta_v) = sum_w f(w) * delta_v(w) = f(v)

    For point indicators, this is simply the identity map.

    Time: O(3^n) — just copying the signal
    Space: O(3^n)
    """
    return signal.copy()


def reconstruct_from_moments(moments: np.ndarray) -> np.ndarray:
    """
    Reconstruct a signal from its point-indicator moments.

    Since moment(f, delta_v) = f(v), reconstruction is trivial
    (the identity map). This is the content of the moment injectivity theorem.

    Time: O(3^n)
    Space: O(3^n)
    """
    return moments.copy()


# ============================================================
# Algorithm 4: Period Detection for Branch-Periodic Signals
# ============================================================

def detect_branch_period(signal: np.ndarray, n: int) -> int:
    """
    Detect the minimal branch period of a signal on (Z/3Z)^n.

    A signal is p-periodic if it depends only on the first p coordinates.
    This algorithm finds the minimal such p.

    Args:
        signal: Signal values indexed by (Z/3Z)^n states
        n: Word length

    Returns:
        Minimal period p (1 <= p <= n)

    Time: O(n * 3^n)
    Space: O(3^n)
    """
    states = list(product(range(3), repeat=n))
    state_to_idx = {s: i for i, s in enumerate(states)}

    for p in range(1, n + 1):
        # Check if signal is p-periodic: f(w1) = f(w2) whenever w1[:p] = w2[:p]
        is_periodic = True
        prefix_values = {}
        for w in states:
            prefix = w[:p]
            val = signal[state_to_idx[w]]
            if prefix in prefix_values:
                if abs(val - prefix_values[prefix]) > 1e-12:
                    is_periodic = False
                    break
            else:
                prefix_values[prefix] = val
        if is_periodic:
            return p
    return n


def factor_through_quotient(signal: np.ndarray, n: int, p: int) -> Dict[tuple, float]:
    """
    Factor a p-periodic signal through the prefix truncation map.

    Returns a function g on (Z/3Z)^p such that f = g ∘ trunc_p.

    Time: O(3^n)
    Space: O(3^p)
    """
    states = list(product(range(3), repeat=n))
    state_to_idx = {s: i for i, s in enumerate(states)}

    quotient = {}
    for w in states:
        prefix = w[:p]
        if prefix not in quotient:
            quotient[prefix] = signal[state_to_idx[w]]
    return quotient


# ============================================================
# Algorithm 5: Residue Class Computation
# ============================================================

def compute_residue_classes(max_depth: int, K: int) -> Dict[tuple, tuple]:
    """
    Compute residue classes (a mod K, b mod K, c mod K) for all
    Berggren tree vertices up to given depth.

    Time: O(3^max_depth)
    Space: O(3^max_depth)
    """
    tree = generate_berggren_tree(max_depth)
    residues = {}
    for word, triple in tree.items():
        residues[word] = tuple(int(x) % K for x in triple)
    return residues


def group_by_residue(residues: Dict[tuple, tuple]) -> Dict[tuple, List[tuple]]:
    """
    Group words by their residue class.

    Time: O(|residues|)
    Space: O(|residues|)
    """
    groups = defaultdict(list)
    for word, res in residues.items():
        groups[res].append(word)
    return dict(groups)


# ============================================================
# Algorithm 6: Certified Reconstruction Procedure
# ============================================================

def certified_reconstruction(
    moments: Dict[tuple, float],
    n: int,
    tolerance: float = 1e-12
) -> Dict:
    """
    Certified reconstruction of a signal from its character moments.

    Given moments {moment(f, delta_v) : v in states}, this procedure:
    1. Reconstructs the signal f
    2. Detects the minimal branch period p
    3. Factors f through the p-quotient
    4. Returns a certificate of correctness

    Args:
        moments: Dictionary mapping word states to moment values
        n: Word length
        tolerance: Numerical tolerance for period detection

    Returns:
        Dictionary with keys:
        - 'signal': reconstructed signal array
        - 'period': minimal branch period
        - 'quotient': factored signal on quotient space
        - 'certificate': correctness verification data

    Time: O(n * 3^n)
    Space: O(3^n)
    """
    states = list(product(range(3), repeat=n))

    # Step 1: Reconstruct signal from moments
    signal = np.array([moments.get(s, 0.0) for s in states])

    # Step 2: Detect minimal period
    period = detect_branch_period(signal, n)

    # Step 3: Factor through quotient
    quotient = factor_through_quotient(signal, n, period)

    # Step 4: Verify reconstruction
    state_to_idx = {s: i for i, s in enumerate(states)}
    max_error = 0.0
    for s in states:
        reconstructed = quotient[s[:period]]
        error = abs(signal[state_to_idx[s]] - reconstructed)
        max_error = max(max_error, error)

    certificate = {
        'reconstruction_exact': max_error < tolerance,
        'max_error': max_error,
        'period': period,
        'quotient_size': 3 ** period,
        'full_space_size': 3 ** n,
        'compression_ratio': 3 ** n / 3 ** period if period < n else 1.0,
    }

    return {
        'signal': signal,
        'period': period,
        'quotient': quotient,
        'certificate': certificate,
    }


# ============================================================
# Example Usage
# ============================================================

if __name__ == "__main__":
    print("Berggren–Hecke Spectral Reconstruction Algorithms")
    print("=" * 55)

    # Example 1: Tree generation
    print("\n--- Algorithm 1: Tree Generation ---")
    tree = generate_berggren_tree(2)
    print(f"Generated {len(tree)} triples up to depth 2")
    for word in sorted(tree.keys(), key=lambda w: (len(w), w)):
        t = tree[word]
        print(f"  {list(word) if word else '[]'}: ({t[0]}, {t[1]}, {t[2]})")

    # Example 2: Hecke algebra
    print("\n--- Algorithm 2: Hecke Algebra ---")
    H = HeckeAlgebra(2)
    signal = np.random.randn(H.num_states)
    Hf = H.hecke_average(signal)
    print(f"State space size: {H.num_states}")
    print(f"Hecke output is constant: {np.allclose(Hf, Hf[0])}")
    print(f"Constant value = total mass: {np.isclose(Hf[0], signal.sum())}")

    # Verify commutativity
    err = H.verify_commutativity((1, 0), (0, 2))
    print(f"Commutator norm: {err:.2e}")

    # Example 3: Period detection
    print("\n--- Algorithm 4: Period Detection ---")
    n = 4
    states_4 = list(product(range(3), repeat=n))

    # Create a 2-periodic signal
    np.random.seed(42)
    quotient_vals = {p: np.random.randn() for p in product(range(3), repeat=2)}
    signal_periodic = np.array([quotient_vals[s[:2]] for s in states_4])

    period = detect_branch_period(signal_periodic, n)
    print(f"Created 2-periodic signal on (Z/3Z)^{n}")
    print(f"Detected period: {period}")

    # Example 4: Certified reconstruction
    print("\n--- Algorithm 6: Certified Reconstruction ---")
    moments_dict = {s: signal_periodic[i] for i, s in enumerate(states_4)}
    result = certified_reconstruction(moments_dict, n)
    cert = result['certificate']
    print(f"Period: {result['period']}")
    print(f"Quotient size: {cert['quotient_size']}")
    print(f"Compression ratio: {cert['compression_ratio']:.1f}x")
    print(f"Reconstruction exact: {cert['reconstruction_exact']}")
    print(f"Max error: {cert['max_error']:.2e}")
