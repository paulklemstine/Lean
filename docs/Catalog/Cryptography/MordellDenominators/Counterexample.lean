import Cryptography.MordellDenominators.Basic
import Cryptography.MordellDenominators.Valuation
import Cryptography.MordellDenominators.Criterion

/-!
# The "only bad primes" conjecture is false: the curve `E_55`

The conjecture under scrutiny states that for `E_N : y² = x³ + N` with
`N = p q` a semiprime, every prime occurring in a denominator of `x(nP)` is a
prime of bad reduction, i.e. divides `Δ = -432 N²`, i.e. lies in `{2, 3, p, q}`.

Here we refute it with a completely explicit counterexample and, more
importantly, show that the failure is *permanent*: the offending good prime
never leaves the orbit.

* `MordellDenominators.N55.den_dblX : (dblX 55 9).den = 3136 = 2⁶ · 7²`;
* `MordellDenominators.N55.seven_good : GoodPrime 55 7` — `7 ∤ 6 · 55` and
  `7 ∤ Δ`;
* `MordellDenominators.N55.not_onlyBadPrimes` — the conjecture fails;
* `MordellDenominators.N55.five_not_dvd_den`,
  `MordellDenominators.N55.eleven_not_dvd_den` — worse, the two primes one
  would like to read off, `5` and `11`, are *absent* from that denominator;
* `MordellDenominators.N55.seven_dvd_den_orbit` — `7` divides the denominator
  of the `x`-coordinate of `2ⁿ P` for **every** `n ≥ 1`.
-/

namespace MordellDenominators
namespace N55

/-- `P = (9, 28)` lies on `E₅₅ : y² = x³ + 55` (indeed `28² = 784 = 9³ + 55`). -/
theorem P_onCurve : OnCurve 55 9 28 := by
  unfold OnCurve; norm_num

/-- The duplication formula gives `x(2P) = 2601/3136`. -/
theorem dblX_eq : dblX 55 9 = 2601 / 3136 := by
  unfold dblX; norm_num

/-- The denominator of `x(2P)` is `3136 = 2⁶ · 7²`. -/
theorem den_dblX : (dblX 55 9).den = 3136 := by
  unfold dblX; norm_num

/-- `3136 = 2⁶ · 7²`, so the only primes involved are `2` and `7`. -/
theorem den_factorisation : (dblX 55 9).den = 2 ^ 6 * 7 ^ 2 := by
  rw [den_dblX]; norm_num

/-- `7` divides the denominator of `x(2P)`. -/
theorem seven_dvd_den : 7 ∣ (dblX 55 9).den := by
  rw [den_dblX]; norm_num

/-- `7` is a prime of **good** reduction for `E₅₅`: it does not divide `6·55`. -/
theorem seven_good : GoodPrime 55 7 := by
  refine ⟨by norm_num, ?_⟩
  decide

/-- `7` does not divide the discriminant `Δ = -432 · 55²` either. -/
theorem seven_not_dvd_disc : ¬ ((7 : ℤ) ∣ disc 55) := by
  unfold disc; decide

/-- The prime `5 ∣ 55` does **not** occur in the denominator of `x(2P)`. -/
theorem five_not_dvd_den : ¬ (5 ∣ (dblX 55 9).den) := by
  rw [den_dblX]; norm_num

/-- The prime `11 ∣ 55` does **not** occur in the denominator of `x(2P)`. -/
theorem eleven_not_dvd_den : ¬ (11 ∣ (dblX 55 9).den) := by
  rw [den_dblX]; norm_num

/-- The first doubling of `P` in the iterated orbit is the duplication. -/
theorem dblIter_one : (dblIter 55 1 (9, 28)).1 = dblX 55 9 := by
  simp [dblIter, dbl]

/-- **The conjecture is false.**  For `N = 55 = 5 · 11` and `P = (9, 28)` the
prime `7`, of good reduction, divides the denominator of `x(2P)`. -/
theorem not_onlyBadPrimes : ¬ OnlyBadPrimes 55 (9, 28) := by
  intro hcon
  have h7 : (7 : ℤ) ∣ 6 * 55 := by
    refine hcon 1 7 (by norm_num) ?_
    rw [dblIter_one]
    exact seven_dvd_den
  exact seven_good.2 h7

/-! ## The failure is permanent -/

/-- `E₅₅` has no rational point of order two: `m³ + 55 = 0` is insoluble in `ℤ`. -/
theorem no_int_root : ∀ m : ℤ, m ^ 3 + 55 ≠ 0 := by
  intro m hm
  have hpos : ∀ z : ℤ, 0 < z ^ 2 - 2 * z + 4 := by intro z; nlinarith [sq_nonneg (z - 1)]
  have h2 : -4 ≤ m := by
    by_contra h
    push_neg at h
    have hm5 : m + 5 ≤ 0 := by omega
    nlinarith [mul_nonneg (neg_nonneg.mpr hm5) (le_of_lt (hpos (m + 5)))]
  have h1 : m ≤ -3 := by
    by_contra h
    push_neg at h
    have hm2 : (0 : ℤ) ≤ m + 2 := by omega
    nlinarith [mul_nonneg hm2 (le_of_lt (hpos (m + 2)))]
  interval_cases m <;> omega

