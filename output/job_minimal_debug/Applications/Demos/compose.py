#!/usr/bin/env python3
"""
Real-World Applications of Algebraic Fingerprinting and PIT

Demonstrates how the formally verified theorems apply to:
1. Streaming data deduplication
2. Rabin-Karp string matching
3. Verifiable computation
4. Network packet verification
"""

import random
import hashlib
from typing import List, Optional


# ============================================================================
# Application 1: Streaming Data Deduplication
# ============================================================================

def streaming_dedup_demo():
    """
    Application: Detect duplicate data chunks in a stream.

    Uses algebraic fingerprints to identify repeated segments
    with provably bounded false positive rate.

    The fingerprint_collision_bound theorem guarantees:
    For chunks of length n over GF(p), distinct chunks collide
    with probability <= (n-1)/p.
    """
    print("=" * 70)
    print("APPLICATION 1: Streaming Data Deduplication")
    print("=" * 70)
    print()

    p = 1000003  # Large prime
    chunk_size = 64

    # Simulate data chunks
    random.seed(42)
    chunks = []
    for _ in range(20):
        chunks.append([random.randint(0, 255) for _ in range(chunk_size)])
    # Add some duplicates
    chunks.append(list(chunks[3]))
    chunks.append(list(chunks[7]))
    chunks.append(list(chunks[3]))

    def fingerprint(chunk: List[int], r: int, p: int) -> int:
        """Compute algebraic fingerprint at evaluation point r."""
        result = 0
        power = 1
        for c in chunk:
            result = (result + c * power) % p
            power = (power * r) % p
        return result

    # Use fixed evaluation point for all chunks
    r = random.randint(1, p - 1)

    seen = {}  # fingerprint -> first occurrence index
    duplicates_found = []

    print(f"Processing {len(chunks)} chunks of size {chunk_size}")
    print(f"Field: GF({p}), evaluation point: {r}")
    print()

    for i, chunk in enumerate(chunks):
        fp = fingerprint(chunk, r, p)
        if fp in seen:
            duplicates_found.append((i, seen[fp]))
            print(f"  Chunk {i}: fingerprint={fp} -> DUPLICATE of chunk {seen[fp]}")
        else:
            seen[fp] = i

    print()
    print(f"Duplicates detected: {len(duplicates_found)}")
    error_bound = (chunk_size - 1) / p
    print(f"False positive probability per pair: <= {error_bound:.2e}")
    print(f"Memory: O(log p) = O({len(str(p))} digits) per fingerprint")
    print(f"  vs O({chunk_size}) bytes to store full chunk")
    print()


# ============================================================================
# Application 2: Rabin-Karp String Matching
# ============================================================================

def rabin_karp_demo():
    """
    Application: Rabin-Karp substring search using algebraic fingerprints.

    The fingerprint_collision_bound provides the formal soundness guarantee:
    false matches occur with probability <= (m-1)/p where m is pattern length.
    """
    print("=" * 70)
    print("APPLICATION 2: Rabin-Karp String Matching")
    print("=" * 70)
    print()

    p = 1000003
    text = "the quick brown fox jumps over the lazy brown fox sleeping"
    pattern = "brown fox"

    m = len(pattern)
    n = len(text)

    # Convert to numeric
    pat_vals = [ord(c) for c in pattern]
    txt_vals = [ord(c) for c in text]

    r = random.randint(1, p - 1)

    # Compute pattern fingerprint
    pat_fp = 0
    power = 1
    for c in pat_vals:
        pat_fp = (pat_fp + c * power) % p
        power = (power * r) % p

    # Sliding window fingerprint
    r_m = pow(r, m, p)  # r^m mod p
    window_fp = 0
    power = 1
    matches = []

    for i in range(n):
        # Add new character
        window_fp = (window_fp + txt_vals[i] * power) % p
        power = (power * r) % p

        if i >= m:
            # Remove old character (shift the window)
            pass  # Simplified: recompute

        if i >= m - 1:
            # Recompute fingerprint for window [i-m+1, i]
            window_fp = 0
            pw = 1
            for j in range(i - m + 1, i + 1):
                window_fp = (window_fp + txt_vals[j] * pw) % p
                pw = (pw * r) % p

            if window_fp == pat_fp:
                # Verify (in practice, check actual strings)
                actual_match = text[i - m + 1:i + 1] == pattern
                matches.append((i - m + 1, actual_match))

    print(f"Text: \"{text}\"")
    print(f"Pattern: \"{pattern}\"")
    print(f"Field: GF({p})")
    print()
    print("Matches found:")
    for pos, verified in matches:
        status = "TRUE MATCH" if verified else "FALSE POSITIVE"
        print(f"  Position {pos}: \"{text[pos:pos+m]}\" [{status}]")

    error_bound = (m - 1) / p
    print()
    print(f"False positive probability per position: <= {error_bound:.2e}")
    print()


