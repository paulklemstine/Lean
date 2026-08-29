/-
# The which-factor wall, cycle II: the exact resolution law is a square root

`Algebra.WhichFactorWallInvariant` established that the wall (binary capacity)
determines the class imbalance *Lipschitz-stably* only away from balance, and
that **no** linear inversion constant survives as the imbalance approaches
`1/2` (`no_uniform_inversion_constant`).  That looks like bad news for the
trace battery: the mission brief concluded that "the wall carries almost no
information and should be dropped from the battery report".

This file proves that this conclusion is *wrong*, and replaces it by the exact
law.  The wall is invertible everywhere — uniformly, with no guard at all — but
with a **square-root** modulus of continuity, and the exponent `1/2` is optimal:

* `four_mul_sub_le_log_ratio` — the pointwise derivative bound
  `4 (1/2 - x) ≤ log (1-x) - log x` on `(0, 1/2]`, i.e. `binEntropy` is
  `2`-strongly concave-at-balance in the integrated sense.
* `binEntropy_diff_ge_two_mul_sq` — **Pinsker-type inverse bound**:
  `2 (q - p)² ≤ binEntropy q - binEntropy p` for `0 ≤ p ≤ q ≤ 1/2`.
  This is the sharp global replacement for the (false) linear conjecture.
* `imbalance_sqrt_stability` — **unconditional cross-population stability**:
  if two walls agree within `ε` then the imbalances agree within `√(ε/2)`.
  No guard `η`, no hypothesis beyond `p, q ∈ [0, 1/2]`.
* `binary_wall_sqrt_stability` — the same for two binary statistics on two
  different finite populations.
* `binEntropy_gap_two_sided` — the exact quadratic law at balance:
  `2 t² ≤ log 2 - binEntropy (1/2 - t) ≤ 4 t²`.
* `sqrt_law_sharp` — the exponent `1/2` cannot be improved: for every small `ε`
  there are imbalances whose walls agree within `ε` while the imbalances differ
  by `√ε / 2`.

Consequence for the battery report: a wall value is *never* uninformative; its
resolution is `Θ(ε)` away from balance and `Θ(√ε)` at balance.  A reported wall
should be published together with the resolution its error bar implies.
-/
import Algebra.WhichFactorWallInvariant

namespace WhichFactorWall

open Real Set

/-! ## 1.  A derivative bound with the right behaviour at balance -/

private lemma hasDerivAt_psi {y : ℝ} (hy0 : y ≠ 0) (hy1 : (1 : ℝ) - y ≠ 0) :
    HasDerivAt (fun z : ℝ => log (1 - z) - log z + 4 * z - 2) (-(1 - y)⁻¹ - y⁻¹ + 4) y := by
  have h1 : HasDerivAt (fun z : ℝ => (1 : ℝ) - z) (-1) y := by
    simpa using (hasDerivAt_const y (1 : ℝ)).sub (hasDerivAt_id y)
  have h2 : HasDerivAt (fun z : ℝ => log (1 - z)) (-(1 - y)⁻¹) y := by
    have h := (Real.hasDerivAt_log hy1).comp y h1
    simpa [mul_comm] using h
  have h3 := ((h2.sub (Real.hasDerivAt_log hy0)).add ((hasDerivAt_id y).const_mul 4)).sub_const 2
  convert h3 using 1
  ring

