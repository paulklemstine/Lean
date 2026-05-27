/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Cycle-Birth Concentration — Definitions

Foundational definitions for the theory of cycle-birth distributions
in weighted graph filtrations. These definitions support the main theorems
establishing concentration and universality of tropical critical values.

## Main Definitions

* `FiltStep` — A single edge-insertion step recording weight and connectivity status.
* `WFiltration` — A complete weighted graph filtration (vertices + ordered edge insertions).
* `cycleBirthWeights` — The multiset of edge weights at which cycle births occur.
* `cycleBirthCountLE` — Cumulative counting function for cycle births ≤ threshold.
* `empiricalCycleBirthCDF` — Normalized empirical CDF of cycle-birth times.
* `HasBoundedDifferences` — Abstract bounded-differences property for concentration.
-/

import Mathlib

open Finset BigOperators

namespace CycleBirth

/-! ### Filtration Step -/

/-- A filtration step records what happens when a single edge is inserted
    into the growing subgraph.
    - `sameComponent = true`: endpoints already connected → **cycle birth** (β₁ increases)
    - `sameComponent = false`: endpoints in different components → **merge** (β₀ decreases) -/
structure FiltStep where
  weight : ℚ
  sameComponent : Bool
  deriving DecidableEq, Inhabited

/-! ### Weighted Filtration -/

/-- A weighted graph filtration: vertex count + ordered edge insertions.
    Each step records the edge weight and whether the endpoints were
    already in the same connected component at the time of insertion. -/
structure WFiltration where
  numVerts : ℕ
  steps : List FiltStep

/-- Number of cycle-birth events (edges creating cycles). -/
def WFiltration.cycleCount (F : WFiltration) : ℕ :=
  F.steps.countP (·.sameComponent)

/-- Number of merge events (edges connecting components). -/
def WFiltration.mergeCount (F : WFiltration) : ℕ :=
  F.steps.countP (fun s => !s.sameComponent)

/-! ### Cycle-Birth Multiset and Counting -/

/-- **Cycle-birth weight list.**
    The list of edge weights at which cycle births occur.
    These are the **tropical critical values** of the filtration. -/
def WFiltration.cycleBirthWeights (F : WFiltration) : List ℚ :=
  (F.steps.filter (·.sameComponent)).map (·.weight)

/-- **Cumulative cycle-birth counting function.**
    `cycleBirthCountLE F t` = number of cycle births with weight ≤ t.
    This is the **tropical spectral counting function**. -/
def WFiltration.cycleBirthCountLE (F : WFiltration) (t : ℚ) : ℕ :=
  F.steps.countP (fun s => s.sameComponent && decide (s.weight ≤ t))

/-- **Empirical cycle-birth CDF.**
    Normalizes the counting function by total cycle count. -/
noncomputable def WFiltration.empiricalCycleBirthCDF (F : WFiltration) (t : ℚ) : ℚ :=
  if F.cycleCount = 0 then 0
  else (F.cycleBirthCountLE t : ℚ) / (F.cycleCount : ℚ)

/-! ### Weight Transformation -/

/-- Apply a function to all step weights, preserving sameComponent flags. -/
def WFiltration.mapWeights (F : WFiltration) (φ : ℚ → ℚ) : WFiltration where
  numVerts := F.numVerts
  steps := F.steps.map (fun s => ⟨φ s.weight, s.sameComponent⟩)

/-- Extract the classification flags (true = cycle birth, false = merge). -/
def WFiltration.flags (F : WFiltration) : List Bool :=
  F.steps.map (·.sameComponent)

/-! ### Bounded Differences -/

/-- A function on Boolean vectors has bounded differences with constant `c`.
    This is the hypothesis needed for McDiarmid's inequality.
    If `f` satisfies bounded differences with constant 1 in each coordinate,
    then: P(|f(X) - E[f(X)]| ≥ r) ≤ 2·exp(-2r²/m). -/
def HasBoundedDifferences (m : ℕ) (f : (Fin m → Bool) → ℤ) (c : ℕ) : Prop :=
  ∀ (x : Fin m → Bool) (i : Fin m) (b : Bool),
    |f x - f (Function.update x i b)| ≤ c

/-! ### Worked Examples -/

/-- Triangle filtration: 3 vertices, edges with weights 1, 2, 3.
    First two edges merge, third creates a cycle. -/
def triangleFiltration : WFiltration where
  numVerts := 3
  steps := [⟨1, false⟩, ⟨2, false⟩, ⟨3, true⟩]

/-- K₄ filtration: 4 vertices, edges with weights 1..6.
    First 3 edges form spanning tree (merges), last 3 create cycles. -/
def k4Filtration : WFiltration where
  numVerts := 4
  steps := [⟨1, false⟩, ⟨2, false⟩, ⟨3, false⟩, ⟨4, true⟩, ⟨5, true⟩, ⟨6, true⟩]

end CycleBirth