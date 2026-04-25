/-! # CatalogBuild.Speculative.EulerDirectionComplete

Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 8
-/

import Mathlib

noncomputable section

/-- [Section: # CatalogBuild.Speculative.EulerDirectionComplete
Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 10] -/
noncomputable def σ₁' (n : ℕ) : ℕ := ∑ d ∈ n.divisors, d


/-- [Section: # CatalogBuild.Speculative.EulerDirectionComplete
Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 10] -/
theorem mersenne_prime_exponent_prime (n : ℕ) (hn : 1 < n)
    (hm : Nat.Prime (2 ^ n - 1)) : Nat.Prime n := by
  exact?


/-- [Section: # CatalogBuild.Speculative.EulerDirectionComplete
Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 8] -/
theorem sigma1'_prime (p : ℕ) (hp : Nat.Prime p) : σ₁' p = p + 1 := by
  simp [σ₁', hp.sum_divisors, add_comm]


theorem sigma1'_ge_one_plus (n : ℕ) (hn : 1 < n) : 1 + n ≤ σ₁' n := by
  -- Since 1 and n are distinct divisors of n, we have {1, n} ⊆ n.divisors.
  have h_subset : ({1, n} : Finset ℕ) ⊆ n.divisors := by
    exact Finset.insert_subset_iff.mpr ⟨ Nat.mem_divisors.mpr ⟨ one_dvd _, by linarith ⟩, Finset.singleton_subset_iff.mpr ( Nat.mem_divisors.mpr ⟨ dvd_rfl, by linarith ⟩ ) ⟩;
  exact le_trans ( by rw [ Finset.sum_pair ( by linarith ) ] ) ( Finset.sum_le_sum_of_subset h_subset )


theorem euler_m_equals_mersenne (k m : ℕ) (hk : 0 < k) (hm : 0 < m)
    (hm_odd : ¬(2 ∣ m))
    (heq : (2 ^ (k + 1) - 1) * σ₁' m = 2 ^ (k + 1) * m)
    (hdvd : (2 ^ (k + 1) - 1) ∣ m) :
    m = 2 ^ (k + 1) - 1 := by
  -- Assume there exists $q \geq 2$ such that $m = (2^(k+1) - 1) * q$.
  by_contra hq_ge_two
  obtain ⟨q, hq_ge_two, hm_eq⟩ : ∃ q, 2 ≤ q ∧ m = (2 ^ (k + 1) - 1) * q := by
    exact Exists.elim hdvd fun q hq => ⟨ q, Nat.one_lt_iff_ne_zero_and_ne_one.mpr ⟨ by aesop_cat, by aesop_cat ⟩, hq ⟩;
  -- Then $\sigma_1(m) \geq 1 + q + (2^{k+1} - 1)q$.
  have h_sigma_ge : σ₁' m ≥ 1 + q + (2 ^ (k + 1) - 1) * q := by
    -- Since $m$ is odd and $q \geq 2$, $m$ has at least the divisors $1$, $q$, and $(2^{k+1} - 1)q$.
    have h_divisors : Nat.divisors m ⊇ {1, q, (2 ^ (k + 1) - 1) * q} := by
      simp +decide [ Finset.insert_subset_iff, hm_eq ];
      exact ⟨ Nat.sub_ne_zero_of_lt ( by norm_num ), by linarith ⟩;
    refine' le_trans _ ( Finset.sum_le_sum_of_subset h_divisors );
    rw [ Finset.sum_insert, Finset.sum_insert ] <;> norm_num;
    · linarith;
    · nlinarith [ Nat.le_sub_one_of_lt ( Nat.pow_lt_pow_right ( by decide : 1 < 2 ) ( by linarith : k + 1 > 1 ) ) ];
    · exact ⟨ by linarith, by nlinarith [ Nat.le_sub_one_of_lt ( Nat.pow_lt_pow_right ( by decide : 1 < 2 ) ( by linarith : k + 1 > 1 ) ) ] ⟩;
  nlinarith [ Nat.sub_add_cancel ( Nat.one_le_pow ( k + 1 ) 2 zero_lt_two ), pow_pos ( zero_lt_two' ℕ ) k, pow_succ' 2 k, mul_pos ( Nat.sub_pos_of_lt ( one_lt_pow₀ one_lt_two ( by linarith : k + 1 ≠ 0 ) ) ) ( zero_lt_two' ℕ ) ]


theorem six_is_perfect' : σ₁' 6 = 2 * 6 := by unfold σ₁'; native_decide


theorem twentyeight_is_perfect' : σ₁' 28 = 2 * 28 := by unfold σ₁'; native_decide


/-- The sum 1 + 2 + ... + n = n*(n+1)/2. -/
theorem triangular_formula (n : ℕ) :
    2 * (∑ i ∈ Finset.range (n + 1), i) = n * (n + 1) := by
  induction n with
  | zero => simp
  | succ n ih => rw [Finset.sum_range_succ]; linarith


end
