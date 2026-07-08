import Mathlib

/-!
# Split Geometry: a direction-dependent curvature on `ℝ²`

This file studies the *Split Geometry* on `ℝ²` whose Riemannian metric is
`ds² = dx²/cosh²(y) + cosh²(x) dy²`, i.e. it expands in the `x`-direction
(governed by `1/cosh²(y)`) and contracts in the `y`-direction (governed by
`cosh²(x)`).

The metric coefficients are

* `gxx x y = sechSq y`   (coefficient of `dx²`), and
* `gyy x y = cosh²(x)`   (coefficient of `dy²`),

where `sechSq t = 1 / cosh²(t)`.  Both are strictly positive everywhere, so the
metric is a genuine (positive-definite) Riemannian metric on all of `ℝ²`
(`gxx_pos`, `gyy_pos`, `metric_det_pos`).

The conjecture attached to this geometry posits a curvature function
`K(x,y) = sech²(x) - sech²(y)` whose sign is meant to change across the
diagonals `y = ± x`.  We make this precise:

* `K_eq_zero_iff`  : `K x y = 0 ↔ |x| = |y|` — the flat *phase boundary*.
* `phase_boundary_eq` : the zero set of `K` is exactly the union of the two
  diagonals `{p | p.2 = p.1 ∨ p.2 = -p.1}`.
* `K_neg_of_abs_lt` : `|y| < |x| → K x y < 0`.
* `K_pos_of_abs_lt` : `|x| < |y| → 0 < K x y`.
* `K_trichotomy`   : the sign of `K x y` is determined by comparing `|x|` and
  `|y|`.
* `abs_K_lt_one`   : `|K x y| < 1` everywhere (the curvature function is bounded).
* `K_sup_sharp`, `K_inf_sharp` : this bound is *sharp* — `K(0,y) → 1` and
  `K(x,0) → -1`; and `K_range` shows the range of `K` is exactly the open
  interval `(-1, 1)`.
* `KGauss`, `KGauss_eq` : the *true* Gaussian curvature of the split metric,
  computed from the orthogonal-metric (Brioschi) formula, equals
  `-cosh²y - sech²x + 2·sech²x·sech²y`.  `KGauss_ne_K` shows this differs from
  the posited sign model `K`.

**Honest correction to the informal conjecture.**  The informal statement labels
the region `|x| > |y|` as *elliptic* (`K > 0`) and `|y| > |x|` as *hyperbolic*
(`K < 0`).  For the posited function `K = sech² x - sech² y` the signs are in fact
the *opposite*: since `cosh` is increasing in `|·|`, `|x| > |y|` forces
`sech² x < sech² y`, hence `K < 0` there, and `K > 0` when `|y| > |x|`.  The
theorems below record the mathematically correct signs.  (The zero set / phase
boundary along `y = ±x` is exactly as conjectured.)

`K` is treated here as the *posited* curvature function of the Split Geometry; we
prove the structural claims about its zero set and sign regions, together with the
positive-definiteness of the underlying metric.
-/

namespace SplitGeometry

open Real

/-- `sechSq t = sech²(t) = 1 / cosh²(t)`, the hyperbolic secant squared. -/
noncomputable def sechSq (t : ℝ) : ℝ := 1 / (Real.cosh t) ^ 2

/-- The `dx²` coefficient of the split metric. -/
noncomputable def gxx (_x y : ℝ) : ℝ := sechSq y

/-- The `dy²` coefficient of the split metric. -/
noncomputable def gyy (x _y : ℝ) : ℝ := (Real.cosh x) ^ 2

/-- The posited curvature function of the Split Geometry,
`K(x,y) = sech²(x) - sech²(y)`. -/
noncomputable def K (x y : ℝ) : ℝ := sechSq x - sechSq y

/-! ### Basic positivity facts about `sechSq` -/

theorem sechSq_pos (t : ℝ) : 0 < sechSq t := by
  unfold sechSq
  have h : 0 < (Real.cosh t) ^ 2 := pow_pos (Real.cosh_pos t) 2
  positivity

