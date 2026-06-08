/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Phase Transitions in Tropical Stability

This file establishes a deterministic threshold theory for tropical Lorentzian
stability. The **tropical margin** is a scalar order parameter compressing
an O(n²)-family of exchange inequalities into a single certificate.

## Main Results

* `tropMargin_eq_two_diagBias` — the tropical margin equals twice the diagonal bias
* `tropMargin_lipschitz` — Lipschitz stability under sup-norm perturbations
* `tropMargin_lower_bound_signal_noise` — deterministic signal/noise threshold
* `tropMargin_pos_of_signal_noise` — positive margin from signal dominance
* `tropMargin_meanModel` — exact computation for the mean model
* `tropMargin_mono_offdiag` — ferromagnetic monotonicity of the tropical margin

## Application Keywords

tropical geometry, Lorentzian polynomials, phase transition, random matrix theory,
Gaussian ensemble, statistical physics, monotone property, threshold phenomenon,
concentration of measure, certified stability, four-point inequality
-/

open Finset BigOperators

noncomputable section

namespace TropicalPhaseTransition

/-! ## Section 1: Core Definitions -/

/-- Exchange slack on a quadruple `(i, j, k, l)`. -/
def exSlack {n : ℕ} (W : Matrix (Fin n) (Fin n) ℝ) (i j k l : Fin n) : ℝ :=
  W i j + W k l - W i k - W j l

/-- The set of distinct pairs in `Fin n`. -/
def distinctPairs (n : ℕ) : Finset (Fin n × Fin n) :=
  Finset.univ.filter fun p => decide (p.1 ≠ p.2) = true

/-- Diagonal exchange slack for a pair. -/
def diagExSlack {n : ℕ} (W : Matrix (Fin n) (Fin n) ℝ) (i j : Fin n) : ℝ :=
  2 * W i j - W i i - W j j

/-- Tropical stability margin: minimum diagonal exchange slack over distinct pairs. -/
def tropMargin {n : ℕ} (W : Matrix (Fin n) (Fin n) ℝ) : ℝ :=
  if h : (distinctPairs n).Nonempty then
    (distinctPairs n).inf' h (fun p => diagExSlack W p.1 p.2)
  else 0

/-- Diagonal bias: `inf_{i≠j} (W i j - (W i i + W j j) / 2)`. -/
def diagBias {n : ℕ} (W : Matrix (Fin n) (Fin n) ℝ) : ℝ :=
  if h : (distinctPairs n).Nonempty then
    (distinctPairs n).inf' h (fun p => W p.1 p.2 - (W p.1 p.1 + W p.2 p.2) / 2)
  else 0

/-- Entry-wise sup-norm: `max_{i,j} |W i j|`. -/
def entrySupNorm {n : ℕ} (W : Matrix (Fin n) (Fin n) ℝ) : ℝ :=
  if h : (Finset.univ : Finset (Fin n × Fin n)).Nonempty then
    Finset.sup' Finset.univ h (fun p : Fin n × Fin n => |W p.1 p.2|)
  else 0

/-- Mean model matrix: diagonal `μdiag`, off-diagonal `μoff`. -/
def meanModel (n : ℕ) (μdiag μoff : ℝ) : Matrix (Fin n) (Fin n) ℝ :=
  Matrix.of fun i j => if i = j then μdiag else μoff

