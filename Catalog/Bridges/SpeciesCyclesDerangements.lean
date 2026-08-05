/-
# Derangements are sets of long cycles

A permutation without fixed points is exactly a permutation all of whose cycles have
length at least two, i.e. a *set of cycles of length ≥ 2*.  In the language of species,

    D ≅ E ∘ C₂,

where `C₂` is the species of cyclic structures on sets with at least two elements.

This file introduces `C₂ = Species.cycGe2`, computes its exponential generating series
(`egf C₂ = egf C - X`), and deduces the counting form of the above isomorphism,

    |(E ∘ C₂)[n]| = numDerangements n,

from the exponential formula: both sides have exponential generating series solving the
same linear differential equation `A′ · (1 - X) = X · A` with `A(0) = 1`.
-/
import Bridges.SpeciesExponentialFormula
import Bridges.SpeciesDerangements

noncomputable section

namespace SpeciesEGF

open scoped BigOperators
open PowerSeries

namespace Species

/-! ## The species of cycles of length at least two -/

/-- The species `C₂` of cyclic structures on sets with at least two elements. -/
def cycGe2 : Species where
  obj A := {x : cyc.obj A // 2 ≤ Nat.card A}
  map e x := ⟨cyc.map e x.1, by rw [← Nat.card_congr e]; exact x.2⟩
  map_refl x := Subtype.ext (cyc.map_refl x.1)
  map_trans e f x := Subtype.ext (cyc.map_trans e f x.1)
  finite A _ := Subtype.finite

@[simp] theorem card_cycGe2 (n : ℕ) :
    cycGe2.card n = if 2 ≤ n then (n - 1).factorial else 0 := by
  by_cases hn : 2 ≤ n
  · have hcard : 2 ≤ Nat.card (Fin n) := by simpa using hn
    have : cycGe2.obj (Fin n) ≃ cyc.obj (Fin n) :=
      { toFun := fun x => x.1
        invFun := fun x => ⟨x, hcard⟩
        left_inv := fun _ => rfl
        right_inv := fun _ => rfl }
    rw [if_pos hn, card, Nat.card_congr this, ← card, card_cyc (by omega)]
  · have hcard : ¬ 2 ≤ Nat.card (Fin n) := by simpa using hn
    have : IsEmpty (cycGe2.obj (Fin n)) := ⟨fun x => hcard x.2⟩
    rw [if_neg hn, card]
    simp

/-- Removing the cycles of length one from the species of cycles removes the linear term
of its exponential generating series. -/
theorem egf_cycGe2 : cycGe2.egf = cyc.egf - PowerSeries.X := by
  ext n
  rw [map_sub, coeff_egf, coeff_egf, card_cycGe2, PowerSeries.coeff_X]
  match n with
  | 0 => simp
  | 1 => simp
  | (m + 2) =>
      rw [if_pos (by omega), if_neg (by omega), card_cyc (by omega)]
      simp

/-! ## The differential equation satisfied by the two series -/

/-- The Leibniz rule for the formal derivative, in product form. -/
theorem derivative_mul' (f g : ℚ⟦X⟧) : d⁄dX ℚ (f * g) = f * d⁄dX ℚ g + g * d⁄dX ℚ f := by
  simp [smul_eq_mul]

/-- The exponential generating series of derangements satisfies `D′ · (1 - X) = X · D`. -/
theorem deriv_egf_derang :
    d⁄dX ℚ derang.egf * (1 - PowerSeries.X) = PowerSeries.X * derang.egf := by
  set D := derang.egf with hD
  set u := PowerSeries.exp ℚ with hu
  have hus : D * u * (1 - PowerSeries.X) = 1 := egf_derang_mul_exp_mul
  have hd : d⁄dX ℚ (D * u * (1 - PowerSeries.X)) = 0 := by rw [hus]; simp
  have hexp : d⁄dX ℚ u = u := by rw [hu]; exact PowerSeries.derivative_exp ℚ
  rw [derivative_mul', derivative_mul'] at hd
  have hone : d⁄dX ℚ (1 - PowerSeries.X : ℚ⟦X⟧) = -1 := by simp
  rw [hone, hexp] at hd
  have hne : u ≠ 0 := by
    intro h
    have hc : PowerSeries.constantCoeff u = 0 := by rw [h]; simp
    rw [hu] at hc
    simp at hc
  refine mul_right_cancel₀ hne ?_
  linear_combination hd

/-- The exponential generating series of `E ∘ C₂` satisfies the same differential
equation `A′ · (1 - X) = X · A`. -/
theorem deriv_egf_comp_set_cycGe2 :
    d⁄dX ℚ (set.comp cycGe2).egf * (1 - PowerSeries.X)
      = PowerSeries.X * (set.comp cycGe2).egf := by
  set A := (set.comp cycGe2).egf with hA
  have h1 : d⁄dX ℚ A = d⁄dX ℚ cycGe2.egf * A := deriv_egf_comp_set cycGe2
  have h2 : d⁄dX ℚ cycGe2.egf = d⁄dX ℚ cyc.egf - 1 := by
    rw [egf_cycGe2, map_sub, PowerSeries.derivative_X]
  have h3 : d⁄dX ℚ cyc.egf * (1 - PowerSeries.X) = 1 := deriv_egf_cyc
  rw [h1, h2]
  linear_combination A * h3

/-! ## Derangements as sets of long cycles -/

/-- **`E ∘ C₂` and `D` have the same exponential generating series.** -/
theorem egf_comp_set_cycGe2 : (set.comp cycGe2).egf = derang.egf := by
  have hu : PowerSeries.constantCoeff (1 - PowerSeries.X : ℚ⟦X⟧) ≠ 0 := by simp
  refine eq_of_derivative_mul_eq hu deriv_egf_comp_set_cycGe2 deriv_egf_derang ?_
  rw [coeff_zero_egf_comp_set, coeff_egf, card_derang]
  simp

/-- **Derangements are sets of cycles of length at least two**, in counting form. -/
theorem card_comp_set_cycGe2 (n : ℕ) : (set.comp cycGe2).card n = numDerangements n := by
  have h := (egf_eq_iff (set.comp cycGe2) derang).1 egf_comp_set_cycGe2 n
  rwa [card_derang] at h

/-- The number of partitions of an `n`-set into blocks of size at least two, each carrying
a cyclic order, is the number of derangements: an alternative form of the previous
theorem via the composition counting formula. -/
theorem sum_blocking_prod_cycGe2 (n : ℕ) :
    ∑ p : Blocking (Fin n), ∏ c : p.Block, cycGe2.card (Nat.card c.elems)
      = numDerangements n := by
  have h := card_comp set cycGe2 n
  rw [card_comp_set_cycGe2] at h
  simpa using h.symm

end Species

end SpeciesEGF