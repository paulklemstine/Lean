import Mathlib

/-!
# Why the coupling bit exists: discriminants, the sign character, and `p mod 3`

`Physics.S3TypeChannelUniversal` proves the information-theoretic law
`I(residue ; splitting type) = 1` for the Chebotarev model of an `S₃`-cubic.  The model
input is the classical fact that the *sign* of the Frobenius permutation is the quadratic
character of the discriminant.  This file supplies the algebraic and number-theoretic
backbone of that input, in three steps.

1. **The square root of the discriminant transforms by the sign character.**
   For any `n` and any `v : Fin n → R`, the Vandermonde product
   `δ(v) = ∏_{i<j} (v j - v i)` satisfies `δ(v ∘ σ) = sgn(σ) · δ(v)`
   (`S3Algebra.vandermonde_prod_perm`), proved from `Matrix.det_permute` and
   `Matrix.det_vandermonde`.  Hence `δ²` is Galois-invariant (the discriminant) while `δ`
   itself generates the quadratic resolvent, on which Galois acts by the sign character.

2. **The discriminant of a depressed cubic.**  If `r,s,t` are the roots of `x³ + ax + b`
   then `((r-s)(s-t)(t-r))² = -4a³ - 27b²` (`S3Algebra.disc_depressed_cubic`), a pure
   polynomial identity proved from the Vieta relations.  Specialising gives
   `disc(x³-3) = -243`, `disc(x³-2) = -108`, `disc(x³-x-1) = -23`.

3. **The resolvent character is `p mod 3` for two of the three fields.**
   `-243 = -3·9²` and `-108 = -3·6²` have squarefree kernel `-3`, and
   `S3Algebra.isSquare_neg_three_iff` proves `IsSquare (-3 : ZMod p) ↔ p ≡ 1 (mod 3)` for
   every prime `p ∉ {2,3}` — the cube-root-of-unity argument.  Consequently
   `S3Algebra.isSquare_neg243_iff` and `S3Algebra.isSquare_neg108_iff`: the Frobenius sign
   bit of the fields `x³-3` and `x³-2` at `p` is literally `p mod 3`, which is the residue
   observable used in the channel theorems.  The third field, `x³-x-1`, has squarefree
   discriminant `-23`, whence a genuinely different (mod 23) residue observable — and yet
   the same channel value.
-/

namespace S3Algebra

open scoped BigOperators
open Finset

/-! ## 1.  The Vandermonde product transforms by the sign character -/

/-- **The square root of the discriminant is a sign-character eigenvector.**
For any commutative ring `R`, any `v : Fin n → R` and any permutation `σ`, the Vandermonde
product `δ(v) = ∏_{i<j}(v j - v i)` satisfies `δ(v ∘ σ) = sgn(σ) · δ(v)`. -/
theorem vandermonde_prod_perm {R : Type*} [CommRing R] {n : ℕ} (v : Fin n → R)
    (σ : Equiv.Perm (Fin n)) :
    ∏ i, ∏ j ∈ Ioi i, (v (σ j) - v (σ i))
      = ((Equiv.Perm.sign σ : ℤ) : R) * ∏ i, ∏ j ∈ Ioi i, (v j - v i) := by
  have h1 : (Matrix.vandermonde (v ∘ σ)) = (Matrix.vandermonde v).submatrix (⇑σ) id := by
    funext i j; simp [Matrix.vandermonde, Matrix.submatrix]
  have h3 : (Matrix.vandermonde (v ∘ σ)).det
      = ((Equiv.Perm.sign σ : ℤ) : R) * (Matrix.vandermonde v).det := by
    rw [h1, Matrix.det_permute]
  rw [Matrix.det_vandermonde, Matrix.det_vandermonde] at h3
  simpa using h3

