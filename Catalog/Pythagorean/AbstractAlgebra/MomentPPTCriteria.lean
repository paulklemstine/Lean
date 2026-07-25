import Mathlib
import Pythagorean.PosetTheory.ReflectionPositivity

/-!
# Finite moment certificates for positive partial transpose spectra

Moment relaxations of the positive-partial-transpose condition replace direct spectral
positivity by positivity of truncated shifted Hankel matrices.  This chapter develops
the finite spectral algebra behind that construction.  A spectrum is represented by
nodes `x j` with nonnegative multiplicities `w j`; its moments are
`p k = ∑ j, w j (x j)^k`.

The principal results show that a nonnegative spectrum produces a positive semidefinite
shifted moment matrix at every level, identify its quadratic form as a weighted sum of
squares, prove nesting of the hierarchy, and extract the first nonlinear obstruction
`p₁p₃ ≥ p₂²`.  A strict reverse inequality is therefore a rigorous certificate that
some spectral node is negative.
-/

open Finset BigOperators Matrix

namespace MomentPPT

noncomputable section

/-- The power moment of a finite weighted spectrum. -/
def spectralMoment {ι : Type*} [Fintype ι] (w x : ι → ℝ) (k : ℕ) : ℝ :=
  ∑ j, w j * x j ^ k

/-- The level-`m` shifted Hankel matrix, with entry `p_(a+b+1)`. -/
def shiftedHankel {ι : Type*} [Fintype ι] (w x : ι → ℝ) (m : ℕ) :
    Matrix (Fin m) (Fin m) ℝ :=
  fun a b => spectralMoment w x (a.val + b.val + 1)

/-- The polynomial encoded by a coefficient vector in the monomial basis. -/
def probePolynomial {m : ℕ} (c : Fin m → ℝ) (t : ℝ) : ℝ :=
  ∑ a, c a * t ^ a.val

/-
Exact sum-of-squares expansion of the shifted Hankel quadratic form.
-/
theorem shiftedHankel_quadratic_identity {ι : Type*} [Fintype ι]
    (w x : ι → ℝ) (m : ℕ) (c : Fin m → ℝ) :
    (∑ a, ∑ b, c a * shiftedHankel w x m a b * c b) =
      ∑ j, w j * x j * (probePolynomial c (x j)) ^ 2 := by
  simp +decide only [shiftedHankel, spectralMoment, Finset.mul_sum _ _ _, mul_left_comm, mul_comm,
      probePolynomial];
  simp +decide only [sum_sigma', Finset.mul_sum _ _ _, mul_assoc, pow_succ, mul_comm, mul_left_comm,
      sq];
  refine' Finset.sum_bij ( fun a _ => ⟨ a.snd.snd, a.snd.fst, a.fst ⟩ ) _ _ _ _ <;> simp +decide [ pow_add, mul_assoc, mul_comm, mul_left_comm ];
  grind

/-
A nonnegative weighted spectrum has a positive semidefinite shifted moment matrix
at every truncation level.  This is the finite Gram-kernel mechanism underlying the
moment-based PPT hierarchy.
-/
theorem shiftedHankel_psd_of_nonnegative_spectrum {ι : Type*} [Fintype ι]
    (w x : ι → ℝ) (hw : ∀ j, 0 ≤ w j) (hx : ∀ j, 0 ≤ x j)
    (m : ℕ) (c : Fin m → ℝ) :
    0 ≤ ∑ a, ∑ b, c a * shiftedHankel w x m a b * c b := by
  convert shiftedHankel_quadratic_identity w x m c ▸ Finset.sum_nonneg fun j _ => mul_nonneg ( mul_nonneg ( hw j ) ( hx j ) ) ( sq_nonneg _ ) using 1

/-
The hierarchy is nested: positivity at level `m+1` implies positivity at level
`m`, by extending a probe with a zero highest coefficient.
-/
theorem shiftedHankel_hierarchy_nested {ι : Type*} [Fintype ι]
    (w x : ι → ℝ) (m : ℕ)
    (hlarge : ∀ c : Fin (m + 1) → ℝ,
      0 ≤ ∑ a, ∑ b, c a * shiftedHankel w x (m + 1) a b * c b) :
    ∀ c : Fin m → ℝ,
      0 ≤ ∑ a, ∑ b, c a * shiftedHankel w x m a b * c b := by
  intro c
  specialize hlarge (Fin.snoc c 0);
  simp_all +decide [ Fin.sum_univ_castSucc, shiftedHankel ]

/-
The first genuinely nonlinear moment obstruction: nonnegative spectra satisfy
`p₂² ≤ p₁p₃`.  It is the determinant condition for the level-two shifted Hankel
matrix.
-/
theorem first_moment_PPT_inequality {ι : Type*} [Fintype ι]
    (w x : ι → ℝ) (hw : ∀ j, 0 ≤ w j) (hx : ∀ j, 0 ≤ x j) :
    (spectralMoment w x 2) ^ 2 ≤
      spectralMoment w x 1 * spectralMoment w x 3 := by
  -- Apply the Cauchy-Schwarz inequality to the vectors $u_i = \sum_{j} \sqrt{w_j x_j} x_j^i$ and $v_i = \sum_{j} \sqrt{w_j x_j} x_j^j$.
  have h_cauchy_schwarz : ∀ (u v : ι → ℝ), (∑ j, u j * v j) ^ 2 ≤ (∑ j, u j ^ 2) * (∑ j, v j ^ 2) := by
    exact fun u v => sum_mul_sq_le_sq_mul_sq univ u v;
  convert h_cauchy_schwarz ( fun j => Real.sqrt ( w j ) * Real.sqrt ( x j ) ) ( fun j => Real.sqrt ( w j ) * Real.sqrt ( x j ) * x j ) using 1;
  · simp +decide only [spectralMoment, pow_two];
    grind +qlia;
  · simp +decide only [spectralMoment, mul_pow, Real.sq_sqrt (hw _), Real.sq_sqrt (hx _)] ; ring;

