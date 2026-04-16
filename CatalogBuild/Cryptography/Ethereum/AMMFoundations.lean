/-! # CatalogBuild.Cryptography.Ethereum.AMMFoundations

Auto-generated from theorem catalog database.
Domain: Cryptography/Ethereum
Declarations: 13
-/

import Mathlib

noncomputable section

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



/-- [Section: # CatalogBuild.Cryptography.Ethereum.AMMFoundations
Auto-generated from theorem catalog database.
Domain: Cryptography/Ethereum
Declarations: 13] -/
theorem invariant_preserved (p : Pool) (dx : ℝ) (hdx : 0 < dx) :
    (p.afterSwapXtoY dx hdx).invariant = p.invariant := by
  unfold Pool.invariant Pool.afterSwapXtoY;
  rw [ mul_div_cancel₀ _ ( ne_of_gt ( by linarith [ p.hX ] ) ) ]



theorem swap_output_pos (p : Pool) (dx : ℝ) (hdx : 0 < dx) :
    0 < p.swapXtoY dx hdx := by
  exact sub_pos_of_lt ( by rw [ div_lt_iff₀ ] <;> nlinarith [ p.hX, p.hY ] )



theorem swap_output_lt_reserve (p : Pool) (dx : ℝ) (hdx : 0 < dx) :
    p.swapXtoY dx hdx < p.reserveY := by
  unfold Ethereum.AMM.Pool.swapXtoY; ring_nf; norm_num [ hdx, p.hX, p.hY ] ;
  linarith [ p.hX ]



theorem swap_monotone (p : Pool) (dx₁ dx₂ : ℝ) (h1 : 0 < dx₁) (h2 : 0 < dx₂)
    (hle : dx₁ ≤ dx₂) :
    p.swapXtoY dx₁ h1 ≤ p.swapXtoY dx₂ h2 := by
  unfold Pool.swapXtoY;
  gcongr ; nlinarith [ p.hX, p.hY ];
  linarith [ p.hX ]



theorem swap_diminishing_returns (p : Pool) (a b : ℝ) (ha : 0 < a) (hb : 0 < b) (hab : a ≤ b) :
    p.swapXtoY b hb / b ≤ p.swapXtoY a ha / a := by
  unfold Pool.swapXtoY;
  rw [ sub_div', sub_div' ] <;> try nlinarith [ p.hX, p.hY ];
  field_simp;
  rw [ div_le_div_iff₀ ] <;> nlinarith [ mul_pos ha hb, mul_le_mul_of_nonneg_left hab ( show 0 ≤ p.reserveY by linarith [ p.hY ] ), mul_le_mul_of_nonneg_left hab ( show 0 ≤ p.reserveX by linarith [ p.hX ] ), p.hX, p.hY ]



theorem swap_formula (p : Pool) (dx : ℝ) (hdx : 0 < dx) :
    p.swapXtoY dx hdx = p.reserveY * dx / (p.reserveX + dx) := by
  unfold Pool.swapXtoY
  ring;
  linarith [ inv_mul_cancel_left₀ ( show p.reserveX + dx ≠ 0 by linarith [ p.hX ] ) p.reserveY ]



theorem fee_reduces_output (p : Pool) (dx γ : ℝ)
    (hdx : 0 < dx) (hγ0 : 0 < γ) (hγ1 : γ < 1) :
    p.swapXtoYWithFee dx γ hdx hγ0 hγ1 < p.swapXtoY dx hdx := by
  unfold Pool.swapXtoYWithFee Pool.swapXtoY; norm_num; ring;
  exact mul_lt_mul_of_pos_left ( inv_strictAnti₀ ( by nlinarith [ p.hX, p.hY ] ) ( by nlinarith [ p.hX, p.hY ] ) ) ( mul_pos p.hX p.hY )



end
