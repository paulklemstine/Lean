/-
# Full pinning at degree 12: the information theory of the type channel

This file develops, from scratch, the finite Shannon-information calculus needed to
state and prove the **full pinning** phenomenon observed at conductor 56:

  `I(p mod 56 ; T) = H(T)`  exactly, with gap `0`,

where `T = resDeg` is the splitting type (residue degree) of a residue class in
`Q(ζ₅₆)⁺`, and the input `p mod 56` is uniform on the 24 reduced residues.

Two layers:

* a **general theorem** (`mutualInfo_eq_entropyOut`): for *any* finite sample set
  `S` and *any* deterministic channel `φ : α → T`, the mutual information between a
  uniform input and its image equals the output entropy — the gap is identically 0.
  The point is that this is an equality, not an inequality: deterministic channels
  are exactly the fully pinned ones (`pinning_gap_zero`).
* the **exact evaluation** at conductor 56 (`entropyOut_Units56_resDeg`):

    `H(T) = 4/3 + (log₂ 3)/4 = 1.72957...`

  proved as a closed form, then bracketed rigorously by
  `1.7295 < H(T) < 1.7296`, which is the reported value `1.7296` bits.

We also compute the residual uncertainty `H(X | T) = 5/3 + (3/4)·log₂ 3`, i.e. the
channel is *lossy* even though it is fully pinned; the two statements together say
that the type is a strict, deterministic coarsening of the residue.
-/
import Mathlib
import Pythagorean.Degree12Composite

set_option maxRecDepth 40000

namespace Catalog.Pythagorean.Degree12Composite

open Finset

/-! ## A finite information calculus -/

/-- `nlog2 x = -x·log₂ x`, the Shannon term (with the convention `nlog2 0 = 0`). -/
noncomputable def nlog2 (x : ℝ) : ℝ := -x * Real.logb 2 x

@[simp] lemma nlog2_zero : nlog2 0 = 0 := by simp [nlog2]

lemma nlog2_one_div (x : ℝ) : nlog2 (1 / x) = (1 / x) * Real.logb 2 x := by
  rw [nlog2, one_div, Real.logb_inv]; ring

variable {α T : Type*} [DecidableEq T]

/-- The fibre of the channel `φ` over the output symbol `t`, inside the sample set `S`. -/
def fiber (S : Finset α) (φ : α → T) (t : T) : Finset α := S.filter (fun a => φ a = t)

/-- Output probability of the symbol `t` for a uniform input on `S`. -/
noncomputable def prob (S : Finset α) (φ : α → T) (t : T) : ℝ :=
  (fiber S φ t).card / S.card

/-- Output (Shannon) entropy `H(T)` in bits. -/
noncomputable def entropyOut (S : Finset α) (φ : α → T) : ℝ :=
  ∑ t ∈ S.image φ, nlog2 (prob S φ t)

/-- Input entropy `H(X) = log₂ |S|` of the uniform distribution on `S`. -/
noncomputable def entropyIn (S : Finset α) : ℝ := Real.logb 2 S.card

/-- Joint entropy `H(X, T)` of the uniform input and its image. -/
noncomputable def entropyJoint (S : Finset α) (φ : α → T) : ℝ :=
  ∑ p ∈ S ×ˢ S.image φ, nlog2 (if φ p.1 = p.2 then (S.card : ℝ)⁻¹ else 0)

/-- Mutual information `I(X ; T) = H(X) + H(T) - H(X, T)`. -/
noncomputable def mutualInfo (S : Finset α) (φ : α → T) : ℝ :=
  entropyIn S + entropyOut S φ - entropyJoint S φ

/-- Conditional entropy `H(X | T) = H(X,T) - H(T)`. -/
noncomputable def entropyCond (S : Finset α) (φ : α → T) : ℝ :=
  entropyJoint S φ - entropyOut S φ

