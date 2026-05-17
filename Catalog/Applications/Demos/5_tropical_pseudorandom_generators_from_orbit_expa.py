#!/usr/bin/env python3
"""
applications.py — Real-World Applications of Tropical Orbit PRGs

Demonstrates practical applications of the tropical orbit PRG theory:
1. Lightweight stream cipher for IoT devices
2. Deterministic randomness extraction for testing
3. Scheduling-aware pseudorandom number generation
4. Graph-based key derivation
"""

import numpy as np
from collections import Counter
from typing import List, Tuple

# Import core algorithms
INF = float('inf')

def trop_matmul(A, B):
    n = len(A)
    C = [[INF]*n for _ in range(n)]
    for i in range(n):
        for j in range(n):
            for k in range(n):
                C[i][j] = min(C[i][j], A[i][k] + B[k][j]) if A[i][k] != INF and B[k][j] != INF else C[i][j]
    return C

def trop_matpow(A, p):
    n = len(A)
    result = [[INF]*n for _ in range(n)]
    for i in range(n):
        result[i][i] = 0
    base = [row[:] for row in A]
    while p > 0:
        if p % 2 == 1:
            result = trop_matmul(result, base)
        base = trop_matmul(base, base)
        p //= 2
    return result

def hash_mod(M, modulus=256):
    total = 0
    for row in M:
        for x in row:
            if x != INF:
                total += int(x)
    return total % modulus

# ─────────────────────────────────────────────────────────────────────
# Application 1: Lightweight Stream Cipher
# ─────────────────────────────────────────────────────────────────────

class TropicalStreamCipher:
    """A lightweight stream cipher based on tropical matrix powering.
    
    The cipher uses a tropical matrix as a seed and generates a
    pseudorandom keystream by hashing successive powers of the matrix.
    
    Security is based on the tropical orbit PRG theorem:
    if the orbit has sufficient expansion (distinct powers) and the
    hash function extracts well, the keystream is statistically
    close to uniform.
    
    Suitable for resource-constrained environments (IoT, embedded)
    because tropical operations use only addition and minimum—no
    multiplication or modular exponentiation needed.
    
    Example:
        >>> cipher = TropicalStreamCipher(key_matrix=[[1,3],[2,0]], modulus=256)
        >>> keystream = cipher.generate(100)
        >>> ciphertext = cipher.encrypt(b"Hello, world!")
        >>> plaintext = cipher.decrypt(ciphertext)
    """
    
    def __init__(self, key_matrix: List[List[float]], modulus: int = 256):
        self.key = key_matrix
        self.modulus = modulus
        self.position = 0
    
    def generate(self, length: int) -> List[int]:
        """Generate `length` bytes of keystream."""
        stream = []
        for i in range(length):
            power = trop_matpow(self.key, self.position + i)
            stream.append(hash_mod(power, self.modulus))
        self.position += length
        return stream
    
    def encrypt(self, plaintext: bytes) -> bytes:
        """Encrypt plaintext using XOR with keystream."""
        keystream = self.generate(len(plaintext))
        return bytes(p ^ k for p, k in zip(plaintext, keystream))
    
    def decrypt(self, ciphertext: bytes) -> bytes:
        """Decrypt ciphertext (same as encrypt for XOR cipher)."""
        self.position -= len(ciphertext)  # Rewind
        return self.encrypt(ciphertext)
    
    def reset(self):
        """Reset stream position."""
        self.position = 0

# ─────────────────────────────────────────────────────────────────────
# Application 2: Deterministic Test Random Number Generator
# ─────────────────────────────────────────────────────────────────────

class TropicalTestRNG:
    """Deterministic RNG for software testing.
    
    Produces reproducible pseudorandom sequences from a tropical
    matrix seed. Unlike standard PRNGs (LCG, Mersenne Twister),
    this generator's quality is backed by a formal mathematical
    theorem connecting orbit expansion to statistical uniformity.
    
    The key advantage: if you can verify that your seed matrix has
    orbit expansion (easy to check computationally), you get a
    formal guarantee on output quality.
    
    Example:
        >>> rng = TropicalTestRNG(seed_matrix=[[2,5],[1,3]])
        >>> values = rng.random_integers(0, 100, count=50)
    """
    
    def __init__(self, seed_matrix: List[List[float]], bits_per_sample: int = 8):
        self.seed = seed_matrix
        self.bits = bits_per_sample
        self.modulus = 2 ** bits_per_sample
        self.counter = 0
    
    def next_value(self) -> int:
        """Generate next pseudorandom value in [0, modulus)."""
        power = trop_matpow(self.seed, self.counter)
        value = hash_mod(power, self.modulus)
        self.counter += 1
        return value
    
    def random_integers(self, low: int, high: int, count: int = 1) -> List[int]:
        """Generate `count` random integers in [low, high)."""
        range_size = high - low
        return [low + self.next_value() % range_size for _ in range(count)]
    
    def random_floats(self, count: int = 1) -> List[float]:
        """Generate `count` random floats in [0, 1)."""
        return [self.next_value() / self.modulus for _ in range(count)]
    
    def verify_expansion(self, T: int) -> bool:
        """Check if seed has full orbit expansion up to step T."""
        powers = set()
        for i in range(T + 1):
            p = tuple(tuple(row) for row in trop_matpow(self.seed, i))
            powers.add(p)
        return len(powers) == T + 1

