#!/usr/bin/env python3
"""
Algorithms for Berggren Quantum Walk Spectral Realization

Implements the core algorithms from the spectral realization theory:
1. Reachable submodule rank computation
2. Hankel matrix construction and rank analysis
3. Minimal realization extraction (SVD-based)
4. Amplitude reconstruction from minimal model
5. Boundary data reconstruction
"""

import numpy as np
from typing import List, Tuple, Dict, Optional
import itertools


def generate_words(alphabet: str, max_length: int) -> List[str]:
    """Generate all words over alphabet up to given length.

    Args:
        alphabet: String of generator symbols (e.g., 'ABC')
        max_length: Maximum word length

    Returns:
        List of all words of length 0 to max_length

    Time complexity: O(|alphabet|^max_length)
    Space complexity: O(|alphabet|^max_length)
    """
    words = ['']
    for length in range(1, max_length + 1):
        for w in itertools.product(alphabet, repeat=length):
            words.append(''.join(w))
    return words


def eval_word_matrix(generators: Dict[str, np.ndarray], word: str) -> np.ndarray:
    """Evaluate a word as a product of generator matrices.

    Convention: word "g1g2...gk" maps to generators[g1] @ generators[g2] @ ... @ generators[gk]

    Args:
        generators: Dict mapping generator symbols to matrices
        word: String of generator symbols

    Returns:
        Product matrix

    Time complexity: O(n³ * |word|) where n is the matrix dimension
    """
    n = next(iter(generators.values())).shape[0]
    result = np.eye(n, dtype=complex)
    for g in reversed(word):
        result = generators[g] @ result
    return result


def compute_reachable_rank(generators: Dict[str, np.ndarray],
                           psi0: np.ndarray,
                           max_depth: int,
                           tol: float = 1e-10) -> Tuple[List[int], int]:
    """Compute the reachable submodule rank at each depth.

    Implements Theorem A: the rank stabilizes at finite depth N ≤ dim(V).

    Algorithm:
        For each depth d = 0, 1, ..., max_depth:
            1. Collect all states evalWord(w) @ psi0 for |w| ≤ d
            2. Stack them as rows of a matrix
            3. Compute the numerical rank

    Args:
        generators: Dict mapping generator symbols to unitary matrices
        psi0: Initial state vector
        max_depth: Maximum depth to explore
        tol: Tolerance for numerical rank

    Returns:
        (ranks, stabilization_depth) where ranks[d] is the rank at depth d

    Time complexity: O(n³ * Σ_{d=0}^{max_depth} |alphabet|^d)
    Space complexity: O(n * Σ_{d=0}^{max_depth} |alphabet|^d)
    """
    alphabet = ''.join(generators.keys())
    ranks = []
    all_states = []

    for depth in range(max_depth + 1):
        if depth == 0:
            all_states.append(psi0.copy())
        else:
            for word in itertools.product(alphabet, repeat=depth):
                w = ''.join(word)
                state = eval_word_matrix(generators, w) @ psi0
                all_states.append(state)

        matrix = np.vstack([s.reshape(1, -1) for s in all_states])
        rank = np.linalg.matrix_rank(matrix, tol=tol)
        ranks.append(rank)

    # Find stabilization depth
    stab = 0
    for i in range(len(ranks) - 1):
        if ranks[i] == ranks[i + 1]:
            stab = i
            break
    else:
        stab = len(ranks) - 1

    return ranks, stab


def build_hankel_matrix(generators: Dict[str, np.ndarray],
                        psi0: np.ndarray,
                        obs: np.ndarray,
                        depth: int) -> Tuple[np.ndarray, List[str]]:
    """Build the truncated Hankel matrix H(u,v) = obs^* @ generators(u++v) @ psi0.

    Args:
        generators: Dict mapping generator symbols to matrices
        psi0: Initial state vector
        obs: Observation vector
        depth: Truncation depth (words up to this length)

    Returns:
        (H, words) where H[i,j] = amplitude(words[i] + words[j])

    Time complexity: O(n³ * W² + n * W²) where W = number of words
    Space complexity: O(W² + n * W)
    """
    alphabet = ''.join(generators.keys())
    words = generate_words(alphabet, depth)
    W = len(words)

    # Precompute amplitudes for all concatenated words
    H = np.zeros((W, W), dtype=complex)
    for i, u in enumerate(words):
        for j, v in enumerate(words):
            concat = u + v
            state = eval_word_matrix(generators, concat) @ psi0
            H[i, j] = np.conj(obs) @ state

    return H, words


