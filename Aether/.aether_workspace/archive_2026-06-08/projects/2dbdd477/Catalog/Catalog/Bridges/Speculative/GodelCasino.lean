import Mathlib

/-!
# Gödel's Casino: Incomplete but Winnable Games

We formalize a game-theoretic framework around logical decidability.
In "Gödel's Casino," a player is dealt statements and must bet on their truth values.
Some statements are decidable (the player can determine the truth), others are not.

## Main Results

* The **selective strategy** (bet correctly on decidable statements, abstain otherwise)
  achieves profit equal to the number of decidable rounds.
* No strategy can exceed the total number of rounds in profit (**profit ceiling**).
* The selective strategy **dominates** any strategy on decidable rounds.
* A **tropical profit** formulation connects casino strategy optimization to
  max-plus algebra, bridging game theory with tropical geometry.
* **Information-theoretic bound**: relates the decidable fraction to achievable profit.

## Novel Definitions

* `CasinoRound` — a round with ground truth and decidability flag
* `CasinoBet` — the three possible actions (bet true, bet false, abstain)
* `GodelCasino` — the full game structure over a finite index set
* `tropicalOptimalPayoff` — profit computation in the tropical (max-plus) semiring

## Cross-domain Connection

The tropical profit theorem connects game theory / logic to tropical algebra,
showing that strategy optimization in Gödel's Casino can be expressed as
tropical polynomial evaluation.
-/

noncomputable section

open Finset BigOperators

/-! ## Core Definitions -/

/-- A bet in Gödel's Casino: the player can bet TRUE, bet FALSE, or ABSTAIN. -/
inductive CasinoBet : Type
  | betTrue  : CasinoBet
  | betFalse : CasinoBet
  | abstain  : CasinoBet
  deriving DecidableEq, Repr

/-- A round in Gödel's Casino.
  Each round has a ground truth value and a decidability flag.
  If `isDecidable = true`, the player's theory can determine the truth value. -/
structure CasinoRound : Type where
  /-- The actual truth value of the statement -/
  truth : Bool
  /-- Whether the statement is decidable by the player's formal system -/
  isDecidable : Bool
  deriving DecidableEq, Repr

/-- The payoff from a single bet: +1 for correct, -1 for incorrect, 0 for abstain -/
def betPayoff (r : CasinoRound) (b : CasinoBet) : ℤ :=
  match b with
  | .abstain  => 0
  | .betTrue  => if r.truth then 1 else -1
  | .betFalse => if r.truth then -1 else 1

/-- A strategy in Gödel's Casino maps a round to a bet. -/
def CasinoStrategy := CasinoRound → CasinoBet

/-- The selective strategy: bet correctly on decidable rounds, abstain on undecidable ones. -/
def selectiveStrategy : CasinoStrategy := fun r =>
  if r.isDecidable then
    if r.truth then .betTrue else .betFalse
  else
    .abstain

/-- Total profit of a strategy over a list of rounds. -/
def totalProfit (s : CasinoStrategy) : List CasinoRound → ℤ
  | [] => 0
  | r :: rs => betPayoff r (s r) + totalProfit s rs

/-- Count of decidable rounds in a list. -/
def decidableCount : List CasinoRound → ℕ
  | [] => 0
  | r :: rs => (if r.isDecidable then 1 else 0) + decidableCount rs

/-! ## Basic Properties of Bet Payoffs -/

/-- The payoff of any single bet is bounded by 1 in absolute value. -/
theorem betPayoff_abs_le_one (r : CasinoRound) (b : CasinoBet) :
    |betPayoff r b| ≤ 1 := by
  unfold betPayoff; cases b <;> simp <;> cases r.truth <;> simp

/-- Abstaining always yields zero payoff. -/
@[simp]
theorem betPayoff_abstain (r : CasinoRound) : betPayoff r .abstain = 0 := rfl

/-- The selective strategy always achieves payoff ≥ 0 on each round. -/
theorem selectiveStrategy_nonneg (r : CasinoRound) :
    0 ≤ betPayoff r (selectiveStrategy r) := by
  unfold selectiveStrategy betPayoff
  cases r with | mk t d => cases d <;> cases t <;> simp

/-- The selective strategy achieves payoff = 1 on decidable rounds. -/
theorem selectiveStrategy_decidable_payoff (r : CasinoRound) (h : r.isDecidable = true) :
    betPayoff r (selectiveStrategy r) = 1 := by
  unfold selectiveStrategy betPayoff
  cases r with | mk t d => simp_all; cases t <;> simp_all

