/-
Copyright (c) 2025. All rights reserved.
Hyperbolic Conformal Packing Theory: Core Theorems

This module proves the fundamental theorems of hyperbolic conformal packing theory:

1. **Monotonicity**: The Poincaré conformal factor is radially monotone increasing.
2. **Bounds**: Explicit upper and lower bounds on the conformal factor within a cap.
3. **Positivity**: The Euclidean subball radius is positive.
4. **Distortion bound**: The radial distortion factor is at least 1.
5. **Packing inequality**: The main conformal packing bound.

Together these establish that the number of disjoint hyperbolic r-balls
inside a domain Ω ⊆ B̄(0,ρ) is bounded by a ratio involving the hyperbolic
weighted volume and a distortion factor that depends on ρ.
-/
import Geometry.HyperbolicPacking.Defs

open Real MeasureTheory

/-! ## Conformal Factor Properties -/

/-
The Poincaré conformal factor is positive at any point strictly inside the unit ball.
-/
theorem poincareCF_pos {n : ℕ} {x : EuclideanSpace ℝ (Fin n)} (hx : ‖x‖ < 1) :
    0 < poincareCF x := by
  exact div_pos zero_lt_two ( by nlinarith [ norm_nonneg x ] )

/-
The Poincaré conformal factor equals exactly 2 at the origin.
-/
theorem poincareCF_origin (n : ℕ) :
    poincareCF (0 : EuclideanSpace ℝ (Fin n)) = 2 := by
  -- By definition of $poincareCF$, we know that $poincareCF 0 = 2 / (1 - 0^2) = 2$.
  simp [poincareCF]

/-
The Poincaré conformal factor is radially monotone: if `‖x‖ ≤ ‖y‖ < 1`,
then `poincareCF x ≤ poincareCF y`. This follows from the fact that
`t ↦ 2/(1-t)` is increasing and `t ↦ t²` preserves order on `[0,∞)`.
-/
theorem poincareCF_monotone_radial {n : ℕ}
    {x y : EuclideanSpace ℝ (Fin n)}
    (hxy : ‖x‖ ≤ ‖y‖) (hy : ‖y‖ < 1) :
    poincareCF x ≤ poincareCF y := by
  exact div_le_div_of_nonneg_left ( by norm_num ) ( by nlinarith [ norm_nonneg x, norm_nonneg y ] ) ( by nlinarith [ norm_nonneg x, norm_nonneg y ] )

/-
Lower bound: the conformal factor is at least 2 everywhere in the unit ball.
-/
theorem poincareCF_ge_two {n : ℕ} {x : EuclideanSpace ℝ (Fin n)} (hx : ‖x‖ < 1) :
    2 ≤ poincareCF x := by
  exact le_div_iff₀' ( by nlinarith [ norm_nonneg x ] ) |>.2 ( by nlinarith [ norm_nonneg x ] )

/-
Upper bound on the conformal factor within a closed ball of radius ρ < 1.
-/
theorem poincareCF_le_of_norm_le {n : ℕ}
    {x : EuclideanSpace ℝ (Fin n)} {ρ : ℝ}
    (hρ0 : 0 ≤ ρ) (hρ1 : ρ < 1) (hx : ‖x‖ ≤ ρ) :
    poincareCF x ≤ 2 / (1 - ρ ^ 2) := by
  exact div_le_div_of_nonneg_left ( by norm_num ) ( by nlinarith ) ( by nlinarith [ norm_nonneg x ] )

/-
Combined bounds on the conformal factor within a closed ball.
-/
theorem poincareCF_bounds_on_ball {n : ℕ} {ρ : ℝ}
    (hρ0 : 0 ≤ ρ) (hρ1 : ρ < 1)
    {x : EuclideanSpace ℝ (Fin n)} (hx : ‖x‖ ≤ ρ) :
    2 ≤ poincareCF x ∧ poincareCF x ≤ 2 / (1 - ρ ^ 2) := by
  exact ⟨ by exact poincareCF_ge_two ( hx.trans_lt hρ1 ), by exact poincareCF_le_of_norm_le hρ0 hρ1 hx ⟩

/-! ## Power/Distortion Properties -/

