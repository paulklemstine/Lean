/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# GL3 Tropical Satake Certified Robustness for IRV Classifiers

This file formalizes a robustness theory for deterministic, tie-free
instant-runoff / sequential-elimination classifiers built from multiclass
tropical score maps.

## Main results

* `roundLoser_eq_of_strict_min` — uniqueness of the minimizer on a finite set
* `gap_preserved_under_perturbation` — the one-round perturbation lemma
* `eliminationOrderOn_stable` — elimination-order stability under bounded perturbation
* `irvWinnerOn_stable` — winner stability under bounded perturbation
* `irvWinner_certified_robust` — the full tropical/Lipschitz robustness corollary

## Proof architecture

The core theorem proceeds by induction on the cardinality of the active
candidate set. At each round, the gap certificate ensures the current loser
has score at least γ below every other active candidate. A uniform
perturbation of size ≤ ε shifts each score by at most ε, so the gap shrinks
by at most 2ε. When 2ε < γ, the same candidate remains the unique loser,
and the induction carries through the remaining rounds.
-/

import Mathlib

namespace IRV

open Finset

/-! ## Part 1: Core Definitions -/

/-- Pairwise distinct scores on a candidate set. -/
def PairwiseDistinctOn {m : ℕ} (S : Finset (Fin m)) (v : Fin m → ℝ) : Prop :=
  ∀ ⦃i⦄, i ∈ S → ∀ ⦃j⦄, j ∈ S → i ≠ j → v i ≠ v j

/-- Gap certificate: `i` is in `S` and every other element of `S` has
    score at least `γ` above `v i`. -/
def HasGapAtLeast {m : ℕ} (S : Finset (Fin m)) (v : Fin m → ℝ)
    (i : Fin m) (γ : ℝ) : Prop :=
  i ∈ S ∧ ∀ j ∈ S, j ≠ i → v i + γ ≤ v j

/-- The round loser: the element of `S` minimizing `v`, chosen via `Classical.choose`
    from the existence of a minimizer on a nonempty finite set. -/
noncomputable def roundLoser {m : ℕ} (S : Finset (Fin m)) (hS : S.Nonempty)
    (v : Fin m → ℝ) : Fin m :=
  (S.exists_min_image v hS).choose

/-! ## Part 2: Properties of `roundLoser` -/

lemma roundLoser_mem {m : ℕ} (S : Finset (Fin m)) (hS : S.Nonempty)
    (v : Fin m → ℝ) : roundLoser S hS v ∈ S :=
  (S.exists_min_image v hS).choose_spec.1

lemma roundLoser_le {m : ℕ} (S : Finset (Fin m)) (hS : S.Nonempty)
    (v : Fin m → ℝ) : ∀ j ∈ S, v (roundLoser S hS v) ≤ v j :=
  (S.exists_min_image v hS).choose_spec.2

/-
If `i ∈ S` is strictly below every other element of `S` under `v`,
    then `roundLoser S hS v = i`.
-/
lemma roundLoser_eq_of_strict_min {m : ℕ} {S : Finset (Fin m)} {hS : S.Nonempty}
    {v : Fin m → ℝ} {i : Fin m}
    (hi : i ∈ S) (hmin : ∀ j ∈ S, j ≠ i → v i < v j) :
    roundLoser S hS v = i := by
  -- Since `roundLoser S hS v` is in `S` and `v i < v j` for all `j ∈ S \ {i}`, it must be that `roundLoser S hS v = i`.
  have h_unique_min : ∀ j ∈ S, v j < v (roundLoser S hS v) → False := by
    exact fun j hj => not_lt_of_ge ( roundLoser_le S hS v j hj );
  exact Classical.not_not.1 fun h => h_unique_min i hi <| hmin _ ( roundLoser_mem _ hS _ ) h

/-! ## Part 3: Recursive Elimination -/

private lemma erase_nonempty_of_card_gt_one {m : ℕ} {S : Finset (Fin m)}
    {a : Fin m} (ha : a ∈ S) (hcard : ¬ S.card ≤ 1) :
    (S.erase a).Nonempty := by
  -- Since S has more than one element, removing one element a from S leaves a set with at least one element.
  have h_card_erase : (S.erase a).card ≥ 1 := by
    grind +locals;
  -- Since the cardinality of S.erase a is at least 1, the set must be nonempty.
  apply Finset.card_pos.mp h_card_erase

private lemma erase_card_lt {m : ℕ} {S : Finset (Fin m)}
    {a : Fin m} (ha : a ∈ S) :
    (S.erase a).card < S.card := by
  grind +locals

