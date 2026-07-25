/-
# EML Interpolation Theory: The Hölder (`Lip_α`) Jackson Rate

`EML.LipschitzJacksonRate` proves the `α = 1` Jackson rate `O(1/n)` for the
width-`n` piecewise-linear EML interpolant. The mission conjecture is stated for
the full Hölder class `Lip_α`: width `O(ε^{-n/α})` for `f ∈ Lip_α(K)`. This file
proves exactly the one-variable case of that scaling.

For an `α`-Hölder `f` (i.e. `|f x − f y| ≤ L·|x − y|^α`, `0 < α`) the *same*
piecewise-linear interpolant `pwLinInterp` of `EML.LipschitzJacksonRate`
satisfies the uniform bound

  `|f x − pwLinInterp f n x| ≤ 2L / n^α`   on `[0,1]`.

Thus to reach accuracy `ε` one needs width `n = O(ε^{-1/α})` — the conjectured
`ε^{-n/α}` exponent in dimension `n = 1`. The `α = 1` line recovers (up to the
explicit constant) the Lipschitz rate of the companion file.

## Main results
- `holderInterp_error`: single-interval Hölder interpolation bound `2L·(b−a)^α`.
- `pwLinInterp_holder_error`: uniform Jackson rate `2L / n^α` on `[0,1]`.
- `pwLinInterp_holder_tendsto`: pointwise convergence to `f`.
-/
import Mathlib
import EML.LipschitzJacksonRate

noncomputable section

open Real

