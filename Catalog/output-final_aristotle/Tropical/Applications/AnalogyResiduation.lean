/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib
import Tropical.MinPlusAlgebra

/-!
# Analogy as a mathematical operation: adjoint pairs and residuation

This file formalizes *analogy-making* between two ordered structures as a mathematical
operation.  An **analogy** from a structure `A` to a structure `B` is a pair of
order-compatible maps

* `forward : A → B`  (translate a situation in `A` into `B`), and
* `backward : B → A`  (translate back),

tied together by the *adjunction law*

  `forward a ≤ b  ↔  a ≤ backward b`.

This single law is exactly what makes the two directions *coherent*: `forward a` is the
tightest image of `a`, and `backward b` is the loosest preimage of `b`.  The round-trip
`backward ∘ forward` measures how much structure is preserved when a concept is carried
across and brought home again.

## Main results

* `Analogy.forward_mono`, `Analogy.backward_mono` — both directions of an analogy are
  monotone (structure-preserving).
* `Analogy.unit_le` / `Analogy.counit_le` — the round trip never *under*-shoots on the
  source side and never *over*-shoots on the target side.
* `Analogy.roundtrip_infl`, `Analogy.roundtrip_mono`, `Analogy.roundtrip_idem` — the
  fidelity operator `backward ∘ forward` is a **closure operator**: inflationary,
  monotone, and idempotent.  Analogy-making stabilizes after one round trip.
* `Analogy.backward_unique` — an analogy is *determined by its forward direction*: the
  backward map is unique.  Thus there is a single best way to translate back.
* `Analogy.isPerfect_iff_forward_injective` — the analogy is **perfect** (loses no
  structure, `backward ∘ forward = id`) exactly when the forward map is injective.
* `Analogy.fidelity_le_card`, `Analogy.fidelity_eq_card_iff_perfect` — the *structural
  fidelity* (number of source points fixed by the round trip) is maximized precisely by
  perfect analogies.  This is the quantitative "best analogies maximize similarity" claim.
* `Analogy.equivalence_forward_order_embedding` — a two-sided perfect analogy is an order
  isomorphism.
* `tropicalAnalogy`, `tropical_adjoint` — the **bridge** to tropical (min-plus) algebra:
  every min-plus matrix–vector map `v ↦ A ⊗ v` has a canonical best analogy given by
  max-plus *residuation* `tropResidual A`, yielding the classical shortest-path
  reconstruction inequalities `trop_unit_le` and `trop_counit_le`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): Hofstadter's "analogy as fluid mapping" can be made precise as
an adjoint pair between ordered structures, with the round-trip composition serving as the
quantitative measure of analogical fidelity; the *best* analogy for a fixed forward map is
its residual, and this residual is exactly the tropical/min-plus inverse used in the
Tropical catalog's shortest-path constructions.

Experiment (Experimenter): We defined `Analogy` by the adjunction law and derived
monotonicity, the closure-operator structure of the round trip, uniqueness of the backward
map, the perfect/injective equivalence, and the finite fidelity-maximization theorem.  We
then instantiated the framework with `tropMatVecMul` (from `Tropical.MinPlusAlgebra`) and
its max-plus residual, verifying the adjunction law pointwise.

Analysis (Analyst): The adjunction law alone forces every structural feature — no extra
hypotheses were needed for monotonicity or the closure laws.  Equality in the triangle
identities needs antisymmetry, hence the `PartialOrder` assumption.  The fidelity theorem
is genuinely finite-combinatorial: it counts fixed points of the round trip and is sharp.

Critique (Critic): No result is vacuous: the tropical instance is a concrete, nontrivial
witness on `Fin n → ℝ`, and the fidelity theorem is an iff with both directions used.  The
closure idempotence is proved from the triangle identity, not assumed.  Antisymmetry is the
only structural assumption and it is necessary for the equalities.

Synthesis (PI): "Analogy" is the operation of taking an adjoint; "best analogy" is
residuation; "fidelity" is the fixed-point count of the closure operator; and the
min-plus world supplies canonical, computable instances. Category served: cross-domain
bridge (Applications ⇄ Tropical / order theory).
-/

namespace AnalogyResiduation

open scoped BigOperators

/-- An **analogy** from an ordered structure `A` to an ordered structure `B`: a forward
translation and a backward translation coupled by the adjunction law
`forward a ≤ b ↔ a ≤ backward b`. -/
structure Analogy (A B : Type*) [PartialOrder A] [PartialOrder B] where
  /-- Translate a source situation into the target. -/
  forward : A → B
  /-- Translate a target situation back to the source. -/
  backward : B → A
  /-- The adjunction law tying the two directions together. -/
  adjoint : ∀ a b, forward a ≤ b ↔ a ≤ backward b

