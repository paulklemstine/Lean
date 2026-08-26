import Mathlib
import Probability.SpikeInclusionGeometry
import Probability.SpikeQuantileIdentity

/-!
# The continuum quantile law of the window residue

`Catalog/Probability/SpikeQuantileIdentity.lean` proves the exact discrete
quantile identity

`#{ j ∈ W N : residue N j ≤ x } = min (3 isqrt N) (isqrt (N + x)) - isqrt N`.

This file closes the remaining, *asymptotic* half of future direction 1: the
limit law of the rescaled residue `v / s²` under the uniform position law on the
window.  Everything is proved with an explicit, non-asymptotic error term, so the
limit statement is a corollary rather than the primitive result.

Main results (`Spike.Quantile`):

* `card_sublevel_sq` : on a perfect-square modulus `N = M²` (where the integer
  and real square roots agree, so no rounding of the anchor occurs) the sublevel
  count is exactly `isqrt (M² + x) - M` as long as `x ≤ 8 M²`, i.e. as long as
  the threshold stays inside the window;
* `quantile_law_error` : the **Kolmogorov distance bound**
  `| F_M(x) - (√(1 + x/M²) - 1)/2 | ≤ 1/(2M)`
  where `F_M(x)` is the empirical fraction of window positions with residue at
  most `x`.  The limit c.d.f. `y ↦ (√(1+y) - 1)/2` is precisely the law of
  `(1 + 2U)² - 1` for `U` uniform on `[0,1]`, which is the conjectured law;
* `quantile_tendsto` : consequently, for every level `y ∈ [0,8]` the empirical
  fraction below `y M²` converges to `(√(1+y) - 1)/2`;
* `decile_law_exact` : at the round-85 decile level `y = 11/25` the limit law
  returns exactly `1/10`, and on the divisible moduli `N = (5m)²` the empirical
  fraction *equals* `1/10` with no error at all — the decile statistic and the
  magnitude statistic agree exactly, not just in the limit.

Interpretation: a first-decile analysis on this window is a `v ≤ 0.44 s²`
analysis with an error of at most one position, at every scale.  There is no
asymptotic regime in which the positional cut carries information beyond the
magnitude cut.
-/

namespace Spike.Quantile

open Spike Filter

/-! ### Comparison of the integer and real square roots -/

/-- The integer square root never exceeds the real one. -/
theorem natSqrt_le_sqrt (m : ℕ) : (Nat.sqrt m : ℝ) ≤ Real.sqrt m := by
  have h : ((Nat.sqrt m : ℝ)) ^ 2 ≤ (m : ℝ) := by exact_mod_cast Nat.sqrt_le' m
  nlinarith [Real.sq_sqrt (by positivity : (0:ℝ) ≤ (m : ℝ)), Real.sqrt_nonneg (m : ℝ),
    Nat.cast_nonneg (α := ℝ) (Nat.sqrt m)]

/-- The real square root is less than one more than the integer one. -/
theorem sqrt_lt_natSqrt_succ (m : ℕ) : Real.sqrt m < (Nat.sqrt m : ℝ) + 1 := by
  have h0 : m < (Nat.sqrt m + 1) ^ 2 := by simpa [pow_two] using Nat.lt_succ_sqrt' m
  have h : (m : ℝ) < ((Nat.sqrt m : ℝ) + 1) ^ 2 := by exact_mod_cast h0
  nlinarith [Real.sq_sqrt (by positivity : (0:ℝ) ≤ (m : ℝ)), Real.sqrt_nonneg (m : ℝ),
    Nat.cast_nonneg (α := ℝ) (Nat.sqrt m)]

/-- The rounding error of the integer square root, in the form used below. -/
theorem abs_natSqrt_sub_sqrt_le (m : ℕ) : |(Nat.sqrt m : ℝ) - Real.sqrt m| ≤ 1 := by
  have h1 := natSqrt_le_sqrt m
  have h2 := sqrt_lt_natSqrt_succ m
  rw [abs_le]
  constructor <;> linarith

/-! ### The exact sublevel count on a perfect-square modulus -/

