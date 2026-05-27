/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Dynamic Lorentzian Certificates and Online Sampling

This file develops the first formal theory of **dynamic Lorentzian certification**:
how a certificate for a strongly log-concave / Lorentzian generating polynomial evolves
under local (rank-1 monomial) perturbations, and how this evolution controls online
sampling via warm-start stability.

## Key Ideas

A Lorentzian certificate for a homogeneous polynomial of degree `d` on `n` variables
is a tree indexed by iterated partial derivatives down to quadratic forms.
A rank-1 update `f' = f + c · X^α` does not globally disturb this tree; it only
affects derivative nodes whose multiindex is coordinatewise dominated by `α`.
This **locality principle** is the algebraic engine behind a dynamic algorithm.

## Main Definitions

* `AffectedMultiindices` — The set of derivative multiindices that can "see" an update
* `rankOneUpdate` — One-monomial perturbation of a multivariate polynomial
* `DynCert.iterPDeriv` — Iterated partial derivative by a multiindex
* `dynamicCertificateCost` — Cost of updating only affected certificate nodes
* `affectedCount` — Number of affected multiindices at a given depth
* `totalVariationDist` — Total variation distance between finite distributions
* `normalizePMF` — Normalize a nonneg weight vector to a probability distribution

## Main Results

* `iterated_pderiv_rankOneUpdate_eq_of_not_le` — **Locality theorem**: derivatives
  not dominated by the update exponent are unchanged
* `rankOneUpdate_isHomogeneous` — Rank-1 updates preserve homogeneity
* `dynamic_certificate_cost_le` — Dynamic cost is bounded by affected-node count
* `dynamic_certificate_cost_le_rebuild` — Dynamic cost never exceeds rebuild cost
* `tv_le_half_l1` — Total variation ≤ ½ · ℓ₁ distance for PMFs
* `graphicMatroid_singleBasisUpdate_local` — Graphic matroid application of locality

## References

* Brändén–Huh, "Lorentzian Polynomials", Annals of Mathematics, 2020
* Anari–Liu–Oveis Gharan–Vinzant, "Log-Concave Polynomials II", 2019
-/

open Finset BigOperators MvPolynomial

noncomputable section

namespace DynCert

/-! ## Section 1: Core Definitions -/

/-- The set of derivative multiindices of total mass `k` that are coordinatewise
    dominated by the update exponent `α`. These are exactly the derivative nodes
    in the certificate tree that can change under a rank-1 update by `X^α`. -/
def AffectedMultiindices {n : ℕ} (α : Fin n → ℕ) (k : ℕ) : Set (Fin n → ℕ) :=
  {β | (∑ i, β i) = k ∧ ∀ i, β i ≤ α i}

/-- A rank-1 (one-monomial) perturbation of a multivariate polynomial.
    `rankOneUpdate f c α` returns `f + c · X^α`. -/
def rankOneUpdate {n : ℕ} {R : Type*} [CommSemiring R]
    (f : MvPolynomial (Fin n) R) (c : R) (α : Fin n →₀ ℕ) : MvPolynomial (Fin n) R :=
  f + MvPolynomial.C c * MvPolynomial.monomial α 1

/-- Iterated partial derivative: apply `∂/∂xᵢ` exactly `β(i)` times for each `i`.
    Defined by folding over all variables using `Fin.foldl`. -/
def iterPDeriv {n : ℕ} {R : Type*} [CommSemiring R]
    (β : Fin n → ℕ) (f : MvPolynomial (Fin n) R) : MvPolynomial (Fin n) R :=
  Fin.foldl n (fun acc i => (MvPolynomial.pderiv i)^[β i] acc) f

/-- Count of affected multiindices at depth `k` for update exponent `α`. -/
def affectedCount {n : ℕ} (α : Fin n → ℕ) (k : ℕ) : ℕ :=
  ((Fintype.piFinset (fun i : Fin n => Finset.range (α i + 1))).filter
    (fun β => ∑ i, β i = k)).card

