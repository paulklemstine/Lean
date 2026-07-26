/-
# Persistent Cycles in Randomized Graphs — the independent edge-retention model

This file develops, from scratch and self-containedly, the elementary probability
theory of the **independent edge-retention (bond percolation) model** that underlies
the study of persistent cycles in random subgraphs `G_p`.

We model a finite index set `ι` of "edges".  An *outcome* is a function
`ω : ι → Bool`, where `ω e = true` means edge `e` is *retained*.  Each edge is
retained independently with probability `p`, giving the product mass function
`weight p ω = ∏ e, (if ω e then p else 1 - p)`.

Main results:

* `PersistentCycles.sum_weight` — the weights form a genuine probability mass
  function: `∑ ω, weight p ω = 1` (for every real `p`).
* `PersistentCycles.prob_survives` — the probability that a *fixed* edge set `S`
  survives is exactly `p ^ S.card`.  This is the exact "survival law" that drives
  every first–moment estimate for cycle persistence.
* `PersistentCycles.prob_union_le` — countable (here: finite/binary) subadditivity,
  the union bound.
* `PersistentCycles.exp_surviving_eq` — linearity of expectation: the expected
  number of surviving members of a family `F` of edge sets equals `∑ S ∈ F, p^|S|`.
* Monotonicity, boundedness and non-negativity lemmas.

These are the exact tools used in the companion file `Contrarian.lean` to *prove*
some persistence conjectures and *disprove* others.
-/
import Mathlib

open scoped BigOperators
open Classical

namespace PersistentCycles

variable {ι : Type*} [Fintype ι] [DecidableEq ι]

/-- The probability mass of a single retention outcome `ω`, in which each edge `e`
is retained (`ω e = true`) with probability `p` and deleted with probability
`1 - p`, independently. -/
noncomputable def weight (p : ℝ) (ω : ι → Bool) : ℝ :=
  ∏ e, (if ω e then p else 1 - p)

/-- Probability of an arbitrary event `A` (a set of outcomes) under the retention
model.  We use classical decidability so that `A` may be any predicate. -/
noncomputable def Prob (p : ℝ) (A : (ι → Bool) → Prop) : ℝ :=
  ∑ ω, if A ω then weight p ω else 0

/-- The event that every edge of the fixed set `S` is retained. -/
def survives (S : Finset ι) (ω : ι → Bool) : Prop := ∀ e ∈ S, ω e = true

-- Each outcome has non-negative weight when `p ∈ [0,1]`.
omit [DecidableEq ι] in
theorem weight_nonneg {p : ℝ} (hp0 : 0 ≤ p) (hp1 : p ≤ 1) (ω : ι → Bool) :
    0 ≤ weight p ω :=
  Finset.prod_nonneg fun _ _ => by split_ifs <;> linarith

/--
The weights sum to one: they form a probability mass function.
-/
theorem sum_weight (p : ℝ) : ∑ ω : ι → Bool, weight p ω = 1 := by
  have h_sum : (∑ ω : ι → Bool, ∏ x : ι, (if ω x then p else 1 - p)) = (∏ x : ι, (∑ ω : Bool, (if ω then p else 1 - p))) := by
    rw [ Finset.prod_sum ];
    refine' Finset.sum_bij ( fun f _ => fun x _ => f x ) _ _ _ _ <;> simp +decide;
    · simp +decide [ funext_iff ];
    · exact fun b => ⟨ fun x => b x ( Finset.mem_univ x ), rfl ⟩;
  convert h_sum using 2 ; simp +decide

