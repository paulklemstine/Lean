import Mathlib
import Catalog.NumberTheory.ProfileFormResidualPeak

/-!
# Profile form VIII: the hump-location law

Stage-5 result of the cycle: we close the main open conjecture left by
`ProfileFormUniformMixturePeak` (Direction 1 of `FUTURE_DIRECTIONS.md`).

`ProfileFormUniformMixturePeak` exhibited a hump of the uniform-mixture residual
`R(x) = T(x)/M(x)` near `x ≈ 10` for the measured exponent `b = 11/10`, and
observed numerically that the hump sits near `1/(b-1) ≈ 9.6`.  Here that
observation becomes a theorem.

Write `T(x) = (1+x)^{-b}` and `M(x) = (1 - e^{-x})/x`.  Then exactly

  `R(x) = tailResidual b x / (1 - e^{-x})`,   `tailResidual b x = x (1+x)^{-b}`,

and the second factor tends to `1`, so the *shape* of `R` far from the origin is
governed by the elementary function `tailResidual`.  Its logarithmic derivative

  `d/dx log (x (1+x)^{-b}) = 1/x - b/(1+x) = (1 - (b-1)x) / (x(1+x))`

changes sign exactly once, at

  `x* = 1/(b-1)`,

for every `b > 1`.  This gives:

* `tailResidual_strictMonoOn` / `tailResidual_strictAntiOn` — strict increase on
  `[0, x*]`, strict decrease on `[x*, ∞)`;
* `tailResidual_unique_max` — `x*` is the *unique* maximiser on `[0,∞)`;
* `humpLocation_eleven_tenths` — the closed form `x* = 1/(b-1)` is exactly `10`
  at the measured exponent `b = 11/10`, matching the numerically located hump;
* `uniformResidual_hump_confined` — a quantitative transfer to the true
  residual: outside the set where `tailResidual` is within a factor
  `1 - e^{-x₀}` of its maximum, the true residual is strictly below its value at
  `x*`.  So the hump of `R` really is confined near `1/(b-1)`.

The law is a genuine *dichotomy* with the `b = 1` threshold of
`ProfileFormExponentThreshold`: for `b ≤ 1` no such maximiser exists,
`tailResidual` being then increasing throughout (`tailResidual_strictMono_of_le_one`).
So the same exponent-one threshold that decides the total window mass also
decides whether a hump exists at all — and the reported bootstrap interval
`[0.991, 1.218]` straddles it.
-/

namespace ProfileForm

open Set Filter Topology

/-- The **tail residual**: the elementary shape `x (1+x)^{-b}` obtained from the
uniform-mixture residual `T/M` by dropping the factor `1/(1 - e^{-x}) → 1`. -/
noncomputable def tailResidual (b x : ℝ) : ℝ := x * (1 + x) ^ (-b)

/-- The **hump location** `x* = 1/(b-1)`. -/
noncomputable def humpLocation (b : ℝ) : ℝ := 1 / (b - 1)

theorem tailResidual_zero (b : ℝ) : tailResidual b 0 = 0 := by
  simp [tailResidual]

theorem tailResidual_pos {b x : ℝ} (hx : 0 < x) : 0 < tailResidual b x := by
  have h1 : (0:ℝ) < 1 + x := by linarith
  exact mul_pos hx (Real.rpow_pos_of_pos h1 _)

/-- The exact derivative: the sign is that of `1 - (b-1)x`. -/
theorem tailResidual_hasDerivAt (b : ℝ) {x : ℝ} (hx : -1 < x) :
    HasDerivAt (tailResidual b) ((1 + x) ^ (-b - 1) * (1 - (b - 1) * x)) x := by
  have h1 : (0:ℝ) < 1 + x := by linarith
  have hne : (1 + x) ≠ 0 := ne_of_gt h1
  have hg : HasDerivAt (fun y : ℝ => 1 + y) 1 x := by
    simpa using (hasDerivAt_id x).const_add 1
  have hp : HasDerivAt (fun y : ℝ => (1 + y) ^ (-b)) ((-b) * (1 + x) ^ (-b - 1) * 1) x :=
    (Real.hasDerivAt_rpow_const (p := -b) (Or.inl hne)).comp x hg
  have hmul := (hasDerivAt_id x).mul hp
  convert hmul using 1
  have hsplit : (1 + x) ^ (-b) = (1 + x) ^ (-b - 1) * (1 + x) := by
    rw [← Real.rpow_add_one hne (-b - 1)]; ring_nf
  simp only [id]
  rw [hsplit]; ring

