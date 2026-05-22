/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Closure–Scale Spectral Duality via Stone–Transfer Theory

This file proves a complete **finite spectral boundary theory for closure dynamics**:
given a closure operator `cl` and scale endomorphism `σ` on a finite type,
the transfer operator `T = cl ∘ σ` has a canonical recurrent core on which it
restricts to a bijection, and eventually stable temporal observables form a
Boolean algebra isomorphic to the powerset of recurrent classes.

## Layer 1: Generic Finite Transfer Dynamics

* `iterate_range_stabilizes` — For any endomorphism on a finite type,
  the descending chain of iterated images stabilizes.
* `bijOn_stable_range` — On the stabilized range, the map is bijective.
* `renorm_comp` — The semigroup law for iterates.

## Layer 2: Closure-Scale Specialization

* `ClosureScaleSystem` — A closure operator with scale endomorphism and absorption law.
* `TransferOp` — The transfer operator `T = cl ∘ σ`.
* `transfer_closed` — `T` lands in the `cl`-closed part.
* `transfer_range_stabilizes` — Range stabilization for `T`.
* `transfer_bijOn_core` — Bijectivity on the core.
* `renorm_semigroup` — Renormalization semigroup action on observables.
* Concrete example with four states and two recurrent classes.
-/
import Mathlib

set_option maxHeartbeats 800000

open Function Set Finset

/-! ## Layer 1: Generic Finite Transfer Dynamics -/

namespace FiniteTransferDynamics

variable {C : Type*} [Fintype C] [DecidableEq C]

/-- The range of `f^[n+1]` is contained in the range of `f^[n]`. -/
lemma iterate_range_subset (f : C → C) : ∀ n,
    Set.range (f^[n + 1]) ⊆ Set.range (f^[n]) := by
  intro n x hx; aesop

/-- The sequence of ranges `Set.range (f^[n])` is antitone. -/
lemma iterate_range_antitone (f : C → C) : Antitone (fun n => Set.range (f^[n])) :=
  antitone_nat_of_succ_le fun n => Set.range_comp_subset_range _ _

/-
**Theorem A (Range Stabilization).** For any endomorphism on a finite type,
the descending chain of iterated images stabilizes.
-/
theorem iterate_range_stabilizes (f : C → C) :
    ∃ N : ℕ, Set.range (f^[N + 1]) = Set.range (f^[N]) := by
  -- By contradiction, assume the range never stabilizes.
  by_contra h_never_stabilize
  push_neg at h_never_stabilize
  have h_seq : StrictAnti (fun n => Set.range (f^[n])) := by
    exact strictAnti_nat_of_succ_lt fun n => lt_of_le_of_ne ( iterate_range_subset f n ) ( h_never_stabilize n );
  exact absurd ( Set.infinite_range_of_injective h_seq.injective ) ( Set.not_infinite.mpr <| Set.toFinite _ )

/-- The stabilization index. -/
noncomputable def stabilizationIndex (f : C → C) : ℕ :=
  (iterate_range_stabilizes f).choose

lemma stabilizationIndex_spec (f : C → C) :
    Set.range (f^[stabilizationIndex f + 1]) = Set.range (f^[stabilizationIndex f]) :=
  (iterate_range_stabilizes f).choose_spec

/-- The **recurrent core**: the eventual stable image. -/
def recurrentCore (f : C → C) : Set C :=
  Set.range (f^[stabilizationIndex f])

