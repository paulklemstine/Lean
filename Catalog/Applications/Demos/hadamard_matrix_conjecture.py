"""
Hadamard Matrix Theory — Real-World Applications

Demonstrates practical applications of Hadamard matrices in:
1. Signal processing (Walsh-Hadamard Transform)
2. Error-correcting codes
3. Experimental design (balanced screening)
4. Compressed sensing
"""

import numpy as np
from algorithms import (
    sylvester_construction, kronecker_product, verify_hadamard,
    normalize_hadamard, extract_equidistant_code, hamming_distance,
    paley_type_I
)


# ============================================================
# APPLICATION 1: Walsh-Hadamard Transform
# ============================================================

def walsh_hadamard_transform(x: np.ndarray) -> np.ndarray:
    """
    Compute the Walsh-Hadamard Transform of a signal.

    The WHT of a vector x of length n = 2^k is:
        y = (1/√n) H_k x

    where H_k is the Sylvester-Hadamard matrix.

    Properties:
        - Orthogonal transform: WHT^(-1) = WHT
        - Energy preservation: ||y||^2 = ||x||^2
        - O(n log n) fast algorithm exists (not used here for clarity)

    Applications:
        - Image compression
        - Signal analysis
        - Spectral methods in algorithms

    Args:
        x: Input signal of length 2^k.

    Returns:
        WHT coefficients.
    """
    n = len(x)
    k = int(np.log2(n))
    assert 2**k == n, "Signal length must be a power of 2"

    H = sylvester_construction(k).astype(float)
    return H @ x / np.sqrt(n)


def fast_walsh_hadamard(x: np.ndarray) -> np.ndarray:
    """
    Fast Walsh-Hadamard Transform using butterfly operations.

    Time complexity: O(n log n)
    Space complexity: O(n)

    This is analogous to the FFT but for the Hadamard basis.
    """
    n = len(x)
    assert n > 0 and (n & (n - 1)) == 0, "Length must be power of 2"

    y = x.astype(float).copy()
    h = 1
    while h < n:
        for i in range(0, n, h * 2):
            for j in range(i, i + h):
                a = y[j]
                b = y[j + h]
                y[j] = a + b
                y[j + h] = a - b
        h *= 2

    return y / np.sqrt(n)


# ============================================================
# APPLICATION 2: Error-Correcting Codes
# ============================================================

