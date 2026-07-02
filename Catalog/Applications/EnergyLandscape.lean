import Mathlib
import Catalog.Shared.E
import Catalog.Shared.Sublevel

/-! # CatalogBuild.Speculative.EnergyLandscape

Unified from EnergyLandscapeAdvanced, EnergyLandscapeAdvanced_2,
EnergyLandscapeMorse, and EnergyMorseTheory.
The factoring energy function E(N,x) = N mod x and its Morse-theoretic structure.
-/}

-- ---------------------------------------------------------------------------
-- Basic energy properties
-- ---------------------------------------------------------------------------

/-- Energy is zero iff x divides N. -/
theorem energy_zero_iff (N x : ℕ) (hx : 0 < x) : E N x = 0 ↔ x ∣ N := by
  unfold E; exact Nat.dvd_iff_mod_eq_zero.symm

/-- Energy is strictly less than x. -/
theorem energy_lt (N x : ℕ) (hx : 0 < x) : E N x < x :=
  Nat.mod_lt N hx

/-- Energy is strictly positive at non-divisors. -/
theorem energy_pos_of_not_dvd (N x : ℕ) (hx : 0 < x) (hnd : ¬(x ∣ N)) :
    0 < E N x := by
  exact Nat.pos_of_ne_zero fun h => hnd (Nat.dvd_of_mod_eq_zero h)

/-- Energy predecessor value: E(N, N-1) = 1 for N > 2. -/
theorem energy_predecessor (N : ℕ) (hN : 2 < N) : E N (N - 1) = 1 := by
  rcases N with (_ | _ | _ | _ | _ | N) <;> simp_all +arith +decide [E]
  norm_num [(by ring : N + 5 = N + 4 + 1)]

/-- Energy at x = 2 classifies parity. -/
theorem energy_parity (N : ℕ) : E N 2 = N % 2 := by rfl

-- ---------------------------------------------------------------------------
-- Divisor counting via zero-energy points
-- ---------------------------------------------------------------------------

/-- A prime has exactly two zero-energy points (its divisors). -/
theorem prime_two_zeros (N : ℕ) (hN : Nat.Prime N) :
    (Finset.Icc 1 N |>.filter (fun x => E N x = 0)).card = 2 := by
  convert sublevel_zero_card_eq_tau N hN.pos using 1
  rw [hN.divisors, Finset.card_insert_of_notMem] <;> aesop

/-- A semiprime has exactly four zero-energy points. -/
theorem semiprime_minima_count (p q : ℕ) (hp : Nat.Prime p) (hq : Nat.Prime q)
    (hpq : p ≠ q) :
    (Finset.Icc 1 (p * q) |>.filter (fun x => E (p * q) x = 0)).card = 4 := by
  convert sublevel_zero_card_eq_tau (p * q) (Nat.mul_pos hp.pos hq.pos) using 1
  have h_divisors : (p * q).divisors = {1, p, q, p * q} := by
    rw [Nat.divisors_mul, hp.divisors, hq.divisors]
    simpa [Finset.ext_iff, Finset.mem_mul] using by tauto
  rw [h_divisors, Finset.card_insert_of_notMem, Finset.card_insert_of_notMem,
    Finset.card_insert_of_notMem]
  <;> norm_num [hp.ne_zero, hq.ne_zero, hp.ne_one, hq.ne_one, hpq]
  exact ⟨Ne.symm hp.ne_one, Ne.symm hq.ne_one,
    Nat.ne_of_lt (one_lt_mul'' hp.one_lt hq.one_lt)⟩

-- ---------------------------------------------------------------------------
-- Energy bounds
-- ---------------------------------------------------------------------------

/-- The total energy sum over [1, N] is at most N². -/
theorem total_energy_bound (N : ℕ) (hN : 0 < N) :
    ∑ x ∈ Finset.Icc 1 N, E N x ≤ N * N := by
  calc ∑ x ∈ Finset.Icc 1 N, E N x
      ≤ ∑ x ∈ Finset.Icc 1 N, x := by
        exact Finset.sum_le_sum fun x _ => Nat.le_of_lt (Nat.mod_lt _ (by omega))
    _ ≤ ∑ x ∈ Finset.Icc 1 N, N := by
        exact Finset.sum_le_sum fun x hx => (Finset.mem_Icc.mp hx).2
    _ = (Finset.Icc 1 N).card * N := by rw [Finset.sum_const, smul_eq_mul]
    _ ≤ N * N := by
        have : (Finset.Icc 1 N).card ≤ N := by rw [Nat.card_Icc]; omega
        exact Nat.mul_le_mul_right N this