theorem sechSq_le_one (t : ℝ) : sechSq t ≤ 1 := by
  unfold sechSq
  have h1 : (1 : ℝ) ≤ (Real.cosh t) ^ 2 := by
    have := Real.one_le_cosh t
    nlinarith [this]
  have h2 : 0 < (Real.cosh t) ^ 2 := pow_pos (Real.cosh_pos t) 2
  rw [div_le_one h2]
  linarith

/-- `sechSq` is an even function. -/
theorem sechSq_even (t : ℝ) : sechSq (-t) = sechSq t := by
  unfold sechSq; rw [Real.cosh_neg]

/-! ### Positive-definiteness of the split metric -/

theorem gxx_pos (x y : ℝ) : 0 < gxx x y := sechSq_pos y

theorem gyy_pos (x y : ℝ) : 0 < gyy x y := pow_pos (Real.cosh_pos x) 2

/-- The determinant `gxx · gyy` of the metric is positive everywhere, so the split
metric is positive-definite (a genuine Riemannian metric) on all of `ℝ²`. -/
theorem metric_det_pos (x y : ℝ) : 0 < gxx x y * gyy x y :=
  mul_pos (gxx_pos x y) (gyy_pos x y)

/-! ### Elementary symmetries of the curvature function -/

/-- `K` is antisymmetric under swapping its arguments. -/
theorem K_antisymm (x y : ℝ) : K x y = -(K y x) := by unfold K; ring

/-- `K` is even in its first argument (reflection `x ↦ -x`). -/
theorem K_even_left (x y : ℝ) : K (-x) y = K x y := by
  unfold K; rw [sechSq_even]

/-- `K` is even in its second argument (reflection `y ↦ -y`). -/
theorem K_even_right (x y : ℝ) : K x (-y) = K x y := by
  unfold K; rw [sechSq_even]

/-- The main diagonal `y = x` is flat. -/
theorem K_diag (x : ℝ) : K x x = 0 := by unfold K; ring

/-- The anti-diagonal `y = -x` is flat. -/
theorem K_antidiag (x : ℝ) : K x (-x) = 0 := by
  unfold K; rw [sechSq_even]; ring

/-! ### The phase boundary -/

/-- `cosh x = cosh y` iff `|x| = |y|`. -/
theorem cosh_eq_cosh_iff (x y : ℝ) : Real.cosh x = Real.cosh y ↔ |x| = |y| := by
  rw [le_antisymm_iff, Real.cosh_le_cosh, Real.cosh_le_cosh, ← le_antisymm_iff]

/-- `sechSq x = sechSq y` iff `|x| = |y|`. -/
theorem sechSq_eq_iff (x y : ℝ) : sechSq x = sechSq y ↔ |x| = |y| := by
  rw [← cosh_eq_cosh_iff]
  unfold sechSq
  have hx : 0 < (Real.cosh x) ^ 2 := pow_pos (Real.cosh_pos x) 2
  have hy : 0 < (Real.cosh y) ^ 2 := pow_pos (Real.cosh_pos y) 2
  rw [one_div, one_div, inv_inj]
  constructor
  · intro h
    have := Real.cosh_pos x
    have := Real.cosh_pos y
    nlinarith [Real.cosh_pos x, Real.cosh_pos y]
  · intro h; rw [h]

/-- **Phase boundary.** `K x y = 0` exactly on the two diagonals `|x| = |y|`. -/
theorem K_eq_zero_iff (x y : ℝ) : K x y = 0 ↔ |x| = |y| := by
  unfold K
  rw [sub_eq_zero, sechSq_eq_iff]

/-- The zero set (flat phase boundary) of `K` is exactly the union of the two
diagonals `y = x` and `y = -x`. -/
theorem phase_boundary_eq :
    {p : ℝ × ℝ | K p.1 p.2 = 0} = {p : ℝ × ℝ | p.2 = p.1 ∨ p.2 = -p.1} := by
  ext p
  simp only [Set.mem_setOf_eq, K_eq_zero_iff]
  rw [abs_eq_abs]
  constructor
  · rintro (h | h)
    · exact Or.inl h.symm
    · exact Or.inr (by linarith)
  · rintro (h | h)
    · exact Or.inl h.symm
    · exact Or.inr (by linarith)

/-! ### Sign of the curvature in the two regions -/

