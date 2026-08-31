import Mathlib
import Physics.TDialU108BandLoss

/-!
# U108 deepening: angle metric, sharpness of the plateau window, and the rapidity group

## Research context

Second cycle of the round-69 #2 thread (`TDIAL-U108-CONTINUES-FADE`, exp 544).  The first file
`Physics.TDialU108BandLoss` established

* the exact gap between the Gram and advantage decorrelation certificates,
* a plateau-localisation theorem for a decelerating fade, instantiated at U108 to the window
  `[0.4362, 0.488]`,
* Fisher-`z` (= rapidity) pooling bounds showing that seed heterogeneity cannot lift the
  pooled reading back into the `0.55` band.

Three questions were left open by that file, and are settled here.

1. **Is the plateau window sharp?**  `u108_plateau_window` only gives an inclusion; maybe the
   lower edge is an artefact of the estimate.  `plateau_window_edge_attained` and
   `u108_lower_edge_attained` construct the exact geometric fade that realises the edge, so
   no better bound is derivable from a single rung plus the ratio hypothesis.
2. **Is the pooling inflation strict?**  `fisherPool2_gt_mean_of_ne` upgrades the inequality
   to a strict one exactly when the seeds disagree — this is what makes "first seed
   heterogeneity of the ladder" a *quantitative* remark rather than a qualitative one.
3. **What is the geometry underneath the Gram certificate?**  `corr_angle_triangle` shows the
   correlation angle `arccos` is a genuine (pseudo)metric: the dial/baseline angle is at most
   the sum of the two angles to the rate.  The band floor is then a *radius*, and the fade is
   motion of the dial away from the rate on the correlation sphere.

Additionally `fisherAdd_group` records that correlations under Einstein/Fisher composition
form an abelian group isomorphic to the additive reals (rapidity), and
`fisherAdd_can_exceed_floor` marks the boundary: *composition* of two sub-floor correlations
can exceed the floor, so only the *mean* (rapidity-average) form of pooling is floor
preserving — the guarded version of the "heterogeneity cannot rescue the band" claim.
-/

namespace Catalog.Physics.TDialU108

open Real Set Filter

/-! ## Section 1. Sharpness of the plateau window -/

/-- The exact geometric fade with initial value `s₀`, initial step `d₀` and ratio `r`. -/
noncomputable def geoFade (s0 d0 r : ℝ) : ℕ → ℝ := fun n => (s0 - d0 / (1 - r)) + (d0 / (1 - r)) * r ^ n

/-- **The plateau window edge is attained.**  For every admissible ratio `r ∈ [0,1)` and every
nonnegative initial step `d₀`, the geometric fade is antitone, decelerates with ratio exactly
`r`, reproduces the two measured values `s₀` and `s₀ − d₀`, and converges to precisely
`s₀ − d₀/(1−r)` — the lower edge of the window of `u108_plateau_window`.  Hence no bound better
than `dₙ/(1−r)` can be derived from one rung plus the ratio hypothesis. -/
theorem plateau_window_edge_attained (s0 d0 r : ℝ) (hr0 : 0 ≤ r) (hr1 : r < 1) (hd : 0 ≤ d0) :
    geoFade s0 d0 r 0 = s0 ∧ geoFade s0 d0 r 1 = s0 - d0 ∧
      (∀ n, geoFade s0 d0 r (n + 1) ≤ geoFade s0 d0 r n) ∧
      (∀ n, geoFade s0 d0 r (n + 1) - geoFade s0 d0 r (n + 2)
          = r * (geoFade s0 d0 r n - geoFade s0 d0 r (n + 1))) ∧
      Tendsto (geoFade s0 d0 r) atTop (nhds (s0 - d0 / (1 - r))) := by
  have h1r : 0 < 1 - r := by linarith
  have hA : 0 ≤ d0 / (1 - r) := div_nonneg hd h1r.le
  refine ⟨by simp [geoFade], ?_, ?_, ?_, ?_⟩
  · simp only [geoFade, pow_one]
    field_simp
    ring
  · intro n
    have hstep : geoFade s0 d0 r n - geoFade s0 d0 r (n + 1)
        = (d0 / (1 - r)) * r ^ n * (1 - r) := by
      simp only [geoFade, pow_succ]; ring
    have : 0 ≤ (d0 / (1 - r)) * r ^ n * (1 - r) := by positivity
    linarith
  · intro n
    simp only [geoFade, pow_succ]
    ring
  · have hpow : Tendsto (fun n : ℕ => r ^ n) atTop (nhds 0) :=
      tendsto_pow_atTop_nhds_zero_of_lt_one hr0 hr1
    have h := ((hpow.const_mul (d0 / (1 - r))).const_add (s0 - d0 / (1 - r)))
    simpa [geoFade] using h

