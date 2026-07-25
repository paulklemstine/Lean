import Mathlib

/-!
# No exponential-polynomial solves Airy's equation

This file proves that no function of the form `f = q · exp(p)`, with `q, p`
real polynomials and `q ≠ 0`, can satisfy Airy's equation `f'' = x · f`.

The heart of the argument is the *Airy coefficient* polynomial

  `airyCoeff q p = q'' + 2·q'·p' + q·p'' + q·(p')²`,

which is the polynomial such that `(q · exp p)'' = (airyCoeff q p) · exp p`.

## Main results

* `airyCoeff` — the polynomial coefficient of `exp p` in `(q·exp p)''`.
* `airyCoeff_ne_X_mul` — for `q ≠ 0`, `airyCoeff q p ≠ X · q`
  (a pure degree-mismatch fact).
* `second_deriv_poly_mul_exp` — the analytic connection
  `(q·exp p)'' = (airyCoeff q p)·exp p`.
* `no_exp_poly_solves_airy` — no `q·exp p` with `q ≠ 0` satisfies `f'' = x·f`.
-/

open Polynomial

namespace AiryExpPolyObstruction

/-! ### The Airy coefficient polynomial -/

/-- The Airy coefficient `q'' + 2·q'·p' + q·p'' + q·(p')²`.  It is the
polynomial satisfying `(q · exp p)'' = (airyCoeff q p) · exp p`. -/
noncomputable def airyCoeff (q p : Polynomial ℝ) : Polynomial ℝ :=
  derivative (derivative q)
    + 2 * (derivative q) * (derivative p)
    + q * derivative (derivative p)
    + q * (derivative p) ^ 2

/-- Algebraic identity underlying the analytic second-derivative computation:
applying the "first-order operator" `g ↦ g' + g·p'` twice to `q` produces
`airyCoeff q p`. -/
theorem airyCoeff_eq (q p : Polynomial ℝ) :
    derivative (derivative q + q * derivative p)
      + (derivative q + q * derivative p) * derivative p = airyCoeff q p := by
  unfold airyCoeff; simp +decide [ Polynomial.derivative_add, Polynomial.derivative_mul ] ; ring;

/-! ### Degree analysis: `airyCoeff q p ≠ X · q` -/

/-- When `q ≠ 0` and `p' ≠ 0`, the Airy coefficient has degree exactly
`deg q + 2·deg p'`, since the term `q·(p')²` strictly dominates the others. -/
theorem degree_airyCoeff_eq (q p : Polynomial ℝ) (hq : q ≠ 0)
    (hp : derivative p ≠ 0) :
    (airyCoeff q p).degree = q.degree + 2 * (derivative p).degree := by
  by_cases h : Polynomial.natDegree ( derivative p ) = 0 <;> simp_all +decide [ Polynomial.degree_eq_natDegree hq, Polynomial.degree_eq_natDegree hp ];
  · -- Since the degree of the derivative of $p$ is zero, $p$ must be a constant polynomial.
    obtain ⟨c, hc⟩ : ∃ c : ℝ, derivative p = Polynomial.C c := by
      exact ⟨ _, Polynomial.eq_C_of_natDegree_eq_zero h ⟩;
    unfold airyCoeff; simp_all +decide;
    rw [ Polynomial.degree_add_eq_right_of_degree_lt ] <;> norm_num [ Polynomial.degree_add_eq_left_of_degree_lt, Polynomial.degree_add_eq_right_of_degree_lt, Polynomial.degree_C, hp ];
    · exact Polynomial.degree_eq_natDegree hq;
    · refine' lt_of_le_of_lt ( Polynomial.degree_add_le _ _ ) _ ; norm_num [ hp ];
      erw [ Polynomial.degree_C ] <;> norm_num;
      exact ⟨ lt_of_le_of_lt ( Polynomial.degree_derivative_le ) ( Polynomial.degree_derivative_lt <| by aesop ), Polynomial.degree_derivative_lt <| by aesop ⟩;
  · rw [ show airyCoeff q p = q * ( derivative p ) ^ 2 + ( derivative ( derivative q ) + 2 * derivative q * derivative p + q * derivative ( derivative p ) ) by rw [ add_comm ] ; unfold airyCoeff ; ring, Polynomial.degree_add_eq_left_of_degree_lt ] <;> norm_num [ Polynomial.degree_eq_natDegree hq, Polynomial.degree_eq_natDegree hp ];
    refine' lt_of_le_of_lt ( Polynomial.degree_add_le _ _ ) ( max_lt ( lt_of_le_of_lt ( Polynomial.degree_add_le _ _ ) _ ) _ ) <;> norm_num [ Polynomial.degree_eq_natDegree hp ];
    · constructor;
      · refine' lt_of_le_of_lt ( Polynomial.degree_derivative_le ) _;
        refine' lt_of_le_of_lt ( Polynomial.degree_derivative_le ) _;
        exact lt_of_le_of_lt ( Polynomial.degree_le_natDegree ) ( WithBot.coe_lt_coe.mpr ( by linarith [ Nat.pos_of_ne_zero h ] ) );
      · erw [ Polynomial.degree_C ] <;> norm_num;
        refine' lt_of_le_of_lt ( add_le_add ( Polynomial.degree_derivative_le ) le_rfl ) _;
        rw [ Polynomial.degree_eq_natDegree hq ] ; norm_cast ; linarith [ Nat.pos_of_ne_zero h ];
    · refine' lt_of_le_of_lt ( add_le_add ( Polynomial.degree_le_natDegree ) ( Polynomial.degree_le_natDegree ) ) _ ; norm_cast ; simp +arith +decide [ * ];
      exact lt_of_le_of_lt ( Polynomial.natDegree_derivative_le .. ) ( by omega )