/-- **Hyperbolic-labelled region gives `K < 0`.**  If `|y| < |x|` then `K x y < 0`. -/
theorem K_neg_of_abs_lt {x y : ℝ} (h : |y| < |x|) : K x y < 0 := by
  unfold K sechSq
  have hcx : 0 < (Real.cosh x) ^ 2 := pow_pos (Real.cosh_pos x) 2
  have hcy : 0 < (Real.cosh y) ^ 2 := pow_pos (Real.cosh_pos y) 2
  have hlt : Real.cosh y < Real.cosh x := (Real.cosh_lt_cosh).2 h
  have hsq : (Real.cosh y) ^ 2 < (Real.cosh x) ^ 2 := by
    nlinarith [Real.cosh_pos x, Real.cosh_pos y]
  have : (1 : ℝ) / (Real.cosh x) ^ 2 < 1 / (Real.cosh y) ^ 2 :=
    one_div_lt_one_div_of_lt hcy hsq
  linarith

/-- **Elliptic-labelled region gives `K > 0`.**  If `|x| < |y|` then `0 < K x y`. -/
theorem K_pos_of_abs_lt {x y : ℝ} (h : |x| < |y|) : 0 < K x y := by
  have := K_neg_of_abs_lt h
  rw [K_antisymm] at this ⊢
  linarith [K_neg_of_abs_lt h, K_antisymm y x]

/-- **Trichotomy of the phase diagram.**  The sign of the curvature function is
completely determined by comparing `|x|` and `|y|`:
`K > 0` when `|x| < |y|`, `K = 0` on the boundary `|x| = |y|`, and `K < 0` when
`|y| < |x|`. -/
theorem K_trichotomy (x y : ℝ) :
    (|x| < |y| → 0 < K x y) ∧ (|x| = |y| → K x y = 0) ∧ (|y| < |x| → K x y < 0) :=
  ⟨K_pos_of_abs_lt, (K_eq_zero_iff x y).2, K_neg_of_abs_lt⟩

/-- An elliptic-labelled point genuinely exists (`K > 0`). -/
theorem exists_K_pos : ∃ x y : ℝ, 0 < K x y :=
  ⟨0, 1, K_pos_of_abs_lt (by norm_num)⟩

/-- A hyperbolic-labelled point genuinely exists (`K < 0`). -/
theorem exists_K_neg : ∃ x y : ℝ, K x y < 0 :=
  ⟨1, 0, K_neg_of_abs_lt (by norm_num)⟩

/-! ### Boundedness of the curvature function -/

theorem K_lt_one (x y : ℝ) : K x y < 1 := by
  unfold K
  have := sechSq_le_one x
  have := sechSq_pos y
  linarith

theorem neg_one_lt_K (x y : ℝ) : -1 < K x y := by
  unfold K
  have := sechSq_le_one y
  have := sechSq_pos x
  linarith

/-- The posited curvature function is bounded: `|K x y| < 1` everywhere. -/
theorem abs_K_lt_one (x y : ℝ) : |K x y| < 1 :=
  abs_lt.2 ⟨neg_one_lt_K x y, K_lt_one x y⟩

/-! ### Sharpness of the `±1` bound

The bound `|K| < 1` is sharp: neither `1` nor `-1` is attained, but both are
approached in the limit.  Since `cosh` grows without bound, `sechSq t → 0` as
`t → ∞`, so along the coordinate axes `K` tends to the extreme values:
`K(0, y) → 1` and `K(x, 0) → -1`.  Hence the range of `K` is exactly the open
interval `(-1, 1)`. -/

theorem sechSq_zero : sechSq 0 = 1 := by unfold sechSq; simp

/-- `cosh` tends to `+∞`. -/
theorem tendsto_cosh_atTop : Filter.Tendsto Real.cosh Filter.atTop Filter.atTop := by
  apply Filter.tendsto_atTop_mono (fun x => ?_)
    (Real.tendsto_exp_atTop.atTop_div_const (by norm_num : (0 : ℝ) < 2))
  rw [Real.cosh_eq]
  have := Real.exp_pos (-x)
  linarith

