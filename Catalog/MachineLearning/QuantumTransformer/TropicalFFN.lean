/-! # CatalogBuild.MachineLearning.QuantumTransformer.TropicalFFN

Auto-generated from theorem catalog database.
Domain: MachineLearning/QuantumTransformer
Declarations: 11
-/

import Mathlib

noncomputable section

/-- [Section: # CatalogBuild.MachineLearning.QuantumTransformer.TropicalFFN
Auto-generated from theorem catalog database.
Domain: MachineLearning/QuantumTransformer
Declarations: 11] -/
theorem tropical_add_identity (a neg_inf : ℝ) (h : neg_inf ≤ a) :
    max a neg_inf = a := max_eq_left h



theorem single_layer_regions (d : ℕ) : d + 1 ≥ 1 := by omega



theorem multi_layer_regions_bound (d L : ℕ) :
    1 ≤ (d + 1) ^ L :=
  Nat.one_le_pow L (d + 1) (by omega)



theorem deep_region_exponential (d L : ℕ) (hd : 2 ≤ d) (hL : 1 ≤ L) :
    d * L < (d + 1) ^ L := by
  induction hL <;> simp_all +decide [ pow_succ' ];
  nlinarith [ Nat.zero_le ( d * ‹_› ) ]



/-- The crystallization loss for a ReLU neuron: small when |x| is large. -/
def relu_crystal_loss (x : ℝ) : ℝ := 1 / (1 + x ^ 2)



theorem relu_crystal_loss_pos (x : ℝ) : 0 < relu_crystal_loss x := by
  unfold relu_crystal_loss; positivity



theorem relu_crystal_loss_le_one (x : ℝ) : relu_crystal_loss x ≤ 1 := by
  unfold relu_crystal_loss
  rw [div_le_one (by positivity)]
  linarith [sq_nonneg x]



theorem relu_crystal_loss_vanishes (x : ℝ) (hx : 1 ≤ |x|) :
    relu_crystal_loss x ≤ 1 / 2 := by
  unfold relu_crystal_loss
  have h1 : 1 ≤ x ^ 2 := by nlinarith [sq_abs x]
  have h2 : (2 : ℝ) ≤ 1 + x ^ 2 := by linarith
  gcongr



def is_tropical_monomial (f : ℝ → ℝ) : Prop :=
  ∃ a b : ℝ, ∀ x, f x = a * x + b



theorem const_is_monomial (c : ℝ) : is_tropical_monomial (fun _ => c) :=
  ⟨0, c, fun _ => by ring⟩



theorem affine_is_monomial (a b : ℝ) : is_tropical_monomial (fun x => a * x + b) :=
  ⟨a, b, fun _ => rfl⟩



end