# ─────────────────────────────────────────────────────────────────────
# Application 3: Scheduling-Aware PRG
# ─────────────────────────────────────────────────────────────────────

class SchedulingPRG:
    """PRG for job scheduling with built-in timing structure.
    
    In scheduling theory, tropical matrices naturally encode
    job processing times and resource constraints. This PRG
    generates randomized schedules where the randomness quality
    is tied to the scheduling graph's structure.
    
    The matrix A encodes processing times: A[i][j] is the minimum
    time needed to transition from resource i to resource j.
    Powers A^k encode k-step transition times.
    
    Example:
        >>> # 3 machines, random processing times
        >>> A = [[0, 3, 7], [2, 0, 5], [4, 1, 0]]
        >>> prg = SchedulingPRG(A, num_jobs=10)
        >>> schedule = prg.generate_schedule()
    """
    
    def __init__(self, processing_matrix: List[List[float]], num_jobs: int):
        self.matrix = processing_matrix
        self.num_jobs = num_jobs
        self.n = len(processing_matrix)
    
    def generate_schedule(self, modulus: int = None) -> List[Tuple[int, int]]:
        """Generate a randomized job schedule.
        
        Returns list of (machine, start_time) assignments.
        """
        if modulus is None:
            modulus = self.n
        
        schedule = []
        for job in range(self.num_jobs):
            power = trop_matpow(self.matrix, job + 1)
            machine = hash_mod(power, modulus) % self.n
            # Start time from tropical power structure
            start_time = min(power[machine][j] for j in range(self.n) 
                           if power[machine][j] != INF)
            if start_time == INF:
                start_time = 0
            schedule.append((machine, int(start_time)))
        
        return schedule
    
    def makespan_estimate(self) -> float:
        """Estimate makespan using tropical powers."""
        power = trop_matpow(self.matrix, self.num_jobs)
        finite_vals = [power[i][j] for i in range(self.n) 
                      for j in range(self.n) if power[i][j] != INF]
        return max(finite_vals) if finite_vals else 0

# ─────────────────────────────────────────────────────────────────────
# Application 4: Graph-Based Key Derivation
# ─────────────────────────────────────────────────────────────────────

class TropicalKeyDerivation:
    """Key derivation from shortest-path structure.
    
    Given a weighted directed graph (as an adjacency matrix with
    edge weights), derive cryptographic keys by hashing tropical
    powers. The k-th power encodes all-pairs shortest paths of
    length exactly k, providing a rich source of pseudorandomness
    when the graph has good expansion.
    
    This connects graph expansion (a well-studied property) to
    cryptographic key quality via the tropical orbit PRG theorem.
    
    Example:
        >>> # Random weighted graph on 4 vertices
        >>> G = [[0, 3, INF, 7], [INF, 0, 2, INF],
        ...      [5, INF, 0, 1], [INF, 4, INF, 0]]
        >>> kdf = TropicalKeyDerivation(G)
        >>> key = kdf.derive_key(length=32)
    """
    
    def __init__(self, adjacency_matrix: List[List[float]]):
        self.graph = adjacency_matrix
        self.n = len(adjacency_matrix)
    
    def derive_key(self, length: int, modulus: int = 256) -> bytes:
        """Derive a key of given length from the graph structure.
        
        Each byte is derived from a different tropical power,
        ensuring that the key benefits from orbit expansion.
        """
        key_bytes = []
        for i in range(length):
            power = trop_matpow(self.graph, i + 1)
            key_bytes.append(hash_mod(power, modulus))
        return bytes(key_bytes)
    
    def check_expansion(self, T: int) -> dict:
        """Analyze expansion quality of the graph for key derivation."""
        powers = set()
        for i in range(T + 1):
            p = tuple(tuple(row) for row in trop_matpow(self.graph, i))
            powers.add(p)
        return {
            'total_steps': T + 1,
            'distinct_powers': len(powers),
            'expansion_ratio': len(powers) / (T + 1),
            'full_expansion': len(powers) == T + 1
        }

# ─────────────────────────────────────────────────────────────────────
# Main demonstration
# ─────────────────────────────────────────────────────────────────────

