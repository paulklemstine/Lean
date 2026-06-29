#!/usr/bin/env python3
"""
Algorithms for Berggren Expander Hashing

Implements the core algorithms from the research paper:
1. Berggren hash computation
2. Collision kernel analysis
3. Exceptional set enumeration
4. Orbit connectivity analysis
5. Spectral gap estimation via power iteration
"""

import numpy as np
from typing import List, Tuple, Set, Dict, Optional
from collections import defaultdict
import math

# === Core Definitions ===

# Berggren generator matrices
B_A = np.array([[1, -2, 2], [2, -1, 2], [2, -2, 3]], dtype=np.int64)
B_B = np.array([[1, 2, 2], [2, 1, 2], [2, 2, 3]], dtype=np.int64)
B_C = np.array([[-1, 2, 2], [-2, 1, 2], [-2, 2, 3]], dtype=np.int64)
GENERATORS = [B_A, B_B, B_C]


class BerggrenHash:
    """
    Berggren Expander Hash Family.
    
    Parameterized by a modulus N and a base Pythagorean triple.
    Messages are encoded as sequences of generator indices {0, 1, 2}.
    
    Time complexity: O(L) matrix multiplications mod N for a word of length L.
    Space complexity: O(1) — only need current state vector.
    """
    
    def __init__(self, modulus: int, base: Tuple[int, int, int] = (3, 4, 5)):
        self.N = modulus
        self.base = np.array(base, dtype=np.int64)
        assert (base[0]**2 + base[1]**2 - base[2]**2) % modulus == 0, \
            "Base must satisfy Pythagorean relation mod N"
    
    def hash(self, word: List[int]) -> Tuple[int, int, int]:
        """
        Compute H_N(word) = M_word · base mod N.
        
        Args:
            word: List of generator indices (0=A, 1=B, 2=C)
        Returns:
            Triple (a, b, c) mod N satisfying a²+b²≡c² (mod N)
        """
        v = self.base.copy()
        # Apply generators right-to-left (so word[0] is outermost)
        for g in reversed(word):
            v = GENERATORS[g] @ v
            v = v % self.N
        return tuple(int(x) for x in v)
    
    def verify_pythagorean(self, v: Tuple[int, int, int]) -> bool:
        """Check that output satisfies Pythagorean relation mod N."""
        return (v[0]**2 + v[1]**2 - v[2]**2) % self.N == 0


def word_matrix_mod(word: List[int], N: int) -> np.ndarray:
    """
    Compute the word matrix mod N.
    
    Time: O(L · 3³) = O(27L) arithmetic operations mod N.
    """
    M = np.eye(3, dtype=np.int64)
    for g in word:
        M = (GENERATORS[g] @ M) % N
    return M


def collision_kernel(w1: List[int], w2: List[int], N: int) -> List[Tuple[int, int, int]]:
    """
    Find all vectors v in (Z/NZ)³ where w1·v ≡ w2·v (mod N).
    Equivalently, find ker(D mod N) where D = M_w1 - M_w2.
    
    Time: O(N³) — brute force enumeration.
    For large N, use Smith normal form instead.
    """
    D = (word_matrix_mod(w1, N) - word_matrix_mod(w2, N)) % N
    kernel = []
    for a in range(N):
        for b in range(N):
            for c in range(N):
                v = np.array([a, b, c], dtype=np.int64)
                if all((D @ v) % N == 0):
                    kernel.append((a, b, c))
    return kernel


def exceptional_set(N: int, L: int) -> Set[Tuple[int, int, int]]:
    """
    Compute the exceptional set Exc(N, L): vectors that lie in the 
    collision kernel for at least one pair of distinct word matrices
    of length ≤ L.
    
    Time: O(3^(2L) · N³) — exponential in L, polynomial in N.
    Only practical for small L.
    """
    import itertools
    
    exc = set()
    # Generate all words of length ≤ L
    all_words = []
    for length in range(L + 1):
        for w in itertools.product(range(3), repeat=length):
            all_words.append(list(w))
    
    # For each pair, find collision kernel
    matrices_seen = {}
    for w in all_words:
        M = word_matrix_mod(w, N)
        key = tuple(M.flatten())
        if key not in matrices_seen:
            matrices_seen[key] = w
    
    unique_words = list(matrices_seen.values())
    print(f"  {len(all_words)} words of length ≤ {L}, {len(unique_words)} distinct matrices mod {N}")
    
    for i in range(len(unique_words)):
        for j in range(i + 1, len(unique_words)):
            ker = collision_kernel(unique_words[i], unique_words[j], N)
            exc.update(ker)
    
    return exc


