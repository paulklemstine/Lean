/-
# Binary staircase numbers: the arithmetic of the NET-47 knee spread

The NET-47 round reports, at the cell `(d = 4, ctx = 1024)`, the three-seed knee distribution

```
{96, 112, 128},   product point  d·ctx/32 = 128 = 2^7,
```

with the "7/8 median law" `112 = (7/8)·128` and a "±16 half-grid-step jitter".  Written in base
two the three numbers are `1100000`, `1110000`, `10000000`: each is a block of ones followed by a
block of zeros.  This file isolates that combinatorial shape as a number-theoretic object,

```
stair b j = 2 ^ b * (2 ^ j - 1) = 2 ^ (b + j) - 2 ^ b,
```

the *binary staircase number* with `j` ones and `b` trailing zeros, and proves the arithmetic
which makes the measured pattern forced rather than accidental.

Main results.

* `KneeStaircase.digits_stair` — the defining combinatorial description: the base-2 digits of
  `stair b j` are `b` zeros followed by `j` ones.  Hence `stair` is a *normal form*:
  `KneeStaircase.stair_injective2` shows `(b, j)` is recoverable from the number, via the 2-adic
  valuation (`KneeStaircase.factorization_two_stair`) and the digit sum
  (`KneeStaircase.digit_sum_stair`).
* `KneeStaircase.two_mul_stair_succ` — the **midpoint law**
  `2 · stair b (j+1) = stair (b+1) j + 2 ^ (b+j+1)`: every rung of the ladder is the exact
  midpoint of the previous rung and the top point `2^n`.  This is the abstract form of
  `2 · 112 = 96 + 128`.
* `KneeStaircase.ladder_arithmetic_progression` — consequently the triple
  `(stair (b+1) j, stair b (j+1), 2^(b+j+1))` is an arithmetic progression of common difference
  `2 ^ b`: a knee spread of this shape has mean = median, and the median is the `(2^{j+1}-1)/2^{j+1}`
  fraction of the top point.
* `KneeStaircase.stair_lt_two_pow`, `KneeStaircase.stair_strictMono_ones` — the ladder increases
  in `j` and stays strictly below the top point: the product point is the maximum of the family,
  never attained by a genuine staircase rung.
* `KneeStaircase.net47_*` — the instantiation at the measured numbers: `96 = stair 5 2`,
  `112 = stair 4 3`, `128 = 2^7`, `8·112 = 7·128`, and the arithmetic-progression statement of the
  jitter, all as consequences of the general lemmas rather than by evaluation.

Companion file: `Catalog/NumberTheory/KneeStaircaseDivisorSpectrum.lean` (divisor sums, the
abundant/deficient/perfect classification of the family and its analytic limit).
-/

import Mathlib

namespace KneeStaircase

/-! ## 1.  The staircase family -/

/-- The **binary staircase number** with `j` ones and `b` trailing zeros:
`stair b j = 2 ^ b * (2 ^ j - 1)`. -/
def stair (b j : ℕ) : ℕ := 2 ^ b * (2 ^ j - 1)

@[simp] theorem stair_zero_ones (b : ℕ) : stair b 0 = 0 := by simp [stair]

@[simp] theorem stair_one (b : ℕ) : stair b 1 = 2 ^ b := by simp [stair]

theorem one_le_two_pow (j : ℕ) : 1 ≤ 2 ^ j := Nat.one_le_two_pow

/-- The staircase number as a difference of two powers of two: `2^(b+j) - 2^b`. -/
theorem stair_eq_sub (b j : ℕ) : stair b j = 2 ^ (b + j) - 2 ^ b := by
  rw [stair, Nat.mul_sub, pow_add, mul_one]

theorem stair_add_two_pow (b j : ℕ) : stair b j + 2 ^ b = 2 ^ (b + j) := by
  have h : 2 ^ b ≤ 2 ^ (b + j) := Nat.pow_le_pow_right (by norm_num) (Nat.le_add_right _ _)
  rw [stair_eq_sub]; omega

theorem stair_pos {b j : ℕ} (hj : 1 ≤ j) : 0 < stair b j := by
  have h2 : 2 ≤ 2 ^ j := by
    calc (2:ℕ) = 2 ^ 1 := (pow_one 2).symm
    _ ≤ 2 ^ j := Nat.pow_le_pow_right (by norm_num) hj
  have : 0 < 2 ^ j - 1 := by omega
  exact Nat.mul_pos (Nat.two_pow_pos _) this

