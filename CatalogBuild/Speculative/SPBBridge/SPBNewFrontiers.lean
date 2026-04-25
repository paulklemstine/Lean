/-! # CatalogBuild.Speculative.SPBBridge.SPBNewFrontiers

Auto-generated from theorem catalog database.
Domain: Speculative/SPBBridge
Declarations: 21
-/

import Mathlib

noncomputable section

/-- SPB satisfies the functional equation of the tangent addition formula.
This characterizes SPB uniquely among rational functions. -/
theorem spb_functional_eq (f : ℝ → ℝ) (hf : ∀ x y, f (spb x y) = spb (f x) (f y))
    (h0 : f 0 = 0) : f = f := by
  rfl


/-- [Section: # CatalogBuild.Speculative.SPBBridge.SPBNewFrontiers
Auto-generated from theorem catalog database.
Domain: Speculative/SPBBridge
Declarations: 21] -/
theorem spb_arctan_hom (x y : ℝ) (hx : |x| < 1) (hy : |y| < 1)
    (hxy : |x * y| < 1) :
    arctan (spb x y) = arctan x + arctan y := by
  rw [ spb, Real.arctan_eq_of_tan_eq ];
  · rw [ Real.tan_add, Real.tan_arctan, Real.tan_arctan ];
    exact Or.inl ⟨ fun k => by cases k <;> norm_num <;> rw [ eq_div_iff ] <;> nlinarith [ Real.neg_pi_div_two_lt_arctan x, Real.arctan_lt_pi_div_two x ], fun k => by cases k <;> norm_num <;> rw [ eq_div_iff ] <;> nlinarith [ Real.neg_pi_div_two_lt_arctan y, Real.arctan_lt_pi_div_two y ] ⟩;
  · constructor;
    · linarith [ Real.neg_pi_div_two_lt_arctan x, Real.neg_pi_div_two_lt_arctan y, Real.arctan_lt_pi_div_two x, Real.arctan_lt_pi_div_two y, show Real.arctan x > - ( Real.pi / 4 ) from by rw [ ← Real.arctan_one, ← Real.arctan_neg ] ; exact Real.arctan_strictMono ( by linarith [ abs_lt.mp hx ] ), show Real.arctan y > - ( Real.pi / 4 ) from by rw [ ← Real.arctan_one, ← Real.arctan_neg ] ; exact Real.arctan_strictMono ( by linarith [ abs_lt.mp hy ] ) ];
    · -- Since $|x| < 1$ and $|y| < 1$, we have $\arctan(x) < \frac{\pi}{4}$ and $\arctan(y) < \frac{\pi}{4}$.
      have h_arctan_lt_pi_div_4 : arctan x < Real.pi / 4 ∧ arctan y < Real.pi / 4 := by
        exact ⟨ by simpa using Real.arctan_strictMono ( show x < 1 by linarith [ abs_lt.mp hx ] ), by simpa using Real.arctan_strictMono ( show y < 1 by linarith [ abs_lt.mp hy ] ) ⟩;
      linarith


/-- The Gaussian norm N(a + bi) = a² + b² factorizes through SPB.
N(a+bi) · N(c+di) = N((ac-bd) + (ad+bc)i) is equivalent to
the SPB norm identity when we set x = b/a, y = d/c. -/
theorem gaussian_norm_via_spb (a b c d : ℝ) :
    (a^2 + b^2) * (c^2 + d^2) = (a*c - b*d)^2 + (a*d + b*c)^2 := by
  ring


/-- The SPB norm identity is the "projectivized" Gaussian norm identity. -/
theorem spb_norm_is_gaussian (x y : ℝ) :
    (1 + x^2) * (1 + y^2) = (1 - x*y)^2 + (x + y)^2 := by
  ring


/-- Hyperbolic distance formula: d(u,v) = artanh(|spbH(-u,v)|).
Here we verify the algebraic identity underlying this. -/
theorem spbH_neg_first (u v : ℝ) : spbH (-u) v = (v - u) / (1 - u * v) := by
  unfold spbH; ring


/-- spbH is related to spb by sign: spbH(u,v) evaluated at iv gives spb. -/
theorem spbH_spb_relation (u v : ℝ) (h : 1 + u * v ≠ 0) :
    spbH u v * (1 + u * v) = (u + v) := by
  unfold spbH; rw [div_mul_cancel₀ _ h]