/-- **The U108 lower edge is exactly attained.**  With the measured `s₀ = 0.488`,
`d₀ = 0.0259` and the boundary ratio `r = 1/2`, the geometric fade converges to exactly
`0.4362`: the lower edge of the U108 plateau window is realised, not merely a bound. -/
theorem u108_lower_edge_attained :
    Tendsto (geoFade 0.488 0.0259 (1/2)) atTop (nhds 0.4362) := by
  have h := plateau_window_edge_attained 0.488 0.0259 (1/2) (by norm_num) (by norm_num)
    (by norm_num)
  have hval : (0.488 : ℝ) - 0.0259 / (1 - 1/2) = 0.4362 := by norm_num
  rw [hval] at h
  exact h.2.2.2.2

/-! ## Section 2. Strict inflation from heterogeneity -/

/-- Strict midpoint concavity of `tanh` on `(0, ∞)`: spreading the rapidities strictly lowers
the average of the correlations. -/
theorem tanh_midpoint_gt (m d : ℝ) (hm : 0 < m) (hd : d ≠ 0) :
    Real.tanh (m + d) + Real.tanh (m - d) < 2 * Real.tanh m := by
  have hden : Real.cosh (m + d) * Real.cosh (m - d) = Real.cosh m ^ 2 + Real.sinh d ^ 2 := by
    rw [Real.cosh_add, Real.cosh_sub]
    linear_combination (Real.cosh m ^ 2) * (Real.cosh_sq_sub_sinh_sq d)
      + (Real.sinh d ^ 2) * (Real.cosh_sq_sub_sinh_sq m)
  have hnum : Real.sinh (m + d) * Real.cosh (m - d) + Real.sinh (m - d) * Real.cosh (m + d)
      = 2 * Real.sinh m * Real.cosh m := by
    rw [Real.sinh_add, Real.sinh_sub, Real.cosh_add, Real.cosh_sub]
    linear_combination (2 * Real.sinh m * Real.cosh m) * (Real.cosh_sq_sub_sinh_sq d)
  have hcp : ∀ x : ℝ, 0 < Real.cosh x := Real.cosh_pos
  have hlhs : Real.tanh (m + d) + Real.tanh (m - d)
      = (2 * Real.sinh m * Real.cosh m) / (Real.cosh m ^ 2 + Real.sinh d ^ 2) := by
    rw [Real.tanh_eq_sinh_div_cosh, Real.tanh_eq_sinh_div_cosh,
      div_add_div _ _ (hcp _).ne' (hcp _).ne', hden.symm, ← hnum]
    ring_nf
  have hrhs : 2 * Real.tanh m = (2 * Real.sinh m * Real.cosh m) / (Real.cosh m ^ 2) := by
    rw [Real.tanh_eq_sinh_div_cosh]; field_simp
  rw [hlhs, hrhs]
  have hsm : 0 < Real.sinh m := Real.sinh_pos_iff.mpr hm
  have hsn : 0 < 2 * Real.sinh m * Real.cosh m := by positivity
  have hsd : 0 < Real.sinh d ^ 2 := by
    have : Real.sinh d ≠ 0 := fun h => hd (Real.sinh_eq_zero.mp h)
    positivity
  have hc2 : 0 < Real.cosh m ^ 2 := by positivity
  exact div_lt_div_of_pos_left hsn hc2 (by linarith)

/-- Strict two-point form. -/
theorem tanh_two_point_strict (u v : ℝ) (hu : 0 ≤ u) (hv : 0 ≤ v) (hne : u ≠ v) :
    Real.tanh u + Real.tanh v < 2 * Real.tanh ((u + v) / 2) := by
  have hm : 0 < (u + v) / 2 := by
    rcases lt_or_gt_of_ne hne with h | h <;> linarith
  have hd : (u - v) / 2 ≠ 0 := by
    intro h
    apply hne
    have : u - v = 0 := by linarith [h]
    linarith
  have h := tanh_midpoint_gt ((u + v) / 2) ((u - v) / 2) hm hd
  have e1 : (u + v) / 2 + (u - v) / 2 = u := by ring
  have e2 : (u + v) / 2 - (u - v) / 2 = v := by ring
  rwa [e1, e2] at h