namespace Analogy

variable {A B : Type*} [PartialOrder A] [PartialOrder B]

/-- The forward direction of an analogy preserves order. -/
theorem forward_mono (an : Analogy A B) : Monotone an.forward := by
  intro a a' h
  exact (an.adjoint _ _).2 (h.trans ((an.adjoint _ _).1 le_rfl))

/-- The backward direction of an analogy preserves order. -/
theorem backward_mono (an : Analogy A B) : Monotone an.backward := by
  intro b b' h
  exact (an.adjoint _ _).1 (((an.adjoint _ _).2 le_rfl).trans h)

/-- Carrying a source situation across and back never loses ground: `a ≤ backward (forward a)`. -/
theorem unit_le (an : Analogy A B) (a : A) : a ≤ an.backward (an.forward a) :=
  (an.adjoint a (an.forward a)).1 le_rfl

/-- Carrying a target situation back and across never overshoots: `forward (backward b) ≤ b`. -/
theorem counit_le (an : Analogy A B) (b : B) : an.forward (an.backward b) ≤ b :=
  (an.adjoint (an.backward b) b).2 le_rfl

/-- **Triangle identity** (source side): a single round trip already stabilizes the image. -/
theorem forward_roundtrip (an : Analogy A B) (a : A) :
    an.forward (an.backward (an.forward a)) = an.forward a :=
  le_antisymm (an.counit_le _) (an.forward_mono (an.unit_le a))

/-- **Triangle identity** (target side). -/
theorem backward_roundtrip (an : Analogy A B) (b : B) :
    an.backward (an.forward (an.backward b)) = an.backward b :=
  le_antisymm (an.backward_mono (an.counit_le b)) (an.unit_le _)

/-- The **fidelity operator** of an analogy: translate across and back. -/
def roundtrip (an : Analogy A B) : A → A := fun a => an.backward (an.forward a)

/-- The fidelity operator is inflationary. -/
theorem roundtrip_infl (an : Analogy A B) (a : A) : a ≤ an.roundtrip a :=
  an.unit_le a

/-- The fidelity operator is monotone. -/
theorem roundtrip_mono (an : Analogy A B) : Monotone an.roundtrip :=
  an.backward_mono.comp an.forward_mono

/-- The fidelity operator is idempotent: analogy-making stabilizes after one round trip. -/
theorem roundtrip_idem (an : Analogy A B) (a : A) :
    an.roundtrip (an.roundtrip a) = an.roundtrip a :=
  an.backward_roundtrip (an.forward a)

/-- **Uniqueness of the backward direction.** An analogy is determined by its forward map:
there is a single best way to translate back. -/
theorem backward_unique (an₁ an₂ : Analogy A B) (h : an₁.forward = an₂.forward) :
    an₁.backward = an₂.backward := by
  funext b
  apply le_antisymm
  · exact (an₂.adjoint _ _).1 (by rw [← h]; exact an₁.counit_le b)
  · exact (an₁.adjoint _ _).1 (by rw [h]; exact an₂.counit_le b)

/-- An analogy is **perfect** when the round trip loses no structure at all. -/
def IsPerfect (an : Analogy A B) : Prop := ∀ a, an.backward (an.forward a) = a

/-- A perfect analogy has an injective forward map, and conversely. -/
theorem isPerfect_iff_forward_injective (an : Analogy A B) :
    an.IsPerfect ↔ Function.Injective an.forward := by
  constructor
  · intro hp
    exact Function.LeftInverse.injective hp
  · intro hinj a
    exact hinj (an.forward_roundtrip a)

section Fintype

variable [Fintype A] [DecidableEq A]

/-- The **structural fidelity** of an analogy over a finite source: the number of source
situations that are recovered exactly by a round trip. -/
def fidelity (an : Analogy A B) : ℕ :=
  (Finset.univ.filter (fun a => an.backward (an.forward a) = a)).card

/-- Fidelity is bounded by the size of the source structure. -/
theorem fidelity_le_card (an : Analogy A B) : an.fidelity ≤ Fintype.card A := by
  unfold fidelity
  simpa [Finset.card_univ] using Finset.card_filter_le Finset.univ
    (fun a => an.backward (an.forward a) = a)