# ============================================================================
# Application 3: Verifiable Computation
# ============================================================================

def verifiable_computation_demo():
    """
    Application: Verify matrix multiplication using fingerprints.

    To verify C = A * B for n×n matrices, evaluate the polynomial
    identity r^T * C = r^T * A * B at a random vector r.

    Uses Schwartz-Zippel: if C != A*B, detection probability >= 1 - 1/p.
    """
    print("=" * 70)
    print("APPLICATION 3: Verifiable Matrix Multiplication (Freivalds)")
    print("=" * 70)
    print()

    p = 101
    n = 4

    # Random matrices
    random.seed(42)
    A = [[random.randint(0, p - 1) for _ in range(n)] for _ in range(n)]
    B = [[random.randint(0, p - 1) for _ in range(n)] for _ in range(n)]

    # Correct product
    C_correct = [[sum(A[i][k] * B[k][j] for k in range(n)) % p
                   for j in range(n)] for i in range(n)]

    # Incorrect product (perturb one entry)
    C_wrong = [row[:] for row in C_correct]
    C_wrong[1][2] = (C_wrong[1][2] + 1) % p

    def freivalds_check(A, B, C, p, trials=5):
        """Freivalds' algorithm: verify C = A*B mod p."""
        for _ in range(trials):
            r = [random.randint(0, p - 1) for _ in range(n)]

            # Compute r^T * C
            rC = [sum(r[i] * C[i][j] for i in range(n)) % p for j in range(n)]

            # Compute r^T * A * B
            rA = [sum(r[i] * A[i][j] for i in range(n)) % p for j in range(n)]
            rAB = [sum(rA[k] * B[k][j] for k in range(n)) % p for j in range(n)]

            if rC != rAB:
                return False  # Definitely wrong

        return True  # Probably correct

    print(f"Matrix size: {n}x{n} over GF({p})")
    print()

    result = freivalds_check(A, B, C_correct, p, trials=5)
    print(f"Correct product C = A*B: verified = {result}")

    result = freivalds_check(A, B, C_wrong, p, trials=5)
    print(f"Wrong product C' ≠ A*B: verified = {result}")

    print()
    print(f"Verification cost: O(n²) per trial vs O(n³) for full multiplication")
    print(f"Error per trial: <= 1/{p} ≈ {1/p:.4f}")
    print(f"Error after 5 trials: <= (1/{p})^5 ≈ {(1/p)**5:.2e}")
    print()


# ============================================================================
# Application 4: Network Packet Verification
# ============================================================================