/-- **Single-interval Hölder Jackson lemma.** If `f` is `α`-Hölder with constant
`L` (`0 < α`), the linear interpolant through the endpoints of `[a,b]` has error
at most `2L·(b−a)^α` on the cell. For `α = 1` this is the Lipschitz bound. -/
theorem holderInterp_error (f : ℝ → ℝ) (L α : ℝ) (hα0 : 0 < α) (hL : 0 ≤ L)
    (hf : ∀ x y, |f x - f y| ≤ L * |x - y| ^ α)
    (a b x : ℝ) (hab : a < b) (hx : x ∈ Set.Icc a b) :
    |f x - (f a + (f b - f a)/(b - a) * (x - a))| ≤ 2 * L * (b - a) ^ α := by
  obtain ⟨hxa, hxb⟩ := hx
  have hba : 0 < b - a := by linarith
  have hxa0 : (0:ℝ) ≤ x - a := by linarith
  have h1 : |f x - f a| ≤ L * (b - a) ^ α := by
    refine le_trans (hf x a) ?_
    rw [abs_of_nonneg hxa0]
    apply mul_le_mul_of_nonneg_left _ hL
    exact Real.rpow_le_rpow hxa0 (by linarith) hα0.le
  have h2 : |(f b - f a)/(b - a) * (x - a)| ≤ L * (b - a) ^ α := by
    rw [abs_mul, abs_div, abs_of_pos hba, abs_of_nonneg hxa0]
    have hfb : |f b - f a| ≤ L * (b - a) ^ α := by
      refine le_trans (hf b a) ?_
      rw [abs_of_nonneg (by linarith : (0:ℝ) ≤ b - a)]
    have step : |f b - f a| / (b - a) * (x - a) ≤ |f b - f a| / (b - a) * (b - a) := by
      apply mul_le_mul_of_nonneg_left (by linarith); positivity
    refine le_trans step ?_
    rw [div_mul_cancel₀ _ hba.ne']; exact hfb
  calc |f x - (f a + (f b - f a)/(b - a) * (x - a))|
      = |(f x - f a) - (f b - f a)/(b - a) * (x - a)| := by ring_nf
    _ ≤ |f x - f a| + |(f b - f a)/(b - a) * (x - a)| := abs_sub _ _
    _ ≤ L * (b - a) ^ α + L * (b - a) ^ α := by linarith
    _ = 2 * L * (b - a) ^ α := by ring

/-- **Global Hölder Jackson rate.** For an `α`-Hölder `f` (`0 < α`), the width-`n`
piecewise-linear EML interpolant of `EML.LipschitzJacksonRate` approximates `f`
uniformly on `[0,1]` with error at most `2L / n^α`. To reach accuracy `ε` one
needs width `n = O(ε^{-1/α})`, the conjectured exponent in dimension one. -/
theorem pwLinInterp_holder_error (f : ℝ → ℝ) (L α : ℝ) (hα0 : 0 < α) (hL : 0 ≤ L)
    (hf : ∀ x y, |f x - f y| ≤ L * |x - y| ^ α)
    (n : ℕ) (hn : 1 ≤ n) (x : ℝ) (hx : x ∈ Set.Icc (0:ℝ) 1) :
    |f x - pwLinInterp f n x| ≤ 2 * L / (n:ℝ) ^ α := by
  have hnpos : (0:ℝ) < n := by exact_mod_cast hn
  obtain ⟨hlo, hhi⟩ := pwLinInterp_locate n hn x hx
  set k : ℕ := min (n-1) ⌊(n:ℝ) * x⌋₊ with hk
  set a : ℝ := (k:ℝ)/n with ha
  set b : ℝ := ((k:ℝ)+1)/n with hb
  have hab : a < b := by rw [ha, hb, div_lt_div_iff_of_pos_right hnpos]; linarith
  have hba : b - a = 1/n := by rw [ha, hb]; field_simp; ring
  have heq : pwLinInterp f n x = f a + (f b - f a)/(b - a) * (x - a) := rfl
  rw [heq]
  have hmain := holderInterp_error f L α hα0 hL hf a b x hab ⟨hlo, hhi⟩
  -- rewrite (1/n)^α = 1 / n^α
  have hrw : (1 / (n:ℝ)) ^ α = 1 / (n:ℝ) ^ α := by
    rw [Real.div_rpow (by norm_num) hnpos.le, Real.one_rpow]
  calc |f x - (f a + (f b - f a)/(b - a) * (x - a))|
      ≤ 2 * L * (b - a) ^ α := hmain
    _ = 2 * L * (1 / (n:ℝ)) ^ α := by rw [hba]
    _ = 2 * L * (1 / (n:ℝ) ^ α) := by rw [hrw]
    _ = 2 * L / (n:ℝ) ^ α := by ring

/-- **Convergence (Hölder case).** For each `x ∈ [0,1]` and `α`-Hölder `f`, the
width-`n` interpolants converge to `f x`. -/
theorem pwLinInterp_holder_tendsto (f : ℝ → ℝ) (L α : ℝ) (hα0 : 0 < α) (hL : 0 ≤ L)
    (hf : ∀ x y, |f x - f y| ≤ L * |x - y| ^ α)
    (x : ℝ) (hx : x ∈ Set.Icc (0:ℝ) 1) :
    Filter.Tendsto (fun n : ℕ => pwLinInterp f n x) Filter.atTop (nhds (f x)) := by
  rw [Metric.tendsto_nhds]
  intro ε hε
  -- n^α → ∞, so 2L / n^α → 0
  have hpow : Filter.Tendsto (fun n : ℕ => (n:ℝ) ^ α) Filter.atTop Filter.atTop :=
    (tendsto_rpow_atTop hα0).comp tendsto_natCast_atTop_atTop
  have htend : Filter.Tendsto (fun n : ℕ => 2 * L / (n:ℝ) ^ α) Filter.atTop (nhds 0) :=
    Filter.Tendsto.div_atTop tendsto_const_nhds hpow
  rw [Metric.tendsto_nhds] at htend
  have := htend ε hε
  filter_upwards [this, Filter.eventually_ge_atTop 1] with n hn1 hn2
  have hbound := pwLinInterp_holder_error f L α hα0 hL hf n hn2 x hx
  rw [Real.dist_eq, abs_sub_comm]
  refine lt_of_le_of_lt hbound ?_
  have hnn : (0:ℝ) ≤ 2 * L / (n:ℝ) ^ α := by
    apply div_nonneg (by linarith)
    positivity
  rw [Real.dist_eq, sub_zero, abs_of_nonneg hnn] at hn1
  exact hn1

/-
-- !-- Lab Notes -- !--

## Hypothesis (Hypothesizer)
The conjecture is for `Lip_α`, not just `Lip_1`. Bold claim: the *identical*
piecewise-linear EML interpolant attains the full Hölder Jackson scaling
`2L / n^α`, so the width needed for accuracy `ε` scales as `ε^{-1/α}` — the
mission's `ε^{-n/α}` with `n = 1`.

## Experiment (Experimenter)
On a cell of width `h`, both `|f x − f a| ≤ L h^α` and the slope contribution
`|f b − f a|/h · (x − a) ≤ (L h^α / h)·h = L h^α` are controlled by `L h^α`; their
sum is `2L h^α`. With `h = 1/n` this is `2L / n^α`. The slope estimate is where
`α < 1` bites: the divided difference is `O(h^{α-1})`, which blows up as `h → 0`,
but multiplied by `(x − a) ≤ h` it is tamed back to `O(h^α)`.

## Analysis (Analyst)
"True and a strict generalization." The Lipschitz file is the `α = 1` slice.
The only new ingredient is `Real.rpow` monotonicity (`Real.rpow_le_rpow`) and the
identity `(1/n)^α = 1/n^α` (`Real.div_rpow`). The convergence proof reduces to
`n^α → ∞` (`tendsto_rpow_atTop`) and `const / (→∞) → 0`.

## Critique (Critic)
- Not trivial: genuine `rpow` analysis, divided-difference taming, and a limit
  argument through `tendsto_rpow_atTop`.
- Boundary: `α > 0` is essential (at `α = 0` the modulus need not vanish, so no
  rate); the construction and clamp are inherited (and reused, not re-proved)
  from `EML.LipschitzJacksonRate`.
- Genuinely extends the catalog: it lifts the `α = 1` rate to all `α ∈ (0,∞)`
  while reusing `pwLinInterp` and `pwLinInterp_locate` verbatim.

## Synthesis (PI)
A single explicit EML construction realises the conjectured Hölder Jackson
scaling `n^{-α}` in one variable, unifying the Lipschitz and Hölder regimes and
making the `ε^{-1/α}` width law constructive.
-/
end