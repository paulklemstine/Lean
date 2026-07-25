import Mathlib

/-! # CatalogBuild.MachineLearning.Neural.TransformerAlgebra

Auto-generated from theorem catalog database.
Domain: MachineLearning/Neural
Declarations: 22
-/


noncomputable section

/-- Softmax function on a real-valued vector indexed by `Fin n`. -/
def softmaxVec (n : ℕ) (x : Fin n → ℝ) (i : Fin n) : ℝ :=
  Real.exp (x i) / ∑ j : Fin n, Real.exp (x j)


/-- The denominator of softmax is strictly positive. -/
theorem softmax_denom_pos (n : ℕ) (hn : 0 < n) (x : Fin n → ℝ) :
    0 < ∑ j : Fin n, Real.exp (x j) := by
  have : Nonempty (Fin n) := Fin.pos_iff_nonempty.mp hn
  apply Finset.sum_pos
  · intro j _; exact Real.exp_pos (x j)
  · exact Finset.univ_nonempty


/-- Each softmax output is non-negative. -/
theorem softmaxVec_nonneg (n : ℕ) (hn : 0 < n) (x : Fin n → ℝ) (i : Fin n) :
    0 ≤ softmaxVec n x i := by
  unfold softmaxVec
  apply div_nonneg
  · exact le_of_lt (Real.exp_pos (x i))
  · exact le_of_lt (softmax_denom_pos n hn x)


/-- Softmax outputs sum to 1 (i.e., softmax defines a probability distribution). -/
theorem softmaxVec_sum_eq_one (n : ℕ) (hn : 0 < n) (x : Fin n → ℝ) :
    ∑ i : Fin n, softmaxVec n x i = 1 := by
  unfold softmaxVec
  rw [← Finset.sum_div]
  exact div_self (ne_of_gt (softmax_denom_pos n hn x))


/-- Each softmax output is at most 1. -/
theorem softmaxVec_le_one (n : ℕ) (hn : 0 < n) (x : Fin n → ℝ) (i : Fin n) :
    softmaxVec n x i ≤ 1 := by
  unfold softmaxVec
  apply div_le_one_iff.mpr
  left
  exact ⟨softmax_denom_pos n hn x,
    Finset.single_le_sum (fun j _ => le_of_lt (Real.exp_pos (x j))) (Finset.mem_univ i)⟩


/-- A 2D rotation matrix parameterized by angle θ. -/
def rotationMatrix2D (θ : ℝ) : Matrix (Fin 2) (Fin 2) ℝ :=
  !![Real.cos θ, -(Real.sin θ); Real.sin θ, Real.cos θ]


/-- The determinant of a 2D rotation matrix is 1. -/
theorem rotationMatrix2D_det (θ : ℝ) :
    (rotationMatrix2D θ).det = 1 := by
  simp [rotationMatrix2D, Matrix.det_fin_two]
  nlinarith [sin_sq_add_cos_sq θ]


/-- Rotation matrices are orthogonal: R^T * R = I. -/
theorem rotationMatrix2D_orthogonal (θ : ℝ) :
    (rotationMatrix2D θ)ᵀ * (rotationMatrix2D θ) = 1 := by
  ext i j
  fin_cases i <;> fin_cases j <;>
    simp [rotationMatrix2D, Matrix.mul_apply, Matrix.transpose_apply,
          Fin.sum_univ_two] <;>
    nlinarith [sin_sq_add_cos_sq θ]


/-- Composition of rotations is a rotation by the sum of angles. -/
theorem rotationMatrix2D_mul (θ₁ θ₂ : ℝ) :
    rotationMatrix2D θ₁ * rotationMatrix2D θ₂ = rotationMatrix2D (θ₁ + θ₂) := by
  ext i j
  fin_cases i <;> fin_cases j <;>
    simp [rotationMatrix2D, Matrix.mul_apply, Fin.sum_univ_two,
          Real.cos_add, Real.sin_add] <;>
    ring


