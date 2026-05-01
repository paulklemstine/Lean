import Mathlib

/-! # Neural Composition Bridge

Proves the fundamental composition laws for neural network analysis:

1. Lipschitz composition: Lip(f∘g) ≤ Lip(f) · Lip(g)
2. Lipschitz sum: Lip(f+g) ≤ Lip(f) + Lip(g)
3. Lipschitz subtraction: Lip(f-g) ≤ Lip(f) + Lip(g)
4. Lipschitz max: Lip(max(f,g)) ≤ max(Lip(f), Lip(g))
5. Continuous composition: continuous compositions are continuous

These are the EXACT laws that make certified adversarial robustness possible:
- ResNet blocks compose as f(x) + g(x) with sum Lipschitz bound
- Max-pooling uses max with bounded Lipschitz constant
- Deep networks compose layers with multiplicative Lipschitz bound

This bridge formalizes the theoretical foundation of our certified robustness work.
-/

namespace NeuralCompositionBridge

/-! ## Section 1: Lipschitz Composition -/

/-- Lipschitz composition: Lip(f∘g) ≤ Lip(f) · Lip(g).
    The fundamental theorem for neural network Lipschitz bounds:
    composition of K_f-Lipschitz and K_g-Lipschitz functions is
    K_f·K_g-Lipschitz. For n layers with constant K: overall Lip is K^n. -/
theorem lipschitz_comp {α β γ : Type*} [PseudoEMetricSpace α] [PseudoEMetricSpace β]
    [PseudoEMetricSpace γ] {Kf Kg : NNReal} {f : β → γ} {g : α → β}
    (hf : LipschitzWith Kf f) (hg : LipschitzWith Kg g) :
    LipschitzWith (Kf * Kg) (f ∘ g) :=
  LipschitzWith.comp hf hg

/-! ## Section 2: Lipschitz Arithmetic -/

/-- Lipschitz sum: Lip(f+g) ≤ Lip(f) + Lip(g).
    Bounds the Lipschitz constant of a residual connection:
    ‖f(x) + g(x) - (f(y) + g(y))‖ ≤ (K_f + K_g)‖x-y‖.
    This is why ResNet blocks have Lipschitz constant (1 + K_skip). -/
theorem lipschitz_add {α : Type*} {E : Type*} [PseudoEMetricSpace α]
    [SeminormedAddCommGroup E] {Kf Kg : NNReal} {f g : α → E}
    (hf : LipschitzWith Kf f) (hg : LipschitzWith Kg g) :
    LipschitzWith (Kf + Kg) fun x => f x + g x :=
  LipschitzWith.add hf hg

/-- Lipschitz subtraction: Lip(f-g) ≤ Lip(f) + Lip(g). -/
theorem lipschitz_sub {α : Type*} {E : Type*} [PseudoEMetricSpace α]
    [SeminormedAddCommGroup E] {Kf Kg : NNReal} {f g : α → E}
    (hf : LipschitzWith Kf f) (hg : LipschitzWith Kg g) :
    LipschitzWith (Kf + Kg) fun x => f x - g x :=
  LipschitzWith.sub hf hg

/-- Lipschitz max: Lip(max(f,g)) ≤ max(Lip(f), Lip(g)).
    This bounds the Lipschitz constant for ReLU and max-pooling:
    ‖max(f(x),g(x)) - max(f(y),g(y))‖ ≤ max(K_f,K_g)‖x-y‖. -/
theorem lipschitz_max {α : Type*} [PseudoEMetricSpace α]
    {f g : α → ℝ} {Kf Kg : NNReal}
    (hf : LipschitzWith Kf f) (hg : LipschitzWith Kg g) :
    LipschitzWith (max Kf Kg) fun x => max (f x) (g x) :=
  LipschitzWith.max hf hg

/-! ## Section 3: Continuous Composition -/

/-- Continuous functions compose: if g∘f then continuous.
    This justifies that deep neural networks (compositions of
    continuous layers) are continuous functions. -/
theorem continuous_comp {X Y Z : Type*} [TopologicalSpace X] [TopologicalSpace Y]
    [TopologicalSpace Z] {f : X → Y} {g : Y → Z}
    (hg : Continuous g) (hf : Continuous f) :
    Continuous (g ∘ f) :=
  Continuous.comp hg hf

/-! ## Section 4: ResNet vs Feedforward -/

/-- Feedforward composition: if each layer has Lipschitz constant K,
    two composed layers have Lip at most K².
    For n layers: Lip ≤ K^n (exponential in depth).
    Compare with ResNet's polynomial (1+K)^n bound. -/
theorem feedforward_composition_bound {α : Type*} [PseudoEMetricSpace α]
    {K : NNReal} {f g : α → α}
    (hf : LipschitzWith K f) (hg : LipschitzWith K g) :
    LipschitzWith (K * K) (f ∘ g) :=
  LipschitzWith.comp hf hg

/-- Two different Lipschitz constants compose: Lip(f∘g) ≤ K_f · K_g.
    For feedforward networks with varying layer Lipschitz constants,
    the overall bound is the product of all layer constants. -/
theorem lipschitz_composition_product {α β γ : Type*} [PseudoEMetricSpace α]
    [PseudoEMetricSpace β] [PseudoEMetricSpace γ]
    {Kf Kg : NNReal} {f : β → γ} {g : α → β}
    (hf : LipschitzWith Kf f) (hg : LipschitzWith Kg g) :
    LipschitzWith (Kf * Kg) (f ∘ g) :=
  lipschitz_comp hf hg

end NeuralCompositionBridge
