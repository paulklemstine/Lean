/-! # CatalogBuild.Computation.OrbitAnalysis

Auto-generated from theorem catalog database.
Domain: Computation
Declarations: 20
-/

import Mathlib

noncomputable section

def EML_orb (a b : ℝ) : ℝ := Real.exp a - Real.log b


def Phi_orb (p : ℝ × ℝ) : ℝ × ℝ := (EML_orb p.1 p.2, EML_orb p.2 p.1)


def sumCoord (p : ℝ × ℝ) : ℝ := p.1 + p.2


def diag_orb (x : ℝ) : ℝ := Real.exp x - Real.log x


theorem sum_after_phi (x y : ℝ) :
    sumCoord (Phi_orb (x, y)) = (Real.exp x - Real.log y) + (Real.exp y - Real.log x) := by
  simp [sumCoord, Phi_orb, EML_orb]


theorem sum_quadratic_growth (x y : ℝ) (hx : 0 < x) (hy : 0 < y) :
    sumCoord (Phi_orb (x, y)) ≥ sumCoord (x, y) + x ^ 2 / 2 + y ^ 2 / 2 := by
      unfold sumCoord Phi_orb EML_orb;
      have h_exp_x : Real.exp x ≥ 1 + x + x^2 / 2 := by
        -- We'll use the exponential property: $\exp(x) = \sum_{n=0}^{\infty} \frac{x^n}{n!}$.
        have h_exp_series : Real.exp x = ∑' n, x^n / Nat.factorial n := by
          simp +decide [ Real.exp_eq_exp_ℝ, NormedSpace.exp_eq_tsum_div ];
        exact h_exp_series.symm ▸ le_trans ( by norm_num [ Finset.sum_range_succ ] ) ( Summable.sum_le_tsum ( Finset.range 3 ) ( fun _ _ => by positivity ) ( by simpa using Real.summable_pow_div_factorial x ) )
      have h_exp_y : Real.exp y ≥ 1 + y + y^2 / 2 := by
        rw [ Real.exp_eq_exp_ℝ ];
        rw [ NormedSpace.exp_eq_tsum_div ] ; exact le_trans ( by norm_num [ Finset.sum_range_succ ] ) ( Summable.sum_le_tsum ( Finset.range 3 ) ( fun _ _ => by positivity ) ( by simpa using Real.summable_pow_div_factorial y ) ) ;
      have h_log_x : Real.log x ≤ x - 1 := by
        exact Real.log_le_sub_one_of_pos hx
      have h_log_y : Real.log y ≤ y - 1 := by
        exact Real.log_le_sub_one_of_pos hy;
      have h_exp_x' : Real.exp x ≥ 1 + x + x^2 / 2 + x^3 / 6 := by
        rw [ Real.exp_eq_exp_ℝ ];
        rw [ NormedSpace.exp_eq_tsum_div ];
        refine' le_trans _ ( Summable.sum_le_tsum ( Finset.range 4 ) ( fun _ _ => by positivity ) ( by simpa using Real.summable_pow_div_factorial x ) ) ; norm_num [ Finset.sum_range_succ, Nat.factorial ]
      have h_exp_y' : Real.exp y ≥ 1 + y + y^2 / 2 + y^3 / 6 := by
        rw [ Real.exp_eq_exp_ℝ ];
        rw [ NormedSpace.exp_eq_tsum_div ];
        refine' le_trans _ ( Summable.sum_le_tsum ( Finset.range 4 ) ( fun _ _ => by positivity ) ( by simpa using Real.summable_pow_div_factorial y ) ) ; norm_num [ Finset.sum_range_succ, Nat.factorial ];
      nlinarith [ sq_nonneg ( x - y ), mul_pos hx hy, Real.add_one_le_exp x, Real.add_one_le_exp y, Real.log_le_sub_one_of_pos hx, Real.log_le_sub_one_of_pos hy ]


def lyap_orb (p : ℝ × ℝ) : ℝ := Real.exp p.1 + Real.exp p.2


/-- exp(x) + exp(y) > 0 always. -/
theorem lyap_pos (p : ℝ × ℝ) : lyap_orb p > 0 := by
  simp [lyap_orb]; positivity