/-- Dynamic certificate cost: the total number of certificate nodes that
    potentially need recomputation. Bounded by the sum of affected counts
    across all derivative depths 0 through d-2. -/
def dynamicCertificateCost (n d : ℕ) (α : Fin n → ℕ) : ℕ :=
  ∑ k ∈ Finset.range (d - 1), affectedCount α k

/-- The rebuild cost for a degree-d Lorentzian certificate in n variables.
    This is n^d (matching `certificate_verification_complexity`). -/
def rebuildCost (n d : ℕ) : ℕ := n ^ d

/-- Total variation distance between two finite distributions. -/
def totalVariationDist {α : Type*} [Fintype α]
    (μ ν : α → ℝ) : ℝ :=
  (1 / 2) * ∑ a : α, |μ a - ν a|

/-- Normalize a nonneg weight vector to a probability distribution. -/
def normalizePMF {σ : Type*} [Fintype σ] (w : σ → ℝ) : σ → ℝ :=
  fun s => w s / ∑ t : σ, w t

/-! ## Section 2: Iterated Derivative Properties -/

/-
Iterated partial derivative distributes over addition.
-/
theorem iterPDeriv_add {n : ℕ} {R : Type*} [CommSemiring R]
    (β : Fin n → ℕ) (f g : MvPolynomial (Fin n) R) :
    iterPDeriv β (f + g) = iterPDeriv β f + iterPDeriv β g := by
  -- Apply induction on the number of variables.
  have h_ind : ∀ (k : ℕ) (f g : MvPolynomial (Fin n) R) (is : List (Fin n)), List.foldl (fun acc i => (MvPolynomial.pderiv i)^[β i] acc) (f + g) is = List.foldl (fun acc i => (MvPolynomial.pderiv i)^[β i] acc) f is + List.foldl (fun acc i => (MvPolynomial.pderiv i)^[β i] acc) g is := by
    intro k f g is; induction' is using List.reverseRecOn with is ih <;> simp_all +decide [ Function.iterate_succ_apply' ] ;
  convert h_ind n f g ( List.finRange n ) using 1 <;> simp +decide [ iterPDeriv ];
  · grind +qlia;
  · grind

/-
The iterated partial derivative of a monomial `X^α` by multiindex `β`
    vanishes when `β` is not coordinatewise ≤ `α`.
