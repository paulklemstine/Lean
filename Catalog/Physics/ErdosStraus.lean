import Mathlib

/-!
# The Erdős–Straus conjecture

The Erdős–Straus conjecture asserts that for every integer `n ≥ 2` the fraction `4/n`
can be written as a sum of three unit fractions, i.e. there exist positive integers
`x, y, z` with `4/n = 1/x + 1/y + 1/z`.

This file develops the standard structural results around the conjecture:

* `ErdosStrausSolution` : the basic predicate.
* Four parametric solution families, each proved by an explicit construction that does
  **not** refer to the conjecture itself (so there is no circular dependency):
  - `es_even`           : even denominators;
  - `es_three_dvd`      : multiples of three;
  - `es_three_mod_four` : Sierpiński's family for `n ≡ 3 [MOD 4]`;
  - `es_five_mod_eight` : Komornik's family for `n ≡ 5 [MOD 8]`.
* `es_of_dvd` : divisor inheritance — a solution for a divisor lifts to a solution for the
  multiple.
* `erdosStraus_reduction` : it suffices to verify the conjecture for prime denominators
  `p ≡ 1 [MOD 8]`.
* `erdosStraus_lt_1000` : the conjecture holds for all `2 ≤ n < 1000` (finite verification).

All the constructive content flows through the arithmetic bridge `es_of_nat`, which turns a
denominator-cleared identity over `ℕ` into a genuine solution.
-/

open scoped BigOperators
open Std

namespace ErdosStraus

/-- `ErdosStrausSolution n` holds iff `4/n` is a sum of three unit fractions with
positive integer denominators. -/
def ErdosStrausSolution (n : ℕ) : Prop :=
  ∃ x y z : ℕ+, (4 : ℚ) / n = 1 / ((x : ℕ) : ℚ) + 1 / ((y : ℕ) : ℚ) + 1 / ((z : ℕ) : ℚ)

/-- Bridge between the rational statement and the purely arithmetic (denominator-cleared)
statement over `ℕ`: positive `x, y, z` with `4·xyz = n·(xy + yz + zx)` yield a solution. -/
theorem es_of_nat (n x y z : ℕ) (hx : 0 < x) (hy : 0 < y) (hz : 0 < z) (hn : 0 < n)
    (h : 4 * (x * y * z) = n * (x * y + y * z + z * x)) : ErdosStrausSolution n := by
  refine ⟨⟨x, hx⟩, ⟨y, hy⟩, ⟨z, hz⟩, ?_⟩
  have hnq : (n : ℚ) ≠ 0 := by exact_mod_cast hn.ne'
  have hxq : (x : ℚ) ≠ 0 := by exact_mod_cast hx.ne'
  have hyq : (y : ℚ) ≠ 0 := by exact_mod_cast hy.ne'
  have hzq : (z : ℚ) ≠ 0 := by exact_mod_cast hz.ne'
  have hq : (4 : ℚ) * ((x : ℚ) * y * z) = (n : ℚ) * ((x : ℚ) * y + y * z + z * x) := by
    exact_mod_cast h
  show (4 : ℚ) / n = 1 / (x : ℚ) + 1 / (y : ℚ) + 1 / (z : ℚ)
  field_simp
  ring_nf
  ring_nf at hq
  linarith [hq]

/-! ## Parametric families

Each family below is a standalone constructive existence proof. None of them refers to
`ErdosStrausSolution` of any other number, so there is no circular dependency on the
conjecture itself. -/

/-- **Even denominators.** For even `n ≥ 2`, with `m = n/2`,
`4/n = 1/m + 1/(m+1) + 1/(m(m+1))`. -/
theorem es_even (n : ℕ) (h : Even n) (hn : 2 ≤ n) : ErdosStrausSolution n := by
  obtain ⟨r, rfl⟩ := h
  have hr : 1 ≤ r := by omega
  exact es_of_nat (r + r) r (r + 1) (r * (r + 1)) (by omega) (by omega) (by positivity)
    (by omega) (by ring)

/-- **Multiples of three.** For `3 ∣ n` with `n ≥ 1`, with `m = n/3`,
`4/n = 1/(m+1) + 1/(m(m+1)) + 1/(3m)`. -/
theorem es_three_dvd (n : ℕ) (h : 3 ∣ n) (hn : 1 ≤ n) : ErdosStrausSolution n := by
  obtain ⟨m, rfl⟩ := h
  have hm : 1 ≤ m := by omega
  exact es_of_nat (3 * m) (m + 1) (m * (m + 1)) (3 * m) (by omega) (by positivity) (by omega)
    (by omega) (by ring)