/-- **The slope of `binEntropy` dominates the linear function `4 (1/2 - x)`.**
Equivalently `log ((1-x)/x) ≥ 4 (1/2 - x)` on `(0, 1/2]`: the tangent-line
comparison that makes the binary entropy `2`-strongly concave at balance. -/
theorem four_mul_sub_le_log_ratio {x : ℝ} (hx0 : 0 < x) (hx : x ≤ 2⁻¹) :
    4 * (2⁻¹ - x) ≤ log (1 - x) - log x := by
  have hanti : AntitoneOn (fun z : ℝ => log (1 - z) - log z + 4 * z - 2) (Icc x 2⁻¹) := by
    apply antitoneOn_of_deriv_nonpos (convex_Icc x 2⁻¹)
    · intro y hy
      simp only [mem_Icc] at hy
      exact ((hasDerivAt_psi (by linarith [hy.1] : y ≠ 0)
        (by intro h; nlinarith [hy.2])).differentiableAt.continuousAt).continuousWithinAt
    · rw [interior_Icc]
      intro y hy
      simp only [mem_Ioo] at hy
      exact (hasDerivAt_psi (by linarith [hy.1] : y ≠ 0)
        (by intro h; nlinarith [hy.2])).differentiableAt.differentiableWithinAt
    · rw [interior_Icc]
      intro y hy
      simp only [mem_Ioo] at hy
      have hy0 : (0 : ℝ) < y := lt_trans hx0 hy.1
      have hy1 : y < 1 := by linarith [hy.2]
      have hne0 : y ≠ 0 := ne_of_gt hy0
      have hne1 : (1 : ℝ) - y ≠ 0 := by intro h; nlinarith
      rw [(hasDerivAt_psi hne0 hne1).deriv]
      have key : -(1 - y)⁻¹ - y⁻¹ + 4 = -((2 * y - 1) ^ 2 / (y * (1 - y))) := by
        field_simp
        ring
      rw [key]
      have hnn : 0 ≤ (2 * y - 1) ^ 2 / (y * (1 - y)) := div_nonneg (sq_nonneg _) (by nlinarith)
      linarith
  have h := hanti (left_mem_Icc.2 hx) (right_mem_Icc.2 hx) hx
  simp only at h
  norm_num at h
  linarith

/-! ## 2.  The Pinsker-type inverse bound -/

private lemma hasDerivAt_entropyPlusSq {x : ℝ} (hx0 : x ≠ 0) (hx1 : x ≠ 1) :
    HasDerivAt (fun z : ℝ => binEntropy z + 2 * (2⁻¹ - z) ^ 2)
      (log (1 - x) - log x - 4 * (2⁻¹ - x)) x := by
  have h1 : HasDerivAt (fun z : ℝ => (2⁻¹ - z : ℝ)) (-1) x := by
    simpa using (hasDerivAt_const x (2⁻¹ : ℝ)).sub (hasDerivAt_id x)
  have h2 : HasDerivAt (fun z : ℝ => 2 * (2⁻¹ - z : ℝ) ^ 2) (2 * (2 * (2⁻¹ - x) * (-1))) x :=
    ((h1.pow 2).const_mul 2).congr_deriv (by ring)
  have h3 := (Real.hasDerivAt_binEntropy hx0 hx1).add h2
  convert h3 using 1
  ring

/-- The "entropy plus quadratic defect" `binEntropy x + 2 (1/2 - x)²` is monotone on
the balanced side.  This is the integrated form of `four_mul_sub_le_log_ratio`. -/
theorem monotoneOn_binEntropy_add_sq :
    MonotoneOn (fun z : ℝ => binEntropy z + 2 * (2⁻¹ - z) ^ 2) (Icc 0 2⁻¹) := by
  have hcont : ContinuousOn (fun z : ℝ => binEntropy z + 2 * (2⁻¹ - z) ^ 2) (Icc 0 2⁻¹) :=
    (Real.binEntropy_continuous.add (by fun_prop)).continuousOn
  apply monotoneOn_of_deriv_nonneg (convex_Icc 0 2⁻¹) hcont
  · rw [interior_Icc]
    intro y hy
    simp only [mem_Ioo] at hy
    exact (hasDerivAt_entropyPlusSq (by linarith [hy.1] : y ≠ 0)
      (by intro h; rw [h] at hy; linarith [hy.2])).differentiableAt.differentiableWithinAt
  · rw [interior_Icc]
    intro y hy
    simp only [mem_Ioo] at hy
    rw [(hasDerivAt_entropyPlusSq (by linarith [hy.1] : y ≠ 0)
      (by intro h; rw [h] at hy; linarith [hy.2])).deriv]
    linarith [four_mul_sub_le_log_ratio hy.1 hy.2.le]

