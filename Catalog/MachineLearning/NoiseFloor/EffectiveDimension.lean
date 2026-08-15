/-
# The Noise-Floor Principle, Part I: Effective Dimension

Round-6 hypothesis closure, Phase A.  This file develops the *spectral effective
dimension*

  `effDim a b = ∑ i, a i / (a i + b)`

of a nonnegative "signal spectrum" `a : ι → ℝ` measured at a "noise level" `b > 0`.
It is the scalar shadow of the matrix quantity `tr (A (A + b•1)⁻¹)` (the
*trace lemma frontier*, formalised in `TraceLemma.lean`), and it is the exact
value of the information-theoretic noise floor of any linear spectral filter
(formalised in `NoiseFloorPrinciple.lean`).

Main results:

* `effDim_nonneg`, `effDim_le_card`, `effDim_le_min`
* `effDim_le_trace_div`      — the *trace bound* `d_eff ≤ tr(a)/b`
* `effDim_antitone_level`    — monotone decreasing in the noise level
* `effDim_mono_spectrum`     — monotone increasing in the spectrum
* `effDim_doubling`          — `d_eff(b/2) ≤ 2 d_eff(b)`: the noise floor has no
                               sharp cliff (a Muckenhoupt-style doubling property)
* `effDim_scale_invariant`   — joint scaling invariance `d_eff(ca, cb) = d_eff(a,b)`
* `effDim_concave`           — concavity in the spectrum (mixing signals cannot help)
* `count_le_two_mul_effDim`  — `#{i : b ≤ a i} ≤ 2 d_eff`: every *resolvable* mode
                               contributes at least one half to the effective dimension.
-/
import Mathlib

namespace Catalog.MachineLearning.NoiseFloor

open Finset

variable {ι : Type*} [Fintype ι]

/-- The **spectral effective dimension** of a nonnegative spectrum `a` at noise
level `b`: `∑ i, a i / (a i + b)`.  Each mode contributes a number in `[0,1)`
measuring how far it sticks out of the noise floor. -/
noncomputable def effDim (a : ι → ℝ) (b : ℝ) : ℝ := ∑ i, a i / (a i + b)

section Basic

variable {a : ι → ℝ} {b : ℝ}

omit [Fintype ι] in
lemma denom_pos (ha : ∀ i, 0 ≤ a i) (hb : 0 < b) (i : ι) : 0 < a i + b := by
  have := ha i; linarith

omit [Fintype ι] in
lemma mode_mem_Ico (ha : ∀ i, 0 ≤ a i) (hb : 0 < b) (i : ι) :
    0 ≤ a i / (a i + b) ∧ a i / (a i + b) < 1 := by
  have hd : 0 < a i + b := denom_pos ha hb i
  refine ⟨div_nonneg (ha i) hd.le, ?_⟩
  rw [div_lt_one hd]; linarith

lemma effDim_nonneg (ha : ∀ i, 0 ≤ a i) (hb : 0 < b) : 0 ≤ effDim a b :=
  Finset.sum_nonneg fun i _ => (mode_mem_Ico ha hb i).1

/-- The effective dimension never exceeds the ambient dimension. -/
lemma effDim_le_card (ha : ∀ i, 0 ≤ a i) (hb : 0 < b) :
    effDim a b ≤ (Fintype.card ι : ℝ) := by
  classical
  have : effDim a b ≤ ∑ _i : ι, (1 : ℝ) :=
    Finset.sum_le_sum fun i _ => (mode_mem_Ico ha hb i).2.le
  simpa [Finset.card_univ] using this

/-- **Trace bound** (scalar form of the trace lemma): the effective dimension is
controlled by the total signal power divided by the noise level. -/
lemma effDim_le_trace_div (ha : ∀ i, 0 ≤ a i) (hb : 0 < b) :
    effDim a b ≤ (∑ i, a i) / b := by
  rw [Finset.sum_div]
  refine Finset.sum_le_sum fun i _ => ?_
  have hd : 0 < a i + b := denom_pos ha hb i
  rw [div_le_div_iff₀ hd hb]
  nlinarith [ha i]
/-- Combining the two universal bounds: `d_eff ≤ min(n, tr a / b)`. -/
lemma effDim_le_min (ha : ∀ i, 0 ≤ a i) (hb : 0 < b) :
    effDim a b ≤ min (Fintype.card ι : ℝ) ((∑ i, a i) / b) :=
  le_min (effDim_le_card ha hb) (effDim_le_trace_div ha hb)

/-- The effective dimension decreases as the noise level grows. -/
lemma effDim_antitone_level (ha : ∀ i, 0 ≤ a i) {b₁ b₂ : ℝ} (hb₁ : 0 < b₁)
    (h : b₁ ≤ b₂) : effDim a b₂ ≤ effDim a b₁ := by
  refine Finset.sum_le_sum fun i _ => ?_
  have h1 : 0 < a i + b₁ := denom_pos ha hb₁ i
  have h2 : 0 < a i + b₂ := by have := ha i; linarith
  rw [div_le_div_iff₀ h2 h1]
  nlinarith [ha i]

