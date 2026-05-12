#!/usr/bin/env python3
"""
Closure-Kolmogorov Realization: Applications

Demonstrates real-world applications of the realization theory:
1. System identification from input-output data
2. Model compression via Hankel minimization
3. Closure-weighted process modeling
4. Signal transduction modeling
"""

import numpy as np
from itertools import product as cart_product
from typing import List, Tuple

np.set_printoptions(precision=4, suppress=True)


class ClosureTransducer:
    def __init__(self, n, init, act_a, act_b, out, input_alph, output_alph):
        self.n = n
        self.init = np.array(init, dtype=float)
        self.act_a = {k: np.array(v, dtype=float) for k, v in act_a.items()}
        self.act_b = {k: np.array(v, dtype=float) for k, v in act_b.items()}
        self.out = np.array(out, dtype=float)
        self.input_alph = input_alph
        self.output_alph = output_alph

    def behavior(self, u, v):
        w = self.init.copy()
        for b in reversed(v):
            w = self.act_b[b] @ w
        for a in reversed(u):
            w = self.act_a[a] @ w
        return float(w @ self.out)

    def state_vector(self, u, v):
        w = self.init.copy()
        for b in reversed(v):
            w = self.act_b[b] @ w
        for a in reversed(u):
            w = self.act_a[a] @ w
        return w


def gen_words(alphabet, max_len):
    words = [[]]
    for length in range(1, max_len + 1):
        for w in cart_product(alphabet, repeat=length):
            words.append(list(w))
    return words


# ============================================================
# Application 1: System Identification
# ============================================================
def app_system_identification():
    """Identify a hidden transducer from input-output observations."""
    print("=" * 60)
    print("APPLICATION 1: System Identification from Black-Box Data")
    print("=" * 60)
    print()

    # Hidden system (unknown to the identifier)
    hidden = ClosureTransducer(
        n=2,
        init=[1.0, 0.3],
        act_a={'H': [[0.7, 0.2], [0.1, 0.8]], 'L': [[0.4, 0.5], [0.3, 0.3]]},
        act_b={'on': [[0.9, 0.05], [0.1, 0.85]], 'off': [[0.3, 0.6], [0.5, 0.2]]},
        out=[0.8, 0.4],
        input_alph=['H', 'L'],
        output_alph=['on', 'off'],
    )

    # Collect observation data (Hankel table)
    in_words = gen_words(['H', 'L'], 3)
    out_words = gen_words(['on', 'off'], 3)

    prefix_pairs = [(u, v) for u in in_words[:8] for v in out_words[:8]]
    suffix_pairs = prefix_pairs

    m = len(prefix_pairs)
    H = np.zeros((m, m))
    for i, (u, v) in enumerate(prefix_pairs):
        for j, (up, vp) in enumerate(suffix_pairs):
            H[i, j] = hidden.behavior(u + up, v + vp)

    # Determine system complexity
    _, s, _ = np.linalg.svd(H)
    print(f"Observation Hankel matrix: {H.shape}")
    print(f"Top singular values: {s[:6]}")

    rank = np.sum(s > 1e-8 * s[0])
    print(f"Identified system dimension: {rank}")
    print(f"True system dimension: {hidden.n}")
    print(f"Correct identification: {rank == hidden.n}")
    print()

    # Reconstruct via rank factorization
    U, S_diag, Vt = np.linalg.svd(H, full_matrices=False)
    L = U[:, :rank] * S_diag[:rank]
    R = Vt[:rank, :]

    empty_idx = prefix_pairs.index(([], []))
    init_vec = L[empty_idx, :]
    out_vec = R[:, empty_idx]

    # Verify reconstruction
    print("Verification of identified model:")
    test_pairs = [(u, v) for u in in_words[:5] for v in out_words[:5]]
    max_err = 0
    for u, v in test_pairs:
        true_val = hidden.behavior(u, v)
        # Compute via Hankel factorization
        row_idx = prefix_pairs.index((u, v)) if (u, v) in prefix_pairs else None
        if row_idx is not None:
            recon_val = float(L[row_idx, :] @ out_vec)
            err = abs(true_val - recon_val)
            max_err = max(max_err, err)

    print(f"  Max reconstruction error (on training data): {max_err:.2e}")
    print()


