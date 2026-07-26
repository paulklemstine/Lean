/-
# Tropical Certified Robustness — Core Definitions and Per-Expert Lemmas

This module formalizes the core definitions for multiclass piecewise-linear
network robustness certification via logit-gap margins, and proves the
key analytic lemma: a positive score gap combined with a coordinatewise
Lipschitz bound implies decision stability under L∞ perturbation.
-/
import Mathlib

open Finset BigOperators Classical

noncomputable section

attribute [local instance] Classical.propDecidable

variable {n C d : ℕ} [NeZero C]

/-! ## Core Definitions -/

/-- A score vector `s` *decides* class `c` if `c` achieves the maximum score. -/
def decides (s : Fin C → ℝ) (c : Fin C) : Prop :=
  ∀ j : Fin C, s j ≤ s c

/-- Strict version: `c` is the unique maximizer. -/
def StrictDecides (s : Fin C → ℝ) (c : Fin C) : Prop :=
  ∀ j : Fin C, j ≠ c → s j < s c

/-- `StrictDecides` implies `decides`. -/
theorem StrictDecides.decides {s : Fin C → ℝ} {c : Fin C}
    (h : StrictDecides s c) : decides s c := by
  intro j
  by_cases hj : j = c
  · subst hj; exact le_refl _
  · exact le_of_lt (h j hj)

/-- `predicts f x c` means expert `f` predicts class `c` at input `x`. -/
def predicts (f : (Fin d → ℝ) → Fin C → ℝ) (x : Fin d → ℝ) (c : Fin C) : Prop :=
  decides (f x) c

/-- Helper to produce the nonemptiness witness for `univ.erase c` when `C ≥ 2`. -/
theorem erase_univ_nonempty (hC : 1 < C) (c : Fin C) :
    (Finset.univ (α := Fin C) |>.erase c).Nonempty := by
  have : Nontrivial (Fin C) := Fin.nontrivial_iff_two_le.mpr (by omega)
  rw [Finset.erase_nonempty (Finset.mem_univ c)]
  exact Finset.univ_nontrivial

/-- The score gap of class `c`: the margin by which `c` beats the runner-up. -/
def scoreGap (f : (Fin d → ℝ) → Fin C → ℝ) (x : Fin d → ℝ) (c : Fin C)
    (hC : 1 < C) : ℝ :=
  f x c - Finset.sup' (Finset.univ.erase c) (erase_univ_nonempty hC c) (fun j => f x j)

/-- Vote count: number of experts predicting class `c` at input `x`. -/
def voteCount (F : Fin n → (Fin d → ℝ) → Fin C → ℝ) (x : Fin d → ℝ) (c : Fin C) : ℕ :=
  ((Finset.univ : Finset (Fin n)).filter (fun i => decides (F i x) c)).card

/-- The set of experts that vote for class `c` at input `x`. -/
def winnerVoters (F : Fin n → (Fin d → ℝ) → Fin C → ℝ) (x : Fin d → ℝ) (c : Fin C) :
    Finset (Fin n) :=
  Finset.univ.filter (fun i => decides (F i x) c)

/-- `voteCount` equals the cardinality of `winnerVoters`. -/
theorem voteCount_eq_card_winnerVoters (F : Fin n → (Fin d → ℝ) → Fin C → ℝ)
    (x : Fin d → ℝ) (c : Fin C) :
    voteCount F x c = (winnerVoters F x c).card := by
  rfl

/-- L∞ ball predicate. -/
def InLInfBall (x z : Fin d → ℝ) (r : ℝ) : Prop :=
  ∀ k, |z k - x k| ≤ r

/-- Coordinatewise Lipschitz bound. -/
def CoordLipschitz (f : (Fin d → ℝ) → Fin C → ℝ) (K : ℝ) : Prop :=
  ∀ x z c, |f z c - f x c| ≤ K * (∑ k : Fin d, |z k - x k|)

/-! ## Key Analytic Lemma: L∞ ball sum bound -/

