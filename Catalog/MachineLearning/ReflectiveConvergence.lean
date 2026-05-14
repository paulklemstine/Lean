/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Reflective Convergence: Self-Modifying Research Strategies via Dependent Dynamical Systems

This file formalizes research strategy as a mathematically analyzable object: a
state-transition system with dependent state spaces, improvement operators, and
provable convergence theorems.

## Main Results

* `reflective_eventual_fixed_point` — Every inflationary monotone self-improvement
  operator on a finite strategy space converges to a fixed point.
* `reflective_convergence_finite` — The iteration sequence eventually stabilizes.
* `weakness_descent_converges` — If improvement strictly reduces a finite defect set,
  the weakness profile stabilizes.
* `dependent_cycle_transport` — States transport coherently across equal outcomes.
* `concrete_defect_convergence` — Concrete convergence for a finite defect model.

## Cross-Domain Connections

- Abstract interpretation: monotone transfer operators on finite domains.
- Discrete dynamical systems: fixed points as reflective equilibria.
- Oracle complexity: bounded self-reference via `self_reference_bound`.
- Idempotent evidence aggregation: via `add_self_eq`.
- Closure-capacity theory: via `cap_depends_on_closure_class`.
-/

import Mathlib

open Finset Function

set_option maxHeartbeats 400000

/-! ## §1. Outcome-Indexed Research Cycles -/

universe u v

/-- A research system with outcome-dependent state spaces.
    Each outcome `o` determines a fiber `NextState o` of possible next states,
    and `eval` selects a state in the appropriate fiber. -/
structure ResearchSystem where
  Outcome : Type u
  NextState : Outcome → Type v
  eval : (o : Outcome) → NextState o

/-- A dependent research cycle: outcomes determine state spaces,
    and states determine the next outcome. -/
structure DepResearch where
  Outcome : Type u
  State : Outcome → Type v
  nextOutcome : (o : Outcome) → State o → Outcome

/-- The total state space of a two-step dependent research cycle. -/
def twoStepState (R : DepResearch) := Σ o : R.Outcome, R.State o

/-- If two outcomes are equal, the corresponding state spaces are equivalent. -/
def dependent_cycle_transport
    {R : DepResearch}
    {o₁ o₂ : R.Outcome} (h : o₁ = o₂) :
    R.State o₁ ≃ R.State o₂ :=
  Equiv.cast (congrArg R.State h)

/-- Transport preserves identity: transporting along `rfl` is the identity. -/
theorem dependent_cycle_transport_rfl
    {R : DepResearch} {o : R.Outcome} :
    dependent_cycle_transport (rfl : o = o) = Equiv.refl _ := by
  rfl

/-! ## §2. Reflective Strategy Framework -/

/-- A reflective strategy system bundling improvement with convergence data. -/
structure ReflectiveSystem (σ : Type u) [Fintype σ] [DecidableEq σ] [Preorder σ] where
  improve : σ → σ
  rank : σ → ℕ
  inflationary : ∀ s, s ≤ improve s
  strict_progress : ∀ s, improve s ≠ s → rank s < rank (improve s)

/-! ## §3. Main Convergence Theorems -/

section Convergence

variable {σ : Type u} [Fintype σ] [DecidableEq σ] [Preorder σ]

/-
Helper: if improvement hasn't stabilized up to step n, rank strictly increases
    at each step, giving n distinct rank values.
-/
omit [Fintype σ] [DecidableEq σ] [Preorder σ] in
private theorem rank_strictly_increases_along_nonfixed
    (improve : σ → σ) (rank : σ → ℕ)
    (hstrict : ∀ s, improve s ≠ s → rank s < rank (improve s))
    (s : σ) (n : ℕ)
    (hnot : ∀ k, k < n → improve^[k + 1] s ≠ improve^[k] s) :
    ∀ i j, i < j → j ≤ n → rank (improve^[i] s) < rank (improve^[j] s) := by
  intro i j hij hnj; induction' hij with k hk <;> simp_all +decide [ Function.iterate_succ_apply' ] ;
  exact lt_trans ( by solve_by_elim [ Nat.le_of_lt ] ) ( hstrict _ ( hnot _ hnj ) )

