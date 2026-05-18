"""
Algorithms for Algebraic Coding Theory
=======================================

Implementations of:
- Reed-Solomon encoding and distance computation
- BCH syndrome computation and bound verification
- Berlekamp-Massey algorithm for minimal linear recurrence synthesis
- Syndrome-based decoding

All algorithms operate over finite fields GF(p) for prime p.
"""

from typing import List, Tuple, Optional
import numpy as np


class GF:
    """Simple finite field GF(p) arithmetic for prime p."""

    def __init__(self, p: int):
        self.p = p

    def add(self, a: int, b: int) -> int:
        return (a + b) % self.p

    def sub(self, a: int, b: int) -> int:
        return (a - b) % self.p

    def mul(self, a: int, b: int) -> int:
        return (a * b) % self.p

    def inv(self, a: int) -> int:
        """Modular inverse using extended Euclidean algorithm."""
        if a % self.p == 0:
            raise ValueError("Cannot invert zero")
        return pow(a, self.p - 2, self.p)

    def div(self, a: int, b: int) -> int:
        return self.mul(a, self.inv(b))

    def pow(self, a: int, n: int) -> int:
        return pow(a, n, self.p)

    def neg(self, a: int) -> int:
        return (-a) % self.p


def rs_encode(gf: GF, eval_points: List[int], message_poly: List[int]) -> List[int]:
    """
    Reed-Solomon encoding: evaluate the message polynomial at each evaluation point.

    Args:
        gf: Finite field
        eval_points: List of n distinct evaluation points in GF(p)
        message_poly: Coefficients [a0, a1, ..., a_{k-1}] of message polynomial

    Returns:
        Codeword [p(α₀), p(α₁), ..., p(αₙ₋₁)]
    """
    codeword = []
    for alpha in eval_points:
        val = 0
        for j, coeff in enumerate(message_poly):
            val = gf.add(val, gf.mul(coeff, gf.pow(alpha, j)))
        codeword.append(val)
    return codeword


def hamming_weight(gf: GF, v: List[int]) -> int:
    """Number of nonzero entries."""
    return sum(1 for x in v if x % gf.p != 0)


def hamming_distance(gf: GF, u: List[int], v: List[int]) -> int:
    """Number of positions where u and v differ."""
    return sum(1 for a, b in zip(u, v) if (a - b) % gf.p != 0)


def rs_minimum_distance(gf: GF, eval_points: List[int], k: int,
                         num_samples: int = 1000) -> int:
    """
    Estimate minimum distance of RS(n, k) by sampling random nonzero codewords.

    For RS codes, the true minimum distance is n - k + 1 (MDS property).
    """
    n = len(eval_points)
    min_wt = n + 1
    for _ in range(num_samples):
        # Random nonzero polynomial of degree < k
        coeffs = [np.random.randint(0, gf.p) for _ in range(k)]
        if all(c == 0 for c in coeffs):
            coeffs[0] = 1
        cw = rs_encode(gf, eval_points, coeffs)
        wt = hamming_weight(gf, cw)
        if wt > 0:
            min_wt = min(min_wt, wt)
    return min_wt


def bch_syndrome(gf: GF, alpha: int, b: int, c: List[int], j: int) -> int:
    """
    Compute BCH syndrome S_j = sum_i c[i] * alpha^((b+j)*i).
    """
    n = len(c)
    s = 0
    for i in range(n):
        s = gf.add(s, gf.mul(c[i], gf.pow(alpha, (b + j) * i)))
    return s


def bch_check(gf: GF, alpha: int, b: int, delta: int,
              c: List[int]) -> bool:
    """Check if c satisfies BCH parity check conditions."""
    for j in range(delta - 1):
        if bch_syndrome(gf, alpha, b, c, j) != 0:
            return False
    return True


