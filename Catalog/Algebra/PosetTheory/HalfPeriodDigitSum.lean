import Mathlib

/-!
# Base-`b` digit sums and the Midy pairing

`Shared/PosetTheory/HalfPeriodMidy.lean` reduces the generalized Midy theorem to a single
combinatorial input: the digit sum of `k · (b^h − 1)` for `1 ≤ k ≤ b^h − 1`.  This module
supplies the digit sum function and that input.

* `dsum b n` — the sum of the base-`b` digits of `n`.
* `dsum_rec` — the defining recursion `dsum b n = n % b + dsum b (n / b)`.
* `dsum_add_mul_pow` — digit sums split across a power of the base:
  `dsum b (x + b^h * q) = dsum b x + dsum b q` whenever `x < b^h`.
* `dsum_complement_add` — the *nines complement* identity in additive form: if
  `x + y + 1 = b^h` then `dsum b x + dsum b y = (b − 1) · h`.
* `dsum_midy` — the Midy input: for `1 ≤ k ≤ b^h − 1`,
  `dsum b (k · (b^h − 1)) = (b − 1) · h`.

The proof of `dsum_midy` is the classical two-block picture:
`k · (b^h − 1) = (k − 1) · b^h + (b^h − k)`, whose low block `b^h − k` and high block
`k − 1` are digitwise complementary, so each of the `h` digit positions contributes
exactly `b − 1`.
-/

namespace HalfPeriodDigitSum

/-- The sum of the base-`b` digits of `n`. -/
def dsum (b n : ℕ) : ℕ := (Nat.digits b n).sum

@[simp] theorem dsum_zero (b : ℕ) : dsum b 0 = 0 := by simp [dsum]

