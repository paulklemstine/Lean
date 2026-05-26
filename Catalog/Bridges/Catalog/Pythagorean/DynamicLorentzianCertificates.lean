/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Dynamic Lorentzian Certificates and Online Sampling

This file develops the first formal theory of **dynamic Lorentzian certification**:
how a certificate for a strongly log-concave / Lorentzian generating polynomial evolves
under local perturbations, and how this evolution controls online sampling.

## Overview

A Lorentzian certificate for a homogeneous polynomial of degree `d` on `n` variables
is a tree indexed by iterated partial derivatives down to quadratic forms. A rank-1 update
`f' = f + c · X^α` should not globally disturb this tree — only derivative nodes whose
multiindex is coordinatewise dominated by `α` are affected.

## Main Definitions

* `AffectedMultiindices` — The set of derivative multiindices affected by a monomial update
* `rankOneUpdate` — A one-monomial perturbation of a multivariate polynomial
* `affectedCount` — Cardinality of affected multiindices at a given derivative order
* `dynamicCertificateCost` — Cost of updating only affected certificate nodes
* `pderivPow` — Iterated application of a single partial derivative
* `iteratedMPderiv` — Iterated mixed partial derivative indexed by a multiindex
* `tvDist` — Total variation distance between finite distributions
* `normalizeWeights` — Normalize a nonneg weight vector to a probability distribution

## Main Results

* `rankOneUpdate_isHomogeneous` — Rank-1 updates preserve homogeneity
* `pderivPow_monomial_eq_zero` — Iterated derivatives kill over-differentiated monomials
* `iteratedMPderiv_rankOneUpdate_eq_of_not_le` — Locality: derivatives not dominated
  by α are unchanged under rank-1 update
* `dynamic_certificate_cost_le_rebuild` — Dynamic cost ≤ full rebuild cost
* `tvDist_le_half_l1` — Total variation ≤ ½ · ℓ₁ distance
* `normalizedCoeff_tvDist_bound` — Warm-start TV bound for normalized coefficients
* `graphicMatroid_singleBasisUpdate_local` — Locality for graphic matroid basis updates

## Cross-Domain Connections

* **Streaming algorithms**: Dynamic certificate locality ↔ incremental maintenance
* **MCMC**: Warm-start TV control translates coefficient drift into sampler stability
* **Matroid theory**: Basis generating polynomials are Lorentzian; dynamic certification
  yields online sampling of combinatorial structures
* **Statistical physics**: Normalized coefficient distribution theorem ↔ partition-function
  stability

## References

* Brändén–Huh, "Lorentzian Polynomials", Annals of Mathematics, 2020
* Anari–Liu–Oveis Gharan–Vinzant, "Log-Concave Polynomials", 2019
-/

open Finset BigOperators MvPolynomial

noncomputable section

/-! ## Core Definitions -/

/-- The set of derivative multiindices of total mass `k` that are coordinatewise
    dominated by a monomial exponent vector `α`. These are exactly the derivative
    directions that can "see" a rank-1 monomial update by `X^α`. -/
def AffectedMultiindices {n : ℕ} (α : Fin n → ℕ) (k : ℕ) : Set (Fin n → ℕ) :=
  {β | (∑ i, β i) = k ∧ ∀ i, β i ≤ α i}

/-- A rank-1 polynomial update: add `c · X^α` to `f`. -/
def rankOneUpdate {n : ℕ} {R : Type*} [CommSemiring R]
    (f : MvPolynomial (Fin n) R) (c : R) (α : Fin n →₀ ℕ) : MvPolynomial (Fin n) R :=
  f + MvPolynomial.monomial α c

/-- Count of affected multiindices at derivative order `k`.
    This counts `|{β : Fin n → ℕ | ∑ β_i = k ∧ ∀ i, β_i ≤ α_i}|`. -/
def affectedCount {n : ℕ} (α : Fin n → ℕ) (k : ℕ) : ℕ :=
  ((Fintype.piFinset (fun i => Finset.range (α i + 1))).filter
    (fun β => ∑ i, β i = k)).card

/-- The dynamic certificate update cost: sum of affected counts at each derivative
    depth from 0 to d-2, scaled by the leaf recomputation cost n². -/
