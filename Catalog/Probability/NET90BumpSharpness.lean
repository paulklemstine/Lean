import Probability.NET90SymmetricBump

/-!
# NET-90, second cycle: how big can the bump be, and what turns it off?

The first cycle established that a mixed-domain context has knee governed by a
sup-convolution, that the balanced arm of the ratio sweep is strictly bumped, and that
for the geometric profile the bump is exactly a doubling.  Two questions are left open
by that analysis, and both are answered here.

**How large can a mixing bump be?**  `mixKnee_le_two_mul_kstar_context` shows the
balanced self-mixture never costs more than *twice* the pure budget measured at the same
total context length — so the empirically reported `+25–33%` premium is well inside a
hard structural ceiling.  `bump_factor_two_is_sharp` shows the ceiling is attained: the
geometric profile realises the factor exactly (`12 = 2 · 6`).  So `2` is the sharp
constant of the theory, not an artefact of the estimates.

**Why do asymmetric arms sometimes sit at the pure value?**  Not because of key counts —
`mixKnee_geomHalf_eq_twelve` bumps every interior arm when both sides use the same
profile.  The correct control variable is the *mass ratio* of the two domains.
`mixKnee_le_kstar_inflated` shows a light domain can be ignored altogether at the cost
of inflating the gate by the mass ratio, and `minority_squeeze` sandwiches the mixed
knee between two pure knees whose gates both converge to `τ` as the minority mass
vanishes.  The explicit instance `mixKnee_lightMinority_eq_six` exhibits a two-domain
context with *half the keys* in the minority domain whose knee is exactly the pure
value `6`, while the mass-balanced mixture of the same key counts sits at `12`.

`net90_bump_with_shoulders` assembles the three arms — light minority `6`, balanced
`12`, pure `6` — into one statement: the ratio response is a bump with genuine
shoulders, and mass balance, not block counts, is what puts an arm on the plateau.

-- !-- Lab Notes -- !--
Hypothesizer (cycle 2):
 (S1) The mixing bump has a universal ceiling of exactly `2` at matched context.  [BOLD]
 (S2) The ceiling is attained, so no sharper universal constant exists.
 (S3) Asymmetric arms return to the pure value iff the minority *mass* — not its key
      count — is small compared with `(1-τ)` times the majority mass.            [BOLD]
 (S4) The knee is monotone in the context length for every profile, so the two
      context levels of the experiment cannot be compared without this correction.

Experimenter: S4 = `kstar_mono_context`; S1 = `mixKnee_le_two_mul_kstar_context`;
S2 = `bump_factor_two_is_sharp`; S3 = `mixKnee_le_kstar_inflated` together with
`minority_squeeze` and the exact instance `mixKnee_lightMinority_eq_six`.

Analyst: the failure mode of cycle 1 was to read the empirical `25/75 = pure` cell as a
statement about *block counts*.  Under the sup-convolution model that reading is false
(the interior plateau covers all key-count ratios); the honest correction is that the
cell is a statement about *mass*, and cycle 2 proves the corrected version.  This is a
"needs a different definition" outcome, resolved.

Critic: `mixKnee_le_kstar_inflated` carries the hypothesis that the inflated gate is
still `≤ 1`; without it the bound is false, because a pure-`a` head can no longer clear
the gate on its own — the hypothesis is exactly the mass condition, so nothing is hidden.
The sharpness theorem uses an equality, not an estimate, so the constant `2` cannot be
improved.
-/

namespace AttentionBudget

open Finset

variable {a b : ℕ → ℝ} {m l : ℕ} {τ : ℝ}

/-! ## The knee is monotone in the context length -/

