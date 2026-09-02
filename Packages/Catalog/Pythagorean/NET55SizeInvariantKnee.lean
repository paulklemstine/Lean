import Mathlib
import Shared.AttentionBudgetKnee
import Shared.AttentionBudgetScaling
import Pythagorean.NET79GeometricRatioKnee

/-!
# NET-55 — THE-KNEE-IS-SIZE-INVARIANT: a formal theory of size-independent key budgets

The NET-55 round measured the lossless attention budget (the *knee* `k*`, the least
number of retained keys whose top-`k` truncation clears a `0.98` agreement gate) of
Qwen2.5-1.5B and compared it with the 0.5B model measured in earlier rounds:

```
ctx      full acc     k*(1.5B)     k*(0.5B)
512      0.4680       16           16
1024     0.5004       16           32   (grid floor: 16 was the smallest budget tried)
```

Tripling the parameter count did not raise the budget by a single key.  This file asks
the mathematical question behind that verdict: *which structural feature of a family of
attention profiles makes the knee independent of the model index?*  Working with the
`AttentionBudget` theory of `Catalog/Shared/AttentionBudgetKnee.lean` we prove:

* **Scale invariance** (`kstar_const_smul`, `knee_invariant_under_head_replication`).
  The knee is a functional of the *shape* of the sorted profile, not of its total mass:
  multiplying every attention weight by a positive constant — in particular replicating
  a head `m` times, the crudest model of "more parameters" — leaves `k*` literally
  unchanged, at every context length and every gate.
* **Envelope size-uniformity** (`sizeUniform_of_summable_envelope`).  If a whole family
  of models shares one summable upper envelope and a uniformly positive lead weight,
  then a single budget `K` clears the gate for *every* member at *every* context.  The
  budget is computed from the envelope alone: no dependence on the model index, the
  depth, or the parameter count.  This is the precise statement that a "~30-key budget
  covers every real model".
* **Rigidity** (`sizeUniform_uniform_concentration`).  Conversely, a size-uniform budget
  is not a soft statement: it forces a *uniform* mass-concentration bound
  `headMass (W s) n ≤ headMass (W s) K / τ` on every member of the family.
* **P1 refuted** (`net55_P1_refuted`).  "Bigger model ⇒ bigger budget" is false as a
  law: we exhibit two genuine profiles where the one with strictly greater total
  attention mass has a knee of `8` against the smaller model's `18` — a ten-key
  *decrease* under a capacity increase.
* **The flat chain is realizable** (`net55_flat_knee_chain`).  Cycle 2 refuted exact
  flatness in general (`exact_flatness_refuted`); here we show the measured pattern
  `k*(512) = k*(1024) = 16` is nevertheless attained exactly, by the geometric profile
  with ratio `39/50`.  So `{16, 16}` is consistent, but only as a statement about a
  particular profile class, never as a theorem about all profiles.

The technical tool that makes the `512`/`1024` computations feasible is
`kstar_geomProfile_eq_of_small_powers`: a pass certificate needs only `r ^ K ≤ 1 - τ`
(no context-dependent denominator) and a fail certificate at a *short* reference context
`m ≤ n` transfers upwards, because the retained fraction is antitone in the context.

-- !-- Lab Notes -- !--
Hypothesizer (NET-55 cycle, ranked by expected impact):
 (N1) The knee is invariant under every positive rescaling of the profile, hence
      parameter count *per se* can never move it.                            [BOLD]
 (N2) A family sharing one summable envelope and a uniform lead weight has one
      budget for all members and all contexts — size-invariance is an envelope
      phenomenon, not a capacity phenomenon.                                 [BOLD]
 (N3) Size-monotonicity of the knee (the pre-registered P1) is refutable by explicit
      profiles, not merely unsupported by the data.
 (N4) A size-uniform budget forces uniform concentration: the invariance is rigid.
 (N5) The measured flat chain `{16,16}` is exactly realizable by a geometric profile,
      so flatness is consistent even though it is not universal.

Experimenter: N1 = `kstar_const_smul`; N2 = `sizeUniform_of_summable_envelope`;
N3 = `net55_P1_refuted` (knees `8` and `18` computed exactly at ctx `64`, gate `0.98`);
N4 = `sizeUniform_uniform_concentration`; N5 = `net55_flat_knee_chain` (ratio `39/50`,
knee `16` at ctx `512` and `1024`).  All proved, zero sorries.

