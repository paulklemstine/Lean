import Probability.NET90ThreeDomainSimplex

/-!
# NET-90, sixth cycle: the `d`-domain ladder and the collapse of the `6·d` law

Cycle 5 (`NET90ThreeDomainSimplex.lean`) computed the exact budgets of one, two and three
equally massive geometric domains at gate `0.98` and found the ladder `6 → 12 → 18`,
recording it as "the per-domain cost does not saturate — the budget is `6·d`".  Direction 2
of `FUTURE_DIRECTIONS.md` asked for general `d`.  This file settles it, and the answer
contradicts the naive extrapolation: **the `6·d` law is an artefact of `d ≤ 3`.**

The `d`-fold head mass `mixNHead a m d k` is the `d`-fold sup-convolution of the pure head
mass, defined by recursion on the number of domains, and `mixNKnee` is the induced knee.
The machinery is validated against the earlier cycles: `mixNKnee_one`, `mixNKnee_two` and
`mixNKnee_three` identify it with `kstar`, `mixKnee` and `mix3Knee` respectively.

The exact answer for the geometric profile `(1/2)^i` at gate `0.98` is

  `mixNKnee geomHalf m d 0.98 = ⌈143·d / 25⌉ = (143·d + 24) / 25`   (`mixNKnee_geomHalf`),

i.e. exactly `5.72` keys per domain rather than `6`.  For `d = 1,2,3` the ceiling rounds up
to `6, 12, 18` and hides the true rate; from `d = 4` on it separates: four domains need
**23**, not 24 (`net90_domain_ladder_four`, `mixNKnee_lt_six_mul`).

The engine of both bounds is the *tangent-line* estimate `half_pow_tangent`:

  `(7 - j) / 64 ≤ (1/2)^j`  for every `j : ℕ`,

with equality exactly at `j ∈ {5, 6}`.  Summed over the `d` domains it turns the discrete
allocation problem into a linear one: no allocation of `k` keys can leave less than
`(7d - k)/64` of the geometric tail behind, and an allocation using only blocks of size `5`
and `6` attains that bound.  This is where the `1/25` comes from — and it is why the
per-domain cost `143/25` is *not* an integer, which is precisely what the small-`d` ladder
could not see.

-- !-- Lab Notes -- !--
Hypothesizer (cycle 6):
 (U1) The `6·d` ladder of cycle 5 is false for large `d`; the true per-domain cost is a
      non-integer rate `< 6`, and the ladder is its ceiling.                    [BOLD]
 (U2) The extremal allocation uses only two block sizes (`5` and `6`), so a single linear
      (tangent) inequality replaces the case analysis of cycle 5.
 (U3) The `d`-fold theory is a recursion over the two-domain one, so all the earlier exact
      values must be recovered as instances.

Experimenter: U2 = `half_pow_tangent`, giving `mixNHead_geomHalf_le` (upper) and
`le_mixNHead_geomHalf` (lower, by an explicit `5/6`-block construction); U1 =
`mixNKnee_geomHalf` and `mixNKnee_lt_six_mul`; U3 = `mixNKnee_one`, `mixNKnee_two`,
`mixNKnee_three`.  Zero sorries.

Analyst: the failure of cycle 5's reading is a rounding artefact, not an error: `⌈5.72 d⌉`
equals `6 d` exactly for `d ≤ 3` because `0.28 d < 1` there.  The finite-context correction
enters only through the hypothesis `1600 · d ≤ 2 ^ m`: the gate is computed against the
*actual* mass `2(1 - 2^{-m})` of a domain of `m` keys, and the razor at `k = ⌈5.72d⌉ - 1`
has margin `1/800`, which the truncation error `1.96 · d · 2^{-m}` must not eat.  With the
experimental `m ≥ 16` this covers every `d ≤ 41`.

Critic: nothing here is vacuous — `mixNKnee_one/two/three` pin the new definition to the
old ones, so the ladder is a statement about the same object as cycles 1–5, and the
`d = 4` cell is exhibited with both a passing allocation and an impossibility proof.
-/

namespace AttentionBudget

open Finset

variable {a : ℕ → ℝ} {m d k : ℕ} {τ : ℝ}

/-! ## The `d`-fold sup-convolution -/

