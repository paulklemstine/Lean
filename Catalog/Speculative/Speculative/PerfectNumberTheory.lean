import Mathlib

/-! # CatalogBuild.Speculative.PerfectNumberTheory

Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 6
-/

/-- [Section: # CatalogBuild.Speculative.PerfectNumberTheory
Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 6] -/
theorem sigma1_pow_two (n : ℕ) : σ₁ (2 ^ n) = 2 ^ (n + 1) - 1 := by
  unfold σ₁; simp +decide [ Nat.geomSum_eq ] ;

/-- [Section: # CatalogBuild.Speculative.PerfectNumberTheory
Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 6] -/
theorem sigma1_mersenne_prime (p : ℕ) (hp : Nat.Prime (2 ^ p - 1)) (hp2 : 1 ≤ p) :
    σ₁ (2 ^ p - 1) = 2 ^ p := by
  unfold σ₁; simp +decide [ *, Nat.sum_divisors_eq_sum_properDivisors_add_self ] ;
  rw [ Nat.sub_add_cancel ( Nat.one_le_pow _ _ ( by decide ) ) ]

theorem sigma1_gt (n : ℕ) (hn : 1 < n) : n < σ₁ n := by
  unfold σ₁; rw [ Finset.sum_eq_sum_diff_singleton_add ( Nat.mem_divisors_self n hn.ne_bot ) ] ; linarith [ Finset.single_le_sum ( fun x ( hx : x ∈ n.divisors \ { n } ) ↦ Nat.zero_le x ) ( Finset.mem_sdiff.mpr ⟨ Nat.mem_divisors.mpr ⟨ one_dvd n, by linarith ⟩, by aesop ⟩ : 1 ∈ n.divisors \ { n } ) ] ;

theorem sigma1_ge_succ (n : ℕ) (hn : 1 < n) : n + 1 ≤ σ₁ n := by
  exact Nat.succ_le_of_lt ( sigma1_gt n hn )

theorem twelve_abundant : 2 * 12 < σ₁ 12 := by
  decide +kernel

theorem sigma1_monotone_dvd (m n : ℕ) (hm : 0 < m) (hn : 0 < n) :
    σ₁ m ≤ σ₁ (m * n) := by
  exact Finset.sum_le_sum_of_subset ( fun x hx => Nat.mem_divisors.mpr ⟨ dvd_mul_of_dvd_left ( Nat.dvd_of_mem_divisors hx ) _, by positivity ⟩ )

