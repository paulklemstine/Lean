import Mathlib

/-!
# Thue–Morse sign sequence and its convolution powers

This file sets up the basic objects studied in `ThueMorsePowerParityShadow.lean`:

* `tmsign n = (-1) ^ (number of binary ones of n)`, the Thue–Morse sign sequence.
* `tconv m n`, the `m`-fold (Cauchy) convolution of the Thue–Morse sign sequence,
  defined recursively so that `tconv 1 = tmsign`.

We record the recurrence `tconv_succ`, the base value `tconv_one`, and the key
algebraic fact `tmsign_sq : tmsign n ^ 2 = 1` (the signs are `±1`).
-/

namespace ThueMorse

open Finset

/-- The Thue–Morse sign at `n`: `(-1)` raised to the number of `1`-bits of `n`
(equivalently, the digit sum of `n` in base `2`). -/
def tmsign (n : ℕ) : ℤ := (-1) ^ (Nat.digits 2 n).sum

/-- The `m`-fold convolution of the Thue–Morse sign sequence.
`tconv 0` is the convolution unit (`1` at `0`), and each extra factor convolves
with one more copy of `tmsign`, so that `tconv 1 = tmsign`. -/
def tconv : ℕ → ℕ → ℤ
  | 0, n => if n = 0 then 1 else 0
  | (m + 1), n => ∑ k ∈ Finset.range (n + 1), tconv m k * tmsign (n - k)

@[simp] lemma tconv_zero (n : ℕ) : tconv 0 n = if n = 0 then 1 else 0 := rfl

/-- The defining convolution recurrence. -/
lemma tconv_succ (m n : ℕ) :
    tconv (m + 1) n = ∑ k ∈ Finset.range (n + 1), tconv m k * tmsign (n - k) := rfl

/-- The Thue–Morse signs square to `1`. -/
lemma tmsign_sq (n : ℕ) : tmsign n ^ 2 = 1 := by
  unfold tmsign
  rw [← pow_mul]
  exact Even.neg_one_pow ⟨_, by ring⟩

/-- The one-fold convolution is just the Thue–Morse sign sequence. -/
lemma tconv_one (n : ℕ) : tconv 1 n = tmsign n := by
  show (∑ k ∈ Finset.range (n + 1), tconv 0 k * tmsign (n - k)) = tmsign n
  rw [Finset.sum_eq_single 0]
  · simp [tconv]
  · intro k _ hk0; simp [tconv, hk0]
  · intro h; exact absurd (Finset.mem_range.mpr (Nat.succ_pos n)) h

end ThueMorse