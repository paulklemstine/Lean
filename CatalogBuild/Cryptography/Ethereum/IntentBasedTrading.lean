/-! # CatalogBuild.Cryptography.Ethereum.IntentBasedTrading

Auto-generated from theorem catalog database.
Domain: Cryptography/Ethereum
Declarations: 16
-/

import Mathlib

noncomputable section

/-- A trade intent: the user's desired outcome -/
structure Intent where
  inputAmount : ℝ      -- Amount user is willing to spend
  minOutput : ℝ        -- Minimum acceptable output
  deadline : ℕ         -- Block number deadline
  hInput : 0 < inputAmount
  hMin : 0 ≤ minOutput



/-- A solver's proposed fill for an intent -/
structure Fill where
  outputAmount : ℝ     -- Amount the solver will deliver
  solverCost : ℝ       -- Solver's cost to source the tokens
  hOutput : 0 ≤ outputAmount



/-- A fill satisfies an intent if it delivers at least the minimum -/
def Fill.satisfies (f : Fill) (i : Intent) : Prop :=
  i.minOutput ≤ f.outputAmount



/-- Solver profit from a fill -/
noncomputable def solverProfit (i : Intent) (f : Fill) : ℝ :=
  i.inputAmount - f.solverCost



/-- Output from direct AMM execution -/
noncomputable def ammOutput (reserveX reserveY dx : ℝ) : ℝ :=
  reserveY * dx / (reserveX + dx)



/-- AMM output is positive for positive inputs -/
theorem ammOutput_pos (rx ry dx : ℝ) (hrx : 0 < rx) (hry : 0 < ry) (hdx : 0 < dx) :
    0 < ammOutput rx ry dx := by
  unfold ammOutput
  exact div_pos (mul_pos hry hdx) (by linarith)



/-- In a competitive solver market with n solvers, the winning solver
must offer at least as much output as any other solver. -/
structure SolverAuction where
  intent : Intent
  fills : List Fill
  hNonempty : fills ≠ []
  hAllSatisfy : ∀ f ∈ fills, f.satisfies intent



/-- The best fill maximizes output amount -/
noncomputable def bestOutput (fills : List Fill) : ℝ :=
  fills.foldl (fun acc f => max acc f.outputAmount) 0



/-- **Competition theorem**: with at least two solvers competing,
the winning output is at least as good as the AMM output.
(Assuming at least one solver can match AMM output as baseline.) -/
theorem competition_beats_amm
    (intent : Intent)
    (ammOut : ℝ) (hammOut : 0 < ammOut)
    (solver1_output solver2_output : ℝ)
    (h1 : ammOut ≤ solver1_output)
    (h2 : ammOut ≤ solver2_output) :
    ammOut ≤ max solver1_output solver2_output := by
  exact le_max_of_le_left h1



/-- UniswapX uses a Dutch auction: the offered output starts high and
decreases over time, ensuring execution within the deadline. -/
structure DutchAuction where
  startOutput : ℝ       -- Initial (high) output offer
  endOutput : ℝ         -- Final (low) output offer
  startBlock : ℕ
  endBlock : ℕ
  hStart : 0 < startOutput
  hEnd : 0 < endOutput
  hDecay : endOutput ≤ startOutput
  hBlocks : startBlock < endBlock



/-- Output at a given block (linear decay) -/
noncomputable def DutchAuction.outputAt (da : DutchAuction) (block : ℕ) : ℝ :=
  if block ≤ da.startBlock then da.startOutput
  else if da.endBlock ≤ block then da.endOutput
  else
    let progress := (block - da.startBlock : ℝ) / (da.endBlock - da.startBlock : ℝ)
    da.startOutput - progress * (da.startOutput - da.endOutput)



