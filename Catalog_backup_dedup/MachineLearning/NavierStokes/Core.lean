import Mathlib

/-!
# Navier–Stokes Regularity: A Priori Differential-Inequality Core

This file formalizes the *scalar a priori estimates* that underlie the regularity
theory of the incompressible Navier–Stokes equations. Rather than formalizing the
full PDE (which is far beyond current Mathlib infrastructure), we isolate the exact
ordinary differential inequalities that energy methods reduce the problem to, and
prove their consequences rigorously. Each statement is phrased for an abstract
"observable" `Y : ℝ → ℝ` (time ↦ energy / enstrophy) whose time derivative obeys
the inequality coming from the corresponding `L²` estimate.

## Mathematical background

For the incompressible Navier–Stokes equations on a periodic / bounded domain,
multiplying by the velocity and integrating gives the **energy identity**
`d/dt (½‖u‖₂²) = -ν ‖∇u‖₂²`, and multiplying the vorticity equation by the
vorticity gives the **enstrophy identity**
`d/dt (½‖ω‖₂²) = -ν ‖∇ω‖₂² + (stretching term)`.

* In **2D** the vortex–stretching term `∫ ω·(∇u)ω` *vanishes identically*, so the
  enstrophy is monotonically non-increasing: this is the engine of 2D global
  regularity. We capture this as `enstrophy_2d_global_bound`.

* The Poincaré inequality `‖∇u‖₂² ≥ λ₁ ‖u‖₂²` upgrades energy dissipation to
  exponential decay: `energy_exponential_decay`.

* In **3D** the stretching term obeys `|∫ ω·(∇u)ω| ≤ C ‖ω‖₂³` (Sobolev /
  interpolation), giving the *supercritical* inequality `Z' ≤ C Z³`. This yields
  only a finite a priori existence time and the classical blow-up rate bound,
  formalized in `enstrophy_3d_apriori_bound`.

* When dissipation dominates the stretching term (small data relative to
  viscosity), one gets `Z' ≤ -a Z + C Z³`, and under an a priori bound the
  enstrophy decays exponentially: `enstrophy_3d_small_data_decay`. Its
  *unconditional* invariance form `enstrophy_3d_small_data_invariant` is the
  scalar shadow of small-data global regularity in 3D.

## Main results

* `enstrophy_2d_global_bound` — 2D enstrophy stays below its initial value (global regularity engine).
* `energy_exponential_decay` — energy decays like `E₀ e^{-c t}` under a Poincaré-type dissipation bound.
* `energy_tendsto_zero` — consequently the energy tends to `0`.
* `enstrophy_3d_apriori_bound` — 3D enstrophy obeys the blow-up-rate bound `Z(t)² ≤ Z₀²/(1 - 2C Z₀² t)`.
* `enstrophy_3d_small_data_decay` — conditional (a priori bounded) exponential decay in 3D.
* `enstrophy_3d_small_data_invariant` — unconditional small-data enstrophy invariance in 3D.

-- !-- Lab Notes -- !--
-- Hypothesis H1 (2D): the *only* structural fact needed for 2D global regularity at
--   the level of a priori bounds is sign-definiteness of the enstrophy derivative.
--   We confirmed this collapses to `antitone_of_deriv_nonpos`.
-- Hypothesis H2 (decay): exponential decay should follow from the integrating
--   factor `g(t) = E(t) e^{c t}`; experiment confirmed `g' ≤ 0` needs *no* sign
--   assumption on `E`, only the differential inequality. Result is therefore stated
--   without `E ≥ 0`.
-- Hypothesis H3 (3D): the supercritical cubic inequality is best linearized via the
--   substitution `w = 1/Z²`, which satisfies the *linear* bound `w' ≥ -2C`. This is
--   the cleanest route and avoids comparison-ODE existence theory entirely.
-- Failure analysis: a direct Grönwall attack on `Z' ≤ C Z³` fails because the
--   comparison solution blows up; the reciprocal substitution sidesteps this by
--   turning blow-up into a positivity threshold `w(t) > 0 ⇔ t < T*`.
-/

open scoped Topology
open Filter

namespace NavierStokes

/-! ## 2D global regularity: enstrophy is non-increasing -/

