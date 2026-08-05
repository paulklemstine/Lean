import Mathlib
import Bridges.InformationGeometry.FisherMetric
import Computation.InformationGeometry.FisherInnerProduct

/-!
# Cramér–Rao as Cauchy–Schwarz in the Fisher inner product space, and the
equality case of the `L¹` bound

This file continues `Computation/InformationGeometry/FisherInnerProduct.lean`,
where the finite Fisher form `fisherForm p v w = ∑ i, v i * w i / p i` was
packaged as a genuine `InnerProductSpace ℝ (FisherTangent p)` on the zero-sum
tangent hyperplane of the open probability simplex.

Two open questions recorded in `FUTURE_DIRECTIONS.md` are settled here.

## Main results

* `InformationGeometry.l1_sq_eq_fisherForm_iff` — the **equality case** of the
  Cauchy–Schwarz bound `(∑ i, |v i|)² ≤ fisherForm p v v`: equality holds if and
  only if `i ↦ |v i| / p i` is constant.  Specialised to displacements this is
  `InformationGeometry.l1_sq_eq_chiSquared_iff`, the equality case of
  `‖p − q‖₁² ≤ χ²(p ‖ q)`.

* `InformationGeometry.estimatorTangent` — the tangent vector
  `i ↦ p i * (T i − E_p T)` attached to an observable `T`.  Its Fisher square
  length is the variance (`fisherForm_estimatorTangent_self`) and its Fisher
  pairing with a tangent direction `v` is the derivative `∑ i, T i * v i` of the
  mean along `v` (`fisherForm_estimatorTangent_vec`).

* `InformationGeometry.cramer_rao` — consequently the **Cramér–Rao inequality**
  `(∑ i, T i * v i)² ≤ Var_p(T) * fisherForm p v v` is *literally* the
  Cauchy–Schwarz inequality of the Fisher inner product space, with no extra
  analytic input.  `cramer_rao_family` states the differential form for a
  parameterised family, `cramer_rao_unbiased` the classical `Var ≥ 1/I` shape,
  `cramer_rao_attained` the exact attainment along the score direction, and
  `cramer_rao_eq_iff` the full equality case.
-/

noncomputable section

open Finset

namespace InformationGeometry

variable {ι : Type*} [Fintype ι]

/-! ## Weighted mean and variance -/

/-- The mean of an observable `T` under the weights `p`. -/
def mean (p T : ι → ℝ) : ℝ := ∑ i, p i * T i

/-- The variance of an observable `T` under the weights `p`. -/
def variance (p T : ι → ℝ) : ℝ := ∑ i, p i * (T i - mean p T) ^ 2

theorem variance_nonneg (p T : ι → ℝ) (hp : ∀ i, 0 ≤ p i) : 0 ≤ variance p T :=
  Finset.sum_nonneg fun i _ => mul_nonneg (hp i) (sq_nonneg _)

/-- The bias-variance identity: `Var = E[T²] − (E T)²` for a probability vector. -/
theorem variance_eq_sub (p T : ι → ℝ) (hps : ∑ i, p i = 1) :
    variance p T = (∑ i, p i * T i ^ 2) - mean p T ^ 2 := by
  have hexp : ∀ i, p i * (T i - mean p T) ^ 2
      = p i * T i ^ 2 - 2 * mean p T * (p i * T i) + mean p T ^ 2 * p i := by
    intro i; ring
  rw [variance, Finset.sum_congr rfl fun i _ => hexp i]
  rw [Finset.sum_add_distrib, Finset.sum_sub_distrib, ← Finset.mul_sum, ← Finset.mul_sum, hps]
  have hm : ∑ i, p i * T i = mean p T := rfl
  rw [hm]
  ring

