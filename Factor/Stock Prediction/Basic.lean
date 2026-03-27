/-
  # Online Portfolio Optimization — Core Definitions

  This module formalizes the mathematical foundations of online portfolio selection,
  based on the framework of Cover's Universal Portfolio (1991) and Online Convex
  Optimization regret theory.

  ## Key Concepts

  - **Portfolio**: A probability distribution over n assets (weights in the simplex)
  - **Price Relatives**: Ratio of closing price to opening price for each asset
  - **Wealth Growth**: Multiplicative wealth factor from portfolio returns
  - **Regret**: Gap between algorithm's wealth and best fixed strategy in hindsight
  - **Kelly Criterion**: Optimal fraction to invest maximizing log-wealth growth

  ## Mathematical Framework

  At each time step t = 1, ..., T:
  1. Algorithm selects portfolio weights bₜ ∈ Δₙ (n-simplex)
  2. Market reveals price relatives xₜ ∈ ℝ₊ⁿ
  3. Wealth updates: Wₜ = Wₜ₋₁ · ⟨bₜ, xₜ⟩

  The goal is to minimize regret: log(W*_T) - log(W_T), where W*_T is the
  wealth of the best constant-rebalanced portfolio (CRP) in hindsight.
-/

import Mathlib

open Finset BigOperators

namespace StockPrediction

/-- A portfolio over n assets: weights summing to 1, all nonneg. -/
structure Portfolio (n : ℕ) where
  weights : Fin n → ℝ
  nonneg : ∀ i, 0 ≤ weights i
  sum_one : ∑ i, weights i = 1

/-- Price relatives: ratio of closing to opening price for each asset. -/
structure PriceRelatives (n : ℕ) where
  values : Fin n → ℝ
  pos : ∀ i, 0 < values i

/-- The return of a portfolio given price relatives: ⟨b, x⟩ -/
noncomputable def portfolioReturn (n : ℕ) (b : Portfolio n) (x : PriceRelatives n) : ℝ :=
  ∑ i : Fin n, b.weights i * x.values i

/-
PROBLEM
Portfolio return is strictly positive when portfolio has support on positive prices.

PROVIDED SOLUTION
The portfolio return is ∑ b_i * x_i. Since b_i ≥ 0, x_i > 0, and ∑ b_i = 1 with n > 0, at least one b_i > 0 (since they sum to 1 and are nonneg). Then the sum is strictly positive because the positive terms dominate. Use Finset.sum_pos or show there exists an index where b_i * x_i > 0 and all terms are nonneg.
-/
theorem portfolioReturn_pos {n : ℕ} (hn : 0 < n) (b : Portfolio n) (x : PriceRelatives n) :
    0 < portfolioReturn n b x := by
      -- By definition of $b$ and $x$, there exists some $i$ such that $b.weights i > 0$.
      obtain ⟨i, hi⟩ : ∃ i, b.weights i > 0 := by
        exact not_forall_not.mp fun h => absurd ( b.sum_one ▸ Finset.sum_nonpos fun i _ => le_of_not_gt fun hi => h i hi ) ( by norm_num );
      exact lt_of_lt_of_le ( mul_pos hi ( x.pos i ) ) ( Finset.single_le_sum ( fun i _ => mul_nonneg ( b.nonneg i ) ( le_of_lt ( x.pos i ) ) ) ( Finset.mem_univ i ) )

/-- Cumulative wealth after T rounds, starting with wealth 1. -/
noncomputable def cumulativeWealth (n : ℕ) (T : ℕ)
    (portfolios : Fin T → Portfolio n) (prices : Fin T → PriceRelatives n) : ℝ :=
  ∏ t : Fin T, portfolioReturn n (portfolios t) (prices t)

/-- Cumulative wealth of a constant-rebalanced portfolio (CRP). -/
noncomputable def crpWealth (n : ℕ) (T : ℕ)
    (b : Portfolio n) (prices : Fin T → PriceRelatives n) : ℝ :=
  ∏ t : Fin T, portfolioReturn n b (prices t)

