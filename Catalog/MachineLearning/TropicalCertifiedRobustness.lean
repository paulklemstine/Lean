/-
# Tropical Certified Robustness — Max-Plus Spectral Composition and Layerwise
  Verification Bounds for Deep ReLU Networks

This module establishes tropical (max-plus) algebra as the canonical framework for
certified robustness of deep piecewise-linear (ReLU) networks. ReLU(x) = max(0, x)
is a tropical operation, so every ReLU layer is a tropical-affine map, and deep
network composition is fundamentally tropical.

Bridge: connects tropical geometry ↔ operator theory ↔ certified ML ↔ safety verification
-/
import Mathlib

open Finset BigOperators

noncomputable section

/-! ## Section 1: Tropical Spectral Bound (ℓ∞ Operator Norm) -/

/-- The ℓ∞ operator norm of a matrix: max row-sum of absolute values.
    Bridge: connects tropical geometry ↔ operator theory ↔ certified ML. -/
def tropicalRowNorm {m n : ℕ} [NeZero m] (A : Matrix (Fin m) (Fin n) ℝ) : ℝ :=
  Finset.sup' Finset.univ ⟨⟨0, Fin.pos'⟩, Finset.mem_univ _⟩
    (fun i => ∑ j, |A i j|)

theorem tropical_row_norm_nonneg {m n : ℕ} [NeZero m]
    (A : Matrix (Fin m) (Fin n) ℝ) : 0 ≤ tropicalRowNorm A := by
  unfold tropicalRowNorm
  have h0 : (⟨0, Fin.pos'⟩ : Fin m) ∈ Finset.univ := Finset.mem_univ _
  exact le_trans (Finset.sum_nonneg (fun j _ => abs_nonneg (A ⟨0, Fin.pos'⟩ j)))
    (Finset.le_sup' (fun i => ∑ j, |A i j|) h0)

/-! ## Section 2: ReLU as a Tropical Operation -/

/-- ReLU activation: relu(x) = max(0, x). -/
def relu' (x : ℝ) : ℝ := max 0 x

/-- **ReLU is 1-Lipschitz**: |max(0,a) - max(0,b)| ≤ |a - b|.
    Bridge: connects contraction mapping theory ↔ tropical geometry ↔ certified ML. -/
theorem relu_one_lipschitz (a b : ℝ) : |relu' a - relu' b| ≤ |a - b| := by
  unfold relu'
  rw [show max 0 a = max a 0 from max_comm 0 a, show max 0 b = max b 0 from max_comm 0 b]
  exact abs_max_sub_max_le_abs a b 0

theorem relu'_nonneg (x : ℝ) : 0 ≤ relu' x := le_max_left 0 x

theorem relu'_of_nonneg {x : ℝ} (hx : 0 ≤ x) : relu' x = x := max_eq_right hx

theorem relu'_of_nonpos {x : ℝ} (hx : x ≤ 0) : relu' x = 0 := max_eq_left hx

/-- **ReLU idempotence**: relu(relu(x)) = relu(x).
    Bridge: connects tropical idempotent algebra ↔ depth reduction. -/
theorem relu_idempotent (x : ℝ) : relu' (relu' x) = relu' x := by
  unfold relu'
  rcases le_or_gt 0 x with hx | hx
  · simp [max_eq_right hx]
  · simp [max_eq_left (le_of_lt hx)]

/-- **ReLU distributes over max**: relu(max(a,b)) = max(relu(a), relu(b)).
    Bridge: connects tropical semiring axioms ↔ activation theory. -/
theorem relu_max_distrib (a b : ℝ) : relu' (max a b) = max (relu' a) (relu' b) := by
  unfold relu'
  exact (max_max_max_comm 0 0 a b).symm ▸ by simp [max_self]

theorem relu_monotone {a b : ℝ} (h : a ≤ b) : relu' a ≤ relu' b :=
  max_le_max_left 0 h

/-! ## Section 3: ℓ∞ Norm and Matrix-Vector Bounds -/

/-- ℓ∞ norm of a finite vector. -/
def linfNorm {n : ℕ} [NeZero n] (x : Fin n → ℝ) : ℝ :=
  Finset.sup' Finset.univ ⟨⟨0, Fin.pos'⟩, Finset.mem_univ _⟩ (fun j => |x j|)

theorem linfNorm_nonneg {n : ℕ} [NeZero n] (x : Fin n → ℝ) :
    0 ≤ linfNorm x := by
  exact le_trans (abs_nonneg _)
    (Finset.le_sup' (fun j => |x j|) (Finset.mem_univ (⟨0, Fin.pos'⟩ : Fin n)))

theorem le_linfNorm {n : ℕ} [NeZero n] (x : Fin n → ℝ) (j : Fin n) :
    |x j| ≤ linfNorm x :=
  Finset.le_sup' (fun j => |x j|) (Finset.mem_univ j)

/-- Each coordinate of Ax bounded by row sum times ‖x‖∞. -/
theorem matrix_vec_coord_bound {m n : ℕ} [NeZero n]
    (A : Matrix (Fin m) (Fin n) ℝ) (x : Fin n → ℝ) (i : Fin m) :
    |A.mulVec x i| ≤ (∑ j, |A i j|) * linfNorm x := by
  simp only [Matrix.mulVec, dotProduct]
  calc |∑ j : Fin n, A i j * x j|
      ≤ ∑ j : Fin n, |A i j * x j| := Finset.abs_sum_le_sum_abs _ _
    _ = ∑ j : Fin n, |A i j| * |x j| := by
        congr 1; ext j; exact abs_mul (A i j) (x j)
    _ ≤ ∑ j : Fin n, |A i j| * linfNorm x := by
        apply Finset.sum_le_sum; intro j _
        exact mul_le_mul_of_nonneg_left (le_linfNorm x j) (abs_nonneg _)
    _ = (∑ j : Fin n, |A i j|) * linfNorm x := (Finset.sum_mul ..).symm

/-- **Tropical row norm bounds matrix-vector**: |(Ax)ᵢ| ≤ ‖A‖ · ‖x‖∞.
    Bridge: connects operator theory ↔ tropical spectral analysis ↔ certified ML. -/
theorem tropical_row_norm_bound_coord {m n : ℕ} [NeZero m] [NeZero n]
    (A : Matrix (Fin m) (Fin n) ℝ) (x : Fin n → ℝ) (i : Fin m) :
    |A.mulVec x i| ≤ tropicalRowNorm A * linfNorm x := by
  calc |A.mulVec x i|
      ≤ (∑ j, |A i j|) * linfNorm x := matrix_vec_coord_bound A x i
    _ ≤ tropicalRowNorm A * linfNorm x := by
        apply mul_le_mul_of_nonneg_right
        · exact Finset.le_sup' (fun i => ∑ j, |A i j|) (Finset.mem_univ i)
        · exact linfNorm_nonneg x

/-! ## Section 4: Submultiplicativity -/

/-
**Submultiplicativity**: ‖A * B‖ ≤ ‖A‖ · ‖B‖.
    Deep network Lipschitz bounds compose via products.
    Bridge: connects tropical geometry ↔ operator theory ↔ certified ML.
-/
theorem tropical_row_norm_submultiplicative {m n p : ℕ} [NeZero m] [NeZero n] [NeZero p]
    (A : Matrix (Fin m) (Fin n) ℝ) (B : Matrix (Fin n) (Fin p) ℝ) :
    tropicalRowNorm (A * B) ≤ tropicalRowNorm A * tropicalRowNorm B := by
  unfold tropicalRowNorm;
  -- For each row i of A*B, we have ∑_k |(AB)_{ik}| ≤ ∑_j |A_{ij}| (∑_k |B_{jk}|).
  have h_row_bound : ∀ i, ∑ k, |(A * B) i k| ≤ ∑ j, |A i j| * (∑ k, |B j k|) := by
    intro i;
    simp +decide only [Matrix.mul_apply, Finset.mul_sum _ _ _];
    refine' le_trans ( Finset.sum_le_sum fun _ _ => Finset.abs_sum_le_sum_abs _ _ ) _;
    exact Finset.sum_comm.le.trans ( Finset.sum_le_sum fun _ _ => Finset.sum_le_sum fun _ _ => by rw [ abs_mul ] );
  simp_all +decide;
  exact fun i => le_trans ( h_row_bound i ) ( by rw [ Finset.sum_mul _ _ _ ] ; exact Finset.sum_le_sum fun j _ => mul_le_mul_of_nonneg_left ( Finset.le_sup' ( fun i => ∑ j, |B i j| ) ( Finset.mem_univ j ) ) ( abs_nonneg _ ) ) |> le_trans <| mul_le_mul_of_nonneg_right ( Finset.le_sup' ( fun i => ∑ j, |A i j| ) ( Finset.mem_univ i ) ) ( Finset.le_sup' ( fun i => ∑ j, |B i j| ) ( Finset.mem_univ ⟨ 0, NeZero.pos n ⟩ ) |> le_trans ( Finset.sum_nonneg fun _ _ => abs_nonneg _ ) )

/-! ## Section 5: Tropical Affine Layers -/

/-- A tropical affine layer: x ↦ max(Ax + b, 0) componentwise. -/
structure TropicalAffineLayer (m n : ℕ) where
  weight : Matrix (Fin m) (Fin n) ℝ
  bias : Fin m → ℝ

/-- Evaluate a tropical affine layer: x ↦ ReLU(Wx + b). -/
def tropicalAffineEval {m n : ℕ} (layer : TropicalAffineLayer m n)
    (x : Fin n → ℝ) : Fin m → ℝ :=
  fun i => relu' (layer.weight.mulVec x i + layer.bias i)

/-
**Single-layer Lipschitz bound** per coordinate.
    Bridge: connects tropical spectral analysis ↔ single-layer verification.
-/
theorem tropical_affine_lipschitz_coord {m n : ℕ} [NeZero m] [NeZero n]
    (layer : TropicalAffineLayer m n) (x y : Fin n → ℝ) (i : Fin m) :
    |tropicalAffineEval layer x i - tropicalAffineEval layer y i| ≤
    tropicalRowNorm layer.weight * linfNorm (x - y) := by
  -- Apply the ReLU Lipschitz property
  have h_relu_lip : |relu' (layer.weight.mulVec x i + layer.bias i) - relu' (layer.weight.mulVec y i + layer.bias i)| ≤ |layer.weight.mulVec x i - layer.weight.mulVec y i| := by
    unfold relu';
    grind;
  exact h_relu_lip.trans ( by simpa [ Matrix.mulVec_sub ] using tropical_row_norm_bound_coord layer.weight ( x - y ) i )

/-! ## Section 6: Composition Lipschitz Theorem -/

/-
**Composition of two Lipschitz functions**: L₂ · L₁ bound.
    Bridge: connects tropical algebra ↔ deep learning ↔ certified robustness.
-/
theorem lipschitz_compose_two
    (f g : ℝ → ℝ) (L₁ L₂ : ℝ) (_hL₁ : 0 ≤ L₁) (hL₂ : 0 ≤ L₂)
    (hf : ∀ a b, |f a - f b| ≤ L₁ * |a - b|)
    (hg : ∀ a b, |g a - g b| ≤ L₂ * |a - b|) :
    ∀ a b, |g (f a) - g (f b)| ≤ L₂ * L₁ * |a - b| := by
  exact fun a b => le_trans ( hg _ _ ) ( by rw [ mul_assoc ] ; exact mul_le_mul_of_nonneg_left ( hf _ _ ) hL₂ )

/-
**Composition of three Lipschitz functions**: L₃ · L₂ · L₁ bound.
    Bridge: connects deep network depth ↔ Lipschitz composition.
-/
theorem lipschitz_compose_three
    (f g h : ℝ → ℝ) (L₁ L₂ L₃ : ℝ)
    (_hL₁ : 0 ≤ L₁) (hL₂ : 0 ≤ L₂) (hL₃ : 0 ≤ L₃)
    (hf : ∀ a b, |f a - f b| ≤ L₁ * |a - b|)
    (hg : ∀ a b, |g a - g b| ≤ L₂ * |a - b|)
    (hh : ∀ a b, |h a - h b| ≤ L₃ * |a - b|) :
    ∀ a b, |h (g (f a)) - h (g (f b))| ≤ L₃ * L₂ * L₁ * |a - b| := by
  intro a b; convert le_trans ( hh _ _ ) ( mul_le_mul_of_nonneg_left ( le_trans ( hg _ _ ) ( mul_le_mul_of_nonneg_left ( hf _ _ ) hL₂ ) ) hL₃ ) using 1 ; ring;

/-! ## Section 7: Tropical Deformation -/

/-- Deformed activation: (1-ε)·max(0,x) + ε·x. At ε=0 → ReLU, ε=1 → identity.
    Bridge: connects algebraic topology ↔ tropical geometry ↔ ReLU networks. -/
def deformedActivation (ε x : ℝ) : ℝ := (1 - ε) * max 0 x + ε * x

theorem deformed_at_zero (x : ℝ) : deformedActivation 0 x = relu' x := by
  simp [deformedActivation, relu']

theorem deformed_at_one (x : ℝ) : deformedActivation 1 x = x := by
  simp [deformedActivation]

/-
**Deformation Lipschitz invariance**: f_ε is 1-Lipschitz for all ε ∈ [0,1].
    Bridge: connects algebraic topology ↔ tropical geometry ↔ certified ML.
-/
theorem relu_tropical_deformation_lipschitz (ε : ℝ) (hε0 : 0 ≤ ε) (hε1 : ε ≤ 1)
    (x y : ℝ) :
    |deformedActivation ε x - deformedActivation ε y| ≤ |x - y| := by
  unfold deformedActivation;
  cases max_cases ( 0 : ℝ ) x <;> cases max_cases ( 0 : ℝ ) y <;> cases abs_cases ( x - y ) <;> cases abs_cases ( ( 1 - ε ) * Max.max 0 x + ε * x - ( ( 1 - ε ) * Max.max 0 y + ε * y ) ) <;> nlinarith

/-! ## Section 8: Certified Robustness Radius -/

/-
**Product of positive reals is positive**.
-/
theorem tropical_product_pos {L : ℕ} (σ : Fin L → ℝ) (hσ : ∀ i, 0 < σ i) :
    0 < ∏ i : Fin L, σ i := by
  exact Finset.prod_pos fun i _ => hσ i

/-
**Certified radius positivity**: δ/(2·∏σᵢ) > 0.
    Bridge: connects tropical optimization ↔ adversarial robustness.
-/
theorem certified_radius_positive {L : ℕ}
    (margin : ℝ) (hMargin : 0 < margin)
    (σ : Fin L → ℝ) (hσ : ∀ i, 0 < σ i) :
    0 < margin / (2 * ∏ i : Fin L, σ i) := by
  exact div_pos hMargin ( mul_pos zero_lt_two ( Finset.prod_pos fun _ _ => hσ _ ) )

/-
**Margin preservation**: Lipschitz perturbation preserves positive margin.
    Bridge: connects tropical verification ↔ autonomous vehicle safety.
-/
theorem margin_degradation_bound
    (f g : ℝ → ℝ) (K : ℝ) (hK : 0 < K)
    (hf : ∀ a b, |f a - f b| ≤ K * |a - b|)
    (hg : ∀ a b, |g a - g b| ≤ K * |a - b|)
    (x margin : ℝ) (_hMargin : 0 < margin)
    (hGap : f x - g x ≥ margin)
    (Δ : ℝ) (hΔ : |Δ| < margin / (2 * K)) :
    f (x + Δ) - g (x + Δ) > 0 := by
  -- By the triangle inequality, we have $|f(x+\Delta) - f(x)| \leq K|\Delta|$ and $|g(x+\Delta) - g(x)| \leq K|\Delta|$.
  have h_triangle : |f (x + Δ) - f x| ≤ K * |Δ| ∧ |g (x + Δ) - g x| ≤ K * |Δ| := by
    exact ⟨ by simpa using hf ( x + Δ ) x, by simpa using hg ( x + Δ ) x ⟩;
  rw [ lt_div_iff₀ ] at hΔ <;> nlinarith [ abs_le.mp h_triangle.1, abs_le.mp h_triangle.2 ]

/-! ## Section 9: Norm for Special Matrices -/

/-
Identity matrix has tropical row norm 1.
    Bridge: connects tropical algebra ↔ neural network initialization.
-/
theorem tropical_norm_identity {n : ℕ} [NeZero n] :
    tropicalRowNorm (1 : Matrix (Fin n) (Fin n) ℝ) = 1 := by
  refine' le_antisymm _ _ <;> norm_num [ tropicalRowNorm ];
  · intro i; erw [ Finset.sum_eq_single i ] <;> simp +decide [ Matrix.one_apply ] ;
    tauto;
  · use 0; norm_num [ Matrix.one_apply ] ;
    rw [ Finset.sum_eq_single 0 ] <;> aesop

/-
Zero matrix has tropical row norm 0.
-/
theorem tropical_norm_zero {m n : ℕ} [NeZero m] :
    tropicalRowNorm (0 : Matrix (Fin m) (Fin n) ℝ) = 0 := by
  unfold tropicalRowNorm;
  norm_num +zetaDelta at *

/-! ## Section 10: Tropical Lipschitz Certificate -/

/-- Tropical Lipschitz certificate: bound + proof of correctness. -/
structure TropicalLipschitzCert {m n : ℕ} [NeZero m] [NeZero n]
    (A : Matrix (Fin m) (Fin n) ℝ) where
  bound : ℝ
  hBound : 0 ≤ bound
  certifies : ∀ x i, |A.mulVec x i| ≤ bound * linfNorm x

/-
Every matrix admits a tropical Lipschitz certificate.
    Bridge: connects tropical optimization ↔ certificate generation ↔ certified ML.
-/
theorem tropical_lipschitz_cert_exists {m n : ℕ} [NeZero m] [NeZero n]
    (A : Matrix (Fin m) (Fin n) ℝ) :
    ∃ cert : TropicalLipschitzCert A, cert.bound = tropicalRowNorm A := by
  use ⟨tropicalRowNorm A, tropical_row_norm_nonneg A, fun x i => tropical_row_norm_bound_coord A x i⟩

/-! ## Section 11: Certified Robustness Radius Structure -/

/-- Certified robustness radius from tropical spectral analysis. -/
structure TropicalCertifiedRadius (L : ℕ) where
  margin : ℝ
  spectral_bounds : Fin L → ℝ
  hMargin : 0 < margin
  hBounds : ∀ i, 0 < spectral_bounds i

def TropicalCertifiedRadius.radius {L : ℕ} (cert : TropicalCertifiedRadius L) : ℝ :=
  cert.margin / (2 * ∏ i : Fin L, cert.spectral_bounds i)

theorem TropicalCertifiedRadius.radius_pos {L : ℕ} (cert : TropicalCertifiedRadius L) :
    0 < cert.radius :=
  certified_radius_positive cert.margin cert.hMargin cert.spectral_bounds cert.hBounds

/-! ## Section 12: Monotonicity -/

/-
Product of spectral bounds is monotone.
    Bridge: connects order theory ↔ tropical arithmetic.
-/
theorem spectral_product_monotone {L : ℕ}
    (σ τ : Fin L → ℝ) (hσ : ∀ i, 0 < σ i) (_ : ∀ i, 0 < τ i)
    (h : ∀ i, σ i ≤ τ i) :
    ∏ i : Fin L, σ i ≤ ∏ i : Fin L, τ i := by
  exact Finset.prod_le_prod ( fun _ _ => le_of_lt ( hσ _ ) ) fun _ _ => h _

/-
Larger spectral bounds → smaller certified radius.
    Bridge: connects network conditioning ↔ adversarial robustness.
-/
theorem certified_radius_monotone_contravariant {L : ℕ}
    (margin : ℝ) (hMargin : 0 < margin)
    (σ τ : Fin L → ℝ) (hσ : ∀ i, 0 < σ i) (_hτ : ∀ i, 0 < τ i)
    (h : ∀ i, σ i ≤ τ i) :
    margin / (2 * ∏ i : Fin L, τ i) ≤ margin / (2 * ∏ i : Fin L, σ i) := by
  gcongr;
  · exact mul_pos zero_lt_two ( Finset.prod_pos fun i _ => hσ i );
  · exact fun i _ => le_of_lt ( hσ i );
  · exact h _

end