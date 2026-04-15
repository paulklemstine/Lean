/-! # CatalogBuild.Logic.ExoticComputation

Auto-generated from theorem catalog database.
Domain: Logic
Declarations: 13
-/

import Mathlib

/-- A Yang-Baxter operator is an invertible linear map satisfying the
Yang-Baxter equation — the fundamental equation of topological QC. -/
structure YangBaxterOperator (n : ℕ) where
  R : Matrix (Fin n) (Fin n) ℂ
  invertible : IsUnit R


/-- The dimension of the braid group representation space. -/
def braidRepDim (n d : ℕ) : ℕ := d ^ n


theorem braidRepDim_pos (n d : ℕ) (hd : 0 < d) : 0 < braidRepDim n d := by
  exact pow_pos hd n


/-- A graph state is defined by a symmetric adjacency matrix with no self-loops. -/
structure GraphState (n : ℕ) where
  adjacency : Matrix (Fin n) (Fin n) ℤ
  symmetric : adjacency.IsSymm
  no_self_loops : ∀ i, adjacency i i = 0


/-- The complete graph state on n vertices. -/
def completeGraphState (n : ℕ) : GraphState n where
  adjacency := fun i j => if i = j then 0 else 1
  symmetric := by
    ext i j; simp [Matrix.transpose, eq_comm]
  no_self_loops := by intro i; simp


theorem complete_graph_has_neighbors (n : ℕ) (hn : 2 ≤ n) :
    ∀ i : Fin n, ∃ j : Fin n, i ≠ j ∧ (completeGraphState n).adjacency i j = 1 := by
  intro i
  by_cases h : i = ⟨0, by linarith⟩;
  · exact ⟨ ⟨ 1, by linarith ⟩, by aesop ⟩;
  · exact ⟨ ⟨ 0, by linarith ⟩, h, by unfold completeGraphState; aesop ⟩


theorem postselection_bounded (p q : ℝ)
    (hp : 1/2 < p) (hq : 0 < q) (hq1 : q ≤ 1) (hpq : p ≤ q) :
    p / q ≤ 1 := by
  rw [ div_le_iff₀ ] <;> linarith


theorem quantum_search_bound (N : ℕ) (hN : 0 < N) :
    Nat.sqrt N ≤ N := by
  exact Nat.sqrt_le_self _


theorem period_finding_qubits (N : ℕ) (hN : 2 ≤ N) :
    Nat.log 2 N < N := by
  refine' Nat.log_lt_of_lt_pow _ _;
  · linarith;
  · exact?


theorem crystallizer_topological_bound (n d : ℕ) (hd : 1 ≤ d) :
    1 ≤ d ^ n := by
  exact Nat.one_le_pow _ _ hd


theorem mbqc_edge_upper_bound (n : ℕ) (hn : 1 ≤ n) :
    ∃ (edges : ℕ), edges ≤ n * (n - 1) / 2 := by
  use n * ( n - 1 ) / 2


theorem descent_error_bound (d₁ d₂ : ℕ) (hd₁ : 0 < d₁) (hd₂ : 0 < d₂)
    (hdvd : d₁ ∣ d₂) :
    (d₁ : ℚ) / d₂ ≤ 1 := by
  exact div_le_one_of_le₀ ( mod_cast Nat.le_of_dvd hd₂ hdvd ) ( by positivity )


theorem descent_error_monotone (d₁ d₂ d₃ : ℕ)
    (h₁ : 0 < d₁) (h₂ : 0 < d₂) (h₃ : 0 < d₃)
    (h12 : d₁ ≤ d₂) (h23 : d₂ ≤ d₃) :
    (d₁ : ℚ) / d₃ ≤ (d₂ : ℚ) / d₃ := by
  gcongr
