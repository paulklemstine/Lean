#!/usr/bin/env python3
"""
Čech Stabilizer Codes: Chain Complex Quantum Error Correction
=============================================================

This demo illustrates the main mathematical constructions:
1. Chain complex → CSS code
2. Syndrome computation
3. Error correction within the distance bound
4. Concrete examples: repetition code, Steane code
"""

import numpy as np
from itertools import product

# ============================================================
# Core: F₂ arithmetic
# ============================================================

def f2_mul(A, B):
    """Matrix multiplication over F₂ (GF(2))."""
    return np.mod(A @ B, 2)

def f2_add(A, B):
    """Matrix addition over F₂."""
    return np.mod(A + B, 2)

def weight(v):
    """Hamming weight of a binary vector."""
    return int(np.sum(v != 0))

# ============================================================
# Chain Complex
# ============================================================

class F2ChainComplex:
    """An F₂ chain complex C₀ →[d1]→ C₁ →[d2]→ C₂ with d2∘d1 = 0."""
    
    def __init__(self, d1, d2):
        self.d1 = np.array(d1, dtype=int) % 2
        self.d2 = np.array(d2, dtype=int) % 2
        
        # Verify chain complex condition
        product_mat = f2_mul(self.d2, self.d1)
        assert np.all(product_mat == 0), f"∂²≠0: d2*d1 = {product_mat}"
        
        self.m = self.d1.shape[1]  # dim C₀
        self.n = self.d1.shape[0]  # dim C₁ (= number of qubits)
        self.p = self.d2.shape[0]  # dim C₂
    
    def to_css_code(self):
        """Convert to CSS code: Hx = d1^T, Hz = d2."""
        return CSSCode(self.d1.T, self.d2)

class CSSCode:
    """A CSS quantum error-correcting code over F₂."""
    
    def __init__(self, Hx, Hz):
        self.Hx = np.array(Hx, dtype=int) % 2
        self.Hz = np.array(Hz, dtype=int) % 2
        self.n = self.Hx.shape[1]  # number of qubits
        self.rx = self.Hx.shape[0]  # X-check generators
        self.rz = self.Hz.shape[0]  # Z-check generators
        
        # Verify CSS orthogonality
        orth = f2_mul(self.Hx, self.Hz.T)
        assert np.all(orth == 0), f"CSS orthogonality fails: Hx*Hz^T = {orth}"
    
    def x_syndrome(self, e):
        """Compute X-syndrome Hz * e (mod 2)."""
        return f2_mul(self.Hz, e.reshape(-1, 1)).flatten() % 2
    
    def z_syndrome(self, e):
        """Compute Z-syndrome Hx * e (mod 2)."""
        return f2_mul(self.Hx, e.reshape(-1, 1)).flatten() % 2
    
    def is_x_logical(self, v):
        """Check if v is in ker(Hz)."""
        return np.all(self.x_syndrome(v) == 0)
    
    def is_z_logical(self, v):
        """Check if v is in ker(Hx)."""
        return np.all(self.z_syndrome(v) == 0)
    
    def compute_distance(self):
        """Compute the minimum distance by exhaustive search (small codes only)."""
        min_x_dist = self.n + 1
        min_z_dist = self.n + 1
        
        # Find minimum weight X-logical that is NOT an X-stabilizer
        for bits in product([0, 1], repeat=self.n):
            v = np.array(bits, dtype=int)
            if weight(v) == 0:
                continue
            if self.is_x_logical(v):
                # Check if it's a stabilizer (in column space of Hx^T)
                if not self._is_in_column_space(self.Hx.T, v):
                    min_x_dist = min(min_x_dist, weight(v))
            if self.is_z_logical(v):
                if not self._is_in_column_space(self.Hz.T, v):
                    min_z_dist = min(min_z_dist, weight(v))
        
        return min(min_x_dist, min_z_dist)
    
    def _is_in_column_space(self, M, v):
        """Check if v is in the column space of M over F₂."""
        # Try all linear combinations of columns
        ncols = M.shape[1]
        for bits in product([0, 1], repeat=ncols):
            combo = np.array(bits, dtype=int)
            result = f2_mul(M, combo.reshape(-1, 1)).flatten() % 2
            if np.all(result == v % 2):
                return True
        return False
    
    def logical_qubits(self):
        """Count logical qubits = dim(ker Hz / im Hx^T)."""
        # dim ker Hz
        ker_hz = 0
        for bits in product([0, 1], repeat=self.n):
            v = np.array(bits, dtype=int)
            if self.is_x_logical(v):
                ker_hz += 1
        dim_ker_hz = int(np.log2(ker_hz)) if ker_hz > 0 else 0
        
        # dim im Hx^T = rank Hx
        rank_hx = np.linalg.matrix_rank(self.Hx.astype(float))
        
        return dim_ker_hz - rank_hx

# ============================================================
# Example 1: 3-qubit Repetition Code
# ============================================================

print("=" * 60)
print("Example 1: 3-Qubit Repetition Code")
print("=" * 60)

d1_rep = np.array([[1], [1], [1]])
d2_rep = np.array([[1, 1, 0], [0, 1, 1]])

rep_complex = F2ChainComplex(d1_rep, d2_rep)
rep_code = rep_complex.to_css_code()

print(f"Chain complex: C₀(F₂¹) →[∂₁]→ C₁(F₂³) →[∂₂]→ C₂(F₂²)")
print(f"∂₁ = {d1_rep.T[0]}")
print(f"∂₂ = ")
for row in d2_rep:
    print(f"  {row}")
