import Mathlib
import Physics.PermutationReadoutCore
import Physics.PermutationReadoutAsymmetry
import Physics.PermutationReadoutBurnside
import Physics.PermutationReadoutJacobi
import Physics.PermutationReadoutExcess

/-!
# PERMORD: the worked instances, formally verified

The PERMORD experiment recorded four factorisations obtained from the cycle
spectrum of `x ↦ a·x` on `ZMod N` (`N = 143, 221, 899, 3127`) and the exact
cycle counts predicted by the stratification law.  This file certifies those
numbers inside Lean, and — the point of the paper — certifies the *separation*:
two multipliers of `ZMod 65` with the **same** `ord_N` but **different**
individual readouts, so that the cycle structure is strictly finer than the
lcm-datum available to unit-group probes.

## Main results

* `Physics.PermReadout.Examples.readout_143`, `readout_221`, `readout_899`,
  `readout_3127` — the readout returns the two prime factors.
* `Physics.PermReadout.Examples.cycleCount_143` — the cycle count `5` predicted
  by `cycleCount_semiprime`.
* `Physics.PermReadout.Examples.lcm_blind_65` — `ord_65(57) = ord_65(31) = 4`:
  the unit-group probe cannot tell the two multipliers apart.
* `Physics.PermReadout.Examples.readout_separates_65` — but their cycle
  readouts differ (`4` versus `1` on the stratum of `13`), and even their cycle
  counts differ (`17` versus `20`).
* `Physics.PermReadout.Examples.jacobi_from_readout_65` — the parity bit of the
  two separating cycle counts reproduces the Jacobi symbols `J(57|65) = 1` and
  `J(31|65) = −1`, computed independently by `norm_num`.
-/

namespace Physics.PermReadout.Examples

open Physics.PermReadout

/-! ## Concrete multiplicative orders

Each of these is a genuine order computation: the exponent is verified, and
every proper divisor obtained by dividing out a prime is verified to fail. -/

theorem ord_11_2 : orderOf (((2 : ℕ) : ZMod 11)) = 10 := by
  rw [Nat.cast_ofNat]
  apply orderOf_eq_of_pow_and_pow_div_prime (by norm_num) (by decide)
  intro r hr hdvd
  have : r ≤ 10 := Nat.le_of_dvd (by norm_num) hdvd
  interval_cases r <;> revert hdvd hr <;> decide

theorem ord_13_2 : orderOf (((2 : ℕ) : ZMod 13)) = 12 := by
  rw [Nat.cast_ofNat]
  apply orderOf_eq_of_pow_and_pow_div_prime (by norm_num) (by decide)
  intro r hr hdvd
  have : r ≤ 12 := Nat.le_of_dvd (by norm_num) hdvd
  interval_cases r <;> revert hdvd hr <;> decide

theorem ord_13_7 : orderOf (((7 : ℕ) : ZMod 13)) = 12 := by
  rw [Nat.cast_ofNat]
  apply orderOf_eq_of_pow_and_pow_div_prime (by norm_num) (by decide)
  intro r hr hdvd
  have : r ≤ 12 := Nat.le_of_dvd (by norm_num) hdvd
  interval_cases r <;> revert hdvd hr <;> decide

theorem ord_17_7 : orderOf (((7 : ℕ) : ZMod 17)) = 16 := by
  rw [Nat.cast_ofNat]
  apply orderOf_eq_of_pow_and_pow_div_prime (by norm_num) (by decide)
  intro r hr hdvd
  have : r ≤ 16 := Nat.le_of_dvd (by norm_num) hdvd
  interval_cases r <;> revert hdvd hr <;> decide

theorem ord_29_3 : orderOf (((3 : ℕ) : ZMod 29)) = 28 := by
  rw [Nat.cast_ofNat]
  apply orderOf_eq_of_pow_and_pow_div_prime (by norm_num) (by decide)
  intro r hr hdvd
  have : r ≤ 28 := Nat.le_of_dvd (by norm_num) hdvd
  interval_cases r <;> revert hdvd hr <;> decide

