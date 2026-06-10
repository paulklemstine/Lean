#!/usr/bin/env python3
"""
Applications of Hadamard Matrices

Demonstrates real-world applications:
1. Walsh-Hadamard Transform for signal processing
2. Error-correcting codes (Reed-Muller / Hadamard codes)
3. Compressed sensing measurement matrices
4. Spread-spectrum communication (CDMA)
5. Combinatorial design construction
"""

import numpy as np
from typing import List, Tuple, Dict


# ──────────────────────────────────────────────────────────────────────
# Utility: Sylvester-Hadamard matrix
# ──────────────────────────────────────────────────────────────────────

def hadamard(k: int) -> np.ndarray:
    """2^k × 2^k Sylvester-Hadamard matrix."""
    H = np.array([[1]], dtype=float)
    for _ in range(k):
        H = np.block([[H, H], [H, -H]])
    return H


# ══════════════════════════════════════════════════════════════════════
# 1. Walsh-Hadamard Transform
# ══════════════════════════════════════════════════════════════════════

def walsh_hadamard_transform(x: np.ndarray) -> np.ndarray:
    """Compute the normalized Walsh-Hadamard transform.

    WHT(x) = (1/√n) H_k x, where n = 2^k = len(x).

    Properties:
    - Energy preservation: ||WHT(x)||² = ||x||²
    - Self-inverse: WHT(WHT(x)) = x
    - O(n log n) via fast algorithm
    """
    n = len(x)
    k = int(np.log2(n))
    assert 2**k == n, "Length must be a power of 2"
    H = hadamard(k) / np.sqrt(n)
    return H @ x


def fast_walsh_hadamard(x: np.ndarray) -> np.ndarray:
    """O(n log n) fast Walsh-Hadamard transform (in-place butterfly).

    This is the recursive doubling algorithm mirroring the Sylvester construction.
    """
    y = x.astype(float).copy()
    n = len(y)
    h = 1
    while h < n:
        for i in range(0, n, 2 * h):
            for j in range(i, i + h):
                a = y[j]
                b = y[j + h]
                y[j] = a + b
                y[j + h] = a - b
        h *= 2
    return y / np.sqrt(n)


# ══════════════════════════════════════════════════════════════════════
# 2. Hadamard Error-Correcting Codes
# ══════════════════════════════════════════════════════════════════════

