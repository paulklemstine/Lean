import Mathlib

/-! # CatalogBuild.Geometry.Stereographic.OmegaPoint

Auto-generated from theorem catalog database.
Domain: Geometry/Stereographic
Declarations: 19
-/


noncomputable section

/-- The x-coordinate of the inverse stereographic projection ℝ → S¹ -/
def invStereoX (t : ℝ) : ℝ := 2 * t / (t ^ 2 + 1)




/-- The y-coordinate of the inverse stereographic projection ℝ → S¹ -/
def invStereoY (t : ℝ) : ℝ := (t ^ 2 - 1) / (t ^ 2 + 1)




/-- The Omega Point: the north pole of S¹, the "point at infinity" -/
def omegaPoint : ℝ × ℝ := (0, 1)




/-- The denominator t² + 1 is always positive -/
theorem denom_pos (t : ℝ) : 0 < t ^ 2 + 1 := by positivity




/-- The denominator t² + 1 is never zero -/
theorem denom_ne_zero (t : ℝ) : t ^ 2 + 1 ≠ 0 := ne_of_gt (denom_pos t)




/-- The Omega Point lies on the unit circle -/
theorem omega_point_on_circle : omegaPoint.1 ^ 2 + omegaPoint.2 ^ 2 = 1 := by
  simp [omegaPoint]




/-- [Section: # CatalogBuild.Geometry.Stereographic.OmegaPoint
Auto-generated from theorem catalog database.
Domain: Geometry/Stereographic
Declarations: 19] -/
theorem omega_x_tendsto_atTop :
    Tendsto invStereoX atTop (nhds 0) := by
  -- To prove the limit, we can use the fact that the denominator grows faster than the numerator.
  have h_lim : Filter.Tendsto (fun t : ℝ => 2 / (t + 1 / t)) Filter.atTop (nhds 0) := by
    exact tendsto_const_nhds.div_atTop ( Filter.tendsto_id.atTop_add <| tendsto_const_nhds.div_atTop Filter.tendsto_id );
  refine h_lim.congr' ( by filter_upwards [ Filter.eventually_gt_atTop 0 ] with t ht using by rw [ show invStereoX t = 2 / ( t + 1 / t ) by rw [ invStereoX, div_eq_div_iff ] <;> ring <;> nlinarith [ inv_mul_cancel₀ ht.ne' ] ] )




/-- [Section: # CatalogBuild.Geometry.Stereographic.OmegaPoint
Auto-generated from theorem catalog database.
Domain: Geometry/Stereographic
Declarations: 19] -/
theorem omega_x_tendsto_atBot :
    Tendsto invStereoX atBot (nhds 0) := by
  -- To prove the limit as $t \to -\infty$, we can use the fact that the limit of a function as $t \to -\infty$ is the same as the limit of the function as $t \to \infty$ with the sign reversed.
  have h_neg : Filter.Tendsto (fun t : ℝ => invStereoX (-t)) Filter.atTop (nhds 0) := by
    convert omega_x_tendsto_atTop.neg using 2 ; norm_num [ invStereoX ] ; ring;
    norm_num;
  convert h_neg.comp Filter.tendsto_neg_atBot_atTop using 2 ; aesop




theorem omega_y_tendsto_atTop :
    Tendsto invStereoY atTop (nhds 1) := by
  -- We can decompose the function as $1 - \frac{2}{t^2 + 1}$.
  suffices h_decomp : Tendsto (fun t : ℝ => 1 - 2 / (t ^ 2 + 1)) atTop (nhds 1) by
    convert h_decomp using 2 ; rw [ invStereoY ] ; rw [ one_sub_div ( by positivity ) ] ; ring;
  exact le_trans ( tendsto_const_nhds.sub <| tendsto_const_nhds.div_atTop <| Filter.tendsto_atTop_add_const_right _ _ <| by norm_num ) <| by norm_num;




theorem omega_y_tendsto_atBot :
    Tendsto invStereoY atBot (nhds 1) := by
  rw [ Metric.tendsto_nhds ] at *;
  unfold invStereoY;
  exact fun ε hε => Filter.eventually_atBot.2 ⟨ -ε⁻¹ - 1, fun x hx => abs_lt.2 ⟨ by nlinarith [ sq_nonneg ( x + 1 ), mul_inv_cancel₀ hε.ne.symm, mul_div_cancel₀ ( x ^ 2 - 1 ) ( show x ^ 2 + 1 ≠ 0 by nlinarith ) ], by nlinarith [ sq_nonneg ( x + 1 ), mul_inv_cancel₀ hε.ne.symm, mul_div_cancel₀ ( x ^ 2 - 1 ) ( show x ^ 2 + 1 ≠ 0 by nlinarith ) ] ⟩ ⟩




/-- **The Omega Point Theorem (at +∞)**: The inverse stereographic projection
converges to the north pole (0, 1) as t → +∞.
The north pole is the Omega Point — the image of infinity. -/
theorem omega_point_is_north_pole_atTop :
    Tendsto invStereo atTop (nhds omegaPoint) := by
  rw [show omegaPoint = (0, 1) from rfl]
  exact Filter.Tendsto.prodMk_nhds omega_x_tendsto_atTop omega_y_tendsto_atTop




