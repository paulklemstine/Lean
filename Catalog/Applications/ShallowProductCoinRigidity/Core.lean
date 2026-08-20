/-
Copyright (c) 2026. Released under the Apache 2.0 license.
-/
import Mathlib

/-!
# Rigidity gap for shallow product coins — the bipartite core

## Setting

Fix two finite "registers" `A` and `B` and a *resonance set* `R ⊆ A × B`.
A **coin** on a finite register is an `ℓ²`-normalised complex amplitude vector,
`∑ a, ‖f a‖² = 1`.  The **resonance amplitude** of the *product coin* `f ⊗ g` is

`bipAmp R f g = ∑ x ∈ R, f x.1 * g x.2`.

The elementary Cauchy–Schwarz bound is `‖bipAmp R f g‖² ≤ |R|`
(`bipAmp_sq_le_card`), with equality forcing the product coin to be the
normalised indicator of `R`.  The content of this file is the *quantitative*
converse:

**Main theorem** (`bipAmp_sq_gap`).  If `R` is **not** a combinatorial box, then
for *every* product coin

`‖bipAmp R f g‖² · (3|R| + 1) ≤ 3|R|²`,  i.e.  `‖A(ψ)‖² ≤ (1 - 1/(3|R|+1))·|R|`,

an explicit multiplicative deficiency depending only on `|R|`; in additive form
`‖A(ψ)‖² ≤ |R| - 2/7` (`bipAmp_sq_le_card_sub`).

Combined with the fact that a box *does* attain the optimum
(`isBox_attains`), this yields the exact dichotomy
`resonanceAmplitude_sq_eq_iff`: the optimum `|R|` is attained by a product coin
**iff** `R` is a box.

## Proof idea

Write `u = |f| ⊗ |g|` for the modulus product vector, `T = ∑_{x∈R} u x`,
`m = |R|` and `μ = T/m`.  A direct expansion gives

`∑_{x} (u x - μ·1_R x)² = 1 - T²/m`.

If `R` is not a box there are `(a,b), (a',b') ∈ R` with `(a,b') ∉ R`, and the
four points `(a,b), (a,b'), (a',b), (a',b')` are pairwise distinct.  The `2 × 2`
minor of `u` at these points vanishes (`u` has rank one), while the
corresponding minor of `μ·1_R` equals `μ²`.  Comparing the two minors through
the four deviations `e₁₁, e₁₂, e₂₁, e₂₂` and an AM–GM step
(`rankOne_minor_ineq`) gives `μ² ≤ 3(e₁₁²+e₁₂²+e₂₁²+e₂₂²) ≤ 3(1 - T²/m)`, i.e.
`T²/m² ≤ 3 - 3T²/m`, which is exactly `T²(3m+1) ≤ 3m²`.  No singular-value
theory is needed.
-/

open Finset

namespace ShallowProductCoin

variable {A B : Type*} [Fintype A] [Fintype B] [DecidableEq A] [DecidableEq B]

/-- A **coin** on a finite register: an `ℓ²`-normalised complex amplitude vector. -/
def IsCoin (f : A → ℂ) : Prop := ∑ a, ‖f a‖ ^ 2 = 1

/-- The **resonance amplitude** of the product coin `f ⊗ g` against the
resonance set `R`. -/
noncomputable def bipAmp (R : Finset (A × B)) (f : A → ℂ) (g : B → ℂ) : ℂ :=
  ∑ x ∈ R, f x.1 * g x.2

/-- `R` is a **combinatorial box** (a product set): it is closed under
recombining the first coordinate of one element with the second coordinate of
another. -/
def IsBox (R : Finset (A × B)) : Prop := ∀ x ∈ R, ∀ y ∈ R, (x.1, y.2) ∈ R

/-! ### Two elementary ingredients -/

/-- The algebraic heart of the gap.  If a vanishing `2 × 2` minor of a rank-one
matrix is compared with the minor `μ²` of a `0/1` pattern through the four
deviations `e₁₁, e₁₂, e₂₁, e₂₂`, then `μ² ≤ 3·(e₁₁²+e₁₂²+e₂₁²+e₂₂²)`.

The hypothesis `hid` is the vanishing of the rank-one minor written in terms of
the deviations; `c ≤ 1` bounds the (unknown) value of the pattern at the fourth
point, and `mu`, `e₁₂` are nonnegative because the underlying vector is a
product of moduli.