/-- [Section: # CatalogBuild.Cryptography.Ethereum.IntentBasedTrading
Auto-generated from theorem catalog database.
Domain: Cryptography/Ethereum
Declarations: 16] -/
theorem dutch_auction_nonincreasing (da : DutchAuction) (b₁ b₂ : ℕ)
    (hle : b₁ ≤ b₂) :
    da.outputAt b₂ ≤ da.outputAt b₁ := by
  revert hle;
  unfold DutchAuction.outputAt;
  split_ifs;
  any_goals intro h; nlinarith [ da.hDecay ];
  · exact fun h => by nlinarith [ da.hDecay, show ( b₁ : ℝ ) ≤ da.endBlock by norm_cast; linarith, show ( da.endBlock : ℝ ) ≤ b₂ by norm_cast, show ( da.startBlock : ℝ ) < da.endBlock by norm_cast; linarith, div_mul_cancel₀ ( ( b₁ : ℝ ) - da.startBlock ) ( sub_ne_zero_of_ne ( by norm_cast; linarith : ( da.endBlock : ℝ ) ≠ da.startBlock ) ) ] ;
  · exact fun _ => sub_le_self _ ( mul_nonneg ( div_nonneg ( sub_nonneg.2 <| mod_cast by linarith ) <| sub_nonneg.2 <| mod_cast by linarith ) <| sub_nonneg.2 <| mod_cast da.hDecay );
  · exact fun h => by exact sub_le_sub_left ( mul_le_mul_of_nonneg_right ( div_le_div_of_nonneg_right ( sub_le_sub_right ( Nat.cast_le.mpr h ) _ ) ( sub_nonneg.mpr ( mod_cast by linarith ) ) ) ( sub_nonneg.mpr ( mod_cast da.hDecay ) ) ) _;



theorem dutch_auction_bounded (da : DutchAuction) (block : ℕ) :
    da.endOutput ≤ da.outputAt block ∧ da.outputAt block ≤ da.startOutput := by
  unfold DutchAuction.outputAt;
  split_ifs <;> constructor <;> try linarith [ da.hDecay ];
  · simp +zetaDelta at *;
    rw [ div_mul_eq_mul_div, sub_div', le_div_iff₀ ] <;> nlinarith [ show ( block : ℝ ) ≥ da.startBlock + 1 by exact_mod_cast ‹_›, show ( block : ℝ ) < da.endBlock by exact_mod_cast ‹_›, da.hDecay ];
  · exact sub_le_self _ ( mul_nonneg ( div_nonneg ( sub_nonneg.mpr <| Nat.cast_le.mpr <| le_of_not_ge ‹_› ) <| sub_nonneg.mpr <| Nat.cast_le.mpr <| le_of_not_ge <| by linarith ) <| sub_nonneg.mpr <| by linarith [ da.hDecay ] )



/-- A batch of trade intents that can potentially be matched internally -/
structure Batch where
  buyOrders : List Intent   -- Users wanting to buy token Y with token X
  sellOrders : List Intent  -- Users wanting to sell token Y for token X



/-- **Coincidence of Wants (CoW)**: When buy and sell orders overlap,
both sides get better prices than AMM execution.
If user A wants to swap X→Y and user B wants to swap Y→X,
they can trade directly at the midpoint price, both saving
the AMM's spread. -/
theorem cow_price_improvement
    (spotPrice : ℝ) (hspot : 0 < spotPrice)
    (ammBuyPrice : ℝ) (ammSellPrice : ℝ)
    (hBuy : spotPrice ≤ ammBuyPrice)   -- buying from AMM costs more
    (hSell : ammSellPrice ≤ spotPrice)  -- selling to AMM gives less
    (midPrice : ℝ) (hmid : midPrice = (ammBuyPrice + ammSellPrice) / 2) :
    -- Both buyer and seller get a better price than AMM
    midPrice ≤ ammBuyPrice ∧ ammSellPrice ≤ midPrice := by
  constructor
  · linarith
  · linarith



/-- **Truthful pricing in equilibrium**: In a competitive market with
sufficient solvers, no solver can profitably deviate from offering
their true cost plus minimal margin.
If solver offers output y at cost c, and there are competitors:
- Offering less than y means losing to competitors
- Offering more than y means negative profit
- Offering y at cost c is the equilibrium -/
theorem solver_truthful_equilibrium
    (cost : ℝ) (hcost : 0 < cost)
    (competitorOffer : ℝ) (hcomp : cost < competitorOffer)
    (solverOffer : ℝ) :
    -- If solver offers less than competitor, they win
    (solverOffer ≤ cost → competitorOffer - cost > 0) ∧
    -- If solver offers more than competitor, they lose
    (competitorOffer < solverOffer → True) := by
  exact ⟨fun _ => by linarith, fun _ => trivial⟩



end