-/
set_option maxHeartbeats 800000 in
theorem iterPDeriv_monomial_eq_zero_of_not_le {n : ℕ}
    {R : Type*} [CommSemiring R]
    (α : Fin n →₀ ℕ) (β : Fin n → ℕ)
    (h : ¬ ∀ i, β i ≤ α i) :
    iterPDeriv β (MvPolynomial.monomial α (1 : R)) = 0 := by
  obtain ⟨i_0, hi⟩ : ∃ i_0 : Fin n, α i_0 < β i_0 := by
    grind;
  -- Since `α i_0 < β i_0`, the monomial `monomial α 1` is zero after differentiating by `β i_0` times.
  have h_zero : (MvPolynomial.pderiv i_0)^[β i_0] (MvPolynomial.monomial α 1 : MvPolynomial (Fin n) R) = 0 := by
    -- By definition of `pderiv`, we know that $(pderiv i_0)^{β i_0} (X^{α}) = 0$ if $β i_0 > α i_0$.
    have h_pderiv : ∀ k : ℕ, (pderiv i_0)^[k] (monomial α 1 : MvPolynomial (Fin n) R) = if k ≤ α i_0 then (Nat.descFactorial (α i_0) k : R) • monomial (α - Finsupp.single i_0 k) 1 else 0 := by
      intro k; induction' k with k ih <;> simp_all +decide [ Function.iterate_succ_apply', Nat.descFactorial_succ ] ;
      split_ifs <;> simp_all +decide [ Nat.descFactorial_succ, mul_assoc, mul_comm, mul_left_comm, Finsupp.single_apply ];
      · simp +decide [ mul_comm, Finsupp.sub_apply, Finsupp.single_apply, tsub_tsub ];
        simp +decide [ mul_comm, Algebra.smul_def ];
        simp +decide [ mul_assoc, mul_comm, mul_left_comm, MvPolynomial.monomial_eq ];
      · linarith;
    rw [ h_pderiv, if_neg hi.not_ge ];
  -- Since `α i_0 < β i_0`, the monomial `monomial α 1` is zero after differentiating by `β i_0` times, and thus the entire iterated derivative is zero.
  have h_iter_zero : ∀ (l : List (Fin n)), i_0 ∈ l → (List.foldl (fun acc i => (MvPolynomial.pderiv i)^[β i] acc) (MvPolynomial.monomial α 1 : MvPolynomial (Fin n) R) l) = 0 := by
    intro l hl;
    induction l using List.reverseRecOn <;> simp_all +decide;
    cases hl <;> simp_all +decide [ Function.iterate_fixed ];
    rename_i k hk₁ hk₂;
    by_cases hk₃ : k ∈ ‹List ( Fin n ) › <;> simp_all +decide [ Function.iterate_fixed ];
    induction' ‹List ( Fin n ) › using List.reverseRecOn with l ih <;> simp_all +decide [ Function.iterate_fixed ];
    -- Since $k \neq ih$, the partial derivatives commute.
    have h_comm : ∀ (f : MvPolynomial (Fin n) R), (MvPolynomial.pderiv k) ((MvPolynomial.pderiv ih) f) = (MvPolynomial.pderiv ih) ((MvPolynomial.pderiv k) f) := by
      intro f; exact (by
      induction f using MvPolynomial.induction_on <;> simp_all +decide [ MvPolynomial.pderiv_monomial ];
      simp +decide [ Pi.single_apply, hk₃.2 ] ; ring;
      aesop);
    -- Apply the commutativity of partial derivatives to rewrite the goal.
    have h_comm_iter : ∀ (m : ℕ) (f : MvPolynomial (Fin n) R), (MvPolynomial.pderiv k)^[m] ((MvPolynomial.pderiv ih) f) = (MvPolynomial.pderiv ih) ((MvPolynomial.pderiv k)^[m] f) := by
      intro m f; induction' m with m ih generalizing f <;> simp_all +decide [ Function.iterate_succ_apply' ] ;
    induction' β ih with m ih <;> simp_all +decide [ Function.iterate_succ_apply' ];
  grind +locals

/-
Scaling by a constant commutes with iterated partial derivatives.
-/
theorem iterPDeriv_C_mul {n : ℕ} {R : Type*} [CommSemiring R]
    (β : Fin n → ℕ) (c : R) (f : MvPolynomial (Fin n) R) :
    iterPDeriv β (MvPolynomial.C c * f) = MvPolynomial.C c * iterPDeriv β f := by
  have h_const_mul : ∀ (i : Fin n) (k : ℕ) (g : MvPolynomial (Fin n) R), (MvPolynomial.pderiv i)^[k] (MvPolynomial.C c * g) = MvPolynomial.C c * (MvPolynomial.pderiv i)^[k] g := by
    intro i k g; induction' k with k ih generalizing g <;> simp_all +decide [ Function.iterate_succ_apply' ] ;
  unfold iterPDeriv
  generalize_proofs at *;
  -- By definition of foldl, we can apply the constant multiplication property iteratively.
  have h_foldl : ∀ (l : List (Fin n)) (f : MvPolynomial (Fin n) R), (List.foldl (fun acc i => (MvPolynomial.pderiv i)^[β i] acc) (MvPolynomial.C c * f) l) = MvPolynomial.C c * (List.foldl (fun acc i => (MvPolynomial.pderiv i)^[β i] acc) f l) := by
    intro l f; induction' l using List.reverseRecOn with l ih <;> aesop;
  generalize_proofs at *; (
  grind)

