/-
# The reward–KL Pareto frontier and its tropical corner

Second research cycle built on `Catalog.Tropical.ConstrainedEqualsPenalised`.

Where the first file established *constrained = penalised* (existence and uniqueness of the
temperature realising a KL budget, and optimality of the tilt inside the KL ball), this file
studies the **frontier** traced by the penalised family, i.e. the parametric curve

`t ↦ (k(t), V(t)) = (KL(p_t ‖ π₀), 𝔼_{p_t}[r])`,   `t = 1/β ∈ [0, ∞)`.

Main results, all proved *without differentiating* the log-partition function:

* `klDiv_tilted_eq_bregman` — the KL divergence between two members of the tilted family is
  exactly the **Bregman divergence of `log Z`**:
  `KL(p_s ‖ p_t) = log Z(t) - log Z(s) - (t-s)·𝔼_{p_s}[r]`.
* `convexOn_logPartition` — hence `log Z` is convex on all of `ℝ` (Gibbs / cumulant convexity),
  obtained purely from the supporting-line inequality above.
* `shadow_price_bracket` — `s·(V(t)-V(s)) ≤ k(t)-k(s) ≤ t·(V(t)-V(s))` for `0 < s ≤ t`:
  the marginal reward per unit of KL is bracketed by the two temperatures, so the temperature
  `β = 1/t` *is* the shadow price of the KL constraint.
* `frontier_concave` — the reward–KL frontier is concave (chord slopes decrease).
* `expect_tendsto_rewardMax` and `frontier_tendsto_tropical_corner` — as `β → 0` the frontier
  runs into the **tropical corner** `(L, max r)` with `L = -log π₀(argmax r)`: the Maslov
  dequantization limit of the whole alignment problem.
-/
import Catalog.Tropical.ConstrainedEqualsPenalised

namespace Catalog.Tropical.ConstrainedPenalised

open Finset Real Filter Topology

variable {ι : Type*} [Fintype ι] [Nonempty ι] {p0 r : ι → ℝ}

/-! ## `log Z` is a cumulant generating function: KL between tilts is its Bregman divergence -/

/-- **Bregman identity.** The KL divergence between two tilts equals the Bregman divergence of
the log-partition function with respect to its (mean-reward) supporting slope. -/
theorem klDiv_tilted_eq_bregman (hp0 : ∀ i, 0 < p0 i) (s t : ℝ) :
    klDiv (tilted p0 r s) (tilted p0 r t)
      = Real.log (partitionFn p0 r t) - Real.log (partitionFn p0 r s)
        - (t - s) * expect (tilted p0 r s) r := by
  have h1 := klDiv_tilted_decomposition (p := tilted p0 r s) (r := r) hp0
    (tilted_isProb (r := r) hp0 s) t
  have h2 := klCurve_eq (p0 := p0) (r := r) hp0 s
  have e1 : klDiv (tilted p0 r s) p0 = klCurve p0 r s := rfl
  rw [e1] at h1
  rw [h1, h2]
  ring

/-- **Supporting line.** `log Z` lies above each of its tangent lines, with slope the mean reward
of the corresponding tilt. -/
theorem logPartition_supporting_line (hp0 : ∀ i, 0 < p0 i) (s t : ℝ) :
    Real.log (partitionFn p0 r s) + (t - s) * expect (tilted p0 r s) r
      ≤ Real.log (partitionFn p0 r t) := by
  have hb := klDiv_tilted_eq_bregman (r := r) hp0 s t
  have hnn : 0 ≤ klDiv (tilted p0 r s) (tilted p0 r t) :=
    klDiv_nonneg (tilted_isProb hp0 s) (tilted_isProb hp0 t) (tilted_pos hp0 t)
  linarith

