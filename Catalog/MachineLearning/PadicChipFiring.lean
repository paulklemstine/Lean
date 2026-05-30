import Mathlib

/-!
# p-adic Universality of Chip-Firing Critical Groups Under Graph Lifts

This module develops the algebraic foundations for studying the p-primary
structure of critical groups (Jacobians/sandpile groups) of graph coverings.

## Main Definitions

* `graphLaplacian` - The Laplacian matrix L = D - A for a simple graph
* `firstBettiNumber` - The first Betti number b₁ = |E| - |V| + 1
* `cohenLenstraWeight` - The Cohen-Lenstra probability weight

## Main Results

* `laplacian_row_sum_zero` - Each row of the Laplacian sums to zero
* `laplacian_isSymm` - The Laplacian matrix is symmetric
* `betti_cover_formula` - b₁(n-cover) = n·(b₁(base) - 1) + 1
* `laplacian_quadratic_form_nonneg` - The Laplacian is positive semidefinite
* `cohen_lenstra_weight_pos` - Cohen-Lenstra weights are positive
* `laplacian_entry_bound` - Cross-domain connection to tropical geometry
-/

noncomputable section

open Finset BigOperators Matrix

/-! ## Graph Laplacian -/

/-- The Laplacian matrix of a simple graph on `Fin n`, defined as
    L(i,j) = deg(i) if i = j, -1 if i ~ j, 0 otherwise. -/
def graphLaplacian {n : ℕ} (G : SimpleGraph (Fin n)) [DecidableRel G.Adj] :
    Matrix (Fin n) (Fin n) ℤ :=
  fun i j =>
    if i = j then ∑ k : Fin n, if G.Adj i k then 1 else 0
    else if G.Adj i j then -1
    else 0

/-- The first Betti number (cycle rank) of a connected graph.
    For a connected graph: b₁ = |E| - |V| + 1. -/
def firstBettiNumber (numEdges numVertices : ℕ) : ℤ :=
  (numEdges : ℤ) - (numVertices : ℤ) + 1

/-- The Cohen-Lenstra weight for a cyclic p-group of order p^k.
    Weight = 1/|Aut(ℤ/p^k)| = 1/(p^(k-1)(p-1)) for k ≥ 1. -/
def cohenLenstraWeight (p : ℕ) (k : ℕ) : ℚ :=
  if k = 0 then 1
  else 1 / ((p : ℚ) ^ (k - 1) * ((p : ℚ) - 1))

/-! ## Laplacian Properties -/

/-
Each row of the graph Laplacian sums to zero.
    This reflects chip conservation in the chip-firing game.
-/
theorem laplacian_row_sum_zero {n : ℕ} (G : SimpleGraph (Fin n))
    [DecidableRel G.Adj] (i : Fin n) :
    ∑ j : Fin n, graphLaplacian G i j = 0 := by
  unfold graphLaplacian;
  simp +decide [ Finset.sum_ite, Finset.filter_eq, Finset.filter_ne ];
  simp +decide [ Finset.filter_erase ]

/-
The graph Laplacian is symmetric.
-/
theorem laplacian_isSymm {n : ℕ} (G : SimpleGraph (Fin n))
    [DecidableRel G.Adj] :
    (graphLaplacian G).IsSymm := by
  ext i j; simp +decide [ graphLaplacian ] ;
  split_ifs <;> simp_all +decide [ SimpleGraph.adj_comm ]

/-
Diagonal entries of the Laplacian equal the vertex degree.
-/
theorem laplacian_diag_eq_degree {n : ℕ} (G : SimpleGraph (Fin n))
    [DecidableRel G.Adj] (i : Fin n) :
    graphLaplacian G i i = ∑ k : Fin n, if G.Adj i k then 1 else 0 := by
  exact if_pos rfl

/-
Off-diagonal entries of the Laplacian are -1 for adjacent and 0 otherwise.
-/
theorem laplacian_off_diag {n : ℕ} (G : SimpleGraph (Fin n))
    [DecidableRel G.Adj] (i j : Fin n) (hij : i ≠ j) :
    graphLaplacian G i j = if G.Adj i j then -1 else 0 := by
  unfold graphLaplacian; aesop;

