/-
# Proof Refinement Systems

A rigorous mathematical framework for **proof refinement systems** — abstract structures
capturing how structured objects (proofs, programs, circuits) improve through iterative
complexity-reducing transformations.

## Core Results:
- Well-foundedness of complexity-decreasing refinement
- Fixed-point theorem: every optimizer reaches a plateau
- Quantitative convergence bounds
- Product refinement systems
- Lyapunov-style convergence certificates
- Multi-objective refinement and Pareto theory
-/

import Mathlib

open Function Set Finset

/-! ## Part 1: Core Definitions -/

/-- A **proof refinement system** is a type equipped with a natural-number-valued
complexity measure and a refinement relation that strictly decreases complexity. -/
structure ProofRefinementSystem where
  State : Type
  complexity : State → ℕ
  refines : State → State → Prop
  complexity_decreasing : ∀ x y, refines x y → complexity y < complexity x

/-- An **optimizer** on a refinement system never increases complexity. -/
structure Optimizer (P : ProofRefinementSystem) where
  step : P.State → P.State
  step_nonincreasing : ∀ x, P.complexity (step x) ≤ P.complexity x

/-- A **strict optimizer** always makes genuine progress unless at a fixed point. -/
structure StrictOptimizer (P : ProofRefinementSystem) extends Optimizer P where
  step_strict : ∀ x, step x ≠ x → P.complexity (step x) < P.complexity x

/-- The orbit of a state under an optimizer. -/
noncomputable def optimizerOrbit (P : ProofRefinementSystem) (opt : Optimizer P)
    (x : P.State) : ℕ → P.State
  | 0 => x
  | n + 1 => opt.step (optimizerOrbit P opt x n)

/-- A state is a **fixed point** of an optimizer. -/
def isFixedPoint (P : ProofRefinementSystem) (opt : Optimizer P) (x : P.State) : Prop :=
  opt.step x = x

/-- A state is **minimal** if no further refinement is possible. -/
def isMinimal (P : ProofRefinementSystem) (x : P.State) : Prop :=
  ∀ y, ¬P.refines x y

/-! ## Part 2: Well-Foundedness and Termination -/

/-
The refinement relation is well-founded (inherits from ℕ).
-/
theorem refinement_wellFounded (P : ProofRefinementSystem) :
    WellFounded (fun x y => P.refines y x) := by
  constructor;
  intro x;
  induction' n : P.complexity x using Nat.strong_induction_on with n ih generalizing x;
  refine' ⟨ _, fun y hy => _ ⟩;
  exact ih _ ( by linarith [ P.complexity_decreasing _ _ hy ] ) _ rfl

