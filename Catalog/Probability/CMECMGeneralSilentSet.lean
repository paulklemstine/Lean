/-
# CM-ECM-GENERAL: closing three open follow-ups of the round-17 cycle

`Probability.CMECMGeneralJ0`, `…Information`, `…TorsionSix` and
`…Conditionality` establish, for the `j = 0` curve `E : y² = x³ + 1`:

* `6 ∣ #E(𝔽_p)` for every prime `p > 3` (rational `6`-torsion degeneracy), hence
  the `ℓ ∈ {1,2,3,6}` ECM-order channels are *silent* (exactly zero bits);
* the union-dilution inequality with its exact factor;
* the inert collapse `#E(𝔽_p) = p + 1` for `p ≡ 2 (mod 3)` and the `ℓ = 9`
  residue dial `9 ∣ #E ↔ p ≡ 8 (mod 9)`.

This file closes the three follow-up questions those results left open.

## 1. The silent set is *exactly* the divisor set of `6` (conjecture C1)

`ecm_channel_silent_iff_dvd_six`: for **every** `ℓ`, the ECM-order event
`ℓ ∣ #E(𝔽_p)` is unconditionally true on all good primes **iff** `ℓ ∣ 6`.  The
"only if" half needs just one prime, `p = 5`, where `#E = 6`; the "if" half is
the torsion degeneracy.  So the zero-bit locus of the `j = 0` curve is
`{1,2,3,6}` and nothing more — the degeneracy is precisely the rational torsion.
`ecm_channel_one_bit_of_witnesses` converts any pair of primes with different
`ℓ`-divisibility into a sample on which the channel carries a full `log 2`, and
`ecm_channel_dichotomy` states the resulting all-or-nothing alternative.

## 2. The inert dial is complete at every modulus (conjecture C2, inert half)

`inert_dial`: for `p ≡ 2 (mod 3)` and *every* `ℓ ≥ 1`,
`ℓ ∣ #E(𝔽_p) ↔ p ≡ ℓ - 1 (mod ℓ)`; specialised to `ℓ = 3^m` in
`inert_prime_power_dial`, and stated as genuine residue visibility in
`inert_dial_residue_visible` (two inert primes in the same class mod `ℓ` have
the same `ℓ`-divisibility).  Contrast
`nine_dvd_not_determined_by_residue_on_split_half`: on the split half no such
dial exists already at `ℓ = 9`.

## 3. Union dilution is sharp (conjecture C3)

`union_dilution_sharp`: every dilution factor `c ∈ (0,1)` is attained *exactly*
by an honest two-class binary channel with a class-blind admixture.  Together
with `union_dilution` (the factor is never `> 1`) this pins the law: mixing in a
class-blind half multiplies the correlation ratio by
`μ_A(1-μ_A)/μ_U(1-μ_U) ∈ (0,1]`, and every such value occurs.
-/
import Mathlib
import Algebra.ECMParityCore
import Probability.CMECMGeneralJ0
import Probability.CMECMGeneralInformation
import Probability.CMECMGeneralTorsionSix
import Probability.CMECMGeneralConditionality
import Probability.CMECMGeneralSupersingular

namespace CMECMGeneralInfo

open Finset

/-! ## 1. The silent set of the `j = 0` curve is exactly the divisors of `6` -/

/-- `6 ∣ #E_{j0}(𝔽_q)` for every good prime, restated on `PrimeGt3`. -/
theorem six_dvd_cardJ0 (q : PrimeGt3) : 6 ∣ cardJ0 q := by
  obtain ⟨n, hn, hn3⟩ := q
  exact @CMECMGeneral.six_dvd_curveCard_j0 n ⟨hn⟩ (by omega) (by omega)

/-- **Silent-set classification.**  The ECM-order event `ℓ ∣ #E_{j0}(𝔽_p)` holds
unconditionally on the good primes if and only if `ℓ ∣ 6`.  Hence the zero-bit
locus of the `j = 0` curve is exactly `{1, 2, 3, 6}`: silence is *equivalent* to
rational torsion, not merely implied by it. -/
theorem ecm_channel_silent_iff_dvd_six (ℓ : ℕ) :
    (∀ q : PrimeGt3, ℓ ∣ cardJ0 q) ↔ ℓ ∣ 6 := by
  constructor
  · intro h
    have h5 := h p5
    rwa [cardJ0_p5] at h5
  · intro h q
    exact h.trans (six_dvd_cardJ0 q)