/-- The window of a perfect square `M²` has exactly `2M` positions. -/
theorem window_sq_card (M : ℕ) : (window (M ^ 2)).card = 2 * M := by
  rw [window, Nat.card_Icc, Nat.sqrt_eq' M]
  omega

/-- **Exact sublevel count.**  For a threshold inside the window
(`x ≤ 8 M²`) the number of window positions with residue at most `x` is
`isqrt (M² + x) - M`. -/
theorem card_sublevel_sq (M x : ℕ) (hx : x ≤ 8 * M ^ 2) :
    ((window (M ^ 2)).filter (fun j => residue (M ^ 2) j ≤ x)).card
      = Nat.sqrt (M ^ 2 + x) - M := by
  have h1 : Nat.sqrt (M ^ 2) = M := Nat.sqrt_eq' M
  have h2 : Nat.sqrt (M ^ 2 + x) ≤ 3 * M := by
    have hle : M ^ 2 + x ≤ (3 * M) ^ 2 := by nlinarith
    calc Nat.sqrt (M ^ 2 + x) ≤ Nat.sqrt ((3 * M) ^ 2) := Nat.sqrt_le_sqrt hle
      _ = 3 * M := Nat.sqrt_eq' _
  rw [card_sublevel (N := M ^ 2) x, h1]
  omega

/-- The anchor bound: the sublevel count is nonnegative in the integers. -/
theorem le_natSqrt_add (M x : ℕ) : M ≤ Nat.sqrt (M ^ 2 + x) := by
  have := Nat.sqrt_le_sqrt (Nat.le_add_right (M ^ 2) x)
  rwa [Nat.sqrt_eq' M] at this

/-! ### The limit law, with an explicit error term -/

/-- The empirical fraction of window positions of the modulus `M²` whose residue
is at most `x`. -/
noncomputable def empFrac (M x : ℕ) : ℝ :=
  (((window (M ^ 2)).filter (fun j => residue (M ^ 2) j ≤ x)).card : ℝ) / (2 * M)

/-- The conjectured limit c.d.f.: the law of `(1 + 2U)² - 1` for `U` uniform on
`[0,1]`, i.e. `y ↦ (√(1+y) - 1)/2`. -/
noncomputable def limitCDF (y : ℝ) : ℝ := (Real.sqrt (1 + y) - 1) / 2

/-- Rewriting the limit c.d.f. at the rescaled threshold. -/
theorem limitCDF_eq (M x : ℕ) (hM : 0 < M) :
    limitCDF ((x : ℝ) / (M : ℝ) ^ 2)
      = (Real.sqrt ((M : ℝ) ^ 2 + x) - M) / (2 * M) := by
  have hM' : (0 : ℝ) < M := by exact_mod_cast hM
  have h : (1 + (x : ℝ) / (M : ℝ) ^ 2) = ((M : ℝ) ^ 2 + x) / (M : ℝ) ^ 2 := by field_simp
  rw [limitCDF, h, Real.sqrt_div (by positivity), Real.sqrt_sq hM'.le]
  field_simp

/-- **Kolmogorov bound for the quantile law.**  At every scale, the empirical
distribution function of the residue on the window differs from the continuum
law `(√(1+y) - 1)/2` by at most one position, i.e. by at most `1/(2M)`. -/
theorem quantile_law_error (M x : ℕ) (hM : 0 < M) (hx : x ≤ 8 * M ^ 2) :
    |empFrac M x - limitCDF ((x : ℝ) / (M : ℝ) ^ 2)| ≤ 1 / (2 * M) := by
  have hM' : (0 : ℝ) < M := by exact_mod_cast hM
  have hcard := card_sublevel_sq M x hx
  have hle := le_natSqrt_add M x
  have hcast : (((window (M ^ 2)).filter (fun j => residue (M ^ 2) j ≤ x)).card : ℝ)
      = (Nat.sqrt (M ^ 2 + x) : ℝ) - (M : ℝ) := by
    rw [hcard, Nat.cast_sub hle]
  have hreal : Real.sqrt ((M : ℝ) ^ 2 + x) = Real.sqrt ((M ^ 2 + x : ℕ) : ℝ) := by
    push_cast; ring_nf
  have herr : |(Nat.sqrt (M ^ 2 + x) : ℝ) - Real.sqrt ((M : ℝ) ^ 2 + x)| ≤ 1 := by
    rw [hreal]; exact abs_natSqrt_sub_sqrt_le _
  rw [empFrac, hcast, limitCDF_eq M x hM, div_sub_div_same]
  rw [abs_div, abs_of_pos (by positivity : (0:ℝ) < 2 * (M : ℝ))]
  have hnum : |(Nat.sqrt (M ^ 2 + x) : ℝ) - (M : ℝ) - (Real.sqrt ((M : ℝ) ^ 2 + x) - M)| ≤ 1 := by
    rw [show (Nat.sqrt (M ^ 2 + x) : ℝ) - (M : ℝ) - (Real.sqrt ((M : ℝ) ^ 2 + x) - M)
        = (Nat.sqrt (M ^ 2 + x) : ℝ) - Real.sqrt ((M : ℝ) ^ 2 + x) by ring]
    exact herr
  gcongr

/-- **The continuum limit law.**  For every level `y ∈ [0,8]` the empirical
fraction of window positions with residue at most `y M²` converges, as the
modulus grows, to `(√(1+y) - 1)/2`. -/
theorem quantile_tendsto (y : ℝ) (hy : 0 ≤ y) (hy8 : y ≤ 8) :
    Tendsto (fun M : ℕ => empFrac M ⌊y * (M : ℝ) ^ 2⌋₊) atTop (nhds (limitCDF y)) := by
  set u : ℕ → ℝ := fun M => ((⌊y * (M : ℝ) ^ 2⌋₊ : ℕ) : ℝ) / (M : ℝ) ^ 2 with hu_def
  -- the rescaled thresholds converge to `y`
  have hufloor : ∀ M : ℕ, 0 < M → |u M - y| ≤ 1 / (M : ℝ) := by
    intro M hM
    have hM' : (0 : ℝ) < M := by exact_mod_cast hM
    have hM2 : (0 : ℝ) < (M : ℝ) ^ 2 := by positivity
    have h1 : ((⌊y * (M : ℝ) ^ 2⌋₊ : ℕ) : ℝ) ≤ y * (M : ℝ) ^ 2 :=
      Nat.floor_le (by positivity)
    have h2 : y * (M : ℝ) ^ 2 - 1 < ((⌊y * (M : ℝ) ^ 2⌋₊ : ℕ) : ℝ) := by
      have := Nat.lt_floor_add_one (y * (M : ℝ) ^ 2)
      linarith
    have hMle : (1 : ℝ) ≤ (M : ℝ) := by exact_mod_cast hM
    have heq : u M - y = (((⌊y * (M : ℝ) ^ 2⌋₊ : ℕ) : ℝ) - y * (M : ℝ) ^ 2) / (M : ℝ) ^ 2 := by
      rw [hu_def]; field_simp
    have hnum : |((⌊y * (M : ℝ) ^ 2⌋₊ : ℕ) : ℝ) - y * (M : ℝ) ^ 2| ≤ 1 := by
      rw [abs_le]; constructor <;> linarith
    rw [heq, abs_div, abs_of_pos hM2]
    calc |((⌊y * (M : ℝ) ^ 2⌋₊ : ℕ) : ℝ) - y * (M : ℝ) ^ 2| / (M : ℝ) ^ 2
        ≤ 1 / (M : ℝ) ^ 2 := by gcongr
      _ ≤ 1 / (M : ℝ) := by
          apply one_div_le_one_div_of_le hM'
          nlinarith
  have hu : Tendsto u atTop (nhds y) := by
    have hbound : ∀ᶠ M : ℕ in atTop, ‖u M - y‖ ≤ 1 / (M : ℝ) := by
      filter_upwards [eventually_gt_atTop 0] with M hM
      simpa [Real.norm_eq_abs] using hufloor M hM
    have hzero : Tendsto (fun M : ℕ => 1 / (M : ℝ)) atTop (nhds 0) :=
      tendsto_one_div_atTop_nhds_zero_nat
    have := squeeze_zero_norm' hbound hzero
    simpa using this.add (tendsto_const_nhds (x := y) (f := atTop (α := ℕ)))
  -- the limit c.d.f. is continuous
  have hcont : Continuous limitCDF := by
    unfold limitCDF
    fun_prop
  have hg : Tendsto (fun M : ℕ => limitCDF (u M)) atTop (nhds (limitCDF y)) :=
    (hcont.tendsto y).comp hu
  -- the difference vanishes
  have hdiff : Tendsto (fun M : ℕ => empFrac M ⌊y * (M : ℝ) ^ 2⌋₊ - limitCDF (u M))
      atTop (nhds 0) := by
    have hbound : ∀ᶠ M : ℕ in atTop,
        ‖empFrac M ⌊y * (M : ℝ) ^ 2⌋₊ - limitCDF (u M)‖ ≤ 1 / (M : ℝ) := by
      filter_upwards [eventually_gt_atTop 0] with M hM
      have hM' : (0 : ℝ) < M := by exact_mod_cast hM
      have hx : ⌊y * (M : ℝ) ^ 2⌋₊ ≤ 8 * M ^ 2 := by
        have h1 : y * (M : ℝ) ^ 2 ≤ ((8 * M ^ 2 : ℕ) : ℝ) := by
          push_cast
          nlinarith [sq_nonneg ((M : ℝ))]
        simpa using Nat.floor_le_of_le h1
      have h := quantile_law_error M ⌊y * (M : ℝ) ^ 2⌋₊ hM hx
      have hhalf : 1 / (2 * (M : ℝ)) ≤ 1 / (M : ℝ) := by
        apply div_le_div_of_nonneg_left (by norm_num) hM'
        linarith
      simpa [Real.norm_eq_abs, hu_def] using h.trans hhalf
    exact squeeze_zero_norm' hbound tendsto_one_div_atTop_nhds_zero_nat
  simpa using hdiff.add hg

/-! ### The decile point: the limit law is attained exactly -/

/-- At the round-85 decile level `y = 11/25` the limit law returns exactly
`1/10`. -/
theorem limitCDF_decile : limitCDF (11 / 25) = 1 / 10 := by
  rw [limitCDF]
  have h : (1 : ℝ) + 11 / 25 = (6 / 5) ^ 2 := by norm_num
  rw [h, Real.sqrt_sq (by norm_num)]
  norm_num

/-- **The decile statistic is exact, not merely asymptotic.**  On the divisible
moduli `N = (5m)²` the fraction of window positions in the first decile equals
the limit-law value `1/10` with zero error. -/
theorem decile_law_exact (m : ℕ) (hm : 0 < m) :
    ((((window ((5 * m) ^ 2)).filter (fun j => inFirstDecile ((5 * m) ^ 2) j)).card : ℝ)
        / ((window ((5 * m) ^ 2)).card : ℝ)) = limitCDF (11 / 25) := by
  rw [limitCDF_decile, firstDecile_card, window_card]
  have hm' : (0 : ℝ) < m := by exact_mod_cast hm
  push_cast
  field_simp

end Spike.Quantile