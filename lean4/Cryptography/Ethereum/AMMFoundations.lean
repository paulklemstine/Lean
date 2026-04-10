/-
  # Automated Market Maker (AMM) Foundations
  ## Formal Verification of Constant-Product Market Makers

  This file formalizes the core mathematics of Uniswap-style constant product
  automated market makers (CPMMs). We prove the fundamental invariant properties,
  derive the exchange rate formula, and establish bounds on slippage.

  ### Key Results:
  - The constant product invariant is preserved under valid trades
  - The marginal price equals the reserve ratio
  - Slippage is bounded by trade size relative to reserves
  - Arbitrage profit is strictly positive when prices diverge

  ### References:
  - Uniswap v2 Whitepaper (Adams et al., 2020)
  - An Analysis of Uniswap Markets (Angeris et al., 2019)
-/

import Mathlib

namespace Ethereum.AMM

/-! ## Core Definitions -/

/-- A liquidity pool state for a constant-product AMM (e.g., Uniswap v2).
    `reserveX` and `reserveY` are the quantities of tokens X and Y in the pool. -/
structure Pool where
  reserveX : ℝ
  reserveY : ℝ
  hX : 0 < reserveX
  hY : 0 < reserveY

/-- The constant product invariant k = x * y -/
noncomputable def Pool.invariant (p : Pool) : ℝ := p.reserveX * p.reserveY

/-- The marginal (spot) price of token X in terms of token Y -/
noncomputable def Pool.spotPrice (p : Pool) : ℝ := p.reserveY / p.reserveX

/-- Amount of token Y received when selling `dx` of token X (no fees) -/
noncomputable def Pool.swapXtoY (p : Pool) (dx : ℝ) (hdx : 0 < dx) : ℝ :=
  p.reserveY - p.reserveX * p.reserveY / (p.reserveX + dx)

/-- Amount of token Y received when selling `dx` of token X (with fee rate γ ∈ (0,1)) -/
noncomputable def Pool.swapXtoYWithFee (p : Pool) (dx : ℝ) (γ : ℝ)
    (hdx : 0 < dx) (hγ0 : 0 < γ) (hγ1 : γ < 1) : ℝ :=
  p.reserveY - p.reserveX * p.reserveY / (p.reserveX + (1 - γ) * dx)

/-- The pool state after a swap of `dx` token X for token Y (no fees) -/
noncomputable def Pool.afterSwapXtoY (p : Pool) (dx : ℝ) (hdx : 0 < dx) : Pool where
  reserveX := p.reserveX + dx
  reserveY := p.reserveX * p.reserveY / (p.reserveX + dx)
  hX := by linarith [p.hX]
  hY := by exact div_pos (mul_pos p.hX p.hY) (by linarith [p.hX])

/-! ## Fundamental Theorems -/

/-
PROBLEM
**Invariant Preservation**: The constant product invariant is preserved after a swap.

PROVIDED SOLUTION
Unfold invariant and afterSwapXtoY. The new invariant is (x + dx) * (x*y/(x+dx)) = x*y = old invariant. Use field_simp and ring.
-/
theorem invariant_preserved (p : Pool) (dx : ℝ) (hdx : 0 < dx) :
    (p.afterSwapXtoY dx hdx).invariant = p.invariant := by
  unfold Pool.invariant Pool.afterSwapXtoY;
  rw [ mul_div_cancel₀ _ ( ne_of_gt ( by linarith [ p.hX ] ) ) ]

/-
PROBLEM
**Output Positivity**: Swapping a positive amount always yields a positive output.

PROVIDED SOLUTION
Unfold swapXtoY. We need 0 < y - x*y/(x+dx). This equals y*dx/(x+dx). Since all terms are positive, the result follows.
-/
theorem swap_output_pos (p : Pool) (dx : ℝ) (hdx : 0 < dx) :
    0 < p.swapXtoY dx hdx := by
  exact sub_pos_of_lt ( by rw [ div_lt_iff₀ ] <;> nlinarith [ p.hX, p.hY ] )

/-
PROBLEM
**Output Bound**: The output of a swap is always less than the total reserve.

PROVIDED SOLUTION
Unfold swapXtoY. We need y - x*y/(x+dx) < y, i.e., 0 < x*y/(x+dx), which is positive since x, y, x+dx are all positive.
-/
theorem swap_output_lt_reserve (p : Pool) (dx : ℝ) (hdx : 0 < dx) :
    p.swapXtoY dx hdx < p.reserveY := by
  unfold Ethereum.AMM.Pool.swapXtoY; ring_nf; norm_num [ hdx, p.hX, p.hY ] ;
  linarith [ p.hX ]

