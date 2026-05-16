/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Tropical Surgery: Definitions

Core definitions for tropical (min-plus) matrix surgery operations.
-/
import Mathlib

open Finset

noncomputable section

/-! ## Surgery Operations -/

/-- A rank-one tropical (min-plus) outer product: the matrix with entries `u(i) + v(j)`. -/
def tropicalRankOneUpdate {n : ℕ} (u v : Fin n → ℝ) : Fin n → Fin n → ℝ :=
  fun i j => u i + v j

/-- Rank-two tropical surgery: replace `A` by the entrywise minimum of `A` with
    two rank-one outer products. This is the tropical analogue of a rank-2 additive update. -/
def tropicalRankTwoSurgery {n : ℕ} (A : Fin n → Fin n → ℝ)
    (u v u' v' : Fin n → ℝ) : Fin n → Fin n → ℝ :=
  fun i j => min (A i j) (min (u i + v j) (u' i + v' j))

/-- Localized two-entry surgery: decrease at most two specific matrix entries. -/
def twoEntrySurgery {n : ℕ} (A : Fin n → Fin n → ℝ)
    (i₁ j₁ i₂ j₂ : Fin n) (c₁ c₂ : ℝ) : Fin n → Fin n → ℝ :=
  fun i j =>
    if i = i₁ ∧ j = j₁ then min (A i j) c₁
    else if i = i₂ ∧ j = j₂ then min (A i j) c₂
    else A i j

/-! ## Closed Walk and Cycle Mean -/

/-- Weight of a closed walk of length `k` specified by vertex sequence `σ`.
    The walk visits `σ(0) → σ(1) → ⋯ → σ(k-1) → σ(0)`. -/
def closedWalkWeight {n : ℕ} (A : Fin n → Fin n → ℝ) {k : ℕ} (hk : 0 < k)
    (σ : Fin k → Fin n) : ℝ :=
  ∑ t : Fin k, A (σ t) (σ ⟨(t.val + 1) % k, Nat.mod_lt _ hk⟩)

/-- Mean edge weight of a closed walk (cycle mean). -/
def cycleMean {n : ℕ} (A : Fin n → Fin n → ℝ) {k : ℕ} (hk : 0 < k)
    (σ : Fin k → Fin n) : ℝ :=
  closedWalkWeight A hk σ / (k : ℝ)

/-- A walk parameter: a cycle length index and a vertex sequence. -/
abbrev WalkParam (n : ℕ) := Σ (k : Fin (n + 1)), (Fin (k.val + 1) → Fin (n + 1))

/-- Cycle mean of the walk specified by a `WalkParam`. -/
def walkParamCycleMean {n : ℕ} (A : Fin (n + 1) → Fin (n + 1) → ℝ)
    (p : WalkParam n) : ℝ :=
  cycleMean A (Nat.succ_pos p.1.val) p.2

/-! ## Tropical Spectral Radius -/

/-- The tropical spectral radius of an `(n+1) × (n+1)` matrix, defined as the minimum
    cycle mean over all closed walks of length 1 through `n+1`.

    This equals the minimum cycle mean of the associated weighted digraph,
    which is the tropical eigenvalue in min-plus algebra. -/
def tropicalSpectralRadius {n : ℕ} (A : Fin (n + 1) → Fin (n + 1) → ℝ) : ℝ :=
  Finset.univ.inf' Finset.univ_nonempty (walkParamCycleMean A)

/-! ## Surgery Support -/

/-- The support of surgery: the set of positions where `B i j < A i j`. -/
def surgerySupport {n : ℕ} (A B : Fin n → Fin n → ℝ) : Set (Fin n × Fin n) :=
  {p | B p.1 p.2 < A p.1 p.2}

/-- A walk avoids a set of edges. -/
def walkAvoids {n k : ℕ} (hk : 0 < k)
    (σ : Fin k → Fin n) (S : Set (Fin n × Fin n)) : Prop :=
  ∀ t : Fin k, (σ t, σ ⟨(t.val + 1) % k, Nat.mod_lt _ hk⟩) ∉ S

end