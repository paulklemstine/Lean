/-
# Entropy deficit of a label coarsening

## Context (FACT round-29 #2, "THE-ORIGINAL-STANDS")

The audit of paper 99's rebuild turned on a purely information-theoretic fact:
merging distinct labels can only *destroy* label entropy, never create it, and
the amount destroyed is controlled by a nonnegative **deficit** functional.

This file develops that functional from scratch (Mathlib has no Shannon entropy
for finitely supported weight functions), in bits, with the standard convention
`0 · log 0 = 0` — which is automatic in Lean because `Real.logb 2 0 = 0`.

Main results:

* `D_eq` — closed form of the deficit `D s w = ∑ w x · (log₂ W − log₂ (w x))`;
* `D_nonneg` — the deficit of a nonnegative weight vector is `≥ 0`
  (equivalently: `nlp (∑ w) ≤ H w`, i.e. *merging a block loses entropy*);
* `kl_nonneg` — Gibbs' inequality in unnormalised form, with the zero
  convention and an explicit absolute-continuity hypothesis (which is
  **necessary**: see `kl_neg_without_absolute_continuity`);
* `D_superadditive` — concavity of entropy in deficit form: the total deficit
  of a family of weight vectors is at most the deficit of their sum.  This is
  the engine of the data-processing inequality proved in
  `Applications.JointLabelReconciliation`;
* `D_pos_of_two_positive` — a *strict* loss: whenever a merged block contains
  two strictly positive masses, entropy strictly drops.
-/
import Mathlib

namespace LabelEntropy

open Finset Real

variable {ι κ : Type*}

/-- Pointwise Shannon term in bits, `nlp t = -t·log₂ t`, with `nlp 0 = 0`. -/
noncomputable def nlp (t : ℝ) : ℝ := -(t * Real.logb 2 t)

@[simp] lemma nlp_zero : nlp 0 = 0 := by simp [nlp]

/-- Shannon entropy (bits) of a nonnegative weight function on a finite set. -/
noncomputable def H (s : Finset ι) (w : ι → ℝ) : ℝ := ∑ i ∈ s, nlp (w i)

/-- Entropy **deficit**: how much entropy is lost by collapsing the whole block
`s` into a single label of mass `∑ w`. -/
noncomputable def D (s : Finset ι) (w : ι → ℝ) : ℝ := H s w - nlp (∑ i ∈ s, w i)

lemma H_empty (w : ι → ℝ) : H (∅ : Finset ι) w = 0 := by simp [H]

/-- Closed form of the deficit.  No positivity is needed: it is an algebraic
rearrangement using `(∑ w)·log₂(∑ w) = ∑ (w x · log₂ (∑ w))`. -/
lemma D_eq (s : Finset ι) (w : ι → ℝ) :
    D s w = ∑ i ∈ s, w i * (Real.logb 2 (∑ j ∈ s, w j) - Real.logb 2 (w i)) := by
  have hmul : (∑ j ∈ s, w j) * Real.logb 2 (∑ j ∈ s, w j)
      = ∑ i ∈ s, w i * Real.logb 2 (∑ j ∈ s, w j) := by
    rw [Finset.sum_mul]
  simp only [D, H, nlp]
  rw [sub_neg_eq_add, hmul, ← Finset.sum_add_distrib]
  refine Finset.sum_congr rfl fun i _ => ?_
  ring

/-- **Merging loses entropy.**  The deficit of a nonnegative weight vector is
nonnegative; equivalently `nlp (∑ w) ≤ H s w`. -/
theorem D_nonneg {s : Finset ι} {w : ι → ℝ} (hw : ∀ i ∈ s, 0 ≤ w i) : 0 ≤ D s w := by
  rw [D_eq]
  refine Finset.sum_nonneg fun i hi => ?_
  rcases eq_or_lt_of_le (hw i hi) with h0 | hpos
  · simp [← h0]
  · have hle : w i ≤ ∑ j ∈ s, w j := Finset.single_le_sum hw hi
    have hS : (0:ℝ) < ∑ j ∈ s, w j := lt_of_lt_of_le hpos hle
    have : Real.logb 2 (w i) ≤ Real.logb 2 (∑ j ∈ s, w j) :=
      Real.logb_le_logb_of_le (by norm_num) hpos hle
    have := sub_nonneg.mpr this
    positivity

/-- Restated: collapsing a block to a single label cannot increase entropy. -/
theorem nlp_sum_le_H {s : Finset ι} {w : ι → ℝ} (hw : ∀ i ∈ s, 0 ≤ w i) :
    nlp (∑ i ∈ s, w i) ≤ H s w :=
  sub_nonneg.mp (D_nonneg hw)

/-! ## Gibbs' inequality (unnormalised, base 2) -/