/--
**Survival law.**  The probability that a fixed edge set `S` is entirely
retained equals `p ^ |S|`.
-/
theorem prob_survives (p : ℝ) (S : Finset ι) :
    Prob p (survives S) = p ^ S.card := by
  unfold Prob survives;
  -- Consider the product $\prod_{e \in S} (p \cdot \mathbb{1}_{\omega_e = \text{true}} + (1 - p) \cdot \mathbb{1}_{\omega_e = \text{false}})$.
  have h_prod : ∑ ω : ι → Bool, (∏ e, (if ω e then p else 1 - p)) * (if ∀ e ∈ S, ω e = true then 1 else 0) = ∏ e, (∑ b : Bool, if e ∈ S then (if b then p else 0) else (if b then p else 1 - p)) := by
    -- By Fubini's theorem, we can interchange the order of summation.
    have h_fubini : ∑ ω : ι → Bool, (∏ e, (if ω e then p else 1 - p)) * (if ∀ e ∈ S, ω e = true then 1 else 0) = ∑ ω : ι → Bool, (∏ e, (if e ∈ S then (if ω e then p else 0) else (if ω e then p else 1 - p))) := by
      congr with ω ; split_ifs <;> simp_all +decide [ Finset.prod_ite ];
      simp_all +decide [ Finset.filter_not ];
      rw [ show ( Finset.filter ( fun x => ω x = true ) Finset.univ ) = S ∪ Finset.filter ( fun x => ω x = true ) ( Finset.univ \ S ) from ?_, show ( Finset.filter ( fun x => ω x = false ) Finset.univ ) = Finset.filter ( fun x => ω x = false ) ( Finset.univ \ S ) from ?_ ];
      · rw [ Finset.card_union_of_disjoint ( Finset.disjoint_left.mpr fun x hx₁ hx₂ => by aesop ), pow_add ] ; ring;
      · grind;
      · grind;
    rw [h_fubini, Finset.prod_univ_sum, ← Fintype.piFinset_univ]
  convert h_prod using 1 <;> simp +decide [ weight ]

/--
Probabilities are non-negative for `p ∈ [0,1]`.
-/
theorem prob_nonneg {p : ℝ} (hp0 : 0 ≤ p) (hp1 : p ≤ 1) (A : (ι → Bool) → Prop) :
    0 ≤ Prob p A := by
  convert Finset.sum_nonneg ?_;
  · infer_instance;
  · exact fun _ _ => by split_ifs <;> [ exact weight_nonneg hp0 hp1 _; exact le_rfl ] ;

/--
Monotonicity of probability with respect to event inclusion.
-/
theorem prob_mono {p : ℝ} (hp0 : 0 ≤ p) (hp1 : p ≤ 1) {A B : (ι → Bool) → Prop}
    (h : ∀ ω, A ω → B ω) : Prob p A ≤ Prob p B := by
  convert Finset.sum_le_sum fun ω _ => ?_;
  · infer_instance;
  · split_ifs <;> simp_all +decide [ weight_nonneg hp0 hp1 ]

/--
Every probability is at most one, for `p ∈ [0,1]`.
-/
theorem prob_le_one {p : ℝ} (hp0 : 0 ≤ p) (hp1 : p ≤ 1) (A : (ι → Bool) → Prop) :
    Prob p A ≤ 1 := by
  convert prob_mono hp0 hp1 ( fun ω _ => trivial ) using 1;
  exact Eq.symm ( by unfold Prob; simp +decide [ sum_weight ] )

/--
**Union bound (finite subadditivity).**
-/
theorem prob_union_le {p : ℝ} (hp0 : 0 ≤ p) (hp1 : p ≤ 1) (A B : (ι → Bool) → Prop) :
    Prob p (fun ω => A ω ∨ B ω) ≤ Prob p A + Prob p B := by
  -- Apply the linearity of summation.
  simp [Prob];
  simpa only [ ← Finset.sum_add_distrib ] using Finset.sum_le_sum fun x _ => by by_cases hA : A x <;> by_cases hB : B x <;> simp +decide [ hA, hB ] ; linarith [ weight_nonneg hp0 hp1 x ] ;

/-- The expected number of surviving members of a finite family `F` of edge sets. -/
noncomputable def expSurviving (p : ℝ) (F : Finset (Finset ι)) : ℝ :=
  ∑ ω, weight p ω * ((F.filter (fun S => survives S ω)).card : ℝ)

/--
**Linearity of expectation / first moment.**  The expected number of surviving
edge sets in a family `F` is the sum of the individual survival probabilities.
-/
theorem exp_surviving_eq (p : ℝ) (F : Finset (Finset ι)) :
    expSurviving p F = ∑ S ∈ F, p ^ S.card := by
  convert Finset.sum_congr rfl fun S hS => prob_survives p S using 1;
  convert Finset.sum_comm using 1;
  refine' Finset.sum_congr rfl fun x hx => _;
  simp +decide [ Finset.sum_ite, mul_comm ]

end PersistentCycles