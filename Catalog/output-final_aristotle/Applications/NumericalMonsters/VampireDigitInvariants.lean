/-
Copyright (c) 2026. All rights reserved.
Released under Apache 2.0 license.

# Vampire Numbers and Other Numerical Monsters: Digit-Congruence Invariants

A *vampire number* is a composite `v` with an even number of digits that factors
as `v = x * y`, where the two "fangs" `x` and `y` together use exactly the same
multiset of digits as `v` (with `x` and `y` each having half of `v`'s digits and
not both ending in a trailing zero). The smallest is `1260 = 21 * 60`.

The combinatorial heart of the whole *bestiary* (vampires, werewolves, ghosts,
zombies) is the relation

  `SharesAllDigits b x y  :  digits(x) ++ digits(y)  is a permutation of  digits(x*y)`

i.e. the factors together carry exactly the digit multiset of their product, in
base `b`.  This file proves *base-independent congruence invariants* that every
such "fanged" factorisation must obey — necessary conditions that are cheap to
check yet cut deeply into the search space, and that hold in *every* base.

## Main results

* `NumericalMonsters.sharesAllDigits_modEq` — the **casting-out-`(b-1)`s
  invariant**: if `x, y` share all digits with `x*y` in base `b ≥ 2` then
  `x + y ≡ x * y  [MOD b-1]`.  (Base `10`: `x + y ≡ x*y  (mod 9)`.)

* `NumericalMonsters.sharesAllDigits_unit_nine` — the **`ZMod 9` unit identity**:
  in base `10`, `(x - 1) * (y - 1) = 1` in `ZMod 9`.  Thus each fang minus one is
  a *unit* modulo `9`.

* `NumericalMonsters.fang_not_one_mod_three` — a striking **arithmetic taboo**:
  *no* fang of a base-`10` vampire/werewolf factorisation is `≡ 1 (mod 3)`; both
  `x % 3 ≠ 1` and `y % 3 ≠ 1`.

* `NumericalMonsters.binary_fang_not_power_of_two` — a **cross-domain bridge** to
  the binary sum-of-digits theory of `CusickSumOfDigits`: in base `2`, no fang of
  a digit-sharing factorisation is a power of two (`2 ≤ s₂(x)`).  Its engine is
  the *submultiplicativity* `s₂(x*y) ≤ s₂(x)·s₂(y)`, itself built on the catalog
  lemma `CusickSumDigits.s2_subadditive`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): "Sharing all digits" is a rigid constraint, so the
divisibility-by-`9` fingerprint of a number (its digit sum mod `9`) should be
*conserved* across the factorisation. If `digits(x)++digits(y)` is a permutation
of `digits(x*y)` then digit sums add, and since `n ≡ digitsum(n) (mod 9)` we get
`x + y ≡ x*y (mod 9)`. Two surprising predictions follow: (a) `(x-1)(y-1) ≡ 1
(mod 9)`, forcing `x-1` to be a unit; (b) hence no fang is `≡ 1 (mod 3)`.

Experiment (Experimenter): computed `SharesAllDigits 10 21 60` (→ `1260`) and a
brute-force scan of base-2 pairs `(x,y) < 40` found genuine solutions such as
`(7,25)` (`7*25 = 175`), confirming non-vacuity. Checked `21 % 3 = 0`,
`60 % 3 = 0` — consistent with taboo (b). Mathlib supplies
`Nat.modEq_digits_sum` and `Nat.modEq_nine_digits_sum`; `List.Perm.sum_eq`
transports digit sums across the permutation.

Analysis (Analyst): the invariant generalises verbatim to base `b` via
casting-out-`(b-1)`s; the degenerate base `2` (modulus `1`) is handled
separately. The `mod 3` taboo is the image of the `ZMod 9` unit identity under
the ring hom `ZMod 9 → ZMod 3`. Bridging to Cusick's binary `s₂`: sharing digits
forces `s₂(x)+s₂(y) = s₂(x*y)`, and submultiplicativity `s₂(x*y) ≤ s₂(x)s₂(y)`
then forbids a power-of-two fang.