theorem tailResidual_deriv (b : ℝ) {x : ℝ} (hx : -1 < x) :
    deriv (tailResidual b) x = (1 + x) ^ (-b - 1) * (1 - (b - 1) * x) :=
  (tailResidual_hasDerivAt b hx).deriv

theorem tailResidual_continuousOn (b : ℝ) : ContinuousOn (tailResidual b) (Ici (0:ℝ)) := by
  intro x hx
  have h1 : (0:ℝ) < 1 + x := by simp only [mem_Ici] at hx; linarith
  refine ContinuousAt.continuousWithinAt (ContinuousAt.mul continuousAt_id ?_)
  exact (Real.continuousAt_rpow_const _ _ (Or.inl (ne_of_gt h1))).comp (by fun_prop)

theorem humpLocation_pos {b : ℝ} (hb : 1 < b) : 0 < humpLocation b := by
  have hb1 : (0:ℝ) < b - 1 := by linarith
  exact div_pos one_pos hb1

/-- `x*` is exactly where the derivative vanishes. -/
theorem tailResidual_deriv_humpLocation {b : ℝ} (hb : 1 < b) :
    deriv (tailResidual b) (humpLocation b) = 0 := by
  have hb1 : (0:ℝ) < b - 1 := by linarith
  have hx : -1 < humpLocation b := lt_trans (by norm_num) (humpLocation_pos hb)
  rw [tailResidual_deriv b hx, humpLocation]
  have h : (b - 1) * (1 / (b - 1)) = 1 := by field_simp
  rw [h]; ring

theorem tailResidual_strictMonoOn {b : ℝ} (hb : 1 < b) :
    StrictMonoOn (tailResidual b) (Icc 0 (humpLocation b)) := by
  have hb1 : (0:ℝ) < b - 1 := by linarith
  refine strictMonoOn_of_deriv_pos (convex_Icc _ _)
    ((tailResidual_continuousOn b).mono (Icc_subset_Ici_self)) ?_
  intro x hx
  rw [interior_Icc] at hx
  obtain ⟨hx0, hx1⟩ := hx
  have hxm : -1 < x := by linarith
  rw [tailResidual_deriv b hxm]
  have hpos : (0:ℝ) < (1 + x) ^ (-b - 1) := Real.rpow_pos_of_pos (by linarith) _
  have hlt : (b - 1) * x < 1 := by
    have hx1' : x < 1 / (b - 1) := by simpa [humpLocation] using hx1
    have := (lt_div_iff₀ hb1).mp hx1'
    linarith [this]
  exact mul_pos hpos (by linarith)

theorem tailResidual_strictAntiOn {b : ℝ} (hb : 1 < b) :
    StrictAntiOn (tailResidual b) (Ici (humpLocation b)) := by
  have hb1 : (0:ℝ) < b - 1 := by linarith
  have hsub : Ici (humpLocation b) ⊆ Ici (0:ℝ) :=
    Ici_subset_Ici.mpr (le_of_lt (humpLocation_pos hb))
  refine strictAntiOn_of_deriv_neg (convex_Ici _)
    ((tailResidual_continuousOn b).mono hsub) ?_
  intro x hx
  rw [interior_Ici] at hx
  have hx0 : 0 < x := lt_trans (humpLocation_pos hb) hx
  have hxm : -1 < x := by linarith
  rw [tailResidual_deriv b hxm]
  have hpos : (0:ℝ) < (1 + x) ^ (-b - 1) := Real.rpow_pos_of_pos (by linarith) _
  have hgt : 1 < (b - 1) * x := by
    have hx1' : 1 / (b - 1) < x := by simpa [humpLocation] using hx
    have h := (div_lt_iff₀ hb1).mp hx1'
    linarith [h]
  exact mul_neg_of_pos_of_neg hpos (by linarith)

/-- **Hump-location law.**  For every exponent `b > 1` the tail residual has a
unique maximiser on `[0,∞)`, and it sits at `x* = 1/(b-1)`. -/
theorem tailResidual_unique_max {b : ℝ} (hb : 1 < b) {x : ℝ} (hx : 0 ≤ x)
    (hne : x ≠ humpLocation b) :
    tailResidual b x < tailResidual b (humpLocation b) := by
  have hstar := humpLocation_pos hb
  rcases lt_or_gt_of_ne hne with h | h
  · exact tailResidual_strictMonoOn hb ⟨hx, le_of_lt h⟩ ⟨le_of_lt hstar, le_refl _⟩ h
  · exact tailResidual_strictAntiOn hb (mem_Ici.mpr (le_refl _)) (mem_Ici.mpr (le_of_lt h)) h

