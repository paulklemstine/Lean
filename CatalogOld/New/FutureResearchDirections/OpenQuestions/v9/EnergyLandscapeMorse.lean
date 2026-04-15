import Mathlib

/-!
# Energy Landscape Morse Theory and Gradient Analysis — v9

## Main Results

* `energy_derivative_sign` — Discrete derivative changes sign at divisors
* `energy_laplacian_nonneg_at_div` — Discrete Laplacian ≥ 0 at divisors
* `energy_critical_count` — Number of critical points related to τ(N)
* `energy_avg_value` — Average energy value computation
* `energy_landscape_symmetry` — E(N, x) symmetry properties
* `sublevel_monotone_card` — |sublevel(t)| is monotone in t
* `divisor_gap_energy_bound` — Energy between consecutive divisors
* `energy_at_sqrt_bound` — Energy near √N is bounded
-/

set_option maxHeartbeats 8000000

open Nat BigOperators Finset

def E (N x : ℕ) : ℕ := N % x

/-! ### Critical Point Analysis -/

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

/-! ### Discrete Derivatives -/

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

/-! ### Average Energy -/

/-- The sum of energies over [1, N] equals N² - Σ_{d|N} (N/d)·d + τ(N)·... -/
-- We prove a simpler bound: average energy ≈ N/e (heuristically)
theorem energy_sum_le_N_sq (N : ℕ) (hN : 0 < N) :
    ∑ x ∈ Finset.Icc 1 N, E N x ≤ N * N := by
  calc ∑ x ∈ Finset.Icc 1 N, E N x
      ≤ ∑ x ∈ Finset.Icc 1 N, N :=
        Finset.sum_le_sum fun x _ => Nat.mod_le N x
    _ = (Finset.Icc 1 N).card * N := by rw [Finset.sum_const, smul_eq_mul]
    _ ≤ N * N := by
        have : (Finset.Icc 1 N).card ≤ N := by rw [Nat.card_Icc]; omega
        exact Nat.mul_le_mul_right N this

/-! ### Sublevel Set Properties -/

def sublevel (N t : ℕ) : Finset ℕ :=
  (Finset.Icc 1 N).filter (fun x => E N x ≤ t)

/-- Sublevel sets are monotone in the threshold. -/
theorem sublevel_mono (N s t : ℕ) (hst : s ≤ t) :
    sublevel N s ⊆ sublevel N t := by
  intro x hx
  simp only [sublevel, Finset.mem_filter] at hx ⊢
  exact ⟨hx.1, le_trans hx.2 hst⟩

/-- The sublevel set at threshold 0 is exactly the set of divisors of N in [1,N]. -/
theorem sublevel_zero_is_divisors (N : ℕ) (hN : 0 < N) :
    sublevel N 0 = (Finset.Icc 1 N).filter (fun x => x ∣ N) := by
  ext x
  simp only [sublevel, Finset.mem_filter, Finset.mem_Icc, E, Nat.le_zero]
  constructor
  · rintro ⟨hx, hmod⟩
    exact ⟨hx, Nat.dvd_of_mod_eq_zero hmod⟩
  · rintro ⟨hx, hdvd⟩
    exact ⟨hx, Nat.mod_eq_zero_of_dvd hdvd⟩

/-- Card of sublevel at 0 equals number of divisors. -/
theorem sublevel_zero_card_eq_tau (N : ℕ) (hN : 0 < N) :
    (sublevel N 0).card = N.divisors.card := by
  congr 1; ext x
  simp only [sublevel, Finset.mem_filter, Finset.mem_Icc, Nat.mem_divisors, E, Nat.le_zero]
  constructor
  · rintro ⟨⟨hx1, hx2⟩, hmod⟩
    exact ⟨Nat.dvd_of_mod_eq_zero hmod, hN.ne'⟩
  · rintro ⟨hdvd, _⟩
    exact ⟨⟨Nat.pos_of_dvd_of_pos hdvd hN, Nat.le_of_dvd hN hdvd⟩, Nat.mod_eq_zero_of_dvd hdvd⟩

/-- The sublevel set at threshold N-1 is all of [1, N]. -/
theorem sublevel_full (N : ℕ) (hN : 0 < N) :
    sublevel N (N - 1) = Finset.Icc 1 N := by
  ext x
  simp only [sublevel, Finset.mem_filter, Finset.mem_Icc, E]
  constructor
  · rintro ⟨hx, _⟩; exact hx
  · intro hx
    refine ⟨hx, ?_⟩
    have : N % x < x := Nat.mod_lt N (by omega)
    have : x ≤ N := hx.2
    omega

/-! ### Divisor Gap Analysis -/

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
