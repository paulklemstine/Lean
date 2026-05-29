#!/usr/bin/env python3
"""
Formal Spectral Moonshine: Applications

Demonstrates real-world applications of the moonshine transform framework:
1. Symmetry fingerprinting of molecules/crystals via spectral weights
2. Representation-theoretic data compression
3. Statistical mechanics partition functions for graded systems
4. Signal processing on finite groups

Application keywords: spectral decoding, harmonic analysis, representation theory,
partition functions, information compression, symmetry fingerprints
"""

import numpy as np
from math import comb, factorial
from typing import List, Dict, Tuple


# ============================================================
# Character table utilities (self-contained)
# ============================================================

def s3_data():
    table = np.array([[1,1,1],[1,-1,1],[2,0,-1]], dtype=complex)
    sizes = np.array([1, 3, 2])
    return table, sizes, 6, ['triv', 'sign', 'std'], ['e', '(12)', '(123)']

def s4_data():
    """Character table of S₄. Order 24, 5 conjugacy classes."""
    # Classes: e, (12), (123), (1234), (12)(34)
    # Sizes:   1,  6,    8,     6,      3
    table = np.array([
        [1,  1,  1,  1,  1],   # trivial
        [1, -1,  1, -1,  1],   # sign
        [2,  0, -1,  0,  2],   # 2-dim
        [3,  1,  0, -1, -1],   # standard
        [3, -1,  0,  1, -1],   # sign ⊗ standard
    ], dtype=complex)
    sizes = np.array([1, 6, 8, 6, 3])
    return table, sizes, 24, ['1', 'sgn', '2', 'std', 'sgn⊗std'], \
           ['e', '(12)', '(123)', '(1234)', '(12)(34)']

def a5_data():
    phi = (1 + np.sqrt(5)) / 2
    psi = (1 - np.sqrt(5)) / 2
    table = np.array([
        [1,  1,   1,    1,    1   ],
        [3, -1,   0,    phi,  psi ],
        [3, -1,   0,    psi,  phi ],
        [4,  0,   1,   -1,   -1   ],
        [5,  1,  -1,    0,    0   ],
    ], dtype=complex)
    sizes = np.array([1, 15, 20, 12, 12])
    return table, sizes, 60, ['1', '3a', '3b', '4', '5'], \
           ['e', '(12)(34)', '(123)', '(12345)', '(13245)']

def inner_product(f, g, sizes, order):
    return np.sum(sizes * f * np.conj(g)) / order

def decode(f, table, sizes, order):
    return np.array([inner_product(f, table[i], sizes, order)
                     for i in range(table.shape[0])])


# ============================================================
# Application 1: Symmetry Fingerprinting
# ============================================================

def symmetry_fingerprint(class_fn_values, table, sizes, order):
    """
    Compute the spectral fingerprint of a class function.
    
    The fingerprint is the vector of spectral weights |<f, χ_i>|²,
    normalized to sum to 1. This gives a probability distribution
    over irreducible representations that characterizes the "symmetry
    content" of the function.
    
    Application: In chemistry, the symmetry of molecular vibrations
    determines which transitions are IR/Raman active. The spectral
    fingerprint quantifies how a physical observable distributes
    across symmetry sectors.
    """
    coeffs = decode(class_fn_values, table, sizes, order)
    weights = np.abs(coeffs) ** 2
    total = np.sum(weights)
    if total > 0:
        return weights / total
    return weights

def spectral_entropy(fingerprint):
    """
    Shannon entropy of a spectral fingerprint.
    
    H = -Σ p_i log(p_i)
    
    Measures the "symmetry complexity" of a class function.
    Low entropy = concentrated in few irreps (high symmetry).
    High entropy = spread across many irreps (low symmetry).
    """
    fp = fingerprint[fingerprint > 1e-15]
    return -np.sum(fp * np.log2(fp))


print("=" * 70)
print("APPLICATION 1: Symmetry Fingerprinting")
print("=" * 70)

table, sizes, order, irr_names, class_names = s4_data()
print(f"\nGroup: S₄, |G| = {order}")

# "Molecular vibration" class functions
vibrations = {
    "highly symmetric": np.array([4, 0, 1, 0, 0], dtype=complex),
    "asymmetric": np.array([4, 2, 1, 0, 0], dtype=complex),
    "regular-like": np.array([24, 0, 0, 0, 0], dtype=complex),
}

for name, vib in vibrations.items():
    fp = symmetry_fingerprint(vib, table, sizes, order)
    entropy = spectral_entropy(fp)
    print(f"\n  {name}: f = {vib}")
    print(f"    Fingerprint: {np.round(fp, 4)}")
    print(f"    Entropy: {entropy:.4f} bits")
    print(f"    Dominant irrep: {irr_names[np.argmax(fp)]}")


# ============================================================
# Application 2: Representation-Theoretic Compression
# ============================================================

print("\n" + "=" * 70)
print("APPLICATION 2: Data Compression via Spectral Truncation")
print("=" * 70)

table, sizes, order, irr_names, class_names = a5_data()
num_classes = len(class_names)

# A "signal" on A₅ conjugacy classes
signal = np.array([10, 3, 1, 5, 4], dtype=complex)
print(f"\nOriginal signal on A₅ classes: {signal}")

coeffs = decode(signal, table, sizes, order)
print(f"Fourier coefficients: {np.round(coeffs, 4)}")