def estimate_spectral_gap(N: int, num_iterations: int = 100) -> float:
    """
    Estimate the spectral gap of the Berggren averaging operator on (Z/NZ)³
    using power iteration on the complement of the constant eigenspace.
    
    The averaging operator M acts on f: (Z/NZ)³ → R by
        (Mf)(x) = (1/3) Σ_{g∈{A,B,C}} f(g·x)
    
    The spectral gap is 1 - λ₂ where λ₂ is the second-largest eigenvalue.
    
    Time per iteration: O(N³) function evaluations.
    """
    size = N ** 3
    
    # Start with a random mean-zero function
    f = np.random.randn(N, N, N)
    f -= f.mean()
    
    ratios = []
    for _ in range(num_iterations):
        norm_before = np.sqrt(np.sum(f**2))
        if norm_before < 1e-15:
            break
        
        # Apply averaging operator
        g = np.zeros_like(f)
        for gen in GENERATORS:
            gen_mod = gen % N
            for a in range(N):
                for b in range(N):
                    for c in range(N):
                        v = np.array([a, b, c], dtype=np.int64)
                        w = (gen_mod @ v) % N
                        g[w[0], w[1], w[2]] += f[a, b, c]
        g /= 3.0
        
        # Project out mean
        g -= g.mean()
        
        norm_after = np.sqrt(np.sum(g**2))
        if norm_before > 0:
            ratios.append(norm_after / norm_before)
        f = g
    
    if ratios:
        lambda2 = np.median(ratios[-20:])  # Use last 20 iterations
        return 1.0 - lambda2
    return 0.0


def orbit_connectivity(p: int) -> Dict:
    """
    Analyze the orbit structure of the Berggren action on the 
    Pythagorean cone mod p.
    
    Returns statistics about orbits, connectivity, and mixing.
    """
    # Find Pythagorean cone
    cone = set()
    for a in range(p):
        for b in range(p):
            c2 = (a*a + b*b) % p
            for c in range(p):
                if (c*c) % p == c2:
                    cone.add((a, b, c))
    
    # BFS to find orbits
    visited = set()
    orbits = []
    
    for start in cone:
        if start in visited:
            continue
        orbit = set()
        frontier = [start]
        while frontier:
            new_frontier = []
            for v in frontier:
                if v in orbit:
                    continue
                orbit.add(v)
                visited.add(v)
                for gen in GENERATORS:
                    w = tuple(int(x) % p for x in gen @ np.array(v))
                    if w in cone and w not in orbit:
                        new_frontier.append(w)
            frontier = new_frontier
        orbits.append(orbit)
    
    return {
        'prime': p,
        'cone_size': len(cone),
        'num_orbits': len(orbits),
        'orbit_sizes': sorted([len(o) for o in orbits], reverse=True),
        'largest_orbit_fraction': max(len(o) for o in orbits) / len(cone) if cone else 0,
    }


# === Run demonstrations ===
if __name__ == '__main__':
    print("=" * 60)
    print("Berggren Hash Algorithm Demonstrations")
    print("=" * 60)
    
    # Test hash
    H = BerggrenHash(modulus=101)
    print(f"\nHash family: N=101, base=(3,4,5)")
    test_words = [[0], [1], [2], [0,1], [1,2], [0,1,2]]
    for w in test_words:
        h = H.hash(w)
        word_str = ''.join('ABC'[g] for g in w)
        pyth = H.verify_pythagorean(h)
        print(f"  H({word_str}) = {h}, Pythagorean: {pyth}")
    
    # Orbit analysis
    print(f"\nOrbit connectivity analysis:")
    for p in [5, 7, 11, 13, 17, 19, 23, 29, 31]:
        stats = orbit_connectivity(p)
        print(f"  p={p:2d}: cone={stats['cone_size']:4d}, "
              f"orbits={stats['num_orbits']}, "
              f"sizes={stats['orbit_sizes'][:3]}, "
              f"coverage={stats['largest_orbit_fraction']:.2f}")
    
    # Exceptional set analysis
    print(f"\nExceptional set analysis (N=7, L=1):")
    exc = exceptional_set(7, 1)
    print(f"  |Exc(7,1)| = {len(exc)} out of {7**3} = 343")
    print(f"  Density: {len(exc)/343:.4f}")
    
    print(f"\nExceptional set analysis (N=11, L=1):")
    exc = exceptional_set(11, 1)
    print(f"  |Exc(11,1)| = {len(exc)} out of {11**3} = 1331")
    print(f"  Density: {len(exc)/1331:.4f}")


