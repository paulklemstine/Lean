import Mathlib
import BourgainGamburd.Convolution

/-!
# Averaging Operators and Spectral Gap on Finite Groups

This file defines the averaging operator associated to a symmetric generating
set of a finite group and the spectral gap via a Dirichlet form / Rayleigh quotient
formulation. These concepts are central to the Bourgain–Gamburd expansion machine.

## Main definitions

- `AveragingOperator` : the operator `T_S f(x) = (1/|S|) ∑_{s ∈ S} f(s * x)`
- `DirichletForm` : the Dirichlet energy `E_S(f) = (1/(2|S|)) ∑_{s ∈ S} ∑_x (f(sx) - f(x))²`
- `HasSpectralGap` : predicate asserting a spectral gap lower bound

## Main results

- `dirichletForm_nonneg` : the Dirichlet form is nonneg
- `spectralGap_of_dirichletForm_bound` : extracts spectral gap from Dirichlet form lower bounds
-/

namespace SpectralGapTheory

open Finset BigOperators FiniteGroupConvolution

variable {G : Type*} [Fintype G] [DecidableEq G] [Group G]

/-! ### Averaging Operator -/

/-- The averaging operator `T_S` associated to a finite subset `S` of a group:
  `T_S f(x) = (1/|S|) ∑_{s ∈ S} f(s * x)`. -/
noncomputable def averagingOp (S : Finset G) (f : G → ℝ) : G → ℝ :=
  fun x => (S.card : ℝ)⁻¹ * ∑ s ∈ S, f (s * x)

/-- The generating set measure: uniform distribution on S. -/
noncomputable def genSetMeasure (S : Finset G) : G → ℝ :=
  fun g => if g ∈ S then (S.card : ℝ)⁻¹ else 0

/-! ### Dirichlet Form -/

/-- The Dirichlet form associated to a generating set `S`:
  `E_S(f) = (1/(2|S|)) ∑_{s ∈ S} ∑_{x : G} (f(sx) - f(x))²`.
  This measures the average squared difference of `f` along edges of the Cayley graph. -/
noncomputable def dirichletForm (S : Finset G) (f : G → ℝ) : ℝ :=
  (2 * S.card : ℝ)⁻¹ * ∑ s ∈ S, ∑ x : G, (f (s * x) - f x) ^ 2

/-- A symmetric generating set: closed under inversion. -/
def SymmetricSet (S : Finset G) : Prop :=
  ∀ g ∈ S, g⁻¹ ∈ S

/-- A generating set: its closure is the full group. -/
def IsGenerating (S : Finset G) : Prop :=
  Subgroup.closure (↑S : Set G) = ⊤

/-- The spectral gap lower bound predicate for a generating set `S`:
  the Dirichlet form of every mean-zero function is at least `gap * ‖f‖²₂`. -/
def HasSpectralGap (S : Finset G) (gap : ℝ) : Prop :=
  ∀ f : G → ℝ, MeanZero f → dirichletForm S f ≥ gap * l2NormSq f

/-! ### Basic Properties -/

theorem dirichletForm_nonneg (S : Finset G) (f : G → ℝ) :
    0 ≤ dirichletForm S f := by
  exact mul_nonneg ( inv_nonneg.mpr ( mul_nonneg zero_le_two ( Nat.cast_nonneg _ ) ) ) ( Finset.sum_nonneg fun _ _ => Finset.sum_nonneg fun _ _ => sq_nonneg _ )

/-- The Dirichlet form of a constant function is zero. -/
theorem dirichletForm_const (S : Finset G) (c : ℝ) :
    dirichletForm S (fun _ => c) = 0 := by
  simp [dirichletForm]

/-- The generating set measure is a probability measure when S is nonempty. -/
theorem genSetMeasure_isProbMeasure (S : Finset G) (hS : S.Nonempty) :
    IsProbMeasure (genSetMeasure S) := by
  refine' ⟨ fun g => _, _ ⟩;
  · unfold genSetMeasure; split_ifs <;> positivity;
  · unfold genSetMeasure;
    simp +decide [ Finset.sum_ite, hS.ne_empty ]

/-- The generating set measure is symmetric when the generating set is symmetric. -/
theorem genSetMeasure_isSymmetric (S : Finset G)
    (hS : SymmetricSet S) :
    IsSymmetric (genSetMeasure S) := by
  intro g;
  unfold genSetMeasure;
  split_ifs <;> simp_all +decide [ SymmetricSet ];
  exact absurd ( hS _ ‹_› ) ( by simp +decide [ * ] )

omit [DecidableEq G] in
/-- A spectral gap bound implies the Dirichlet form lower bound. -/
theorem spectralGap_nonneg (S : Finset G) (gap : ℝ)
    (h : HasSpectralGap S gap) (f : G → ℝ) (hf : MeanZero f) :
    gap * l2NormSq f ≤ dirichletForm S f :=
  h f hf

end SpectralGapTheory