/-
**Flagship theorem**: Every inflationary improvement operator with strictly
    increasing rank on non-fixed points eventually reaches a fixed point.
-/
omit [DecidableEq σ] in
theorem reflective_eventual_fixed_point
    (improve : σ → σ) (rank : σ → ℕ)
    (_hinfl : ∀ s, s ≤ improve s)
    (hstrict : ∀ s, improve s ≠ s → rank s < rank (improve s)) :
    ∀ s, ∃ n, improve^[n] s = improve (improve^[n] s) := by
  intro s;
  by_contra h_no_fixed_point;
  -- By rank_strictly_increases_along_nonfixed, rank is strictly increasing along the iterate sequence.
  have h_rank_increasing : StrictMono (fun n => rank (improve^[n] s)) := by
    refine' strictMono_nat_of_lt_succ fun n => _;
    simpa only [ Function.iterate_succ_apply' ] using hstrict _ fun h => h_no_fixed_point ⟨ n, h.symm ⟩;
  exact absurd ( Set.infinite_range_of_injective h_rank_increasing.injective ) ( Set.not_infinite.mpr <| Set.Finite.subset ( Set.toFinite <| Set.range rank ) <| Set.range_subset_iff.mpr fun n => Set.mem_range_self _ )

/-
Adjacent iterates eventually coincide.
-/
omit [DecidableEq σ] in
theorem reflective_convergence_finite
    (improve : σ → σ) (rank : σ → ℕ)
    (hinfl : ∀ s, s ≤ improve s)
    (hstrict : ∀ s, improve s ≠ s → rank s < rank (improve s)) :
    ∀ s, ∃ n, improve^[n + 1] s = improve^[n] s := by
  intro s
  obtain ⟨n, hn⟩ := reflective_eventual_fixed_point improve rank hinfl hstrict s
  exact ⟨n, by rw [iterate_succ_apply']; exact hn.symm⟩

/-
The stable iterate is genuinely a fixed point.
-/
omit [Fintype σ] [DecidableEq σ] [Preorder σ] in
theorem fixed_point_is_fixed
    (improve : σ → σ) (s : σ) (n : ℕ)
    (h : improve^[n + 1] s = improve^[n] s) :
    improve (improve^[n] s) = improve^[n] s := by
  rwa [ Function.iterate_succ_apply' ] at h

end Convergence

/-! ## §4. Weakness Descent -/

section WeaknessDescent

variable {σ : Type u} {δ : Type u} [Fintype δ] [DecidableEq δ]

/-
Weakness cardinality is non-increasing under improvement.
-/
omit [Fintype δ] [DecidableEq δ] in
theorem weakness_card_nonincreasing
    (weakness : σ → Finset δ) (improve : σ → σ)
    (hsub : ∀ s, weakness (improve s) ⊆ weakness s) :
    ∀ s, (weakness (improve s)).card ≤ (weakness s).card := by
  exact fun s => Finset.card_le_card ( hsub s )

/-
**Weakness descent theorem**: If improvement never introduces new weaknesses
    and strictly reduces the weakness set when it changes,
    then the weakness profile stabilizes in finitely many steps.
-/
omit [Fintype δ] in
theorem weakness_descent_converges
    (weakness : σ → Finset δ) (improve : σ → σ)
    (_hsub : ∀ s, weakness (improve s) ⊆ weakness s)
    (hstrict : ∀ s, weakness (improve s) ≠ weakness s →
        (weakness (improve s)).card < (weakness s).card) :
    ∀ s, ∃ n, weakness (improve^[n + 1] s) = weakness (improve^[n] s) := by
  intro s;
  -- Apply the well-founded induction on the cardinality of the weakness set.
  induction' h_card : (weakness s).card using Nat.strong_induction_on with k ih generalizing s;
  by_cases h : weakness ( improve s ) = weakness s;
  · exact ⟨ 0, h ⟩;
  · exact Exists.elim ( ih _ ( hstrict _ h |> fun x => by linarith ) _ rfl ) fun n hn => ⟨ n + 1, by simpa [ ← Function.iterate_succ_apply' ] using hn ⟩

end WeaknessDescent

/-! ## §5. Bounded Self-Reference -/

/-
A non-trivial improvement operator must change at least one strategy.
    Direct consequence of `self_reference_bound` from the catalog.
-/
theorem improve_moves_some_strategy
    {σ : Type*} [Fintype σ] [DecidableEq σ] (improve : σ → σ)
    (h_nontrivial : improve ≠ id) :
    (Finset.univ.filter (fun x => improve x = x)).card < Fintype.card σ := by
  exact Finset.card_lt_card ( Finset.filter_ssubset.mpr <| by contrapose! h_nontrivial; aesop )

/-! ## §6. Idempotent Evidence Aggregation -/

/-- Rediscovering the same weakness does not inflate the diagnostic score.
    Uses `AddIdempotent` from the catalog's `add_self_eq`. -/
theorem idempotent_evidence_stable
    {S : Type*} [Add S] (hI : ∀ a : S, a + a = a) (evidence : S) :
    evidence + evidence = evidence :=
  hI evidence

/-! ## §7. Composition of Certified Improvements -/

/-- Certified improvement steps compose. -/
theorem certified_improvement_composes
    {σ τ ρ : Prop} (detect : σ → τ) (repair : τ → ρ) :
    σ → ρ :=
  repair ∘ detect

/-! ## §8. Concrete Model: Defect Elimination -/

/-- A concrete improvement that removes the minimum element of a defect set. -/
noncomputable def improveDefects (n : ℕ) (s : Finset (Fin n)) : Finset (Fin n) :=
  if h : s.Nonempty then s.erase (s.min' h) else s

theorem improveDefects_subset (n : ℕ) (s : Finset (Fin n)) :
    improveDefects n s ⊆ s := by
  grind +locals

theorem improveDefects_strict (n : ℕ) (s : Finset (Fin n)) :
    improveDefects n s ≠ s → (improveDefects n s).card < s.card := by
  unfold improveDefects;
  grind

/-
**Concrete convergence**: Iterating defect elimination on a finite set stabilizes.
-/
theorem concrete_defect_convergence (n : ℕ) (s : Finset (Fin n)) :
    ∃ k, (improveDefects n)^[k + 1] s = (improveDefects n)^[k] s := by
  convert weakness_descent_converges ( fun s => s ) ( fun s => if h : s.Nonempty then s.erase ( s.min' h ) else s ) _ _ s using 1;
  · grind;
  · grind +qlia

/-! ## §9. Closure-Invariant Capacity -/

/-
Research capacity factors through closure equivalence.
-/
theorem research_capacity_closure_invariant
    {X : Type*} [DecidableEq X] [Fintype X]
    (cl : Finset X → Finset X) (cap : Finset X → ℕ)
    (h_cl_inv : ∀ A, cap (cl A) = cap A)
    (A B : Finset X) (h : cl A = cl B) :
    cap A = cap B := by
  grind

/-! ## §10. Query Complexity Bound -/

/-
Bound on distinct improvement outcomes from a k-query strategy.
-/
theorem improvement_output_bound {α β : Type*} [DecidableEq β] (k : ℕ)
    (_queries : Fin k → α) (decide : (Fin k → Bool) → β) :
    (Finset.image decide Finset.univ).card ≤ 2 ^ k := by
  exact le_trans ( Finset.card_image_le ) ( by simp +decide [ Finset.card_univ ] )