/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Reflective Convergence Architecture: Self-Modifying Research Strategies

This file formalizes *self-improving formal research* as a mathematical object:
a dependent transition system whose next-step strategy is chosen from certified
evidence extracted from previous outcomes. We prove three classes of theorems:

1. **Monotone convergence**: Under monotone improvement and boundedness,
   the quality sequence of a reflective research process converges.

2. **Finite stabilization**: Under strict progress on a finite strategy space,
   the process reaches a fixed point in finitely many steps.

3. **Local optimality**: Fixed points of a reflective selector that maximizes
   quality over admissible successors are locally optimal.

## Main Results

* `ResearchSystem` — A dependent transition system packaging states, strategies,
  outcomes, and quality evaluation.
* `reflective_iteration_converges` — Monotone bounded quality trajectories converge.
* `finite_reflective_stabilizes` — Strict progress on finite types implies stabilization.
* `reflective_fixedpoint_locallyOptimal` — Fixed points of quality-maximizing selectors
  are locally optimal.
* `LocallyOptimal` — Definition of local optimality relative to admissible moves.

## Cross-Domain Connections

- Dynamical systems: convergence of discrete orbits under Lyapunov-type conditions.
- Learning theory: policy iteration convergence for strategy improvement.
- Dependent type theory: state-indexed admissible moves as dependent types.
- Oracle complexity: bounded information extraction under reflective feedback.
-/

import Mathlib

open Filter Function Finset Topology

set_option maxHeartbeats 400000

/-! ## §1. Research System: Dependent Transition System -/

/-- A research system with outcome-dependent strategy spaces.
    Each state `s` determines a type `Strategy s` of admissible next strategies,
    and `outcome` produces the next state from a state-strategy pair.
    `quality` assigns a numerical score to each state. -/
structure ResearchSystem where
  State : Type
  Strategy : State → Type
  outcome : (s : State) → Strategy s → State
  quality : State → ℝ

/-! ## §2. Monotone Convergence of Reflective Iteration -/

/-- The quality sequence of a reflective iteration: `q n = quality (next^[n] s0)`. -/
def qualitySeq {State : Type*} (quality : State → ℝ) (next : State → State)
    (s0 : State) (n : ℕ) : ℝ :=
  quality (next^[n] s0)

/-
**Monotone convergence theorem for reflective iteration.**
    Any internally certified self-improvement operator with monotone bounded quality
    admits a limiting performance level. This is the foundational convergence result
    for reflective research processes.
