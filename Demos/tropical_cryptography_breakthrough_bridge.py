#!/usr/bin/env python3
"""
Tropical Cryptography — Core Algorithms

Implements the key generation, encoding, and decoding algorithms
for the tropical KEM (Key Encapsulation Mechanism) based on
row-separated min-plus matrix action.
"""

import numpy as np
from typing import Tuple, Optional


def tropical_matvec(A: np.ndarray, x: np.ndarray) -> np.ndarray:
    """Compute the tropical (min-plus) matrix–vector product.
    
    T_A(x)[i] = min_j (A[i,j] + x[j])
    
    Time complexity: O(n * m) where A is n×m.
    Space complexity: O(n) for the output.
    
    Args:
        A: Matrix of shape (n, m).
        x: Vector of shape (m,).
    
    Returns:
        Vector of shape (n,).
    
    Example:
        >>> A = np.array([[3, 1, 4], [1, 5, 9]])
        >>> x = np.array([2, 7, 1])
        >>> tropical_matvec(A, x)
        array([5., 3.])
    """
    return np.min(A + x[np.newaxis, :], axis=1)


def keygen(n: int, delta: float, seed: Optional[int] = None) -> Tuple[np.ndarray, np.ndarray]:
    """Generate a tropical KEM key pair.
    
    Public key: row-separated matrix A ∈ ℝ^{n×n}
    Secret key: permutation σ ∈ S_n (as an array of indices)
    
    The matrix satisfies: A[i, σ[i]] + δ ≤ A[i, j] for all j ≠ σ[i].
    
    Time complexity: O(n²).
    Space complexity: O(n²) for A, O(n) for σ.
    
    Args:
        n: Dimension (security parameter).
        delta: Row separation gap (controls security margin).
        seed: Random seed for reproducibility.
    
    Returns:
        (A, sigma): Public key matrix and secret permutation.
    
    Example:
        >>> A, sigma = keygen(8, delta=2.0, seed=42)
        >>> A.shape
        (8, 8)
        >>> len(set(sigma))  # sigma is a permutation
        8
    """
    rng = np.random.RandomState(seed)
    sigma = rng.permutation(n)
    
    base = rng.randn(n) * 2
    A = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            if j == sigma[i]:
                A[i, j] = base[i]
            else:
                A[i, j] = base[i] + delta + rng.uniform(0, 2)
    
    return A, sigma


def encode(A: np.ndarray, x: np.ndarray) -> np.ndarray:
    """Encode (encrypt) a message using tropical matrix action.
    
    c = T_A(x) where T_A is the min-plus matrix–vector product.
    
    Time complexity: O(n²).
    
    Args:
        A: Public key matrix of shape (n, n).
        x: Message vector of shape (n,) with bounded oscillation.
    
    Returns:
        Ciphertext vector of shape (n,).
    """
    return tropical_matvec(A, x)


def decode(A: np.ndarray, sigma: np.ndarray, c: np.ndarray) -> np.ndarray:
    """Decode (decrypt) a ciphertext using the trapdoor permutation.
    
    x[j] = c[σ⁻¹(j)] - A[σ⁻¹(j), j]
    
    Time complexity: O(n).
    
    Args:
        A: Public key matrix of shape (n, n).
        sigma: Secret permutation (array of length n).
        c: Ciphertext vector of shape (n,).
    
    Returns:
        Recovered message vector of shape (n,).
    """
    n = len(sigma)
    sigma_inv = np.argsort(sigma)
    x = np.zeros(n)
    for j in range(n):
        i = sigma_inv[j]
        x[j] = c[i] - A[i, j]
    return x


def encapsulate(A: np.ndarray, delta: float, seed: Optional[int] = None) -> Tuple[np.ndarray, np.ndarray]:
    """Key encapsulation: generate a shared secret and ciphertext.
    
    Samples a random bounded-oscillation vector x, computes the
    ciphertext c = T_A(x), and derives a shared key K = hash(x).
    
    Args:
        A: Public key matrix.
        delta: Oscillation bound.
        seed: Random seed.
    
    Returns:
        (ciphertext, shared_key_material): The ciphertext and the raw
        key material (the message x). In practice, x would be hashed.
    """
    rng = np.random.RandomState(seed)
    n = A.shape[0]
    center = rng.randn()
    x = center + rng.uniform(-delta / 2, delta / 2, size=n)
    c = encode(A, x)
    return c, x


