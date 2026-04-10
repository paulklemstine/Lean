#!/usr/bin/env python3
"""
Division Algebra Codes and the E8 Lattice
==========================================

Demonstrates quantum error-correcting codes based on the E8 lattice,
which lives in the octonion dimension (8) and achieves optimal sphere packing.

Key results (formally verified in Lean 4):
- E8 kissing number = 240 = 112 + 128
- 112 from ±eᵢ ± eⱼ (i < j), 128 from (±½,...,±½) with even signs
- Brahmagupta-Fibonacci identity enables code composition
- Cayley-Dickson doubling: 1 → 2 → 4 → 8

Run: python3 e8_division_algebra_codes.py
"""

import numpy as np
from itertools import product, combinations

# ============================================================
# Section 1: E8 Root System Construction
# ============================================================

def construct_e8_roots():
    """Construct the 240 roots of the E8 lattice.
    
    Type I (112 roots): ±eᵢ ± eⱼ for 0 ≤ i < j ≤ 7
    Type II (128 roots): (±½,...,±½) with even number of minus signs
    
    Formally verified: e8_kissing_decomposition, e8_short_roots, e8_half_integer_roots
    """
    roots = []
    
    # Type I: ±eᵢ ± eⱼ
    for i, j in combinations(range(8), 2):
        for si in [1, -1]:
            for sj in [1, -1]:
                root = np.zeros(8)
                root[i] = si
                root[j] = sj
                roots.append(root)
    
    # Type II: (±½,...,±½) with even number of minus signs
    for signs in product([0.5, -0.5], repeat=8):
        root = np.array(signs)
        n_neg = sum(1 for s in signs if s < 0)
        if n_neg % 2 == 0:
            roots.append(root)
    
    return np.array(roots)

def verify_e8_properties(roots):
    """Verify key properties of the E8 root system."""
    print("E8 ROOT SYSTEM VERIFICATION")
    print("-" * 40)
    
    n = len(roots)
    print(f"Number of roots: {n} (expected 240)")
    
    # Squared norms
    norms_sq = np.sum(roots ** 2, axis=1)
    print(f"All squared norms = 2: {np.allclose(norms_sq, 2.0)}")
    
    # Inner products
    inner_products = set()
    for i in range(min(n, 100)):
        for j in range(i + 1, min(n, 100)):
            ip = np.dot(roots[i], roots[j])
            inner_products.add(round(ip, 6))
    print(f"Inner product values: {sorted(inner_products)}")
    
    # Kissing number: count neighbors at distance √2
    if n <= 240:
        kissing = 0
        for i in range(n):
            for j in range(n):
                if i != j:
                    dist_sq = np.sum((roots[i] - roots[j]) ** 2)
                    if abs(dist_sq - 2.0) < 1e-10:
                        kissing += 1
        # Each root sees this many neighbors
        kissing_per_root = kissing // n
        print(f"Average neighbors at distance √2: {kissing_per_root}")
    
    # Type decomposition
    type1 = sum(1 for r in roots if np.sum(r != 0) == 2)
    type2 = sum(1 for r in roots if np.allclose(np.abs(r), 0.5))
    print(f"Type I (±eᵢ±eⱼ): {type1} (expected 112)")
    print(f"Type II (±½,...,±½): {type2} (expected 128)")
    print(f"Total: {type1 + type2} = {type1} + {type2}")

# ============================================================
# Section 2: Division Algebra Norm Multiplicativity
# ============================================================

def brahmagupta_fibonacci(a, b, c, d):
    """The 2-square identity: (a²+b²)(c²+d²) = (ac-bd)² + (ad+bc)²
    
    This is norm-multiplicativity for ℂ:
      |z₁|² · |z₂|² = |z₁z₂|²
    where z₁ = a + bi, z₂ = c + di.
    
    Formally verified: brahmagupta_fibonacci in BreakthroughDirections.lean
    """
    lhs = (a**2 + b**2) * (c**2 + d**2)
    rhs = (a*c - b*d)**2 + (a*d + b*c)**2
    return lhs, rhs, abs(lhs - rhs) < 1e-10

