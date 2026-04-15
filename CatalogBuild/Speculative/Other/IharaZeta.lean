/-! # CatalogBuild.Speculative.Other.IharaZeta

Auto-generated from theorem catalog database.
Domain: Speculative/Other
Declarations: 11
-/

import Mathlib

noncomputable section

/-- A graph is q+1 regular if every vertex has degree q+1. -/
def IharaGraph.isRegular {n : ℕ} (G : IharaGraph n) (q : ℕ) : Prop :=
  ∀ i, G.degree i = (q + 1 : ℝ)


/-- The adjacency matrix as a Mathlib matrix. -/
def IharaGraph.adjMatrix {n : ℕ} (G : IharaGraph n) : Matrix (Fin n) (Fin n) ℝ :=
  Matrix.of G.adj


/-- The degree matrix (diagonal). -/
def IharaGraph.degMatrix {n : ℕ} (G : IharaGraph n) : Matrix (Fin n) (Fin n) ℝ :=
  Matrix.diagonal (fun i => G.degree i)


/-- The adjacency matrix is symmetric. -/
theorem IharaGraph.adjMatrix_symm {n : ℕ} (G : IharaGraph n) :
    G.adjMatrix.transpose = G.adjMatrix := by
  ext i j
  simp [IharaGraph.adjMatrix, Matrix.of, Matrix.transpose]
  exact G.adj_symm j i


/-- The Ihara matrix: I - u·A + u²·(D - I).
This is the key matrix whose determinant gives ζ_G(u)⁻¹. -/
def iharaMatrix {n : ℕ} (G : IharaGraph n) (u : ℝ) : Matrix (Fin n) (Fin n) ℝ :=
  1 - u • G.adjMatrix + u^2 • (G.degMatrix - 1)


theorem ihara_matrix_regular {n : ℕ} (G : IharaGraph n) (q : ℕ) (u : ℝ)
    (hreg : G.isRegular q) :
    iharaMatrix G u = (1 + (q : ℝ) * u^2) • (1 : Matrix (Fin n) (Fin n) ℝ) - u • G.adjMatrix := by
  ext i j; by_cases hij : i = j <;> simp_all +decide [ Matrix.mul_apply, Finset.mul_sum _ _ _, Finset.sum_add_distrib, mul_assoc, add_mul, sub_mul, mul_sub, pow_two, mul_comm, mul_left_comm ] ; ring;
  · simp [iharaMatrix, hreg];
    simp [IharaGraph.degMatrix, hreg];
    exact Or.inl ( by linarith [ hreg j ] );
  · unfold iharaMatrix;
    unfold IharaGraph.degMatrix; aesop;


theorem regular_graph_eigenvalue_bound {n : ℕ} (G : IharaGraph n) (q : ℕ)
    (hreg : G.isRegular q)
    (hadj_nn : ∀ i j, 0 ≤ G.adj i j)  -- adjacency entries are non-negative
    (ev : ℝ)
    (hev : ∃ v : Fin n → ℝ, v ≠ 0 ∧ G.adjMatrix.mulVec v = ev • v) :
    |ev| ≤ (q + 1 : ℝ) := by
  obtain ⟨ v, hv_ne, hv ⟩ := hev;
  -- Since $v$ is non-zero, there exists some $i$ such that $|v_i|$ is maximal and $|v_i| > 0$.
  obtain ⟨i, hi⟩ : ∃ i : Fin n, (∀ j : Fin n, |v j| ≤ |v i|) ∧ |v i| > 0 := by
    obtain ⟨i, hi⟩ : ∃ i : Fin n, ∀ j : Fin n, |v j| ≤ |v i| := by
      simpa using Finset.exists_max_image Finset.univ ( fun j => |v j| ) ⟨ ⟨ 0, Nat.pos_of_ne_zero ( by rintro rfl; simp_all +decide [ funext_iff ] ) ⟩, Finset.mem_univ _ ⟩;
    exact ⟨ i, hi, abs_pos.mpr ( show v i ≠ 0 from fun h => hv_ne <| funext fun j => by simpa [ h ] using hi j ) ⟩;
  have h_abs : |v i| * |ev| ≤ ∑ j, G.adj i j * |v j| := by
    have h_abs : |v i| * |ev| = |∑ j, G.adj i j * v j| := by
      simp_all +decide [ funext_iff, Matrix.mulVec, dotProduct ];
      exact hv i ▸ by rw [ mul_comm, abs_mul ] ;
    exact h_abs.symm ▸ le_trans ( Finset.abs_sum_le_sum_abs _ _ ) ( Finset.sum_le_sum fun j _ => by rw [ abs_mul, abs_of_nonneg ( hadj_nn i j ) ] );
  -- Since $|v_j| \leq |v_i|$ for all $j$, we have $\sum_{j} G.adj i j * |v_j| \leq |v_i| * \sum_{j} G.adj i j$.
  have h_sum_le : ∑ j, G.adj i j * |v j| ≤ |v i| * ∑ j, G.adj i j := by
    simpa only [ mul_comm, Finset.mul_sum _ _ _ ] using Finset.sum_le_sum fun j _ => mul_le_mul_of_nonneg_left ( hi.1 j ) ( hadj_nn i j );
  nlinarith [ hreg i, show ( ∑ j : Fin n, G.adj i j ) = q + 1 from mod_cast hreg i ]


/-- A Ramanujan graph satisfies |λ| ≤ 2√q for all non-trivial eigenvalues. -/
def IharaGraph.isRamanujan {n : ℕ} (G : IharaGraph n) (q : ℕ) : Prop :=
  G.isRegular q ∧ ∀ ev : ℝ,
    (∃ v : Fin n → ℝ, v ≠ 0 ∧ G.adjMatrix.mulVec v = ev • v) →
    |ev| = (q + 1 : ℝ) ∨ |ev| ≤ 2 * Real.sqrt q


/-- Number of edges of a graph (half the sum of all adjacency entries). -/
def IharaGraph.numEdges {n : ℕ} (G : IharaGraph n) : ℝ :=
  (∑ i, ∑ j, G.adj i j) / 2


/-- The rank of the fundamental group: r = |E| - |V| + 1 -/
def IharaGraph.graphRank {n : ℕ} (G : IharaGraph n) : ℝ :=
  G.numEdges - n + 1


theorem regular_graph_edges {n : ℕ} (G : IharaGraph n) (q : ℕ) (hreg : G.isRegular q) :
    G.numEdges = (n : ℝ) * (q + 1 : ℝ) / 2 := by
  convert congr_arg ( fun x : ℝ => x / 2 ) ( Finset.sum_congr rfl fun i _ => hreg i ) using 1 ; simp +decide [ Finset.sum_add_distrib, Matrix.mulVec, dotProduct ];
  ring


end