/-- Off-diagonal monotone ordering (ferromagnetic). -/
def OffDiagMonotoneLe {n : ℕ} (W W' : Matrix (Fin n) (Fin n) ℝ) : Prop :=
  (∀ i, W' i i ≤ W i i) ∧ (∀ i j, i ≠ j → W i j ≤ W' i j)

/-! ## Section 2: Basic Lemmas -/

lemma distinctPairs_nonempty {n : ℕ} (hn : 2 ≤ n) : (distinctPairs n).Nonempty := by
  exact ⟨ ⟨ ⟨ 0, by linarith ⟩, ⟨ 1, by linarith ⟩ ⟩, by simp +decide [ distinctPairs ] ⟩

lemma mem_distinctPairs {n : ℕ} {p : Fin n × Fin n} :
    p ∈ distinctPairs n ↔ p.1 ≠ p.2 := by
  unfold distinctPairs; aesop;

lemma univ_product_nonempty {n : ℕ} (hn : 1 ≤ n) :
    (Finset.univ : Finset (Fin n × Fin n)).Nonempty := by
  exact ⟨ ⟨ ⟨ 0, by linarith ⟩, ⟨ 0, by linarith ⟩ ⟩, Finset.mem_univ _ ⟩

theorem exSlack_diag_eq {n : ℕ} (W : Matrix (Fin n) (Fin n) ℝ)
    (i j : Fin n) :
    exSlack W i j i j = diagExSlack W i j := by
  simp [exSlack, diagExSlack]; ring

theorem tropMargin_of_two_le {n : ℕ} (hn : 2 ≤ n)
    (W : Matrix (Fin n) (Fin n) ℝ) :
    tropMargin W = (distinctPairs n).inf' (distinctPairs_nonempty hn)
      (fun p => diagExSlack W p.1 p.2) := by
  simp [tropMargin, dif_pos (distinctPairs_nonempty hn)]

theorem entrySupNorm_nonneg {n : ℕ} (W : Matrix (Fin n) (Fin n) ℝ) :
    0 ≤ entrySupNorm W := by
  -- By definition of `entrySupNorm`, we know that it is the supremum of the absolute values of the entries.
  unfold entrySupNorm;
  split_ifs <;> norm_num;
  exact ⟨ Classical.choose ‹_› |> Prod.fst ⟩

theorem abs_entry_le_entrySupNorm {n : ℕ} (_hn : 1 ≤ n)
    (W : Matrix (Fin n) (Fin n) ℝ) (i j : Fin n) :
    |W i j| ≤ entrySupNorm W := by
  unfold entrySupNorm;
  convert Finset.le_sup' ( fun p : Fin n × Fin n => |W p.1 p.2| ) ( Finset.mem_univ ( i, j ) ) using 1;
  grind +extAll

/-! ## Section 3: Theorem 1 — tropMargin = 2 * diagBias -/

/-
**Theorem 1.** The tropical margin equals twice the diagonal bias.
-/
theorem tropMargin_eq_two_diagBias {n : ℕ} (hn : 2 ≤ n)
    (W : Matrix (Fin n) (Fin n) ℝ) :
    tropMargin W = 2 * diagBias W := by
  convert tropMargin_of_two_le hn W;
  unfold diagBias diagExSlack;
  split_ifs <;> simp_all +decide [ Finset.inf'_eq_csInf_image, sub_sub ];
  rw [ ← smul_eq_mul, ← Real.sInf_smul_of_nonneg ] <;> norm_num;
  congr! 1;
  ext; simp [Set.mem_smul_set, Set.mem_image];
  exact ⟨ fun ⟨ a, b, h, h' ⟩ => ⟨ a, b, h, by linear_combination h' ⟩, fun ⟨ a, b, h, h' ⟩ => ⟨ a, b, h, by linear_combination h' ⟩ ⟩

/-! ## Section 4: Theorem 2 — Lipschitz stability -/

theorem diagExSlack_sub_bound {n : ℕ} (hn : 1 ≤ n)
    (W W' : Matrix (Fin n) (Fin n) ℝ) (i j : Fin n) :
    |diagExSlack W i j - diagExSlack W' i j| ≤ 4 * entrySupNorm (W - W') := by
  convert abs_le.mpr ?_ using 1;
  · infer_instance;
  · constructor <;> have := abs_entry_le_entrySupNorm hn ( W - W' ) i j <;> have := abs_entry_le_entrySupNorm hn ( W - W' ) i i <;> have := abs_entry_le_entrySupNorm hn ( W - W' ) j j <;> norm_num [ abs_le ] at *; all_goals unfold diagExSlack; linarith;

/-
**Theorem 2.** Lipschitz stability of tropMargin.
-/
theorem tropMargin_lipschitz {n : ℕ} (hn : 2 ≤ n)
    (W W' : Matrix (Fin n) (Fin n) ℝ) :
    |tropMargin W - tropMargin W'| ≤ 4 * entrySupNorm (W - W') := by
  have h_tropMargin_W : tropMargin W = (distinctPairs n).inf' (distinctPairs_nonempty hn) (fun p => diagExSlack W p.1 p.2) := by
    exact?
  have h_tropMargin_W' : tropMargin W' = (distinctPairs n).inf' (distinctPairs_nonempty hn) (fun p => diagExSlack W' p.1 p.2) := by
    grind +suggestions;
  rw [ h_tropMargin_W, h_tropMargin_W', abs_sub_le_iff ];
  constructor <;> obtain ⟨ p, hp₁, hp₂ ⟩ := Finset.exists_mem_eq_inf' ( distinctPairs_nonempty hn ) ( fun p => diagExSlack W p.1 p.2 ) <;> obtain ⟨ q, hq₁, hq₂ ⟩ := Finset.exists_mem_eq_inf' ( distinctPairs_nonempty hn ) ( fun p => diagExSlack W' p.1 p.2 ) <;> norm_num at *;
  · use q.1, q.2;
    exact ⟨ hq₁, by linarith [ abs_le.mp ( diagExSlack_sub_bound ( by linarith ) W W' q.1 q.2 ) ] ⟩;
  · exact ⟨ p.1, p.2, hp₁, by linarith [ show diagExSlack W' p.1 p.2 ≤ 4 * entrySupNorm ( W - W' ) + diagExSlack W p.1 p.2 by linarith [ abs_le.mp ( diagExSlack_sub_bound ( by linarith ) W W' p.1 p.2 ) ] ] ⟩

/-! ## Section 5: Theorem 3 — Signal/noise decomposition -/

theorem entrySupNorm_neg {n : ℕ} (W : Matrix (Fin n) (Fin n) ℝ) :
    entrySupNorm (-W) = entrySupNorm W := by
  unfold entrySupNorm;
  simp +decide [ abs_neg ]

/-
**Theorem 3.** Signal/noise lower bound for tropMargin.
-/
theorem tropMargin_lower_bound_signal_noise {n : ℕ} (hn : 2 ≤ n)
    (S N : Matrix (Fin n) (Fin n) ℝ) :
    tropMargin S - 4 * entrySupNorm N ≤ tropMargin (S + N) := by
  have := @tropMargin_lipschitz n hn ( S + N ) S;
  norm_num at * ; linarith only [ abs_le.mp this ] ;

/-- **Theorem 3'.** Positive margin from signal dominance. -/
theorem tropMargin_pos_of_signal_noise {n : ℕ} (hn : 2 ≤ n)
    (S N : Matrix (Fin n) (Fin n) ℝ)
    (h : 4 * entrySupNorm N < tropMargin S) :
    0 < tropMargin (S + N) := by
  linarith [tropMargin_lower_bound_signal_noise hn S N]

/-! ## Section 6: Theorem 4 — Mean model exact computation -/

theorem diagExSlack_meanModel {n : ℕ} (μdiag μoff : ℝ)
    (i j : Fin n) (hij : i ≠ j) :
    diagExSlack (meanModel n μdiag μoff) i j = 2 * (μoff - μdiag) := by
  unfold diagExSlack meanModel; norm_num [ hij ] ; ring;

/-
**Theorem 4.** Exact tropical margin of the mean model.
-/
theorem tropMargin_meanModel {n : ℕ} (hn : 2 ≤ n) (μdiag μoff : ℝ) :
    tropMargin (meanModel n μdiag μoff) = 2 * (μoff - μdiag) := by
  -- Since the function is constant over distinct pairs, the infimum is trivially that constant.
  have h_const : ∀ p ∈ distinctPairs n, diagExSlack (meanModel n μdiag μoff) p.1 p.2 = 2 * (μoff - μdiag) := by
    exact fun p hp => diagExSlack_meanModel μdiag μoff p.1 p.2 <| by simpa using mem_distinctPairs.mp hp;
  rw [ tropMargin_of_two_le hn, Finset.inf'_eq_csInf_image ];
  exact le_antisymm ( csInf_le ⟨ 2 * ( μoff - μdiag ), by rintro x ⟨ p, hp, rfl ⟩ ; exact h_const p hp ▸ le_rfl ⟩ ⟨ Classical.choose ( distinctPairs_nonempty hn ), Classical.choose_spec ( distinctPairs_nonempty hn ), h_const _ ( Classical.choose_spec ( distinctPairs_nonempty hn ) ) ⟩ ) ( le_csInf ⟨ _, ⟨ Classical.choose ( distinctPairs_nonempty hn ), Classical.choose_spec ( distinctPairs_nonempty hn ), rfl ⟩ ⟩ <| by rintro x ⟨ p, hp, rfl ⟩ ; exact h_const p hp ▸ le_rfl )

/-! ## Section 7: Theorem 5 — Ferromagnetic monotonicity -/

theorem diagExSlack_mono_offdiag {n : ℕ}
    (W W' : Matrix (Fin n) (Fin n) ℝ)
    (hmono : OffDiagMonotoneLe W W')
    (i j : Fin n) (hij : i ≠ j) :
    diagExSlack W i j ≤ diagExSlack W' i j := by
  unfold diagExSlack;
  linarith [ hmono.1 i, hmono.1 j, hmono.2 i j hij ]

/-
**Theorem 5.** Ferromagnetic monotonicity of tropMargin.
-/
theorem tropMargin_mono_offdiag {n : ℕ}
    (W W' : Matrix (Fin n) (Fin n) ℝ)
    (hmono : OffDiagMonotoneLe W W') :
    tropMargin W ≤ tropMargin W' := by
  rcases n with ( _ | _ | n ) <;> simp_all +decide [ tropMargin ];
  grind +suggestions

/-! ## Section 8: Certified stability estimator -/

/-
Certified stability bound: margin of perturbed mean model ≥ 2(μoff-μdiag) - 4ε.
-/
theorem certified_stability_bound {n : ℕ} (hn : 2 ≤ n)
    (μdiag μoff ε : ℝ) (N : Matrix (Fin n) (Fin n) ℝ)
    (hε : entrySupNorm N ≤ ε) :
    2 * (μoff - μdiag) - 4 * ε ≤ tropMargin (meanModel n μdiag μoff + N) := by
  have := tropMargin_lower_bound_signal_noise hn ( meanModel n μdiag μoff ) N;
  linarith [ show tropMargin ( meanModel n μdiag μoff ) = 2 * ( μoff - μdiag ) from tropMargin_meanModel hn μdiag μoff ]

/-! ## Section 9: Witness extraction -/

/-
There exists a witness pair achieving `tropMargin`.
-/
theorem tropMargin_witness {n : ℕ} (hn : 2 ≤ n)
    (W : Matrix (Fin n) (Fin n) ℝ) :
    ∃ i j : Fin n, i ≠ j ∧ tropMargin W = diagExSlack W i j := by
  -- By definition of tropMargin, we know that it is the infimum of the diagonal exchange slacks over distinct pairs.
  unfold tropMargin;
  split_ifs <;> simp_all +decide [ Finset.inf'_eq_csInf_image ];
  · -- By definition of infimum, there exists a pair (i, j) in the distinctPairs set such that the diagonal exchange slack for this pair is equal to the infimum.
    obtain ⟨p, hp⟩ : ∃ p ∈ distinctPairs n, diagExSlack W p.1 p.2 = sInf (Set.image (fun p : Fin n × Fin n => diagExSlack W p.1 p.2) (distinctPairs n)) := by
      exact ( IsCompact.sInf_mem ( Set.Finite.isCompact <| Set.toFinite _ ) <| Set.Nonempty.image _ <| by assumption );
    grind +suggestions;
  · exact absurd ‹distinctPairs n = ∅› ( Finset.Nonempty.ne_empty ( distinctPairs_nonempty hn ) )

/-! ## Section 10: Sublevel set nesting -/

theorem stable_region_nesting {n : ℕ} (t₁ t₂ : ℝ) (ht : t₁ ≤ t₂)
    (W : Matrix (Fin n) (Fin n) ℝ) (h : t₂ ≤ tropMargin W) :
    t₁ ≤ tropMargin W :=
  le_trans ht h

end TropicalPhaseTransition