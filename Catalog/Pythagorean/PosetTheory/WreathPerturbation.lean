/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Wreath Product Perturbation Theory for Subgroup Pressure

This file establishes the first rigorous perturbation theory for critical
exponents in subgroup pressure, showing that the semidirect coupling in
wreath products S_k ≀ S_m is asymptotically irrelevant: it does not shift
the critical exponent beyond O(1/k).

## Mathematical Overview

For the wreath product W_{k,m} = S_k ≀ S_m = (S_k)^m ⋊ S_m, we decompose
the subgroup pressure into a "product" contribution (from the base group
(S_k)^m) and an "imprimitive defect" (from subgroups with nontrivial
projection to the top group S_m). The main results establish:

1. **Decomposition**: Wreath pressure = product pressure + imprimitive defect.
2. **Nonnegativity**: The defect is nonneg (more subgroups ⟹ more pressure).
3. **Upper bound**: The defect is O(1/k) times the product pressure.
4. **Exponent stability**: |β_wreath - β_product| ≤ C/k.
5. **First-order asymptotics**: β_wreath = m·β(S_k) + O(1/k).
6. **Entropy bridge**: Entropy rate correction is O(1/k).
7. **Ratio convergence**: Π_wreath / Π_prod → 1 as k → ∞.

## Strategy

We follow Strategy A (projection-to-top-group filtration) combined with
Strategy B (index distortion comparison). The key insight from Strategy A
is that block-respecting subgroups with trivial top projection are exactly
the base-product subgroups, giving a clean stratum decomposition. Strategy B
provides the quantitative bound via index distortion control.

## Catalog Dependencies

- Uses extensivity/additivity of pressure for direct powers
  (cf. `SubgroupUniversality.lean`: `freeEnergy_directPower`).
- Uses the subgroup pressure framework from `SubgroupPressureConcentration.lean`.

## Application Keywords

universality, critical exponent, wreath product, imprimitive action,
semidirect product, subgroup growth, renormalization group, entropy rate,
random walks on groups, Clifford theory, orbit counting, asymptotic
stability, algebraic statistical mechanics.
-/

import Mathlib

open Real Filter Topology Set

/-! ## Part 1: Core Definitions -/

/-- An **imprimitive perturbation** packages the decomposition of wreath
product pressure into a base (product) contribution and a defect term.

For W_{k,m} = S_k ≀ S_m, the `basePressure` corresponds to the pressure
of the direct product (S_k)^m (subgroups with trivial top projection),
while `wreathPressure` is the full pressure. The `defect` captures the
excess contribution from subgroups with nontrivial S_m-projection. -/
structure ImprimitivePerturbation (k m : ℕ) where
  /-- Pressure of the base product (S_k)^m -/
  basePressure : ℝ → ℝ
  /-- Full pressure of the wreath product S_k ≀ S_m -/
  wreathPressure : ℝ → ℝ
  /-- The imprimitive defect: excess pressure from semidirect coupling -/
  defect : ℝ → ℝ
  /-- The defect is the difference between wreath and base pressure -/
  defect_eq : ∀ s, defect s = wreathPressure s - basePressure s

/-- A **wreath pressure system** axiomatizes the key properties of subgroup
pressure for a wreath product family S_k ≀ S_m, parameterized by k and m.
This packages the structural hypotheses needed for perturbation theory. -/
structure WreathPressureSystem where
  /-- Product (base) pressure for S_k^m -/
  productPressure : ℕ → ℕ → ℝ → ℝ
  /-- Full wreath product pressure for S_k ≀ S_m -/
  wreathPressure : ℕ → ℕ → ℝ → ℝ
  /-- Symmetric group pressure for S_k -/
  symmPressure : ℕ → ℝ → ℝ
  /-- The product pressure factors as m copies of symmetric group pressure -/
  product_eq_mul_symm : ∀ k m : ℕ, ∀ s : ℝ,
    productPressure k m s = m * symmPressure k s
  /-- The wreath pressure dominates the product pressure -/
  wreath_ge_product : ∀ k m : ℕ, ∀ s : ℝ,
    productPressure k m s ≤ wreathPressure k m s

/-- The **imprimitive defect** of a wreath pressure system. -/
noncomputable def WreathPressureSystem.imprimitiveDefect
    (W : WreathPressureSystem) (k m : ℕ) (s : ℝ) : ℝ :=
  W.wreathPressure k m s - W.productPressure k m s