def berlekamp_massey(gf: GF, sequence: List[int]) -> List[int]:
    """
    Berlekamp-Massey algorithm: find the shortest linear recurrence
    generating the given sequence over GF(p).

    The algorithm maintains a connection polynomial C(x) and updates it
    iteratively to annihilate each new symbol while minimizing degree.

    Args:
        gf: Finite field GF(p)
        sequence: Input sequence [s₀, s₁, ..., s_{N-1}]

    Returns:
        Recurrence coefficients [c₁, c₂, ..., c_L] such that
        s[m] = c₁·s[m-1] + c₂·s[m-2] + ... + c_L·s[m-L] for m ≥ L.

    Time complexity: O(N²) field operations
    Space complexity: O(N)
    """
    N = len(sequence)
    # Connection polynomial coefficients (1 + c1*x + c2*x^2 + ...)
    C = [1]  # Current connection polynomial
    B = [1]  # Previous connection polynomial
    L = 0    # Current recurrence length
    x = 1    # Steps since last length change
    b_delta = 1  # Previous discrepancy at last length change

    for m in range(N):
        # Compute discrepancy
        d = sequence[m]
        for j in range(1, L + 1):
            if j < len(C):
                d = gf.add(d, gf.mul(C[j], sequence[m - j]))

        if d == 0:
            x += 1
        else:
            T = C.copy()
            # Update: C(x) -= (d/b) * x^x * B(x)
            coeff = gf.div(d, b_delta)
            # Pad C if needed
            needed_len = max(len(C), x + len(B))
            while len(C) < needed_len:
                C.append(0)
            for j in range(len(B)):
                C[j + x] = gf.sub(C[j + x], gf.mul(coeff, B[j]))

            if 2 * L <= m:
                L = m + 1 - L
                B = T
                b_delta = d
                x = 1
            else:
                x += 1

    # Extract recurrence coefficients (negate and drop leading 1)
    result = []
    for j in range(1, L + 1):
        if j < len(C):
            result.append(gf.neg(C[j]))
        else:
            result.append(0)
    return result


def syndrome_decode(gf: GF, eval_points: List[int], k: int,
                    received: List[int]) -> Optional[List[int]]:
    """
    Syndrome-based decoding for RS codes using Berlekamp-Massey.

    Given a received word r = c + e where c is a codeword and
    wt(e) ≤ t = (n-k)/2, recover the original codeword c.

    Steps:
    1. Compute syndromes S_j = r(α^j) for j = 1, ..., 2t
    2. Run Berlekamp-Massey on syndromes to find error-locator polynomial
    3. Find roots of error-locator (error positions)
    4. Solve for error values using Forney's algorithm
    5. Subtract errors from received word

    Args:
        gf: Finite field
        eval_points: Evaluation points α₀, ..., αₙ₋₁
        k: Message polynomial degree bound
        received: Received word (possibly corrupted)

    Returns:
        Decoded codeword, or None if decoding fails
    """
    n = len(eval_points)
    t = (n - k) // 2

    if t == 0:
        return received  # No error correction possible

    # Step 1: Compute 2t syndromes
    # For RS codes with eval points α₀, ..., αₙ₋₁, use a primitive element
    # S_j = sum_i r_i * α_i^j
    syndromes = []
    for j in range(1, 2 * t + 1):
        s = 0
        for i in range(n):
            s = gf.add(s, gf.mul(received[i], gf.pow(eval_points[i], j)))
        syndromes.append(s)

    # Check if all syndromes are zero (no errors)
    if all(s == 0 for s in syndromes):
        return received

    # Step 2: Berlekamp-Massey to find error-locator polynomial
    sigma_coeffs = berlekamp_massey(gf, syndromes)
    num_errors = len(sigma_coeffs)

    if num_errors > t:
        return None  # Too many errors

    # Step 3: Find error positions by Chien search
    # Error locator sigma(x) = 1 + sigma_1*x + ... + sigma_v*x^v
    # Roots are inverses of error locations
    error_positions = []
    for i in range(n):
        # Evaluate sigma at alpha_i^(-1)
        alpha_inv = gf.inv(eval_points[i]) if eval_points[i] != 0 else None
        if alpha_inv is None:
            continue
        val = 1
        for j, c in enumerate(sigma_coeffs):
            val = gf.add(val, gf.mul(c, gf.pow(alpha_inv, j + 1)))
        if val == 0:
            error_positions.append(i)

    if len(error_positions) != num_errors:
        return None  # Couldn't find all error positions

    # Step 4: Solve for error values
    # Set up system: for each syndrome j,
    # S_j = sum_{l in errors} e_l * alpha_l^j
    # This is a Vandermonde system
    v = len(error_positions)
    if v == 0:
        return received

    # Build Vandermonde matrix
    V = [[0] * v for _ in range(v)]
    for row in range(v):
        for col in range(v):
            pos = error_positions[col]
            V[row][col] = gf.pow(eval_points[pos], row + 1)

    # Solve V * e = S (first v syndromes)
    # Gaussian elimination
    S = [syndromes[j] for j in range(v)]
    augmented = [V[i] + [S[i]] for i in range(v)]

    for col in range(v):
        # Find pivot
        pivot = None
        for row in range(col, v):
            if augmented[row][col] != 0:
                pivot = row
                break
        if pivot is None:
            return None
        augmented[col], augmented[pivot] = augmented[pivot], augmented[col]

        # Eliminate
        inv_pivot = gf.inv(augmented[col][col])
        for row in range(v):
            if row != col and augmented[row][col] != 0:
                factor = gf.mul(augmented[row][col], inv_pivot)
                for j in range(v + 1):
                    augmented[row][j] = gf.sub(
                        augmented[row][j],
                        gf.mul(factor, augmented[col][j])
                    )

    # Extract error values
    error_values = []
    for i in range(v):
        error_values.append(gf.div(augmented[i][v], augmented[i][i]))

    # Step 5: Subtract errors
    corrected = received.copy()
    for pos, val in zip(error_positions, error_values):
        corrected[pos] = gf.sub(corrected[pos], val)

    return corrected