/-- **Core obstruction (degree mismatch).** For any nonzero `q` and any `p`,
the Airy coefficient is never equal to `X · q`. -/
theorem airyCoeff_ne_X_mul (q p : Polynomial ℝ) (hq : q ≠ 0) :
    airyCoeff q p ≠ X * q := by
  by_cases hp : Polynomial.derivative p = 0;
  · simp_all +decide [ AiryExpPolyObstruction.airyCoeff ];
    intro h;
    replace h := congr_arg Polynomial.natDegree h ; simp_all +decide [ Polynomial.natDegree_mul' ];
    exact absurd h ( by linarith [ Polynomial.natDegree_derivative_le q, Polynomial.natDegree_derivative_le ( derivative q ), Nat.sub_le ( Polynomial.natDegree q ) 1, Nat.sub_le ( Polynomial.natDegree ( derivative q ) ) 1 ] );
  · have := degree_airyCoeff_eq q p hq hp;
    intro h; simp_all +decide [ Polynomial.degree_eq_natDegree hq ] ;
    rw [ Polynomial.degree_eq_natDegree hp ] at this ; norm_cast at this ; omega

/-! ### Analytic connection -/

/-- For any polynomials `p, g`, the function `x ↦ g(x)·exp(p(x))` has derivative
`(g' + g·p')(x)·exp(p(x))`. -/
theorem hasDerivAt_poly_mul_exp (p g : Polynomial ℝ) (x : ℝ) :
    HasDerivAt (fun y => eval y g * Real.exp (eval y p))
      (eval x (derivative g + g * derivative p) * Real.exp (eval x p)) x := by
  convert HasDerivAt.mul ( Polynomial.hasDerivAt _ _ ) ( HasDerivAt.exp ( Polynomial.hasDerivAt _ _ ) ) using 1 ; norm_num ; ring

/-- **Analytic connection.** The second derivative of `q·exp p` is
`(airyCoeff q p)·exp p`. -/
theorem second_deriv_poly_mul_exp (q p : Polynomial ℝ) (x : ℝ) :
    deriv (deriv (fun y => eval y q * Real.exp (eval y p))) x
      = eval x (airyCoeff q p) * Real.exp (eval x p) := by
  rw [ ←airyCoeff_eq, show deriv ( fun y => eval y q * Real.exp ( eval y p ) ) = fun y => eval y ( derivative q + q * derivative p ) * Real.exp ( eval y p ) from funext fun y => ?_ ];
  · convert HasDerivAt.deriv ( hasDerivAt_poly_mul_exp p ( derivative q + q * derivative p ) x ) using 1;
  · convert HasDerivAt.deriv ( hasDerivAt_poly_mul_exp p q y ) using 1

/-! ### Conclusion -/

/-- **No exponential-polynomial solves Airy's equation.** If `q ≠ 0`, the
function `f = q·exp p` cannot satisfy `f'' = x·f`. -/
theorem no_exp_poly_solves_airy (q p : Polynomial ℝ) (hq : q ≠ 0)
    (hsol : ∀ x : ℝ,
      deriv (deriv (fun y => eval y q * Real.exp (eval y p))) x
        = x * (eval x q * Real.exp (eval x p))) : False := by
  convert airyCoeff_ne_X_mul q p hq ?_;
  refine' Polynomial.funext fun x => _;
  convert congr_arg ( fun y => y / Real.exp ( eval x p ) ) ( hsol x ) using 1 <;> norm_num [ Real.exp_ne_zero, mul_div_assoc ];
  rw [ second_deriv_poly_mul_exp, mul_div_cancel_right₀ _ ( ne_of_gt ( Real.exp_pos _ ) ) ]

end AiryExpPolyObstruction