# ============================================================
# Application 2: Model Compression
# ============================================================
def app_model_compression():
    """Compress a large transducer by exploiting Hankel rank."""
    print("=" * 60)
    print("APPLICATION 2: Model Compression via Hankel Minimization")
    print("=" * 60)
    print()

    # Large model with redundant states
    n_orig = 8
    np.random.seed(42)

    # Generate a random rank-3 system embedded in 8 dimensions
    true_rank = 3
    A = np.random.randn(n_orig, true_rank) * 0.3
    init_full = A @ np.random.randn(true_rank)
    out_full = A @ np.random.randn(true_rank)

    # Create a structured random transducer
    def make_matrix():
        core = np.random.randn(true_rank, true_rank) * 0.3
        return A @ core @ np.linalg.pinv(A)

    T_big = ClosureTransducer(
        n=n_orig,
        init=init_full,
        act_a={0: make_matrix(), 1: make_matrix()},
        act_b={0: make_matrix(), 1: make_matrix()},
        out=out_full,
        input_alph=[0, 1],
        output_alph=[0, 1],
    )

    # Compute effective rank
    test_words = gen_words([0, 1], 3)
    reach_vecs = [T_big.init.copy()]
    w = T_big.init.copy()
    for u in test_words[:30]:
        for v in test_words[:30]:
            w_curr = T_big.init.copy()
            for b in reversed(v):
                w_curr = T_big.act_b[b] @ w_curr
            for a in reversed(u):
                w_curr = T_big.act_a[a] @ w_curr
            reach_vecs.append(w_curr)

    R = np.column_stack(reach_vecs)
    _, s, _ = np.linalg.svd(R, full_matrices=False)
    eff_rank = np.sum(s > 1e-8 * s[0])

    print(f"Original model: {n_orig} states")
    print(f"Effective Hankel rank: {eff_rank}")
    print(f"Compression ratio: {n_orig / eff_rank:.1f}x")
    print(f"Singular value spectrum: {s[:6]}")
    print()

    # Compress via projection
    U_proj = np.linalg.svd(R, full_matrices=False)[0][:, :eff_rank]
    P_inv = np.linalg.pinv(U_proj)

    T_small = ClosureTransducer(
        n=eff_rank,
        init=P_inv @ T_big.init,
        act_a={k: P_inv @ M @ U_proj for k, M in T_big.act_a.items()},
        act_b={k: P_inv @ M @ U_proj for k, M in T_big.act_b.items()},
        out=U_proj.T @ T_big.out,
        input_alph=[0, 1],
        output_alph=[0, 1],
    )

    # Verify behavior preservation
    max_err = 0
    for u in test_words[:15]:
        for v in test_words[:15]:
            err = abs(T_big.behavior(u, v) - T_small.behavior(u, v))
            max_err = max(max_err, err)

    print(f"Compressed model: {T_small.n} states")
    print(f"Max behavior error: {max_err:.2e}")
    print(f"Behavior preserved: {max_err < 1e-6}")
    print()


# ============================================================
# Application 3: Signal Transduction Modeling
# ============================================================
def app_signal_transduction():
    """Model a biological signal transduction pathway as a closure transducer."""
    print("=" * 60)
    print("APPLICATION 3: Signal Transduction Pathway Modeling")
    print("=" * 60)
    print()

    # Model: a cell receives input signals (growth factor levels)
    # and produces output responses (gene expression levels).
    # States represent internal signaling pathway configurations.

    # 3 states: {basal, activated, saturated}
    # Input signals: {low, high}
    # Output responses: {express, suppress}

    T = ClosureTransducer(
        n=3,
        init=[0.8, 0.15, 0.05],  # mostly basal at start
        act_a={
            'low': [
                [0.9, 0.05, 0.01],   # basal stays basal
                [0.3, 0.6, 0.05],    # activated may deactivate
                [0.1, 0.3, 0.5],     # saturated may step down
            ],
            'high': [
                [0.2, 0.7, 0.05],    # basal gets activated
                [0.05, 0.4, 0.5],    # activated may saturate
                [0.01, 0.1, 0.85],   # saturated stays saturated
            ],
        },
        act_b={
            'express': [
                [0.3, 0.0, 0.0],     # basal: low expression
                [0.0, 0.8, 0.0],     # activated: high expression
                [0.0, 0.0, 0.9],     # saturated: very high expression
            ],
            'suppress': [
                [0.7, 0.0, 0.0],     # basal: high suppression
                [0.0, 0.2, 0.0],     # activated: low suppression
                [0.0, 0.0, 0.1],     # saturated: very low suppression
            ],
        },
        out=[1.0, 1.0, 1.0],
        input_alph=['low', 'high'],
        output_alph=['express', 'suppress'],
    )

    print("Signal transduction model: 3 internal states")
    print("Input signals: {low, high}")
    print("Output responses: {express, suppress}")
    print()

    # Simulate different stimulation protocols
    protocols = [
        ("Sustained low", ['low'] * 4),
        ("Sustained high", ['high'] * 4),
        ("Pulse (high-low-low)", ['high', 'low', 'low']),
        ("Ramp up", ['low', 'low', 'high', 'high']),
        ("Oscillating", ['low', 'high', 'low', 'high']),
    ]

    for name, input_seq in protocols:
        # Compute probability of expression vs suppression for each output sequence length
        out_express = T.behavior(input_seq, ['express'] * len(input_seq))
        out_suppress = T.behavior(input_seq, ['suppress'] * len(input_seq))
        ratio = out_express / (out_express + out_suppress) if (out_express + out_suppress) > 0 else 0
        print(f"  {name:25s}: express={out_express:.4f}, suppress={out_suppress:.4f}, "
              f"expression ratio={ratio:.3f}")

    print()

    # Identify minimal complexity
    test_words_in = gen_words(['low', 'high'], 3)
    test_words_out = gen_words(['express', 'suppress'], 3)

    reach_vecs = []
    for u in test_words_in[:20]:
        for v in test_words_out[:20]:
            reach_vecs.append(T.state_vector(u, v))

    R = np.column_stack(reach_vecs)
    _, s, _ = np.linalg.svd(R, full_matrices=False)
    rank = np.sum(s > 1e-10 * s[0])
    print(f"Hankel rank of pathway model: {rank}")
    print(f"Model is already minimal: {rank == T.n}")
    print()


