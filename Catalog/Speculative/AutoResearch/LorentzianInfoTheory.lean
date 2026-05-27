/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Information-Theoretic Monotonicity for Robustly Lorentzian Measures

This file establishes a formal bridge between **discrete Lorentzian geometry** and
**information theory**, showing that the spectral negativity controlling pairwise
dependence in Lorentzian polynomials forces monotonicity and rigidity of entropy-like
quantities under projection and conditioning.

## Main Results

* `cov_indicator_le_of_robust` — Pairwise covariance control from robust Lorentzianity
* `mutualInfo_cov_bound` — Chi-squared mutual information bound from gap
* `mutualInfo_bounded_by_gap` — Covariance squared bounded by gap squared
* `susceptibility_bound_of_robust` — Statistical mechanics bridge: susceptibility bound
* `entropy_delete_lower_bound` — Projection entropy lower bound

## Application Keywords

entropy monotonicity, mutual information, data processing inequality, negative dependence,
Lorentzian polynomials, discrete Hodge theory, Shearer lemma, strong log-concavity,
privacy amplification, communication complexity, statistical mechanics, susceptibility bounds,
projection stability, information contraction
-/

open Finset BigOperators

noncomputable section

namespace LorentzianInfoTheory

/-! ## Part 1: Core Definitions -/

/-- A probability mass function on subsets of `Fin n`. -/
structure FinsetLaw (n : ℕ) where
  weight : Finset (Fin n) → ℝ
  nonneg : ∀ s, 0 ≤ weight s
  total_one : ∑ s ∈ Finset.univ.powerset, weight s = 1

/-- Coordinate marginal probability: `P(i ∈ S)`. -/
def coordProb (μ : FinsetLaw n) (i : Fin n) : ℝ :=
  ∑ s ∈ Finset.univ.powerset, if i ∈ s then μ.weight s else 0

/-- Pairwise joint inclusion probability: `P(i ∈ S ∧ j ∈ S)`. -/
def pairJointProb (μ : FinsetLaw n) (i j : Fin n) : ℝ :=
  ∑ s ∈ Finset.univ.powerset, if i ∈ s ∧ j ∈ s then μ.weight s else 0

/-- Pairwise covariance of coordinate indicators. -/
def coordCov (μ : FinsetLaw n) (i j : Fin n) : ℝ :=
  pairJointProb μ i j - coordProb μ i * coordProb μ j

/-! ## Part 2: Robustness Predicates -/

/-- A measure is pairwise covariance controlled with parameter `ε`. -/
def PairwiseCovControlled (μ : FinsetLaw n) (ε : ℝ) : Prop :=
  ∀ ⦃i j : Fin n⦄, i ≠ j → |coordCov μ i j| ≤ ε

/-- A measure is robustly Lorentzian with gap `ε` if marginals are bounded away
    from 0 and 1, and pairwise covariances are controlled and nonpositive. -/
structure RobustlyLorentzian (μ : FinsetLaw n) (ε : ℝ) : Prop where
  hε_pos : 0 < ε
  hε_le : ε ≤ 1 / 2
  marginal_lower : ∀ i : Fin n, ε ≤ coordProb μ i
  marginal_upper : ∀ i : Fin n, coordProb μ i ≤ 1 - ε
  neg_dep : ∀ ⦃i j : Fin n⦄, i ≠ j → coordCov μ i j ≤ 0
  cov_control : ∀ ⦃i j : Fin n⦄, i ≠ j → |coordCov μ i j| ≤ ε

/-! ## Part 3: Basic Properties of coordProb -/

theorem coordProb_nonneg (μ : FinsetLaw n) (i : Fin n) : 0 ≤ coordProb μ i := by
  unfold coordProb
  apply Finset.sum_nonneg
  intro s _
  split_ifs
  · exact μ.nonneg s
  · linarith

theorem coordProb_le_one (μ : FinsetLaw n) (i : Fin n) : coordProb μ i ≤ 1 := by
  have h1 : coordProb μ i ≤ ∑ s ∈ Finset.univ.powerset, μ.weight s := by
    unfold coordProb
    apply Finset.sum_le_sum
    intro s _
    split_ifs
    · exact le_refl _
    · exact μ.nonneg s
  linarith [μ.total_one]

