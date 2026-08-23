/-
# Concavity of the Lagrange exponent on the physical range `[1/27, ∞)`

Building on `Novelty.LagrangeExponentCore`, where the **Lagrange exponent**

  `σ t = (1 + ∛(27 t - 1)) / 3`

was introduced as the inverse of the critical cubic `h y = y³ - y² + y/3`
(`h y = ((3y-1)³ + 1)/27`), this file proves the main structural theorem of the
programme and pins down its exact boundary.

## Main results

* `lagrangeExponent_concaveOn` — `σ` is concave on `Set.Ici (1/27)`;
* `lagrangeExponent_strictConcaveOn` — in fact *strictly* concave there;
* `lagrangeExponent_midpoint_concave` — the midpoint form: averaging two masses
  never decreases the growth rate, `(σ s + σ t)/2 ≤ σ ((s+t)/2)`;
* `lagrangeExponent_jensen` — the finite Jensen form for an arbitrary weighted
  average of masses;
* `lagrangeExponent_strictConvexOn_Iic` — below the critical mass the behaviour is
  *reversed*: `σ` is strictly convex on `Set.Iic (1/27)`;
* `lagrangeExponent_not_concaveOn_Ici` — consequently `1/27` is the **exact**
  threshold: for every `a < 1/27`, `σ` fails to be concave on `Set.Ici a`.
  (Adversarial check: the theorem is not vacuously "concave everywhere".)
* `lagrangeExponent_hasDerivAt` — the derivative `σ' t = 3 (27t-1)^(-2/3)` above the
  critical mass, together with `lagrangeExponent_deriv_antitoneOn`, the analytic
  shadow of concavity.
* `three_mass_prod_le_inv27` / `lagrangeExponent_mass_prod_le_third` — the bridge to
  mass distributions: by AM–GM a three–point distribution has product at most `1/27`,
  which is precisely the critical mass, so `1/27` is not an arbitrary constant.

## Structure of the proof

Because `h' y = 3 (y - 1/3)²` vanishes only at `y = 1/3`, the cubic is an affine shift
of a pure cube and `σ` is an affine shift of `x ↦ x^(1/3)`.  Concavity on
`[1/27, ∞)` is therefore the concavity of `x ↦ x^(1/3)` on `[0, ∞)` transported by the
increasing affine change of variables `t ↦ 27 t - 1`; convexity on `(-∞, 1/27]` is the
same statement transported by the *decreasing* affine map `t ↦ 1 - 27 t`, whose sign flip
reverses the inequality.  The inflection at `t = 1/27` is exactly the image of the
degenerate critical point `y = 1/3`.
-/
import Novelty.LagrangeExponentCore

namespace LagrangeExponent

open Set

/-! ## Concavity above the critical mass -/

/-- **Main theorem.** The Lagrange exponent is concave on the physical range `[1/27, ∞)`:
averaging two mass parameters never decreases the growth rate. -/
theorem lagrangeExponent_concaveOn : ConcaveOn ℝ (Ici (1 / 27 : ℝ)) lagrangeExponent := by
  refine ⟨convex_Ici _, ?_⟩
  intro x hx y hy a b ha hb hab
  simp only [mem_Ici] at hx hy
  simp only [smul_eq_mul]
  have hu : (0 : ℝ) ≤ 27 * x - 1 := by linarith
  have hv : (0 : ℝ) ≤ 27 * y - 1 := by linarith
  have harg : 27 * (a * x + b * y) - 1 = a * (27 * x - 1) + b * (27 * y - 1) := by
    have : a + b = 1 := hab
    nlinarith [this]
  have hmix : (0 : ℝ) ≤ a * (27 * x - 1) + b * (27 * y - 1) :=
    add_nonneg (mul_nonneg ha hu) (mul_nonneg hb hv)
  have key := (Real.concaveOn_rpow (p := (1 : ℝ) / 3) (by norm_num) (by norm_num)).2
      (mem_Ici.2 hu) (mem_Ici.2 hv) ha hb hab
  simp only [smul_eq_mul] at key
  unfold lagrangeExponent
  rw [harg, cbrt_of_nonneg hu, cbrt_of_nonneg hv, cbrt_of_nonneg hmix]
  nlinarith [key, hab]