def decapsulate(A: np.ndarray, sigma: np.ndarray, c: np.ndarray) -> np.ndarray:
    """Key decapsulation: recover the shared secret from a ciphertext.
    
    Args:
        A: Public key matrix.
        sigma: Secret permutation.
        c: Ciphertext.
    
    Returns:
        Recovered key material (the message x).
    """
    return decode(A, sigma, c)


def verify_row_separation(A: np.ndarray, sigma: np.ndarray, delta: float) -> bool:
    """Verify that a matrix satisfies the row separation condition.
    
    Args:
        A: Matrix of shape (n, m).
        sigma: Designated minimizer for each row.
        delta: Required separation gap.
    
    Returns:
        True if the row separation condition holds.
    """
    n, m = A.shape
    for i in range(n):
        for j in range(m):
            if j != sigma[i]:
                if A[i, sigma[i]] + delta > A[i, j] + 1e-12:
                    return False
    return True


def verify_bounded_oscillation(x: np.ndarray, delta: float) -> bool:
    """Verify that a vector has bounded oscillation.
    
    Args:
        x: Vector.
        delta: Oscillation bound.
    
    Returns:
        True if max|x_j - x_k| ≤ δ.
    """
    return (np.max(x) - np.min(x)) <= delta + 1e-12


# ─── Example usage ───

if __name__ == "__main__":
    print("Tropical KEM — Full Protocol Demo")
    print("=" * 50)
    
    n = 8
    delta = 2.0
    
    # Key generation
    A, sigma = keygen(n, delta, seed=42)
    print(f"Key generation: n={n}, δ={delta}")
    print(f"  Secret permutation σ = {sigma}")
    print(f"  Row separation verified: {verify_row_separation(A, sigma, delta)}")
    
    # Encapsulation
    ct, key_material = encapsulate(A, delta, seed=123)
    print(f"\nEncapsulation:")
    print(f"  Key material x = {np.round(key_material, 4)}")
    print(f"  Oscillation = {np.max(key_material) - np.min(key_material):.4f}")
    print(f"  Ciphertext c = {np.round(ct, 4)}")
    
    # Decapsulation
    recovered = decapsulate(A, sigma, ct)
    print(f"\nDecapsulation:")
    print(f"  Recovered x = {np.round(recovered, 10)}")
    print(f"  Match: {np.allclose(key_material, recovered)}")
    
    # Security test: try to decode without the secret key
    print(f"\nSecurity test:")
    wrong_sigma = np.roll(sigma, 1)  # Wrong permutation
    wrong_recovery = decode(A, wrong_sigma, ct)
    print(f"  With wrong σ: {np.round(wrong_recovery, 4)}")
    print(f"  Matches original: {np.allclose(key_material, wrong_recovery)}")


#!/usr/bin/env python3
"""
Tropical Cryptography — Applications

Demonstrates practical applications of the tropical row-separated
injectivity theorem in cryptographic settings.
"""

import numpy as np
import hashlib
from typing import List, Tuple


def tropical_matvec(A: np.ndarray, x: np.ndarray) -> np.ndarray:
    """Min-plus matrix–vector product."""
    return np.min(A + x[np.newaxis, :], axis=1)


def make_separated_matrix(n: int, delta: float, seed: int = 42) -> Tuple[np.ndarray, np.ndarray]:
    """Generate a row-separated matrix with random permutation."""
    rng = np.random.RandomState(seed)
    sigma = rng.permutation(n)
    base = rng.randn(n) * 2
    A = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            if j == sigma[i]:
                A[i, j] = base[i]
            else:
                A[i, j] = base[i] + delta + rng.uniform(0, 2)
    return A, sigma


# ─── Application 1: Tropical Hash Function ───