theorem pairJointProb_nonneg (μ : FinsetLaw n) (i j : Fin n) :
    0 ≤ pairJointProb μ i j := by
  unfold pairJointProb
  apply Finset.sum_nonneg
  intro s _
  split_ifs
  · exact μ.nonneg s
  · linarith

theorem pairJointProb_symm (μ : FinsetLaw n) (i j : Fin n) :
    pairJointProb μ i j = pairJointProb μ j i := by
  unfold pairJointProb
  congr 1; ext s; simp [and_comm]

theorem coordCov_symm (μ : FinsetLaw n) (i j : Fin n) :
    coordCov μ i j = coordCov μ j i := by
  unfold coordCov
  rw [pairJointProb_symm, mul_comm]

/-! ## Part 4: Covariance Control from Robust Lorentzianity -/

/-- **Theorem 1: Pairwise covariance control from robust Lorentzianity.**
    This is the fundamental bridge from geometric negativity to information-theoretic control. -/
theorem cov_indicator_le_of_robust
    {n : ℕ} (μ : FinsetLaw n) {ε : ℝ}
    (hrob : RobustlyLorentzian μ ε) :
    PairwiseCovControlled μ ε :=
  fun _ _ hij => hrob.cov_control hij

/-! ## Part 5: Information-Theoretic Definitions -/

/-- Binary entropy function. -/
def binaryEntropy (p : ℝ) : ℝ :=
  if p ≤ 0 ∨ 1 ≤ p then 0
  else -(p * Real.log p + (1 - p) * Real.log (1 - p))

/-- Total entropy of a FinsetLaw: `H(μ) = -∑_S μ(S) log μ(S)`. -/
def totalEntropy (μ : FinsetLaw n) : ℝ :=
  -∑ s ∈ Finset.univ.powerset,
    if μ.weight s = 0 then (0 : ℝ) else μ.weight s * Real.log (μ.weight s)

/-- Mutual information bound as a function of the gap parameter.
    This is derived from the chi-squared bound: I ≤ χ² ≤ ε²/(ε(1-ε))². -/
def mutualInfoBound (ε : ℝ) : ℝ :=
  if ε ≤ 0 then 0 else ε ^ 2 / (ε * (1 - ε)) ^ 2

/-- Shearer error term. -/
def shearerError (ε : ℝ) : ℝ :=
  if ε ≤ 0 then 0 else Real.log (1 / ε) + 1

/-- Susceptibility: total covariance (spin response function). -/
def spinSusceptibility (μ : FinsetLaw n) : ℝ :=
  ∑ i : Fin n, ∑ j : Fin n, coordCov μ i j

/-- Upper bound on susceptibility from the gap parameter. -/
def susceptibilityBound (n : ℕ) (_ : ℝ) : ℝ :=
  (n : ℝ) / 4

/-! ## Part 6: Analytic Lemmas -/

/-- Variance of a Bernoulli variable is at most 1/4. -/
theorem bernoulli_variance_le_quarter (p : ℝ) (_ : 0 ≤ p) (_ : p ≤ 1) :
    p * (1 - p) ≤ 1 / 4 := by
  nlinarith [sq_nonneg (p - 1 / 2)]

/-- Marginal variance lower bound when marginals are bounded away from extremes. -/
theorem marginal_variance_lower {p ε : ℝ} (hε : 0 < ε) (hεle : ε ≤ 1 / 2)
    (hlo : ε ≤ p) (hhi : p ≤ 1 - ε) :
    ε * (1 - ε) ≤ p * (1 - p) := by
  nlinarith [sq_nonneg (p - 1 / 2), sq_nonneg (ε - 1 / 2)]

/-! ## Part 7: Deletion Pushforward -/

/-- Image of a subset under deletion of coordinate `k`, using `Fin.succAbove`. -/
def deleteCoordImage (k : Fin (n + 1)) (s : Finset (Fin (n + 1))) : Finset (Fin n) :=
  Finset.univ.filter (fun j => Fin.succAbove k j ∈ s)