/-- **Strict** concavity above the critical mass: distinct masses give a *strict* gain. -/
theorem lagrangeExponent_strictConcaveOn :
    StrictConcaveOn ℝ (Ici (1 / 27 : ℝ)) lagrangeExponent := by
  refine ⟨convex_Ici _, ?_⟩
  intro x hx y hy hxy a b ha hb hab
  simp only [mem_Ici] at hx hy
  simp only [smul_eq_mul]
  have hu : (0 : ℝ) ≤ 27 * x - 1 := by linarith
  have hv : (0 : ℝ) ≤ 27 * y - 1 := by linarith
  have hne : 27 * x - 1 ≠ 27 * y - 1 := by
    intro h; exact hxy (by linarith)
  have harg : 27 * (a * x + b * y) - 1 = a * (27 * x - 1) + b * (27 * y - 1) := by
    have : a + b = 1 := hab
    nlinarith [this]
  have hmix : (0 : ℝ) ≤ a * (27 * x - 1) + b * (27 * y - 1) :=
    add_nonneg (mul_nonneg ha.le hu) (mul_nonneg hb.le hv)
  have key := (Real.strictConcaveOn_rpow (p := (1 : ℝ) / 3) (by norm_num) (by norm_num)).2
      (mem_Ici.2 hu) (mem_Ici.2 hv) hne ha hb hab
  simp only [smul_eq_mul] at key
  unfold lagrangeExponent
  rw [harg, cbrt_of_nonneg hu, cbrt_of_nonneg hv, cbrt_of_nonneg hmix]
  nlinarith [key, hab]

/-- **Midpoint form.** Averaging two mass distributions never decreases the growth rate. -/
theorem lagrangeExponent_midpoint_concave {s t : ℝ} (hs : 1 / 27 ≤ s) (ht : 1 / 27 ≤ t) :
    (lagrangeExponent s + lagrangeExponent t) / 2 ≤ lagrangeExponent ((s + t) / 2) := by
  have h := lagrangeExponent_concaveOn.2 (mem_Ici.2 hs) (mem_Ici.2 ht)
      (by norm_num : (0:ℝ) ≤ 1/2) (by norm_num : (0:ℝ) ≤ 1/2) (by norm_num)
  simp only [smul_eq_mul] at h
  have harg : (1 : ℝ) / 2 * s + 1 / 2 * t = (s + t) / 2 := by ring
  rw [harg] at h
  linarith

/-- Strict midpoint gain for distinct masses. -/
theorem lagrangeExponent_midpoint_strict {s t : ℝ} (hs : 1 / 27 ≤ s) (ht : 1 / 27 ≤ t)
    (hst : s ≠ t) :
    (lagrangeExponent s + lagrangeExponent t) / 2 < lagrangeExponent ((s + t) / 2) := by
  have h := lagrangeExponent_strictConcaveOn.2 (mem_Ici.2 hs) (mem_Ici.2 ht) hst
      (by norm_num : (0:ℝ) < 1/2) (by norm_num : (0:ℝ) < 1/2) (by norm_num)
  simp only [smul_eq_mul] at h
  have harg : (1 : ℝ) / 2 * s + 1 / 2 * t = (s + t) / 2 := by ring
  rw [harg] at h
  linarith

/-- **Jensen form.** An arbitrary weighted average of admissible masses never decreases the
growth rate. -/
theorem lagrangeExponent_jensen {ι : Type*} (T : Finset ι) (w : ι → ℝ) (m : ι → ℝ)
    (hw : ∀ i ∈ T, 0 ≤ w i) (hw1 : ∑ i ∈ T, w i = 1) (hm : ∀ i ∈ T, 1 / 27 ≤ m i) :
    (∑ i ∈ T, w i * lagrangeExponent (m i)) ≤ lagrangeExponent (∑ i ∈ T, w i * m i) := by
  have := lagrangeExponent_concaveOn.le_map_sum (t := T) (w := w) (p := m) hw hw1
    (fun i hi => mem_Ici.2 (hm i hi))
  simpa only [smul_eq_mul] using this

/-! ## Convexity below the critical mass, and sharpness of the threshold -/