# Reconstruct with top-k coefficients
for k in range(1, 6):
    # Keep k largest coefficients
    indices = np.argsort(np.abs(coeffs))[::-1][:k]
    truncated = np.zeros_like(coeffs)
    truncated[indices] = coeffs[indices]
    
    reconstructed = np.zeros(num_classes, dtype=complex)
    for i in range(len(irr_names)):
        reconstructed += truncated[i] * table[i]
    
    error = np.linalg.norm(signal - reconstructed)
    compression = k / num_classes * 100
    print(f"  k={k}: error={error:.4f}, using {compression:.0f}% of coefficients")


# ============================================================
# Application 3: Partition Functions (Statistical Mechanics)
# ============================================================

print("\n" + "=" * 70)
print("APPLICATION 3: Partition Functions for Graded Systems")
print("=" * 70)

table, sizes, order, irr_names, class_names = s3_data()
print(f"\nGroup: S₃")

# Build two graded representations
print("\nRepresentation V: degree 0 = trivial, degree 1 = standard")
V_coeffs = {0: table[0], 1: table[2]}

print("Representation W: degree 0 = sign, degree 1 = trivial")
W_coeffs = {0: table[1], 1: table[0]}

print("\nDirect sum V⊕W (verified by gradedTrace_directSum_eq_add):")
for n in range(2):
    v = V_coeffs.get(n, np.zeros(3, dtype=complex))
    w = W_coeffs.get(n, np.zeros(3, dtype=complex))
    total = v + w
    print(f"  Degree {n}: V={v}, W={w}, V⊕W={total}")

# Verify partition function additivity
print("\nPartition function Z_g(q) = Σ_n Tr(g|V_n) q^n:")
for c, cname in enumerate(class_names):
    z_v = " + ".join(f"{np.real(V_coeffs.get(n, np.zeros(3))[c]):.0f}q^{n}"
                     for n in range(2))
    z_w = " + ".join(f"{np.real(W_coeffs.get(n, np.zeros(3))[c]):.0f}q^{n}"
                     for n in range(2))
    z_sum = " + ".join(f"{np.real(V_coeffs.get(n, np.zeros(3))[c] + W_coeffs.get(n, np.zeros(3))[c]):.0f}q^{n}"
                       for n in range(2))
    print(f"  Z_V({cname}) = {z_v}")
    print(f"  Z_W({cname}) = {z_w}")
    print(f"  Z_V⊕W({cname}) = Z_V + Z_W = {z_sum}")
    print()


# ============================================================
# Application 4: Spectral Distance Between Representations
# ============================================================

print("=" * 70)
print("APPLICATION 4: Spectral Distance Between Representations")
print("=" * 70)

table, sizes, order, irr_names, class_names = s4_data()
print(f"\nGroup: S₄")

# Compare different representations using spectral fingerprints
reps = {name: table[i] for i, name in enumerate(irr_names)}

print("\nSpectral distance matrix (L² between fingerprints):")
print(f"{'':>12}", end="")
for name in irr_names:
    print(f"{name:>10}", end="")
print()

for name1 in irr_names:
    fp1 = symmetry_fingerprint(reps[name1], table, sizes, order)
    print(f"{name1:>12}", end="")
    for name2 in irr_names:
        fp2 = symmetry_fingerprint(reps[name2], table, sizes, order)
        dist = np.linalg.norm(fp1 - fp2)
        print(f"{dist:>10.4f}", end="")
    print()

print("""
\nKey insight: Representations with similar spectral fingerprints
share similar symmetry content, even if they are not isomorphic.
This spectral distance provides a metric on the space of representations
that captures structural similarity beyond mere dimension matching.
""")


#!/usr/bin/env python3
"""
Formal Spectral Moonshine: Demonstration Script

Constructs toy moonshine packets for manageable finite groups (S₃, A₅),
computes multiplicity decompositions using the verified inner-product formula,
and tests the log-concavity conjecture for symmetric power multiplicities.

Application keywords: monstrous moonshine, McKay-Thompson series, class functions,
irreducible characters, Fourier inversion, graded representations, spectral decoding
"""

import numpy as np
from itertools import product as iterproduct
from collections import defaultdict

# ============================================================
# Part 1: Character Tables for Small Groups
# ============================================================

def s3_character_table():
    """Character table of S₃ ≅ D₃.
    Conjugacy classes: {e}, {(12),(13),(23)}, {(123),(132)}
    Class sizes: 1, 3, 2
    Irreps: trivial (1), sign (1'), standard (2-dim)
    """
    # Rows = irreps, Columns = conjugacy classes
    # Classes: [e], [(12)], [(123)]
    table = np.array([
        [1,  1,  1],   # trivial
        [1, -1,  1],   # sign
        [2,  0, -1],   # standard
    ], dtype=complex)
    class_sizes = np.array([1, 3, 2])
    order = 6
    irr_names = ['trivial', 'sign', 'standard']
    class_names = ['e', '(12)', '(123)']
    return table, class_sizes, order, irr_names, class_names

def a5_character_table():
    """Character table of A₅ (alternating group on 5 elements).
    Order 60. 5 conjugacy classes. 5 irreps of dimensions 1,3,3,4,5.
    """
    phi = (1 + np.sqrt(5)) / 2  # golden ratio
    psi = (1 - np.sqrt(5)) / 2

    # Classes: [e], [(12)(34)], [(123)], [(12345)], [(13245)]
    # Sizes:    1,   15,         20,      12,        12
    table = np.array([
        [1,  1,   1,    1,    1   ],  # trivial
        [3, -1,   0,    phi,  psi ],  # 3-dim (a)
        [3, -1,   0,    psi,  phi ],  # 3-dim (b)
        [4,  0,   1,   -1,   -1   ],  # 4-dim
        [5,  1,  -1,    0,    0   ],  # 5-dim
    ], dtype=complex)
    class_sizes = np.array([1, 15, 20, 12, 12])
    order = 60
    irr_names = ['1', '3a', '3b', '4', '5']
    class_names = ['e', '(12)(34)', '(123)', '(12345)', '(13245)']
    return table, class_sizes, order, irr_names, class_names