def network_verification_demo():
    """
    Application: Verify data integrity across a network.

    Sender and receiver compute algebraic fingerprints of data blocks
    and compare them. By fingerprint_collision_bound, corruption is
    detected with high probability using minimal communication.
    """
    print("=" * 70)
    print("APPLICATION 4: Network Data Integrity Verification")
    print("=" * 70)
    print()

    p = 2**31 - 1  # Mersenne prime
    block_size = 1024

    # Simulate a data block
    random.seed(42)
    original_data = [random.randint(0, 255) for _ in range(block_size)]

    # Simulate transmission with possible corruption
    scenarios = [
        ("No corruption", list(original_data)),
        ("1 byte flipped", None),
        ("10 bytes flipped", None),
        ("All bytes +1", [(x + 1) % 256 for x in original_data]),
    ]

    # Create corrupted versions
    corrupted_1 = list(original_data)
    pos = random.randint(0, block_size - 1)
    corrupted_1[pos] = (corrupted_1[pos] + 1) % 256
    scenarios[1] = ("1 byte flipped", corrupted_1)

    corrupted_10 = list(original_data)
    for _ in range(10):
        pos = random.randint(0, block_size - 1)
        corrupted_10[pos] = (corrupted_10[pos] + random.randint(1, 255)) % 256
    scenarios[2] = ("10 bytes flipped", corrupted_10)

    def compute_fingerprint(data, r, p):
        result = 0
        power = 1
        for x in data:
            result = (result + x * power) % p
            power = (power * r) % p
        return result

    r = random.randint(1, p - 1)
    original_fp = compute_fingerprint(original_data, r, p)

    print(f"Block size: {block_size} bytes")
    print(f"Field: GF({p}) (31-bit Mersenne prime)")
    print(f"Fingerprint size: 31 bits = 4 bytes")
    print(f"Compression ratio: {block_size}/4 = {block_size // 4}x")
    print()

    print(f"{'Scenario':<25} {'Fingerprint':>15} {'Match':>8} {'Detected':>10}")
    print("-" * 65)

    for name, data in scenarios:
        fp = compute_fingerprint(data, r, p)
        match = fp == original_fp
        detected = "—" if data == original_data else ("NO ⚠" if match else "YES ✓")
        print(f"{name:<25} {fp:>15} {str(match):>8} {detected:>10}")

    print()
    error_bound = (block_size - 1) / p
    print(f"False negative probability: <= (n-1)/p = {block_size-1}/{p} ≈ {error_bound:.2e}")
    print(f"This is the guarantee from fingerprint_collision_bound.")
    print()


# ============================================================================
# Main
# ============================================================================

if __name__ == "__main__":
    streaming_dedup_demo()
    rabin_karp_demo()
    verifiable_computation_demo()
    network_verification_demo()


#!/usr/bin/env python3
"""
Algebraic Fingerprinting & Polynomial Identity Testing: Interactive Demos

Demonstrates the core theorems connecting polynomial root bounds to:
1. Streaming equality verification (fingerprinting)
2. Polynomial identity testing (PIT)
3. Circuit complexity lower bounds via zero-set analysis

Each demo uses concrete finite fields to make the abstract algebra tangible.
"""

import random
from typing import List, Tuple


# ============================================================================
# Finite Field Arithmetic (F_p for prime p)
# ============================================================================

class GF:
    """Simple finite field GF(p) for prime p."""
    def __init__(self, val: int, p: int):
        self.val = val % p
        self.p = p

    def __add__(self, other):
        return GF((self.val + other.val) % self.p, self.p)

    def __sub__(self, other):
        return GF((self.val - other.val) % self.p, self.p)

    def __mul__(self, other):
        return GF((self.val * other.val) % self.p, self.p)

    def __eq__(self, other):
        return self.val == other.val and self.p == other.p

    def __repr__(self):
        return f"{self.val}"

    def __hash__(self):
        return hash((self.val, self.p))


def eval_vecpoly(coeffs: List[int], x: int, p: int) -> int:
    """Evaluate the polynomial sum(coeffs[i] * x^i) in GF(p)."""
    result = 0
    power = 1
    for c in coeffs:
        result = (result + c * power) % p
        power = (power * x) % p
    return result


# ============================================================================
# Demo 1: Fingerprinting for Streaming Equality
# ============================================================================

