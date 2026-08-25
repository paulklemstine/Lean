import Pythagorean.EdgeKernelRefinement

/-!
# Separation of the bulk+spike profile from every single power law

`Pythagorean.EdgeKernelRefinement` proved that a two-component positional profile is not a
rescaled single power law *as a density*. This file upgrades the statement in two ways.

1. **Multiplicative strict convexity** (`twoComp_mul_gt_sq`). For every geometric triple
   `1+x₀, 1+x₁, 1+x₂` (i.e. `(1+x₁)² = (1+x₀)(1+x₂)`) a genuine two-component profile
   satisfies the *strict* inequality `f(x₁)² < f(x₀) f(x₂)`, whereas every pure power law
   satisfies it with equality. Consequently no single power law can match a bulk+spike
   profile on *any* nondegenerate subwindow (`twoComp_ne_single_on`) — not just globally.

2. **Cumulative (measurable) level** (`mixFrac_ne_single`). Even the *normalised cumulative*
   statistic separates the families: no exponent `b` reproduces the mixture's edge fraction
   simultaneously at all windows `t ∈ (0,1)`. Since an effective exponent does exist for each
   individual window (`exists_effective_exponent`), the fitted exponent is necessarily
   **window dependent** (`effective_exponent_window_dependent`): fitting the same profile on
   a narrower left window returns a different (steeper) exponent. This is the formal content
   of a "left-half refit steepens the fitted law" observation.

3. **Direction of the drift** (`localExponent_strictAnti`). The exponent reported by a
   log-log slope measurement is *strictly larger on the left half* of any geometric triple
   than on the right half, whereas a pure power law reports the same exponent everywhere
   (`localExponent_single`). So the drift is not merely nonconstant: it steepens toward the
   left edge.
-/

namespace Pythagorean.EdgeKernel

open MeasureTheory Filter Topology

/-! ## Multiplicative strict convexity of a two-component profile -/

/-- Auxiliary: on a geometric triple of bases the kernel is multiplicatively affine. -/
lemma ker_geom (β : ℝ) {x₀ x₁ x₂ : ℝ} (h₀ : 0 ≤ x₀) (h₂ : 0 ≤ x₂)
    (hgeom : (1 + x₁) ^ 2 = (1 + x₀) * (1 + x₂)) (hx₁ : 0 ≤ x₁) :
    ker β x₁ * ker β x₁ = ker β x₀ * ker β x₂ := by
  have hu : (0:ℝ) ≤ 1 + x₀ := by linarith
  have hv : (0:ℝ) ≤ 1 + x₂ := by linarith
  have hm : (1 + x₁) * (1 + x₁) = (1 + x₀) * (1 + x₂) := by nlinarith [hgeom]
  rw [ker, ker, ker, ← Real.mul_rpow (by linarith) (by linarith),
    ← Real.mul_rpow hu hv, hm]

