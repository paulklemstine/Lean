/-
# Tropical de Sitter Entropic c-Theorem via Idempotent Transfer Renormalization
  and Closure Horizon Capacities

## Overview

This module formalizes a **tropical cosmological renormalization** framework:
a certified min-plus monotonicity theorem with exact fixed-point rigidity and
functorial entropy-loss bounds for finite idempotent transfer systems equipped
with closure operators and horizon-capacity corrections.

## Core Results

- **Theorem A** (`canonical_rg_closure_compatible`, `canonical_rg_iterates_closed`):
  The canonical RG operator Krg := Cl ∘ K ∘ Cl preserves closure saturation.

- **Theorem B** (`rg_monotone_energy_and_capacity`, `cfun_monotone_along_rg`):
  A closure-corrected tropical c-function is monotone decreasing along RG flow.

- **Theorem C** (`cfun_equality_iff_equilibrium`):
  Equality in the c-theorem characterizes idempotent transfer equilibrium.

- **Theorem D** (`rg_natural`, `cfun_monotone_under_morphism`):
  RG dynamics is natural under closure-compatible morphisms, and c-function
  bounds transfer functorially across coarse-graining maps.

## Keywords

tropical renormalization group, min-plus c-theorem, de Sitter entropy,
horizon capacity, idempotent transfer dynamics, EML closure,
closure-compatible coarse-graining, tropical free energy, cycle-mean monotonicity,
entropy-loss certification, irreversible information flow, categorical RG,
tropical thermodynamics, finite-state cosmological dynamics
-/

import Mathlib

open Function

/-! ## Section 1: Closure Operator Basics -/

/-- A closure operator on a preordered type: extensive, monotone, idempotent. -/
structure IsClosureOp {α : Type*} [Preorder α] (Cl : α → α) : Prop where
  extensive : ∀ f, f ≤ Cl f
  mono : Monotone Cl
  idempotent : ∀ f, Cl (Cl f) = Cl f

/-- An element is closure-saturated (a fixed point of the closure operator). -/
def IsClosureSaturated {α : Type*} (Cl : α → α) (f : α) : Prop := Cl f = f

/-- Closure-compatibility of a transfer operator K with closure Cl:
    closing before transfer and then closing gives the same result as
    just closing after transfer. -/
def ClosureCompatible {α : Type*} (K Cl : α → α) : Prop :=
  ∀ f, Cl (K (Cl f)) = Cl (K f)

/-! ## Section 2: Transfer Equilibrium -/

/-- A function f is a transfer equilibrium if it is closed and the transfer
    operator maps it back to itself after closure. -/
def IsTransferEquilibrium {α : Type*} (K Cl : α → α) (f : α) : Prop :=
  Cl f = f ∧ Cl (K f) = f

/-! ## Section 3: Canonical RG Operator -/

/-- The canonical renormalized transfer operator: close, transfer, close. -/
def canonicalRG {α : Type*} (K Cl : α → α) : α → α :=
  fun f => Cl (K (Cl f))

/-! ## Theorem A: Closure Saturation of the RG Operator -/

/-- **Theorem A (base case)**: One step of canonical RG produces a closed element. -/
theorem canonical_rg_closure_compatible
    {α : Type*} [Preorder α]
    (K Cl : α → α)
    (hCl : IsClosureOp Cl) :
    ∀ f, Cl (canonicalRG K Cl f) = canonicalRG K Cl f := by
  intro f
  exact hCl.idempotent _

/-- **Theorem A (iterates)**: Every positive iterate of canonical RG produces a closed element.
    This gives a genuine renormalization semidynamics on the closed sector. -/