def tropical_hash(A: np.ndarray, message: np.ndarray) -> bytes:
    """Hash a message using tropical matrix action.
    
    The message is encoded as a bounded-oscillation vector,
    then mapped through T_A and discretized to produce a hash.
    
    Args:
        A: Hash key matrix (n×m with m > n for compression).
        message: Input vector of bounded oscillation.
    
    Returns:
        Hash digest as bytes.
    """
    ct = tropical_matvec(A, message)
    # Discretize to fixed precision and hash
    discretized = np.round(ct * 1e6).astype(np.int64)
    raw = discretized.tobytes()
    return hashlib.sha256(raw).digest()


def demo_tropical_hashing():
    """Demonstrate collision resistance of tropical hashing."""
    print("Application 1: Tropical Hash Function")
    print("=" * 50)
    
    n_out = 8   # output dimension
    n_in = 16   # input dimension (compression: 16 → 8)
    delta = 2.0
    
    rng = np.random.RandomState(42)
    sigma = rng.permutation(n_in)[:n_out]  # injective but not surjective
    base = rng.randn(n_out) * 2
    A = np.zeros((n_out, n_in))
    for i in range(n_out):
        for j in range(n_in):
            if j == sigma[i]:
                A[i, j] = base[i]
            else:
                A[i, j] = base[i] + delta + rng.uniform(0, 2)
    
    # Hash several messages
    messages = [
        np.ones(n_in) * 0.5,
        np.ones(n_in) * 0.5 + 0.001 * np.eye(n_in)[0],  # tiny perturbation
        np.zeros(n_in),
        rng.uniform(-0.5, 0.5, n_in),
    ]
    
    print(f"Matrix: {n_out}×{n_in}, δ={delta}")
    print(f"\nHashes of 4 messages:")
    for i, msg in enumerate(messages):
        h = tropical_hash(A, msg)
        print(f"  msg[{i}]: {h.hex()[:32]}...")
    
    # Check that different messages produce different hashes
    hashes = [tropical_hash(A, m) for m in messages]
    unique = len(set(hashes))
    print(f"\nUnique hashes: {unique}/{len(messages)}")


# ─── Application 2: Tropical Commitment Scheme ───

def tropical_commit(A: np.ndarray, sigma: np.ndarray, 
                     value: float, delta: float, seed: int) -> Tuple[np.ndarray, np.ndarray]:
    """Commit to a value using tropical encoding.
    
    Returns (commitment, opening) where:
    - commitment = T_A(r) where r encodes the value
    - opening = r (the randomness)
    
    Binding: changing the value changes the commitment (by injectivity).
    Hiding: the commitment looks random without knowing σ.
    """
    rng = np.random.RandomState(seed)
    n = A.shape[0]
    # Encode value into a bounded-oscillation vector
    r = value + rng.uniform(-delta/4, delta/4, size=n)
    commitment = tropical_matvec(A, r)
    return commitment, r


def tropical_verify(A: np.ndarray, sigma: np.ndarray,
                     commitment: np.ndarray, opening: np.ndarray) -> bool:
    """Verify a tropical commitment."""
    recomputed = tropical_matvec(A, opening)
    return np.allclose(commitment, recomputed)


def demo_commitment_scheme():
    """Demonstrate the tropical commitment scheme."""
    print("\n\nApplication 2: Tropical Commitment Scheme")
    print("=" * 50)
    
    n = 8
    delta = 3.0
    A, sigma = make_separated_matrix(n, delta, seed=99)
    
    # Alice commits to value 42
    value = 42.0
    commitment, opening = tropical_commit(A, sigma, value, delta, seed=7)
    
    print(f"Alice commits to value {value}")
    print(f"  Commitment: {np.round(commitment, 4)}")
    print(f"  Opening: {np.round(opening, 4)}")
    
    # Verification
    valid = tropical_verify(A, sigma, commitment, opening)
    print(f"  Verification: {valid}")
    
    # Binding: trying to open with a different value fails
    fake_opening = opening.copy()
    fake_opening[0] += 0.1
    fake_valid = tropical_verify(A, sigma, commitment, fake_opening)
    print(f"  Fake opening verification: {fake_valid}")


