/-
# Complex-weighted undirected random graphs: phase locking and spectral obstruction

An undirected Bernoulli graph whose present edges all receive one fixed complex
weight is not a non-Hermitian i.i.d. matrix.  Its adjacency matrix is a complex
scalar multiple of a real symmetric zero-one matrix.  The results below isolate
this exact obstruction to a circular-law interpretation: adjunction changes only
the global phase, the matrix is normal, and every real eigenpair of the underlying
indicator matrix is transported along the single complex line spanned by the
weight.

-- !-- Lab Notes -- !--
Hypothesis (Stage 1): Seven falsifiable possibilities were considered, ranked by
impact: (1) a circular limiting law for fixed complex edge weight; (2) asymptotic
rotational invariance after centering; (3) exact normality for every realization;
(4) confinement of transported eigenvalues to one complex line; (5) a deterministic
phase relation between a matrix and its adjoint; (6) a row-sum disk bound scaled by
the modulus of the weight; and (7) linear scaling of expected weighted subgraph
counts.
Experiment (Stage 2): Writing the weighted adjacency matrix as `z • B`, with `B`
a real-valued symmetric indicator matrix, immediately tests the first two claims.
Adjunction, matrix multiplication, eigenvector transport, and expectation were then
calculated symbolically without asymptotics.
Analysis (Stage 3): Claims (3)--(7) survive exactly.  Claims (1) and (2) fail for
the undirected model because all randomness is contained in a Hermitian matrix and
multiplication by one scalar merely rotates and dilates its real spectrum.  Entry
independence also fails across the diagonal because `B i j = B j i`.
Critique (Stage 4): Normality alone would not imply line confinement for an arbitrary
normal matrix, so the scalar-Hermitian factorization and explicit eigenpair transport
are both retained.  The disk estimate is a deterministic outer bound, not evidence
of uniform filling.  No assertion treats a complex number as a probability.
Synthesis (Stage 5): The corrected theory separates the real Bernoulli parameter
from the complex edge amplitude.  Circular laws become plausible only after changing
the model to directed edges or independently phased entries.
-/
import Mathlib
import Algebra.ErdosRenyi.Model
import Algebra.Automation.SpectralBound

open Finset BigOperators Matrix

namespace ComplexRandomGraph

variable {n : Type*} [Fintype n] [DecidableEq n]

/-- The complex indicator matrix of a Boolean edge relation. -/
def indicator (g : n → n → Bool) : Matrix n n ℂ :=
  fun i j => if g i j then 1 else 0

/-- A fixed-amplitude complex adjacency matrix. -/
def adjacency (z : ℂ) (g : n → n → Bool) : Matrix n n ℂ :=
  fun i j => if g i j then z else 0

/-
Every fixed-amplitude adjacency matrix factors into one complex scalar and a
zero-one indicator matrix.
-/
theorem adjacency_factor (z : ℂ) (g : n → n → Bool) :
    adjacency z g = z • indicator g := by
  ext i j; by_cases h : g i j <;> simp +decide [ h, adjacency, indicator ] ;

/-
Symmetry of the edge relation makes the indicator matrix Hermitian.
-/
theorem indicator_isHermitian (g : n → n → Bool)
    (hsymm : ∀ i j, g i j = g j i) :
    (indicator g).IsHermitian := by
  ext i j; simp [indicator, hsymm]

/-
Adjoining a complex weighted undirected adjacency matrix conjugates only its
global amplitude.
-/
theorem adjacency_conjTranspose (z : ℂ) (g : n → n → Bool)
    (hsymm : ∀ i j, g i j = g j i) :
    (adjacency z g).conjTranspose = adjacency (star z) g := by
  unfold adjacency;
  ext i j; aesop

/-
A complex scalar multiple of a symmetric zero-one matrix is normal.  Thus the
fixed-phase undirected model is structurally unlike a Ginibre matrix.
-/
theorem adjacency_normal (z : ℂ) (g : n → n → Bool)
    (hsymm : ∀ i j, g i j = g j i) :
    adjacency z g * (adjacency z g).conjTranspose =
      (adjacency z g).conjTranspose * adjacency z g := by
  ext i j; simp +decide [ Matrix.mul_apply, adjacency_conjTranspose, hsymm ] ; ring;
  simp +decide only [adjacency] ; congr ; ext ; ring;
  split_ifs <;> ring