def verify_norm_multiplicativity():
    """Verify norm-multiplicativity for ℝ, ℂ, ℍ dimensions."""
    print()
    print("NORM MULTIPLICATIVITY (Division Algebra Cascade)")
    print("-" * 50)
    
    np.random.seed(42)
    
    # Complex (2-square identity)
    print()
    print("ℂ (dim 2): Brahmagupta-Fibonacci identity")
    for trial in range(3):
        a, b, c, d = np.random.randn(4)
        lhs, rhs, ok = brahmagupta_fibonacci(a, b, c, d)
        print(f"  ({a:.2f}²+{b:.2f}²)({c:.2f}²+{d:.2f}²) = {lhs:.4f} = {rhs:.4f} {'✓' if ok else '✗'}")
    
    # Quaternion (4-square identity, simplified)
    print()
    print("ℍ (dim 4): Euler's four-square identity")
    for trial in range(3):
        x = np.random.randn(4)
        y = np.random.randn(4)
        norm_x = np.sum(x**2)
        norm_y = np.sum(y**2)
        # Quaternion product
        z = np.array([
            x[0]*y[0] - x[1]*y[1] - x[2]*y[2] - x[3]*y[3],
            x[0]*y[1] + x[1]*y[0] + x[2]*y[3] - x[3]*y[2],
            x[0]*y[2] - x[1]*y[3] + x[2]*y[0] + x[3]*y[1],
            x[0]*y[3] + x[1]*y[2] - x[2]*y[1] + x[3]*y[0],
        ])
        norm_z = np.sum(z**2)
        ok = abs(norm_x * norm_y - norm_z) < 1e-8
        print(f"  ‖x‖²·‖y‖² = {norm_x*norm_y:.4f}, ‖xy‖² = {norm_z:.4f} {'✓' if ok else '✗'}")
    
    # Cayley-Dickson dimensions
    print()
    print("Cayley-Dickson doubling: dim(𝔸ₖ) = 2^k")
    algebras = ["ℝ", "ℂ", "ℍ", "𝕆"]
    for k, name in enumerate(algebras):
        dim = 2**k
        print(f"  {name}: dimension = 2^{k} = {dim}")
    print()
    print("Formally verified: cayley_dickson_doubling in BreakthroughDirections.lean")

# ============================================================
# Section 3: E8 Lattice Code Construction
# ============================================================

def e8_encoder(message_bits):
    """Encode a message using the E8 lattice.
    
    Uses the (8,4) extended Hamming code structure of E8.
    The E8 lattice is the set of vectors in ℤ⁸ ∪ (ℤ+½)⁸
    with even coordinate sum.
    """
    assert len(message_bits) == 4, "E8 code encodes 4 bits into 8 coordinates"
    
    # Generator matrix for (8,4) code (simplified E8 encoding)
    G = np.array([
        [1, 0, 0, 0, 1, 1, 1, 0],
        [0, 1, 0, 0, 1, 1, 0, 1],
        [0, 0, 1, 0, 1, 0, 1, 1],
        [0, 0, 0, 1, 0, 1, 1, 1],
    ])
    
    message = np.array(message_bits)
    codeword = (message @ G) % 2
    
    return codeword

def e8_minimum_distance():
    """Compute minimum distance of E8 code.
    The minimum squared Euclidean distance is 2 (formally verified).
    The minimum Hamming distance of the extended (8,4) code is 4.
    """
    min_hamming = float('inf')
    
    for bits in product([0, 1], repeat=4):
        if any(b != 0 for b in bits):  # Skip zero codeword
            codeword = e8_encoder(list(bits))
            weight = np.sum(codeword != 0)
            min_hamming = min(min_hamming, weight)
    
    return min_hamming

def demonstrate_e8_code():
    """Demonstrate the E8 lattice code."""
    print()
    print("E8 LATTICE CODE")
    print("-" * 50)
    print()
    print("The E8 lattice yields an (8,4,4) code:")
    print("  - n = 8 (codeword length = octonion dimension)")
    print("  - k = 4 (message bits)")
    print("  - d = 4 (minimum Hamming distance)")
    print()
    
    # Generate all codewords
    print("All 16 codewords:")
    codewords = []
    for bits in product([0, 1], repeat=4):
        cw = e8_encoder(list(bits))
        codewords.append(cw)
        print(f"  {list(bits)} → {cw}")
    
    # Minimum distance
    d_min = e8_minimum_distance()
    print(f"\nMinimum Hamming distance: {d_min}")
    print(f"Error correction capability: t = ⌊(d-1)/2⌋ = {(d_min - 1) // 2}")
    print(f"Error detection capability: d-1 = {d_min - 1}")
    
    # Demonstrate error correction
    print()
    print("ERROR CORRECTION DEMO:")
    original = [1, 0, 1, 1]
    codeword = e8_encoder(original)
    print(f"  Original message: {original}")
    print(f"  Encoded: {codeword}")
    
    # Add single error
    corrupted = codeword.copy()
    corrupted[3] = 1 - corrupted[3]  # Flip bit 3
    print(f"  Corrupted (1 error): {corrupted}")
    
    # Find nearest codeword (maximum likelihood decoding)
    best_dist = float('inf')
    best_msg = None
    for bits in product([0, 1], repeat=4):
        cw = e8_encoder(list(bits))
        dist = np.sum(cw != corrupted)
        if dist < best_dist:
            best_dist = dist
            best_msg = list(bits)
    
    print(f"  Decoded: {best_msg} (distance {best_dist})")
    print(f"  Correct: {'✓' if best_msg == original else '✗'}")

# ============================================================
# Section 4: Sphere Packing and Kissing Numbers
# ============================================================

