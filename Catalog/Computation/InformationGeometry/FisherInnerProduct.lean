import Mathlib
import Bridges.InformationGeometry.FisherMetric
import Speculative.AutoResearch.PinskerInequality

/-!
# The Fisher form as a genuine inner product, and as the Hessian of KL divergence

This file continues the development of `Bridges/InformationGeometry/FisherMetric.lean`,
which introduced the finite Fisher information form

`fisherForm p v w = ∑ i, v i * w i / p i`

on a finite categorical model, together with the Kullback--Leibler divergence
`klDiv` and Pearson's `chiSquared`.  There the Riemannian axioms were verified as
plain propositions.  Here we go two steps further.

## Main results

* `InformationGeometry.FisherTangent` — the tangent hyperplane
  `{v : ι → ℝ | ∑ i, v i = 0}` of the open probability simplex at a point `p`,
  carried by a type synonym so that it can be equipped with a *point dependent*
  inner product.  It is given `Inner`, `NormedAddCommGroup` and
  `InnerProductSpace ℝ` instances whose inner product is exactly `fisherForm p`.

* `InformationGeometry.l1_sq_le_fisherForm`, `InformationGeometry.l1_sq_le_chiSquared`
  — Cauchy--Schwarz in the Fisher geometry.

* `InformationGeometry.klDiv_hessian_diagonal` — the second derivative of
  `s ↦ KL(p + s·v ‖ p)` at `s = 0` equals `fisherForm p v v`.

* `InformationGeometry.klDiv_hessian_bilinear` — the mixed version, returning
  `fisherForm p v w`.
-/

noncomputable section

open Finset

namespace InformationGeometry

variable {ι : Type*} [Fintype ι]

/-! ## The tangent hyperplane of the open simplex -/

/-- The tangent hyperplane to the probability simplex: zero-sum vectors. -/
def tangentSubmodule (ι : Type*) [Fintype ι] : Submodule ℝ (ι → ℝ) where
  carrier := {v | ∑ i, v i = 0}
  add_mem' := by
    intro a b ha hb
    simp only [Set.mem_setOf_eq] at ha hb ⊢
    simp [Pi.add_apply, Finset.sum_add_distrib, ha, hb]
  zero_mem' := by simp
  smul_mem' := by
    intro c a ha
    simp only [Set.mem_setOf_eq] at ha ⊢
    simp [Pi.smul_apply, smul_eq_mul, ← Finset.mul_sum, ha]

/-- A point of the open probability simplex on a finite type. -/
structure OpenSimplex (ι : Type*) [Fintype ι] where
  /-- The underlying probability vector. -/
  prob : ι → ℝ
  /-- Every coordinate is strictly positive. -/
  prob_pos : ∀ i, 0 < prob i
  /-- The coordinates sum to one. -/
  prob_sum : ∑ i, prob i = 1

/-- Tangent vectors at a point `p` of the open simplex.  This is a type synonym
for the zero-sum hyperplane; the point `p` is recorded in the type so that the
Fisher inner product at `p` can be installed as an instance. -/
def FisherTangent {ι : Type*} [Fintype ι] (_p : OpenSimplex ι) : Type _ :=
  ↥(tangentSubmodule ι)

namespace FisherTangent

variable {p : OpenSimplex ι}

instance : AddCommGroup (FisherTangent p) :=
  inferInstanceAs (AddCommGroup ↥(tangentSubmodule ι))

instance : Module ℝ (FisherTangent p) :=
  inferInstanceAs (Module ℝ ↥(tangentSubmodule ι))

/-- The underlying zero-sum vector of a tangent vector. -/
def vec (v : FisherTangent p) : ι → ℝ := Subtype.val v

@[simp] theorem sum_vec (v : FisherTangent p) : ∑ i, v.vec i = 0 := v.2

theorem vec_injective : Function.Injective (vec : FisherTangent p → ι → ℝ) :=
  fun _ _ h => Subtype.ext h

@[ext] theorem ext {v w : FisherTangent p} (h : v.vec = w.vec) : v = w :=
  vec_injective h

@[simp] theorem vec_add (v w : FisherTangent p) : (v + w).vec = v.vec + w.vec := rfl

@[simp] theorem vec_smul (c : ℝ) (v : FisherTangent p) : (c • v).vec = c • v.vec := rfl

@[simp] theorem vec_zero : (0 : FisherTangent p).vec = 0 := rfl