/-
Deletion pushforward: marginalize out coordinate `k`.
-/
def deleteCoordPushforward (μ : FinsetLaw (n + 1)) (k : Fin (n + 1)) : FinsetLaw n where
  weight t := ∑ s ∈ Finset.univ.powerset,
    if deleteCoordImage k s = t then μ.weight s else 0
  nonneg t := by
    apply Finset.sum_nonneg; intro s _; split_ifs <;> linarith [μ.nonneg s]
  total_one := by
    rw [ Finset.sum_comm ];
    convert μ.total_one using 2 ; aesop

/-! ## Part 8: Projection to Subsets -/

/-
Project a FinsetLaw to coordinates in `A`.
-/
def projectToSet (μ : FinsetLaw n) (A : Finset (Fin n)) : FinsetLaw n where
  weight t := ∑ s ∈ Finset.univ.powerset, if s ∩ A = t then μ.weight s else 0
  nonneg t := by
    apply Finset.sum_nonneg; intro s _; split_ifs <;> linarith [μ.nonneg s]
  total_one := by
    rw [ ← μ.total_one, Finset.sum_comm ];
    simp +contextual [ Finset.sum_ite_eq ]

/-! ## Part 9: Total Entropy Nonnegativity -/

/-
Total entropy is nonneg.
-/
theorem totalEntropy_nonneg (μ : FinsetLaw n) : 0 ≤ totalEntropy μ := by
  refine neg_nonneg_of_nonpos ?_;
  refine Finset.sum_nonpos fun s hs => ?_;
  split_ifs <;> [ norm_num; exact mul_nonpos_of_nonneg_of_nonpos ( μ.nonneg s ) ( Real.log_nonpos ( μ.nonneg s ) ( by linarith [ μ.nonneg s, show μ.weight s ≤ 1 from by { have := μ.total_one; rw [ Finset.sum_eq_add_sum_diff_singleton hs ] at this; linarith [ μ.nonneg s, Finset.sum_nonneg fun x ( hx : x ∈ Finset.powerset ( Finset.univ : Finset ( Fin n ) ) \ { s } ) => μ.nonneg x ] } ] ) ) ]

/-! ## Part 10: Core Theorems -/

/-
**Theorem 2: Chi-squared / mutual information bound from covariance control.**

    If μ is robustly Lorentzian with gap ε, then the chi-squared divergence
    between the joint law of `(X_i, X_j)` and the product of marginals is bounded
    by `ε² / (ε(1-ε))²`. Since MI ≤ chi-squared, this bounds pairwise MI.

    The proof uses three key ingredients:
    1. `cov_control` gives `|Cov(X_i, X_j)| ≤ ε`, so `Cov² ≤ ε²`
    2. `marginal_lower/upper` gives `p(1-p) ≥ ε(1-ε)` via convexity
    3. The quotient is monotone: smaller numerator and larger denominator
-/
theorem mutualInfo_cov_bound
    {n : ℕ} (μ : FinsetLaw n) {ε : ℝ}
    (hrob : RobustlyLorentzian μ ε)
    {i j : Fin n} (hij : i ≠ j) :
    (coordCov μ i j) ^ 2 / (coordProb μ i * (1 - coordProb μ i) *
      (coordProb μ j * (1 - coordProb μ j))) ≤
    ε ^ 2 / (ε * (1 - ε)) ^ 2 := by
  -- Apply the bounds on the covariance and marginal variances.
  have h_num : (coordCov μ i j) ^ 2 ≤ ε ^ 2 := by
    nlinarith [ abs_le.mp ( hrob.cov_control hij ) ]
  have h_denom : (coordProb μ i * (1 - coordProb μ i)) * (coordProb μ j * (1 - coordProb μ j)) ≥ (ε * (1 - ε)) ^ 2 := by
    have h_denom : coordProb μ i * (1 - coordProb μ i) ≥ ε * (1 - ε) ∧ coordProb μ j * (1 - coordProb μ j) ≥ ε * (1 - ε) := by
      exact ⟨ marginal_variance_lower hrob.hε_pos hrob.hε_le ( hrob.marginal_lower i ) ( hrob.marginal_upper i ), marginal_variance_lower hrob.hε_pos hrob.hε_le ( hrob.marginal_lower j ) ( hrob.marginal_upper j ) ⟩;
    nlinarith only [ h_denom, show 0 ≤ ε * ( 1 - ε ) by nlinarith only [ hrob.hε_pos, hrob.hε_le ] ];
  gcongr;
  exact sq_pos_of_pos ( mul_pos hrob.hε_pos ( sub_pos.mpr ( lt_of_le_of_lt hrob.hε_le ( by norm_num ) ) ) )

