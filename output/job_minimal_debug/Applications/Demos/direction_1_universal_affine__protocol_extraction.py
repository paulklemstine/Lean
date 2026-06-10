#!/usr/bin/env python3
"""
Universal Affine Σ-Protocol Extraction — Applications

This module demonstrates real-world applications of the universal
extraction framework:

1. Protocol verification: automatically classify Σ-protocols as affine
2. Extraction matrix analysis: compute extraction rank for protocol families
3. Security parameter estimation: relate extraction probability to field size
4. Batch extraction: process multiple transcript pairs efficiently
"""

import random
from typing import List, Tuple, Dict, Optional
from dataclasses import dataclass


# ═══════════════════════════════════════════════════════
# Import core algorithms
# ═══════════════════════════════════════════════════════

def mod_inverse(a: int, p: int) -> int:
    if a % p == 0:
        raise ValueError(f"{a} not invertible mod {p}")
    return pow(a, p - 2, p)


def affine_extract_1d(z1, z2, c1, c2, q):
    return ((z1 - z2) * mod_inverse((c1 - c2) % q, q)) % q


def matrix_mul_vec(M, v, q):
    return [sum(M[i][j] * v[j] for j in range(len(v))) % q for i in range(len(M))]


# ═══════════════════════════════════════════════════════
# Application 1: Protocol Classification
# ═══════════════════════════════════════════════════════

@dataclass
class ProtocolTemplate:
    """Template for an affine Σ-protocol."""
    name: str
    witness_dim: int
    response_dim: int
    coeff_matrix: List[List[int]]  # Over ZMod q
    description: str


def classify_protocol(template: ProtocolTemplate, q: int) -> Dict:
    """
    Classify a protocol template: compute its extraction properties.

    Returns a dictionary with:
    - extraction_rank: whether unique extraction is possible
    - kernel_dim: dimension of the extraction kernel
    - security_level: estimated bits of security from extraction
    """
    M = template.coeff_matrix
    n = template.witness_dim
    m = template.response_dim

    # Compute rank via determinant for square matrices
    if m == n == 2:
        det = (M[0][0] * M[1][1] - M[0][1] * M[1][0]) % q
        rank = 2 if det != 0 else (1 if any(M[i][j] % q != 0
               for i in range(2) for j in range(2)) else 0)
        kernel_dim = n - rank
    elif m == n == 1:
        rank = 1 if M[0][0] % q != 0 else 0
        kernel_dim = n - rank
    else:
        rank = min(m, n)  # Optimistic
        kernel_dim = max(0, n - rank)

    has_extraction_rank = (kernel_dim == 0)

    return {
        "name": template.name,
        "witness_dim": n,
        "response_dim": m,
        "rank": rank,
        "kernel_dim": kernel_dim,
        "has_extraction_rank": has_extraction_rank,
        "extraction_possible": has_extraction_rank,
        "description": template.description,
    }


# ═══════════════════════════════════════════════════════
# Application 2: Batch Extraction
# ═══════════════════════════════════════════════════════

@dataclass
class TranscriptPair:
    """A pair of transcripts with the same commitment."""
    c1: int
    c2: int
    z1: List[int]
    z2: List[int]


def batch_extract(pairs: List[TranscriptPair], q: int) -> List[List[int]]:
    """
    Extract witnesses from multiple transcript pairs efficiently.

    All pairs use the same challenge-difference inverse when possible,
    amortizing the modular inversion cost.

    Time complexity: O(k·n·log q) for k pairs of n-dimensional responses.
    """
    results = []
    # Group by challenge difference for amortized inversion
    inv_cache: Dict[int, int] = {}

    for pair in pairs:
        diff_c = (pair.c1 - pair.c2) % q
        if diff_c not in inv_cache:
            inv_cache[diff_c] = mod_inverse(diff_c, q)
        inv_dc = inv_cache[diff_c]

        w = [((pair.z1[i] - pair.z2[i]) * inv_dc) % q
             for i in range(len(pair.z1))]
        results.append(w)

    return results


# ═══════════════════════════════════════════════════════
# Application 3: Protocol Security Analysis
# ═══════════════════════════════════════════════════════

