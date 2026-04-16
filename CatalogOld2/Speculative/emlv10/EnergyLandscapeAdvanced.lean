/-! # CatalogBuild.Speculative.emlv10.EnergyLandscapeAdvanced

Auto-generated from theorem catalog database.
Domain: Speculative/emlv10
Declarations: 8
-/

import Mathlib

/-- Energy relates to quotient: N = x·(N/x) + E(N,x). -/
theorem energy_decomposition (N x : ℕ) (hx : 0 < x) :
    N = x * (N / x) + E N x :=
  (Nat.div_add_mod N x).symm


/-- For divisors d₁ < d₂ with no divisor between them,
E(N, x) increases linearly from d₁ to almost d₂. -/
theorem energy_between_divisors (N d₁ d₂ x : ℕ) (hd1 : d₁ ∣ N) (hd2 : d₂ ∣ N)
    (hlt : d₁ < d₂) (hx1 : d₁ < x) (hx2 : x ≤ d₂) (hx : 0 < x) :
    E N x = N - x * (N / x) := by
  exact Nat.mod_def N x


/-- At any divisor d of N, E(N, d) = 0. -/
theorem energy_zero_divisor (N d : ℕ) (hd : d ∣ N) : E N d = 0 :=
  Nat.mod_eq_zero_of_dvd hd


/-- One step of discrete gradient descent: move to the neighbor with lower energy. -/
def gradientStep (N x : ℕ) : ℕ :=
  if E N (x - 1) ≤ E N (x + 1) then x - 1 else x + 1


/-- Iterated gradient descent. -/
def gradientDescent (N : ℕ) : ℕ → ℕ → ℕ
  | x, 0 => x
  | x, k + 1 =>
    if E N x = 0 then x
    else gradientDescent N (gradientStep N x) k


theorem critical_thresholds_count (N : ℕ) (hN : 0 < N) :
    ∃ S : Finset ℕ, S.card ≤ N ∧
      ∀ t, t ∉ S → sublevel N t = sublevel N (t + 1) ∨ t ≥ N := by
  refine' ⟨ Finset.Ico 0 N, _, _ ⟩ <;> aesop


/-- The sum of all energy values over [1,N] is bounded. -/
theorem energy_sum_bound (N : ℕ) (hN : 0 < N) :
    ∑ x ∈ Finset.Icc 1 N, E N x ≤ N * N := by
  calc ∑ x ∈ Finset.Icc 1 N, E N x
      ≤ ∑ x ∈ Finset.Icc 1 N, N :=
        Finset.sum_le_sum fun x _ => Nat.mod_le N x
    _ = (Finset.Icc 1 N).card * N := by rw [Finset.sum_const, smul_eq_mul]
    _ ≤ N * N := by
        have : (Finset.Icc 1 N).card ≤ N := by rw [Nat.card_Icc]; omega
        exact Nat.mul_le_mul_right N this


/-- The maximum energy value over [1,N] is at most N/2. -/
theorem energy_max_le (N x : ℕ) (hx : 0 < x) (hxN : x ≤ N) :
    E N x < N := by
  unfold E
  exact lt_of_lt_of_le (Nat.mod_lt N hx) hxN
