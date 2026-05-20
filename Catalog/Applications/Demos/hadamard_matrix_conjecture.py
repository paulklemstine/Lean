"""
Hadamard Matrix Applications

Demonstrates real-world applications of Hadamard matrices in:
    1. Error-correcting codes (Hadamard/Walsh codes)
    2. Signal processing (Walsh-Hadamard transform)
    3. Compressed sensing (measurement matrices)
    4. Combinatorial design (BIBD from normalized Hadamard)
"""

from __future__ import annotations
import numpy as np
from algorithms import (
    sylvester_matrix, normalize_hadamard, hadamard_code,
    hamming_distance, is_hadamard, hadamard_excess,
    walsh_hadamard_transform, verify_energy_identity,
)


def demonstrate_error_correction():
    """
    Show how Hadamard codes provide error detection and correction.

    A Hadamard code of order n:
    - Has n codewords of length n
    - Minimum distance n/2
    - Can detect up to n/2 - 1 errors
    - Can correct up to n/4 - 1 errors
    """
    print("=" * 70)
    print("APPLICATION 1: Error-Correcting Codes")
    print("=" * 70)

    for k in [2, 3, 4]:
        n = 2**k
        H = sylvester_matrix(k)
        H_norm = normalize_hadamard(H)
        code = hadamard_code(H_norm)

        # Remove first row (all zeros after normalization)
        useful_code = code[1:]

        print(f"\nHadamard code of order {n}:")
        print(f"  Codewords: {len(useful_code)}")
        print(f"  Code length: {n}")
        print(f"  Min distance: {n // 2}")
        print(f"  Error detection: up to {n // 2 - 1} errors")
        print(f"  Error correction: up to {n // 4 - 1} errors")
        print(f"  Code rate: {np.log2(len(useful_code)):.1f}/{n} = {np.log2(len(useful_code))/n:.3f}")

        if k <= 3:
            print(f"  Codewords:")
            for i, cw in enumerate(useful_code):
                print(f"    c{i+1} = {''.join(map(str, cw))}")

        # Simulate error correction
        original = useful_code[0]
        num_errors = n // 4 - 1
        if num_errors > 0:
            corrupted = original.copy()
            error_positions = np.random.choice(n, num_errors, replace=False)
            corrupted[error_positions] = 1 - corrupted[error_positions]

            # Decode by finding nearest codeword
            distances = [hamming_distance(corrupted, cw) for cw in code]
            decoded_idx = np.argmin(distances)

            print(f"  Error correction demo ({num_errors} errors):")
            print(f"    Original:  {''.join(map(str, original))}")
            print(f"    Corrupted: {''.join(map(str, corrupted))}")
            print(f"    Decoded:   {''.join(map(str, code[decoded_idx]))}")
            print(f"    Correct:   {np.array_equal(code[decoded_idx], original)}")


def demonstrate_signal_processing():
    """
    Show the Walsh-Hadamard transform for signal analysis and compression.

    The WHT is analogous to the Fourier transform but uses ±1 values,
    making it computationally efficient (only additions and subtractions).
    """
    print("\n" + "=" * 70)
    print("APPLICATION 2: Signal Processing (Walsh-Hadamard Transform)")
    print("=" * 70)

    k = 3
    n = 2**k

    # Create a simple signal
    t = np.arange(n)
    signal = np.array([1, 1, 1, 1, -1, -1, -1, -1], dtype=int)  # Step function

    print(f"\nOriginal signal (length {n}):")
    print(f"  x = {signal}")

    # Transform
    transformed = walsh_hadamard_transform(signal, k)
    print(f"\nWalsh-Hadamard coefficients:")
    print(f"  WHT(x) = {transformed}")

    # Verify energy identity
    energy = verify_energy_identity(signal, k)
    print(f"\nEnergy identity verification:")
    print(f"  ‖x‖² = {energy['input_energy']}")
    print(f"  ‖WHT(x)‖² = {energy['output_energy']}")
    print(f"  n · ‖x‖² = {energy['expected_output_energy']}")
    print(f"  Ratio ‖WHT(x)‖²/‖x‖² = {energy['ratio']} (should be {n})")
    print(f"  Verified: {energy['verified']}")

    # Demonstrate compression: keep only largest coefficients
    print(f"\nSignal compression:")
    sorted_idx = np.argsort(np.abs(transformed))[::-1]
    for num_keep in [1, 2, 4, n]:
        mask = np.zeros(n, dtype=int)
        mask[sorted_idx[:num_keep]] = 1
        compressed = transformed * mask
        H = sylvester_matrix(k)
        # Inverse WHT is (1/n) * WHT
        reconstructed = (H @ compressed) / n
        error = np.sum((signal - reconstructed) ** 2)
        print(f"  Keep {num_keep}/{n} coefficients: reconstruction error = {error:.1f}")


