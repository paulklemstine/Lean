/-! # CatalogBuild.Speculative.EnergyMorseTheory

Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 10
-/

import Mathlib

noncomputable section

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


/-- The energy at x is bounded by x - 1. -/
theorem energy_bound (N x : ℕ) (hx : 0 < x) : E N x < x :=
  Nat.mod_lt N hx


/-- [Section: ### Energy Properties] -/
theorem energy_pos_of_not_dvd (N x : ℕ) (hx : 0 < x) (hnd : ¬(x ∣ N)) :
    0 < E N x := by
  exact Nat.pos_of_ne_zero fun h => hnd <| Nat.dvd_of_mod_eq_zero h


/-- The total variation of E over [1, N]. -/
noncomputable def total_variation (N : ℕ) : ℤ :=
  ∑ x ∈ Finset.Icc 1 (N - 1), |((E N (x + 1) : ℤ) - (E N x : ℤ))|


/-- Total variation is nonneg. -/
theorem total_variation_nonneg (N : ℕ) : 0 ≤ total_variation N := by
  unfold total_variation
  exact Finset.sum_nonneg (fun x _ => abs_nonneg _)


/-- Sublevel at 0 = divisors. -/
theorem sublevel_zero_divisors (N : ℕ) (hN : 0 < N) :
    sublevel N 0 = N.divisors := by
  simp [sublevel, Nat.divisors];
  ext; simp [Nat.mod_eq_zero_of_dvd];
  exact fun _ _ => ⟨ fun h => Nat.dvd_of_mod_eq_zero h, fun h => Nat.mod_eq_zero_of_dvd h ⟩


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


theorem zero_energy_eq_divisor_count (N : ℕ) (hN : 0 < N) :
    (Finset.Icc 1 N |>.filter (fun x => E N x = 0)).card = N.divisors.card := by
  congr 1 with x;
  simp +zetaDelta at *;
  exact ⟨ fun hx => ⟨ Nat.dvd_of_mod_eq_zero hx.2, hN.ne' ⟩, fun hx => ⟨ ⟨ Nat.pos_of_dvd_of_pos hx.1 hN, Nat.le_of_dvd hN hx.1 ⟩, Nat.mod_eq_zero_of_dvd hx.1 ⟩ ⟩

end
