/-! # CatalogBuild.Cryptography.Ethereum.SandwichNonMonotonicity

Auto-generated from theorem catalog database.
Domain: Cryptography/Ethereum
Declarations: 12
-/

import Mathlib

noncomputable section

noncomputable def poolAfter (p : Pool) (dx : ℝ) (hdx : 0 < dx) : Pool where
  x := p.x + dx
  y := p.x * p.y / (p.x + dx)
  hx := by linarith [p.hx]
  hy := div_pos (mul_pos p.hx p.hy) (by linarith [p.hx])


/-- The sandwich gain from the victim's price impact on attacker's position:
gain(f) = y·f·v / ((x+f)·(x+f+v)) -/
noncomputable def sandwichGain (x y v f : ℝ) : ℝ :=
  y * f * v / ((x + f) * (x + f + v))


/-- Net profit after subtracting round-trip slippage cost:
NetProfit(f) = sandwichGain(f) - y·f²/(x·(x+f)) -/
noncomputable def netSandwichProfit (x y v f : ℝ) : ℝ :=
  sandwichGain x y v f - y * f ^ 2 / (x * (x + f))


theorem sandwich_gain_at_zero (x y v : ℝ) :
    sandwichGain x y v 0 = 0 := by
  unfold sandwichGain; ring


theorem sandwich_gain_pos (x y v f : ℝ)
    (hx : 0 < x) (hy : 0 < y) (hv : 0 < v) (hf : 0 < f) :
    0 < sandwichGain x y v f := by
  unfold sandwichGain
  apply div_pos
  · positivity
  · exact mul_pos (by linarith) (by linarith)


theorem net_profit_at_zero (x y v : ℝ) (hx : 0 < x) :
    netSandwichProfit x y v 0 = 0 := by
  unfold netSandwichProfit sandwichGain
  simp [mul_comm, mul_assoc]


theorem net_profit_eventually_negative (x y v : ℝ)
    (hx : 0 < x) (hy : 0 < y) (hv : 0 < v) :
    ∃ F : ℝ, 0 < F ∧ netSandwichProfit x y v F < 0 := by
  unfold netSandwichProfit sandwichGain;
  refine' ⟨ x + v + 1, by positivity, _ ⟩;
  field_simp;
  nlinarith [ mul_pos hx hy, mul_pos hx hv, mul_pos hy hv, pow_pos hx 3, pow_pos hy 3, pow_pos hv 3 ]


theorem sandwich_nonmonotone (x y v : ℝ)
    (hx : 0 < x) (hy : 0 < y) (hv : 0 < v) :
    ∃ f₁ f₂ : ℝ, 0 < f₁ ∧ f₁ < f₂ ∧
      netSandwichProfit x y v f₂ < netSandwichProfit x y v f₁ := by
  norm_num [ netSandwichProfit, sandwichGain ];
  refine' ⟨ 1, by norm_num, 2 + x + v, _, _ ⟩;
  · linarith;
  · field_simp;
    exact lt_of_sub_pos ( by ring_nf; positivity )


noncomputable def optimalFrontRun (x v : ℝ) : ℝ :=
  Real.sqrt (x * (x + v)) - x


theorem optimal_front_run_pos (x v : ℝ) (hx : 0 < x) (hv : 0 < v) :
    0 < optimalFrontRun x v := by
  -- By definition of `optimalFrontRun`, we know that it is a positive real number.
  unfold optimalFrontRun
  exact sub_pos_of_lt (Real.lt_sqrt_of_sq_lt (by nlinarith))


noncomputable def flashSandwichProfit (x y v f γ : ℝ) : ℝ :=
  netSandwichProfit x y v f - γ * f


theorem flash_fee_reduces_profit (x y v f γ : ℝ) (hγ : 0 < γ) (hf : 0 < f) :
    flashSandwichProfit x y v f γ < netSandwichProfit x y v f := by
  unfold flashSandwichProfit
  linarith [mul_pos hγ hf]


end