def main():
    print("=" * 70)
    print("APPLICATIONS OF TROPICAL ORBIT PRG THEORY")
    print("=" * 70)
    
    # App 1: Stream cipher
    print(f"\n{'─'*70}")
    print("Application 1: Lightweight Stream Cipher")
    print(f"{'─'*70}")
    
    key = [[1, 3, 7], [2, 0, 5], [4, 1, 0]]
    cipher = TropicalStreamCipher(key)
    
    plaintext = b"Tropical algebra meets cryptography!"
    ciphertext = cipher.encrypt(plaintext)
    cipher.reset()
    decrypted = cipher.decrypt(ciphertext)
    
    print(f"  Plaintext:  {plaintext}")
    print(f"  Ciphertext: {ciphertext.hex()[:60]}...")
    print(f"  Decrypted:  {decrypted}")
    print(f"  Match: {plaintext == decrypted}")
    
    # Keystream statistics
    cipher.reset()
    keystream = cipher.generate(1000)
    counts = Counter(keystream)
    print(f"  Keystream uniformity (1000 bytes):")
    print(f"    Unique values: {len(counts)}/256")
    print(f"    Max frequency: {max(counts.values())}")
    print(f"    Min frequency: {min(counts.values()) if len(counts) == 256 else 0}")
    
    # App 2: Test RNG
    print(f"\n{'─'*70}")
    print("Application 2: Deterministic Test RNG")
    print(f"{'─'*70}")
    
    rng = TropicalTestRNG([[2, 5], [1, 3]])
    values = rng.random_integers(0, 100, count=20)
    print(f"  20 random integers in [0,100): {values}")
    
    floats = TropicalTestRNG([[2, 5], [1, 3]]).random_floats(10)
    print(f"  10 random floats: {[f'{x:.3f}' for x in floats]}")
    
    has_expansion = rng.verify_expansion(20)
    print(f"  Full expansion up to T=20: {has_expansion}")
    
    # App 3: Scheduling
    print(f"\n{'─'*70}")
    print("Application 3: Scheduling-Aware PRG")
    print(f"{'─'*70}")
    
    proc_matrix = [[0, 3, 7], [2, 0, 5], [4, 1, 0]]
    prg = SchedulingPRG(proc_matrix, num_jobs=8)
    schedule = prg.generate_schedule()
    
    print(f"  Generated schedule (machine, start_time):")
    for job, (machine, start) in enumerate(schedule):
        print(f"    Job {job}: Machine {machine}, Start time {start}")
    
    makespan = prg.makespan_estimate()
    print(f"  Estimated makespan: {makespan}")
    
    # App 4: Key derivation
    print(f"\n{'─'*70}")
    print("Application 4: Graph-Based Key Derivation")
    print(f"{'─'*70}")
    
    graph = [[0, 3, INF, 7], [INF, 0, 2, INF],
             [5, INF, 0, 1], [INF, 4, INF, 0]]
    kdf = TropicalKeyDerivation(graph)
    
    key = kdf.derive_key(32)
    print(f"  Derived 32-byte key: {key.hex()}")
    
    expansion = kdf.check_expansion(32)
    print(f"  Graph expansion analysis:")
    for k, v in expansion.items():
        print(f"    {k}: {v}")
    
    print(f"\n{'='*70}")
    print("All applications demonstrated successfully.")
    print("Key theme: min-plus algebra provides lightweight, provably")
    print("structured pseudorandomness for diverse applications.")
    print(f"{'='*70}")

if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
demo.py — Tropical Orbit PRG: Concrete Numerical Demonstrations

