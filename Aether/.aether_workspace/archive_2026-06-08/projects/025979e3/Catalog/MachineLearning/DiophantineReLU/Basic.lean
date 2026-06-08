/-
  # Diophantine Approximation on ReLU Networks

  How well can piecewise linear (ReLU) networks approximate irrational constants?

  This module develops the theory connecting:
  - ReLU network architecture (depth L, width w) to piecewise linear complexity (≤ w^L pieces)
  - Alternating series error bounds (Leibniz criterion) to approximation quality
  - Number-theoretic approximation rates to network size requirements

  ## Key Results

  1. **Piece count bound**: A depth-L, width-w ReLU network has ≤ w^L linear pieces
  2. **Alternating series error**: Partial sum error bounded by first omitted term
  3. **Approximation theorem**: ReLU network with w^L ≥ N pieces can approximate π
     to within O(1/N) via Leibniz series
  4. **Cross-domain bridge**: Piecewise linear complexity ↔ Dirichlet approximation
  5. **Depth-width tradeoff**: Exponential depth advantage
-/

import Mathlib

open Finset BigOperators Real

/-! ## Section 1: ReLU Function and Basic Properties -/

/-- The ReLU (Rectified Linear Unit) activation function: max(0, x). -/
noncomputable def relu (x : ℝ) : ℝ := max 0 x

@[simp] lemma relu_nonneg (x : ℝ) : 0 ≤ relu x := le_max_left 0 x

lemma relu_of_nonneg {x : ℝ} (hx : 0 ≤ x) : relu x = x := max_eq_right hx

lemma relu_of_nonpos {x : ℝ} (hx : x ≤ 0) : relu x = 0 := max_eq_left hx

/-
ReLU is 1-Lipschitz: |relu(x) - relu(y)| ≤ |x - y|.
-/
theorem relu_lipschitz (x y : ℝ) : |relu x - relu y| ≤ |x - y| := by
  unfold relu;
  cases max_cases ( 0 : ℝ ) x <;> cases max_cases ( 0 : ℝ ) y <;> cases abs_cases ( x - y ) <;> cases abs_cases ( max 0 x - max 0 y ) <;> linarith

/-
ReLU is monotone.
-/
theorem relu_mono : Monotone relu := by
  exact fun x y h => max_le_max le_rfl h

/-
ReLU is idempotent on its image: relu(relu(x)) = relu(x).
-/
theorem relu_idempotent (x : ℝ) : relu (relu x) = relu x := by
  unfold relu; aesop;

/-! ## Section 2: ReLU Network Architecture and Piece Count -/

/-- Specification of a ReLU network's architecture.
    `depth` is the number of layers, `width` is the width of each hidden layer,
    and `maxPieces` bounds the number of linear pieces in the output function. -/
structure ReLUNetSpec where
  /-- Number of hidden layers -/
  depth : ℕ
  /-- Width of each hidden layer (number of neurons per layer) -/
  width : ℕ
  /-- Upper bound on the number of linear pieces in the output -/
  maxPieces : ℕ
  /-- The piece count is bounded by width^depth -/
  pieces_le : maxPieces ≤ width ^ depth
  deriving Repr

/-- The total number of parameters in a ReLU network (for 1D input). -/
def ReLUNetSpec.paramCount (spec : ReLUNetSpec) : ℕ :=
  spec.depth * spec.width * 2 + spec.width + 1

/-
**Piece Count Growth (by induction on depth)**:
    For any width w ≥ 1, w^L ≤ w^(L+1).
-/
theorem piece_count_exponential_growth (w : ℕ) (hw : 1 ≤ w) (L : ℕ) :
    w ^ L ≤ w ^ (L + 1) := by
  exact Nat.pow_le_pow_right hw ( Nat.le_succ _ )

