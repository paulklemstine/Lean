/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib
import Tropical.PosetTheory.MinPlusAlgebra

/-!
# Stable cores and rank monotonicity of adjoint analogies

An analogy between ordered structures is represented by an adjoint pair.  Its source
round trip is a closure operator and its target round trip is an interior operator.
This chapter identifies their fixed-point posets by an order isomorphism and proves a
finite rank theorem: the number of stable source points is the cardinality of the
closure image, and cannot increase under composition.

The result links order-theoretic adjunctions, finite combinatorial rank, and tropical
matrix maps.  The imported min-plus algebra supplies the motivating family of forward
maps, while the arguments apply to every adjoint pair of finite partial orders.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): The stable points of the two round trips should form the
lossless core of every analogy.  More boldly, their cardinality should behave like rank
under composition, bounded by the rank of either factor.

Experiment (Experimenter): The closure image was compared directly with its fixed-point
subtype.  For a composite, stable points were injected into the first stable core by the
unit inequalities, and into the second stable core by applying the second closure after
the first forward map.

Analysis (Analyst): Idempotence is exactly the condition making image and fixed-point
rank coincide.  The second rank bound does not follow by sending a stable point merely
through the first forward map: that point need not already be stable for the second
closure.  Applying the second closure repairs this boundary case and preserves
injectivity.

Critique (Critic): One-sided perfection is not assumed, and neither component need be
injective.  The bounds include empty finite orders and are cardinal inequalities rather
than consequences of surjectivity assumptions.  A constant analogy from `Bool` to
`PUnit` exhibits a genuinely lossy boundary case with a one-point stable core.

Synthesis (Principal Investigator): Every adjoint analogy contains canonically
isomorphic source and target cores.  Their finite cardinality is an image rank, and the
rank is nonincreasing under chaining.  This yields a generalization from tropical
residuation to arbitrary finite ordered structures and a broader categorical rank law.
-/

namespace Tropical
namespace StableAnalogy

/-- An order-theoretic analogy is a pair of maps satisfying the adjunction law. -/
structure Analogy (A B : Type*) [PartialOrder A] [PartialOrder B] where
  forward : A → B
  backward : B → A
  adjoint : ∀ a b, forward a ≤ b ↔ a ≤ backward b

namespace Analogy

variable {A B C : Type*} [PartialOrder A] [PartialOrder B] [PartialOrder C]

/-
The forward translation is monotone.
-/
theorem forward_mono (f : Analogy A B) : Monotone f.forward := by
  intro a a';
  exact fun ha => f.adjoint _ _ |>.2 ( ha.trans ( f.adjoint _ _ |>.1 le_rfl ) )