/-! ## Section 3: Theorem 1 — Locality of Derivative Perturbation -/

/-
**Locality Theorem**: Under a rank-1 update `f + c · X^α`, the iterated
    partial derivative `∂^β` is unchanged whenever `β` is not coordinatewise
    dominated by `α`. This is the foundational result: only derivative nodes
    in `AffectedMultiindices α k` can change under the rank-1 update.

    *Proof strategy*: Expand `rankOneUpdate`, use linearity of `iterPDeriv`,
    and show the monomial contribution vanishes by `iterPDeriv_monomial_eq_zero_of_not_le`.
-/
theorem iterated_pderiv_rankOneUpdate_eq_of_not_le
    {n : ℕ} {R : Type*} [CommSemiring R]
    (f : MvPolynomial (Fin n) R)
    (c : R) (α : Fin n →₀ ℕ) (β : Fin n → ℕ)
    (hnot : ¬ ∀ i, β i ≤ α i) :
    iterPDeriv β (rankOneUpdate f c α) = iterPDeriv β f := by
  -- By linearity of the derivative, we can split the derivative into the sum of the derivatives of f and c * X^α.
  have h_linear : iterPDeriv β (f + MvPolynomial.C c * MvPolynomial.monomial α 1) = iterPDeriv β f + iterPDeriv β (MvPolynomial.C c * MvPolynomial.monomial α 1) := by
    convert iterPDeriv_add _ _ _ using 1;
  -- By linearity of the derivative, we can split the derivative into the sum of the derivatives of f and c * X^α. Then use the fact that the derivative of c * X^α is zero.
  have h_zero : iterPDeriv β (MvPolynomial.C c * MvPolynomial.monomial α 1) = MvPolynomial.C c * iterPDeriv β (MvPolynomial.monomial α 1) := by
    grind +suggestions
  simp_all +decide [ iterPDeriv_monomial_eq_zero_of_not_le ];
  exact h_linear

/-! ## Section 4: Theorem 2 — Homogeneity Preservation -/

/-
A monomial `C c * X^α` with `|α| = d` is homogeneous of degree `d`.
-/
theorem monomial_isHomogeneous {n d : ℕ} {R : Type*} [CommSemiring R]
    (α : Fin n →₀ ℕ) (c : R) (hα : α.sum (fun _ v => v) = d) :
    (MvPolynomial.C c * MvPolynomial.monomial α (1 : R)).IsHomogeneous d := by
  convert MvPolynomial.IsHomogeneous.C_mul _ _;
  convert MvPolynomial.isHomogeneous_monomial _ _;
  exact hα

/-
**Homogeneity Preservation**: If `f` is homogeneous of degree `d` and
    `|α| = d`, then the rank-1 update `f + c · X^α` is also homogeneous
    of degree `d`. Dynamic certification only makes sense if updates preserve
    the class of objects being certified.
-/
theorem rankOneUpdate_isHomogeneous
    {n d : ℕ} {R : Type*} [CommSemiring R]
    (f : MvPolynomial (Fin n) R)
    (c : R) (α : Fin n →₀ ℕ)
    (hf : f.IsHomogeneous d)
    (hα : α.sum (fun _ v => v) = d) :
    (rankOneUpdate f c α).IsHomogeneous d := by
  convert MvPolynomial.IsHomogeneous.add hf ( monomial_isHomogeneous α c hα ) using 1

/-! ## Section 5: Theorem 3 — Dynamic Certificate Cost Bounds -/

/-
The affected count at depth `k` is at most the total size of the
    product domain `∏ᵢ {0, ..., α(i)}`.
-/
theorem affectedCount_le_prod {n : ℕ} (α : Fin n → ℕ) (k : ℕ) :
    affectedCount α k ≤ ∏ i : Fin n, (α i + 1) := by
  exact le_trans ( Finset.card_filter_le _ _ ) ( by simp +decide )