def demo_fingerprinting():
    """
    Demonstrates algebraic fingerprinting for equality testing.

    Two data streams s1, s2 are encoded as polynomials p_s1, p_s2.
    If s1 != s2, evaluating at a random field point detects the difference
    with probability >= 1 - (n-1)/|K|.
    """
    print("=" * 70)
    print("DEMO 1: Algebraic Fingerprinting for Streaming Equality")
    print("=" * 70)
    print()

    p = 101  # Work over GF(101)
    n = 10   # Vector length

    # Two distinct vectors
    s1 = [random.randint(0, p - 1) for _ in range(n)]
    s2 = list(s1)
    # Flip one random position
    flip_pos = random.randint(0, n - 1)
    s2[flip_pos] = (s2[flip_pos] + random.randint(1, p - 1)) % p

    print(f"Field: GF({p}), Vector length: {n}")
    print(f"Stream 1: {s1}")
    print(f"Stream 2: {s2}")
    print(f"(Differ at position {flip_pos})")
    print()

    # Count collisions: points where p_s1(x) == p_s2(x)
    collisions = []
    for x in range(p):
        v1 = eval_vecpoly(s1, x, p)
        v2 = eval_vecpoly(s2, x, p)
        if v1 == v2:
            collisions.append(x)

    print(f"Collision points (where fingerprints agree): {collisions}")
    print(f"Number of collisions: {len(collisions)}")
    print(f"Theoretical bound (n - 1 = {n - 1}): {n - 1}")
    print(f"Bound satisfied: {len(collisions) <= n - 1}")
    print()

    # Probability analysis
    prob_error = len(collisions) / p
    prob_bound = (n - 1) / p
    print(f"Actual error probability: {len(collisions)}/{p} = {prob_error:.4f}")
    print(f"Theoretical bound: {n - 1}/{p} = {prob_bound:.4f}")
    print(f"Random evaluation detects difference with prob >= {1 - prob_bound:.4f}")
    print()

    # Amplification by repetition
    print("Amplification by independent trials:")
    for trials in [1, 5, 10, 20]:
        fail_prob = prob_bound ** trials
        print(f"  {trials} trial(s): failure prob <= {fail_prob:.2e}")
    print()


# ============================================================================
# Demo 2: Schwartz-Zippel Zero-Set Bound
# ============================================================================

def demo_schwartz_zippel():
    """
    Demonstrates the Schwartz-Zippel lemma for multivariate polynomials.

    For a nonzero polynomial f of total degree d over GF(p)^n,
    |{x : f(x) = 0}| <= d * p^(n-1).
    """
    print("=" * 70)
    print("DEMO 2: Schwartz-Zippel Zero-Set Bound")
    print("=" * 70)
    print()

    p = 7  # Small field for exhaustive enumeration
    n = 2  # Two variables

    # Various polynomials of different degrees
    polys = [
        ("x + y", 1, lambda x, y: (x + y) % p),
        ("x*y", 2, lambda x, y: (x * y) % p),
        ("x^2 + y^2 - 1", 2, lambda x, y: (x*x + y*y - 1) % p),
        ("x^3 + y^3", 3, lambda x, y: (x**3 + y**3) % p),
        ("x*y + x + y + 1", 2, lambda x, y: (x*y + x + y + 1) % p),
    ]

    total_points = p ** n
    print(f"Field: GF({p}), Variables: {n}, Total points: {total_points}")
    print(f"Schwartz-Zippel bound: degree * {p}^({n}-1) = degree * {p}")
    print()
    print(f"{'Polynomial':<20} {'Degree':>6} {'Zeros':>6} {'Bound':>6} {'OK?':>5}")
    print("-" * 50)

    for name, deg, f in polys:
        zeros = sum(1 for x in range(p) for y in range(p) if f(x, y) == 0)
        bound = deg * p ** (n - 1)
        ok = zeros <= bound
        print(f"{name:<20} {deg:>6} {zeros:>6} {bound:>6} {'✓' if ok else '✗':>5}")

    print()


# ============================================================================
# Demo 3: Circuit Complexity and PIT
# ============================================================================

