/-
# Quadratic character sums, conic counts, and the exact vertical second moment

This file completes the elementary toolkit for the family `y^2 = x^3 + a*x + b` over a
finite field `F` of characteristic `≠ 2, 3` by evaluating **every** quadratic character
sum of a quadratic polynomial, counting the points of the conic `x^2+x*y+y^2 = c`, and
deducing the **exact vertical second moment**

`∑_{b ∈ F} a(a,b)^2 = q^2 - q * (1 + χ(-3) + χ(-3a))`  for `a ≠ 0`,
`∑_{b ∈ F} a(0,b)^2 = q * (q-1) * (1 + χ(-3))`.

The second formula gives a second, independent proof that the family `y^2 = x^3 + b` is
supersingular exactly when `χ(-3) = -1`, i.e. when `q ≡ 2 (mod 3)`.

Main results:

* `EllipticModCount.sum_char_quadratic` : `∑_v χ(αv^2+βv+γ) = -χ(α)` unless the
  discriminant vanishes, in which case it is `(q-1)χ(α)`.
* `EllipticModCount.sum_conic` : the number of points of `x^2+xy+y^2 = c`.
* `EllipticModCount.collisions_eq` / `collisions_zero` : exact collision counts.
* `EllipticModCount.vertical_second_moment` / `vertical_second_moment_zero`.
* `EllipticModCount.vertical_second_moment_zero_eq_zero_iff` : supersingularity of the
  family `y^2 = x^3 + b` is *equivalent* to `χ(-3) = -1`.
-/
import Mathlib
import Combinatorics.EllipticPointCount
import Combinatorics.EllipticSecondMoment

namespace EllipticModCount

open Finset

variable {F : Type*} [Field F] [Fintype F] [DecidableEq F]

section QuadraticSums

