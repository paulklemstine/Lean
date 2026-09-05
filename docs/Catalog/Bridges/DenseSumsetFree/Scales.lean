import Mathlib
import Bridges.DenseSumsetFree.Basic
/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Avoidance at a given scale, and the logarithmic target

To compare the theorem proved here with the conjectural optimum we package the
statement "dense subsets of `[n]` avoiding all sumsets with summands of size
`≥ C · f n`" into a single predicate `AvoidanceAtScale f δ`.

* `avoidanceAtScale_mono` — avoidance at a smaller scale is a stronger statement;
* `avoidanceAtScale_log_cubed` — **proved**: avoidance at scale `(log n)³` holds
  for every density `δ < 1`;
* `LogScaleTarget` — the conjectural optimum, avoidance at scale `log n`
  (a *definition*, not a theorem: it is the open target of the mission);
* `logScaleTarget_imp_log_cubed` — the target is indeed stronger than what we
  prove, so the development is consistent with, and a step towards, it.
-/
import Bridges.DenseSumsetFree.TwoSummands
open Finset Pointwise

namespace DenseSumsetFree

/-- `AvoidanceAtScale f δ`: there is a constant `C > 0` such that for all
sufficiently large `n` there is `S ⊆ [n]` of density at least `δ` containing no
sumset `A + B` with `|A|, |B| ≥ C · f n`. -/
def AvoidanceAtScale (f : ℕ → ℝ) (δ : ℝ) : Prop :=
  ∃ C : ℝ, 0 < C ∧ ∃ N : ℕ, ∀ n : ℕ, N ≤ n →
    ∃ S : Finset ℕ, S ⊆ Finset.range n ∧ δ * n ≤ S.card ∧
      ∀ A B : Finset ℕ, C * f n ≤ A.card → C * f n ≤ B.card → ¬ A + B ⊆ S

/-- Avoidance at a pointwise smaller scale is stronger. -/
theorem avoidanceAtScale_mono {f g : ℕ → ℝ} {δ : ℝ} {N₀ : ℕ}
    (hfg : ∀ n, N₀ ≤ n → f n ≤ g n) (h : AvoidanceAtScale f δ) :
    AvoidanceAtScale g δ := by
  obtain ⟨C, hC0, N, hN⟩ := h
  refine ⟨C, hC0, max N N₀, fun n hn => ?_⟩
  obtain ⟨S, hSsub, hScard, hSavoid⟩ := hN n (le_trans (le_max_left _ _) hn)
  have hle : C * f n ≤ C * g n :=
    mul_le_mul_of_nonneg_left (hfg n (le_trans (le_max_right _ _) hn)) hC0.le
  exact ⟨S, hSsub, hScard,
    fun A B hA hB => hSavoid A B (by linarith) (by linarith)⟩

/-- **The theorem of this development, in scale form.** -/
theorem avoidanceAtScale_log_cubed (δ : ℝ) (hδ0 : 0 < δ) (hδ1 : δ < 1) :
    AvoidanceAtScale (fun n => (Real.log n) ^ 3) δ :=
  exists_dense_set_avoiding_polylog_sumsets δ hδ0 hδ1

/-- **The conjectural optimum** (a definition of the open target, not a claim):
dense subsets of `[n]` avoiding every sumset `A + B` with
`min(|A|, |B|) ≥ C log n`. -/
def LogScaleTarget (δ : ℝ) : Prop := AvoidanceAtScale (fun n => Real.log n) δ

/-- The logarithmic target implies the `(log n)³` statement proved here: the two
are compatible, and the target is the stronger one. -/
theorem logScaleTarget_imp_log_cubed {δ : ℝ} (h : LogScaleTarget δ) :
    AvoidanceAtScale (fun n => (Real.log n) ^ 3) δ := by
  refine avoidanceAtScale_mono (N₀ := 3) (fun n hn => ?_) h
  have hnR : (3:ℝ) ≤ (n : ℝ) := by exact_mod_cast hn
  have hlog1 : 1 ≤ Real.log n := by
    have h3 : (1:ℝ) < Real.log 3 := by
      rw [Real.lt_log_iff_exp_lt (by norm_num)]
      linarith [Real.exp_one_lt_d9]
    have : Real.log 3 ≤ Real.log n := Real.log_le_log (by norm_num) hnR
    linarith
  simpa using pow_le_pow_right₀ hlog1 (by norm_num : 1 ≤ 3)

/-- **The mission statement, verbatim, with the `(log n)³` threshold.**  For every
fixed `0 < δ < 1` there is `C > 0` such that for all sufficiently large `n` there
is `S ⊆ [n]` with `|S| ≥ δ n` and: for all finite `A, B ⊆ ℕ` with
`min(|A|, |B|) ≥ C (log n)³`, the sumset `A + B` is not contained in `S`. -/
theorem exists_dense_set_avoiding_sumsets_min (δ : ℝ) (hδ0 : 0 < δ) (hδ1 : δ < 1) :
    ∃ C : ℝ, 0 < C ∧ ∃ N : ℕ, ∀ n : ℕ, N ≤ n →
      ∃ S : Finset ℕ, S ⊆ Finset.range n ∧ δ * n ≤ S.card ∧
        ∀ A B : Finset ℕ, C * (Real.log n) ^ 3 ≤ (min A.card B.card : ℕ) →
          ¬ A + B ⊆ S := by
  obtain ⟨C, hC0, N, hN⟩ := exists_dense_set_avoiding_polylog_sumsets δ hδ0 hδ1
  refine ⟨C, hC0, N, fun n hn => ?_⟩
  obtain ⟨S, hSsub, hScard, hSavoid⟩ := hN n hn
  refine ⟨S, hSsub, hScard, fun A B hAB => hSavoid A B ?_ ?_⟩
  · exact le_trans hAB (by exact_mod_cast Nat.cast_le.2 (min_le_left _ _))
  · exact le_trans hAB (by exact_mod_cast Nat.cast_le.2 (min_le_right _ _))

end DenseSumsetFree