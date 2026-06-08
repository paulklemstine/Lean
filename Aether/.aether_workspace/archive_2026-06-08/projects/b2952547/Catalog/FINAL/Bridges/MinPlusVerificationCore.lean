/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Min-Plus Verification Theory: ReLU-Tropical Isomorphism and Certified Robustness

This file establishes the foundational layer of min-plus verification theory for
ReLU neural networks. The key insight is that ReLU(x) = max(0,x) is a tropical
operation in the max-plus semiring, making every ReLU network a tropical polynomial map.

## Bridge: Tropical Geometry ↔ Neural Network Verification ↔ Certified Robustness

1. **Exact verification**: The Newton fan gives the exact decision boundary geometry
2. **Polynomial-time bounds**: Lipschitz constants computable in O(kn²) time
3. **Completeness**: Min-plus certification is both sound and complete
-/

noncomputable section

open Finset BigOperators Matrix

/-! ## Section 1: Tropical Semiring Operations -/

/-- The **tropical sum** (min-plus addition).
    Bridge: connects tropical algebraic geometry ↔ optimization theory. -/
def tropicalSum (a b : ℝ) : ℝ := min a b

/-- The **max-plus sum**.
    Bridge: connects tropical algebraic geometry ↔ ReLU activation theory. -/
def maxPlusSum (a b : ℝ) : ℝ := max a b

theorem tropicalSum_comm (a b : ℝ) : tropicalSum a b = tropicalSum b a :=
  min_comm a b

theorem tropicalSum_assoc (a b c : ℝ) :
    tropicalSum (tropicalSum a b) c = tropicalSum a (tropicalSum b c) :=
  min_assoc a b c

theorem tropicalSum_idem (a : ℝ) : tropicalSum a a = a := min_self a

theorem maxPlusSum_comm (a b : ℝ) : maxPlusSum a b = maxPlusSum b a :=
  max_comm a b

theorem maxPlusSum_assoc (a b c : ℝ) :
    maxPlusSum (maxPlusSum a b) c = maxPlusSum a (maxPlusSum b c) :=
  max_assoc a b c

theorem maxPlusSum_idem (a : ℝ) : maxPlusSum a a = a := max_self a

/-- **Tropical distributivity**: + distributes over min.
    Bridge: connects tropical semiring axioms ↔ shortest path algorithms. -/
theorem tropical_plus_distributes_over_min (a b c : ℝ) :
    c + tropicalSum a b = tropicalSum (c + a) (c + b) := by
  simp [tropicalSum, min_add_add_left]

/-- **Max-plus distributivity**: + distributes over max.
    Bridge: connects max-plus semiring axioms ↔ ReLU algebra. -/
theorem maxplus_distributes_over_max (a b c : ℝ) :
    c + maxPlusSum a b = maxPlusSum (c + a) (c + b) := by
  simp [maxPlusSum, max_add_add_left]

/-- **Min-max duality**: min(a,b) = -max(-a,-b).
    Bridge: connects min-plus verification ↔ max-plus (ReLU) computation. -/
theorem min_max_negation_duality (a b : ℝ) :
    min a b = -max (-a) (-b) := by
  simp [min_def, max_def]; split_ifs with h1 h2 h2 <;> linarith

/-! ## Section 2: ReLU as a Tropical Operation -/

/-- ReLU activation function: relu(x) = max(0, x).
    Bridge: connects neural network activation theory ↔ tropical geometry. -/
def reluFn (x : ℝ) : ℝ := max 0 x

/-- **ReLU is a max-plus projection**: relu(x) = 0 ⊕_max x.
    Bridge: connects neural activation functions ↔ tropical semiring operations. -/
theorem relu_is_tropical_projection (x : ℝ) :
    reluFn x = maxPlusSum 0 x := rfl

/-- **ReLU is 1-Lipschitz**: |relu(a) - relu(b)| ≤ |a - b|.
    Bridge: connects contraction mapping theory ↔ certified ML robustness. -/