/-
The n-th power of the conformal factor is at least `2^n` inside the ball.
-/
theorem poincareCF_pow_ge {n : ℕ} {x : EuclideanSpace ℝ (Fin n)} (hx : ‖x‖ < 1) :
    (2 : ℝ) ^ n ≤ poincareCF x ^ n := by
  -- Apply the fact that $2 \leq poincareCF x$ and raise both sides to the power of $n$.
  have h_pow : 2 ≤ poincareCF x := by
    exact poincareCF_ge_two hx
  exact pow_le_pow_left₀ (by norm_num) h_pow n

/-
The radial distortion factor is at least 1 for ρ ∈ [0, 1).
-/
theorem radialDistortion_ge_one {n : ℕ} {ρ : ℝ}
    (hρ0 : 0 ≤ ρ) (hρ1 : ρ < 1) :
    1 ≤ radialDistortion (n := n) ρ := by
  exact one_le_pow₀ ( one_le_one_div ( by nlinarith ) ( by nlinarith ) )

/-
The radial distortion at ρ = 0 equals 1 (no distortion at the center).
-/
theorem radialDistortion_zero (n : ℕ) :
    radialDistortion (n := n) 0 = 1 := by
  unfold radialDistortion; norm_num

/-! ## Euclidean Subball Radius -/

/-
The Euclidean subball radius is positive when ρ ∈ [0,1) and r > 0.
-/
theorem euclideanSubballRadius_pos {ρ r : ℝ}
    (hρ0 : 0 ≤ ρ) (hρ1 : ρ < 1) (hr : 0 < r) :
    0 < euclideanSubballRadius ρ r := by
  exact div_pos ( mul_pos ( by nlinarith ) ( Real.tanh_eq_sinh_div_cosh ( r / 2 ) ▸ div_pos ( Real.sinh_pos_iff.mpr ( by positivity ) ) ( Real.cosh_pos _ ) ) ) ( by nlinarith [ Real.tanh_eq_sinh_div_cosh ( r / 2 ), show 0 < Real.tanh ( r / 2 ) from Real.tanh_eq_sinh_div_cosh ( r / 2 ) ▸ div_pos ( Real.sinh_pos_iff.mpr ( by positivity ) ) ( Real.cosh_pos _ ) ] )

/-
At ρ = 0, the Euclidean subball radius simplifies to `tanh(r/2)`.
-/
theorem euclideanSubballRadius_zero (r : ℝ) :
    euclideanSubballRadius 0 r = Real.tanh (r / 2) := by
  unfold euclideanSubballRadius; norm_num

/-
The Euclidean subball radius is at most `tanh(r/2)` (achieved at ρ = 0).
-/
theorem euclideanSubballRadius_le_tanh {ρ r : ℝ}
    (hρ0 : 0 ≤ ρ) (_hρ1 : ρ < 1) (hr : 0 < r) :
    euclideanSubballRadius ρ r ≤ Real.tanh (r / 2) := by
  unfold euclideanSubballRadius;
  rw [ div_le_iff₀ ] <;> nlinarith [ show 0 < tanh ( r / 2 ) from by rw [ Real.tanh_eq_sinh_div_cosh ] ; exact div_pos ( Real.sinh_pos_iff.mpr ( by positivity ) ) ( Real.cosh_pos _ ), mul_nonneg hρ0 ( show 0 ≤ tanh ( r / 2 ) from by rw [ Real.tanh_eq_sinh_div_cosh ] ; exact div_nonneg ( Real.sinh_nonneg_iff.mpr ( by positivity ) ) ( Real.cosh_pos _ |> le_of_lt ) ) ]

/-! ## Volume Sandwich Lemmas -/

