import Mathlib

/-!
# The Mandelbrot Set's Secret Number Theory: External Angles and the Doubling Map

The hyperbolic components ("bulbs") of the Mandelbrot set are indexed by rational *external
angles* `p/q ∈ ℚ/ℤ`.  The dynamics on the circle of external angles is the **doubling map**
`θ ↦ 2θ mod 1`.  Restricted to angles with denominator `q`, this is exactly *multiplication by
`2`* on `ℤ/qℤ`.

This file makes the "secret number theory" precise:

* The doubling map on `ℤ/qℤ` is a **bijection iff `q` is odd** (`2` must be invertible), and it
  **fails to be injective when `q` is even**.  Thus the angle `p/q` is periodic under doubling
  exactly when `q` is odd — the classical periodicity criterion for external rays landing on
  Mandelbrot bulbs.
* The `n`-th iterate is multiplication by `2ⁿ`, so the **period of the angle `1/q` equals the
  multiplicative order of `2` modulo `q`** (`orderOf (2 : ZMod q)`); equivalently
  `q ∣ 2^{period} - 1` (a Mersenne-type divisibility).
* For an **odd prime `q`**, Fermat's little theorem forces the bulb period to **divide `q - 1`**.

We close with a *contrarian* section: several natural-looking conjectures about these periods are
**false**, and we prove the counterexamples (e.g. `2` is not a primitive root mod `7`, so the
period is `3`, not `6`).
-/

namespace ExternalAngle

/-- Angle doubling with denominator `q`: on `ℤ/qℤ` it is multiplication by `2`
(the shift `p/q ↦ 2p/q mod 1`). -/
def dbl (q : ℕ) (x : ZMod q) : ZMod q := 2 * x

/-
The `n`-th iterate of the doubling map is multiplication by `2ⁿ`.
-/
lemma dbl_iterate (q : ℕ) (n : ℕ) (x : ZMod q) : (dbl q)^[n] x = (2 : ZMod q) ^ n * x := by
  induction' n with n ih generalizing x <;> simp_all +decide [ pow_succ, mul_assoc, Function.iterate_succ_apply' ];
  unfold dbl; ring;

/-
**Odd denominators give a bijection.**  When `q` is odd, `2` is a unit mod `q`, so the
doubling map is a bijection: every external angle `p/q` is (purely) periodic.
-/
theorem dbl_bijective_of_odd {q : ℕ} (hq : Odd q) : Function.Bijective (dbl q) := by
  -- Since $q$ is odd, $2$ is a unit in $\mathbb{Z}/q\mathbb{Z}$.
  have h_unit : IsUnit (2 : ZMod q) := by
    -- Since $q$ is odd, $2$ is invertible modulo $q$.
    have h_inv : ∃ x : ℕ, 2 * x ≡ 1 [MOD q] := by
      exact ⟨ ( q + 1 ) / 2, by rw [ mul_comm, Nat.div_mul_cancel ( even_iff_two_dvd.mp ( by simpa [ parity_simps ] using hq ) ) ] ; simp +decide [ Nat.ModEq ] ⟩;
    exact isUnit_iff_exists_inv.mpr ⟨ h_inv.choose, by simpa [ ← ZMod.natCast_eq_natCast_iff ] using h_inv.choose_spec ⟩;
  refine' ⟨ _, _ ⟩;
  · intro x y hxy;
    exact h_unit.mul_left_cancel hxy;
  · obtain ⟨ u, hu ⟩ := h_unit.exists_left_inv;
    exact fun x => ⟨ u * x, by unfold dbl; linear_combination' hu * x ⟩

/-
**Even denominators break injectivity.**  When `q` is even (and positive), the doubling map is
not injective — the corresponding external angles are only *pre*-periodic.
-/
theorem dbl_not_injective_of_even {q : ℕ} (hq : Even q) (hq0 : 0 < q) :
    ¬ Function.Injective (dbl q) := by
  obtain ⟨ k, rfl ⟩ := hq; simp +decide [ Function.Injective ] ;
  refine' ⟨ 0, ↑k, _, _ ⟩ <;> simp_all +decide [ ← two_mul, dbl ];
  · norm_cast;
    erw [ eq_comm, ZMod.natCast_eq_zero_iff ] ;
    rw [ two_mul ];
  · rw [ eq_comm ] ; norm_num [ ZMod.natCast_eq_zero_iff ] ; exact Nat.not_dvd_of_pos_of_lt hq0 ( by linarith ) ;