/-- A non-silent channel is not merely nonconstant: on the two-prime sample built
from any pair of witnesses it carries a full bit, `log 2`.  This is the general
form of `ell_five_channel_carries_one_bit`. -/
theorem ecm_channel_one_bit_of_witnesses {ℓ : ℕ} {q r : PrimeGt3}
    (hq : ℓ ∣ cardJ0 q) (hr : ¬ ℓ ∣ cardJ0 r) :
    empMI (id : Bool → Bool)
      (fun ω : Bool => decide (ℓ ∣ cardJ0 (if ω then q else r))) = Real.log 2 := by
  have hfun : (fun ω : Bool => decide (ℓ ∣ cardJ0 (if ω then q else r))) = id := by
    funext ω
    cases ω
    · simp [hr]
    · simp [hq]
  rw [hfun, empMI_perfect_correlation]

/-- **All-or-nothing dichotomy for the `j = 0` ECM-order channels.**  For every
`ℓ`, either `ℓ ∣ 6`, and then the channel carries exactly `0` bits on every
sample and every class statistic; or `ℓ ∤ 6`, and then *any* good prime realising
the divisibility already yields a two-prime sample (paired with `p = 5`) on which
the same channel carries a full `log 2`. -/
theorem ecm_channel_dichotomy (ℓ : ℕ) :
    (ℓ ∣ 6 ∧ ∀ (Ω : Type) (_ : Fintype Ω) (_ : DecidableEq Ω) (_ : Nonempty Ω)
        (sample : Ω → PrimeGt3) (c : Ω → Bool),
        empMI c (fun ω => decide (ℓ ∣ cardJ0 (sample ω))) = 0) ∨
    (¬ ℓ ∣ 6 ∧ ∀ q : PrimeGt3, ℓ ∣ cardJ0 q →
        empMI (id : Bool → Bool)
          (fun ω : Bool => decide (ℓ ∣ cardJ0 (if ω then q else p5))) = Real.log 2) := by
  by_cases h : ℓ ∣ 6
  · refine Or.inl ⟨h, ?_⟩
    intro Ω _ _ _ sample c
    refine empMI_of_const c _ true (fun ω => ?_)
    have hd : ℓ ∣ cardJ0 (sample ω) := h.trans (six_dvd_cardJ0 (sample ω))
    simp [hd]
  · refine Or.inr ⟨h, ?_⟩
    intro q hq
    refine ecm_channel_one_bit_of_witnesses hq ?_
    rw [cardJ0_p5]
    exact h

/-! ## 2. The inert residue dial at every modulus -/