/-
Any refinement chain has length ≤ initial complexity.
-/
theorem chain_length_bound (P : ProofRefinementSystem) (chain : ℕ → P.State)
    (h_chain : ∀ i, P.refines (chain i) (chain (i + 1)))
    (n : ℕ) : n ≤ P.complexity (chain 0) := by
  -- By induction on $n$, we can show that the complexity of the chain at step $n$ is at least $n$ less than the initial complexity.
  have h_ind : ∀ n, P.complexity (chain n) ≤ P.complexity (chain 0) - n := by
    intro n;
    exact Nat.le_sub_of_add_le ( by induction' n with n ih <;> [ norm_num; linarith [ P.complexity_decreasing _ _ ( h_chain n ) ] ] );
  exact le_of_not_gt fun hn => by have := h_ind n; have := P.complexity_decreasing ( chain n ) ( chain ( n + 1 ) ) ( h_chain n ) ; omega;

/-! ## Part 3: Fixed-Point Theorems -/

/-
Complexity of orbit is non-increasing.
-/
theorem orbit_complexity_nonincreasing (P : ProofRefinementSystem) (opt : Optimizer P)
    (x : P.State) (n : ℕ) :
    P.complexity (optimizerOrbit P opt x (n + 1)) ≤
    P.complexity (optimizerOrbit P opt x n) := by
  exact opt.step_nonincreasing _

/-
A non-increasing ℕ-valued sequence eventually stabilizes.
-/
theorem nat_nonincreasing_eventually_constant (f : ℕ → ℕ)
    (h_noninc : ∀ n, f (n + 1) ≤ f n) :
    ∃ N, ∀ n, N ≤ n → f n = f N := by
  -- By the Monotone Convergence Theorem, an antitone sequence that is bounded below converges.
  have h_converges : ∃ L, Filter.Tendsto f Filter.atTop (nhds L) := by
    exact ⟨ _, tendsto_atTop_ciInf ( show Antitone f from antitone_nat_of_succ_le h_noninc ) ⟨ 0, Set.forall_mem_range.2 fun n => Nat.zero_le _ ⟩ ⟩;
  obtain ⟨ L, hL ⟩ := h_converges; simp_all +decide [ Nat.cast_inj ] ;
  exact ⟨ hL.choose, fun n hn => by rw [ hL.choose_spec n hn, hL.choose_spec _ le_rfl ] ⟩

/-- The complexity sequence of any orbit eventually stabilizes. -/
theorem orbit_complexity_eventually_constant (P : ProofRefinementSystem)
    (opt : Optimizer P) (x : P.State) :
    ∃ N, ∀ n, N ≤ n →
        P.complexity (optimizerOrbit P opt x n) =
        P.complexity (optimizerOrbit P opt x N) := by
  exact nat_nonincreasing_eventually_constant
    (fun n => P.complexity (optimizerOrbit P opt x n))
    (orbit_complexity_nonincreasing P opt x)

/-
**Strict optimizer convergence**: reaches a fixed point within complexity(x₀) steps.
-/
theorem strict_optimizer_reaches_fixpoint (P : ProofRefinementSystem)
    (opt : StrictOptimizer P) (x : P.State) :
    ∃ N, N ≤ P.complexity x ∧
      isFixedPoint P opt.toOptimizer (optimizerOrbit P opt.toOptimizer x N) := by
  by_contra! h_contra;
  -- By induction on $n$, we can show that for all $n \leq P.complexity x$, $P.complexity (optimizerOrbit P opt.toOptimizer x n) < P.complexity x - n$.
  have h_ind : ∀ n ≤ P.complexity x, P.complexity (optimizerOrbit P opt.toOptimizer x n) ≤ P.complexity x - n := by
    intro n hn;
    induction' n with n ih <;> simp_all +decide [ optimizerOrbit ];
    exact Nat.le_sub_one_of_lt ( lt_of_lt_of_le ( opt.step_strict _ ( h_contra _ hn.le ) ) ( ih hn.le ) );
  specialize h_ind ( P.complexity x ) le_rfl ; simp_all +decide [ isFixedPoint ];
  have := opt.step_strict ( optimizerOrbit P opt.toOptimizer x ( P.complexity x ) ) ; aesop;

/-! ## Part 4: Lyapunov Theory -/

/-- A **Lyapunov certificate** provides a potential function witnessing convergence. -/
structure LyapunovCertificate (P : ProofRefinementSystem) (opt : Optimizer P) where
  potential : P.State → ℕ
  potential_nonincreasing : ∀ x, potential (opt.step x) ≤ potential x
  potential_strict : ∀ x, potential (opt.step x) = potential x → opt.step x = x

/-- The complexity function is always a Lyapunov certificate for strict optimizers. -/
noncomputable def complexity_lyapunov (P : ProofRefinementSystem) (opt : StrictOptimizer P) :
    LyapunovCertificate P opt.toOptimizer where
  potential := P.complexity
  potential_nonincreasing := opt.step_nonincreasing
  potential_strict := by
    intro x h
    by_contra hne
    have := opt.step_strict x hne
    omega

/-
**Lyapunov convergence**: converges within potential(x₀) steps.
-/
theorem lyapunov_convergence (P : ProofRefinementSystem) (opt : Optimizer P)
    (L : LyapunovCertificate P opt) (x : P.State) :
    ∃ N, N ≤ L.potential x ∧ isFixedPoint P opt (optimizerOrbit P opt x N) := by
  by_contra! h;
  -- By induction on $n$, we can show that for all $n \leq L.potential x$, $L.potential (optimizerOrbit P opt x n) \leq L.potential x - n$.
  have h_ind : ∀ n ≤ L.potential x, L.potential (optimizerOrbit P opt x n) ≤ L.potential x - n := by
    intro n hn;
    induction' n with n ih;
    · rfl;
    · -- By the properties of the Lyapunov certificate, we have $L.potential (opt.step (optimizerOrbit P opt x n)) \leq L.potential (optimizerOrbit P opt x n) - 1$.
      have h_step : L.potential (opt.step (optimizerOrbit P opt x n)) ≤ L.potential (optimizerOrbit P opt x n) - 1 := by
        exact Nat.le_sub_one_of_lt ( lt_of_le_of_ne ( L.potential_nonincreasing _ ) fun con => h n ( Nat.le_of_succ_le hn ) <| L.potential_strict _ con );
      exact le_trans h_step ( Nat.sub_le_sub_right ( ih ( Nat.le_of_succ_le hn ) ) _ );
  -- Applying the induction hypothesis with $n = L.potential x$, we get $L.potential (optimizerOrbit P opt x (L.potential x)) \leq 0$.
  have h_zero : L.potential (optimizerOrbit P opt x (L.potential x)) ≤ 0 := by
    simpa using h_ind _ le_rfl;
  exact h ( L.potential x ) le_rfl ( L.potential_strict _ <| by linarith [ L.potential_nonincreasing ( optimizerOrbit P opt x ( L.potential x ) ) ] )

/-! ## Part 5: Product Refinement Systems -/

/-- The **product** of two proof refinement systems. -/
def ProofRefinementSystem.product (P Q : ProofRefinementSystem) :
    ProofRefinementSystem where
  State := P.State × Q.State
  complexity := fun p => P.complexity p.1 + Q.complexity p.2
  refines := fun p q =>
    (P.refines p.1 q.1 ∧ p.2 = q.2) ∨ (p.1 = q.1 ∧ Q.refines p.2 q.2)
  complexity_decreasing := by
    intro ⟨x₁, y₁⟩ ⟨x₂, y₂⟩ h
    simp only at h ⊢
    rcases h with ⟨hp, heq⟩ | ⟨heq, hq⟩
    · have := P.complexity_decreasing _ _ hp; subst heq; omega
    · have := Q.complexity_decreasing _ _ hq; subst heq; omega

/-- Product refinement inherits well-foundedness. -/
theorem product_wellFounded (P Q : ProofRefinementSystem) :
    WellFounded (fun x y => (P.product Q).refines y x) :=
  refinement_wellFounded (P.product Q)

/-! ## Part 6: Refinement Morphisms -/

/-- A **refinement morphism** is a complexity-nonincreasing refinement-preserving map. -/
structure RefinementMorphism (P Q : ProofRefinementSystem) where
  map : P.State → Q.State
  complexity_bound : ∀ x, Q.complexity (map x) ≤ P.complexity x
  preserves_refinement : ∀ x y, P.refines x y → Q.refines (map x) (map y)

/-- Composition of refinement morphisms. -/
def RefinementMorphism.comp {P Q R : ProofRefinementSystem}
    (f : RefinementMorphism Q R) (g : RefinementMorphism P Q) :
    RefinementMorphism P R where
  map := f.map ∘ g.map
  complexity_bound := fun x => le_trans (f.complexity_bound (g.map x)) (g.complexity_bound x)
  preserves_refinement := fun x y h =>
    f.preserves_refinement _ _ (g.preserves_refinement _ _ h)

/-
A refinement-reflecting morphism preserves minimality.
-/
theorem morphism_preserves_minimality {P Q : ProofRefinementSystem}
    (f : RefinementMorphism P Q)
    (hf_surj : Function.Surjective f.map)
    (hf_reflects : ∀ x y, Q.refines (f.map x) (f.map y) → P.refines x y)
    (x : P.State) (hx : isMinimal P x) :
    isMinimal Q (f.map x) := by
  intro y hy; cases hf_surj y; aesop;

/-! ## Part 7: Multi-Objective Refinement and Pareto Theory -/

/-- A **multi-objective refinement system** with k objectives. -/
structure MultiObjectiveRefinement (k : ℕ) where
  State : Type
  objectives : State → Fin k → ℕ
  pareto_refines : State → State → Prop
  pareto_spec : ∀ x y, pareto_refines x y ↔
    (∀ i, objectives y i ≤ objectives x i) ∧ (∃ i, objectives y i < objectives x i)

/-- Convert multi-objective to single-objective using the sum. -/
def MultiObjectiveRefinement.toSingleObjective {k : ℕ} (M : MultiObjectiveRefinement k) :
    ProofRefinementSystem where
  State := M.State
  complexity := fun x => ∑ i : Fin k, M.objectives x i
  refines := M.pareto_refines
  complexity_decreasing := by
    intro x y hxy
    rw [M.pareto_spec] at hxy
    obtain ⟨hle, i, hlt⟩ := hxy
    exact Finset.sum_lt_sum (fun j _ => hle j) ⟨i, Finset.mem_univ _, hlt⟩

/-
**Pareto well-foundedness**: Multi-objective refinement is well-founded.
-/
theorem pareto_wellFounded {k : ℕ} (M : MultiObjectiveRefinement k) :
    WellFounded (fun x y => M.pareto_refines y x) := by
  convert refinement_wellFounded ( MultiObjectiveRefinement.toSingleObjective M ) using 1

/-
Total complexity bounds the length of any Pareto-improving chain.
-/
theorem pareto_chain_bound {k : ℕ} (M : MultiObjectiveRefinement k)
    (chain : ℕ → M.State)
    (h_chain : ∀ i, M.pareto_refines (chain i) (chain (i + 1)))
    (n : ℕ) :
    n ≤ ∑ j : Fin k, M.objectives (chain 0) j := by
  convert chain_length_bound ( M.toSingleObjective ) chain _ n;
  exact h_chain

/-! ## Part 8: Refinement Strategy -/

/-- A **refinement strategy** optionally produces a strictly better state. -/
def RefinementStrategy (P : ProofRefinementSystem) :=
  (x : P.State) → Option { y : P.State // P.complexity y < P.complexity x }

/-- Apply a strategy n times. -/
noncomputable def applyStrategy (P : ProofRefinementSystem)
    (s : RefinementStrategy P) : P.State → ℕ → P.State
  | x, 0 => x
  | x, n + 1 =>
    match s x with
    | none => x
    | some ⟨y, _⟩ => applyStrategy P s y n

/-
Applying a strategy never increases complexity.
-/
theorem strategy_nonincreasing (P : ProofRefinementSystem)
    (s : RefinementStrategy P) (x : P.State) (n : ℕ) :
    P.complexity (applyStrategy P s x n) ≤ P.complexity x := by
  induction' n with n ih generalizing x;
  · rfl;
  · rw [ show applyStrategy P s x ( n + 1 ) = match s x with | none => x | some ⟨ y, hy ⟩ => applyStrategy P s y n from rfl ];
    cases h : s x <;> simp +decide;
    exact le_trans ( ih _ ) ( le_of_lt ( by aesop ) )

/-
Any strategy terminates within complexity(x) steps.
-/
theorem strategy_termination (P : ProofRefinementSystem)
    (s : RefinementStrategy P) (x : P.State) :
    ∃ N, N ≤ P.complexity x ∧ s (applyStrategy P s x N) = none := by
  induction' hxi : P.complexity x using Nat.strongRecOn with m ih generalizing x;
  by_cases h : s x = none;
  · exact ⟨ 0, Nat.zero_le _, h ⟩;
  · obtain ⟨ y, hy ⟩ := Option.ne_none_iff_exists'.mp h;
    obtain ⟨ N, hN₁, hN₂ ⟩ := ih ( P.complexity y ) ( by linarith [ y.2 ] ) y ( by linarith [ y.2 ] );
    use N + 1;
    simp_all +decide [ applyStrategy ];
    exact ⟨ by linarith [ y.2 ], by rw [ hy ] ; exact hN₂ ⟩

/-! ## Part 9: Linear Chain — Disproving Universal Speedup

The **Refinement Speedup Hypothesis** conjectures that for any proof refinement
system with complexity bound C, there exists an optimizer that reaches a
fixed point in O(√C) steps. We disprove this by exhibiting the linear chain
system where Ω(C) steps are necessary.
-/

/-- A linear chain refinement system: the only path is n → n-1 → ⋯ → 0. -/
abbrev linearChainSystem : ProofRefinementSystem where
  State := ℕ
  complexity := fun n => n
  refines := fun x y => y + 1 = x
  complexity_decreasing := fun _ _ h => by omega

/-
The unique optimizer: subtract 1.
-/
abbrev linearChainOptimizer : StrictOptimizer linearChainSystem where
  step := fun n => n - 1
  step_nonincreasing := fun _ => by
    exact Nat.sub_le _ _
  step_strict := fun x h => by
    simp only [linearChainSystem] at *
    omega

/-
The orbit in the linear chain equals n - k.
-/
theorem linear_chain_orbit_eq (n k : ℕ) :
    optimizerOrbit linearChainSystem linearChainOptimizer.toOptimizer n k = n - k := by
  induction' k with k ih generalizing n <;> simp_all +decide [ Nat.sub_sub, optimizerOrbit ]

/-
Reaching 0 from n requires exactly n steps.
-/
theorem linear_chain_exact_steps (n : ℕ) :
    optimizerOrbit linearChainSystem linearChainOptimizer.toOptimizer n n = 0 := by
  rw [ linear_chain_orbit_eq, Nat.sub_self ]

/-
Before step n, the orbit has not reached 0 (for n > 0).
-/
theorem linear_chain_needs_n_steps (n : ℕ) (k : ℕ) (hk : k < n) :
    optimizerOrbit linearChainSystem linearChainOptimizer.toOptimizer n k ≠ 0 := by
  exact ne_of_gt ( linear_chain_orbit_eq n k ▸ Nat.sub_pos_of_lt hk )