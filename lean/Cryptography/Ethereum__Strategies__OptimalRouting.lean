/-
  # Optimal Routing Across Multiple AMM Pools
  ## Formal Verification via Convex Optimization

  When trading across multiple constant-product AMM pools, the optimal
  routing problem is a convex optimization: split the input across pools
  to maximize total output.

  ### Key Results:
  - Diminishing marginal output (marginal price decreases)
  - Swap output formula and positivity
  - Price impact is non-negative and monotone
  - Splitting across pools can beat single-pool routing

  ### References:
  - "Optimal Routing for Constant Function Market Makers" (Angeris et al., 2022)
-/

import Mathlib

namespace Ethereum.Routing

/-! ## Pool Model -/

structure Pool where
  x : ℝ
  y : ℝ
  hx : 0 < x
  hy : 0 < y

noncomputable def swapOut (p : Pool) (dx : ℝ) (hdx : 0 < dx) : ℝ :=
  p.y * dx / (p.x + dx)

/-- Marginal price: d/d(dx) [y·dx/(x+dx)] = x·y/(x+dx)² -/
noncomputable def marginalPrice (p : Pool) (dx : ℝ) : ℝ :=
  p.x * p.y / (p.x + dx) ^ 2

/-! ## Concavity of Swap Output -/

/-- Diminishing marginal output: marginal price decreases with input -/
theorem diminishing_marginal_output (p : Pool) (d₁ d₂ : ℝ)
    (hd₁ : 0 < d₁) (hd₂ : 0 < d₂) (hle : d₁ ≤ d₂) :
    marginalPrice p d₂ ≤ marginalPrice p d₁ := by
  unfold marginalPrice
  have h1 : (0 : ℝ) < p.x + d₁ := by linarith [p.hx]
  apply div_le_div_of_nonneg_left (le_of_lt (mul_pos p.hx p.hy)) (sq_pos_of_pos h1)
  exact pow_le_pow_left₀ h1.le (by linarith) 2

/-- Swap output is positive -/
theorem swapOut_pos (p : Pool) (dx : ℝ) (hdx : 0 < dx) :
    0 < swapOut p dx hdx := by
  unfold swapOut
  exact div_pos (mul_pos p.hy hdx) (by linarith [p.hx])

/-- Swap output is less than the reserve -/
theorem swapOut_lt_reserve (p : Pool) (dx : ℝ) (hdx : 0 < dx) :
    swapOut p dx hdx < p.y := by
  unfold swapOut
  rw [div_lt_iff₀ (by linarith [p.hx] : 0 < p.x + dx)]
  nlinarith [p.hx, p.hy]

/-! ## Price Impact -/

/-- Price impact: percentage difference between spot and effective price -/
noncomputable def priceImpact (p : Pool) (dx : ℝ) (hdx : 0 < dx) : ℝ :=
  1 - swapOut p dx hdx / (dx * (p.y / p.x))

/-
Price impact is non-negative
-/
theorem price_impact_nonneg (p : Pool) (dx : ℝ) (hdx : 0 < dx) :
    0 ≤ priceImpact p dx hdx := by
  unfold priceImpact;
  unfold swapOut;
  field_simp;
  rw [ sub_nonneg, div_le_iff₀ ] <;> nlinarith [ p.hx, p.hy ]

/-
Price impact increases with trade size
-/
theorem price_impact_mono (p : Pool) (d₁ d₂ : ℝ)
    (hd₁ : 0 < d₁) (hd₂ : 0 < d₂) (hle : d₁ ≤ d₂) :
    priceImpact p d₁ hd₁ ≤ priceImpact p d₂ hd₂ := by
  unfold priceImpact;
  unfold swapOut;
  field_simp;
  gcongr;
  · exact mul_nonneg p.hy.le p.hx.le;
  · exact mul_pos p.hy ( add_pos p.hx hd₁ );
  · linarith [ p.hy ]

/-! ## Multi-Pool Routing -/

/-- A routing across n pools -/
structure Routing (n : ℕ) where
  amounts : Fin n → ℝ
  nonneg : ∀ i, 0 ≤ amounts i

noncomputable def Pool.output (p : Pool) (dx : ℝ) : ℝ :=
  if dx ≤ 0 then 0 else p.y * dx / (p.x + dx)

noncomputable def routingOutput {n : ℕ} (pools : Fin n → Pool) (r : Routing n) : ℝ :=
  ∑ i, (pools i).output (r.amounts i)

/-
Splitting across two identical pools beats single-pool routing for large trades
-/
theorem split_beats_single (p : Pool) (D : ℝ) (hD : 0 < D) :
    swapOut p (D / 2) (by linarith) + swapOut p (D / 2) (by linarith) ≥
    swapOut p D hD ∨ D ≤ 0 := by
  unfold swapOut; ring_nf; norm_num [ hD.le ] ;
  exact Or.inl ( mul_le_mul_of_nonneg_left ( inv_anti₀ ( by linarith [ p.hx ] ) ( by linarith [ p.hx ] ) ) ( mul_nonneg p.hy.le hD.le ) )

end Ethereum.Routing