/-
For odd `q`, every point is periodic under the doubling map: there is a common period `n > 0`
with `(dbl q)^[n] = id`.
-/
theorem dbl_periodic_of_odd {q : ℕ} (hq : Odd q) (hq1 : 1 < q) :
    ∃ n, 0 < n ∧ ∀ x : ZMod q, (dbl q)^[n] x = x := by
  -- By definition of exponentiation in modular arithmetic, we know that $(2 : \mathbb{Z}/q\mathbb{Z})^{φ(q)} = 1$.
  have h_exp : (2 : ZMod q) ^ Nat.totient q = 1 := by
    simpa [ ← ZMod.natCast_eq_natCast_iff ] using Nat.ModEq.pow_totient ( by aesop );
  exact ⟨ Nat.totient q, Nat.totient_pos.mpr hq1.le, fun x => by rw [ dbl_iterate, h_exp, one_mul ] ⟩

/-
The period of the angle `1/q` (the point `1`) equals the multiplicative order of `2` mod `q`:
`(dbl q)^[n] 1 = 1 ↔ orderOf (2 : ZMod q) ∣ n`.
-/
theorem dbl_period_one {q : ℕ} (n : ℕ) :
    (dbl q)^[n] 1 = 1 ↔ orderOf (2 : ZMod q) ∣ n := by
  simp [ orderOf_dvd_iff_pow_eq_one, dbl_iterate ]

/-
**Mersenne-type divisibility.**  The denominator `q` divides `2^{period} - 1`, where
`period = orderOf (2 : ZMod q)`.  For odd `q > 1` this is the genuine Mersenne statement (the
period is a true positive period, cf. `order_two_pos`); for even `q` the order is `0` and the
divisibility holds trivially (`q ∣ 0`).
-/
theorem dvd_two_pow_order_sub_one {q : ℕ} :
    q ∣ 2 ^ (orderOf (2 : ZMod q)) - 1 := by
  simp [ ← ZMod.natCast_eq_zero_iff, pow_orderOf_eq_one ]

/-
**Fermat / the bulb-period divides `q - 1`.**  For an odd prime `q`, the period of the `p/q`
bulb (the order of `2` mod `q`) divides `q - 1`.
-/
theorem order_two_dvd_sub_one {q : ℕ} (hq : q.Prime) (hq2 : q ≠ 2) :
    orderOf (2 : ZMod q) ∣ q - 1 := by
  rw [ orderOf_dvd_iff_pow_eq_one ];
  haveI := Fact.mk hq; exact ZMod.pow_card_sub_one_eq_one ( by erw [ Ne.eq_def, ZMod.natCast_eq_zero_iff ] ; exact Nat.not_dvd_of_pos_of_lt Nat.zero_lt_two <| lt_of_le_of_ne hq.two_le <| Ne.symm hq2 ) ;

/-
The period is positive for odd `q > 1` (the order of `2` is a genuine period).
-/
theorem order_two_pos {q : ℕ} (hq : Odd q) (hq1 : 1 < q) : 0 < orderOf (2 : ZMod q) := by
  rw [ orderOf_pos_iff ];
  -- By Euler's theorem, since $q$ is odd, we have $2^{\varphi(q)} \equiv 1 \pmod{q}$.
  have h_euler : 2 ^ Nat.totient q ≡ 1 [MOD q] := by
    exact Nat.ModEq.pow_totient <| by obtain ⟨ k, rfl ⟩ := hq; norm_num;
  exact isOfFinOrder_iff_pow_eq_one.mpr ⟨ q.totient, Nat.totient_pos.mpr hq1.le, by simpa [ ← ZMod.natCast_eq_natCast_iff ] using h_euler ⟩

/-! ## Contrarian section: natural conjectures that are FALSE

The following bold guesses about bulb periods are refuted by explicit counterexamples. -/

/-
Concrete order computations (periods of small bulbs).
-/
theorem order_two_mod_three : orderOf (2 : ZMod 3) = 2 := by
  simp +decide only [orderOf_eq_iff]

theorem order_two_mod_seven : orderOf (2 : ZMod 7) = 3 := by
  simp +decide only [orderOf_eq_iff]

theorem order_two_mod_five : orderOf (2 : ZMod 5) = 4 := by
  simp +decide only [orderOf_eq_iff]

/-
**Disproof.**  "`2` is always a primitive root modulo every odd prime" (equivalently the
`p/q` bulb always has maximal period `q - 1`).  FALSE: for `q = 7` the period is `3 ≠ 6`.
-/
theorem not_two_always_primitive_root :
    ∃ q : ℕ, q.Prime ∧ q ≠ 2 ∧ orderOf (2 : ZMod q) ≠ q - 1 := by
  exact ⟨ 7, by decide, by decide, by rw [ order_two_mod_seven ] ; decide ⟩

/-
**Disproof.**  "Every bulb period is prime."  FALSE: for `q = 5` the period is `4`, which is
composite.
-/
theorem not_period_always_prime :
    ∃ q : ℕ, q.Prime ∧ q ≠ 2 ∧ ¬ (orderOf (2 : ZMod q)).Prime := by
  use 5;
  rw [ order_two_mod_five ] ; norm_num

end ExternalAngle