/-- **Strict heterogeneity inflation.**  If two nonnegative seed correlations differ, the
Fisher-pooled value is *strictly* above their arithmetic mean.  Equality holds only for
homogeneous seeds, so the ladder's first heterogeneous rung is also the first rung whose
pooled reading is strictly optimistic relative to the seed average. -/
theorem fisherPool2_gt_mean_of_ne {x y : ℝ} (hx0 : 0 ≤ x) (hx1 : x < 1) (hy0 : 0 ≤ y)
    (hy1 : y < 1) (hne : x ≠ y) :
    (x + y) / 2 < fisherPool2 x y := by
  have hxm : x ∈ Ioo (-1:ℝ) 1 := ⟨by linarith, hx1⟩
  have hym : y ∈ Ioo (-1:ℝ) 1 := ⟨by linarith, hy1⟩
  have hane : artanh x ≠ artanh y := fun h => hne (by
    have := congrArg Real.tanh h
    rwa [Real.tanh_artanh hxm, Real.tanh_artanh hym] at this)
  have h := tanh_two_point_strict (artanh x) (artanh y) (Real.artanh_nonneg hx0)
    (Real.artanh_nonneg hy0) hane
  rw [Real.tanh_artanh hxm, Real.tanh_artanh hym] at h
  rw [fisherPool2]
  linarith

/-! ## Section 3. The correlation angle is a metric -/

/-- The correlation angle `arccos c` between two standardised variables. -/
noncomputable def corrAngle (c : ℝ) : ℝ := Real.arccos c

/-- Two-sided Gram bound: the dial/baseline correlation is trapped in the interval cut out by
the two correlations with the rate. -/
theorem corr_two_sided {a b c : ℝ}
    (hdet : 0 ≤ 1 + 2 * a * b * c - a ^ 2 - b ^ 2 - c ^ 2) :
    a * b - √((1 - a ^ 2) * (1 - b ^ 2)) ≤ c ∧ c ≤ a * b + √((1 - a ^ 2) * (1 - b ^ 2)) := by
  have h : (c - a * b) ^ 2 ≤ (1 - a ^ 2) * (1 - b ^ 2) := by nlinarith [sq_nonneg (c - a * b)]
  have habs : |c - a * b| ≤ √((1 - a ^ 2) * (1 - b ^ 2)) := by
    rw [← Real.sqrt_sq_eq_abs]
    exact Real.sqrt_le_sqrt h
  have h1 := neg_abs_le (c - a * b)
  have h2 := le_abs_self (c - a * b)
  constructor <;> linarith

