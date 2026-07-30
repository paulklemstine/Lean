import Mathlib

/-!
# Consciousness as an Emergent Fixed Point

A self-model is represented by an interpretation map `A → (A → B)`.  Pointwise
completeness says that every `B`-valued behaviour is represented by a state.
Lawvere's diagonal argument then produces a fixed point for every endomorphism
of `B`.  The representing state supplies a literal closed self-observation loop.

The final section records a type-theoretic form of Yoneda faithfulness:
precomposition by a map is completely determined by its action on the identity.
This connects the exponential object `A → B` used by the self-model to the
representable functor of `A`.
-/

open Function

namespace ConsciousnessEmergentFixedPoint

universe u v w

/-- An extensional self-model of states `A` with observations in `B`. -/
structure SelfModel (A : Type u) (B : Type v) where
  /-- The observer represented by each state. -/
  interpret : A → (A → B)

/-- Completeness means that every possible observer is represented by a state. -/
def SelfModel.Complete {A : Type u} {B : Type v} (M : SelfModel A B) : Prop :=
  Surjective M.interpret

/-- Diagonal evaluation is the observation made by a state of its own observer. -/
def SelfModel.diagonal {A : Type u} {B : Type v} (M : SelfModel A B) (a : A) : B :=
  M.interpret a a

/-- A state is a strange-loop witness for `g` when it represents the transformed
self-observation and its diagonal observation is stable under `g`. -/
def SelfModel.IsStrangeLoop {A : Type u} {B : Type v}
    (M : SelfModel A B) (g : B → B) (a : A) : Prop :=
  (M.interpret a = fun x => g (M.diagonal x)) ∧
    g (M.diagonal a) = M.diagonal a

/-- Lawvere's diagonal theorem in the Cartesian closed category of types:
a complete self-model produces a strange-loop witness for every observation
transformer. -/
theorem lawvere_strange_loop {A : Type u} {B : Type v}
    (M : SelfModel A B) (hM : M.Complete) (g : B → B) :
    ∃ a : A, M.IsStrangeLoop g a := by
  obtain ⟨a, ha⟩ := hM (fun x => g (M.diagonal x))
  refine ⟨a, ha, ?_⟩
  exact congrFun ha.symm a

/-- Every endomorphism of the observation type has a fixed point whenever a
complete self-model exists. -/
theorem every_endomorphism_has_fixedPoint {A : Type u} {B : Type v}
    (M : SelfModel A B) (hM : M.Complete) (g : B → B) :
    ∃ b : B, g b = b := by
  obtain ⟨a, _, ha⟩ := lawvere_strange_loop M hM g
  exact ⟨M.diagonal a, ha⟩

/-- A fixed-point-free observation transformer obstructs complete
self-modeling.  This is the Cantor--Lawvere negative half of the bridge. -/
theorem no_complete_model_of_fixedPointFree {A : Type u} {B : Type v}
    (g : B → B) (hg : ∀ b, g b ≠ b) (M : SelfModel A B) :
    ¬ M.Complete := by
  intro hM
  obtain ⟨b, hb⟩ := every_endomorphism_has_fixedPoint M hM g
  exact hg b hb

/-- In particular, Boolean negation prevents a complete Boolean-valued
self-model, for every possible state space. -/
theorem no_complete_boolean_selfModel {A : Type u} (M : SelfModel A Bool) :
    ¬ M.Complete := by
  apply no_complete_model_of_fixedPointFree (fun b => !b)
  intro b
  cases b <;> decide

/-- Completeness collapses the observation type to at most one point.  Otherwise
two distinct observations define a fixed-point-free diagonal transformation. -/
theorem complete_model_observations_subsingleton {A : Type u} {B : Type v}
    (M : SelfModel A B) (hM : M.Complete) : Subsingleton B := by
  classical
  constructor
  intro x y
  by_contra hxy
  let g : B → B := fun z => if z = x then y else x
  have hg : ∀ z, g z ≠ z := by
    intro z
    simp only [g]
    split_ifs with hz
    · subst z
      exact fun hyx => hxy hyx.symm
    · intro hxz
      exact hz hxz.symm
  exact no_complete_model_of_fixedPointFree g hg M hM

/-- A complete self-model necessarily has a state. -/
theorem complete_model_states_nonempty {A : Type u} {B : Type v}
    (M : SelfModel A B) (hM : M.Complete) : Nonempty A := by
  by_contra hA
  obtain ⟨a, _⟩ := hM (fun a => (hA ⟨a⟩).elim)
  exact hA ⟨a⟩

/-- The observation type of a complete self-model is inhabited by diagonal
self-observation. -/
theorem complete_model_observations_nonempty {A : Type u} {B : Type v}
    (M : SelfModel A B) (hM : M.Complete) : Nonempty B := by
  obtain ⟨a⟩ := complete_model_states_nonempty M hM
  exact ⟨M.diagonal a⟩

