import Probability.NET76TokenMatched
import Shared.AttentionBudgetScaling

/-!
# NET-76, cycle 4: a checkable certificate for the token-matched factor

Cycle 3 (`Probability.NET76TokenMatched`) reduced the question "does this domain have a
multiplicative budget factor at equal token counts?" to a question about the *base*
curve alone: the factor exists exactly when the base knee is flat across the factor's
ratio.  This file supplies the missing certificate — a condition on the attention
profile itself that decides flatness — and applies it to the reported table.

* `kstar_mono_context` — the knee is monotone in the context length, for every positive
  profile.  (Retained mass is antitone in the context, so a longer context can only
  raise the budget.)
* `kstar_eq_of_tail_gate` — **the certificate.**  For a profile with geometric decay
  ratio `r`, if the tail beyond the *measured* knee already fits under the gate slack,
  `r ^ k* / (1 - r) ≤ 1 - τ`, then the knee never moves again: `k*(w, m) = k*(w, n)` for
  every `m ≥ n`.  This is a finite, checkable inequality in the two numbers `(r, τ)`
  and one measurement.
* `eventual_exact_flatness` — unconditionally, a geometrically decaying profile has an
  *exactly* flat knee from some context onwards.  Monotonicity plus the uniform budget
  of `Shared.AttentionBudgetScaling` forces the integer sequence `n ↦ k*(w, n)` to
  stabilise.  This sharpens the "boundedness, not equality" caveat of the earlier
  theory: equality does hold, eventually.
* `geometric_admits_token_matched_factor` — combining with cycle 3: past the
  stabilisation point every dilation of a geometric profile satisfies the token-matched
  factor law exactly.  So a token-matched domain factor is not vacuous — it is the
  privilege of spectral-gap domains.
* `rising_knee_falsifies_tail_gate` and `net76_english_row_has_no_certificate` — the
  converse for the reported data: a base curve that still moves across a doubling (the
  reported `16 → 20`) fails the certificate for *every* decay ratio `r`, hence admits
  no exact token-matched factor at that context.  The reported table therefore reports
  factors in a regime where, by its own increments, factors are not defined.