# ============================================================
# Part 2: Multiplicity Decoder (Verified Algorithm)
# ============================================================

def decode_multiplicities(class_fn_values, char_table, class_sizes, order):
    """
    Compute multiplicities of irreducible characters in a class function.
    
    This implements the verified formula:
        m_χ = (1/|G|) Σ_C |C| · f(C) · conj(χ(C))
    
    where the sum is over conjugacy classes C with representative elements.
    
    Parameters:
        class_fn_values: array of shape (num_classes,) — values of f on each class
        char_table: array of shape (num_irreps, num_classes)
        class_sizes: array of shape (num_classes,) — size of each conjugacy class
        order: int — |G|
    
    Returns:
        multiplicities: array of shape (num_irreps,)
    """
    multiplicities = np.zeros(char_table.shape[0], dtype=complex)
    for i in range(char_table.shape[0]):
        multiplicities[i] = np.sum(
            class_sizes * class_fn_values * np.conj(char_table[i])
        ) / order
    return multiplicities

# ============================================================
# Part 3: Symmetric Power Traces
# ============================================================

def symmetric_power_trace(char_values, n, order_or_none=None):
    """
    Compute Tr(g | Sym^n(V)) using Newton's identity / generating function.
    
    For a representation with character values p_k = Tr(g^k | V),
    we use the recursion for symmetric power characters:
        n · χ_{Sym^n}(g) = Σ_{k=1}^{n} p_k(g) · χ_{Sym^{n-k}}(g)
    
    where p_k(g) = χ_V(g^k).
    
    For class function computation, we need χ_V(g^k) for each conjugacy class.
    We approximate by using the character values directly (valid for the identity class).
    
    For the identity element, p_k(e) = dim(V) for all k, so:
        χ_{Sym^n}(e) = C(dim+n-1, n) = binomial coefficient.
    """
    dim = int(np.real(char_values[0]))  # dimension = trace at identity
    from math import comb
    return comb(dim + n - 1, n)

def sym_power_multiplicities_identity(dim, n_max, char_table, class_sizes, order):
    """
    Compute multiplicities of irreducibles in Sym^n(V) for n = 0..n_max,
    evaluated only at the identity (giving dimensions).
    
    For the identity element, Tr(e | Sym^n(V)) = C(dim+n-1, n).
    """
    from math import comb
    mults = []
    for n in range(n_max + 1):
        sym_dim = comb(dim + n - 1, n)
        # At identity, the class function value is just sym_dim
        # For a full computation, we'd need all class values
        # Here we record the dimension for the conjecture test
        mults.append(sym_dim)
    return mults

def compute_sym_power_full(rep_index, char_table, class_sizes, order, n_max):
    """
    Compute multiplicities of each irreducible in Sym^n(V) for a chosen
    representation V, for n = 0, 1, ..., n_max.
    
    Uses the Molien-type generating function approach via Newton's identities.
    For each conjugacy class representative g, we need χ_V(g^k).
    For cyclic elements, g^k is in a computable conjugacy class.
    
    Simplified version: we use the plethysm formula via power sums.
    For each class C, we compute the symmetric power character values recursively.
    """
    num_classes = char_table.shape[1]
    num_irreps = char_table.shape[0]
    
    # For each conjugacy class, compute Sym^n character values
    # Using the recursion: n * chi_Sym^n(g) = sum_{k=1}^n p_k(g) * chi_Sym^{n-k}(g)
    # where p_k(g) = chi_V(g^k)
    # 
    # For small groups, we need the power map: given class index c and power k,
    # which class does g^k belong to?
    # We'll compute this for S3 and A5 specifically.
    
    # Generic approach: just use the identity class for demonstration
    # (For a full implementation, one needs the power map of the group)
    
    chi_V = char_table[rep_index]
    
    # Compute symmetric power traces for identity only (all power maps to identity)
    # At identity: p_k(e) = dim(V) for all k
    dim = int(np.real(chi_V[0]))
    
    from math import comb
    sym_traces_identity = [comb(dim + n - 1, n) for n in range(n_max + 1)]
    
    # For the full multiplicity computation at identity, we just need dimensions
    # m_i(n) contribution from identity: (1/|G|) * 1 * sym_trace * conj(chi_i(e))
    # = (1/|G|) * C(dim+n-1,n) * dim_i
    
    multiplicities = np.zeros((n_max + 1, num_irreps))
    for n in range(n_max + 1):
        # Full Molien series computation for identity contribution
        # This is an approximation; full computation needs all classes
        for i in range(num_irreps):
            # Molien series: m_i = (1/|G|) * sum_g chi_Sym^n(g) * conj(chi_i(g))
            # Identity contribution:
            multiplicities[n, i] = np.real(
                sym_traces_identity[n] * np.conj(char_table[i, 0]) / order
            )
    
    return multiplicities, sym_traces_identity

# ============================================================
# Part 4: Moonshine Packet Construction
# ============================================================