/-- The variance of a probability vector vanishes exactly on constants. -/
theorem variance_eq_zero_iff (p T : ι → ℝ) (hp : ∀ i, 0 < p i) :
    variance p T = 0 ↔ ∀ i, T i = mean p T := by
  rw [variance, Finset.sum_eq_zero_iff_of_nonneg
    fun i _ => mul_nonneg (hp i).le (sq_nonneg _)]
  constructor
  · intro h i
    have hi := h i (Finset.mem_univ i)
    rcases mul_eq_zero.mp hi with h0 | h0
    · exact absurd h0 (ne_of_gt (hp i))
    · have : T i - mean p T = 0 := by
        simpa using pow_eq_zero_iff (n := 2) (by norm_num) |>.mp h0
      linarith
  · intro h i _
    rw [h i]
    simp

/-- Jensen / Cauchy–Schwarz for a probability vector: `(E c)² ≤ E (c²)`. -/
theorem mean_sq_le_sq_mean (p c : ι → ℝ) (hp : ∀ i, 0 ≤ p i) (hps : ∑ i, p i = 1) :
    (∑ i, p i * c i) ^ 2 ≤ ∑ i, p i * c i ^ 2 := by
  have h := variance_nonneg p c hp
  rw [variance_eq_sub p c hps] at h
  have hm : mean p c = ∑ i, p i * c i := rfl
  rw [hm] at h
  linarith

/-- **Equality case of Jensen's inequality**: `(E c)² = E (c²)` holds for a
strictly positive probability vector exactly when `c` is constant. -/
theorem mean_sq_eq_iff (p c : ι → ℝ) (hp : ∀ i, 0 < p i) (hps : ∑ i, p i = 1) :
    (∑ i, p i * c i) ^ 2 = ∑ i, p i * c i ^ 2 ↔ ∃ k : ℝ, ∀ i, c i = k := by
  have hm : mean p c = ∑ i, p i * c i := rfl
  have hvar : variance p c = (∑ i, p i * c i ^ 2) - (∑ i, p i * c i) ^ 2 := by
    rw [variance_eq_sub p c hps, hm]
  constructor
  · intro h
    have h0 : variance p c = 0 := by rw [hvar, ← h]; ring
    exact ⟨mean p c, (variance_eq_zero_iff p c hp).mp h0⟩
  · rintro ⟨k, hk⟩
    have hmk : mean p c = k := by
      rw [mean, Finset.sum_congr rfl fun i _ => by rw [hk i], ← Finset.sum_mul, hps, one_mul]
    have h0 : variance p c = 0 := by
      rw [variance, Finset.sum_eq_zero]
      intro i _
      rw [hk i, hmk]
      simp
    rw [hvar] at h0
    linarith

/-! ## The equality case of the `L¹` Cauchy–Schwarz bound -/

/-- **Equality case of `l1_sq_le_fisherForm`.**  For a strictly positive
probability vector `p`, the squared `L¹` norm of `v` equals its squared Fisher
length exactly when the ratio `|v i| / p i` is constant in `i`. -/
theorem l1_sq_eq_fisherForm_iff (p v : ι → ℝ) (hp : ∀ i, 0 < p i) (hps : ∑ i, p i = 1) :
    (∑ i, |v i|) ^ 2 = fisherForm p v v ↔ ∃ c : ℝ, ∀ i, |v i| = c * p i := by
  have h1 : ∑ i, p i * (|v i| / p i) = ∑ i, |v i| := by
    refine Finset.sum_congr rfl fun i _ => ?_
    rw [mul_comm]
    exact div_mul_cancel₀ _ (ne_of_gt (hp i))
  have h2 : ∑ i, p i * (|v i| / p i) ^ 2 = fisherForm p v v := by
    rw [fisherForm]
    refine Finset.sum_congr rfl fun i _ => ?_
    have hne : p i ≠ 0 := ne_of_gt (hp i)
    rw [div_pow, sq_abs, sq]
    field_simp
  have key := mean_sq_eq_iff p (fun i => |v i| / p i) hp hps
  rw [h1, h2] at key
  rw [key]
  constructor
  · rintro ⟨k, hk⟩
    exact ⟨k, fun i => (div_eq_iff (ne_of_gt (hp i))).mp (hk i)⟩
  · rintro ⟨k, hk⟩
    refine ⟨k, fun i => ?_⟩
    show |v i| / p i = k
    rw [hk i]
    exact mul_div_cancel_right₀ k (ne_of_gt (hp i))