def extract_minimal_realization(generators: Dict[str, np.ndarray],
                                 psi0: np.ndarray,
                                 obs: np.ndarray,
                                 depth: int,
                                 tol: float = 1e-10) -> Dict:
    """Extract the minimal finite realization from Hankel data.

    Implements Theorem C: constructs the canonical smallest finite-dimensional
    model that reproduces all amplitudes.

    Algorithm (SVD-based Hankel realization):
        1. Build Hankel matrix H(u,v) = amplitude(u ++ v)
        2. Compute SVD: H = U Σ V^*
        3. Truncate to rank r: H ≈ U_r Σ_r V_r^*
        4. Extract initial vector: α = V_r^* e_0 (first column)
        5. Extract output: ω = U_r^* e_0 (first row)
        6. For each generator g, build shifted Hankel H_g(u,v) = amplitude(u ++ g ++ v)
        7. Project: T_g = (U_r Σ_r^{1/2})^+ H_g (V_r Σ_r^{1/2})^+

    Args:
        generators: Dict mapping generator symbols to matrices
        psi0: Initial state vector
        obs: Observation vector
        depth: Truncation depth
        tol: Tolerance for rank determination

    Returns:
        Dict with keys: 'T' (generator matrices), 'init', 'out', 'dim', 'rank'

    Time complexity: O(W³) where W = number of words up to depth
    Space complexity: O(W²)
    """
    alphabet = ''.join(generators.keys())
    H, words = build_hankel_matrix(generators, psi0, obs, depth)
    W = len(words)
    rank = np.linalg.matrix_rank(H, tol=tol)

    # SVD
    U, S, Vh = np.linalg.svd(H)
    sqrt_S = np.sqrt(S[:rank])
    U_r = U[:, :rank] * sqrt_S[np.newaxis, :]
    V_r = Vh[:rank, :].T * sqrt_S[np.newaxis, :]

    # Initial and output vectors
    init = V_r[0, :]  # Row 0 = empty word
    output = U_r[0, :]

    # Shifted Hankel matrices and generator projections
    U_pinv = np.linalg.pinv(U_r)  # rank × W
    V_r_pinv = np.linalg.pinv(V_r.T)  # W × rank

    T = {}
    for g in alphabet:
        H_g = np.zeros((W, W), dtype=complex)
        for i, u in enumerate(words):
            for j, v in enumerate(words):
                state = eval_word_matrix(generators, u + g + v) @ psi0
                H_g[i, j] = np.conj(obs) @ state

        T[g] = U_pinv @ H_g @ V_r_pinv  # rank × rank

    return {
        'T': T,
        'init': init,
        'out': output,
        'dim': rank,
        'rank': rank
    }


def reconstruct_amplitude(realization: Dict, word: str) -> complex:
    """Reconstruct an amplitude from a minimal realization.

    Computes: out @ T_{w_1} @ T_{w_2} @ ... @ T_{w_k} @ init

    Args:
        realization: Dict from extract_minimal_realization
        word: Word to evaluate

    Returns:
        Reconstructed amplitude value

    Time complexity: O(r² * |word|) where r is the realization dimension
    """
    state = realization['init'].copy()
    for g in reversed(word):
        state = realization['T'][g] @ state
    return realization['out'] @ state


def verify_reconstruction(generators: Dict[str, np.ndarray],
                          psi0: np.ndarray,
                          obs: np.ndarray,
                          realization: Dict,
                          test_words: List[str]) -> Dict[str, float]:
    """Verify that a minimal realization correctly reconstructs amplitudes.

    Args:
        generators, psi0, obs: Original quantum walk parameters
        realization: Minimal realization from extract_minimal_realization
        test_words: Words to test

    Returns:
        Dict mapping words to reconstruction errors
    """
    errors = {}
    for w in test_words:
        true_amp = np.conj(obs) @ eval_word_matrix(generators, w) @ psi0
        recon_amp = reconstruct_amplitude(realization, w)
        errors[w] = abs(true_amp - recon_amp)
    return errors


