import Mathlib
import Shared.GraphTheory.FractalTruthMetric
import MachineLearning.GoldenMeanPeriodicCensus

/-!
# The transfer matrix and the rational census series of the golden-mean subshift

Twelfth cycle of the research thread begun in `Shared.GraphTheory.FractalTruthMetric`.

Cycle 11 (`MachineLearning.GoldenMeanPeriodicCensus`) proved the exact periodic census

`#{x ∈ GoldenMean | shift^[n] x = x} = lucas n`   (for `n ≥ 1`),

against `2 ^ n` for the full shift, and deduced an obstruction to conjugacy at *every*
period.  That is an infinite family of inequalities.  This cycle compresses the whole family
into two algebraic objects.

The first is the **transfer matrix** `A = !![1,1;1,0]` of the golden-mean constraint (the
adjacency matrix of the graph on `{false, true}` with every edge except `true → true`).  We
prove the Artin–Mazur trace formula in the form

`#{x ∈ GoldenMean | shift^[n] x = x} = trace (A ^ n)`   (for `n ≥ 1`),

so the dynamical count is a spectral quantity.

The second is the **census generating series** `∑ₙ Lₙ Xⁿ ∈ ℤ⟦X⟧`.  We prove that it is
rational, with denominator exactly the characteristic polynomial `det (1 - X • A) = 1 - X - X²`
of the transfer matrix:

`det (1 - X • A) * censusSeries = C 2 - X`,

and correspondingly `(1 - 2X) * fullShiftCensusSeries = 1` for the full shift.  Since the
constant coefficient of each denominator is a unit, both series are genuinely inverses of
polynomials, so the infinite hierarchy of cycle 11 becomes a comparison of two rational
functions with different denominators.

## Main results

* `transferMatrix_pow_succ` — the closed form of `A ^ (n+1)` in Fibonacci numbers.
* `trace_transferMatrix_pow` — `trace (A ^ n) = lucas n` for every `n`, including `n = 0`.
* `periodicPoints_trace_formula` — the Artin–Mazur trace formula for the golden-mean subshift.
* `det_one_sub_smul_transferMatrix` — `det (1 - t • A) = 1 - t - t²` over any commutative ring.
* `censusSeries_rational` / `censusSeries_eq_inv` — the census series is the rational function
  `(2 - X) / det (1 - X • A)`.
* `fullShift_censusSeries_rational` — the corresponding statement `1 / (1 - 2X)` for the full
  shift.
* `censusSeries_ne_fullShift` — the two series differ, and in fact differ in every positive
  degree; this is cycle 11's obstruction hierarchy in one line.
-/

namespace FractalTruthCompactness

open FractalTruthMetric Matrix PowerSeries

/-! ## The transfer matrix -/

/-- The transfer matrix of the golden-mean constraint: the adjacency matrix of the graph on
`{false, true}` in which every transition is allowed except `true → true`.  We keep the base
ring general so that the same matrix can be used over `ℤ` and over `ℤ⟦X⟧`. -/
def transferMatrix (R : Type*) [CommRing R] : Matrix (Fin 2) (Fin 2) R := !![1, 1; 1, 0]

/-- The classical closed form for the powers of the Fibonacci transfer matrix. -/
theorem transferMatrix_pow_succ (n : ℕ) :
    transferMatrix ℤ ^ (n + 1) =
      !![(Nat.fib (n + 2) : ℤ), (Nat.fib (n + 1) : ℤ);
         (Nat.fib (n + 1) : ℤ), (Nat.fib n : ℤ)] := by
  induction n with
  | zero => simp [transferMatrix]
  | succ k ih =>
      rw [pow_succ, ih]
      have h1 : (Nat.fib (k + 3) : ℤ) = Nat.fib (k + 1) + Nat.fib (k + 2) := by
        exact_mod_cast congrArg (Nat.cast : ℕ → ℤ) (Nat.fib_add_two (n := k + 1))
      have h2 : (Nat.fib (k + 2) : ℤ) = Nat.fib k + Nat.fib (k + 1) := by
        exact_mod_cast congrArg (Nat.cast : ℕ → ℤ) (Nat.fib_add_two (n := k))
      rw [show k + 1 + 2 = k + 3 from rfl, show k + 1 + 1 = k + 2 from rfl, h1, h2]
      simp [transferMatrix]
      constructor <;> ring

