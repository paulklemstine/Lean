/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Tropical Satake Beatpath Robustness

This file formalizes a Schulze/beatpath aggregation layer on top of pairwise
tropical Hecke margins for `Fin 3`, and proves a certified robustness theorem
whose radius is governed by the minimum decisive beatpath gap.

## Main Results

* `beatpathStrengthN_lipschitz`: The beatpath closure is 1-Lipschitz with respect
  to uniform perturbations of edge weights.
* `unique_beatpath_winner_stable_of_half_gap`: A unique beatpath winner is preserved
  under perturbations smaller than half the decisive gap.
* `hecke_score_beatpath_stable_under_score_margin_perturbation`: Specialization to
  margins induced by tropical Satake Hecke scores.

## Mathematical Overview

The key mathematical content is that tropical Hecke score geometry induces a weighted
tournament. The Schulze winner is extracted by a max-min path closure, and the closure
is 1-Lipschitz with respect to uniform perturbations of edge weights. This gives a
certified multiclass decision rule distinct from top-2, Condorcet-by-raw-margins,
and score-gap rules.

The 1-Lipschitz property of max-min closure is a structural theorem about the
bottleneck semiring: the operations `min` and `max` are each nonexpansive in the
uniform metric, so any composition of them (including the transitive closure) is
also nonexpansive. This is the conceptual heart of the robustness certificate.
-/

import Mathlib

noncomputable section

open Finset

/-! ## Core Definitions -/

/-- A pairwise margin matrix on `Fin n`: `m i j` represents the margin of `i` over `j`. -/
def PairMargin (n : ℕ) := Fin n → Fin n → ℝ

/-- One step of the max-min (widest path) closure on `Fin 3`.
    Updates path strengths by considering all one-hop extensions. -/
def widemaxStep (m p : PairMargin 3) : PairMargin 3 :=
  fun i j => max (p i j)
    (max (min (p i 0) (m 0 j))
      (max (min (p i 1) (m 1 j))
        (min (p i 2) (m 2 j))))

/-- Iterated max-min closure. `beatpathIter m t` gives path strengths using
    paths of length at most `t + 1`. -/
def beatpathIter (m : PairMargin 3) : ℕ → PairMargin 3
  | 0 => m
  | t + 1 => widemaxStep m (beatpathIter m t)

/-- Beatpath strength matrix after `n = 3` iterations of closure.
    On `Fin 3`, this captures all simple paths (length ≤ 2), so it equals
    the true beatpath strength. -/
def beatpathStrengthN (m : PairMargin 3) : PairMargin 3 :=
  beatpathIter m 3

/-- Candidate `c` is a beatpath winner if it strictly dominates every rival
    in beatpath strength. -/
def IsBeatpathWinner (m : PairMargin 3) (c : Fin 3) : Prop :=
  ∀ d, d ≠ c → beatpathStrengthN m c d > beatpathStrengthN m d c

/-- Candidate `c` is the unique beatpath winner. -/
def UniqueBeatpathWinner (m : PairMargin 3) (c : Fin 3) : Prop :=
  IsBeatpathWinner m c ∧ ∀ d, IsBeatpathWinner m d → d = c

/-- Margin matrix induced by a score vector: `scoreMargin H i j = H i - H j`. -/
def scoreMargin (H : Fin 3 → ℝ) : PairMargin 3 :=
  fun i j => H i - H j

