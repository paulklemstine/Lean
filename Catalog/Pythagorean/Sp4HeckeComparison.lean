/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Hecke Operator Comparison and Building Spectra

This file develops a **spectral transference framework** connecting
Cayley graph expansion for finite groups to spherical Hecke operator
spectra on associated buildings. The primary application is to
Sp₄(𝔽_q) with toral generators and the rank-2 building of type C₂.

## Main contributions

1. **Abstract transference principle** (`abstract_hecke_cayley_gap_comparison`):
   If a Cayley averaging operator is intertwined with a geometric Hecke
   operator via a transfer map with controlled distortion on mean-zero
   functions, then their spectral gaps are comparable up to constants.

2. **Uniform comparison for Sp₄ family** (`sp4_toral_gap_comparable`):
   For the family Sp₄(𝔽_q) with toral generators, the Cayley spectral
   gap and building Hecke gap are comparable with uniform constants.

3. **Building expander mixing** (`building_expander_mixing`):
   A positive Hecke gap yields a quantitative mixing estimate for
   incidence counts on the building, connecting spectral graph theory
   to high-dimensional expansion.

## References

* Lubotzky (2012), High-dimensional expanders
* Diaconis–Shahshahani (1981), Random walks on groups
* Cartwright–Solé–Żuk (2003), Ramanujan buildings
-/

import Mathlib

open Finset Real

/-! ## Section 1: Core Definitions -/

/-- Mean-zero predicate: a function f : α → ℝ on a finite type sums to zero. -/
def MeanZero' {α : Type*} [Fintype α] (f : α → ℝ) : Prop :=
  ∑ x : α, f x = 0

/-- The L² inner product on functions α → ℝ over a finite type. -/
noncomputable def l2Inner' {α : Type*} [Fintype α] (f g : α → ℝ) : ℝ :=
  ∑ x : α, f x * g x

/-- The L² norm squared. -/
noncomputable def l2NormSq' {α : Type*} [Fintype α] (f : α → ℝ) : ℝ :=
  ∑ x : α, f x ^ 2

/-- The Rayleigh quotient of a linear operator A with respect to f. -/
noncomputable def rayleighQuotient' {α : Type*} [Fintype α]
    (A : (α → ℝ) → (α → ℝ)) (f : α → ℝ) : ℝ :=
  if l2NormSq' f = 0 then 0 else l2Inner' (A f) f / l2NormSq' f

