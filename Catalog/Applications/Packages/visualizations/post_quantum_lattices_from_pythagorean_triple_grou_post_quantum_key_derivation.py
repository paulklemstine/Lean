#!/usr/bin/env python3
"""
Applications of Berggren Pythagorean Lattice Cryptography

Demonstrates real-world applications:
1. Post-quantum key derivation
2. Verifiable random function from Berggren orbit
3. Commitment scheme using Pythagorean structure
4. Entropy analysis of Berggren word distributions
"""

import numpy as np
import hashlib
import secrets
import math
from typing import Tuple, List

# Berggren generators
A = np.array([[1, -2, 2], [2, -1, 2], [2, -2, 3]], dtype=np.int64)
B_mat = np.array([[1,  2, 2], [2,  1, 2], [2,  2, 3]], dtype=np.int64)
C = np.array([[-1, 2, 2], [-2, 1, 2], [-2, 2, 3]], dtype=np.int64)
GENS = [A, B_mat, C]
ROOT = np.array([3, 4, 5], dtype=np.int64)


def eval_word(word: List[int]) -> np.ndarray:
    """Evaluate Berggren word (list of 0,1,2) on root triple."""
    v = ROOT.copy()
    for g in reversed(word):
        v = GENS[g] @ v
    return v


# ============================================================
# Application 1: Post-Quantum Key Derivation
# ============================================================

def pq_key_derivation(security_bits: int = 128) -> dict:
    """
    Post-quantum key derivation from Berggren orbit.

    The min-entropy of a uniformly random depth-d Berggren word is
    d·log₂(3) ≈ 1.585·d bits. For security_bits bits of post-quantum
    security (accounting for Grover halving), we need:
        d ≥ 2·security_bits / log₂(3)

    Args:
        security_bits: Target post-quantum security level.

    Returns:
        Dictionary with key derivation parameters and derived key.
    """
    # Compute required depth
    required_depth = math.ceil(2 * security_bits / math.log2(3))

    # Sample random word
    word = [secrets.randbelow(3) for _ in range(required_depth)]

    # Evaluate to get Pythagorean triple
    triple = eval_word(word)

    # Derive key via hash
    key_material = triple.tobytes()
    derived_key = hashlib.sha3_256(key_material).hexdigest()

    return {
        'security_bits': security_bits,
        'depth': required_depth,
        'word_entropy_bits': required_depth * math.log2(3),
        'pq_security_bits': required_depth * math.log2(3) / 2,
        'triple': triple,
        'derived_key': derived_key,
        'triple_is_pythagorean': int(triple[0])**2 + int(triple[1])**2 == int(triple[2])**2,
    }


# ============================================================
# Application 2: Verifiable Random Function (VRF)
# ============================================================

def berggren_vrf(secret_word: List[int], input_data: bytes) -> Tuple[bytes, np.ndarray]:
    """
    Verifiable random function using Berggren orbit.

    The VRF output is Hash(eval(word, root) || input).
    The proof is the Pythagorean triple itself (verifier checks a²+b²=c²).

    Args:
        secret_word: Secret Berggren word.
        input_data: Public input.

    Returns:
        (output_hash, proof_triple)
    """
    triple = eval_word(secret_word)
    # Output = H(triple || input)
    h = hashlib.sha256()
    h.update(triple.tobytes())
    h.update(input_data)
    output = h.digest()
    return output, triple


def verify_vrf(output: bytes, proof_triple: np.ndarray, input_data: bytes) -> bool:
    """Verify a VRF output given the proof triple."""
    a, b, c = proof_triple
    if a**2 + b**2 != c**2:
        return False
    if a <= 0 or b <= 0 or c <= 0:
        return False
    h = hashlib.sha256()
    h.update(proof_triple.tobytes())
    h.update(input_data)
    return h.digest() == output


# ============================================================
# Application 3: Commitment Scheme
# ============================================================

def berggren_commit(message: bytes, depth: int = 20) -> Tuple[bytes, List[int]]:
    """
    Commitment scheme: commit to a message using a random Berggren word.

    Commit(m) = Hash(eval(word, root) || m)
    Opening = word

    Hiding: word is secret, so commitment reveals nothing about m.
    Binding: finding another (word', m') with same hash is hard.

    Args:
        message: Message to commit to.
        depth: Word length (security parameter).

    Returns:
        (commitment, opening)
    """
    word = [secrets.randbelow(3) for _ in range(depth)]
    triple = eval_word(word)
    h = hashlib.sha256()
    h.update(triple.tobytes())
    h.update(message)
    return h.digest(), word