def reed_muller_from_hadamard(k: int) -> dict:
    """
    Construct first-order Reed-Muller code from Sylvester-Hadamard matrix.

    The rows of H_k give a [2^k, k+1, 2^(k-1)] code over GF(2)
    (after mapping ±1 → {0,1}).

    This code:
        - Has minimum distance 2^(k-1) (half the block length)
        - Is used in deep-space communication (Mariner missions)
        - Achieves the Plotkin bound exactly

    Returns:
        Dictionary with code parameters and generator matrix.
    """
    n = 2**k
    H = sylvester_construction(k)

    # Map to binary: +1 → 0, -1 → 1
    G = ((1 - H) // 2).astype(int)

    # The generator matrix is the first k+1 rows
    # (in practice, the full Hadamard gives 2n codewords)

    # Compute all codewords
    codewords = []
    for i in range(n):
        codewords.append(G[i])
        codewords.append(1 - G[i])  # complement

    # Compute minimum distance
    min_dist = n
    for i in range(len(codewords)):
        for j in range(i + 1, len(codewords)):
            d = hamming_distance(codewords[i], codewords[j])
            if d > 0:
                min_dist = min(min_dist, d)

    return {
        "n": n,
        "k_info": k + 1,
        "d_min": min_dist,
        "num_codewords": len(codewords),
        "rate": (k + 1) / n,
        "generator": G[:k+1],
    }


# ============================================================
# APPLICATION 3: Experimental Design (Screening)
# ============================================================

def hadamard_screening_design(n_factors: int) -> dict:
    """
    Construct a Hadamard-based screening experiment.

    In industrial and pharmaceutical screening, one wants to test
    n factors (each at two levels: +1 or -1) with as few runs as possible
    while maintaining balance and orthogonality.

    A Hadamard matrix H of order n provides a design where:
        - n runs test (n-1) factors simultaneously
        - All main effects are estimated independently
        - Estimation variance is minimized (D-optimal)

    This is the Plackett-Burman design when n is a multiple of 4.

    Args:
        n_factors: Number of factors to screen (1 to n-1).

    Returns:
        Design matrix and analysis.
    """
    # Find smallest Hadamard order > n_factors
    n = 4
    while n <= n_factors:
        n += 4

    # Use Sylvester if n is power of 2, otherwise try Paley
    k = int(np.log2(n))
    if 2**k == n:
        H = sylvester_construction(k)
    else:
        # Try Paley
        q = n - 1
        H = paley_type_I(q)
        if H is None:
            # Fallback: use next power of 2
            k = int(np.ceil(np.log2(n_factors + 1)))
            n = 2**k
            H = sylvester_construction(k)

    # Normalize and extract design columns
    H_norm = normalize_hadamard(H)
    # Use columns 1 through n_factors (skip first, which is all 1s)
    design = H_norm[:, 1:n_factors + 1]

    # Verify orthogonality: X^T X = n I
    gram = design.T @ design
    diagonal = np.diag(gram)
    off_diag_max = np.max(np.abs(gram - np.diag(diagonal)))

    return {
        "n_runs": n,
        "n_factors": n_factors,
        "design_matrix": design,
        "orthogonal": off_diag_max == 0,
        "efficiency": n_factors / (n - 1),  # how many columns used vs available
    }


# ============================================================
# APPLICATION 4: Spread-Spectrum Communication (CDMA)
# ============================================================

def cdma_simulation(n_users: int, snr_db: float = 20.0) -> dict:
    """
    Simulate a CDMA (Code Division Multiple Access) communication system
    using Walsh-Hadamard spreading codes.

    In CDMA:
        - Each user gets a unique row of the Hadamard matrix as spreading code
        - All users transmit simultaneously on the same frequency
        - Receiver uses code orthogonality to separate signals

    This is the foundation of 3G cellular (IS-95/CDMA2000) and GPS.

    Args:
        n_users: Number of simultaneous users (must be ≤ 2^k for some k).
        snr_db: Signal-to-noise ratio in dB.

    Returns:
        Simulation results including bit error rates.
    """
    # Find appropriate Hadamard matrix
    k = int(np.ceil(np.log2(max(n_users, 2))))
    n = 2**k
    H = sylvester_construction(k).astype(float)

    # Assign spreading codes (first n_users rows)
    codes = H[:n_users]

    # Generate random data bits for each user: +1 or -1
    np.random.seed(42)
    data = np.random.choice([-1, 1], size=n_users)

    # Spread: each user multiplies their bit by their code
    # Signal on channel = sum of all spread signals
    channel_signal = np.zeros(n)
    for i in range(n_users):
        channel_signal += data[i] * codes[i]

    # Add Gaussian noise
    snr_linear = 10**(snr_db / 10)
    signal_power = np.mean(channel_signal**2)
    noise_power = signal_power / snr_linear
    noise = np.random.normal(0, np.sqrt(noise_power), n)
    received = channel_signal + noise

    # Despread: correlate with each user's code
    decoded = np.zeros(n_users)
    for i in range(n_users):
        correlation = np.dot(received, codes[i]) / n
        decoded[i] = np.sign(correlation)

    # Count errors
    errors = int(np.sum(decoded != data))

    return {
        "n_users": n_users,
        "spreading_factor": n,
        "snr_db": snr_db,
        "data": data,
        "decoded": decoded,
        "errors": errors,
        "ber": errors / n_users,
    }


# ============================================================
# MAIN DEMONSTRATIONS
# ============================================================

if __name__ == "__main__":
    print("=" * 70)
    print("HADAMARD MATRICES — REAL-WORLD APPLICATIONS")
    print("=" * 70)

    # App 1: Walsh-Hadamard Transform
    print("\n--- Application 1: Walsh-Hadamard Transform ---")
    x = np.array([1, 2, 3, 4, 5, 6, 7, 8], dtype=float)
    y_slow = walsh_hadamard_transform(x)
    y_fast = fast_walsh_hadamard(x)
    print(f"  Input signal:  {x}")
    print(f"  WHT (matrix):  {np.round(y_slow, 4)}")
    print(f"  WHT (fast):    {np.round(y_fast, 4)}")
    print(f"  Agreement: {np.allclose(y_slow, y_fast)}")
    print(f"  Energy preserved: ||x||² = {np.sum(x**2):.1f}, ||y||² = {np.sum(y_slow**2):.1f}")

    # App 2: Error-correcting codes
    print("\n--- Application 2: Reed-Muller / Hadamard Codes ---")
    for k in range(2, 6):
        code = reed_muller_from_hadamard(k)
        print(f"  k={k}: [{code['n']}, {code['k_info']}, {code['d_min']}] code, "
              f"{code['num_codewords']} codewords, rate = {code['rate']:.3f}")

    # App 3: Experimental design
    print("\n--- Application 3: Screening Experiment Design ---")
    for n_factors in [3, 7, 11, 15]:
        design = hadamard_screening_design(n_factors)
        print(f"  {n_factors} factors: {design['n_runs']} runs, "
              f"orthogonal = {design['orthogonal']}, "
              f"efficiency = {design['efficiency']:.1%}")

    # App 4: CDMA communication
    print("\n--- Application 4: CDMA Communication Simulation ---")
    for n_users in [2, 4, 8]:
        for snr in [10, 20, 30]:
            result = cdma_simulation(n_users, snr)
            print(f"  {n_users} users, SNR={snr}dB: "
                  f"BER = {result['ber']:.3f} ({result['errors']} errors)")

    print("\n" + "=" * 70)
    print("All applications demonstrated successfully.")


"""
Hadamard Matrix Theory — Interactive Demonstrations

Demonstrates the key constructions and properties of Hadamard matrices
with concrete numerical examples.
"""

import numpy as np
from typing import Optional


def is_hadamard(H: np.ndarray) -> bool:
    """Check if a matrix is Hadamard: ±1 entries and H @ H.T = n * I."""
    n = H.shape[0]
    if H.shape != (n, n):
        return False
    if not np.all(np.isin(H, [-1, 1])):
        return False
    product = H @ H.T
    return np.array_equal(product, n * np.eye(n, dtype=int))


def sylvester_hadamard(k: int) -> np.ndarray:
    """
    Construct the Sylvester-Hadamard matrix of order 2^k.

    H_0 = [[1]]
    H_{k+1} = [[H_k, H_k], [H_k, -H_k]]

    >>> sylvester_hadamard(0)
    array([[1]])
    >>> sylvester_hadamard(1)
    array([[ 1,  1],
           [ 1, -1]])
    """
    H = np.array([[1]], dtype=int)
    for _ in range(k):
        H = np.block([[H, H], [H, -H]])
    return H


def kronecker_hadamard(A: np.ndarray, B: np.ndarray) -> np.ndarray:
    """
    Construct the Kronecker product of two matrices.

    If A is m×m Hadamard and B is n×n Hadamard, the result is (mn)×(mn) Hadamard.
    """
    return np.kron(A, B)


def paley_matrix(q: int) -> Optional[np.ndarray]:
    """
    Construct a Paley-type I Hadamard matrix of order q+1,
    where q is a prime power ≡ 3 (mod 4).

    Uses quadratic residue character (Legendre symbol for primes).
    Returns None if q doesn't satisfy the conditions.
    """
    if q % 4 != 3:
        return None

    # Check if q is prime (simplified; for demo purposes)
    if q < 2:
        return None
    for p in range(2, int(q**0.5) + 1):
        if q % p == 0:
            return None  # Not prime (simplified check)

    # Compute quadratic residues mod q
    qr = set()
    for i in range(1, q):
        qr.add((i * i) % q)

    # Legendre symbol
    def chi(a: int) -> int:
        a = a % q
        if a == 0:
            return 0
        return 1 if a in qr else -1

    # Build the Jacobsthal matrix Q (q×q)
    Q = np.zeros((q, q), dtype=int)
    for i in range(q):
        for j in range(q):
            Q[i, j] = chi(i - j)

    # Paley Type I: H = [[1, j^T], [-j, Q + I]]
    # where j is the all-ones column vector
    n = q + 1
    H = np.zeros((n, n), dtype=int)
    H[0, 0] = 1
    H[0, 1:] = 1
    H[1:, 0] = -1
    H[1:, 1:] = Q + np.eye(q, dtype=int)

    # Negate to get standard form if needed
    # The skew-type Paley: S = H - I should satisfy S @ S.T = (q+1) I - J
    # But we build H directly as Hadamard
    return H


# ============================================================
# DEMONSTRATIONS
# ============================================================

if __name__ == "__main__":
    print("=" * 70)
    print("HADAMARD MATRIX THEORY — DEMONSTRATIONS")
    print("=" * 70)

    # Demo 1: Sylvester construction
    print("\n--- Demo 1: Sylvester Construction ---")
    for k in range(5):
        H = sylvester_hadamard(k)
        n = H.shape[0]
        valid = is_hadamard(H)
        print(f"  H_{k} (order {n:4d}): Hadamard = {valid}")

    print(f"\n  Sylvester H_2 (order 4):")
    H4 = sylvester_hadamard(2)
    print(H4)
    print(f"  H_2 @ H_2^T = 4I: {np.array_equal(H4 @ H4.T, 4 * np.eye(4, dtype=int))}")

    # Demo 2: Kronecker product closure
    print("\n--- Demo 2: Kronecker Product Closure ---")
    H2 = sylvester_hadamard(1)
    H4_kron = kronecker_hadamard(H2, H2)
    print(f"  H2 ⊗ H2 (order {H4_kron.shape[0]}): Hadamard = {is_hadamard(H4_kron)}")

    H8 = kronecker_hadamard(H4, H2)
    print(f"  H4 ⊗ H2 (order {H8.shape[0]}): Hadamard = {is_hadamard(H8)}")

    # Demo 3: Paley construction
    print("\n--- Demo 3: Paley Construction ---")
    paley_primes = [3, 7, 11, 19, 23, 31, 43, 47, 59, 67, 71, 79, 83]
    for q in paley_primes:
        H = paley_matrix(q)
        if H is not None:
            valid = is_hadamard(H)
            print(f"  Paley({q:3d}): order {q+1:4d}, Hadamard = {valid}")

    # Demo 4: Paley × Sylvester = new orders
    print("\n--- Demo 4: Combined Constructions ---")
    H12 = paley_matrix(11)
    if H12 is not None and is_hadamard(H12):
        for k in range(4):
            H_combined = kronecker_hadamard(H12, sylvester_hadamard(k))
            n = H_combined.shape[0]
            print(f"  H12 ⊗ H_{k} (order {n:4d}): Hadamard = {is_hadamard(H_combined)}")

    # Demo 5: Divisibility condition
    print("\n--- Demo 5: Necessary Condition (4 | n for n > 2) ---")
    print("  Orders 1 and 2 are Hadamard (trivial).")
    print("  For n > 2, Hadamard order ⟹ 4 | n.")
    print("  Non-multiples of 4 that are > 2:")
    for n in range(3, 40):
        if n % 4 != 0:
            print(f"    n = {n}: NOT a Hadamard order (4 ∤ {n})")

    # Demo 6: Coverage statistics
    print("\n--- Demo 6: Hadamard Order Coverage up to 100 ---")
    # Known Hadamard orders from our constructions
    known = set()
    # Powers of 2
    for k in range(8):
        known.add(2**k)
    # Paley
    for q in paley_primes:
        known.add(q + 1)
    # Products
    base_orders = list(known)
    for _ in range(3):
        new = set()
        for a in known:
            for b in base_orders:
                if a * b <= 200:
                    new.add(a * b)
        known.update(new)

    known.add(1)  # trivial

    multiples_of_4 = [n for n in range(4, 101, 4)]
    covered = [n for n in multiples_of_4 if n in known]
    uncovered = [n for n in multiples_of_4 if n not in known]

    print(f"  Multiples of 4 up to 100: {len(multiples_of_4)}")
    print(f"  Covered by constructions: {len(covered)}")
    print(f"  Covered orders: {sorted(covered)}")
    print(f"  Uncovered orders: {sorted(uncovered)}")

    # Demo 7: Non-symmetric counterexample
    print("\n--- Demo 7: Counterexample — Not Every Hadamard Matrix is Symmetric ---")
    H_nonsym = np.array([[1, 1], [-1, 1]], dtype=int)
    print(f"  H = {H_nonsym.tolist()}")
    print(f"  Hadamard: {is_hadamard(H_nonsym)}")
    print(f"  Symmetric: {np.array_equal(H_nonsym, H_nonsym.T)}")
    print(f"  H^T = {H_nonsym.T.tolist()}")

    print("\n" + "=" * 70)
    print("All demonstrations complete.")
