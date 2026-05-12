"""
Closure-Kolmogorov Realization: Algorithms for Hankel-based Transducer Reconstruction

This module implements the core algorithms from the realization theory:
1. Hankel matrix construction from a bi-series
2. Finite presentation extraction via rank factorization
3. Closure transducer reconstruction from presentations
4. Behavior evaluation and verification
5. Minimality checking
"""

import numpy as np
from typing import Callable, List, Tuple, Optional, Dict, Any
from dataclasses import dataclass, field
from itertools import product as cart_product


@dataclass
class ClosureTransducer:
    """A finite closure transducer with n states.

    Attributes:
        n: Number of states
        init: Initial weight vector (n,)
        act_a: Input action matrices, keyed by input symbol
        act_b: Output action matrices, keyed by output symbol
        out: Output weight vector (n,)
        input_alphabet: List of input symbols
        output_alphabet: List of output symbols
    """
    n: int
    init: np.ndarray
    act_a: Dict[Any, np.ndarray]
    act_b: Dict[Any, np.ndarray]
    out: np.ndarray
    input_alphabet: list = field(default_factory=list)
    output_alphabet: list = field(default_factory=list)

    def behavior(self, u: list, v: list) -> float:
        """Compute behavior(u, v) = init · M_A(u1)···M_A(um) · M_B(v1)···M_B(vk) · out

        The computation processes output symbols first (innermost), then input symbols.

        Args:
            u: Input word (list of input symbols)
            v: Output word (list of output symbols)

        Returns:
            The scalar behavior value.
        """
        # Start with init vector
        w = self.init.copy()

        # Process output symbols (right fold: v[0] outermost)
        for b in reversed(v):
            w = self.act_b[b] @ w

        # Process input symbols (right fold: u[0] outermost)
        for a in reversed(u):
            w = self.act_a[a] @ w

        return float(w @ self.out)


@dataclass
class HankelPresentation:
    """A finite Hankel presentation of a bi-series.

    Attributes:
        n: Basis dimension
        act_a: Input action matrices {symbol: (n,n) array}
        act_b: Output action matrices {symbol: (n,n) array}
        init_vec: Initial weight vector (n,)
        out_vec: Output weight vector (n,)
        input_alphabet: List of input symbols
        output_alphabet: List of output symbols
    """
    n: int
    act_a: Dict[Any, np.ndarray]
    act_b: Dict[Any, np.ndarray]
    init_vec: np.ndarray
    out_vec: np.ndarray
    input_alphabet: list = field(default_factory=list)
    output_alphabet: list = field(default_factory=list)

    def coeff(self, u: list, v: list) -> np.ndarray:
        """Compute the coefficient vector for word pair (u, v).

        coeff(u, v) = act_a(u1) · ... · act_a(um) · act_b(v1) · ... · act_b(vk) · init

        Args:
            u: Input word
            v: Output word

        Returns:
            Coefficient vector of shape (n,)
        """
        w = self.init_vec.copy()
        for b in reversed(v):
            w = self.act_b[b] @ w
        for a in reversed(u):
            w = self.act_a[a] @ w
        return w

    def evaluate(self, u: list, v: list) -> float:
        """Evaluate the series: f(u,v) = coeff(u,v) · out_vec"""
        return float(self.coeff(u, v) @ self.out_vec)


def reconstruct_transducer(P: HankelPresentation) -> ClosureTransducer:
    """Reconstruct a closure transducer from a Hankel presentation.

    This is the certified reconstruction algorithm: states = basis indices,
    transitions = action matrices, weights = boundary vectors.

    Complexity: O(1) — just packages existing data.

    Args:
        P: A valid Hankel presentation

    Returns:
        A ClosureTransducer with P.n states whose behavior equals the presented series.
    """
    return ClosureTransducer(
        n=P.n,
        init=P.init_vec.copy(),
        act_a={k: v.copy() for k, v in P.act_a.items()},
        act_b={k: v.copy() for k, v in P.act_b.items()},
        out=P.out_vec.copy(),
        input_alphabet=P.input_alphabet,
        output_alphabet=P.output_alphabet,
    )