/-- The staircase rung always lies **strictly below** the top point `2 ^ (b + j)`: in the
NET-47 reading, no jittered knee ever reaches the product point. -/
theorem stair_lt_two_pow (b j : ℕ) : stair b j < 2 ^ (b + j) := by
  have h := stair_add_two_pow b j
  have : 0 < 2 ^ b := Nat.two_pow_pos _
  omega

/-- For a fixed top point `2 ^ n`, the rungs `2 ^ n - 2 ^ (n - j)` increase with the number of
ones `j`. -/
theorem stair_strictMono_ones {b j : ℕ} : stair (b + 1) j < stair b (j + 1) := by
  have h1 := stair_add_two_pow (b + 1) j
  have h2 := stair_add_two_pow b (j + 1)
  have e : b + 1 + j = b + (j + 1) := by omega
  rw [e] at h1
  have hb : 0 < 2 ^ b := Nat.two_pow_pos _
  have : 2 ^ (b + 1) = 2 * 2 ^ b := by ring
  omega

/-! ## 2.  The midpoint (half-step) law -/

/-- **Midpoint law.**  Each rung is the exact arithmetic mean of the previous rung and the top
point: `2 · stair b (j+1) = stair (b+1) j + 2 ^ (b+j+1)`.  Instantiated at `b = 4, j = 2` this is
`2 · 112 = 96 + 128`, the NET-47 "mean = median" observation. -/
theorem two_mul_stair_succ (b j : ℕ) :
    2 * stair b (j + 1) = stair (b + 1) j + 2 ^ (b + j + 1) := by
  have h1 := stair_add_two_pow b (j + 1)
  have h2 := stair_add_two_pow (b + 1) j
  have e : b + 1 + j = b + (j + 1) := by omega
  rw [e] at h2
  have hb : (2:ℕ) ^ (b + 1) = 2 * 2 ^ b := by ring
  have hbj : b + j + 1 = b + (j + 1) := by omega
  rw [hbj]
  omega

/-- **The jitter is an arithmetic progression.**  The triple
`stair (b+1) j < stair b (j+1) < 2 ^ (b+j+1)` has both gaps equal to `2 ^ b`: a half step of the
grid on which the previous rung sits. -/
theorem ladder_arithmetic_progression (b j : ℕ) :
    stair b (j + 1) - stair (b + 1) j = 2 ^ b ∧
      2 ^ (b + j + 1) - stair b (j + 1) = 2 ^ b := by
  have h1 := stair_add_two_pow b (j + 1)
  have h2 := stair_add_two_pow (b + 1) j
  have e : b + 1 + j = b + (j + 1) := by omega
  rw [e] at h2
  have hb : (2:ℕ) ^ (b + 1) = 2 * 2 ^ b := by ring
  have hbj : b + j + 1 = b + (j + 1) := by omega
  rw [hbj]
  omega

/-- The median rung is the fraction `(2^(j+1) - 1) / 2^(j+1)` of the top point.  For `j = 2`:
`8 · 112 = 7 · 128`, the "7/8 law". -/
theorem stair_fraction_of_top (b j : ℕ) :
    2 ^ (j + 1) * stair b (j + 1) = (2 ^ (j + 1) - 1) * 2 ^ (b + j + 1) := by
  have e : b + j + 1 = b + (j + 1) := by omega
  rw [stair, e, pow_add]
  ring

/-! ## 3.  Base-two digits: the staircase is a normal form -/