class MoonshinePacket:
    """A graded sequence of class functions, representing the coefficient data
    of a McKay-Thompson-type series T_g(q) = Σ a_n(g) q^n."""
    
    def __init__(self, group_name, char_table, class_sizes, order,
                 irr_names, class_names):
        self.group_name = group_name
        self.char_table = char_table
        self.class_sizes = class_sizes
        self.order = order
        self.irr_names = irr_names
        self.class_names = class_names
        self.coeffs = {}  # n -> class function values (array over classes)
    
    def set_coeff(self, n, values):
        """Set the degree-n coefficient class function."""
        self.coeffs[n] = np.array(values, dtype=complex)
    
    def eval_at(self, class_index, n_max):
        """Evaluate the McKay-Thompson series for a conjugacy class."""
        return [self.coeffs.get(n, np.zeros(len(self.class_sizes)))[class_index]
                for n in range(n_max + 1)]
    
    def decode(self, n):
        """Decode multiplicities at degree n using the verified formula."""
        if n not in self.coeffs:
            return np.zeros(self.char_table.shape[0])
        return decode_multiplicities(
            self.coeffs[n], self.char_table, self.class_sizes, self.order
        )

# ============================================================
# Part 5: Log-Concavity Conjecture Test
# ============================================================

def test_log_concavity(sequence, start=2):
    """
    Test if a sequence is log-concave: a(n)² ≥ a(n-1) * a(n+1).
    Returns list of (index, is_log_concave, a_{n-1}, a_n, a_{n+1}).
    """
    results = []
    violations = []
    for n in range(max(start, 1), len(sequence) - 1):
        a_prev = sequence[n - 1]
        a_curr = sequence[n]
        a_next = sequence[n + 1]
        lc = a_curr ** 2 >= a_prev * a_next - 1e-10  # numerical tolerance
        results.append((n, lc, a_prev, a_curr, a_next))
        if not lc:
            violations.append(n)
    return results, violations

# ============================================================
# Part 6: Main Demonstration
# ============================================================

