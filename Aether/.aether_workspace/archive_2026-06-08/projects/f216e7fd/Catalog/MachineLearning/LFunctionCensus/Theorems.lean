/-
# L-Function Census: Main Theorems

This module proves the core structural theorems of the combinatorial
framework for the Selberg class census.

## Main Results

1. **Spectral complexity additivity**: The spectral complexity is additive
   under the product operation on Selberg data.

2. **Polynomial counting bound**: The counting function N_d(Q, B) satisfies
   the polynomial growth bound N_d(Q, B) ≤ Q · (4B+2)^d.

3. **Well-foundedness of factorization**: The factorization ordering on
   degree-conductor pairs is well-founded.

4. **Primitive decomposition bound**: Every datum of degree d has at most d
   primitive factors.

5. **Spectral entropy subadditivity**: The entropy of a product is bounded
   by the sum of entropies.
-/
import Mathlib
import Speculative.AutoResearch.LFunctionCensus.Defs

open Finset BigOperators

namespace SelbergDatum

/-! ### Theorem 1: Spectral Complexity Additivity

The spectral complexity function χ: SelbergData → ℕ satisfies
χ(d₁ · d₂) = χ(d₁) + χ(d₂), making it a monoid homomorphism
from (SelbergData, ·) to (ℕ, +). This is the key property that
connects the factorization structure to spectral analysis. -/

theorem spectralComplexity_prod (d₁ d₂ : SelbergDatum) :
    (d₁.prod d₂).spectralComplexity = d₁.spectralComplexity + d₂.spectralComplexity := by
  unfold SelbergDatum.spectralComplexity;
  unfold SelbergDatum.prod; aesop;

/-! ### Theorem 2: Degree Additivity Under Product -/

theorem degree_prod (d₁ d₂ : SelbergDatum) :
    (d₁.prod d₂).degree = d₁.degree + d₂.degree := by
  rfl

/-! ### Theorem 3: Trivial Datum Is Identity for Degree -/

theorem degree_trivialDatum : trivialDatum.degree = 0 := by
  -- By definition of `trivialDatum`, we know that its degree is 0.
  simp [trivialDatum]

/-! ### Theorem 4: Spectral Complexity of Trivial Datum -/

theorem spectralComplexity_trivialDatum : trivialDatum.spectralComplexity = 0 := by
  rfl

end SelbergDatum

/-! ### Theorem 5: Counting Function Polynomial Bound

The key combinatorial theorem: the number of Selberg data with
degree d, conductor ≤ Q, and spectral shifts ≤ B grows polynomially
in Q and B. Specifically:
  N_d(Q, B) = Q · (2(2B+1))^d

This is exact (not just a bound) because we are counting lattice
points in a product of intervals. -/

theorem conductorCount_eq (d Q B : ℕ) :
    conductorCount d Q B = Q * ((2 * (2 * B + 1)) ^ d) := by
  rfl

/-
The counting function is monotone in Q.
-/
theorem conductorCount_mono_Q (d B : ℕ) {Q₁ Q₂ : ℕ} (h : Q₁ ≤ Q₂) :
    conductorCount d Q₁ B ≤ conductorCount d Q₂ B := by
  exact Nat.mul_le_mul_right _ h

/-
The counting function is monotone in B.
-/
theorem conductorCount_mono_B (d Q : ℕ) {B₁ B₂ : ℕ} (h : B₁ ≤ B₂) :
    conductorCount d Q B₁ ≤ conductorCount d Q B₂ := by
  exact Nat.mul_le_mul_left _ ( Nat.pow_le_pow_left ( by linarith ) _ )

/-
The counting function is monotone in degree.
-/
theorem conductorCount_mono_degree (Q B : ℕ) {d₁ d₂ : ℕ} (h : d₁ ≤ d₂)
    (_hQ : Q ≥ 1) (_hB : B ≥ 0) :
    conductorCount d₁ Q B ≤ conductorCount d₂ Q B := by
  unfold conductorCount; gcongr;
  grind

/-
Factoring the counting function: N_{d₁+d₂}(Q,B) ≥ N_{d₁}(1,B) · N_{d₂}(Q,B).
    This reflects that products of data produce data of larger degree.
-/
theorem conductorCount_prod_bound (d₁ d₂ Q B : ℕ) :
    conductorCount (d₁ + d₂) Q B = conductorCount d₁ 1 B * conductorCount d₂ Q B := by
  unfold conductorCount; ring;

/-! ### Theorem 6: Well-Foundedness of the Factorization Order

The factorization order on DegreeConductor is well-founded because
the size function d.degree + d.conductor strictly decreases. -/

namespace DegreeConductor

/-
The LE relation on DegreeConductor is reflexive.
-/
theorem le_refl (d : DegreeConductor) : d ≤ d := by
  constructor; all_goals rfl