/-
**2D enstrophy global bound.** In two dimensions the vortex–stretching term
vanishes, so the enstrophy `Z(t)` (with derivative `D t`) has non-positive
derivative `D t ≤ 0`. Hence it never exceeds its initial value: a global a priori
bound, which is exactly what powers 2D global regularity.
-/
theorem enstrophy_2d_global_bound
    (Z D : ℝ → ℝ)
    (hZ : ∀ t, HasDerivAt Z (D t) t)
    (hdiss : ∀ t, D t ≤ 0) :
    ∀ t, 0 ≤ t → Z t ≤ Z 0 := by
  by_contra h_contra;
  -- Since for every t we have `HasDerivAt Z (D t) t`, the function Z is differentiable everywhere, and `deriv Z t = D t ≤ 0`.
  have h_diff : Differentiable ℝ Z := by
    exact fun t => ( hZ t |> HasDerivAt.differentiableAt )
  have h_deriv_nonpos : ∀ t, deriv Z t ≤ 0 := by
    exact fun t => by simpa only [ hZ t |> HasDerivAt.deriv ] using hdiss t;
  exact h_contra fun t ht => by simpa using antitone_of_deriv_nonpos h_diff h_deriv_nonpos ht;

/-
**2D enstrophy bound from the dissipation identity.** Stating the previous
result in the physical form `Z'(t) = -2 ν G(t)` with viscosity `ν ≥ 0` and
non-negative palinstrophy `G(t) ≥ 0` (the squared `L²` norm of `∇ω`).
-/
theorem enstrophy_2d_global_bound_physical
    (Z G : ℝ → ℝ) (ν : ℝ) (hν : 0 ≤ ν) (hG : ∀ t, 0 ≤ G t)
    (hZ : ∀ t, HasDerivAt Z (-2 * ν * G t) t) :
    ∀ t, 0 ≤ t → Z t ≤ Z 0 := by
  intros t ht
  have := @enstrophy_2d_global_bound Z (fun t => -2 * ν * G t) hZ (fun t => by
    exact mul_nonpos_of_nonpos_of_nonneg ( mul_nonpos_of_nonpos_of_nonneg ( by norm_num ) hν ) ( hG t )) t ht
  aesop

/-! ## Energy decay via the Poincaré inequality -/