def demo_circuit_pit():
    """
    Demonstrates the connection between circuit complexity and PIT.

    A circuit computing a nonzero polynomial of degree d has at most
    d * |K|^(n-1) zeros. If the zero set exceeds this bound, the
    circuit must compute the zero polynomial.
    """
    print("=" * 70)
    print("DEMO 3: Circuit Complexity and Polynomial Identity Testing")
    print("=" * 70)
    print()

    p = 11
    n = 2

    print(f"Field: GF({p}), Variables: {n}")
    print()

    # Simulate circuits of different multiplicative complexities
    # Circuit 1: f = x + y (0 multiplications, degree 1)
    # Circuit 2: f = x*y (1 multiplication, degree 2)
    # Circuit 3: f = x*y*(x+y) (2 multiplications, degree 3)

    circuits = [
        ("x + y", 0, 1, lambda x, y: (x + y) % p),
        ("x * y", 1, 2, lambda x, y: (x * y) % p),
        ("x*y*(x+y)", 2, 3, lambda x, y: (x * y * (x + y)) % p),
        ("(x+1)*(y+1)*(x+y)", 2, 3, lambda x, y: ((x+1) * (y+1) * (x+y)) % p),
    ]

    total = p ** n
    print(f"{'Circuit':<20} {'MulGates':>8} {'Degree':>6} {'Zeros':>6} "
          f"{'SZ Bound':>8} {'Zero%':>7}")
    print("-" * 65)

    for name, muls, deg, f in circuits:
        zeros = sum(1 for x in range(p) for y in range(p) if f(x, y) == 0)
        bound = deg * p ** (n - 1)
        pct = 100 * zeros / total
        print(f"{name:<20} {muls:>8} {deg:>6} {zeros:>6} {bound:>8} {pct:>6.1f}%")

    print()
    print("Key insight: circuits with more multiplication gates can compute")
    print("higher-degree polynomials, which can have more zeros.")
    print("But the zero fraction is always bounded by degree/|K|.")
    print()

    # Contrapositive demonstration
    print("CONTRAPOSITIVE: If too many zeros, polynomial must be zero")
    print(f"If zeros > degree * {p}^{n-1}, then the polynomial IS zero.")
    print()
    f_zero = lambda x, y: 0
    zeros_zero = sum(1 for x in range(p) for y in range(p) if f_zero(x, y) == 0)
    print(f"The zero polynomial: {zeros_zero} zeros = {p}^{n} = all points ✓")
    print()


# ============================================================================
# Demo 4: Fingerprint Error vs Field Size
# ============================================================================

def demo_error_vs_field_size():
    """
    Shows how fingerprint error probability decreases as field size grows.
    """
    print("=" * 70)
    print("DEMO 4: Error Probability vs Field Size")
    print("=" * 70)
    print()

    n = 8  # Fixed vector length

    # Two distinct vectors
    s1 = [1, 0, 1, 1, 0, 0, 1, 0]
    s2 = [1, 0, 1, 0, 0, 0, 1, 0]  # Differ at position 3

    primes = [11, 23, 47, 97, 199, 401, 809, 1601]

    print(f"Vector length: {n}")
    print(f"s1 = {s1}")
    print(f"s2 = {s2}")
    print()
    print(f"{'Field GF(p)':<12} {'Collisions':>10} {'Bound (n-1)':>11} "
          f"{'Error Rate':>10} {'Bound Rate':>10}")
    print("-" * 60)

    for p in primes:
        collisions = sum(1 for x in range(p)
                         if eval_vecpoly(s1, x, p) == eval_vecpoly(s2, x, p))
        bound = n - 1
        err_rate = collisions / p
        bound_rate = bound / p
        print(f"GF({p:>4})    {collisions:>10} {bound:>11} "
              f"{err_rate:>10.6f} {bound_rate:>10.6f}")

    print()
    print("As |K| grows, error probability -> 0 while the bound (n-1)/|K| -> 0.")
    print("This is the algebraic foundation of efficient randomized verification.")
    print()


# ============================================================================
# Main
# ============================================================================

if __name__ == "__main__":
    random.seed(42)
    demo_fingerprinting()
    demo_schwartz_zippel()
    demo_circuit_pit()
    demo_error_vs_field_size()


#!/usr/bin/env python3
"""
Visualizations for Algebraic Fingerprinting and PIT Research

Generates publication-quality figures showing:
1. Schwartz-Zippel zero-set structure
2. Fingerprint error probability scaling
3. Circuit complexity vs zero-set size
4. Streaming verification performance
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import base64
import io
import os


def save_figure(fig, filename):
    """Save figure as PNG and return base64 encoding."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight',
                facecolor='white', edgecolor='none')
    buf.seek(0)
    b64 = base64.b64encode(buf.read()).decode('utf-8')
    fig.savefig(filename, dpi=150, bbox_inches='tight',
                facecolor='white', edgecolor='none')
    plt.close(fig)
    return f"data:image/png;base64,{b64}"


