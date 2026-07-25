import Mathlib

open scoped BigOperators

noncomputable section

namespace RandomMatrix

/-- A finite Gram discretization of an Airy-type correlation kernel.  The index
`r` represents a quadrature node and `i` a point at which the sampled Airy
profile is evaluated. -/
structure AiryGramApproximation (nodes points : ℕ) where
  /-- The quadrature amplitude at each node.  Its square acts as the weight. -/
  amplitude : Fin nodes → ℝ
  /-- Sampled profile values at quadrature nodes and observation points. -/
  sample : Fin nodes → Fin points → ℝ

namespace AiryGramApproximation

/-- The weighted feature vector associated with an observation point. -/
def feature {nodes points : ℕ} (A : AiryGramApproximation nodes points)
    (i : Fin points) (r : Fin nodes) : ℝ :=
  A.amplitude r * A.sample r i

/-- The discrete Airy-type kernel is the Gram matrix of the weighted sampled
profiles. -/
def kernel {nodes points : ℕ} (A : AiryGramApproximation nodes points)
    (i j : Fin points) : ℝ :=
  ∑ r : Fin nodes, A.feature i r * A.feature j r

/-- Every finite Airy Gram kernel is symmetric. -/
theorem kernel_symmetric {nodes points : ℕ}
    (A : AiryGramApproximation nodes points) (i j : Fin points) :
    A.kernel i j = A.kernel j i := by
  simp only [kernel]
  apply Finset.sum_congr rfl
  intro r _
  exact mul_comm _ _

/-- The diagonal of a finite Airy Gram kernel is nonnegative. -/
theorem kernel_diagonal_nonneg {nodes points : ℕ}
    (A : AiryGramApproximation nodes points) (i : Fin points) :
    0 ≤ A.kernel i i := by
  simp only [kernel]
  exact Finset.sum_nonneg (fun r _ => mul_self_nonneg _) 

/-- The two-point determinant of a finite Airy Gram kernel is nonnegative.
This is the finite-dimensional determinantal repulsion inequality
`K(i,j)^2 ≤ K(i,i) K(j,j)`. -/
theorem kernel_twoPoint_nonneg {nodes points : ℕ}
    (A : AiryGramApproximation nodes points) (i j : Fin points) :
    0 ≤ A.kernel i i * A.kernel j j - A.kernel i j ^ 2 := by
  rw [sub_nonneg]
  simpa only [kernel, pow_two] using
    (Finset.sum_mul_sq_le_sq_mul_sq Finset.univ (A.feature i) (A.feature j))

/-- If two sampled weighted profiles are proportional, their two-point
correlation determinant vanishes. -/
theorem kernel_twoPoint_eq_zero_of_proportional {nodes points : ℕ}
    (A : AiryGramApproximation nodes points) (i j : Fin points) (c : ℝ)
    (h : ∀ r, A.feature j r = c * A.feature i r) :
    A.kernel i i * A.kernel j j - A.kernel i j ^ 2 = 0 := by
  have hjj : A.kernel j j = c^2 * A.kernel i i := by
    simp only [kernel]
    rw [Finset.mul_sum]
    congr 1 with r
    rw [h r]
    ring
  have hij : A.kernel i j = c * A.kernel i i := by
    simp only [kernel]
    rw [Finset.mul_sum]
    congr 1 with r
    rw [h r]
    ring
  rw [hjj, hij]
  ring

/-- A nonzero sampled profile has strictly positive one-point density. -/
theorem kernel_diagonal_pos_of_feature_ne_zero {nodes points : ℕ}
    (A : AiryGramApproximation nodes points) (i : Fin points) (r : Fin nodes)
    (hr : A.feature i r ≠ 0) :
    0 < A.kernel i i := by
  simp only [kernel]
  have h1 : A.feature i r * A.feature i r > 0 := mul_self_pos.mpr hr
  apply Finset.sum_pos' _ ⟨⟨r, r.2⟩, Finset.mem_univ _, h1⟩
  intro s _
  apply mul_self_nonneg

end AiryGramApproximation
end RandomMatrix