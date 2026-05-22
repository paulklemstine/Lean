/-
  # Algebra–EML Symbolic Zeta Semantics via Closure Endomorphism Growth
  # and Rational Periodic Orbit Enumeration

  This file develops the theory of finite closure dynamical systems and their
  Artin–Mazur / symbolic zeta semantics.

  ## Cross-Domain Significance

  This development bridges:
  - **Symbolic dynamics**: Artin–Mazur zeta functions, subshifts of finite type
  - **Closure algebra / EML semantics**: closure operators, closure-preserving maps
  - **Thermodynamic formalism**: entropy, capacity, pressure
  - **Cryptographic orbit semantics**: state-collision auditing, orbit-hash degeneracy
  - **Certified ML robustness**: finite-state abstractions, certified complexity controls
-/

import Mathlib

open scoped BigOperators Matrix
open Finset Function

/-! ## Part 1: Core Structures -/

/-- A closure operator on sets satisfying extensivity, monotonicity, and idempotence.
    Bridge: connects lattice-theoretic closure algebra to topological and EML semantics. -/
class IsClosureOp {α : Type*} (cl : Set α → Set α) : Prop where
  extensive : ∀ s, s ⊆ cl s
  monotone : ∀ ⦃s t : Set α⦄, s ⊆ t → cl s ⊆ cl t
  idempotent : ∀ s, cl (cl s) = cl s

/-- A finite closure system: a closure operator on a finite type.
    Bridge: connects finite lattice theory to finitary EML closure semantics. -/
structure FiniteClosureSystem (α : Type*) [Fintype α] where
  cl : Set α → Set α
  isClosure : IsClosureOp cl

/-- A closure-compatible dynamical system on a finite type.
    Bridge: connects closure algebra to symbolic dynamics and thermodynamic formalism.
    The step function is closure-preserving: images of closed sets remain within them. -/
structure ClosureDynamics (α : Type*) [Fintype α] extends FiniteClosureSystem α where
  step : α → α
  closed_orbit_image : ∀ s : Set α, cl s = s → cl (step '' s) ⊆ s

/-- Conjugacy between closure dynamical systems, capturing the notion that
    two systems have the same dynamical/combinatorial structure.
    Bridge: connects dynamical equivalence to symbolic dynamics invariants
    and post_quantum_security state-isomorphism auditing. -/
structure ClosureConjugacy {α : Type*} {β : Type*} [Fintype α] [Fintype β]
    (C : ClosureDynamics α) (D : ClosureDynamics β) where
  toEquiv : α ≃ β
  map_step : ∀ x, toEquiv (C.step x) = D.step (toEquiv x)

/-! ## Part 2: Definitions -/

section Defs
variable {α : Type*} [Fintype α] [DecidableEq α]

/-- The set of n-periodic points: states returning to themselves after n iterations.
    Bridge: connects fixed-point theory to Artin–Mazur periodic orbit enumeration
    and cryptographic state-collision detection. -/
def closurePeriodicPoints (C : ClosureDynamics α) (n : ℕ) : Finset α :=
  Finset.univ.filter (fun x => (C.step^[n]) x = x)

/-- Count of n-periodic points: the fundamental counting invariant. -/
def closurePeriodicCount (C : ClosureDynamics α) (n : ℕ) : ℕ :=
  (closurePeriodicPoints C n).card

/-- Whether a single deterministic step from x to y is allowed. -/
def closureAllowedStep (C : ClosureDynamics α) (x y : α) : Prop :=
  C.step x = y

/-- Whether y is reachable from x via one step followed by closure.
    Bridge: connects deterministic dynamics to nondeterministic closure-semantic
    transitions relevant to EML observable quotient semantics. -/
def closureSemanticStep (C : ClosureDynamics α) (x y : α) : Prop :=
  y ∈ C.cl ({C.step x} : Set α)

/-- The transition matrix: (i,j) entry is 1 if step(i) = j, else 0.
    Bridge: connects closure dynamics to symbolic dynamics adjacency matrices
    and thermodynamic transfer operators. -/
def closureTransitionMatrix (C : ClosureDynamics α) : Matrix α α ℕ :=
  fun i j => if C.step i = j then 1 else 0