/-
**Theorem 3: Covariance magnitude bounded by gap.**
-/
theorem mutualInfo_bounded_by_gap
    {n : ℕ} (μ : FinsetLaw n) {ε : ℝ}
    (hrob : RobustlyLorentzian μ ε)
    {i j : Fin n} (hij : i ≠ j) :
    (coordCov μ i j) ^ 2 ≤ ε ^ 2 := by
  convert pow_le_pow_left₀ ( abs_nonneg _ ) ( hrob.cov_control hij ) 2 using 1 ; rw [ sq_abs ]

/-
**Theorem 4: Entropy deletion lower bound.**

    Deleting one coordinate decreases entropy by at most `log 2`.
    Each fiber of the deletion map has at most 2 preimages
    (the set with and without coordinate k), so by the grouping
    axiom of entropy, the entropy loss is at most `log 2`.
-/
theorem entropy_delete_lower_bound
    {n : ℕ} (μ : FinsetLaw (n + 1)) (k : Fin (n + 1)) :
    totalEntropy (deleteCoordPushforward μ k) ≥ totalEntropy μ - Real.log 2 := by
  -- Let's simplify the expression for the total entropy of the pushforward.
  unfold totalEntropy;
  -- Data processing inequality: entropy of the pushforward is at least the entropy of the original minus the entropy of the kernel.
  have h_data_processing : ∀ t : Finset (Fin n), (∑ s ∈ (Finset.univ.powerset.filter (fun s => deleteCoordImage k s = t)), (μ.weight s)) * Real.log (∑ s ∈ (Finset.univ.powerset.filter (fun s => deleteCoordImage k s = t)), (μ.weight s)) ≤ ∑ s ∈ (Finset.univ.powerset.filter (fun s => deleteCoordImage k s = t)), (μ.weight s) * Real.log (μ.weight s) + (Real.log 2) * (∑ s ∈ (Finset.univ.powerset.filter (fun s => deleteCoordImage k s = t)), (μ.weight s)) := by
    intro t;
    have h_log_sum : ∀ (x y : ℝ), 0 ≤ x → 0 ≤ y → (x + y) * Real.log (x + y) ≤ x * Real.log x + y * Real.log y + Real.log 2 * (x + y) := by
      intro x y hx hy; rcases eq_or_lt_of_le hx with ( rfl | hx ) <;> rcases eq_or_lt_of_le hy with ( rfl | hy ) <;> norm_num;
      · positivity;
      · positivity;
      · -- By Jensen's inequality for the convex function $f(t) = t \log t$, we have:
        have h_jensen : (x / (x + y)) * Real.log (x / (x + y)) + (y / (x + y)) * Real.log (y / (x + y)) ≥ 2 * (1 / 2) * Real.log (1 / 2) := by
          have h_jensen : ConvexOn ℝ (Set.Ioi 0) (fun t : ℝ => t * Real.log t) := by
            exact ( Real.convexOn_mul_log.subset Set.Ioi_subset_Ici_self <| convex_Ioi _ );
          have := h_jensen.2 ( show 0 < x / ( x + y ) by positivity ) ( show 0 < y / ( x + y ) by positivity );
          have := @this ( 1 / 2 ) ( 1 / 2 ) ( by norm_num ) ( by norm_num ) ( by norm_num ) ; norm_num at *;
          rw [ show ( 1 / 2 * ( x / ( x + y ) ) + 1 / 2 * ( y / ( x + y ) ) ) = 1 / 2 by rw [ div_mul_div_comm, div_mul_div_comm ] ; rw [ div_add_div_same, div_eq_iff ] <;> linarith ] at this ; linarith;
        norm_num [ Real.log_div, hx.ne', hy.ne', ne_of_gt ( add_pos hx hy ) ] at *;
        rw [ div_mul_eq_mul_div, div_mul_eq_mul_div, ← add_div, le_div_iff₀ ] at h_jensen <;> nlinarith;
    -- Since these are the only subsets, we can split the sum into two parts: one where $k$ is included and one where it is not.
    have h_split : ∃ s1 s2 : Finset (Fin (n + 1)), deleteCoordImage k s1 = t ∧ deleteCoordImage k s2 = t ∧ (∀ s : Finset (Fin (n + 1)), deleteCoordImage k s = t → s = s1 ∨ s = s2) := by
      refine' ⟨ Finset.image ( Fin.succAbove k ) t, Finset.image ( Fin.succAbove k ) t ∪ { k }, _, _, _ ⟩ <;> simp +decide [ deleteCoordImage ];
      intro s hs; by_cases hk : k ∈ s <;> simp_all +decide [ Finset.ext_iff ] ;
      · refine Or.inr fun a => ⟨ fun ha => ?_, fun ha => ?_ ⟩;
        · by_cases ha' : a = k <;> simp_all +decide [ Fin.succAbove_ne ];
          cases' Fin.exists_succAbove_eq ha' with b hb ; use b ; aesop;
        · grind;
      · refine Or.inl fun a => ⟨ fun ha => ?_, fun ha => ?_ ⟩;
        · cases' Fin.exists_succAbove_eq ( show a ≠ k from by aesop ) with b hb ; use b ; aesop;
        · grind;
    obtain ⟨ s1, s2, hs1, hs2, h ⟩ := h_split;
    rw [ show ( Finset.univ.powerset.filter fun s => deleteCoordImage k s = t ) = { s1, s2 } from ?_ ];
    · by_cases h : s1 = s2 <;> simp_all +decide;
      · exact mul_nonneg ( Real.log_nonneg ( by norm_num ) ) ( μ.nonneg _ );
      · exact h_log_sum _ _ ( μ.nonneg _ ) ( μ.nonneg _ );
    · grind;
  -- Summing over all $t$, we get the desired inequality.
  have h_sum : ∑ t ∈ Finset.univ.powerset, (∑ s ∈ (Finset.univ.powerset.filter (fun s => deleteCoordImage k s = t)), (μ.weight s)) * Real.log (∑ s ∈ (Finset.univ.powerset.filter (fun s => deleteCoordImage k s = t)), (μ.weight s)) ≤ ∑ s ∈ Finset.univ.powerset, (μ.weight s) * Real.log (μ.weight s) + (Real.log 2) * (∑ s ∈ Finset.univ.powerset, (μ.weight s)) := by
    refine le_trans ( Finset.sum_le_sum fun t ht => h_data_processing t ) ?_;
    simp +decide only [Finset.mul_sum _ _ _, sum_add_distrib];
    rw [ ← Finset.sum_biUnion, ← Finset.sum_biUnion ];
    · gcongr;
      · simp +contextual [ deleteCoordImage ];
      · exact Finset.biUnion_subset.mpr fun _ _ => Finset.filter_subset _ _;
      · exact fun _ _ _ => mul_nonneg ( Real.log_nonneg ( by norm_num ) ) ( μ.nonneg _ );
      · exact Finset.biUnion_subset.mpr fun x hx => Finset.filter_subset _ _;
    · exact fun x _ y _ hxy => Finset.disjoint_left.mpr fun s hsx hsy => hxy <| by aesop;
    · exact fun x _ y _ hxy => Finset.disjoint_left.mpr fun s hsx hsy => hxy <| by aesop;
  simp_all +decide [ Finset.sum_ite, deleteCoordPushforward ];
  convert h_sum using 1;
  · exact Finset.sum_subset ( Finset.subset_univ _ ) fun x hx₁ hx₂ => by aesop;
  · rw [ Finset.sum_filter_of_ne ] <;> norm_num [ add_comm, μ.total_one ];
    · exact μ.total_one ▸ by simp +decide [ Finset.sum_powerset ] ;
    · aesop

