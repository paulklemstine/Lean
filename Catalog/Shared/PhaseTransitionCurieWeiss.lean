import Mathlib

/-!
# Mathematics as a Phase Transition: the Curie–Weiss order parameter

This file gives a fully rigorous formalization of a **second-order phase
transition** in the mean-field (Curie–Weiss) model of statistical mechanics.

The physical picture (transposed to the speculative "mathematical coherence"
metaphor of the research mission): a system of many coupled units, each carrying
a `±1` degree of freedom, is described at inverse temperature `β` by the
mean-field self-consistency equation for its *order parameter* `m` (the
spontaneous magnetization, i.e. the average alignment):

$$ m = \tanh(\beta\, m). $$

The **order parameter** `m` measures global coherence.  The central phenomenon
is a *phase transition* at the critical coupling `β_c = 1`:

* **Disordered / sub-critical phase (`β ≤ 1`).**  The only solution with
  `m ≥ 0` is `m = 0`: no spontaneous coherence
  (`curieWeiss_subcritical`).
* **Ordered / super-critical phase (`β > 1`).**  A strictly positive solution
  `m > 0` appears — spontaneous coherence emerges from nothing
  (`curieWeiss_supercritical`), and it is *unique* among positive values
  (`curieWeiss_unique_positive`).

Combining the two directions gives the sharp dichotomy

`(∃ m > 0, m = tanh (β m)) ↔ 1 < β`  (`curieWeiss_phase_transition`),

which locates the critical point exactly at `β_c = 1`.  Because the emergent
`m` can be taken arbitrarily small near `β = 1` (the positive branch is born at
`0`), the transition is *continuous* — the hallmark of a **second-order**
transition, in contrast to a discontinuous first-order jump.

Finally, `curieWeiss_field_positive_solution` shows that a positive external
field `h > 0` *destroys* the sharp transition: the field-driven equation
`m = tanh (β m + h)` has a positive solution `m ∈ (0, 1)` for **every** coupling
`β`, so spontaneous coherence is present at every temperature once a field is
applied.

The analytic backbone consists of two sharp elementary inequalities for `tanh`:
`tanh y < y` and `y - y³/3 < tanh y` for `y > 0`, both proved by monotonicity
of an auxiliary function via its derivative.
-/

open Real Set

namespace CurieWeiss

/-- `tanh` is continuous (as `sinh / cosh` with `cosh` nowhere zero). -/
lemma continuous_tanh : Continuous Real.tanh := by
  have : Real.tanh = fun x => Real.sinh x / Real.cosh x := by
    funext x; exact Real.tanh_eq_sinh_div_cosh x
  rw [this]
  exact Real.continuous_sinh.div Real.continuous_cosh (fun x => ne_of_gt (Real.cosh_pos x))

/-- The derivative of `tanh` is `1 / cosh² x = sech² x`. -/
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

