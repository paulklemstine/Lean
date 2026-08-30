import Mathlib
import Bridges.TreeSieveLottery
import Bridges.TreeSieveHypotenuseFace

/-!
# Norm-form blindness classes for arithmetically constrained search trees

`Catalog/Bridges/TreeSieveHypotenuseFace.lean` proves that the hypotenuse face of
the Berggren tree is supported on primes `≡ 1 mod 4`, hence blind to every
modulus all of whose prime factors are `≡ 3 mod 4`.  That argument used nothing
about the tree beyond the shape of the values it produces: they are *primitively
represented by the norm form* `x² + y²`.

This file isolates that mechanism in general (direction 3 of
`FUTURE_DIRECTIONS.md`).  For an arbitrary `D : ℤ`:

* `prime_dvd_normForm_isSquare` — if `a² + D b² = c` with `a, b` having no common
  prime factor, then every prime `r ∣ c` has `-D` a square in `ZMod r`
  (`r` is *split or ramified* in the associated quadratic order).
* `normForm_gcd_eq_one` — consequently, a search whose values are primitively
  represented by `x² + D y²` has `gcd(value, N) = 1` for every modulus `N` all of
  whose prime factors are *inert* (`-D` a nonsquare).  Zero winning tickets,
  uniformly over the whole (infinite) family of values.

Two instances are worked out, `D = 1` (recovering the Berggren statement from the
general lemma) and `D = 2`, where the blind primes are exactly `r % 8 ∈ {5, 7}`.
The final theorem `blindness_classes_incomparable` shows the two classes are
genuinely different: `3` is blind for `D = 1` yet visible for `D = 2`, and `5` is
blind for `D = 2` yet visible for `D = 1`.  So the obstruction is a property of
the *form*, not a universal defect of tree search — but every fixed form carries
one.
-/

namespace NormFormBlindness

open TreeSieve TreeSieveHyp

/-! ## The general splitting constraint -/

/-- **Norm-form constraint.**  If `c` is primitively represented as `a² + D b²`
then for every prime `r ∣ c` the element `-D` is a square modulo `r`. -/
theorem prime_dvd_normForm_isSquare {D a b c : ℤ} {r : ℕ} (hr : r.Prime)
    (hrep : a ^ 2 + D * b ^ 2 = c) (hrc : (r : ℤ) ∣ c)
    (hprim : ¬ ((r : ℤ) ∣ a ∧ (r : ℤ) ∣ b)) : IsSquare (-(D : ZMod r)) := by
  haveI : Fact r.Prime := ⟨hr⟩
  have hdvd : (r : ℤ) ∣ a ^ 2 + D * b ^ 2 := by rw [hrep]; exact hrc
  have h0 : (a : ZMod r) ^ 2 + (D : ZMod r) * (b : ZMod r) ^ 2 = 0 := by
    have := (ZMod.intCast_zmod_eq_zero_iff_dvd (a ^ 2 + D * b ^ 2) r).mpr hdvd
    push_cast at this
    exact this
  have hbz : (b : ZMod r) ≠ 0 := by
    intro hb
    have hb' : (r : ℤ) ∣ b := (ZMod.intCast_zmod_eq_zero_iff_dvd b r).mp hb
    have ha2 : (a : ZMod r) ^ 2 = 0 := by rw [hb] at h0; simpa using h0
    have haz : (a : ZMod r) = 0 := by
      exact sq_eq_zero_iff.mp ha2
    exact hprim ⟨(ZMod.intCast_zmod_eq_zero_iff_dvd a r).mp haz, hb'⟩
  refine ⟨(a : ZMod r) * (b : ZMod r)⁻¹, ?_⟩
  field_simp
  linear_combination -h0

/-- **Blindness.**  If every prime factor of `N` is inert for the form
`x² + D y²` (i.e. `-D` is a nonsquare modulo it), then no primitively represented
value shares a factor with `N`: the gcd step returns `1` every single time. -/
theorem normForm_gcd_eq_one {D a b c : ℤ}
    (hprim : ∀ r : ℕ, r.Prime → ¬ ((r : ℤ) ∣ a ∧ (r : ℤ) ∣ b))
    (hrep : a ^ 2 + D * b ^ 2 = c) {N : ℕ}
    (hN : ∀ r : ℕ, r.Prime → r ∣ N → ¬ IsSquare (-(D : ZMod r))) :
    Int.gcd c (N : ℤ) = 1 := by
  by_contra hne
  obtain ⟨r, hr, hrdvd⟩ := Nat.exists_prime_and_dvd hne
  have hrZ : (r : ℤ) ∣ (Int.gcd c (N : ℤ) : ℤ) := Int.natCast_dvd_natCast.mpr hrdvd
  have hrc : (r : ℤ) ∣ c := hrZ.trans (Int.gcd_dvd_left _ _)
  have hrN : r ∣ N := by
    have : (r : ℤ) ∣ (N : ℤ) := hrZ.trans (Int.gcd_dvd_right _ _)
    exact_mod_cast this
  exact hN r hr hrN (prime_dvd_normForm_isSquare hr hrep hrc (hprim r hr))

