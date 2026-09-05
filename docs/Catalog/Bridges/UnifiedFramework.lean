import Mathlib

/-! # CatalogBuild.Bridges.UnifiedFramework

Auto-generated from theorem catalog database.
Domain: Bridges
Declarations: 26
-/

noncomputable section

/-- The rectified linear unit.  (Restated here from `Shared/NeuralCoding/Relu.lean`;
the auto-generated file used it without carrying the definition along.) -/
def relu (x : ℝ) : ℝ := max x 0

/-- ReLU is monotone: preserves the tropical order. -/
theorem relu_monotone : Monotone relu :=
  fun _ _ h => max_le_max h le_rfl

/-- Maslov deformed addition (the quantum-tropical interpolation). -/
def maslovAdd (ε : ℝ) (x y : ℝ) : ℝ :=
  ε * Real.log (Real.exp (x / ε) + Real.exp (y / ε))

/-- Maslov addition is commutative (quantum respects symmetry). -/
theorem maslov_comm (ε : ℝ) (x y : ℝ) :
    maslovAdd ε x y = maslovAdd ε y x := by
  simp [maslovAdd, add_comm]

/-- LogSumExp is bounded above by max + log 2 (the quantum correction is bounded). -/
theorem logsumexp_le_max_plus_log2 (x y : ℝ) :
    Real.log (Real.exp x + Real.exp y) ≤ max x y + Real.log 2 := by
  rw [Real.log_le_iff_le_exp (by positivity), Real.exp_add,
      Real.exp_log (by positivity : (0:ℝ) < 2)]
  have hx := le_max_left x y
  have hy := le_max_right x y
  have := Real.exp_le_exp.2 hx
  have := Real.exp_le_exp.2 hy
  linarith

/-- LogSumExp dominates the max (the tropical limit is a lower bound). -/
theorem logsumexp_ge_max (x y : ℝ) :
    max x y ≤ Real.log (Real.exp x + Real.exp y) := by
  have h : Real.exp (max x y) ≤ Real.exp x + Real.exp y := by
    rcases le_total x y with hxy | hxy
    · rw [max_eq_right hxy]; nlinarith [Real.exp_pos x]
    · rw [max_eq_left hxy]; nlinarith [Real.exp_pos y]
  exact (Real.le_log_iff_exp_le (by positivity)).mpr h

/-- The LogSumExp sandwich: max ≤ LSE ≤ max + log 2.
This is the fundamental bound showing tropical = quantum up to log 2. -/
theorem logsumexp_sandwich (x y : ℝ) :
    max x y ≤ Real.log (Real.exp x + Real.exp y) ∧
    Real.log (Real.exp x + Real.exp y) ≤ max x y + Real.log 2 :=
  ⟨logsumexp_ge_max x y, logsumexp_le_max_plus_log2 x y⟩

/-- If e is idempotent, so is 1-e (the complement). -/
theorem karoubi_complement {R : Type*} [Ring R] (e : R) (he : e * e = e) :
    (1 - e) * (1 - e) = 1 - e := by
  have h1 : e * (1 - e) = 0 := by rw [mul_sub, mul_one, he, sub_self]
  calc (1 - e) * (1 - e) = 1 * (1 - e) - e * (1 - e) := by rw [sub_mul]
    _ = (1 - e) - 0 := by rw [one_mul, h1]
    _ = 1 - e := by rw [sub_zero]

/-- Orthogonality: e·(1-e) = 0 for any idempotent e. -/
theorem karoubi_orthogonal {R : Type*} [Ring R] (e : R) (he : e * e = e) :
    e * (1 - e) = 0 := by
  rw [mul_sub, mul_one, he, sub_self]

/-- Completeness: e + (1-e) = 1 (the idempotent decomposition is exhaustive). -/
theorem karoubi_complete {R : Type*} [Ring R] (e : R) :
    e + (1 - e) = 1 := by
  rw [add_sub_cancel]

/-- Complex norm-squared is a sum of two squares (Pythagorean identity). -/
theorem complex_norm_sq_pythagorean (z : ℂ) :
    Complex.normSq z = z.re ^ 2 + z.im ^ 2 := by
  simp [Complex.normSq_apply, sq]