/-- **Equality case of the `χ²` bound** `‖p − q‖₁² ≤ χ²(p ‖ q)`: equality holds
exactly when `i ↦ |p i − q i| / q i` is constant. -/
theorem l1_sq_eq_chiSquared_iff (p q : ι → ℝ) (hq : ∀ i, 0 < q i) (hqs : ∑ i, q i = 1) :
    (∑ i, |p i - q i|) ^ 2 = chiSquared p q ↔ ∃ c : ℝ, ∀ i, |p i - q i| = c * q i := by
  rw [chiSquared_eq_fisher]
  simpa using l1_sq_eq_fisherForm_iff q (p - q) hq hqs

/-! ## The estimator tangent vector -/

/-- The centred observable `T`, rescaled by `p`, is a zero-sum tangent vector at
the point `p` of the open simplex.  It is the Riesz representative of the
linear functional "derivative of the mean of `T`". -/
def estimatorTangent (p : OpenSimplex ι) (T : ι → ℝ) : FisherTangent p :=
  (⟨fun i => p.prob i * (T i - mean p.prob T), by
      show ∑ i, p.prob i * (T i - mean p.prob T) = 0
      have : ∀ i, p.prob i * (T i - mean p.prob T)
          = p.prob i * T i - mean p.prob T * p.prob i := by
        intro i; ring
      rw [Finset.sum_congr rfl fun i _ => this i, Finset.sum_sub_distrib, ← Finset.mul_sum,
        p.prob_sum, mul_one, ← mean]
      ring⟩ : ↥(tangentSubmodule ι))

@[simp] theorem vec_estimatorTangent (p : OpenSimplex ι) (T : ι → ℝ) :
    (estimatorTangent p T).vec = fun i => p.prob i * (T i - mean p.prob T) := rfl

/-- The Fisher square length of the estimator tangent vector is the variance. -/
theorem fisherForm_estimatorTangent_self (p : OpenSimplex ι) (T : ι → ℝ) :
    fisherForm p.prob (estimatorTangent p T).vec (estimatorTangent p T).vec
      = variance p.prob T := by
  rw [fisherForm, variance]
  refine Finset.sum_congr rfl fun i _ => ?_
  rw [vec_estimatorTangent]
  have hne : p.prob i ≠ 0 := ne_of_gt (p.prob_pos i)
  field_simp


/-- Its Fisher pairing with a tangent direction `v` is the derivative of the mean
of `T` along `v`. -/
theorem fisherForm_estimatorTangent_vec (p : OpenSimplex ι) (T : ι → ℝ)
    (v : FisherTangent p) :
    fisherForm p.prob (estimatorTangent p T).vec v.vec = ∑ i, T i * v.vec i := by
  have hterm : ∀ i, p.prob i * (T i - mean p.prob T) * v.vec i / p.prob i
      = T i * v.vec i - mean p.prob T * v.vec i := by
    intro i
    have hne : p.prob i ≠ 0 := ne_of_gt (p.prob_pos i)
    field_simp
  rw [fisherForm, vec_estimatorTangent, Finset.sum_congr rfl fun i _ => hterm i,
    Finset.sum_sub_distrib, ← Finset.mul_sum, v.sum_vec, mul_zero, sub_zero]

/-! ## Cramér–Rao -/