/-- Divisibility of `n + 1` by `ℓ` is exactly the residue condition
`n ≡ ℓ - 1 (mod ℓ)`. -/
theorem dvd_succ_iff_mod {ℓ : ℕ} (hℓ : 0 < ℓ) (n : ℕ) : ℓ ∣ n + 1 ↔ n % ℓ = ℓ - 1 := by
  have hlt : n % ℓ < ℓ := Nat.mod_lt _ hℓ
  have key : (n + 1) % ℓ = (n % ℓ + 1) % ℓ := (Nat.mod_add_mod n ℓ 1).symm
  rw [Nat.dvd_iff_mod_eq_zero, key]
  constructor
  · intro h
    by_contra hne
    have hlt' : n % ℓ + 1 < ℓ := by omega
    rw [Nat.mod_eq_of_lt hlt'] at h
    omega
  · intro h
    have heq : n % ℓ + 1 = ℓ := by omega
    rw [heq, Nat.mod_self]

/-- **The inert dial, at every modulus.**  For `p ≡ 2 (mod 3)` the elliptic order
is `p + 1` exactly, so for every `ℓ ≥ 1` the ECM-order event is a pure residue
condition on `p`: `ℓ ∣ #E_{j0}(𝔽_p) ↔ p ≡ ℓ - 1 (mod ℓ)`. -/
theorem inert_dial {p : ℕ} [Fact p.Prime] (hp : p % 3 = 2) {ℓ : ℕ} (hℓ : 0 < ℓ) :
    ℓ ∣ ECMParity.curveCard (0 : ZMod p) 1 ↔ p % ℓ = ℓ - 1 := by
  rw [CMECMGeneral.inert_curveCard hp, dvd_succ_iff_mod hℓ]

/-- The `ℓ = 3^m` case: the `9 ∣ #E ↔ p ≡ 8 (mod 9)` dial of
`CMECMGeneral.inert_nine_dvd_iff` is the `m = 2` instance of a dial at every
power of the ramified prime. -/
theorem inert_prime_power_dial {p : ℕ} [Fact p.Prime] (hp : p % 3 = 2) (m : ℕ) :
    (3 : ℕ) ^ m ∣ ECMParity.curveCard (0 : ZMod p) 1 ↔ p % 3 ^ m = 3 ^ m - 1 :=
  inert_dial hp (pow_pos (by norm_num) m)

/-- **Residue visibility on the inert half.**  Two inert primes in the same class
mod `ℓ` have the same `ℓ`-divisibility of the elliptic order: the ECM-order event
is a function of `p mod ℓ` there.  (On the split half this fails already at
`ℓ = 9`, by `nine_dvd_not_determined_by_residue_on_split_half`.) -/
theorem inert_dial_residue_visible {p q : ℕ} [Fact p.Prime] [Fact q.Prime]
    (hp : p % 3 = 2) (hq : q % 3 = 2) {ℓ : ℕ} (hℓ : 0 < ℓ) (hres : p % ℓ = q % ℓ) :
    (ℓ ∣ ECMParity.curveCard (0 : ZMod p) 1 ↔ ℓ ∣ ECMParity.curveCard (0 : ZMod q) 1) := by
  rw [inert_dial hp hℓ, inert_dial hq hℓ, hres]

/-! ## 3. Sharpness of the union-dilution law -/

section Sharp

/-- Weighted mean of a two-class channel with equal class weights. -/
theorem wmean_cond (A B : ℝ) :
    wmean (fun _ : Bool => (1 : ℝ) / 2) (fun k => cond k A B) = (A + B) / 2 := by
  simp [wmean]; ring

/-- Weighted conditional variance of a two-class channel with equal class
weights: the squared half-gap between the two conditional probabilities. -/
theorem wvar_cond (A B : ℝ) :
    wvar (fun _ : Bool => (1 : ℝ) / 2) (fun k => cond k A B) = ((A - B) / 2) ^ 2 := by
  simp only [wvar, wmean_cond, Fintype.sum_bool, cond_true, cond_false]
  ring

/-- Adding a class-blind probability `s` to a two-class channel. -/
theorem shift_cond (A B s : ℝ) :
    (fun k : Bool => cond k A B + s) = (fun k : Bool => cond k (A + s) (B + s)) := by
  funext k; cases k <;> simp

/-- **Union dilution is sharp.**  For every target factor `c ∈ (0,1)` there is an
honest binary channel — two equally likely classes, strictly positive
conditional probabilities, a class-blind admixture of probability `b > 0`, a
nondegenerate conditional variation, and a union base rate exactly `1/2` — whose
normalised conditional variation is diluted by *exactly* the factor `c`.

Together with `union_dilution` (the factor never exceeds `1`) and
`eta2_dilution_factor` (the factor is `μ_A(1-μ_A)/μ_U(1-μ_U)`) this pins the
law: the set of achievable dilution factors is exactly `(0,1]`.  In particular
the experiment's observation "CM shadow ≤ inert-class channel" is not an
artefact of the particular curve, and no smaller universal bound holds. -/
theorem union_dilution_sharp {c : ℝ} (hc0 : 0 < c) (hc1 : c < 1) :
    ∃ (a : Bool → ℝ) (b : ℝ),
      (∀ k, 0 < a k) ∧ (∀ k, a k + b < 1) ∧ 0 < b ∧
      0 < wvar (fun _ : Bool => (1 : ℝ) / 2) a ∧
      0 < wmean (fun _ : Bool => (1 : ℝ) / 2) a ∧
      wmean (fun _ : Bool => (1 : ℝ) / 2) a + b = 1 / 2 ∧
      eta2 (fun _ : Bool => (1 : ℝ) / 2) (fun k => a k + b)
        = c * eta2 (fun _ : Bool => (1 : ℝ) / 2) a := by
  set r : ℝ := Real.sqrt (1 - c) with hr
  have hr0 : 0 ≤ r := Real.sqrt_nonneg _
  have hrsq : r ^ 2 = 1 - c := by rw [hr, Real.sq_sqrt]; linarith
  have hrpos : 0 < r := by
    rcases lt_or_eq_of_le hr0 with h | h
    · exact h
    · exfalso; rw [← h] at hrsq; norm_num at hrsq; linarith
  have hrlt : r < 1 := by nlinarith
  set mu : ℝ := (1 - r) / 2 with hmu
  have hmupos : 0 < mu := by rw [hmu]; linarith
  have hmuhalf : mu < 1 / 2 := by rw [hmu]; linarith
  refine ⟨fun k => cond k (mu + mu / 2) (mu - mu / 2), 1 / 2 - mu, ?_, ?_, by linarith,
    ?_, ?_, ?_, ?_⟩
  · intro k; cases k <;> simp <;> linarith
  · intro k; cases k <;> simp <;> linarith
  · rw [wvar_cond]
    have hd : (mu + mu / 2 - (mu - mu / 2)) / 2 = mu / 2 := by ring
    rw [hd]; positivity
  · rw [wmean_cond]; linarith
  · rw [wmean_cond]; ring
  · have hfac : 4 * (mu * (1 - mu)) = c := by rw [hmu]; nlinarith [hrsq]
    have h4 : (4 : ℝ) - mu * 4 ≠ 0 := by intro h; nlinarith
    have hmune : mu ≠ 0 := ne_of_gt hmupos
    rw [shift_cond]
    unfold eta2
    rw [wmean_cond, wvar_cond, wmean_cond, wvar_cond, ← hfac]
    field_simp
    linear_combination (-4 * mu ^ 2) * (inv_mul_cancel₀ h4)

end Sharp

/-! ## 4. `3`-adic Hecke visibility: the trace dial is inert-only -/

section Hecke

/-- On the inert half the trace of Frobenius is *constant* (equal to `0`), hence
trivially a function of any residue class: the `3`-adic datum `a_p mod 3^k` is
completely visible there. -/
theorem trace_determined_on_inert_half (q r : PrimeGt3)
    (hq : q.1 % 3 = 2) (hr : r.1 % 3 = 2) : traceOf q = traceOf r := by
  rw [(traceOf_eq_zero_iff q).mpr hq, (traceOf_eq_zero_iff r).mpr hr]

/-- `a_13 = 2` for the `j = 0` curve (from `#E(𝔽₁₃) = 12`). -/
theorem traceOf_q13 : traceOf q13 = 2 := by
  have h : cardJ0 q13 = 12 := cardJ0_q13
  unfold traceOf CMECMGeneral.traceJ0
  unfold cardJ0 at h
  rw [h]
  norm_num [q13]

/-- `a_31 = -4` for the `j = 0` curve (from `#E(𝔽₃₁) = 36`). -/
theorem traceOf_q31 : traceOf q31 = -4 := by
  have h : cardJ0 q31 = 36 := cardJ0_q31
  unfold traceOf CMECMGeneral.traceJ0
  unfold cardJ0 at h
  rw [h]
  norm_num [q31]

/-- **The trace is `3`-adically invisible on the split half.**  `13` and `31` are
both `≡ 1 (mod 3)` and lie in the same class `4 mod 9`, yet `a_13 = 2` and
`a_31 = -4` are *different* mod `9`.  So, unlike the inert half
(`trace_determined_on_inert_half`), the split-half Hecke term is not a function
of `p mod 9`: the `9 ∣ #E` dial of `CMECMGeneral.inert_nine_dvd_iff` really is a
ramified-inert phenomenon. -/
theorem trace_mod_nine_not_determined_on_split_half :
    ∃ q r : PrimeGt3, q.1 % 9 = r.1 % 9 ∧ q.1 % 3 = 1 ∧ r.1 % 3 = 1 ∧
      ¬ traceOf q ≡ traceOf r [ZMOD 9] := by
  refine ⟨q13, q31, by norm_num [q13, q31], by norm_num [q13], by norm_num [q31], ?_⟩
  rw [traceOf_q13, traceOf_q31]
  decide

end Hecke

end CMECMGeneralInfo