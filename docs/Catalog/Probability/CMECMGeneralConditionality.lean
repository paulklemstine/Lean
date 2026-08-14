/-
# CM-ECM-GENERAL: conditionality — why the `ℓ = 3` null is a *degeneracy*

`Probability.CMECMGeneralJ0` proves that the `ℓ = 3` ECM-order event on the
`j = 0` curve is unconditionally true, and `Probability.CMECMGeneralInformation`
proves that a constant event carries exactly zero bits.  Taken alone, those two
facts would also be consistent with the (false) reading "this information
functional is always `0`".  This file seals that gap from both sides:

* `empMI_perfect_correlation` : the empirical mutual information functional does
  attain the value `log 2 > 0` — one full bit — on a two-point sample, so the
  degeneracy theorem is not vacuous;

* `ell_five_order_event_nonconstant` : at `ℓ = 5` the ECM-order event
  `ℓ ∣ #E_{j0}(𝔽_p)` genuinely *varies* with `p` (`#E = 30` at `p = 29`,
  `#E = 6` at `p = 5`, both verified by kernel computation);

* `ell_five_channel_carries_one_bit` : consequently there is a sample of primes
  on which the `ℓ = 5` channel carries exactly `log 2` — while
  `ecm_order_channel_zero_information` shows the `ℓ = 3` channel carries `0` on
  *every* sample.

So the `ℓ = 3` null is a *rational-torsion degeneracy* of the event, not a
property of the statistic: the shadow is real only when the event is
conditional.

Finally `inert_dvd_iff` records the exact sense in which ECM on the `j = 0`
curve degenerates to the `p+1` method on the inert half: for `p ≡ 2 (mod 3)`
*every* divisibility question about the elliptic order is the same question
about `p + 1`.
-/
import Mathlib
import Probability.CMECMGeneralJ0
import Probability.CMECMGeneralInformation

namespace CMECMGeneralInfo

open Finset

/-! ## 1. The information functional is not identically zero -/

/-- **One full bit.**  A perfectly correlated class/event pair on a two-point
sample has empirical mutual information `log 2`. -/
theorem empMI_perfect_correlation : empMI (id : Bool → Bool) id = Real.log 2 := by
  have h1 : ({ω ∈ ({true, false} : Finset Bool) | ω = true}).card = 1 := by decide
  have h2 : ({ω ∈ ({true, false} : Finset Bool) | ω = false}).card = 1 := by decide
  simp only [empMI, joint, margClass, margEvent, Fintype.sum_bool, id]
  norm_num [h1, h2]
  ring

theorem empMI_perfect_correlation_pos : 0 < empMI (id : Bool → Bool) id := by
  rw [empMI_perfect_correlation]
  exact Real.log_pos (by norm_num)

/-- Contrapositive of the degeneracy law: a channel with nonzero empirical
mutual information must have a non-constant event. -/
theorem nonconstant_of_empMI_ne_zero {Ω : Type*} [Fintype Ω] [DecidableEq Ω] [Nonempty Ω]
    {κ : Type*} [Fintype κ] [DecidableEq κ] (c : Ω → κ) (E : Ω → Bool)
    (h : empMI c E ≠ 0) : ∀ v : Bool, ∃ ω, E ω ≠ v := by
  intro v
  by_contra hc
  push_neg at hc
  exact h (empMI_of_const c E v hc)

/-! ## 2. The `ℓ = 5` order event on the `j = 0` curve is conditional -/

instance : Fact (Nat.Prime 5) := ⟨by norm_num⟩
instance : Fact (Nat.Prime 29) := ⟨by norm_num⟩

/-- `p = 5` as a good prime of the `j = 0` curve. -/
def p5 : PrimeGt3 := ⟨5, by norm_num, by norm_num⟩

/-- `p = 29` as a good prime of the `j = 0` curve. -/
def p29 : PrimeGt3 := ⟨29, by norm_num, by norm_num⟩

/-- `#E_{j0}(𝔽_5) = 6` (kernel computation). -/
theorem cardJ0_p5 : cardJ0 p5 = 6 := by decide

/-- `#E_{j0}(𝔽_29) = 30` (kernel computation).  Note `29 ≡ 2 (mod 3)`, so this is
an instance of the inert collapse `#E = p + 1`. -/
theorem cardJ0_p29 : cardJ0 p29 = 30 := by decide