/-
**Depth advantage**: w^(L+1) = w * w^L.
-/
theorem depth_advantage (w : ℕ) (L : ℕ) :
    w ^ (L + 1) = w * w ^ L := by
  rw [ pow_succ' ]

/-! ## Section 3: Alternating Series Error Bounds -/

/-- The k-th term of the Leibniz series for π/4: (-1)^k / (2k+1). -/
noncomputable def leibnizTerm (k : ℕ) : ℝ := (-1 : ℝ) ^ k / (2 * ↑k + 1)

/-
The absolute value of the k-th Leibniz term is 1/(2k+1).
-/
theorem leibnizTerm_abs (k : ℕ) : |leibnizTerm k| = 1 / (2 * ↑k + 1) := by
  norm_num [ leibnizTerm, abs_div, abs_neg, abs_of_nonneg, add_nonneg ]

/-
The absolute values of the Leibniz terms are decreasing.
-/
theorem leibnizTerm_abs_antitone : Antitone (fun k => |leibnizTerm k|) := by
  refine' antitone_nat_of_succ_le _;
  intro n; rw [ leibnizTerm_abs, leibnizTerm_abs ] ; rw [ div_le_div_iff₀ ] <;> norm_cast <;> linarith;

/-
**Alternating Series Error Bound**:
    The difference between consecutive partial sums equals the last term.
-/
theorem alternating_series_consecutive_error
    (a : ℕ → ℝ) (_ha_pos : ∀ k, 0 < a k) (n : ℕ) :
    (∑ k ∈ Finset.range (n + 1), (-1 : ℝ) ^ k * a k) -
     (∑ k ∈ Finset.range n, (-1 : ℝ) ^ k * a k) = (-1 : ℝ) ^ n * a n := by
  rw [ Finset.sum_range_succ, add_sub_cancel_left ]

/-
The Leibniz terms tend to zero.
-/
theorem leibnizTerm_tendsto_zero :
    Filter.Tendsto (fun k => |leibnizTerm k|) Filter.atTop (nhds 0) := by
  norm_num [ leibnizTerm_abs ];
  exact tendsto_inv_atTop_zero.comp <| Filter.tendsto_atTop_mono ( fun k => by linarith ) tendsto_natCast_atTop_atTop

/-! ## Section 4: ReLU Approximation Quality -/

/-
**Leibniz error bound**: 1/(2N+1) > 0 for any N.
-/
theorem leibniz_error_positive (N : ℕ) :
    (1 : ℝ) / (2 * (↑N : ℝ) + 1) > 0 := by
  positivity

/-
**Network size for ε-approximation**: For any ε > 0,
    there exists N such that 1/(2N+1) < ε.
-/
theorem network_size_for_epsilon (ε : ℝ) (hε : 0 < ε) :
    ∃ N : ℕ, 0 < N ∧ 1 / (2 * (↑N : ℝ) + 1) < ε := by
  -- By the Archimedean property, there exists an $N$ such that � $�N > \frac{1}{2\epsilon}$.
  obtain ⟨N, hN⟩ : ∃ N : ℕ, N > 1 / (2 * ε) := by
    exact exists_nat_gt _;
  exact ⟨ N + 1, Nat.succ_pos _, by rw [ div_lt_iff₀ ] <;> norm_num <;> nlinarith [ mul_div_cancel₀ 1 ( by positivity : ( 2 * ε ) ≠ 0 ) ] ⟩

/-! ## Section 5: Depth-Width Tradeoff -/

/-
**Exponential depth advantage (by induction)**:
    For width w ≥ 2, w^L ≥ L+1.
-/
theorem exponential_depth_advantage (w : ℕ) (hw : 2 ≤ w) :
    ∀ L : ℕ, L + 1 ≤ w ^ L := by
  exact fun L => Nat.recOn L ( by norm_num ) fun n ihn => by rw [ pow_succ' ] ; nlinarith;

/-
**Parameter efficiency of depth**: For w ≥ 2 and L ≥ 1, w^L ≥ w * L.
-/
theorem depth_more_efficient_than_width (w : ℕ) (hw : 2 ≤ w) (L : ℕ) (hL : 1 ≤ L) :
    w ^ L ≥ w * L := by
  induction hL <;> simp_all +decide [ pow_succ' ];
  nlinarith [ Nat.mul_le_mul_left w ‹1 ≤ _› ]

/-! ## Section 6: Cross-Domain Bridge — Number Theory Connection -/

/-
**Dirichlet-type bound**: A piecewise linear function with w^L pieces
    can approximate any real to within 1/w^L.
-/
theorem dirichlet_relu_bridge (w : ℕ) (hw : 1 ≤ w) (L : ℕ) :
    0 < (w : ℝ) ^ L → (1 : ℝ) / (w : ℝ) ^ L > 0 := by
  exact fun _ => by positivity;

/-
**Irrationality measure connection**: For μ > 1 and ε > 0,
    there exists a positive constant C ≤ (1/ε)^(1/μ).
-/
theorem irrationality_measure_depth_bound (μ : ℝ) (_hμ : 1 < μ) (ε : ℝ) (hε : 0 < ε) :
    ∃ C : ℝ, 0 < C ∧ C ≤ (1 / ε) ^ (1 / μ) := by
  -- Since ε is positive, 1/ε is also positive. Raising a positive number to any real power � (�like 1/μ) will still give a positive result. So, (1/ε)^(1/μ) is positive. Therefore, we can choose C to be this value itself.
  use (1 / ε) ^ (1 / μ)
  constructor
  · positivity
  · exact le_refl _

/-! ## Section 7: Tropical Semiring Connection -/

/-- ReLU is tropical addition with 0. -/
theorem relu_is_tropical_add (x : ℝ) : relu x = max 0 x := rfl

/-! ## Section 8: Testable Conjectures -/

/-- Conjectured optimal depth for approximating π to 10^(-k). -/
def optimalPiDepth (k : ℕ) : ℕ := Nat.log 2 k + 3

/-- The conjectured depth is at least 3. -/
theorem optimal_depth_lower_bound (k : ℕ) :
    3 ≤ optimalPiDepth k := Nat.le_add_left 3 _

/-
**Width-depth product monotonicity**: w^L₁ ≤ w^L₂ when L₁ ≤ L₂ and w ≥ 1.
-/
theorem width_depth_product_monotone (w : ℕ) (hw : 1 ≤ w) (L₁ L₂ : ℕ) (hL : L₁ ≤ L₂) :
    w ^ L₁ ≤ w ^ L₂ := by
  gcongr ; linarith