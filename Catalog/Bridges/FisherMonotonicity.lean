/-
  # Deepening the Information-Geometric Bridge:
  #   Chentsov monotonicity (the data-processing inequality for the Fisher metric)
  #   and the directional / multiparameter Cramér–Rao bound

  This module goes *deeper* on the catalog's Fisher-metric programme,
  `Bridges.FisherInformationRiemannian` (construction of the Fisher metric
  `fisher` and the proof of the Riemannian metric axioms + the KL bridge) and
  `Bridges.FisherCramerRao` (the generalized model `GenStatModel`, tensorization
  `gfisher_prod_eq`, the scalar Cramér–Rao bound `cramer_rao`, tensoriality
  `gfisher_reparam`, and the efficiency equality case `cramer_rao_equality_iff`).
  It closes two of the directions flagged there ("the multiparameter matrix bound,
  the geodesic / α-connection picture") on the inference and the geometry side:

  * **Directional Cramér–Rao** (`cramer_rao_directional`).  For *any* statistic
    `f : S → ℝ` and *any* tangent direction `w : Fin d → ℝ`,
        `(E_θ[f · (w·score)])² ≤ Var_θ(f) · (wᵀ G w)`,
    where `w·score = ∑_b w_b score_b` and `wᵀ G w = ∑_{a,b} w_a G_{ab} w_b`.  This
    is the full multiparameter Cramér–Rao information bound: it specializes to the
    catalog's `FisherCramerRao.cramer_rao` at `d = 1`, `w ≡ 1`
    (`cramer_rao_of_directional`).

  * **Chentsov monotonicity / data-processing for the Fisher metric**
    (`fisher_monotone_coarsegrain`, `gfisher_pushModel_le`).  Coarse-graining the
    sample space by an *arbitrary* deterministic statistic `T : S → S'` can only
    *decrease* the Fisher quadratic form:
        `Q_θ^{T_*M}(v) ≤ Q_θ^{M}(v)`  for every direction `v`.
    Here the coarse model `T_*M` carries the conditional-expectation score
    `s̄(y) = E_θ[score | T = y]`, and the inequality is, fibrewise, exactly the
    Cauchy–Schwarz / Jensen contraction of conditional expectation
    `(E[score | T])² ≤ E[score² | T]`.  This is the differential-geometric form of
    the data-processing inequality and the heart of Chentsov's theorem (the Fisher
    metric is the unique monotone metric on statistical manifolds).  We package the
    coarse model as a genuine `GenStatModel` (`pushModel`, under surjectivity of
    `T`) so the statement reads as a Loewner inequality between Fisher tensors.

  All results are proved over an arbitrary finite sample space and reuse the
  `GenStatModel` / `gfisher` / `expect` / `variance` API of `FisherCramerRao`.
-/
import Bridges.FisherCramerRao

open Finset BigOperators Real

noncomputable section

namespace FisherMonotonicity

open FisherCramerRao