/-- **The `ℓ = 5` ECM-order event is not constant.**  Contrast with
`CMECMGeneral.three_dvd_curveCard_j0`, where the `ℓ = 3` event is constant. -/
theorem ell_five_order_event_nonconstant :
    ∃ q r : PrimeGt3, 5 ∣ cardJ0 q ∧ ¬ 5 ∣ cardJ0 r :=
  ⟨p29, p5, by rw [cardJ0_p29]; norm_num, by rw [cardJ0_p5]; norm_num⟩

/-- **The `ℓ = 5` channel can carry a full bit.**  On the two-prime sample
`{29, 5}` the `ℓ = 5` ECM-order event is perfectly correlated with the sample
label, so its empirical mutual information is `log 2` — whereas the `ℓ = 3`
event carries exactly `0` on *every* sample
(`ecm_order_channel_zero_information`). -/
theorem ell_five_channel_carries_one_bit :
    empMI (id : Bool → Bool)
      (fun ω : Bool => decide (5 ∣ cardJ0 (if ω then p29 else p5))) = Real.log 2 := by
  have hfun : (fun ω : Bool => decide (5 ∣ cardJ0 (if ω then p29 else p5))) = id := by
    funext ω
    cases ω
    · simp [cardJ0_p5]
    · simp [cardJ0_p29]
  rw [hfun, empMI_perfect_correlation]

/-! ## 3. The `ℓ = 9` residue dial is an *inert-half* phenomenon -/

instance : Fact (Nat.Prime 13) := ⟨by norm_num⟩
instance : Fact (Nat.Prime 31) := ⟨by norm_num⟩

/-- `p = 13`, a split prime (`13 ≡ 1 mod 3`, `13 ≡ 4 mod 9`). -/
def q13 : PrimeGt3 := ⟨13, by norm_num, by norm_num⟩

/-- `p = 31`, a split prime in the same class mod `9` (`31 ≡ 4 mod 9`). -/
def q31 : PrimeGt3 := ⟨31, by norm_num, by norm_num⟩

set_option maxRecDepth 40000 in
/-- `#E_{j0}(𝔽_13) = 12` (kernel computation). -/
theorem cardJ0_q13 : cardJ0 q13 = 12 := by decide

set_option maxRecDepth 40000 in
/-- `#E_{j0}(𝔽_31) = 36` (kernel computation). -/
theorem cardJ0_q31 : cardJ0 q31 = 36 := by decide

/-- **The `ℓ = 9` channel is invisible on the split half.**  On the inert half
`9 ∣ #E_{j0}(𝔽_p) ↔ p ≡ 8 (mod 9)` (`CMECMGeneral.inert_nine_dvd_iff`), a clean
residue dial.  On the split half no such dial exists: `13` and `31` are both
`≡ 1 (mod 3)` and both `≡ 4 (mod 9)`, yet `9 ∣ #E` holds for `31` and fails for
`13`.  So `9 ∣ #E` is not a function of `p mod 9` — the visibility is a
ramified-inert phenomenon, not a global congruence. -/
theorem nine_dvd_not_determined_by_residue_on_split_half :
    ∃ q r : PrimeGt3, q.1 % 9 = r.1 % 9 ∧ q.1 % 3 = 1 ∧ r.1 % 3 = 1 ∧
      9 ∣ cardJ0 q ∧ ¬ 9 ∣ cardJ0 r :=
  ⟨q31, q13, by norm_num [q31, q13], by norm_num [q31], by norm_num [q13],
    by rw [cardJ0_q31]; norm_num, by rw [cardJ0_q13]; norm_num⟩

/-! ## 4. On the inert half, ECM on `E_{j0}` *is* the `p+1` method -/

/-- For `p ≡ 2 (mod 3)` every divisibility question about the elliptic order is
literally the same question about `p + 1`: the CM curve gives no new smoothness
target beyond Williams' `p+1` method. -/
theorem inert_dvd_iff {p : ℕ} [Fact p.Prime] (hp : p % 3 = 2) (ℓ : ℕ) :
    ℓ ∣ ECMParity.curveCard (0 : ZMod p) 1 ↔ ℓ ∣ p + 1 := by
  rw [CMECMGeneral.inert_curveCard hp]

end CMECMGeneralInfo