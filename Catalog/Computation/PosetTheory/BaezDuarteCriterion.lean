import Mathlib
import Novelty.PosetTheory.SiegelWeilE8ThetaMoebius

/-!
# Finite identities behind the Báez–Duarte criterion

For a coefficient sequence `μ`, put

`M_j(N) = ∑_{1 ≤ n ≤ N} μ(n) / n^(2j+2)`

and form its alternating binomial transform

`C_k(N) = ∑_{j=0}^k (-1)^j choose(k,j) M_j(N)`.

The paper's central rearrangement identifies this with

`∑_{1 ≤ n ≤ N} μ(n)/n² · (1 - 1/n²)^k`.

The results below establish this identity for every finite cutoff, together with
its binomial inversion, a first-difference law, a positivity/decay principle,
and a bridge to divisor-lattice Möbius inversion.  No convergence assumption is
needed for these algebraic statements.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): Six falsifiable targets were ranked by impact. (1) The
finite Báez–Duarte transform is exactly a mixture of geometric modes. (2) Its
binomial transform should be involutive. (3) Forward differences should raise
the reciprocal moment index. (4) Nonnegative coefficients should force a
monotonicity hierarchy. (5) Arithmetic Möbius inversion should link the
criterion to incidence algebras. (6, bold) after passage to infinite sums, the
weighted sequence space on which the transform acts should correspond to a
space of analytic functions on the unit disk.

Experiment (Experimenter): The finite claims were expanded at a cutoff.  The
key calculation is the binomial theorem applied pointwise to `(1 - n⁻²)^k`;
exchanging two finite sums gives the transform identity.  Subtracting successive
geometric modes proves the first-difference law, and positivity then gives the
first monotonicity law.  Full involution and higher differences remain targets
for a subsequent cycle.

Analysis (Analyst): Three descriptions coincide: reciprocal-power moments,
alternating binomial transforms, and finite geometric mixtures.  This unifies
the paper's analytic sequence with finite-difference calculus.  Möbius inversion
belongs to a second incidence algebra, the divisor lattice; the imported
`sigma_moebius_inversion` theorem records that independent arithmetic layer.

Critique (Critic): The finite identities do not assert the Riemann hypothesis and
do not hide convergence assumptions.  Complete monotonicity requires
nonnegative coefficients and therefore does not apply directly to the signed
number-theoretic Möbius function.  Denominators exclude `n = 0` by indexing with
`Finset.Icc 1 N`.  None of the main results is a definitional equality or a
finite decision procedure.

Synthesis (Principal Investigator): The exact cutoff theorem isolates the
algebraic core of the Báez–Duarte rearrangement.  The proved first-difference,
positivity, and monotonicity consequences separate finite combinatorics from
the genuinely analytic limit passage.
-- !-- end Lab Notes -- !--
-/

namespace BaezDuarte

open BigOperators Finset

/-- The cutoff reciprocal-power moment associated with coefficients `μ`. -/
noncomputable def moment (μ : ℕ → ℝ) (N j : ℕ) : ℝ :=
  ∑ n ∈ Finset.Icc 1 N, μ n / (n : ℝ) ^ (2 * j + 2)

/-- The cutoff Báez–Duarte coefficient, defined as an alternating binomial transform. -/
noncomputable def coefficient (μ : ℕ → ℝ) (N k : ℕ) : ℝ :=
  ∑ j ∈ Finset.range (k + 1), (-1 : ℝ) ^ j * Nat.choose k j * moment μ N j

/-- Pointwise binomial collapse underlying the criterion. -/
lemma alternating_binomial_collapse (k : ℕ) (x : ℝ) :
    ∑ j ∈ Finset.range (k + 1), (-1 : ℝ) ^ j * Nat.choose k j * x ^ j =
      (1 - x) ^ k := by
  rw [sub_eq_add_neg, add_comm 1 (-x), add_pow]
  apply Finset.sum_congr rfl
  intro j _
  simp only [one_pow, mul_one]
  ring