#!/usr/bin/env python3
"""
Applications of Berggren Expander Hashing

Demonstrates practical applications of the Pythagorean spectral hash:
1. Message authentication via Berggren hash chains
2. Commitment scheme construction  
3. Pseudorandom number generation from Pythagorean walks
4. Merkle-tree style parallel hashing
"""

import numpy as np
from typing import List, Tuple
import hashlib

# Berggren generators
B_A = np.array([[1, -2, 2], [2, -1, 2], [2, -2, 3]], dtype=np.int64)
B_B = np.array([[1, 2, 2], [2, 1, 2], [2, 2, 3]], dtype=np.int64)
B_C = np.array([[-1, 2, 2], [-2, 1, 2], [-2, 2, 3]], dtype=np.int64)
GENERATORS = [B_A, B_B, B_C]


def encode_message(msg: bytes) -> List[int]:
    """Encode a byte string as a Berggren word (base-3 encoding)."""
    word = []
    for byte in msg:
        # Each byte → ~5.05 trits
        val = byte
        for _ in range(6):  # 6 trits per byte (3^6 = 729 > 256)
            word.append(val % 3)
            val //= 3
    return word


def berggren_hash(word: List[int], N: int, base: np.ndarray = None) -> Tuple[int, ...]:
    """Compute Berggren hash of a word mod N."""
    if base is None:
        base = np.array([3, 4, 5], dtype=np.int64)
    v = base.copy()
    for g in reversed(word):
        v = (GENERATORS[g] @ v) % N
    return tuple(int(x) for x in v)


# === Application 1: Message Authentication ===
print("=" * 60)
print("APPLICATION 1: Message Authentication via Berggren Hash")
print("=" * 60)

N = 10007  # large prime modulus
messages = [
    b"Hello, World!",
    b"Hello, World?",  # one character different
    b"Transfer $1000",
    b"Transfer $1001",
]

print(f"\nModulus: N = {N}")
for msg in messages:
    word = encode_message(msg)
    h = berggren_hash(word, N)
    # Verify Pythagorean
    pyth = (h[0]**2 + h[1]**2 - h[2]**2) % N
    print(f"  H(\"{msg.decode()}\") = {h}  [a²+b²-c² ≡ {pyth} mod N]")

print("\nAvalanche demonstration (one-bit changes):")
msg1 = b"Test message 1"
msg2 = b"Test message 2"
w1 = encode_message(msg1)
w2 = encode_message(msg2)
h1 = berggren_hash(w1, N)
h2 = berggren_hash(w2, N)
diff = tuple((a - b) % N for a, b in zip(h1, h2))
print(f"  H(\"{msg1.decode()}\") = {h1}")
print(f"  H(\"{msg2.decode()}\") = {h2}")
print(f"  Difference mod N: {diff}")
print(f"  All components changed: {all(d != 0 for d in diff)}")


# === Application 2: Commitment Scheme ===
print("\n" + "=" * 60)
print("APPLICATION 2: Pythagorean Commitment Scheme")
print("=" * 60)

def commit(message: bytes, randomness: bytes, N: int) -> Tuple[int, ...]:
    """Commit to a message using Berggren hash with randomness."""
    r_word = encode_message(randomness)
    m_word = encode_message(message)
    combined = r_word + m_word
    return berggren_hash(combined, N)

def verify_commitment(commitment: Tuple[int, ...], message: bytes,
                      randomness: bytes, N: int) -> bool:
    """Verify a commitment opening."""
    recomputed = commit(message, randomness, N)
    return commitment == recomputed

# Demo
import os
message = b"I bid $500"
randomness = os.urandom(16)
N = 10007

c = commit(message, randomness, N)
print(f"\nMessage: \"{message.decode()}\"")
print(f"Randomness: {randomness.hex()[:32]}...")
print(f"Commitment: {c}")
print(f"Pythagorean: {(c[0]**2 + c[1]**2 - c[2]**2) % N == 0}")

# Verify
print(f"\nVerification with correct opening: {verify_commitment(c, message, randomness, N)}")
print(f"Verification with wrong message:   {verify_commitment(c, b'I bid $501', randomness, N)}")
print(f"Verification with wrong randomness: {verify_commitment(c, message, os.urandom(16), N)}")


# === Application 3: Pseudorandom Generation ===
print("\n" + "=" * 60)
print("APPLICATION 3: Pythagorean Pseudorandom Number Generator")
print("=" * 60)

