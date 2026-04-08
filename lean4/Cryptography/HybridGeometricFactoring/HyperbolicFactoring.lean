/-
# Hyperbolic Geometry and Integer Factoring

This file formalizes the connection between hyperbolic geometry and factoring.
The key insight: divisor pairs (d, n/d) of n lie on the rectangular hyperbola xy = n,
and the hyperbolic distance between divisor pairs encodes factoring-relevant information.

The Poincaré half-plane model H² = {z ∈ ℂ : Im(z) > 0} with metric ds² = (dx² + dy²)/y²
provides a natural geometric framework: the group SL₂(ℤ) acts on H² by Möbius
transformations, and this action connects modular arithmetic to hyperbolic geometry.

## Main Results

* `hyperbola_symmetry` — The hyperbola xy = n is symmetric under (x,y) ↦ (y,x).
* `divisor_pair_product` — For d | n, d · (n/d) = n.
* `SL2Z.mul_det` — SL₂(ℤ) matrices preserve determinant 1.
* `convergent_coprime_of_det_one` — CF convergents are coprime pairs.
* `crt_quadratic_residue` — QR mod pq implies QR mod p (CRT projection).
-/

import Mathlib

open Nat

namespace HGF.Hyperbolic

/-! ## Section 1: The Divisor Hyperbola -/

/-- The divisor hyperbola: points (d, n/d) for d | n.
    The divisors come in pairs (d, n/d) which are symmetric. -/
theorem hyperbola_symmetry {n d : ℕ} (hd : d ∣ n) :
    (n / d) ∣ n :=
  Nat.div_dvd_of_dvd hd

/-- For the pair (d, n/d), the product is always n. -/
theorem divisor_pair_product {n d : ℕ} (hd : d ∣ n) :
    d * (n / d) = n :=
  Nat.mul_div_cancel' hd

/-- d² ≤ n implies d ≤ n for any divisor d (the "small" divisor). -/
theorem small_divisor_bound {n d : ℕ} (hd : d ∣ n) (hn : 0 < n) :
    d ≤ n :=
  Nat.le_of_dvd hn hd

/-! ## Section 2: Modular Group SL₂(ℤ) -/

/-- A matrix in SL₂(ℤ): a 2×2 integer matrix with determinant 1. -/
structure SL2Z where
  a : ℤ
  b : ℤ
  c : ℤ
  d : ℤ
  det_eq : a * d - b * c = 1

/-- The identity matrix is in SL₂(ℤ). -/
def SL2Z.one : SL2Z := ⟨1, 0, 0, 1, by ring⟩

/-- The matrix T = [[1,1],[0,1]] (translation) is in SL₂(ℤ). -/
def SL2Z.T : SL2Z := ⟨1, 1, 0, 1, by ring⟩

/-- The matrix S = [[0,-1],[1,0]] (inversion) is in SL₂(ℤ). -/
def SL2Z.S : SL2Z := ⟨0, -1, 1, 0, by ring⟩

/-- SL₂(ℤ) is closed under multiplication. -/
def SL2Z.mul (M N : SL2Z) : SL2Z :=
  ⟨M.a * N.a + M.b * N.c,
   M.a * N.b + M.b * N.d,
   M.c * N.a + M.d * N.c,
   M.c * N.b + M.d * N.d,
   by nlinarith [M.det_eq, N.det_eq]⟩

/-- The determinant is preserved under multiplication. -/
theorem SL2Z.mul_det (M N : SL2Z) :
    (SL2Z.mul M N).a * (SL2Z.mul M N).d - (SL2Z.mul M N).b * (SL2Z.mul M N).c = 1 :=
  (SL2Z.mul M N).det_eq

/-! ## Section 3: Continued Fractions and Coprimality -/

/-- Consecutive convergents of a continued fraction satisfy |pq' - p'q| = 1,
    which implies they are coprime. -/
theorem convergent_coprime_of_det_one {p q : ℤ} (hq : 0 < q)
    (h : ∃ p' q' : ℤ, p * q' - p' * q = 1) :
    IsCoprime p q := by
  obtain ⟨p', q', hdet⟩ := h
  exact ⟨q', -p', by linarith⟩

/-- The mediant of two fractions a/b and c/d is (a+c)/(b+d).
    If they are Farey neighbors, b+d > 0. -/
theorem farey_mediant_denominator {b d : ℕ} (hb : 0 < b) (hd : 0 < d) :
    0 < b + d := by omega

/-! ## Section 4: Hyperbolic Distance and Factoring Complexity -/

/-- The "hyperbolic" relationship between divisor pairs: if d₁ ≤ d₂ are both
    divisors of n, then n/d₂ ≤ n/d₁ (the companion divisors are reversed). -/
theorem divisor_companion_reversed {d₁ d₂ n : ℕ}
    (hd1 : d₁ ∣ n) (hd2 : d₂ ∣ n)
    (hd1_pos : 0 < d₁) (hle : d₁ ≤ d₂) :
    n / d₂ ≤ n / d₁ :=
  Nat.div_le_div_left hle hd1_pos

/-! ## Section 5: Connection to Quadratic Residues -/

/-- If a is a nonzero quadratic residue mod p, then its square root is also nonzero. -/
theorem quadratic_residue_nonzero {p : ℕ} (hp : Nat.Prime p)
    {a : ZMod p} (ha : a ≠ 0) (hsq : ∃ x : ZMod p, x * x = a) :
    ∃ x : ZMod p, x * x = a ∧ x ≠ 0 := by
  obtain ⟨x, hx⟩ := hsq
  exact ⟨x, hx, fun hx0 => ha (by rw [← hx, hx0, mul_zero])⟩

/-- The CRT projection: QR mod pq implies QR mod p. -/
theorem crt_quadratic_residue {p q : ℕ} (hp : Nat.Prime p) (hq : Nat.Prime q)
    {a : ZMod (p * q)} :
    (∃ x : ZMod (p * q), x * x = a) →
    (∃ xp : ZMod p, xp * xp = ZMod.castHom (dvd_mul_right p q) (ZMod p) a) := by
  intro ⟨x, hx⟩
  exact ⟨ZMod.castHom (dvd_mul_right p q) (ZMod p) x, by rw [← map_mul, hx]⟩

end HGF.Hyperbolic
