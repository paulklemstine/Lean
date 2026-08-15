import Mathlib
import Bridges.InnerProductBridge
/-! # Sparse graph spectra and forbidden-cycle extremal problems

The spectral extremal problem for planar and outerplanar graphs begins with a
linear-algebraic bridge: an adjacency eigenvalue is controlled by the number of
edges.  This file isolates that bridge in a form independent of planarity, and
then records the sharper consequence obtained whenever a forbidden-configuration
argument supplies a linear edge bound.

The resulting estimate is not the final sharp classification for forbidden
`C_{k,l}` graphs.  It is the robust baseline against which the extremal join
constructions must be compared.
-/

namespace PlanarForbiddenCycleSpectral

open Finset Matrix SimpleGraph
open scoped BigOperators

variable {V : Type*} [Fintype V]

-- !-- Lab Notes -- !--
-- Hypothesis: a Frobenius-norm estimate converts any combinatorial edge bound
-- into an adjacency-eigenvalue bound.
-- Experiment: apply finite Cauchy--Schwarz first to every matrix row and then
-- sum the resulting inequalities.
-- Analysis: symmetry identifies the squared Frobenius norm of an adjacency
-- matrix with the trace of its square, hence with twice the edge count.
-- Critique: this gives the universal constant `sqrt 2`; it deliberately does
-- not claim the sharp extremal graph or encode planarity, whose structural
-- classification requires substantially more graph-minor infrastructure.
-- Synthesis: the general matrix theorem and graph specialization below form a
-- reusable analytic/combinatorial bridge.
-- !-- End Lab Notes -- !--

/-- Rowwise Cauchy--Schwarz, summed over all rows, bounds the squared Euclidean
mass of a matrix-vector product by the squared Frobenius mass of the matrix. -/
theorem sum_sq_mulVec_le_frobenius
    (A : Matrix V V ℝ) (x : V → ℝ) :
    (∑ i, (A.mulVec x i) ^ 2) ≤
      (∑ i, ∑ j, (A i j) ^ 2) * (∑ j, (x j) ^ 2) := by
  calc
    (∑ i, (A.mulVec x i) ^ 2) ≤
        ∑ i, (∑ j, (A i j) ^ 2) * (∑ j, (x j) ^ 2) := by
      apply Finset.sum_le_sum
      intro i hi
      simpa [Matrix.mulVec, dotProduct] using
        (Finset.sum_mul_sq_le_sq_mul_sq (Finset.univ) (A i) x)
    _ = (∑ i, ∑ j, (A i j) ^ 2) * (∑ j, (x j) ^ 2) := by
      rw [Finset.sum_mul]

/-- A nonzero eigenvector forces the square of its eigenvalue below the squared
Frobenius norm.  This is the finite-dimensional spectral-to-counting bridge. -/
theorem eigenvalue_sq_le_frobenius
    (A : Matrix V V ℝ) (x : V → ℝ) (lam : ℝ)
    (heig : A.mulVec x = lam • x) (hx : x ≠ 0) :
    lam ^ 2 ≤ ∑ i, ∑ j, (A i j) ^ 2 := by
  have hcoord : ∃ i, x i ≠ 0 := by simpa [Function.ne_iff] using hx
  obtain ⟨i, hi⟩ := hcoord
  have hspos : 0 < ∑ j, (x j) ^ 2 := by
    apply Finset.sum_pos'
    · intro j hj
      positivity
    · exact ⟨i, Finset.mem_univ i, sq_pos_of_ne_zero hi⟩
  have heq : (∑ i, (A.mulVec x i) ^ 2) = lam ^ 2 * (∑ j, (x j) ^ 2) := by
    simp_rw [congrFun heig]
    simp [smul_eq_mul, mul_pow, Finset.mul_sum]
  have hF := sum_sq_mulVec_le_frobenius A x
  rw [heq] at hF
  nlinarith