/-- **Determinism collapses the joint entropy**: for a deterministic channel the
joint distribution of `(X, φ X)` is just the uniform distribution on `S`, so
`H(X, T) = H(X)`. -/
theorem entropyJoint_eq_entropyIn (S : Finset α) (φ : α → T) (hS : S.Nonempty) :
    entropyJoint S φ = entropyIn S := by
  have hn : (S.card : ℝ) ≠ 0 := Nat.cast_ne_zero.2 (Finset.card_ne_zero_of_mem hS.choose_spec)
  rw [entropyJoint, Finset.sum_product]
  have key : ∀ a ∈ S, (∑ t ∈ S.image φ, nlog2 (if φ a = t then (S.card : ℝ)⁻¹ else 0))
      = (S.card : ℝ)⁻¹ * Real.logb 2 S.card := by
    intro a ha
    rw [Finset.sum_eq_single (φ a)]
    · simp [nlog2, Real.logb_inv]
    · intro b _ hb
      simp [Ne.symm hb]
    · intro h
      exact absurd (Finset.mem_image_of_mem φ ha) h
  rw [Finset.sum_congr rfl key, Finset.sum_const, nsmul_eq_mul, entropyIn]
  field_simp

/-- **Full pinning theorem.**  For a deterministic channel the mutual information
between a uniform input and the output equals the whole output entropy. -/
theorem mutualInfo_eq_entropyOut (S : Finset α) (φ : α → T) (hS : S.Nonempty) :
    mutualInfo S φ = entropyOut S φ := by
  rw [mutualInfo, entropyJoint_eq_entropyIn S φ hS]; ring

/-- The "pinning gap" `H(T) - I(X;T)` vanishes identically. -/
theorem pinning_gap_zero (S : Finset α) (φ : α → T) (hS : S.Nonempty) :
    entropyOut S φ - mutualInfo S φ = 0 := by
  rw [mutualInfo_eq_entropyOut S φ hS]; ring

/-- Conditional entropy is the exact information loss: `H(X|T) = H(X) - H(T)`. -/
theorem entropyCond_eq (S : Finset α) (φ : α → T) (hS : S.Nonempty) :
    entropyCond S φ = entropyIn S - entropyOut S φ := by
  rw [entropyCond, entropyJoint_eq_entropyIn S φ hS]

/-! ## Base-2 logarithm toolkit -/

lemma logb2_two : Real.logb 2 2 = 1 := Real.logb_self_eq_one (b := 2) (by norm_num)

lemma logb2_four : Real.logb 2 4 = 2 := by
  rw [show (4:ℝ) = 2 ^ (2:ℕ) by norm_num, Real.logb_pow, logb2_two]; ring

lemma logb2_six : Real.logb 2 6 = 1 + Real.logb 2 3 := by
  rw [show (6:ℝ) = 2 * 3 by norm_num, Real.logb_mul (by norm_num) (by norm_num), logb2_two]

lemma logb2_twelve : Real.logb 2 12 = 2 + Real.logb 2 3 := by
  rw [show (12:ℝ) = 4 * 3 by norm_num, Real.logb_mul (by norm_num) (by norm_num), logb2_four]

lemma logb2_twentyfour : Real.logb 2 24 = 3 + Real.logb 2 3 := by
  rw [show (24:ℝ) = 8 * 3 by norm_num, Real.logb_mul (by norm_num) (by norm_num),
    show (8:ℝ) = 2 ^ (3:ℕ) by norm_num, Real.logb_pow, logb2_two]
  ring

/-- A rigorous rational lower bound for `log₂ 3`, from `2^84 < 3^53`. -/
lemma logb2_three_lower : (84 : ℝ) / 53 < Real.logb 2 3 := by
  have h : ((2:ℝ) ^ (84:ℕ)) < (3:ℝ) ^ (53:ℕ) := by
    exact_mod_cast (by norm_num : (2 ^ 84 : ℕ) < 3 ^ 53)
  have h2 := Real.log_lt_log (by positivity) h
  rw [Real.log_pow, Real.log_pow] at h2
  push_cast at h2
  have hlog2 : 0 < Real.log 2 := Real.log_pos (by norm_num)
  rw [Real.logb, lt_div_iff₀ hlog2]
  linarith

/-- A rigorous rational upper bound for `log₂ 3`, from `3^147 < 2^233`. -/
lemma logb2_three_upper : Real.logb 2 3 < (233 : ℝ) / 147 := by
  have h : ((3:ℝ) ^ (147:ℕ)) < (2:ℝ) ^ (233:ℕ) := by
    exact_mod_cast (by norm_num : (3 ^ 147 : ℕ) < 2 ^ 233)
  have h2 := Real.log_lt_log (by positivity) h
  rw [Real.log_pow, Real.log_pow] at h2
  push_cast at h2
  have hlog2 : 0 < Real.log 2 := Real.log_pos (by norm_num)
  rw [Real.logb, div_lt_iff₀ hlog2]
  linarith

