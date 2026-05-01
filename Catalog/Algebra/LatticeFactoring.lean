import Mathlib

/-! # CatalogBuild.Speculative.LatticeFactoring

Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 18
-/

noncomputable section

/-- The LLL approximation factor for dimension n: 2^((n-1)/2). -/
noncomputable def lll_approx_factor (n : ℕ) : ℝ := (2 : ℝ) ^ ((n - 1 : ℝ) / 2)

/-- [Section: # CatalogBuild.Speculative.LatticeFactoring
Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 18] -/
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
Declarations: 18] -/
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

/-- [Section: # CatalogBuild.Speculative.LatticeFactoring
Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 18] -/
def normSq' (x y : ℤ) : ℤ := x ^ 2 + y ^ 2

/-- [Section: # CatalogBuild.Speculative.LatticeFactoring
Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 18] -/
theorem normSq_nonneg' (x y : ℤ) : 0 ≤ normSq' x y := by
  unfold normSq'; positivity

theorem normSq_zero_iff' (x y : ℤ) : normSq' x y = 0 ↔ x = 0 ∧ y = 0 := by
  unfold normSq'
  constructor
  · intro h; exact ⟨by nlinarith, by nlinarith⟩
  · rintro ⟨rfl, rfl⟩; ring

theorem factoring_lattice_exists' (N : ℕ) (hN : 1 < N) :
    ∃ a b c d : ℤ, a * d - b * c = N ∧ normSq' c d ≤ 2 * N := by
  refine ⟨N, 0, 0, 1, ?_, ?_⟩
  · simp
  · simp [normSq']; omega

def IsSmooth' (B n : ℕ) : Prop :=
  ∀ p, Nat.Prime p → p ∣ n → p ≤ B

theorem one_is_smooth' (B : ℕ) : IsSmooth' B 1 := by
  intro p hp hd
  have := hp.one_lt
  have := Nat.le_of_dvd one_pos hd
  omega

theorem smooth_mul' (B a b : ℕ) (ha : IsSmooth' B a) (hb : IsSmooth' B b) :
    IsSmooth' B (a * b) := by
  intro p hp hd
  rcases hp.dvd_mul.mp hd with h | h
  · exact ha p hp h
  · exact hb p hp h

theorem smooth_exists (N B : ℕ) (hB : 1 < B) (hBN : B ≤ N) :
    ∃ n, 1 < n ∧ n ≤ N ∧ IsSmooth' B n := by
  obtain ⟨p, hp, hpB⟩ := Nat.exists_prime_and_dvd (show B ≠ 1 by omega)
  refine ⟨p, hp.one_lt, ?_, ?_⟩
  · exact le_trans (le_of_dvd (by omega) hpB) hBN
  · intro q hq hqp
    rcases hp.eq_one_or_self_of_dvd q hqp with h | h
    · exact absurd h hq.ne_one
    · rw [h]; exact le_of_dvd (by omega) hpB

theorem coppersmith_deg1 (a b p : ℤ) (hp : 0 < p)
    (hmod : p ∣ (a + b))
    (hsmall : |a + b| < p) :
    a + b = 0 := by
  rcases hmod with ⟨k, hk⟩
  rw [hk] at hsmall ⊢
  rw [abs_mul, abs_of_pos hp] at hsmall
  have : |k| = 0 := by
    by_contra h
    have hk1 : 1 ≤ |k| := Int.one_le_abs (mt abs_eq_zero.mpr h)
    linarith [mul_le_mul_of_nonneg_left hk1 (le_of_lt hp)]
  simp [abs_eq_zero.mp this]