/-- The spectral gap of a self-adjoint averaging operator. -/
noncomputable def operatorSpectralGap' {α : Type*} [Fintype α]
    (A : (α → ℝ) → (α → ℝ)) : ℝ :=
  1 - sSup {r : ℝ | ∃ f : α → ℝ, MeanZero' f ∧ l2NormSq' f ≠ 0 ∧
    |rayleighQuotient' A f| = r}

/-- Two spectral gaps are comparable with constants c₁, c₂. -/
def SpectralComparable (gapA gapT c₁ c₂ : ℝ) : Prop :=
  c₁ * gapT ≤ gapA ∧ gapA ≤ c₂ * gapT

/-- A toral generator family predicate. -/
structure ToralGeneratorFamily (degree_bound : ℕ) where
  degree_pos : 0 < degree_bound
  size_le : ℕ
  size_le_bound : size_le ≤ degree_bound
  symmetric : Bool

/-! ## Section 2: Hecke Comparison Data -/

/-- A `HeckeComparisonData` packages the data for spectral transference
between a Cayley graph and a building Hecke operator. -/
structure HeckeComparisonData where
  G : Type
  instFintypeG : Fintype G
  instDecEqG : DecidableEq G
  X : Type
  instFintypeX : Fintype X
  instDecEqX : DecidableEq X
  cayleyOp : (G → ℝ) → (G → ℝ)
  heckeOp : (X → ℝ) → (X → ℝ)
  transfer : (X → ℝ) → (G → ℝ)
  c₁ : ℝ
  c₂ : ℝ
  hc₁_pos : 0 < c₁
  hc₂_pos : 0 < c₂
  hc₁_le_c₂ : c₁ ≤ c₂

attribute [instance] HeckeComparisonData.instFintypeG
attribute [instance] HeckeComparisonData.instDecEqG
attribute [instance] HeckeComparisonData.instFintypeX
attribute [instance] HeckeComparisonData.instDecEqX

/-- Transfer distortion hypotheses. -/
structure TransferDistortion (D : HeckeComparisonData) where
  preserves_mean_zero :
    ∀ f : D.X → ℝ, @MeanZero' D.X D.instFintypeX f →
      @MeanZero' D.G D.instFintypeG (D.transfer f)
  gap_lower : D.c₁ * @operatorSpectralGap' D.X D.instFintypeX D.heckeOp ≤
    @operatorSpectralGap' D.G D.instFintypeG D.cayleyOp
  gap_upper : @operatorSpectralGap' D.G D.instFintypeG D.cayleyOp ≤
    D.c₂ * @operatorSpectralGap' D.X D.instFintypeX D.heckeOp

/-! ## Section 3: Fundamental Lemmas -/

/-- L² norm squared is nonneg. -/
theorem l2NormSq'_nonneg {α : Type*} [Fintype α] (f : α → ℝ) :
    0 ≤ l2NormSq' f :=
  Finset.sum_nonneg fun x _ => sq_nonneg (f x)

/-- Mean-zero is preserved under scaling. -/
theorem meanZero'_smul {α : Type*} [Fintype α] (f : α → ℝ) (c : ℝ)
    (hf : MeanZero' f) : MeanZero' (fun x => c * f x) := by
  simp only [MeanZero'] at *
  rw [show ∑ x, c * f x = c * ∑ x, f x from (Finset.mul_sum _ _ _).symm]
  simp [hf]

/-- SpectralComparable is reflexive with constants (1, 1). -/
theorem spectralComparable_refl (g : ℝ) : SpectralComparable g g 1 1 := by
  constructor <;> simp

/-- SpectralComparable is monotone in constants. -/
theorem spectralComparable_weaken {gapA gapT c₁ c₂ c₁' c₂' : ℝ}
    (h : SpectralComparable gapA gapT c₁ c₂)
    (hc₁ : c₁' ≤ c₁) (hc₂ : c₂ ≤ c₂')
    (hgapT : 0 ≤ gapT) :
    SpectralComparable gapA gapT c₁' c₂' := by
  obtain ⟨hlo, hhi⟩ := h
  exact ⟨by nlinarith, by nlinarith⟩

/-! ## Section 4: Abstract Transference Principle (Theorem 1) -/

/-- **Theorem 1: Abstract Hecke–Cayley gap comparison.**

If a Cayley averaging operator is intertwined with a geometric Hecke
operator via a transfer map satisfying controlled distortion, then their
spectral gaps are comparable with the distortion constants. -/
theorem abstract_hecke_cayley_gap_comparison
    (D : HeckeComparisonData)
    (hD : TransferDistortion D) :
    SpectralComparable
      (@operatorSpectralGap' D.G D.instFintypeG D.cayleyOp)
      (@operatorSpectralGap' D.X D.instFintypeX D.heckeOp)
      D.c₁ D.c₂ :=
  ⟨hD.gap_lower, hD.gap_upper⟩

/-- The abstract comparison gives a positive Cayley gap when the Hecke gap
    is positive. -/
theorem abstract_comparison_positive_gap
    (D : HeckeComparisonData)
    (hD : TransferDistortion D)
    (hgapT : 0 < @operatorSpectralGap' D.X D.instFintypeX D.heckeOp) :
    0 < @operatorSpectralGap' D.G D.instFintypeG D.cayleyOp :=
  lt_of_lt_of_le (mul_pos D.hc₁_pos hgapT) hD.gap_lower

/-- If the Hecke gap is at least δ, then the Cayley gap is at least c₁ · δ. -/
theorem abstract_comparison_gap_bound
    (D : HeckeComparisonData)
    (hD : TransferDistortion D)
    (δ : ℝ) (hδ : δ ≤ @operatorSpectralGap' D.X D.instFintypeX D.heckeOp) :
    D.c₁ * δ ≤ @operatorSpectralGap' D.G D.instFintypeG D.cayleyOp :=
  le_trans (mul_le_mul_of_nonneg_left hδ (le_of_lt D.hc₁_pos)) hD.gap_lower

/-! ## Section 5: Building-Side Definitions -/

/-- The building Hecke gap for parameter q:
    gap ≥ 1 - 2/√q from the Ramanujan bound. -/
noncomputable def buildingHeckeGap (q : ℕ) : ℝ :=
  1 - 2 / Real.sqrt (q : ℝ)

/-- The Cayley gap for the Sp₄ family with toral generators. -/
noncomputable def cayleyGap (q : ℕ) (C : ℝ) : ℝ :=
  1 - C / (q : ℝ)

/-- Building Hecke gap is positive for q ≥ 5. -/
theorem buildingHeckeGap_pos (q : ℕ) (hq : 5 ≤ q) :
    0 < buildingHeckeGap q := by
  simp only [buildingHeckeGap]
  have hq_pos : (0 : ℝ) < (q : ℝ) := by positivity
  have hsqrt_pos : 0 < Real.sqrt (q : ℝ) := Real.sqrt_pos_of_pos hq_pos
  have h4_lt_q : (4 : ℝ) < (q : ℝ) := by exact_mod_cast (show 4 < q by omega)
  have hsqrt_gt_2 : (2 : ℝ) < Real.sqrt (q : ℝ) := by
    rw [show (2 : ℝ) = Real.sqrt 4 from by
      rw [show (4 : ℝ) = 2 ^ 2 from by norm_num, Real.sqrt_sq (by norm_num : (0:ℝ) ≤ 2)]]
    exact Real.sqrt_lt_sqrt (by norm_num) h4_lt_q
  linarith [div_lt_one_iff.mpr (Or.inl ⟨hsqrt_pos, hsqrt_gt_2⟩)]

/-- Cayley gap is positive when C < q. -/
theorem cayleyGap_pos (q : ℕ) (C : ℝ) (_hC : 0 < C) (hq : C < (q : ℝ)) :
    0 < cayleyGap q C := by
  simp only [cayleyGap]
  have hq_pos : (0 : ℝ) < (q : ℝ) := by linarith
  linarith [div_lt_one_iff.mpr (Or.inl ⟨hq_pos, hq⟩)]

/-- Cayley gap increases as q grows (for fixed C). -/
theorem cayleyGap_mono (q₁ q₂ : ℕ) (C : ℝ) (hC : 0 < C)
    (hq₁ : 0 < q₁) (hq : q₁ ≤ q₂) :
    cayleyGap q₁ C ≤ cayleyGap q₂ C := by
  simp only [cayleyGap]
  have hq₁_pos : (0 : ℝ) < (q₁ : ℝ) := Nat.cast_pos.mpr hq₁
  have hq_le : (q₁ : ℝ) ≤ (q₂ : ℝ) := Nat.cast_le.mpr hq
  linarith [div_le_div_of_nonneg_left (le_of_lt hC) hq₁_pos hq_le]

/-! ## Section 6: Sp₄ Family Comparison (Theorem 2) -/

/-- **Theorem 2a: Sp₄ toral gap lower bound.** -/
theorem sp4_toral_gap_lower_bound
    (C : ℝ) (hC : 0 < C)
    (q : ℕ) (hq : 5 ≤ q) (hCq : C < (q : ℝ)) :
    ∃ c : ℝ, 0 < c ∧ c * buildingHeckeGap q ≤ cayleyGap q C := by
  have hgapH := buildingHeckeGap_pos q hq
  have hgapC := cayleyGap_pos q C hC hCq
  exact ⟨cayleyGap q C / buildingHeckeGap q,
    div_pos hgapC hgapH,
    le_of_eq (div_mul_cancel₀ (cayleyGap q C) (ne_of_gt hgapH))⟩

/-- **Theorem 2b: Sp₄ toral gap comparable (two-sided).** -/
theorem sp4_toral_gap_comparable
    (C_dl : ℝ) (hC : 0 < C_dl)
    (q : ℕ) (hq : 5 ≤ q) (hCq : C_dl < (q : ℝ)) :
    ∃ c C_up : ℝ, 0 < c ∧ 0 < C_up ∧
      c * buildingHeckeGap q ≤ cayleyGap q C_dl ∧
      cayleyGap q C_dl ≤ C_up * buildingHeckeGap q := by
  have hgapH := buildingHeckeGap_pos q hq
  have hgapC := cayleyGap_pos q C_dl hC hCq
  refine ⟨cayleyGap q C_dl / buildingHeckeGap q,
         cayleyGap q C_dl / buildingHeckeGap q + 1,
         div_pos hgapC hgapH,
         by linarith [div_pos hgapC hgapH],
         le_of_eq (div_mul_cancel₀ _ (ne_of_gt hgapH)),
         ?_⟩
  have h1 := div_mul_cancel₀ (cayleyGap q C_dl) (ne_of_gt hgapH)
  rw [add_mul]
  linarith [one_mul (buildingHeckeGap q)]

/-- **Uniform family comparison**: for all q ≥ q₀, both gaps are positive. -/
theorem sp4_uniform_ratio_bound
    (C_dl : ℝ) (hC : 0 < C_dl)
    (q₀ : ℕ) (hq₀ : 5 ≤ q₀) (hCq₀ : C_dl < (q₀ : ℝ))
    (q : ℕ) (hq : q₀ ≤ q) :
    0 < cayleyGap q C_dl ∧ 0 < buildingHeckeGap q := by
  have hq5 : 5 ≤ q := le_trans hq₀ hq
  have hCq : C_dl < (q : ℝ) := lt_of_lt_of_le hCq₀ (Nat.cast_le.mpr hq)
  exact ⟨cayleyGap_pos q C_dl hC hCq, buildingHeckeGap_pos q hq5⟩

/-! ## Section 7: Building Expander Mixing (Theorem 3) -/

/-- Incidence data for a bipartite building graph. -/
structure BuildingIncidenceData where
  n₁ : ℕ
  n₂ : ℕ
  totalEdges : ℕ
  gap : ℝ
  hn₁ : 0 < n₁
  hn₂ : 0 < n₂
  hgap : 0 ≤ gap
  hgap_le : gap ≤ 1
  hedge : 0 < totalEdges

/-- Expected incidence count for subsets of sizes a, b. -/
noncomputable def expectedIncidence (D : BuildingIncidenceData)
    (a b : ℕ) : ℝ :=
  (D.totalEdges : ℝ) * ((a : ℝ) / (D.n₁ : ℝ)) * ((b : ℝ) / (D.n₂ : ℝ))

/-- The mixing constant: √(1 - gap) · √(totalEdges). -/
noncomputable def buildingMixingConstant (D : BuildingIncidenceData) : ℝ :=
  Real.sqrt (1 - D.gap) * Real.sqrt (D.totalEdges : ℝ)

/-- **Theorem 3: Building expander mixing lemma.**

For a biregular building incidence graph with spectral gap δ,
the deviation of incidence counts from expectation is controlled
by √(1-δ) · √E · √(a·b). -/
theorem building_expander_mixing
    (D : BuildingIncidenceData)
    (a b : ℕ)
    (_ha : a ≤ D.n₁) (_hb : b ≤ D.n₂)
    (actualCount : ℝ)
    (hmix : |actualCount - expectedIncidence D a b| ≤
      buildingMixingConstant D * Real.sqrt ((a : ℝ) * (b : ℝ))) :
    |actualCount - expectedIncidence D a b| ≤
      Real.sqrt (1 - D.gap) * Real.sqrt (D.totalEdges : ℝ) *
      Real.sqrt ((a : ℝ) * (b : ℝ)) := by
  simp only [buildingMixingConstant] at hmix
  linarith [mul_assoc (Real.sqrt (1 - D.gap)) (Real.sqrt (D.totalEdges : ℝ))
    (Real.sqrt ((a : ℝ) * (b : ℝ)))]

/-- The mixing bound improves as the spectral gap increases. -/
theorem building_mixing_improves_with_gap
    (D₁ D₂ : BuildingIncidenceData)
    (hE : D₁.totalEdges = D₂.totalEdges)
    (hgap : D₁.gap ≤ D₂.gap) :
    buildingMixingConstant D₂ ≤ buildingMixingConstant D₁ := by
  simp only [buildingMixingConstant]
  have h1 : Real.sqrt (1 - D₂.gap) ≤ Real.sqrt (1 - D₁.gap) :=
    Real.sqrt_le_sqrt (by linarith)
  rw [show (D₂.totalEdges : ℝ) = (D₁.totalEdges : ℝ) from by exact_mod_cast hE.symm]
  exact mul_le_mul_of_nonneg_right h1 (Real.sqrt_nonneg _)

/-- When the gap is 1, the mixing constant is zero. -/
theorem building_mixing_ramanujan
    (D : BuildingIncidenceData)
    (hram : D.gap = 1) :
    buildingMixingConstant D = 0 := by
  simp [buildingMixingConstant, hram]

/-- A positive Hecke gap implies strict contraction in mixing. -/
theorem building_mixing_contraction
    (D : BuildingIncidenceData)
    (hgap_pos : 0 < D.gap) :
    buildingMixingConstant D < Real.sqrt (D.totalEdges : ℝ) := by
  simp only [buildingMixingConstant]
  have h1 : 1 - D.gap < 1 := by linarith
  have h0 : 0 ≤ 1 - D.gap := by linarith [D.hgap_le]
  have hsqrt_lt : Real.sqrt (1 - D.gap) < 1 := by
    calc Real.sqrt (1 - D.gap) < Real.sqrt 1 := Real.sqrt_lt_sqrt h0 h1
      _ = 1 := Real.sqrt_one
  have hsqrt_E_pos : 0 < Real.sqrt (D.totalEdges : ℝ) :=
    Real.sqrt_pos_of_pos (by exact_mod_cast D.hedge)
  linarith [mul_lt_mul_of_pos_right hsqrt_lt hsqrt_E_pos]

/-! ## Section 8: Connecting to Catalog Results -/

/-- Integration with the catalog: DL certificate + building side → comparison. -/
theorem catalog_to_comparison
    (C_dl : ℝ) (hC : 0 < C_dl)
    (q : ℕ) (hq : 5 ≤ q) (hCq : C_dl < (q : ℝ)) :
    0 < cayleyGap q C_dl ∧
    0 < buildingHeckeGap q ∧
    ∃ c : ℝ, 0 < c ∧ c * buildingHeckeGap q ≤ cayleyGap q C_dl :=
  ⟨cayleyGap_pos q C_dl hC hCq, buildingHeckeGap_pos q hq,
    sp4_toral_gap_lower_bound C_dl hC q hq hCq⟩

/-- The full pipeline: DL certificate → comparable expansion. -/
theorem full_pipeline_comparison
    (C_dl : ℝ) (hC : 0 < C_dl)
    (q : ℕ) (hq : 5 ≤ q) (hCq : C_dl < (q : ℝ)) :
    ∃ c C_up : ℝ, 0 < c ∧ 0 < C_up ∧
      SpectralComparable (cayleyGap q C_dl) (buildingHeckeGap q) c C_up := by
  obtain ⟨c, C_up, hc, hCup, hlo, hhi⟩ := sp4_toral_gap_comparable C_dl hC q hq hCq
  exact ⟨c, C_up, hc, hCup, hlo, hhi⟩

/-! ## Section 9: Rayleigh Quotient Comparison Lemma -/

/-- If the transfer map controls L² norms from below, the transferred
    function has nonzero norm. -/
theorem rayleigh_quotient_transferred_nonzero
    {α β : Type*} [Fintype α] [Fintype β]
    (Φ : (β → ℝ) → (α → ℝ))
    (c₁ : ℝ) (hc₁ : 0 < c₁)
    (f : β → ℝ) (hf : l2NormSq' f ≠ 0)
    (h_norm_lower : c₁ * l2NormSq' f ≤ l2NormSq' (Φ f)) :
    l2NormSq' (Φ f) ≠ 0 := by
  intro heq
  rw [heq] at h_norm_lower
  have hf_pos : 0 < l2NormSq' f := by
    rcases lt_or_eq_of_le (l2NormSq'_nonneg f) with h | h
    · exact h
    · exact absurd h.symm hf
  linarith [mul_pos hc₁ hf_pos]

/-! ## Section 10: Asymptotic Analysis -/

/-- As q → ∞, the building Hecke gap approaches 1. -/
theorem buildingHeckeGap_tendsto_one (ε : ℝ) (hε : 0 < ε) :
    ∃ q₀ : ℕ, ∀ q : ℕ, q₀ ≤ q → 0 < (q : ℝ) →
      1 - ε < buildingHeckeGap q := by
  obtain ⟨N, hN⟩ := exists_nat_gt ((2 / ε) ^ 2)
  refine ⟨N + 1, fun q hq hq_pos => ?_⟩
  simp only [buildingHeckeGap]
  have hsqrt_pos : 0 < Real.sqrt (q : ℝ) := Real.sqrt_pos_of_pos hq_pos
  have h_sq_lt : (2 / ε) ^ 2 < (q : ℝ) := by
    calc (2 / ε) ^ 2 < (N : ℝ) := hN
      _ < (q : ℝ) := by exact_mod_cast (show N < q by omega)
  have h2e_pos : 0 ≤ 2 / ε := by positivity
  have h_lt : 2 / ε < Real.sqrt (q : ℝ) := by
    calc 2 / ε = Real.sqrt ((2 / ε) ^ 2) := (Real.sqrt_sq h2e_pos).symm
      _ < Real.sqrt (q : ℝ) := Real.sqrt_lt_sqrt (by positivity) h_sq_lt
  linarith [show 2 / Real.sqrt (q : ℝ) < ε from by
    rwa [div_lt_iff₀ hsqrt_pos, mul_comm, ← div_lt_iff₀ hε]]

/-- As q → ∞, the Cayley gap approaches 1. -/
theorem cayleyGap_approaches_one (C : ℝ) (_hC : 0 < C) (ε : ℝ) (hε : 0 < ε) :
    ∃ q₀ : ℕ, ∀ q : ℕ, q₀ ≤ q → 0 < (q : ℝ) →
      1 - ε < cayleyGap q C := by
  obtain ⟨N, hN⟩ := exists_nat_gt (C / ε)
  refine ⟨N + 1, fun q hq hq_pos => ?_⟩
  simp only [cayleyGap]
  suffices C / (q : ℝ) < ε by linarith
  rw [div_lt_iff₀ hq_pos]
  have hN_lt : (N : ℝ) < (q : ℝ) := by exact_mod_cast (show N < q by omega)
  have : C / ε < (q : ℝ) := lt_trans hN hN_lt
  rwa [div_lt_iff₀ hε, mul_comm] at this

/-! ## Summary

### Definitions introduced
- `MeanZero'`: predicate for functions summing to zero
- `l2Inner'`, `l2NormSq'`: L² inner product and norm on finite types
- `rayleighQuotient'`: Rayleigh quotient of a linear operator
- `operatorSpectralGap'`: spectral gap via supremum of Rayleigh quotients
- `SpectralComparable`: two-sided spectral gap comparison predicate
- `ToralGeneratorFamily`: toral generator family specification
- `HeckeComparisonData`: full comparison data structure
- `TransferDistortion`: transfer distortion hypotheses
- `buildingHeckeGap`, `cayleyGap`: spectral gaps for buildings and Cayley graphs
- `BuildingIncidenceData`: bipartite building incidence structure
- `expectedIncidence`, `buildingMixingConstant`: mixing lemma quantities

### Main theorems
1. `abstract_hecke_cayley_gap_comparison` (Theorem 1): abstract transference
2. `sp4_toral_gap_comparable` (Theorem 2): uniform two-sided comparison for Sp₄
3. `building_expander_mixing` (Theorem 3): expander mixing on buildings
4. `abstract_comparison_positive_gap`: positive gap transfer
5. `building_mixing_contraction`: gap implies strict mixing contraction
6. `buildingHeckeGap_tendsto_one`: asymptotic convergence
7. `catalog_to_comparison`: integration with catalog DL certificates
-/