/-
A strict failure of the first nonlinear moment inequality detects a negative
spectral node, provided the spectral weights are nonnegative.
-/
theorem negative_node_of_first_moment_violation {ι : Type*} [Fintype ι]
    (w x : ι → ℝ) (hw : ∀ j, 0 ≤ w j)
    (hviol : spectralMoment w x 1 * spectralMoment w x 3 <
      (spectralMoment w x 2) ^ 2) :
    ∃ j, x j < 0 := by
  by_contra! h_nonneg;
  exact hviol.not_ge ( first_moment_PPT_inequality w x hw h_nonneg )

/-
Quantitative robustness of the first moment certificate.  If approximate moments
are uniformly accurate and the exact determinant has margin `δ`, then an explicit
error budget preserves violation.
-/
theorem first_moment_violation_stable
    (p₁ p₂ p₃ q₁ q₂ q₃ δ ε B : ℝ)
    (hp1 : |p₁| ≤ B) (hp2 : |p₂| ≤ B) (hp3 : |p₃| ≤ B)
    (hq1 : |q₁ - p₁| ≤ ε) (hq2 : |q₂ - p₂| ≤ ε) (hq3 : |q₃ - p₃| ≤ ε)
    (hmargin : p₂ ^ 2 - p₁ * p₃ ≥ δ)
    (hbudget : 2 * B * ε + ε ^ 2 + (2 * B * ε + ε ^ 2) < δ) :
    q₁ * q₃ < q₂ ^ 2 := by
  -- By combining terms, we can factor out common factors and simplify the expression.
  have h_simplify : |p₁ * (q₃ - p₃) + p₃ * (q₁ - p₁) + (q₁ - p₁) * (q₃ - p₃)| ≤ 2 * B * ε + ε ^ 2 ∧ |2 * p₂ * (q₂ - p₂) + (q₂ - p₂) ^ 2| ≤ 2 * B * ε + ε ^ 2 := by
    constructor <;> rw [ abs_le ] at *;
    · constructor <;> nlinarith;
    · constructor <;> nlinarith only [ hp2, hq2 ];
  linarith [ abs_le.mp h_simplify.1, abs_le.mp h_simplify.2 ]

/-
!-- Lab Notes -- !--

Hypothesis.  Shifted Hankel positivity is the natural finite-dimensional shadow of
spectral nonnegativity, and its first nontrivial principal minor should already yield
a robust negativity witness.

Experiment.  Expanding the quadratic form against a monomial probe gives exactly a
sum of `w j * x j` times polynomial squares.  The two-coefficient probe then yields
the determinant inequality `p₂² ≤ p₁p₃`; perturbing all three moments gives a fully
explicit stability budget.

Analysis.  The sum-of-squares identity survives without sign assumptions, while
positivity requires both nonnegative weights and nonnegative nodes.  Thus failure of
the determinant condition locates a negative node by contraposition.  The hierarchy
is nested because lower-degree probes embed by a zero leading coefficient.

Critique.  These results do not assert the random-matrix asymptotic threshold from the
paper: that step requires concentration and permutation asymptotics not developed
here.  The converse at a fixed finite level is also false in general; a negative node
can evade finitely many moment tests.  The proved statements isolate the exact
algebraic core and state all sign and error hypotheses explicitly.

Synthesis.  Finite PPT moment tests are organized as nested Gram positivity
conditions.  Their first nonlinear member is both a negativity certificate and an
experimentally robust one whenever its determinant is separated from zero.

Under the same sign assumptions, the shifted Hankel matrix is literally a Gram
kernel.  This identifies moment positivity with the factored-kernel mechanism used
in reflection positivity.
-/
theorem shiftedHankel_eq_gram {ι : Type*} [Fintype ι]
    (w x : ι → ℝ) (hw : ∀ j, 0 ≤ w j) (hx : ∀ j, 0 ≤ x j)
    (m : ℕ) (a b : Fin m) :
    shiftedHankel w x m a b =
      ∑ j, (Real.sqrt (w j * x j) * x j ^ a.val) *
        (Real.sqrt (w j * x j) * x j ^ b.val) := by
  unfold shiftedHankel; simp +decide [ spectralMoment ] ; ring;
  exact Finset.sum_congr rfl fun _ _ => by rw [ Real.sq_sqrt ( mul_nonneg ( hw _ ) ( hx _ ) ) ] ; ring;

/-
Reflection positivity supplies the Gram quadratic-form certificate for the
feature map attached to a nonnegative spectrum.
-/
theorem moment_features_reflection_positive {ι : Type*} [Fintype ι]
    (w x : ι → ℝ) (m : ℕ) (c : Fin m → ℝ) :
    0 ≤ ∑ a, ∑ b, c a *
      (∑ j, (Real.sqrt (w j * x j) * x j ^ a.val) *
        (Real.sqrt (w j * x j) * x j ^ b.val)) * c b := by
  have := @factored_kernel_posSemidef ( Fin m ) ι;
  convert this ( fun a j => Real.sqrt ( w j * x j ) * x j ^ ( a : ℕ ) ) c using 1

end

end MomentPPT