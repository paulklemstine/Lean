import Mathlib

/-! # CatalogBuild.Speculative.CrossCollisionTheory

Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 16
-/

/-- d² - x² = (d-x)(d+x). -/
theorem peel_channel (d x : ℤ) :
    d ^ 2 - x ^ 2 = (d - x) * (d + x) := by ring

/-- If N | d, then gcd(d - x, N) = gcd(x, N). -/
theorem peel_gcd_simplification (d x N : ℤ) (hd : N ∣ d) :
    Int.gcd (d - x) N = Int.gcd x N := by
  obtain ⟨m, rfl⟩ := hd
  rw [show N * m - x = -x + m * N by ring]
  rw [Int.gcd_add_mul_right_left, Int.neg_gcd]

/-- x² - y² = (x-y)(x+y). -/
theorem cross_collision_identity (x y : ℤ) :
    x ^ 2 - y ^ 2 = (x - y) * (x + y) := by ring

/-- gcd(x - y, N) always divides N. -/
theorem cross_collision_factor_attempt (x y N : ℤ) :
    ↑(Int.gcd (x - y) N) ∣ N := Int.gcd_dvd_right _ _

/-- If p | N and p | (x - y), then p | gcd(x - y, N). -/
theorem cross_collision_reveals_factor (p x y N : ℤ)
    (hpN : p ∣ N) (hpxy : p ∣ (x - y)) :
    p ∣ ↑(Int.gcd (x - y) N) :=
  Int.dvd_coe_gcd hpxy hpN

/-- C(k,2) = k(k-1)/2. -/
theorem cross_collision_channel_count (k : ℕ) :
    Nat.choose k 2 = k * (k - 1) / 2 :=
  Nat.choose_two_right k

/-- 2 * (k + C(k,2)) = k(k+1). -/
theorem total_channel_formula (k : ℕ) (hk : 0 < k) :
    2 * (k + Nat.choose k 2) = k * (k + 1) := by
  rcases k with _ | n
  · omega
  · rw [Nat.choose_two_right, Nat.succ_sub_one]
    have h : 2 ∣ (n + 1) * n := by
      rcases n.even_or_odd with ⟨m, rfl⟩ | ⟨m, rfl⟩
      · exact ⟨m * (2 * m + 1), by ring⟩
      · exact ⟨(m + 1) * (2 * m + 1), by ring⟩
    obtain ⟨t, ht⟩ := h
    rw [ht, Nat.mul_div_cancel_left _ (by norm_num : 0 < 2)]
    nlinarith [ht]

/-- #{x ∈ [1, pq] : p|x or q|x} = p + q - 1. -/
theorem density_count (p q : ℕ) (hp : 0 < p) (hq : 0 < q) :
    p * q / p + p * q / q - p * q / (p * q) = q + p - 1 := by
  rw [Nat.mul_div_cancel_left _ hp, Nat.mul_div_cancel _ hq,
      Nat.div_self (Nat.mul_pos hp hq)]

/-- For balanced semiprimes, 2·min(p,q) - 1 ≤ p + q - 1. -/
theorem balanced_density_lower (p q : ℕ) (hp : 2 ≤ p) (hq : 2 ≤ q) :
    2 * min p q - 1 ≤ p + q - 1 := by omega

/-- [Section: # CatalogBuild.Speculative.CrossCollisionTheory
Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 16] -/
theorem gcd_cascade_terminates (N g : ℕ) (hN : 1 < N)
    (hg : g ∣ N) (hg1 : 1 < g) (_ : g < N) :
    N / g < N := Nat.div_lt_self (by omega) hg1

/-- [Section: # CatalogBuild.Speculative.CrossCollisionTheory
Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 16] -/
theorem single_success_suffices (N g : ℕ) (hN : 1 < N) (hg : g ∣ N)
    (hg1 : 1 < g) (_ : g < N) :
    ∃ p q : ℕ, N = p * q ∧ 1 < p ∧ 1 < q :=
  ⟨g, N / g, by rw [Nat.mul_div_cancel' hg], hg1, by
    have := Nat.div_pos (Nat.le_of_dvd (by omega) hg) (by omega)
    nlinarith [Nat.div_mul_cancel hg]⟩

theorem peel_product_eq (d x : ℤ) :
    (d - x) * (d + x) = d ^ 2 - x ^ 2 := by ring

theorem congruence_from_peels (d₁ x₁ d₂ x₂ y : ℤ)
    (h : (d₁ - x₁) * (d₁ + x₁) * ((d₂ - x₂) * (d₂ + x₂)) = y ^ 2) :
    (d₁ ^ 2 - x₁ ^ 2) * (d₂ ^ 2 - x₂ ^ 2) = y ^ 2 := by
  nlinarith [sq_nonneg (d₁ - x₁)]

theorem short_vector_gcd (N x m : ℤ) :
    Int.gcd (m * N - x) N = Int.gcd x N := by
  rw [show m * N - x = -x + m * N by ring]
  rw [Int.gcd_add_mul_right_left, Int.neg_gcd]

theorem union_bound_channels (k : ℕ) :
    k ≤ k + Nat.choose k 2 := Nat.le_add_right k _

theorem more_reps_more_chances (r₁ r₂ k : ℕ) (h : r₁ ≤ r₂) :
    r₁ * k ≤ r₂ * k := Nat.mul_le_mul_right k h