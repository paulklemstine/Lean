/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Harmonic Research
-/
import Mathlib
import Pythagorean.CategoricalShannon.Defs

/-!
# Categorical Shannon Theory — Main Theorems

This file proves the core theorems of **Categorical Shannon Theory**:

1. **Discrete Tightness**: In a discrete model, `minCoverSize = totalElements`.
2. **Terminal Compression**: With a terminal source, `minCoverSize ≤ |F(T)|`.
3. **Graph Domination Bridge**: Covers ↔ dominating sets.
4. **Compression Factor**: Discrete needs `n` times more generators than connected.

## The Shannon Analogy

Morphisms are channels: each generator `(Y, z)` "transmits" its value to other
objects via restriction maps. `minCoverSize` = minimum codewords needed.
-/

open Finset Fintype

noncomputable section

set_option linter.unusedVariables false

/-! ### Theorem 1: Discrete Tightness -/

/-- In a discrete model, a covering generator must be at the same object. -/
theorem discrete_covers_same_object (M : PresheafModel) (hdisc : IsDiscreteModel M)
    (g : Generator M) (X : M.Ob) (w : M.F X) (hcov : Covers M g X w) :
    g.1 = X := by
  have h := hdisc X g.1 hcov.1
  exact h.symm

/-- In a discrete model with identity self-restrictions, each generator covers
    exactly its own element. Uses `rcases` decomposition on the sigma pair. -/
theorem discrete_covers_self_only (M : PresheafModel) (hdisc : IsDiscreteModel M)
    (hid : ∀ (Y : M.Ob) (w : M.F Y), M.restrict Y Y w = w)
    (g : Generator M) (X : M.Ob) (w : M.F X)
    (hcov : Covers M g X w) : g = ⟨X, w⟩ := by
  rcases g with ⟨Y, z⟩
  have hYX : Y = X := by
    have h := hdisc X Y hcov.1
    exact h.symm
  subst hYX
  have hzw : z = w := by
    have h := hcov.2
    dsimp at h
    rw [hid _ z] at h
    exact h
  subst hzw; rfl

/-- Any covering set in a discrete model must contain all generators.
    By contradiction: if some `⟨Y, z⟩ ∉ S`, then `z` at `Y` cannot be covered. -/
theorem discrete_covering_set_eq_univ (M : PresheafModel) (hdisc : IsDiscreteModel M)
    (hid : ∀ (Y : M.Ob) (w : M.F Y), M.restrict Y Y w = w)
    (hsc : IsSelfCovering M)
    (S : Finset (Generator M)) (hS : IsCoveringSet M S) :
    S = Finset.univ := by
  ext ⟨Y, z⟩
  simp only [Finset.mem_univ, iff_true]
  obtain ⟨g', hg'_mem, hg'_cov⟩ := hS Y z
  have heq := discrete_covers_self_only M hdisc hid g' Y z hg'_cov
  rwa [heq] at hg'_mem

/-- **Theorem 1 (Discrete Tightness).**
    In a discrete self-covering model with identity self-restrictions,
    `minCoverSize M = totalElements M`. No compression is possible.

    *Proof*: Upper bound from `fullSet_isCovering`. Lower bound by showing
    every covering set must be the full set via `discrete_covers_self_only`. -/
theorem discrete_minCoverSize_eq_totalElements (M : PresheafModel) (hdisc : IsDiscreteModel M)
    (hsc : IsSelfCovering M)
    (hid : ∀ (Y : M.Ob) (w : M.F Y), M.restrict Y Y w = w) :
    minCoverSize M = totalElements M := by
  apply le_antisymm
  · exact minCoverSize_le_totalElements M hsc
  · unfold minCoverSize
    apply le_csInf
    · exact ⟨_, _, rfl, fullSet_isCovering M hsc⟩
    · intro k ⟨S, hcard, hcov⟩
      rw [← hcard, discrete_covering_set_eq_univ M hdisc hid hsc S hcov]
      simp [totalElements, Element, Generator]

/-! ### Theorem 2: Terminal Object Compression -/

/-- The set of generators at object `T`. -/
def generatorsAt (M : PresheafModel) (T : M.Ob) : Finset (Generator M) :=
  (Finset.univ : Finset (M.F T)).map ⟨fun z => (⟨T, z⟩ : Generator M), fun a b h => by
    simp [Generator] at h; exact h⟩

theorem generatorsAt_card (M : PresheafModel) (T : M.Ob) :
    (generatorsAt M T).card = Fintype.card (M.F T) := by
  simp [generatorsAt]