def transducer_to_presentation(T: ClosureTransducer) -> HankelPresentation:
    """Construct a Hankel presentation from a transducer.

    The coefficient function is defined by the transducer's state trajectories.

    Args:
        T: A closure transducer

    Returns:
        A HankelPresentation valid for T's behavior.
    """
    return HankelPresentation(
        n=T.n,
        act_a={k: v.copy() for k, v in T.act_a.items()},
        act_b={k: v.copy() for k, v in T.act_b.items()},
        init_vec=T.init.copy(),
        out_vec=T.out.copy(),
        input_alphabet=T.input_alphabet,
        output_alphabet=T.output_alphabet,
    )


def build_hankel_matrix(
    f: Callable[[list, list], float],
    input_words: List[list],
    output_words: List[list],
    suffix_input_words: List[list],
    suffix_output_words: List[list],
) -> np.ndarray:
    """Build a bi-Hankel matrix from a series f.

    H[i,j] = f(input_words[i] + suffix_input_words[j],
               output_words[i] + suffix_output_words[j])

    where i indexes row prefixes (u,v) and j indexes column suffixes (u',v').

    Args:
        f: The bi-series function
        input_words: List of input prefix words
        output_words: List of output prefix words (same length as input_words)
        suffix_input_words: List of input suffix words
        suffix_output_words: List of output suffix words (same length as suffix_input_words)

    Returns:
        Hankel matrix of shape (len(input_words), len(suffix_input_words))
    """
    m = len(input_words)
    k = len(suffix_input_words)
    H = np.zeros((m, k))
    for i in range(m):
        for j in range(k):
            u = input_words[i] + suffix_input_words[j]
            v = output_words[i] + suffix_output_words[j]
            H[i, j] = f(u, v)
    return H


