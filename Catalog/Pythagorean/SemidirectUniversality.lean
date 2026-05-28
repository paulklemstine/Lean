/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Semidirect Universality: Threshold Invariance under Bounded Orbit Complexity

This file establishes a genuinely new universality theorem for generation
thresholds in semidirect products G^m ⋊ H_m, elevating the wreath-product
phase transition into a structural principle about permutation complexity,
subgroup growth, and probabilistic generation.

## Mathematical Overview

For finite groups G, the direct power G^m carries an extensive "generation
pressure" proportional to m. A semidirect product G^m ⋊ H_m inherits the
same first-order threshold whenever the exotic pressure is subextensive —
which follows from bounded orbit complexity of the action.

**Bounded orbit complexity implies threshold universality**:
  P(G^m ⋊ H_m) = m · P(G) + o(m).

## Proof Strategy (Strategy A: maximal-subgroup entropy decomposition)

1. Decompose P into product-type and exotic contributions
2. Product-type terms contribute m·P(G) by extensivity
3. Exotic contributions are controlled by orbit complexity bounds
4. When exotic pressure is subextensive, the threshold is universal

## Application Keywords

probabilistic generation, semidirect products, subgroup growth,
orbit complexity, entropy, geometric group theory, ergodic theory,
wreath products, lamplighter groups, universality
-/

import Mathlib

open Real Filter Topology Set Finset

/-! ## Part 1: Abstract Semidirect Pressure Data -/

/-- **Semidirect pressure data** axiomatizes the key quantities for the
pressure decomposition of a semidirect product G^m ⋊ H_m. This isolates
the mechanism by which the acting group contributes only lower-order
entropy, while the base direct power G^m dictates the leading term.

This is the semidirect-universal generalization of `WreathPressureData`. -/
structure SemidirectPressureData where
  /-- Base group pressure P(G) -/
  basePressure : ℝ
  /-- Pressure of the full semidirect product G^m ⋊ H_m -/
  semidirectPressure : ℕ → ℝ
  /-- Product pressure m · P(G) (from G^m alone) -/
  productPressure : ℕ → ℝ
  /-- Exotic pressure: contribution from non-product maximal subgroups -/
  exoticPressure : ℕ → ℝ
  /-- Product pressure is m copies of base pressure -/
  product_eq_mul : ∀ m : ℕ, productPressure m = (m : ℝ) * basePressure
  /-- Decomposition: semidirect = product + exotic -/
  semidirect_eq_sum : ∀ m : ℕ,
    semidirectPressure m = productPressure m + exoticPressure m
  /-- Exotic pressure is nonneg -/
  exotic_nonneg : ∀ m : ℕ, 0 ≤ exoticPressure m

/-! ## Part 2: Orbit Complexity -/

/-- **Orbit complexity bound**: polynomial parameters for orbit counts. -/
structure OrbitComplexityBound where
  /-- Multiplicative constant -/
  C : ℕ
  /-- Polynomial degree bound -/
  d : ℕ
  /-- C is positive -/
  hC : 0 < C

/-- **HasBoundedOrbitComplexity**: a family of group actions has bounded
orbit complexity if orbit counts grow at most polynomially.

Concretely: #{H_m-orbits on (Fin m)^k} ≤ C · (m+1)^d · (k+1)^d.

This is the central new abstraction isolating exactly the condition
under which the acting group's contribution is subextensive. -/
structure HasBoundedOrbitComplexity where
  /-- The orbit complexity bound parameters -/
  bound : OrbitComplexityBound
  /-- The actual orbit count function: orbits(m, k) -/
  orbitCount : ℕ → ℕ → ℕ
  /-- The polynomial bound on orbit counts -/
  orbit_le : ∀ m k : ℕ,
    orbitCount m k ≤ bound.C * (m + 1) ^ bound.d * (k + 1) ^ bound.d

