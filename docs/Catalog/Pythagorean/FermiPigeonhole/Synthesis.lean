/-
# Synthesis: the Fermi "paradox" is a theorem about small first moments

Two clean general statements, then the cosmological instantiation.

General form:

* `contact_le_expectation_sq_div_epochs`: `Prb (Contact) ≤ (N * p) ^ 2 / T`.
  Writing `E = N * p` for the Drake expectation, the chance of *any* contact ever
  happening is at most `E ^ 2 / T`: quadratic in the expectation and inversely
  proportional to the amount of available time.
* `fermi_dichotomy`: if `E < 1`, then simultaneously
  (i) a completely lifeless cosmos has probability at least `1 - E > 0`,
  (ii) contact has probability at most `1 / T`, and
  (iii) more than `T - 1` epochs are expected to be empty.

Cosmological instantiation (`fermiN`, `fermiT`, `fermiP`): `10 ^ 10` habitable
sites, `4.5 * 10 ^ 9` one-year epochs, and a per-site probability `10 ^ (-11)` of
producing a technological civilization.  Then `E = 0.1`, the cosmos is lifeless
with probability at least `0.9`, and contact has probability below `10 ^ (-11)`.

The moral: nothing is paradoxical.  With `E < 1` pigeons and `T` holes, the
pigeonhole principle predicts empty holes; the observation "we see nobody" is the
prediction, not an anomaly.
-/
import Pythagorean.FermiPigeonhole.Contact
import Pythagorean.FermiPigeonhole.EmptyEpochs
import Pythagorean.FermiPigeonhole.LifetimeWindow

namespace Pythagorean.FermiPigeonhole

open Finset

variable {N T : ℕ} {p : ℝ}

/-- **Contact is controlled by the square of the Drake expectation.** -/
theorem contact_le_expectation_sq_div_epochs (h0 : 0 ≤ p) (h1 : p ≤ 1) (hT : 0 < T) :
    Prb N T p (Contact N T) ≤ ((N : ℝ) * p) ^ 2 / T := by
  have hbase := prb_contact_le (N := N) (T := T) (p := p) h0 h1 hT
  have hTpos : (0 : ℝ) < T := by exact_mod_cast hT
  have hq : (0 : ℝ) ≤ p ^ 2 / T := by positivity
  have hcard : ((N : ℝ) ^ 2 - N) ≤ (N : ℝ) ^ 2 := by
    have : (0 : ℝ) ≤ (N : ℝ) := Nat.cast_nonneg _
    linarith
  refine hbase.trans ?_
  calc ((N : ℝ) ^ 2 - N) * (p ^ 2 / T) ≤ (N : ℝ) ^ 2 * (p ^ 2 / T) := by
        exact mul_le_mul_of_nonneg_right hcard hq
    _ = ((N : ℝ) * p) ^ 2 / T := by ring

/-- **The Fermi dichotomy.**  A Drake expectation below one forces a lifeless
cosmos to be likely, contact to be very unlikely, and almost all epochs to be
empty. -/
theorem fermi_dichotomy (h0 : 0 ≤ p) (h1 : p ≤ 1) (hT : 0 < T)
    (hE : (N : ℝ) * p < 1) :
    (1 - (N : ℝ) * p ≤ Prb N T p {f | ∀ i, f i = none} ∧
        0 < Prb N T p {f | ∀ i, f i = none}) ∧
      Prb N T p (Contact N T) ≤ 1 / T ∧
      (T : ℝ) - 1 < ∑ f : Cosmos N T, weight N T p f * ((emptyEpochs N T f).card : ℝ) := by
  have hTpos : (0 : ℝ) < T := by exact_mod_cast hT
  have hEnn : 0 ≤ (N : ℝ) * p := mul_nonneg (Nat.cast_nonneg _) h0
  refine ⟨⟨prb_lifeless_ge h1, ?_⟩, ?_, ?_⟩
  · exact lt_of_lt_of_le (by linarith) (prb_lifeless_ge (N := N) (T := T) h1)
  · refine (contact_le_expectation_sq_div_epochs h0 h1 hT).trans ?_
    have hsq : ((N : ℝ) * p) ^ 2 ≤ 1 := by nlinarith
    exact div_le_div_of_nonneg_right hsq hTpos.le
  · have := expected_empty_epochs_ge (N := N) (T := T) (p := p) h0 h1 hT
    linarith

/-- Number of habitable sites used in the cosmological instantiation: `10 ^ 10`. -/
def fermiN : ℕ := 10 ^ 10

/-- Number of one-year epochs used in the cosmological instantiation: `4.5 * 10 ^ 9`. -/
def fermiT : ℕ := 4500000000

/-- Per-site probability of producing a technological civilization: `10 ^ (-11)`. -/
noncomputable def fermiP : ℝ := 1 / 10 ^ 11

lemma fermiP_nonneg : 0 ≤ fermiP := by
  rw [fermiP]; positivity

