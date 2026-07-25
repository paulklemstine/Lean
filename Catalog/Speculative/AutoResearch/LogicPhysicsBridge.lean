/-
# Logic-Physics Bridge: Physical Realizability ↔ Logical Consistency

This file establishes the formal foundations for the *logic-physics bridge*: the
precise correspondence between **physical realizability** (a theory of laws admits
at least one concrete state realizing them — i.e. it "has a model") and **logical
consistency** (the theory does not semantically entail a contradiction).

The central thesis, going back to the Hilbert/Gödel-era slogan *"consistency is
existence"*, is here made into a clean, fully formal, domain-agnostic theorem:

    `Realizable T ↔ Consistent T`.

We then derive the structural corollaries that turn this equivalence into a usable
calculus: the principle of explosion (an unrealizable world models every law),
monotonicity of realizability under weakening a theory, compositionality of
realizability across independent subsystems, and a concrete *no-go theorem* showing
that any theory containing a law and its negation cannot be physically realized.

Finally we instantiate the abstract bridge on a concrete physics example
(an energy-conservation law on a real state space) to demonstrate that the
framework is non-vacuous.

## Cross-Domain Connections (Catalog Synthesis)

* **Logic** (`Catalog/Logic/Completeness.lean`, `Catalog/Logic/Basic.lean`):
  the bridge is the semantic skeleton underlying soundness/completeness — here we
  isolate the *model-existence ↔ consistency* half in a form independent of any
  particular proof system.
* **Physics** (`Catalog/Physics/Bridge.lean`): that file bridges thermodynamic cost
  to circuit free energy; here we provide the *meta*-bridge explaining why any such
  physical model existing at all is equivalent to the logical consistency of its laws.
* **Bridges** (`Catalog/Bridges/Foundations.lean`, `Catalog/Bridges/Core.lean`):
  this module is a new cross-domain bridge in the same family, connecting
  model theory to dynamical realizability.

-- !-- Lab Notebook -- !--
Hypothesis:
  The informal physicists' slogan "a set of laws is realizable iff it is consistent"
  can be made a single, classical, domain-agnostic biconditional, from which the
  usual structural meta-theorems (explosion, monotonicity, compositionality, no-go)
  follow as one-line corollaries.
Result:
  Proved `realizable_iff_consistent` and five structural corollaries with `sorry = 0`,
  plus a concrete non-vacuous physics instantiation (`conservation_realizable`).
Insight:
  Once `Consistent` is *defined* as `¬ Entails T ⊥`, the bridge is exactly the
  classical equivalence `(¬ ∀ s, ¬ P s) ↔ (∃ s, P s)`. The mathematical content is
  entirely in choosing the right primitive notions; the corollaries are then forced.
  This pinpoints classical logic (`not_forall` / `not_not`) as the *only* nonconstructive
  ingredient in the logic-physics correspondence.
Failure analysis:
  An earlier formulation tried to define `Consistent` syntactically via a derivation
  relation; that needlessly drags in a proof calculus and breaks domain-agnosticism.
  Defining consistency *semantically* (no entailment of ⊥) keeps the bridge clean and
  makes completeness a definitional unfolding rather than a theorem to re-prove.
-- !-- Lab Notebook -- !--
-/

import Mathlib

namespace LogicPhysicsBridge

universe u

/-- A `Theory` over a state space `S` is a set of *laws*: predicates that a physical
state may or may not satisfy. -/
abbrev Theory (S : Type u) : Type u := Set (S → Prop)

/-- A state `s` is a **model** of a theory `T` when it satisfies every law in `T`. -/
def IsModel {S : Type u} (T : Theory S) (s : S) : Prop := ∀ p ∈ T, p s

/-- **Physical realizability.** A theory is realizable when some concrete state
realizes (models) all of its laws simultaneously. -/
def Realizable {S : Type u} (T : Theory S) : Prop := ∃ s, IsModel T s

/-- **Semantic entailment.** `T` entails `φ` when every model of `T` satisfies `φ`. -/
def Entails {S : Type u} (T : Theory S) (φ : S → Prop) : Prop :=
  ∀ s, IsModel T s → φ s

/-- **Logical consistency.** A theory is consistent when it does not entail the
absurd law `⊥` (the predicate that is false at every state). -/
def Consistent {S : Type u} (T : Theory S) : Prop :=
  ¬ Entails T (fun _ => False)

/-! ## The central bridge -/

-- !-- comment -- !--
-- `Realizable T ↔ Consistent T`: unfold both sides to the classical equivalence
-- `(∃ s, IsModel T s) ↔ ¬ (∀ s, IsModel T s → False)`, discharged by `push_neg`.
-- !-- comment -- !--
/-- **The logic-physics bridge.** A theory of physical laws is *realizable* (has a
model) **iff** it is *consistent* (does not entail a contradiction). This is the
formal content of the slogan "consistency is existence". -/
theorem realizable_iff_consistent {S : Type u} (T : Theory S) :
    Realizable T ↔ Consistent T := by
  unfold Realizable Consistent Entails
  constructor
  · rintro ⟨s, hs⟩ h
    exact h s hs
  · intro h
    by_contra hcon
    push_neg at hcon
    exact h (fun s hs => (hcon s hs).elim)

/-! ## Structural corollaries -/

-- !-- comment -- !--
-- Explosion: an unrealizable theory has no models, so `Entails T φ` holds vacuously.
-- !-- comment -- !--
/-- **Principle of explosion (ex falso for worlds).** A theory with no physical
realization entails *every* law: an impossible world models anything. -/
theorem not_realizable_entails_all {S : Type u} {T : Theory S}
    (h : ¬ Realizable T) (φ : S → Prop) : Entails T φ := by
  intro s hs
  exact absurd ⟨s, hs⟩ h

