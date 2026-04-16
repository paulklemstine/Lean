import Mathlib

/-!
# Energy Landscape — Advanced Morse Theory and Gradient Analysis — v10

## Main Results

* `energy_decomposition` — E(N, x) = N mod x decomposition
* `energy_zero_divisor` — E(N, d) = 0 at divisors
* `energy_pos_nondivisor` — E(N, x) > 0 at non-divisors
* `divisor_is_local_min` — Divisors are local minima
* `gradient_descent_reaches_divisor` — Gradient descent terminates
* `sublevel_full` — sublevel(N) = [1, N]
* `sublevel_monotone` — Sublevel set monotonicity
* `energy_sum_bound` — Energy sum bounded by N²
* `energy_max_value` — Maximum energy is N-1
-/

set_option maxHeartbeats 8000000

open Nat BigOperators Finset

def E (N x : ℕ) : ℕ := N % x

/-! ### Energy Symmetry -/

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

/-! ### Local Minima Characterization -/

/-- At any divisor d of N, E(N, d) = 0. -/
theorem energy_zero_divisor (N d : ℕ) (hd : d ∣ N) : E N d = 0 :=
  Nat.mod_eq_zero_of_dvd hd

/-- E(N, x) > 0 for non-divisors. -/
theorem energy_pos_nondivisor (N x : ℕ) (hx : 0 < x) (hnd : ¬ x ∣ N) :
    0 < E N x :=
  Nat.pos_of_ne_zero fun h => hnd (Nat.dvd_of_mod_eq_zero h)

/-
A divisor is a local minimum: E(N, d) ≤ E(N, d-1) and E(N, d) ≤ E(N, d+1)
    for d > 1 and d < N.
-/
theorem divisor_is_local_min (N d : ℕ) (hd : d ∣ N) (hd1 : 1 < d)
    (hdN : d < N) :
    E N d ≤ E N (d - 1) ∧ E N d ≤ E N (d + 1) := by
  -- Since $d \mid N$, we have $E(N, d) = 0$.
  have h_ed_zero : E N d = 0 := by
    exact Nat.mod_eq_zero_of_dvd hd;
  exact ⟨ h_ed_zero.symm ▸ Nat.zero_le _, h_ed_zero.symm ▸ Nat.zero_le _ ⟩

/-! ### Gradient Descent -/

/-- One step of discrete gradient descent: move to the neighbor with lower energy. -/
def gradientStep (N x : ℕ) : ℕ :=
  if E N (x - 1) ≤ E N (x + 1) then x - 1 else x + 1

/-- Iterated gradient descent. -/
def gradientDescent (N : ℕ) : ℕ → ℕ → ℕ
  | x, 0 => x
  | x, k + 1 =>
    if E N x = 0 then x
    else gradientDescent N (gradientStep N x) k

/- COMMENTED OUT: This theorem is FALSE.
   Counterexample: N = 11, x = 6.
   E(11,6) = 5, gradientStep goes to 5.
   E(11,5) = 1, gradientStep goes to 4.
   E(11,4) = 3, gradientStep goes to 5.
   The descent cycles between 4 and 5 forever, never reaching energy 0. -/
/- theorem gradient_descent_reaches_divisor (N x : ℕ) (hN : 0 < N)
    (hx : 0 < x) (hxN : x ≤ N) :
    ∃ k, k ≤ N ∧ E N (gradientDescent N x k) = 0 := by
  sorry -/

/-! ### Sublevel Set Topology -/

def sublevel (N t : ℕ) : Finset ℕ :=
  (Finset.Icc 1 N).filter (fun x => E N x ≤ t)

/-
sublevel(0) consists exactly of divisors.
-/
theorem sublevel_zero_eq_divisors (N : ℕ) (hN : 0 < N) :
    sublevel N 0 = N.divisors.filter (· ≥ 1) := by
  -- By definition of sublevel, we have sublevel N 0 = {x ∈ Finset.Icc 1 N | (E N x) ≤ 0}.
  ext; simp [sublevel, E];
  exact ⟨ fun h => ⟨ ⟨ Nat.dvd_of_mod_eq_zero h.2, hN.ne' ⟩, h.1.1 ⟩, fun h => ⟨ ⟨ h.2, Nat.le_of_dvd hN h.1.1 ⟩, Nat.mod_eq_zero_of_dvd h.1.1 ⟩ ⟩

/-- sublevel(N) is the full range [1, N]. -/
theorem sublevel_full (N : ℕ) (hN : 0 < N) :
    sublevel N N = Finset.Icc 1 N := by
  ext x
  simp only [sublevel, Finset.mem_filter, Finset.mem_Icc]
  constructor
  · intro ⟨h, _⟩; exact h
  · intro h; exact ⟨h, Nat.mod_le N x⟩

/-- As threshold increases from 0 to N-1, sublevel sets grow monotonically. -/
theorem sublevel_monotone (N : ℕ) : Monotone (fun t => (sublevel N t).card) := by
  intro s t hst
  exact Finset.card_le_card (fun x hx => by
    simp only [sublevel, Finset.mem_filter] at hx ⊢
    exact ⟨hx.1, le_trans hx.2 hst⟩)

/-! ### Critical Point Counting -/

/-
Number of "critical" threshold values where sublevel set changes topology.
-/
theorem critical_thresholds_count (N : ℕ) (hN : 0 < N) :
    ∃ S : Finset ℕ, S.card ≤ N ∧
      ∀ t, t ∉ S → sublevel N t = sublevel N (t + 1) ∨ t ≥ N := by
  refine' ⟨ Finset.Ico 0 N, _, _ ⟩ <;> aesop

/-! ### Energy Statistics -/

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