/-- The discriminant `δ²` is Galois-invariant: only the *sign* of `δ` moves. -/
theorem vandermonde_sq_perm_invariant {R : Type*} [CommRing R] {n : ℕ} (v : Fin n → R)
    (σ : Equiv.Perm (Fin n)) :
    (∏ i, ∏ j ∈ Ioi i, (v (σ j) - v (σ i))) ^ 2
      = (∏ i, ∏ j ∈ Ioi i, (v j - v i)) ^ 2 := by
  rw [vandermonde_prod_perm v σ, mul_pow]
  have : ((Equiv.Perm.sign σ : ℤ) : R) ^ 2 = 1 := by
    rcases Int.units_eq_one_or (Equiv.Perm.sign σ) with h | h <;> rw [h] <;> norm_num
  rw [this, one_mul]

/-! ## 2.  The discriminant of a depressed cubic -/

/-- **Discriminant of `x³ + a x + b`.**  If `r, s, t` are its roots (Vieta: `r+s+t = 0`,
`rs+st+tr = a`, `rst = -b`) then the square of the Vandermonde product is `-4a³ - 27b²`. -/
theorem disc_depressed_cubic {R : Type*} [CommRing R] (r s t a b : R)
    (h1 : r + s + t = 0) (h2 : r * s + s * t + t * r = a) (h3 : r * s * t = -b) :
    ((r - s) * (s - t) * (t - r)) ^ 2 = -4 * a ^ 3 - 27 * b ^ 2 := by
  have ht : t = -r - s := by linear_combination h1
  subst ht
  have ha : a = -(r ^ 2 + r * s + s ^ 2) := by linear_combination -h2
  have hb : b = r ^ 2 * s + r * s ^ 2 := by linear_combination h3
  rw [ha, hb]; ring

/-- `disc(x³ - 3) = -243`. -/
theorem disc_x3_sub_3 {R : Type*} [CommRing R] (r s t : R)
    (h1 : r + s + t = 0) (h2 : r * s + s * t + t * r = 0) (h3 : r * s * t = 3) :
    ((r - s) * (s - t) * (t - r)) ^ 2 = -243 := by
  have := disc_depressed_cubic r s t 0 (-3) h1 h2 (by linear_combination h3)
  rw [this]; norm_num

/-- `disc(x³ - 2) = -108`. -/
theorem disc_x3_sub_2 {R : Type*} [CommRing R] (r s t : R)
    (h1 : r + s + t = 0) (h2 : r * s + s * t + t * r = 0) (h3 : r * s * t = 2) :
    ((r - s) * (s - t) * (t - r)) ^ 2 = -108 := by
  have := disc_depressed_cubic r s t 0 (-2) h1 h2 (by linear_combination h3)
  rw [this]; norm_num

/-- `disc(x³ - x - 1) = -23`. -/
theorem disc_x3_sub_x_sub_1 {R : Type*} [CommRing R] (r s t : R)
    (h1 : r + s + t = 0) (h2 : r * s + s * t + t * r = -1) (h3 : r * s * t = 1) :
    ((r - s) * (s - t) * (t - r)) ^ 2 = -23 := by
  have := disc_depressed_cubic r s t (-1) (-1) h1 h2 (by linear_combination h3)
  rw [this]; norm_num

/-- The three discriminants are pairwise distinct: three genuinely different fields. -/
theorem three_discriminants_distinct :
    (-243 : ℤ) ≠ -108 ∧ (-243 : ℤ) ≠ -23 ∧ (-108 : ℤ) ≠ -23 := by
  refine ⟨by decide, by decide, by decide⟩

/-- Two of the three discriminants have the same squarefree kernel `-3`, the third has
squarefree kernel `-23`: the resolvent fields are `ℚ(√-3)`, `ℚ(√-3)` and `ℚ(√-23)`. -/
theorem squarefree_kernels :
    (-243 : ℤ) = -3 * 9 ^ 2 ∧ (-108 : ℤ) = -3 * 6 ^ 2 ∧ (-23 : ℤ) = -23 * 1 ^ 2 ∧
      Squarefree (-3 : ℤ) ∧ Squarefree (-23 : ℤ) := by
  refine ⟨by norm_num, by norm_num, by norm_num, ?_, ?_⟩
  · have h : Prime (-3 : ℤ) := by rw [Int.prime_iff_natAbs_prime]; norm_num
    exact h.squarefree
  · have h : Prime (-23 : ℤ) := by rw [Int.prime_iff_natAbs_prime]; norm_num
    exact h.squarefree