/-- **Strict multiplicative convexity.** On any geometric triple of positions a genuine
two-component profile is strictly log-convex, while a pure power law is log-affine. -/
theorem twoComp_mul_gt_sq {A K b₁ b₂ x₀ x₁ x₂ : ℝ} (hA : 0 < A) (hK : 0 < K) (hb : b₁ ≠ b₂)
    (h₀ : 0 ≤ x₀) (h01 : x₀ < x₁) (h12 : x₁ < x₂)
    (hgeom : (1 + x₁) ^ 2 = (1 + x₀) * (1 + x₂)) :
    twoComp A K b₁ b₂ x₁ * twoComp A K b₁ b₂ x₁
      < twoComp A K b₁ b₂ x₀ * twoComp A K b₁ b₂ x₂ := by
  have hx₁ : 0 ≤ x₁ := le_trans h₀ h01.le
  have hx₂ : 0 ≤ x₂ := le_trans hx₁ h12.le
  have hu : (0:ℝ) < 1 + x₀ := by linarith
  have hv : (0:ℝ) < 1 + x₂ := by linarith
  -- abbreviations
  set a := ker b₁ x₀ with ha
  set a' := ker b₁ x₂ with ha'
  set k := ker b₂ x₀ with hk
  set k' := ker b₂ x₂ with hk'
  set p := ker b₁ x₁ with hp
  set q := ker b₂ x₁ with hq
  have hpp : p * p = a * a' := ker_geom b₁ h₀ hx₂ hgeom hx₁
  have hqq : q * q = k * k' := ker_geom b₂ h₀ hx₂ hgeom hx₁
  have hppos : 0 < p := ker_pos b₁ hx₁
  have hqpos : 0 < q := ker_pos b₂ hx₁
  -- the two cross terms have the same product as `(p*q)^2` but are distinct
  have hcross : (a * k') * (k * a') = (p * q) * (p * q) := by
    calc (a * k') * (k * a') = (a * a') * (k * k') := by ring
      _ = (p * p) * (q * q) := by rw [hpp, hqq]
      _ = (p * q) * (p * q) := by ring
  have hne : a * k' ≠ k * a' := by
    -- strict comparison of the two cross terms, by the sign of `b₂ - b₁`
    have key : ∀ c₁ c₂ : ℝ, c₁ < c₂ →
        ker c₁ x₀ * ker c₂ x₂ < ker c₂ x₀ * ker c₁ x₂ := by
      intro c₁ c₂ hlt
      have hd : (0:ℝ) < c₂ - c₁ := by linarith
      have hbase : (1 + x₂) ^ (-(c₂ - c₁)) < (1 + x₀) ^ (-(c₂ - c₁)) :=
        Real.rpow_lt_rpow_of_neg hu (by linarith) (by linarith)
      have hposmul : 0 < (1 + x₀) ^ (-c₁) * (1 + x₂) ^ (-c₁) := by
        exact mul_pos (Real.rpow_pos_of_pos hu _) (Real.rpow_pos_of_pos hv _)
      have hmul := mul_lt_mul_of_pos_right hbase hposmul
      have e1 : (1 + x₀) ^ (-(c₂ - c₁)) * ((1 + x₀) ^ (-c₁) * (1 + x₂) ^ (-c₁))
          = ker c₂ x₀ * ker c₁ x₂ := by
        rw [ker, ker, ← mul_assoc, ← Real.rpow_add hu]
        ring_nf
      have e2 : (1 + x₂) ^ (-(c₂ - c₁)) * ((1 + x₀) ^ (-c₁) * (1 + x₂) ^ (-c₁))
          = ker c₁ x₀ * ker c₂ x₂ := by
        rw [ker, ker]
        rw [show (1 + x₂) ^ (-(c₂ - c₁)) * ((1 + x₀) ^ (-c₁) * (1 + x₂) ^ (-c₁))
            = (1 + x₀) ^ (-c₁) * ((1 + x₂) ^ (-(c₂ - c₁)) * (1 + x₂) ^ (-c₁)) by ring,
          ← Real.rpow_add hv]
        ring_nf
      rw [e1, e2] at hmul
      exact hmul
    rcases lt_or_gt_of_ne hb with hlt | hgt
    · exact ne_of_lt (key b₁ b₂ hlt)
    · exact ne_of_gt (key b₂ b₁ hgt)
  -- AM-GM, strict because the cross terms differ
  have hPpos : 0 < a * k' := mul_pos (ker_pos b₁ h₀) (ker_pos b₂ hx₂)
  have hQpos : 0 < k * a' := mul_pos (ker_pos b₂ h₀) (ker_pos b₁ hx₂)
  have hAM : 2 * (p * q) < a * k' + k * a' := by
    have hsq : 0 < (a * k' - k * a') ^ 2 := by
      have : a * k' - k * a' ≠ 0 := sub_ne_zero.mpr hne
      positivity
    nlinarith [hcross, mul_pos hppos hqpos, hPpos, hQpos]
  simp only [twoComp, ← ha, ← ha', ← hk, ← hk', ← hp, ← hq]
  have key : (A * a + K * k) * (A * a' + K * k') - (A * p + K * q) * (A * p + K * q)
      = A * K * (a * k' + k * a' - 2 * (p * q)) := by
    linear_combination (-A ^ 2) * hpp - K ^ 2 * hqq
  nlinarith [key, hAM, mul_pos hA hK]