def level_amplitude_recurrence(generators: Dict[str, np.ndarray],
                                psi0: np.ndarray,
                                obs: np.ndarray,
                                max_level: int) -> Tuple[np.ndarray, Optional[np.ndarray]]:
    """Compute level amplitudes and detect linear recurrence.

    The level amplitude at depth n is the sum of amplitudes over all
    words of length n. Under the finite realization, these satisfy a
    linear recurrence of order ≤ dim(realization).

    Args:
        generators, psi0, obs: Quantum walk parameters
        max_level: Maximum level to compute

    Returns:
        (level_amps, recurrence_coeffs) where recurrence_coeffs[i] are
        the coefficients c_i such that a_n = sum_i c_i * a_{n-d+i}
    """
    alphabet = ''.join(generators.keys())
    level_amps = np.zeros(max_level + 1, dtype=complex)

    for n in range(max_level + 1):
        if n == 0:
            level_amps[0] = np.conj(obs) @ psi0
        else:
            for word in itertools.product(alphabet, repeat=n):
                w = ''.join(word)
                state = eval_word_matrix(generators, w) @ psi0
                level_amps[n] += np.conj(obs) @ state

    # Try to find recurrence
    recurrence = None
    for d in range(1, max_level // 2 + 1):
        # Build system: a_{d+k} = sum_{i=0}^{d-1} c_i * a_{k+i} for k=0,...,d-1
        if 2 * d > max_level:
            break
        A = np.zeros((d, d), dtype=complex)
        b = np.zeros(d, dtype=complex)
        for k in range(d):
            for i in range(d):
                A[k, i] = level_amps[k + i]
            b[k] = level_amps[d + k]

        try:
            c = np.linalg.solve(A, b)
            # Verify on remaining data
            ok = True
            for k in range(d, max_level - d + 1):
                predicted = sum(c[i] * level_amps[k + i] for i in range(d))
                if abs(predicted - level_amps[d + k]) > 1e-8:
                    ok = False
                    break
            if ok:
                recurrence = c
                break
        except np.linalg.LinAlgError:
            continue

    return level_amps, recurrence


if __name__ == '__main__':
    # Quick demonstration
    np.random.seed(42)
    n = 3

    # Random unitary generators
    def random_unitary(dim):
        Z = (np.random.randn(dim, dim) + 1j * np.random.randn(dim, dim)) / np.sqrt(2)
        Q, R = np.linalg.qr(Z)
        D = np.diag(np.diag(R) / np.abs(np.diag(R)))
        return Q @ D

    gens = {g: random_unitary(n) for g in 'ABC'}
    psi0 = np.array([1, 0, 0], dtype=complex)
    obs = np.array([1, 0, 0], dtype=complex)

    print("=== Reachable Rank Analysis ===")
    ranks, stab = compute_reachable_rank(gens, psi0, 5)
    print(f"Ranks by depth: {ranks}")
    print(f"Stabilization depth: {stab}")

    print("\n=== Minimal Realization ===")
    real = extract_minimal_realization(gens, psi0, obs, 3)
    print(f"Realization dimension: {real['dim']}")

    print("\n=== Reconstruction Verification ===")
    test = ['', 'A', 'B', 'C', 'AB', 'BA', 'ABC', 'CBA', 'ABCA']
    errors = verify_reconstruction(gens, psi0, obs, real, test)
    for w, err in errors.items():
        print(f"  word='{w}': error = {err:.2e}")

    print("\n=== Level Amplitude Recurrence ===")
    amps, rec = level_amplitude_recurrence(gens, psi0, obs, 8)
    print(f"Level amplitudes: {[f'{a:.4f}' for a in amps]}")
    if rec is not None:
        print(f"Recurrence coefficients (order {len(rec)}): {rec}")
    else:
        print("No simple recurrence detected")
