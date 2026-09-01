import Probability.NET90MixtureKnee

/-!
# NET-90: the symmetric-mixture bump, exactly

`Probability.NET90MixtureKnee` shows that the key budget of a two-domain context is
governed by a sup-convolution and is trapped between a superadditive and a subadditive
bound.  This file turns that theory into *exact numbers* on an explicit profile, and
uses them to refute the three pre-registered shapes of the mixing-ratio response.

Working with the geometric profile `geomHalf i = (1/2)^i` and the experiment's gate
`τ = 0.98`:

* `kstar_geomHalf_eq_six` — every pure context of length `≥ 16` has knee **exactly 6**;
  in particular both endpoints of the ratio sweep agree, at every context length.
* `mixKnee_geomHalf_eq_twelve` — every mixture with **both** sides of size `≥ 16` has
  knee **exactly 12**, independently of the ratio: an interior *plateau* at twice the
  pure budget.
* `net90_bump` — hence the balanced arm strictly exceeds both pure endpoints.
* `net90_refutes_linear`, `net90_refutes_dip`, `net90_refutes_monotone` — the three
  pre-registered shapes P1 (linear in ratio), P2 (dip below the pure domains) and
  P3 (monotone in the prose fraction) are all false for this profile.
* `net90_minority_threshold` — the bump switches off when the minority side is small:
  a minority of at most `5` keys keeps the knee `≤ 11 < 12`.  Asymmetry is protective
  only in the *extreme* regime, which is the sharp mathematical form of the informal
  "minority blocks are rare enough that majority structure dominates".
* `net90_context_table` — the two experimental context levels `512` and `1024`
  instantiated: `(6, 12)` at both, i.e. the bump does not wash out with context.

-- !-- Lab Notes -- !--
Experimenter (all values below are theorems of this file, not measurements):

  arm (ctx 512)       m     l     knee
  pure code         512     0        6
  25/75             128   384       12
  50/50             256   256       12
  75/25             384   128       12
  pure prose          0   512        6

  arm (ctx 1024)      m     l     knee
  pure code        1024     0        6
  50/50             512   512       12
  pure prose          0  1024        6

The measured NET-90 table (`{12,12,16,16,12}` at ctx 512) has the same *sign* as the
theory — the interior arms are never below the endpoints and the balanced arm is
strictly above — but the theory predicts the interior arms are all bumped, whereas the
measurement reports `25/75` at the endpoint value.  Under the model that is only
possible when one side is close to the extreme regime (`net90_minority_threshold`) or
when the two domains carry very unequal head mass, which is exactly the honest-limits
caveat recorded for the corpus draw.

Analyst: the mechanism is not "cross-domain interference" in any dynamical sense.  It is
purely combinatorial: a mixed context forces the truncation budget to be *split*, and
each side must independently be served to a gate barely below `τ`.  Two heads cost twice
one head.  The prediction "not linear, not a dip, a bump" is therefore structural, and
the only content the corpus contributes is *where the plateau shoulders sit*.

Critic: the theorems are exact equalities, not one-sided estimates, so they cannot be
vacuous; the failure sides (`retained ... 5 < 0.98` and `mixRetained ... 11 < 0.98`) are
proved, not assumed, so the knee values are pinned from both sides.  The plateau result
requires both sides `≥ 16`, and `net90_minority_threshold` shows this hypothesis is not
removable: with a small minority the conclusion is false.
-/

namespace AttentionBudget

open Finset

/-! ## The geometric profile -/

/-- The reference sorted attention profile `(1/2)^i`: a clean spectral gap. -/
noncomputable def geomHalf : ℕ → ℝ := fun i => (1 / 2 : ℝ) ^ i

lemma geomHalf_pos : ∀ i, 0 < geomHalf i := fun i => by
  show (0 : ℝ) < (1 / 2 : ℝ) ^ i
  positivity

/-- Closed form for the head mass of the geometric profile. -/
lemma headMass_geomHalf (n : ℕ) : headMass geomHalf n = 2 * (1 - (1 / 2 : ℝ) ^ n) := by
  rw [headMass]
  rw [show (∑ i ∈ range n, geomHalf i) = ∑ i ∈ range n, (1 / 2 : ℝ) ^ i from rfl]
  rw [geom_sum_eq (by norm_num : (1 / 2 : ℝ) ≠ 1)]
  ring