/-- The effective dimension increases with the signal spectrum. -/
lemma effDim_mono_spectrum {a a' : ι → ℝ} (ha : ∀ i, 0 ≤ a i) (hb : 0 < b)
    (h : ∀ i, a i ≤ a' i) : effDim a b ≤ effDim a' b := by
  refine Finset.sum_le_sum fun i _ => ?_
  have h1 : 0 < a i + b := denom_pos ha hb i
  have h2 : 0 < a' i + b := by have := (ha i).trans (h i); linarith
  rw [div_le_div_iff₀ h1 h2]
  nlinarith [ha i, h i]

/-- **Doubling property.** Halving the noise level at most doubles the effective
dimension: the noise floor degrades continuously, never off a cliff. -/
lemma effDim_doubling (ha : ∀ i, 0 ≤ a i) (hb : 0 < b) :
    effDim a (b / 2) ≤ 2 * effDim a b := by
  rw [effDim, effDim, Finset.mul_sum]
  refine Finset.sum_le_sum fun i _ => ?_
  have h1 : 0 < a i + b / 2 := by have := ha i; linarith
  have h2 : 0 < a i + b := denom_pos ha hb i
  rw [div_le_iff₀ h1]
  have : 2 * (a i / (a i + b)) = (2 * a i) / (a i + b) := by ring
  rw [this, div_mul_eq_mul_div, le_div_iff₀ h2]
  nlinarith [ha i]

/-- Joint scale invariance: the effective dimension only depends on the
signal-to-noise ratios `a i / b`. -/
lemma effDim_scale_invariant (a : ι → ℝ) (b : ℝ) {c : ℝ} (hc : 0 < c) :
    effDim (fun i => c * a i) (c * b) = effDim a b := by
  refine Finset.sum_congr rfl fun i _ => ?_
  rw [← mul_add, mul_div_mul_left _ _ hc.ne']

/-- Pointwise concavity of `x ↦ x / (x + b)` on the nonnegative reals.  The
cleared-denominator identity behind it is
`gap = b * w * (1-w) * (x-y)^2`. -/
lemma mode_concave {x y : ℝ} (hx : 0 ≤ x) (hy : 0 ≤ y) (hb : 0 < b) {w : ℝ}
    (hw₀ : 0 ≤ w) (hw₁ : w ≤ 1) :
    w * (x / (x + b)) + (1 - w) * (y / (y + b))
      ≤ (w * x + (1 - w) * y) / ((w * x + (1 - w) * y) + b) := by
  have hX : 0 < x + b := by linarith
  have hY : 0 < y + b := by linarith
  have h1w : (0 : ℝ) ≤ 1 - w := by linarith
  have hZ : 0 < w * x + (1 - w) * y + b := by
    have := mul_nonneg hw₀ hx
    have := mul_nonneg h1w hy
    linarith
  have lhs_eq : w * (x / (x + b)) + (1 - w) * (y / (y + b))
      = (w * x * (y + b) + (1 - w) * y * (x + b)) / ((x + b) * (y + b)) := by
    field_simp
  rw [lhs_eq, div_le_div_iff₀ (by positivity) hZ]
  nlinarith [mul_nonneg (mul_nonneg (mul_nonneg hb.le hw₀) h1w) (sq_nonneg (x - y))]

/-- **Concavity in the spectrum**: mixing two signal spectra can only *increase*
the effective dimension.  Equivalently, the effective dimension is a concave
functional of the signal, so spectral diversity is never penalised. -/
lemma effDim_concave {a a' : ι → ℝ} (ha : ∀ i, 0 ≤ a i) (ha' : ∀ i, 0 ≤ a' i)
    (hb : 0 < b) {w : ℝ} (hw₀ : 0 ≤ w) (hw₁ : w ≤ 1) :
    w * effDim a b + (1 - w) * effDim a' b
      ≤ effDim (fun i => w * a i + (1 - w) * a' i) b := by
  rw [effDim, effDim, effDim, Finset.mul_sum, Finset.mul_sum, ← Finset.sum_add_distrib]
  exact Finset.sum_le_sum fun i _ => mode_concave (ha i) (ha' i) hb hw₀ hw₁

end Basic

section Counting

variable {a : ι → ℝ} {b : ℝ}

omit [Fintype ι] in
/-- A mode whose power exceeds the noise level contributes at least `1/2`. -/
lemma half_le_mode (hb : 0 < b) {i : ι} (hi : b ≤ a i) : (1 : ℝ) / 2 ≤ a i / (a i + b) := by
  have hd : 0 < a i + b := by linarith
  rw [div_le_div_iff₀ (by norm_num) hd]
  linarith

/-- **Resolvable-mode counting bound.**  Every mode above the noise level
contributes at least one half of a dimension, so the number of resolvable modes
is at most twice the effective dimension.  This is the combinatorial half of the
noise-floor principle. -/
lemma count_le_two_mul_effDim [DecidableEq ι] (ha : ∀ i, 0 ≤ a i) (hb : 0 < b) :
    ((univ.filter fun i => b ≤ a i).card : ℝ) ≤ 2 * effDim a b := by
  classical
  have h1 : ((univ.filter fun i => b ≤ a i).card : ℝ) * (2 : ℝ)⁻¹
      ≤ ∑ i ∈ univ.filter fun i => b ≤ a i, a i / (a i + b) := by
    have := Finset.card_nsmul_le_sum (univ.filter fun i => b ≤ a i)
      (fun i => a i / (a i + b)) ((1 : ℝ) / 2) (fun i hi => half_le_mode hb (mem_filter.1 hi).2)
    simpa [nsmul_eq_mul] using this
  have h2 : ∑ i ∈ univ.filter fun i => b ≤ a i, a i / (a i + b) ≤ effDim a b := by
    refine Finset.sum_le_sum_of_subset_of_nonneg (Finset.filter_subset _ _) ?_
    intro i _ _
    exact (mode_mem_Ico ha hb i).1
  linarith

end Counting

end Catalog.MachineLearning.NoiseFloor