/-- Recursive elimination order on active set `S`: produces the list
    `[first_eliminated, second_eliminated, ..., winner]`. -/
noncomputable def eliminationOrderOn {m : ℕ}
    (S : Finset (Fin m)) (hS : S.Nonempty) (v : Fin m → ℝ) : List (Fin m) :=
  if hcard : S.card ≤ 1 then
    [S.min' hS]
  else
    let i := roundLoser S hS v
    have hi : i ∈ S := roundLoser_mem S hS v
    have hS' : (S.erase i).Nonempty := erase_nonempty_of_card_gt_one hi hcard
    have : (S.erase i).card < S.card := erase_card_lt hi
    i :: eliminationOrderOn (S.erase i) hS' v
termination_by S.card

/-- The IRV winner on active set `S`: the last candidate surviving
    sequential elimination by minimum score. -/
noncomputable def irvWinnerOn {m : ℕ}
    (S : Finset (Fin m)) (hS : S.Nonempty) (v : Fin m → ℝ) : Fin m :=
  if hcard : S.card ≤ 1 then
    S.min' hS
  else
    let i := roundLoser S hS v
    have hi : i ∈ S := roundLoser_mem S hS v
    have hS' : (S.erase i).Nonempty := erase_nonempty_of_card_gt_one hi hcard
    have : (S.erase i).card < S.card := erase_card_lt hi
    irvWinnerOn (S.erase i) hS' v
termination_by S.card

/-- The IRV winner on all candidates. -/
noncomputable def irvWinner {m : ℕ} [NeZero m] (v : Fin m → ℝ) : Fin m :=
  irvWinnerOn Finset.univ Finset.univ_nonempty v

/-- Recursive gap certificate: at every round of the elimination of `v` on `S`,
    the current loser has gap at least `γ` to every other active candidate. -/
noncomputable def EliminationGapCertified {m : ℕ}
    (S : Finset (Fin m)) (hS : S.Nonempty) (v : Fin m → ℝ) (γ : ℝ) : Prop :=
  if hcard : S.card ≤ 1 then
    True
  else
    let i := roundLoser S hS v
    have hi : i ∈ S := roundLoser_mem S hS v
    have hS' : (S.erase i).Nonempty := erase_nonempty_of_card_gt_one hi hcard
    have : (S.erase i).card < S.card := erase_card_lt hi
    HasGapAtLeast S v i γ ∧ EliminationGapCertified (S.erase i) hS' v γ
termination_by S.card

/-! ## Part 4: One-Round Perturbation Lemma -/

/-
The algebraic heart: if `i` has gap `γ` in `S` under `v`, and `v'` is
    within `ε` of `v` coordinatewise, then `i` still has gap `γ - 2*ε`
    in `S` under `v'`.
-/
lemma gap_preserved_under_perturbation {m : ℕ}
    {S : Finset (Fin m)} {v v' : Fin m → ℝ}
    {i : Fin m} {γ ε : ℝ}
    (hgap : HasGapAtLeast S v i γ)
    (hclose : ∀ k, |v' k - v k| ≤ ε) :
    ∀ j ∈ S, j ≠ i → v' i + (γ - 2 * ε) ≤ v' j := by
  exact fun j hj hij => by linarith [ abs_le.mp ( hclose i ), abs_le.mp ( hclose j ), hgap.2 j hj hij ] ;

/-
From a preserved positive gap, the same candidate is the strict minimizer.
-/
lemma strict_min_of_gap {m : ℕ}
    {S : Finset (Fin m)} {v : Fin m → ℝ}
    {i : Fin m} {δ : ℝ}
    (_hi : i ∈ S) (hδ : 0 < δ)
    (hsep : ∀ j ∈ S, j ≠ i → v i + δ ≤ v j) :
    ∀ j ∈ S, j ≠ i → v i < v j := by
  exact fun j hj hij => lt_of_lt_of_le ( lt_add_of_pos_right _ hδ ) ( hsep j hj hij )

/-! ## Part 5: Main Stability Theorem -/

/-
**Elimination-order stability theorem.** If the elimination of `v` on `S`
    is gap-certified with parameter `γ`, and `v'` is within `ε` of `v`
    coordinatewise with `2ε < γ`, then the elimination order of `v'` on `S`
    equals that of `v`.
-/
theorem eliminationOrderOn_stable {m : ℕ}
    {v v' : Fin m → ℝ}
    (S : Finset (Fin m)) (hS : S.Nonempty)
    {ε γ : ℝ}
    (hcert : EliminationGapCertified S hS v γ)
    (hε : 0 ≤ ε)
    (hgap : 2 * ε < γ)
    (hclose : ∀ i, |v' i - v i| ≤ ε) :
    eliminationOrderOn S hS v' = eliminationOrderOn S hS v := by
  nontriviality;
  -- Apply the induction hypothesis to the smaller set S.erase i.
  have ih : ∀ (S : Finset (Fin m)) (hS : S.Nonempty), S.card < Finset.card S + 1 → EliminationGapCertified S hS v γ → 2 * ε < γ → (∀ i, |v' i - v i| ≤ ε) → eliminationOrderOn S hS v' = eliminationOrderOn S hS v := by
    intros S hS hcard hcert hgap hclose;
    induction' n : Finset.card S using Nat.strong_induction_on with n ih generalizing S hS;
    unfold eliminationOrderOn;
    grind +locals;
  exact ih S hS ( Nat.lt_succ_self _ ) hcert hgap hclose

/-! ## Part 6: Winner Stability -/

/-
**Winner stability theorem.** Under the same hypotheses as
    `eliminationOrderOn_stable`, the IRV winner is preserved.
-/
theorem irvWinnerOn_stable {m : ℕ}
    {v v' : Fin m → ℝ}
    (S : Finset (Fin m)) (hS : S.Nonempty)
    {ε γ : ℝ}
    (hcert : EliminationGapCertified S hS v γ)
    (hε : 0 ≤ ε)
    (hgap : 2 * ε < γ)
    (hclose : ∀ i, |v' i - v i| ≤ ε) :
    irvWinnerOn S hS v' = irvWinnerOn S hS v := by
  -- By induction on the size of S.
  induction' n : S.card using Nat.strong_induction_on with n ih generalizing S;
  unfold irvWinnerOn;
  split_ifs <;> simp_all +decide;
  convert ih _ _ _ _ _ rfl using 2;
  · grind +locals;
  · rw [ ← n, Finset.card_erase_of_mem ( roundLoser_mem _ hS _ ) ] ; aesop;
  · unfold EliminationGapCertified at hcert;
    split_ifs at hcert ; simp_all +decide;
    convert hcert.2 using 1;
    rw [ roundLoser_eq_of_strict_min ];
    · exact roundLoser_mem S hS v;
    · intro j hj hj'; have := hcert.1.2 j hj hj'; linarith [ abs_le.mp ( hclose ( roundLoser S hS v ) ), abs_le.mp ( hclose j ) ] ;

/-
Winner stability on the full candidate set.
-/
theorem irvWinner_stable {m : ℕ} [NeZero m]
    {v v' : Fin m → ℝ}
    {ε γ : ℝ}
    (hcert : EliminationGapCertified Finset.univ Finset.univ_nonempty v γ)
    (hε : 0 ≤ ε)
    (hgap : 2 * ε < γ)
    (hclose : ∀ i, |v' i - v i| ≤ ε) :
    irvWinner v' = irvWinner v := by
  convert irvWinnerOn_stable Finset.univ Finset.univ_nonempty hcert hε hgap hclose using 1

/-! ## Part 7: Tropical / GL3 Certified Robustness Corollary -/

/-
**Tropical/GL3 certified robustness theorem.** If a score map `s` is
    K-Lipschitz in L∞ (in the sense that coordinatewise perturbation ≤ r
    implies score perturbation ≤ K*r), and the elimination of `s x` on all
    candidates is gap-certified with parameter `γ`, then any input `x'`
    within L∞-radius `r` of `x` yields the same IRV winner, provided
    `2 K r < γ`.
-/
theorem irvWinner_certified_robust {d m : ℕ} [NeZero m]
    (s : (Fin d → ℝ) → Fin m → ℝ)
    {x x' : Fin d → ℝ}
    {r K γ : ℝ}
    (hLip : ∀ z z' : Fin d → ℝ, (∀ k, |z' k - z k| ≤ r) →
      ∀ i : Fin m, |s z' i - s z i| ≤ K * r)
    (hpert : ∀ k, |x' k - x k| ≤ r)
    (hK : 0 ≤ K) (hr : 0 ≤ r)
    (hcert : EliminationGapCertified Finset.univ Finset.univ_nonempty
      (fun i => s x i) γ)
    (hmargin : 2 * (K * r) < γ) :
    irvWinner (fun i => s x' i) = irvWinner (fun i => s x i) := by
  -- Apply the winner stability theorem with ε = K*r and the fact that 2ε < γ.
  apply irvWinner_stable;
  exacts [ hcert, mul_nonneg hK hr, hmargin, fun i => hLip x x' hpert i ]

end IRV