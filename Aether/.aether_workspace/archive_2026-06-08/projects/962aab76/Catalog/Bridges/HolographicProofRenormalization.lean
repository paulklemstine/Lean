/-
# Holographic Proof Renormalization

This file formalizes a mathematical framework treating proof normalization as
renormalization group (RG) flow on a discrete proof-state space equipped with
a complexity valuation.

## Main Results

1. **RG Termination**: Any renormalization operator with strict descent away from
   fixed points reaches a fixed point in at most `valuation x` steps.

2. **Orbital Minimality**: The fixed point reached by RG flow has minimal valuation
   along the entire orbit.

3. **Semantic Stability**: Semantics-preserving renormalization operators preserve
   semantics along all iterates.

4. **Tropical-Ultrametric Distance Bounds Semantics**: A Lipschitz semantic map
   has its semantic distance controlled by a tropical/ultrametric proof distance.

5. **Decidable Approximate Theoremhood**: In a finite proof space, the existence
   of a proof state of bounded valuation satisfying a semantic predicate is decidable.

6. **Finite Orbit Theorem**: Every orbit in a finite type is eventually periodic,
   and strict valuation descent sharpens this to eventual fixedness.

## Cross-Domain Connections

- **p-adic geometry**: Valuation measures complexity; descent mirrors contraction.
- **Tropical geometry**: Distance via min/max of valuations.
- **Renormalization group**: Coarse-graining on derivations; fixed points as
  universality classes.
- **Dynamical systems**: Lyapunov descent; no-cycle principle.
-/

import Mathlib

/-! ## Basic Definitions -/

/-- A proof state consists of size, depth, and number of cuts. -/
structure ProofState where
  size : ℕ
  depth : ℕ
  cuts  : ℕ
deriving DecidableEq, Repr

/-- Complexity valuation: total of size, depth, and cuts. -/
def valuation (x : ProofState) : ℕ := x.size + x.depth + x.cuts

/-- A renormalization operator on proof states. -/
abbrev RenormOp := ProofState → ProofState

/-- `R` never increases complexity. -/
def IsComplexityNonincreasing (R : RenormOp) : Prop :=
  ∀ x, valuation (R x) ≤ valuation x

/-- `R` strictly decreases complexity when not at a fixed point. -/
def IsStrictAwayFromFixed (R : RenormOp) : Prop :=
  ∀ x, R x ≠ x → valuation (R x) < valuation x

/-! ## Target 1: Finite RG Flow Reaches a Fixed Point -/