lemma headMass_geomHalf_lt_two (n : ℕ) : headMass geomHalf n < 2 := by
  rw [headMass_geomHalf]
  have : (0 : ℝ) < (1 / 2 : ℝ) ^ n := by positivity
  linarith

/-- On a context of length at least `16` the geometric head mass is within `2⁻¹⁵` of its
supremum. -/
lemma headMass_geomHalf_ge {n : ℕ} (hn : 16 ≤ n) :
    2 * (1 - (1 / 2 : ℝ) ^ 16) ≤ headMass geomHalf n := by
  have hp : (1 / 2 : ℝ) ^ n ≤ (1 / 2 : ℝ) ^ 16 :=
    pow_le_pow_of_le_one (by norm_num) (by norm_num) hn
  rw [headMass_geomHalf]
  linarith

/-! ## The pure endpoints: knee exactly 6 -/

/-- **Both endpoints of the ratio sweep.**  For the geometric profile the pure-domain
knee at gate `0.98` is exactly `6` on every context of length at least `16`. -/
theorem kstar_geomHalf_eq_six {n : ℕ} (hn : 16 ≤ n) : kstar geomHalf n (0.98 : ℝ) = 6 := by
  have hn0 : 0 < n := by omega
  have hpos : 0 < headMass geomHalf n := headMass_pos geomHalf_pos hn0
  have hlow : 2 * (1 - (1 / 2 : ℝ) ^ 16) ≤ headMass geomHalf n := headMass_geomHalf_ge hn
  have hhigh : headMass geomHalf n < 2 := headMass_geomHalf_lt_two n
  have h6 : headMass geomHalf 6 = 63 / 32 := by rw [headMass_geomHalf]; norm_num
  have h5 : headMass geomHalf 5 = 31 / 16 := by rw [headMass_geomHalf]; norm_num
  norm_num at hlow
  have hpass : (0.98 : ℝ) ≤ retained geomHalf n 6 := by
    rw [retained, min_eq_left (by omega : 6 ≤ n), le_div_iff₀ hpos, h6]
    norm_num
    linarith
  have hfail : retained geomHalf n 5 < (0.98 : ℝ) := by
    rw [retained, min_eq_left (by omega : 5 ≤ n), div_lt_iff₀ hpos, h5]
    norm_num
    linarith
  have h1 : kstar geomHalf n (0.98 : ℝ) ≤ 6 := kstar_le_of_pass hpass
  have h2 : 5 < kstar geomHalf n (0.98 : ℝ) :=
    lt_kstar_of_fail geomHalf_pos hn0 (by norm_num) hfail
  omega

/-! ## The interior of the sweep: knee exactly 12 -/

/-- The optimal split of a budget `k ≤ 11` across two geometric sides of size at least
`16` never reaches more than `125/32` of the available mass `4`. -/
lemma mixHead_geomHalf_eleven {m l : ℕ} (hm : 16 ≤ m) (hl : 16 ≤ l) :
    mixHead geomHalf geomHalf m l 11 ≤ 125 / 32 := by
  refine mixHead_le fun j hj => ?_
  have h1 : min j m = j := min_eq_left (by omega)
  have h2 : min (11 - j) l = 11 - j := min_eq_left (by omega)
  rw [h1, h2, headMass_geomHalf, headMass_geomHalf]
  interval_cases j <;> norm_num

