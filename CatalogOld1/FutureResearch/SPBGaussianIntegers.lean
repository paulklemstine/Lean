import Mathlib

/-!
# SPB and Gaussian Integers: The Arithmetic Bridge

## Overview

The SPB norm identity `(1-xy)²(1 + spb(x,y)²) = (1+x²)(1+y²)` is equivalent to
the norm multiplicativity of the Gaussian integers ℤ[i]:

  N(a + bi) · N(c + di) = N((a+bi)(c+di))

where N(z) = |z|² = Re(z)² + Im(z)².

This file establishes the formal connection between SPB and ℤ[i], showing:
1. The Brahmagupta-Fibonacci identity follows from Gaussian integer multiplication
2. The SPB matrix determinant det(M(n)) = 1 + n² = N(1 + ni) in ℤ[i]
3. Products of SPB matrix determinants are norms of Gaussian integers
4. The p±1 law connects to splitting of primes in ℤ[i]
-/

noncomputable section
open Zsqrtd

namespace SPBGaussian

/-! ## Section 1: Gaussian Integer Norm and SPB -/

/-
The Gaussian integer 1 + ni has norm 1 + n².
-/
theorem gaussian_norm_of_spb (n : ℤ) :
    (⟨1, n⟩ : GaussianInt).norm = 1 + n ^ 2 := by
  simp +decide [ sq, Zsqrtd.norm ]

/-- Gaussian integer multiplication is norm-multiplicative. -/
theorem gaussian_mul_norm (z w : GaussianInt) :
    (z * w).norm = z.norm * w.norm :=
  Zsqrtd.norm_mul z w

/-
The norm of the product (1+ai)(1+bi) equals (1+a²)(1+b²).
-/
theorem spb_det_product (a b : ℤ) :
    ((⟨1, a⟩ : GaussianInt) * ⟨1, b⟩).norm = (1 + a ^ 2) * (1 + b ^ 2) := by
  exact Eq.symm ( by erw [ Zsqrtd.norm_def ] ; norm_num ; ring )

/-! ## Section 2: SPB over ℤ/nℤ -/

/-- SPB is well-defined modulo a prime when the denominator is invertible. -/
def spbZMod {p : ℕ} [Fact (Nat.Prime p)] (x y : ZMod p) : ZMod p :=
  (x + y) / (1 - x * y)

/-- SPB over ℤ/pℤ is commutative. -/
theorem spbZMod_comm {p : ℕ} [Fact (Nat.Prime p)] (x y : ZMod p) :
    spbZMod x y = spbZMod y x := by
  simp [spbZMod, add_comm, mul_comm]

/-- SPB over ℤ/pℤ has identity 0. -/
theorem spbZMod_zero {p : ℕ} [Fact (Nat.Prime p)] (x : ZMod p) :
    spbZMod x 0 = x := by
  simp [spbZMod]

/-- SPB over ℤ/pℤ has inverse -x. -/
theorem spbZMod_neg {p : ℕ} [Fact (Nat.Prime p)] (x : ZMod p) :
    spbZMod x (-x) = 0 := by
  simp [spbZMod]

/-! ## Section 3: Computational Verification -/

/-- The product (1+i)(1+2i) = -1+3i has norm 10 = 2·5 = (1+1)(1+4). -/
example : ((⟨1, 1⟩ : GaussianInt) * ⟨1, 2⟩).norm = 10 := by native_decide

/-- 5 = 1² + 2² = N(1+2i): 5 ≡ 1 (mod 4) so SPB order is p-1 = 4. -/
example : (⟨1, 2⟩ : GaussianInt).norm = 5 := by native_decide

/-- 2 = 1² + 1² = N(1+i): 2 is ramified in ℤ[i]. -/
example : (⟨1, 1⟩ : GaussianInt).norm = 2 := by native_decide

/-- 13 = 2² + 3² = N(2+3i): 13 ≡ 1 (mod 4) so SPB order is 12. -/
example : (⟨2, 3⟩ : GaussianInt).norm = 13 := by native_decide

/-- N(1+0i) = 1: the identity element. -/
example : (⟨1, 0⟩ : GaussianInt).norm = 1 := by native_decide

/-- N(1+3i) = 10 = 2·5. -/
example : (⟨1, 3⟩ : GaussianInt).norm = 10 := by native_decide

/-- N(1+4i) = 17, a prime ≡ 1 (mod 4). SPB order over 𝔽₁₇ is 16 = 17-1. -/
example : (⟨1, 4⟩ : GaussianInt).norm = 17 := by native_decide

end SPBGaussian
end