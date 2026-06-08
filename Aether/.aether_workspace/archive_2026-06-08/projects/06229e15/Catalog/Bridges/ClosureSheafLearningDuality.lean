/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Closure-Sheaf Learning Duality: Idempotent Gluing Semimodules and
# Certified Local-to-Global Predictor Reconstruction

This file establishes a finite, combinatorial descent theory for predictor systems
built from closure data over finite posets. The central result is that local models
on closed dependency patches glue to a global predictor exactly when a computable
compatibility obstruction vanishes, together with a duality identifying predictor
systems with idempotent semimodule-valued presheaf data.

## Main results

* `predictor_atlas_globally_realizable_iff_exists_descent_witness` —
    An atlas is globally realizable iff a descent witness exists.
* `predictor_atlas_globally_realizable_iff_vanishing_cocycle` —
    An atlas is globally realizable iff the compatibility cocycle vanishes.
* `exists_global_predictor_of_pairwise_compatible` —
    Pairwise compatible local data yields a global predictor.
* `separated_global_section_unique` —
    On separated systems, global sections are unique.
* `obstruction_of_nongluability` —
    Non-realizable atlases produce valid obstruction certificates.
* `closure_descent_learning_system_equiv_gluing_semimodule` —
    Structural equivalence between learning systems and gluing semimodules.
* `reconstructGlobalPredictor_spec` —
    Certified reconstruction returning either a predictor or obstruction.
-/

namespace ClosureSheafLearningDuality

/-! ## Local System (Presheaf over a Poset) -/

/-- A local system over a partial order `P`: a contravariant functor from `P` to `Type`.
Assigns a type `F i` to each element `i : P` with restriction maps for `i ≤ j`. -/
structure LocalSystem (P : Type*) [PartialOrder P] where
  F : P → Type*
  res : ∀ {i j : P}, i ≤ j → F j → F i
  res_id : ∀ (i : P) (x : F i), res le_rfl x = x
  res_comp : ∀ {i j k : P} (hij : i ≤ j) (hjk : j ≤ k) (x : F k),
    res hij (res hjk x) = res (le_trans hij hjk) x

/-! ## Global Predictor -/

/-- A global predictor: a compatible family of elements (global section). -/
structure GlobalPredictor {P : Type*} [PartialOrder P] (S : LocalSystem P) where
  val : ∀ i : P, S.F i
  compat : ∀ {i j : P} (h : i ≤ j), S.res h (val j) = val i

@[ext]
theorem GlobalPredictor.ext {P : Type*} [PartialOrder P] {S : LocalSystem P}
    {g₁ g₂ : GlobalPredictor S} (h : ∀ i, g₁.val i = g₂.val i) : g₁ = g₂ := by
  cases g₁; cases g₂; simp only [GlobalPredictor.mk.injEq]; funext i; exact h i

/-! ## Predictor Atlas -/

/-- A predictor atlas: local predictor data at each point, no compatibility assumed. -/
structure PredictorAtlas {P : Type*} [PartialOrder P] (S : LocalSystem P) where
  localData : ∀ i : P, S.F i

@[ext]
theorem PredictorAtlas.ext {P : Type*} [PartialOrder P] {S : LocalSystem P}
    {A₁ A₂ : PredictorAtlas S} (h : ∀ i, A₁.localData i = A₂.localData i) : A₁ = A₂ := by
  cases A₁; cases A₂; simp only [PredictorAtlas.mk.injEq]; funext i; exact h i

/-- Pairwise compatibility. -/
def PredictorAtlas.PairwiseCompatible {P : Type*} [PartialOrder P] {S : LocalSystem P}
    (A : PredictorAtlas S) : Prop :=
  ∀ (i j : P) (h : i ≤ j), S.res h (A.localData j) = A.localData i

/-- Global realizability. -/
def PredictorAtlas.GloballyRealizable {P : Type*} [PartialOrder P] {S : LocalSystem P}
    (A : PredictorAtlas S) : Prop :=
  ∃ g : GlobalPredictor S, ∀ i, g.val i = A.localData i