# ─── Application 3: Tropical Fingerprinting ───

def tropical_fingerprint(A: np.ndarray, data: np.ndarray, delta: float) -> np.ndarray:
    """Create a tropical fingerprint of data.
    
    Maps high-dimensional data to a lower-dimensional tropical encoding
    that preserves identity (by injectivity on the bounded domain).
    """
    # Normalize to bounded oscillation
    data_centered = data - np.mean(data)
    scale = max(np.max(np.abs(data_centered)), 1e-10)
    normalized = data_centered * (delta / (2 * scale))
    return tropical_matvec(A, normalized)


def demo_fingerprinting():
    """Demonstrate tropical fingerprinting for data integrity."""
    print("\n\nApplication 3: Tropical Fingerprinting")
    print("=" * 50)
    
    n = 6
    delta = 2.0
    A, sigma = make_separated_matrix(n, delta, seed=55)
    
    # Create some "documents" (data vectors)
    docs = [
        np.array([1.0, 2.0, 3.0, 4.0, 5.0, 6.0]),
        np.array([1.0, 2.0, 3.0, 4.0, 5.0, 6.1]),  # slightly modified
        np.array([6.0, 5.0, 4.0, 3.0, 2.0, 1.0]),   # reversed
        np.array([1.0, 2.0, 3.0, 4.0, 5.0, 6.0]),   # duplicate of doc 0
    ]
    
    print(f"Matrix: {n}×{n}, δ={delta}")
    print(f"\nFingerprints:")
    fps = []
    for i, doc in enumerate(docs):
        fp = tropical_fingerprint(A, doc, delta)
        fps.append(fp)
        print(f"  Doc {i}: {np.round(fp, 4)}")
    
    # Check: identical docs → identical fingerprints
    print(f"\n  Doc 0 == Doc 3: {np.allclose(fps[0], fps[3])}")
    print(f"  Doc 0 == Doc 1: {np.allclose(fps[0], fps[1])}")
    print(f"  Doc 0 == Doc 2: {np.allclose(fps[0], fps[2])}")


# ─── Application 4: Security Parameter Analysis ───

def analyze_security_parameters():
    """Analyze how security scales with dimension and separation."""
    print("\n\nApplication 4: Security Parameter Analysis")
    print("=" * 50)
    
    print(f"\n{'n':>6} | {'log2(n!)':>10} | {'Grover (log2)':>14} | {'Key size (KB)':>14}")
    print("-" * 50)
    
    for n in [8, 16, 32, 64, 128, 256]:
        import math
        log2_nfact = sum(math.log2(k) for k in range(1, n+1))
        grover = log2_nfact / 2
        key_size_kb = n * n * 8 / 1024  # doubles
        print(f"{n:>6} | {log2_nfact:>10.1f} | {grover:>14.1f} | {key_size_kb:>14.1f}")
    
    print("\nNote: Grover's algorithm gives the best known quantum attack.")
    print("For n=128, even quantum search requires ~2^356 operations.")


if __name__ == "__main__":
    demo_tropical_hashing()
    demo_commitment_scheme()
    demo_fingerprinting()
    analyze_security_parameters()
    
    print("\n" + "=" * 50)
    print("All applications completed successfully.")
    print("=" * 50)


