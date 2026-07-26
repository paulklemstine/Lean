/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Committee Plurality Robustness via Tropical Satake Certificates

This file formalizes a **committee-level plurality robustness theorem** that composes
memberwise certified robustness (e.g. from GL₃ tropical Satake top-k certificates)
into an ensemble-level winner-invariance guarantee.

## Mathematical overview

Consider a committee of `n` members, each casting a vote for one of `m` labels.
The committee winner is the label receiving the most votes (plurality winner).

The main result has two layers:

1. **Analytic / tropical layer**: each member's vote is unchanged when its score
   perturbation stays within a certified radius. This is the content of the existing
   GL₃ tropical Satake top-k robustness theorems.

2. **Discrete committee layer**: if only a bounded number `C` of members can change
   their vote, then a plurality margin strictly greater than `2C` forces the
   committee winner to remain fixed. The factor of 2 is tight: each changed member
   can simultaneously gain a vote for a competitor and lose a vote for the winner.

The key combinatorial insight is that independent per-label vote-count bounds
(`voteCount` changes by at most `C`) combine to give a vote-gap bound of `2C`:

  `voteCount v' y - voteCount v' w ≤ (voteCount v y - voteCount v w) + 2C`

The plurality stability theorem is then immediate from this gap bound.

## Main results

- `voteCount_sub_le_changed`: vote count for any label changes by at most the number
  of changed members (absolute value form).
- `voteGap_perturbation_le_changed`: the pairwise vote gap increases by at most `2C`.
- `plurality_winner_stable_of_margin_gt_twice_changed`: discrete plurality stability.
- `changedMembers_subset_unstable`: only analytically unstable members can change vote.
- `changedMembers_card_le_unstable`: cardinality consequence.
- `committee_plurality_robust_of_member_certificates`: the main abstract ensemble
  robustness theorem.
- `gl3_tropical_satake_committee_plurality_robust`: specialization to GL₃ tropical
  Satake certificates.

## Significance

This result upgrades certified robustness from a single GL₃ Hecke-score classifier
to an ensemble mechanism. The theorem isolates a discrete plurality margin principle
independent of the analytic details of tropical Satake, showing how memberwise certified
radii compose nontrivially at committee level through the cardinality of the
unstable-member set.
-/

open Finset

/-! ## Core definitions -/

/-- The number of committee members voting for label `y`. -/
def voteCount {n m : ℕ} (v : Fin n → Fin m) (y : Fin m) : ℕ :=
  (Finset.univ.filter (fun i : Fin n => v i = y)).card

/-- The finset of members voting for label `y`. -/
def voteCountFinset {n m : ℕ} (v : Fin n → Fin m) (y : Fin m) : Finset (Fin n) :=
  Finset.univ.filter (fun i => v i = y)

/-- `voteCount` equals the cardinality of `voteCountFinset`. -/
theorem voteCount_eq_card_voteCountFinset
    {n m : ℕ} (v : Fin n → Fin m) (y : Fin m) :
    voteCount v y = (voteCountFinset v y).card := by
  rfl