/-- Multiplying by a nonzero square does not change the quadratic character. -/
theorem char_mul_sq {d : F} (hd : d ≠ 0) (c : F) :
    quadraticChar F (c * d ^ 2) = quadraticChar F c := by
  rw [map_mul, quadraticChar_sq_one' hd, mul_one]

/-- **Counting the roots of a quadratic.** -/
theorem sum_ite_quadratic_root (hF : ringChar F ≠ 2) (β γ : F) :
    ∑ y : F, (if y ^ 2 + β * y + γ = 0 then (1 : ℤ) else 0)
      = quadraticChar F (β ^ 2 - 4 * γ) + 1 := by
  have h2 : (2 : F) ≠ 0 := Ring.two_ne_zero hF
  have hbij : Function.Bijective fun z : F => z - β / 2 := by
    constructor
    · intro z₁ z₂ h
      simpa using h
    · intro y
      exact ⟨y + β / 2, by ring⟩
  have hcond : ∀ z : F,
      ((z - β / 2) ^ 2 + β * (z - β / 2) + γ = 0) ↔ (z ^ 2 = (β ^ 2 - 4 * γ) * (2⁻¹) ^ 2) := by
    intro z
    constructor
    · intro h
      field_simp
      field_simp at h
      linear_combination h
    · intro h
      field_simp at h ⊢
      linear_combination h
  have hre : ∑ z : F, (if (z - β / 2) ^ 2 + β * (z - β / 2) + γ = 0 then (1 : ℤ) else 0)
      = ∑ y : F, (if y ^ 2 + β * y + γ = 0 then (1 : ℤ) else 0) :=
    Fintype.sum_bijective _ hbij _ _ fun _ => rfl
  rw [← hre, Finset.sum_congr rfl fun z _ => if_congr (hcond z) rfl rfl,
    sum_ite_sq hF, char_mul_sq (by simpa using h2)]

/-- The hyperbola count `#{(u,t) : t^2 = u^2 - D}`. -/
theorem sum_hyperbola (hF : ringChar F ≠ 2) (D : F) :
    ∑ u : F, ∑ t : F, (if t ^ 2 = u ^ 2 - D then (1 : ℤ) else 0)
      = if D = 0 then 2 * (Fintype.card F : ℤ) - 1 else (Fintype.card F : ℤ) - 1 := by
  have h2 : (2 : F) ≠ 0 := Ring.two_ne_zero hF
  have hconv : (∑ u : F, ∑ t : F, (if t ^ 2 = u ^ 2 - D then (1 : ℤ) else 0))
      = ∑ ut : F × F, (if ut.2 ^ 2 = ut.1 ^ 2 - D then (1 : ℤ) else 0) :=
    (Fintype.sum_prod_type' (fun u t : F => if t ^ 2 = u ^ 2 - D then (1 : ℤ) else 0)).symm
  have hbij : Function.Bijective
      (fun sr : F × F => (((sr.1 + sr.2) / 2, (sr.2 - sr.1) / 2) : F × F)) := by
    refine Function.bijective_iff_has_inverse.mpr
      ⟨fun ut : F × F => ((ut.1 - ut.2, ut.1 + ut.2) : F × F), ?_, ?_⟩
    · rintro ⟨s, r⟩
      simp only [Prod.mk.injEq]
      constructor <;> field_simp <;> ring
    · rintro ⟨u, t⟩
      simp only [Prod.mk.injEq]
      constructor <;> field_simp <;> ring
  have hstep : ∀ sr : F × F,
      (if ((sr.2 - sr.1) / 2) ^ 2 = ((sr.1 + sr.2) / 2) ^ 2 - D then (1 : ℤ) else 0)
        = (if sr.1 * sr.2 = D then (1 : ℤ) else 0) := by
    rintro ⟨s, r⟩
    refine if_congr ?_ rfl rfl
    have hid : ((s + r) / 2) ^ 2 - ((r - s) / 2) ^ 2 = s * r := by
      field_simp
      ring
    constructor
    · intro h
      linear_combination -hid - h
    · intro h
      linear_combination -hid - h
  have hre : ∑ sr : F × F, (if sr.1 * sr.2 = D then (1 : ℤ) else 0)
      = ∑ ut : F × F, (if ut.2 ^ 2 = ut.1 ^ 2 - D then (1 : ℤ) else 0) := by
    rw [← Fintype.sum_bijective _ hbij
      (fun sr : F × F => if ((sr.2 - sr.1) / 2) ^ 2 = ((sr.1 + sr.2) / 2) ^ 2 - D then (1 : ℤ)
        else 0)
      (fun ut : F × F => if ut.2 ^ 2 = ut.1 ^ 2 - D then (1 : ℤ) else 0) (fun _ => rfl)]
    exact Finset.sum_congr rfl fun sr _ => (hstep sr).symm
  rw [hconv, ← hre, Fintype.sum_prod_type]
  have hinner : ∀ s : F, ∑ r : F, (if s * r = D then (1 : ℤ) else 0)
      = if s = 0 then (if D = 0 then (Fintype.card F : ℤ) else 0) else 1 := by
    intro s
    by_cases hs : s = 0
    · subst hs
      rw [if_pos rfl]
      by_cases hD : D = 0
      · subst hD
        simp [Finset.card_univ]
      · simp [hD, Ne.symm hD]
    · rw [if_neg hs]
      have hiff : ∀ r : F, (s * r = D) ↔ (r = s⁻¹ * D) := by
        intro r
        constructor
        · intro h
          field_simp
          linear_combination h
        · intro h
          rw [h]
          field_simp
      rw [Finset.sum_congr rfl fun r _ => if_congr (hiff r) rfl rfl]
      simp
  have hfin : ∀ X : ℤ, (∑ _s : F, (0 : ℤ)) = 0 → (∑ s : F, (if s = 0 then X else (1 : ℤ)))
      = X + ((Fintype.card F : ℤ) - 1) := by
    intro X _
    have hsplit : ∀ s : F, (if s = 0 then X else (1 : ℤ))
        = 1 + (if s = 0 then X - 1 else 0) := by
      intro s
      by_cases h : s = 0 <;> simp [h]
    rw [Finset.sum_congr rfl fun s _ => hsplit s, Finset.sum_add_distrib, Finset.sum_const,
      Finset.card_univ, nsmul_eq_mul, mul_one,
      Finset.sum_ite_eq' univ (0 : F) (fun _ : F => X - 1)]
    simp
    ring
  rw [Finset.sum_congr rfl fun s _ => hinner s, hfin _ (by simp)]
  by_cases hD : D = 0
  · rw [if_pos hD, if_pos hD]
    ring
  · rw [if_neg hD, if_neg hD]
    ring

/-- **Evaluation of the character sum of a quadratic polynomial.** -/
theorem sum_char_sq_sub (hF : ringChar F ≠ 2) (D : F) :
    ∑ u : F, quadraticChar F (u ^ 2 - D)
      = if D = 0 then (Fintype.card F : ℤ) - 1 else -1 := by
  have hkey : ∀ u : F, quadraticChar F (u ^ 2 - D)
      = (∑ t : F, (if t ^ 2 = u ^ 2 - D then (1 : ℤ) else 0)) - 1 := by
    intro u
    rw [sum_ite_sq hF]
    ring
  rw [Finset.sum_congr rfl fun u _ => hkey u, Finset.sum_sub_distrib, sum_hyperbola hF,
    Finset.sum_const, Finset.card_univ, nsmul_eq_mul, mul_one]
  by_cases hD : D = 0
  · rw [if_pos hD, if_pos hD]
    ring
  · rw [if_neg hD, if_neg hD]
    ring

/-- **The complete quadratic character sum of a quadratic polynomial.** -/
theorem sum_char_quadratic (hF : ringChar F ≠ 2) {α : F} (hα : α ≠ 0) (β γ : F) :
    ∑ v : F, quadraticChar F (α * v ^ 2 + β * v + γ)
      = if β ^ 2 - 4 * α * γ = 0 then ((Fintype.card F : ℤ) - 1) * quadraticChar F α
        else -quadraticChar F α := by
  have h2 : (2 : F) ≠ 0 := Ring.two_ne_zero hF
  have h4 : (4 : F) ≠ 0 := by
    have he : (4 : F) = 2 * 2 := by norm_num
    rw [he]
    exact mul_ne_zero h2 h2
  set D : F := β ^ 2 / 4 - α * γ with hD
  have hchi : ∀ v : F, quadraticChar F (α * v ^ 2 + β * v + γ)
      = quadraticChar F α * quadraticChar F ((α * v + β / 2) ^ 2 - D) := by
    intro v
    have hid : (α * v + β / 2) ^ 2 - D = α * (α * v ^ 2 + β * v + γ) := by
      rw [hD]
      field_simp
      ring
    rw [hid, map_mul, ← mul_assoc, ← sq, quadraticChar_sq_one hα, one_mul]
  have hbij : Function.Bijective fun v : F => α * v + β / 2 := by
    constructor
    · intro v₁ v₂ h
      simp only at h
      have hv : α * v₁ = α * v₂ := by linear_combination h
      exact mul_left_cancel₀ hα hv
    · intro u
      refine ⟨(u - β / 2) / α, ?_⟩
      field_simp
      ring
  have hre : ∑ v : F, quadraticChar F ((α * v + β / 2) ^ 2 - D)
      = ∑ u : F, quadraticChar F (u ^ 2 - D) :=
    Fintype.sum_bijective _ hbij _ _ fun _ => rfl
  rw [Finset.sum_congr rfl fun v _ => hchi v, ← Finset.mul_sum, hre, sum_char_sq_sub hF]
  have hDiff : (D = 0) ↔ (β ^ 2 - 4 * α * γ = 0) := by
    rw [hD]
    constructor
    · intro h
      field_simp at h
      linear_combination h
    · intro h
      field_simp
      linear_combination h
  by_cases hc : β ^ 2 - 4 * α * γ = 0
  · rw [if_pos hc, if_pos (hDiff.mpr hc)]
    ring
  · rw [if_neg hc, if_neg (fun hx => hc (hDiff.mp hx))]
    ring

end QuadraticSums

section Conic

/-- **The conic count.** The number of points of `x^2+x*y+y^2 = c` over `F`
(characteristic `≠ 2, 3`). -/
theorem sum_conic (hF : ringChar F ≠ 2) (h3 : (3 : F) ≠ 0) (c : F) :
    ∑ x : F, ∑ y : F, (if x ^ 2 + x * y + y ^ 2 = c then (1 : ℤ) else 0)
      = (Fintype.card F : ℤ)
        + (if c = 0 then ((Fintype.card F : ℤ) - 1) * quadraticChar F (-3)
           else -quadraticChar F (-3)) := by
  have h2 : (2 : F) ≠ 0 := Ring.two_ne_zero hF
  have h4 : (4 : F) ≠ 0 := by
    have he : (4 : F) = 2 * 2 := by norm_num
    rw [he]
    exact mul_ne_zero h2 h2
  have hn3 : (-3 : F) ≠ 0 := neg_ne_zero.mpr h3
  have hinner : ∀ x : F, ∑ y : F, (if x ^ 2 + x * y + y ^ 2 = c then (1 : ℤ) else 0)
      = quadraticChar F (-3 * x ^ 2 + 0 * x + 4 * c) + 1 := by
    intro x
    have hcond : ∀ y : F, (x ^ 2 + x * y + y ^ 2 = c) ↔ (y ^ 2 + x * y + (x ^ 2 - c) = 0) := by
      intro y
      constructor
      · intro h
        linear_combination h
      · intro h
        linear_combination h
    rw [Finset.sum_congr rfl fun y _ => if_congr (hcond y) rfl rfl,
      sum_ite_quadratic_root hF x (x ^ 2 - c)]
    congr 2
    ring
  rw [Finset.sum_congr rfl fun x _ => hinner x, Finset.sum_add_distrib, Finset.sum_const,
    Finset.card_univ, nsmul_eq_mul, mul_one, sum_char_quadratic hF hn3 0 (4 * c)]
  have hdisc : ((0 : F) ^ 2 - 4 * (-3) * (4 * c) = 0) ↔ (c = 0) := by
    constructor
    · intro h
      have h48 : (48 : F) * c = 0 := by linear_combination h
      rcases mul_eq_zero.mp h48 with h' | h'
      · exfalso
        apply h3
        have h16 : (48 : F) = 16 * 3 := by norm_num
        rw [h16] at h'
        rcases mul_eq_zero.mp h' with h'' | h''
        · exfalso
          apply h4
          have : (16 : F) = 4 * 4 := by norm_num
          rw [this] at h''
          rcases mul_eq_zero.mp h'' with h3' | h3' <;> exact h3'
        · exact h''
      · exact h'
    · intro h
      rw [h]
      ring
  by_cases hc : c = 0
  · rw [if_pos hc, if_pos (hdisc.mpr hc)]
    ring
  · rw [if_neg hc, if_neg (fun hx => hc (hdisc.mp hx))]
    ring

end Conic

section Collisions

/-- The collision count as a double sum of indicators. -/
theorem collisions_eq_sum (a : F) :
    (collisions a : ℤ)
      = ∑ x : F, ∑ y : F, (if x ^ 3 + a * x = y ^ 3 + a * y then (1 : ℤ) else 0) := by
  rw [collisions, Finset.card_filter]
  push_cast
  exact Fintype.sum_prod_type'
    (fun x y : F => if x ^ 3 + a * x = y ^ 3 + a * y then (1 : ℤ) else 0)

/-- **Exact collision count.** `#{(x,y) : x^3+ax = y^3+ay} = 2q - 1 - χ(-3) - χ(-a/3)`
for `a ≠ 0`, and `2q - 1 + (q-1)χ(-3)` for `a = 0`. -/
theorem collisions_formula (hF : ringChar F ≠ 2) (h3 : (3 : F) ≠ 0) (a : F) :
    (collisions a : ℤ) = (Fintype.card F : ℤ)
      + ((Fintype.card F : ℤ)
        + (if -a = 0 then ((Fintype.card F : ℤ) - 1) * quadraticChar F (-3)
           else -quadraticChar F (-3)))
      - (quadraticChar F (-a / 3) + 1) := by
  have hsplit : ∀ x y : F, (if x ^ 3 + a * x = y ^ 3 + a * y then (1 : ℤ) else 0)
      = (if x = y then (1 : ℤ) else 0) + (if x ^ 2 + x * y + y ^ 2 = -a then (1 : ℤ) else 0)
        - (if x = y then (if x ^ 2 + x * y + y ^ 2 = -a then (1 : ℤ) else 0) else 0) := by
    intro x y
    by_cases hxy : x = y
    · subst hxy
      rw [if_pos rfl, if_pos rfl, if_pos rfl]
      ring
    · rw [if_neg hxy, if_neg hxy]
      have hiff : (x ^ 3 + a * x = y ^ 3 + a * y) ↔ (x ^ 2 + x * y + y ^ 2 = -a) := by
        constructor
        · intro h
          have hfac : (x - y) * (x ^ 2 + x * y + y ^ 2 + a) = 0 := by linear_combination h
          rcases mul_eq_zero.mp hfac with h' | h'
          · exact absurd (by linear_combination h' : x = y) hxy
          · linear_combination h'
        · intro h
          linear_combination (x - y) * h
      rw [if_congr hiff rfl rfl]
      ring
  rw [collisions_eq_sum a]
  rw [Finset.sum_congr rfl fun x _ => Finset.sum_congr rfl fun y _ => hsplit x y]
  have hexp : ∀ x : F, ∑ y : F,
      ((if x = y then (1 : ℤ) else 0) + (if x ^ 2 + x * y + y ^ 2 = -a then (1 : ℤ) else 0)
        - (if x = y then (if x ^ 2 + x * y + y ^ 2 = -a then (1 : ℤ) else 0) else 0))
      = 1 + (∑ y : F, (if x ^ 2 + x * y + y ^ 2 = -a then (1 : ℤ) else 0))
        - (if x ^ 2 + x * x + x ^ 2 = -a then (1 : ℤ) else 0) := by
    intro x
    rw [Finset.sum_sub_distrib, Finset.sum_add_distrib,
      Finset.sum_ite_eq univ x (fun _ : F => (1 : ℤ)),
      Finset.sum_ite_eq univ x (fun y : F => if x ^ 2 + x * y + y ^ 2 = -a then (1 : ℤ) else 0)]
    simp only [mem_univ, if_true]
  rw [Finset.sum_congr rfl fun x _ => hexp x, Finset.sum_sub_distrib, Finset.sum_add_distrib,
    Finset.sum_const, Finset.card_univ, nsmul_eq_mul, mul_one, sum_conic hF h3 (-a)]
  have hlast : ∑ x : F, (if x ^ 2 + x * x + x ^ 2 = -a then (1 : ℤ) else 0)
      = quadraticChar F (-a / 3) + 1 := by
    have hc : ∀ x : F, (x ^ 2 + x * x + x ^ 2 = -a) ↔ (x ^ 2 = -a / 3) := by
      intro x
      constructor
      · intro h
        field_simp
        linear_combination h
      · intro h
        field_simp at h
        linear_combination h
    rw [Finset.sum_congr rfl fun x _ => if_congr (hc x) rfl rfl, sum_ite_sq hF]
  rw [hlast]

/-- The collision count for `a = 0`. -/
theorem collisions_zero (hF : ringChar F ≠ 2) (h3 : (3 : F) ≠ 0) :
    (collisions (0 : F) : ℤ)
      = 2 * (Fintype.card F : ℤ) - 1 + ((Fintype.card F : ℤ) - 1) * quadraticChar F (-3) := by
  rw [collisions_formula hF h3 0]
  simp only [neg_zero, zero_div, quadraticChar_zero, if_true]
  ring

/-- The collision count for `a ≠ 0`. -/
theorem collisions_ne_zero (hF : ringChar F ≠ 2) (h3 : (3 : F) ≠ 0) {a : F} (ha : a ≠ 0) :
    (collisions a : ℤ)
      = 2 * (Fintype.card F : ℤ) - 1 - quadraticChar F (-3) - quadraticChar F (-a / 3) := by
  rw [collisions_formula hF h3 a, if_neg (neg_ne_zero.mpr ha)]
  ring

end Collisions

section VerticalMoment

/-- **Exact vertical second moment at `a = 0`.** -/
theorem vertical_second_moment_zero (hF : ringChar F ≠ 2) (h3 : (3 : F) ≠ 0) :
    ∑ b : F, (frobTrace (0 : F) b) ^ 2
      = (Fintype.card F : ℤ) * ((Fintype.card F : ℤ) - 1) * (1 + quadraticChar F (-3)) := by
  have hconv : ∀ b : F, (frobTrace (0 : F) b) ^ 2 = (charSum (0 : F) b) ^ 2 := by
    intro b
    rw [frobTrace_eq_neg_charSum hF]
    ring
  rw [Finset.sum_congr rfl fun b _ => hconv b, sum_b_charSum_sq hF, collisions_zero hF h3]
  ring

/-- **Exact vertical second moment for `a ≠ 0`.** -/
theorem vertical_second_moment (hF : ringChar F ≠ 2) (h3 : (3 : F) ≠ 0) {a : F} (ha : a ≠ 0) :
    ∑ b : F, (frobTrace a b) ^ 2
      = (Fintype.card F : ℤ) ^ 2
        - (Fintype.card F : ℤ) * (1 + quadraticChar F (-3) + quadraticChar F (-a / 3)) := by
  have hconv : ∀ b : F, (frobTrace a b) ^ 2 = (charSum a b) ^ 2 := by
    intro b
    rw [frobTrace_eq_neg_charSum hF]
    ring
  rw [Finset.sum_congr rfl fun b _ => hconv b, sum_b_charSum_sq hF, collisions_ne_zero hF h3 ha]
  ring

/-- The diagonal of `F × F`. -/
private def diag (F : Type*) [Fintype F] [DecidableEq F] : Finset (F × F) :=
  univ.image fun x : F => ((x, x) : F × F)

omit [Field F] in
private lemma card_diag : (diag F).card = Fintype.card F := by
  rw [diag, Finset.card_image_of_injective _ (fun x y h => by simpa using congrArg Prod.fst h),
    Finset.card_univ]

private lemma diag_subset (a : F) :
    diag F ⊆ univ.filter fun xy : F × F => xy.1 ^ 3 + a * xy.1 = xy.2 ^ 3 + a * xy.2 := by
  intro z hz
  simp only [diag, Finset.mem_image, mem_univ, true_and] at hz
  obtain ⟨x, hx⟩ := hz
  subst hx
  simp

/-- **A cubic/quadratic bridge.** Cubing is a bijection of `F` exactly when `-3` is a
nonsquare.  (Equivalently: `F` contains a primitive cube root of unity iff `-3` is a square.)
This is derived here purely from the collision count of the family `y^2 = x^3 + b`. -/
theorem cube_bijective_iff_char_neg_three (hF : ringChar F ≠ 2) (h3 : (3 : F) ≠ 0) :
    (Function.Bijective fun x : F => x ^ 3) ↔ quadraticChar F (-3) = -1 := by
  have hq : 1 < Fintype.card F := Fintype.one_lt_card
  have hqZ : (1 : ℤ) < (Fintype.card F : ℤ) := by exact_mod_cast hq
  set S : Finset (F × F) :=
    univ.filter fun xy : F × F => xy.1 ^ 3 + (0 : F) * xy.1 = xy.2 ^ 3 + (0 : F) * xy.2 with hSdef
  have hSD : (S = diag F) ↔ Function.Injective fun x : F => x ^ 3 := by
    constructor
    · intro h x y hxy
      have hmem : ((x, y) : F × F) ∈ S := by
        simp only [hSdef, Finset.mem_filter, mem_univ, true_and]
        simpa using hxy
      rw [h] at hmem
      simp only [diag, Finset.mem_image, mem_univ, true_and] at hmem
      obtain ⟨z, hz⟩ := hmem
      have h1 : z = x := congrArg Prod.fst hz
      have h2 : z = y := congrArg Prod.snd hz
      rw [← h1, ← h2]
    · intro hinj
      refine Finset.Subset.antisymm ?_ (diag_subset 0)
      intro z hz
      simp only [hSdef, Finset.mem_filter, mem_univ, true_and] at hz
      have hz' : z.1 = z.2 := by
        apply hinj
        simpa using hz
      simp only [diag, Finset.mem_image, mem_univ, true_and]
      exact ⟨z.1, by simp [Prod.ext_iff, hz']⟩
  have hcoll : (collisions (0 : F) : ℤ)
      = 2 * (Fintype.card F : ℤ) - 1 + ((Fintype.card F : ℤ) - 1) * quadraticChar F (-3) :=
    collisions_zero hF h3
  constructor
  · intro hbij
    have hSeq : S = diag F := hSD.mpr hbij.injective
    have hc : collisions (0 : F) = Fintype.card F := by
      rw [collisions, ← hSdef, hSeq, card_diag]
    rw [hc] at hcoll
    have : ((Fintype.card F : ℤ) - 1) * (quadraticChar F (-3) + 1) = 0 := by linarith
    rcases mul_eq_zero.mp this with h' | h'
    · exact absurd h' (by linarith)
    · linarith
  · intro hchi
    rw [hchi] at hcoll
    have hc : (collisions (0 : F) : ℤ) = (Fintype.card F : ℤ) := by rw [hcoll]; ring
    have hcard : S.card = (diag F).card := by
      rw [card_diag, ← collisions, ← hSdef] at *
      exact_mod_cast hc
    have hSeq : S = diag F := (Finset.eq_of_subset_of_card_le (diag_subset 0) (le_of_eq hcard)).symm
    exact Finite.injective_iff_bijective.mp (hSD.mp hSeq)

/-- **Supersingularity of the family `y^2 = x^3 + b` is exactly the condition `χ(-3) = -1`.** -/
theorem vertical_second_moment_zero_eq_zero_iff (hF : ringChar F ≠ 2) (h3 : (3 : F) ≠ 0) :
    (∑ b : F, (frobTrace (0 : F) b) ^ 2 = 0) ↔ quadraticChar F (-3) = -1 := by
  have hq : 1 < Fintype.card F := Fintype.one_lt_card
  have hqZ : (1 : ℤ) < (Fintype.card F : ℤ) := by exact_mod_cast hq
  rw [vertical_second_moment_zero hF h3]
  constructor
  · intro h
    rcases mul_eq_zero.mp h with h' | h'
    · rcases mul_eq_zero.mp h' with h'' | h'' <;> linarith
    · linarith
  · intro h
    rw [h]
    ring

end VerticalMoment

end EllipticModCount