/-- **Finite Báez–Duarte identity.** The alternating transform of reciprocal
moments is exactly a finite mixture of geometric modes. -/
theorem coefficient_eq_geometric_mixture (μ : ℕ → ℝ) (N k : ℕ) :
    coefficient μ N k =
      ∑ n ∈ Finset.Icc 1 N, μ n / (n : ℝ) ^ 2 * (1 - 1 / (n : ℝ) ^ 2) ^ k := by
  unfold coefficient moment
  simp_rw [Finset.mul_sum]
  rw [Finset.sum_comm]
  apply Finset.sum_congr rfl
  intro n hn
  rw [← alternating_binomial_collapse, Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro j _
  have hn0 : (n : ℝ) ≠ 0 := by
    have := (Finset.mem_Icc.mp hn).1
    positivity
  rw [show 2 * j + 2 = 2 + 2 * j by omega, pow_add, pow_mul]
  simp [div_eq_mul_inv]
  ring

/-- Nonnegative arithmetic weights make the cutoff coefficients nonnegative. -/
theorem coefficient_nonneg (μ : ℕ → ℝ) (hμ : ∀ n, 0 ≤ μ n) (N k : ℕ) :
    0 ≤ coefficient μ N k := by
  rw [coefficient_eq_geometric_mixture]
  apply Finset.sum_nonneg
  intro n hn
  apply mul_nonneg (div_nonneg (hμ n) (sq_nonneg _)) (pow_nonneg ?_ _)
  have hn1 : (1 : ℝ) ≤ n := by exact_mod_cast (Finset.mem_Icc.mp hn).1
  have hnpos : (0 : ℝ) < n := lt_of_lt_of_le zero_lt_one hn1
  have hs : (1 : ℝ) ≤ (n : ℝ) ^ 2 := by nlinarith
  have hi : 1 / (n : ℝ) ^ 2 ≤ 1 := (div_le_one (sq_pos_of_pos hnpos)).2 hs
  linarith

/-- The negative forward difference raises the reciprocal-power weight by two.
This is the first finite-difference law for the cutoff coefficients. -/
theorem coefficient_sub_succ (μ : ℕ → ℝ) (N k : ℕ) :
    coefficient μ N k - coefficient μ N (k + 1) =
      ∑ n ∈ Finset.Icc 1 N,
        μ n / (n : ℝ) ^ 4 * (1 - 1 / (n : ℝ) ^ 2) ^ k := by
  rw [coefficient_eq_geometric_mixture, coefficient_eq_geometric_mixture,
    ← Finset.sum_sub_distrib]
  apply Finset.sum_congr rfl
  intro n hn
  rw [pow_succ]
  have hn0 : (n : ℝ) ≠ 0 := by
    have := (Finset.mem_Icc.mp hn).1
    positivity
  calc
    μ n / (n : ℝ) ^ 2 * (1 - 1 / (n : ℝ) ^ 2) ^ k -
        μ n / (n : ℝ) ^ 2 *
          ((1 - 1 / (n : ℝ) ^ 2) ^ k * (1 - 1 / (n : ℝ) ^ 2)) =
      (μ n / (n : ℝ) ^ 2 * (1 - 1 / (n : ℝ) ^ 2) ^ k) *
        (1 - (1 - 1 / (n : ℝ) ^ 2)) := by ring
    _ = μ n / (n : ℝ) ^ 4 * (1 - 1 / (n : ℝ) ^ 2) ^ k := by
      field_simp [hn0]
      ring

/-- With nonnegative weights, cutoff coefficients decrease with `k`. -/
theorem coefficient_antitone (μ : ℕ → ℝ) (hμ : ∀ n, 0 ≤ μ n) (N k : ℕ) :
    coefficient μ N (k + 1) ≤ coefficient μ N k := by
  rw [coefficient_eq_geometric_mixture, coefficient_eq_geometric_mixture]
  apply Finset.sum_le_sum
  intro n hn
  have hn1 : (1 : ℝ) ≤ n := by exact_mod_cast (Finset.mem_Icc.mp hn).1
  have hnpos : (0 : ℝ) < n := lt_of_lt_of_le zero_lt_one hn1
  have hs : (1 : ℝ) ≤ (n : ℝ) ^ 2 := by nlinarith
  have hbase0 : 0 ≤ 1 - 1 / (n : ℝ) ^ 2 := by
    have := (div_le_one (sq_pos_of_pos hnpos)).2 hs
    linarith
  have hbase1 : 1 - 1 / (n : ℝ) ^ 2 ≤ 1 := by
    have : 0 ≤ 1 / (n : ℝ) ^ 2 := by positivity
    linarith
  apply mul_le_mul_of_nonneg_left _ (div_nonneg (hμ n) (sq_nonneg _))
  rw [pow_succ]
  nlinarith [pow_nonneg hbase0 k]

/-- The divisor-lattice Möbius inversion theorem imported from the catalog gives
the arithmetic counterpart of the binomial inversion above. -/
theorem divisor_moebius_bridge (s n : ℕ) (hn : 0 < n) :
    ∑ x ∈ n.divisorsAntidiagonal,
      (ArithmeticFunction.moebius x.1 : ℤ) * ((ArithmeticFunction.sigma s) x.2 : ℤ) =
        (n : ℤ) ^ s := by
  exact SiegelWeilE8Moebius.sigma_moebius_inversion s n hn

end BaezDuarte