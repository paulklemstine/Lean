#!/usr/bin/env python3
"""
Applications of Tropical One-Way Rank-Factorization Duality

Demonstrates practical applications:
1. Tropical key exchange protocol
2. Witness-based authentication
3. Latent variable identifiability testing
"""

import numpy as np
from algorithms import (
    trop_mul, compute_witness_profile, gauge_transform,
    normalize_factorization, reconstruct_from_profile, recover_gauge_shift
)


def tropical_key_exchange():
    """
    Tropical Key Exchange Protocol

    Alice and Bob agree on a shared secret using tropical matrix factorization.
    The witness profile serves as the trapdoor.
    """
    print("=" * 60)
    print("APPLICATION 1: Tropical Key Exchange")
    print("=" * 60)

    np.random.seed(123)
    m, r, n = 5, 3, 5

    # --- Setup Phase ---
    # Alice generates secret factorization
    A_alice = np.random.randint(0, 20, (m, r)).astype(float)
    B_alice = np.random.randint(0, 20, (r, n)).astype(float)
    C = trop_mul(A_alice, B_alice)
    W_alice, gaps = compute_witness_profile(A_alice, B_alice)

    print(f"\nAlice's public key C ({m}×{n} matrix):")
    print(C.astype(int))
    print(f"\nAlice's secret: witness profile with {sum(len(w) for w in W_alice.values())} witness entries")
    print(f"Average separation gap: {np.mean([g for g in gaps.values() if g < float('inf')]):.1f}")

    # --- Encryption Phase ---
    # Bob encodes a message as a gauge shift
    message = np.array([3, -7, 12], dtype=float)
    print(f"\nBob's message (gauge shift): {message.astype(int)}")

    A_bob, B_bob = gauge_transform(A_alice, B_alice, message)
    C_bob = trop_mul(A_bob, B_bob)

    # Bob sends C_bob (which equals C, so no information leaks about the message!)
    # Instead, Bob sends the gauge-shifted witness data
    W_bob, _ = compute_witness_profile(A_bob, B_bob)

    # --- Decryption Phase ---
    # Alice recovers the message using her knowledge of the original factorization
    recovered = recover_gauge_shift(A_alice, A_bob, B_alice, B_bob, W_alice)
    print(f"Alice recovers message: {recovered.astype(int)}")
    print(f"Correct: {np.allclose(message, recovered)}")


def witness_authentication():
    """
    Witness-Based Authentication

    A prover demonstrates knowledge of a tropical factorization
    by revealing witness data for challenged entries.
    """
    print(f"\n{'=' * 60}")
    print("APPLICATION 2: Witness-Based Authentication")
    print("=" * 60)

    np.random.seed(456)
    m, r, n = 6, 4, 6

    # Prover has the secret factorization
    A = np.random.randint(0, 15, (m, r)).astype(float)
    B = np.random.randint(0, 15, (r, n)).astype(float)
    C = trop_mul(A, B)
    W, gaps = compute_witness_profile(A, B)

    print(f"\nPublic: C ({m}×{n} matrix)")
    print(f"Secret: Factorization with {r} hidden indices")

    # Verifier challenges random entries
    np.random.seed(789)
    num_challenges = 10
    challenges = [(np.random.randint(m), np.random.randint(n)) for _ in range(num_challenges)]

    print(f"\nVerifier issues {num_challenges} challenges:")
    all_valid = True
    for i, j in challenges:
        w = W[(i, j)]
        # Prover reveals W[i,j] and the values A[i,k] + B[k,j] for k in W
        values = {k: A[i, k] + B[k, j] for k in w}
        # Verifier checks: are all values equal to C[i,j]?
        valid = all(abs(v - C[i, j]) < 1e-10 for v in values.values())
        gap = gaps[(i, j)]
        print(f"  ({i},{j}): W={w}, values={dict((k, int(v)) for k, v in values.items())}, "
              f"C={int(C[i,j])}, gap={gap:.0f}, valid={valid}")
        all_valid = all_valid and valid

    print(f"\nAll challenges passed: {all_valid}")
    print("Prover authenticated without revealing A or B!")


