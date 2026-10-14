import Geometry.AGL8Channel.SemiprimeChannel
import Cryptography.NonabelianTypeChannel.Fields

/-!
# The detector law: why the largest abelianization leaks the least

`AGL(1,8)` has the largest abelianization of the catalog (`C₇`) and the smallest channel.
This file proves the structural reason, for *every* finite group.

Call a splitting-type readout `T` a **trivial-coset detector** if one type value `τ₀` occurs
exactly on the non-trivial cosets of `[G,G]`: `T g = τ₀ ↔ g ∉ [G,G]`.  (All the
information `T` carries beyond that lives *inside* the trivial coset, where it is useless
for the residue.)  Then:

* `detector_law` / `group_detector_law` — **the channel is a binary entropy**:
  `I(coset ; T) = log₂ n - ((n-1)/n) log₂ (n-1) = h(1/n)` with `n = |G^ab|`, *whatever* else
  `T` does.  (`detectorInfo_eq_binEntropy`.)
* `detectorInfo_strictAnti` — **anti-monotonicity**: among detector channels, a strictly
  larger abelianization gives a strictly *smaller* channel.
* `detectorInfo_tendsto_zero`, `detectorInfo_le` — the channel vanishes,
  `I ≤ (log₂ n + 3)/n`, even though the cap `log₂ n` diverges; `detector_fraction_tendsto_zero`
  — the realised fraction of the cap tends to `0`.

Instances (the affine Frobenius groups `AGL(1,2ᵏ)` with `2ᵏ - 1` prime are all detectors,
because every non-trivial multiplier has the same order `2ᵏ - 1`):

* `agl8_isDetector`, `agl8_channel_via_law` — `AGL(1,8)`, `n = 7`: the law reproduces the
  value `log₂ 7 - (6/7) log₂ 6` computed by brute force in `PrimeChannel`.
* `A4_isDetector`, `A4_channel_via_law` — `A₄ = AGL(1,4)`, `n = 3`: the law reproduces the
  catalog's `TypeChannel.A4_channel = log₂ 3 - 2/3`.
* `agl8_below_A4` — consequently `AGL(1,8)` leaks strictly less than `A₄`, *derived from
  the law* (not from numerics).
-/

namespace AGL8

open Finset Real TypeChannel Filter Topology

/-! ## 1. The detector value -/

/-- The detector value `δ(n) = log₂ n - ((n-1)/n) log₂ (n-1)`, in bits. -/
noncomputable def detectorInfo (n : ℕ) : ℝ :=
  logb 2 n - ((n : ℝ) - 1) / n * logb 2 ((n : ℝ) - 1)

/-- `δ(n)` is the binary entropy of `1/n`, converted to bits. -/
theorem detectorInfo_eq_binEntropy {n : ℕ} (hn : 2 ≤ n) :
    detectorInfo n = Real.binEntropy (1 / n) / Real.log 2 := by
  have hn' : (2 : ℝ) ≤ n := by exact_mod_cast hn
  have hpos : (0 : ℝ) < n := by linarith
  have hm : (0 : ℝ) < (n : ℝ) - 1 := by linarith
  unfold detectorInfo Real.binEntropy
  have h1 : (1 : ℝ) - 1 / n = ((n : ℝ) - 1) / n := by field_simp
  rw [h1, one_div, inv_inv, inv_div, Real.log_div hpos.ne' hm.ne', logb, logb]
  field_simp
  ring

/-! ## 2. The detector law for an arbitrary finite channel -/

section Law

variable {Ω κ τ : Type*} [DecidableEq κ] [DecidableEq τ]

/-- **THE DETECTOR LAW (abstract form).**  Let `c` be a balanced readout (every one of its
`n ≥ 2` values has the same number `k` of preimages in `S`), and let `T` be a readout which
takes a value `τ₀` exactly off the fibre of `c₁`.  Then, however `T` behaves on that fibre,

  `I(c ; T) = log₂ n - ((n-1)/n) log₂ (n-1)`. -/
