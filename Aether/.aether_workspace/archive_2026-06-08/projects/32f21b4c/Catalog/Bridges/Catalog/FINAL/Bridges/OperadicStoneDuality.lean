import Mathlib

/-!
# Operadic Stone Duality: Neural Heyting Semimodules and
  Certified Architecture–Kripke Reconstruction

Bridge: connects Algebra (distributive lattices, Heyting algebras, Birkhoff duality)
  to Machine Learning (neural architecture identifiability, operadic deep learning)
  to Logic (intuitionistic Kripke semantics, prime filters, bounded morphisms).

## Overview

We prove that finitely generated acyclic neural architectures admit a canonical
intuitionistic semantics — a finite Heyting algebra of *monotone predicates*
(upper sets of the module poset) — from which the architecture can be
reconstructed up to isomorphism.

The upper set lattice `UpperSet N.Module` is a finite distributive lattice
and Heyting algebra. Its join-irreducible elements are the principal upper sets
`↑m = Ici m`, which correspond bijectively to modules. The module partial order
is recovered via `m₁ ≤ m₂ ↔ Ici m₁ ≤ Ici m₂` (in the UpperSet order).

An order isomorphism of upper-set lattices therefore induces an order isomorphism
of module posets, establishing the reconstruction theorem.

## Main Results

* `pred_distrib_lattice` — upper sets form a distributive lattice
* `pred_heyting` — upper sets form a Heyting algebra
* `pred_finite` — the lattice is finite
* `ici_orderEmbedding` — m ↦ Ici m is an order embedding
* `principalUpper_joinIrred` — principal upper sets are join-irreducible
* `joinIrred_iff_principal` — join-irreducibles = principal upper sets
* `soundness_completeness` — lattice order = Kripke semantic entailment
* `upperPredMap_contravariant` — contravariant functoriality
* `iso_induces_order_iso` — upper-set lattice iso ⟹ module order iso
* `semantics_determines_architecture` — the main reconstruction theorem
-/

open Set Function

noncomputable section

namespace OperadicStoneDuality

/-! ## Part I: Neural Architecture Foundations -/

/-- A finitely generated acyclic neural architecture.
    Bridge: ML (neural architecture) ↔ Algebra (finite partial order). -/
structure NeuralArchFG where
  /-- The type of modules/layers -/
  Module : Type
  [instFintype : Fintype Module]
  [instDecEq : DecidableEq Module]
  [instPartialOrder : PartialOrder Module]
  /-- The primitive generators -/
  generators : Finset Module
  /-- Every module is above some generator -/
  generation : ∀ m : Module, ∃ g ∈ generators, g ≤ m
  /-- Generators are nonempty -/
  gen_nonempty : generators.Nonempty

attribute [instance] NeuralArchFG.instFintype NeuralArchFG.instDecEq
  NeuralArchFG.instPartialOrder

/-! ## Part II: Upper Set Predicate Lattice

We use Mathlib's `UpperSet α` — the type of upward-closed subsets of a
preordered type. For a finite partial order, this is automatically:
- a distributive lattice (`DistribLattice`)
- a Heyting algebra (`HeytingAlgebra`)
- finite (`Finite`)

The ordering on `UpperSet α` is: `U ≤ V ↔ V.carrier ⊆ U.carrier` (reverse
inclusion). This means `Ici m₁ ≤ Ici m₂ ↔ m₁ ≤ m₂`, so the map `m ↦ Ici m`
is an order embedding. -/

/-- The predicate lattice is a distributive lattice. -/
instance pred_distrib_lattice (N : NeuralArchFG) :
    DistribLattice (UpperSet N.Module) := inferInstance

/-- The predicate lattice is a Heyting algebra. -/
instance pred_heyting (N : NeuralArchFG) :
    HeytingAlgebra (UpperSet N.Module) := inferInstance

/-- The predicate lattice is finite. -/
theorem pred_finite (N : NeuralArchFG) : Finite (UpperSet N.Module) := inferInstance

/-! ## Part III: Principal Upper Sets and Order Embedding

The map `m ↦ Ici m` sends modules to their principal upper sets.
This is an order embedding, meaning the module partial order is
faithfully encoded in the upper set lattice. -/

/-
The principal upper set map is an order embedding.
    This is the key structural fact: the module order is encoded
    in the upper-set lattice order.

    Bridge: Order theory (Birkhoff embedding) ↔ ML (architecture encoding).