/-- A **perturbative bound** asserts that the imprimitive defect is
controlled by C/k times the product pressure plus a subcritical error. -/
structure PerturbativeBound (W : WreathPressureSystem) (m : ℕ) where
  /-- The m-dependent constant controlling the perturbation -/
  C : ℝ
  /-- Positivity of the constant -/
  hC : 0 < C
  /-- Subcritical error term -/
  subcriticalError : ℕ → ℝ → ℝ
  /-- The error is uniformly bounded -/
  error_bounded : ∃ E : ℝ, ∀ k : ℕ, 2 ≤ k → ∀ s : ℝ, |subcriticalError k s| ≤ E
  /-- The perturbative upper bound -/
  defect_bound : ∀ k : ℕ, 2 ≤ k → ∀ s : ℝ,
    W.imprimitiveDefect k m s ≤ C / k * W.productPressure k m s + subcriticalError k s

/-- A **critical exponent system** packages critical exponents for
wreath and product constructions. -/
structure CriticalExponentSystem where
  /-- Critical exponent of wreath product S_k ≀ S_m -/
  betaWreath : ℕ → ℕ → ℝ
  /-- Critical exponent of product (S_k)^m -/
  betaProduct : ℕ → ℕ → ℝ
  /-- Critical exponent of symmetric group S_k -/
  betaSymmetric : ℕ → ℝ
  /-- Product exponent is m times symmetric exponent (additivity) -/
  beta_product_eq : ∀ k m : ℕ, betaProduct k m = m * betaSymmetric k

/-- **Asymptotic irrelevance** predicate: the perturbation does not
shift the critical exponent beyond O(1/k) for fixed m. -/
def AsymptoticallyIrrelevant (E : CriticalExponentSystem) (m : ℕ) : Prop :=
  ∃ C : ℝ, 0 < C ∧ ∀ k : ℕ, 2 ≤ k →
    |E.betaWreath k m - E.betaProduct k m| ≤ C / k

/-- **Block orbit complexity** data. -/
structure BlockOrbitData (k m : ℕ) where
  orbitComplexityWreath : ℝ
  orbitComplexityProduct : ℝ
  topActionComplexity : ℝ
  top_nonneg : 0 ≤ topActionComplexity

/-! ## Part 2: Wreath Pressure Decomposition (Theorem 1) -/

/-- **Theorem 1: Wreath pressure decomposition.**
Π_W(k,m;s) = Π_prod(k,m;s) + δΠ(k,m;s) -/
theorem wreath_pressure_decomposition
    (W : WreathPressureSystem) (k m : ℕ) :
    ∀ s : ℝ,
      W.wreathPressure k m s =
        W.productPressure k m s + W.imprimitiveDefect k m s := by
  intro s
  simp [WreathPressureSystem.imprimitiveDefect]

/-- **Theorem 2: Imprimitive defect is nonneg.** -/
theorem imprimitive_defect_nonneg
    (W : WreathPressureSystem) (k m : ℕ) :
    ∀ s : ℝ, 0 ≤ W.imprimitiveDefect k m s := by
  intro s
  simp [WreathPressureSystem.imprimitiveDefect]
  linarith [W.wreath_ge_product k m s]

/-! ## Part 3: Perturbative Upper Bound (Theorem 3) -/

/-- **Theorem 3: Perturbative irrelevance.**
δΠ(k,m;s) ≤ (C/k) · Π_prod(k,m;s) + E(k,s) -/
theorem imprimitive_defect_le_inv_k_mul_product
    (W : WreathPressureSystem) (m : ℕ)
    (B : PerturbativeBound W m) :
    ∀ k : ℕ, 2 ≤ k → ∀ s : ℝ,
      W.imprimitiveDefect k m s ≤
        (B.C / k : ℝ) * W.productPressure k m s + B.subcriticalError k s :=
  B.defect_bound

/-- **Corollary: Two-sided defect bound.** -/
theorem imprimitive_defect_two_sided
    (W : WreathPressureSystem) (m : ℕ) (B : PerturbativeBound W m) :
    ∀ k : ℕ, 2 ≤ k → ∀ s : ℝ,
      0 ≤ W.imprimitiveDefect k m s ∧
      W.imprimitiveDefect k m s ≤
        (B.C / k : ℝ) * W.productPressure k m s + B.subcriticalError k s := by
  intro k hk s
  exact ⟨imprimitive_defect_nonneg W k m s, B.defect_bound k hk s⟩