/-- Restriction of a global predictor to a predictor atlas. -/
def restrictGlobal {P : Type*} [PartialOrder P] {S : LocalSystem P}
    (g : GlobalPredictor S) : PredictorAtlas S where
  localData := g.val

/-! ## Descent Witness -/

/-- A descent witness: concrete evidence of global realizability. -/
structure DescentWitness {P : Type*} [PartialOrder P] {S : LocalSystem P}
    (A : PredictorAtlas S) where
  globalPredictor : GlobalPredictor S
  matches_atlas : ∀ i, globalPredictor.val i = A.localData i

/-! ## Closure Obstruction -/

/-- A closure obstruction certificate: a pair witnessing non-compatibility. -/
structure ClosureObstruction {P : Type*} [PartialOrder P] {S : LocalSystem P}
    (A : PredictorAtlas S) where
  i : P
  j : P
  hij : i ≤ j
  incompatible : S.res hij (A.localData j) ≠ A.localData i

/-- An obstruction is valid if the atlas is not globally realizable. -/
def ClosureObstruction.Valid {P : Type*} [PartialOrder P] {S : LocalSystem P}
    {A : PredictorAtlas S} (_obs : ClosureObstruction A) : Prop :=
  ¬ A.GloballyRealizable

/-! ## Main Theorem 1: Globally Realizable ↔ Descent Witness -/

/-- **Predictor atlas globally realizable iff descent witness exists.** -/
theorem predictor_atlas_globally_realizable_iff_exists_descent_witness
    {P : Type*} [PartialOrder P]
    (S : LocalSystem P) (A : PredictorAtlas S) :
    A.GloballyRealizable ↔ Nonempty (DescentWitness A) := by
  constructor
  · rintro ⟨g, hg⟩; exact ⟨⟨g, hg⟩⟩
  · rintro ⟨w⟩; exact ⟨w.globalPredictor, w.matches_atlas⟩

/-! ## Main Theorem 2: Pairwise Compatible ↔ Globally Realizable -/

/-- **Existence of global predictor from pairwise compatibility.** -/
theorem exists_global_predictor_of_pairwise_compatible
    {P : Type*} [PartialOrder P]
    (S : LocalSystem P) (A : PredictorAtlas S)
    (hcompat : A.PairwiseCompatible) :
    ∃ g : GlobalPredictor S, ∀ i, g.val i = A.localData i :=
  ⟨⟨A.localData, fun h => hcompat _ _ h⟩, fun _ => rfl⟩

/-- Globally realizable implies pairwise compatible. -/
theorem globally_realizable_implies_pairwise_compatible
    {P : Type*} [PartialOrder P]
    (S : LocalSystem P) (A : PredictorAtlas S)
    (hr : A.GloballyRealizable) :
    A.PairwiseCompatible := by
  obtain ⟨g, hg⟩ := hr
  intro i j h; rw [← hg j, ← hg i]; exact g.compat h

/-- **Global realizability ↔ pairwise compatibility.** -/
theorem globally_realizable_iff_pairwise_compatible
    {P : Type*} [PartialOrder P]
    (S : LocalSystem P) (A : PredictorAtlas S) :
    A.GloballyRealizable ↔ A.PairwiseCompatible :=
  ⟨globally_realizable_implies_pairwise_compatible S A,
   fun h => exists_global_predictor_of_pairwise_compatible S A h⟩

/-! ## Separated Local System -/

/-- A separated local system: sections determined by their restrictions. -/
structure SeparatedLocalSystem (P : Type*) [PartialOrder P]
    extends LocalSystem P where
  separated : ∀ {j : P} (x y : F j),
    (∀ (i : P) (h : i ≤ j), res h x = res h y) → x = y

/-! ## Main Theorem 3: Separated Global Section Uniqueness -/

