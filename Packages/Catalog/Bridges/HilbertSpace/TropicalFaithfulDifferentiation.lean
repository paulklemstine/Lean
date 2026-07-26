/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Tropical Faithfulness of Differentiation

This file establishes a formal dictionary between symbolic differentiation and
tropical/combinatorial geometry: **differentiation is tropically faithful exactly
when valuative non-cancellation prevents coefficient collapse**.

## Main Definitions

* `mixedPartial` — The mixed partial derivative ∂ᵢ(∂ⱼ p).
* `mixedShadow` — The combinatorial shadow: exponents `β` with `β + eᵢ + eⱼ ∈ S`.
* `TropFaithfulDiff` — Predicate: support of mixed partial equals shadow.
* `SecondOrderNonCancellationCertificate` — Certificate for aggregate operators.

## Main Results

* `coeff_pderiv` — Coefficient formula for partial derivatives.
* `support_mixedPartial_iff` — Support of ∂ᵢ∂ⱼp equals mixed shadow (char 0).
* `tropFaithful_of_charZero` — Individual mixed partials are always faithful.
* `support_aggregate_of_certificate` — Certificate ⟹ exact aggregate support.
* `exists_strict_support_inclusion` — Strict inclusion without certificate.
* `newton_subset_of_support_subset` — Newton polytope monotonicity.
* `innerExponent_sub_shift` — Support function shift under shadow translation.
-/

open MvPolynomial Finsupp BigOperators

noncomputable section

variable {K σ : Type*} [Field K] [CharZero K] [DecidableEq σ]

namespace TropicalFaithful

/-! ## Core Definitions -/

/-- The **mixed partial derivative** ∂ᵢ(∂ⱼ p). -/
def mixedPartial (i j : σ) (p : MvPolynomial σ K) : MvPolynomial σ K :=
  MvPolynomial.pderiv i (MvPolynomial.pderiv j p)

/-- The **mixed shadow**: exponents `β` such that `β + eᵢ + eⱼ ∈ S`. -/
def mixedShadow (i j : σ) (S : Finset (σ →₀ ℕ)) : Set (σ →₀ ℕ) :=
  {β | β + Finsupp.single i 1 + Finsupp.single j 1 ∈ S}

/-- **Tropical faithfulness** for mixed partial differentiation. -/
def TropFaithfulDiff (p : MvPolynomial σ K) (i j : σ) : Prop :=
  ∀ β : σ →₀ ℕ,
    β ∈ (mixedPartial i j p).support ↔ β ∈ mixedShadow i j p.support

/-! ## Coefficient Formulas -/

/-
**Coefficient formula for partial derivatives.**
The coefficient of `β` in `∂ᵢ p` is `(β i + 1) * coeff (β + eᵢ) p`.
-/
theorem coeff_pderiv (p : MvPolynomial σ K) (i : σ) (β : σ →₀ ℕ) :
    MvPolynomial.coeff β (MvPolynomial.pderiv i p) =
      (↑(β i + 1) : K) * MvPolynomial.coeff (β + Finsupp.single i 1) p := by
  induction' p using MvPolynomial.induction_on' with p q hp hq; simp_all +decide [ MvPolynomial.coeff_add, MvPolynomial.coeff_C, MvPolynomial.coeff_X, mul_assoc, mul_comm, mul_left_comm, add_mul, mul_add, pow_succ ] ; ring;
  · split_ifs <;> simp_all +decide [ Finsupp.ext_iff ];
    · ring;
    · grind;
  · simp_all +decide [ mul_add, add_mul, MvPolynomial.coeff_add ]

/-- **Scalar nonvanishing in char 0.** The factor `(n+1 : K)` is nonzero. -/
theorem nat_succ_ne_zero_in_charZero (n : ℕ) : (↑(n + 1) : K) ≠ 0 := by
  exact_mod_cast Nat.succ_ne_zero n

/-! ## Theorem 1: Support-level Tropical Faithfulness -/

/-
**Theorem 1 (Support faithfulness).** In characteristic zero,
`β ∈ supp(∂ᵢ∂ⱼ p)` iff `β + eᵢ + eⱼ ∈ supp(p)`.
No certificate needed for individual mixed partials — each output monomial
has exactly one ancestor, and the scalar factor is nonzero in char 0.
-/
theorem support_mixedPartial_iff
    (p : MvPolynomial σ K) (i j : σ) (β : σ →₀ ℕ) :
    β ∈ (mixedPartial i j p).support ↔
      β + Finsupp.single i 1 + Finsupp.single j 1 ∈ p.support := by
  unfold mixedPartial;
  grind +suggestions

/-- Individual mixed partials are always tropically faithful in char 0. -/
theorem tropFaithful_of_charZero (p : MvPolynomial σ K) (i j : σ) :
    TropFaithfulDiff p i j :=
  fun β => support_mixedPartial_iff p i j β

/-! ## Aggregate Mixed Partial Operators -/