theorem ord_31_3 : orderOf (((3 : ℕ) : ZMod 31)) = 30 := by
  rw [Nat.cast_ofNat]
  apply orderOf_eq_of_pow_and_pow_div_prime (by norm_num) (by decide)
  intro r hr hdvd
  have : r ≤ 30 := Nat.le_of_dvd (by norm_num) hdvd
  interval_cases r <;> revert hdvd hr <;> decide

theorem ord_53_2 : orderOf (((2 : ℕ) : ZMod 53)) = 52 := by
  rw [Nat.cast_ofNat]
  apply orderOf_eq_of_pow_and_pow_div_prime (by norm_num) (by decide)
  intro r hr hdvd
  have : r ≤ 52 := Nat.le_of_dvd (by norm_num) hdvd
  interval_cases r <;> revert hdvd hr <;> decide

theorem ord_59_2 : orderOf (((2 : ℕ) : ZMod 59)) = 58 := by
  rw [Nat.cast_ofNat]
  apply orderOf_eq_of_pow_and_pow_div_prime (by norm_num) (by decide)
  intro r hr hdvd
  have : r ≤ 58 := Nat.le_of_dvd (by norm_num) hdvd
  interval_cases r <;> revert hdvd hr <;> decide

/-! ## The four recorded factorisations

In each case the cycle through the point `p` has length `ord_q(a)` and the cycle
through `q` has length `ord_p(a)`; for a multiplier that is primitive modulo
both factors this returns the unordered pair `{p, q}`. -/

/-- `N = 143 = 11·13`, `a = 2`: the two nontrivial cycle lengths are `12` and
`10`, and `12 + 1 = 13`, `10 + 1 = 11` are the prime factors. -/
theorem readout_143 :
    period (11 * 13) 2 11 + 1 = 13 ∧ period (11 * 13) 2 13 + 1 = 11 := by
  constructor
  · rw [period_at_prime_left (by norm_num), ord_13_2]
  · rw [period_at_prime_right (by norm_num), ord_11_2]

/-- `N = 221 = 13·17`, `a = 7`. -/
theorem readout_221 :
    period (13 * 17) 7 13 + 1 = 17 ∧ period (13 * 17) 7 17 + 1 = 13 := by
  constructor
  · rw [period_at_prime_left (by norm_num), ord_17_7]
  · rw [period_at_prime_right (by norm_num), ord_13_7]

/-- `N = 899 = 29·31`, `a = 3`. -/
theorem readout_899 :
    period (29 * 31) 3 29 + 1 = 31 ∧ period (29 * 31) 3 31 + 1 = 29 := by
  constructor
  · rw [period_at_prime_left (by norm_num), ord_31_3]
  · rw [period_at_prime_right (by norm_num), ord_29_3]

/-- `N = 3127 = 53·59`, `a = 2`. -/
theorem readout_3127 :
    period (53 * 59) 2 53 + 1 = 59 ∧ period (53 * 59) 2 59 + 1 = 53 := by
  constructor
  · rw [period_at_prime_left (by norm_num), ord_59_2]
  · rw [period_at_prime_right (by norm_num), ord_53_2]

/-! ## The exact cycle count for `N = 143` -/

theorem ord_143_2 : orderOf (((2 : ℕ) : ZMod (11 * 13))) = 60 := by
  rw [orderOf_eq_lcm (by norm_num) 2, ord_11_2, ord_13_2]
  decide