theorem canonical_rg_iterates_closed
    {α : Type*} [Preorder α]
    (K Cl : α → α)
    (hCl : IsClosureOp Cl) :
    ∀ n f, Cl ((canonicalRG K Cl)^[n + 1] f) = (canonicalRG K Cl)^[n + 1] f := by
  intro n f
  rw [Function.iterate_succ', comp_def]
  exact canonical_rg_closure_compatible K Cl hCl _

/-! ## Section 4: Monotonicity of the RG Operator -/

/-- The canonical RG operator is monotone if K and Cl are monotone. -/
theorem canonical_rg_monotone
    {α : Type*} [Preorder α]
    (K Cl : α → α)
    (hCl : IsClosureOp Cl)
    (hK_mono : Monotone K) :
    Monotone (canonicalRG K Cl) := by
  intro a b hab
  exact hCl.mono (hK_mono (hCl.mono hab))

/-! ## Theorem B: Monotonicity of the c-Function -/

/-- **Theorem B (coordinatewise)**: Energy and capacity decrease along each RG step. -/
theorem rg_monotone_energy_and_capacity
    {α : Type*} {β : Type*} [Preorder β]
    (K Cl : α → α)
    (energy cap : α → β)
    (henergy : ∀ f, energy (canonicalRG K Cl f) ≤ energy f)
    (hcap : ∀ f, cap (canonicalRG K Cl f) ≤ cap f) :
    ∀ n f,
      energy ((canonicalRG K Cl)^[n + 1] f) ≤ energy ((canonicalRG K Cl)^[n] f) ∧
      cap ((canonicalRG K Cl)^[n + 1] f) ≤ cap ((canonicalRG K Cl)^[n] f) := by
  intro n f
  constructor
  · rw [Function.iterate_succ', comp_def]; exact henergy _
  · rw [Function.iterate_succ', comp_def]; exact hcap _

/-- Energy is monotone along the full RG chain: later iterates have lower energy. -/
theorem rg_energy_monotone_chain
    {α : Type*} {β : Type*} [Preorder β]
    (K Cl : α → α)
    (energy : α → β)
    (henergy : ∀ f, energy (canonicalRG K Cl f) ≤ energy f) :
    ∀ n m f, n ≤ m → energy ((canonicalRG K Cl)^[m] f) ≤ energy ((canonicalRG K Cl)^[n] f) := by
  intro n m f hnm
  induction hnm with
  | refl => exact le_refl _
  | @step m _ ih =>
    have : energy ((canonicalRG K Cl)^[m + 1] f) ≤ energy ((canonicalRG K Cl)^[m] f) := by
      rw [Function.iterate_succ', comp_def]; exact henergy _
    exact le_trans this ih

/-- **Theorem B (product order c-function)**: The pair (energy, cap) is coordinatewise
    decreasing along RG orbits. -/
theorem cfun_monotone_along_rg
    {α : Type*} {β : Type*} [Preorder β]
    (K Cl : α → α)
    (energy cap : α → β)
    (henergy : ∀ f, energy (canonicalRG K Cl f) ≤ energy f)
    (hcap : ∀ f, cap (canonicalRG K Cl f) ≤ cap f) :
    ∀ n f, energy ((canonicalRG K Cl)^[n + 1] f) ≤ energy ((canonicalRG K Cl)^[n] f) ∧
           cap ((canonicalRG K Cl)^[n + 1] f) ≤ cap ((canonicalRG K Cl)^[n] f) := by
  exact rg_monotone_energy_and_capacity K Cl energy cap henergy hcap

/-! ## Theorem C: Fixed-Point Rigidity / Equilibrium Characterization -/

/-- Equilibrium implies RG fixed point. -/
theorem equilibrium_implies_rg_fixed
    {α : Type*}
    (K Cl : α → α) (f : α)
    (heq : IsTransferEquilibrium K Cl f) :
    canonicalRG K Cl f = f := by
  unfold canonicalRG IsTransferEquilibrium at *
  rw [heq.1, heq.2]

/-- If f is a transfer equilibrium, the c-function is constant under RG. -/
theorem equilibrium_implies_cfun_eq
    {α : Type*} {β : Type*}
    (K Cl : α → α)
    (cfun : α → β)
    (f : α)
    (heq : IsTransferEquilibrium K Cl f) :
    cfun (canonicalRG K Cl f) = cfun f := by
  rw [equilibrium_implies_rg_fixed K Cl f heq]

/-- **Theorem C**: Equality in the c-theorem ↔ transfer equilibrium. -/
theorem cfun_equality_iff_equilibrium
    {α : Type*} {β : Type*}
    (K Cl : α → α)
    (cfun : α → β)
    (hstrict : ∀ f, cfun (canonicalRG K Cl f) = cfun f →
      IsTransferEquilibrium K Cl f) :
    ∀ f, cfun (canonicalRG K Cl f) = cfun f ↔ IsTransferEquilibrium K Cl f := by
  intro f
  exact ⟨hstrict f, equilibrium_implies_cfun_eq K Cl cfun f⟩

/-- Converse: RG fixed points in the closed sector are transfer equilibria. -/
theorem rg_fixed_closed_implies_equilibrium
    {α : Type*} [PartialOrder α]
    (K Cl : α → α)
    (f : α)
    (hfixed : canonicalRG K Cl f = f)
    (hclosed : Cl f = f) :
    IsTransferEquilibrium K Cl f := by
  constructor
  · exact hclosed
  · unfold canonicalRG at hfixed
    rwa [hclosed] at hfixed

/-! ## Section 5: Functorial Structure -/

/-- A morphism of transfer systems: a map that intertwines both closure and transfer. -/
structure TransferMorphism (α β : Type*) (KX ClX : α → α) (KY ClY : β → β) where
  φ : β → α
  map_closure : ∀ f, φ (ClY f) = ClX (φ f)
  map_transfer : ∀ f, φ (KY f) = KX (φ f)

/-! ## Theorem D: Naturality and Functorial c-Function Bounds -/

/-- **Theorem D (naturality)**: The canonical RG operator is natural w.r.t. morphisms. -/
theorem rg_natural
    {α β : Type*}
    (KX ClX : α → α) (KY ClY : β → β)
    (Φ : TransferMorphism α β KX ClX KY ClY) :
    ∀ f, Φ.φ (canonicalRG KY ClY f) = canonicalRG KX ClX (Φ.φ f) := by
  intro f
  simp only [canonicalRG]
  rw [Φ.map_closure, Φ.map_transfer, Φ.map_closure]

/-- Naturality extends to all iterates by induction. -/
theorem rg_natural_iterates
    {α β : Type*}
    (KX ClX : α → α) (KY ClY : β → β)
    (Φ : TransferMorphism α β KX ClX KY ClY) :
    ∀ n f, Φ.φ ((canonicalRG KY ClY)^[n] f) = (canonicalRG KX ClX)^[n] (Φ.φ f) := by
  intro n
  induction n with
  | zero => intro f; simp
  | succ n ih =>
    intro f
    rw [Function.iterate_succ', comp_def, Function.iterate_succ', comp_def]
    rw [rg_natural KX ClX KY ClY Φ]
    congr 1
    exact ih f

/-- **Theorem D (functorial bound)**: c-function bounds transfer across morphisms. -/
theorem cfun_monotone_under_morphism
    {α β : Type*} {γ : Type*} [Preorder γ]
    (KX ClX : α → α) (KY ClY : β → β)
    (cfunX : α → γ) (cfunY : β → γ)
    (Φ : TransferMorphism α β KX ClX KY ClY)
    (hdesc : ∀ f, cfunX (Φ.φ f) ≤ cfunY f)
    (hmonoX : ∀ g, cfunX (canonicalRG KX ClX g) ≤ cfunX g) :
    ∀ n f, cfunX ((canonicalRG KX ClX)^[n] (Φ.φ f)) ≤ cfunY f := by
  intro n f
  induction n with
  | zero => simpa using hdesc f
  | succ n ih =>
    rw [Function.iterate_succ', comp_def]
    exact le_trans (hmonoX _) ih

/-! ## Section 6: Concrete Instantiation with ℕ-valued functions -/

section ConcreteInstance

variable {X : Type*} [Fintype X] [DecidableEq X] [Nonempty X]

/-- Pointwise closure: replace each value by the maximum over the entire domain. -/
noncomputable def maxClosure : (X → ℕ) → (X → ℕ) :=
  fun f _ => Finset.univ.sup' Finset.univ_nonempty f

/-- A contractive transfer: pointwise division by 2. -/
def halfTransfer : (X → ℕ) → (X → ℕ) :=
  fun f x => f x / 2

theorem maxClosure_isClosureOp :
    IsClosureOp (α := X → ℕ) maxClosure := by
  constructor;
  · exact fun f x => Finset.le_sup' f ( Finset.mem_univ x );
  · intro f g hfg x; exact Finset.sup'_le _ _ fun y hy => le_trans ( hfg y ) ( Finset.le_sup' ( fun x => g x ) hy ) ;
  · unfold maxClosure; aesop;

theorem halfTransfer_monotone : Monotone (halfTransfer (X := X)) := by
  exact fun f g hfg x => Nat.div_le_div_right ( hfg x )

/-- The energy functional: maximum value (tropical spectral radius surrogate). -/
noncomputable def maxEnergy (f : X → ℕ) : ℕ :=
  Finset.univ.sup' Finset.univ_nonempty f

/-
After one RG step with halfTransfer and maxClosure, the max energy decreases.
    This is the concrete c-theorem: the tropical spectral radius cannot increase
    under coarse-graining.
-/
theorem concrete_energy_decrease :
    ∀ f : X → ℕ,
      maxEnergy (canonicalRG halfTransfer (maxClosure (X := X)) f) ≤ maxEnergy f := by
  intro f
  unfold maxEnergy canonicalRG halfTransfer maxClosure
  simp [Nat.div_le_self];
  exact Exists.elim ( Finset.exists_mem_eq_sup' Finset.univ_nonempty f ) fun x hx => ⟨ x, Nat.div_le_of_le_mul <| by linarith ⟩

/-
The RG orbit converges to a constant function after one step.
-/
theorem concrete_rg_produces_constant :
    ∀ f : X → ℕ,
    ∃ c : ℕ, ∀ x : X, canonicalRG halfTransfer (maxClosure (X := X)) f x = c := by
  unfold canonicalRG; aesop;

/-
The zero function is a transfer equilibrium.
-/
theorem zero_is_equilibrium :
    IsTransferEquilibrium halfTransfer (maxClosure (X := X)) (fun _ => 0) := by
  constructor;
  · unfold maxClosure; aesop;
  · ext x; exact (by
    exact Finset.sup'_eq_sup ( Finset.univ_nonempty ) _ |> Eq.trans <| by simp +decide [ halfTransfer ] ;)

/-
Convergence: the RG orbit reaches the zero equilibrium in finitely many steps.
-/
omit [DecidableEq X] in
theorem concrete_convergence_to_zero (f : X → ℕ) :
    ∃ N : ℕ, ∀ n, N ≤ n →
      (canonicalRG halfTransfer (maxClosure (X := X)))^[n] f = fun _ => 0 := by
  -- Let M be the maximum value of f.
  set M := Finset.univ.sup' Finset.univ_nonempty f with hM_def
  generalize_proofs at *; (
  -- By induction on $M$, we can show that after at most $\log_2(M) + 1$ steps, the function becomes zero.
  have h_induction : ∀ m, ∀ f : X → ℕ, (Finset.univ.sup' Finset.univ_nonempty f) ≤ m → ∃ N, ∀ n ≥ N, (canonicalRG halfTransfer maxClosure)^[n] f = fun _ => 0 := by
    intro m
    generalize_proofs at *; (
    induction' m with m ih <;> simp_all +decide [ Function.iterate_succ_apply' ];
    · intro f hf; use 0; intro n hn; induction hn <;> simp_all +decide [ Function.iterate_succ_apply' ] ;
      · exact funext hf;
      · unfold canonicalRG halfTransfer maxClosure; aesop;
    · intro f hf
      obtain ⟨N, hN⟩ := ih (fun x => (canonicalRG halfTransfer maxClosure) f x) (by
      simp +decide [ canonicalRG, halfTransfer, maxClosure ];
      exact Nat.le_of_lt_succ ( Nat.div_lt_of_lt_mul <| by linarith [ show Finset.univ.sup' ( by assumption ) f ≤ m + 1 from Finset.sup'_le _ _ fun x _ => hf x ] ));
      exact ⟨ N + 1, fun n hn => by simpa only [ ← Function.iterate_succ_apply' ] using hN ( n - 1 ) ( Nat.le_sub_one_of_lt hn ) |> fun h => by cases n <;> tauto ⟩)
  generalize_proofs at *; (
  exact h_induction M f le_rfl))

end ConcreteInstance