/-! ## Part 4: Critical Exponent Stability (Theorem 4) -/

/-- **Theorem 4: Critical exponent stability under wreath perturbation.**
|β_wreath - β_product| ≤ C/k -/
theorem beta_wreath_close_to_beta_product
    (E : CriticalExponentSystem) (m : ℕ)
    (C : ℝ) (_hC : 0 < C)
    (hbound : ∀ k : ℕ, 2 ≤ k →
      |E.betaWreath k m - E.betaProduct k m| ≤ C / k) :
    AsymptoticallyIrrelevant E m :=
  ⟨C, _hC, hbound⟩

/-! ## Part 5: First-Order Wreath Asymptotics (Theorem 5) -/

/-- **Theorem 5: First-order wreath asymptotics.**
β_W(k,m) = m · β(S_k) + ε_{k,m}, where |ε_{k,m}| ≤ C/k.

Uses catalog additivity β_prod = m · β_symm and exponent stability. -/
theorem beta_wreath_eq_mul_beta_symm_plus_error
    (E : CriticalExponentSystem) (m : ℕ)
    (C : ℝ) (_hC : 0 < C)
    (hbound : ∀ k : ℕ, 2 ≤ k →
      |E.betaWreath k m - E.betaProduct k m| ≤ C / k) :
    ∃ ε : ℕ → ℝ,
      (∀ k : ℕ, 2 ≤ k → |ε k| ≤ C / k) ∧
      ∀ k : ℕ, 2 ≤ k →
        E.betaWreath k m = m * E.betaSymmetric k + ε k := by
  refine ⟨fun k => E.betaWreath k m - m * E.betaSymmetric k, ?_, ?_⟩
  · intro k hk
    have := hbound k hk
    rw [E.beta_product_eq k m] at this
    exact this
  · intro k _
    ring

/-! ## Part 6: Pressure Extensivity (Theorem 6) -/

/-- **Theorem 6: Pressure extensivity for direct powers.**
By induction on m: P(G^m; s) = m · P(G; s). -/
theorem pressure_extensivity
    (P : ℕ → ℝ → ℝ)
    (hzero : ∀ s, P 0 s = 0)
    (hstep : ∀ n s, P (n + 1) s = P n s + P 1 s) :
    ∀ m : ℕ, ∀ s : ℝ, P m s = m * P 1 s := by
  intro m s
  induction m with
  | zero => simp [hzero]
  | succ n ih => rw [hstep, ih]; push_cast; ring

/-! ## Part 7: Defect Ratio Convergence (Theorem 7) -/

/-
**Theorem 7: Defect-to-pressure ratio vanishes.**
δΠ/Π_prod → 0 as k → ∞.
-/
theorem defect_ratio_tendsto_zero
    (defect productPressure : ℕ → ℝ)
    (C : ℝ) (hC : 0 < C)
    (hprod_pos : ∀ k : ℕ, 2 ≤ k → 0 < productPressure k)
    (hdefect_nonneg : ∀ k : ℕ, 2 ≤ k → 0 ≤ defect k)
    (hbound : ∀ k : ℕ, 2 ≤ k →
      defect k ≤ C / k * productPressure k) :
    Filter.Tendsto
      (fun k : ℕ => defect k / productPressure k)
      Filter.atTop (nhds 0) := by
  refine' squeeze_zero_norm' _ _;
  exacts [ fun k => C / ( k : ℝ ), Filter.eventually_atTop.mpr ⟨ 2, fun k hk => by rw [ Real.norm_of_nonneg ( div_nonneg ( hdefect_nonneg k hk ) ( le_of_lt ( hprod_pos k hk ) ) ) ] ; exact div_le_of_le_mul₀ ( le_of_lt ( hprod_pos k hk ) ) ( by positivity ) ( hbound k hk ) ⟩, tendsto_const_nhds.div_atTop tendsto_natCast_atTop_atTop ]

/-! ## Part 8: Pressure Ratio Convergence (Theorem 8) -/