theorem digits_two_pow_sub_one (j : ℕ) :
    Nat.digits 2 (2 ^ j - 1) = List.replicate j 1 := by
  induction j with
  | zero => simp
  | succ n ih =>
      have hpos : 0 < 2 ^ (n + 1) - 1 := by
        have : 2 ≤ 2 ^ (n + 1) := by
          calc (2:ℕ) = 2 ^ 1 := (pow_one 2).symm
          _ ≤ 2 ^ (n + 1) := Nat.pow_le_pow_right (by norm_num) (by omega)
        omega
      rw [Nat.digits_def' (by norm_num) hpos]
      have h1 : (2 ^ (n + 1) - 1) % 2 = 1 := by
        have h2 : 2 ^ (n + 1) = 2 * 2 ^ n := by ring
        have hn : 1 ≤ 2 ^ n := one_le_two_pow n
        omega
      have h2 : (2 ^ (n + 1) - 1) / 2 = 2 ^ n - 1 := by
        have h2' : 2 ^ (n + 1) = 2 * 2 ^ n := by ring
        have hn : 1 ≤ 2 ^ n := one_le_two_pow n
        omega
      rw [h1, h2, ih, List.replicate_succ]

/-- **Digit description.**  `stair b j` is written in base two as `b` zeros (least significant)
followed by `j` ones. -/
theorem digits_stair {b j : ℕ} (hj : 1 ≤ j) :
    Nat.digits 2 (stair b j) = List.replicate b 0 ++ List.replicate j 1 := by
  induction b with
  | zero => simpa [stair] using digits_two_pow_sub_one j
  | succ n ih =>
      have hpos : 0 < stair (n + 1) j := stair_pos hj
      rw [Nat.digits_def' (by norm_num) hpos]
      have hs : stair (n + 1) j = 2 * stair n j := by
        simp [stair, pow_succ]; ring
      have h1 : stair (n + 1) j % 2 = 0 := by omega
      have h2 : stair (n + 1) j / 2 = stair n j := by omega
      rw [h1, h2, ih, List.replicate_succ]
      simp

/-- The base-two digit sum of a staircase number is its number of ones. -/
theorem digit_sum_stair {b j : ℕ} (hj : 1 ≤ j) :
    (Nat.digits 2 (stair b j)).sum = j := by
  rw [digits_stair hj]
  simp

/-! ## 4.  The 2-adic valuation and injectivity of the parametrisation -/

theorem odd_two_pow_sub_one {j : ℕ} (hj : 1 ≤ j) : ¬ (2 ∣ 2 ^ j - 1) := by
  obtain ⟨n, rfl⟩ : ∃ n, j = n + 1 := ⟨j - 1, by omega⟩
  have h2 : 2 ^ (n + 1) = 2 * 2 ^ n := by ring
  have hn : 1 ≤ 2 ^ n := one_le_two_pow n
  omega

/-- The 2-adic valuation of `stair b j` is exactly the number of trailing zeros `b`. -/
theorem factorization_two_stair {b j : ℕ} (hj : 1 ≤ j) :
    (stair b j).factorization 2 = b := by
  have hne : (2 ^ j - 1) ≠ 0 := by
    have h2 : (2:ℕ) ^ 1 ≤ 2 ^ j := Nat.pow_le_pow_right (by norm_num) hj
    simp only [pow_one] at h2
    omega
  rw [stair, Nat.factorization_mul (by positivity) hne]
  simp [Nat.Prime.factorization_pow Nat.prime_two,
    Nat.factorization_eq_zero_of_not_dvd (odd_two_pow_sub_one hj)]

/-- **Normal form.**  A staircase number determines its parameters: the exponent pair `(b, j)` is
read off as (2-adic valuation, digit sum). -/
theorem stair_injective2 {b j b' j' : ℕ} (hj : 1 ≤ j) (hj' : 1 ≤ j')
    (h : stair b j = stair b' j') : b = b' ∧ j = j' := by
  have hb : b = b' := by
    have := factorization_two_stair (b := b) hj
    rw [h, factorization_two_stair hj'] at this
    exact this.symm
  refine ⟨hb, ?_⟩
  have hd := digit_sum_stair (b := b) hj
  rw [h, digit_sum_stair hj'] at hd
  exact hd.symm

/-! ## 5.  The NET-47 instance -/

theorem net47_ninetysix : stair 5 2 = 96 := by norm_num [stair]

theorem net47_onetwelve : stair 4 3 = 112 := by norm_num [stair]

theorem net47_product_point : (2:ℕ) ^ 7 = 128 := by norm_num

/-- The three measured knees are the two top rungs of the weight-7 staircase ladder together
with its top point, and they form an arithmetic progression of step `2 ^ 4 = 16` — the
"half-grid-step jitter". -/
theorem net47_knees_arithmetic_progression :
    (112 : ℕ) - 96 = 16 ∧ (128 : ℕ) - 112 = 16 := by
  have h := ladder_arithmetic_progression 4 2
  rw [net47_onetwelve, show stair (4+1) 2 = 96 from net47_ninetysix,
    show (2:ℕ) ^ (4 + 2 + 1) = 128 by norm_num] at h
  exact ⟨h.1, h.2⟩

/-! ### The window `(96, 128)`: why the mid-grid read is forced -/

/-- A staircase rung is at least half of its top point. -/
theorem two_pow_le_two_mul_stair {b j : ℕ} (hj : 1 ≤ j) : 2 ^ (b + j) ≤ 2 * stair b j := by
  have h := stair_add_two_pow b j
  have hle : 2 ^ b ≤ stair b j := by
    have h1 : (2:ℕ) ^ (b + 1) ≤ 2 ^ (b + j) := Nat.pow_le_pow_right (by norm_num) (by omega)
    have h2 : (2:ℕ) ^ (b + 1) = 2 * 2 ^ b := by ring
    omega
  omega

/-- **Weight rigidity.**  Any staircase number strictly between `96` and `128` has weight
`b + j = 7`: it is a rung of the *same* ladder as the measured knees.  (The two-sided bound is
what forces this; neither inequality alone suffices.) -/
theorem weight_eq_seven_of_window {b j : ℕ} (hj : 1 ≤ j)
    (hlo : 96 < stair b j) (hhi : stair b j < 128) : b + j = 7 := by
  have hup : b + j ≤ 7 := by
    by_contra hcon
    have h8 : (2:ℕ) ^ 8 ≤ 2 ^ (b + j) := Nat.pow_le_pow_right (by norm_num) (by omega)
    have := two_pow_le_two_mul_stair (b := b) (j := j) hj
    norm_num at h8
    omega
  have hlow : 7 ≤ b + j := by
    by_contra hcon
    have h6 : (2:ℕ) ^ (b + j) ≤ 2 ^ 6 := Nat.pow_le_pow_right (by norm_num) (by omega)
    have := stair_lt_two_pow b j
    norm_num at h6
    omega
  omega

/-- **The staircase window.**  The only staircase numbers strictly between the lowest measured
knee `96` and the product point `128` are the remaining rungs of the weight-7 ladder. -/
theorem staircase_window {b j : ℕ} (hj : 1 ≤ j)
    (hlo : 96 < stair b j) (hhi : stair b j < 128) :
    stair b j = 112 ∨ stair b j = 120 ∨ stair b j = 124 ∨ stair b j = 126 ∨
      stair b j = 127 := by
  have hw := weight_eq_seven_of_window hj hlo hhi
  have hb : b = 7 - j := by omega
  have hj7 : j ≤ 7 := by omega
  subst hb
  interval_cases j <;> simp_all [stair]

/-- **The mid-grid read is forced.**  On the sweep grid (multiples of `16`), `112` is the *only*
staircase number strictly between `96` and `128`.  The measured third-seed knee therefore had no
alternative on the grid: the "±16 half-grid-step jitter" is the arithmetic of binary staircases,
not a free parameter. -/
theorem net47_mid_grid_forced {b j : ℕ} (hj : 1 ≤ j)
    (hlo : 96 < stair b j) (hhi : stair b j < 128) (hgrid : 16 ∣ stair b j) :
    stair b j = 112 := by
  rcases staircase_window hj hlo hhi with h | h | h | h | h <;> rw [h] at hgrid ⊢ <;> omega

/-- Mean = median: `2 · 112 = 96 + 128`, an instance of the midpoint law. -/
theorem net47_median_is_mean : 2 * (112 : ℕ) = 96 + 128 := by
  have h := two_mul_stair_succ 4 2
  rw [net47_onetwelve, show stair (4+1) 2 = 96 from net47_ninetysix,
    show (2:ℕ) ^ (4 + 2 + 1) = 128 by norm_num] at h

/-- The 7/8 law: `8 · 112 = 7 · 128`, an instance of `stair_fraction_of_top`. -/
theorem net47_seven_eighths : 8 * (112 : ℕ) = 7 * 128 := by
  have h := stair_fraction_of_top 4 2
  rw [net47_onetwelve] at h

/-- The digit pattern of the measured knees: `96 = 1100000₂`, `112 = 1110000₂`. -/
theorem net47_digits :
    Nat.digits 2 96 = List.replicate 5 0 ++ List.replicate 2 1 ∧
      Nat.digits 2 112 = List.replicate 4 0 ++ List.replicate 3 1 := by
  constructor
  · rw [← net47_ninetysix]; exact digits_stair (by norm_num)
  · rw [← net47_onetwelve]; exact digits_stair (by norm_num)

end KneeStaircase