Analyst: the informative structure is that *two different mechanisms* can produce a
size-invariant knee, and they are separated here.  Exact invariance (N1) comes from
homogeneity of `retained` in the weights, and it is a group action: the knee is a class
function on the projective space of profiles.  Approximate invariance (N2) comes from a
shared tail envelope and is quantitative.  A measurement of `{16,16}` cannot distinguish
them; distinguishing them requires measuring the *shape* (the decay ratio), which is
exactly what the sub-16 addendum would do.

Critic: `net55_P1_refuted` is not a rescaling artefact in disguise — the two witnesses
have genuinely different decay ratios (`3/5` versus `4/5`), so the knee gap `8` versus
`18` survives any normalisation; the total-mass inequality is only the capacity proxy.
The hypothesis `0 < c` in `sizeUniform_of_summable_envelope` is load-bearing: with lead
weights tending to `0` the family's profiles flatten and no uniform budget exists.
-/

namespace PythKnee

open Finset AttentionBudget

/-! ## N1 — exact scale invariance of the knee -/

section Scaling

variable {w : ℕ → ℝ} {c : ℝ}

/-- Head mass is homogeneous of degree one in the weights. -/
lemma headMass_const_smul (c : ℝ) (w : ℕ → ℝ) (k : ℕ) :
    headMass (fun i => c * w i) k = c * headMass w k := by
  simp [headMass, Finset.mul_sum]