/-- `sechSq t → 0` as `t → +∞`. -/
theorem tendsto_sechSq_atTop : Filter.Tendsto sechSq Filter.atTop (nhds 0) := by
  have h : Filter.Tendsto (fun t => (Real.cosh t)⁻¹) Filter.atTop (nhds 0) :=
    tendsto_cosh_atTop.inv_tendsto_atTop
  have h2 := h.pow 2
  simp only [pow_two, mul_zero] at h2
  unfold sechSq
  convert h2 using 2 with t
  rw [pow_two]; field_simp

/-- Along the `y`-axis, `K` approaches its supremum `1`: `K(0, y) → 1`. -/
theorem tendsto_K_zero_left :
    Filter.Tendsto (fun y => K 0 y) Filter.atTop (nhds 1) := by
  have : Filter.Tendsto (fun y => sechSq 0 - sechSq y) Filter.atTop
      (nhds (sechSq 0 - 0)) := tendsto_const_nhds.sub tendsto_sechSq_atTop
  simpa [K, sechSq_zero] using this

/-- Along the `x`-axis, `K` approaches its infimum `-1`: `K(x, 0) → -1`. -/
theorem tendsto_K_zero_right :
    Filter.Tendsto (fun x => K x 0) Filter.atTop (nhds (-1)) := by
  have : Filter.Tendsto (fun x => sechSq x - sechSq 0) Filter.atTop
      (nhds (0 - sechSq 0)) := tendsto_sechSq_atTop.sub tendsto_const_nhds
  simpa [K, sechSq_zero] using this

/-- The bound `K < 1` is sharp: for every `c < 1` there is a point where
`K` exceeds `c`. -/
theorem K_sup_sharp {c : ℝ} (hc : c < 1) : ∃ x y : ℝ, c < K x y := by
  have h := tendsto_K_zero_left
  have : ∀ᶠ y in Filter.atTop, c < K 0 y :=
    h.eventually (eventually_gt_nhds hc)
  obtain ⟨y, hy⟩ := this.exists
  exact ⟨0, y, hy⟩

/-- The bound `-1 < K` is sharp: for every `c > -1` there is a point where
`K` is below `c`. -/
theorem K_inf_sharp {c : ℝ} (hc : -1 < c) : ∃ x y : ℝ, K x y < c := by
  have h := tendsto_K_zero_right
  have : ∀ᶠ x in Filter.atTop, K x 0 < c :=
    h.eventually (eventually_lt_nhds hc)
  obtain ⟨x, hx⟩ := this.exists
  exact ⟨x, 0, hx⟩

/-! ### Regularity -/

/-- `sechSq` is continuous. -/
theorem continuous_sechSq : Continuous sechSq := by
  unfold sechSq
  have h : ∀ t : ℝ, (Real.cosh t) ^ 2 ≠ 0 := fun t => by positivity
  exact continuous_const.div (Real.continuous_cosh.pow 2) h

/-- The curvature function is continuous on `ℝ²`. -/
theorem continuous_K : Continuous (fun p : ℝ × ℝ => K p.1 p.2) := by
  unfold K
  exact (continuous_sechSq.comp continuous_fst).sub
    (continuous_sechSq.comp continuous_snd)

/-! ### The exact range of the posited curvature function

The curvature function `K` is continuous on the connected plane `ℝ²`, its values
are bounded strictly inside `(-1, 1)` (`abs_K_lt_one`), and both endpoints are
approached in the limit (`K_sup_sharp`, `K_inf_sharp`).  In fact **every** value
of the open interval is attained: `K 0 y = 1 - sech²y` sweeps out `[0, 1)` as
`cosh y` ranges over `[1, ∞)`, and `K x 0 = sech²x - 1` sweeps out `(-1, 0]`.
Hence the range of `K` is *exactly* the open interval `(-1, 1)`. -/