/-- **The interior plateau.**  Every mixture whose two sides both have at least `16` keys
has knee exactly `12` at gate `0.98` — twice the pure budget, and independent of the
mixing ratio. -/
theorem mixKnee_geomHalf_eq_twelve {m l : ℕ} (hm : 16 ≤ m) (hl : 16 ≤ l) :
    mixKnee geomHalf geomHalf m l (0.98 : ℝ) = 12 := by
  have hm0 : 0 < m := by omega
  have hl0 : 0 < l := by omega
  have htot : 0 < mixTotal geomHalf geomHalf m l :=
    mixTotal_pos geomHalf_pos geomHalf_pos hm0 hl0
  have hlowm : 2 * (1 - (1 / 2 : ℝ) ^ 16) ≤ headMass geomHalf m := headMass_geomHalf_ge hm
  have hlowl : 2 * (1 - (1 / 2 : ℝ) ^ 16) ≤ headMass geomHalf l := headMass_geomHalf_ge hl
  have hhm : headMass geomHalf m < 2 := headMass_geomHalf_lt_two m
  have hhl : headMass geomHalf l < 2 := headMass_geomHalf_lt_two l
  have h6 : headMass geomHalf 6 = 63 / 32 := by rw [headMass_geomHalf]; norm_num
  norm_num at hlowm hlowl
  have hpass : (0.98 : ℝ) ≤ mixRetained geomHalf geomHalf m l 12 := by
    have hsplit := le_mixHead geomHalf geomHalf m l (j := 6) (k := 12) (by omega)
    rw [min_eq_left (by omega : 6 ≤ m), show 12 - 6 = 6 from rfl,
      min_eq_left (by omega : 6 ≤ l), h6] at hsplit
    rw [mixRetained, le_div_iff₀ htot, mixTotal]
    norm_num
    linarith
  have hfail : mixRetained geomHalf geomHalf m l 11 < (0.98 : ℝ) := by
    have hub := mixHead_geomHalf_eleven hm hl
    rw [mixRetained, div_lt_iff₀ htot, mixTotal]
    norm_num
    linarith
  have h1 : mixKnee geomHalf geomHalf m l (0.98 : ℝ) ≤ 12 := mixKnee_le_of_pass hpass
  have h2 : 11 < mixKnee geomHalf geomHalf m l (0.98 : ℝ) :=
    lt_mixKnee_of_fail geomHalf_pos geomHalf_pos hm0 hl0 (by norm_num) hfail
  omega

/-! ## The bump and the refutation of the three pre-registered shapes -/

/-- **The symmetric-mixture bump.**  At any context length the balanced mixture costs
exactly twice the pure budget of either endpoint. -/
theorem net90_bump {N : ℕ} (hN : 16 ≤ N) :
    mixKnee geomHalf geomHalf (2 * N) 0 (0.98 : ℝ) = 6 ∧
      mixKnee geomHalf geomHalf 0 (2 * N) (0.98 : ℝ) = 6 ∧
      mixKnee geomHalf geomHalf N N (0.98 : ℝ) = 12 ∧
      mixKnee geomHalf geomHalf (2 * N) 0 (0.98 : ℝ)
        < mixKnee geomHalf geomHalf N N (0.98 : ℝ) ∧
      mixKnee geomHalf geomHalf 0 (2 * N) (0.98 : ℝ)
        < mixKnee geomHalf geomHalf N N (0.98 : ℝ) := by
  have hcode : mixKnee geomHalf geomHalf (2 * N) 0 (0.98 : ℝ) = 6 := by
    rw [mixKnee_pure_right geomHalf_pos]
    exact kstar_geomHalf_eq_six (by omega)
  have hprose : mixKnee geomHalf geomHalf 0 (2 * N) (0.98 : ℝ) = 6 := by
    rw [mixKnee_pure_left geomHalf_pos]
    exact kstar_geomHalf_eq_six (by omega)
  have hmix : mixKnee geomHalf geomHalf N N (0.98 : ℝ) = 12 :=
    mixKnee_geomHalf_eq_twelve hN hN
  exact ⟨hcode, hprose, hmix, by omega, by omega⟩

/-- **P1 refuted — the response is not linear in the mixing ratio.**  A linear response
would put the balanced arm at the average of the two endpoints. -/
theorem net90_refutes_linear {N : ℕ} (hN : 16 ≤ N) :
    2 * mixKnee geomHalf geomHalf N N (0.98 : ℝ)
      ≠ mixKnee geomHalf geomHalf (2 * N) 0 (0.98 : ℝ)
        + mixKnee geomHalf geomHalf 0 (2 * N) (0.98 : ℝ) := by
  obtain ⟨hc, hp, hm, -, -⟩ := net90_bump hN
  omega

/-- **P2 refuted — the balanced arm is not a dip.**  It lies strictly *above* both pure
domains, not below them. -/
theorem net90_refutes_dip {N : ℕ} (hN : 16 ≤ N) :
    max (mixKnee geomHalf geomHalf (2 * N) 0 (0.98 : ℝ))
        (mixKnee geomHalf geomHalf 0 (2 * N) (0.98 : ℝ))
      < mixKnee geomHalf geomHalf N N (0.98 : ℝ) := by
  obtain ⟨hc, hp, hm, -, -⟩ := net90_bump hN
  omega