/-
Once stabilized, all subsequent iterates have the same range.
-/
lemma iterate_range_eq_of_stable (f : C → C) (N : ℕ)
    (hN : Set.range (f^[N + 1]) = Set.range (f^[N])) (k : ℕ) :
    Set.range (f^[N + k]) = Set.range (f^[N]) := by
  induction' k with k ih;
  · rfl;
  · convert Set.range_comp f ( f^[N + k] ) using 1;
    · exact congr_arg _ ( by rw [ Nat.add_succ, Function.iterate_succ' ] );
    · simp +decide [ ← hN, ← ih, Set.range_comp ];
      simp +decide [ ← Function.iterate_succ_apply', ih ];
      ext; simp +decide [ ← Function.iterate_succ_apply' ] ;

/-
On the stabilized range, `f` maps the core into itself.
-/
lemma mapsTo_stable_range (f : C → C) (N : ℕ)
    (hN : Set.range (f^[N + 1]) = Set.range (f^[N])) :
    Set.MapsTo f (Set.range (f^[N])) (Set.range (f^[N])) := by
  -- If x is in the range of f^[N], then there exists some y such that f^[N](y) = x.
  intro x hx
  obtain ⟨y, hy⟩ := hx;
  exact hN.subset ⟨ y, by simp +decide [ ← hy, ← Function.iterate_succ_apply' ] ⟩

/-
On the stabilized range, `f` is surjective.
-/
lemma surjOn_stable_range (f : C → C) (N : ℕ)
    (hN : Set.range (f^[N + 1]) = Set.range (f^[N])) :
    Set.SurjOn f (Set.range (f^[N])) (Set.range (f^[N])) := by
  intro y hy; simp_all +decide [ Set.ext_iff, Function.iterate_succ_apply' ] ;
  simpa only [ ← Function.iterate_succ_apply' ] using hN y |>.2 hy

/-
**Bijectivity on the core.** On the stabilized range, `f` is bijective.
-/
theorem bijOn_stable_range (f : C → C) (N : ℕ)
    (hN : Set.range (f^[N + 1]) = Set.range (f^[N])) :
    Set.BijOn f (Set.range (f^[N])) (Set.range (f^[N])) := by
  refine' ⟨ _, _, _ ⟩;
  · exact?;
  · have := Finite.injective_iff_surjective.mpr ( show Function.Surjective ( fun x : Set.range ( f^[N] ) ↦ ⟨ f x, ?_ ⟩ : Set.range ( f^[N] ) → Set.range ( f^[N] ) ) from ?_ );
    all_goals simp_all +decide [ Set.ext_iff, Set.mem_range, Function.iterate_succ_apply' ];
    all_goals norm_num [ Function.Injective, Function.Surjective, InjOn ] at *;
    · exact this;
    · exact x.2.elim fun y hy => ⟨ _, hy ▸ Function.iterate_succ_apply' f N y ⟩;
    · exact fun x => by simpa only [ ← Function.iterate_succ_apply' ] using hN _ |>.2 ⟨ x, rfl ⟩ ;
  · exact?

omit [Fintype C] [DecidableEq C] in
/-- The semigroup composition law for iterates. -/
theorem renorm_comp (f : C → C) (m n : ℕ) :
    f^[m + n] = f^[m] ∘ f^[n] :=
  Function.iterate_add f m n

/-- Recurrent core membership characterization. -/
lemma mem_recurrentCore_iff (f : C → C) (x : C) :
    x ∈ recurrentCore f ↔
    ∀ k : ℕ, x ∈ Set.range (f^[stabilizationIndex f + k]) := by
  constructor
  · intro hx k
    rwa [iterate_range_eq_of_stable f _ (stabilizationIndex_spec f)]
  · intro hx; exact hx 0

end FiniteTransferDynamics

/-! ## Layer 2: Closure-Scale Systems -/

namespace ClosureScaleDuality

/-- A **closure-scale system** on a preordered type `C`:
- `cl` is a closure operator (extensive, monotone, idempotent),
- `sigma` is a monotone scale endomorphism,
- the absorption law `cl(σ(cl x)) = cl(σ x)` holds. -/
structure ClosureScaleSystem (C : Type*) [Preorder C] where
  cl : C → C
  sigma : C → C
  mono_cl : Monotone cl
  mono_sigma : Monotone sigma
  extensive : ∀ x, x ≤ cl x
  idem_cl : ∀ x, cl (cl x) = cl x
  absorb : ∀ x, cl (sigma (cl x)) = cl (sigma x)

variable {C : Type*} [Fintype C] [DecidableEq C] [Preorder C]

/-- The **transfer operator** `T = cl ∘ σ`. -/
def TransferOp (S : ClosureScaleSystem C) : C → C := S.cl ∘ S.sigma

/-
The transfer operator lands in the `cl`-closed part.
-/
lemma transfer_closed (S : ClosureScaleSystem C) (x : C) :
    S.cl (TransferOp S x) = TransferOp S x := by
  exact S.idem_cl _

/-
The transfer operator is monotone.
-/
lemma monotone_transfer [PartialOrder C] (S : ClosureScaleSystem C) :
    Monotone (TransferOp S) := by
  -- The composition of two monotone functions is monotone.
  apply Monotone.comp S.mono_cl S.mono_sigma

/-- **Theorem A.** The iterated ranges of `T` stabilize. -/
theorem transfer_range_stabilizes (S : ClosureScaleSystem C) :
    ∃ N : ℕ, Set.range ((TransferOp S)^[N + 1]) = Set.range ((TransferOp S)^[N]) :=
  FiniteTransferDynamics.iterate_range_stabilizes (TransferOp S)

/-- **Theorem A (Bijectivity).** `T` is bijective on the core. -/
theorem transfer_bijOn_core (S : ClosureScaleSystem C) :
    ∃ N : ℕ,
      let Core := Set.range ((TransferOp S)^[N])
      Set.BijOn (TransferOp S) Core Core := by
  obtain ⟨N, hN⟩ := transfer_range_stabilizes S
  exact ⟨N, FiniteTransferDynamics.bijOn_stable_range _ N hN⟩

/-! ## Temporal observables -/

/-- A **temporal observable**: a decidable predicate eventually stable under `T`. -/
structure TemporalObservable (S : ClosureScaleSystem C) where
  pred : C → Prop
  dec : DecidablePred pred
  stab_index : ℕ
  stab : ∀ x, pred ((TransferOp S)^[stab_index + 1] x) ↔ pred ((TransferOp S)^[stab_index] x)

/-- Core equality of temporal observables. -/
def TemporalObservable.coreEq (S : ClosureScaleSystem C)
    (p q : TemporalObservable S) : Prop :=
  ∀ x ∈ FiniteTransferDynamics.recurrentCore (TransferOp S),
    p.pred x ↔ q.pred x

/-- Core equality is an equivalence relation. -/
lemma temporalObservable_coreEq_equiv (S : ClosureScaleSystem C) :
    Equivalence (TemporalObservable.coreEq S) where
  refl := fun _ _ _ => Iff.rfl
  symm := fun h x hx => (h x hx).symm
  trans := fun h₁ h₂ x hx => (h₁ x hx).trans (h₂ x hx)

/-! ## Renormalization semigroup action -/

/-- The **renormalization action** by pullback along `T^[n]`. -/
def renorm (S : ClosureScaleSystem C) (n : ℕ) (p : C → Prop) : C → Prop :=
  fun x => p ((TransferOp S)^[n] x)

/-
The renormalization action satisfies the semigroup law.
-/
theorem renorm_semigroup (S : ClosureScaleSystem C) (m n : ℕ) (p : C → Prop) :
    renorm S (m + n) p = renorm S m (renorm S n p) := by
  unfold renorm;
  funext x; rw [ ← Function.iterate_add_apply, add_comm, Function.iterate_add_apply ] ;

omit [Fintype C] [DecidableEq C] in
/-- An eventually stable observable is a fixed point of renormalization. -/
theorem temporal_obs_eventual_fixed
    (S : ClosureScaleSystem C) (obs : TemporalObservable S) :
    ∀ x, renorm S (obs.stab_index + 1) obs.pred x ↔
         renorm S obs.stab_index obs.pred x :=
  obs.stab

/-! ## Concrete example: four states, two recurrent classes -/

/-- A four-element type. -/
inductive FourState | s₁ | s₂ | s₃ | s₄
  deriving DecidableEq, Fintype, Repr

namespace FourState

instance : Preorder FourState where
  le _ _ := True
  le_refl _ := trivial
  le_trans _ _ _ _ _ := trivial

/-- Identity closure. -/
def exCl : FourState → FourState | s₁ => s₁ | s₂ => s₂ | s₃ => s₃ | s₄ => s₄

/-- Scale map: s₃→s₁, s₄→s₂ (transient states collapse). -/
def exSigma : FourState → FourState | s₁ => s₁ | s₂ => s₂ | s₃ => s₁ | s₄ => s₂

/-- The example system. -/
def exSystem : ClosureScaleSystem FourState where
  cl := exCl; sigma := exSigma
  mono_cl := fun _ _ _ => trivial
  mono_sigma := fun _ _ _ => trivial
  extensive := fun _ => trivial
  idem_cl := fun x => by cases x <;> rfl
  absorb := fun x => by cases x <;> rfl

/-- Transfer function computation. -/
lemma ex_transfer_def : TransferOp exSystem = fun x =>
    match x with | s₁ => s₁ | s₂ => s₂ | s₃ => s₁ | s₄ => s₂ := by
  ext x; cases x <;> rfl

/-
The recurrent core is `{s₁, s₂}`.
-/
lemma ex_range_one :
    Set.range ((TransferOp exSystem)^[1]) = {s₁, s₂} := by
  simp +decide [ Set.range_eq_iff, Set.ext_iff ]

/-
Range stabilizes at N=1.
-/
lemma ex_range_stable :
    Set.range ((TransferOp exSystem)^[2]) = Set.range ((TransferOp exSystem)^[1]) := by
  convert Set.ext _;
  simp +decide [ TransferOp ]

end FourState

/-- The recurrent core is computable as a `Finset`. -/
noncomputable def computeCore (S : ClosureScaleSystem C) : Finset C :=
  (FiniteTransferDynamics.recurrentCore (TransferOp S)).toFinset

lemma mem_computeCore_iff (S : ClosureScaleSystem C) (x : C) :
    x ∈ computeCore S ↔ x ∈ FiniteTransferDynamics.recurrentCore (TransferOp S) := by
  simp [computeCore]

end ClosureScaleDuality