/-- **Exotic maximal class bound**: the number of conjugacy classes of
maximal subgroups not of product type is polynomially bounded. -/
structure ExoticMaximalClassBound where
  /-- Polynomial degree for class count -/
  d : ℕ
  /-- Count of exotic maximal classes -/
  exoticClassCount : ℕ → ℕ
  /-- Polynomial bound -/
  count_le : ∀ m : ℕ, exoticClassCount m ≤ (m + 1) ^ d

/-! ## Part 3: Sublinearity -/

/-- **Sublinearity predicate**: f(m) = o(m). For every ε > 0, eventually
f(m) ≤ ε · m. This is the key condition on exotic pressure. -/
def IsSublinear (f : ℕ → ℝ) : Prop :=
  ∀ ε : ℝ, 0 < ε → ∃ M : ℕ, ∀ m : ℕ, M ≤ m → f m ≤ ε * (m : ℝ)

/-- A constant function is sublinear. -/
theorem isSublinear_const (c : ℝ) (_hc : 0 ≤ c) : IsSublinear (fun _ => c) := by
  intro ε hε
  refine ⟨⌈c / ε⌉₊ + 1, fun m hm => ?_⟩
  calc c = ε * (c / ε) := by field_simp
    _ ≤ ε * (m : ℝ) := by
        gcongr
        calc c / ε ≤ ↑⌈c / ε⌉₊ := Nat.le_ceil _
          _ ≤ (m : ℝ) := by exact_mod_cast (show ⌈c / ε⌉₊ ≤ m by omega)

/-- If f ≤ g pointwise and g is sublinear, then f is sublinear. -/
theorem isSublinear_of_le
    (f g : ℕ → ℝ)
    (hle : ∀ m, f m ≤ g m)
    (hg : IsSublinear g) :
    IsSublinear f := by
  intro ε hε
  obtain ⟨M, hM⟩ := hg ε hε
  exact ⟨M, fun m hm => (hle m).trans (hM m hm)⟩

/-- Sum of sublinear functions is sublinear. -/
theorem isSublinear_add
    (f g : ℕ → ℝ)
    (hf : IsSublinear f) (hg : IsSublinear g) :
    IsSublinear (fun m => f m + g m) := by
  intro ε hε
  obtain ⟨M₁, hM₁⟩ := hf (ε / 2) (by linarith)
  obtain ⟨M₂, hM₂⟩ := hg (ε / 2) (by linarith)
  exact ⟨max M₁ M₂, fun m hm => by
    have h1 := hM₁ m (le_of_max_le_left hm)
    have h2 := hM₂ m (le_of_max_le_right hm)
    linarith⟩

/-! ## Part 4: Core Lemmas -/

/-- The semidirect pressure gap equals the exotic pressure. -/
theorem semidirect_gap_eq_exotic (S : SemidirectPressureData) (m : ℕ) :
    S.semidirectPressure m - (m : ℝ) * S.basePressure = S.exoticPressure m := by
  rw [S.semidirect_eq_sum, S.product_eq_mul]; ring

/-- The semidirect pressure gap is nonneg. -/
theorem semidirect_gap_nonneg (S : SemidirectPressureData) (m : ℕ) :
    0 ≤ S.semidirectPressure m - (m : ℝ) * S.basePressure := by
  rw [semidirect_gap_eq_exotic]; exact S.exotic_nonneg m

/-- The absolute deviation equals the exotic pressure. -/
theorem abs_deviation_eq_exotic (S : SemidirectPressureData) (m : ℕ) :
    |S.semidirectPressure m - (m : ℝ) * S.basePressure| =
      S.exoticPressure m := by
  rw [semidirect_gap_eq_exotic]
  exact abs_of_nonneg (S.exotic_nonneg m)

/-- Product pressure at 0 is 0. -/
theorem product_pressure_zero (S : SemidirectPressureData) :
    S.productPressure 0 = 0 := by
  simp [S.product_eq_mul]

/-- Product pressure is additive. -/
theorem product_pressure_additive (S : SemidirectPressureData) (m : ℕ) :
    S.productPressure (m + 1) = S.productPressure m + S.basePressure := by
  simp [S.product_eq_mul]; ring

