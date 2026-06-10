"""
Algebraic Coding Theory Algorithms
===================================

Implementations of:
- Finite field arithmetic (GF(2^m) via polynomial representation)
- Reed-Solomon encoding and syndrome computation
- Berlekamp-Massey algorithm for finding minimal LFSR / error locator polynomial
- Syndrome Hankel matrix construction and rank analysis
- Error locator polynomial root finding (Chien search)
- Full RS decoder pipeline

All algorithms operate over GF(2^m) represented as integers mod an irreducible polynomial.
"""

from typing import List, Tuple, Optional, Dict
import numpy as np


# ============================================================
# Finite Field Arithmetic: GF(2^m)
# ============================================================

class GF:
    """Galois Field GF(2^m) arithmetic.

    Elements are represented as integers in [0, 2^m - 1].
    Multiplication uses a precomputed log/antilog table based on a primitive polynomial.

    Attributes:
        m: Extension degree.
        size: Number of field elements (2^m).
        prim_poly: Primitive polynomial (integer representation).
        exp_table: Antilog table: exp_table[i] = alpha^i.
        log_table: Log table: log_table[x] = i such that alpha^i = x.
    """

    def __init__(self, m: int, prim_poly: int):
        """Initialize GF(2^m) with given primitive polynomial.

        Args:
            m: Extension degree.
            prim_poly: Irreducible polynomial of degree m over GF(2),
                       represented as an integer (e.g., x^4 + x + 1 = 0b10011 = 19).
        """
        self.m = m
        self.size = 1 << m  # 2^m
        self.prim_poly = prim_poly

        # Build exp and log tables
        self.exp_table = [0] * (2 * self.size)
        self.log_table = [0] * self.size

        x = 1
        for i in range(self.size - 1):
            self.exp_table[i] = x
            self.log_table[x] = i
            x <<= 1
            if x >= self.size:
                x ^= prim_poly
        # Extend exp_table for easy modular access
        for i in range(self.size - 1, 2 * self.size):
            self.exp_table[i] = self.exp_table[i - (self.size - 1)]

    def mul(self, a: int, b: int) -> int:
        """Multiply two field elements."""
        if a == 0 or b == 0:
            return 0
        return self.exp_table[(self.log_table[a] + self.log_table[b]) % (self.size - 1)]

    def div(self, a: int, b: int) -> int:
        """Divide a by b (b must be nonzero)."""
        if b == 0:
            raise ZeroDivisionError("Division by zero in GF")
        if a == 0:
            return 0
        return self.exp_table[(self.log_table[a] - self.log_table[b]) % (self.size - 1)]

    def inv(self, a: int) -> int:
        """Multiplicative inverse."""
        if a == 0:
            raise ZeroDivisionError("Zero has no inverse")
        return self.exp_table[(self.size - 1 - self.log_table[a]) % (self.size - 1)]

    def pow(self, a: int, n: int) -> int:
        """Exponentiation a^n."""
        if a == 0:
            return 0 if n > 0 else 1
        return self.exp_table[(self.log_table[a] * n) % (self.size - 1)]

    def add(self, a: int, b: int) -> int:
        """Addition (= XOR in characteristic 2)."""
        return a ^ b

    def sub(self, a: int, b: int) -> int:
        """Subtraction (= addition in characteristic 2)."""
        return a ^ b

    def alpha(self, i: int) -> int:
        """Return α^i."""
        return self.exp_table[i % (self.size - 1)]

    def poly_eval(self, coeffs: List[int], x: int) -> int:
        """Evaluate polynomial (coeffs[i] = coefficient of x^i) at point x."""
        result = 0
        for i in range(len(coeffs) - 1, -1, -1):
            result = self.add(self.mul(result, x), coeffs[i])
        return result


# ============================================================
# Standard GF instances
# ============================================================

# GF(2^4) with primitive polynomial x^4 + x + 1
GF16 = GF(4, 0b10011)