/-- The stratification law predicts `1 + 120/60 + 12/12 + 10/10 = 5` cycles for
the permutation `x ↦ 2·x` on `ZMod 143`. -/
theorem cycleCount_143 : cycleCount (11 * 13) 2 = 5 := by
  have h := cycleCount_semiprime (p := 11) (q := 13) (a := 2)
    (by norm_num) (by norm_num) (by norm_num) (by decide)
  rw [h, ord_143_2, ord_11_2, ord_13_2,
    show Nat.totient (11 * 13) = 120 from by
      rw [Nat.totient_mul (by norm_num), Nat.totient_prime (by norm_num),
        Nat.totient_prime (by norm_num)]]

/-- The primitive-multiplier collapse `#cycles = gcd(p−1, q−1) + 3`, checked on
`N = 899 = 29·31` with `a = 3`: `gcd(28, 30) + 3 = 5`. -/
theorem cycleCount_899 : cycleCount (29 * 31) 3 = 5 := by
  rw [cycleCount_primitive (by norm_num) (by norm_num) (by norm_num) (by decide)
    (by rw [ord_29_3]) (by rw [ord_31_3])]
  decide

/-- The same collapse for `N = 143 = 11·13`, `a = 2`: `gcd(10, 12) + 3 = 5`,
in agreement with the direct computation `cycleCount_143`. -/
theorem cycleCount_143_via_gcd : cycleCount (11 * 13) 2 = Nat.gcd 10 12 + 3 := by
  rw [cycleCount_primitive (by norm_num) (by norm_num) (by norm_num) (by decide)
    (by rw [ord_11_2]) (by rw [ord_13_2])]

/-! ## Closing the lcm-blindness loophole: a concrete separation

`N = 65 = 5·13`.  The multipliers `57` and `31` have the *same* order `4` in the
unit group of `ZMod 65`, so every unit-group probe — every function of
`ord_N(a) = lcm(ord_5(a), ord_13(a))` — is blind to the difference between them.
Their individual orders differ (`ord_5(57) = 4` but `ord_5(31) = 1`), and the
cycle structure of the permutation of the whole ring sees exactly that. -/

theorem ord_5_57 : orderOf (((57 : ℕ) : ZMod 5)) = 4 := by
  rw [Nat.cast_ofNat]
  apply orderOf_eq_of_pow_and_pow_div_prime (by norm_num) (by decide)
  intro r hr hdvd
  have : r ≤ 4 := Nat.le_of_dvd (by norm_num) hdvd
  interval_cases r <;> revert hdvd hr <;> decide

theorem ord_5_31 : orderOf (((31 : ℕ) : ZMod 5)) = 1 := by
  rw [Nat.cast_ofNat]
  exact orderOf_eq_one_iff.mpr (by decide)

theorem ord_13_57 : orderOf (((57 : ℕ) : ZMod 13)) = 4 := by
  rw [Nat.cast_ofNat]
  apply orderOf_eq_of_pow_and_pow_div_prime (by norm_num) (by decide)
  intro r hr hdvd
  have : r ≤ 4 := Nat.le_of_dvd (by norm_num) hdvd
  interval_cases r <;> revert hdvd hr <;> decide

theorem ord_13_31 : orderOf (((31 : ℕ) : ZMod 13)) = 4 := by
  rw [Nat.cast_ofNat]
  apply orderOf_eq_of_pow_and_pow_div_prime (by norm_num) (by decide)
  intro r hr hdvd
  have : r ≤ 4 := Nat.le_of_dvd (by norm_num) hdvd
  interval_cases r <;> revert hdvd hr <;> decide

/-- **The unit-group probe is blind.**  `ord_65(57) = ord_65(31) = 4`. -/
theorem lcm_blind_65 :
    orderOf (((57 : ℕ) : ZMod (5 * 13))) = orderOf (((31 : ℕ) : ZMod (5 * 13))) := by
  rw [orderOf_eq_lcm (by norm_num) 57,
    orderOf_eq_lcm (by norm_num) 31,
    ord_5_57, ord_13_57, ord_5_31, ord_13_31]
  decide

