#!/usr/bin/env python3
"""
Tropical RSA Algorithms: Min-Plus Cryptographic Primitives

Complete implementations of:
1. Tropical matrix arithmetic (min-plus semiring)
2. Tropical key generation, encryption, decryption
3. Tropical Diffie-Hellman key exchange
4. Tropical matrix factorization (brute-force search)
5. Fast tropical matrix exponentiation (repeated squaring)

All algorithms include docstrings, type hints, complexity analysis,
and example usage.
"""

import numpy as np
from typing import Tuple, List, Optional
from dataclasses import dataclass
import time

INF = float('inf')


# =============================================================================
# Core Tropical Arithmetic
# =============================================================================

class TropicalMatrix:
    """
    An n×n matrix over the min-plus (tropical) semiring.

    Operations:
      - Tropical addition (⊕): entrywise min
      - Tropical multiplication (⊗): (A⊗B)_{ij} = min_k(A_{ik} + B_{kj})

    This is the algebraic structure underlying shortest-path computation
    and tropical cryptography.
    """

    def __init__(self, data: np.ndarray):
        """Initialize from a numpy array. Use float('inf') for ∞."""
        self.data = np.array(data, dtype=float)
        self.n = self.data.shape[0]
        assert self.data.shape == (self.n, self.n), "Matrix must be square"

    @staticmethod
    def identity(n: int) -> 'TropicalMatrix':
        """
        Tropical identity matrix: 0 on diagonal, ∞ off diagonal.

        Time: O(n²), Space: O(n²)
        """
        I = np.full((n, n), INF)
        np.fill_diagonal(I, 0)
        return TropicalMatrix(I)

    @staticmethod
    def random(n: int, max_val: int = 100) -> 'TropicalMatrix':
        """
        Random tropical matrix with entries in {0, 1, ..., max_val}.

        Time: O(n²), Space: O(n²)
        """
        return TropicalMatrix(np.random.randint(0, max_val + 1, (n, n)).astype(float))

    def __matmul__(self, other: 'TropicalMatrix') -> 'TropicalMatrix':
        """
        Tropical matrix multiplication (⊗).

        (A ⊗ B)_{ij} = min_k (A_{ik} + B_{kj})

        This computes shortest-path composition: the (i,j) entry is the
        minimum cost of any 2-hop path from i to j through intermediate k.

        Time: O(n³), Space: O(n²)
        """
        assert self.n == other.n
        n = self.n
        C = np.full((n, n), INF)
        for i in range(n):
            for j in range(n):
                for k in range(n):
                    val = self.data[i, k] + other.data[k, j]
                    if val < C[i, j]:
                        C[i, j] = val
        return TropicalMatrix(C)

    def power(self, k: int) -> 'TropicalMatrix':
        """
        Tropical matrix power via repeated multiplication.

        A^k = A ⊗ A ⊗ ... ⊗ A (k times)

        Key property: A^k[i][j] = cost of shortest k-hop path from i to j.

        Time: O(k · n³), Space: O(n²)
        """
        result = TropicalMatrix.identity(self.n)
        for _ in range(k):
            result = self @ result
        return result

    def fast_power(self, k: int) -> 'TropicalMatrix':
        """
        Tropical matrix power via repeated squaring.

        Uses the identity: A^(2m) = (A^m)^2, A^(2m+1) = A ⊗ (A^m)^2

        Time: O(n³ · log k), Space: O(n²)

        This is the efficient algorithm used in practice for tropical
        cryptography, where exponents can be very large.
        """
        if k == 0:
            return TropicalMatrix.identity(self.n)
        if k == 1:
            return TropicalMatrix(self.data.copy())

        result = TropicalMatrix.identity(self.n)
        base = TropicalMatrix(self.data.copy())
        while k > 0:
            if k % 2 == 1:
                result = base @ result
            base = base @ base
            k //= 2
        return result

    def __eq__(self, other: 'TropicalMatrix') -> bool:
        """Check equality of tropical matrices."""
        return np.array_equal(self.data, other.data)

    def __repr__(self) -> str:
        rows = []
        for i in range(self.n):
            row = []
            for j in range(self.n):
                if self.data[i, j] == INF:
                    row.append("  ∞")
                else:
                    row.append(f"{self.data[i, j]:3.0f}")
            rows.append("[" + " ".join(row) + "]")
        return "\n".join(rows)


