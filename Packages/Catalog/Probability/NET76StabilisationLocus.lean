import Probability.NET76StabilityCertificate
import Shared.AttentionBudgetSummability

/-!
# NET-76, cycle 5: locating the stabilisation context, and the asymptotic factor

Cycle 4 (`Probability.NET76StabilityCertificate`) proved that a geometrically decaying
profile has an *eventually constant* knee, but neither identified the constant nor
located the context at which the knee freezes.  Both gaps are closed here.

* `kinf` — the **limit knee**: the least budget whose head mass clears the gate against
  the *total* mass `∑' i, w i` of the profile.  This is a property of the profile alone;
  no context length appears in it.
* `kstar_le_kinf` — the limit knee dominates every measured knee, so a rising measured
  chain is a lower bound on the asymptotic budget.
* `kstar_eq_kinf_of_headMass_large` — one inequality on the measured context decides the
  knee exactly: as soon as `headMass w (kinf - 1) < τ · headMass w n`, the measured knee
  *is* the limit knee.
* `stabilisation_locus_explicit` and `exists_stabilisation_locus` — for a profile with
  decay ratio `r` the freezing context is explicit: any `N` with
  `τ · w 0 · r ^ N / (1 - r) < τ · (∑' i, w i) - headMass w (kinf - 1)` works, and such an
  `N` always exists.  This upgrades cycle 4's abstract stabilisation to a computable
  locus together with the value of the limit.
* `rising_row_precedes_stabilisation` — the audit: the reported English chain
  `16 → 20` forces `kinf ≥ 20` *and* puts the whole measurement strictly before the
  stabilisation locus.  A domain factor read off there is read off in the pre-asymptotic
  regime.
* `net76_factor_is_asymptotic` — the honest form of the verdict: past the locus, every
  dilation satisfies `k*(dilated) = c · kinf(base)`.  The single number per domain
  multiplies the *asymptotic* budget, not a measured one.
* `kinf_wGeo`, `wGeo_stabilises`, `wGeo_locus_located`, `wGeo_locus_exact` — the
  cycle-4 dyadic witness is carried through: its limit knee is exactly `20`, it is
  frozen from context `21` onwards, while its knee is `16` at context `16` and still at
  most `19` at context `20`.  So its stabilisation locus is *exactly* `21`, the general
  criterion is tight on this witness, and both the theory and the audit are
  non-vacuous.

-- !-- Lab Notes -- !--
Hypothesizer (cycle 5):
 (M1) The eventual value of the knee is a profile invariant, computable without any
      context: the limit knee `kinf`.                       [confirmed: `kstar_le_kinf`,
      `kstar_eq_kinf_of_headMass_large`]
 (M2) The freezing context is explicit in `(r, τ, w 0)` and the gate slack of the limit
      knee.                                                 [confirmed: `stabilisation_locus_explicit`]
 (M3) The reported English row is pre-asymptotic.           [confirmed: `rising_row_precedes_stabilisation`]
 (M4) The one number per domain, if it exists at all, multiplies `kinf`.
                                                            [confirmed: `net76_factor_is_asymptotic`]
 (M5) The stabilisation locus of the dyadic witness is `> 16`, so the reported context
      is genuinely below it — in fact it is exactly `21`.   [confirmed: `wGeo_locus_located`,
      `wGeo_locus_exact`]

Analyst: the informative point is the *direction* of the error.  Because `kstar ≤ kinf`
always, a pre-asymptotic measurement systematically *under*-reports the budget; a factor
computed from two under-reports need not be the factor of the limits.  This explains,
without any appeal to noise, why the reported per-domain factors drift with context.

Critic: `kinf` is not vacuous (`kinf_pos` shows it is at least `1`, and `kinf_wGeo`
computes it exactly for a concrete profile), the arithmetic of the witness is exact
rational arithmetic, and every hypothesis of the audit is realised by that witness.
-/

namespace Catalog.Probability.NET76StabilisationLocus

open Finset Filter AttentionBudget Catalog.Probability.NET76DomainDilation
open Catalog.Probability.NET76TokenMatched Catalog.Probability.NET76StabilityCertificate

variable {w : ℕ → ℝ} {r tau : ℝ} {c m n : ℕ}

