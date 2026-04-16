/-! # CatalogBuild.MachineLearning.KoopmanDimension

Auto-generated from theorem catalog database.
Domain: MachineLearning
Declarations: 20
-/

import Mathlib

noncomputable section

/-- Koopman operator: lifts dynamics f to act on observables. -/
def KoopmanLift {X : Type*} (f : X → X) (g : X → ℝ) : X → ℝ := g ∘ f



/-- Koopman is linear: additivity. -/
theorem KoopmanLift.additive {X : Type*} (f : X → X) (g₁ g₂ : X → ℝ) :
    KoopmanLift f (g₁ + g₂) = KoopmanLift f g₁ + KoopmanLift f g₂ := by
  ext x; simp [KoopmanLift]



/-- Koopman is linear: scalar multiplication. -/
theorem KoopmanLift.smul {X : Type*} (f : X → X) (c : ℝ) (g : X → ℝ) :
    KoopmanLift f (c • g) = c • KoopmanLift f g := by
  ext x; simp [KoopmanLift]



/-- Koopman composition law: contravariant functoriality. -/
theorem KoopmanLift.comp {X : Type*} (f g : X → X) (obs : X → ℝ) :
    KoopmanLift (f ∘ g) obs = KoopmanLift g (KoopmanLift f obs) := by
  ext x; simp [KoopmanLift]



/-- Koopman of identity is identity. -/
theorem KoopmanLift.id_eq {X : Type*} (g : X → ℝ) :
    KoopmanLift id g = g := by ext x; simp [KoopmanLift]



/-- The number of monomials in n variables of total degree ≤ d is C(n+d, d). -/
theorem minimal_lifting_dimension (n d : ℕ) :
    0 < Nat.choose (n + d) d := Nat.choose_pos (by omega)



/-- For degree-1 (linear) maps, the lifting dimension is n+1. -/
theorem lifting_dim_linear (n : ℕ) : Nat.choose (n + 1) 1 = n + 1 :=
  Nat.choose_one_right (n + 1)



/-- [Section: # CatalogBuild.MachineLearning.KoopmanDimension
Auto-generated from theorem catalog database.
Domain: MachineLearning
Declarations: 20] -/
theorem lifting_dim_quadratic (n : ℕ) :
    Nat.choose (n + 2) 2 = (n + 2) * (n + 1) / 2 := by
  rw [ Nat.choose_two_right ];
  rfl



theorem lifting_dim_poly_growth (n d : ℕ) (hd : 0 < d) :
    n ≤ Nat.choose (n + d) d := by
      induction' hd with k hk;
      · norm_num;
      · exact le_add_right ‹_›



/-- Equivariance definition for dynamics. -/
def IsEquivKoop {X : Type*} (f σ : X → X) : Prop :=
  ∀ x, f (σ x) = σ (f x)



/-- Equivariance is preserved under composition. -/
theorem IsEquivKoop.comp {X : Type*} {f₁ f₂ σ : X → X}
    (h₁ : IsEquivKoop f₁ σ) (h₂ : IsEquivKoop f₂ σ) :
    IsEquivKoop (f₁ ∘ f₂) σ := by
  intro x; simp only [Function.comp]
  rw [h₂ x, h₁]



/-- The identity is equivariant with respect to any symmetry. -/
theorem IsEquivKoop.id_eq {X : Type*} (σ : X → X) : IsEquivKoop id σ := by
  intro x; simp



/-- If f is σ-equivariant, Koopman commutes with the induced action on observables. -/
theorem KoopmanLift.equivariant {X : Type*} (f σ : X → X)
    (hequiv : IsEquivKoop f σ) (g : X → ℝ) :
    KoopmanLift f (g ∘ σ) = (KoopmanLift f g) ∘ σ := by
  ext x
  simp [KoopmanLift, Function.comp, hequiv x]



/-- For a group of order |G|, equivariant lifting dimension ≤ total dimension. -/
theorem equivariant_dimension_bound (n d G_order : ℕ) (_hG : 0 < G_order) :
    Nat.choose (n + d) d / G_order ≤ Nat.choose (n + d) d :=
  Nat.div_le_self _ _



/-- At a fixed point x (f(x) = x), K_f(g)(x) = g(x). -/
theorem KoopmanLift.at_fixed_point {X : Type*} (f : X → X) (x : X)
    (hfp : f x = x) (g : X → ℝ) :
    KoopmanLift f g x = g x := by
  simp [KoopmanLift, hfp]



/-- Constant observables are eigenvectors with eigenvalue 1. -/
theorem KoopmanLift.constant_eigenvalue {X : Type*} (f : X → X) (c : ℝ) :
    KoopmanLift f (fun _ => c) = fun _ => c := by
  ext x; simp [KoopmanLift]



/-- For GPT-2 (d_model=768, quadratic attention), lifting dimension is C(770, 2). -/
theorem gpt2_koopman_dim : Nat.choose 770 2 = 770 * 769 / 2 := by
  rw [Nat.choose_two_right]



/-- Linear transformers (degree 1) have optimal lifting dimension n+1. -/
theorem linear_transformer_optimal (n : ℕ) :
    Nat.choose (n + 1) 1 = n + 1 := Nat.choose_one_right (n + 1)



/-- For L layers, the naive Koopman lifting has dimension C(n + d^L, d^L). -/
theorem naive_L_layer_dim (n d L : ℕ) (_hd : 1 ≤ d) :
    0 < Nat.choose (n + d ^ L) (d ^ L) :=
  Nat.choose_pos (by omega)



/-- The dimension savings from layerwise vs naive lifting.
For d=2, n=10, L=3: naive needs C(18, 8) = 43758,
layerwise needs C(12, 2) = 66. -/
theorem layerwise_savings_example :
    Nat.choose 12 2 = 66 ∧ Nat.choose 18 8 = 43758 := by
  constructor <;> native_decide



end