class PythagoreanPRNG:
    """
    Pseudorandom number generator based on Berggren random walks.
    
    The state is a vector on the Pythagorean cone mod N.
    Each step applies a Berggren generator (chosen from a seed stream)
    and outputs the state.
    """
    
    def __init__(self, N: int, seed: bytes):
        self.N = N
        self.state = np.array([3, 4, 5], dtype=np.int64)
        self.seed_stream = self._expand_seed(seed)
        self.index = 0
    
    def _expand_seed(self, seed: bytes) -> List[int]:
        """Expand seed into a long generator sequence."""
        expanded = []
        counter = 0
        while len(expanded) < 10000:
            h = hashlib.sha256(seed + counter.to_bytes(4, 'big')).digest()
            for byte in h:
                expanded.append(byte % 3)
            counter += 1
        return expanded
    
    def next(self) -> Tuple[int, int, int]:
        """Generate next pseudorandom Pythagorean triple mod N."""
        g = self.seed_stream[self.index % len(self.seed_stream)]
        self.index += 1
        self.state = (GENERATORS[g] @ self.state) % self.N
        return tuple(int(x) for x in self.state)
    
    def next_int(self, bound: int) -> int:
        """Generate a pseudorandom integer in [0, bound)."""
        t = self.next()
        return (t[0] * 1000003 + t[1] * 1009 + t[2]) % bound

# Demo
prng = PythagoreanPRNG(N=10007, seed=b"demo seed 12345")
print(f"\nFirst 10 pseudorandom Pythagorean triples mod 10007:")
for i in range(10):
    t = prng.next()
    pyth = (t[0]**2 + t[1]**2 - t[2]**2) % 10007
    print(f"  Step {i+1}: {t}  [Pyth residue: {pyth}]")

# Statistical test
print(f"\nDistribution test (1000 samples, N=101):")
prng2 = PythagoreanPRNG(N=101, seed=b"test seed")
counts = {}
for _ in range(1000):
    t = prng2.next()
    counts[t] = counts.get(t, 0) + 1

print(f"  Distinct values visited: {len(counts)}")
print(f"  Most common (count): {max(counts.values())}")
print(f"  Least common (count): {min(counts.values())}")
print(f"  Expected uniform count: {1000/len(counts):.1f}")


# === Application 4: Merkle-Tree Hashing ===
print("\n" + "=" * 60)
print("APPLICATION 4: Merkle-Tree Parallel Hashing")
print("=" * 60)

def merkle_berggren_hash(blocks: List[bytes], N: int) -> Tuple[int, ...]:
    """
    Compute a Merkle-tree style hash using Berggren action.
    
    Each block is hashed individually, then pairs are combined
    by treating the hash output as a new base point for the next level.
    """
    # Leaf hashes
    leaves = []
    for block in blocks:
        word = encode_message(block)
        h = berggren_hash(word, N)
        leaves.append(h)
    
    # Combine pairs up the tree
    level = leaves
    while len(level) > 1:
        next_level = []
        for i in range(0, len(level), 2):
            if i + 1 < len(level):
                # Combine: use first hash as base, second as word
                base = np.array(level[i], dtype=np.int64)
                word = list(level[i+1])  # use hash values as generator indices
                word = [x % 3 for x in word]  # reduce to valid generators
                combined = berggren_hash(word, N, base)
                next_level.append(combined)
            else:
                next_level.append(level[i])
        level = next_level
    
    return level[0] if level else (0, 0, 0)

# Demo
blocks = [f"Block {i}".encode() for i in range(8)]
N = 10007
root = merkle_berggren_hash(blocks, N)
print(f"\nMerkle root of {len(blocks)} blocks: {root}")
print(f"Pythagorean: {(root[0]**2 + root[1]**2 - root[2]**2) % N == 0}")

# Tamper detection
blocks_tampered = blocks.copy()
blocks_tampered[3] = b"Block 3 TAMPERED"
root_tampered = merkle_berggren_hash(blocks_tampered, N)
print(f"Tampered root: {root_tampered}")
print(f"Roots differ: {root != root_tampered}")

print("\n✓ All applications demonstrated successfully.")


#!/usr/bin/env python3
"""
Berggren Expander Hash: Demonstrations and Numerical Examples

This module demonstrates the core constructions of Pythagorean spectral cryptography:
1. Berggren matrix action on primitive Pythagorean triples
2. Modular reduction and hash computation
3. Collision kernel analysis
4. Orbit visualization on the Pythagorean cone mod p
"""

import numpy as np
from typing import List, Tuple

# === Berggren Generators ===

B_A = np.array([[1, -2, 2], [2, -1, 2], [2, -2, 3]], dtype=int)
B_B = np.array([[1, 2, 2], [2, 1, 2], [2, 2, 3]], dtype=int)
B_C = np.array([[-1, 2, 2], [-2, 1, 2], [-2, 2, 3]], dtype=int)