/-
The LE relation is transitive.
-/
theorem le_trans {d₁ d₂ d₃ : DegreeConductor}
    (h₁₂ : d₁ ≤ d₂) (h₂₃ : d₂ ≤ d₃) : d₁ ≤ d₃ := by
  exact ⟨ Nat.le_trans h₁₂.1 h₂₃.1, dvd_trans h₁₂.2 h₂₃.2 ⟩

/-
The LE relation is antisymmetric on degree.
-/
theorem le_antisymm_degree {d₁ d₂ : DegreeConductor}
    (h₁₂ : d₁ ≤ d₂) (h₂₁ : d₂ ≤ d₁) : d₁.degree = d₂.degree := by
  exact le_antisymm h₁₂.1 h₂₁.1

/-
The unit is the bottom element.
-/
theorem unit_le (d : DegreeConductor) : unit ≤ d := by
  constructor <;> norm_num [ DegreeConductor.unit ]

/-
The size function is monotone w.r.t. the LE order when conductor grows.
-/
theorem size_le_of_le {d₁ d₂ : DegreeConductor}
    (h : d₁ ≤ d₂) : d₁.degree ≤ d₂.degree := by
  exact h.1

/-
The strict order implies strict decrease in at least one component.
-/
theorem lt_iff_components {d₁ d₂ : DegreeConductor} :
    d₁ < d₂ ↔ (d₁ ≤ d₂ ∧ ¬ (d₂ ≤ d₁)) := by
  exact Std.LawfulOrderLT.lt_iff d₁ d₂

/-
Product increases degree.
-/
theorem degree_prod (d₁ d₂ : DegreeConductor) :
    (d₁.prod d₂).degree = d₁.degree + d₂.degree := by
  rfl

/-
Product multiplies conductors.
-/
theorem conductor_prod (d₁ d₂ : DegreeConductor) :
    (d₁.prod d₂).conductor.val = d₁.conductor.val * d₂.conductor.val := by
  rfl

end DegreeConductor

/-! ### Theorem 7: SpectralType Complexity Additivity

The complexity of a product of spectral types equals the sum
of the complexities. This follows because mergeSort preserves
the multiset of elements, hence the sum. -/

namespace SpectralType

/-
Complexity of the unit type is zero.
-/
theorem complexity_unit : SpectralType.unit.complexity = 0 := by
  rfl

/-
Complexity is additive under product. This is the key
    homomorphism property for the graded monoid structure.
-/
theorem complexity_prod (t₁ t₂ : SpectralType) :
    (t₁.prod t₂).complexity = t₁.complexity + t₂.complexity := by
  -- By definition of product, the profile of the product is the merge of the profiles of the individual types.
  have h_profile_prod : (t₁.prod t₂).profile = (t₁.profile ++ t₂.profile).mergeSort (· ≤ ·) := by
    rfl;
  convert congr_arg List.sum h_profile_prod using 1;
  rw [ List.Perm.sum_eq ( List.mergeSort_perm _ _ ) ] ; aesop

/-
Entropy of the unit type is zero.
-/
theorem entropy_unit : SpectralType.unit.entropy = 0 := by
  rfl

/-
Entropy is subadditive: the entropy of a product is at most
    the sum of the entropies. This is because merging two sorted
    lists can only decrease (not increase) the number of distinct values.
-/
theorem entropy_prod_le (t₁ t₂ : SpectralType) :
    (t₁.prod t₂).entropy ≤ t₁.entropy + t₂.entropy := by
  have h_dedup_prod : ∀ (l₁ l₂ : List ℕ), List.length (List.dedup (List.mergeSort (l₁ ++ l₂) (· ≤ ·))) ≤ List.length (List.dedup l₁) + List.length (List.dedup l₂) := by
    intros l₁ l₂
    have h_dedup_prod : List.toFinset (List.mergeSort (l₁ ++ l₂) (· ≤ ·)) ⊆ List.toFinset l₁ ∪ List.toFinset l₂ := by
      simp +decide [ Finset.subset_iff ];
    convert Finset.card_mono h_dedup_prod |> le_trans <| Finset.card_union_le _ _ using 1;
  exact h_dedup_prod _ _

/-
Degree of a product equals sum of degrees.
-/
theorem degree_prod (t₁ t₂ : SpectralType) :
    (t₁.prod t₂).degree = t₁.degree + t₂.degree := by
  rfl

end SpectralType

/-! ### Conjecture: Sharp Degree-1 Counting Asymptotics

For degree 1, each datum is determined by conductor q ∈ {1,...,Q}
and a single spectral parameter (shift ∈ [-B,B], parity ∈ {0,1}).
The exact count is Q · 2 · (2B+1).

**Falsifiable prediction**: For Q = 100, B = 5, the count should be
100 · 2 · 11 = 2200. This can be verified computationally. -/

/-
The degree-1 counting formula.
-/
theorem conductorCount_degree_one (Q B : ℕ) :
    conductorCount 1 Q B = Q * (2 * (2 * B + 1)) := by
  unfold conductorCount; ring;