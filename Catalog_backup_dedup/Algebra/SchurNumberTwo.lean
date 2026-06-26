/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Schur's theorem for two colours: the Schur number `S(2) = 4`

This file develops the additive-combinatorial ("algebraic") side of Ramsey
theory: **Schur's theorem**.  A *Schur triple* is a triple `(x, y, z)` of
positive integers with `x + y = z`; a colouring of `{1, …, n}` is said to be
*monochromatic-free* (a `SchurColouring`) if it contains no Schur triple all of
whose entries receive the same colour.

The **Schur number** `S(r)` is the largest `n` such that `{1, …, n}` admits a
monochromatic-free `r`-colouring.  Here we settle the two-colour case
completely:

* `schurColourable_four`  — `{1, 2, 3, 4}` admits a sum-free two-colouring,
  namely `{1, 4}` (colour `false`) versus `{2, 3}` (colour `true`).
* `not_schurColourable_five` — every two-colouring of `{1, 2, 3, 4, 5}` contains
  a monochromatic Schur triple.

Together with monotonicity (`schurColourable_mono`) these give the exact value
`S(2) = 4` (`schur_number_two`).

A two-colouring of `ℕ` is modelled as a function `c : ℕ → Bool`; only the values
`c 1, …, c n` are inspected by the predicates below, so this faithfully captures
colourings of the finite interval `{1, …, n}`.

-- !-- Lab Notes -- !--
-- Hypothesis: the classical Schur number S(2) equals 4.  This is the additive
--   analogue of the Ramsey number R(3,3)=6 living in the Catalog
--   (`Applications/Ramsey.lean`); Schur's theorem in fact follows from Ramsey's
--   theorem (colour the edge {i,j} by the colour of |i-j|), and S(r) ≤ R_r(3)-1.
-- Experiment: a brute-force `decide` over all `2^6` colourings of indices 0..5
--   confirmed (a) every two-colouring of {1,…,5} has a monochromatic x+y=z and
--   (b) some two-colouring of {1,…,4} avoids one.  See ComputationalEvidence.md.
-- Insight / key construction: the forcing chain making `{1,…,5}` unavoidable is
--   purely deterministic (no genuine case split): writing a = c 1,
--     (1,1,2) ⇒ c 2 ≠ a,  (2,2,4) ⇒ c 4 = a,  (1,4,5) ⇒ c 5 ≠ a,
--     (2,3,5) ⇒ c 3 ≠ c 2 = a,  (1,3,4) ⇒ c 1 = c 3 = c 4 = a — contradiction.
-- Failure analysis: an attempt to phrase the upper bound directly as a
--   `decide` over `ℕ → Bool` is impossible (not a Fintype); the honest
--   `ℕ → Bool` statement is instead reduced to the five Boolean values
--   `c 1, …, c 5` by hand.
-/
import Mathlib

namespace SchurNumber

/-- A *Schur triple* with codomain bounded by `n`: positive `x, y` and `z = x+y`
with `z ≤ n`.  We keep the data as an explicit predicate on `x y z`. -/
def IsSchurTriple (n x y z : ℕ) : Prop :=
  1 ≤ x ∧ 1 ≤ y ∧ x + y = z ∧ z ≤ n

/-- A two-colouring `c : ℕ → Bool` is a **Schur colouring** of `{1, …, n}` if no
Schur triple in `{1, …, n}` is monochromatic. -/
def SchurColouring (n : ℕ) (c : ℕ → Bool) : Prop :=
  ∀ x y z, IsSchurTriple n x y z → ¬ (c x = c y ∧ c y = c z)

/-- `{1, …, n}` is **Schur-colourable** with two colours if it admits a Schur
colouring. -/
def SchurColourable (n : ℕ) : Prop := ∃ c : ℕ → Bool, SchurColouring n c

/-- **Monotonicity.** Restricting a Schur colouring of `{1, …, n}` to a shorter
interval `{1, …, m}` (with `m ≤ n`) is again a Schur colouring. -/
theorem schurColourable_mono {m n : ℕ} (hmn : m ≤ n) (h : SchurColourable n) :
    SchurColourable m := by
  obtain ⟨c, hc⟩ := h
  refine ⟨c, ?_⟩
  intro x y z ht
  exact hc x y z ⟨ht.1, ht.2.1, ht.2.2.1, le_trans ht.2.2.2 hmn⟩

/-- The explicit sum-free two-colouring of `{1, 2, 3, 4}`: colour `2` and `3`
with `true`, everything else with `false`.  Equivalently the partition
`{1, 4} ⊔ {2, 3}`. -/
def witnessColouring : ℕ → Bool := fun k => decide (k = 2 ∨ k = 3)

/-
**Lower bound / construction.** `{1, 2, 3, 4}` is Schur-colourable with two
colours, witnessed by `witnessColouring`.
-/
theorem schurColourable_four : SchurColourable 4 := by
  use fun x => if x = 2 ∨ x = 3 then true else false;
  rintro x y z ⟨ hx, hy, rfl, hz ⟩ ; rcases x with ( _ | _ | _ | _ | _ | x ) <;> rcases y with ( _ | _ | _ | _ | _ | y ) <;> simp_all +arith +decide

/-
**Upper bound (Schur's theorem, two colours).** Every two-colouring of
`{1, 2, 3, 4, 5}` contains a monochromatic Schur triple.
-/
theorem not_schurColourable_five : ¬ SchurColourable 5 := by
  rintro ⟨ c, hc ⟩;
  -- By examining all possible colorings of {1, 2, 3, 4, 5}, we can show that there must be a monochromatic Schur triple.
  have h_examine : ∀ (c : Fin 5 → Bool), ∃ x y z : Fin 5, x.val + 1 + (y.val + 1) = z.val + 1 ∧ z.val + 1 ≤ 5 ∧ c x = c y ∧ c y = c z := by
    decide;
  obtain ⟨ x, y, z, h₁, h₂, h₃, h₄ ⟩ := h_examine ( fun i => c ( i + 1 ) ) ; exact hc ( x + 1 ) ( y + 1 ) ( z + 1 ) ⟨ by linarith, by linarith, by linarith, by linarith ⟩ ( by aesop ) ;

/-- **The Schur number `S(2) = 4`.** `{1, …, 4}` admits a sum-free
two-colouring, but `{1, …, 5}` does not; hence `4` is the largest Schur-colourable
interval length for two colours. -/
theorem schur_number_two :
    SchurColourable 4 ∧ ¬ SchurColourable 5 ∧
      (∀ n, SchurColourable n → n ≤ 4) := by
  refine ⟨schurColourable_four, not_schurColourable_five, ?_⟩
  intro n hn
  by_contra h
  push_neg at h
  exact not_schurColourable_five (schurColourable_mono (by omega) hn)

end SchurNumber