def berggren_verify_commitment(commitment: bytes, message: bytes, opening: List[int]) -> bool:
    """Verify a Berggren commitment."""
    triple = eval_word(opening)
    # Verify Pythagorean property
    a, b, c = triple
    if a**2 + b**2 != c**2:
        return False
    h = hashlib.sha256()
    h.update(triple.tobytes())
    h.update(message)
    return h.digest() == commitment


# ============================================================
# Application 4: Entropy Analysis
# ============================================================

def analyze_entropy(max_depth: int = 12) -> List[dict]:
    """
    Analyze the min-entropy of Berggren word distributions.

    For uniform random words of length d over {A,B,C}:
    - Number of words: 3^d
    - Shannon entropy: d·log₂(3) bits
    - Min-entropy: d·log₂(3) bits (uniform distribution)
    - Post-quantum security: d·log₂(3)/2 bits

    Returns:
        List of analysis results per depth.
    """
    results = []
    for d in range(1, max_depth + 1):
        n_words = 3**d
        shannon = d * math.log2(3)
        min_entropy = shannon  # Uniform distribution
        pq_security = min_entropy / 2
        grover_queries = int(math.sqrt(n_words))

        results.append({
            'depth': d,
            'n_words': n_words,
            'shannon_entropy': shannon,
            'min_entropy': min_entropy,
            'pq_security_bits': pq_security,
            'grover_queries': grover_queries,
        })
    return results


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print("=" * 70)
    print("Application 1: Post-Quantum Key Derivation")
    print("=" * 70)
    print()

    for sec_bits in [64, 128, 256]:
        result = pq_key_derivation(sec_bits)
        print(f"  Target security: {sec_bits} bits")
        print(f"    Depth required: {result['depth']}")
        print(f"    Word entropy: {result['word_entropy_bits']:.1f} bits")
        print(f"    PQ security: {result['pq_security_bits']:.1f} bits")
        print(f"    Triple Pythagorean: {result['triple_is_pythagorean']}")
        print(f"    Derived key: {result['derived_key'][:32]}...")
        print()

    print("=" * 70)
    print("Application 2: Verifiable Random Function")
    print("=" * 70)
    print()

    secret = [secrets.randbelow(3) for _ in range(20)]
    input_msg = b"Hello, Berggren!"
    output, proof = berggren_vrf(secret, input_msg)
    valid = verify_vrf(output, proof, input_msg)
    print(f"  Secret word length: {len(secret)}")
    print(f"  Proof triple: ({proof[0]}, {proof[1]}, {proof[2]})")
    print(f"  Output: {output.hex()[:32]}...")
    print(f"  Verification: {valid}")
    print(f"  Pythagorean check: {proof[0]**2 + proof[1]**2 == proof[2]**2}")
    print()

    # Tamper test
    bad_output = verify_vrf(b'\x00' * 32, proof, input_msg)
    print(f"  Tampered output verification: {bad_output} (should be False)")

    print()
    print("=" * 70)
    print("Application 3: Commitment Scheme")
    print("=" * 70)
    print()

    message = b"I commit to this message"
    commitment, opening = berggren_commit(message, depth=15)
    valid = berggren_verify_commitment(commitment, message, opening)
    print(f"  Message: {message.decode()}")
    print(f"  Commitment: {commitment.hex()[:32]}...")
    print(f"  Opening word length: {len(opening)}")
    print(f"  Verification: {valid}")

    # Binding test
    bad_valid = berggren_verify_commitment(commitment, b"different message", opening)
    print(f"  Different message verification: {bad_valid} (should be False)")

    print()
    print("=" * 70)
    print("Application 4: Entropy Analysis")
    print("=" * 70)
    print()

    results = analyze_entropy()
    print(f"  {'Depth':>6} {'Words':>12} {'H_∞ (bits)':>12} {'PQ Sec':>10} {'Grover Q':>12}")
    print("  " + "-" * 56)
    for r in results:
        print(f"  {r['depth']:>6} {r['n_words']:>12,} {r['min_entropy']:>12.1f} "
              f"{r['pq_security_bits']:>10.1f} {r['grover_queries']:>12,}")
