import Mathlib

/-! # CatalogBuild.Computation.Oracles.Advanced

Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 16
-/


noncomputable section

/-- O₁ refines O₂ if every fixed point of O₁ is a fixed point of O₂. -/
def OracleRefines {X : Type*} (O₁ O₂ : X → X) : Prop :=
  ∀ x, O₁ x = x → O₂ x = x




/-- [Section: # CatalogBuild.Computation.Oracles.Advanced
Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 16] -/
theorem oracleRefines_refl {X : Type*} (O : X → X) : OracleRefines O O :=
  fun _ h => h




/-- [Section: # CatalogBuild.Computation.Oracles.Advanced
Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 16] -/
theorem oracleRefines_trans {X : Type*} (O₁ O₂ O₃ : X → X)
    (h₁₂ : OracleRefines O₁ O₂) (h₂₃ : OracleRefines O₂ O₃) :
    OracleRefines O₁ O₃ :=
  fun x hx => h₂₃ x (h₁₂ x hx)




theorem idem_compose_self {X : Type*} (f : X → X) (hf : ∀ x, f (f x) = f x) :
    f ∘ f = f := funext hf




theorem binaryEntropy_nonneg (p : ℝ) (hp0 : 0 < p) (hp1 : p < 1) :
    0 ≤ binaryEntropy p := by
  unfold binaryEntropy;
  split_ifs <;> nlinarith [ Real.logb_neg ( show 1 < 2 by norm_num ) hp0 hp1, Real.logb_neg ( show 1 < 2 by norm_num ) ( show 0 < 1 - p by linarith ) ( show 1 - p < 1 by linarith ) ]




theorem binaryEntropy_half : binaryEntropy (1/2 : ℝ) = 1 := by
  unfold binaryEntropy; norm_num;
  norm_num [ Real.logb_div ]




/-- A constant oracle has a unique fixed point. -/
theorem constant_unique_fixed_point (c : ℝ) :
    ∃! x : ℝ, (fun _ => c) x = x :=
  ⟨c, rfl, fun y hy => hy.symm⟩




/-- Idempotent maps converge in one step. -/
theorem idem_one_step (f : ℝ → ℝ) (hf : ∀ x, f (f x) = f x) (x : ℝ) :
    f x = f (f x) := (hf x).symm




theorem mobius_compose (a₁ b₁ c₁ d₁ a₂ b₂ c₂ d₂ x : ℝ)
    (h : c₂ * x + d₂ ≠ 0)
    (h' : c₁ * mobiusTransform a₂ b₂ c₂ d₂ x + d₁ ≠ 0) :
    mobiusTransform a₁ b₁ c₁ d₁ (mobiusTransform a₂ b₂ c₂ d₂ x) =
    (a₁ * (a₂ * x + b₂) + b₁ * (c₂ * x + d₂)) /
    (c₁ * (a₂ * x + b₂) + d₁ * (c₂ * x + d₂)) := by
  unfold mobiusTransform; simp_all +decide [ mul_comm, mul_assoc, mul_left_comm ] ; ring;
  grind




/-- Meta-oracle: selects the best oracle from a family. -/
structure MetaGeodesicOracle (α : Type*) where
  family : α → (ℝ → ℝ)
  idem : ∀ i, ∀ x, family i (family i x) = family i x
  selectIdx : ℝ → α




/-- Meta-oracle consultation. -/
def MetaGeodesicOracle.consult {α : Type*} (M : MetaGeodesicOracle α) (x : ℝ) : ℝ :=
  M.family (M.selectIdx x) x




/-- With constant selector, meta-oracle is a standard oracle. -/
theorem MetaGeodesicOracle.constant_selector_is_oracle {α : Type*}
    (M : MetaGeodesicOracle α) (i : α) (hsel : ∀ x, M.selectIdx x = i) :
    ∀ x, M.consult (M.consult x) = M.consult x := by
  intro x
  simp only [MetaGeodesicOracle.consult, hsel]
  exact M.idem i _




/-- N-dimensional inverse stereographic projection ℝⁿ → Sⁿ ⊂ ℝⁿ⁺¹. -/
def invStereoN (n : ℕ) (x : Fin n → ℝ) : Fin (n + 1) → ℝ :=
  let s := ∑ i, x i ^ 2
  fun i =>
    if h : i.val < n then
      2 * x ⟨i.val, h⟩ / (1 + s)
    else
      (s - 1) / (1 + s)




theorem invStereoN_on_sphere (n : ℕ) (x : Fin n → ℝ) :
    ∑ i : Fin (n + 1), (invStereoN n x i) ^ 2 = 1 := by
  unfold invStereoN;
  norm_num [ Finset.sum_add_distrib, Finset.mul_sum _ _ _, mul_pow, Finset.sum_mul _ _ _, div_pow ];
  norm_num [ Finset.sum_ite, Fin.sum_univ_castSucc ];
  norm_num [ ← Finset.mul_sum _ _ _, ← Finset.sum_div ];
  rw [ ← add_div, div_eq_iff ] <;> nlinarith [ show 0 ≤ ∑ i, x i ^ 2 from Finset.sum_nonneg fun _ _ => sq_nonneg _ ]




theorem hypothesis_crystallization (f : ℝ → ℝ) (hf : ∀ x, f (f x) = f x) (x : ℝ) :
    f (f x) = f x := hf x

-- H4: Idempotent partition into fixed/non-fixed



theorem idem_partition {α : Type*} [DecidableEq α] (f : α → α)
    (hf : ∀ x, f (f x) = f x) (x : α) :
    f x = x ∨ (f x ≠ x ∧ f (f x) = f x) := by
  by_cases h : f x = x
  · exact Or.inl h
  · exact Or.inr ⟨h, hf x⟩




end