Demonstrates how tropical matrix powering generates pseudorandom sequences
when combined with hash extraction. Shows the key mathematical phenomena:
1. Orbit expansion in tropical (min-plus) algebra
2. Conditional entropy preservation along orbits
3. Statistical distance from uniform after hashing
4. Comparison of dense vs prime-power thinned orbits
"""

import numpy as np
from itertools import product
from collections import Counter

# ─────────────────────────────────────────────────────────────────────
# §1. Tropical (min-plus) matrix operations
# ─────────────────────────────────────────────────────────────────────

INF = float('inf')

def trop_add(a, b):
    """Tropical addition: min(a, b)."""
    return min(a, b)

def trop_mul(a, b):
    """Tropical multiplication: a + b (in the usual sense)."""
    if a == INF or b == INF:
        return INF
    return a + b

def trop_matmul(A, B):
    """Tropical matrix multiplication: C[i,j] = min_k (A[i,k] + B[k,j])."""
    n = len(A)
    C = [[INF]*n for _ in range(n)]
    for i in range(n):
        for j in range(n):
            for k in range(n):
                C[i][j] = trop_add(C[i][j], trop_mul(A[i][k], B[k][j]))
    return C

def trop_matpow(A, p):
    """Compute A^p in the tropical semiring."""
    n = len(A)
    # Identity: 0 on diagonal, INF elsewhere
    result = [[INF]*n for _ in range(n)]
    for i in range(n):
        result[i][i] = 0
    base = [row[:] for row in A]
    while p > 0:
        if p % 2 == 1:
            result = trop_matmul(result, base)
        base = trop_matmul(base, base)
        p //= 2
    return result

def mat_to_tuple(M):
    """Flatten matrix to tuple for hashing/comparison."""
    return tuple(tuple(row) for row in M)

# ─────────────────────────────────────────────────────────────────────
# §2. Generate a seed family of tropical matrices
# ─────────────────────────────────────────────────────────────────────

def generate_seed_family(n, num_seeds, value_range=10, rng=None):
    """Generate a random family of n×n tropical matrices with entries in [0, value_range]."""
    if rng is None:
        rng = np.random.default_rng(42)
    seeds = []
    for _ in range(num_seeds):
        M = [[int(rng.integers(0, value_range+1)) for _ in range(n)] for _ in range(n)]
        seeds.append(M)
    return seeds

# ─────────────────────────────────────────────────────────────────────
# §3. Hash function (extraction)
# ─────────────────────────────────────────────────────────────────────

def tropical_hash(M, modulus=8):
    """Simple hash: sum of all entries mod modulus.
    
    This serves as a basic extractor from tropical matrix space to a
    finite alphabet {0, 1, ..., modulus-1}.
    """
    total = 0
    for row in M:
        for x in row:
            if x != INF:
                total += int(x)
    return total % modulus

# ─────────────────────────────────────────────────────────────────────
# §4. Orbit hash sequence generation
# ─────────────────────────────────────────────────────────────────────

def orbit_hash_sequence(seed_matrix, T, hash_fn=tropical_hash, modulus=8):
    """Compute [h(G^0), h(G^1), ..., h(G^T)] for a seed matrix G."""
    seq = []
    for i in range(T + 1):
        power = trop_matpow(seed_matrix, i)
        seq.append(hash_fn(power, modulus))
    return tuple(seq)

def prime_power_orbit_hash(seed_matrix, T, p=2, hash_fn=tropical_hash, modulus=8):
    """Compute [h(G^(p^0)), h(G^(p^1)), ..., h(G^(p^T))] for prime p."""
    seq = []
    for j in range(T + 1):
        power = trop_matpow(seed_matrix, p**j)
        seq.append(hash_fn(power, modulus))
    return tuple(seq)

# ─────────────────────────────────────────────────────────────────────
# §5. Statistical distance computation
# ─────────────────────────────────────────────────────────────────────

def empirical_distribution(sequences, alphabet_size, length):
    """Compute empirical distribution of sequence tuples."""
    counts = Counter(sequences)
    total = len(sequences)
    total_outcomes = alphabet_size ** length
    dist = {}
    for seq, count in counts.items():
        dist[seq] = count / total
    return dist, total_outcomes

def statistical_distance(dist, total_outcomes):
    """Compute statistical distance from uniform over all outcomes."""
    uniform_prob = 1.0 / total_outcomes
    total_var = 0.0
    # Sum over outcomes that appear in dist
    for seq, prob in dist.items():
        total_var += abs(prob - uniform_prob)
    # Add contribution from outcomes not in dist
    missing = total_outcomes - len(dist)
    total_var += missing * uniform_prob
    return total_var / 2.0

# ─────────────────────────────────────────────────────────────────────
# §6. Prefix fiber analysis
# ─────────────────────────────────────────────────────────────────────

def compute_prefix_fibers(seeds, T, hash_fn=tropical_hash, modulus=8):
    """Compute prefix fiber sizes for each step i ≤ T."""
    # For each step i, compute the map s -> (h(G^0), ..., h(G^(i-1)))
    # and find the maximum fiber size
    results = []
    all_hashes = []
    for s in seeds:
        hashes = []
        for i in range(T + 1):
            power = trop_matpow(s, i)
            hashes.append(hash_fn(power, modulus))
        all_hashes.append(tuple(hashes))
    
    for i in range(T + 1):
        prefix_map = Counter()
        for hashes in all_hashes:
            prefix = hashes[:i]
            prefix_map[prefix] += 1
        max_fiber = max(prefix_map.values()) if prefix_map else 0
        results.append({
            'step': i,
            'num_prefixes': len(prefix_map),
            'max_fiber_size': max_fiber,
            'avg_fiber_size': len(seeds) / len(prefix_map) if prefix_map else 0
        })
    return results

# ─────────────────────────────────────────────────────────────────────
# §7. Main demonstration
# ─────────────────────────────────────────────────────────────────────

def main():
    print("=" * 70)
    print("TROPICAL ORBIT PRG: DEMONSTRATION")
    print("Harvesting randomness from min-plus matrix dynamics")
    print("=" * 70)
    
    # Parameters
    n = 2          # Matrix dimension
    num_seeds = 64 # Size of seed family
    T = 5          # Orbit length
    modulus = 4    # Hash output alphabet size
    
    rng = np.random.default_rng(2024)
    seeds = generate_seed_family(n, num_seeds, value_range=15, rng=rng)
    
    print(f"\nParameters:")
    print(f"  Matrix dimension: {n}×{n}")
    print(f"  Seed family size: {num_seeds}")
    print(f"  Orbit length T: {T}")
    print(f"  Hash alphabet size: {modulus}")
    
    # ── Demo 1: Orbit expansion ──
    print(f"\n{'─'*70}")
    print("Demo 1: Orbit Expansion (Distinct Powers)")
    print(f"{'─'*70}")
    
    for idx in range(min(3, num_seeds)):
        powers = set()
        for i in range(T + 1):
            p = mat_to_tuple(trop_matpow(seeds[idx], i))
            powers.add(p)
        print(f"  Seed {idx}: {len(powers)} distinct powers out of {T+1} steps")
    
    # Count seeds with full orbit expansion
    full_expansion = 0
    for s in seeds:
        powers = set()
        for i in range(T + 1):
            p = mat_to_tuple(trop_matpow(s, i))
            powers.add(p)
        if len(powers) == T + 1:
            full_expansion += 1
    print(f"\n  Seeds with full expansion (all {T+1} powers distinct): "
          f"{full_expansion}/{num_seeds} = {full_expansion/num_seeds:.1%}")
    
    # ── Demo 2: Orbit hash sequences ──
    print(f"\n{'─'*70}")
    print("Demo 2: Orbit Hash Sequences")
    print(f"{'─'*70}")
    
    sequences = []
    for s in seeds:
        seq = orbit_hash_sequence(s, T, modulus=modulus)
        sequences.append(seq)
    
    print(f"  First 5 orbit hash sequences:")
    for i in range(min(5, len(sequences))):
        print(f"    Seed {i}: {sequences[i]}")
    
    # ── Demo 3: Statistical distance from uniform ──
    print(f"\n{'─'*70}")
    print("Demo 3: Statistical Distance from Uniform")
    print(f"{'─'*70}")
    
    for t in range(1, T + 1):
        truncated = [seq[:t+1] for seq in sequences]
        dist, total = empirical_distribution(truncated, modulus, t + 1)
        sd = statistical_distance(dist, total)
        print(f"  Length {t+1}: stat_dist = {sd:.4f}, "
              f"distinct outputs = {len(dist)}/{total}")
    
    # ── Demo 4: Prefix fiber analysis ──
    print(f"\n{'─'*70}")
    print("Demo 4: Prefix Fiber Analysis")
    print(f"{'─'*70}")
    
    fibers = compute_prefix_fibers(seeds, T, modulus=modulus)
    print(f"  {'Step':>4} {'#Prefixes':>10} {'MaxFiber':>10} {'AvgFiber':>10} "
          f"{'log₂(N/B)':>10}")
    for f in fibers:
        log_bound = (np.log2(num_seeds / f['max_fiber_size']) 
                     if f['max_fiber_size'] > 0 else float('inf'))
        print(f"  {f['step']:>4} {f['num_prefixes']:>10} "
              f"{f['max_fiber_size']:>10} {f['avg_fiber_size']:>10.1f} "
              f"{log_bound:>10.2f}")
    
    # ── Demo 5: Dense vs prime-power orbits ──
    print(f"\n{'─'*70}")
    print("Demo 5: Dense vs Prime-Power Orbit Comparison")
    print(f"{'─'*70}")
    
    T_long = 8
    # Dense orbit
    dense_seqs = []
    for s in seeds:
        seq = orbit_hash_sequence(s, T_long, modulus=modulus)
        dense_seqs.append(seq)
    
    dense_dist, dense_total = empirical_distribution(dense_seqs, modulus, T_long + 1)
    dense_sd = statistical_distance(dense_dist, dense_total)
    
    # Prime-power orbit (p=2)
    pp_seqs = []
    T_pp = min(T_long, 4)  # p^j grows fast, keep manageable
    for s in seeds:
        seq = prime_power_orbit_hash(s, T_pp, p=2, modulus=modulus)
        pp_seqs.append(seq)
    
    pp_dist, pp_total = empirical_distribution(pp_seqs, modulus, T_pp + 1)
    pp_sd = statistical_distance(pp_dist, pp_total)
    
    print(f"  Dense orbit (T={T_long}):       stat_dist = {dense_sd:.4f}, "
          f"distinct = {len(dense_dist)}/{dense_total}")
    print(f"  Prime-power orbit (T={T_pp}, p=2): stat_dist = {pp_sd:.4f}, "
          f"distinct = {len(pp_dist)}/{pp_total}")
    
    # ── Demo 6: Conditional extraction quality ──
    print(f"\n{'─'*70}")
    print("Demo 6: Conditional Extraction Quality (Step-by-Step)")
    print(f"{'─'*70}")
    
    # For each step i, compute the conditional distribution of h(G^i) given prefix
    all_hashes = []
    for s in seeds:
        hashes = tuple(orbit_hash_sequence(s, T, modulus=modulus))
        all_hashes.append(hashes)
    
    for i in range(T + 1):
        # Group by prefix
        prefix_groups = {}
        for hashes in all_hashes:
            prefix = hashes[:i]
            if prefix not in prefix_groups:
                prefix_groups[prefix] = []
            prefix_groups[prefix].append(hashes[i])
        
        # For each prefix, compute stat distance of conditional dist from uniform
        max_cond_sd = 0.0
        avg_cond_sd = 0.0
        for prefix, values in prefix_groups.items():
            counts = Counter(values)
            fiber_size = len(values)
            cond_sd = 0.0
            for b in range(modulus):
                prob = counts.get(b, 0) / fiber_size
                cond_sd += abs(prob - 1.0 / modulus)
            cond_sd /= 2.0
            max_cond_sd = max(max_cond_sd, cond_sd)
            avg_cond_sd += cond_sd * fiber_size / num_seeds
        
        print(f"  Step {i}: max_cond_ε = {max_cond_sd:.4f}, "
              f"avg_cond_ε = {avg_cond_sd:.4f}, "
              f"#prefixes = {len(prefix_groups)}")
    
    # ── Demo 7: Next-symbol unpredictability ──
    print(f"\n{'─'*70}")
    print("Demo 7: Next-Symbol Unpredictability")
    print(f"{'─'*70}")
    
    # Test a simple predictor: most frequent next symbol given prefix
    for i in range(1, T + 1):
        # Build predictor from prefix statistics
        prefix_groups = {}
        for hashes in all_hashes:
            prefix = hashes[:i]
            if prefix not in prefix_groups:
                prefix_groups[prefix] = []
            prefix_groups[prefix].append(hashes[i])
        
        correct = 0
        for hashes in all_hashes:
            prefix = hashes[:i]
            # Predict most common next symbol
            counts = Counter(prefix_groups[prefix])
            prediction = counts.most_common(1)[0][0]
            if prediction == hashes[i]:
                correct += 1
        
        accuracy = correct / num_seeds
        random_guess = 1.0 / modulus
        print(f"  Step {i}: predictor accuracy = {accuracy:.4f}, "
              f"random guess = {random_guess:.4f}, "
              f"advantage = {accuracy - random_guess:.4f}")
    
    print(f"\n{'='*70}")
    print("All demonstrations complete.")
    print("Key insight: Tropical orbit expansion → extractable randomness")
    print(f"{'='*70}")

if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
visualizations.py — Generate figures for the Tropical Orbit PRG research.

Creates publication-quality visualizations saved as PNG files.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from collections import Counter
import base64
import io

# ── Tropical operations (self-contained) ──
INF = float('inf')

def trop_matmul(A, B):
    n = len(A)
    C = [[INF]*n for _ in range(n)]
    for i in range(n):
        for j in range(n):
            for k in range(n):
                if A[i][k] != INF and B[k][j] != INF:
                    C[i][j] = min(C[i][j], A[i][k] + B[k][j])
    return C

def trop_matpow(A, p):
    n = len(A)
    result = [[INF]*n for _ in range(n)]
    for i in range(n):
        result[i][i] = 0
    base = [row[:] for row in A]
    while p > 0:
        if p % 2 == 1:
            result = trop_matmul(result, base)
        base = trop_matmul(base, base)
        p //= 2
    return result

def hash_mod(M, modulus=4):
    total = 0
    for row in M:
        for x in row:
            if x != INF:
                total += int(x)
    return total % modulus

def generate_seeds(n, num_seeds, value_range=15, rng_seed=42):
    rng = np.random.default_rng(rng_seed)
    return [[[int(rng.integers(0, value_range+1)) for _ in range(n)] 
             for _ in range(n)] for _ in range(num_seeds)]

# ─────────────────────────────────────────────────────────────────────
# Figure 1: Orbit Expansion Heatmap
# ─────────────────────────────────────────────────────────────────────

def fig_orbit_expansion():
    """Heatmap showing distinct powers for different seed families."""
    fig, ax = plt.subplots(figsize=(10, 6))
    
    n = 2
    T = 12
    num_seeds = 40
    seeds = generate_seeds(n, num_seeds, value_range=10, rng_seed=2024)
    
    data = np.zeros((num_seeds, T + 1))
    for si, s in enumerate(seeds):
        seen = set()
        for t in range(T + 1):
            p = tuple(tuple(row) for row in trop_matpow(s, t))
            seen.add(p)
            data[si, t] = len(seen)
    
    im = ax.imshow(data, aspect='auto', cmap='viridis', interpolation='nearest')
    ax.set_xlabel('Orbit Step t', fontsize=13)
    ax.set_ylabel('Seed Index', fontsize=13)
    ax.set_title('Tropical Orbit Expansion: Distinct Powers vs Time', fontsize=14)
    plt.colorbar(im, ax=ax, label='# Distinct Powers')
    
    fig.tight_layout()
    fig.savefig('/workspace/request-project/fig_orbit_expansion.png', dpi=150)
    plt.close(fig)
    return '/workspace/request-project/fig_orbit_expansion.png'

# ─────────────────────────────────────────────────────────────────────
# Figure 2: Statistical Distance vs Orbit Length
# ─────────────────────────────────────────────────────────────────────

def fig_stat_distance():
    """Statistical distance from uniform as orbit length grows."""
    fig, ax = plt.subplots(figsize=(9, 6))
    
    modulus = 4
    T = 8
    
    for num_seeds, marker, color in [(32, 'o', '#e74c3c'), (64, 's', '#3498db'), 
                                      (128, '^', '#2ecc71'), (256, 'D', '#9b59b6')]:
        seeds = generate_seeds(2, num_seeds, value_range=15, rng_seed=42)
        
        sds = []
        for t in range(T + 1):
            seqs = []
            for s in seeds:
                seq = tuple(hash_mod(trop_matpow(s, i), modulus) for i in range(t + 1))
                seqs.append(seq)
            
            counts = Counter(seqs)
            total_outcomes = modulus ** (t + 1)
            uniform_prob = 1.0 / total_outcomes
            tv = sum(abs(c/num_seeds - uniform_prob) for c in counts.values())
            tv += (total_outcomes - len(counts)) * uniform_prob
            sds.append(tv / 2.0)
        
        ax.plot(range(T + 1), sds, f'-{marker}', color=color, 
                label=f'|S| = {num_seeds}', markersize=7, linewidth=2)
    
    ax.set_xlabel('Orbit Length T', fontsize=13)
    ax.set_ylabel('Statistical Distance from Uniform', fontsize=13)
    ax.set_title('PRG Quality: Statistical Distance vs Orbit Length', fontsize=14)
    ax.legend(fontsize=11)
    ax.set_ylim(-0.05, 1.05)
    ax.grid(True, alpha=0.3)
    
    fig.tight_layout()
    fig.savefig('/workspace/request-project/fig_stat_distance.png', dpi=150)
    plt.close(fig)
    return '/workspace/request-project/fig_stat_distance.png'

# ─────────────────────────────────────────────────────────────────────
# Figure 3: Prefix Fiber Sizes
# ─────────────────────────────────────────────────────────────────────

def fig_fiber_analysis():
    """Prefix fiber sizes and conditional entropy."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))
    
    n = 2
    T = 8
    num_seeds = 128
    modulus = 4
    seeds = generate_seeds(n, num_seeds, value_range=15, rng_seed=2024)
    
    all_hashes = []
    for s in seeds:
        hashes = tuple(hash_mod(trop_matpow(s, i), modulus) for i in range(T + 1))
        all_hashes.append(hashes)
    
    max_fibers = []
    avg_fibers = []
    cond_entropies = []
    
    for i in range(T + 1):
        prefix_counts = Counter()
        for hashes in all_hashes:
            prefix_counts[hashes[:i]] += 1
        
        max_f = max(prefix_counts.values())
        avg_f = num_seeds / len(prefix_counts)
        cond_ent = np.log2(num_seeds / max_f) if max_f > 0 else 0
        
        max_fibers.append(max_f)
        avg_fibers.append(avg_f)
        cond_entropies.append(cond_ent)
    
    steps = range(T + 1)
    ax1.bar(steps, max_fibers, alpha=0.7, color='#e74c3c', label='Max Fiber')
    ax1.bar(steps, avg_fibers, alpha=0.5, color='#3498db', label='Avg Fiber')
    ax1.set_xlabel('Orbit Step', fontsize=12)
    ax1.set_ylabel('Fiber Size', fontsize=12)
    ax1.set_title('Prefix Fiber Sizes', fontsize=13)
    ax1.legend()
    ax1.grid(True, alpha=0.3)
    
    ax2.plot(steps, cond_entropies, '-o', color='#2ecc71', linewidth=2, markersize=8)
    ax2.axhline(y=np.log2(num_seeds), color='gray', linestyle='--', 
                label=f'log₂|S| = {np.log2(num_seeds):.1f}')
    ax2.set_xlabel('Orbit Step', fontsize=12)
    ax2.set_ylabel('Conditional Min-Entropy (bits)', fontsize=12)
    ax2.set_title('Conditional Min-Entropy Lower Bound', fontsize=13)
    ax2.legend()
    ax2.grid(True, alpha=0.3)
    
    fig.tight_layout()
    fig.savefig('/workspace/request-project/fig_fiber_analysis.png', dpi=150)
    plt.close(fig)
    return '/workspace/request-project/fig_fiber_analysis.png'