Critique (Critic): none of the four main theorems is `decide`/`native_decide`;
each uses `induction`, ring homomorphisms, `linear_combination`, or the imported
subadditivity lemma. Non-vacuity is witnessed by explicit `example`s. The
statements are stated over all of `ℕ` (no finite range).

Synthesis (PI): a base-independent "conservation law" for arithmetic monsters —
digit-sharing factorisations live inside the unit group modulo `b-1`, and in
binary they avoid powers of two.
-/
import Mathlib
import Applications.CusickSumOfDigits

open Nat

namespace NumericalMonsters

/-- The core relation of the bestiary: in base `b`, the digits of `x` together
with the digits of `y` form a permutation of the digits of the product `x*y`.
Vampire, werewolf, ghost and zombie numbers are all refinements of this. -/
def SharesAllDigits (b x y : ℕ) : Prop :=
  (Nat.digits b x ++ Nat.digits b y).Perm (Nat.digits b (x * y))

/-- **Casting-out-`(b-1)`s invariant.**  If `x` and `y` share all their digits
with the product `x*y` in base `b ≥ 2`, then `x + y ≡ x*y  [MOD b-1]`. -/
theorem sharesAllDigits_modEq (b x y : ℕ) (hb : 2 ≤ b) (h : SharesAllDigits b x y) :
    (x + y) ≡ (x * y) [MOD (b - 1)] := by
  have hsum : (Nat.digits b x ++ Nat.digits b y).sum = (Nat.digits b (x * y)).sum :=
    h.sum_eq
  rw [List.sum_append] at hsum
  rcases Nat.lt_or_ge b 3 with hb3 | hb3
  · interval_cases b
    · exact Nat.modEq_one
  · have hmod : b % (b - 1) = 1 := by
      rw [Nat.mod_eq_sub_mod (by omega), show b - (b - 1) = 1 by omega,
        Nat.mod_eq_of_lt (by omega)]
    have hx := Nat.modEq_digits_sum (b - 1) b hmod x
    have hy := Nat.modEq_digits_sum (b - 1) b hmod y
    have hxy := Nat.modEq_digits_sum (b - 1) b hmod (x * y)
    calc
      x + y ≡ (Nat.digits b x).sum + (Nat.digits b y).sum [MOD (b - 1)] :=
        Nat.ModEq.add hx hy
      _ = (Nat.digits b (x * y)).sum := hsum
      _ ≡ (x * y) [MOD (b - 1)] := hxy.symm

/-- Base-`10` specialisation: `x + y ≡ x*y  (mod 9)`. -/
theorem sharesAllDigits_modEq_nine (x y : ℕ) (h : SharesAllDigits 10 x y) :
    (x + y) ≡ (x * y) [MOD 9] :=
  sharesAllDigits_modEq 10 x y (by norm_num) h

/-- **`ZMod 9` unit identity.**  In base `10`, each fang minus one is a unit:
`(x - 1) * (y - 1) = 1` in `ZMod 9`. -/
theorem sharesAllDigits_unit_nine (x y : ℕ) (h : SharesAllDigits 10 x y) :
    ((x : ZMod 9) - 1) * ((y : ZMod 9) - 1) = 1 := by
  have h2 : ((x : ZMod 9) + y) = ((x : ZMod 9) * y) := by
    have := (ZMod.natCast_eq_natCast_iff (x + y) (x * y) 9).mpr
      (sharesAllDigits_modEq_nine x y h)
    push_cast at this
    exact this
  linear_combination -h2