/-- The selective strategy achieves payoff = 0 on undecidable rounds. -/
theorem selectiveStrategy_undecidable_payoff (r : CasinoRound) (h : r.isDecidable = false) :
    betPayoff r (selectiveStrategy r) = 0 := by
  unfold selectiveStrategy betPayoff
  cases r with | mk t d => simp_all

/-! ## Main Theorems -/

/-
**Theorem 1 (Induction)**: The selective strategy achieves total profit equal to
  the number of decidable rounds.
-/
theorem selective_profit_eq_decidable_count (rounds : List CasinoRound) :
    totalProfit selectiveStrategy rounds = ↑(decidableCount rounds) := by
  -- We'll use induction on the list of rounds.
  induction' rounds with r rs ih;
  · rfl;
  · convert congr_arg₂ ( · + · ) ( show betPayoff r ( selectiveStrategy r ) = ( if r.isDecidable then 1 else 0 ) from ?_ ) ih using 1;
    · exact mod_cast rfl;
    · split_ifs <;> simp_all +decide [ selectiveStrategy ];
      cases r ; aesop

/-
**Theorem 2 (Induction)**: Total profit of any strategy is bounded above
  by the number of rounds.
-/
theorem totalProfit_le_length (s : CasinoStrategy) (rounds : List CasinoRound) :
    totalProfit s rounds ≤ ↑rounds.length := by
  induction' rounds with rounds_ih rounds_rounds generalizing s;
  · rfl;
  · exact le_trans ( add_le_add ( show betPayoff _ _ ≤ 1 by exact le_of_abs_le ( betPayoff_abs_le_one _ _ ) ) ( by solve_by_elim ) ) ( by norm_num; linarith )

/-
**Theorem 3**: The selective strategy achieves non-negative total profit.
-/
theorem selective_profit_nonneg (rounds : List CasinoRound) :
    0 ≤ totalProfit selectiveStrategy rounds := by
  exact_mod_cast ( by linarith [ selective_profit_eq_decidable_count rounds ] : ( 0 : ℤ ) ≤ totalProfit selectiveStrategy rounds )

/-
**Theorem 4**: No strategy can outperform the selective strategy
  on all-decidable rounds.
-/
theorem selective_optimal_on_decidable
    (s : CasinoStrategy)
    (rounds : List CasinoRound)
    (h_all_dec : ∀ r ∈ rounds, r.isDecidable = true) :
    totalProfit s rounds ≤ totalProfit selectiveStrategy rounds := by
  have h_totalProfit_le_length : ∀ (rounds : List CasinoRound), (∀ r ∈ rounds, r.isDecidable = true) → totalProfit s rounds ≤ ↑(decidableCount rounds) := by
    intro rounds h_all_dec
    induction' rounds with r rounds ih;
    · rfl;
    · simp_all +decide [ decidableCount ];
      exact add_le_add ( by exact le_of_abs_le ( betPayoff_abs_le_one r ( s r ) ) ) ih;
  exact le_trans ( h_totalProfit_le_length rounds h_all_dec ) ( by rw [ selective_profit_eq_decidable_count ] )

/-
**Theorem 5 (by_contra)**: If any decidable round exists, the selective strategy
  achieves strictly positive profit.
-/
theorem selective_positive_if_decidable_exists
    (rounds : List CasinoRound)
    (h : ∃ r ∈ rounds, r.isDecidable = true) :
    0 < totalProfit selectiveStrategy rounds := by
  obtain ⟨ r, hr, hr' ⟩ := h;
  convert selective_profit_eq_decidable_count rounds ▸ Nat.cast_pos.mpr _;
  induction rounds <;> simp_all +decide [ List.foldr ];
  cases hr <;> simp_all +decide [ decidableCount ]

/-
Total profit decomposes over list concatenation.
-/
theorem totalProfit_append (s : CasinoStrategy) (l₁ l₂ : List CasinoRound) :
    totalProfit s (l₁ ++ l₂) = totalProfit s l₁ + totalProfit s l₂ := by
  induction l₁ <;> simp_all +decide [ totalProfit ];
  ring

/-! ## Incompleteness Gap -/

/-- The **incompleteness gap**: difference between perfect play and achievable play. -/
def incompletenessGap (rounds : List CasinoRound) : ℕ :=
  rounds.length - decidableCount rounds

/-
decidableCount is bounded by list length
-/
theorem decidableCount_le_length (rounds : List CasinoRound) :
    decidableCount rounds ≤ rounds.length := by
  induction' rounds with r rounds ih;
  · rfl;
  · simp +arith +decide [ decidableCount ];
    split_ifs <;> linarith

