import Mathlib

/-!
# Fermat's Little Theorem for p = 5

For every integer `a`, the quantity `a^5 - a` is a multiple of `5`. We prove this
as a special case of the general integer form of Fermat's little theorem
(`prime_dvd_pow_sub_self`), which is obtained by transporting the identity
`x^p = x` (valid in the field `ZMod p` for prime `p`, `ZMod.pow_card`) back to `ℤ`.

We then sharpen the result: `a^5 - a` is in fact divisible by `30 = 2·3·5`, using
the factorisations `a^5 - a = (a^2 - a)(a^3 + a^2 + a + 1) = (a^2 + 1)(a^3 - a)`
together with Fermat's little theorem for the primes `2` and `3`.

## Main Results

* `prime_dvd_pow_sub_self`: for a prime `p`, `(p : ℤ) ∣ a^p - a` (general FLT).
* `five_dvd_pow_five_sub_self`: `5 ∣ a^5 - a` (the requested statement).
* `thirty_dvd_pow_five_sub_self`: `30 ∣ a^5 - a` (a strengthening).

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): The map `a ↦ a^5` fixes every residue class mod 5,
so `5 ∣ a^5 - a`. More generally `p ∣ a^p - a` for every prime `p`, and the p=5
case should follow by instantiation. A surprising, stronger conjecture: the same
expression is always divisible by 30, not just 5.

Experiment (Experimenter): Tabulated `a^5 - a` for `-3 ≤ a ≤ 7` (see
ComputationalEvidence.md); every value is divisible by 30. The residue table
`a^5 mod 5` shows the fifth-power map is the identity on `ZMod 5`.

Analysis (Analyst): The clean formal route is `ZMod.pow_card : x^p = x` in
`ZMod p`, transported to `ℤ` via `ZMod.intCast_zmod_eq_zero_iff_dvd`. This proves
the general prime statement in one stroke, avoiding brute-force case analysis.
The 30-divisibility does NOT follow from the p=5 case alone; it needs the p=2 and
p=3 cases plus the algebraic factorisations, then coprimality to combine.

Critique (Critic): The proofs are not `decide`-only — they use the field
structure of `ZMod p` (`ZMod.pow_card`), a nontrivial cast lemma, ring
identities, and a coprimality combination for the mod-30 result. The p=5 theorem
is a genuine instantiation of the general theorem, not a restatement.

Synthesis (PI): Three layered theorems — the general integer FLT, its p=5
specialisation (the requested result), and the 30-divisibility strengthening.
-- !-- Lab Notes -- !--
-/

namespace FermatLittleP5

open scoped BigOperators

/-- **Fermat's little theorem, integer form.** For a prime `p` and any integer
`a`, `p` divides `a^p - a`. Proof: in the field `ZMod p` we have `x^p = x`
(`ZMod.pow_card`), so the image of `a^p - a` is `0`; transporting back to `ℤ`
gives divisibility. -/
theorem prime_dvd_pow_sub_self (p : ℕ) [Fact (Nat.Prime p)] (a : ℤ) :
    (p : ℤ) ∣ a ^ p - a := by
  have h : ((a ^ p - a : ℤ) : ZMod p) = 0 := by
    push_cast
    rw [ZMod.pow_card]
    ring
  exact (ZMod.intCast_zmod_eq_zero_iff_dvd _ p).mp h

/-- **Fermat's little theorem for p = 5.** For every integer `a`, `5 ∣ a^5 - a`. -/
theorem five_dvd_pow_five_sub_self (a : ℤ) : (5 : ℤ) ∣ a ^ 5 - a := by
  have : Fact (Nat.Prime 5) := ⟨by norm_num⟩
  exact_mod_cast prime_dvd_pow_sub_self 5 a

/-- **Strengthening.** For every integer `a`, `30 ∣ a^5 - a`, since `a^5 - a` is
divisible by each of the primes `2`, `3`, and `5`. -/
theorem thirty_dvd_pow_five_sub_self (a : ℤ) : (30 : ℤ) ∣ a ^ 5 - a := by
  have h2 : (2 : ℤ) ∣ a ^ 5 - a := by
    have : Fact (Nat.Prime 2) := ⟨by norm_num⟩
    have hf := prime_dvd_pow_sub_self 2 a
    have hfac : a ^ 5 - a = (a ^ 2 - a) * (a ^ 3 + a ^ 2 + a + 1) := by ring
    rw [hfac]
    exact Dvd.dvd.mul_right (by exact_mod_cast hf) _
  have h3 : (3 : ℤ) ∣ a ^ 5 - a := by
    have : Fact (Nat.Prime 3) := ⟨by norm_num⟩
    have hf := prime_dvd_pow_sub_self 3 a
    have hfac : a ^ 5 - a = (a ^ 2 + 1) * (a ^ 3 - a) := by ring
    rw [hfac]
    exact Dvd.dvd.mul_left (by exact_mod_cast hf) _
  have h5 : (5 : ℤ) ∣ a ^ 5 - a := five_dvd_pow_five_sub_self a
  have h6 : (6 : ℤ) ∣ a ^ 5 - a := (show IsCoprime (2 : ℤ) 3 by decide).mul_dvd h2 h3
  exact (show IsCoprime (6 : ℤ) 5 by decide).mul_dvd h6 h5

end FermatLittleP5