The optimal constant here is `φ² = (3+√5)/2 = 2.618…`, attained at
`(e₁₁,e₁₂,e₂₁,e₂₂) = (-1,√5,1,-1)·(√5-2)/…`; the value `3` used below is a
convenient rational relaxation. -/
theorem rankOne_minor_ineq (mu c e11 e12 e21 e22 : ℝ) (hmu : 0 ≤ mu) (he12 : 0 ≤ e12)
    (hc1 : c ≤ 1)
    (hid : mu ^ 2 + mu * (e11 + e22) + e11 * e22 - mu * c * e12 - e12 * e21 = 0) :
    mu ^ 2 ≤ 3 * (e11 ^ 2 + e12 ^ 2 + e21 ^ 2 + e22 ^ 2) := by
  nlinarith [sq_nonneg (mu + e11 + e22), sq_nonneg (e11 - e22), sq_nonneg (e12 - e21),
    sq_nonneg (mu - 2 * e12), sq_nonneg (mu + 2 * e11), sq_nonneg (mu + 2 * e22),
    mul_nonneg hmu he12, mul_nonneg hmu (mul_nonneg he12 (sub_nonneg.2 hc1)),
    sq_nonneg (e11 + e22 + e12)]

/-- Four values of a nonnegative function at the four corners of a
combinatorial rectangle are dominated by the total sum. -/
theorem sum_four_le (F : A × B → ℝ) (hF : ∀ x, 0 ≤ F x) {a a' : A} {b b' : B}
    (ha : a ≠ a') (hb : b ≠ b') :
    F (a, b) + F (a, b') + F (a', b) + F (a', b') ≤ ∑ x : A × B, F x := by
  have hsub : ({(a, b), (a, b'), (a', b), (a', b')} : Finset (A × B)) ⊆ Finset.univ :=
    Finset.subset_univ _
  have h := Finset.sum_le_sum_of_subset_of_nonneg hsub (fun x _ _ => hF x)
  refine le_trans (le_of_eq ?_) h
  rw [Finset.sum_insert (by simp [ha, hb]), Finset.sum_insert (by simp [ha, Ne.symm hb]),
    Finset.sum_insert (by simp [hb])]
  simp
  ring

/-! ### The gap for real rank-one vectors -/

/-- **Core gap theorem.**  Let `u : A × B → ℝ` be `ℓ²`-normalised and let one of
its `2 × 2` minors vanish, at four points whose pattern in `R` is `1, 0 / ?, 1`.
Then `(∑_{x ∈ R} u x)² · (3|R| + 1) ≤ 3|R|²`.