/-- Head mass of a top-`k` truncation of a context made of `d` domains, each carrying `m`
keys with sorted profile `a`.  It is the `d`-fold sup-convolution of the pure head mass,
built by recursion on the number of domains. -/
noncomputable def mixNHead (a : ℕ → ℝ) (m : ℕ) : ℕ → ℕ → ℝ
  | 0, _ => 0
  | d + 1, k =>
      (range (k + 1)).sup' nonempty_range_add_one
        fun j => mixNHead a m d j + headMass a (min (k - j) m)

/-- Total mass of a `d`-domain context with `m` keys per domain. -/
noncomputable def mixNTotal (a : ℕ → ℝ) (m d : ℕ) : ℝ := (d : ℝ) * headMass a m

/-- Retained fraction of a `d`-domain context under a top-`k` truncation. -/
noncomputable def mixNRetained (a : ℕ → ℝ) (m d k : ℕ) : ℝ :=
  mixNHead a m d k / mixNTotal a m d

/-- The knee of a `d`-domain context. -/
noncomputable def mixNKnee (a : ℕ → ℝ) (m d : ℕ) (τ : ℝ) : ℕ :=
  sInf {k | τ ≤ mixNRetained a m d k}

@[simp] lemma mixNHead_zero (a : ℕ → ℝ) (m k : ℕ) : mixNHead a m 0 k = 0 := rfl

lemma le_mixNHead (a : ℕ → ℝ) (m d : ℕ) {j k : ℕ} (hj : j ≤ k) :
    mixNHead a m d j + headMass a (min (k - j) m) ≤ mixNHead a m (d + 1) k := by
  rw [mixNHead]
  exact Finset.le_sup' (fun i => mixNHead a m d i + headMass a (min (k - i) m))
    (mem_range.2 (Nat.lt_succ_of_le hj))

lemma mixNHead_le {C : ℝ}
    (h : ∀ j ≤ k, mixNHead a m d j + headMass a (min (k - j) m) ≤ C) :
    mixNHead a m (d + 1) k ≤ C := by
  rw [mixNHead]
  exact Finset.sup'_le _ _ fun j hj => h j (by simpa [Nat.lt_succ_iff] using mem_range.1 hj)

lemma mixNKnee_le_of_pass (h : τ ≤ mixNRetained a m d k) : mixNKnee a m d τ ≤ k :=
  Nat.sInf_le h

section Positive

variable (ha : ∀ i, 0 < a i)

include ha

