/-! # CatalogBuild.Geometry.Stereographic.StereographicAttention

Auto-generated from theorem catalog database.
Domain: Geometry/Stereographic
Declarations: 12
-/

import Mathlib

noncomputable section

/-- The conformal factor of stereographic projection at a point y ∈ ℝⁿ. -/
def stereoConfFactor (n : ℕ) (y : Fin n → ℝ) : ℝ :=
  2 / (1 + ∑ i, (y i) ^ 2)





/-- The stereographic kernel: measures similarity of two points via their
spherical images under inverse stereographic projection. -/
def stereoKernel (n : ℕ) (x y : Fin n → ℝ) : ℝ :=
  ∑ i, invStereo n x i * invStereo n y i





/-- Inner product in ℝⁿ. -/
def innerProd (n : ℕ) (x y : Fin n → ℝ) : ℝ :=
  ∑ i, x i * y i





/-- [Section: # CatalogBuild.Geometry.Stereographic.StereographicAttention
Auto-generated from theorem catalog database.
Domain: Geometry/Stereographic
Declarations: 12] -/
theorem stereoKernel_rational (n : ℕ) (x y : Fin n → ℝ) :
    stereoKernel n x y * (stereoDenom n x * stereoDenom n y) =
    4 * innerProd n x y + (sqNorm n x - 1) * (sqNorm n y - 1) := by
  unfold stereoKernel stereoDenom sqNorm;
  unfold invStereo; norm_num [ Fin.sum_univ_castSucc ] ; ring;
  unfold innerProd; norm_num [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul ] ; ring;
  norm_num [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul, mul_assoc ];
  -- Combine like terms and simplify the expression.
  field_simp
  ring





/-- The stereographic softmax weight: exponential of the stereographic kernel,
measuring how much token j attends to token i. -/
def stereoSoftmaxWeight (n : ℕ) (temperature : ℝ) (q k : Fin n → ℝ) : ℝ :=
  Real.exp (stereoKernel n q k / temperature)





/-- Stereographic softmax weights are always positive. -/
theorem stereoSoftmaxWeight_pos (n : ℕ) (T : ℝ) (q k : Fin n → ℝ) :
    0 < stereoSoftmaxWeight n T q k := by
  unfold stereoSoftmaxWeight
  exact exp_pos _





/-- A 2D Möbius transformation: f(z) = (az+b)/(cz+d) where ad-bc ≠ 0.
We encode this as a transformation on ℝ² via the real/imaginary decomposition. -/
def mobiusTransform2D (a b c d : ℝ × ℝ) (z : Fin 2 → ℝ) : Fin 2 → ℝ :=
  let x := z 0
  let y := z 1
  -- Complex multiplication (a₁+ia₂)(x+iy) = (a₁x - a₂y) + i(a₁y + a₂x)
  let num_re := (a.1 * x - a.2 * y + b.1)
  let num_im := (a.1 * y + a.2 * x + b.2)
  let den_re := (c.1 * x - c.2 * y + d.1)
  let den_im := (c.1 * y + c.2 * x + d.2)
  let den_sq := den_re ^ 2 + den_im ^ 2
  fun i => if i = 0
    then (num_re * den_re + num_im * den_im) / den_sq
    else (num_im * den_re - num_re * den_im) / den_sq





/-- A stereographic attention head: given queries Q, keys K, values V
(each as sequences of n-dimensional vectors), computes attention output.
- `seqLen` is the sequence length
- `d` is the embedding dimension
- `T` is the temperature parameter -/
def stereoAttentionHead (seqLen d : ℕ) (T : ℝ)
    (Q K V : Fin seqLen → Fin d → ℝ) : Fin seqLen → Fin d → ℝ :=
  fun i j =>
    let weights := fun k => stereoSoftmaxWeight d T (Q i) (K k)
    let totalWeight := ∑ k : Fin seqLen, weights k
    ∑ k : Fin seqLen, (weights k / totalWeight) * V k j





/-- Each attention weight in the stereographic head is non-negative. -/
theorem stereoAttention_weights_nonneg (d : ℕ) (T : ℝ) (q k : Fin d → ℝ) :
    0 ≤ stereoSoftmaxWeight d T q k :=
  le_of_lt (stereoSoftmaxWeight_pos d T q k)





/-- [Section: # CatalogBuild.Geometry.Stereographic.StereographicAttention
Auto-generated from theorem catalog database.
Domain: Geometry/Stereographic
Declarations: 12] -/
theorem stereoAttention_weight_sum_pos (seqLen d : ℕ) (T : ℝ)
    (Q : Fin seqLen → Fin d → ℝ) (K : Fin seqLen → Fin d → ℝ)
    (i : Fin seqLen) (hLen : 0 < seqLen) :
    0 < ∑ k : Fin seqLen, stereoSoftmaxWeight d T (Q i) (K k) := by
  exact Finset.sum_pos ( fun _ _ => Real.exp_pos _ ) ⟨ i, Finset.mem_univ _ ⟩





theorem stereoKernel_bounded (n : ℕ) (x y : Fin n → ℝ) :
    |stereoKernel n x y| ≤ n + 1 := by
  have h_norm_sq : ∀ y : Fin n → ℝ, ∑ i : Fin (n + 1), (invStereo n y i) ^ 2 = 1 := by
    intro y
    unfold invStereo;
    norm_num [ Fin.sum_univ_castSucc ];
    field_simp;
    norm_num [ ← Finset.mul_sum _ _ _, ← Finset.sum_div, mul_div_cancel₀ _ ( by positivity : ( 1 + ∑ i, y i ^ 2 ) ^ 2 ≠ 0 ) ];
    ring;
  have h_cauchy_schwarz : ∀ (u v : Fin (n + 1) → ℝ), (∑ i, u i * v i) ^ 2 ≤ (∑ i, u i ^ 2) * (∑ i, v i ^ 2) := by
    exact?;
  exact abs_le.mpr ⟨ by have := h_cauchy_schwarz ( invStereo n x ) ( invStereo n y ) ; have := h_norm_sq x; have := h_norm_sq y; norm_num [ stereoKernel ] at *; nlinarith, by have := h_cauchy_schwarz ( invStereo n x ) ( invStereo n y ) ; have := h_norm_sq x; have := h_norm_sq y; norm_num [ stereoKernel ] at *; nlinarith ⟩





theorem invStereo_on_sphere (n : ℕ) (y : Fin n → ℝ) :
    ∑ i, (invStereo n y i) ^ 2 = 1 := by
  unfold invStereo;
  norm_num [ Finset.sum_ite, Fin.sum_univ_castSucc ];
  field_simp;
  norm_num [ ← Finset.mul_sum _ _ _, ← Finset.sum_div ];
  rw [ mul_div_cancel₀ ] <;> nlinarith [ show 0 ≤ ∑ i, y i ^ 2 by exact Finset.sum_nonneg fun _ _ => sq_nonneg _ ]





end
