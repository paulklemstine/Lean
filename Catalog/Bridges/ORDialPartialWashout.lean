import Mathlib
import Bridges.ORDialCap
import Bridges.ORDialMaximum
import Bridges.ORDialClassification
import Bridges.ORDialCharacter
import Bridges.ORDialWashoutInvariance
import Bridges.ORDialCharacterWashout

/-!
# Partial washout: the dial is a strictly monotone function of the character contrast

`Bridges.ORDialWashoutInvariance` and `Bridges.ORDialWashoutParity` describe the two
extremes of multiplier randomisation: the dial either stays at the cap `orCap` or collapses
to `0`.  This file fills in the whole interval between them and turns the qualitative
dichotomy into a *continuous degradation law* — direction 1 of the previous cycle's
`FUTURE_DIRECTIONS.md`.

For an index-two kernel `K` with quadratic character `χ = quadChar K` and a contrast
parameter `t`, consider the one-parameter family of class-rate profiles

`charProfile K t a = (1 + t · χ a) / 2`,

which interpolates between the constant profile `t = 0` (all information gone) and the
coset indicator `t = 1` (the maximiser).  The main results are:

* `noFork_charProfile`: the conditional no-fork probability is exactly
  `(1 + t² χ(c))/4` — the contrast enters *squared*, because the fork event pairs two
  independent draws;
* `orInfo_charProfile`: hence `orInfo (charProfile K t) = dialAt (t²)` where
  `dialAt u = H(1/4) − ½(H((1+u)/4) + H((1−u)/4))` is a group-free one-dimensional
  function;
* `dialAt_strictMonoOn`: `dialAt` is strictly increasing on `[0,1]`, by strict concavity of
  the binary entropy (the two evaluation points spread apart as `u` grows), with
  `dialAt 0 = 0` and `dialAt 1 = orCap`;
* `orInfo_charProfile_strictMono` and `orInfo_charProfile_lt_orCap`: the dial reads a
  strictly increasing function of the contrast `|t|`, and is strictly below the cap
  whenever `|t| < 1`.

Finally `mix_charProfile_of_le` and `mix_charProfile_of_not_le` show that multiplier
randomisation by a subgroup `H` acts on this family by `t ↦ t` (if `H ≤ K`) or `t ↦ 0`
(if `H ⊄ K`): the earlier dichotomy is exactly the statement that a *subgroup* multiplier
can only realise the two endpoints of the continuum, while the continuum itself is real.
-/

open Real Finset

namespace ORDial

section OneDimensional

/-- The dial value as a function of the squared character contrast `u = t²`. -/
noncomputable def dialAt (u : ℝ) : ℝ :=
  Real.binEntropy (1/4) - (Real.binEntropy ((1+u)/4) + Real.binEntropy ((1-u)/4)) / 2

@[simp] lemma dialAt_zero : dialAt 0 = 0 := by
  simp [dialAt]

lemma dialAt_one : dialAt 1 = orCap := by
  have h2 : Real.binEntropy ((1:ℝ)/2) = Real.log 2 := by
    rw [show (1:ℝ)/2 = 2⁻¹ by norm_num]; exact Real.binEntropy_two_inv
  rw [dialAt, orCap]
  norm_num [h2]

/-- **Strict monotonicity of the degradation law.**  A larger character contrast gives a
strictly larger dial value: the two entropy evaluation points `(1±u)/4` spread apart, and
the binary entropy is strictly concave. -/
theorem dialAt_strictMonoOn : StrictMonoOn dialAt (Set.Icc (0:ℝ) 1) := by
  rintro u ⟨hu0, hu1⟩ v ⟨hv0, hv1⟩ huv
  have hvpos : 0 < v := lt_of_le_of_lt hu0 huv
  have hxmem : (1+v)/4 ∈ Set.Icc (0:ℝ) 1 := ⟨by linarith, by linarith⟩
  have hymem : (1-v)/4 ∈ Set.Icc (0:ℝ) 1 := ⟨by linarith, by linarith⟩
  have hxy : (1+v)/4 ≠ (1-v)/4 := by intro h; linarith
  have hq : u / v * v = u := div_mul_cancel₀ u hvpos.ne'
  have hlam0 : 0 < (1 + u/v)/2 := by
    have : 0 ≤ u/v := div_nonneg hu0 hvpos.le
    linarith
  have hlam1 : 0 < 1 - (1 + u/v)/2 := by
    have : u/v < 1 := (div_lt_one hvpos).mpr huv
    linarith
  have h1 := Real.strictConcave_binEntropy.2 hxmem hymem hxy hlam0 hlam1 (by ring)
  have h2 := Real.strictConcave_binEntropy.2 hxmem hymem hxy hlam1 hlam0 (by ring)
  simp only [smul_eq_mul] at h1 h2
  rw [show (1 + u/v)/2 * ((1+v)/4) + (1 - (1 + u/v)/2) * ((1-v)/4) = (1+u)/4 from by
    linear_combination (1/4) * hq] at h1
  rw [show (1 - (1 + u/v)/2) * ((1+v)/4) + (1 + u/v)/2 * ((1-v)/4) = (1-u)/4 from by
    linear_combination (-1/4) * hq] at h2
  rw [dialAt, dialAt]
  linarith