/-- The defining recursion of the digit sum. -/
theorem dsum_rec {b : ℕ} (hb : 2 ≤ b) (n : ℕ) : dsum b n = n % b + dsum b (n / b) := by
  rcases Nat.eq_zero_or_pos n with rfl | hn
  · simp
  · rw [dsum, Nat.digits_def' (by omega : 1 < b) hn]
    simp [dsum]

/-- Numbers below the base are their own digit sum. -/
theorem dsum_of_lt {b n : ℕ} (hb : 2 ≤ b) (hn : n < b) : dsum b n = n := by
  rw [dsum_rec hb n, Nat.mod_eq_of_lt hn, Nat.div_eq_of_lt hn, dsum_zero]
  omega

/-- **Splitting a digit sum at a power of the base.** -/
theorem dsum_add_mul_pow {b : ℕ} (hb : 2 ≤ b) :
    ∀ (h x q : ℕ), x < b ^ h → dsum b (x + b ^ h * q) = dsum b x + dsum b q := by
  intro h
  induction h with
  | zero =>
      intro x q hx
      have hx0 : x = 0 := by simpa using hx
      simp [hx0]
  | succ h ih =>
      intro x q hx
      have hb0 : 0 < b := by omega
      have hxb : x < b * b ^ h := by
        calc x < b ^ (h + 1) := hx
          _ = b * b ^ h := by ring
      have key : b ^ (h + 1) * q = b * (b ^ h * q) := by ring
      have hmod : (x + b ^ (h + 1) * q) % b = x % b := by
        rw [key, Nat.add_mul_mod_self_left]
      have hdiv : (x + b ^ (h + 1) * q) / b = x / b + b ^ h * q := by
        rw [key, Nat.add_mul_div_left _ _ hb0]
      have hxlt : x / b < b ^ h := Nat.div_lt_of_lt_mul hxb
      rw [dsum_rec hb (x + b ^ (h + 1) * q), hmod, hdiv, ih (x / b) q hxlt,
        dsum_rec hb x]
      omega

/-- **The nines-complement identity.**  If `x` and `y` are complementary `h`-digit strings,
i.e. `x + y + 1 = b^h`, then each of the `h` positions contributes a pair of digits
summing to `b − 1`, so `dsum b x + dsum b y = (b − 1) · h`. -/
theorem dsum_complement_add {b : ℕ} (hb : 2 ≤ b) :
    ∀ (h x y : ℕ), x + y + 1 = b ^ h → dsum b x + dsum b y = (b - 1) * h := by
  intro h
  induction h with
  | zero =>
      intro x y hxy
      obtain ⟨hx0, hy0⟩ : x = 0 ∧ y = 0 := by simpa using hxy
      simp [hx0, hy0]
  | succ h ih =>
      intro x y hxy
      have hb0 : 0 < b := by omega
      have hP : 0 < b ^ h := pow_pos hb0 h
      have hbP : b ^ (h + 1) = b * b ^ h := by ring
      rw [dsum_rec hb x, dsum_rec hb y]
      -- split both numbers into low digit and high part
      have hx : b * (x / b) + x % b = x := Nat.div_add_mod x b
      have hy : b * (y / b) + y % b = y := Nat.div_add_mod y b
      have hrb : x % b < b := Nat.mod_lt _ hb0
      have hsb : y % b < b := Nat.mod_lt _ hb0
      set r := x % b
      set s := y % b
      set x' := x / b
      set y' := y / b
      -- the two low digits are complementary
      have hsum : b * (x' + y') + (r + s + 1) = b * b ^ h := by
        rw [← hbP]
        rw [Nat.mul_add]
        omega
      have hdvd : b ∣ (r + s + 1) := by
        have heq : r + s + 1 = b * b ^ h - b * (x' + y') := by omega
        rw [heq]
        exact Nat.dvd_sub ⟨b ^ h, rfl⟩ ⟨x' + y', rfl⟩
      obtain ⟨c, hc⟩ := hdvd
      have hclt : c < 2 := by
        have : b * c < b * 2 := by omega
        exact Nat.lt_of_mul_lt_mul_left this
      have hcpos : 0 < c := by
        rcases Nat.eq_zero_or_pos c with rfl | hcp
        · omega
        · exact hcp
      have hc1 : c = 1 := by omega
      have hlow : r + s + 1 = b := by rw [hc, hc1, Nat.mul_one]
      -- hence the high parts are complementary one digit shorter
      have hhigh : x' + y' + 1 = b ^ h := by
        have h1 : b * (x' + y' + 1) = b * b ^ h := by
          rw [Nat.mul_add, Nat.mul_one]
          omega
        exact Nat.eq_of_mul_eq_mul_left hb0 h1
      have hihh := ih x' y' hhigh
      have hexp : (b - 1) * (h + 1) = (b - 1) * h + (b - 1) := by ring
      omega

/-- The nines-complement identity in subtractive form. -/
theorem dsum_complement {b : ℕ} (hb : 2 ≤ b) (h x : ℕ) (hx : x < b ^ h) :
    dsum b x + dsum b (b ^ h - 1 - x) = (b - 1) * h :=
  dsum_complement_add hb h x (b ^ h - 1 - x) (by omega)

/-- **The Midy input.**  For `1 ≤ k ≤ b^h − 1` the base-`b` digit sum of `k · (b^h − 1)`
is exactly `(b − 1) · h`. -/
theorem dsum_midy (b h k : ℕ) (hb : 2 ≤ b) (hk1 : 1 ≤ k) (hk2 : k ≤ b ^ h - 1) :
    dsum b (k * (b ^ h - 1)) = (b - 1) * h := by
  have hb0 : 0 < b := by omega
  have hpow : 0 < b ^ h := pow_pos hb0 h
  have hkP : k ≤ b ^ h := by omega
  -- the two-block decomposition
  have hdec : k * (b ^ h - 1) = (b ^ h - k) + b ^ h * (k - 1) := by
    zify [hk1, hkP, hpow]
    ring
  have hlow : b ^ h - k < b ^ h := by omega
  rw [hdec, dsum_add_mul_pow hb h _ (k - 1) hlow]
  exact dsum_complement_add hb h (b ^ h - k) (k - 1) (by omega)

end HalfPeriodDigitSum