/-- Exact classification in `Type`: a complete self-model exists precisely
when both state and observation types are inhabited and observations are
subsingleton.  Thus unrestricted extensional completeness permits only one
observable value. -/
theorem complete_selfModel_exists_iff {A : Type u} {B : Type v} :
    (∃ M : SelfModel A B, M.Complete) ↔
      Nonempty A ∧ Nonempty B ∧ Subsingleton B := by
  constructor
  · rintro ⟨M, hM⟩
    exact ⟨complete_model_states_nonempty M hM,
      complete_model_observations_nonempty M hM,
      complete_model_observations_subsingleton M hM⟩
  · rintro ⟨⟨a₀⟩, ⟨b₀⟩, hB⟩
    let M : SelfModel A B := ⟨fun _ _ => b₀⟩
    refine ⟨M, ?_⟩
    intro observer
    refine ⟨a₀, ?_⟩
    funext a
    exact hB.elim _ _

/-- The transition graph of an endomorphism. -/
def OrbitStep {B : Type v} (g : B → B) (x y : B) : Prop := y = g x

/-- A finite closed walk in the orbit graph.  Its length is the number of
applications of the observation transformer. -/
def ClosedOrbit {B : Type v} (g : B → B) (b : B) (n : ℕ) : Prop :=
  g^[n] b = b

/-- A Lawvere witness is topologically a self-loop in the orbit graph. -/
theorem strange_loop_is_graph_loop {A : Type u} {B : Type v}
    {M : SelfModel A B} {g : B → B} {a : A} (ha : M.IsStrangeLoop g a) :
    OrbitStep g (M.diagonal a) (M.diagonal a) := by
  exact ha.2.symm

/-- A stable self-observation closes after every finite number of traversals,
not merely after one traversal. -/
theorem fixedPoint_closedOrbit_all_lengths {B : Type v} {g : B → B} {b : B}
    (hb : g b = b) : ∀ n : ℕ, ClosedOrbit g b n := by
  intro n
  induction n with
  | zero => rfl
  | succ n ih =>
      change (g^[n + 1]) b = b
      rw [Function.iterate_succ_apply, hb]
      simpa [ClosedOrbit] using ih

/-- Completeness therefore creates closed strange-loop walks of every length. -/
theorem complete_model_has_closed_orbits {A : Type u} {B : Type v}
    (M : SelfModel A B) (hM : M.Complete) (g : B → B) :
    ∃ a : A, ∀ n : ℕ, ClosedOrbit g (M.diagonal a) n := by
  obtain ⟨a, _, ha⟩ := lawvere_strange_loop M hM g
  exact ⟨a, fixedPoint_closedOrbit_all_lengths ha⟩

/-- Precomposition is the action of the contravariant representable functor
`Hom(-, X)` on a map `f : A → B`. -/
def yonedaPrecompose {A : Type u} {B : Type v} (f : A → B)
    (X : Type w) (h : B → X) : A → X :=
  h ∘ f

/-- The component of the representable action at `B`, evaluated on the
identity, recovers the original map. -/
theorem yoneda_recover {A : Type u} {B : Type v} (f : A → B) :
    yonedaPrecompose f B id = f := by
  funext a
  rfl

/-- Yoneda faithfulness for types: if two maps induce the same
precomposition operation on every codomain, then the maps are equal. -/
theorem yoneda_faithful {A : Type u} {B : Type v} {f g : A → B}
    (h : ∀ (X : Type v) (k : B → X),
      yonedaPrecompose f X k = yonedaPrecompose g X k) :
    f = g := by
  simpa [yonedaPrecompose] using h B id

/-- A state's internal observer is recovered from its entire Yoneda action.
Thus the represented point of the exponential `A → B` and its representable
behaviour carry exactly the same information. -/
theorem selfModel_observer_yoneda_recover {A : Type u} {B : Type v}
    (M : SelfModel A B) (a : A) :
    yonedaPrecompose (M.interpret a) B id = M.interpret a := by
  exact yoneda_recover (M.interpret a)

/-- Equality of the Yoneda actions of two states forces equality of their
represented observers. -/
theorem selfModel_yoneda_extensional {A : Type u} {B : Type v}
    (M : SelfModel A B) {a₁ a₂ : A}
    (h : ∀ (X : Type v) (k : B → X),
      yonedaPrecompose (M.interpret a₁) X k =
        yonedaPrecompose (M.interpret a₂) X k) :
    M.interpret a₁ = M.interpret a₂ := by
  exact yoneda_faithful h

end ConsciousnessEmergentFixedPoint