/-- Retained mass at a fixed budget can only fall as the context grows. -/
lemma retained_antitone_context (ha : ∀ i, 0 < a i) {n n' k : ℕ} (hn : 0 < n) (h : n ≤ n') :
    retained a n' k ≤ retained a n k := by
  have hpos : 0 < headMass a n := headMass_pos ha hn
  have hpos' : 0 < headMass a n' := headMass_pos ha (by omega)
  rcases le_or_gt k n with hkn | hnk
  · rw [retained, retained, min_eq_left hkn, min_eq_left (by omega : k ≤ n')]
    exact div_le_div_of_nonneg_left (headMass_nonneg ha k) hpos (headMass_mono ha h)
  · have h1 : retained a n k = 1 := by
      rw [retained, min_eq_right (by omega : n ≤ k), div_self hpos.ne']
    rw [h1]
    exact retained_le_one ha n' k (by omega)

/-- **S4 — the knee grows with the context.**  A longer context can only need a larger
budget, for every profile and every gate. -/
theorem kstar_mono_context (ha : ∀ i, 0 < a i) {n n' : ℕ} (hn : 0 < n) (h : n ≤ n')
    (hτ : τ ≤ 1) : kstar a n τ ≤ kstar a n' τ := by
  have hpass : τ ≤ retained a n' (kstar a n' τ) :=
    gate_le_retained_kstar ha (by omega) hτ
  exact kstar_le_of_pass (le_trans hpass (retained_antitone_context ha hn h))

/-! ## The bump has a hard ceiling of two -/

/-- **S1 — the factor-two ceiling.**  A balanced self-mixture never needs more than twice
the budget of the pure context of the same total length. -/
theorem mixKnee_le_two_mul_kstar_context (ha : ∀ i, 0 < a i) (hm : 0 < m) (hτ : τ ≤ 1) :
    mixKnee a a m m τ ≤ 2 * kstar a (2 * m) τ := by
  have h1 := (balanced_selfmix_sandwich ha hm hτ).2
  have h2 : kstar a m τ ≤ kstar a (2 * m) τ :=
    kstar_mono_context ha hm (by omega) hτ
  omega

/-- **S2 — the ceiling is attained.**  For the geometric profile the balanced mixture of
two contexts of `N ≥ 16` keys costs exactly twice the pure budget on the context of
length `2N`, so the constant `2` in the ceiling cannot be improved. -/
theorem bump_factor_two_is_sharp {N : ℕ} (hN : 16 ≤ N) :
    mixKnee geomHalf geomHalf N N (0.98 : ℝ) = 2 * kstar geomHalf (2 * N) (0.98 : ℝ) := by
  rw [mixKnee_geomHalf_eq_twelve hN hN, kstar_geomHalf_eq_six (by omega)]

/-! ## Turning the bump off: mass, not block count -/

/-- **S3 — a light domain can be ignored.**  Serving only the heavy domain, to a gate
inflated by the total-to-heavy mass ratio, already clears the mixed gate. -/
theorem mixKnee_le_kstar_inflated (ha : ∀ i, 0 < a i) (hb : ∀ i, 0 < b i) (hm : 0 < m)
    (hl : 0 < l) (hgate : τ * mixTotal a b m l / headMass a m ≤ 1) :
    mixKnee a b m l τ ≤ kstar a m (τ * mixTotal a b m l / headMass a m) := by
  set T := mixTotal a b m l with hT
  set S := headMass a m with hS
  have hSpos : 0 < S := headMass_pos ha hm
  have hTpos : 0 < T := mixTotal_pos ha hb hm hl
  set kA := kstar a m (τ * T / S) with hkA
  have hpass : τ * T / S ≤ retained a m kA := gate_le_retained_kstar ha hm hgate
  have hhead : τ * T ≤ headMass a (min kA m) := by
    rw [retained, le_div_iff₀ hSpos, div_mul_eq_mul_div, mul_div_assoc, div_self hSpos.ne',
      mul_one] at hpass
    exact hpass
  refine mixKnee_le_of_pass (k := kA) ?_
  have hsplit := le_mixHead a b m l (j := kA) (k := kA) le_rfl
  rw [Nat.sub_self] at hsplit
  have hb0 : headMass b (min 0 l) = 0 := by simp [headMass]
  rw [hb0, add_zero] at hsplit
  rw [mixRetained, le_div_iff₀ hTpos]
  linarith

/-- **The shoulders of the bump.**  The mixed knee is squeezed between two pure knees of
the heavy domain whose gates both tend to `τ` as the minority mass tends to zero. -/
theorem minority_squeeze (ha : ∀ i, 0 < a i) (hb : ∀ i, 0 < b i) (hm : 0 < m) (hl : 0 < l)
    (hτ : τ ≤ 1) (hgate : τ * mixTotal a b m l / headMass a m ≤ 1) :
    kstar a m (τ - (1 - τ) * (headMass b l / headMass a m)) ≤ mixKnee a b m l τ ∧
      mixKnee a b m l τ ≤ kstar a m (τ * mixTotal a b m l / headMass a m) := by
  refine ⟨le_trans ?_ (add_kstar_le_mixKnee ha hb hm hl hτ), mixKnee_le_kstar_inflated ha hb hm hl hgate⟩
  omega

/-! ## An explicit light minority: half the keys, none of the bump -/

/-- A second domain with the same shape but a thousandth of the mass. -/
noncomputable def geomLight : ℕ → ℝ := fun i => (1 / 1000 : ℝ) * (1 / 2 : ℝ) ^ i

lemma geomLight_pos : ∀ i, 0 < geomLight i := fun i => by
  show (0 : ℝ) < (1 / 1000 : ℝ) * (1 / 2 : ℝ) ^ i
  positivity

lemma headMass_geomLight (n : ℕ) :
    headMass geomLight n = (1 / 1000 : ℝ) * (2 * (1 - (1 / 2 : ℝ) ^ n)) := by
  rw [← headMass_geomHalf]
  simp only [headMass, geomLight, geomHalf, Finset.mul_sum]

lemma headMass_geomLight_lt (n : ℕ) : headMass geomLight n < 1 / 500 := by
  rw [headMass_geomLight]
  have : (0 : ℝ) < (1 / 2 : ℝ) ^ n := by positivity
  linarith

lemma headMass_geomLight_pos {n : ℕ} (hn : 0 < n) : 0 < headMass geomLight n :=
  headMass_pos geomLight_pos hn

/-- The budget `5` cannot clear the gate against a heavy geometric domain plus a light
companion. -/
lemma mixHead_light_five {m l : ℕ} (hm : 16 ≤ m) (hl : 16 ≤ l) :
    mixHead geomHalf geomLight m l 5 ≤ 97 / 50 := by
  refine mixHead_le fun j hj => ?_
  have h1 : min j m = j := min_eq_left (by omega)
  have h2 : min (5 - j) l = 5 - j := min_eq_left (by omega)
  rw [h1, h2, headMass_geomHalf, headMass_geomLight]
  interval_cases j <;> norm_num

/-- **Mass, not blocks.**  A mixture whose minority domain holds *half of all keys* but
only a thousandth of the mass has knee exactly `6` — the pure value — even though the
mass-balanced mixture with the very same key counts has knee `12`. -/
theorem mixKnee_lightMinority_eq_six {m l : ℕ} (hm : 16 ≤ m) (hl : 16 ≤ l) :
    mixKnee geomHalf geomLight m l (0.98 : ℝ) = 6 := by
  have hm0 : 0 < m := by omega
  have hl0 : 0 < l := by omega
  have htot : 0 < mixTotal geomHalf geomLight m l :=
    mixTotal_pos geomHalf_pos geomLight_pos hm0 hl0
  have hlowm : 2 * (1 - (1 / 2 : ℝ) ^ 16) ≤ headMass geomHalf m := headMass_geomHalf_ge hm
  have hhm : headMass geomHalf m < 2 := headMass_geomHalf_lt_two m
  have hlowl : 0 < headMass geomLight l := headMass_geomLight_pos hl0
  have hhl : headMass geomLight l < 1 / 500 := headMass_geomLight_lt l
  have h6 : headMass geomHalf 6 = 63 / 32 := by rw [headMass_geomHalf]; norm_num
  norm_num at hlowm
  have hpass : (0.98 : ℝ) ≤ mixRetained geomHalf geomLight m l 6 := by
    have hsplit := le_mixHead geomHalf geomLight m l (j := 6) (k := 6) le_rfl
    rw [min_eq_left (by omega : 6 ≤ m), Nat.sub_self, show min 0 l = 0 from Nat.zero_min l,
      h6, show headMass geomLight 0 = 0 by simp [headMass], add_zero] at hsplit
    rw [mixRetained, le_div_iff₀ htot, mixTotal]
    norm_num
    linarith
  have hfail : mixRetained geomHalf geomLight m l 5 < (0.98 : ℝ) := by
    have hub := mixHead_light_five hm hl
    rw [mixRetained, div_lt_iff₀ htot, mixTotal]
    norm_num
    linarith
  have h1 : mixKnee geomHalf geomLight m l (0.98 : ℝ) ≤ 6 := mixKnee_le_of_pass hpass
  have h2 : 5 < mixKnee geomHalf geomLight m l (0.98 : ℝ) :=
    lt_mixKnee_of_fail geomHalf_pos geomLight_pos hm0 hl0 (by norm_num) hfail
  omega

/-- **The ratio response is a bump with shoulders.**  At fixed key counts `N + N`:
a mass-light second domain leaves the knee at the pure value `6`, while a mass-balanced
second domain lifts it to `12`.  Hence the mixing-ratio response is controlled by the
domains' mass balance, and both the plateau and the shoulders are realised. -/
theorem net90_bump_with_shoulders {N : ℕ} (hN : 16 ≤ N) :
    mixKnee geomHalf geomHalf (2 * N) 0 (0.98 : ℝ) = 6 ∧
      mixKnee geomHalf geomLight N N (0.98 : ℝ) = 6 ∧
      mixKnee geomHalf geomHalf N N (0.98 : ℝ) = 12 := by
  refine ⟨?_, mixKnee_lightMinority_eq_six hN hN, mixKnee_geomHalf_eq_twelve hN hN⟩
  rw [mixKnee_pure_right geomHalf_pos]
  exact kstar_geomHalf_eq_six (by omega)

end AttentionBudget