import Mathlib

/-!
# The Fisher metric on the finite statistical manifold

We model the open probability simplex on a finite type `ι`.  At a positive
probability vector `p`, tangent vectors are functions `ι → ℝ` (the Fisher form
restricts in particular to the usual zero-sum tangent hyperplane).

The file builds a chain from the score representation of Fisher information,
through all algebraic and positivity axioms of a real inner product, to a global
information-geometric comparison

`0 ≤ KL(p ‖ q) ≤ g_q(p - q, p - q)`.

Thus the local quadratic geometry is explicitly connected to statistical
relative entropy.  No analytic limiting assumptions are needed for this finite,
strictly positive model.
-/

noncomputable section

open Finset

namespace InformationGeometry

variable {ι : Type*} [Fintype ι]

/-- The Fisher information form of a finite categorical model. -/
def fisherForm (p v w : ι → ℝ) : ℝ :=
  ∑ i, v i * w i / p i

/-- Kullback--Leibler divergence on a finite categorical model. -/
def klDiv (p q : ι → ℝ) : ℝ :=
  ∑ i, p i * Real.log (p i / q i)

/-- Pearson's chi-squared divergence. -/
def chiSquared (p q : ι → ℝ) : ℝ :=
  ∑ i, (p i - q i) ^ 2 / q i

/-- Fisher information is the expected product of directional score functions. -/
theorem fisherForm_score_representation (p v w : ι → ℝ)
    (hp : ∀ i, 0 < p i) :
    fisherForm p v w = ∑ i, p i * (v i / p i) * (w i / p i) := by
  apply Finset.sum_congr rfl
  intro i _
  field_simp [ne_of_gt (hp i)]

/-- The Fisher form is symmetric. -/
theorem fisherForm_symm (p v w : ι → ℝ) :
    fisherForm p v w = fisherForm p w v := by
  apply Finset.sum_congr rfl
  intro i _
  ring

/-- The Fisher form is additive in its first argument. -/
theorem fisherForm_add_left (p u v w : ι → ℝ) :
    fisherForm p (u + v) w = fisherForm p u w + fisherForm p v w := by
  simp only [fisherForm, Pi.add_apply, add_mul, add_div, sum_add_distrib]

/-- Symmetry and left additivity give additivity in the second argument. -/
theorem fisherForm_add_right (p u v w : ι → ℝ) :
    fisherForm p u (v + w) = fisherForm p u v + fisherForm p u w := by
  rw [fisherForm_symm, fisherForm_add_left]
  rw [fisherForm_symm p v u, fisherForm_symm p w u]

/-- The Fisher form is homogeneous in its first argument. -/
theorem fisherForm_smul_left (c : ℝ) (p v w : ι → ℝ) :
    fisherForm p (c • v) w = c * fisherForm p v w := by
  simp only [fisherForm, Pi.smul_apply, smul_eq_mul, mul_assoc, mul_div_assoc,
    Finset.mul_sum]

/-- Symmetry and left homogeneity give homogeneity in the second argument. -/
theorem fisherForm_smul_right (c : ℝ) (p v w : ι → ℝ) :
    fisherForm p v (c • w) = c * fisherForm p v w := by
  rw [fisherForm_symm, fisherForm_smul_left, fisherForm_symm p w v]

/-- At a strictly positive model, every Fisher squared length is nonnegative. -/
theorem fisherForm_nonneg (p v : ι → ℝ) (hp : ∀ i, 0 < p i) :
    0 ≤ fisherForm p v v := by
  exact Finset.sum_nonneg fun i _ =>
    div_nonneg (mul_self_nonneg _) (le_of_lt (hp i))

/-- At a strictly positive model, zero Fisher squared length forces the zero vector. -/
theorem fisherForm_eq_zero_iff (p v : ι → ℝ) (hp : ∀ i, 0 < p i) :
    fisherForm p v v = 0 ↔ v = 0 := by
  rw [fisherForm,
    Finset.sum_eq_zero_iff_of_nonneg
      fun i _ => div_nonneg (mul_self_nonneg _) (le_of_lt (hp i))]
  simp [funext_iff, ne_of_gt (hp _)]

/-- Positive definiteness in its usual strict form. -/
theorem fisherForm_pos_iff (p v : ι → ℝ) (hp : ∀ i, 0 < p i) :
    0 < fisherForm p v v ↔ v ≠ 0 := by
  constructor
  · intro h hv
    subst v
    simp [fisherForm] at h
  · intro hv
    have hne : fisherForm p v v ≠ 0 := fun h =>
      hv ((fisherForm_eq_zero_iff p v hp).mp h)
    exact lt_of_le_of_ne (fisherForm_nonneg p v hp) hne.symm

