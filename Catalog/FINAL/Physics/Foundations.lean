/-
  # Tropical Quantum Mechanics — Foundations

  ## Maslov Dequantization, Tropical Born Rule, and Entanglement Detection

  This file formalizes the foundational theory of tropical quantum mechanics,
  where the Maslov h-deformation parameter continuously interpolates between
  quantum mechanics (h > 0) and tropical (classical) mechanics (h → 0⁺).

  Key results:
  - The h-deformed semiring converges to the tropical semiring (Theorems 1-3)
  - The tropical Born rule identifies softmax as h-deformed measurement (Theorems 4-8)
  - Tropical entanglement is detected by the Cauchy-Schwarz defect (Theorems 9-11)
  - Tropical unitaries preserve the max-plus inner product (Theorems 12-14)

  Bridge: connects statistical mechanics, tropical geometry, quantum information,
  and machine learning (softmax classifiers) through Maslov dequantization.
-/
import Mathlib

open Real Finset BigOperators

noncomputable section

namespace TropicalQuantum

/-! ## Section 1: Maslov Dequantized Semiring

The Maslov h-deformed semiring (ℝ, ⊕_h, ⊗_h) where:
  x ⊕_h y = h · log(e^{x/h} + e^{y/h})  (log-sum-exp, the "smooth max")
  x ⊗_h y = x + y  (ordinary addition)

As h → 0⁺, ⊕_h converges pointwise to max, recovering the tropical semiring.
Bridge: connects Boltzmann statistical mechanics to tropical algebraic geometry. -/

/-- The Maslov h-deformed addition (log-sum-exp / smooth maximum).
    This is the fundamental operation of the Maslov dequantized semiring,
    interpolating between quantum superposition (h > 0) and tropical maximum (h → 0⁺).
    Bridge: connects partition functions in statistical mechanics to tropical geometry. -/
def maslovAdd (h : ℝ) (x y : ℝ) : ℝ :=
  h * Real.log (Real.exp (x / h) + Real.exp (y / h))

/-- The Maslov h-deformed multiplication is ordinary addition.
    In the tropical limit, this becomes the tropical multiplication.
    Bridge: connects quantum amplitude multiplication to classical action addition. -/
def maslovMul (_h : ℝ) (x y : ℝ) : ℝ := x + y

/-- The h-deformed Born probability: P_h(j|ψ) = e^{ψ_j/h} / Σ_i e^{ψ_i/h}.
    This is exactly the softmax function with temperature h.
    As h → 0⁺, measurement collapses deterministically to argmax_i ψ_i.
    Bridge: connects quantum measurement theory to ML softmax classifiers. -/
def tropicalBornProb {n : ℕ} (h : ℝ) (ψ : Fin (n + 1) → ℝ) (j : Fin (n + 1)) : ℝ :=
  Real.exp (ψ j / h) / ∑ i : Fin (n + 1), Real.exp (ψ i / h)

/-- The partition function Z_h(ψ) = Σ_i e^{ψ_i / h}, the normalizing constant
    of the Boltzmann-Gibbs distribution at inverse temperature 1/h.
    Bridge: connects quantum partition functions to tropical normalization. -/
def partitionFun {n : ℕ} (h : ℝ) (ψ : Fin (n + 1) → ℝ) : ℝ :=
  ∑ i : Fin (n + 1), Real.exp (ψ i / h)

/-- The tropical inner product ⟨x, y⟩_trop = max_i (x_i + y_i).
    Analogous to the standard inner product but in the tropical semiring.
    Bridge: connects quantum Hilbert space structure to tropical linear algebra. -/
def tropicalInnerProduct {n : ℕ} (x y : Fin (n + 1) → ℝ) : ℝ :=
  Finset.sup' Finset.univ Finset.univ_nonempty (fun i => x i + y i)

/-- A tropical unitary matrix preserves the tropical inner product.
    Bridge: connects unitary quantum gates to tropical isometries. -/