-- !-- comment -- !--
-- Equivalent restatement of the bridge: entailing ⊥ is exactly non-realizability.
-- !-- comment -- !--
/-- A theory entails the absurd law **iff** it is not physically realizable. -/
theorem entails_false_iff_not_realizable {S : Type u} (T : Theory S) :
    Entails T (fun _ => False) ↔ ¬ Realizable T := by
  rw [realizable_iff_consistent]
  unfold Consistent
  exact (not_not).symm

-- !-- comment -- !--
-- Monotonicity: any model of the larger theory `T'` already models the smaller `T`.
-- !-- comment -- !--
/-- **Monotonicity of realizability.** Weakening a theory (removing laws) can only
make it easier to realize: if `T ⊆ T'` and `T'` is realizable, so is `T`. -/
theorem realizable_of_subset {S : Type u} {T T' : Theory S}
    (hsub : T ⊆ T') (h : Realizable T') : Realizable T := by
  obtain ⟨s, hs⟩ := h
  exact ⟨s, fun p hp => hs p (hsub hp)⟩

-- !-- comment -- !--
-- No-go: a state can't satisfy both `p` and `¬p`, so no model exists.
-- !-- comment -- !--
/-- **No-go theorem.** A theory containing both a law `p` and its negation cannot be
physically realized; equivalently, it is inconsistent. -/
theorem contradiction_not_realizable {S : Type u} (T : Theory S) (p : S → Prop)
    (hp : p ∈ T) (hnp : (fun s => ¬ p s) ∈ T) : ¬ Realizable T := by
  rintro ⟨s, hs⟩
  exact hs (fun s => ¬ p s) hnp (hs p hp)

/-! ## Compositionality across independent subsystems -/

/-- The **product theory** on `S × S'`: a law of either subsystem, lifted to act on
its own coordinate of the joint state. -/
def product {S S' : Type u} (T : Theory S) (T' : Theory S') : Theory (S × S') :=
  {q | (∃ p ∈ T, q = fun x => p x.1) ∨ (∃ p' ∈ T', q = fun x => p' x.2)}

-- !-- comment -- !--
-- Compositionality: a joint state models the product iff each component models its
-- factor; assemble/destructure a pair of models, matching laws by their coordinate.
-- !-- comment -- !--
/-- **Compositionality of realizability.** Two independent subsystems can be jointly
realized **iff** each can be realized on its own. Physically: independent worlds
coexist exactly when each is individually possible. -/
theorem product_realizable_iff {S S' : Type u} (T : Theory S) (T' : Theory S') :
    Realizable (product T T') ↔ Realizable T ∧ Realizable T' := by
  constructor
  · rintro ⟨⟨s, s'⟩, hmod⟩
    refine ⟨⟨s, ?_⟩, ⟨s', ?_⟩⟩
    · intro p hp
      exact hmod (fun x => p x.1) (Or.inl ⟨p, hp, rfl⟩)
    · intro p' hp'
      exact hmod (fun x => p' x.2) (Or.inr ⟨p', hp', rfl⟩)
  · rintro ⟨⟨s, hs⟩, ⟨s', hs'⟩⟩
    refine ⟨(s, s'), ?_⟩
    rintro q (⟨p, hp, rfl⟩ | ⟨p', hp', rfl⟩)
    · exact hs p hp
    · exact hs' p' hp'

/-! ## A concrete physics instantiation (non-vacuity) -/

/-- A toy physical state: a pair `(E, t)` of an energy and a time. -/
abbrev PhysState : Type := ℝ × ℝ

/-- **Energy conservation** as a single law on the trajectory parameter: here we model
a *stationary* observation, requiring the energy to equal a fixed level `E₀`. -/
def conservationLaw (E₀ : ℝ) : Theory PhysState :=
  {fun s => s.1 = E₀}

-- !-- comment -- !--
-- Non-vacuity: the state `(E₀, 0)` literally satisfies the energy-conservation law,
-- so the conservation theory has a model — its realizability is witnessed concretely.
-- !-- comment -- !--
/-- **The conservation theory is realizable**, hence (by the bridge) consistent:
the physics framework instantiates the abstract bridge non-vacuously. -/
theorem conservation_realizable (E₀ : ℝ) : Realizable (conservationLaw E₀) := by
  refine ⟨(E₀, 0), ?_⟩
  intro p hp
  simp only [conservationLaw, Set.mem_singleton_iff] at hp
  subst hp
  rfl

/-- Consequently, the conservation theory is **consistent** — derived purely from the
bridge, with no separate logical argument. -/
theorem conservation_consistent (E₀ : ℝ) : Consistent (conservationLaw E₀) :=
  (realizable_iff_consistent _).mp (conservation_realizable E₀)

/-- **A genuine physical no-go.** Two distinct fixed energy levels cannot both hold:
demanding energy `= E₀` and energy `= E₁` with `E₀ ≠ E₁` is not realizable. -/
theorem two_levels_not_realizable {E₀ E₁ : ℝ} (h : E₀ ≠ E₁) :
    ¬ Realizable (conservationLaw E₀ ∪ conservationLaw E₁) := by
  rintro ⟨s, hs⟩
  have h0 : s.1 = E₀ := hs _ (Or.inl rfl)
  have h1 : s.1 = E₁ := hs _ (Or.inr rfl)
  exact h (h0 ▸ h1)

end LogicPhysicsBridge