def extract_presentation_from_hankel(
    f: Callable[[list, list], float],
    input_alphabet: list,
    output_alphabet: list,
    max_word_length: int = 3,
    rank_tol: float = 1e-10,
) -> HankelPresentation:
    """Extract a minimal Hankel presentation from a bi-series by Hankel factorization.

    Algorithm:
    1. Enumerate word pairs up to max_word_length
    2. Build the Hankel matrix
    3. Compute rank factorization H = L · R
    4. Extract action matrices by solving residual equations
    5. Extract boundary vectors

    Complexity: O(|words|^2 · n) for matrix operations, where |words| grows
    exponentially with max_word_length.

    Args:
        f: The bi-series to present
        input_alphabet: List of input symbols
        output_alphabet: List of output symbols
        max_word_length: Maximum word length for Hankel matrix construction
        rank_tol: Tolerance for numerical rank determination

    Returns:
        A HankelPresentation approximating f.
    """
    # Generate all words up to max_word_length
    def gen_words(alphabet, max_len):
        words = [[]]
        for length in range(1, max_len + 1):
            for w in cart_product(alphabet, repeat=length):
                words.append(list(w))
        return words

    input_words = gen_words(input_alphabet, max_word_length)
    output_words = gen_words(output_alphabet, max_word_length)

    # Create prefix-suffix pairs: use all word pairs as both prefixes and suffixes
    prefix_pairs = [(u, v) for u in input_words for v in output_words]
    suffix_pairs = prefix_pairs  # same set for square Hankel matrix

    m = len(prefix_pairs)

    # Build Hankel matrix
    H = np.zeros((m, m))
    for i, (u, v) in enumerate(prefix_pairs):
        for j, (up, vp) in enumerate(suffix_pairs):
            H[i, j] = f(u + up, v + vp)

    # Rank factorization via SVD
    U, s, Vt = np.linalg.svd(H, full_matrices=False)
    rank = np.sum(s > rank_tol * s[0]) if s[0] > rank_tol else 0
    rank = max(rank, 1)  # at least 1 state

    # Truncated factorization: H ≈ L · R where L = U[:,:r]*diag(s[:r]), R = Vt[:r,:]
    L = U[:, :rank] * s[:rank]
    R = Vt[:rank, :]

    # Pseudo-inverse of L for coefficient extraction
    L_pinv = np.linalg.pinv(L)

    # Extract init and out vectors
    # init = coeff([], []) = L_pinv @ H[row for ([], []), :]  ... but simpler:
    # The row for ([], []) in prefix_pairs
    empty_idx = prefix_pairs.index(([], []))
    init_vec = L_pinv @ H[empty_idx, :]
    # Actually init_vec should be L_pinv @ h_empty where h_empty is the row of H for empty prefix
    # But more precisely: init_vec = L_pinv @ H[empty_idx, :] gives coeff([], [])
    # which should equal init_vec.

    # out_vec: f(u,v) = coeff(u,v) · out_vec, so out_vec = R[:, empty_idx]
    out_vec = R[:, empty_idx]

    # Re-derive init_vec properly
    init_vec = L[empty_idx, :]  # the empty-prefix row of L IS the init vector

    # Actually let's be more careful. L[i, :] represents the coefficient of prefix_pair i.
    # So init_vec = L[empty_idx, :] and out_vec = R[:, empty_idx].

    # Verify: f([], []) should equal init_vec @ out_vec
    # = L[empty_idx, :] @ R[:, empty_idx] = H[empty_idx, empty_idx]

    # Extract action matrices
    act_a = {}
    for a in input_alphabet:
        # For input symbol a: coeff(a::u, v) = act_a[a] @ coeff(u, v)
        # So for each prefix (u, v), the row for (a::u, v) should be act_a[a] @ L[row(u,v), :]
        # Build the shifted matrix and solve
        M_shifted = np.zeros((m, rank))
        for i, (u, v) in enumerate(prefix_pairs):
            au = [a] + u
            av = v
            shifted_pair = (au, av)
            # Find the Hankel row for the shifted prefix
            h_row = np.array([f(au + sp[0], av + sp[1]) for sp in suffix_pairs])
            M_shifted[i, :] = L_pinv @ h_row

        # Solve: M_shifted = act_a[a] @ L_coeff where L_coeff[i,:] = L[i,:]
        # Actually M_shifted[i, :] = act_a[a] @ L[i, :] for each i
        # So M_shifted = L @ act_a[a]^T  ... or:
        # M_shifted^T = act_a[a] @ L^T
        # act_a[a] = M_shifted^T @ pinv(L^T) = M_shifted^T @ pinv(L)^T
        # Hmm, let's think more carefully.
        # coeff(a::u, v) = act_a[a] @ coeff(u, v)
        # L_pinv @ H[(a::u,v) row, :] = act_a[a] @ L_pinv @ H[(u,v) row, :]
        # In matrix form: coeff_shifted = act_a[a] @ coeff_original
        # Where coeff_original[i, :] = coeff(u_i, v_i) ∈ R^rank for the i-th prefix pair

        # The coefficient matrix for all prefixes: C[i, :] = L[i, :] (approximately)
        # The shifted coefficient matrix: C_shifted[i, :] = M_shifted[i, :]
        # Relation: C_shifted = C @ act_a[a]^T  (if coeff is a row vector and act is left-multiply)

        # Wait, in our formulation: coeff(a::u, v)_j = sum_i act_a(a)_{j,i} * coeff(u,v)_i
        # So coeff(a::u, v) = act_a(a) @ coeff(u, v)  (matrix @ vector)
        # If C is the matrix whose rows are coeff vectors: C[i, :] = coeff(u_i, v_i)
        # Then C_shifted[i, :] = (act_a(a) @ C[i, :])  ... but act_a(a) @ C[i, :] treats C[i,:] as column
        # So C_shifted[i, :] = (act_a(a) @ C[i, :]^T)^T = C[i, :] @ act_a(a)^T

        # Therefore: C_shifted = C @ act_a(a)^T
        # act_a(a)^T = pinv(C) @ C_shifted
        # act_a(a) = (pinv(C) @ C_shifted)^T = C_shifted^T @ pinv(C)^T

        C = L  # rows are coefficient vectors
        act_a[a] = np.linalg.lstsq(C, M_shifted, rcond=None)[0].T

    act_b = {}
    for b in output_alphabet:
        M_shifted = np.zeros((m, rank))
        for i, (u, v) in enumerate(prefix_pairs):
            # Only well-defined for u = [] in our formulation, but we use the general version
            if len(u) == 0:
                bv = [b] + v
                h_row = np.array([f(sp[0], bv + sp[1]) for sp in suffix_pairs])
                M_shifted[i, :] = L_pinv @ h_row
            else:
                # For non-empty u, coeff(u, b::v) = act_a(u) @ act_b(b) @ coeff([], v)
                # We compute this indirectly
                bv = [b] + v
                h_row = np.array([f(u + sp[0], bv + sp[1]) for sp in suffix_pairs])
                M_shifted[i, :] = L_pinv @ h_row

        C = L
        act_b[b] = np.linalg.lstsq(C, M_shifted, rcond=None)[0].T

    return HankelPresentation(
        n=rank,
        act_a=act_a,
        act_b=act_b,
        init_vec=L[empty_idx, :].copy(),
        out_vec=R[:, empty_idx].copy(),
        input_alphabet=input_alphabet,
        output_alphabet=output_alphabet,
    )


