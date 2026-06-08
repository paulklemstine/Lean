import Mathlib
import Speculative.RiemannHypothesis.Defs

/-!
# RH Equivalence Theorems

We prove purely logical equivalences between different formulations of the
Riemann Hypothesis predicate `RHFor ζ`. These are not deep analytically,
but they create the **formal interface layer** needed for composing future
RH-adjacent theorems.

## Main Results

- `rhfor_iff_no_offline_zero`: RH ↔ no nontrivial zero is off the critical line
- `rhfor_iff_abs_re_eq_zero`: RH ↔ `|Re(s) - 1/2| = 0` for all nontrivial zeros
- `rhfor_iff_re_ge_and_le`: RH ↔ `Re(s) ≥ 1/2 ∧ Re(s) ≤ 1/2` for nontrivial zeros
- `rhfor_contrapositive`: off critical line → not a nontrivial zero
- `rhfor_of_subset_zeros`: RH is monotone in zero sets
-/

namespace RH

/-
RH is equivalent to: every nontrivial zero that is *not* on the critical line
    leads to a contradiction.
-/
theorem rhfor_iff_no_offline_zero (ζ : ℂ → ℂ) :
    RHFor ζ ↔ ∀ s : ℂ, IsNontrivialZero ζ s → s.re ≠ (1 : ℝ) / 2 → False := by
  simp +decide [ RHFor, OnCriticalLine ]

/-
RH is equivalent to: `|Re(s) - 1/2| = 0` for every nontrivial zero.
-/
theorem rhfor_iff_abs_re_eq_zero (ζ : ℂ → ℂ) :
    RHFor ζ ↔ ∀ s : ℂ, IsNontrivialZero ζ s → |s.re - (1 : ℝ) / 2| = 0 := by
  simp +decide only [abs_eq_zero, sub_eq_zero];
  rfl

/-
RH is equivalent to the conjunction `Re(s) ≥ 1/2 ∧ Re(s) ≤ 1/2` for
    every nontrivial zero.
-/
theorem rhfor_iff_re_ge_and_le (ζ : ℂ → ℂ) :
    RHFor ζ ↔ ∀ s : ℂ, IsNontrivialZero ζ s → s.re ≥ 1/2 ∧ s.re ≤ 1/2 := by
  -- First, let's unfold `RHFor ζ` and `OnCriticalLine ζ`. It's enough to show the equivalence for `OnCriticalLine`, since `RHFor` is formally equivalent to `IsNontrivialZero ζ s → OnCriticalLine s` being equivalent to `IsNontrivialZero ζ s → s.re = 1 / 2`.
  unfold RH.RHFor RH.OnCriticalLine;
  grind +qlia

/-
Contrapositive of RH: if `s` is off the critical line, it is not a
    nontrivial zero.
-/
theorem rhfor_contrapositive (ζ : ℂ → ℂ) (hRH : RHFor ζ) (s : ℂ)
    (hoff : s.re ≠ (1 : ℝ) / 2) : ¬ IsNontrivialZero ζ s := by
  exact fun h => hoff <| hRH s h

/-
If RH holds for `ζ`, then every nontrivial zero has `Re(s) = 1 - Re(s)`,
    i.e. the real part is symmetric about `1/2`.
-/
theorem rhfor_re_symmetric (ζ : ℂ → ℂ) (hRH : RHFor ζ) (s : ℂ)
    (hs : IsNontrivialZero ζ s) : s.re = 1 - s.re := by
  linarith [ hRH s hs, show s.re = 1 / 2 from hRH s hs ]

/-
RH is monotone in `ζ`-restrictions: if `RHFor ζ` and every nontrivial zero
    of `ζ'` is also a nontrivial zero of `ζ`, then `RHFor ζ'`.
-/
theorem rhfor_of_subset_zeros (ζ ζ' : ℂ → ℂ) (hRH : RHFor ζ)
    (hsub : ∀ s, IsNontrivialZero ζ' s → IsNontrivialZero ζ s) :
    RHFor ζ' := by
  exact fun s hs => hRH s ( hsub s hs )

end RH