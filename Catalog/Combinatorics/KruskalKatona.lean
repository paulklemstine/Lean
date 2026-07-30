/-
Copyright (c) 2026. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib.Combinatorics.SetFamily.KruskalKatona

/-! # The Kruskal–Katona theorem

A catalog-facing formulation of Mathlib's set-family theorem, together with its
iterated and numerical Lovász consequences.  `∂` denotes the lower shadow and
`IsInitSeg` the initial-segment predicate for colexicographic order.
-/

open Finset
open Finset.Colex
open scoped FinsetFamily

namespace Catalog.Combinatorics.KruskalKatona

variable {n r k i : ℕ} {𝒜 𝒞 : Finset (Finset (Fin n))}

/-- **Kruskal–Katona.** Among uniform families of a given cardinality, an
initial segment of colex has minimum lower shadow. -/
theorem shadow_minimized_by_colex
    (huniform : (𝒜 : Set (Finset (Fin n))).Sized r)
    (hcard : #𝒞 ≤ #𝒜) (hcolex : IsInitSeg 𝒞 r) :
    #(∂ 𝒞) ≤ #(∂ 𝒜) := by
  exact Finset.kruskal_katona huniform hcard hcolex

/-- The iterated Kruskal–Katona theorem: colex initial segments minimize every
iterated lower shadow. -/
theorem iterated_shadow_minimized_by_colex
    (huniform : (𝒜 : Set (Finset (Fin n))).Sized r)
    (hcard : #𝒞 ≤ #𝒜) (hcolex : IsInitSeg 𝒞 r) :
    #(∂^[k] 𝒞) ≤ #(∂^[k] 𝒜) := by
  exact Finset.iterated_kk huniform hcard hcolex

/-- **Lovász form of Kruskal–Katona.** If an `r`-uniform family contains at
least `k.choose r` members, its `i`-fold lower shadow contains at least
`k.choose (r-i)` members. -/
theorem lovasz_shadow_bound (hir : i ≤ r) (hrk : r ≤ k) (hkn : k ≤ n)
    (huniform : (𝒜 : Set (Finset (Fin n))).Sized r)
    (hcard : k.choose r ≤ #𝒜) :
    k.choose (r - i) ≤ #(∂^[i] 𝒜) := by
  exact Finset.kruskal_katona_lovasz_form hir hrk hkn huniform hcard

end Catalog.Combinatorics.KruskalKatona