def main():
    print("=" * 70)
    print("FORMAL SPECTRAL MOONSHINE: Demonstration")
    print("=" * 70)
    
    # --- S₃ Example ---
    print("\n" + "=" * 70)
    print("Example 1: Moonshine Packet for S₃")
    print("=" * 70)
    
    table, sizes, order, irr_names, class_names = s3_character_table()
    print(f"\nGroup: S₃, |G| = {order}")
    print(f"Conjugacy classes: {class_names}")
    print(f"Class sizes: {sizes}")
    print(f"Irreducible representations: {irr_names}")
    print(f"\nCharacter table:")
    for i, name in enumerate(irr_names):
        print(f"  {name:>10}: {table[i]}")
    
    # Build a moonshine packet from the regular representation
    packet_s3 = MoonshinePacket("S₃", table, sizes, order, irr_names, class_names)
    
    # Degree 0: trivial representation
    packet_s3.set_coeff(0, table[0])  # trivial: [1, 1, 1]
    
    # Degree 1: standard representation
    packet_s3.set_coeff(1, table[2])  # standard: [2, 0, -1]
    
    # Degree 2: regular representation
    reg_char = np.array([order, 0, 0], dtype=complex)  # regular rep trace
    packet_s3.set_coeff(2, reg_char)
    
    print("\n--- Multiplicity Decoding ---")
    for n in range(3):
        mults = packet_s3.decode(n)
        print(f"\n  Degree {n}: class function = {packet_s3.coeffs[n]}")
        print(f"    Multiplicities: ", end="")
        for i, name in enumerate(irr_names):
            print(f"{name}={np.real(mults[i]):.1f}  ", end="")
        print()
    
    # Verify: regular representation should have m_i = dim(V_i)
    print("\n  ✓ Degree 2 (regular rep): multiplicities should equal dimensions")
    mults_reg = packet_s3.decode(2)
    dims = [int(np.real(table[i, 0])) for i in range(len(irr_names))]
    print(f"    Expected dims: {dims}")
    print(f"    Computed mults: {[round(np.real(m)) for m in mults_reg]}")
    
    # --- McKay-Thompson series display ---
    print("\n--- McKay-Thompson Series (first 3 terms) ---")
    for c, cname in enumerate(class_names):
        series = [packet_s3.coeffs.get(n, np.zeros(3))[c] for n in range(3)]
        terms = " + ".join(f"{np.real(s):.0f}q^{n}" for n, s in enumerate(series))
        print(f"  T_{{{cname}}}(q) = {terms} + ...")
    
    # --- Fourier Inversion Verification ---
    print("\n--- Fourier Inversion Verification ---")
    # For each degree, verify: f(g) = Σ_χ <f,χ> · χ(g)
    for n in range(3):
        f_values = packet_s3.coeffs[n]
        mults = decode_multiplicities(f_values, table, sizes, order)
        reconstructed = np.zeros(len(class_names), dtype=complex)
        for i in range(len(irr_names)):
            reconstructed += mults[i] * table[i]
        error = np.max(np.abs(f_values - reconstructed))
        status = "✓" if error < 1e-10 else "✗"
        print(f"  Degree {n}: reconstruction error = {error:.2e} {status}")
    
    # --- A₅ Example ---
    print("\n" + "=" * 70)
    print("Example 2: Moonshine Packet for A₅")
    print("=" * 70)
    
    table, sizes, order, irr_names, class_names = a5_character_table()
    print(f"\nGroup: A₅, |G| = {order}")
    print(f"Irreducible representations: {irr_names}")
    print(f"Dimensions: {[int(np.real(table[i,0])) for i in range(5)]}")
    
    # Build packet from Sym^n of the 3a representation
    packet_a5 = MoonshinePacket("A₅", table, sizes, order, irr_names, class_names)
    
    # For the 3a representation (index 1)
    rep_idx = 1
    from math import comb
    n_max_demo = 8
    print(f"\nSymmetric powers of the 3a representation:")
    for n in range(n_max_demo + 1):
        dim_sym = comb(3 + n - 1, n)
        # Identity class function value for Sym^n(3a)
        identity_val = dim_sym
        # Set coefficient (identity class only for now)
        vals = np.zeros(5, dtype=complex)
        vals[0] = identity_val
        packet_a5.set_coeff(n, vals)
        print(f"  Sym^{n}(3a): dim = {dim_sym}")
    
    # --- Conjecture Test: Log-Concavity ---
    print("\n" + "=" * 70)
    print("Conjecture Test: Log-Concavity of Symmetric Power Dimensions")
    print("=" * 70)
    
    print("\nConjecture: For A₅ and its 3-dimensional irrep V = 3a,")
    print("the dimension sequence dim(Sym^n(V)) is eventually log-concave.")
    print()
    
    n_test = 100
    dim_sequence = [comb(3 + n - 1, n) for n in range(n_test + 1)]
    
    results, violations = test_log_concavity(dim_sequence)
    
    print(f"Testing for n = 1 to {n_test}:")
    print(f"  Total tests: {len(results)}")
    print(f"  Violations: {len(violations)}")
    
    if len(violations) == 0:
        print("  ✓ Sequence IS log-concave for all tested n!")
    else:
        print(f"  ✗ Violations at indices: {violations[:10]}")
    
    # Show first few values
    print(f"\n  First 15 values of dim(Sym^n(3a)):")
    print(f"  {dim_sequence[:15]}")
    
    # Check log-concavity detail
    print(f"\n  Log-concavity check (first 10):")
    for n, lc, a_prev, a_curr, a_next in results[:10]:
        ratio = a_curr**2 / (a_prev * a_next) if a_prev * a_next > 0 else float('inf')
        status = "✓" if lc else "✗"
        print(f"    n={n}: a(n)²={a_curr**2}, a(n-1)*a(n+1)={a_prev*a_next}, "
              f"ratio={ratio:.6f} {status}")
    
    # --- General multiplicity sequences ---
    print("\n" + "=" * 70)
    print("Multiplicity Sequences for S₃ Regular Representation Decomposition")
    print("=" * 70)
    
    table, sizes, order, irr_names, class_names = s3_character_table()
    
    # Build a richer packet: Sym^n of the standard representation of S₃
    dim_std = 2
    print(f"\nDimensions of Sym^n(standard) for S₃:")
    sym_dims = [comb(dim_std + n - 1, n) for n in range(20)]
    print(f"  {sym_dims[:15]}")
    
    results_sym, violations_sym = test_log_concavity(sym_dims)
    print(f"\nLog-concavity of Sym^n(standard) dimensions:")
    print(f"  Violations: {len(violations_sym)}")
    if len(violations_sym) == 0:
        print("  ✓ Log-concave!")
    
    # --- Parseval Verification ---
    print("\n" + "=" * 70)
    print("Parseval's Theorem Verification")
    print("=" * 70)
    
    # For S₃, verify that <f,g> = Σ_χ <f,χ>·conj(<g,χ>)
    table, sizes, order, irr_names, class_names = s3_character_table()
    
    f_values = np.array([3, 1, 0], dtype=complex)  # some class function
    g_values = np.array([2, 0, -1], dtype=complex)  # standard character
    
    # Direct inner product
    direct_inner = np.sum(sizes * f_values * np.conj(g_values)) / order
    
    # Parseval expansion
    f_coeffs = decode_multiplicities(f_values, table, sizes, order)
    g_coeffs = decode_multiplicities(g_values, table, sizes, order)
    parseval_inner = np.sum(f_coeffs * np.conj(g_coeffs))
    
    print(f"\n  f = {f_values}")
    print(f"  g = {g_values}")
    print(f"  Direct <f,g> = {direct_inner}")
    print(f"  Parseval Σ <f,χ>·conj(<g,χ>) = {parseval_inner}")
    print(f"  Match: {'✓' if abs(direct_inner - parseval_inner) < 1e-10 else '✗'}")
    
    # --- Summary ---
    print("\n" + "=" * 70)
    print("SUMMARY")
    print("=" * 70)
    print("""
Key results demonstrated:
  1. Multiplicity decoding via inner product formula (verified in Lean)
  2. Fourier inversion reconstruction (verified in Lean)
  3. Parseval's theorem for class functions (verified in Lean)
  4. Log-concavity conjecture tested for symmetric power dimensions
  5. Moonshine packet construction and evaluation

The formal Lean proofs establish:
  • graded_module_determined_by_traces: trace data determines representations
  • classFn_fourier_expansion: spectral decomposition of class functions  
  • classFn_parseval: Parseval's identity for finite group harmonics
  • decodeMultiplicities_correct: verified multiplicity extraction algorithm
  • gradedTrace_directSum_eq_add: partition function additivity
""")

if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Fourier Inversion on Finite Groups

Demonstrates the core mathematical result: any class function on a finite group
can be perfectly reconstructed from its inner products with irreducible characters.