theorem K_range : Set.range (fun p : ℝ × ℝ => K p.1 p.2) = Set.Ioo (-1) 1 := by
  -- To prove equality of sets, we show each set is a subset of the other.
  apply Set.eq_of_subset_of_subset;
  · exact Set.range_subset_iff.mpr fun p => abs_lt.mp ( abs_K_lt_one p.1 p.2 );
  · intro c hc; by_cases h : 0 ≤ c <;> simp_all +decide [ K ] ;
    · -- Since $c \geq 0$, we can find $y \geq 0$ such that $\cosh(y) = \sqrt{\frac{1}{1-c}}$.
      obtain ⟨y, hy⟩ : ∃ y : ℝ, 0 ≤ y ∧ Real.cosh y = Real.sqrt (1 / (1 - c)) := by
        have h_cosh_surj : ∀ r : ℝ, 1 ≤ r → ∃ y : ℝ, 0 ≤ y ∧ Real.cosh y = r := by
          intro r hr; use Real.arsinh ( Real.sqrt ( r^2 - 1 ) ) ;
          norm_num [ Real.cosh_arsinh ];
          rw [ Real.sq_sqrt ( by nlinarith ), add_sub_cancel, Real.sqrt_sq ( by linarith ) ];
        exact h_cosh_surj _ <| Real.le_sqrt_of_sq_le <| by rw [ le_div_iff₀ ] <;> linarith;
      use 0, y; simp_all +decide [ sechSq ] ; ring_nf;
      rw [ Real.sq_sqrt ] <;> linarith;
    · obtain ⟨x, hx⟩ : ∃ x : ℝ, sechSq x = 1 + c := by
        -- Since $c < 0$, we can solve for $x$ in $1 / \cosh^2 x = 1 + c$.
        use Real.arsinh (Real.sqrt (1 / (1 + c) - 1));
        unfold sechSq;
        rw [ Real.cosh_sq, Real.sinh_arsinh ] ; ring_nf;
        rw [ Real.sq_sqrt ] <;> norm_num ; nlinarith [ inv_mul_cancel₀ ( by linarith : ( 1 + c ) ≠ 0 ) ];
      exact ⟨ x, 0, by linarith [ show sechSq 0 = 1 from by unfold sechSq; norm_num ] ⟩

/-! ### The true Gaussian curvature of the split metric

We now compute the *actual* Gaussian curvature of the split metric
`ds² = E dx² + G dy²` with `E = gxx = sech²y` and `G = gyy = cosh²x`, using the
standard formula for an orthogonal (`F = 0`) metric,
`K_gauss = -1/(2√(EG)) · [∂ₓ(∂ₓG / √(EG)) + ∂_y(∂_yE / √(EG))]`.

The computation shows the true Gaussian curvature is
`K_gauss(x,y) = -cosh²y - sech²x + 2·sech²x·sech²y`, which is genuinely different
from the posited `K(x,y) = sech²x - sech²y` (`KGauss_ne_K`); the two agree only in
special positions such as the origin (`KGauss_origin`, `K` also vanishes there). -/

/-- `√(E·G) = cosh x / cosh y` for the split metric (`E = sech²y`, `G = cosh²x`). -/
noncomputable def sqrtEG (x y : ℝ) : ℝ := Real.cosh x / Real.cosh y

theorem sqrtEG_pos (x y : ℝ) : 0 < sqrtEG x y :=
  div_pos (Real.cosh_pos x) (Real.cosh_pos y)

