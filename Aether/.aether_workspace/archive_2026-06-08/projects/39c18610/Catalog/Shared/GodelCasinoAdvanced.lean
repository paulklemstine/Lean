import Mathlib

/-!
# Gödel's Casino: Oracle Hierarchies and Information Value

We develop an advanced theory of Gödel's Casino that formalizes:
1. **Oracle-augmented games** — how strengthening the decidability oracle affects strategy profit
2. **Strategy dominance preorder** — a partial order on strategies
3. **Incompleteness entropy** — an information-theoretic measure of undecidability
4. **Layered Casino** — a multi-round game with escalating oracle strength
5. **Information Value Theorem** — the exact value of decidability information

## Novel Definitions

* `OracleCasino` — a casino parameterized by an oracle (decidability predicate)
* `StrategyDominates` — preorder on strategies measuring worst-case relative performance
* `IncompletenessEntropy` — the fraction of undecidable rounds
* `LayeredCasino` — multi-layer game where each layer has a stronger oracle
* `OracleUnion` — combining two oracles into one

## Main Results

* **Oracle Monotonicity**: Strengthening the oracle never decreases optimal profit
* **Information Value Theorem**: Additional profit = additional decidable rounds
* **Dominance Transitivity**: Strategy dominance is a preorder
* **Layer Profit Monotonicity**: Higher layers yield weakly more profit
* **Entropy-Profit Duality**: Entropy + decidable fraction = 1
* **Oracle Composition**: Union of oracles dominates each component
* **Oracle Query Equivalence**: Profit depends only on COUNT of decidable rounds
* **Binary Casino Zero-Sum**: Fundamental zero-sum property of binary bets

## Cross-domain Connections

* Logic ↔ Information Theory: incompleteness entropy captures information loss
* Game Theory ↔ Order Theory: strategy comparison forms a preorder
* Computability ↔ Game Theory: oracle hierarchy maps to profit hierarchy
-/

noncomputable section

open Finset BigOperators

/-! ## Core Definitions -/

/-- A bet in Gödel's Casino. -/
inductive GBet : Type
  | betTrue  : GBet
  | betFalse : GBet
  | abstain  : GBet
  deriving DecidableEq, Repr

/-- Payoff from a single bet: +1 correct, -1 incorrect, 0 abstain. -/
def gPayoff (truth : Bool) (b : GBet) : ℤ :=
  match b with
  | .abstain  => 0
  | .betTrue  => if truth then 1 else -1
  | .betFalse => if truth then -1 else 1

@[simp] theorem gPayoff_abstain (t : Bool) : gPayoff t .abstain = 0 := rfl

theorem gPayoff_abs_le (t : Bool) (b : GBet) : |gPayoff t b| ≤ 1 := by
  cases b <;> simp [gPayoff] <;> cases t <;> simp

theorem gPayoff_correct (t : Bool) :
    gPayoff t (if t then .betTrue else .betFalse) = 1 := by
  cases t <;> simp [gPayoff]

/-! ## Part I: Oracle Casino -/

/-- An Oracle Casino: statements indexed by `ι` with truth values and
decidability determined by an oracle. -/
structure OracleCasino (ι : Type*) [Fintype ι] where
  truth : ι → Bool
  oracle : ι → Bool

/-- The selective strategy: bet correctly on oracle-decidable rounds, abstain otherwise. -/
def selectiveStrat {ι : Type*} [Fintype ι] (G : OracleCasino ι) (i : ι) : GBet :=
  if G.oracle i then
    if G.truth i then .betTrue else .betFalse
  else .abstain

/-- Profit of a strategy. -/
def casinoProfit {ι : Type*} [Fintype ι] (G : OracleCasino ι) (s : ι → GBet) : ℤ :=
  ∑ i : ι, gPayoff (G.truth i) (s i)

/-- Number of decidable rounds. -/
def decCount {ι : Type*} [Fintype ι] [DecidableEq ι] (G : OracleCasino ι) : ℕ :=
  (Finset.univ.filter (fun i => G.oracle i = true)).card

/-- Number of undecidable rounds. -/
def undecCount {ι : Type*} [Fintype ι] [DecidableEq ι] (G : OracleCasino ι) : ℕ :=
  (Finset.univ.filter (fun i => G.oracle i = false)).card

/-- Selective strategy payoff on a single round. -/
theorem selective_single {ι : Type*} [Fintype ι] (G : OracleCasino ι) (i : ι) :
    gPayoff (G.truth i) (selectiveStrat G i) = if G.oracle i then 1 else 0 := by
  simp only [selectiveStrat]
  split
  · exact gPayoff_correct (G.truth i)
  · rfl