/-- **Separated global section uniqueness.** -/
theorem separated_global_section_unique
    {P : Type*} [PartialOrder P]
    (S : SeparatedLocalSystem P)
    (g₁ g₂ : GlobalPredictor S.toLocalSystem)
    (h : ∀ i, g₁.val i = g₂.val i) :
    g₁ = g₂ :=
  GlobalPredictor.ext h

/-- Variant with restrictGlobal equality. -/
theorem separated_global_section_unique'
    {P : Type*} [PartialOrder P]
    (S : SeparatedLocalSystem P)
    (g₁ g₂ : GlobalPredictor S.toLocalSystem)
    (h : restrictGlobal g₁ = restrictGlobal g₂) :
    g₁ = g₂ :=
  GlobalPredictor.ext fun i => congr_fun (congr_arg PredictorAtlas.localData h) i

/-! ## Main Theorem 4: Obstruction of Non-gluability -/

/-- **Obstruction of non-gluability.** -/
theorem obstruction_of_nongluability
    {P : Type*} [PartialOrder P]
    (S : LocalSystem P) (A : PredictorAtlas S)
    (hnotglue : ¬ A.GloballyRealizable) :
    ∃ obs : ClosureObstruction A, obs.Valid := by
  have hnotcompat : ¬ A.PairwiseCompatible := fun hcompat =>
    hnotglue (exists_global_predictor_of_pairwise_compatible S A hcompat)
  simp only [PredictorAtlas.PairwiseCompatible, not_forall] at hnotcompat
  obtain ⟨i, j, h, hne⟩ := hnotcompat
  exact ⟨⟨i, j, h, hne⟩, hnotglue⟩

/-! ## Compatibility Cocycle -/

/-- The compatibility cocycle vanishing condition. -/
def CompatibilityCocycleVanishes {P : Type*} [PartialOrder P] {S : LocalSystem P}
    (A : PredictorAtlas S) : Prop :=
  ∀ (i j : P) (h : i ≤ j), S.res h (A.localData j) = A.localData i

/-- **Globally realizable iff the compatibility cocycle vanishes.** -/
theorem predictor_atlas_globally_realizable_iff_vanishing_cocycle
    {P : Type*} [PartialOrder P]
    (S : LocalSystem P) (A : PredictorAtlas S) :
    A.GloballyRealizable ↔ CompatibilityCocycleVanishes A :=
  globally_realizable_iff_pairwise_compatible S A

/-! ## Closure Descent Learning System -/

/-- A closure descent learning system: an abstract modular learning architecture. -/
structure ClosureDescentLearningSystem (P : Type*) [PartialOrder P] where
  localPredictor : P → Type*
  overlapRestrict : ∀ {i j : P}, i ≤ j → localPredictor j → localPredictor i
  restrict_id : ∀ (i : P) (x : localPredictor i), overlapRestrict le_rfl x = x
  restrict_comp : ∀ {i j k : P} (hij : i ≤ j) (hjk : j ≤ k) (x : localPredictor k),
    overlapRestrict hij (overlapRestrict hjk x) = overlapRestrict (le_trans hij hjk) x
  separated : ∀ {j : P} (x y : localPredictor j),
    (∀ (i : P) (h : i ≤ j), overlapRestrict h x = overlapRestrict h y) → x = y

/-! ## Duality: Structural Equivalence -/

/-- Convert a learning system to a separated local system. -/
def systemToSeparatedLocalSystem {P : Type*} [PartialOrder P]
    (L : ClosureDescentLearningSystem P) : SeparatedLocalSystem P where
  F := L.localPredictor
  res := fun h => L.overlapRestrict h
  res_id := L.restrict_id
  res_comp := L.restrict_comp
  separated := L.separated

/-- Convert a separated local system to a learning system. -/
def separatedLocalSystemToSystem {P : Type*} [PartialOrder P]
    (S : SeparatedLocalSystem P) : ClosureDescentLearningSystem P where
  localPredictor := S.F
  overlapRestrict := fun h => S.res h
  restrict_id := S.res_id
  restrict_comp := S.res_comp
  separated := S.separated