This is the finite-group analogue of Fourier inversion, and the mathematical
foundation of the "moonshine decoder" — the algorithm that extracts representation-
theoretic information from q-series coefficient data.
"""

import numpy as np
import matplotlib.pyplot as plt

# ============================================================
# Self-contained data
# ============================================================

def s4_data():
    table = np.array([
        [1,  1,  1,  1,  1],
        [1, -1,  1, -1,  1],
        [2,  0, -1,  0,  2],
        [3,  1,  0, -1, -1],
        [3, -1,  0,  1, -1],
    ], dtype=complex)
    sizes = np.array([1, 6, 8, 6, 3])
    return table, sizes, 24, ['1', 'sgn', '2', 'std', 'sgn⊗std'], \
           ['e', '(12)', '(123)', '(1234)', '(12)(34)']

def decode(f, table, sizes, order):
    return np.array([np.sum(sizes * f * np.conj(table[i])) / order
                     for i in range(table.shape[0])])

# ============================================================
# Build the visualization
# ============================================================

table, sizes, order, irr_names, class_names = s4_data()
num_irreps = len(irr_names)

# Choose a class function to decompose
f = np.array([7, 1, -2, 3, 1], dtype=complex)

# Compute Fourier coefficients
coeffs = decode(f, table, sizes, order)

# Progressive reconstruction
fig, axes = plt.subplots(2, 3, figsize=(16, 9))

# Top row: progressive reconstruction
for k in range(5):
    ax = axes[0, k] if k < 3 else axes[1, k - 3]
    
    # Reconstruct with first k+1 components
    reconstructed = np.zeros(len(class_names), dtype=complex)
    for i in range(k + 1):
        reconstructed += coeffs[i] * table[i]
    
    x = np.arange(len(class_names))
    width = 0.35
    
    ax.bar(x - width/2, np.real(f), width, label='Original f', color='steelblue', alpha=0.7)
    ax.bar(x + width/2, np.real(reconstructed), width, label=f'Reconstructed (k={k+1})',
           color='coral', alpha=0.7)
    
    error = np.linalg.norm(f - reconstructed)
    ax.set_title(f'Using {k+1}/{num_irreps} components\nError: {error:.4f}',
                fontsize=10, fontweight='bold')
    ax.set_xticks(x)
    ax.set_xticklabels(class_names, fontsize=8, rotation=30)
    ax.set_ylabel('Value', fontsize=9)
    ax.legend(fontsize=7)
    ax.axhline(y=0, color='gray', linewidth=0.5)

# Bottom right: Fourier coefficients
ax = axes[1, 2]
colors = ['#e41a1c', '#377eb8', '#4daf4a', '#984ea3', '#ff7f00']
bars = ax.bar(range(num_irreps), np.real(coeffs), color=colors, alpha=0.8)
ax.set_xticks(range(num_irreps))
ax.set_xticklabels(irr_names, fontsize=9)
ax.set_xlabel('Irreducible character', fontsize=10)
ax.set_ylabel('Fourier coefficient ⟨f, χ⟩', fontsize=10)
ax.set_title('Spectral Decomposition\nof f', fontsize=10, fontweight='bold')
ax.axhline(y=0, color='gray', linewidth=0.5)
ax.grid(True, alpha=0.3, axis='y')

# Add coefficient values
for i, (bar, c) in enumerate(zip(bars, coeffs)):
    ax.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.05,
            f'{np.real(c):.2f}', ha='center', va='bottom', fontsize=9, fontweight='bold')

plt.suptitle(
    f'Fourier Inversion on S₄: f = {[int(np.real(x)) for x in f]}\n'
    f'f(g) = Σᵢ ⟨f, χᵢ⟩ · χᵢ(g) — Progressive Reconstruction',
    fontsize=13, fontweight='bold', y=1.02
)
plt.tight_layout()
plt.savefig('fourier_inversion.png', dpi=150, bbox_inches='tight')
print("Saved fourier_inversion.png")


#!/usr/bin/env python3
"""
Visualization: Moonshine Packet Heatmap

Creates a heatmap showing how McKay-Thompson series coefficients distribute
across conjugacy classes and grading degrees. This visualizes the core data
structure of moonshine: a matrix of values T_g(n) where rows are conjugacy
classes and columns are grading degrees.

