/-
# Prompt Optimization as Closure Theory via Galois Connections

This file formalizes the theory of prompt optimization as a closure process
induced by a Galois connection between prompt space and quality space.

## Main Results

### Theorem A — Closure Operator
* `promptClosure_isClosureOperator`: `back ∘ eval` from a Galois connection is a closure
  operator: monotone, inflationary, and idempotent.
* `promptClosure_least_closed_above`: Universal property — the closure of `p` is the
  least closed element above `p`.

### Theorem B — Optimal Prompts
* `optimal_prompt_iff_closed`: A prompt is optimal iff it is a fixed point of `back ∘ eval`.
* `optimal_of_adjoint_fixed` / `adjoint_fixed_of_optimal`: Characterization of optimal
  prompts via the adjunction.

### Theorem C — Finite Convergence
* `inflationary_monotone_stabilizes`: Any inflationary monotone self-map on a finite
  partial order stabilizes under iteration within `Fintype.card` steps.
* `promptClosure_iter_stabilizes`: Iterating `back ∘ eval` converges to a fixed point.

### Theorem D — Alternating Optimization
* `alternating_process_converges`: The alternating eval/back process converges to
  a closed (optimal) prompt.

### Complete Lattice Structure
* `closedPrompts_completeLattice`: Closed prompts form a complete lattice.

### Concrete Model
* A verified Galois connection on `Fin 3` and `Fin 2`, with computed closure examples.
-/

import Mathlib

open Function OrderDual

/-! ## Core Definitions -/

section CoreDefs

variable {P Q : Type*} [Preorder P] [Preorder Q]

/-- A prompt is "closed" (optimal) if applying the round-trip `back ∘ eval` returns it unchanged. -/
def PromptClosed (eval : P →o Q) (back : Q →o P) (p : P) : Prop :=
  back (eval p) = p

/-- The prompt closure map: round-trip through quality space and back. -/
def promptClosure (eval : P →o Q) (back : Q →o P) (p : P) : P :=
  back (eval p)

end CoreDefs

/-! ## Theorem A: Prompt Closure is a Closure Operator -/

section ClosureOperatorSection

variable {P Q : Type*} [PartialOrder P] [Preorder Q]
  (eval : P →o Q) (back : Q →o P)

/-- The prompt closure `back ∘ eval` induced by a Galois connection is monotone,
    inflationary, and idempotent — i.e., it is a closure operator. -/
theorem promptClosure_isClosureOperator (hgc : GaloisConnection eval back) :
    (Monotone (promptClosure eval back)) ∧
    (∀ p, p ≤ promptClosure eval back p) ∧
    (∀ p, promptClosure eval back (promptClosure eval back p) = promptClosure eval back p) := by
  refine ⟨?_, ?_, ?_⟩
  · exact fun _ _ h => back.mono (eval.mono h)
  · exact fun p => hgc.le_u_l p
  · exact fun p => hgc.u_l_u_eq_u _

/-- The prompt closure agrees with Mathlib's `GaloisConnection.closureOperator`. -/
theorem promptClosure_eq_gc_closureOperator (hgc : GaloisConnection eval back) (p : P) :
    promptClosure eval back p = hgc.closureOperator p := by
  rfl