theorem tailResidual_isMaxOn {b : ℝ} (hb : 1 < b) :
    IsMaxOn (tailResidual b) (Ici (0:ℝ)) (humpLocation b) := by
  intro x hx
  simp only [Set.mem_setOf_eq]
  rcases eq_or_ne x (humpLocation b) with rfl | hne
  · exact le_refl _
  · exact le_of_lt (tailResidual_unique_max hb (mem_Ici.mp hx) hne)

/-- For the measured exponent `b = 11/10` the law predicts the hump at exactly
`x = 10`, which is where `ProfileFormUniformMixturePeak` located it. -/
theorem humpLocation_eleven_tenths : humpLocation (11/10) = 10 := by
  norm_num [humpLocation]

/-- **Dichotomy at the exponent-one threshold.**  For `b ≤ 1` the tail residual
is strictly increasing on `[0,∞)`, so no hump exists at all. -/
theorem tailResidual_strictMono_of_le_one {b : ℝ} (hb : b ≤ 1) :
    StrictMonoOn (tailResidual b) (Ici (0:ℝ)) := by
  refine strictMonoOn_of_deriv_pos (convex_Ici _) (tailResidual_continuousOn b) ?_
  intro x hx
  rw [interior_Ici] at hx
  have hxm : -1 < x := by simp only [mem_Ioi] at hx; linarith
  rw [tailResidual_deriv b hxm]
  have hpos : (0:ℝ) < (1 + x) ^ (-b - 1) := Real.rpow_pos_of_pos (by linarith) _
  have hx0 : 0 < x := hx
  have : (b - 1) * x ≤ 0 := mul_nonpos_of_nonpos_of_nonneg (by linarith) (le_of_lt hx0)
  exact mul_pos hpos (by linarith)

/-! ### Transfer to the true uniform-mixture residual -/

/-- Exact factorisation of the uniform-mixture residual. -/
theorem residual_eq_tailResidual_div {b x : ℝ} (hx : 0 < x) :
    powerProfile 1 b x / dickmanMixtureBaseline x
      = tailResidual b x / (1 - Real.exp (-x)) := by
  have hden : 1 - Real.exp (-x) ≠ 0 := by
    have : Real.exp (-x) < 1 := by
      rw [Real.exp_lt_one_iff]; linarith
    linarith
  rw [powerProfile, dickmanMixtureBaseline, tailResidual]
  field_simp

theorem one_sub_exp_neg_pos {x : ℝ} (hx : 0 < x) : 0 < 1 - Real.exp (-x) := by
  have : Real.exp (-x) < 1 := by rw [Real.exp_lt_one_iff]; linarith
  linarith

theorem one_sub_exp_neg_lt_one {x : ℝ} : 1 - Real.exp (-x) < 1 := by
  have := Real.exp_pos (-x); linarith

/-- Lower sandwich: the true residual always dominates the tail residual. -/
theorem tailResidual_le_residual {b x : ℝ} (hx : 0 < x) :
    tailResidual b x ≤ powerProfile 1 b x / dickmanMixtureBaseline x := by
  rw [residual_eq_tailResidual_div hx]
  rw [le_div_iff₀ (one_sub_exp_neg_pos hx)]
  nlinarith [tailResidual_pos (b := b) hx, one_sub_exp_neg_lt_one (x := x),
    one_sub_exp_neg_pos hx]

/-- Upper sandwich on a window bounded away from the origin. -/
theorem residual_le_tailResidual_div {b x₀ x : ℝ} (hx₀ : 0 < x₀) (hx : x₀ ≤ x) :
    powerProfile 1 b x / dickmanMixtureBaseline x
      ≤ tailResidual b x / (1 - Real.exp (-x₀)) := by
  have hxpos : 0 < x := lt_of_lt_of_le hx₀ hx
  rw [residual_eq_tailResidual_div hxpos]
  refine div_le_div_of_nonneg_left (le_of_lt (tailResidual_pos hxpos))
    (one_sub_exp_neg_pos hx₀) ?_
  have : Real.exp (-x) ≤ Real.exp (-x₀) := Real.exp_le_exp.mpr (by linarith)
  linarith

/-- **The hump of the true residual is confined near `x* = 1/(b-1)`.**

