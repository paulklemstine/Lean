/-! # CatalogBuild.Speculative.RosettaStone.Applications

Auto-generated from theorem catalog database.
Domain: Speculative/RosettaStone
Declarations: 10
-/

import Mathlib

noncomputable section

/-- Tropical shortest path: min is associative and idempotent. -/
theorem tropical_path_idempotent (a b c : ℝ) :
    min (min a b) c = min a (min b c) := min_assoc a b c

/-- min is idempotent. -/

theorem min_idempotent' (a : ℝ) : min a a = a := min_self a

/-! ## Application 2: Phylogenetics -/

/-- The four-point condition for tree metrics. -/

def is_tree_metric {X : Type*} (d : X → X → ℝ) : Prop :=
  ∀ a b c e : X,
    d a b + d c e ≤ max (d a c + d b e) (d a e + d b c)

/-! ## Application 3: Quantum Error Correction -/

/-- A quantum error correcting code is defined by a projection. -/

structure QECC (n : ℕ) where
  projection : Matrix (Fin n) (Fin n) ℂ
  is_projection : projection * projection = projection

/-- The code space dimension = trace of the projection. -/

noncomputable def code_dimension {n : ℕ} (C : QECC n) : ℂ :=
  Matrix.trace C.projection

/-
PROBLEM
Complementary code: (I - P) defines the "error space."

PROVIDED SOLUTION
Expand (1 - P)(1 - P) = 1 - P - P + P*P = 1 - P - P + P = 1 - P using is_projection: P*P = P. This is in a matrix ring which may not be commutative, but we have sub_mul, mul_sub available.
-/

theorem complement_code {n : ℕ} (C : QECC n) :
    (1 - C.projection) * (1 - C.projection) = 1 - C.projection := by
  norm_num [ sub_mul, mul_sub, C.is_projection ]

/-- Two orthogonal codes: if P₁ + P₂ = 1 then P₂ = 1 - P₁. -/

theorem orthogonal_codes_sum {n : ℕ} (C₁ C₂ : QECC n)
    (hsum : C₁.projection + C₂.projection = 1) :
    C₂.projection = 1 - C₁.projection := by
  have h := hsum
  have : C₂.projection = 1 - C₁.projection := by
    rw [← h]; simp [add_sub_cancel_left]
  exact this

/-! ## Application 4: Machine Learning -/

/-- ReLU is idempotent on non-negative inputs. -/

theorem pca_projection_property {n : ℕ} (P : Matrix (Fin n) (Fin n) ℝ)
    (hP : P * P = P) (x : Fin n → ℝ) :
    P.mulVec (P.mulVec x) = P.mulVec x := by
  simp [Matrix.mulVec_mulVec, hP]

/-! ## Application 5: CRT-based Parallel Computation -/

/-- CRT idempotents enable parallel computation. -/

theorem crt_shares_sum_to_one :
    ∀ e₀ e₁ : ZMod 6, e₀ * e₀ = e₀ → e₁ * e₁ = e₁ →
    e₀ * e₁ = 0 → e₀ + e₁ = 1 →
    ∀ x : ZMod 6, x = e₀ * x + e₁ * x := by
  intro e₀ e₁ _ _ _ h_sum x
  rw [← add_mul, h_sum, one_mul]

/-- ℤ/6ℤ has 4 idempotents (2² since 6 = 2·3). -/

theorem zmod6_idem_count :
    (Finset.univ.filter (fun e : ZMod 6 => e * e = e)).card = 4 := by decide


end
