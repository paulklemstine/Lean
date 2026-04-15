/-! # CatalogBuild.Speculative.Consciousness.SelfReferentialTheories

Auto-generated from theorem catalog database.
Domain: Speculative/Consciousness
Declarations: 16
-/

import Mathlib

noncomputable section

structure QuineSystem where
  Element : Type*
  represent : Element → Element
  execute : Element → Element
  quine_condition : ∀ e, represent e = e → execute e = e


def QuineSystem.isQuine (Q : QuineSystem) (e : Q.Element) : Prop :=
  Q.represent e = e


theorem quine_fixed_point {A : Type*} (Y : (A → A) → A)
    (hY : ∀ f : A → A, f (Y f) = Y f) (f : A → A) :
    ∃ q : A, f q = q := ⟨Y f, hY f⟩

/-! ## §2: Self-Justifying Axiom Systems -/


structure SelfJustifyingSystem where
  Axiom_ : Type*
  Theorem_ : Type*
  axioms : Set Axiom_
  derives : Set Axiom_ → Theorem_ → Prop
  justify : Theorem_ → Axiom_
  self_justification : ∀ a ∈ axioms,
    ∃ t : Theorem_, derives axioms t ∧ justify t = a


def SelfJustifyingSystem.isMinimal (S : SelfJustifyingSystem) : Prop :=
  ∀ a ∈ S.axioms, ¬ ∀ a' ∈ S.axioms \ {a},
    ∃ t, S.derives (S.axioms \ {a}) t ∧ S.justify t = a'

/-! ## §3: Autopoietic Systems -/


def AutopoieticSystem.operationallyClosed (A : AutopoieticSystem)
    (boundary : Set A.Component) : Prop :=
  ∀ c ∈ boundary, A.produces c ⊆ boundary


theorem autopoietic_fixed_point (A : AutopoieticSystem) (S : Set A.Component)
    (hclosed : ∀ c ∈ S, A.produces c ⊆ S) :
    ⋃ c ∈ S, A.produces c ⊆ S := by
  intro x hx; simp at hx; obtain ⟨c, hcS, hxp⟩ := hx; exact hclosed c hcS hxp

/-! ## §4: The Bootstrap Paradox -/


structure BootstrapLoop where
  State : Type*
  timeline : ℤ → State
  evolve : State → State
  consistency : ∀ t, timeline (t + 1) = evolve (timeline t)
  loop_period : ℕ
  loop_pos : 0 < loop_period
  is_loop : ∀ t, timeline (t + ↑loop_period) = timeline t


theorem bootstrap_periodic (B : BootstrapLoop) (t : ℤ) (k : ℕ) :
    B.timeline (t + ↑k * ↑B.loop_period) = B.timeline t := by
  induction k with
  | zero => simp
  | succ n ih =>
    have : (↑(n + 1) : ℤ) * ↑B.loop_period = ↑n * ↑B.loop_period + ↑B.loop_period := by
      push_cast; ring
    rw [this, ← add_assoc, B.is_loop, ih]

/-! ## §5: Self-Referential Consciousness -/


structure SelfReferentialConsciousness where
  State : Type*
  reflect : State → State
  justify : State → Prop
  produce : State → Set State
  fixed_point : ∃ s, reflect s = s
  self_justified : ∀ s, reflect s = s → justify s
  self_producing : ∀ s, reflect s = s → s ∈ ⋃ s', produce s'


def SelfReferentialConsciousness.consciousStates (S : SelfReferentialConsciousness) :
    Set S.State :=
  { s | S.reflect s = s }


theorem conscious_states_justified (S : SelfReferentialConsciousness) :
    ∀ s ∈ S.consciousStates, S.justify s :=
  fun s hs => S.self_justified s hs

/-! ## §6: The Liar's Staircase -/


def liarsStaircase : ℕ → Bool
  | 0 => true
  | n + 1 => !(liarsStaircase n)


theorem liars_staircase_alternates (n : ℕ) :
    liarsStaircase (n + 1) = !(liarsStaircase n) := rfl


theorem liars_staircase_even (n : ℕ) :
    liarsStaircase (2 * n) = true := by
  induction n with
  | zero => rfl
  | succ k ih =>
    show liarsStaircase (2 * k + 1 + 1) = true
    simp [liarsStaircase]
    exact ih


theorem liars_staircase_odd (n : ℕ) :
    liarsStaircase (2 * n + 1) = false := by
  simp [liarsStaircase, liars_staircase_even]


end