/-- Consequently no point of `E₅₅(ℚ)` has vanishing `y`-coordinate. -/
theorem no_two_torsion_55 : ∀ x y : ℚ, OnCurve 55 x y → y ≠ 0 :=
  fun _ _ h => no_two_torsion 55 no_int_root h

/-- **The good prime `7` never leaves the orbit**: it divides the denominator
of the `x`-coordinate of `2ⁿ P` for every `n ≥ 1`, although `7` is a prime of
good reduction for `E₅₅`. -/
theorem seven_dvd_den_orbit (n : ℕ) (hn : 1 ≤ n) :
    7 ∣ (dblIter 55 n (9, 28)).1.den := by
  obtain ⟨m, rfl⟩ : ∃ m, n = 1 + m := ⟨n - 1, by omega⟩
  refine dvd_den_dblIter_of_dvd no_two_torsion_55 (P := (9, 28)) P_onCurve
    (by norm_num) ?_ m
  rw [dblIter_one]
  exact seven_dvd_den

/-- The `7`-adic valuation of the denominator of `x(2P)` equals `2`. -/
theorem seven_val_dblX : padicValNat 7 (dblX 55 9).den = 2 := by
  haveI : Fact (Nat.Prime 7) := ⟨by norm_num⟩
  rw [den_dblX, show (3136 : ℕ) = 7 ^ 2 * 64 by norm_num,
    padicValNat.mul (by positivity) (by norm_num), padicValNat.prime_pow,
    padicValNat.eq_zero_of_not_dvd (by norm_num)]

/-- **The good prime `7` occurs with the same exponent `2` at every stage of
the orbit**: `padicVal₇(den x(2ⁿ P)) = 2` for all `n ≥ 1`. -/
theorem seven_val_orbit (n : ℕ) (hn : 1 ≤ n) :
    padicValNat 7 (dblIter 55 n (9, 28)).1.den = 2 := by
  obtain ⟨m, rfl⟩ : ∃ m, n = 1 + m := ⟨n - 1, by omega⟩
  have hd : (7 : ℕ) ∣ (dblIter 55 1 (9, 28)).1.den := by
    rw [dblIter_one_fst]; exact seven_dvd_den
  have hconst := padicValNat_den_dblIter_const no_two_torsion_55 (P := (9, 28))
    P_onCurve (by norm_num) (by norm_num) hd m
  rw [hconst, dblIter_one_fst]
  exact seven_val_dblX

/-- Sharper form of the refutation: for `E₅₅` and `P = (9,28)` the denominator
of `x(2P)` involves a good prime and involves *neither* of the two primes of
`N = 5 · 11`.  So the denominator at this step reveals a prime of good
reduction rather than the factorisation of `N`. -/
theorem denominator_hides_factorisation :
    7 ∣ (dblX 55 9).den ∧ ¬ ((7 : ℤ) ∣ disc 55) ∧
      ¬ (5 ∣ (dblX 55 9).den) ∧ ¬ (11 ∣ (dblX 55 9).den) :=
  ⟨seven_dvd_den, seven_not_dvd_disc, five_not_dvd_den, eleven_not_dvd_den⟩

end N55

/-! ## A second semiprime counterexample, via the criterion -/

namespace N33

/-- `P = (-2, 5)` lies on `E₃₃ : y² = x³ + 33` (`25 = -8 + 33`). -/
theorem P_onCurve : OnCurve 33 (-2) 5 := by
  unfold OnCurve; norm_num

/-- `x(2P) = 136/25` for `N = 33 = 3 · 11` and `P = (-2, 5)`. -/
theorem dblX_eq : dblX 33 (-2) = 136 / 25 := by
  unfold dblX; norm_num

/-- Its denominator is `25 = 5²`, and `5` is a prime of good reduction. -/
theorem den_dblX : (dblX 33 (-2)).den = 25 := by
  unfold dblX; norm_num

/-- `5` is good for `E₃₃`: `5 ∤ 6 · 33 = 198`. -/
theorem five_good : GoodPrime 33 5 := ⟨by norm_num, by decide⟩

/-- **A second counterexample**, obtained from the general criterion applied to
the integral point `(-2, 5)`: the good prime `5` divides `y`, hence divides the
denominator of `x(2P)`.  Note that `5 ∤ 33`, so again the denominator exposes a
prime unrelated to the factorisation `33 = 3 · 11`. -/
theorem not_onlyBadPrimes : ¬ OnlyBadPrimes 33 ((-2 : ℚ), (5 : ℚ)) := by
  have h := not_onlyBadPrimes_of_intPoint (N := 33) (x := -2) (y := 5)
    (by norm_num) (by norm_num) (l := 5) (by norm_num) (by norm_num) (by decide)
  simpa using h

end N33
end MordellDenominators