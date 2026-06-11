/-
  # Going Deeper on the Information-Geometric Bridge:
  #   Tensorization, the Cramér–Rao bound, and the tensorial law of the Fisher metric

  This module *extends and generalizes* `Bridges.FisherInformationRiemannian`
  (the construction of the Fisher information metric `fisher` on a finite-sample
  statistical model and the proof that it satisfies the Riemannian metric axioms,
  together with the KL bridge).  Here we:

  * **Generalize the sample space** from `Fin n` to an arbitrary finite type `S`
    (`GenStatModel`), and re-derive the metric axioms (`gfisher_symm`,
    `gfisher_posSemidef`, `gfisher_posDef`) in this generality.

  * **Tensorization / additivity of Fisher information** (`gfisher_prod_eq`): the
    Fisher metric of a product of two *independent* models with a shared parameter
    is the *sum* of the two Fisher metrics.  In particular, two i.i.d. observations
    carry twice the single-observation information (`gfisher_iid_two`).  This is the
    precise sense in which Fisher information is *additive over independent data* —
    the statistical foundation of estimator consistency.

  * **The Cramér–Rao lower bound** (`cramer_rao`): for any (regular) statistic `T`
    the variance is bounded below by `ψ'(θ)² / G(θ)`, where `ψ = E_θ[T]`.  This is
    the deepest classical bridge between the Fisher metric and statistical
    inference: the inverse Fisher metric is the intrinsic lower bound on estimator
    variance.  The proof is a weighted Cauchy–Schwarz inequality
    (`expect_mul_sq_le`) for the score inner product, exactly the inner product
    whose Gram matrix is `gfisher`.

  * **The tensorial transformation law** (`gfisher_reparam`): under a smooth
    reparametrization with Jacobian `J`, the Fisher matrix transforms by the
    congruence `G' = Jᵀ G J`.  This is the statement that `gfisher` is a genuine
    `(0,2)`-tensor — the differential-geometric content of "Riemannian metric".

  Together these promote the catalog's "Fisher is a metric" result to the full
  package a working information geometer needs: additivity, the Cramér–Rao
  inference bound, and tensoriality.
-/
import Mathlib

open Finset BigOperators Real

noncomputable section

namespace FisherCramerRao

/-! ## I. Statistical models on an arbitrary finite sample space

    This generalizes `FisherRiemannian.StatModel` (whose sample space is `Fin n`)
    to an arbitrary finite type `S`, which is exactly what is needed to form
    *product* sample spaces `S × S'` for the tensorization theorem. -/

/-- A statistical model on a finite sample space `S`, parametrized by `Fin d → ℝ`. -/
structure GenStatModel (S : Type*) [Fintype S] (d : ℕ) where
  p : (Fin d → ℝ) → S → ℝ
  p_pos : ∀ θ x, 0 < p θ x
  p_sum : ∀ θ, ∑ x, p θ x = 1
  score : (Fin d → ℝ) → S → Fin d → ℝ
  score_mean_zero : ∀ θ i, ∑ x, p θ x * score θ x i = 0

variable {S S' : Type*} [Fintype S] [Fintype S'] {d : ℕ}

/-- The Fisher information matrix of a `GenStatModel`. -/
def gfisher (M : GenStatModel S d) (θ : Fin d → ℝ) (i j : Fin d) : ℝ :=
  ∑ x, M.p θ x * M.score θ x i * M.score θ x j

/-- Expectation of a real statistic under the model at `θ`. -/
def expect (M : GenStatModel S d) (θ : Fin d → ℝ) (f : S → ℝ) : ℝ :=
  ∑ x, M.p θ x * f x

/-- Variance of a real statistic under the model at `θ`. -/
def variance (M : GenStatModel S d) (θ : Fin d → ℝ) (f : S → ℝ) : ℝ :=
  expect M θ (fun x => (f x - expect M θ f) ^ 2)

/-! ## II. The metric axioms in full generality -/

-- !-- Each summand is symmetric in `i, j`. -- !--
theorem gfisher_symm (M : GenStatModel S d) (θ : Fin d → ℝ) (i j : Fin d) :
    gfisher M θ i j = gfisher M θ j i := by
  simp [gfisher, mul_assoc, mul_comm, mul_left_comm]