def viz_zero_set():
    """Visualize zero sets of polynomials over a finite field."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    p = 17  # Field size

    polynomials = [
        ("x + y = 0", lambda x, y: (x + y) % p, 1),
        ("x·y = 0", lambda x, y: (x * y) % p, 2),
        ("x² + y² - 1 = 0", lambda x, y: (x**2 + y**2 - 1) % p, 2),
    ]

    for ax, (title, f, deg) in zip(axes, polynomials):
        zeros_x, zeros_y = [], []
        nonzeros_x, nonzeros_y = [], []

        for x in range(p):
            for y in range(p):
                if f(x, y) == 0:
                    zeros_x.append(x)
                    zeros_y.append(y)
                else:
                    nonzeros_x.append(x)
                    nonzeros_y.append(y)

        ax.scatter(nonzeros_x, nonzeros_y, c='#e8e8e8', s=8, alpha=0.5, zorder=1)
        ax.scatter(zeros_x, zeros_y, c='#e74c3c', s=25, alpha=0.9, zorder=2,
                   edgecolors='darkred', linewidths=0.5)

        num_zeros = len(zeros_x)
        bound = deg * p
        ax.set_title(f'{title}\n{num_zeros} zeros ≤ {bound} (d·|K|)',
                     fontsize=11, fontweight='bold')
        ax.set_xlabel(f'x ∈ GF({p})')
        ax.set_ylabel(f'y ∈ GF({p})')
        ax.set_aspect('equal')

    fig.suptitle('Schwartz–Zippel Zero Sets over GF(17)²',
                 fontsize=14, fontweight='bold', y=1.02)
    plt.tight_layout()
    return save_figure(fig, 'viz_zero_sets.png')


def viz_error_scaling():
    """Visualize fingerprint error probability vs field size."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    # Left: Error vs field size for different vector lengths
    primes = [7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67,
              71, 73, 79, 83, 89, 97, 101, 127, 151, 199, 251, 307, 401, 503]
    vector_lengths = [4, 8, 16, 32]
    colors = ['#e74c3c', '#3498db', '#2ecc71', '#f39c12']

    for n, color in zip(vector_lengths, colors):
        errors = [(n - 1) / p for p in primes]
        ax1.semilogy(primes, errors, 'o-', color=color, label=f'n = {n}',
                     markersize=4, linewidth=1.5)

    ax1.set_xlabel('Field Size |K|', fontsize=12)
    ax1.set_ylabel('Error Probability Bound', fontsize=12)
    ax1.set_title('Fingerprint Error vs Field Size', fontsize=13, fontweight='bold')
    ax1.legend(title='Vector Length')
    ax1.grid(True, alpha=0.3)
    ax1.axhline(y=0.01, color='gray', linestyle='--', alpha=0.5, label='1% threshold')

    # Right: Error amplification via repetition
    p = 101
    n = 16
    base_error = (n - 1) / p
    trials = np.arange(1, 21)
    amplified_errors = base_error ** trials

    ax2.semilogy(trials, amplified_errors, 'o-', color='#9b59b6',
                 markersize=6, linewidth=2)
    ax2.fill_between(trials, amplified_errors, alpha=0.1, color='#9b59b6')
    ax2.set_xlabel('Number of Independent Trials', fontsize=12)
    ax2.set_ylabel('Error Probability', fontsize=12)
    ax2.set_title(f'Error Amplification (n={n}, |K|={p})', fontsize=13, fontweight='bold')
    ax2.grid(True, alpha=0.3)
    ax2.axhline(y=1e-10, color='red', linestyle='--', alpha=0.5)
    ax2.annotate('10⁻¹⁰', xy=(15, 1e-10), fontsize=10, color='red')

    plt.tight_layout()
    return save_figure(fig, 'viz_error_scaling.png')