/-- The preceding chain packages exactly the symmetry, bilinearity, and positive
 definiteness axioms required of a Riemannian metric at the point `p`. -/
theorem fisher_riemannian_axioms (p : ι → ℝ) (hp : ∀ i, 0 < p i) :
    (∀ v w, fisherForm p v w = fisherForm p w v) ∧
    (∀ u v w, fisherForm p (u + v) w = fisherForm p u w + fisherForm p v w) ∧
    (∀ (c : ℝ) v w, fisherForm p (c • v) w = c * fisherForm p v w) ∧
    (∀ v, 0 ≤ fisherForm p v v) ∧
    (∀ v, fisherForm p v v = 0 ↔ v = 0) := by
  exact ⟨fisherForm_symm p, fisherForm_add_left p,
    fun c v w => fisherForm_smul_left c p v w,
    fun v => fisherForm_nonneg p v hp, fun v => fisherForm_eq_zero_iff p v hp⟩

/-- Pearson divergence is precisely Fisher squared distance at the displacement
`p - q`, based at `q`. -/
theorem chiSquared_eq_fisher (p q : ι → ℝ) :
    chiSquared p q = fisherForm q (p - q) (p - q) := by
  simp only [chiSquared, fisherForm, Pi.sub_apply, sq]

/-- Gibbs' inequality: relative entropy is nonnegative. -/
theorem klDiv_nonneg (p q : ι → ℝ) (hp : ∀ i, 0 < p i) (hq : ∀ i, 0 < q i)
    (hps : ∑ i, p i = 1) (hqs : ∑ i, q i = 1) :
    0 ≤ klDiv p q := by
  have h_sum : ∑ i, p i * (1 - q i / p i) ≤
      ∑ i, p i * Real.log (p i / q i) := by
    gcongr with i
    · exact le_of_lt (hp i)
    · have hlog := Real.log_le_sub_one_of_pos (div_pos (hq i) (hp i))
      rw [Real.log_div (ne_of_gt (hq i)) (ne_of_gt (hp i))] at hlog
      rw [Real.log_div (ne_of_gt (hp i)) (ne_of_gt (hq i))]
      linarith
  have hcancel : ∑ i, p i * (1 - q i / p i) = 0 := by
    have hterm : ∀ i, p i * (1 - q i / p i) = p i - q i := fun i => by
      field_simp [ne_of_gt (hp i)]
    simp only [hterm, Finset.sum_sub_distrib, hps, hqs, sub_self]
  rw [klDiv]
  linarith

/-- The global information-geometric bridge: KL divergence is bounded above by
Fisher squared displacement (equivalently, Pearson chi-squared divergence). -/
theorem klDiv_le_fisher (p q : ι → ℝ) (hp : ∀ i, 0 < p i) (hq : ∀ i, 0 < q i)
    (hps : ∑ i, p i = 1) (hqs : ∑ i, q i = 1) :
    klDiv p q ≤ fisherForm q (p - q) (p - q) := by
  have h_log_le : ∑ i, p i * Real.log (p i / q i) ≤
      ∑ i, p i * (p i / q i - 1) := by
    gcongr with i
    · exact le_of_lt (hp i)
    · exact Real.log_le_sub_one_of_pos (div_pos (hp i) (hq i))
  have hrhs : ∑ i, p i * (p i / q i - 1) =
      fisherForm q (p - q) (p - q) := by
    rw [← chiSquared_eq_fisher]
    have hterm : ∀ i, p i * (p i / q i - 1) =
        (p i - q i) ^ 2 / q i + (p i - q i) := fun i => by
      field_simp [ne_of_gt (hq i)]
      ring
    simp only [chiSquared, hterm, Finset.sum_add_distrib, Finset.sum_sub_distrib,
      hps, hqs, sub_self, add_zero]
  rw [klDiv]
  exact h_log_le.trans_eq hrhs

/-- The complete two-sided bridge combines Gibbs' inequality with the Fisher upper
bound.  This theorem explicitly reuses the preceding two links in the chain. -/
theorem klDiv_fisher_sandwich (p q : ι → ℝ)
    (hp : ∀ i, 0 < p i) (hq : ∀ i, 0 < q i)
    (hps : ∑ i, p i = 1) (hqs : ∑ i, q i = 1) :
    0 ≤ klDiv p q ∧ klDiv p q ≤ fisherForm q (p - q) (p - q) := by
  exact ⟨klDiv_nonneg p q hp hq hps hqs,
    klDiv_le_fisher p q hp hq hps hqs⟩

end InformationGeometry

end