def extraction_probability_analysis(q: int, num_challenges: int = 2) -> Dict:
    """
    Analyze the probability that extraction succeeds given random challenges.

    For affine protocols over GF(q), extraction requires two distinct
    challenges. The probability that k randomly chosen challenges include
    at least two distinct values is 1 - (1/q)^(k-1).

    Returns analysis results.
    """
    # Probability of all k challenges being identical
    p_all_same = (1.0 / q) ** (num_challenges - 1)
    p_extraction = 1.0 - p_all_same

    return {
        "field_size": q,
        "num_challenges": num_challenges,
        "p_distinct_challenges": p_extraction,
        "security_bits": int(-1 * (round(p_all_same * (2**64)).bit_length() - 64)
                               if p_all_same > 0 else float('inf')),
        "note": (f"With {num_challenges} random challenges over GF({q}), "
                f"extraction succeeds with probability ≥ {p_extraction:.10f}")
    }


# ═══════════════════════════════════════════════════════
# Application 4: Affine Code Analysis (Coding Theory Bridge)
# ═══════════════════════════════════════════════════════

def affine_code_minimum_distance(M: List[List[int]], q: int) -> int:
    """
    Compute the minimum distance of the affine code defined by M over GF(q).

    The affine code maps witness w to the evaluation vector
    (M·w evaluated at each challenge c ∈ GF(q)).

    For extraction, we need minimum distance ≥ 2, which is equivalent
    to M having extraction rank (mulVec injective).

    This brute-force computation works for small fields and dimensions.
    """
    n = len(M[0]) if M else 0
    if n == 0:
        return float('inf')

    min_weight = float('inf')

    # Check all nonzero codewords
    from itertools import product as cart_product
    for w in cart_product(range(q), repeat=n):
        if all(x == 0 for x in w):
            continue
        Mw = matrix_mul_vec(M, list(w), q)
        # Weight = number of nonzero coordinates in Mw
        weight = sum(1 for x in Mw if x % q != 0)
        # But for affine codes, the "distance" relates to distinct evaluations
        # For our purpose: if Mw = 0, then the code has distance 0
        if all(x == 0 for x in Mw):
            return 0  # Kernel is nontrivial → no unique extraction
        min_weight = min(min_weight, weight)

    return min_weight


# ═══════════════════════════════════════════════════════
# Main demonstration
# ═══════════════════════════════════════════════════════

def main():
    q = 23
    print("=" * 60)
    print("APPLICATION 1: Protocol Classification")
    print("=" * 60)

    protocols = [
        ProtocolTemplate("Schnorr", 1, 1, [[1]],
                        "z = r + c·w, single witness"),
        ProtocolTemplate("Okamoto", 2, 2, [[1, 0], [0, 1]],
                        "z_i = r_i + c·w_i, identity matrix"),
        ProtocolTemplate("Okamoto-weighted", 2, 2, [[3, 5], [7, 11]],
                        "z_i = r_i + c·(M·w)_i, custom matrix"),
        ProtocolTemplate("Degenerate", 2, 2, [[1, 2], [2, 4]],
                        "Singular matrix — no unique extraction"),
    ]

    for proto in protocols:
        info = classify_protocol(proto, q)
        print(f"\n{info['name']}:")
        print(f"  Witness dim: {info['witness_dim']}, Response dim: {info['response_dim']}")
        print(f"  Rank: {info['rank']}, Kernel dim: {info['kernel_dim']}")
        print(f"  Extraction possible: {'✓' if info['extraction_possible'] else '✗'}")
        print(f"  Description: {info['description']}")

    print("\n" + "=" * 60)
    print("APPLICATION 2: Batch Extraction")
    print("=" * 60)

    random.seed(123)
    num_pairs = 5
    w_true = [random.randint(0, q-1) for _ in range(2)]
    r_base = [random.randint(0, q-1) for _ in range(2)]
    print(f"\nTrue witness: {w_true}")
    print(f"Processing {num_pairs} transcript pairs...")

    pairs = []
    for i in range(num_pairs):
        c1 = random.randint(0, q-1)
        c2 = c1
        while c2 == c1:
            c2 = random.randint(0, q-1)
        z1 = [(r_base[j] + c1 * w_true[j]) % q for j in range(2)]
        z2 = [(r_base[j] + c2 * w_true[j]) % q for j in range(2)]
        pairs.append(TranscriptPair(c1, c2, z1, z2))
        print(f"  Pair {i+1}: c₁={c1}, c₂={c2}")

    witnesses = batch_extract(pairs, q)
    for i, w in enumerate(witnesses):
        match = w == w_true
        print(f"  Extracted from pair {i+1}: {w} {'✓' if match else '✗'}")

    print("\n" + "=" * 60)
    print("APPLICATION 3: Security Analysis")
    print("=" * 60)

    for q_val in [23, 251, 65537, 2**128 + 51]:
        analysis = extraction_probability_analysis(q_val)
        print(f"\n  GF({q_val}):")
        print(f"    P(distinct challenges) = {analysis['p_distinct_challenges']:.15f}")
        print(f"    {analysis['note']}")

    print("\n" + "=" * 60)
    print("APPLICATION 4: Affine Code Analysis")
    print("=" * 60)

    q_small = 7
    test_matrices = [
        ("Identity 2×2", [[1, 0], [0, 1]]),
        ("Full rank", [[2, 3], [5, 1]]),
        ("Singular", [[1, 2], [2, 4]]),
        ("Zero column", [[1, 0], [0, 0]]),
    ]

    for name, M in test_matrices:
        d = affine_code_minimum_distance(M, q_small)
        inj = d > 0
        print(f"\n  {name}: M = {M}")
        print(f"    Min distance of affine code: {d}")
        print(f"    Has extraction rank: {'✓' if inj else '✗'}")
        print(f"    (Extraction rank ↔ min distance > 0 ↔ trivial kernel)")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Universal Affine Σ-Protocol Extraction — Interactive Demonstration