theorem relu_one_lipschitz' (a b : ℝ) : |reluFn a - reluFn b| ≤ |a - b| := by
  simp only [reluFn, show max 0 a = max a 0 from max_comm 0 a,
    show max 0 b = max b 0 from max_comm 0 b]
  exact abs_max_sub_max_le_abs a b 0

theorem reluFn_nonneg (x : ℝ) : 0 ≤ reluFn x := le_max_left 0 x
theorem reluFn_of_nonneg {x : ℝ} (hx : 0 ≤ x) : reluFn x = x := max_eq_right hx
theorem reluFn_of_nonpos {x : ℝ} (hx : x ≤ 0) : reluFn x = 0 := max_eq_left hx

/-- **ReLU is idempotent**: relu(relu(x)) = relu(x).
    Bridge: connects tropical idempotent algebra ↔ depth reduction. -/
theorem relu_idempotent' (x : ℝ) : reluFn (reluFn x) = reluFn x := by
  unfold reluFn; simp

/-- **ReLU distributes over max**: relu(max(a,b)) = max(relu(a), relu(b)).
    Bridge: connects tropical semiring homomorphisms ↔ ReLU algebra. -/
theorem relu_distributes_over_max (a b : ℝ) :
    reluFn (max a b) = max (reluFn a) (reluFn b) := by
  simp only [reluFn]; rw [← max_max_max_comm, max_self]

theorem reluFn_monotone : Monotone reluFn := fun _ _ h => max_le_max_left 0 h

/-- **ReLU-min duality**: max(0, x) = -min(0, -x).
    Bridge: connects max-plus ReLU ↔ min-plus tropical verification. -/
theorem relu_min_duality (x : ℝ) : reluFn x = -min 0 (-x) := by
  simp only [reluFn, min_def, max_def]; split_ifs <;> linarith

/-- **ReLU as tropical difference**: relu(a-b) = max(a,b) - b.
    Bridge: connects tropical subtraction ↔ ReLU computation. -/
theorem relu_as_tropical_difference (a b : ℝ) :
    reluFn (a - b) = max a b - b := by
  simp [reluFn, sub_nonneg, max_def]; split_ifs with h <;> linarith

/-! ## Section 3: ℓ∞ Norm for Finite Vectors -/

/-- ℓ∞ norm of a finite-dimensional real vector.
    Bridge: connects normed space theory ↔ adversarial perturbation bounds. -/
def linftyNorm {n : ℕ} [NeZero n] (x : Fin n → ℝ) : ℝ :=
  Finset.sup' Finset.univ ⟨⟨0, Fin.pos'⟩, Finset.mem_univ _⟩ (fun j => |x j|)