/-! ## 3.  The resolvent character of `ℚ(√-3)` is `p mod 3` -/

/-- Multiplying by a nonzero square does not change squareness. -/
theorem isSquare_mul_sq_iff {F : Type*} [Field F] (u v : F) (hv : v ≠ 0) :
    IsSquare (u * v ^ 2) ↔ IsSquare u := by
  constructor
  · rintro ⟨w, hw⟩
    refine ⟨w / v, ?_⟩
    field_simp
    linear_combination hw
  · rintro ⟨w, hw⟩
    exact ⟨w * v, by rw [hw]; ring⟩

private lemma cast_ne_zero_of_prime_ne (p q : ℕ) [Fact p.Prime] (hq : q.Prime) (hne : p ≠ q) :
    ((q : ℕ) : ZMod p) ≠ 0 := by
  have hp : p.Prime := Fact.out
  intro hz
  exact hne ((Nat.prime_dvd_prime_iff_eq hp hq).1 ((CharP.cast_eq_zero_iff (ZMod p) p q).1 hz))

/-- **The quadratic character of `-3` is the residue mod `3`.**
For a prime `p ∉ {2,3}`, `-3` is a square mod `p` if and only if `p ≡ 1 (mod 3)`.
The proof is the cube-root-of-unity argument: `ζ = (y-1)/2` where `y² = -3`, resp.
`y = 2ζ+1` where `ζ` is an element of order `3` supplied by Cauchy's theorem. -/
theorem isSquare_neg_three_iff (p : ℕ) [Fact p.Prime] (hp2 : p ≠ 2) (hp3 : p ≠ 3) :
    IsSquare (-3 : ZMod p) ↔ p % 3 = 1 := by
  have hp : p.Prime := Fact.out
  have hp1 : 2 ≤ p := hp.two_le
  have h2 : (2 : ZMod p) ≠ 0 := by
    have := cast_ne_zero_of_prime_ne p 2 Nat.prime_two hp2
    simpa using this
  have h3 : (3 : ZMod p) ≠ 0 := by
    have := cast_ne_zero_of_prime_ne p 3 Nat.prime_three hp3
    simpa using this
  haveI : Fact (Nat.Prime 3) := ⟨Nat.prime_three⟩
  constructor
  · rintro ⟨y, hy⟩
    -- `hy : -3 = y * y`
    set z : ZMod p := (y - 1) / 2 with hzdef
    have hz2 : 2 * z = y - 1 := by
      rw [hzdef]; field_simp
    have hzsum : z ^ 2 + z + 1 = 0 := by
      have h4 : (4 : ZMod p) ≠ 0 := by
        intro h
        apply h2
        have : (2 : ZMod p) * 2 = 0 := by linear_combination h
        rcases mul_eq_zero.1 this with h' | h' <;> exact h'
      have key : (4 : ZMod p) * (z ^ 2 + z + 1) = (2 * z + 1) ^ 2 + 3 := by ring
      rw [hz2] at key
      have : (4 : ZMod p) * (z ^ 2 + z + 1) = 0 := by
        rw [key]; linear_combination -hy
      rcases mul_eq_zero.1 this with h' | h'
      · exact absurd h' h4
      · exact h'
    have hzcube : z ^ 3 = 1 := by linear_combination (z - 1) * hzsum
    have hzne : z ≠ 1 := by
      intro h
      apply h3
      rw [h] at hzsum
      linear_combination hzsum
    have hord : orderOf z = 3 := by
      have hdvd : orderOf z ∣ 3 := orderOf_dvd_of_pow_eq_one hzcube
      have h1 : orderOf z ≠ 1 := by
        intro h
        exact hzne (orderOf_eq_one_iff.1 h)
      rcases (Nat.Prime.eq_one_or_self_of_dvd Nat.prime_three _ hdvd) with h | h
      · exact absurd h h1
      · exact h
    have hz0 : z ≠ 0 := by
      intro h
      rw [h] at hzcube
      simp at hzcube
    have hfermat : z ^ (p - 1) = 1 := ZMod.pow_card_sub_one_eq_one hz0
    have hdvd : 3 ∣ p - 1 := by
      have := orderOf_dvd_of_pow_eq_one hfermat
      rwa [hord] at this
    obtain ⟨c, hc⟩ := hdvd
    omega
  · intro hmod
    have hdvd : 3 ∣ Fintype.card (ZMod p)ˣ := by
      rw [ZMod.card_units_eq_totient, Nat.totient_prime hp]
      omega
    obtain ⟨u, hu⟩ := exists_prime_orderOf_dvd_card 3 hdvd
    have hu3 : u ^ 3 = 1 := by rw [← hu]; exact pow_orderOf_eq_one u
    have hune : u ≠ 1 := by
      intro h
      rw [h] at hu
      simp at hu
    set z : ZMod p := (u : ZMod p) with hzdef
    have hz3 : z ^ 3 = 1 := by
      have : ((u ^ 3 : (ZMod p)ˣ) : ZMod p) = ((1 : (ZMod p)ˣ) : ZMod p) := by rw [hu3]
      simpa [hzdef] using this
    have hzne : z ≠ 1 := by
      intro h
      apply hune
      exact Units.ext (by simpa [hzdef] using h)
    have hzsum : z ^ 2 + z + 1 = 0 := by
      have hfac : (z - 1) * (z ^ 2 + z + 1) = 0 := by linear_combination hz3
      rcases mul_eq_zero.1 hfac with h' | h'
      · exact absurd (by linear_combination h') hzne
      · exact h'
    exact ⟨2 * z + 1, by linear_combination -4 * hzsum⟩

/-- **The Frobenius sign bit of `x³ - 3` at `p` is `p mod 3`.**  `disc = -243 = -3·9²`. -/
theorem isSquare_neg243_iff (p : ℕ) [Fact p.Prime] (hp2 : p ≠ 2) (hp3 : p ≠ 3) :
    IsSquare ((-243 : ℤ) : ZMod p) ↔ p % 3 = 1 := by
  have h9 : ((9 : ℤ) : ZMod p) ≠ 0 := by
    have h3 : ((3 : ℕ) : ZMod p) ≠ 0 := cast_ne_zero_of_prime_ne p 3 Nat.prime_three hp3
    intro h
    apply h3
    have : ((3 : ZMod p)) * 3 = 0 := by push_cast at h ⊢; linear_combination h
    rcases mul_eq_zero.1 this with h' | h' <;> simpa using h'
  have hrw : ((-243 : ℤ) : ZMod p) = (-3 : ZMod p) * (9 : ZMod p) ^ 2 := by
    push_cast; ring
  rw [hrw, isSquare_mul_sq_iff _ _ (by simpa using h9)]
  exact isSquare_neg_three_iff p hp2 hp3

/-- **The Frobenius sign bit of `x³ - 2` at `p` is also `p mod 3`.**  `disc = -108 = -3·6²`.
Two different cubics, two different discriminants, one residue observable. -/
theorem isSquare_neg108_iff (p : ℕ) [Fact p.Prime] (hp2 : p ≠ 2) (hp3 : p ≠ 3) :
    IsSquare ((-108 : ℤ) : ZMod p) ↔ p % 3 = 1 := by
  have h6 : ((6 : ℤ) : ZMod p) ≠ 0 := by
    have h2 : ((2 : ℕ) : ZMod p) ≠ 0 := cast_ne_zero_of_prime_ne p 2 Nat.prime_two hp2
    have h3 : ((3 : ℕ) : ZMod p) ≠ 0 := cast_ne_zero_of_prime_ne p 3 Nat.prime_three hp3
    intro h
    have : (2 : ZMod p) * 3 = 0 := by push_cast at h ⊢; linear_combination h
    rcases mul_eq_zero.1 this with h' | h'
    · exact h2 (by simpa using h')
    · exact h3 (by simpa using h')
  have hrw : ((-108 : ℤ) : ZMod p) = (-3 : ZMod p) * (6 : ZMod p) ^ 2 := by
    push_cast; ring
  rw [hrw, isSquare_mul_sq_iff _ _ (by simpa using h6)]
  exact isSquare_neg_three_iff p hp2 hp3

end S3Algebra