lemma dialAt_lt_orCap {u : ℝ} (hu0 : 0 ≤ u) (hu1 : u < 1) : dialAt u < orCap := by
  have := dialAt_strictMonoOn ⟨hu0, hu1.le⟩ (Set.right_mem_Icc.mpr zero_le_one) hu1
  rwa [dialAt_one] at this

lemma dialAt_pos {u : ℝ} (hu : 0 < u) (hu1 : u ≤ 1) : 0 < dialAt u := by
  have := dialAt_strictMonoOn (Set.left_mem_Icc.mpr zero_le_one) ⟨hu.le, hu1⟩ hu
  rwa [dialAt_zero] at this

end OneDimensional

section Profile

variable {G : Type*} [Fintype G] [CommGroup G]

/-- The contrast-`t` character profile attached to an index-two kernel `K`. -/
noncomputable def charProfile (K : Subgroup G) (t : ℝ) : G → ℝ :=
  fun a => (1 + t * quadChar K a) / 2

omit [Fintype G] in
lemma quadChar_sq (K : Subgroup G) (a : G) : quadChar K a * quadChar K a = 1 := by
  rcases quadChar_values K a with h | h <;> rw [h] <;> norm_num

omit [Fintype G] in
lemma quadChar_mul (K : Subgroup G) (h : K.index = 2) (a b : G) :
    quadChar K (a * b) = quadChar K a * quadChar K b := by
  simpa using (quadCharHom K h).map_mul a b

omit [Fintype G] in
lemma quadChar_inv (K : Subgroup G) (h : K.index = 2) (a : G) :
    quadChar K a⁻¹ = quadChar K a := by
  have h1 : quadChar K a * quadChar K a⁻¹ = 1 := by
    have hmm := quadChar_mul K h a a⁻¹
    rw [mul_inv_cancel] at hmm
    have h1 : quadChar K (1 : G) = 1 := by classical simp [quadChar]
    rw [h1] at hmm
    exact hmm.symm
  rcases quadChar_values K a with ha | ha <;> rw [ha] at h1 ⊢ <;> linarith

omit [Fintype G] in
lemma charProfile_nonneg (K : Subgroup G) {t : ℝ} (ht : |t| ≤ 1) (a : G) :
    0 ≤ charProfile K t a := by
  have h1 : -1 ≤ t := neg_le_of_abs_le ht
  have h2 : t ≤ 1 := le_of_abs_le ht
  rcases quadChar_values K a with h | h <;> rw [charProfile, h] <;> linarith

omit [Fintype G] in
lemma charProfile_le_one (K : Subgroup G) {t : ℝ} (ht : |t| ≤ 1) (a : G) :
    charProfile K t a ≤ 1 := by
  have h1 : -1 ≤ t := neg_le_of_abs_le ht
  have h2 : t ≤ 1 := le_of_abs_le ht
  rcases quadChar_values K a with h | h <;> rw [charProfile, h] <;> linarith

omit [Fintype G] in
/-- Contrast `1` is exactly the coset indicator of the earlier files: the family really
interpolates the known maximiser. -/
lemma charProfile_one (K : Subgroup G) : charProfile K 1 = subgroupProfile K := by
  funext a
  rw [charProfile, subgroupProfile_eq_quadChar]
  ring

lemma avg_charProfile (K : Subgroup G) (hK : K.index = 2) (t : ℝ) :
    avg (charProfile K t) = 1/2 := by
  have hrw : charProfile K t = fun a => 1/2 + (t/2) * quadChar K a := by
    funext a; rw [charProfile]; ring
  rw [hrw, avg_affine, avg_quadChar_eq_zero K hK]
  ring

