/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Aristotle (Harmonic)
-/
import Mathlib

/-!
# Further thoughts on dimensions of posets

This file formalizes the implication arguments and the dimension-behaviour preorder
from George M. Bergman's *Further thoughts on dimensions of posets* (2026).

The longstanding product lower bound and the two stronger adjoined-endpoint bounds
are open.  Accordingly, the results below isolate and prove the paper's unconditional
logical content: the two-step argument implying the conjectured defect-two bound,
and the max-envelope argument classifying disconnected posets by their maximal
component behaviours.

The development is parameterized by a dimension function and product operation.  It
therefore applies directly to order dimension, while making clear that the proofs use
only arithmetic and pointwise comparison of product-dimension profiles.
-/

namespace FurtherThoughtsDimensions

/-! ## The arithmetic core of Proposition 2.2 -/

/-- A dimension theory consists of a class of objects, a product operation, and a
natural-number-valued dimension. -/
structure DimensionTheory (Obj : Type*) where
  dim : Obj → ℕ
  prod : Obj → Obj → Obj

variable {Obj : Type*} (T : DimensionTheory Obj)

/-- The longstanding defect-two product inequality. -/
def DefectTwoProductBound : Prop :=
  ∀ p q, T.dim p + T.dim q ≤ T.dim (T.prod p q) + 2

/-- The exact numerical chain used in Proposition 2.2: bounded endpoint
additivity followed by two one-step endpoint-removal estimates. -/
theorem proposition_2_2_two_step
    {p q boundedP boundedQ middle : Obj}
    (hdimP : T.dim boundedP = T.dim p)
    (hdimQ : T.dim boundedQ = T.dim q)
    (hbounded : T.dim (T.prod boundedP boundedQ) =
      T.dim boundedP + T.dim boundedQ)
    (hfirst : T.dim (T.prod boundedP boundedQ) ≤ T.dim middle + 1)
    (hsecond : T.dim middle ≤ T.dim (T.prod p q) + 1) :
    T.dim p + T.dim q ≤ T.dim (T.prod p q) + 2 := by
  omega

/-- The one-step version used when existing least/greatest elements let one omit
one endpoint-removal step. -/
theorem proposition_2_2_one_step
    {p q boundedP boundedQ : Obj}
    (hdimP : T.dim boundedP = T.dim p)
    (hdimQ : T.dim boundedQ = T.dim q)
    (hbounded : T.dim (T.prod boundedP boundedQ) =
      T.dim boundedP + T.dim boundedQ)
    (hstep : T.dim (T.prod boundedP boundedQ) ≤ T.dim (T.prod p q) + 1) :
    T.dim p + T.dim q ≤ T.dim (T.prod p q) + 1 := by
  omega

/-- A uniform version of Proposition 2.2(i): if every pair admits the bounded
augmentation and the two one-step comparisons in the paper, then the defect-two
product bound follows for every pair. -/
theorem proposition_2_2_uniform
    (boundedP boundedQ : Obj → Obj)
    (middle : Obj → Obj → Obj)
    (hdimP : ∀ p, T.dim (boundedP p) = T.dim p)
    (hdimQ : ∀ q, T.dim (boundedQ q) = T.dim q)
    (hbounded : ∀ p q, T.dim (T.prod (boundedP p) (boundedQ q)) =
      T.dim (boundedP p) + T.dim (boundedQ q))
    (hfirst : ∀ p q, T.dim (T.prod (boundedP p) (boundedQ q)) ≤
      T.dim (middle p q) + 1)
    (hsecond : ∀ p q, T.dim (middle p q) ≤ T.dim (T.prod p q) + 1) :
    DefectTwoProductBound T := by
  intro p q
  exact proposition_2_2_two_step T (hdimP p) (hdimQ q) (hbounded p q)
    (hfirst p q) (hsecond p q)

/-- The paper's weakened observation: two endpoint-removal bounds of cost `n`
each imply a product bound of total defect `2*n`. -/
theorem two_step_with_general_defect
    {p q boundedP boundedQ middle : Obj} {n : ℕ}
    (hdimP : T.dim boundedP = T.dim p)
    (hdimQ : T.dim boundedQ = T.dim q)
    (hbounded : T.dim (T.prod boundedP boundedQ) =
      T.dim boundedP + T.dim boundedQ)
    (hfirst : T.dim (T.prod boundedP boundedQ) ≤ T.dim middle + n)
    (hsecond : T.dim middle ≤ T.dim (T.prod p q) + n) :
    T.dim p + T.dim q ≤ T.dim (T.prod p q) + 2 * n := by
  omega

/-! ## Product-dimension behaviour -/

variable {Query : Type*}

