import Mathlib

/-!
# Shadow-Energy Universality: Definitions

This file defines the core mathematical structures for the Shadow-Energy
Dimension-Independence Theorem for separable Lagrangian systems.

## Main Definitions

* `ExtensivityIndex` — A novel quantitative measure of how a numerical scheme's
  error constant scales with spatial dimension.
* `kineticEnergy` — Weighted Pythagorean sum T(v) = Σᵢ ½ mᵢ vᵢ².
* `shadowBound` — The shadow energy bound C₀ · h² · (1 + κ/n).
* `SeparableDefectData` — Packages per-component defects and coupling for
  a separable Lagrangian system.

## Context

In classical mechanics, a *separable Lagrangian* has the form L = T(v) - V(q)
where the kinetic energy T is a weighted sum of squares (Pythagorean structure).
The shadow energy theorem states that the energy drift of a symplectic integrator
applied to such a system admits a bound that is *dimension-independent* in the
limit n → ∞, with correction term O(κ/n).
-/

noncomputable section

open Finset BigOperators

/-- The extensivity index measures how a numerical scheme's error constant
    scales with spatial dimension. Index 0 means dimension-independent,
    Index 1 means linear scaling, etc. This is a NEW quantitative measure
    of the "curse of dimensionality" for integrators. -/
structure ExtensivityIndex where
  /-- The scaling exponent: 0 = dimension-free, 1 = linear in n -/
  index : ℝ
  /-- Base error constant as a function of energy level -/
  baseConstant : ℝ → ℝ
  /-- Coupling correction parameter κ -/
  dimCorrection : ℝ
  /-- The index is non-negative -/
  index_nonneg : 0 ≤ index
  /-- The base constant is positive at every energy level -/
  base_pos : ∀ E₀, 0 < baseConstant E₀

/-- Kinetic energy as a weighted Pythagorean sum: T(v) = Σᵢ ½ mᵢ vᵢ² -/
def kineticEnergy {n : ℕ} (m : Fin n → ℝ) (v : Fin n → ℝ) : ℝ :=
  ∑ i : Fin n, (1 / 2) * m i * (v i) ^ 2

/-- The shadow energy bound function: C₀ · h² · (1 + κ/n) -/
def shadowBound (C₀ h κ : ℝ) (n : ℕ) : ℝ :=
  C₀ * h ^ 2 * (1 + κ / ↑n)

/-- Data packaging the per-component defects and coupling term
    for a separable Lagrangian system. -/
structure SeparableDefectData (n : ℕ) where
  /-- Per-component energy defects -/
  componentDefects : Fin n → ℝ
  /-- Coupling term from inter-component interactions -/
  couplingTerm : ℝ
  /-- Per-component bound -/
  componentBound : ℝ
  /-- Coupling bound -/
  couplingBound : ℝ
  /-- Each component defect is bounded -/
  hcomp : ∀ i, |componentDefects i| ≤ componentBound
  /-- The coupling term is bounded -/
  hcoupl : |couplingTerm| ≤ couplingBound

/-- The total defect of a separable system is the sum of component defects
    plus the coupling term. -/
def SeparableDefectData.totalDefect {n : ℕ} (d : SeparableDefectData n) : ℝ :=
  (∑ i, d.componentDefects i) + d.couplingTerm

/-- An extensivity index of zero, representing perfect dimension-independence. -/
def ExtensivityIndex.zero (C : ℝ → ℝ) (hC : ∀ E₀, 0 < C E₀) : ExtensivityIndex where
  index := 0
  baseConstant := C
  dimCorrection := 0
  index_nonneg := le_refl 0
  base_pos := hC

end