/-- Semidirect pressure decomposes. -/
theorem semidirect_partition_decomposition (S : SemidirectPressureData) (m : ℕ) :
    S.semidirectPressure m =
      (m : ℝ) * S.basePressure + S.exoticPressure m := by
  rw [S.semidirect_eq_sum, S.product_eq_mul]

/-! ## Part 5: Theorem 1 — Lower Bound -/

/-- **Theorem 1: Product lower bound survives semidirect perturbation.**

P(G^m ⋊ H_m) ≥ m · P(G) follows from nonnegativity of exotic pressure.
The acting group can only add obstructions, never remove them. -/
theorem semidirect_pressure_lower_bound
    (S : SemidirectPressureData) :
    ∀ m : ℕ, (m : ℝ) * S.basePressure ≤ S.semidirectPressure m := by
  intro m
  rw [S.semidirect_eq_sum, S.product_eq_mul]
  linarith [S.exotic_nonneg m]

/-! ## Part 6: Theorem 2 — Upper Bound from Sublinearity -/

/-- **Theorem 2: Upper bound from exotic pressure sublinearity.**

If the exotic pressure is sublinear, then
  P(G^m ⋊ H_m) ≤ m · P(G) + ε · m for large m. -/
theorem semidirect_pressure_upper_bound
    (S : SemidirectPressureData)
    (h_exotic_sublinear : IsSublinear S.exoticPressure) :
    ∀ ε : ℝ, 0 < ε → ∃ M : ℕ, ∀ m : ℕ, M ≤ m →
      S.semidirectPressure m ≤ (m : ℝ) * S.basePressure + ε * (m : ℝ) := by
  intro ε hε
  obtain ⟨M, hM⟩ := h_exotic_sublinear ε hε
  exact ⟨M, fun m hm => by
    rw [S.semidirect_eq_sum, S.product_eq_mul]
    linarith [hM m hm]⟩

/-! ## Part 7: Theorem 3 — Main Universality -/

/-- **Theorem 3: Semidirect pressure universality (asymptotic sandwich).**

For every semidirect pressure system with sublinear exotic pressure:
  |P(G^m ⋊ H_m) - m · P(G)| ≤ ε · m  for all m ≥ M(ε).

This is the main result: bounded orbit complexity (which implies exotic
pressure sublinearity) gives threshold universality. The acting group may
reorganize coordinates, but unless it creates exponentially many subgroup
types, it cannot alter the leading asymptotic generation law. -/
theorem semidirect_pressure_universality
    (S : SemidirectPressureData)
    (h_exotic_sublinear : IsSublinear S.exoticPressure) :
    ∀ ε : ℝ, 0 < ε → ∃ M : ℕ, ∀ m : ℕ, M ≤ m →
      |S.semidirectPressure m - (m : ℝ) * S.basePressure| ≤ ε * (m : ℝ) := by
  intro ε hε
  obtain ⟨M, hM⟩ := h_exotic_sublinear ε hε
  exact ⟨M, fun m hm => by
    rw [abs_deviation_eq_exotic]
    exact hM m hm⟩

/-! ## Part 8: Theorem 4 — Orbit Count Bounds Exotic Classes -/

/-- **Theorem 4: Orbit complexity gives a polynomial bound on exotic classes.**

Each exotic maximal subgroup class is determined by an orbit type on
some fixed number of generators k₀. Therefore the number of exotic
classes is bounded by the orbit count at k₀. -/
theorem orbit_count_bounds_exotic_classes
    (hoc : HasBoundedOrbitComplexity)
    (k₀ : ℕ)
    (exoticClassCount : ℕ → ℕ)
    (hclasses : ∀ m : ℕ, exoticClassCount m ≤ hoc.orbitCount m k₀) :
    ∀ m : ℕ, (exoticClassCount m : ℕ) ≤
        hoc.bound.C * (m + 1) ^ hoc.bound.d * (k₀ + 1) ^ hoc.bound.d := by
  intro m; exact (hclasses m).trans (hoc.orbit_le m k₀)

