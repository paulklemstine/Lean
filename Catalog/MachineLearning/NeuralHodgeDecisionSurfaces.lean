/-
# A finite polyhedral Hodge shadow for ReLU decision surfaces

This file proves two concrete results that remain valid without imposing a
(nonexistent, in general) complex Hodge structure on a real ReLU decision set.

First, the cycle space of the four-edge square is exactly one-dimensional:
every rational 1-cycle is a common multiple of the sum of its four linear
edges.  Thus every class in this small polyhedral model has an explicit
face-supported representative.

Second, we study the proposed architecture-dependent numerical expression
`choose first p * choose last q * product interior`.  We prove its vanishing
range, reversal symmetry, and a uniform exponential estimate.
-/

import Mathlib

open scoped BigOperators
open Finset

namespace NeuralHodgeDecisionSurfaces

/-! ## The square as a finite decision-surface model -/

/-- Rational coefficients on the four oriented edges of a square. -/
abbrev SquareChain := Fin 4 → ℚ

/-- The cellular boundary of a chain on the cyclically oriented square.
At each vertex this is incoming coefficient minus outgoing coefficient. -/
def squareBoundary (x : SquareChain) : Fin 4 → ℚ := fun v =>
  match v with
  | 0 => x 3 - x 0
  | 1 => x 0 - x 1
  | 2 => x 1 - x 2
  | 3 => x 2 - x 3

/-- A square chain is a cycle exactly when its cellular boundary vanishes. -/
def IsSquareCycle (x : SquareChain) : Prop := squareBoundary x = 0

/-- The fundamental oriented cycle, with coefficient one on every edge. -/
def fundamentalSquareCycle : SquareChain := fun _ => 1

/-- The fundamental square chain has zero boundary. -/
theorem fundamentalSquareCycle_isCycle :
    IsSquareCycle fundamentalSquareCycle := by
  unfold IsSquareCycle squareBoundary fundamentalSquareCycle
  funext v
  fin_cases v <;> simp

/-- Boundary cancellation forces all four edge coefficients to agree. -/
theorem square_cycle_coefficients_equal (x : SquareChain) (hx : IsSquareCycle x) :
    x 0 = x 1 ∧ x 1 = x 2 ∧ x 2 = x 3 := by
  simp [IsSquareCycle] at hx
  have h1 : x 0 - x 1 = 0 := by simpa using congr_fun hx 1
  have h2 : x 1 - x 2 = 0 := by simpa using congr_fun hx 2
  have h3 : x 2 - x 3 = 0 := by simpa using congr_fun hx 3
  exact ⟨by linarith, by linarith, by linarith⟩

/-- **Square cycle classification.** Every rational cycle on the square is a
unique scalar multiple of the sum of its four oriented linear edges. -/
theorem square_cycle_classification (x : SquareChain) :
    IsSquareCycle x ↔ ∃! a : ℚ, x = a • fundamentalSquareCycle := by
  constructor
  · intro hx
    -- Forward: x is a cycle implies x = a • fundamentalSquareCycle for unique a
    have heq := square_cycle_coefficients_equal x hx
    use x 0
    constructor
    · -- Show x = (x 0) • fundamentalSquareCycle
      funext i
      fin_cases i <;> simp [fundamentalSquareCycle, heq]
    · -- Uniqueness
      intro y hy
      have h : x 0 = y := by
        have := congr_fun hy 0
        simp [fundamentalSquareCycle] at this
        linarith
      linarith
  · intro ⟨a, ha, _⟩
    -- Backward: x = a • fundamentalSquareCycle implies x is a cycle
    rw [ha]
    change squareBoundary (a • fundamentalSquareCycle) = 0
    unfold squareBoundary fundamentalSquareCycle
    funext v
    fin_cases v <;> simp

/-- Consequently, two square cycles are equal as soon as they agree on one
edge. This is a useful rigidity consequence of the classification. -/
theorem square_cycle_ext (x y : SquareChain)
    (hx : IsSquareCycle x) (hy : IsSquareCycle y) (h0 : x 0 = y 0) : x = y := by
  have hx' := square_cycle_coefficients_equal x hx
  have hy' := square_cycle_coefficients_equal y hy
  ext i
  fin_cases i <;> simp_all

/-- A cycle whose coefficient on one edge is zero is the zero cycle. -/
theorem square_cycle_eq_zero_of_edge_zero (x : SquareChain)
    (hx : IsSquareCycle x) (h0 : x 0 = 0) : x = 0 := by
  have heq := square_cycle_coefficients_equal x hx
  ext i
  fin_cases i <;> simp_all

