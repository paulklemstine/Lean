import Mathlib
import Novelty.ThueMorsePowerValuation

/-!
# The parity shadow of Thue–Morse convolution powers

Working modulo `2`, the Thue–Morse sign sequence `tmsign` collapses to the constant
`1` (every sign is `±1`, and `±1 ≡ 1 (mod 2)`).  Consequently the `m`-fold
convolution `tconv m` becomes, modulo `2`, an iterated partial-sum operator applied
to the all-ones sequence.  The hockey-stick identity then identifies the result with
a single binomial coefficient:

* `tmsign_zmod2`     : `(tmsign n : ZMod 2) = 1`.
* `tconv_succ_zmod2` : `(tconv (m+1) n : ZMod 2) = (Nat.choose (n+m) m : ZMod 2)`.

Specializing recovers explicit parities of the low convolution powers:

* `t1_odd`          : `tconv 1 n` is always odd.
* `t2_parity`       : `tconv 2 n ≡ n + 1 (mod 2)`.
* `t2_odd_iff_even` : `tconv 2 n` is odd iff `n` is even.

The argument is non-circular: `tconv_succ_zmod2` is proved by induction on `m` using
only the defining recurrence `tconv_succ`, the base case `tconv_one`, the sign fact
`tmsign_zmod2`, and the hockey-stick identity `Nat.sum_range_add_choose`.
-/

namespace ThueMorse

open Finset

/-- Modulo `2`, every Thue–Morse sign equals `1`: `tmsign n = (-1) ^ (…)`, and
`(-1 : ZMod 2) = 1`. -/
theorem tmsign_zmod2 (n : ℕ) : (tmsign n : ZMod 2) = 1 := by
  unfold tmsign
  push_cast
  rw [show (-1 : ZMod 2) = 1 from by decide, one_pow]

/-- The parity shadow of the convolution powers: modulo `2`, the `(m+1)`-fold
convolution of the Thue–Morse signs is the binomial coefficient `C(n+m, m)`.

Proof by induction on `m`.  The base case `m = 0` reduces to `tconv 1 = tmsign` and
`tmsign ≡ 1`.  In the inductive step the defining recurrence rewrites
`tconv (m+2) n` as `∑_{k≤n} tconv (m+1) k * tmsign (n-k)`; modulo `2` each
`tmsign (n-k)` is `1` and the inductive hypothesis turns the summand into
`C(k+m, m)`, whence the hockey-stick identity `Nat.sum_range_add_choose` collapses
the sum to `C(n+m+1, m+1)`. -/
theorem tconv_succ_zmod2 (m n : ℕ) :
    (tconv (m + 1) n : ZMod 2) = (Nat.choose (n + m) m : ZMod 2) := by
  induction m generalizing n with
  | zero => rw [tconv_one, tmsign_zmod2]; simp
  | succ m ih =>
    rw [tconv_succ]
    push_cast
    rw [Finset.sum_congr rfl (fun k _ => by rw [tmsign_zmod2, mul_one, ih k])]
    rw [← Nat.cast_sum, Nat.sum_range_add_choose n m, Nat.add_assoc]

/-- Bridge from a `ZMod 2` equality of integer casts to an equality of remainders. -/
private lemma int_emod_two_of_zmod (a b : ℤ) (h : (a : ZMod 2) = (b : ZMod 2)) :
    a % 2 = b % 2 := by
  rwa [ZMod.intCast_eq_intCast_iff, Int.ModEq] at h

/-- The one-fold convolution `tconv 1 = tmsign` is always odd, since each sign is
`±1`. -/
theorem t1_odd (n : ℕ) : tconv 1 n % 2 = 1 := by
  rw [tconv_one]
  have hmul : tmsign n * tmsign n = 1 := by rw [← pow_two]; exact tmsign_sq n
  rcases mul_self_eq_one_iff.mp hmul with h1 | h1 <;> rw [h1] <;> decide

/-- The two-fold convolution has the parity of `n + 1`: this is `tconv_succ_zmod2`
with `m = 1`, using `C(n+1, 1) = n + 1`. -/
theorem t2_parity (n : ℕ) : tconv 2 n % 2 = ((n : ℤ) + 1) % 2 := by
  have h := tconv_succ_zmod2 1 n
  apply int_emod_two_of_zmod
  rw [h, Nat.choose_one_right]
  push_cast
  ring

/-- The two-fold convolution `tconv 2 n` is odd exactly when `n` is even. -/
theorem t2_odd_iff_even (n : ℕ) : tconv 2 n % 2 = 1 ↔ n % 2 = 0 := by
  rw [t2_parity]
  omega

end ThueMorse