/-- An **aggregate mixed partial operator**: K-linear combination of mixed partials. -/
def aggregateMixedPartial [Fintype σ]
    (weights : σ → σ → K) (p : MvPolynomial σ K) : MvPolynomial σ K :=
  ∑ i : σ, ∑ j : σ, weights i j • mixedPartial i j p

/-- The **aggregate shadow**: union of mixed shadows over nonzero weights. -/
def aggregateShadow [Fintype σ]
    (weights : σ → σ → K) (S : Finset (σ →₀ ℕ)) : Set (σ →₀ ℕ) :=
  ⋃ (i : σ) (j : σ) (_ : weights i j ≠ 0), mixedShadow i j S

/-- **Second-order non-cancellation certificate** for aggregate operators.
Asserts that every shadow exponent has nonzero aggregate coefficient. -/
def SecondOrderNonCancellationCertificate [Fintype σ]
    (p : MvPolynomial σ K) (weights : σ → σ → K) : Prop :=
  ∀ β : σ →₀ ℕ,
    β ∈ aggregateShadow weights p.support →
    MvPolynomial.coeff β (aggregateMixedPartial weights p) ≠ 0

/-! ## Theorem 2: Overapproximation -/

/-
**Lemma.** Coefficient of aggregate is sum of weighted mixed partial coefficients.
-/
theorem coeff_aggregateMixedPartial [Fintype σ]
    (weights : σ → σ → K) (p : MvPolynomial σ K) (β : σ →₀ ℕ) :
    MvPolynomial.coeff β (aggregateMixedPartial weights p) =
      ∑ i : σ, ∑ j : σ, weights i j *
        MvPolynomial.coeff β (mixedPartial i j p) := by
  unfold aggregateMixedPartial;
  simp +decide [ MvPolynomial.coeff_sum, MvPolynomial.coeff_smul ]

/-
**Theorem 2 (Overapproximation).**
If `β ∈ supp(aggregate)` then β lies in some individual mixed shadow
with nonzero weight.
-/
theorem support_aggregate_subset [Fintype σ]
    (weights : σ → σ → K) (p : MvPolynomial σ K) (β : σ →₀ ℕ)
    (hβ : β ∈ (aggregateMixedPartial weights p).support) :
    ∃ (i j : σ), weights i j ≠ 0 ∧
      β + Finsupp.single i 1 + Finsupp.single j 1 ∈ p.support := by
  -- By definition of support, there exists some $i$ and $j$ such that the coefficient of $\beta$ in the mixed partial $\partial_i \partial_j p$ is non-zero.
  obtain ⟨i, j, hij⟩ : ∃ i j, weights i j * (MvPolynomial.coeff β (MvPolynomial.pderiv i (MvPolynomial.pderiv j p))) ≠ 0 := by
    contrapose! hβ;
    simp +decide [ aggregateMixedPartial, hβ ];
    simp +decide [ mixedPartial, MvPolynomial.coeff_sum, hβ ];
  exact ⟨ i, j, by aesop, by simpa using ( support_mixedPartial_iff p i j β ).mp ( show β ∈ ( MvPolynomial.pderiv i ( MvPolynomial.pderiv j p ) ).support from by aesop ) ⟩

/-! ## Theorem 3: Certificate implies exactness -/

/-
**Theorem 3 (Certificate ⟹ exactness).**
If the non-cancellation certificate holds, then every shadow exponent
appears in the aggregate support. Combined with Theorem 2, this gives
exact support = shadow under the certificate.
-/
theorem support_aggregate_of_certificate [Fintype σ]
    (weights : σ → σ → K) (p : MvPolynomial σ K)
    (hcert : SecondOrderNonCancellationCertificate p weights) (β : σ →₀ ℕ)
    (hβ : β ∈ aggregateShadow weights p.support) :
    β ∈ (aggregateMixedPartial weights p).support := by
  convert MvPolynomial.mem_support_iff.mpr ( hcert β hβ ) using 1

/-! ## Theorem 4: Strict inclusion counterexample -/

/-- Explicit polynomial: p = X₀² · X₁ + X₀ · X₁² in K[X₀, X₁].
We will show ∂₀∂₁p = ∂₁∂₀p, so the sum 1·∂₀∂₁ + (-1)·∂₁∂₀ = 0,
giving strict inclusion (shadow is nonempty but support is empty). -/
def symmetricPoly : MvPolynomial (Fin 2) K :=
  MvPolynomial.monomial (Finsupp.single 0 2 + Finsupp.single 1 1) (1 : K) +
  MvPolynomial.monomial (Finsupp.single 0 1 + Finsupp.single 1 2) (1 : K)

/-- The antisymmetric weights: w(0,1) = 1, w(1,0) = -1, w(0,0) = w(1,1) = 0.
Under these weights, ∂₀∂₁ and ∂₁∂₀ cancel each other since mixed partials commute. -/
def antisymWeights : Fin 2 → Fin 2 → K :=
  fun i j => if i = 0 ∧ j = 1 then 1 else if i = 1 ∧ j = 0 then -1 else 0