/-- The set of members whose vote changed under perturbation. -/
def changedMembers {n m : ℕ} (v v' : Fin n → Fin m) : Finset (Fin n) :=
  Finset.univ.filter (fun i => v i ≠ v' i)

/-- Membership in `changedMembers` is equivalent to having different votes. -/
theorem mem_changedMembers {n m : ℕ} {v v' : Fin n → Fin m} {i : Fin n} :
    i ∈ changedMembers v v' ↔ v i ≠ v' i := by
  simp [changedMembers]

/-- A member with equal votes is not in `changedMembers`. -/
theorem not_mem_changedMembers_of_eq {n m : ℕ} {v v' : Fin n → Fin m} {i : Fin n}
    (h : v i = v' i) : i ∉ changedMembers v v' := by
  simp [changedMembers, h]

/-- The set of analytically unstable members (perturbation exceeds certified radius). -/
noncomputable def unstableMembers (ε cert : Fin n → ℝ) : Finset (Fin n) :=
  Finset.univ.filter (fun i => ¬ ε i < cert i)

/-! ## Vote count perturbation bounds -/

/-- Members who voted for `y` originally but not after perturbation form a subset
of `changedMembers`. -/
theorem lost_voters_subset_changed {n m : ℕ} (v v' : Fin n → Fin m) (y : Fin m) :
    Finset.univ.filter (fun i => v i = y ∧ v' i ≠ y) ⊆ changedMembers v v' := by
  intro i hi
  simp only [Finset.mem_filter, Finset.mem_univ, true_and] at hi ⊢
  simp only [changedMembers, Finset.mem_filter, Finset.mem_univ, true_and, ne_eq]
  exact fun h => (hi.2 (h ▸ hi.1)).elim

/-- Members who vote for `y` after perturbation but not before form a subset
of `changedMembers`. -/
theorem gained_voters_subset_changed {n m : ℕ} (v v' : Fin n → Fin m) (y : Fin m) :
    Finset.univ.filter (fun i => v i ≠ y ∧ v' i = y) ⊆ changedMembers v v' := by
  intro i hi
  simp only [Finset.mem_filter, Finset.mem_univ, true_and] at hi ⊢
  simp [changedMembers, hi.1, hi.2]

/-- **Upper bound**: the perturbed vote count exceeds the original by at most the
number of changed members. -/
theorem voteCount_le_add_changed {n m : ℕ}
    (v v' : Fin n → Fin m) (y : Fin m) :
    voteCount v' y ≤ voteCount v y + (changedMembers v v').card := by
  unfold voteCount changedMembers
  exact le_trans (Finset.card_mono fun i hi => by by_cases hi' : v i = y <;> aesop)
    (Finset.card_union_le _ _)

/-- **Lower bound**: the perturbed vote count is at least the original minus the
number of changed members. -/
theorem voteCount_ge_sub_changed {n m : ℕ}
    (v v' : Fin n → Fin m) (y : Fin m) :
    voteCount v y - (changedMembers v v').card ≤ voteCount v' y := by
  unfold voteCount changedMembers
  rw [tsub_le_iff_right, ← Finset.card_union_add_card_inter]
  exact le_add_right (Finset.card_le_card fun x hx => by by_cases h : v x = v' x <;> aesop)

/-- **Absolute value bound**: the vote count for any fixed label changes by at most
the number of changed members. -/
theorem voteCount_sub_le_changed
    {n m : ℕ}
    (v v' : Fin n → Fin m) (y : Fin m) :
    |(voteCount v y : ℤ) - (voteCount v' y : ℤ)| ≤ (changedMembers v v').card := by
  refine abs_sub_le_iff.mpr ⟨?_, ?_⟩
  · rw [sub_le_iff_le_add']
    unfold voteCount changedMembers
    rw_mod_cast [← Finset.card_union_add_card_inter]
    exact le_add_right (Finset.card_le_card fun x hx => by by_cases h : v x = v' x <;> aesop)
  · exact sub_le_iff_le_add'.mpr (mod_cast voteCount_le_add_changed v v' y)

/-! ## Vote gap perturbation bound -/

/-
**Vote-gap perturbation bound.** The pairwise vote gap `(count y) - (count w)` can
increase by at most `2 * C` where `C` is the number of changed members. This is tight:
a member switching from `w` to `y` increases the gap by 2.
-/
theorem voteGap_perturbation_le_changed
    {n m : ℕ}
    (v v' : Fin n → Fin m) (y w : Fin m) :
    (voteCount v' y : ℤ) - voteCount v' w
      ≤ ((voteCount v y : ℤ) - voteCount v w) +
        2 * (changedMembers v v').card := by
  have h_le_add : (voteCount v' y : ℤ) ≤ (voteCount v y : ℤ) + (changedMembers v v').card := by
    exact_mod_cast voteCount_le_add_changed v v' y
  have h_ge_sub : (voteCount v' w : ℤ) ≥ (voteCount v w : ℤ) - (changedMembers v v').card := by
    have h_ge_sub : (voteCount v w : ℤ) - (changedMembers v v').card ≤ (voteCount v' w : ℤ) := by
      have := voteCount_ge_sub_changed v v' w
      omega;
    exact h_ge_sub;
  grind

/-! ## Plurality stability theorems -/

/-
**Discrete plurality stability.** If `w` beats every competitor by a margin strictly
greater than twice the number of changed members, then `w` remains the unique plurality
winner after perturbation. The factor of 2 is tight: a member switching from `w` to `y`
simultaneously increases `y`'s count and decreases `w`'s count.
-/
theorem plurality_winner_stable_of_margin_gt_twice_changed
    {n m : ℕ}
    (v v' : Fin n → Fin m) (w : Fin m)
    (hmargin : ∀ y : Fin m, y ≠ w →
      voteCount v y + 2 * (changedMembers v v').card < voteCount v w)
    : ∀ y : Fin m, y ≠ w → voteCount v' y < voteCount v' w := by
  intros y hy; specialize hmargin y hy; linarith [ voteGap_perturbation_le_changed v v' y w ] ;

/-
**Corollary with explicit bound `M`.**
-/
theorem plurality_winner_stable_of_margin_gt_M
    {n m : ℕ}
    (v v' : Fin n → Fin m) (w : Fin m) (M : ℕ)
    (hchanged : (changedMembers v v').card ≤ M)
    (hmargin : ∀ y : Fin m, y ≠ w → voteCount v y + 2 * M < voteCount v w)
    : ∀ y : Fin m, y ≠ w → voteCount v' y < voteCount v' w := by
  intro y hy;
  have := voteGap_perturbation_le_changed v v' y w;
  linarith [ hmargin y hy ]

/-! ## Bridge from analytic certificates to combinatorial bounds -/

/-- **Only unstable members can change vote.** If a member's perturbation is within its
certified radius, its vote is unchanged. Therefore changed members are a subset of
unstable members. -/
theorem changedMembers_subset_unstable
    {n m : ℕ}
    (v v' : Fin n → Fin m)
    (ε cert : Fin n → ℝ)
    (hstable : ∀ i, ε i < cert i → v' i = v i) :
    changedMembers v v' ⊆ unstableMembers ε cert := by
  exact fun i hi => Finset.mem_filter.mpr
    ⟨Finset.mem_filter.mp hi |>.1,
     fun h => by have := hstable i h; simp_all +decide [changedMembers]⟩

/-- **Cardinality consequence**: the number of changed members is bounded by the
number of unstable members. -/
theorem changedMembers_card_le_unstable
    {n m : ℕ}
    (v v' : Fin n → Fin m)
    (ε cert : Fin n → ℝ)
    (hstable : ∀ i, ε i < cert i → v' i = v i) :
    (changedMembers v v').card ≤ (unstableMembers ε cert).card :=
  Finset.card_le_card (changedMembers_subset_unstable v v' ε cert hstable)

/-! ## Main ensemble robustness theorem -/

/-
**Main theorem: Committee plurality robustness from memberwise certificates.**

Given a committee of `n` members voting among `m` labels, if:
1. each member's vote is unchanged when its perturbation is within its certified radius,
2. the plurality winner `w` beats every competitor by a margin strictly greater than
   twice the number of unstable members,

then `w` remains the unique plurality winner after perturbation.

This theorem is the correct abstract interface: the GL₃ tropical Satake theorem (or any
other memberwise robustness certificate) can be plugged in as the proof of `hstable`.

**Why the factor of 2?** Each unstable member can at worst switch its vote from `w` to
a competitor `y`, simultaneously decreasing `w`'s count by 1 and increasing `y`'s count
by 1, for a net gap change of 2 per member.
-/
theorem committee_plurality_robust_of_member_certificates
    {n m : ℕ}
    (v v' : Fin n → Fin m)
    (ε cert : Fin n → ℝ)
    (w : Fin m)
    (hstable : ∀ i, ε i < cert i → v' i = v i)
    (hmargin : ∀ y : Fin m, y ≠ w →
      voteCount v y + 2 * (unstableMembers ε cert).card < voteCount v w) :
    ∀ y : Fin m, y ≠ w → voteCount v' y < voteCount v' w := by
  apply plurality_winner_stable_of_margin_gt_M v v' w (unstableMembers ε cert).card (by
  exact changedMembers_card_le_unstable v v' ε cert hstable) (by
  assumption)

/-! ## GL₃ tropical Satake specialization -/

/-- **GL₃ tropical Satake committee plurality robustness.**

Specialization of the abstract committee robustness theorem to the setting where
each member's certified radius comes from the GL₃ tropical Satake top-k robustness
certificate. The `hmember_cert` hypothesis is exactly what the single-model theorem
`topKSet_eq_of_uniform_score_close` (or its Lipschitz variant) provides, composed
with a deterministic label selector.

The key abstraction boundary: we assume that each member has a deterministic vote
extraction from its score vector, and that this extraction is stable when the top-k
set is preserved. The GL₃ certificate guarantees top-k preservation, which implies
vote preservation via the selector stability. -/
theorem gl3_tropical_satake_committee_plurality_robust
    {n m : ℕ}
    (v v' : Fin n → Fin m)
    (ε certifiedRadius : Fin n → ℝ)
    (w : Fin m)
    (hmember_cert : ∀ i, ε i < certifiedRadius i → v' i = v i)
    (hmargin : ∀ y : Fin m, y ≠ w →
      voteCount v y + 2 * (unstableMembers ε certifiedRadius).card < voteCount v w) :
    ∀ y : Fin m, y ≠ w → voteCount v' y < voteCount v' w :=
  committee_plurality_robust_of_member_certificates v v' ε certifiedRadius w
    hmember_cert hmargin

/-- **Selected label stability from top-k invariance.**

If a label selector depends only on membership in the top-k set, and the top-k set
is preserved under perturbation, then the selected label is unchanged. This is the
bridge between the GL₃ tropical Satake top-k theorem and the vote-level stability
hypothesis needed by the committee robustness theorem. -/
theorem selectedLabel_stable_of_topK_stable
    {ι : Type*} [Fintype ι] [DecidableEq ι]
    (selector : Finset ι → ι)
    (score score' : ι → ℝ)
    (k : ℕ)
    (topKSet : (ι → ℝ) → ℕ → Finset ι)
    (htopk_eq : topKSet score' k = topKSet score k) :
    selector (topKSet score' k) = selector (topKSet score k) := by
  rw [htopk_eq]

#print axioms committee_plurality_robust_of_member_certificates
#print axioms gl3_tropical_satake_committee_plurality_robust
#print axioms voteGap_perturbation_le_changed
#print axioms plurality_winner_stable_of_margin_gt_twice_changed
#print axioms changedMembers_subset_unstable
#print axioms selectedLabel_stable_of_topK_stable