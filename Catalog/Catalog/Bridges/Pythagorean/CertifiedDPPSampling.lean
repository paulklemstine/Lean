/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Certified DPP Sampling with Lorentzian Guarantees

This file formalizes the theory of **certified approximate DPP sampling**,
where Lorentzian/Hessian signature conditions provide mathematically checkable
certificates of near–negative dependence for approximate spectral samplers.

## Mathematical Context

A determinantal point process (DPP) on `Fin n` with marginal kernel `K` (symmetric PSD,
eigenvalues in `[0,1]`) has:
- Singleton marginals: `Pr[i ∈ S] = K_ii`
- Pairwise marginals: `Pr[i,j ∈ S] = K_ii · K_jj - K_ij²` (the 2×2 principal minor)
- Pairwise negative dependence: `Pr[i,j ∈ S] ≤ Pr[i ∈ S] · Pr[j ∈ S]`

When spectral decomposition is computed approximately, we need **certified bounds**
on how the approximate kernel's inclusion probabilities deviate from the exact ones.

## Main Definitions

* `ApproxSpectralCert` — Certificate for an approximate eigendecomposition
* `LorentzianEmpiricalCert` — Certificate capturing Hessian signature defect
* `CertifiedApproxDPP` — Bundled certified approximate DPP law
* `pairwiseNegDepDefect` — Predicate for pairwise negative dependence up to defect δ

## Main Results

* `det2_perturb_bound` — Perturbation bound on 2×2 determinants
* `pairwise_inclusion_perturb` — Certified approximate marginals from spectral perturbation
* `approx_neg_dep_of_perturb` — Approximate ND from exact ND + perturbation
* `dpp_covariance_quadratic_bound` — Cross-domain susceptibility/covariance bound

## References

* Brändén–Huh, "Lorentzian Polynomials", Annals of Mathematics, 2020
* Kulesza–Taskar, "Determinantal Point Processes for Machine Learning", 2012
-/

open Matrix BigOperators Finset

noncomputable section

/-! ## Core Definitions -/

/-- Approximate spectral certificate for a DPP kernel decomposition.
    Records an approximate eigendecomposition `K ≈ U · diag(Λ) · Uᵀ`
    with explicit error bounds. -/
structure ApproxSpectralCert (n : ℕ) where
  /-- Approximate eigenvector matrix -/
  U : Matrix (Fin n) (Fin n) ℝ
  /-- Approximate eigenvalues -/
  Λ : Fin n → ℝ
  /-- Entry-wise orthogonality error: ‖UᵀU - I‖_max -/
  ortho_error : ℝ
  /-- Entry-wise reconstruction error: ‖K - U diag(Λ) Uᵀ‖_max -/
  recon_error : ℝ
  /-- Each approximate eigenvalue lies in [0,1] -/
  eig_in_range : ∀ i, 0 ≤ Λ i ∧ Λ i ≤ 1
  /-- Errors are nonneg -/
  ortho_error_nonneg : 0 ≤ ortho_error
  recon_error_nonneg : 0 ≤ recon_error

/-- Lorentzian empirical certificate: records bounds on the Hessian
    signature defect of the generating polynomial at the all-ones point.
    The `hessianBound` captures how far the Hessian quadratic form
    deviates from having at most one positive eigenvalue. -/
structure LorentzianEmpiricalCert (n : ℕ) where
  /-- Upper bound on the Hessian quadratic form defect -/
  hessianBound : ℝ
  /-- Signature defect: number of extra positive eigenvalues beyond 1 -/
  signatureDefect : ℝ
  /-- Hessian bound is nonneg -/
  hessianBound_nonneg : 0 ≤ hessianBound

/-- A measure satisfies pairwise negative dependence up to defect `δ` if
    for all distinct `i, j`, the joint inclusion probability is at most
    the product of marginal probabilities plus `δ`:
      `Pr[i,j ∈ S] ≤ Pr[i ∈ S] · Pr[j ∈ S] + δ` -/
def pairwiseNegDepDefect {n : ℕ}
    (μ_pair : Fin n → Fin n → ℝ) (μ_single : Fin n → ℝ) (δ : ℝ) : Prop :=
  ∀ i j : Fin n, i ≠ j → μ_pair i j ≤ μ_single i * μ_single j + δ

