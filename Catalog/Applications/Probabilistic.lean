/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Foundations for the probabilistic method (first moment / union bound)

This file collects elementary, fully self-contained counting lemmas that constitute
the *first moment method* (a.k.a. the union bound), phrased over finite types.  These
are the probabilistic-method foundations referenced by the `n`-queens completion
development in `Catalog/Applications/NQueens`.

The statements are deliberately measure-free: a "random outcome" ranges over a finite
type `Ω`, an "event" is a `Finset Ω`, and "positive probability" is encoded as the
*existence* of an outcome.  The arguments are pure cardinality counting.
-/

import Mathlib

namespace Catalog.Probabilistic

open Finset

/-
**First moment method (union bound), set form.**
If a finite family of events `B i` (`i ∈ s`) has total size strictly less than the
number of outcomes, then some outcome avoids every event.  This is the deterministic
core of the union bound: `ℙ(⋃ Bᵢ) ≤ ∑ ℙ(Bᵢ) < 1`.
-/
theorem exists_avoiding_all {Ω : Type*} [Fintype Ω] [DecidableEq Ω] {ι : Type*}
    (s : Finset ι) (B : ι → Finset Ω)
    (h : ∑ i ∈ s, (B i).card < Fintype.card Ω) :
    ∃ ω : Ω, ∀ i ∈ s, ω ∉ B i := by
  contrapose! h;
  exact le_trans ( by simp +decide ) ( Finset.card_le_card ( show Finset.univ ⊆ Finset.biUnion s B from fun ω _ => by obtain ⟨ i, hi, hi' ⟩ := h ω; exact Finset.mem_biUnion.2 ⟨ i, hi, hi' ⟩ ) ) |> le_trans <| Finset.card_biUnion_le

/-
**First moment method, expectation form.**
If a nonnegative integer "cost" function has total (hence average) value strictly less
than the number of outcomes, then some outcome has zero cost.  Equivalently: if the
expected number of bad events is `< 1`, some outcome has no bad event.
-/
theorem exists_eq_zero_of_sum_lt_card {Ω : Type*} [Fintype Ω] [Nonempty Ω] (f : Ω → ℕ)
    (h : ∑ ω, f ω < Fintype.card Ω) :
    ∃ ω, f ω = 0 := by
  contrapose! h;
  exact le_trans ( by simp +decide ) ( Finset.sum_le_sum fun ω _ => Nat.one_le_iff_ne_zero.mpr ( h ω ) )

end Catalog.Probabilistic