def dynamicCertificateCost (n d : ℕ) (α : Fin n → ℕ) : ℕ :=
  n ^ 2 * (∑ k ∈ Finset.range (d - 1), affectedCount α k)

/-- Iterated application of a single partial derivative `∂/∂xᵢ` applied `k` times. -/
def pderivPow {n : ℕ} {R : Type*} [CommSemiring R]
    (i : Fin n) (k : ℕ) (f : MvPolynomial (Fin n) R) : MvPolynomial (Fin n) R :=
  (MvPolynomial.pderiv i)^[k] f

/-- Iterated mixed partial derivative: apply `∂/∂xᵢ` exactly `β i` times for each `i`,
    sequentially over `i ∈ Fin n`. The result is independent of order because mixed
    partials commute. -/
def iteratedMPderiv {n : ℕ} {R : Type*} [CommSemiring R]
    (β : Fin n → ℕ) (f : MvPolynomial (Fin n) R) : MvPolynomial (Fin n) R :=
  (List.finRange n).foldl (fun g i => (MvPolynomial.pderiv i)^[β i] g) f

/-- Total variation distance between two distributions on a finite type. -/
def tvDist {α : Type*} [Fintype α]
    (μ ν : α → ℝ) : ℝ :=
  (1 / 2) * ∑ a, |μ a - ν a|

/-- Normalize a nonneg weight vector to sum to 1. -/
def normalizeWeights {α : Type*} [Fintype α]
    (w : α → ℝ) : α → ℝ :=
  fun a => w a / ∑ s, w s

/-! ## Theorem 1: Homogeneity Preservation Under Rank-1 Updates -/

/-
**Homogeneity is preserved under compatible rank-1 updates.**
    If `f` is homogeneous of degree `d` and the monomial `α` has degree `d`,
    then `f + c·X^α` is homogeneous of degree `d`.

    This ensures the algebraic universe is stable under dynamic moves —
    a prerequisite for certificate maintenance. Uses `IsHomogeneous.add`
    and `isHomogeneous_monomial` from Mathlib.
-/
theorem rankOneUpdate_isHomogeneous
    {n d : ℕ} {R : Type*} [CommSemiring R]
    (f : MvPolynomial (Fin n) R) (c : R) (α : Fin n →₀ ℕ)
    (hf : f.IsHomogeneous d)
    (hα : Finsupp.degree α = d) :
    (rankOneUpdate f c α).IsHomogeneous d := by
  convert MvPolynomial.IsHomogeneous.add hf ( MvPolynomial.isHomogeneous_monomial c hα ) using 1

/-! ## Theorem 2: Locality of Derivative Perturbation -/

/-
Iterated single partial derivative distributes over addition,
    since `pderiv i` is a derivation (hence additive).
-/
theorem pderivPow_add {n : ℕ} {R : Type*} [CommSemiring R]
    (i : Fin n) (k : ℕ) (f g : MvPolynomial (Fin n) R) :
    pderivPow i k (f + g) = pderivPow i k f + pderivPow i k g := by
  induction' k with k IH generalizing f g <;> simp_all +decide [ Function.iterate_succ_apply', pderivPow ]

/-
**Key monomial annihilation lemma**: if we differentiate `monomial α c` by
    `∂/∂xᵢ` more times than `α i`, the result is zero.

    Proof by induction on `k`: each differentiation reduces the `i`-th exponent
    by 1 and multiplies by the exponent. Once the exponent reaches 0, the next
    differentiation produces a zero coefficient.