GENERATORS = [B_A, B_B, B_C]
GEN_NAMES = ['A', 'B', 'C']


def word_matrix(word: List[int]) -> np.ndarray:
    """Compute the matrix product for a Berggren word."""
    M = np.eye(3, dtype=int)
    for g in word:
        M = GENERATORS[g] @ M
    return M


def is_pythagorean(v: np.ndarray) -> bool:
    """Check if v = (a, b, c) satisfies a² + b² = c²."""
    return int(v[0])**2 + int(v[1])**2 == int(v[2])**2


def hash_berggren(word: List[int], base: np.ndarray, N: int) -> np.ndarray:
    """Compute the Berggren hash: reduce word_matrix(word) @ base mod N."""
    M = word_matrix(word)
    return (M @ base) % N


# === Demo 1: Berggren Tree Generation ===
print("=" * 60)
print("DEMO 1: Berggren Tree — Generating Primitive Pythagorean Triples")
print("=" * 60)

base = np.array([3, 4, 5])
print(f"\nRoot triple: {tuple(base)}")
print(f"Pythagorean check: {base[0]}² + {base[1]}² = {base[0]**2} + {base[1]**2} = {base[2]**2} = {base[2]}² ✓")

print("\nLevel 1 children:")
for i, (gen, name) in enumerate(zip(GENERATORS, GEN_NAMES)):
    child = gen @ base
    print(f"  {name}·(3,4,5) = {tuple(child)}")
    print(f"    Check: {child[0]}² + {child[1]}² = {child[0]**2 + child[1]**2} = {child[2]**2} = {child[2]}² ✓")

print("\nLevel 2 children (from A·(3,4,5) = (5,12,13)):")
v = GENERATORS[0] @ base
for i, (gen, name) in enumerate(zip(GENERATORS, GEN_NAMES)):
    child = gen @ v
    print(f"  {name}·(5,12,13) = {tuple(child)}, Pythag: {is_pythagorean(child)}")

# === Demo 2: Determinant Structure ===
print("\n" + "=" * 60)
print("DEMO 2: Determinant Structure")
print("=" * 60)

for name, gen in zip(GEN_NAMES, GENERATORS):
    d = int(np.linalg.det(gen).round())
    print(f"det({name}) = {d}")

print("\nWord matrix determinants (all ±1):")
for length in range(1, 5):
    # Generate a few random words
    import itertools
    words = list(itertools.product(range(3), repeat=length))[:5]
    for w in words:
        M = word_matrix(list(w))
        d = int(np.linalg.det(M).round())
        word_str = ''.join(GEN_NAMES[g] for g in w)
        print(f"  det(M_{word_str}) = {d:+d}")

# === Demo 3: Hash Computation ===
print("\n" + "=" * 60)
print("DEMO 3: Berggren Hash Computation (mod N)")
print("=" * 60)

N = 101  # prime modulus
print(f"\nModulus N = {N} (prime)")
print(f"Base triple: (3, 4, 5)")
print(f"Base mod {N}: ({3 % N}, {4 % N}, {5 % N})")

words = [[0], [1], [2], [0, 1], [0, 2], [1, 0], [2, 1, 0]]
for w in words:
    h = hash_berggren(w, base, N)
    word_str = ''.join(GEN_NAMES[g] for g in w)
    # Check Pythagorean mod N
    pyth_check = (h[0]**2 + h[1]**2 - h[2]**2) % N
    print(f"  H_{N}({word_str}) = {tuple(h)}  (a²+b²-c² ≡ {pyth_check} mod {N})")

# === Demo 4: Collision Analysis ===
print("\n" + "=" * 60)
print("DEMO 4: Collision Kernel Analysis")
print("=" * 60)

w1 = [0]  # word A
w2 = [1]  # word B
M1 = word_matrix(w1)
M2 = word_matrix(w2)
D = M1 - M2
print(f"\nDifference matrix D = M_A - M_B:")
print(D)
print(f"\nD mod {N}:")
D_mod = D % N
print(D_mod)

# Find kernel of D mod N
print(f"\nKernel of D mod {N} (vectors v with D·v ≡ 0 mod {N}):")
kernel_count = 0
for a in range(N):
    for b in range(N):
        for c in range(N):
            v = np.array([a, b, c])
            if all((D_mod @ v) % N == 0):
                kernel_count += 1
                if kernel_count <= 5:
                    print(f"  v = ({a}, {b}, {c})")
if kernel_count > 5:
    print(f"  ... ({kernel_count} total kernel vectors)")
print(f"\nKernel size: {kernel_count} out of {N**3} = {N}³ vectors")
print(f"Kernel fraction: {kernel_count}/{N**3} ≈ {kernel_count/N**3:.6f}")
print(f"Expected (≈ 1/N = 1/{N}): {1/N:.6f}")

