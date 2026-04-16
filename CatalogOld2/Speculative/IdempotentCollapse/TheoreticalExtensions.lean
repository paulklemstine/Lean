/-! # CatalogBuild.Speculative.IdempotentCollapse.TheoreticalExtensions

Auto-generated from theorem catalog database.
Domain: Speculative/IdempotentCollapse
Declarations: 27
-/

import Mathlib

noncomputable section

/-- Image of an idempotent equals its fixed-point set. -/
theorem idem_image_eq_fixed (f : α → α) (hf : IsIdempotent' f) :
    range f = FixedPointSet f := by
  ext x; constructor
  · rintro ⟨y, rfl⟩; exact hf y
  · intro hx; exact ⟨x, hx⟩


/-- Every idempotent iterate equals the idempotent (n ≥ 1). -/
theorem idem_iterate (f : α → α) (hf : IsIdempotent' f) (n : ℕ) (hn : 1 ≤ n) :
    f^[n] = f := by
  ext x
  obtain ⟨m, rfl⟩ := Nat.exists_eq_succ_of_ne_zero (by omega : n ≠ 0)
  show f^[m + 1] x = f x
  suffices h : ∀ k, f^[k] (f x) = f x from h m
  intro k; induction k with
  | zero => rfl
  | succ k ih => show f^[k] (f (f x)) = f x; rw [hf]; exact ih


/-- A collapse function is an idempotent endomorphism. -/
structure CollapseFunction (α : Type*) where
  collapse : α → α
  idempotent : ∀ x, collapse (collapse x) = collapse x


/-- The image of a collapse function equals its fixed points. -/
theorem collapse_image_eq_fixed {α : Type*} (C : CollapseFunction α) :
    range C.collapse = {x | C.collapse x = x} := by
  ext x; constructor
  · rintro ⟨y, rfl⟩; exact C.idempotent y
  · intro hx; exact ⟨x, hx⟩


/-- The identity is a (trivial) collapse function. -/
def idCollapse (α : Type*) : CollapseFunction α where
  collapse := id
  idempotent := fun _ => rfl


/-- A constant function is a (total) collapse. -/
def constCollapse {α : Type*} (c : α) : CollapseFunction α where
  collapse := fun _ => c
  idempotent := fun _ => rfl


/-- The critical line projection: P(σ, t) = (1/2, t). -/
def criticalLineProjection : ℝ × ℝ → ℝ × ℝ :=
  fun ⟨_, t⟩ => (1/2, t)


/-- The critical line projection is idempotent. -/
theorem criticalLineProjection_idempotent :
    ∀ p : ℝ × ℝ, criticalLineProjection (criticalLineProjection p) = criticalLineProjection p := by
  intro ⟨_, _⟩; rfl


/-- The fixed points of the critical line projection are exactly the critical line. -/
theorem criticalLine_fixed_points :
    {p : ℝ × ℝ | criticalLineProjection p = p} = {p : ℝ × ℝ | p.1 = 1/2} := by
  ext ⟨σ, t⟩
  simp only [mem_setOf_eq, criticalLineProjection, Prod.mk.injEq]
  constructor
  · rintro ⟨h, -⟩; linarith
  · intro h; exact ⟨by linarith, trivial⟩


/-- **RH Reformulation**: If all non-trivial zeros ρ satisfy P(ρ) = ρ,
then all non-trivial zeros have Re(ρ) = 1/2. -/
theorem RH_via_fixed_points (zeros : Set (ℝ × ℝ))
    (h : ∀ ρ ∈ zeros, criticalLineProjection ρ = ρ) :
    ∀ ρ ∈ zeros, ρ.1 = 1/2 := by
  intro ⟨σ, t⟩ hρ
  have h1 := h ⟨σ, t⟩ hρ
  simp only [criticalLineProjection, Prod.mk.injEq] at h1
  linarith [h1.1]


/-- The reflection operator T(σ, t) = (1-σ, t). -/
def zetaReflection : ℝ × ℝ → ℝ × ℝ := fun ⟨σ, t⟩ => (1 - σ, t)


/-- T is an involution: T ∘ T = id. -/
theorem zetaReflection_involution : ∀ p : ℝ × ℝ, zetaReflection (zetaReflection p) = p := by
  intro ⟨σ, t⟩; simp [zetaReflection]


/-- P = (id + T)/2 in coordinate form. -/
theorem projection_from_reflection (σ t : ℝ) :
    criticalLineProjection (σ, t) =
      ((σ + (zetaReflection (σ, t)).1) / 2, t) := by
  simp only [criticalLineProjection, zetaReflection]; ext <;> simp


/-- A model for the RG flow: a continuous dynamical system on coupling space. -/
structure RGFlow (α : Type*) [TopologicalSpace α] where
  flow : ℝ → α → α
  flow_zero : ∀ x, flow 0 x = x
  semigroup : ∀ s t x, flow (s + t) x = flow s (flow t x)


/-- A fixed point of the RG flow. -/
def RGFixedPoint {α : Type*} [TopologicalSpace α] (F : RGFlow α) (x : α) : Prop :=
  ∀ t, F.flow t x = x


/-- Fixed points are preserved under flow. -/
theorem fixed_preserved {α : Type*} [TopologicalSpace α] (F : RGFlow α)
    (x : α) (hx : RGFixedPoint F x) (t : ℝ) :
    F.flow t x = x := hx t


/-- **Key Theorem**: If the RG flow converges to a limit L, then L is a fixed point.
This is why RG∞ is idempotent: the limit of the flow is its own fixed point. -/
theorem rg_limit_is_fixed {α : Type*} [TopologicalSpace α] [T2Space α]
    (F : RGFlow α) (x : α) (L : α)
    (hconv : Filter.Tendsto (fun t => F.flow t x) Filter.atTop (nhds L))
    (hcont : ∀ s, Continuous (F.flow s)) :
    ∀ s, F.flow s L = L := by
  intro s
  have h_lim : Filter.Tendsto (fun t => F.flow s (F.flow t x)) Filter.atTop (nhds L) := by
    have h_lim : Filter.Tendsto (fun t => F.flow (s + t) x) Filter.atTop (nhds L) :=
      hconv.comp (Filter.tendsto_atTop_add_const_left _ _ Filter.tendsto_id)
    simpa only [F.semigroup] using h_lim
  exact tendsto_nhds_unique
    ((hcont s).continuousAt.tendsto.comp hconv) h_lim


/-- A theory has a mass gap if there's a positive lower bound on excitation energies. -/
structure MassGap (EnergySpectrum : Set ℝ) where
  vacuum : ℝ
  gap : ℝ
  gap_pos : 0 < gap
  vacuum_in : vacuum ∈ EnergySpectrum
  spectral_gap : ∀ E ∈ EnergySpectrum, E = vacuum ∨ vacuum + gap ≤ E


/-- If a mass gap exists, the vacuum is isolated in the spectrum. -/
theorem vacuum_isolated (S : Set ℝ) (mg : MassGap S) :
    ∀ E ∈ S, E ≠ mg.vacuum → mg.vacuum + mg.gap ≤ E := by
  intro E hE hne
  cases mg.spectral_gap E hE with
  | inl h => exact absurd h hne
  | inr h => exact h


/-- A Boolean gate is idempotent if g(x, x) = x. -/
def BoolGateIdempotent (g : Bool → Bool → Bool) : Prop :=
  ∀ x, g x x = x


/-- XOR is NOT idempotent. -/
theorem xor_not_idempotent : ¬ BoolGateIdempotent (· ^^ ·) := by
  intro h; have := h true; simp at this


/-- NOT is NOT idempotent (it's an involution, not idempotent). -/
theorem not_not_idempotent : ¬ (∀ x : Bool, (!(!x)) = (!x)) := by
  push_neg; exact ⟨true, by simp⟩


/-- AND preserves the Boolean ordering. -/
theorem and_bool_monotone (a b c d : Bool) (hac : a ≤ c) (hbd : b ≤ d) :
    (a && b) ≤ (c && d) := by
  cases a <;> cases b <;> cases c <;> cases d <;> simp_all


/-- OR preserves the Boolean ordering. -/
theorem or_bool_monotone (a b c d : Bool) (hac : a ≤ c) (hbd : b ≤ d) :
    (a || b) ≤ (c || d) := by
  cases a <;> cases b <;> cases c <;> cases d <;> simp_all


/-- A surjective idempotent on a finite type must be the identity. -/
theorem idem_surj_is_id {α : Type*} [Fintype α] [DecidableEq α]
    (f : α → α) (hf : IsIdempotent' f) (hsurj : Surjective f) :
    f = id := by
  ext x; obtain ⟨y, rfl⟩ := hsurj x; exact hf y


/-- Commuting collapse functions compose to form a collapse. -/
theorem collapse_compose_comm {α : Type*}
    (C₁ C₂ : CollapseFunction α)
    (hcomm : ∀ x, C₁.collapse (C₂.collapse x) = C₂.collapse (C₁.collapse x)) :
    IsIdempotent' (C₁.collapse ∘ C₂.collapse) := by
  intro x; simp +decide [*, Function.comp]
  rw [C₁.idempotent, C₂.idempotent]


/-- Complete classification of idempotent functions on Bool:
they are exactly id, const true, and const false. -/
theorem bool_idempotent_classification (f : Bool → Bool) (hf : IsIdempotent' f) :
    f = id ∨ f = (fun _ => true) ∨ f = (fun _ => false) := by
  fin_cases f <;> simp +decide [IsIdempotent'] at hf ⊢


end