/-- Universal property: `back (eval p)` is the least closed element above `p`. -/
theorem promptClosure_least_closed_above (p p' : P)
    (hp : p ≤ p') (hclosed : PromptClosed eval back p') :
    promptClosure eval back p ≤ p' := by
  exact hclosed ▸ back.monotone (eval.monotone hp)

/-- Closed elements are exactly the fixed points of the closure. -/
theorem closed_iff_fixedPoint (p : P) :
    PromptClosed eval back p ↔ promptClosure eval back p = p := by
  rfl

end ClosureOperatorSection

/-! ## Theorem B: Optimal Prompts via Adjunction -/

section OptimalPrompts

variable {P Q : Type*} [PartialOrder P] [Preorder Q]
  (eval : P →o Q) (back : Q →o P)

/-- A prompt is optimal iff it is closed under the Galois connection round-trip. -/
theorem optimal_prompt_iff_closed (p : P) :
    PromptClosed eval back p ↔ promptClosure eval back p = p :=
  Iff.rfl

/-- Forward direction: if `p = back q` and `eval (back q) = q`, then `p` is closed. -/
theorem optimal_of_adjoint_fixed {p : P} {q : Q}
    (hp : p = back q) (hq : eval (back q) = q) :
    PromptClosed eval back p := by
  subst hp
  simp [hq, PromptClosed]

/-- Backward direction: if `p` is closed, then `p = back (eval p)` and
    `eval (back (eval p)) = eval p`. -/
theorem adjoint_fixed_of_optimal {p : P}
    (hclosed : PromptClosed eval back p) :
    p = back (eval p) ∧ eval (back (eval p)) = eval p :=
  ⟨hclosed.symm, by rw [hclosed]⟩

end OptimalPrompts

/-! ## Theorem C: Finite Convergence of Iterative Adjunction -/

section FiniteConvergence

/-
Key stabilization lemma: any inflationary monotone self-map on a finite partial order
    has a fixed point reachable by iteration. The iteration stabilizes within
    `Fintype.card P` steps.
-/
theorem inflationary_monotone_stabilizes
    {P : Type*} [PartialOrder P] [Fintype P]
    (f : P → P) (_hmono : Monotone f) (hinfl : ∀ x, x ≤ f x) :
    ∀ p : P, ∃ n : ℕ, n ≤ Fintype.card P ∧ f^[n] p = f^[n + 1] p := by
  intro p
  by_contra h_contra
  push_neg at h_contra;
  -- By definition of $f$ being monotone and inflationary, the sequence $f^[n] p$ is strictly increasing.
  have h_strict_mono : StrictMono (fun n : Fin (Fintype.card P + 1) => f^[n] p) := by
    intro m n hmn
    have h_strict_mono_step : ∀ k : ℕ, k < n.val → f^[k] p < f^[k + 1] p := by
      exact fun k hk => lt_of_le_of_ne ( by simpa only [ Function.iterate_succ_apply' ] using hinfl _ ) ( h_contra k ( Nat.le_trans hk.le ( Nat.le_of_lt_succ n.2 ) ) );
    induction' n using Fin.inductionOn with n ih;
    · tauto;
    · grind +revert;
  exact absurd ( Fintype.card_le_of_injective _ h_strict_mono.injective ) ( by simp +decide )

/-
Iterating the prompt closure on any prompt converges to a fixed point.
-/
theorem promptClosure_iter_stabilizes
    {P Q : Type*} [PartialOrder P] [Preorder Q] [Fintype P]
    (eval : P →o Q) (back : Q →o P)
    (hgc : GaloisConnection eval back) :
    ∀ p : P, ∃ n : ℕ, n ≤ Fintype.card P ∧
      (fun x => back (eval x))^[n] p = (fun x => back (eval x))^[n + 1] p := by
  -- Apply the stabilization lemma with the function `fun x => back (eval x)`.
  intros p
  apply inflationary_monotone_stabilizes;
  · exact fun x y hxy => back.mono ( eval.mono hxy );
  · exact fun x => hgc.le_u_l x

/-- The limit of prompt closure iteration is itself a closed (optimal) prompt. -/
theorem promptClosure_iter_limit_is_closed
    {P Q : Type*} [PartialOrder P] [Preorder Q]
    (eval : P →o Q) (back : Q →o P)
    (p : P) (n : ℕ)
    (hn : (fun x => back (eval x))^[n] p = (fun x => back (eval x))^[n + 1] p) :
    PromptClosed eval back ((fun x => back (eval x))^[n] p) := by
  simp only [iterate_succ_apply'] at hn
  exact hn.symm

end FiniteConvergence

/-! ## Theorem D: Alternating Optimization -/

section AlternatingOptimization

/-
The alternating process (eval then back, repeated) converges to a closed prompt.
    This combines convergence (Theorem C) with the fact that the limit is closed.
-/
theorem alternating_process_converges
    {P Q : Type*} [PartialOrder P] [Preorder Q] [Fintype P]
    (eval : P →o Q) (back : Q →o P)
    (hgc : GaloisConnection eval back) (p₀ : P) :
    ∃ n : ℕ, n ≤ Fintype.card P ∧
      PromptClosed eval back ((fun x => back (eval x))^[n] p₀) := by
  -- By Theorem C, there exists an n such that the closure converges to a fixed point.
  obtain ⟨n, hn⟩ : ∃ n : ℕ, n ≤ Fintype.card P ∧ (fun x => back (eval x))^[n] p₀ = (fun x => back (eval x))^[n + 1] p₀ := by
    exact promptClosure_iter_stabilizes eval back hgc p₀;
  exact ⟨ n, hn.1, by simpa only [ Function.iterate_succ_apply' ] using hn.2.symm ⟩

end AlternatingOptimization

/-! ## Closed Prompts Form a Complete Lattice -/

section ClosedLattice

/-
The set of closed prompts admits a complete lattice structure, inherited from
    the closure operator on a complete lattice.
-/
noncomputable instance closedPrompts_completeLattice
    {P Q : Type*} [CompleteLattice P] [Preorder Q]
    (eval : P →o Q) (back : Q →o P) (hgc : GaloisConnection eval back) :
    CompleteLattice (hgc.closureOperator.Closeds) :=
  hgc.closureOperator.gi.liftCompleteLattice

end ClosedLattice

/-! ## Concrete Model: Prompt Levels and Quality Levels

We demonstrate with `P = Fin 3` (prompt refinement levels: rough, moderate, precise)
and `Q = Fin 2` (quality levels: low, high).

- `eval`: maps rough(0) and moderate(1) to low(0), precise(2) to high(1).
- `back`: maps low(0) to moderate(1), high(1) to precise(2).

This forms a Galois connection: `eval(p) ≤ q ↔ p ≤ back(q)`.
The closure `back ∘ eval` maps 0 ↦ 1, 1 ↦ 1, 2 ↦ 2.
Closed (optimal) prompts are {1, 2}: moderate and precise are optimal refinement levels.
-/

section ConcreteModel

/-- Prompt evaluation: maps prompt level to quality level. -/
def concreteEval : Fin 3 →o Fin 2 where
  toFun
    | 0 => 0
    | 1 => 0
    | 2 => 1
  monotone' := by decide

/-- Quality back-propagation: maps quality level to required prompt level. -/
def concreteBack : Fin 2 →o Fin 3 where
  toFun
    | 0 => 1
    | 1 => 2
  monotone' := by decide

/-
The concrete eval/back pair forms a Galois connection.
-/
theorem concrete_galoisConnection :
    GaloisConnection concreteEval concreteBack := by
  exact fun p q => by fin_cases p <;> fin_cases q <;> simp +decide ;

/-- The closure maps prompt 0 (rough) to prompt 1 (moderate). -/
theorem concrete_closure_0 : concreteBack (concreteEval 0) = 1 := by native_decide

/-- Prompt 1 (moderate) is already closed/optimal. -/
theorem concrete_closure_1 : concreteBack (concreteEval 1) = 1 := by native_decide

/-- Prompt 2 (precise) is already closed/optimal. -/
theorem concrete_closure_2 : concreteBack (concreteEval 2) = 2 := by native_decide

/-- Prompt 0 is NOT optimal — it gets refined by the closure. -/
theorem concrete_not_optimal_0 : ¬PromptClosed concreteEval concreteBack 0 := by
  simp [PromptClosed, concreteEval, concreteBack]

/-- Prompt 1 IS optimal. -/
theorem concrete_optimal_1 : PromptClosed concreteEval concreteBack 1 := by
  simp [PromptClosed, concreteEval, concreteBack]

/-- Prompt 2 IS optimal. -/
theorem concrete_optimal_2 : PromptClosed concreteEval concreteBack 2 := by
  simp [PromptClosed, concreteEval, concreteBack]

/-- Starting from prompt 0, one iteration of closure reaches the optimal prompt 1. -/
theorem concrete_convergence_from_0 :
    (fun x => concreteBack (concreteEval x))^[1] (0 : Fin 3) =
    (fun x => concreteBack (concreteEval x))^[2] (0 : Fin 3) := by native_decide

end ConcreteModel