/-! ## Instance `D = 1`: the Berggren hypotenuse face -/

/-- For the form `x² + y²` the inert primes are exactly those `≡ 3 mod 4`. -/
theorem inert_one_iff {r : ℕ} (hr : r.Prime) :
    ¬ IsSquare (-((1 : ℤ) : ZMod r)) ↔ r % 4 = 3 := by
  haveI : Fact r.Prime := ⟨hr⟩
  have hcast : -((1 : ℤ) : ZMod r) = -1 := by push_cast; ring
  rw [hcast]
  constructor
  · intro h
    by_contra h3
    exact h (ZMod.exists_sq_eq_neg_one_iff.mpr h3)
  · intro h3 hsq
    exact ZMod.exists_sq_eq_neg_one_iff.mp hsq h3

/-- The Berggren statement, rederived from the general norm-form lemma: the
hypotenuse face of the tree never meets a modulus whose prime factors are all
`≡ 3 mod 4`. -/
theorem berg_hyp_gcd_one_of_three_mod_four (w : List (Fin 3)) {N : ℕ}
    (hN : ∀ r : ℕ, r.Prime → r ∣ N → r % 4 = 3) :
    Int.gcd ((bergOf w).2.2 ^ 2) (N : ℤ) = 1 := by
  refine normForm_gcd_eq_one (D := 1) (a := (bergOf w).1) (b := (bergOf w).2.1)
    (bergOf_prim w) (by linear_combination bergOf_pyth w) ?_
  intro r hr hrN
  exact (inert_one_iff hr).mpr (hN r hr hrN)

/-! ## Instance `D = 2`: a different blindness class -/

/-- For the form `x² + 2y²` the inert primes are exactly those `≡ 5, 7 mod 8`. -/
theorem inert_two_iff {r : ℕ} (hr : r.Prime) (hr2 : r ≠ 2) :
    ¬ IsSquare (-((2 : ℤ) : ZMod r)) ↔ (r % 8 = 5 ∨ r % 8 = 7) := by
  haveI : Fact r.Prime := ⟨hr⟩
  have hcast : -((2 : ℤ) : ZMod r) = -2 := by push_cast; ring
  have hodd : r % 2 = 1 := Nat.odd_iff.mp (hr.odd_of_ne_two hr2)
  have h8 : r % 8 % 2 = r % 2 := Nat.mod_mod_of_dvd r (by norm_num)
  rw [hcast, ZMod.exists_sq_eq_neg_two_iff hr2]
  omega

/-- Every prime divisor of a primitive value of `x² + 2y²` is `1` or `3 mod 8`
(or equal to `2`). -/
theorem prime_dvd_two_normForm_mod_eight {a b c : ℤ} {r : ℕ} (hr : r.Prime) (hr2 : r ≠ 2)
    (hrep : a ^ 2 + 2 * b ^ 2 = c) (hrc : (r : ℤ) ∣ c)
    (hprim : ¬ ((r : ℤ) ∣ a ∧ (r : ℤ) ∣ b)) : r % 8 = 1 ∨ r % 8 = 3 := by
  have hsq : IsSquare (-((2 : ℤ) : ZMod r)) :=
    prime_dvd_normForm_isSquare (D := 2) hr (by linear_combination hrep) hrc hprim
  have hodd : r % 2 = 1 := Nat.odd_iff.mp (hr.odd_of_ne_two hr2)
  have hmm : r % 8 % 2 = r % 2 := Nat.mod_mod_of_dvd r (by norm_num)
  by_contra h
  push_neg at h
  have h57 : r % 8 = 5 ∨ r % 8 = 7 := by omega
  exact (inert_two_iff hr hr2).mpr h57 hsq