/-- **Retained mass is scale free.**  Rescaling every attention weight by a positive
constant does not change the fraction of mass a top-`k` truncation keeps. -/
theorem retained_const_smul (hc : 0 < c) (w : ℕ → ℝ) (n k : ℕ) :
    retained (fun i => c * w i) n k = retained w n k := by
  simp only [retained, headMass_const_smul]
  rw [mul_div_mul_left _ _ hc.ne']

/-- **N1 — the knee is scale invariant.**  Parameter count enters the attention profile
only through an overall normalisation of the weights, and the knee does not see it. -/
theorem kstar_const_smul (hc : 0 < c) (w : ℕ → ℝ) (n : ℕ) (τ : ℝ) :
    kstar (fun i => c * w i) n τ = kstar w n τ := by
  unfold kstar
  congr 1
  ext k
  simp [Set.mem_setOf_eq, retained_const_smul hc]

/-- **Head replication does not move the budget.**  Replacing a head by `m` identical
copies (the crudest model of "`m`× the parameters") leaves the knee unchanged at every
context length and every gate. -/
theorem knee_invariant_under_head_replication {m : ℕ} (hm : 0 < m) (w : ℕ → ℝ) (n : ℕ)
    (τ : ℝ) : kstar (fun i => (m : ℝ) * w i) n τ = kstar w n τ :=
  kstar_const_smul (by exact_mod_cast hm) w n τ

/-- The NET-55 headline as an exact theorem in the replication model: tripling the
model does not raise the budget by one key. -/
theorem tripling_the_model_keeps_the_knee (w : ℕ → ℝ) (n : ℕ) (τ : ℝ) :
    kstar (fun i => 3 * w i) n τ = kstar w n τ :=
  kstar_const_smul (by norm_num) w n τ

end Scaling

/-! ## N2 — a size-uniform budget from a shared summable envelope -/

/-- A family of models `W` indexed by `ι` (read: by parameter count) admits a
*size-uniform budget* at gate `τ` when one key budget clears the gate for every member
at every context length. -/
def SizeUniform {ι : Type*} (W : ι → ℕ → ℝ) (τ : ℝ) : Prop :=
  ∃ K : ℕ, ∀ s : ι, ∀ n : ℕ, 1 ≤ n → kstar (W s) n τ ≤ K

section Envelope

variable {ι : Type*} {W : ι → ℕ → ℝ} {v : ℕ → ℝ} {c τ : ℝ}

/-- The block of mass between budgets `k` and `n` is bounded by the envelope tail. -/
lemma block_le_envelope_tail (hpos : ∀ s i, 0 < W s i) (hdom : ∀ s i, W s i ≤ v i)
    (hsum : Summable v) (s : ι) (k n : ℕ) :
    headMass (W s) n - headMass (W s) k ≤ (∑' i, v i) - ∑ i ∈ range k, v i := by
  have hvpos : ∀ i, 0 ≤ v i := fun i => le_of_lt (lt_of_lt_of_le (hpos s i) (hdom s i))
  rcases le_or_gt n k with hnk | hkn
  · have h1 : headMass (W s) n ≤ headMass (W s) k :=
      headMass_mono (fun i => hpos s i) hnk
    have h2 : ∑ i ∈ range k, v i ≤ ∑' i, v i := hsum.sum_le_tsum _ (fun i _ => hvpos i)
    linarith
  · have hsplit : headMass (W s) n - headMass (W s) k = ∑ i ∈ Finset.Ico k n, W s i := by
      rw [Finset.sum_Ico_eq_sub _ hkn.le]; simp [headMass]
    have hb : ∑ i ∈ Finset.Ico k n, W s i ≤ ∑ i ∈ Finset.Ico k n, v i :=
      Finset.sum_le_sum fun i _ => hdom s i
    have hb2 : ∑ i ∈ Finset.Ico k n, v i = ∑ i ∈ range n, v i - ∑ i ∈ range k, v i := by
      rw [Finset.sum_Ico_eq_sub _ hkn.le]
    have hb3 : ∑ i ∈ range n, v i ≤ ∑' i, v i := hsum.sum_le_tsum _ (fun i _ => hvpos i)
    rw [hsplit]
    linarith
/-- **N2 — the envelope theorem.**  A family of attention profiles that shares one
summable upper envelope `v` and a uniformly positive lead weight `c` has a *single* key
budget serving every member of the family at every context length.  The budget is
computed from `v`, `c` and the gate alone: it is blind to the model index, hence to the
parameter count. -/
theorem sizeUniform_of_summable_envelope (hpos : ∀ s i, 0 < W s i)
    (hdom : ∀ s i, W s i ≤ v i) (hsum : Summable v) (hc : 0 < c) (hlead : ∀ s, c ≤ W s 0)
    (hτ : τ < 1) : SizeUniform W τ := by
  by_cases hne : Nonempty ι
  swap
  · exact ⟨0, fun s => absurd ⟨s⟩ hne⟩
  obtain ⟨s₀⟩ := hne
  have hvpos : ∀ i, 0 ≤ v i := fun i => le_of_lt (lt_of_lt_of_le (hpos s₀ i) (hdom s₀ i))
  have hε : 0 < (1 - τ) * c := mul_pos (by linarith) hc
  -- choose a budget whose envelope tail is smaller than `(1 - τ) * c`
  have htend : Filter.Tendsto (fun k => ∑ i ∈ range k, v i) Filter.atTop
      (nhds (∑' i, v i)) := hsum.hasSum.tendsto_sum_nat
  have : ∀ᶠ k in Filter.atTop, (∑' i, v i) - ∑ i ∈ range k, v i < (1 - τ) * c := by
    have := htend.eventually (eventually_gt_nhds (by linarith [hε] :
      (∑' i, v i) - (1 - τ) * c < ∑' i, v i))
    filter_upwards [this] with k hk
    linarith
  obtain ⟨K0, hK0⟩ := this.exists
  refine ⟨max K0 1, fun s n hn => ?_⟩
  set K := max K0 1 with hK
  have hKtail : (∑' i, v i) - ∑ i ∈ range K, v i < (1 - τ) * c := by
    have hmono : ∑ i ∈ range K0, v i ≤ ∑ i ∈ range K, v i :=
      Finset.sum_le_sum_of_subset_of_nonneg
        (Finset.range_subset_range.mpr (le_max_left _ _)) fun i _ _ => hvpos i
    linarith
  rcases le_or_gt n K with hnK | hKn
  · exact le_trans (kstar_le_context (fun i => hpos s i) hn (by linarith)) hnK
  · refine kstar_le_of_pass (n := n) (k := K) ?_
    have hden : 0 < headMass (W s) n := headMass_pos (fun i => hpos s i) hn
    have hlead' : c ≤ headMass (W s) K := by
      have h1 : headMass (W s) 1 ≤ headMass (W s) K :=
        headMass_mono (fun i => hpos s i) (le_max_right _ _)
      have : headMass (W s) 1 = W s 0 := by simp [headMass]
      linarith [hlead s]
    have hblock := block_le_envelope_tail hpos hdom hsum s K n
    have hmass : headMass (W s) n - headMass (W s) K < (1 - τ) * c := by linarith
    have hmin : min K n = K := min_eq_left hKn.le
    rw [retained, hmin, le_div_iff₀ hden]
    rcases le_or_gt τ 0 with hτ0 | hτ0
    · have : τ * headMass (W s) n ≤ 0 := mul_nonpos_of_nonpos_of_nonneg hτ0 hden.le
      linarith
    · have e1 : τ * (headMass (W s) n - headMass (W s) K) ≤ τ * ((1 - τ) * c) :=
        mul_le_mul_of_nonneg_left hmass.le hτ0.le
      have e2 : τ * ((1 - τ) * c) ≤ (1 - τ) * c := by nlinarith
      have e3 : (1 - τ) * c ≤ (1 - τ) * headMass (W s) K :=
        mul_le_mul_of_nonneg_left hlead' (by linarith)
      nlinarith

end Envelope

/-! ## N4 — rigidity: a size-uniform budget forces uniform concentration -/

/-- **N4.**  A size-uniform budget is a strong statement: every member of the family
concentrates a `τ`-fraction of the mass of *every* context inside its first `K` keys. -/
theorem sizeUniform_uniform_concentration {ι : Type*} {W : ι → ℕ → ℝ} {τ : ℝ}
    (hpos : ∀ s i, 0 < W s i) (hτ1 : τ ≤ 1) (h : SizeUniform W τ) :
    ∃ K : ℕ, ∀ (s : ι) (n : ℕ), 1 ≤ n → τ * headMass (W s) n ≤ headMass (W s) K := by
  obtain ⟨K, hK⟩ := h
  refine ⟨K, fun s n hn => ?_⟩
  have hpass : τ ≤ retained (W s) n (kstar (W s) n τ) :=
    gate_le_retained_kstar (fun i => hpos s i) hn hτ1
  have hden : 0 < headMass (W s) n := headMass_pos (fun i => hpos s i) hn
  rw [retained, le_div_iff₀ hden] at hpass
  have hmono : headMass (W s) (min (kstar (W s) n τ) n) ≤ headMass (W s) K :=
    headMass_mono (fun i => hpos s i) (le_trans (min_le_left _ _) (hK s n hn))
  linarith

/-! ## A context-cheap knee calculus for geometric profiles

Exact knee values at contexts `512` and `1024` would require evaluating `r ^ 1024` in
exact arithmetic.  The following two lemmas remove that cost: the *pass* certificate is
context free, and the *fail* certificate may be checked at any shorter reference
context. -/

section SmallPowers

variable {r τ : ℝ}

/-- Retained mass of a geometric profile is antitone in the context length, in the
quantitative form needed for fail certificates. -/
lemma retained_geomProfile_le_of_ctx_ge (hr0 : 0 < r) (hr1 : r < 1) {m n k : ℕ}
    (hm : 0 < m) (hmn : m ≤ n) (hkn : k ≤ n) :
    retained (geomProfile r) n k ≤ (1 - r ^ k) / (1 - r ^ m) := by
  have hn : 0 < n := lt_of_lt_of_le hm hmn
  have hrm : r ^ m < 1 := pow_lt_one₀ hr0.le hr1 (by omega)
  have hrn : r ^ n ≤ r ^ m := pow_le_pow_of_le_one hr0.le hr1.le hmn
  have hnum : 0 ≤ 1 - r ^ k := by
    have : r ^ k ≤ 1 := pow_le_one₀ hr0.le hr1.le
    linarith
  rw [retained_geomProfile_eq hr0 hr1 n k hn, min_eq_left hkn]
  exact div_le_div_of_nonneg_left hnum (by linarith) (by linarith)

/-- **Context-cheap exact knee.**  A pass certificate `r ^ K ≤ 1 - τ` (context free) and
a fail certificate checked at a short reference context `m ≤ n` pin the knee of a
geometric profile at context `n` to the value `K`. -/
theorem kstar_geomProfile_eq_of_small_powers (hr0 : 0 < r) (hr1 : r < 1) {m n K : ℕ}
    (hm : 0 < m) (hmn : m ≤ n) (hK1 : 1 ≤ K) (hKn : K ≤ n) (hτ : τ ≤ 1)
    (hpass : r ^ K ≤ 1 - τ) (hfail : (1 - r ^ (K - 1)) / (1 - r ^ m) < τ) :
    kstar (geomProfile r) n τ = K := by
  have hn : 0 < n := lt_of_lt_of_le hm hmn
  have hup : kstar (geomProfile r) n τ ≤ K :=
    kstar_geomProfile_le_of_pow_le hr0 hr1 hn hpass
  have hlow : K - 1 < kstar (geomProfile r) n τ := by
    refine lt_kstar_of_fail (geomProfile_pos hr0) hn hτ ?_
    exact lt_of_le_of_lt
      (retained_geomProfile_le_of_ctx_ge hr0 hr1 hm hmn (by omega : K - 1 ≤ n)) hfail
  omega

end SmallPowers

/-! ## N3 — the pre-registered size law P1 is refutable, not merely unsupported -/

/-- The knee of the `3/5` geometric profile at gate `0.98` is exactly `8`, at every
context length from `64` upwards. -/
theorem knee_three_fifths_98 {n : ℕ} (hn : 64 ≤ n) :
    kstar (geomProfile (3 / 5)) n (98 / 100) = 8 := by
  refine kstar_geomProfile_eq_of_small_powers (by norm_num) (by norm_num)
    (m := 64) (by norm_num) hn (by norm_num) (by omega) (by norm_num) (by norm_num) ?_
  rw [div_lt_iff₀ (by norm_num)]
  norm_num

/-- The knee of the `4/5` geometric profile at gate `0.98` is exactly `18`, at every
context length from `64` upwards. -/
theorem knee_four_fifths_98 {n : ℕ} (hn : 64 ≤ n) :
    kstar (geomProfile (4 / 5)) n (98 / 100) = 18 := by
  refine kstar_geomProfile_eq_of_small_powers (by norm_num) (by norm_num)
    (m := 64) (by norm_num) hn (by norm_num) (by omega) (by norm_num) (by norm_num) ?_
  rw [div_lt_iff₀ (by norm_num)]
  norm_num

/-- **N3 — P1 refuted.**  There are two attention profiles, the second carrying strictly
more total attention mass than the first at every context, whose knees at gate `0.98`
are `18` and `8`: a capacity increase accompanied by a ten-key *decrease* of the
lossless budget.  "The knee grows with model size" is therefore false as a law about
attention profiles, independently of any measurement. -/
theorem net55_P1_refuted :
    ∃ wSmall wLarge : ℕ → ℝ, (∀ i, 0 < wSmall i) ∧ (∀ i, 0 < wLarge i) ∧
      (∀ n : ℕ, 0 < n → headMass wSmall n < headMass wLarge n) ∧
      kstar wSmall 512 (98 / 100) = 18 ∧ kstar wLarge 512 (98 / 100) = 8 := by
  refine ⟨geomProfile (4 / 5), fun i => 10 * geomProfile (3 / 5) i,
    geomProfile_pos (by norm_num), fun i => by
      have := geomProfile_pos (r := 3 / 5) (by norm_num) i; linarith, ?_, ?_, ?_⟩
  · intro n hn
    have hs : headMass (geomProfile (4 / 5)) n = 5 * (1 - (4 / 5 : ℝ) ^ n) := by
      rw [headMass_geomProfile, geom_sum_eq (by norm_num)]; ring
    have hl : headMass (fun i => 10 * geomProfile (3 / 5) i) n
        = 25 * (1 - (3 / 5 : ℝ) ^ n) := by
      rw [headMass_const_smul, headMass_geomProfile, geom_sum_eq (by norm_num)]; ring
    have h1 : (0 : ℝ) < (4 / 5 : ℝ) ^ n := pow_pos (by norm_num) n
    have h2 : ((3 : ℝ) / 5) ^ n ≤ 3 / 5 := by
      calc ((3 : ℝ) / 5) ^ n ≤ (3 / 5 : ℝ) ^ 1 :=
            pow_le_pow_of_le_one (by norm_num) (by norm_num) hn
        _ = 3 / 5 := by norm_num
    rw [hs, hl]
    nlinarith
  · exact knee_four_fifths_98 (by norm_num)
  · exact (kstar_const_smul (by norm_num) _ _ _).trans (knee_three_fifths_98 (by norm_num))

/-! ## N5 — the measured flat chain `{16, 16}` is exactly realizable -/

/-- **N5.**  The geometric profile with decay ratio `39/50` has knee exactly `16` at
context `512` *and* at context `1024`, at the `0.98` gate: the measured NET-55 chain
`k*(512) = k*(1024) = 16` is realizable on the nose.  Combined with
`exact_flatness_refuted` (flatness is not automatic) this places the observation
precisely: it is a statement about the profile class, not a universal law. -/
theorem net55_flat_knee_chain :
    kstar (geomProfile (39 / 50)) 512 (98 / 100) = 16 ∧
      kstar (geomProfile (39 / 50)) 1024 (98 / 100) = 16 := by
  constructor <;>
  · refine kstar_geomProfile_eq_of_small_powers (by norm_num) (by norm_num)
      (m := 64) (by norm_num) (by norm_num) (by norm_num) (by norm_num) (by norm_num)
      (by norm_num) ?_
    rw [div_lt_iff₀ (by norm_num)]
    norm_num

end PythKnee