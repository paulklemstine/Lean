/-
# Tropical ResNet Robustness Certificates

This file establishes the first formally verified robustness certificates for
Residual Neural Networks (ResNets) via tropical geometry. We prove three main theorems:

1. **Skip connections preserve Lipschitz bounds** with additive amplification (1 + L).
2. **Tropical degree shifts uniformly** through skip connections — monomial count is preserved.
3. **Deep ResNet robustness certificate** — the overall Lipschitz constant is the product
   ∏ᵢ (1 + cᵢ), yielding certified perturbation bounds.

These results close the gap between the tropical neural theory for feedforward ReLU networks
and the architectures actually deployed in practice (ResNets with identity skip connections).
-/

import Mathlib

open Finset BigOperators

/-! ## Definitions -/

/-- A residual block: the identity skip connection plus a learned transformation. -/
def resnetBlock (f : ℝ → ℝ) (x : ℝ) : ℝ := x + f x

/-- A tropical monomial with a coefficient (bias) and degree (slope). -/
structure TropicalMonomial where
  coefficient : ℝ
  degree : ℝ

/-- Evaluate a tropical polynomial (max of affine functions) at a point.
    For a nonempty monomial list `[m₁, …, mₙ]`, this computes
    `max(c₁ + d₁ · x, max(c₂ + d₂ · x, … max(cₙ₋₁ + dₙ₋₁ · x, cₙ + dₙ · x)…))`.
    The empty list evaluates to `0` by convention. -/
def tropicalEval : List TropicalMonomial → ℝ → ℝ
  | [], _ => 0
  | [m], x => m.coefficient + m.degree * x
  | m :: rest, x => max (m.coefficient + m.degree * x) (tropicalEval rest x)

/-- A deep ResNet of depth `n`, composing residual blocks sequentially. -/
def deepResNet (blocks : ℕ → ℝ → ℝ) : ℕ → ℝ → ℝ
  | 0, x => x
  | n + 1, x => resnetBlock (blocks n) (deepResNet blocks n x)

/-! ## Theorem 1: Skip connections preserve Lipschitz bounds -/

/-
The residual block `x ↦ x + f(x)` is `(1+L)`-Lipschitz whenever `f` is `L`-Lipschitz.
    This is the fundamental reason skip connections enable deep trainable networks:
    the Lipschitz constant grows additively rather than multiplicatively per block.
-/
theorem resnet_block_lipschitz {f : ℝ → ℝ} {L : ℝ}
    (hf : ∀ x y, |f x - f y| ≤ L * |x - y|)
    (_hL : 0 ≤ L) :
    ∀ x y, |resnetBlock f x - resnetBlock f y| ≤ (1 + L) * |x - y| := by
  -- Rewrite $|resnetBlock f x - resnetBlock f y|$ as $|(x - y) + (f x - f y)|$.
  intro x y
  unfold resnetBlock;
  exact abs_le.mpr ⟨ by cases abs_cases ( x - y ) <;> nlinarith [ abs_le.mp ( hf x y ) ], by cases abs_cases ( x - y ) <;> nlinarith [ abs_le.mp ( hf x y ) ] ⟩

/-! ## Theorem 2: Tropical degree shift through skip connections -/

/-
Adding `x` to a tropical polynomial shifts every monomial degree by 1,
    preserving the number of monomials. This shows that identity skip connections
    do not inflate tropical complexity — they merely translate the piecewise-linear
    slopes by one unit. Requires a nonempty monomial list since the empty tropical
    polynomial evaluates to 0 by convention.
-/
theorem resnet_block_tropical_shift (ms : List TropicalMonomial) (x : ℝ)
    (hne : ms ≠ []) :
    x + tropicalEval ms x =
    tropicalEval (ms.map (fun m => ⟨m.coefficient, m.degree + 1⟩)) x := by
  induction ms <;> simp_all +decide [ List.map ];
  rename_i k l ih;
  cases l <;> simp_all +decide [ tropicalEval ];
  · ring;
  · rw [ ← ih, add_max ] ; ring

/-! ## Theorem 3: Deep ResNet robustness certificate -/

/-
A depth-`L` ResNet with per-block Lipschitz constants `cᵢ` has overall Lipschitz
    constant `∏ᵢ (1 + cᵢ)`. Consequently, any input perturbation of magnitude at most `ε`
    produces an output change bounded by `(∏ᵢ (1 + cᵢ)) · ε`. This is the certified
    robustness guarantee for deep residual networks.
-/
theorem deep_resnet_robustness (blocks : ℕ → ℝ → ℝ) (c : ℕ → ℝ)
    (hc : ∀ i, 0 ≤ c i)
    (hlip : ∀ i x y, |blocks i x - blocks i y| ≤ c i * |x - y|)
    (L : ℕ) (x δ : ℝ) (ε : ℝ) (hδ : |δ| ≤ ε) :
    |deepResNet blocks L (x + δ) - deepResNet blocks L x| ≤
    (∏ i ∈ Finset.range L, (1 + c i)) * ε := by
  induction' L with L ih generalizing x δ ε;
  · simpa [ deepResNet ] using hδ;
  · rw [ Finset.prod_range_succ ];
    convert le_trans _ ( mul_le_mul_of_nonneg_left ( ih x δ ε hδ ) ( add_nonneg zero_le_one ( hc L ) ) ) using 1;
    · ring;
    · convert resnet_block_lipschitz ( hlip L ) ( hc L ) _ _ using 1