/-- Per-term Gibbs bound: `(a - b)/log 2 ≤ a·(log₂ a - log₂ b)` for nonnegative
`a, b` with `b = 0 → a = 0`. -/
lemma gibbs_term {a b : ℝ} (ha : 0 ≤ a) (hb : 0 ≤ b) (hac : b = 0 → a = 0) :
    (a - b) / Real.log 2 ≤ a * (Real.logb 2 a - Real.logb 2 b) := by
  have hlog2 : (0:ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  rcases eq_or_lt_of_le ha with h0 | hapos
  · have hb' : 0 ≤ b := hb
    simp only [← h0, zero_mul, zero_sub]
    have : (0 - b) / Real.log 2 ≤ 0 := by
      apply div_nonpos_of_nonpos_of_nonneg (by linarith) hlog2.le
    simpa using this
  · have hbpos : 0 < b := by
      rcases eq_or_lt_of_le hb with hb0 | hbp
      · exact absurd (hac hb0.symm) (by linarith)
      · exact hbp
    have hlog : Real.log (b / a) ≤ b / a - 1 :=
      Real.log_le_sub_one_of_pos (div_pos hbpos hapos)
    have hsplit : Real.log (b / a) = Real.log b - Real.log a :=
      Real.log_div (ne_of_gt hbpos) (ne_of_gt hapos)
    have key : Real.log a - Real.log b ≥ 1 - b / a := by
      rw [hsplit] at hlog; linarith
    have hmul : a * (Real.log a - Real.log b) ≥ a * (1 - b / a) := by
      exact mul_le_mul_of_nonneg_left key hapos.le
    have hcancel : a * (1 - b / a) = a - b := by
      field_simp
    have hkey : a - b ≤ a * (Real.log a - Real.log b) := by
      rw [← hcancel]; exact hmul
    have hrw : a * (Real.logb 2 a - Real.logb 2 b)
        = (a * (Real.log a - Real.log b)) / Real.log 2 := by
      simp only [Real.logb]
      ring
    rw [hrw]
    gcongr

/-- **Gibbs' inequality**, unnormalised and in bits: if `b` is absolutely
continuous w.r.t. `a` (`b i = 0 → a i = 0`) and has no more total mass, then the
relative entropy `∑ a·(log₂ a - log₂ b)` is nonnegative. -/
theorem kl_nonneg {s : Finset ι} {a b : ι → ℝ}
    (ha : ∀ i ∈ s, 0 ≤ a i) (hb : ∀ i ∈ s, 0 ≤ b i)
    (hac : ∀ i ∈ s, b i = 0 → a i = 0)
    (hsum : ∑ i ∈ s, b i ≤ ∑ i ∈ s, a i) :
    0 ≤ ∑ i ∈ s, a i * (Real.logb 2 (a i) - Real.logb 2 (b i)) := by
  have hlog2 : (0:ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  have hterm : ∀ i ∈ s, (a i - b i) / Real.log 2
      ≤ a i * (Real.logb 2 (a i) - Real.logb 2 (b i)) :=
    fun i hi => gibbs_term (ha i hi) (hb i hi) (hac i hi)
  have h1 : ∑ i ∈ s, (a i - b i) / Real.log 2
      ≤ ∑ i ∈ s, a i * (Real.logb 2 (a i) - Real.logb 2 (b i)) :=
    Finset.sum_le_sum hterm
  have h2 : ∑ i ∈ s, (a i - b i) / Real.log 2
      = ((∑ i ∈ s, a i) - ∑ i ∈ s, b i) / Real.log 2 := by
    rw [← Finset.sum_div, Finset.sum_sub_distrib]
  have h3 : 0 ≤ ((∑ i ∈ s, a i) - ∑ i ∈ s, b i) / Real.log 2 :=
    div_nonneg (by linarith) hlog2.le
  linarith [h1, h2 ▸ h3]

/-- The absolute-continuity hypothesis in `kl_nonneg` cannot be dropped under
the `log 0 = 0` convention: an explicit two-point counterexample. -/
theorem kl_neg_without_absolute_continuity :
    ∃ (a b : Bool → ℝ), (∀ i, 0 ≤ a i) ∧ (∀ i, 0 ≤ b i) ∧
      (∑ i ∈ (Finset.univ : Finset Bool), b i) = ∑ i ∈ (Finset.univ : Finset Bool), a i ∧
      (∑ i ∈ (Finset.univ : Finset Bool), a i * (Real.logb 2 (a i) - Real.logb 2 (b i))) < 0 := by
  have h2 : Real.logb 2 ((1:ℝ)/2) = -1 := by
    rw [show (1:ℝ)/2 = (2:ℝ)⁻¹ by norm_num, Real.logb_inv, Real.logb_self_eq_one] ; norm_num
  refine ⟨fun i => if i then (1:ℝ)/2 else 1/2, fun i => if i then 0 else 1,
    by intro i; cases i <;> norm_num, by intro i; cases i <;> norm_num, by
      simp, ?_⟩
  simp only [Fintype.sum_bool]
  norm_num [h2]

/-! ## Concavity of entropy, in deficit form -/

/-- Key fiber estimate: comparing a sub-block `v` to a dominating block `w`. -/
lemma kl_fiber_nonneg {s : Finset ι} {v w : ι → ℝ}
    (hv : ∀ x ∈ s, 0 ≤ v x) (hvw : ∀ x ∈ s, v x ≤ w x)
    (hWpos : 0 < ∑ x ∈ s, w x) :
    0 ≤ ∑ x ∈ s, v x *
      ((Real.logb 2 (∑ y ∈ s, w y) - Real.logb 2 (w x))
        - (Real.logb 2 (∑ y ∈ s, v y) - Real.logb 2 (v x))) := by
  set W := ∑ y ∈ s, w y with hW
  set V := ∑ y ∈ s, v y with hV
  have hw : ∀ x ∈ s, 0 ≤ w x := fun x hx => le_trans (hv x hx) (hvw x hx)
  have hVnonneg : 0 ≤ V := Finset.sum_nonneg hv
  -- the comparison measure
  set b : ι → ℝ := fun x => w x * V / W with hbdef
  have hbnonneg : ∀ x ∈ s, 0 ≤ b x := fun x hx =>
    div_nonneg (mul_nonneg (hw x hx) hVnonneg) hWpos.le
  have hbsum : ∑ x ∈ s, b x = V := by
    simp only [hbdef]
    rw [← Finset.sum_div, ← Finset.sum_mul, ← hW]
    field_simp
  have hac : ∀ x ∈ s, b x = 0 → v x = 0 := by
    intro x hx hbx
    simp only [hbdef, div_eq_zero_iff] at hbx
    rcases hbx with h | h
    · rcases mul_eq_zero.mp h with hwx | hVzero
      · exact le_antisymm (by rw [← hwx]; exact hvw x hx) (hv x hx)
      · -- V = 0 with v nonneg forces v x = 0
        have : ∀ y ∈ s, v y = 0 :=
          (Finset.sum_eq_zero_iff_of_nonneg hv).mp (hV ▸ hVzero)
        exact this x hx
    · exact absurd h (ne_of_gt hWpos)
  have hkl := kl_nonneg (a := v) (b := b) hv hbnonneg hac (by rw [hbsum])
  refine le_trans hkl (le_of_eq (Finset.sum_congr rfl fun x hx => ?_))
  rcases eq_or_lt_of_le (hv x hx) with h0 | hpos
  · simp [← h0]
  · -- here v x > 0, hence w x > 0 and V > 0
    have hwx : 0 < w x := lt_of_lt_of_le hpos (hvw x hx)
    have hVpos : 0 < V := lt_of_lt_of_le hpos (hV ▸ Finset.single_le_sum hv hx)
    have hbx : b x = w x * V / W := rfl
    have : Real.logb 2 (b x) = Real.logb 2 (w x) + Real.logb 2 V - Real.logb 2 W := by
      rw [hbx, Real.logb_div (by positivity) (ne_of_gt hWpos), Real.logb_mul (ne_of_gt hwx)
        (ne_of_gt hVpos)]
    rw [this]
    ring

/-- **Concavity of entropy (deficit form).**  Splitting a nonnegative weight
vector into a family of pieces cannot increase the total deficit. -/
theorem D_superadditive {s : Finset ι} {t : Finset κ} {v : κ → ι → ℝ}
    (hv : ∀ y ∈ t, ∀ x ∈ s, 0 ≤ v y x) :
    ∑ y ∈ t, D s (v y) ≤ D s (fun x => ∑ y ∈ t, v y x) := by
  set w : ι → ℝ := fun x => ∑ y ∈ t, v y x with hwdef
  have hw : ∀ x ∈ s, 0 ≤ w x := fun x hx => Finset.sum_nonneg fun y hy => hv y hy x hx
  have hvw : ∀ y ∈ t, ∀ x ∈ s, v y x ≤ w x := fun y hy x hx =>
    Finset.single_le_sum (f := fun y => v y x) (fun z hz => hv z hz x hx) hy
  rcases eq_or_lt_of_le (Finset.sum_nonneg hw) with hW0 | hWpos
  · -- degenerate: total mass zero, everything vanishes
    have hallw : ∀ x ∈ s, w x = 0 := (Finset.sum_eq_zero_iff_of_nonneg hw).mp hW0.symm
    have hallv : ∀ y ∈ t, ∀ x ∈ s, v y x = 0 := by
      intro y hy x hx
      exact le_antisymm (by rw [← hallw x hx]; exact hvw y hy x hx) (hv y hy x hx)
    have hL : ∀ y ∈ t, D s (v y) = 0 := by
      intro y hy
      have h1 : ∀ x ∈ s, v y x = 0 := fun x hx => hallv y hy x hx
      have h2 : H s (v y) = 0 :=
        Finset.sum_eq_zero fun x hx => by rw [h1 x hx, nlp_zero]
      have h3 : ∑ x ∈ s, v y x = 0 := Finset.sum_eq_zero h1
      simp [D, h2, h3]
    have hR : D s w = 0 := by
      have h2 : H s w = 0 :=
        Finset.sum_eq_zero fun x hx => by rw [hallw x hx, nlp_zero]
      have h3 : ∑ x ∈ s, w x = 0 := Finset.sum_eq_zero hallw
      simp [D, h2, h3]
    rw [Finset.sum_congr rfl hL, hR]
    simp
  · rw [D_eq]
    have hLHS : ∑ y ∈ t, D s (v y)
        = ∑ y ∈ t, ∑ x ∈ s, v y x *
            (Real.logb 2 (∑ z ∈ s, v y z) - Real.logb 2 (v y x)) :=
      Finset.sum_congr rfl fun y _ => D_eq s (v y)
    have hRHS : ∑ x ∈ s, w x * (Real.logb 2 (∑ z ∈ s, w z) - Real.logb 2 (w x))
        = ∑ y ∈ t, ∑ x ∈ s, v y x *
            (Real.logb 2 (∑ z ∈ s, w z) - Real.logb 2 (w x)) := by
      conv_rhs => rw [Finset.sum_comm]
      refine Finset.sum_congr rfl fun x _ => ?_
      simp only [hwdef, Finset.sum_mul]
    rw [hLHS, hRHS, ← sub_nonneg, ← Finset.sum_sub_distrib]
    refine Finset.sum_nonneg fun y hy => ?_
    have := kl_fiber_nonneg (s := s) (v := v y) (w := w)
      (fun x hx => hv y hy x hx) (fun x hx => hvw y hy x hx) hWpos
    calc (0:ℝ) ≤ ∑ x ∈ s, v y x *
          ((Real.logb 2 (∑ z ∈ s, w z) - Real.logb 2 (w x))
            - (Real.logb 2 (∑ z ∈ s, v y z) - Real.logb 2 (v y x))) := this
      _ = (∑ x ∈ s, v y x * (Real.logb 2 (∑ z ∈ s, w z) - Real.logb 2 (w x)))
            - ∑ x ∈ s, v y x * (Real.logb 2 (∑ z ∈ s, v y z) - Real.logb 2 (v y x)) := by
          rw [← Finset.sum_sub_distrib]
          exact Finset.sum_congr rfl fun x _ => by ring

/-! ## Strict loss -/

/-- **Strict entropy loss.**  If a merged block contains two distinct atoms of
strictly positive mass, the deficit is strictly positive: entropy really drops,
it does not merely fail to increase. -/
theorem D_pos_of_two_positive {s : Finset ι} {w : ι → ℝ} (hw : ∀ i ∈ s, 0 ≤ w i)
    {i j : ι} (hi : i ∈ s) (hj : j ∈ s) (hij : i ≠ j)
    (hwi : 0 < w i) (hwj : 0 < w j) : 0 < D s w := by
  classical
  rw [D_eq]
  set S := ∑ k ∈ s, w k with hS
  have hSi : w i + w j ≤ S := by
    have : w i + w j = ∑ k ∈ ({i, j} : Finset ι), w k := by
      rw [Finset.sum_pair hij]
    rw [this, hS]
    refine Finset.sum_le_sum_of_subset_of_nonneg ?_ (fun k hk _ => hw k hk)
    intro k hk
    simp only [Finset.mem_insert, Finset.mem_singleton] at hk
    rcases hk with rfl | rfl <;> assumption
  have hSpos : 0 < S := by linarith
  have hstrict : Real.logb 2 (w i) < Real.logb 2 S :=
    Real.logb_lt_logb (by norm_num) hwi (by linarith)
  have hpos_i : 0 < w i * (Real.logb 2 S - Real.logb 2 (w i)) := by
    have := sub_pos.mpr hstrict
    positivity
  have hrest : ∀ k ∈ s, 0 ≤ w k * (Real.logb 2 S - Real.logb 2 (w k)) := by
    intro k hk
    rcases eq_or_lt_of_le (hw k hk) with h0 | hpos
    · simp [← h0]
    · have hle : w k ≤ S := hS ▸ Finset.single_le_sum hw hk
      have : Real.logb 2 (w k) ≤ Real.logb 2 S := Real.logb_le_logb_of_le (by norm_num) hpos hle
      have := sub_nonneg.mpr this
      positivity
  exact Finset.sum_pos' hrest ⟨i, hi, hpos_i⟩

end LabelEntropy