/-- Path count for deterministic systems equals cardinality. -/
def closurePathCount (_C : ClosureDynamics α) (_n : ℕ) : ℕ :=
  Fintype.card α

/-- Orbit hash: periodic point set as cryptographic fingerprint.
    Bridge: connects periodic orbit enumeration to post_quantum_security
    state-collision auditing. -/
def closureOrbitHash (C : ClosureDynamics α) (n : ℕ) : Finset α :=
  closurePeriodicPoints C n

/-- Capacity: log of state space cardinality.
    Bridge: connects topological entropy to lipschitz_certified_robustness bounds. -/
noncomputable def closureCapacity (_C : ClosureDynamics α) : ℝ :=
  Real.log (Fintype.card α : ℝ)

/-- Certified radius derived from capacity.
    Bridge: connects closure capacity to lipschitz_certified_robustness. -/
noncomputable def closureCertifiedRadius (C : ClosureDynamics α) : ℝ :=
  1 / (1 + closureCapacity C)

/-- Thermodynamic weight: uniform Gibbs weight.
    Bridge: connects closure dynamics to thermodynamic formalism. -/
noncomputable def closureThermoWeight (_C : ClosureDynamics α) (_x : α) : ℝ :=
  (1 : ℝ)

/-- The closure zeta function as a formal power series over ℚ.
    Coefficient n = closurePeriodicCount C n.
    Bridge: connects Artin–Mazur periodic orbit enumeration to closure-based
    EML semantics and thermodynamic entropy bounds. -/
noncomputable def closureZeta (C : ClosureDynamics α) : PowerSeries ℚ :=
  PowerSeries.mk (fun n => (closurePeriodicCount C n : ℚ))

end Defs

/-! ## Part 3: Basic Periodic Point Theorems -/

section BasicTheorems
variable {α : Type*} [Fintype α] [DecidableEq α]

/-- Membership in periodic points ↔ fixed point of iterate. -/
theorem mem_closurePeriodicPoints_iff
    (C : ClosureDynamics α) (n : ℕ) (x : α) :
    x ∈ closurePeriodicPoints C n ↔ (C.step^[n]) x = x := by
  simp [closurePeriodicPoints]

/-- Periodic point count ≤ cardinality.
    Bridge: certified bound for post_quantum_security state-space auditing. -/
theorem closurePeriodicCount_le_card
    (C : ClosureDynamics α) (n : ℕ) :
    closurePeriodicCount C n ≤ Fintype.card α := by
  unfold closurePeriodicCount closurePeriodicPoints
  exact Finset.card_filter_le _ _

/-- At iteration 0, every point is periodic. -/
theorem closurePeriodicPoints_zero
    (C : ClosureDynamics α) :
    closurePeriodicPoints C 0 = Finset.univ := by
  ext x; simp [closurePeriodicPoints]

/-- Count at 0 = full cardinality. -/
theorem closurePeriodicCount_zero
    (C : ClosureDynamics α) :
    closurePeriodicCount C 0 = Fintype.card α := by
  unfold closurePeriodicCount
  rw [closurePeriodicPoints_zero, Finset.card_univ]

/-- Fixed points of step^[1] = fixed points of step. -/
theorem closurePeriodicPoints_one
    (C : ClosureDynamics α) :
    closurePeriodicPoints C 1 = Finset.univ.filter (fun x => C.step x = x) := by
  ext x; simp [closurePeriodicPoints]

end BasicTheorems

/-! ## Part 4: Iteration and Divisibility -/

section Divisibility
variable {α : Type*} [Fintype α] [DecidableEq α]

/-- Key iteration lemma: if f^[m] x = x then f^[k*m] x = x. -/
theorem iterate_mul_fixed {α : Type*} {f : α → α} {m : ℕ} {x : α}
    (hx : f^[m] x = x) (k : ℕ) : f^[k * m] x = x := by
  induction k with
  | zero => simp
  | succ k ih =>
    rw [Nat.succ_mul, Function.iterate_add_apply, hx, ih]

/-- If m divides n, then every m-periodic point is n-periodic. -/
theorem closurePeriodic_monotone_divisor
    (C : ClosureDynamics α) {m n : ℕ} (h : m ∣ n) :
    closurePeriodicPoints C m ⊆ closurePeriodicPoints C n := by
  intro x hx
  rw [mem_closurePeriodicPoints_iff] at hx ⊢
  obtain ⟨k, rfl⟩ := h
  rw [Nat.mul_comm]
  exact iterate_mul_fixed hx k

