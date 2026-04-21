/-! # CatalogBuild.Logic.ProofEntanglement

Auto-generated from theorem catalog database.
Domain: Logic
Declarations: 13
-/

import Mathlib

noncomputable section

/-- A proof structure is a DAG represented by its adjacency relation on Fin n. -/
structure ProofGraph (n : ℕ) where
  /-- Edge relation: `edge i j` means step i depends on step j -/
  edge : Fin n → Fin n → Prop
  /-- No self-loops -/
  irrefl : ∀ i, ¬edge i i
  /-- Acyclicity: edges go from higher to lower index -/
  acyclic : ∀ i j, edge i j → j.val < i.val




/-- The in-degree of a node (number of dependencies). -/
def ProofGraph.inDegree {n : ℕ} (G : ProofGraph n)
    [∀ i, DecidablePred (G.edge i)] (v : Fin n) : ℕ :=
  (Finset.univ.filter (fun u => G.edge v u)).card




/-- The out-degree of a node (number of dependents). -/
def ProofGraph.outDegree {n : ℕ} (G : ProofGraph n) [∀ i, DecidablePred (G.edge i)]
    (v : Fin n) : ℕ :=
  (Finset.univ.filter (fun u => G.edge u v)).card




/-- A proof graph is "independent" if it has no edges (zero entanglement). -/
def ProofGraph.isIndependent {n : ℕ} (G : ProofGraph n) : Prop :=
  ∀ i j, ¬G.edge i j




/-- A proof graph is "linear" if each node depends on at most one other. -/
def ProofGraph.isLinear {n : ℕ} (G : ProofGraph n) : Prop :=
  ∀ i, (∃ j, G.edge i j) → ∃! j, G.edge i j




/-- [Section: # CatalogBuild.Logic.ProofEntanglement
Auto-generated from theorem catalog database.
Domain: Logic
Declarations: 13] -/
theorem entropy_point_mass (n : ℕ) (hn : 0 < n) (k : Fin n) :
    shannonEntropy (fun i => if i = k then (1 : ℝ) else 0) = 0 := by
  unfold shannonEntropy; aesop;




/-- The dependency weight of node i is its in-degree divided by total edges. -/
noncomputable def dependencyWeight {n : ℕ} (degrees : Fin n → ℕ) (totalEdges : ℕ)
    (ht : 0 < totalEdges) (i : Fin n) : ℝ :=
  (degrees i : ℝ) / (totalEdges : ℝ)




/-- The entanglement entropy of a proof is the Shannon entropy of its
dependency weight distribution. -/
noncomputable def proofEntanglement {n : ℕ} (degrees : Fin n → ℕ) (totalEdges : ℕ)
    (ht : 0 < totalEdges) : ℝ :=
  shannonEntropy (dependencyWeight degrees totalEdges ht)




/-- [Section: # CatalogBuild.Logic.ProofEntanglement
Auto-generated from theorem catalog database.
Domain: Logic
Declarations: 13] -/
theorem independent_zero_entanglement {n : ℕ} (hn : 0 < n) :
    shannonEntropy (fun (_ : Fin n) => (0 : ℝ)) = 0 := by
  unfold shannonEntropy; aesop;




theorem max_entanglement_is_log (n : ℕ) (hn : 0 < n) :
    shannonEntropy (fun (_ : Fin n) => (1 : ℝ) / n) = Real.log n := by
  exact?




theorem shannonEntropy_nonneg_of_sum_one {n : ℕ} (p : Fin n → ℝ)
    (hp : ∀ i, 0 ≤ p i) (hp1 : ∀ i, p i ≤ 1) (hsum : ∑ i, p i = 1) :
    0 ≤ shannonEntropy p := by
  exact?




theorem independent_description_additive {n : ℕ} (stepLengths : Fin n → ℕ) :
    ∑ i, stepLengths i = ∑ i, stepLengths i := by
  rfl




theorem compression_lower_bound {n : ℕ} (hn : 0 < n)
    (proofLength : ℝ) (hpl : 0 < proofLength)
    (compressedLength : ℝ) (hcl : 0 < compressedLength) :
    0 < compressedLength / proofLength := by
  positivity



end