/-- **Lucas numbers are traces of transfer-matrix powers.**  This is the linear-algebraic
reading of the census of cycle 11; note that it also covers `n = 0`, where both sides equal
`2` because `A ^ 0` is the identity of a two-dimensional space. -/
theorem trace_transferMatrix_pow (n : ℕ) :
    (transferMatrix ℤ ^ n).trace = (lucas n : ℤ) := by
  match n with
  | 0 => simp
  | (k + 1) =>
      rw [transferMatrix_pow_succ, Matrix.trace_fin_two_of, lucas_succ_eq_fib]
      push_cast
      ring

/-- **Artin–Mazur trace formula for the golden-mean subshift.**  The number of points of
period `n` is the trace of the `n`-th power of the transfer matrix.  Combining the
combinatorial census of cycle 11 with the closed form of the matrix powers turns a counting
statement into a spectral one. -/
theorem periodicPoints_trace_formula {n : ℕ} (hn : 0 < n) :
    ((periodicPoints n).ncard : ℤ) = (transferMatrix ℤ ^ n).trace := by
  rw [ncard_periodicPoints_goldenMean hn, trace_transferMatrix_pow]

/-- The characteristic series of the transfer matrix: `det (1 - t • A) = 1 - t - t²`.  Stated
over an arbitrary commutative ring so that it can be specialised both to scalars and to formal
power series. -/
theorem det_one_sub_smul_transferMatrix (R : Type*) [CommRing R] (t : R) :
    (1 - t • transferMatrix R).det = 1 - t - t ^ 2 := by
  simp [transferMatrix, Matrix.det_fin_two, Matrix.one_fin_two]
  ring

/-! ## The census generating series -/

/-- The generating series of the periodic census of the golden-mean subshift,
`∑ₙ Lₙ Xⁿ`. -/
noncomputable def censusSeries : PowerSeries ℤ := PowerSeries.mk fun n => (lucas n : ℤ)

/-- The generating series of the periodic census of the full shift, `∑ₙ 2ⁿ Xⁿ`. -/
noncomputable def fullShiftCensusSeries : PowerSeries ℤ := PowerSeries.mk fun n => (2 : ℤ) ^ n

@[simp] theorem coeff_censusSeries (n : ℕ) :
    (PowerSeries.coeff n) censusSeries = (lucas n : ℤ) := by
  simp [censusSeries]

@[simp] theorem coeff_fullShiftCensusSeries (n : ℕ) :
    (PowerSeries.coeff n) fullShiftCensusSeries = (2 : ℤ) ^ n := by
  simp [fullShiftCensusSeries]

/-- **Rationality of the census series.**  The generating function of the Lucas census
satisfies `(1 - X - X²) · ∑ₙ Lₙ Xⁿ = 2 - X`.  The proof is coefficientwise: degree `0` and
degree `1` are the two initial values `L₀ = 2`, `L₁ = 1`, and every higher degree is exactly
the Lucas recursion. -/
theorem censusSeries_rational :
    (1 - X - X ^ 2) * censusSeries = C (2 : ℤ) - X := by
  have hexp : (1 - X - X ^ 2) * censusSeries
      = censusSeries - X * censusSeries - X ^ 2 * censusSeries := by ring
  ext n
  rw [hexp]
  match n with
  | 0 => simp [censusSeries, lucas, map_ofNat]
  | 1 =>
      have h2 : (PowerSeries.coeff 1) (X ^ 2 * censusSeries) = 0 := by
        rw [show X ^ 2 * censusSeries = X * (X * censusSeries) by ring, coeff_succ_X_mul]
        simp [PowerSeries.coeff_zero_eq_constantCoeff]
      rw [map_sub, map_sub, coeff_succ_X_mul, h2]
      simp only [censusSeries, coeff_mk, map_sub, coeff_C, coeff_X]
      norm_num [lucas]
  | (n + 2) =>
      have h1 : (PowerSeries.coeff (n + 2)) (X * censusSeries)
          = (PowerSeries.coeff (n + 1)) censusSeries := coeff_succ_X_mul _ _
      have h2 : (PowerSeries.coeff (n + 2)) (X ^ 2 * censusSeries)
          = (PowerSeries.coeff n) censusSeries := coeff_X_pow_mul censusSeries 2 n
      rw [map_sub, map_sub, h1, h2]
      simp only [censusSeries, coeff_mk, map_sub, coeff_C, coeff_X]
      norm_num
      push_cast [lucas]
      ring

