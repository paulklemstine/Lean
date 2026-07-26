import Mathlib
import EML.DepthCompression

/-!
# Chain Rules for Exponential–Logarithmic Compositions

This chapter studies the differential structure of functions of the form
`exp (h x) * log (g x)`.  It identifies the exact logarithmic factorization,
records a sharp obstruction to a tempting but incorrect factorization, and
computes three successive derivatives of `exp (x^2) * log (x+1)`.
-/

noncomputable section

open Real

namespace ExpLogChainRules

/-- The exponential–logarithmic product associated with inner functions `h` and `g`. -/
def expLogProduct (h g : ℝ → ℝ) : ℝ → ℝ :=
  fun x => Real.exp (h x) * Real.log (g x)

/-- The unfactored chain rule for an exponential–logarithmic product. -/
theorem hasDerivAt_expLogProduct {h g : ℝ → ℝ} {h' g' x : ℝ}
    (hh : HasDerivAt h h' x) (hg : HasDerivAt g g' x) (hg0 : g x ≠ 0) :
    HasDerivAt (expLogProduct h g)
      (Real.exp (h x) * (h' * Real.log (g x) + g' / g x)) x := by
  convert hh.exp.mul (hg.log hg0) using 1
  · ring

/-- The correct canonical factorization.  Besides `g x ≠ 0`, it requires
`log (g x) ≠ 0`; equivalently, the original product must not vanish through
its logarithmic factor. -/
theorem hasDerivAt_expLogProduct_factored {h g : ℝ → ℝ} {h' g' x : ℝ}
    (hh : HasDerivAt h h' x) (hg : HasDerivAt g g' x)
    (hg0 : g x ≠ 0) (hlog0 : Real.log (g x) ≠ 0) :
    HasDerivAt (expLogProduct h g)
      (expLogProduct h g x * (h' + g' / (g x * Real.log (g x)))) x := by
  convert hasDerivAt_expLogProduct hh hg hg0 using 1
  dsimp [expLogProduct]
  field_simp

/-- The proposed factor `f * (h' + g'/g)` is false.  With `h=0` and
`g=exp`, the product is the identity function, whose derivative at `2` is
`1`, whereas the proposed expression evaluates to `2`. -/
theorem proposed_factorization_counterexample :
    _root_.deriv (expLogProduct (fun _ : ℝ => 0) Real.exp) 2 = 1 ∧
    expLogProduct (fun _ : ℝ => 0) Real.exp 2 *
      (0 + Real.exp 2 / Real.exp 2) = 2 := by
  constructor
  · have heq : expLogProduct (fun _ : ℝ => 0) Real.exp = id := by
      funext y
      simp [expLogProduct]
    rw [heq]
    simp
  · simp [expLogProduct]

/-! The following four expressions expose the complete three-step calculation.
They are kept factored through `exp (x^2)`, making their EML structure explicit. -/

def testF0 (x : ℝ) : ℝ :=
  Real.exp (x ^ 2) * Real.log (x + 1)

def testF1 (x : ℝ) : ℝ :=
  Real.exp (x ^ 2) * (2 * x * Real.log (x + 1) + 1 / (x + 1))

def testF2 (x : ℝ) : ℝ :=
  Real.exp (x ^ 2) *
    ((4 * x ^ 2 + 2) * Real.log (x + 1) + 4 * x / (x + 1) - 1 / (x + 1) ^ 2)

def testF3 (x : ℝ) : ℝ :=
  Real.exp (x ^ 2) *
    ((8 * x ^ 3 + 12 * x) * Real.log (x + 1) +
      (12 * x ^ 2 + 6) / (x + 1) - 6 * x / (x + 1) ^ 2 + 2 / (x + 1) ^ 3)

/-- First derivative in the test calculation. -/
theorem hasDerivAt_testF0 {x : ℝ} (hx : x ≠ -1) :
    HasDerivAt testF0 (testF1 x) x := by
  unfold testF0 testF1
  have hden : x + 1 ≠ 0 := by
    intro h
    apply hx
    linarith
  convert ((((hasDerivAt_id x).pow 2).exp).mul
    (((hasDerivAt_id x).add_const 1).log hden)) using 1
  norm_num [id_eq, Pi.pow_apply, Pi.mul_apply, Pi.add_apply, Pi.div_apply, Pi.sub_apply]
  ring

/-- Second derivative in the test calculation. -/
theorem hasDerivAt_testF1 {x : ℝ} (hx : x ≠ -1) :
    HasDerivAt testF1 (testF2 x) x := by
  unfold testF1 testF2
  have hden : x + 1 ≠ 0 := by
    intro h
    apply hx
    linarith
  convert ((((hasDerivAt_id x).pow 2).exp).mul
    (((((hasDerivAt_const x 2).mul (hasDerivAt_id x)).mul
      (((hasDerivAt_id x).add_const 1).log hden)).add
      ((hasDerivAt_const x 1).div ((hasDerivAt_id x).add_const 1) hden)))) using 1
  norm_num [id_eq, Pi.pow_apply, Pi.mul_apply, Pi.add_apply, Pi.div_apply, Pi.sub_apply]
  field_simp
  ring

