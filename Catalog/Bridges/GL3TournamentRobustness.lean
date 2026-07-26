/-
# GL3 Tropical Satake Tournament Robustness

This file establishes robustness theorems for a pairwise-comparison (tournament)
classifier built from GL3 tropical Satake / Hecke score maps. The key results show
that if all pairwise score margins exceed twice the perturbation budget, then:
- the sign of every pairwise gap is preserved,
- the Condorcet (tournament) winner is invariant, and
- the Copeland score of the winner remains exactly 2.

The mathematical content is:
  tropical Lipschitz control on scores
  ⇒ Lipschitz control on pairwise gaps
  ⇒ sign stability of all decisive comparisons
  ⇒ invariance of tournament-based multiclass decisions.
-/

import Mathlib

open Finset

variable {α : Type*}

/-! ## Core Definitions -/

/-- The pairwise gap between scores for classes `i` and `j`. -/
def gap (S : α → Fin 3 → ℝ) (x : α) (i j : Fin 3) : ℝ :=
  S x i - S x j

/-- Number of pairwise wins for class `i`: the count of classes `j ≠ i`
    such that `S x i > S x j`. -/
noncomputable def pairwiseWins (S : α → Fin 3 → ℝ) (x : α) (i : Fin 3) : ℕ :=
  (Finset.univ.filter fun j => j ≠ i ∧ 0 < gap S x i j).card

/-- Class `i` is a Condorcet winner if it beats every other class in
    pairwise comparison. -/
def isCondorcetWinner (S : α → Fin 3 → ℝ) (x : α) (i : Fin 3) : Prop :=
  ∀ j, j ≠ i → 0 < gap S x i j

/-- A strict tournament has no ties: every pair of distinct classes has
    a nonzero gap. -/
def strictTournament (S : α → Fin 3 → ℝ) (x : α) : Prop :=
  ∀ i j, i ≠ j → gap S x i j ≠ 0

/-! ## Sign Preservation Under Perturbation -/

/-
**Sign preservation lemma.** If a real number `a` is perturbed to `b`
    with `|b - a| ≤ ε` and `ε < |a|`, then `a` and `b` have the same sign.
-/
theorem sign_preserved_of_abs_diff_lt_abs
    {a b ε : ℝ}
    (h1 : |b - a| ≤ ε)
    (h2 : ε < |a|) :
    (0 < a ↔ 0 < b) := by
  constructor <;> intro <;> cases abs_cases ( b - a ) <;> cases abs_cases a <;> linarith

/-! ## Gap Perturbation Bound -/

/-
The perturbation of a pairwise gap is bounded by twice the coordinatewise
    score perturbation: if each score changes by at most `K * d * r`, then
    each gap changes by at most `2 * K * d * r`.