/-- **The Cramér–Rao inequality for a finite categorical model**, obtained as the
Cauchy–Schwarz inequality of the Fisher inner product space applied to the
estimator tangent vector and the score direction `v`. -/
theorem cramer_rao (p : OpenSimplex ι) (T : ι → ℝ) (v : FisherTangent p) :
    (∑ i, T i * v.vec i) ^ 2 ≤ variance p.prob T * fisherForm p.prob v.vec v.vec := by
  set u := estimatorTangent p T with hu
  have hcs := abs_fisherForm_le_mul p u v
  rw [fisherForm_estimatorTangent_vec p T v, fisherForm_estimatorTangent_self p T] at hcs
  have hA : (0 : ℝ) ≤ variance p.prob T :=
    variance_nonneg _ _ fun i => (p.prob_pos i).le
  have hB : (0 : ℝ) ≤ fisherForm p.prob v.vec v.vec :=
    fisherForm_nonneg _ _ p.prob_pos
  have hsq : (∑ i, T i * v.vec i) ^ 2
      ≤ (Real.sqrt (variance p.prob T) * Real.sqrt (fisherForm p.prob v.vec v.vec)) ^ 2 := by
    rw [← sq_abs]
    exact pow_le_pow_left₀ (abs_nonneg _) hcs 2
  rwa [mul_pow, Real.sq_sqrt hA, Real.sq_sqrt hB] at hsq

/-- Differential form: if the coordinates of a parameterised family `q` are
differentiable at `0` with derivative the tangent vector `v`, then the derivative
of `s ↦ E_{q s}[T]` at `0` obeys the Cramér–Rao bound at `q 0 = p`. -/
theorem cramer_rao_family (p : OpenSimplex ι) (T : ι → ℝ) (v : FisherTangent p)
    (q : ℝ → ι → ℝ) (hq : ∀ i, HasDerivAt (fun s => q s i) (v.vec i) 0) :
    HasDerivAt (fun s => ∑ i, T i * q s i) (∑ i, T i * v.vec i) 0 ∧
      (∑ i, T i * v.vec i) ^ 2 ≤ variance p.prob T * fisherForm p.prob v.vec v.vec := by
  refine ⟨HasDerivAt.fun_sum fun i _ => ?_, cramer_rao p T v⟩
  exact (hq i).const_mul (T i)

/-- The classical shape of the bound: for an estimator whose mean has unit
derivative along the score direction `v`, the variance is at least the reciprocal
Fisher information. -/
theorem cramer_rao_unbiased (p : OpenSimplex ι) (T : ι → ℝ) (v : FisherTangent p)
    (hv : v ≠ 0) (hT : ∑ i, T i * v.vec i = 1) :
    1 / fisherForm p.prob v.vec v.vec ≤ variance p.prob T := by
  have hvne : v.vec ≠ 0 := fun h => hv (FisherTangent.vec_eq_zero_iff.mp h)
  have hI : 0 < fisherForm p.prob v.vec v.vec :=
    (fisherForm_pos_iff p.prob v.vec p.prob_pos).mpr hvne
  have h := cramer_rao p T v
  rw [hT, one_pow] at h
  rw [div_le_iff₀ hI]
  linarith [h, mul_comm (variance p.prob T) (fisherForm p.prob v.vec v.vec)]

/-- The bound is attained: along the score direction determined by `T` itself,
Cramér–Rao is an equality. -/
theorem cramer_rao_attained (p : OpenSimplex ι) (T : ι → ℝ) :
    (∑ i, T i * (estimatorTangent p T).vec i) ^ 2
      = variance p.prob T
        * fisherForm p.prob (estimatorTangent p T).vec (estimatorTangent p T).vec := by
  rw [fisherForm_estimatorTangent_self,
    ← fisherForm_estimatorTangent_vec p T (estimatorTangent p T),
    fisherForm_estimatorTangent_self]
  ring