-- !-- Lab Notes -- !--
Hypothesizer (cycle 4):
 (L1) The knee is monotone in context for every profile.                [confirmed: `kstar_mono_context`]
 (L2) Geometric decay makes the knee *eventually constant*, not merely bounded. [confirmed: `eventual_exact_flatness`]
 (L3) A checkable inequality in (r, τ, k*) certifies flatness from a single measurement. [confirmed: `kstar_eq_of_tail_gate`]
 (L4) Therefore exactly the spectral-gap domains admit an exact token-matched factor. [confirmed in one direction:
      `geometric_admits_token_matched_factor`; the other direction is cycle 3's `token_matched_factor_forces_stability`]
 (L5) The reported English chain (+4 per doubling) passes some certificate.  [REFUTED: `net76_english_row_has_no_certificate`]

Analyst: L5 fails for a structural reason, not a numerical one — the certificate and a
strictly rising knee are contradictory for *every* `r < 1` simultaneously, because the
certificate's conclusion is exact equality of two measured integers.  The informative
consequence is a dichotomy: a domain either stabilises (and then has an honest factor)
or keeps rising (and then no factor is defined for it at the measured context).

Critic: `eventual_exact_flatness` is not vacuous — `exact_flatness_refuted` in
`Shared.AttentionBudgetScaling` shows the knee genuinely moves at small contexts, so
the stabilisation point is not `1`; and the certificate is not circular, since its
hypothesis mentions only `r`, `τ` and the knee at the *single* context where the
measurement was made.
-/

namespace Catalog.Probability.NET76StabilityCertificate

open Finset AttentionBudget Catalog.Probability.NET76DomainDilation
open Catalog.Probability.NET76TokenMatched

variable {w : ℕ → ℝ} {r tau : ℝ} {c m n : ℕ}

/-! ## 1.  Monotonicity of the knee in the context length -/

/-- **The knee is monotone in the context.**  Retained mass is antitone in the context
length, so a longer context can only push the budget up. -/
theorem kstar_mono_context (hw : ∀ i, 0 < w i) (htau : tau ≤ 1) (hn : 1 ≤ n)
    (hnm : n ≤ m) : kstar w n tau ≤ kstar w m tau := by
  have hpass := gate_le_retained_kstar hw (n := m) (by omega) htau
  exact kstar_le_of_pass (le_trans hpass (retained_antitone_context hw _ hn hnm))

/-! ## 2.  The certificate -/

/-- **The flatness certificate.**  For a profile with decay ratio `r`, if the geometric
tail beyond the measured knee already fits inside the gate slack,
`r ^ k*(w,n) / (1 - r) ≤ 1 - τ`, then the knee is frozen: it takes the same value at
every longer context.  The hypothesis is a finite inequality in the three numbers
`r`, `τ` and the single measurement `k*(w, n)`. -/
theorem kstar_eq_of_tail_gate (hw : ∀ i, 0 < w i) (hr0 : 0 < r) (hr1 : r < 1)
    (hdec : ∀ i, w (i + 1) ≤ r * w i) (htau0 : 0 < tau) (htau : tau ≤ 1) (hn : 1 ≤ n)
    (hgate : r ^ (kstar w n tau) / (1 - r) ≤ 1 - tau) (hnm : n ≤ m) :
    kstar w m tau = kstar w n tau := by
  have hK1 : 1 ≤ kstar w n tau := kstar_pos hw (by omega) htau0 htau
  have hlow := retained_ge_of_geometric_decay hw hr0 hr1 hdec (k := kstar w n tau)
    (n := m) hK1 (by omega)
  have hpass : tau ≤ retained w m (kstar w n tau) := by linarith
  exact le_antisymm (kstar_le_of_pass hpass) (kstar_mono_context hw htau hn hnm)

/-- **Eventual exact flatness.**  A geometrically decaying profile has a knee that is
monotone (`kstar_mono_context`) and uniformly bounded
(`ctxStable_of_geometric_decay`), hence *constant* from some context onwards.  The
earlier theory could only claim boundedness; the sharpening to equality is what a
token-matched factor needs. -/
theorem eventual_exact_flatness (hw : ∀ i, 0 < w i) (hr0 : 0 < r) (hr1 : r < 1)
    (hdec : ∀ i, w (i + 1) ≤ r * w i) (htau : tau ≤ 1) (htau1 : tau < 1) :
    ∃ N : ℕ, 1 ≤ N ∧ ∀ m : ℕ, N ≤ m → kstar w m tau = kstar w N tau := by
  obtain ⟨B, hB⟩ := ctxStable_of_geometric_decay hw hr0 hr1 hdec htau1
  set A : Set ℕ := {v : ℕ | ∃ m : ℕ, 1 ≤ m ∧ kstar w m tau = v} with hA
  have hne : A.Nonempty := ⟨kstar w 1 tau, 1, le_rfl, rfl⟩
  have hbdd : BddAbove A := by
    refine ⟨B, ?_⟩
    rintro v ⟨m, hm, rfl⟩
    exact hB m hm
  obtain ⟨N, hN1, hNv⟩ := Nat.sSup_mem hne hbdd
  refine ⟨N, hN1, fun m hm => ?_⟩
  have h1 : kstar w N tau ≤ kstar w m tau := kstar_mono_context hw htau hN1 hm
  have h2 : kstar w m tau ≤ sSup A := le_csSup hbdd ⟨m, by omega, rfl⟩
  omega

/-! ## 3.  Spectral-gap domains do admit a token-matched factor -/

/-- **The positive half of the dichotomy.**  Past its stabilisation point, a
geometrically decaying base profile is flat across every ratio, so — with the usual gate
condition of `kstar_dilate_eq_mul` — every block dilation of it satisfies the
token-matched factor law *exactly*.  A domain factor at equal token counts is therefore
a real phenomenon, available precisely to spectral-gap domains. -/
theorem geometric_admits_token_matched_factor (hw : ∀ i, 0 < w i) (hr0 : 0 < r)
    (hr1 : r < 1) (hdec : ∀ i, w (i + 1) ≤ r * w i) (htau0 : 0 < tau) (htau : tau ≤ 1)
    (htau1 : tau < 1) :
    ∃ N : ℕ, 1 ≤ N ∧ ∀ c n : ℕ, 0 < c → N ≤ n →
      retained (dilate c w) (c * n) (c * kstar w n tau - 1) < tau →
        kstar (dilate c w) (c * n) tau = c * kstar w (c * n) tau := by
  obtain ⟨N, hN1, hflat⟩ := eventual_exact_flatness hw hr0 hr1 hdec htau htau1
  refine ⟨N, hN1, fun c n hc hn hgate => ?_⟩
  have hcn : N ≤ c * n := le_trans hn (Nat.le_mul_of_pos_left n hc)
  have hstab : kstar w n tau = kstar w (c * n) tau := by
    rw [hflat n hn, hflat (c * n) hcn]
  exact stable_base_gives_token_matched_factor hw hc (by omega) htau0 htau hstab hgate

/-! ## 4.  The reported English row has no certificate -/

/-- **The negative half.**  If the base knee still moves across a doubling — which the
reported `16 → 20` English chain asserts — then the certificate fails, for *every*
admissible decay ratio `r`: the geometric tail beyond the measured knee is strictly
larger than the gate slack. -/
theorem rising_knee_falsifies_tail_gate (hw : ∀ i, 0 < w i) (hr0 : 0 < r) (hr1 : r < 1)
    (hdec : ∀ i, w (i + 1) ≤ r * w i) (htau0 : 0 < tau) (htau : tau ≤ 1) (hn : 1 ≤ n)
    (hrise : kstar w n tau < kstar w (2 * n) tau) :
    1 - tau < r ^ (kstar w n tau) / (1 - r) := by
  by_contra hcon
  push_neg at hcon
  have := kstar_eq_of_tail_gate hw hr0 hr1 hdec htau0 htau hn hcon
    (m := 2 * n) (by omega)
  omega

/-- **The reported English row, audited against the certificate.**  Assume the reported
English measurements `k*@512 = 16` and `k*@1024 = 20`.  Then no decay ratio certifies
flatness at `512`, and consequently — by cycle 3 — no exact token-matched factor exists
at that context for any dilation depth. -/
theorem net76_english_row_has_no_certificate (hw : ∀ i, 0 < w i) (hr0 : 0 < r)
    (hr1 : r < 1) (hdec : ∀ i, w (i + 1) ≤ r * w i) (htau0 : 0 < tau) (htau : tau ≤ 1)
    (hn : 1 ≤ n) (h512 : kstar w n tau = 16) (h1024 : kstar w (2 * n) tau = 20) :
    1 - tau < r ^ 16 / (1 - r) ∧
      ∀ c : ℕ, 2 ≤ c → kstar (dilate c w) (c * n) tau ≠ c * kstar w (c * n) tau := by
  have hrise : kstar w n tau < kstar w (2 * n) tau := by omega
  refine ⟨?_, fun c hc2 => ?_⟩
  · have := rising_knee_falsifies_tail_gate hw hr0 hr1 hdec htau0 htau hn hrise
    rwa [h512] at this
  · -- a factor at context `c·n` would force `k*(w, n) = k*(w, c·n)`, i.e. flatness,
    -- but `c·n ≥ 2n` and the knee already rose between `n` and `2n`
    intro hfactor
    have hstab :=
      token_matched_factor_forces_stability hw (show 0 < c by omega) (show 0 < n by omega)
        htau0 htau hfactor
    have hmono := kstar_mono_context hw htau (n := 2 * n) (m := c * n) (by omega)
      (Nat.mul_le_mul_right n hc2)
    omega

/-! ## 5.  The audited hypotheses are satisfiable

A refutation is only worth as much as the consistency of its hypotheses, so we exhibit
an explicit profile, gate and context realising the reported English pair `(16, 20)`
across a doubling — and doing so with *geometric* decay, the most favourable case.
Thus `net76_english_row_has_no_certificate` is not vacuous: the reported chain is
realisable, and it is the certificate, not the data, that fails. -/

/-- The dyadic geometric profile `2^{-i}`. -/
noncomputable def wGeo : ℕ → ℝ := fun i => (1 / 2 : ℝ) ^ i

/-- A gate at which the dyadic profile's knee rises from `16` at context `16` to `20`
at context `32`. -/
noncomputable def tauGeo : ℝ := (2 ^ 32 - 5000) / (2 ^ 32 - 1)

lemma wGeo_pos : ∀ i, 0 < wGeo i := fun i => by
  rw [wGeo]; positivity

lemma wGeo_decay : ∀ i, wGeo (i + 1) ≤ (1 / 2 : ℝ) * wGeo i := by
  intro i
  rw [wGeo, pow_succ]
  ring_nf
  exact le_rfl

lemma tauGeo_pos : 0 < tauGeo := by norm_num [tauGeo]

lemma tauGeo_le_one : tauGeo ≤ 1 := by
  rw [tauGeo, div_le_one (by norm_num)]
  norm_num

/-- **The rising witness.**  For the dyadic profile at gate `tauGeo` the knee is exactly
`16` at context `16` and exactly `20` at context `32`: a geometric profile whose budget
still moves across a doubling. -/
theorem rising_geometric_witness :
    kstar wGeo 16 tauGeo = 16 ∧ kstar wGeo (2 * 16) tauGeo = 20 := by
  constructor
  · have hfail : retained wGeo 16 15 < tauGeo := by
      norm_num [retained, headMass, wGeo, tauGeo, Finset.sum_range_succ]
    have hpass : tauGeo ≤ retained wGeo 16 16 := by
      rw [retained_self wGeo_pos (by norm_num)]
      exact tauGeo_le_one
    obtain ⟨h1, h2⟩ := knee_bracket wGeo_pos (n := 16) (by norm_num) tauGeo_le_one hfail hpass
    omega
  · have hfail : retained wGeo (2 * 16) 19 < tauGeo := by
      norm_num [retained, headMass, wGeo, tauGeo, Finset.sum_range_succ]
    have hpass : tauGeo ≤ retained wGeo (2 * 16) 20 := by
      norm_num [retained, headMass, wGeo, tauGeo, Finset.sum_range_succ]
    obtain ⟨h1, h2⟩ :=
      knee_bracket wGeo_pos (n := 2 * 16) (by norm_num) tauGeo_le_one hfail hpass
    omega

/-- **Non-vacuity of the audit.**  All hypotheses of
`net76_english_row_has_no_certificate` — positivity, geometric decay with a genuine
ratio `r < 1`, a gate in `(0, 1]`, and the reported knees `16` and `20` across a
doubling — are simultaneously satisfiable. -/
theorem english_row_hypotheses_satisfiable :
    ∃ (v : ℕ → ℝ) (s t : ℝ) (k : ℕ), (∀ i, 0 < v i) ∧ 0 < s ∧ s < 1 ∧
      (∀ i, v (i + 1) ≤ s * v i) ∧ 0 < t ∧ t ≤ 1 ∧ 1 ≤ k ∧
        kstar v k t = 16 ∧ kstar v (2 * k) t = 20 :=
  ⟨wGeo, 1 / 2, tauGeo, 16, wGeo_pos, by norm_num, by norm_num, wGeo_decay, tauGeo_pos,
    tauGeo_le_one, by norm_num, rising_geometric_witness.1, rising_geometric_witness.2⟩

end Catalog.Probability.NET76StabilityCertificate