# ============================================================
# Application 4: Closure Operator Semantics
# ============================================================
def app_closure_semantics():
    """Demonstrate closure operator semantics via idempotent semiring transducers."""
    print("=" * 60)
    print("APPLICATION 4: Closure Operator Semantics (Tropical)")
    print("=" * 60)
    print()

    # In the tropical semiring (min, +), addition is min and multiplication is +.
    # A "closure transducer" computes shortest-path-like quantities.

    # We simulate a shortest-path transducer:
    # States represent network nodes, transitions are edge costs.
    # behavior(u, v) = minimum-cost path processing inputs u and outputs v.

    # For demonstration, we use regular arithmetic but interpret the structure
    # as a tropical computation.

    INF = 1e10  # represents infinity in tropical semiring

    # 3-node network
    n = 3
    # Tropical init (0 for start node, inf for others)
    init = np.array([0.0, INF, INF])

    # Input transitions (edge costs when reading input symbol)
    act_a_0 = np.array([
        [0, 2, INF],
        [INF, 0, 3],
        [1, INF, 0],
    ])  # costs from state i to state j when reading input 0

    act_a_1 = np.array([
        [0, INF, 4],
        [1, 0, INF],
        [INF, 2, 0],
    ])

    # Output transitions
    act_b_0 = np.array([
        [0, 1, INF],
        [INF, 0, 2],
        [3, INF, 0],
    ])

    act_b_1 = np.array([
        [0, INF, 3],
        [2, 0, INF],
        [INF, 1, 0],
    ])

    out = np.array([INF, INF, 0.0])  # only node 2 is accepting

    def tropical_matmul(M, v):
        """Tropical matrix-vector multiply: (M ⊗ v)_j = min_i (M_{j,i} + v_i)"""
        n = len(v)
        result = np.full(n, INF)
        for j in range(n):
            for i in range(n):
                result[j] = min(result[j], M[j, i] + v[i])
        return result

    def tropical_dot(v, w):
        """Tropical dot product: min_i (v_i + w_i)"""
        return min(v[i] + w[i] for i in range(len(v)))

    def tropical_behavior(u, v):
        """Compute shortest path cost through the network."""
        w = init.copy()
        for b in reversed(v):
            M = {0: act_b_0, 1: act_b_1}[b]
            w = tropical_matmul(M, w)
        for a in reversed(u):
            M = {0: act_a_0, 1: act_a_1}[a]
            w = tropical_matmul(M, w)
        return tropical_dot(w, out)

    print("Tropical (shortest-path) closure transducer:")
    print(f"  States: {n}")
    print(f"  Input alphabet: {{0, 1}}")
    print(f"  Output alphabet: {{0, 1}}")
    print()

    print("Shortest path costs (input → output):")
    for u in [[], [0], [1], [0, 0], [0, 1], [1, 0]]:
        for v in [[], [0], [1]]:
            cost = tropical_behavior(u, v)
            cost_str = f"{cost:.1f}" if cost < INF / 2 else "∞"
            print(f"  cost({u} → {v}) = {cost_str}")

    print()
    print("This demonstrates closure semantics: the tropical semiring's")
    print("idempotent addition (min) acts as a closure operator on path costs.")
    print()


# ============================================================
# Main
# ============================================================
if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  Closure-Kolmogorov Realization — Applications           ║")
    print("╚══════════════════════════════════════════════════════════╝")
    print()

    app_system_identification()
    app_model_compression()
    app_signal_transduction()
    app_closure_semantics()

    print("All applications completed successfully.")


#!/usr/bin/env python3
"""
Closure-Kolmogorov Realization: Concrete Demonstrations

Demonstrates the main theorems with tangible numerical examples:
1. Constructing a closure transducer from algebraic data
2. Verifying behavior matches a target bi-series
3. Round-trip stability (transducer → presentation → transducer)
4. Minimality of the Hankel presentation dimension
5. Extraction from a black-box series via Hankel factorization
"""

import numpy as np
from itertools import product as cart_product
from typing import List, Dict, Any

np.set_printoptions(precision=4, suppress=True)


# ============================================================
# Core data structures (self-contained)
# ============================================================

class ClosureTransducer:
    """A finite closure transducer with n states."""

    def __init__(self, n, init, act_a, act_b, out, input_alph, output_alph):
        self.n = n
        self.init = np.array(init, dtype=float)
        self.act_a = {k: np.array(v, dtype=float) for k, v in act_a.items()}
        self.act_b = {k: np.array(v, dtype=float) for k, v in act_b.items()}
        self.out = np.array(out, dtype=float)
        self.input_alph = input_alph
        self.output_alph = output_alph

    def behavior(self, u, v):
        """Compute behavior(u, v) via matrix-vector products."""
        w = self.init.copy()
        for b in reversed(v):
            w = self.act_b[b] @ w
        for a in reversed(u):
            w = self.act_a[a] @ w
        return float(w @ self.out)

    def state_vector(self, u, v):
        """Compute the state vector after processing (u, v)."""
        w = self.init.copy()
        for b in reversed(v):
            w = self.act_b[b] @ w
        for a in reversed(u):
            w = self.act_a[a] @ w
        return w