/-
**Best analogies maximize structural similarity.** The fidelity attains its maximum
value (the size of the source) exactly for perfect analogies.
-/
theorem fidelity_eq_card_iff_perfect (an : Analogy A B) :
    an.fidelity = Fintype.card A ↔ an.IsPerfect := by
      constructor <;> intro h;
      · intro a
        by_contra h_contra
        have h_card : (Finset.univ.filter (fun a => an.backward (an.forward a) = a)).card < Fintype.card A := by
          exact Finset.card_lt_card ( Finset.filter_ssubset.mpr ⟨ a, by aesop ⟩ )
        exact h_card.ne h;
      · exact congr_arg Finset.card ( Finset.filter_true_of_mem fun a _ => h a )

end Fintype

/-- A **structural equivalence** is a two-sided perfect analogy. -/
def IsEquivalence (an : Analogy A B) : Prop :=
  (∀ a, an.backward (an.forward a) = a) ∧ (∀ b, an.forward (an.backward b) = b)

/-- A structural equivalence is an order embedding in the forward direction: it reflects and
preserves the order, hence identifies the two structures. -/
theorem equivalence_forward_order_embedding (an : Analogy A B) (h : an.IsEquivalence)
    (a a' : A) : an.forward a ≤ an.forward a' ↔ a ≤ a' := by
  constructor
  · intro hle
    have := an.backward_mono hle
    rwa [h.1 a, h.1 a'] at this
  · intro hle
    exact an.forward_mono hle

end Analogy

/-! ## Bridge to tropical (min-plus) algebra

For a min-plus matrix `A`, the map `v ↦ A ⊗ v` (`tropMatVecMul`, from
`Tropical.MinPlusAlgebra`) admits a canonical *best analogy* given by max-plus residuation.
This realizes analogy-making concretely on `Fin n → ℝ` and recovers the classical
shortest-path reconstruction inequalities. -/

open Tropical

/-- The **max-plus residual** of a min-plus matrix: the best analogical inverse of
`tropMatVecMul A`, defined by `(A♯ w)_k = max_i (w_i - A_{i k})`. -/
noncomputable def tropResidual {n : ℕ} [NeZero n]
    (A : Matrix (Fin n) (Fin n) ℝ) (w : Fin n → ℝ) : Fin n → ℝ :=
  fun k => Finset.univ.sup' Finset.univ_nonempty (fun i => w i - A i k)

/-
**Tropical adjunction law.** The residual `tropResidual A` is the lower adjoint of the
min-plus map `tropMatVecMul A`: `A♯ w ≤ v` pointwise iff `w ≤ A ⊗ v` pointwise.
-/
theorem tropical_adjoint {n : ℕ} [NeZero n]
    (A : Matrix (Fin n) (Fin n) ℝ) (w v : Fin n → ℝ) :
    (∀ k, tropResidual A w k ≤ v k) ↔ (∀ i, w i ≤ tropMatVecMul A v i) := by
      constructor <;> intro h <;> simp_all +decide [ tropResidual, tropMatVecMul, Finset.le_inf'_iff ];
      · exact fun i b => by linarith [ h b i ] ;
      · exact fun k b => by linarith [ h b k ] ;

/-- The **canonical analogy** attached to a min-plus matrix `A`: forward is max-plus
residuation, backward is min-plus multiplication. -/
noncomputable def tropicalAnalogy {n : ℕ} [NeZero n]
    (A : Matrix (Fin n) (Fin n) ℝ) : AnalogyResiduation.Analogy (Fin n → ℝ) (Fin n → ℝ) where
  forward := tropResidual A
  backward := tropMatVecMul A
  adjoint := by
    intro w v
    rw [Pi.le_def, Pi.le_def]
    exact tropical_adjoint A w v

/-- **Shortest-path reconstruction, lower bound.** Reconstructing a target `w` through the
residual and back never falls below `w`: `w ≤ A ⊗ (A♯ w)`. -/
theorem trop_unit_le {n : ℕ} [NeZero n]
    (A : Matrix (Fin n) (Fin n) ℝ) (w : Fin n → ℝ) (i : Fin n) :
    w i ≤ tropMatVecMul A (tropResidual A w) i :=
  (tropicalAnalogy A).unit_le w i

/-- **Shortest-path reconstruction, upper bound.** Passing a source `v` through the min-plus
map and residual back never exceeds `v`: `A♯ (A ⊗ v) ≤ v`. -/
theorem trop_counit_le {n : ℕ} [NeZero n]
    (A : Matrix (Fin n) (Fin n) ℝ) (v : Fin n → ℝ) (k : Fin n) :
    tropResidual A (tropMatVecMul A v) k ≤ v k :=
  (tropicalAnalogy A).counit_le v k

end AnalogyResiduation