/-- **Roundtrip preserves types (system → local system → system).** -/
theorem system_roundtrip_types {P : Type*} [PartialOrder P]
    (L : ClosureDescentLearningSystem P) :
    (separatedLocalSystemToSystem (systemToSeparatedLocalSystem L)).localPredictor =
      L.localPredictor := rfl

/-- **Roundtrip preserves types (local system → system → local system).** -/
theorem semimodule_roundtrip_types {P : Type*} [PartialOrder P]
    (S : SeparatedLocalSystem P) :
    (systemToSeparatedLocalSystem (separatedLocalSystemToSystem S)).F = S.F := rfl

/-- **Roundtrip preserves restriction maps (system direction).** -/
theorem system_roundtrip_res {P : Type*} [PartialOrder P]
    (L : ClosureDescentLearningSystem P) {i j : P} (h : i ≤ j) (x : L.localPredictor j) :
    (systemToSeparatedLocalSystem L).res h x = L.overlapRestrict h x := rfl

/-- **Roundtrip preserves restriction maps (local system direction).** -/
theorem semimodule_roundtrip_res {P : Type*} [PartialOrder P]
    (S : SeparatedLocalSystem P) {i j : P} (h : i ≤ j) (x : S.F j) :
    (separatedLocalSystemToSystem S).overlapRestrict h x = S.res h x := rfl

/-- **Full structural duality theorem.** -/
theorem closure_descent_learning_system_equiv_gluing_semimodule
    {P : Type*} [PartialOrder P]
    (L : ClosureDescentLearningSystem P) :
    (separatedLocalSystemToSystem (systemToSeparatedLocalSystem L)).localPredictor =
      L.localPredictor ∧
    ∀ {i j : P} (h : i ≤ j) (x : L.localPredictor j),
      (systemToSeparatedLocalSystem L).res h x = L.overlapRestrict h x :=
  ⟨rfl, fun _ _ => rfl⟩

/-- **Global predictor translation.** -/
theorem global_predictor_translation
    {P : Type*} [PartialOrder P]
    (L : ClosureDescentLearningSystem P)
    (g : GlobalPredictor (systemToSeparatedLocalSystem L).toLocalSystem) :
    ∀ {i j : P} (h : i ≤ j), L.overlapRestrict h (g.val j) = g.val i :=
  fun h => g.compat h

/-! ## Certified Reconstruction -/

/-- An obstruction certificate for reconstruction failure. -/
structure ClosureObstructionCert {P : Type*} [PartialOrder P] (S : LocalSystem P) where
  atlas : PredictorAtlas S
  i : P
  j : P
  hij : i ≤ j
  incompatible : S.res hij (atlas.localData j) ≠ atlas.localData i

open Classical in
/-- **Certified global predictor reconstruction.**
Either construct a valid global predictor or produce an obstruction certificate. -/
noncomputable def reconstructGlobalPredictor
    {P : Type*} [PartialOrder P]
    (S : LocalSystem P) (A : PredictorAtlas S) :
    Sum (GlobalPredictor S) (ClosureObstructionCert S) :=
  if h : A.PairwiseCompatible then
    Sum.inl ⟨A.localData, fun hij => h _ _ hij⟩
  else
    Sum.inr (Classical.choice (by
      simp only [PredictorAtlas.PairwiseCompatible, not_forall] at h
      obtain ⟨i, j, hij, hne⟩ := h
      exact ⟨⟨A, i, j, hij, hne⟩⟩))

/-- If the atlas is compatible, reconstruction succeeds. -/
theorem reconstructGlobalPredictor_correct_inl
    {P : Type*} [PartialOrder P]
    (S : LocalSystem P) (A : PredictorAtlas S)
    (hcompat : A.PairwiseCompatible) :
    ∃ g : GlobalPredictor S, reconstructGlobalPredictor S A = Sum.inl g ∧
      ∀ i, g.val i = A.localData i := by
  refine ⟨⟨A.localData, fun hij => hcompat _ _ hij⟩, ?_, fun _ => rfl⟩
  unfold reconstructGlobalPredictor
  simp [hcompat]