/-
The incompleteness gap bounds the lost profit.
-/
theorem incompleteness_gap_eq (rounds : List CasinoRound) :
    (↑rounds.length : ℤ) - totalProfit selectiveStrategy rounds =
    ↑(incompletenessGap rounds) := by
  rw [ eq_comm, incompletenessGap ];
  rw [ Nat.cast_sub ( decidableCount_le_length rounds ), selective_profit_eq_decidable_count ]

/-! ## Tropical Connection: Cross-Domain Bridge (Logic ↔ Tropical Geometry)

In the max-plus semiring (ℤ, max, +), optimizing over strategies becomes a
tropical polynomial evaluation. The tropical profit of a round is the maximum
payoff achievable from any bet.
-/

/-- The tropical (max-plus) optimal payoff at a single round. -/
def tropicalOptimalPayoff (r : CasinoRound) : ℤ :=
  max (betPayoff r .betTrue) (max (betPayoff r .betFalse) (betPayoff r .abstain))

/-- The tropical optimal payoff is always exactly 1. -/
theorem tropicalOptimalPayoff_eq_one (r : CasinoRound) :
    tropicalOptimalPayoff r = 1 := by
  unfold tropicalOptimalPayoff betPayoff
  cases r with | mk t d => cases t <;> simp

/-
The total tropical optimal profit equals the number of rounds.
-/
theorem tropical_total_eq_length (rounds : List CasinoRound) :
    (rounds.map tropicalOptimalPayoff).sum = ↑rounds.length := by
  induction rounds <;> simp +decide [ * ];
  rw [ add_comm, tropicalOptimalPayoff_eq_one ]

/-
**Tropical-Casino Bridge Theorem**: selective profit times length equals
  decidable count times tropical optimal.
-/
theorem tropical_casino_bridge (rounds : List CasinoRound) :
    totalProfit selectiveStrategy rounds * ↑rounds.length =
    ↑(decidableCount rounds) * (rounds.map tropicalOptimalPayoff).sum := by
  rw [ selective_profit_eq_decidable_count, tropical_total_eq_length, mul_comm ]

/-! ## Finset-based Formulation -/

/-- A Gödel Casino game over a finite index set. -/
structure GodelCasino (ι : Type*) [Fintype ι] [DecidableEq ι] where
  /-- Truth assignment for each round -/
  truth : ι → Bool
  /-- Decidability oracle -/
  decidable : ι → Bool

/-- Strategy for a finset-indexed casino -/
def FinStrategy (ι : Type*) := ι → CasinoBet

/-- Profit of a strategy in a finset-indexed casino -/
def finProfit {ι : Type*} [Fintype ι] [DecidableEq ι]
    (G : GodelCasino ι) (s : FinStrategy ι) : ℤ :=
  ∑ i : ι, betPayoff ⟨G.truth i, G.decidable i⟩ (s i)

/-- The selective strategy for a finset-indexed casino -/
def finSelectiveStrategy {ι : Type*} [Fintype ι] [DecidableEq ι]
    (G : GodelCasino ι) : FinStrategy ι := fun i =>
  if G.decidable i then
    if G.truth i then .betTrue else .betFalse
  else
    .abstain

/-- Number of decidable rounds in a finset-indexed casino -/
def finDecidableCount {ι : Type*} [Fintype ι] [DecidableEq ι]
    (G : GodelCasino ι) : ℕ :=
  (Finset.univ.filter (fun i => G.decidable i = true)).card

/-
**Finset Selective Profit Theorem**: The selective strategy profit
  equals the number of decidable rounds.
-/
theorem fin_selective_profit_eq {ι : Type*} [Fintype ι] [DecidableEq ι]
    (G : GodelCasino ι) :
    finProfit G (finSelectiveStrategy G) = ↑(finDecidableCount G) := by
  -- We'll use the fact that the profit from the selective strategy is equal to the number of decidable rounds.
  have h_profit : ∑ i, betPayoff ⟨G.truth i, G.decidable i⟩ (finSelectiveStrategy G i) = ∑ i ∈ Finset.univ.filter (fun i => G.decidable i), 1 := by
    rw [ Finset.sum_filter, ← Finset.sum_congr rfl ];
    unfold finSelectiveStrategy betPayoff; aesop;
  aesop

/-
**Finset Optimality**: No strategy achieves more than `Fintype.card ι` profit.
-/
theorem fin_profit_le_card {ι : Type*} [Fintype ι] [DecidableEq ι]
    (G : GodelCasino ι) (s : FinStrategy ι) :
    finProfit G s ≤ ↑(Fintype.card ι) := by
  exact le_trans ( Finset.sum_le_sum fun i _ => show betPayoff _ _ ≤ 1 from by unfold betPayoff; aesop ) ( by simpa )