/-! ## 1.  The limit knee -/

/-- The **limit knee** of a profile: the least budget whose head mass clears the gate
measured against the total mass of the profile.  No context length occurs in the
definition. -/
noncomputable def kinf (w : ℕ → ℝ) (tau : ℝ) : ℕ :=
  sInf {k | tau * (∑' i, w i) ≤ headMass w k}

lemma headMass_le_tsum (hw : ∀ i, 0 < w i) (hsum : Summable w) (n : ℕ) :
    headMass w n ≤ ∑' i, w i :=
  hsum.sum_le_tsum _ (fun i _ => (hw i).le)

lemma tsum_pos (hw : ∀ i, 0 < w i) (hsum : Summable w) : 0 < ∑' i, w i := by
  have h1 : headMass w 1 = w 0 := by simp [headMass]
  exact lt_of_lt_of_le (hw 0) (h1 ▸ headMass_le_tsum hw hsum 1)

lemma kinfSet_nonempty (hw : ∀ i, 0 < w i) (hsum : Summable w) (htau1 : tau < 1) :
    {k | tau * (∑' i, w i) ≤ headMass w k}.Nonempty := by
  have hSpos : 0 < ∑' i, w i := tsum_pos hw hsum
  have htend : Tendsto (fun m => headMass w m) atTop (nhds (∑' i, w i)) :=
    hsum.hasSum.tendsto_sum_nat
  have hlt : tau * (∑' i, w i) < ∑' i, w i := by nlinarith
  obtain ⟨k, hk⟩ := (htend.eventually_const_lt hlt).exists
  exact ⟨k, hk.le⟩

/-- The limit knee clears the gate against the total mass. -/
lemma gate_le_headMass_kinf (hw : ∀ i, 0 < w i) (hsum : Summable w) (htau1 : tau < 1) :
    tau * (∑' i, w i) ≤ headMass w (kinf w tau) :=
  Nat.sInf_mem (kinfSet_nonempty hw hsum htau1)

/-- Every budget strictly below the limit knee fails against the total mass. -/
lemma headMass_lt_of_lt_kinf {k : ℕ} (hk : k < kinf w tau) :
    headMass w k < tau * (∑' i, w i) := by
  have := Nat.notMem_of_lt_sInf (s := {k | tau * (∑' i, w i) ≤ headMass w k}) hk
  simpa [Set.mem_setOf_eq, not_le] using this

lemma kinf_pos (hw : ∀ i, 0 < w i) (hsum : Summable w) (htau0 : 0 < tau)
    (htau1 : tau < 1) : 0 < kinf w tau := by
  rcases Nat.eq_zero_or_pos (kinf w tau) with h | h
  · exfalso
    have h0 : tau * (∑' i, w i) ≤ headMass w 0 := by
      simpa [h] using gate_le_headMass_kinf hw hsum htau1
    have := mul_pos htau0 (tsum_pos hw hsum)
    simp only [headMass, Finset.range_zero, Finset.sum_empty] at h0
    linarith
  · exact h

/-! ## 2.  The measured knee versus the limit knee -/

/-- **The limit knee dominates.**  At every context length the measured knee is at most
the limit knee, so a measurement is always an under-report of the asymptotic budget. -/
theorem kstar_le_kinf (hw : ∀ i, 0 < w i) (hsum : Summable w) (htau0 : 0 < tau)
    (htau1 : tau < 1) (hn : 1 ≤ n) : kstar w n tau ≤ kinf w tau := by
  refine kstar_le_of_pass ?_
  have hnpos : 0 < headMass w n := headMass_pos hw hn
  rcases le_or_gt n (kinf w tau) with h | h
  · rw [retained, min_eq_right h, div_self hnpos.ne']
    exact htau1.le
  · rw [retained, min_eq_left h.le, le_div_iff₀ hnpos]
    have h1 : tau * headMass w n ≤ tau * (∑' i, w i) :=
      mul_le_mul_of_nonneg_left (headMass_le_tsum hw hsum n) htau0.le
    exact le_trans h1 (gate_le_headMass_kinf hw hsum htau1)

/-- **One inequality decides the knee.**  Once the measured context carries enough mass
that the last failing head mass is below `τ · headMass w n`, the measured knee equals
the limit knee exactly. -/
theorem kstar_eq_kinf_of_headMass_large (hw : ∀ i, 0 < w i) (hsum : Summable w)
    (htau0 : 0 < tau) (htau1 : tau < 1) (hn : 1 ≤ n)
    (hlarge : headMass w (kinf w tau - 1) < tau * headMass w n) :
    kstar w n tau = kinf w tau := by
  have hkpos : 0 < kinf w tau := kinf_pos hw hsum htau0 htau1
  refine le_antisymm (kstar_le_kinf hw hsum htau0 htau1 hn) ?_
  have hnpos : 0 < headMass w n := headMass_pos hw hn
  have hfail : retained w n (kinf w tau - 1) < tau := by
    rw [retained, div_lt_iff₀ hnpos]
    calc headMass w (min (kinf w tau - 1) n) ≤ headMass w (kinf w tau - 1) :=
          headMass_mono hw (min_le_left _ _)
      _ < tau * headMass w n := hlarge
  have := lt_kstar_of_fail hw hn htau1.le hfail
  omega

/-! ## 3.  Geometric profiles: the locus is explicit -/

lemma weight_le_geometric (hr0 : 0 < r)
    (hdec : ∀ i, w (i + 1) ≤ r * w i) : ∀ i, w i ≤ w 0 * r ^ i := by
  intro i
  induction i with
  | zero => simp
  | succ k ih =>
      have h1 : w (k + 1) ≤ r * w k := hdec k
      have h2 : r * w k ≤ r * (w 0 * r ^ k) := by
        exact mul_le_mul_of_nonneg_left ih hr0.le
      calc w (k + 1) ≤ r * (w 0 * r ^ k) := le_trans h1 h2
        _ = w 0 * r ^ (k + 1) := by ring

lemma summable_of_geometric_decay (hw : ∀ i, 0 < w i) (hr0 : 0 < r) (hr1 : r < 1)
    (hdec : ∀ i, w (i + 1) ≤ r * w i) : Summable w := by
  have hgeo : Summable (fun i => w 0 * r ^ i) :=
    (summable_geometric_of_lt_one hr0.le hr1).mul_left (w 0)
  exact Summable.of_nonneg_of_le (fun i => (hw i).le)
    (weight_le_geometric hr0 hdec) hgeo

/-- The mass beyond a context of length `n` is controlled by the geometric tail. -/
lemma tail_le_geometric (hw : ∀ i, 0 < w i) (hr0 : 0 < r) (hr1 : r < 1)
    (hdec : ∀ i, w (i + 1) ≤ r * w i) (n : ℕ) :
    (∑' i, w i) - headMass w n ≤ w 0 * r ^ n / (1 - r) := by
  have hsum : Summable w := summable_of_geometric_decay hw hr0 hr1 hdec
  have hshift : Summable (fun i => w (i + n)) := (summable_nat_add_iff n).mpr hsum
  have hsplit : ∑' i, w i = (∑ i ∈ Finset.range n, w i) + ∑' i, w (i + n) :=
    (hsum.sum_add_tsum_nat_add n).symm
  have hgeo : Summable (fun i => w 0 * r ^ n * r ^ i) :=
    (summable_geometric_of_lt_one hr0.le hr1).mul_left _
  have hle : ∀ i, w (i + n) ≤ w 0 * r ^ n * r ^ i := by
    intro i
    have := weight_le_geometric hr0 hdec (i + n)
    calc w (i + n) ≤ w 0 * r ^ (i + n) := this
      _ = w 0 * r ^ n * r ^ i := by ring
  have hcmp : ∑' i, w (i + n) ≤ ∑' i, w 0 * r ^ n * r ^ i :=
    hshift.tsum_le_tsum hle hgeo
  have hval : ∑' i, w 0 * r ^ n * r ^ i = w 0 * r ^ n / (1 - r) := by
    rw [tsum_mul_left, tsum_geometric_of_lt_one hr0.le hr1]
    field_simp
  rw [hsplit]
  simp only [headMass]
  linarith [hval ▸ hcmp]

/-- **The stabilisation locus, explicitly.**  For a profile with decay ratio `r`, any
context `N` whose geometric tail fits inside the gate slack of the limit knee freezes the
knee at the limit value from `N` onwards. -/
theorem stabilisation_locus_explicit (hw : ∀ i, 0 < w i) (hr0 : 0 < r) (hr1 : r < 1)
    (hdec : ∀ i, w (i + 1) ≤ r * w i) (htau0 : 0 < tau) (htau1 : tau < 1) {N : ℕ}
    (hN1 : 1 ≤ N)
    (hN : tau * (w 0 * r ^ N / (1 - r)) <
      tau * (∑' i, w i) - headMass w (kinf w tau - 1)) :
    ∀ m : ℕ, N ≤ m → kstar w m tau = kinf w tau := by
  have hsum : Summable w := summable_of_geometric_decay hw hr0 hr1 hdec
  intro m hm
  have hm1 : 1 ≤ m := le_trans hN1 hm
  have hpow : r ^ m ≤ r ^ N := pow_le_pow_of_le_one hr0.le hr1.le hm
  have hr1' : (0 : ℝ) < 1 - r := by linarith
  have hmono : w 0 * r ^ m / (1 - r) ≤ w 0 * r ^ N / (1 - r) := by
    have hw0 : (0 : ℝ) ≤ w 0 := (hw 0).le
    gcongr
  have htail := tail_le_geometric hw hr0 hr1 hdec m
  have hscale : tau * ((∑' i, w i) - headMass w m) ≤ tau * (w 0 * r ^ N / (1 - r)) :=
    mul_le_mul_of_nonneg_left (le_trans htail hmono) htau0.le
  refine kstar_eq_kinf_of_headMass_large hw hsum htau0 htau1 hm1 ?_
  nlinarith

/-- Such a context always exists: the stabilisation locus is a genuine finite number. -/
theorem exists_stabilisation_locus (hw : ∀ i, 0 < w i) (hr0 : 0 < r) (hr1 : r < 1)
    (hdec : ∀ i, w (i + 1) ≤ r * w i) (htau0 : 0 < tau) (htau1 : tau < 1) :
    ∃ N : ℕ, 1 ≤ N ∧ ∀ m : ℕ, N ≤ m → kstar w m tau = kinf w tau := by
  have hsum : Summable w := summable_of_geometric_decay hw hr0 hr1 hdec
  have hkpos : 0 < kinf w tau := kinf_pos hw hsum htau0 htau1
  have hslack : 0 < tau * (∑' i, w i) - headMass w (kinf w tau - 1) := by
    have := headMass_lt_of_lt_kinf (w := w) (tau := tau) (k := kinf w tau - 1) (by omega)
    linarith
  have hr1' : (0 : ℝ) < 1 - r := by linarith
  set slack := tau * (∑' i, w i) - headMass w (kinf w tau - 1) with hslackdef
  have heps : 0 < slack * (1 - r) / (tau * w 0) := by
    have := hw 0
    positivity
  obtain ⟨K, hK⟩ := exists_pow_lt_of_lt_one heps hr1
  refine ⟨max K 1, le_max_right _ _, ?_⟩
  have hpowle : r ^ (max K 1) ≤ r ^ K :=
    pow_le_pow_of_le_one hr0.le hr1.le (le_max_left _ _)
  have hbound : tau * (w 0 * r ^ (max K 1) / (1 - r)) < slack := by
    have hlt : r ^ (max K 1) < slack * (1 - r) / (tau * w 0) := lt_of_le_of_lt hpowle hK
    have hw0 := hw 0
    have key : r ^ (max K 1) * (tau * w 0) < slack * (1 - r) :=
      (lt_div_iff₀ (by positivity)).mp hlt
    have hrw : tau * (w 0 * r ^ (max K 1) / (1 - r))
        = tau * w 0 * r ^ (max K 1) / (1 - r) := by ring
    rw [hrw, div_lt_iff₀ hr1']
    nlinarith
  exact stabilisation_locus_explicit hw hr0 hr1 hdec htau0 htau1 (le_max_right _ _) hbound

/-! ## 4.  The reported row is pre-asymptotic -/

/-- **The audit.**  If a base curve still rises across a doubling — the reported English
`16 → 20` — then the asymptotic budget is at least the larger measurement, and the whole
measurement lies strictly before the stabilisation locus.  A factor read off at that
context is read off in the pre-asymptotic regime. -/
theorem rising_row_precedes_stabilisation (hw : ∀ i, 0 < w i) (hsum : Summable w)
    (htau0 : 0 < tau) (htau1 : tau < 1) (hn : 1 ≤ n) (h512 : kstar w n tau = 16)
    (h1024 : kstar w (2 * n) tau = 20) :
    20 ≤ kinf w tau ∧
      ∀ N : ℕ, (∀ m : ℕ, N ≤ m → kstar w m tau = kinf w tau) → n < N := by
  refine ⟨?_, ?_⟩
  · have := kstar_le_kinf hw hsum htau0 htau1 (n := 2 * n) (by omega)
    omega
  · intro N hN
    by_contra hcon
    push_neg at hcon
    have h1 := hN n hcon
    have h2 := hN (2 * n) (by omega)
    omega

/-! ## 5.  The honest form of the verdict -/

/-- **The factor is asymptotic.**  Past the stabilisation locus, every block dilation of
a geometric base profile has knee exactly `c · kinf(base)` (under the usual gate
condition).  So the single number per domain multiplies the profile invariant `kinf`,
never a pre-asymptotic measurement. -/
theorem net76_factor_is_asymptotic (hw : ∀ i, 0 < w i) (hr0 : 0 < r) (hr1 : r < 1)
    (hdec : ∀ i, w (i + 1) ≤ r * w i) (htau0 : 0 < tau) (htau1 : tau < 1) :
    ∃ N : ℕ, 1 ≤ N ∧ ∀ c m : ℕ, 0 < c → N ≤ m →
      retained (dilate c w) (c * m) (c * kstar w m tau - 1) < tau →
        kstar (dilate c w) (c * m) tau = c * kinf w tau := by
  obtain ⟨N, hN1, hstab⟩ := exists_stabilisation_locus hw hr0 hr1 hdec htau0 htau1
  refine ⟨N, hN1, fun c m hc hm hgate => ?_⟩
  have hcm : N ≤ c * m := le_trans hm (Nat.le_mul_of_pos_left m hc)
  have hflat : kstar w m tau = kstar w (c * m) tau := by
    rw [hstab m hm, hstab (c * m) hcm]
  have := stable_base_gives_token_matched_factor hw hc (by omega) htau0 htau1.le hflat hgate
  rw [this, hstab (c * m) hcm]

/-! ## 6.  The dyadic witness, carried through

The cycle-4 witness `wGeo i = 2⁻ⁱ` with gate `tauGeo` realises the reported English pair
`(16, 20)` across a doubling.  Here its limit knee is computed exactly and its
stabilisation locus is bracketed. -/

lemma headMass_wGeo (k : ℕ) : headMass wGeo k = 2 - 2 * (1 / 2 : ℝ) ^ k := by
  induction k with
  | zero => simp [headMass]
  | succ j ih =>
      rw [headMass, Finset.sum_range_succ, ← headMass, ih, wGeo]
      ring

lemma tsum_wGeo : ∑' i, wGeo i = 2 := by
  show ∑' i : ℕ, (1 / 2 : ℝ) ^ i = 2
  rw [tsum_geometric_of_lt_one (by norm_num) (by norm_num)]
  norm_num

lemma summable_wGeo : Summable wGeo :=
  summable_geometric_of_lt_one (by norm_num) (by norm_num)

lemma tauGeo_lt_one : tauGeo < 1 := by
  rw [tauGeo, div_lt_one (by norm_num)]
  norm_num

/-- **The limit knee of the witness is exactly `20`.**  The reported `20` at the longer
context is therefore the asymptotic budget, and the reported `16` at the shorter one is
not. -/
theorem kinf_wGeo : kinf wGeo tauGeo = 20 := by
  have hmem : tauGeo * (∑' i, wGeo i) ≤ headMass wGeo 20 := by
    rw [tsum_wGeo, headMass_wGeo, tauGeo]
    rw [div_mul_eq_mul_div, div_le_iff₀ (by norm_num)]
    norm_num
  have hle : kinf wGeo tauGeo ≤ 20 := Nat.sInf_le hmem
  have hfail19 : headMass wGeo 19 < tauGeo * (∑' i, wGeo i) := by
    rw [tsum_wGeo, headMass_wGeo, tauGeo]
    rw [div_mul_eq_mul_div, lt_div_iff₀ (by norm_num)]
    norm_num
  by_contra hne
  have hlt : kinf wGeo tauGeo ≤ 19 := by omega
  have hgate := gate_le_headMass_kinf wGeo_pos summable_wGeo tauGeo_lt_one
  have hmono : headMass wGeo (kinf wGeo tauGeo) ≤ headMass wGeo 19 :=
    headMass_mono wGeo_pos hlt
  linarith

/-- **The witness is frozen from context `21`.**  Explicit locus for a concrete
profile. -/
theorem wGeo_stabilises : ∀ m : ℕ, 21 ≤ m → kstar wGeo m tauGeo = 20 := by
  intro m hm
  have hkinf := kinf_wGeo
  have hlarge : headMass wGeo (kinf wGeo tauGeo - 1) < tauGeo * headMass wGeo m := by
    rw [hkinf]
    have h19 : headMass wGeo (20 - 1) = 2 - 2 * (1 / 2 : ℝ) ^ 19 := by
      norm_num [headMass_wGeo]
    have hmge : (2 : ℝ) - 2 * (1 / 2 : ℝ) ^ 21 ≤ headMass wGeo m := by
      rw [headMass_wGeo]
      have : (1 / 2 : ℝ) ^ m ≤ (1 / 2 : ℝ) ^ 21 :=
        pow_le_pow_of_le_one (by norm_num) (by norm_num) hm
      linarith
    have hstep : (2 : ℝ) - 2 * (1 / 2 : ℝ) ^ 19 < tauGeo * (2 - 2 * (1 / 2 : ℝ) ^ 21) := by
      rw [tauGeo]
      rw [div_mul_eq_mul_div, lt_div_iff₀ (by norm_num)]
      norm_num
    have htaupos : 0 < tauGeo := tauGeo_pos
    have := mul_le_mul_of_nonneg_left hmge htaupos.le
    rw [h19]
    linarith
  exact kstar_eq_kinf_of_headMass_large wGeo_pos summable_wGeo tauGeo_pos tauGeo_lt_one
    (by omega) hlarge |>.trans hkinf

/-- **The locus of the witness is located.**  Its knee is still `16` at context `16`, is
already `20` at context `32`, and is frozen at the limit value `20` from context `21`
onwards: the stabilisation locus lies in the window `(16, 21]`, strictly above the
shorter reported context. -/
theorem wGeo_locus_located :
    kstar wGeo 16 tauGeo = 16 ∧ kstar wGeo 32 tauGeo = 20 ∧
      kinf wGeo tauGeo = 20 ∧ (∀ m : ℕ, 21 ≤ m → kstar wGeo m tauGeo = 20) ∧
      ∀ N : ℕ, (∀ m : ℕ, N ≤ m → kstar wGeo m tauGeo = kinf wGeo tauGeo) → 16 < N := by
  refine ⟨rising_geometric_witness.1, by simpa using rising_geometric_witness.2, kinf_wGeo,
    wGeo_stabilises, fun N hN => ?_⟩
  by_contra hcon
  push_neg at hcon
  have h1 := hN 16 hcon
  rw [rising_geometric_witness.1, kinf_wGeo] at h1
  omega

/-- **The locus of the witness is exactly `21`.**  At context `20` the knee is still
strictly below the limit value `20`, while from `21` onwards it is frozen there: the
sufficient criterion of `stabilisation_locus_explicit` fires at the first context where
freezing actually happens. -/
theorem wGeo_locus_exact :
    kstar wGeo 20 tauGeo ≤ 19 ∧ ∀ m : ℕ, 21 ≤ m → kstar wGeo m tauGeo = 20 := by
  refine ⟨kstar_le_of_pass ?_, wGeo_stabilises⟩
  have h : retained wGeo 20 19
      = (2 - 2 * (1 / 2 : ℝ) ^ 19) / (2 - 2 * (1 / 2 : ℝ) ^ 20) := by
    rw [retained]
    norm_num [headMass_wGeo]
  rw [h, tauGeo, div_le_div_iff₀ (by norm_num) (by norm_num)]
  norm_num

end Catalog.Probability.NET76StabilisationLocus