/-- **The permutation readout is not blind.**  On the stratum of `13` the two
multipliers have cycle lengths `4` and `1`; consequently their cycle counts
differ (`17` versus `20`) even though their orders in `(ZMod 65)ˣ` agree. -/
theorem readout_separates_65 :
    period (5 * 13) 57 13 = 4 ∧ period (5 * 13) 31 13 = 1 ∧
      cycleCount (5 * 13) 57 = 17 ∧ cycleCount (5 * 13) 31 = 20 := by
  have htot : Nat.totient (5 * 13) = 48 := by
    rw [Nat.totient_mul (by norm_num), Nat.totient_prime (by norm_num),
      Nat.totient_prime (by norm_num)]
  have h57 : period (5 * 13) 57 13 = 4 := by
    rw [period_at_prime_right (p := 5) (q := 13) (by norm_num), ord_5_57]
  have h31 : period (5 * 13) 31 13 = 1 := by
    rw [period_at_prime_right (p := 5) (q := 13) (by norm_num), ord_5_31]
  refine ⟨h57, h31, ?_, ?_⟩
  · have h := cycleCount_semiprime (p := 5) (q := 13) (a := 57)
      (by norm_num) (by norm_num) (by norm_num) (by decide)
    rw [h, orderOf_eq_lcm (by norm_num) 57,
      ord_5_57, ord_13_57, htot]
    decide
  · have h := cycleCount_semiprime (p := 5) (q := 13) (a := 31)
      (by norm_num) (by norm_num) (by norm_num) (by decide)
    rw [h, orderOf_eq_lcm (by norm_num) 31,
      ord_5_31, ord_13_31, htot]
    decide

/-! ## The Burnside identity on the separating pair

`ord_65(57)·#cycles = 4·17 = 68 = 65 + 1 + 1 + 1` and
`ord_65(31)·#cycles = 4·20 = 80 = 65 + 5 + 5 + 5`: the excess of the second
multiplier is carried entirely by nontrivial Pollard gcds — and those gcds are
themselves the factor `5`.  The extra cycles are not new information; they are
the classical `p−1` probes in disguise. -/

theorem ord_65_57 : orderOf (((57 : ℕ) : ZMod (5 * 13))) = 4 := by
  rw [orderOf_eq_lcm (by norm_num) 57, ord_5_57, ord_13_57]
  decide

theorem ord_65_31 : orderOf (((31 : ℕ) : ZMod (5 * 13))) = 4 := by
  rw [orderOf_eq_lcm (by norm_num) 31, ord_5_31, ord_13_31]
  decide

theorem burnside_65_57 :
    4 * cycleCount (5 * 13) 57 = ∑ k ∈ Finset.range 4, Nat.gcd (5 * 13) (57 ^ k - 1) := by
  have h := orderOf_mul_cycleCount_eq_sum_gcd (N := 5 * 13) (a := 57) (by norm_num) (by decide)
  rwa [ord_65_57] at h

theorem burnside_65_31 :
    4 * cycleCount (5 * 13) 31 = ∑ k ∈ Finset.range 4, Nat.gcd (5 * 13) (31 ^ k - 1) := by
  have h := orderOf_mul_cycleCount_eq_sum_gcd (N := 5 * 13) (a := 31) (by norm_num) (by decide)
  rwa [ord_65_31] at h

/-- The extra cycles of the multiplier `31` come with a Pollard hit: already
`k = 1` gives `gcd(65, 30) = 5`, a nontrivial factor of `65`. -/
theorem pollard_hit_65_31 :
    ∃ k ∈ Finset.Ico 1 4, 1 < Nat.gcd (5 * 13) (31 ^ k - 1) ∧
      Nat.gcd (5 * 13) (31 ^ k - 1) ∣ 5 * 13 := by
  refine ⟨1, by decide, by decide, Nat.gcd_dvd_left _ _⟩