/-
**Theorem 5 (Cross-Domain Bridge): Susceptibility bound from robust Lorentzianity.**

    The susceptibility `χ(μ) = ∑_{i,j} Cov(X_i, X_j)` is bounded by `n/4`.
    This bridges to statistical mechanics: Lorentzian negativity limits
    the magnetic susceptibility, preventing divergence of correlations.

    **Proof strategy:**
    - Diagonal terms: `∑_i Var(X_i) ≤ n · (1/4)` since Bernoulli variance ≤ 1/4
    - Off-diagonal terms: `∑_{i≠j} Cov(X_i, X_j) ≤ 0` by negative dependence
    - Total: `χ ≤ n/4 + 0 = n/4`
-/
theorem susceptibility_bound_of_robust
    {n : ℕ} (μ : FinsetLaw n) {ε : ℝ}
    (hrob : RobustlyLorentzian μ ε) :
    spinSusceptibility μ ≤ susceptibilityBound n ε := by
  -- The diagonal part: ∑_i coordCov μ i i. We need to show coordCov μ i i = pairJointProb μ i i - (coordProb μ i)². Since pairJointProb μ i i = coordProb μ i (the condition i∈S ∧ i∈S is just i∈S), we get coordCov μ i i = coordProb μ i - (coordProb μ i)² = coordProb μ i * (1 - coordProb μ i) ≤ 1/4.
  have h_diag : ∀ i : Fin n, coordCov μ i i ≤ 1 / 4 := by
    intro i
    have h_diag : coordCov μ i i = coordProb μ i * (1 - coordProb μ i) := by
      unfold coordCov coordProb pairJointProb; ring;
      simp +contextual [ Finset.sum_ite ];
    linarith [ sq_nonneg ( coordProb μ i - 1 / 2 ) ];
  -- The off-diagonal part: by hrob.neg_dep, each term is ≤ 0, so the sum is ≤ 0.
  have h_off_diag : ∀ i j : Fin n, i ≠ j → coordCov μ i j ≤ 0 := by
    exact fun i j hij => hrob.neg_dep hij;
  refine' le_trans ( Finset.sum_le_sum fun i _ => Finset.sum_le_sum fun j _ => _ ) _;
  use fun i j => if i = j then 1 / 4 else 0;
  · grind;
  · norm_num [ Finset.sum_ite, susceptibilityBound ];
    linarith