/-- Uniform perturbation bound on margin matrices. -/
def MarginPerturbBound (m m' : PairMargin 3) (ε : ℝ) : Prop :=
  ∀ i j, |m' i j - m i j| ≤ ε

/-- Lower bound on the decisive beatpath gap for candidate `c`. -/
def beatpathGapLB (m : PairMargin 3) (c : Fin 3) (γ : ℝ) : Prop :=
  ∀ d, d ≠ c → γ ≤ beatpathStrengthN m c d - beatpathStrengthN m d c

/-! ## Helper Lemmas: Lipschitz Properties of min and max -/

/-
`min` is 1-Lipschitz in the uniform metric.
-/
theorem min_abs_le_of_abs_le_abs_le
    {a a' b b' ε : ℝ}
    (ha : |a' - a| ≤ ε) (hb : |b' - b| ≤ ε) :
    |min a' b' - min a b| ≤ ε := by
  cases min_cases a' b' <;> cases min_cases a b <;> cases abs_cases ( min a' b' - min a b ) <;> cases abs_cases ( a' - a ) <;> cases abs_cases ( b' - b ) <;> linarith

/-
`max` is 1-Lipschitz in the uniform metric.
-/
theorem max_abs_le_of_abs_le_abs_le
    {a a' b b' ε : ℝ}
    (ha : |a' - a| ≤ ε) (hb : |b' - b| ≤ ε) :
    |max a' b' - max a b| ≤ ε := by
  cases max_cases a' b' <;> cases max_cases a b <;> exact abs_le.mpr ⟨ by linarith [ abs_le.mp ha, abs_le.mp hb ], by linarith [ abs_le.mp ha, abs_le.mp hb ] ⟩

/-! ## Beatpath Iteration Lipschitz Property -/

/-
The `widemaxStep` operation is 1-Lipschitz: if both the margin matrices
    and the current path matrices are pointwise ε-close, so is the result.
-/
theorem widemaxStep_lipschitz
    (m m' p p' : PairMargin 3) (ε : ℝ)
    (hm : ∀ i j, |m' i j - m i j| ≤ ε)
    (hp : ∀ i j, |p' i j - p i j| ≤ ε) :
    ∀ i j, |widemaxStep m' p' i j - widemaxStep m p i j| ≤ ε := by
  intros i j; unfold widemaxStep; exact (by
  apply_rules [ max_abs_le_of_abs_le_abs_le, min_abs_le_of_abs_le_abs_le ]);

/-
The beatpath iteration is 1-Lipschitz at every step.
-/
theorem beatpathIter_lipschitz
    (m m' : PairMargin 3) (ε : ℝ)
    (_hε : 0 ≤ ε)
    (hpert : MarginPerturbBound m m' ε) :
    ∀ t i j, |beatpathIter m' t i j - beatpathIter m t i j| ≤ ε := by
  intro t
  induction t with
  | zero => exact fun i j => hpert i j
  | succ t ih => exact fun i j => widemaxStep_lipschitz _ _ _ _ ε hpert ih i j

/-- **Beatpath strength is 1-Lipschitz** under uniform edge perturbations.
    This is the central stability theorem for the max-min closure. -/
theorem beatpathStrengthN_lipschitz
    (m m' : PairMargin 3) (ε : ℝ)
    (hε : 0 ≤ ε)
    (hpert : MarginPerturbBound m m' ε) :
    ∀ i j, |beatpathStrengthN m' i j - beatpathStrengthN m i j| ≤ ε := by
  exact beatpathIter_lipschitz m m' ε hε hpert 3

/-! ## Winner Uniqueness -/

/-
If `a` strictly dominates `b` in beatpath strength, then `b` cannot be
    a beatpath winner.
-/
theorem beatpath_winner_irrefl_asym
    (m : PairMargin 3) {a b : Fin 3}
    (ha : beatpathStrengthN m a b > beatpathStrengthN m b a) :
    ¬IsBeatpathWinner m b := by
  unfold IsBeatpathWinner;
  grind

/-
A candidate that strictly dominates all rivals in beatpath strength
    is the unique beatpath winner.
-/
theorem unique_beatpath_winner_of_strict_domination
    (m : PairMargin 3) (c : Fin 3)
    (hdom : ∀ d, d ≠ c → beatpathStrengthN m c d > beatpathStrengthN m d c) :
    UniqueBeatpathWinner m c := by
  exact ⟨ hdom, fun d hd => Classical.not_not.1 fun h => by have := hdom d h; exact ( beatpath_winner_irrefl_asym m this ) hd ⟩

/-! ## Gap Degradation and Winner Stability -/

/-
The beatpath gap degrades by at most `2ε` under an `ε`-perturbation.
-/
theorem beatpath_gap_degrades_by_two_eps
    (m m' : PairMargin 3) (ε : ℝ)
    (hε : 0 ≤ ε)
    (hpert : MarginPerturbBound m m' ε) :
    ∀ c d,
      (beatpathStrengthN m c d - beatpathStrengthN m d c) - 2 * ε
        ≤ beatpathStrengthN m' c d - beatpathStrengthN m' d c := by
  exact fun c d => by linarith [ abs_le.mp ( beatpathStrengthN_lipschitz m m' ε hε hpert c d ), abs_le.mp ( beatpathStrengthN_lipschitz m m' ε hε hpert d c ) ] ;

/-
A beatpath winner is preserved under perturbations smaller than half
    the decisive gap.
-/
theorem beatpath_winner_stable_of_half_gap
    (m m' : PairMargin 3) (c : Fin 3) (ε γ : ℝ)
    (hε : 0 ≤ ε)
    (hpert : MarginPerturbBound m m' ε)
    (hgap : ∀ d, d ≠ c → γ ≤ beatpathStrengthN m c d - beatpathStrengthN m d c)
    (hdec : 2 * ε < γ) :
    IsBeatpathWinner m' c := by
  exact fun d hd => by linarith [ beatpath_gap_degrades_by_two_eps m m' ε hε hpert c d, hgap d hd ] ;

/-
A unique beatpath winner is preserved under perturbations smaller than
    half the decisive gap.
-/
theorem unique_beatpath_winner_stable_of_half_gap
    (m m' : PairMargin 3) (c : Fin 3) (ε γ : ℝ)
    (hε : 0 ≤ ε)
    (hpert : MarginPerturbBound m m' ε)
    (hgap : ∀ d, d ≠ c → γ ≤ beatpathStrengthN m c d - beatpathStrengthN m d c)
    (hdec : 2 * ε < γ) :
    UniqueBeatpathWinner m' c := by
  exact ⟨beatpath_winner_stable_of_half_gap m m' c ε γ hε hpert hgap hdec,
    fun d hd => by
      by_contra h_contra
      have := hd c (Ne.symm h_contra)
      linarith [beatpath_gap_degrades_by_two_eps m m' ε hε hpert c d, hgap d h_contra]⟩

/-! ## Hecke Score Specialization -/

/-
If the beatpath gap for a Hecke-score-induced margin is positive,
    the candidate is the unique beatpath winner.
-/
theorem hecke_score_beatpath_unique_winner_of_positive_gap
    (H : Fin 3 → ℝ) (c : Fin 3) (γ : ℝ)
    (hgap : ∀ d, d ≠ c →
      γ ≤ beatpathStrengthN (scoreMargin H) c d - beatpathStrengthN (scoreMargin H) d c)
    (hγ : 0 < γ) :
    UniqueBeatpathWinner (scoreMargin H) c := by
  exact unique_beatpath_winner_of_strict_domination _ _ fun d hd => by linarith [ hgap d hd ] ;

/-
**Robust Schulze certificate for Hecke scores**: if the pairwise margins
    of two score vectors are ε-close and the beatpath gap exceeds 2ε,
    then the beatpath winner is preserved.
-/
theorem hecke_score_beatpath_stable_under_score_margin_perturbation
    (H H' : Fin 3 → ℝ) (c : Fin 3) (ε γ : ℝ)
    (hε : 0 ≤ ε)
    (hmargin : ∀ i j, |((H' i - H' j) - (H i - H j))| ≤ ε)
    (hgap : ∀ d, d ≠ c →
      γ ≤ beatpathStrengthN (scoreMargin H) c d -
           beatpathStrengthN (scoreMargin H) d c)
    (hdec : 2 * ε < γ) :
    UniqueBeatpathWinner (scoreMargin H') c := by
  apply_rules [ unique_beatpath_winner_stable_of_half_gap ]

/-
**Tropical Satake Schulze certificate**: the full pipeline from
    score perturbation to certified unique beatpath winner.
-/
theorem tropical_satake_schulze_certificate
    (x x' : Fin 3 → ℝ) (c : Fin 3) (ε γ : ℝ)
    (hε : 0 ≤ ε)
    (hmargin : ∀ i j, |((x' i - x' j) - (x i - x j))| ≤ ε)
    (hgap : ∀ d, d ≠ c →
      γ ≤ beatpathStrengthN (scoreMargin x) c d -
           beatpathStrengthN (scoreMargin x) d c)
    (hdec : 2 * ε < γ) :
    UniqueBeatpathWinner (scoreMargin x') c :=
  hecke_score_beatpath_stable_under_score_margin_perturbation x x' c ε γ hε hmargin hgap hdec

end