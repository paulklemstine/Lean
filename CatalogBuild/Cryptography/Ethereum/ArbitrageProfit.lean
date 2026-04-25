/-! # CatalogBuild.Cryptography.Ethereum.ArbitrageProfit

Auto-generated from theorem catalog database.
Domain: Cryptography/Ethereum
Declarations: 11
-/

import Mathlib

noncomputable section

/-- A simplified pool with reserves (for cleaner arbitrage statements) -/
structure SimplePool where
  x : ℝ  -- reserve of token A
  y : ℝ  -- reserve of token B
  hx : 0 < x
  hy : 0 < y


/-- Spot price of A in terms of B -/
noncomputable def SimplePool.price (p : SimplePool) : ℝ := p.y / p.x


/-- Output when buying B with amount `dx` of A (no fees) -/
noncomputable def SimplePool.buyB (p : SimplePool) (dx : ℝ) : ℝ :=
  p.y * dx / (p.x + dx)


/-- Output when buying A with amount `dy` of B (no fees) -/
noncomputable def SimplePool.buyA (p : SimplePool) (dy : ℝ) : ℝ :=
  p.x * dy / (p.y + dy)


/-- [Section: # CatalogBuild.Cryptography.Ethereum.ArbitrageProfit
Auto-generated from theorem catalog database.
Domain: Cryptography/Ethereum
Declarations: 11] -/
theorem arbitrage_profit_exists
    (pool1 pool2 : SimplePool)
    (h_price_diverge : pool1.price < pool2.price) :
    ∃ dx : ℝ, 0 < dx ∧
      let a_received := pool1.buyA (pool1.y * dx / (pool1.x + dx))
      let b_profit := pool2.buyB dx
      0 < b_profit := by
  exact ⟨ 1, by norm_num, div_pos ( by linarith [ pool1.hx, pool1.hy, pool2.hx, pool2.hy ] ) ( by linarith [ pool1.hx, pool1.hy, pool2.hx, pool2.hy ] ) ⟩


/-- **Arbitrage Revenue Formula**: When buying `dx` of token A in pool1 and
immediately selling in pool2, the gross revenue in token B is: -/
noncomputable def arbitrageRevenue (p1 p2 : SimplePool) (dx : ℝ) : ℝ :=
  let dy1 := p1.buyB dx     -- B spent to buy dx of A in pool1... actually
  p2.buyB dx - p1.buyB dx


