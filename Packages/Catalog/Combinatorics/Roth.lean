/-
Copyright (c) 2026. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib.Combinatorics.Additive.Corner.Roth

/-! # Roth's theorem on three-term arithmetic progressions

We expose both the finite-density theorem and the asymptotic `o(N)` statement.
`ThreeAPFree A` means that `A` contains no nonconstant three-term arithmetic
progression.
-/

open Finset
open Asymptotics Filter

namespace Catalog.Combinatorics.ExtremalGraphTheory

/-- **Roth's theorem, finite density form.** A sufficiently large subset of
`{0, …, n-1}` of density at least `ε` is not three-AP-free. -/
theorem roth_three_ap_density {n : ℕ} (ε : ℝ) (hε : 0 < ε)
    (hn : cornersTheoremBound (ε / 3) ≤ n)
    (A : Finset ℕ) (hA : A ⊆ range n) (hdense : ε * n ≤ #A) :
    ¬ ThreeAPFree (A : Set ℕ) := by
  exact roth_3ap_theorem_nat ε hε hn A hA hdense

/-- **Roth's theorem, asymptotic extremal form.** The largest cardinality of a
three-AP-free subset of `{0, …, N-1}` is `o(N)`. -/
theorem roth_three_ap_asymptotic :
    IsLittleO atTop (fun N ↦ (rothNumberNat N : ℝ)) (fun N ↦ (N : ℝ)) := by
  exact rothNumberNat_isLittleO_id

/-- Positive witness form of Roth's theorem: under the density assumptions,
there are three members `a,b,c` of `A`, not all collapsed at the middle term,
with `a + c = b + b`. -/
theorem exists_nontrivial_three_ap {n : ℕ} (ε : ℝ) (hε : 0 < ε)
    (hn : cornersTheoremBound (ε / 3) ≤ n)
    (A : Finset ℕ) (hA : A ⊆ range n) (hdense : ε * n ≤ #A) :
    ∃ a ∈ A, ∃ b ∈ A, ∃ c ∈ A, a + c = b + b ∧ a ≠ b := by
  have hfree := roth_three_ap_density ε hε hn A hA hdense
  unfold ThreeAPFree at hfree
  push_neg at hfree
  simpa only [Finset.mem_coe] using hfree

end Catalog.Combinatorics.ExtremalGraphTheory