/-- The multiplier `57`, with the same global order, produces no Pollard hit —
and correspondingly no extra cycles. -/
theorem no_pollard_hit_65_57 :
    (∀ k ∈ Finset.Ico 1 4, Nat.gcd (5 * 13) (57 ^ k - 1) = 1) ∧
      4 * cycleCount (5 * 13) 57 = 5 * 13 + (4 - 1) := by
  refine ⟨by decide, ?_⟩
  have h := (cycleCount_minimal_iff_no_pollard_hit (N := 5 * 13) (a := 57)
    (by norm_num) (by decide)).mpr
  rw [ord_65_57] at h
  exact h (by decide)

/-! ## The parity bit of the separating pair is the Jacobi symbol

The two multipliers of `ZMod 65` that the unit-group probe cannot distinguish
have cycle counts `17` and `20`, hence permutation parities `65 − 17 = 48`
(even) and `65 − 20 = 45` (odd).  By `jacobi_readout_parity` this predicts
`J(57|65) = 1` and `J(31|65) ≠ 1`; both predictions are confirmed by an
independent evaluation of the Jacobi symbol.  So the separation achieved by the
readout is invisible at the level of the sign: the sign is a free quantity. -/

theorem jacobi_from_readout_65 :
    jacobiSym ((57 : ℕ) : ℤ) (5 * 13) = 1 ∧ jacobiSym ((31 : ℕ) : ℤ) (5 * 13) ≠ 1 := by
  have hpar57 := jacobi_readout_parity (p := 5) (q := 13) (a := 57)
    (by norm_num) (by norm_num) (by norm_num) (by norm_num) (by norm_num) (by decide)
  have hpar31 := jacobi_readout_parity (p := 5) (q := 13) (a := 31)
    (by norm_num) (by norm_num) (by norm_num) (by norm_num) (by norm_num) (by decide)
  obtain ⟨-, -, h57, h31⟩ := readout_separates_65
  rw [h57] at hpar57
  rw [h31] at hpar31
  exact ⟨hpar57.mpr (by norm_num), fun h => by simpa using hpar31.mp h⟩

/-- Independent confirmation of the two Jacobi symbols predicted above by the
cycle counts alone. -/
theorem jacobi_direct_65 :
    jacobiSym ((57 : ℕ) : ℤ) (5 * 13) = 1 ∧ jacobiSym ((31 : ℕ) : ℤ) (5 * 13) = -1 := by
  constructor <;> norm_num

/-! ## The excess formula on the separating pair

For `a = 57` the two local orders are `4` and `4`, so `gcd = 4` and the surplus
is `(4−1)·1·3 = 9`: the prime readouts have `2` and `4` cycles, the composite
one `2·4 + 9 = 17`.  For `a = 31` the local orders are `1` and `4`, coprime, so
the surplus is `0` and the composite count is exactly `5·4 = 20`.  The pair
therefore realises both extremes of `cycleCount_eq_prod_iff_coprime_orders`. -/

theorem excess_65_57 :
    cycleCount 5 57 * cycleCount 13 57 + 9 = cycleCount (5 * 13) 57 := by
  have h := cycleCount_excess (p := 5) (q := 13) (a := 57)
    (by norm_num) (by norm_num) (by norm_num) (by decide)
  rw [cycleCount_prime (p := 5) (a := 57) (by norm_num) (by decide),
    cycleCount_prime (p := 13) (a := 57) (by norm_num) (by decide),
    ord_5_57, ord_13_57] at h ⊢
  rw [h]
  decide

theorem excess_65_31_eq_zero :
    cycleCount 5 31 * cycleCount 13 31 = cycleCount (5 * 13) 31 := by
  have h := (cycleCount_eq_prod_iff_coprime_orders (p := 5) (q := 13) (a := 31)
    (by norm_num) (by norm_num) (by norm_num) (by decide)).mpr
  rw [ord_5_31, ord_13_31] at h
  exact (h (by decide)).symm

end Physics.PermReadout.Examples