/-- RoPE frequency for position `pos` and dimension index `k` with base `b`
and model dimension `d`. The frequency is θ_k = pos / b^(2k/d). -/
def ropeFrequency (pos : ℕ) (k : ℕ) (d : ℕ) (base : ℝ) : ℝ :=
  (pos : ℝ) / base ^ ((2 * k : ℝ) / d)


/-- The RoPE rotation for a given position and dimension pair. -/
def ropeRotation (pos : ℕ) (k : ℕ) (d : ℕ) (base : ℝ) : Matrix (Fin 2) (Fin 2) ℝ :=
  rotationMatrix2D (ropeFrequency pos k d base)


/-- RoPE rotation preserves the identity at position 0. -/
theorem ropeRotation_zero (k d : ℕ) (base : ℝ) :
    ropeRotation 0 k d base = rotationMatrix2D 0 := by
  simp [ropeRotation, ropeFrequency]


/-- Scaled dot-product scores: S = Q · K^T / √d. -/
def attentionScores (N d : ℕ) (Q K : Matrix (Fin N) (Fin d) ℝ) :
    Matrix (Fin N) (Fin N) ℝ :=
  (1 / Real.sqrt d) • (Q * Kᵀ)


/-- Row-wise softmax applied to a matrix. -/
def rowSoftmax (N : ℕ) (M : Matrix (Fin N) (Fin N) ℝ) :
    Matrix (Fin N) (Fin N) ℝ :=
  Matrix.of (fun i j => softmaxVec N (fun k => M i k) j)


/-- Full attention output: softmax(QK^T/√d) · V -/
def attentionOutput (N d dv : ℕ)
    (Q K : Matrix (Fin N) (Fin d) ℝ) (V : Matrix (Fin N) (Fin dv) ℝ) :
    Matrix (Fin N) (Fin dv) ℝ :=
  rowSoftmax N (attentionScores N d Q K) * V


/-- Each row of the attention weight matrix sums to 1 (stochastic matrix). -/
theorem attention_weights_stochastic (N d : ℕ) (hN : 0 < N)
    (Q K : Matrix (Fin N) (Fin d) ℝ) (i : Fin N) :
    ∑ j : Fin N, rowSoftmax N (attentionScores N d Q K) i j = 1 := by
  simp [rowSoftmax, Matrix.of_apply]
  exact softmaxVec_sum_eq_one N hN _


/-- Attention weights are non-negative. -/
theorem attention_weights_nonneg (N d : ℕ) (hN : 0 < N)
    (Q K : Matrix (Fin N) (Fin d) ℝ) (i j : Fin N) :
    0 ≤ rowSoftmax N (attentionScores N d Q K) i j := by
  simp [rowSoftmax, Matrix.of_apply]
  exact softmaxVec_nonneg N hN _ j


/-- A deterministic layer is a function ℝ^n → ℝ^m with no stochastic component. -/
structure DeterministicLayer (n m : ℕ) where
  forward : (Fin n → ℝ) → (Fin m → ℝ)


/-- Composition of deterministic layers is deterministic. -/
def DeterministicLayer.compose {a b c : ℕ}
    (f : DeterministicLayer b c) (g : DeterministicLayer a b) :
    DeterministicLayer a c where
  forward := f.forward ∘ g.forward


/-- A linear layer defined by weight matrix W and bias b. -/
def linearLayer (n m : ℕ) (W : Matrix (Fin m) (Fin n) ℝ) (bias : Fin m → ℝ) :
    DeterministicLayer n m where
  forward x i := (∑ j : Fin n, W i j * x j) + bias i


/-- Residual connection: f(x) = x + g(x) for g : ℝ^n → ℝ^n. -/
def residualConnection (n : ℕ) (g : DeterministicLayer n n) :
    DeterministicLayer n n where
  forward x i := x i + g.forward x i


/-- Composition of deterministic layers yields the same result as
sequential application — the forward pass is a pure function. -/
theorem forward_pass_deterministic {a b c : ℕ}
    (f : DeterministicLayer b c) (g : DeterministicLayer a b)
    (x : Fin a → ℝ) :
    (f.compose g).forward x = f.forward (g.forward x) := rfl


end