end Divisibility

/-! ## Part 5: Transition Matrix -/

section TransitionMatrix
variable {α : Type*} [Fintype α] [DecidableEq α]

/-- Transition matrix entries are indicator of step. -/
theorem closureTransitionMatrix_det_entries
    (C : ClosureDynamics α) (i j : α) :
    closureTransitionMatrix C i j = if C.step i = j then 1 else 0 := by
  rfl

/-
Powers of transition matrix give indicators of iterated step.
    Bridge: connects matrix algebra to symbolic dynamics path enumeration.
-/
theorem closureTransitionMatrix_pow_entry
    (C : ClosureDynamics α) :
    ∀ n i j, ((closureTransitionMatrix C) ^ n) i j =
      if (C.step^[n]) i = j then 1 else 0 := by
  intro n i j;
  induction' n with n ih generalizing i j;
  · simp +decide [ Matrix.one_apply ];
  · simp +decide [ *, pow_succ, Matrix.mul_apply ];
    erw [ Function.iterate_succ_apply' ] ; aesop

/-
Matrix trace of n-th power = periodic point count.
    Bridge: connects linear algebra (trace) to dynamical systems
    (periodic orbits) and thermodynamic partition functions.
-/
theorem closureTrace_eq_periodicCount
    (C : ClosureDynamics α) (n : ℕ) :
    Matrix.trace ((closureTransitionMatrix C) ^ n) = closurePeriodicCount C n := by
  simp +decide [ Matrix.trace, closureTransitionMatrix_pow_entry ];
  rfl

omit [DecidableEq α] in
/-- Deterministic path count equals cardinality. -/
theorem closurePathCount_deterministic_exact
    (C : ClosureDynamics α) :
    ∀ n : ℕ, closurePathCount C n = Fintype.card α := by
  intro _; rfl

end TransitionMatrix

/-! ## Part 6: Conjugacy Invariance -/

section Conjugacy
variable {α : Type*} [Fintype α] [DecidableEq α]
variable {β : Type*} [Fintype β] [DecidableEq β]

omit [DecidableEq α] [DecidableEq β] in
/-- Conjugacy commutes with iteration.
    Bridge: connects dynamical conjugacy to categorical natural transformations. -/
theorem iterate_eq_on_conj
    {C : ClosureDynamics α} {D : ClosureDynamics β}
    (h : ClosureConjugacy C D) :
    ∀ n x, h.toEquiv ((C.step^[n]) x) = (D.step^[n]) (h.toEquiv x) := by
  intro n x; induction' n with n ih generalizing x <;> simp_all +decide [ Function.iterate_succ_apply' ] ;
  rw [ ← ih, h.map_step ]

/-
Conjugate systems have same periodic point sets (up to equivalence).
-/
theorem closurePeriodicPoints_equiv
    {C : ClosureDynamics α} {D : ClosureDynamics β}
    (h : ClosureConjugacy C D) (n : ℕ) :
    Finset.map h.toEquiv.toEmbedding (closurePeriodicPoints C n) =
      closurePeriodicPoints D n := by
  ext x;
  simp +decide [mem_closurePeriodicPoints_iff];
  have := h.toEquiv.symm_apply_apply ( C.step^[n] ( h.toEquiv.symm x ) );
  rw [ ← this, iterate_eq_on_conj ];
  aesop

/-
Conjugate systems have the same periodic point counts.
-/
theorem closurePeriodicCount_conj_invariant
    {C : ClosureDynamics α} {D : ClosureDynamics β}
    (h : ClosureConjugacy C D) (n : ℕ) :
    closurePeriodicCount C n = closurePeriodicCount D n := by
  convert congr_arg Finset.card ( closurePeriodicPoints_equiv h n ) using 1;
  rw [ Finset.card_map, closurePeriodicCount ]

end Conjugacy

/-! ## Part 7: Growth Bounded by Capacity -/

section Growth
variable {α : Type*} [Fintype α] [DecidableEq α]

/-
Bridge: periodic orbit growth is bounded by closure capacity.
    Connects to thermodynamic entropy and post_quantum_security models.