/-- **P3 refuted — the response is not monotone in the mixing fraction.**  Along the
sweep `m ↦ k*(m, 2N - m)` the value rises from the code endpoint to the balanced point
and falls back to the prose endpoint, so the sweep is neither monotone nor antitone. -/
theorem net90_refutes_monotone {N : ℕ} (hN : 16 ≤ N) :
    ¬ Monotone (fun m : ℕ => mixKnee geomHalf geomHalf (min m (2 * N)) (2 * N - m) (0.98 : ℝ))
      ∧ ¬ Antitone
          (fun m : ℕ => mixKnee geomHalf geomHalf (min m (2 * N)) (2 * N - m) (0.98 : ℝ)) := by
  have h0 : mixKnee geomHalf geomHalf (min 0 (2 * N)) (2 * N - 0) (0.98 : ℝ) = 6 := by
    simp only [Nat.zero_min, Nat.sub_zero]
    rw [mixKnee_pure_left geomHalf_pos]
    exact kstar_geomHalf_eq_six (by omega)
  have hmid : mixKnee geomHalf geomHalf (min N (2 * N)) (2 * N - N) (0.98 : ℝ) = 12 := by
    rw [min_eq_left (by omega), show 2 * N - N = N by omega]
    exact mixKnee_geomHalf_eq_twelve hN hN
  have hend :
      mixKnee geomHalf geomHalf (min (2 * N) (2 * N)) (2 * N - 2 * N) (0.98 : ℝ) = 6 := by
    rw [min_self, show 2 * N - 2 * N = 0 by omega, mixKnee_pure_right geomHalf_pos]
    exact kstar_geomHalf_eq_six (by omega)
  constructor
  · intro hmono
    have := hmono (show N ≤ 2 * N by omega)
    simp only at this
    omega
  · intro hanti
    have := hanti (show 0 ≤ N by omega)
    simp only at this
    omega

/-! ## Where the plateau stops: the minority threshold -/

/-- **The bump needs a substantial minority.**  If the minority domain contributes at
most `5` keys, the mixed knee stays at `≤ 11`, strictly below the plateau value `12`.
So the interior plateau is not an artefact of the hypothesis `16 ≤ l`: the conclusion
genuinely fails in the extreme-asymmetry regime. -/
theorem net90_minority_threshold {m l : ℕ} (hm : 16 ≤ m) (hl0 : 0 < l) (hl : l ≤ 5) :
    mixKnee geomHalf geomHalf m l (0.98 : ℝ) ≤ 11 := by
  have h := mixKnee_le_kstar_add_minority (a := geomHalf) (b := geomHalf) geomHalf_pos
    geomHalf_pos (by omega : 0 < m) hl0 (by norm_num : (0.98 : ℝ) ≤ 1)
  rw [kstar_geomHalf_eq_six hm] at h
  omega

/-! ## The two experimental context levels -/

/-- **The NET-90 context table, derived.**  At both experimental context levels the pure
arms sit at `6` and the balanced arm at `12`: the `+`-premium of symmetric mixing is a
factor of two and does not wash out between `512` and `1024`. -/
theorem net90_context_table :
    kstar geomHalf 512 (0.98 : ℝ) = 6 ∧
      kstar geomHalf 1024 (0.98 : ℝ) = 6 ∧
      mixKnee geomHalf geomHalf 256 256 (0.98 : ℝ) = 12 ∧
      mixKnee geomHalf geomHalf 512 512 (0.98 : ℝ) = 12 ∧
      mixKnee geomHalf geomHalf 128 384 (0.98 : ℝ) = 12 ∧
      mixKnee geomHalf geomHalf 384 128 (0.98 : ℝ) = 12 :=
  ⟨kstar_geomHalf_eq_six (by norm_num), kstar_geomHalf_eq_six (by norm_num),
   mixKnee_geomHalf_eq_twelve (by norm_num) (by norm_num),
   mixKnee_geomHalf_eq_twelve (by norm_num) (by norm_num),
   mixKnee_geomHalf_eq_twelve (by norm_num) (by norm_num),
   mixKnee_geomHalf_eq_twelve (by norm_num) (by norm_num)⟩

end AttentionBudget