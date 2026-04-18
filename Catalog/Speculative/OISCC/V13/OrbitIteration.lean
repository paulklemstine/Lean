/-
# OISCC V13: Orbit Iteration Theory

Formal analysis of the iterated diagonal map d^n(x) = (exp - ln)^n(x).
We establish precise growth bounds, monotonicity of iterates, and
the super-linear escape rate.

Key results:
1. d^n(x) ≥ x + n for all x > 0, n ≥ 0 (linear escape bound)
2. d^n(x) > 0 for all x > 0, n ≥ 0 (orbit stays positive)
3. d^{n+1}(x) > d^n(x) for all x > 0 (strict monotonicity of iterates)
4. The orbit sequence is eventually ≥ any given bound
5. d²(x) ≥ d(x) + 1 for x > 0 (iterated escape)
-/

import Mathlib

noncomputable section

open Real Filter Topology Set

/-- The diagonal map d(x) = exp(x) - ln(x). -/
def d_oi (x : ℝ) : ℝ := Real.exp x - Real.log x

/-- The n-th iterate of the diagonal map. -/
def d_oi_n (n : ℕ) (x : ℝ) : ℝ := d_oi^[n] x

theorem d_oi_n_zero (x : ℝ) : d_oi_n 0 x = x := rfl
theorem d_oi_n_succ (n : ℕ) (x : ℝ) : d_oi_n (n + 1) x = d_oi (d_oi_n n x) := by
  simp [d_oi_n, Function.iterate_succ_apply']

/-
d(x) > x for all x > 0 (no fixed points).
-/
theorem d_oi_gt_id (x : ℝ) (hx : 0 < x) : d_oi x > x := by
  unfold d_oi;
  have := Real.exp_one_gt_d9.le;
  rw [ show x = 1 + ( x - 1 ) by ring, Real.exp_add ];
  nlinarith [ Real.add_one_le_exp ( x - 1 ), Real.exp_pos ( x - 1 ), Real.log_le_sub_one_of_pos ( by linarith : 0 < 1 + ( x - 1 ) ) ]

/-
d(x) ≥ 2 for all x > 0.
-/
theorem d_oi_ge_two (x : ℝ) (hx : 0 < x) : d_oi x ≥ 2 := by
  linarith [ Real.add_one_le_exp x, Real.log_le_sub_one_of_pos hx, ( show d_oi x = Real.exp x - Real.log x by rfl ) ]

/-- d(x) > 0 for all x > 0. -/
theorem d_oi_pos (x : ℝ) (hx : 0 < x) : d_oi x > 0 := by
  linarith [d_oi_ge_two x hx]

/-
d(x) - x ≥ 1 for all x > 0 (uniform escape speed).
-/
theorem d_oi_disp_ge_one (x : ℝ) (hx : 0 < x) : d_oi x - x ≥ 1 := by
  unfold d_oi;
  have := Real.add_one_le_exp ( x - 1 );
  rw [ show x = 1 + ( x - 1 ) by ring, Real.exp_add ];
  nlinarith [ Real.add_one_le_exp 1, Real.log_le_sub_one_of_pos ( by linarith : 0 < 1 + ( x - 1 ) ) ]

/-- The n-th iterate stays positive. -/
theorem d_oi_n_pos (n : ℕ) (x : ℝ) (hx : 0 < x) : d_oi_n n x > 0 := by
  induction n with
  | zero => exact hx
  | succ n ih => rw [d_oi_n_succ]; exact d_oi_pos _ ih

/-- The n-th iterate is strictly increasing in n. -/
theorem d_oi_n_strict_mono_step (n : ℕ) (x : ℝ) (hx : 0 < x) :
    d_oi_n (n + 1) x > d_oi_n n x := by
  rw [d_oi_n_succ]; exact d_oi_gt_id _ (d_oi_n_pos n x hx)

/-- d^n(x) ≥ x + n for all x > 0 (linear escape). -/
theorem d_oi_n_linear_escape (n : ℕ) (x : ℝ) (hx : 0 < x) :
    d_oi_n n x ≥ x + n := by
  induction n with
  | zero => simp [d_oi_n_zero]
  | succ n ih =>
    rw [d_oi_n_succ]
    have h_pos := d_oi_n_pos n x hx
    have h_disp := d_oi_disp_ge_one (d_oi_n n x) h_pos
    push_cast; linarith

/-- The orbit eventually exceeds any bound. -/
theorem d_oi_n_tendsto (x : ℝ) (hx : 0 < x) (B : ℝ) :
    ∃ N : ℕ, ∀ n, N ≤ n → d_oi_n n x ≥ B := by
  obtain ⟨N, hN⟩ := exists_nat_ge (B - x)
  exact ⟨N, fun n hn => by
    have h1 := d_oi_n_linear_escape n x hx
    have h2 : (N : ℝ) ≤ (n : ℝ) := Nat.cast_le.mpr hn
    linarith⟩

/-- d²(x) ≥ d(x) + 1 for all x > 0. -/
theorem d_oi_double_escape (x : ℝ) (hx : 0 < x) :
    d_oi (d_oi x) ≥ d_oi x + 1 := by
  have h := d_oi_disp_ge_one (d_oi x) (d_oi_pos x hx)
  linarith

/-- The orbit is strictly monotone. -/
theorem orbit_strictly_increasing (x : ℝ) (hx : 0 < x) :
    StrictMono (fun n => d_oi_n n x) := by
  intro m n hmn
  induction hmn with
  | refl => exact d_oi_n_strict_mono_step _ x hx
  | step _ ih => exact lt_trans ih (d_oi_n_strict_mono_step _ x hx)

/-
d(x) is strictly monotone on [1, ∞).
-/
theorem d_oi_strictMono_Ici : StrictMonoOn d_oi (Set.Ici 1) := by
  -- Since the derivative of $d_oi$ is positive on $[1, \infty)$, $d_oi$ is strictly increasing on $[1, \infty)$.
  have h_deriv_pos : ∀ x ∈ Set.Ici 1, 0 < deriv d_oi x := by
    unfold d_oi;
    norm_num +zetaDelta at *;
    intro x hx; norm_num [ Real.differentiableAt_exp, Real.differentiableAt_log, ne_of_gt ( zero_lt_one.trans_le hx ) ];
    nlinarith [ inv_mul_cancel₀ ( by linarith : x ≠ 0 ), Real.add_one_le_exp x ];
  apply_rules [ strictMonoOn_of_deriv_pos ];
  · exact convex_Ici _;
  · exact continuousOn_of_forall_continuousAt fun x hx => by exact DifferentiableAt.continuousAt ( by exact differentiableAt_of_deriv_ne_zero ( ne_of_gt ( h_deriv_pos x hx ) ) ) ;
  · exact fun x hx => h_deriv_pos x <| interior_subset hx

/-
The displacement d(x) - x is convex on (0, ∞).
-/
theorem displacement_convex : ConvexOn ℝ (Set.Ioi 0) (fun x => d_oi x - x) := by
  apply_rules [ convexOn_of_deriv2_nonneg, convex_Ioi ];
  · exact ContinuousOn.sub ( ContinuousOn.sub ( Real.continuousOn_exp ) ( Real.continuousOn_log.mono fun x hx => ne_of_gt hx ) ) continuousOn_id;
  · exact DifferentiableOn.sub ( DifferentiableOn.sub ( Real.differentiable_exp.differentiableOn ) ( Real.differentiableOn_log.mono fun x hx => ne_of_gt <| interior_subset hx ) ) differentiableOn_id;
  · unfold d_oi;
    refine' DifferentiableOn.congr _ _;
    exacts [ fun x => Real.exp x - 1 / x - 1, DifferentiableOn.sub ( DifferentiableOn.sub ( Real.differentiable_exp.differentiableOn ) ( DifferentiableOn.div ( differentiableOn_const _ ) differentiableOn_id fun x hx => ne_of_gt <| interior_subset hx ) ) ( differentiableOn_const _ ), fun x hx => by norm_num [ Real.differentiableAt_exp, Real.differentiableAt_log, ne_of_gt <| interior_subset hx ] ];
  · -- Let's calculate the first derivative of $d(x) - x$.
    have h_deriv : ∀ x > 0, deriv (fun x => d_oi x - x) x = Real.exp x - 1 / x - 1 := by
      intro x hx; unfold d_oi; norm_num [ Real.differentiableAt_exp, Real.differentiableAt_log, hx.ne' ] ;
    -- Let's calculate the second derivative of $d(x) - x$.
    have h_deriv2 : ∀ x > 0, deriv^[2] (fun x => d_oi x - x) x = Real.exp x + 1 / x^2 := by
      have h_deriv2 : ∀ x > 0, deriv^[2] (fun x => d_oi x - x) x = deriv (fun x => Real.exp x - 1 / x - 1) x := by
        exact fun x hx => Filter.EventuallyEq.deriv_eq ( Filter.eventuallyEq_of_mem ( Ioi_mem_nhds hx ) fun y hy => h_deriv y hy );
      intro x hx; rw [ h_deriv2 x hx ] ; norm_num [ Real.differentiableAt_exp, differentiableAt_inv, hx.ne' ] ;
    exact fun x hx => h_deriv2 x ( interior_subset hx ) ▸ add_nonneg ( Real.exp_nonneg x ) ( one_div_nonneg.mpr ( sq_nonneg x ) )

end