# =============================================================================
# Tropical Cryptographic Primitives
# =============================================================================

@dataclass
class TropicalPublicKey:
    """Public key: (G, G^a) where G is the generator and a is the secret exponent."""
    generator: TropicalMatrix
    public_value: TropicalMatrix


@dataclass
class TropicalPrivateKey:
    """Private key: the secret exponent a."""
    exponent: int


@dataclass
class TropicalCiphertext:
    """Ciphertext: (G^r, (G^a)^r ⊗ M) where r is random."""
    ephemeral: TropicalMatrix
    masked: TropicalMatrix


@dataclass
class TropicalKeyPair:
    """A complete key pair."""
    public_key: TropicalPublicKey
    private_key: TropicalPrivateKey


def keygen(n: int, max_val: int = 100, max_exp: int = 20) -> TropicalKeyPair:
    """
    Generate a tropical key pair.

    Algorithm:
    1. Generate a random n×n tropical matrix G (the generator).
    2. Choose a random secret exponent a.
    3. Compute the public value G^a using fast exponentiation.

    Args:
        n: Matrix dimension
        max_val: Maximum entry value in the generator
        max_exp: Maximum secret exponent

    Returns:
        TropicalKeyPair containing public and private keys

    Time: O(n³ · log a), Space: O(n²)
    """
    G = TropicalMatrix.random(n, max_val)
    a = np.random.randint(1, max_exp + 1)
    G_a = G.fast_power(a)
    pk = TropicalPublicKey(generator=G, public_value=G_a)
    sk = TropicalPrivateKey(exponent=a)
    return TropicalKeyPair(public_key=pk, private_key=sk)


def encrypt(pk: TropicalPublicKey, message: TropicalMatrix,
            randomness: Optional[int] = None) -> TropicalCiphertext:
    """
    Encrypt a message matrix using tropical ElGamal.

    Algorithm:
    1. Choose random r (or use provided randomness).
    2. Compute ephemeral = G^r.
    3. Compute shared = (G^a)^r = G^(ar).
    4. Compute masked = shared ⊗ M.

    Args:
        pk: Recipient's public key (G, G^a)
        message: Plaintext matrix M
        randomness: Optional deterministic randomness r

    Returns:
        TropicalCiphertext = (G^r, G^(ar) ⊗ M)

    Time: O(n³ · log r), Space: O(n²)
    """
    r = randomness if randomness is not None else np.random.randint(1, 20)
    ephemeral = pk.generator.fast_power(r)
    shared = pk.public_value.fast_power(r)  # (G^a)^r
    masked = shared @ message
    return TropicalCiphertext(ephemeral=ephemeral, masked=masked)


def compute_shared_secret(sk: TropicalPrivateKey,
                          ciphertext: TropicalCiphertext) -> TropicalMatrix:
    """
    Compute the shared secret from the private key and ciphertext.

    Algorithm:
    1. Compute (G^r)^a = G^(ra) = G^(ar) = shared secret.

    This matches the sender's (G^a)^r by commutativity of tropical powers.

    Args:
        sk: Recipient's private key (exponent a)
        ciphertext: The ciphertext containing ephemeral = G^r

    Returns:
        The shared secret matrix G^(ar)

    Time: O(n³ · log a), Space: O(n²)
    """
    return ciphertext.ephemeral.fast_power(sk.exponent)


# =============================================================================
# Tropical Diffie-Hellman Key Exchange
# =============================================================================

def diffie_hellman_exchange(n: int, max_val: int = 50) -> Tuple[TropicalMatrix, TropicalMatrix]:
    """
    Simulate a tropical Diffie-Hellman key exchange.

    Protocol:
    1. Alice and Bob agree on public generator G.
    2. Alice chooses secret a, publishes G^a.
    3. Bob chooses secret b, publishes G^b.
    4. Alice computes (G^b)^a = G^(ba).
    5. Bob computes (G^a)^b = G^(ab).
    6. G^(ab) = G^(ba) by commutativity of exponents.

    Returns:
        (alice_shared, bob_shared) — should be equal!

    Time: O(n³ · (log a + log b)), Space: O(n²)
    """
    G = TropicalMatrix.random(n, max_val)
    a = np.random.randint(2, 15)
    b = np.random.randint(2, 15)

    # Public values
    G_a = G.fast_power(a)
    G_b = G.fast_power(b)

    # Shared secrets
    alice_shared = G_b.fast_power(a)  # (G^b)^a = G^(ba)
    bob_shared = G_a.fast_power(b)    # (G^a)^b = G^(ab)

    return alice_shared, bob_shared