/-- **The contrast enters squared.**  The conditional no-fork probability of the
contrast-`t` profile is `(1 + t² χ(c))/4`. -/
lemma noFork_charProfile (K : Subgroup G) (hK : K.index = 2) (t : ℝ) (c : G) :
    noFork (charProfile K t) c = (1 + t^2 * quadChar K c) / 4 := by
  have hpt : ∀ a : G, charProfile K t a * charProfile K t (c * a⁻¹)
      = (1 + t^2 * quadChar K c) / 4 + (t * (1 + quadChar K c) / 4) * quadChar K a := by
    intro a
    have hmul : quadChar K (c * a⁻¹) = quadChar K c * quadChar K a := by
      rw [quadChar_mul K hK, quadChar_inv K hK]
    have hsq := quadChar_sq K a
    rw [charProfile, charProfile, hmul]
    linear_combination (t^2 * quadChar K c / 4) * hsq
  have hstep : noFork (charProfile K t) c
      = avg (fun a => (1 + t^2 * quadChar K c) / 4
          + (t * (1 + quadChar K c) / 4) * quadChar K a) := by
    rw [noFork]; exact congrArg avg (funext hpt)
  rw [hstep, avg_affine, avg_quadChar_eq_zero K hK]
  ring

/-- Averaging a function of a `±1` character over the group reads its two values equally
often. -/
lemma avg_of_quadChar (K : Subgroup G) (hK : K.index = 2) (F : ℝ → ℝ) :
    avg (fun c => F (quadChar K c)) = (F 1 + F (-1)) / 2 := by
  have hpt : ∀ c : G, F (quadChar K c)
      = (F 1 + F (-1)) / 2 + ((F 1 - F (-1)) / 2) * quadChar K c := by
    intro c
    rcases quadChar_values K c with h | h <;> rw [h] <;> ring
  have hstep : avg (fun c => F (quadChar K c))
      = avg (fun c => (F 1 + F (-1)) / 2 + ((F 1 - F (-1)) / 2) * quadChar K c) :=
    congrArg avg (funext hpt)
  rw [hstep, avg_affine, avg_quadChar_eq_zero K hK]
  ring

/-- **The dial of the contrast-`t` profile is the one-dimensional law at `t²`.** -/
theorem orInfo_charProfile (K : Subgroup G) (hK : K.index = 2) (t : ℝ) :
    orInfo (charProfile K t) = dialAt (t^2) := by
  have hfork : (fun c => Real.binEntropy (noFork (charProfile K t) c))
      = fun c => (fun x => Real.binEntropy ((1 + t^2 * x) / 4)) (quadChar K c) := by
    funext c; rw [noFork_charProfile K hK]
  rw [orInfo, avg_charProfile K hK, hfork,
    avg_of_quadChar K hK (fun x => Real.binEntropy ((1 + t^2 * x) / 4)), dialAt]
  norm_num
  ring_nf