/-! ## The conductor-56 type channel -/

lemma Units56_nonempty : Units56.Nonempty := ⟨1, by decide⟩

lemma card_fiber_one : (fiber Units56 resDeg 1).card = 2 := by decide
lemma card_fiber_two : (fiber Units56 resDeg 2).card = 6 := by decide
lemma card_fiber_three : (fiber Units56 resDeg 3).card = 4 := by decide
lemma card_fiber_six : (fiber Units56 resDeg 6).card = 12 := by decide

/-- The four type probabilities are exactly `1/12, 1/4, 1/6, 1/2` — the Chebotarev
densities of the four element orders of `C₆ × C₂`. -/
theorem prob_values :
    prob Units56 resDeg 1 = 1 / 12 ∧ prob Units56 resDeg 2 = 1 / 4 ∧
    prob Units56 resDeg 3 = 1 / 6 ∧ prob Units56 resDeg 6 = 1 / 2 := by
  refine ⟨?_, ?_, ?_, ?_⟩ <;>
    simp only [prob, card_fiber_one, card_fiber_two, card_fiber_three, card_fiber_six,
      card_Units56] <;> norm_num

/-- **Exact entropy of the degree-12 type channel.**
`H(T) = 4/3 + (log₂ 3)/4`. -/
theorem entropyOut_Units56_resDeg :
    entropyOut Units56 resDeg = 4 / 3 + Real.logb 2 3 / 4 := by
  obtain ⟨p1, p2, p3, p6⟩ := prob_values
  rw [entropyOut, image_resDeg]
  rw [show ({1, 2, 3, 6} : Finset ℕ) = insert 1 (insert 2 (insert 3 {6})) from rfl]
  rw [Finset.sum_insert (by decide), Finset.sum_insert (by decide),
    Finset.sum_insert (by decide), Finset.sum_singleton]
  rw [p1, p2, p3, p6, nlog2_one_div, nlog2_one_div, nlog2_one_div, nlog2_one_div,
    logb2_twelve, logb2_six, logb2_four, logb2_two]
  ring

/-- The reported value: `H(T) = 1.7296` bits to four decimal places. -/
theorem entropyOut_numeric :
    1.7295 < entropyOut Units56 resDeg ∧ entropyOut Units56 resDeg < 1.7296 := by
  rw [entropyOut_Units56_resDeg]
  exact ⟨by linarith [logb2_three_lower], by linarith [logb2_three_upper]⟩

/-- **Full pinning at conductor 56**: the mutual information between a uniform
reduced residue mod 56 and its splitting type equals the full type entropy. -/
theorem mutualInfo_Units56_resDeg :
    mutualInfo Units56 resDeg = 4 / 3 + Real.logb 2 3 / 4 :=
  (mutualInfo_eq_entropyOut Units56 resDeg Units56_nonempty).trans entropyOut_Units56_resDeg

/-- The measured gap `H(T) - I` is exactly `0`. -/
theorem pinning_gap_Units56 :
    entropyOut Units56 resDeg - mutualInfo Units56 resDeg = 0 :=
  pinning_gap_zero Units56 resDeg Units56_nonempty

/-- Input entropy: `H(X) = log₂ 24 = 3 + log₂ 3`. -/
theorem entropyIn_Units56 : entropyIn Units56 = 3 + Real.logb 2 3 := by
  rw [entropyIn, card_Units56]
  exact_mod_cast logb2_twentyfour

/-- **The channel is fully pinned but strictly lossy.**  The residual uncertainty
about the residue class given its type is `H(X|T) = 5/3 + (3/4)·log₂ 3 ≈ 2.8548`
bits, so the type map is deterministic (gap 0) yet far from injective. -/
theorem entropyCond_Units56 :
    entropyCond Units56 resDeg = 5 / 3 + 3 * Real.logb 2 3 / 4 := by
  rw [entropyCond_eq Units56 resDeg Units56_nonempty, entropyIn_Units56,
    entropyOut_Units56_resDeg]
  ring

theorem entropyCond_pos : 0 < entropyCond Units56 resDeg := by
  rw [entropyCond_Units56]; linarith [logb2_three_lower]

end Catalog.Pythagorean.Degree12Composite