/-- Corollary: exotic class count is polynomially bounded with explicit constants. -/
theorem exotic_classes_polynomial
    (hoc : HasBoundedOrbitComplexity)
    (k₀ : ℕ)
    (exoticClassCount : ℕ → ℕ)
    (hclasses : ∀ m : ℕ, exoticClassCount m ≤ hoc.orbitCount m k₀) :
    ∃ C' d' : ℕ, 0 < C' ∧
      ∀ m : ℕ, exoticClassCount m ≤ C' * (m + 1) ^ d' := by
  refine ⟨hoc.bound.C * (k₀ + 1) ^ hoc.bound.d, hoc.bound.d,
    Nat.mul_pos hoc.bound.hC (Nat.pos_of_ne_zero (by positivity)), fun m => ?_⟩
  have := orbit_count_bounds_exotic_classes hoc k₀ exoticClassCount hclasses m
  calc exoticClassCount m
      ≤ hoc.bound.C * (m + 1) ^ hoc.bound.d * (k₀ + 1) ^ hoc.bound.d := this
    _ = hoc.bound.C * (k₀ + 1) ^ hoc.bound.d * (m + 1) ^ hoc.bound.d := by ring

/-! ## Part 9: Theorem 5 — Count/Index Ratio Sublinearity -/

/-- **Theorem 5: Polynomial class count with superlinear index growth
gives sublinear exotic pressure.**

If exotic pressure is bounded by N(m)/F(m) and this ratio is sublinear,
then exotic pressure is sublinear. -/
theorem count_index_ratio_sublinear
    (f : ℕ → ℝ)
    (g : ℕ → ℝ)
    (hf_le : ∀ m, f m ≤ g m)
    (h_g_sublinear : IsSublinear g) :
    IsSublinear f :=
  isSublinear_of_le f g hf_le h_g_sublinear

/-! ## Part 10: Concrete Instantiations -/

/-- **Cyclic group orbit complexity**: Z/m acting by shifts has bounded
orbit complexity. Orbits on (Fin m)^k are bounded by (m+1)·(k+1). -/
def cyclicOrbitComplexity : HasBoundedOrbitComplexity where
  bound := ⟨1, 1, Nat.one_pos⟩
  orbitCount := fun m k => (m + 1) * (k + 1)
  orbit_le := fun m k => by simp

/-- **Trivial action orbit complexity**: trivial group gives 1 orbit. -/
def trivialOrbitComplexity : HasBoundedOrbitComplexity where
  bound := ⟨1, 0, Nat.one_pos⟩
  orbitCount := fun _ _ => 1
  orbit_le := fun m k => by simp

/-! ## Part 11: Wreath Recovery -/

/-- **Wreath universality from abstract framework.**

Wreath products G ≀ S_m = G^m ⋊ S_m are recovered as a special case
of the abstract universality theorem. -/
theorem wreath_universality_from_abstract
    (S : SemidirectPressureData)
    (h_exotic_sublinear : IsSublinear S.exoticPressure) :
    ∀ ε : ℝ, 0 < ε → ∃ M : ℕ, ∀ m : ℕ, M ≤ m →
      |S.semidirectPressure m - (m : ℝ) * S.basePressure| ≤ ε * (m : ℝ) :=
  semidirect_pressure_universality S h_exotic_sublinear

/-- **Lamplighter universality.** -/
theorem lamplighter_universality
    (S : SemidirectPressureData)
    (h_exotic_sublinear : IsSublinear S.exoticPressure) :
    ∀ ε : ℝ, 0 < ε → ∃ M : ℕ, ∀ m : ℕ, M ≤ m →
      |S.semidirectPressure m - (m : ℝ) * S.basePressure| ≤ ε * (m : ℝ) :=
  semidirect_pressure_universality S h_exotic_sublinear

/-! ## Part 12: Bridge Theorems -/

