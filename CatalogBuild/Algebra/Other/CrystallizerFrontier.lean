/-! # CatalogBuild.Algebra.Other.CrystallizerFrontier

Auto-generated from theorem catalog database.
Domain: Algebra/Other
Declarations: 33
-/

import Mathlib

noncomputable section

/-- Inverse stereographic projection: from the circle back to the line.
For (x, y) on S¹ with y ≠ -1, the inverse is x/(1+y). -/
noncomputable def inv_stereo (x y : ℝ) : ℝ := x / (1 + y)


/-- [Section: # CatalogBuild.Speculative.Other.CrystallizerFrontier
Auto-generated from theorem catalog database.
Domain: Speculative/Other
Declarations: 33] -/
theorem stereo_inv_stereo_fst (x y : ℝ) (hS : x ^ 2 + y ^ 2 = 1) (hy : y ≠ -1) :
    let t := inv_stereo x y
    2 * t / (1 + t ^ 2) = x := by
  unfold inv_stereo;
  grind


/-- [Section: # CatalogBuild.Speculative.Other.CrystallizerFrontier
Auto-generated from theorem catalog database.
Domain: Speculative/Other
Declarations: 33] -/
theorem stereo_inv_stereo_snd (x y : ℝ) (hS : x ^ 2 + y ^ 2 = 1) (hy : y ≠ -1) :
    let t := inv_stereo x y
    (1 - t ^ 2) / (1 + t ^ 2) = y := by
  unfold inv_stereo
  field_simp [hy]
  ring_nf at *;
  grind


/-- The quadratic form Q(v) = v₁² + v₂² - v₃² that defines Pythagorean triples.
The Berggren matrices preserve the zero set of this form. -/
def pythag_form : Matrix (Fin 3) (Fin 3) ℤ := !![1, 0, 0; 0, 1, 0; 0, 0, -1]


/-- The Berggren A-matrix preserves the Pythagorean quadratic form:
Aᵀ · diag(1,1,-1) · A = diag(1,1,-1). -/
theorem berggren_A_preserves_form :
    let A : Matrix (Fin 3) (Fin 3) ℤ := !![1, -2, 2; 2, -1, 2; 2, -2, 3]
    A.transpose * pythag_form * A = pythag_form := by native_decide


/-- The Berggren B-matrix preserves the Pythagorean quadratic form. -/
theorem berggren_B_preserves_form :
    let B : Matrix (Fin 3) (Fin 3) ℤ := !![1, 2, 2; 2, 1, 2; 2, 2, 3]
    B.transpose * pythag_form * B = pythag_form := by native_decide


/-- The Berggren C-matrix preserves the Pythagorean quadratic form. -/
theorem berggren_C_preserves_form :
    let C : Matrix (Fin 3) (Fin 3) ℤ := !![-1, 2, 2; -2, 1, 2; -2, 2, 3]
    C.transpose * pythag_form * C = pythag_form := by native_decide