/-- The denominator of the census series is literally the characteristic series of the
transfer matrix: `det (1 - X • A) · ∑ₙ Lₙ Xⁿ = 2 - X`.  This is the precise sense in which the
Artin–Mazur zeta function of the golden-mean subshift is rational with denominator
`det (1 - X A)`. -/
theorem censusSeries_det_transferMatrix :
    (1 - (X : PowerSeries ℤ) • transferMatrix (PowerSeries ℤ)).det * censusSeries
      = C (2 : ℤ) - X := by
  rw [det_one_sub_smul_transferMatrix]
  exact censusSeries_rational

/-- The denominator is a unit in `ℤ⟦X⟧`, because its constant coefficient is `1`. -/
theorem isUnit_one_sub_X_sub_X_sq :
    IsUnit ((1 : PowerSeries ℤ) - X - X ^ 2) := by
  rw [PowerSeries.isUnit_iff_constantCoeff]
  simp

/-- **The census series is a genuine rational function.**  Dividing by the (invertible)
characteristic series exhibits `∑ₙ Lₙ Xⁿ = (2 - X) / (1 - X - X²)`. -/
theorem censusSeries_eq_inv :
    censusSeries
      = (C (2 : ℤ) - X) * Ring.inverse ((1 : PowerSeries ℤ) - X - X ^ 2) := by
  calc censusSeries
      = Ring.inverse ((1 : PowerSeries ℤ) - X - X ^ 2) * ((1 - X - X ^ 2) * censusSeries) := by
        rw [← mul_assoc, Ring.inverse_mul_cancel _ isUnit_one_sub_X_sub_X_sq, one_mul]
    _ = (C (2 : ℤ) - X) * Ring.inverse ((1 : PowerSeries ℤ) - X - X ^ 2) := by
        rw [censusSeries_rational]; ring

/-- **Rationality for the full shift.**  The full shift is the `1 × 1` case: its census series
is `1 / (1 - 2X)`, the transfer "matrix" being the scalar `2`. -/
theorem fullShift_censusSeries_rational :
    (1 - C (2 : ℤ) * X) * fullShiftCensusSeries = 1 := by
  have hexp : (1 - C (2 : ℤ) * X) * fullShiftCensusSeries
      = fullShiftCensusSeries - C (2 : ℤ) * (X * fullShiftCensusSeries) := by ring
  ext n
  rw [hexp]
  match n with
  | 0 =>
      have h : (PowerSeries.coeff 0) (C (2 : ℤ) * (X * fullShiftCensusSeries)) = 0 := by
        simp [PowerSeries.coeff_zero_eq_constantCoeff]
      rw [map_sub, h]
      simp
  | (k + 1) =>
      have h : (PowerSeries.coeff (k + 1)) (C (2 : ℤ) * (X * fullShiftCensusSeries))
          = 2 * (2 : ℤ) ^ k := by
        rw [PowerSeries.coeff_C_mul, coeff_succ_X_mul, coeff_fullShiftCensusSeries]
      rw [map_sub, h, coeff_fullShiftCensusSeries]
      simp only [coeff_one]
      norm_num
      ring

/-! ## The conjugacy obstruction as a comparison of rational functions -/

/-- Every positive-degree coefficient of the golden-mean census series is strictly smaller
than the corresponding coefficient of the full-shift series.  This is the whole obstruction
hierarchy of cycle 11, read off from the two rational functions. -/
theorem coeff_censusSeries_lt (n : ℕ) :
    (PowerSeries.coeff (n + 1)) censusSeries
      < (PowerSeries.coeff (n + 1)) fullShiftCensusSeries := by
  rw [coeff_censusSeries, coeff_fullShiftCensusSeries]
  have h := lucas_lt_two_pow n
  have : ((lucas (n + 1) : ℤ)) < ((2 ^ (n + 1) : ℕ) : ℤ) := by exact_mod_cast h
  simpa using this

/-- The two census series are distinct; equivalently the two subshifts have different
Artin–Mazur zeta functions, hence are not topologically conjugate. -/
theorem censusSeries_ne_fullShift : censusSeries ≠ fullShiftCensusSeries := by
  intro h
  have := coeff_censusSeries_lt 0
  rw [h] at this
  exact lt_irrefl _ this

end FractalTruthCompactness