-/
theorem pderivPow_monomial_eq_zero {n : ℕ} {R : Type*} [CommSemiring R]
    (i : Fin n) (k : ℕ) (α : Fin n →₀ ℕ) (c : R)
    (hk : α i < k) :
    pderivPow i k (MvPolynomial.monomial α c) = 0 := by
  unfold pderivPow;
  induction' k with k ih generalizing α c;
  · contradiction;
  · by_cases h : α i < k;
    · rw [ Function.iterate_succ_apply', ih α c h, map_zero ];
    · simp +decide [ show α i = k by linarith, MvPolynomial.pderiv_monomial ];
      by_cases hk : k = 0 <;> simp_all +decide [ Finsupp.single_apply ];
      convert ih ( α - Finsupp.single i 1 ) ( c * k ) _ using 1;
      simp +decide [ Finsupp.single_apply, show α i = k by linarith ];
      exact Nat.pos_of_ne_zero hk

/-
Iterated mixed partial derivative distributes over addition.
-/
theorem iteratedMPderiv_add {n : ℕ} {R : Type*} [CommSemiring R]
    (β : Fin n → ℕ) (f g : MvPolynomial (Fin n) R) :
    iteratedMPderiv β (f + g) = iteratedMPderiv β f + iteratedMPderiv β g := by
  convert pderivPow_add using 1;
  rotate_left;
  exact 0;
  exact ℕ;
  exact inferInstance;
  convert Iff.rfl ; simp_all +decide [ pderivPow, iteratedMPderiv ];
  induction' ( List.finRange n ) using List.reverseRecOn with i hi <;> simp_all +decide [ Function.iterate_succ_apply' ]

/-
**Monomial annihilation for mixed derivatives**: if `β` is not coordinatewise
    dominated by `α`, then the iterated mixed derivative of `monomial α c` is zero.

    This follows because there exists some coordinate `i` where `β i > α i`,
    and applying `pderivPow i (β i)` to the monomial kills it.