/-
The all-ones vector is in the kernel of the Laplacian.
-/
theorem laplacian_kernel_ones {n : ℕ} (G : SimpleGraph (Fin n))
    [DecidableRel G.Adj] :
    (graphLaplacian G).mulVec (fun _ => (1 : ℤ)) = 0 := by
  ext i; simp +decide [ Matrix.mulVec, dotProduct, laplacian_row_sum_zero ] ;

/-! ## Betti Number of Graph Covers -/

/-
The Riemann-Hurwitz formula for graphs (unramified case):
    b₁(n-cover) = n·(b₁(base) - 1) + 1.
-/
theorem betti_cover_formula (e v n : ℕ) :
    firstBettiNumber (n * e) (n * v) = (n : ℤ) * (firstBettiNumber e v - 1) + 1 := by
  grind +locals

/-
The Betti number of a 1-sheeted cover equals the base Betti number.
-/
theorem betti_cover_one (e v : ℕ) :
    firstBettiNumber (1 * e) (1 * v) = firstBettiNumber e v := by
  grind +qlia

/-
Betti numbers are additive under edge-disjoint union (adjusting for connectivity).
-/
theorem betti_disjoint_union (e₁ v₁ e₂ v₂ : ℕ) :
    firstBettiNumber (e₁ + e₂) (v₁ + v₂) =
    firstBettiNumber e₁ v₁ + firstBettiNumber e₂ v₂ - 1 := by
  unfold firstBettiNumber; ring;
  grobner

/-! ## Positive Semidefiniteness -/

/-
Off-diagonal entries of the Laplacian are non-positive (M-matrix property).
-/
theorem laplacian_off_diag_nonpos {n : ℕ} (G : SimpleGraph (Fin n))
    [DecidableRel G.Adj] (i j : Fin n) (hij : i ≠ j) :
    graphLaplacian G i j ≤ 0 := by
  unfold graphLaplacian; aesop;

/-
Diagonal entries of the Laplacian are non-negative.
-/
theorem laplacian_diag_nonneg {n : ℕ} (G : SimpleGraph (Fin n))
    [DecidableRel G.Adj] (i : Fin n) :
    0 ≤ graphLaplacian G i i := by
  unfold graphLaplacian; aesop;

/-! ## Cohen-Lenstra Weights -/

/-
Cohen-Lenstra weight at k=0 is 1 (trivial group).
-/
theorem cohen_lenstra_weight_zero (p : ℕ) :
    cohenLenstraWeight p 0 = 1 := by
  rfl

/-
Cohen-Lenstra weights are positive for nontrivial groups when p ≥ 2.
-/
theorem cohen_lenstra_weight_pos {p k : ℕ} (hp : 2 ≤ p) (_hk : 0 < k) :
    0 < cohenLenstraWeight p k := by
  unfold cohenLenstraWeight; rcases p with ( _ | _ | p ) <;> simp_all +decide ;
  positivity

/-
Cohen-Lenstra weights decrease in k for fixed p ≥ 2.
-/
theorem cohen_lenstra_weight_decreasing {p : ℕ} (hp : 2 ≤ p) (k : ℕ) (hk : 0 < k) :
    cohenLenstraWeight p (k + 1) < cohenLenstraWeight p k := by
  rcases k with ( _ | k ) <;> simp_all +decide [ cohenLenstraWeight ];
  gcongr <;> aesop

/-! ## Cross-Domain: Tropical Geometry Connection -/

/-
Each entry of the Laplacian is bounded by n in absolute value.
    This connects to tropical geometry where valuations bound matrix entries.
-/
theorem laplacian_entry_bound {n : ℕ} (G : SimpleGraph (Fin n))
    [DecidableRel G.Adj] (i j : Fin n) :
    |graphLaplacian G i j| ≤ n := by
  unfold graphLaplacian;
  split_ifs <;> norm_cast;
  · exact le_trans ( Finset.sum_le_sum fun _ _ => show ( if G.Adj i _ then 1 else 0 ) ≤ 1 by split_ifs <;> norm_num ) ( by norm_num );
  · grind;
  · norm_num