-/
theorem ici_le_ici_iff (N : NeuralArchFG) (m₁ m₂ : N.Module) :
    UpperSet.Ici m₁ ≤ UpperSet.Ici m₂ ↔ m₁ ≤ m₂ := by
  constructor;
  · intro h; have := h ( by aesop : m₂ ∈ UpperSet.Ici m₂ ) ; aesop;
  · exact fun h => fun x hx => le_trans h hx

/-
The map `m ↦ Ici m` is injective.
    Bridge: Algebra (separation).
-/
theorem ici_injective (N : NeuralArchFG) :
    Injective (UpperSet.Ici : N.Module → UpperSet N.Module) :=
  UpperSet.Ici_injective

/-- The order embedding from modules to upper sets. -/
def iciOrderEmbedding (N : NeuralArchFG) :
    N.Module ↪o UpperSet N.Module where
  toFun := UpperSet.Ici
  inj' := ici_injective N
  map_rel_iff' := ici_le_ici_iff N _ _

/-! ## Part IV: Join-Irreducibles

An element of a bounded lattice is join-irreducible if it's nonzero and
cannot be written as a non-trivial join. The join-irreducibles of
`UpperSet α` are exactly the principal upper sets `Ici m`. -/

/-
Principal upper sets are meet-irreducible (`InfIrred`) in the upper set lattice.
    In Mathlib's `UpperSet`, `⊓ = ∪` and `⊔ = ∩`, so meet-irreducibility means
    `Ici m` cannot be written as `A ∪ B` for strictly larger `A`, `B`.

    Proof: if `Ici m = A ∪ B` then `m ∈ A` or `m ∈ B`. WLOG `m ∈ A`.
    Since `A` is upper, `Ici m ⊆ A ⊆ A ∪ B = Ici m`, so `A = Ici m`.

    Bridge: Algebra (meet-irreducible) ↔ ML (atomic module).
-/
theorem principalUpper_infIrred (N : NeuralArchFG) (m : N.Module) :
    InfIrred (UpperSet.Ici m : UpperSet N.Module) := by
  simp +decide

/-
Meet-irreducible upper sets are exactly the principal upper sets.
    Bridge: Algebra (classification of irreducibles) ↔ ML (module identification).
-/
theorem infIrred_iff_principal (N : NeuralArchFG) (U : UpperSet N.Module) :
    InfIrred U ↔ ∃ m : N.Module, U = UpperSet.Ici m := by
  grind +suggestions