# === Demo 5: Orbit Size Analysis ===
print("\n" + "=" * 60)
print("DEMO 5: Orbit Analysis on Pythagorean Cone mod p")
print("=" * 60)

def pythagorean_cone_mod(p: int) -> List[Tuple[int, int, int]]:
    """Find all triples (a,b,c) in F_p³ with a²+b²=c²."""
    triples = []
    for a in range(p):
        for b in range(p):
            c2 = (a*a + b*b) % p
            for c in range(p):
                if (c*c) % p == c2:
                    triples.append((a, b, c))
    return triples

def orbit_from(start: np.ndarray, p: int, max_steps: int = 1000) -> set:
    """Compute the forward orbit of start under Berggren generators mod p."""
    orbit = {tuple(start % p)}
    frontier = [start % p]
    while frontier and len(orbit) < max_steps:
        new_frontier = []
        for v in frontier:
            for gen in GENERATORS:
                w = (gen @ np.array(v)) % p
                t = tuple(w)
                if t not in orbit:
                    orbit.add(t)
                    new_frontier.append(w)
        frontier = new_frontier
    return orbit

for p in [5, 7, 11, 13, 17, 19, 23]:
    cone = pythagorean_cone_mod(p)
    orbit = orbit_from(np.array([3, 4, 5]), p)
    pyth_orbit = {v for v in orbit if (v[0]**2 + v[1]**2 - v[2]**2) % p == 0}
    print(f"  p={p:2d}: |Cone| = {len(cone):4d}, |Orbit| = {len(orbit):4d}, "
          f"|Pyth∩Orbit| = {len(pyth_orbit):4d}, ratio = {len(pyth_orbit)/len(cone):.2f}")

print("\n✓ All demonstrations completed successfully.")