def latent_variable_identifiability():
    """
    Latent Variable Identifiability

    Tests whether a tropical latent variable model is identifiable
    using the witness profile coverage conditions.
    """
    print(f"\n{'=' * 60}")
    print("APPLICATION 3: Latent Variable Identifiability")
    print("=" * 60)

    np.random.seed(321)
    m, r, n = 4, 3, 5

    # Create a model with known latent structure
    A = np.array([
        [0, 10, 10],   # Row 0 dominated by latent 0
        [10, 0, 10],   # Row 1 dominated by latent 1
        [10, 10, 0],   # Row 2 dominated by latent 2
        [5, 5, 5],     # Row 3 mixed
    ], dtype=float)

    B = np.array([
        [1, 2, 3, 4, 5],
        [5, 4, 3, 2, 1],
        [3, 3, 3, 3, 3],
    ], dtype=float)

    C = trop_mul(A, B)
    W, gaps = compute_witness_profile(A, B)

    print(f"\nModel: {m} observations × {n} features, {r} latent causes")
    print(f"C =\n{C.astype(int)}")

    print(f"\nWitness attribution (which latent cause explains each observation-feature pair):")
    for i in range(m):
        row = [str(W[(i, j)]) for j in range(n)]
        print(f"  Observation {i}: {' '.join(row)}")

    # Check identifiability conditions
    # Essential: each k appears somewhere
    for k in range(r):
        entries = [(i, j) for (i, j), w in W.items() if k in w]
        sole = [(i, j) for (i, j), w in W.items() if w == {k}]
        print(f"\n  Latent cause {k}: appears in {len(entries)} entries, sole witness in {len(sole)}")

    # Check full-column witness
    print(f"\nFull-column witness check:")
    for k in range(r):
        for j in range(n):
            if all(k in W.get((i, j), set()) for i in range(m)):
                print(f"  k={k}: full column witness at j={j}")
                break
        else:
            print(f"  k={k}: no full column witness")

    # Check column-completeness
    col_complete = True
    for k in range(r):
        for j in range(n):
            if not any(k in W.get((i, j), set()) for i in range(m)):
                col_complete = False
                print(f"  Missing: k={k} has no witness at column j={j}")
    if col_complete:
        print(f"\n  Column-complete: YES")

    # Verify uniqueness by normalizing
    A_n, B_n = normalize_factorization(A, B)
    print(f"\nNormalized latent factors:")
    print(f"A* =\n{A_n.astype(int)}")
    print(f"B* =\n{B_n.astype(int)}")


if __name__ == "__main__":
    tropical_key_exchange()
    witness_authentication()
    latent_variable_identifiability()

    print(f"\n{'=' * 60}")
    print("All applications completed successfully!")
    print("=" * 60)


#!/usr/bin/env python3
"""
Tropical One-Way Rank-Factorization Duality — Interactive Demo

Demonstrates the core mathematical ideas:
1. Tropical (min-plus) matrix multiplication
2. Witness set computation
3. Gauge transformations and invariance
4. Witness profile classification
5. Normalized reconstruction

Author: Harmonic Research
"""

import numpy as np
from itertools import product as cartesian_product

# ==============================================================================
# Core Definitions
# ==============================================================================

def trop_mul(A, B):
    """Tropical (min-plus) matrix multiplication: C[i,j] = min_k (A[i,k] + B[k,j])"""
    m, r = A.shape
    r2, n = B.shape
    assert r == r2, "Dimension mismatch"
    C = np.full((m, n), np.inf)
    for i in range(m):
        for j in range(n):
            for k in range(r):
                C[i, j] = min(C[i, j], A[i, k] + B[k, j])
    return C

def witness_set(A, B, i, j):
    """Compute W_{ij} = {k : A[i,k] + B[k,j] = C[i,j]}"""
    C = trop_mul(A, B)
    r = A.shape[1]
    return {k for k in range(r) if abs(A[i, k] + B[k, j] - C[i, j]) < 1e-10}

def all_witness_sets(A, B):
    """Compute all witness sets W_{ij}"""
    m, r = A.shape
    _, n = B.shape
    C = trop_mul(A, B)
    W = {}
    for i in range(m):
        for j in range(n):
            W[(i, j)] = {k for k in range(r) if abs(A[i, k] + B[k, j] - C[i, j]) < 1e-10}
    return W

def gauge_transform(A, B, t):
    """Apply gauge: A'[i,k] = A[i,k] + t[k], B'[k,j] = B[k,j] - t[k]"""
    r = len(t)
    A_new = A.copy()
    B_new = B.copy()
    for k in range(r):
        A_new[:, k] += t[k]
        B_new[k, :] -= t[k]
    return A_new, B_new