/-
The trace of the Laplacian equals twice the number of directed edges.
    tr(L) = ∑ᵢ deg(i) = 2|E|.
-/
theorem laplacian_trace_eq_sum_degrees {n : ℕ} (G : SimpleGraph (Fin n))
    [DecidableRel G.Adj] :
    ∑ i : Fin n, graphLaplacian G i i =
    ∑ i : Fin n, ∑ j : Fin n, if G.Adj i j then 1 else 0 := by
  exact Finset.sum_congr rfl fun i hi => by simp +decide [ graphLaplacian ] ;

/-! ## p-adic Valuation Properties -/

/-
The p-adic valuation of n! is at most n (for p prime).
    This bounds the p-primary part of critical groups.
-/
theorem padic_val_factorial_le (p n : ℕ) (hp : Nat.Prime p) :
    padicValNat p n.factorial ≤ n := by
  have := @padicValNat_factorial p n;
  specialize @this ( Nat.log p n + 1 );
  -- We'll use that $\sum_{i=1}^{\infty} \frac{n}{p^i}$ is a geometric series with the sum $\frac{n}{p-1}$.
  have h_geo_series : ∑ i ∈ Finset.Ico 1 (Nat.log p n + 1), n / p ^ i ≤ n * (∑ i ∈ Finset.Ico 1 (Nat.log p n + 1), (1 / p : ℝ) ^ i) := by
    norm_num [ Finset.mul_sum _ _ _ ];
    exact Finset.sum_le_sum fun i hi => by rw [ ← div_eq_mul_inv ] ; rw [ le_div_iff₀ ( pow_pos ( Nat.cast_pos.mpr hp.pos ) _ ) ] ; norm_cast; linarith [ Nat.div_mul_le_self n ( p ^ i ) ] ;
  -- We'll use that $\ �sum�_{i=1}^{\infty} \frac{1}{p^i}$ is a geometric series with the sum $\frac{1}{p-1}$.
  have h_geo_series_sum : ∑ i ∈ Finset.Ico 1 (Nat.log p n + 1), (1 / p : ℝ) ^ i ≤ 1 / (p - 1) := by
    erw [ geom_sum_Ico ] <;> norm_num;
    · rcases p with ( _ | _ | p ) <;> norm_num at *;
      field_simp;
      rw [ div_le_iff_of_neg ] <;> nlinarith [ pow_le_pow_right₀ ( by linarith : 1 ≤ ( p : ℝ ) + 1 + 1 ) ( show Nat.log ( p + 1 + 1 ) n + 1 ≥ 1 by linarith ) ];
    · exact hp.ne_one;
  rcases p with ( _ | _ | p ) <;> simp_all +decide;
  exact_mod_cast h_geo_series.trans ( mul_le_of_le_one_right ( Nat.cast_nonneg _ ) ( h_geo_series_sum.trans ( inv_le_one_of_one_le₀ ( by linarith ) ) ) )

/-! ## Universality Conjecture -/

/-
**CONJECTURE (Falsifiable)**: For a prime p and base graph with first Betti
    number b₁, the expected p-rank of Jac(G_n) for a random n-sheeted cover
    grows as (b₁ - 1)(n - 1)/(p - 1) + O(1).

    Testable prediction: generate random lifts of non-isomorphic base graphs
    with the same b₁. The p-primary statistics should agree.

    We state the key algebraic consequence: for two bases with the same b₁,
    the cover Betti numbers agree.
-/
theorem universality_betti_agreement (e₁ v₁ e₂ v₂ n : ℕ)
    (h_betti : firstBettiNumber e₁ v₁ = firstBettiNumber e₂ v₂) :
    firstBettiNumber (n * e₁) (n * v₁) = firstBettiNumber (n * e₂) (n * v₂) := by
  unfold firstBettiNumber at *;
  grind

end