# GF(2^8) with primitive polynomial x^8 + x^4 + x^3 + x^2 + 1
GF256 = GF(8, 0b100011101)


# ============================================================
# Reed-Solomon Encoding
# ============================================================

def rs_generator_poly(gf: GF, nsym: int, fcr: int = 1) -> List[int]:
    """Compute the RS generator polynomial g(x) = ∏(x - α^i) for i = fcr..fcr+nsym-1.

    Args:
        gf: Galois field.
        nsym: Number of check symbols (= designed distance - 1).
        fcr: First consecutive root index.

    Returns:
        Coefficients of g(x), lowest degree first.
    """
    g = [1]
    for i in range(fcr, fcr + nsym):
        # Multiply g by (x - alpha^i) = (x + alpha^i) in char 2
        root = gf.alpha(i)
        new_g = [0] * (len(g) + 1)
        for j in range(len(g)):
            new_g[j] = gf.add(new_g[j], gf.mul(g[j], root))
            new_g[j + 1] = gf.add(new_g[j + 1], g[j])
        g = new_g
    return g


def rs_encode(gf: GF, msg: List[int], nsym: int, fcr: int = 1) -> List[int]:
    """Systematic RS encoding.

    Args:
        gf: Galois field.
        msg: Message symbols (k symbols).
        nsym: Number of check symbols.
        fcr: First consecutive root.

    Returns:
        Codeword of length k + nsym (message followed by check symbols).
    """
    gen = rs_generator_poly(gf, nsym, fcr)
    # msg_poly * x^nsym
    padded = [0] * nsym + msg
    # Polynomial long division
    for i in range(len(msg) - 1, -1, -1):
        coeff = padded[i + nsym]
        if coeff != 0:
            for j in range(len(gen)):
                padded[i + j] = gf.add(padded[i + j], gf.mul(gen[j], coeff))
    # Check symbols are the remainder
    check = padded[:nsym]
    return check + msg


# ============================================================
# Syndrome Computation
# ============================================================

def compute_syndromes(gf: GF, received: List[int], nsym: int, fcr: int = 1) -> List[int]:
    """Compute syndromes S_i = r(α^i) for i = fcr..fcr+nsym-1.

    Args:
        gf: Galois field.
        received: Received word.
        nsym: Number of syndromes to compute.
        fcr: First consecutive root index.

    Returns:
        List of nsym syndromes.
    """
    syndromes = []
    for i in range(fcr, fcr + nsym):
        s = gf.poly_eval(received, gf.alpha(i))
        syndromes.append(s)
    return syndromes


# ============================================================
# Berlekamp-Massey Algorithm
# ============================================================

def berlekamp_massey(gf: GF, syndromes: List[int]) -> List[int]:
    """Berlekamp-Massey algorithm for finding the error locator polynomial.

    Given a sequence of syndromes, finds the shortest LFSR (minimal polynomial)
    that generates the sequence. This is the error locator polynomial σ(x).

    The algorithm maintains:
    - C(x): current connection polynomial (error locator candidate)
    - B(x): previous connection polynomial
    - L: current LFSR length
    - delta: discrepancy

    Args:
        gf: Galois field.
        syndromes: List of syndrome values [S_0, S_1, ..., S_{N-1}].

    Returns:
        Coefficients of the error locator polynomial σ(x), lowest degree first.
        σ(x) is monic: σ_L = 1 where L = deg(σ).

    Docstring:
        This implements the iterative Berlekamp-Massey procedure. At each step k,
        it computes the discrepancy Δ = S_k + Σ_{j=1}^L C_j S_{k-j}.
        If Δ ≠ 0, it updates C(x) to maintain the LFSR invariant.
        The key theorem (proved formally in our Lean development) is that the
        output polynomial is the unique minimal annihilator of the syndrome sequence.
    """
    N = len(syndromes)
    # C = current error locator, B = previous, both stored as coefficient lists
    C = [1]  # σ(x) = 1 initially
    B = [1]  # Previous polynomial
    L = 0    # Current LFSR length
    m = 1    # Shift counter
    b = 1    # Previous discrepancy

    for n in range(N):
        # Compute discrepancy
        delta = syndromes[n]
        for j in range(1, len(C)):
            if n - j >= 0:
                delta = gf.add(delta, gf.mul(C[j], syndromes[n - j]))

        if delta == 0:
            m += 1
        elif 2 * L <= n:
            # Update: need to increase LFSR length
            T = list(C)
            coeff = gf.div(delta, b)
            # C(x) = C(x) - (delta/b) * x^m * B(x)
            shifted_B = [0] * m + B
            while len(C) < len(shifted_B):
                C.append(0)
            for j in range(len(shifted_B)):
                C[j] = gf.add(C[j], gf.mul(coeff, shifted_B[j]))
            L = n + 1 - L
            B = T
            b = delta
            m = 1
        else:
            # Update without increasing length
            coeff = gf.div(delta, b)
            shifted_B = [0] * m + B
            while len(C) < len(shifted_B):
                C.append(0)
            for j in range(len(shifted_B)):
                C[j] = gf.add(C[j], gf.mul(coeff, shifted_B[j]))
            m += 1

    return C