#!/usr/bin/env python3
"""
Visualizations for Berggren Expander Hashing

Generates publication-quality figures showing:
1. Berggren tree structure
2. Orbit on Pythagorean cone mod p  
3. Collision kernel density
4. Spectral gap estimates
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D
import base64
import io

# Berggren generators
B_A = np.array([[1, -2, 2], [2, -1, 2], [2, -2, 3]], dtype=np.int64)
B_B = np.array([[1, 2, 2], [2, 1, 2], [2, 2, 3]], dtype=np.int64)
B_C = np.array([[-1, 2, 2], [-2, 1, 2], [-2, 2, 3]], dtype=np.int64)
GENERATORS = [B_A, B_B, B_C]
GEN_NAMES = ['A', 'B', 'C']
GEN_COLORS = ['#e74c3c', '#3498db', '#2ecc71']

def save_fig_base64(fig) -> str:
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    return "data:image/png;base64," + base64.b64encode(buf.read()).decode()


# === Figure 1: Berggren Tree ===
def plot_berggren_tree():
    fig, ax = plt.subplots(1, 1, figsize=(14, 8))
    
    base = np.array([3, 4, 5])
    
    # Generate tree up to depth 3
    nodes = [(base, 0, 0, None)]  # (triple, depth, position, parent_pos)
    positions = {}
    
    depth_counts = {0: 1, 1: 3, 2: 9, 3: 27}
    
    queue = [(base, 0, 0.5)]
    positions[(3, 4, 5)] = (0.5, 0)
    all_edges = []
    all_nodes = []
    
    all_nodes.append((0.5, 0, base, -1))
    
    for depth in range(3):
        next_queue = []
        for v, d, x in queue:
            parent_pos = (x, -depth)
            for i, (gen, name) in enumerate(zip(GENERATORS, GEN_NAMES)):
                child = gen @ v
                child_x = x + (i - 1) * (0.4 / (3 ** depth))
                child_y = -(depth + 1)
                all_nodes.append((child_x, child_y, child, i))
                all_edges.append((parent_pos, (child_x, child_y), i))
                next_queue.append((child, depth + 1, child_x))
        queue = next_queue
    
    # Draw edges
    for (x1, y1), (x2, y2), gen_idx in all_edges:
        ax.plot([x1, x2], [y1, y2], color=GEN_COLORS[gen_idx], 
                linewidth=1.5, alpha=0.6, zorder=1)
    
    # Draw nodes
    for x, y, triple, gen_idx in all_nodes:
        color = '#333333' if gen_idx == -1 else GEN_COLORS[gen_idx]
        ax.scatter(x, y, s=80, c=color, zorder=3, edgecolors='white', linewidth=0.5)
        label = f"({triple[0]},{triple[1]},{triple[2]})"
        if y > -2:
            ax.annotate(label, (x, y), textcoords="offset points",
                       xytext=(0, 12), ha='center', fontsize=7, fontweight='bold')
    
    ax.set_xlim(-0.1, 1.1)
    ax.set_ylim(-3.5, 0.5)
    ax.set_title('Berggren Tree of Primitive Pythagorean Triples', fontsize=14, fontweight='bold')
    ax.axis('off')
    
    # Legend
    for i, (name, color) in enumerate(zip(GEN_NAMES, GEN_COLORS)):
        ax.scatter([], [], c=color, label=f'Generator {name}', s=60)
    ax.legend(loc='lower right', fontsize=10)
    
    return fig


# === Figure 2: Pythagorean Cone mod p ===
def plot_pythagorean_cone(p=23):
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    
    # Find Pythagorean cone
    cone = []
    for a in range(p):
        for b in range(p):
            c2 = (a*a + b*b) % p
            for c in range(p):
                if (c*c) % p == c2:
                    cone.append((a, b, c))
    
    # Find orbit from (3,4,5)
    orbit = {(3 % p, 4 % p, 5 % p)}
    frontier = [(3 % p, 4 % p, 5 % p)]
    while frontier:
        new_frontier = []
        for v in frontier:
            for gen in GENERATORS:
                w = tuple(int(x) % p for x in gen @ np.array(v))
                if w not in orbit:
                    orbit.add(w)
                    new_frontier.append(w)
        frontier = new_frontier
    
    # Plot cone
    ax = axes[0]
    cone_arr = np.array(cone)
    orbit_arr = np.array(list(orbit))
    non_orbit = np.array([v for v in cone if tuple(v) not in orbit])
    
    if len(non_orbit) > 0:
        ax.scatter(non_orbit[:, 0], non_orbit[:, 1], c='#cccccc', s=20, alpha=0.5, label='Cone (not in orbit)')
    ax.scatter(orbit_arr[:, 0], orbit_arr[:, 1], c='#e74c3c', s=30, alpha=0.8, label='Berggren orbit')
    ax.set_xlabel('a (mod p)')
    ax.set_ylabel('b (mod p)')
    ax.set_title(f'Pythagorean Cone mod {p}\n|Cone|={len(cone)}, |Orbit|={len(orbit)}', fontsize=12)
    ax.legend(fontsize=9)
    ax.set_aspect('equal')
    
    # Plot orbit coverage vs prime
    ax = axes[1]
    primes = [5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47]
    coverages = []
    cone_sizes = []
    
    for pp in primes:
        cone_p = set()
        for a in range(pp):
            for b in range(pp):
                c2 = (a*a + b*b) % pp
                for c in range(pp):
                    if (c*c) % pp == c2:
                        cone_p.add((a, b, c))
        
        orbit_p = {(3 % pp, 4 % pp, 5 % pp)}
        front = [(3 % pp, 4 % pp, 5 % pp)]
        while front:
            nf = []
            for v in front:
                for gen in GENERATORS:
                    w = tuple(int(x) % pp for x in gen @ np.array(v))
                    if w not in orbit_p:
                        orbit_p.add(w)
                        nf.append(w)
            front = nf
        
        coverages.append(len(orbit_p) / len(cone_p) if cone_p else 0)
        cone_sizes.append(len(cone_p))
    
    ax.bar(range(len(primes)), coverages, color='#3498db', alpha=0.8)
    ax.set_xticks(range(len(primes)))
    ax.set_xticklabels([str(p) for p in primes], rotation=45)
    ax.set_ylabel('Orbit / Cone ratio')
    ax.set_xlabel('Prime p')
    ax.set_title('Orbit Coverage of Pythagorean Cone', fontsize=12)
    ax.set_ylim(0, 1.1)
    ax.axhline(y=1.0, color='red', linestyle='--', alpha=0.5, label='Full coverage')
    ax.legend(fontsize=9)
    
    plt.tight_layout()
    return fig


# === Figure 3: Collision Kernel Density ===
def plot_collision_density():
    fig, ax = plt.subplots(1, 1, figsize=(10, 6))
    
    primes = [5, 7, 11, 13, 17, 19, 23, 29, 31]
    
    # For each prime, compute kernel size for A vs B
    kernel_fracs = []
    theoretical = []
    
    for p in primes:
        D = (B_A - B_B) % p
        ker_count = 0
        for a in range(p):
            for b in range(p):
                for c in range(p):
                    v = np.array([a, b, c], dtype=np.int64)
                    if all((D @ v) % p == 0):
                        ker_count += 1
        kernel_fracs.append(ker_count / p**3)
        theoretical.append(1.0 / p)
    
    ax.semilogy(primes, kernel_fracs, 'o-', color='#e74c3c', linewidth=2, 
                markersize=8, label='Measured |ker(D)|/p³')
    ax.semilogy(primes, theoretical, 's--', color='#3498db', linewidth=2,
                markersize=6, label='Theoretical 1/p')
    ax.semilogy(primes, [1/p**2 for p in primes], '^:', color='#2ecc71', linewidth=1.5,
                markersize=5, label='Lower bound 1/p²')
    
    ax.set_xlabel('Prime p', fontsize=12)
    ax.set_ylabel('Collision kernel fraction', fontsize=12)
    ax.set_title('Collision Kernel Density: |ker(M_A - M_B) mod p| / p³', fontsize=13)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    
    return fig


# === Figure 4: Hash Avalanche ===
def plot_avalanche():
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    
    N = 101
    base = np.array([3, 4, 5], dtype=np.int64)
    
    # Compute hashes for many random words
    np.random.seed(42)
    L = 10
    num_samples = 500
    
    # Original words and single-generator-flipped words
    diffs = []
    for _ in range(num_samples):
        word = list(np.random.randint(0, 3, size=L))
        h1 = base.copy()
        for g in reversed(word):
            h1 = (GENERATORS[g] @ h1) % N
        
        # Flip one position
        pos = np.random.randint(L)
        word2 = word.copy()
        word2[pos] = (word[pos] + 1) % 3
        h2 = base.copy()
        for g in reversed(word2):
            h2 = (GENERATORS[g] @ h2) % N
        
        diff = tuple((int(a) - int(b)) % N for a, b in zip(h1, h2))
        diffs.append(diff)
    
    # Plot component differences
    ax = axes[0]
    comp0 = [d[0] for d in diffs]
    comp1 = [d[1] for d in diffs]
    comp2 = [d[2] for d in diffs]
    
    ax.hist(comp0, bins=N, range=(0, N), alpha=0.5, color='#e74c3c', label='Δa')
    ax.hist(comp1, bins=N, range=(0, N), alpha=0.5, color='#3498db', label='Δb')
    ax.hist(comp2, bins=N, range=(0, N), alpha=0.5, color='#2ecc71', label='Δc')
    ax.set_xlabel('Difference value mod N', fontsize=11)
    ax.set_ylabel('Frequency', fontsize=11)
    ax.set_title(f'Avalanche Effect: Component Differences (N={N}, L={L})', fontsize=12)
    ax.legend()
    
    # Non-collision rate
    ax = axes[1]
    lengths = range(1, 16)
    non_collision_rates = []
    for L in lengths:
        collisions = 0
        trials = 200
        for _ in range(trials):
            word = list(np.random.randint(0, 3, size=L))
            pos = np.random.randint(L)
            word2 = word.copy()
            word2[pos] = (word[pos] + 1) % 3
            
            h1 = base.copy()
            for g in reversed(word):
                h1 = (GENERATORS[g] @ h1) % N
            h2 = base.copy()
            for g in reversed(word2):
                h2 = (GENERATORS[g] @ h2) % N
            
            if tuple(h1) == tuple(h2):
                collisions += 1
        non_collision_rates.append(1.0 - collisions / trials)
    
    ax.plot(list(lengths), non_collision_rates, 'o-', color='#e74c3c', linewidth=2, markersize=6)
    ax.axhline(y=1.0, color='green', linestyle='--', alpha=0.5)
    ax.set_xlabel('Word length L', fontsize=11)
    ax.set_ylabel('Non-collision rate', fontsize=11)
    ax.set_title(f'Avalanche: P(H(w₁) ≠ H(w₂)) for single-flip pairs (N={N})', fontsize=12)
    ax.set_ylim(0.8, 1.02)
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    return fig


# Generate all figures
if __name__ == '__main__':
    print("Generating visualizations...")
    
    fig1 = plot_berggren_tree()
    fig1.savefig('berggren_tree.png', dpi=150, bbox_inches='tight')
    print("  Saved berggren_tree.png")
    
    fig2 = plot_pythagorean_cone()
    fig2.savefig('pythagorean_cone.png', dpi=150, bbox_inches='tight')
    print("  Saved pythagorean_cone.png")
    
    fig3 = plot_collision_density()
    fig3.savefig('collision_density.png', dpi=150, bbox_inches='tight')
    print("  Saved collision_density.png")
    
    fig4 = plot_avalanche()
    fig4.savefig('avalanche_effect.png', dpi=150, bbox_inches='tight')
    print("  Saved avalanche_effect.png")
    
    print("\n✓ All visualizations generated.")