/-
The backward translation is monotone.
-/
theorem backward_mono (f : Analogy A B) : Monotone f.backward := by
  intro b b' hbb';
  have := f.adjoint ( f.backward b ) b';
  exact this.mp ( le_trans ( f.adjoint _ _ |>.2 le_rfl ) hbb' )

/-
The source-side unit inequality.
-/
theorem unit_le (f : Analogy A B) (a : A) : a ≤ f.backward (f.forward a) := by
  exact f.adjoint _ _ |>.1 le_rfl

/-
The target-side counit inequality.
-/
theorem counit_le (f : Analogy A B) (b : B) : f.forward (f.backward b) ≤ b := by
  exact f.adjoint _ _ |>.2 le_rfl

/-- The source round trip. -/
def closure (f : Analogy A B) : A → A := fun a => f.backward (f.forward a)

/-- The target round trip. -/
def interior (f : Analogy A B) : B → B := fun b => f.forward (f.backward b)

/-
The source closure stabilizes after one application.
-/
theorem closure_idem (f : Analogy A B) (a : A) :
    f.closure (f.closure a) = f.closure a := by
  refine' le_antisymm _ _;
  · convert f.backward_mono ( counit_le f ( f.forward a ) ) using 1;
  · apply f.unit_le

/-
The target interior stabilizes after one application.
-/
theorem interior_idem (f : Analogy A B) (b : B) :
    f.interior (f.interior b) = f.interior b := by
  refine' le_antisymm _ _;
  · exact f.counit_le _;
  · convert f.forward_mono ( unit_le f ( f.backward b ) ) using 1

/-- Stable concepts on the source side. -/
abbrev SourceCore (f : Analogy A B) := {a : A // f.closure a = a}

/-- Stable concepts on the target side. -/
abbrev TargetCore (f : Analogy A B) := {b : B // f.interior b = b}

/-- Every analogy restricts to an order isomorphism between its stable cores. -/
def stableCoreOrderIso (f : Analogy A B) : f.SourceCore ≃o f.TargetCore where
  toEquiv :=
    { toFun := fun a => ⟨f.forward a, congrArg f.forward a.property⟩
      invFun := fun b => ⟨f.backward b, congrArg f.backward b.property⟩
      left_inv := fun a => Subtype.ext a.property
      right_inv := fun b => Subtype.ext b.property }
  map_rel_iff' := by
    intro a a'
    constructor
    · intro h
      change f.forward a.1 ≤ f.forward a'.1 at h
      have hback := f.backward_mono h
      change f.closure a.1 ≤ f.closure a'.1 at hback
      rw [a.property, a'.property] at hback
      exact hback
    · intro h
      change f.forward a.1 ≤ f.forward a'.1
      exact f.forward_mono h

/-
The stable source and target cores have equal finite cardinality.
-/
theorem sourceCore_card_eq_targetCore_card (f : Analogy A B)
    [Fintype A] [Fintype B] :
    Fintype.card f.SourceCore = Fintype.card f.TargetCore := by
  convert Fintype.card_congr ( stableCoreOrderIso f ).toEquiv

/-- The image of the source closure, represented as a subtype. -/
abbrev ClosureImage (f : Analogy A B) := {a : A // ∃ x, f.closure x = a}

/-- Idempotence identifies the closure image with the stable source core. -/
def closureImageEquivSourceCore (f : Analogy A B) :
    f.ClosureImage ≃ f.SourceCore where
  toFun x := ⟨x.1, by
    obtain ⟨a, ha⟩ := x.2
    rw [← ha, f.closure_idem]⟩
  invFun x := ⟨x.1, ⟨x.1, x.property⟩⟩
  left_inv x := Subtype.ext rfl
  right_inv x := Subtype.ext rfl

/-- The finite fidelity rank is the number of stable source points. -/
noncomputable def rank (f : Analogy A B) [Fintype A] : ℕ := Fintype.card f.SourceCore

/-
Fidelity rank equals the cardinality of the closure image.
-/
theorem rank_eq_closureImage_card (f : Analogy A B) [Fintype A] :
    f.rank = Fintype.card f.ClosureImage := by
  convert Fintype.card_congr ( closureImageEquivSourceCore f ).symm using 1

/-- Composition of analogies, with backward maps composed in reverse order. -/
def comp (g : Analogy B C) (f : Analogy A B) : Analogy A C where
  forward := g.forward ∘ f.forward
  backward := f.backward ∘ g.backward
  adjoint := by
    intro a c
    exact (g.adjoint _ _).trans (f.adjoint _ _)

/-- A point stable under a composite is already stable under the first analogy. -/
def compositeCoreToFirst (g : Analogy B C) (f : Analogy A B) :
    (g.comp f).SourceCore → f.SourceCore := fun a => ⟨a.1, by
  apply le_antisymm
  · have hu : f.forward a.1 ≤ g.backward (g.forward (f.forward a.1)) := g.unit_le _
    have hb := f.backward_mono hu
    change f.closure a.1 ≤ (g.comp f).closure a.1 at hb
    rw [a.property] at hb
    exact hb
  · exact f.unit_le a.1⟩

/-
The first-core comparison map is injective.
-/
theorem compositeCoreToFirst_injective (g : Analogy B C) (f : Analogy A B) :
    Function.Injective (compositeCoreToFirst g f) := by
  intro a b hab;
  injection hab;
  exact Subtype.ext ‹_›

/-- A composite-stable point maps injectively into the second stable core after
stabilization by the second closure. -/
def compositeCoreToSecond (g : Analogy B C) (f : Analogy A B) :
    (g.comp f).SourceCore → g.SourceCore := fun a =>
  ⟨g.closure (f.forward a.1), g.closure_idem _⟩

/-
The second-core comparison map is injective.
-/
theorem compositeCoreToSecond_injective (g : Analogy B C) (f : Analogy A B) :
    Function.Injective (compositeCoreToSecond g f) := by
  intro a b hab;
  apply Subtype.ext;
  have h_eq : f.backward (g.closure (f.forward a)) = a ∧ f.backward (g.closure (f.forward b)) = b := by
    have := a.2; have := b.2; simp_all +decide [ Analogy.closure, Analogy.comp ] ;
  exact h_eq.1.symm.trans ( congr_arg _ ( congr_arg Subtype.val hab ) |> Eq.trans <| h_eq.2 )

/-
**Rank monotonicity under composition.** The stable rank of a chained analogy
cannot exceed the rank of either component.
-/
theorem rank_comp_le_min (g : Analogy B C) (f : Analogy A B)
    [Fintype A] [Fintype B] :
    (g.comp f).rank ≤ min f.rank g.rank := by
  refine' le_min _ _;
  · convert Fintype.card_le_of_injective _ ( compositeCoreToFirst_injective g f ) using 1;
  · convert Fintype.card_le_of_injective _ ( compositeCoreToSecond_injective g f ) using 1

/-- The identity analogy. -/
def id (A : Type*) [PartialOrder A] : Analogy A A where
  forward := _root_.id
  backward := _root_.id
  adjoint := fun _ _ => Iff.rfl

/-
Identity analogies have full finite rank.
-/
theorem rank_id [Fintype A] : (Analogy.id A).rank = Fintype.card A := by
  refine' Fintype.card_congr _;
  symm;
  refine' Equiv.ofBijective ( fun a => ⟨ a, _ ⟩ ) ⟨ fun a b h => _, fun a => _ ⟩ <;> aesop

/-- A concrete lossy analogy from the two-element order to the one-element order. -/
def boolToPUnit : Analogy Bool PUnit where
  forward := fun _ => PUnit.unit
  backward := fun _ => true
  adjoint := by
    intro a b
    simp

example : boolToPUnit.closure false = true := by
  rfl

-- The imported tropical operation is a concrete family of monotone forward maps.
example {n : ℕ} [NeZero n] (M : Matrix (Fin n) (Fin n) ℝ) :
    Monotone (tropMatVecMul M) := by
  exact tropMatVecMul_monotone M

end Analogy
end StableAnalogy
end Tropical