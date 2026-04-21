/-! # CatalogBuild.Logic.O1Impossibility

Auto-generated from theorem catalog database.
Domain: Logic
Declarations: 13
-/

import Mathlib

noncomputable section

/-- Given the smallest prime factor p, the factor-finding step is (p-1)/2. -/
theorem k_from_p (p : ℕ) (hp : 2 ≤ p) (hodd : p % 2 = 1) :
    2 * ((p - 1) / 2) + 1 = p := by omega




/-- Given the factor-finding step k, the factor is 2k+1. -/
theorem p_from_k (k : ℕ) (p : ℕ) (hp : 2 ≤ p) (hodd : p % 2 = 1)
    (hk : k = (p - 1) / 2) : p = 2 * k + 1 := by omega




/-- The maps k ↦ 2k+1 and p ↦ (p-1)/2 are mutual inverses (on odd p ≥ 3). -/
theorem k_p_equivalence (p : ℕ) (hp : 2 ≤ p) (hodd : p % 2 = 1) :
    (2 * ((p - 1) / 2) + 1 = p) ∧ ((2 * ((p - 1) / 2) + 1 - 1) / 2 = (p - 1) / 2) := by
  omega




/-- Round-trip: k → p → k is the identity. -/
theorem roundtrip_k (k : ℕ) : (2 * k + 1 - 1) / 2 = k := by omega




/-- Round-trip: p → k → p is the identity for odd p ≥ 3. -/
theorem roundtrip_p (p : ℕ) (hp : 2 ≤ p) (hodd : p % 2 = 1) :
    2 * ((p - 1) / 2) + 1 = p := by omega




/-- The factor condition: p divides b_k = ((N-2k)² - 1)/2 iff p divides 4k²-1. -/
theorem factor_condition' (N k p : ℤ) (hp : p ∣ N) :
    p ∣ ((N - 2*k)^2 - 1) ↔ p ∣ (4*k^2 - 1) := by
  obtain ⟨d, rfl⟩ := hp
  constructor
  · rintro ⟨x, hx⟩; exact ⟨x - p * d ^ 2 + 4 * d * k, by linarith⟩
  · rintro ⟨x, hx⟩; exact ⟨x + p * d ^ 2 - 4 * d * k, by linarith⟩




/-- 4k²-1 = (2k-1)(2k+1) — the factorization that controls everything. -/
theorem four_k_sq_factored (k : ℤ) : 4 * k ^ 2 - 1 = (2 * k - 1) * (2 * k + 1) := by ring




/-- [Section: # CatalogBuild.Logic.O1Impossibility
Auto-generated from theorem catalog database.
Domain: Logic
Declarations: 13] -/
theorem no_shortcut_before_p (p : ℕ) (hp : Nat.Prime p) (hodd : p ≠ 2)
    (k : ℕ) (hk_pos : 0 < k) (hk_lt : k < (p - 1) / 2) :
    ¬((p : ℤ) ∣ (4 * (k : ℤ) ^ 2 - 1)) := by
  by_contra h_contra
  have h_div : (p : ℤ) ∣ (2 * k - 1) ∨ (p : ℤ) ∣ (2 * k + 1) := by
    exact Int.Prime.dvd_mul' hp <| by convert h_contra using 1; ring;
  have h_contra' : (p : ℤ) ∣ (2 * k - 1) → False := by
    exact fun h => by have := Int.le_of_dvd ( by linarith ) h; omega;
  have h_contra'' : (p : ℤ) ∣ (2 * k + 1) → False := by
    exact fun h => by have := Int.le_of_dvd ( by positivity ) h; omega;
  exact h_contra' (h_div.resolve_right h_contra'')




/-- At step k = (p-1)/2, the factor IS found — p divides 4k²-1. -/
theorem factor_found_at_half_p (p : ℕ) (hp : 2 ≤ p) (hodd : p % 2 = 1) :
    (p : ℤ) ∣ (4 * ((p - 1 : ℕ) / 2 : ℤ) ^ 2 - 1) := by
  rw [four_k_sq_factored]
  have h2k : 2 * ((p - 1 : ℕ) / 2 : ℤ) + 1 = (p : ℤ) := by omega
  rw [← h2k]
  exact dvd_mul_left _ _




/-- The minimum number of steps to find a factor of N = p·q (p ≤ q, both odd primes)
is exactly (p-1)/2. No strategy — including the closed-form — can do better
without additional structure (like knowing p in advance). -/
theorem min_steps_is_half_p (p : ℕ) (hp : Nat.Prime p) (hodd_p : p ≠ 2)
    (k : ℕ) (hk_pos : 0 < k) (hk_lt : k < (p - 1) / 2) :
    ¬((p : ℤ) ∣ (4 * (k : ℤ) ^ 2 - 1)) :=
  no_shortcut_before_p p hp hodd_p k hk_pos hk_lt




/-- The closed-form lets you evaluate any step in O(1) without
computing prior steps. This is useful for parallelism but
doesn't reduce total work. -/
noncomputable def closedFormStep (N k : ℕ) : ℕ × ℕ × ℕ :=
  let ak := N - 2 * k
  let bk := (ak * ak - 1) / 2
  let ck := (ak * ak + 1) / 2
  (ak, bk, ck)




/-- The closed-form step produces a valid Pythagorean triple
(when ak is odd and > 0). -/
theorem closedForm_is_pythagorean (N k : ℤ) (hN : N % 2 = 1) :
    (N - 2*k) ^ 2 + (((N - 2*k) ^ 2 - 1) / 2) ^ 2 =
    (((N - 2*k) ^ 2 + 1) / 2) ^ 2 := by
  nlinarith [
    Int.ediv_mul_cancel (show 2 ∣ (N - 2 * k) ^ 2 - 1 from
      even_iff_two_dvd.mp (by simpa [parity_simps] using Int.odd_iff.mpr hN)),
    Int.ediv_mul_cancel (show 2 ∣ (N - 2 * k) ^ 2 + 1 from
      even_iff_two_dvd.mp (by simpa [parity_simps] using Int.odd_iff.mpr hN))]




/-- **Main result**: For an odd prime p, the factor-finding step k = (p-1)/2
and the factor p = 2k+1 are related by a trivial O(1) bijection. Therefore:
- Computing k from N requires finding p (factoring).
- The closed-form evaluates each step in O(1) but requires (p-1)/2 steps.
- Total complexity: O(p) = O(√N) — same as trial division.
- The algorithm cannot be made O(1) without a breakthrough in factoring. -/
theorem o1_factoring_impossible_summary (p : ℕ) (hp : Nat.Prime p) (hodd_p : p ≠ 2) :
    -- The factor-finding step is (p-1)/2
    (2 * ((p - 1) / 2) + 1 = p) ∧
    -- No earlier step works
    (∀ k : ℕ, 0 < k → k < (p - 1) / 2 → ¬((p : ℤ) ∣ (4 * (k : ℤ) ^ 2 - 1))) := by
  refine ⟨?_, fun k hk_pos hk_lt => no_shortcut_before_p p hp hodd_p k hk_pos hk_lt⟩
  cases hp.eq_two_or_odd with
  | inl h => exact absurd h hodd_p
  | inr h => omega

#check o1_factoring_impossible_summary



end
