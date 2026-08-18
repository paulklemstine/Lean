import Pythagorean.KernelStirlingRecurrence
import Pythagorean.KernelTwoBlocks

/-!
# Closed forms in the Stirling triangle of kernel patterns, and Bell numbers beyond `decide`

Using the Stirling recursion `KernelPattern.stirling2_succ_succ` together with the two
boundary columns already established (`stirling2_one`, `stirling2_two`, `stirling2_self`) we
solve several diagonals and columns of the triangle in closed form:

* `stirling2_succ_pred` : `S(n+1, n) = C(n+1, 2)`;
* `stirling2_add_two_sub_two` : `S(n+2, n) = C(n+2, 3) + 3 * C(n+2, 4)`;
* `stirling2_three`, `stirling2_four`, `stirling2_five` : the columns `k = 3, 4, 5`, in the
  inclusion–exclusion form `k! * S(n,k) = ∑ⱼ (-1)ʲ C(k,j) (k-j)ⁿ` written without
  subtraction so that it lives in `ℕ`.

The payoff is that the Bell numbers `Nat.bell 6 = 203`, `Nat.bell 7 = 877` and
`Nat.bell 8 = 4140` become *provable from the structure theory*, by summing a row of the
triangle — the brute-force `decide` used for `n ≤ 5` is hopeless at these sizes
(`Fin 8 → Fin 8` has `8^8 = 16777216` elements).
-/

open Finset

namespace KernelPattern

/-! ## The two diagonals below the main one -/

/-- The first subdiagonal: a pattern of length `n+1` with `n` blocks merges exactly one pair
of coordinates, so there are `C(n+1,2)` of them. -/
theorem stirling2_succ_pred (n : ℕ) : stirling2 (n + 1) n = Nat.choose (n + 1) 2 := by
  induction n with
  | zero => simp [stirling2_succ_zero]
  | succ m ih =>
      have hrec := stirling2_succ_succ (m + 1) m
      rw [ih, stirling2_self] at hrec
      have hpascal : Nat.choose (m + 1 + 1) 2 = Nat.choose (m + 1) 1 + Nat.choose (m + 1) 2 :=
        Nat.choose_succ_succ (m + 1) 1
      rw [Nat.choose_one_right] at hpascal
      omega

/-- `3 * C(n+2, 3) = n * C(n+2, 2)`, the arithmetic identity behind the second subdiagonal. -/
theorem three_mul_choose_three (n : ℕ) :
    3 * Nat.choose (n + 2) 3 = n * Nat.choose (n + 2) 2 := by
  have h : (n + 2 + 1) * Nat.choose (n + 2) 2 = Nat.choose (n + 3) 3 * 3 :=
    Nat.add_one_mul_choose_eq (n + 2) 2
  have hpascal : Nat.choose (n + 3) 3
      = Nat.choose (n + 2) 2 + Nat.choose (n + 2) 3 := Nat.choose_succ_succ (n + 2) 2
  rw [hpascal] at h
  -- `h : (n + 3) * C(n+2,2) = (C(n+2,2) + C(n+2,3)) * 3`
  nlinarith [h]

/-- The second subdiagonal: `S(n+2, n) = C(n+2,3) + 3 * C(n+2,4)`. -/
theorem stirling2_add_two_sub_two (n : ℕ) :
    stirling2 (n + 2) n = Nat.choose (n + 2) 3 + 3 * Nat.choose (n + 2) 4 := by
  induction n with
  | zero => simp [stirling2_succ_zero, Nat.choose]
  | succ m ih =>
      show stirling2 (m + 3) (m + 1) = Nat.choose (m + 3) 3 + 3 * Nat.choose (m + 3) 4
      have hrec : stirling2 (m + 3) (m + 1)
          = stirling2 (m + 2) m + (m + 1) * stirling2 (m + 2) (m + 1) :=
        stirling2_succ_succ (m + 2) m
      have hsp : stirling2 (m + 2) (m + 1) = Nat.choose (m + 2) 2 := stirling2_succ_pred (m + 1)
      have p3 : Nat.choose (m + 3) 3 = Nat.choose (m + 2) 2 + Nat.choose (m + 2) 3 :=
        Nat.choose_succ_succ (m + 2) 2
      have p4 : Nat.choose (m + 3) 4 = Nat.choose (m + 2) 3 + Nat.choose (m + 2) 4 :=
        Nat.choose_succ_succ (m + 2) 3
      have hmul : (m + 1) * Nat.choose (m + 2) 2
          = Nat.choose (m + 2) 2 + 3 * Nat.choose (m + 2) 3 := by
        rw [three_mul_choose_three m, add_mul, one_mul, Nat.add_comm]
      rw [hrec, ih, hsp, hmul, p3, p4]
      ring

