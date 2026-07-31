/-
# Adjacency–degree moments and degree-distribution moments

This file formalizes a concrete connector suggested by adjacency-degree algebras.
For a symmetric matrix `A`, let `d` be its row-sum vector and `D = diag d`.
Then the scalar adjacency-degree moment

  1ᵀ A D A 1

is the third raw moment `∑ᵥ d(v)^3` of the row-sum distribution.  For a simple
undirected graph, `A` is the adjacency matrix and `d(v)` is the degree, so this
also counts homomorphisms from the three-leaf star: choose the image of its
center and then independently choose the images of its three leaves.

Thus one scalar word in the noncommutative adjacency-degree algebra connects
linear algebra, degree statistics, and graph homomorphism counting.
-/
import Mathlib

open Matrix Finset
open scoped BigOperators

namespace AdjacencyDegreeMomentBridge

variable {V : Type*} [Fintype V]

/-- The row-sum vector of a square matrix. -/
def rowSum (A : Matrix V V ℝ) : V → ℝ := fun i => ∑ j, A i j

/-- The scalar moment obtained by summing all coordinates of `A D A 1`, where
`D` is the diagonal matrix of row sums. -/
def adjacencyDegreeMoment [DecidableEq V] (A : Matrix V V ℝ) : ℝ :=
  ∑ i, ((A * Matrix.diagonal (rowSum A) * A) *ᵥ (fun _ => (1 : ℝ))) i

/-- **Matrix/statistics connector.** For every finite symmetric real matrix, the
adjacency-degree word `A D A`, tested against the all-ones vector on both sides,
is exactly the third raw moment of its row-sum vector. -/
theorem adjacencyDegreeMoment_eq_sum_rowSum_cube [DecidableEq V]
    (A : Matrix V V ℝ) (hA : A.IsSymm) :
    adjacencyDegreeMoment A = ∑ i, (rowSum A i) ^ 3 := by
  have hones : A *ᵥ (fun _ => (1 : ℝ)) = rowSum A := by
    funext i
    simp [Matrix.mulVec, dotProduct, rowSum]
  have hdiag : Matrix.diagonal (rowSum A) *ᵥ rowSum A =
      fun i => (rowSum A i) ^ 2 := by
    funext i
    rw [Matrix.mulVec_diagonal]
    ring
  unfold adjacencyDegreeMoment
  rw [← Matrix.mulVec_mulVec, ← Matrix.mulVec_mulVec, hones, hdiag]
  simp only [Matrix.mulVec, dotProduct]
  calc
    (∑ i, ∑ j, A i j * rowSum A j ^ 2) =
        ∑ j, (∑ i, A i j) * rowSum A j ^ 2 := by
          rw [Finset.sum_comm]
          apply Finset.sum_congr rfl
          intro j _
          rw [← Finset.sum_mul]
    _ = ∑ j, rowSum A j * rowSum A j ^ 2 := by
          apply Finset.sum_congr rfl
          intro j _
          congr 1
          unfold rowSum
          apply Finset.sum_congr rfl
          intro i _
          exact hA.apply j i
    _ = ∑ i, rowSum A i ^ 3 := by
          apply Finset.sum_congr rfl
          intro i _
          ring

/-- The adjacency matrix has row sum equal to the (real-valued) vertex degree. -/
theorem adjMatrix_rowSum_eq_degree
    (G : SimpleGraph V) [DecidableRel G.Adj] (v : V) :
    rowSum (G.adjMatrix ℝ) v = (G.degree v : ℝ) := by
  unfold rowSum
  rw [show G.degree v = (G.neighborFinset v).card from rfl]
  calc
    (∑ j, G.adjMatrix ℝ v j) = ∑ j ∈ G.neighborFinset v, (1 : ℝ) := by
      rw [← Finset.sum_subset (s₁ := G.neighborFinset v) (s₂ := Finset.univ)]
      · apply Finset.sum_congr rfl
        intro j hj
        simp only [SimpleGraph.mem_neighborFinset] at hj
        simp [SimpleGraph.adjMatrix_apply, hj]
      · exact Finset.subset_univ _
      · intro j _ hj
        simp only [SimpleGraph.mem_neighborFinset] at hj
        simp [SimpleGraph.adjMatrix_apply, hj]
    _ = (G.neighborFinset v).card := by simp

/-- **Graph/spectral/statistical connector.** The scalar word `1ᵀ A D A 1` of a
finite simple graph is the sum of cubes of its degrees. -/
theorem graph_adjacencyDegreeMoment_eq_sum_degree_cube [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] :
    adjacencyDegreeMoment (G.adjMatrix ℝ) = ∑ v, (G.degree v : ℝ) ^ 3 := by
  have hsymm : (G.adjMatrix ℝ).IsSymm := by
    apply Matrix.ext
    intro i j
    simp [Matrix.transpose_apply, SimpleGraph.adjMatrix_apply, G.adj_comm]
  rw [adjacencyDegreeMoment_eq_sum_rowSum_cube (G.adjMatrix ℝ) hsymm]
  apply Finset.sum_congr rfl
  intro v _
  rw [adjMatrix_rowSum_eq_degree G v]

/-- The degree-cube expression is also the number of ordered choices of three
neighbors of a center, written as a finite sum of cardinalities.  Repetitions
are allowed, exactly as in graph homomorphisms from a three-leaf star. -/
theorem sum_degree_cube_eq_ordered_neighbor_triples
    (G : SimpleGraph V) [DecidableRel G.Adj] :
    ∑ v, (G.degree v) ^ 3 =
      ∑ v, ((G.neighborFinset v ×ˢ G.neighborFinset v) ×ˢ G.neighborFinset v).card := by
  apply Finset.sum_congr rfl
  intro v _
  simp [SimpleGraph.card_neighborFinset_eq_degree, pow_succ]

/-- Combined bridge: the adjacency-degree scalar moment is the real cast of the
number of ordered center-and-three-neighbor choices, hence of three-star graph
homomorphisms. -/
theorem adjacencyDegreeMoment_eq_star_choices [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] :
    adjacencyDegreeMoment (G.adjMatrix ℝ) =
      (∑ v, ((G.neighborFinset v ×ˢ G.neighborFinset v) ×ˢ
        G.neighborFinset v).card : ℕ) := by
  rw [graph_adjacencyDegreeMoment_eq_sum_degree_cube G]
  push_cast
  exact_mod_cast sum_degree_cube_eq_ordered_neighbor_triples G

end AdjacencyDegreeMomentBridge