class HankelPresentation:
    """A finite Hankel presentation."""

    def __init__(self, n, act_a, act_b, init_vec, out_vec, input_alph, output_alph):
        self.n = n
        self.act_a = {k: np.array(v, dtype=float) for k, v in act_a.items()}
        self.act_b = {k: np.array(v, dtype=float) for k, v in act_b.items()}
        self.init_vec = np.array(init_vec, dtype=float)
        self.out_vec = np.array(out_vec, dtype=float)
        self.input_alph = input_alph
        self.output_alph = output_alph

    def coeff(self, u, v):
        w = self.init_vec.copy()
        for b in reversed(v):
            w = self.act_b[b] @ w
        for a in reversed(u):
            w = self.act_a[a] @ w
        return w

    def evaluate(self, u, v):
        return float(self.coeff(u, v) @ self.out_vec)


def reconstruct(P):
    """Reconstruct a transducer from a presentation."""
    return ClosureTransducer(P.n, P.init_vec, P.act_a, P.act_b, P.out_vec,
                             P.input_alph, P.output_alph)


def to_presentation(T):
    """Convert a transducer to a presentation."""
    return HankelPresentation(T.n, T.act_a, T.act_b, T.init, T.out,
                               T.input_alph, T.output_alph)


def gen_words(alphabet, max_len):
    """Generate all words up to a given length."""
    words = [[]]
    for length in range(1, max_len + 1):
        for w in cart_product(alphabet, repeat=length):
            words.append(list(w))
    return words


# ============================================================
# Demo 1: Basic Realization
# ============================================================
def demo_basic_realization():
    print("=" * 60)
    print("DEMO 1: Basic Realization from Hankel Presentation")
    print("=" * 60)
    print()

    # Define a presentation for a simple 2-state transducer
    # over input alphabet {a, b} and output alphabet {x, y}
    # The series counts weighted path combinations.

    P = HankelPresentation(
        n=2,
        act_a={
            'a': [[0.5, 0.3], [0.1, 0.6]],
            'b': [[0.4, 0.2], [0.3, 0.5]],
        },
        act_b={
            'x': [[0.6, 0.1], [0.2, 0.7]],
            'y': [[0.3, 0.4], [0.5, 0.2]],
        },
        init_vec=[1.0, 0.5],
        out_vec=[0.8, 0.3],
        input_alph=['a', 'b'],
        output_alph=['x', 'y'],
    )

    # Reconstruct the transducer
    T = reconstruct(P)
    print(f"Reconstructed transducer with {T.n} states")
    print(f"  init = {T.init}")
    print(f"  out  = {T.out}")
    print()

    # Verify behavior matches the presentation
    print("Behavior verification (P.evaluate vs T.behavior):")
    test_words_a = gen_words(['a', 'b'], 2)
    test_words_b = gen_words(['x', 'y'], 2)

    max_error = 0.0
    for u in test_words_a[:6]:
        for v in test_words_b[:6]:
            p_val = P.evaluate(u, v)
            t_val = T.behavior(u, v)
            error = abs(p_val - t_val)
            max_error = max(max_error, error)
            if len(u) + len(v) <= 2:
                print(f"  f({u}, {v}) = {p_val:.6f}  (T: {t_val:.6f}, err: {error:.2e})")

    print(f"\n  Maximum error across all tests: {max_error:.2e}")
    print(f"  Reconstruction correct: {max_error < 1e-12}")
    print()


# ============================================================
# Demo 2: Round-trip Stability
# ============================================================
def demo_roundtrip():
    print("=" * 60)
    print("DEMO 2: Round-trip Stability (T → P → T')")
    print("=" * 60)
    print()

    # Start with a transducer
    T = ClosureTransducer(
        n=3,
        init=[1.0, 0.0, 0.5],
        act_a={
            0: [[0.2, 0.5, 0.1], [0.3, 0.1, 0.4], [0.1, 0.3, 0.2]],
            1: [[0.4, 0.1, 0.3], [0.2, 0.5, 0.1], [0.3, 0.2, 0.4]],
        },
        act_b={
            0: [[0.3, 0.2, 0.3], [0.1, 0.6, 0.1], [0.4, 0.1, 0.3]],
            1: [[0.5, 0.1, 0.2], [0.2, 0.3, 0.4], [0.1, 0.4, 0.3]],
        },
        out=[0.7, 0.2, 0.5],
        input_alph=[0, 1],
        output_alph=[0, 1],
    )

    # Convert to presentation
    P = to_presentation(T)

    # Reconstruct
    T2 = reconstruct(P)

    print(f"Original: {T.n} states → Presentation: dim {P.n} → Reconstructed: {T2.n} states")
    print()

    # Verify round-trip
    test_words = gen_words([0, 1], 3)
    max_error = 0.0
    for u in test_words:
        for v in test_words:
            orig = T.behavior(u, v)
            recon = T2.behavior(u, v)
            max_error = max(max_error, abs(orig - recon))

    print(f"Maximum behavior difference: {max_error:.2e}")
    print(f"Round-trip stable: {max_error < 1e-12}")

    # Show some values
    print("\nSample behaviors:")
    for u in test_words[:5]:
        for v in test_words[:5]:
            if len(u) + len(v) <= 2:
                print(f"  T({u},{v}) = {T.behavior(u,v):.6f}  T'({u},{v}) = {T2.behavior(u,v):.6f}")
    print()