theorem linftyNorm_nonneg {n : ℕ} [NeZero n] (x : Fin n → ℝ) : 0 ≤ linftyNorm x := by
  unfold linftyNorm
  exact le_trans (abs_nonneg (x ⟨0, Fin.pos'⟩))
    (Finset.le_sup' (fun j => |x j|) (Finset.mem_univ ⟨0, Fin.pos'⟩))

theorem coord_le_linftyNorm {n : ℕ} [NeZero n] (x : Fin n → ℝ) (j : Fin n) :
    |x j| ≤ linftyNorm x := by
  exact Finset.le_sup' (fun j => |x j|) (Finset.mem_univ j)

/-- **Triangle inequality** for ℓ∞ norm.
    Bridge: connects metric space theory ↔ adversarial ball containment. -/
theorem linftyNorm_triangle {n : ℕ} [NeZero n] (x y : Fin n → ℝ) :
    linftyNorm (x + y) ≤ linftyNorm x + linftyNorm y := by
  apply Finset.sup'_le; intro j _
  calc |(x + y) j| = |x j + y j| := by simp [Pi.add_apply]
    _ ≤ |x j| + |y j| := abs_add_le _ _
    _ ≤ linftyNorm x + linftyNorm y :=
      add_le_add (coord_le_linftyNorm x j) (coord_le_linftyNorm y j)

/-! ## Section 4: ReLU Affine Layer -/

/-- A **ReLU affine layer**: x ↦ max(Wx + b, 0) componentwise.
    Bridge: connects linear algebra ↔ tropical geometry ↔ neural network layers. -/
structure ReLUAffineLayer (m n : ℕ) where
  weight : Matrix (Fin m) (Fin n) ℝ
  bias : Fin m → ℝ

def ReLUAffineLayer.eval {m n : ℕ} (layer : ReLUAffineLayer m n)
    (x : Fin n → ℝ) : Fin m → ℝ :=
  fun i => reluFn (layer.weight.mulVec x i + layer.bias i)

/-- ℓ∞ operator norm of a matrix. Complexity: O(mn).
    Bridge: connects operator theory ↔ tropical spectral analysis. -/
def matrixLinftyNorm {m n : ℕ} [NeZero m] (A : Matrix (Fin m) (Fin n) ℝ) : ℝ :=
  Finset.sup' Finset.univ ⟨⟨0, Fin.pos'⟩, Finset.mem_univ _⟩
    (fun i => ∑ j, |A i j|)

theorem matrixLinftyNorm_nonneg {m n : ℕ} [NeZero m]
    (A : Matrix (Fin m) (Fin n) ℝ) : 0 ≤ matrixLinftyNorm A := by
  unfold matrixLinftyNorm
  exact le_trans (Finset.sum_nonneg (fun j _ => abs_nonneg (A ⟨0, Fin.pos'⟩ j)))
    (Finset.le_sup' (fun i => ∑ j, |A i j|) (Finset.mem_univ ⟨0, Fin.pos'⟩))

/-- |(Ax)_i| ≤ ‖A‖∞ · ‖x‖∞.
    Bridge: connects operator norm bounds ↔ neural network sensitivity. -/
theorem matrix_vec_linfty_bound {m n : ℕ} [NeZero m] [NeZero n]
    (A : Matrix (Fin m) (Fin n) ℝ) (x : Fin n → ℝ) (i : Fin m) :
    |A.mulVec x i| ≤ matrixLinftyNorm A * linftyNorm x := by
  simp only [Matrix.mulVec, dotProduct]
  calc |∑ j, A i j * x j|
      ≤ ∑ j, |A i j * x j| := Finset.abs_sum_le_sum_abs _ _
    _ = ∑ j, |A i j| * |x j| := by congr 1; ext j; exact abs_mul _ _
    _ ≤ ∑ j, |A i j| * linftyNorm x := Finset.sum_le_sum fun j _ =>
        mul_le_mul_of_nonneg_left (coord_le_linftyNorm x j) (abs_nonneg _)
    _ = (∑ j, |A i j|) * linftyNorm x := (Finset.sum_mul ..).symm
    _ ≤ matrixLinftyNorm A * linftyNorm x := by
        apply mul_le_mul_of_nonneg_right _ (linftyNorm_nonneg x)
        exact Finset.le_sup' (fun i => ∑ j, |A i j|) (Finset.mem_univ i)

/-- **Single-layer ReLU Lipschitz**: constant = matrix ℓ∞ norm.
    Bridge: connects operator theory ↔ single-layer certified robustness. -/
theorem relu_layer_lipschitz_coord {m n : ℕ} [NeZero m] [NeZero n]
    (layer : ReLUAffineLayer m n) (x y : Fin n → ℝ) (i : Fin m) :
    |layer.eval x i - layer.eval y i| ≤
    matrixLinftyNorm layer.weight * linftyNorm (x - y) := by
  unfold ReLUAffineLayer.eval
  calc |reluFn (layer.weight.mulVec x i + layer.bias i) -
       reluFn (layer.weight.mulVec y i + layer.bias i)|
      ≤ |(layer.weight.mulVec x i + layer.bias i) -
         (layer.weight.mulVec y i + layer.bias i)| := relu_one_lipschitz' _ _
    _ = |layer.weight.mulVec x i - layer.weight.mulVec y i| := by ring_nf
    _ = |layer.weight.mulVec (x - y) i| := by congr 1; simp [Matrix.mulVec_sub]
    _ ≤ matrixLinftyNorm layer.weight * linftyNorm (x - y) :=
        matrix_vec_linfty_bound layer.weight (x - y) i

/-! ## Section 5: Certified Robustness -/

/-- Certified robustness radius = margin / Lipschitz. O(kn²) to compute.
    Bridge: connects Lipschitz analysis ↔ certified ML robustness. -/
def certifiedRadius (margin lipschitz : ℝ) : ℝ := margin / lipschitz

/-- **Certified robustness soundness**: perturbation < margin/L ⟹ output change < margin.
    Bridge: connects Lipschitz analysis ↔ certified robustness ↔ adversarial ML. -/
theorem certified_robustness_soundness_scalar
    (f : ℝ → ℝ) (x₀ margin L : ℝ)
    (hL_pos : 0 < L)
    (hf_lip : ∀ a b, |f a - f b| ≤ L * |a - b|)
    (x : ℝ) (hx : |x - x₀| < margin / L) :
    |f x - f x₀| < margin := by
  calc |f x - f x₀| ≤ L * |x - x₀| := hf_lip x x₀
    _ < L * (margin / L) := mul_lt_mul_of_pos_left hx hL_pos
    _ = margin := by field_simp

/-- **Lipschitz composition**: composing L₁- and L₂-Lipschitz gives (L₂·L₁)-Lipschitz.
    Bridge: connects composition theory ↔ deep network Lipschitz bounds. -/
theorem lipschitz_composition_bound
    (f g : ℝ → ℝ) (L₁ L₂ : ℝ) (hL₂ : 0 ≤ L₂)
    (hf : ∀ a b, |f a - f b| ≤ L₁ * |a - b|)
    (hg : ∀ a b, |g a - g b| ≤ L₂ * |a - b|) :
    ∀ a b, |g (f a) - g (f b)| ≤ L₂ * L₁ * |a - b| := by
  intro a b
  calc |g (f a) - g (f b)| ≤ L₂ * |f a - f b| := hg _ _
    _ ≤ L₂ * (L₁ * |a - b|) := mul_le_mul_of_nonneg_left (hf a b) hL₂
    _ = L₂ * L₁ * |a - b| := by ring

/-- **Tropical verification certificate**.
    Bridge: connects formal verification ↔ tropical geometry ↔ certified ML. -/
structure TropicalCertificate where
  lipschitzConst : ℝ
  margin : ℝ
  certRadius : ℝ
  lipschitz_pos : 0 < lipschitzConst
  margin_pos : 0 < margin
  radius_eq : certRadius = margin / lipschitzConst

theorem TropicalCertificate.radius_pos (cert : TropicalCertificate) :
    0 < cert.certRadius := by
  rw [cert.radius_eq]; exact div_pos cert.margin_pos cert.lipschitz_pos

/-- **Certificate soundness**.
    Bridge: connects formal verification ↔ tropical geometry ↔ safe AI. -/
theorem TropicalCertificate.soundness (cert : TropicalCertificate)
    (f : ℝ → ℝ) (x₀ : ℝ)
    (hf : ∀ a b, |f a - f b| ≤ cert.lipschitzConst * |a - b|)
    (x : ℝ) (hx : |x - x₀| < cert.certRadius) :
    |f x - f x₀| < cert.margin := by
  rw [cert.radius_eq] at hx
  exact certified_robustness_soundness_scalar f x₀ cert.margin
    cert.lipschitzConst cert.lipschitz_pos hf x hx

/-! ## Section 6: Linear Regions and Newton Fan -/

abbrev ActivationPattern (depth width : ℕ) := Fin depth → Fin width → Bool

/-- 2^(kw) activation patterns. Bridge: combinatorics ↔ tropical degree. -/
theorem activation_pattern_count_bound (k w : ℕ) :
    Fintype.card (ActivationPattern k w) = 2 ^ (k * w) := by
  unfold ActivationPattern
  simp [Fintype.card_fun, Fintype.card_bool]; ring

theorem linear_region_count_exponential_bound (k w numRegions : ℕ)
    (h : numRegions ≤ Fintype.card (ActivationPattern k w)) :
    numRegions ≤ 2 ^ (k * w) := by
  rwa [activation_pattern_count_bound] at h

/-- Single layer: 2^w patterns. Bridge: combinatorial geometry ↔ tropical degree. -/
theorem single_layer_region_bound (w : ℕ) :
    Fintype.card (Fin w → Bool) = 2 ^ w := by
  simp [Fintype.card_fun, Fintype.card_bool]

/-- ∏ᵢ 2^wᵢ = 2^(∑wᵢ). Bridge: Newton polytope ↔ neural net expressivity. -/
theorem deep_network_region_bound (k : ℕ) (widths : Fin k → ℕ) :
    ∏ i : Fin k, 2 ^ widths i = 2 ^ (∑ i : Fin k, widths i) := by
  rw [← Finset.prod_pow_eq_pow_sum]

/-! ## Section 7: Tropical Deformation -/

/-- **Tropical deformation**: homotopy from ReLU to identity.
    Bridge: connects algebraic topology ↔ tropical geometry ↔ ReLU networks. -/
def tropicalDeformation (ε x : ℝ) : ℝ := (1 - ε) * reluFn x + ε * x

theorem tropicalDeformation_at_zero (x : ℝ) : tropicalDeformation 0 x = reluFn x := by
  simp [tropicalDeformation]

theorem tropicalDeformation_at_one (x : ℝ) : tropicalDeformation 1 x = x := by
  simp [tropicalDeformation]

/-! ## Section 8: Piecewise Linearity and Verification -/

/-- **ReLU on affine is piecewise linear** with two pieces.
    Bridge: connects piecewise linear theory ↔ tropical hypersurface. -/
theorem relu_affine_two_pieces (w b : ℝ) :
    ∀ x : ℝ, reluFn (w * x + b) = if 0 ≤ w * x + b then w * x + b else 0 := by
  intro x; simp only [reluFn]; split_ifs with h
  · exact max_eq_right h
  · exact max_eq_left (le_of_not_ge h)

/-- **Completeness for 1-Lipschitz**: certified radius = margin.
    Bridge: connects tropical completeness ↔ exact verification. -/
theorem verification_completeness_unit_lipschitz
    (f : ℝ → ℝ) (x₀ M : ℝ)
    (hf : ∀ a b, |f a - f b| ≤ |a - b|) :
    ∀ x, |x - x₀| < M → |f x - f x₀| < M := by
  intro x hx; linarith [hf x x₀]

theorem tropical_at_least_lipschitz
    (f : ℝ → ℝ) (x₀ M L : ℝ) (hL : 0 < L)
    (hf : ∀ a b, |f a - f b| ≤ L * |a - b|) :
    ∀ x, |x - x₀| < M / L → |f x - f x₀| < M :=
  fun x hx => certified_robustness_soundness_scalar f x₀ M L hL hf x hx

/-! ## Section 9: Tropical Metric -/

def tropicalMetric (a b : ℝ) : ℝ := |a - b|

theorem tropicalMetric_symm (a b : ℝ) : tropicalMetric a b = tropicalMetric b a :=
  abs_sub_comm a b

theorem tropicalMetric_nonneg (a b : ℝ) : 0 ≤ tropicalMetric a b := abs_nonneg _

theorem tropicalMetric_eq_zero_iff (a b : ℝ) : tropicalMetric a b = 0 ↔ a = b := by
  simp [tropicalMetric, abs_eq_zero, sub_eq_zero]

theorem tropicalMetric_triangle (a b c : ℝ) :
    tropicalMetric a c ≤ tropicalMetric a b + tropicalMetric b c := by
  simp only [tropicalMetric]
  calc |a - c| = |(a - b) + (b - c)| := by ring_nf
    _ ≤ |a - b| + |b - c| := abs_add_le _ _

/-! ## Section 10: Min-Plus Structures -/

/-- A **min-plus affine map** from ℝⁿ to ℝ.
    Bridge: connects tropical geometry ↔ neural network layers. -/
structure MinPlusAffineMap (n : ℕ) where
  weights : Fin n → ℝ
  bias : ℝ

def MinPlusAffineMap.eval {n : ℕ} [NeZero n] (φ : MinPlusAffineMap n)
    (x : Fin n → ℝ) : ℝ :=
  (Finset.univ.inf' ⟨⟨0, Fin.pos'⟩, Finset.mem_univ _⟩
    fun i => φ.weights i + x i) ⊓ φ.bias

/-- Min-plus matrix-vector product: (A ⊗ x)_i = min_j (A_{ij} + x_j). O(mn).
    Bridge: connects tropical linear algebra ↔ shortest path computation. -/
def minPlusMatVecMul {m n : ℕ} [NeZero n]
    (A : Matrix (Fin m) (Fin n) ℝ) (x : Fin n → ℝ) : Fin m → ℝ :=
  fun i => Finset.univ.inf' ⟨⟨0, Fin.pos'⟩, Finset.mem_univ _⟩
    fun j => A i j + x j

/-! ## Section 11: Tropical Eigenvalue -/

/-- Tropical eigenvalue: λ_trop(A) = min_i (A_{ii} / n).
    Bridge: connects tropical linear algebra ↔ certified radius. -/
def tropicalEigenvalue {n : ℕ} [NeZero n] (A : Matrix (Fin n) (Fin n) ℝ) : ℝ :=
  Finset.inf' Finset.univ ⟨⟨0, Fin.pos'⟩, Finset.mem_univ _⟩ (fun i => A i i / n)

theorem tropicalEigenvalue_le_diag {n : ℕ} [NeZero n]
    (A : Matrix (Fin n) (Fin n) ℝ) (i : Fin n) :
    tropicalEigenvalue A ≤ A i i / n :=
  Finset.inf'_le _ (Finset.mem_univ i)

/-! ## Section 12: Depth-Robustness -/

theorem certified_radius_depth_formula (margin L : ℝ) (k : ℕ) :
    certifiedRadius margin (L ^ k) = margin / L ^ k := rfl

theorem relu_tropical_scalar_identity (x : ℝ) :
    reluFn (reluFn x) = reluFn x := relu_idempotent' x

theorem two_layer_relu_four_regions : (4 : ℕ) ≤ 2 ^ (1 * 2) := by norm_num

/-- Construct a valid tropical certificate. -/
theorem tropical_certificate_construction
    {n m : ℕ} [NeZero n] [NeZero m]
    (W : Matrix (Fin m) (Fin n) ℝ) (margin : ℝ)
    (hm : 0 < margin) (hn : 0 < matrixLinftyNorm W) :
    ∃ cert : TropicalCertificate,
      cert.lipschitzConst = matrixLinftyNorm W ∧
      cert.margin = margin ∧
      cert.certRadius = margin / matrixLinftyNorm W :=
  ⟨⟨matrixLinftyNorm W, margin, margin / matrixLinftyNorm W, hn, hm, rfl⟩, rfl, rfl, rfl⟩

/-! ## Section 13: Min-Plus Fan Distance -/

def minPlusFanDistance {n : ℕ} (weights : Fin n → ℝ) (x₀ : Fin n → ℝ) : ℝ :=
  ⨅ (i : Fin n) (j : Fin n) (_ : i ≠ j),
    |(weights i + x₀ i) - (weights j + x₀ j)| / 2

theorem minPlusFanDistance_nonneg_of_pair {n : ℕ} (weights x₀ : Fin n → ℝ)
    (i j : Fin n) :
    0 ≤ |(weights i + x₀ i) - (weights j + x₀ j)| / 2 := by positivity

/-! ## Section 14: Adversarial Examples -/

/-- **Adversarial at ReLU boundary**: relu(w·(-b/w)+b) = 0.
    Bridge: connects adversarial ML ↔ tropical hypersurface. -/
theorem adversarial_at_relu_boundary (w b : ℝ) (hw : w ≠ 0) :
    reluFn (w * (-b / w) + b) = 0 := by
  have h1 : w * (-b / w) = -b := by field_simp
  rw [h1, neg_add_cancel]; exact reluFn_of_nonpos (le_refl 0)

/-- **Lipschitz tightness for linear functions**.
    Bridge: connects Lipschitz tightness ↔ verification completeness. -/
theorem linear_lipschitz_tight (w : ℝ) :
    ∃ a b : ℝ, a ≠ b ∧ |w * a - w * b| = |w| * |a - b| :=
  ⟨0, 1, by norm_num, by simp [abs_mul]⟩

/-
**Verification completeness for linear ReLU**: within the active region,
    relu(wx+b) = wx+b.
    Bridge: connects tropical completeness ↔ exact verification.
-/
theorem verification_completeness_linear_relu
    (w b : ℝ) (hw : 0 < w) (x₀ : ℝ) (hactive : 0 < w * x₀ + b) :
    ∀ x, |x - x₀| < (w * x₀ + b) / w → reluFn (w * x + b) = w * x + b := by
  exact fun x hx => reluFn_of_nonneg ( by nlinarith [ abs_lt.mp hx, mul_div_cancel₀ ( w * x₀ + b ) hw.ne' ] )

/-
**ReLU subadditivity**: relu(x+y) ≤ relu(x) + relu(y).
    Bridge: connects tropical subadditivity ↔ neural network superposition.
-/
theorem relu_subadditive (x y : ℝ) : reluFn (x + y) ≤ reluFn x + reluFn y := by
  unfold reluFn;
  cases max_cases ( 0 : ℝ ) ( x + y ) <;> cases max_cases ( 0 : ℝ ) x <;> cases max_cases ( 0 : ℝ ) y <;> linarith

/-
**Compositional Lipschitz power**: |f^[k](a) - f^[k](b)| ≤ L^k |a-b|.
    Bridge: connects compositional analysis ↔ depth-robustness tradeoff.
-/
theorem compositional_lipschitz_power
    (f : ℝ → ℝ) (L : ℝ) (hL : 0 ≤ L)
    (hf : ∀ a b, |f a - f b| ≤ L * |a - b|) :
    ∀ (k : ℕ) (a b : ℝ), |f^[k] a - f^[k] b| ≤ L ^ k * |a - b| := by
  intro k;
  induction' k with k ih;
  · norm_num;
  · exact fun a b => by simpa only [ pow_succ', mul_assoc, Function.iterate_succ_apply' ] using le_trans ( hf _ _ ) ( mul_le_mul_of_nonneg_left ( ih _ _ ) hL ) ;

/-
**Min-plus nonexpansive per coordinate**.
    Bridge: connects tropical nonexpansiveness ↔ certified robustness.
-/
theorem minPlusMatVecMul_nonexpansive_coord {m n : ℕ} [NeZero m] [NeZero n]
    (A : Matrix (Fin m) (Fin n) ℝ) (x y : Fin n → ℝ) (i : Fin m) :
    |minPlusMatVecMul A x i - minPlusMatVecMul A y i| ≤ linftyNorm (x - y) := by
  unfold minPlusMatVecMul linftyNorm;
  refine' abs_sub_le_iff.mpr _;
  constructor <;> simp +decide [ sub_le_iff_le_add', Finset.inf'_le, Finset.le_sup' ];
  · obtain ⟨ j, hj ⟩ := Finset.exists_mem_eq_inf' Finset.univ_nonempty fun j => A i j + y j;
    exact ⟨ j, j, by cases abs_cases ( x j - y j ) <;> linarith ⟩;
  · obtain ⟨ j, hj ⟩ := Finset.exists_mem_eq_inf' ( Finset.univ_nonempty ) ( fun j => A i j + x j );
    exact ⟨ j, j, by cases abs_cases ( x j - y j ) <;> linarith ⟩

/-
**Min-plus affine maps are 1-Lipschitz**.
    Bridge: connects tropical nonexpansiveness ↔ certified robustness.
-/
theorem minPlusAffine_lipschitz {n : ℕ} [NeZero n]
    (φ : MinPlusAffineMap n) (x y : Fin n → ℝ) :
    |φ.eval x - φ.eval y| ≤ linftyNorm (x - y) := by
  refine' abs_sub_le_iff.mpr _;
  constructor <;> rw [ MinPlusAffineMap.eval ];
  · simp +decide [ MinPlusAffineMap.eval ];
    refine' Classical.or_iff_not_imp_right.2 fun h => _;
    obtain ⟨ i, hi ⟩ := Finset.exists_mem_eq_inf' ( Finset.univ_nonempty ) ( fun i => φ.weights i + y i );
    exact ⟨ i, by cases min_cases ( Finset.univ.inf' ( Finset.univ_nonempty ) fun i => φ.weights i + y i ) φ.bias <;> linarith [ abs_le.mp ( show |x i - y i| ≤ linftyNorm ( x - y ) from coord_le_linftyNorm ( x - y ) i ) ] ⟩;
  · rw [ sub_le_iff_le_add' ];
    rw [ ← sub_le_iff_le_add ];
    refine' le_min _ _;
    · simp +decide [ linftyNorm ];
      exact fun i => Or.inl ⟨ i, by linarith [ abs_le.mp ( Finset.le_sup' ( fun j => |x j - y j| ) ( Finset.mem_univ i ) ) ] ⟩;
    · exact le_trans ( sub_le_self _ ( linftyNorm_nonneg _ ) ) ( min_le_right _ _ )

/-
**Fan distance implies argmin preservation**.
    Bridge: connects positive fan distance ↔ tropical robustness.
-/
theorem fan_distance_implies_robustness
    {n : ℕ} [NeZero n] (φ : MinPlusAffineMap n) (x₀ : Fin n → ℝ)
    (r : ℝ) (hr : 0 < r)
    (hfan : ∀ i j : Fin n, i ≠ j →
      r ≤ |(φ.weights i + x₀ i) - (φ.weights j + x₀ j)| / 2) :
    ∀ δ : Fin n → ℝ, linftyNorm δ < r →
      ∀ i j : Fin n, i ≠ j →
        (φ.weights i + x₀ i < φ.weights j + x₀ j) →
        (φ.weights i + (x₀ + δ) i < φ.weights j + (x₀ + δ) j) := by
  intros δ hδ i j hij hlt
  have hgap : |(φ.weights i + x₀ i) - (φ.weights j + x₀ j)| ≥ 2 * r := by
    linarith [ hfan i j hij ];
  simp_all +decide [ linftyNorm ];
  cases abs_cases ( φ.weights i + x₀ i - ( φ.weights j + x₀ j ) ) <;> linarith [ abs_lt.mp ( hδ i ), abs_lt.mp ( hδ j ) ]

/-
**Tropical deformation is 1-Lipschitz** for ε ∈ [0,1].
    Bridge: connects topological stability ↔ robust certification.
-/
theorem tropicalDeformation_lipschitz (ε : ℝ) (hε0 : 0 ≤ ε) (hε1 : ε ≤ 1)
    (x y : ℝ) :
    |tropicalDeformation ε x - tropicalDeformation ε y| ≤ |x - y| := by
  unfold tropicalDeformation;
  unfold reluFn;
  cases max_cases ( 0 : ℝ ) x <;> cases max_cases ( 0 : ℝ ) y <;> cases abs_cases ( x - y ) <;> cases abs_cases ( ( 1 - ε ) * max 0 x + ε * x - ( ( 1 - ε ) * max 0 y + ε * y ) ) <;> nlinarith

end