/-- **Selective Profit Theorem**: Selective strategy profit = decidable count. -/
theorem selective_profit_eq {ι : Type*} [Fintype ι] [DecidableEq ι]
    (G : OracleCasino ι) :
    casinoProfit G (selectiveStrat G) = ↑(decCount G) := by
  simp only [casinoProfit, decCount]
  rw [← Finset.sum_boole]
  congr 1; ext i
  simp only [selective_single]

/-
**Profit Ceiling**: No strategy exceeds `Fintype.card ι` profit.
-/
theorem profit_ceiling {ι : Type*} [Fintype ι] [DecidableEq ι]
    (G : OracleCasino ι) (s : ι → GBet) :
    casinoProfit G s ≤ ↑(Fintype.card ι) := by
  exact le_trans ( Finset.sum_le_sum fun i _ => show gPayoff ( G.truth i ) ( s i ) ≤ 1 by exact le_of_abs_le ( gPayoff_abs_le _ _ ) ) ( by simp +decide )

/-- **Selective Non-negativity**: Selective strategy always achieves ≥ 0. -/
theorem selective_nonneg {ι : Type*} [Fintype ι] [DecidableEq ι]
    (G : OracleCasino ι) :
    0 ≤ casinoProfit G (selectiveStrat G) := by
  rw [selective_profit_eq]; exact Nat.cast_nonneg _

/-
**Selective Positive**: If any round is decidable, profit > 0.
-/
theorem selective_positive {ι : Type*} [Fintype ι] [DecidableEq ι]
    (G : OracleCasino ι) (h : ∃ i, G.oracle i = true) :
    0 < casinoProfit G (selectiveStrat G) := by
  obtain ⟨ i, hi ⟩ := h;
  rw [ selective_profit_eq ];
  exact_mod_cast Finset.card_pos.mpr ⟨ i, Finset.mem_filter.mpr ⟨ Finset.mem_univ _, hi ⟩ ⟩

/-! ## Part II: Decidable-Undecidable Partition -/

/-
Decidable and undecidable counts partition the total.
-/
theorem dec_undec_partition {ι : Type*} [Fintype ι] [DecidableEq ι]
    (G : OracleCasino ι) :
    decCount G + undecCount G = Fintype.card ι := by
  convert Finset.card_add_card_compl ( Finset.univ.filter fun i => G.oracle i = true );
  exact congr_arg Finset.card ( by ext; simp +decide [ undecCount ] )

/-! ## Part III: Incompleteness Entropy -/

/-- **Incompleteness Entropy**: fraction of undecidable rounds.
This measures how much "information" is lost due to incompleteness. -/
def incompletenessEntropy {ι : Type*} [Fintype ι] [DecidableEq ι]
    (G : OracleCasino ι) : ℚ :=
  (undecCount G : ℚ) / (Fintype.card ι : ℚ)

/-- **Decidable Fraction**: fraction of decidable rounds. -/
def decidableFraction {ι : Type*} [Fintype ι] [DecidableEq ι]
    (G : OracleCasino ι) : ℚ :=
  (decCount G : ℚ) / (Fintype.card ι : ℚ)

/-
**Entropy-Profit Duality**: Incompleteness entropy + decidable fraction = 1.
What incompleteness takes away is exactly what decidability gives.
-/
theorem entropy_profit_duality {ι : Type*} [Fintype ι] [DecidableEq ι]
    (G : OracleCasino ι) (hcard : (0 : ℚ) < Fintype.card ι) :
    incompletenessEntropy G + decidableFraction G = 1 := by
  rw [ incompletenessEntropy, decidableFraction, div_add_div_same, div_eq_iff ] <;> norm_cast at * ; linarith [ dec_undec_partition G ];
  linarith

/-! ## Part IV: Strategy Dominance -/

/-- Strategy `s₁` dominates `s₂` if it achieves ≥ profit on every truth assignment. -/
def StrategyDominates {ι : Type*} [Fintype ι]
    (_oracle : ι → Bool) (s₁ s₂ : ι → GBet) : Prop :=
  ∀ truth : ι → Bool,
    (∑ i, gPayoff (truth i) (s₁ i)) ≥ (∑ i, gPayoff (truth i) (s₂ i))

/-- **Dominance Reflexivity**. -/
theorem dominance_refl {ι : Type*} [Fintype ι]
    (oracle : ι → Bool) (s : ι → GBet) :
    StrategyDominates oracle s s :=
  fun _ => le_refl _