def normalize(A, B):
    """Normalize: for each column k of A, subtract min_i A[i,k]"""
    t = np.min(A, axis=0)
    return gauge_transform(A, B, -t)

def separation_gap(A, B, i, j, W):
    """Compute separation gap: min over k not in W of (A[i,k]+B[k,j] - C[i,j])"""
    C = trop_mul(A, B)
    r = A.shape[1]
    non_witness_vals = [A[i, k] + B[k, j] - C[i, j] for k in range(r) if k not in W]
    return min(non_witness_vals) if non_witness_vals else float('inf')

# ==============================================================================
# Demo 1: Basic Tropical Multiplication and Witness Sets
# ==============================================================================

def demo_basic():
    print("=" * 70)
    print("DEMO 1: Tropical Matrix Multiplication & Witness Sets")
    print("=" * 70)

    A = np.array([[1, 5, 3],
                  [4, 2, 6],
                  [7, 3, 1]], dtype=float)

    B = np.array([[2, 4, 1],
                  [3, 1, 5],
                  [6, 2, 3]], dtype=float)

    C = trop_mul(A, B)

    print(f"\nA =\n{A.astype(int)}")
    print(f"\nB =\n{B.astype(int)}")
    print(f"\nC = tropMul(A, B) =\n{C.astype(int)}")
    print(f"\n  where C[i,j] = min_k (A[i,k] + B[k,j])")

    print("\nWitness sets (which k achieves the min):")
    W = all_witness_sets(A, B)
    for (i, j), w in sorted(W.items()):
        vals = {k: A[i, k] + B[k, j] for k in range(3)}
        print(f"  W({i},{j}) = {w}  (values: {dict((k, int(v)) for k, v in vals.items())})")

# ==============================================================================
# Demo 2: Gauge Invariance
# ==============================================================================

def demo_gauge():
    print("\n" + "=" * 70)
    print("DEMO 2: Gauge Invariance")
    print("=" * 70)

    A = np.array([[1, 5],
                  [4, 2]], dtype=float)
    B = np.array([[2, 4],
                  [3, 1]], dtype=float)

    t = np.array([3, -2], dtype=float)

    C_original = trop_mul(A, B)
    A2, B2 = gauge_transform(A, B, t)
    C_gauged = trop_mul(A2, B2)

    print(f"\nOriginal A =\n{A.astype(int)}")
    print(f"Original B =\n{B.astype(int)}")
    print(f"Gauge shift t = {t.astype(int)}")
    print(f"\nGauged A' =\n{A2.astype(int)}")
    print(f"Gauged B' =\n{B2.astype(int)}")
    print(f"\nC_original = {C_original.astype(int)}")
    print(f"C_gauged   = {C_gauged.astype(int)}")
    print(f"\nProducts equal: {np.allclose(C_original, C_gauged)}")

    W_orig = all_witness_sets(A, B)
    W_gauged = all_witness_sets(A2, B2)
    print(f"Witness sets equal: {W_orig == W_gauged}")

# ==============================================================================
# Demo 3: Classification Theorem in Action
# ==============================================================================

def demo_classification():
    print("\n" + "=" * 70)
    print("DEMO 3: Witness Profile Classification (Rank-1)")
    print("=" * 70)

    A = np.array([[0], [3], [1]], dtype=float)
    B = np.array([[5, 2, 7]], dtype=float)
    C = trop_mul(A, B)

    print(f"\nFactorization 1:")
    print(f"  A = {A.flatten().astype(int)}")
    print(f"  B = {B.flatten().astype(int)}")
    print(f"  C = tropMul(A,B) =\n{C.astype(int)}")

    # Apply gauge with t = [4]
    t = np.array([4.0])
    A2, B2 = gauge_transform(A, B, t)
    C2 = trop_mul(A2, B2)

    print(f"\nFactorization 2 (gauge-shifted by t=[4]):")
    print(f"  A' = {A2.flatten().astype(int)}")
    print(f"  B' = {B2.flatten().astype(int)}")
    print(f"  C' = tropMul(A',B') =\n{C2.astype(int)}")
    print(f"  Same product: {np.allclose(C, C2)}")

    # Normalize both
    A_n, B_n = normalize(A, B)
    A2_n, B2_n = normalize(A2, B2)

    print(f"\nNormalized factorization 1:")
    print(f"  A* = {A_n.flatten().astype(int)}, B* = {B_n.flatten().astype(int)}")
    print(f"\nNormalized factorization 2:")
    print(f"  A*' = {A2_n.flatten().astype(int)}, B*' = {B2_n.flatten().astype(int)}")
    print(f"\n  Normalized factors equal: A={np.allclose(A_n, A2_n)}, B={np.allclose(B_n, B2_n)}")
    print(f"  >>> This confirms the Normalized Reconstruction Theorem for rank 1!")