/-! ## Information-Theoretic Bound -/

/-- The decidable fraction of a game. -/
def decidableFraction {ι : Type*} [Fintype ι] [DecidableEq ι]
    (G : GodelCasino ι) : ℚ :=
  (finDecidableCount G : ℚ) / (Fintype.card ι : ℚ)

/-
**Information bound**: The selective strategy captures profit proportional
  to the decidable fraction.
-/
theorem selective_captures_decidable_fraction {ι : Type*} [Fintype ι] [DecidableEq ι]
    (G : GodelCasino ι) (h : 0 < Fintype.card ι) :
    (finProfit G (finSelectiveStrategy G) : ℚ) / (Fintype.card ι : ℚ) =
    decidableFraction G := by
  rw [ fin_selective_profit_eq, decidableFraction ];
  rfl

/-
**Worst-case blind strategy theorem**: betting TRUE on all undecidable rounds,
  the adversary can make profit = -n.
-/
theorem blind_strategy_worst_case (n : ℕ) (_hn : 0 < n) :
    ∃ G : GodelCasino (Fin n),
      (∀ i, G.decidable i = false) ∧
      finProfit G (fun _ => .betTrue) = -↑n := by
  refine' ⟨ ⟨ fun _ => Bool.false, fun _ => Bool.false ⟩, _, _ ⟩ <;> simp +decide [ finProfit ];
  unfold betPayoff; aesop;

/-- A naive strategy always bets TRUE. -/
def naiveStrategy : FinStrategy ι := fun _ => .betTrue

/-
**Incompleteness Advantage**: When ALL undecidable statements are false
  (worst case for naive betting) and at least one undecidable round exists,
  the selective strategy strictly outperforms the naive "always bet TRUE" strategy.
  This demonstrates that meta-knowledge about decidability is advantageous.
-/
theorem incompleteness_advantage {n : ℕ}
    (G : GodelCasino (Fin n))
    (h_undec_false : ∀ i : Fin n, G.decidable i = false → G.truth i = false)
    (h_exists_undec : ∃ i : Fin n, G.decidable i = false) :
    finProfit G naiveStrategy < finProfit G (finSelectiveStrategy G) := by
  refine' Finset.sum_lt_sum _ _;
  · intro i hi; by_cases hi' : G.decidable i <;> simp_all +decide [ naiveStrategy, finSelectiveStrategy ] ;
    cases h : G.truth i <;> simp +decide [ h ];
  · grind +locals

/-! ## Decidability Density -/

/-- Adding a decidable round increases selective strategy profit by exactly 1. -/
theorem selective_profit_cons_decidable (r : CasinoRound) (h : r.isDecidable = true)
    (rs : List CasinoRound) :
    totalProfit selectiveStrategy (r :: rs) = 1 + totalProfit selectiveStrategy rs := by
  simp only [totalProfit]; rw [selectiveStrategy_decidable_payoff r h]

/-- Adding an undecidable round does not change selective strategy profit. -/
theorem selective_profit_cons_undecidable (r : CasinoRound) (h : r.isDecidable = false)
    (rs : List CasinoRound) :
    totalProfit selectiveStrategy (r :: rs) = totalProfit selectiveStrategy rs := by
  simp only [totalProfit]; rw [selectiveStrategy_undecidable_payoff r h]; ring

/-! ## Falsifiable Conjecture

**Conjecture**: For any sequence of `n` arithmetic statements of bounded quantifier
complexity ≤ k, the fraction of statements decidable in PA is at least `1/(k+1)`.

This is computationally testable: enumerate arithmetic sentences by complexity and
check decidability. The conjecture predicts that at each level of the arithmetic
hierarchy, at least a fixed fraction of sentences are decidable.

We state a model-level version: in any finite casino, the selective strategy
profit is at least 1 if any decidable round exists. -/

/-
**Falsifiable conjecture (model level)**: For any casino game where at least
  fraction `1/k` of rounds are decidable, the selective strategy achieves
  profit at least `n/k` where n is the number of rounds.

  Testable: generate random casino instances and verify the bound.
-/
theorem decidable_fraction_profit_bound {ι : Type*} [Fintype ι] [DecidableEq ι]
    (G : GodelCasino ι) (k : ℕ) (_hk : 0 < k)
    (h_frac : k * finDecidableCount G ≥ Fintype.card ι) :
    (k : ℤ) * finProfit G (finSelectiveStrategy G) ≥ ↑(Fintype.card ι) := by
  rw [ fin_selective_profit_eq ] ; exact_mod_cast h_frac

end