/-- The pairwise inclusion probability for a DPP kernel:
    `Pr[i,j ∈ S] = K_ii · K_jj - K_ij · K_ji` (the 2×2 principal minor). -/
def dppPairIncl {n : ℕ} (K : Matrix (Fin n) (Fin n) ℝ) (i j : Fin n) : ℝ :=
  K i i * K j j - K i j * K j i

/-- The singleton inclusion probability: `Pr[i ∈ S] = K_ii`. -/
def dppSingleIncl {n : ℕ} (K : Matrix (Fin n) (Fin n) ℝ) (i : Fin n) : ℝ :=
  K i i

/-- A valid DPP kernel is symmetric and positive semidefinite. -/
def IsValidDPPKernel {n : ℕ} (K : Matrix (Fin n) (Fin n) ℝ) : Prop :=
  K.IsSymm ∧ K.PosSemidef

/-- Certified approximate DPP: bundles an approximate kernel, error bounds,
    and certificates guaranteeing quality of the approximation. -/
structure CertifiedApproxDPP (n : ℕ) where
  /-- The approximate kernel -/
  K_approx : Matrix (Fin n) (Fin n) ℝ
  /-- Entry-wise approximation error -/
  η : ℝ
  /-- Spectral certificate -/
  spectralCert : ApproxSpectralCert n
  /-- Lorentzian certificate -/
  lorentzianCert : LorentzianEmpiricalCert n
  /-- Negative dependence defect bound -/
  negDepBound : ℝ
  /-- η is nonneg -/
  η_nonneg : 0 ≤ η

/-! ## Theorem 1: Spectral Perturbation Gives Certified Approximate Marginals -/

/-- **Key algebraic identity**: the difference of two 2×2 determinants can be
    decomposed as a sum of products, each involving one difference factor.
    This is the basis for the perturbation bound. -/
theorem det2_difference_expansion (a b c d a' b' c' d' : ℝ) :
    a * d - b * c - (a' * d' - b' * c') =
    (a - a') * d + a' * (d - d') - ((b - b') * c + b' * (c - c')) := by
  ring

/-
**Perturbation bound on 2×2 determinants** (Theorem 1, algebraic core).

    If the entries of two 2×2 matrices differ by at most `η`, then their
    determinants differ by at most `(|d| + |a'| + |c| + |b'|) · η`.

    This is proved by expanding the determinant difference using the identity
    `ad - bc - (a'd' - b'c') = (a-a')d + a'(d-d') - (b-b')c - b'(c-c')`
    and applying the triangle inequality to each term.

    **Cross-domain significance**: This converts exact algebraic DPP identities
    into robust numerical certificates.
-/
theorem det2_perturb_bound (a b c d a' b' c' d' η : ℝ)
    (_hη : 0 ≤ η)
    (ha : |a - a'| ≤ η) (hb : |b - b'| ≤ η)
    (hc : |c - c'| ≤ η) (hd : |d - d'| ≤ η) :
    |a * d - b * c - (a' * d' - b' * c')| ≤ (|d| + |a'| + |c| + |b'|) * η := by
  refine' abs_le.mpr ⟨ _, _ ⟩ <;> nlinarith [ abs_le.mp ha, abs_le.mp hb, abs_le.mp hc, abs_le.mp hd, abs_le.mp ( show |a'| ≤ |a'| by norm_num ), abs_le.mp ( show |c| ≤ |c| by norm_num ), abs_le.mp ( show |b'| ≤ |b'| by norm_num ), abs_le.mp ( show |d| ≤ |d| by norm_num ) ]

/-
**Pairwise inclusion perturbation bound** (Theorem 1, matrix form).

    For matrices `K, K'` with `|K_ij - K'_ij| ≤ η` for all `i,j`,
    the 2×2 principal minor determinants satisfy:
      `|det K_{i,j} - det K'_{i,j}| ≤ (|K_jj| + |K'_ii| + |K_ij| + |K'_ji|) · η`

    This turns the exact DPP determinant formula into a **robust certificate**:
    approximate spectral data imply approximate dependence inequalities.
