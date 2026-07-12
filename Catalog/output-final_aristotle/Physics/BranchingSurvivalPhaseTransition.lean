import Mathlib

/-!
# A universal order-parameter threshold: from mean-field magnetism to branching survival

This file develops a single structural mechanism behind two apparently distinct
threshold phenomena and shows they are governed by the **same** critical value
`c = 1`.

## The two systems

* **Mean-field (Curie–Weiss) magnetism.**  The spontaneous magnetization `m`
  solves the self-consistency equation `m = tanh(β m)`, with coupling `β`.

* **Survival of a branching process.**  A Galton–Watson process with a Poisson
  offspring law of mean `μ` survives with probability `q`, where `q` solves the
  fixed-point equation for the survival probability
  `q = 1 - exp(-μ q)` (equivalently, `1 - q` is the extinction probability, the
  smallest fixed point of the offspring generating function).

Both order parameters are fixed points of a smooth, increasing, concave map `F`
with `F 0 = 0` whose derivative at the origin equals the coupling.  The unifying
observation is:

> A concave increasing map through the origin acquires a strictly positive fixed
> point exactly when its slope at the origin exceeds `1`.

## Main results

* `fixedPoint_exists` / `fixedPoint_none` — the abstract dichotomy: a positive
  fixed point of `F` on `(0, b)` exists once the origin-slope `c` exceeds `1`
  (and none exists whenever `F` stays strictly below the diagonal).
* `curieWeiss_supercritical_via_bridge` — the Curie–Weiss ordered phase recovered
  as an instance of the abstract dichotomy.
* `branching_subcritical`, `branching_supercritical`,
  `branching_phase_transition`, `branching_unique_positive`, `branching_lt_one`
  — the full phase-transition package for the branching survival probability,
  with the same critical coupling `μ_c = 1`.
* `branching_exponent_lower` — a quantitative onset `2 (μ - 1) / μ² ≤ q`,
  exhibiting a *linear* onset of the survival probability (critical exponent
  `1`), in contrast to the *square-root* onset (exponent `1/2`) of the symmetric
  Curie–Weiss magnetization.  The asymmetry of the offspring map (it is not odd)
  is exactly what changes the exponent.
-/

open Real Set

namespace OrderParameterBridge

/-! ### Elementary analytic inputs -/

/-- The derivative of `tanh` is `1 / cosh² x`. -/
lemma hasDerivAt_tanh (x : ℝ) :
    HasDerivAt Real.tanh (1 / Real.cosh x ^ 2) x := by
  have hc := Real.hasDerivAt_cosh x
  have hs := Real.hasDerivAt_sinh x
  have hcpos := Real.cosh_pos x
  have hne : Real.cosh x ≠ 0 := ne_of_gt hcpos
  have hquot :
      HasDerivAt (fun y => Real.sinh y / Real.cosh y)
        ((Real.cosh x * Real.cosh x - Real.sinh x * Real.sinh x) / Real.cosh x ^ 2) x := by
    have := hs.div hc hne
    convert this using 1
  have hform : Real.tanh = fun y => Real.sinh y / Real.cosh y := by
    funext y; exact Real.tanh_eq_sinh_div_cosh y
  rw [hform]
  have hid : (Real.cosh x * Real.cosh x - Real.sinh x * Real.sinh x) / Real.cosh x ^ 2
      = 1 / Real.cosh x ^ 2 := by
    have := Real.cosh_sq_sub_sinh_sq x
    have hsq : Real.cosh x * Real.cosh x - Real.sinh x * Real.sinh x = 1 := by
      have h2 : Real.cosh x ^ 2 - Real.sinh x ^ 2 = 1 := this
      nlinarith [h2]
    rw [hsq]
  rw [hid] at hquot
  exact hquot

/-- `tanh` is continuous. -/
lemma continuous_tanh : Continuous Real.tanh := by
  have : Real.tanh = fun x => Real.sinh x / Real.cosh x := by
    funext x; exact Real.tanh_eq_sinh_div_cosh x
  rw [this]
  exact Real.continuous_sinh.div Real.continuous_cosh (fun x => ne_of_gt (Real.cosh_pos x))