/-! ## The proposed architecture expression -/

/-- The numerical expression proposed as a bound for a network with first
hidden width `first`, last hidden width `last`, and intervening widths
`interior`.  No claim that actual Hodge numbers exist is built into this
definition. -/
def architectureBound (first last : ℕ) (interior : List ℕ) (p q : ℕ) : ℕ :=
  first.choose p * last.choose q * interior.prod

/-- The proposed bound vanishes outside the first-layer range. -/
theorem architectureBound_eq_zero_of_first_lt
    {first last p q : ℕ} {interior : List ℕ} (h : first < p) :
    architectureBound first last interior p q = 0 := by
  simp [architectureBound, Nat.choose_eq_zero_of_lt h]

/-- The proposed bound vanishes outside the last-layer range. -/
theorem architectureBound_eq_zero_of_last_lt
    {first last p q : ℕ} {interior : List ℕ} (h : last < q) :
    architectureBound first last interior p q = 0 := by
  simp [architectureBound, Nat.choose_eq_zero_of_lt h]

/-- Reversing all hidden widths and exchanging bidegrees preserves the bound.
This is the exact numerical analogue of Hodge symmetry available here. -/
theorem architectureBound_reverse_symmetry
    (first last p q : ℕ) (interior : List ℕ) :
    architectureBound last first interior.reverse q p =
      architectureBound first last interior p q := by
  simp [architectureBound, List.prod_reverse, mul_comm]

/-- A binomial coefficient is bounded by the full Boolean-cube count. -/
theorem choose_le_two_pow (n k : ℕ) : n.choose k ≤ 2 ^ n := by
  exact Nat.choose_le_two_pow n k

/-- Uniform exponential estimate for the proposed architecture expression. -/
theorem architectureBound_exponential
    (first last p q : ℕ) (interior : List ℕ) :
    architectureBound first last interior p q ≤
      2 ^ (first + last) * interior.prod := by
  simp [architectureBound]
  apply Nat.mul_le_mul_right
  calc first.choose p * last.choose q ≤ 2 ^ first * 2 ^ last := by
         apply Nat.mul_le_mul (choose_le_two_pow first p) (choose_le_two_pow last q)
       _ = 2 ^ (first + last) := by ring

/-- If every intervening layer is nonzero, the architecture expression is
positive exactly in the binomial support rectangle. -/
theorem architectureBound_pos_iff
    {first last p q : ℕ} {interior : List ℕ}
    (hinterior : ∀ w ∈ interior, 0 < w) :
    0 < architectureBound first last interior p q ↔
      p ≤ first ∧ q ≤ last := by
  unfold architectureBound
  have hinterior_pos : 0 < interior.prod := List.prod_pos hinterior
  have mul_pos_iff : ∀ a b : ℕ, 0 < a * b ↔ 0 < a ∧ 0 < b := fun a b => by
    constructor
    · intro h
      constructor
      · by_contra ha; simp [ha] at h
      · by_contra hb; simp [hb] at h
    · exact fun ⟨ha, hb⟩ => Nat.mul_pos ha hb
  rw [mul_pos_iff, mul_pos_iff]
  constructor
  · intro h
    have h1 := h.1.1
    have h2 := h.1.2
    constructor
    · by_contra hp; simp [Nat.choose_eq_zero_of_lt (not_le.mp hp)] at h1
    · by_contra hq; simp [Nat.choose_eq_zero_of_lt (not_le.mp hq)] at h2
  · intro ⟨hp, hq⟩
    exact ⟨⟨Nat.choose_pos hp, Nat.choose_pos hq⟩, hinterior_pos⟩

/-! ## Machine-checked small cases

These examples serve as concise computational evidence.  They are checked by
Lean's kernel along with the general theorems above. -/

example : architectureBound 2 3 [] 1 1 = 6 := by decide
example : architectureBound 3 4 [2] 1 2 = 36 := by decide
example : architectureBound 4 5 [2, 3] 2 1 = 180 := by decide
example : architectureBound 2 3 [] 3 0 = 0 := by decide

/-- Direct finite check of the fundamental square cycle's coefficients. -/
theorem fundamentalSquareCycle_values :
    fundamentalSquareCycle 0 = 1 ∧ fundamentalSquareCycle 1 = 1 ∧
    fundamentalSquareCycle 2 = 1 ∧ fundamentalSquareCycle 3 = 1 := by
  norm_num [fundamentalSquareCycle]

end NeuralHodgeDecisionSurfaces