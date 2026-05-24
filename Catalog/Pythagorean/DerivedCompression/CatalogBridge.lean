/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Harmonic Research
-/
import Mathlib
import Pythagorean.ProbeComplexity.CompressionFiltration
import Pythagorean.DerivedCompression.Basic

/-!
# Bridge: Derived Compression ↔ Catalog Infrastructure

This file connects the abstract derived compression invariants from
`DerivedCompression.Basic` to the catalog's concrete `compressionDefect`
defined in `Pythagorean.ProbeComplexity.CompressionFiltration`.

## Main Results

* `compressionDefect_eq_kappa1` — The catalog's compression defect is κ¹.
* `catalog_nonneg_via_kappa1` — Catalog nonnegativity as a corollary of κ¹ theory.
-/

open CategoryTheory Opposite DerivedCompression

universe u v

/-- **Bridge theorem**: The catalog's `compressionDefect` is a special case of κ¹.
    `compressionDefect J F G = kappa1 (κ F) (κ (F ⊕ G)) (κ G)` -/
theorem compressionDefect_eq_kappa1
    {C : Type u} [Category.{v} C] [DecidableEq C] [Fintype C]
    (J : GrothendieckTopology C)
    (F G : Cᵒᵖ ⥤ Type v) :
    CompressionFiltration.compressionDefect J F G =
      kappa1 (CompressionFiltration.sheafCompressionNumber J F : ℤ)
        (CompressionFiltration.sheafCompressionNumber J
          (CompressionFiltration.PresheafCoprod F G) : ℤ)
        (CompressionFiltration.sheafCompressionNumber J G : ℤ) := by
  unfold CompressionFiltration.compressionDefect kappa1
  ring

/-- **Corollary**: The catalog's `compressionDefect_nonneg` via `kappa1_nonneg`. -/
theorem catalog_nonneg_via_kappa1
    {C : Type u} [Category.{v} C] [DecidableEq C] [Fintype C]
    (J : GrothendieckTopology C)
    (F G : Cᵒᵖ ⥤ Type v)
    (hF : (CompressionFiltration.sheafCompressionCards J F).Nonempty)
    (hG : (CompressionFiltration.sheafCompressionCards J G).Nonempty) :
    0 ≤ CompressionFiltration.compressionDefect J F G := by
  rw [compressionDefect_eq_kappa1]
  apply kappa1_nonneg
  exact_mod_cast CompressionFiltration.compression_extension_le J F G hF hG