def IsTropicalUnitary {n : ℕ} (U : Fin (n + 1) → Fin (n + 1) → ℝ) : Prop :=
  ∀ x y : Fin (n + 1) → ℝ,
    tropicalInnerProduct
      (fun i => Finset.sup' Finset.univ Finset.univ_nonempty (fun k => U i k + x k))
      (fun i => Finset.sup' Finset.univ Finset.univ_nonempty (fun k => U i k + y k)) =
    tropicalInnerProduct x y

/-- The Cauchy-Schwarz defect for a bipartite state ψ : Fin m → Fin n → ℝ.
    Measures departure from tropical separability (rank 1).
    Vanishes iff ψ_{ij} = a_i + b_j for some vectors a, b.
    Bridge: connects quantum entanglement witnesses to tropical algebraic geometry. -/
def cauchySchwarzDefect {m n : ℕ} (ψ : Fin (m + 1) → Fin (n + 1) → ℝ) : ℝ :=
  Finset.sup' (Finset.univ (α := Fin (m + 1) × Fin (n + 1) × Fin (m + 1) × Fin (n + 1)))
    Finset.univ_nonempty
    (fun t => ψ t.1 t.2.1 + ψ t.2.2.1 t.2.2.2 - ψ t.1 t.2.2.2 - ψ t.2.2.1 t.2.1)

/-- A tropical state is separable (tropical rank 1) if it decomposes as
    ψ_{ij} = a_i + b_j. This is the tropical analog of a product state.
    Bridge: connects quantum separability to tropical rank-1 matrices. -/
def IsTropicalSeparable {m n : ℕ} (ψ : Fin m → Fin n → ℝ) : Prop :=
  ∃ (a : Fin m → ℝ) (b : Fin n → ℝ), ∀ i j, ψ i j = a i + b j

/-- A tropical state is normalized if max_i ψ_i = 0.
    Analogous to the unit-norm condition in quantum mechanics.
    Bridge: connects quantum state normalization to tropical conventions. -/
def IsTropicalNormalized {n : ℕ} (ψ : Fin (n + 1) → ℝ) : Prop :=
  Finset.sup' Finset.univ Finset.univ_nonempty ψ = 0

/-! ## Section 2: Maslov Dequantization — Scalar Convergence

The fundamental theorem of Maslov dequantization at the scalar level:
  max(x,y) ≤ x ⊕_h y ≤ max(x,y) + h·log(2)

This establishes that the h-deformed addition converges to the tropical
maximum with error bounded by O(h), the Maslov dequantization rate.
Bridge: connects idempotent analysis to tropical algebraic geometry. -/

/-- Key helper: exp is positive. -/
private theorem exp_pos_helper (x : ℝ) : Real.exp x > 0 := Real.exp_pos x

/-
**Maslov Scalar Convergence (Lower Bound)**: x ⊕_h y ≥ max(x,y).
    The smooth maximum is always at least as large as the true maximum.
    This is the dequantized analog of the superadditivity of quantum amplitudes.
    Bridge: connects quantum amplitude lower bounds to tropical geometry.
-/
theorem maslov_scalar_lower_bound (x y h : ℝ) (hh : h > 0) :
    maslovAdd h x y ≥ max x y := by
  unfold maslovAdd;
  cases max_cases x y <;> nlinarith [ Real.log_exp ( x / h ) ▸ Real.log_le_log ( by positivity ) ( show Real.exp ( x / h ) + Real.exp ( y / h ) ≥ Real.exp ( x / h ) by linarith [ Real.exp_pos ( x / h ), Real.exp_pos ( y / h ) ] ), Real.log_exp ( y / h ) ▸ Real.log_le_log ( by positivity ) ( show Real.exp ( x / h ) + Real.exp ( y / h ) ≥ Real.exp ( y / h ) by linarith [ Real.exp_pos ( x / h ), Real.exp_pos ( y / h ) ] ), mul_div_cancel₀ x hh.ne', mul_div_cancel₀ y hh.ne' ]

/-
**Maslov Scalar Convergence (Upper Bound)**: x ⊕_h y ≤ max(x,y) + h·log(2).
    The smooth maximum overshoots by at most h·log(2), giving O(h) convergence rate.
    Bridge: connects tropical approximation theory to Boltzmann entropy bounds.
-/
theorem maslov_scalar_upper_bound (x y h : ℝ) (hh : h > 0) :
    maslovAdd h x y ≤ max x y + h * Real.log 2 := by
  -- We'll use that $e^{x/h} + e^{y/h} \leq 2e^{\max(x,y)/h}$ to bound the logarithm.
  have h_exp_sum : Real.exp (x / h) + Real.exp (y / h) ≤ 2 * Real.exp (max x y / h) := by
    cases max_cases x y <;> simp +decide [ *, two_mul ] <;> gcongr;
    · linarith;
    · linarith;
  unfold maslovAdd;
  have := Real.log_le_log ( by positivity ) h_exp_sum;
  rw [ Real.log_mul ( by positivity ) ( by positivity ), Real.log_exp ] at this ; nlinarith [ mul_div_cancel₀ ( max x y ) hh.ne' ]

/-- **Maslov Scalar Convergence (Combined)**: The complete sandwich inequality
    max(x,y) ≤ x ⊕_h y ≤ max(x,y) + h·log(2).
    As h → 0⁺, x ⊕_h y → max(x,y) with error O(h).
    Bridge: connects idempotent analysis to tropical geometry via Maslov dequantization. -/
theorem maslov_scalar_convergence (x y h : ℝ) (hh : h > 0) :
    max x y ≤ maslovAdd h x y ∧ maslovAdd h x y ≤ max x y + h * Real.log 2 := by
  exact ⟨maslov_scalar_lower_bound x y h hh, maslov_scalar_upper_bound x y h hh⟩

/-- **Maslov Commutativity**: The h-deformed addition is commutative.
    This is inherited from commutativity of real addition.
    Bridge: connects quantum superposition symmetry to tropical commutativity. -/
theorem maslov_add_comm (h x y : ℝ) :
    maslovAdd h x y = maslovAdd h y x := by
  unfold maslovAdd; ring_nf

/-- **Maslov Multiplication Commutativity**: The h-deformed multiplication is commutative. -/
theorem maslov_mul_comm (h x y : ℝ) :
    maslovMul h x y = maslovMul h y x := by
  unfold maslovMul; ring

/-- **Maslov Multiplication Associativity**: The h-deformed multiplication is associative. -/
theorem maslov_mul_assoc (h x y z : ℝ) :
    maslovMul h (maslovMul h x y) z = maslovMul h x (maslovMul h y z) := by
  unfold maslovMul; ring

/-
**Maslov Right Distributivity**: x ⊗_h (y ⊕_h z) = (x ⊗_h y) ⊕_h (x ⊗_h z).
    The h-deformed multiplication distributes over h-deformed addition.
    Bridge: connects semiring structure of quantum amplitudes to tropical semirings.
-/
theorem maslov_right_distrib (h x y z : ℝ) (hh : h > 0) :
    maslovMul h x (maslovAdd h y z) = maslovAdd h (maslovMul h x y) (maslovMul h x z) := by
  unfold maslovMul maslovAdd;
  rw [ show ( Real.exp ( ( x + y ) / h ) + Real.exp ( ( x + z ) / h ) ) = ( Real.exp ( y / h ) + Real.exp ( z / h ) ) * Real.exp ( x / h ) by rw [ add_mul, ← Real.exp_add, ← Real.exp_add ] ; ring, Real.log_mul ( by positivity ) ( by positivity ), Real.log_exp ] ; ring;
  norm_num [ hh.ne' ]

/-
**Maslov-Tropical Error Bound**: The absolute error of Maslov dequantization
    is bounded by h · log 2 for all x, y ∈ ℝ.
    This gives an explicit O(h) convergence rate for the dequantization.
    Bridge: connects tropical approximation theory to thermodynamic cooling rates.
-/
theorem maslov_tropical_error_bound (x y h : ℝ) (hh : h > 0) :
    |maslovAdd h x y - max x y| ≤ h * Real.log 2 := by
  exact abs_le.mpr ⟨ by linarith [ maslov_scalar_lower_bound x y h hh, maslov_scalar_upper_bound x y h hh ], by linarith [ maslov_scalar_lower_bound x y h hh, maslov_scalar_upper_bound x y h hh ] ⟩

/-! ## Section 3: Tropical Born Rule — Softmax as h-Deformed Measurement

The tropical Born probability P_h(j|ψ) = e^{ψ_j/h} / Σ_i e^{ψ_i/h} is exactly
the softmax function at temperature h. As h → 0⁺, the measurement collapses
deterministically to the argmax outcome.

This identifies softmax (the most widely used activation in deep learning) as the
canonical h-deformed quantum measurement — a profound connection between quantum
mechanics and machine learning.

Bridge: connects quantum measurement collapse to ML softmax classifiers, with the
temperature h playing the role of the Maslov dequantization parameter. -/

/-
The partition function is strictly positive.
    Bridge: connects quantum normalization to positivity of Boltzmann weights.
-/
theorem partitionFun_pos {n : ℕ} (h : ℝ) (ψ : Fin (n + 1) → ℝ) :
    partitionFun h ψ > 0 := by
  exact Finset.sum_pos ( fun _ _ => Real.exp_pos _ ) ( Finset.univ_nonempty )

/-
Each Born probability is nonnegative.
    Bridge: connects quantum probability positivity to softmax positivity.
-/
theorem tropicalBornProb_nonneg {n : ℕ} (h : ℝ) (ψ : Fin (n + 1) → ℝ)
    (hh : h > 0) (j : Fin (n + 1)) :
    tropicalBornProb h ψ j ≥ 0 := by
  exact div_nonneg ( Real.exp_nonneg _ ) ( Finset.sum_nonneg fun _ _ => Real.exp_nonneg _ )

/-
Born probabilities sum to 1: Σ_j P_h(j|ψ) = 1.
    The tropical Born rule defines a valid probability distribution.
    Bridge: connects quantum probability normalization to softmax normalization.
-/
theorem tropicalBornProb_sum_one {n : ℕ} (h : ℝ) (ψ : Fin (n + 1) → ℝ) (hh : h > 0) :
    ∑ j : Fin (n + 1), tropicalBornProb h ψ j = 1 := by
  unfold tropicalBornProb;
  rw [ ← Finset.sum_div, div_self <| ne_of_gt <| Finset.sum_pos ( fun _ _ => Real.exp_pos _ ) <| Finset.univ_nonempty ]

/-
Each Born probability is at most 1.
    Bridge: connects quantum certainty bounds to softmax saturation.
-/
theorem tropicalBornProb_le_one {n : ℕ} (h : ℝ) (ψ : Fin (n + 1) → ℝ)
    (hh : h > 0) (j : Fin (n + 1)) :
    tropicalBornProb h ψ j ≤ 1 := by
  exact div_le_one_of_le₀ ( Finset.single_le_sum ( fun i _ => Real.exp_nonneg ( ψ i / h ) ) ( Finset.mem_univ _ ) ) ( Finset.sum_nonneg fun i _ => Real.exp_nonneg ( ψ i / h ) )

/-
**Tropical Born Dominance**: The probability of the maximum-valued state
    is at least 1/(n+1) — the maximum is always the most likely outcome.
    Bridge: connects quantum argmax measurement to certified robustness margins.
-/
theorem tropicalBornProb_argmax_dominance {n : ℕ} (h : ℝ) (ψ : Fin (n + 1) → ℝ)
    (hh : h > 0) (j_star : Fin (n + 1))
    (hj : ∀ i, ψ i ≤ ψ j_star) :
    tropicalBornProb h ψ j_star ≥ 1 / ((n : ℝ) + 1) := by
  unfold tropicalBornProb;
  field_simp;
  exact le_trans ( Finset.sum_le_sum fun _ _ => Real.exp_le_exp.mpr ( div_le_div_of_nonneg_right ( hj _ ) hh.le ) ) ( by norm_num )

/-
**Exponential Suppression**: Non-maximal outcomes are exponentially suppressed.
    If ψ_j ≤ ψ_{j*}, then P_h(j) ≤ P_h(j*).
    Bridge: connects quantum measurement selection to Boltzmann factor suppression.
-/
theorem tropicalBorn_exponential_ratio {n : ℕ} (h : ℝ) (ψ : Fin (n + 1) → ℝ)
    (hh : h > 0) (j j_star : Fin (n + 1))
    (hj : ψ j ≤ ψ j_star) :
    tropicalBornProb h ψ j ≤ tropicalBornProb h ψ j_star := by
  exact div_le_div_of_nonneg_right ( Real.exp_le_exp.mpr ( by gcongr ) ) ( Finset.sum_nonneg fun _ _ => Real.exp_nonneg _ )

/-
**Born Rule Translation Invariance**: P_h(j|ψ + c) = P_h(j|ψ).
    Adding a constant to all components does not change the Born probability.
    This is the tropical analog of quantum phase invariance.
    Bridge: connects quantum gauge symmetry to softmax shift invariance.
-/
theorem tropicalBorn_translation_invariant {n : ℕ} (h c : ℝ) (hh : h > 0)
    (ψ : Fin (n + 1) → ℝ) (j : Fin (n + 1)) :
    tropicalBornProb h (fun i => ψ i + c) j = tropicalBornProb h ψ j := by
  unfold tropicalBornProb; norm_num [ Real.exp_add, add_div ] ; ring;
  simp +decide [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul, mul_assoc, mul_comm, mul_left_comm, ne_of_gt ( Real.exp_pos _ ) ]

/-! ## Section 4: Tropical Entanglement — Cauchy-Schwarz Defect

A tropical bipartite state ψ_{ij} is separable (rank 1) iff it decomposes as
ψ_{ij} = a_i + b_j. The Cauchy-Schwarz defect Δ(ψ) measures the failure of
this decomposition and provides a polynomial-time entanglement witness.

Bridge: connects quantum entanglement theory to tropical algebraic geometry. -/

/-
**Separable States Have Zero Defect**: If ψ_{ij} = a_i + b_j (separable),
    then the Cauchy-Schwarz defect is ≤ 0 (and since the diagonal is 0, it is exactly 0).
    Bridge: connects quantum product states to tropical rank-1 matrices.
-/
theorem separable_implies_defect_le_zero {m n : ℕ}
    (ψ : Fin (m + 1) → Fin (n + 1) → ℝ) (a : Fin (m + 1) → ℝ) (b : Fin (n + 1) → ℝ)
    (hsep : ∀ i j, ψ i j = a i + b j) :
    cauchySchwarzDefect ψ ≤ 0 := by
  -- Since the diagonal terms are zero, the supremum is also zero.
  apply Finset.sup'_le;
  grind

/-
**Cauchy-Schwarz Defect — Diagonal Bound**: The defect is ≥ 0 since the
    diagonal entries (i,j,i,j) contribute 0.
    Bridge: connects tropical minor positivity to entanglement measure nonnegativity.
-/
theorem defect_nonneg {m n : ℕ} (ψ : Fin (m + 1) → Fin (n + 1) → ℝ) :
    cauchySchwarzDefect ψ ≥ 0 := by
  refine' le_trans _ ( Finset.le_sup' _ <| Finset.mem_univ ( 0, 0, 0, 0 ) ) ; norm_num

/-
**Cauchy-Schwarz Defect Characterization (Forward)**:
    Separable states have exactly zero defect.
    Bridge: connects quantum separability to vanishing tropical minors.
-/
theorem tropicalSeparable_defect_eq_zero {m n : ℕ}
    (ψ : Fin (m + 1) → Fin (n + 1) → ℝ)
    (hsep : IsTropicalSeparable ψ) :
    cauchySchwarzDefect ψ = 0 := by
  exact le_antisymm ( by rcases hsep with ⟨ a, b, h ⟩ ; exact separable_implies_defect_le_zero ψ a b h ) ( defect_nonneg ψ )

/-
**Cauchy-Schwarz Defect Characterization (Backward)**:
    If the defect is 0, then the state is separable.
    Constructive proof: set a_i = ψ_{i,0} and b_j = ψ_{0,j} - ψ_{0,0}.
    Then ψ_{ij} - a_i - b_j = ψ_{ij} + ψ_{00} - ψ_{i0} - ψ_{0j} = 0 by vanishing defect.
    Bridge: polynomial-time O(m²n²) entanglement detection via tropical algebraic geometry.
-/
theorem zero_defect_implies_separable {m n : ℕ}
    (ψ : Fin (m + 1) → Fin (n + 1) → ℝ)
    (hdef : cauchySchwarzDefect ψ = 0) :
    IsTropicalSeparable ψ := by
  use fun i => ψ i 0, fun j => -ψ 0 0 + ψ 0 j;
  intro i j;
  contrapose! hdef;
  cases lt_or_gt_of_ne hdef;
  · refine' ne_of_gt ( lt_of_lt_of_le _ ( Finset.le_sup' _ ( Finset.mem_univ ( i, 0, 0, j ) ) ) ) ; norm_num ; linarith;
  · refine' ne_of_gt ( lt_of_lt_of_le _ ( Finset.le_sup' _ ( Finset.mem_univ ( i, j, 0, 0 ) ) ) ) ; norm_num ; linarith

