/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Multicolour Schur numbers: the lower bound `S(3) ≥ 13`

This file extends `Algebra/SchurNumberTwo.lean` from two colours to an arbitrary
number of colours, and supplies the classical **construction** witnessing the
lower bound for the three-colour Schur number, `S(3) ≥ 13`.

A colouring with colour set `Fin r` is modelled as `c : ℕ → Fin r`.  A colouring
of `{1, …, n}` is a `SchurColouring` if no Schur triple `x + y = z` (with all
entries in `{1, …, n}`) is monochromatic.  `SchurColourable r n` asserts the
existence of such an `r`-colouring.

The headline result, `schurColourable_three_thirteen`, exhibits the explicit
three-colouring of `{1, …, 13}`

* colour `0`: `{1, 4, 10, 13}`
* colour `1`: `{2, 3, 11, 12}`
* colour `2`: `{5, 6, 7, 8, 9}`

and proves it is sum-free in each colour class, giving `S(3) ≥ 13`.

-- !-- Lab Notes -- !--
-- Hypothesis: the three-colour Schur number satisfies S(3) = 13 (Schur 1916).
--   The upper bound S(3) ≤ 13 requires ruling out every one of `3^13 ≈ 1.6·10⁶`
--   colourings of {1,…,13}; this is feasible only with `native_decide` (the
--   `Lean.ofReduceBool` axiom) and is left to a future cycle (see
--   FUTURE_DIRECTIONS.md).  Here we settle the constructive **lower** bound.
-- Experiment: a `Finset.filter` count over `Icc 1 13 ×ˢ Icc 1 13` confirmed the
--   classical partition above has exactly 0 monochromatic Schur triples.
-- Insight: the colour classes are symmetric under `k ↦ 14 - k` (1↔13, 4↔10,
--   2↔12, 3↔11, and {5,…,9} fixed), reflecting the reflective symmetry of the
--   extremal Schur colouring.
-- Generalisation: `SchurColouring` and `SchurColourable` are stated for an
--   arbitrary colour count `r`, recovering the two-colour file as `r = 2`
--   (via `Bool ≃ Fin 2`), and `schurColourable_mono` transfers verbatim.
-/
import Mathlib

namespace SchurNumber

/-- A *Schur triple* with codomain bounded by `n`: positive `x, y` and `z = x+y`
with `z ≤ n`. -/
def IsSchurTripleN (n x y z : ℕ) : Prop :=
  1 ≤ x ∧ 1 ≤ y ∧ x + y = z ∧ z ≤ n

/-- An `r`-colouring `c : ℕ → Fin r` is a **Schur colouring** of `{1, …, n}` if
no Schur triple in `{1, …, n}` is monochromatic. -/
def SchurColouringR (r n : ℕ) (c : ℕ → Fin r) : Prop :=
  ∀ x y z, IsSchurTripleN n x y z → ¬ (c x = c y ∧ c y = c z)

/-- `{1, …, n}` is **`r`-Schur-colourable** if it admits an `r`-colouring with no
monochromatic Schur triple. -/
def SchurColourableR (r n : ℕ) : Prop := ∃ c : ℕ → Fin r, SchurColouringR r n c

/-- **Monotonicity** in the interval length: a Schur colouring of `{1, …, n}`
restricts to one of `{1, …, m}` for `m ≤ n`. -/
theorem schurColourableR_mono {r m n : ℕ} (hmn : m ≤ n) (h : SchurColourableR r n) :
    SchurColourableR r m := by
  obtain ⟨c, hc⟩ := h
  refine ⟨c, ?_⟩
  intro x y z ht
  exact hc x y z ⟨ht.1, ht.2.1, ht.2.2.1, le_trans ht.2.2.2 hmn⟩

/-- The classical extremal three-colouring of `{1, …, 13}`:
colour `0 = {1, 4, 10, 13}`, colour `1 = {2, 3, 11, 12}`,
colour `2 = {5, 6, 7, 8, 9}`. -/
def witnessThree : ℕ → Fin 3 := fun k =>
  if k = 1 ∨ k = 4 ∨ k = 10 ∨ k = 13 then 0
  else if k = 2 ∨ k = 3 ∨ k = 11 ∨ k = 12 then 1
  else 2

/-
**Construction / lower bound `S(3) ≥ 13`.** `{1, …, 13}` admits a sum-free
three-colouring, witnessed by `witnessThree`.
-/
theorem schurColourable_three_thirteen : SchurColourableR 3 13 := by
  -- By definition of $witnessThree$, we know that no Schur triple in $\{1, \ldots, 13\}$ is monochromatic.
  have h_witness : ∀ x y z, 1 ≤ x → 1 ≤ y → x + y = z → z ≤ 13 → ¬ (witnessThree x = witnessThree y ∧ witnessThree y = witnessThree z) := by
    intro x y z hx hy hxy hz; subst hxy; interval_cases _ : x + y <;> simp_all +decide ;
    all_goals rcases x with ( _ | _ | x ) <;> repeat rcases y with ( _ | _ | y ) <;> simp_all +arith +decide only;
  exact ⟨ _, fun x y z h => h_witness x y z h.1 h.2.1 h.2.2.1 h.2.2.2 ⟩

end SchurNumber