/-- **Convexity of the log-partition function**, derived from the supporting-line inequality
alone — no derivatives, no Hölder. -/
theorem convexOn_logPartition (hp0 : ∀ i, 0 < p0 i) :
    ConvexOn ℝ Set.univ (fun t => Real.log (partitionFn p0 r t)) := by
  refine ⟨convex_univ, ?_⟩
  intro x _ y _ a b ha hb hab
  have hx := logPartition_supporting_line (r := r) hp0 (a * x + b * y) x
  have hy := logPartition_supporting_line (r := r) hp0 (a * x + b * y) y
  have hzz : a * (x - (a * x + b * y)) + b * (y - (a * x + b * y)) = 0 := by
    have hb1 : b = 1 - a := by linarith
    subst hb1; ring
  have key : (a + b) * Real.log (partitionFn p0 r (a * x + b * y))
      + (a * (x - (a * x + b * y)) + b * (y - (a * x + b * y)))
        * expect (tilted p0 r (a * x + b * y)) r
      ≤ a * Real.log (partitionFn p0 r x) + b * Real.log (partitionFn p0 r y) := by
    calc (a + b) * Real.log (partitionFn p0 r (a * x + b * y))
          + (a * (x - (a * x + b * y)) + b * (y - (a * x + b * y)))
            * expect (tilted p0 r (a * x + b * y)) r
        = a * (Real.log (partitionFn p0 r (a * x + b * y))
              + (x - (a * x + b * y)) * expect (tilted p0 r (a * x + b * y)) r)
          + b * (Real.log (partitionFn p0 r (a * x + b * y))
              + (y - (a * x + b * y)) * expect (tilted p0 r (a * x + b * y)) r) := by ring
      _ ≤ a * Real.log (partitionFn p0 r x) + b * Real.log (partitionFn p0 r y) := by
          linarith [mul_le_mul_of_nonneg_left hx ha, mul_le_mul_of_nonneg_left hy hb]
  rw [hzz, hab] at key
  simpa using key

/-! ## The shadow-price bracket -/

/-- **Shadow price bracket.**  For `0 < s ≤ t` the increment of the KL budget is bracketed by the
two temperatures times the increment of expected reward:
`s·ΔV ≤ Δk ≤ t·ΔV`.  Equivalently `ΔV/Δk ∈ [1/t, 1/s] = [β_t, β_s]`: the inverse temperature is
exactly the marginal price of one nat of KL. -/
theorem shadow_price_bracket (hp0 : ∀ i, 0 < p0 i) (s t : ℝ) :
    s * (expect (tilted p0 r t) r - expect (tilted p0 r s) r) ≤ klCurve p0 r t - klCurve p0 r s ∧
      klCurve p0 r t - klCurve p0 r s
        ≤ t * (expect (tilted p0 r t) r - expect (tilted p0 r s) r) := by
  have h1 := duality_identity (p := tilted p0 r s) (r := r) hp0 (tilted_isProb hp0 s) t
  have h2 := duality_identity (p := tilted p0 r t) (r := r) hp0 (tilted_isProb hp0 t) s
  have e1 : klDiv (tilted p0 r s) p0 = klCurve p0 r s := rfl
  have e2 : klDiv (tilted p0 r t) p0 = klCurve p0 r t := rfl
  rw [e1] at h1
  rw [e2] at h2
  have hn1 : 0 ≤ klDiv (tilted p0 r s) (tilted p0 r t) :=
    klDiv_nonneg (tilted_isProb hp0 s) (tilted_isProb hp0 t) (tilted_pos hp0 t)
  have hn2 : 0 ≤ klDiv (tilted p0 r t) (tilted p0 r s) :=
    klDiv_nonneg (tilted_isProb hp0 t) (tilted_isProb hp0 s) (tilted_pos hp0 s)
  constructor
  · nlinarith [h2, hn2]
  · nlinarith [h1, hn1]

/-- **Concavity of the reward–KL Pareto frontier.**  For `0 < s < t < u` the chord slopes of the
curve `k ↦ V` decrease, in cross-multiplied form. -/
theorem frontier_concave (hp0 : ∀ i, 0 < p0 i) {s t u : ℝ} (hs : 0 < s) (hst : s ≤ t)
    (htu : t ≤ u) :
    (klCurve p0 r u - klCurve p0 r t) * (expect (tilted p0 r t) r - expect (tilted p0 r s) r)
      ≥ (klCurve p0 r t - klCurve p0 r s)
        * (expect (tilted p0 r u) r - expect (tilted p0 r t) r) := by
  have ht : 0 < t := lt_of_lt_of_le hs hst
  have hA := (shadow_price_bracket (r := r) hp0 s t).2
  have hB := (shadow_price_bracket (r := r) hp0 t u).1
  have hkts : 0 ≤ klCurve p0 r t - klCurve p0 r s := by
    have := klCurve_sub_ge_klDiv (r := r) hp0 hs.le hst
    have hn : 0 ≤ klDiv (tilted p0 r t) (tilted p0 r s) :=
      klDiv_nonneg (tilted_isProb hp0 t) (tilted_isProb hp0 s) (tilted_pos hp0 s)
    linarith
  have hkut : 0 ≤ klCurve p0 r u - klCurve p0 r t := by
    have := klCurve_sub_ge_klDiv (r := r) hp0 ht.le htu
    have hn : 0 ≤ klDiv (tilted p0 r u) (tilted p0 r t) :=
      klDiv_nonneg (tilted_isProb hp0 u) (tilted_isProb hp0 t) (tilted_pos hp0 t)
    linarith
  -- `t·ΔV_{st} ≥ Δk_{st}` and `t·ΔV_{tu} ≤ Δk_{tu}` give the claim after cross-multiplying.
  nlinarith [hA, hB, hkts, hkut, ht]