/-- With surjective restrictions from a terminal source, generators at T cover all. -/
theorem terminal_generators_cover (M : PresheafModel) (T : M.Ob)
    (hterm : IsTerminalSource M T) (hsurj : TerminalSurjective M T) :
    IsCoveringSet M (generatorsAt M T) := by
  intro X w
  obtain ⟨z, hz⟩ := hsurj X w
  refine ⟨⟨T, z⟩, ?_, ?_⟩
  · simp [generatorsAt]
  · exact ⟨hterm X, hz⟩

/-- **Theorem 2 (Terminal Compression).**
    `minCoverSize M ≤ |F(T)|` when T is terminal with surjective restrictions.
    Uses `calc` chain through `generatorsAt_card`. -/
theorem minCoverSize_le_terminal_fiber (M : PresheafModel) (T : M.Ob)
    (hterm : IsTerminalSource M T) (hsurj : TerminalSurjective M T)
    (hsc : IsSelfCovering M) :
    minCoverSize M ≤ Fintype.card (M.F T) := by
  calc minCoverSize M
      ≤ (generatorsAt M T).card :=
        minCoverSize_le_of_covering M _ (terminal_generators_cover M T hterm hsurj)
    _ = Fintype.card (M.F T) := generatorsAt_card M T

/-! ### Theorem 3: Functional Uniqueness of Covers -/

/-- Each generator covers at most one element per object (deterministic restriction). -/
theorem generator_covers_unique (M : PresheafModel) (g : Generator M) (X : M.Ob)
    (w₁ w₂ : M.F X) (h₁ : Covers M g X w₁) (h₂ : Covers M g X w₂) : w₁ = w₂ := by
  rw [← h₁.2, ← h₂.2]

/-! ### Theorem 4: Graph Domination Bridge -/

/-- **Theorem 4 (Graph Domination Bridge).**
    For self-covering models, covering sets = dominating sets in the generator graph.
    Cross-domain bridge between presheaf theory and graph theory. -/
theorem covering_eq_dominating (M : PresheafModel) (hsc : IsSelfCovering M)
    (S : Finset (Generator M)) :
    IsCoveringSet M S ↔ IsDominatingSet M (stdGenGraph M) S :=
  covering_iff_dominating M hsc S

/-! ### Concrete Models -/

/-- Discrete model on `Fin n` with fiber `Fin (m + 1)`. Only self-restrictions. -/
def discreteFinModel (n m : ℕ) : PresheafModel where
  Ob := Fin n
  instFintypeOb := inferInstance
  instDecEqOb := inferInstance
  F := fun _ => Fin (m + 1)
  instFintypeF := fun _ => inferInstance
  instDecEqF := fun _ => inferInstance
  hasRestriction := fun X Y => X = Y
  instDecRestriction := by
    intro ⟨x, y⟩; simp [Function.uncurry]; exact inferInstance
  restrict := fun X Y z => if X = Y then z else 0

theorem discreteFinModel_isDiscrete (n m : ℕ) :
    IsDiscreteModel (discreteFinModel n m) := fun _ _ h => h

theorem discreteFinModel_isSelfCovering (n m : ℕ) :
    IsSelfCovering (discreteFinModel n m) := by
  intro X w; exact ⟨rfl, by simp [discreteFinModel]⟩

theorem discreteFinModel_id_restrict (n m : ℕ) (Y : Fin n) (w : Fin (m + 1)) :
    (discreteFinModel n m).restrict Y Y w = w := by simp [discreteFinModel]

theorem discreteFinModel_totalElements (n m : ℕ) :
    totalElements (discreteFinModel n m) = n * (m + 1) := by
  simp [totalElements_eq_sum, discreteFinModel]

/-- **Tightness Theorem**: `minCoverSize(discrete n m) = n * (m + 1)`. -/
theorem discreteFinModel_minCoverSize (n m : ℕ) :
    minCoverSize (discreteFinModel n m) = n * (m + 1) := by
  rw [← discreteFinModel_totalElements n m]
  exact discrete_minCoverSize_eq_totalElements _
    (discreteFinModel_isDiscrete n m)
    (discreteFinModel_isSelfCovering n m)
    (discreteFinModel_id_restrict n m)