/-
**Key lemma**: Valuation decreases strictly at each non-fixed iterate step.
-/
lemma valuation_iterate_lt_of_not_fixed
    (R : RenormOp) (hstrict : IsStrictAwayFromFixed R)
    (x : ProofState) (n : ℕ)
    (hne : R^[n] x ≠ R^[n + 1] x) :
    valuation (R^[n + 1] x) < valuation (R^[n] x) := by
  convert hstrict _;
  swap;
  exact R^[n] x;
  simp_all +decide [ Function.iterate_succ_apply' ];
  tauto

/-
**Key lemma**: Valuation is nonincreasing along iterates under strict descent.
-/
lemma valuation_iterate_le
    (R : RenormOp) (hstrict : IsStrictAwayFromFixed R)
    (x : ProofState) (n : ℕ) :
    valuation (R^[n] x) ≤ valuation x := by
  induction' n with n ih;
  · rfl;
  · -- By the strictness condition, if $R^[n] x \neq R^[n+1] x$, then $valuation (R^[n+1] x) < valuation (R^[n] x)$.
    by_cases hne : R^[n] x ≠ R^[n+1] x;
    · exact le_trans ( valuation_iterate_lt_of_not_fixed R hstrict x n hne |> le_of_lt ) ih;
    · lia

/-
**Theorem (RG Termination with Bound)**: Any renormalization operator with strict
descent away from fixed points reaches a fixed point within `valuation x` steps.
This is the formal nucleus of "RG flow on proof spaces converges to minimal proofs."
The bound `n ≤ valuation x` is the real content: proof normalization is quantitatively
controlled by valuation energy.
-/
theorem exists_fixed_point_on_orbit_with_bound
    (R : RenormOp)
    (hstrict : IsStrictAwayFromFixed R) :
    ∀ x : ProofState, ∃ n ≤ valuation x, R^[n] x = R^[n + 1] x := by
  intro x;
  by_contra! h;
  -- By induction on $n$, we can show that $valuation (R^[n] x) \leq valuation x - n$.
  have h_induction : ∀ n ≤ valuation x, valuation (R^[n] x) ≤ valuation x - n := by
    intro n hn;
    induction' n with n ih;
    · norm_num;
    · exact Nat.le_sub_one_of_lt ( lt_of_lt_of_le ( valuation_iterate_lt_of_not_fixed R hstrict x n ( h n ( Nat.le_of_succ_le hn ) ) ) ( ih ( Nat.le_of_succ_le hn ) ) );
  specialize h_induction ( valuation x ) le_rfl ; simp_all +decide [ Function.iterate_succ_apply' ];
  specialize h ( valuation x ) le_rfl;
  have := hstrict ( R^[valuation x] x ) ; simp_all +decide [ valuation ] ;

/-! ## Target 2: Fixed Points are Valuation-Minimal on the Orbit -/

/-
**Theorem (Orbital Minimality)**: The fixed point reached by RG flow has minimal
valuation along the entire orbit. This upgrades mere convergence into a variational
principle: RG fixed points are orbitwise minimal representatives — the mathematically
respectable version of "minimal proofs."
-/
theorem fixed_point_orbit_minimal
    (R : RenormOp)
    (hstrict : IsStrictAwayFromFixed R) :
    ∀ x : ProofState,
      ∃ y : ProofState,
        (∃ n, R^[n] x = y) ∧
        R y = y ∧
        ∀ m, valuation y ≤ valuation (R^[m] x) := by
  intro x
  obtain ⟨n, hn⟩ := exists_fixed_point_on_orbit_with_bound R hstrict x
  use R^[n] x;
  refine' ⟨ ⟨ n, rfl ⟩, _, _ ⟩;
  · simpa [ ← Function.iterate_succ_apply' ] using hn.2.symm;
  · intro m
    by_cases hm : m ≤ n;
    · have h_le : ∀ k ≥ m, valuation (R^[k] x) ≤ valuation (R^[m] x) := by
        intro k hk; induction hk <;> simp_all +decide [ Function.iterate_succ_apply' ] ;
        exact le_trans ( valuation_iterate_le R hstrict _ 1 ) ‹_›;
      exact h_le n hm;
    · rw [ show R^[m] x = R^[n] x from _ ];
      exact Nat.le_induction ( by tauto ) ( fun k hk ih => by rw [ Function.iterate_succ_apply', ih, ← Function.iterate_succ_apply' R n x, hn.2 ] ) m ( not_le.mp hm )

/-! ## Target 3: Semantic Stability and Distance Bounds -/

/-- Semantic space: a finite binary type. -/
abbrev Semantics := Fin 2

/-- Semantic distance: 0 if equal, 1 if different. -/
def semDist (a b : Semantics) : ℕ := if a = b then 0 else 1

/-- Tropical/ultrametric-flavored proof distance. Two distinct states are
separated by `1 + max(v(x), v(y))`, reflecting that higher-complexity states
are further from everything in the ultrametric topology. -/
def proofDist (x y : ProofState) : ℕ :=
  if x = y then 0 else Nat.succ (max (valuation x) (valuation y))

/-- A semantic map from proof states to semantics. -/
abbrev SemanticsMap := ProofState → Semantics

/-- Lipschitz condition: semantic distance is bounded by proof distance. -/
def SemanticsLipschitz (σ : SemanticsMap) : Prop :=
  ∀ x y, semDist (σ x) (σ y) ≤ proofDist x y

/-- `R` preserves semantics. -/
def SemanticsPreserving (R : RenormOp) (σ : SemanticsMap) : Prop :=
  ∀ x, σ (R x) = σ x

/-
**Theorem (Tropical Distance Bounds Semantics)**: Semantic distance is
controlled by the tropical/ultrametric proof distance for any Lipschitz semantic map.
This creates the bridge: proof geometry bounds semantic divergence.
-/
theorem tropical_ultrametric_bounds_semantics
    (σ : SemanticsMap)
    (hσ : SemanticsLipschitz σ) :
    ∀ x y : ProofState, semDist (σ x) (σ y) ≤ proofDist x y := by
  assumption

/-
**Theorem (Semantic Stability under RG Flow)**: If `R` preserves semantics,
then semantics is invariant along all iterates. This is the formal essence of
"compression without semantic loss."
-/
theorem renorm_semantic_stability
    (R : RenormOp) (σ : SemanticsMap)
    (hσ : SemanticsPreserving R σ) :
    ∀ n x, σ (R^[n] x) = σ x := by
  exact fun n x => Nat.recOn n rfl fun n ih => by rw [ Function.iterate_succ_apply', hσ, ih ] ;

/-! ## Target 4: Decidable Approximate Theoremhood -/

/-- Approximate theoremhood at scale `k`: there exists a proof state of
valuation at most `k` whose semantics satisfies `T`. -/
def ApproxTheoremhood (σ : SemanticsMap) (T : Semantics → Prop) [DecidablePred T] (k : ℕ) : Prop :=
  ∃ x : ProofState, valuation x ≤ k ∧ T (σ x)

/-
**Theorem (Decidable Approximate Theoremhood, Fintype version)**:
In a finite proof space, bounded-scale theoremhood is decidable. This is the
first mathematically honest version of the claim that holographic renormalization
yields a decidable approximation to theoremhood.
-/
instance decidable_approx_theoremhood_fintype
    {P : Type} [Fintype P] [DecidableEq P]
    (v : P → ℕ) (σ : P → Semantics)
    (T : Semantics → Prop) [DecidablePred T] (k : ℕ) :
    Decidable (∃ x : P, v x ≤ k ∧ T (σ x)) :=
  inferInstance

/-! ## Target 5: Finite Orbit Theorem -/

/-
**Theorem (Bounded Orbit Eventually Periodic)**: Every orbit in a finite type
is eventually periodic. This imports finite dynamical systems into proof theory.
-/
theorem bounded_orbit_eventually_periodic
    {P : Type} [Fintype P] [DecidableEq P]
    (R : P → P) :
    ∀ x : P, ∃ m n : ℕ, m < n ∧ R^[m] x = R^[n] x := by
  intro x;
  by_contra! h;
  exact absurd ( Set.infinite_range_of_injective ( fun m n mn => le_antisymm ( not_lt.1 fun contra => h _ _ contra mn.symm ) ( not_lt.1 fun contra => h _ _ contra mn ) ) ) ( Set.not_infinite.mpr <| Set.toFinite _ )

/-
**Theorem (Strict Descent implies Eventual Fixedness)**: In a finite type
with a valuation, strict descent rules out nontrivial cycles, yielding
eventual fixedness rather than mere periodicity.
-/
theorem strict_descent_eventual_fixed
    {P : Type} [Fintype P] [DecidableEq P]
    (R : P → P) (v : P → ℕ)
    (hstrict : ∀ x, R x ≠ x → v (R x) < v x) :
    ∀ x : P, ∃ n : ℕ, R^[n] x = R^[n + 1] x := by
  intro x;
  by_contra! h;
  -- By the properties of the valuation function and the strict descent condition, the sequence $v(R^n(x))$ is strictly decreasing.
  have h_decreasing : StrictAnti (fun n => v (R^[n] x)) := by
    refine' strictAnti_nat_of_succ_lt _;
    exact fun n => by simpa only [ Function.iterate_succ_apply' ] using hstrict _ ( by simpa only [ Function.iterate_succ_apply' ] using Ne.symm ( h n ) ) ;
  exact absurd ( Set.infinite_range_of_injective h_decreasing.injective ) ( Set.not_infinite.mpr <| Set.finite_iff_bddAbove.mpr ⟨ _, Set.forall_mem_range.mpr fun n => h_decreasing.antitone n.zero_le ⟩ )

/-! ## Concrete Model: Cut-Elimination Renormalization -/

/-- A concrete renormalization step: eliminate one cut. -/
def renormStep (x : ProofState) : ProofState :=
  if x.cuts = 0 then x
  else { x with cuts := x.cuts - 1 }

/-
The concrete renormalization step never increases valuation.
-/
theorem renormStep_nonincreasing : IsComplexityNonincreasing renormStep := by
  unfold renormStep;
  -- By definition of `valuation`, we have `valuation x = x.size + x.depth + x.cuts`.
  intro x
  simp [valuation];
  split_ifs <;> simp +arith +decide

/-
The concrete renormalization step strictly decreases valuation away from fixed points.
-/
theorem renormStep_strict_away_from_fixed : IsStrictAwayFromFixed renormStep := by
  grind +locals

/-
**Theorem (Concrete RG Convergence)**: The cut-elimination step reaches a
fixed point within `valuation x` steps.
-/
theorem renormStep_converges :
    ∀ x : ProofState, ∃ n ≤ valuation x, renormStep^[n] x = renormStep^[n + 1] x := by
  -- Apply the theorem `exists_fixed_point_on_orbit_with_bound` with the given hypotheses.
  apply exists_fixed_point_on_orbit_with_bound;
  -- Apply the theorem that states the renormStep is strictly away from fixed points.
  apply renormStep_strict_away_from_fixed

/-! ## Ultrametric Triangle Inequality -/

/-
`proofDist` satisfies the ultrametric (strong) triangle inequality:
`proofDist x z ≤ max (proofDist x y) (proofDist y z)`.
This is the key structural property distinguishing ultrametric from ordinary
metric spaces, establishing that proof distance induces an ultrametric-like
structure on proof states.
-/
theorem proofDist_ultrametric (x y z : ProofState) :
    proofDist x z ≤ max (proofDist x y) (proofDist y z) := by
  by_cases hxz : x = z <;> by_cases hxy : x = y <;> by_cases hyz : y = z <;> simp_all +decide [ proofDist ];
  grobner