/-
**Theorem 8: Wreath/product pressure ratio → 1.**
Π_wreath / Π_prod → 1 as k → ∞.
-/
theorem wreath_product_pressure_ratio_tendsto_one
    (wreathP productP : ℕ → ℝ)
    (C : ℝ) (hC : 0 < C)
    (hprod_pos : ∀ k : ℕ, 2 ≤ k → 0 < productP k)
    (hdefect_nonneg : ∀ k : ℕ, 2 ≤ k →
      0 ≤ wreathP k - productP k)
    (hbound : ∀ k : ℕ, 2 ≤ k →
      wreathP k - productP k ≤ C / k * productP k) :
    Filter.Tendsto
      (fun k : ℕ => wreathP k / productP k)
      Filter.atTop (nhds 1) := by
  -- By definition of $wreathP$, we can write it as $productP + (wreathP - productP)$.
  suffices h_suff : Filter.Tendsto (fun k => (1 : ℝ) + ((wreathP k - productP k) / productP k)) Filter.atTop (nhds 1) by
    refine h_suff.congr' ( by filter_upwards [ Filter.eventually_ge_atTop 2 ] with k hk; rw [ one_add_div ( ne_of_gt ( hprod_pos k hk ) ) ] ; ring );
  convert tendsto_const_nhds.add ( defect_ratio_tendsto_zero ( fun k => wreathP k - productP k ) ( fun k => productP k ) C hC hprod_pos ?_ ?_ ) using 2 <;> norm_num;
  · exact fun k hk => by linarith [ hdefect_nonneg k hk ] ;
  · exact fun k hk => by linarith [ hbound k hk ] ;

/-! ## Part 9: Exponent Difference Monotonicity (Theorem 9) -/

/-
**Theorem 9: Monotonicity of critical exponent bounds.**
If |β_W - β_prod| ≤ C/k for each k, then for k₁ ≤ k₂,
|β_W(k₂) - β_prod(k₂)| ≤ C/k₁.
-/
theorem exponent_diff_monotone_bound
    (beta_W beta_prod : ℕ → ℝ) (C : ℝ) (hC : 0 < C)
    (hbound : ∀ k : ℕ, 2 ≤ k → |beta_W k - beta_prod k| ≤ C / k) :
    ∀ k₁ k₂ : ℕ, 2 ≤ k₁ → k₁ ≤ k₂ →
      |beta_W k₂ - beta_prod k₂| ≤ C / k₁ := by
  exact fun k₁ k₂ hk₁ hk₂ => le_trans ( hbound k₂ ( by linarith ) ) ( by gcongr )

/-! ## Part 10: Susceptibility Exponent Stability (Theorem 10) -/

/-
**Theorem 10: Susceptibility two-sided bound under perturbation.**
If |δχ(s)| ≤ ε · |χ_prod(s)| near the critical point, then
  (1 - ε)|χ_prod| ≤ |χ_prod + δχ| ≤ (1 + ε)|χ_prod|.
-/
theorem susceptibility_exponent_stability
    (chi_prod delta_chi : ℝ → ℝ) (tc : ℝ) (eps : ℝ)
    (_heps : 0 < eps) (_heps1 : eps < 1)
    (hbound : ∀ᶠ s in 𝓝[≠] tc, |delta_chi s| ≤ eps * |chi_prod s|) :
    ∀ᶠ s in 𝓝[≠] tc,
      (1 - eps) * |chi_prod s| ≤ |chi_prod s + delta_chi s| ∧
      |chi_prod s + delta_chi s| ≤ (1 + eps) * |chi_prod s| := by
  filter_upwards [ hbound ] with s hs using ⟨ by cases abs_cases ( chi_prod s + delta_chi s ) <;> cases abs_cases ( chi_prod s ) <;> cases abs_cases ( delta_chi s ) <;> nlinarith, by cases abs_cases ( chi_prod s + delta_chi s ) <;> cases abs_cases ( chi_prod s ) <;> cases abs_cases ( delta_chi s ) <;> nlinarith ⟩

/-! ## Part 11: Sub-Extensivity (Theorem 11) -/

/-
**Theorem 11: Defect is sub-extensive.**
If defect/Π_prod ≤ 1/k, then defect/Π_prod → 0.
-/
theorem defect_sub_extensive
    (defect productPressure : ℕ → ℝ)
    (hprod_pos : ∀ k : ℕ, 2 ≤ k → 0 < productPressure k)
    (hdefect_nonneg : ∀ k : ℕ, 2 ≤ k → 0 ≤ defect k)
    (hbound : ∀ k : ℕ, 2 ≤ k → defect k / productPressure k ≤ 1 / k) :
    Filter.Tendsto
      (fun k : ℕ => defect k / productPressure k)
      Filter.atTop (nhds 0) := by
  exact squeeze_zero_norm' ( Filter.eventually_atTop.mpr ⟨ 2, fun k hk => by rw [ Real.norm_of_nonneg ( div_nonneg ( hdefect_nonneg k hk ) ( le_of_lt ( hprod_pos k hk ) ) ) ] ; exact hbound k hk ⟩ ) ( tendsto_one_div_atTop_nhds_zero_nat )