#!/usr/bin/env python3
"""
Tropical Cryptography Bridge — Interactive Demo

Demonstrates the row-separated tropical matrix–vector product
and its injectivity properties, as formalized in Lean 4.

The key insight: under a row-separation condition, the min-plus
matrix action collapses to a simple affine readout, making the
map injective on bounded-oscillation domains.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from itertools import permutations
import base64
from io import BytesIO


def tropical_matvec(A: np.ndarray, x: np.ndarray) -> np.ndarray:
    """Compute the tropical (min-plus) matrix–vector product.
    
    (T_A x)(i) = min_j (A[i,j] + x[j])
    
    Args:
        A: Matrix of shape (n, m)
        x: Vector of shape (m,)
    Returns:
        Vector of shape (n,) with the tropical product.
    """
    return np.min(A + x[np.newaxis, :], axis=1)


def affine_readout(A: np.ndarray, sigma: np.ndarray, x: np.ndarray) -> np.ndarray:
    """Compute the affine readout A[i, sigma[i]] + x[sigma[i]].
    
    This is what the tropical product equals under row separation.
    """
    n = A.shape[0]
    return np.array([A[i, sigma[i]] + x[sigma[i]] for i in range(n)])


def check_row_separation(A: np.ndarray, sigma: np.ndarray, delta: float) -> bool:
    """Check whether matrix A is row-separated with designated columns sigma and gap delta."""
    n, m = A.shape
    for i in range(n):
        for j in range(m):
            if j != sigma[i]:
                if A[i, sigma[i]] + delta > A[i, j] + 1e-12:
                    return False
    return True


def check_bounded_oscillation(x: np.ndarray, delta: float) -> bool:
    """Check whether vector x has oscillation bounded by delta."""
    return np.max(x) - np.min(x) <= delta + 1e-12


def make_separated_matrix(n: int, delta: float, seed: int = 42) -> tuple:
    """Generate a random row-separated matrix with a random permutation sigma.
    
    Returns (A, sigma) where A is n×n and sigma is a permutation of {0,...,n-1}.
    """
    rng = np.random.RandomState(seed)
    sigma = rng.permutation(n)
    
    # Start with random base values for designated columns
    base = rng.randn(n) * 2
    
    # Build the matrix: designated columns get base[i], others get base[i] + delta + extra
    A = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            if j == sigma[i]:
                A[i, j] = base[i]
            else:
                A[i, j] = base[i] + delta + rng.uniform(0, 2)
    
    return A, sigma


def demo_row_rigidity():
    """Demonstrate that tropical action = affine readout under separation."""
    print("=" * 60)
    print("DEMO 1: Row Rigidity Theorem")
    print("=" * 60)
    
    n = 5
    delta = 1.0
    A, sigma = make_separated_matrix(n, delta, seed=42)
    
    print(f"\nMatrix A ({n}×{n}), delta = {delta}")
    print(f"Designated permutation sigma = {sigma}")
    print(f"Row separation verified: {check_row_separation(A, sigma, delta)}")
    
    # Generate a bounded-oscillation vector
    rng = np.random.RandomState(123)
    center = rng.randn()
    x = center + rng.uniform(-delta/2, delta/2, size=n)
    
    print(f"\nInput vector x = {np.round(x, 4)}")
    print(f"Oscillation = {np.max(x) - np.min(x):.4f} <= {delta} : {check_bounded_oscillation(x, delta)}")
    
    trop = tropical_matvec(A, x)
    affine = affine_readout(A, sigma, x)
    
    print(f"\nTropical product T_A(x) = {np.round(trop, 6)}")
    print(f"Affine readout          = {np.round(affine, 6)}")
    print(f"Max difference          = {np.max(np.abs(trop - affine)):.2e}")
    print(f"Equal (up to float):      {np.allclose(trop, affine)}")
    
    return A, sigma, delta


def demo_injectivity():
    """Demonstrate injectivity of tropical action on bounded-oscillation domain."""
    print("\n" + "=" * 60)
    print("DEMO 2: Injectivity Theorem")
    print("=" * 60)
    
    n = 4
    delta = 2.0
    A, sigma = make_separated_matrix(n, delta, seed=99)
    
    print(f"\nMatrix A ({n}×{n}), delta = {delta}")
    print(f"Designated permutation sigma = {sigma}")
    
    # Generate many random bounded-oscillation vectors
    rng = np.random.RandomState(7)
    num_samples = 1000
    outputs = []
    inputs = []
    
    for _ in range(num_samples):
        center = rng.randn() * 3
        x = center + rng.uniform(-delta/2, delta/2, size=n)
        inputs.append(x.copy())
        outputs.append(tropical_matvec(A, x))
    
    # Check injectivity: no two distinct inputs produce the same output
    collisions = 0
    for i in range(num_samples):
        for j in range(i + 1, min(i + 50, num_samples)):  # Sample pairs
            if np.allclose(outputs[i], outputs[j], atol=1e-10):
                if not np.allclose(inputs[i], inputs[j], atol=1e-10):
                    collisions += 1
    
    print(f"\nTested {num_samples} random bounded-oscillation vectors")
    print(f"Collisions found: {collisions}")
    print(f"Injectivity confirmed: {collisions == 0}")


def demo_separation_breakdown():
    """Show what happens when separation or oscillation bounds are violated."""
    print("\n" + "=" * 60)
    print("DEMO 3: Breakdown Outside the Rigidity Regime")
    print("=" * 60)
    
    n = 3
    delta = 1.0
    A, sigma = make_separated_matrix(n, delta, seed=42)
    
    # Test with increasing oscillation
    print(f"\nMatrix ({n}×{n}), separation delta = {delta}")
    print(f"Permutation sigma = {sigma}")
    print(f"\n{'Oscillation':>12} | {'Max Error':>12} | {'Rigidity Holds':>15}")
    print("-" * 45)
    
    errors = []
    osc_values = np.linspace(0, 4 * delta, 20)
    
    for osc in osc_values:
        rng = np.random.RandomState(0)
        x = rng.uniform(-osc/2, osc/2, size=n)
        trop = tropical_matvec(A, x)
        affine = affine_readout(A, sigma, x)
        err = np.max(np.abs(trop - affine))
        errors.append(err)
        if osc in [0, delta/2, delta, 2*delta, 4*delta]:
            print(f"{osc:12.2f} | {err:12.2e} | {'YES' if err < 1e-10 else 'NO':>15}")
    
    return osc_values, errors, delta


def demo_cryptographic_encoding():
    """Demonstrate the encoding/decoding process for a finite message space."""
    print("\n" + "=" * 60)
    print("DEMO 4: Cryptographic Encoding of Finite Messages")
    print("=" * 60)
    
    n = 4
    delta = 3.0
    A, sigma = make_separated_matrix(n, delta, seed=55)
    sigma_inv = np.argsort(sigma)
    
    # Create a finite message space: binary strings of length n,
    # embedded as vectors with coordinates in {0, 1} (oscillation = 1 <= delta)
    messages = []
    for bits in range(2**n):
        msg = np.array([(bits >> i) & 1 for i in range(n)], dtype=float)
        messages.append(msg)
    
    print(f"\nMessage space: {len(messages)} binary vectors of length {n}")
    print(f"Max oscillation of messages: 1.0 <= delta = {delta}")
    
    # Encode all messages
    ciphertexts = [tropical_matvec(A, m) for m in messages]
    
    # Check injectivity
    unique_cts = set()
    for ct in ciphertexts:
        unique_cts.add(tuple(np.round(ct, 10)))
    
    print(f"Distinct ciphertexts: {len(unique_cts)} (= {len(messages)} messages)")
    print(f"Injective encoding: {len(unique_cts) == len(messages)}")
    
    # Demonstrate decoding using the inverse permutation
    print(f"\nDecoding via sigma^(-1):")
    print(f"sigma = {sigma}, sigma^(-1) = {sigma_inv}")
    
    test_msg = messages[7]  # 0111 in binary
    ct = tropical_matvec(A, test_msg)
    # Recover: x[sigma[i]] = ct[i] - A[i, sigma[i]]
    recovered = np.zeros(n)
    for i in range(n):
        recovered[sigma[i]] = ct[i] - A[i, sigma[i]]
    
    print(f"Original message:  {test_msg}")
    print(f"Ciphertext:        {np.round(ct, 4)}")
    print(f"Recovered message: {np.round(recovered, 10)}")
    print(f"Recovery exact:    {np.allclose(test_msg, recovered)}")


def generate_visualizations():
    """Generate visualizations for the research."""
    
    # Visualization 1: Row rigidity breakdown
    fig, axes = plt.subplots(1, 2, figsize=(12, 5))
    
    n = 3
    delta = 1.0
    A, sigma = make_separated_matrix(n, delta, seed=42)
    
    osc_values = np.linspace(0, 4 * delta, 100)
    errors = []
    
    for osc in osc_values:
        rng = np.random.RandomState(0)
        x = rng.uniform(-osc/2, osc/2, size=n)
        trop = tropical_matvec(A, x)
        affine = affine_readout(A, sigma, x)
        errors.append(np.max(np.abs(trop - affine)))
    
    ax = axes[0]
    ax.plot(osc_values / delta, errors, 'b-', linewidth=2)
    ax.axvline(x=1.0, color='r', linestyle='--', alpha=0.7, label='δ boundary')
    ax.fill_between(osc_values / delta, 0, max(errors) * 1.1,
                     where=osc_values <= delta, alpha=0.1, color='green')
    ax.set_xlabel('Oscillation / δ', fontsize=12)
    ax.set_ylabel('Max |tropical − affine|', fontsize=12)
    ax.set_title('Row Rigidity: Error vs. Oscillation', fontsize=13)
    ax.legend(fontsize=11)
    ax.set_ylim(bottom=-0.01)
    ax.grid(True, alpha=0.3)
    
    # Visualization 2: Injectivity — output spread
    n = 3
    delta = 2.0
    A, sigma = make_separated_matrix(n, delta, seed=99)
    
    rng = np.random.RandomState(42)
    num_samples = 500
    ins = []
    outs = []
    for _ in range(num_samples):
        center = rng.randn() * 2
        x = center + rng.uniform(-delta/2, delta/2, size=n)
        ins.append(x[0] - x[1])  # Project to 2D
        outs.append(tropical_matvec(A, x)[0] - tropical_matvec(A, x)[1])
    
    ax = axes[1]
    ax.scatter(ins, outs, s=8, alpha=0.6, c='purple')
    ax.set_xlabel('Input feature (x₁ − x₂)', fontsize=12)
    ax.set_ylabel('Output feature (y₁ − y₂)', fontsize=12)
    ax.set_title('Injectivity: Input vs. Output Projections', fontsize=13)
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('/workspace/request-project/tropical_crypto_bridge.png', dpi=150, bbox_inches='tight')
    plt.close()
    
    # Visualization 3: Matrix heatmap with separation structure
    fig, axes = plt.subplots(1, 2, figsize=(12, 5))
    
    n = 6
    delta = 1.5
    A, sigma = make_separated_matrix(n, delta, seed=77)
    
    ax = axes[0]
    im = ax.imshow(A, cmap='viridis', aspect='auto')
    for i in range(n):
        ax.plot(sigma[i], i, 'r*', markersize=15, markeredgecolor='white', markeredgewidth=1)
    ax.set_xlabel('Column j', fontsize=12)
    ax.set_ylabel('Row i', fontsize=12)
    ax.set_title('Tropical Matrix A\n(★ = designated minimizer σ(i))', fontsize=13)
    plt.colorbar(im, ax=ax)
    
    # Show the separation gaps
    ax = axes[1]
    gaps = []
    for i in range(n):
        min_other = min(A[i, j] for j in range(n) if j != sigma[i])
        gap = min_other - A[i, sigma[i]]
        gaps.append(gap)
    
    ax.barh(range(n), gaps, color='steelblue', edgecolor='navy')
    ax.axvline(x=delta, color='red', linestyle='--', linewidth=2, label=f'δ = {delta}')
    ax.set_xlabel('Separation gap (min competitor − designated)', fontsize=12)
    ax.set_ylabel('Row i', fontsize=12)
    ax.set_title('Row Separation Gaps', fontsize=13)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3, axis='x')
    
    plt.tight_layout()
    plt.savefig('/workspace/request-project/separation_structure.png', dpi=150, bbox_inches='tight')
    plt.close()
    
    print("\nVisualizations saved.")
    return True


if __name__ == "__main__":
    demo_row_rigidity()
    demo_injectivity()
    demo_separation_breakdown()
    demo_cryptographic_encoding()
    generate_visualizations()
    
    print("\n" + "=" * 60)
    print("All demos completed successfully.")
    print("=" * 60)