Only one vanishing minor of `u` is used, so this applies verbatim to any
product vector `u = p ⊗ q`. -/
theorem gap_of_rankOne (R : Finset (A × B)) (u : A × B → ℝ) (hu0 : ∀ x, 0 ≤ u x)
    (hu1 : ∑ x : A × B, u x ^ 2 = 1)
    {a a' : A} {b b' : B}
    (hrank : u (a, b) * u (a', b') = u (a, b') * u (a', b))
    (hab : (a, b) ∈ R) (hab' : (a', b') ∈ R) (hout : (a, b') ∉ R) :
    (∑ x ∈ R, u x) ^ 2 * (3 * R.card + 1) ≤ 3 * (R.card : ℝ) ^ 2 := by
  have ha : a ≠ a' := by rintro rfl; exact hout hab'
  have hb : b ≠ b' := by rintro rfl; exact hout hab
  set m : ℝ := (R.card : ℝ) with hm
  have hm1 : 1 ≤ m := by
    have h : 1 ≤ R.card := Finset.card_pos.2 ⟨_, hab⟩
    simpa [hm] using (Nat.one_le_cast (α := ℝ)).2 h
  have hm0 : 0 < m := lt_of_lt_of_le zero_lt_one hm1
  set T : ℝ := ∑ x ∈ R, u x with hT
  set mu : ℝ := T / m with hmu
  set ind : A × B → ℝ := fun x => if x ∈ R then (1 : ℝ) else 0 with hind
  -- squared distance from `u` to the best multiple of the indicator of `R`
  have hD : ∑ x : A × B, (u x - mu * ind x) ^ 2 = 1 - 2 * mu * T + mu ^ 2 * m := by
    have h1 : ∀ x : A × B, (u x - mu * ind x) ^ 2
        = u x ^ 2 - 2 * mu * (if x ∈ R then u x else 0)
          + mu ^ 2 * (if x ∈ R then (1 : ℝ) else 0) := by
      intro x; by_cases hx : x ∈ R <;> simp [hind, hx]; ring
    rw [Finset.sum_congr rfl (fun x _ => h1 x)]
    rw [Finset.sum_add_distrib, Finset.sum_sub_distrib, ← Finset.mul_sum, ← Finset.mul_sum,
      Finset.sum_ite_mem, Finset.univ_inter, hu1]
    simp [hT, hm]
  have hDval : ∑ x : A × B, (u x - mu * ind x) ^ 2 = 1 - T ^ 2 / m := by
    rw [hD, hmu]; field_simp; ring
  have hfour := sum_four_le (fun x => (u x - mu * ind x) ^ 2) (fun x => sq_nonneg _) ha hb
  have hi1 : ind (a, b) = 1 := by simp [hind, hab]
  have hi2 : ind (a, b') = 0 := by simp [hind, hout]
  have hi4 : ind (a', b') = 1 := by simp [hind, hab']
  have hc1 : ind (a', b) ≤ 1 := by rw [hind]; dsimp only; split <;> norm_num
  have hT0 : 0 ≤ T := Finset.sum_nonneg fun x _ => hu0 x
  have hmu0 : 0 ≤ mu := div_nonneg hT0 (le_of_lt hm0)
  have hkey : mu ^ 2 ≤ 3 * ((u (a, b) - mu) ^ 2 + (u (a, b')) ^ 2
      + (u (a', b) - mu * ind (a', b)) ^ 2 + (u (a', b') - mu) ^ 2) :=
    rankOne_minor_ineq _ _ _ _ _ _ hmu0 (hu0 _) hc1 (by linear_combination hrank)
  have hS : (u (a, b) - mu) ^ 2 + (u (a, b')) ^ 2
      + (u (a', b) - mu * ind (a', b)) ^ 2 + (u (a', b') - mu) ^ 2 ≤ 1 - T ^ 2 / m := by
    rw [← hDval]
    calc (u (a, b) - mu) ^ 2 + (u (a, b')) ^ 2
          + (u (a', b) - mu * ind (a', b)) ^ 2 + (u (a', b') - mu) ^ 2
        = (u (a, b) - mu * ind (a, b)) ^ 2 + (u (a, b') - mu * ind (a, b')) ^ 2
          + (u (a', b) - mu * ind (a', b)) ^ 2 + (u (a', b') - mu * ind (a', b')) ^ 2 := by
          rw [hi1, hi2, hi4]; ring
      _ ≤ _ := hfour
  have hmu2 : mu ^ 2 = T ^ 2 / m ^ 2 := by rw [hmu]; ring
  have hlast : T ^ 2 / m ^ 2 ≤ 3 * (1 - T ^ 2 / m) := by rw [← hmu2]; linarith [hkey, hS]
  have hne : m ≠ 0 := ne_of_gt hm0
  have e1 : m ^ 2 * (T ^ 2 / m ^ 2) = T ^ 2 := by field_simp
  have e2 : m ^ 2 * (3 * (1 - T ^ 2 / m)) = 3 * m ^ 2 - 3 * m * T ^ 2 := by field_simp
  have h3 := mul_le_mul_of_nonneg_left hlast (sq_nonneg m)
  rw [e1, e2] at h3
  nlinarith [h3]

/-! ### From real rank-one vectors to complex product coins -/

omit [DecidableEq A] [DecidableEq B] in
/-- A product of two normalised modulus vectors is normalised on `A × B`. -/
theorem prod_norm_sq (p : A → ℝ) (q : B → ℝ) (hp1 : ∑ a, p a ^ 2 = 1)
    (hq1 : ∑ b, q b ^ 2 = 1) : ∑ x : A × B, (p x.1 * q x.2) ^ 2 = 1 := by
  have h : ∑ x : A × B, (p x.1 * q x.2) ^ 2 = (∑ a, p a ^ 2) * ∑ b, q b ^ 2 := by
    rw [Finset.sum_mul_sum, Fintype.sum_prod_type]
    exact Finset.sum_congr rfl fun a _ => Finset.sum_congr rfl fun b _ => by ring
  rw [h, hp1, hq1, mul_one]

omit [Fintype A] [Fintype B] [DecidableEq A] [DecidableEq B] in
/-- The complex amplitude is dominated by the amplitude of the modulus coin. -/
theorem norm_bipAmp_le (R : Finset (A × B)) (f : A → ℂ) (g : B → ℂ) :
    ‖bipAmp R f g‖ ≤ ∑ x ∈ R, ‖f x.1‖ * ‖g x.2‖ := by
  refine le_trans (norm_sum_le _ _) (le_of_eq ?_)
  exact Finset.sum_congr rfl fun x _ => norm_mul _ _

omit [DecidableEq A] [DecidableEq B] in
/-- **Cauchy–Schwarz bound.**  Every product coin obeys `‖A(ψ)‖² ≤ |R|`. -/
theorem bipAmp_sq_le_card (R : Finset (A × B)) (f : A → ℂ) (g : B → ℂ)
    (hf : IsCoin f) (hg : IsCoin g) : ‖bipAmp R f g‖ ^ 2 ≤ (R.card : ℝ) := by
  set p : A → ℝ := fun a => ‖f a‖
  set q : B → ℝ := fun b => ‖g b‖
  have hT : ‖bipAmp R f g‖ ≤ ∑ x ∈ R, p x.1 * q x.2 := norm_bipAmp_le R f g
  have hCS : (∑ x ∈ R, p x.1 * q x.2) ^ 2
      ≤ (R.card : ℝ) * ∑ x ∈ R, (p x.1 * q x.2) ^ 2 :=
    sq_sum_le_card_mul_sum_sq
  have hsub : ∑ x ∈ R, (p x.1 * q x.2) ^ 2 ≤ ∑ x : A × B, (p x.1 * q x.2) ^ 2 :=
    Finset.sum_le_sum_of_subset_of_nonneg (Finset.subset_univ _) fun x _ _ => sq_nonneg _
  have hone : ∑ x : A × B, (p x.1 * q x.2) ^ 2 = 1 := prod_norm_sq p q hf hg
  have hcard : (0 : ℝ) ≤ (R.card : ℝ) := Nat.cast_nonneg _
  have h1 : ‖bipAmp R f g‖ ^ 2 ≤ (∑ x ∈ R, p x.1 * q x.2) ^ 2 := by
    have h0 : (0 : ℝ) ≤ ‖bipAmp R f g‖ := norm_nonneg _
    nlinarith [hT, h0]
  nlinarith [hCS, hsub, hone, hcard, h1]

/-- **Main rigidity gap.**  If `R` is not a box — witnessed by `(a,b), (a',b') ∈ R`
with `(a,b') ∉ R` — then *every* product coin satisfies
`‖A(ψ)‖² · (3|R| + 1) ≤ 3|R|²`, i.e. `‖A(ψ)‖² ≤ (1 - 1/(3|R|+1))·|R|`. -/
theorem bipAmp_sq_gap (R : Finset (A × B)) (f : A → ℂ) (g : B → ℂ)
    (hf : IsCoin f) (hg : IsCoin g) {a a' : A} {b b' : B}
    (hab : (a, b) ∈ R) (hab' : (a', b') ∈ R) (hout : (a, b') ∉ R) :
    ‖bipAmp R f g‖ ^ 2 * (3 * R.card + 1) ≤ 3 * (R.card : ℝ) ^ 2 := by
  set u : A × B → ℝ := fun x => ‖f x.1‖ * ‖g x.2‖ with hu
  have hu0 : ∀ x, 0 ≤ u x := fun x => mul_nonneg (norm_nonneg _) (norm_nonneg _)
  have hu1 : ∑ x : A × B, u x ^ 2 = 1 := prod_norm_sq _ _ hf hg
  have hrank : u (a, b) * u (a', b') = u (a, b') * u (a', b) := by simp [hu]; ring
  have hgap := gap_of_rankOne R u hu0 hu1 hrank hab hab' hout
  have hT : ‖bipAmp R f g‖ ≤ ∑ x ∈ R, u x := norm_bipAmp_le R f g
  have h0 : (0 : ℝ) ≤ ‖bipAmp R f g‖ := norm_nonneg _
  have h1 : ‖bipAmp R f g‖ ^ 2 ≤ (∑ x ∈ R, u x) ^ 2 := by nlinarith [hT, h0]
  have hpos : (0 : ℝ) ≤ 3 * (R.card : ℝ) + 1 := by positivity
  nlinarith [hgap, h1, hpos]

/-- Additive form of the gap: for a non-box `R` the optimum `|R|` is missed by at
least `2/7`, uniformly in `|R|`, in the alphabet sizes and in the depth. -/
theorem bipAmp_sq_le_card_sub (R : Finset (A × B)) (f : A → ℂ) (g : B → ℂ)
    (hf : IsCoin f) (hg : IsCoin g) {a a' : A} {b b' : B}
    (hab : (a, b) ∈ R) (hab' : (a', b') ∈ R) (hout : (a, b') ∉ R) :
    ‖bipAmp R f g‖ ^ 2 ≤ (R.card : ℝ) - 2 / 7 := by
  have hgap := bipAmp_sq_gap R f g hf hg hab hab' hout
  have hne : (a, b) ≠ (a', b') := by
    rintro h
    rw [Prod.mk.injEq] at h
    exact hout (h.2 ▸ hab)
  have hcard2 : 2 ≤ R.card := Finset.one_lt_card.2 ⟨_, hab, _, hab', hne⟩
  have hm : (2 : ℝ) ≤ (R.card : ℝ) := by exact_mod_cast hcard2
  nlinarith [hgap, hm]

/-! ### Boxes attain the optimum -/

omit [Fintype A] [Fintype B] [DecidableEq A] [DecidableEq B] in
/-- The amplitude against a product set factors. -/
theorem bipAmp_product (A₀ : Finset A) (B₀ : Finset B) (f : A → ℂ) (g : B → ℂ) :
    bipAmp (A₀ ×ˢ B₀) f g = (∑ a ∈ A₀, f a) * ∑ b ∈ B₀, g b := by
  unfold bipAmp
  rw [Finset.sum_product, Finset.sum_mul_sum]

/-- The uniform coin supported on a nonempty finite set is a coin. -/
theorem uniform_isCoin (A₀ : Finset A) (h : A₀.Nonempty) :
    IsCoin (fun a => if a ∈ A₀ then ((Real.sqrt A₀.card : ℝ) : ℂ)⁻¹ else 0) := by
  have hc : (0 : ℝ) < (A₀.card : ℝ) := by exact_mod_cast Finset.card_pos.2 h
  have hs : Real.sqrt A₀.card ≠ 0 := ne_of_gt (Real.sqrt_pos.2 hc)
  show ∑ a, _ = _
  have key : ∀ a : A, ‖(if a ∈ A₀ then ((Real.sqrt A₀.card : ℝ) : ℂ)⁻¹ else 0)‖ ^ 2
      = if a ∈ A₀ then ((A₀.card : ℝ))⁻¹ else 0 := by
    intro a
    by_cases h' : a ∈ A₀
    · simp [h', Real.sq_sqrt hc.le]
    · simp [h']
  rw [Finset.sum_congr rfl fun a _ => key a, Finset.sum_ite_mem, Finset.univ_inter,
    Finset.sum_const, nsmul_eq_mul]
  field_simp

omit [Fintype A] in
/-- Total amplitude of the uniform coin over its support. -/
theorem uniform_sum (A₀ : Finset A) (h : A₀.Nonempty) :
    (∑ a ∈ A₀, if a ∈ A₀ then ((Real.sqrt A₀.card : ℝ) : ℂ)⁻¹ else 0)
      = ((Real.sqrt A₀.card : ℝ) : ℂ) := by
  have hc : (0 : ℝ) < (A₀.card : ℝ) := by exact_mod_cast Finset.card_pos.2 h
  have hs : Real.sqrt A₀.card ≠ 0 := ne_of_gt (Real.sqrt_pos.2 hc)
  rw [Finset.sum_congr rfl fun a ha => (if_pos ha), Finset.sum_const, nsmul_eq_mul]
  have hsq : ((A₀.card : ℂ)) = ((Real.sqrt A₀.card : ℝ) : ℂ) * ((Real.sqrt A₀.card : ℝ) : ℂ) := by
    rw [← Complex.ofReal_mul, Real.mul_self_sqrt hc.le]
    simp
  rw [hsq]
  field_simp

omit [Fintype A] [Fintype B] in
/-- A nonempty box is exactly the product of its two projections. -/
theorem isBox_eq_product {R : Finset (A × B)} (hR : IsBox R) :
    R = (R.image Prod.fst) ×ˢ (R.image Prod.snd) := by
  ext x
  constructor
  · intro hx
    simp only [Finset.mem_product, Finset.mem_image]
    exact ⟨⟨x, hx, rfl⟩, ⟨x, hx, rfl⟩⟩
  · intro hx
    simp only [Finset.mem_product, Finset.mem_image] at hx
    obtain ⟨⟨y, hy, hy1⟩, ⟨z, hz, hz2⟩⟩ := hx
    have h := hR y hy z hz
    rwa [hy1, hz2] at h

/-- **Boxes attain the Cauchy–Schwarz optimum.**  For a nonempty box `R` there is
a product coin with `‖A(ψ)‖² = |R|`. -/
theorem isBox_attains {R : Finset (A × B)} (hR : IsBox R) (hne : R.Nonempty) :
    ∃ f : A → ℂ, ∃ g : B → ℂ, IsCoin f ∧ IsCoin g ∧ ‖bipAmp R f g‖ ^ 2 = (R.card : ℝ) := by
  classical
  set A₀ := R.image Prod.fst with hA₀
  set B₀ := R.image Prod.snd with hB₀
  have hprod : R = A₀ ×ˢ B₀ := isBox_eq_product hR
  have hA₀ne : A₀.Nonempty := hne.image _
  have hB₀ne : B₀.Nonempty := hne.image _
  have hcA : (0 : ℝ) < (A₀.card : ℝ) := by exact_mod_cast Finset.card_pos.2 hA₀ne
  have hcB : (0 : ℝ) < (B₀.card : ℝ) := by exact_mod_cast Finset.card_pos.2 hB₀ne
  refine ⟨fun a => if a ∈ A₀ then ((Real.sqrt A₀.card : ℝ) : ℂ)⁻¹ else 0,
          fun b => if b ∈ B₀ then ((Real.sqrt B₀.card : ℝ) : ℂ)⁻¹ else 0,
          uniform_isCoin A₀ hA₀ne, uniform_isCoin B₀ hB₀ne, ?_⟩
  rw [hprod, bipAmp_product, uniform_sum A₀ hA₀ne, uniform_sum B₀ hB₀ne]
  rw [norm_mul, mul_pow]
  rw [Complex.norm_real, Complex.norm_real, Real.norm_eq_abs, Real.norm_eq_abs,
    abs_of_nonneg (Real.sqrt_nonneg _), abs_of_nonneg (Real.sqrt_nonneg _),
    Real.sq_sqrt hcA.le, Real.sq_sqrt hcB.le, Finset.card_product]
  push_cast
  ring

/-! ### The dichotomy -/

/-- **Rigidity dichotomy.**  For a nonempty resonance set `R`, the
Cauchy–Schwarz optimum `‖A(ψ)‖² = |R|` is attained by some *product* coin if and
only if `R` is a combinatorial box.  Equivalently: the indicator of `R` belongs
to the (projectivised) product family iff `R` is a product set. -/
theorem resonanceAmplitude_sq_eq_iff {R : Finset (A × B)} (hne : R.Nonempty) :
    (∃ f : A → ℂ, ∃ g : B → ℂ, IsCoin f ∧ IsCoin g ∧ ‖bipAmp R f g‖ ^ 2 = (R.card : ℝ))
      ↔ IsBox R := by
  refine ⟨fun ⟨f, g, hf, hg, heq⟩ => ?_, fun hR => isBox_attains hR hne⟩
  by_contra hbox
  unfold IsBox at hbox
  push_neg at hbox
  obtain ⟨x, hx, y, hy, hxy⟩ := hbox
  have hgap := bipAmp_sq_gap R f g hf hg (a := x.1) (b := x.2) (a' := y.1) (b' := y.2)
    (by simpa using hx) (by simpa using hy) hxy
  rw [heq] at hgap
  have hm1 : (1 : ℝ) ≤ (R.card : ℝ) := by
    have h : 1 ≤ R.card := Finset.card_pos.2 hne
    exact_mod_cast h
  nlinarith [hgap, hm1]

end ShallowProductCoin