# ============================================================
# Demo 3: Minimality
# ============================================================
def demo_minimality():
    print("=" * 60)
    print("DEMO 3: Minimality — Redundant States Detected")
    print("=" * 60)
    print()

    # Create a minimal 2-state transducer
    T_min = ClosureTransducer(
        n=2,
        init=[1.0, 0.5],
        act_a={0: [[0.6, 0.2], [0.1, 0.8]], 1: [[0.3, 0.5], [0.4, 0.2]]},
        act_b={0: [[0.7, 0.1], [0.3, 0.5]], 1: [[0.2, 0.6], [0.5, 0.3]]},
        out=[0.9, 0.4],
        input_alph=[0, 1],
        output_alph=[0, 1],
    )

    # Create a bloated 4-state transducer with duplicate state space
    Z = np.zeros((2, 2))
    T_big = ClosureTransducer(
        n=4,
        init=[0.5, 0.25, 0.5, 0.25],
        act_a={
            0: np.block([[T_min.act_a[0], Z], [Z, T_min.act_a[0]]]),
            1: np.block([[T_min.act_a[1], Z], [Z, T_min.act_a[1]]]),
        },
        act_b={
            0: np.block([[T_min.act_b[0], Z], [Z, T_min.act_b[0]]]),
            1: np.block([[T_min.act_b[1], Z], [Z, T_min.act_b[1]]]),
        },
        out=[0.45, 0.2, 0.45, 0.2],
        input_alph=[0, 1],
        output_alph=[0, 1],
    )

    # The big transducer has 4 states but only needs 2
    print(f"Minimal transducer: {T_min.n} states")
    print(f"Bloated transducer: {T_big.n} states")
    print()

    # Verify they compute the same behavior
    test_words = gen_words([0, 1], 3)
    max_error = 0.0
    for u in test_words:
        for v in test_words:
            err = abs(T_min.behavior(u, v) - T_big.behavior(u, v))
            max_error = max(max_error, err)

    print(f"Same behavior: {max_error < 1e-10} (max error: {max_error:.2e})")

    # Detect redundancy via reachability analysis
    reach_vecs = []
    for u in test_words[:20]:
        for v in test_words[:20]:
            reach_vecs.append(T_big.state_vector(u, v))
    R = np.column_stack(reach_vecs)
    _, s, _ = np.linalg.svd(R, full_matrices=False)
    eff_rank = np.sum(s > 1e-10 * s[0])
    print(f"Effective rank of reachability matrix: {eff_rank}")
    print(f"Minimality theorem: need at least {eff_rank} states (have {T_big.n})")
    print(f"Optimal matches minimal transducer: {eff_rank == T_min.n}")
    print()


# ============================================================
# Demo 4: Hankel Matrix and Rank
# ============================================================
def demo_hankel_rank():
    print("=" * 60)
    print("DEMO 4: Hankel Matrix Structure and Rank")
    print("=" * 60)
    print()

    # Define a bi-series via a known 3-state transducer
    T = ClosureTransducer(
        n=3,
        init=[1.0, 0.0, 0.0],
        act_a={0: [[0, 1, 0], [0, 0, 1], [1, 0, 0]],  # cyclic permutation
               1: [[1, 0, 0], [0, 1, 0], [0, 0, 1]]},  # identity
        act_b={0: [[1, 0, 0], [0, 1, 0], [0, 0, 1]],  # identity
               1: [[0, 0, 1], [1, 0, 0], [0, 1, 0]]},  # another permutation
        out=[1.0, 0.0, 0.0],
        input_alph=[0, 1],
        output_alph=[0, 1],
    )

    f = lambda u, v: T.behavior(u, v)

    # Build the Hankel matrix
    words = gen_words([0, 1], 2)
    n_words = len(words)

    # Only use input prefixes with empty output, and vice versa for simplicity
    prefixes_a = words[:7]
    prefixes_b = words[:7]
    suffixes_a = words[:7]
    suffixes_b = words[:7]

    prefix_pairs = [(u, v) for u in prefixes_a for v in prefixes_b]
    suffix_pairs = [(u, v) for u in suffixes_a for v in suffixes_b]

    m = len(prefix_pairs)
    k = len(suffix_pairs)
    H = np.zeros((m, k))
    for i, (u, v) in enumerate(prefix_pairs):
        for j, (up, vp) in enumerate(suffix_pairs):
            H[i, j] = f(u + up, v + vp)

    _, s, _ = np.linalg.svd(H, full_matrices=False)
    print(f"Hankel matrix size: {H.shape}")
    print(f"Singular values: {s[:8]}")
    rank = np.sum(s > 1e-10 * s[0])
    print(f"Numerical rank: {rank}")
    print(f"Matches transducer states: {rank == T.n}")
    print()

    # Show the Hankel matrix structure (small submatrix)
    print("Hankel matrix (first 8×8 block):")
    np.set_printoptions(precision=2, linewidth=100)
    print(H[:8, :8])
    np.set_printoptions(precision=4, suppress=True)
    print()