# ============================================================
# Chien Search: Find roots of the error locator polynomial
# ============================================================

def chien_search(gf: GF, sigma: List[int]) -> List[int]:
    """Find error positions by evaluating σ(x) at all field elements.

    For an [n,k] RS code over GF(2^m), the error positions are
    {j : σ(α^{-j}) = 0} = {j : α^j is a root of the reversed locator}.

    Args:
        gf: Galois field.
        sigma: Error locator polynomial coefficients.

    Returns:
        List of error positions (as power-of-α indices).
    """
    positions = []
    n = gf.size - 1  # Codeword length
    for i in range(n):
        # Evaluate σ at α^{-i} = α^{n-i}
        val = gf.poly_eval(sigma, gf.alpha(n - i))
        if val == 0:
            positions.append(i)
    return positions


# ============================================================
# Forney Algorithm: Compute error magnitudes
# ============================================================

def forney_algorithm(gf: GF, sigma: List[int], syndromes: List[int],
                     positions: List[int], fcr: int = 1) -> Dict[int, int]:
    """Compute error magnitudes using Forney's algorithm.

    Args:
        gf: Galois field.
        sigma: Error locator polynomial.
        syndromes: Syndrome values.
        positions: Error positions from Chien search.
        fcr: First consecutive root.

    Returns:
        Dictionary mapping error position -> error magnitude.
    """
    nsym = len(syndromes)
    # Compute error evaluator polynomial Ω(x) = S(x)σ(x) mod x^nsym
    # where S(x) = Σ S_i x^i
    omega = [0] * nsym
    for i in range(nsym):
        for j in range(min(i + 1, len(sigma))):
            omega[i] = gf.add(omega[i], gf.mul(sigma[j], syndromes[i - j]))

    # Compute formal derivative σ'(x)
    # In characteristic 2, σ'(x) = σ_1 + σ_3 x^2 + σ_5 x^4 + ...
    sigma_deriv = []
    for i in range(1, len(sigma)):
        if i % 2 == 1:
            sigma_deriv.append(sigma[i])
        else:
            sigma_deriv.append(0)
    if not sigma_deriv:
        sigma_deriv = [0]

    magnitudes = {}
    for pos in positions:
        Xi_inv = gf.alpha(pos)  # α^pos
        # e_j = -X_j * Ω(X_j^{-1}) / σ'(X_j^{-1})  (adjusting for fcr)
        Xi = gf.inv(Xi_inv) if Xi_inv != 0 else 0
        # Adjust for fcr
        Xi_fcr = gf.pow(Xi, 1 - fcr) if Xi != 0 else 0

        omega_val = gf.poly_eval(omega, Xi)
        sigma_d_val = gf.poly_eval(sigma_deriv, Xi)

        if sigma_d_val != 0:
            magnitude = gf.mul(Xi_fcr, gf.div(omega_val, sigma_d_val))
            magnitudes[pos] = magnitude
        else:
            magnitudes[pos] = 0

    return magnitudes


