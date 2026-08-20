/-
# The prime `ℓ = 2`: where the naive `q`-Kummer recipe breaks, and how to repair it

The `q`-analogue of Kummer's theorem proved in `Catalog/NumberTheory/QKummer/Valuation.lean`
takes as input a *regular datum* `IsQRegular q ℓ d e`.  For odd primes `ℓ ∤ q` this is supplied
by `isQRegular_of_odd_prime` with `d = ord_ℓ(q)` the multiplicative order of `q` modulo `ℓ`.

At `ℓ = 2` the recipe `d = ord_2(q) = 1` **fails**: `not_isQRegular_two_of_orderOf` exhibits
`q = 3` where `v_2([2]_3) = v_2(4) = 2` but the recipe predicts `1`.  This is the failure of
lifting the exponent at the prime `2`.

The correct statement replaces the order of `q` modulo `2` by the order of `q` modulo `4`:

* if `q ≡ 1 (mod 4)` then `IsQRegular q 2 1 0` (`isQRegular_two_of_one_mod_four`);
* if `q ≡ 3 (mod 4)` then `IsQRegular q 2 2 (v_2([2]_q))` (`isQRegular_two_of_three_mod_four`).

Consequently the `q`-Kummer formula holds verbatim at `ℓ = 2` once `d` is read as the order of
`q` in `(ZMod 4)ˣ`, which is the sharp boundary of the theorem.
-/
import Catalog.NumberTheory.QKummer.Valuation

namespace QKummer

/-- `[2]_q = 1 + q`. -/
theorem qNat_two (q : ℕ) : qNat q 2 = 1 + q := by
  simp [qNat, Finset.sum_range_succ]

/-- For odd `q` the `q`-integer `[m]_q` has the same parity as `m`. -/
theorem qNat_mod_two {q : ℕ} (hq : q % 2 = 1) (m : ℕ) : qNat q m % 2 = m % 2 := by
  induction m with
  | zero => simp
  | succ m ih =>
      have hpow : q ^ m % 2 = 1 := by simp [Nat.pow_mod, hq]
      rw [qNat_succ, Nat.add_mod, ih, hpow]
      omega

/-- For odd `q` and odd `m`, the `q`-integer `[m]_q` is odd. -/
theorem padicValNat_two_qNat_of_odd {q m : ℕ} (hq : q % 2 = 1) (hm : m % 2 = 1) :
    padicValNat 2 (qNat q m) = 0 :=
  padicValNat.eq_zero_of_not_dvd (by have := qNat_mod_two hq m; omega)

/-- **Lifting the exponent at `2`.**  For odd `q ≥ 3` and even `m ≠ 0`,
`v_2([m]_q) + 1 = v_2(q+1) + v_2(m)`. -/
theorem padicValNat_two_qNat_even {q m : ℕ} (hq2 : 2 ≤ q) (hq : q % 2 = 1) (hm : m ≠ 0)
    (hmeven : Even m) :
    padicValNat 2 (qNat q m) + 1 = padicValNat 2 (q + 1) + padicValNat 2 m := by
  have h1 := padicValNat.pow_two_sub_one (x := q) (n := m) (by omega) (by omega) hm hmeven
  have h2 := padicValNat_pow_sub_one (ℓ := 2) hq2 (Nat.pos_of_ne_zero hm)
  omega

/-- `v_2(2 * t) = 1 + v_2(t)` for `t ≠ 0`. -/
theorem padicValNat_two_mul {t : ℕ} (ht : t ≠ 0) :
    padicValNat 2 (2 * t) = 1 + padicValNat 2 t := by
  rw [padicValNat.mul (by norm_num) ht, padicValNat.self (by norm_num)]