/-- **Sierpiński's family.** For `n ≡ 3 [MOD 4]`, writing `n + 1 = 4k`,
`4/n = 1/k + 1/(2kn) + 1/(2kn)`. -/
theorem es_three_mod_four (n : ℕ) (h : n % 4 = 3) : ErdosStrausSolution n := by
  obtain ⟨k, hk⟩ : ∃ k, n + 1 = 4 * k := ⟨(n + 1) / 4, by omega⟩
  have hk1 : 1 ≤ k := by omega
  have hn3 : 3 ≤ n := by omega
  refine es_of_nat n k (2 * k * n) (2 * k * n) (by omega) (by positivity) (by positivity)
    (by omega) ?_
  have hk' : (n : ℤ) + 1 = 4 * k := by exact_mod_cast hk
  zify
  linear_combination (-4 * (k : ℤ) ^ 2 * (n : ℤ) ^ 2) * hk'

/-- **Komornik's family.** For `n ≡ 5 [MOD 8]`, writing `n + 3 = 8b`,
`4/n = 1/(2b) + 1/(2bn) + 1/(bn)`. -/
theorem es_five_mod_eight (n : ℕ) (h : n % 8 = 5) : ErdosStrausSolution n := by
  obtain ⟨b, hb⟩ : ∃ b, n + 3 = 8 * b := ⟨(n + 3) / 8, by omega⟩
  have hb1 : 1 ≤ b := by omega
  have hn5 : 5 ≤ n := by omega
  refine es_of_nat n (2 * b) (2 * b * n) (b * n) (by omega) (by positivity) (by positivity)
    (by omega) ?_
  have hb' : (n : ℤ) + 3 = 8 * b := by exact_mod_cast hb
  zify
  linear_combination (-2 * (b : ℤ) ^ 2 * (n : ℤ) ^ 2) * hb'

/-! ## Divisor inheritance -/

/-- **Divisor inheritance.** A solution for a divisor `m` lifts to a solution for any
positive multiple `n` of `m`: scale every denominator by `n/m`.

This is the genuinely useful direction.  Note that the *opposite* direction from the
informal prompt — "`ErdosStrausSolution n` and `d ∣ n` imply `ErdosStrausSolution (n/d)`"
— is **false**: e.g. `n = 4`, `d = 4` gives `n/d = 1`, but `4/1 = 4` cannot be a sum of
three unit fractions (the maximum such sum is `3`).  The corrected, true statement is
`es_of_div_dvd` below. -/
theorem es_of_dvd {m n : ℕ} (hm : ErdosStrausSolution m) (hdvd : m ∣ n) (hn : 0 < n) :
    ErdosStrausSolution n := by
  obtain ⟨x, y, z, hxyz⟩ := hm
  obtain ⟨k, rfl⟩ := hdvd
  have hm0 : 0 < m := Nat.pos_of_ne_zero (fun h => by simp [h] at hn)
  have hk0 : 0 < k := Nat.pos_of_ne_zero (fun h => by simp [h] at hn)
  refine ⟨⟨k, hk0⟩ * x, ⟨k, hk0⟩ * y, ⟨k, hk0⟩ * z, ?_⟩
  have hmq : (m : ℚ) ≠ 0 := by exact_mod_cast hm0.ne'
  have hkq : (k : ℚ) ≠ 0 := by exact_mod_cast hk0.ne'
  have hxq : ((x : ℕ) : ℚ) ≠ 0 := by exact_mod_cast x.pos.ne'
  have hyq : ((y : ℕ) : ℚ) ≠ 0 := by exact_mod_cast y.pos.ne'
  have hzq : ((z : ℕ) : ℚ) ≠ 0 := by exact_mod_cast z.pos.ne'
  simp only [PNat.mul_coe, PNat.mk_coe, Nat.cast_mul]
  field_simp at hxyz ⊢
  ring_nf at hxyz ⊢
  nlinarith [hxyz]

/-- Corrected form of the prompt's "divisor inheritance": if `d ∣ n` and the divisor
`n/d` already has a solution, then so does `n`. -/
theorem es_of_div_dvd {n d : ℕ} (hd : d ∣ n) (hn : 0 < n)
    (h : ErdosStrausSolution (n / d)) : ErdosStrausSolution n :=
  es_of_dvd h (Nat.div_dvd_of_dvd hd) hn

/-! ## Reduction to primes `≡ 1 [MOD 8]` -/