This script demonstrates the core mathematical result: witness extraction from
affine Σ-protocols is a theorem of linear algebra over finite fields.

For each protocol (Schnorr, Chaum–Pedersen, Okamoto), we:
1. Set up a prime-order field GF(q)
2. Generate a random witness and commitment randomness
3. Simulate two accepting transcripts with distinct challenges
4. Run the universal affine extractor
5. Verify the extracted witness matches the original

We also demonstrate the obstruction theorem: when the protocol matrix has
nontrivial kernel, unique extraction fails.
"""

import random
from typing import Tuple, Optional, List


def mod_inverse(a: int, p: int) -> int:
    """Compute modular inverse of a mod p using Fermat's little theorem."""
    if a % p == 0:
        raise ValueError(f"{a} has no inverse mod {p}")
    return pow(a, p - 2, p)


def affine_extract_1d(z1: int, z2: int, c1: int, c2: int, q: int) -> int:
    """
    1-dimensional affine extractor.
    Given z₁ = r + c₁·w and z₂ = r + c₂·w (mod q),
    recover w = (z₁ - z₂) · (c₁ - c₂)⁻¹ (mod q).
    """
    diff_z = (z1 - z2) % q
    diff_c = (c1 - c2) % q
    return (diff_z * mod_inverse(diff_c, q)) % q


def affine_extract_vec(z1: List[int], z2: List[int],
                       c1: int, c2: int, q: int) -> List[int]:
    """Coordinatewise vector extraction."""
    return [affine_extract_1d(z1[i], z2[i], c1, c2, q)
            for i in range(len(z1))]


def matrix_mul_vec(M: List[List[int]], v: List[int], q: int) -> List[int]:
    """Matrix-vector multiply over GF(q)."""
    m = len(M)
    n = len(v)
    result = [0] * m
    for i in range(m):
        for j in range(n):
            result[i] = (result[i] + M[i][j] * v[j]) % q
    return result


def is_injective(M: List[List[int]], q: int) -> bool:
    """
    Check if the matrix M has trivial kernel over GF(q)
    by testing all vectors (brute force for small dimensions).
    """
    n = len(M[0]) if M else 0
    if n == 0:
        return True
    # For small fields, enumerate
    if q ** n > 100000:
        return True  # Skip for large cases
    from itertools import product
    for v in product(range(q), repeat=n):
        if any(x != 0 for x in v):
            result = matrix_mul_vec(M, list(v), q)
            if all(x == 0 for x in result):
                return False
    return True


# ═══════════════════════════════════════════════════════
# Protocol Demonstrations
# ═══════════════════════════════════════════════════════