/-- **Pinsker-type inverse bound for the wall.**  On the balanced side the capacity
gain between two imbalances is at least twice the squared gap.  Unlike the
refuted linear bound, this holds with an absolute constant, uniformly up to
`1/2`. -/
theorem binEntropy_diff_ge_two_mul_sq {p q : ℝ} (hp : 0 ≤ p) (hpq : p ≤ q) (hq : q ≤ 2⁻¹) :
    2 * (q - p) ^ 2 ≤ binEntropy q - binEntropy p := by
  have h := monotoneOn_binEntropy_add_sq ⟨hp, le_trans hpq hq⟩ ⟨le_trans hp hpq, hq⟩ hpq
  simp only at h
  nlinarith [h, sub_nonneg.2 hpq]

/-- Symmetric form: `2 |p - q|² ≤ |wall gap|` on `[0, 1/2]`. -/
theorem two_mul_sq_le_abs_binEntropy_sub {p q : ℝ} (hp : p ∈ Icc (0 : ℝ) 2⁻¹)
    (hq : q ∈ Icc (0 : ℝ) 2⁻¹) : 2 * (p - q) ^ 2 ≤ |binEntropy p - binEntropy q| := by
  rcases le_total p q with h | h
  · have h1 := binEntropy_diff_ge_two_mul_sq hp.1 h hq.2
    have h2 : binEntropy q - binEntropy p ≤ |binEntropy p - binEntropy q| := by
      rw [abs_sub_comm]; exact le_abs_self _
    nlinarith [h1, h2]
  · have h1 := binEntropy_diff_ge_two_mul_sq hq.1 h hp.2
    have h2 : binEntropy p - binEntropy q ≤ |binEntropy p - binEntropy q| := le_abs_self _
    nlinarith [h1, h2]

/-! ## 3.  Unconditional square-root stability of the wall -/

/-- **The corrected cross-population invariant, with no guard.**  Two imbalances in
`[0, 1/2]` whose walls agree within `ε` agree within `√(ε/2)`.  This holds all
the way up to balance, where the linear bound of
`WhichFactorWall.imbalance_dist_le` degenerates. -/
theorem imbalance_sqrt_stability {p q ε : ℝ} (hp : p ∈ Icc (0 : ℝ) 2⁻¹)
    (hq : q ∈ Icc (0 : ℝ) 2⁻¹) (hε : |binEntropy p - binEntropy q| ≤ ε) :
    |p - q| ≤ Real.sqrt (ε / 2) := by
  have h := two_mul_sq_le_abs_binEntropy_sub hp hq
  have h2 : (p - q) ^ 2 ≤ ε / 2 := by linarith
  exact Real.abs_le_sqrt h2

/-- **Cross-population form.**  Two binary statistics on two different finite
populations whose empirical entropies agree within `ε` have class imbalances
agreeing within `√(ε/2)` — no hypothesis beyond being on the balanced side. -/
theorem binary_wall_sqrt_stability {Ω₁ Ω₂ : Type*} [Fintype Ω₁] [Nonempty Ω₁] [Fintype Ω₂]
    [Nonempty Ω₂] {α₁ α₂ : Type*} [DecidableEq α₁] [DecidableEq α₂]
    (f : Ω₁ → α₁) (g : Ω₂ → α₂) {a b : α₁} {c e : α₂} {ε : ℝ}
    (hab : a ≠ b) (hce : c ≠ e) (hf : img f = {a, b}) (hg : img g = {c, e})
    (hpf : (cnt f a : ℝ) / (Fintype.card Ω₁ : ℝ) ∈ Icc (0 : ℝ) 2⁻¹)
    (hpg : (cnt g c : ℝ) / (Fintype.card Ω₂ : ℝ) ∈ Icc (0 : ℝ) 2⁻¹)
    (hcap : |H f - H g| ≤ ε) :
    |(cnt f a : ℝ) / (Fintype.card Ω₁ : ℝ) - (cnt g c : ℝ) / (Fintype.card Ω₂ : ℝ)|
      ≤ Real.sqrt (ε / 2) := by
  have h1 := H_two_values f hab hf
  have h2 := H_two_values g hce hg
  exact imbalance_sqrt_stability hpf hpg (by rw [← h1, ← h2]; exact hcap)