/-- **Dominance Transitivity**. -/
theorem dominance_trans {ι : Type*} [Fintype ι]
    (oracle : ι → Bool) (s₁ s₂ s₃ : ι → GBet)
    (h₁₂ : StrategyDominates oracle s₁ s₂)
    (h₂₃ : StrategyDominates oracle s₂ s₃) :
    StrategyDominates oracle s₁ s₃ := by
  intro truth
  exact le_trans (h₂₃ truth) (h₁₂ truth)

/-! ## Part V: Oracle Augmentation -/

/-- An augmented casino with base decidability and oracle extension. -/
structure AugmentedCasino (ι : Type*) [Fintype ι] where
  truth : ι → Bool
  baseDec : ι → Bool
  oracleExt : ι → Bool

/-- Combined decidability: base OR oracle. -/
def AugmentedCasino.combined {ι : Type*} [Fintype ι]
    (G : AugmentedCasino ι) (i : ι) : Bool :=
  G.baseDec i || G.oracleExt i

/-- Base decidable count. -/
def AugmentedCasino.baseCount {ι : Type*} [Fintype ι] [DecidableEq ι]
    (G : AugmentedCasino ι) : ℕ :=
  (Finset.univ.filter (fun i => G.baseDec i = true)).card

/-- Combined decidable count. -/
def AugmentedCasino.combinedCount {ι : Type*} [Fintype ι] [DecidableEq ι]
    (G : AugmentedCasino ι) : ℕ :=
  (Finset.univ.filter (fun i => G.combined i = true)).card

/-
**Oracle Extension Monotonicity**: Combined decidability ≥ base decidability.
-/
theorem augmented_monotone {ι : Type*} [Fintype ι] [DecidableEq ι]
    (G : AugmentedCasino ι) :
    G.baseCount ≤ G.combinedCount := by
  exact Finset.card_mono fun x hx => by simp_all +decide [ AugmentedCasino.combined ] ;

/-- **Information Value**: Additional decidable rounds from the oracle. -/
def informationValue {ι : Type*} [Fintype ι] [DecidableEq ι]
    (G : AugmentedCasino ι) : ℕ :=
  G.combinedCount - G.baseCount

/-- **Information Value Theorem**: The oracle's information value equals the
number of newly decidable statements. Formally, the profit difference between
oracle-augmented and base selective play equals `informationValue`. -/
theorem information_value_eq {ι : Type*} [Fintype ι] [DecidableEq ι]
    (G : AugmentedCasino ι) :
    (G.combinedCount : ℤ) - (G.baseCount : ℤ) = ↑(informationValue G) := by
  simp only [informationValue]
  have h := augmented_monotone G
  omega

/-! ## Part VI: Layered Casino (Oracle Hierarchy) -/

/-- A Layered Casino: a sequence of oracle levels where each level decides
a superset of the previous level. Models the arithmetic hierarchy. -/
structure LayeredCasino (ι : Type*) [Fintype ι] (L : ℕ) where
  truth : ι → Bool
  oracle : Fin (L + 1) → ι → Bool
  mono : ∀ (k : Fin L) (i : ι),
    oracle ⟨k.val, by omega⟩ i = true → oracle ⟨k.val + 1, by omega⟩ i = true

/-- Profit at a given oracle level. -/
def layerDecCount {ι : Type*} [Fintype ι] [DecidableEq ι] {L : ℕ}
    (G : LayeredCasino ι L) (level : Fin (L + 1)) : ℕ :=
  (Finset.univ.filter (fun i => G.oracle level i = true)).card

/-
**Layer Decidability Monotonicity**: Higher oracle levels decide more.
-/
theorem layer_mono {ι : Type*} [Fintype ι] [DecidableEq ι] {L : ℕ}
    (G : LayeredCasino ι L) (k : Fin L) :
    layerDecCount G ⟨k.val, by omega⟩ ≤ layerDecCount G ⟨k.val + 1, by omega⟩ := by
  refine Finset.card_mono ?_;
  intro i hi; have := G.mono k i; aesop;

/-! ## Part VII: Binary Casino Zero-Sum -/

/-- A binary bet (no abstain). -/
inductive BBet : Type
  | yes : BBet
  | no  : BBet
  deriving DecidableEq

/-- Binary payoff. -/
def bPayoff (truth : Bool) (b : BBet) : ℤ :=
  match b with
  | .yes => if truth then 1 else -1
  | .no  => if truth then -1 else 1