/-- Sum of two squares is non-negative (the norm is real-valued). -/
theorem sum_sq_nonneg (a b : ℝ) : 0 ≤ a ^ 2 + b ^ 2 := by positivity

/-- Berggren matrix M₁ acting on Euclid parameters. -/
def berggrenM₁ : Matrix (Fin 2) (Fin 2) ℤ := !![2, -1; 1, 0]

/-- Berggren matrix M₃. -/
def berggrenM₃ : Matrix (Fin 2) (Fin 2) ℤ := !![1, 2; 0, 1]

/-- M₁ has determinant 1 — it lies in SL₂(ℤ). -/
theorem berggren_M1_det : Matrix.det berggrenM₁ = 1 := by
  simp [berggrenM₁, Matrix.det_fin_two]

/-- M₃ has determinant 1 — it lies in SL₂(ℤ). -/
theorem berggren_M3_det : Matrix.det berggrenM₃ = 1 := by
  simp [berggrenM₃, Matrix.det_fin_two]

/-- M₃ is a parabolic element (a shear / unipotent matrix). -/
theorem berggren_M3_parabolic : berggrenM₃ - 1 = !![0, 2; 0, 0] := by
  ext i j; fin_cases i <;> fin_cases j <;> simp [berggrenM₃]

/-- The Pythagorean quadratic form Q(a,b,c) = a² + b² - c². -/
def pythagQ (v : Fin 3 → ℤ) : ℤ := v 0 ^ 2 + v 1 ^ 2 - v 2 ^ 2

/-- The primitive triple (3,4,5) satisfies Q = 0. -/
theorem root_triple_pythagorean : pythagQ ![3, 4, 5] = 0 := by
  native_decide

/-- 1D stereographic projection (circle to line). -/
def stereo1D (x : ℝ) : ℝ := 2 * x / (1 + x ^ 2)

/-- The denominator 1 + x² is always positive. -/
theorem stereo_denom_pos (x : ℝ) : 0 < 1 + x ^ 2 := by positivity

/-- |stereo1D(x)| ≤ 1: the stereographic image lives in [-1, 1]. -/
theorem stereo1D_bounded (x : ℝ) : |stereo1D x| ≤ 1 := by
  rw [stereo1D, abs_div, abs_of_pos (by positivity : (0:ℝ) < 1 + x ^ 2)]
  rw [div_le_one (by positivity)]
  rw [abs_le]
  constructor <;> nlinarith [sq_nonneg x, sq_nonneg (x - 1), sq_nonneg (x + 1)]

/-- stereo1D(0) = 0: the origin maps to itself. -/
theorem stereo1D_zero : stereo1D 0 = 0 := by simp [stereo1D]

/-- Exponential growth of regions with depth. -/
theorem depth_region_growth (d : ℕ) (hd : 1 ≤ d) : 2 ^ d ≥ d + 1 := by
  induction d with
  | zero => omega
  | succ n ih =>
    cases n with
    | zero => simp
    | succ m =>
      calc 2 ^ (m + 2) = 2 * 2 ^ (m + 1) := by ring
        _ ≥ 2 * (m + 2) := by omega
        _ = (m + 2) + (m + 2) := by ring
        _ ≥ (m + 2) + 1 := by omega

/-- Number of idempotents in ℤ/nℤ. -/
def idempotentCount (n : ℕ) [NeZero n] : ℕ :=
  (Finset.univ.filter (fun e : ZMod n => e * e = e)).card

/-- ℤ/2ℤ has exactly 2 idempotents (0 and 1). -/
theorem idempotent_count_2 : idempotentCount 2 = 2 := by native_decide

/-- ℤ/6ℤ has exactly 4 idempotents (0, 1, 3, 4). -/
theorem idempotent_count_6 : idempotentCount 6 = 4 := by native_decide

/-- ℤ/30ℤ has exactly 8 idempotents. -/
theorem idempotent_count_30 : idempotentCount 30 = 8 := by native_decide

end