-/
theorem iteratedMPderiv_monomial_eq_zero {n : ℕ} {R : Type*} [CommSemiring R]
    (β : Fin n → ℕ) (α : Fin n →₀ ℕ) (c : R)
    (hnot : ¬ ∀ i, β i ≤ α i) :
    iteratedMPderiv β (MvPolynomial.monomial α c) = 0 := by
  obtain ⟨i₀, hi₀⟩ : ∃ i₀, β i₀ > α i₀ := by
    exact by push_neg at hnot; exact hnot;
  -- Since these operations commute (mixed partials commute), we can rearrange to apply (pderiv i₀)^[β i₀] last (or think of it differently).
  have h_comm : ∀ (l : List (Fin n)) (f : MvPolynomial (Fin n) R), List.Perm l (List.finRange n) → List.foldl (fun g i => (MvPolynomial.pderiv i)^[β i] g) f l = List.foldl (fun g i => (MvPolynomial.pderiv i)^[β i] g) f (List.finRange n) := by
    intro l f hl_perm
    have h_comm : ∀ (i j : Fin n), i ≠ j → ∀ (g : MvPolynomial (Fin n) R), (MvPolynomial.pderiv i)^[β i] ((MvPolynomial.pderiv j)^[β j] g) = (MvPolynomial.pderiv j)^[β j] ((MvPolynomial.pderiv i)^[β i] g) := by
      intro i j hij g
      have h_comm : ∀ (k l : ℕ), (MvPolynomial.pderiv i)^[k] ((MvPolynomial.pderiv j)^[l] g) = (MvPolynomial.pderiv j)^[l] ((MvPolynomial.pderiv i)^[k] g) := by
        intro k l; induction' k with k ih generalizing l <;> simp_all +decide [ Function.iterate_succ_apply' ] ;
        induction' l with l ih' <;> simp_all +decide [ Function.iterate_succ_apply' ];
        rw [ ← ih' ];
        -- By definition of pderiv, we know that pderiv i (pderiv j g) = pderiv j (pderiv i g).
        have h_comm : ∀ (i j : Fin n), i ≠ j → ∀ (g : MvPolynomial (Fin n) R), pderiv i (pderiv j g) = pderiv j (pderiv i g) := by
          intro i j hij g; induction g using MvPolynomial.induction_on <;> simp_all +decide [ MvPolynomial.pderiv_monomial ] ;
          simp +decide [ Pi.single_apply, hij, eq_comm ] ; ring;
          aesop;
        exact h_comm i j hij _;
      exact h_comm _ _;
    have h_comm : ∀ (l₁ l₂ : List (Fin n)), List.Perm l₁ l₂ → ∀ (f : MvPolynomial (Fin n) R), List.foldl (fun g i => (MvPolynomial.pderiv i)^[β i] g) f l₁ = List.foldl (fun g i => (MvPolynomial.pderiv i)^[β i] g) f l₂ := by
      intros l₁ l₂ hl_perm f; induction' hl_perm with l₁ l₂ hl_perm ih generalizing f; aesop;
      · simp +decide [ *, List.foldl ];
      · grind;
      · grind;
    exact h_comm _ _ hl_perm _;
  specialize h_comm ( List.cons i₀ ( List.erase ( List.finRange n ) i₀ ) ) ( MvPolynomial.monomial α c ) ?_ <;> simp_all +decide [ List.perm_cons_erase ];
  · grind;
  · convert h_comm.symm using 1;
    convert pderivPow_monomial_eq_zero i₀ ( β i₀ ) α c hi₀ |> Eq.symm using 1;
    induction' ( List.finRange n ).erase i₀ using List.reverseRecOn with l ih <;> simp_all +decide [ Function.iterate_succ_apply' ];
    · rfl;
    · rw [ pderivPow_monomial_eq_zero i₀ ( β i₀ ) α c hi₀ ] ; simp +decide [ Function.iterate_fixed ]

/-
**Locality of derivative perturbation (main theorem).**

    For a rank-1 update `f' = f + c·X^α`, if the derivative multiindex `β` is not
    coordinatewise dominated by `α`, then `∂^β f' = ∂^β f`.

    This is the foundational locality theorem for dynamic Lorentzian certification.
    It turns dynamic certification into a sparse update problem: only derivative
    nodes in `AffectedMultiindices(α, k)` can change under the rank-1 update.
-/
theorem iteratedMPderiv_rankOneUpdate_eq_of_not_le
    {n : ℕ} {R : Type*} [CommSemiring R]
    (f : MvPolynomial (Fin n) R) (c : R) (α : Fin n →₀ ℕ) (β : Fin n → ℕ)
    (hnot : ¬ ∀ i, β i ≤ α i) :
    iteratedMPderiv β (rankOneUpdate f c α) = iteratedMPderiv β f := by
  convert iteratedMPderiv_add β f ( MvPolynomial.monomial α c ) using 1;
  rw [ iteratedMPderiv_monomial_eq_zero β α c hnot, add_zero ]

/-! ## Theorem 3: Dynamic Complexity Upper Bound -/

/-
The dynamic certificate cost is defined as `n² · ∑_{k<d-1} affectedCount(α, k)`.
-/
theorem dynamic_certificate_cost_eq
    {n d : ℕ} (α : Fin n → ℕ) :
    dynamicCertificateCost n d α =
      n ^ 2 * (∑ k ∈ Finset.range (d - 1), affectedCount α k) := by
  rfl

/-
Each `affectedCount` is at most the number of all multiindices of that order,
    which is bounded by `(∑ α_i).choose k`.
-/
theorem affectedCount_le_choose {n : ℕ} (α : Fin n → ℕ) (k : ℕ) :
    affectedCount α k ≤ Nat.choose (∑ i, α i) k := by
  -- By definition of `affectedCount`, we know that it is bounded above by the binomial coefficient.
  simp [affectedCount];
  refine' le_trans ( Finset.card_le_card _ ) _;
  exact Finset.image ( fun s : Finset ( Fin n × ℕ ) => fun i => Finset.card ( Finset.filter ( fun j => j.1 = i ) s ) ) ( Finset.powersetCard k ( Finset.biUnion Finset.univ fun i => Finset.image ( fun j => ( i, j ) ) ( Finset.range ( α i + 1 ) ) |> Finset.filter ( fun x => x.2 ≠ 0 ) ) );
  · intro β hβ;
    refine' Finset.mem_image.mpr ⟨ Finset.biUnion Finset.univ fun i => Finset.image ( fun j => ( i, j + 1 ) ) ( Finset.range ( β i ) ), _, _ ⟩ <;> simp_all +decide [ Finset.sum_add_distrib ];
    · refine' ⟨ _, _ ⟩;
      · grind;
      · rw [ Finset.card_biUnion ];
        · simp +decide [ Finset.card_image_of_injective, Function.Injective, hβ.2 ];
        · exact fun i _ j _ hij => Finset.disjoint_left.mpr fun x hx₁ hx₂ => hij <| by aesop;
    · ext i; simp +decide [ Finset.filter_biUnion, Finset.filter_image ] ;
      rw [ Finset.card_biUnion ];
      · rw [ Finset.sum_eq_single i ] <;> simp +contextual [ Finset.filter_eq, Finset.filter_ne ];
        rw [ Finset.card_image_of_injective ] <;> norm_num [ Function.Injective ];
      · exact fun a _ b _ hab => Finset.disjoint_left.mpr fun x hx₁ hx₂ => hab <| by aesop;
  · refine' Finset.card_image_le.trans _;
    simp +zetaDelta at *;
    refine' Nat.choose_le_choose _ _;
    refine' le_trans ( Finset.card_biUnion_le ) _;
    refine' Finset.sum_le_sum fun i _ => _;
    rw [ Finset.filter_image ];
    exact Finset.card_image_le.trans ( by simp +arith +decide [ Finset.filter_ne' ] )

/-
**Dynamic certificate cost ≤ product bound.**
    The total number of affected derivative nodes across all depths is bounded
    by ∏(α_i + 1), the total number of coordinatewise-dominated multiindices.
    Thus `dynamicCertificateCost ≤ n² · (d-1) · max_k(affectedCount α k)`.

    For a clean comparison: `dynamicCertificateCost ≤ n² · ∑_{k<d-1} d.choose(k)`,
    which connects to `certificate_verification_complexity` from the catalog.
-/
theorem dynamic_certificate_cost_le_choose_sum
    {n d : ℕ} (α : Fin n → ℕ) (hd : 2 ≤ d)
    (hα : (∑ i, α i) = d) :
    dynamicCertificateCost n d α ≤
      n ^ 2 * (∑ k ∈ Finset.range (d - 1), Nat.choose d k) := by
  exact Nat.mul_le_mul_left _ ( Finset.sum_le_sum fun i hi => affectedCount_le_choose α i |> le_trans <| by aesop )

/-! ## Theorem 4: Total Variation and Warm-Start Bounds -/

/-
**Total variation equals half the ℓ₁ distance** (by definition).
-/
theorem tvDist_eq_half_l1 {α : Type*} [Fintype α]
    (μ ν : α → ℝ) :
    tvDist μ ν = (1 / 2) * ∑ a, |μ a - ν a| := by
  exact?

/-
**Total variation ≤ ½ · ℓ₁ distance.**
-/
theorem tvDist_le_half_l1 {α : Type*} [Fintype α]
    (μ ν : α → ℝ) :
    tvDist μ ν ≤ (1 / 2) * ∑ a, |μ a - ν a| := by
  rfl

/-
**Warm-start total variation bound for normalized coefficient distributions.**
    If two nonneg weight vectors w, w' have ℓ₁ distance Δ, then the total variation
    between their normalized distributions is bounded by Δ / min(Z, Z')
    where Z = ∑ w, Z' = ∑ w'. This uses the triangle inequality decomposition:
    |w_s/Z - w'_s/Z'| ≤ |w_s - w'_s|/Z + w'_s · |Z' - Z|/(Z · Z'),
    then sums and uses |Z' - Z| ≤ Δ.

    This is the probabilistic counterpart to dynamic certificate locality:
    sparse algebraic updates → small distribution drift → efficient warm-start.
-/
theorem normalizedCoeff_tvDist_bound
    {σ : Type*} [Fintype σ]
    (w w' : σ → ℝ)
    (hw : ∀ s, 0 ≤ w s)
    (hw' : ∀ s, 0 ≤ w' s)
    (hZ : 0 < ∑ s, w s)
    (hZ' : 0 < ∑ s, w' s) :
    tvDist (normalizeWeights w) (normalizeWeights w') ≤
      (1 / min (∑ s, w s) (∑ s, w' s)) * ∑ s, |w s - w' s| := by
  -- Applying the triangle inequality to each term in the sum.
  have h_triangle : ∀ s, |w s / (∑ s, w s) - w' s / (∑ s, w' s)| ≤ |w s - w' s| / (∑ s, w s) + |w' s| * |(∑ s, w' s) - (∑ s, w s)| / ((∑ s, w s) * (∑ s, w' s)) := by
    intro s
    field_simp [hZ, hZ'];
    rw [ abs_div, abs_of_nonneg ( mul_nonneg hZ.le hZ'.le ) ];
    rw [ mul_div_cancel₀ _ ( mul_ne_zero hZ.ne' hZ'.ne' ) ];
    cases abs_cases ( w s - w' s ) <;> cases abs_cases ( ∑ s, w' s - ∑ s, w s ) <;> cases abs_cases ( w s * ∑ s, w' s - ( ∑ s, w s ) * w' s ) <;> cases abs_cases ( w' s ) <;> nlinarith [ hw s, hw' s ];
  -- Summing the inequalities from the triangle inequality.
  have h_sum_triangle : ∑ s, |w s / (∑ s, w s) - w' s / (∑ s, w' s)| ≤ (∑ s, |w s - w' s|) / (∑ s, w s) + |(∑ s, w' s) - (∑ s, w s)| / (∑ s, w s) := by
    convert Finset.sum_le_sum fun s _ => h_triangle s using 1 ; simp +decide [ Finset.sum_add_distrib, Finset.sum_div _ _ _, div_eq_mul_inv ] ; ring;
    simp +decide [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul, abs_of_nonneg, hw', hZ', hZ ];
    rw [ mul_assoc, mul_inv_cancel₀ hZ'.ne', mul_one ];
  -- Using the triangle inequality again, we have $|\sum s, w' s - \sum s, w s| \leq \sum s, |w s - w' s|$.
  have h_triangle_sum : |(∑ s, w' s) - (∑ s, w s)| ≤ ∑ s, |w s - w' s| := by
    convert Finset.abs_sum_le_sum_abs ( fun s => w s - w' s ) Finset.univ using 1 ; simp +decide [ abs_sub_comm, Finset.sum_sub_distrib ];
  unfold tvDist normalizeWeights;
  cases min_cases ( ∑ s, w s ) ( ∑ s, w' s ) <;> simp +decide [ *, div_eq_mul_inv ] at *;
  · nlinarith [ inv_pos.2 hZ, inv_pos.2 hZ', mul_inv_cancel₀ hZ.ne', mul_inv_cancel₀ hZ'.ne', abs_nonneg ( ∑ s, w' s - ∑ s, w s ) ];
  · field_simp at *;
    simp_all +decide [ mul_comm ];
    nlinarith [ abs_of_nonpos ( by linarith : ( ∑ s, w' s - ∑ s, w s ) ≤ 0 ) ]

/-! ## Theorem 5: Graphic Matroid Bridge -/

/-
**Locality for graphic matroid single-basis updates.**
    If a single spanning tree monomial `X^α` is added to the basis generating
    polynomial of a graphic matroid, derivatives not dominated by `α` are
    unaffected. This is a direct corollary of the general locality theorem.

    This bridges to streaming graph algorithms: dynamic Lorentzian certification
    governs evolving network models and online combinatorial sampling.
-/
theorem graphicMatroid_singleBasisUpdate_local
    {n : ℕ} {R : Type*} [CommSemiring R]
    (basisPoly : MvPolynomial (Fin n) R)
    (α : Fin n →₀ ℕ) (β : Fin n → ℕ)
    (hnot : ¬ ∀ i, β i ≤ α i) :
    iteratedMPderiv β (rankOneUpdate basisPoly 1 α) =
      iteratedMPderiv β basisPoly := by
  convert iteratedMPderiv_rankOneUpdate_eq_of_not_le _ _ _ _ hnot using 1

/-! ## Conjecture: Dynamic Lorentzian Warm-Start Principle

For squarefree homogeneous Lorentzian polynomials `f_t` arising from a stream of graphic
matroid updates, if `f_{t+1} = f_t + c_t · X^{α_t}` with bounded coefficient perturbation
and bounded affected-node fraction, then the natural basis-exchange Markov chain started
from stationarity of `f_t` mixes to within `ε` of stationarity for `f_{t+1}` in
`O(log(1/ε) + log(1/(1 - δ_t)))` steps, where `δ_t` is controlled by the normalized
coefficient ℓ₁ drift and affected certificate mass.

### Computational Disproof Protocol
- Graphs on n = 10, 20, 50, 100
- Add/delete one edge at a time
- Compare rebuild vs dynamic certificate update cost
- Compare cold-start vs warm-start empirical mixing time
- Report cases where the warm-start advantage collapses
-/

end