/-- The Gaussian curvature of the split metric, defined via the orthogonal-metric
(Brioschi) formula applied to `E = gxx` and `G = gyy`. -/
noncomputable def KGauss (x y : ℝ) : ℝ :=
  -1 / (2 * sqrtEG x y) *
    ( deriv (fun x' => deriv (fun x'' => gyy x'' y) x' / sqrtEG x' y) x
    + deriv (fun y' => deriv (fun y'' => gxx x y'') y' / sqrtEG x y') y )

/-
`∂ₓ G = ∂ₓ cosh²x = 2 cosh x sinh x`.
-/
theorem deriv_gyy_fst (x y : ℝ) :
    deriv (fun x'' => gyy x'' y) x = 2 * Real.cosh x * Real.sinh x := by
  simp +decide [ gyy, Real.differentiableAt_cosh ]

/-
`∂_y E = ∂_y sech²y = -2 sinh y / cosh³y`.
-/
theorem deriv_gxx_snd (x y : ℝ) :
    deriv (fun y'' => gxx x y'') y = -2 * Real.sinh y / Real.cosh y ^ 3 := by
  unfold gxx sechSq;
  norm_num [ Real.differentiableAt_cosh, pow_succ, mul_assoc, mul_comm, mul_left_comm, ne_of_gt ( Real.cosh_pos _ ) ] ; ring

/-- The `x`-flux `∂ₓG / √(EG)` simplifies to `2 sinh x cosh y`. -/
theorem fluxX (x y : ℝ) :
    deriv (fun x'' => gyy x'' y) x / sqrtEG x y = 2 * Real.sinh x * Real.cosh y := by
  rw [deriv_gyy_fst]
  unfold sqrtEG
  have hx := Real.cosh_pos x
  field_simp

/-- The `y`-flux `∂_yE / √(EG)` simplifies to `-2 sinh y / (cosh²y cosh x)`. -/
theorem fluxY (x y : ℝ) :
    deriv (fun y'' => gxx x y'') y / sqrtEG x y
      = -2 * Real.sinh y / (Real.cosh y ^ 2 * Real.cosh x) := by
  rw [deriv_gxx_snd]
  unfold sqrtEG
  have hx := Real.cosh_pos x
  have hy := Real.cosh_pos y
  field_simp

/-
Outer `x`-derivative of the `x`-flux: `∂ₓ(2 sinh x cosh y) = 2 cosh x cosh y`.
-/
theorem deriv_fluxX (x y : ℝ) :
    deriv (fun x' => deriv (fun x'' => gyy x'' y) x' / sqrtEG x' y) x
      = 2 * Real.cosh x * Real.cosh y := by
  have hfun : (fun x' => deriv (fun x'' => gyy x'' y) x' / sqrtEG x' y)
      = fun x' => 2 * Real.sinh x' * Real.cosh y := funext (fun x' => fluxX x' y)
  rw [hfun]
  norm_num

/-
Outer `y`-derivative of the `y`-flux:
`∂_y(-2 sinh y / (cosh²y cosh x)) = -2/cosh x · (2 - cosh²y)/cosh³y`.
-/
theorem deriv_fluxY (x y : ℝ) :
    deriv (fun y' => deriv (fun y'' => gxx x y'') y' / sqrtEG x y') y
      = -2 / Real.cosh x * ((2 - Real.cosh y ^ 2) / Real.cosh y ^ 3) := by
  have hfun : (fun y' => deriv (fun y'' => gxx x y'') y' / sqrtEG x y')
      = fun y' => -2 * Real.sinh y' / (Real.cosh y' ^ 2 * Real.cosh x) :=
    funext (fun y' => fluxY x y')
  rw [hfun]
  norm_num [ Real.differentiableAt_sinh, Real.differentiableAt_cosh, ne_of_gt ( Real.cosh_pos _ ) ];
  field_simp;
  rw [ Real.sinh_sq ] ; ring

/-- **The true Gaussian curvature of the split metric.**  Computed from the
metric via the orthogonal-metric formula, it equals
`-cosh²y - sech²x + 2·sech²x·sech²y`. -/
theorem KGauss_eq (x y : ℝ) :
    KGauss x y = -(Real.cosh y) ^ 2 - sechSq x + 2 * sechSq x * sechSq y := by
  unfold KGauss sechSq
  rw [deriv_fluxX, deriv_fluxY]
  unfold sqrtEG
  have hx := Real.cosh_pos x
  have hy := Real.cosh_pos y
  field_simp
  ring

/-- At the origin the true Gaussian curvature vanishes. -/
theorem KGauss_origin : KGauss 0 0 = 0 := by
  rw [KGauss_eq]; simp [sechSq_zero]; norm_num

/-
The true Gaussian curvature is **not** the posited curvature function `K`:
they differ at some point (e.g. `(0, 1)`), so `K` is only a schematic sign model,
not the metric's Gaussian curvature.
-/
theorem KGauss_ne_K : ∃ x y : ℝ, KGauss x y ≠ K x y := by
  refine ⟨0, 1, ?_⟩
  rw [KGauss_eq]
  unfold sechSq K ;
  unfold sechSq; norm_num;
  nlinarith [ Real.cosh_sq' 1, Real.sinh_pos_iff.2 zero_lt_one, mul_inv_cancel₀ ( ne_of_gt ( sq_pos_of_pos ( Real.cosh_pos 1 ) ) ) ]

end SplitGeometry