def demonstrate_compressed_sensing():
    """
    Show Hadamard matrices as measurement matrices for compressed sensing.

    A Hadamard matrix provides a deterministic measurement matrix with
    good incoherence properties for sparse signal recovery.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 3: Compressed Sensing")
    print("=" * 70)

    k = 4
    n = 2**k
    H = sylvester_matrix(k)

    # Create a sparse signal
    sparsity = 3
    x_true = np.zeros(n, dtype=float)
    support = np.random.choice(n, sparsity, replace=False)
    x_true[support] = np.random.randn(sparsity)

    # Take m < n measurements
    m = 8
    measurement_rows = np.random.choice(n, m, replace=False)
    Phi = H[measurement_rows, :].astype(float) / np.sqrt(n)
    y = Phi @ x_true

    print(f"\nCompressed sensing with Hadamard measurements:")
    print(f"  Signal dimension: n = {n}")
    print(f"  Signal sparsity: s = {sparsity}")
    print(f"  Number of measurements: m = {m}")
    print(f"  Compression ratio: {m}/{n} = {m/n:.2f}")
    print(f"  True support: {sorted(support)}")
    print(f"  Measurement matrix: {m} rows of normalized H_{n}")

    # Mutual coherence of measurement matrix
    G = Phi.T @ Phi
    np.fill_diagonal(G, 0)
    coherence = np.max(np.abs(G))
    print(f"  Mutual coherence: {coherence:.4f}")


def demonstrate_combinatorial_design():
    """
    Show how a normalized Hadamard matrix yields a symmetric BIBD.

    A normalized Hadamard matrix of order 4t, after removing the first
    row and column, yields a 2-(4t-1, 2t-1, t-1) symmetric design.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 4: Combinatorial Design (BIBD)")
    print("=" * 70)

    for t in [1, 2, 3]:
        n = 4 * t
        H = sylvester_matrix(int(np.log2(n))) if (n & (n - 1)) == 0 else None

        if H is None or H.shape[0] != n:
            continue

        H_norm = normalize_hadamard(H)

        # Remove first row and column
        core = H_norm[1:, 1:]

        # Convert to incidence matrix: +1 → 1, -1 → 0
        inc = ((core + 1) // 2).astype(int)

        v = n - 1  # number of points = number of blocks
        k_param = 2 * t - 1  # block size
        lambda_param = t - 1  # replication number for pairs

        print(f"\n2-({v}, {k_param}, {lambda_param}) symmetric design from H_{n}:")
        print(f"  Points: {v}")
        print(f"  Blocks: {v}")
        print(f"  Block size k: {k_param}")
        print(f"  λ (pair coverage): {lambda_param}")

        # Verify block sizes
        block_sizes = np.sum(inc, axis=1)
        print(f"  Block sizes: {np.unique(block_sizes)} (should be [{k_param}])")

        # Verify pair coverage
        if lambda_param > 0:
            # For each pair of points, count how many blocks contain both
            pair_counts = []
            for i in range(v):
                for j in range(i + 1, v):
                    count = np.sum(inc[:, i] * inc[:, j])
                    pair_counts.append(count)
            pair_counts = np.array(pair_counts)
            print(f"  Pair coverage: {np.unique(pair_counts)} (should be [{lambda_param}])")

        if n <= 8:
            print(f"  Incidence matrix:")
            for row in inc:
                print(f"    {''.join(map(str, row))}")


def demonstrate_excess_analysis():
    """
    Analyze the excess (sum of all entries) of Hadamard matrices.
    The excess satisfies σ(H)² ≤ n³ (formally verified).
    """
    print("\n" + "=" * 70)
    print("APPLICATION 5: Excess Analysis")
    print("=" * 70)

    print(f"\n{'Order':>6} {'Excess':>8} {'σ²':>10} {'n³':>10} {'σ²/n³':>8} {'Bound OK':>10}")
    print("-" * 60)

    for k in range(1, 8):
        n = 2**k
        H = sylvester_matrix(k)
        sigma = hadamard_excess(H)
        sigma_sq = sigma**2
        bound = n**3
        ratio = sigma_sq / bound if bound > 0 else 0
        ok = sigma_sq <= bound

        print(f"{n:>6} {sigma:>8} {sigma_sq:>10} {bound:>10} {ratio:>8.4f} {'✓' if ok else '✗':>10}")


if __name__ == "__main__":
    np.random.seed(42)
    demonstrate_error_correction()
    demonstrate_signal_processing()
    demonstrate_compressed_sensing()
    demonstrate_combinatorial_design()
    demonstrate_excess_analysis()


#!/usr/bin/env python3
"""
Hadamard Matrix Theory — Interactive Demonstration

This demo showcases the constructions and properties of Hadamard matrices
that have been formally verified in Lean 4. It generates matrices,
verifies their properties numerically, and demonstrates cross-domain
applications in coding theory, signal processing, and combinatorial design.

Usage:
    python demo.py                    # Run full demonstration
    python demo.py --order 8          # Show specific order
    python demo.py --construction sylvester  # Choose construction type
    python demo.py --application code        # Focus on specific application
"""

from __future__ import annotations
import numpy as np
import sys


# ─── Core Algorithms (self-contained) ───────────────────────────────────────

def sylvester_matrix(k: int) -> np.ndarray:
    """Construct the 2^k × 2^k Sylvester-Hadamard matrix recursively."""
    H = np.array([[1]], dtype=int)
    for _ in range(k):
        H = np.block([[H, H], [H, -H]])
    return H


def kronecker_hadamard(H1: np.ndarray, H2: np.ndarray) -> np.ndarray:
    """Kronecker (tensor) product of two matrices."""
    return np.kron(H1, H2)


def is_hadamard(H: np.ndarray) -> bool:
    """Check whether H is a valid Hadamard matrix."""
    n = H.shape[0]
    if H.shape != (n, n):
        return False
    if not np.all(np.abs(H) == 1):
        return False
    return np.array_equal(H @ H.T, n * np.eye(n, dtype=int))


def normalize_hadamard(H: np.ndarray) -> np.ndarray:
    """Normalize H so first row and column are all +1."""
    H2 = H.copy()
    H2 = H2 * H2[0, :][np.newaxis, :]
    H2 = H2 * H2[:, 0][:, np.newaxis]
    return H2


def hadamard_code(H: np.ndarray) -> np.ndarray:
    """Map ±1 matrix to binary code: +1 → 0, -1 → 1."""
    return ((1 - H) // 2).astype(int)


def hamming_distance(u: np.ndarray, v: np.ndarray) -> int:
    """Hamming distance between two binary vectors."""
    return int(np.sum(u != v))


def hadamard_excess(H: np.ndarray) -> int:
    """Sum of all entries of H."""
    return int(np.sum(H))


def walsh_hadamard_transform(x: np.ndarray, k: int) -> np.ndarray:
    """Compute WHT(x) = H_k · x."""
    return sylvester_matrix(k) @ x


def paley_matrix(q: int) -> np.ndarray | None:
    """
    Construct Paley-type I Hadamard matrix of order q+1 for prime q ≡ 3 (mod 4).
    Returns None if conditions not met.
    """
    def is_prime(n):
        if n < 2: return False
        for p in range(2, int(n**0.5) + 1):
            if n % p == 0: return False
        return True

    if not is_prime(q) or q % 4 != 3:
        return None

    # Legendre symbol
    def legendre(a, p):
        a = a % p
        if a == 0: return 0
        if pow(a, (p - 1) // 2, p) == 1: return 1
        return -1

    n = q + 1
    # Build quadratic residue matrix
    Q = np.zeros((q, q), dtype=int)
    for i in range(q):
        for j in range(q):
            Q[i, j] = legendre((j - i) % q, q)

    # Paley Type I: H = [[-1, j^T], [j, Q + I]]
    j_vec = np.ones(q, dtype=int)
    H = np.zeros((n, n), dtype=int)
    H[0, 0] = -1
    H[0, 1:] = j_vec
    H[1:, 0] = j_vec
    H[1:, 1:] = Q + np.eye(q, dtype=int)

    if is_hadamard(H):
        return H
    return None


# ─── Display Utilities ──────────────────────────────────────────────────────

def print_matrix(H: np.ndarray, name: str = "H", max_size: int = 16):
    """Pretty-print a ±1 matrix using + and - symbols."""
    n = H.shape[0]
    print(f"\n{name} ({n}×{n}):")
    if n > max_size:
        print(f"  [Matrix too large to display ({n}×{n}), showing corners]")
        for i in range(min(4, n)):
            row = "".join(" +" if H[i, j] == 1 else " -" for j in range(min(8, n)))
            print(f"  {row} ...")
        print(f"  {'  .':>{2*min(8,n)+4}}")
        return
    for i in range(n):
        row = "".join(" +" if H[i, j] == 1 else " -" for j in range(n))
        print(f"  {row}")


def divider(title: str):
    """Print a section divider."""
    print(f"\n{'═' * 70}")
    print(f"  {title}")
    print(f"{'═' * 70}")


# ─── Demonstrations ─────────────────────────────────────────────────────────

def demo_sylvester():
    """Demonstrate Sylvester construction for all powers of 2."""
    divider("SYLVESTER CONSTRUCTION: Hadamard matrices of order 2^k")
    print()
    print("  Theorem (formally verified): For every k ≥ 0, there exists a")
    print("  Hadamard matrix of order 2^k, constructed by iterated Kronecker")
    print("  product of the 2×2 seed matrix [[1,1],[1,-1]].")
    print()

    for k in range(6):
        n = 2**k
        H = sylvester_matrix(k)
        valid = is_hadamard(H)
        excess = hadamard_excess(H)
        print(f"  k={k}: H_{n:>3} — {'✓ Hadamard' if valid else '✗ FAILED'}"
              f"  excess={excess:>5}  excess²/n³={excess**2/max(n**3,1):.4f}")

        if k <= 3:
            print_matrix(H, f"H_{n}")


def demo_kronecker():
    """Demonstrate Kronecker closure theorem."""
    divider("KRONECKER CLOSURE: Tensor product preserves Hadamard property")
    print()
    print("  Theorem (formally verified): If H₁ (m×m) and H₂ (n×n) are")
    print("  Hadamard, then H₁ ⊗ H₂ (mn×mn) is Hadamard.")
    print()

    H2 = sylvester_matrix(1)  # 2×2
    H4 = sylvester_matrix(2)  # 4×4

    print("  H₂ ⊗ H₄ = H₈:")
    H8 = kronecker_hadamard(H2, H4)
    print(f"  Verified: {is_hadamard(H8)}")
    print_matrix(H8, "H₂ ⊗ H₄")

    # Build H₁₂ via Paley and tensor with H₂
    H_paley = paley_matrix(11)
    if H_paley is not None:
        print(f"\n  Paley construction: H₁₂ from q=11 (11 ≡ 3 mod 4)")
        print(f"  Verified: {is_hadamard(H_paley)}")
        H24 = kronecker_hadamard(H2, H_paley)
        print(f"  H₂ ⊗ H₁₂ = H₂₄: Verified: {is_hadamard(H24)}")


def demo_obstruction():
    """Demonstrate the 4|n divisibility obstruction."""
    divider("DIVISIBILITY OBSTRUCTION: n > 2 implies 4 | n")
    print()
    print("  Theorem (formally verified): If a Hadamard matrix of order n")
    print("  exists with n > 2, then 4 divides n.")
    print()
    print("  This means no Hadamard matrix exists for orders 3, 5, 6, 7, 9, 10, 11, ...")
    print()

    print(f"  {'Order':>6}  {'4|n?':>5}  {'Hadamard exists?':>16}  {'Status':>12}")
    print(f"  {'─'*6}  {'─'*5}  {'─'*16}  {'─'*12}")

    known_orders = {1, 2, 4, 8, 12, 16, 20, 24, 28, 32}
    for n in range(1, 33):
        div4 = "yes" if n % 4 == 0 else "no"
        if n <= 2:
            exists = "yes"
            status = "trivial"
        elif n % 4 != 0:
            exists = "no (obstr.)"
            status = "impossible"
        elif n in known_orders:
            exists = "yes"
            status = "constructed"
        else:
            exists = "open"
            status = "unknown"
        print(f"  {n:>6}  {div4:>5}  {exists:>16}  {status:>12}")


def demo_code():
    """Demonstrate Hadamard codes and equidistance."""
    divider("HADAMARD CODES: Equidistant binary codes")
    print()
    print("  Theorem (formally verified): For a Hadamard matrix of order n,")
    print("  the binary code obtained by mapping +1→0, -1→1 has the property")
    print("  that all distinct codeword pairs have Hamming distance exactly n/2.")
    print()

    for k in [2, 3, 4]:
        n = 2**k
        H = sylvester_matrix(k)
        code = hadamard_code(H)

        distances = set()
        for i in range(n):
            for j in range(i + 1, n):
                distances.add(hamming_distance(code[i], code[j]))

        print(f"  Order {n}: {n} codewords of length {n}")
        print(f"    All pairwise distances: {sorted(distances)}")
        print(f"    Expected distance: {n // 2}")
        print(f"    Equidistant: {'✓' if distances == {n // 2} else '✗'}")

        if k == 2:
            print(f"    Codewords:")
            for i in range(n):
                cw = ''.join(map(str, code[i]))
                print(f"      row {i}: {cw}")
        print()


def demo_energy():
    """Demonstrate the Walsh-Hadamard energy identity."""
    divider("WALSH-HADAMARD ENERGY IDENTITY: ‖Hx‖² = n·‖x‖²")
    print()
    print("  Theorem (formally verified): For any Hadamard matrix H of order n")
    print("  and any integer vector x, ∑ᵢ(∑ⱼ Hᵢⱼxⱼ)² = n · ∑ⱼ xⱼ².")
    print()

    k = 3
    n = 2**k

    test_vectors = [
        ("unit vector e₁", np.array([1, 0, 0, 0, 0, 0, 0, 0])),
        ("all ones", np.ones(n, dtype=int)),
        ("alternating", np.array([1, -1, 1, -1, 1, -1, 1, -1])),
        ("random", np.array([3, -1, 4, 1, -5, 9, -2, 6])),
    ]

    for name, x in test_vectors:
        Hx = walsh_hadamard_transform(x, k)
        lhs = int(np.sum(Hx**2))
        rhs = n * int(np.sum(x**2))
        print(f"  x = {name}:")
        print(f"    ‖x‖² = {int(np.sum(x**2))}")
        print(f"    ‖Hx‖² = {lhs}")
        print(f"    n·‖x‖² = {rhs}")
        print(f"    Verified: {'✓' if lhs == rhs else '✗'}")
        print()


def demo_normalization():
    """Demonstrate normalization procedure."""
    divider("NORMALIZATION: Making first row and column all +1")
    print()
    print("  Theorem (formally verified): Every Hadamard matrix can be")
    print("  transformed into a normalized form (first row and column all +1)")
    print("  by sign-flipping rows and columns.")
    print()

    H = sylvester_matrix(2)
    print("  Original matrix:")
    print_matrix(H, "H₄")

    H_norm = normalize_hadamard(H)
    print("\n  After normalization:")
    print_matrix(H_norm, "H₄ (normalized)")

    print(f"\n  First row all +1: {np.all(H_norm[0] == 1)}")
    print(f"  First col all +1: {np.all(H_norm[:, 0] == 1)}")
    print(f"  Still Hadamard:   {is_hadamard(H_norm)}")


def demo_excess():
    """Demonstrate excess bound σ² ≤ n³."""
    divider("EXCESS BOUND: σ(H)² ≤ n³")
    print()
    print("  Theorem (formally verified): For any Hadamard matrix H of order n,")
    print("  the square of the excess σ(H) = ∑ᵢⱼ Hᵢⱼ satisfies σ(H)² ≤ n³.")
    print()

    print(f"  {'Order':>6} {'Excess σ':>10} {'σ²':>12} {'n³':>12} {'σ²/n³':>8} {'Bound':>6}")
    print(f"  {'─'*6} {'─'*10} {'─'*12} {'─'*12} {'─'*8} {'─'*6}")

    for k in range(1, 9):
        n = 2**k
        H = sylvester_matrix(k)
        sigma = hadamard_excess(H)
        print(f"  {n:>6} {sigma:>10} {sigma**2:>12} {n**3:>12} "
              f"{sigma**2/n**3:>8.4f} {'  ✓' if sigma**2 <= n**3 else '  ✗':>6}")


def demo_paley():
    """Demonstrate Paley construction for primes q ≡ 3 (mod 4)."""
    divider("PALEY CONSTRUCTION: Hadamard matrices from quadratic residues")
    print()
    print("  For primes q ≡ 3 (mod 4), there exists a Hadamard matrix of order q+1")
    print("  built from the Legendre symbol (quadratic residue character) over GF(q).")
    print()

    primes_3mod4 = [3, 7, 11, 19, 23, 31, 43, 47, 59, 67, 71, 79, 83]
    for q in primes_3mod4:
        H = paley_matrix(q)
        if H is not None:
            n = q + 1
            sigma = hadamard_excess(H)
            print(f"  q={q:>3} → H_{n:>3}: "
                  f"{'✓ Hadamard' if is_hadamard(H) else '✗ FAILED'}  "
                  f"excess={sigma}")
            if q <= 11:
                print_matrix(H, f"Paley H_{n}")
        else:
            print(f"  q={q:>3} → construction failed")


def demo_comparison():
    """Compare Sylvester vs Paley constructions at overlapping orders."""
    divider("SYLVESTER vs PALEY: Comparing constructions")
    print()
    print("  At some orders, both Sylvester and Paley constructions exist.")
    print("  We compare their excess and spectral properties.")
    print()

    # Order 4: Sylvester H₄ vs Paley from q=3
    H_sylv = sylvester_matrix(2)
    H_paley = paley_matrix(3)

    if H_paley is not None:
        print("  Order 4:")
        print(f"    Sylvester excess: {hadamard_excess(H_sylv)}")
        print(f"    Paley excess:     {hadamard_excess(H_paley)}")

        # Row-sum comparison
        sylv_rowsums = np.sum(H_sylv, axis=1)
        paley_rowsums = np.sum(H_paley, axis=1)
        print(f"    Sylvester row sums: {sorted(sylv_rowsums)}")
        print(f"    Paley row sums:     {sorted(paley_rowsums)}")

    # Order 8: Sylvester vs Paley from q=7
    H_sylv8 = sylvester_matrix(3)
    H_paley8 = paley_matrix(7)

    if H_paley8 is not None:
        print("\n  Order 8:")
        print(f"    Sylvester excess: {hadamard_excess(H_sylv8)}")
        print(f"    Paley excess:     {hadamard_excess(H_paley8)}")

        sylv_rowsums = sorted(np.sum(H_sylv8, axis=1))
        paley_rowsums = sorted(np.sum(H_paley8, axis=1))
        print(f"    Sylvester row sums: {sylv_rowsums}")
        print(f"    Paley row sums:     {paley_rowsums}")
        print(f"    Same row-sum profile: {sylv_rowsums == paley_rowsums}")


# ─── Main ────────────────────────────────────────────────────────────────────

def main():
    """Run all demonstrations."""
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║     HADAMARD MATRIX THEORY — Formal Verification Demonstration     ║")
    print("║                                                                    ║")
    print("║  All key properties below have been formally verified in Lean 4.   ║")
    print("║  This demo provides numerical evidence alongside the proofs.       ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")

    args = sys.argv[1:]

    if "--application" in args:
        idx = args.index("--application")
        if idx + 1 < len(args):
            app = args[idx + 1].lower()
            demos = {
                "sylvester": demo_sylvester,
                "kronecker": demo_kronecker,
                "obstruction": demo_obstruction,
                "code": demo_code,
                "energy": demo_energy,
                "normalization": demo_normalization,
                "excess": demo_excess,
                "paley": demo_paley,
                "comparison": demo_comparison,
            }
            if app in demos:
                demos[app]()
                return
            else:
                print(f"Unknown application: {app}")
                print(f"Available: {', '.join(demos.keys())}")
                return

    # Run everything
    demo_sylvester()
    demo_kronecker()
    demo_obstruction()
    demo_normalization()
    demo_code()
    demo_energy()
    demo_excess()
    demo_paley()
    demo_comparison()

    print("\n" + "═" * 70)
    print("  All demonstrations complete.")
    print("  Every property marked ✓ has been formally verified in Lean 4.")
    print("═" * 70)


if __name__ == "__main__":
    main()