-/
theorem reflective_iteration_converges
    {State : Type*}
    (quality : State → ℝ)
    (next : State → State)
    (s0 : State)
    (hmono : ∀ s, quality s ≤ quality (next s))
    (hbounded : BddAbove (Set.range fun n : ℕ => quality ((next^[n]) s0))) :
    ∃ L : ℝ, Tendsto (fun n : ℕ => quality ((next^[n]) s0)) atTop (𝓝 L) := by
  exact ⟨ _, tendsto_atTop_isLUB ( monotone_nat_of_le_succ fun n => by simpa only [ Function.iterate_succ_apply' ] using hmono _ ) ( isLUB_ciSup hbounded ) ⟩

/-
Helper: the quality sequence is monotone when each step improves quality.
-/
theorem qualitySeq_monotone
    {State : Type*}
    (quality : State → ℝ)
    (next : State → State)
    (s0 : State)
    (hmono : ∀ s, quality s ≤ quality (next s)) :
    Monotone (fun n : ℕ => quality ((next^[n]) s0)) := by
  exact monotone_nat_of_le_succ fun n => by simpa only [ Function.iterate_succ_apply' ] using hmono _;

/-
**Convergence theorem for `ResearchSystem`.**
    Given a dependent research system with a strategy selector, if every step
    improves quality and quality is bounded above, the trajectory converges.
-/
theorem ResearchSystem.exists_convergent_trajectory
    (R : ResearchSystem)
    (select : (s : R.State) → R.Strategy s)
    (s0 : R.State)
    (hmono : ∀ s, R.quality s ≤ R.quality (R.outcome s (select s)))
    (hbounded : BddAbove (Set.range fun n : ℕ =>
      R.quality ((fun x => R.outcome x (select x))^[n] s0))) :
    ∃ L : ℝ, Tendsto (fun n : ℕ =>
      R.quality ((fun x => R.outcome x (select x))^[n] s0)) atTop (𝓝 L) := by
  convert reflective_iteration_converges _ _ _ _ _;
  · grind +qlia;
  · grind +splitImp

/-! ## §3. Finite-State Stabilization Under Strict Progress -/

/-
**Finite stabilization theorem.**
    If strategy choices come from a finite space and each genuine update strictly
    improves a natural-number score, then the iteration eventually stabilizes
    at a fixed point. This is a genuine reflective theorem: finite self-modification
    with certified strict progress cannot oscillate forever.
-/
theorem finite_reflective_stabilizes
    {σ : Type*} [Fintype σ] [DecidableEq σ]
    (score : σ → ℕ)
    (update : σ → σ)
    (s0 : σ)
    (hstrict : ∀ s, update s ≠ s → score s < score (update s)) :
    ∃ N : ℕ, ∀ n ≥ N, (update^[n]) s0 = (update^[N]) s0 := by
  -- By the pigeonhole principle, since σ is finite, there exist indices i < j such that update^[i] s0 = update^[j] s0.
  obtain ⟨i, j, hij, h_eq⟩ : ∃ i j : ℕ, i < j ∧ (update^[i]) s0 = (update^[j]) s0 := by
    by_contra! h;
    exact absurd ( Set.infinite_range_of_injective ( fun i j hij => le_antisymm ( not_lt.1 fun hi => h _ _ hi hij.symm ) ( not_lt.1 fun hj => h _ _ hj hij ) ) ) ( Set.not_infinite.mpr <| Set.toFinite _ );
  -- Let N be the smallest index where update^[N+1] s0 = update^[N] s0 (if it never equals, we get a contradiction from the strictly increasing score bounded above).
  obtain ⟨N, hN⟩ : ∃ N : ℕ, update^[N+1] s0 = update^[N] s0 := by
    contrapose! h_eq;
    -- Since the score is strictly increasing, the sequence of scores is strictly increasing.
    have h_score_strict_mono : StrictMono (fun n => score (update^[n] s0)) := by
      refine' strictMono_nat_of_lt_succ fun n => _;
      simpa only [ Function.iterate_succ_apply' ] using hstrict _ ( by simpa only [ Function.iterate_succ_apply' ] using h_eq n );
    exact fun h => ne_of_lt ( h_score_strict_mono hij ) ( by simp +decide [ h ] );
  exact ⟨ N, fun n hn => by induction hn <;> simp_all +decide [ Function.iterate_succ_apply' ] ⟩

/-
The stabilized iterate is a genuine fixed point.
-/
theorem finite_reflective_stabilizes_fixedpoint
    {σ : Type*} [Fintype σ] [DecidableEq σ]
    (score : σ → ℕ)
    (update : σ → σ)
    (s0 : σ)
    (_hstrict : ∀ s, update s ≠ s → score s < score (update s))
    (N : ℕ) (hN : ∀ n ≥ N, (update^[n]) s0 = (update^[N]) s0) :
    update ((update^[N]) s0) = (update^[N]) s0 := by
  simpa [ ← Function.iterate_succ_apply' ] using hN ( N + 1 ) ( Nat.le_succ _ )

/-! ## §4. Local Optimality -/

/-- A state is **locally optimal** relative to admissible moves if no admissible
    successor has strictly higher quality. -/
def LocallyOptimal
    {State : Type*}
    (Admissible : State → Finset State)
    (quality : State → ℝ)
    (s : State) : Prop :=
  ∀ t, t ∈ Admissible s → quality t ≤ quality s

/-
**Fixed points of quality-maximizing selectors are locally optimal.**
    If `next s` always belongs to `Admissible s` and dominates all admissible
    successors in quality, then any fixed point of `next` is locally optimal.
    This is the type-theoretic centerpiece: a reflective architecture that can
    certify its own update choice transforms fixed points into internally
    verified local optima.
-/
theorem reflective_fixedpoint_locallyOptimal
    {State : Type*} [DecidableEq State]
    (Admissible : State → Finset State)
    (quality : State → ℝ)
    (next : State → State)
    (s : State)
    (hchoose : ∀ s, next s ∈ Admissible s ∧
      ∀ t, t ∈ Admissible s → quality t ≤ quality (next s))
    (hfix : next s = s) :
    ∀ t, t ∈ Admissible s → quality t ≤ quality s := by
  exact fun t ht => hfix ▸ hchoose s |>.2 t ht

/-
Equivalent formulation using `LocallyOptimal`.
-/
theorem reflective_fixedpoint_locallyOptimal'
    {State : Type*} [DecidableEq State]
    (Admissible : State → Finset State)
    (quality : State → ℝ)
    (next : State → State)
    (s : State)
    (hchoose : ∀ s, next s ∈ Admissible s ∧
      ∀ t, t ∈ Admissible s → quality t ≤ quality (next s))
    (hfix : next s = s) :
    LocallyOptimal Admissible quality s := by
  exact fun t ht => by simpa [ hfix ] using hchoose s |>.2 t ht;

/-! ## §5. Composition: From Stabilization to Local Optimality -/

/-
**Grand composition theorem.**
    For a finite-state reflective system with quality-maximizing admissible updates
    and strict score progress, the iteration stabilizes at a locally optimal state.
-/
theorem reflective_stabilizes_at_local_optimum
    {σ : Type*} [Fintype σ] [DecidableEq σ]
    (Admissible : σ → Finset σ)
    (quality : σ → ℝ)
    (score : σ → ℕ)
    (next : σ → σ)
    (s0 : σ)
    (hchoose : ∀ s, next s ∈ Admissible s ∧
      ∀ t, t ∈ Admissible s → quality t ≤ quality (next s))
    (hstrict : ∀ s, next s ≠ s → score s < score (next s)) :
    ∃ N : ℕ, LocallyOptimal Admissible quality ((next^[N]) s0) := by
  -- By finite_domain_stabilizes, we know there exists an N such that for all n ≥ N, next^[n] s0 = next^[N] s0.
  obtain ⟨N, hN⟩ :=
    finite_reflective_stabilizes score next s0 hstrict;
  -- By finite_domain_stabilizes_fixedpoint, we know that next^[N] s0 is a fixed point.
  have hfix : next (next^[N] s0) = next^[N] s0 := by
    simpa [ ← Function.iterate_succ_apply' ] using hN ( N + 1 ) ( Nat.le_succ _ );
  exact ⟨ N, fun t ht => by simpa [ hfix ] using hchoose _ |>.2 t ht ⟩

/-! ## §6. Sequence-Oriented Convergence -/

/-
**Monotone bounded real sequences converge.**
    This is the sequence-oriented core of reflective convergence:
    any monotone bounded-above sequence of quality scores has a limit.
-/
theorem reflective_quality_seq_converges
    (q : ℕ → ℝ)
    (hmono : Monotone q)
    (hbounded : BddAbove (Set.range q)) :
    ∃ L : ℝ, Tendsto q atTop (𝓝 L) := by
  exact ⟨ _, tendsto_atTop_isLUB hmono ( isLUB_ciSup hbounded ) ⟩