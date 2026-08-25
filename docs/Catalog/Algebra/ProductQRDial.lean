/-
# The product QR dial: an XOR law, factor blindness, and where the flip lives

Formal core of experiment **577** (paper 227), arithmetic part.  The covariate
of the experiment is the *product dial*

  `W(N, P) = ∑_{ℓ ∈ P, N a QR mod ℓ} 1/ℓ`,

evaluated on semiprimes `N = p q`.  This file proves the three arithmetic facts
that govern its behaviour.

## Main results

* `ProductQRDial.qr_product_iff` — the **XOR law**: for a prime `ℓ` coprime to
  both factors, `p q` is a residue mod `ℓ` iff `p` and `p` have the *same*
  residue status.  The product dial reads a parity, not the factors.
* `ProductQRDial.qrWeight_blind` and `ProductQRDial.qrWeight_pp_eq_nn` — the
  resulting **factor blindness** of the weighted product dial: `PP` and `NN`
  factorisation types produce *identical* weighted dials, exactly as the
  extrinsic class-group representation vector of
  `Catalog/Algebra/ClassGroupResidueDial.lean` collapses `PP` and `NN`.
* `ProductQRDial.qrWeight_sq` — squares saturate the dial: every prime of the
  window contributes, so the dial is maximal on squares.
* `ProductQRDial.dial_forms_agree_on_one_mod_four` — **where the reciprocity
  artifact lives**: on a window consisting of primes `ℓ ≡ 1 (mod 4)` the
  composite-bottom (product) dial and the clean prime-bottom dial are *equal*.
  All of the discrepancy diagnosed in `Catalog/Algebra/ReciprocityFlipDial.lean`
  is carried by the `ℓ ≡ 3 (mod 4)` part of the window.
-/
import Mathlib
import Algebra.ReciprocityFlipDial

namespace ProductQRDial

open Finset

/-! ## 1. The XOR law for the product dial -/

/-- **XOR law.**  For an odd modulus `ℓ` coprime to both factors, the product
`a * b` is recorded as a residue exactly when `a` and `b` have equal symbols. -/
theorem qr_product_iff {a b : ℤ} {l : ℕ} (ha : Int.gcd a l = 1) (hb : Int.gcd b l = 1) :
    jacobiSym (a * b) l = 1 ↔ jacobiSym a l = jacobiSym b l := by
  rw [jacobiSym.mul_left]
  rcases jacobiSym.eq_one_or_neg_one ha with h1 | h1 <;>
    rcases jacobiSym.eq_one_or_neg_one hb with h2 | h2 <;>
    simp [h1, h2]

/-- The `PP` and `NN` cases both produce the value `+1`. -/
theorem qr_product_pp_eq_nn {p q p' q' : ℤ} {l : ℕ}
    (hp : jacobiSym p l = 1) (hq : jacobiSym q l = 1)
    (hp' : jacobiSym p' l = -1) (hq' : jacobiSym q' l = -1) :
    jacobiSym (p * q) l = jacobiSym (p' * q') l := by
  rw [jacobiSym.mul_left, jacobiSym.mul_left, hp, hq, hp', hq']
  norm_num

/-! ## 2. The weighted product dial -/

/-- The `1/ℓ`-weighted product dial of `N` over a window `P` of moduli. -/
noncomputable def qrWeight (N : ℤ) (P : Finset ℕ) : ℝ :=
  ∑ l ∈ P, if jacobiSym N l = 1 then (1 : ℝ) / l else 0

/-- The dial is determined by the symbol values; equal symbols give equal
dials. -/
theorem qrWeight_congr {M N : ℤ} {P : Finset ℕ}
    (h : ∀ l ∈ P, jacobiSym M l = jacobiSym N l) : qrWeight M P = qrWeight N P := by
  unfold qrWeight
  exact Finset.sum_congr rfl (fun l hl => by rw [h l hl])

/-- **Factor blindness of the product dial.**  Two semiprimes whose factor
symbols have the same product at every modulus of the window are indistinguishable
by the weighted product dial. -/
theorem qrWeight_blind {p q p' q' : ℤ} {P : Finset ℕ}
    (h : ∀ l ∈ P, jacobiSym p l * jacobiSym q l = jacobiSym p' l * jacobiSym q' l) :
    qrWeight (p * q) P = qrWeight (p' * q') P := by
  refine qrWeight_congr (fun l hl => ?_)
  rw [jacobiSym.mul_left, jacobiSym.mul_left]
  exact h l hl