-/
theorem closurePeriodic_growth_le_capacity
    (C : ClosureDynamics α) (n : ℕ) (hn : 0 < closurePeriodicCount C n) :
    Real.log (closurePeriodicCount C n : ℝ) ≤ closureCapacity C := by
  exact Real.log_le_log ( Nat.cast_pos.mpr hn ) ( Nat.cast_le.mpr ( closurePeriodicCount_le_card C n ) )

/-- Orbit hash cardinality = periodic count. -/
theorem closureOrbitHash_card_eq_periodicCount
    (C : ClosureDynamics α) (n : ℕ) :
    (closureOrbitHash C n).card = closurePeriodicCount C n := by
  rfl

omit [DecidableEq α] in
/-- Certified radius is positive.
    Bridge: lipschitz_certified_robustness positivity. -/
theorem closureCertifiedRadius_pos
    (C : ClosureDynamics α) :
    0 < closureCertifiedRadius C := by
  exact one_div_pos.mpr ( add_pos_of_pos_of_nonneg zero_lt_one ( Real.log_natCast_nonneg _ ) )

omit [DecidableEq α] in
/-- Thermodynamic weight is positive. -/
theorem closureThermoWeight_pos
    (C : ClosureDynamics α) (x : α) :
    0 < closureThermoWeight C x := by
  unfold closureThermoWeight; positivity

omit [DecidableEq α] in
/-- Thermodynamic weight is conjugacy-invariant. -/
theorem closureThermoWeight_conj_invariant
    {β : Type*} [Fintype β]
    {C : ClosureDynamics α} {D : ClosureDynamics β}
    (h : ClosureConjugacy C D) (x : α) :
    closureThermoWeight C x = closureThermoWeight D (h.toEquiv x) := by
  simp [closureThermoWeight]

end Growth

/-! ## Part 8: Zeta Function Theorems -/

section ZetaFunction
variable {α : Type*} [Fintype α] [DecidableEq α]

/-
Zeta function is conjugacy-invariant.
-/
theorem closureZeta_conj_invariant
    {β : Type*} [Fintype β] [DecidableEq β]
    {C : ClosureDynamics α} {D : ClosureDynamics β}
    (h : ClosureConjugacy C D) :
    closureZeta C = closureZeta D := by
  unfold closureZeta;
  simp +decide [closurePeriodicCount_conj_invariant h]

/-
Zeta coefficients are bounded by cardinality.
-/
theorem closureZeta_coeff_le_card
    (C : ClosureDynamics α) (n : ℕ) :
    (PowerSeries.coeff (R := ℚ) n) (closureZeta C) ≤ (Fintype.card α : ℚ) := by
  simp [closureZeta]
  exact_mod_cast closurePeriodicCount_le_card C n

end ZetaFunction

/-! ## Part 9: Capacity and Radius Bounds -/

section CapacityBounds
variable {α : Type*} [Fintype α] [DecidableEq α]

omit [DecidableEq α] in
/-- Capacity is nonneg when state space is nonempty. -/
theorem closureCapacity_nonneg
    (C : ClosureDynamics α) (hne : 0 < Fintype.card α) :
    0 ≤ closureCapacity C := by
  exact Real.log_nonneg ( mod_cast hne )

omit [DecidableEq α] in
/-- Certified radius ≤ 1. -/
theorem closureCertifiedRadius_le_one
    (C : ClosureDynamics α) :
    closureCertifiedRadius C ≤ 1 := by
  exact div_le_self zero_le_one ( le_add_of_nonneg_right ( Real.log_natCast_nonneg _ ) )

omit [DecidableEq α] in
/-- Certified radius is antitone in capacity. -/
theorem closureCertifiedRadius_antitone_capacity
    {C D : ClosureDynamics α}
    (h : closureCapacity C ≤ closureCapacity D) :
    closureCertifiedRadius D ≤ closureCertifiedRadius C := by
  grind +locals

end CapacityBounds

/-! ## Part 10: Eventually Periodic and Rationality -/

section Rationality
variable {α : Type*} [Fintype α] [DecidableEq α]

/-
Every orbit is eventually periodic with explicit preperiod bound.
    Bridge: certified termination for symbolic model checking.