/-
**Exponential energy decay.** If the energy `E(t)` satisfies the
Poincaré-strengthened dissipation bound `E'(t) ≤ -c E(t)`, then
`E(t) ≤ E₀ e^{-c t}` for all `t ≥ 0`. No sign assumption on `E` (or on the rate
`c`) is needed: the integrating factor `E(t) e^{c t}` is non-increasing.
-/
theorem energy_exponential_decay
    (E D : ℝ → ℝ) (c : ℝ)
    (hE : ∀ t, HasDerivAt E (D t) t)
    (hineq : ∀ t, D t ≤ -c * E t) :
    ∀ t, 0 ≤ t → E t ≤ E 0 * Real.exp (-c * t) := by
  -- Define `g t = E t * Real.exp (c * t)`. Then `HasDerivAt g (D t * Real.exp (c*t) + E t * (Real.exp (c*t) * c)) t` by the product rule (`HasDerivAt.mul` with `hE t` and the derivative of `fun t => Real.exp (c*t)` which is `Real.exp (c*t) * c`).
  set g : ℝ → ℝ := fun t => E t * Real.exp (c * t)
  have h_deriv_g : ∀ t, HasDerivAt g ((D t + c * E t) * Real.exp (c * t)) t := by
    intro t; convert HasDerivAt.mul ( hE t ) ( HasDerivAt.exp ( hasDerivAt_id' t |> HasDerivAt.const_mul c ) ) using 1 ; ring;
  -- Since `D t + c * E t ≤ 0`, we have `deriv g t ≤ 0`. Hence g is antitone (via `antitone_of_deriv_nonpos`, using differentiability from each `HasDerivAt` and `(...).deriv`).
  have h_antitone_g : Antitone g := by
    apply_rules [ antitone_of_deriv_nonpos ];
    · exact fun t => ( h_deriv_g t |> HasDerivAt.differentiableAt );
    · exact fun t => by rw [ h_deriv_g t |> HasDerivAt.deriv ] ; exact mul_nonpos_of_nonpos_of_nonneg ( by linarith [ hineq t ] ) ( Real.exp_nonneg _ ) ;
  intro t ht; have := h_antitone_g ht; simp_all +decide [ Real.exp_neg, mul_comm c ];
  simp +zetaDelta at *;
  rwa [ ← div_eq_mul_inv, le_div_iff₀ ( Real.exp_pos _ ), mul_comm t c ]

/-
**Energy tends to zero.** With a strictly positive decay rate `c > 0` and
non-negative energy, the energy converges to `0` as `t → ∞`.
-/
theorem energy_tendsto_zero
    (E D : ℝ → ℝ) (c : ℝ) (hc : 0 < c)
    (hE : ∀ t, HasDerivAt E (D t) t)
    (hEnn : ∀ t, 0 ≤ E t)
    (hineq : ∀ t, D t ≤ -c * E t) :
    Tendsto E atTop (𝓝 0) := by
  convert squeeze_zero_norm' _ _;
  exacts [ fun t => E 0 * Real.exp ( -c * t ), Filter.eventually_atTop.mpr ⟨ 0, fun t ht => by rw [ Real.norm_of_nonneg ( hEnn t ) ] ; exact energy_exponential_decay E D c hE hineq t ht ⟩, by simpa using tendsto_const_nhds.mul ( Real.tendsto_exp_atBot.comp <| Filter.tendsto_neg_atTop_atBot.comp <| Filter.tendsto_id.const_mul_atTop hc ) ]

/-! ## 3D supercritical a priori bound -/

/-
**3D enstrophy a priori (blow-up rate) bound.** The supercritical inequality
`Z'(t) ≤ C Z(t)³` (`C > 0`, `Z > 0`) yields, on the maximal interval
`0 ≤ t < T* = 1/(2 C Z₀²)`, the sharp comparison bound
`Z(t)² ≤ Z₀² / (1 - 2 C Z₀² t)`. The right-hand side blows up exactly at `T*`,
encoding the classical lower bound on the existence time.
-/
theorem enstrophy_3d_apriori_bound
    (Z D : ℝ → ℝ) (C : ℝ) (hC : 0 < C)
    (hpos : ∀ t, 0 < Z t)
    (hZ : ∀ t, HasDerivAt Z (D t) t)
    (hineq : ∀ t, D t ≤ C * (Z t) ^ 3) :
    ∀ t, 0 ≤ t → t < 1 / (2 * C * (Z 0) ^ 2) →
      (Z t) ^ 2 ≤ (Z 0) ^ 2 / (1 - 2 * C * (Z 0) ^ 2 * t) := by
  intros t ht ht';
  -- Let's define the auxiliary function $w(t) = \frac{1}{Z(t)^2}$.
  set w : ℝ → ℝ := fun t => 1 / (Z t)^2;
  -- By definition of $w$, we know that $w'(t) \geq -2C$.
  have hw_deriv : ∀ t, deriv w t ≥ -2 * C := by
    intro t; erw [ deriv_div ] <;> norm_num [ hZ t |> HasDerivAt.differentiableAt ];
    · rw [ le_div_iff₀ ] <;> nlinarith [ hpos t, hZ t |> HasDerivAt.deriv, hineq t, pow_pos ( hpos t ) 3, pow_pos ( hpos t ) 4, pow_pos ( hpos t ) 5, pow_pos ( hpos t ) 6, pow_pos ( hpos t ) 7, pow_pos ( hpos t ) 8, pow_pos ( hpos t ) 9, pow_pos ( hpos t ) 10 ];
    · linarith [ hpos t ];
  -- By fundamental theorem of calculus, we have $w(t) \geq w(0) - 2Ct$.
  have hw_ftc : ∀ t ≥ 0, w t ≥ w 0 - 2 * C * t := by
    intro t ht; by_contra h_contra; push_neg at h_contra; (
    have := exists_deriv_eq_slope w ( show t > 0 from ht.lt_of_ne ( by rintro rfl; norm_num at h_contra ) );
    exact absurd ( this ( continuousOn_of_forall_continuousAt fun x hx => DifferentiableAt.continuousAt ( by exact DifferentiableAt.div ( differentiableAt_const _ ) ( DifferentiableAt.pow ( hZ x |> HasDerivAt.differentiableAt ) _ ) ( ne_of_gt ( sq_pos_of_pos ( hpos x ) ) ) ) ) ( fun x hx => DifferentiableAt.differentiableWithinAt ( by exact DifferentiableAt.div ( differentiableAt_const _ ) ( DifferentiableAt.pow ( hZ x |> HasDerivAt.differentiableAt ) _ ) ( ne_of_gt ( sq_pos_of_pos ( hpos x ) ) ) ) ) ) ( by rintro ⟨ c, ⟨ hc₁, hc₂ ⟩, hc ⟩ ; rw [ eq_div_iff ] at hc <;> nlinarith [ hw_deriv c ] ));
  rw [ le_div_iff₀ ] <;> norm_num at *;
  · have := hw_ftc t ht; rw [ div_add', le_div_iff₀ ] at this <;> nlinarith [ hpos t, hpos 0, pow_pos ( hpos t ) 2, pow_pos ( hpos 0 ) 2, mul_div_cancel₀ 1 ( ne_of_gt ( pow_pos ( hpos 0 ) 2 ) ) ] ;
  · nlinarith [ mul_inv_cancel₀ ( ne_of_gt hC ), mul_inv_cancel₀ ( ne_of_gt ( sq_pos_of_pos ( hpos 0 ) ) ), mul_pos hC ( sq_pos_of_pos ( hpos 0 ) ) ]

/-! ## 3D small-data results -/

/-
**3D conditional (small-data) exponential decay.** When dissipation dominates
stretching, `Z'(t) ≤ -a Z(t) + C Z(t)³`. If a uniform a priori bound `Z(t) ≤ M`
holds with `C M² ≤ a` (small data), then the enstrophy decays exponentially with
rate `a - C M²`. This is a genuine (non-increasing) decay precisely in the
small-data regime `C M² ≤ a`, where the rate `a - C M²` is non-negative; the bound
itself holds for the stated reasons regardless, so we do not assume `C M² ≤ a`.
-/
theorem enstrophy_3d_small_data_decay
    (Z D : ℝ → ℝ) (a C M : ℝ) (hC : 0 ≤ C)
    (hM : ∀ t, Z t ≤ M)
    (hZnn : ∀ t, 0 ≤ Z t)
    (hZ : ∀ t, HasDerivAt Z (D t) t)
    (hineq : ∀ t, D t ≤ -a * Z t + C * (Z t) ^ 3) :
    ∀ t, 0 ≤ t → Z t ≤ Z 0 * Real.exp (-(a - C * M ^ 2) * t) := by
  convert energy_exponential_decay Z D ( a - C * M ^ 2 ) _ _ using 1;
  · assumption;
  · intro t; nlinarith [ hineq t, hZnn t, hM t, mul_le_mul_of_nonneg_left ( hM t ) ( hZnn t ), mul_le_mul_of_nonneg_left ( hM t ) ( hC ) ] ;

/-
**3D unconditional small-data enstrophy invariance.** If the initial enstrophy
is small relative to viscosity, `C (Z₀)² < a`, then the enstrophy never exceeds its
initial value `Z₀`, for all future times. This is the scalar shadow of small-data
global regularity in 3D: the a priori bound is *self-sustaining*, so no blow-up can
occur. The (mild) hypothesis `0 < Z 0` rules out the degenerate zero-enstrophy
state and makes the first-crossing derivative strictly negative.
-/
theorem enstrophy_3d_small_data_invariant
    (Z D : ℝ → ℝ) (a C : ℝ)
    (hZ0 : 0 < Z 0)
    (hZ : ∀ t, HasDerivAt Z (D t) t)
    (hsmall : C * (Z 0) ^ 2 < a)
    (hineq : ∀ t, D t ≤ -a * Z t + C * (Z t) ^ 3) :
    ∀ t, 0 ≤ t → Z t ≤ Z 0 := by
  intro t ht;
  by_contra h_contra;
  -- Consider the nonempty compact set `K = {t ∈ Set.Icc 0 t | Z t ≤ Z 0}` (contains 0). Let `s = sSup K`.
  obtain ⟨s, hs⟩ : ∃ s ∈ Set.Icc 0 t, Z s = Z 0 ∧ ∀ u ∈ Set.Icc 0 t, u > s → Z u > Z 0 := by
    obtain ⟨s, hs⟩ : ∃ s ∈ Set.Icc 0 t, Z s ≤ Z 0 ∧ ∀ u ∈ Set.Icc 0 t, u > s → Z u > Z 0 := by
      have h_compact : IsCompact {u ∈ Set.Icc 0 t | Z u ≤ Z 0} := by
        exact CompactIccSpace.isCompact_Icc.of_isClosed_subset ( isClosed_Icc.inter <| isClosed_le ( show Continuous Z from continuous_iff_continuousAt.mpr fun x => HasDerivAt.continuousAt <| hZ x ) continuous_const ) fun x hx => hx.1;
      have := h_compact.exists_isGreatest;
      exact Exists.elim ( this ⟨ 0, ⟨ by norm_num, ht ⟩, by linarith ⟩ ) fun x hx => ⟨ x, hx.1.1, hx.1.2, fun u hu hu' => not_le.1 fun hu'' => hu'.not_ge <| hx.2 ⟨ hu, hu'' ⟩ ⟩;
    refine' ⟨ s, hs.1, le_antisymm hs.2.1 _, hs.2.2 ⟩;
    by_cases hs_eq_t : s = t;
    · grind;
    · have h_lim : Filter.Tendsto Z (nhdsWithin s (Set.Ioi s)) (nhds (Z s)) := by
        exact HasDerivAt.continuousAt ( hZ s ) |> ContinuousAt.continuousWithinAt;
      exact le_of_tendsto_of_tendsto tendsto_const_nhds h_lim ( Filter.eventually_of_mem ( Ioo_mem_nhdsGT <| lt_of_le_of_ne hs.1.2 hs_eq_t ) fun u hu => le_of_lt <| hs.2.2 u ⟨ by linarith [ hu.1, hs.1.1 ], by linarith [ hu.2, hs.1.2 ] ⟩ hu.1 );
  -- Since $Z(s) = Z(0)$ and $Z'(s) < 0$, there exists a $\delta > 0$ such that $Z(u) < Z(0)$ for $u \in (s, s + \delta)$.
  obtain ⟨δ, hδ_pos, hδ⟩ : ∃ δ > 0, ∀ u, s < u ∧ u < s + δ → Z u < Z 0 := by
    have h_deriv_neg : D s < 0 := by
      have := hineq s; rw [ hs.2.1 ] at this; nlinarith [ mul_lt_mul_of_pos_right hsmall hZ0, hZ0 ] ;
    have := hZ s;
    have := this.tendsto_slope_zero;
    have := Metric.tendsto_nhdsWithin_nhds.mp this ( -D s ) ( by linarith );
    obtain ⟨ δ, hδ₁, hδ₂ ⟩ := this; use δ, hδ₁; intros u hu; have := hδ₂ ( show u - s ≠ 0 by linarith ) ( abs_lt.mpr ⟨ by linarith, by linarith ⟩ ) ; norm_num at *;
    nlinarith [ abs_lt.mp this, inv_mul_cancel_left₀ ( by linarith : ( u - s ) ≠ 0 ) ( Z u - Z s ) ];
  contrapose! hδ;
  exact ⟨ s + Min.min δ ( t - s ) / 2, ⟨ by linarith [ lt_min hδ_pos ( sub_pos.mpr ( show s < t from lt_of_le_of_ne hs.1.2 ( by rintro rfl; linarith ) ) ) ], by linarith [ min_le_left δ ( t - s ), min_le_right δ ( t - s ) ] ⟩, le_of_lt ( hs.2.2 _ ⟨ by linarith [ hs.1.1, lt_min hδ_pos ( sub_pos.mpr ( show s < t from lt_of_le_of_ne hs.1.2 ( by rintro rfl; linarith ) ) ) ], by linarith [ hs.1.2, min_le_left δ ( t - s ), min_le_right δ ( t - s ) ] ⟩ ( by linarith [ lt_min hδ_pos ( sub_pos.mpr ( show s < t from lt_of_le_of_ne hs.1.2 ( by rintro rfl; linarith ) ) ) ] ) ) ⟩

end NavierStokes