/-- The squared Frobenius mass of a simple graph's real adjacency matrix is
exactly twice its number of edges. -/
theorem adjacency_frobenius_eq_twice_edges
    (G : SimpleGraph V) [DecidableRel G.Adj] :
    (∑ i, ∑ j, (G.adjMatrix ℝ i j) ^ 2) = 2 * (G.edgeFinset.card : ℝ) := by
  have hrow : ∀ i, (∑ j, (G.adjMatrix ℝ i j) ^ 2) = (G.degree i : ℝ) := by
    intro i
    rw [show G.degree i = (G.neighborFinset i).card from rfl]
    calc
      _ = ∑ j ∈ G.neighborFinset i, (1 : ℝ) := by
        rw [← Finset.sum_subset (s₁ := G.neighborFinset i) (s₂ := Finset.univ)]
        · apply Finset.sum_congr rfl
          intro j hj
          simp only [SimpleGraph.mem_neighborFinset] at hj
          simp [SimpleGraph.adjMatrix_apply, hj]
        · exact Finset.subset_univ _
        · intro j hj hjnot
          simp only [SimpleGraph.mem_neighborFinset] at hjnot
          simp [SimpleGraph.adjMatrix_apply, hjnot]
      _ = _ := by simp
  simp_rw [hrow]
  rw [← Nat.cast_sum, SimpleGraph.sum_degrees_eq_twice_card_edges]
  push_cast
  ring

/-- Every adjacency eigenvalue of a finite simple graph satisfies
`λ² ≤ 2m`, where `m` is the number of edges. -/
theorem graph_eigenvalue_sq_le_twice_edges
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (x : V → ℝ) (lam : ℝ)
    (heig : (G.adjMatrix ℝ).mulVec x = lam • x) (hx : x ≠ 0) :
    lam ^ 2 ≤ 2 * (G.edgeFinset.card : ℝ) := by
  calc
    lam ^ 2 ≤ ∑ i, ∑ j, (G.adjMatrix ℝ i j) ^ 2 :=
      eigenvalue_sq_le_frobenius (G.adjMatrix ℝ) x lam heig hx
    _ = 2 * (G.edgeFinset.card : ℝ) := adjacency_frobenius_eq_twice_edges G

/-- Any hereditary or topological restriction yielding `m ≤ c n` immediately
yields the spectral estimate `λ² ≤ 2 c n`.  In particular this packages the
analytic final step in planar, outerplanar, and forbidden-`C_{k,l}` arguments. -/
theorem graph_eigenvalue_sq_le_of_linear_edge_bound
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (x : V → ℝ) (lam c : ℝ)
    (heig : (G.adjMatrix ℝ).mulVec x = lam • x) (hx : x ≠ 0)
    (hedges : (G.edgeFinset.card : ℝ) ≤ c * Fintype.card V) :
    lam ^ 2 ≤ 2 * c * Fintype.card V := by
  have hspec := graph_eigenvalue_sq_le_twice_edges G x lam heig hx
  have hn : (0 : ℝ) ≤ Fintype.card V := by positivity
  nlinarith

-- !-- Lab Notes -- !--
-- Hypothesis: positivity of a distinguished eigenvalue should turn the squared
-- estimate into a direct upper bound by a square root.
-- Experiment: combine nonnegativity with monotonicity of squaring.
-- Analysis: no Perron--Frobenius theorem is needed once nonnegativity of the
-- selected eigenvalue is supplied explicitly.
-- Critique: the edge bound remains an input; asserting the paper's exact
-- forbidden-cycle threshold here would conceal its deepest combinatorial step.
-- Synthesis: the square-root corollary states the asymptotic spectral scale in
-- the form used by extremal comparisons.
-- !-- End Lab Notes -- !--

/-- Square-root form of the linear-edge estimate for a nonnegative adjacency
 eigenvalue. -/
theorem graph_eigenvalue_le_sqrt_of_linear_edge_bound
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (x : V → ℝ) (lam c : ℝ)
    (heig : (G.adjMatrix ℝ).mulVec x = lam • x) (hx : x ≠ 0)
    (hc : 0 ≤ c)
    (hedges : (G.edgeFinset.card : ℝ) ≤ c * Fintype.card V) :
    lam ≤ Real.sqrt (2 * c * Fintype.card V) := by
  have hsq := graph_eigenvalue_sq_le_of_linear_edge_bound G x lam c heig hx hedges
  have harg : 0 ≤ 2 * c * (Fintype.card V : ℝ) := by positivity
  have hsqrt : 0 ≤ Real.sqrt (2 * c * Fintype.card V) := Real.sqrt_nonneg _
  have hsqrt_sq : (Real.sqrt (2 * c * Fintype.card V)) ^ 2 =
      2 * c * Fintype.card V := Real.sq_sqrt harg
  nlinarith

end PlanarForbiddenCycleSpectral