/-- **`tanh y < y` for `y > 0`.**  Below the critical coupling this forces the
disordered phase (only the trivial fixed point survives). -/
lemma tanh_lt_id {y : ℝ} (hy : 0 < y) : Real.tanh y < y := by
  set F : ℝ → ℝ := fun y => y - Real.tanh y
  have h_deriv_pos : ∀ y > 0, deriv F y > 0 := by
    simp +zetaDelta at *
    intro y hy
    norm_num [ Real.tanh_eq_sinh_div_cosh, Real.differentiableAt_sinh, Real.differentiableAt_cosh, ne_of_gt ( Real.cosh_pos _ ) ]
    rw [ div_lt_iff₀ ] <;> nlinarith [ Real.cosh_sq' y, Real.sinh_pos_iff.2 hy ]
  have h_mvt : ∃ c ∈ Set.Ioo 0 y, deriv F c = (F y - F 0) / (y - 0) := by
    apply_rules [ exists_deriv_eq_slope ]
    · exact ContinuousOn.sub continuousOn_id <| ContinuousOn.congr ( show ContinuousOn ( fun y => Real.sinh y / Real.cosh y ) ( Set.Icc 0 y ) from ContinuousOn.div ( Real.continuous_sinh.continuousOn ) ( Real.continuous_cosh.continuousOn ) fun x hx => ne_of_gt <| Real.cosh_pos _ ) fun x hx => Real.tanh_eq_sinh_div_cosh _
    · exact fun x hx => DifferentiableAt.differentiableWithinAt ( by exact differentiableAt_of_deriv_ne_zero ( ne_of_gt ( h_deriv_pos x hx.1 ) ) )
  obtain ⟨ c, ⟨ hc1, hc2 ⟩, hc3 ⟩ := h_mvt; have := h_deriv_pos c hc1; rw [ hc3, gt_iff_lt ] at this; rw [ lt_div_iff₀ ] at this <;> aesop

/-- **`1 - exp(-x) < x` for `x > 0`.**  The branching analogue of `tanh y < y`:
the offspring map lies strictly below the diagonal. -/
lemma one_sub_exp_lt_id {x : ℝ} (hx : 0 < x) : 1 - Real.exp (-x) < x := by
  have h := Real.add_one_lt_exp (show (-x : ℝ) ≠ 0 by simpa using hx.ne')
  -- (-x) + 1 < exp (-x)
  linarith

/-
**A sharp quadratic lower bound `x - x²/2 < 1 - exp(-x)` for `x > 0`.**
This is what makes a positive survival probability appear once `μ > 1`, and it
pins the *linear* onset exponent.
-/
lemma quad_lt_one_sub_exp {x : ℝ} (hx : 0 < x) : x - x ^ 2 / 2 < 1 - Real.exp (-x) := by
  -- Apply the Taylor series expansion of $e^{-x}$ around $x = 0$.
  have h_taylor : ∀ x : ℝ, 0 < x → Real.exp (-x) < 1 - x + x^2 / 2 := by
    intro x hx; rw [ Real.exp_neg ];
    rw [ inv_eq_one_div, div_lt_iff₀ ( Real.exp_pos _ ) ];
    -- We'll use the exponential property to simplify the expression. Note that $e^x > 1 + x + \frac{x^2}{2}$ for all $x > 0$.
    have h_exp_gt : ∀ x : ℝ, 0 < x → Real.exp x > 1 + x + x^2 / 2 := by
      exact fun x hx => by rw [ Real.exp_eq_exp_ℝ ] ; rw [ NormedSpace.exp_eq_tsum_div ] ; exact lt_of_lt_of_le ( by simpa [ Finset.sum_range_succ ] using by positivity ) ( Summable.sum_le_tsum ( Finset.range 4 ) ( fun _ _ => by positivity ) ( by simpa using Real.summable_pow_div_factorial x ) ) ;
    nlinarith [ h_exp_gt x hx, sq_nonneg ( x - 1 ), Real.add_one_le_exp x ];
  linarith [ h_taylor x hx ]

/-! ### The abstract order-parameter dichotomy (the bridge) -/

/-
If `F 0 = 0` and `F` has slope `c > 1` at the origin, then `F` overtakes the
diagonal at some arbitrarily small positive point: there is `x ∈ (0, b)` with
`x < F x`.  This is the seed of a positive fixed point.
-/
lemma exists_lt_image_of_deriv {F : ℝ → ℝ} {c b : ℝ} (hb : 0 < b)
    (hF0 : F 0 = 0) (hderiv : HasDerivAt F c 0) (hc : 1 < c) :
    ∃ x, 0 < x ∧ x < b ∧ x < F x := by
  -- By the definition of the derivative, since $c > 1$, there exists a $\delta > 0$ such that for all $x$ with $0 < x < \delta$, we have $\frac{F(x) - F(0)}{x} > 1$.
  obtain ⟨δ, hδ_pos, hδ⟩ : ∃ δ > 0, ∀ x, 0 < x ∧ x < δ → (F x - F 0) / x > 1 := by
    have := Metric.tendsto_nhdsWithin_nhds.mp ( show Filter.Tendsto ( fun x => ( F x - F 0 ) / x ) ( nhdsWithin 0 ( Set.Ioi 0 ) ) ( nhds c ) from ?_ ) ( c - 1 ) ( by linarith );
    · exact ⟨ this.choose, this.choose_spec.1, fun x hx => by linarith [ abs_lt.mp ( this.choose_spec.2 hx.1 ( by simpa [ abs_of_pos hx.1 ] using hx.2 ) ) ] ⟩;
    · simpa [ div_eq_inv_mul, hF0 ] using hderiv.tendsto_slope_zero_right;
  exact ⟨ Min.min δ b / 2, by positivity, by linarith [ min_le_left δ b, min_le_right δ b ], by have := hδ ( Min.min δ b / 2 ) ⟨ by positivity, by linarith [ min_le_left δ b, min_le_right δ b ] ⟩ ; rw [ gt_iff_lt ] at this; rw [ lt_div_iff₀ ( by positivity ) ] at this; linarith ⟩

/-
**Existence half of the abstract dichotomy.**  A concave-type increasing map
`F` with `F 0 = 0`, origin-slope `c > 1`, continuous on `[0, b]` and lying below
the diagonal at the right endpoint (`F b < b`) has a fixed point strictly inside
`(0, b)`.
-/
theorem fixedPoint_exists {F : ℝ → ℝ} {c b : ℝ}
    (hb : 0 < b) (hF0 : F 0 = 0) (hderiv : HasDerivAt F c 0)
    (hcont : ContinuousOn F (Set.Icc 0 b)) (hFb : F b < b) (hc : 1 < c) :
    ∃ m, 0 < m ∧ m < b ∧ F m = m := by
  -- By the properties of the intermediate value theorem, since $F(0) = 0$ and $F(b) < b$, there exists some $x₀ \in (0, b)$ such that $F(x₀) > x₀$.
  obtain ⟨x₀, hx₀⟩ : ∃ x₀ ∈ Set.Ioo 0 b, F x₀ > x₀ := by
    have := exists_lt_image_of_deriv hb hF0 hderiv hc; aesop;
  -- By the properties of the intermediate value theorem, since $F(x₀) > x₀$ and $F(b) < b$, there exists some $m \in (x₀, b)$ such that $F(m) = m$.
  obtain ⟨m, hm⟩ : ∃ m ∈ Set.Ioo x₀ b, F m - m = 0 := by
    apply_rules [ intermediate_value_Ioo' ] <;> norm_num [ * ];
    · linarith [ hx₀.1.2 ];
    · exact ContinuousOn.sub ( hcont.mono ( Set.Icc_subset_Icc hx₀.1.1.le le_rfl ) ) continuousOn_id;
  exact ⟨ m, lt_trans hx₀.1.1 hm.1.1, hm.1.2, sub_eq_zero.mp hm.2 ⟩

/-- **Non-existence half of the abstract dichotomy.**  If `F` stays strictly
below the diagonal on the positive axis, it has no positive fixed point. -/
theorem fixedPoint_none {F : ℝ → ℝ} (hsub : ∀ x, 0 < x → F x < x) :
    ∀ m, 0 < m → F m ≠ m := by
  intro m hm hcontra
  exact absurd hcontra (ne_of_lt (hsub m hm))

/-! ### Curie–Weiss magnetism as an instance of the bridge -/

/-- **Ordered phase of the Curie–Weiss model, via the abstract bridge.**  For
`β > 1` the magnetization self-consistency equation `m = tanh(β m)` has a
solution `m ∈ (0, 1)`.  This recovers the ordered phase purely as a corollary of
`fixedPoint_exists`, illustrating the unification. -/
theorem curieWeiss_supercritical_via_bridge {β : ℝ} (hβ : 1 < β) :
    ∃ m, 0 < m ∧ m < 1 ∧ Real.tanh (β * m) = m := by
  have hderiv : HasDerivAt (fun m => Real.tanh (β * m)) β 0 := by
    have h := (hasDerivAt_tanh (β * 0)).comp (0 : ℝ) ((hasDerivAt_id (0 : ℝ)).const_mul β)
    simpa using h
  have hcont : ContinuousOn (fun m => Real.tanh (β * m)) (Set.Icc 0 1) :=
    (continuous_tanh.comp (continuous_const.mul continuous_id)).continuousOn
  have hFb : Real.tanh (β * 1) < 1 := by simpa using Real.tanh_lt_one (β * 1)
  have hF0 : (fun m => Real.tanh (β * m)) 0 = 0 := by simp
  exact fixedPoint_exists (b := 1) one_pos hF0 hderiv hcont hFb hβ

/-! ### Branching-process survival: the phase transition -/

/-- The survival self-consistency equation for a Galton–Watson process with
Poisson offspring law of mean `μ`: the survival probability `q` satisfies
`q = 1 - exp(-μ q)`. -/
def BranchingFixedPoint (μ q : ℝ) : Prop := q = 1 - Real.exp (-(μ * q))

/-- Any survival probability is `< 1`: extinction always has positive
probability. -/
theorem branching_lt_one {μ q : ℝ} (h : BranchingFixedPoint μ q) : q < 1 := by
  have := Real.exp_pos (-(μ * q))
  rw [BranchingFixedPoint] at h
  linarith

/-- **Sub-critical / extinction phase.**  If the mean offspring number satisfies
`0 < μ ≤ 1`, the only non-negative survival probability is `q = 0`: the process
dies out almost surely. -/
theorem branching_subcritical {μ q : ℝ} (hμ0 : 0 < μ) (hμ : μ ≤ 1) (hq : 0 ≤ q)
    (h : BranchingFixedPoint μ q) : q = 0 := by
  rw [BranchingFixedPoint] at h
  by_contra hq0
  have hqpos : 0 < q := lt_of_le_of_ne hq (Ne.symm hq0)
  have hx : 0 < μ * q := mul_pos hμ0 hqpos
  have h1 : 1 - Real.exp (-(μ * q)) < μ * q := one_sub_exp_lt_id hx
  have h2 : μ * q ≤ q := by nlinarith [hqpos]
  linarith [h, h1, h2]

/-- **Super-critical / survival phase.**  If `μ > 1`, a strictly positive
survival probability `q ∈ (0, 1)` exists: the process survives with positive
probability. -/
theorem branching_supercritical {μ : ℝ} (hμ : 1 < μ) :
    ∃ q, 0 < q ∧ q < 1 ∧ BranchingFixedPoint μ q := by
  set F : ℝ → ℝ := fun q => 1 - Real.exp (-(μ * q)) with hFdef
  have hderiv : HasDerivAt F μ 0 := by
    have hg : HasDerivAt (fun q : ℝ => -(μ * q)) (-μ) 0 := by
      simpa using ((hasDerivAt_id (0 : ℝ)).const_mul μ).neg
    have he : HasDerivAt (fun q : ℝ => Real.exp (-(μ * q))) (Real.exp (-(μ * 0)) * (-μ)) 0 :=
      (Real.hasDerivAt_exp _).comp 0 hg
    have : HasDerivAt F (0 - Real.exp (-(μ * 0)) * (-μ)) 0 :=
      (hasDerivAt_const 0 (1 : ℝ)).sub he
    simpa using this
  have hcont : ContinuousOn F (Set.Icc 0 1) := by
    apply ContinuousOn.sub continuousOn_const
    exact (Real.continuous_exp.comp ((continuous_const.mul continuous_id).neg)).continuousOn
  have hFb : F 1 < 1 := by
    have := Real.exp_pos (-(μ * 1)); simp only [hFdef]; linarith
  have hF0 : F 0 = 0 := by simp [hFdef]
  obtain ⟨m, hm0, hm1, hmeq⟩ := fixedPoint_exists (b := 1) one_pos hF0 hderiv hcont hFb hμ
  exact ⟨m, hm0, hm1, hmeq.symm⟩

/-- **The branching phase transition, sharply located at `μ_c = 1`.**  A positive
survival probability exists if and only if the mean offspring number exceeds the
critical value `1`. -/
theorem branching_phase_transition {μ : ℝ} (hμ0 : 0 < μ) :
    (∃ q, 0 < q ∧ BranchingFixedPoint μ q) ↔ 1 < μ := by
  constructor
  · rintro ⟨q, hq, h⟩
    by_contra hle
    push_neg at hle
    exact absurd (branching_subcritical hμ0 hle hq.le h) (ne_of_gt hq)
  · intro hμ
    obtain ⟨q, hq, _, h⟩ := branching_supercritical hμ
    exact ⟨q, hq, h⟩

/-
**Uniqueness of the positive survival branch.**  For fixed `μ`, at most one
positive survival probability solves the self-consistency equation; hence the
survival probability is a well-defined single-valued function of `μ`.
-/
theorem branching_unique_positive {μ q₁ q₂ : ℝ} (h1 : 0 < q₁) (h2 : 0 < q₂)
    (e1 : BranchingFixedPoint μ q₁) (e2 : BranchingFixedPoint μ q₂) : q₁ = q₂ := by
  by_contra! hq_ne;
  -- Without loss of generality, assume $q_1 < q_2$.
  wlog hq1_lt_q2 : q₁ < q₂ generalizing q₁ q₂;
  · exact this h2 h1 e2 e1 hq_ne.symm ( lt_of_le_of_ne ( le_of_not_gt hq1_lt_q2 ) hq_ne.symm );
  · -- Apply the Mean Value Theorem to the intervals $[q₁, q₂]$ and $[0, q₁]$.
    obtain ⟨ξ, hξ⟩ : ∃ ξ ∈ Set.Ioo q₁ q₂, deriv (fun x => 1 - Real.exp (-(μ * x))) ξ = (1 - Real.exp (-(μ * q₂)) - (1 - Real.exp (-(μ * q₁)))) / (q₂ - q₁) := by
      apply_rules [ exists_deriv_eq_slope ];
      · fun_prop;
      · exact DifferentiableOn.sub ( differentiableOn_const _ ) ( DifferentiableOn.exp ( DifferentiableOn.neg ( differentiableOn_id.const_mul _ ) ) )
    obtain ⟨η, hη⟩ : ∃ η ∈ Set.Ioo 0 q₁, deriv (fun x => 1 - Real.exp (-(μ * x))) η = (1 - Real.exp (-(μ * q₁)) - (1 - Real.exp (-(μ * 0)))) / (q₁ - 0) := by
      have := exists_deriv_eq_slope ( f := fun x => 1 - Real.exp ( - ( μ * x ) ) ) h1;
      exact this ( Continuous.continuousOn <| by continuity ) ( Differentiable.differentiableOn <| by norm_num [ mul_comm μ ] );
    norm_num [ mul_comm μ ] at *;
    -- Since $μ > 0$, we can divide both sides of the equations by $μ$.
    have h_div : Real.exp (-(ξ * μ)) = Real.exp (-(η * μ)) := by
      grind +locals;
    norm_num at *;
    grind +locals

/-- **Quantitative linear onset (critical exponent `1`).**  For `μ > 1`, the
positive survival probability obeys `2 (μ - 1) / μ² ≤ q`.  Thus the order
parameter turns on *linearly* in `μ - 1`, in contrast to the square-root onset of
the (symmetric) Curie–Weiss magnetization: the asymmetry of the offspring map
changes the mean-field critical exponent from `1/2` to `1`. -/
theorem branching_exponent_lower {μ q : ℝ} (hμ : 1 < μ) (hq : 0 < q)
    (h : BranchingFixedPoint μ q) : 2 * (μ - 1) / μ ^ 2 ≤ q := by
  rw [BranchingFixedPoint] at h
  have hμ0 : 0 < μ := by linarith
  have hx : 0 < μ * q := mul_pos hμ0 hq
  have hquad := quad_lt_one_sub_exp hx
  -- (μq) - (μq)²/2 < 1 - exp(-μq) = q
  rw [← h] at hquad
  rw [div_le_iff₀ (by positivity : (0:ℝ) < μ ^ 2)]
  nlinarith [hquad, hq, mul_pos hq hq, hμ0]

/-! ### Lab Notes

`-- !-- Lab Notes -- !--`

**Hypothesis.**  The two thresholds — the Curie–Weiss ordering transition
(`β_c = 1`) and the branching-process survival transition (`μ_c = 1`) — are the
same phenomenon: a concave increasing map through the origin acquires a positive
fixed point exactly when its origin-slope crosses `1`.  We conjectured that a
single abstract lemma would generate both ordered phases, and that the *shape* of
the map (odd vs. non-odd) would control the critical exponent.

**Experiment.**  We isolated the abstract existence criterion `fixedPoint_exists`
(slope `> 1` at the origin + sub-diagonal at the right endpoint ⇒ interior fixed
point) and its converse `fixedPoint_none`.  The Curie–Weiss ordered phase falls
out as `curieWeiss_supercritical_via_bridge` by instantiating `F = tanh(β·)`
(origin-slope `β`).  The branching phase falls out as `branching_supercritical`
by instantiating `F = 1 - exp(-μ·)` (origin-slope `μ`).  The sub-critical
non-existence uses the sharp diagonal bounds `tanh y < y` and `1 - exp(-x) < x`.

**Analysis.**  The unification is genuine: both existence proofs are the *same*
lemma with different analytic inputs.  The critical exponents differ, however.
For the symmetric map `tanh` (odd), the cubic term `y³/3` gives
`m² ≳ 3(β-1)`, i.e. exponent `1/2`.  For the non-odd branching map the *quadratic*
term dominates, giving `q ≳ 2(μ-1)`, i.e. exponent `1`
(`branching_exponent_lower`).  The parity of the update map is precisely what
selects the exponent.

**Critique.**  We checked that no result is vacuous: every ordered-phase theorem
produces a solution strictly inside `(0, 1)` (not the trivial root `0`), and the
`iff` statements are guarded by `0 < μ` to exclude the degenerate `μ ≤ 0` regime
where `q` need not be a probability.  Uniqueness is proved by a mean-value /
strict-monotonicity argument rather than by assuming the branch is single-valued.

**Synthesis.**  A single order-parameter template governs mean-field magnetism
and branching survival, with a universal critical coupling `1` but
model-dependent critical exponents controlled by the symmetry of the update map.
-/

end OrderParameterBridge