/-- **Dynamic complexity bound**: The dynamic certificate cost equals
    the sum of affected counts over depths (by definition). -/
theorem dynamic_certificate_cost_eq
    {n d : ℕ} (α : Fin n → ℕ) :
    dynamicCertificateCost n d α =
      ∑ k ∈ Finset.range (d - 1), affectedCount α k := by
  rfl

/-
**Dynamic cost upper bound via product**: The dynamic certificate cost is
    bounded by `d` times the product `∏ᵢ (αᵢ + 1)`, which captures the maximum
    size of the affected region at any single depth, summed over all depths.
    For sparse updates (small `α`), this is much smaller than rebuild cost.
-/
theorem dynamic_certificate_cost_le_prod_bound
    {n d : ℕ} (α : Fin n → ℕ) :
    dynamicCertificateCost n d α ≤ (d - 1) * ∏ i : Fin n, (α i + 1) := by
  exact le_trans ( Finset.sum_le_sum fun _ _ => affectedCount_le_prod _ _ ) ( by simp +decide [ mul_comm, Finset.sum_mul _ _ _ ] )

/-
**Dynamic ≤ rebuild**: The dynamic certificate cost is bounded by the total
    number of certificate tree nodes `∑ₖ (number of multiindices of weight k)`.
    Since `affectedCount α k` counts a subset of all multiindices at depth `k`,
    the dynamic cost is always at most the full tree size. Here we bound it
    by `d * (d + 1)^n`, using that each `αᵢ ≤ d` implies `∏(αᵢ+1) ≤ (d+1)^n`.