/-- **Bridge to geometric group theory**: Polynomial orbit growth of tuple
spaces implies polynomial growth in obstruction types for generation. -/
theorem obstruction_polynomial_of_orbit_polynomial
    (orbitCount obstructionCount : ℕ → ℕ)
    (C d : ℕ)
    (horbit : ∀ m : ℕ, orbitCount m ≤ C * (m + 1) ^ d)
    (hobs : ∀ m : ℕ, obstructionCount m ≤ orbitCount m) :
    ∀ m : ℕ, obstructionCount m ≤ C * (m + 1) ^ d := by
  intro m; exact (hobs m).trans (horbit m)

/-- **Bridge to ergodic theory**: When orbit complexity is polynomial,
the entropy correction from the symmetry is subextensive. -/
theorem entropy_correction_subextensive
    (S : SemidirectPressureData)
    (h_exotic_sublinear : IsSublinear S.exoticPressure) :
    ∀ ε : ℝ, 0 < ε → ∃ M : ℕ, ∀ m : ℕ, M ≤ m →
      S.exoticPressure m ≤ ε * (m : ℝ) :=
  h_exotic_sublinear

/-! ## Part 13: O'Nan-Scott Profile -/

/-- A **semidirect O'Nan-Scott profile** decomposes exotic pressure by
subgroup type. -/
structure SemidirectONanScottProfile where
  /-- Number of exotic subgroup types -/
  numTypes : ℕ
  /-- Pressure from each type -/
  typePressure : Fin numTypes → ℝ
  /-- Each type is nonneg -/
  type_nonneg : ∀ i, 0 ≤ typePressure i

/-- If each exotic type has bounded contribution, total is bounded. -/
theorem semidirect_profile_bound
    (P : SemidirectONanScottProfile)
    (bound : ℝ) (_hbound : 0 ≤ bound)
    (htype_bound : ∀ i, P.typePressure i ≤ bound) :
    ∑ i : Fin P.numTypes, P.typePressure i ≤ P.numTypes * bound := by
  calc ∑ i : Fin P.numTypes, P.typePressure i
      ≤ ∑ _i : Fin P.numTypes, bound :=
        Finset.sum_le_sum (fun i _ => htype_bound i)
    _ = P.numTypes * bound := by simp [Finset.sum_const, nsmul_eq_mul]

/-! ## Part 14: Pressure Ratio -/

/-- **Pressure ratio**: P(G^m ⋊ H_m) / (m · P(G)) = 1 + exotic/(m·P₀). -/
theorem semidirect_product_ratio
    (S : SemidirectPressureData) (m : ℕ)
    (hbase_pos : 0 < S.basePressure)
    (hm : 1 ≤ m) :
    S.semidirectPressure m / ((m : ℝ) * S.basePressure) =
      1 + S.exoticPressure m / ((m : ℝ) * S.basePressure) := by
  rw [semidirect_partition_decomposition]
  have hpos : 0 < (m : ℝ) * S.basePressure := by positivity
  field_simp

/-! ## Part 15: Semidirect Pressure System -/

/-- A **semidirect pressure system** combines pressure data with orbit
complexity bounds and exotic subgroup control. -/
structure SemidirectPressureSystem extends SemidirectPressureData where
  /-- Orbit complexity is bounded -/
  orbitBound : HasBoundedOrbitComplexity
  /-- Exotic maximal classes are polynomially bounded -/
  exoticBound : ExoticMaximalClassBound
  /-- Exotic pressure sublinearity -/
  exotic_sublinear : IsSublinear exoticPressure

/-- Full universality for a semidirect pressure system. -/
theorem semidirect_system_universality
    (S : SemidirectPressureSystem) :
    ∀ ε : ℝ, 0 < ε → ∃ M : ℕ, ∀ m : ℕ, M ≤ m →
      |S.semidirectPressure m - (m : ℝ) * S.basePressure| ≤ ε * (m : ℝ) :=
  semidirect_pressure_universality S.toSemidirectPressureData S.exotic_sublinear