def verify_recurrence(gf: GF, coeffs: List[int], sequence: List[int]) -> bool:
    """Verify that coefficients define a valid recurrence for the sequence."""
    L = len(coeffs)
    for m in range(L, len(sequence)):
        predicted = 0
        for j, c in enumerate(coeffs):
            predicted = gf.add(predicted, gf.mul(c, sequence[m - j - 1]))
        if predicted != sequence[m]:
            return False
    return True


if __name__ == "__main__":
    # Example: RS(7, 3) over GF(7)
    gf7 = GF(7)
    eval_pts = list(range(7))  # [0, 1, 2, 3, 4, 5, 6]

    # Encode message [1, 2, 3] -> polynomial 1 + 2x + 3x²
    message = [1, 2, 3]
    codeword = rs_encode(gf7, eval_pts, message)
    print(f"Message:  {message}")
    print(f"Codeword: {codeword}")
    print(f"Weight:   {hamming_weight(gf7, codeword)}")

    # Introduce 2 errors
    received = codeword.copy()
    received[1] = (received[1] + 3) % 7  # Error at position 1
    received[4] = (received[4] + 5) % 7  # Error at position 4
    print(f"\nReceived (2 errors): {received}")
    print(f"Hamming distance:    {hamming_distance(gf7, codeword, received)}")

    # Decode
    decoded = syndrome_decode(gf7, eval_pts, 3, received)
    print(f"Decoded:  {decoded}")
    print(f"Correct:  {decoded == codeword}")

    # Verify minimum distance
    print(f"\nExpected min distance: {7 - 3 + 1} = 5")
    est_dist = rs_minimum_distance(gf7, eval_pts, 3, num_samples=5000)
    print(f"Estimated min distance (sampling): {est_dist}")

    # Berlekamp-Massey example
    print("\n--- Berlekamp-Massey ---")
    # Sequence satisfying s[n] = 3*s[n-1] + 2*s[n-2] mod 7
    seq = [1, 3]
    for _ in range(8):
        next_val = gf7.add(gf7.mul(3, seq[-1]), gf7.mul(2, seq[-2]))
        seq.append(next_val)
    print(f"Sequence: {seq}")

    recurrence = berlekamp_massey(gf7, seq)
    print(f"Recovered recurrence: {recurrence}")
    print(f"Verification: {verify_recurrence(gf7, recurrence, seq)}")