/-- Average energy is bounded by N²/2. -/
theorem average_energy_bound (N : ℕ) (hN : 1 ≤ N) :
    2 * (∑ x ∈ Finset.Icc 1 N, E N x) ≤ N * N * N := by
  induction hN <;> norm_num [Finset.sum_Ioc_succ_top,
    (Nat.succ_eq_succ ▸ Finset.Icc_succ_left_eq_Ioc)] at *
  · native_decide +revert
  · unfold E at *
    norm_num [Nat.mod_eq_of_lt]
    exact le_trans (mul_le_mul_of_nonneg_left
      (Finset.sum_le_sum fun _ _ => Nat.mod_le _ _) zero_le_two)
      (by norm_num [Finset.sum_add_distrib]; nlinarith)

/-- The maximum energy between 1 and N is at most N - 1. -/
theorem energy_max_bound (N x : ℕ) (hN : 0 < N) (hx : 0 < x) (hxN : x ≤ N) :
    E N x ≤ N - 1 := by
  unfold E
  have := Nat.mod_lt N hx
  omega

/-- Between two divisors there exists a point of maximal energy. -/
theorem energy_max_between_divisors (N d₁ d₂ : ℕ) (hlt : d₁ < d₂) :
    ∃ x, d₁ ≤ x ∧ x ≤ d₂ ∧ ∀ y, d₁ ≤ y → y ≤ d₂ → E N y ≤ E N x := by
  have hne : (Finset.Icc d₁ d₂).Nonempty :=
    ⟨d₁, Finset.mem_Icc.mpr ⟨le_refl _, le_of_lt hlt⟩⟩
  obtain ⟨x, hx_mem, hx_max⟩ := Finset.exists_max_image _ (E N) hne
  exact ⟨x, (Finset.mem_Icc.mp hx_mem).1, (Finset.mem_Icc.mp hx_mem).2,
    fun y hy1 hy2 => hx_max y (Finset.mem_Icc.mpr ⟨hy1, hy2⟩)⟩

-- ---------------------------------------------------------------------------
-- Discrete differential structure (Morse theory)
-- ---------------------------------------------------------------------------

/-- The energy gradient: ΔE(x) = E(x+1) - E(x). -/
def energy_gradient (N x : ℕ) : ℤ := (E N (x + 1) : ℤ) - (E N x : ℤ)

/-- The discrete Laplacian (second difference) of the energy. -/
def energy_laplacian (N x : ℕ) : ℤ :=
  (E N (x + 2) : ℤ) - 2 * (E N (x + 1) : ℤ) + (E N x : ℤ)

/-- At a divisor d, the forward difference drops to the minimum. -/
theorem energy_drops_at_divisor (N d : ℕ) (hd : d ∣ N) (hd1 : 1 < d) :
    (E N d : ℤ) ≤ (E N (d - 1) : ℤ) := by
  rw [Nat.mod_eq_zero_of_dvd hd]
  exact Int.ofNat_nonneg _

/-- A point x is a local minimum of E if E(x) ≤ E(x-1) and E(x) ≤ E(x+1). -/
def is_local_min (N x : ℕ) : Prop :=
  1 < x ∧ x < N ∧ E N x ≤ E N (x - 1) ∧ E N x ≤ E N (x + 1)

/-- Zero-energy points are local minima (E = 0 is the global minimum). -/
theorem divisor_is_local_min (N d : ℕ) (hd : d ∣ N) (hd1 : 1 < d)
    (hd_lt : d < N) :
    is_local_min N d := by
  refine' ⟨hd1, hd_lt, _, _⟩
  · rcases hd with ⟨k, rfl⟩
    rcases d with (_ | _ | d) <;> simp_all +decide [Nat.mul_succ, E]
  · unfold E
    cases hd; aesop

/-- The total variation of E over [1, N]. -/
noncomputable def total_variation (N : ℕ) : ℤ :=
  ∑ x ∈ Finset.Icc 1 (N - 1), |((E N (x + 1) : ℤ) - (E N x : ℤ))|

/-- Total variation is nonnegative. -/
theorem total_variation_nonneg (N : ℕ) : 0 ≤ total_variation N := by
  unfold total_variation
  exact Finset.sum_nonneg (fun x _ => abs_nonneg _)

/-- At divisors, the Laplacian is nonnegative (since E = 0 there). -/
theorem laplacian_nonneg_at_divisor (N d : ℕ) (hd : d ∣ N) (hd1 : 1 < d) :
    0 ≤ energy_laplacian N d := by
  unfold energy_laplacian
  obtain ⟨k, hk⟩ := hd
  rcases d with (_ | _ | d) <;> simp_all +decide [Nat.add_mod, Nat.mod_eq_of_lt]
  unfold E; norm_cast; aesop