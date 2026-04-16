/-! # CatalogBuild.Bridges.IharaZeta

Auto-generated from theorem catalog database.
Domain: Bridges
Declarations: 15
-/

import Mathlib

noncomputable section

/-- An Ihara graph on n vertices. -/
structure IharaGraph (n : ℕ) where
  adj : Matrix (Fin n) (Fin n) ℝ
  symmetric : adj.IsSymm
  no_self_loops : ∀ i : Fin n, adj i i = 0



/-- [Section: # CatalogBuild.Bridges.IharaZeta
Auto-generated from theorem catalog database.
Domain: Bridges
Declarations: 15] -/
def IharaGraph.degree {n : ℕ} (G : IharaGraph n) (i : Fin n) : ℝ :=
  ∑ j : Fin n, G.adj i j



def IharaGraph.degreeMatrix {n : ℕ} (G : IharaGraph n) : Matrix (Fin n) (Fin n) ℝ :=
  Matrix.diagonal (fun i => G.degree i)



def IharaGraph.laplacian {n : ℕ} (G : IharaGraph n) : Matrix (Fin n) (Fin n) ℝ :=
  G.degreeMatrix - G.adj



def IharaGraph.iharaMatrix {n : ℕ} (G : IharaGraph n) (u : ℝ) : Matrix (Fin n) (Fin n) ℝ :=
  (1 : Matrix (Fin n) (Fin n) ℝ) - u • G.adj + u^2 • (G.degreeMatrix - 1)



/-- A regular Ihara graph. -/
structure RegularIharaGraph (n : ℕ) (q : ℕ) extends IharaGraph n where
  regular : ∀ i : Fin n, toIharaGraph.degree i = (q : ℝ) + 1



theorem regular_degree_matrix_eq {n : ℕ} {q : ℕ} (G : RegularIharaGraph n q) :
    G.toIharaGraph.degreeMatrix = ((q : ℝ) + 1) • (1 : Matrix (Fin n) (Fin n) ℝ) := by
  -- Since G is regular, degree(i) = q + 1 for all i. So D = (q + 1) · I.
  have h_regular : ∀ i : Fin n, G.toIharaGraph.degree i = q + 1 := by
    exact_mod_cast G.regular;
  ext i;
  unfold IharaGraph.degreeMatrix;
  by_cases hi : i = ‹_› <;> aesop



theorem ihara_matrix_regular_simplification {n : ℕ} {q : ℕ} (G : RegularIharaGraph n q) (u : ℝ) :
    G.toIharaGraph.iharaMatrix u =
    (1 + (q : ℝ) * u^2) • (1 : Matrix (Fin n) (Fin n) ℝ) - u • G.toIharaGraph.adj := by
  ext i j;
  simp [IharaGraph.iharaMatrix, regular_degree_matrix_eq];
  ring



def onesVec (n : ℕ) : Fin n → ℝ := fun _ => 1



theorem laplacian_ones_eq_zero {n : ℕ} (G : IharaGraph n) :
    G.laplacian.mulVec (onesVec n) = 0 := by
  ext i;
  unfold onesVec;
  unfold IharaGraph.laplacian;
  unfold IharaGraph.degreeMatrix;
  unfold IharaGraph.degree; simp +decide [ Matrix.mulVec, dotProduct ];
  simp +decide [ diagonal ]



/-- Sum of all degrees in a regular graph equals n·(q+1). -/
theorem regular_degree_sum {n : ℕ} {q : ℕ} (G : RegularIharaGraph n q) :
    ∑ i : Fin n, G.toIharaGraph.degree i = (n : ℝ) * ((q : ℝ) + 1) := by
  simp [G.regular]; ring



/-- Total adjacency entries equal n·(q+1) for regular graphs. -/
theorem regular_total_adjacency {n : ℕ} {q : ℕ} (G : RegularIharaGraph n q) :
    ∑ i : Fin n, ∑ j : Fin n, G.toIharaGraph.adj i j = (n : ℝ) * ((q : ℝ) + 1) :=
  regular_degree_sum G



/-- A Ramanujan graph. -/
def IsRamanujan {n : ℕ} {q : ℕ} (G : RegularIharaGraph n q) : Prop :=
  ∀ ev : ℝ, (∃ v : Fin n → ℝ, v ≠ 0 ∧ G.toIharaGraph.adj.mulVec v = ev • v) →
    ev ≠ (q : ℝ) + 1 → ev ≠ -((q : ℝ) + 1) →
    |ev| ≤ 2 * Real.sqrt q



/-- Ramanujan implies spectral gap. -/
theorem ramanujan_spectral_gap {n : ℕ} {q : ℕ} (G : RegularIharaGraph n q)
    (hR : IsRamanujan G) (ev : ℝ)
    (hev : ∃ v : Fin n → ℝ, v ≠ 0 ∧ G.toIharaGraph.adj.mulVec v = ev • v)
    (hne1 : ev ≠ (q : ℝ) + 1) (hne2 : ev ≠ -((q : ℝ) + 1)) :
    (q : ℝ) + 1 - ev ≥ (q : ℝ) + 1 - 2 * Real.sqrt q := by
  have hbound := hR ev hev hne1 hne2
  linarith [le_abs_self ev]



/-- The trace of an adjacency matrix with zero diagonal is zero. -/
theorem trace_adj_zero {n : ℕ} (G : IharaGraph n) :
    Matrix.trace G.adj = 0 := by
  simp [Matrix.trace, Matrix.diag_apply, G.no_self_loops]



end