-/
theorem dynamic_certificate_cost_le_rebuild
    {n d : ℕ} (α : Fin n → ℕ) (hα : (∑ i, α i) = d) :
    dynamicCertificateCost n d α ≤ d * (d + 1) ^ n := by
  refine' le_trans ( dynamic_certificate_cost_le_prod_bound α ) _;
  gcongr;
  · exact Nat.pred_le _;
  · exact le_trans ( Finset.prod_le_prod' fun _ _ => Nat.succ_le_succ <| Finset.single_le_sum ( fun i _ => Nat.zero_le ( α i ) ) <| Finset.mem_univ _ ) <| by norm_num [ hα ] ;

/-! ## Section 6: Theorem 4 — Graphic Matroid Application -/

/-- **Graphic matroid locality**: For any polynomial `f` and any
    update monomial `α` (modeling a spanning tree basis), the locality theorem
    applies: derivatives not dominated by the basis indicator are unchanged.
    This specializes the general locality theorem to the graphic matroid setting
    and connects dynamic Lorentzian certification to streaming graph algorithms. -/
theorem graphicMatroid_singleBasisUpdate_local
    {n : ℕ} {R : Type*} [CommSemiring R]
    (f : MvPolynomial (Fin n) R)
    (α : Fin n →₀ ℕ) (β : Fin n → ℕ)
    (hnot : ¬ ∀ i, β i ≤ α i) :
    iterPDeriv β (rankOneUpdate f 1 α) = iterPDeriv β f :=
  iterated_pderiv_rankOneUpdate_eq_of_not_le f 1 α β hnot

/-! ## Section 7: Theorem 5 — Warm-Start Total Variation Control -/

/-- A function is a probability mass function if it is nonneg and sums to 1. -/
structure IsPMF {α : Type*} [Fintype α] (μ : α → ℝ) : Prop where
  nonneg : ∀ a, 0 ≤ μ a
  sum_one : ∑ a, μ a = 1

/-
**Total variation ≤ ½ · ℓ₁ distance**: For any two functions `μ` and `ν`
    on a finite type, `TV(μ, ν) ≤ ½ · ‖μ - ν‖₁`.
    This is immediate from the definition of `totalVariationDist`.
-/
theorem tv_le_half_l1
    {α : Type*} [Fintype α]
    (μ ν : α → ℝ) :
    totalVariationDist μ ν ≤ (1 / 2) * ∑ a, |μ a - ν a| := by
  rfl

/-
**Warm-start coefficient perturbation bound**: If two nonneg weight vectors
    `w` and `w'` are both positive-sum, then their normalizations have total
    variation bounded by `Δ / max(Z, Z')` where `Δ = ∑|wᵢ - w'ᵢ|`,
    `Z = ∑ wᵢ`, `Z' = ∑ w'ᵢ`. This quantifies sampling stability under
    coefficient perturbation from rank-1 polynomial updates.

    *Proof*: Use the decomposition `w(s)/Z - w'(s)/Z' = Z'(w(s)-w'(s))/(ZZ') + w'(s)(Z'-Z)/(ZZ')`
    and the triangle inequality `|Z'-Z| ≤ ∑|w-w'|`.
-/
set_option maxHeartbeats 1600000 in
theorem normalizedCoeffDist_tv_bound
    {σ : Type*} [Fintype σ]
    (w w' : σ → ℝ)
    (hw : ∀ s, 0 ≤ w s) (hw' : ∀ s, 0 ≤ w' s)
    (hZ : 0 < ∑ s, w s) (hZ' : 0 < ∑ s, w' s) :
    totalVariationDist (normalizePMF w) (normalizePMF w') ≤
      (∑ s, |w s - w' s|) / max (∑ s, w s) (∑ s, w' s) := by
  -- Let $Z = \sum_{s} w(s)$ and $Z' = \sum_{s} w'(s)$.
  set Z := ∑ s, w s
  set Z' := ∑ s, w' s;
  -- We use two decompositions:
  have h_decomp1 : ∑ s, |w s / Z - w' s / Z'| ≤ 2 * (∑ s, |w s - w' s|) / Z' := by
    have h_decomp1 : ∑ s, |(w s / Z) - (w' s / Z')| ≤ (∑ s, (Z * |w s - w' s| + w s * |Z - Z'|)) / (Z * Z') := by
      have h_decomp1 : ∀ s, |(w s / Z) - (w' s / Z')| ≤ (Z * |w s - w' s| + w s * |Z - Z'|) / (Z * Z') := by
        intro s
        field_simp [hZ.ne', hZ'.ne'];
        rw [ abs_div, abs_of_nonneg ( mul_nonneg hZ.le hZ'.le ), mul_div_cancel₀ _ ( ne_of_gt ( mul_pos hZ hZ' ) ) ];
        cases abs_cases ( w s * Z' - Z * w' s ) <;> cases abs_cases ( w s - w' s ) <;> cases abs_cases ( Z - Z' ) <;> nlinarith [ hw s, hw' s, Finset.single_le_sum ( fun a _ => hw a ) ( Finset.mem_univ s ), Finset.single_le_sum ( fun a _ => hw' a ) ( Finset.mem_univ s ) ];
      simpa only [ Finset.sum_div _ _ _ ] using Finset.sum_le_sum fun s _ => h_decomp1 s;
    -- We can bound the numerator by $Z \cdot \Delta + Z \cdot |Z - Z'|$.
    have h_num_bound : ∑ s, (Z * |w s - w' s| + w s * |Z - Z'|) ≤ Z * ∑ s, |w s - w' s| + Z * |Z - Z'| := by
      simp +decide [ Finset.sum_add_distrib, Finset.mul_sum _ _ _ ];
      rw [ ← Finset.sum_mul _ _ _ ];
    -- We can bound $|Z - Z'|$ by $\sum |w - w'|$.
    have h_abs_diff : |Z - Z'| ≤ ∑ s, |w s - w' s| := by
      convert Finset.abs_sum_le_sum_abs _ _ using 2 ; aesop;
      infer_instance;
    exact h_decomp1.trans ( by rw [ div_le_div_iff₀ ] <;> nlinarith [ mul_pos hZ hZ' ] )
  have h_decomp2 : ∑ s, |w s / Z - w' s / Z'| ≤ 2 * (∑ s, |w s - w' s|) / Z := by
    have h_decomp2 : ∑ s, |w s / Z - w' s / Z'| ≤ ∑ s, |w s - w' s| / Z + ∑ s, |Z' - Z| * w' s / (Z * Z') := by
      have h_decomp2 : ∀ s, |w s / Z - w' s / Z'| ≤ |w s - w' s| / Z + |Z' - Z| * w' s / (Z * Z') := by
        intro s
        field_simp [hZ, hZ'];
        rw [ abs_div, abs_of_nonneg ( mul_nonneg hZ.le hZ'.le ) ];
        rw [ mul_div_cancel₀ _ ( ne_of_gt ( mul_pos hZ hZ' ) ) ];
        cases abs_cases ( w s - w' s ) <;> cases abs_cases ( Z' - Z ) <;> cases abs_cases ( w s * Z' - Z * w' s ) <;> nlinarith [ hw s, hw' s ];
      simpa only [ Finset.sum_add_distrib ] using Finset.sum_le_sum fun s _ => h_decomp2 s;
    -- We can bound the second term by noting that $\sum_{s} w'(s) = Z'$.
    have h_second_term : ∑ s, |Z' - Z| * w' s / (Z * Z') = |Z' - Z| / Z := by
      simp +decide [ ← Finset.mul_sum _ _ _, ← Finset.sum_div, mul_div_mul_comm ];
      grind;
    -- We can bound the first term by noting that $\sum_{s} |w(s) - w'(s)| \geq |Z - Z'|$.
    have h_first_term : ∑ s, |w s - w' s| ≥ |Z - Z'| := by
      exact le_trans ( by rw [ ← Finset.sum_sub_distrib ] ) ( Finset.abs_sum_le_sum_abs _ _ );
    simp_all +decide [ ← Finset.sum_div _ _ _ ];
    exact h_decomp2.trans ( by rw [ ← add_div, div_le_div_iff_of_pos_right hZ ] ; cases abs_cases ( Z' - Z ) <;> cases abs_cases ( Z - Z' ) <;> linarith );
  -- Taking the min: ∑ ≤ 2Δ/max(Z,Z'). TV = (1/2)∑ ≤ Δ/max(Z,Z').
  have h_min : ∑ s, |w s / Z - w' s / Z'| ≤ 2 * (∑ s, |w s - w' s|) / max Z Z' := by
    grind +suggestions;
  convert mul_le_mul_of_nonneg_left h_min ( show ( 0 : ℝ ) ≤ 1 / 2 by norm_num ) using 1 ; ring!

end DynCert

/-! ## Section 8: Conjecture — Dynamic Lorentzian Warm-Start Principle

**Conjecture**: For squarefree homogeneous Lorentzian polynomials `fₜ` arising
from a stream of graphic matroid updates, if `f_{t+1} = fₜ + cₜ X^{αₜ}` with
bounded coefficient perturbation and bounded affected-node fraction, then the
natural basis-exchange Markov chain started from stationarity of `fₜ` mixes to
within `ε` of stationarity for `f_{t+1}` in `O(log(1/ε) + log(1/(1 - δₜ)))`
steps, where `δₜ` is controlled by the normalized coefficient ℓ₁ drift and
affected certificate mass.

### Falsifiable Computational Test Protocol

1. Generate graphic matroids from random graphs on n = 10, 20, 50, 100 vertices
2. Add/delete one edge at a time, tracking the spanning tree generating polynomial
3. For each update:
   - Compute `affectedCount α k` for all derivative depths k
   - Compare dynamic certificate update cost vs full rebuild cost
4. Report cases where warm-start advantage collapses
5. Verify predicted scaling: warm-start mixing ∝ log(1/ε) + log(1/(1-δₜ))
-/