/-
**Sharp inequality `tanh y < y` for `y > 0`.**  This forces the disordered
phase to have a *unique* fixed point at `m = 0` when `β ≤ 1`.
-/
lemma tanh_lt_self {y : ℝ} (hy : 0 < y) : Real.tanh y < y := by
  -- Consider the function $F(y) = y - \tanh(y)$.
  set F : ℝ → ℝ := fun y => y - Real.tanh y;
  -- We'll use the fact that $F(y)$ is differentiable and its derivative is positive on $(0, \infty)$.
  have h_deriv_pos : ∀ y > 0, deriv F y > 0 := by
    simp +zetaDelta at *;
    intro y hy; norm_num [ Real.tanh_eq_sinh_div_cosh, Real.differentiableAt_sinh, Real.differentiableAt_cosh, ne_of_gt ( Real.cosh_pos _ ) ];
    rw [ div_lt_iff₀ ] <;> nlinarith [ Real.cosh_sq' y, Real.sinh_pos_iff.2 hy ];
  -- Since $F$ is differentiable and its derivative is positive on $(0, \infty)$, we can apply the Mean Value Theorem to $F$ on this interval.
  have h_mvt : ∃ c ∈ Set.Ioo 0 y, deriv F c = (F y - F 0) / (y - 0) := by
    apply_rules [ exists_deriv_eq_slope ];
    · exact ContinuousOn.sub continuousOn_id <| ContinuousOn.congr ( show ContinuousOn ( fun y => Real.sinh y / Real.cosh y ) ( Set.Icc 0 y ) from ContinuousOn.div ( Real.continuous_sinh.continuousOn ) ( Real.continuous_cosh.continuousOn ) fun x hx => ne_of_gt <| Real.cosh_pos _ ) fun x hx => Real.tanh_eq_sinh_div_cosh _;
    · exact fun x hx => DifferentiableAt.differentiableWithinAt ( by exact differentiableAt_of_deriv_ne_zero ( ne_of_gt ( h_deriv_pos x hx.1 ) ) );
  obtain ⟨ c, ⟨ hc1, hc2 ⟩, hc3 ⟩ := h_mvt; have := h_deriv_pos c hc1; rw [ hc3, gt_iff_lt ] at this; rw [ lt_div_iff₀ ] at this <;> aesop;

/-
**Sharp lower bound `y - y³/3 < tanh y` for `y > 0`.**  The cubic
correction is exactly what makes a positive solution appear once `β > 1`.
-/
lemma tanh_gt_cubic {y : ℝ} (hy : 0 < y) : y - y ^ 3 / 3 < Real.tanh y := by
  -- Consider the function $G(y) = \tanh(y) - y + y^3 / 3$. We need to show that $G(y) > 0$ for $y > 0$.
  set G : ℝ → ℝ := fun y => Real.tanh y - y + y^3 / 3;
  -- We need to show that the derivative of $G(y)$ is positive for $y > 0$.
  have hG_deriv_pos : ∀ y > 0, 0 < deriv G y := by
    intro y hy
    have h_deriv : deriv G y = (1 / Real.cosh y ^ 2) - 1 + y ^ 2 := by
      convert HasDerivAt.deriv ( HasDerivAt.add ( HasDerivAt.sub ( hasDerivAt_tanh y ) ( hasDerivAt_id y ) ) ( HasDerivAt.div_const ( hasDerivAt_pow 3 y ) _ ) ) using 1 ; ring!
    rw [h_deriv];
    -- We'll use that $y^2 - \tanh^2 y > 0$ for $y > 0$.
    have h_pos : y^2 - Real.tanh y^2 > 0 := by
      exact sub_pos_of_lt ( by nlinarith [ show 0 < Real.tanh y from by rw [ Real.tanh_eq_sinh_div_cosh ] ; exact div_pos ( Real.sinh_pos_iff.mpr hy ) ( Real.cosh_pos _ ), tanh_lt_self hy ] );
    simp_all +decide [ Real.tanh_eq_sinh_div_cosh ];
    field_simp at *;
    nlinarith [ Real.sinh_sq y ];
  -- Since $G(y)$ is differentiable and its derivative is positive for $y > 0$, we can apply the Mean Value Theorem to $G$ on the interval $(0, y)$.
  have h_mvt : ∃ c ∈ Set.Ioo 0 y, deriv G c = (G y - G 0) / (y - 0) := by
    apply_rules [ exists_deriv_eq_slope ];
    · exact ContinuousOn.add ( ContinuousOn.sub ( by rw [ show tanh = fun x => Real.sinh x / Real.cosh x from funext fun x => Real.tanh_eq_sinh_div_cosh x ] ; exact ContinuousOn.div ( Real.continuous_sinh.continuousOn ) ( Real.continuous_cosh.continuousOn ) fun x hx => ne_of_gt ( Real.cosh_pos x ) ) continuousOn_id ) ( Continuous.continuousOn ( by continuity ) );
    · exact fun x hx => DifferentiableAt.differentiableWithinAt ( by exact differentiableAt_of_deriv_ne_zero ( ne_of_gt ( hG_deriv_pos x hx.1 ) ) );
  simp +zetaDelta at *;
  nlinarith [ h_mvt.choose_spec, hG_deriv_pos _ h_mvt.choose_spec.1.1, mul_div_cancel₀ ( tanh y - y + y ^ 3 / 3 ) hy.ne' ]

/-- Every self-consistent order parameter lies strictly inside `(-1, 1)`:
coherence is always bounded, since `m = tanh(β m) ∈ (-1,1)`. -/
theorem sol_abs_lt_one {β m : ℝ} (h : Real.tanh (β * m) = m) : |m| < 1 := by
  rw [← h, abs_lt]
  exact ⟨Real.neg_one_lt_tanh _, Real.tanh_lt_one _⟩

/-- Solutions come in symmetric `±m` pairs: the two ordered phases (aligned /
anti-aligned) are mirror images. -/
theorem sol_symm {β m : ℝ} (h : Real.tanh (β * m) = m) :
    Real.tanh (β * (-m)) = -m := by
  rw [mul_neg, Real.tanh_neg, h]

/-
**Sub-critical / disordered phase.**  If the coupling satisfies `β ≤ 1`,
the only non-negative self-consistent order parameter is `m = 0`: no
spontaneous coherence.
-/
theorem curieWeiss_subcritical {β m : ℝ} (hβ : β ≤ 1) (hm : 0 ≤ m)
    (h : Real.tanh (β * m) = m) : m = 0 := by
  by_contra hm_ne;
  -- Since $m \neq 0$, we have $0 < m$.
  have hm_pos : 0 < m := by
    positivity;
  by_cases hβm : β * m ≤ 0;
  · exact absurd h ( by linarith [ show Real.tanh ( β * m ) ≤ 0 from by simpa [ Real.tanh_eq_sinh_div_cosh ] using div_nonpos_of_nonpos_of_nonneg ( Real.sinh_nonpos_iff.mpr hβm ) ( Real.cosh_pos _ |> le_of_lt ) ] );
  · linarith [ tanh_lt_self ( lt_of_not_ge hβm ), mul_le_of_le_one_left hm_pos.le hβ ]

/-
**Super-critical / ordered phase.**  If `β > 1`, a strictly positive
self-consistent order parameter exists: spontaneous coherence emerges.
-/
theorem curieWeiss_supercritical {β : ℝ} (hβ : 1 < β) :
    ∃ m, 0 < m ∧ Real.tanh (β * m) = m := by
  -- Define the function $f(m) = \tanh(\beta m) - m$.
  set f : ℝ → ℝ := fun m => Real.tanh (β * m) - m;
  -- Choose $m_0$ such that $0 < m_0 < 1$ and $f(m_0) > 0$.
  obtain ⟨m0, hm0_pos, hm0_lt_one, hm0_pos_f⟩ : ∃ m0 : ℝ, 0 < m0 ∧ m0 < 1 ∧ f m0 > 0 := by
    -- Choose $c = \sqrt{\frac{3(\beta - 1)}{\beta^3}}$ and $m_0 = \frac{\min(1, c)}{2}$.
    set c := Real.sqrt (3 * (β - 1) / β^3)
    set m0 := min 1 c / 2;
    refine' ⟨ m0, _, _, _ ⟩ <;> norm_num;
    · exact div_pos ( lt_min zero_lt_one ( Real.sqrt_pos.mpr ( div_pos ( by linarith ) ( by positivity ) ) ) ) zero_lt_two;
    · exact div_lt_one ( by positivity ) |>.2 ( lt_of_le_of_lt ( min_le_left _ _ ) ( by norm_num ) );
    · -- By definition of $m0$, we know that $β^3 * m0^2 / 3 < β - 1$.
      have h_m0_bound : β^3 * m0^2 / 3 < β - 1 := by
        have h_m0_bound : m0^2 < c^2 := by
          exact pow_lt_pow_left₀ ( by rw [ div_lt_iff₀ ] <;> linarith [ show 0 < c by exact Real.sqrt_pos.mpr ( div_pos ( by linarith ) ( by positivity ) ), min_le_left 1 c, min_le_right 1 c ] ) ( by positivity ) ( by positivity );
        rw [ Real.sq_sqrt ] at h_m0_bound <;> nlinarith [ pow_pos ( zero_lt_one.trans hβ ) 3, mul_div_cancel₀ ( 3 * ( β - 1 ) ) ( pow_ne_zero 3 ( ne_of_gt ( zero_lt_one.trans hβ ) ) ) ];
      -- By definition of $m0$, we know that $β * m0 > 0$, so we can apply the inequality $tanh(y) > y - y^3 / 3$.
      have h_tanh_ineq : Real.tanh (β * m0) > β * m0 - (β * m0)^3 / 3 := by
        apply tanh_gt_cubic;
        exact mul_pos ( by positivity ) ( div_pos ( lt_min zero_lt_one ( Real.sqrt_pos.mpr ( div_pos ( by linarith ) ( by positivity ) ) ) ) zero_lt_two );
      nlinarith [ show 0 < m0 by exact div_pos ( lt_min zero_lt_one ( Real.sqrt_pos.mpr ( div_pos ( mul_pos zero_lt_three ( sub_pos.mpr hβ ) ) ( pow_pos ( zero_lt_one.trans hβ ) 3 ) ) ) ) zero_lt_two ];
  -- By the intermediate value theorem, since $f(m_0) > 0$ and $f(1) < 0$, there exists $m \in (m_0, 1)$ such that $f(m) = 0$.
  obtain ⟨m, hm⟩ : ∃ m ∈ Set.Ioo m0 1, f m = 0 := by
    apply_rules [ intermediate_value_Ioo' ] <;> norm_num [ hm0_lt_one.le ];
    · exact Continuous.continuousOn ( by exact Continuous.sub ( by simpa only [ Real.tanh_eq_sinh_div_cosh ] using Continuous.div ( Real.continuous_sinh.comp ( continuous_const.mul continuous_id' ) ) ( Real.continuous_cosh.comp ( continuous_const.mul continuous_id' ) ) fun x => ne_of_gt ( Real.cosh_pos _ ) ) continuous_id' );
    · exact ⟨ sub_neg_of_lt <| by rw [ Real.tanh_eq_sinh_div_cosh ] ; exact lt_of_lt_of_le ( div_lt_one ( Real.cosh_pos _ ) |>.2 <| Real.sinh_lt_cosh _ ) <| by norm_num, hm0_pos_f ⟩;
  exact ⟨ m, lt_trans hm0_pos hm.1.1, sub_eq_zero.mp hm.2 ⟩

/-- **The phase transition, sharply located at `β_c = 1`.**  A non-trivial
(positive) order parameter exists if and only if the coupling exceeds the
critical value `1`.  This holds for *every* real `β`. -/
theorem curieWeiss_phase_transition (β : ℝ) :
    (∃ m, 0 < m ∧ Real.tanh (β * m) = m) ↔ 1 < β := by
  constructor
  · rintro ⟨m, hm, h⟩
    by_contra hle
    push_neg at hle
    exact absurd (curieWeiss_subcritical hle hm.le h) (ne_of_gt hm)
  · exact curieWeiss_supercritical

/-
**Uniqueness of the positive branch.**  Whenever a positive order
parameter exists, it is unique; hence the spontaneous magnetization is a
well-defined single-valued function of `β`.
-/
theorem curieWeiss_unique_positive {β m₁ m₂ : ℝ} (h1 : 0 < m₁) (h2 : 0 < m₂)
    (e1 : Real.tanh (β * m₁) = m₁) (e2 : Real.tanh (β * m₂) = m₂) : m₁ = m₂ := by
  -- By contradiction, assume $m₁ \ne m₂$. Without loss of generality, assume $m₁ < m₂$.
  by_contra h_neq
  wlog h_lt : m₁ < m₂ generalizing m₁ m₂;
  · exact this h2 h1 e2 e1 ( Ne.symm h_neq ) ( lt_of_le_of_ne ( le_of_not_gt h_lt ) ( Ne.symm h_neq ) );
  · -- Apply the mean value theorem to g on the interval [m₁, m₂] (m₁ < m₂): there is ξ ∈ (m₁, m₂) with
    -- β * (1 / Real.cosh (β*ξ)^2) = (g m₂ - g m₁)/(m₂ - m₁).
    obtain ⟨ξ, hξ⟩ : ∃ ξ ∈ Set.Ioo m₁ m₂, deriv (fun m => Real.tanh (β * m)) ξ = (Real.tanh (β * m₂) - Real.tanh (β * m₁)) / (m₂ - m₁) := by
      apply_rules [ exists_deriv_eq_slope ];
      · exact Continuous.continuousOn ( by simpa only [ Real.tanh_eq_sinh_div_cosh ] using Continuous.div ( Real.continuous_sinh.comp ( continuous_const.mul continuous_id' ) ) ( Real.continuous_cosh.comp ( continuous_const.mul continuous_id' ) ) fun x => ne_of_gt ( Real.cosh_pos _ ) );
      · exact fun x hx => DifferentiableAt.differentiableWithinAt ( by simpa only [ Real.tanh_eq_sinh_div_cosh ] using DifferentiableAt.div ( Real.differentiableAt_sinh.comp x ( differentiableAt_id.const_mul β ) ) ( Real.differentiableAt_cosh.comp x ( differentiableAt_id.const_mul β ) ) ( ne_of_gt ( Real.cosh_pos _ ) ) );
    -- Apply the mean value theorem to g on the interval [0, m₁] (0 < m₁): there is η ∈ (0, m₁) with
    -- β * (1 / Real.cosh (β*η)^2) = (g m₁ - g 0)/(m₁ - 0).
    obtain ⟨η, hη⟩ : ∃ η ∈ Set.Ioo 0 m₁, deriv (fun m => Real.tanh (β * m)) η = (Real.tanh (β * m₁) - Real.tanh (β * 0)) / (m₁ - 0) := by
      apply_rules [ exists_deriv_eq_slope ];
      · exact Continuous.continuousOn ( by simpa only [ Real.tanh_eq_sinh_div_cosh ] using Continuous.div ( Real.continuous_sinh.comp ( continuous_const.mul continuous_id' ) ) ( Real.continuous_cosh.comp ( continuous_const.mul continuous_id' ) ) fun x => ne_of_gt ( Real.cosh_pos _ ) );
      · exact fun x hx => DifferentiableAt.differentiableWithinAt ( by simpa only [ Real.tanh_eq_sinh_div_cosh ] using DifferentiableAt.div ( Real.differentiableAt_sinh.comp x ( differentiableAt_id.const_mul β ) ) ( Real.differentiableAt_cosh.comp x ( differentiableAt_id.const_mul β ) ) ( ne_of_gt ( Real.cosh_pos _ ) ) );
    -- By definition of $g$, we know that its derivative is $β * (1 / Real.cosh (β*m)^2)$.
    have h_deriv : ∀ m, deriv (fun m => Real.tanh (β * m)) m = β * (1 / Real.cosh (β * m)^2) := by
      intro m
      have hcomp := (hasDerivAt_tanh (β * m)).comp m ((hasDerivAt_id m).const_mul β)
      simpa [mul_comm] using hcomp.deriv
    simp_all +decide [ ne_of_gt ];
    -- Since $\cosh$ is strictly increasing on $[0, \infty)$, we have $\cosh(\beta \xi) > \cosh(\beta \eta)$.
    have h_cosh_inc : Real.cosh (β * ξ) > Real.cosh (β * η) := by
      by_cases hβ_pos : 0 < β;
      · simp +zetaDelta at *;
        exact mul_lt_mul_of_pos_left ( by rw [ abs_of_pos, abs_of_pos ] <;> linarith ) ( abs_pos.mpr hβ_pos.ne' );
      · nlinarith [ inv_pos.mpr ( sq_pos_of_pos ( Real.cosh_pos ( β * ξ ) ) ) ];
    field_simp at hξ hη;
    ring_nf at *;
    nlinarith [ Real.cosh_pos ( β * η ), Real.cosh_pos ( β * ξ ) ]

/-
**A positive external field destroys the sharp transition.**
For any coupling `β` and any positive external field `h > 0`, the field-driven
self-consistency equation `m = tanh (β m + h)` always has a *positive* solution
`m ∈ (0, 1)`, regardless of whether `β` is sub- or super-critical.  Thus the
sharp `β_c = 1` dichotomy of the zero-field model (`curieWeiss_phase_transition`)
is smoothed out: once a field is applied, spontaneous coherence is present at
every temperature and the transition is no longer sharp.  The proof is an
intermediate-value argument for `f m = tanh (β m + h) - m`, using `f 0 = tanh h > 0`
and `f 1 = tanh (β + h) - 1 < 0`.
-/
theorem curieWeiss_field_positive_solution {β h : ℝ} (hh : 0 < h) :
    ∃ m, 0 < m ∧ m < 1 ∧ Real.tanh (β * m + h) = m := by
  -- By the intermediate value theorem, since $f(0) > 0$ and $f(1) < 0$, there exists some $m \in (0, 1)$ such that $f(m) = 0$.
  obtain ⟨m, hm⟩ : ∃ m ∈ Set.Ioo 0 1, Real.tanh (β * m + h) - m = 0 := by
    apply_rules [ intermediate_value_Ioo' ] <;> norm_num;
    · simpa only [ Real.tanh_eq_sinh_div_cosh ] using ContinuousOn.sub ( ContinuousOn.div ( Real.continuous_sinh.comp_continuousOn ( ContinuousOn.add ( continuousOn_const.mul continuousOn_id ) continuousOn_const ) ) ( Real.continuous_cosh.comp_continuousOn ( ContinuousOn.add ( continuousOn_const.mul continuousOn_id ) continuousOn_const ) ) fun x hx => ne_of_gt ( Real.cosh_pos _ ) ) continuousOn_id;
    · exact ⟨ by rw [ Real.tanh_eq_sinh_div_cosh ] ; exact div_lt_one ( Real.cosh_pos _ ) |>.2 ( Real.sinh_lt_cosh _ ), by rw [ Real.tanh_eq_sinh_div_cosh ] ; exact div_pos ( Real.sinh_pos_iff.2 hh ) ( Real.cosh_pos _ ) ⟩;
  exact ⟨ m, hm.1.1, hm.1.2, sub_eq_zero.mp hm.2 ⟩

end CurieWeiss