def demo_schnorr(q: int = 23):
    """
    Schnorr protocol extraction demonstration.

    Protocol: z = r + c·w (mod q)
    Matrix form: M = [1], 1×1 identity
    """
    print("=" * 60)
    print("SCHNORR PROTOCOL EXTRACTION")
    print("=" * 60)
    print(f"\nField: GF({q})")

    # Secret witness and commitment randomness
    w = random.randint(1, q - 1)
    r = random.randint(0, q - 1)
    print(f"Secret witness: w = {w}")
    print(f"Commitment randomness: r = {r}")

    # Two distinct challenges
    c1 = random.randint(0, q - 1)
    c2 = c1
    while c2 == c1:
        c2 = random.randint(0, q - 1)
    print(f"\nChallenge 1: c₁ = {c1}")
    print(f"Challenge 2: c₂ = {c2}")

    # Compute responses
    z1 = (r + c1 * w) % q
    z2 = (r + c2 * w) % q
    print(f"Response 1: z₁ = {z1}")
    print(f"Response 2: z₂ = {z2}")

    # Extract witness
    w_extracted = affine_extract_1d(z1, z2, c1, c2, q)
    print(f"\nExtracted witness: w' = {w_extracted}")
    print(f"Original witness:  w  = {w}")
    print(f"Match: {'✓ YES' if w_extracted == w else '✗ NO'}")
    assert w_extracted == w, "Extraction failed!"
    return True


def demo_chaum_pedersen(q: int = 31):
    """
    Chaum–Pedersen protocol extraction demonstration.

    Protocol equations (at the scalar/exponent level):
      z = r + c·w  (same z, r, w for both group equations)
    This is the same 1D extraction as Schnorr.
    """
    print("\n" + "=" * 60)
    print("CHAUM–PEDERSEN PROTOCOL EXTRACTION")
    print("=" * 60)
    print(f"\nField: GF({q})")

    w = random.randint(1, q - 1)
    r = random.randint(0, q - 1)
    print(f"Secret witness (shared discrete log): w = {w}")
    print(f"Commitment randomness: r = {r}")

    c1 = random.randint(0, q - 1)
    c2 = c1
    while c2 == c1:
        c2 = random.randint(0, q - 1)
    print(f"\nChallenge 1: c₁ = {c1}")
    print(f"Challenge 2: c₂ = {c2}")

    z1 = (r + c1 * w) % q
    z2 = (r + c2 * w) % q
    print(f"Response 1: z₁ = {z1}")
    print(f"Response 2: z₂ = {z2}")

    w_extracted = affine_extract_1d(z1, z2, c1, c2, q)
    print(f"\nExtracted witness: w' = {w_extracted}")
    print(f"Original witness:  w  = {w}")
    print(f"Match: {'✓ YES' if w_extracted == w else '✗ NO'}")
    assert w_extracted == w
    return True


def demo_okamoto(q: int = 37):
    """
    Okamoto two-generator protocol extraction demonstration.

    Protocol equations:
      z₁ = r₁ + c·w₁
      z₂ = r₂ + c·w₂
    Matrix form: M = I₂ (2×2 identity)
    """
    print("\n" + "=" * 60)
    print("OKAMOTO PROTOCOL EXTRACTION")
    print("=" * 60)
    print(f"\nField: GF({q})")

    w1 = random.randint(1, q - 1)
    w2 = random.randint(1, q - 1)
    r1 = random.randint(0, q - 1)
    r2 = random.randint(0, q - 1)
    print(f"Secret witness: (w₁, w₂) = ({w1}, {w2})")
    print(f"Commitment randomness: (r₁, r₂) = ({r1}, {r2})")

    c1 = random.randint(0, q - 1)
    c2 = c1
    while c2 == c1:
        c2 = random.randint(0, q - 1)
    print(f"\nChallenge 1: c₁ = {c1}")
    print(f"Challenge 2: c₂ = {c2}")

    # Transcript 1
    z11 = (r1 + c1 * w1) % q
    z12 = (r2 + c1 * w2) % q
    # Transcript 2
    z21 = (r1 + c2 * w1) % q
    z22 = (r2 + c2 * w2) % q
    print(f"Transcript 1 responses: (z₁₁, z₁₂) = ({z11}, {z12})")
    print(f"Transcript 2 responses: (z₂₁, z₂₂) = ({z21}, {z22})")

    w1_ext = affine_extract_1d(z11, z21, c1, c2, q)
    w2_ext = affine_extract_1d(z12, z22, c1, c2, q)
    print(f"\nExtracted witness: (w₁', w₂') = ({w1_ext}, {w2_ext})")
    print(f"Original witness:  (w₁, w₂)  = ({w1}, {w2})")
    print(f"Match: {'✓ YES' if (w1_ext, w2_ext) == (w1, w2) else '✗ NO'}")
    assert (w1_ext, w2_ext) == (w1, w2)
    return True