/-- Below the critical mass the curvature is **reversed**: `σ` is strictly convex on
`(-∞, 1/27]`. -/
theorem lagrangeExponent_strictConvexOn_Iic :
    StrictConvexOn ℝ (Iic (1 / 27 : ℝ)) lagrangeExponent := by
  refine ⟨convex_Iic _, ?_⟩
  intro x hx y hy hxy a b ha hb hab
  simp only [mem_Iic] at hx hy
  simp only [smul_eq_mul]
  have hu : (0 : ℝ) ≤ 1 - 27 * x := by linarith
  have hv : (0 : ℝ) ≤ 1 - 27 * y := by linarith
  have hne : 1 - 27 * x ≠ 1 - 27 * y := by
    intro h; exact hxy (by linarith)
  have harg : 27 * (a * x + b * y) - 1 = -(a * (1 - 27 * x) + b * (1 - 27 * y)) := by
    have : a + b = 1 := hab
    nlinarith [this]
  have hmix : (0 : ℝ) ≤ a * (1 - 27 * x) + b * (1 - 27 * y) :=
    add_nonneg (mul_nonneg ha.le hu) (mul_nonneg hb.le hv)
  have key := (Real.strictConcaveOn_rpow (p := (1 : ℝ) / 3) (by norm_num) (by norm_num)).2
      (mem_Ici.2 hu) (mem_Ici.2 hv) hne ha hb hab
  simp only [smul_eq_mul] at key
  unfold lagrangeExponent
  have hx' : cbrt (27 * x - 1) = -((1 - 27 * x) ^ ((1 : ℝ) / 3)) := by
    have : (27 : ℝ) * x - 1 = -(1 - 27 * x) := by ring
    rw [this, cbrt_neg, cbrt_of_nonneg hu]
  have hy' : cbrt (27 * y - 1) = -((1 - 27 * y) ^ ((1 : ℝ) / 3)) := by
    have : (27 : ℝ) * y - 1 = -(1 - 27 * y) := by ring
    rw [this, cbrt_neg, cbrt_of_nonneg hv]
  rw [harg, cbrt_neg, cbrt_of_nonneg hmix, hx', hy']
  nlinarith [key, hab]

/-- **Sharpness of the threshold.** For every `a < 1/27` the exponent fails to be concave on
`[a, ∞)`: the critical mass `1/27` is the exact left endpoint of the concavity region. -/
theorem lagrangeExponent_not_concaveOn_Ici {a : ℝ} (ha : a < 1 / 27) :
    ¬ ConcaveOn ℝ (Ici a) lagrangeExponent := by
  intro hcon
  have hmem1 : a ∈ Ici a := mem_Ici.2 le_rfl
  have hmem2 : (1 / 27 : ℝ) ∈ Ici a := mem_Ici.2 ha.le
  have hc := hcon.2 hmem1 hmem2 (by norm_num : (0:ℝ) ≤ 1/2) (by norm_num : (0:ℝ) ≤ 1/2)
    (by norm_num)
  have hv := lagrangeExponent_strictConvexOn_Iic.2 (mem_Iic.2 ha.le) (mem_Iic.2 le_rfl)
    (ne_of_lt ha) (by norm_num : (0:ℝ) < 1/2) (by norm_num : (0:ℝ) < 1/2) (by norm_num)
  simp only [smul_eq_mul] at hc hv
  linarith

/-- The mirror statement: `σ` is not convex on any `Iic b` with `1/27 < b`. -/
theorem lagrangeExponent_not_convexOn_Iic {b : ℝ} (hb : 1 / 27 < b) :
    ¬ ConvexOn ℝ (Iic b) lagrangeExponent := by
  intro hcon
  have hmem1 : (1 / 27 : ℝ) ∈ Iic b := mem_Iic.2 hb.le
  have hmem2 : b ∈ Iic b := mem_Iic.2 le_rfl
  have hc := hcon.2 hmem1 hmem2 (by norm_num : (0:ℝ) ≤ 1/2) (by norm_num : (0:ℝ) ≤ 1/2)
    (by norm_num)
  have hv := lagrangeExponent_strictConcaveOn.2 (mem_Ici.2 le_rfl) (mem_Ici.2 hb.le)
    (ne_of_lt hb) (by norm_num : (0:ℝ) < 1/2) (by norm_num : (0:ℝ) < 1/2) (by norm_num)
  simp only [smul_eq_mul] at hc hv
  linarith

/-- **Exact characterisation of the concavity rays.** `σ` is concave on `[c, ∞)` if and only
if `c` is at least the critical mass `1/27`. -/
theorem lagrangeExponent_concaveOn_Ici_iff {c : ℝ} :
    ConcaveOn ℝ (Ici c) lagrangeExponent ↔ 1 / 27 ≤ c := by
  constructor
  · intro hcon
    by_contra hc
    push_neg at hc
    exact lagrangeExponent_not_concaveOn_Ici hc hcon
  · intro hc
    exact lagrangeExponent_concaveOn.subset (Ici_subset_Ici.2 hc) (convex_Ici c)

/-- The mirror characterisation of the convexity rays. -/
theorem lagrangeExponent_convexOn_Iic_iff {c : ℝ} :
    ConvexOn ℝ (Iic c) lagrangeExponent ↔ c ≤ 1 / 27 := by
  constructor
  · intro hcon
    by_contra hc
    push_neg at hc
    exact lagrangeExponent_not_convexOn_Iic hc hcon
  · intro hc
    exact lagrangeExponent_strictConvexOn_Iic.convexOn.subset (Iic_subset_Iic.2 hc) (convex_Iic c)

/-! ## The analytic shadow: the derivative above the critical mass -/

