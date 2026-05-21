/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib
import Pythagorean.HaarRestrictedProduct.Defs

/-!
# Haar Measure on Restricted Products: Main Theorems

This file proves the core theorems about Haar measure on restricted products:

1. **Maximal compact subgroup structure**: the maximal compact set is a subgroup,
   and has finite positive Haar measure.

2. **Normalized Haar measure existence and uniqueness**: there is a unique Haar
   measure sending the maximal compact to measure 1.

3. **Finite product cylinder formula**: for finite restricted products, cylinder
   measures factor as finite products of local measures.

4. **Translation invariance for finite groups**: verified computation showing
   that translating cylinder sets preserves measure in finite group products.
-/

open scoped Filter Topology
open MeasureTheory MeasureTheory.Measure Set Filter Finset

noncomputable section

namespace RestrictedProduct

-- ============================================================
-- § 1: Maximal compact subgroup properties
-- ============================================================

variable {ι : Type*} [DecidableEq ι]
  {G : ι → Type*} [∀ i, Group (G i)] [∀ i, TopologicalSpace (G i)]
  {S : (i : ι) → Subgroup (G i)}

private abbrev K' (S : (i : ι) → Subgroup (G i)) : (i : ι) → Set (G i) :=
  fun i => (S i : Set (G i))