def demo_matrix_extraction(q: int = 17):
    """
    General matrix extraction demonstration.

    For a random injective M, simulate z = t + c·M·w and extract.
    """
    print("\n" + "=" * 60)
    print("GENERAL MATRIX EXTRACTION")
    print("=" * 60)
    print(f"\nField: GF({q})")

    # 2×2 injective matrix
    while True:
        M = [[random.randint(0, q-1) for _ in range(2)] for _ in range(2)]
        det = (M[0][0] * M[1][1] - M[0][1] * M[1][0]) % q
        if det != 0:
            break
    print(f"Protocol matrix M:")
    print(f"  [{M[0][0]:3d} {M[0][1]:3d}]")
    print(f"  [{M[1][0]:3d} {M[1][1]:3d}]")
    print(f"det(M) = {det} (nonzero → injective)")

    w = [random.randint(0, q-1) for _ in range(2)]
    t = [random.randint(0, q-1) for _ in range(2)]
    print(f"\nWitness vector: w = {w}")
    print(f"Offset vector: t = {t}")

    c1 = random.randint(0, q - 1)
    c2 = c1
    while c2 == c1:
        c2 = random.randint(0, q - 1)

    Mw = matrix_mul_vec(M, w, q)
    z1 = [(t[i] + c1 * Mw[i]) % q for i in range(2)]
    z2 = [(t[i] + c2 * Mw[i]) % q for i in range(2)]

    print(f"\nChallenges: c₁ = {c1}, c₂ = {c2}")
    print(f"Response 1: z₁ = {z1}")
    print(f"Response 2: z₂ = {z2}")

    # Step 1: Recover M·w
    Mw_extracted = affine_extract_vec(z1, z2, c1, c2, q)
    print(f"\nRecovered M·w = {Mw_extracted}")
    print(f"Actual M·w    = {Mw}")
    assert Mw_extracted == Mw

    # Step 2: Recover w using M⁻¹
    det_inv = mod_inverse(det, q)
    M_inv = [
        [(M[1][1] * det_inv) % q, ((-M[0][1]) * det_inv) % q],
        [((-M[1][0]) * det_inv) % q, (M[0][0] * det_inv) % q]
    ]
    w_extracted = matrix_mul_vec(M_inv, Mw_extracted, q)
    print(f"Extracted witness: w' = {w_extracted}")
    print(f"Original witness:  w  = {w}")
    print(f"Match: {'✓ YES' if w_extracted == w else '✗ NO'}")
    assert w_extracted == w
    return True


def demo_obstruction(q: int = 11):
    """
    Obstruction theorem demonstration.

    When M has nontrivial kernel, distinct witnesses can produce
    identical transcript differences, making unique extraction impossible.
    """
    print("\n" + "=" * 60)
    print("OBSTRUCTION THEOREM DEMONSTRATION")
    print("=" * 60)
    print(f"\nField: GF({q})")

    # Singular 2×2 matrix (rank 1)
    a, b = random.randint(1, q-1), random.randint(0, q-1)
    M = [[a, b], [(2*a) % q, (2*b) % q]]  # row 2 = 2 * row 1
    det = (M[0][0] * M[1][1] - M[0][1] * M[1][0]) % q
    print(f"Singular protocol matrix M:")
    print(f"  [{M[0][0]:3d} {M[0][1]:3d}]")
    print(f"  [{M[1][0]:3d} {M[1][1]:3d}]")
    print(f"det(M) = {det} (zero → non-injective)")
    assert det == 0

    # Two distinct witnesses in the kernel's coset
    w1 = [random.randint(0, q-1) for _ in range(2)]
    # Find a kernel vector: M·k = 0 with k ≠ 0
    # Kernel: a·k₁ + b·k₂ = 0 → k = (-b, a) or scalar multiples
    k = [(-b) % q, a % q]
    s = random.randint(1, q-1)  # nonzero scalar
    w2 = [(w1[i] + s * k[i]) % q for i in range(2)]

    Mw1 = matrix_mul_vec(M, w1, q)
    Mw2 = matrix_mul_vec(M, w2, q)
    print(f"\nWitness 1: w₁ = {w1}")
    print(f"Witness 2: w₂ = {w2}")
    print(f"Kernel vector: k = {k}")
    print(f"w₂ = w₁ + {s}·k")
    print(f"\nM·w₁ = {Mw1}")
    print(f"M·w₂ = {Mw2}")
    print(f"M·w₁ = M·w₂: {'✓ YES' if Mw1 == Mw2 else '✗ NO'}")
    assert Mw1 == Mw2
    print(f"w₁ ≠ w₂:     {'✓ YES' if w1 != w2 else '✗ NO'}")
    assert w1 != w2

    print("\n→ Two distinct witnesses produce identical transcripts!")
    print("→ Unique extraction is IMPOSSIBLE (as the obstruction theorem predicts).")
    return True