/-
Sum of absolute coordinate differences is at most `d * r` on an L∞ ball.
-/
theorem sum_abs_sub_le_dim_mul_linf
    {d : ℕ} (x z : Fin d → ℝ) (r : ℝ)
    (hball : InLInfBall x z r) :
    ∑ k : Fin d, |z k - x k| ≤ (d : ℝ) * r := by
  exact le_trans ( Finset.sum_le_sum fun _ _ => hball _ ) ( by simp +decide )

/-! ## Key Analytic Lemma: decision stability under Lipschitz perturbation -/

/-
Auxiliary: Lipschitz bound gives a lower bound on f z c.
-/
theorem lip_lower {C d : ℕ} [NeZero C]
    (f : (Fin d → ℝ) → Fin C → ℝ) (K : ℝ) (x z : Fin d → ℝ) (c : Fin C)
    (_hK : 0 ≤ K)
    (hLip : CoordLipschitz f K) :
    f x c - K * (∑ k : Fin d, |z k - x k|) ≤ f z c := by
  linarith [ abs_le.mp ( hLip x z c ) ]

/-
Auxiliary: Lipschitz bound gives an upper bound on f z j.
-/
theorem lip_upper {C d : ℕ} [NeZero C]
    (f : (Fin d → ℝ) → Fin C → ℝ) (K : ℝ) (x z : Fin d → ℝ) (j : Fin C)
    (_hK : 0 ≤ K)
    (hLip : CoordLipschitz f K) :
    f z j ≤ f x j + K * (∑ k : Fin d, |z k - x k|) := by
  linarith [ abs_le.mp ( hLip x z j ) ]

/-
The sup' over `univ.erase c` is at most every element outside `c`.
-/
theorem sup'_erase_le {C : ℕ} [NeZero C] (s : Fin C → ℝ) (c j : Fin C)
    (hC : 1 < C) (hj : j ≠ c) :
    s j ≤ Finset.sup' (Finset.univ.erase c) (erase_univ_nonempty hC c) s := by
  exact Finset.le_sup' s ( by aesop )

/-
If the score gap exceeds `2 * K * d * r` and `f` is `K`-Lipschitz,
    then `f` still strictly decides `c` throughout the L∞ ball of radius `r`.
-/
theorem strictDecides_of_gap_gt
    {C d : ℕ} [NeZero C]
    (f : (Fin d → ℝ) → Fin C → ℝ)
    (K r : ℝ)
    (x z : Fin d → ℝ)
    (c : Fin C)
    (hC : 1 < C)
    (hK : 0 ≤ K)
    (hLip : CoordLipschitz f K)
    (hball : InLInfBall x z r)
    (hgap : scoreGap f x c hC > 2 * K * (d : ℝ) * r) :
    StrictDecides (f z) c := by
  intro j hj; unfold scoreGap at hgap; simp_all +decide ;
  -- By the Lipschitz condition, we have $f z j \leq f x j + K * d * r$ and $f z c \geq f x c - K * d * r$.
  have h_lip_j : f z j ≤ f x j + K * d * r := by
    have := hLip x z j;
    nlinarith [ abs_le.mp this, show ( ∑ k : Fin d, |z k - x k| ) ≤ d * r by exact le_trans ( Finset.sum_le_sum fun _ _ => hball _ ) ( by norm_num ) ]
  have h_lip_c : f z c ≥ f x c - K * d * r := by
    have := sum_abs_sub_le_dim_mul_linf x z r hball; nlinarith [ lip_lower f K x z c hK hLip ] ;
  linarith [ Finset.le_sup' ( fun j => f x j ) ( Finset.mem_erase_of_ne_of_mem hj ( Finset.mem_univ j ) ) ]

/-- Corollary: under the same hypotheses, `decides` holds. -/
theorem decides_of_gap_gt
    {C d : ℕ} [NeZero C]
    (f : (Fin d → ℝ) → Fin C → ℝ)
    (K r : ℝ)
    (x z : Fin d → ℝ)
    (c : Fin C)
    (hC : 1 < C)
    (hK : 0 ≤ K)
    (hLip : CoordLipschitz f K)
    (hball : InLInfBall x z r)
    (hgap : scoreGap f x c hC > 2 * K * (d : ℝ) * r) :
    decides (f z) c :=
  (strictDecides_of_gap_gt f K r x z c hC hK hLip hball hgap).decides