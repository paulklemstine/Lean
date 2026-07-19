/-
# The Unreasonable Effectiveness of Wrong Theories — Contrarian Results

This file separates a defensible geometric theorem from two overstrong readings
of the slogan.  A theory is a point of a real inner-product space, truth is a
distinguished point, and a phenomenon is a measurement direction.
-/
import Mathlib

open scoped RealInnerProductSpace Topology

namespace WrongTheoriesContrarian

section Definitions

variable {E : Type*} [NormedAddCommGroup E]

/-- Global wrongness is distance from the truth in theory-space. -/
def wrongness (truth T : E) : ℝ := ‖T - truth‖

/-- The theory obtained after the first `n` perturbative corrections. -/
def partialTheory (T₀ : E) (c : ℕ → E) (n : ℕ) : E :=
  T₀ + ∑ i ∈ Finset.range n, c i

@[simp] theorem wrongness_truth (truth : E) : wrongness truth truth = 0 := by
  simp [wrongness]

@[simp] theorem partialTheory_zero (T₀ : E) (c : ℕ → E) :
    partialTheory T₀ c 0 = T₀ := by
  simp [partialTheory]

end Definitions

section Perturbation

variable {E : Type*} [NormedAddCommGroup E]

/-- A precise positive result: if the correction series sums to the exact gap,
then the wrongness of the partial theories converges to zero. -/
theorem wrongness_converges_of_hasSum (truth T₀ : E) (c : ℕ → E)
    (hc : HasSum c (truth - T₀)) :
    Filter.Tendsto (fun n => wrongness truth (partialTheory T₀ c n))
      Filter.atTop (𝓝 0) := by
  convert Filter.Tendsto.norm
    (hc.tendsto_sum_nat.const_add T₀ |> Filter.Tendsto.sub_const <| truth) using 2
  simp

/-
Convergence toward truth does not force step-by-step improvement.  This
finite perturbation first doubles the error and only then corrects it exactly.
-/
theorem convergent_correction_can_initially_worsen :
    let c : ℕ → ℝ := fun n => if n = 0 then 1 else if n = 1 then -2 else 0
    HasSum c (-1) ∧
      wrongness 0 (partialTheory 1 c 1) > wrongness 0 (partialTheory 1 c 0) ∧
      partialTheory 1 c 2 = 0 := by
  refine' ⟨ _, _, _ ⟩ <;> norm_num [ wrongness, partialTheory ];
  · convert hasSum_sum_of_ne_finset_zero _ using 1;
    rotate_left;
    exacts [ { 0, 1 }, by intro b hb; rcases b with ( _ | _ | b ) <;> simp_all +decide, by tauto, by norm_num ];
  · norm_num [ Finset.sum ]

end Perturbation

section Phenomena

variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]

/-- Absolute prediction error in measurement direction `u`. -/
noncomputable def predErr (truth T u : E) : ℝ := |⟪T - truth, u⟫|

@[simp] theorem truth_prediction_error (truth u : E) :
    predErr truth truth u = 0 := by
  simp [predErr]

/-- A wrong theory is exact on every phenomenon orthogonal to its error. -/
theorem exact_on_orthogonal_phenomena (truth T u : E)
    (horth : ⟪T - truth, u⟫ = (0 : ℝ)) :
    predErr truth T u = 0 := by
  simp [predErr, horth]

/-
**Disproof of the unrestricted headline claim.** If the comparison class
contains truth itself, no wrong theory can have strictly smaller prediction
error than every member of that class on any phenomenon.
-/
theorem cannot_beat_a_class_containing_truth (truth T : E) (K : Set E)
    (htruth : truth ∈ K) :
    ¬ ∃ u : E, ∀ S ∈ K, predErr truth T u < predErr truth S u := by
  exact fun ⟨ u, hu ⟩ => not_lt_of_ge ( by simp [ predErr ] ) ( hu _ htruth )

/-
A stronger obstruction: every genuinely wrong theory has a phenomenon on
which truth is strictly better. Thus no wrong theory uniformly dominates truth.
-/
theorem truth_strictly_beats_every_wrong_theory_somewhere (truth T : E)
    (hwrong : T ≠ truth) :
    ∃ u : E, predErr truth truth u < predErr truth T u := by
  refine' ⟨ T - truth, _ ⟩;
  simp +decide [predErr];
  exact sq_pos_of_pos ( norm_pos_iff.mpr ( sub_ne_zero.mpr hwrong ) )

/-
The valid contrarian core. If a rival's error is not parallel to the wrong
 theory's error, Gram–Schmidt produces a phenomenon where the wrong theory is
exact and the rival is not.
-/
theorem wrong_theory_beats_nonparallel_rival (truth A B : E) (hA : A ≠ truth)
    (hparallel : ∀ r : ℝ, B - truth ≠ r • (A - truth)) :
    ∃ u : E, predErr truth A u = 0 ∧ 0 < predErr truth B u := by
  refine' ⟨ B - truth - ( inner ℝ ( B - truth ) ( A - truth ) / inner ℝ ( A - truth ) ( A - truth ) ) • ( A - truth ), _, _ ⟩ <;> simp_all +decide [ predErr ];
  · simp +decide [inner_sub_right, inner_smul_right,
      div_mul_cancel₀ _ (pow_ne_zero 2 (norm_ne_zero_iff.mpr (sub_ne_zero.mpr hA)))];
    simp +decide [real_inner_comm, inner_sub_left];
    ring;
  · by_contra h_contra;
    have h_contra' : ‖B - truth - ( inner ℝ ( B - truth ) ( A - truth ) / inner ℝ ( A - truth ) ( A - truth ) ) • ( A - truth )‖ ^ 2 = 0 := by
      rw [ @norm_sub_sq ℝ ] ; simp_all +decide [inner_sub_left, inner_sub_right, inner_smul_right] ; ring;
      rw [ norm_smul, Real.norm_eq_abs ] ; ring_nf at * ; simp_all +decide [ sub_eq_iff_eq_add ] ;
      grind;
    simp_all +decide [ sub_eq_iff_eq_add ]

end Phenomena

end WrongTheoriesContrarian