module

public import Mathlib
public import Pythagorean.UniversalS3FourthTypeChannel

/-!
# UNIVERSAL-S3-FOURTH (paper 115): what `I(p mod 3 ; T) = 1.0000` actually means

A two-variable Shannon calculus for uniform samples on a finite set, applied to the type channel
of `UniversalS3FourthTypeChannel`.  (The catalog's `Degree12CompositeEntropy` has only the
input/output form `I(X ; φ X)`, and it is not a `module` file, so it cannot be imported here.
The two-function form below is the one needed for `I(p mod 3 ; T)`.)

* `ent`, `mutInfo` — entropy in bits and `I(f ; g) = H(f) + H(g) - H(f, g)` for the uniform
  distribution on a finite sample `S`.
* `ent_congr`, `ent_comp_injective` — entropy depends only on values on `S`, and does not
  change under injective relabelling.
* `mutInfo_eq_ent_of_factor` — **pinning theorem**: if `f` factors through `g` on `S`, then
  `I(f ; g) = H(f)` exactly.
* `ent_two_balanced` — a balanced two-valued variable has entropy exactly `1` bit.
* `typeChannel_mutInfo` — **the sample law**: on *every* finite sample of primes `p ∤ 3c`, and
  for *every* `c`, `I(p mod 3 ; T) = H(p mod 3)`.  The normalised information `I/H` is
  exactly `1`.  The value `1.0000` itself is `H(p mod 3)` rounded; it is exactly `1` only on
  balanced samples.
* `seven_balanced_sample` — on the balanced sample `{5, 11, 13, 19}` the fourth field `x³ - 7`
  gives `I = 1` exactly.
* `s3_mutInfo_sign_fix` — **the Chebotarev model**: for `σ` uniform in `S₃`,
  `I(sign σ ; #Fix σ) = 1` bit exactly.  This is the group-theoretic source of the law, since
  `p mod 3` is the Frobenius sign on `ℚ(√-3)` and the root count is `#Fix(Frob_p)`.
* `s3_ent_fix`, `s3_type_gap` — `H(T) = 2/3 + (log₂ 3)/2 ≈ 1.459` and the gap
  `H(T) - I = (log₂ 3)/2 - 1/3 > 0`: the type is a strict refinement of `p mod 3`.

-- !-- Lab Notes -- !--
Primes `p < 1000`, `p ∤ 3c` (`ComputationalEvidence.md`):
  `c = 7`: `H(p mod 3) = 0.99832`, `H(T) = 1.42687`, `I = 0.99832` (so `I/H = 1`).
  `c = 2`: `0.99906 / 1.42378 / 0.99906`; `c = 3`: `0.99873 / 1.43453 / 0.99873`;
  `c = 5`: `0.99906 / 1.42378 / 0.99906`.
  In each case `I = H(p mod 3)` to all printed digits, as `typeChannel_mutInfo` predicts;
  `I` is *not* exactly `1` on these samples.
-/

@[expose] public section

namespace UniversalS3Fourth

open Finset

/-- The Shannon term `-x log₂ x`. -/
noncomputable def nlog2 (x : ℝ) : ℝ := -x * Real.logb 2 x

lemma nlog2_inv (x : ℝ) : nlog2 x⁻¹ = x⁻¹ * Real.logb 2 x := by
  rw [nlog2, Real.logb_inv]; ring

variable {α β γ δ : Type*} [DecidableEq β] [DecidableEq γ] [DecidableEq δ]

/-- Probability that `f = b` under the uniform distribution on `S`. -/
noncomputable def pmf (S : Finset α) (f : α → β) (b : β) : ℝ :=
  ((S.filter (fun a => f a = b)).card : ℝ) / S.card

/-- Shannon entropy (bits) of `f` under the uniform distribution on `S`. -/
noncomputable def ent (S : Finset α) (f : α → β) : ℝ :=
  ∑ b ∈ S.image f, nlog2 (pmf S f b)