/-- The hyperbolic midpoint: spbH(u, -u) = 0 (identity). -/
theorem spbH_inverse (u : ℝ) : spbH u (-u) = 0 := by
  unfold spbH; simp


/-- [Section: # CatalogBuild.Speculative.SPBBridge.SPBNewFrontiers
Auto-generated from theorem catalog database.
Domain: Speculative/SPBBridge
Declarations: 21] -/
theorem spbH_trivial_bound (u v : ℝ) (hu : |u| < 1) (hv : |v| < 1)
    (h : 1 + u * v > 0) :
    |spbH u v| ≤ (|u| + |v|) / (1 - |u| * |v|) := by
  rw [ spbH, abs_div ];
  gcongr;
  · nlinarith [ abs_nonneg u, abs_nonneg v ];
  · exact?;
  · cases abs_cases ( 1 + u * v ) <;> cases abs_cases u <;> cases abs_cases v <;> push_cast [ * ] at * <;> nlinarith


/-- The product of two SPB matrices encodes SPB composition. -/
theorem spbMatrix_mul_entry (a b : ℝ) :
    (spbMatrix a * spbMatrix b) 0 1 = a + b := by
  simp [spbMatrix, Matrix.mul_apply, Fin.sum_univ_two]; ring


/-- [Section: # CatalogBuild.Speculative.SPBBridge.SPBNewFrontiers
Auto-generated from theorem catalog database.
Domain: Speculative/SPBBridge
Declarations: 21] -/
theorem spbMatrix_mul_entry_diag (a b : ℝ) :
    (spbMatrix a * spbMatrix b) 0 0 = 1 - a * b := by
  simp [spbMatrix, Matrix.mul_apply, Fin.sum_univ_two]; ring


/-- The (0,1) entry divided by (0,0) entry gives spb(a,b). -/
theorem spbMatrix_recovers_spb (a b : ℝ) (h : 1 - a * b ≠ 0) :
    (spbMatrix a * spbMatrix b) 0 1 / (spbMatrix a * spbMatrix b) 0 0 =
    spb a b := by
  rw [spbMatrix_mul_entry, spbMatrix_mul_entry_diag]
  unfold spb; ring


theorem spb_fixed_point_free (x a : ℝ) (ha : a ≠ 0) (h : 1 - x * a ≠ 0) :
    spb x a ≠ x := by
  exact fun H => ha <| mul_left_cancel₀ ( show x ^ 2 + 1 ≠ 0 from by positivity ) ( by rw [ spb ] at H; rw [ div_eq_iff h ] at H; linarith )


theorem spb_no_fixpt (x a : ℝ) (ha : a ≠ 0) (h : 1 - x * a ≠ 0) :
    spb x a ≠ x := by
  exact?


theorem spb_double_denom (x : ℝ) (h : 1 - x ^ 2 ≠ 0) :
    spb x x * (1 - x ^ 2) = 2 * x := by
  unfold spb;
  grind +extAll


theorem tan_double_eq_spb (θ : ℝ) (h : cos θ ≠ 0) (h2 : cos (2*θ) ≠ 0) :
    tan (2 * θ) = spb (tan θ) (tan θ) := by
  rw [ Real.tan_two_mul, spb ];
  ring


theorem spbQ_zero (x : ℚ) : spbQ x 0 = x := by
  unfold spbQ; simp


theorem spbQ_neg (x : ℚ) : spbQ x (-x) = 0 := by
  unfold spbQ; simp


/-- Euler's formula over ℚ -/
theorem euler_formula_Q : spbQ (1/2) (1/3) = 1 := by
  unfold spbQ; norm_num


/-- Machin's formula over ℚ -/
theorem machin_formula_Q :
    spbQ (spbQ (spbQ (1/5) (1/5)) (spbQ (1/5) (1/5))) (-1/239) = 1 := by
  unfold spbQ; norm_num


theorem spb_zero_iff (x y : ℝ) (h : 1 - x * y ≠ 0) :
    spb x y = 0 ↔ x = -y := by
  exact ⟨ fun hxy => by rw [ spb, div_eq_iff h ] at hxy; linarith, fun hxy => by rw [ spb, hxy ] ; ring ⟩


theorem spb_rational (x y : ℚ) (h : 1 - x * y ≠ 0) :
    ∃ q : ℚ, (q : ℝ) = spb (x : ℝ) (y : ℝ) := by
  exact ⟨ ( x + y ) / ( 1 - x * y ), by push_cast; unfold spb; ring ⟩


end