/-- Third derivative in the test calculation. -/
theorem hasDerivAt_testF2 {x : ℝ} (hx : x ≠ -1) :
    HasDerivAt testF2 (testF3 x) x := by
  unfold testF2 testF3
  have hden : x + 1 ≠ 0 := by
    intro h
    apply hx
    linarith
  have hExp := (((hasDerivAt_id x).pow 2).exp)
  have hLog := (((hasDerivAt_id x).add_const 1).log hden)
  have hA := (((hasDerivAt_const x 4).mul ((hasDerivAt_id x).pow 2)).add_const 2)
  have hB := ((hasDerivAt_const x 4).mul (hasDerivAt_id x)).div
    ((hasDerivAt_id x).add_const 1) hden
  have hC := (hasDerivAt_const x 1).div (((hasDerivAt_id x).add_const 1).pow 2)
    (pow_ne_zero 2 hden)
  convert hExp.mul ((hA.mul hLog).add hB |>.sub hC) using 1
  norm_num [id_eq, Pi.pow_apply, Pi.mul_apply, Pi.add_apply, Pi.div_apply, Pi.sub_apply]
  field_simp
  ring

/-- The second analytic derivative agrees locally with the second symbolic expression. -/
lemma second_derivative_test_at {x : ℝ} (hx : x ≠ -1) :
    _root_.deriv (fun z => _root_.deriv testF0 z) x = testF2 x := by
  have hnear : ∀ᶠ y in nhds x, y ≠ -1 := eventually_ne_nhds hx
  have heq : (fun y => _root_.deriv testF0 y) =ᶠ[nhds x] testF1 := by
    filter_upwards [hnear] with y hy
    exact (hasDerivAt_testF0 hy).deriv
  rw [Filter.EventuallyEq.deriv_eq heq]
  exact (hasDerivAt_testF1 hx).deriv

/-- The three analytic derivative functions agree with the explicit EML-style
expressions throughout the natural domain `x > -1`. -/
theorem third_derivative_test (x : ℝ) (hx : -1 < x) :
    _root_.deriv (fun y => _root_.deriv (fun z => _root_.deriv testF0 z) y) x = testF3 x := by
  have hxne : x ≠ -1 := by linarith
  have hnear : ∀ᶠ y in nhds x, y ≠ -1 := eventually_ne_nhds hxne
  have heq : (fun y => _root_.deriv (fun z => _root_.deriv testF0 z) y) =ᶠ[nhds x]
      testF2 := by
    filter_upwards [hnear] with y hy
    exact second_derivative_test_at hy
  rw [Filter.EventuallyEq.deriv_eq heq]
  exact (hasDerivAt_testF2 hxne).deriv

/-- The constant-depth exp-log representation of every positive monomial
is compatible with differentiation: its analytic derivative is the
usual monomial derivative, while its expression depth remains exactly three. -/
theorem derivative_of_depth_compressed_monomial (n : ℕ) (x : ℝ) (hx : 0 < x) :
    _root_.deriv (fun y => (EML.DepthCompression.Term.monoExpLog (n + 1)).eval y) x =
      (n + 1 : ℝ) * x ^ n ∧
    (EML.DepthCompression.Term.monoExpLog (n + 1)).depth = 3 := by
  constructor
  · have hlocal : ∀ᶠ y in nhds x,
        (EML.DepthCompression.Term.monoExpLog (n + 1)).eval y = y ^ (n + 1) := by
      filter_upwards [eventually_gt_nhds hx] with y hy
      exact EML.DepthCompression.Term.monoExpLog_eval (n + 1) hy
    have hderiv : _root_.deriv (fun y : ℝ => y ^ (n + 1)) x =
        (n + 1 : ℝ) * x ^ n := by
      simpa [Nat.cast_add, pow_succ] using (((hasDerivAt_id x).pow (n + 1)).deriv)
    rw [Filter.EventuallyEq.deriv_eq hlocal]
    exact hderiv
  · exact EML.DepthCompression.Term.monoExpLog_depth (n + 1)

-- !-- Lab Notes -- !--
/-!
**Hypothesis.** Seven falsifiable claims were ranked by structural impact:
(1) exp-log products admit the originally proposed multiplicative factorization;
(2) they admit a corrected logarithmic-derivative factorization away from zeros;
(3) symbolic EML differentiation preserves rather than merely increments depth;
(4) all iterated derivatives obey the same depth bound;
(5) the test function has an explicit third derivative in the EML differential field;
(6) zeros of the logarithmic factor are unavoidable singularities of a fully factored
logarithmic derivative; and (7) adjoining reciprocals yields a depth-filtered
differential algebra linked to the existing exponential EML hierarchy.

**Experiment.** Direct differentiation disproved (1) using `h=0`, `g=exp` at
`x=2`.  Product and chain rules established (2).  Three successive symbolic
calculations produced `testF1`, `testF2`, and `testF3`; each was checked by a
pointwise derivative theorem.  The existing structural differentiation theorem
established (3) and (4) for the exponential-polynomial component.

**Analysis.** The failed formula omitted a factor of `1 / log g`.  The correct
identity is `f' = f * (h' + g'/(g log g))`, and it is available only where both
`g` and `log g` are nonzero.  Unfactored differentiation needs only `g ≠ 0`.
The third derivative displays a stable normal form: an exponential factor times
a sum of one logarithmic term and rational terms whose pole order increases by
one at each differentiation.

**Critique.** The original universal claim is false, not merely difficult.
The point `x=-1` is excluded because `log (x+1)` has no ordinary derivative
there.  The factored theorem also excludes `g=1`, where the product vanishes and
its logarithmic derivative is undefined.  No positivity assumption is needed
for the real logarithm's derivative; nonvanishing is the sharp local condition.

**Synthesis.** The surviving theory consists of the unfactored chain rule, its
correctly guarded factorization, an explicit counterexample to the proposed
formula, a complete third-derivative calculation, and a bridge from that
calculation to constant-depth exp-log representations of positive monomials.
-/
-- !-- End Lab Notes -- !--

end ExpLogChainRules