/-- If `q ≡ 1 (mod 4)` then `v_2(q + 1) = 1`. -/
theorem padicValNat_two_succ_of_one_mod_four {q : ℕ} (hq : q % 4 = 1) :
    padicValNat 2 (q + 1) = 1 := by
  obtain ⟨t, ht⟩ : ∃ t, q + 1 = 2 * t := ⟨(q + 1) / 2, by omega⟩
  have htodd : t % 2 = 1 := by omega
  rw [ht, padicValNat_two_mul (by omega), padicValNat.eq_zero_of_not_dvd (by omega)]

/-- **Regularity at `ℓ = 2` for `q ≡ 1 (mod 4)`**: the period is `1` and the offset is `0`,
i.e. `v_2([m]_q) = v_2(m)`. -/
theorem isQRegular_two_of_one_mod_four {q : ℕ} (hq2 : 2 ≤ q) (hq : q % 4 = 1) :
    IsQRegular q 2 1 0 := by
  refine ⟨Nat.one_pos, ?_⟩
  intro m hm
  rw [if_pos (one_dvd m), Nat.div_one, Nat.zero_add]
  rcases Nat.even_or_odd m with hev | hodd
  · have h := padicValNat_two_qNat_even hq2 (by omega) (by omega) hev
    rw [padicValNat_two_succ_of_one_mod_four hq] at h
    omega
  · have hm2 : m % 2 = 1 := Nat.odd_iff.mp hodd
    rw [padicValNat_two_qNat_of_odd (by omega) hm2,
      padicValNat.eq_zero_of_not_dvd (by omega)]

/-- **Regularity at `ℓ = 2` for `q ≡ 3 (mod 4)`**: the period is `2` — the order of `q` modulo
`4`, *not* modulo `2` — and the offset is `v_2([2]_q) = v_2(q+1)`. -/
theorem isQRegular_two_of_three_mod_four {q : ℕ} (hq : q % 4 = 3) :
    IsQRegular q 2 2 (padicValNat 2 (qNat q 2)) := by
  have hq2 : 2 ≤ q := by omega
  refine ⟨by norm_num, ?_⟩
  intro m hm
  have he : padicValNat 2 (qNat q 2) = padicValNat 2 (q + 1) := by
    rw [qNat_two, Nat.add_comm]
  by_cases hdm : 2 ∣ m
  · obtain ⟨t, rfl⟩ := hdm
    have ht : t ≠ 0 := by rintro rfl; simp at hm
    have h := padicValNat_two_qNat_even (m := 2 * t) hq2 (by omega) (by omega) ⟨t, by omega⟩
    rw [padicValNat_two_mul ht] at h
    rw [if_pos ⟨t, rfl⟩, Nat.mul_div_cancel_left t (by norm_num), he]
    omega
  · rw [if_neg hdm, padicValNat_two_qNat_of_odd (by omega) (by omega)]

/-- **The naive recipe fails at `ℓ = 2`.**  Taking `d` to be the order of `q` modulo `2`
(which is always `1`) and `e = v_2([1]_q) = 0` does *not* give a regular datum: for `q = 3`,
`v_2([2]_3) = v_2(4) = 2`, whereas the recipe predicts `v_2(2) = 1`. -/
theorem not_isQRegular_two_of_orderOf : ¬ IsQRegular 3 2 1 0 := by
  intro h
  have h2 := h.val 2 (by norm_num)
  rw [if_pos (one_dvd 2), Nat.div_one, Nat.zero_add] at h2
  have hq : qNat 3 2 = 2 ^ 2 := by rw [qNat_two]; norm_num
  rw [hq, padicValNat.prime_pow, padicValNat.self (by norm_num)] at h2
  exact absurd h2 (by norm_num)

/-- The order of `q` modulo `2` is `1` for every odd `q`; this is why the naive recipe has no
chance at `ℓ = 2`. -/
theorem orderOf_zmod_two {q : ℕ} (hq : q % 2 = 1) : orderOf ((q : ℕ) : ZMod 2) = 1 := by
  have hcast : ((q : ℕ) : ZMod 2) = 1 := by
    rw [← ZMod.natCast_mod q 2, hq]
    norm_num
  rw [hcast, orderOf_one]

end QKummer