lemma fermiP_le_one : fermiP ≤ 1 := by
  rw [fermiP]; norm_num

lemma fermiT_pos : 0 < fermiT := by
  rw [fermiT]; norm_num

/-- With the conservative Drake estimates, the expected number of technological
civilizations in the observable universe is `1/10`: strictly less than one. -/
theorem fermi_expected_count :
    ∑ f : Cosmos fermiN fermiT, weight fermiN fermiT fermiP f
        * (civCount fermiN fermiT f : ℝ) = 1 / 10 := by
  rw [drake_expected_count (N := fermiN) (T := fermiT) (p := fermiP) fermiT_pos]
  rw [fermiN, fermiP]
  norm_num

/-- The Drake expectation of the cosmological instantiation is below one. -/
lemma fermi_expectation_lt_one : (fermiN : ℝ) * fermiP < 1 := by
  rw [fermiN, fermiP]; norm_num

/-- With the conservative Drake estimates, the universe is completely lifeless with
probability at least `9/10`. -/
theorem fermi_lifeless_ge :
    (9 : ℝ) / 10 ≤ Prb fermiN fermiT fermiP {f | ∀ i, f i = none} := by
  have h := prb_lifeless_ge (N := fermiN) (T := fermiT) fermiP_le_one
  have hval : (fermiN : ℝ) * fermiP = 1 / 10 := by rw [fermiN, fermiP]; norm_num
  rw [hval] at h
  linarith

/-- With the conservative Drake estimates, the probability that two contemporaneous
civilizations ever exist is below `10 ^ (-11)`. -/
theorem fermi_contact_le :
    Prb fermiN fermiT fermiP (Contact fermiN fermiT) ≤ 1 / 10 ^ 11 := by
  have h := prb_contact_le (N := fermiN) (T := fermiT) (p := fermiP)
    fermiP_nonneg fermiP_le_one fermiT_pos
  refine h.trans ?_
  rw [fermiN, fermiT, fermiP]
  norm_num

/-- **Two-sided estimate.**  With the conservative Drake estimates, the probability
that the universe contains at least one technological civilization lies between
`19/200 = 0.095` and `1/10 = 0.1`; in particular the model is not vacuous, and the
first-moment answer is correct to within `5 * 10 ^ (-3)`. -/
theorem fermi_someone_exists_sandwich :
    (19 : ℝ) / 200 ≤ Prb fermiN fermiT fermiP {f | ∃ i, f i ≠ none} ∧
      Prb fermiN fermiT fermiP {f | ∃ i, f i ≠ none} ≤ 1 / 10 := by
  have hval : (fermiN : ℝ) * fermiP = 1 / 10 := by rw [fermiN, fermiP]; norm_num
  have hlo := prb_exists_civ_ge (N := fermiN) (T := fermiT) (p := fermiP)
    fermiP_nonneg fermiP_le_one fermiT_pos
  have hhi := prb_exists_civ_le (N := fermiN) (T := fermiT) (p := fermiP)
    fermiP_nonneg fermiP_le_one fermiT_pos
  rw [hval] at hlo hhi
  constructor
  · refine le_trans ?_ hlo
    norm_num
  · exact hhi

/-- **Generous lifetimes do not rescue contact.**  Even granting every civilization
a detectability lifetime of `10 ^ 4` epochs (ten thousand years), the probability
that two civilizations are ever mutually detectable stays below `10 ^ (-7)`. -/
theorem fermi_windowContact_le :
    Prb fermiN fermiT fermiP (WindowContact fermiN fermiT (10 ^ 4)) ≤ 1 / 10 ^ 7 := by
  have h := prb_windowContact_le (N := fermiN) (T := fermiT) (L := 10 ^ 4) (p := fermiP)
    fermiP_nonneg fermiP_le_one fermiT_pos
  refine h.trans ?_
  rw [fermiN, fermiT, fermiP]
  norm_num

/-- With the conservative Drake estimates, all but at most a tenth of an epoch is
expected to be empty: at least `4499999999.9` of the `4.5 * 10 ^ 9` epochs contain
no civilization. -/
theorem fermi_empty_epochs :
    (4500000000 : ℝ) - 1 / 10
      ≤ ∑ f : Cosmos fermiN fermiT,
          weight fermiN fermiT fermiP f * ((emptyEpochs fermiN fermiT f).card : ℝ) := by
  have h := expected_empty_epochs_ge (N := fermiN) (T := fermiT) (p := fermiP)
    fermiP_nonneg fermiP_le_one fermiT_pos
  have hval : (fermiN : ℝ) * fermiP = 1 / 10 := by rw [fermiN, fermiP]; norm_num
  have hT : ((fermiT : ℕ) : ℝ) = 4500000000 := by rw [fermiT]; norm_num
  rw [hval, hT] at h
  exact h

end Pythagorean.FermiPigeonhole