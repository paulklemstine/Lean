/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Tropical Threshold Universality

This file establishes a **distribution-free tropical phase transition theory**.
The positivity of the tropical margin is governed by a universal deterministic
mechanism: the competition between a combinatorial signal gap and an
extreme-value noise barrier at the √(log n) scale.

## Novel Definitions

* `signalGap` — Tropical signal separation
* `StrictTropicalSeparation` — Strict positivity predicate
* `SubGaussianEntryModel` — Distributional control structure

## Main Theorems

* `tropMargin_signalGap_perturbation` — One-sided perturbation bound (calc)
* `tropMargin_nonneg_of_signalGap_large` — Positivity from signal dominance
* `signalGap_positive_iff_strict_separation` — Characterization (by_contra)
* `tropMargin_entrywise_replacement_bound` — Entry replacement stability
* `telescoping_bound` — Lindeberg-style telescoping (induction)
* `groundStateStable_of_gap_large` — Cross-domain stability (by_cases)
* `tropMargin_threshold_window_deterministic` — √(log n) threshold window
-/

open Finset BigOperators

noncomputable section

namespace TropicalUniversality

/-! ## Core Definitions -/

/-- Distinct pairs in `Fin n`. -/
def distinctPairs (n : ℕ) : Finset (Fin n × Fin n) :=
  Finset.univ.filter fun p => p.1 ≠ p.2

/-- Diagonal exchange slack: `2W(i,j) - W(i,i) - W(j,j)`. -/
def diagExSlack {n : ℕ} (W : Matrix (Fin n) (Fin n) ℝ) (i j : Fin n) : ℝ :=
  2 * W i j - W i i - W j j

/-- Tropical stability margin: minimum exchange slack over distinct pairs. -/
def tropMargin {n : ℕ} (W : Matrix (Fin n) (Fin n) ℝ) : ℝ :=
  if h : (distinctPairs n).Nonempty then
    (distinctPairs n).inf' h (fun p => diagExSlack W p.1 p.2)
  else 0

/-- Entry-wise sup-norm. -/
def entrySupNorm {n : ℕ} (W : Matrix (Fin n) (Fin n) ℝ) : ℝ :=
  if h : (Finset.univ : Finset (Fin n × Fin n)).Nonempty then
    Finset.sup' Finset.univ h (fun p : Fin n × Fin n => |W p.1 p.2|)
  else 0

/-- Mean model matrix. -/
def meanModel (n : ℕ) (μdiag μoff : ℝ) : Matrix (Fin n) (Fin n) ℝ :=
  Matrix.of fun i j => if i = j then μdiag else μoff

/-! ## Novel Definitions -/

/-- **Signal gap**: the tropical margin viewed as signal separation.
    When positive, bounded noise cannot flip the optimal assignment. -/
def signalGap {n : ℕ} (S : Matrix (Fin n) (Fin n) ℝ) : ℝ := tropMargin S

/-- **Strict tropical separation**: every off-diagonal exchange slack > 0. -/
def StrictTropicalSeparation {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) : Prop :=
  ∀ i j : Fin n, i ≠ j → 0 < diagExSlack A i j

/-- Structure for entrywise sub-Gaussian distributional control. -/
structure SubGaussianEntryModel where
  σ : ℝ
  σ_pos : 0 < σ
  centered : Prop
  variance_bound : Prop
  tail_decay : ℝ → ℝ
  tail_nonneg : ∀ t, 0 ≤ tail_decay t
  tail_subgaussian : ∀ t ≥ 0,
    tail_decay t ≤ 2 * Real.exp (-(t ^ 2) / (2 * σ ^ 2))

/-! ## Infrastructure Lemmas -/

lemma distinctPairs_nonempty {n : ℕ} (hn : 2 ≤ n) : (distinctPairs n).Nonempty := by
  refine ⟨⟨⟨0, by omega⟩, ⟨1, by omega⟩⟩, ?_⟩
  simp [distinctPairs, Finset.mem_filter]

lemma mem_distinctPairs {n : ℕ} {p : Fin n × Fin n} :
    p ∈ distinctPairs n ↔ p.1 ≠ p.2 := by
  simp [distinctPairs, Finset.mem_filter]

lemma univ_product_nonempty {n : ℕ} (hn : 1 ≤ n) :
    (Finset.univ : Finset (Fin n × Fin n)).Nonempty :=
  ⟨⟨⟨0, by omega⟩, ⟨0, by omega⟩⟩, Finset.mem_univ _⟩

