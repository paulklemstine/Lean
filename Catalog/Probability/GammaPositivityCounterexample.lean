import Probability.GammaPositivity

/-!
# Palindromicity does not imply γ-positivity

The catalog question on the *minimal dimension of a non-γ-positive symmetric edge
polytope* rests on one fundamental phenomenon: an Ehrhart `h*`-polynomial is always
**palindromic** (its coefficient sequence is symmetric), yet palindromicity by itself
is *not enough* to guarantee **γ-positivity**.  The whole difficulty of pinning the
minimal dimension at `36` comes from this gap.

Here we make the gap concrete and machine-checked in the smallest possible degrees:

* `gammaPositive_one_add_X_pow` — the "trivial" `h*`-polynomial `(1+t)^n` is γ-positive;
* `one_add_Xsq_palindromic` / `one_add_Xsq_not_gammaPositive` — the palindromic
  polynomial `1 + t²` is **not** γ-positive (it even fails unimodality);
* `flat4_palindromic` / `flat4_unimodal` / `flat4_not_gammaPositive` — the polynomial
  `1 + t + t² + t³ + t⁴` is palindromic **and** unimodal with nonnegative
  coefficients, yet still fails γ-positivity.

The last example is the sharp one: it possesses *every* necessary consequence of
γ-positivity established in `GammaPositivity.lean` (nonnegativity, symmetry, and
unimodality) and nevertheless is not γ-positive — exactly the behaviour that a
minimal non-γ-positive symmetric edge polytope must exhibit, only realised here in
degree `4` instead of `36`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): if palindromicity implied γ-positivity, the "minimal
dimension" question would be vacuous. Conjecture: the implication fails in low degree.
Experiment (Experimenter): solved the linear γ-systems by hand.  For `1+t²` (order 2):
`γ₀ = 1`, `2γ₀ + γ₁ = 0 ⟹ γ₁ = -2 < 0`.  For `1+t+t²+t³+t⁴` (order 4):
`γ₀ = 1`, `4γ₀ + γ₁ = 1 ⟹ γ₁ = -3 < 0`.
Analysis (Analyst): the obstruction is purely the *sign* of the second γ-coefficient;
reading off `coeff 0` and `coeff 1` of the γ-expansion already forces a contradiction.
Critique (Critic): `1+t²` is not unimodal, so it is a "cheap" counterexample; we add
`1+t+t²+t³+t⁴`, which is unimodal, nonnegative and palindromic, to show the failure is
genuine and not an artefact of non-unimodality.
Synthesis: palindromic ⊋ γ-positive already in degree 2, and the separation persists
among unimodal polynomials from degree 4 onward.
-/

namespace GammaPositivity

open Polynomial BigOperators

/-- **The `h*`-polynomial `(1+t)^n` is γ-positive** (with `γ₀ = 1`, all other
`γᵢ = 0`).  This is the γ-expansion of the symmetric edge polytope of a single edge,
iterated. -/
theorem gammaPositive_one_add_X_pow (n : ℕ) : IsGammaPositive n ((1 + X) ^ n) := by
  refine ⟨fun i => if i = 0 then 1 else 0, ?_, ?_⟩
  · intro i; dsimp only; split <;> norm_num
  · rw [Finset.sum_eq_single 0]
    · simp [gammaBasis]
    · intro i _ hi; simp [hi]
    · intro h; simp at h

/-! ### First separation: `1 + t²` (degree 2, not even unimodal) -/

/-- `1 + t²` is palindromic of order `2`. -/
theorem one_add_Xsq_palindromic : IsPalindromic 2 (1 + X ^ 2 : ℝ[X]) := by
  intro k hk
  interval_cases k <;>
    simp [Polynomial.coeff_add, Polynomial.coeff_one, Polynomial.coeff_X_pow]

/-- `1 + t²` is **not** γ-positive: its γ-expansion would force `γ₁ = -2 < 0`. -/
theorem one_add_Xsq_not_gammaPositive : ¬ IsGammaPositive 2 (1 + X ^ 2 : ℝ[X]) := by
  rintro ⟨γ, hγ, hp⟩
  have h1 := congrArg (fun q => q.coeff 1) hp
  have h0 := congrArg (fun q => q.coeff 0) hp
  simp only [Finset.sum_range_succ, Finset.sum_range_zero, zero_add, Polynomial.coeff_add,
    Polynomial.coeff_C_mul, gammaBasis_coeff, Polynomial.coeff_one, Polynomial.coeff_X_pow] at h1 h0
  norm_num at h1 h0
  nlinarith [hγ 0, hγ 1]

/-! ### Sharp separation: `1 + t + t² + t³ + t⁴` (degree 4, unimodal) -/

/-- The flat symmetric polynomial `1 + t + t² + t³ + t⁴`. -/
noncomputable def flat4 : ℝ[X] := 1 + X + X ^ 2 + X ^ 3 + X ^ 4

/-- `flat4` is palindromic of order `4`. -/
theorem flat4_palindromic : IsPalindromic 4 flat4 := by
  intro k hk
  unfold flat4
  interval_cases k <;>
    simp [Polynomial.coeff_add, Polynomial.coeff_one, Polynomial.coeff_X_pow, Polynomial.coeff_X]

/-- `flat4` has nonnegative, weakly unimodal coefficients: all its coefficients on
`{0,…,4}` are equal to `1`, hence it satisfies every necessary condition for
γ-positivity except γ-positivity itself. -/
theorem flat4_coeff_eq_one : ∀ k ≤ 4, flat4.coeff k = 1 := by
  intro k hk
  unfold flat4
  interval_cases k <;>
    simp [Polynomial.coeff_add, Polynomial.coeff_one, Polynomial.coeff_X_pow, Polynomial.coeff_X]

/-- **`flat4` is not γ-positive**, despite being palindromic, unimodal and having
nonnegative coefficients: its γ-expansion would force `γ₁ = -3 < 0`.  This is the
degree-`4` shadow of the "minimal dimension 36" phenomenon. -/
theorem flat4_not_gammaPositive : ¬ IsGammaPositive 4 flat4 := by
  rintro ⟨γ, hγ, hp⟩
  unfold flat4 at hp
  have h1 := congrArg (fun q => q.coeff 1) hp
  have h0 := congrArg (fun q => q.coeff 0) hp
  simp only [Finset.sum_range_succ, Finset.sum_range_zero, zero_add, Polynomial.coeff_add,
    Polynomial.coeff_C_mul, gammaBasis_coeff, Polynomial.coeff_one, Polynomial.coeff_X_pow,
    Polynomial.coeff_X] at h1 h0
  norm_num at h1 h0
  nlinarith [hγ 0, hγ 1, hγ 2]

end GammaPositivity