/-- Connected model on `Fin n` with fiber `Fin (m + 1)`, all-to-all identity. -/
def connectedFinModel (n m : ℕ) : PresheafModel where
  Ob := Fin n
  instFintypeOb := inferInstance
  instDecEqOb := inferInstance
  F := fun _ => Fin (m + 1)
  instFintypeF := fun _ => inferInstance
  instDecEqF := fun _ => inferInstance
  hasRestriction := fun _ _ => True
  instDecRestriction := by
    intro ⟨_, _⟩; simp [Function.uncurry]; exact inferInstance
  restrict := fun _ _ z => z

theorem connectedFinModel_selfCovering (n m : ℕ) :
    IsSelfCovering (connectedFinModel n m) := fun _ w => ⟨trivial, rfl⟩

/-- **Compression Instance**: Connected model needs at most `m + 1` generators. -/
theorem connectedFinModel_minCoverSize_le (n m : ℕ) (hn : 0 < n) :
    minCoverSize (connectedFinModel n m) ≤ m + 1 := by
  have h := minCoverSize_le_terminal_fiber (connectedFinModel n m) (⟨0, hn⟩ : Fin n)
    (fun _ => trivial) (fun _ w => ⟨w, rfl⟩)
    (connectedFinModel_selfCovering n m)
  simp [connectedFinModel] at h
  exact h

/-! ### Theorem 5: Compression Factor -/

/-- **Theorem 5 (Compression Factor).**
    Discrete: `n * (m+1)` generators. Connected: `≤ m+1` generators.
    Ratio is `n` — morphisms provide `n`-fold compression. -/
theorem compression_factor (n m : ℕ) (hn : 0 < n) :
    minCoverSize (discreteFinModel n m) = n * (m + 1) ∧
    minCoverSize (connectedFinModel n m) ≤ m + 1 :=
  ⟨discreteFinModel_minCoverSize n m, connectedFinModel_minCoverSize_le n m hn⟩

/-! ### Information-Theoretic Interpretation -/

/-- The **categorical entropy**: total elements to represent. -/
def categoricalEntropy (M : PresheafModel) : ℕ := totalElements M

/-- In the discrete case, cover size = entropy: zero compression. -/
theorem discrete_zero_compression (M : PresheafModel) (hdisc : IsDiscreteModel M)
    (hsc : IsSelfCovering M)
    (hid : ∀ (Y : M.Ob) (w : M.F Y), M.restrict Y Y w = w) :
    minCoverSize M = categoricalEntropy M :=
  discrete_minCoverSize_eq_totalElements M hdisc hsc hid

/-! ### Conjecture: Morphism Density Compression Law -/

/-- The total number of restriction pairs in the model. -/
def totalRestrictions (M : PresheafModel) : ℕ :=
  @Finset.card (M.Ob × M.Ob)
    ((Finset.univ).filter (fun p => @decide (M.hasRestriction p.1 p.2)
      (M.instDecRestriction ⟨p.1, p.2⟩)))

/-- **Falsifiable Conjecture (REFUTED)**: `minCoverSize * R ≤ n² * m`.
    Counterexample: n=3, m=3, R=5 (2 extra edges), minCoverSize=6.
    6 * 5 = 30 > 27 = 9 * 3.

    The failure reveals that morphism density alone does not determine
    compression — the *topology* of the restriction graph matters.
    This motivates studying graph-theoretic invariants (connectivity,
    domination number) rather than simple edge counts. -/
def MorphismDensityCompressionLaw_Refuted : Prop :=
  ¬ (∀ (n m R : ℕ),
    0 < n → 0 < m → n ≤ R →
    ∀ (M : PresheafModel),
      Fintype.card M.Ob = n →
      (∀ X : M.Ob, Fintype.card (M.F X) ≤ m) →
      IsSelfCovering M →
      minCoverSize M * R ≤ n * n * m)

/-- **Refined Conjecture**: `minCoverSize ≤ n * m / max(1, minInDegree)`
    where `minInDegree` is the minimum over objects X of the number of
    objects Y with a restriction to X. This accounts for topology. -/
def RefinedCompressionConjecture : Prop :=
  ∀ (M : PresheafModel),
    IsSelfCovering M →
    ∀ (d : ℕ), 0 < d →
    (∀ X : M.Ob, d ≤ (Finset.univ.filter (fun Y : M.Ob =>
      @decide (M.hasRestriction X Y) (M.instDecRestriction ⟨X, Y⟩))).card) →
    ∀ (m : ℕ), (∀ X : M.Ob, Fintype.card (M.F X) ≤ m) →
    minCoverSize M * d ≤ Fintype.card M.Ob * m

end