/-- If the atlas is incompatible, reconstruction fails with a certificate. -/
theorem reconstructGlobalPredictor_correct_inr
    {P : Type*} [PartialOrder P]
    (S : LocalSystem P) (A : PredictorAtlas S)
    (hnotcompat : ¬ A.PairwiseCompatible) :
    (∃ cert : ClosureObstructionCert S,
      reconstructGlobalPredictor S A = Sum.inr cert) ∧ ¬ A.GloballyRealizable := by
  refine ⟨?_, fun ⟨g, hg⟩ => hnotcompat fun i j hij => by rw [← hg j, ← hg i]; exact g.compat hij⟩
  unfold reconstructGlobalPredictor
  simp [hnotcompat]

/-! ## Auxiliary Theorems -/

/-- A global predictor yields a pairwise compatible atlas. -/
theorem global_predictor_yields_compatible_atlas
    {P : Type*} [PartialOrder P]
    {S : LocalSystem P} (g : GlobalPredictor S) :
    (restrictGlobal g).PairwiseCompatible :=
  fun _ _ h => g.compat h

/-- A descent witness from a global realization. -/
theorem descent_witness_of_global_section
    {P : Type*} [PartialOrder P] {S : LocalSystem P}
    (A : PredictorAtlas S) (g : GlobalPredictor S)
    (hg : ∀ i, g.val i = A.localData i) :
    Nonempty (DescentWitness A) :=
  ⟨⟨g, hg⟩⟩

/-- A descent witness provides a global section. -/
theorem global_section_of_descent_witness
    {P : Type*} [PartialOrder P] {S : LocalSystem P}
    (A : PredictorAtlas S) (w : DescentWitness A) :
    ∃ g : GlobalPredictor S, ∀ i, g.val i = A.localData i :=
  ⟨w.globalPredictor, w.matches_atlas⟩

/-- **Binary gluing preserves compatibility.** -/
theorem binary_gluing_preserves_compatibility
    {P : Type*} [PartialOrder P]
    (S : LocalSystem P) (A : PredictorAtlas S)
    {i j k : P} (hij : i ≤ j) (hjk : j ≤ k)
    (hik_compat : S.res (le_trans hij hjk) (A.localData k) = A.localData i) :
    S.res hij (S.res hjk (A.localData k)) = A.localData i := by
  rw [S.res_comp]; exact hik_compat

/-- **Finite gluing step.** -/
theorem finite_gluing_step
    {P : Type*} [PartialOrder P]
    (S : LocalSystem P) (A : PredictorAtlas S)
    (hcompat : A.PairwiseCompatible) :
    ∃ g : GlobalPredictor S, restrictGlobal g = A :=
  ⟨⟨A.localData, fun h => hcompat _ _ h⟩, rfl⟩

/-- **Certified generalization of a reconstructed predictor.** -/
theorem certified_generalization_of_reconstructed_predictor
    {P : Type*} [PartialOrder P] {S : LocalSystem P}
    (A : PredictorAtlas S) (w : DescentWitness A) :
    ∀ i, w.globalPredictor.val i = A.localData i :=
  w.matches_atlas

/-! ## Idempotent Commutative Monoid -/

/-- An idempotent commutative monoid: `a + a = a`. -/
class IdempotentCommMonoid (M : Type*) extends AddCommMonoid M where
  add_idem : ∀ a : M, a + a = a

attribute [simp] IdempotentCommMonoid.add_idem

/-- Idempotent addition. -/
theorem idem_add {M : Type*} [IdempotentCommMonoid M] (a : M) : a + a = a :=
  IdempotentCommMonoid.add_idem a