# ============================================================
# Syndrome Hankel Matrix
# ============================================================

def syndrome_hankel_matrix(syndromes: List[int], m: int) -> np.ndarray:
    """Construct the m×m syndrome Hankel matrix H[i,j] = S_{i+j}.

    The rank of this matrix equals the number of errors (over the appropriate field).
    This is the bridge between coding theory and structured linear algebra.

    Args:
        syndromes: Syndrome sequence [S_0, S_1, ...].
        m: Matrix dimension.

    Returns:
        m×m numpy array (integer entries from the field).
    """
    H = np.zeros((m, m), dtype=int)
    for i in range(m):
        for j in range(m):
            idx = i + j
            if idx < len(syndromes):
                H[i, j] = syndromes[idx]
    return H


def hankel_rank_gf2(H: np.ndarray) -> int:
    """Compute rank of a matrix over GF(2) using Gaussian elimination.

    Args:
        H: Integer matrix (entries 0 or 1).

    Returns:
        Rank over GF(2).
    """
    m = H.shape[0]
    A = H.copy() % 2
    rank = 0
    for col in range(min(A.shape[0], A.shape[1])):
        # Find pivot
        pivot = None
        for row in range(rank, m):
            if A[row, col] % 2 == 1:
                pivot = row
                break
        if pivot is None:
            continue
        # Swap
        A[[rank, pivot]] = A[[pivot, rank]]
        # Eliminate
        for row in range(m):
            if row != rank and A[row, col] % 2 == 1:
                A[row] = (A[row] + A[rank]) % 2
        rank += 1
    return rank


# ============================================================
# Full RS Decoder
# ============================================================

def rs_decode(gf: GF, received: List[int], nsym: int, fcr: int = 1) -> Optional[List[int]]:
    """Full Reed-Solomon decoder using Berlekamp-Massey.

    Pipeline:
    1. Compute syndromes
    2. If all zero, no errors
    3. Run Berlekamp-Massey to find error locator
    4. Chien search for error positions
    5. Forney algorithm for error magnitudes
    6. Correct errors

    Args:
        gf: Galois field.
        received: Received word (may contain errors).
        nsym: Number of check symbols.
        fcr: First consecutive root.

    Returns:
        Corrected codeword, or None if decoding fails.
    """
    syndromes = compute_syndromes(gf, received, nsym, fcr)

    # Check if error-free
    if all(s == 0 for s in syndromes):
        return list(received)

    # Find error locator polynomial
    sigma = berlekamp_massey(gf, syndromes)
    num_errors = len(sigma) - 1

    # Check if too many errors
    if num_errors > nsym // 2:
        return None  # Decoding failure

    # Find error positions
    positions = chien_search(gf, sigma)
    if len(positions) != num_errors:
        return None  # Decoding failure

    # Compute error magnitudes
    magnitudes = forney_algorithm(gf, sigma, syndromes, positions, fcr)

    # Correct errors
    corrected = list(received)
    for pos in positions:
        if pos < len(corrected):
            corrected[pos] = gf.add(corrected[pos], magnitudes.get(pos, 0))

    return corrected


if __name__ == "__main__":
    # Quick self-test
    gf = GF16
    msg = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]
    nsym = 4
    codeword = rs_encode(gf, msg, nsym)
    print(f"Message:  {msg}")
    print(f"Codeword: {codeword}")

    # Inject errors
    received = list(codeword)
    received[0] ^= 5
    received[3] ^= 9
    print(f"Received: {received}")

    # Decode
    decoded = rs_decode(gf, received, nsym)
    print(f"Decoded:  {decoded}")
    print(f"Match:    {decoded == codeword}")