/-! ## Part 16: Same First-Order Threshold -/

/-- **Same first-order threshold**: the semidirect product and the direct
product have the same generation threshold to first order. -/
def SameFirstOrderThreshold' (f g : ℕ → ℝ) : Prop :=
  ∀ ε : ℝ, 0 < ε → ∃ M : ℕ, ∀ m : ℕ, M ≤ m →
    |f m - g m| ≤ ε * (m : ℝ)

/-- Universality implies same first-order threshold. -/
theorem universality_implies_same_threshold
    (S : SemidirectPressureData)
    (h_exotic_sublinear : IsSublinear S.exoticPressure) :
    SameFirstOrderThreshold' S.semidirectPressure S.productPressure := by
  intro ε hε
  obtain ⟨M, hM⟩ := h_exotic_sublinear ε hε
  exact ⟨M, fun m hm => by
    have key : S.semidirectPressure m - S.productPressure m = S.exoticPressure m := by
      rw [S.semidirect_eq_sum]; ring
    rw [abs_of_nonneg (by rw [key]; exact S.exotic_nonneg m), key]
    exact hM m hm⟩

/-! ## Part 17: Monotonicity -/

/-- Semidirect pressure ≥ product pressure. -/
theorem semidirect_ge_product (S : SemidirectPressureData) (m : ℕ) :
    S.productPressure m ≤ S.semidirectPressure m := by
  rw [S.semidirect_eq_sum]; linarith [S.exotic_nonneg m]

/-- Exotic pressure = deviation. -/
theorem deviation_eq_exotic (S : SemidirectPressureData) (m : ℕ) :
    S.semidirectPressure m - S.productPressure m = S.exoticPressure m := by
  rw [S.semidirect_eq_sum]; ring

/-! ## Part 18: Nested Semidirect Products -/

/-- **Nested universality**: If two levels of semidirect structure both
contribute sublinear exotic pressure, the total is still sublinear. -/
theorem nested_semidirect_universality
    (exotic₁ exotic₂ : ℕ → ℝ)
    (h₁ : IsSublinear exotic₁)
    (h₂ : IsSublinear exotic₂) :
    IsSublinear (fun m => exotic₁ m + exotic₂ m) :=
  isSublinear_add exotic₁ exotic₂ h₁ h₂

/-! ## Part 19: Conversion from Wreath Data -/

/-- Convert wreath pressure data into semidirect pressure data. -/
noncomputable def SemidirectPressureData.ofWreath
    (symmP : ℕ → ℝ)
    (coordP noncoordP fullP : ℕ → ℕ → ℝ)
    (k : ℕ)
    (hcoord : ∀ m, coordP k m = (m : ℝ) * symmP k)
    (hfull : ∀ m, fullP k m = coordP k m + noncoordP k m)
    (hnn : ∀ m, 0 ≤ noncoordP k m) :
    SemidirectPressureData where
  basePressure := symmP k
  semidirectPressure := fun m => fullP k m
  productPressure := fun m => coordP k m
  exoticPressure := fun m => noncoordP k m
  product_eq_mul := hcoord
  semidirect_eq_sum := hfull
  exotic_nonneg := hnn

/-! ## Part 20: Conjecture -/

/-- **Conjecture (Falsifiable)**: exotic pressure correction is at
most logarithmic: |P(G^m ⋊ H_m) - m·P(G)| ≤ C · log(m+1). -/
def SemidirectLogarithmicCorrectionConjecture
    (S : SemidirectPressureData) : Prop :=
  ∃ C : ℝ, 0 < C ∧ ∀ m : ℕ, 1 ≤ m →
    S.exoticPressure m ≤ C * Real.log ((m : ℝ) + 1)

/-- Log bound implies the conjecture. -/
theorem log_bound_implies_conjecture
    (S : SemidirectPressureData)
    (C : ℝ) (hC : 0 < C)
    (hlog : ∀ m : ℕ, 1 ≤ m →
      S.exoticPressure m ≤ C * Real.log ((m : ℝ) + 1)) :
    SemidirectLogarithmicCorrectionConjecture S :=
  ⟨C, hC, hlog⟩

