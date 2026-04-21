/-! # CatalogBuild.Computation.Factoring.IOFSpeedup

Auto-generated from theorem catalog database.
Domain: Computation/Factoring
Declarations: 10
-/

import Mathlib

/-- The product of consecutive odd legs in the descent.
Computing GCD(∏ a_k, N) in one shot finds factors if any a_k shares a factor with N. -/
def leg_product (N : ℤ) (start len : ℕ) : ℤ :=
  (Finset.range len).prod (fun i => N - 2 * (↑start + ↑i))




/-- If any term in the product shares a factor p with N,
then the product also shares that factor. -/
theorem factor_in_product (N : ℤ) (p : ℤ) (start len : ℕ) (j : ℕ)
    (hj : j < len) (hdvd : p ∣ (N - 2 * (↑start + ↑j))) :
    p ∣ leg_product N start len := by
  exact dvd_trans hdvd (Finset.dvd_prod_of_mem _ (Finset.mem_range.mpr hj))




/-- The product of even legs (b_k values) in a batch. Since b_k = ((N-2k)² - 1)/2,
and p | b_k at the factor step, the product of b_k values will share factor p with N.
We use the squared-minus-one formulation to avoid integer division issues. -/
def bleg_product (N : ℤ) (start len : ℕ) : ℤ :=
  (Finset.range len).prod (fun i => (N - 2 * (↑start + ↑i)) ^ 2 - 1)




/-- [Section: # CatalogBuild.Computation.Factoring.IOFSpeedup
Auto-generated from theorem catalog database.
Domain: Computation/Factoring
Declarations: 10] -/
theorem factor_step_divides_bleg (p q : ℕ) (hp : Nat.Prime p) (hq : Nat.Prime q)
    (hp2 : p ≠ 2) (hq2 : q ≠ 2) (hle : p ≤ q) :
    (↑p : ℤ) ∣ (↑(p * q) - 2 * ↑((p - 1) / 2)) ^ 2 - 1 := by
      cases Nat.Prime.eq_two_or_odd hp <;> simp_all +decide [ Nat.mul_div_cancel' ];
      -- Since $p$ is odd, we can simplify the expression $(p * q - 2 * ((p - 1) / 2)) ^ 2 - 1$ to $(p * q - p + 1) ^ 2 - 1$.
      have h_simp : (p * q - 2 * ((p - 1) / 2) : ℤ) = p * q - p + 1 := by
        omega;
      norm_num [ Nat.cast_sub hp.pos, h_simp ];
      norm_num [ ← ZMod.intCast_zmod_eq_zero_iff_dvd ]




/-- The energy at a jumped position. Jumping by Δ steps at once. -/
def energy_at (N : ℤ) (k : ℕ) : ℤ := (N - 2 * k) ^ 2




/-- Energy is monotonically decreasing: if j < k (and both are below the
midpoint), then energy at j exceeds energy at k.
This means we can safely jump ahead without missing the minimum. -/
theorem energy_monotone_decreasing (N : ℕ) (j k : ℕ)
    (hjk : j < k) (hk : 2 * k < N) :
    energy_at (↑N) k < energy_at (↑N) j := by
  unfold energy_at; nlinarith

-- The BSGS strategy: jump by stride Δ, find the interval [iΔ, (i+1)Δ)
-- that contains the factor step, then search within that interval.
-- Total GCD operations: O(N/(pΔ)) + O(Δ) = O(√N/Δ + Δ).
-- Optimal at Δ = N^(1/4), giving O(N^(1/4)) GCD operations.




/-- A factor step lies in exactly one stride interval. -/
theorem factor_in_unique_interval (p : ℕ) (hp : 2 < p) (stride : ℕ) (hs : 0 < stride) :
    ∃ i : ℕ, i * stride ≤ (p - 1) / 2 ∧ (p - 1) / 2 < (i + 1) * stride := by
  exact ⟨(p - 1) / 2 / stride, Nat.div_mul_le_self _ _,
    by linarith [Nat.div_add_mod ((p - 1) / 2) stride, Nat.mod_lt ((p - 1) / 2) hs]⟩




/-- The energy drop between consecutive steps is linear in k.
E(k) - E(k+1) = (N-2k)² - (N-2k-2)² = 4(N-2k) - 4.
This means the energy drops faster at earlier steps and slower at later steps. -/
theorem energy_drop_formula (N : ℤ) (k : ℕ) :
    energy_at N k - energy_at N (k + 1) = 4 * (N - 2 * ↑k) - 4 := by
  unfold energy_at; push_cast; ring




/-- The cumulative energy dissipated after K steps. -/
theorem cumulative_energy_drop (N : ℤ) (K : ℕ) :
    energy_at N 0 - energy_at N K = 4 * N * ↑K - 4 * (↑K : ℤ) ^ 2 := by
  unfold energy_at; ring




/-- [Section: # CatalogBuild.Computation.Factoring.IOFSpeedup
Auto-generated from theorem catalog database.
Domain: Computation/Factoring
Declarations: 10] -/
theorem factor_square_condition (N p : ℕ) (k : ℕ) (hp : Nat.Prime p) (hdvd : p ∣ N)
    (hp2 : p ≠ 2) :
    (↑p : ℤ) ∣ ((↑N - 2 * ↑k) ^ 2 - 1) →
    ((↑N : ℤ) - 2 * ↑k) % (↑p : ℤ) = 1 ∨ ((↑N : ℤ) - 2 * ↑k) % (↑p : ℤ) = (↑p : ℤ) - 1 := by
      intro h;
      haveI := Fact.mk hp;
      simp_all +decide [ ← ZMod.intCast_zmod_eq_zero_iff_dvd, sub_eq_iff_eq_add ];
      rcases h with ( h | h ) <;> rw [ ← ZMod.val_intCast ] <;> simp_all +decide [ sub_eq_iff_eq_add ];
      · rcases p with ( _ | _ | p ) <;> norm_cast;
        exact Or.inl rfl;
      · norm_num [ ZMod.cast, ZMod.val ];
        rcases p with ( _ | _ | p ) <;> norm_num at *;
        erw [ Fin.val_mk ] ; norm_num