/-! ## The columns `k = 3, 4, 5` -/

/-- The three-block column: `6 * S(n,3) = 3ⁿ - 3·2ⁿ + 3`, stated subtraction-free. -/
theorem stirling2_three (n : ℕ) :
    6 * stirling2 (n + 1) 3 + 3 * 2 ^ (n + 1) = 3 ^ (n + 1) + 3 := by
  induction n with
  | zero =>
      rw [stirling2_eq_zero_of_lt (by norm_num)]
      norm_num
  | succ m ih =>
      have hrec : stirling2 (m + 1 + 1) 3
          = stirling2 (m + 1) 2 + 3 * stirling2 (m + 1) 3 := by
        simpa using stirling2_succ_succ (m + 1) 2
      have h2 := stirling2_two m
      have hpow : 1 ≤ 2 ^ m := Nat.one_le_two_pow
      have e2 : (2 : ℕ) ^ (m + 1 + 1) = 4 * 2 ^ m := by ring
      have e2' : (2 : ℕ) ^ (m + 1) = 2 * 2 ^ m := by ring
      have e3 : (3 : ℕ) ^ (m + 1 + 1) = 9 * 3 ^ m := by ring
      have e3' : (3 : ℕ) ^ (m + 1) = 3 * 3 ^ m := by ring
      rw [e2', e3'] at ih
      rw [hrec, e2, e3, h2]
      omega

/-- The four-block column: `24 * S(n,4) = 4ⁿ - 4·3ⁿ + 6·2ⁿ - 4`, stated subtraction-free. -/
theorem stirling2_four (n : ℕ) :
    24 * stirling2 (n + 1) 4 + 4 * 3 ^ (n + 1) + 4 = 4 ^ (n + 1) + 6 * 2 ^ (n + 1) := by
  induction n with
  | zero =>
      rw [stirling2_eq_zero_of_lt (by norm_num)]
      norm_num
  | succ m ih =>
      have hrec : stirling2 (m + 1 + 1) 4
          = stirling2 (m + 1) 3 + 4 * stirling2 (m + 1) 4 := by
        simpa using stirling2_succ_succ (m + 1) 3
      have h3 := stirling2_three m
      have e2 : (2 : ℕ) ^ (m + 1 + 1) = 2 * 2 ^ (m + 1) := by ring
      have e3 : (3 : ℕ) ^ (m + 1 + 1) = 3 * 3 ^ (m + 1) := by ring
      have e4 : (4 : ℕ) ^ (m + 1 + 1) = 4 * 4 ^ (m + 1) := by ring
      rw [hrec, e2, e3, e4]
      omega

/-- The five-block column: `120 * S(n,5) = 5ⁿ - 5·4ⁿ + 10·3ⁿ - 10·2ⁿ + 5`, subtraction-free. -/
theorem stirling2_five (n : ℕ) :
    120 * stirling2 (n + 1) 5 + 5 * 4 ^ (n + 1) + 10 * 2 ^ (n + 1)
      = 5 ^ (n + 1) + 10 * 3 ^ (n + 1) + 5 := by
  induction n with
  | zero =>
      rw [stirling2_eq_zero_of_lt (by norm_num)]
      norm_num
  | succ m ih =>
      have hrec : stirling2 (m + 1 + 1) 5
          = stirling2 (m + 1) 4 + 5 * stirling2 (m + 1) 5 := by
        simpa using stirling2_succ_succ (m + 1) 4
      have h4 := stirling2_four m
      have e2 : (2 : ℕ) ^ (m + 1 + 1) = 2 * 2 ^ (m + 1) := by ring
      have e3 : (3 : ℕ) ^ (m + 1 + 1) = 3 * 3 ^ (m + 1) := by ring
      have e4 : (4 : ℕ) ^ (m + 1 + 1) = 4 * 4 ^ (m + 1) := by ring
      have e5 : (5 : ℕ) ^ (m + 1 + 1) = 5 * 5 ^ (m + 1) := by ring
      rw [hrec, e2, e3, e4, e5]
      omega