/-- **Triangle inequality for the correlation angle.**  Gram positivity of the `3×3`
correlation matrix is *equivalent in content* to the statement that `arccos ∘ corr` obeys the
triangle inequality: the angle between the dial `T` and the count baseline is at most the sum
of their angles to the rate.  Correlations therefore live on a sphere, and the `0.55` band
floor is a spherical cap around the rate. -/
theorem corr_angle_triangle {a b c : ℝ} (ha : |a| ≤ 1) (hb : |b| ≤ 1)
    (hdet : 0 ≤ 1 + 2 * a * b * c - a ^ 2 - b ^ 2 - c ^ 2) :
    corrAngle c ≤ corrAngle a + corrAngle b := by
  obtain ⟨ha1, ha2⟩ := abs_le.1 ha
  obtain ⟨hb1, hb2⟩ := abs_le.1 hb
  rcases le_or_gt π (Real.arccos a + Real.arccos b) with hbig | hsmall
  · exact le_trans (Real.arccos_le_pi c) hbig
  · have hlow := (corr_two_sided hdet).1
    have hsa : Real.sin (Real.arccos a) = √(1 - a ^ 2) := Real.sin_arccos a
    have hsb : Real.sin (Real.arccos b) = √(1 - b ^ 2) := Real.sin_arccos b
    have hca : Real.cos (Real.arccos a) = a := Real.cos_arccos ha1 ha2
    have hcb : Real.cos (Real.arccos b) = b := Real.cos_arccos hb1 hb2
    have hsplit : √((1 - a ^ 2) * (1 - b ^ 2)) = √(1 - a ^ 2) * √(1 - b ^ 2) :=
      Real.sqrt_mul (by nlinarith) _
    have hcos : Real.cos (Real.arccos a + Real.arccos b) ≤ c := by
      rw [Real.cos_add, hca, hcb, hsa, hsb, ← hsplit]
      linarith
    by_contra hcon
    push_neg at hcon
    have hsum0 : 0 ≤ Real.arccos a + Real.arccos b :=
      add_nonneg (Real.arccos_nonneg a) (Real.arccos_nonneg b)
    have hlt : Real.cos (Real.arccos c) < Real.cos (Real.arccos a + Real.arccos b) := by
      refine Real.strictAntiOn_cos ⟨hsum0, hsmall.le⟩
        ⟨Real.arccos_nonneg c, Real.arccos_le_pi c⟩ ?_
      exact hcon
    have hsa2 : a ^ 2 ≤ 1 := by nlinarith
    have hsb2 : b ^ 2 ≤ 1 := by nlinarith
    have hAM : √((1 - a ^ 2) * (1 - b ^ 2)) ≤ ((1 - a ^ 2) + (1 - b ^ 2)) / 2 := by
      have h := Real.sqrt_le_sqrt
        (show (1 - a ^ 2) * (1 - b ^ 2) ≤ (((1 - a ^ 2) + (1 - b ^ 2)) / 2) ^ 2 by
          nlinarith [sq_nonneg (a ^ 2 - b ^ 2)])
      rwa [Real.sqrt_sq (by linarith)] at h
    have hup := (corr_two_sided hdet).2
    have hc' : Real.cos (Real.arccos c) = c :=
      Real.cos_arccos (by nlinarith [sq_nonneg (a + b)]) (by nlinarith [sq_nonneg (a - b)])
    rw [hc'] at hlt
    linarith

/-- **The U108 angle reading.**  The dial sits at angle `arccos 0.488` from the rate and the
baseline at `arccos 0.396`; the triangle inequality bounds the dial/baseline angle by their
sum, and the band floor `0.55` is the cap of radius `arccos 0.55` — which the dial has left,
since `arccos` is strictly antitone. -/
theorem u108_angle_outside_cap : corrAngle 0.55 < corrAngle 0.488 := by
  refine Real.strictAntiOn_arccos ⟨by norm_num, by norm_num⟩ ⟨by norm_num, by norm_num⟩ ?_
  norm_num

/-! ## Section 4. The rapidity group, and the boundary of the pooling claim -/

/-- Einstein/Fisher composition is commutative. -/
theorem fisherAdd_comm (x y : ℝ) : fisherAdd x y = fisherAdd y x := by
  unfold fisherAdd; rw [add_comm x y, mul_comm x y]

/-- `0` is the identity for composition. -/
theorem fisherAdd_zero (x : ℝ) : fisherAdd x 0 = x := by
  unfold fisherAdd; norm_num

/-- Negation is the inverse for composition. -/
theorem fisherAdd_neg_self (x : ℝ) : fisherAdd x (-x) = 0 := by
  unfold fisherAdd; simp

/-- **Associativity of Einstein/Fisher composition**, proved by transport along the rapidity
isomorphism `artanh : (-1,1) ≃ ℝ` rather than by brute-force algebra. -/
theorem fisherAdd_assoc {x y z : ℝ} (hx : x ∈ Ioo (-1:ℝ) 1) (hy : y ∈ Ioo (-1:ℝ) 1)
    (hz : z ∈ Ioo (-1:ℝ) 1) :
    fisherAdd (fisherAdd x y) z = fisherAdd x (fisherAdd y z) := by
  have hxy : fisherAdd x y ∈ Ioo (-1:ℝ) 1 := fisherAdd_mem_Ioo hx hy
  have hyz : fisherAdd y z ∈ Ioo (-1:ℝ) 1 := fisherAdd_mem_Ioo hy hz
  have e1 : artanh (fisherAdd x y) = artanh x + artanh y := by
    rw [← tanh_artanh_add hx hy, Real.artanh_tanh]
  have e2 : artanh (fisherAdd y z) = artanh y + artanh z := by
    rw [← tanh_artanh_add hy hz, Real.artanh_tanh]
  rw [← tanh_artanh_add hxy hz, ← tanh_artanh_add hx hyz, e1, e2, add_assoc]

/-- **Boundary of the pooling claim.**  Fisher-`z` *composition* is not `z`-*averaging*: two
seeds well below the `0.55` floor compose to a value above it.  Only the mean form
(`fisherPool2`, `fisherPool3`) is floor preserving, which is why
`pool_below_floor_of_seeds_below_floor` is stated for the mean. -/
theorem fisherAdd_can_exceed_floor :
    (0.4 : ℝ) < 0.55 ∧ (0.55 : ℝ) < fisherAdd 0.4 0.4 := by
  refine ⟨by norm_num, ?_⟩
  unfold fisherAdd
  rw [lt_div_iff₀ (by norm_num)]
  norm_num

/-- The two pooling operations at the same input: averaging stays below the floor while
composition does not.  This is the sharpest statement of the "heterogeneity cannot rescue the
band, but boosting can" dichotomy. -/
theorem pool_vs_compose_dichotomy :
    fisherPool2 0.4 0.4 < 0.55 ∧ (0.55 : ℝ) < fisherAdd 0.4 0.4 := by
  refine ⟨?_, fisherAdd_can_exceed_floor.2⟩
  have hm : (0.4 : ℝ) ∈ Ioo (-1:ℝ) 1 := ⟨by norm_num, by norm_num⟩
  have : fisherPool2 (0.4 : ℝ) 0.4 = 0.4 := by
    unfold fisherPool2
    rw [show (artanh (0.4:ℝ) + artanh (0.4:ℝ)) / 2 = artanh (0.4:ℝ) by ring]
    exact Real.tanh_artanh hm
  rw [this]; norm_num

end Catalog.Physics.TDialU108