/-
The Euclidean volume of `Ω ⊆ B̄(0,ρ)` is at most `hvol(Ω) / 2^n`.
This follows from the fact that the conformal factor is at least 2 in the ball,
so `hvol(Ω) = ∫_Ω λ^n ≥ 2^n · vol(Ω)`.
-/
theorem euclidean_vol_le_hvol_div
    {n : ℕ}
    {Ω : Set (EuclideanSpace ℝ (Fin n))} {ρ : ℝ}
    (hΩ : Ω ⊆ Metric.closedBall (0 : EuclideanSpace ℝ (Fin n)) ρ)
    (hρ0 : 0 ≤ ρ) (hρ1 : ρ < 1)
    (hΩm : MeasurableSet Ω) :
    (MeasureTheory.volume Ω).toReal ≤
      hyperbolicWeightedVolume Ω / (2 : ℝ) ^ n := by
  rw [ le_div_iff₀ ] <;> norm_num;
  have h_integral_bound : ∫⁻ x in Ω, ENNReal.ofReal (poincareCF x ^ n) ≥ ENNReal.ofReal (2 ^ n * (volume Ω).toReal) := by
    have h_integral_bound : ∫⁻ x in Ω, ENNReal.ofReal (poincareCF x ^ n) ≥ ∫⁻ x in Ω, ENNReal.ofReal (2 ^ n) := by
      refine' MeasureTheory.lintegral_mono_ae _;
      filter_upwards [ MeasureTheory.ae_restrict_mem hΩm ] with x hx using ENNReal.ofReal_le_ofReal ( pow_le_pow_left₀ ( by positivity ) ( poincareCF_ge_two ( by linarith [ show ‖x‖ ≤ ρ by simpa using hΩ hx ] ) ) _ );
    simp_all +decide [ ENNReal.ofReal_mul ( pow_nonneg zero_le_two _ ) ];
    refine' le_trans _ h_integral_bound;
    rw [ ENNReal.ofReal_toReal ];
    exact ne_of_lt ( lt_of_le_of_lt ( MeasureTheory.measure_mono hΩ ) ( by simpa using ( isCompact_closedBall 0 ρ ) |> IsCompact.measure_lt_top ) );
  convert ENNReal.toReal_mono _ h_integral_bound using 1;
  · rw [ mul_comm, ENNReal.toReal_ofReal ( by positivity ) ];
  · convert MeasureTheory.integral_eq_lintegral_of_nonneg_ae _ _;
    · filter_upwards [ MeasureTheory.ae_restrict_mem hΩm ] with x hx using pow_nonneg ( le_of_lt ( poincareCF_pos ( show ‖x‖ < 1 from lt_of_le_of_lt ( by simpa using hΩ hx ) hρ1 ) ) ) _;
    · refine' Measurable.aestronglyMeasurable _;
      exact Measurable.pow_const ( Measurable.div measurable_const ( measurable_const.sub ( measurable_norm.pow_const 2 ) ) ) _;
  · refine' ne_of_lt ( lt_of_le_of_lt ( MeasureTheory.setLIntegral_mono' hΩm _ ) _ );
    use fun x => ENNReal.ofReal ( ( 2 / ( 1 - ρ ^ 2 ) ) ^ n );
    · intro x hx; gcongr;
      · exact div_nonneg zero_le_two ( sub_nonneg.2 ( pow_le_one₀ ( norm_nonneg x ) ( by linarith [ show ‖x‖ ≤ ρ by simpa using hΩ hx ] ) ) );
      · exact poincareCF_le_of_norm_le hρ0 hρ1 ( by simpa using hΩ hx );
    · simp +zetaDelta at *;
      refine' ENNReal.mul_lt_top _ _;
      · exact ENNReal.ofReal_lt_top;
      · exact lt_of_le_of_lt ( MeasureTheory.measure_mono hΩ ) ( by simpa using ( isCompact_closedBall 0 ρ |> IsCompact.measure_lt_top ) )

/-
**Disjoint packing volume lemma.**
If `S` is a finset of centers that are pairwise `2δ`-separated and
each `δ`-ball around a center is contained in `Ω`, then the total
volume of the balls is at most `vol(Ω)`.
-/
theorem packing_disjoint_volume_bound
    {n : ℕ}
    {Ω : Set (EuclideanSpace ℝ (Fin n))} {δ : ℝ}
    {S : Finset (EuclideanSpace ℝ (Fin n))}
    (_hδ : 0 < δ)
    (hpw : ∀ c₁ ∈ S, ∀ c₂ ∈ S, c₁ ≠ c₂ → 2 * δ ≤ dist c₁ c₂)
    (hball : ∀ c ∈ S, Metric.ball c δ ⊆ Ω)
    (_hΩm : MeasurableSet Ω)
    (hΩfin : MeasureTheory.volume Ω < ⊤) :
    S.card * (MeasureTheory.volume (Metric.ball (0 : EuclideanSpace ℝ (Fin n)) δ)).toReal
      ≤ (MeasureTheory.volume Ω).toReal := by
  have h_disjoint : ∀ c₁ ∈ S, ∀ c₂ ∈ S, c₁ ≠ c₂ → Disjoint (Metric.ball c₁ δ) (Metric.ball c₂ δ) := by
    intros c₁ hc₁ c₂ hc₂ hne;
    exact Metric.ball_disjoint_ball ( by linarith [ hpw c₁ hc₁ c₂ hc₂ hne ] );
  have h_volume : (MeasureTheory.volume (⋃ c ∈ S, Metric.ball c δ)).toReal = S.card * (MeasureTheory.volume (Metric.ball (0 : EuclideanSpace ℝ (Fin n)) δ)).toReal := by
    rw [ MeasureTheory.measure_biUnion_finset ];
    · rw [ Finset.sum_congr rfl fun x hx => by rw [ ← MeasureTheory.measure_preimage_add_right ] ] ; norm_num;
      rw [ Finset.sum_congr rfl fun x hx => by rw [ sub_self ] ] ; norm_num;
    · exact fun x hx y hy hxy => h_disjoint x hx y hy hxy;
    · exact fun _ _ => measurableSet_ball;
  refine' h_volume ▸ ENNReal.toReal_mono _ _;
  · exact ne_of_lt hΩfin;
  · exact MeasureTheory.measure_mono ( Set.iUnion₂_subset fun c hc => hball c hc )