/-! ## The tropical corner of the frontier -/

/-- The KL budget grows sublinearly: `k(t)/t → 0`. -/
theorem klCurve_div_tendsto_zero (hp0 : ∀ i, 0 < p0 i) (hs : ∑ i, p0 i = 1) :
    Tendsto (fun t => klCurve p0 r t / t) atTop (𝓝 0) := by
  have hlow : ∀ᶠ t in atTop, (0 : ℝ) ≤ klCurve p0 r t / t := by
    filter_upwards [eventually_gt_atTop (0 : ℝ)] with t ht
    exact div_nonneg (klCurve_nonneg hp0 hs t) ht.le
  have hhigh : ∀ᶠ t in atTop, klCurve p0 r t / t ≤ tropicalCeiling p0 r / t := by
    filter_upwards [eventually_gt_atTop (0 : ℝ)] with t ht
    gcongr
    exact klCurve_le_tropicalCeiling hp0 hs ht.le
  have hR : Tendsto (fun t : ℝ => tropicalCeiling p0 r / t) atTop (𝓝 0) :=
    Filter.Tendsto.div_atTop tendsto_const_nhds tendsto_id
  exact tendsto_of_tendsto_of_tendsto_of_le_of_le' tendsto_const_nhds hR hlow hhigh

/-- **The penalised policy attains the tropical optimum in the zero-temperature limit**:
`𝔼_{p_t}[r] → max r` as `t → ∞`, i.e. as `β → 0`. -/
theorem expect_tendsto_rewardMax (hp0 : ∀ i, 0 < p0 i) (hs : ∑ i, p0 i = 1) :
    Tendsto (fun t => expect (tilted p0 r t) r) atTop (𝓝 (rewardMax r)) := by
  have hrw : ∀ᶠ t in atTop, expect (tilted p0 r t) r
      = klCurve p0 r t / t + Real.log (partitionFn p0 r t) / t := by
    filter_upwards [eventually_gt_atTop (0 : ℝ)] with t ht
    have h := klCurve_eq (p0 := p0) (r := r) hp0 t
    field_simp
    linarith [h]
  have hlim : Tendsto
      (fun t => klCurve p0 r t / t + Real.log (partitionFn p0 r t) / t) atTop
      (𝓝 (rewardMax r)) := by
    have := (klCurve_div_tendsto_zero (r := r) hp0 hs).add
      (tropical_limit_of_logPartition (r := r) hp0 hs)
    simpa using this
  exact hlim.congr' (hrw.mono fun t h => h.symm)

/-- **The tropical corner.**  The reward–KL frontier converges, as the temperature goes to zero,
to the corner `(L, max r)` where `L = -log π₀(argmax r)` is the tropical ceiling and `max r` is
the tropical (max-plus) value of the reward. -/
theorem frontier_tendsto_tropical_corner (hp0 : ∀ i, 0 < p0 i) (hs : ∑ i, p0 i = 1) :
    Tendsto (fun t => (klCurve p0 r t, expect (tilted p0 r t) r)) atTop
      (𝓝 (tropicalCeiling p0 r, rewardMax r)) := by
  rw [nhds_prod_eq]
  exact (klCurve_tendsto_tropicalCeiling (r := r) hp0).prodMk
    (expect_tendsto_rewardMax (r := r) hp0 hs)

/-- **The frontier is exactly the constrained value function.**  At the budget `k = k(t)` the
constrained optimum value is `𝔼_{p_t}[r]`; combined with `frontier_tendsto_tropical_corner`, the
value function increases to `max r` as the budget increases to `L`. -/
theorem constrained_value_eq_frontier (hp0 : ∀ i, 0 < p0 i) {t : ℝ} (ht : 0 < t) :
    IsGreatest {v : ℝ | ∃ p, IsProb p ∧ klDiv p p0 ≤ klCurve p0 r t ∧ expect p r = v}
      (expect (tilted p0 r t) r) := by
  constructor
  · exact ⟨tilted p0 r t, tilted_isProb hp0 t, le_rfl, rfl⟩
  · rintro v ⟨p, hp, hple, rfl⟩
    exact tilted_maximises hp0 hp ht hple

end Catalog.Tropical.ConstrainedPenalised