/-- The best CRP wealth in hindsight (supremum over all fixed portfolios). -/
noncomputable def bestCrpWealth (n : ℕ) (T : ℕ)
    (prices : Fin T → PriceRelatives n) : ℝ :=
  sSup {w : ℝ | ∃ b : Portfolio n, crpWealth n T b prices = w}

/-- Logarithmic regret: difference between log of best CRP and algorithm's wealth. -/
noncomputable def logRegret (n : ℕ) (T : ℕ)
    (portfolios : Fin T → Portfolio n) (prices : Fin T → PriceRelatives n) : ℝ :=
  Real.log (bestCrpWealth n T prices) - Real.log (cumulativeWealth n T portfolios prices)

/-- The log-wealth (growth rate) of a portfolio sequence. -/
noncomputable def logWealth (n : ℕ) (T : ℕ)
    (portfolios : Fin T → Portfolio n) (prices : Fin T → PriceRelatives n) : ℝ :=
  ∑ t : Fin T, Real.log (portfolioReturn n (portfolios t) (prices t))

/-
PROBLEM
Log-wealth equals log of cumulative wealth.

PROVIDED SOLUTION
logWealth is the sum of logs and cumulativeWealth is the product. Use Real.log_prod (log of product equals sum of logs) applied to a finite product. Each portfolioReturn is positive (by portfolioReturn_pos), so log_prod applies.
-/
theorem logWealth_eq_log_cumulativeWealth {n : ℕ} (hn : 0 < n) (T : ℕ)
    (portfolios : Fin T → Portfolio n) (prices : Fin T → PriceRelatives n) :
    logWealth n T portfolios prices = Real.log (cumulativeWealth n T portfolios prices) := by
      -- Apply the logarithm property that the logarithm of a product is the sum of the logarithms.
      have h_log_prod : Real.log (∏ t, portfolioReturn n (portfolios t) (prices t)) = ∑ t, Real.log (portfolioReturn n (portfolios t) (prices t)) := by
        apply Real.log_prod;
        exact fun t _ => ne_of_gt <| portfolioReturn_pos hn _ _;
      exact h_log_prod.symm

/-! ## Kelly Criterion

The Kelly criterion determines the optimal fraction of wealth to bet on a
binary outcome to maximize expected log-wealth growth. For a bet with
probability p of winning and odds b:1, the optimal fraction is:

  f* = p - (1-p)/b = (pb - (1-p))/b

This generalizes to the multi-asset case as the portfolio maximizing
expected log-return.
-/

/-- Kelly optimal fraction for a binary bet with win probability p and odds b:1. -/
noncomputable def kellyFraction (p b : ℝ) : ℝ :=
  (p * b - (1 - p)) / b

/-
PROBLEM
Kelly fraction is nonneg when edge is positive (pb > 1-p).

PROVIDED SOLUTION
kellyFraction p b = (p*b - (1-p))/b. The numerator p*b - (1-p) = p*b - 1 + p is nonneg iff p*b ≥ 1-p, which is given by hedge. Since b > 0, dividing a nonneg by a positive gives nonneg.
-/
theorem kellyFraction_nonneg {p b : ℝ} (hp : 0 ≤ p) (hp1 : p ≤ 1)
    (hb : 0 < b) (hedge : (1 - p) < p * b) :
    0 ≤ kellyFraction p b := by
      exact div_nonneg ( by linarith ) hb.le

/-
PROBLEM
Kelly fraction is at most 1 when p ≤ 1.

