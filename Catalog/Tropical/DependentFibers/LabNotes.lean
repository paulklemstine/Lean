import Tropical.DependentFibers.Compositions
import Tropical.DependentFibers.NonConstant
import Tropical.DependentFibers.Semiring
import Tropical.DependentFibers.Sharpness

/-!
# Lab notes: kernel-checked fibre data for the dependent-fibre thread

Every statement below is a concrete instance of the general theory, checked by Lean.
They are the data that suggested the general theorems, recorded as theorems in their
own right.  (The numerical values were first produced by evaluating `fiber`, which is
computable; see `ComputationalEvidence.md`.)

## Experiment RAMP — the generic degree-4 polynomial `min_i (i(i−1)/2 + i·x)`

Fibre cardinalities at `x = 0, −1, −2, −3, −4, …` are `2, 2, 2, 2, 1, 1, …` and the
fibre at a half-integer is a singleton: exactly `4` simple corners, in accordance with
`cornerSet_rampCoeff_ncard`.

## Experiment STEP — the step polynomials of degree 4

At `x = 0` the fibre cardinalities of `stepCoeff k`, `k = 1 … 5`, are `1, 2, 3, 4, 5`,
and at `x = 1` they are all `1`: every admissible cardinality occurs
(`dependent_solutions_at_every_cardinality`).

## Experiment BLOCK — two-block Newton polygons of degree 6

The pairs of corner multiplicities are `(1,7), (2,6), (3,5), (4,4), (5,3), (6,2),
(7,1)`: every two-part composition of `6` is realised (`two_block_profile`).

## Experiment NONCONVEX — strictness off the Newton polygon

For `c = (0, 5, 1, 7)` (degree `3`) the monomial `i = 1` lies strictly above the lower
hull.  The polynomial has only two corners, at `x = −1/2` with fibre `{0, 2}` and at
`x = −6` with fibre `{2, 3}`, so the total multiplicity excess is `2 < 3 = n`: the
degree bound `multiplicity_sum_le` is *strict* exactly when some monomial is invisible,
and the missing amount is the lattice length hidden inside the hull edge `(0,0)–(2,1)`.
-/

namespace TropicalDependentFibers

open Finset

/-! ## RAMP -/

/-- The four corners of the generic degree-4 polynomial and their fibres. -/
theorem labnote_ramp_deg_four :
    fiber 4 rampCoeff (-(0 : ℚ)) = {0, 1} ∧ fiber 4 rampCoeff (-(1 : ℚ)) = {1, 2} ∧
      fiber 4 rampCoeff (-(2 : ℚ)) = {2, 3} ∧ fiber 4 rampCoeff (-(3 : ℚ)) = {3, 4} := by
  refine ⟨?_, ?_, ?_, ?_⟩
  · simpa using fiber_rampCoeff (n := 4) (m := 0) (by omega)
  · simpa using fiber_rampCoeff (n := 4) (m := 1) (by omega)
  · simpa using fiber_rampCoeff (n := 4) (m := 2) (by omega)
  · simpa using fiber_rampCoeff (n := 4) (m := 3) (by omega)

/-- Degree 4, generic: exactly four corners, total multiplicity excess `4`. -/
theorem labnote_ramp_corner_data :
    (cornerSet 4 rampCoeff).ncard = 4 ∧
      ∑ x ∈ (range 4).image (fun m : ℕ => -(m : ℚ)), ((fiber 4 rampCoeff x).card - 1) = 4 :=
  ⟨cornerSet_rampCoeff_ncard 4, multiplicity_sum_rampCoeff 4⟩

/-! ## STEP -/

/-- The full cardinality ladder in degree 4: `1, 2, 3, 4, 5` at the origin, all `1` at
`x = 1`. -/
theorem labnote_step_ladder :
    ((fiber 4 (stepCoeff 1) 0).card, (fiber 4 (stepCoeff 2) 0).card,
        (fiber 4 (stepCoeff 3) 0).card, (fiber 4 (stepCoeff 4) 0).card,
        (fiber 4 (stepCoeff 5) 0).card) = (1, 2, 3, 4, 5) ∧
      ∀ k : ℕ, 1 ≤ k → (fiber 4 (stepCoeff k) 1).card = 1 := by
  constructor
  · simp only [Prod.mk.injEq]
    refine ⟨?_, ?_, ?_, ?_, ?_⟩ <;>
      rw [fiber_stepCoeff_zero (by omega) (by omega), Finset.card_range]
  · intro k hk
    rw [fiber_stepCoeff_one (n := 4) hk, Finset.card_singleton]

/-! ## BLOCK -/

