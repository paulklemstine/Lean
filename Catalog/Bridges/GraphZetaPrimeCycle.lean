import Mathlib

/-!
# Graph-zeta local factors and Lucas recurrences

This file gives a precise bridge between spectral graph theory and elementary number theory.
For a quadratic Ihara local factor `1 - λu + qu²`, its reciprocal roots `α, β` generate the
power-sum sequence `αⁿ + βⁿ`.  The sequence is a Lucas sequence, and a finite explicit formula
shows that these spectral power sums are exactly the coefficients of the logarithmic derivative
of the local factor, up to an explicit boundary term.
-/

namespace GraphZetaPrimeCycle

/-- The quadratic factor contributed by an adjacency eigenvalue `l`. -/
def localFactor (l q u : ℂ) : ℂ := 1 - l * u + q * u ^ 2

/-- Power sums of the two reciprocal roots. -/
def spectralPowerSum (α β : ℂ) (n : ℕ) : ℂ := α ^ n + β ^ n

/-
Reciprocal-root factorization of an Ihara local factor.
-/
theorem localFactor_factor (l q u α β : ℂ) (hs : α + β = l) (hp : α * β = q) :
    localFactor l q u = (1 - α * u) * (1 - β * u) := by
  grind +locals

/-
The spectral power sums obey the Lucas recurrence with parameters `(l,q)`.
-/
theorem spectralPowerSum_recurrence (l q α β : ℂ) (hs : α + β = l)
    (hp : α * β = q) (n : ℕ) :
    spectralPowerSum α β (n + 2) =
      l * spectralPowerSum α β (n + 1) - q * spectralPowerSum α β n := by
  unfold spectralPowerSum; rw [ ← hs, ← hp ] ; ring;

/-
Initial value at zero.
-/
theorem spectralPowerSum_zero (α β : ℂ) : spectralPowerSum α β 0 = 2 := by
  unfold spectralPowerSum; norm_num;

/-
Initial value at one identifies the adjacency eigenvalue.
-/
theorem spectralPowerSum_one (l α β : ℂ) (hs : α + β = l) :
    spectralPowerSum α β 1 = l := by
  exact hs ▸ by unfold spectralPowerSum; ring;

/-
The local graph Riemann hypothesis: the Ramanujan eigenvalue bound forces every zero of the
quadratic Ihara factor onto the critical circle of radius `1 / √q`.
-/
theorem ramanujan_critical_circle (l q : ℝ) (hq : 0 < q) (hl : l ^ 2 ≤ 4 * q)
    (z : ℂ) (hz : localFactor (l : ℂ) (q : ℂ) z = 0) :
    ‖z‖ = 1 / Real.sqrt q := by
  -- By definition of $localFactor$, we have $1 - l * z + q * z^2 = 0$.
  have h_eq : 1 - l * z + q * z^2 = 0 := by
    exact hz;
  -- Consider two cases: $z.im = 0$ and $z.im \neq 0$.
  by_cases h_im : z.im = 0;
  · simp_all +decide [ Complex.ext_iff, sq ];
    rw [ ← sq_eq_sq₀ ] <;> norm_num [ Complex.normSq, Complex.norm_def, h_im ];
    rw [ Real.sq_sqrt ( mul_self_nonneg _ ), Real.sq_sqrt hq.le, inv_eq_of_mul_eq_one_right ] ; nlinarith [ sq_nonneg ( l - 2 * q * z.re ) ];
  · simp_all +decide [ Complex.ext_iff, sq ];
    rw [ ← sq_eq_sq₀ ] <;> norm_num [ Complex.normSq, Complex.sq_norm ];
    grind

/-
The finite graph-zeta explicit formula. Multiplication by the Ihara local factor cancels all
interior coefficients of the spectral power-sum series.  The two low-degree terms are the
analogue of the main terms in an explicit formula, while the final two terms are an exact
finite-truncation error.
-/
theorem finite_explicit_formula (l q α β u : ℂ) (hs : α + β = l)
    (hp : α * β = q) (N : ℕ) :
    localFactor l q u *
        (∑ k ∈ Finset.range (N + 1), spectralPowerSum α β (k + 1) * u ^ k) =
      l - 2 * q * u
        - spectralPowerSum α β (N + 2) * u ^ (N + 1)
        + q * spectralPowerSum α β (N + 1) * u ^ (N + 2) := by
  induction N <;> simp_all +decide [ Finset.sum_range_succ, pow_succ, localFactor, spectralPowerSum ] ; ring;
  · grind;
  · grind +ring

/-- The integer Lucas sequence with parameters `(2,2)`. -/
def exampleLucas : ℕ → ℤ
  | 0 => 2
  | 1 => 2
  | n + 2 => 2 * exampleLucas (n + 1) - 2 * exampleLucas n

/-- The first several coefficients for `(l,q)=(2,2)`, computed by the Lucas recurrence. -/
def exampleCoefficients : List ℤ := [2, 2, 0, -4, -8, -8, 0, 16]

/-- A kernel-checked small case supporting the displayed coefficient table. -/
example : (List.range 8).map exampleLucas = exampleCoefficients := by
  decide

end GraphZetaPrimeCycle