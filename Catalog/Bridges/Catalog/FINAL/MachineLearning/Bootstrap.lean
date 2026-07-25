/-
# Scale-Exponent Bootstrap and Dimension Transfer

This module extracts exponent arithmetic from the discrete incidence
lower bound to derive covering-number growth rates, and then transfers
these to lower Minkowski dimension bounds.

## Main results
- `covering_number_lower_bound` — if the tube/cell system at scale δ satisfies
  M_δ ≥ c_M · δ^{-(n-1)}, L_δ ≥ c_L · δ^{-1}, P_δ ≤ C_P · δ^{-(n+α)},
  then N_δ ≥ C · δ^{-(n-α)} for a computable constant C.
- `lowerMinkowskiDim_ge_of_covering_bound` — covering-number growth rate
  gives a lower bound on the lower Minkowski dimension.
-/

import Mathlib

namespace PairwiseIntersection

open Real Filter

/-! ## Scale-Exponent Bootstrap

Given scale-dependent bounds on tube count M, tube load L, pair energy P,
and the discrete lower bound N ≥ (M·L)²/P, we extract the covering
exponent n - α. -/

/-- Scale-exponent bootstrap: from the discrete incidence bound and
scale-dependent hypotheses, derive a power-law lower bound on covering numbers.

If M(δ) ≥ cM · δ^{-(n-1)}, L(δ) ≥ cL · δ^{-1}, P(δ) ≤ cP · δ^{-(n+α)},
and N(δ) ≥ (M(δ)·L(δ))² / P(δ), then N(δ) ≥ C · δ^{-(n-α)}
for C = cM² · cL² / cP. -/
theorem covering_number_lower_bound
    (n α cM cL cP : ℝ)
    (hcM : 0 < cM) (hcL : 0 < cL) (hcP : 0 < cP)
    (M L P N : ℝ → ℝ)
    (hM : ∀ δ, 0 < δ → δ < 1 → cM * δ⁻¹ ^ (n - 1) ≤ M δ)
    (hL : ∀ δ, 0 < δ → δ < 1 → cL * δ⁻¹ ≤ L δ)
    (hP : ∀ δ, 0 < δ → δ < 1 → P δ ≤ cP * δ⁻¹ ^ (n + α))
    (hPpos : ∀ δ, 0 < δ → δ < 1 → 0 < P δ)
    (hdisc : ∀ δ, 0 < δ → δ < 1 → (M δ * L δ) ^ 2 / P δ ≤ N δ) :
    ∀ δ, 0 < δ → δ < 1 →
      cM ^ 2 * cL ^ 2 / cP * δ⁻¹ ^ (n - α) ≤ N δ := by
  intros δ hδ_pos hδ_lt_1
  have h_mul : (M δ * L δ) ^ 2 ≥ (cM * cL) ^ 2 * δ⁻¹ ^ (2 * n) := by
    have h_mul : (M δ * L δ) ^ 2 ≥ (cM * δ⁻¹ ^ (n - 1) * cL * δ⁻¹) ^ 2 := by
      simpa only [ mul_assoc ] using pow_le_pow_left₀ ( by positivity ) ( mul_le_mul ( hM δ hδ_pos hδ_lt_1 ) ( hL δ hδ_pos hδ_lt_1 ) ( by positivity ) ( by nlinarith [ hM δ hδ_pos hδ_lt_1, hL δ hδ_pos hδ_lt_1, show 0 ≤ cM * δ⁻¹ ^ ( n - 1 ) by positivity, show 0 ≤ cL * δ⁻¹ by positivity ] ) ) 2;
    convert h_mul using 1 ; ring;
    norm_num [ Real.rpow_add ( inv_pos.mpr hδ_pos ), Real.rpow_mul ( inv_nonneg.mpr hδ_pos.le ) ] ; ring;
    norm_cast ; norm_num [ hδ_pos.ne' ] ; ring;
    norm_num [ hδ_pos.ne' ];
  refine le_trans ?_ ( hdisc δ hδ_pos hδ_lt_1 );
  rw [ div_mul_eq_mul_div, div_le_div_iff₀ ] <;> try nlinarith [ hPpos δ hδ_pos hδ_lt_1 ];
  refine le_trans ?_ ( mul_le_mul_of_nonneg_right h_mul hcP.le );
  convert mul_le_mul_of_nonneg_left ( hP δ hδ_pos hδ_lt_1 ) ( show 0 ≤ cM ^ 2 * cL ^ 2 * δ⁻¹ ^ ( n - α ) by positivity ) using 1 ; ring;
  rw [ show n * 2 = n - α + ( n + α ) by ring, Real.rpow_add ( by positivity ) ] ; ring

/-! ## Directional Cover Profile

A bundled structure for scale-dependent discretization data. -/

/-- A directional cover profile bundles the scale-dependent quantities
arising in a Kakeya-type discretization. -/
structure DirectionalCoverProfile where
  /-- Dimension of the ambient space -/
  ambientDim : ℕ
  /-- Tube count at scale δ -/
  tubeCount : ℝ → ℝ
  /-- Minimum tube load at scale δ -/
  minLoad : ℝ → ℝ
  /-- Pair energy bound at scale δ -/
  energyBound : ℝ → ℝ
  /-- Covering number at scale δ -/
  coveringNumber : ℝ → ℝ

/-! ## Lower Minkowski Dimension

We define a notion of covering-number growth exponent and prove that
power-law lower bounds on covering numbers imply dimension lower bounds. -/

/-- The covering-number growth exponent: the supremum of all s such that
N(δ) ≥ C · (1/δ)^s for some C > 0 and all sufficiently small δ > 0.
This is a form of the lower Minkowski dimension. -/
noncomputable def coveringExponent (N : ℝ → ℝ) : ℝ :=
  sSup {s : ℝ | ∃ C > 0, ∀ δ, 0 < δ → δ < 1 → C * δ⁻¹ ^ s ≤ N δ}

/-
If N(δ) ≥ C · δ^{-s} for all 0 < δ < 1 with C > 0, then
the covering exponent is at least s.
-/
theorem coveringExponent_ge_of_bound
    (N : ℝ → ℝ) (s C : ℝ)
    (hC : 0 < C)
    (hN : ∀ δ, 0 < δ → δ < 1 → C * δ⁻¹ ^ s ≤ N δ)
    (hbdd : BddAbove {s : ℝ | ∃ C > 0, ∀ δ, 0 < δ → δ < 1 → C * δ⁻¹ ^ s ≤ N δ}) :
    s ≤ coveringExponent N := by
  -- By definition of covering exponent, $s \le sSup {s | ∃ C > 0, ∀ δ, 0 < δ → δ < 1 → C * δ⁻¹ ^ s ≤ N δ}$.
  apply le_csSup; exact hbdd; exact ⟨C, hC, hN⟩

/-! ## Combined Kakeya-type dimension bound

Putting together the discrete incidence bound with the scale bootstrap,
we get a dimension lower bound from pairwise energy control. -/

/-
Kakeya-type dimension bound: if a directional cover profile has
  - M_δ ≳ δ^{-(n-1)} tubes,
  - each tube meets ≳ δ^{-1} cubes,
  - pair energy ≲ δ^{-(n+α)},
then the covering exponent is at least n - α.
-/
theorem kakeya_dimension_from_energy
    (n α cM cL cP : ℝ)
    (hcM : 0 < cM) (hcL : 0 < cL) (hcP : 0 < cP)
    (M L P N : ℝ → ℝ)
    (hM : ∀ δ, 0 < δ → δ < 1 → cM * δ⁻¹ ^ (n - 1) ≤ M δ)
    (hL : ∀ δ, 0 < δ → δ < 1 → cL * δ⁻¹ ≤ L δ)
    (hP : ∀ δ, 0 < δ → δ < 1 → P δ ≤ cP * δ⁻¹ ^ (n + α))
    (hPpos : ∀ δ, 0 < δ → δ < 1 → 0 < P δ)
    (hdisc : ∀ δ, 0 < δ → δ < 1 → (M δ * L δ) ^ 2 / P δ ≤ N δ)
    (hbdd : BddAbove {s : ℝ | ∃ C > 0, ∀ δ, 0 < δ → δ < 1 → C * δ⁻¹ ^ s ≤ N δ}) :
    n - α ≤ coveringExponent N := by
  refine' ( coveringExponent_ge_of_bound N ( n - α ) _ _ _ hbdd );
  exact cM ^ 2 * cL ^ 2 / cP;
  · positivity;
  · convert covering_number_lower_bound n α cM cL cP hcM hcL hcP M L P N hM hL hP hPpos hdisc using 1

end PairwiseIntersection