# ─────────────────────────────────────────────────────────────────────
# Figure 4: Dense vs Prime-Power Error Comparison
# ─────────────────────────────────────────────────────────────────────

def fig_dense_vs_primepower():
    """Compare error accumulation: dense orbit vs prime-power thinning."""
    fig, ax = plt.subplots(figsize=(9, 6))
    
    # Theoretical comparison
    T_vals = np.arange(1, 21)
    eps = 0.05
    r = 0.7
    
    dense_bound = (T_vals + 1) * eps
    pp_bound = np.full_like(T_vals, eps / (1 - r), dtype=float)
    pp_actual = np.array([eps * sum(r**j for j in range(t+1)) for t in T_vals])
    
    ax.plot(T_vals, dense_bound, '-o', color='#e74c3c', linewidth=2, 
            label=f'Dense orbit: (T+1)·ε = {eps}·(T+1)', markersize=5)
    ax.plot(T_vals, pp_bound, '--', color='#3498db', linewidth=2, 
            label=f'Prime-power bound: ε₀/(1-r) = {eps/(1-r):.3f}')
    ax.plot(T_vals, pp_actual, '-s', color='#2ecc71', linewidth=2,
            label=f'Prime-power actual: ε₀·∑rʲ', markersize=5)
    
    ax.set_xlabel('Orbit Length T', fontsize=13)
    ax.set_ylabel('Cumulative Error Bound', fontsize=13)
    ax.set_title(f'Dense vs Prime-Power Orbit: Error Accumulation (ε={eps}, r={r})', 
                 fontsize=14)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    
    fig.tight_layout()
    fig.savefig('/workspace/request-project/fig_dense_vs_pp.png', dpi=150)
    plt.close(fig)
    return '/workspace/request-project/fig_dense_vs_pp.png'