/-
The meet-irreducibles biject with modules.
-/
theorem infIrred_bijection (N : NeuralArchFG) :
    ∃ f : N.Module → {U : UpperSet N.Module // InfIrred U},
      Function.Bijective f := by
  refine' ⟨ _, _, _ ⟩;
  exact fun m => ⟨ UpperSet.Ici m, principalUpper_infIrred N m ⟩;
  · exact fun m m' h => ici_injective N <| by injection h;
  · intro ⟨ U, hU ⟩ ; cases infIrred_iff_principal N U |>.1 hU ; aesop;

/-! ## Part V: Soundness and Completeness -/

/-- Kripke forcing: world w forces proposition U iff w ∈ U. -/
def kforces (N : NeuralArchFG) (w : N.Module) (U : UpperSet N.Module) : Prop :=
  w ∈ U

/-- Semantic entailment: V entails U means every world in V is also in U.
    Note: In the `UpperSet` order, `U ≤ V` means `V ⊆ U` as sets,
    so `U ≤ V` means V entails U (V is stronger than U). -/
def ksemEntails (N : NeuralArchFG) (V U : UpperSet N.Module) : Prop :=
  ∀ w, kforces N w V → kforces N w U

/-- **Theorem (Soundness and Completeness):**
    `U ≤ V` in the upper-set lattice iff V semantically entails U,
    i.e., every world forcing V also forces U.

    Bridge: Algebra (lattice order) ↔ Logic (semantic entailment). -/
theorem soundness_completeness (N : NeuralArchFG) (U V : UpperSet N.Module) :
    U ≤ V ↔ ksemEntails N V U := by
  simp only [kforces, ksemEntails]
  exact Iff.rfl

/-! ## Part VI: Architecture Morphisms and Contravariance -/

/-- A morphism of neural architectures. -/
structure NeuralArchHom (N M : NeuralArchFG) where
  toFun : N.Module → M.Module
  monotone : Monotone toFun
  gen_map : ∀ g ∈ N.generators, toFun g ∈ M.generators

/-- The inverse image map on upper-set predicates.
    Bridge: Algebra (contravariant functor) ↔ Logic (substitution). -/
def upperPredMap {N M : NeuralArchFG} (f : NeuralArchHom N M) :
    UpperSet M.Module → UpperSet N.Module :=
  fun U => ⟨f.toFun ⁻¹' (U : Set M.Module),
    fun _ _ hxy hx => U.upper (f.monotone hxy) hx⟩

/-- Identity morphism. -/
def neuralArchId (N : NeuralArchFG) : NeuralArchHom N N where
  toFun := id
  monotone := fun _ _ h => h
  gen_map := fun _ hg => hg

/-- Composition of morphisms. -/
def neuralArchComp {N M P : NeuralArchFG}
    (f : NeuralArchHom N M) (g : NeuralArchHom M P) : NeuralArchHom N P where
  toFun := g.toFun ∘ f.toFun
  monotone := fun _ _ h => g.monotone (f.monotone h)
  gen_map := fun gen hgen => g.gen_map _ (f.gen_map gen hgen)

/-
**Theorem (Contravariant Functoriality):**
    upperPredMap respects composition contravariantly.
-/
theorem upperPredMap_contravariant {N M P : NeuralArchFG}
    (f : NeuralArchHom N M) (g : NeuralArchHom M P) (Q : UpperSet P.Module) :
    upperPredMap (neuralArchComp f g) Q = upperPredMap f (upperPredMap g Q) := by
  unfold upperPredMap neuralArchComp; aesop;

/-
upperPredMap preserves identity.
-/
theorem upperPredMap_id (N : NeuralArchFG) (U : UpperSet N.Module) :
    upperPredMap (neuralArchId N) U = U :=
  UpperSet.ext_iff.mpr rfl

/-! ## Part VII: Reconstruction Theorem -/

/-- Two architectures are isomorphic. -/
def NeuralArchIso (N M : NeuralArchFG) : Prop :=
  ∃ f : N.Module ≃o M.Module,
    (∀ g, g ∈ N.generators → f g ∈ M.generators) ∧
    (∀ g, g ∈ M.generators → f.symm g ∈ N.generators)

/-
**Key Lemma:** An order isomorphism of upper-set lattices preserves
    meet-irreducibles.
-/
theorem iso_preserves_infIrred {N M : NeuralArchFG}
    (h : UpperSet N.Module ≃o UpperSet M.Module) (U : UpperSet N.Module) :
    InfIrred U → InfIrred (h U) := by
  unfold InfIrred;
  simp +decide [ IsMax, eq_comm ];
  intro x hx₁ hx₂ hx₃;
  refine' ⟨ ⟨ h x, h.monotone hx₁, _ ⟩, _ ⟩;
  · exact fun h' => hx₂ <| h.le_iff_le.mp h';
  · intro b c hbc;
    have := hx₃ ( show U = h.symm b ⊓ h.symm c from ?_ );
    · cases this <;> simp_all +decide [ ← h.injective.eq_iff ];
    · rw [ ← h.symm_apply_apply U, ← hbc, h.symm.map_inf ]

/-
**Key Lemma:** An order isomorphism of upper-set lattices induces
    an order isomorphism of the module posets.
-/
theorem iso_induces_order_iso {N M : NeuralArchFG}
    (h : UpperSet N.Module ≃o UpperSet M.Module) :
    ∃ f : N.Module ≃o M.Module,
      ∀ m, h (UpperSet.Ici m) = UpperSet.Ici (f m) := by
  have h_iso : ∀ m : N.Module, ∃ n : M.Module, h (UpperSet.Ici m) = UpperSet.Ici n := by
    have := @iso_preserves_infIrred;
    exact fun m => by have := this h ( UpperSet.Ici m ) ( principalUpper_infIrred N m ) ; rw [ infIrred_iff_principal ] at this; tauto;
  choose f hf using h_iso;
  have h_inj : Function.Injective f := by
    intro m₁ m₂ h_eq;
    have := h.injective ( by aesop : h ( UpperSet.Ici m₁ ) = h ( UpperSet.Ici m₂ ) ) ; aesop;
  have h_surj : Function.Surjective f := by
    have h_surj : ∀ m : M.Module, ∃ n : N.Module, h.symm (UpperSet.Ici m) = UpperSet.Ici n := by
      intro m;
      have := infIrred_iff_principal N ( h.symm ( UpperSet.Ici m ) );
      exact this.mp ( by simpa using iso_preserves_infIrred h.symm _ ( principalUpper_infIrred M m ) );
    intro m; obtain ⟨ n, hn ⟩ := h_surj m; use n; have := h.apply_symm_apply ( UpperSet.Ici m ) ; aesop;
  have h_order_iso : ∀ m₁ m₂ : N.Module, m₁ ≤ m₂ ↔ f m₁ ≤ f m₂ := by
    intros m₁ m₂; exact ⟨fun hmn => by
      have h_order_iso : h (UpperSet.Ici m₁) ≤ h (UpperSet.Ici m₂) := by
        exact h.monotone ( by aesop );
      aesop, fun hmn => by
      have := h.le_iff_le.mp ( show h ( UpperSet.Ici m₁ ) ≤ h ( UpperSet.Ici m₂ ) from by aesop ) ; aesop;⟩;
  refine' ⟨ { Equiv.ofBijective f ⟨ h_inj, h_surj ⟩ with map_rel_iff' := _ }, hf ⟩;
  exact fun { a b } => Iff.symm ( h_order_iso a b )

