import Mathlib
import Bridges.PosetTheory.FisherCramerRao
import Bridges.FisherMonotonicity
import Bridges.DifferentialGeometry.InformationGeometryOptimization

/-!
# Contrarian information geometry on finite statistical models

This file separates a false, over-quantified flatness claim from a correct
finite-dimensional construction.  It develops the Fisher metric of a finite
feature model as a covariance Gram form, states the directional Cramér--Rao
bound geometrically, and gives the natural/expectation-coordinate presentations
of Amari's alpha-connections.

The main contrarian conclusions are:

* an arbitrary connection with `α = 1` need not be flat, even in dimension one;
* the canonical alpha-connection built from a cubic score tensor is e-flat in
  natural coordinates and its dual presentation is m-flat in expectation
  coordinates;
* away from `α = 1`, a nonzero cubic tensor obstructs vanishing natural-coordinate
  coefficients.
-/

noncomputable section

open Finset BigOperators

namespace InformationGeometryContrarian

variable {S : Type*} [Fintype S]
variable {d : ℕ}

/-- Expectation with respect to a finite weight vector. -/
def weightedExpectation (p : S → ℝ) (f : S → ℝ) : ℝ :=
  ∑ x, p x * f x

/-- The centered version of a finite sufficient statistic. -/
def centeredFeature (p : S → ℝ) (T : S → Fin d → ℝ)
    (x : S) (i : Fin d) : ℝ :=
  T x i - weightedExpectation p (fun y => T y i)

/-- Fisher information of a finite exponential-family feature model, expressed
as the covariance matrix of its sufficient statistics. -/
def featureFisher (p : S → ℝ) (T : S → Fin d → ℝ) (i j : Fin d) : ℝ :=
  weightedExpectation p (fun x => centeredFeature p T x i * centeredFeature p T x j)

/-- The Amari--Chentsov cubic tensor is the third centered moment of the score. -/
def scoreCubic (p : S → ℝ) (T : S → Fin d → ℝ) (i j k : Fin d) : ℝ :=
  weightedExpectation p (fun x =>
    centeredFeature p T x i * centeredFeature p T x j * centeredFeature p T x k)

/-- The Fisher quadratic form is an expectation of the squared directional score. -/
theorem featureFisher_quadForm (p : S → ℝ) (T : S → Fin d → ℝ)
    (v : Fin d → ℝ) :
    (∑ i, ∑ j, v i * featureFisher p T i j * v j) =
      weightedExpectation p (fun x => (∑ i, v i * centeredFeature p T x i) ^ 2) := by
  simp +decide [featureFisher, weightedExpectation, mul_assoc, mul_comm,
    mul_left_comm, Finset.mul_sum _ _ _, pow_two]
  exact Eq.symm (Finset.sum_comm.trans
    (Finset.sum_congr rfl fun _ _ => Finset.sum_comm))

/-- The feature Fisher matrix is positive semidefinite for nonnegative weights. -/
theorem featureFisher_positiveSemidefinite (p : S → ℝ) (T : S → Fin d → ℝ)
    (hp : ∀ x, 0 ≤ p x) (v : Fin d → ℝ) :
    0 ≤ ∑ i, ∑ j, v i * featureFisher p T i j * v j := by
  rw [featureFisher_quadForm]
  unfold weightedExpectation
  exact Finset.sum_nonneg (fun x _ => mul_nonneg (hp x) (sq_nonneg _))

/-- The exact nullspace criterion for a full-support finite feature model. -/
theorem featureFisher_null_iff (p : S → ℝ) (T : S → Fin d → ℝ)
    (hp : ∀ x, 0 < p x) (v : Fin d → ℝ) :
    (∑ i, ∑ j, v i * featureFisher p T i j * v j) = 0 ↔
      ∀ x, ∑ i, v i * centeredFeature p T x i = 0 := by
  rw [featureFisher_quadForm]
  unfold weightedExpectation
  constructor
  · intro h x
    have hz := (Finset.sum_eq_zero_iff_of_nonneg
      (fun y _ => mul_nonneg (le_of_lt (hp y)) (sq_nonneg _))).mp h x (Finset.mem_univ x)
    exact sq_eq_zero_iff.mp ((mul_eq_zero.mp hz).resolve_left (ne_of_gt (hp x)))
  · intro h
    simp [h]

/-- Lower-index coefficients of the canonical alpha-connection in natural
coordinates.  The cubic score tensor controls departure from the e-connection. -/
def naturalAlphaChristoffel (α : ℝ) (C : Fin d → Fin d → Fin d → ℝ)
    (i j k : Fin d) : ℝ :=
  ((1 - α) / 2) * C i j k

/-- The same alpha-connection in the dual expectation-coordinate presentation. -/
def expectationAlphaChristoffel (α : ℝ) (C : Fin d → Fin d → Fin d → ℝ)
    (i j k : Fin d) : ℝ :=
  ((1 + α) / 2) * C i j k

/-- Exponential families are e-flat in natural parameters: the canonical
`α = 1` coefficients vanish. -/
theorem exponential_family_e_flat
    (C : Fin d → Fin d → Fin d → ℝ) (i j k : Fin d) :
    naturalAlphaChristoffel 1 C i j k = 0 := by
  simp [naturalAlphaChristoffel]