PROVIDED SOLUTION
kellyFraction p b = (p*b - (1-p))/b = p - (1-p)/b. Since p ≤ 1 and (1-p)/b ≥ 0 (because 1-p ≥ 0 and b > 0), we have kellyFraction ≤ p ≤ 1.
-/
theorem kellyFraction_le_one {p b : ℝ} (hp : 0 ≤ p) (hp1 : p ≤ 1)
    (hb : 0 < b) :
    kellyFraction p b ≤ 1 := by
      unfold kellyFraction; nlinarith [ mul_div_cancel₀ ( p * b - ( 1 - p ) ) hb.ne' ] ;

/-- Expected log-growth rate under Kelly criterion. -/
noncomputable def kellyGrowthRate (p b : ℝ) : ℝ :=
  let f := kellyFraction p b
  p * Real.log (1 + f * b) + (1 - p) * Real.log (1 - f)

/-! ## Exponential Gradient Algorithm

The Exponential Gradient (EG) algorithm updates portfolio weights
multiplicatively:

  bₜ₊₁(i) = bₜ(i) · exp(η · xₜ(i) / ⟨bₜ, xₜ⟩) / Zₜ

where Zₜ is a normalization factor and η is the learning rate.

The EG algorithm achieves O(√(T log n)) regret.
-/

/-- Exponential gradient update (unnormalized). -/
noncomputable def egUpdateUnnorm (n : ℕ) (η : ℝ) (b : Portfolio n)
    (x : PriceRelatives n) (i : Fin n) : ℝ :=
  b.weights i * Real.exp (η * x.values i / portfolioReturn n b x)

/-- Normalization constant for EG update. -/
noncomputable def egNormConst (n : ℕ) (η : ℝ) (b : Portfolio n)
    (x : PriceRelatives n) : ℝ :=
  ∑ i : Fin n, egUpdateUnnorm n η b x i

/-
PROBLEM
The EG normalization constant is strictly positive.

PROVIDED SOLUTION
egNormConst is ∑ b_i * exp(...). Each term b_i * exp(...) is nonneg (b_i ≥ 0, exp > 0). Since ∑ b_i = 1 and n > 0, at least one b_i > 0. For that index, b_i * exp(...) > 0. So the sum is positive.
-/
theorem egNormConst_pos {n : ℕ} (hn : 0 < n) (η : ℝ) (b : Portfolio n)
    (x : PriceRelatives n) :
    0 < egNormConst n η b x := by
      obtain ⟨i, hi⟩ : ∃ i, b.weights i > 0 := by
        exact not_forall_not.mp fun h => by have := b.sum_one; linarith [ show ∑ i, b.weights i ≤ 0 from Finset.sum_nonpos fun i _ => le_of_not_gt fun hi => h i hi ] ;
      exact lt_of_lt_of_le ( mul_pos hi ( Real.exp_pos _ ) ) ( Finset.single_le_sum ( fun i _ => mul_nonneg ( b.nonneg i ) ( Real.exp_nonneg _ ) ) ( Finset.mem_univ i ) )

/-! ## Regret Bounds

The central theorem: the EG algorithm with learning rate η = √(8 log n / T)
achieves logarithmic regret at most √(T log n / 2), which is O(√(T log n)).

This is sublinear in T, meaning the average per-round regret → 0 as T → ∞.
-/

/-
PROBLEM
Regret bound for the EG algorithm: there exists a portfolio strategy whose
    logarithmic regret against the best CRP is at most O(√(T · log n)).
    This is the fundamental guarantee of online convex optimization applied
    to portfolio selection (Helmbold et al., 1998).

    Note: The bound applies specifically to the EG algorithm's output, not to
    arbitrary portfolio sequences. We state this as an existential: for any
    price sequence, there exists a strategy achieving this regret bound.

PROVIDED SOLUTION
For the existential, use the trivial strategy: equal weight portfolio (1/n for each asset). This gives a CRP itself, so the regret against the best CRP may not be zero, but it may be bounded. Actually, the simplest approach: just use the best CRP itself as the portfolio. The best CRP is a constant-rebalanced portfolio, so if we use it as our strategy, our wealth equals the best CRP wealth, giving regret 0, which is ≤ the bound. The existential is satisfied by choosing portfolios to be any constant-rebalanced portfolio (in fact, we can always achieve 0 regret with hindsight). Choose `portfolios t` to be any fixed portfolio b for all t. Then cumulativeWealth = crpWealth with that b. The bestCrpWealth ≥ crpWealth for any b, so logRegret ≥ 0. But if we choose b to be the best CRP, then logRegret = 0 ≤ bound. However, bestCrpWealth is defined as sSup which might not be attained. Instead, we can simply use the uniform portfolio, which gives some crpWealth, and note that logRegret can still be large. Actually the simplest existential witness: use the equal weight portfolio for all t. The logRegret = log(bestCRP) - log(equalWeightCRP). We need this ≤ √(T log n / 2). This is not obvious. A simpler approach: note that logRegret involves sSup, and since we're choosing the portfolios, choose portfolios such that cumulativeWealth is large. In fact, by choosing portfolios = constant uniform portfolio, the cumulativeWealth = crpWealth of uniform, and logRegret = log(bestCRP/uniformCRP). This could be up to T * log(max_price_relative). That's not bounded by √(T log n/2) in general. So the trivial approach doesn't work. The real proof requires constructing the EG algorithm's output. This is a deep theorem that requires formalizing the EG update rule as a function from price histories to portfolios. This is very hard to formalize from scratch. Let me try: define the EG strategy recursively, then the bound follows from the standard analysis.
-/
theorem eg_regret_bound_exists (n T : ℕ) (hn : 1 < n) (hT : 0 < T) :
    ∀ (prices : Fin T → PriceRelatives n),
    ∃ (portfolios : Fin T → Portfolio n),
    logRegret n T portfolios prices ≤ Real.sqrt (↑T * Real.log ↑n / 2) := by
      intro prices;
      -- We'll use that `sSup` is achieved by some portfolio `b`.
      obtain ⟨b, hb⟩ : ∃ b : Portfolio n, crpWealth n T b prices = sSup {w : ℝ | ∃ b : Portfolio n, crpWealth n T b prices = w} := by
        -- The set of portfolios is compact, and the function crpWealth is continuous, so the supremum is attained.
        have h_compact : IsCompact {b : Fin n → ℝ | (∀ i, 0 ≤ b i) ∧ (∑ i, b i = 1)} := by
          exact CompactIccSpace.isCompact_Icc.of_isClosed_subset ( isClosed_Ici.preimage ( continuous_pi fun _ => continuous_apply _ ) |> IsClosed.inter <| isClosed_eq ( continuous_finset_sum _ fun _ _ => continuous_apply _ ) continuous_const ) fun x hx => ⟨ fun i => hx.1 i, fun i => hx.2 ▸ Finset.single_le_sum ( fun a _ => hx.1 a ) ( Finset.mem_univ i ) ⟩;
        have h_continuous : ContinuousOn (fun b : Fin n → ℝ => ∏ t : Fin T, (∑ i : Fin n, b i * (prices t).values i)) {b : Fin n → ℝ | (∀ i, 0 ≤ b i) ∧ (∑ i, b i = 1)} := by
          fun_prop;
        have := h_compact.exists_isMaxOn ⟨ fun _ => 1 / n, ⟨ fun _ => by positivity, by norm_num [ show n ≠ 0 by positivity ] ⟩ ⟩ h_continuous;
        obtain ⟨ b, hb₁, hb₂ ⟩ := this;
        refine' ⟨ ⟨ b, hb₁.1, hb₁.2 ⟩, le_antisymm _ _ ⟩;
        · exact le_csSup ⟨ _, fun w hw => by rcases hw with ⟨ b, rfl ⟩ ; exact hb₂ ⟨ b.nonneg, b.sum_one ⟩ ⟩ ⟨ ⟨ b, hb₁.1, hb₁.2 ⟩, rfl ⟩;
        · exact csSup_le ⟨ _, ⟨ ⟨ b, hb₁.1, hb₁.2 ⟩, rfl ⟩ ⟩ fun w hw => by rcases hw with ⟨ b', rfl ⟩ ; exact hb₂ ⟨ b'.nonneg, b'.sum_one ⟩ ;
      unfold logRegret crpWealth at *;
      unfold bestCrpWealth cumulativeWealth at *;
      unfold crpWealth at *;
      exact ⟨ fun _ => b, by rw [ ← hb ] ; norm_num; positivity ⟩

end StockPrediction