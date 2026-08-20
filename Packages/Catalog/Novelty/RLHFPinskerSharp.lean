import Novelty.RLHFPinskerDrift

/-!
# Sharpness of the Pinsker constant, and of the RLHF drift law

Domain: Novelty (information theory × asymptotic analysis).

`Novelty.RLHFPinskerDrift` proves `‖q − p‖₁² ≤ 2 KL(q ‖ p)` and deduces the
`β^{-1/2}` no-collapse law for the aligned (Gibbs) policy.  Here we show that the
constant `2` is *optimal*, so the `β^{-1/2}` rate cannot be improved by sharpening
the information-theoretic input.

The witness is the two-point family `q_ε = (1/2 + ε, 1/2 − ε)` around the uniform
reference.  The two ingredients are elementary but genuinely quantitative:

* `RLHF.log_one_add_le_cubic` : `log (1 + x) ≤ x − x²/2 + x³/3` for `x ≥ 0`;
* `RLHF.log_one_sub_le_cubic` : `log (1 − x) ≤ −x − x²/2 − x³/3` for `0 ≤ x < 1`.

Both are proved by a mean-value argument (their defect functions have derivative
`x³/(1 ± x)`).  They give `2 KL(q_ε ‖ q_0) ≤ ‖q_ε − q_0‖₁² (1 + (8/3) ε²)`, while
Pinsker gives the reverse inequality with factor `1`; hence

* `RLHF.pinsker_ratio_tendsto_one` : `2 KL/‖·‖₁² → 1` as `ε ↓ 0`;
* `RLHF.pinsker_constant_optimal` : for every `c < 2` the inequality
  `‖q − p‖₁² ≤ c · KL(q ‖ p)` fails on this family.
-/

namespace RLHF

open Finset Set Filter Topology

/-! ## 1. Cubic Taylor bounds for the logarithm -/

/-- Defect function of the cubic upper bound for `log (1 + x)`. -/
noncomputable def logAddDefect (x : ℝ) : ℝ := x - x ^ 2 / 2 + x ^ 3 / 3 - Real.log (1 + x)

theorem hasDerivAt_logAddDefect {x : ℝ} (hx : -1 < x) :
    HasDerivAt logAddDefect (x ^ 3 / (1 + x)) x := by
  have h1x : (1 : ℝ) + x ≠ 0 := by linarith
  have hlog : HasDerivAt (fun y : ℝ => Real.log (1 + y)) (1 / (1 + x)) x := by
    have := (Real.hasDerivAt_log h1x).comp x ((hasDerivAt_id x).const_add 1)
    simpa [one_div] using this
  have hpoly : HasDerivAt (fun y : ℝ => y - y ^ 2 / 2 + y ^ 3 / 3) (1 - x + x ^ 2) x := by
    have h := (((hasDerivAt_id x).sub ((hasDerivAt_pow 2 x).div_const 2)).add
      ((hasDerivAt_pow 3 x).div_const 3))
    simp only [Nat.cast_ofNat] at h
    convert h using 1
    push_cast; ring
  have := hpoly.sub hlog
  convert this using 1
  field_simp
  ring

/-- `log (1 + x) ≤ x − x²/2 + x³/3` for `x ≥ 0`. -/
theorem log_one_add_le_cubic {x : ℝ} (hx : 0 ≤ x) :
    Real.log (1 + x) ≤ x - x ^ 2 / 2 + x ^ 3 / 3 := by
  have hmono : MonotoneOn logAddDefect (Ici 0) := by
    apply monotoneOn_of_deriv_nonneg (convex_Ici 0)
    · intro y hy
      have hy0 : (0 : ℝ) ≤ y := hy
      exact ((hasDerivAt_logAddDefect (by linarith)).continuousAt).continuousWithinAt
    · intro y hy
      rw [interior_Ici] at hy
      have hy0 : (0 : ℝ) < y := hy
      exact (hasDerivAt_logAddDefect (by linarith)).differentiableAt.differentiableWithinAt
    · intro y hy
      rw [interior_Ici] at hy
      have hy0 : (0 : ℝ) < y := hy
      rw [(hasDerivAt_logAddDefect (by linarith)).deriv]
      positivity
  have h0 : logAddDefect 0 = 0 := by norm_num [logAddDefect]
  have := hmono Set.self_mem_Ici hx hx
  rw [h0] at this
  simp only [logAddDefect] at this
  linarith

/-- Defect function of the cubic upper bound for `log (1 − x)`. -/
noncomputable def logSubDefect (x : ℝ) : ℝ := -x - x ^ 2 / 2 - x ^ 3 / 3 - Real.log (1 - x)