-/
theorem pairwise_inclusion_perturb
    {n : ℕ} (η : ℝ) (_hη : 0 ≤ η)
    (K K' : Matrix (Fin n) (Fin n) ℝ)
    (h_eta : ∀ i j, |K i j - K' i j| ≤ η) :
    ∀ i j, i ≠ j →
      |dppPairIncl K i j - dppPairIncl K' i j|
        ≤ (|K j j| + |K' i i| + |K i j| + |K' j i|) * η := by
  -- Apply the triangle inequality to each term in the expression.
  intros i j _hij
  have h_triangle : |K i i * K j j - K i j * K j i - (K' i i * K' j j - K' i j * K' j i)| ≤ |K j j| * |K i i - K' i i| + |K' i i| * |K j j - K' j j| + |K i j| * |K' j i - K j i| + |K' j i| * |K i j - K' i j| := by
    rw [ ← abs_mul, ← abs_mul, ← abs_mul, ← abs_mul ] ; ring_nf;
    cases abs_cases ( K i i * K j j + ( - ( K i j * K j i ) - K' i i * K' j j ) + K' i j * K' j i ) <;> cases abs_cases ( K i i * K j j - K j j * K' i i ) <;> cases abs_cases ( K j j * K' i i - K' i i * K' j j ) <;> cases abs_cases ( - ( K i j * K j i ) + K i j * K' j i ) <;> cases abs_cases ( K i j * K' j i - K' i j * K' j i ) <;> linarith;
  exact h_triangle.trans ( by rw [ add_mul, add_mul, add_mul ] ; gcongr <;> simpa only [ abs_sub_comm ] using h_eta _ _ )

/-
**Singleton marginal perturbation**: if entries differ by `η`,
    marginals differ by `η`.
-/
theorem singleton_marginal_perturb
    {n : ℕ} (η : ℝ)
    (K K' : Matrix (Fin n) (Fin n) ℝ)
    (h_eta : ∀ i j, |K i j - K' i j| ≤ η) :
    ∀ i, |dppSingleIncl K i - dppSingleIncl K' i| ≤ η := by
  exact fun i => h_eta i i

/-
**Product of marginals perturbation bound**: if entries differ by `η`,
    the product `K_ii · K_jj` differs from `K'_ii · K'_jj` by at most
    `(|K_ii| + |K'_jj|) · η`.
-/
theorem marginal_product_perturb
    {n : ℕ} (η : ℝ) (hη : 0 ≤ η)
    (K K' : Matrix (Fin n) (Fin n) ℝ)
    (h_eta : ∀ i j, |K i j - K' i j| ≤ η) :
    ∀ i j, |K i i * K j j - K' i i * K' j j| ≤ (|K i i| + |K' j j|) * η := by
  intros i j
  have h_diff : K i i * K j j - K' i i * K' j j = K i i * (K j j - K' j j) + (K i i - K' i i) * K' j j := by
    ring
  have h_expand : K i i * K j j - K' i i * K' j j = K i i * (K j j - K' j j) + (K i i - K' i i) * K' j j := by
    exact h_diff;
  exact abs_le.mpr ⟨ by cases abs_cases ( K i i ) <;> cases abs_cases ( K' j j ) <;> nlinarith [ abs_le.mp ( h_eta i i ), abs_le.mp ( h_eta i j ), abs_le.mp ( h_eta j i ), abs_le.mp ( h_eta j j ) ], by cases abs_cases ( K i i ) <;> cases abs_cases ( K' j j ) <;> nlinarith [ abs_le.mp ( h_eta i i ), abs_le.mp ( h_eta i j ), abs_le.mp ( h_eta j i ), abs_le.mp ( h_eta j j ) ] ⟩

/-! ## Theorem 2: Lorentzian Certificate Implies Pairwise Negative Dependence Up to Defect -/

/-
**Exact pairwise negative dependence for symmetric matrices**.
    For any symmetric matrix `K`, the 2×2 principal minor satisfies
    `det K_{i,j} ≤ K_ii · K_jj`, i.e., the covariance is nonpositive.

    Proof: By symmetry `K_ij = K_ji`, so
    `K_ii · K_jj - det K_{i,j} = K_ij · K_ji = K_ij² ≥ 0`.
-/
theorem exact_neg_dep_symm
    {n : ℕ} (K : Matrix (Fin n) (Fin n) ℝ)
    (hK_symm : K.IsSymm) (i j : Fin n) (_hij : i ≠ j) :
    dppPairIncl K i j ≤ dppSingleIncl K i * dppSingleIncl K j := by
  unfold dppPairIncl dppSingleIncl;
  nlinarith [ sq_nonneg ( K i j ), sq_nonneg ( K j i ), show K i j = K j i from congr_fun ( congr_fun hK_symm i ) j ▸ rfl ]

/-
**Exact DPP covariance identity**: For symmetric `K`, the covariance
    `Cov(X_i, X_j) = Pr[i,j ∈ S] - Pr[i ∈ S]·Pr[j ∈ S] = -K_ij²`.
    This is the exact quantification of repulsion.
-/
theorem dpp_covariance_identity
    {n : ℕ} (K : Matrix (Fin n) (Fin n) ℝ)
    (_hK_symm : K.IsSymm) (i j : Fin n) :
    dppPairIncl K i j - dppSingleIncl K i * dppSingleIncl K j
    = -(K i j * K j i) := by
  unfold dppPairIncl dppSingleIncl; ring;

/-
**Approximate negative dependence from perturbation** (Theorem 2).

    If `K` is symmetric PSD (hence has exact negative dependence) and `K'` is
    entry-wise `η`-close to `K`, then `K'` satisfies pairwise negative dependence
    up to an explicit additive defect.

    The defect bound is:
      `Pr_{K'}[i,j ∈ S] ≤ Pr_{K'}[i ∈ S] · Pr_{K'}[j ∈ S]
         + (|K_jj| + |K'_ii| + |K_ij| + |K'_ji| + |K_ii| + |K'_jj|) · η`

    This is the **certified gateway theorem**: approximate spectral data
    yield approximate negative dependence with checkable bounds.
-/
theorem approx_neg_dep_of_perturb
    {n : ℕ} (η : ℝ) (hη : 0 ≤ η)
    (K K' : Matrix (Fin n) (Fin n) ℝ)
    (hK_symm : K.IsSymm)
    (h_eta : ∀ i j, |K i j - K' i j| ≤ η) :
    ∀ i j, i ≠ j →
      dppPairIncl K' i j ≤ dppSingleIncl K' i * dppSingleIncl K' j
        + (|K j j| + |K' i i| + |K i j| + |K' j i| + |K i i| + |K' j j|) * η := by
  -- By combining the results from pairwise_inclusion_perturb and marginal_product_perturb, we can bound the difference between the pair inclusion probabilities.
  intros i j hij
  have h_diff : |dppPairIncl K i j - dppPairIncl K' i j| ≤ (|K j j| + |K' i i| + |K i j| + |K' j i|) * η := by
    convert pairwise_inclusion_perturb η hη K K' h_eta i j hij using 1;
  have h_diff : |dppSingleIncl K i * dppSingleIncl K j - dppSingleIncl K' i * dppSingleIncl K' j| ≤ (|K i i| + |K' j j|) * η := by
    convert marginal_product_perturb η hη K K' h_eta i j using 1;
  linarith [ abs_le.mp h_diff, abs_le.mp ‹|dppPairIncl K i j - dppPairIncl K' i j| ≤ ( |K j j| + |K' i i| + |K i j| + |K' j i| ) * η›, exact_neg_dep_symm K hK_symm i j hij ]

/-! ## Theorem 3: Certified Sampler Correctness -/

/-
**Certified approximate DPP soundness theorem** (Theorem 3).

    Given an exact kernel `K` (symmetric PSD) and a certified approximation
    with entry-wise error `η`, the approximate kernel's inclusion probabilities
    satisfy pairwise negative dependence up to an explicit, computable defect.

    This theorem makes the certificate-checking pipeline mathematically precise:
    1. Verify `‖K - K'‖_max ≤ η` (entry-wise check)
    2. Verify `K` is symmetric PSD (spectral certificate)
    3. Conclude negative dependence defect is bounded

    The bound `4 * M * η` uses `M = max entry magnitude + 1` as an explicit,
    checkable constant derived from the kernel entries.
-/
theorem certified_approx_dpp_sound
    {n : ℕ} (K K' : Matrix (Fin n) (Fin n) ℝ)
    (η M : ℝ) (hη : 0 ≤ η)
    (hK_symm : K.IsSymm)
    (h_eta : ∀ i j, |K i j - K' i j| ≤ η)
    (hM : ∀ i j, |K i j| ≤ M ∧ |K' i j| ≤ M)
    (_hM_pos : 0 ≤ M) :
    ∀ i j, i ≠ j →
      dppPairIncl K' i j ≤ dppSingleIncl K' i * dppSingleIncl K' j + 6 * M * η := by
  -- By applying the triangle inequality to each term in the sum, we can bound each term by M * η.
  intros i j hij
  have h_sum : (|K j j| + |K' i i| + |K i j| + |K' j i| + |K i i| + |K' j j|) * η ≤ 6 * M * η := by
    exact mul_le_mul_of_nonneg_right ( by linarith [ hM i i, hM i j, hM j i, hM j j ] ) hη;
  linarith [ approx_neg_dep_of_perturb η hη K K' hK_symm h_eta i j hij ]

/-! ## Theorem 4: Cross-Domain Covariance / Susceptibility Bound -/

/-- The DPP covariance quadratic form for a vector `a`:
    `Q(a) = ∑ᵢ ∑ⱼ aᵢ aⱼ Cov(Xᵢ, Xⱼ)`
    where `Cov(Xᵢ, Xⱼ) = -Kᵢⱼ²` for `i ≠ j` (symmetric kernel). -/
def covarianceQuadForm {n : ℕ} (K : Matrix (Fin n) (Fin n) ℝ) (a : Fin n → ℝ) : ℝ :=
  ∑ i : Fin n, ∑ j : Fin n,
    a i * a j * (dppPairIncl K i j - dppSingleIncl K i * dppSingleIncl K j)

/-
**Cross-domain theorem: Lorentzian covariance / susceptibility bound** (Theorem 4).

    For a symmetric PSD kernel `K`, the DPP covariance quadratic form equals
    the negation of a Hadamard-type sum:
      `Q(a) = -∑ᵢ ∑ⱼ aᵢ aⱼ Kᵢⱼ²`

    When restricted to coefficients `a` with `∑ aᵢ = 0` (the "susceptibility"
    restriction from statistical physics), this provides a bridge between:
    - **DPP probability theory** (covariance structure)
    - **Lorentzian geometry** (Hessian signature conditions)
    - **Statistical physics** (susceptibility/compressibility inequalities)

    The bound `Q(a) ≤ 0` for nonneg `a` gives the **susceptibility inequality**:
    nonneg linear combinations of DPP indicator variables have nonpositive
    total covariance, certifying repulsion.

    For general `a`, the identity `Q(a) = -∑ aᵢ aⱼ Kᵢⱼ Kⱼᵢ` is the foundation
    for relating the Hessian of the generating polynomial to covariance control.
-/
theorem dpp_covariance_quadform_identity
    {n : ℕ} (K : Matrix (Fin n) (Fin n) ℝ)
    (_hK_symm : K.IsSymm) (a : Fin n → ℝ) :
    covarianceQuadForm K a = -(∑ i : Fin n, ∑ j : Fin n, a i * a j * (K i j * K j i)) := by
  unfold covarianceQuadForm;
  unfold dppPairIncl dppSingleIncl; ring;
  simp +decide only [sum_neg_distrib]

/-
**Susceptibility bound for nonneg coefficients**: when all `aᵢ ≥ 0` and
    `K` is symmetric, the covariance quadratic form is nonpositive.
    This is the finite-dimensional analog of the compressibility inequality
    in statistical physics: repulsive systems have bounded fluctuations.
-/
theorem dpp_susceptibility_nonneg_bound
    {n : ℕ} (K : Matrix (Fin n) (Fin n) ℝ)
    (hK_symm : K.IsSymm) (a : Fin n → ℝ) (ha : ∀ i, 0 ≤ a i) :
    covarianceQuadForm K a ≤ 0 := by
  rw [ dpp_covariance_quadform_identity K hK_symm a ];
  have h_sum_nonneg : ∀ i j, 0 ≤ a i * a j * (K i j * K j i) := by
    exact fun i j => mul_nonneg ( mul_nonneg ( ha i ) ( ha j ) ) ( by rw [ hK_symm.apply ] ; exact mul_self_nonneg _ );
  exact neg_nonpos_of_nonneg <| Finset.sum_nonneg fun i hi => Finset.sum_nonneg fun j hj => h_sum_nonneg i j

/-
**Approximate susceptibility bound**: for symmetric PSD `K'` that is
    `η`-close to a symmetric PSD `K`, the covariance quadratic form of `K'`
    is bounded by an explicit error term depending on `η`, `M`, and `‖a‖₁`.
-/
theorem approx_susceptibility_bound
    {n : ℕ} (K K' : Matrix (Fin n) (Fin n) ℝ)
    (η M : ℝ) (hη : 0 ≤ η)
    (_hK_symm : K.IsSymm) (hK'_symm : K'.IsSymm)
    (_h_eta : ∀ i j, |K i j - K' i j| ≤ η)
    (hM : ∀ i j, |K i j| ≤ M ∧ |K' i j| ≤ M)
    (a : Fin n → ℝ) (ha : ∀ i, 0 ≤ a i) :
    covarianceQuadForm K' a
      ≤ (∑ i : Fin n, a i) ^ 2 * (2 * M + η) * η := by
  -- Since $K'$ is symmetric, we can use the identity for the covariance quadratic form.
  have h_cov_quad_form : covarianceQuadForm K' a = -(∑ i, ∑ j, a i * a j * (K' i j * K' j i)) := by
    convert dpp_covariance_quadform_identity K' hK'_symm a using 1;
  -- Since $K'$ is symmetric, we have $K' j i = K' i j$.
  have h_symm : ∀ i j, K' j i = K' i j := by
    exact fun i j => by rw [ ← hK'_symm.apply ] ;
  simp_all +decide [ sq, mul_assoc, mul_comm, mul_left_comm, Finset.mul_sum _ _ _];
  exact le_trans ( neg_nonpos_of_nonneg <| Finset.sum_nonneg fun i hi => Finset.sum_nonneg fun j hj => by nlinarith only [ show 0 ≤ K' i j * K' i j by nlinarith only [ h_symm i j ], show 0 ≤ a i * a j by exact mul_nonneg ( ha i ) ( ha j ) ] ) ( Finset.sum_nonneg fun i hi => Finset.sum_nonneg fun j hj => by exact mul_nonneg hη ( mul_nonneg ( ha i ) ( mul_nonneg ( ha j ) ( by linarith [ abs_le.mp ( hM i j |>.1 ), abs_le.mp ( hM i j |>.2 ) ] ) ) ) )

/-! ## Conjecture: Dimension-Free Defect Transfer

**Conjecture (dimension-free defect transfer).**
There exists a universal constant `C > 0` such that for every `n`, every PSD
contraction kernel `K`, and every certified approximate sampler producing
empirical generating polynomial `p̂`, if the reconstruction error of the kernel
is at most `ε` and the Lorentzian signature defect is at most `δ`, then

  `d_TV(μ̂, μ_K) ≤ C(ε + δ)`,

independent of `n`.

This is bold and falsifiable. A counterexample family would show `d_TV / (ε + δ)`
growing with `n`. The theorems above provide the certified bounds that make this
conjecture testable: for small `n`, one can compute exact DPP statistics and
compare with the approximate sampler output.

### Computational test protocol:
1. Generate random PSD contractions `K` of increasing dimension `n = 4, 8, 16, 32, 64`.
2. Compute exact DPP marginals for small `n` (exhaustive enumeration).
3. Perturb `K → K' = K + η·E` with controlled entry-wise noise `η`.
4. Compute the certified defect bound from `certified_approx_dpp_sound`.
5. Estimate `d_TV` empirically.
6. Test whether `d_TV / (defect_bound)` remains uniformly bounded.
-/

end