/-- Mutual information `I(f ; g) = H(f) + H(g) - H(f, g)` on the uniform sample `S`. -/
noncomputable def mutInfo (S : Finset α) (f : α → β) (g : α → γ) : ℝ :=
  ent S f + ent S g - ent S (fun a => (f a, g a))

/-- Entropy depends only on the values on the sample. -/
theorem ent_congr (S : Finset α) {f f' : α → β} (h : ∀ a ∈ S, f a = f' a) :
    ent S f = ent S f' := by
  unfold ent pmf
  rw [image_congr (fun a ha => h a ha)]
  refine sum_congr rfl (fun b _ => ?_)
  rw [filter_congr (fun a ha => by rw [h a ha])]

/-- Entropy is invariant under injective relabelling of the values. -/
theorem ent_comp_injective (S : Finset α) (g : α → γ) {k : γ → δ}
    (hk : Function.Injective k) : ent S (fun a => k (g a)) = ent S g := by
  unfold ent
  rw [show (S.image fun a => k (g a)) = (S.image g).image k by rw [image_image]; rfl,
    sum_image (fun x _ y _ hxy => hk hxy)]
  refine sum_congr rfl (fun t _ => ?_)
  unfold pmf
  rw [filter_congr (p := fun a => k (g a) = k t) (q := fun a => g a = t)
    (fun a _ => hk.eq_iff)]