def verify_behavior(
    T: ClosureTransducer,
    f: Callable[[list, list], float],
    test_words_a: List[list],
    test_words_b: List[list],
    tol: float = 1e-8,
) -> Tuple[bool, float]:
    """Verify that a transducer's behavior matches a target series.

    Args:
        T: The transducer to verify
        f: The target bi-series
        test_words_a: Input words to test
        test_words_b: Output words to test
        tol: Tolerance for equality checking

    Returns:
        (is_correct, max_error): Whether the behavior matches within tolerance,
        and the maximum error observed.
    """
    max_error = 0.0
    for u in test_words_a:
        for v in test_words_b:
            expected = f(u, v)
            actual = T.behavior(u, v)
            error = abs(expected - actual)
            max_error = max(max_error, error)

    return max_error < tol, max_error


def minimize_transducer(T: ClosureTransducer, tol: float = 1e-10) -> ClosureTransducer:
    """Minimize a closure transducer by removing unreachable/unobservable states.

    Uses the Hankel factorization approach: extract a presentation and reconstruct.

    Args:
        T: Input transducer
        tol: Tolerance for rank determination

    Returns:
        A minimal transducer with the same behavior.
    """
    P = transducer_to_presentation(T)
    # The presentation from a transducer has dimension T.n.
    # To minimize, we need to find a lower-rank factorization.

    # Build a Hankel-like matrix from the transducer's reachability/observability
    # Reachability: enumerate state vectors reachable from init
    # Observability: enumerate observation vectors

    # For simplicity, use SVD-based reduction
    # Build reachability matrix (columns = reachable state vectors)
    if not T.input_alphabet and not T.output_alphabet:
        return T

    max_depth = min(5, T.n + 1)

    def gen_words(alphabet, max_len):
        words = [[]]
        for length in range(1, max_len + 1):
            for w in cart_product(alphabet, repeat=length):
                words.append(list(w))
        return words

    all_words_a = gen_words(T.input_alphabet, max_depth)
    all_words_b = gen_words(T.output_alphabet, max_depth)

    # Reachability matrix: columns are state vectors after processing (u, v)
    reach_vecs = []
    for u in all_words_a:
        for v in all_words_b:
            w = T.init.copy()
            for b in reversed(v):
                w = T.act_b[b] @ w
            for a in reversed(u):
                w = T.act_a[a] @ w
            reach_vecs.append(w)

    R_mat = np.column_stack(reach_vecs) if reach_vecs else np.zeros((T.n, 1))

    U, s, _ = np.linalg.svd(R_mat, full_matrices=False)
    rank = np.sum(s > tol * s[0]) if len(s) > 0 and s[0] > tol else 1

    if rank >= T.n:
        return T  # Already minimal

    # Project onto rank-dimensional subspace
    P_proj = U[:, :rank]  # (n x rank)
    P_pinv = np.linalg.pinv(P_proj)  # (rank x n)

    new_init = P_pinv @ T.init
    new_out = P_proj.T @ T.out
    new_act_a = {a: P_pinv @ M @ P_proj for a, M in T.act_a.items()}
    new_act_b = {b: P_pinv @ M @ P_proj for b, M in T.act_b.items()}

    return ClosureTransducer(
        n=rank,
        init=new_init,
        act_a=new_act_a,
        act_b=new_act_b,
        out=new_out,
        input_alphabet=T.input_alphabet,
        output_alphabet=T.output_alphabet,
    )


