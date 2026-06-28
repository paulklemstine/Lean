/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# A uniform set family of VC dimension at most `d` and size `Mformula n d`

This file realises the construction promised by `LayeredStarFormula.lean`: an
explicit *uniform* set family over `Fin n` whose VC dimension is at most `d` and
whose cardinality is exactly `Mformula n d = C(n, ⌊d/2⌋)`.

* `Shatters F S`           — every subset of `S` is cut out by some member of `F`;
* `VCdimLe F d`            — no shattered set exceeds `d` points;
* `uniformStarFamily n d`  — all `⌊d/2⌋`-element subsets of `Fin n`;
* `uniformStarFamily_uniform`  — it is uniform (every member has `⌊d/2⌋` points);
* `uniformStarFamily_card`     — its size is `Mformula n d`;
* `uniformStarFamily_vcDimLe`  — its VC dimension is at most `d`;
* `exists_uniform_VC_family`   — the packaged existence statement.

The VC bound is sharp at the level of the construction: shattering a set `S`
requires (taking `T = S`) some `⌊d/2⌋`-set containing `S`, forcing
`|S| ≤ ⌊d/2⌋ ≤ d`.
-/
import Mathlib

open Finset

namespace Catalog.Novelty.UniformVCStar

variable {n : ℕ}

/-- A set family `F` over `Fin n` **shatters** `S` if every subset `T ⊆ S` is
realized as `s ∩ S` for some member `s ∈ F`. -/
def Shatters (F : Finset (Finset (Fin n))) (S : Finset (Fin n)) : Prop :=
  ∀ T ⊆ S, ∃ s ∈ F, s ∩ S = T

/-- `F` has VC dimension at most `d`: no shattered set has more than `d` points. -/
def VCdimLe (F : Finset (Finset (Fin n))) (d : ℕ) : Prop :=
  ∀ S : Finset (Fin n), Shatters F S → S.card ≤ d

/-- The size of the central uniform layer, `C(n, ⌊d/2⌋)`. -/
def Mformula (n d : ℕ) : ℕ := n.choose (d / 2)

/-- The **uniform layered-star family**: all `⌊d/2⌋`-element subsets of `Fin n`. -/
def uniformStarFamily (n d : ℕ) : Finset (Finset (Fin n)) :=
  (Finset.univ : Finset (Fin n)).powersetCard (d / 2)

/-- The family has size exactly `Mformula n d = C(n, ⌊d/2⌋)`. -/
theorem uniformStarFamily_card (n d : ℕ) :
    (uniformStarFamily n d).card = Mformula n d := by
  unfold uniformStarFamily Mformula
  rw [Finset.card_powersetCard]
  simp

/-- The family is **uniform**: every member has exactly `⌊d/2⌋` points. -/
theorem uniformStarFamily_uniform (n d : ℕ) :
    ∀ s ∈ uniformStarFamily n d, s.card = d / 2 := by
  intro s hs
  rw [uniformStarFamily, Finset.mem_powersetCard] at hs
  exact hs.2

/-- The uniform layered-star family has **VC dimension at most `d`**. -/
theorem uniformStarFamily_vcDimLe (n d : ℕ) :
    VCdimLe (uniformStarFamily n d) d := by
  intro S hS
  obtain ⟨s, hs, hsS⟩ := hS S (le_refl S)
  have hSsub : S ⊆ s := by rw [← hsS]; exact Finset.inter_subset_left
  have hcard : s.card = d / 2 := uniformStarFamily_uniform n d s hs
  have h2 : S.card ≤ s.card := Finset.card_le_card hSsub
  omega

/-- **Main construction.** For every `n` and `d` there is a *uniform* set family
over `Fin n` of VC dimension at most `d` and size exactly `Mformula n d`. -/
theorem exists_uniform_VC_family (n d : ℕ) :
    ∃ F : Finset (Finset (Fin n)),
      F.card = Mformula n d ∧ (∀ s ∈ F, s.card = d / 2) ∧ VCdimLe F d :=
  ⟨uniformStarFamily n d, uniformStarFamily_card n d,
    uniformStarFamily_uniform n d, uniformStarFamily_vcDimLe n d⟩

end Catalog.Novelty.UniformVCStar