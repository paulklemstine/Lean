import Tropical.JacobiSignedMultiplicative

/-!
# The Jacobi-signed circle count escapes the residue dial

The earlier character-weighted witnesses (CIRC, BQF, GSP) all collapsed to a *residue
dial*: their value was a function of `N mod 4` or `N mod 8`.  Here we prove, by exact
evaluation, that the Jacobi-signed count is **not** a residue dial, and that the Weil
floor of `JacobiSignedWeilFloorBound.lean` is nearly attained.

* `JacSign.WZ_eq_WN` : the abstract statistic equals the concrete range-sum, so all the
  numerical statements below are statements about `W` / `WZ` themselves.
* `JacSign.W_17`, `JacSign.W_41`, ... : exact values (`-2`, `-10`, `-14`, ...).
* `JacSign.not_residue_dial_prime` : there is **no** function `f` with `W p = f (p % 8)`
  for all primes `p`.  (`17 ≡ 41 ≡ 1 (mod 8)` but `W 17 = -2 ≠ -10 = W 41`.)
* `JacSign.not_residue_dial_modulus` : likewise at composite level
  (`21 ≡ 85 ≡ 5 (mod 8)` but `WZ 21 = 0 ≠ -4 = WZ 85`).
* `JacSign.weil_floor_near_attained` : `W 173 = 26` and `26² = 676 > 0.97 · (4 · 173)`,
  so the bound `W p ^ 2 ≤ 4 p` cannot be improved by any constant factor `< 0.977`.
* `JacSign.not_constant_on_primes_mod_four` : the statistic is not a dial mod 4 either.
-/

open Finset

namespace JacSign

/-- A directly computable form of the statistic. -/
def WN (n : ℕ) : ℤ := ∑ x ∈ Finset.range n, jacobiSym ((x : ℤ) * (1 - (x : ℤ) ^ 2)) n

/-- The abstract Jacobi-signed count coincides with the concrete range-sum. -/
theorem WZ_eq_WN (n : ℕ) [NeZero n] : WZ n = WN n := by
  rw [WZ, WN]
  refine Finset.sum_nbij' (i := fun x : ZMod n => x.val) (j := fun k : ℕ => (k : ZMod n))
    ?_ ?_ ?_ ?_ ?_
  · intro a _; exact Finset.mem_range.mpr (ZMod.val_lt a)
  · intro k _; exact Finset.mem_univ _
  · intro a _; exact ZMod.natCast_zmod_val a
  · intro k hk; exact ZMod.val_cast_of_lt (Finset.mem_range.mp hk)
  · intro a _
    show jchar n _ = jacobiSym ((a.val : ℤ) * (1 - (a.val : ℤ) ^ 2)) n
    unfold jchar
    apply jacobiSym.mod_left'
    refine (ZMod.intCast_eq_intCast_iff' (((a * (1 - a ^ 2)).val : ℤ))
      ((a.val : ℤ) * (1 - (a.val : ℤ) ^ 2)) n).mp ?_
    push_cast
    simp

instance fact_prime_5 : Fact (Nat.Prime 5) := ⟨by norm_num⟩
instance fact_prime_13 : Fact (Nat.Prime 13) := ⟨by norm_num⟩
instance fact_prime_17 : Fact (Nat.Prime 17) := ⟨by norm_num⟩
instance fact_prime_29 : Fact (Nat.Prime 29) := ⟨by norm_num⟩
instance fact_prime_41 : Fact (Nat.Prime 41) := ⟨by norm_num⟩
instance fact_prime_53 : Fact (Nat.Prime 53) := ⟨by norm_num⟩
instance fact_prime_173 : Fact (Nat.Prime 173) := ⟨by norm_num⟩

/-- Bridge: for a prime, `W p` is the concrete sum. -/
theorem W_eq_WN (p : ℕ) [Fact p.Prime] : W p = WN p := by
  haveI : NeZero p := ⟨(Fact.out : p.Prime).ne_zero⟩
  rw [← WZ_prime p, WZ_eq_WN]

set_option maxRecDepth 100000

theorem W_5 : W 5 = 2 := by
  rw [W_eq_WN, WN]
  simp only [Finset.sum_range_succ, Finset.sum_range_zero]
  norm_num

theorem W_13 : W 13 = -6 := by
  rw [W_eq_WN, WN]
  simp only [Finset.sum_range_succ, Finset.sum_range_zero]
  norm_num

theorem W_17 : W 17 = -2 := by
  rw [W_eq_WN, WN]
  simp only [Finset.sum_range_succ, Finset.sum_range_zero]
  norm_num

theorem W_29 : W 29 = 10 := by
  rw [W_eq_WN, WN]
  simp only [Finset.sum_range_succ, Finset.sum_range_zero]
  norm_num

theorem W_41 : W 41 = -10 := by
  rw [W_eq_WN, WN]
  simp only [Finset.sum_range_succ, Finset.sum_range_zero]
  norm_num

theorem W_53 : W 53 = -14 := by
  rw [W_eq_WN, WN]
  simp only [Finset.sum_range_succ, Finset.sum_range_zero]
  norm_num