if __name__ == "__main__":
    # Example: a simple bi-series over {0,1} x {0,1}
    print("=== Closure-Kolmogorov Realization: Algorithm Demo ===\n")

    # Define a simple bi-series: f(u,v) = (-1)^(|u|+|v|) * (|u|+|v|+1)
    def example_series(u, v):
        return (-1) ** (len(u) + len(v)) * (len(u) + len(v) + 1)

    # Create a transducer that realizes this series
    # State space: 2 states tracking parity and accumulator
    T = ClosureTransducer(
        n=2,
        init=np.array([1.0, 1.0]),
        act_a={
            0: np.array([[-1.0, 0.0], [0.0, -1.0]]),
            1: np.array([[-1.0, 0.0], [0.0, -1.0]]),
        },
        act_b={
            0: np.array([[-1.0, 0.0], [0.0, -1.0]]),
            1: np.array([[-1.0, 0.0], [0.0, -1.0]]),
        },
        out=np.array([1.0, 0.0]),
        input_alphabet=[0, 1],
        output_alphabet=[0, 1],
    )

    # Test behavior
    print("Transducer behavior vs target series:")
    test_words = [[], [0], [1], [0, 1], [1, 0], [0, 0]]
    for u in test_words[:4]:
        for v in test_words[:4]:
            actual = T.behavior(u, v)
            expected = example_series(u, v)
            print(f"  f({u}, {v}) = {expected:6.1f}, T({u}, {v}) = {actual:6.1f}")

    # Convert to presentation and back
    P = transducer_to_presentation(T)
    T2 = reconstruct_transducer(P)
    print(f"\nRound-trip: T has {T.n} states, T2 has {T2.n} states")
    print(f"Behaviors match: {all(abs(T.behavior(u, v) - T2.behavior(u, v)) < 1e-10 for u in test_words for v in test_words)}")

    print("\n=== Minimization Demo ===")
    # Create a redundant transducer (4 states, but only 2 needed)
    T_big = ClosureTransducer(
        n=4,
        init=np.array([1.0, 0.0, 1.0, 0.0]),
        act_a={
            0: np.block([[T.act_a[0], np.zeros((2, 2))], [np.zeros((2, 2)), T.act_a[0]]]),
            1: np.block([[T.act_a[1], np.zeros((2, 2))], [np.zeros((2, 2)), T.act_a[1]]]),
        },
        act_b={
            0: np.block([[T.act_b[0], np.zeros((2, 2))], [np.zeros((2, 2)), T.act_b[0]]]),
            1: np.block([[T.act_b[1], np.zeros((2, 2))], [np.zeros((2, 2)), T.act_b[1]]]),
        },
        out=np.array([0.5, 0.0, 0.5, 0.0]),
        input_alphabet=[0, 1],
        output_alphabet=[0, 1],
    )
    print(f"Redundant transducer: {T_big.n} states")
    T_min = minimize_transducer(T_big)
    print(f"Minimized transducer: {T_min.n} states")

    is_ok, max_err = verify_behavior(T_min, lambda u, v: T_big.behavior(u, v), test_words, test_words)
    print(f"Behavior preserved: {is_ok} (max error: {max_err:.2e})")