theorem detector_law {S : Finset Ω} {c : Ω → κ} {T : Ω → τ} {k : ℕ} (hk : 0 < k)
    (hunif : ∀ a ∈ S.image c, (fiber S c a).card = k) {c₁ : κ} (hc₁ : c₁ ∈ S.image c)
    {τ₀ : τ} (hT : ∀ w ∈ S, T w = τ₀ ↔ c w ≠ c₁) (hn : 2 ≤ (S.image c).card) :
    mutualInfo S c T = detectorInfo (S.image c).card := by
  set n := (S.image c).card with hn_def
  obtain ⟨w₀, hw₀, -⟩ := mem_image.mp hc₁
  have hSne : S.Nonempty := ⟨w₀, hw₀⟩
  -- Lagrange: `|S| = k n`.
  have hScard : S.card = k * n := by
    have h0 := Finset.card_eq_sum_card_image c S
    have h1 : ∀ b ∈ S.image c, (S.filter (fun a => c a = b)).card = k := fun b hb => hunif b hb
    rw [h0, Finset.sum_congr rfl h1, Finset.sum_const, smul_eq_mul, mul_comm]
  have hn2 : (2 : ℝ) ≤ n := by exact_mod_cast hn
  have hkR : (0 : ℝ) < k := by exact_mod_cast hk
  have hSR : (S.card : ℝ) = k * n := by rw [hScard]; push_cast; ring
  -- `H(c) = log₂ n`.
  have hHc : entropy S c = logb 2 n := entropy_eq_logb_card_of_uniform_fibers hSne hk hunif
  -- The types occurring on the trivial fibre.
  set B := (S.filter (fun w => c w = c₁)).image T with hB
  have hτB : τ₀ ∉ B := by
    intro h
    obtain ⟨w, hw, hwt⟩ := mem_image.mp h
    rw [mem_filter] at hw
    exact ((hT w hw.1).mp hwt) hw.2
  have hBne : ∀ t ∈ B, t ≠ τ₀ := fun t ht h => hτB (h ▸ ht)
  -- `H(T)` splits off the detector value.
  have hTsub : S.image T ⊆ insert τ₀ B := by
    intro t ht
    obtain ⟨w, hw, rfl⟩ := mem_image.mp ht
    by_cases hcw : c w = c₁
    · exact mem_insert_of_mem (mem_image.mpr ⟨w, mem_filter.mpr ⟨hw, hcw⟩, rfl⟩)
    · rw [(hT w hw).mpr hcw]; exact mem_insert_self _ _
  have hfibτ : (fiber S T τ₀).card = k * n - k := by
    have hf : fiber S T τ₀ = S.filter (fun w => ¬ c w = c₁) := by
      unfold fiber
      exact Finset.filter_congr (fun w hw => hT w hw)
    have hsplit := Finset.card_filter_add_card_filter_not (s := S) (fun w => c w = c₁)
    have hk1 : (S.filter (fun w => c w = c₁)).card = k := hunif c₁ hc₁
    rw [hf]; omega
  have hpτ : prob S T τ₀ = ((n : ℝ) - 1) / n := by
    unfold prob
    rw [hfibτ, hSR]
    have hle : k ≤ k * n := Nat.le_mul_of_pos_right k (by omega)
    rw [Nat.cast_sub hle]; push_cast
    field_simp
  have hHT : entropy S T = -(prob S T τ₀ * logb 2 (prob S T τ₀)) +
      ∑ t ∈ B, -(prob S T t * logb 2 (prob S T t)) := by
    rw [entropy_eq_sum_of_subset hTsub, sum_insert hτB]
  -- `H(c, T)` splits into the trivial fibre and the merged non-trivial cosets.
  set E := (S.image c).erase c₁ with hE
  have hpairsub : S.image (pairObs c T) ⊆
      B.image (fun t => (c₁, t)) ∪ E.image (fun a => (a, τ₀)) := by
    intro x hx
    obtain ⟨w, hw, rfl⟩ := mem_image.mp hx
    by_cases hcw : c w = c₁
    · refine mem_union_left _ (mem_image.mpr ⟨T w, mem_image.mpr ⟨w, mem_filter.mpr ⟨hw, hcw⟩,
        rfl⟩, ?_⟩)
      simp [pairObs, hcw]
    · refine mem_union_right _ (mem_image.mpr ⟨c w, mem_erase.mpr ⟨hcw, mem_image_of_mem c hw⟩,
        ?_⟩)
      simp [pairObs, (hT w hw).mpr hcw]
  have hdisj : Disjoint (B.image (fun t => (c₁, t))) (E.image (fun a => (a, τ₀))) := by
    rw [Finset.disjoint_left]
    intro x hx1 hx2
    obtain ⟨t, ht, rfl⟩ := mem_image.mp hx1
    obtain ⟨a, _, ha⟩ := mem_image.mp hx2
    simp only [Prod.mk.injEq] at ha
    exact hBne t ht ha.2.symm
  have hpair_triv : ∀ t ∈ B, prob S (pairObs c T) (c₁, t) = prob S T t := by
    intro t ht
    unfold prob fiber pairObs
    congr 3
    refine Finset.filter_congr (fun w hw => ?_)
    simp only [Prod.mk.injEq]
    constructor
    · exact fun h => h.2
    · intro h
      refine ⟨?_, h⟩
      by_contra hcw
      exact hBne t ht (h ▸ (hT w hw).mpr hcw)
  have hpair_E : ∀ a ∈ E, prob S (pairObs c T) (a, τ₀) = 1 / n := by
    intro a ha
    obtain ⟨hac, haS⟩ := mem_erase.mp ha
    have hf : fiber S (pairObs c T) (a, τ₀) = fiber S c a := by
      unfold fiber pairObs
      refine Finset.filter_congr (fun w hw => ?_)
      simp only [Prod.mk.injEq]
      constructor
      · exact fun h => h.1
      · intro h
        exact ⟨h, (hT w hw).mpr (h ▸ hac)⟩
    unfold prob
    rw [hf, hunif a haS, hSR]
    field_simp
  have hEcard : E.card = n - 1 := by rw [hE, card_erase_of_mem hc₁]
  have hHcT : entropy S (pairObs c T) =
      ∑ t ∈ B, -(prob S T t * logb 2 (prob S T t)) + ((n : ℝ) - 1) * (1 / n * logb 2 n) := by
    rw [entropy_eq_sum_of_subset hpairsub, sum_union hdisj,
      sum_image (s := B) (g := fun t => (c₁, t)) (fun t _ t' _ h => by simpa using h),
      sum_image (s := E) (g := fun a => (a, τ₀)) (fun a _ a' _ h => by simpa using h)]
    rw [sum_congr (s₁ := B) rfl (fun t ht => by rw [hpair_triv t ht]),
      sum_congr (s₁ := E) rfl (fun a ha => by rw [hpair_E a ha]), sum_const (s := E), hEcard,
      nsmul_eq_mul]
    have hn1 : ((n - 1 : ℕ) : ℝ) = (n : ℝ) - 1 := by
      rw [Nat.cast_sub (by omega)]; push_cast; ring
    rw [hn1, one_div, logb_inv]
    ring
  -- Assemble.
  rw [mutualInfo, hHc, hHT, hHcT, hpτ, detectorInfo]
  have hm : (0 : ℝ) < (n : ℝ) - 1 := by linarith
  have hnpos : (0 : ℝ) < n := by linarith
  rw [logb_div hm.ne' hnpos.ne']
  field_simp
  ring

end Law

/-- **THE DETECTOR LAW (group form).**  If the splitting-type readout of a finite group takes
one value `τ₀` exactly on the complement of the derived subgroup, the type channel is the
binary entropy `h(1/n)` of the event "trivial coset", `n = [G : G']`. -/
theorem group_detector_law {G : Type*} [Group G] [DecidableEq G] {κ τ : Type*}
    [DecidableEq κ] [DecidableEq τ] {S N : Finset G} {c : G → κ} {T : G → τ}
    (hS : IsSubgroupFinset S) (hN : IsSubgroupFinset N) (hNS : N ⊆ S)
    (hc : IsCosetReadout S N c) {τ₀ : τ} (hT : ∀ g ∈ S, T g = τ₀ ↔ g ∉ N)
    (hn : 2 ≤ (S.image c).card) :
    mutualInfo S c T = detectorInfo (S.image c).card := by
  refine detector_law (k := N.card) (card_pos.mpr ⟨1, hN.one_mem⟩) ?_
    (mem_image_of_mem c hS.one_mem) (τ₀ := τ₀) ?_ hn
  · intro a ha
    obtain ⟨g, hg, rfl⟩ := mem_image.mp ha
    exact card_fiber_cosetReadout hS hNS hc hg
  · intro g hg
    rw [hT g hg, Ne, hc g hg 1 hS.one_mem, inv_one, mul_one]

/-! ## 3. Anti-monotonicity and vanishing -/

/-- **Anti-monotonicity.**  For detector channels, a strictly larger abelianization gives a
strictly smaller channel: `2 ≤ n < m ⟹ δ(m) < δ(n)`. -/
theorem detectorInfo_strictAnti {n m : ℕ} (hn : 2 ≤ n) (hnm : n < m) :
    detectorInfo m < detectorInfo n := by
  rw [detectorInfo_eq_binEntropy hn, detectorInfo_eq_binEntropy (by omega)]
  have hl : 0 < Real.log 2 := Real.log_pos (by norm_num)
  rw [div_lt_div_iff_of_pos_right hl]
  have hn' : (2 : ℝ) ≤ n := by exact_mod_cast hn
  have hm' : (n : ℝ) < m := by exact_mod_cast hnm
  apply Real.binEntropy_strictMonoOn
  · constructor
    · positivity
    · rw [one_div]; exact inv_anti₀ (by norm_num) (by linarith)
  · constructor
    · positivity
    · rw [one_div]; exact inv_anti₀ (by norm_num) hn'
  · exact one_div_lt_one_div_of_lt (by linarith) hm'

/-- **Vanishing.**  `δ(n) → 0`: detector channels of growing abelianization leak nothing in
the limit. -/
theorem detectorInfo_tendsto_zero :
    Tendsto (fun n : ℕ => detectorInfo n) atTop (𝓝 0) := by
  have h1 : Tendsto (fun n : ℕ => Real.binEntropy (1 / (n : ℝ)) / Real.log 2) atTop
      (𝓝 (Real.binEntropy 0 / Real.log 2)) :=
    ((Real.binEntropy_continuous.tendsto 0).comp tendsto_one_div_atTop_nhds_zero_nat).div_const _
  rw [Real.binEntropy_zero, zero_div] at h1
  refine h1.congr' ?_
  filter_upwards [eventually_ge_atTop 2] with n hn
  exact (detectorInfo_eq_binEntropy hn).symm

/-- **Explicit rate.**  `δ(n) ≤ (log₂ n + 3)/n` for `n ≥ 2`. -/
theorem detectorInfo_le {n : ℕ} (hn : 2 ≤ n) :
    detectorInfo n ≤ (logb 2 n + 3) / n := by
  have hn' : (2 : ℝ) ≤ n := by exact_mod_cast hn
  have hpos : (0 : ℝ) < n := by linarith
  have hm : (0 : ℝ) < (n : ℝ) - 1 := by linarith
  have hl : (0.6931471803 : ℝ) < Real.log 2 := Real.log_two_gt_d9
  have hl0 : 0 < Real.log 2 := by linarith
  -- `log (n/(n-1)) ≤ 1/(n-1)`.
  have hlog : Real.log ((n : ℝ) / ((n : ℝ) - 1)) ≤ 1 / ((n : ℝ) - 1) := by
    have := Real.log_le_sub_one_of_pos (div_pos hpos hm)
    have he : (n : ℝ) / ((n : ℝ) - 1) - 1 = 1 / ((n : ℝ) - 1) := by field_simp; ring
    linarith
  have hsplit : detectorInfo n =
      (1 / n) * logb 2 ((n : ℝ) - 1) + Real.log ((n : ℝ) / ((n : ℝ) - 1)) / Real.log 2 := by
    unfold detectorInfo
    rw [Real.log_div hpos.ne' hm.ne', logb, logb]
    field_simp
    ring
  have hmono : logb 2 ((n : ℝ) - 1) ≤ logb 2 n :=
    Real.logb_le_logb_of_le (by norm_num) hm (by linarith)
  have hfrac : 1 / ((n : ℝ) - 1) / Real.log 2 ≤ 3 / n := by
    rw [div_div, div_le_div_iff₀ (by positivity) hpos]
    nlinarith
  rw [hsplit]
  calc (1 / n) * logb 2 ((n : ℝ) - 1) + Real.log ((n : ℝ) / ((n : ℝ) - 1)) / Real.log 2
      ≤ (1 / n) * logb 2 n + 1 / ((n : ℝ) - 1) / Real.log 2 := by
        gcongr
    _ ≤ (1 / n) * logb 2 n + 3 / n := by linarith
    _ = (logb 2 n + 3) / n := by ring

/-- **The realised fraction of the cap tends to zero**: `δ(n) / log₂ n → 0`. -/
theorem detector_fraction_tendsto_zero :
    Tendsto (fun n : ℕ => detectorInfo n / logb 2 n) atTop (𝓝 0) := by
  have hb : ∀ᶠ n : ℕ in atTop, 0 ≤ detectorInfo n / logb 2 n ∧
      detectorInfo n / logb 2 n ≤ detectorInfo n := by
    filter_upwards [eventually_ge_atTop 2] with n hn
    have hn' : (2 : ℝ) ≤ n := by exact_mod_cast hn
    have hlog1 : 1 ≤ logb 2 (n : ℝ) := by
      rw [Real.le_logb_iff_rpow_le (by norm_num) (by linarith), Real.rpow_one]; exact hn'
    have hδ : 0 ≤ detectorInfo n := by
      rw [detectorInfo_eq_binEntropy hn]
      exact div_nonneg (Real.binEntropy_nonneg (by positivity)
        (by rw [one_div]; exact inv_le_one_of_one_le₀ (by linarith)))
        (Real.log_pos (by norm_num)).le
    exact ⟨div_nonneg hδ (by linarith), div_le_self hδ hlog1⟩
  exact tendsto_of_tendsto_of_tendsto_of_le_of_le' tendsto_const_nhds detectorInfo_tendsto_zero
    (hb.mono fun _ h => h.1) (hb.mono fun _ h => h.2)

/-! ## 4. Instances: `AGL(1,8)` and `A₄ = AGL(1,4)` -/

/-- The cycle type of `AGL(1,8)` is a trivial-coset detector: it is `[1,7]` exactly off the
translation subgroup. -/
theorem agl8_isDetector : ∀ g ∈ aglSet, aglType g = ({7} : Multiset ℕ) ↔ g ∉ transSet := by
  intro g hg
  rw [← aglCoset_eq_zero_iff hg]
  obtain ⟨e, b, rfl⟩ := mem_aglSet.mp hg
  rw [aglType_aff, aglCoset_aff, typeCode]
  by_cases he : e = 0
  · subst he
    by_cases hb : b = 0
    · simp [hb]
    · simp [hb]; decide
  · simp [he]

/-- **The law reproduces the brute-force `AGL(1,8)` value.** -/
theorem agl8_channel_via_law :
    mutualInfo aglSet aglCoset aglType = detectorInfo 7 ∧
      detectorInfo 7 = logb 2 7 - 6 / 7 * logb 2 6 := by
  refine ⟨?_, ?_⟩
  · have h := group_detector_law aglSet_isSubgroup transSet_isSubgroup transSet_subset
      aglCoset_isCosetReadout agl8_isDetector (by rw [aglCoset_image_card]; norm_num)
    rwa [aglCoset_image_card] at h
  · unfold detectorInfo; norm_num

/-- The catalog's `A₄` (Galois group of `x⁴ + 8x + 12`) with its splitting-type readout is a
trivial-coset detector: the type `(1,0)` of the 3-cycles occurs exactly off `V₄`. -/
theorem A4_isDetector : ∀ g ∈ A4, splitType g = (1, 0) ↔ g ∉ V4 := by decide

/-- **The law reproduces the catalog's `A₄` channel** `TypeChannel.A4_channel`. -/
theorem A4_channel_via_law :
    mutualInfo A4 pairIdx splitType = detectorInfo 3 ∧
      detectorInfo 3 = logb 2 3 - 2 / 3 := by
  have himg : (A4.image pairIdx).card = 3 := by decide
  refine ⟨?_, ?_⟩
  · have h := group_detector_law A4_isSubgroup V4_isSubgroup (by decide) A4_coset A4_isDetector
      (by rw [himg]; norm_num)
    rwa [himg] at h
  · have h := A4_channel
    rw [← h]
    have h2 := group_detector_law A4_isSubgroup V4_isSubgroup (by decide) A4_coset A4_isDetector
      (by rw [himg]; norm_num)
    rw [h2, himg]

/-- **`AGL(1,8)` leaks strictly less than `A₄ = AGL(1,4)`, as a consequence of the law.**
Both are detectors; their abelianizations have orders `7 > 3`; anti-monotonicity does the
rest.  No numerical evaluation is used. -/
theorem agl8_below_A4 :
    mutualInfo aglSet aglCoset aglType < mutualInfo A4 pairIdx splitType := by
  rw [agl8_channel_via_law.1, A4_channel_via_law.1]
  exact detectorInfo_strictAnti (by norm_num) (by norm_num)

/-- **Explicit vanishing bound at `AGL(1,8)`.**  `I₁ ≤ (log₂ 7 + 3)/7`. -/
theorem agl8_rate_bound :
    mutualInfo aglSet aglCoset aglType ≤ (logb 2 7 + 3) / 7 := by
  rw [agl8_channel_via_law.1]
  have := detectorInfo_le (n := 7) (by norm_num)
  simpa using this

end AGL8