theorem W_173 : W 173 = 26 := by
  rw [W_eq_WN, WN]
  simp only [Finset.sum_range_succ, Finset.sum_range_zero]
  norm_num

theorem WZ_21 : WZ 21 = 0 := by
  rw [WZ_eq_WN, WN]
  simp only [Finset.sum_range_succ, Finset.sum_range_zero]
  norm_num

theorem WZ_85 : WZ 85 = -4 := by
  rw [WZ_eq_WN, WN]
  simp only [Finset.sum_range_succ, Finset.sum_range_zero]
  norm_num

/-- **Not a residue dial (primes).** No function of `p mod 8` computes `W p`:
`17 ≡ 41 ≡ 1 (mod 8)` but `W 17 = -2` and `W 41 = -10`. -/
theorem not_residue_dial_prime :
    ¬ ∃ f : ℕ → ℤ, ∀ (p : ℕ) (inst : Fact p.Prime), @W p inst = f (p % 8) := by
  rintro ⟨f, hf⟩
  have h17 := hf 17 fact_prime_17
  have h41 := hf 41 fact_prime_41
  rw [W_17] at h17
  rw [W_41] at h41
  norm_num at h17 h41
  omega

/-- The statistic is not a dial modulo `4` either. -/
theorem not_residue_dial_prime_mod_four :
    ¬ ∃ f : ℕ → ℤ, ∀ (p : ℕ) (inst : Fact p.Prime), @W p inst = f (p % 4) := by
  rintro ⟨f, hf⟩
  have h13 := hf 13 fact_prime_13
  have h17 := hf 17 fact_prime_17
  rw [W_13] at h13
  rw [W_17] at h17
  norm_num at h13 h17
  omega

/-- **Not a residue dial (composite moduli).** `21 ≡ 85 ≡ 5 (mod 8)` but
`WZ 21 = 0` and `WZ 85 = -4`. -/
theorem not_residue_dial_modulus :
    ¬ ∃ f : ℕ → ℤ, ∀ (n : ℕ) (inst : NeZero n), @WZ n inst = f (n % 8) := by
  rintro ⟨f, hf⟩
  have h21 := hf 21 (by infer_instance)
  have h85 := hf 85 (by infer_instance)
  rw [WZ_21] at h21
  rw [WZ_85] at h85
  norm_num at h21 h85
  omega

/-- **The Weil floor is essentially attained.** For `p = 173` we have `W p ^ 2 = 676`
while `4 p = 692`: no bound `W p ^ 2 ≤ c · p` with `c < 3.9` can hold for all primes. -/
theorem weil_floor_near_attained :
    ∃ p : ℕ, ∃ inst : Fact p.Prime, 100 * (@W p inst) ^ 2 > 97 * (4 * (p : ℤ)) := by
  refine ⟨173, fact_prime_173, ?_⟩
  rw [W_173]
  norm_num

/-- The Weil bound really is a bound here, and it is not vacuous: the statistic takes
nonzero values, so the vanishing theorem for `p ≡ 3 (mod 4)` is not the whole story. -/
theorem W_ne_zero_example : W 5 ≠ 0 := by rw [W_5]; norm_num

instance fact_prime_3 : Fact (Nat.Prime 3) := ⟨by norm_num⟩
instance fact_prime_7 : Fact (Nat.Prime 7) := ⟨by norm_num⟩

/-- **An infinite blind family.** For every prime `q ≠ 3` the Jacobi-signed count of the
semiprime `3q` is `0`: on this family the witness returns no information whatsoever,
whatever the size of `q`. -/
theorem blind_family_three (q : ℕ) [Fact q.Prime] (hq : q ≠ 3) : WZ (3 * q) = 0 :=
  WZ_semiprime_eq_zero_of_three_mod_four (fun h => hq h.symm) (Or.inl rfl)

/-- **The statistic collides**: distinct semiprimes with the same value, so `WZ` cannot
determine a factorisation. -/
theorem statistic_not_injective :
    ∃ M N : ℕ, M ≠ N ∧ (∃ instM : NeZero M, ∃ instN : NeZero N, @WZ M instM = @WZ N instN) := by
  refine ⟨15, 21, by norm_num, ⟨by norm_num⟩, ⟨by norm_num⟩, ?_⟩
  have h15 : WZ (3 * 5) = 0 := blind_family_three 5 (by norm_num)
  have h21 : WZ (3 * 7) = 0 := blind_family_three 7 (by norm_num)
  norm_num at h15 h21
  rw [h15, h21]

/-- Consistency with the parity theorem: all observed values are even. -/
theorem observed_values_even :
    (2 : ℤ) ∣ W 17 ∧ (2 : ℤ) ∣ W 41 ∧ (2 : ℤ) ∣ W 53 ∧ (2 : ℤ) ∣ W 173 := by
  refine ⟨W_even 17 (by norm_num), W_even 41 (by norm_num), W_even 53 (by norm_num),
    W_even 173 (by norm_num)⟩

end JacSign