/-- Every two-part composition of `6` occurs as a pair of corner multiplicities. -/
theorem labnote_block_profiles_six :
    ∀ m ≤ 6, (fiber 6 (sumCoeff (twoBlockIncr m)) (-1)).card = m + 1 ∧
      (fiber 6 (sumCoeff (twoBlockIncr m)) (-2)).card = 7 - m := by
  intro m hm
  obtain ⟨h1, h2⟩ := two_block_profile (n := 6) hm
  refine ⟨h1, ?_⟩
  omega

/-! ## NONCONVEX -/

/-- The non-convex experimental coefficient vector `(0, 5, 1, 7)`. -/
def exCoeff : ℕ → ℚ := fun i => if i = 0 then 0 else if i = 1 then 5 else if i = 2 then 1 else 7

/-- At `x = −6` the two top monomials tie: the fibre is `{2, 3}`. -/
theorem labnote_ex_fiber_neg_six : fiber 3 exCoeff (-6) = {2, 3} := by
  ext i
  simp only [mem_fiber_iff, Finset.mem_insert, Finset.mem_singleton]
  constructor
  · rintro ⟨hi, hmin⟩
    have h := hmin 2 (by norm_num)
    interval_cases i
    · norm_num [exCoeff] at h
    · norm_num [exCoeff] at h
    · exact Or.inl rfl
    · exact Or.inr rfl
  · rintro (rfl | rfl) <;>
      exact ⟨by norm_num, fun j hj => by interval_cases j <;> norm_num [exCoeff]⟩

/-- At `x = −1/2` the monomials `0` and `2` tie, while the monomial `1` stays strictly
above: the fibre is `{0, 2}`, a corner of multiplicity `2` although its hull edge has
lattice length `2`. -/
theorem labnote_ex_fiber_neg_half : fiber 3 exCoeff (-(1/2)) = {0, 2} := by
  ext i
  simp only [mem_fiber_iff, Finset.mem_insert, Finset.mem_singleton]
  constructor
  · rintro ⟨hi, hmin⟩
    have h := hmin 0 (by norm_num)
    interval_cases i
    · exact Or.inl rfl
    · norm_num [exCoeff] at h
    · exact Or.inr rfl
    · norm_num [exCoeff] at h
  · rintro (rfl | rfl) <;>
      exact ⟨by norm_num, fun j hj => by interval_cases j <;> norm_num [exCoeff]⟩

/-- **Strictness data.**  The non-convex example has total multiplicity excess `2`,
strictly below its degree `3`: `multiplicity_sum_le` is an inequality, not an identity,
for coefficient vectors with an invisible monomial. -/
theorem labnote_ex_strict_degree_bound :
    ∑ x ∈ ({-6, -(1/2)} : Finset ℚ), ((fiber 3 exCoeff x).card - 1) = 2 ∧ (2 : ℕ) < 3 := by
  constructor
  · rw [Finset.sum_insert (by norm_num), Finset.sum_singleton,
      labnote_ex_fiber_neg_six, labnote_ex_fiber_neg_half]
    decide
  · norm_num

/-! ## Experiment COMP — a three-block composition of degree 6

The composition `6 = 2 + 1 + 3` is realised by the staircase polynomial of
`Compositions.lean`: its fibres at `x = 0, −1, −2` have cardinalities `3, 2, 4`, i.e.
multiplicity excesses `2, 1, 3`, which sum to the degree `6`. -/

/-- The block sizes of the composition `6 = 2 + 1 + 3`. -/
def compEx : ℕ → ℕ := fun j => if j = 0 then 2 else if j = 1 then 1 else 3

theorem labnote_compEx_blockSum : blockSum compEx 3 = 6 := by
  simp [blockSum, Finset.sum_range_succ, compEx]

/-- **Composition data.**  The three corners of the staircase polynomial of `(2,1,3)`
carry the prescribed multiplicities. -/
theorem labnote_composition_two_one_three :
    (fiber 6 (sumCoeff (blockIncr compEx 3)) (-(0 : ℚ))).card = 3 ∧
      (fiber 6 (sumCoeff (blockIncr compEx 3)) (-(1 : ℚ))).card = 2 ∧
        (fiber 6 (sumCoeff (blockIncr compEx 3)) (-(2 : ℚ))).card = 4 := by
  have h0 := composition_profile (m := compEx) (r := 3) (j := 0) (by omega)
  have h1 := composition_profile (m := compEx) (r := 3) (j := 1) (by omega)
  have h2 := composition_profile (m := compEx) (r := 3) (j := 2) (by omega)
  rw [labnote_compEx_blockSum] at h0 h1 h2
  exact ⟨by simpa [compEx] using h0, by simpa [compEx] using h1, by simpa [compEx] using h2⟩

end TropicalDependentFibers