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


#!/usr/bin/env python3
"""
Berggren Pythagorean Lattices: Demonstrations

Concrete numerical demonstrations of the formally verified theorems:
1. Berggren orbit generation and primitive triple verification
2. Lattice norm bounds
3. Security parameter computation
"""

import numpy as np
from typing import List, Tuple

# Berggren generator matrices
A = np.array([[1, -2, 2], [2, -1, 2], [2, -2, 3]], dtype=np.int64)
B = np.array([[1,  2, 2], [2,  1, 2], [2,  2, 3]], dtype=np.int64)
C = np.array([[-1, 2, 2], [-2, 1, 2], [-2, 2, 3]], dtype=np.int64)

GENERATORS = [A, B, C]
GEN_NAMES = ['A', 'B', 'C']

ROOT = np.array([3, 4, 5], dtype=np.int64)

# --- Utility Functions ---

def gcd(a: int, b: int) -> int:
    """Compute GCD of two integers."""
    a, b = abs(a), abs(b)
    while b:
        a, b = b, a % b
    return a

def is_pythagorean(v: np.ndarray) -> bool:
    """Check if v is a Pythagorean triple with positive entries."""
    return (v[0] > 0 and v[1] > 0 and v[2] > 0 and
            v[0]**2 + v[1]**2 == v[2]**2)

def is_primitive(v: np.ndarray) -> bool:
    """Check if v is a primitive Pythagorean triple."""
    return is_pythagorean(v) and gcd(v[0], gcd(v[1], v[2])) == 1

def sq_norm(v: np.ndarray) -> int:
    """Squared Euclidean norm."""
    return int(np.sum(v**2))

# --- Demo 1: Berggren Orbit Generation ---

def generate_orbit(depth: int) -> List[Tuple[str, np.ndarray]]:
    """Generate all triples in the Berggren tree up to given depth."""
    results = [("", ROOT)]
    frontier = [("", ROOT)]
    for d in range(depth):
        new_frontier = []
        for word, v in frontier:
            for i, (M, name) in enumerate(zip(GENERATORS, GEN_NAMES)):
                new_word = word + name
                new_v = M @ v
                results.append((new_word, new_v))
                new_frontier.append((new_word, new_v))
        frontier = new_frontier
    return results

print("=" * 70)
print("DEMO 1: Berggren Orbit — First 3 Levels of the Ternary Tree")
print("=" * 70)
print()

orbit = generate_orbit(2)
print(f"{'Word':<8} {'Triple':<20} {'Pyth?':>6} {'Prim?':>6} {'sqNorm':>8} {'c²':>8}")
print("-" * 60)
for word, v in orbit:
    w = word if word else "(root)"
    triple = f"({v[0]}, {v[1]}, {v[2]})"
    pyth = "✓" if is_pythagorean(v) else "✗"
    prim = "✓" if is_primitive(v) else "✗"
    sn = sq_norm(v)
    csq = int(v[2]**2)
    print(f"{w:<8} {triple:<20} {pyth:>6} {prim:>6} {sn:>8} {csq:>8}")

print()
print(f"Total triples generated (depth ≤ 2): {len(orbit)}")
print(f"All are Pythagorean: {all(is_pythagorean(v) for _, v in orbit)}")
print(f"All are primitive:   {all(is_primitive(v) for _, v in orbit)}")

# --- Demo 2: Norm Lower Bounds ---

print()
print("=" * 70)
print("DEMO 2: Norm Bounds — sqNorm = 2c² for Pythagorean Triples")
print("=" * 70)
print()

deep_orbit = generate_orbit(4)
norms = [(word, v, sq_norm(v)) for word, v in deep_orbit]
norms.sort(key=lambda x: x[2])

print("Smallest 10 triples by squared norm:")
print(f"{'Word':<12} {'Triple':<25} {'sqNorm':>8} {'2c²':>8} {'Match?':>7}")
print("-" * 65)
for word, v, sn in norms[:10]:
    w = word if word else "(root)"
    triple = f"({v[0]}, {v[1]}, {v[2]})"
    two_csq = 2 * int(v[2]**2)
    match = "✓" if sn == two_csq else "✗"
    print(f"{w:<12} {triple:<25} {sn:>8} {two_csq:>8} {match:>7}")