/-- **Arithmetic taboo.**  No fang of a base-`10` digit-sharing factorisation is
congruent to `1` modulo `3`: `x % 3 ≠ 1`. -/
theorem fang_not_one_mod_three (x y : ℕ) (h : SharesAllDigits 10 x y) :
    x % 3 ≠ 1 := by
  intro hx
  have hz := sharesAllDigits_unit_nine x y h
  set f := ZMod.castHom (show (3 : ℕ) ∣ 9 by norm_num) (ZMod 3) with hf
  have himg : (f ((x : ZMod 9) - 1)) * (f ((y : ZMod 9) - 1)) = 1 := by
    rw [← map_mul, hz, map_one]
  have hx3 : ((x : ZMod 3)) = 1 := by
    conv_lhs => rw [← ZMod.natCast_mod x 3]
    rw [hx]; norm_num
  have hzero : f ((x : ZMod 9) - 1) = 0 := by
    rw [map_sub, map_natCast, map_one, hx3, sub_self]
  rw [hzero, zero_mul] at himg
  exact zero_ne_one himg

/-- The taboo is symmetric: the other fang also avoids `1 (mod 3)`. -/
theorem fang_not_one_mod_three' (x y : ℕ) (h : SharesAllDigits 10 x y) :
    y % 3 ≠ 1 := by
  apply fang_not_one_mod_three y x
  unfold SharesAllDigits at h ⊢
  rw [mul_comm]
  exact (List.perm_append_comm.trans h)

/-! ### Bridge to the binary sum-of-digits theory (`CusickSumOfDigits`) -/

/-- Sharing all digits in base `2` means the binary digit sums add:
`s₂(x) + s₂(y) = s₂(x*y)`. -/
theorem s2_add_of_sharesAllDigits (x y : ℕ) (h : SharesAllDigits 2 x y) :
    CusickSumDigits.s2 x + CusickSumDigits.s2 y = CusickSumDigits.s2 (x * y) := by
  have hsum : (Nat.digits 2 x ++ Nat.digits 2 y).sum = (Nat.digits 2 (x * y)).sum :=
    h.sum_eq
  rw [List.sum_append] at hsum
  simpa [CusickSumDigits.s2] using hsum

/-- Multiplying by two just prepends a zero digit, so `s₂(2*m) = s₂(m)`. -/
theorem s2_double (m : ℕ) : CusickSumDigits.s2 (2 * m) = CusickSumDigits.s2 m := by
  rcases Nat.eq_zero_or_pos m with hm | hm
  · simp [hm, CusickSumDigits.s2]
  · have := Nat.digits_base_pow_mul (b := 2) (k := 1) (m := m) (by norm_num) hm
    simp only [pow_one] at this
    simp [CusickSumDigits.s2, this]