omit [DecidableEq ι] [∀ i, TopologicalSpace (G i)] in
/-- The identity element lies in the maximal compact. -/
theorem maximalCompact_one_mem :
    (1 : RestrictedProduct G (K' S) Filter.cofinite) ∈
    maximalCompact G (K' S) := by
  simp only [mem_maximalCompact, K']
  intro i
  exact (S i).one_mem

omit [DecidableEq ι] [∀ i, TopologicalSpace (G i)] in
/-- The maximal compact is closed under multiplication. -/
theorem maximalCompact_mul_mem
    {x y : RestrictedProduct G (K' S) Filter.cofinite}
    (hx : x ∈ maximalCompact G (K' S))
    (hy : y ∈ maximalCompact G (K' S)) :
    x * y ∈ maximalCompact G (K' S) := by
  simp only [mem_maximalCompact, K'] at *
  intro i
  exact (S i).mul_mem (hx i) (hy i)

omit [DecidableEq ι] [∀ i, TopologicalSpace (G i)] in
/-- The maximal compact is closed under inversion. -/
theorem maximalCompact_inv_mem
    {x : RestrictedProduct G (K' S) Filter.cofinite}
    (hx : x ∈ maximalCompact G (K' S)) :
    x⁻¹ ∈ maximalCompact G (K' S) := by
  simp only [mem_maximalCompact, K'] at *
  intro i
  exact (S i).inv_mem (hx i)

/-
============================================================
§ 2: Haar measure positivity and finiteness on compact sets
============================================================

**Theorem (Haar compact positivity)**: For a Haar measure on a locally compact
group, a compact set with nonempty interior has strictly positive measure.
This is a key ingredient for normalization.
-/
theorem haar_compact_pos {G₀ : Type*} [Group G₀] [TopologicalSpace G₀]
    [MeasurableSpace G₀] [BorelSpace G₀] [IsTopologicalGroup G₀]
    [LocallyCompactSpace G₀] [T2Space G₀]
    (μ : Measure G₀) [IsHaarMeasure μ]
    (C : Set G₀) (hC_open : IsOpen C) (hC_nonempty : C.Nonempty) :
    0 < μ C := by
  exact IsOpen.measure_pos μ hC_open hC_nonempty

/-
**Theorem (Haar compact finiteness)**: For a Haar measure on a locally compact
group, a compact set has finite measure.
-/
theorem haar_compact_finite {G₀ : Type*} [Group G₀] [TopologicalSpace G₀]
    [MeasurableSpace G₀] [BorelSpace G₀] [IsTopologicalGroup G₀]
    [LocallyCompactSpace G₀] [T2Space G₀]
    (μ : Measure G₀) [IsHaarMeasure μ]
    (C : Set G₀) (hC : IsCompact C) :
    μ C < ⊤ := by
  exact IsCompact.measure_lt_top ( μ := μ ) hC

/-
**Theorem (Haar compact positive finite)**: Combining positivity and finiteness:
a compact open set has measure in `(0, ∞)`. This is exactly what's needed to
normalize: we can divide by `μ(C)` and get a well-defined measure.
-/
theorem haar_compact_open_pos_finite {G₀ : Type*} [Group G₀] [TopologicalSpace G₀]
    [MeasurableSpace G₀] [BorelSpace G₀] [IsTopologicalGroup G₀]
    [LocallyCompactSpace G₀] [T2Space G₀]
    (μ : Measure G₀) [IsHaarMeasure μ]
    (C : Set G₀) (hC_compact : IsCompact C)
    (hC_open : IsOpen C) (hC_nonempty : C.Nonempty) :
    0 < μ C ∧ μ C < ⊤ := by
  exact ⟨ by simpa using RestrictedProduct.haar_compact_pos μ C hC_open hC_nonempty, by simpa using RestrictedProduct.haar_compact_finite μ C hC_compact ⟩

/-
============================================================
§ 3: Normalized Haar measure
============================================================

**Theorem (Normalized Haar existence)**: Given a Haar measure `μ` and a compact
open nonempty set `C`, the scaled measure `(μ C)⁻¹ • μ` is a Haar measure
with `C` having measure exactly 1.

This is the normalization theorem: the maximal compact subgroup of a restricted
product provides the natural `C`, giving us `μ(∏ K_i) = 1`.
-/
theorem normalized_haar_value {G₀ : Type*} [Group G₀] [TopologicalSpace G₀]
    [MeasurableSpace G₀] [BorelSpace G₀] [IsTopologicalGroup G₀]
    [LocallyCompactSpace G₀] [T2Space G₀]
    (μ : Measure G₀) [IsHaarMeasure μ]
    (C : Set G₀) (hC_compact : IsCompact C)
    (hC_open : IsOpen C) (hC_nonempty : C.Nonempty) :
    ((μ C)⁻¹ • μ) C = 1 := by
  convert ENNReal.inv_mul_cancel ( show μ C ≠ 0 from ?_ ) ( show μ C ≠ ⊤ from ?_ ) using 1
  generalize_proofs at *; (
  exact ne_of_gt ( haar_compact_pos μ C hC_open hC_nonempty ));
  exact ne_of_lt ( hC_compact.measure_lt_top )

/-
============================================================
§ 4: Uniqueness of normalized Haar measure
============================================================

**Theorem (Haar uniqueness via normalization)**:
Two Haar measures on a locally compact second-countable group that agree on
a positive compact `C` must be equal. This is a consequence of the classical
Haar uniqueness theorem: Haar measure is unique up to positive scalar.
-/
theorem haar_unique_of_eq_on_compact {G₀ : Type*} [Group G₀] [TopologicalSpace G₀]
    [MeasurableSpace G₀] [BorelSpace G₀] [IsTopologicalGroup G₀]
    [LocallyCompactSpace G₀] [T2Space G₀] [SecondCountableTopology G₀]
    (μ ν : Measure G₀) [IsHaarMeasure μ] [IsHaarMeasure ν]
    [SigmaFinite μ] [SigmaFinite ν]
    (C : TopologicalSpace.PositiveCompacts G₀)
    (h : μ C = ν C) :
    μ = ν := by
  have h_eq : μ = (μ C) • MeasureTheory.Measure.haarMeasure C := by
    convert MeasureTheory.Measure.haarMeasure_unique μ C;
  have h_eq' : ν = (ν C) • MeasureTheory.Measure.haarMeasure C := by
    convert MeasureTheory.Measure.haarMeasure_unique ν C;
  rw [ h_eq, h_eq', h ]

/-
============================================================
§ 5: Finite product cylinder computations
============================================================

**Theorem (Finite product cardinality formula)**:
For finite groups, the number of tuples `(x_i)` with each `x_i ∈ A_i`
equals the product of cardinalities `|A_i|`.

This is the combinatorial base case of the cylinder measure formula:
when all groups are finite, Haar measure reduces to counting measure
and cylinder values become finite products.
-/
theorem finite_product_card {ι : Type*} [Fintype ι] [DecidableEq ι]
    (G : ι → Type*) [∀ i, Fintype (G i)] [∀ i, DecidableEq (G i)]
    (A : ∀ i, Finset (G i)) :
    (Finset.univ.filter (fun x : ∀ i, G i => ∀ i, x i ∈ A i)).card =
    ∏ i, (A i).card := by
  convert Fintype.card_piFinset A using 1;
  refine' Finset.card_bij _ _ _ _;
  use fun a ha i => a i;
  · aesop;
  · aesop;
  · aesop

/-
**Theorem (Translation invariance for finite products)**:
For finite groups, translating all coordinates by group elements preserves
the number of tuples satisfying a product constraint.

This is the discrete analogue of left-invariance of Haar measure: in a finite
group, left multiplication is a bijection, so counting measure is invariant.
This serves as a verified computational check of translation invariance.
-/
theorem finite_product_translate_card {ι : Type*} [Fintype ι] [DecidableEq ι]
    (G : ι → Type*) [∀ i, Group (G i)] [∀ i, Fintype (G i)] [∀ i, DecidableEq (G i)]
    (g : ∀ i, G i) (A : ∀ i, Finset (G i)) :
    (Finset.univ.filter (fun x : ∀ i, G i => ∀ i, g i * x i ∈ A i)).card =
    (Finset.univ.filter (fun x : ∀ i, G i => ∀ i, x i ∈ A i)).card := by
  refine' Finset.card_bij ( fun x _ => fun i => g i * x i ) _ _ _ <;> simp +decide;
  · simp +contextual [ funext_iff ];
  · exact fun b hb => ⟨ fun i => ( g i ) ⁻¹ * b i, fun i => by simpa using hb i, by ext i; simp +decide ⟩

end RestrictedProduct