import Mathlib

/-! # CatalogBuild.Tropical.Langlands.MachineLearning

Auto-generated from theorem catalog database.
Domain: Tropical/Langlands
Declarations: 14
-/

noncomputable section

/-- [Section: # CatalogBuild.Tropical.Langlands.MachineLearning
Auto-generated from theorem catalog database.
Domain: Tropical/Langlands
Declarations: 14] -/
theorem relu_convex (x y t : ℝ) (ht0 : 0 ≤ t) (ht1 : t ≤ 1) :
    relu (t * x + (1 - t) * y) ≤ t * relu x + (1 - t) * relu y := by
  unfold relu;
  cases max_cases ( t * x + ( 1 - t ) * y ) 0 <;> cases max_cases x 0 <;> cases max_cases y 0 <;> nlinarith

/-- A single-layer tropical neural network -/
def tropicalLayer (n m : ℕ) (W : Fin m → Fin n → ℝ) (b : Fin m → ℝ)
    (x : Fin n → ℝ) : Fin m → ℝ :=
  fun i => min (⨅ j : Fin n, W i j + x j) (b i)

/-- The max-plus layer -/
def maxPlusLayer (n m : ℕ) (W : Fin m → Fin n → ℝ) (x : Fin n → ℝ) : Fin m → ℝ :=
  fun i => ⨆ j : Fin n, W i j + x j

/-- The dual (transpose) of a network layer -/
def dualLayer (n m : ℕ) (W : Fin m → Fin n → ℝ) : Fin n → Fin m → ℝ :=
  fun j i => W i j

/-- Double dual is the original -/
theorem dualLayer_involution (n m : ℕ) (W : Fin m → Fin n → ℝ) :
    dualLayer m n (dualLayer n m W) = W := by
  ext i j; simp [dualLayer]

/-- [Section: # CatalogBuild.Tropical.Langlands.MachineLearning
Auto-generated from theorem catalog database.
Domain: Tropical/Langlands
Declarations: 14] -/
theorem dual_preserves_tropDet (n : ℕ) (W : Fin n → Fin n → ℝ) :
    (⨅ σ : Equiv.Perm (Fin n), ∑ i, W i (σ i)) =
    (⨅ σ : Equiv.Perm (Fin n), ∑ i, (dualLayer n n W) i (σ i)) := by
  have h_symm : ∀ σ : Equiv.Perm (Fin n), ∑ i, W i (σ i) = ∑ i, W (σ⁻¹ i) i := by
    exact fun σ => by rw [ ← Equiv.sum_comp σ⁻¹ ] ; simp +decide ;
  rw [ ← Equiv.iInf_comp ( Equiv.inv ( Equiv.Perm ( Fin n ) ) ) ] ; aesop;

/-- L¹ tropical loss function -/
def tropicalLoss (n : ℕ) (target output : Fin n → ℝ) : ℝ :=
  ∑ i : Fin n, |target i - output i|

/-- Tropical loss is non-negative -/
theorem tropicalLoss_nonneg (n : ℕ) (target output : Fin n → ℝ) :
    tropicalLoss n target output ≥ 0 :=
  Finset.sum_nonneg fun i _ => abs_nonneg _

theorem tropicalLoss_zero_iff (n : ℕ) (target output : Fin n → ℝ) :
    tropicalLoss n target output = 0 ↔ target = output := by
  constructor <;> intro h <;> simp_all +decide [ funext_iff, Finset.sum_eq_zero_iff_of_nonneg, abs_nonneg ];
  · exact fun i => sub_eq_zero.mp ( by contrapose! h; exact ne_of_gt <| lt_of_lt_of_le ( by positivity ) <| Finset.single_le_sum ( fun x _ => abs_nonneg ( target x - output x ) ) <| Finset.mem_univ i );
  · exact Finset.sum_eq_zero fun i _ => by simp +decide [ h i ] ;

theorem tropicalLoss_triangle (n : ℕ) (x y z : Fin n → ℝ) :
    tropicalLoss n x z ≤ tropicalLoss n x y + tropicalLoss n y z := by
  unfold tropicalLoss;
  simpa only [ ← Finset.sum_add_distrib ] using Finset.sum_le_sum fun i _ => abs_sub_le _ _ _

/-- A tropical polynomial: sup of affine functions -/
def tropPolynomial (n : ℕ) (coeffs offsets : Fin n → ℝ) (x : ℝ) : ℝ :=
  ⨆ i : Fin n, coeffs i * x + offsets i

theorem tropPolynomial_convex (n : ℕ) [hn : Nonempty (Fin n)]
    (coeffs offsets : Fin n → ℝ)
    (x y t : ℝ) (ht0 : 0 ≤ t) (ht1 : t ≤ 1) :
    tropPolynomial n coeffs offsets (t * x + (1 - t) * y) ≤
    t * tropPolynomial n coeffs offsets x +
    (1 - t) * tropPolynomial n coeffs offsets y := by
  refine' ciSup_le _;
  intro i
  have h_le : coeffs i * x + offsets i ≤ tropPolynomial n coeffs offsets x ∧ coeffs i * y + offsets i ≤ tropPolynomial n coeffs offsets y := by
    exact ⟨ le_ciSup ( Finite.bddAbove_range fun i => coeffs i * x + offsets i ) i, le_ciSup ( Finite.bddAbove_range fun i => coeffs i * y + offsets i ) i ⟩;
  nlinarith

/-- Tropical attention: (min, +) analogue of dot-product attention -/
def tropicalAttention (n d : ℕ)
    (Q K V : Fin n → Fin d → ℝ) : Fin n → Fin d → ℝ :=
  fun i k => ⨅ j : Fin n, (∑ l : Fin d, |Q i l - K j l|) + V j k

/-- ReLU difference gives arbitrary piecewise-linear pieces -/
theorem relu_difference_is_pl (a b : ℝ) (x : ℝ) :
    relu (x - a) - relu (x - b) = max (x - a) 0 - max (x - b) 0 := by
  simp [relu]

end