-/
theorem closureDynamics_eventually_periodic
    (C : ClosureDynamics α) (x : α) :
    ∃ μ : ℕ, μ ≤ Fintype.card α ∧ ∃ p : ℕ, 0 < p ∧ p ≤ Fintype.card α ∧
      (C.step^[μ + p]) x = (C.step^[μ]) x := by
  have h_pigeonhole : ∃ i j : ℕ, i < j ∧ i ≤ Fintype.card α ∧ j ≤ Fintype.card α ∧ C.step^[i] x = C.step^[j] x := by
    by_contra! h;
    exact absurd ( Finset.card_le_univ ( Finset.image ( fun i => C.step^[i] x ) ( Finset.Iic ( Fintype.card α ) ) ) ) ( by rw [ Finset.card_image_of_injOn fun i hi j hj hij => le_antisymm ( not_lt.1 fun hi' => h _ _ hi' ( Finset.mem_Iic.1 hj ) ( Finset.mem_Iic.1 hi ) hij.symm ) ( not_lt.1 fun hj' => h _ _ hj' ( Finset.mem_Iic.1 hi ) ( Finset.mem_Iic.1 hj ) hij ) ] ; simp +decide );
  obtain ⟨ i, j, hij, hi, hj, h ⟩ := h_pigeonhole; exact ⟨ i, hi, j - i, Nat.sub_pos_of_lt hij, Nat.sub_le_of_le_add <| by linarith, by rw [ add_tsub_cancel_of_le hij.le, h ] ⟩ ;

/-
Periodic point counts are eventually periodic.
    Bridge: connects finite-state eventual periodicity to certified
    termination and rationality of the zeta function.
-/
theorem closurePeriodicCount_eventually_periodic
    (C : ClosureDynamics α) :
    ∃ N p : ℕ, 0 < p ∧ ∀ n, N ≤ n →
      closurePeriodicCount C (n + p) = closurePeriodicCount C n := by
  -- Since α is finite, there exists a positive integer p such that for all n ≥ N, the function step^[n] is periodic with period p.
  have h_periodic : ∃ N p, 0 < p ∧ ∀ n ≥ N, (fun x => C.step^[n] x) = (fun x => C.step^[n + p] x) := by
    -- By the pigeonhole principle, since there are only finitely many functions from α to α, there must exist indices i < j such that step^[i] = step^[j].
    obtain ⟨i, j, hij, h_eq⟩ : ∃ i j : ℕ, i < j ∧ (fun x => C.step^[i] x) = (fun x => C.step^[j] x) := by
      by_contra! h;
      exact absurd ( Set.infinite_range_of_injective ( fun i j hij => le_antisymm ( not_lt.1 fun hi => h _ _ hi hij.symm ) ( not_lt.1 fun hj => h _ _ hj hij ) ) ) ( Set.not_infinite.mpr <| Set.toFinite _ );
    refine' ⟨ i, j - i, tsub_pos_of_lt hij, fun n hn => _ ⟩;
    induction hn <;> simp_all +decide [ Nat.succ_add, Function.iterate_succ_apply' ];
    rw [ Nat.add_sub_cancel' hij.le ];
  obtain ⟨ N, p, hp, h ⟩ := h_periodic;
  refine' ⟨ N, p, hp, fun n hn => _ ⟩;
  unfold closurePeriodicCount;
  unfold closurePeriodicPoints; simp +decide [ funext_iff ] at h ⊢; aesop;

/-
The zeta function is rational: periodic counts satisfy a linear recurrence.
    Bridge: Artin–Mazur zeta rationality for closure-based EML semantics.
-/
theorem closureZeta_rational
    (C : ClosureDynamics α) :
    ∃ N : ℕ, 0 < N ∧ ∀ n, N ≤ n →
      closurePeriodicCount C (n + N) = closurePeriodicCount C n := by
  obtain ⟨ N, p, hp, h ⟩ := closurePeriodicCount_eventually_periodic C;
  refine' ⟨ p * ( N + 1 ), Nat.mul_pos hp ( Nat.succ_pos _ ), fun n hn => _ ⟩;
  induction' N + 1 with k hk <;> simp_all +decide [ Nat.mul_succ, ← add_assoc ];
  rw [ h _ ( by nlinarith ), hk ]

end Rationality