/-- The product-dimension profile of an object: its value at `q` is the dimension
of its product with `q`. -/
abbrev Profile (Obj Query : Type*) := Obj → Query → ℕ

/-- Bergman's relation `P ≼ P'`: every product-dimension value of `P` is at most
the corresponding value of `P'`. -/
def BehaviorLE (profile : Profile Obj Query) (p p' : Obj) : Prop :=
  ∀ q, profile p q ≤ profile p' q

/-- Bergman's relation `P ≈ P'`: equality of all product-dimension values. -/
def BehaviorEquiv (profile : Profile Obj Query) (p p' : Obj) : Prop :=
  BehaviorLE profile p p' ∧ BehaviorLE profile p' p

@[refl] theorem behaviorLE_refl (profile : Profile Obj Query) (p : Obj) :
    BehaviorLE profile p p := by
  intro q
  exact le_rfl

@[trans] theorem behaviorLE_trans (profile : Profile Obj Query) {p p' p'' : Obj}
    (hpp' : BehaviorLE profile p p') (hp'p'' : BehaviorLE profile p' p'') :
    BehaviorLE profile p p'' := by
  intro q
  exact le_trans (hpp' q) (hp'p'' q)

@[refl] theorem behaviorEquiv_refl (profile : Profile Obj Query) (p : Obj) :
    BehaviorEquiv profile p p := by
  exact ⟨behaviorLE_refl profile p, behaviorLE_refl profile p⟩

@[symm] theorem behaviorEquiv_symm (profile : Profile Obj Query) {p p' : Obj}
    (h : BehaviorEquiv profile p p') : BehaviorEquiv profile p' p := by
  exact h.symm

@[trans] theorem behaviorEquiv_trans (profile : Profile Obj Query) {p p' p'' : Obj}
    (hpp' : BehaviorEquiv profile p p') (hp'p'' : BehaviorEquiv profile p' p'') :
    BehaviorEquiv profile p p'' := by
  exact ⟨behaviorLE_trans profile hpp'.1 hp'p''.1,
    behaviorLE_trans profile hp'p''.2 hpp'.2⟩

/-- Behaviour equivalence is exactly pointwise equality of product-dimension
profiles. -/
theorem behaviorEquiv_iff (profile : Profile Obj Query) (p p' : Obj) :
    BehaviorEquiv profile p p' ↔ ∀ q, profile p q = profile p' q := by
  constructor
  · intro h q
    exact Nat.le_antisymm (h.1 q) (h.2 q)
  · intro h
    exact ⟨fun q => (h q).le, fun q => (h q).ge⟩

/-- The dimension profile of a disconnected union is represented in Lemma 4.2
by the maximum of `2` and all component profiles. -/
def componentEnvelope (profile : Profile Obj Query) (components : Finset Obj)
    (q : Query) : ℕ :=
  max 2 (components.sup fun p => profile p q)

/-- A component is `≼`-maximal in a finite family when every component above it
has the same product-dimension behaviour. -/
def BehaviorMaximal (profile : Profile Obj Query) (components : Finset Obj)
    (p : Obj) : Prop :=
  p ∈ components ∧ ∀ ⦃p'⦄, p' ∈ components →
    BehaviorLE profile p p' → BehaviorLE profile p' p

/-- Every member of a finite component family lies below a `≼`-maximal member.
This is the finite-preorder fact used implicitly in Proposition 4.3. -/
theorem exists_behaviorMaximal_above [DecidableEq Obj]
    (profile : Profile Obj Query) {components : Finset Obj} {p : Obj}
    (hp : p ∈ components) :
    ∃ p', BehaviorLE profile p p' ∧ BehaviorMaximal profile components p' := by
  letI : LE Obj := ⟨BehaviorLE profile⟩
  letI : Preorder Obj := {
    le_refl := fun p => behaviorLE_refl profile p
    le_trans := fun _ _ _ h₁ h₂ => behaviorLE_trans profile h₁ h₂ }
  obtain ⟨p', hpp', hp'max⟩ := components.exists_le_maximal hp
  exact ⟨p', hpp', hp'max⟩

/-- Pointwise domination of every component by some component in another family
implies domination of their max-envelopes.  This is the order-theoretic core of
Corollary 4.4. -/
theorem componentEnvelope_mono (profile : Profile Obj Query)
    {left right : Finset Obj}
    (hdom : ∀ p ∈ left, ∃ p' ∈ right, BehaviorLE profile p p') :
    ∀ q, componentEnvelope profile left q ≤ componentEnvelope profile right q := by
  intro q
  apply max_le_max_left 2
  apply Finset.sup_le
  intro p hp
  obtain ⟨p', hp', hpp'⟩ := hdom p hp
  exact (hpp' q).trans (Finset.le_sup (f := fun x => profile x q) hp')

/-- It suffices in the domination criterion to check only `≼`-maximal source
components, as asserted in Corollary 4.4. -/
theorem componentEnvelope_mono_of_maximal [DecidableEq Obj]
    (profile : Profile Obj Query) {left right : Finset Obj}
    (hdom : ∀ p, BehaviorMaximal profile left p →
      ∃ p' ∈ right, BehaviorLE profile p p') :
    ∀ q, componentEnvelope profile left q ≤ componentEnvelope profile right q := by
  apply componentEnvelope_mono profile
  intro p hp
  obtain ⟨m, hpm, hm⟩ := exists_behaviorMaximal_above profile hp
  obtain ⟨p', hp', hmp'⟩ := hdom m hm
  exact ⟨p', hp', behaviorLE_trans profile hpm hmp'⟩

/-- Mutual cofinality under `≼` makes the two disconnected max-envelopes equal.
Together with Lemma 4.2's formula for dimensions of disconnected unions, this is
Proposition 4.3. -/
theorem componentEnvelope_eq_of_mutual_domination (profile : Profile Obj Query)
    {left right : Finset Obj}
    (hlr : ∀ p ∈ left, ∃ p' ∈ right, BehaviorLE profile p p')
    (hrl : ∀ p' ∈ right, ∃ p ∈ left, BehaviorLE profile p' p) :
    ∀ q, componentEnvelope profile left q = componentEnvelope profile right q := by
  intro q
  exact Nat.le_antisymm (componentEnvelope_mono profile hlr q)
    (componentEnvelope_mono profile hrl q)

/-- The maximal-component criterion of Proposition 4.3: if every maximal
component in either family is behaviour-equivalent to a maximal component in the
other, their disconnected dimension envelopes agree. -/
theorem proposition_4_3 [DecidableEq Obj] (profile : Profile Obj Query)
    {left right : Finset Obj}
    (hlr : ∀ p, BehaviorMaximal profile left p →
      ∃ p', BehaviorMaximal profile right p' ∧ BehaviorEquiv profile p p')
    (hrl : ∀ p', BehaviorMaximal profile right p' →
      ∃ p, BehaviorMaximal profile left p ∧ BehaviorEquiv profile p p') :
    ∀ q, componentEnvelope profile left q = componentEnvelope profile right q := by
  intro q
  apply Nat.le_antisymm
  · apply componentEnvelope_mono_of_maximal profile
    intro p hp
    obtain ⟨p', hp'max, h⟩ := hlr p hp
    exact ⟨p', hp'max.1, h.1⟩
  · apply componentEnvelope_mono_of_maximal profile
    intro p' hp'
    obtain ⟨p, hpmax, h⟩ := hrl p' hp'
    exact ⟨p, hpmax.1, h.2⟩

/-- Replacing every component by a behaviour-equivalent component does not change
the max-envelope. -/
theorem componentEnvelope_eq_of_matched_equiv (profile : Profile Obj Query)
    {left right : Finset Obj}
    (hlr : ∀ p ∈ left, ∃ p' ∈ right, BehaviorEquiv profile p p')
    (hrl : ∀ p' ∈ right, ∃ p ∈ left, BehaviorEquiv profile p p') :
    ∀ q, componentEnvelope profile left q = componentEnvelope profile right q := by
  apply componentEnvelope_eq_of_mutual_domination profile
  · intro p hp
    obtain ⟨p', hp', h⟩ := hlr p hp
    exact ⟨p', hp', h.1⟩
  · intro p' hp'
    obtain ⟨p, hp, h⟩ := hrl p' hp'
    exact ⟨p, hp, h.2⟩

/-- Adding components already dominated by existing components leaves a
max-envelope unchanged.  This formalizes the paper's observation that one may
adjoin arbitrarily many copies of subordinate components without changing the
`≈`-class of a disconnected poset of dimension at least two. -/
theorem componentEnvelope_union_of_dominated [DecidableEq Obj]
    (profile : Profile Obj Query) {base extra : Finset Obj}
    (hdom : ∀ p ∈ extra, ∃ p' ∈ base, BehaviorLE profile p p') :
    ∀ q, componentEnvelope profile (base ∪ extra) q = componentEnvelope profile base q := by
  apply componentEnvelope_eq_of_mutual_domination profile
  · intro p hp
    rcases Finset.mem_union.mp hp with hp | hp
    · exact ⟨p, hp, behaviorLE_refl profile p⟩
    · exact hdom p hp
  · intro p hp
    exact ⟨p, Finset.mem_union_left extra hp, behaviorLE_refl profile p⟩

end FurtherThoughtsDimensions