/-- **The continuous degradation law.**  On `0 ≤ t ≤ 1` the dial is a strictly increasing
function of the character contrast. -/
theorem orInfo_charProfile_strictMono (K : Subgroup G) (hK : K.index = 2) {t t' : ℝ}
    (ht0 : 0 ≤ t) (htt : t < t') (ht1 : t' ≤ 1) :
    orInfo (charProfile K t) < orInfo (charProfile K t') := by
  rw [orInfo_charProfile K hK, orInfo_charProfile K hK]
  refine dialAt_strictMonoOn ⟨by positivity, by nlinarith⟩ ⟨by positivity, by nlinarith⟩ ?_
  nlinarith

/-- Any contrast strictly below `1` is strictly below the cap: partial randomisation is
already a strict loss, and total randomisation (`t = 0`) reads exactly `0`. -/
theorem orInfo_charProfile_lt_orCap (K : Subgroup G) (hK : K.index = 2) {t : ℝ}
    (ht : |t| < 1) : orInfo (charProfile K t) < orCap := by
  rw [orInfo_charProfile K hK]
  refine dialAt_lt_orCap (by positivity) ?_
  have h1 : -1 < t := neg_lt_of_abs_lt ht
  have h2 : t < 1 := lt_of_abs_lt ht
  nlinarith

/-- The two endpoints: contrast `1` is the maximiser and contrast `0` the constant
profile. -/
theorem orInfo_charProfile_endpoints (K : Subgroup G) (hK : K.index = 2) :
    orInfo (charProfile K 1) = orCap ∧ orInfo (charProfile K 0) = 0 := by
  refine ⟨?_, ?_⟩
  · rw [orInfo_charProfile K hK]; norm_num [dialAt_one]
  · rw [orInfo_charProfile K hK]; norm_num

/-- Consistency with the earlier maximum theorem: evaluating the degradation law at
contrast `1` reproduces `orInfo_index_two_eq_orCap`. -/
theorem orInfo_subgroupProfile_eq_dialAt_one (K : Subgroup G) (hK : K.index = 2) :
    orInfo (subgroupProfile K) = dialAt 1 := by
  rw [← charProfile_one K, orInfo_charProfile K hK]
  norm_num

/-! ## Multiplier randomisation only realises the endpoints -/

open Classical in
/-- A multiplier group inside the kernel leaves the profile — hence the contrast —
untouched. -/
theorem mix_charProfile_of_le (K H : Subgroup G) (hK : K.index = 2) (t : ℝ) (hHK : H ≤ K) :
    mix H (charProfile K t) = charProfile K t := by
  classical
  funext a
  have hcard : (0:ℝ) < (Nat.card H : ℝ) := card_subgroup_pos H
  have hterm : ∀ g : G, (if g ∈ H then charProfile K t (g * a) else 0)
      = charProfile K t a * (if g ∈ H then (1:ℝ) else 0) := by
    intro g
    by_cases hg : g ∈ H
    · have hchar : quadChar K (g * a) = quadChar K a := by
        rw [quadChar_mul K hK, quadChar_eq_one_iff.mpr (hHK hg), one_mul]
      rw [if_pos hg, if_pos hg, charProfile, charProfile, hchar]
      ring
    · rw [if_neg hg, if_neg hg]; ring
  rw [mix, Finset.sum_congr rfl fun g _ => hterm g, ← Finset.mul_sum,
    sum_indicator_subgroup H]
  field_simp

open Classical in
/-- A multiplier group escaping the kernel drives the contrast to `0`: the randomised
profile is the constant `1/2`, i.e. `charProfile K 0`. -/
theorem mix_charProfile_of_not_le (K H : Subgroup G) (hK : K.index = 2) (t : ℝ)
    (hHK : ¬ H ≤ K) : mix H (charProfile K t) = charProfile K 0 := by
  classical
  have hconst : charProfile K 0 = fun _ : G => (1:ℝ)/2 := by
    funext a; rw [charProfile]; ring
  rw [hconst]
  funext a
  have hcard : (0:ℝ) < (Nat.card H : ℝ) := card_subgroup_pos H
  have hterm : ∀ g : G, (if g ∈ H then charProfile K t (g * a) else 0)
      = (1/2) * (if g ∈ H then (1:ℝ) else 0)
        + (t * quadChar K a / 2) * (if g ∈ H then quadChar K g else 0) := by
    intro g
    by_cases hg : g ∈ H
    · rw [if_pos hg, if_pos hg, if_pos hg, charProfile, quadChar_mul K hK]
      ring
    · rw [if_neg hg, if_neg hg, if_neg hg]; ring
  rw [mix, Finset.sum_congr rfl fun g _ => hterm g, Finset.sum_add_distrib, ← Finset.mul_sum,
    ← Finset.mul_sum, sum_indicator_subgroup H, sum_quadChar_over_subgroup K H hK hHK]
  field_simp
  ring

/-- **The dichotomy is the endpoint statement of a genuine continuum.**  Subgroup
multipliers move the contrast only between `t` and `0`, yet every intermediate contrast is
realised by an admissible profile with the same mean rate as the maximiser and a strictly
intermediate dial value. -/
theorem partial_washout_continuum (K : Subgroup G) (hK : K.index = 2) {t : ℝ}
    (ht0 : 0 < t) (ht1 : t < 1) :
    (∀ a, 0 ≤ charProfile K t a) ∧ (∀ a, charProfile K t a ≤ 1) ∧
      avg (charProfile K t) = avg (charProfile K 1) ∧
      0 < orInfo (charProfile K t) ∧ orInfo (charProfile K t) < orCap := by
  have habs : |t| ≤ 1 := by rw [abs_of_pos ht0]; exact ht1.le
  refine ⟨charProfile_nonneg K habs, charProfile_le_one K habs, ?_, ?_, ?_⟩
  · rw [avg_charProfile K hK, avg_charProfile K hK]
  · rw [orInfo_charProfile K hK]
    exact dialAt_pos (by positivity) (by nlinarith)
  · exact orInfo_charProfile_lt_orCap K hK (by rw [abs_of_pos ht0]; exact ht1)

end Profile

end ORDial