/-- **Pinning theorem.** If `f` is a function of `g` on the sample, then `I(f ; g) = H(f)`. -/
theorem mutInfo_eq_ent_of_factor (S : Finset α) (f : α → β) (g : α → γ) (d : γ → β)
    (h : ∀ a ∈ S, f a = d (g a)) : mutInfo S f g = ent S f := by
  have hpair : ent S (fun a => (f a, g a)) = ent S g := by
    rw [ent_congr S (f' := fun a => (fun t => (d t, t)) (g a)) (fun a ha => by rw [h a ha])]
    exact ent_comp_injective (k := fun t => (d t, t)) S g
      (fun x y hxy => congrArg Prod.snd hxy)
  unfold mutInfo
  rw [hpair, add_sub_cancel_right]

/-- **A balanced two-valued variable carries exactly one bit.** -/
theorem ent_two_balanced (S : Finset α) (f : α → β) {b₁ b₂ : β} (hne : b₁ ≠ b₂)
    (hS : S.Nonempty) (hval : ∀ a ∈ S, f a = b₁ ∨ f a = b₂)
    (hbal : (S.filter (fun a => f a = b₁)).card = (S.filter (fun a => f a = b₂)).card) :
    ent S f = 1 := by
  set n := (S.filter (fun a => f a = b₁)).card with hn
  have hnot : S.filter (fun a => ¬ f a = b₁) = S.filter (fun a => f a = b₂) := by
    refine filter_congr (fun a ha => ?_)
    rcases hval a ha with h | h
    · simp [h, hne]
    · simp [h, Ne.symm hne]
  have hcard : S.card = 2 * n := by
    have := card_filter_add_card_filter_not (s := S) (fun a => f a = b₁)
    rw [hnot, ← hbal] at this; omega
  have hnpos : 0 < n := by
    have := hS.card_pos; omega
  have himg : S.image f = {b₁, b₂} := by
    ext b
    simp only [mem_image, mem_insert, mem_singleton]
    constructor
    · rintro ⟨a, ha, rfl⟩; exact hval a ha
    · rintro (rfl | rfl)
      · obtain ⟨a, ha⟩ := card_pos.mp hnpos
        exact ⟨a, (mem_filter.mp ha).1, (mem_filter.mp ha).2⟩
      · obtain ⟨a, ha⟩ := card_pos.mp (hbal ▸ hnpos)
        exact ⟨a, (mem_filter.mp ha).1, (mem_filter.mp ha).2⟩
  have hhalf : ∀ b ∈ ({b₁, b₂} : Finset β), pmf S f b = 2⁻¹ := by
    intro b hb
    have hnR : (n : ℝ) ≠ 0 := by exact_mod_cast hnpos.ne'
    simp only [mem_insert, mem_singleton] at hb
    rcases hb with rfl | rfl
    · rw [pmf, hcard, ← hn]; push_cast; field_simp
    · rw [pmf, hcard, ← hbal]; push_cast; field_simp
  rw [ent, himg, sum_congr rfl (fun b hb => by rw [hhalf b hb]), sum_pair hne, nlog2_inv,
    Real.logb_self_eq_one (by norm_num)]
  norm_num

/-! ## The sample law for the type channel -/

/-- **Sample law.** On every finite sample of primes `p ∤ 3c`, and for every `c`,
`I(p mod 3 ; T) = H(p mod 3)`.  The normalised information is exactly `1`. -/
theorem typeChannel_mutInfo (c : ℤ) (S : Finset ℕ)
    (hS : ∀ p ∈ S, p.Prime ∧ ¬ (p : ℤ) ∣ 3 * c) :
    mutInfo S (fun p => p % 3) (cubeType c) = ent S (fun p => p % 3) :=
  mutInfo_eq_ent_of_factor S _ _ typeDecode
    (fun p hp => (typeDecode_cubeType c (hS p hp).1 (hS p hp).2).symm)

/-- On a sample balanced between the classes `1` and `2 (mod 3)`, the type channel of any pure
cubic carries exactly one bit about `p mod 3`. -/
theorem typeChannel_mutInfo_balanced (c : ℤ) (S : Finset ℕ) (hne : S.Nonempty)
    (hS : ∀ p ∈ S, p.Prime ∧ ¬ (p : ℤ) ∣ 3 * c)
    (hbal : (S.filter (fun p => p % 3 = 1)).card = (S.filter (fun p => p % 3 = 2)).card) :
    mutInfo S (fun p => p % 3) (cubeType c) = 1 := by
  rw [typeChannel_mutInfo c S hS]
  refine ent_two_balanced S _ (by norm_num) hne (fun p hp => ?_) hbal
  obtain ⟨hpr, hram⟩ := hS p hp
  have := (unramified_facts hpr hram).1
  omega

/-- The fourth field on the balanced sample `{5, 11, 13, 19}`: `I(p mod 3 ; T) = 1` exactly. -/
theorem seven_balanced_sample :
    mutInfo ({5, 11, 13, 19} : Finset ℕ) (fun p => p % 3) (cubeType 7) = 1 := by
  refine typeChannel_mutInfo_balanced 7 _ ⟨5, by simp⟩ (fun p hp => ?_) (by decide)
  simp only [mem_insert, mem_singleton] at hp
  rcases hp with rfl | rfl | rfl | rfl <;> refine ⟨by norm_num, ?_⟩ <;> norm_num

/-! ## The Chebotarev model: `S₃` acting on three roots -/

/-- Number of fixed points of a permutation of the three roots. -/
def fixCount (σ : Equiv.Perm (Fin 3)) : ℕ := (univ.filter (fun i => σ i = i)).card

/-- In `S₃` the sign is determined by the fixed-point count: odd iff exactly one fixed point. -/
theorem s3_sign_eq_decode :
    ∀ σ : Equiv.Perm (Fin 3), Equiv.Perm.sign σ = if fixCount σ = 1 then -1 else 1 := by
  decide

/-- **The Chebotarev model of the law.** For `σ` uniform in `S₃`,
`I(sign σ ; #Fix σ) = 1` bit exactly. -/
theorem s3_mutInfo_sign_fix :
    mutInfo (univ : Finset (Equiv.Perm (Fin 3))) (fun σ => Equiv.Perm.sign σ) fixCount = 1 := by
  rw [mutInfo_eq_ent_of_factor _ _ _ (fun t => if t = 1 then (-1 : ℤˣ) else 1)
    (fun σ _ => s3_sign_eq_decode σ)]
  refine ent_two_balanced _ _ (b₁ := (1 : ℤˣ)) (b₂ := -1) (by decide) univ_nonempty
    (fun σ _ => Int.units_eq_one_or _) (by decide)

lemma s3_fix_image : (univ : Finset (Equiv.Perm (Fin 3))).image fixCount = {3, 1, 0} := by
  decide

/-- **Type entropy in the `S₃` model:** `H(#Fix) = 2/3 + (log₂ 3)/2`, from the class sizes
`1, 3, 2` (identity, transpositions, 3-cycles). -/
theorem s3_ent_fix :
    ent (univ : Finset (Equiv.Perm (Fin 3))) fixCount = 2 / 3 + Real.logb 2 3 / 2 := by
  have h3 : pmf (univ : Finset (Equiv.Perm (Fin 3))) fixCount 3 = (6 : ℝ)⁻¹ := by
    rw [pmf, show (univ.filter fun σ : Equiv.Perm (Fin 3) => fixCount σ = 3).card = 1 by decide,
      card_univ, Fintype.card_perm, Fintype.card_fin]; norm_num
  have h1 : pmf (univ : Finset (Equiv.Perm (Fin 3))) fixCount 1 = (2 : ℝ)⁻¹ := by
    rw [pmf, show (univ.filter fun σ : Equiv.Perm (Fin 3) => fixCount σ = 1).card = 3 by decide,
      card_univ, Fintype.card_perm, Fintype.card_fin]; norm_num
  have h0 : pmf (univ : Finset (Equiv.Perm (Fin 3))) fixCount 0 = (3 : ℝ)⁻¹ := by
    rw [pmf, show (univ.filter fun σ : Equiv.Perm (Fin 3) => fixCount σ = 0).card = 2 by decide,
      card_univ, Fintype.card_perm, Fintype.card_fin]; norm_num
  rw [ent, s3_fix_image, sum_insert (by decide), sum_insert (by decide), sum_singleton, h3, h1, h0,
    nlog2_inv, nlog2_inv, nlog2_inv,
    show (6 : ℝ) = 2 * 3 by norm_num, Real.logb_mul (by norm_num) (by norm_num),
    Real.logb_self_eq_one (by norm_num)]
  ring

/-- `log₂ 3 > 3/2`, from `2³ < 3²`. -/
lemma logb2_three_gt : (3 : ℝ) / 2 < Real.logb 2 3 := by
  have h : ((2 : ℝ) ^ (3 : ℕ)) < (3 : ℝ) ^ (2 : ℕ) := by norm_num
  have h2 := Real.log_lt_log (by positivity) h
  rw [Real.log_pow, Real.log_pow] at h2
  push_cast at h2
  have hlog2 : 0 < Real.log 2 := Real.log_pos (by norm_num)
  rw [Real.logb, lt_div_iff₀ hlog2]
  linarith

/-- **The type is strictly finer than `p mod 3`.** In the `S₃` model the gap
`H(T) - I(sign ; T)` equals `(log₂ 3)/2 - 1/3`, which is positive (`> 5/12`). -/
theorem s3_type_gap :
    ent (univ : Finset (Equiv.Perm (Fin 3))) fixCount
        - mutInfo (univ : Finset (Equiv.Perm (Fin 3))) (fun σ => Equiv.Perm.sign σ) fixCount
      = Real.logb 2 3 / 2 - 1 / 3 ∧
    (5 : ℝ) / 12 < Real.logb 2 3 / 2 - 1 / 3 := by
  rw [s3_ent_fix, s3_mutInfo_sign_fix]
  exact ⟨by ring, by linarith [logb2_three_gt]⟩

end UniversalS3Fourth

end