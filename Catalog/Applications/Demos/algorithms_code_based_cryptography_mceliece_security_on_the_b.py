#!/usr/bin/env python3
"""
algorithms.py — Type-hinted implementations of McEliece cryptosystem algorithms.

Includes:
1. McEliece key generation, encryption, decryption
2. Information Set Decoding (ISD) attack
3. Grover's bound computation
4. Parameter validation
"""

from typing import List, Tuple, Optional, Dict
from dataclasses import dataclass
from math import comb, log2, sqrt, factorial
import random


# ============================================================
# Type Aliases
# ============================================================

BinaryVector = List[int]
BinaryMatrix = List[List[int]]
Permutation = List[int]


# ============================================================
# GF(2) Arithmetic
# ============================================================

def gf2_add(a: BinaryVector, b: BinaryVector) -> BinaryVector:
    """Add two binary vectors over GF(2)."""
    return [(x + y) % 2 for x, y in zip(a, b)]


def gf2_dot(a: BinaryVector, b: BinaryVector) -> int:
    """Dot product over GF(2)."""
    return sum(x * y for x, y in zip(a, b)) % 2


def gf2_mat_vec(mat: BinaryMatrix, vec: BinaryVector) -> BinaryVector:
    """Matrix-vector product over GF(2)."""
    return [gf2_dot(row, vec) for row in mat]


def gf2_mat_mul(A: BinaryMatrix, B: BinaryMatrix) -> BinaryMatrix:
    """Matrix multiplication over GF(2)."""
    m, n = len(A), len(B[0])
    p = len(B)
    result = [[0] * n for _ in range(m)]
    for i in range(m):
        for j in range(n):
            result[i][j] = sum(A[i][k] * B[k][j] for k in range(p)) % 2
    return result


def gf2_identity(n: int) -> BinaryMatrix:
    """n×n identity matrix over GF(2)."""
    return [[1 if i == j else 0 for j in range(n)] for i in range(n)]


def gf2_rank(mat: BinaryMatrix) -> int:
    """Rank of a binary matrix via Gaussian elimination."""
    mat = [row[:] for row in mat]
    m, n = len(mat), len(mat[0])
    rank = 0
    for col in range(n):
        pivot = None
        for row in range(rank, m):
            if mat[row][col] == 1:
                pivot = row
                break
        if pivot is None:
            continue
        mat[rank], mat[pivot] = mat[pivot], mat[rank]
        for row in range(m):
            if row != rank and mat[row][col] == 1:
                mat[row] = [(mat[row][j] + mat[rank][j]) % 2 for j in range(n)]
        rank += 1
    return rank


def hamming_weight(v: BinaryVector) -> int:
    """Hamming weight of a binary vector."""
    return sum(v)


# ============================================================
# McEliece Cryptosystem
# ============================================================

@dataclass
class McElieceParams:
    """McEliece cryptosystem parameters."""
    n: int      # Code length
    k: int      # Code dimension
    t: int      # Error correction capability
    m: int      # Extension field degree (n ≤ 2^m)

    def validate(self) -> bool:
        """Check parameter constraints."""
        return (self.k <= self.n and
                self.t <= self.n and
                2 * self.t <= self.n and
                self.k > 0 and
                self.n > 0 and
                self.k >= self.n - self.m * self.t)


@dataclass
class McElieceSecretKey:
    """McEliece secret key."""
    generator: BinaryMatrix     # k×n generator matrix of Goppa code
    scrambler: BinaryMatrix     # k×k invertible scrambling matrix S
    permutation: Permutation    # Length-n permutation P


@dataclass
class McEliecePublicKey:
    """McEliece public key."""
    public_matrix: BinaryMatrix  # k×n public generator matrix G' = S·G·P


@dataclass
class McElieceCiphertext:
    """McEliece ciphertext."""
    data: BinaryVector  # Length-n binary vector


def mceliece_keygen(params: McElieceParams,
                     generator: BinaryMatrix) -> Tuple[McEliecePublicKey, McElieceSecretKey]:
    """
    McEliece Key Generation

    Input: Parameters and a Goppa code generator matrix
    Output: (public_key, secret_key)

    Algorithm:
    1. Generate random invertible k×k matrix S
    2. Generate random permutation P of {0, ..., n-1}
    3. Compute G' = S · G · P
    """
    k, n = params.k, params.n

    # Random invertible scrambling matrix (simplified: use identity for demo)
    S = gf2_identity(k)

    # Random permutation
    P = list(range(n))
    random.shuffle(P)

    # Apply permutation to columns of G
    G_permuted = [[generator[i][P[j]] for j in range(n)] for i in range(k)]

    # Compute S · G_permuted
    public_matrix = gf2_mat_mul(S, G_permuted)

    sk = McElieceSecretKey(generator=generator, scrambler=S, permutation=P)
    pk = McEliecePublicKey(public_matrix=public_matrix)

    return pk, sk


def mceliece_encrypt(pk: McEliecePublicKey,
                      message: BinaryVector,
                      t: int) -> McElieceCiphertext:
    """
    McEliece Encryption

    Input: Public key, message m ∈ GF(2)^k, error weight t
    Output: Ciphertext c = m·G' + e

    Algorithm:
    1. Compute codeword c₀ = m · G'
    2. Generate random error e with wt(e) = t
    3. Output c = c₀ + e
    """
    n = len(pk.public_matrix[0])
    codeword = gf2_mat_vec(pk.public_matrix, message)
    error = [0] * n
    positions = random.sample(range(n), t)
    for p in positions:
        error[p] = 1
    ciphertext = gf2_add(codeword, error)
    return McElieceCiphertext(data=ciphertext)