/-- **Blindness for `x² + 2y²` on a semiprime.**  If both prime factors of `N`
are `≡ 5` or `7 mod 8`, a search over primitive values of `x² + 2y²` splits `N`
with probability exactly `0`. -/
theorem two_normForm_blind_semiprime {a b c : ℤ}
    (hprim : ∀ r : ℕ, r.Prime → ¬ ((r : ℤ) ∣ a ∧ (r : ℤ) ∣ b))
    (hrep : a ^ 2 + 2 * b ^ 2 = c) {p q : ℕ} (hp : p.Prime) (hq : q.Prime)
    (hp8 : p % 8 = 5 ∨ p % 8 = 7) (hq8 : q % 8 = 5 ∨ q % 8 = 7) :
    Int.gcd c ((p * q : ℕ) : ℤ) = 1 := by
  refine normForm_gcd_eq_one (D := 2) hprim (by linear_combination hrep) ?_
  intro r hr hrN
  have hr2 : r ≠ 2 := by
    rintro rfl
    rcases (Nat.Prime.dvd_mul hr).mp hrN with h | h
    · have := (Nat.prime_dvd_prime_iff_eq hr hp).mp h
      omega
    · have := (Nat.prime_dvd_prime_iff_eq hr hq).mp h
      omega
  refine (inert_two_iff hr hr2).mpr ?_
  rcases (Nat.Prime.dvd_mul hr).mp hrN with h | h
  · rw [(Nat.prime_dvd_prime_iff_eq hr hp).mp h]; exact hp8
  · rw [(Nat.prime_dvd_prime_iff_eq hr hq).mp h]; exact hq8

/-! ## The two blindness classes are incomparable -/

/-- Nothing is primitively obstructed by the unit: no prime divides `1`. -/
theorem prim_of_second_one (a : ℤ) :
    ∀ r : ℕ, r.Prime → ¬ ((r : ℤ) ∣ a ∧ (r : ℤ) ∣ (1 : ℤ)) := by
  rintro r hr ⟨-, h1⟩
  have : r ∣ 1 := by exact_mod_cast h1
  have := Nat.le_of_dvd Nat.one_pos this
  have := hr.two_le
  omega

/-- **Blindness is a property of the form, not of tree search.**  The prime `3`
is blind for `x² + y²` but visible for `x² + 2y²`, and the prime `5` is blind for
`x² + 2y²` but visible for `x² + y²`.  Hence the two obstruction classes are
incomparable — yet each form has one, so no single change of form escapes. -/
theorem blindness_classes_incomparable :
    (∀ a b c : ℤ, (∀ r : ℕ, r.Prime → ¬ ((r : ℤ) ∣ a ∧ (r : ℤ) ∣ b)) →
        a ^ 2 + b ^ 2 = c → Int.gcd c (3 : ℤ) = 1) ∧
    (∃ a b c : ℤ, (∀ r : ℕ, r.Prime → ¬ ((r : ℤ) ∣ a ∧ (r : ℤ) ∣ b)) ∧
        a ^ 2 + 2 * b ^ 2 = c ∧ Int.gcd c (3 : ℤ) = 3) ∧
    (∀ a b c : ℤ, (∀ r : ℕ, r.Prime → ¬ ((r : ℤ) ∣ a ∧ (r : ℤ) ∣ b)) →
        a ^ 2 + 2 * b ^ 2 = c → Int.gcd c (5 : ℤ) = 1) ∧
    (∃ a b c : ℤ, (∀ r : ℕ, r.Prime → ¬ ((r : ℤ) ∣ a ∧ (r : ℤ) ∣ b)) ∧
        a ^ 2 + b ^ 2 = c ∧ Int.gcd c (5 : ℤ) = 5) := by
  refine ⟨?_, ⟨1, 1, 3, prim_of_second_one 1, by norm_num, by decide⟩, ?_,
    ⟨1, 2, 5, ?_, by norm_num, by decide⟩⟩
  · intro a b c hprim hrep
    have := normForm_gcd_eq_one (D := 1) (c := c) (N := 3) hprim (by linear_combination hrep)
      (fun r hr hr3 => (inert_one_iff hr).mpr
        (by rw [(Nat.prime_dvd_prime_iff_eq hr Nat.prime_three).mp hr3]))
    simpa using this
  · intro a b c hprim hrep
    have hp5 : Nat.Prime 5 := by norm_num
    have := normForm_gcd_eq_one (D := 2) (c := c) (N := 5) hprim (by linear_combination hrep)
      (fun r hr hr5 => (inert_two_iff hr
        (by rw [(Nat.prime_dvd_prime_iff_eq hr hp5).mp hr5]; norm_num)).mpr
        (by rw [(Nat.prime_dvd_prime_iff_eq hr hp5).mp hr5]; norm_num))
    simpa using this
  · rintro r hr ⟨h1, -⟩
    have : r ∣ 1 := by exact_mod_cast h1
    have := Nat.le_of_dvd Nat.one_pos this
    have := hr.two_le
    omega

end NormFormBlindness