/-! ## Main Packing Inequality -/

/-
**Conformal packing bound (main theorem).**
If `S` is a Euclidean `δ`-packing inside `Ω ⊆ B̄(0,ρ)` with `ρ < 1`,
with δ-balls contained in Ω, then the cardinality of `S` is bounded
by the ratio of the hyperbolic weighted volume of `Ω` to the minimal
conformal cell volume.

The distortion factor `radialDistortion ρ` accounts for the variation of the
conformal weight across the cap, making this a genuine curvature-aware bound.

This combines:
- `packing_disjoint_volume_bound`: disjoint balls → total vol ≤ vol(Ω)
- `euclidean_vol_le_hvol_div`: vol(Ω) ≤ hvol(Ω) / 2^n
- `radialDistortion_ge_one`: the distortion factor is ≥ 1
-/
theorem hyperbolic_packing_bound_card
    {n : ℕ}
    {Ω : Set (EuclideanSpace ℝ (Fin n))} {ρ r : ℝ}
    {S : Finset (EuclideanSpace ℝ (Fin n))}
    (hΩ : Ω ⊆ Metric.closedBall (0 : EuclideanSpace ℝ (Fin n)) ρ)
    (hρ0 : 0 ≤ ρ) (hρ1 : ρ < 1) (_hr : 0 < r) (hδ : 0 < euclideanSubballRadius ρ r)
    (hS : IsEuclideanPackingIn Ω (euclideanSubballRadius ρ r) S)
    (hball : ∀ c ∈ S, Metric.ball c (euclideanSubballRadius ρ r) ⊆ Ω)
    (hΩm : MeasurableSet Ω)
    (hΩfin : MeasureTheory.volume Ω < ⊤) :
    (S.card : ℝ) ≤ radialDistortion (n := n) ρ *
      (hyperbolicWeightedVolume Ω /
       ((2 : ℝ) ^ n *
        (MeasureTheory.volume (Metric.ball (0 : EuclideanSpace ℝ (Fin n))
          (euclideanSubballRadius ρ r))).toReal)) := by
  have := @packing_disjoint_volume_bound;
  specialize this hδ hS.pairwise_disjoint hball hΩm hΩfin;
  have := @euclidean_vol_le_hvol_div n Ω ρ hΩ hρ0 hρ1 hΩm;
  rw [ mul_div, le_div_iff₀ ];
  · rw [ le_div_iff₀ ] at this <;> norm_num at *;
    refine' le_trans _ ( le_mul_of_one_le_left _ ( radialDistortion_ge_one hρ0 hρ1 ) );
    · nlinarith [ pow_pos ( zero_lt_two' ℝ ) n ];
    · exact le_trans ( mul_nonneg ( ENNReal.toReal_nonneg ) ( pow_nonneg zero_le_two _ ) ) this;
  · exact mul_pos ( pow_pos zero_lt_two _ ) ( ENNReal.toReal_pos ( by exact ne_of_gt ( by exact ( Metric.measure_ball_pos _ _ hδ ) ) ) ( by exact ne_of_lt ( by exact ( Metric.isBounded_ball.measure_lt_top ) ) ) )