@[simp] theorem vec_eq_zero_iff {v : FisherTangent p} : v.vec = 0 ↔ v = 0 := by
  constructor
  · intro h; exact ext (by simpa using h)
  · rintro rfl; rfl

end FisherTangent

/-! ## The Fisher inner product -/

instance fisherInner (p : OpenSimplex ι) : Inner ℝ (FisherTangent p) :=
  ⟨fun v w => fisherForm p.prob v.vec w.vec⟩

@[simp] theorem inner_fisherTangent (p : OpenSimplex ι) (v w : FisherTangent p) :
    inner ℝ v w = fisherForm p.prob v.vec w.vec := rfl

instance fisherCore (p : OpenSimplex ι) : InnerProductSpace.Core ℝ (FisherTangent p) where
  conj_inner_symm v w := by
    simp only [inner_fisherTangent, starRingEnd_apply, star_trivial]
    exact fisherForm_symm _ _ _
  re_inner_nonneg v := by
    simpa using fisherForm_nonneg p.prob v.vec p.prob_pos
  add_left v w u := by
    simp only [inner_fisherTangent, FisherTangent.vec_add]
    exact fisherForm_add_left _ _ _ _
  smul_left v w c := by
    simp only [inner_fisherTangent, FisherTangent.vec_smul, starRingEnd_apply, star_trivial]
    exact fisherForm_smul_left _ _ _ _
  definite v h := by
    have hv : v.vec = 0 := (fisherForm_eq_zero_iff p.prob v.vec p.prob_pos).mp h
    exact FisherTangent.vec_eq_zero_iff.mp hv

instance fisherNormedAddCommGroup (p : OpenSimplex ι) :
    NormedAddCommGroup (FisherTangent p) :=
  InnerProductSpace.Core.toNormedAddCommGroup (𝕜 := ℝ)

/-- The norm of the Fisher inner product space is the Fisher length. -/
theorem norm_fisherTangent (p : OpenSimplex ι) (v : FisherTangent p) :
    ‖v‖ = Real.sqrt (fisherForm p.prob v.vec v.vec) := rfl

theorem norm_sq_fisherTangent (p : OpenSimplex ι) (v : FisherTangent p) :
    ‖v‖ ^ 2 = fisherForm p.prob v.vec v.vec := by
  rw [norm_fisherTangent, Real.sq_sqrt (fisherForm_nonneg _ _ p.prob_pos)]

instance fisherInnerProductSpace (p : OpenSimplex ι) :
    InnerProductSpace ℝ (FisherTangent p) where
  norm_smul_le c v := by
    rw [norm_fisherTangent, norm_fisherTangent, FisherTangent.vec_smul,
      fisherForm_smul_left, fisherForm_symm, fisherForm_smul_left, fisherForm_symm]
    rw [show c * (c * fisherForm p.prob v.vec v.vec)
        = c ^ 2 * fisherForm p.prob v.vec v.vec by ring,
      Real.sqrt_mul (by positivity), Real.sqrt_sq_eq_abs]
    simp [Real.norm_eq_abs]
  norm_sq_eq_re_inner v := by
    simpa using norm_sq_fisherTangent p v
  conj_inner_symm v w := (fisherCore p).conj_inner_symm v w
  add_left v w u := (fisherCore p).add_left v w u
  smul_left v w c := (fisherCore p).smul_left v w c

/-! ## Cauchy--Schwarz: the `L¹` bound -/

/-- Cauchy--Schwarz in the Fisher geometry: for a probability vector `p`, the
squared `L¹`-norm of `v` is bounded by its squared Fisher length. -/
theorem l1_sq_le_fisherForm (p v : ι → ℝ) (hp : ∀ i, 0 < p i) (hps : ∑ i, p i = 1) :
    (∑ i, |v i|) ^ 2 ≤ fisherForm p v v := by
  have key := Finset.sum_mul_sq_le_sq_mul_sq (univ : Finset ι)
    (fun i => |v i| / Real.sqrt (p i)) (fun i => Real.sqrt (p i))
  have h1 : ∑ i, |v i| / Real.sqrt (p i) * Real.sqrt (p i) = ∑ i, |v i| := by
    refine Finset.sum_congr rfl fun i _ => ?_
    have : Real.sqrt (p i) ≠ 0 := ne_of_gt (Real.sqrt_pos.mpr (hp i))
    field_simp
  have h2 : ∑ i, (|v i| / Real.sqrt (p i)) ^ 2 = fisherForm p v v := by
    rw [fisherForm]
    refine Finset.sum_congr rfl fun i _ => ?_
    rw [div_pow, Real.sq_sqrt (hp i).le, sq_abs, sq]
  have h3 : ∑ i, Real.sqrt (p i) ^ 2 = 1 := by
    rw [← hps]
    exact Finset.sum_congr rfl fun i _ => Real.sq_sqrt (hp i).le
  simp only [h1, h2, h3, mul_one] at key
  exact key

