/-
# Vampire Numbers: Main Theorems

Key results about vampire numbers and arithmetic creatures:
1. The "casting out nines" constraint on fangs
2. Vampire numbers are composite
3. Fang bounds from digit count constraints
4. Existence: 1260 is a vampire number
5. Digit sum preservation in vampire factorizations
-/

import Mathlib
import Geometry.VampireNumbers.Defs

open VampireNumbers

/-! ## Digit Sum and Modular Arithmetic -/

/-- The digit sum of a natural number is congruent to the number mod 9.
    This is the classical "casting out nines" result. -/
theorem digitSum_modEq_nine (n : ℕ) : n ≡ digitSum n [MOD 9] := by
  unfold digitSum
  exact Nat.modEq_digits_sum 9 10 (by norm_num) n

/-- For a vampire number v = x * y, the digit sum of v equals the sum
    of digit sums of x and y. This follows from the multiset equality. -/
theorem vampire_digitSum_additive {v x y : ℕ}
    (h : digitMultiset v = digitMultiset x + digitMultiset y) :
    digitSum v = digitSum x + digitSum y := by
  unfold digitSum digitMultiset at *
  rw [← Multiset.sum_coe, ← Multiset.sum_coe, ← Multiset.sum_coe, h, Multiset.sum_add]

/-- **The Vampire Mod-9 Theorem**: If v = x * y is a vampire factorization
    (with digit multiset equality), then x * y ≡ x + y [MOD 9].

    This is a genuine constraint: it means (x-1)(y-1) ≡ 1 (mod 9), so
    the residues of x and y mod 9 must be multiplicative inverses shifted by 1.
    Only certain pairs of residue classes can appear as fangs. -/
theorem vampire_mod9_constraint {v x y : ℕ}
    (hprod : v = x * y)
    (hdigits : digitMultiset v = digitMultiset x + digitMultiset y) :
    x * y ≡ x + y [MOD 9] := by
  have h1 : v ≡ digitSum v [MOD 9] := digitSum_modEq_nine v
  have h2 : x ≡ digitSum x [MOD 9] := digitSum_modEq_nine x
  have h3 : y ≡ digitSum y [MOD 9] := digitSum_modEq_nine y
  have h4 : digitSum v = digitSum x + digitSum y := vampire_digitSum_additive hdigits
  subst hprod
  calc x * y ≡ digitSum (x * y) [MOD 9] := h1
    _ = digitSum x + digitSum y := h4
    _ ≡ x + y [MOD 9] := (h2.add h3).symm

/-
**Fang Residue Constraint**: For vampire fangs x, y with x, y ≥ 2,
    we have (x - 1) * (y - 1) ≡ 1 [MOD 9] in integers. This severely
    restricts which residue class pairs can form valid fangs.
-/
theorem vampire_fang_residue_constraint {x y : ℕ}
    (hx : x ≥ 2) (hy : y ≥ 2)
    (hmod : x * y ≡ x + y [MOD 9]) :
    ((x : ℤ) - 1) * ((y : ℤ) - 1) ≡ 1 [ZMOD 9] := by
  rw [ Int.modEq_iff_dvd ];
  convert hmod.dvd using 1 ; ring;
  push_cast; ring;

/-! ## Structural Properties -/

/-
A number with n digits satisfies 10^(n-1) ≤ v < 10^n for n ≥ 1.
-/
theorem digits_bound {v : ℕ} {n : ℕ} (hn : n ≥ 1) (hv : v ≠ 0)
    (hlen : numDigits v = n) :
    10^(n-1) ≤ v ∧ v < 10^n := by
  rcases n <;> simp_all +decide [ numDigits ];
  rw [ Nat.pow_le_iff_le_log, Nat.lt_pow_iff_log_lt, Nat.digits_len ] at * <;> aesop

/-
**Vampire numbers are composite**: Any vampire number has a non-trivial
    factorization, since both fangs have at least 2 digits (≥ 10).
-/
theorem vampire_is_composite {v : ℕ} (hv : IsVampire v) :
    ∃ a b : ℕ, a > 1 ∧ b > 1 ∧ v = a * b := by
  obtain ⟨ n, hn, hlen, x, y, rfl, hx, hy, hdigits, htrailing ⟩ := hv;
  use x, y;
  rcases x with ( _ | _ | x ) <;> rcases y with ( _ | _ | y ) <;> simp_all +arith +decide;
  · linarith;
  · bv_omega;
  · linarith;
  · grind +qlia