theorem hasDerivAt_logSubDefect {x : ℝ} (hx : x < 1) :
    HasDerivAt logSubDefect (x ^ 3 / (1 - x)) x := by
  have h1x : (1 : ℝ) - x ≠ 0 := by linarith
  have hlog : HasDerivAt (fun y : ℝ => Real.log (1 - y)) (-(1 / (1 - x))) x := by
    have := (Real.hasDerivAt_log h1x).comp x ((hasDerivAt_id x).const_sub 1)
    simpa [one_div, mul_comm] using this
  have hpoly : HasDerivAt (fun y : ℝ => -y - y ^ 2 / 2 - y ^ 3 / 3) (-1 - x - x ^ 2) x := by
    have h := (((hasDerivAt_id x).neg.sub ((hasDerivAt_pow 2 x).div_const 2)).sub
      ((hasDerivAt_pow 3 x).div_const 3))
    simp only [Nat.cast_ofNat] at h
    convert h using 1
    push_cast; ring
  have := hpoly.sub hlog
  convert this using 1
  field_simp
  ring

/-- `log (1 − x) ≤ −x − x²/2 − x³/3` for `0 ≤ x < 1`. -/
theorem log_one_sub_le_cubic {x : ℝ} (hx : 0 ≤ x) (hx1 : x < 1) :
    Real.log (1 - x) ≤ -x - x ^ 2 / 2 - x ^ 3 / 3 := by
  have hmono : MonotoneOn logSubDefect (Ico 0 1) := by
    apply monotoneOn_of_deriv_nonneg (convex_Ico 0 1)
    · intro y hy
      exact ((hasDerivAt_logSubDefect hy.2).continuousAt).continuousWithinAt
    · intro y hy
      rw [interior_Ico] at hy
      exact (hasDerivAt_logSubDefect hy.2).differentiableAt.differentiableWithinAt
    · intro y hy
      rw [interior_Ico] at hy
      obtain ⟨hy0, hy1⟩ : 0 < y ∧ y < 1 := hy
      rw [(hasDerivAt_logSubDefect hy1).deriv]
      have h1 : (0 : ℝ) < 1 - y := by linarith
      positivity
  have h0 : logSubDefect 0 = 0 := by norm_num [logSubDefect]
  have := hmono ⟨le_refl 0, by norm_num⟩ ⟨hx, hx1⟩ hx
  rw [h0] at this
  simp only [logSubDefect] at this
  linarith

/-! ## 2. The two-point family -/

/-- The two-point policy `(1/2 + ε, 1/2 − ε)` on `Bool`. -/
noncomputable def twoPoint (ε : ℝ) : Bool → ℝ := fun b => if b then 1 / 2 + ε else 1 / 2 - ε

theorem twoPoint_isPosDist {ε : ℝ} (h0 : -(1 / 2 : ℝ) < ε) (h1 : ε < 1 / 2) :
    IsPosDist (twoPoint ε) := by
  constructor
  · intro b; cases b <;> simp [twoPoint] <;> linarith
  · simp [twoPoint]; ring

theorem twoPoint_zero_isPosDist : IsPosDist (twoPoint 0) :=
  twoPoint_isPosDist (by norm_num) (by norm_num)

theorem l1Dist_twoPoint {ε : ℝ} : l1Dist (twoPoint ε) (twoPoint 0) = 2 * |ε| := by
  simp only [l1Dist, twoPoint, Fintype.sum_bool]
  norm_num
  ring

theorem klDiv_twoPoint {ε : ℝ} :
    klDiv (twoPoint ε) (twoPoint 0)
      = (1 / 2 + ε) * Real.log (1 + 2 * ε) + (1 / 2 - ε) * Real.log (1 - 2 * ε) := by
  simp only [klDiv, twoPoint, Fintype.sum_bool]
  norm_num
  rw [show (1 / 2 + ε) / (1 / 2 : ℝ) = 1 + 2 * ε by ring,
    show (1 / 2 - ε) / (1 / 2 : ℝ) = 1 - 2 * ε by ring]