lemma mixNHead_mono (m d : ℕ) : Monotone (mixNHead a m d) := by
  induction d with
  | zero => intro k k' _; simp
  | succ d _ =>
      intro k k' hk
      refine mixNHead_le fun j hj => ?_
      refine le_trans ?_ (le_mixNHead a m d (j := j) (k := k') (by omega))
      exact add_le_add le_rfl (headMass_mono ha (min_le_min (by omega) le_rfl))

lemma mixNHead_le_total (m d k : ℕ) : mixNHead a m d k ≤ (d : ℝ) * headMass a m := by
  induction d generalizing k with
  | zero => simp
  | succ d ih =>
      refine mixNHead_le fun j _ => ?_
      have h1 := ih j
      have h2 : headMass a (min (k - j) m) ≤ headMass a m :=
        headMass_mono ha (min_le_right _ _)
      push_cast
      linarith

lemma mixNHead_full (m d : ℕ) : mixNHead a m d (d * m) = (d : ℝ) * headMass a m := by
  induction d with
  | zero => simp
  | succ d ih =>
      refine le_antisymm (mixNHead_le_total ha m (d + 1) _) ?_
      have hk : (d + 1) * m = d * m + m := by ring
      have h := le_mixNHead a m d (j := d * m) (k := d * m + m) (by omega)
      simp only [Nat.add_sub_cancel_left, min_self] at h
      rw [ih] at h
      rw [hk]
      push_cast
      linarith

lemma mixNTotal_pos (hm : 0 < m) (hd : 0 < d) : 0 < mixNTotal a m d := by
  have h1 : (0 : ℝ) < (d : ℝ) := by exact_mod_cast hd
  have h2 : 0 < headMass a m := headMass_pos ha hm
  exact mul_pos h1 h2

lemma mixNRetained_full (hm : 0 < m) (hd : 0 < d) : mixNRetained a m d (d * m) = 1 := by
  rw [mixNRetained, mixNHead_full ha, ← mixNTotal, div_self (mixNTotal_pos ha hm hd).ne']

lemma mixNRetained_mono (hm : 0 < m) (hd : 0 < d) : Monotone (mixNRetained a m d) :=
  fun _ _ hkk =>
    div_le_div_of_nonneg_right (mixNHead_mono ha m d hkk) (mixNTotal_pos ha hm hd).le

lemma gate_le_mixNRetained_mixNKnee (hm : 0 < m) (hd : 0 < d) (hτ : τ ≤ 1) :
    τ ≤ mixNRetained a m d (mixNKnee a m d τ) := by
  have hmem : d * m ∈ {k | τ ≤ mixNRetained a m d k} := by
    simp only [Set.mem_setOf_eq, mixNRetained_full ha hm hd]
    exact hτ
  exact Nat.sInf_mem ⟨_, hmem⟩

lemma lt_mixNKnee_of_fail (hm : 0 < m) (hd : 0 < d) (hτ : τ ≤ 1)
    (h : mixNRetained a m d k < τ) : k < mixNKnee a m d τ := by
  by_contra hcon
  push_neg at hcon
  have h1 := mixNRetained_mono ha hm hd hcon
  have h2 := gate_le_mixNRetained_mixNKnee ha hm hd hτ
  linarith

/-! ## Validation: the new machinery reproduces cycles 1–5 -/

lemma mixNHead_one (m k : ℕ) : mixNHead a m 1 k = headMass a (min k m) := by
  refine le_antisymm (mixNHead_le fun j hj => ?_) ?_
  · simp only [mixNHead_zero, zero_add]
    exact headMass_mono ha (min_le_min (by omega) le_rfl)
  · have h := le_mixNHead a m 0 (j := 0) (k := k) (Nat.zero_le k)
    simpa using h

lemma mixNHead_two (m k : ℕ) : mixNHead a m 2 k = mixHead a a m m k := by
  refine le_antisymm (mixNHead_le fun j hj => ?_) (mixHead_le fun j hj => ?_)
  · rw [mixNHead_one ha]
    exact le_mixHead a a m m hj
  · rw [← mixNHead_one ha m j]
    exact le_mixNHead a m 1 hj

lemma mixNHead_three (m k : ℕ) : mixNHead a m 3 k = mix3Head a a a m m m k := by
  refine le_antisymm (mixNHead_le fun j hj => ?_) (mix3Head_le fun j hj => ?_)
  · rw [mixNHead_two ha]
    exact le_mix3Head a a a m m m hj
  · rw [← mixNHead_two ha m j]
    exact le_mixNHead a m 2 hj

/-- One domain: the `d`-fold knee is the pure knee of the catalog theory. -/
theorem mixNKnee_one (m : ℕ) (τ : ℝ) : mixNKnee a m 1 τ = kstar a m τ := by
  have hset : {k | τ ≤ mixNRetained a m 1 k} = {k | τ ≤ retained a m k} := by
    ext k
    simp [mixNRetained, mixNTotal, mixNHead_one ha, retained]
  simp [mixNKnee, kstar, hset]

/-- Two domains: the `d`-fold knee is the two-domain mixture knee of cycle 1. -/
theorem mixNKnee_two (m : ℕ) (τ : ℝ) : mixNKnee a m 2 τ = mixKnee a a m m τ := by
  have htot : mixNTotal a m 2 = mixTotal a a m m := by
    rw [mixNTotal, mixTotal]; push_cast; ring
  have hset : {k | τ ≤ mixNRetained a m 2 k} = {k | τ ≤ mixRetained a a m m k} := by
    ext k
    simp [mixNRetained, mixRetained, mixNHead_two ha, htot]
  simp [mixNKnee, mixKnee, hset]

/-- Three domains: the `d`-fold knee is the three-domain knee of cycle 5. -/
theorem mixNKnee_three (m : ℕ) (τ : ℝ) : mixNKnee a m 3 τ = mix3Knee a a a m m m τ := by
  have htot : mixNTotal a m 3 = mix3Total a a a m m m := by
    rw [mixNTotal, mix3Total, mixTotal]; push_cast; ring
  have hset : {k | τ ≤ mixNRetained a m 3 k} = {k | τ ≤ mix3Retained a a a m m m k} := by
    ext k
    simp [mixNRetained, mix3Retained, mixNHead_three ha, htot]
  simp [mixNKnee, mix3Knee, hset]

end Positive

/-! ## The tangent-line inequality -/

/-- **The tangent estimate.**  The convex function `j ↦ (1/2)^j` dominates its chord
through `j = 5` and `j = 6`, namely `(7 - j)/64`, at every natural `j`, with equality
exactly at `j = 5, 6`.  Summing it over the domains linearises the allocation problem. -/
private lemma half_pow_tangent (j : ℕ) : ((7 : ℝ) - (j : ℝ)) / 64 ≤ (1 / 2 : ℝ) ^ j := by
  rcases le_or_gt j 7 with hj | hj
  · interval_cases j <;> norm_num
  · have hj' : (7 : ℝ) ≤ (j : ℝ) := by exact_mod_cast hj.le
    have hpos : (0 : ℝ) < (1 / 2 : ℝ) ^ j := by positivity
    have hneg : ((7 : ℝ) - (j : ℝ)) / 64 ≤ 0 := by linarith
    linarith

/-! ## The exact `d`-domain head of the geometric profile -/

/-- **Upper bound.**  No allocation of `k` keys across `d` geometric domains can leave less
than `(7d - k)/64` of the tail mass behind. -/
lemma mixNHead_geomHalf_le (m d k : ℕ) :
    mixNHead geomHalf m d k ≤ 2 * (d : ℝ) - (7 * (d : ℝ) - (k : ℝ)) / 32 := by
  induction d generalizing k with
  | zero =>
      have hk : (0 : ℝ) ≤ (k : ℝ) := Nat.cast_nonneg k
      simp only [mixNHead_zero, Nat.cast_zero]
      linarith
  | succ d ih =>
      refine mixNHead_le fun j hj => ?_
      have h1 := ih (k := j)
      have hcast : ((k - j : ℕ) : ℝ) = (k : ℝ) - (j : ℝ) := by
        have : (j : ℕ) ≤ k := hj
        push_cast [Nat.cast_sub this]
        ring
      have hle : (1 / 2 : ℝ) ^ (k - j) ≤ (1 / 2 : ℝ) ^ (min (k - j) m) :=
        pow_le_pow_of_le_one (by norm_num) (by norm_num) (min_le_left _ _)
      have htan := half_pow_tangent (k - j)
      rw [hcast] at htan
      have h3 : headMass geomHalf (min (k - j) m)
          = 2 * (1 - (1 / 2 : ℝ) ^ (min (k - j) m)) := headMass_geomHalf _
      rw [h3]
      push_cast
      linarith

/-- **Lower bound.**  Allocating only blocks of `5` and `6` keys attains the tangent bound:
for `5d ≤ k ≤ 6d` the `d`-domain head is at least `2d - (7d - k)/32`. -/
lemma le_mixNHead_geomHalf (hm : 6 ≤ m) :
    ∀ d k : ℕ, 5 * d ≤ k → k ≤ 6 * d →
      2 * (d : ℝ) - (7 * (d : ℝ) - (k : ℝ)) / 32 ≤ mixNHead geomHalf m d k := by
  intro d
  induction d with
  | zero =>
      intro k _ h2
      have hk : k = 0 := by omega
      subst hk
      norm_num
  | succ d ih =>
      intro k h1 h2
      rcases le_or_gt (5 * d + 6) k with hc | hc
      · have h := le_mixNHead geomHalf m d (j := k - 6) (k := k) (by omega)
        have hmin : min (k - (k - 6)) m = 6 := by omega
        rw [hmin] at h
        have h6 : headMass geomHalf 6 = 63 / 32 := by
          rw [headMass_geomHalf]; norm_num
        rw [h6] at h
        have hih := ih (k - 6) (by omega) (by omega)
        have hcast : ((k - 6 : ℕ) : ℝ) = (k : ℝ) - 6 := by
          have h6k : (6 : ℕ) ≤ k := by omega
          push_cast [Nat.cast_sub h6k]
          ring
        rw [hcast] at hih
        push_cast
        linarith
      · have h := le_mixNHead geomHalf m d (j := k - 5) (k := k) (by omega)
        have hmin : min (k - (k - 5)) m = 5 := by omega
        rw [hmin] at h
        have h5 : headMass geomHalf 5 = 31 / 16 := by
          rw [headMass_geomHalf]; norm_num
        rw [h5] at h
        have hih := ih (k - 5) (by omega) (by omega)
        have hcast : ((k - 5 : ℕ) : ℝ) = (k : ℝ) - 5 := by
          have h5k : (5 : ℕ) ≤ k := by omega
          push_cast [Nat.cast_sub h5k]
          ring
        rw [hcast] at hih
        push_cast
        linarith

/-! ## The exact `d`-domain knee: `⌈143 d / 25⌉` -/

/-- **The `d`-domain budget.**  For `d` geometric domains of `m ≥ 16` keys each at gate
`0.98` the knee is exactly `⌈143 d / 25⌉`: the per-domain cost is `143/25 = 5.72` keys, not
`6`.  The hypothesis `1600 · d ≤ 2 ^ m` keeps the finite-context truncation error below the
`1/800` margin of the razor; with the experimental `m = 16` it covers every `d ≤ 40`. -/
theorem mixNKnee_geomHalf (hd : 0 < d) (hm : 16 ≤ m) (hdm : 1600 * d ≤ 2 ^ m) :
    mixNKnee geomHalf m d (0.98 : ℝ) = (143 * d + 24) / 25 := by
  set K := (143 * d + 24) / 25 with hKdef
  have hK1 : 143 * d ≤ 25 * K := by omega
  have hK2 : 25 * K ≤ 143 * d + 24 := by omega
  have hK5 : 5 * d ≤ K := by omega
  have hK6 : K ≤ 6 * d := by omega
  have hKpos : 1 ≤ K := by omega
  have hm0 : 0 < m := by omega
  have hHpos : 0 < headMass geomHalf m := headMass_pos geomHalf_pos hm0
  have hTpos : 0 < mixNTotal geomHalf m d := mixNTotal_pos geomHalf_pos hm0 hd
  have hdR : (1 : ℝ) ≤ (d : ℝ) := by exact_mod_cast hd
  have hHlt : headMass geomHalf m < 2 := headMass_geomHalf_lt_two m
  have hHeq : headMass geomHalf m = 2 * (1 - (1 / 2 : ℝ) ^ m) := headMass_geomHalf m
  have hpass : (0.98 : ℝ) ≤ mixNRetained geomHalf m d K := by
    have hlow := le_mixNHead_geomHalf (m := m) (by omega) d K (by omega) (by omega)
    have hKR : 143 * (d : ℝ) ≤ 25 * (K : ℝ) := by exact_mod_cast hK1
    have hprod : (d : ℝ) * headMass geomHalf m ≤ (d : ℝ) * 2 :=
      mul_le_mul_of_nonneg_left hHlt.le (by linarith)
    rw [mixNRetained, le_div_iff₀ hTpos, mixNTotal]
    linarith
  have hfail : mixNRetained geomHalf m d (K - 1) < (0.98 : ℝ) := by
    have hup := mixNHead_geomHalf_le m d (K - 1)
    have hcast : ((K - 1 : ℕ) : ℝ) = (K : ℝ) - 1 := by
      push_cast [Nat.cast_sub hKpos]
      ring
    rw [hcast] at hup
    have hKR : 25 * (K : ℝ) ≤ 143 * (d : ℝ) + 24 := by exact_mod_cast hK2
    have h2m : (1600 : ℝ) * (d : ℝ) ≤ (2 : ℝ) ^ m := by exact_mod_cast hdm
    have h2mpos : (0 : ℝ) < (2 : ℝ) ^ m := by positivity
    have hxeq : (1 / 2 : ℝ) ^ m = 1 / (2 : ℝ) ^ m := by
      rw [div_pow]; norm_num
    have hdx : (d : ℝ) * (1 / 2 : ℝ) ^ m ≤ 1 / 1600 := by
      rw [hxeq, mul_one_div, div_le_div_iff₀ h2mpos (by norm_num : (0 : ℝ) < 1600)]
      linarith
    rw [mixNRetained, div_lt_iff₀ hTpos, mixNTotal, hHeq]
    nlinarith [hup, hdx, hKR]
  have h1 : mixNKnee geomHalf m d (0.98 : ℝ) ≤ K := mixNKnee_le_of_pass hpass
  have h2 : K - 1 < mixNKnee geomHalf m d (0.98 : ℝ) :=
    lt_mixNKnee_of_fail geomHalf_pos hm0 hd (by norm_num) hfail
  omega

/-- **The `5.72` rate.**  The `d`-domain budget is squeezed between `143 d / 25` and
`(143 d + 24)/25`, so the per-domain cost converges to `143/25 < 6`. -/
theorem mixNKnee_geomHalf_rate (hd : 0 < d) (hm : 16 ≤ m) (hdm : 1600 * d ≤ 2 ^ m) :
    143 * d ≤ 25 * mixNKnee geomHalf m d (0.98 : ℝ) ∧
      25 * mixNKnee geomHalf m d (0.98 : ℝ) ≤ 143 * d + 24 := by
  rw [mixNKnee_geomHalf hd hm hdm]
  omega

/-- **The `6·d` law fails from four domains on.**  For `d ≥ 4` the balanced `d`-domain
budget is *strictly* below `6·d`, so the ladder `6 → 12 → 18` of cycle 5 does not continue:
the per-domain cost does saturate below the pure budget. -/
theorem mixNKnee_lt_six_mul (hd : 4 ≤ d) (hm : 16 ≤ m) (hdm : 1600 * d ≤ 2 ^ m) :
    mixNKnee geomHalf m d (0.98 : ℝ) < 6 * d := by
  rw [mixNKnee_geomHalf (by omega) hm hdm]
  omega

private lemma pow_two_ge_of_sixteen_le {m : ℕ} (hm : 16 ≤ m) : 65536 ≤ 2 ^ m := by
  have h : (2 : ℕ) ^ 16 ≤ 2 ^ m := Nat.pow_le_pow_right (by norm_num) hm
  norm_num at h
  exact h

/-- **The corrected ladder `6 → 12 → 18 → 23`.**  On the geometric profile at gate `0.98`,
with at least 16 keys per domain, one, two and three domains cost `6, 12, 18` — reproducing
cycles 2 and 5 — but four domains cost `23`, strictly less than `4 · 6 = 24`. -/
theorem net90_domain_ladder_four {m : ℕ} (hm : 16 ≤ m) :
    mixNKnee geomHalf m 1 (0.98 : ℝ) = 6 ∧
      mixNKnee geomHalf m 2 (0.98 : ℝ) = 12 ∧
      mixNKnee geomHalf m 3 (0.98 : ℝ) = 18 ∧
      mixNKnee geomHalf m 4 (0.98 : ℝ) = 23 ∧
      mixNKnee geomHalf m 4 (0.98 : ℝ) < 4 * mixNKnee geomHalf m 1 (0.98 : ℝ) := by
  have hpow := pow_two_ge_of_sixteen_le hm
  have h1 : mixNKnee geomHalf m 1 (0.98 : ℝ) = 6 := by
    rw [mixNKnee_geomHalf (by norm_num) hm (by omega)]
  have h2 : mixNKnee geomHalf m 2 (0.98 : ℝ) = 12 := by
    rw [mixNKnee_geomHalf (by norm_num) hm (by omega)]
  have h3 : mixNKnee geomHalf m 3 (0.98 : ℝ) = 18 := by
    rw [mixNKnee_geomHalf (by norm_num) hm (by omega)]
  have h4 : mixNKnee geomHalf m 4 (0.98 : ℝ) = 23 := by
    rw [mixNKnee_geomHalf (by norm_num) hm (by omega)]
  exact ⟨h1, h2, h3, h4, by rw [h1, h4]; norm_num⟩

/-- **Consistency with cycles 1–5.**  The `d`-fold knee agrees with the pure, two- and
three-domain knees already computed, so the ladder above is a statement about the same
budget object: `6`, `12`, `18`. -/
theorem net90_ladder_consistency {m : ℕ} (hm : 16 ≤ m) :
    mixNKnee geomHalf m 1 (0.98 : ℝ) = kstar geomHalf m (0.98 : ℝ) ∧
      mixNKnee geomHalf m 2 (0.98 : ℝ) = mixKnee geomHalf geomHalf m m (0.98 : ℝ) ∧
      mixNKnee geomHalf m 3 (0.98 : ℝ)
        = mix3Knee geomHalf geomHalf geomHalf m m m (0.98 : ℝ) ∧
      kstar geomHalf m (0.98 : ℝ) = 6 ∧
      mixKnee geomHalf geomHalf m m (0.98 : ℝ) = 12 ∧
      mix3Knee geomHalf geomHalf geomHalf m m m (0.98 : ℝ) = 18 :=
  ⟨mixNKnee_one geomHalf_pos m _, mixNKnee_two geomHalf_pos m _,
    mixNKnee_three geomHalf_pos m _, kstar_geomHalf_eq_six hm,
    mixKnee_geomHalf_eq_twelve hm hm, mix3Knee_geomHalf_eq_eighteen hm hm hm⟩

end AttentionBudget