-- !-- The quadratic form collapses to `∑_x p·(∑_i v_i score_i)²` after swapping
--     the order of summation (`Finset.sum_comm`) and factoring out `p`. -- !--
theorem gfisher_quadForm_eq (M : GenStatModel S d) (θ v : Fin d → ℝ) :
    (∑ i, ∑ j, v i * gfisher M θ i j * v j)
      = ∑ x, M.p θ x * (∑ i, v i * M.score θ x i) ^ 2 := by
  simp +decide [ gfisher, mul_assoc, mul_comm, mul_left_comm, Finset.mul_sum _ _ _,
    Finset.sum_mul, pow_two ]
  exact Eq.symm ( Finset.sum_comm.trans ( Finset.sum_congr rfl fun _ _ => Finset.sum_comm ) )

-- !-- Positive semidefiniteness: the quadratic form is a sum of `p·(·)² ≥ 0`. -- !--
theorem gfisher_posSemidef (M : GenStatModel S d) (θ v : Fin d → ℝ) :
    0 ≤ ∑ i, ∑ j, v i * gfisher M θ i j * v j := by
  rw [gfisher_quadForm_eq]
  exact Finset.sum_nonneg fun _ _ => mul_nonneg (le_of_lt (M.p_pos _ _)) (sq_nonneg _)

/-- Score nondegeneracy (first-order identifiability) at `θ`: no nonzero tangent
    direction is annihilated by every outcome's score. -/
def ScoreNondegenerate (M : GenStatModel S d) (θ : Fin d → ℝ) : Prop :=
  ∀ v : Fin d → ℝ, (∀ x, (∑ i, v i * M.score θ x i) = 0) → v = 0

-- !-- Positive definiteness: vanishing of `∑ p·(·)²` with `p > 0` forces every
--     weighted score to vanish, so nondegeneracy gives `v = 0`. -- !--
theorem gfisher_posDef (M : GenStatModel S d) (θ : Fin d → ℝ)
    (hnd : ScoreNondegenerate M θ) (v : Fin d → ℝ) (hv : v ≠ 0) :
    0 < ∑ i, ∑ j, v i * gfisher M θ i j * v j := by
  by_contra h_contra
  obtain ⟨x, hx⟩ : ∃ x : S, M.p θ x * (∑ i, v i * M.score θ x i) ^ 2 ≠ 0 := by
    exact not_forall.mp fun h => hv <| hnd v fun x => by simpa [ ne_of_gt ( M.p_pos θ x ) ] using h x
  exact h_contra <| lt_of_lt_of_le ( lt_of_le_of_ne ( mul_nonneg ( le_of_lt ( M.p_pos θ x ) )
    ( sq_nonneg _ ) ) hx.symm ) <| Finset.single_le_sum ( fun x _ => mul_nonneg
    ( le_of_lt ( M.p_pos θ x ) ) ( sq_nonneg ( ∑ i, v i * M.score θ x i ) ) )
    ( Finset.mem_univ x ) |> le_trans <| by rw [ gfisher_quadForm_eq ]

/-! ## III. Tensorization: Fisher information is additive over independent data -/

/-- The **independent product** of two models on `S`, `S'` sharing the parameter
    `θ`.  The likelihood factorizes, so the score is the *sum* of the two scores
    (the log-likelihood being a sum). -/