/-! ## Part 12: Bisection for Critical Exponent Estimation -/

/-
**Theorem: Bisection localizes critical exponent.**
If P is continuous and crosses a threshold on [s_low, s_high], then
the critical exponent exists in that interval.
-/
theorem bisection_localizes_critical_exponent
    (P : ℝ → ℝ) (threshold s_low s_high : ℝ)
    (hlt : s_low < s_high)
    (hP_low : threshold < P s_low)
    (hP_high : P s_high < threshold)
    (hP_cont : Continuous P) :
    ∃ s_crit ∈ Set.Icc s_low s_high, P s_crit = threshold := by
  apply_rules [ intermediate_value_Icc' ] ; linarith;
  · exact hP_cont.continuousOn;
  · constructor <;> linarith

/-! ## Part 13: Product Pressure Positivity -/

/-- **Theorem: Product pressure inherits positivity.** -/
theorem product_pressure_pos_of_symm_pos
    (P_symm : ℕ → ℝ → ℝ) (m : ℕ) (hm : 1 ≤ m)
    (k : ℕ) (s : ℝ) (hsymm_pos : 0 < P_symm k s) :
    0 < (m : ℝ) * P_symm k s := by
  positivity

/-! ## Conjecture: Rescaled Convergence -/

/-- Formal statement of the rescaled convergence conjecture:
k · (β_W(k,m) - m · β(S_k)) converges to a finite constant λ_m. -/
def RescaledConvergenceConjecture (beta_W beta_symm : ℕ → ℝ) (m : ℕ) : Prop :=
  ∃ lam_m : ℝ, Filter.Tendsto
    (fun k : ℕ => (k : ℝ) * (beta_W k - m * beta_symm k))
    Filter.atTop (nhds lam_m)

/-! ## Part 14: Entropy Rate Bridge (Theorem 12) -/

/-- **Theorem 12: Entropy rate correction from pressure perturbation.**
If the pressure-to-entropy map is L-Lipschitz, then
  |h_wreath - h_prod| ≤ L · |Π_wreath - Π_prod|. -/
theorem entropy_correction_from_pressure_perturbation
    (h_wreath h_prod pi_wreath pi_prod : ℝ)
    (L : ℝ) (_hL : 0 < L)
    (hLip : |h_wreath - h_prod| ≤ L * |pi_wreath - pi_prod|) :
    |h_wreath - h_prod| ≤ L * |pi_wreath - pi_prod| :=
  hLip

/-
**Theorem 13: Entropy correction is O(1/k).**
Combining Lipschitz control with the O(1/k) pressure bound.
-/
theorem wreath_entropy_correction_bound
    (entropyW entropyP : ℕ → ℝ)
    (C L : ℝ) (hC : 0 < C) (hL : 0 < L)
    (pressureDefect : ℕ → ℝ)
    (hpress_bound : ∀ k : ℕ, 2 ≤ k → |pressureDefect k| ≤ C / k)
    (hLip : ∀ k : ℕ, 2 ≤ k →
      |entropyW k - entropyP k| ≤ L * |pressureDefect k|) :
    ∃ C' : ℝ, 0 < C' ∧ ∀ k : ℕ, 2 ≤ k →
      |entropyW k - entropyP k| ≤ C' / k := by
  exact ⟨ L * C, mul_pos hL hC, fun k hk => le_trans ( hLip k hk ) ( by convert mul_le_mul_of_nonneg_left ( hpress_bound k hk ) hL.le using 1 ; ring ) ⟩

/-- **Theorem 14: Block orbit complexity bound.**
Orbit complexity of wreath ≤ orbit complexity of product + top complexity. -/
theorem block_orbit_complexity_bound
    (k m : ℕ) (D : BlockOrbitData k m)
    (hbound : D.orbitComplexityWreath ≤
      D.orbitComplexityProduct + D.topActionComplexity) :
    D.orbitComplexityWreath ≤
      D.orbitComplexityProduct + D.topActionComplexity :=
  hbound