theorem lyap_after_phi (x y : ℝ) (hx : 0 < x) (hy : 0 < y) :
    lyap_orb (Phi_orb (x, y)) = Real.exp (Real.exp x) / y + Real.exp (Real.exp y) / x := by
  simp [lyap_orb, Phi_orb, EML_orb, Real.exp_sub, Real.exp_log hx, Real.exp_log hy]


theorem phi_diagonal (x : ℝ) :
    Phi_orb (x, x) = (diag_orb x, diag_orb x) := by
  simp [Phi_orb, EML_orb, diag_orb]


theorem diagonal_invariant (x : ℝ) :
    (Phi_orb (x, x)).1 = (Phi_orb (x, x)).2 := by
  simp [Phi_orb, EML_orb]


theorem orbit_start : Phi_orb (1, 1) = (Real.exp 1, Real.exp 1) := by
  simp [Phi_orb, EML_orb, Real.log_one]


theorem orbit_second :
    Phi_orb (Real.exp 1, Real.exp 1) =
    (Real.exp (Real.exp 1) - 1, Real.exp (Real.exp 1) - 1) := by
  simp [Phi_orb, EML_orb, Real.log_exp]


def asymmetry (p : ℝ × ℝ) : ℝ := p.1 - p.2


theorem asymmetry_evolution (x y : ℝ) :
    asymmetry (Phi_orb (x, y)) =
    (Real.exp x - Real.exp y) + (Real.log x - Real.log y) := by
  simp [asymmetry, Phi_orb, EML_orb]; ring


theorem asymmetry_preserved (x y : ℝ) (hy : 0 < y) (hxy : x > y) :
    asymmetry (Phi_orb (x, y)) > 0 := by
  rw [asymmetry_evolution]
  have h1 : Real.exp x > Real.exp y := Real.exp_lt_exp.mpr hxy
  have h2 : Real.log x > Real.log y := Real.log_lt_log hy hxy
  linarith


theorem asymmetry_grows (x y : ℝ) (hy : 1 ≤ y) (hxy : x > y) :
    asymmetry (Phi_orb (x, y)) > asymmetry (x, y) := by
      -- By definition of asymmetry, we have asymmetry (Phi_orb (x, y)) = (Real.exp x - Real.exp y) + (Real.log x - Real.log y).
      have h_asym_def : asymmetry (Phi_orb (x, y)) = (Real.exp x - Real.exp y) + (Real.log x - Real.log y) := by
        exact asymmetry_evolution x y
      -- Since $\exp$ is convex, we have $\exp(x) \geq \exp(y) + \exp(y)(x - y)$.
      have h_exp_convex : Real.exp x ≥ Real.exp y + Real.exp y * (x - y) := by
        have h_exp_convex : ∀ a b : ℝ, a < b → Real.exp b ≥ Real.exp a + Real.exp a * (b - a) := by
          intro a b hab; rw [ show b = a + ( b - a ) by ring, Real.exp_add ] ; nlinarith [ Real.add_one_le_exp ( b - a ), Real.exp_pos a ] ;
        exact h_exp_convex _ _ hxy;
      -- Since $\exp$ is convex, we have $\log(x) > \log(y)$.
      have h_log_pos : Real.log x > Real.log y := by
        gcongr;
      nlinarith [ Real.add_one_le_exp y, Real.exp_pos y, show asymmetry ( x, y ) = x - y by rfl ]


def prodCoord (p : ℝ × ℝ) : ℝ := p.1 * p.2


theorem prod_after_phi (x y : ℝ) :
    prodCoord (Phi_orb (x, y)) =
    (Real.exp x - Real.log y) * (Real.exp y - Real.log x) := by
  simp [prodCoord, Phi_orb, EML_orb]


/-- On the diagonal, the product equals d(x)² ≥ 4. -/
theorem prod_diagonal_ge_four (x : ℝ) (hx : 0 < x) :
    prodCoord (Phi_orb (x, x)) ≥ 4 := by
  rw [prod_after_phi]
  have h : Real.exp x - Real.log x ≥ 2 := by
    nlinarith [Real.add_one_le_exp x, Real.log_le_sub_one_of_pos hx]
  nlinarith


end