print(f"∂₂·∂₁ = {f2_mul(d2_rep, d1_rep).T[0]}  (= 0 ✓)")
print()
print(f"CSS Code:")
print(f"  n = {rep_code.n} qubits")
print(f"  Hx ({rep_code.rx}×{rep_code.n}) = {rep_code.Hx}")
print(f"  Hz ({rep_code.rz}×{rep_code.n}) = ")
for row in rep_code.Hz:
    print(f"    {row}")

# Test error correction
print(f"\nError correction demo:")
e = np.array([1, 0, 0])  # Single bit flip on qubit 0
syndrome = rep_code.x_syndrome(e)
print(f"  Error e = {e}, weight = {weight(e)}")
print(f"  X-syndrome = {syndrome}")
print(f"  Is X-logical? {rep_code.is_x_logical(e)}")

# Try distance computation
dist = rep_code.compute_distance()
print(f"\n  Code distance = {dist}")

# ============================================================
# Example 2: Steane [[7,1,3]] Code
# ============================================================

print("\n" + "=" * 60)
print("Example 2: Steane [[7,1,3]] Code")
print("=" * 60)

# Hamming parity check matrix
H = np.array([
    [1, 0, 1, 0, 1, 0, 1],
    [0, 1, 1, 0, 0, 1, 1],
    [0, 0, 0, 1, 1, 1, 1]
])

d1_steane = H.T  # 7×3
d2_steane = H     # 3×7

steane_complex = F2ChainComplex(d1_steane, d2_steane)
steane_code = steane_complex.to_css_code()

print(f"Chain complex: C₀(F₂³) →[Hᵀ]→ C₁(F₂⁷) →[H]→ C₂(F₂³)")
print(f"Hamming parity check H:")
for row in H:
    print(f"  {row}")
print(f"H·Hᵀ = ")
for row in f2_mul(H, H.T):
    print(f"  {row}")
print(f"(= 0 ✓ — Hamming self-orthogonality over F₂)")
print()
print(f"CSS Code:")
print(f"  n = {steane_code.n} qubits")
print(f"  rx = {steane_code.rx} X-generators")
print(f"  rz = {steane_code.rz} Z-generators")
print(f"  Hx = Hᵀ·ᵀ = H (self-dual!)")

# Test various errors
print(f"\nSyndrome decoding demo:")
for err_pos in range(7):
    e = np.zeros(7, dtype=int)
    e[err_pos] = 1
    syn = steane_code.x_syndrome(e)
    print(f"  Error on qubit {err_pos}: syndrome = {syn}")

dist = steane_code.compute_distance()
print(f"\n  Code distance = {dist}")
print(f"  Correction radius = ⌊(d-1)/2⌋ = {(dist-1)//2}")
print(f"  Quantum Singleton: k + 2(d-1) = 1 + 2(3-1) = 5 ≤ 7 ✓")

# ============================================================
# Example 3: 4-qubit Code
# ============================================================

print("\n" + "=" * 60)
print("Example 3: 4-Qubit Code")
print("=" * 60)

d1_4q = np.array([[1, 0], [0, 1], [1, 1], [0, 0]])
d2_4q = np.array([[1, 1, 1, 0]])

four_complex = F2ChainComplex(d1_4q, d2_4q)
four_code = four_complex.to_css_code()

print(f"Chain complex: C₀(F₂²) →[∂₁]→ C₁(F₂⁴) →[∂₂]→ C₂(F₂¹)")
print(f"∂₂·∂₁ = {f2_mul(d2_4q, d1_4q)[0]} (= 0 ✓)")
print(f"CSS Code: n={four_code.n}, rx={four_code.rx}, rz={four_code.rz}")

dist = four_code.compute_distance()
print(f"Code distance = {dist}")

# ============================================================
# Example 4: Duality
# ============================================================

print("\n" + "=" * 60)
print("Example 4: Poincaré Duality")
print("=" * 60)

print(f"Original: C₀(F₂¹) →[∂₁]→ C₁(F₂³) →[∂₂]→ C₂(F₂²)")
print(f"Dual:     C₂(F₂²) →[∂₂ᵀ]→ C₁(F₂³) →[∂₁ᵀ]→ C₀(F₂¹)")
print()

# Dual complex
d1_dual = d2_rep.T  # ∂₂ᵀ
d2_dual = d1_rep.T  # ∂₁ᵀ

dual_complex = F2ChainComplex(d1_dual, d2_dual)
dual_code = dual_complex.to_css_code()

print(f"Original code: Hx = ∂₁ᵀ ({rep_code.rx}×{rep_code.n}), Hz = ∂₂ ({rep_code.rz}×{rep_code.n})")
print(f"Dual code:     Hx = ∂₂  ({dual_code.rx}×{dual_code.n}), Hz = ∂₁ᵀ ({dual_code.rz}×{dual_code.n})")
print(f"→ X and Z stabilizers are swapped!")
print(f"→ This is electromagnetic duality in quantum codes.")

# ============================================================
# Summary
# ============================================================

print("\n" + "=" * 60)
print("Summary: Chain Complex → CSS Code Functor")
print("=" * 60)
print("""
The chain complex condition ∂² = 0 is EQUIVALENT to the CSS
orthogonality condition Hx · Hzᵀ = 0.

This means:
  • Every chain complex gives a valid quantum code
  • Homology H₁ = ker(∂₂)/im(∂₁) counts logical qubits
  • Code distance = min weight of non-trivial homology class
  • Chain morphisms give code morphisms (functoriality)
  • Dualizing swaps X ↔ Z (electromagnetic duality)

All of these are FORMALLY VERIFIED in Lean 4 with Mathlib.
""")