/-- **Equality case of Cramér–Rao**: the bound is attained exactly when the
estimator tangent vector and the score direction are parallel. -/
theorem cramer_rao_eq_iff (p : OpenSimplex ι) (T : ι → ℝ) (v : FisherTangent p)
    (hv : v ≠ 0) :
    (∑ i, T i * v.vec i) ^ 2 = variance p.prob T * fisherForm p.prob v.vec v.vec ↔
      ∃ c : ℝ, ∀ i, p.prob i * (T i - mean p.prob T) = c * v.vec i := by
  set u := estimatorTangent p T with hu
  have hpair : fisherForm p.prob u.vec v.vec = ∑ i, T i * v.vec i :=
    fisherForm_estimatorTangent_vec p T v
  have hself : fisherForm p.prob u.vec u.vec = variance p.prob T :=
    fisherForm_estimatorTangent_self p T
  have hinner : (inner ℝ u v : ℝ) = ∑ i, T i * v.vec i := by
    rw [inner_fisherTangent, hpair]
  have hnu : ‖u‖ ^ 2 = variance p.prob T := by
    rw [norm_sq_fisherTangent, hself]
  have hnv : ‖v‖ ^ 2 = fisherForm p.prob v.vec v.vec := norm_sq_fisherTangent p v
  have hvnorm : (0 : ℝ) < ‖v‖ := norm_pos_iff.mpr hv
  constructor
  · intro heq
    have hsq : (inner ℝ u v : ℝ) ^ 2 = (‖u‖ * ‖v‖) ^ 2 := by
      rw [hinner, mul_pow, hnu, hnv]; exact heq
    have habs : |(inner ℝ u v : ℝ)| = ‖u‖ * ‖v‖ := by
      have h2 : |(inner ℝ u v : ℝ)| ^ 2 = (‖u‖ * ‖v‖) ^ 2 := by rw [sq_abs]; exact hsq
      have h3 := congrArg Real.sqrt h2
      rwa [Real.sqrt_sq (abs_nonneg _), Real.sqrt_sq (by positivity)] at h3
    obtain ⟨c, hcv⟩ : ∃ c : ℝ, u = c • v := by
      rcases (abs_eq (by positivity : (0 : ℝ) ≤ ‖u‖ * ‖v‖)).mp habs with h | h
      · have hpar : ‖v‖ • u = ‖u‖ • v := inner_eq_norm_mul_iff_real.mp h
        refine ⟨‖u‖ / ‖v‖, ?_⟩
        rw [div_eq_inv_mul, mul_smul, ← hpar, inv_smul_smul₀ (ne_of_gt hvnorm)]
      · have h2 : (inner ℝ (-u) v : ℝ) = ‖-u‖ * ‖v‖ := by
          rw [inner_neg_left, norm_neg, h]
          simp
        have hpar : ‖v‖ • (-u) = ‖-u‖ • v := inner_eq_norm_mul_iff_real.mp h2
        refine ⟨-(‖u‖ / ‖v‖), ?_⟩
        have hu' : -u = (‖-u‖ / ‖v‖) • v := by
          rw [div_eq_inv_mul, mul_smul, ← hpar, inv_smul_smul₀ (ne_of_gt hvnorm)]
        rw [norm_neg] at hu'
        rw [neg_smul, ← hu', neg_neg]
    refine ⟨c, fun i => ?_⟩
    have hvecs : u.vec = c • v.vec := by rw [hcv]; rfl
    have := congrFun hvecs i
    simpa [hu] using this
  · rintro ⟨c, hc⟩
    have hvecs : u.vec = c • v.vec := by
      funext i
      simpa [hu] using hc i
    have h1 : ∑ i, T i * v.vec i = c * fisherForm p.prob v.vec v.vec := by
      rw [← hpair, hvecs, fisherForm_smul_left]
    have h2 : variance p.prob T = c ^ 2 * fisherForm p.prob v.vec v.vec := by
      rw [← hself, hvecs, fisherForm_smul_left, fisherForm_symm, fisherForm_smul_left,
        fisherForm_symm]
      ring
    rw [h1, h2]
    ring

end InformationGeometry

end