/-
**Theorem 4 (Strict inclusion).**
Mixed partials commute (∂ᵢ∂ⱼ = ∂ⱼ∂ᵢ), so the antisymmetric combination
∂₀∂₁ - ∂₁∂₀ is identically zero. Yet the shadow is nonempty.
This gives a maximally sharp counterexample: the certificate fails and
the shadow strictly over-approximates the (empty) actual support.
-/
theorem pderiv_comm (p : MvPolynomial σ K) (i j : σ) :
    mixedPartial i j p = mixedPartial j i p := by
  -- By definition of partial derivatives, we know that they commute.
  have h_comm : ∀ (p : MvPolynomial σ K) (i j : σ), MvPolynomial.pderiv i (MvPolynomial.pderiv j p) = MvPolynomial.pderiv j (MvPolynomial.pderiv i p) := by
    intro p i j;
    induction p using MvPolynomial.induction_on' <;> simp +decide [ * ];
    by_cases hij : i = j <;> simp +decide [ hij, mul_assoc, mul_comm, mul_left_comm, Finsupp.single_apply ];
    rw [ tsub_right_comm ];
  exact h_comm p i j

/-
The aggregate with antisymmetric weights is zero.
-/
theorem antisym_aggregate_eq_zero (p : MvPolynomial (Fin 2) K) :
    aggregateMixedPartial antisymWeights p = 0 := by
  unfold aggregateMixedPartial antisymWeights; simp +decide [ Fin.sum_univ_two, pderiv_comm ] ;

/-
**Strict inclusion exists.** The shadow is nonempty but the support is empty.
-/
theorem exists_strict_support_inclusion :
    ∃ (p : MvPolynomial (Fin 2) K),
      (aggregateMixedPartial (antisymWeights (K := K)) p).support = ∅ ∧
      (aggregateShadow (antisymWeights (K := K)) p.support).Nonempty := by
  refine' ⟨ _, _, _ ⟩;
  exact MvPolynomial.monomial ( Finsupp.single 0 2 + Finsupp.single 1 1 ) 1 + MvPolynomial.monomial ( Finsupp.single 0 1 + Finsupp.single 1 2 ) 1;
  · rw [ antisym_aggregate_eq_zero ] ; aesop;
  · refine' ⟨ Finsupp.single 0 1, _ ⟩;
    refine' Set.mem_iUnion₂.2 ⟨ 0, 1, _ ⟩;
    simp +decide [ antisymWeights, mixedShadow ];
    simp +decide [ ← two_smul ℕ, Finsupp.single_apply ];
    split_ifs <;> norm_num

/-! ## Convex Hull / Newton Polytope -/

/-- Cast a finsupp to an ℝ-valued function. -/
def exponentToReal (α : σ →₀ ℕ) : σ → ℝ := fun s => (α s : ℝ)

/-- The Newton polytope: convex hull of support vectors cast to ℝ. -/
def newtonPolytopeSet (p : MvPolynomial σ K) : Set (σ → ℝ) :=
  convexHull ℝ (exponentToReal '' ↑p.support)

/-
**Newton polytope monotonicity.** Smaller support ⟹ smaller polytope.
-/
theorem newton_subset_of_support_subset
    (p q : MvPolynomial σ K) (h : q.support ⊆ p.support) :
    newtonPolytopeSet q ⊆ newtonPolytopeSet p := by
  exact convexHull_mono ( Set.image_mono h )

/-
**Newton polytope equality from support equality.**
-/
theorem newton_eq_of_support_eq
    (p q : MvPolynomial σ K) (h : q.support = p.support) :
    newtonPolytopeSet q = newtonPolytopeSet p := by
  unfold newtonPolytopeSet; aesop;

/-! ## Theorem 5: Support Function Shift (Cross-Domain Bridge) -/

/-- Inner product ⟨w, α⟩ for exponent vectors. -/
def innerExponent [Fintype σ] (w : σ → ℝ) (α : σ →₀ ℕ) : ℝ :=
  ∑ s : σ, w s * (α s : ℝ)

/-
**Theorem 5 (Support function shift, distinct variables).**
When `i ≠ j`, subtracting eᵢ + eⱼ from an exponent shifts the inner product by -(wᵢ + wⱼ).
-/
theorem innerExponent_sub_shift [Fintype σ]
    (w : σ → ℝ) (α : σ →₀ ℕ) (i j : σ) (hij : i ≠ j)
    (hi : 1 ≤ α i) (hj : 1 ≤ α j) :
    innerExponent w (α - Finsupp.single i 1 - Finsupp.single j 1) =
      innerExponent w α - (w i + w j) := by
  unfold innerExponent;
  rw [ Finset.sum_congr rfl fun x hx => ?_ ];
  rotate_left;
  use fun x => w x * α x - w x * ( if i = x then 1 else 0 ) - w x * ( if j = x then 1 else 0 );
  · split_ifs <;> simp_all +decide; all_goals ring;
  · simp +decide [ Finset.sum_sub_distrib ] ; ring

end TropicalFaithful

end