-/
theorem gap_perturbation_bound
    (S : α → Fin 3 → ℝ) (x x' : α) (K d r : ℝ)
    (hscore : ∀ i : Fin 3, |S x' i - S x i| ≤ K * d * r) :
    ∀ i j : Fin 3, |gap S x' i j - gap S x i j| ≤ 2 * K * d * r := by
  exact fun i j => abs_le.mpr ⟨ by linarith [ abs_le.mp ( hscore i ), abs_le.mp ( hscore j ), show gap S x' i j - gap S x i j = ( S x' i - S x' j ) - ( S x i - S x j ) by rfl ], by linarith [ abs_le.mp ( hscore i ), abs_le.mp ( hscore j ), show gap S x' i j - gap S x i j = ( S x' i - S x' j ) - ( S x i - S x j ) by rfl ] ⟩

/-! ## Gap Sign Stability -/

/-
**Gap sign stability.** If all pairwise gaps are perturbed by at most
    `2 * K * d * r`, and every gap's absolute value exceeds this bound,
    then all gap signs are preserved.
-/
theorem gap_sign_stable_of_margin
    {α : Type*}
    (S : α → Fin 3 → ℝ)
    (x x' : α) (K d r : ℝ)
    (hgap :
      ∀ i j : Fin 3, |gap S x' i j - gap S x i j| ≤ 2 * K * d * r)
    (hmargin :
      ∀ i j : Fin 3, i ≠ j → 2 * K * d * r < |gap S x i j|) :
    ∀ i j : Fin 3, i ≠ j → (0 < gap S x i j ↔ 0 < gap S x' i j) := by
  exact fun i j hij => sign_preserved_of_abs_diff_lt_abs ( hgap i j ) ( hmargin i j hij )

/-! ## Condorcet Winner Stability -/

/-
**Condorcet winner stability.** If class `c` beats every rival by more than
    the perturbation budget `2 * K * d * r`, then `c` remains a Condorcet
    winner after perturbation. This is the main robustness theorem.
-/
theorem condorcet_stable_of_pairwise_margins
    {α : Type*}
    (S : α → Fin 3 → ℝ)
    (x x' : α) (c : Fin 3) (K d r : ℝ)
    (hgap :
      ∀ i j : Fin 3, |gap S x' i j - gap S x i j| ≤ 2 * K * d * r)
    (hmargin :
      ∀ j : Fin 3, j ≠ c → 2 * K * d * r < gap S x c j) :
    isCondorcetWinner S x' c := by
  intro j hj;
  linarith [ abs_le.mp ( hgap c j ), hmargin j hj ]

/-! ## Copeland Score of a Condorcet Winner -/

/-
A Condorcet winner on `Fin 3` has Copeland score (pairwise wins) exactly 2.
-/
theorem pairwiseWins_eq_two_of_condorcet
    (S : α → Fin 3 → ℝ) (x : α) (c : Fin 3)
    (hcond : isCondorcetWinner S x c) :
    pairwiseWins S x c = 2 := by
  unfold pairwiseWins;
  rw [ show ( Finset.univ.filter fun j => j ≠ c ∧ 0 < gap S x c j ) = Finset.univ.erase c from Finset.ext fun y => by aesop ] ; simp +decide

/-
**Copeland score stability.** Combining Condorcet stability with the
    Copeland score computation: class `c` has Copeland score 2 after perturbation.
-/
theorem copeland_stable_of_pairwise_margins
    {α : Type*}
    (S : α → Fin 3 → ℝ)
    (x x' : α) (c : Fin 3) (K d r : ℝ)
    (hgap :
      ∀ i j : Fin 3, |gap S x' i j - gap S x i j| ≤ 2 * K * d * r)
    (hmargin :
      ∀ j : Fin 3, j ≠ c → 2 * K * d * r < gap S x c j) :
    pairwiseWins S x' c = 2 := by
  exact pairwiseWins_eq_two_of_condorcet S x' c
    (condorcet_stable_of_pairwise_margins S x x' c K d r hgap hmargin)

/-! ## Full GL3 Robustness Theorem -/

/-
**GL3 Tournament Robustness Theorem.** Starting from coordinatewise score
    perturbation bounds `|S x' i - S x i| ≤ K * d * r`, if every gap from the
    winning class `c` exceeds `2 * K * d * r`, then `c` remains a Condorcet
    winner. This derives the gap perturbation bound internally.
-/
theorem robust_tournament_winner_of_GL3_margin
    {α : Type*}
    (S : α → Fin 3 → ℝ)
    (x x' : α) (c : Fin 3) (K d r : ℝ)
    (hscore :
      ∀ i : Fin 3, |S x' i - S x i| ≤ K * d * r)
    (hmargin :
      ∀ j : Fin 3, j ≠ c → 2 * K * d * r < S x c - S x j) :
    isCondorcetWinner S x' c := by
  -- Apply the gap perturbation bound to derive that the gaps are bounded.
  exact condorcet_stable_of_pairwise_margins S x x' c K d r
    (gap_perturbation_bound S x x' K d r hscore) hmargin

/-! ## Strict Tournament Orientation Stability -/

/-
**All-edges orientation stability.** If all pairwise margins exceed the
    perturbation budget, then the orientation of every edge in the tournament
    is preserved. This implies invariance of any decision rule that depends
    only on edge orientations.
-/
theorem strict_tournament_orientation_stable
    {α : Type*}
    (S : α → Fin 3 → ℝ)
    (x x' : α) (K d r : ℝ)
    (hgap :
      ∀ i j : Fin 3, |gap S x' i j - gap S x i j| ≤ 2 * K * d * r)
    (hmargin :
      ∀ i j : Fin 3, i ≠ j → 2 * K * d * r < |gap S x i j|) :
    ∀ i j : Fin 3, i ≠ j →
      (0 < gap S x i j ↔ 0 < gap S x' i j) := by
  grind +splitImp

/-! ## Condorcet Winner Existence and Cycles -/

/-
A Condorcet winner exists on `Fin 3` if and only if the tournament has
    no 3-cycle.
-/
theorem exists_condorcet_winner_iff_no_cycle_Fin3
    (S : α → Fin 3 → ℝ) (x : α)
    (hstrict : strictTournament S x) :
    (∃ i : Fin 3, isCondorcetWinner S x i) ↔
      ¬ ((0 < gap S x 0 1 ∧ 0 < gap S x 1 2 ∧ 0 < gap S x 2 0) ∨
         (0 < gap S x 1 0 ∧ 0 < gap S x 0 2 ∧ 0 < gap S x 2 1)) := by
  unfold isCondorcetWinner gap;
  simp +decide [ Fin.forall_fin_succ, Fin.exists_fin_succ ] at *;
  constructor <;> intro h;
  · constructor <;> intros <;> linarith;
  · cases lt_or_gt_of_ne ( hstrict 0 1 ( by decide ) ) <;> cases lt_or_gt_of_ne ( hstrict 1 2 ( by decide ) ) <;> cases lt_or_gt_of_ne ( hstrict 0 2 ( by decide ) ) <;> simp +decide [ * ] at *;
    all_goals unfold gap at *; simp_all +decide ;
    · linarith;
    · linarith