/-! ## Bell numbers beyond the reach of `decide` -/

/-- The sixth row of the Stirling triangle. -/
theorem stirling2_row_six :
    (stirling2 6 0, stirling2 6 1, stirling2 6 2, stirling2 6 3, stirling2 6 4,
      stirling2 6 5, stirling2 6 6) = (0, 1, 31, 90, 65, 15, 1) := by
  have h2 := stirling2_two 5
  have h3 := stirling2_three 5
  have h4 := stirling2_four 5
  have h5 := stirling2_succ_pred 5
  norm_num at h2 h3 h4 h5 ⊢
  exact ⟨stirling2_succ_zero 5, stirling2_one 5, h2, by omega, by omega, h5, stirling2_self 6⟩

/-- The seventh row of the Stirling triangle. -/
theorem stirling2_row_seven :
    (stirling2 7 0, stirling2 7 1, stirling2 7 2, stirling2 7 3, stirling2 7 4,
      stirling2 7 5, stirling2 7 6, stirling2 7 7) = (0, 1, 63, 301, 350, 140, 21, 1) := by
  have h2 := stirling2_two 6
  have h3 := stirling2_three 6
  have h4 := stirling2_four 6
  have h5 := stirling2_add_two_sub_two 5
  have h6 := stirling2_succ_pred 6
  norm_num at h2 h3 h4 h5 h6 ⊢
  exact ⟨stirling2_succ_zero 6, stirling2_one 6, h2, by omega, by omega, h5, h6,
    stirling2_self 7⟩

/-- The eighth row of the Stirling triangle. -/
theorem stirling2_row_eight :
    (stirling2 8 0, stirling2 8 1, stirling2 8 2, stirling2 8 3, stirling2 8 4,
      stirling2 8 5, stirling2 8 6, stirling2 8 7, stirling2 8 8)
      = (0, 1, 127, 966, 1701, 1050, 266, 28, 1) := by
  have h2 := stirling2_two 7
  have h3 := stirling2_three 7
  have h4 := stirling2_four 7
  have h5 := stirling2_five 7
  have h6 := stirling2_add_two_sub_two 6
  have h7 := stirling2_succ_pred 7
  norm_num at h2 h3 h4 h5 h6 h7 ⊢
  exact ⟨stirling2_succ_zero 7, stirling2_one 7, h2, by omega, by omega, by omega, h6, h7,
    stirling2_self 8⟩

/-- **`Nat.bell 6 = 203`**, obtained by summing the sixth row of the Stirling triangle. -/
theorem bell_six : Nat.bell 6 = 203 := by
  have hrow := stirling2_row_six
  simp only [Prod.mk.injEq] at hrow
  rw [← sum_stirling2_eq_bell 6]
  simp only [Finset.sum_range_succ, Finset.sum_range_zero, hrow.1, hrow.2.1, hrow.2.2.1,
    hrow.2.2.2.1, hrow.2.2.2.2.1, hrow.2.2.2.2.2.1, hrow.2.2.2.2.2.2]

/-- **`Nat.bell 7 = 877`**, by summing the seventh row of the Stirling triangle. -/
theorem bell_seven : Nat.bell 7 = 877 := by
  have hrow := stirling2_row_seven
  simp only [Prod.mk.injEq] at hrow
  rw [← sum_stirling2_eq_bell 7]
  simp only [Finset.sum_range_succ, Finset.sum_range_zero, hrow.1, hrow.2.1, hrow.2.2.1,
    hrow.2.2.2.1, hrow.2.2.2.2.1, hrow.2.2.2.2.2.1, hrow.2.2.2.2.2.2.1,
    hrow.2.2.2.2.2.2.2]

/-- **`Nat.bell 8 = 4140`**, by summing the eighth row of the Stirling triangle. -/
theorem bell_eight : Nat.bell 8 = 4140 := by
  have hrow := stirling2_row_eight
  simp only [Prod.mk.injEq] at hrow
  rw [← sum_stirling2_eq_bell 8]
  simp only [Finset.sum_range_succ, Finset.sum_range_zero, hrow.1, hrow.2.1, hrow.2.2.1,
    hrow.2.2.2.1, hrow.2.2.2.2.1, hrow.2.2.2.2.2.1, hrow.2.2.2.2.2.2.1,
    hrow.2.2.2.2.2.2.2.1, hrow.2.2.2.2.2.2.2.2]

end KernelPattern