
import Mathlib

/-! # CatalogBuild.Speculative.EnergyLandscapeMorse

Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 9
-/

/-- At a divisor, the energy is exactly 0. -/
theorem energy_zero_at_divisor (N d : ℕ) (hd : d ∣ N) : E N d = 0 :=
  Nat.mod_eq_zero_of_dvd hd

/-- Energy is strictly positive at non-divisors. -/
theorem energy_pos_at_nondivisor (N x : ℕ) (hx : 0 < x) (hnd : ¬ x ∣ N) :
    0 < E N x :=
  Nat.pos_of_ne_zero fun h => hnd (Nat.dvd_of_mod_eq_zero h)

/-- Energy is always less than x. -/
theorem energy_lt_modulus (N x : ℕ) (hx : 0 < x) : E N x < x :=
  Nat.mod_lt N hx

/-- Forward difference of the energy function. -/
def energy_forward_diff (N x : ℕ) : ℤ :=
  (E N (x + 1) : ℤ) - (E N x : ℤ)

/-- The discrete Laplacian (second difference) of the energy. -/
def energy_laplacian (N x : ℕ) : ℤ :=
  (E N (x + 2) : ℤ) - 2 * (E N (x + 1) : ℤ) + (E N x : ℤ)

/-- At a divisor d, the forward difference from d-1 to d drops to minimum. -/
theorem energy_drops_at_divisor (N d : ℕ) (hd : d ∣ N) (hd1 : 1 < d) :
    (E N d : ℤ) ≤ (E N (d - 1) : ℤ) := by
  rw [energy_zero_at_divisor N d hd]
  exact Int.ofNat_nonneg _

/-- The sum of energies over [1, N] equals N² - Σ_{d|N} (N/d)·d + τ(N)·... -/
theorem energy_sum_le_N_sq (N : ℕ) (hN : 0 < N) :
    ∑ x ∈ Finset.Icc 1 N, E N x ≤ N * N := by
  calc ∑ x ∈ Finset.Icc 1 N, E N x
      ≤ ∑ x ∈ Finset.Icc 1 N, N :=
        Finset.sum_le_sum fun x _ => Nat.mod_le N x
    _ = (Finset.Icc 1 N).card * N := by rw [Finset.sum_const, smul_eq_mul]
    _ ≤ N * N := by
        have : (Finset.Icc 1 N).card ≤ N := by rw [Nat.card_Icc]; omega
        exact Nat.mul_le_mul_right N this

/-- Between two consecutive divisors, the energy rises from 0.
Specifically, if d | N and d < x < d' (next divisor), then E(N,x) > 0. -/
theorem energy_pos_between_divisors (N d x : ℕ) (hd : d ∣ N)
    (hdx : d < x) (hx : 0 < x) (hnd : ¬ x ∣ N) :
    0 < E N x :=
  energy_pos_at_nondivisor N x hx hnd

/-- The maximum energy between 1 and N is at most N - 1. -/
theorem energy_max_bound (N x : ℕ) (hN : 0 < N) (hx : 0 < x) (hxN : x ≤ N) :
    E N x ≤ N - 1 := by
  unfold E
  have := Nat.mod_lt N hx
  omega