/-- [Section: # CatalogBuild.Speculative.Other.CrystallizerFrontier
Auto-generated from theorem catalog database.
Domain: Speculative/Other
Declarations: 33] -/
theorem periodic_loss_max_at_half_int (n : ℤ) :
    sin (π * (n + 1/2)) ^ 2 = 1 := by
  norm_num [ mul_add, mul_div, Real.sin_add ];
  exact eq_or_eq_neg_of_sq_eq_sq _ _ <| by norm_num [ mul_comm Real.pi, Real.cos_sq' ] ;


theorem periodic_loss_deriv :
    HasDerivAt (fun m : ℝ => sin (π * m) ^ 2) (π * sin (2 * π * m)) m := by
  -- Apply the chain rule to find the derivative: g'(m) = 2sin(πm)cos(πm) * π.
  have h_chain : HasDerivAt (fun m => (Real.sin (Real.pi * m))^2) (2 * Real.sin (Real.pi * m) * Real.cos (Real.pi * m) * Real.pi) m := by
    have h_sin : HasDerivAt (fun m => Real.sin (Real.pi * m)) (Real.pi * Real.cos (Real.pi * m)) m := by
      simpa [ mul_comm ] using HasDerivAt.sin ( HasDerivAt.const_mul Real.pi ( hasDerivAt_id m ) )
    convert h_sin.pow 2 using 1 ; ring;
  convert h_chain using 1 ; rw [ mul_assoc, Real.sin_two_mul ] ; ring


theorem periodic_loss_grad_zero_half_int (n : ℤ) :
    sin (2 * π * (↑n + 1/2)) = 0 := by
  exact Real.sin_eq_zero_iff.mpr ⟨ 2 * n + 1, by push_cast; ring ⟩


theorem rotation_orthogonal (θ : ℝ) :
    let R : Matrix (Fin 2) (Fin 2) ℝ := !![cos θ, -sin θ; sin θ, cos θ]
    R.transpose * R = 1 := by
  ext i j ; fin_cases i <;> fin_cases j <;> norm_num [ Matrix.mul_apply, Matrix.transpose_apply ] <;> nlinarith [ Real.sin_sq_add_cos_sq θ ]


theorem rotation_inverse (θ : ℝ) :
    let R : Matrix (Fin 2) (Fin 2) ℝ := !![cos θ, -sin θ; sin θ, cos θ]
    let Rinv : Matrix (Fin 2) (Fin 2) ℝ := !![cos (-θ), -sin (-θ); sin (-θ), cos (-θ)]
    R * Rinv = 1 := by
  ext i j; fin_cases i <;> fin_cases j <;> norm_num [ Matrix.mul_apply, Fin.sum_univ_succ ] <;> ring_nf <;> norm_num [ Real.sin_sq, Real.cos_sq ] ;


theorem stereo_approx_sin (θ : ℝ) (ε : ℝ) (hε : ε > 0) :
    ∃ p q : ℤ, q > 0 ∧ |sin θ - 2 * ↑p * ↑q / (↑p ^ 2 + ↑q ^ 2)| < ε := by
  by_cases h : Real.sin θ = 0 ∨ Real.sin θ = 1 ∨ Real.sin θ = -1;
  · rcases h with ( h | h | h );
    · exact ⟨ 0, 1, by norm_num, by simpa [ h ] using hε ⟩;
    · exact ⟨ 1, 1, by norm_num, by norm_num [ h ] ; linarith ⟩;
    · exact ⟨ -1, 1, by norm_num, by norm_num [ h ] ; linarith ⟩;
  · -- By the density of rationals in reals, there exists a rational number $x$ such that $|\sin \theta - \frac{2x}{1 + x^2}| < \epsilon$.
    obtain ⟨x, hx⟩ : ∃ x : ℚ, |Real.sin θ - 2 * x / (1 + x ^ 2)| < ε := by
      -- By the properties of the intermediate value theorem, since $f(x) = \frac{2x}{1+x^2}$ is continuous and $f(\mathbb{R}) = [-1, 1]$, there exists $x \in \mathbb{R}$ such that $f(x) = \sin \theta$.
      obtain ⟨x, hx⟩ : ∃ x : ℝ, 2 * x / (1 + x ^ 2) = Real.sin θ := by
        -- We can solve the equation $2x = \sin \theta (1 + x^2)$ for $x$ using the quadratic formula.
        use (1 + Real.sqrt (1 - Real.sin θ ^ 2)) / Real.sin θ;
        field_simp;
        rw [ div_eq_iff ( by tauto ) ] ; nlinarith [ Real.mul_self_sqrt ( show 0 ≤ 1 - Real.sin θ ^ 2 by nlinarith [ Real.sin_sq_le_one θ ] ), Real.sqrt_nonneg ( 1 - Real.sin θ ^ 2 ), mul_div_cancel₀ ( ( 1 + Real.sqrt ( 1 - Real.sin θ ^ 2 ) ) ^ 2 ) ( show Real.sin θ ^ 2 ≠ 0 by aesop ) ];
      -- By the properties of the intermediate value theorem, since $f(x) = \frac{2x}{1+x^2}$ is continuous and $f(\mathbb{R}) = [-1, 1]$, there exists $x \in \mathbb{R}$ such that $f(x) = \sin \theta$. Use this fact.
      have h_cont : ContinuousAt (fun x : ℝ => 2 * x / (1 + x ^ 2)) x := by
        exact ContinuousAt.div ( continuousAt_const.mul continuousAt_id ) ( continuousAt_const.add ( continuousAt_id.pow 2 ) ) ( by positivity );
      have := Metric.continuousAt_iff.mp h_cont ε hε;
      rcases this with ⟨ δ, δ_pos, H ⟩ ; rcases exists_rat_btwn ( show x - δ < x by linarith ) with ⟨ q, hq₁, hq₂ ⟩ ; exact ⟨ q, by rw [ abs_sub_comm ] ; exact H ( abs_lt.mpr ⟨ by linarith, by linarith ⟩ ) |> fun h => by simpa [ hx ] using h ⟩ ;
    -- Let $p$ and $q$ be the numerator and denominator of $x$, respectively.
    obtain ⟨p, q, hq_pos, hx_eq⟩ : ∃ p q : ℤ, q > 0 ∧ x = p / q := by
      exact ⟨ x.num, x.den, Nat.cast_pos.mpr x.pos, x.num_div_den.symm ⟩;
    use p, q;
    simp_all +decide [ abs_div, abs_mul, abs_of_pos ];
    grind


theorem gram_schmidt_idempotent (u : Fin 2 → ℝ) (v : Fin 2 → ℝ)
    (hu : ∑ i : Fin 2, u i ^ 2 = 1) :
    let proj := fun w : Fin 2 → ℝ => fun i => w i - (∑ j, u j * w j) * u i
    proj (proj v) = proj v := by
  -- Let's simplify the expression for the projection.
  ext i
  simp [hu];
  exact Or.inl ( by rw [ Fin.sum_univ_two ] at hu; linear_combination' hu * - ( u 0 * v 0 + u 1 * v 1 ) )


/-- The Berggren A-matrix has trace 3 (= 1 + (-1) + 3). -/
theorem berggren_A_trace :
    let A : Matrix (Fin 3) (Fin 3) ℤ := !![1, -2, 2; 2, -1, 2; 2, -2, 3]
    A.trace = 3 := by native_decide


/-- The Berggren B-matrix has trace 5 (= 1 + 1 + 3). -/
theorem berggren_B_trace :
    let B : Matrix (Fin 3) (Fin 3) ℤ := !![1, 2, 2; 2, 1, 2; 2, 2, 3]
    B.trace = 5 := by native_decide


/-- The Berggren C-matrix has trace 3 (= -1 + 1 + 3). -/
theorem berggren_C_trace :
    let C : Matrix (Fin 3) (Fin 3) ℤ := !![-1, 2, 2; -2, 1, 2; -2, 2, 3]
    C.trace = 3 := by native_decide


/-- The product A·B of Berggren matrices has determinant -1.
This follows from det(A)·det(B) = 1·(-1) = -1. -/
theorem berggren_AB_det :
    let A : Matrix (Fin 3) (Fin 3) ℤ := !![1, -2, 2; 2, -1, 2; 2, -2, 3]
    let B : Matrix (Fin 3) (Fin 3) ℤ := !![1, 2, 2; 2, 1, 2; 2, 2, 3]
    (A * B).det = -1 := by native_decide


/-- The product A·C of Berggren matrices has determinant 1 (both in SL₃(ℤ)). -/
theorem berggren_AC_det :
    let A : Matrix (Fin 3) (Fin 3) ℤ := !![1, -2, 2; 2, -1, 2; 2, -2, 3]
    let C : Matrix (Fin 3) (Fin 3) ℤ := !![-1, 2, 2; -2, 1, 2; -2, 2, 3]
    (A * C).det = 1 := by native_decide


theorem cos_double_angle (θ : ℝ) : cos (2 * θ) = 2 * cos θ ^ 2 - 1 := by
  exact Real.cos_two_mul θ


theorem sin_double_angle (θ : ℝ) : sin (2 * θ) = 2 * sin θ * cos θ := by
  exact Real.sin_two_mul θ


theorem cos_triple_angle (θ : ℝ) : cos (3 * θ) = 4 * cos θ ^ 3 - 3 * cos θ := by
  exact Real.cos_three_mul θ


theorem chebyshev_recurrence_3 (θ : ℝ) :
    cos (3 * θ) = 2 * cos θ * cos (2 * θ) - cos θ := by
  rw [ Real.cos_three_mul, Real.cos_two_mul ] ; ring;


theorem stereo_int_rational (m : ℤ) :
    ∃ p q : ℤ, q > 0 ∧ (2 * ↑m : ℚ) / (1 + ↑m ^ 2) = ↑p / ↑q := by
  exact ⟨ 2 * m, 1 + m ^ 2, by positivity, by push_cast; ring ⟩


/-- The sum of two crystallized (integer-valued) periodic losses is still non-negative.
A basic but important monotonicity property for the total loss. -/
theorem sum_periodic_loss_nonneg (a b : ℝ) :
    sin (π * a) ^ 2 + sin (π * b) ^ 2 ≥ 0 := by
  have := sq_nonneg (sin (π * a))
  have := sq_nonneg (sin (π * b))
  linarith


theorem total_periodic_loss_zero_iff (a b c : ℝ) :
    sin (π * a) ^ 2 + sin (π * b) ^ 2 + sin (π * c) ^ 2 = 0 ↔
    (∃ n : ℤ, a = n) ∧ (∃ n : ℤ, b = n) ∧ (∃ n : ℤ, c = n) := by
  constructor <;> intro h;
  · -- Since each term is non-negative and their sum is zero, each term must individually be zero.
    have h_sin_zero : Real.sin (Real.pi * a) = 0 ∧ Real.sin (Real.pi * b) = 0 ∧ Real.sin (Real.pi * c) = 0 := by
      exact ⟨ by contrapose! h; positivity, by contrapose! h; positivity, by contrapose! h; positivity ⟩;
    exact ⟨ by obtain ⟨ n, hn ⟩ := Real.sin_eq_zero_iff.mp h_sin_zero.1; exact ⟨ n, by nlinarith [ Real.pi_pos ] ⟩, by obtain ⟨ n, hn ⟩ := Real.sin_eq_zero_iff.mp h_sin_zero.2.1; exact ⟨ n, by nlinarith [ Real.pi_pos ] ⟩, by obtain ⟨ n, hn ⟩ := Real.sin_eq_zero_iff.mp h_sin_zero.2.2; exact ⟨ n, by nlinarith [ Real.pi_pos ] ⟩ ⟩;
  · rcases h with ⟨ ⟨ n, rfl ⟩, ⟨ m, rfl ⟩, ⟨ k, rfl ⟩ ⟩ ; norm_num [ mul_comm Real.pi ] ;


/-- Applying Berggren A to (3,4,5) produces (5,12,13), a Pythagorean triple. -/
theorem berggren_A_applies :
    let A : Matrix (Fin 3) (Fin 3) ℤ := !![1, -2, 2; 2, -1, 2; 2, -2, 3]
    let v : Fin 3 → ℤ := ![3, 4, 5]
    A.mulVec v = ![5, 12, 13] := by native_decide


/-- Applying Berggren B to (3,4,5) produces (21,20,29), a Pythagorean triple. -/
theorem berggren_B_applies :
    let B : Matrix (Fin 3) (Fin 3) ℤ := !![1, 2, 2; 2, 1, 2; 2, 2, 3]
    let v : Fin 3 → ℤ := ![3, 4, 5]
    B.mulVec v = ![21, 20, 29] := by native_decide


/-- (21,20,29) is indeed a Pythagorean triple. -/
theorem triple_21_20_29 : (21 : ℤ) ^ 2 + 20 ^ 2 = 29 ^ 2 := by norm_num


/-- Applying Berggren C to (3,4,5) produces (15,8,17), a Pythagorean triple. -/
theorem berggren_C_applies :
    let C : Matrix (Fin 3) (Fin 3) ℤ := !![-1, 2, 2; -2, 1, 2; -2, 2, 3]
    let v : Fin 3 → ℤ := ![3, 4, 5]
    C.mulVec v = ![15, 8, 17] := by native_decide


/-- (15,8,17) is indeed a Pythagorean triple. -/
theorem triple_15_8_17 : (15 : ℤ) ^ 2 + 8 ^ 2 = 17 ^ 2 := by norm_num


theorem periodic_loss_integer_shift (m : ℝ) (n : ℤ) :
    sin (π * (m + ↑n)) ^ 2 = sin (π * m) ^ 2 := by
  rw [ mul_add, Real.sin_add ] ; norm_num [ mul_comm Real.pi ];
  norm_num [ mul_pow, Real.cos_sq' ]


theorem periodic_loss_reflection (t : ℝ) (n : ℤ) :
    sin (π * (↑n + t)) ^ 2 = sin (π * (↑n - t)) ^ 2 := by
  norm_num [ mul_add, mul_sub, Real.sin_add, Real.sin_sub ];
  norm_num [ mul_comm Real.pi ]


end