print()
print(f"Theorem verified: sqNorm = 2c² for all {len(deep_orbit)} triples: "
      f"{all(sq_norm(v) == 2*int(v[2]**2) for _, v in deep_orbit)}")
print(f"All sqNorm ≥ 1: {all(sq_norm(v) >= 1 for _, v in deep_orbit)}")
print(f"All sqNorm ≥ 50 (= 2·5²): {all(sq_norm(v) >= 50 for _, v in deep_orbit)}")

# --- Demo 3: Security Parameters ---

print()
print("=" * 70)
print("DEMO 3: Post-Quantum Security Parameters")
print("=" * 70)
print()

print(f"{'Depth d':>8} {'Words (3^d)':>14} {'MinEntropy':>12} {'PQ Sec Bits':>12}")
print("-" * 50)
for d in range(1, 21):
    words = 3**d
    min_ent = d  # log₂(3^d) ≈ d·1.585, lower bounded by d
    pq_bits = d // 2
    print(f"{d:>8} {words:>14,} {min_ent:>12} {pq_bits:>12}")

# --- Demo 4: Quadratic Form Preservation ---

print()
print("=" * 70)
print("DEMO 4: Quadratic Form Q(v) = a² + b² - c² Preservation")
print("=" * 70)
print()

print("Verifying Q(Mv) = Q(v) for all generators and first-level triples:")
for name, M in zip(GEN_NAMES, GENERATORS):
    qv = int(ROOT[0]**2 + ROOT[1]**2 - ROOT[2]**2)
    mv = M @ ROOT
    qmv = int(mv[0]**2 + mv[1]**2 - mv[2]**2)
    print(f"  Generator {name}: Q(root) = {qv}, Q({name}·root) = {qmv}  {'✓' if qv == qmv else '✗'}")

print()
print("Verifying for all depth-4 orbit vectors:")
all_preserved = True
for word, v in deep_orbit:
    qv = int(v[0]**2 + v[1]**2 - v[2]**2)
    if qv != 0:
        all_preserved = False
        print(f"  FAILED: word={word}, Q(v) = {qv}")
print(f"  All {len(deep_orbit)} vectors on null cone Q(v)=0: {all_preserved}")

# --- Demo 5: Generator Invertibility ---

print()
print("=" * 70)
print("DEMO 5: Generator Invertibility (det = ±1)")
print("=" * 70)
print()

A_inv = np.array([[1, 2, -2], [-2, -1, 2], [-2, -2, 3]], dtype=np.int64)
B_inv = np.array([[1, 2, -2], [2, 1, -2], [-2, -2, 3]], dtype=np.int64)
C_inv = np.array([[-1, -2, 2], [2, 1, -2], [-2, -2, 3]], dtype=np.int64)

INVERSES = [A_inv, B_inv, C_inv]

for name, M, Minv in zip(GEN_NAMES, GENERATORS, INVERSES):
    det_M = int(np.round(np.linalg.det(M)))
    product = M @ Minv
    is_id = np.array_equal(product, np.eye(3, dtype=np.int64))
    print(f"  Generator {name}: det = {det_M:+d}, M·M⁻¹ = I: {is_id}")

print()
print("This integer invertibility is the key to coprimality preservation!")
print("If d | (Mv)ᵢ for all i, then d | (M⁻¹Mv)ᵢ = vᵢ for all i.")

# --- Demo 6: Tree Growth ---

print()
print("=" * 70)
print("DEMO 6: Exponential Growth of the Berggren Tree")
print("=" * 70)
print()

import math

print(f"{'Depth':>6} {'Nodes':>12} {'log₂(Nodes)':>12} {'Grover Queries':>16}")
print("-" * 50)
for d in range(1, 16):
    nodes = 3**d
    log_nodes = d * math.log2(3)
    grover = int(3**(d/2))
    print(f"{d:>6} {nodes:>12,} {log_nodes:>12.2f} {grover:>16,}")

print()
print("The Berggren tree generates exponentially many distinct primitive triples.")
print("A quantum adversary needs Ω(√N) = Ω(3^(d/2)) queries by Grover's bound.")

if __name__ == "__main__":
    print("\n\nAll demonstrations completed successfully.")