/-- **No single power law on any subwindow.** A genuine two-component profile disagrees with
every rescaled single kernel already on an arbitrary nondegenerate subwindow `[s,e]`. -/
theorem twoComp_ne_single_on {A K b₁ b₂ s e : ℝ} (hA : 0 < A) (hK : 0 < K) (hb : b₁ ≠ b₂)
    (hs : 0 ≤ s) (hse : s < e) :
    ¬ ∃ C b : ℝ, ∀ x ∈ Set.Icc s e, twoComp A K b₁ b₂ x = C * ker b x := by
  rintro ⟨C, b, h⟩
  have hu : (0:ℝ) < 1 + s := by linarith
  have hv : (0:ℝ) < 1 + e := by linarith
  set m : ℝ := Real.sqrt ((1 + s) * (1 + e)) with hm
  have hmsq : m ^ 2 = (1 + s) * (1 + e) := Real.sq_sqrt (by positivity)
  have hmu : 1 + s < m := by
    have : Real.sqrt ((1 + s) * (1 + s)) < Real.sqrt ((1 + s) * (1 + e)) :=
      Real.sqrt_lt_sqrt (by positivity) (by nlinarith)
    rwa [show (1 + s) * (1 + s) = (1 + s) ^ 2 by ring, Real.sqrt_sq (le_of_lt hu)] at this
  have hmv : m < 1 + e := by
    have : Real.sqrt ((1 + s) * (1 + e)) < Real.sqrt ((1 + e) * (1 + e)) :=
      Real.sqrt_lt_sqrt (by positivity) (by nlinarith)
    rwa [show (1 + e) * (1 + e) = (1 + e) ^ 2 by ring, Real.sqrt_sq (le_of_lt hv)] at this
  -- the middle point of the geometric triple
  set x₁ : ℝ := m - 1 with hx₁
  have hgeom : (1 + x₁) ^ 2 = (1 + s) * (1 + e) := by
    rw [hx₁]; simpa using hmsq
  have hstrict := twoComp_mul_gt_sq (A := A) (K := K) (b₁ := b₁) (b₂ := b₂)
    (x₀ := s) (x₁ := x₁) (x₂ := e) hA hK hb hs (by rw [hx₁]; linarith)
    (by rw [hx₁]; linarith) hgeom
  -- but the single law is multiplicatively affine on the same triple
  have hs' := h s ⟨le_rfl, hse.le⟩
  have he' := h e ⟨hse.le, le_rfl⟩
  have hm' := h x₁ ⟨by rw [hx₁]; linarith, by rw [hx₁]; linarith⟩
  have hkg : ker b x₁ * ker b x₁ = ker b s * ker b e :=
    ker_geom b hs (by linarith) hgeom (by rw [hx₁]; linarith)
  rw [hs', he', hm'] at hstrict
  have : C * ker b x₁ * (C * ker b x₁) = C * ker b s * (C * ker b e) := by
    linear_combination C ^ 2 * hkg
  linarith

/-! ## Window dependence of the fitted exponent -/

lemma hasDerivAt_headMass (b : ℝ) {t : ℝ} (ht0 : 0 < t) :
    HasDerivAt (fun s => headMass b s) (ker b t) t := by
  have hcont : ContinuousAt (ker b) t :=
    ContinuousAt.rpow_const (by fun_prop) (Or.inl (by linarith))
  have hmeasf : Measurable (ker b) := by unfold ker; fun_prop
  exact intervalIntegral.integral_hasDerivAt_right (ker_int b le_rfl ht0.le)
    ⟨Set.univ, Filter.univ_mem, hmeasf.aestronglyMeasurable⟩ hcont

lemma hasDerivAt_edgeFrac (β : ℝ) {t : ℝ} (ht0 : 0 < t) :
    HasDerivAt (fun s => edgeFrac β s) (ker β t / headMass β 1) t :=
  (hasDerivAt_headMass β ht0).div_const _

/-- **The cumulative statistic separates the families.** No single exponent reproduces the
edge fraction of a genuine bulk+spike mixture at all windows simultaneously. -/
theorem mixFrac_ne_single {w b₁ b₂ : ℝ} (hw0 : 0 < w) (hw1 : w < 1) (hb : b₁ ≠ b₂) :
    ¬ ∃ b : ℝ, ∀ t ∈ Set.Ioo (0:ℝ) 1, mixFrac w b₁ b₂ t = edgeFrac b t := by
  rintro ⟨b, h⟩
  have hH₁ : 0 < headMass b₁ 1 := headMass_pos b₁ one_pos
  have hH₂ : 0 < headMass b₂ 1 := headMass_pos b₂ one_pos
  have hHb : 0 < headMass b 1 := headMass_pos b one_pos
  set A : ℝ := (1 - w) / headMass b₁ 1 with hA
  set K : ℝ := w / headMass b₂ 1 with hK
  have hApos : 0 < A := by rw [hA]; exact div_pos (by linarith) hH₁
  have hKpos : 0 < K := by rw [hK]; exact div_pos hw0 hH₂
  -- differentiate the assumed identity on the open window
  have hderiv : ∀ t ∈ Set.Ioo (0:ℝ) 1,
      twoComp A K b₁ b₂ t = (1 / headMass b 1) * ker b t := by
    intro t ht
    have hmix : HasDerivAt (fun s => mixFrac w b₁ b₂ s) (A * ker b₁ t + K * ker b₂ t) t := by
      have d₁ := (hasDerivAt_edgeFrac b₁ ht.1).const_mul (1 - w)
      have d₂ := (hasDerivAt_edgeFrac b₂ ht.1).const_mul w
      have hsum := d₁.add d₂
      have hfun : (fun s => mixFrac w b₁ b₂ s)
          = fun s => (1 - w) * edgeFrac b₁ s + w * edgeFrac b₂ s := rfl
      rw [hfun]
      convert hsum using 1
      rw [hA, hK]; ring
    have hsingle : HasDerivAt (fun s => edgeFrac b s) ((1 / headMass b 1) * ker b t) t := by
      have hd := hasDerivAt_edgeFrac b ht.1
      convert hd using 1
      ring
    have heq : (fun s => mixFrac w b₁ b₂ s) =ᶠ[𝓝 t] fun s => edgeFrac b s := by
      filter_upwards [Ioo_mem_nhds ht.1 ht.2] with s hs using h s hs
    have := (hmix.congr_of_eventuallyEq heq.symm).unique hsingle
    simpa [twoComp] using this
  -- and contradict the subwindow separation
  refine twoComp_ne_single_on (A := A) (K := K) (b₁ := b₁) (b₂ := b₂)
    (s := 1/4) (e := 3/4) hApos hKpos hb (by norm_num) (by norm_num)
    ⟨1 / headMass b 1, b, ?_⟩
  intro x hx
  exact hderiv x ⟨by linarith [hx.1], by linarith [hx.2]⟩

/-- For each individual window an effective exponent does exist (and is steeper than the
bulk): the mixture's edge fraction is realised by a single law window by window. -/
theorem exists_effective_exponent {w b₁ b₂ t : ℝ} (hw0 : 0 < w) (hw1 : w < 1)
    (hb₁ : 1 < b₁) (hb : b₁ < b₂) (ht0 : 0 < t) (ht1 : t < 1) :
    ∃ b, b₁ < b ∧ edgeFrac b t = mixFrac w b₁ b₂ t := by
  refine exists_edgeFrac_eq ht0 hb₁ (mixFrac_gt_bulk hw0 hb ht0 ht1) ?_
  have h₁ := edgeFrac_lt_one b₁ ht0.le ht1
  have h₂ := edgeFrac_lt_one b₂ ht0.le ht1
  rw [mixFrac]
  nlinarith

/-- **Window dependence of the fitted exponent.** If a single-law exponent is fitted to the
mixture window by window, the resulting exponent cannot be constant: refitting on a different
window necessarily returns a different exponent. -/
theorem effective_exponent_window_dependent {w b₁ b₂ : ℝ} (hw0 : 0 < w) (hw1 : w < 1)
    (hb : b₁ ≠ b₂) (beff : ℝ → ℝ)
    (hfit : ∀ t ∈ Set.Ioo (0:ℝ) 1, edgeFrac (beff t) t = mixFrac w b₁ b₂ t) :
    ¬ ∃ c, ∀ t ∈ Set.Ioo (0:ℝ) 1, beff t = c := by
  rintro ⟨c, hc⟩
  refine mixFrac_ne_single hw0 hw1 hb ⟨c, fun t ht => ?_⟩
  have := hfit t ht
  rwa [hc t ht, eq_comm] at this


/-! ## The measured local exponent steepens toward the left edge -/

/-- The exponent that a two-point (log-log) slope measurement on the window `[x,y]` reports
for a profile `f`. -/
noncomputable def localExponent (f : ℝ → ℝ) (x y : ℝ) : ℝ :=
  -(Real.log (f y) - Real.log (f x)) / (Real.log (1 + y) - Real.log (1 + x))

/-- A pure power law reports the same exponent on every window: the slope measurement is
scale free. -/
theorem localExponent_single {C b x y : ℝ} (hC : 0 < C) (hx : 0 ≤ x) (hxy : x < y) :
    localExponent (fun z => C * ker b z) x y = b := by
  have hx1 : (0:ℝ) < 1 + x := by linarith
  have hy1 : (0:ℝ) < 1 + y := by linarith
  have hd : Real.log (1 + x) < Real.log (1 + y) := Real.log_lt_log hx1 (by linarith)
  have hlog : ∀ z : ℝ, 0 ≤ z → Real.log (C * ker b z) = Real.log C - b * Real.log (1 + z) := by
    intro z hz
    have hz1 : (0:ℝ) < 1 + z := by linarith
    rw [Real.log_mul (ne_of_gt hC) (ne_of_gt (ker_pos _ hz)), ker, Real.log_rpow hz1]
    ring
  have hne : Real.log (1 + y) - Real.log (1 + x) ≠ 0 := sub_ne_zero.mpr (ne_of_gt hd)
  rw [localExponent, hlog x hx, hlog y (by linarith), div_eq_iff hne]
  ring

/-- **Left-edge steepening.** On a geometric triple of positions, a genuine two-component
profile reports a strictly steeper exponent on the left half-window than on the right
half-window. A pure power law reports the same exponent on both. -/
theorem localExponent_strictAnti {A K b₁ b₂ x₀ x₁ x₂ : ℝ} (hA : 0 < A) (hK : 0 < K)
    (hb : b₁ ≠ b₂) (h₀ : 0 ≤ x₀) (h01 : x₀ < x₁) (h12 : x₁ < x₂)
    (hgeom : (1 + x₁) ^ 2 = (1 + x₀) * (1 + x₂)) :
    localExponent (twoComp A K b₁ b₂) x₁ x₂ < localExponent (twoComp A K b₁ b₂) x₀ x₁ := by
  have hx₁ : 0 ≤ x₁ := le_trans h₀ h01.le
  have hx₂ : 0 ≤ x₂ := le_trans hx₁ h12.le
  have hu : (0:ℝ) < 1 + x₀ := by linarith
  have hm : (0:ℝ) < 1 + x₁ := by linarith
  have hv : (0:ℝ) < 1 + x₂ := by linarith
  have hfpos : ∀ z : ℝ, 0 ≤ z → 0 < twoComp A K b₁ b₂ z := by
    intro z hz
    have := ker_pos b₁ hz
    have := ker_pos b₂ hz
    unfold twoComp
    positivity
  -- the two log-spacings agree
  have hspace : Real.log (1 + x₁) - Real.log (1 + x₀) = Real.log (1 + x₂) - Real.log (1 + x₁) := by
    have h2 : Real.log ((1 + x₁) * (1 + x₁)) = Real.log ((1 + x₀) * (1 + x₂)) := by
      rw [show (1 + x₁) * (1 + x₁) = (1 + x₁) ^ 2 by ring, hgeom]
    rw [Real.log_mul (ne_of_gt hm) (ne_of_gt hm), Real.log_mul (ne_of_gt hu) (ne_of_gt hv)] at h2
    linarith
  have hd : 0 < Real.log (1 + x₁) - Real.log (1 + x₀) :=
    sub_pos.mpr (Real.log_lt_log hu (by linarith))
  -- strict log-convexity of the profile
  have hconv := twoComp_mul_gt_sq hA hK hb h₀ h01 h12 hgeom
  have hlog : 2 * Real.log (twoComp A K b₁ b₂ x₁)
      < Real.log (twoComp A K b₁ b₂ x₀) + Real.log (twoComp A K b₁ b₂ x₂) := by
    have h1 := hfpos x₀ h₀
    have h2 := hfpos x₁ hx₁
    have h3 := hfpos x₂ hx₂
    have hll := Real.log_lt_log (by positivity) hconv
    rw [Real.log_mul (ne_of_gt h2) (ne_of_gt h2),
      Real.log_mul (ne_of_gt h1) (ne_of_gt h3)] at hll
    linarith
  rw [localExponent, localExponent, ← hspace, div_lt_div_iff_of_pos_right hd]
  linarith

end Pythagorean.EdgeKernel