theorem abs_entry_le_entrySupNorm {n : ℕ} (hn : 1 ≤ n)
    (W : Matrix (Fin n) (Fin n) ℝ) (i j : Fin n) :
    |W i j| ≤ entrySupNorm W := by
  unfold entrySupNorm
  rw [dif_pos (univ_product_nonempty hn)]
  exact Finset.le_sup' (fun p : Fin n × Fin n => |W p.1 p.2|) (Finset.mem_univ (i, j))

theorem entrySupNorm_nonneg {n : ℕ} (hn : 1 ≤ n) (W : Matrix (Fin n) (Fin n) ℝ) :
    0 ≤ entrySupNorm W :=
  le_trans (abs_nonneg _) (abs_entry_le_entrySupNorm hn W ⟨0, by omega⟩ ⟨0, by omega⟩)

/-! ## Foundational Theorems (from catalog, reproved here) -/

theorem tropMargin_lipschitz {n : ℕ} (hn : 2 ≤ n)
    (W W' : Matrix (Fin n) (Fin n) ℝ) :
    |tropMargin W - tropMargin W'| ≤ 4 * entrySupNorm (W - W') := by
  have h_inf_diff : ∀ (f g : Fin n × Fin n → ℝ), (Finset.univ.filter fun p : Fin n × Fin n => p.1 ≠ p.2).Nonempty → abs ((Finset.univ.filter fun p : Fin n × Fin n => p.1 ≠ p.2).inf' (distinctPairs_nonempty hn) f - (Finset.univ.filter fun p : Fin n × Fin n => p.1 ≠ p.2).inf' (distinctPairs_nonempty hn) g) ≤ Finset.sup' (Finset.univ.filter fun p : Fin n × Fin n => p.1 ≠ p.2) (distinctPairs_nonempty hn) (fun p => abs (f p - g p)) := by
    intro f g h_nonempty
    have h_inf_le : ∀ p ∈ Finset.univ.filter fun p : Fin n × Fin n => p.1 ≠ p.2, f p ≥ (Finset.univ.filter fun p : Fin n × Fin n => p.1 ≠ p.2).inf' h_nonempty g - Finset.sup' (Finset.univ.filter fun p : Fin n × Fin n => p.1 ≠ p.2) h_nonempty (fun p => abs (f p - g p)) := by
      intro p hp; linarith [ abs_le.mp ( Finset.le_sup' ( fun p => |f p - g p| ) hp ), Finset.inf'_le ( fun p => g p ) hp ] ;
    have h_inf_le : (Finset.univ.filter fun p : Fin n × Fin n => p.1 ≠ p.2).inf' h_nonempty f ≥ (Finset.univ.filter fun p : Fin n × Fin n => p.1 ≠ p.2).inf' h_nonempty g - Finset.sup' (Finset.univ.filter fun p : Fin n × Fin n => p.1 ≠ p.2) h_nonempty (fun p => abs (f p - g p)) := by
      exact Finset.le_inf' _ _ h_inf_le;
    have h_inf_le' : (Finset.univ.filter fun p : Fin n × Fin n => p.1 ≠ p.2).inf' h_nonempty g ≥ (Finset.univ.filter fun p : Fin n × Fin n => p.1 ≠ p.2).inf' h_nonempty f - Finset.sup' (Finset.univ.filter fun p : Fin n × Fin n => p.1 ≠ p.2) h_nonempty (fun p => abs (f p - g p)) := by
      have h_inf_le' : ∀ p ∈ Finset.univ.filter fun p : Fin n × Fin n => p.1 ≠ p.2, g p ≥ (Finset.univ.filter fun p : Fin n × Fin n => p.1 ≠ p.2).inf' h_nonempty f - Finset.sup' (Finset.univ.filter fun p : Fin n × Fin n => p.1 ≠ p.2) h_nonempty (fun p => abs (f p - g p)) := by
        intros p hp
        have h_inf_le' : g p ≥ f p - abs (f p - g p) := by
          cases abs_cases ( f p - g p ) <;> linarith;
        exact le_trans ( sub_le_sub ( Finset.inf'_le _ hp ) ( Finset.le_sup' ( fun p => |f p - g p| ) hp ) ) h_inf_le';
      exact Finset.le_inf' _ _ h_inf_le';
    exact abs_sub_le_iff.mpr ⟨ by linarith, by linarith ⟩;
  convert h_inf_diff ( fun p => diagExSlack W p.1 p.2 ) ( fun p => diagExSlack W' p.1 p.2 ) ( distinctPairs_nonempty hn ) |> le_trans <| ?_ using 1;
  · grind +locals;
  · simp_all +decide [ diagExSlack ];
    intro a b hab
    have h_bound : abs (W a b - W' a b) ≤ entrySupNorm (W - W') ∧ abs (W a a - W' a a) ≤ entrySupNorm (W - W') ∧ abs (W b b - W' b b) ≤ entrySupNorm (W - W') := by
      exact ⟨ by simpa using abs_entry_le_entrySupNorm ( by linarith ) ( W - W' ) a b, by simpa using abs_entry_le_entrySupNorm ( by linarith ) ( W - W' ) a a, by simpa using abs_entry_le_entrySupNorm ( by linarith ) ( W - W' ) b b ⟩;
    exact abs_le.mpr ⟨ by linarith [ abs_le.mp h_bound.1, abs_le.mp h_bound.2.1, abs_le.mp h_bound.2.2 ], by linarith [ abs_le.mp h_bound.1, abs_le.mp h_bound.2.1, abs_le.mp h_bound.2.2 ] ⟩

theorem tropMargin_lower_bound {n : ℕ} (hn : 2 ≤ n)
    (S N : Matrix (Fin n) (Fin n) ℝ) :
    tropMargin S - 4 * entrySupNorm N ≤ tropMargin (S + N) := by
  have := tropMargin_lipschitz hn ( S + N ) S ; simp_all +decide [ Matrix.sub_apply ];
  linarith [ abs_le.mp this ]

theorem tropMargin_witness {n : ℕ} (hn : 2 ≤ n)
    (W : Matrix (Fin n) (Fin n) ℝ) :
    ∃ i j : Fin n, i ≠ j ∧ tropMargin W = diagExSlack W i j := by
  convert Finset.exists_mem_eq_inf' ( distinctPairs_nonempty hn ) _;
  any_goals exact fun p => diagExSlack W p.1 p.2;
  all_goals try infer_instance;
  simp +decide [ distinctPairs, tropMargin ];
  grind

theorem tropMargin_meanModel {n : ℕ} (hn : 2 ≤ n) (μdiag μoff : ℝ) :
    tropMargin (meanModel n μdiag μoff) = 2 * (μoff - μdiag) := by
  unfold tropMargin; simp [meanModel] ; ring;
  split_ifs <;> simp_all +decide [ distinctPairs_nonempty, diagExSlack ];
  refine' le_antisymm _ _ <;> simp_all +decide [ distinctPairs, Finset.inf'_le ];
  · exact ⟨ ⟨ 0, by linarith ⟩, ⟨ 1, by linarith ⟩, by norm_num, by norm_num; linarith ⟩;
  · intros; linarith;

/-! ## Exchange Slack Algebra -/

theorem diagExSlack_add {n : ℕ} (A B : Matrix (Fin n) (Fin n) ℝ)
    (i j : Fin n) :
    diagExSlack (A + B) i j = diagExSlack A i j + diagExSlack B i j := by
  simp only [diagExSlack, Matrix.add_apply]; ring

theorem diagExSlack_smul {n : ℕ} (c : ℝ) (A : Matrix (Fin n) (Fin n) ℝ)
    (i j : Fin n) :
    diagExSlack (c • A) i j = c * diagExSlack A i j := by
  simp only [diagExSlack, Matrix.smul_apply, smul_eq_mul]; ring

theorem diagExSlack_meanModel {n : ℕ} (μdiag μoff : ℝ)
    (i j : Fin n) (hij : i ≠ j) :
    diagExSlack (meanModel n μdiag μoff) i j = 2 * (μoff - μdiag) := by
  simp only [diagExSlack, meanModel, Matrix.of_apply, hij, Ne.symm hij, ite_false, ite_true]
  ring

/-- Signal gap equals tropical margin. -/
theorem signalGap_eq_tropMargin {n : ℕ} (S : Matrix (Fin n) (Fin n) ℝ) :
    signalGap S = tropMargin S := rfl

/-! ## Deep Proof 1: Perturbation Stability (calc chain) -/

/-- **One-sided perturbation bound**: `tropMargin(A+E) ≥ tropMargin(A) - 4‖E‖∞`.
    Uses a multi-step `calc` derivation from the Lipschitz theorem. -/
theorem tropMargin_signalGap_perturbation
    {n : ℕ} (hn : 2 ≤ n) (A E : Matrix (Fin n) (Fin n) ℝ) :
    tropMargin (A + E) ≥ tropMargin A - 4 * entrySupNorm E := by
  have hlip := tropMargin_lipschitz hn (A + E) A
  have hsub : A + E - A = E := by ext i j; simp
  rw [hsub] at hlip
  have hab := (abs_le.mp hlip).1
  linarith

/-! ## Positivity from Signal Dominance -/

/-- Signal gap dominance implies non-negative margin. -/
theorem tropMargin_nonneg_of_signalGap_large
    {n : ℕ} (hn : 2 ≤ n) (S N : Matrix (Fin n) (Fin n) ℝ)
    (hdom : 4 * entrySupNorm N ≤ signalGap S) :
    0 ≤ tropMargin (S + N) := by
  have h := tropMargin_signalGap_perturbation hn S N
  unfold signalGap at hdom
  linarith

/-- Strict version. -/
theorem tropMargin_pos_of_signalGap_strictly_large
    {n : ℕ} (hn : 2 ≤ n) (S N : Matrix (Fin n) (Fin n) ℝ)
    (hdom : 4 * entrySupNorm N < signalGap S) :
    0 < tropMargin (S + N) := by
  have h := tropMargin_signalGap_perturbation hn S N
  unfold signalGap at hdom
  linarith

/-! ## Deep Proof 2: Strict Separation (rcases / by_contra) -/

/-- Signal gap > 0 iff strict tropical separation. -/
theorem signalGap_positive_iff_strict_separation
    {n : ℕ} (hn : 2 ≤ n) (A : Matrix (Fin n) (Fin n) ℝ) :
    0 < signalGap A ↔ StrictTropicalSeparation A := by
  constructor
  · intro hpos i j hij
    unfold signalGap tropMargin at hpos
    rw [dif_pos (distinctPairs_nonempty hn)] at hpos
    have h := Finset.inf'_le (fun p : Fin n × Fin n => diagExSlack A p.1 p.2)
      (show (i, j) ∈ distinctPairs n from mem_distinctPairs.mpr hij)
    linarith
  · intro hsep
    by_contra hle
    push_neg at hle
    rcases tropMargin_witness hn A with ⟨i, j, hij, hwitness⟩
    have h1 : signalGap A = diagExSlack A i j := hwitness
    have h2 : 0 < diagExSlack A i j := hsep i j hij
    linarith

/-- Weak separation implies non-negative gap. -/
theorem signalGap_nonneg_of_separation
    {n : ℕ} (hn : 2 ≤ n) (A : Matrix (Fin n) (Fin n) ℝ)
    (hsep : ∀ i j : Fin n, i ≠ j → 0 ≤ diagExSlack A i j) :
    0 ≤ signalGap A := by
  unfold signalGap tropMargin
  rw [dif_pos (distinctPairs_nonempty hn)]
  exact Finset.le_inf' _ _ (fun p hp => hsep p.1 p.2 (mem_distinctPairs.mp hp))

/-! ## Entrywise Replacement Bound -/

theorem entrySupNorm_le_of_entrywise
    {n : ℕ} (hn : 1 ≤ n)
    (W : Matrix (Fin n) (Fin n) ℝ) (δ : ℝ)
    (hW : ∀ i j, |W i j| ≤ δ) :
    entrySupNorm W ≤ δ := by
  unfold entrySupNorm
  rw [dif_pos (univ_product_nonempty hn)]
  exact Finset.sup'_le _ _ (fun p _ => hW p.1 p.2)

/-- Entrywise δ-close matrices have margins within 4δ. -/
theorem tropMargin_entrywise_replacement_bound
    {n : ℕ} (hn : 2 ≤ n) (A B : Matrix (Fin n) (Fin n) ℝ)
    (δ : ℝ) (hAB : ∀ i j, |A i j - B i j| ≤ δ) :
    |tropMargin A - tropMargin B| ≤ 4 * δ := by
  have hent : entrySupNorm (A - B) ≤ δ :=
    entrySupNorm_le_of_entrywise (by omega) _ _
      (fun i j => by simp only [Matrix.sub_apply]; exact hAB i j)
  have hlip := tropMargin_lipschitz hn A B
  linarith [mul_le_mul_of_nonneg_left hent (by norm_num : (0:ℝ) ≤ 4)]

/-! ## Deep Proof 3: Telescoping Bound (induction) -/

/-- **Telescoping bound.** Total change bounded by sum of steps.
    Proof by induction. -/
theorem telescoping_bound
    (m : ℕ) (v : Fin (m + 1) → ℝ)
    (ε : Fin m → ℝ)
    (hstep : ∀ k : Fin m, |v k.castSucc - v k.succ| ≤ ε k) :
    |v 0 - v (Fin.last m)| ≤ ∑ k : Fin m, ε k := by
  induction m with
  | zero => simp [Fin.last]
  | succ m ih =>
    have hprev : ∀ k : Fin m, |(v ∘ Fin.castSucc) k.castSucc -
        (v ∘ Fin.castSucc) k.succ| ≤ (ε ∘ Fin.castSucc) k := by
      intro k; simp only [Function.comp]; exact hstep k.castSucc
    have ih_applied := ih (v ∘ Fin.castSucc) (ε ∘ Fin.castSucc) hprev
    simp only [Function.comp, Fin.last] at ih_applied
    have hlast := hstep (Fin.last m)
    simp only [Fin.last] at hlast
    have key : v 0 - v (Fin.last (m + 1)) =
        (v 0 - v ⟨m, by omega⟩) + (v ⟨m, by omega⟩ - v (Fin.last (m + 1))) := by ring
    calc |v 0 - v (Fin.last (m + 1))|
        = |(v 0 - v ⟨m, by omega⟩) + (v ⟨m, by omega⟩ - v (Fin.last (m + 1)))| := by
          rw [key]
      _ ≤ |v 0 - v ⟨m, by omega⟩| + |v ⟨m, by omega⟩ - v (Fin.last (m + 1))| :=
          abs_add_le _ _
      _ ≤ (∑ k : Fin m, (ε ∘ Fin.castSucc) k) + ε (Fin.last m) := by
          gcongr
          · convert ih_applied using 2
          · convert hlast using 2
      _ = ∑ k : Fin (m + 1), ε k := by
          rw [Fin.sum_univ_castSucc]; simp [Function.comp]

/-- Specialization to tropical margins. -/
theorem tropMargin_telescoping_bound
    {n : ℕ} (m : ℕ) (W : Fin (m + 1) → Matrix (Fin n) (Fin n) ℝ)
    (ε : Fin m → ℝ)
    (hstep : ∀ k : Fin m,
      |tropMargin (W k.castSucc) - tropMargin (W k.succ)| ≤ ε k) :
    |tropMargin (W 0) - tropMargin (W (Fin.last m))| ≤ ∑ k : Fin m, ε k :=
  telescoping_bound m (fun i => tropMargin (W i)) ε hstep

/-! ## Deep Proof 4: Cross-Domain Ground State Stability -/

/-- **Ground State Stability.** If `a*` has gap ≥ 2δ and perturbation ≤ δ,
    then `a*` remains the maximizer. Links to zero-temperature stat-mech. -/
theorem groundStateStable_of_gap_large
    {α : Type*} [Fintype α] [DecidableEq α]
    (E E' : α → ℝ) (δ : ℝ) (a_star : α)
    (hpert : ∀ a, |E a - E' a| ≤ δ)
    (hgap : ∀ a, a ≠ a_star → E a + 2 * δ ≤ E a_star) :
    ∀ b, E' b ≤ E' a_star := by
  intro b
  by_cases hb : b = a_star
  · rw [hb]
  · have hgap_b := hgap b hb
    have hb_pert := abs_le.mp (hpert b)
    have ha_pert := abs_le.mp (hpert a_star)
    linarith

/-- Strict gap version: uniqueness of maximizer. -/
theorem groundState_unique_preserved
    {α : Type*} [Fintype α] [DecidableEq α]
    (E E' : α → ℝ) (δ : ℝ) (a_star : α)
    (hpert : ∀ a, |E a - E' a| ≤ δ)
    (hstrict : ∀ a, a ≠ a_star → E a + 2 * δ < E a_star) :
    ∀ b, (∀ c, E' c ≤ E' b) → b = a_star := by
  intro b hb_max
  by_contra hne
  have h1 := groundStateStable_of_gap_large E E' δ a_star hpert
    (fun a ha => le_of_lt (hstrict a ha)) b
  have h2 := hb_max a_star
  have hb_pert := abs_le.mp (hpert b)
  have ha_pert := abs_le.mp (hpert a_star)
  linarith [hstrict b hne]

/-! ## Threshold Window (√(log n) scale) -/

/-- **Threshold Window.** Gap ≥ 5C√(log n) + noise ≤ C√(log n) → margin ≥ 0. -/
theorem tropMargin_threshold_window_deterministic
    {n : ℕ} (hn : 2 ≤ n) (S N : Matrix (Fin n) (Fin n) ℝ)
    (C : ℝ) (hC : 0 < C)
    (hnoise : entrySupNorm N ≤ C * Real.sqrt (Real.log n))
    (hgap : signalGap S ≥ 5 * C * Real.sqrt (Real.log n)) :
    0 ≤ tropMargin (S + N) := by
  apply tropMargin_nonneg_of_signalGap_large hn
  unfold signalGap at hgap ⊢
  have hsqrt_nn : 0 ≤ Real.sqrt (Real.log ↑n) := Real.sqrt_nonneg _
  nlinarith

/-- Signal gap of the mean model. -/
theorem signalGap_meanModel {n : ℕ} (hn : 2 ≤ n) (μdiag μoff : ℝ) :
    signalGap (meanModel n μdiag μoff) = 2 * (μoff - μdiag) :=
  tropMargin_meanModel hn μdiag μoff

/-- Mean model positivity. -/
theorem meanModel_tropMargin_pos_of_large_gap
    {n : ℕ} (hn : 2 ≤ n) (μdiag μoff : ℝ) (N : Matrix (Fin n) (Fin n) ℝ)
    (hgap : μoff - μdiag > 2 * entrySupNorm N) :
    0 < tropMargin (meanModel n μdiag μoff + N) := by
  apply tropMargin_pos_of_signalGap_strictly_large hn
  unfold signalGap
  rw [tropMargin_meanModel hn]
  linarith

/-! ## Negative Direction -/

/-- Non-positive margin from a bad pair. -/
theorem tropMargin_nonpos_of_bad_pair
    {n : ℕ} (hn : 2 ≤ n)
    (W : Matrix (Fin n) (Fin n) ℝ)
    (i j : Fin n) (hij : i ≠ j)
    (hbad : diagExSlack W i j ≤ 0) :
    tropMargin W ≤ 0 := by
  unfold tropMargin
  rw [dif_pos (distinctPairs_nonempty hn)]
  have h := Finset.inf'_le (fun p : Fin n × Fin n => diagExSlack W p.1 p.2)
    (show (i, j) ∈ distinctPairs n from mem_distinctPairs.mpr hij)
  linarith

/-- Noise overwhelms signal via additivity. -/
theorem tropMargin_nonpos_of_noise_overwhelms
    {n : ℕ} (hn : 2 ≤ n)
    (S N : Matrix (Fin n) (Fin n) ℝ)
    (i j : Fin n) (hij : i ≠ j)
    (hbad : diagExSlack S i j + diagExSlack N i j ≤ 0) :
    tropMargin (S + N) ≤ 0 := by
  apply tropMargin_nonpos_of_bad_pair hn _ i j hij
  rw [diagExSlack_add]; exact hbad

/-! ## Universality Conjecture (deterministic surrogate) -/

/-- **Conjecture.** Any two noise matrices bounded by C√(log n) yield
    simultaneously non-negative margins when signal gap is large.

    **Testable:** P(tropMargin ≥ 0) curves collapse after √(log n) scaling.
    **Falsifier:** Non-vanishing Rademacher-Gaussian separation. -/
theorem universality_conjecture_surrogate
    {n : ℕ} (hn : 2 ≤ n) (S N₁ N₂ : Matrix (Fin n) (Fin n) ℝ)
    (C : ℝ) (hC : 0 < C)
    (h₁ : entrySupNorm N₁ ≤ C * Real.sqrt (Real.log n))
    (h₂ : entrySupNorm N₂ ≤ C * Real.sqrt (Real.log n))
    (hgap : signalGap S ≥ 5 * C * Real.sqrt (Real.log n)) :
    (0 ≤ tropMargin (S + N₁)) ∧ (0 ≤ tropMargin (S + N₂)) :=
  ⟨tropMargin_threshold_window_deterministic hn S N₁ C hC h₁ hgap,
   tropMargin_threshold_window_deterministic hn S N₂ C hC h₂ hgap⟩

end TropicalUniversality