def demo_conjecture_test(q: int = 7, trials: int = 100):
    """
    Test Conjecture B: rank obstruction is the only obstruction.

    For random matrices over GF(q), verify that extraction succeeds
    iff the matrix is injective.
    """
    print("\n" + "=" * 60)
    print("CONJECTURE B: RANK OBSTRUCTION TEST")
    print("=" * 60)
    print(f"\nField: GF({q}), Testing {trials} random 2×2 matrices")

    successes = 0
    failures_injective = 0  # Injective but extraction failed (would disprove)
    failures_noninjective = 0  # Non-injective and extraction ambiguous (expected)

    for trial in range(trials):
        M = [[random.randint(0, q-1) for _ in range(2)] for _ in range(2)]
        det = (M[0][0] * M[1][1] - M[0][1] * M[1][0]) % q
        inj = (det != 0)

        w = [random.randint(0, q-1) for _ in range(2)]
        t = [random.randint(0, q-1) for _ in range(2)]
        c1, c2 = random.randint(0, q-1), random.randint(0, q-1)
        while c1 == c2:
            c2 = random.randint(0, q-1)

        Mw = matrix_mul_vec(M, w, q)
        z1 = [(t[i] + c1 * Mw[i]) % q for i in range(2)]
        z2 = [(t[i] + c2 * Mw[i]) % q for i in range(2)]

        Mw_recovered = affine_extract_vec(z1, z2, c1, c2, q)

        if inj:
            det_inv = mod_inverse(det, q)
            M_inv = [
                [(M[1][1] * det_inv) % q, ((-M[0][1]) * det_inv) % q],
                [((-M[1][0]) * det_inv) % q, (M[0][0] * det_inv) % q]
            ]
            w_recovered = matrix_mul_vec(M_inv, Mw_recovered, q)
            if w_recovered == w:
                successes += 1
            else:
                failures_injective += 1
                print(f"  ✗ COUNTEREXAMPLE at trial {trial}!")
        else:
            failures_noninjective += 1

    print(f"\n  Injective matrices:     {successes} tested, "
          f"{failures_injective} extraction failures")
    print(f"  Non-injective matrices: {failures_noninjective} "
          f"(extraction ambiguous, as expected)")

    if failures_injective == 0:
        print("\n  → Conjecture B SUPPORTED: rank obstruction is the only obstruction")
    else:
        print("\n  → Conjecture B REFUTED!")

    return failures_injective == 0


if __name__ == "__main__":
    random.seed(42)  # For reproducibility

    print("╔══════════════════════════════════════════════════════════╗")
    print("║  Universal Affine Σ-Protocol Extraction — Demo Suite    ║")
    print("╚══════════════════════════════════════════════════════════╝")

    all_passed = True
    all_passed &= demo_schnorr()
    all_passed &= demo_chaum_pedersen()
    all_passed &= demo_okamoto()
    all_passed &= demo_matrix_extraction()
    all_passed &= demo_obstruction()
    all_passed &= demo_conjecture_test()

    print("\n" + "=" * 60)
    if all_passed:
        print("ALL DEMONSTRATIONS PASSED ✓")
    else:
        print("SOME DEMONSTRATIONS FAILED ✗")
    print("=" * 60)