# ============================================================
# Demo 5: Duality — Existence Equivalence
# ============================================================
def demo_duality():
    print("=" * 60)
    print("DEMO 5: Duality — Machine ↔ Algebra Equivalence")
    print("=" * 60)
    print()

    # Start with algebraic data (a presentation)
    P = HankelPresentation(
        n=2,
        act_a={0: [[0.8, 0.1], [0.2, 0.7]], 1: [[0.5, 0.3], [0.4, 0.6]]},
        act_b={0: [[0.9, 0.05], [0.1, 0.85]], 1: [[0.6, 0.2], [0.3, 0.7]]},
        init_vec=[1.0, 0.0],
        out_vec=[1.0, 1.0],
        input_alph=[0, 1],
        output_alph=[0, 1],
    )

    # Direction 1: Algebra → Machine
    T = reconstruct(P)
    print(f"[Algebra → Machine] Presentation (dim {P.n}) → Transducer ({T.n} states)")

    # Direction 2: Machine → Algebra
    P2 = to_presentation(T)
    print(f"[Machine → Algebra] Transducer ({T.n} states) → Presentation (dim {P2.n})")

    # Verify full round-trip
    T3 = reconstruct(P2)
    test_words = gen_words([0, 1], 3)
    max_err = max(abs(P.evaluate(u, v) - T3.behavior(u, v))
                  for u in test_words for v in test_words)
    print(f"\nFull round-trip error: {max_err:.2e}")
    print(f"Duality holds: {max_err < 1e-12}")
    print()

    # Show the series values
    print("Sample series values through the duality:")
    for u in [[], [0], [1], [0, 1]]:
        for v in [[], [0], [1]]:
            val = P.evaluate(u, v)
            print(f"  f({u}, {v}) = {val:.6f}")
    print()


# ============================================================
# Main
# ============================================================
if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  Closure-Kolmogorov Realization Duality — Demonstrations ║")
    print("╚══════════════════════════════════════════════════════════╝")
    print()

    demo_basic_realization()
    demo_roundtrip()
    demo_minimality()
    demo_hankel_rank()
    demo_duality()

    print("All demonstrations completed successfully.")