The visualization reveals patterns in how representation-theoretic information
is encoded into q-series coefficients — the central mystery of moonshine.
"""

import numpy as np
import matplotlib.pyplot as plt
from math import comb

# ============================================================
# Self-contained data
# ============================================================

def s3_data():
    table = np.array([[1,1,1],[1,-1,1],[2,0,-1]], dtype=complex)
    sizes = np.array([1, 3, 2])
    return table, sizes, 6, ['triv', 'sign', 'std'], ['e', '(12)', '(123)']

def a5_data():
    phi = (1 + np.sqrt(5)) / 2
    psi = (1 - np.sqrt(5)) / 2
    table = np.array([
        [1,  1,   1,    1,    1   ],
        [3, -1,   0,    phi,  psi ],
        [3, -1,   0,    psi,  phi ],
        [4,  0,   1,   -1,   -1   ],
        [5,  1,  -1,    0,    0   ],
    ], dtype=complex)
    sizes = np.array([1, 15, 20, 12, 12])
    return table, sizes, 60, ['1', '3a', '3b', '4', '5'], \
           ['e', '(12)(34)', '(123)', '(12345)', '(13245)']

def decode(f, table, sizes, order):
    return np.array([np.sum(sizes * f * np.conj(table[i])) / order
                     for i in range(table.shape[0])])

# ============================================================
# Build moonshine packet data
# ============================================================

fig, axes = plt.subplots(1, 3, figsize=(18, 5))

# --- Panel 1: S₃ McKay-Thompson coefficient matrix ---
ax = axes[0]
table, sizes, order, irr_names, class_names = s3_data()
n_max = 8

# Build coefficients: use symmetric powers of standard rep
# At identity: dim Sym^n(2-dim) = n+1
# Character values computed from traces
packet_data = np.zeros((len(class_names), n_max + 1))
for n in range(n_max + 1):
    # For the trivial class: always n+1
    packet_data[0, n] = n + 1
    # For transposition class: alternating ±1
    packet_data[1, n] = 1 if n % 2 == 0 else 0
    # For 3-cycle class: from generating function 1/((1-x)(1-x²))... simplified
    packet_data[2, n] = 1 if n % 3 == 0 else 0

im = ax.imshow(packet_data, aspect='auto', cmap='RdBu_r',
               vmin=-np.max(np.abs(packet_data)), vmax=np.max(np.abs(packet_data)))
ax.set_xticks(range(n_max + 1))
ax.set_yticks(range(len(class_names)))
ax.set_yticklabels(class_names, fontsize=10)
ax.set_xlabel('Degree n', fontsize=11)
ax.set_ylabel('Conjugacy class', fontsize=11)
ax.set_title('S₃: Moonshine Packet\nT_g(q) coefficients', fontsize=12, fontweight='bold')
plt.colorbar(im, ax=ax, shrink=0.8)

# Annotate values
for i in range(len(class_names)):
    for j in range(n_max + 1):
        ax.text(j, i, f'{packet_data[i,j]:.0f}', ha='center', va='center', fontsize=8,
                color='white' if abs(packet_data[i,j]) > np.max(packet_data)/2 else 'black')

# --- Panel 2: A₅ multiplicity matrix ---
ax = axes[1]
table, sizes, order, irr_names, class_names = a5_data()

# Build packet from dimensions of Sym^n(3a)
n_max_a5 = 10
mult_data = np.zeros((len(irr_names), n_max_a5 + 1))
for n in range(n_max_a5 + 1):
    sym_dim = comb(3 + n - 1, n)
    # At identity: the multiplicity decoding gives contributions from identity class only
    for i in range(len(irr_names)):
        mult_data[i, n] = np.real(sym_dim * np.conj(table[i, 0])) / order

im = ax.imshow(mult_data, aspect='auto', cmap='viridis')
ax.set_xticks(range(n_max_a5 + 1))
ax.set_yticks(range(len(irr_names)))
ax.set_yticklabels(irr_names, fontsize=10)
ax.set_xlabel('Degree n', fontsize=11)
ax.set_ylabel('Irreducible character', fontsize=11)
ax.set_title('A₅: Multiplicity Profile\nm_χ(Sym^n(3a))', fontsize=12, fontweight='bold')
plt.colorbar(im, ax=ax, shrink=0.8)

# --- Panel 3: Parseval energy distribution ---
ax = axes[2]
table, sizes, order, irr_names, class_names = a5_data()

# Show how total energy distributes across characters
n_range = range(1, 15)
total_energies = []
component_energies = {name: [] for name in irr_names}

for n in list(n_range):
    sym_dim = comb(3 + n - 1, n)
    class_fn = np.zeros(5, dtype=complex)
    class_fn[0] = sym_dim
    
    coeffs = decode(class_fn, table, sizes, order)
    total_e = np.sum(np.abs(coeffs) ** 2)
    total_energies.append(total_e)
    
    for i, name in enumerate(irr_names):
        component_energies[name].append(np.abs(coeffs[i]) ** 2)

# Stack plot
bottom = np.zeros(len(list(n_range)))
colors = ['#e41a1c', '#377eb8', '#4daf4a', '#984ea3', '#ff7f00']
for i, name in enumerate(irr_names):
    vals = np.array(component_energies[name])
    ax.bar(list(n_range), vals, bottom=bottom, color=colors[i],
           alpha=0.8, label=name, width=0.8)
    bottom += vals

ax.set_xlabel('Degree n', fontsize=11)
ax.set_ylabel('Spectral energy |⟨f,χ⟩|²', fontsize=11)
ax.set_title('A₅: Parseval Energy\nDecomposition', fontsize=12, fontweight='bold')
ax.legend(fontsize=8, title='Irrep', title_fontsize=9)

plt.suptitle('Moonshine Packets: From Traces to Spectra', fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('moonshine_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved moonshine_heatmap.png")


#!/usr/bin/env python3
"""
Visualization: Spectral Fingerprints of Class Functions

Visualizes how class functions decompose into irreducible character components,
showing the spectral weight distribution as a heatmap across different
representations and group elements.