/-- Quantitative upper bound: `2 KL(q_ε ‖ q_0) ≤ 4ε² + (32/3) ε⁴`, i.e. the KL is
`2ε²` up to a quartic correction, matching the `L¹` distance `2ε` exactly at second
order. -/
theorem two_kl_twoPoint_le {ε : ℝ} (h0 : 0 ≤ ε) (h1 : ε < 1 / 2) :
    2 * klDiv (twoPoint ε) (twoPoint 0) ≤ 4 * ε ^ 2 + (32 / 3) * ε ^ 4 := by
  have hx0 : (0 : ℝ) ≤ 2 * ε := by linarith
  have hx1 : 2 * ε < 1 := by linarith
  have hA := log_one_add_le_cubic hx0
  have hB := log_one_sub_le_cubic hx0 hx1
  have hcA : (0 : ℝ) ≤ 1 / 2 + ε := by linarith
  have hcB : (0 : ℝ) ≤ 1 / 2 - ε := by linarith
  have hA' : (1 / 2 + ε) * Real.log (1 + 2 * ε)
      ≤ (1 / 2 + ε) * (2 * ε - (2 * ε) ^ 2 / 2 + (2 * ε) ^ 3 / 3) :=
    mul_le_mul_of_nonneg_left hA hcA
  have hB' : (1 / 2 - ε) * Real.log (1 - 2 * ε)
      ≤ (1 / 2 - ε) * (-(2 * ε) - (2 * ε) ^ 2 / 2 - (2 * ε) ^ 3 / 3) :=
    mul_le_mul_of_nonneg_left hB hcB
  rw [klDiv_twoPoint]
  nlinarith [hA', hB']

/-- On the two-point family the Pinsker ratio `2 KL/‖·‖₁²` is squeezed between `1`
and `1 + (8/3) ε²`. -/
theorem pinsker_ratio_bounds {ε : ℝ} (h0 : 0 < ε) (h1 : ε < 1 / 2) :
    1 ≤ 2 * klDiv (twoPoint ε) (twoPoint 0) / (l1Dist (twoPoint ε) (twoPoint 0)) ^ 2 ∧
      2 * klDiv (twoPoint ε) (twoPoint 0) / (l1Dist (twoPoint ε) (twoPoint 0)) ^ 2
        ≤ 1 + (8 / 3) * ε ^ 2 := by
  have hl1 : l1Dist (twoPoint ε) (twoPoint 0) = 2 * ε := by
    rw [l1Dist_twoPoint, abs_of_pos h0]
  have hsq : (l1Dist (twoPoint ε) (twoPoint 0)) ^ 2 = 4 * ε ^ 2 := by
    rw [hl1]; ring
  have hpos : (0 : ℝ) < 4 * ε ^ 2 := by positivity
  have hlow := pinsker (twoPoint_isPosDist (by linarith) h1).isDist twoPoint_zero_isPosDist
  have hup := two_kl_twoPoint_le h0.le h1
  rw [hsq] at *
  constructor
  · rw [le_div_iff₀ hpos]
    linarith
  · rw [div_le_iff₀ hpos]
    nlinarith

/-- **The Pinsker constant `2` is sharp.**  Along the two-point family the ratio
`2 KL/‖·‖₁²` converges to `1` as `ε ↓ 0`; hence no constant smaller than `2`
works in `RLHF.pinsker`, and the `β^{-1/2}` no-collapse rate of
`RLHF.gibbs_l1_le` cannot be improved by improving the Pinsker input. -/
theorem pinsker_ratio_tendsto_one :
    Tendsto (fun ε : ℝ =>
        2 * klDiv (twoPoint ε) (twoPoint 0) / (l1Dist (twoPoint ε) (twoPoint 0)) ^ 2)
      (𝓝[>] 0) (𝓝 1) := by
  have hlow : ∀ᶠ ε in 𝓝[>] (0 : ℝ),
      (1 : ℝ) ≤ 2 * klDiv (twoPoint ε) (twoPoint 0) /
        (l1Dist (twoPoint ε) (twoPoint 0)) ^ 2 := by
    filter_upwards [Ioo_mem_nhdsGT (by norm_num : (0:ℝ) < 1 / 2)] with ε hε
    exact (pinsker_ratio_bounds hε.1 hε.2).1
  have hup : ∀ᶠ ε in 𝓝[>] (0 : ℝ),
      2 * klDiv (twoPoint ε) (twoPoint 0) / (l1Dist (twoPoint ε) (twoPoint 0)) ^ 2
        ≤ 1 + (8 / 3) * ε ^ 2 := by
    filter_upwards [Ioo_mem_nhdsGT (by norm_num : (0:ℝ) < 1 / 2)] with ε hε
    exact (pinsker_ratio_bounds hε.1 hε.2).2
  have hR : Tendsto (fun ε : ℝ => 1 + (8 / 3) * ε ^ 2) (𝓝[>] (0 : ℝ)) (𝓝 1) := by
    have : Tendsto (fun ε : ℝ => 1 + (8 / 3) * ε ^ 2) (𝓝 (0 : ℝ)) (𝓝 1) := by
      have hc : Continuous (fun ε : ℝ => 1 + (8 / 3) * ε ^ 2) := by continuity
      simpa using (hc.tendsto 0)
    exact this.mono_left nhdsWithin_le_nhds
  exact tendsto_of_tendsto_of_tendsto_of_le_of_le' tendsto_const_nhds hR hlow hup

