import Mathlib
import Speculative.DifferentialClosure.Defs

/-!
# Semantic Soundness of Symbolic Differentiation

The main theorem: the symbolic derivative `derivE` correctly computes real-analytic
derivatives wherever the expression is valid.

## Main results

* `EExpr.validAt_derivE` — Validity is preserved under differentiation
* `EExpr.derivE_sound` — Semantic correctness: `derivE e` represents the real derivative of `e`
-/

noncomputable section

open Real EExpr

/-
Validity of an expression at a point implies validity of its symbolic derivative.
This is essential: the derivative algorithm never introduces domain violations.
-/
theorem EExpr.validAt_derivE {e : EExpr} {x : ℝ} (hv : ValidAt e x) :
    ValidAt (derivE e) x := by
      have h_valid_deriv : ∀ e : EExpr, ∀ x : ℝ, e.ValidAt x → e.derivE.ValidAt x := by
        intro e x hv;
        induction' e with e ih generalizing x;
        all_goals simp_all +decide [ EExpr.derivE, EExpr.ValidAt ];
        · exact mul_ne_zero hv.2.2 hv.2.2;
        · linarith;
      exact h_valid_deriv e x hv

/-
**Fundamental Soundness Theorem.**
For every elementary expression `e` and every point `x` in the domain of `e`,
the symbolic derivative `derivE e` evaluates to the real derivative of `evalE e`
at `x`. This connects the syntactic differential algebra to standard real analysis.

Proof is by structural induction on `e`, applying the chain rule, product rule,
and quotient rule at each constructor.
-/
theorem EExpr.derivE_sound (e : EExpr) (x : ℝ) (hv : ValidAt e x) :
    HasDerivAt (fun y => evalE e y) (evalE (derivE e) x) x := by
      induction' e with e ih generalizing x;
      any_goals apply_rules [ HasDerivAt.add, HasDerivAt.sub, HasDerivAt.mul, HasDerivAt.div, HasDerivAt.exp, HasDerivAt.log ];
      all_goals norm_num [ EExpr.evalE, EExpr.derivE ] at *;
      exact hasDerivAt_id x;
      exact hasDerivAt_const _ _;
      exact hv.1;
      exact hv.2;
      exact hv.1;
      exact HasDerivAt.neg ( by solve_by_elim [ hv.2 ] );
      exact hv.1;
      · exact hv.2;
      · rename_i a b ha hb;
        convert HasDerivAt.div ( ha x hv.1 ) ( hb x hv.2.1 ) ( hv.2.2 ) using 1 ; ring;
      · rename_i e ih;
        convert HasDerivAt.exp ( ih x hv ) using 1 ; ring!;
      · exact hv.1;
      · exact hv.2.ne'

end