/-
**Main Theorem (Semantics Determines Architecture):**
    If two architectures have isomorphic upper-set predicate lattices,
    and the isomorphism preserves generator-marking, then the architectures
    are isomorphic.

    Bridge: ML (architecture identifiability) ↔ Algebra (lattice determines poset)
    ↔ Logic (semantics determines syntax).
-/
theorem semantics_determines_architecture (N M : NeuralArchFG)
    (h : UpperSet N.Module ≃o UpperSet M.Module)
    (hgen_fwd : ∀ g ∈ N.generators,
      ∃ g' ∈ M.generators, h (UpperSet.Ici g) = UpperSet.Ici g')
    (hgen_bwd : ∀ g ∈ M.generators,
      ∃ g' ∈ N.generators, h (UpperSet.Ici g') = UpperSet.Ici g) :
    NeuralArchIso N M := by
  obtain ⟨ f, hf ⟩ := iso_induces_order_iso h;
  refine' ⟨ f, _, _ ⟩;
  · intro g hg; specialize hgen_fwd g hg; aesop;
  · intro g hg; specialize hgen_bwd g hg; aesop;

/-! ## Part VIII: Persistence -/

/-- Activation predicates (principal upper sets) are persistent. -/
theorem activation_persistent (N : NeuralArchFG) (m : N.Module) :
    ∀ w₁ w₂ : N.Module, w₁ ≤ w₂ → w₁ ∈ (UpperSet.Ici m : UpperSet N.Module) →
      w₂ ∈ (UpperSet.Ici m : UpperSet N.Module) := by
  intro w₁ w₂ h hw₁
  simp [UpperSet.mem_Ici_iff] at hw₁ ⊢
  exact le_trans hw₁ h

/-! ## Part IX: Semimodule Enrichment -/

/-- A neural Heyting semimodule: a Heyting algebra with a compatible
    semimodule structure over a semiring S. -/
class NeuralHeytingSemimodule (S : Type*) (H : Type*) [Semiring S]
    [HeytingAlgebra H] [AddCommMonoid H] [Module S H] : Prop where
  smul_inf : ∀ (s : S) (a b : H), s • (a ⊓ b) = s • a ⊓ s • b

/-! ## Part X: Concrete Examples -/

/-- A 3-layer feedforward architecture. -/
def threeLayerArch : NeuralArchFG where
  Module := Fin 3
  generators := {0}
  generation := fun m => ⟨0, Finset.mem_singleton.mpr rfl, Fin.zero_le m⟩
  gen_nonempty := ⟨0, Finset.mem_singleton.mpr rfl⟩

example : HeytingAlgebra (UpperSet threeLayerArch.Module) := inferInstance
example : Finite (UpperSet threeLayerArch.Module) := inferInstance

/-- A discrete 2-module architecture (parallel modules). -/
def parallelArch : NeuralArchFG where
  Module := Fin 2
  generators := {0, 1}
  generation := fun m => by fin_cases m <;> [exact ⟨0, by simp, le_refl _⟩; exact ⟨1, by simp, le_refl _⟩]
  gen_nonempty := ⟨0, by simp⟩

end OperadicStoneDuality