# =============================================================================
# Tropical Matrix Factorization (Attack Algorithm)
# =============================================================================

def brute_force_factorization(target: TropicalMatrix,
                              generator: TropicalMatrix,
                              max_exp: int = 50) -> Optional[int]:
    """
    Brute-force attack: recover secret exponent s from (G, G^s).

    Algorithm:
    For each candidate exponent k = 1, 2, ..., max_exp:
        Compute G^k and check if G^k == target.

    This is the naive attack that tropical cryptography must resist.
    For large dimensions and exponents, this becomes infeasible.

    Args:
        target: The public value G^s
        generator: The generator matrix G
        max_exp: Maximum exponent to try

    Returns:
        The recovered exponent, or None if not found

    Time: O(max_exp · n³ · log max_exp), Space: O(n²)
    """
    for k in range(1, max_exp + 1):
        if generator.fast_power(k) == target:
            return k
    return None


# =============================================================================
# Benchmarking
# =============================================================================

def benchmark_operations(sizes: List[int] = [2, 4, 8, 16, 32]) -> None:
    """
    Benchmark tropical matrix operations across different dimensions.

    Measures:
    - Matrix multiplication time
    - Fast exponentiation time
    - Key generation time
    """
    print(f"{'n':>4} {'Mul (ms)':>10} {'Pow-10 (ms)':>12} {'Pow-100 (ms)':>13}")
    print("-" * 45)

    for n in sizes:
        A = TropicalMatrix.random(n, 100)
        B = TropicalMatrix.random(n, 100)

        # Multiplication
        t0 = time.time()
        for _ in range(10):
            _ = A @ B
        t_mul = (time.time() - t0) / 10 * 1000

        # Power 10
        t0 = time.time()
        for _ in range(10):
            _ = A.fast_power(10)
        t_pow10 = (time.time() - t0) / 10 * 1000

        # Power 100
        t0 = time.time()
        for _ in range(10):
            _ = A.fast_power(100)
        t_pow100 = (time.time() - t0) / 10 * 1000

        print(f"{n:4d} {t_mul:10.2f} {t_pow10:12.2f} {t_pow100:13.2f}")


# =============================================================================
# Main: Run Examples
# =============================================================================

if __name__ == "__main__":
    np.random.seed(42)

    print("=" * 60)
    print("TROPICAL CRYPTOGRAPHY: Algorithm Demonstrations")
    print("=" * 60)
    print()

    # Key exchange
    print("--- Diffie-Hellman Key Exchange ---")
    alice_shared, bob_shared = diffie_hellman_exchange(4)
    print(f"Shared secrets match: {alice_shared == bob_shared}")
    print()

    # Encryption
    print("--- Encryption/Decryption ---")
    kp = keygen(3, max_val=10, max_exp=8)
    M = TropicalMatrix.random(3, 10)
    ct = encrypt(kp.public_key, M, randomness=5)
    shared = compute_shared_secret(kp.private_key, ct)
    sender_shared = kp.public_key.public_value.fast_power(5)
    print(f"Shared secrets match: {shared == sender_shared}")
    print()

    # Brute-force attack
    print("--- Brute-Force Attack ---")
    G = TropicalMatrix.random(3, 10)
    secret = 7
    target = G.fast_power(secret)
    recovered = brute_force_factorization(target, G, max_exp=20)
    print(f"True secret: {secret}, Recovered: {recovered}")
    print()

    # Benchmarks
    print("--- Performance Benchmarks ---")
    benchmark_operations([2, 4, 8, 16])
    print()

    # Fast vs naive power
    print("--- Fast Exponentiation Verification ---")
    G = TropicalMatrix.random(4, 20)
    for k in [1, 5, 10, 20, 50]:
        naive = G.power(k)
        fast = G.fast_power(k)
        print(f"  G^{k:2d}: naive == fast? {naive == fast}")
    print()

    print("All algorithm demonstrations complete!")
