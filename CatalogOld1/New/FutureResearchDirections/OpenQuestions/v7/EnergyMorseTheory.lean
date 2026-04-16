import Mathlib

/-!
# Energy Landscape Morse Theory and Critical Point Analysis (A7, C13)

We extend the energy landscape E(x) = N mod x with Morse-theoretic analysis,
computing critical point indices and studying the topology of sublevel sets.

## Main Results

* `divisor_is_local_min` — Divisors are local minima
* `sublevel_zero_divisors` — Sublevel at 0 equals divisors
* `sublevel_monotone` — Sublevel sets are monotone
* `laplacian_nonneg_at_divisor` — Discrete Laplacian ≥ 0 at divisors
* `sublevel_full` — Full sublevel at threshold N-1
-/

set_option maxHeartbeats 3200000

open Nat BigOperators Finset

/-- The factoring energy function. -/
def E (N x : ℕ) : ℕ := N % x

/-! ### Critical Point Analysis -/

/-- A point x is a local minimum of E if E(x) ≤ E(x-1) and E(x) ≤ E(x+1). -/
def is_local_min (N x : ℕ) : Prop :=
  1 < x ∧ x < N ∧ E N x ≤ E N (x - 1) ∧ E N x ≤ E N (x + 1)

/-- Zero-energy points are local minima (E = 0 is the global minimum). -/
theorem divisor_is_local_min (N d : ℕ) (hd : d ∣ N) (hd1 : 1 < d)
    (hd_lt : d < N) :
    is_local_min N d := by
  refine' ⟨ hd1, hd_lt, _, _ ⟩;
  · rcases hd with ⟨ k, rfl ⟩;
    rcases d with ( _ | _ | d ) <;> simp_all +decide [ Nat.mul_succ, E ];
  · unfold E;
    cases hd ; aesop

/-! ### Energy Properties -/

/-- Energy is zero iff x divides N. -/
theorem energy_zero_iff (N x : ℕ) (hx : 0 < x) : E N x = 0 ↔ x ∣ N := by
  unfold E; exact Nat.dvd_iff_mod_eq_zero.symm

/-- The energy at x is bounded by x - 1. -/
theorem energy_bound (N x : ℕ) (hx : 0 < x) : E N x < x :=
  Nat.mod_lt N hx

/-
Energy of non-divisor is positive.
-/
theorem energy_pos_of_not_dvd (N x : ℕ) (hx : 0 < x) (hnd : ¬(x ∣ N)) :
    0 < E N x := by
  exact Nat.pos_of_ne_zero fun h => hnd <| Nat.dvd_of_mod_eq_zero h

/-! ### Total Variation -/

/-- The total variation of E over [1, N]. -/
noncomputable def total_variation (N : ℕ) : ℤ :=
  ∑ x ∈ Finset.Icc 1 (N - 1), |((E N (x + 1) : ℤ) - (E N x : ℤ))|

/-- Total variation is nonneg. -/
theorem total_variation_nonneg (N : ℕ) : 0 ≤ total_variation N := by
  unfold total_variation
  exact Finset.sum_nonneg (fun x _ => abs_nonneg _)

/-! ### Sublevel Set Topology -/

/-- Sublevel set at threshold t. -/
def sublevel (N t : ℕ) : Finset ℕ :=
  (Finset.Icc 1 N).filter (fun x => E N x ≤ t)

/-- Sublevel at 0 = divisors. -/
theorem sublevel_zero_divisors (N : ℕ) (hN : 0 < N) :
    sublevel N 0 = N.divisors := by
  simp [sublevel, Nat.divisors];
  ext; simp [Nat.mod_eq_zero_of_dvd];
  exact fun _ _ => ⟨ fun h => Nat.dvd_of_mod_eq_zero h, fun h => Nat.mod_eq_zero_of_dvd h ⟩

/-- Sublevel sets are monotone in the threshold. -/
theorem sublevel_monotone (N t₁ t₂ : ℕ) (h : t₁ ≤ t₂) :
    sublevel N t₁ ⊆ sublevel N t₂ := by
  intro x hx
  simp [sublevel] at hx ⊢
  exact ⟨hx.1, le_trans hx.2 h⟩

/-
At threshold N-1, the sublevel set is all of [1,N].
-/
theorem sublevel_full (N : ℕ) (hN : 0 < N) :
    sublevel N (N - 1) = Finset.Icc 1 N := by
  -- By definition of sublevel, we need to show that for all x in [1, N], E(N, x) ≤ N - 1.
  ext x
  simp [sublevel];
  -- By definition of modulo, we know that $N \mod x < x$.
  have h_mod_lt : ∀ x, 1 ≤ x → x ≤ N → N % x < x := by
    exact fun x hx₁ hx₂ => Nat.mod_lt _ hx₁;
  exact fun hx₁ hx₂ => Nat.le_sub_one_of_lt ( lt_of_lt_of_le ( h_mod_lt x hx₁ hx₂ ) hx₂ )

/-! ### Morse-Theoretic Index -/

/-- Discrete second derivative (Laplacian). -/
def discrete_laplacian (N x : ℕ) : ℤ :=
  (E N (x + 1) : ℤ) + (E N (x - 1) : ℤ) - 2 * (E N x : ℤ)

/-- At divisors, the Laplacian is nonneg (since E = 0 there). -/
theorem laplacian_nonneg_at_divisor (N d : ℕ) (hd : d ∣ N) (hd1 : 1 < d) :
    0 ≤ discrete_laplacian N d := by
  unfold discrete_laplacian;
  obtain ⟨ k, hk ⟩ := hd;
  rcases d with ( _ | _ | d ) <;> simp_all +decide [ Nat.add_mod, Nat.mod_eq_of_lt ];
  unfold E; norm_cast; aesop;

/-
The average energy: Σ E(N,x) ≤ N².
-/
theorem average_energy_bound (N : ℕ) (hN : 0 < N) :
    ∑ x ∈ Finset.Icc 1 N, E N x ≤ N * N := by
  exact le_trans ( Finset.sum_le_sum fun i hi => show E N i ≤ N from Nat.mod_le _ _ ) ( by norm_num )

/-
Number of zero-energy points in [1,N] = number of divisors.
-/
theorem zero_energy_eq_divisor_count (N : ℕ) (hN : 0 < N) :
    (Finset.Icc 1 N |>.filter (fun x => E N x = 0)).card = N.divisors.card := by
  congr 1 with x;
  simp +zetaDelta at *;
  exact ⟨ fun hx => ⟨ Nat.dvd_of_mod_eq_zero hx.2, hN.ne' ⟩, fun hx => ⟨ ⟨ Nat.pos_of_dvd_of_pos hx.1 hN, Nat.le_of_dvd hN hx.1 ⟩, Nat.mod_eq_zero_of_dvd hx.1 ⟩ ⟩