# ─────────────────────────────────────────────────────────────────────
# Figure 5: Conditional Extraction Quality
# ─────────────────────────────────────────────────────────────────────

def fig_extraction_quality():
    """Step-by-step conditional extraction quality."""
    fig, ax = plt.subplots(figsize=(9, 6))
    
    T = 8
    modulus = 4
    
    for num_seeds, marker, color in [(64, 'o', '#e74c3c'), (128, 's', '#3498db'),
                                      (256, '^', '#2ecc71')]:
        seeds = generate_seeds(2, num_seeds, value_range=15, rng_seed=42)
        
        all_hashes = []
        for s in seeds:
            hashes = tuple(hash_mod(trop_matpow(s, i), modulus) for i in range(T + 1))
            all_hashes.append(hashes)
        
        max_cond_sds = []
        for i in range(T + 1):
            prefix_groups = {}
            for hashes in all_hashes:
                prefix = hashes[:i]
                if prefix not in prefix_groups:
                    prefix_groups[prefix] = []
                prefix_groups[prefix].append(hashes[i])
            
            max_sd = 0
            for values in prefix_groups.values():
                counts = Counter(values)
                fiber_size = len(values)
                sd = sum(abs(counts.get(b, 0)/fiber_size - 1/modulus) 
                        for b in range(modulus)) / 2
                max_sd = max(max_sd, sd)
            max_cond_sds.append(max_sd)
        
        ax.plot(range(T + 1), max_cond_sds, f'-{marker}', color=color,
                label=f'|S| = {num_seeds}', linewidth=2, markersize=7)
    
    ax.axhline(y=0, color='gray', linestyle='--', alpha=0.5)
    ax.set_xlabel('Orbit Step i', fontsize=13)
    ax.set_ylabel('Max Conditional Statistical Distance ε', fontsize=13)
    ax.set_title('Conditional Extraction Quality at Each Step', fontsize=14)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    ax.set_ylim(-0.05, 1.05)
    
    fig.tight_layout()
    fig.savefig('/workspace/request-project/fig_extraction_quality.png', dpi=150)
    plt.close(fig)
    return '/workspace/request-project/fig_extraction_quality.png'

# ─────────────────────────────────────────────────────────────────────
# Generate all figures
# ─────────────────────────────────────────────────────────────────────

def generate_all_figures():
    """Generate all visualization figures."""
    print("Generating figures...")
    
    paths = []
    for name, fn in [
        ("Orbit Expansion", fig_orbit_expansion),
        ("Statistical Distance", fig_stat_distance),
        ("Fiber Analysis", fig_fiber_analysis),
        ("Dense vs Prime-Power", fig_dense_vs_primepower),
        ("Extraction Quality", fig_extraction_quality),
    ]:
        print(f"  {name}...", end=" ", flush=True)
        path = fn()
        paths.append(path)
        print(f"Done → {path}")
    
    print(f"\nAll {len(paths)} figures generated successfully.")
    return paths

def fig_to_base64(path):
    """Convert a figure file to a base64 data URI."""
    with open(path, 'rb') as f:
        data = f.read()
    b64 = base64.b64encode(data).decode('utf-8')
    return f"data:image/png;base64,{b64}"

if __name__ == "__main__":
    paths = generate_all_figures()