/-- **The Omega Point Theorem (at -∞)**: The inverse stereographic projection
converges to the north pole (0, 1) as t → -∞. -/
theorem omega_point_is_north_pole_atBot :
    Tendsto invStereo atBot (nhds omegaPoint) := by
  rw [show omegaPoint = (0, 1) from rfl]
  exact Filter.Tendsto.prodMk_nhds omega_x_tendsto_atBot omega_y_tendsto_atBot




theorem stereoInvFunAux_tendsto_north_pole
    {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]
    (v : E) (hv : ‖v‖ = 1) :
    Tendsto (stereoInvFunAux v) (Bornology.cobounded E) (nhds v) := by
  -- Let's simplify the expression for the difference.
  suffices h_simp : Filter.Tendsto (fun w : E => ((‖w‖^2 - 4) / (‖w‖^2 + 4)) • v + (4 / (‖w‖^2 + 4)) • w) (Bornology.cobounded E) (nhds v) by
    convert h_simp using 2 ; unfold stereoInvFunAux ; norm_num ; ring;
    norm_num [ add_comm, add_left_comm, add_assoc, mul_comm, smul_smul ] ; ring;
  -- We can split the limit into two parts and show each part tends to its respective limit.
  have h_split : Filter.Tendsto (fun w : E => ((‖w‖^2 - 4) / (‖w‖^2 + 4))) (Bornology.cobounded E) (nhds 1) ∧ Filter.Tendsto (fun w : E => (4 / (‖w‖^2 + 4)) • w) (Bornology.cobounded E) (nhds 0) := by
    constructor;
    · -- We can divide the numerator and the denominator by ‖w‖^2.
      have h_div : Filter.Tendsto (fun w : E => (1 - 4 / (‖w‖^2 : ℝ)) / (1 + 4 / (‖w‖^2 : ℝ))) (Bornology.cobounded E) (nhds 1) := by
        -- As ‖w‖ → ∞, the term $4 / (‖w‖^2)$ tends to $0$.
        have h_zero : Filter.Tendsto (fun w : E => 4 / (‖w‖^2 : ℝ)) (Bornology.cobounded E) (nhds 0) := by
          refine' tendsto_const_nhds.div_atTop _;
          exact Filter.tendsto_pow_atTop ( by norm_num ) |> Filter.Tendsto.comp <| tendsto_norm_cobounded_atTop;
        convert Filter.Tendsto.div ( tendsto_const_nhds.sub h_zero ) ( tendsto_const_nhds.add h_zero ) _ using 2 <;> norm_num;
      refine h_div.congr' ?_;
      filter_upwards [ Bornology.eventually_ne_cobounded 0 ] with w hw using by rw [ one_sub_div ( by positivity ), one_add_div ( by positivity ) ] ; rw [ div_div_div_cancel_right₀ ( by positivity ) ] ;
    · have h_second_term : Filter.Tendsto (fun w : E => (4 / (‖w‖^2 + 4)) * ‖w‖) (Bornology.cobounded E) (nhds 0) := by
        -- We can simplify the expression inside the limit further by dividing the numerator and the denominator by ‖w‖.
        suffices h_simplify' : Filter.Tendsto (fun w : E => 4 / (‖w‖ + 4 / ‖w‖)) (Bornology.cobounded E) (nhds 0) by
          grind;
        refine' tendsto_const_nhds.div_atTop _;
        exact Filter.tendsto_atTop_mono ( fun w => le_add_of_nonneg_right <| div_nonneg zero_le_four <| norm_nonneg _ ) ( tendsto_norm_cobounded_atTop );
      exact tendsto_zero_iff_norm_tendsto_zero.mpr ( by simpa [ norm_smul, abs_of_nonneg ( by positivity : 0 ≤ ( ‖_‖^2 + 4 : ℝ ) ⁻¹ * 4 ) ] using h_second_term.norm );
  simpa using Filter.Tendsto.add ( h_split.1.smul_const v ) h_split.2




/-- The Omega Point in the one-point compactification is the point at infinity -/
def omegaPointOnePoint : OnePoint ℝ := OnePoint.infty




/-- Every finite point embeds into the one-point compactification -/
def finiteOracle (n : ℝ) : OnePoint ℝ := .some n




/-- The Omega Point is NOT a finite oracle -/
theorem omega_not_finite : ∀ n : ℝ, omegaPointOnePoint ≠ finiteOracle n := by
  intro n; exact nofun




/-- Oracle level n maps to a point on S¹ via inverse stereographic projection.
As n → ∞, these points converge to the Omega Point (north pole). -/
def oracleOnSphere (n : ℕ) : ℝ × ℝ := invStereo (n : ℝ)




/-- Each oracle level maps to the unit circle -/
theorem oracle_on_circle (n : ℕ) :
    (oracleOnSphere n).1 ^ 2 + (oracleOnSphere n).2 ^ 2 = 1 := by
  exact inv_stereo_on_circle (n : ℝ)




/-- The oracle hierarchy converges to the Omega Point on the sphere -/
theorem oracle_hierarchy_converges_to_omega :
    Tendsto (fun n : ℕ => invStereo (n : ℝ)) atTop (nhds omegaPoint) :=
  omega_point_is_north_pole_atTop.comp tendsto_natCast_atTop_atTop




end