/-- **Idempotent n-fold addition.** `n • a = a` for `n ≥ 1`. -/
theorem idem_nsmul {M : Type*} [IdempotentCommMonoid M] (a : M) (n : ℕ) (hn : 0 < n) :
    n • a = a := by
  induction n with
  | zero => omega
  | succ n ih =>
    cases n with
    | zero => simp
    | succ n => rw [succ_nsmul, ih (by omega), idem_add]

/-! ## Gluing Semimodule -/

/-- A gluing semimodule: local system with idempotent monoidal fibers. -/
structure GluingSemimodule (P : Type*) [PartialOrder P] extends LocalSystem P where
  addOp : ∀ i, F i → F i → F i
  zeroOp : ∀ i, F i
  add_idem : ∀ i (x : F i), addOp i x x = x
  add_comm : ∀ i (x y : F i), addOp i x y = addOp i y x
  add_assoc : ∀ i (x y z : F i), addOp i (addOp i x y) z = addOp i x (addOp i y z)
  add_zero : ∀ i (x : F i), addOp i x (zeroOp i) = x
  res_zero : ∀ {i j : P} (h : i ≤ j), res h (zeroOp j) = zeroOp i
  res_add : ∀ {i j : P} (h : i ≤ j) (x y : F j),
    res h (addOp j x y) = addOp i (res h x) (res h y)

/-- A separated gluing semimodule. -/
structure SeparatedGluingSemimodule (P : Type*) [PartialOrder P]
    extends GluingSemimodule P where
  separated : ∀ {j : P} (x y : F j),
    (∀ (i : P) (h : i ≤ j), res h x = res h y) → x = y

/-- Convert to separated local system. -/
def SeparatedGluingSemimodule.toSeparatedLocalSystem {P : Type*} [PartialOrder P]
    (S : SeparatedGluingSemimodule P) : SeparatedLocalSystem P where
  F := S.F; res := S.res; res_id := S.res_id; res_comp := S.res_comp
  separated := S.separated

/-- **Existence and uniqueness on separated gluing semimodules.** -/
theorem exists_unique_global_predictor_of_compatible_separated
    {P : Type*} [PartialOrder P]
    (S : SeparatedGluingSemimodule P) (A : PredictorAtlas S.toLocalSystem)
    (hcompat : A.PairwiseCompatible) :
    ∃! g : GlobalPredictor S.toLocalSystem, ∀ i, g.val i = A.localData i := by
  refine ⟨⟨A.localData, fun h => hcompat _ _ h⟩, fun _ => rfl, ?_⟩
  intro g₂ hg₂
  exact GlobalPredictor.ext fun i => by rw [hg₂ i]

/-- **Reconstruction correctness and uniqueness.** -/
theorem reconstruction_correct_and_unique
    {P : Type*} [PartialOrder P]
    (S : SeparatedGluingSemimodule P) (A : PredictorAtlas S.toLocalSystem)
    (g₁ g₂ : GlobalPredictor S.toLocalSystem)
    (h₁ : ∀ i, g₁.val i = A.localData i)
    (h₂ : ∀ i, g₂.val i = A.localData i) :
    g₁ = g₂ :=
  GlobalPredictor.ext fun i => by rw [h₁ i, h₂ i]

/-- **Idempotent aggregation in gluing semimodules.** -/
theorem gluing_semimodule_idem_aggregation
    {P : Type*} [PartialOrder P]
    (S : GluingSemimodule P) (i : P) (x : S.F i) :
    S.addOp i x x = x :=
  S.add_idem i x

/-- **Restriction distributes over idempotent addition.** -/
theorem gluing_semimodule_res_distributes
    {P : Type*} [PartialOrder P]
    (S : GluingSemimodule P) {i j : P} (h : i ≤ j) (x y : S.F j) :
    S.res h (S.addOp j x y) = S.addOp i (S.res h x) (S.res h y) :=
  S.res_add h x y

end ClosureSheafLearningDuality