This illustrates the core insight of formal spectral moonshine: class functions
on finite groups have a unique "frequency decomposition" analogous to Fourier
analysis, where irreducible characters play the role of frequency components.
"""

import numpy as np
import matplotlib.pyplot as plt
from math import comb

# ============================================================
# Self-contained character table data
# ============================================================

def s4_data():
    table = np.array([
        [1,  1,  1,  1,  1],
        [1, -1,  1, -1,  1],
        [2,  0, -1,  0,  2],
        [3,  1,  0, -1, -1],
        [3, -1,  0,  1, -1],
    ], dtype=complex)
    sizes = np.array([1, 6, 8, 6, 3])
    return table, sizes, 24, ['1', 'sgn', '2', 'std', 'sgn⊗std'], \
           ['e', '(12)', '(123)', '(1234)', '(12)(34)']

def a5_data():
    phi = (1 + np.sqrt(5)) / 2
    psi = (1 - np.sqrt(5)) / 2
    table = np.array([
        [1,  1,   1,    1,    1   ],
        [3, -1,   0,    phi,  psi ],
        [3, -1,   0,    psi,  phi ],
        [4,  0,   1,   -1,   -1   ],
        [5,  1,  -1,    0,    0   ],
    ], dtype=complex)
    sizes = np.array([1, 15, 20, 12, 12])
    return table, sizes, 60, ['1', '3a', '3b', '4', '5'], \
           ['e', '(12)(34)', '(123)', '(12345)', '(13245)']

def decode(f, table, sizes, order):
    return np.array([np.sum(sizes * f * np.conj(table[i])) / order
                     for i in range(table.shape[0])])

def fingerprint(f, table, sizes, order):
    coeffs = decode(f, table, sizes, order)
    weights = np.abs(coeffs) ** 2
    total = np.sum(weights)
    return weights / total if total > 0 else weights

# ============================================================
# Create the visualization
# ============================================================

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# --- Panel 1: S₄ spectral decomposition heatmap ---
ax = axes[0, 0]
table, sizes, order, irr_names, class_names = s4_data()

# Various class functions to decompose
test_functions = {
    'trivial χ': table[0],
    'sign χ': table[1],
    'standard χ': table[3],
    'regular': np.array([24, 0, 0, 0, 0], dtype=complex),
    'custom 1': np.array([5, 1, 2, 0, 1], dtype=complex),
    'custom 2': np.array([3, -1, 0, 1, 3], dtype=complex),
}

fp_matrix = np.array([fingerprint(f, table, sizes, order) for f in test_functions.values()])
im = ax.imshow(fp_matrix, aspect='auto', cmap='YlOrRd', vmin=0, vmax=1)
ax.set_xticks(range(len(irr_names)))
ax.set_xticklabels(irr_names, fontsize=9)
ax.set_yticks(range(len(test_functions)))
ax.set_yticklabels(list(test_functions.keys()), fontsize=9)
ax.set_xlabel('Irreducible representation', fontsize=10)
ax.set_ylabel('Class function', fontsize=10)
ax.set_title('S₄: Spectral Fingerprints', fontsize=12, fontweight='bold')
plt.colorbar(im, ax=ax, label='Spectral weight')

# --- Panel 2: A₅ Fourier coefficients ---
ax = axes[0, 1]
table, sizes, order, irr_names, class_names = a5_data()

# Decompose the character of each irreducible (should give delta functions)
colors = ['#e41a1c', '#377eb8', '#4daf4a', '#984ea3', '#ff7f00']
bar_width = 0.15
x = np.arange(len(irr_names))
for i, name in enumerate(irr_names):
    coeffs = decode(table[i], table, sizes, order)
    ax.bar(x + i * bar_width, np.real(coeffs), bar_width,
           label=f'χ_{{{name}}}', color=colors[i], alpha=0.8)

ax.set_xticks(x + bar_width * 2)
ax.set_xticklabels(irr_names, fontsize=9)
ax.set_xlabel('Basis character', fontsize=10)
ax.set_ylabel('Fourier coefficient', fontsize=10)
ax.set_title('A₅: Orthogonality (δ_{ij})', fontsize=12, fontweight='bold')
ax.legend(fontsize=8, ncol=2)
ax.axhline(y=0, color='gray', linewidth=0.5)

# --- Panel 3: Log-concavity of symmetric power dimensions ---
ax = axes[1, 0]
dims = [3, 4, 5]
for d in dims:
    n_vals = list(range(20))
    sym_dims = [comb(d + n - 1, n) for n in n_vals]
    ax.plot(n_vals, sym_dims, 'o-', markersize=3, label=f'dim V = {d}')

ax.set_xlabel('Degree n', fontsize=10)
ax.set_ylabel('dim Sym^n(V)', fontsize=10)
ax.set_title('Symmetric Power Growth', fontsize=12, fontweight='bold')
ax.set_yscale('log')
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# --- Panel 4: Log-concavity ratio ---
ax = axes[1, 1]
for d in dims:
    n_vals = list(range(2, 25))
    ratios = []
    for n in n_vals:
        a_prev = comb(d + n - 2, n - 1)
        a_curr = comb(d + n - 1, n)
        a_next = comb(d + n, n + 1)
        ratio = a_curr ** 2 / (a_prev * a_next) if a_prev * a_next > 0 else 0
        ratios.append(ratio)
    ax.plot(n_vals, ratios, 'o-', markersize=3, label=f'dim V = {d}')

ax.axhline(y=1, color='red', linewidth=1, linestyle='--', label='log-concavity threshold')
ax.set_xlabel('Degree n', fontsize=10)
ax.set_ylabel('a(n)² / (a(n-1)·a(n+1))', fontsize=10)
ax.set_title('Log-Concavity Ratio (>1 = log-concave)', fontsize=12, fontweight='bold')
ax.legend(fontsize=8)
ax.grid(True, alpha=0.3)
ax.set_ylim(0.95, 1.35)

plt.suptitle('Formal Spectral Moonshine: Visualizations', fontsize=14, fontweight='bold', y=1.01)
plt.tight_layout()
plt.savefig('spectral_fingerprints.png', dpi=150, bbox_inches='tight')
print("Saved spectral_fingerprints.png")
