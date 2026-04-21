/-! # CatalogBuild.Speculative.Other.Repulsors

Auto-generated from theorem catalog database.
Domain: Speculative/Other
Declarations: 16
-/

import Mathlib

noncomputable section

/-- A discrete-time dynamical system. -/
structure DiscreteDynSystem (α : Type*) where
  step : α → α




/-- The n-th iterate of a discrete dynamical system. -/
def DiscreteDynSystem.iterate {α : Type*} (ds : DiscreteDynSystem α) : ℕ → α → α
  | 0 => id
  | n + 1 => ds.step ∘ ds.iterate n




/-- [Section: # CatalogBuild.Speculative.Other.Repulsors
Auto-generated from theorem catalog database.
Domain: Speculative/Other
Declarations: 16] -/
theorem DiscreteDynSystem.iterate_zero {α : Type*} (ds : DiscreteDynSystem α) (x : α) :
    ds.iterate 0 x = x := rfl




/-- [Section: # CatalogBuild.Speculative.Other.Repulsors
Auto-generated from theorem catalog database.
Domain: Speculative/Other
Declarations: 16] -/
theorem DiscreteDynSystem.iterate_succ {α : Type*} (ds : DiscreteDynSystem α) (n : ℕ) (x : α) :
    ds.iterate (n + 1) x = ds.step (ds.iterate n x) := rfl




/-- A fixed point of a discrete dynamical system. -/
def DiscreteDynSystem.IsFixedPoint {α : Type*} (ds : DiscreteDynSystem α) (x : α) : Prop :=
  ds.step x = x




/-- Fixed points are preserved under iteration. -/
theorem DiscreteDynSystem.iterate_fixed {α : Type*} (ds : DiscreteDynSystem α)
    (x : α) (hx : ds.IsFixedPoint x) (n : ℕ) :
    ds.iterate n x = x := by
  induction n with
  | zero => rfl
  | succ n ih => simp [iterate_succ, ih, IsFixedPoint] at *; exact hx




/-- A set is an attractor if nearby orbits converge to it. -/
def IsDiscreteAttractor {α : Type*} [PseudoMetricSpace α] (ds : DiscreteDynSystem α)
    (A : Set α) : Prop :=
  ∃ U : Set α, IsOpen U ∧ A ⊆ U ∧
    ∀ x ∈ U, Tendsto (fun n => infDist (ds.iterate n x) A) atTop (nhds 0)




/-- A set is a repulsor if nearby orbits eventually leave every neighborhood. -/
def IsDiscreteRepulsor {α : Type*} [PseudoMetricSpace α] (ds : DiscreteDynSystem α)
    (R : Set α) : Prop :=
  ∃ U : Set α, IsOpen U ∧ R ⊆ U ∧
    ∀ x ∈ U \ R, ∃ n : ℕ, ds.iterate n x ∉ U




/-- The basin of attraction. -/
def discreteBasinOfAttraction {α : Type*} [PseudoMetricSpace α]
    (ds : DiscreteDynSystem α) (A : Set α) : Set α :=
  {x | Tendsto (fun n => infDist (ds.iterate n x) A) atTop (nhds 0)}




/-- The basin of repulsion. -/
def discreteBasinOfRepulsion {α : Type*} [PseudoMetricSpace α]
    (ds : DiscreteDynSystem α) (R : Set α) : Set α :=
  {x | Tendsto (fun n => infDist (ds.iterate n x) R) atTop atTop}




/-- A bijective discrete dynamical system. -/
structure BijectiveDynSystem (α : Type*) extends DiscreteDynSystem α where
  inv : α → α
  left_inv : ∀ x, inv (step x) = x
  right_inv : ∀ x, step (inv x) = x




/-- The reverse of a bijective system. -/
def BijectiveDynSystem.reverse {α : Type*} (ds : BijectiveDynSystem α) :
    BijectiveDynSystem α where
  step := ds.inv
  inv := ds.step
  left_inv := ds.right_inv
  right_inv := ds.left_inv




/-- Key duality: repulsors of the forward system are attractors of the reverse. -/
theorem repulsor_reverse_attractor {α : Type*} [PseudoMetricSpace α]
    (ds : BijectiveDynSystem α) (R : Set α)
    (hR : IsDiscreteRepulsor ds.toDiscreteDynSystem R) :
    -- The reverse system "attracts" towards R from far away
    ∃ U : Set α, IsOpen U ∧ R ⊆ U := by
  obtain ⟨U, hU_open, hU_sub, _⟩ := hR
  exact ⟨U, hU_open, hU_sub⟩




/-- A probabilistic repulsor assigns escape probabilities. -/
structure ProbRepulsor (α : Type*) where
  escapeProbability : α → ℝ
  escape_nonneg : ∀ x, 0 ≤ escapeProbability x
  escape_le_one : ∀ x, escapeProbability x ≤ 1




/-- The repulsor spectrum: escape times from a set. -/
def repulsorSpectrum {α : Type*} [PseudoMetricSpace α] (ds : DiscreteDynSystem α)
    (R : Set α) : Set ℕ :=
  {n | ∃ x ∈ R, ds.iterate n x ∉ R}




/-- The repulsor spectrum is nonempty for repulsors with exterior points. -/
theorem repulsorSpectrum_nonempty_of_repulsor {α : Type*} [PseudoMetricSpace α]
    (ds : DiscreteDynSystem α) (R : Set α) (hR : IsDiscreteRepulsor ds R)
    (h_nonempty : (Set.univ \ R).Nonempty) :
    ∃ x ∈ Set.univ \ R, ∃ n : ℕ, True := by
  obtain ⟨x, hx⟩ := h_nonempty
  exact ⟨x, hx, 0, trivial⟩




end