/-- The dual mixture connection is flat in expectation parameters. -/
theorem exponential_family_m_flat_in_expectation_coordinates
    (C : Fin d → Fin d → Fin d → ℝ) (i j k : Fin d) :
    expectationAlphaChristoffel (-1) C i j k = 0 := by
  simp [expectationAlphaChristoffel]

/-- Opposite alpha-connections are dual: their lower coefficients add to the
Amari--Chentsov cubic tensor. -/
theorem alpha_connections_dual
    (α : ℝ) (C : Fin d → Fin d → Fin d → ℝ) (i j k : Fin d) :
    naturalAlphaChristoffel α C i j k +
      naturalAlphaChristoffel (-α) C i j k = C i j k := by
  unfold naturalAlphaChristoffel
  ring

/-- Natural and expectation presentations agree after reversing alpha. -/
theorem natural_expectation_coordinate_duality
    (α : ℝ) (C : Fin d → Fin d → Fin d → ℝ) (i j k : Fin d) :
    naturalAlphaChristoffel α C i j k =
      expectationAlphaChristoffel (-α) C i j k := by
  unfold naturalAlphaChristoffel expectationAlphaChristoffel
  ring

/-- The zero and dual connections average to the Levi--Civita (`α = 0`)
coefficients. -/
theorem leviCivita_is_dual_midpoint
    (C : Fin d → Fin d → Fin d → ℝ) (i j k : Fin d) :
    naturalAlphaChristoffel 0 C i j k =
      (naturalAlphaChristoffel 1 C i j k +
        naturalAlphaChristoffel (-1) C i j k) / 2 := by
  unfold naturalAlphaChristoffel
  ring

/-- Contrarian obstruction: if one cubic component is nonzero, no natural
alpha-connection other than `α = 1` can have that coefficient vanish. -/
theorem nonzero_cubic_forces_alpha_one
    (α : ℝ) (C : Fin d → Fin d → Fin d → ℝ) (i j k : Fin d)
    (hC : C i j k ≠ 0)
    (hzero : naturalAlphaChristoffel α C i j k = 0) :
    α = 1 := by
  unfold naturalAlphaChristoffel at hzero
  rcases mul_eq_zero.mp hzero with h | h
  · apply (sub_eq_zero.mp ?_).symm
    exact (div_eq_zero_iff.mp h).resolve_right (by norm_num)
  · exact (hC h).elim

/-- The previously proposed statement that *every* connection tagged `α = 1`
is flat is false.  Flatness follows from the canonical construction, not merely
from attaching the number one to arbitrary Christoffel symbols. -/
theorem arbitrary_connection_e_flat_conjecture_false :
    ¬ InformationGeometry.ExpFamilyEFlat 1 := by
  intro h
  let Γ : InformationGeometry.AlphaConnection 1 :=
    { α := 1
      christoffel := fun _ _ _ _ => 1 }
  have hz := h Γ rfl (fun _ => 0) 0 0 0
  norm_num at hz

/-- A concrete Bernoulli distribution used as exact computational evidence. -/
def bernoulliQuarterProbability : Fin 2 → ℝ
  | 0 => 3 / 4
  | 1 => 1 / 4

/-- Its sufficient statistic is the indicator of outcome `1`. -/
def bernoulliIndicator : Fin 2 → Fin 1 → ℝ
  | 0, _ => 0
  | 1, _ => 1

/-- Exact small-case calculation: Bernoulli(1/4) has Fisher variance `3/16`. -/
theorem bernoulli_quarter_fisher_exact :
    featureFisher bernoulliQuarterProbability bernoulliIndicator 0 0 = 3 / 16 := by
  norm_num [featureFisher, weightedExpectation, centeredFeature,
    bernoulliQuarterProbability, bernoulliIndicator, Fin.sum_univ_two]

/-- Exact small-case calculation: its cubic score moment is nonzero (`3/32`). -/
theorem bernoulli_quarter_cubic_exact :
    scoreCubic bernoulliQuarterProbability bernoulliIndicator 0 0 0 = 3 / 32 := by
  norm_num [scoreCubic, weightedExpectation, centeredFeature,
    bernoulliQuarterProbability, bernoulliIndicator, Fin.sum_univ_two]

/-- Consequently, in this asymmetric Bernoulli exponential family, the natural
alpha coefficient vanishes exactly at the e-connection `α = 1`. -/
theorem bernoulli_quarter_alpha_flat_iff (α : ℝ) :
    naturalAlphaChristoffel α
      (scoreCubic bernoulliQuarterProbability bernoulliIndicator) 0 0 0 = 0 ↔
      α = 1 := by
  constructor
  · intro h
    exact nonzero_cubic_forces_alpha_one α _ 0 0 0
      (by rw [bernoulli_quarter_cubic_exact]; norm_num) h
  · rintro rfl
    exact exponential_family_e_flat _ 0 0 0

/-- The directional Cramér--Rao inequality, phrased as comparison between the
squared estimator sensitivity and its variance times Fisher squared length. -/
theorem cramer_rao_geometric
    (M : FisherCramerRao.GenStatModel S d) (θ : Fin d → ℝ)
    (f : S → ℝ) (w : Fin d → ℝ) :
    (FisherCramerRao.expect M θ
      (fun x => f x * FisherMonotonicity.dirScore M θ w x)) ^ 2 ≤
      FisherCramerRao.variance M θ f *
        (∑ i, ∑ j, w i * FisherCramerRao.gfisher M θ i j * w j) := by
  exact FisherMonotonicity.cramer_rao_directional M θ f w

end InformationGeometryContrarian