/-- Above the critical mass, `σ` is differentiable with `σ' t = 3 (27 t - 1)^(-2/3)`. -/
theorem lagrangeExponent_hasDerivAt {t : ℝ} (ht : 1 / 27 < t) :
    HasDerivAt lagrangeExponent (3 * (27 * t - 1) ^ (-(2 : ℝ) / 3)) t := by
  have hpos : (0 : ℝ) < 27 * t - 1 := by linarith
  have hlin : HasDerivAt (fun u : ℝ => 27 * u - 1) 27 t := by
    simpa using ((hasDerivAt_id t).const_mul (27 : ℝ)).sub_const 1
  have hrp : HasDerivAt (fun u : ℝ => (27 * u - 1) ^ ((1 : ℝ) / 3))
      (27 * ((1 : ℝ) / 3) * (27 * t - 1) ^ ((1 : ℝ) / 3 - 1)) t :=
    hlin.rpow_const (Or.inl (ne_of_gt hpos))
  have hg : HasDerivAt (fun u : ℝ => (1 + (27 * u - 1) ^ ((1 : ℝ) / 3)) / 3)
      ((27 * ((1 : ℝ) / 3) * (27 * t - 1) ^ ((1 : ℝ) / 3 - 1)) / 3) t :=
    (hrp.const_add 1).div_const 3
  have hval : (27 * ((1 : ℝ) / 3) * (27 * t - 1) ^ ((1 : ℝ) / 3 - 1)) / 3
      = 3 * (27 * t - 1) ^ (-(2 : ℝ) / 3) := by
    have he : (1 : ℝ) / 3 - 1 = -(2 : ℝ) / 3 := by norm_num
    rw [he]; ring
  rw [← hval]
  refine hg.congr_of_eventuallyEq ?_
  have hopen : {u : ℝ | 0 < 27 * u - 1} ∈ nhds t := by
    refine IsOpen.mem_nhds ?_ hpos
    exact isOpen_lt continuous_const (by fun_prop)
  filter_upwards [hopen] with u hu
  unfold lagrangeExponent
  rw [cbrt_of_nonneg hu.le]

/-- The derivative is antitone above the critical mass — the analytic shadow of concavity. -/
theorem lagrangeExponent_deriv_antitoneOn :
    AntitoneOn (fun t : ℝ => 3 * (27 * t - 1) ^ (-(2 : ℝ) / 3)) (Ioi (1 / 27 : ℝ)) := by
  intro x hx y hy hxy
  simp only [mem_Ioi] at hx hy
  have hx' : (0 : ℝ) < 27 * x - 1 := by linarith
  have hy' : (0 : ℝ) < 27 * y - 1 := by linarith
  have hmono : (27 * y - 1) ^ (-(2 : ℝ) / 3) ≤ (27 * x - 1) ^ (-(2 : ℝ) / 3) := by
    apply Real.rpow_le_rpow_of_nonpos hx' (by linarith) (by norm_num)
  linarith

/-! ## Bridge to mass distributions: why `1/27` -/

/-- AM–GM in three variables: a probability vector on three states has product at most
`1/27`, attained only at the uniform distribution. -/
theorem three_mass_prod_le_inv27 {p q r : ℝ} (hp : 0 ≤ p) (hq : 0 ≤ q) (hr : 0 ≤ r)
    (h : p + q + r = 1) : p * q * r ≤ 1 / 27 := by
  nlinarith [sq_nonneg (p - q), sq_nonneg (q - r), sq_nonneg (p - r), sq_nonneg (p + q - 2 * r),
    mul_nonneg hp hq, mul_nonneg hq hr, mul_nonneg hp hr]

/-- Consequently, the *product mass* of any three–point distribution sits at or below the
critical value `1/27`, i.e. its exponent never exceeds the degenerate critical point `1/3`.
This is what singles out `1/27` as the boundary of the physical range. -/
theorem lagrangeExponent_mass_prod_le_third {p q r : ℝ} (hp : 0 ≤ p) (hq : 0 ≤ q) (hr : 0 ≤ r)
    (h : p + q + r = 1) : lagrangeExponent (p * q * r) ≤ 1 / 3 := by
  have := three_mass_prod_le_inv27 hp hq hr h
  calc lagrangeExponent (p * q * r) ≤ lagrangeExponent (1 / 27) :=
        lagrangeExponent_strictMono.monotone this
    _ = 1 / 3 := lagrangeExponent_critical

/-- The uniform distribution realises the boundary case exactly. -/
theorem lagrangeExponent_uniform_mass :
    lagrangeExponent ((1 / 3 : ℝ) * (1 / 3) * (1 / 3)) = 1 / 3 := by
  norm_num

end LagrangeExponent