/-- [Section: # CatalogBuild.Cryptography.Ethereum.ArbitrageProfit
Auto-generated from theorem catalog database.
Domain: Cryptography/Ethereum
Declarations: 11] -/
theorem small_trade_profitable
    (p1 p2 : SimplePool)
    (h_diverge : p1.price < p2.price) :
    ∃ ε : ℝ, 0 < ε ∧ ∀ dx : ℝ, 0 < dx → dx < ε →
      0 < p2.buyB dx - p1.buyB dx := by
  unfold SimplePool.buyB SimplePool.price at *;
  have h_diff_pos : Filter.Tendsto (fun dx => (p2.y * dx / (p2.x + dx) - p1.y * dx / (p1.x + dx)) / dx) (nhdsWithin 0 (Set.Ioi 0)) (nhds ((p2.y / p2.x) - (p1.y / p1.x))) := by
    -- We can simplify the expression inside the limit.
    suffices h_simplify : Filter.Tendsto (fun dx => (p2.y / (p2.x + dx) - p1.y / (p1.x + dx))) (nhdsWithin 0 (Set.Ioi 0)) (nhds ((p2.y / p2.x - p1.y / p1.x))) by
      refine' h_simplify.congr' ( by filter_upwards [ self_mem_nhdsWithin ] with x hx using by rw [ eq_div_iff hx.out.ne' ] ; ring );
    exact tendsto_nhdsWithin_of_tendsto_nhds ( ContinuousAt.tendsto ( by exact ContinuousAt.sub ( ContinuousAt.div continuousAt_const ( continuousAt_const.add continuousAt_id ) ( by linarith [ p1.hx, p2.hx ] ) ) ( ContinuousAt.div continuousAt_const ( continuousAt_const.add continuousAt_id ) ( by linarith [ p1.hx, p2.hx ] ) ) ) |> fun h => h.trans <| by norm_num );
  have := h_diff_pos.eventually ( lt_mem_nhds <| sub_pos.mpr h_diverge );
  rcases ( Metric.mem_nhdsWithin_iff.mp <| this ) with ⟨ ε, ε_pos, hε ⟩;
  exact ⟨ ε, ε_pos, fun dx dx_pos dx_lt => by have := hε ⟨ mem_ball_zero_iff.mpr ( abs_lt.mpr ⟨ by linarith, by linarith ⟩ ), dx_pos ⟩ ; rw [ Set.mem_setOf_eq, lt_div_iff₀ dx_pos ] at this; linarith ⟩


/-- A three-pool cycle: A→B→C→A. Profit if the product of exchange rates > 1. -/
noncomputable def cyclicProfitRate (p_ab p_bc p_ca : SimplePool) : ℝ :=
  p_ab.price * p_bc.price * p_ca.price


/-- [Section: # CatalogBuild.Cryptography.Ethereum.ArbitrageProfit
Auto-generated from theorem catalog database.
Domain: Cryptography/Ethereum
Declarations: 11] -/
theorem cyclic_arbitrage_exists
    (p_ab p_bc p_ca : SimplePool)
    (h_cycle : 1 < cyclicProfitRate p_ab p_bc p_ca) :
    ∃ dx : ℝ, 0 < dx ∧
      let dy := p_ab.buyB dx           -- A → B
      let dz := p_bc.buyB dy           -- B → C
      let da := p_ca.buyB dz           -- C → A
      dx < da := by                     -- End up with more A than started
  -- Use the fact that as dx approaches 0, the ratio da/dx approaches cyclicProfitRate.
  have h_limit : Filter.Tendsto (fun dx => p_ca.buyB (p_bc.buyB (p_ab.buyB dx)) / dx) (nhdsWithin 0 (Set.Ioi 0)) (nhds (cyclicProfitRate p_ab p_bc p_ca)) := by
    -- Use the fact that the derivative of the composition of functions is the product of their derivatives.
    have h_deriv : HasDerivAt (fun dx => p_ca.buyB (p_bc.buyB (p_ab.buyB dx))) (cyclicProfitRate p_ab p_bc p_ca) 0 := by
      convert HasDerivAt.comp _ ( show HasDerivAt ( fun dy => p_ca.buyB dy ) _ _ from ( hasDerivAt_deriv_iff.mpr ?_ ) ) ( HasDerivAt.comp _ ( show HasDerivAt ( fun dz => p_bc.buyB dz ) _ _ from ( hasDerivAt_deriv_iff.mpr ?_ ) ) ( show HasDerivAt ( fun dx => p_ab.buyB dx ) _ _ from ( hasDerivAt_deriv_iff.mpr ?_ ) ) ) using 1 <;> norm_num [ SimplePool.buyB, SimplePool.price ];
      · norm_num [ mul_comm, add_comm, SimplePool.price, cyclicProfitRate ];
        norm_num [ p_ab.hx.ne', p_bc.hx.ne', p_ca.hx.ne', p_ab.hy.ne', p_bc.hy.ne', p_ca.hy.ne', mul_div_assoc ] ; ring;
      · exact DifferentiableAt.div ( differentiableAt_id.const_mul _ ) ( differentiableAt_id.const_add _ ) ( by linarith [ p_ca.hx ] );
      · exact DifferentiableAt.div ( differentiableAt_id.const_mul _ ) ( differentiableAt_id.const_add _ ) ( by linarith [ p_bc.hx ] );
      · exact DifferentiableAt.div ( differentiableAt_id.const_mul _ ) ( differentiableAt_id.const_add _ ) ( by linarith [ p_ab.hx ] );
    convert h_deriv.tendsto_slope_zero_right using 1;
    ext; norm_num [ div_eq_inv_mul, SimplePool.buyB ] ;
  have := h_limit.eventually ( lt_mem_nhds h_cycle ) ; have := this.and self_mem_nhdsWithin; obtain ⟨ x, hx₁, hx₂ ⟩ := this.exists; exact ⟨ x, hx₂, by rw [ div_eq_mul_inv ] at hx₁; nlinarith [ inv_mul_cancel₀ hx₂.ne' ] ⟩ ;


/-- For two pools with different prices, the optimal trade size.
When p2 has higher price than p1, buying A from p1 and selling to p2 is profitable.
The optimal amount of A to trade is derived from setting the derivative of
profit to zero. -/
noncomputable def optimalTradeSize (p1 p2 : SimplePool) : ℝ :=
  Real.sqrt (p1.x * p2.x * p1.y * p2.y) / (p1.y + p2.y) - p1.x * p1.y / (p1.y + p2.y)


theorem optimal_size_pos (p1 p2 : SimplePool)
    (h : p1.price < p2.price)
    (hliq : p1.x * p1.y < p2.x * p2.y) :
    0 < optimalTradeSize p1 p2 := by
  unfold optimalTradeSize;
  rw [ div_sub_div_same, lt_div_iff₀ ] <;> try nlinarith [ p1.hx, p1.hy, p2.hx, p2.hy ];
  rw [ lt_sub_iff_add_lt', Real.lt_sqrt ] <;> nlinarith [ p1.hx, p1.hy, p2.hx, p2.hy, mul_pos p1.hx p1.hy, mul_pos p2.hx p2.hy ]


end