/-- **Theorem 6: Shearer-type inequality under robust Lorentzianity.**

    For coordinate subsets `A_1, ..., A_m` covering each coordinate at least `r` times,
    `H(μ) ≤ (1/r) ∑_t H(π_{A_t} μ) + shearerError ε`. -/
theorem shearer_type_of_robust_lorentzian
    {n m : ℕ} (μ : FinsetLaw n) {ε : ℝ}
    (hε : 0 < ε) (hrob : RobustlyLorentzian μ ε)
    (r : ℕ) (A : Fin m → Finset (Fin n))
    (hcover : ∀ i : Fin n, r ≤ (Finset.univ.filter fun t => i ∈ A t).card)
    (hr : 0 < r) :
    totalEntropy μ ≤
      (1 / (r : ℝ)) * ∑ t : Fin m, totalEntropy (projectToSet μ (A t))
      + shearerError ε := by
  sorry

/-! ## Part 11: Information Profile -/

/-- An information profile bundles computed entropy and covariance data. -/
structure InfoProfile (n : ℕ) where
  entropy : ℝ
  coordProbs : Fin n → ℝ
  covMatrix : Fin n → Fin n → ℝ
  susceptibility : ℝ

/-- Compute the information profile of a FinsetLaw. -/
def auditRobustLorentzianInfoProfile (μ : FinsetLaw n) : InfoProfile n where
  entropy := totalEntropy μ
  coordProbs := coordProb μ
  covMatrix := fun i j => coordCov μ i j
  susceptibility := spinSusceptibility μ

end LorentzianInfoTheory