/-- Every prime is solvable, provided the single prime `p` is solvable when `p ≡ 1 [MOD 8]`.
The other residues are handled by the parametric families: `p = 2` (even), `p ≡ 3 [MOD 4]`
(Sierpiński) and `p ≡ 5 [MOD 8]` (Komornik). -/
theorem es_prime {p : ℕ} (hp : p.Prime) (H : p % 8 = 1 → ErdosStrausSolution p) :
    ErdosStrausSolution p := by
  by_cases h2 : 2 ∣ p
  · have hp2 : p = 2 := ((Nat.prime_dvd_prime_iff_eq Nat.prime_two hp).mp h2).symm
    subst hp2; exact es_even 2 (by decide) (by norm_num)
  · have hcases : p % 8 = 1 ∨ p % 8 = 3 ∨ p % 8 = 5 ∨ p % 8 = 7 := by omega
    rcases hcases with h | h | h | h
    · exact H h
    · exact es_three_mod_four p (by omega)
    · exact es_five_mod_eight p h
    · exact es_three_mod_four p (by omega)

/-- **Reduction theorem.** If every prime `≡ 1 [MOD 8]` is solvable, then every `n ≥ 2`
is solvable.  (Take the smallest prime factor and lift via `es_of_dvd`.) -/
theorem erdosStraus_reduction
    (H : ∀ p : ℕ, p.Prime → p % 8 = 1 → ErdosStrausSolution p)
    {n : ℕ} (hn : 2 ≤ n) : ErdosStrausSolution n := by
  have hp : (n.minFac).Prime := Nat.minFac_prime (by omega)
  exact es_of_dvd (es_prime hp (fun h8 => H _ hp h8)) (Nat.minFac_dvd n) (by omega)

/-- Bounded reduction theorem, suitable for finite verification: to handle all `2 ≤ n < N`
it suffices to handle the primes `≡ 1 [MOD 8]` below `N`. -/
theorem erdosStraus_reduction_bounded (N : ℕ)
    (H : ∀ p : ℕ, p.Prime → p % 8 = 1 → p < N → ErdosStrausSolution p)
    {n : ℕ} (hn : 2 ≤ n) (hN : n < N) : ErdosStrausSolution n := by
  have hp : (n.minFac).Prime := Nat.minFac_prime (by omega)
  have hle : n.minFac ≤ n := Nat.minFac_le (by omega)
  exact es_of_dvd (es_prime hp (fun h8 => H _ hp h8 (by omega))) (Nat.minFac_dvd n) (by omega)

/-! ## Finite verification for `n < 1000`

The parametric families cover every `n` except those whose prime factors are all
`≡ 1 [MOD 8]`.  For the finitely many primes `p ≡ 1 [MOD 8]` below `1000`, an explicit
witness is produced by a bounded search (`esWit`) and verified by `native_decide`. -/

/-- Bounded Egyptian-fraction search returning a witness `(x, y, z)` for `4/n`. -/
def esWit (n : ℕ) : Option (ℕ × ℕ × ℕ) := Id.run do
  for x in [n / 4 + 1 : 3 * n / 4 + 2] do
    if 4 * x > n then
      let a := 4 * x - n
      let b := n * x
      for y in [b / a + 1 : 2 * b / a + 1] do
        if a * y > b then
          let c := a * y - b
          let d := b * y
          if d % c = 0 then
            return some (x, y, d / c)
  return none

/-- Boolean correctness check for the witness produced by `esWit`. -/
def esGood (q : ℕ) : Bool :=
  match esWit q with
  | some (x, y, z) =>
      decide (0 < x) && decide (0 < y) && decide (0 < z) &&
        decide (4 * (x * y * z) = q * (x * y + y * z + z * x))
  | none => false

/-- Every prime `≡ 1 [MOD 8]` below `1000` has a valid witness. Verified computationally. -/
theorem es_witTable : ∀ q, q < 1000 → Nat.Prime q → q % 8 = 1 → esGood q = true := by
  native_decide

/-- Solvability for the hard primes `p ≡ 1 [MOD 8]` below `1000`. -/
theorem es_hardPrime (p : ℕ) (hp : p.Prime) (h8 : p % 8 = 1) (hlt : p < 1000) :
    ErdosStrausSolution p := by
  have hg := es_witTable p hlt hp h8
  unfold esGood at hg
  cases hw : esWit p with
  | none => rw [hw] at hg; simp at hg
  | some t =>
    obtain ⟨x, y, z⟩ := t
    rw [hw] at hg
    simp only [Bool.and_eq_true, decide_eq_true_eq] at hg
    obtain ⟨⟨⟨hx, hy⟩, hz⟩, heq⟩ := hg
    exact es_of_nat p x y z hx hy hz hp.pos heq

/-- **Finite verification.** The Erdős–Straus conjecture holds for every `2 ≤ n < 1000`. -/
theorem erdosStraus_lt_1000 {n : ℕ} (hn : 2 ≤ n) (hN : n < 1000) : ErdosStrausSolution n :=
  erdosStraus_reduction_bounded 1000 es_hardPrime hn hN

end ErdosStraus