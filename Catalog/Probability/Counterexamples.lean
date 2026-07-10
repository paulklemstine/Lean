import Novelty.Core

/-!
# Counterexample candidates that *fail* the Jacobian hypothesis

A standard way researchers probe the Jacobian Conjecture is to write down a
plausible-looking non-triangular polynomial map and test whether its Jacobian
determinant is a nonzero constant.  If `det(JF)` is *not* constant, the map is
simply **not a candidate**: the hypothesis of the conjecture fails, and nothing
can be concluded (the map may or may not be injective).

This file makes that falsification precise for two famous "first guesses", and
verifies with zero sorries that each fails the constancy requirement.

## Main results

* `cand2_jacDet` / `cand2_jacDet_not_const` — the symmetric **degree-2** map
  `F(X₀,X₁) = (X₀+X₁², X₁+X₀²)` has `det(JF) = 1 - 4X₀X₁`, which is **not
  constant**.  Contrast with `DegreeTwo.lean`: the *triangular* degree-2 maps do
  satisfy the hypothesis, this non-triangular one does not.
* `cand3_jacDet` / `cand3_jacDet_not_const` — the symmetric **degree-3** map
  `F(X₀,X₁) = (X₀+X₁³, X₁+X₀³)` has `det(JF) = 1 - 9X₀²X₁²`, again **not
  constant**.

-- !-- Lab Notes -- !--
* Hypothesis (Hypothesizer): the "obvious" symmetric maps `X_i + X_{σ(i)}^d` are
  *not* Jacobian-Conjecture counterexamples because they already fail the
  hypothesis — their Jacobian determinant is a nonconstant polynomial.  This is
  why genuine candidates must use *cubic-linear / nilpotent* structure
  (cf. `Druzkowski.lean`), not arbitrary monomials.
* Experiment (Experimenter): computed `det(JF)` with `pderiv` and proved
  non-constancy by evaluating the determinant polynomial at two points
  (`(0,0)` and `(1,1)`) that give different values; if it were `C c` both
  evaluations would equal `c`.
* Analysis (Analyst): the off-diagonal cross terms `∂F₀/∂X₁ · ∂F₁/∂X₀`
  (`= 4X₀X₁`, resp. `9X₀²X₁²`) are exactly what break constancy.  Nilpotency of
  the linear part (Drużkowski) is the structural device that kills precisely
  these cross terms, which is why it produces honest candidates while naive
  symmetry does not.
* Critique (Critic): we are *not* claiming these maps are non-injective or that
  they refute anything — only that they fail the conjecture's hypothesis, the
  correct and verifiable statement.  This guards against the common error of
  "testing the conjecture" on maps it never applied to.
* Synthesis (PI): the trilogy is complete — triangular degree-2 (holds),
  cubic-linear degree-3 witness (holds), naive symmetric candidates (excluded by
  hypothesis).  The boundary between "candidate" and "non-candidate" is the
  constancy of `det(JF)`, computed mechanically here.
-/

open MvPolynomial

namespace JacobianConjecture.Counterexamples

/-! ## Degree-2 symmetric (non-triangular) candidate -/

/-- `F(X₀,X₁) = (X₀ + X₁², X₁ + X₀²)`. -/
noncomputable def cand2 : Fin 2 → MvPolynomial (Fin 2) ℚ
  | 0 => X 0 + (X 1) ^ 2
  | 1 => X 1 + (X 0) ^ 2

/-- Its Jacobian determinant is `1 - 4·X₀·X₁`. -/
theorem cand2_jacDet : jacDet cand2 = 1 - 4 * X 0 * X 1 := by
  unfold jacDet polyJacobian
  rw [Matrix.det_fin_two]
  simp only [Matrix.of_apply, cand2, map_add, pderiv_pow, pderiv_X, Pi.single_apply,
    Fin.reduceEq, if_true, if_false]
  ring

/-- The degree-2 candidate **fails** the Jacobian Conjecture's hypothesis: its
Jacobian determinant is not a constant polynomial. -/
theorem cand2_jacDet_not_const : ¬ ∃ c : ℚ, jacDet cand2 = C c := by
  rw [cand2_jacDet]
  rintro ⟨c, hc⟩
  have h0 := congrArg (eval ![0, 0]) hc
  have h1 := congrArg (eval ![1, 1]) hc
  simp [eval_C] at h0 h1
  rw [← h0] at h1
  norm_num at h1

/-! ## Degree-3 symmetric (non-triangular) candidate -/

/-- `F(X₀,X₁) = (X₀ + X₁³, X₁ + X₀³)`. -/
noncomputable def cand3 : Fin 2 → MvPolynomial (Fin 2) ℚ
  | 0 => X 0 + (X 1) ^ 3
  | 1 => X 1 + (X 0) ^ 3

/-- Its Jacobian determinant is `1 - 9·X₀²·X₁²`. -/
theorem cand3_jacDet : jacDet cand3 = 1 - 9 * (X 0) ^ 2 * (X 1) ^ 2 := by
  unfold jacDet polyJacobian
  rw [Matrix.det_fin_two]
  simp only [Matrix.of_apply, cand3, map_add, pderiv_pow, pderiv_X, Pi.single_apply,
    Fin.reduceEq, if_true, if_false]
  ring

/-- The degree-3 candidate **fails** the Jacobian Conjecture's hypothesis: its
Jacobian determinant is not a constant polynomial. -/
theorem cand3_jacDet_not_const : ¬ ∃ c : ℚ, jacDet cand3 = C c := by
  rw [cand3_jacDet]
  rintro ⟨c, hc⟩
  have h0 := congrArg (eval ![0, 0]) hc
  have h1 := congrArg (eval ![1, 1]) hc
  simp [eval_C] at h0 h1
  rw [← h0] at h1
  norm_num at h1

end JacobianConjecture.Counterexamples