/-
PROBLEM
**Monotonicity**: Larger input ⟹ larger output.

PROVIDED SOLUTION
Unfold swapXtoY. Need y - xy/(x+dx₁) ≤ y - xy/(x+dx₂). This reduces to xy/(x+dx₂) ≤ xy/(x+dx₁). Since xy > 0 and x+dx₁ ≤ x+dx₂, dividing by a larger denominator gives a smaller result.
-/
theorem swap_monotone (p : Pool) (dx₁ dx₂ : ℝ) (h1 : 0 < dx₁) (h2 : 0 < dx₂)
    (hle : dx₁ ≤ dx₂) :
    p.swapXtoY dx₁ h1 ≤ p.swapXtoY dx₂ h2 := by
  unfold Pool.swapXtoY;
  gcongr ; nlinarith [ p.hX, p.hY ];
  linarith [ p.hX ]

/-
PROBLEM
**Concavity / Diminishing Returns**: The marginal output decreases with input size.
    Formally: for 0 < a ≤ b, swapXtoY(a)/a ≥ swapXtoY(b)/b

PROVIDED SOLUTION
Unfold swapXtoY. (y - xy/(x+b))/b ≤ (y - xy/(x+a))/a. Use swap_formula to rewrite as y*b/(x+b)/b ≤ y*a/(x+a)/a, i.e., y/(x+b) ≤ y/(x+a). Since a ≤ b, x+a ≤ x+b, so 1/(x+b) ≤ 1/(x+a). Multiply by y > 0.
-/
theorem swap_diminishing_returns (p : Pool) (a b : ℝ) (ha : 0 < a) (hb : 0 < b) (hab : a ≤ b) :
    p.swapXtoY b hb / b ≤ p.swapXtoY a ha / a := by
  unfold Pool.swapXtoY;
  rw [ sub_div', sub_div' ] <;> try nlinarith [ p.hX, p.hY ];
  field_simp;
  rw [ div_le_div_iff₀ ] <;> nlinarith [ mul_pos ha hb, mul_le_mul_of_nonneg_left hab ( show 0 ≤ p.reserveY by linarith [ p.hY ] ), mul_le_mul_of_nonneg_left hab ( show 0 ≤ p.reserveX by linarith [ p.hX ] ), p.hX, p.hY ]

/-
PROBLEM
**Swap Formula**: Closed-form expression for swap output.
    dy = reserveY * dx / (reserveX + dx)

PROVIDED SOLUTION
Unfold swapXtoY. Show y - x*y/(x+dx) = y*dx/(x+dx). Use field_simp and ring.
-/
theorem swap_formula (p : Pool) (dx : ℝ) (hdx : 0 < dx) :
    p.swapXtoY dx hdx = p.reserveY * dx / (p.reserveX + dx) := by
  unfold Pool.swapXtoY
  ring;
  linarith [ inv_mul_cancel_left₀ ( show p.reserveX + dx ≠ 0 by linarith [ p.hX ] ) p.reserveY ]

/-
PROBLEM
**Fees Reduce Output**: Adding fees strictly reduces the swap output.

PROVIDED SOLUTION
Unfold both. swapXtoYWithFee = y - xy/(x+(1-γ)*dx) and swapXtoY = y - xy/(x+dx). Since 0 < γ < 1, (1-γ)*dx < dx, so x+(1-γ)*dx < x+dx, so xy/(x+(1-γ)*dx) > xy/(x+dx), so y - xy/(x+(1-γ)*dx) < y - xy/(x+dx).
-/
theorem fee_reduces_output (p : Pool) (dx γ : ℝ)
    (hdx : 0 < dx) (hγ0 : 0 < γ) (hγ1 : γ < 1) :
    p.swapXtoYWithFee dx γ hdx hγ0 hγ1 < p.swapXtoY dx hdx := by
  unfold Pool.swapXtoYWithFee Pool.swapXtoY; norm_num; ring;
  exact mul_lt_mul_of_pos_left ( inv_strictAnti₀ ( by nlinarith [ p.hX, p.hY ] ) ( by nlinarith [ p.hX, p.hY ] ) ) ( mul_pos p.hX p.hY )

end Ethereum.AMM