/-- **`PP` and `NN` are invisible.**  If at every modulus of the window both
factors of `N` are residues, while both factors of `N'` are non-residues, the two
weighted product dials coincide — the same collapse as for the class-group
residue dial. -/
theorem qrWeight_pp_eq_nn {p q p' q' : ℤ} {P : Finset ℕ}
    (hp : ∀ l ∈ P, jacobiSym p l = 1) (hq : ∀ l ∈ P, jacobiSym q l = 1)
    (hp' : ∀ l ∈ P, jacobiSym p' l = -1) (hq' : ∀ l ∈ P, jacobiSym q' l = -1) :
    qrWeight (p * q) P = qrWeight (p' * q') P := by
  refine qrWeight_blind (fun l hl => ?_)
  rw [hp l hl, hq l hl, hp' l hl, hq' l hl]
  norm_num

/-- **Squares saturate the dial.**  If `m` is coprime to every modulus of the
window then `m²` is a residue at all of them, so its dial is the full harmonic
window weight — the maximum possible value. -/
theorem qrWeight_sq {m : ℤ} {P : Finset ℕ} (hm : ∀ l ∈ P, Int.gcd m l = 1) :
    qrWeight (m * m) P = ∑ l ∈ P, (1 : ℝ) / l := by
  unfold qrWeight
  refine Finset.sum_congr rfl (fun l hl => ?_)
  have h : jacobiSym (m * m) l = 1 := by
    rw [jacobiSym.mul_left]
    rcases jacobiSym.eq_one_or_neg_one (hm l hl) with h1 | h1 <;> rw [h1] <;> norm_num
  rw [if_pos h]

/-! ## 3. Where the reciprocity artifact lives -/

/-- **The dial forms agree away from `3 mod 4`.**  On a window of moduli
`ℓ ≡ 1 (mod 4)` the composite-bottom (product) dial `ℓ ↦ (ℓ | N)` and the clean
prime-bottom dial `ℓ ↦ (N | ℓ)` are *identical* covariates.  Consequently the
entire dial-form artifact of paper 226 is carried by the `ℓ ≡ 3 (mod 4)` moduli,
and only when `N ≡ 3 (mod 4)`. -/
theorem dial_forms_agree_on_one_mod_four {N : ℕ} (hN : Odd N) {P : Finset ℕ}
    (hP : ∀ l ∈ P, Odd l ∧ l % 4 = 1) :
    ∑ l ∈ P, (if jacobiSym (l : ℤ) N = 1 then (1 : ℝ) / l else 0)
      = ∑ l ∈ P, (if jacobiSym (N : ℤ) l = 1 then (1 : ℝ) / l else 0) := by
  refine Finset.sum_congr rfl (fun l hl => ?_)
  obtain ⟨hlodd, hl1⟩ := hP l hl
  have hflip : ¬ (l % 4 = 3 ∧ N % 4 = 3) := by
    rintro ⟨h3, -⟩; omega
  rw [ReciprocityFlipDial.jacobi_agree_of_not_both_three_mod_four hlodd hN hflip]

/-- **And they can differ on `3 mod 4`.**  For a modulus `ℓ ≡ 3 (mod 4)` and
`N ≡ 3 (mod 4)` coprime to it, exactly one of the two forms records a residue:
the two dials are *complementary* there, not merely different. -/
theorem dial_forms_complementary_on_three_mod_four {l N : ℕ}
    (hl : l % 4 = 3) (hN : N % 4 = 3) (hcop : Nat.Coprime l N) :
    (jacobiSym (l : ℤ) N = 1) ↔ ¬ (jacobiSym (N : ℤ) l = 1) := by
  have hlodd : Odd l := Nat.odd_iff.mpr (by omega)
  have hNodd : Odd N := Nat.odd_iff.mpr (by omega)
  have hflip : jacobiSym (l : ℤ) N = - jacobiSym (N : ℤ) l :=
    ReciprocityFlipDial.jacobi_flip_of_three_mod_four hl hN
  have hgcd : Int.gcd (N : ℤ) l = 1 := by
    simpa [Int.gcd_natCast_natCast] using (Nat.coprime_comm.mp hcop)
  rcases jacobiSym.eq_one_or_neg_one hgcd with h | h <;> rw [hflip, h] <;> norm_num

end ProductQRDial