/-
Eigenpairs scale with the global complex edge amplitude.
-/
theorem eigenpair_transport (z mu : ℂ) (g : n → n → Bool) (v : n → ℂ)
    (hv : (indicator g).mulVec v = mu • v) :
    (adjacency z g).mulVec v = (z * mu) • v := by
  rw [ adjacency_factor ];
  rw [ Matrix.smul_mulVec, hv, smul_smul ]

/-
For nonzero amplitude, every eigenpair of the weighted matrix pulls back to an
eigenpair of the indicator matrix by division by that amplitude.
-/
theorem eigenpair_pullback {z lam : ℂ} (hz : z ≠ 0) (g : n → n → Bool)
    (v : n → ℂ) (hv : (adjacency z g).mulVec v = lam • v) :
    (indicator g).mulVec v = (lam / z) • v := by
  ext i;
  convert congr_arg ( fun x : n → ℂ => x i / z ) hv using 1 ; simp +decide [ Matrix.mulVec, dotProduct, Finset.sum_div, div_eq_inv_mul, hz ];
  · simp +decide [ Finset.mul_sum _ _ _, mul_assoc, mul_left_comm, hz, indicator, adjacency ];
  · simp +decide [ div_eq_inv_mul, mul_assoc, mul_comm, mul_left_comm ]

/-
The deterministic row-sum estimate from the catalog scales exactly under a
constant complex amplitude: a real eigenvalue bound `B` becomes the radial bound
`‖z‖ B` for its transported complex eigenvalue.
-/
theorem transported_eigenvalue_norm_bound
    (z : ℂ) {m : ℕ} (A : Matrix (Fin m) (Fin m) ℝ) (mu : ℝ)
    (v : Fin m → ℝ) (hv : v ≠ 0) (hAv : A.mulVec v = mu • v)
    (B : ℝ) (hB : ∀ i, ∑ j, |A i j| ≤ B) :
    ‖z * (mu : ℂ)‖ ≤ ‖z‖ * B := by
  convert mul_le_mul_of_nonneg_left ( @SpectralBound.eigenvalue_abs_le_of_rowSum_le m A mu v ( mod_cast hv ) ( mod_cast hAv ) B hB ) ( norm_nonneg z ) using 1;
  norm_num

/-- Multiplying a random variable by a fixed complex amplitude commutes with the
finite Erdős--Rényi expectation. -/
noncomputable def complexExpectation {E : Type*} [Fintype E] [DecidableEq E]
    (p : ℝ) (X : (E → Bool) → ℂ) : ℂ :=
  ∑ g : E → Bool, (ErdosRenyi.weight p g : ℂ) * X g

/-
Expected complex-weighted subgraph counts are the real first-moment polynomial
rotated and dilated by the edge amplitude.
-/
theorem expected_weighted_subgraphCount
    {E ι : Type*} [Fintype E] [DecidableEq E] [Fintype ι]
    (p : ℝ) (z : ℂ) (S : ι → Finset E) :
    complexExpectation p (fun g => z * (ErdosRenyi.subgraphCount S g : ℂ)) =
      z * ∑ i, (p : ℂ) ^ (S i).card := by
  convert congr_arg ( fun x : ℝ => z * x : ℝ → ℂ ) ( ErdosRenyi.expectation_subgraphCount p S ) using 1;
  · unfold complexExpectation ErdosRenyi.expectation; simp +decide [ mul_assoc, mul_left_comm, Finset.mul_sum _ _ _ ] ;
  · norm_num

/-
On four vertices the complete loopless realization has the all-ones vector as
an eigenvector with eigenvalue `3z`.  This is the deterministic mean-direction
outlier that an uncentered disk heuristic overlooks.
-/
theorem complete_four_eigenpair (z : ℂ) :
    (adjacency z (fun i j : Fin 4 => decide (i ≠ j))).mulVec (fun _ : Fin 4 => (1 : ℂ)) =
      (3 * z) • (fun _ : Fin 4 => (1 : ℂ)) := by
  ext i; unfold adjacency; norm_num [ Fin.sum_univ_four, Matrix.mulVec ] ; ring;
  fin_cases i <;> simp +decide [ Fin.sum_univ_four, dotProduct ] <;> ring!

/-
The complete four-vertex realization already violates the proposed radius
`√n ‖z‖`: its eigenvalue has modulus `3‖z‖`, strictly larger than `2‖z‖` for
nonzero amplitude.
-/
theorem complete_four_outside_sqrt_disk (z : ℂ) (hz : z ≠ 0) :
    ‖3 * z‖ > Real.sqrt 4 * ‖z‖ := by
  norm_num [ norm_mul, hz ]

end ComplexRandomGraph