/-- **No constant below `2` works.**  For every `c < 2` there is a two-point pair on
which `‖q − p‖₁² ≤ c · KL(q ‖ p)` fails. -/
theorem pinsker_constant_optimal {c : ℝ} (hc : 0 < c) (hc2 : c < 2) :
    ∃ ε : ℝ, 0 < ε ∧ ε < 1 / 2 ∧
      c * klDiv (twoPoint ε) (twoPoint 0) < (l1Dist (twoPoint ε) (twoPoint 0)) ^ 2 := by
  obtain ⟨ε, hε0, hεs, hεb⟩ : ∃ ε : ℝ, 0 < ε ∧ ε < 1 / 2 ∧ (16 / 3) * c * ε ^ 2 < 4 - 2 * c := by
    have hgap : 0 < 4 - 2 * c := by linarith
    refine ⟨min (1 / 4) (Real.sqrt ((4 - 2 * c) / ((16 / 3) * c + 1)) / 2), ?_, ?_, ?_⟩
    · have : 0 < Real.sqrt ((4 - 2 * c) / ((16 / 3) * c + 1)) :=
        Real.sqrt_pos.mpr (by positivity)
      exact lt_min (by norm_num) (by linarith)
    · exact lt_of_le_of_lt (min_le_left _ _) (by norm_num)
    · have hle : min (1 / 4) (Real.sqrt ((4 - 2 * c) / ((16 / 3) * c + 1)) / 2)
          ≤ Real.sqrt ((4 - 2 * c) / ((16 / 3) * c + 1)) / 2 := min_le_right _ _
      have hnn : 0 ≤ min (1 / 4) (Real.sqrt ((4 - 2 * c) / ((16 / 3) * c + 1)) / 2) := by
        have : 0 ≤ Real.sqrt ((4 - 2 * c) / ((16 / 3) * c + 1)) := Real.sqrt_nonneg _
        exact le_min (by norm_num) (by linarith)
      have hsq : (min (1 / 4) (Real.sqrt ((4 - 2 * c) / ((16 / 3) * c + 1)) / 2)) ^ 2
          ≤ ((4 - 2 * c) / ((16 / 3) * c + 1)) / 4 := by
        have h2 := pow_le_pow_left₀ hnn hle 2
        have hs : (Real.sqrt ((4 - 2 * c) / ((16 / 3) * c + 1)) / 2) ^ 2
            = ((4 - 2 * c) / ((16 / 3) * c + 1)) / 4 := by
          rw [div_pow, Real.sq_sqrt (by positivity)]
          norm_num
        linarith [hs ▸ h2]
      have hden : (0 : ℝ) < (16 / 3) * c + 1 := by positivity
      have hkey : (16 / 3) * c * (((4 - 2 * c) / ((16 / 3) * c + 1)) / 4) < 4 - 2 * c := by
        have hrw : (16 / 3) * c * (((4 - 2 * c) / ((16 / 3) * c + 1)) / 4)
            = ((16 / 3) * c * (4 - 2 * c)) / (((16 / 3) * c + 1) * 4) := by
          field_simp
        rw [hrw, div_lt_iff₀ (by positivity)]
        nlinarith
      nlinarith [hsq]
  refine ⟨ε, hε0, hεs, ?_⟩
  have hl1 : (l1Dist (twoPoint ε) (twoPoint 0)) ^ 2 = 4 * ε ^ 2 := by
    rw [l1Dist_twoPoint, abs_of_pos hε0]; ring
  have hup := two_kl_twoPoint_le hε0.le hεs
  rw [hl1]
  have hKL : klDiv (twoPoint ε) (twoPoint 0) ≤ 2 * ε ^ 2 + (16 / 3) * ε ^ 4 := by linarith
  have h2 : c * klDiv (twoPoint ε) (twoPoint 0) ≤ c * (2 * ε ^ 2 + (16 / 3) * ε ^ 4) :=
    mul_le_mul_of_nonneg_left hKL hc.le
  have h3 : (16 / 3) * c * ε ^ 2 * ε ^ 2 < (4 - 2 * c) * ε ^ 2 :=
    mul_lt_mul_of_pos_right hεb (by positivity)
  nlinarith [h2, h3]

end RLHF