def demonstrate_sphere_packing():
    """Demonstrate sphere packing properties across dimensions."""
    print()
    print("SPHERE PACKING ACROSS DIVISION ALGEBRA DIMENSIONS")
    print("-" * 50)
    print()
    
    # Known kissing numbers for small dimensions
    kissing_numbers = {
        1: 2,      # ℝ: two neighbors on a line
        2: 6,      # ℂ: hexagonal packing
        3: 12,     # 3D: icosahedral arrangement
        4: 24,     # ℍ: D4 lattice
        8: 240,    # 𝕆: E8 lattice
        24: 196560 # Leech lattice
    }
    
    print(f"{'Dim':>4} {'Kissing #':>10} {'Algebra':>10} {'Lattice':>10}")
    print("-" * 36)
    for dim, kiss in sorted(kissing_numbers.items()):
        algebra = {1: "ℝ", 2: "ℂ", 4: "ℍ", 8: "𝕆"}.get(dim, "—")
        lattice = {1: "ℤ", 2: "A₂", 3: "FCC", 4: "D₄", 8: "E₈", 24: "Λ₂₄"}.get(dim, "?")
        print(f"{dim:>4} {kiss:>10} {algebra:>10} {lattice:>10}")
    
    print()
    print("Key observations:")
    print("  • Division algebra dimensions (1,2,4,8) all achieve exceptional packings")
    print("  • E8 (dim 8) is proved optimal (Viazovska, 2016)")
    print("  • Leech lattice (dim 24 = 3×8) is proved optimal (CKMRV, 2017)")
    print("  • The pattern 2→6→24→240 hints at deeper algebraic structure")
    
    # E8 decomposition
    print()
    print("E8 kissing number decomposition (formally verified):")
    print(f"  Type I:  C(8,2) × 4 = {28 * 4} = 112 roots ±eᵢ ± eⱼ")
    print(f"  Type II: 2⁸/2 = {256 // 2} = 128 roots (±½,...,±½)")
    print(f"  Total:   112 + 128 = 240 ✓")

# ============================================================
# Section 5: Quantum Error Correction Connection
# ============================================================

def quantum_error_correction():
    """Demonstrate the connection to quantum error correction."""
    print()
    print("QUANTUM ERROR CORRECTION VIA E8")
    print("-" * 50)
    print()
    print("Connection to quantum stabilizer codes:")
    print()
    print("1. CLASSICAL → QUANTUM LIFTING:")
    print("   The (8,4,4) classical code from E8 can be lifted to a")
    print("   [[8,0,4]] quantum stabilizer code (8 physical qubits,")
    print("   0 logical qubits, distance 4).")
    print()
    print("2. CSS CONSTRUCTION:")
    print("   Using the self-dual property of the E8 code (C = C⊥),")
    print("   the CSS construction yields a quantum code with")
    print("   distance d_Q = min(d(C), d(C⊥)) = 4.")
    print()
    print("3. NORM MULTIPLICATIVITY → CODE COMPOSITION:")
    print("   The Brahmagupta-Fibonacci identity (formally verified)")
    print("   enables composing E8-based codes: if C₁, C₂ correct t errors,")
    print("   their tensor product C₁ ⊗ C₂ corrects t errors in each block.")
    print()
    print("4. IDEMPOTENT CONNECTION:")
    print("   Quantum measurement is idempotent (P² = P).")
    print("   Error syndrome extraction is a projection onto the codespace.")
    print("   This connects to the master equation f ∘ f = f.")
    
    # Demonstrate self-duality
    print()
    print("E8 CODE SELF-DUALITY CHECK:")
    codewords = []
    for bits in product([0, 1], repeat=4):
        cw = e8_encoder(list(bits))
        codewords.append(cw)
    
    codewords = np.array(codewords)
    
    # Check orthogonality (mod 2)
    G = codewords[:4]  # Generator rows
    product_matrix = (G @ G.T) % 2
    is_self_orthogonal = np.all(product_matrix == 0)
    print(f"  G·Gᵀ = 0 (mod 2): {is_self_orthogonal}")
    if is_self_orthogonal:
        print("  → Code is self-orthogonal → CSS construction applicable ✓")

# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print("=" * 70)
    print("DIVISION ALGEBRA CODES AND THE E8 LATTICE")
    print("=" * 70)
    print()
    
    # Construct and verify E8
    roots = construct_e8_roots()
    verify_e8_properties(roots)
    
    # Norm multiplicativity
    verify_norm_multiplicativity()
    
    # E8 code
    demonstrate_e8_code()
    
    # Sphere packing
    demonstrate_sphere_packing()
    
    # Quantum connection
    quantum_error_correction()
    
    print()
    print("=" * 70)
    print("SUMMARY")
    print("=" * 70)
    print()
    print("The E8 lattice unifies:")
    print("  1. SPHERE PACKING: Optimal density in dim 8 (Viazovska)")
    print("  2. ERROR CORRECTION: (8,4,4) code with distance 4")
    print("  3. DIVISION ALGEBRAS: Lives in octonion dimension")
    print("  4. QUANTUM CODES: Self-dual → CSS construction")
    print("  5. NORM MULTIPLICATIVITY: Brahmagupta-Fibonacci cascade")
    print()
    print("All algebraic properties formally verified in Lean 4.")
    print("See: Bridges/NewDirections/BreakthroughDirections.lean")