/-- Total-variation versus chi-squared: the squared `L¹` distance between two
probability vectors is bounded by Pearson's divergence. -/
theorem l1_sq_le_chiSquared (p q : ι → ℝ) (hq : ∀ i, 0 < q i) (hqs : ∑ i, q i = 1) :
    (∑ i, |p i - q i|) ^ 2 ≤ chiSquared p q := by
  rw [chiSquared_eq_fisher]
  simpa using l1_sq_le_fisherForm q (p - q) hq hqs


/-! ## Consequences of the inner-product packaging -/

/-- **Cauchy--Schwarz for the Fisher form**, obtained for free from the
`InnerProductSpace` instance on the tangent hyperplane. -/
theorem abs_fisherForm_le_mul (p : OpenSimplex ι) (v w : FisherTangent p) :
    |fisherForm p.prob v.vec w.vec| ≤
      Real.sqrt (fisherForm p.prob v.vec v.vec) *
        Real.sqrt (fisherForm p.prob w.vec w.vec) := by
  have h := abs_real_inner_le_norm v w
  rwa [inner_fisherTangent, norm_fisherTangent, norm_fisherTangent] at h

/-- The parallelogram law for the Fisher form, again inherited from the
`InnerProductSpace` instance. -/
theorem fisherForm_parallelogram (p : OpenSimplex ι) (v w : FisherTangent p) :
    fisherForm p.prob (v + w).vec (v + w).vec
        + fisherForm p.prob (v - w).vec (v - w).vec
      = 2 * fisherForm p.prob v.vec v.vec + 2 * fisherForm p.prob w.vec w.vec := by
  have h := norm_add_sq_real v w
  have h' := norm_sub_sq_real v w
  have e1 := norm_sq_fisherTangent p (v + w)
  have e2 := norm_sq_fisherTangent p (v - w)
  have e3 := norm_sq_fisherTangent p v
  have e4 := norm_sq_fisherTangent p w
  linarith [h, h', e1, e2, e3, e4]

/-! ## A sharpened divergence sandwich

Combining Pinsker's inequality (`PinskerInequality.general_pinsker`), the Fisher
upper bound `klDiv ≤ χ²` from `Bridges.InformationGeometry.FisherMetric`, and the
Cauchy--Schwarz bound `l1_sq_le_chiSquared` proved above, we obtain a three-term
chain.  Note that Pinsker plus `KL ≤ χ²` only yields `‖p - q‖₁² ≤ 2 χ²`, whereas
Cauchy--Schwarz gives the constant `1`, which is optimal (see
`l1_sq_eq_chiSquared_two_point`). -/

/-- The two `klDiv` definitions in the catalog agree. -/
theorem klDiv_eq_pinskerKlDiv (p q : ι → ℝ) :
    klDiv p q = PinskerInequality.klDiv p q := rfl

/-- Pinsker's inequality, transported to the `InformationGeometry.klDiv` of the
Fisher metric development. -/
theorem half_l1_sq_le_klDiv (p q : ι → ℝ) (hp : ∀ i, 0 < p i) (hq : ∀ i, 0 < q i)
    (hps : ∑ i, p i = 1) (hqs : ∑ i, q i = 1) :
    (1 / 2) * (∑ i, |p i - q i|) ^ 2 ≤ klDiv p q :=
  PinskerInequality.general_pinsker p q hp hq hps hqs

/-- **The sharpened divergence sandwich.**  For strictly positive probability
vectors the `L¹` distance, the relative entropy and Pearson's `χ²` divergence
(equivalently, the squared Fisher displacement) satisfy

`½‖p-q‖₁² ≤ KL(p‖q) ≤ χ²(p‖q)` and, more sharply, `‖p-q‖₁² ≤ χ²(p‖q)`. -/
theorem divergence_sandwich (p q : ι → ℝ) (hp : ∀ i, 0 < p i) (hq : ∀ i, 0 < q i)
    (hps : ∑ i, p i = 1) (hqs : ∑ i, q i = 1) :
    (1 / 2) * (∑ i, |p i - q i|) ^ 2 ≤ klDiv p q ∧
      klDiv p q ≤ fisherForm q (p - q) (p - q) ∧
      (∑ i, |p i - q i|) ^ 2 ≤ fisherForm q (p - q) (p - q) :=
  ⟨half_l1_sq_le_klDiv p q hp hq hps hqs,
    klDiv_le_fisher p q hp hq hps hqs,
    (chiSquared_eq_fisher p q) ▸ l1_sq_le_chiSquared p q hq hqs⟩

/-! ### Sharpness of the Cauchy--Schwarz constant -/

/-- A symmetric two-point perturbation of the uniform distribution on `Fin 2`. -/
def twoPoint (e : ℝ) : Fin 2 → ℝ := ![1 / 2 + e, 1 / 2 - e]

/-- The uniform distribution on `Fin 2`. -/
def uniformTwo : Fin 2 → ℝ := ![1 / 2, 1 / 2]

/-- The constant `1` in `l1_sq_le_chiSquared` cannot be improved: for the
symmetric two-point family the inequality is an equality. -/
theorem l1_sq_eq_chiSquared_two_point (e : ℝ) :
    (∑ i : Fin 2, |twoPoint e i - uniformTwo i|) ^ 2
      = chiSquared (twoPoint e) uniformTwo := by
  have h1 : (1 : ℝ) / 2 + e - 1 / 2 = e := by ring
  have h2 : (1 : ℝ) / 2 - e - 1 / 2 = -e := by ring
  simp only [chiSquared, Fin.sum_univ_two, twoPoint, uniformTwo, Matrix.cons_val_zero,
    Matrix.cons_val_one, h1, h2, abs_neg]
  rw [show |e| + |e| = 2 * |e| by ring, mul_pow, sq_abs]
  ring

/-! ## The Fisher form as the Hessian of KL divergence -/

/-- The perturbed probability vector `p + s·v`. -/
def line (p v : ι → ℝ) (s : ℝ) : ι → ℝ := fun i => p i + s * v i

omit [Fintype ι] in
@[simp] theorem line_zero (p v : ι → ℝ) : line p v 0 = p := by
  funext i; simp [line]

/-- The basic building block: the derivative of `s ↦ log ((p i + s v i)/p i)`. -/
theorem hasDerivAt_logRatio (a b : ℝ) (t : ℝ) (ha : 0 < a) (hab : 0 < a + t * b) :
    HasDerivAt (fun s : ℝ => Real.log ((a + s * b) / a)) (b / (a + t * b)) t := by
  have hu : HasDerivAt (fun s : ℝ => a + s * b) b t := by
    simpa using ((hasDerivAt_id t).mul_const b).const_add a
  have hg : HasDerivAt (fun s : ℝ => (a + s * b) / a) (b / a) t := hu.div_const a
  have hne : (a + t * b) / a ≠ 0 := ne_of_gt (div_pos hab ha)
  have hlog := hg.log hne
  have hsimp : b / a / ((a + t * b) / a) = b / (a + t * b) := by
    field_simp
  rwa [hsimp] at hlog

/-- Along a zero-sum direction, the derivative of `s ↦ KL(p + s·v ‖ p)` is the
score sum `∑ i, v i * log ((p i + s v i)/p i)`. -/
theorem hasDerivAt_klDiv_line (p v : ι → ℝ) (hv : ∑ i, v i = 0) (t : ℝ)
    (ht : ∀ i, 0 < p i + t * v i) (hp : ∀ i, 0 < p i) :
    HasDerivAt (fun s => klDiv (line p v s) p)
      (∑ i, v i * Real.log ((p i + t * v i) / p i)) t := by
  have hfun : (fun s => klDiv (line p v s) p)
      = fun s => ∑ i, (p i + s * v i) * Real.log ((p i + s * v i) / p i) := rfl
  rw [hfun]
  have hsum : ∑ i, (v i * Real.log ((p i + t * v i) / p i) + v i)
      = ∑ i, v i * Real.log ((p i + t * v i) / p i) := by
    rw [Finset.sum_add_distrib, hv, add_zero]
  rw [← hsum]
  refine HasDerivAt.fun_sum fun i _ => ?_
  have hu : HasDerivAt (fun s : ℝ => p i + s * v i) (v i) t := by
    simpa using ((hasDerivAt_id t).mul_const (v i)).const_add (p i)
  have hlog := hasDerivAt_logRatio (p i) (v i) t (hp i) (ht i)
  have hmul := hu.fun_mul hlog
  have hne : p i + t * v i ≠ 0 := ne_of_gt (ht i)
  have heq : (p i + t * v i) * (v i / (p i + t * v i)) = v i := by
    field_simp
  rw [heq] at hmul
  exact hmul

/-- The derivative of the `w`-score along the direction `v`. -/
theorem hasDerivAt_klDiv_score (p v w : ι → ℝ) (t : ℝ)
    (ht : ∀ i, 0 < p i + t * v i) (hp : ∀ i, 0 < p i) :
    HasDerivAt (fun s => ∑ i, w i * Real.log ((p i + s * v i) / p i))
      (∑ i, w i * v i / (p i + t * v i)) t := by
  refine HasDerivAt.fun_sum fun i _ => ?_
  have hlog := hasDerivAt_logRatio (p i) (v i) t (hp i) (ht i)
  have := hlog.const_mul (w i)
  rwa [mul_div_assoc'] at this

/-- The mixed second derivative of the KL divergence at the diagonal is the
Fisher bilinear form: differentiating the `w`-score along `v` at the base point
returns `fisherForm p v w`. -/
theorem klDiv_hessian_bilinear (p v w : ι → ℝ) (hp : ∀ i, 0 < p i) :
    HasDerivAt (fun s => ∑ i, w i * Real.log ((p i + s * v i) / p i))
      (fisherForm p v w) 0 := by
  have ht : ∀ i, 0 < p i + (0 : ℝ) * v i := by
    intro i; simpa using hp i
  have h := hasDerivAt_klDiv_score p v w 0 ht hp
  have hval : ∑ i, w i * v i / (p i + (0 : ℝ) * v i) = fisherForm p v w := by
    rw [fisherForm]
    refine Finset.sum_congr rfl fun i _ => ?_
    rw [zero_mul, add_zero, mul_comm (w i) (v i)]
  rwa [hval] at h

/-- Near `0` the perturbed vector stays in the open simplex. -/
theorem eventually_line_pos (p v : ι → ℝ) (hp : ∀ i, 0 < p i) :
    ∀ᶠ t in nhds (0 : ℝ), ∀ i, 0 < p i + t * v i := by
  rw [Filter.eventually_all]
  intro i
  have hcont : ContinuousAt (fun t : ℝ => p i + t * v i) 0 := by fun_prop
  have h0 : (0 : ℝ) < p i + (0 : ℝ) * v i := by simpa using hp i
  exact hcont.eventually (eventually_gt_nhds h0)

/-- **The Fisher form is the Hessian of the KL divergence on the diagonal.**
The second derivative at `s = 0` of `s ↦ KL(p + s·v ‖ p)`, taken along a
zero-sum direction `v`, is exactly the Fisher squared length of `v` at `p`. -/
theorem klDiv_hessian_diagonal (p v : ι → ℝ) (hp : ∀ i, 0 < p i) (hv : ∑ i, v i = 0) :
    deriv (deriv fun s => klDiv (line p v s) p) 0 = fisherForm p v v := by
  have hev : (deriv fun s => klDiv (line p v s) p)
      =ᶠ[nhds (0 : ℝ)] fun s => ∑ i, v i * Real.log ((p i + s * v i) / p i) := by
    filter_upwards [eventually_line_pos p v hp] with t ht
    exact (hasDerivAt_klDiv_line p v hv t ht hp).deriv
  rw [hev.deriv_eq]
  exact (klDiv_hessian_bilinear p v v hp).deriv

/-- Packaged form of the two main results at a point of the open simplex: the
Fisher inner product of the tangent space is simultaneously the norm of the
`InnerProductSpace` structure and the Hessian of relative entropy. -/
theorem fisher_norm_eq_klDiv_hessian (p : OpenSimplex ι) (v : FisherTangent p) :
    ‖v‖ ^ 2 = deriv (deriv fun s => klDiv (line p.prob v.vec s) p.prob) 0 := by
  rw [norm_sq_fisherTangent, klDiv_hessian_diagonal p.prob v.vec p.prob_pos v.sum_vec]

end InformationGeometry

end