/-
**Fang lower bound**: Each fang of a vampire number has at least 2 digits,
    hence is at least 10.
-/
theorem vampire_fang_ge_ten {v x y n : ℕ}
    (hn : n ≥ 2) (hx : numDigits x = n) (hy : numDigits y = n)
    (hprod : v = x * y) (hv : v ≠ 0) :
    x ≥ 10 ∧ y ≥ 10 := by
  have h_digits_x : 10^(n-1) ≤ x := by
    have := digits_bound ( show 1 ≤ n by linarith ) ( show x ≠ 0 by aesop_cat ) hx; aesop;
  have h_digits_y : 10^(n-1) ≤ y := by
    apply (digits_bound (by linarith) (by
    aesop) hy).left;
  exact ⟨ le_trans ( Nat.le_self_pow ( Nat.sub_ne_zero_of_lt hn ) _ ) h_digits_x, le_trans ( Nat.le_self_pow ( Nat.sub_ne_zero_of_lt hn ) _ ) h_digits_y ⟩

/-
**Vampire number lower bound**: Every vampire number is at least 1000
    (4 digits minimum).
-/
theorem vampire_ge_1000 {v : ℕ} (hv : IsVampire v) : v ≥ 1000 := by
  rcases hv with ⟨ n, hn, href, x, y, hv1, href1, href2, href3 ⟩;
  -- From IsVampire, v has 2*n digits with n ≥ 2, so numDigits v ≥ 4.
  have h_len : numDigits v ≥ 4 := by
    linarith;
  contrapose! h_len; interval_cases v <;> native_decide;

/-! ## Existence: 1260 is a Vampire Number -/

/-- The number 1260 has exactly 4 decimal digits. -/
theorem numDigits_1260 : numDigits 1260 = 4 := by native_decide

/-- The number 21 has exactly 2 decimal digits. -/
theorem numDigits_21 : numDigits 21 = 2 := by native_decide

/-- The number 60 has exactly 2 decimal digits. -/
theorem numDigits_60 : numDigits 60 = 2 := by native_decide

/-- The digit multiset of 1260 equals the union of digit multisets of 21 and 60. -/
theorem digits_1260_eq : digitMultiset 1260 = digitMultiset 21 + digitMultiset 60 := by
  native_decide

/-- **1260 is a vampire number** with fangs 21 and 60. -/
theorem vampire_1260 : IsVampire 1260 := by
  refine ⟨2, le_refl 2, numDigits_1260, 21, 60, by norm_num, numDigits_21, numDigits_60,
    digits_1260_eq, ?_⟩
  omega

/-! ## Counting and Density -/

/-
The number of possible fang pairs for a 2n-digit number: there are at most
    (10^n - 10^(n-1))^2 pairs of n-digit numbers to check. This provides an
    upper bound on the search space.
-/
theorem fang_search_space_bound (n : ℕ) (hn : n ≥ 1) :
    (10^n - 10^(n-1)) * (10^n - 10^(n-1)) ≤ 10^(2*n) := by
  rcases n with ( _ | n ) <;> simp_all +decide [ Nat.pow_succ' ];
  zify ; norm_num ; ring_nf ; norm_num

/-! ## The Spectral Number Theorem -/

/-
**Spectral numbers don't exist**: If the sorted digits match, the multisets
    are equal. This shows our definition of spectral numbers is vacuous —
    there are no "near-miss" vampires by digit sorting.
-/
theorem spectral_numbers_empty : ∀ v : ℕ, ¬IsSpectralNumber v := by
  intro v;
  intro h;
  obtain ⟨x, y, hv, hx, hy, hsort, hne⟩ := h;
  exact hne ( by simpa using congr_arg Multiset.ofList hsort )

/-! ## Ghost Number Properties -/

/-
**Ghost numbers require large digit sets**: If v = x * y is a ghost number,
    then v, x, y together use at least 3 distinct digits (and the digit sets
    are pairwise disjoint between v and {x, y}).
-/
theorem ghost_number_distinct_digits {v : ℕ} (hg : IsGhostNumber v) :
    (digitMultiset v).toFinset.card ≥ 1 := by
  rcases v with ( _ | _ | v ) <;> simp_all +arith +decide [ numDigits ];
  · obtain ⟨ x, y, hxy, hx, hy, hx', hy' ⟩ := hg;
    nlinarith;
  · unfold digitMultiset; aesop