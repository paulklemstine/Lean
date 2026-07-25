/-
# A counterexample to an overstrong tropical Hodge conjecture

The Hodge decomposition applies to closed forms (or, in its three-summand
version, includes a coexact term).  The tempting claim that every form is
`exact + harmonic` is false, already for a two-dimensional cochain complex.
-/

import Mathlib

noncomputable section

namespace TropicalHodge.Contrarian

/-- The preceding coboundary includes a scalar as the first coordinate. -/
def counterDPrev : ℝ →ₗ[ℝ] (Fin 2 → ℝ) where
  toFun a := fun i => if i = 0 then a else 0
  map_add' a b := by
    ext i
    simp only [Pi.add_apply]
    split_ifs <;> ring
  map_smul' a b := by
    ext i
    simp only [Pi.smul_apply, smul_eq_mul]
    split_ifs <;> simp_all

/-- The following coboundary reads the second coordinate. -/
def counterDNext : (Fin 2 → ℝ) →ₗ[ℝ] ℝ where
  toFun x := x 1
  map_add' _ _ := rfl
  map_smul' _ _ := rfl

/-- This is a genuine cochain complex: consecutive coboundaries compose to zero. -/
theorem counter_complex : counterDNext.comp counterDPrev = 0 := by
  ext
  simp [counterDNext, counterDPrev]

/-- In standard coordinates, harmonic means closed and orthogonal to the first axis. -/
def CounterHarmonic (h : Fin 2 → ℝ) : Prop := counterDNext h = 0 ∧ h 0 = 0

/-- The form concentrated in the second coordinate is not closed. -/
def nonClosedForm : Fin 2 → ℝ := fun i => if i = 1 then 1 else 0

theorem nonClosedForm_not_closed : counterDNext nonClosedForm ≠ 0 := by
  norm_num [counterDNext, nonClosedForm]

/-- In this example the only harmonic form is zero. -/
theorem counter_harmonic_eq_zero (h : Fin 2 → ℝ) (hh : CounterHarmonic h) : h = 0 := by
  have h1 : h 1 = 0 := hh.1
  funext i
  fin_cases i <;> simp [hh.2, h1]

/--
**Disproof of the naive two-summand conjecture.**  It is not true that every
cochain is exact plus harmonic.  The missing part is the coexact summand.
-/
theorem not_every_form_exact_plus_harmonic :
    ¬ ∀ x : Fin 2 → ℝ, ∃ exact harmonic : Fin 2 → ℝ,
      exact ∈ counterDPrev.range ∧ CounterHarmonic harmonic ∧
      x = exact + harmonic := by
  intro hall
  obtain ⟨exact, harmonic, hexact, hharmonic, hsum⟩ := hall nonClosedForm
  have hhzero : harmonic = 0 := counter_harmonic_eq_zero harmonic hharmonic
  obtain ⟨a, rfl⟩ := hexact
  have at_one := congr_fun hsum 1
  norm_num [nonClosedForm, counterDPrev, hhzero] at at_one

end TropicalHodge.Contrarian