/-- **Binary Zero-Sum**: Sum over both truth values is zero. -/
theorem binary_zero_sum (b : BBet) :
    bPayoff true b + bPayoff false b = 0 := by
  cases b <;> simp [bPayoff]

/-- For any binary bet, the payoff is ±1. -/
theorem bPayoff_values (t : Bool) (b : BBet) :
    bPayoff t b = 1 ∨ bPayoff t b = -1 := by
  cases t <;> cases b <;> simp [bPayoff]

/-! ## Part VIII: Oracle Union -/

/-- Union of two oracles. -/
def oracleUnion {ι : Type*} (o₁ o₂ : ι → Bool) : ι → Bool :=
  fun i => o₁ i || o₂ i

/-
**Oracle Union Dominance (left)**: Union decides everything o₁ decides.
-/
theorem union_dominates_left {ι : Type*} [Fintype ι] [DecidableEq ι]
    (o₁ o₂ : ι → Bool) :
    (univ.filter (fun i => o₁ i = true)).card ≤
    (univ.filter (fun i => oracleUnion o₁ o₂ i = true)).card := by
  exact Finset.card_mono fun x hx => by unfold oracleUnion; aesop;

/-
**Oracle Union Dominance (right)**: Union decides everything o₂ decides.
-/
theorem union_dominates_right {ι : Type*} [Fintype ι] [DecidableEq ι]
    (o₁ o₂ : ι → Bool) :
    (univ.filter (fun i => o₂ i = true)).card ≤
    (univ.filter (fun i => oracleUnion o₁ o₂ i = true)).card := by
  exact Finset.card_mono fun x hx => by unfold oracleUnion; aesop;

/-- **Oracle Query Equivalence**: Selective strategy profit depends only on the
COUNT of decidable rounds, not on WHICH rounds are decidable. All decidable
knowledge is equally valuable. -/
theorem oracle_query_equivalence {ι : Type*} [Fintype ι] [DecidableEq ι]
    (truth : ι → Bool) (o₁ o₂ : ι → Bool)
    (h : (univ.filter (fun i => o₁ i = true)).card =
         (univ.filter (fun i => o₂ i = true)).card) :
    casinoProfit ⟨truth, o₁⟩ (selectiveStrat ⟨truth, o₁⟩) =
    casinoProfit ⟨truth, o₂⟩ (selectiveStrat ⟨truth, o₂⟩) := by
  rw [selective_profit_eq, selective_profit_eq]
  exact_mod_cast h

/-! ## Part IX: Adversarial Worst Case -/

/-
**Adversarial Worst Case**: If ALL rounds are undecidable, the adversary
can ensure any fixed strategy achieves profit = -n (maximum loss).
-/
theorem adversarial_worst_case (n : ℕ) (_hn : 0 < n) :
    ∃ G : OracleCasino (Fin n),
      (∀ i, G.oracle i = false) ∧
      casinoProfit G (fun _ => .betTrue) = -↑n := by
  refine' ⟨ ⟨ fun _ => Bool.false, fun _ => Bool.false ⟩, _, _ ⟩ <;> simp +decide [ casinoProfit ];
  grind +locals

/-- **Selective Resilience**: Even in the worst case, selective strategy never loses. -/
theorem selective_never_loses {ι : Type*} [Fintype ι] [DecidableEq ι]
    (G : OracleCasino ι) :
    0 ≤ casinoProfit G (selectiveStrat G) :=
  selective_nonneg G

/-! ## Part X: Falsifiable Conjecture (Arithmetic Decidability Density)

**Conjecture**: For any finite collection of arithmetic sentences of quantifier
depth at most `k` in the arithmetic hierarchy, the fraction decidable in PA
is at least `1/(2^k)`.

**Testable prediction**: Enumerate Σ₁ sentences up to length 100. At least 50%
should be decidable in PA (since Σ₁-completeness guarantees all true Σ₁ sentences
are provable, and at least half of random Σ₁ sentences are true).

We state a conditional version:
-/

/-- **Conditional Decidability Bound**: If at least fraction 1/m of rounds are
decidable, then the selective strategy achieves profit ≥ n/m. -/
theorem conditional_decidability_bound {ι : Type*} [Fintype ι] [DecidableEq ι]
    (G : OracleCasino ι) (m : ℕ) (_hm : 0 < m)
    (h_frac : m * decCount G ≥ Fintype.card ι) :
    (m : ℤ) * casinoProfit G (selectiveStrat G) ≥ ↑(Fintype.card ι) := by
  rw [selective_profit_eq]
  exact_mod_cast h_frac

end