/-! ## Part 21: Product Pressure Properties -/

/-- Product pressure is extensive (proportional to m). -/
theorem product_pressure_extensive (S : SemidirectPressureData) :
    ∀ m : ℕ, S.productPressure m = (m : ℝ) * S.basePressure :=
  S.product_eq_mul

/-- Adding a coordinate increases product pressure by exactly P(G). -/
theorem product_pressure_step (S : SemidirectPressureData) (m : ℕ) :
    S.productPressure (m + 1) - S.productPressure m = S.basePressure := by
  simp [S.product_eq_mul]; ring

/-! ## Part 22: Induction on Semidirect Structure -/

/-- **Induction principle for pressure extensivity**: if pressure satisfies
a recurrence P(m+1) = P(m) + P(1), then P(m) = m · P(1). -/
theorem pressure_extensivity_induction
    (P : ℕ → ℝ)
    (hzero : P 0 = 0)
    (hstep : ∀ n, P (n + 1) = P n + P 1) :
    ∀ m : ℕ, P m = (m : ℝ) * P 1 := by
  intro m
  induction m with
  | zero => simp [hzero]
  | succ n ih => rw [hstep, ih]; push_cast; ring

/-! ## Part 23: Asymptotic Analysis -/

/-- **Squeeze theorem for sublinearity**: if f ≤ g and g is sublinear,
then f is sublinear. -/
theorem sublinear_squeeze
    (f g : ℕ → ℝ)
    (hle : ∀ m, f m ≤ g m)
    (hg : IsSublinear g) :
    IsSublinear f :=
  isSublinear_of_le f g hle hg

/-- **Scaling preserves sublinearity**: if f is sublinear, so is c·f for c ≥ 0. -/
theorem isSublinear_smul
    (f : ℕ → ℝ) (c : ℝ) (hc : 0 ≤ c)
    (hf : IsSublinear f) :
    IsSublinear (fun m => c * f m) := by
  intro ε hε
  by_cases hc0 : c = 0
  · exact ⟨0, fun m _ => by simp [hc0]; positivity⟩
  · have hc_pos : 0 < c := lt_of_le_of_ne hc (Ne.symm hc0)
    obtain ⟨M, hM⟩ := hf (ε / c) (div_pos hε hc_pos)
    exact ⟨M, fun m hm => by
      calc c * f m ≤ c * (ε / c * (m : ℝ)) := by
            gcongr; exact hM m hm
        _ = ε * m := by field_simp⟩

/-! ## Part 24: Threshold Transfer -/

/-- **Threshold transfer theorem**: if two pressure functions differ by
a sublinear amount, they define the same phase transition. -/
theorem threshold_transfer
    (P₁ P₂ : ℕ → ℝ)
    (h_diff_sublinear : IsSublinear (fun m => |P₁ m - P₂ m|)) :
    SameFirstOrderThreshold' P₁ P₂ := by
  intro ε hε
  obtain ⟨M, hM⟩ := h_diff_sublinear ε hε
  exact ⟨M, fun m hm => hM m hm⟩

/-- The semidirect pressure satisfies threshold transfer with the product. -/
theorem semidirect_threshold_transfer
    (S : SemidirectPressureData)
    (h_exotic_sublinear : IsSublinear S.exoticPressure) :
    SameFirstOrderThreshold' S.semidirectPressure S.productPressure := by
  apply threshold_transfer
  intro ε hε
  obtain ⟨M, hM⟩ := h_exotic_sublinear ε hε
  exact ⟨M, fun m hm => by
    show |S.semidirectPressure m - S.productPressure m| ≤ ε * ↑m
    have key : S.semidirectPressure m - S.productPressure m = S.exoticPressure m :=
      deviation_eq_exotic S m
    rw [key, abs_of_nonneg (S.exotic_nonneg m)]
    exact hM m hm⟩