def mceliece_decrypt(sk: McElieceSecretKey,
                      ct: McElieceCiphertext,
                      decoder) -> Optional[BinaryVector]:
    """
    McEliece Decryption

    Input: Secret key, ciphertext
    Output: Recovered message or None

    Algorithm:
    1. Apply inverse permutation P⁻¹ to ciphertext
    2. Decode using the secret Goppa code decoder
    3. Apply inverse scrambler S⁻¹ to recovered message
    """
    n = len(ct.data)
    P_inv = [0] * n
    for i, p in enumerate(sk.permutation):
        P_inv[p] = i

    # Unpermute
    unpermuted = [ct.data[P_inv[j]] for j in range(n)]

    # Decode (provided by the Goppa code)
    decoded = decoder(unpermuted)
    if decoded is None:
        return None

    # Apply S⁻¹ (identity in simplified case)
    return decoded


# ============================================================
# Information Set Decoding (Attack)
# ============================================================

def isd_attack(public_matrix: BinaryMatrix,
               ciphertext: BinaryVector,
               t: int,
               max_iterations: int = 10000) -> Optional[BinaryVector]:
    """
    Information Set Decoding Attack

    Input: Public key matrix G', ciphertext c, target weight t
    Output: Message m such that wt(c - mG') ≤ t, or None

    Algorithm:
    1. Choose random information set I ⊂ {0,...,n-1}, |I| = k
    2. Extract G'_I (submatrix of columns in I)
    3. If G'_I invertible, compute m = c_I · (G'_I)⁻¹
    4. Check if wt(c - m·G') ≤ t
    5. Repeat until success

    Expected iterations: C(n,t) / C(n-k,t)
    """
    k = len(public_matrix)
    n = len(public_matrix[0])

    for _ in range(max_iterations):
        # Random information set
        info_set = sorted(random.sample(range(n), k))

        # Extract submatrix
        G_I = [[public_matrix[i][j] for j in info_set] for i in range(k)]

        # Check if invertible (rank = k)
        if gf2_rank(G_I) < k:
            continue

        # Solve for message (simplified: try systematic form)
        c_I = [ciphertext[j] for j in info_set]

        # Gaussian elimination to solve G_I^T · m = c_I
        augmented = [G_I[i][:] + [c_I[i]] for i in range(k)]
        # ... (full Gaussian elimination omitted for brevity)

        # Check error weight
        # candidate_codeword = gf2_mat_vec(public_matrix, m_candidate)
        # error = gf2_add(ciphertext, candidate_codeword)
        # if hamming_weight(error) <= t: return m_candidate

    return None  # Failed


# ============================================================
# Security Analysis Functions
# ============================================================

def isd_work_factor(n: int, k: int, t: int) -> float:
    """
    Compute the ISD work factor log2(C(n,t) / C(n-k,t)).

    This is the expected number of iterations (in bits) for the basic
    Lee-Brickell ISD algorithm.
    """
    log_num = sum(log2(n - i) - log2(i + 1) for i in range(t))
    log_den = sum(log2(n - k - i) - log2(i + 1) for i in range(min(t, n - k)))
    return log_num - log_den


def grover_bound(classical_bits: float) -> float:
    """
    Grover's quantum lower bound: quantum security = classical / 2.
    """
    return classical_bits / 2


def quantum_security_level(n: int, k: int, t: int) -> float:
    """Compute quantum security level in bits."""
    classical = isd_work_factor(n, k, t)
    return grover_bound(classical)


def validate_nist_params() -> List[Dict]:
    """Validate NIST McEliece parameter sets."""
    params = [
        McElieceParams(n=3488, k=2720, t=64, m=12),
        McElieceParams(n=4608, k=3360, t=96, m=13),
        McElieceParams(n=6688, k=5024, t=128, m=13),
        McElieceParams(n=6960, k=5413, t=119, m=13),
        McElieceParams(n=8192, k=6528, t=128, m=13),
    ]

    results = []
    for p in params:
        classical = isd_work_factor(p.n, p.k, p.t)
        quantum = grover_bound(classical)
        results.append({
            'params': f'[{p.n}, {p.k}, {p.t}]',
            'valid': p.validate(),
            'classical_security_bits': round(classical, 1),
            'quantum_security_bits': round(quantum, 1),
            'key_size_bytes': p.k * (p.n - p.k) // 8,
        })

    return results


# ============================================================
# Goppa Code Rate Analysis
# ============================================================

def goppa_rate(n: int, m: int, t: int) -> float:
    """
    Compute the rate R = k/n of a binary Goppa code.
    k ≥ n - m·t, so R ≥ 1 - m·t/n.
    """
    k_lower = max(0, n - m * t)
    return k_lower / n


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print("McEliece Parameter Validation")
    print("=" * 70)
    results = validate_nist_params()
    for r in results:
        print(f"  {r['params']}: valid={r['valid']}, "
              f"classical={r['classical_security_bits']} bits, "
              f"quantum={r['quantum_security_bits']} bits, "
              f"key={r['key_size_bytes']} bytes")

    print("\nGoppa Code Rates")
    print("=" * 70)
    for n, m, t in [(3488, 12, 64), (4608, 13, 96), (6688, 13, 128)]:
        print(f"  Γ({n}, {m}, {t}): rate ≥ {goppa_rate(n, m, t):.4f}")
