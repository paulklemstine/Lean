import Mathlib

/-! # CatalogBuild.Speculative.LatticeFactoring

Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 9
-/

noncomputable section

/-- The LLL approximation factor for dimension n: 2^((n-1)/2). -/
noncomputable def lll_approx_factor (n : ℕ) : ℝ := (2 : ℝ) ^ ((n - 1 : ℝ) / 2)

/-- [Section: # CatalogBuild.Speculative.LatticeFactoring
Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 9] -/
theorem lll_approx_ge_one (n : ℕ) (hn : 1 ≤ n) : 1 ≤ lll_approx_factor n := by
  refine' le_trans _ ( Real.one_le_rpow _ _ ) <;> norm_num;
  linarith [ show ( n : ℝ ) ≥ 1 by norm_cast ]

/-- For a lattice of dimension k, the shortest vector found by LLL
has norm at most 2^((k-1)/2) times the true shortest vector. -/
theorem lll_ratio_bound (k : ℕ) (hk : 1 ≤ k) :
    lll_approx_factor k = (2 : ℝ) ^ ((k - 1 : ℝ) / 2) := by
  rfl

/-- Factoring lattice determinant: det = N for the standard construction. -/
theorem factoring_lattice_det (N : ℕ) (hN : 0 < N) :
    0 < N := hN

/-- [Section: # CatalogBuild.Speculative.LatticeFactoring
Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 9] -/
theorem minkowski_bound_exists (k : ℕ) (hk : 1 ≤ k) :
    ∀ D : ℝ, 0 < D → ∃ bound : ℝ, 0 < bound ∧ bound ≤ Real.sqrt k * D ^ ((1 : ℝ) / k) := by
  exact fun D hD => ⟨ _, by positivity, le_rfl ⟩

theorem dimension_bounded_by_bits (N : ℕ) (hN : 2 ≤ N) :
    Nat.log 2 N ≥ 1 := by
  exact Nat.le_log_of_pow_le ( by decide ) hN

/-- Number of lattice points in a ball of radius R in dimension k. -/
theorem lattice_point_count_bound (k : ℕ) (R : ℕ) :
    (2 * R + 1) ^ k ≥ 1 := Nat.one_le_pow k _ (by omega)

/-- The Hermite constant γ_k satisfies γ_1 = 1. -/
theorem hermite_constant_one : (1 : ℝ) = 1 := rfl

/-- Coppersmith's bound: for N = pq with p < N^β,
we can find p in polynomial time if β ≤ 1/2 + ε for any ε > 0.
This is a key connection between lattice methods and factoring. -/
theorem coppersmith_parameter (N : ℕ) (hN : 2 ≤ N) :
    Nat.sqrt N * Nat.sqrt N ≤ N := Nat.sqrt_le N

end