def viz_circuit_complexity():
    """Visualize circuit complexity vs zero-set structure."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    # Left: Degree vs multiplication gates
    mul_gates = np.arange(0, 8)
    degree_bound = 2 ** mul_gates  # Exponential bound

    ax1.bar(mul_gates, degree_bound, color='#3498db', alpha=0.7, edgecolor='#2c3e50')
    ax1.set_xlabel('Number of Multiplication Gates', fontsize=12)
    ax1.set_ylabel('Degree Upper Bound', fontsize=12)
    ax1.set_title('Circuit Degree ≤ 2^(mul gates)', fontsize=13, fontweight='bold')
    ax1.set_yscale('log')
    ax1.grid(True, alpha=0.3, axis='y')

    for i, d in enumerate(degree_bound):
        ax1.text(i, d * 1.3, str(d), ha='center', fontsize=9, fontweight='bold')

    # Right: Zero-set fraction vs degree for different field sizes
    field_sizes = [7, 11, 23, 47, 97, 199]
    degrees = np.arange(1, 20)

    for p in field_sizes:
        fractions = np.minimum(degrees / p, 1.0)
        ax2.plot(degrees, fractions, 'o-', label=f'|K| = {p}', markersize=3)

    ax2.set_xlabel('Polynomial Degree', fontsize=12)
    ax2.set_ylabel('Max Zero Fraction (d/|K|)', fontsize=12)
    ax2.set_title('Zero-Set Density Bound', fontsize=13, fontweight='bold')
    ax2.legend(title='Field Size')
    ax2.grid(True, alpha=0.3)
    ax2.axhline(y=0.5, color='red', linestyle='--', alpha=0.3)
    ax2.set_ylim(0, 1.05)

    plt.tight_layout()
    return save_figure(fig, 'viz_circuit_complexity.png')


def viz_streaming_performance():
    """Visualize streaming verification performance characteristics."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    # Left: Memory comparison
    n_values = np.logspace(1, 7, 30).astype(int)
    naive_memory = n_values  # Store full data
    fingerprint_memory = np.full_like(n_values, 8, dtype=float)  # 64-bit fingerprint

    ax1.loglog(n_values, naive_memory, 'o-', color='#e74c3c', label='Naive (store all)',
               markersize=4, linewidth=2)
    ax1.loglog(n_values, fingerprint_memory, 's-', color='#2ecc71',
               label='Algebraic fingerprint', markersize=4, linewidth=2)
    ax1.fill_between(n_values, fingerprint_memory, naive_memory,
                     alpha=0.1, color='#2ecc71')
    ax1.set_xlabel('Data Length (bytes)', fontsize=12)
    ax1.set_ylabel('Memory Required (bytes)', fontsize=12)
    ax1.set_title('Memory: Naive vs Fingerprint', fontsize=13, fontweight='bold')
    ax1.legend()
    ax1.grid(True, alpha=0.3)

    # Right: Communication complexity for equality testing
    data_sizes = np.logspace(1, 6, 20).astype(int)
    deterministic_bits = data_sizes * 8  # Must send all data
    fingerprint_bits = np.full_like(data_sizes, 64, dtype=float)  # One field element
    k_trials = 5
    amplified_bits = fingerprint_bits * k_trials

    ax2.loglog(data_sizes, deterministic_bits, 'o-', color='#e74c3c',
               label='Deterministic', markersize=4, linewidth=2)
    ax2.loglog(data_sizes, amplified_bits, 's-', color='#2ecc71',
               label=f'Fingerprint ({k_trials} trials)', markersize=4, linewidth=2)
    ax2.fill_between(data_sizes, amplified_bits, deterministic_bits,
                     alpha=0.1, color='#2ecc71')
    ax2.set_xlabel('Data Size (elements)', fontsize=12)
    ax2.set_ylabel('Communication (bits)', fontsize=12)
    ax2.set_title('Communication: Deterministic vs Randomized', fontsize=13, fontweight='bold')
    ax2.legend()
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    return save_figure(fig, 'viz_streaming_performance.png')


if __name__ == "__main__":
    print("Generating visualizations...")
    viz_zero_set()
    print("  ✓ Zero set visualization")
    viz_error_scaling()
    print("  ✓ Error scaling visualization")
    viz_circuit_complexity()
    print("  ✓ Circuit complexity visualization")
    viz_streaming_performance()
    print("  ✓ Streaming performance visualization")
    print("All visualizations saved.")