variable {S S' : Type*} [Fintype S] [Fintype S'] [DecidableEq S'] {d : ℕ}

/-! ## I. The directional / multiparameter Cramér–Rao bound

    `cramer_rao_directional` is the genuinely multiparameter information bound: it
    couples an arbitrary statistic `f` with an arbitrary tangent direction `w` and
    recovers the catalog's scalar `cramer_rao` as the `d = 1`, `w ≡ 1` case. -/

/-- The score contracted against a tangent direction `w`, i.e. the directional
    score `w·score = ∑_b w_b ∂_b log p`. -/
def dirScore (M : GenStatModel S d) (θ w : Fin d → ℝ) (x : S) : ℝ :=
  ∑ b, w b * M.score θ x b

-- !-- E_θ of the directional score is `∑_b w_b · E_θ[score_b] = 0` by
--     `score_mean_zero` (linearity of expectation over the sum on `b`). -- !--
theorem expect_dirScore_zero (M : GenStatModel S d) (θ w : Fin d → ℝ) :
    expect M θ (dirScore M θ w) = 0 := by
  unfold FisherCramerRao.expect dirScore
  simp +decide only [mul_sum, mul_left_comm]
  exact Finset.sum_comm.trans
    (by simp +decide [← Finset.mul_sum _ _ _, ← Finset.sum_mul, M.score_mean_zero])

-- !-- The expectation of the squared directional score is the Fisher quadratic
--     form `wᵀ G w`; this is exactly `FisherCramerRao.gfisher_quadForm_eq`. -- !--
theorem expect_dirScore_sq (M : GenStatModel S d) (θ w : Fin d → ℝ) :
    expect M θ (fun x => dirScore M θ w x ^ 2)
      = ∑ a, ∑ b, w a * gfisher M θ a b * w b := by
  convert FisherCramerRao.gfisher_quadForm_eq M θ w |> Eq.symm using 1

/-- **Directional / multiparameter Cramér–Rao bound.**  For any statistic
    `f : S → ℝ` and any tangent direction `w`,
        `(E_θ[f · (w·score)])² ≤ Var_θ(f) · (wᵀ G w)`.
    The right factor is the Fisher quadratic form in direction `w`; the bound says
    the (squared) covariance of any statistic with any directional score is
    controlled by the statistic's variance times the Fisher information in that
    direction.  This is the full multiparameter Cramér–Rao inequality. -/
-- !-- Apply the weighted Cauchy–Schwarz `expect_mul_sq_le` to `a := f − E[f]` and
--     `b := w·score`.  Then `E[a·b] = E[f·b]` since `E[b] = 0`
--     (`expect_dirScore_zero`); `E[a²] = Var f`; and `E[b²] = wᵀ G w`
--     (`expect_dirScore_sq`). -- !--
theorem cramer_rao_directional (M : GenStatModel S d) (θ : Fin d → ℝ)
    (f : S → ℝ) (w : Fin d → ℝ) :
    (expect M θ (fun x => f x * dirScore M θ w x)) ^ 2
      ≤ variance M θ f * (∑ a, ∑ b, w a * gfisher M θ a b * w b) := by
  convert FisherCramerRao.expect_mul_sq_le M θ (fun x => f x - expect M θ f)
    (fun x => dirScore M θ w x) using 1
  · simp +decide [sub_mul, FisherCramerRao.expect]
    simp +decide [mul_sub, ← Finset.sum_mul _ _ _, M.p_sum]
    simp +decide only [mul_comm, mul_left_comm]
    simp +decide [← mul_assoc, ← Finset.sum_mul _ _ _, expect_dirScore_zero]
    simp +decide [← Finset.mul_sum _ _ _, ← Finset.sum_mul, mul_comm,
      mul_left_comm, dirScore]
    have h_sum_zero : ∑ x, M.p θ x * ∑ b, w b * M.score θ x b
        = ∑ b, w b * ∑ x, M.p θ x * M.score θ x b := by
      simpa only [mul_assoc, mul_left_comm, Finset.mul_sum _ _ _] using Finset.sum_comm
    simp_all +decide [GenStatModel.score_mean_zero]
  · exact congr_arg₂ _ rfl (expect_dirScore_sq M θ w ▸ rfl)

-- !-- Specialize `cramer_rao_directional` to `d = 1`, `w ≡ 1`: then
--     `dirScore = score₀`, the Fisher quad form collapses to `gfisher 0 0`, and
--     `hreg` identifies the covariance with `psiPrime`. -- !--
/-- The catalog's scalar `FisherCramerRao.cramer_rao` is the `d = 1`, `w ≡ 1`
    specialization of `cramer_rao_directional`. -/
theorem cramer_rao_of_directional (M : GenStatModel S 1) (θ : Fin 1 → ℝ) (T : S → ℝ)
    (psiPrime : ℝ)
    (hreg : expect M θ (fun x => T x * M.score θ x 0) = psiPrime) :
    psiPrime ^ 2 ≤ variance M θ T * gfisher M θ 0 0 := by
  have h := cramer_rao_directional M θ T (fun _ => 1)
  simp only [dirScore, Fin.sum_univ_one, one_mul] at h
  rw [hreg] at h
  simpa using h

/-! ## II. Chentsov monotonicity: the data-processing inequality for Fisher

    Coarse-graining the sample space by `T : S → S'` can only lose information.
    The proof is a fibrewise Cauchy–Schwarz: over the fiber `T⁻¹(y)`,
    `(∑ p·s)² ≤ (∑ p)·(∑ p·s²)`, i.e. `(E[s | T=y])² ≤ E[s² | T=y]`. -/

/-- The fiber mass at `y`: `q(y) = ∑_{x : T x = y} p(x)` (the pushforward
    probability of the outcome `y` under the statistic `T`). -/
def fiberMass (M : GenStatModel S d) (θ : Fin d → ℝ) (T : S → S') (y : S') : ℝ :=
  ∑ x, if T x = y then M.p θ x else 0

/-- The conditional-expectation score of the coarse model:
    `s̄_i(y) = (∑_{T x = y} p(x) score_i(x)) / q(y) = E_θ[score_i | T = y]`. -/
def coarseScore (M : GenStatModel S d) (θ : Fin d → ℝ) (T : S → S')
    (y : S') (i : Fin d) : ℝ :=
  (∑ x, if T x = y then M.p θ x * M.score θ x i else 0) / fiberMass M θ T y

-- !-- Partition of the sample space by the fibers of `T`: swapping the two sums,
--     the inner `∑_y (if T x = y then f x else 0)` picks out `y = T x`. -- !--
theorem sum_fiberwise (T : S → S') (f : S → ℝ) :
    (∑ y, ∑ x, if T x = y then f x else 0) = ∑ x, f x := by
  rw [← Finset.sum_comm]; aesop

-- !-- Weighted Cauchy–Schwarz over the fiber with nonnegative weights
--     `a x = if T x = y then p x else 0`, via `Finset.sum_mul_sq_le_sq_mul_sq`
--     applied to `√a` and `√a·s` and simplified with `Real.sq_sqrt`. -- !--
omit [Fintype S'] in
theorem fiber_cauchy_schwarz (M : GenStatModel S d) (θ : Fin d → ℝ)
    (T : S → S') (s : S → ℝ) (y : S') :
    (∑ x, (if T x = y then M.p θ x else 0) * s x) ^ 2
      ≤ (fiberMass M θ T y)
        * (∑ x, (if T x = y then M.p θ x else 0) * s x ^ 2) := by
  convert Finset.sum_mul_sq_le_sq_mul_sq (Finset.univ : Finset S)
    (fun x => if T x = y then Real.sqrt (M.p θ x) else 0)
    (fun x => if T x = y then Real.sqrt (M.p θ x) * s x else 0) using 1
  · congr! 2
    split_ifs <;>
      simp +decide [*, mul_comm, mul_left_comm,
        Real.mul_self_sqrt (le_of_lt (M.p_pos θ _))]
  · congr! 1
    · exact Finset.sum_congr rfl fun _ _ => by
        split_ifs <;> simp +decide [*, Real.sq_sqrt (le_of_lt (M.p_pos _ _))]
    · exact Finset.sum_congr rfl fun x _ => by
        split_ifs <;> simp +decide [*, mul_pow, Real.sq_sqrt (le_of_lt (M.p_pos θ x))]

/-- **Chentsov monotonicity (explicit quadratic-form version).**  For any
    coarse-graining map `T : S → S'` and any weighted-score function `s`, the
    coarse-grained Fisher quadratic form (built from the conditional-expectation
    score `s̄(y) = (∑_{T x = y} p·s) / q(y)`) is bounded by the fine one:
        `∑_y q(y) · s̄(y)² ≤ ∑_x p(x) · s(x)²`.
    The left side is `Q^{T_*M}`, the right side is `Q^{M}`; the gap is the
    information destroyed by the (lossy) statistic `T`. -/
-- !-- Fibrewise, `q(y)·s̄(y)² = (∑ p·s)²/q(y) ≤ ∑ p·s²` by `fiber_cauchy_schwarz`
--     (with the degenerate case `q(y) = 0` handled since then the term vanishes).
--     Summing over `y` and applying `sum_fiberwise` to `x ↦ p x · s x²` gives the
--     fine quadratic form on the right. -- !--
theorem fisher_monotone_coarsegrain (M : GenStatModel S d) (θ : Fin d → ℝ)
    (T : S → S') (s : S → ℝ) :
    (∑ y, fiberMass M θ T y
        * ((∑ x, if T x = y then M.p θ x * s x else 0) / fiberMass M θ T y) ^ 2)
      ≤ ∑ x, M.p θ x * s x ^ 2 := by
  have h_bound : ∀ y, fiberMass M θ T y
      * ((∑ x, if T x = y then M.p θ x * s x else 0) / fiberMass M θ T y) ^ 2
      ≤ ∑ x, (if T x = y then M.p θ x else 0) * s x ^ 2 := by
    intro y
    by_cases h : fiberMass M θ T y = 0
    · simp [h]
      exact Finset.sum_nonneg fun x _ => by split_ifs <;> nlinarith [M.p_pos θ x]
    · convert div_le_iff₀' (lt_of_le_of_ne
        (show 0 ≤ fiberMass M θ T y from Finset.sum_nonneg fun _ _ => by
          split_ifs <;> linarith [M.p_pos θ ‹_›]) (Ne.symm h)) |>.2
        (fiber_cauchy_schwarz M θ T s y) using 1
      grind
  convert Finset.sum_le_sum fun y _ => h_bound y using 1
  rw [← Finset.sum_comm]; simp +decide

/-! ### Packaging the coarse model as a `GenStatModel`

    Under surjectivity of `T` every fiber is nonempty, so `q(y) > 0` and the
    conditional-expectation score is well defined; the coarse model `pushModel` is
    then a genuine statistical model and `gfisher_pushModel_le` is a Loewner
    inequality between Fisher metric tensors. -/

-- !-- Surjectivity gives `x₀` with `T x₀ = y`; that term contributes `p x₀ > 0`,
--     all others `≥ 0`, so the fiber mass is positive (`Finset.single_le_sum`). -- !--
omit [Fintype S'] in
theorem fiberMass_pos (M : GenStatModel S d) (θ : Fin d → ℝ)
    {T : S → S'} (hT : Function.Surjective T) (y : S') :
    0 < fiberMass M θ T y := by
  obtain ⟨x, hx⟩ := hT y
  refine lt_of_lt_of_le ?_ (Finset.single_le_sum (fun a _ => ?_) (Finset.mem_univ x))
  · rw [if_pos hx]; exact M.p_pos θ x
  · split_ifs <;> [exact le_of_lt (M.p_pos θ a); exact le_rfl]

-- !-- `∑_y q(y) = ∑_y ∑_x (if T x = y then p x else 0) = ∑_x p x = 1` by
--     `sum_fiberwise` and `p_sum`. -- !--
theorem pushModel_p_sum (M : GenStatModel S d) (T : S → S') (θ : Fin d → ℝ) :
    (∑ y, fiberMass M θ T y) = 1 := by
  convert M.p_sum θ using 1
  convert sum_fiberwise T (fun x => M.p θ x) using 1

-- !-- `q(y) ≠ 0` (`fiberMass_pos`) lets us cancel `q(y) · (num/q(y)) = num`, so
--     `∑_y q(y) · s̄_i(y) = ∑_x p · score_i = 0` by `sum_fiberwise` and
--     `score_mean_zero`. -- !--
theorem pushModel_score_mean_zero (M : GenStatModel S d)
    {T : S → S'} (hT : Function.Surjective T) (θ : Fin d → ℝ) (i : Fin d) :
    (∑ y, fiberMass M θ T y * coarseScore M θ T y i) = 0 := by
  unfold coarseScore
  rw [Finset.sum_congr rfl fun y _ => by
    rw [mul_comm, div_mul_cancel₀ _ (by linarith [fiberMass_pos M θ hT y])]]
  rw [Finset.sum_comm]; simp +decide [M.score_mean_zero]

/-- The **pushforward / coarse-grained model** `T_*M` on `S'` along a surjective
    statistic `T`.  The probabilities are the fiber masses and the score is the
    conditional expectation of the original score given `T`. -/
def pushModel (M : GenStatModel S d) {T : S → S'} (hT : Function.Surjective T) :
    GenStatModel S' d where
  p := fun θ y => fiberMass M θ T y
  p_pos := fun θ y => fiberMass_pos M θ hT y
  p_sum := fun θ => pushModel_p_sum M T θ
  score := fun θ y i => coarseScore M θ T y i
  score_mean_zero := fun θ i => pushModel_score_mean_zero M hT θ i

/-- **Chentsov monotonicity (Fisher-tensor / Loewner version).**  For a surjective
    statistic `T`, the Fisher metric of the coarse-grained model `T_*M` is
    dominated by that of `M` in the Loewner order: for every direction `v`,
        `vᵀ G(T_*M) v ≤ vᵀ G(M) v`.
    This is the precise sense in which the Fisher metric is *monotone under
    statistical maps* — the geometric data-processing inequality underlying
    Chentsov's uniqueness theorem. -/
-- !-- `gfisher_quadForm_eq` rewrites both quadratic forms as `∑ p·(directional
--     score)²`.  For `pushModel` the directional score at `y` is
--     `(∑_{T x = y} p·(v·score))/q(y)`, so with `s := v·score` the goal becomes
--     `fisher_monotone_coarsegrain`. -- !--
theorem gfisher_pushModel_le (M : GenStatModel S d)
    {T : S → S'} (hT : Function.Surjective T) (θ v : Fin d → ℝ) :
    (∑ a, ∑ b, v a * gfisher (pushModel M hT) θ a b * v b)
      ≤ ∑ a, ∑ b, v a * gfisher M θ a b * v b := by
  convert fisher_monotone_coarsegrain M θ T (fun x => ∑ i, v i * M.score θ x i) using 1
  · rw [gfisher_quadForm_eq]
    simp +decide only [pushModel]
    simp +decide [coarseScore, Finset.sum_ite]
    simp +decide only [sum_div, Finset.mul_sum _ _ _, mul_div_assoc', mul_left_comm]
    exact Finset.sum_congr rfl fun _ _ => by rw [Finset.sum_comm]
  · convert gfisher_quadForm_eq M θ v using 1

/-! ## III. Corollary: scalar monotonicity of Fisher information -/

-- !-- Apply `gfisher_pushModel_le` with `d = 1` and `v ≡ 1`; both double sums
--     collapse to the single `(0,0)` entry. -- !--
/-- **Scalar data-processing inequality.**  For a single parameter, passing data
    through any surjective statistic `T` cannot increase the Fisher information:
    `G(T_*M)(θ) ≤ G(M)(θ)`. -/
theorem gfisher_pushModel_le_scalar (M : GenStatModel S 1)
    {T : S → S'} (hT : Function.Surjective T) (θ : Fin 1 → ℝ) :
    gfisher (pushModel M hT) θ 0 0 ≤ gfisher M θ 0 0 := by
  convert gfisher_pushModel_le M hT θ (fun _ => 1) using 1 <;> simp +decide

end FisherMonotonicity