def hadamard_code(k: int) -> np.ndarray:
    """Generate the [2^k, k+1, 2^{k-1}] Hadamard code.

    Takes all 2^k rows of the Sylvester matrix (and their negations),
    converts ±1 to 0/1, giving 2^{k+1} codewords of length 2^k
    with minimum Hamming distance 2^{k-1}.

    This is the first-order Reed-Muller code RM(1, k).
    """
    n = 2**k
    H = hadamard(k).astype(int)
    # Include both rows and negated rows
    codewords = np.vstack([H, -H])
    # Convert ±1 to 0/1: +1 → 0, -1 → 1
    bits = ((1 - codewords) // 2).astype(int)
    return bits


def decode_hadamard(received: np.ndarray, k: int) -> int:
    """Maximum-likelihood decoding for Hadamard code.

    Given a received binary word (possibly corrupted), find the closest
    codeword by computing correlation with all rows of H.
    Can correct up to 2^{k-2} - 1 errors.
    """
    n = 2**k
    H = hadamard(k).astype(int)
    # Convert bits to ±1
    signal = 1 - 2 * received.astype(int)
    # Compute correlations with all rows
    correlations = H @ signal
    best_row = np.argmax(np.abs(correlations))
    best_sign = np.sign(correlations[best_row])
    return best_row if best_sign > 0 else best_row + n


# ══════════════════════════════════════════════════════════════════════
# 3. Compressed Sensing
# ══════════════════════════════════════════════════════════════════════

def compressed_sensing_demo(n: int = 64, m: int = 16, s: int = 3):
    """Demonstrate compressed sensing with Hadamard measurement matrix.

    Args:
        n: signal length (must be power of 2)
        m: number of measurements
        s: sparsity level

    The Hadamard matrix provides a structured measurement matrix with
    guaranteed RIP (Restricted Isometry Property) when rows are
    randomly subsampled.
    """
    k = int(np.log2(n))
    H = hadamard(k) / np.sqrt(n)

    # Create sparse signal
    x = np.zeros(n)
    support = np.random.choice(n, s, replace=False)
    x[support] = np.random.randn(s)

    # Random row selection for measurement
    rows = np.sort(np.random.choice(n, m, replace=False))
    A = H[rows, :]

    # Measurements
    y = A @ x

    # Simple recovery via OMP (Orthogonal Matching Pursuit)
    x_hat = np.zeros(n)
    residual = y.copy()
    support_est = []

    for _ in range(s):
        correlations = np.abs(A.T @ residual)
        idx = np.argmax(correlations)
        support_est.append(idx)
        A_s = A[:, support_est]
        coeffs = np.linalg.lstsq(A_s, y, rcond=None)[0]
        x_hat_partial = np.zeros(n)
        for i, idx in enumerate(support_est):
            x_hat_partial[idx] = coeffs[i]
        residual = y - A @ x_hat_partial
        x_hat = x_hat_partial

    return {
        "original_support": sorted(support),
        "recovered_support": sorted(support_est),
        "recovery_error": np.linalg.norm(x - x_hat) / max(np.linalg.norm(x), 1e-10),
        "support_match": set(support) == set(support_est),
    }


# ══════════════════════════════════════════════════════════════════════
# 4. CDMA Spreading Codes
# ══════════════════════════════════════════════════════════════════════

def cdma_demo(k: int = 3, num_users: int = 4, snr_db: float = 10.0):
    """Demonstrate CDMA using Walsh-Hadamard spreading codes.

    Each user gets a row of the Hadamard matrix as their spreading code.
    Multiple users transmit simultaneously; the receiver separates them
    using the orthogonality of Hadamard rows.

    Args:
        k: Hadamard order parameter (n = 2^k chips per symbol)
        num_users: number of simultaneous users (≤ 2^k)
        snr_db: signal-to-noise ratio in dB
    """
    n = 2**k  # Spreading factor
    H = hadamard(k).astype(int)

    assert num_users <= n, f"At most {n} users supported"

    # Each user's data: ±1 symbols
    num_symbols = 10
    user_data = np.random.choice([-1, 1], size=(num_users, num_symbols))

    # Spreading codes (rows of H)
    codes = H[:num_users, :]

    # Transmit: each user spreads their data
    # Combined signal = sum of all users' spread signals
    combined = np.zeros((n, num_symbols))
    for u in range(num_users):
        for t in range(num_symbols):
            combined[:, t] += user_data[u, t] * codes[u, :]

    # Add noise
    noise_power = n * num_users * 10**(-snr_db / 10)
    noise = np.sqrt(noise_power) * np.random.randn(n, num_symbols)
    received = combined + noise

    # Receive: correlate with each user's code
    decoded = np.zeros((num_users, num_symbols), dtype=int)
    for u in range(num_users):
        for t in range(num_symbols):
            correlation = np.dot(codes[u, :], received[:, t]) / n
            decoded[u, t] = 1 if correlation > 0 else -1

    # Compute BER
    errors = np.sum(decoded != user_data)
    total_bits = num_users * num_symbols
    ber = errors / total_bits

    return {
        "users": num_users,
        "spreading_factor": n,
        "snr_db": snr_db,
        "bit_error_rate": ber,
        "total_errors": errors,
        "total_bits": total_bits,
    }


# ══════════════════════════════════════════════════════════════════════
# 5. Combinatorial Design Construction
# ══════════════════════════════════════════════════════════════════════

def bibd_from_hadamard(k: int) -> Dict:
    """Construct a symmetric BIBD from a Sylvester-Hadamard matrix.

    For order n = 2^k, this produces a 2-(n-1, n/2-1, n/4-1) design.
    """
    n = 2**k
    H = hadamard(k).astype(int)

    # Normalize: first row/column all +1
    Hn = H.copy()
    for j in range(n):
        if Hn[0, j] == -1:
            Hn[:, j] *= -1
    for i in range(n):
        if Hn[i, 0] == -1:
            Hn[i, :] *= -1

    # Extract core and convert
    core = Hn[1:, 1:]
    inc = ((core + 1) // 2).astype(int)

    v = n - 1
    t = n // 4
    expected_k = 2 * t - 1
    expected_lam = t - 1

    # Verify parameters
    block_sizes = [int(inc[:, j].sum()) for j in range(v)]
    replications = [int(inc[i, :].sum()) for i in range(v)]
    pair_lambdas = []
    for i in range(v):
        for j in range(i + 1, v):
            pair_lambdas.append(int(np.sum(inc[i] * inc[j])))

    return {
        "v": v,
        "k": expected_k,
        "lambda": expected_lam,
        "block_sizes": list(set(block_sizes)),
        "replications": list(set(replications)),
        "pair_lambdas": list(set(pair_lambdas)),
        "incidence_matrix": inc,
        "verified": (set(block_sizes) == {expected_k} and
                     set(replications) == {expected_k} and
                     set(pair_lambdas) == {expected_lam}),
    }


# ══════════════════════════════════════════════════════════════════════
# Main demo
# ══════════════════════════════════════════════════════════════════════

if __name__ == "__main__":
    np.random.seed(42)

    print("=" * 70)
    print("  HADAMARD MATRIX APPLICATIONS")
    print("=" * 70)

    # 1. Walsh-Hadamard Transform
    print("\n1. Walsh-Hadamard Transform")
    print("-" * 50)
    n = 16
    x = np.random.randn(n)
    y = walsh_hadamard_transform(x)
    y_fast = fast_walsh_hadamard(x)
    print(f"   Signal length: {n}")
    print(f"   ||x||² = {np.sum(x**2):.6f}")
    print(f"   ||WHT(x)||² = {np.sum(y**2):.6f}")
    print(f"   Energy preserved: {np.isclose(np.sum(x**2), np.sum(y**2))}")
    print(f"   Fast WHT matches naive: {np.allclose(y, y_fast)}")
    # Self-inverse
    x_recovered = walsh_hadamard_transform(y)
    print(f"   WHT(WHT(x)) ≈ x: {np.allclose(x, x_recovered)}")

    # 2. Error-correcting codes
    print("\n2. Hadamard Error-Correcting Code")
    print("-" * 50)
    for k in range(2, 5):
        code = hadamard_code(k)
        n_cw = code.shape[0]
        n_len = code.shape[1]
        min_dist = n_len
        for i in range(n_cw):
            for j in range(i + 1, n_cw):
                d = np.sum(code[i] != code[j])
                min_dist = min(min_dist, d)
        print(f"   k={k}: [{n_len}, {k+1}, {min_dist}] code with {n_cw} codewords")

    # Test error correction
    k = 4
    code = hadamard_code(k)
    original = code[5]  # pick codeword 5
    corrupted = original.copy()
    # Introduce 3 errors (can correct up to 2^{k-2}-1 = 3)
    error_pos = np.random.choice(16, 3, replace=False)
    corrupted[error_pos] = 1 - corrupted[error_pos]
    decoded = decode_hadamard(corrupted, k)
    print(f"\n   Decoding test (k={k}):")
    print(f"   Original codeword index: 5")
    print(f"   Errors introduced: {len(error_pos)} at positions {error_pos}")
    print(f"   Decoded index: {decoded}")
    print(f"   Correct: {decoded == 5}")

    # 3. Compressed sensing
    print("\n3. Compressed Sensing")
    print("-" * 50)
    for s in [2, 3, 4]:
        result = compressed_sensing_demo(n=64, m=20, s=s)
        print(f"   Sparsity={s}: support_match={result['support_match']}, "
              f"error={result['recovery_error']:.6f}")

    # 4. CDMA
    print("\n4. CDMA Spreading")
    print("-" * 50)
    for snr in [5, 10, 15, 20]:
        result = cdma_demo(k=3, num_users=4, snr_db=snr)
        print(f"   SNR={snr:2d}dB: BER={result['bit_error_rate']:.4f} "
              f"({result['total_errors']}/{result['total_bits']} errors)")

    # 5. Combinatorial designs
    print("\n5. Combinatorial Designs from Hadamard")
    print("-" * 50)
    for k in range(2, 6):
        design = bibd_from_hadamard(k)
        n = 2**k
        t = n // 4
        print(f"   Order {n}: 2-({design['v']}, {design['k']}, {design['lambda']}) "
              f"design — verified: {design['verified']}")

    print("\n" + "=" * 70)
    print("  All applications demonstrated successfully.")
    print("=" * 70)


#!/usr/bin/env python3
"""
Hadamard Matrix Existence Engine — Interactive Demo

Demonstrates the Hadamard existence calculus:
- Certified construction of Hadamard matrices from generators
- Verification of orthogonality and ±1 properties
- Coding theory: Hamming distances between rows
- Design theory: row intersection numbers
- Generator completeness testing up to a bound

Usage:
    python demo.py [--bound B]  (default B=100)
"""

import numpy as np
import sys
from typing import Optional, List, Tuple


# ──────────────────────────────────────────────────────────────────────
# Core Hadamard constructions
# ──────────────────────────────────────────────────────────────────────

def sylvester_hadamard(k: int) -> np.ndarray:
    """Construct the 2^k × 2^k Sylvester-Hadamard matrix by recursive doubling.

    H_0 = [1]
    H_{k+1} = [[H_k, H_k], [H_k, -H_k]]
    """
    H = np.array([[1]])
    for _ in range(k):
        H = np.block([[H, H], [H, -H]])
    return H


def kronecker_hadamard(H1: np.ndarray, H2: np.ndarray) -> np.ndarray:
    """Tensor (Kronecker) product of two Hadamard matrices."""
    return np.kron(H1, H2)


def verify_hadamard(H: np.ndarray) -> bool:
    """Verify that H is a valid Hadamard matrix:
    - All entries are ±1
    - H @ H.T = n * I
    """
    n = H.shape[0]
    if H.shape != (n, n):
        return False
    if not np.all(np.abs(H) == 1):
        return False
    product = H @ H.T
    expected = n * np.eye(n, dtype=int)
    return np.array_equal(product, expected)


# ──────────────────────────────────────────────────────────────────────
# Construction engine with provenance tracking
# ──────────────────────────────────────────────────────────────────────

class HadamardCertificate:
    """A certified Hadamard matrix with provenance."""
    def __init__(self, matrix: np.ndarray, provenance: List[str]):
        self.matrix = matrix
        self.provenance = provenance
        self.order = matrix.shape[0]

    def __repr__(self):
        return f"HadamardCertificate(order={self.order}, provenance={self.provenance})"


def factorize_as_power_of_two(n: int) -> Optional[int]:
    """If n = 2^k, return k; else None."""
    if n < 1:
        return None
    k = 0
    m = n
    while m > 1:
        if m % 2 != 0:
            return None
        m //= 2
        k += 1
    return k


def build_certificate(n: int) -> Optional[HadamardCertificate]:
    """Attempt to construct a Hadamard matrix of order n from certified generators.

    Strategy:
    1. n = 1: trivial seed
    2. n = 2: base Hadamard matrix
    3. n = 2^k: Sylvester construction
    4. n = m * p where both m, p have certificates: tensor product
    5. Otherwise: return None (order not generated)
    """
    if n == 1:
        return HadamardCertificate(np.array([[1]]), ["base1"])
    if n == 2:
        return HadamardCertificate(np.array([[1, 1], [1, -1]]), ["base2"])

    # Check if power of 2
    k = factorize_as_power_of_two(n)
    if k is not None:
        H = sylvester_hadamard(k)
        return HadamardCertificate(H, [f"sylvester(2^{k})"])

    # Try to factor n and build from tensor products
    for d in range(2, int(n**0.5) + 1):
        if n % d == 0:
            cert1 = build_certificate(d)
            cert2 = build_certificate(n // d)
            if cert1 is not None and cert2 is not None:
                H = kronecker_hadamard(cert1.matrix, cert2.matrix)
                prov = [f"tensor({d} × {n // d})"] + cert1.provenance + cert2.provenance
                return HadamardCertificate(H, prov)

    return None


# ──────────────────────────────────────────────────────────────────────
# Coding theory analysis
# ──────────────────────────────────────────────────────────────────────

def sign_to_bits(row: np.ndarray) -> np.ndarray:
    """Convert ±1 vector to binary: +1 → 0, -1 → 1."""
    return ((1 - row) // 2).astype(int)


def hamming_distance(x: np.ndarray, y: np.ndarray) -> int:
    """Compute Hamming distance between two binary vectors."""
    return int(np.sum(x != y))


def analyze_code(H: np.ndarray):
    """Analyze the binary code formed by rows of H."""
    n = H.shape[0]
    bits = np.array([sign_to_bits(H[i]) for i in range(n)])
    distances = []
    for i in range(n):
        for j in range(i + 1, n):
            d = hamming_distance(bits[i], bits[j])
            distances.append(d)
    return distances


# ──────────────────────────────────────────────────────────────────────
# Design theory analysis
# ──────────────────────────────────────────────────────────────────────

def analyze_design(H: np.ndarray):
    """Analyze the combinatorial design from a normalized Hadamard matrix.

    Normalize first row/column to all 1s, then:
    - Delete first row/column
    - Convert 1 → 1, -1 → 0
    This gives the incidence matrix of a symmetric BIBD.
    """
    n = H.shape[0]

    # Normalize: flip columns where first row is -1, then rows where first col is -1
    H_norm = H.copy()
    for j in range(n):
        if H_norm[0, j] == -1:
            H_norm[:, j] *= -1
    for i in range(n):
        if H_norm[i, 0] == -1:
            H_norm[i, :] *= -1

    # Delete first row and column
    core = H_norm[1:, 1:]
    # Convert to binary incidence
    inc = ((core + 1) // 2).astype(int)

    v = n - 1
    # Block sizes (column sums)
    block_sizes = inc.sum(axis=0)
    # Point replications (row sums)
    point_reps = inc.sum(axis=1)
    # Pairwise intersections
    intersections = []
    for i in range(v):
        for j in range(i + 1, v):
            lam = int(np.sum(inc[i] * inc[j]))
            intersections.append(lam)

    return {
        "v": v,
        "k_values": np.unique(block_sizes).tolist(),
        "r_values": np.unique(point_reps).tolist(),
        "lambda_values": np.unique(intersections).tolist() if intersections else [],
        "incidence_matrix": inc,
    }


# ──────────────────────────────────────────────────────────────────────
# Main demo
# ──────────────────────────────────────────────────────────────────────

def main():
    B = 100
    if "--bound" in sys.argv:
        idx = sys.argv.index("--bound")
        B = int(sys.argv[idx + 1])

    print("=" * 72)
    print("  HADAMARD MATRIX EXISTENCE ENGINE — DEMO")
    print("=" * 72)
    print()

    # ── Part 1: Enumerate orders ──────────────────────────────────────
    print(f"Part 1: Hadamard order analysis for n ≤ {B}")
    print("-" * 60)

    admissible = []
    constructed = []
    not_constructed = []

    for n in range(1, B + 1):
        if n == 1 or n == 2:
            cert = build_certificate(n)
            if cert:
                admissible.append(n)
                constructed.append((n, cert))
        elif n % 4 == 0:
            admissible.append(n)
            cert = build_certificate(n)
            if cert:
                constructed.append((n, cert))
            else:
                not_constructed.append(n)
        # else: ruled out by divisibility (4 ∤ n and n > 2)

    print(f"  Admissible orders (n=1,2 or 4|n):  {len(admissible)}")
    print(f"  Successfully constructed:           {len(constructed)}")
    print(f"  Not generated by our calculus:      {len(not_constructed)}")
    print()

    if not_constructed:
        print(f"  Orders not generated: {not_constructed}")
        print()

    # ── Part 2: Construction provenance ───────────────────────────────
    print("Part 2: Construction provenance (selected orders)")
    print("-" * 60)

    for n, cert in constructed[:15]:
        print(f"  n = {n:3d}:  {' → '.join(cert.provenance)}")
    if len(constructed) > 15:
        print(f"  ... ({len(constructed) - 15} more)")
    print()

    # ── Part 3: Verification ──────────────────────────────────────────
    print("Part 3: Matrix verification")
    print("-" * 60)

    for k in range(1, 5):
        n = 2**k
        H = sylvester_hadamard(k)
        ok = verify_hadamard(H)
        print(f"  Sylvester H_{k} (order {n}): valid = {ok}")
    print()

    # Display H_2
    H2 = sylvester_hadamard(2)
    print("  Sylvester H_2 (order 4):")
    for row in H2:
        print("    [" + " ".join(f"{x:+d}" for x in row) + "]")
    print()

    H3 = sylvester_hadamard(3)
    print("  Sylvester H_3 (order 8):")
    for row in H3:
        print("    [" + " ".join(f"{x:+d}" for x in row) + "]")
    print()

    # ── Part 4: Coding theory ─────────────────────────────────────────
    print("Part 4: Coding theory — Hamming distances between rows")
    print("-" * 60)

    for k in range(1, 5):
        n = 2**k
        H = sylvester_hadamard(k)
        distances = analyze_code(H)
        unique_d = set(distances)
        print(f"  Order {n}: Hamming distances = {unique_d}  (expected: {{{n//2}}})")
    print()

    # ── Part 5: Design theory ─────────────────────────────────────────
    print("Part 5: Design theory — BIBD parameters")
    print("-" * 60)

    for k in range(2, 5):
        n = 2**k
        H = sylvester_hadamard(k)
        design = analyze_design(H)
        t = n // 4
        print(f"  Order {n} → 2-({design['v']}, {design['k_values']}, {design['lambda_values']}) design")
        print(f"    Expected: 2-({4*t-1}, {2*t-1}, {t-1})")
    print()

    # ── Part 6: Generator density ─────────────────────────────────────
    print("Part 6: Generator density")
    print("-" * 60)

    multiples_of_4 = [n for n in range(4, B + 1, 4)]
    generated = [n for n in multiples_of_4 if build_certificate(n) is not None]
    density = len(generated) / len(multiples_of_4) if multiples_of_4 else 0
    print(f"  Multiples of 4 up to {B}: {len(multiples_of_4)}")
    print(f"  Generated by our calculus: {len(generated)}")
    print(f"  Empirical density: {density:.4f}")
    print(f"  Generated: {generated}")
    print(f"  Not generated: {[n for n in multiples_of_4 if n not in generated]}")
    print()

    # ── Part 7: Walsh spectrum ────────────────────────────────────────
    print("Part 7: Walsh transform energy preservation")
    print("-" * 60)

    for k in range(1, 5):
        n = 2**k
        H = sylvester_hadamard(k)
        x = np.random.randn(n)
        W = H / np.sqrt(n)  # Normalized Walsh-Hadamard transform
        y = W @ x
        energy_in = np.sum(x**2)
        energy_out = np.sum(y**2)
        print(f"  k={k} (n={n}): ||x||² = {energy_in:.6f}, ||Wx||² = {energy_out:.6f}, "
              f"ratio = {energy_out/energy_in:.10f}")
    print()

    print("=" * 72)
    print("  Demo complete.")
    print("=" * 72)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""Generate PACKAGE.json from all deliverables."""
import json
import os

def read_file(path):
    with open(path, 'r') as f:
        return f.read()

# Read all components
article = read_file('ARTICLE.md')
research_paper = read_file('RESEARCH_PAPER.md')
future_directions = read_file('FUTURE_DIRECTIONS.md')

# Read Lean proofs
lean_files = [
    'Catalog/Algebra/Hadamard/Defs.lean',
    'Catalog/Algebra/Hadamard/Basic.lean',
    'Catalog/Algebra/Hadamard/Examples.lean',
    'Catalog/Algebra/Hadamard/Constructions.lean',
    'Catalog/Algebra/Hadamard/Coding.lean',
    'Catalog/Algebra/Hadamard/Obstruction.lean',
    'Catalog/Algebra/Hadamard/Design.lean',
]
lean_proofs = ""
for f in lean_files:
    if os.path.exists(f):
        lean_proofs += f"-- ═══ {f} ═══\n\n"
        lean_proofs += read_file(f)
        lean_proofs += "\n\n"

# Read Python files
demo_code = read_file('demo.py')
algorithms_code = read_file('algorithms.py')
applications_code = read_file('applications.py')
viz_hadamard = read_file('visualize_hadamard.py')
viz_existence = read_file('visualize_existence.py')
viz_code = read_file('visualize_code.py')

# Read HTML
html_explorer = read_file('interactive_hadamard.html')
html_kronecker = read_file('interactive_kronecker.html')

package = {
    "title": "Hadamard Existence by Algebraic Generation",
    "domain": "Algebra / Combinatorics",
    "article": article,
    "research_paper": research_paper,
    "future_directions": future_directions,
    "demos": [
        {
            "name": "Hadamard Existence Engine Demo",
            "code": demo_code
        },
        {
            "name": "Applications of Hadamard Matrices",
            "code": applications_code
        }
    ],
    "algorithms": [
        {
            "name": "Hadamard Construction Engine",
            "pseudocode": """Algorithm: BuildHadamardCertificate(n)
Input: positive integer n
Output: Hadamard matrix of order n, or FAIL

1. If n = 1: return [1]
2. If n = 2: return [[1,1],[1,-1]]
3. If n > 2 and 4 ∤ n: return FAIL (arithmetic obstruction)
4. If n = 2^k: return Sylvester(k) via recursive doubling
5. If n = q+1, q ≡ 3 (mod 4) prime: return Paley_I(q)
6. If n = 2(q+1), q ≡ 1 (mod 4) prime: return Paley_II(q)
7. For each factorization n = d × (n/d):
     cert1 ← BuildHadamardCertificate(d)
     cert2 ← BuildHadamardCertificate(n/d)
     if both succeed: return Kronecker(cert1, cert2)
8. return FAIL

Complexity: O(n² log n) for direct constructions, O(n³) worst case.
Correctness: Proved sound by hadamardSeed_implies_order theorem.""",
            "code": algorithms_code
        }
    ],
    "visualizations": [
        {
            "name": "Hadamard Matrix Patterns",
            "code": viz_hadamard,
            "description": "Visualizes the self-similar ±1 patterns of Sylvester-Hadamard matrices at orders 2, 4, 8, and 16, revealing the fractal structure of the recursive doubling construction."
        },
        {
            "name": "Hadamard Existence Landscape",
            "code": viz_existence,
            "description": "Shows which orders ≤ 200 have certified Hadamard matrices under our construction calculus (Sylvester + Paley + tensor), compared to all admissible orders. The gap reveals where the conjecture remains open."
        },
        {
            "name": "Hadamard Code Distance Properties",
            "code": viz_code,
            "description": "Visualizes the orthogonality (HHᵀ) and equidistant code property (all pairwise Hamming distances = n/2) of Hadamard matrices at different orders."
        }
    ],
    "interactive_demos": [
        {
            "name": "Interactive Hadamard Matrix Explorer",
            "html": html_explorer,
            "description": "Explore Sylvester-Hadamard matrices interactively. Adjust the order parameter k to see the ±1 pattern, verify orthogonality, and observe the equidistant code property."
        },
        {
            "name": "Kronecker Product Visualizer",
            "html": html_kronecker,
            "description": "Visualize how the tensor (Kronecker) product of two Hadamard matrices produces a larger Hadamard matrix, demonstrating the multiplicative closure theorem."
        }
    ],
    "lean_proofs": lean_proofs
}

with open('PACKAGE.json', 'w') as f:
    json.dump(package, f, indent=2, ensure_ascii=False)

print("PACKAGE.json generated successfully")
print(f"  Article: {len(article)} chars")
print(f"  Research paper: {len(research_paper)} chars")
print(f"  Future directions: {len(future_directions)} chars")
print(f"  Lean proofs: {len(lean_proofs)} chars")
print(f"  Demos: {len(package['demos'])}")
print(f"  Algorithms: {len(package['algorithms'])}")
print(f"  Visualizations: {len(package['visualizations'])}")
print(f"  Interactive demos: {len(package['interactive_demos'])}")


#!/usr/bin/env python3
"""
Visualization 3: Hadamard Code Distance Properties

Visualizes the Hamming distance distribution between codewords of the
Hadamard code, showing the equidistance property: all pairs of distinct
rows have Hamming distance exactly n/2. This is the visual proof of the
coding-theory bridge theorem.
"""
import numpy as np
import matplotlib.pyplot as plt

def hadamard(k):
    H = np.array([[1]])
    for _ in range(k):
        H = np.block([[H, H], [H, -H]])
    return H

fig, axes = plt.subplots(2, 3, figsize=(15, 9))

for idx, k in enumerate([2, 3, 4]):
    n = 2**k
    H = hadamard(k).astype(int)

    # Compute pairwise dot products (should be n on diagonal, 0 off-diagonal)
    gram = H @ H.T

    ax1 = axes[0, idx]
    im = ax1.imshow(gram, cmap='RdBu_r', vmin=-n, vmax=n, interpolation='nearest')
    ax1.set_title(f'H·Hᵀ (order {n})', fontsize=12, fontweight='bold')
    ax1.set_xlabel('Row j')
    ax1.set_ylabel('Row i')
    plt.colorbar(im, ax=ax1, shrink=0.8)

    # Hamming distance matrix
    bits = ((1 - H) // 2).astype(int)
    dist_matrix = np.zeros((n, n), dtype=int)
    for i in range(n):
        for j in range(n):
            dist_matrix[i, j] = np.sum(bits[i] != bits[j])

    ax2 = axes[1, idx]
    im2 = ax2.imshow(dist_matrix, cmap='viridis', interpolation='nearest')
    ax2.set_title(f'Hamming Distance (order {n})', fontsize=12, fontweight='bold')
    ax2.set_xlabel('Row j')
    ax2.set_ylabel('Row i')
    plt.colorbar(im2, ax=ax2, shrink=0.8)

    # Annotate: off-diagonal should all be n/2
    off_diag = dist_matrix[np.triu_indices(n, k=1)]
    ax2.text(0.02, 0.02, f'All off-diag = {set(off_diag)}',
             transform=ax2.transAxes, fontsize=9, color='white',
             verticalalignment='bottom',
             bbox=dict(boxstyle='round', facecolor='black', alpha=0.5))

fig.suptitle('Hadamard Matrices: Orthogonality and Equidistant Codes',
             fontsize=15, fontweight='bold')
plt.tight_layout()
plt.savefig('hadamard_codes.png', dpi=150, bbox_inches='tight')
print("Saved hadamard_codes.png")


#!/usr/bin/env python3
"""
Visualization 2: Hadamard Existence Landscape

Shows which orders have certified Hadamard matrices under our construction
calculus (Sylvester + Paley + tensor), compared to the admissible orders
(multiples of 4, plus 1 and 2). The gap between generated and admissible
orders reveals where the Hadamard conjecture remains unresolved.
"""
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches

def is_prime(n):
    if n < 2: return False
    if n < 4: return True
    if n % 2 == 0 or n % 3 == 0: return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i + 2) == 0: return False
        i += 6
    return True

def hadamard_matrix(k):
    H = np.array([[1]])
    for _ in range(k):
        H = np.block([[H, H], [H, -H]])
    return H

def legendre(a, p):
    a = a % p
    if a == 0: return 0
    r = pow(a, (p-1)//2, p)
    return r if r <= 1 else r - p

def paley1(q):
    if not is_prime(q) or q % 4 != 3: return None
    n = q + 1
    H = np.zeros((n,n), dtype=int)
    H[0,:] = 1; H[:,0] = 1
    for i in range(q):
        for j in range(q):
            H[i+1,j+1] = -1 if i==j else legendre(i-j, q)
    if np.array_equal(H@H.T, n*np.eye(n,dtype=int)): return H
    return None

def paley2(q):
    if not is_prime(q) or q % 4 != 1: return None
    Q = np.zeros((q,q),dtype=int)
    for i in range(q):
        for j in range(q):
            Q[i][j] = legendre(i-j,q)
    nc = q+1
    C = np.zeros((nc,nc),dtype=int)
    C[0,1:]=1; C[1:,0]=1; C[1:,1:]=Q
    I = np.eye(nc,dtype=int)
    H = np.block([[C+I, C-I],[C-I, -(C+I)]])
    if np.array_equal(H@H.T, H.shape[0]*np.eye(H.shape[0],dtype=int)): return H
    return None

# Build cache
_cache = {}
def construct(n):
    if n in _cache: return _cache[n]
    r = _construct(n)
    _cache[n] = r
    return r

def _construct(n):
    if n <= 0: return None
    if n == 1 or n == 2: return "base"
    if n > 2 and n % 4 != 0: return None
    m = n; k = 0
    while m > 1 and m % 2 == 0: m //= 2; k += 1
    if m == 1: return "sylvester"
    q = n - 1
    if is_prime(q) and q % 4 == 3 and paley1(q) is not None: return "paley1"
    if n % 2 == 0:
        q2 = n//2 - 1
        if q2 > 0 and is_prime(q2) and q2 % 4 == 1 and paley2(q2) is not None: return "paley2"
    for d in range(2, int(n**0.5)+1):
        if n % d == 0:
            c1 = construct(d); c2 = construct(n//d)
            if c1 and c2: return "tensor"
    return None

B = 200
orders = list(range(1, B+1))

inadmissible = [n for n in orders if n > 2 and n % 4 != 0]
admissible = [n for n in orders if n <= 2 or n % 4 == 0]
generated = [n for n in admissible if construct(n)]
not_generated = [n for n in admissible if not construct(n)]

# Plot
fig, ax = plt.subplots(figsize=(16, 3))

for n in inadmissible:
    ax.bar(n, 1, color='#e0e0e0', width=0.8)
for n in not_generated:
    ax.bar(n, 1, color='#e74c3c', width=0.8)
for n in generated:
    method = construct(n)
    colors = {'base': '#2ecc71', 'sylvester': '#3498db', 'paley1': '#9b59b6',
              'paley2': '#f39c12', 'tensor': '#1abc9c'}
    ax.bar(n, 1, color=colors.get(method, '#1abc9c'), width=0.8)

ax.set_xlim(0, B+1)
ax.set_ylim(0, 1.5)
ax.set_yticks([])
ax.set_xlabel('Order n', fontsize=12)
ax.set_title(f'Hadamard Existence Landscape (n ≤ {B})', fontsize=14, fontweight='bold')

patches = [
    mpatches.Patch(color='#e0e0e0', label='Inadmissible (4∤n, n>2)'),
    mpatches.Patch(color='#2ecc71', label='Base seed (n=1,2)'),
    mpatches.Patch(color='#3498db', label='Sylvester (2^k)'),
    mpatches.Patch(color='#9b59b6', label='Paley Type I'),
    mpatches.Patch(color='#f39c12', label='Paley Type II'),
    mpatches.Patch(color='#1abc9c', label='Tensor product'),
    mpatches.Patch(color='#e74c3c', label='Open / not generated'),
]
ax.legend(handles=patches, loc='upper right', fontsize=8, ncol=4)

plt.tight_layout()
plt.savefig('hadamard_existence.png', dpi=150, bbox_inches='tight')
print(f"Saved hadamard_existence.png")
print(f"Generated: {len(generated)}/{len(admissible)} admissible orders")
print(f"Not generated: {not_generated}")


#!/usr/bin/env python3
"""
Visualization 1: Hadamard Matrix Structure

Visualizes the ±1 pattern of Sylvester-Hadamard matrices at different orders,
showing how the recursive doubling construction creates fractal-like patterns.
The self-similar structure is the visual fingerprint of the Walsh system.
"""
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors

def hadamard(k):
    H = np.array([[1]])
    for _ in range(k):
        H = np.block([[H, H], [H, -H]])
    return H

fig, axes = plt.subplots(1, 4, figsize=(16, 4))
cmap = mcolors.ListedColormap(['#2c3e50', '#ecf0f1'])  # dark=-1, light=+1

for idx, k in enumerate([1, 2, 3, 4]):
    ax = axes[idx]
    H = hadamard(k)
    n = H.shape[0]
    # Map -1 → 0, +1 → 1 for colormap
    display = ((H + 1) // 2).astype(int)
    ax.imshow(display, cmap=cmap, interpolation='nearest', aspect='equal')
    ax.set_title(f'Order {n} (k={k})', fontsize=14, fontweight='bold')
    ax.set_xticks([])
    ax.set_yticks([])
    # Add grid
    for i in range(n + 1):
        ax.axhline(i - 0.5, color='gray', linewidth=0.3)
        ax.axvline(i - 0.5, color='gray', linewidth=0.3)

fig.suptitle('Sylvester-Hadamard Matrices: Self-Similar ±1 Patterns',
             fontsize=16, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('hadamard_patterns.png', dpi=150, bbox_inches='tight')
print("Saved hadamard_patterns.png")