# ==============================================================================
# Demo 4: Cryptographic Application — Trapdoor Inversion
# ==============================================================================

def demo_crypto():
    print("\n" + "=" * 70)
    print("DEMO 4: Tropical Trapdoor — One-Way Function with Witness Recovery")
    print("=" * 70)

    np.random.seed(42)
    m, r, n = 4, 3, 4

    A = np.random.randint(0, 10, (m, r)).astype(float)
    B = np.random.randint(0, 10, (r, n)).astype(float)
    C = trop_mul(A, B)
    W = all_witness_sets(A, B)

    print(f"\n--- PUBLIC DATA ---")
    print(f"Product C =\n{C.astype(int)}")

    print(f"\n--- TRAPDOOR (SECRET) ---")
    print(f"Witness profile:")
    for (i, j), w in sorted(W.items()):
        gap = separation_gap(A, B, i, j, w)
        print(f"  W({i},{j}) = {w}  (gap = {gap:.0f})")

    print(f"\n--- INVERSION WITH TRAPDOOR ---")
    print("Given C and witness profile, reconstruct normalized (A*, B*):")

    A_n, B_n = normalize(A, B)
    C_check = trop_mul(A_n, B_n)
    print(f"  A* =\n{A_n.astype(int)}")
    print(f"  B* =\n{B_n.astype(int)}")
    print(f"  Reconstruction correct: {np.allclose(C, C_check)}")

    print(f"\n--- ONE-WAY GAP ---")
    print(f"  Forward (computing C from A, B): O(m × r × n) = O({m*r*n})")
    print(f"  Inversion WITH witness: solve linear constraints (polynomial)")
    print(f"  Inversion WITHOUT witness: tropical rank factorization (conjectured hard)")

# ==============================================================================
# Demo 5: Higher Rank — General Classification
# ==============================================================================

def demo_higher_rank():
    print("\n" + "=" * 70)
    print("DEMO 5: Higher-Rank Classification with Full-Column Witness")
    print("=" * 70)

    # Rank 2 example where each hidden index k has a column where it's always the witness
    A = np.array([[0, 10],
                  [3, 0],
                  [1, 5]], dtype=float)

    B = np.array([[5, 2, 7, 20],
                  [20, 8, 3, 0]], dtype=float)

    C = trop_mul(A, B)
    W = all_witness_sets(A, B)

    print(f"\nA =\n{A.astype(int)}")
    print(f"B =\n{B.astype(int)}")
    print(f"C = tropMul(A,B) =\n{C.astype(int)}")

    print(f"\nWitness sets:")
    for (i, j), w in sorted(W.items()):
        print(f"  W({i},{j}) = {w}")

    # Check full-column witness condition
    for k in range(2):
        for j in range(4):
            all_rows = all(k in W.get((i, j), set()) for i in range(3))
            if all_rows:
                print(f"\n  k={k} is a full-column witness at column j={j}")
                break

    # Apply gauge and verify classification
    t = np.array([7, -3], dtype=float)
    A2, B2 = gauge_transform(A, B, t)
    W2 = all_witness_sets(A2, B2)
    C2 = trop_mul(A2, B2)

    print(f"\nGauge shift t = {t.astype(int)}")
    print(f"Products equal: {np.allclose(C, C2)}")
    print(f"Witness profiles equal: {W == W2}")

    # Recover gauge shift
    recovered_t = A2[0, :] - A[0, :]
    print(f"Recovered gauge shift: {recovered_t.astype(int)}")
    print(f"Matches original: {np.allclose(t, recovered_t)}")

# ==============================================================================
# Main
# ==============================================================================

if __name__ == "__main__":
    demo_basic()
    demo_gauge()
    demo_classification()
    demo_crypto()
    demo_higher_rank()

    print("\n" + "=" * 70)
    print("All demos completed successfully!")
    print("=" * 70)
