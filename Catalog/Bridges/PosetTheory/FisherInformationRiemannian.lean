/-
  # Information-Geometric Bridge: the Fisher Metric on Statistical Manifolds

  This module formalizes, for a finite-sample-space statistical model parametrized
  by `ℝ^d`, the **Fisher information matrix** as an explicit expectation of the
  outer product of score functions, and proves that it satisfies the axioms of a
  Riemannian metric tensor:

  * `fisher_symm`        — the Fisher matrix is symmetric;
  * `fisher_quadForm_eq` — its quadratic form is an expectation of squares;
  * `fisher_posSemidef`  — it is positive semidefinite (metric nonnegativity);
  * `fisher_posDef`      — it is positive definite under score nondegeneracy.

  We then build the bridge to statistical inference / differential geometry:

  * `fisher_eq_score_cov`           — Fisher = covariance of the (zero-mean) score;
  * `fisher_eq_neg_expected_hessian`— Fisher = −E[Hessian of the log-likelihood],
        the *two forms of Fisher information* identity, i.e. the statement that the
        Fisher metric is the curvature (Hessian) of the Kullback–Leibler divergence;
  * `KL_self_zero`, `KL_nonneg`     — the Kullback–Leibler divergence vanishes on
        the diagonal and is nonnegative (Gibbs' inequality), the global companion of
        the local curvature statement above.

  Finally `bernoulliModel` is a concrete worked instance whose Fisher information is
  computed in closed form (`bernoulli_fisher`).

  This EXTENDS the abstract `MetricTensor` / Bregman picture of
  `Bridges.InformationGeometryOptimization`: there the Fisher metric is taken as a
  positive-definite tensor axiomatically; here we *construct* it from a probability
  model and *derive* the metric axioms and the KL connection.
-/
import Mathlib

open Finset BigOperators Real

noncomputable section

namespace FisherRiemannian

/-! ## I. Statistical models on a finite sample space -/

/-- A statistical model on the finite sample space `Fin n`, parametrized by
    `Fin d → ℝ`.  `p θ x` is the probability of outcome `x` under parameter `θ`,
    and `score θ x i` is the `i`-th component of the score vector
    `∂_i log p(x; θ)`.  The regularity condition `score_mean_zero` (`E_θ[score] = 0`)
    holds for every smooth model since `∑_x p = 1` is constant. -/
structure StatModel (n d : ℕ) where
  p : (Fin d → ℝ) → Fin n → ℝ
  p_pos : ∀ θ x, 0 < p θ x
  p_sum : ∀ θ, ∑ x, p θ x = 1
  score : (Fin d → ℝ) → Fin n → Fin d → ℝ
  score_mean_zero : ∀ θ i, ∑ x, p θ x * score θ x i = 0

variable {n d : ℕ}

/-- The Fisher information matrix
    `G_{ij}(θ) = E_θ[ ∂_i log p · ∂_j log p ] = ∑_x p(x;θ) · score_i · score_j`. -/
def fisher (M : StatModel n d) (θ : Fin d → ℝ) (i j : Fin d) : ℝ :=
  ∑ x, M.p θ x * M.score θ x i * M.score θ x j

/-! ## II. The Fisher matrix is a Riemannian metric tensor -/

-- !-- The Fisher matrix is symmetric because each summand is symmetric in i,j. -- !--
theorem fisher_symm (M : StatModel n d) (θ : Fin d → ℝ) (i j : Fin d) :
    fisher M θ i j = fisher M θ j i := by
  simp [fisher, mul_assoc, mul_comm, mul_left_comm]

-- !-- Expanding the double sum and pulling p out, the quadratic form collapses to
--     ∑_x p(x;θ) · (∑_i v i · score_i)², a manifestly nonnegative quantity. -- !--
theorem fisher_quadForm_eq (M : StatModel n d) (θ v : Fin d → ℝ) :
    (∑ i, ∑ j, v i * fisher M θ i j * v j)
      = ∑ x, M.p θ x * (∑ i, v i * M.score θ x i) ^ 2 := by
  simp +decide [ fisher, pow_two, mul_assoc, mul_comm, mul_left_comm, Finset.mul_sum _ _ _ ];
  exact Eq.symm ( by rw [ Finset.sum_comm ] ; exact Finset.sum_congr rfl fun _ _ => Finset.sum_comm.trans ( Finset.sum_congr rfl fun _ _ => Finset.sum_congr rfl fun _ _ => by ring ) )

-- !-- Positive semidefiniteness: the quadratic form equals a sum of p·(·)² ≥ 0. -- !--
theorem fisher_posSemidef (M : StatModel n d) (θ v : Fin d → ℝ) :
    0 ≤ ∑ i, ∑ j, v i * fisher M θ i j * v j := by
  rw [ fisher_quadForm_eq ] ; exact Finset.sum_nonneg fun _ _ => mul_nonneg ( le_of_lt ( M.p_pos _ _ ) ) ( sq_nonneg _ ) ;

/-- Score nondegeneracy at `θ`: the scores of the distinct outcomes span enough of
    `ℝ^d` that no nonzero direction is annihilated by every outcome's score.  This is
    the statistical-manifold rank condition (the model is *identifiable* to first
    order). -/
def ScoreNondegenerate (M : StatModel n d) (θ : Fin d → ℝ) : Prop :=
  ∀ v : Fin d → ℝ, (∀ x, (∑ i, v i * M.score θ x i) = 0) → v = 0

-- !-- Positive definiteness: if the quadratic form vanishes then, since every
--     p(x;θ) > 0, each weighted score ∑_i v i score_i vanishes, so nondegeneracy
--     forces v = 0. -- !--
theorem fisher_posDef (M : StatModel n d) (θ : Fin d → ℝ)
    (hnd : ScoreNondegenerate M θ) (v : Fin d → ℝ) (hv : v ≠ 0) :
    0 < ∑ i, ∑ j, v i * fisher M θ i j * v j := by
  -- By fisher_posSemidef the quadratic form is ≥ 0; suppose for contradiction it is not > 0, so it equals 0.
  by_contra h_contra
  have h_zero : ∑ x, M.p θ x * (∑ i, v i * M.score θ x i) ^ 2 = 0 := by
    rw [ ← fisher_quadForm_eq ];
    exact le_antisymm ( le_of_not_gt h_contra ) ( fisher_posSemidef M θ v );
  rw [ Finset.sum_eq_zero_iff_of_nonneg fun x _ => mul_nonneg ( le_of_lt ( M.p_pos θ x ) ) ( sq_nonneg _ ) ] at h_zero;
  exact hv <| hnd v fun x => by simpa [ ne_of_gt ( M.p_pos θ x ) ] using h_zero x ( Finset.mem_univ x ) ;

/-! ## III. Bridge to inference: Fisher = covariance of the score -/

-- !-- Since the score has zero mean, its covariance E[s_i s_j] − E[s_i]E[s_j] is
--     just E[s_i s_j], which is the Fisher matrix by definition. -- !--
theorem fisher_eq_score_cov (M : StatModel n d) (θ : Fin d → ℝ) (i j : Fin d) :
    fisher M θ i j
      = (∑ x, M.p θ x * M.score θ x i * M.score θ x j)
        - (∑ x, M.p θ x * M.score θ x i) * (∑ x, M.p θ x * M.score θ x j) := by
  unfold fisher; norm_num [ M.score_mean_zero ] ;

/-! ## IV. Bridge to geometry: Fisher = −E[Hessian of the log-likelihood]

    This is the *two forms of Fisher information* identity.  Writing
    `score = ∂ log p` and `hess = ∂² log p`, the chain rule gives
    `∂_i∂_j log p = (∂_i∂_j p)/p − score_i · score_j`.  Combined with the
    regularity condition `∑_x ∂_i∂_j p = 0` (constancy of `∑_x p = 1`), encoded as
    `secondReg`, this yields `G_{ij} = −E_θ[∂_i∂_j log p]`.  Geometrically, the
    right-hand side is the Hessian of the Kullback–Leibler divergence `θ' ↦ KL(θ‖θ')`
    at `θ' = θ`, so the Fisher metric is exactly the curvature of KL. -/

-- !-- Multiply the chain rule `hess = secondScore − score⊗score` by p and sum:
--     ∑ p·hess = ∑ p·secondScore − ∑ p·score⊗score = 0 − fisher = −fisher. -- !--
theorem fisher_eq_neg_expected_hessian (M : StatModel n d) (θ : Fin d → ℝ)
    (i j : Fin d)
    (hess secondScore : Fin n → ℝ)
    (chain : ∀ x, hess x = secondScore x - M.score θ x i * M.score θ x j)
    (secondReg : ∑ x, M.p θ x * secondScore x = 0) :
    fisher M θ i j = - ∑ x, M.p θ x * hess x := by
  simp_all +decide [ mul_sub, mul_comm ]
  exact Finset.sum_congr rfl fun _ _ => by ring

/-! ## V. The global companion: Kullback–Leibler divergence -/

/-- Kullback–Leibler divergence `KL(p‖q) = ∑_x p x · log (p x / q x)`. -/
def KL (p q : Fin n → ℝ) : ℝ := ∑ x, p x * Real.log (p x / q x)

-- !-- KL(p‖p) = ∑ p · log 1 = 0. -- !--
theorem KL_self_zero (p : Fin n → ℝ) (hp : ∀ x, p x ≠ 0) : KL p p = 0 := by
  exact Finset.sum_eq_zero fun x _ => by simp +decide [ hp x ] ;

-- !-- Gibbs' inequality.  Using log t ≤ t − 1 with t = q/p:
--     −KL = ∑ p·log(q/p) ≤ ∑ p·(q/p − 1) = ∑ q − ∑ p = 1 − 1 = 0. -- !--
theorem KL_nonneg (p q : Fin n → ℝ) (hp : ∀ x, 0 < p x) (hq : ∀ x, 0 < q x)
    (hps : ∑ x, p x = 1) (hqs : ∑ x, q x = 1) :
    0 ≤ KL p q := by
  -- Apply the inequality $\log(t) \geq 1 - \frac{1}{t}$ to each term in the sum.
  have h_ineq : ∀ x, p x * Real.log (p x / q x) ≥ p x * (1 - q x / p x) := by
    intro x; have := Real.log_le_sub_one_of_pos ( div_pos ( hq x ) ( hp x ) ) ; simp_all +decide
    rw [ Real.log_div ] at * <;> linarith [ hp x, hq x ]
  refine' le_trans _ ( Finset.sum_le_sum fun x _ => h_ineq x );
  simp +decide [ mul_sub, mul_div_cancel₀ _ ( ne_of_gt ( hp _ ) ), hps, hqs ]

/-! ## VI. A concrete worked instance: the Bernoulli family

    Sample space `Fin 2`, one parameter.  With `σ θ ∈ (0,1)` the success probability
    and `dσ θ` its derivative, the model
    `p(0) = σ`, `p(1) = 1 − σ`, `score(0) = dσ/σ`, `score(1) = −dσ/(1−σ)`
    has Fisher information `G(θ) = dσ(θ)² / (σ(θ)(1−σ(θ)))`, the classical Bernoulli
    Fisher information. -/

/-- The Bernoulli statistical model parametrized through a smooth success
    probability `σ : ℝ → ℝ` with derivative `dσ`. -/
def bernoulliModel (σ dσ : ℝ → ℝ) (hσ0 : ∀ t, 0 < σ t) (hσ1 : ∀ t, σ t < 1) :
    StatModel 2 1 where
  p := fun θ x => if x = 0 then σ (θ 0) else 1 - σ (θ 0)
  p_pos := by
    intro θ x
    fin_cases x <;> simp
    · exact hσ0 _
    · linarith [hσ1 (θ 0)]
  p_sum := by
    intro θ; rw [Fin.sum_univ_two]; simp
  score := fun θ x _ =>
    if x = 0 then dσ (θ 0) / σ (θ 0) else - dσ (θ 0) / (1 - σ (θ 0))
  score_mean_zero := by
    intro θ i
    rw [Fin.sum_univ_two]; simp
    have h0 : σ (θ 0) ≠ 0 := ne_of_gt (hσ0 (θ 0))
    have h1 : (1 : ℝ) - σ (θ 0) ≠ 0 := by linarith [hσ1 (θ 0)]
    field_simp
    ring

-- !-- Direct computation over the two outcomes:
--     G = σ·(dσ/σ)² + (1−σ)·(dσ/(1−σ))² = dσ²/σ + dσ²/(1−σ) = dσ²/(σ(1−σ)). -- !--
theorem bernoulli_fisher (σ dσ : ℝ → ℝ) (hσ0 : ∀ t, 0 < σ t) (hσ1 : ∀ t, σ t < 1)
    (θ : Fin 1 → ℝ) :
    fisher (bernoulliModel σ dσ hσ0 hσ1) θ 0 0
      = dσ (θ 0) ^ 2 / (σ (θ 0) * (1 - σ (θ 0))) := by
  unfold fisher bernoulliModel
  rw [Fin.sum_univ_two]; simp
  have h0 : σ (θ 0) ≠ 0 := ne_of_gt (hσ0 (θ 0))
  have h1 : (1 : ℝ) - σ (θ 0) ≠ 0 := by linarith [hσ1 (θ 0)]
  field_simp
  ring

end FisherRiemannian