#!/usr/bin/env python3
"""
Closure-Kolmogorov Realization: Visualizations

Generates publication-quality figures illustrating:
1. Hankel matrix structure and rank
2. Singular value decay (determines state complexity)
3. Realization duality diagram
4. Behavior surface
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.colors import LinearSegmentedColormap
from itertools import product as cart_product
import os

OUTPUT_DIR = os.path.dirname(os.path.abspath(__file__))


def gen_words(alphabet, max_len):
    words = [[]]
    for length in range(1, max_len + 1):
        for w in cart_product(alphabet, repeat=length):
            words.append(list(w))
    return words


class ClosureTransducer:
    def __init__(self, n, init, act_a, act_b, out):
        self.n = n
        self.init = np.array(init, dtype=float)
        self.act_a = {k: np.array(v, dtype=float) for k, v in act_a.items()}
        self.act_b = {k: np.array(v, dtype=float) for k, v in act_b.items()}
        self.out = np.array(out, dtype=float)

    def behavior(self, u, v):
        w = self.init.copy()
        for b in reversed(v):
            w = self.act_b[b] @ w
        for a in reversed(u):
            w = self.act_a[a] @ w
        return float(w @ self.out)


def fig_hankel_matrix():
    """Visualize the Hankel matrix structure."""
    T = ClosureTransducer(
        n=3,
        init=[1.0, 0.5, 0.2],
        act_a={0: [[0.6, 0.3, 0.1], [0.2, 0.5, 0.3], [0.1, 0.2, 0.7]],
               1: [[0.4, 0.4, 0.2], [0.3, 0.3, 0.4], [0.2, 0.5, 0.3]]},
        act_b={0: [[0.7, 0.2, 0.1], [0.1, 0.6, 0.3], [0.2, 0.3, 0.5]],
               1: [[0.5, 0.3, 0.2], [0.2, 0.4, 0.4], [0.3, 0.2, 0.5]]},
        out=[0.8, 0.5, 0.3],
    )

    words = gen_words([0, 1], 2)
    prefix_pairs = [(u, v) for u in words[:5] for v in words[:5]]
    suffix_pairs = prefix_pairs

    m = len(prefix_pairs)
    H = np.zeros((m, m))
    for i, (u, v) in enumerate(prefix_pairs):
        for j, (up, vp) in enumerate(suffix_pairs):
            H[i, j] = T.behavior(u + up, v + vp)

    fig, axes = plt.subplots(1, 2, figsize=(14, 5.5))

    # Hankel matrix heatmap
    im = axes[0].imshow(H, cmap='RdYlBu_r', aspect='auto')
    axes[0].set_title('Bi-Hankel Matrix H(f)', fontsize=14, fontweight='bold')
    axes[0].set_xlabel('Suffix pair index (u\', v\')', fontsize=11)
    axes[0].set_ylabel('Prefix pair index (u, v)', fontsize=11)
    plt.colorbar(im, ax=axes[0], shrink=0.8)

    # Singular values
    _, s, _ = np.linalg.svd(H)
    axes[1].semilogy(range(1, len(s) + 1), s, 'o-', color='#2196F3', markersize=6,
                     linewidth=2)
    rank = np.sum(s > 1e-10 * s[0])
    axes[1].axvline(x=rank, color='#F44336', linestyle='--', linewidth=2,
                    label=f'Hankel rank = {rank}')
    axes[1].set_title('Singular Value Decay', fontsize=14, fontweight='bold')
    axes[1].set_xlabel('Index', fontsize=11)
    axes[1].set_ylabel('Singular value (log scale)', fontsize=11)
    axes[1].legend(fontsize=11)
    axes[1].grid(True, alpha=0.3)

    plt.tight_layout()
    path = os.path.join(OUTPUT_DIR, 'hankel_structure.png')
    plt.savefig(path, dpi=150, bbox_inches='tight')
    plt.close()
    print(f"Saved: {path}")
    return path


def fig_behavior_surface():
    """Visualize the behavior surface as a function of word lengths."""
    T = ClosureTransducer(
        n=3,
        init=[1.0, 0.5, 0.2],
        act_a={0: [[0.6, 0.3, 0.1], [0.2, 0.5, 0.3], [0.1, 0.2, 0.7]],
               1: [[0.4, 0.4, 0.2], [0.3, 0.3, 0.4], [0.2, 0.5, 0.3]]},
        act_b={0: [[0.7, 0.2, 0.1], [0.1, 0.6, 0.3], [0.2, 0.3, 0.5]],
               1: [[0.5, 0.3, 0.2], [0.2, 0.4, 0.4], [0.3, 0.2, 0.5]]},
        out=[0.8, 0.5, 0.3],
    )

    max_len = 8
    # For each (input_length, output_length), compute average behavior over all words
    avg_behavior = np.zeros((max_len + 1, max_len + 1))
    for il in range(max_len + 1):
        for ol in range(max_len + 1):
            in_words = list(cart_product([0, 1], repeat=il)) if il > 0 else [()]
            out_words = list(cart_product([0, 1], repeat=ol)) if ol > 0 else [()]
            total = 0
            count = 0
            for u in in_words:
                for v in out_words:
                    total += T.behavior(list(u), list(v))
                    count += 1
            avg_behavior[il, ol] = total / count

    fig, ax = plt.subplots(figsize=(8, 6))
    im = ax.imshow(avg_behavior, cmap='viridis', origin='lower', aspect='auto',
                   interpolation='bilinear')
    ax.set_xlabel('Output word length |v|', fontsize=12)
    ax.set_ylabel('Input word length |u|', fontsize=12)
    ax.set_title('Average Transducer Behavior by Word Length', fontsize=14,
                 fontweight='bold')
    plt.colorbar(im, ax=ax, label='Average behavior value')

    # Add contour lines
    ax.contour(avg_behavior, levels=8, colors='white', alpha=0.4, linewidths=0.8,
               origin='lower')

    plt.tight_layout()
    path = os.path.join(OUTPUT_DIR, 'behavior_surface.png')
    plt.savefig(path, dpi=150, bbox_inches='tight')
    plt.close()
    print(f"Saved: {path}")
    return path


def fig_compression_spectrum():
    """Visualize model compression via singular value thresholding."""
    np.random.seed(42)
    true_rank = 3
    n_big = 10

    A = np.random.randn(n_big, true_rank) * 0.3
    init = A @ np.random.randn(true_rank)
    out = A @ np.random.randn(true_rank)

    def make_mat():
        core = np.random.randn(true_rank, true_rank) * 0.3
        return A @ core @ np.linalg.pinv(A)

    T = ClosureTransducer(n_big, init,
                          {0: make_mat(), 1: make_mat()},
                          {0: make_mat(), 1: make_mat()},
                          out)

    # Collect reachable state vectors
    test_words = gen_words([0, 1], 4)
    vecs = []
    for u in test_words[:50]:
        for v in test_words[:50]:
            w = T.init.copy()
            for b in reversed(v):
                w = T.act_b[b] @ w
            for a in reversed(u):
                w = T.act_a[a] @ w
            vecs.append(w)

    R = np.column_stack(vecs)
    _, s, _ = np.linalg.svd(R, full_matrices=False)

    fig, axes = plt.subplots(1, 2, figsize=(13, 5))

    # Singular value spectrum
    axes[0].bar(range(1, len(s) + 1), s, color='#42A5F5', alpha=0.8, edgecolor='#1565C0')
    axes[0].axhline(y=1e-10 * s[0], color='#F44336', linestyle='--', linewidth=2,
                    label='Threshold')
    axes[0].set_xlabel('Component index', fontsize=12)
    axes[0].set_ylabel('Singular value', fontsize=12)
    axes[0].set_title('Reachability Spectrum', fontsize=14, fontweight='bold')
    axes[0].legend(fontsize=11)
    axes[0].set_yscale('log')
    axes[0].grid(True, alpha=0.3, axis='y')

    # Compression error vs rank
    errors = []
    ranks = list(range(1, min(n_big + 1, len(s) + 1)))
    for r in ranks:
        U_proj = np.linalg.svd(R, full_matrices=False)[0][:, :r]
        P_inv = np.linalg.pinv(U_proj)
        T_small = ClosureTransducer(
            r, P_inv @ T.init,
            {k: P_inv @ M @ U_proj for k, M in T.act_a.items()},
            {k: P_inv @ M @ U_proj for k, M in T.act_b.items()},
            U_proj.T @ T.out)
        max_err = max(abs(T.behavior(u, v) - T_small.behavior(u, v))
                      for u in test_words[:10] for v in test_words[:10])
        errors.append(max_err)

    axes[1].semilogy(ranks, errors, 'o-', color='#4CAF50', markersize=7, linewidth=2)
    axes[1].axvline(x=true_rank, color='#FF9800', linestyle='--', linewidth=2,
                    label=f'True rank = {true_rank}')
    axes[1].set_xlabel('Number of states (compressed)', fontsize=12)
    axes[1].set_ylabel('Max behavior error', fontsize=12)
    axes[1].set_title('Compression Error vs. State Count', fontsize=14,
                      fontweight='bold')
    axes[1].legend(fontsize=11)
    axes[1].grid(True, alpha=0.3)

    plt.tight_layout()
    path = os.path.join(OUTPUT_DIR, 'compression_spectrum.png')
    plt.savefig(path, dpi=150, bbox_inches='tight')
    plt.close()
    print(f"Saved: {path}")
    return path


def fig_duality_diagram():
    """Create a conceptual diagram of the realization duality."""
    fig, ax = plt.subplots(figsize=(10, 6))
    ax.set_xlim(0, 10)
    ax.set_ylim(0, 6)
    ax.axis('off')

    # Boxes
    box_props = dict(boxstyle='round,pad=0.5', facecolor='#E3F2FD', edgecolor='#1565C0',
                     linewidth=2)
    box_props2 = dict(boxstyle='round,pad=0.5', facecolor='#E8F5E9', edgecolor='#2E7D32',
                      linewidth=2)

    # Left: Algebraic side
    ax.text(2.5, 4.5, 'Hankel\nPresentation\n(P, coeff, act)', fontsize=13,
            ha='center', va='center', bbox=box_props, fontweight='bold')
    ax.text(2.5, 1.5, 'Row Semimodule\n(finite generators\n+ residual actions)', fontsize=11,
            ha='center', va='center', bbox=box_props)

    # Right: Computational side
    ax.text(7.5, 4.5, 'Closure\nTransducer\n(n states)', fontsize=13,
            ha='center', va='center', bbox=box_props2, fontweight='bold')
    ax.text(7.5, 1.5, 'Behavior\nf : A* × B* → S', fontsize=11,
            ha='center', va='center', bbox=box_props2)

    # Arrows
    arrow_props = dict(arrowstyle='->', color='#1565C0', lw=2.5)
    arrow_props2 = dict(arrowstyle='->', color='#2E7D32', lw=2.5)

    # Top arrows (duality)
    ax.annotate('', xy=(5.8, 4.8), xytext=(4.2, 4.8), arrowprops=arrow_props)
    ax.text(5.0, 5.2, 'reconstruct', fontsize=10, ha='center', color='#1565C0',
            fontstyle='italic')

    ax.annotate('', xy=(4.2, 4.2), xytext=(5.8, 4.2), arrowprops=arrow_props2)
    ax.text(5.0, 3.8, 'observe', fontsize=10, ha='center', color='#2E7D32',
            fontstyle='italic')

    # Vertical arrows
    ax.annotate('', xy=(2.5, 2.3), xytext=(2.5, 3.7), arrowprops=dict(
        arrowstyle='->', color='#666', lw=1.5))
    ax.text(1.5, 3.0, 'generates', fontsize=9, ha='center', color='#666',
            fontstyle='italic')

    ax.annotate('', xy=(7.5, 2.3), xytext=(7.5, 3.7), arrowprops=dict(
        arrowstyle='->', color='#666', lw=1.5))
    ax.text(8.5, 3.0, 'computes', fontsize=9, ha='center', color='#666',
            fontstyle='italic')

    # Bottom connection
    ax.annotate('', xy=(5.5, 1.5), xytext=(4.5, 1.5), arrowprops=dict(
        arrowstyle='<->', color='#F44336', lw=2))
    ax.text(5.0, 1.0, 'equals', fontsize=10, ha='center', color='#F44336',
            fontweight='bold')

    # Title
    ax.text(5.0, 5.8, 'Closure-Kolmogorov Realization Duality',
            fontsize=16, ha='center', fontweight='bold', color='#333')

    plt.tight_layout()
    path = os.path.join(OUTPUT_DIR, 'duality_diagram.png')
    plt.savefig(path, dpi=150, bbox_inches='tight')
    plt.close()
    print(f"Saved: {path}")
    return path


if __name__ == "__main__":
    print("Generating visualizations...\n")
    fig_hankel_matrix()
    fig_behavior_surface()
    fig_compression_spectrum()
    fig_duality_diagram()
    print("\nAll visualizations generated.")
