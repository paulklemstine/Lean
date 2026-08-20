/-
# Infinite families above the one-bit cap

The exact table of values covers finitely many cyclic orders.  Combining the
CRT additivity law with the non-negativity of the counting channel promotes it
to *infinite families*: every cyclic order whose `2`-primary part is `4`, `8` or
`16` breaks the one-bit binary-fork cap, no matter how complicated its odd part
is, and every order with `2`-primary part `2` attains the cap.

This is the structural form of the experimental "growth law": the `2`-primary
component alone already pushes the channel above one bit, and the odd part can
only add.
-/
import Catalog.Shared.CyclicTypeChannelCRT
import Catalog.Shared.CyclicTypeChannelCap
import Catalog.Shared.CyclicTypeChannelNonneg

namespace CyclicTypeChannel

open Finset

/-- The channel of any cyclic order is non-negative. -/
theorem Ipair_nonneg (n : ℕ) : 0 ≤ Ipair n := mutInfo_nonneg _ _ _

/-- `2 ^ j` is coprime to every odd number. -/
theorem coprime_two_pow_odd {m : ℕ} (hm : Odd m) (j : ℕ) : Nat.Coprime (2 ^ j) m :=
  Nat.Coprime.pow_left j (Nat.coprime_two_left.mpr hm)

/-- **The cap is attained by every order with `2`-primary part `2`.** -/
theorem Ipair_two_mul_odd {m : ℕ} (hm0 : 0 < m) (hm : Odd m) : 1 ≤ Ipair (2 * m) := by
  have h : Nat.Coprime 2 m := by simpa using coprime_two_pow_odd hm 1
  rw [Ipair_mul_of_coprime (by norm_num) hm0 h, Ipair_val_2]
  linarith [Ipair_nonneg m]

/-- **Every order with `2`-primary part `4` is above the cap**, whatever its odd
part: an infinite family of symmetric semiprime forks carrying more than one
bit. -/
theorem Ipair_four_mul_odd {m : ℕ} (hm0 : 0 < m) (hm : Odd m) : (5 : ℝ) / 4 ≤ Ipair (4 * m) := by
  have h : Nat.Coprime 4 m := by simpa using coprime_two_pow_odd hm 2
  rw [Ipair_mul_of_coprime (by norm_num) hm0 h, Ipair_val_4]
  linarith [Ipair_nonneg m]

/-- **Every order with `2`-primary part `8` is above the cap.** -/
theorem Ipair_eight_mul_odd {m : ℕ} (hm0 : 0 < m) (hm : Odd m) :
    (21 : ℝ) / 16 ≤ Ipair (8 * m) := by
  have h : Nat.Coprime 8 m := by simpa using coprime_two_pow_odd hm 3
  rw [Ipair_mul_of_coprime (by norm_num) hm0 h, Ipair_val_8]
  linarith [Ipair_nonneg m]

/-- **Every order with `2`-primary part `16` is above the cap.** -/
theorem Ipair_sixteen_mul_odd {m : ℕ} (hm0 : 0 < m) (hm : Odd m) :
    (85 : ℝ) / 64 ≤ Ipair (16 * m) := by
  have h : Nat.Coprime 16 m := by simpa using coprime_two_pow_odd hm 4
  rw [Ipair_mul_of_coprime (by norm_num) hm0 h, Ipair_val_16]
  linarith [Ipair_nonneg m]

/-- **An infinite family strictly above the binary-fork cap.**  For *every* odd
`m`, the cyclic order `4m` carries strictly more than one bit — the one-bit cap
of the binary symmetric fork fails on an infinite set of fields, not just on the
finitely many computed examples. -/
theorem above_cap_infinite_family {m : ℕ} (hm0 : 0 < m) (hm : Odd m) : 1 < Ipair (4 * m) := by
  have := Ipair_four_mul_odd hm0 hm
  linarith

/-- The above-cap orders `{4m : m odd}` are unbounded, so no finite computation
could have settled the question. -/
theorem above_cap_unbounded (B : ℕ) : ∃ n, B < n ∧ 1 < Ipair n := by
  refine ⟨4 * (2 * B + 1), ?_, above_cap_infinite_family (by omega) ⟨B, by ring⟩⟩
  omega

end CyclicTypeChannel