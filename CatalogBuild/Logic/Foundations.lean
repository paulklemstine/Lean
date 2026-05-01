/-! # CatalogBuild.Logic.Foundations

Auto-generated from theorem catalog database.
Domain: Logic
Declarations: 16
-/

import Mathlib

noncomputable section

/-- A temporal flow is a monoid action of T on S: a map Φ: T → (S → S) satisfying
Φ(0) = id and Φ(s + t) = Φ(s) ∘ Φ(t).
This captures the algebraic essence of time evolution. -/
structure TemporalFlow (T : Type*) (S : Type*) [AddMonoid T] where
  /-- The flow map: each time duration t gives an endomorphism of S -/
  flow : T → S → S
  /-- The present does nothing: Φ(0) = id -/
  flow_zero : ∀ s : S, flow 0 s = s
  /-- Time composition: Φ(a + b) = Φ(a) ∘ Φ(b) -/
  flow_add : ∀ (a b : T) (s : S), flow (a + b) s = flow a (flow b s)


/-- An entropy functional on a temporal flow is a real-valued function
that never decreases along the flow. This is the algebraic second law. -/
structure EntropyFunctional {T S : Type*} [AddMonoid T] (Φ : TemporalFlow T S) where
  /-- The entropy function η: S → ℝ -/
  entropy : S → ℝ
  /-- Second law: entropy never decreases along the flow -/
  monotone : ∀ (t : T) (s : S), entropy s ≤ entropy (Φ.flow t s)


/-- [Section: # CatalogBuild.Physics.AlgebraicPhysics.Foundations
Auto-generated from theorem catalog database.
Domain: Physics/AlgebraicPhysics
Declarations: 16] -/
theorem arrow_of_time
    {S : Type*}
    (flow_t : S → S)        -- Φ(t): forward evolution
    (backward : S → S)      -- Hypothetical Φ(-t): backward evolution
    (entropy : S → ℝ)       -- η: entropy functional
    (s : S)                  -- a non-equilibrium state
    (h_strict : entropy s < entropy (flow_t s))
    (h_inverse : backward (flow_t s) = s)
    (h_backward_monotone : entropy (flow_t s) ≤ entropy (backward (flow_t s))) :
    False := by
  rw [h_inverse] at h_backward_monotone; linarith


/-- Negation in an ordered additive commutative group reverses the order. -/
theorem temporal_duality_order_reversal
    {G : Type*} [AddCommGroup G] [PartialOrder G] [IsOrderedAddMonoid G]
    (a b : G) (h : a ≤ b) : -b ≤ -a :=
  neg_le_neg_iff.mpr h


/-- Time reversal is an involution: --t = t -/
theorem temporal_duality_involution
    {G : Type*} [AddGroup G] (t : G) : -(-t) = t :=
  neg_neg t


/-- The flow at time 0 is the identity. -/
theorem flow_identity {T S : Type*} [AddMonoid T] (Φ : TemporalFlow T S) (s : S) :
    Φ.flow 0 s = s :=
  Φ.flow_zero s


/-- The semigroup law: composing two time steps equals one combined step. -/
theorem flow_composition {T S : Type*} [AddMonoid T]
    (Φ : TemporalFlow T S) (a b : T) (s : S) :
    Φ.flow a (Φ.flow b s) = Φ.flow (a + b) s :=
  Φ.flow_add a b s ▸ rfl


/-- Triple composition: Φ(a) ∘ Φ(b) ∘ Φ(c) = Φ(a + b + c) -/
theorem flow_triple_composition {T S : Type*} [AddMonoid T]
    (Φ : TemporalFlow T S) (a b c : T) (s : S) :
    Φ.flow a (Φ.flow b (Φ.flow c s)) = Φ.flow (a + b + c) s := by
  rw [← Φ.flow_add, ← Φ.flow_add]


/-- A reversible temporal flow is one where each Φ(t) is bijective,
with Φ(-t) as the inverse. -/
structure ReversibleFlow (G : Type*) (S : Type*) [AddGroup G]
    extends TemporalFlow G S where
  /-- Φ(-t) is the left inverse of Φ(t) -/
  flow_neg_left : ∀ (t : G) (s : S), flow (-t) (flow t s) = s
  /-- Φ(-t) is the right inverse of Φ(t) -/
  flow_neg_right : ∀ (t : G) (s : S), flow t (flow (-t) s) = s


/-- In a reversible flow, Φ(t) is injective. -/
theorem reversible_flow_injective {G S : Type*} [AddGroup G]
    (Φ : ReversibleFlow G S) (t : G) :
    Function.Injective (Φ.flow t) := by
  intro x y hxy
  have hx := Φ.flow_neg_left t x
  have hy := Φ.flow_neg_left t y
  rw [hxy] at hx
  rw [← hx, hy]


/-- In a reversible flow, Φ(t) is surjective. -/
theorem reversible_flow_surjective {G S : Type*} [AddGroup G]
    (Φ : ReversibleFlow G S) (t : G) :
    Function.Surjective (Φ.flow t) := by
  intro y
  exact ⟨Φ.flow (-t) y, Φ.flow_neg_right t y⟩


/-- An equilibrium state is a fixed point of all flow maps. -/
def IsEquilibrium {T S : Type*} [AddMonoid T] (Φ : TemporalFlow T S) (s : S) : Prop :=
  ∀ t : T, Φ.flow t s = s


/-- At equilibrium, entropy is constant. -/
theorem entropy_constant_at_equilibrium
    {T S : Type*} [AddMonoid T]
    (Φ : TemporalFlow T S) (η : EntropyFunctional Φ) (s : S)
    (h_eq : IsEquilibrium Φ s) (t : T) :
    η.entropy (Φ.flow t s) = η.entropy s := by
  rw [h_eq t]


/-- Entropy at a later time is at least as large as at an earlier time. -/
theorem entropy_monotone_trajectory
    {T S : Type*} [AddMonoid T]
    (Φ : TemporalFlow T S) (η : EntropyFunctional Φ) (a b : T) (s : S) :
    η.entropy (Φ.flow a s) ≤ η.entropy (Φ.flow (b + a) s) := by
  rw [Φ.flow_add]
  exact η.monotone _ _


/-- [Section: # CatalogBuild.Physics.AlgebraicPhysics.Foundations
Auto-generated from theorem catalog database.
Domain: Physics/AlgebraicPhysics
Declarations: 16] -/
theorem group_monoid_dichotomy
    {G S : Type*} [AddGroup G]
    (Φ : ReversibleFlow G S)
    (η : EntropyFunctional Φ.toTemporalFlow)
    (s : S) (t : G)
    (h_strict : η.entropy s < η.entropy (Φ.flow t s)) :
    False := by
  have h := η.monotone (-t) (Φ.flow t s)
  rw [Φ.flow_neg_left] at h
  linarith


/-- A linear temporal flow on ℝ → ℝ given by multiplication by e^{at}. -/
noncomputable def linearFlow (a : ℝ) : TemporalFlow ℝ ℝ where
  flow := fun t x => Real.exp (a * t) * x
  flow_zero := by
    intro s
    simp [mul_comm]
  flow_add := by
    intro t₁ t₂ s
    simp [mul_add, Real.exp_add, mul_comm, mul_left_comm]


end