/-- Binary digit-sum recursion: `s₂(n) = n % 2 + s₂(n / 2)`. -/
theorem s2_rec (n : ℕ) : CusickSumDigits.s2 n = n % 2 + CusickSumDigits.s2 (n / 2) := by
  rcases Nat.eq_zero_or_pos n with hn | hn
  · simp [hn, CusickSumDigits.s2]
  · rw [CusickSumDigits.s2, Nat.digits_def' (b := 2) (by norm_num) hn]
    simp [CusickSumDigits.s2]

/-- **Submultiplicativity of the binary digit sum.**  `s₂(x*y) ≤ s₂(x)·s₂(y)`.
Built on `CusickSumDigits.s2_subadditive`. -/
theorem s2_submul (x y : ℕ) :
    CusickSumDigits.s2 (x * y) ≤ CusickSumDigits.s2 x * CusickSumDigits.s2 y := by
  induction y using Nat.strong_induction_on with
  | _ y ih =>
    rcases Nat.eq_zero_or_pos y with hy | hy
    · simp [hy, CusickSumDigits.s2]
    · have hq : y / 2 < y := Nat.div_lt_self hy (by norm_num)
      have key : CusickSumDigits.s2 y = y % 2 + CusickSumDigits.s2 (y / 2) := s2_rec y
      have hmul : x * y = 2 * (x * (y / 2)) + (y % 2) * x := by
        have hy2 : y = 2 * (y / 2) + y % 2 := by omega
        calc x * y = x * (2 * (y / 2) + y % 2) := by rw [← hy2]
          _ = 2 * (x * (y / 2)) + (y % 2) * x := by ring
      rcases Nat.mod_two_eq_zero_or_one y with h0 | h1
      · rw [hmul, h0]
        simp only [zero_mul, add_zero]
        rw [s2_double]
        calc CusickSumDigits.s2 (x * (y / 2))
              ≤ CusickSumDigits.s2 x * CusickSumDigits.s2 (y / 2) := ih _ hq
          _ ≤ CusickSumDigits.s2 x * CusickSumDigits.s2 y := by rw [key, h0]; simp
      · rw [hmul, h1]
        simp only [one_mul]
        calc CusickSumDigits.s2 (2 * (x * (y / 2)) + x)
              ≤ CusickSumDigits.s2 (2 * (x * (y / 2))) + CusickSumDigits.s2 x :=
                CusickSumDigits.s2_subadditive _ _
          _ = CusickSumDigits.s2 (x * (y / 2)) + CusickSumDigits.s2 x := by rw [s2_double]
          _ ≤ CusickSumDigits.s2 x * CusickSumDigits.s2 (y / 2) + CusickSumDigits.s2 x :=
                Nat.add_le_add_right (ih _ hq) _
          _ = CusickSumDigits.s2 x * (CusickSumDigits.s2 (y / 2) + 1) := by ring
          _ ≤ CusickSumDigits.s2 x * CusickSumDigits.s2 y := by rw [key, h1]; ring_nf; omega

/-- `s₂(n) ≥ 1` for `n ≥ 1`. -/
theorem s2_pos (n : ℕ) (hn : 1 ≤ n) : 1 ≤ CusickSumDigits.s2 n := by
  induction n using Nat.strong_induction_on with
  | _ n ih =>
    rw [s2_rec]
    rcases Nat.mod_two_eq_zero_or_one n with h0 | h1
    · have hd : n / 2 < n := Nat.div_lt_self (by omega) (by norm_num)
      have : 1 ≤ CusickSumDigits.s2 (n / 2) := ih _ hd (by omega)
      omega
    · omega

/-- **Cross-domain bridge: binary fangs avoid powers of two.**  If `x` and `y`
share all digits with their product in base `2` (with `x, y ≥ 1`), then neither
fang is a power of two: `2 ≤ s₂(x)`. -/
theorem binary_fang_not_power_of_two (x y : ℕ) (hx : 1 ≤ x) (hy : 1 ≤ y)
    (h : SharesAllDigits 2 x y) : 2 ≤ CusickSumDigits.s2 x := by
  have hadd := s2_add_of_sharesAllDigits x y h
  have hsub := s2_submul x y
  have hxpos := s2_pos x hx
  have hypos := s2_pos y hy
  -- `s₂x + s₂y = s₂(xy) ≤ s₂x·s₂y`, with `s₂x, s₂y ≥ 1`, forces `s₂x ≥ 2`.
  nlinarith [hadd, hsub, hxpos, hypos]

/-! ### Non-vacuity witnesses -/

/-- The smallest vampire number: `1260 = 21 * 60`, and its fangs share all
digits with it. -/
example : SharesAllDigits 10 21 60 := by unfold SharesAllDigits; decide

/-- Consistency with the `mod 3` taboo: `21 % 3 = 0 ≠ 1` and `60 % 3 = 0 ≠ 1`. -/
example : (21 : ℕ) % 3 ≠ 1 ∧ (60 : ℕ) % 3 ≠ 1 := by decide

/-- A genuine base-`2` digit-sharing pair: `7 * 25 = 175`. -/
example : SharesAllDigits 2 7 25 := by unfold SharesAllDigits; decide

end NumericalMonsters