def prodModel (M : GenStatModel S d) (N : GenStatModel S' d) :
    GenStatModel (S × S') d where
  p := fun θ x => M.p θ x.1 * N.p θ x.2
  p_pos := fun θ x => mul_pos (M.p_pos θ x.1) (N.p_pos θ x.2)
  p_sum := by
    intro θ
    rw [Fintype.sum_prod_type]
    simp_rw [← Finset.mul_sum, ← Finset.sum_mul, M.p_sum, N.p_sum, one_mul]
  score := fun θ x i => M.score θ x.1 i + N.score θ x.2 i
  score_mean_zero := by
    intro θ i
    simp +decide only [mul_add]
    rw [ Finset.sum_add_distrib, Fintype.sum_prod_type, Fintype.sum_prod_type ]
    simp +decide [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul, mul_assoc, mul_comm, mul_left_comm,
      M.p_sum, N.p_sum, M.score_mean_zero, N.score_mean_zero ]

-- !-- Expand `(s^M + s^N)(s^M + s^N)` over the product space into four terms.  The
--     two diagonal terms reproduce `gfisher M` and `gfisher N` (using `∑ p = 1` in
--     the other factor); the two cross terms factor as products of mean-zero scores
--     and so vanish by `score_mean_zero`. -- !--
theorem gfisher_prod_eq (M : GenStatModel S d) (N : GenStatModel S' d)
    (θ : Fin d → ℝ) (i j : Fin d) :
    gfisher (prodModel M N) θ i j = gfisher M θ i j + gfisher N θ i j := by
  simp +decide [ gfisher, prodModel ]
  have h_split : ∑ x : S, ∑ y : S', M.p θ x * N.p θ y * (M.score θ x i + N.score θ y i) * (M.score θ x j + N.score θ y j) =
    (∑ x : S, M.p θ x * M.score θ x i * M.score θ x j) * (∑ y : S', N.p θ y) +
    (∑ y : S', N.p θ y * N.score θ y i * N.score θ y j) * (∑ x : S, M.p θ x) +
    (∑ x : S, M.p θ x * M.score θ x i) * (∑ y : S', N.p θ y * N.score θ y j) +
    (∑ x : S, M.p θ x * M.score θ x j) * (∑ y : S', N.p θ y * N.score θ y i) := by
      simp +decide only [mul_add, mul_assoc, add_mul, sum_add_distrib, sum_mul _ _ _]
      simp +decide only [mul_comm, mul_left_comm, Finset.mul_sum _ _ _] ; ring
      simp +decide only [mul_assoc, Finset.mul_sum _ _ _, sum_mul] ; ring
      exact congr rfl ( Finset.sum_comm.trans ( Finset.sum_congr rfl fun _ _ =>
        Finset.sum_congr rfl fun _ _ => by ring ) )
  simp_all +decide [ GenStatModel.p_sum, GenStatModel.score_mean_zero ]
  erw [ ← h_split, Finset.sum_product ]

/-! ## IV. The Cramér–Rao lower bound -/

-- !-- Weighted Cauchy–Schwarz for the expectation inner product: apply
--     `Finset.sum_mul_sq_le_sq_mul_sq` to the weighted functions `√p·a`, `√p·b`
--     and simplify with `Real.sq_sqrt` (using `p > 0`). -- !--
theorem expect_mul_sq_le (M : GenStatModel S d) (θ : Fin d → ℝ) (a b : S → ℝ) :
    (expect M θ (fun x => a x * b x)) ^ 2
      ≤ expect M θ (fun x => a x ^ 2) * expect M θ (fun x => b x ^ 2) := by
  unfold expect
  convert Finset.sum_mul_sq_le_sq_mul_sq ( Finset.univ : Finset S )
    ( fun x => Real.sqrt ( M.p θ x ) * a x ) ( fun x => Real.sqrt ( M.p θ x ) * b x ) using 2 <;> ring
  · exact Finset.sum_congr rfl fun _ _ => by rw [ Real.sq_sqrt ( le_of_lt ( M.p_pos _ _ ) ) ]
  · exact Finset.sum_congr rfl fun _ _ => by rw [ Real.sq_sqrt ( le_of_lt ( M.p_pos θ _ ) ) ]
  · exact Finset.sum_congr rfl fun _ _ => by rw [ Real.sq_sqrt ( le_of_lt ( M.p_pos _ _ ) ) ]

/-- **Cramér–Rao lower bound** (single parameter).  For a statistic `T` whose
    expectation `ψ(θ) = E_θ[T]` is differentiable with the *regularity identity*
    `ψ'(θ) = E_θ[T · score]` (interchange of differentiation and expectation), the
    variance of `T` is bounded below by `ψ'(θ)² / G(θ)`.  Here we state the bound
    in the cleared form `ψ'(θ)² ≤ Var_θ(T) · G(θ)`, valid without dividing.

    Geometrically: the inverse Fisher metric is the intrinsic lower bound on the
    variance of any (regular) estimator — the metric *measures information*. -/
-- !-- With `Sx = score x 0`, `a x = T x − E[T]`, we have `E[a·S] = E[T·S] − E[T]·E[S]
--     = ψ' − E[T]·0 = ψ'` by `score_mean_zero`; apply `expect_mul_sq_le` to `a, S`,
--     noting `E[a²] = Var(T)` and `E[S²] = gfisher 0 0`. -- !--
theorem cramer_rao (M : GenStatModel S 1) (θ : Fin 1 → ℝ) (T : S → ℝ)
    (psiPrime : ℝ)
    (hreg : expect M θ (fun x => T x * M.score θ x 0) = psiPrime) :
    psiPrime ^ 2 ≤ variance M θ T * gfisher M θ 0 0 := by
  convert expect_mul_sq_le M θ ( fun x => T x - expect M θ T ) ( fun x => M.score θ x 0 ) using 1
  · simp +decide only [hreg.symm, expect, sub_mul, mul_sub, sum_sub_distrib]
    simp +decide [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul, mul_assoc, mul_comm, mul_left_comm,
      M.score_mean_zero ]
    simp +decide [ ← mul_assoc, ← Finset.sum_mul _ _ _, M.score_mean_zero ]
  · simp +decide only [variance, sq, gfisher]
    simp +decide only [expect, mul_assoc]

/-! ## V. The tensorial transformation law (Fisher is a `(0,2)`-tensor) -/

-- !-- Substitute the chain-rule score `s'_a = ∑_i J_{a i} s_i` into `gfisher` for
--     `M'`, expand the product of the two sums, and pull the constants `J` out of
--     the `∑_x`, recognizing `∑_x p s_i s_j = gfisher i j`. -- !--
theorem gfisher_reparam (M : GenStatModel S d) {d' : ℕ}
    (M' : GenStatModel S d')
    (θ : Fin d → ℝ) (η : Fin d' → ℝ) (J : Fin d' → Fin d → ℝ)
    (hp : ∀ x, M'.p η x = M.p θ x)
    (hscore : ∀ x a, M'.score η x a = ∑ i, J a i * M.score θ x i)
    (a b : Fin d') :
    gfisher M' η a b = ∑ i, ∑ j, J a i * gfisher M θ i j * J b j := by
  simp +decide [ mul_assoc, mul_comm, mul_left_comm, Finset.mul_sum _ _ _, Finset.sum_mul, gfisher ]
  simp +decide only [hp, hscore, mul_sum, sum_mul, sum_sigma']
  apply Finset.sum_bij (fun x _ => ⟨x.snd.snd, x.snd.fst, x.fst⟩) _ _ _ _ <;>
    simp +decide [ mul_assoc, mul_comm, mul_left_comm ]
  grind

/-! ## VI. Corollaries -/

-- !-- Immediate from `gfisher_prod_eq` with `N = M`. -- !--
/-- **Additivity for i.i.d. data (`k = 2`).**  Two independent copies of the same
    model carry twice the Fisher information. -/
theorem gfisher_iid_two (M : GenStatModel S d) (θ : Fin d → ℝ) (i j : Fin d) :
    gfisher (prodModel M M) θ i j = 2 * gfisher M θ i j := by
  rw [gfisher_prod_eq]; ring

-- !-- Specialize `cramer_rao` to `ψ' = 1`. -- !--
/-- **Cramér–Rao for an unbiased estimator** of the scalar parameter `θ 0`:
    if `E_θ[T] = θ 0` near `θ` so that `ψ'(θ) = 1` (encoded as the regularity
    identity `E_θ[T·score] = 1`), then `Var_θ(T) · G(θ) ≥ 1`, i.e. the variance is
    at least the inverse Fisher information `1 / G(θ)`. -/
theorem cramer_rao_unbiased (M : GenStatModel S 1) (θ : Fin 1 → ℝ) (T : S → ℝ)
    (hreg : expect M θ (fun x => T x * M.score θ x 0) = 1) :
    1 ≤ variance M θ T * gfisher M θ 0 0 := by
  have := cramer_rao M θ T 1 hreg
  simpa using this

end FisherCramerRao

/-! ## VII. Attainment / efficiency: the equality case of Cramér–Rao

    The Cramér–Rao bound is *tight*: equality is achieved exactly when, locally at
    `θ`, the centered statistic is proportional to the score — i.e. the model is a
    one-parameter exponential family with `T` as its natural (efficient) statistic.
    Further strengthenings (the multiparameter matrix bound, the geodesic /
    α-connection picture) are recorded in `FUTURE_DIRECTIONS.md`. -/

namespace FisherCramerRao

variable {S : Type*} [Fintype S]

-- !-- Forward: equality in Cauchy–Schwarz is the vanishing of `E[(a − c·S)²]` at
--     `c = ψ'/G`, which equals `Var − ψ'²/G = 0`; as every `p(x) > 0`, each term
--     vanishes, giving pointwise proportionality.  Reverse: substitute `a = c·S`
--     and compute both sides directly. -- !--
/-- **Efficiency / attainment (equality case of Cramér–Rao).**  Equality holds in
    the Cramér–Rao bound iff the centered statistic `T − E_θ[T]` is proportional to
    the score, i.e. the model is a one-parameter exponential family with `T` its
    natural statistic and `T` an efficient estimator. -/
theorem cramer_rao_equality_iff (M : GenStatModel S 1) (θ : Fin 1 → ℝ) (T : S → ℝ)
    (psiPrime : ℝ) (hpos : 0 < gfisher M θ 0 0)
    (hreg : expect M θ (fun x => T x * M.score θ x 0) = psiPrime) :
    psiPrime ^ 2 = variance M θ T * gfisher M θ 0 0
      ↔ ∃ c : ℝ, ∀ x, T x - expect M θ T = c * M.score θ x 0 := by
  refine' ⟨ fun h => _, fun ⟨ c, hc ⟩ => _ ⟩;
  · -- Consider the nonnegative quantity Q := E (fun x => (a x - c * S x)^2) = ∑ x, p·(a x - c S x)^2 ≥ 0 (each term ≥0).
    set c := psiPrime / gfisher M θ 0 0
    have hQ_nonneg : ∑ x, M.p θ x * (T x - expect M θ T - c * M.score θ x 0) ^ 2 = 0 := by
      -- Expanding the sum using linearity of expectation.
      have h_expand : ∑ x, M.p θ x * (T x - expect M θ T - c * M.score θ x 0)^2 = variance M θ T - 2 * c * psiPrime + c^2 * gfisher M θ 0 0 := by
        simp +decide [ sub_sq, mul_assoc, mul_comm, mul_left_comm, Finset.mul_sum _ _ _, Finset.sum_add_distrib, Finset.sum_mul, gfisher, variance, expect ];
        simp +decide [ mul_add, mul_sub, Finset.sum_add_distrib, Finset.sum_sub_distrib, mul_assoc, mul_comm, mul_left_comm, Finset.mul_sum _ _ _, Finset.sum_mul, hreg.symm ];
        simp +decide [ ← mul_assoc, ← Finset.mul_sum _ _ _, ← Finset.sum_mul, M.score_mean_zero, expect ] ; ring;
        simp +decide [ mul_assoc, mul_comm, mul_left_comm, Finset.mul_sum _ _ _, Finset.sum_mul, M.score_mean_zero ];
        rw [ Finset.sum_comm ];
        simp +decide [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul, mul_assoc, mul_comm, mul_left_comm, M.score_mean_zero ];
      grind;
    rw [ Finset.sum_eq_zero_iff_of_nonneg fun _ _ => mul_nonneg ( le_of_lt ( M.p_pos _ _ ) ) ( sq_nonneg _ ) ] at hQ_nonneg;
    exact ⟨ c, fun x => eq_of_sub_eq_zero ( by simpa [ ne_of_gt ( M.p_pos _ _ ) ] using hQ_nonneg x ( Finset.mem_univ x ) ) ⟩;
  · -- Substitute $a x = c * S x$ into the expressions for variance and Fisher information.
    have h_var : variance M θ T = c ^ 2 * gfisher M θ 0 0 := by
      unfold variance gfisher;
      simp +decide only [expect, sq];
      rw [ Finset.mul_sum _ _ _ ] ; congr ; ext x ; rw [ show T x - ∑ x, M.p θ x * T x = c * M.score θ x 0 from hc x ] ; ring;
    have h_fisher : psiPrime = c * gfisher M θ 0 0 := by
      have h_psiPrime : psiPrime = ∑ x, M.p θ x * (expect M θ T + c * M.score θ x 0) * M.score θ x 0 := by
        exact hreg ▸ Finset.sum_congr rfl fun x _ => by rw [ ← hc x ] ; ring;
      simp +decide [ h_psiPrime, mul_add, add_mul, mul_assoc, mul_comm, mul_left_comm, Finset.mul_sum _ _ _, Finset.sum_add_distrib, gfisher ];
      simp +decide [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul, M.score_mean_zero ];
    rw [ h_var, h_fisher ] ; ring

end FisherCramerRao