/-! ## 4.  The exact quadratic law at balance, and optimality of the exponent -/

/-- **Two-sided quadratic law at balance.**  `2 t² ≤ log 2 - binEntropy (1/2 - t) ≤ 4 t²`.
The upper bound is `log_two_sub_binEntropy_le_sq`; the lower bound is the
Pinsker-type inequality above.  So the capacity deficit at balance is exactly of
order `t²`, and the two constants `2` and `4` bracket it. -/
theorem binEntropy_gap_two_sided {t : ℝ} (ht0 : 0 ≤ t) (ht : t < 2⁻¹) :
    2 * t ^ 2 ≤ log 2 - binEntropy (2⁻¹ - t) ∧
      log 2 - binEntropy (2⁻¹ - t) ≤ 4 * t ^ 2 := by
  refine ⟨?_, log_two_sub_binEntropy_le_sq ht0 ht⟩
  have h := binEntropy_diff_ge_two_mul_sq (p := 2⁻¹ - t) (q := 2⁻¹)
    (by linarith) (by linarith) (le_refl _)
  rw [Real.binEntropy_two_inv] at h
  have hsq : (2⁻¹ - (2⁻¹ - t) : ℝ) ^ 2 = t ^ 2 := by ring_nf
  rw [hsq] at h
  linarith

/-- **The exponent `1/2` in `imbalance_sqrt_stability` is optimal.**  For every
`0 < ε ≤ 1/4` there are two imbalances whose walls agree within `ε` while the
imbalances themselves differ by `√ε / 2`.  Hence no bound of the form
`|p - q| ≤ C ε^α` with `α > 1/2` can hold. -/
theorem sqrt_law_sharp {ε : ℝ} (hε0 : 0 < ε) (hε : ε ≤ 4⁻¹) :
    ∃ p q : ℝ, p ∈ Icc (0 : ℝ) 2⁻¹ ∧ q ∈ Icc (0 : ℝ) 2⁻¹ ∧
      |binEntropy p - binEntropy q| ≤ ε ∧ Real.sqrt ε / 2 ≤ |p - q| := by
  set t : ℝ := Real.sqrt ε / 2 with hts
  have hsq : Real.sqrt ε ^ 2 = ε := Real.sq_sqrt hε0.le
  have hspos : 0 < Real.sqrt ε := Real.sqrt_pos.2 hε0
  have hshalf : Real.sqrt ε ≤ 2⁻¹ := by
    nlinarith [hsq, hspos, hε]
  have ht0 : 0 < t := by rw [hts]; linarith
  have ht4 : t ≤ 4⁻¹ := by rw [hts]; linarith
  refine ⟨2⁻¹ - t, 2⁻¹, ⟨by linarith, by linarith⟩, ⟨by norm_num, le_refl _⟩, ?_, ?_⟩
  · have hquad := log_two_sub_binEntropy_le_sq ht0.le (by linarith)
    have hle : binEntropy (2⁻¹ - t) ≤ log 2 := by
      simpa using (Real.binEntropy_le_log_two (p := 2⁻¹ - t))
    rw [Real.binEntropy_two_inv, abs_of_nonpos (by linarith), neg_sub]
    have h4 : 4 * t ^ 2 = ε := by rw [hts]; nlinarith [hsq]
    linarith
  · rw [show (2⁻¹ - t : ℝ) - 2⁻¹ = -t by ring, abs_neg, abs_of_nonneg ht0.le]

end WhichFactorWall