If a point `x ≥ x₀ > 0` is so far out that the *elementary* tail residual has
already dropped below the fraction `1 - e^{-x₀}` of its maximum, then the true
uniform-mixture residual at `x` is strictly below its value at `x*`.  Since
`1 - e^{-x₀} → 1` as `x₀` grows, the localisation is asymptotically sharp. -/
theorem uniformResidual_hump_confined {b x₀ x : ℝ} (hb : 1 < b) (hx₀ : 0 < x₀) (hx : x₀ ≤ x)
    (hgap : tailResidual b x < (1 - Real.exp (-x₀)) * tailResidual b (humpLocation b)) :
    powerProfile 1 b x / dickmanMixtureBaseline x
      < powerProfile 1 b (humpLocation b) / dickmanMixtureBaseline (humpLocation b) := by
  have hstarpos : 0 < humpLocation b := humpLocation_pos hb
  have hden : 0 < 1 - Real.exp (-x₀) := one_sub_exp_neg_pos hx₀
  calc powerProfile 1 b x / dickmanMixtureBaseline x
      ≤ tailResidual b x / (1 - Real.exp (-x₀)) :=
        residual_le_tailResidual_div hx₀ hx
    _ < tailResidual b (humpLocation b) := by
        rw [div_lt_iff₀ hden]; linarith [hgap]
    _ ≤ powerProfile 1 b (humpLocation b) / dickmanMixtureBaseline (humpLocation b) :=
        tailResidual_le_residual hstarpos

/-- The confinement hypothesis is not vacuous: it holds for all large `x`,
because for `b > 1` the tail residual tends to `0` at infinity. -/
theorem tailResidual_tendsto_zero {b : ℝ} (hb : 1 < b) :
    Tendsto (tailResidual b) atTop (𝓝 0) := by
  have hpow : Tendsto (fun x : ℝ => (1 + x) ^ (1 - b)) atTop (𝓝 0) := by
    have h := tendsto_rpow_neg_atTop (y := b - 1) (by linarith)
    have hadd : Tendsto (fun x : ℝ => 1 + x) atTop atTop :=
      tendsto_atTop_add_const_left _ 1 tendsto_id
    simpa [show -(b - 1) = 1 - b by ring] using h.comp hadd
  refine squeeze_zero' (Filter.eventually_ge_atTop (0:ℝ) |>.mono ?_)
    (Filter.eventually_ge_atTop (0:ℝ) |>.mono ?_) hpow
  · intro x hx
    have h1 : (0:ℝ) < 1 + x := by linarith
    exact mul_nonneg hx (Real.rpow_pos_of_pos h1 _).le
  · intro x hx
    have h1 : (0:ℝ) < 1 + x := by linarith
    have hle : x * (1 + x) ^ (-b) ≤ (1 + x) * (1 + x) ^ (-b) := by
      have := (Real.rpow_pos_of_pos h1 (-b)).le
      nlinarith [Real.rpow_pos_of_pos h1 (-b)]
    have heq : (1 + x) * (1 + x) ^ (-b) = (1 + x) ^ (1 - b) := by
      rw [show (1:ℝ) - b = 1 + (-b) by ring, Real.rpow_add h1, Real.rpow_one]
    simpa [tailResidual] using hle.trans heq.le

/-- **Existence of a confining window.**  For every `b > 1` and every `x₀ > 0`
there is a threshold beyond which the true residual is provably below its value
at the hump location: the hump is genuinely localised. -/
theorem uniformResidual_hump_confined_eventually {b x₀ : ℝ} (hb : 1 < b) (hx₀ : 0 < x₀) :
    ∀ᶠ x in atTop,
      powerProfile 1 b x / dickmanMixtureBaseline x
        < powerProfile 1 b (humpLocation b) / dickmanMixtureBaseline (humpLocation b) := by
  have hden : 0 < 1 - Real.exp (-x₀) := one_sub_exp_neg_pos hx₀
  have hmax : 0 < tailResidual b (humpLocation b) :=
    tailResidual_pos (humpLocation_pos hb)
  have hpos : 0 < (1 - Real.exp (-x₀)) * tailResidual b (humpLocation b) := mul_pos hden hmax
  have hgap := (tailResidual_tendsto_zero hb).eventually (eventually_lt_nhds hpos)
  filter_upwards [hgap, Filter.eventually_ge_atTop x₀] with x hx hxx
  exact uniformResidual_hump_confined hb hx₀ hxx hx

end ProfileForm