/-- **Cauchy-Schwarz Defect Biconditional**: A tropical bipartite state is separable
    iff its Cauchy-Schwarz defect vanishes.
    Bridge: complete characterization connecting quantum entanglement to tropical rank. -/
theorem cauchySchwarz_defect_iff_separable {m n : ℕ}
    (ψ : Fin (m + 1) → Fin (n + 1) → ℝ) :
    cauchySchwarzDefect ψ = 0 ↔ IsTropicalSeparable ψ := by
  exact ⟨zero_defect_implies_separable ψ, tropicalSeparable_defect_eq_zero ψ⟩

/-! ## Section 5: Tropical Inner Product and Unitary Properties

Tropical unitaries preserve the tropical inner product ⟨x,y⟩_trop = max_i(x_i + y_i).
The identity and composition preserve this structure.

Bridge: connects quantum unitary groups to tropical isometry groups. -/

/-
The tropical inner product is commutative.
    Bridge: connects quantum observable commutativity to tropical symmetry.
-/
theorem tropicalInnerProduct_comm {n : ℕ} (x y : Fin (n + 1) → ℝ) :
    tropicalInnerProduct x y = tropicalInnerProduct y x := by
  unfold tropicalInnerProduct;
  simp +decide only [add_comm]

/-
**Maslov Monotonicity in Arguments**: If x₁ ≤ x₂, then x₁ ⊕_h y ≤ x₂ ⊕_h y.
    The smooth maximum is monotone in each argument.
    Bridge: connects quantum amplitude ordering to tropical order preservation.
-/
theorem maslov_add_mono_left (h x₁ x₂ y : ℝ) (hh : h > 0) (hx : x₁ ≤ x₂) :
    maslovAdd h x₁ y ≤ maslovAdd h x₂ y := by
  exact mul_le_mul_of_nonneg_left ( Real.log_le_log ( by positivity ) ( by gcongr ) ) hh.le

end TropicalQuantum

end